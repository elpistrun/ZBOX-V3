if(SERVER)then 
	AddCSLuaFile() 
end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Coalition's Orders"
SWEP.Instructions = "Press LMB to call in rapid bombardment to designated location."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 35
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/ichat/w_radio.mdl"
SWEP.WorldModelReal = "models/weapons/ichat/c_radio.mdl"

SWEP.AnimList = {
    ["deploy"] = { "draw", 1, false },
    ["fire"] = { "fire", 1, false },
    ["idle"] = { "idle", 1, true }
}

if(CLIENT)then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true

SWEP.HoldPos = Vector(2, -4, 4)
SWEP.HoldAng = Angle(25, 5, 15)

if(SERVER)then
    
    local function AS_GetPlaneHeightAt(pos)
        local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,100000), mask = MASK_SOLID_BRUSHONLY})
        local worldTop = (tr.HitPos.z - 100)
        return math.min(worldTop, pos.z + 5000)
    end

    function CallB2Airstrike(target)
        local delay = math.Rand(5, 7)
        timer.Simple(delay + 0.5, function()
             -- Play arrival sound 0.5 seconds after arrival
             for _, p in ipairs(player.GetAll()) do
                 if IsValid(p) then p:EmitSound("b2fly.mp3", 80, 100, 1) end
             end
        end)

        timer.Simple(delay, function()
            local h = AS_GetPlaneHeightAt(target)
            local minB, maxB = game.GetWorld():GetModelBounds()
            local axis = math.random(1,2)
            local startPos, endPos
            if axis == 1 then
                startPos = Vector(minB.x - 3500, target.y, h)
                endPos = Vector(maxB.x + 3500, target.y, h)
            else
                startPos = Vector(target.x, minB.y - 3500, h)
                endPos = Vector(target.x, maxB.y + 3500, h)
            end
            local dirNorm = (endPos - startPos):GetNormalized()
            endPos = endPos + dirNorm * 2500
            local plane = ents.Create("prop_dynamic")
            if not IsValid(plane) then return end
            plane:SetModel("models/b2/b2.mdl")
            plane:SetPos(startPos)
            local dir = endPos - startPos
            local ang = dir:Angle()
            ang:RotateAroundAxis(ang:Up(), 180)
            plane:SetAngles(ang)
            plane:Spawn()
            plane:Activate()
            util.ScreenShake(target, 1, 2, 6, 99999)
            local shakeTimer = "AS_JetShake_" .. plane:EntIndex()
            timer.Create(shakeTimer, 0.4, 0, function()
                if not IsValid(plane) then timer.Remove(shakeTimer) return end
                for _, e in ipairs(ents.GetAll()) do
                    local phys = e:GetPhysicsObject()
                    if IsValid(phys) and phys:IsMotionEnabled() then
                        phys:ApplyForceCenter(VectorRand() * 15)
                    end
                end
            end)
            local speed = 800 * 3.0
            local dist = startPos:Distance(endPos)
            local dur = dist / speed
            local startTime = CurTime()
            local hn = "AS_AirstrikePlane_" .. plane:EntIndex()
            hook.Add("Think", hn, function()
                if not IsValid(plane) then hook.Remove("Think", hn) return end
                local tBase = (CurTime() - startTime) / dur
                local accelStart = 0.8
                local accelFactor = 1.7
                local t
                if tBase > accelStart then
                    local tail = tBase - accelStart
                    t = math.min(1, accelStart + tail * accelFactor)
                else
                    t = tBase
                end
                if tBase >= 1 then plane:Remove() hook.Remove("Think", hn) timer.Remove(shakeTimer) return end
                local p = LerpVector(t, startPos, endPos)
                plane:SetPos(p)
            end)
            local dropT
            if axis == 1 then
                dropT = math.Clamp((target.x - startPos.x) / (endPos.x - startPos.x), 0, 1)
            else
                dropT = math.Clamp((target.y - startPos.y) / (endPos.y - startPos.y), 0, 1)
            end
            
            local bombCount = 20
            local bombInterval = 0.25 -- Increased spacing
            local spreadTime = bombCount * bombInterval
            local startDropTime = (dur * dropT) - (spreadTime / 2)
            
            -- Right vector relative to flight path for dual row
            local rightVec = ang:Right() * 150 -- Offset distance

            for i = 0, bombCount - 1 do
                local bTime = startDropTime + (i * bombInterval)
                if bTime > 0 then
                    timer.Simple(bTime, function()
                        if not IsValid(plane) then return end
                        
                        local function DropBomb(offset)
                             local bombClass = "ent_jack_gmod_ezbomb"
                             -- Removed big bomb chance
                             
                             local bomb = ents.Create(bombClass)
                             if not IsValid(bomb) then return end
                             bomb:SetPos(plane:GetPos() + Vector(0,0,-60) + offset)
                             bomb:Spawn()
                             bomb:Activate()
                             
                             -- Prevent mid-air collisions/explosions
                             bomb:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
                             local phys = bomb:GetPhysicsObject()
                             if IsValid(phys) then
                                 phys:EnableDrag(false)
                                 phys:SetVelocity(Vector(0,0,-1000)) -- Initial downward velocity
                             end
                             
                             if bomb.Arm then
                                 bomb:Arm()
                             elseif bomb.SetState then
                                 bomb:SetState(1)
                             end

                             -- Play falling sound
                             bomb:EmitSound("bombfalling.mp3", 80, 100, 1)
                             
                             -- Stop sound on removal/explosion
                             local bombId = bomb:EntIndex()
                             local soundHook = "AS_BombSound_" .. bombId
                             hook.Add("EntityRemoved", soundHook, function(ent)
                                if ent == bomb then
                                    ent:StopSound("bombfalling.mp3")
                                    hook.Remove("EntityRemoved", soundHook)
                                end
                             end)
                        end

                        -- Drop two bombs (left and right)
                        DropBomb(rightVec)
                        DropBomb(-rightVec)

                    end)
                end
            end
        end)
    end

    function SWEP:PrimaryAttack()
        if self:GetNextPrimaryFire() > CurTime() then return end
        self:SetNextPrimaryFire(CurTime() + 10)

        local owner = self:GetOwner()
        local tr = owner:GetEyeTrace()
        
        -- Play confirmation sound to owner
        owner:EmitSound("airstrikecallin.ogg", 75, 100, 0.8)
        
        -- Play global sound
        -- for _, p in ipairs(player.GetAll()) do
        --    if IsValid(p) then p:EmitSound("jetflybylong.wav", 80, 100, 1) end
        -- end

        CallB2Airstrike(tr.HitPos)
        
        self:PlayAnim("fire")
    end

    function SWEP:SecondaryAttack()
    end
    
    function SWEP:Reload()
    end

    function SWEP:RagdollFunc(pos, angles, ragdoll)
		shadowControl = shadowControl or hg.ShadowControl
		local fakeGun = ragdoll.fakeGun
		shadowControl(ragdoll, 5, 0.001, angles, 500, 30, pos, 500, 50)
	end
end

if(CLIENT)then
	function SWEP:DrawHUD()
		if(GetViewEntity() ~= LocalPlayer())then 
			return 
		end

		if(LocalPlayer():InVehicle())then 
			return 
		end
	end
end
