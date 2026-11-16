--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.Modules = zmc.Modules or {}

zmc.Modules.Append = zmc.Modules.Append or {}
zmc.Modules.Append.Items = zmc.Modules.Append.Items or {}
zmc.Modules.Append.Dishs = zmc.Modules.Append.Dishs or {}

function zmc.Modules.Load()
    for k,v in pairs(zmc.Modules.Append.Items) do
        // If this module already exists in our base config then stop
        if zmc.config.Items_ListID[v.uniqueid] then continue end

        zmc.config.Items_ListID[v.uniqueid] = table.insert(zmc.config.Items, v)
    end
    //if SERVER then zclib.Data.Save(nil,"zmc_item_config",zmc.config.Items) end

    for k,v in pairs(zmc.Modules.Append.Dishs) do
        // If this module already exists in our base config then stop
        if zmc.config.Dishs_ListID[v.uniqueid] then continue end

        zmc.config.Dishs_ListID[v.uniqueid] = table.insert(zmc.config.Dishs, v)
    end
    //if SERVER then zclib.Data.Save(nil,"zmc_dish_config",zmc.config.Dishs) end
end

timer.Simple(5, function()
    // Load any items found in the modules
    zmc.Modules.Load()
end)
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
