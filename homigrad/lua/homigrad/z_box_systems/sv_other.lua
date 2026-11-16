// тут я построю анти спавнкилл
util.AddNetworkString("zb_boxnow")
util.AddNetworkString("zb_boxstate")
util.AddNetworkString("zb_boxdata")
util.AddNetworkString("zb_boxstaticdata")
util.AddNetworkString("zb_generalmessage")
util.AddNetworkString("zb_swep_cooldown_update")
util.AddNetworkString("zb_swep_cooldowns")

local player_meta = FindMetaTable("Player")
local zeroVec = Vector(0,0,0)
local DataSpawn = {
    ["active"] = true,
    ["min"] = zeroVec,
    ["max"] = zeroVec,
}

local DataAction = {
    ["RQT: CreateBox"] = function(ply)
        ply:ChatPrint("let's go start box creating! +zoom (default B) = create point, +walk (default ALT) = cancel creating box")
        net.Start("zb_boxstate")
            net.WriteBool(true)
        net.Send(ply)
    end,
    ["RQT: ToggleBox"] = function(ply)
        DataSpawn["active"] = not DataSpawn["active"]
        local msg_to_send = (DataSpawn["active"] == true and "не будут получать урон") or "будут получать урон"
        ply:ChatPrint("Теперь игроки находящиеся в коробке " .. msg_to_send .. ".")
    end,
    ["RQT: GetBox"] = function(ply)
        net.Start("zb_boxstaticdata")
            net.WriteVector(DataSpawn["min"])
            net.WriteVector(DataSpawn["max"])
        net.Send(ply)
        ply:ChatPrint("succesfully get...")
    end,
}

file.CreateDir("zbox_data")
file.CreateDir("zbox_data/anti_spawnkill")

net.Receive("zb_boxnow", function(len,ply)
    if not ply:IsAdmin() then return end
    local action = net.ReadString()
    if DataAction[action] then DataAction[action](ply) end
end)

local function WriteSpawnData(min, max)
    local map = game.GetMap()
    local path = "zbox_data/anti_spawnkill/" .. tostring(map) .. ".txt"
    local data = util.TableToJSON({[1] = min, [2] = max})
    DataSpawn["min"] = min
    DataSpawn["max"] = max
    file.Write(path, data)
end

local function RestoreSpawnData()
    local map = game.GetMap()
    local path = "zbox_data/anti_spawnkill/" .. tostring(map) .. ".txt"
    local data = (file.Exists(path, "DATA") and util.JSONToTable(file.Read(path, "DATA"))) or "NULL:DATA"
    local data_min, data_max = (data != "NULL:DATA" and data[1]) or zeroVec, (data != "NULL:DATA" and data[2]) or zeroVec
    DataSpawn["min"] = data_min
    DataSpawn["max"] = data_max
end

RestoreSpawnData()

net.Receive("zb_boxdata", function(_, ply)
    if not ply:IsAdmin() then return end
    local min = net.ReadVector()
    local max = net.ReadVector()
    WriteSpawnData(min, max)

    timer.Simple(0.5, function()
        net.Start("zb_boxstate")
            net.WriteBool(false)
        net.Send(ply)
    end)

    ply:ChatPrint("ready!")
end)

local entity_in_box = ents.FindInBox
local entity_in_sphere = ents.FindInSphere
local entity_find_by_class = ents.FindByClass
cacheSpawnPoints = cacheSpawnPoints or {}

