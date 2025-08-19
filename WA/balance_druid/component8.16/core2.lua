env.test = function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, ...)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        aura_env.PrevCast = spellID
        
        if destGUID == aura_env.ids.FullMoon then
            aura_env.LastFullMoon = GetTime()
        end
        
        if destGUID == aura_env.ids.ForceOfNature then
            aura_env.LastForceOfNature = GetTime()
        end
    elseif subEvent == "SPELL_PERIODIC_ENERGIZE" then
        if spellID == 202497 then -- Shooting Stars
            aura_env.OrbitBreakerBuffStacks = aura_env.OrbitBreakerBuffStacks + 1
        end
    elseif subEvent == "SPELL_DAMAGE" then
        if spellID == aura_env.ids.FullMoon and GetTime() - aura_env.LastFullMoon > 1 then
            aura_env.OrbitBreakerBuffStacks = 0
        end
    end
    return
end