env.test = function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if destGUID == aura_env.ids.MetamorphosisBuff and IsPlayerSpell(ids.Demonsurge) then
        -- aura_env.DemonsurgeAbyssalGaze = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeAnnihilationBuff = true
        -- aura_env.DemonsurgeConsumingFireBuff = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeDeathSweepBuff = true
    end
    return
end
