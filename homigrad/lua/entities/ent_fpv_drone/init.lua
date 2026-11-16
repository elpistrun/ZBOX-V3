AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_signal.lua")

if SERVER then
    util.AddNetworkString("fpv_control")
    util.AddNetworkString("fpv_explosion")
    util.AddNetworkString("drone_controller_release_control")
    util.AddNetworkString("drone_status_update")
    util.AddNetworkString("drone_controller_release_control_cmd")
    util.AddNetworkString("drone_controller_connect")
    util.AddNetworkString("drone_controller_take_control")
    util.AddNetworkString("drone_controller_connected")
    util.AddNetworkString("drone_destroyed")
    util.AddNetworkString("drone_set_frequency")
    util.AddNetworkString("drone_frequency_update")

    net.Receive("fpv_control", function(len, ply)
        local drone = net.ReadEntity()
        if not IsValid(drone) then return end
        if drone.pilot ~= ply then return end
        if drone.IsDestroyed then return end
        if drone.disabled then return end

        drone.Roll = net.ReadFloat()
        drone.Pitch = net.ReadFloat()
        drone.Yaw = net.ReadFloat()
        drone.Throttle = math.Clamp(net.ReadFloat(), 0, 50)

        if drone.Throttle > 5 and not drone.armed and not drone.disabled then
            drone.armed = true
            if drone.motorSound then
                drone.motorSound:Play()
            end
            if drone.assignSound then
                drone.assignSound:Play()
            end
        end
    end)

    net.Receive("drone_controller_connect", function(len, ply)
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_drone_controller" then return end

        local droneIndex = net.ReadInt(32)
        local drone = Entity(droneIndex)

        if not IsValid(drone) or drone:GetClass() ~= "ent_fpv_drone" then
            ply:ChatPrint("Drone not found")
            return
        end

        local dist = ply:GetPos():Distance(drone:GetPos())
        if dist > 400 then
            ply:ChatPrint("Drone is too far! Get within 10 meters to connect.")
            return
        end

        if IsValid(drone.pilot) then
            ply:ChatPrint("Drone is in use")
            return
        end

        wep.CurrentDrone = drone

        net.Start("drone_controller_connected")
            net.WriteInt(drone:EntIndex(), 32)
        net.Send(ply)

        ply:ChatPrint("Connected to drone #" .. drone:EntIndex())
    end)

    net.Receive("drone_controller_release_control_cmd", function(len, ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" and wep.InControl then
            wep:ReleaseControl()
            ply:ChatPrint("Control released")
        end
    end)

    net.Receive("drone_set_frequency", function(len, ply)
    local drone = net.ReadEntity()
    local isVideo = net.ReadBool()
    local freq = net.ReadFloat()

    print("[drone_set_frequency] received | ply:", ply, "| drone:", drone, "| isVideo:", isVideo, "| freq:", freq)

    if not IsValid(drone) then
        print("[drone_set_frequency] drone invalid, abort")
        return
    end
    if drone:GetClass() ~= "ent_fpv_drone" then
        print("[drone_set_frequency] wrong class:", drone:GetClass())
        return
    end

    local pilot = drone.pilot
    if IsValid(pilot) and pilot ~= ply then
        print("[drone_set_frequency] drone is in use by another player")
        return
    end

    if isVideo then
        if freq < 5645 or freq > 5945 then return end
        drone:SetVideoFrequency(freq)
        ply:ChatPrint("Drone video frequency set to " .. string.format("%.0f", freq) .. " MHz")
    else
        if freq < 900 or freq > 2483 then return end
        drone:SetControlFrequency(freq)
        ply:ChatPrint("Drone control frequency set to " .. string.format("%.0f", freq) .. " MHz")
    end

    net.Start("drone_frequency_update")
        net.WriteEntity(drone)
        net.WriteBool(isVideo)
        net.WriteFloat(freq)
    net.Broadcast()
end)
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.VideoSignal = 1.0
    self.ControlSignal = 1.0
    self.VideoTarget = 1.0
    self.ControlTarget = 1.0
    self.SignalCheckAt = 0

    self.VideoFreq = 5800
    self.ControlFreq = 2440
    self.FreqDirty = false
    self.Frequency = 5800

    self:SetNWFloat("DroneSpeed", 0)
    self:SetNWFloat("DroneHeight", 0)
    self:SetNWFloat("DroneBattery", 100)
    self:SetNWInt("DroneSignal", 100)
    self:SetNWInt("DroneVideoSignal", 100)
    self:SetNWInt("DroneControlSignal", 100)
    self:SetNWFloat("DroneVideoFreq", self.VideoFreq)
    self:SetNWFloat("DroneControlFreq", self.ControlFreq)
    self:SetNWFloat("DroneFrequency", self.VideoFreq)
    self:SetNWBool("DroneDisabled", false)
    self:SetNWEntity("DronePilot", NULL)

    self.Battery = 100
    self.disabled = false
    self.IsDestroyed = false
    self.Throttle = 0
    self.Roll = 0
    self.Pitch = 0
    self.Yaw = 0
    self.pilot = NULL
    self.armed = false

    self.crashRollActive = false
    self.explodeTimer = nil
    self.removeTimer = nil

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(10)
        phys:EnableGravity(true)
        phys:EnableDrag(true)
        phys:SetAngleDragCoefficient(4)
        phys:SetDamping(0.1, 3)
    end

    self.motorSound = CreateSound(self, "kamikaze/fpv_idlesound.ogg")
    self.motorSound:ChangePitch(70)
    self.motorSound:ChangeVolume(0.6)
    self.motorSound:SetSoundLevel(85)

    self.startSound = CreateSound(self, "fpv/startup.wav")
    self.assignSound = CreateSound(self, "fpv/assigned.wav")

    self:StartMotionController()
    self:NextThink(CurTime())
end

function ENT:GetDriver()
    return self.pilot
end

function ENT:SetDriver(ply)
    if IsValid(self.pilot) and self.pilot ~= ply then
        net.Start("drone_controller_release_control")
        net.Send(self.pilot)
    end

    self.pilot = ply

    if IsValid(ply) then
        ply:SetNWEntity("ControlledDrone", self)
        self:SetNWEntity("DronePilot", ply)
        self.startSound:Play()

        net.Start("drone_frequency_update")
            net.WriteEntity(self)
            net.WriteBool(true)
            net.WriteFloat(self.VideoFreq)
        net.Send(ply)

        net.Start("drone_frequency_update")
            net.WriteEntity(self)
            net.WriteBool(false)
            net.WriteFloat(self.ControlFreq)
        net.Send(ply)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    else
        self.Throttle = 0
        self.Roll = 0
        self.Pitch = 0
        self.Yaw = 0
        self.armed = false
        self:SetNWEntity("DronePilot", NULL)
        if self.motorSound then
            self.motorSound:Stop()
        end
    end
end

function ENT:UpdateNWData()
    if not IsValid(self) then return end

    local speed = self:GetCurrentSpeed() or 0
    local height = self:GetCurrentHeight() or 0
    local battery = self:GetBatteryPercent() or 100
    local video = self:GetNWInt("DroneVideoSignal", 100)
    local control = self:GetNWInt("DroneControlSignal", 100)
    local signal = math.min(video, control)

    self:SetNWFloat("DroneSpeed", speed)
    self:SetNWFloat("DroneHeight", height)
    self:SetNWFloat("DroneBattery", battery)
    self:SetNWBool("DroneDisabled", self.disabled or false)

    if self.pilot == nil then return end

    net.Start("drone_status_update")
        net.WriteEntity(self)
        net.WriteFloat(battery)
        net.WriteInt(signal, 8)
        net.WriteBool(self.disabled or false)
        net.WriteBool(IsValid(self.pilot))
    net.Broadcast()
end

function ENT:GetBatteryPercent()
    if self.Throttle == nil then self.Throttle = 0 end
    if self.Battery == nil then self.Battery = 100 end

    if self.armed and not self.disabled then
        local drainRate = 0.0003
        local throttleFactor = (self.Throttle / 50) ^ 1.8
        drainRate = drainRate + 0.005 * throttleFactor
        local maneuvering = math.abs(self.Roll) + math.abs(self.Pitch) + math.abs(self.Yaw)
        drainRate = drainRate + maneuvering * 0.0008

        self.Battery = self.Battery - drainRate
        if self.Battery < 0 then self.Battery = 0 end
    end

    self:SetNWFloat("DroneBattery", math.Round(self.Battery))
    return math.Round(self.Battery)
end

function ENT:GetCurrentHeight()
    local tr = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() - Vector(0, 0, 5000),
        mask = MASK_SOLID_BRUSHONLY
    })
    return math.Round(tr.HitPos:Distance(self:GetPos()) / 39.37)
