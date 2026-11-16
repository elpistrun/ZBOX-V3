if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Author = "Mannytko"
ENT.Category = "ZCity Other"
ENT.PrintName = "Sulfuric Acid jar"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.IconOverride = "vgui/acid.png"

-- Acid scream phrases similar to fire screaming
local hg_acid_pain = {
	"SHIT SHIT SHIT AHAHHHHHAHHAAAA!",
	"FUCK AAAAAAAAAAAAAAAAAAAAAHHHHHHH IT BURNS!",
	"AAAAAAAAAAH AAAAAAAAAAAAAAAAAAAAAH AHHHHH!",
	"AAAAAAHHHH IT'S EATING MY SKIN!",
	"FUCK AAAAAAAAAAAAAAAAAAAAAHHHHHHH!",
	"FUCK AAAAAAAAGHHHH AAAAAAAAAAAAAAAAAAAH!",
	"AAAAAAAAAAAAAAAAH AAAAAAAAAAH IT BURNS!",
	"FUCKKKK ITS BURNS IT BURNS IT BURNNSS AAAAAAHHHHH!!",
}

-- Hook for acid screaming (similar to fire screaming)
if SERVER then
	hook.Add("PreHomigradDamage","AcidScream", function( ent, dmgInfo )
		local ply = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent

		if dmgInfo:IsDamageType(DMG_ACID) and IsValid(ply) and ply:IsPlayer() and ply.organism and not ply.organism.otrub and ply:Alive() then
			-- Check if player is already screaming to prevent spam
			if (ply.lastAcidScream or 0) > CurTime() then return end
			ply.lastAcidScream = CurTime() + 3 -- 3 second cooldown
			
			-- Use female or male sounds based on player
			local femaleCount = 8 -- Assuming similar count to fire screams
			local maleCount = 8
			local phrase = "zcitysnd/"..(ThatPlyIsFemale(ply) and "fe" or "").."male/burn/death_burn"..math.random(1,ThatPlyIsFemale(ply) and femaleCount or maleCount)..".mp3"
			ply:Notify(table.Random(hg_acid_pain),SoundDuration(phrase),"ply_acid",0.5,function(ply)
				if IsValid(ply) and ply:Alive() then
					hg.GetCurrentCharacter(ply):EmitSound(phrase)
					ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
					ply.lastPhr = phrase
				end
			end, Color(255,0,0)) -- Red color for acid
		end
	end)
	
	-- Stop acid screaming in water (similar to fire screaming)
	hook.Add("Think", "StopAcidPhraseInWater", function()
		for k, ply in pairs(player.GetAll()) do
			if ply:WaterLevel() >= 2 and ply.lastPhr and string.find(ply.lastPhr, "burn") then
				ply:StopSound(ply.lastPhr)
				ply.lastPhr = nil
				ply.phrCld = 0
			end
		end
	end)
