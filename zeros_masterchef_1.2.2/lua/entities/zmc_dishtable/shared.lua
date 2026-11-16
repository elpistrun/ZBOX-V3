--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_kitchen/zmc_dishtable.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Dishtable"
ENT.Category = "Zeros MasterCook"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
	self:NetworkVar("Int", 1, "DishID")

	if (SERVER) then
		self:SetDishID(-1)
	end
end

function ENT:CanPickUp(ItemID)
	local ItemData = zmc.Item.GetData(ItemID)
    if ItemData == nil then return end
    if ItemData.sell == nil then return end
	return true
end

function ENT:CanProperty(ply)
	return ply:IsSuperAdmin()
end

function ENT:CanTool(ply, tab, str)
	return ply:IsSuperAdmin()
end

function ENT:CanDrive(ply)
	return ply:IsSuperAdmin()
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
