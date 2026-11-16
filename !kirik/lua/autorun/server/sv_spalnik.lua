local function zalupa(ply)
    local playerSleepniks = {}

    for k, v in ipairs(ents.FindByClass("sleepnik")) do
        if IsValid(v:GetNW2Entity("sleeper_2281337")) and v:GetNW2Entity("sleeper_2281337") == ply then 
            table.insert(playerSleepniks, v)
        end
    end

    if #playerSleepniks > 0 then
        table.sort(playerSleepniks, function(a, b) 
            return (a:GetCreationID() or 0) > (b:GetCreationID() or 0)
        end)
        
        local lastSleepnik = playerSleepniks[1]
        ply:SetPos(lastSleepnik:GetPos() + Vector(0, 0, 10))
        --ply:PrintMessage(HUD_PRINTTALK, "you stupid nigger")
    end
end

hook.Add("PlayerSpawn", "spalnik_hook", zalupa)