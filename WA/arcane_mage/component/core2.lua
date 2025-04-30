env.test = function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    if spellID == aura_env.ids.ArcaneBlast then
        aura_env.NeedArcaneBlastSpark = false
        aura_env.PrevArcaneBlast = GetTime()
    elseif spellID == aura_env.ids.ArcaneOrb then
        aura_env.UsedOrb = true
    elseif spellID == aura_env.ids.ArcaneMissiles then
        aura_env.UsedMissiles = true
    elseif spellID == aura_env.ids.ArcaneBarrage then
        aura_env.UsedBarrage = true
    elseif spellID == aura_env.ids.TouchOfTheMagi then
        aura_env.NeedArcaneBlastSpark = true
    end
    return
end
