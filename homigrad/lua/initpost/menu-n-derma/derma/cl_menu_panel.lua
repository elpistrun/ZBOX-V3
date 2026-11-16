surface.CreateFont("ZC_MM_Title2", {
    font = "Bahnschrift",
    size = ScreenScale(10),
    weight = 1000,
    antialias = true
})
local textRed = "Z"
local textWhite = "-BOX V3"
local fontName = "ZC_MM_Title2"

hook.Add("HUDPaint", "slivhomicbox", function()
    surface.SetFont(fontName)
    local redWidth, redHeight = surface.GetTextSize(textRed)
    local whiteWidth, whiteHeight = surface.GetTextSize(textWhite)
    local totalWidth = redWidth + whiteWidth
    local xStart = ScrW() - totalWidth - 10
    local baseY = 5
    local t = RealTime() * 2
    local pulse = math.sin(t) * 3
    local alpha = 0.6 + math.sin(t * 1.5) * 0.2
    alpha = math.Clamp(alpha, 0.3, 0.9)
    local y = baseY - pulse
    surface.SetTextColor(255, 50, 50, 255 * alpha)
    surface.SetTextPos(xStart, y)
    surface.DrawText(textRed)
    surface.SetTextColor(255, 255, 255, 255 * alpha * 0.9)
    surface.SetTextPos(xStart + redWidth, y)
    surface.DrawText(textWhite)
end)
-- зомби чипсы

----
local PANEL = {}

local red_select = Color(245,45,45)
local red_neon = Color(255, 50, 50, 180)

local Selects = {
    {Title = "Disconnect", Func = function(luaMenu) RunConsoleCommand("disconnect") end},
    {Title = "Retry", Func = function(luaMenu) RunConsoleCommand("retry") end},
    {Title = "Main Menu", Func = function(luaMenu) gui.ActivateGameUI() luaMenu:Close() end},
    {Title = "Discord", Func = function(luaMenu) luaMenu:Close() gui.OpenURL("https://discord.gg/aSUxvwDrAs ")  end},
    {Title = "Appearance", Func = function(luaMenu) 
    luaMenu:Close() 
    if hg and hg.CreateApperanceMenu then
        local appearanceFrame = vgui.Create("HG_AppearanceMenu")
        appearanceFrame:SetSize(ScrW(), ScrH())
        appearanceFrame:MakePopup()
    else
        RunConsoleCommand("hg_appearance_menu")
    end
end},
    --{Title = "Arsenal", Func = function(luaMenu) 
    --luaMenu:Close() 
    --if hg and hg.CreateArmoryMenu then
     --   local arsenalFrame = vgui.Create("HG_ArmoryMenu")
     --   arsenalFrame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
     --   arsenalFrame:Center()
     --   arsenalFrame:MakePopup()
  --  else
    --    RunConsoleCommand("hg_arsenal_menu")
  --  end
--end},
    {Title = "Settings", Func = function(luaMenu) 
    luaMenu:Close()
    local settingsFrame = vgui.Create("DFrame")
    settingsFrame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    settingsFrame:Center()
    settingsFrame:MakePopup()
    settingsFrame:SetTitle("Settings")
    settingsFrame:ShowCloseButton(true)
    
    if hg and hg.DrawSettings then
        hg.DrawSettings(settingsFrame)
    end
end},
    {Title = "Give Ammo", Func = function(luaMenu) 
    net.Start("GiveAmmoToPlayer")
    net.SendToServer()
end},
    {Title = "Give Melee Belt", Func = function(luaMenu)
    net.Start("AutoPickupSpawnSlingForPlayer")
    net.SendToServer()
    luaMenu:Close()
end},
    {Title = "Kill", Func = function(luaMenu) 
    RunConsoleCommand("kill")
    luaMenu:Close()
end},
    {Title = "Return", Func = function(luaMenu) luaMenu:Close() end},
}


surface.CreateFont("ZC_MM_Title", {
    font = "Bahnschrift",
    size = ScreenScale(40),
    weight = 800,
    antialias = true
})

