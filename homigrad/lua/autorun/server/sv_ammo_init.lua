util.AddNetworkString("GiveAmmoToPlayer")

net.Receive("GiveAmmoToPlayer", function(len, ply)
    if not IsValid(ply) then return end
    
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        local ammoType = wep:GetPrimaryAmmoType()
        if ammoType ~= -1 then
            ply:GiveAmmo(30, ammoType)
            ply:ChatPrint("[ZB] Патроны выданы")
        else
            ply:ChatPrint("[ZB] Ваше оружие не требует патронов.")
        end
    else
        ply:ChatPrint("[ZB] У вас нет активного оружия.")
    end
end)
