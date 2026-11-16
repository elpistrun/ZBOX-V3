if SERVER then
    AddCSLuaFile()
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Drone Detector"
SWEP.Instructions = "Scan for drones in the area. LMB - change mode. R - turn on/off. RMB - raise hand."
SWEP.Category = "Weapons - Drones"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.IdleHoldType = "normal"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

if CLIENT then
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
SWEP.offsetVec = Vector(-20, 10, -33.5)
SWEP.offsetAng = Angle(145, 175, 182)

-- Режимы: дальность / чувствительность / точность
SWEP.Modes = {
    [1] = { name = "FS", range = 850, sensitivity = 0.3, accuracy = 0.3 },
    [2] = { name = "MS", range = 500, sensitivity = 0.6, accuracy = 0.6 },
    [3] = { name = "CS", range = 250, sensitivity = 1.0, accuracy = 1.0 },
}
SWEP.CurrentMode = 1

-- Сканируемые каналы (полные диапазоны реального дрона)
SWEP.VideoFreqs   = { 5645, 5732, 5769, 5800, 5860, 5905, 5945, 5880 }
SWEP.ControlFreqs = { 2400, 2440, 2480 }

-- Допуск поиска по частоте (МГц) — чтобы дрон на 5810 тоже находился каналом 5800
SWEP.FreqTolerance = 8

SWEP.ScreenPosOffset = Vector(4.65, -1.889, 2.69)
SWEP.ScreenAngleOffset = Angle(30, -3.7, 94.3)

-- Плавное поднятие руки
SWEP.HandRaiseLerp = 0