local function CachePoints()
    local points = entity_find_by_class("info_player_*")
    for p = 1, #points do
        cacheSpawnPoints[#cacheSpawnPoints + 1] = points[p]:GetPos()
    end
end

hook.Add("InitPostEntity", "homigrad-setantispawnkill", CachePoints)
CachePoints()

local PlayersInSpawnZone = PlayersInSpawnZone or {}
local PlayersInSpawnZone_Update = PlayersInSpawnZone_Update or 0
local HasValue = table.HasValue
local insert2 = table.insert

function player_meta:InSpawnZone()
    if not IsValid(self) or not self:Alive() then return false end
    return HasValue(PlayersInSpawnZone, self)
end
hook.Add("Tick", "PlayersInSpawnZone:Insert", function()
    if (CurTime() - PlayersInSpawnZone_Update) < 0.6 then return end
    PlayersInSpawnZone_Update = CurTime()
    PlayersInSpawnZone = {}

    for _, ply in player.Iterator() do
        if not ply:Alive() then continue end
        if not IsValid(ply) then continue end

        if not istable(ply.leave_pointspawn) then
            ply.leave_pointspawn = {false, CurTime()}
        end

        local vBoxMin, vBoxMax = DataSpawn["min"], DataSpawn["max"]
        local entities_in_box = entity_in_box(vBoxMin, vBoxMax)

        if ply.leave_pointspawn[1] ~= true then
            for i = 1, #cacheSpawnPoints do
                local vec = cacheSpawnPoints[i]
                local entities_in_sphere = entity_in_sphere(vec, 150)
                for c = 1, #entities_in_sphere do
                    local ent = entities_in_sphere[c]
                    if not ent:IsRagdoll() and not ent:IsPlayer() then continue end
                    local find_ent = (ent:IsRagdoll() and hg.RagdollOwner(ent)) or ent
                    if ply == find_ent then
                        insert2(PlayersInSpawnZone, ply)
                    end
                end
            end
            if not HasValue(PlayersInSpawnZone, ply) then
                if (CurTime() - ply.leave_pointspawn[2]) > 2 then
                    ply.leave_pointspawn[1] = true
                end
            end
        end

        if DataSpawn["active"] == true then
            for z = 1, #entities_in_box do
                local ent = entities_in_box[z]
                if not ent:IsRagdoll() and not ent:IsPlayer() then continue end
                local find_ent = (ent:IsRagdoll() and hg.RagdollOwner(ent)) or ent
                if ply == find_ent then
                    insert2(PlayersInSpawnZone, ply)
                end
            end
        end
    end
end)

concommand.Add("zb_spawnzone", function(ply)
    if not ply:IsAdmin() then return end
    ply:ChatPrint((ply:InSpawnZone() and "your in spawnzone") or "your not in spawnzone")
end)

-- ========== КУЛДАУНЫ НА ОРУЖИЕ ==========

-- Базовый кулдаун 3 секунды
local DEFAULT_COOLDOWN = 3

-- Особые кулдауны
local CustomDelay = {
    ["weapon_ruger"] = 0.7,
    ["weapon_p22"] = 1.5,
    ["weapon_hg_molotov_tpik"] = 30,
    ["weapon_hg_flashbang_tpik"] = 30,
    ["weapon_hg_rpg"] = 300,
    ["weapon_at4"] = 150,
    ["flaregun_homigrad"] = 105,
    ["weapon_m320gl"] = 600,
    ["weapon_kord"] = 80,
}

-- Оружие без кулдауна
local NoCooldown = {
    ["gmod_tool"] = true,
    ["weapon_physgun"] = true,
}

-- Получить кулдаун
local function GetCooldownTime(class)
    if NoCooldown[class] then return 0 end
    return CustomDelay[class] or DEFAULT_COOLDOWN
end

-- Проверка есть ли оружие у игрока
local function PlayerHasWeapon(ply, class)
    for _, wep in ipairs(ply:GetWeapons()) do
        if IsValid(wep) and wep:GetClass() == class then
            return true
        end
    end
    return false
end

-- Обновить кулдаун
local function UpdateCooldown(ply, class)
    if not IsValid(ply) then return true end
    
    local cdTime = GetCooldownTime(class)
    if cdTime <= 0 then return true end
    
    if not ply.SWEP_Cooldown then 
        ply.SWEP_Cooldown = {} 
    end
    
    local endTime = CurTime() + cdTime
    ply.SWEP_Cooldown[class] = endTime
    
    -- Отправляем клиенту
    net.Start("zb_swep_cooldown_update")
        net.WriteString(class)
        net.WriteFloat(endTime)
    net.Send(ply)
    
    return true
end

-- Проверка кулдауна
local function HasCooldown(ply, class)
    local cdTime = GetCooldownTime(class)
    if cdTime <= 0 then return false end
    
    if not ply.SWEP_Cooldown then return false end
    local endTime = ply.SWEP_Cooldown[class]
    return endTime and endTime > CurTime()
end

-- ХУКИ
hook.Add("PlayerGiveSWEP", "CooldownCheck", function(ply, class, spawninfo)
    if not IsValid(ply) or not ply:Alive() then return true end
    
    -- Если оружие уже есть - пропускаем
    if PlayerHasWeapon(ply, class) then
        return true
    end
    
    if HasCooldown(ply, class) then
        local remaining = math.ceil(ply.SWEP_Cooldown[class] - CurTime())
        ply:ChatPrint("Вы не можете получить это оружие еще " .. remaining .. " секунд!")
        return false
    end
    
    return UpdateCooldown(ply, class)
end)

hook.Add("PlayerSpawnSWEP", "CooldownCheckSpawn", function(ply, class, info)
    if not IsValid(ply) or not ply:Alive() then return true end
    
    if PlayerHasWeapon(ply, class) then
        return true
    end
    
    if HasCooldown(ply, class) then
        local remaining = math.ceil(ply.SWEP_Cooldown[class] - CurTime())
        ply:ChatPrint("Вы не можете получить это оружие еще " .. remaining .. " секунд!")
        return false
    end
    
    return UpdateCooldown(ply, class)
end)

hook.Add("PlayerSpawnedSWEP", "CooldownOnSpawn", function(ply, ent)
    if not IsValid(ply) or not ply:Alive() then return end
    local class = ent:GetClass()
    
    -- Удаляем дубликаты
    local toRemove = {}
    for _, wep in ipairs(ply:GetWeapons()) do
        if IsValid(wep) and wep ~= ent and wep:GetClass() == class then
            table.insert(toRemove, wep)
        end
    end
    for _, wep in ipairs(toRemove) do
        wep:Remove()
    end
    
    UpdateCooldown(ply, class)
end)

-- Отправка кулдаунов при спавне
hook.Add("PlayerSpawn", "SendCooldowns", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        
        net.Start("zb_swep_cooldowns")
            local cooldowns = {}
            if ply.SWEP_Cooldown then
                for class, endTime in pairs(ply.SWEP_Cooldown) do
                    if endTime > CurTime() then
                        cooldowns[class] = endTime
                    end
                end
            end
            -- Ручная отправка таблицы
            net.WriteUInt(table.Count(cooldowns), 16)
            for class, endTime in pairs(cooldowns) do
                net.WriteString(class)
                net.WriteDouble(endTime)
            end
        net.Send(ply)
    end)
end)