end
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_lab/jar01b.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(USE_TOGGLE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		timer.Simple(0.1,function()
			if not IsValid(self) then return end
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
		end)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(5)
			phys:Wake()
		end
		-- Loop sound will start when acid spreads, not here
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > .2 and data.Speed > 25 then
			
			self.Velocity = data.OurOldVelocity
			if data.Speed > 200 and not self.Exploded then 
				self:Detonate()
				self:EmitSound("sulfuricacid/bottle_break" .. math.random(1,3) .. ".wav")
			end
		end
	end

	function ENT:Use(ply)
		if self:IsPlayerHolding() then return end

		self:EmitSound("sulfuricacid/bottle_pickup" .. math.random(1,2) .. ".wav", 50, math.random(95, 105))
		ply:PickupObject(self)
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Exploded then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()
		if Dmg >= 1 and dmginfo:IsDamageType(DMG_BURN) then
			timer.Simple(2, function()
				if not IsValid(self) then return end
				self:Detonate()
			end)
		end
	end

	function ENT:Think()
		if self:GetPhysicsObject():GetVelocity():Length() < 50 or self:WaterLevel() > 0 and not self.Exploded then
			-- Acid jar becomes inert when moving slowly or in water
			local ent = ents.Create("weapon_hg_acidjar")
			ent:SetPos(self:GetPos())
			ent:SetAngles(self:GetAngles())
			ent:SetVelocity(self:GetPhysicsObject():GetVelocity())
			ent.init = true
			ent:Spawn()
			
			self.Exploded = true
			self:Remove()
		end
		--self:NextThink(CurTime() + 1)
		--return true
	end

	function ENT:OnRemove()
		self:StopLoopingSound(self.sndid or 0)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self.EZowner or self
		local AcidRadius = 250 -- Acid splash radius
		local IntenseRadius = 120 -- Intense acid damage radius
		
		-- Water-like acid splash effects
		timer.Simple(.01, function()
			if not IsValid(self) then return end
			
			-- Main central water splash - positioned on ground
			local mainTrace = util.QuickTrace(SelfPos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
			if mainTrace.Hit then
				local mainSplash = EffectData()
				mainSplash:SetOrigin(mainTrace.HitPos + Vector(0, 0, 2))
				mainSplash:SetMagnitude(80) -- Much bigger main splash
				mainSplash:SetScale(12)
				util.Effect("WaterSplash", mainSplash)
			end
			
			-- Multiple water splash effects in different directions - all on ground
			for i = 1, 12 do
				local angle = (360 / 12) * i
				local rad = math.rad(angle)
				local splashDir = Vector(math.cos(rad), math.sin(rad), 0) -- Remove vertical randomness
				local splashPos = SelfPos + splashDir * math.random(20, 60)
				
				-- Trace to ground for each splash
				local splashTrace = util.QuickTrace(splashPos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
				if splashTrace.Hit then
					local splashData = EffectData()
					splashData:SetOrigin(splashTrace.HitPos + Vector(0, 0, 2))
					splashData:SetMagnitude(math.random(40, 60)) -- Bigger splashes
					splashData:SetScale(math.random(6, 10)) -- Bigger scale
					util.Effect("WaterSplash", splashData)
				end
			end
			
			-- Add water-like liquid decals on surfaces around the impact - tighter spread
			for i = 1, 12 do
				local decalPos = SelfPos + VectorRand() * math.random(40, 100) -- Reduced spread from 150 to 100
				local traceDown = util.QuickTrace(decalPos + Vector(0, 0, 50), Vector(0, 0, -100), {self})
				
				if traceDown.Hit then
					local hitPos = traceDown.HitPos
					local hitNormal = traceDown.HitNormal
					local pos1 = hitPos + hitNormal * 2
					local pos2 = hitPos - hitNormal * 2
					
					-- Only water-like decals
					util.Decal("Splash.Large", pos1, pos2) -- Large water puddles
				end
			end
			
			-- Start acid loop sound during burning phase
			local acidLoopSound = CreateSound(game.GetWorld(), "sulfuricacid/acid_loop.wav")
			acidLoopSound:Play()
			
			-- Stop loop sound after acid effects end
			timer.Simple(35, function()
				if acidLoopSound then
					acidLoopSound:Stop()
				end
			end)
			
			-- Create persistent acid puddles
			local acidPuddles = {}
			for i = 1, 8 do
				local puddlePos = SelfPos + VectorRand() * math.random(30, 100)
				local traceDown = util.QuickTrace(puddlePos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
				
				if traceDown.Hit then
					local puddle = {
						pos = traceDown.HitPos,
						radius = math.random(30, 50),
						endTime = CurTime() + math.random(15, 30)
					}
					table.insert(acidPuddles, puddle)
				end
			end
			
			-- Acid puddle damage timer
			local puddleTimer = "acidpuddles_" .. CurTime()
			timer.Create(puddleTimer, 0.5, 70, function() -- Run for 35 seconds max
				for i = #acidPuddles, 1, -1 do
					local puddle = acidPuddles[i]
					
					if CurTime() > puddle.endTime then
						table.remove(acidPuddles, i)
					else
						-- Check for players in puddle
						for _, ply in ipairs(ents.FindInSphere(puddle.pos, puddle.radius)) do
							if ply:IsPlayer() and ply:Alive() then
								-- Continuous acid damage
								local dmg = DamageInfo()
								dmg:SetDamage(math.random(2, 5))
								dmg:SetDamageType(DMG_ACID)
								dmg:SetAttacker(Owner)
								dmg:SetInflictor(self)
								ply:TakeDamageInfo(dmg)
								
								-- Use proper painadd system
								if ply.organism then
									ply.organism.painadd = (ply.organism.painadd or 0) + math.random(8, 15)
									
									-- Random single organ damage from ground acid (minimal)
									local organs = {"stomach", "intestines", "lungsL", "lungsR"}
									local randomOrgan = organs[math.random(#organs)]
									if randomOrgan == "lungsL" or randomOrgan == "lungsR" then
										-- Lungs are arrays, damage the first element
										ply.organism[randomOrgan] = ply.organism[randomOrgan] or {0, 0}
										ply.organism[randomOrgan][1] = math.min(ply.organism[randomOrgan][1] + math.random(0.5, 1) / 100, 1)
									else
										-- Regular organs
										ply.organism[randomOrgan] = math.min((ply.organism[randomOrgan] or 0) + math.random(0.5, 1) / 100, 1)
									end
									
									-- Small chance to create small wounds from ground acid
									if math.random(1, 3) == 1 then -- 33% chance
										local bone = ply:LookupBone("ValveBiped.Bip01_L_Foot") or ply:LookupBone("ValveBiped.Bip01_R_Foot") or 0
										local woundSize = math.random(1, 2) -- Small wounds from ground acid
										hg.organism.AddWoundManual(ply, woundSize, Vector(math.random(-2, 2), math.random(-2, 2), math.random(-1, 1)), Angle(0, 0, 0), bone, CurTime())
									end
								end
								
								-- Random hurt sounds
								if math.random(1, 6) == 1 then
									ply:EmitSound("sulfuricacid/acid_hurt" .. math.random(1,2) .. ".wav", 60, math.random(90, 110))
								end
							end
						end
					end
				end
				
				-- Remove timer when no puddles left
				if #acidPuddles == 0 then
					timer.Remove(puddleTimer)
				end
			end)
			
			-- Player acid damage and pain system
			for _, ent in ipairs(ents.FindInSphere(SelfPos, AcidRadius)) do
				if ent:IsPlayer() and ent:Alive() then
					hg.achievements.SetPlayerAchievement(ent, "disfigured", 1)
					local distance = ent:GetPos():Distance(SelfPos)
					local force = math.max(0, (AcidRadius - distance) / AcidRadius)
					
					-- Intense pain and burning for close players
					if distance <= IntenseRadius then
						-- Extreme pain using proper organism system
						if ent.organism then
							ent.organism.painadd = (ent.organism.painadd or 0) + (force * 30 + 20) -- 20-50 painadd
							ent.organism.disorientation = math.min((ent.organism.disorientation or 0) + 15, 100)
							
							-- Random single organ damage from acid
							local organs = {"stomach", "intestines", "lungsL", "lungsR"}
							local randomOrgan = organs[math.random(#organs)]
							if randomOrgan == "lungsL" or randomOrgan == "lungsR" then
								-- Lungs are arrays, damage the first element
								ent.organism[randomOrgan] = ent.organism[randomOrgan] or {0, 0}
								ent.organism[randomOrgan][1] = math.min(ent.organism[randomOrgan][1] + math.random(1, 3) / 100, 1)
							else
								-- Regular organs
								ent.organism[randomOrgan] = math.min((ent.organism[randomOrgan] or 0) + math.random(1, 3) / 100, 1)
							end
							
							-- Create multiple wounds from acid burns (initial splash)
							local woundCount = math.random(2, 4) -- 2-4 wounds for close range
							for w = 1, woundCount do
								local bone = ent:LookupBone("ValveBiped.Bip01_Spine2") or ent:LookupBone("ValveBiped.Bip01_Pelvis") or 0
								local woundSize = math.random(3, 6) -- Larger wounds from acid
								hg.organism.AddWoundManual(ent, woundSize, Vector(math.random(-5, 5), math.random(-5, 5), math.random(-3, 3)), Angle(0, 0, 0), bone, CurTime())
							end
						end
						
						-- Start acid burning timer - invisible but painful
						local burnTime = force * 20 + 10 -- 10-30 seconds of burning
						local burnTimer = "acidburn_" .. ent:EntIndex() .. "_" .. CurTime()
						
						timer.Create(burnTimer, 0.5, burnTime * 2, function()
							if not IsValid(ent) or not ent:Alive() then 
								timer.Remove(burnTimer)
								return 
							end
							
							-- Continuous acid damage
							local dmg = DamageInfo()
							dmg:SetDamage(math.random(3, 8))
							dmg:SetDamageType(DMG_ACID)
							dmg:SetAttacker(Owner)
							dmg:SetInflictor(self)
							ent:TakeDamageInfo(dmg)
							
							-- Continuous pain using proper system
							if ent.organism then
								ent.organism.painadd = (ent.organism.painadd or 0) + math.random(5, 12)
							end
							
							-- Random hurt sounds
							if math.random(1, 4) == 1 then
								ent:EmitSound("sulfuricacid/acid_hurt" .. math.random(1,2) .. ".wav", 60, math.random(90, 110))
							end
						end)
					else
						-- Moderate acid effects for distant players
						if ent.organism then
							ent.organism.painadd = (ent.organism.painadd or 0) + (force * 15 + 10) -- 10-25 painadd
							
							-- Random single organ damage from acid (reduced for distant)
							local organs = {"stomach", "intestines", "lungsL", "lungsR"}
							local randomOrgan = organs[math.random(#organs)]
							if randomOrgan == "lungsL" or randomOrgan == "lungsR" then
								-- Lungs are arrays, damage the first element
								ent.organism[randomOrgan] = ent.organism[randomOrgan] or {0, 0}
								ent.organism[randomOrgan][1] = math.min(ent.organism[randomOrgan][1] + math.random(0.5, 1) / 100, 1)
							else
								-- Regular organs
								ent.organism[randomOrgan] = math.min((ent.organism[randomOrgan] or 0) + math.random(0.5, 1) / 100, 1)
							end
							
							-- Create fewer wounds for distant players
							local woundCount = math.random(1, 2) -- 1-2 wounds for distant range
							for w = 1, woundCount do
								local bone = ent:LookupBone("ValveBiped.Bip01_Spine2") or ent:LookupBone("ValveBiped.Bip01_Pelvis") or 0
								local woundSize = math.random(2, 4) -- Smaller wounds for distant
								hg.organism.AddWoundManual(ent, woundSize, Vector(math.random(-3, 3), math.random(-3, 3), math.random(-2, 2)), Angle(0, 0, 0), bone, CurTime())
							end
						end
						
						-- Shorter burn duration for distant players
						local burnTime = force * 8 + 3
						local burnTimer = "acidburn_" .. ent:EntIndex() .. "_" .. CurTime()
						
						timer.Create(burnTimer, 1, burnTime, function()
							if not IsValid(ent) or not ent:Alive() then 
								timer.Remove(burnTimer)
								return 
							end
							
							local dmg = DamageInfo()
							dmg:SetDamage(math.random(1, 4))
							dmg:SetDamageType(DMG_ACID)
							dmg:SetAttacker(Owner)
							dmg:SetInflictor(self)
							ent:TakeDamageInfo(dmg)
							
							if ent.organism then
								ent.organism.painadd = (ent.organism.painadd or 0) + math.random(2, 6)
							end
						end)
					end
				elseif ent:IsNPC() or ent:IsNextBot() then
					-- Acid damage for NPCs
					local distance = ent:GetPos():Distance(SelfPos)
					local force = math.max(0, (AcidRadius - distance) / AcidRadius)
					
					local dmg = DamageInfo()
					dmg:SetDamage(force * 40 + 20)
					dmg:SetDamageType(DMG_ACID)
					dmg:SetAttacker(Owner)
					dmg:SetInflictor(self)
					ent:TakeDamageInfo(dmg)
				end
			end
			
			-- Water-like acid spread traces for ground coverage
			for i = 0, 40 do
				local Tr = util.QuickTrace(SelfPos + vector_up * 25, (vector_up * -100) + VectorRand() * (i * 4), {self})
				if Tr.Hit then
					-- Create water-like acid puddle effects - bigger and more visible
					local acidEffect = EffectData()
					acidEffect:SetOrigin(Tr.HitPos + vector_up * 2)
					acidEffect:SetMagnitude(math.random(20, 30)) -- Increased from 8-15 to 20-30
					acidEffect:SetScale(math.random(4, 6)) -- Increased from 2-4 to 4-6
					util.Effect("WaterSplash", acidEffect)
					
					-- Damage entities that touch acid spots
					timer.Simple(math.random(0.1, 0.5), function()
						for _, nearEnt in ipairs(ents.FindInSphere(Tr.HitPos, 30)) do
							if nearEnt:IsPlayer() and nearEnt:Alive() then
								local dmg = DamageInfo()
								dmg:SetDamage(math.random(2, 5))
								dmg:SetDamageType(DMG_ACID)
								dmg:SetAttacker(Owner)
								dmg:SetInflictor(self)
								nearEnt:TakeDamageInfo(dmg)
								
								if nearEnt.organism then
									nearEnt.organism.painadd = (nearEnt.organism.painadd or 0) + math.random(3, 8)
									
									-- Random single organ damage from ground acid coverage (minimal)
									local organs = {"stomach", "intestines", "lungsL", "lungsR"}
									local randomOrgan = organs[math.random(#organs)]
									if randomOrgan == "lungsL" or randomOrgan == "lungsR" then
										-- Lungs are arrays, damage the first element
										nearEnt.organism[randomOrgan] = nearEnt.organism[randomOrgan] or {0, 0}
										nearEnt.organism[randomOrgan][1] = math.min(nearEnt.organism[randomOrgan][1] + math.random(0.5, 1) / 100, 1)
									else
										-- Regular organs
										nearEnt.organism[randomOrgan] = math.min((nearEnt.organism[randomOrgan] or 0) + math.random(0.5, 1) / 100, 1)
									end
									
									-- Small chance to create tiny wounds from ground acid coverage
									if math.random(1, 4) == 1 then -- 25% chance
										local bone = nearEnt:LookupBone("ValveBiped.Bip01_L_Foot") or nearEnt:LookupBone("ValveBiped.Bip01_R_Foot") or 0
										local woundSize = math.random(0.5, 1.5) -- Tiny wounds from ground coverage
										hg.organism.AddWoundManual(nearEnt, woundSize, Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)), Angle(0, 0, 0), bone, CurTime())
									end
								end
							end
						end
					end)
				end
			end
		end)
		
		-- Delayed secondary effects for sustained acid bubbling
		timer.Simple(0.3, function()
			if not IsValid(self) then return end
			
			-- Secondary splash effects - positioned on ground
			for i = 1, 6 do
				local secondaryPos = SelfPos + VectorRand() * math.random(40, 80)
				local secondaryTrace = util.QuickTrace(secondaryPos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
				if secondaryTrace.Hit then
					local secondaryData = EffectData()
					secondaryData:SetOrigin(secondaryTrace.HitPos + Vector(0, 0, 2))
					secondaryData:SetMagnitude(math.random(25, 35)) -- Bigger secondary effects
					secondaryData:SetScale(math.random(4, 6))
					util.Effect("WaterSplash", secondaryData)
				end
			end
		end)
		
		-- Tertiary water bubbling effects
		timer.Simple(0.8, function()
			if not IsValid(self) then return end
			
			for i = 1, 4 do
				local bubblePos = SelfPos + VectorRand() * math.random(20, 50)
				local bubbleTrace = util.QuickTrace(bubblePos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
				if bubbleTrace.Hit then
					local bubbleData = EffectData()
					bubbleData:SetOrigin(bubbleTrace.HitPos + Vector(0, 0, 2))
					bubbleData:SetMagnitude(math.random(15, 25)) -- Bigger bubbling effects
					bubbleData:SetScale(math.random(3, 5))
					util.Effect("WaterSplash", bubbleData)
				end
			end
		end)
		
		-- Final acid steam effects - these can be slightly above ground for steam effect
		timer.Simple(1.5, function()
			if not IsValid(self) then return end
			
			for i = 1, 3 do
				local steamBasePos = SelfPos + VectorRand() * math.random(10, 30)
				local steamTrace = util.QuickTrace(steamBasePos + Vector(0, 0, 20), Vector(0, 0, -40), {self})
				if steamTrace.Hit then
					local steamPos = steamTrace.HitPos + Vector(0, 0, math.random(5, 15)) -- Slight elevation for steam
					local steamData = EffectData()
					steamData:SetOrigin(steamPos)
					steamData:SetMagnitude(math.random(12, 18)) -- Bigger steam effects
					steamData:SetScale(math.random(2, 4))
					util.Effect("WaterSplash", steamData)
				end
			end
		end)
		
		hg.EmitAISound(SelfPos, 512, 16, 8)

		-- Acid spread sounds
		timer.Simple(.05, function()
			if not IsValid(self) then return end
			sound.Play("sulfuricacid/acid_spread" .. math.random(1,2) .. ".wav", SelfPos, 80, 100)
		end)

		timer.Simple(.07, function()
			if not IsValid(self) then return end
			self:Remove()
		end)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end