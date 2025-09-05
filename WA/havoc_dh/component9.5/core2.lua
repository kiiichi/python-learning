env.test = function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast3 = aura_env.PrevCast2
    aura_env.PrevCast2 = aura_env.PrevCast
    aura_env.PrevCast = spellID
    aura_env.LastDeathSweep = GetTime()
    
    -- Consumed Demonsurge explosion.
    if spellID == aura_env.ids.Annihilation then
        aura_env.DemonsurgeAnnihilationBuff = false
    elseif spellID == aura_env.ids.ConsumingFire then
        aura_env.DemonsurgeConsumingFireBuff = false
    elseif spellID == aura_env.ids.DeathSweep then
        aura_env.DemonsurgeDeathSweepBuff = false
    elseif spellID == aura_env.ids.AbyssalGaze then
        aura_env.DemonsurgeAbyssalGazeBuff = false
    elseif spellID == aura_env.ids.SigilOfDoom then
        aura_env.DemonsurgeSigilOfDoomBuff = false
    end
    
    if spellID == aura_env.ids.Metamorphosis then
        aura_env.DemonsurgeAbyssalGaze = true
        aura_env.DemonsurgeAnnihilationBuff = true
        aura_env.DemonsurgeConsumingFireBuff = true
        aura_env.DemonsurgeDeathSweepBuff = true
        aura_env.DemonsurgeSigilOfDoomBuff = true
        return
    end
    
    if spellID == aura_env.ids.ReaversGlaive then
        aura_env.ReaversGlaiveLastUsed = GetTime()
    end
    
    return
end
