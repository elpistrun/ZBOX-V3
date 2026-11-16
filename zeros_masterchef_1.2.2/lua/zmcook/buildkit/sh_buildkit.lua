--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Buildkit = zmc.Buildkit or {}

zmc.Buildkit_Classes = {}
timer.Simple(2,function()
    for k,v in pairs(zmc.config.Buildkit.List) do
        zmc.Buildkit_Classes[v.class] = k
    end
end)

// Check if some player is in the way
function zmc.Buildkit.AreaOccupied(pos,ignore)
    local IsOccupied = false
    for k,v in pairs(ents.FindInSphere(pos,10)) do
        if not IsValid(v) then continue end

        if ignore and v == ignore then continue end

        // We dont place a machine on top of another one
        if zmc.Buildkit_Classes[v:GetClass()] then
            IsOccupied = true
            break
        end

        // Dont place a machine on a player
        if v:IsPlayer() then
            IsOccupied = true
            break
        end
    end
    return IsOccupied
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
