--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire by Vioxtar
Optimized for HG with separate settings

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

--[[-------------------------------------------------------------------------
	Shared Functionalities
---------------------------------------------------------------------------]]
if SERVER or CLIENT then

	function ENT:SetupDataTables()
		self:NetworkVar("Int", 0, "FireState")
	end

	function ENT:Initialize()
		if not IsValid(self) then return end
		
		self:SetFireState(1)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:DrawShadow(false)
		self:SetModel(vFireDummyModel)

		local parent = self:GetParent()
		if !IsValid(parent) then
			parent = game.GetWorld()
		end
		
		self.parent = parent
		if !parent.fires then parent.fires = {} end

		if not isvector(self:GetPos()) then return end
		
		parent.fires[self] = parent:WorldToLocal(self.GetPos and self:GetPos() or parent:GetPos())

		if SERVER then
			self.life = 1
			self.feed = 0
			if !self.stateUp then self.stateUp = 0 end
			if !self.stateDown then self.stateDown = vFireMaxState end
			self:SetTrigger(true)
			self.burning = {}
			self.matType = util.QuickTrace(self:GetPos(), self:GetForward() * -10).MatType or -1
			self.nextFuelThink = 0
			self.nextLifeThink = 0
			self.nextEatThink = 0
			self.nextBurnThink = 0
			self.nextDropThink = 0
			self.nextSpreadThink = 0
		end

		if CLIENT then
			self.lastState = 1
			self.visState = 1
			self.hiddenForPotato = false

			if vFireIsCharacter(parent) and !game.SinglePlayer() then
				self:SetPredictable(true)
			end

			self.pVis = util.GetPixelVisibleHandle()
			self.a = 1
			self.LOD = false
			self.visLOD = false
			self.nextClusterThink = 0
			self.nextParticlesThink = 0
			self.nextAnimationThink = 0
			self:RedoParticles(1)
		end
		
		self:Prioritize(5)
		self.initialized = true
		hook.Run("vFireCreated", self, parent)

		if SERVER then self:FindCluster() end
	end

	function ENT:OnRemove()
		local parent = self.parent
		if IsValid(parent) then
			if parent.fires then parent.fires[self] = nil end
		end

		if CLIENT then
			if self.flames then
				if self.flames:IsValid() then self.flames:StopEmission() end
			end
			if self.base then
				if self.base:IsValid() then self.base:StopEmission() end
			end
		end

		local cluster = self.cluster
		if IsValid(cluster) then
			cluster:RemFire(self)
		end

		if self.initialized then
			hook.Run("vFireRemoved", self, parent)
		end
	end

	function ENT:IsPrioritized()
		return self.prioritized
	end
	
	function ENT:UnPrioritize()
		self.prioritized = false
	end
	
	function ENT:Prioritize(priority, broadcast)
		if priority <= 0 then self:UnPrioritize() return end
		self.prioritized = true
		
		timer.Simple(priority, function()
			if IsValid(self) then
				self:UnPrioritize()
			end
		end)

		self:Think()

		if SERVER and broadcast then
			if player.GetCount() > 0 then
				net.Start("vFirePriority", true)
					net.WriteEntity(self)
					net.WriteInt(priority, 16)
				net.SendPVS(self:GetPos())
			end
		end
	end
	
	if SERVER then
		util.AddNetworkString("vFirePriority")
	end
	
	if CLIENT then
		net.Receive("vFirePriority", function()
			local fire = net.ReadEntity()
			local priority = net.ReadInt(16)
			timer.Simple(0, function()
				if !IsValid(fire) then return end
				if !fire.UnPrioritize or !fire.Prioritize then return end
				if priority <= 0 then
					fire:UnPrioritize()
				else
					fire:Prioritize(priority)
				end
			end)
		end)
	end

	function ENT:GetClosestFire()
		if !IsValid(self.cluster) then return nil end
		if IsValid(self.closestFire) then return self.closestFire end
		
		local minDist = math.huge
		local cluster = self.cluster
		for k, fire2 in pairs(cluster.fires) do
			if self == fire2 then continue end
			local dist = cluster.distMem[self][fire2]
			if dist and dist < minDist then
				self.closestFire = fire2
				minDist = dist
			end
		end
		return self.closestFire, minDist
	end

	function ENT:IsBiggerThan(other)
		if SERVER then
			return self.life > other.life
		end
		if CLIENT then
			if self.GetFireState and other.GetFireState then
				return self:GetFireState() > other:GetFireState()
			else
				return false
			end
		end
	end

	function ENT:GetClosestSmallerFire()
		if !IsValid(self.cluster) then return nil end
		if IsValid(self.closestSmallerFire) then
			if !self:IsBiggerThan(self.closestSmallerFire) then
				self.closestSmallerFire = nil
			else
				return self.closestSmallerFire
			end
		end
		
		local minDist = math.huge
		local cluster = self.cluster
		for k, fire2 in pairs(cluster.fires) do
			if self == fire2 then continue end
			if !self:IsBiggerThan(fire2) then continue end
			local dist = cluster.distMem[self][fire2]
			if dist and dist < minDist then
				self.closestSmallerFire = fire2
				minDist = dist
			end
		end
		return self.closestSmallerFire, minDist
	end

	function ENT:GetClosestBiggerFire()
		if !IsValid(self.cluster) then return nil end
		if IsValid(self.closestBiggerFire) then
			if self:IsBiggerThan(self.closestBiggerFire) then
				self.closestBiggerFire = nil
			else
				return self.closestBiggerFire
			end
		end
		
		local minDist = math.huge
		local cluster = self.cluster
		for k, fire2 in pairs(cluster.fires) do
			if self == fire2 then continue end
			if self:IsBiggerThan(fire2) then continue end
			local dist = cluster.distMem[self][fire2]
			if dist and dist < minDist then
				self.closestBiggerFire = fire2
				minDist = dist
			end
		end
		return self.closestBiggerFire, minDist
	end

	function ENT:GetWindVector()
		local overrideWindVec = hook.Run("vFireOnCalculateWind", self)
		if isvector(overrideWindVec) then
			local length = overrideWindVec:Length()
			if length > 1 then
				overrideWindVec = overrideWindVec / length
			end
			return overrideWindVec
		else
			local exposure
			if self.cluster then
				exposure = self.cluster.windExposure
			end
			if !exposure then
				exposure = math.Rand(0, 1)
			end
			return exposure * vFireGetWindVector()
		end
	end
