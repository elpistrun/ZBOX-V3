-- Jackarunda 2021
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "T H E   G N O M E"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Anomalies"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
---
local STATE_GNORMAL, STATE_SHANK_A_BITCH, STATE_DELET_THIS = 0, 1, 2

-- Константы баффов
local BUFF_TELEPORT_DURATION = 300
local BUFF_IGNORE_GAZE_DURATION = 150

-- Слабость: время замирания после попадания ПОД БАФФОМ
local STUN_DURATION = 6

if SERVER then
    -- Хук на попадания пуль (только для гномов под баффом)
    hook.Add("EntityTakeDamage", "GnomeStunWhenBuffed", function(target, dmginfo)
        if not IsValid(target) then return end
        if target:GetClass() ~= "ent_jack_gmod_ezanomaly_gnome" then return end
        
        local DmgType = dmginfo:GetDamageType()
        local IsBullet = bit.band(DmgType, DMG_BULLET) ~= 0
        local HasAppleBuff = (target.TeleportBuffEnd or 0) > CurTime()
        
        if IsBullet and HasAppleBuff then
            local Time = CurTime()
            target.StunEndTime = Time + STUN_DURATION
            target.FreezeTime = Time + STUN_DURATION
            
            target:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75, 100)
            local effectdata = EffectData()
            effectdata:SetOrigin(target:GetPos())
            effectdata:SetScale(2)
            util.Effect("ManhackSparks", effectdata)
        end
    end)
    
    hook.Add("PlayerTraceAttack", "GnomeStunFromTraceAttack", function(attacker, tr, dmginfo)
        if not tr.Hit or not tr.Entity then return end
        if tr.Entity:GetClass() ~= "ent_jack_gmod_ezanomaly_gnome" then return end
        
        local IsBullet = bit.band(dmginfo:GetDamageType(), DMG_BULLET) ~= 0
        local HasAppleBuff = (tr.Entity.TeleportBuffEnd or 0) > CurTime()
        
        if IsBullet and HasAppleBuff then
            local Time = CurTime()
            tr.Entity.StunEndTime = Time + STUN_DURATION
            tr.Entity.FreezeTime = Time + STUN_DURATION
            
            tr.Entity:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75, 100)
            local effectdata = EffectData()
            effectdata:SetOrigin(tr.Entity:GetPos())
            effectdata:SetScale(2)
            util.Effect("ManhackSparks", effectdata)
        end
    end)
end

---
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "VisualState")
end