-- КОНСОЛЬНЫЕ КОМАНДЫ
concommand.Add("zb_createbox", function(ply)
    if not ply:IsAdmin() then return end
    net.Start("zb_boxnow")
        net.WriteString("RQT: CreateBox")
    net.Send(ply)
    ply:ChatPrint("Режим создания зоны активирован. Нажмите B для установки точек, ALT для отмены.")
end)

concommand.Add("zb_togglebox", function(ply)
    if not ply:IsAdmin() then return end
    net.Start("zb_boxnow")
        net.WriteString("RQT: ToggleBox")
    net.Send(ply)
end)

concommand.Add("zb_getbox", function(ply)
    if not ply:IsAdmin() then return end
    net.Start("zb_boxnow")
        net.WriteString("RQT: GetBox")
    net.Send(ply)
end)

concommand.Add("zb_resetcooldowns", function(ply)
    if not ply:IsAdmin() then return end
    if ply.SWEP_Cooldown then
        ply.SWEP_Cooldown = {}
        ply:ChatPrint("Все кулдауны сброшены")
        
        net.Start("zb_swep_cooldowns")
            net.WriteUInt(0, 16)
        net.Send(ply)
    end
end)

concommand.Add("zb_setcooldown", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local class = args[1]
    local seconds = tonumber(args[2])
    
    if not class or not seconds then
        ply:ChatPrint("Использование: zb_setcooldown [класс] [секунды]")
        return
    end
    
    CustomDelay[class] = seconds
    ply:ChatPrint("Установлен кулдаун " .. seconds .. " сек на " .. class)
end)

