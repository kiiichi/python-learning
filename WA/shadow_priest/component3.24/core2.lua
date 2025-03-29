env.test = function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
end
