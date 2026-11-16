AddCSLuaFile()

local function GetActiveDrone(ply)
    if not IsValid(ply) then return nil end
    local kamikaze = ply:GetNWEntity("kamikaze_")
    local mavic = ply:GetNWEntity("active_mavic")
    
    if IsValid(kamikaze) then return kamikaze, "kamikaze" end
    if IsValid(mavic) then return mavic, "mavic" end
    return nil, nil
end

if SERVER then
    local PlayerOrigins = PlayerOrigins or {}

    hook.Add("SetupMove", "Drones_PhysicalTeleport", function(ply, mv, cmd)
        local drone, dType = GetActiveDrone(ply)
        if IsValid(drone) then
            if not PlayerOrigins[ply:SteamID64()] then
                PlayerOrigins[ply:SteamID64()] = { pos = ply:GetPos(), ang = ply:EyeAngles() }
                ply:SetNotSolid(true)
                ply:SetMoveType(MOVETYPE_NOCLIP)
                if ply:GetActiveWeapon():IsValid() then ply:GetActiveWeapon():SetNoDraw(true) end
            end
            mv:SetOrigin(drone:GetPos())
        else
            local data = PlayerOrigins[ply:SteamID64()]
            if data then
                ply:SetPos(data.pos)
                ply:SetNoDraw(false)
                ply:SetNotSolid(false)
                ply:SetMoveType(MOVETYPE_WALK)
                if ply:GetActiveWeapon():IsValid() then ply:GetActiveWeapon():SetNoDraw(false) end
                PlayerOrigins[ply:SteamID64()] = nil
            end
        end
    end)
end

if CLIENT then
    -- Заглушка для будущего HUD Мавика
    include("dji_mavic_hud.lua") 

    -- ИСПРАВЛЕННЫЙ CalcView - передаем управление самому дрону
    hook.Add("CalcView", "Drones_View", function(ply, pos, ang, fov)
        local drone, dType = GetActiveDrone(ply)
        if IsValid(drone) and drone.CalcView then
            -- Пусть каждый дрон сам управляет своей камерой
            return drone:CalcView(ply, pos, ang, fov)
        end
    end)

    -- Блокировка движения игрока, пока он в дроне
    hook.Add("StartCommand", "Drones_BlockPlayerMove", function(ply, cmd)
        if IsValid(GetActiveDrone(ply)) then
            cmd:ClearMovement()
        end
    end)
    
    -- Отключаем HUD камикадзе для мавика
    hook.Add("HUDShouldDraw", "Mavic_HUD_Control", function(name)
        local ply = LocalPlayer()
        local drone, dType = GetActiveDrone(ply)
        
        if IsValid(drone) and dType == "mavic" then
            -- Отключаем стандартные HUD элементы для мавика
            if name == "CHudHealth" or 
               name == "CHudBattery" or 
               name == "CHudAmmo" or 
               name == "CHudSecondaryAmmo" or
               name == "CHudDamageIndicator" then
                return false
            end
        end
    end)
end

-- Универсальный выход на E
hook.Add("KeyPress", "Drones_GlobalExit", function(ply, key)
    if key == IN_USE and SERVER then
        local drone, dType = GetActiveDrone(ply)
        if IsValid(drone) then
            if dType == "kamikaze" then drone:SetDriver(NULL) end
            if dType == "mavic" and drone.EjectDriver then drone:EjectDriver() end
        end
    end
end)