local Pluv = Material("pluv/pluvkid.jpg")

local function createGradientText(time)
    -- перелив и вся хуйня
    local gradient1 = math.sin(time * 2) * 0.5 + 0.5
    local gradient2 = math.sin(time * 2 + 2) * 0.5 + 0.5
    local gradient3 = math.sin(time * 2 + 4) * 0.5 + 0.5
    
    local zRed = 255
    local zGreen = 20 + 40 * gradient1
    local zBlue = 20 + 40 * gradient2 
    

    local boxBase = 180 + 75 * gradient1 
    local boxR = boxBase
    local boxG = boxBase + 10 * math.sin(time * 3)
    local boxB = boxBase + 20 * math.cos(time * 3)
    
    local v3Base = 185 + 70 * gradient2 
    local v3R = v3Base
    local v3G = v3Base + 5 * math.sin(time * 3 + 1)
    local v3B = v3Base + 15 * math.cos(time * 3 + 1)
    
    -- Основной текст с градиентом
    local text = string.format(
        "<font=ZC_MM_Title><colour=%d,%d,%d,255>Z</colour>-<colour=%d,%d,%d,255>Box</colour> <colour=%d,%d,%d,255>V3</colour></font>",
        zRed, zGreen, zBlue,
        boxR, boxG, boxB, 
        v3R, v3G, v3B 
    )
    
    return text
end

function PANEL:InitializeMarkup()
    local mapname = game.GetMap()
    local prefix = string.find(mapname, "_")
    if prefix then
        mapname = string.sub(mapname, prefix + 1)
    end
    local gm = gmod.GetGamemode().Name .. " | " .. string.NiceName(zb ~= nil and zb.GetRoundName or mapname)

    if hg.PluvTown.Active then
        local text = "<font=ZC_MM_Title><colour=255,15,15,255>    </colour>Box V3</font>\n<font=ZCity_Small>" .. gm .. "</font>"
        self.SelectedPluv = table.Random(hg.PluvTown.PluvMats)
        return markup.Parse(text)
    end

    local gradientText = createGradientText(RealTime())
    local text = gradientText .. "\n<font=ZCity_Small>" .. gm .. "</font>"
    return markup.Parse(text)
end

function PANEL:Think()

    if self.slideProgress < 1 then
        self.slideProgress = math.min(self.slideProgress + FrameTime() * 3, 1)
        local eased = 1 - math.pow(1 - self.slideProgress, 3)
        self:SetPos(self.startX - (self.startX - self.targetX) * eased, self:GetY())
    end
    

    if not self.nextGradientUpdate or self.nextGradientUpdate < RealTime() then
        self.Title, self.TitleShadow = self:InitializeMarkup()
        self.nextGradientUpdate = RealTime() + 0.05 -- Обновление каждые 0.05 секунды
    end
end

local color_red = Color(255,25,25,45)


