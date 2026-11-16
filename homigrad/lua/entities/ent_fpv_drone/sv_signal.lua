FREQ_VIDEO = {
    { 5645, 1.00 },
    { 5732, 0.90 },
    { 5769, 0.85 },
    { 5800, 0.80 },
    { 5860, 0.65 },
    { 5905, 0.55 },
    { 5945, 0.45 },
    { 5880, 0.60 },
}

FREQ_CONTROL = {
    { 2400, 0.70 },
    { 2440, 0.95 },
    { 2480, 0.75 },
}

FREQ_CONTROL_900 = {
    { 902, 1.00 },
    { 915, 0.95 },
    { 928, 0.85 },
}

local VIDEO_BASE_RANGE = 3000
local CONTROL_BASE_RANGE = 4000
local VIDEO_LOSS_STRENGTH = 0.7
local CONTROL_LOSS_STRENGTH = 0.4
local SIGNAL_CHECK_INTERVAL = 0.2

local function freqPowerAt(freq, tbl)
    if not tbl or #tbl == 0 then return 0 end
    if freq <= tbl[1][1] then return tbl[1][2] end
    if freq >= tbl[#tbl][1] then return tbl[#tbl][2] end
    for i = 1, #tbl - 1 do
        local a, b = tbl[i], tbl[i + 1]
        if freq >= a[1] and freq <= b[1] then
            local t = (freq - a[1]) / (b[1] - a[1])
            return Lerp(t, a[2], b[2])
        end
    end
    return tbl[#tbl][2]
end

local function smoothSignal(current, target)
    if target < current then
        return Lerp(0.4, current, target)
    else
        return Lerp(0.15, current, target)
    end
end

local function computeObstructionLoss(origin, target, isVideo)
    local dir = (target - origin)
    local len = dir:Length()
    if len <= 0 then return 0 end
    dir:Normalize()
    local up = Vector(0, 0, 1)
    if math.abs(dir:Dot(up)) > 0.98 then up = Vector(1, 0, 0) end
    local right = dir:Cross(up):GetNormalized()
    local realUp = right:Cross(dir):GetNormalized()
    local offsets = {
        Vector(0, 0, 0),
        right * 0.5,
        right * -0.5,
        realUp * 0.5,
        realUp * -0.5,
    }
    local hits = 0
    for i = 1, #offsets do
        local tr = util.TraceLine({
            start = origin + offsets[i],
            endpos = target + offsets[i],
            mask = MASK_SOLID_BRUSHONLY,
        })
        if tr.Hit and not tr.HitSky then
            hits = hits + 1
        end
    end
    local lossFrac = hits / #offsets
    local strength = isVideo and VIDEO_LOSS_STRENGTH or CONTROL_LOSS_STRENGTH
    return lossFrac * strength
end

local function computeSignal(origin, target, isVideo, relay, freq, relayPilotPos)
    local power
    if isVideo then
        power = freqPowerAt(freq, FREQ_VIDEO)
    else
        if freq >= 900 and freq <= 930 then
            power = freqPowerAt(freq, FREQ_CONTROL_900)
        else
            power = freqPowerAt(freq, FREQ_CONTROL)
        end
    end
    local baseRange = isVideo and VIDEO_BASE_RANGE or CONTROL_BASE_RANGE
    local maxRange = baseRange * power
    if maxRange <= 0 then return 0 end

    local dist
    local obstructionOrigin, obstructionTarget
    if relay then
        local pilotPos = relayPilotPos or origin
        local d1 = pilotPos:Distance(relay)
        local d2 = relay:Distance(target)
        dist = (d1 + d2) / 39.37
        obstructionOrigin = pilotPos
        obstructionTarget = relay
    else
        dist = origin:Distance(target) / 39.37
        obstructionOrigin = origin
        obstructionTarget = target
    end

    local t = math.Clamp(dist / maxRange, 0, 1)
    local frac = 1 - t * t

    local lossFrac = computeObstructionLoss(obstructionOrigin, obstructionTarget, isVideo)
    frac = frac * (1 - lossFrac)

    if relay then
        frac = frac * 0.9
    end

    return math.Clamp(frac, 0, 1)
end

function ENT:GetVideoFrequency()
    return self.VideoFreq or 5800
end

function ENT:GetControlFrequency()
    return self.ControlFreq or 2440
end

function ENT:GetFrequency()
    return self:GetVideoFrequency()
end

function ENT:SetVideoFrequency(freq)
    freq = math.Clamp(freq, 5645, 5945)
    self.VideoFreq = freq
    self.Frequency = freq
    self.FreqDirty = true
    self:SetNWFloat("DroneVideoFreq", freq)
    self:SetNWFloat("DroneFrequency", freq)
    if IsValid(self.pilot) then
        net.Start("drone_frequency_update")
            net.WriteEntity(self)
            net.WriteBool(true)
            net.WriteFloat(freq)
        net.Send(self.pilot)
    end
end

function ENT:SetControlFrequency(freq)
    freq = math.Clamp(freq, 900, 2483)
    self.ControlFreq = freq
    self.FreqDirty = true
    self:SetNWFloat("DroneControlFreq", freq)
    if IsValid(self.pilot) then
        net.Start("drone_frequency_update")
            net.WriteEntity(self)
            net.WriteBool(false)
            net.WriteFloat(freq)
        net.Send(self.pilot)
    end
end

function ENT:SetFrequency(freq)
    self:SetVideoFrequency(freq)
end

function ENT:UpdateSignals()
    if not IsValid(self) then return end

    local pilot = self.pilot
    local dronePos = self:GetPos()

    local videoTarget = 0
    local controlTarget = 0

    if IsValid(pilot) then
        local pilotPos = pilot:GetPos()
        local relay = self.Relay

        videoTarget = computeSignal(pilotPos, dronePos, true, relay, self.VideoFreq or 5800, pilotPos)
        controlTarget = computeSignal(pilotPos, dronePos, false, relay, self.ControlFreq or 2440, pilotPos)
    end

    self.VideoTarget = videoTarget
    self.ControlTarget = controlTarget

    if self.VideoSignal == nil then self.VideoSignal = videoTarget end
    if self.ControlSignal == nil then self.ControlSignal = controlTarget end

    self.VideoSignal = smoothSignal(self.VideoSignal, videoTarget)
    self.ControlSignal = smoothSignal(self.ControlSignal, controlTarget)

    local videoInt = math.Round(math.Clamp(self.VideoSignal, 0, 1) * 100)
    local controlInt = math.Round(math.Clamp(self.ControlSignal, 0, 1) * 100)
    local minInt = math.min(videoInt, controlInt)

    self:SetNWInt("DroneVideoSignal", videoInt)
    self:SetNWInt("DroneControlSignal", controlInt)
    self:SetNWInt("DroneSignal", minInt)

    if self.ControlSignal <= 0.01 and self.armed and not self.disabled then
        if IsValid(pilot) then
            pilot:ChatPrint("SIGNAL LOST - Drone too far or behind obstacle!")
            pilot:SetNWEntity("ControlledDrone", NULL)
            net.Start("drone_controller_release_control")
            net.Send(pilot)
        end

        self.disabled = true
        self.armed = false

        if self.motorSound then
            self.motorSound:Stop()
        end

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableGravity(true)
            phys:SetVelocity(Vector(0, 0, 0))
            phys:SetAngleVelocity(Vector(0, 0, 0))
        end

        self.Throttle = 0
        self.Roll = 0
        self.Pitch = 0
        self.Yaw = 0
        self.pilot = NULL
    end
end