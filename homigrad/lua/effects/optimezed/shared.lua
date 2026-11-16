
if SERVER then return end

local ConVars = {
    explosionsEnabled = GetConVar("hg_opt_explosions_enabled"),
    fireLimitEnabled = GetConVar("hg_opt_fire_limit_enabled"),
    fireLimitAmount = GetConVar("hg_opt_fire_limit_amount"),
    fireQuality = GetConVar("hg_opt_fire_quality"),
    fireDlight = GetConVar("hg_opt_fire_dlight"),
    fireGlow = GetConVar("hg_opt_fire_glow"),
}

function HG_GetEffectQuality(effectType, pos)
    if not ConVars.explosionsEnabled or ConVars.explosionsEnabled:GetBool() == false then
        return 0
    end
    
    local quality = 2
    
    if effectType == "fire" then
        quality = ConVars.fireQuality and ConVars.fireQuality:GetInt() or 2
    end

    if pos and vFireGetLOD then
        local lod = vFireGetLOD(pos)
        if lod >= 3 then
            quality = 1
        elseif lod >= 4 then
            quality = 0
        end
    end
    
    return quality
end

function HG_LimitParticles(count, effectType)
    local maxParticles = 200
    
    if effectType == "fire" then
        maxParticles = math.min(maxParticles, 80)
    elseif effectType == "smoke" then
        maxParticles = math.min(maxParticles, 100)
    elseif effectType == "impact" then
        maxParticles = math.min(maxParticles, 50)
    end
    
    return math.min(count, maxParticles)
end

function HG_ShouldCreateDLight()
    return ConVars.fireDlight and ConVars.fireDlight:GetBool()
end

function HG_ShouldCreateGlow()
    return ConVars.fireGlow and ConVars.fireGlow:GetBool()
end

function HG_ShouldLimitFires()
    return ConVars.fireLimitEnabled and ConVars.fireLimitEnabled:GetBool()
end

function HG_GetFireLimit(realCount)
    local manual = ConVars.fireLimitAmount and ConVars.fireLimitAmount:GetInt() or 0
    if manual > 0 then
        return manual
    end
    
    local mapping = {
        {1, 1}, {2, 2}, {3, 2}, {4, 3}, {5, 4},
        {6, 4}, {7, 5}, {8, 6}, {9, 6}, {10, 6},
        {11, 7}, {12, 7}, {13, 8}, {14, 8}, {15, 9},
        {16, 10}, {17, 12}, {18, 14}, {19, 15}, {20, 15},
        {21, 18}, {22, 18}, {23, 18}, {24, 19}, {25, 20}
    }
    
    for _, pair in ipairs(mapping) do
        if realCount <= pair[1] then
            return pair[2]
        end
    end
    return 20
end


local function CreateOptimizedFire(data)
    local quality = HG_GetEffectQuality("fire", data:GetOrigin())
    if quality == 0 then return end
    
    local SelfPos = data:GetOrigin()
    local Radius = data:GetRadius()
    
    if self and self:WaterLevel and self:WaterLevel() >= 2 then return end

    if HG_ShouldCreateDLight() and quality >= 2 and math.random(5) > 3 then
        local dlight = DynamicLight(self and self:EntIndex() or math.random(1, 10000))
        if dlight then
            dlight.Pos = SelfPos
            dlight.r = 245
            dlight.g = 125
            dlight.b = 15
            dlight.Brightness = 4
            dlight.Size = Radius * 1.5
            dlight.Decay = 0
            dlight.DieTime = CurTime() + 0.5
            dlight.Style = 0
        end
    end
    
    local Emitter = ParticleEmitter(SelfPos)
    if not Emitter then return end
    
    local particleCount = 0
    if quality == 1 then
        particleCount = math.max(3, math.floor(Radius / 50))
    elseif quality == 2 then
        particleCount = math.max(5, math.floor(Radius / 25))
    else
        particleCount = math.max(8, math.floor(Radius / 15))
    end
    
    particleCount = HG_LimitParticles(particleCount, "fire")
    local useCollision = quality >= 2
    
    for i = 0, particleCount do
        local sprite = "sprites/flamelet" .. math.random(1, 5)
        local particle = Emitter:Add(sprite, SelfPos)
        if particle then
            if quality == 1 then
                particle:SetVelocity(5000 * VectorRand())
                particle:SetGravity(Vector(0, 0, math.random(150, 200)))
            else
                particle:SetVelocity(8000 * VectorRand())
                particle:SetGravity(Vector(0, 0, math.random(200, 300)))
            end
            
            particle:SetAirResistance(0)
            particle:SetDieTime(quality == 1 and 0.1 or 0.15)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(255)
            particle:SetStartSize(1)
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(-3, 3))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetLighting(false)
            
            local darg = math.Rand(150, 255)
            particle:SetColor(darg, darg, darg)
            
            if useCollision then
                particle:SetCollide(true)
                particle:SetBounce(0.01)
            end
        end
    end
    
    Emitter:Finish()
end

local oldFireInit = EFFECT and EFFECT.Init or nil
if not oldFireInit then
    EFFECT = {}
    function EFFECT:Init(data)
        CreateOptimizedFire(data)
    end
    function EFFECT:Think() return false end
    function EFFECT:Render() end
end