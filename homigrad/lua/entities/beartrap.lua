AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Beartrap"
ENT.Instructions = "heavy steel bear trap designed to immobilize targets on contact. Once triggered, it clamps down with strong force, restricting movement and dealing damage over time. Hold LMB to Deploy."
ENT.Author = "MeleeCorp"
ENT.Category = "Homigrad"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
    util.AddNetworkString("Beartrap_Minigame")
    util.AddNetworkString("Beartrap_Attempt")

    function ENT:Initialize()
        self:SetModel("models/stiffy360/beartrap.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        -- Use lowercase sequence names as seen in SWEP
        local seq = self:LookupSequence("open")
        if seq == -1 then seq = self:LookupSequence("Open") end
        
        if seq ~= -1 then
            self:ResetSequence(seq)
        else
            -- Fallback if specific "open" animation missing
            self:ResetSequence(0) 
        end
        
        self:SetPlaybackRate(1)
        
        -- Animation state
        self.AnimState = "open"
        self.NextAnimCheck = CurTime() + 1

        self.IsTrapped = false
        self.TrappedEntity = nil
        self.TrappedLimb = nil
    end

    function ENT:Think()
        -- Must advance frames for animations to play on non-player entities
        self:FrameAdvance()
        
        -- Animation loop logic
        if self.AnimState == "open" then
            if self:IsSequenceFinished() then
                local seq = self:LookupSequence("openidle")
                if seq == -1 then seq = self:LookupSequence("OpenIdle") end
                
                if seq ~= -1 then
                    self:ResetSequence(seq)
                    self.AnimState = "openidle"
                end
            end
        elseif self.AnimState == "snap" then
             if self:IsSequenceFinished() then
                local seq = self:LookupSequence("closedidle")
                if seq == -1 then seq = self:LookupSequence("ClosedIdle") end
                
                if seq ~= -1 then
                    self:ResetSequence(seq)
                    self.AnimState = "closedidle"
                end
            end
        end

        self:NextThink(CurTime())

        -- Prevent getting up while trapped
        if self.IsTrapped and IsValid(self.TrappedEntity) and self.TrappedEntity:IsPlayer() then
            self.TrappedEntity.fakecd = CurTime() + 1
            
            -- If player managed to get up (ragdoll removed), force them back down
            if not IsValid(self.TrappedEntity.FakeRagdoll) then
                 -- Force fake again if they somehow got up
                 if hg and hg.Fake then hg.Fake(self.TrappedEntity) end
                 
                 -- Re-attach logic will run in trigger, but we need to re-weld if ragdoll is new
                 -- This handles the edge case where they "Use" fake to get up
                 timer.Simple(0, function()
                     if IsValid(self) and IsValid(self.TrappedEntity) and IsValid(self.TrappedEntity.FakeRagdoll) then
                         self:AttachLimb(self.TrappedEntity.FakeRagdoll, self.TrappedLimb, self.TrappedEntity:LookupBone(self.TrappedLimb == "lleg" and "ValveBiped.Bip01_L_Foot" or "ValveBiped.Bip01_R_Foot")) -- Simplified lookup
                     end
                 end)
            end
        end
        
        -- Proximity Trigger
        if not self.IsTrapped and (self.AnimState == "open" or self.AnimState == "openidle") then
            local pos = self:GetPos()
            -- Increased radius from 20 to 40 for better detection
            for _, ent in ipairs(ents.FindInSphere(pos, 40)) do
                if (ent:IsPlayer() and ent:Alive()) or (ent:IsRagdoll()) then
                    -- Check for specific limb proximity
                    local limb, boneID = self:GetClosestLimb(ent)
                    if limb then
                        self:TriggerTrap(ent, limb, boneID)
                        break
                    end
                end
            end
        end

        return true
    end

    function ENT:GetClosestLimb(ent)
        local bestDist = 1000
        local bestLimb = nil
        local bestBone = nil
        
        -- Bones to check
        local bones = {
            ["ValveBiped.Bip01_L_Foot"] = "lleg",
            ["ValveBiped.Bip01_R_Foot"] = "rleg",
            ["ValveBiped.Bip01_L_Hand"] = "larm",
            ["ValveBiped.Bip01_R_Hand"] = "rarm",
            --["ValveBiped.Bip01_Head1"] = "head" -- Optional, but user emphasized limbs
        }

        for boneName, limbType in pairs(bones) do
            local boneID = ent:LookupBone(boneName)
            if boneID then
                local bonePos = ent:GetBonePosition(boneID)
                local dist = bonePos:DistToSqr(self:GetPos())
                if dist < 900 then -- 30 units squared (was 16/256)
                    if dist < bestDist then
                        bestDist = dist
                        bestLimb = limbType
                        bestBone = boneID
                    end
                end
            end
        end

        return bestLimb, bestBone
    end

    function ENT:TriggerTrap(ent, limb, boneID)
        self.IsTrapped = true
        self.TrappedEntity = ent
        self.TrappedLimb = limb

        -- Visuals
        self:EmitSound("beartrap_trigger.wav")
        self:EmitSound("beartrap.wav")
        
        local seq = self:LookupSequence("snap")
        if seq == -1 then seq = self:LookupSequence("Snap") end
        if seq ~= -1 then self:ResetSequence(seq) end
        
        self:SetPlaybackRate(1)
        self.AnimState = "snap"

        -- Damage and Ragdoll
        local dmg = DamageInfo()
        dmg:SetDamage(80)
        dmg:SetDamageType(DMG_SLASH)
        dmg:SetInflictor(self)
        dmg:SetAttacker(self)

        if ent:IsPlayer() then
            -- Force ragdoll if player
            if hg and hg.Fake then 
                hg.Fake(ent) 
            end
            
            -- Wait a tick for ragdoll to be created
            timer.Simple(0, function()
                if not IsValid(ent) then return end
                local rag = ent.FakeRagdoll
                if IsValid(rag) then
                   self:AttachLimb(rag, limb, boneID)
                   self:ApplyOrganismDamage(ent, limb, dmg)
                   
                   if ent.organism then
                       ent.organism.painadd = (ent.organism.painadd or 0) + 50
                   end

                   -- Auto release after 30 seconds
                   timer.Create("BeartrapRelease_" .. self:EntIndex(), 30, 1, function()
                       if IsValid(self) then
                           self:ReleaseTrap()
                       end
                   end)
                end
            end)
        elseif ent:IsRagdoll() then
            self:AttachLimb(ent, limb, boneID)
            -- Get owner if exists to apply organism damage
            local owner = hg.RagdollOwner(ent)
            if IsValid(owner) then
                self:ApplyOrganismDamage(owner, limb, dmg)
            else
                -- Try to apply to ragdoll itself if it has organism
                 if ent.organism then
                     self:ApplyOrganismDamage(ent, limb, dmg)
                 end
            end
        end
    end

    function ENT:ApplyOrganismDamage(ent, limb, dmgInfo)
        if not ent.organism then return end
        
        -- Use input_list to break bones/damage limbs
        if hg.organism and hg.organism.input_list then
            local func = hg.organism.input_list[limb] or hg.organism.input_list[limb .. "low"]
            if func then
                func(ent.organism, 0, 1.0, dmgInfo) -- High damage to break
            else
                -- Fallback manual damage
                if limb == "lleg" then hg.organism.input_list.lleglow(ent.organism, 0, 1.0, dmgInfo) end
                if limb == "rleg" then hg.organism.input_list.rleglow(ent.organism, 0, 1.0, dmgInfo) end
                -- For arms, if keys differ
            end
        end
    end

    function ENT:AttachLimb(rag, limb, boneID)
        if not IsValid(rag) then return end
        
        -- Find physics bone
        local physBoneID = rag:TranslateBoneToPhysBone(boneID)
        local phys = rag:GetPhysicsObjectNum(physBoneID)
        
        if IsValid(phys) then
            -- Move limb to trap position instead of welding in place (which might be in air if player was standing)
            local trapPhys = self:GetPhysicsObject()
            if IsValid(trapPhys) then
                -- Teleport limb to trap center for realistic "caught" look
                -- But be careful not to stretch ragdoll too much immediately
                local trapPos = self:GetPos()
                phys:SetPos(trapPos + Vector(0,0,5)) -- Slightly above trap center
                
                -- Wake up physics
                phys:Wake()
                trapPhys:Wake()

                -- Weld
                local constraint = constraint.Weld(rag, self, physBoneID, 0, 0, false, false)
                self.WeldConstraint = constraint
                
                -- Also weld the trap to the world if it's not already, to prevent the player from walking away with it
                -- But wait, the trap is usually physics based.
                -- If we weld player to trap, and trap is loose, player drags trap.
                -- If we want player pinned, trap needs to be heavy or fixed.
                -- Beartraps are usually staked or heavy. Let's increase mass significantly while trapped.
                trapPhys:SetMass(5000) 
            end
        end
    end

    function ENT:Use(activator, caller)
        if self.IsTrapped and IsValid(activator) and activator:IsPlayer() then
            -- Can't open if you are the one trapped? Or maybe you can? 
            -- User said "someone else", usually implies another player.
            -- But "presses use" is generic. Let's allow anyone including self for now unless specified.
            -- Actually "someone else" strongly implies not self.
            if activator == self.TrappedEntity then return end
            
            self:ReleaseTrap()
        end
    end

    function ENT:ReleaseTrap()
        if IsValid(self.WeldConstraint) then
            self.WeldConstraint:Remove()
        end
        
        timer.Remove("BeartrapRelease_" .. self:EntIndex())
        
        -- Reset mass
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
             phys:SetMass(50) -- Standard mass
        end

        self.IsTrapped = false
        self.TrappedEntity = nil
        self.TrappedLimb = nil
        
        local seq = self:LookupSequence("open")
        if seq == -1 then seq = self:LookupSequence("Open") end
        if seq ~= -1 then self:ResetSequence(seq) end
        
        self:SetPlaybackRate(1)
        self.AnimState = "open"
        self:EmitSound("beartrapopen.wav") -- Release sound

        -- Cooldown before it can trap again
        self.NextTrapTime = CurTime() + 5
    end

    net.Receive("Beartrap_Attempt", function(len, ply)
        local success = net.ReadBool()
        local ent = ply.FakeRagdoll or ply -- Use ragdoll or player
        
        -- Find the trap this player is stuck in
        -- Since we don't send entity ID, we search or store.
        -- Better to send Entity Index from client? 
        -- Or just search for trap near player that has them trapped.
        
        local trap = nil
        local pos = ply:GetPos()
        for _, e in ipairs(ents.FindInSphere(pos, 100)) do
            if e:GetClass() == "beartrap" and e.TrappedEntity == ply then
                trap = e
                break
            end
        end
        
        if IsValid(trap) then
            if success then
                trap:ReleaseTrap()
            else
                -- Fail penalty?
                ply:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random(1,3) .. ".wav")
                -- Maybe add pain
            end
        end
    end)
end

if CLIENT then
    -- Minigame removed
end
