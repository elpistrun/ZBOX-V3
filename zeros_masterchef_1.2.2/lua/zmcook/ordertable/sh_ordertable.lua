--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Ordertable = zmc.Ordertable or {}

function zmc.Ordertable.CanEditWhitelist(Ordertable,ply)
    zclib.Debug("zmc.Ordertable.CanEditWhitelist")
    if not IsValid(Ordertable) then return false end
    if zclib.Player.IsAdmin(ply) then return true end
    if zmc.config.Order.edit_whitelist_adminonly == false and zclib.Player.IsOwner(ply, Ordertable) then
        return true
    else
        return false
    end
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
