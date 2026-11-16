-- Based off of JMOD EZ Gas Particle, created by Freaking Fission
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Tear Gas"
ENT.Author = "Jackarunda, Freaking Fission, Modified"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.ThinkRate = 2
ENT.AffectRange = 250
ENT.MaxLife = 120
ENT.MaxVel = 100
--

if SERVER then
	util.AddNetworkString("JMod_TearGasVision")
	
	function ENT:CustomInit()
		local Time = CurTime()
		self.NextDmg = Time + 2.5
		self.CurVel = self.CurVel or VectorRand() * 50
		self.AirResistance = 1
	end

	function ENT:DamageObj(obj)
		local Time = CurTime()
		if obj:IsPlayer() then
			local inhaleProt, skinProt, eyeProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)
			
			JMod.DepleteArmorChemicalCharge(obj, (inhaleProt) * .06)
			
			if eyeProt < 1 then
				-- Отправляем эффект на камеру
				net.Start("JMod_TearGasVision")
				net.WriteFloat(5 * math.Clamp(1 - eyeProt, 0, 1)) -- Длительность
				net.WriteFloat(1 - eyeProt) -- Интенсивность
				net.Send(obj)
				JMod.Hint(obj, "tear gas")
			end
			if inhaleProt < .75 then
				JMod.TryCough(obj)
				-- УРОН УБРАН, ТОЛЬКО КАШЕЛЬ
			else
				obj.EZcoughTime = Time + .5
			end
		elseif obj:IsNPC() then
			obj.EZNPCincapacitate = Time + math.Rand(2, 5)
		end
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos, Time = self:GetPos(), CurTime()
		local RandDir = VectorRand(-6, 6)
		RandDir.z = RandDir.z * .5
		local Force = RandDir + (JMod.Wind * 4) + Vector(0, 0, -6)

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
			if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
				if obj.EZgasParticle and not(obj.EZvirusParticle) then
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * .5
				elseif self.NextDmg < Time and self:ShouldDamage(obj) then
					self:DamageObj(obj)
				end
			end
		end
	
		self.CurVel = self.CurVel + Force / ThinkRateHz
		self.CurVel = self.CurVel:GetNormalized() * math.min(self.CurVel:Length(), self.MaxVel)

		local NewPos = SelfPos + self.CurVel / ThinkRateHz

		local MoveTrace = util.TraceLine({
			start = SelfPos,
			endpos = NewPos,
			filter = { self, self.Canister },
			mask = MASK_SOLID+MASK_WATER
		})
		if not MoveTrace.Hit then
			self:SetPos(NewPos)
		else
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 10)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length() * .8
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			self.CurVel = -(CurVelAng:Forward() * Speed)
		end
	end

elseif CLIENT then
	local Mat = Material("effects/smoke_b")
	local DebugMat = Material("sprites/mat_jack_jackconfetti")
	local Cheating = GetConVar("sv_cheats")

	function ENT:Initialize()
		self.Col = Color(255, 255, 255) -- БЕЛЫЙ ДЫМ
		self.Visible = true
		self.Show = true
		self.siz = 1
		self.RenderPos = self:GetPos()

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 2) == 2
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		self:SetRenderBounds(Vector(-250, -250, -250), Vector(250, 250, 250))
	end

	function ENT:DrawTranslucent()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 50, 50, Color(255, 255, 255, 200))
		end

		local Time = CurTime()

		if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end
		self.Show = self.Visible

		if self.Show then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			local EyeDiff = self.RenderPos - EyePos()
			local RenderDist = (1 - 1 / EyeDiff:Length()) * 250
			render.DrawSprite(self.RenderPos + EyeDiff:GetNormalized() * -RenderDist, 
				self.siz, self.siz, 
				Color(255, 255, 255, 15))
			self.RenderPos = LerpVector(FrameTime() * 1, self.RenderPos, SelfPos)
			self.siz = math.Clamp(self.siz + FrameTime() * 150, 0, 500)
		end
	end
	
	-- ЭФФЕКТЫ НА КАМЕРЕ: VHS + Radial Blur + Motion Blur + Красный экран
	local tearGasEffects = {}
	
	net.Receive("JMod_TearGasVision", function()
		local duration = net.ReadFloat()
		local intensity = net.ReadFloat()
		local lply = LocalPlayer()
		
		if not IsValid(lply) then return end
		
		local plyId = lply:UserID()
		tearGasEffects[plyId] = {
			startTime = RealTime(),
			duration = duration,
			intensity = intensity,
			fadeOut = false
		}
		
		hook.Add("RenderScreenspaceEffects", "TearGasEffects_" .. plyId, function()
			if not IsValid(lply) then 
				hook.Remove("RenderScreenspaceEffects", "TearGasEffects_" .. plyId)
				return 
			end
			
			local effect = tearGasEffects[plyId]
			if not effect then 
				hook.Remove("RenderScreenspaceEffects", "TearGasEffects_" .. plyId)
				return 
			end
			
			local timeLeft = effect.duration - (RealTime() - effect.startTime)
			
			-- Проверяем рядом ли еще есть газ
			local nearGas = false
			for _, ent in ipairs(ents.FindInSphere(lply:GetPos(), 300)) do
				if ent:GetClass() == "ent_jack_gmod_ezcsparticle_teargas" or ent:GetClass() == "ent_jack_gmod_ezcsparticle" then
					nearGas = true
					break
				end
			end
			
			-- Если газа нет рядом - медленно уменьшаем интенсивность
			if not nearGas and timeLeft > 0 then
				effect.fadeOut = true
				effect.intensity = math.max(0, effect.intensity - FrameTime() * 0.5)
				if effect.intensity <= 0 then
					tearGasEffects[plyId] = nil
					hook.Remove("RenderScreenspaceEffects", "TearGasEffects_" .. plyId)
					return
				end
			end
			
			if timeLeft > 0 or effect.fadeOut then
				local curIntensity = effect.intensity
				if timeLeft > 0 and not effect.fadeOut then
					curIntensity = curIntensity * (timeLeft / effect.duration)
				end
				
				-- 1. КРАСНЫЙ ЭКРАН
				local redTbl = {
					["$pp_colour_addr"] = 0.25 * curIntensity,
					["$pp_colour_addg"] = 0,
					["$pp_colour_addb"] = 0,
					["$pp_colour_brightness"] = -0.1 * curIntensity,
					["$pp_colour_contrast"] = 1.1,
					["$pp_colour_colour"] = 0.8,
				}
				DrawColorModify(redTbl)
				
				-- 2. VHS ЭФФЕКТ (помехи)
				DrawMaterialOverlay("effects/tv_glitch2", curIntensity * 0.3)
				
				-- 3. RADIAL BLUR (радиальное размытие)
				DrawRadialBlur(0.5, 0.5, curIntensity * 0.25)
				
				-- 4. MOTION BLUR (размытие движения)
				DrawMotionBlur(0.2 * curIntensity, 0.95, 0.01)
				
				-- Дополнительный VHS эффект
				DrawMaterialOverlay("effects/tp_eyepower", curIntensity * 0.2)
				
			else
				tearGasEffects[plyId] = nil
				hook.Remove("RenderScreenspaceEffects", "TearGasEffects_" .. plyId)
			end
		end)
	end)
end

language.Add("ent_jack_gmod_ezcsparticle_teargas", "EZ Tear Gas")