--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Dishtable = zmc.Dishtable or {}

// Returns all the ingredients which are currently missing
function zmc.Dishtable.GetMissingIngredients(Dishtable)
    local DishData = zmc.Dish.GetData(Dishtable:GetDishID())
    if DishData == nil then return {} end
    local temp = {}
    for k,v in pairs(DishData.items) do
        table.insert(temp,v.uniqueid)
    end
    for k,v in pairs(zmc.Inventory.Get(Dishtable)) do
        table.RemoveByValue(temp,v.itm)
    end
    local missing = {}
    for k,v in pairs(temp) do
        table.insert(missing,{itm = v})
    end
    return missing
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
