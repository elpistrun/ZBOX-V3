-- Trimming (Блуждающая Плоть) - ИСПРАВЛЕННАЯ ВЕРСИЯ
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Vita Carnis: Trimming"
ENT.Author = "Your Name"
ENT.Category = "JMod - EZ Anomalies"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.NoSitAllowed = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.JModEZstorable = false
ENT.JModEZremoveOnBlackout = false
---
local STATE_IDLE, STATE_AGGRO, STATE_ATTACK = 0, 1, 2
local ATTACH_NONE, ATTACH_PARASITE = 0, 1

---
if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/watermelon01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
        
        self:SetMaterial("models/flesh")
        self:SetColor(Color(180, 40, 40, 255))
        self:SetModelScale(0.33, 0)

        -- JMod переменные
        self.EZID = "VitaCarnis-Trimming"
        self.EZowner = nil
        self.JModFriends = {}
        self.EZspinMe = false

        -- Состояние
        self.State = STATE_IDLE
        self.NextActionTime = 0
        self.AggroTarget = nil
        self.SpawnTime = CurTime()
        self.IsMature = false
        self.Restlessness = 1
        self.NextBiteTime = 0
        self.HasBeenHit = false
        
        -- СИСТЕМА ПАРАЗИТИРОВАНИЯ
        self.AttachedPlayer = nil
        self.AttachType = ATTACH_NONE
        self.AttachStartTime = 0
        self.NextDrainTime = 0
        self.DrainAmount = 0
        self.OriginalSpeeds = {walk = 200, run = 400}
        self.AttachOffset = Vector(0, 0, 0) -- Смещение для прикрепления
        
        -- БЫСТРОЕ РАЗМНОЖЕНИЕ
        self.NextReproductionTime = CurTime() + 45
        self.ReproductionCooldown = false
        self.ReproductionBoost = 0
        
        -- Для звуков
        self.NextSoundTime = 0
        self.LastMoveSound = 0
        self.NextHeartbeat = 0

        local Phys = self:GetPhysicsObject()
        if IsValid(Phys) then
            Phys:SetMass(15)
            Phys:SetDamping(2, 3)
            Phys:Wake()
        end

        -- Для синхронизации с клиентом
        self:SetNW2Float("PulsePhase", math.Rand(0, 10))
        self:SetNW2Int("State", STATE_IDLE)
        self:SetNW2Bool("Alive", true)
        self:SetNW2Bool("Reproducing", false)
        self:SetNW2Int("AttachType", ATTACH_NONE)
        
        print("[JMod] Vita Carnis Trimming spawned")
        
        -- Запускаем таймер размножения
        self:StartReproductionCycle()
        
        -- ВАЖНО: Устанавливаем позицию на землю
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:SnapToGround()
            end
        end)
    end

    -- ФИКС: УСТАНОВКА НА ЗЕМЛЮ
    function ENT:SnapToGround()
        local trace = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 50),
            endpos = self:GetPos() - Vector(0, 0, 100),
            filter = self,
            mask = MASK_SOLID
        })
        
        if trace.Hit then
            self:SetPos(trace.HitPos + Vector(0, 0, 5))
            local phys = self:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
            end
        end
    end

    function ENT:StartReproductionCycle()
        timer.Create("TrimmingReproduce_" .. self:EntIndex(), 45 - self.ReproductionBoost, 0, function()
            if IsValid(self) and not self.HasBeenHit and not self.ReproductionCooldown then
                self:ReproduceByBudding()
            end
        end)
    end

    function ENT:UpdateReproductionTimer()
        timer.Remove("TrimmingReproduce_" .. self:EntIndex())
        if not self.HasBeenHit then
            self:StartReproductionCycle()
        end
    end

    function ENT:ReproduceByBudding()
        if self.HasBeenHit then return end
        
        self.ReproductionCooldown = true
        self:SetNW2Bool("Reproducing", true)
        
        -- Ускоренное размножение при паразитировании
        local spawnCount = 1
        if self.AttachType == ATTACH_PARASITE then
            spawnCount = math.random(2, 3)
        else
            spawnCount = math.random(1, 2)
        end
        
        -- Эффект почкования
        self:EmitSound("ambient/water/water_spray" .. math.random(1, 3) .. ".wav", 65, 90)
        self:EmitSound("physics/flesh/flesh_squishy_impact_soft" .. math.random(1, 3) .. ".wav", 60, 100)
        
        -- Визуальные изменения
        self:SetColor(Color(200, 60, 60, 255))
        
        -- Создаём новых Trimming через 2 секунды
        timer.Simple(2, function()
            if IsValid(self) and not self.HasBeenHit then
                local spawnPos = self:GetPos()
                
                for i = 1, spawnCount do
                    local offset = Vector(math.random(-30, 30), math.random(-30, 30), 0)
                    local newTrimming = ents.Create("ent_jack_gmod_ezanomaly_trimming")
                    
                    if IsValid(newTrimming) then
                        local spawnLocation = spawnPos + offset
                        
                        -- ФИКС: Проверяем свободное место для спавна
                        local trace = util.TraceLine({
                            start = spawnLocation + Vector(0, 0, 50),
                            endpos = spawnLocation - Vector(0, 0, 100),
                            filter = self,
                            mask = MASK_SOLID
                        })
                        
                        if trace.Hit then
                            spawnLocation = trace.HitPos + Vector(0, 0, 5)
                        end
                        
                        newTrimming:SetPos(spawnLocation)
                        newTrimming:SetAngles(Angle(0, math.random(0, 360), 0))
                        newTrimming:Spawn()
                        
                        -- ВАЖНО: Переинициализируем физику для нового ентити
                        timer.Simple(0, function()
                            if IsValid(newTrimming) then
                                newTrimming:PhysicsInit(SOLID_VPHYSICS)
                                newTrimming:SetMoveType(MOVETYPE_VPHYSICS)
                                newTrimming:SetSolid(SOLID_VPHYSICS)
                                
                                local newPhys = newTrimming:GetPhysicsObject()
                                if IsValid(newPhys) then
                                    newPhys:SetMass(15)
                                    newPhys:SetDamping(2, 3)
                                    newPhys:Wake()
                                end
                                
                                newTrimming:SnapToGround()
                            end
                        end)
                        
                        -- Новые особи сразу зрелые
                        newTrimming.IsMature = true
                        newTrimming:SetColor(Color(140, 20, 20, 255))
                        
                        -- Если родитель паразитирует
                        if self.AttachType == ATTACH_PARASITE then
                            newTrimming.ReproductionBoost = 15
                        end
                        
                        -- Эффект рождения
                        local effectdata = EffectData()
                        effectdata:SetOrigin(spawnLocation)
                        effectdata:SetScale(0.6)
                        util.Effect("BloodImpact", effectdata)
                        
                        newTrimming:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 70, 110)
                    end
                end
                
                -- Звуки завершения
                self:EmitSound("physics/flesh/flesh_bloody_break.wav", 75, 85)
                self:EmitSound("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", 70, 100)
                
                -- Возвращаем цвет
                self:SetColor(Color(180, 40, 40, 255))
                self:SetNW2Bool("Reproducing", false)
                
                -- Перерыв
                local cooldown = self.AttachType == ATTACH_PARASITE and 10 or 20
                
                timer.Simple(cooldown, function()
                    if IsValid(self) then
                        self.ReproductionCooldown = false
                    end
                end)
            end
        end)
    end

    function ENT:PhysicsCollide(data, physobj)
        if data.DeltaTime > 0.2 and data.Speed > 50 then
            self:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(1, 5) .. ".wav", 60, math.random(90, 110))
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
        
        local damageAmount = dmginfo:GetDamage()
        
        if damageAmount > 0 and not self.HasBeenHit then
            self.HasBeenHit = true
            self:SetNW2Bool("Alive", false)
            
            timer.Remove("TrimmingReproduce_" .. self:EntIndex())
            self:DetachFromPlayer()
            self:DeathEffects(dmginfo:GetDamageType(), dmginfo:GetAttacker(), dmginfo:GetInflictor())
            
            timer.Simple(0.5, function()
                if IsValid(self) then
                    self:Remove()
                end
            end)
            
            return
        end
    end

    function ENT:DeathEffects(dmgType, attacker, inflictor)
        self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 75, 100)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(0.5)
        util.Effect("BloodImpact", effectdata)
        
        if self.AttachedPlayer and IsValid(self.AttachedPlayer) then
            self.AttachedPlayer:SetWalkSpeed(self.OriginalSpeeds.walk or 200)
            self.AttachedPlayer:SetRunSpeed(self.OriginalSpeeds.run or 400)
            self.AttachedPlayer:ChatPrint("[Trimming] Паразит уничтожен! Вы свободны.")
        end
    end

    function ENT:Use(activator)
        if activator:IsPlayer() then
            local Time = CurTime()
            if self.NextBiteTime < Time then
                self.NextBiteTime = Time + math.Rand(1, 2)
                
                sound.Play("npc/headcrab/headbite.wav", self:GetPos(), 120, math.random(90, 110))
                
                timer.Simple(0.1, function()
                    if not IsValid(self) or not IsValid(activator) then return end
                    
                    local dmg = DamageInfo()
                    dmg:SetDamage(math.random(3, 5))
                    dmg:SetDamageType(DMG_SLASH)
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageForce(Vector(0, 0, 10))
                    dmg:SetDamagePosition(activator:GetPos())
                    activator:TakeDamageInfo(dmg)
                    
                    if math.random(1, 10) <= 7 then
                        self:AttachAsParasite(activator)
                    end
                    
                    self.Restlessness = self.Restlessness + 1
                    
                    if math.random(1, 3) == 1 then
                        self.AggroTarget = activator
                        self.State = STATE_AGGRO
                        self:SetNW2Int("State", STATE_AGGRO)
                    end
                end)
            end
        end
    end

    -- ФИКС ПРИСАСЫВАНИЯ: правильное позиционирование
    function ENT:AttachAsParasite(ply)
        if self.AttachedPlayer or not IsValid(ply) then return end
        
        self.AttachedPlayer = ply
        self.AttachType = ATTACH_PARASITE
        self.AttachStartTime = CurTime()
        self.NextDrainTime = CurTime() + 2
        self.DrainAmount = 0
        
        -- ФИКС: Сохраняем ТЕКУЩИЕ скорости, а не стандартные
        self.OriginalSpeeds.walk = ply:GetWalkSpeed()
        self.OriginalSpeeds.run = ply:GetRunSpeed()
        
        -- ФИКС: Блокировка движения через SetVelocity
        ply:SetWalkSpeed(1)
        ply:SetRunSpeed(1)
        
        -- Также блокируем движение через velocity
        if ply:GetVelocity():Length() > 0 then
            ply:SetVelocity(Vector(0, 0, 0))
        end
        
        -- Эффекты
        self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 80, 100)
        self:EmitSound("npc/headcrab/headbite.wav", 85, 90)
        
        ply:ChatPrint("[Trimming] ПАРАЗИТ ПРИСОСАЛСЯ! Вы не можете двигаться!")
        
        -- ФИКС: Прикрепляем с правильным смещением
        -- Получаем позицию на теле игрока (случайное место)
        local attachBones = {
            "ValveBiped.Bip01_Spine2", -- Спина
            "ValveBiped.Bip01_Head1",  -- Голова
            "ValveBiped.Bip01_L_UpperArm", -- Левое плечо
            "ValveBiped.Bip01_R_UpperArm", -- Правое плечо
        }
        
        local boneName = attachBones[math.random(1, #attachBones)]
        local boneID = ply:LookupBone(boneName)
        
        if boneID then
            local bonePos, boneAng = ply:GetBonePosition(boneID)
            if bonePos then
                -- Прикрепляем к кости
                self:SetParent(ply)
                self:FollowBone(ply, boneID)
                
                -- Случайное смещение относительно кости
                self.AttachOffset = Vector(
                    math.random(-5, 5),
                    math.random(-5, 5),
                    math.random(0, 10)
                )
                
                local localPos = self.AttachOffset
                self:SetLocalPos(localPos)
                self:SetLocalAngles(Angle(math.random(-20, 20), math.random(0, 360), math.random(-20, 20)))
            else
                -- Запасной вариант: прикрепляем к центру
                self:SetParent(ply)
                self.AttachOffset = Vector(0, 0, 30)
                self:SetLocalPos(self.AttachOffset)
            end
        else
            -- Если не нашли кость, прикрепляем к позиции игрока
            self:SetParent(ply)
            self.AttachOffset = Vector(0, 0, 30)
            self:SetLocalPos(self.AttachOffset)
        end
        
        self:SetMoveType(MOVETYPE_NONE)
        
        -- Ускорение размножения
        self.ReproductionBoost = 20
        self:UpdateReproductionTimer()
        
        self:SetNW2Int("AttachType", ATTACH_PARASITE)
        
        print("[JMod] Trimming attached as parasite to ", ply:Nick(), " at offset ", self.AttachOffset)
    end

    function ENT:DetachFromPlayer()
        if not IsValid(self.AttachedPlayer) then return end
        
        local ply = self.AttachedPlayer
        
        -- ФИКС: Восстанавливаем скорость через таймер
        timer.Simple(0, function()
            if IsValid(ply) and ply:Alive() then
                ply:SetWalkSpeed(self.OriginalSpeeds.walk or 200)
                ply:SetRunSpeed(self.OriginalSpeeds.run or 400)
                
                if self.AttachType == ATTACH_PARASITE then
                    ply:ChatPrint("[Trimming] Паразит открепился! Вы можете двигаться.")
                end
            end
        end)
        
        -- Открепляем
        self:SetParent(nil)
        self:StopFollowingBone()
        self:SetMoveType(MOVETYPE_VPHYSICS)
        
        -- ФИКС: Сбрасываем позицию на землю
        local currentPos = self:GetPos()
        local trace = util.TraceLine({
            start = currentPos + Vector(0, 0, 50),
            endpos = currentPos - Vector(0, 0, 100),
            filter = {self, ply},
            mask = MASK_SOLID
        })
        
        if trace.Hit then
            self:SetPos(trace.HitPos + Vector(0, 0, 5))
        end
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        
        -- Сбрасываем ускорение
        self.ReproductionBoost = 0
        self:UpdateReproductionTimer()
        
        self.AttachedPlayer = nil
        self.AttachType = ATTACH_NONE
        self:SetNW2Int("AttachType", ATTACH_NONE)
        
        print("[JMod] Trimming detached from player")
    end

    function ENT:IsBeingWatched()
        if self.HasBeenHit then return false end
        if self.AttachType == ATTACH_PARASITE then return false end
        
        local selfPos = self:GetPos() + Vector(0, 0, 5)
        for _, ply in pairs(player.GetAll()) do
            if ply:Alive() then
                local gazeDir = (selfPos - ply:GetShootPos()):GetNormalized()
                local eyeDir = ply:EyeAngles():Forward()
                local dot = gazeDir:Dot(eyeDir)
                
                if dot > 0.85 then
                    local trace = util.TraceLine({
                        start = ply:GetShootPos(),
                        endpos = selfPos,
                        filter = {ply, self},
                        mask = MASK_SHOT
                    })
                    if not trace.Hit then
                        return true
                    end
                end
            end
        end
        return false
    end

    function ENT:Attack(target)
        if self.HasBeenHit then return end
        if not IsValid(target) or not target:Alive() then return end
        if self.NextActionTime > CurTime() then return end

        self.State = STATE_ATTACK
        self:SetNW2Int("State", STATE_ATTACK)
        self.NextActionTime = CurTime() + 1.5

        local dir = (target:GetPos() - self:GetPos()):GetNormalized()
        dir.z = dir.z + 0.3
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceCenter(dir * 3000)
        end

        self:EmitSound("npc/headcrab/attack" .. math.random(1, 3) .. ".wav", 65, 100)

        timer.Simple(0.3, function()
            if not IsValid(self) or not IsValid(target) then return end
            
            local dist = self:GetPos():Distance(target:GetPos())
            if dist < 50 then
                local dmg = DamageInfo()
                dmg:SetDamage(8)
                dmg:SetDamageType(DMG_SLASH)
                dmg:SetAttacker(self)
                dmg:SetInflictor(self)
                dmg:SetDamageForce(dir * 1000)
                dmg:SetDamagePosition(target:GetPos())
                target:TakeDamageInfo(dmg)
                
                self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 70, 110)
                target:ViewPunch(Angle(-5, math.random(-5, 5), 0))
                
                if math.random(1, 10) <= 6 and target:IsPlayer() then
                    self:AttachAsParasite(target)
                end
            end
        end)
    end

    function ENT:Think()
        if self.HasBeenHit then return end
        
        local time = CurTime()

        -- Созревание
        if not self.IsMature and time > self.SpawnTime + 15 then
            self.IsMature = true
            self:SetColor(Color(140, 20, 20, 255))
            self:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 45, 120)
        end

        -- ПАРАЗИТИЧЕСКОЕ ВЫСАСЫВАНИЕ
        if self.AttachType == ATTACH_PARASITE and IsValid(self.AttachedPlayer) then
            local ply = self.AttachedPlayer
            
            -- ФИКС: Дополнительная блокировка движения
            if ply:GetVelocity():Length() > 10 then
                ply:SetVelocity(ply:GetVelocity() * -0.5) -- Тормозим движение
            end
            
            -- Высасывание здоровья
            if time > self.NextDrainTime then
                self.NextDrainTime = time + 3
                self.DrainAmount = self.DrainAmount + 1
                
                if ply:Alive() then
                    local dmg = DamageInfo()
                    dmg:SetDamage(5)
                    dmg:SetDamageType(DMG_DIRECT)
                    dmg:SetAttacker(self)
                    dmg:SetInflictor(self)
                    dmg:SetDamageForce(Vector(0, 0, 0))
                    ply:TakeDamageInfo(dmg)
                    
                    self:EmitSound("npc/headcrab/headbite.wav", 60, 100)
                    self:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 50, 150)
                    
                    if math.random(1, 3) == 1 then
                        local effectdata = EffectData()
                        effectdata:SetOrigin(self:GetPos())
                        effectdata:SetScale(0.3)
                        util.Effect("BloodImpact", effectdata)
                    end
                    
                    if self.DrainAmount % 3 == 0 then
                        local healthPercent = math.floor((ply:Health() / ply:GetMaxHealth()) * 100)
                        ply:ChatPrint(string.format("[Trimming] Паразит высасывает здоровье! Осталось: %d%%", healthPercent))
                    end
                    
                    if ply:Health() <= 0 then
                        ply:ChatPrint("[Trimming] Паразит высосал всё ваше здоровье!")
                        self:DetachFromPlayer()
                    end
                else
                    self:DetachFromPlayer()
                end
            end
            
            -- Сердцебиение
            if time > self.NextHeartbeat then
                self.NextHeartbeat = time + 0.5
                self:EmitSound("player/heartbeat1.wav", 40, 100)
            end
            
            self:NextThink(time + 0.1)
            return true
        end

        -- ЗВУКИ ДВИЖЕНИЯ
        if time > self.LastMoveSound + 2 and self.State ~= STATE_IDLE then
            if math.random(1, 3) == 1 then
                self:EmitSound("physics/flesh/flesh_squishy_impact_soft" .. math.random(1, 3) .. ".wav", 40, math.random(100, 130))
                self.LastMoveSound = time
            end
        end

        -- Периодические звуки
        if time > self.NextSoundTime then
            if math.random(1, 20) == 1 then
                self:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 45, math.random(80, 120))
            end
            self.NextSoundTime = time + math.Rand(3, 8)
        end

        -- Обычная AI
        if not self.AttachedPlayer then
            -- ФИКС: Проверяем, не парим ли мы над землёй
            local groundTrace = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() - Vector(0, 0, 20),
                filter = self,
                mask = MASK_SOLID
            })
            
            if not groundTrace.Hit then
                -- Мы в воздухе - пытаемся упасть на землю
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(Vector(0, 0, -500))
                end
            elseif groundTrace.HitPos:Distance(self:GetPos()) > 10 then
                -- Мы слишком высоко над землёй - опускаемся
                self:SetPos(groundTrace.HitPos + Vector(0, 0, 5))
            end
            
            if self.State == STATE_IDLE then
                if not self:IsBeingWatched() and time > self.NextActionTime then
                    if math.random(1, 100) > 70 then
                        local dir = VectorRand()
                        dir.z = math.Clamp(dir.z, -0.2, 0.2)
                        local phys = self:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:ApplyForceCenter(dir * 1000 * (self.IsMature and 1.5 or 1))
                        end
                        self:EmitSound("physics/flesh/flesh_squishy_impact_soft" .. math.random(1, 3) .. ".wav", 35, 130)
                    end
                    self.NextActionTime = time + math.Rand(2, 5)
                end

                if self.IsMature then
                    for _, ply in pairs(player.GetAll()) do
                        if ply:Alive() and self:GetPos():Distance(ply:GetPos()) < 200 then
                            if not self:IsBeingWatched() then
                                self.AggroTarget = ply
                                self.State = STATE_AGGRO
                                self:SetNW2Int("State", STATE_AGGRO)
                                break
                            end
                        end
                    end
                end

            elseif self.State == STATE_AGGRO then
                if not IsValid(self.AggroTarget) or not self.AggroTarget:Alive() then
                    self.State = STATE_IDLE
                    self:SetNW2Int("State", STATE_IDLE)
                    self.AggroTarget = nil
                    return
                end

                local dist = self:GetPos():Distance(self.AggroTarget:GetPos())
                if dist < 100 and time > self.NextActionTime then
                    self:Attack(self.AggroTarget)
                elseif dist > 400 then
                    self.State = STATE_IDLE
                    self:SetNW2Int("State", STATE_IDLE)
                    self.AggroTarget = nil
                else
                    if not self:IsBeingWatched() and time > self.NextActionTime then
                        local dir = (self.AggroTarget:GetPos() - self:GetPos()):GetNormalized()
                        dir.z = math.Clamp(dir.z, -0.1, 0.3)
                        local phys = self:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:ApplyForceCenter(dir * 2000)
                        end
                        self.NextActionTime = time + 0.7
                    end
                end
            end
        end

        -- Визуальные эффекты
        self:SetNW2Float("PulsePhase", self:GetNW2Float("PulsePhase", 0) + 0.05)

        self:NextThink(time + 0.3)
        return true
    end

    function ENT:OnRemove()
        timer.Remove("TrimmingReproduce_" .. self:EntIndex())
        self:DetachFromPlayer()
    end

    function ENT:JModEZremoteTriggerFunc(ply)
        if IsValid(ply) then
            self.State = STATE_AGGRO
            self:SetNW2Int("State", STATE_AGGRO)
            self.AggroTarget = ply
            self:EmitSound("ambient/machines/thumper_hit.wav", 60, 120)
        end
    end
    
    function ENT:JModEZnailPull(ply)
        if IsValid(ply) then
            self:Attack(ply)
        end
        return false
    end
    
