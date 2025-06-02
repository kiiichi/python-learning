aura_env.ShouldShowDebuff = function(unit)
    if UnitAffectingCombat(unit) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.NGWA and _G.NGWA.BalanceDruid then
            for _, ID in ipairs(_G.NGWA.BalanceDruid) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    return false
                end
            end
        end
        return true
    end
end