if CLIENT then
    surface.CreateFont("Detector_Fixed-Font",        { font = "Ari-W9500", size = 44, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-SmallFont",   { font = "Ari-W9500", size = 28, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-TinyFont",    { font = "Ari-W9500", size = 28, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-MediumFont",  { font = "Ari-W9500", size = 28, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-MicroFont",   { font = "Ari-W9500", size = 28, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-MiniFont",    { font = "Ari-W9500", size = 28, weight = 600, outline = false })
    surface.CreateFont("Detector_Fixed-DistFont",    { font = "Ari-W9500", size = 20, weight = 600, outline = false })

    if not LerpVector then
        function LerpVector(t, a, b)
            return Vector(Lerp(t, a.x, b.x), Lerp(t, a.y, b.y), Lerp(t, a.z, b.z))
        end
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool",   0, "IsOn")
    self:NetworkVar("Int",    0, "DetectedCount")
    self:NetworkVar("String", 0, "DetectedInfo")
    self:NetworkVar("Float",  0, "CurrentFreq")
    self:NetworkVar("String", 1, "FreqSignals")
    self:NetworkVar("Int",    1, "Mode")
end

function SWEP:Initialize()
    self:SetHold(self.HoldType)
    self.HandRaiseLerp = 0
    self._wasStanding = false
    if SERVER then
        self.IsOn = false
        self.CurrentMode = 1
        self.LastScan = 0
        self.LastBeep = 0
    end
end

if SERVER then
    function SWEP:Deploy()
        self:SetIsOn(self.IsOn or false)
        self:SetMode(self.CurrentMode or 1)
        self:SetDetectedCount(0)
        self:SetDetectedInfo("OFF")
        self:SetCurrentFreq(0)
        self:SetFreqSignals("")
    end

    function SWEP:Holster()
        return true
    end

    function SWEP:OnRemove()
        if self.IsOn then
            self:ToggleOff()
        end
    end

    function SWEP:ToggleOn()
        self.IsOn = true
        self:SetIsOn(true)
        self.CurrentFreqIndex = 1
        if IsValid(self:GetOwner()) then self:GetOwner():ChatPrint("Drone Detector ON") end
    end

    function SWEP:ToggleOff()
        self.IsOn = false
        self:SetIsOn(false)
        self:SetDetectedCount(0)
        self:SetDetectedInfo("OFF")
        self:SetCurrentFreq(0)
        self:SetFreqSignals("")
        if IsValid(self:GetOwner()) then self:GetOwner():ChatPrint("Drone Detector OFF") end
    end

    function SWEP:CycleMode()
        local maxMode = #self.Modes
        self.CurrentMode = self.CurrentMode + 1
        if self.CurrentMode > maxMode then self.CurrentMode = 1 end
        self:SetMode(self.CurrentMode)
        if IsValid(self:GetOwner()) then
            self:GetOwner():ChatPrint("Mode: " .. self.Modes[self.CurrentMode].name)
        end
    end

    local function channelStrength(droneFreq, scanFreq, tolerance)
        local d = math.abs(droneFreq - scanFreq)
        if d > tolerance then return 0 end
        return 1 - (d / tolerance) * 0.5
    end

    function SWEP:PerformScan()
        if not self.IsOn then return end

        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        local plyPos = ply:GetPos()
        local currentMode = self.Modes[self:GetMode() or 1]
        local range = currentMode.range * 39.37
        local sensitivity = currentMode.sensitivity
        local accuracy = currentMode.accuracy or 0.5
        local tol = self.FreqTolerance

        local videoSignals = {}
        for _, f in ipairs(self.VideoFreqs) do videoSignals[f] = 0 end
        local controlSignals = {}
        for _, f in ipairs(self.ControlFreqs) do controlSignals[f] = 0 end

        local detected = {}
        local nearestDrone = nil
        local nearestDist = math.huge
        local nearestSignal = 0

        for _, drone in ipairs(ents.FindByClass("ent_fpv_drone")) do
            if not IsValid(drone) or drone.IsDestroyed then continue end

            local dist = plyPos:Distance(drone:GetPos())
            if dist > range then continue end

            local vidFreq = drone:GetNWFloat("DroneVideoFreq", drone:GetNWFloat("DroneFrequency", 5800))
            local ctlFreq = drone:GetNWFloat("DroneControlFreq", 2440)

            local distanceFactor = 1 - (dist / range)
            local baseSignal = 100 * distanceFactor * sensitivity
            baseSignal = math.Clamp(baseSignal, 0, 100)

            local bestVidStrength = 0
            local bestVidChan = nil
            for _, cf in ipairs(self.VideoFreqs) do
                local s = channelStrength(vidFreq, cf, tol)
                if s > bestVidStrength then bestVidStrength = s; bestVidChan = cf end
            end
            local bestCtlStrength = 0
            local bestCtlChan = nil
            for _, cf in ipairs(self.ControlFreqs) do
                local s = channelStrength(ctlFreq, cf, tol)
                if s > bestCtlStrength then bestCtlStrength = s; bestCtlChan = cf end
            end

            if bestVidStrength <= 0 and bestCtlStrength <= 0 then
                continue
            end

            local noisyBase = baseSignal * (0.9 + math.random() * 0.2)

            if bestVidStrength > 0 then
                local s = noisyBase * bestVidStrength
                if s > (videoSignals[bestVidChan] or 0) then
                    videoSignals[bestVidChan] = s
                end
            end
            if bestCtlStrength > 0 then
                local s = noisyBase * bestCtlStrength
                if s > (controlSignals[bestCtlChan] or 0) then
                    controlSignals[bestCtlChan] = s
                end
            end

            local overallSignal = math.max(noisyBase * bestVidStrength, noisyBase * bestCtlStrength)
            if overallSignal > 5 then
                local actualDist = dist / 39.37
                local error = (1 - accuracy) * 30
                local randomError = math.random(-error, error)
                local displayedDist = math.Round(math.max(0, actualDist + randomError), 1)

                table.insert(detected, {
                    id = drone:EntIndex(),
                    vidFreq = vidFreq,
                    ctlFreq = ctlFreq,
                    dist = displayedDist,
                    actualDist = actualDist,
                    signal = math.Round(overallSignal),
                    drone = drone
                })
            end

            if dist < nearestDist then
                nearestDist = dist
                nearestDrone = drone
                nearestSignal = overallSignal
            end
        end

        table.sort(detected, function(a, b) return a.dist < b.dist end)

        self.DetectedDrones = detected
        self:SetDetectedCount(#detected)

        local info = "None"
        if #detected > 0 then
            local n = detected[1]
            local distText = n.dist .. "m"
            if accuracy < 1.0 then distText = "~" .. distText end
            info = string.format("VTX %.0f / RX %.0f  %s", n.vidFreq, n.ctlFreq, distText)
        end
        self:SetDetectedInfo(info)

        local vidParts, ctlParts = {}, {}
        for _, f in ipairs(self.VideoFreqs) do
            table.insert(vidParts, string.format("%.0f|%d", f, math.Round(videoSignals[f] or 0)))
        end
        for _, f in ipairs(self.ControlFreqs) do
            table.insert(ctlParts, string.format("%.0f|%d", f, math.Round(controlSignals[f] or 0)))
        end
        self:SetFreqSignals("v:" .. table.concat(vidParts, ",") .. ";c:" .. table.concat(ctlParts, ","))

        if nearestDrone and nearestSignal > 5 then
            local distFactor = math.Clamp(nearestSignal / 100, 0.1, 1)
            local beepInterval = 0.05 + (1 - distFactor) * 1
            local volume = 45 + distFactor * 30
            local pitch = 55 + distFactor * 75

            if not self.LastBeep or CurTime() - self.LastBeep > beepInterval then
                self.LastBeep = CurTime()
                self:EmitSound("kamikaze/pisk.MP3", volume, pitch)
            end
        else
            self.LastBeep = 0
        end
    end
end

function SWEP:SetHold(value)
    self:SetWeaponHoldType(value)
    self:SetHoldType(value)
    self.holdtype = value
end

function SWEP:PrimaryAttack()
    if SERVER then return end
    local tbl = {}
    for i = 1, #self.Modes do
        local mode = self.Modes[i]
        tbl[#tbl + 1] = {
            function()
                RunConsoleCommand("detector_setmode", i)
                return -1
            end,
            mode.name .. " (" .. mode.range .. "m)"
        }
    end
    hg.CreateRadialMenu(tbl)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    if SERVER then
        if not self.turnOnCD or self.turnOnCD < CurTime() then
            self.turnOnCD = CurTime() + 0.5
            if self.IsOn then
                self:ToggleOff()
            else
                self:ToggleOn()
            end
            self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        end
    end
end

if SERVER then
    concommand.Add("detector_setmode", function(ply, cmd, args)
        if not args[1] then return end
        local mode = tonumber(args[1])
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_detector" then
            if mode >= 1 and mode <= #wep.Modes then
                wep.CurrentMode = mode
                wep:SetMode(mode)
                ply:ChatPrint("Mode: " .. wep.Modes[mode].name)
            end
        end
    end)
end

hook.Add("Think", "DroneDetectorGlobalScan", function()
    if not SERVER then return end
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        local wep = ply:GetWeapon("weapon_drone_detector")
        if IsValid(wep) and wep:GetIsOn() then
            if CurTime() - wep.LastScan > 0.3 then
                wep.LastScan = CurTime()
                wep:PerformScan()
            end
        end
    end
end)

function SWEP:DrawWorldModel2()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner:GetActiveWeapon() ~= self then return end

    self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
    local WorldModel = self.model
    local character = hg.GetCurrentCharacter(owner)

    WorldModel:SetNoDraw(true)
    WorldModel:SetModelScale(self.ModelScale or 1)

    if IsValid(character) then
        local offsetVec = self.offsetVec
        local offsetAng = self.offsetAng
        local boneid = character:LookupBone("ValveBiped.Bip01_L_Hand")
        if not boneid then return end

        local matrix = character:GetBoneMatrix(boneid)
        if not matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
        WorldModel:SetPos(newPos)
        WorldModel:SetAngles(newAng)
        WorldModel:SetupBones()
        WorldModel:DrawModel()

        newPos, newAng = LocalToWorld(self.ScreenPosOffset, self.ScreenAngleOffset, matrix:GetTranslation(), matrix:GetAngles())

        local screenScale = (ScrW() / 1920) * 0.005
        cam.Start3D2D(newPos, newAng, screenScale)
            local width, height = 290, 250
            local isOn = self:GetIsOn()
            local mode = self:GetMode() or 1
            local modeName = self.Modes[mode] and self.Modes[mode].name or "SCAN"
            local detectedCount = self:GetDetectedCount() or 0
            local detectedInfo = self:GetDetectedInfo() or "None"
            local freqSignals = self:GetFreqSignals() or ""

            local vtxVal, rxVal, distText = "--", "--", ""
            if detectedCount > 0 and detectedInfo and detectedInfo ~= "None" and detectedInfo ~= "OFF" then
                local vtx, rx, dist = detectedInfo:match("VTX%s+([%d%.]+)%s*/%s*RX%s+([%d%.]+)%s+(.+)$")
                if vtx then vtxVal = string.format("%.0f", tonumber(vtx)) end
                if rx then rxVal = string.format("%.0f", tonumber(rx)) end
                if dist then distText = dist end
            end

            draw.RoundedBox(8, -width / 2.1, -height / 1.75, width, height, isOn and Color(0, 39, 0) or Color(0, 15, 0))

            if isOn then
                draw.SimpleText("VTX", "Detector_Fixed-MicroFont", -width / 4 + 160, -height / 2 + 57, Color(0, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(vtxVal, "Detector_Fixed-MicroFont", -width / 4 + 157, -height / 2 + 77, Color(0, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                draw.SimpleText(modeName, "Detector_Fixed-TinyFont", 129, -height / 8 + 30, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                draw.SimpleText("RX", "Detector_Fixed-MicroFont", -width / 4 + 165, -height / 8 + 85, Color(0, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(rxVal, "Detector_Fixed-MicroFont", -width / 4 + 155, -height / 8 + 105, Color(0, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                local vidData, ctlData = {}, {}
                local vPart, cPart = freqSignals:match("^v:([^;]*);c:(.*)$")
                local function parsePart(str)
                    local out = {}
                    if not str or str == "" then return out end
                    for _, pair in ipairs(string.Split(str, ",")) do
                        local f, s = pair:match("([%d%.]+)|(%d+)")
                        if f and s then table.insert(out, { freq = tonumber(f), signal = tonumber(s) }) end
                    end
                    return out
                end
                vidData = parsePart(vPart)
                ctlData = parsePart(cPart)

                local function drawRow(data, y, freqColor)
                    local barLength = math.Clamp(data.signal / 100 * 80, 0, 80)
                    local barColor = data.signal > 60 and Color(0, 255, 0)
                                  or (data.signal > 30 and Color(255, 200, 0) or Color(50, 50, 50))
                    draw.SimpleText(string.format("%.0f", data.freq), "Detector_Fixed-MediumFont", -125, y, freqColor or Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(2, -65, y - 8, 80, 16, Color(30, 30, 30))
                    if data.signal > 5 then
                        draw.RoundedBox(2, -65, y - 8, barLength, 16, barColor)
                    end
                    draw.SimpleText(data.signal .. "%", "Detector_Fixed-MicroFont", 19, y, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local y = -height / 1.8 + 12
                for _, d in ipairs(vidData) do drawRow(d, y, Color(0, 255, 100)); y = y + 21 end

                y = y + 4
                for _, d in ipairs(ctlData) do drawRow(d, y, Color(0, 200, 255)); y = y + 21 end

                if detectedCount > 0 then
                    local boxX = width / 2 - 60
                    local boxY = -height / 3 + 70
                    local boxSize = 26
                    draw.RoundedBox(3, boxX, boxY, boxSize, boxSize, Color(200, 20, 20, 230))
                    draw.SimpleText(detectedCount, "Detector_Fixed-MediumFont", boxX + boxSize / 2.5, boxY + boxSize / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                if detectedCount > 0 and distText ~= "" then
                    draw.SimpleText(distText, "Detector_Fixed-DistFont", -width / 5 + 135, height / 6 - 165, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            else
                draw.SimpleText("DRONE DETECTOR", "Detector_Fixed-SmallFont", 0, -90, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("OFF", "Detector_Fixed-TinyFont", 0, -20, Color(150, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Press R to turn on", "Detector_Fixed-MiniFont", 0, 45, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()
    else
        WorldModel:SetPos(self:GetPos())
        WorldModel:SetAngles(self:GetAngles())
        WorldModel:DrawModel()
    end
end

function SWEP:BoneSet(lookup_name, vec, ang)
    local owner = self:GetOwner()
    if IsValid(owner) and !owner:IsPlayer() then return end
    hg.bone.Set(owner, lookup_name, vec, ang, "dronedetector", 0.01)
end

local handAng1      = Angle(-20, -15, 20)
local handAng2      = Angle(-2, -95, -80)
local handAng1Raised = Angle(-50, -60, 30)
local handAng2Raised = Angle(0, -97, -97)

function SWEP:Step()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local active = owner:KeyDown(IN_ATTACK) and self:GetIsOn()
    local posed = owner:KeyDown(IN_ATTACK2)

    if active then
        self:SetHold(self.HoldType)
    elseif self:GetHoldType() ~= self.IdleHoldType then
        self:SetHold(self.IdleHoldType)
    end

    local standing = owner:OnGround()
        and owner:GetVelocity():LengthSqr() <= 1000
        and not owner:IsTyping()
        and not owner:IsFlagSet(FL_ANIMDUCKING)

    local a1, a2
    if standing then
        local wantRaise = posed and 1 or 0
        self.HandRaiseLerp = math.Approach(self.HandRaiseLerp or 0, wantRaise, FrameTime() / 0.2)
        local t = self.HandRaiseLerp or 0
        a1 = LerpAngle(t, handAng1, handAng1Raised)
        a2 = LerpAngle(t, handAng2, handAng2Raised)
    else
        self.HandRaiseLerp = math.Approach(self.HandRaiseLerp or 0, 0, FrameTime() / 0.2)
        a1, a2 = angle_zero, angle_zero
    end

    self:BoneSet("l_upperarm", vector_origin, a1)
    self:BoneSet("l_forearm",  vector_origin, a2)
    self:BoneSet("r_upperarm", vector_origin, angle_zero)
    self:BoneSet("r_forearm",  vector_origin, angle_zero)

        -- Пальцы (всегда)
    self:BoneSet("ValveBiped.Bip01_L_Finger0",  vector_origin, Angle(0, -35, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger01", vector_origin, Angle(0, 0, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger02", vector_origin, Angle(0, 0, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger1",  vector_origin, Angle(0, -20, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger11", vector_origin, Angle(-35, -70, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger12", vector_origin, Angle(0, -60, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger2",  vector_origin, Angle(-5, -35, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger21", vector_origin, Angle(-10, -77, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger22", vector_origin, Angle(0, -44, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger3",  vector_origin, Angle(5, -50, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger31", vector_origin, Angle(-11, -75, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger32", vector_origin, Angle(0, -50, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger4",  vector_origin, Angle(25, -65, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger41", vector_origin, Angle(0, -65, 0))
    self:BoneSet("ValveBiped.Bip01_L_Finger42", vector_origin, Angle(0, -55, 0))
end