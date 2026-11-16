--
local ExplosiveSound = {
    Fire = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_incendiary_ground_sm2"
    },
    Sharpnel = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_groundsplode_medium"
    },
    Normal = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"},
        Effect = "pcf_jack_groundsplode_small"
    }
}

-- Накопление взрывов
local explosionQueue = {}
local explosionProcessTime = 0
local EXPLOSION_WINDOW = 0.15

-- Функция для расчёта визуального эффекта
local function GetVisualEffect(count, expType)
    if count <= 2 then
        return ExplosiveSound[expType].Effect, 1.0
    elseif count <= 7 then
        return "pcf_jack_groundsplode_medium", 1.2
    elseif count <= 15 then
        return "pcf_jack_groundsplode_medium", 1.5
    else
        return "pcf_jack_incendiary_ground_sm2", 2.0
    end
end

-- Обработка накопленных взрывов
local function ProcessExplosionQueue()
    if #explosionQueue == 0 then return end
    
    local optimizeExplosions = GetConVarNumber("hg_opt_explosions_enabled") == 1
    
    local posSum = Vector(0, 0, 0)
    local countByType = {Fire = 0, Sharpnel = 0, Normal = 0}
    
    for _, exp in ipairs(explosionQueue) do
        posSum = posSum + exp.pos
        countByType[exp.type] = countByType[exp.type] + 1
    end
    
    local dominantType = "Normal"
    local maxCount = 0
    for type, count in pairs(countByType) do
        if count > maxCount then
            maxCount = count
            dominantType = type
        end
    end
    
    local centerPos = posSum / #explosionQueue
    local totalCount = #explosionQueue
    
    if optimizeExplosions then
        -- Группируем взрывы
        local effectName, scale = GetVisualEffect(totalCount, dominantType)
        
        local effectCount = math.min(totalCount, 3)
        
        for i = 1, effectCount do
            local offset = VectorRand(-30, 30) * scale
            if i == 1 then
                ParticleEffect(effectName, centerPos, vector_up:Angle())
            else
                ParticleEffect(effectName, centerPos + offset, vector_up:Angle())
            end
        end
    else
        -- Показываем каждый взрыв отдельно
        for _, exp in ipairs(explosionQueue) do
            ParticleEffect(ExplosiveSound[exp.type].Effect, exp.pos, vector_up:Angle())
        end
    end
    
    -- Звук взрыва (один на группу)
    local farSound = table.Random(ExplosiveSound[dominantType].Far)
    local nearSound = table.Random(ExplosiveSound[dominantType].Near)
    
    local view = render.GetViewSetup(true)
    local time = centerPos:Distance(view.origin) / 17836
    
    timer.Simple(time, function()
        EmitSound(farSound, centerPos, 0, CHAN_WEAPON, 0.8, 100, 0, 100, 0, nil)
        if time < 0.6 then
            EmitSound(nearSound, centerPos, 0, CHAN_AUTO, 1.0, 110, 0, 100, 0, nil)
        end
    end)
    
    -- Тряска камеры
    if centerPos:Distance(view.origin) < 500 then
        local shakeIntensity = math.min(50 + totalCount * 2, 150)
        util.ScreenShake(centerPos, shakeIntensity, shakeIntensity * 3, 1, 1500)
    end
    
    explosionQueue = {}
end

-- Приём взрыва от сервера
net.Receive("hg_booom", function()
    local pos = net.ReadVector()
    local expType = net.ReadString()
    
    table.insert(explosionQueue, {
        pos = pos,
        type = expType,
        time = CurTime()
    })
    
    timer.Simple(EXPLOSION_WINDOW, function()
        if #explosionQueue > 0 then
            ProcessExplosionQueue()
        end
    end)
end)

hook.Add("InitPostEntity", "HG_ClearExplosionQueue", function()
    explosionQueue = {}
end)