end

function ENT:GetCurrentSpeed()
    local vel = self:GetVelocity()
    return math.Round(vel:Length() * 0.068)
end

function ENT:StartCrashRoll()
    if self.crashRollActive then return end
    if self.IsDestroyed then return end
    if not self.disabled then return end

    self.crashRollActive = true

    local crashChance = math.random(1, 100)
    if crashChance <= 60 then
        timer.Simple(0.3, function()
            if IsValid(self) and not self.IsDestroyed then
                self:TriggerExplosion()
            end
        end)
    else
        local finalChance = math.random(1, 100)
        if finalChance <= 50 then
            local delay = math.random(1, 20)
            self.explodeTimer = timer.Simple(delay, function()
                if IsValid(self) and not self.IsDestroyed then
                    self:TriggerExplosion()
                end
            end)
        else
            self.removeTimer = timer.Simple(20, function()
                if IsValid(self) and not self.IsDestroyed then
                    self:Remove()
                end
            end)
        end
    end
end

function ENT:ClearTimers()
    if self.explodeTimer then
        timer.Remove(self.explodeTimer)
        self.explodeTimer = nil
    end
    if self.removeTimer then
        timer.Remove(self.removeTimer)
        self.removeTimer = nil
    end
end

function ENT:FragSplosion(pos, fragNum, fragDmg, fragMaxDist, attacker)
    if not attacker then attacker = self.pilot or self end

    for i = 1, fragNum do
        local dir = VectorRand()
        dir:Normalize()

        local tr = util.TraceLine({
            start = pos,
            endpos = pos + dir * fragMaxDist,
            filter = {self, self.pilot}
        })

        if tr.Hit and IsValid(tr.Entity) then
            local dmg = DamageInfo()
            dmg:SetDamage(fragDmg * (1 - tr.Fraction) + 20)
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetAttacker(attacker)
            dmg:SetInflictor(self)
            tr.Entity:TakeDamageInfo(dmg)
        end
    end