end

--[[-------------------------------------------------------------------------
	Server Functionalities (ОСТАЁТСЯ БЕЗ ИЗМЕНЕНИЙ)
---------------------------------------------------------------------------]]
if SERVER then

	function ENT:ChangeLife(newLife)
		self.life = math.min(newLife, vFireStateToLife(self.stateDown or vFireMaxLife))
	end

	function ENT:GiveLife(fire2, amount)
		local take = math.Min(amount, self.life)
		fire2:ChangeLife(fire2.life + take)
		self:ChangeLife(self.life - take)
	end

	function ENT:GiveFeed(fire2, amount)
		local take = math.Min(amount, self.feed)
		fire2.feed = fire2.feed + take
		self.feed = self.feed - take
	end

	function ENT:Eat(fire2)
		fire2:GiveLife(self, fire2.life)
		fire2:GiveFeed(self, fire2.feed)
		fire2:Remove()
	end

	function ENT:SoftExtinguish(amount)
		self:ChangeLife(self.life - amount)
	end

	function ENT:FindCluster()
		local foundCluster
		local minDist = math.huge
		local closeEnts = ents.FindInSphere(self:GetPos(), vFireClusterSize)
		
		for k, cluster in pairs(closeEnts) do
			if cluster:GetClass() != "vfire_cluster" then continue end
			if cluster.parent != self.parent then continue end
			if cluster.matType != self.matType then continue end
			
			local dist = self:GetPos():DistToSqr(cluster:GetPos())
			if dist < minDist then
				minDist = dist
				foundCluster = cluster
			end
		end

		if IsValid(foundCluster) then
			foundCluster:AddFire(self)
		else
			foundCluster = ents.Create("vfire_cluster")
			foundCluster:SetNW2Entity("ClusterParent", self.parent)
			foundCluster.matType = self.matType
			foundCluster:Spawn()
			foundCluster:AddFire(self)
		end
	end

	function ENT:AddBurning(ent)
		if self.burning[ent] or vFireIsVFireEnt(ent) or ent == self.parent then return end
		self.burning[ent] = ent
	end

	function ENT:RemoveBurning(ent)
		if self.burning[ent] then self.burning[ent] = nil end
	end

	function ENT:StartTouch(otherEnt)
		self:AddBurning(otherEnt)
	end

	function ENT:EndTouch(otherEnt)
		self:RemoveBurning(otherEnt)
	end

	function ENT:Drop()
		local dropPos = self:GetPos() + self:GetForward()
		local fireBall = CreateVFireBall(self.life, self.feed, dropPos, Vector(), self:GetOwner())
		self:Remove()
		return fireBall
	end

	function ENT:IsPotentiallyVisible()
		local cluster = self.cluster
		if cluster then
			return cluster.PVSLOD or true
		else
			return true
		end
	end

	function ENT:ImprovePlacement(targetState, parent)
		if !parent then parent = self.parent end
		
		local forward = self:GetForward()
		local pos = self:GetPos()
		local ignoreFraction = !parent:IsWorld()
		local offset
		if ignoreFraction then
			offset = Vector()
		else
			offset = forward
		end

		local tracePos = pos + offset
		local traceLen = 16.5
		local traceOffset = vFireBaseRadius(targetState) * 0.4
		local traceDir = forward * -traceLen
		
		local up = self:GetUp()
		local down = -up
		local right = self:GetRight()
		local left = -right

		local upTr = util.QuickTrace(tracePos + up * traceOffset, traceDir, function(ent) return ent == parent end)
		local downTr = util.QuickTrace(tracePos + down * traceOffset, traceDir, function(ent) return ent == parent end)
		local goodUp = upTr.Hit and upTr.Entity == parent and (ignoreFraction or upTr.Fraction > 0)
		local goodDown = downTr.Hit and downTr.Entity == parent and (ignoreFraction or downTr.Fraction > 0)

		if !goodUp and !goodDown then return false end

		local rightTr = util.QuickTrace(tracePos + right * traceOffset, traceDir, function(ent) return ent == parent end)
		local leftTr = util.QuickTrace(tracePos + left * traceOffset, traceDir, function(ent) return ent == parent end)
		local goodRight = rightTr.Hit and rightTr.Entity == parent and (ignoreFraction or rightTr.Fraction > 0)
		local goodLeft = leftTr.Hit and leftTr.Entity == parent and (ignoreFraction or leftTr.Fraction > 0)

		if !goodRight and !goodLeft then return false end

		local sum = 0
		local sumVec = Vector()
		
		if goodUp then sum = sum + 1; sumVec = sumVec + upTr.HitPos end
		if goodDown then sum = sum + 1; sumVec = sumVec + downTr.HitPos end
		if goodRight then sum = sum + 1; sumVec = sumVec + rightTr.HitPos end
		if goodLeft then sum = sum + 1; sumVec = sumVec + leftTr.HitPos end

		if sum > 0 then
			local newPos = sumVec / sum
			tracePos = newPos + offset

			if !goodUp then
				upTr = util.QuickTrace(tracePos + up * traceOffset, traceDir, function(ent) return ent == parent end)
				goodUp = upTr.Hit and upTr.Entity == parent and (ignoreFraction or upTr.Fraction > 0)
				if !goodUp then return false end
			end

			if !goodDown then
				downTr = util.QuickTrace(tracePos + down * traceOffset, traceDir, function(ent) return ent == parent end)
				goodDown = downTr.Hit and downTr.Entity == parent and (ignoreFraction or downTr.Fraction > 0)
				if !goodDown then return false end
			end

			if !goodRight then
				rightTr = util.QuickTrace(tracePos + right * traceOffset, traceDir, function(ent) return ent == parent end)
				goodRight = rightTr.Hit and rightTr.Entity == parent and (ignoreFraction or rightTr.Fraction > 0)
				if !goodRight then return false end
			end

			if !goodLeft then
				leftTr = util.QuickTrace(tracePos + left * traceOffset, traceDir, function(ent) return ent == parent end)
				goodLeft = leftTr.Hit and leftTr.Entity == parent and (ignoreFraction or leftTr.Fraction > 0)
				if !goodLeft then return false end
			end

			if goodUp and goodDown and goodRight and goodLeft then
				local fixedPos = util.IntersectRayWithPlane(newPos, forward, pos, forward)
				if fixedPos then newPos = fixedPos end
				return true, newPos
			end
		else
			return false
		end
	end

	function ENT:UpdateCollisionBounds(state)
		local col = vFireBaseRadius(state) * 0.2
		self:SetCollisionBounds(Vector(-col, -col, -col), Vector(col, col, col))
		self:UseTriggerBounds(true, col)
	end

	function ENT:Think()
		if !IsValid(self.parent) and !self.parent:IsWorld() then self:Remove() return end
		
		local curTime = CurTime()
		local throttleAdd = self:IsPrioritized() and 0 or vFireThinkThrottle

		if curTime >= self.nextFuelThink then
			self:FuelThink()
			self.nextFuelThink = curTime + vFireFuelThinkTickRate + throttleAdd
		end

		if curTime >= self.nextLifeThink then
			self:LifeThink()
			self.nextLifeThink = curTime + vFireLifeThinkTickRate + throttleAdd
		end

		if curTime >= self.nextEatThink then
			self:EatThink()
			self.nextEatThink = curTime + vFireEatThinkTickRate + throttleAdd
		end

		if curTime >= self.nextBurnThink then
			self:BurnThink()
			self.nextBurnThink = curTime + 0.5
		end

		local ran
		if curTime >= self.nextDropThink then
			if !ran then ran = math.random(0, 1000 + vFiresCount * 10) end
			self:DropThink(ran)
			self.nextDropThink = curTime + vFireDropThinkTickRate + throttleAdd
		end

		if curTime >= self.nextSpreadThink then
			if !ran then ran = math.random(0, 1000 + vFiresCount * 10) end
			self:SpreadThink(ran)
			self.nextSpreadThink = curTime + vFireSpreadThinkTickRate + throttleAdd
		end

		local nextThink = math.Min(self.nextFuelThink, self.nextLifeThink, self.nextEatThink, self.nextBurnThink, self.nextDropThink, self.nextSpreadThink)
		self:NextThink(nextThink)
		return true
	end

	function ENT:FuelThink()
		local take = self.life
		local fuel = vFireTakeFuel(self.parent, take * 2)
		
		if fuel > 0 then
			self.feed = self.feed + fuel
		else
			if !self.clusterFuels then self.clusterFuels = 10 end
			if self.clusterFuels > 0 then
				local cluster = self.cluster
				if IsValid(cluster) then
					fuel = vFireTakeFuel(self.cluster, take)
					self.feed = self.feed + fuel
					self.clusterFuels = self.clusterFuels - 1
				end
			end
		end

		local ent = table.Random(self.burning)
		if IsValid(ent) then
			local fuel = vFireTakeFuel(ent, take)
			if fuel > 0 then
				self.feed = self.feed + fuel
			end
		end
	end

	function ENT:LifeThink()
		if (self.life <= 0) or self:WaterLevel() > 0 then
			self:Remove()
			return
		else
			local feedSave = vFireIsCharacter(self.parent) and 1 or 5
			local f = math.Min(math.Rand(0, self.feed / feedSave) + 1, self.feed)
			self.feed = self.feed - f

			if self:IsPrioritized() then
				self:ChangeLife(self.life + f)
			else
				local decayMul = 1 - vFireDecayRate
				self:ChangeLife(self.life * decayMul + f - vFireLifeThrottle)
				if self.life <= 0 then self:Remove() return end
			end
		end

		local oldState = self:GetFireState()
		local state = vFireLifeToState(self.life)
		
		if state != oldState then
			if state <= self.stateDown then
				if state > self.stateUp then
					local canGrow, newPos
					while !canGrow do
						if state <= self.stateUp then break end
						canGrow, newPos = self:ImprovePlacement(state)
						if canGrow then
							self.stateUp = state
							self:SetPos(newPos)
						else
							if state == 1 then break end
							self.stateDown = state - 1
							state = self.stateDown
						end
					end
				end
			end
			self:SetFireState(state)
			self:UpdateCollisionBounds(state)
		end
	end

	function ENT:EatThink()
		if !vFireIsCharacter(self.parent) then
			local closestSmallerFire, closestSmallerFireDist = self:GetClosestSmallerFire()
			if IsValid(closestSmallerFire) and closestSmallerFireDist then
				if closestSmallerFireDist <= vFireBaseRadius(self:GetFireState()) * 0.7 then
					self:Eat(closestSmallerFire)
				end
			end
		end
	end
	
	ENT.PainMultiplier = 0.15

	function ENT:BurnThink()
		local damageEnabled = vFireEnableDamage and vFireDamageMultiplier > 0
		local owner = self:GetOwner()
		if !IsValid(owner) then owner = nil end
		local amount = self.life * math.Rand(0.01, 0.08) * vFireDamageMultiplier
		
		for _, ent in pairs(self.burning) do
			if IsValid(ent) then
				if ent:IsPlayer() and ent:InVehicle() and !vFireEnableDamageInVehicles then continue end

				if damageEnabled then
					local dmg = DamageInfo()
					if ent.vFireDamageData == nil then vFireSetDamageData(ent) end
					if !ent.vFireDamageData then continue end
					
					dmg:SetDamage(amount * ent.vFireDamageData.dmgMul)
					dmg:SetDamageType(ent.vFireDamageData.dmgType)
					dmg:SetDamageForce(VectorRand(-0.1,0.1))
					
					local doer = owner or ent
					dmg:SetAttacker(doer)
					dmg:SetInflictor(self)
					ent:TakeDamageInfo(dmg)
				end
				
				if vFireIsCharacter(ent) and vFireEnableSpread then
					if (ent:IsPlayer() and hg.GetCurrentCharacter(ent):IsPlayer() and math.random(1, 6) == 1) or !ent:IsPlayer() then
						local newFeed = self.feed + vFireTakeFuel(ent, 12)
						if newFeed > 0 then
							CreateVFire(ent, ent:GetPos(), Vector(), newFeed, self)
						end
					end
				end
			else
				self.burning[k] = nil
			end
		end

		local parent = self.parent
		if damageEnabled and !parent:IsWorld() then
			local dmg = DamageInfo()
			if parent.vFireDamageData == nil then vFireSetDamageData(parent) end
			if !parent.vFireDamageData then return end
			
			dmg:SetDamage(amount * parent.vFireDamageData.dmgMul)
			dmg:SetDamageType(parent.vFireDamageData.dmgType)
			dmg:SetDamageForce(VectorRand(-0.1,0.1))
			
			local doer
			if parent:Health() - dmg:GetDamage() <= 0 then
				doer = owner or parent
			else
				doer = parent
			end
			dmg:SetAttacker(doer)
			dmg:SetInflictor(self)
			parent:TakeDamageInfo(dmg)
		end

		if parent:IsPlayer() then
			if !self.stickToPlayer then self.stickToPlayer = math.random(15, math.max(self:GetFireState(),30)) end
			if self.stickToPlayer > 0 then
				self.stickToPlayer = self.stickToPlayer - 1
			else
				self:Drop()
			end
		end
	end

	function ENT:DropThink(ran)
		if ran < 150 then
			if self.life < 7 then
				if self.cantDrop then return end
				if self.parent:IsRagdoll() or self.parent:IsPlayer() then return end
				local dropPos = self:GetPos() + self:GetForward()
				local tr = util.QuickTrace(dropPos, Vector(0, 0, -5))
				if !tr.Hit then
					self:Drop()
				else
					self.cantDrop = !vFireIsMobile(self.parent)
				end
			end
		end
	end
	
	ENT.totalparticles = 3
	ENT.gasparticles = 0
	ENT.NextParticle = 0

	hg = hg or {}
	hg.particles = hg.particles or {}

	vfireallowspreadon = {
		[MAT_GRASS] = true,
		[MAT_WOOD] = true,
		[MAT_TILE] = true,
		[MAT_PLASTIC] = true,
	}

	function ENT:SpreadThink(ran)
		if vFireEnableSpread then
			if !self:IsPotentiallyVisible() then return end
			
			for _,v in ipairs(hg.gasolinePath) do
				if v[1]:Distance(self:GetPos()) > (vFireBaseRadius(self:GetFireState() or 1) or 1) or v[2] ~= false then continue end
				v[2] = CurTime()
				v[3] = self:GetOwner()
			end

			if self.NextParticle < CurTime() and vFireLifeToState(self.life) > 4 then
				self.NextParticle = CurTime() + 2
				if (self.gasparticles < self.totalparticles) then
					table.insert(hg.particles, {self:GetPos(), VectorRand(-15, 15), CurTime() + 120})
					self.gasparticles = self.gasparticles + 1
				end
				if (self.gasparticles == self.totalparticles) then return end
			end
			
			if ran < 1000 then
				local forward = self:GetForward()
				if ran < 575 then
					local upwards = Vector(0, 0, 1)
					local dir = upwards + self:GetWindVector() + VectorRand()
					dir = dir * (vFireBaseRadius(self:GetFireState() or 1) or 1)
					local tr = util.QuickTrace(self:GetPos(), dir, self.parent)
					if tr.Hit and tr.Fraction > 0 then
						local ent = tr.Entity
						if vFireIsVFireEnt(ent) then return end
						local newFeed = self.feed + vFireTakeFuel(ent, 12)
						if newFeed > 0 then
							CreateVFire(ent, tr.HitPos, tr.HitNormal, newFeed, self)
						end
					end
				else
					local mul = (vFireBaseRadius(self:GetFireState() or 1) or 1) * math.Rand(0.775, 1)
					local dir = forward * -mul
					local ang = self:GetAngles()
					
					if !self.spreadAng then self.spreadAng = math.Rand(0, 360) end
					ang:RotateAroundAxis(forward, self.spreadAng)
					local offset = ang:Right() * mul + forward * 2
					local pos = self:GetPos() + offset
					local tr = util.QuickTrace(pos, dir)
					local ent = tr.Entity
					
					if tr.Hit and vfireallowspreadon[tr.MatType] and (tr.Fraction > 0 or IsValid(ent)) then
						if vFireIsVFireEnt(ent) then return end
						local newFire
						local newFeed = self.feed + vFireTakeFuel(ent, 12)
						if newFeed > 0 then
							newFire = CreateVFire(ent, tr.HitPos, tr.HitNormal, newFeed, self)
						end
						
						if IsValid(newFire) then
							if self.spreadAng then
								local spreadAngRan = math.Rand(-60, 60)
								newFire.spreadAng = self.spreadAng + spreadAngRan
								self.spreadAng = self.spreadAng - spreadAngRan
							end
						else
							self.spreadAng = nil
						end
					else
						self.spreadAng = nil
					end
				end
			end
		end
	end
