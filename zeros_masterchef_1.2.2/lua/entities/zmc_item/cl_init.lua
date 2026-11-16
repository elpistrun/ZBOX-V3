--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

include("shared.lua")

function ENT:Initialize()
	zmc.Item.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmc.Item.Draw(self)
end

function ENT:Think()

	zclib.util.LoopedSound(self, "zmc_flys_looped", self:GetIsRotten())

	if zclib.util.InDistance(self:GetPos(), LocalPlayer():GetPos(), zmc.renderdist_ui) then
		if self:GetIsRotten() then
			if self.HasFlys ~= true then
				self.HasFlys = true
				zclib.Effect.ParticleEffectAttach("zmc_flys", PATTACH_POINT_FOLLOW, self, 0)
			end
		else
			if self.HasFlys then
				self:StopParticles()
				self.HasFlys = nil
			end
		end
	else
		if self.HasFlys then
			self:StopParticles()
			self.HasFlys = nil
		end
	end
end

function ENT:OnRemove()
	self:StopParticles()
	self:StopSound("zmc_flys_looped")
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
