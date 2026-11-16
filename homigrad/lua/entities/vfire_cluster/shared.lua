--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire Cluster by Vioxtar
Optimized for HG with separate settings

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

--[[-------------------------------------------------------------------------
Some helper functions because Set/Get LocalPos() can't handle world parents
---------------------------------------------------------------------------]]
local function GetRelPos(v)
	if v.parent:IsWorld() then
		return v:GetPos()
	else
		return v:GetLocalPos()
	end
end

local function SetRelPos(v, pos)
	if v.parent:IsWorld() then
		v:SetPos(pos)
	else
		v:SetLocalPos(pos)
	end
end

--[[-------------------------------------------------------------------------
Add a fire to the cluster
---------------------------------------------------------------------------]]
function ENT:AddFire(fire)
	if !IsValid(fire) or fire.parent != self.parent then return end
	if self.fires[fire] then return end

	local cluster = fire:GetNW2Entity("FireCluster")
	if IsValid(cluster) then
		cluster:RemFire(fire)
	end

	self.fires[fire] = fire
	fire.cluster = self

	if self.cnt == 0 then
		SetRelPos(self, GetRelPos(fire))
	else
		local p = GetRelPos(self)
		p = (p * self.cnt + GetRelPos(fire)) / (self.cnt + 1)
		SetRelPos(self, p)
	end
	
	if !self.parent.fireClusters then
		self.parent.fireClusters = {}
		hook.Run("vFireEntityStartedBurning", self.parent)
	end
	
	if self.parent.fireClusters then
		self.parent.fireClusters[self] = GetRelPos(self)
	end
	
	self.cnt = self.cnt + 1

	if SERVER then fire:SetNW2Entity("FireCluster", self) end

	local minDist = math.huge
	local closestFire
	local minDistSmaller = math.huge
	local closestFireSmaller
	local minDistBigger = math.huge
	local closestFireBigger

	self.distMem[fire] = {}
	for k, fire2 in pairs(self.fires) do
		if !IsValid(fire2) then continue end
		local dist = 0
		if fire != fire2 then
			dist = fire:GetPos():Distance(fire2:GetPos())
			if dist < minDist then
				minDist = dist
				closestFire = fire2
			end
			if dist < minDistSmaller then
				minDistSmaller = dist
				closestFireSmaller = fire2
			end
			if dist < minDistBigger then
				minDistBigger = dist
				closestFireBigger = fire2
			end
		end
		self.distMem[fire][fire2] = dist
		self.distMem[fire2][fire] = dist
	end

	fire.closestFire = closestFire
	fire.closestSmallerFire = closestFireSmaller
	fire.closestBiggerFire = closestFireBigger
end

--[[-------------------------------------------------------------------------
Remove a fire from the cluster
---------------------------------------------------------------------------]]
function ENT:RemFire(fire)
	if !IsValid(fire) then return end
	if !self.fires[fire] then return end

	if self.cnt - 1 <= 0 then
		if SERVER then self:Remove() end
		return
	end

	self.fires[fire] = nil
	fire.cluster = nil

	local p = GetRelPos(self)
	p = (p * self.cnt - GetRelPos(fire)) / (self.cnt - 1)
	SetRelPos(self, p)
	
	if IsValid(self.parent) and self.parent.fireClusters then
		self.parent.fireClusters[self] = GetRelPos(self)
	end

	self.cnt = self.cnt - 1

	self.distMem[fire] = nil
	for k, fire2 in pairs(self.fires) do
		self.distMem[fire2][fire] = nil
	end
end

local windExposureCheckTime = 45
function ENT:CalcWindExposure()
	self.windExposure = 1
end

if SERVER then
	local pvsLODCheckTime = 100
	function ENT:CalcPVSLOD()
		for k, ply in player.Iterator() do
			self.PVSLOD = self:TestPVS(ply:GetPos())
			if self.PVSLOD then break end
		end
		timer.Simple(pvsLODCheckTime, function()
			if IsValid(self) then
				self:CalcPVSLOD()
			end
		end)
	end
end

function ENT:Initialize()
	if not IsValid(self) then return end
	
	local parent = self:GetNW2Entity("ClusterParent")
	if SERVER then
		if !IsValid(parent) and !parent:IsWorld() then
			self:Remove()
			return
		end
	end

	if IsValid(parent) then self:SetParent(parent) end
	self.parent = parent

	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	self.fires = {}
	self.cnt = 0

	self:CalcWindExposure()

	if SERVER then
		self:CalcPVSLOD()
	end

	if CLIENT then
		local soundName = table.Random(list.Get("vFireLoopSounds"))
		self.sound = CreateSound(self, soundName)
		self.sound:PlayEx(0.4, 100)
		self.sound:SetSoundLevel(180, 0.1)
		self.LOD = false
	end

	self.distMem = {}
end

function ENT:OnRemove()
	if CLIENT then
		local snd = self.sound
		local stopAttempts = 1
		while snd:IsPlaying() and stopAttempts <= 50 do
			snd:Stop()
			stopAttempts = stopAttempts + 1
		end
	end

	if SERVER then
		self:SetPos(Vector())
	end

	local parent = self.parent
	if parent == nil then
		hook.Run("vFireEntityStoppedBurning", parent)
		return
	end
	
	if !IsValid(parent) and !parent:IsWorld() then
		hook.Run("vFireEntityStoppedBurning", parent)
		return
	end

	if parent.fireClusters then
		parent.fireClusters[self] = nil
		if table.Count(parent.fireClusters) <= 0 then
			hook.Run("vFireEntityStoppedBurning", parent)
			parent.fireClusters = nil
		end
	end
end

--[[-------------------------------------------------------------------------
CLIENT Functionalities (Optimized for HG)
---------------------------------------------------------------------------]]
if CLIENT then
	local function IsLowQualityFire()
		return GetConVarNumber("hg_opt_fire_quality") == 1
	end

	local function IsFireLimitEnabled()
		return GetConVarNumber("hg_opt_fire_limit_enabled") == 1
	end

	function ENT:GetClusterMagnitude()
		local maxState = 0
		for k, fire in pairs(self.fires) do
			if IsValid(fire) then
				local state = fire:GetFireState()
				if state > maxState then
					maxState = state
				end
			end
		end
		return math.Min(maxState * 0.2, 1)
	end

	local clientTickRate = 3
	local lowQualityTickRate = 6

	function ENT:Think()
		local curTime = CurTime()
		local isLowQuality = IsLowQualityFire()
		local rate = isLowQuality and lowQualityTickRate or clientTickRate
		
		self.LOD = isLowQuality or vFireGetLOD(self)

		if not self.LOD then
			local clusterMagnitude = self:GetClusterMagnitude()
			if isLowQuality then
				self.sound:ChangeVolume(clusterMagnitude * 0.3, rate)
				self.sound:ChangePitch(100, rate)
			else
				self.sound:ChangeVolume(clusterMagnitude, rate)
				self.sound:ChangePitch(120 - 40 * clusterMagnitude, rate)
			end
		end

		self:SetNextClientThink(CurTime() + rate)
		return true
	end
end