AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "The Ancient Wendigo"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Spawnable = false

-- we need to code this EXTRA defensively, because we don't want to generate any errors
-- that would ruin the secret

if (SERVER) then

	ENT.HauntedPlayer = nil
	function ENT:Initialize()
		self:SetModel("models/ancient jendigo/ancient jendigo.mdl")
		self:PhysicsInit(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(false)
	end

	function ENT:Think()
		local Time = CurTime()

		-- Check if we need to switch players
		local needNewPlayer = false
		
		if not(IsValid(self.HauntedPlayer) and self.HauntedPlayer:Alive()) then
			needNewPlayer = true
		elseif self.HauntedPlayer:InVehicle() then
			-- Switch if player is in a vehicle
			needNewPlayer = true
		elseif math.random(1, 100) == 1 then
			needNewPlayer = true
		end
		
		if needNewPlayer then
			-- Find a new player to haunt
			local allPlayers = player.GetHumans()
			local validPlayers = {}
			
			for k, ply in pairs(allPlayers) do
				if IsValid(ply) and ply:Alive() and not ply:InVehicle() and ply ~= self.HauntedPlayer then
					table.insert(validPlayers, ply)
				end
			end
			
			-- If we have valid players, pick a random one
			if #validPlayers > 0 then
				self.HauntedPlayer = validPlayers[math.random(1, #validPlayers)]
			elseif IsValid(self.HauntedPlayer) and self.HauntedPlayer:Alive() then
				-- Keep current player if no other options
			else
				-- Fallback to any alive player
				for k, ply in pairs(allPlayers) do
					if IsValid(ply) and ply:Alive() then
						self.HauntedPlayer = ply
						break
					end
				end
			end
		end
		
		-- Update position if we have a valid haunted player
		if IsValid(self.HauntedPlayer) and self.HauntedPlayer:Alive() then
			local Tr = util.QuickTrace(self.HauntedPlayer:GetShootPos(), self.HauntedPlayer:GetAimVector() * 3000, {self.HauntedPlayer})
			self:SetPos(Tr.HitPos + Tr.HitNormal * 100)
		end
		
		self:NextThink(Time + 1)
		return true
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

elseif (CLIENT) then
	-- Rendering state
	ENT.StoredRenderPos = nil
	ENT.StoredRenderAngle = nil
	ENT.RenderUntil = 0
	ENT.FadeOutDuration = 0.1 -- Fade out over 0.1 seconds
	ENT.SpawnMode = "rotation"
	
	-- Rotation tracking
	ENT.LastYaw = 0
	ENT.LastCheckTime = 0
	ENT.NextAllowedTrigger = 0
	ENT.LastRotationDirection = 0 -- 1 = rotating right, -1 = rotating left
	
	-- Velocity tracking for straight line detection
	ENT.LastVelocity = Vector(0, 0, 0)
	ENT.LastVelocityCheckTime = 0
	ENT.StraightLineStartTime = 0
	ENT.IsStraightLine = false
	
	-- Random sound tracking
	ENT.NextRandomSoundCheck = 0
	
	-- Spawn chance modifier (increased when scream plays, reset when seen)
	ENT.SpawnChanceModifier = 1
	
	-- Find a spawn position at the edge of the player's screen
	-- centerBias: 0 = far edge (40-45% FOV), 1 = more centered (15-20% FOV)
	-- side: 1 = right, -1 = left, nil = random
	function ENT:FindEdgeSpawn(centerBias, side)
		local ply = LocalPlayer()
		if not IsValid(ply) then return nil end
		
		local ViewPos, ViewVec, ViewAng = EyePos(), EyeVector(), EyeAngles()
		ViewVec.z = 0
		ViewVec:Normalize()
		
		-- Calculate horizontal FOV
		local fov = ply:GetFOV()
		local aspectRatio = ScrW() / ScrH()
		local hFOV = 2 * math.atan(math.tan(math.rad(fov) / 2) * aspectRatio)
		
		-- Determine side (random if not specified)
		if side == nil then
			side = math.random(0, 1) == 0 and 1 or -1
		end
		
		-- Calculate edge angle based on center bias
		-- centerBias 0: 40-45% of FOV (far edge)
		-- centerBias 1: 15-20% of FOV (more towards center)
		centerBias = math.Clamp(centerBias or 0, 0, 1)
		local minEdgePercent = 0.15 -- High center bias
		local maxEdgePercent = 0.45 -- Low center bias
		local edgePercent = maxEdgePercent - (centerBias * (maxEdgePercent - minEdgePercent))
		local edgeAngle = math.deg(hFOV) * math.Rand(edgePercent - 0.05, edgePercent)
		
		-- Rotate the forward vector by the edge angle
		local edgeDir = ViewVec
		edgeDir:Rotate(Angle(0, edgeAngle * side, 0))
		
		-- Random distance
		local distance = math.random(800, 1500)
		return ViewPos + edgeDir * distance + Vector(0, 0, 20)
	end

	function ENT:Think()
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then 
			self:NextThink(CurTime())
			return true
		end
		
		local currentTime = CurTime()
		local currentRealTime = RealTime()
		
		-- Initialize tracking on first think
		if self.LastCheckTime == 0 then
			self.LastCheckTime = currentTime
			self.LastYaw = ply:EyeAngles().y
			self.NextRandomSoundCheck = currentTime + 10
		end
		
		-- ROTATION DETECTION
		if self.LastCheckTime ~= 0 then
			local deltaTime = currentTime - self.LastCheckTime
			if deltaTime >= 0.2 then
				local currentYaw = ply:EyeAngles().y
				local yawDelta = math.NormalizeAngle(currentYaw - self.LastYaw)
				local yawDeltaAbs = math.abs(yawDelta)
				
				-- Determine rotation direction
				if yawDelta > 0 then
					self.LastRotationDirection = 1 -- Rotating right (positive yaw)
				elseif yawDelta < 0 then
					self.LastRotationDirection = -1 -- Rotating left (negative yaw)
				end
				
				-- Calculate degrees per second
				local degreesPerSecond = yawDeltaAbs / deltaTime
				
				-- Scale threshold based on FOV
				local currentFOV = ply:GetFOV()
				local baseFOV = 90
				local fovScaledThreshold = 90 * (currentFOV / baseFOV)
				
				-- Check if rotating fast enough and cooldown has expired
				if degreesPerSecond >= fovScaledThreshold and currentTime >= self.NextAllowedTrigger then
					-- 3% chance to actually appear (modified by scream events)
					local baseChance = 33
					local adjustedChance = math.max(1, math.floor(baseChance / self.SpawnChanceModifier))
					if math.random(1, adjustedChance) == 1 then
						self.RenderUntil = currentRealTime + math.Rand(0.15, 0.3)
						self.SpawnMode = "rotation"
					end
					self.NextAllowedTrigger = currentTime + math.Rand(5, 10)
				end
				
				-- Update tracking variables
				self.LastYaw = currentYaw
				self.LastCheckTime = currentTime
			end
		end
		
		-- STRAIGHT LINE RUNNING DETECTION
		local vel = ply:GetVelocity()
		vel.z = 0 -- Ignore vertical movement
		local speed = vel:Length()
		
		if self.LastVelocityCheckTime == 0 then
			self.LastVelocity = vel
			self.LastVelocityCheckTime = currentTime
		else
			local velDeltaTime = currentTime - self.LastVelocityCheckTime
			if velDeltaTime >= 0.1 then
				-- Check if player is moving fast enough (sprinting speed threshold)
				if speed > 200 then
					-- Check if direction is consistent
					local directionChange = 0
					if self.LastVelocity:Length() > 0 and vel:Length() > 0 then
						local lastDir = self.LastVelocity:GetNormalized()
						local currentDir = vel:GetNormalized()
						directionChange = math.deg(math.acos(math.Clamp(lastDir:Dot(currentDir), -1, 1)))
					end
					
					-- If direction change is minimal, consider it straight
					if directionChange < 15 then
						if not self.IsStraightLine then
							self.StraightLineStartTime = currentTime
							self.IsStraightLine = true
						end
						
						-- If running straight for 2+ seconds, trigger wendigo at edge of screen
						if (currentTime - self.StraightLineStartTime) >= 2 and currentTime >= self.NextAllowedTrigger then
							-- 1 in 10 chance to actually appear (modified by scream events)
							local baseChance = 10
							local adjustedChance = math.max(1, math.floor(baseChance / self.SpawnChanceModifier))
							if math.random(1, adjustedChance) == 1 then
								self.RenderUntil = currentRealTime + math.Rand(0.15, 0.3)
								self.SpawnMode = "edge"
							end
							self.NextAllowedTrigger = currentTime + math.Rand(5, 10)
							self.IsStraightLine = false -- Reset
						end
					else
						self.IsStraightLine = false
					end
				else
					self.IsStraightLine = false
				end
				
				self.LastVelocity = vel
				self.LastVelocityCheckTime = currentTime
			end
		end
		
		-- RANDOM SOUND CHECK (every 10 seconds)
		if currentTime >= self.NextRandomSoundCheck then
			if math.random() < 0.01 then
				local currentPos = ply:GetPos()
				local viewAng = ply:EyeAngles()
				
				-- Choose random left or right side
				local side = math.random(0, 1) == 0 and 1 or -1
				local rightDir = viewAng:Right() * side
				rightDir.z = 0
				rightDir:Normalize()
				
				-- Position 300-500 units to the left or right of the player
				local soundPos = currentPos + rightDir * math.random(300, 500)
				
				-- Play the jendigo scream sound (spatial)
				local soundFile = ")jendigo/scream" .. math.random(1, 2) .. ".wav"
				sound.Play(soundFile, soundPos, 75, math.random(90, 110))
				
				-- Increase spawn chance modifier (makes appearances twice as likely)
				self.SpawnChanceModifier = 2
			end
			
			-- Schedule next check in 10 seconds
			self.NextRandomSoundCheck = currentTime + 10
		end
		
		-- RENDER POSITION CALCULATION
		if self.RenderUntil > currentRealTime then
			-- Check if this is a new render cycle
			if not self.StoredRenderPos then
				local CheckPos
				local ViewPos = EyePos()
				local ViewVec = EyeVector()
				ViewVec.z = 0
				ViewVec:Normalize()
				
				if self.SpawnMode == "edge" then
					-- Spawn at edge - bias towards center based on player speed
					local vel = ply:GetVelocity()
					vel.z = 0
					local speed = vel:Length()
					
					-- Calculate speed factor (0 = stationary, 1 = fast noclip speed ~2500)
					local maxSpeed = 3000
					local speedFactor = math.Clamp(speed / maxSpeed, 0, 1)
					
					CheckPos = self:FindEdgeSpawn(speedFactor)
				else
					-- Rotation mode - spawn on the side opposite to rotation direction
					-- If rotating right (1), spawn on left (-1), and vice versa
					local spawnSide = -self.LastRotationDirection
					if spawnSide == 0 then spawnSide = nil end -- Random if no rotation data
					
					CheckPos = self:FindEdgeSpawn(.25, spawnSide)
				end
				
				local CheckPosTr = util.QuickTrace(ViewPos, CheckPos - ViewPos)
				local Tr = util.QuickTrace(CheckPosTr.HitPos + CheckPosTr.HitNormal * 50, Vector(0, 0, -2000))

			if ((Tr.Hit) and (Tr.HitWorld)) and (CheckPosTr.HitPos:Distance(ViewPos) >= 800) then
				self.StoredRenderPos = Tr.HitPos
				-- Make it face directly at the player
				self.StoredRenderAngle = (ViewPos - Tr.HitPos):Angle()
				
				-- Reset spawn chance modifier since wendigo has been seen
				self.SpawnChanceModifier = 1
					
					for i = 1, 58 do
						self:ManipulateBoneAngles(i, Angle(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3)))
					end
					self:SetBodygroup(1, math.random(0, 2))
					self:SetBodygroup(2, math.random(0, 5))
					self:SetBodygroup(3, math.random(0, 1))
					-- 15 left arm, 33 right arm
					self:ManipulateBoneAngles(15, Angle(0, 0, 30))
					self:ManipulateBoneAngles(16, Angle(0, 40, 10))
					self:ManipulateBoneAngles(33, Angle(0, 0, 30))
					self:ManipulateBoneAngles(34, Angle(0, 40, 10))
				end
			end
		else
			-- Reset when render time has expired
			if self.StoredRenderPos then
				self.StoredRenderPos = nil
				self.StoredRenderAngle = nil
			end
		end
		
		self:NextThink(CurTime())
		return true
	end

	function ENT:Draw()
		-- Only handle actual rendering
		if self.StoredRenderPos then
			local currentRealTime = RealTime()
			local timeLeft = self.RenderUntil - currentRealTime
			
			-- Calculate opacity based on fade-out
			local alpha = 255
			if timeLeft <= self.FadeOutDuration then
				-- Fade out during the last 0.1 seconds
				alpha = math.Clamp((timeLeft / self.FadeOutDuration) * 255, 0, 255)
			end
			
			-- Apply transparency
			render.SetBlend(alpha / 255)
			
			self:SetRenderOrigin(self.StoredRenderPos)
			self:SetRenderAngles(self.StoredRenderAngle)
			self:DrawModel()
			
			-- Reset blend
			render.SetBlend(1)
		end
	end
	
	-- Debug console command to test fade out
	--[[concommand.Add("jendigo_test", function(ply, cmd, args)
		local mode = args[1] or "rotation"
		
		-- Find the jendigo entity
		for k, v in pairs(ents.FindByClass("jendigo")) do
			if IsValid(v) then
				local duration = tonumber(args[2]) or 2 -- Default 2 second duration for testing
				v.RenderUntil = RealTime() + duration
				v.SpawnMode = mode
				v.StoredRenderPos = nil -- Force recalculation of position
				v.LastRotationDirection = math.random(0, 1) == 0 and 1 or -1
				print("Jendigo test triggered - Mode: " .. mode .. ", Duration: " .. duration .. "s")
				return
			end
		end
		
		print("No jendigo entity found! Make sure the entity is spawned first.")
	end)--]]

end