local function drawNebula(w, h, time)
    -- фон прозрачнаст делат смалйик крут
    surface.SetDrawColor(10, 5, 15, 254)
    surface.DrawRect(0, 0, w, h)
    

    local nebulaColors = {
        {30, 10, 40, 20},
        {50, 10, 30, 15},
        {20, 5, 50, 10},
        {40, 5, 20, 12}, 
    }
    
    for layer = 1, 8 do
        local color = nebulaColors[(layer % #nebulaColors) + 1]
        local segments = 12
        local baseX = w * 0.3 + math.sin(time * 0.2 + layer) * 50
        local baseY = h * 0.5 + math.cos(time * 0.3 + layer) * 30
        
        for i = 1, segments do
            local angle = (i / segments) * math.pi * 2 + time * 0.1
            local radius = 150 + math.sin(time + i) * 50 + layer * 40
            
            local x1 = baseX + math.cos(angle) * radius
            local y1 = baseY + math.sin(angle) * radius
            local x2 = baseX + math.cos(angle + 0.5) * (radius - 30)
            local y2 = baseY + math.sin(angle + 0.5) * (radius - 30)
            
            surface.SetDrawColor(color[1], color[2], color[3], color[4])
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
    
    for cluster = 1, 5 do
        local clusterX = w * 0.2 + math.sin(time * 0.5 + cluster) * 100
        local clusterY = h * 0.3 + math.cos(time * 0.4 + cluster) * 100 + cluster * 50
        
        for star = 1, 20 do
            local angle = (star / 20) * math.pi * 2 + time
            local dist = 30 + math.sin(time * 2 + star) * 10
            
            local x = clusterX + math.cos(angle) * dist
            local y = clusterY + math.sin(angle) * dist
            
            if x > 0 and x < w and y > 0 and y < h then
                local size = 2 + math.sin(time * 5 + star) * 1
                local alpha = 100 + 50 * math.sin(time * 3 + star)
                
                surface.SetDrawColor(255, 200, 255, alpha)
                surface.DrawRect(x - size/2, y - size/2, size, size)
            end
        end
    end
    
    for i = 1, 400 do
        local x = (i * 137) % w
        local y = (i * 271) % h
        local brightness = 30 + 50 * math.sin(time * 2 + i)
        
        surface.SetDrawColor(255, 255, 255, brightness)
        surface.DrawRect(x, y, 1, 1)
    end
end

local function drawNeonLines(x, y, w, h, angleDeg, time)
    if not w or not h or w <= 0 or h <= 0 then return end
    
    local spacing = 65
    local lineWidth = 24
    local blurAmount = 18
    
    local angleRad = math.rad(angleDeg)
    local cosA = math.cos(angleRad)
    local sinA = math.sin(angleRad)
    
    local diagonal = math.sqrt(w * w + h * h) * 1.8
    local steps = math.ceil(diagonal / spacing) + 15
    
    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    
    local moveOffset = (time * 25) % spacing
    
    for i = -steps, steps do
        local offset = i * spacing + moveOffset
        local centerX = x + w/2 + cosA * offset
        local centerY = y + h/2 + sinA * offset
        
        local perpX = -sinA
        local perpY = cosA
        
        local pulse = math.sin(time * 3 + i * 0.5) * 0.4 + 0.6
        
        for blur = 1, 5 do
            local startX = centerX - perpX * (diagonal/2)
            local startY = centerY - perpY * (diagonal/2)
            local endX = centerX + perpX * (diagonal/2)
            local endY = centerY + perpY * (diagonal/2)
            
            local r = 255
            local g = 20 + math.sin(time * 6 + i) * 30
            local b = 20 + math.cos(time * 5 + i) * 30
            
            if blur == 1 then
                surface.SetDrawColor(r, 50, 50, 200 * pulse)
                surface.DrawLine(startX, startY, endX, endY)
            elseif blur == 2 then
                surface.SetDrawColor(r, 40, 40, 100 * pulse)
                surface.DrawLine(startX, startY, endX, endY)
            elseif blur == 3 then
                surface.SetDrawColor(r, 30, 30, 50 * pulse)
                surface.DrawLine(startX, startY, endX, endY)
            else
                surface.SetDrawColor(r, 20, 20, 20 * pulse)
                surface.DrawLine(startX, startY, endX, endY)
            end
        end
    end
    
    render.PopFilterMag()
    render.PopFilterMin()
end

-- космос пульсар ахуй
local function drawPulsar(w, h, time)
    local centerX = w * 0.75
    local centerY = h * 0.5
    
    local pulseIntensity = 0.3 + 0.9 * math.sin(time * 5)
    
    local baseAngle = math.pi / 4
    

    local swingAmount = 0.087 
    local swing = math.sin(time * 10) * swingAmount 
    

    local angle1 = baseAngle + swing
    local angle2 = baseAngle + math.pi + swing
    
    local rayLength = 1000 + math.sin(time * 30) * 80
    

    for i = 1, 4 do
        local radius = 22 - i * 4 + math.sin(time * 25 + i) * 2
        local alpha = 250 * pulseIntensity * (1 - i/5)
        
        local r = 255
        local g = 240 + 15 * math.sin(time * 10 + i)
        local b = 255
        
        for j = 1, 24 do
            local angle = (j / 24) * math.pi * 2
            local nextAngle = ((j + 1) / 24) * math.pi * 2
            
            local x1 = centerX + math.cos(angle) * radius
            local y1 = centerY + math.sin(angle) * radius
            local x2 = centerX + math.cos(nextAngle) * radius
            local y2 = centerY + math.sin(nextAngle) * radius
            
            surface.SetDrawColor(r, g, b, alpha)
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
    

    for i = 1, 4 do
        local radius = 32 + i * 7 + math.sin(time * 20 + i) * 5
        local alpha = 150 * pulseIntensity * (1 - i/5)
        
        local r = 200 + 55 * math.sin(time * 8 + i)
        local g = 220 + 35 * math.cos(time * 7 + i)
        local b = 255
        
        for j = 1, 28 do
            local angle = (j / 28) * math.pi * 2
            local x1 = centerX + math.cos(angle) * radius
            local y1 = centerY + math.sin(angle) * radius
            local x2 = centerX + math.cos(angle + 0.15) * (radius - 5)
            local y2 = centerY + math.sin(angle + 0.15) * (radius - 5)
            
            surface.SetDrawColor(r, g, b, alpha)
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
    

    for i = 1, 3 do
        local radius = 12 - i * 3
        local alpha = 200 * pulseIntensity
        
        for j = 1, 16 do
            local angle = (j / 16) * math.pi * 2
            local x1 = centerX + math.cos(angle) * radius
            local y1 = centerY + math.sin(angle) * radius
            local x2 = centerX + math.cos(angle + 0.3) * (radius + 4)
            local y2 = centerY + math.sin(angle + 0.3) * (radius + 4)
            
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
    

    for _, angle in pairs({angle1, angle2}) do

        for r = 1, 5 do
            local angleOffset = (r - 3) * 0.03
            local rayAngle = angle + angleOffset
            local length = rayLength * (1 - (r-1) * 0.1)
            
            local endX = centerX + math.cos(rayAngle) * length
            local endY = centerY + math.sin(rayAngle) * length
            

            local rayR = 255
            local rayG = 240 + 15 * math.sin(time * 12 + r)
            local rayB = 255
            

            for blur = 1, 6 do
                local alpha = 60 * pulseIntensity * (1 - blur/7) * (1 - r * 0.12)
                surface.SetDrawColor(rayR, rayG, rayB, alpha)
                surface.DrawLine(centerX + blur*2, centerY + blur*2, endX + blur*2, endY + blur*2)
                surface.DrawLine(centerX - blur*2, centerY - blur*2, endX - blur*2, endY - blur*2)
            end
            

            surface.SetDrawColor(rayR, rayG, rayB, 120 * pulseIntensity * (1 - r * 0.1))
            surface.DrawLine(centerX, centerY, endX, endY)
        end
    end
    

    for i = 1, 5 do
        local radius = 45 + i * 20 + math.sin(time * 12 + i) * 10
        local alpha = 25 * pulseIntensity * (1 - i/6)
        
        for j = 1, 30 do
            local angle = (j / 30) * math.pi * 2
            local x1 = centerX + math.cos(angle) * radius
            local y1 = centerY + math.sin(angle) * radius
            local x2 = centerX + math.cos(angle + 0.2) * (radius + 8)
            local y2 = centerY + math.sin(angle + 0.2) * (radius + 8)
            
            surface.SetDrawColor(180, 200, 255, alpha)
            surface.DrawLine(x1, y1, x2, y2)
        end
    end
end

function PANEL:Init()
    self:SetAlpha(0)
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetBorder(false)
    self:SetColorBG(Color(10,10,19,235))
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    

    self.slideProgress = 0
    self.targetX = ScrW() - self:GetWide()
    self.startX = ScrW() + self:GetWide() * 0.3
    
    self.Title, self.TitleShadow = self:InitializeMarkup()
    
    timer.Simple(0, function()
        if self.First then
            self:First()
        end
    end)
    

    self.lDock = vgui.Create("DPanel", self)
    local lDock = self.lDock
    lDock:Dock(LEFT)
    lDock:SetSize(ScrW()/2, ScrH())
    lDock:DockMargin(ScreenScale(25), ScreenScaleH(10), ScreenScale(10), ScreenScaleH(50))
    lDock.Paint = function(this, w, h)
        if hg.PluvTown.Active then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.SelectedPluv or Pluv)
            surface.DrawTexturedRect(0, ScreenScale(27), ScreenScale(35), ScreenScale(27))
        end

        self.Title:Draw(0, ScreenScale(50), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_LEFT)
        return true
    end

    self.Buttons = {}
    for k, v in ipairs(Selects) do
        if v.GamemodeOnly and engine.ActiveGamemode() != "zbattle" then continue end
        self:AddSelect(lDock, v.Title, v)
    end


    self.rDock = vgui.Create("DPanel", self)
    local rDock = self.rDock
    rDock:Dock(RIGHT)
    rDock:SetSize(ScrW()/2, ScrH())
    rDock:DockMargin(ScreenScale(15), ScreenScaleH(70), ScreenScale(10), ScreenScaleH(10))
    rDock.Paint = function(this, w, h)
        return true
    end

    local zteam = vgui.Create("DLabel", rDock)
    zteam:Dock(BOTTOM)
    zteam:SetFont("ZCity_Tiny")
    zteam:SetTextColor(Color(255,255,255,200))
    zteam:SetText("Original Z-City by sadsalat and his team. Have A Nice Day")
    zteam:SetContentAlignment(3)
    zteam:SetExpensiveShadow(2, Color(0,0,0,220))

    local zteam2 = vgui.Create("DLabel", rDock)
    zteam2:Dock(BOTTOM)
    zteam2:SetFont("ZCity_Tiny")
    zteam2:SetTextColor(Color(255,255,255,200))
    zteam2:SetText("Z-Box reopened by kirik1222,Kimano33")
    zteam2:SetContentAlignment(3)
    zteam2:SetExpensiveShadow(2, Color(0,0,0,220))

    -- Убрал блок с серверами нафиг
end

local cardcolor = Color(15,15,25,180)
local green_color = Color(55,225,55)

function PANEL:AddServerCard(serverTbl)
    local main = self
    local card = vgui.Create("DPanel", self.rDock)
    card:Dock(TOP)
    card:SetSize(500, ScreenScaleH(45))
    card:DockMargin(5,5,5,5)
    card:DockPadding(15,5,15,15)
    card.Info = serverTbl
    function card:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, cardcolor)
        draw.RoundedBox(0, 0, h-h/5, w, h/5, cardcolor)
        draw.RoundedBox(0, 2.5, h-h/5 + 3, w * (card.Info["players"]/card.Info["max_players"]) - 5, h/6, color_red)
    end

    local lbl = vgui.Create("DLabel", card)
    lbl:Dock(BOTTOM)
    lbl:SetFont("ZCity_Tiny")
    lbl:SetText(card.Info["players"].."/"..card.Info["max_players"])
    lbl:SizeToContents()
    lbl:SetTall(ScreenScaleH(17))
    lbl:SetExpensiveShadow(2, Color(0,0,0,200))

    local lbl = vgui.Create("DLabel", card)
    lbl:Dock(LEFT)
    lbl:SetFont("ZCity_Small")
    lbl:SetText(card.Info["name"])
    lbl:SizeToContents()
    lbl:SetTall(ScreenScaleH(19))
    lbl:SetExpensiveShadow(2, Color(0,0,0,200))

    local connectButton = vgui.Create("DButton", card)
    connectButton:Dock(RIGHT)
    connectButton:SetFont("ZCity_Small")
    connectButton:SetText("Connect")
    connectButton:SizeToContents()
    connectButton:SetTall(ScreenScaleH(19))
    connectButton.HoverLerp = 0
    connectButton.RColor = Color(255,255,255)
    function connectButton:Paint(w, h)
        return false
    end

    function connectButton:Think()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, self:IsHovered() and 1 or 0)
        local v = self.HoverLerp
        self:SetTextColor(self.RColor:Lerp(green_color, v))
    end

    function connectButton:DoClick()
        permissions.AskToConnect(card.Info["addr"])
    end
