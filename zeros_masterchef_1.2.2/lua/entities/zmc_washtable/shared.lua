--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_kitchen/zmc_washtable.mdl"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Washtable"
ENT.Category = "Zeros MasterCook"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "PlateCount")
    self:NetworkVar("Int", 2, "WashProgress")

    if (SERVER) then
        self:SetPlateCount(0)
        self:SetWashProgress(0)
    end
end

function ENT:CanPickUp(ItemID)
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
