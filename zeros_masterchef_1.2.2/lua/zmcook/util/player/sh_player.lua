--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Player = zmc.Player or {}

function zmc.Player.IsCook(ply)
    if zmc.config.Jobs and table.Count(zmc.config.Jobs) > 0 then

        //if zclib.Player.IsAdmin(ply) then return true end

        return zmc.config.Jobs[ply:Team()] == true
    else
        return true
    end
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
