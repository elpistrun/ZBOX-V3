-- ============================================================================
-- vFire Potato Mode Optimizations (CLIENT ONLY)
-- Использует отдельные ConVar для управления
-- ============================================================================

if SERVER then return end

local function IsFireLimitEnabled()
    return GetConVarNumber("hg_opt_fire_limit_enabled") == 1
end

local function GetFireLimitAmount()
    local manual = GetConVarNumber("hg_opt_fire_limit_amount")
    if manual > 0 then
        return manual
    end
    return 0
end

local function GetFireLimitFromTable(realCount)
    local manual = GetFireLimitAmount()
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

local function IsHighQualityFire()
    return GetConVarNumber("hg_opt_fire_quality") >= 2
end

local function IsLowQualityFire()
    return GetConVarNumber("hg_opt_fire_quality") == 1
end

local function IsFireDlightEnabled()
    return GetConVarNumber("hg_opt_fire_dlight") == 1
end

local function IsFireGlowEnabled()
    return GetConVarNumber("hg_opt_fire_glow") == 1
end

-- Оптимизация VFire (огонь)
local function OptimizeVFire()
    local vfireClass = scripted_ents.GetStored("vfire")
    if not vfireClass or not vfireClass.t then return end
    
    local ENT = vfireClass.t
    
    if not ENT._origRedoParticles then
        ENT._origRedoParticles = ENT.RedoParticles
    end
    if not ENT._origDraw then
        ENT._origDraw = ENT.Draw
    end
    if not ENT._origThink then
        ENT._origThink = ENT.Think
    end
    if not ENT._origParticlesThink then
        ENT._origParticlesThink = ENT.ParticlesThink
    end
    if not ENT._origAnimationThink then
        ENT._origAnimationThink = ENT.AnimationThink
    end
    
    -- Переопределяем RedoParticles
    function ENT:RedoParticles(state)
        if not IsValid(self) then return end
        
        local isLowQuality = IsLowQualityFire()
        self.visState = state

        if self.flames and self.flames:IsValid() then
            self.flames:StopEmission()
        end

        local size = vFireStateToSize(state)
        local LODStr = ""
        
        if self.LOD or isLowQuality then
            LODStr = "_LOD"
            self.visLOD = true
        else
            self.visLOD = false
        end

        self.flames = CreateParticleSystem(
            self,
            "vFire_Flames_"..size..LODStr,
            1,
            0,
            Vector(0, 0, 0)
        )
        
        -- Высокое качество: создаём базу
        if IsHighQualityFire() and not isLowQuality then
            if self.base and self.base:IsValid() then
                self.base:StopEmission()
            end
            local forward = self:GetForward()
            self.base = CreateParticleSystem(
                self,
                "vFire_Base_"..size..LODStr,
                0,
                0,
                forward * (state - 1)
            )
        end
    end
    
    -- Отключаем Draw если нужно
    function ENT:Draw()
        if not IsFireDlightEnabled() and not IsFireGlowEnabled() then
            return
        end
        
        if self._origDraw then
            self:_origDraw()
        end
    end
    
    -- Упрощаем Think
    function ENT:Think()
        if not IsFireLimitEnabled() then
            if self._origThink then
                return self:_origThink()
            end
        end
        
        local curTime = CurTime()
        local throttleAdd = self:IsPrioritized() and 0 or vFireThinkThrottle

        if curTime >= self.nextClusterThink then
            self:ClusterThink()
            self.nextClusterThink = curTime + vFireClusterThinkTickRate + throttleAdd
        end

        if curTime >= self.nextParticlesThink then
            self:ParticlesThink()
            self.nextParticlesThink = curTime + vFireParticlesThinkTickRate + throttleAdd
        end

        if curTime >= self.nextAnimationThink then
            self:AnimationThink()
            self.nextAnimationThink = curTime + vFireAnimationThinkTickRate + throttleAdd
        end
        
        local thinkRate = math.Min(self.nextClusterThink, self.nextParticlesThink, self.nextAnimationThink) - curTime
        if IsLowQualityFire() then
            thinkRate = math.max(thinkRate, 0.5)
        end
        
        local ranTime = math.Rand(-0.1, 0.1)
        self:SetNextClientThink(curTime + thinkRate + ranTime)
        return true
    end
    
    -- ParticlesThink с учётом качества
    function ENT:ParticlesThink()
        if self._origParticlesThink then
            self:_origParticlesThink()
        end
        
        if not IsFireLimitEnabled() then
            return
        end
        
        local isLowQuality = IsLowQualityFire()
        self.LOD = isLowQuality
    end
    
    -- AnimationThink с учётом качества
    function ENT:AnimationThink()
        if IsLowQualityFire() then
            return
        end
        
        if self._origAnimationThink then
            self:_origAnimationThink()
        end
    end
    
    -- ClusterThink с лимитом огней
    function ENT:ClusterThink()
        local netCluster = self:GetNW2Entity("FireCluster")
        if IsValid(netCluster) and netCluster.AddFire then
            if not self.cluster or self.cluster != netCluster then
                netCluster:AddFire(self)
            end
        end
        
        if not IsFireLimitEnabled() then
            return
        end
        
        if IsValid(self.cluster) then
            local totalFires = 0
            for _ in pairs(self.cluster.fires) do
                totalFires = totalFires + 1
            end
            
            local limit = GetFireLimitFromTable(totalFires)
            
            local fires = {}
            for fire, _ in pairs(self.cluster.fires) do
                if IsValid(fire) then
                    table.insert(fires, fire)
                end
            end
            
            table.sort(fires, function(a, b)
                return (a:GetFireState() or 0) > (b:GetFireState() or 0)
            end)
            
            for i, fire in ipairs(fires) do
                if i > limit then
                    fire.hiddenForPotato = true
                    if fire.flames and fire.flames:IsValid() then
                        fire.flames:StopEmission()
                    end
                else
                    fire.hiddenForPotato = false
                end
            end
        end
    end
end

-- Восстановление оригиналов
local function RevertOptimizations()
    local vfireClass = scripted_ents.GetStored("vfire")
    if vfireClass and vfireClass.t then
        local ENT = vfireClass.t
        if ENT._origRedoParticles then
            ENT.RedoParticles = ENT._origRedoParticles
        end
        if ENT._origDraw then
            ENT.Draw = ENT._origDraw
        end
        if ENT._origThink then
            ENT.Think = ENT._origThink
        end
        if ENT._origParticlesThink then
            ENT.ParticlesThink = ENT._origParticlesThink
        end
        if ENT._origAnimationThink then
            ENT.AnimationThink = ENT._origAnimationThink
        end
    end
end

-- Следим за настройками
local function UpdateVFireOptimizations()
    local fireLimitEnabled = GetConVarNumber("hg_opt_fire_limit_enabled") == 1
    local fireQuality = GetConVarNumber("hg_opt_fire_quality")
    
    if fireLimitEnabled or fireQuality <= 1 then
        OptimizeVFire()
    else
        RevertOptimizations()
    end
end

-- Применяем при загрузке
timer.Simple(0.5, function()
    UpdateVFireOptimizations()
end)

-- Следим за изменениями в настройках
cvars.AddChangeCallback("hg_opt_fire_limit_enabled", function() UpdateVFireOptimizations() end)
cvars.AddChangeCallback("hg_opt_fire_limit_amount", function() UpdateVFireOptimizations() end)
cvars.AddChangeCallback("hg_opt_fire_quality", function() UpdateVFireOptimizations() end)