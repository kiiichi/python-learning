env.test = function(event, _, subEvent, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellID)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then 
        aura_env.PrevCast = spellID 
        if spellID == aura_env.ids.Envenom then
            if IsPlayerSpell(aura_env.ids.TwistTheKnifeTalent) and aura_env.Envenom1 < GetTime() then
                aura_env.Envenom1 = aura_env.Envenom1
                aura_env.Envenom2 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            else
                aura_env.Envenom1 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            end
        elseif spellID == aura_env.ids.CrimsonTempest then
            local NearbyEnemies = 0
            for i = 1, 40 do
                local unit = "nameplate"..i
                if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, 10, "<=") then
                    NearbyEnemies = NearbyEnemies + 1
                end
            end
            aura_env.LastCrimsonTempestCount = min(NearbyEnemies, 5)
        end
    end
    
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
        if spellID == aura_env.ids.Garrote then
            local Multiplier = (aura_env.PlayerHasBuff(392403) or aura_env.PlayerHasBuff(392401)) and 1.5 or 1
            
            aura_env.GarroteSnapshots[targetGUID] = Multiplier
        elseif spellID == aura_env.ids.CrimsonTempestDebuff then
            aura_env.CrimsonTempestSnapshots[targetGUID] = aura_env.LastCrimsonTempestCount
        end
    end

    -- Kichi --
    if subEvent == "SPELL_AURA_REMOVED" then 
        if spellID == aura_env.ids.Garrote then
            aura_env.GarroteSnapshots[targetGUID] = nil
        end
    end

end