else -- CLIENT
    function ENT:Draw()
        local isAlive = self:GetNW2Bool("Alive", true)
        
        if not isAlive then
            render.SetBlend(0.3)
            self:DrawModel()
            render.SetBlend(1)
            return
        end
        
        self:DrawModel()
        
        -- Пульсация
        local isReproducing = self:GetNW2Bool("Reproducing", false)
        local attachType = self:GetNW2Int("AttachType", 0)
        local pulseSpeed = 0.05
        local pulseScale = 0.04
        
        if isReproducing then
            pulseSpeed = 0.15
            pulseScale = 0.1
        elseif attachType == ATTACH_PARASITE then
            pulseSpeed = 0.2
            pulseScale = 0.08
        end
        
        local pulse = math.sin(CurTime() * pulseSpeed * 10) * pulseScale + 1
        local mat = Matrix()
        mat:Scale(Vector(pulse, pulse, pulse * 0.9))
        self:EnableMatrix("RenderMultiply", mat)
        
        -- Цвет
        if isReproducing then
            render.SetColorModulation(1.3, 0.6, 0.6)
            self:DrawModel()
            render.SetColorModulation(1, 1, 1)
        elseif attachType == ATTACH_PARASITE then
            render.SetColorModulation(1.5, 0.4, 0.4)
            self:DrawModel()
            render.SetColorModulation(1, 1, 1)
        end
    end

    function ENT:GetEZdisplay()
        local isAlive = self:GetNW2Bool("Alive", true)
        
        if not isAlive then
            return {"Vita Carnis: Trimming", "СОСТОЯНИЕ: УНИЧТОЖЕНО"}
        end
        
        local stateNames = {
            [STATE_IDLE] = "Неактивно",
            [STATE_AGGRO] = "Агрессивно",
            [STATE_ATTACK] = "Атакует"
        }
        
        local attachNames = {
            [ATTACH_NONE] = "Свободен",
            [ATTACH_PARASITE] = "ПАРАЗИТИРУЕТ"
        }
        
        local state = self:GetNW2Int("State", 0)
        local isReproducing = self:GetNW2Bool("Reproducing", false)
        local attachType = self:GetNW2Int("AttachType", 0)
        
        local status = "Состояние: " .. (stateNames[state] or "Неизвестно")
        if attachType == ATTACH_PARASITE then
            status = "ПАРАЗИТ: Присосался к игроку"
        elseif isReproducing then
            status = status .. " (Почкуется)"
        end
        
        local info = {
            "Vita Carnis: Trimming (ПАРАЗИТ)",
            status,
            "Размножение: каждые 45 секунд",
            "Умирает от одного попадания"
        }
        
        if attachType == ATTACH_PARASITE then
            table.insert(info, "Блокирует движение игрока")
            table.insert(info, "Высасывает 5 HP каждые 3 секунды")
            table.insert(info, "Размножается в 2 раза быстрее")
        else
            table.insert(info, "70% шанс стать паразитом при укусе")
        end
        
        return info
    end

    language.Add("ent_jack_gmod_ezanomaly_trimming", "Vita Carnis: Trimming (Паразит)")
end

-- Регистрация
if JMod and JMod.EZ_ANOMALY_ENTITIES then
    JMod.EZ_ANOMALY_ENTITIES["ent_jack_gmod_ezanomaly_trimming"] = {
        Category = "JMod - EZ Anomalies",
        Name = "Trimming",
        Model = "models/props_junk/watermelon01.mdl",
        Color = Color(180, 40, 40),
        Tip = "Vita Carnis: Паразитическая плоть. Присасывается, блокирует движение и высасывает здоровье."
    }
end