-- ВИЗУАЛИЗАЦИЯ ДЛЯ АДМИНОВ
if CLIENT then
    local showBox = CreateClientConVar("zb_showbox", "1", true, false, "Показывать зону защиты")
    
    net.Receive("zb_boxstaticdata", function()
        DataSpawn = DataSpawn or {}
        DataSpawn["min"] = net.ReadVector()
        DataSpawn["max"] = net.ReadVector()
    end)
    
    net.Receive("zb_boxstate", function()
        local state = net.ReadBool()
        if DataSpawn then
            DataSpawn["active"] = state
        end
    end)
    
    hook.Add("PostDrawTranslucentRenderables", "ZBox_Draw", function()
        if not showBox:GetBool() then return end
        if not LocalPlayer():IsAdmin() then return end
        if not DataSpawn then return end
        
        local min = DataSpawn["min"]
        local max = DataSpawn["max"]
        
        if min == Vector(0,0,0) and max == Vector(0,0,0) then return end
        
        local center = (min + max) / 2
        local size = max - min
        
        local color = DataSpawn["active"] and Color(0, 255, 0, 50) or Color(255, 0, 0, 50)
        local outline = DataSpawn["active"] and Color(0, 255, 0, 255) or Color(255, 0, 0, 255)
        
        render.SetColorMaterial()
        render.DrawBox(center, Angle(0,0,0), size * -0.5, size * 0.5, color, false)
        
        local corners = {
            {min, Vector(min.x, min.y, max.z)},
            {min, Vector(min.x, max.y, min.z)},
            {min, Vector(max.x, min.y, min.z)},
            {max, Vector(max.x, max.y, min.z)},
            {max, Vector(max.x, min.y, max.z)},
            {max, Vector(min.x, max.y, max.z)},
        }
        
        for _, edge in ipairs(corners) do
            render.DrawLine(edge[1], edge[2], outline, true)
        end
    end)
    
    concommand.Add("zb_showbox", function(ply, _, args)
        if not ply:IsAdmin() then return end
        local val = tonumber(args[1])
        if val ~= nil then
            RunConsoleCommand("zb_showbox", val)
            ply:ChatPrint("Отображение зоны: " .. (val == 1 and "ВКЛ" or "ВЫКЛ"))
        else
            ply:ChatPrint("zb_showbox 1 - включить, zb_showbox 0 - выключить")
        end
    end)
    
    -- КЛИЕНТСКАЯ ЧАСТЬ КУЛДАУНОВ
    local SwepCooldowns = {}
    
    net.Receive("zb_swep_cooldowns", function()
        local count = net.ReadUInt(16)
        SwepCooldowns = {}
        for i = 1, count do
            local class = net.ReadString()
            local endTime = net.ReadDouble()
            SwepCooldowns[class] = endTime
        end
    end)
    
    net.Receive("zb_swep_cooldown_update", function()
        local class = net.ReadString()
        local endTime = net.ReadFloat()
        SwepCooldowns[class] = endTime
    end)
    
    function GetSwepCooldown(class)
        local endTime = SwepCooldowns[class]
        if endTime and endTime > CurTime() then
            return math.ceil(endTime - CurTime())
        end
        return 0
    end
end