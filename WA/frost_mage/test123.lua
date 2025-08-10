function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast3 = aura_env.PrevCast2
    aura_env.PrevCast2 = aura_env.PrevCast
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    
    if spellID == aura_env.ids.FrozenOrb then
        aura_env.FrozenOrbRemains = GetTime() + 15
    elseif spellID == aura_env.ids.ConeOfCold then
        aura_env.ConeOfColdLastUsed = GetTime()
    end
    
    local KTrigCD = aura_env.KTrigCD
    KTrigCD("Clear")

    return
end