--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Machine = zmc.Machine or {}

function zmc.Machine.InProgress(Machine)
    if Machine.GetProgress and Machine:GetProgress() > -1 then return true end
    if Machine.GetCookStart and Machine:GetCookStart() > 0 then return true end
    return false
end

// Checks if the set temperatur is in the needed range of the item
function zmc.Machine.TemperaturCheck(itm_comp, temp)
    if itm_comp.temp and itm_comp.temp.start and itm_comp.temp.range and temp >= itm_comp.temp.start and temp <= (itm_comp.temp.start + itm_comp.temp.range) then
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
