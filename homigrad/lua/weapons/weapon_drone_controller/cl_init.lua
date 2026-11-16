include("shared.lua")

if CLIENT then

    SWEP.SelectedDroneEnt = nil
    SWEP.MenuOpen = false
    SWEP.Menu = nil
    SWEP.ControlActive = false
    SWEP.CurrentThrottle = 0
    SWEP.LastThrottleTime = 0
    SWEP.RenderTargets = {}
    SWEP.FixedAngles = Angle(0, 0, 0)
    SWEP.AnglesLocked = false

    SWEP.SmoothRoll = 0
    SWEP.SmoothPitch = 0
    SWEP.SmoothYaw = 0
    SWEP.SmoothThrottle = 0

    SWEP.LastFPSUpdate = 0
    SWEP.CurrentFPS = 0

    SWEP.SignalLostTime = 0
    SWEP.ShowSignalLostMessage = false
    SWEP.IsDestroyedFlag = false
    SWEP.DestroyedTime = 0

    surface.CreateFont("FPV_OSD_Small", { font = "VCR OSD Mono Cyr", size = 14, weight = 400, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Tiny", { font = "VCR OSD Mono Cyr", size = 11, weight = 400, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Speed", { font = "VCR OSD Mono Cyr", size = 32, weight = 700, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Height", { font = "VCR OSD Mono Cyr", size = 24, weight = 700, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Warning", { font = "VCR OSD Mono Cyr", size = 28, weight = 800, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Skull", { font = "VCR OSD Mono Cyr", size = 48, weight = 800, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_FPS", { font = "VCR OSD Mono Cyr", size = 13, weight = 600, outline = true, antialias = true })
    surface.CreateFont("FPV_OSD_Angle", { font = "VCR OSD Mono Cyr", size = 16, weight = 700, outline = true, antialias = true })
    surface.CreateFont("Z-Box_Font", { font = "VCR OSD Mono Cyr", size = 18, weight = 700, outline = true, antialias = true })

    local FREQ_VIDEO_LIST = { 5645, 5732, 5769, 5800, 5860, 5905, 5945, 5880 }
    local FREQ_CONTROL_LIST = { 2400, 2440, 2480 }

    function SWEP:Initialize()
        self:SetHoldType(self.HoldType)
    end

    function SWEP:PrimaryAttack()
        if self.MenuOpen then
            self:CloseMenu()
        else
            self:OpenMenu()
        end
    end

    function SWEP:SecondaryAttack()
        if self.MenuOpen then
            self:CloseMenu()
        end
    end

    function SWEP:Reload()
        if self.ControlActive then
            net.Start("drone_controller_release_control_cmd")
            net.SendToServer()
            self.ControlActive = false
            self.SelectedDroneEnt = nil
            self.CurrentThrottle = 0
        end
    end

    function SWEP:OpenMenu()
        if self.MenuOpen then return end
        self:CreateMenu()
        self.MenuOpen = true
        gui.EnableScreenClicker(true)
    end

    function SWEP:CloseMenu()
        if IsValid(self.Menu) then
            self.Menu:Close()
            self.Menu:Remove()
        end
        self.MenuOpen = false
        gui.EnableScreenClicker(false)
    end

    function SWEP:CreateMenu()
        if IsValid(self.Menu) then
            self.Menu:Remove()
        end

        self.Menu = vgui.Create("DFrame")
        self.Menu:SetSize(640, 540)
        self.Menu:Center()
        self.Menu:SetTitle("FPV Drone Controller - Drone List")
        self.Menu:SetDraggable(true)
        self.Menu:SetDeleteOnClose(true)

        function self.Menu:OnClose()
            local wep = LocalPlayer():GetActiveWeapon()
            if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" then
                wep.MenuOpen = false
                gui.EnableScreenClicker(false)
            end
        end

        local droneList = vgui.Create("DListView", self.Menu)
        droneList:Dock(FILL)
        droneList:AddColumn("Drone ID")
        droneList:AddColumn("Status")
        droneList:AddColumn("Vid")
        droneList:AddColumn("Ctl")
        droneList:AddColumn("Battery")
        droneList:AddColumn("Distance")
        droneList:AddColumn("VTX")
        droneList:AddColumn("RX")
        droneList:DockMargin(10, 10, 10, 10)

        self.Menu.droneList = droneList

        local refreshBtn = vgui.Create("DButton", self.Menu)
        refreshBtn:Dock(BOTTOM)
        refreshBtn:SetText("Refresh")
        refreshBtn:SetTall(30)
        refreshBtn.DoClick = function()
            self:UpdateDroneList()
        end

        local connectBtn = vgui.Create("DButton", self.Menu)
        connectBtn:Dock(BOTTOM)
        connectBtn:SetText("Connect")
        connectBtn:SetTall(30)
        connectBtn.DoClick = function()
            if self.SelectedDroneEnt and IsValid(self.SelectedDroneEnt) then
                net.Start("drone_controller_connect")
                    net.WriteInt(self.SelectedDroneEnt:EntIndex(), 32)
                net.SendToServer()
                self:CloseMenu()
            end
        end

        local controlPanel = vgui.Create("DPanel", self.Menu)
        controlPanel:Dock(BOTTOM)
        controlPanel:SetTall(90)
        controlPanel:SetBackgroundColor(Color(25, 25, 25, 255))

        local ctlLabel = vgui.Create("DLabel", controlPanel)
        ctlLabel:SetPos(10, 4)
        ctlLabel:SetSize(400, 18)
        ctlLabel:SetText("Control Frequency (RX)")
        ctlLabel:SetColor(Color(200, 200, 200))
        ctlLabel:SetFont("FPV_OSD_Small")

        local ctlBtnWidth = 140
        for i, freq in ipairs(FREQ_CONTROL_LIST) do
            local btn = vgui.Create("DButton", controlPanel)
            btn:SetPos(10 + (i - 1) * (ctlBtnWidth + 6), 26)
            btn:SetSize(ctlBtnWidth, 26)
            btn:SetText(freq .. " MHz")
            btn.DoClick = function()
                if self.SelectedDroneEnt and IsValid(self.SelectedDroneEnt) then
                    net.Start("drone_set_frequency")
                        net.WriteEntity(self.SelectedDroneEnt)
                        net.WriteBool(false)
                        net.WriteFloat(freq)
                    net.SendToServer()
                    LocalPlayer():ChatPrint("Drone control frequency set to " .. freq .. " MHz")
                    self:UpdateDroneList()
                else
                    LocalPlayer():ChatPrint("Select a drone first!")
                end
            end
        end

        local videoPanel = vgui.Create("DPanel", self.Menu)
        videoPanel:Dock(BOTTOM)
        videoPanel:SetTall(90)
        videoPanel:SetBackgroundColor(Color(25, 25, 25, 255))

        local vidLabel = vgui.Create("DLabel", videoPanel)
        vidLabel:SetPos(10, 4)
        vidLabel:SetSize(400, 18)
        vidLabel:SetText("Video Frequency (VTX)")
        vidLabel:SetColor(Color(200, 200, 200))
        vidLabel:SetFont("FPV_OSD_Small")

        local vidBtnWidth = 70
        for i, freq in ipairs(FREQ_VIDEO_LIST) do
            local btn = vgui.Create("DButton", videoPanel)
            btn:SetPos(10 + (i - 1) * (vidBtnWidth + 4), 26)
            btn:SetSize(vidBtnWidth, 26)
            btn:SetText(tostring(freq))
            btn.DoClick = function()
                if self.SelectedDroneEnt and IsValid(self.SelectedDroneEnt) then
                    net.Start("drone_set_frequency")
                        net.WriteEntity(self.SelectedDroneEnt)
                        net.WriteBool(true)
                        net.WriteFloat(freq)
                    net.SendToServer()
                    LocalPlayer():ChatPrint("Drone video frequency set to " .. freq .. " MHz")
                    self:UpdateDroneList()
                else
                    LocalPlayer():ChatPrint("Select a drone first!")
                end
            end
        end

        self:UpdateDroneList()
    end

    function SWEP:UpdateDroneList()
        local listView = nil
        if IsValid(self.Menu) and IsValid(self.Menu.droneList) then
            listView = self.Menu.droneList
        else
            return
        end

        if not IsValid(listView) then return end

        listView:Clear()

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local plyPos = ply:GetPos()
        local drones = ents.FindByClass("ent_fpv_drone")

        for _, drone in ipairs(drones) do
            if not IsValid(drone) then continue end

            local distToDrone = plyPos:Distance(drone:GetPos())

            local pilot = drone:GetNWEntity("DronePilot", NULL)
            local isConnectedToMe = IsValid(pilot) and pilot == ply

            if not isConnectedToMe and distToDrone > 800 then
                continue
            end

            local status = "FREE"
            if IsValid(pilot) then
                if pilot == ply then
                    status = "YOU"
                else
                    status = "IN USE"
                end
            end

            if drone.disabled then
                status = "DISABLED"
            end

            if drone.IsDestroyed then
                status = "DESTROYED"
            end

            local videoNW = drone:GetNWInt("DroneVideoSignal", 100)
            local controlNW = drone:GetNWInt("DroneControlSignal", 100)

            local vidText = videoNW .. "%"
            if videoNW <= 0 then vidText = "LOST" elseif videoNW <= 30 then vidText = videoNW .. "% (WEAK)" end

            local ctlText = controlNW .. "%"
            if controlNW <= 0 then ctlText = "LOST" elseif controlNW <= 30 then ctlText = controlNW .. "% (WEAK)" end

            local battery = drone:GetNWFloat("DroneBattery", 100)
            if battery == nil then battery = 100 end

            local distance = math.Round(distToDrone / 39.37, 1)

            local vidFreq = drone:GetNWFloat("DroneVideoFreq", 5800)
            local ctlFreq = drone:GetNWFloat("DroneControlFreq", 2440)

            local batteryText = string.format("%.0f%%", battery)
            if battery < 20 then
                batteryText = batteryText .. " !"
            end

            local line = listView:AddLine(
                tostring(drone:EntIndex()),
                status,
                vidText,
                ctlText,
                batteryText,
                distance .. "m",
                string.format("%.0f", vidFreq),
                string.format("%.0f", ctlFreq)
            )

            line.Drone = drone
            line.OnSelect = function()
                self.SelectedDroneEnt = drone
            end
        end
    end

    function SWEP:GetDroneRT(drone)
        if not IsValid(drone) then return nil end

        local id = drone:EntIndex()
        if not self.RenderTargets[id] then
            local rtName = "drone_fpv_" .. id
            local rt = GetRenderTarget(rtName, 256, 256, false)
            if rt then
                local mat = CreateMaterial("drone_mat_" .. id, "UnlitGeneric", {
                    ["$basetexture"] = rt:GetName(),
                    ["$nolod"] = 1,
                    ["$vertexcolor"] = 1,
                    ["$ignorez"] = 1
                })
                self.RenderTargets[id] = {rt = rt, mat = mat, nextUpdate = 0}
            end
        end

        local data = self.RenderTargets[id]
        if data and data.rt then
            if CurTime() > data.nextUpdate then
                data.nextUpdate = CurTime() + 0.05

                local camPos = drone:GetPos() + drone:GetForward() * 5 + drone:GetUp() * 4
                local camAng = drone:GetAngles()

                render.PushRenderTarget(data.rt)
                    render.Clear(0, 0, 0, 255)
                    cam.Start3D(camPos, camAng, 100)
                        render.RenderView({
                            origin = camPos,
                            angles = camAng,
                            fov = 100,
                            drawviewmodel = false,
                            drawhud = false,
                            dopostprocess = false,
                            drawmonitors = false
                        })
                    cam.End3D()
                render.PopRenderTarget()
            end
            return data.mat
        end

        return nil
    end

    function SWEP:DrawSignalBars(x, y, signal)
        local bars = 5
        local barWidth = 6
        local barSpacing = 3

        for i = 1, bars do
            local barHeight = 6 + i * 2
            local threshold = (i / bars) * 100

            if signal >= threshold then
                surface.SetDrawColor(0, 255, 0, 220)
            elseif signal >= threshold - 20 then
                surface.SetDrawColor(255, 200, 0, 220)
            else
                surface.SetDrawColor(80, 80, 80, 220)
            end

            surface.DrawRect(x + (i - 1) * (barWidth + barSpacing), y + 20 - barHeight, barWidth, barHeight)
        end

        local signalColor = signal > 70 and Color(0, 255, 0) or (signal > 30 and Color(255, 200, 0) or Color(255, 50, 50))
        draw.SimpleText(string.format("%d%%", math.Round(signal)), "FPV_OSD_Tiny", x, y + 22, signalColor)
    end

    function SWEP:DrawControlIndicator(x, y, signal)
        local label = "CTL"
        local color
        if signal <= 0 then
            color = Color(255, 50, 50, 230)
            label = "NO CONTROL"
        elseif signal <= 30 then
            color = Color(255, 200, 0, 230)
        else
            color = Color(0, 255, 100, 230)
        end
        surface.SetDrawColor(color.r, color.g, color.b, 200)
        surface.DrawRect(x, y, 90, 18)
        draw.SimpleText(label .. " " .. math.Round(signal) .. "%", "FPV_OSD_Tiny", x + 45, y + 9, Color(0, 0, 0, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function SWEP:DrawThrottleBar(x, y, throttle, w, h)
        local fillHeight = (throttle / 50) * h

        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(x, y, w, h)

        local r = 0
        local g = 255
        if throttle > 30 then
            r = 255
            g = 255 - (throttle - 30) * 8
        end

        surface.SetDrawColor(r, g, 0, 220)
        surface.DrawRect(x, y + h - fillHeight, w, fillHeight)

        draw.SimpleText(string.format("%d%%", math.Round(throttle / 50 * 100)), "FPV_OSD_Tiny", x + w + 5, y + h - 10, Color(255, 255, 255))
    end

    function SWEP:UpdateFPS()
        local ct = CurTime()
        if ct - self.LastFPSUpdate >= 0.5 then
            self.LastFPSUpdate = ct
            self.CurrentFPS = math.Round(1 / FrameTime())
        end
    end

    function SWEP:GetNoiseLevel(videoSignal)
        local signal = math.Clamp(videoSignal or 0, 0, 100)
        if signal >= 85 then
            return 0
        elseif signal >= 70 then
            return math.floor((85 - signal) / 3)
        elseif signal >= 50 then
            return 8 + math.floor((70 - signal) / 2)
        elseif signal >= 30 then
            return 20 + math.floor((50 - signal) * 1.5)
        elseif signal >= 15 then
            return 50 + math.floor((30 - signal) * 2)
        elseif signal > 0 then
            return 80 + math.floor((15 - signal) * 1.3)
        else
            return 100
        end
    end

    function SWEP:DrawNoiseOnScreen(noiseLevel, w, h, signal)
        if noiseLevel <= 0 then return end

        local snowCount = math.Round(noiseLevel * 1.2)
        for i = 1, snowCount do
            local x = math.random(0, w)
            local y = math.random(0, h)
            local size = math.random(1, 2)
            local alpha = math.Round(30 + noiseLevel * 1.5)
            alpha = math.min(alpha, 200)
            local colorVal = 150 + math.Round(105 * (noiseLevel / 100))
            surface.SetDrawColor(colorVal, colorVal, colorVal, alpha)
            surface.DrawRect(x, y, size, size)
        end

        if noiseLevel > 15 then
            local lineCount = math.Round((noiseLevel - 15) * 0.6)
            for i = 1, lineCount do
                local y = math.random(0, h)
                local lineHeight = math.random(1, 2)
                local alpha = math.Round(40 + (noiseLevel - 15) * 1.5)
                alpha = math.min(alpha, 160)
                surface.SetDrawColor(80, 80, 80, alpha)
                surface.DrawRect(0, y, w, lineHeight)
            end
        end

        if noiseLevel > 40 then
            local darkSpotCount = math.Round((noiseLevel - 40) * 0.2)
            for i = 1, darkSpotCount do
                local x = math.random(0, w - 100)
                local y = math.random(0, h - 80)
                local spotW = math.random(40, 120)
                local spotH = math.random(30, 80)
                local alpha = math.Round(20 + (noiseLevel - 40) * 1.2)
                alpha = math.min(alpha, 100)
                surface.SetDrawColor(0, 0, 0, alpha)
                surface.DrawRect(x, y, spotW, spotH)
            end
        end

        if noiseLevel > 75 then
            local colorGlitchCount = math.Round((noiseLevel - 75) * 0.3)
            for i = 1, colorGlitchCount do
                local x = math.random(0, w - 50)
                local y = math.random(0, h - 20)
                local ww = math.random(20, 80)
                local hh = math.random(10, 30)
                local alpha = math.Round(60 + (noiseLevel - 75) * 2)
                alpha = math.min(alpha, 160)

                local colorType = math.random(1, 3)
                if colorType == 1 then
                    surface.SetDrawColor(255, 0, 0, alpha)
                elseif colorType == 2 then
                    surface.SetDrawColor(0, 255, 0, alpha)
                else
                    surface.SetDrawColor(0, 0, 255, alpha)
                end
                surface.DrawRect(x, y, ww, hh)
            end
        end
    end

    function SWEP:DrawCrosshair()
        local crossLength = 40
        local crossThick = 3
        local centerX, centerY = 300, 225

        surface.SetDrawColor(255, 255, 255, 255)

        surface.DrawRect(centerX - crossLength / 2, centerY - crossThick / 2, crossLength, crossThick)
        surface.DrawRect(centerX - crossThick / 2, centerY - crossLength / 2, crossThick, crossLength)
    end

    function SWEP:DrawAngleIndicators(roll, pitch)
        local centerX = 300
        local topY = 10

        draw.SimpleText(string.format("ROLL: %.0f°     PITCH: %.0f°", roll, pitch), "FPV_OSD_Angle", centerX, topY, Color(0, 255, 100, 220), TEXT_ALIGN_CENTER)
    end

    function SWEP:AddDrawModel(ent)
        if self.ControlActive and IsValid(self.SelectedDroneEnt) then
            local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
            pos = pos + ang:Up() * 1.2 + ang:Forward() * -5 + ang:Right() * -3.4

            local baseScale = 0.0155
            local screenScale = (ScrW() / 1920) * baseScale

            self:UpdateFPS()

            local screenW = 600
            local screenH = 440

            local rtMat = self:GetDroneRT(self.SelectedDroneEnt)
            local drone = self.SelectedDroneEnt

            local battery = drone:GetNWFloat("DroneBattery", 100)
            local speed = drone:GetNWFloat("DroneSpeed", 0)
            local height = drone:GetNWFloat("DroneHeight", 0)
            local videoNW = drone:GetNWInt("DroneVideoSignal", 100)
            local controlNW = drone:GetNWInt("DroneControlSignal", 100)
            local linkMin = math.min(videoNW, controlNW)
            local disabled = drone:GetNWBool("DroneDisabled", false)
            local pilot = drone:GetNWEntity("DronePilot", NULL)
            local isDestroyed = drone.IsDestroyed

            local droneAng = drone:GetAngles()
            local roll = droneAng.r
            local pitch = droneAng.p

            local noiseLevel = self:GetNoiseLevel(videoNW)

            local vidFreq = drone:GetNWFloat("DroneVideoFreq", 5800)
            local ctlFreq = drone:GetNWFloat("DroneControlFreq", 2440)

            vgui.Start3D2D(pos, ang, screenScale)
                if isDestroyed then
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, 0, screenW, screenH)
                    draw.SimpleText("X", "FPV_OSD_Skull", screenW / 2, screenH / 2 - 30, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("DRONE DESTROYED", "FPV_OSD_Warning", screenW / 2, screenH / 2 + 20, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("Press R to open menu", "FPV_OSD_Small", screenW / 2, screenH / 2 + 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
                elseif disabled then
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, 0, screenW, screenH)
                    draw.SimpleText("X", "FPV_OSD_Skull", screenW / 2, screenH / 2 - 30, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("DRONE DISABLED", "FPV_OSD_Warning", screenW / 2, screenH / 2 + 20, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("Press R to open menu", "FPV_OSD_Small", screenW / 2, screenH / 2 + 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
                elseif controlNW <= 0 and videoNW <= 0 then
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, 0, screenW, screenH)
                    draw.SimpleText("X", "FPV_OSD_Skull", screenW / 2, screenH / 2 - 30, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("DRONE LOST CONNECTION", "FPV_OSD_Warning", screenW / 2, screenH / 2 + 20, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("Press R to open menu", "FPV_OSD_Small", screenW / 2, screenH / 2 + 70, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
                elseif videoNW <= 0 then
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, 0, screenW, screenH)
                    draw.SimpleText("NO VIDEO", "FPV_OSD_Warning", screenW / 2, screenH / 2 - 20, Color(255, 100, 100, 255), TEXT_ALIGN_CENTER)
                    draw.SimpleText("CONTROL STILL ACTIVE", "FPV_OSD_Small", screenW / 2, screenH / 2 + 20, Color(255, 200, 0, 255), TEXT_ALIGN_CENTER)
                    self:DrawControlIndicator(10, 10, controlNW)
                    draw.SimpleText(string.format("RX %.0f MHz", ctlFreq), "FPV_OSD_Tiny", 10, 40, Color(200, 200, 200, 220))
                    self:DrawThrottleBar(screenW - 55, screenH - 90, self.CurrentThrottle, 25, 70)
                    draw.SimpleText("THR", "FPV_OSD_Tiny", screenW - 45, screenH - 105, Color(200, 200, 200), TEXT_ALIGN_CENTER)
                elseif rtMat then
                    surface.SetMaterial(rtMat)
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawTexturedRect(0, 0, screenW, screenH)

                    self:DrawNoiseOnScreen(noiseLevel, screenW, screenH, videoNW)

                    local batteryColor = battery < 20 and Color(255, 50, 50) or (battery < 50 and Color(255, 200, 0) or Color(0, 255, 0))

                    draw.SimpleText(string.format("%d", speed), "FPV_OSD_Speed", screenW - 10, 15, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
                    draw.SimpleText("KM/H", "FPV_OSD_Tiny", screenW - 10, 50, Color(200, 200, 200), TEXT_ALIGN_RIGHT)

                    draw.SimpleText(string.format("%dm", height), "FPV_OSD_Height", screenW - 10, 200, Color(255, 255, 255), TEXT_ALIGN_RIGHT)
                    draw.SimpleText("ALT", "FPV_OSD_Tiny", screenW - 10, 230, Color(200, 200, 200), TEXT_ALIGN_RIGHT)

                    draw.SimpleText(string.format("%.0f%%", battery), "FPV_OSD_Small", 10, 25, batteryColor)
                    draw.SimpleText("BAT", "FPV_OSD_Tiny", 10, 10, Color(200, 200, 200))

                    self:DrawSignalBars(12, screenH - 50, videoNW)
                    self:DrawControlIndicator(12, screenH - 80, controlNW)
                    self:DrawThrottleBar(screenW - 55, screenH - 90, self.CurrentThrottle, 25, 70)
                    draw.SimpleText("THR", "FPV_OSD_Tiny", screenW - 45, screenH - 105, Color(200, 200, 200), TEXT_ALIGN_CENTER)

                    draw.SimpleText(string.format("VTX %.0f MHz", vidFreq), "FPV_OSD_Tiny", 10, screenH - 250, Color(200, 200, 200), TEXT_ALIGN_LEFT)
                    draw.SimpleText(string.format("RX %.0f MHz", ctlFreq), "FPV_OSD_Tiny", 10, screenH - 235, Color(200, 200, 200), TEXT_ALIGN_LEFT)

                    if battery < 20 then
                        draw.SimpleText("LOW BATTERY!", "FPV_OSD_Small", screenW / 2, screenH / 2 - 80, Color(255, 50, 50), TEXT_ALIGN_CENTER)
                    end

                    if linkMin < 30 then
                        draw.SimpleText("WEAK SIGNAL!", "FPV_OSD_Small", screenW / 2, screenH / 2 - 60, Color(255, 200, 0), TEXT_ALIGN_CENTER)
                    end

                    if controlNW <= 0 then
                        draw.SimpleText("NO CONTROL!", "FPV_OSD_Small", screenW / 2, screenH / 2 - 40, Color(255, 50, 50), TEXT_ALIGN_CENTER)
                    end

                    if IsValid(pilot) and pilot ~= LocalPlayer() then
                        draw.SimpleText("DRONE IN USE BY: " .. pilot:Name(), "FPV_OSD_Tiny", screenW / 2, screenH - 20, Color(255, 100, 100), TEXT_ALIGN_CENTER)
                    end

                    local centerX = screenW / 2
                    local centerY = screenH / 2
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawRect(centerX - 20, centerY - 1, 40, 2)
                    surface.DrawRect(centerX - 1, centerY - 20, 2, 40)

                    draw.SimpleText(string.format("ROLL: %.0f°     PITCH: %.0f°", roll, pitch), "FPV_OSD_Angle", screenW / 2, 10, Color(0, 255, 100, 220), TEXT_ALIGN_CENTER)

                    draw.SimpleText(string.format("FPS %d", self.CurrentFPS), "FPV_OSD_FPS", screenW / 2, screenH / 2 + 80, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)

                    draw.SimpleText("Z", "Z-Box_Font", 280, 40, Color(139, 0, 0, 220), TEXT_ALIGN_LEFT)
                    draw.SimpleText("-", "Z-Box_Font", 291, 40, Color(150, 150, 150, 220), TEXT_ALIGN_LEFT)
                    draw.SimpleText("Box", "Z-Box_Font", 300, 40, Color(255, 255, 255, 220), TEXT_ALIGN_LEFT)
                else
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(0, 0, screenW, screenH)
                    draw.SimpleText("NO VIDEO", "FPV_OSD_Small", screenW / 2, screenH / 2, Color(255, 100, 100), TEXT_ALIGN_CENTER)
                end
            vgui.End3D2D()
        elseif not self.ControlActive then
            if not IsValid(self.Menu) then
                self:CreateMenu()
            end

            local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
            pos = pos + ang:Up() * 1.2 + ang:Forward() * -14.82 + ang:Right() * -8.2

            local baseScale = 0.0151
            local screenScale = (ScrW() / 1920) * baseScale

            vgui.Start3D2D(pos, ang, screenScale)
                if self.Menu then
                    self.Menu:Paint3D2D()
                end
            vgui.End3D2D()
        end
    end

    net.Receive("drone_frequency_update", function()
        local drone = net.ReadEntity()
        local isVideo = net.ReadBool()
        local freq = net.ReadFloat()
        if IsValid(drone) then
            if isVideo then
                drone:SetNWFloat("DroneVideoFreq", freq)
                drone:SetNWFloat("DroneFrequency", freq)
                drone.Frequency = freq
            else
                drone:SetNWFloat("DroneControlFreq", freq)
            end

            local ply = LocalPlayer()
            if IsValid(ply) then
                local wep = ply:GetActiveWeapon()
                if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" and wep.MenuOpen then
                    wep:UpdateDroneList()
                end
            end
        end
    end)

    net.Receive("drone_controller_take_control", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" then
            wep.ControlActive = true
            wep.CurrentThrottle = 0
            wep.LastThrottleTime = 0
            wep.AnglesLocked = true
            wep.FixedAngles = LocalPlayer():EyeAngles()
            wep.SmoothRoll = 0
            wep.SmoothPitch = 0
            wep.SmoothYaw = 0
            wep.SmoothThrottle = 0
            wep.ShowSignalLostMessage = false
            wep.IsDestroyedFlag = false
            if wep.MenuOpen then
                wep:CloseMenu()
            end
        end
    end)

    net.Receive("drone_controller_release_control", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" then
            wep.ControlActive = false
            wep.CurrentThrottle = 0
            wep.LastThrottleTime = 0
            wep.AnglesLocked = false
            wep.ShowSignalLostMessage = false
            wep.IsDestroyedFlag = false
        end
    end)

    net.Receive("drone_controller_connected", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" then
            local droneIndex = net.ReadInt(32)
            local drone = Entity(droneIndex)
            if IsValid(drone) then
                wep.SelectedDroneEnt = drone
                wep.ShowSignalLostMessage = false
                wep.IsDestroyedFlag = false
                print("[Drone Controller] Connected to drone:", drone:EntIndex())
            end
        end
    end)

    net.Receive("drone_destroyed", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_drone_controller" and wep.ControlActive then
            if IsValid(wep.SelectedDroneEnt) and wep.SelectedDroneEnt.IsDestroyed then
                wep.ControlActive = false
                wep.SelectedDroneEnt = nil
                wep.CurrentThrottle = 0
            end
        end
    end)

    hook.Add("CreateMove", "DroneAcroControl", function(cmd)
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_drone_controller" then return end
        if not wep.ControlActive or not IsValid(wep.SelectedDroneEnt) then return end

        local drone = wep.SelectedDroneEnt
        local controlNW = drone:GetNWInt("DroneControlSignal", 100)
        local brokenControl = controlNW <= 17

        cmd:SetForwardMove(0)
        cmd:SetSideMove(0)
        cmd:SetUpMove(0)

        if wep.AnglesLocked and wep.FixedAngles then
            cmd:SetViewAngles(wep.FixedAngles)
        end

        local mouseSensitivity = 0.0045
        local mouseX = cmd:GetMouseX() * mouseSensitivity
        local mouseY = cmd:GetMouseY() * mouseSensitivity

        local rollRaw = -mouseY
        local pitchRaw = mouseX

        if math.abs(mouseX) < 0.0003 and math.abs(mouseY) < 0.0003 then
            rollRaw = 0
            pitchRaw = 0
        end

        if brokenControl then
            rollRaw = rollRaw + (math.random(-100, 100) / 400)
            pitchRaw = pitchRaw + (math.random(-100, 100) / 400)
        end

        local damping = 0.92
        wep.SmoothRoll = wep.SmoothRoll * damping + rollRaw * (1 - damping)
        wep.SmoothPitch = wep.SmoothPitch * damping + pitchRaw * (1 - damping)

        local roll = math.Clamp(wep.SmoothRoll, -1.2, 1.2)
        local pitch = math.Clamp(wep.SmoothPitch, -1.2, 1.2)

        local yawRaw = 0
        if input.IsKeyDown(KEY_A) then yawRaw = 0.25 end
        if input.IsKeyDown(KEY_D) then yawRaw = -0.25 end

        if brokenControl then
            yawRaw = yawRaw + (math.random(-50, 50) / 200)
        end

        local yawDamping = 0.92
        wep.SmoothYaw = wep.SmoothYaw * yawDamping + yawRaw * (1 - yawDamping)

        if not input.IsKeyDown(KEY_A) and not input.IsKeyDown(KEY_D) then
            wep.SmoothYaw = wep.SmoothYaw * 0.96
        end

        local yaw = math.Clamp(wep.SmoothYaw, -0.8, 0.8)

        local throttleDelta = 0
        local throttleSpeed = 2.5

        if input.IsKeyDown(KEY_W) then throttleDelta = throttleSpeed end
        if input.IsKeyDown(KEY_S) then throttleDelta = -throttleSpeed end

        local mouseWheel = cmd:GetMouseWheel()
        if mouseWheel ~= 0 then
            throttleDelta = throttleDelta + mouseWheel * 1.2
        end

        if brokenControl and throttleDelta == 0 and math.random(1, 100) < 10 then
            throttleDelta = math.random(-3, 3)
        end

        if throttleDelta ~= 0 then
            local now = CurTime()
            if wep.LastThrottleTime == 0 then
                wep.LastThrottleTime = now
                wep.CurrentThrottle = math.Clamp(wep.CurrentThrottle + throttleDelta, 0, 50)
            elseif now - wep.LastThrottleTime >= 0.08 then
                wep.LastThrottleTime = now
                wep.CurrentThrottle = math.Clamp(wep.CurrentThrottle + throttleDelta, 0, 50)
            end
        else
            wep.LastThrottleTime = 0
        end

        net.Start("fpv_control")
            net.WriteEntity(wep.SelectedDroneEnt)
            net.WriteFloat(roll)
            net.WriteFloat(pitch)
            net.WriteFloat(yaw)
            net.WriteFloat(wep.CurrentThrottle)
        net.SendToServer()

        cmd:SetMouseX(0)
        cmd:SetMouseY(0)
    end)

end