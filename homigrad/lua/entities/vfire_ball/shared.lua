--[[-------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

vFire Ball by Vioxtar
Optimized for HG Potato Mode

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "FireState")
end

--[[-------------------------------------------------------------------------
In charge of updating particle systems (CLIENT ONLY)
---------------------------------------------------------------------------]]
if CLIENT then
	function ENT:Initialize()
		-- Клиент НЕ ДОЛЖЕН удалять серверные энтити
		-- Просто отключаем рендер и партиклы
		local isPotato = GetConVarNumber("hg_potatopc") == 1
		if isPotato then
			self:SetNoDraw(true)
			self:SetRenderBounds(Vector(0,0,0), Vector(0,0,0))
			-- Не вызываем self:Remove() на клиенте!
			return
		end
	end

	function ENT:RedoParticles(state)
		if !IsValid(self) then return end

		self.visState = state

		if self.flames then
			if self.flames:IsValid() then 
				self.flames:StopEmission()
			end
		end

		local size = vFireStateToSize(state)
		self.visLOD = false
		local LODStr = ""
		if self.LOD then
			LODStr = "_LOD"
			self.visLOD = true
		end

		self.flames = CreateParticleSystem(
			self,
			"vFire_Flames_"..size..LODStr,
			1,
			0,
			Vector(0, 0, 0)
		)
	end

	local pullForceControlPointIndex = 2
	local stateMul = {30, 45, 65, 115, 245, 345, 400}
	local minStrength = 1 / 1000000000
	
	function ENT:FlameSetDirection(dir, strength)
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
end

--[[-------------------------------------------------------------------------
SERVER ONLY
---------------------------------------------------------------------------]]
if SERVER then
	function ENT:ChangeLife(newLife)
		self.life = math.min(newLife, vFireMaxLife)
		self:SetFireState(vFireLifeToState(self.life))

		if self.life <= 0 then
			self:Remove()
		end
	end

	function ENT:Ignore(ent)
		self.ignore[ent] = true
	end
	
	function ENT:StopIgnoring(ent)
		if self.ignore[ent] then
			self.ignore[ent] = nil
		end
	end

	function ENT:RandomStickSkip()
		return math.Rand(0, 1) >= self.stickProbability
	end

	function ENT:TimedRemoval(time)
		if !time then time = math.Rand(0.3, 0.8) end

		timer.Simple(time, function()
			if IsValid(self) then self:Remove() end
		end)
	end

	function ENT:StickFire(parent, pos, normal)
		local feedFactor = math.Rand(0.5, 1)

		timer.Simple(0, function()
			if !IsValid(parent) and !parent:IsWorld() then return end
			if !self.feedCarry then return end
			local fire = CreateVFire(parent, pos, normal, self.feedCarry * feedFactor, self)

			if IsValid(fire) then
				fire:ChangeLife(self.life * (1 - feedFactor))
				fire:SetFireState(math.max(math.Round(1*(self.feedCarry/10),0),1))
			end
		end)

		self:TimedRemoval()
	end

	function ENT:AttemptFireStick()
		local vel = self.oldVel or self:GetVelocity()
		local tr = util.QuickTrace(self:GetPos(), vel, self)
		if tr.Hit and !tr.HitSky then
			local ent = tr.Entity
			if vFireIsVFireEnt(ent) then return false end
			self:StickFire(ent, tr.HitPos, tr.HitNormal)
			return true
		end
		return false
	end

	function ENT:StartTouch(ent)
		if self.stuck then return end
		if self:RandomStickSkip() then return end

		if ent then
			if self.ignore[ent] or vFireIsVFireEnt(ent) then return end
		end

		if vFireIsCharacter(ent) then
			self:StickFire(ent, ent:GetPos(), VectorRand())
			self.stuck = true
		else
			self.stuck = self:AttemptFireStick()
		end

		if self.stuck then
			hook.Run("vFireBallStuckFire", self, ent)
		end
	end

	function ENT:PhysicsCollide(colData, collider)
		if self.stuck then return end
		if self:RandomStickSkip() then return end

		local ent = colData.HitEntity
		
		if ent then
			if self.ignore[ent] or vFireIsVFireEnt(ent) then return end
		end

		if vFireIsCharacter(ent) then
			self:StickFire(ent, ent:GetPos(), VectorRand())
			self.stuck = true
		else
			self.stuck = self:AttemptFireStick()
		end
		
		if self.stuck then
			hook.Run("vFireBallStuckFire", self, ent)
		end
	end

	function ENT:PhysicsUpdate()
		if self:WaterLevel() > 0 then
			timer.Simple(0, function()
				if IsValid(self) then
					self:Remove()
				end
			end)
		end

		if self.stuck then return end
		self.oldVel = self:GetVelocity()
	end

	function ENT:SetStickProbability(prob)
		self.stickProbability = prob
	end
end

--[[-------------------------------------------------------------------------
INITIALIZATION
---------------------------------------------------------------------------]]
local radius = 0.01

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	if SERVER then
		self.ignore = {}
		self:Ignore(self:GetOwner())
		self.stickProbability = 2/3
		self:PhysicsInitSphere(radius, "default_silent")
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetDamping(0.85, 0)
			phys:SetMass(1)
			phys:Wake()
		end

		self:SetTrigger(true)
		self:SetCollisionBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
		self:UseTriggerBounds(true, radius)

		self.life = 0
		self.stuck = false
		self.feedCarry = 0
	end

	if CLIENT then
		local isPotato = GetConVarNumber("hg_potatopc") == 1
		
		if isPotato then
			-- НЕ УДАЛЯЕМ на клиенте! Просто отключаем отрисовку
			self:SetNoDraw(true)
			self:SetRenderBounds(Vector(0,0,0), Vector(0,0,0))
			return
		end
		
		local state = 1
		self.lastState = 1
		self.visState = 1
		self.LOD = false
		self.visLOD = false
	
		self:RedoParticles(1)
		self:Think()
	end
end

--[[-------------------------------------------------------------------------
ON REMOVE
---------------------------------------------------------------------------]]
function ENT:OnRemove()
	if CLIENT then
		if self.flames then
			if self.flames:IsValid() then 
				self.flames:StopEmission()
			end
		end
		if self.base then
			if self.base:IsValid() then 
				self.base:StopEmission()
			end
		end
	end
end

--[[-------------------------------------------------------------------------
THINK
---------------------------------------------------------------------------]]
local serverTickRate = 0.2
local clientTickRate = 0.3

function ENT:Think()
	if CLIENT then
		local isPotato = GetConVarNumber("hg_potatopc") == 1
		
		if isPotato then
			return false  -- Просто выключаем Think
		end
		
		self.LOD = vFireGetLOD(self)

		local shouldRedoParticles = false
		local lastState = self.lastState
		local state = self:GetFireState()
		self.lastState = state
		
		if state != lastState then
			shouldRedoParticles = true
			local renderSize = state * 20
			self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(renderSize, renderSize, renderSize))
			self:FlameSetDirection(self:GetVelocity(), 1)
		end

		local LODActive = false
		if self.LOD then LODActive = true end

		if LODActive != self.visLOD then
			shouldRedoParticles = true
		end

		if shouldRedoParticles and self.RedoParticles then
			self:RedoParticles(state)
		end
	end

	if SERVER then
		self:ChangeLife(self.life - 1)
	end

	if SERVER then 
		self:NextThink(CurTime() + serverTickRate) 
	end
	
	if CLIENT then 
		self:SetNextClientThink(CurTime() + clientTickRate) 
	end

	return true
end

--[[-------------------------------------------------------------------------
DRAW (CLIENT)
---------------------------------------------------------------------------]]
if CLIENT then
	function ENT:Draw()
		-- Do nothing
	end
end