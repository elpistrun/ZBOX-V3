-- COMBAT GNOME v11.1 (Fixed Stun)
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "COMBAT GNOME"
ENT.Author = "YourName"
ENT.Category = "JMod - EZ Anomalies"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.JModPreferredCarryAngles = Angle(0, 0, 0)

-- Константа оглушения
local STUN_DURATION = 5

---
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Bool", 0, "HasAppleBuff")
end

---
if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/gnome.mdl")
        self:SetModelScale(2, 0)
        
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
        
        -- ВАЖНО: делаем энтити уязвимой для пуль
        self:SetSolidFlags(FSOLID_TRIGGER)
        
        self:SetColor(Color(100, 100, 100, 255))
        self:SetMaterial("models/props_c17/metalladder001")
        
        self:SetState(0) -- PATROL
        self:SetHasAppleBuff(false)
        
        self.LastMineTime = 0
        self.LastGrenadeTime = 0
        self.LastMeleeTime = 0
        self.LastDynamiteBarrageTime = 0
        self.NextMoveTime = 0
        self.Target = nil
        self.CombatMode = false
        self.IsDead = false
        self.AppleBuffEnd = 0
        
        -- Переменные для оглушения
        self.StunEndTime = 0
        self.IsStunned = false
        self.OriginalColor = Color(100, 100, 100, 255)
        
        timer.Simple(0.1, function()
            if IsValid(self) then
                local Phys = self:GetPhysicsObject()
                if IsValid(Phys) then
                    Phys:SetMass(200)
                    Phys:SetDamping(0.5, 0.5)
                    Phys:Wake()
                end
            end
        end)

        print("[JMOD] Combat Gnome spawned! He will attack anyone on sight.")
    end

    -- ВСТРОЕННЫЙ МЕТОД TRACEATTACK - вызывается при попадании пули
    function ENT:TraceAttack(attacker, dmginfo, dir, hitpos)
        if self.IsDead then return end
        
        -- Проверяем что это пуля
        local DmgType = dmginfo:GetDamageType()
        local IsBullet = bit.band(DmgType, DMG_BULLET) ~= 0
        
        if IsBullet then
            self:Stun()
        end
        
        -- Наносим небольшой урон для эффекта
        dmginfo:SetDamage(1)
        self:TakeDamageInfo(dmginfo)
    end

    -- Функция оглушения
    function ENT:Stun()
        if self.IsDead then return end
        if self.IsStunned then return end -- Уже оглушён
        
        local Time = CurTime()
        self.StunEndTime = Time + STUN_DURATION
        self.IsStunned = true
        
        -- Останавливаем движение
        local Phys = self:GetPhysicsObject()
        if IsValid(Phys) then
            Phys:SetVelocity(Vector(0, 0, 0))
            Phys:Sleep()
        end
        
        -- Эффекты оглушения
        self:SetColor(Color(255, 100, 100, 255))
        self:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75, 100)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(2)
        util.Effect("Sparks", effectdata)
        
        -- Сброс боевого режима
        self.CombatMode = false
        self:SetState(0)
        self.Target = nil
        
        print("[JMOD] Combat Gnome stunned for " .. STUN_DURATION .. " seconds!")
        
        -- Таймер на восстановление
        timer.Simple(STUN_DURATION, function()
            if IsValid(self) and not self.IsDead then
                self.IsStunned = false
                self:SetColor(self.OriginalColor)
                -- Пробуждаем физику
                local Phys = self:GetPhysicsObject()
                if IsValid(Phys) then
                    Phys:Wake()
                end
                print("[JMOD] Combat Gnome recovered from stun!")
            end
        end)
    end

    -- Проверка яблока при USE
    function ENT:CheckForApple(activator)
        if not IsValid(activator) or not activator:IsPlayer() then return false, nil end
        
        local gnomePos = self:GetPos()
        local apples = ents.FindInSphere(gnomePos, 350)
        local closestApple = nil
        local closestDist = 99999
        
        for _, ent in pairs(apples) do
            if IsValid(ent) and ent:GetClass() == "ent_jack_gmod_ezapple" then
                local dGnome = gnomePos:Distance(ent:GetPos())
                if dGnome < closestDist then
                    closestDist = dGnome
                    closestApple = ent
                end
            end
        end
        
        if closestApple then return true, closestApple end
        
        local wep = activator:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "ent_jack_gmod_ezapple" then
            return true, wep
        end
        
        return false, nil
    end
    
    -- Поиск ближайшего яблока
    function ENT:FindNearestApple()
        local selfPos = self:GetPos()
        local apples = ents.FindInSphere(selfPos, 2500)
        local best = nil
        local bestDist = math.huge
        for _, ent in pairs(apples) do
            if IsValid(ent) and ent:GetClass() == "ent_jack_gmod_ezapple" then
                local d = selfPos:Distance(ent:GetPos())
                if d < bestDist then
                    bestDist = d
                    best = ent
                end
            end
        end
        return best, bestDist
    end
    
    -- "Съесть" яблоко и получить бафф
    function ENT:EatApple(appleEnt)
        if not IsValid(appleEnt) or appleEnt:GetClass() ~= "ent_jack_gmod_ezapple" then return end
        
        appleEnt:Remove()
        self:ApplyAppleBuff()
        self:EmitSound("snds_jack_gmod/nom" .. math.random(1,3) .. ".ogg", 75, 100)
        
        local ed = EffectData()
        ed:SetOrigin(self:GetPos() + Vector(0,0,30))
        ed:SetScale(1)
        util.Effect("ManhackSparks", ed)
        
        -- Сбрасываем боевой режим после еды
        self.CombatMode = false
        self:SetState(0)
        self.Target = nil
    end

    -- USE
    function ENT:Use(activator)
        if self.IsDead then return end
        if not IsValid(activator) or not activator:IsPlayer() then return end
        
        local hasApple, appleWeapon = self:CheckForApple(activator)
        
        if hasApple then
            appleWeapon:Remove()
            self:EatApple(appleWeapon)
            activator:ChatPrint("Combat Gnome ate the apple! Now buffed for 3 minutes.")
            return
        end
        
        -- Показать статус
        local status = self.CombatMode and "COMBAT" or "PATROL"
        if self:GetHasAppleBuff() then
            status = status .. " (APPLE BUFF)"
        end
        if self.IsStunned then
            status = status .. " [STUNNED]"
        end
        
        activator:ChatPrint("Combat Gnome Status: " .. status)
        activator:ChatPrint("To buff the gnome: Hold an apple item and press USE while near")
        
        self:EmitSound("npc/metropolice/vo/affirmative.wav", 70, 100)
    end

    function ENT:ApplyAppleBuff()
        if self:GetHasAppleBuff() then return end
        
        self:SetHasAppleBuff(true)
        self.AppleBuffEnd = CurTime() + 180 -- 3 минуты
        
        self.OriginalColor = Color(100, 255, 100, 255)
        self:SetColor(self.OriginalColor)
        self:EmitSound("ambient/energy/zap1.wav", 60, 100)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetScale(1.5)
        util.Effect("ManhackSparks", effectdata)
        
        print("[JMOD] Combat Gnome got apple buff! Enhanced abilities for 3 minutes.")
    end

    function ENT:UpdateAppleBuff()
        if not self:GetHasAppleBuff() then return end
        
        if CurTime() > self.AppleBuffEnd then
            self:SetHasAppleBuff(false)
            self.OriginalColor = Color(100, 100, 100, 255)
            self:SetColor(self.OriginalColor)
        end
    end

    function ENT:MeleeAttack(target)
        if self.IsDead or self.IsStunned then return end
        if not IsValid(target) then return end
        
        if CurTime() < self.LastMeleeTime + 2 then return end
        
        self.LastMeleeTime = CurTime()
        self:SetState(4) -- MELEE
        
        local soundPitch = self:GetHasAppleBuff() and 120 or 100
        self:EmitSound("weapons/crowbar/crowbar_swing1.wav", 70, soundPitch)
        
        timer.Simple(0.2, function()
            if not IsValid(self) or not IsValid(target) or self.IsDead or self.IsStunned then return end
            
            local dist = self:GetPos():Distance(target:GetPos())
            if dist <= 200 then
                local damage = self:GetHasAppleBuff() and 30 or 15
                local dmg = DamageInfo()
                dmg:SetDamage(damage)
                dmg:SetDamageType(DMG_CLUB)
                dmg:SetAttacker(self)
                dmg:SetInflictor(self)
                dmg:SetDamagePosition(target:GetPos())
                
                local dir = (target:GetPos() - self:GetPos()):GetNormalized()
                local force = self:GetHasAppleBuff() and 6000 or 4000
                dmg:SetDamageForce(dir * force)
                
                target:TakeDamageInfo(dmg)
                
                self:EmitSound("physics/body/body_medium_impact_hard2.wav", 70, soundPitch)
                
                if target:IsPlayer() or target:IsNPC() then
                    local phys = target:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(dir * force + Vector(0,0,1000))
                    end
                end
            end
            
            self:SetState(self.CombatMode and 1 or 0)
        end)
    end

    function ENT:ThrowInaccurateGrenadeToward(target)
        if self.IsDead or self.IsStunned or not IsValid(target) then return end
        
        if CurTime() < self.LastGrenadeTime + 8 then return end
        
        self.LastGrenadeTime = CurTime()
        self:SetState(3)
        
        self:EmitSound("weapons/slam/throw.wav", 75, 90)
        
        timer.Simple(0.5, function()
            if not IsValid(self) or not IsValid(target) or self.IsDead or self.IsStunned then return end
            
            local grenade = ents.Create("ent_jack_gmod_ezfragnade")
            if IsValid(grenade) then
                JMod.SetEZowner(grenade, self)
                local startPos = self:GetPos() + Vector(0,0,60)
                local baseTarget = target:GetPos() + Vector(0,0,30)
                local randOffset = Vector(math.Rand(-400,400), math.Rand(-400,400), math.Rand(-200,200))
                local targetPos = baseTarget + randOffset
                local dir = (targetPos - startPos):GetNormalized()
                
                grenade:SetPos(startPos)
                grenade:SetAngles(dir:Angle())
                grenade:Spawn()
                grenade:Activate()
                
                local phys = grenade:GetPhysicsObject()
                if IsValid(phys) then
                    local dist = startPos:Distance(targetPos)
                    local force = dir * math.Clamp(dist * 6, 400, 1500)
                    force.z = force.z + 200
                    phys:ApplyForceCenter(force)
                    phys:AddAngleVelocity(VectorRand() * 800)
                end
                
                timer.Simple(0.5, function()
                    if IsValid(grenade) then grenade:Prime() end
                end)
            end
            self:SetState(0)
        end)
    end

    function ENT:ThrowGrenadeAt(target)
        if self.IsDead or self.IsStunned then return end
        
        local cooldown = self:GetHasAppleBuff() and 5 or 15
        if CurTime() < self.LastGrenadeTime + cooldown then return end
        if not IsValid(target) then return end
        
        self.LastGrenadeTime = CurTime()
        self:SetState(3)
        self.Target = target
        
        self:EmitSound("weapons/slam/throw.wav", 75, self:GetHasAppleBuff() and 120 or 100)
        
        timer.Simple(self:GetHasAppleBuff() and 0.25 or 0.5, function()
            if not IsValid(self) or not IsValid(target) or self.IsDead or self.IsStunned then return end
            
            local grenade = ents.Create("ent_jack_gmod_ezfragnade")
            if IsValid(grenade) then
                JMod.SetEZowner(grenade, self)
                local startPos = self:GetPos() + Vector(0,0,60)
                local targetPos = target:GetPos() + Vector(0,0,50)
                local dir = (targetPos - startPos):GetNormalized()
                
                grenade:SetPos(startPos)
                grenade:SetAngles(dir:Angle())
                grenade:Spawn()
                grenade:Activate()
                
                local phys = grenade:GetPhysicsObject()
                if IsValid(phys) then
                    local distance = startPos:Distance(targetPos)
                    local forceMultiplier = self:GetHasAppleBuff() and 15 or 10
                    local force = dir * math.Clamp(distance * forceMultiplier, 500, 2000)
                    force.z = force.z + 300
                    phys:ApplyForceCenter(force)
                    phys:AddAngleVelocity(VectorRand() * 500)
                end
                
                timer.Simple(0.5, function()
                    if IsValid(grenade) then
                        grenade:Prime()
                    end
                end)
            end
            
            self:SetState(self.CombatMode and 1 or 0)
        end)
    end

    function ENT:ThrowDynamiteBarrage(target)
        if self.IsDead or self.IsStunned then return end
        
        if not self:GetHasAppleBuff() then return end
        if CurTime() < self.LastDynamiteBarrageTime + 30 then return end
        if not IsValid(target) then return end
        
        self.LastDynamiteBarrageTime = CurTime()
        
        self:EmitSound("weapons/grenade_launcher1.wav", 85, 100)
        
        local startPos = self:GetPos() + Vector(0,0,70)
        local targetPos = target:GetPos()
        
        for i = 1, 3 do
            timer.Simple(i * 0.5, function()
                if not IsValid(self) or not IsValid(target) or self.IsDead or self.IsStunned then return end
                
                local dynamite = ents.Create("ent_jack_gmod_ezdynamite")
                if IsValid(dynamite) then
                    JMod.SetEZowner(dynamite, self)
                    local angle = (i / 3) * math.pi * 2
                    local offset = Vector(
                        math.cos(angle) * 80,
                        math.sin(angle) * 80,
                        math.Rand(0, 20)
                    )
                    
                    local barrageTargetPos = targetPos + offset
                    local dir = (barrageTargetPos - startPos):GetNormalized()
                    local distance = startPos:Distance(barrageTargetPos)
                    
                    local forceMultiplier = 12
                    local force = dir * math.Clamp(distance * forceMultiplier, 600, 2500)
                    force.z = force.z + 400
                    
                    dynamite:SetPos(startPos)
                    dynamite:SetAngles(dir:Angle())
                    dynamite:Spawn()
                    dynamite:Activate()
                    
                    local phys = dynamite:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(force)
                        phys:AddAngleVelocity(VectorRand() * 300)
                    end
                    
                    timer.Simple(2.0, function()
                        if IsValid(dynamite) then
                            local success, err = pcall(function()
                                if dynamite.Arm then
                                    dynamite:Arm()
                                elseif dynamite.Prime then
                                    dynamite:Prime()
                                end
                            end)
                        end
                    end)
                    
                    self:EmitSound("weapons/slam/throw.wav", 75, math.random(90, 110))
                end
            end)
        end
    end

    function ENT:PlaceMine()
        if self.IsDead or self.IsStunned then return end
        
        local cooldown = self:GetHasAppleBuff() and 15 or 30
        if CurTime() < self.LastMineTime + cooldown then return end
        
        self.LastMineTime = CurTime()
        self:SetState(2)
        
        local soundPitch = self:GetHasAppleBuff() and 120 or 100
        self:EmitSound("weapons/mine_deploy.wav", 60, soundPitch)
        
        timer.Simple(self:GetHasAppleBuff() and 0.7 or 1.0, function()
            if not IsValid(self) or self.IsDead or self.IsStunned then return end
            
            local mine = ents.Create("ent_jack_gmod_ezlandmine")
            if IsValid(mine) then
                local trace = util.TraceLine({
                    start = self:GetPos() + Vector(0,0,20),
                    endpos = self:GetPos() + self:GetForward() * 80 - Vector(0,0,80),
                    filter = self
                })
                
                if trace.Hit then
                    mine:SetPos(trace.HitPos + trace.HitNormal * 2)
                    
                    local normal = trace.HitNormal
                    local ang
                    if normal.z > 0.99 then
                        ang = Angle(90, self:GetAngles().y, 0)
                    else
                        ang = normal:Angle()
                        ang:RotateAroundAxis(ang:Right(), 90)
                    end
                    mine:SetAngles(ang)
                    
                    mine:Spawn()
                    mine:Activate()
                    
                    local success, err = pcall(function()
                        if mine.Arm then
                            mine:Arm(self, true)
                        elseif mine.AutoArm ~= nil then
                            mine.AutoArm = true
                            JMod.SetEZowner(mine, self)
                        end
                    end)
                end
            end
            
            self:SetState(self.CombatMode and 1 or 0)
        end)
    end

    function ENT:FindBestTarget()
        if self.IsDead or self.IsStunned then return nil, math.huge end
        
        local bestTarget = nil
        local bestDist = math.huge
        local selfPos = self:GetPos()
        
        -- Атакуем ВСЕХ игроков
        for _, ply in pairs(player.GetAll()) do
            if ply:Alive() and not ply:IsInVehicle() then
                local dist = selfPos:Distance(ply:GetPos())
                if dist < bestDist then
                    bestTarget = ply
                    bestDist = dist
                end
            end
        end
        
        for _, npc in pairs(ents.FindByClass("npc_*")) do
            if npc:Health() > 0 then
                local dist = selfPos:Distance(npc:GetPos())
                if dist < bestDist then
                    bestTarget = npc
                    bestDist = dist
                end
            end
        end
        
        return bestTarget, bestDist
    end

    function ENT:MoveToPosition(pos)
        if self.IsDead or self.IsStunned then return end
        if CurTime() < self.NextMoveTime then return end
        if not pos then return end
        
        local currentPos = self:GetPos()
        local dir = (pos - currentPos):GetNormalized()
        local distance = currentPos:Distance(pos)
        
        if distance > 50 then
            local targetYaw = (pos - currentPos):Angle().y
            local currentYaw = self:GetAngles().y
            local newYaw = math.ApproachAngle(currentYaw, targetYaw, 10)
            self:SetAngles(Angle(0, newYaw, 0))
            
            local angleDiff = math.abs(math.AngleDifference(targetYaw, currentYaw))
            if angleDiff < 45 then
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:Wake()
                    phys:SetVelocity(Vector(0,0,0))
                    
                    local speedMultiplier = self:GetHasAppleBuff() and 1.5 or 1.0
                    local moveForce = dir * 80000 * math.Clamp(distance/1000, 0.1, 1) * speedMultiplier
                    phys:ApplyForceCenter(moveForce)
                    
                    local trace = util.TraceLine({
                        start = currentPos + Vector(0,0,10),
                        endpos = currentPos + dir * 100 + Vector(0,0,10),
                        filter = self
                    })
                    
                    if trace.Hit then
                        phys:ApplyForceCenter(Vector(0,0,20000))
                    end
                end
            end
            
            self.NextMoveTime = CurTime() + (self:GetHasAppleBuff() and 0.15 or 0.3)
        end
    end

    function ENT:Think()
        if self.IsDead then return end
        
        self:UpdateAppleBuff()
        
        -- Если оглушён — ничего не делаем
        if self.IsStunned then
            self:SetState(0)
            self.CombatMode = false
            local phys = self:GetPhysicsObject()
            if IsValid(phys) and not phys:IsAsleep() then 
                phys:Sleep()
            end
            self:NextThink(CurTime() + 0.5)
            return true
        end
        
        local appleTarget, appleDist = self:FindNearestApple()
        
        if not self:GetHasAppleBuff() and IsValid(appleTarget) then
            self.CombatMode = false
            self:SetState(0)
            
            if appleDist < 100 then
                self:EatApple(appleTarget)
            else
                self:MoveToPosition(appleTarget:GetPos())
                if self:GetState() ~= 2 and self:GetState() ~= 3 and self:GetState() ~= 4 then
                    local appleDir = (appleTarget:GetPos() - self:GetPos()):GetNormalized()
                    local yaw = appleDir:Angle().y
                    self:SetAngles(Angle(0, math.ApproachAngle(self:GetAngles().y, yaw, 8), 0))
                end
                if self:GetState() ~= 3 and math.random(1, 100) <= 5 then
                    local nearestPly = nil
                    local nearestD = math.huge
                    for _, p in pairs(player.GetAll()) do
                        if p:Alive() then
                            local d = self:GetPos():Distance(p:GetPos())
                            if d < nearestD then
                                nearestD = d
                                nearestPly = p
                            end
                        end
                    end
                    if IsValid(nearestPly) then
                        self:ThrowInaccurateGrenadeToward(nearestPly)
                    end
                end
            end
            
            local phys = self:GetPhysicsObject()
            if IsValid(phys) and not phys:IsAsleep() then phys:Wake() end
            self:NextThink(CurTime() + 0.1)
            return true
        end
        
        local target, distance = self:FindBestTarget()
        
        if IsValid(target) then
            if not self.CombatMode then
                self.CombatMode = true
                self:SetState(1)
            end
            
            if distance <= 150 then
                if self:GetState() ~= 4 then
                    self:MeleeAttack(target)
                end
            elseif distance > 150 and distance <= 800 then
                if self:GetState() ~= 2 and self:GetState() ~= 4 then
                    if math.random(1, 100) <= 20 then
                        self:PlaceMine()
                    else
                        local angle = CurTime() * 2
                        local circlePos = target:GetPos() + Vector(math.cos(angle) * 400, math.sin(angle) * 400, 0)
                        self:MoveToPosition(circlePos)
                    end
                end
            elseif distance > 800 and distance <= 4000 then
                if self:GetState() ~= 3 and self:GetState() ~= 2 then
                    if self:GetHasAppleBuff() and distance > 1000 and distance < 3000 then
                        if math.random(1, 100) <= 25 then
                            self:ThrowDynamiteBarrage(target)
                        elseif math.random(1, 100) <= 15 then
                            self:ThrowGrenadeAt(target)
                        else
                            local approachPos = target:GetPos() + Vector(math.random(-200,200), math.random(-200,200), 0)
                            self:MoveToPosition(approachPos)
                        end
                    elseif math.random(1, 100) <= 15 then
                        self:ThrowGrenadeAt(target)
                    else
                        local approachPos = target:GetPos() + Vector(math.random(-200,200), math.random(-200,200), 0)
                        self:MoveToPosition(approachPos)
                    end
                end
            else
                if self.CombatMode then
                    self:MoveToPosition(target:GetPos())
                else
                    if math.random(1, 100) <= 10 then
                        local randomPos = self:GetPos() + Vector(math.random(-500,500), math.random(-500,500), 0)
                        self:MoveToPosition(randomPos)
                    end
                end
            end
            
            if target and self:GetState() ~= 2 and self:GetState() ~= 3 and self:GetState() ~= 4 then
                local targetDir = (target:GetPos() - self:GetPos()):GetNormalized()
                local targetYaw = targetDir:Angle().y
                local newYaw = math.ApproachAngle(self:GetAngles().y, targetYaw, 5)
                self:SetAngles(Angle(0, newYaw, 0))
            end
        else
            self.CombatMode = false
            self:SetState(0)
            if math.random(1, 100) <= 5 then
                local randomPos = self:GetPos() + Vector(math.random(-300,300), math.random(-300,300), 0)
                self:MoveToPosition(randomPos)
            end
        end
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) and not phys:IsAsleep() then phys:Wake() end
        self:NextThink(CurTime() + 0.1)
        return true
    end

    function ENT:PhysicsCollide(data, physobj)
        if self.IsDead or self.IsStunned then return end
        
        local hitEnt = data.HitEntity
        if IsValid(hitEnt) and data.Speed > 150 then
            local hitPhys = hitEnt:GetPhysicsObject()
            if IsValid(hitPhys) and hitPhys:GetMass() >= 500 then
                self:DeathExplosion()
                return
            end
        end
        
        if data.DeltaTime > 0.2 and data.Speed > 100 then
            self:EmitSound("physics/concrete/concrete_impact_hard" .. math.random(1,3) .. ".wav")
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        if self.IsDead then return end
        
        self:TakePhysicsDamage(dmginfo)
        
        local damage = dmginfo:GetDamage()
        local dmgType = dmginfo:GetDamageType()
        
        if damage > 0 then
            self:EmitSound("physics/metal/metal_sheet_impact_hard" .. math.random(1,3) .. ".wav")
            
            if not self.CombatMode and not self.IsStunned then
                self.CombatMode = true
                self:SetState(1)
            end
        end
        
        if bit.band(dmgType, DMG_BLAST) ~= 0 and damage > 100 then
            local att = dmginfo:GetAttacker()
            local infl = dmginfo:GetInflictor()
            if att == self or infl == self then return end
            if IsValid(infl) and (infl.EZowner == self or (JMod and JMod.GetEZowner and JMod.GetEZowner(infl) == self)) then return end
            if IsValid(att) and (att.EZowner == self or (JMod and JMod.GetEZowner and JMod.GetEZowner(att) == self)) then return end
            self:DeathExplosion()
        end
    end

    function ENT:DeathExplosion()
        if self.IsDead then return end
        self.IsDead = true
        
        local pos = self:GetPos()
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos + Vector(0,0,50))
        effectdata:SetScale(self:GetHasAppleBuff() and 4 or 3)
        util.Effect("HelicopterMegaBomb", effectdata, true, true)
        
        self:EmitSound("ambient/explosions/explode_" .. math.random(1,3) .. ".wav", 100, 100)
        
        timer.Simple(0.1, function()
            if IsValid(self) then
                util.BlastDamage(game.GetWorld(), game.GetWorld(), pos, 600, 150)
            end
        end)
        
        timer.Simple(3, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
        
        self:SetNotSolid(true)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetNoDraw(true)
    end

elseif CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    language.Add("ent_jack_gmod_ezanomaly_combatgnome", "COMBAT GNOME")
end