end

function ENT:TriggerExplosion()
    if self.IsDestroyed then return end
    self.IsDestroyed = true

    self:ClearTimers()

    net.Start("drone_destroyed")
    net.Broadcast()

    if IsValid(self.pilot) then
        net.Start("drone_controller_release_control")
        net.Send(self.pilot)
    end

    local pos = self:GetPos()

    net.Start("fpv_explosion")
        net.WriteVector(pos)
    net.Broadcast()

    self:EmitSound("snd_jack_fragsplodeclose.ogg", 120, 100)

    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetScale(1.5)
    effect:SetRadius(3)
    effect:SetNormal(vector_up)
    util.Effect("eff_jack_minesplode", effect)

    local Ang = self:GetAngles()
    Ang:RotateAroundAxis(Ang:Forward(), -90)

    timer.Simple(0.05, function()
        if IsValid(self) then
            ParticleEffect("50lb_air", pos - self:GetRight() * 20, Ang)
            ParticleEffect("50lb_air", pos - self:GetRight() * 50, Ang)
            ParticleEffect("50lb_air", pos - self:GetRight() * 80, Ang)
        end
    end)

    util.ScreenShake(pos, 35, 35, 2, 2000)

    local groundTr = util:QuickTrace(pos + Vector(0, 0, 5), Vector(0, 0, -15), self)

    local attacker = self.pilot
    if not IsValid(attacker) then
        attacker = self
    end

    if groundTr.Hit then
        self:FragSplosion(pos + Vector(0, 0, 10), 500, 35, 2400, attacker)
        util.BlastDamage(self, attacker, pos, 320, 180)
    else
        self:FragSplosion(pos, 590, 25, 2400, attacker)
        util.BlastDamage(self, attacker, pos, 500, 200)
    end

    timer.Simple(0.2, function()
        if IsValid(self) then
            local Tr = util:QuickTrace(pos - self:GetRight() * 100, self:GetRight() * 300)
            if Tr.Hit then
                util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
            end
        end
    end)

    self:Remove()