end

function PANEL:First(ply)
    self:AlphaTo(255, 0.1, 0, nil)
end

function PANEL:Paint(w, h)

    local x, y = self:GetPos()
    
    render.SetScissorRect(x, y, x + w, y + h, true)
    
    local time = RealTime()
    
    drawNebula(w, h, time)
    
    drawPulsar(w, h, time)
    
    if hg and hg.DrawBlur then
        hg.DrawBlur(self, 2)
    end
    
    drawNeonLines(0, 0, w, h, 60, time)
    
    surface.SetDrawColor(255, 50, 50, 100)
    surface.DrawRect(0, 0, 3, h)
    
    for i = 1, 4 do
        local alpha = 40 - i * 8
        if alpha > 0 then
            surface.SetDrawColor(255, 40, 40, alpha)
            surface.DrawOutlinedRect(-i, -i, w + i*2, h + i*2)
        end
    end
    
    render.SetScissorRect(0, 0, 0, 0, false)
    
    surface.SetDrawColor(255, 50, 50, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:AddSelect(pParent, strTitle, tbl)
    local id = #self.Buttons + 1
    self.Buttons[id] = vgui.Create("DLabel", pParent)
    local btn = self.Buttons[id]
    btn:SetText(strTitle)
    btn:SetMouseInputEnabled(true)
    btn:SizeToContents()
    btn:SetFont("ZCity_Small")
    btn:SetTall(ScreenScale(15))
    btn:Dock(BOTTOM)
    btn:DockMargin(0, ScreenScale(2), 0, 0)
    btn.Func = tbl.Func
    btn.HoveredFunc = tbl.HoveredFunc
    local luaMenu = self
    if tbl.CreatedFunc then tbl.CreatedFunc(btn, self, luaMenu) end
    btn.RColor = Color(225,225,225)
    btn:SetExpensiveShadow(2, Color(0,0,0,200))
    function btn:DoClick()
        btn.Func(luaMenu)
    end

    function btn:Think()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, (self:IsHovered() or (IsValid(self:GetChild(0)) and self:GetChild(0):IsHovered()) or (IsValid(self:GetChild(0)) and IsValid(self:GetChild(0):GetChild(0)) and self:GetChild(0):GetChild(0):IsHovered())) and 1 or 0)

        local v = self.HoverLerp
        self:SetTextColor(self.RColor:Lerp(red_select, v))
    end
end

function PANEL:Close()
    local closeX = ScrW() + self:GetWide() * 0.3
    self:MoveTo(closeX, self:GetY(), 0.3, 0, 0.1, function()
        self:AlphaTo(0, 0.1, 0, function() self:Remove() end)
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register("ZMainMenu", PANEL, "ZFrame")

hook.Add("OnPauseMenuShow", "OpenMainMenu", function()
    local run = hook.Run("OnShowZCityPause")
    if run then
        return run
    end

    if MainMenu and IsValid(MainMenu) then
        MainMenu:Close()
        MainMenu = nil
        return false
    end

    MainMenu = vgui.Create("ZMainMenu")
    MainMenu:SetPos(ScrW() + ScrW() * 0.3, 0)
    MainMenu.targetX = ScrW() - MainMenu:GetWide()
    MainMenu.startX = MainMenu:GetX()
    MainMenu:MakePopup()
    return false
end)