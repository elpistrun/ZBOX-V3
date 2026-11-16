--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

if CLIENT then return end
zmc = zmc or {}
zmc.Cookbook = zmc.Cookbook or {}

function zmc.Cookbook.Initialize(Cookbook)
    zclib.EntityTracker.Add(Cookbook)
    Cookbook:PhysicsInit(SOLID_VPHYSICS)
    Cookbook:SetSolid(SOLID_VPHYSICS)
    Cookbook:SetMoveType(MOVETYPE_VPHYSICS)
    Cookbook:SetUseType(SIMPLE_USE)
    Cookbook:DrawShadow(false)
    Cookbook:SetMaxHealth(zmc.config.Damageable[Cookbook:GetClass()])
    Cookbook:SetHealth(Cookbook:GetMaxHealth())

    local phy = Cookbook:GetPhysicsObject()
    if IsValid(phy) then
        phy:Wake()
        phy:EnableMotion(false)
    end
end

function zmc.Cookbook.OnRemove(Cookbook)
    zclib.EntityTracker.Remove(Cookbook)
end

util.AddNetworkString("zmc_cookbook_open")
function zmc.Cookbook.Use(Cookbook, ply)
    if zmc.Player.IsCook(ply) == false then return end
    net.Start("zmc_cookbook_open")
    net.Send(ply)
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
