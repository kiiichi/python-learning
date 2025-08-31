aura_env.ShouldShowDebuff = function(unit)
    if (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.KLIST then
            for _, ID in ipairs(_G.KLIST.BeastMasteryHunter) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    return false
                end
            end
        end
        
        return true
    end
end
