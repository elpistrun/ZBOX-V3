util.AddNetworkString("AutoPickupSpawnSlingForPlayer")

net.Receive("AutoPickupSpawnSlingForPlayer", function(len, ply)
    -- Без проверки админа, только валидный игрок
    if not IsValid(ply) then return end
    
    -- Опционально: cooldown, чтобы не спамить (как в предыдущем)
    if ply.LastSlingGive and ply.LastSlingGive > CurTime() - 10 then  -- 10 сек для теста
        ply:ChatPrint("[ZC Melee Belt] Подождите 10 секунд перед повторным запросом.")
        return
    end
    ply.LastSlingGive = CurTime()
    
    -- Спавним hg_melee_belt на позиции игрока (или очень близко)
    local ent = ents.Create("hg_melee_belt")  -- Класс энтити
    if not IsValid(ent) then return end
    
    -- Позиция: точно на игроке (можно +Vector(0,0,50) для головы, но лучше на ногах)
    local pos = ply:GetPos() + Vector(0, 0, 10)  -- +10 по Z, чтобы не в земле, но близко
    local ang = ply:GetAngles()
    
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    
    -- Авто-подбор: Симулируем использование энтити игроком немедленно
    -- Это вызывает стандартный Use хук энтити, если он есть (для подбора)
    timer.Simple(0.01, function()  -- Короткий таймер, чтобы энтити успел заспавниться
        if IsValid(ent) and IsValid(ply) then
            ent:Use(ply, ply)  -- Вызываем Use для подбора (если энтити поддерживает, рюкзак должен попасть в инвентарь/надеться)
        end
    end)
    
    -- Если рюкзак не подбирается через Use, удалите таймер и добавьте custom логику, например:
    -- ply:AddBackpack(ent) if такая функция есть в моде
    
    -- Уведомление игроку
    ply:ChatPrint("[ZC Melee Belt] Пояс надет!")
    
    -- Очистка: Если не подобрано, удалить через 5 секунд (на случай ошибки)
    timer.Simple(5, function()
        if IsValid(ent) then 
            ent:Remove() 
        end
    end)
end)
