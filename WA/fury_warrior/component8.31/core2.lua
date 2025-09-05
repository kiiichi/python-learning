env.test = function( _,unit,_,_,spellID)
    if unit ~= "player" then return false end
    aura_env.PrevCast = spellID

    if aura_env.GetStacks("player", aura_env.ids.MeatCleaverBuff) == 1 then
        aura_env.ListenSpellInMeatCleaver = spellID
    else aura_env.ListenSpellInMeatCleaver = 0
    end

    return
end