end

--[[-------------------------------------------------------------------------
	Client Functionalities (ИЗМЕНЕНА ДЛЯ ПОДДЕРЖКИ НАСТРОЕК)
---------------------------------------------------------------------------]]
if CLIENT then

	-- Функции для получения настроек
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

	local function IsLowQualityFire()
		return GetConVarNumber("hg_opt_fire_quality") == 1
	end

	local function IsHighQualityFire()
		return GetConVarNumber("hg_opt_fire_quality") >= 2
	end

	local function IsFireDlightEnabled()
		return GetConVarNumber("hg_opt_fire_dlight") == 1
	end

	local function IsFireGlowEnabled()
		return GetConVarNumber("hg_opt_fire_glow") == 1
	end

	function ENT:RedoParticles(state)
		if !IsValid(self) then return end
		
		local isLowQuality = IsLowQualityFire()
		self.visState = state

		if self.flames then
			if self.flames:IsValid() then 
				self.flames:StopEmission()
			end
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

	local pullForceControlPointIndex = 2
	local stateMul = {30, 45, 65, 115, 245, 345, 400}
	local minStrength = 1 / 1000000000
	
	function ENT:FlameSetDirection(dir, strength)
		if IsLowQualityFire() then return end
		
		if IsValid(self.flames) then
			dir:Normalize()
			dir = dir * stateMul[self:GetFireState()]
			local pos
			if strength then
				pos = self:GetPos() + dir / math.Clamp(strength, minStrength, 1)
			else
				pos = self:GetPos() + dir
			end
			self.flames:SetControlPoint(pullForceControlPointIndex, pos)
		end
	end

	function ENT:BasePullToPoint(pos)
		if IsLowQualityFire() then return end
		
		if IsValid(self.base) then
			vFirePullParticlesToPos(self.base, pos)
		end
	end

	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	local lightmat = Material("sprites/light_ignorez")
	local lightDecay = 600
	local lightCalls = {}
	for i = 1, vFireMaxState do
		lightCalls[i] = {}
	end
	local glowCalls = {}
	local blue = 10
	local yellow = 100

	function ENT:Draw()
		if self.LOD == 1 then return end
		if self.hiddenForPotato then return end
		
		local isLowQuality = IsLowQualityFire()
		if isLowQuality then return end

		local state = self.visState
		
		if state == 1 then
			self.a = Lerp(FrameTime() * 2, self.a, 0)
		else
			self.a = Lerp(FrameTime() * 2, self.a, math.Rand(0, state) * 5)
		end

		local a = self.a
		if a < 0.1 then return end

		local pos = self:GetPos() + self:GetForward() * 7
		local aSqrd = a * a

		if IsFireGlowEnabled() and vFireEnableGlows then
			local vis = util.PixelVisible(pos, 1, self.pVis)
			if vis > 0 then
				local glowSize = vis * aSqrd * 6
				table.insert(glowCalls, {
					pos = pos,
					glowSize = glowSize,
					aSqrd = aSqrd
				})
			end
		end

		if IsFireDlightEnabled() and self.LOD == false then
			local entIndex = self:EntIndex()
			lightCalls[state][entIndex] = {
				pos, a, aSqrd * 2
			}
		end
	end

	hook.Add("PostDrawTranslucentRenderables", "_vFireLightCallbacks", function()
		for key, glowData in pairs(glowCalls) do
			render.SetMaterial(lightmat)
			render.DrawSprite(
				glowData.pos,
				glowData.glowSize,
				glowData.glowSize,
				Color(255, yellow, blue, math.Min(glowData.aSqrd * 0.85, 255))
			)
		end
		glowCalls = {}
	end)

	local maxLights = 100

	hook.Add("Think", "_vFireLightCallbacks", function()
		if not IsFireDlightEnabled() then return end
		
		local lightsDrawn = 0
		for state = vFireMaxState, 1, -1 do
			for entIndex, callback in pairs(lightCalls[state]) do
				local dLight = DynamicLight(entIndex)
				if dLight then
					dLight.Pos = callback[1]
					dLight.r = 255
					dLight.g = yellow
					dLight.b = blue
					dLight.Brightness = callback[2] * vFireLightMul
					dLight.Decay = lightDecay
					dLight.Size = callback[3]
					dLight.DieTime = CurTime() + 10
					lightsDrawn = lightsDrawn + 1
					if lightsDrawn >= maxLights then break end
				end
			end
			lightCalls[state] = {}
			if lightsDrawn >= maxLights then break end
		end
	end)

	function ENT:Think()
		local curTime = CurTime()
		local throttleAdd = self:IsPrioritized() and 0 or vFireThinkThrottle
		local isLowQuality = IsLowQualityFire()

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
		if isLowQuality then
			thinkRate = math.max(thinkRate, 0.5)
		end
		
		local ranTime = math.Rand(-0.1, 0.1)
		self:SetNextClientThink(curTime + thinkRate + ranTime)
		return true
	end

	function ENT:ClusterThink()
		local netCluster = self:GetNW2Entity("FireCluster")
		if IsValid(netCluster) and netCluster.AddFire then
			if !self.cluster or self.cluster != netCluster then
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

	function ENT:ParticlesThink()
		self.LOD = vFireGetLOD(self)
		
		local shouldRedoParticles = false
		local lastState = self.lastState
		local state = self:GetFireState()
		self.lastState = state
		
		if state != lastState then
			shouldRedoParticles = true
			local renderSize = state * 20
			self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(renderSize, renderSize, renderSize))
			
			if not IsLowQualityFire() then
				self:FlameSetDirection(self:GetVelocity(), 1)
			end
		end

		local LODActive = false
		if self.LOD then LODActive = true end

		if LODActive != self.visLOD then
			shouldRedoParticles = true
		end

		if shouldRedoParticles and self.RedoParticles then
			self:RedoParticles(state)
		end
		
		-- Принудительно применяем настройки качества
		if IsLowQualityFire() then
			self.LOD = true
		end
	end

	function ENT:AnimationThink()
		if IsLowQualityFire() then return end
		
		local forward = self:GetForward()
		local mul = (1 - forward.z) * 15 + 1
		self:BasePullToPoint(self:GetPos() + forward * mul)

		local pullDir = Vector()
		local pullStrength = 0

		local windVec = self:GetWindVector()
		local windExposure = windVec:Length()
		
		if windExposure > 0.1 then
			local windProd = windVec:Dot(forward)
			local prodMul = 1 - math.abs(math.Clamp(windProd, -1, 1))
			local windMul = prodMul * windExposure
			pullDir = windVec * windMul
			pullStrength = windMul
		end

		local upSideDownMul = -forward.z
		if upSideDownMul > 0 then
			pullDir = pullDir + forward * upSideDownMul
			pullStrength = pullStrength + upSideDownMul
		end
		
		if pullDir and pullDir != Vector(0, 0, 0) and pullStrength != 0 then
			self.lastFlameDir = pullDir
			self:FlameSetDirection(pullDir, pullStrength)
		else
			self:FlameSetDirection()
		end
	end
	
	-- Хук для обновления настроек
	hook.Add("OnConVarChanged", "VFireSettingsUpdate", function(name, old, new)
		if name == "hg_opt_fire_limit_enabled" or 
		   name == "hg_opt_fire_limit_amount" or 
		   name == "hg_opt_fire_quality" or 
		   name == "hg_opt_fire_dlight" or 
		   name == "hg_opt_fire_glow" then
			
			for _, fire in ipairs(ents.FindByClass("vfire")) do
				if IsValid(fire) then
					fire:ParticlesThink()
					fire:ClusterThink()
				end
			end
		end
	end)
end