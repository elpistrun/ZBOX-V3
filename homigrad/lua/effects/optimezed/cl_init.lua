include("shared.lua")

hook.Add("Think", "HG_CheckEffectSettings", function()
    local enabled = GetConVarNumber("hg_opt_explosions_enabled") == 1
    
    if enabled and not HG_EffectsActive then
        HG_EffectsActive = true
        print("[HG] Optimized effects enabled")
    elseif not enabled and HG_EffectsActive then
        HG_EffectsActive = false
        print("[HG] Optimized effects disabled")
    end
end)