---
if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/gnome.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
        
        self.FreezeTime = 0
        self.StunEndTime = 0
        self.Restlessness = 1
        self.NextBiteTime = 0
        self.WaterDeathTime = nil
        self.LastEscapeAttempt = nil
        self.TeleportBuffEnd = 0
        self.IgnoreGazeBuffEnd = 0
        self.FireDeathTime = nil
        self.IsOnFire = false
        self.LastFireJumpTime = 0
        self.Exploded = false
        self.FireCheckTime = 0

        local Phys = self:GetPhysicsObject()
        if IsValid(Phys) then
            Phys:SetMass(100)
            Phys:Wake()
        end

        timer.Simple(0, function()
            if not IsValid(self) then return end
            self:PhysicsInit(SOLID_VPHYSICS)
            local Phys = self:GetPhysicsObject()
            if IsValid(Phys) then
                Phys:SetMass(100)
                Phys:SetDamping(.5, .5)
                Phys:Wake()
            end
        end)
    end

    function ENT:ApplyAppleBuff()
        self.TeleportBuffEnd = CurTime() + BUFF_TELEPORT_DURATION
        self.IgnoreGazeBuffEnd = CurTime() + BUFF_IGNORE_GAZE_DURATION
        
        self:SetColor(Color(100, 255, 100, 255))
        sound.Play("ambient/energy/zap1.wav", self:GetPos(), 75, 100)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(2)
        util.Effect("ManhackSparks", effectdata)
    end

    function ENT:PhysicsCollide(data, physobj)
        if data.DeltaTime > 0.2 then
            if data.Speed > 200 then
                self:EmitSound("Drywall.ImpactHard")
                self.FreezeTime = CurTime() + 10
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
        
        local DmgType = dmginfo:GetDamageType()
        if DmgType == DMG_BURN or DmgType == DMG_DIRECT then
            if not self.IsOnFire then
                self:Ignite(60)
                self.IsOnFire = true
                self.FireDeathTime = CurTime() + 60
            end
        end
    end

    function ENT:Use(activator)
        if activator:IsPlayer() then
            local Time = CurTime()
            if self.NextBiteTime < Time then
                self.NextBiteTime = Time + math.Rand(1, 2)
                timer.Simple(0.1, function()
                    if not(IsValid(self)) or not(IsValid(activator)) then return end
                    sound.Play("npc/headcrab/headbite.wav", self:GetPos(), 120, math.random(90, 110))
                    sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".ogg", self:GetPos(), 60, math.random(90, 110))
                    local Dmg = DamageInfo()
                    Dmg:SetDamage(math.random(1, 2))
                    Dmg:SetDamageType(DMG_SLASH)
                    Dmg:SetAttacker(activator)
                    Dmg:SetInflictor(game.GetWorld())
                    Dmg:SetDamageForce(Vector(0, 0, 0))
                    Dmg:SetDamagePosition(activator:GetBonePosition(activator:LookupBone("ValveBiped.Bip01_L_Hand")) or activator:GetPos())
                    activator:TakeDamageInfo(Dmg)
                    self.Restlessness = self.Restlessness + 1
                end)
            end
        end
    end

    function ENT:TryEscapeFromWater()
        if not IsValid(self) then return end
        
        local SelfPos = self:GetPos()
        
        local EscapeDirections = {
            Vector(100, 0, 50),
            Vector(-100, 0, 50),  
            Vector(0, 100, 50),
            Vector(0, -100, 50),
            Vector(0, 0, 100),
            Vector(50, 50, 75),
            Vector(-50, -50, 75)
        }
        
        for _, dir in pairs(EscapeDirections) do
            local TargetPos = SelfPos + dir
            local Tr = util.TraceLine({
                start = SelfPos,
                endpos = TargetPos,
                filter = self
            })
            
            local TargetWaterCheck = util.PointContents(TargetPos)
            local TargetInWater = bit.band(TargetWaterCheck, CONTENTS_WATER) ~= 0
            
            if not TargetInWater and not Tr.Hit then
                local JumpVec = (TargetPos - SelfPos):GetNormalized()
                self:GetPhysicsObject():ApplyForceCenter(JumpVec * 80000)
                self:EmitSound("physics/water/water_splash" .. math.random(1, 3) .. ".wav", 75, 100)
                return true
            end
        end
        
        local RandomJump = Vector(math.random(-50, 50), math.random(-50, 50), 80)
        self:GetPhysicsObject():ApplyForceCenter(RandomJump:GetNormalized() * 60000)
        
        return false
    end

    function ENT:FirePanicBehavior()
        if not self.IsOnFire then return end
        
        local Time = CurTime()
        
        if Time > self.LastFireJumpTime + math.Rand(1, 2) then
            self.LastFireJumpTime = Time
            
            local SelfPos = self:GetPos()
            
            local NearestPlayer = nil
            local NearestDist = math.huge
            
            for _, ply in pairs(player.GetAll()) do
                if ply:Alive() then
                    local dist = SelfPos:Distance(ply:GetPos())
                    if dist < NearestDist then
                        NearestDist = dist
                        NearestPlayer = ply
                    end
                end
            end
            
            local JumpVec
            
            if IsValid(NearestPlayer) and NearestDist < 1000 then
                local TargetPos = NearestPlayer:GetPos() + Vector(0, 0, 10)
                JumpVec = (TargetPos - SelfPos):GetNormalized()
            else
                JumpVec = VectorRand()
                JumpVec.z = math.abs(JumpVec.z) * 0.7
                JumpVec:Normalize()
            end
            
            local ForceMultiplier = 120000 + math.random(-20000, 20000)
            self:GetPhysicsObject():ApplyForceCenter(JumpVec * ForceMultiplier)
            
            if math.random(1, 3) == 1 then
                self:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav", 80, math.random(80, 120))
            end
        end
    end

    local function FindMachine(pos, returnWhenFound)
        local Closest, ClosestDist = nil, 9e9

        for _, v in ents.Iterator() do
            local Dist = v:GetPos():Distance(pos)

            if Dist < ClosestDist then
                if v.Base and (v.Base == "ent_jack_gmod_ezmachine_base") and (v.GetState and (v:GetState() == JMod.EZ_STATE_ON)) and v.TurnOff then
                    Closest = v
                    ClosestDist = Dist
                    if returnWhenFound then return v end
                end
            end
        end

        return Closest
    end
    
    function ENT:GetObjective()
        if self.CurObjective then
            local Target = self:GetTarget(self.CurObjective)
            if self:CanCompleteObjective(self.CurObjective, Target) then
                return self.CurObjective
            end 
        end

        if not(table.IsEmpty(ents.FindByClass("ent_jack_gmod_ezapple"))) then
            return "eat"
        elseif IsValid(FindMachine(self:GetPos(), true)) then
            return "shutdown"
        else
            return "kill"
        end
    end

    function ENT:GetTarget(objective)
        local Target = nil

        if objective == "kill" then
            local Closest, SelfPos = 9e9, self:GetPos()

            for _, v in player.Iterator() do
                if v:Alive() then
                    local Dist = SelfPos:Distance(v:GetPos())

                    if Dist < Closest then
                        Target = v
                        Closest = Dist
                    end
                end
            end
        elseif objective == "shutdown" then
            Target = FindMachine(self:GetPos())
        elseif objective == "eat" then
            local Closest, SelfPos = 9e9, self:GetPos()

            for _, v in ipairs(ents.FindByClass("ent_jack_gmod_ezapple")) do
                local Dist = SelfPos:Distance(v:GetPos())

                if Dist < Closest then
                    Target = v
                    Closest = Dist
                end
            end
        end

        return Target
    end

    function ENT:FindGroundAt(pos)
        local Tr = util.QuickTrace(pos + Vector(0, 0, 30), Vector(0, 0, -300), {self})

        if Tr.Hit and not Tr.StartSolid then return Tr.HitPos end

        return nil
    end

    function ENT:IsLocationClear(pos)
        return true
    end

    function ENT:TryMoveTowardPoint(pos)
        local SelfPos = self:GetPos()
        local Dir = (pos - SelfPos):GetNormalized()
        local NewPos = SelfPos + Dir * 100
        local NewGroundPos = self:FindGroundAt(NewPos)

        if NewGroundPos then
            if not self:IsLocationBeingWatched(NewGroundPos) then
                if self:IsLocationClear(NewGroundPos) then
                    self:SnapTo(NewGroundPos)
                    return true
                end
            end
        end

        return false
    end

    function ENT:TryMoveRandomly()
        local SelfPos = self:GetPos()
        local Dir = VectorRand()
        local NewPos = SelfPos + Dir * 50 * math.Clamp(self.Restlessness, 1, 5)
        local NewGroundPos = self:FindGroundAt(NewPos)

        if NewGroundPos then
            if not self:IsLocationBeingWatched(NewGroundPos) then
                if self:IsLocationClear(NewGroundPos) then
                    self:SnapTo(NewGroundPos)
                    return true
                end
            end
        end

        return false
    end

    function ENT:SnapTo(pos)
        local Yaw = (pos - self:GetPos()):GetNormalized():Angle().y
        self:SetPos(pos)
        self:SetAngles(Angle(0, Yaw, 0))
        self:GetPhysicsObject():Sleep()
    end

    function ENT:IsLocationBeingWatched(pos)
        if (self.IgnoreGazeBuffEnd or 0) > CurTime() then
            return false
        end
        
        local PotentialObservers = table.Merge(ents.FindByClass("gmod_cameraprop"), player.GetAll())

        for k, obs in pairs(PotentialObservers) do
            local ObsPos = (obs.GetShootPos and obs:GetShootPos()) or obs:GetPos()
            local DirectVec = ObsPos - pos
            local DirectDir = DirectVec:GetNormalized()
            local FacingDir = (obs.GetAimVector and obs:GetAimVector()) or obs:GetForward()
            local ApproachAngle = -math.deg(math.asin(DirectDir:Dot(FacingDir)))

            if ApproachAngle > 30 then
                local Dist = DirectVec:Length()

                if Dist < 5000 then
                    local Tr = util.TraceLine({
                        start = pos,
                        endpos = ObsPos,
                        filter = {self, obs},
                        mask = MASK_SHOT - CONTENTS_WINDOW
                    })

                    if not Tr.Hit then return true end
                end
            end
        end

        return false
    end

    function ENT:AmBeingWatched()
        local SelfPos = self:LocalToWorld(self:OBBCenter())
        
        if (self.IgnoreGazeBuffEnd or 0) > CurTime() then
            return false
        end
        
        local PotentialObservers = table.Merge(ents.FindByClass("gmod_cameraprop"), player.GetAll())

        for k, obs in pairs(PotentialObservers) do
            local ObsPos = (obs.GetShootPos and obs:GetShootPos()) or obs:GetPos()
            local DirectVec = ObsPos - SelfPos
            local DirectDir = DirectVec:GetNormalized()
            local FacingDir = (obs.GetAimVector and obs:GetAimVector()) or obs:GetForward()
            local ApproachAngle = -math.deg(math.asin(DirectDir:Dot(FacingDir)))

            if ApproachAngle > 30 then
                local Dist = DirectVec:Length()
                if Dist < 5000 then
                    local Tr = util.TraceLine({
                        start = SelfPos,
                        endpos = ObsPos,
                        filter = {self, obs},
                        mask = MASK_SHOT - CONTENTS_WINDOW
                    })
                    if not Tr.Hit then 
                        return true 
                    end
                end
            end
        end

        return false
    end

    function ENT:GetDesiredPosition(objective, target)
        if objective == "kill" then
            if target then return self:FindGroundAt(target:GetShootPos() - target:GetAimVector() * 100) end
        elseif objective == "shutdown" then
            if target then return self:FindGroundAt(target:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0)) end
        elseif objective == "eat" then
            if target then return self:FindGroundAt(target:GetPos() + Vector(math.random(-20, 20), math.random(-20, 20), 0)) end
        end

        return nil
    end

    function ENT:FindPatsy(victim)
        if player.GetCount() > 1 then
            for k, v in player.Iterator() do
                if v ~= victim then return v end
            end
        end

        return victim
    end

    function ENT:CanCompleteObjective(objective, target)
        if not IsValid(target) then return false end
        local SelfPos = self:GetPos()

        if objective == "kill" then
            local TargPos = target:GetShootPos()
            local Dist = TargPos:Distance(SelfPos)

            if (Dist <= 220) and (Dist >= 80) then
                return not util.TraceLine({
                    start = SelfPos,
                    endpos = TargPos,
                    filter = {self, target},
                    mask = MASK_SHOT
                }).Hit
            end
        elseif objective == "shutdown" then
            local TargPos = target:GetPos() + Vector(0, 0, 1)
            local Dist = TargPos:Distance(SelfPos)

            if (Dist <= 55) and (Dist >= 10) then
                return not util.TraceLine({
                    start = SelfPos,
                    endpos = TargPos,
                    filter = {self, target},
                    mask = MASK_SHOT
                }).Hit
            end
        elseif objective == "eat" then
            local TargPos = target:GetPos() + Vector(0, 0, 1)
            local Dist = TargPos:Distance(SelfPos)

            if (Dist <= 20) and (Dist >= 2) then
                return not util.TraceLine({
                    start = SelfPos,
                    endpos = TargPos,
                    filter = {self, target},
                    mask = MASK_SHOT
                }).Hit
            end
        end

        return false
    end

    function ENT:Detonate()
        if self.Exploded then return end
        self.Exploded = true

        local SelfPos = self:GetPos()
        local Blam = EffectData()
        Blam:SetOrigin(SelfPos)
        Blam:SetScale(10)
        util.Effect("eff_jack_plastisplosion", Blam, true, true)
        util.ScreenShake(SelfPos, 99999, 99999, 1, 1000)

        for i = 1, 2 do
            sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))
        end

        for i = 1, 2 do
            sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 140, math.random(90, 110))
        end

        timer.Simple(.1, function()
            local MeltBlast = DamageInfo()
            MeltBlast:SetInflictor(game.GetWorld())
            MeltBlast:SetAttacker(game.GetWorld())
            MeltBlast:SetDamage(250)
            MeltBlast:SetDamageType(DMG_DISSOLVE)
            util.BlastDamageInfo(MeltBlast, SelfPos, 400)
            for k, v in pairs(ents.FindInSphere(SelfPos, 1000)) do 
                if v:GetClass() == "npc_strider" then
                    v:Fire("break")
                end
            end
        end)
        
        timer.Simple(1, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end

    function ENT:Think()
        local Time, SelfPos = CurTime(), self:GetPos()
        
        local IsStunned = (self.StunEndTime or 0) > Time
        
        local WaterPoint = SelfPos + Vector(0, 0, 10)
        local WaterContents = util.PointContents(WaterPoint)
        local InWater = bit.band(WaterContents, CONTENTS_WATER) ~= 0
        
        if InWater then
            if not self.WaterDeathTime then
                self.WaterDeathTime = Time + 20
            else
                local TimeLeft = self.WaterDeathTime - Time
                
                if not IsStunned and (not self.LastEscapeAttempt or self.LastEscapeAttempt + 3 < Time) then
                    self.LastEscapeAttempt = Time
                    local escaped = self:TryEscapeFromWater()
                    if escaped then
                        self.WaterDeathTime = nil
                    end
                end
                
                if TimeLeft <= 0 then
                    self:Detonate()
                    return
                end
            end
        else
            if self.WaterDeathTime then
                self.WaterDeathTime = nil
                self.LastEscapeAttempt = nil
            end
        end

        if self:IsOnFire() then
            if not self.IsOnFire then
                self.IsOnFire = true
                self.FireDeathTime = Time + 60
            end
            
            if not IsStunned then
                self:FirePanicBehavior()
            end
            
            if self.FireDeathTime then
                local timeLeft = self.FireDeathTime - Time
                if timeLeft <= 0 then
                    self:Detonate()
                    return
                end
            end
        else
            if self.IsOnFire then
                self.IsOnFire = false
                self.FireDeathTime = nil
            end
        end

        local HasTeleportBuff = (self.TeleportBuffEnd or 0) > Time
        local HasIgnoreGazeBuff = (self.IgnoreGazeBuffEnd or 0) > Time
        
        if HasTeleportBuff or HasIgnoreGazeBuff then
            if math.random(1, 20) == 1 then
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos() + Vector(0, 0, 15))
                effectdata:SetScale(1)
                util.Effect("ElectricSpark", effectdata)
            end
        else
            if self:GetColor() ~= Color(255, 255, 255, 255) then
                self:SetColor(Color(255, 255, 255, 255))
            end
        end

        local CanMove = not IsStunned and (not (self:AmBeingWatched() or ((self.FreezeTime or 0) > Time)) or HasIgnoreGazeBuff)
        
        if CanMove then
            local Objective = self:GetObjective()
            local Target = self:GetTarget(Objective)
            local DesiredPosition = self:GetDesiredPosition(Objective, Target)

            if DesiredPosition and (DesiredPosition:Distance(SelfPos) >= 100) then
                local Moved = self:TryMoveTowardPoint(DesiredPosition)

                if not Moved then
                    self:TryMoveRandomly()
                end
            elseif self:CanCompleteObjective(Objective, Target) then
                if Objective == "kill" then
                    if Target then
                        local Attacker = self:FindPatsy(Target)
                        
                        if Attacker ~= Target then
                            self:SetPhysicsAttacker(Attacker, 1)
                        end

                        local TargetFeetPos = Target:GetPos() + Vector(0, 0, 5)
                        local Vec = (TargetFeetPos - SelfPos):GetNormalized()
                        self:GetPhysicsObject():ApplyForceCenter(Vec * 150000)

                        timer.Simple(0.2, function()
                            if not IsValid(self) then return end
                            
                            local HitEntities = ents.FindInSphere(self:GetPos(), 80)
                            local HitSomething = false
                            
                            for _, hitEnt in pairs(HitEntities) do
                                if hitEnt == Target then
                                    HitSomething = true
                                    local Dmg = DamageInfo()
                                    Dmg:SetDamage(25)
                                    Dmg:SetDamageType(DMG_CRUSH)
                                    Dmg:SetAttacker(self)
                                    Dmg:SetInflictor(self)
                                    Dmg:SetDamageForce(Vec * 10000)
                                    Dmg:SetDamagePosition(TargetFeetPos)
                                    Target:TakeDamageInfo(Dmg)
                                    
                                    Target:ViewPunch(Angle(-20, 0, 0))
                                    sound.Play("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", Target:GetPos(), 75, 100)
                                    
                                elseif hitEnt:IsValid() and hitEnt ~= self and (hitEnt:GetClass():find("prop_") or hitEnt:GetClass():find("ragdoll") or hitEnt:IsNPC()) then
                                    HitSomething = true
                                    local HitPhys = hitEnt:GetPhysicsObject()
                                    if IsValid(HitPhys) then
                                        local ForceDir = (hitEnt:GetPos() - SelfPos):GetNormalized()
                                        HitPhys:ApplyForceCenter(ForceDir * 50000 + Vector(0, 0, 20000))
                                    end
                                    
                                    sound.Play("physics/metal/metal_box_impact_hard" .. math.random(1, 3) .. ".wav", hitEnt:GetPos(), 75, 100)
                                end
                            end
                            
                            if not HitSomething then
                                local Tr = util.QuickTrace(SelfPos, Vec * 50, self)
                                if Tr.Hit then
                                    util.Decal("Impact.Concrete", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                                    sound.Play("physics/concrete/concrete_impact_hard" .. math.random(1, 3) .. ".wav", Tr.HitPos, 75, 100)
                                end
                            end
                        end)

                        timer.Simple(0.5, function()
                            if IsValid(Target) and Target:Alive() then
                                self.Restlessness = math.Clamp((self.Restlessness or 1) + 3, 1, 100)
                            else
                                self.Restlessness = 1
                            end
                        end)
                    end
                elseif Objective == "shutdown" then
                    if Target then
                        Target:TurnOff()
                        Target.EZstayOn = false
                        self.Restlessness = math.Clamp((self.Restlessness or 1) - 10, 1, 100)
                    end
                elseif Objective == "eat" then
                    if Target then
                        Target:Remove()
                        sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".ogg", self:GetPos(), 60, math.random(90, 110))
                        self.Restlessness = math.Clamp((self.Restlessness or 1) - 10, 1, 100)
                        self:ApplyAppleBuff()
                    end
                end
            else
                self:TryMoveRandomly()
            end

            self.Restlessness = math.Clamp((self.Restlessness or 1) + .1, 1, 100)

            if (self.Restlessness or 1) >= 100 then
                self:Detonate()
                return
            end
        else
            if not IsStunned then
                self.Restlessness = math.Clamp((self.Restlessness or 1) - 1, 1, 100)
            end
        end

        local ThinkDelay = math.Rand(2, 4) / math.Clamp((self.Restlessness or 1), 1, 5)
        if HasTeleportBuff then
            ThinkDelay = ThinkDelay * 0.5
        end

        self:NextThink(Time + ThinkDelay)
        return true
    end

    function ENT:OnRemove()
    end
elseif CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    language.Add("ent_jack_gmod_ezanomaly_gnome", "T H E   G N O M E")
end