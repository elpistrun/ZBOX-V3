if SERVER then AddCSLuaFile() end
ENT.Base = "projectile_base"
ENT.Author = "asirius"
ENT.Category = "ZCity Other"
ENT.PrintName = "AT4 rocket"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/weapons/tfa_ins2/w_rpg7_projectile.mdl"
ENT.Sound = "snd_jack_fragsplodeclose.ogg"
ENT.SoundFar = "mortar_strike_far_dist_03.wav"
ENT.SoundWater = "iedins/water/ied_water_detonate_01.wav"
ENT.Speed = 4500
ENT.TruhstTime = 1.2
ENT.IconOverride = "vgui/inventory/weapon_rpg7"

ENT.BlastDamage = 280
ENT.BlastDis = 8

ENT.UseType = SIMPLE_USE
ENT.SafetyDistance = 15 * 52.49 

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    if SERVER then
        self:SetUseType(SIMPLE_USE)
        self.StartPos = self:GetPos()
        self.SafetyArmed = false 
        self.LaunchTime = CurTime()
        self.InitialAngles = self:GetAngles()
        self.ThrustActive = true
        self.FuelLeft = 100
        self.UpLift = Vector(0, 0, GetConVar("sv_gravity"):GetFloat() * 1)
    end
end

function ENT:Think()
    if SERVER and not self.SafetyArmed then
        self:CheckSafetyDistance()
    end
    
    if SERVER then
        local curTime = CurTime()
        local phys = self:GetPhysicsObject()
        
        if IsValid(phys) then
            -- Исправленная строка - используем SetGravityScale вместо SetGravity
            phys:SetGravityScale(0.01)
            
            if curTime < self.LaunchTime + self.TruhstTime then
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos() - self:GetForward() * 20)
                effectdata:SetNormal(-self:GetForward())
                effectdata:SetScale(2)
                util.Effect("MuzzleEffect", effectdata, true)
                
                if not self.EngineSoundStarted then
                    self:EmitSound("weapons/rpg/rocket1.wav", 75, 100, 0.5)
                    self.EngineSoundStarted = true
                end
            else
                self.ThrustActive = false
                if self.EngineSoundStarted and not self.CoastSoundStarted then
                    self:EmitSound("weapons/rpg/rocket1.wav", 35, 105, 0.15)
                    self.CoastSoundStarted = true
                end
            end
            
            if self.ThrustActive and self.FuelLeft > 0 then
                local forwardForce = self.InitialAngles:Forward() * 30000
                local upLift = self.UpLift * 2
                phys:ApplyForceCenter(forwardForce + upLift)
                self.FuelLeft = self.FuelLeft - 0.5
            end
            
            if self:GetVelocity():Length() > 100 then
                local vel = self:GetVelocity()
                local forward = vel:GetNormalized()
                local currentAngles = self:GetAngles()
                local targetAngles = forward:Angle()
                
                local pitchDiff = math.AngleDifference(currentAngles.pitch, targetAngles.pitch)
                local yawDiff = math.AngleDifference(currentAngles.yaw, targetAngles.yaw)
                
                local correction = Angle(0, 0, 0)
                correction.pitch = -pitchDiff * 0.1
                correction.yaw = -yawDiff * 0.1
                
                phys:AddAngleVelocity(Vector(
                    correction.pitch * 40,
                    correction.yaw * 40,
                    0
                ))
                
                local angVel = phys:GetAngleVelocity()
                phys:AddAngleVelocity(-angVel * 0.2)
            end
        end
    end
    
    self.BaseClass.Think(self)
    return true
end

function ENT:CheckSafetyDistance()
    if not self.StartPos then
        self.StartPos = self:GetPos()
        return false
    end
    
    local distance = self:GetPos():Distance(self.StartPos)
    if distance >= self.SafetyDistance and not self.SafetyArmed then
        self.SafetyArmed = true
        self:EmitSound("buttons/button16.wav", 50, 150, 0.3)
    end
    return self.SafetyArmed
end

function ENT:CreateHEATJet()
    if not SERVER then return end
    
    local Pos = self:GetPos()
    local Dir = self:GetVelocity():GetNormalized()
    local Att = self:GetOwner() or self
    
    if JMod and JMod.Sploom then
        JMod.Sploom(Att, Pos, 10)
    else
        util.BlastDamage(self, Att, Pos, 200, 100)
    end
    
    util.ScreenShake(Pos, 1000, 3, 2, 1500)
    self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
    
    local BlastDmg = DamageInfo()
    BlastDmg:SetDamageType(DMG_BLAST)
    BlastDmg:SetDamage(100)
    BlastDmg:SetAttacker(Att)
    BlastDmg:SetInflictor(self)
    BlastDmg:SetDamageForce(Dir * 100)
    util.BlastDamageInfo(BlastDmg, Pos + Dir * 30, 200)
    
    local BlastTr = util.QuickTrace(Pos + Dir * 20, Dir * 100, self)
    
    if BlastTr.Hit and (BlastTr.HitWorld or IsValid(BlastTr.Entity)) then
        if JMod and JMod.RicPenBullet then
            JMod.RicPenBullet(self, Pos, Dir, 5000, true, false, 1, .5)
        else
            local PierceDmg = DamageInfo()
            PierceDmg:SetAttacker(Att)
            PierceDmg:SetInflictor(self)
            PierceDmg:SetDamageType(DMG_SNIPER)
            PierceDmg:SetDamage(5000 * math.Rand(.8, 1.2))
            PierceDmg:SetReportedPosition(Pos)
            PierceDmg:SetDamagePosition(BlastTr.HitPos)
            PierceDmg:SetDamageForce(Dir * 20000 * math.Rand(.8, 1.2))
            BlastTr.Entity:TakeDamageInfo(PierceDmg)
        end
    end
    
    for k, ent in pairs(ents.FindInSphere(Pos, 200)) do
        if ent:GetClass() == "npc_helicopter" then
            ent:Fire("selfdestruct", "", math.Rand(0, 2))
        end
    end
    
    if JMod then
        JMod.WreckBuildings(self, Pos, 2)
        JMod.BlastDoors(self, Pos, 2)
    end
    
    timer.Simple(.2, function()
        local Tr = util.QuickTrace(Pos - Dir * 100, Dir * 300)
        if Tr.Hit then
            util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
        end
    end)
