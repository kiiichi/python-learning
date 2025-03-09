env.test = function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    
    if spellID == aura_env.ids.TemplarStrike then
        aura_env.TemplarStrikeExpires = GetTime() + 5
    end
    
    return
end

