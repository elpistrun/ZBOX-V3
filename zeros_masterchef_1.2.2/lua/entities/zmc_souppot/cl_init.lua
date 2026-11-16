--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

include("shared.lua")

function ENT:Initialize()
	zmc.SoupPot.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmc.SoupPot.Draw(self)
end

function ENT:Think()
	zmc.SoupPot.Think(self)
end

function ENT:OnRemove()
	zmc.SoupPot.OnRemove(self)
end

function ENT:OnReDraw()
	zmc.SoupPot.OnReDraw(self)
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
