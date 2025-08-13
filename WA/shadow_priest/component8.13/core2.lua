env.test = function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    
    if spellID == aura_env.ids.Halo then
        aura_env.Archon4pcStacks = 0
    elseif spellID == aura_env.ids.DevouringPlague then
        -- Each cast of Devouring Plague increases the stacks by 1
        aura_env.Archon4pcStacks = aura_env.Archon4pcStacks + 1
    elseif spellID == aura_env.ids.ShadowCrash then
        aura_env.LastShadowCrash = GetTime()
    end
end