end

function ENT:PhysicsSimulate(phys, delta)
    if CLIENT then return end
    if not IsValid(self.pilot) then return end
    if self.IsDestroyed then return end
    if self.disabled then return end

    if self.ControlSignal and self.ControlSignal <= 0.01 then
        return SIM_GLOBAL_ACCELERATION
    end

    delta = math.min(delta, 0.033)

    local up = self:GetUp()
    local right = self:GetRight()
    local forward = self:GetForward()

    if self.armed then
        local thrust = self.Throttle * 3.61605
        if thrust > 0 then
            phys:ApplyForceCenter(up * thrust)
        end

        local rollForce = self.Roll * 3.0
        local pitchForce = self.Pitch * 4
        local yawForce = self.Yaw * 2.7

        phys:ApplyTorqueCenter(right * rollForce)
        phys:ApplyTorqueCenter(forward * pitchForce)
        phys:ApplyTorqueCenter(up * yawForce)

        if self.motorSound then
            local freq = self:GetVideoFrequency()
            local pitchOffset = (freq - 5800) * 0.02
            local pitch = 60 + (self.Throttle / 50) * 40 + pitchOffset
            self.motorSound:ChangePitch(pitch, 0.1)
        end
    end

    return SIM_GLOBAL_ACCELERATION
end

function ENT:Think()
    if SERVER then
        self:SetNWFloat("DroneBattery", self:GetBatteryPercent())

        if CurTime() >= self.SignalCheckAt then
            self.SignalCheckAt = CurTime() + 0.2
            self:UpdateSignals()
        end

        self:UpdateNWData()

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            if IsValid(self.pilot) and self.armed then
                phys:Wake()
            end
        end
    end
    self:NextThink(CurTime() + 0.033)
    return true
end

function ENT:OnTakeDamage(dmg)
    if self.IsDestroyed then return end

    if self.disabled or self.crashRollActive then
        self:ClearTimers()
        self:TriggerExplosion()
        return
    end

    local explodeChance = math.random(1, 100)
    if explodeChance <= 70 then
        self:TriggerExplosion()
    else
        self.disabled = true
        self.armed = false

        if self.motorSound then
            self.motorSound:Stop()
        end

        if IsValid(self.pilot) then
            self.pilot:SetNWEntity("ControlledDrone", NULL)
            net.Start("drone_controller_release_control")
            net.Send(self.pilot)
            self.pilot = NULL
        end

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableGravity(true)
            phys:SetVelocity(Vector(0, 0, 0))
            phys:SetAngleVelocity(Vector(0, 0, 0))
        end
    end
end

function ENT:PhysicsCollide(data, phys)
    if self.IsDestroyed then return end

    if self.disabled and not self.crashRollActive then
        self:StartCrashRoll()
        return
    end

    if not self.disabled and not self.IsDestroyed then
        local speed = data.Speed

        if speed > 200 then
            self:TriggerExplosion()
        elseif speed > 100 then
            if math.random(1, 100) <= 80 then
                self:TriggerExplosion()
            end
        end
    end
end

function ENT:OnRemove()
    self:ClearTimers()

    if self.motorSound then
        self.motorSound:Stop()
    end
    if self.startSound then
        self.startSound:Stop()
    end
    if self.assignSound then
        self.assignSound:Stop()
    end
    if IsValid(self.pilot) then
        self.pilot:SetNWEntity("ControlledDrone", NULL)
    end
end

if CLIENT then
    function ENT:GetCameraPos()
        return self:GetPos() + self:GetForward() * 5 + self:GetUp() * 4
    end

    function ENT:GetCameraAng()
        return self:GetAngles()
    end

    function ENT:Draw()
        self:DrawModel()
    end
end