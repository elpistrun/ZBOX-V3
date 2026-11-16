-- Очистка карты, вывоз 200-х, мародерство оружия и лута :3
ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}
ZBox.Plugins["Cleaner"] = ZBox.Plugins["Cleaner"] or {}
local PLUGIN = ZBox.Plugins["Cleaner"]

PLUGIN.Name = "Cleaner"

PLUGIN.Hooks = {}
local Hook = PLUGIN.Hooks

local CLEANUP_INTERVAL = 220 -- 333 минуты ларп!?7!??!
local ENTITY_LIFETIME = 220 -- 333 минуты ларп!?7!??!

local ragdollSpawnTimes = {}
local weaponSpawnTimes = {}
local isRunning = false

function Hook.OnEntityCreated(ent)
    if ent:GetClass() == "prop_ragdoll" then
        ragdollSpawnTimes[ent] = CurTime()
    elseif ent:IsWeapon() and not ent:IsPlayer() then
        weaponSpawnTimes[ent] = CurTime()
    end
end

function Hook.EntityRemoved(ent)
    if ragdollSpawnTimes[ent] then
        ragdollSpawnTimes[ent] = nil
    end
    if weaponSpawnTimes[ent] then
        weaponSpawnTimes[ent] = nil
    end
end

local function CleanupEntities()
    --// Ragdolls 
    for ragdoll, spawnTime in pairs(ragdollSpawnTimes) do
        if not IsValid(ragdoll) then
            ragdollSpawnTimes[ragdoll] = nil
        elseif CurTime() - spawnTime >= ENTITY_LIFETIME then
            local org = ragdoll.organism 
            if org and org.isPly then
                ragdollSpawnTimes[ragdoll] = CurTime()
                continue
            end
            for _, ent in ipairs(ents.FindInSphere(ragdoll:GetPos(),1000)) do
                if ent:IsPlayer() and ent:Alive() then 
                    ragdollSpawnTimes[ragdoll] = CurTime() 
                    continue 
                end
            end
            ragdoll:Remove()
            ragdollSpawnTimes[ragdoll] = nil
        end
    end
    --// Weapons
    for weapon, spawnTime in pairs(weaponSpawnTimes) do
        if not IsValid(weapon) then
            weaponSpawnTimes[weapon] = nil
        elseif CurTime() - spawnTime >= ENTITY_LIFETIME then
            if IsValid(weapon:GetOwner()) and (weapon:GetOwner():IsPlayer() or weapon:GetOwner():IsNPC()) then
                weaponSpawnTimes[weapon] = CurTime()
                continue 
            end
            for _, ent in ipairs(ents.FindInSphere(weapon:GetPos(),1000)) do
                if ent:IsPlayer() and ent:Alive() then 
                    weaponSpawnTimes[weapon] = CurTime() 
                    continue 
                end
            end
            weapon:Remove()
            weaponSpawnTimes[weapon] = nil
        end
    end
end

-- АВТОЗАПУСК: Запускается сразу при загрузке файла
local function StartCleaner()
    if isRunning then return end
    
    print("[Cleaner] Автозапуск системы очистки...")
    isRunning = true
    
    -- Очищаем старые данные при старте
    ragdollSpawnTimes = {}
    weaponSpawnTimes = {}
    
    -- Регистрируем хуки если их нет
    if not hook.GetTable()["OnEntityCreated"]["Cleaner_OnEntityCreated"] then
        hook.Add("OnEntityCreated", "Cleaner_OnEntityCreated", Hook.OnEntityCreated)
    end
    if not hook.GetTable()["EntityRemoved"]["Cleaner_EntityRemoved"] then
        hook.Add("EntityRemoved", "Cleaner_EntityRemoved", Hook.EntityRemoved)
    end
    
    -- Запускаем таймер
    timer.Create("CleanerTimer", CLEANUP_INTERVAL, 0, CleanupEntities)
    
    -- Первая очистка через 10 секунд после старта
    timer.Simple(10, function()
        print("[Cleaner] Первая плановая очистка...")
        CleanupEntities()
    end)
end

-- Запускаем при загрузке файла
StartCleaner()

-- Также оставляем поддержку ZBox хуков
function Hook.ZBox_Start()
    StartCleaner()
end

function Hook.ZBox_Disable()
    if isRunning then
        timer.Remove("CleanerTimer")
        hook.Remove("OnEntityCreated", "Cleaner_OnEntityCreated")
        hook.Remove("EntityRemoved", "Cleaner_EntityRemoved")
        isRunning = false
        print("[Cleaner] Система очистки остановлена")
    end
end