end

function ENT:CreateHEATExplosionEffects()
    if not SERVER then return end
    
    local Pos = self:GetPos()
    local Dir = self:GetVelocity():GetNormalized()
    local Ang = self:GetAngles()
    Ang:RotateAroundAxis(Ang:Forward(), -90)
    
    timer.Simple(.1, function()
        ParticleEffect("50lb_air", Pos + Dir * 130, Ang)
        ParticleEffect("50lb_air", Pos, Ang)
        ParticleEffect("50lb_air", Pos - Dir * 50, Ang)
    end)
end

local function IsSoftSurface(trace)
    local surfName = util.GetSurfacePropName(trace.SurfaceProps or 0):lower()
    if surfName:find("dirt") or surfName:find("mud") or surfName:find("grass") or 
       surfName:find("sand") or surfName:find("gravel") or surfName:find("snow") or
       surfName:find("flesh") or surfName:find("foliage") then
        return true
    end
    return false
end

function ENT:AboutToHit2(trace)
    if trace.Hit and not trace.HitSky then
        if not self.SafetyArmed then
            self:CheckSafetyDistance()
            return true
        end
        
        if IsSoftSurface(trace) then
            return true
        else
            self:Detonate()
            return true
        end
    end
    return false
end

function ENT:PhysicsCollide2(data, physobj)
    if self.Exploded then return end
    
    local hitEntity = data.HitEntity
    local hitPos = data.HitPos
    local hitNormal = data.HitNormal
    
    local tr = util.TraceHull({
        start = self:GetPos(),
        endpos = hitPos,
        mins = Vector(-2, -2, -2),
        maxs = Vector(2, 2, 2),
        filter = self
    })
    
    local trace = {
        Hit = tr.Hit,
        HitPos = tr.HitPos or hitPos,
        HitNormal = tr.HitNormal or hitNormal,
        Entity = tr.Entity or hitEntity,
        SurfaceProps = tr.SurfaceProps or 0
    }
    
    if trace.Hit and not trace.HitSky then
        if not self.SafetyArmed then
            self:CheckSafetyDistance()
            return true
        end
        
        if IsSoftSurface(trace) then
            return true
        else
            if data.Speed > 300 then
                self:Detonate()
                return true
            end
        end
    end
    
    return false
end

function ENT:Detonate()
    if self.Exploded then return end
    self.Exploded = true
    
    local Pos = self:GetPos()
    local Dir = self:GetVelocity():GetNormalized()
    local Att = self:GetOwner() or self
    
    if SERVER then
        self:StopSound("weapons/rpg/rocket1.wav")
        self:PlayDistantExplosionSounds()
        self.NoExplosionSound = true 
        
        self:CreateHEATJet()
        
        util.ScreenShake(Pos, 1000, 3, 2, 1500)
        self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
        self:CreateHEATExplosionEffects()
        
        local effectdata = EffectData()
        effectdata:SetOrigin(Pos)
        effectdata:SetNormal(Dir)
        effectdata:SetMagnitude(8)
        effectdata:SetScale(4)
        util.Effect("HelicopterMegaBomb", effectdata, true)
        
        effectdata = EffectData()
        effectdata:SetOrigin(Pos)
        effectdata:SetScale(3)
        util.Effect("Explosion", effectdata, true)
        
        self:Remove()
    end
end

if SERVER then
    util.AddNetworkString("rpg_explosion_sound")
end

function ENT:PlayDistantExplosionSounds()
    if SERVER then
        net.Start("rpg_explosion_sound")
        net.WriteVector(self:GetPos())
        net.WriteString("snd_jack_fragsplodeclose.ogg")
        net.WriteString("mortar_strike_far_dist_03.wav")
        net.Broadcast()
    end
end

if CLIENT then
    net.Receive("rpg_explosion_sound", function()
        local explosionPos = net.ReadVector()
        local closeSound = net.ReadString()
        local farSound = net.ReadString()
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local distance = ply:GetPos():Distance(explosionPos)
        
        if distance <= 1500 then
            EmitSound(closeSound, explosionPos, 0, CHAN_AUTO, 1, 120, 0, 100)
        else
            EmitSound(farSound, explosionPos, 0, CHAN_STATIC, 1, 80, 0, 90)
        end
    end)
end