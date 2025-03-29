env.test = function( _,_,subEvent,_,sourceGUID,_,_,_,_,_,_,_,spellID,_, amount)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        aura_env.PrevCast = spellID
        
        if spellID == aura_env.ids.LightningBolt then
            aura_env.LastTISpell = aura_env.ids.LightningBolt
            aura_env.LightningBoltLastUsed = GetTime()
        elseif spellID == aura_env.ids.ChainLightning then
            aura_env.LastTISpell = aura_env.ids.ChainLightning
            aura_env.ChainLightningLastUsed = GetTime()
            -- Alpha Wolf activated
            aura_env.MinAlphaWolf = GetTime() + 8
        elseif spellID == aura_env.ids.Tempest then
            aura_env.TempestLastUsed = GetTime()
            if aura_env.AwakeningStormsTempest == true then
                aura_env.AwakeningStormsTempest = false
            else
                aura_env.TempestMaelstromCount = 0
            end
        elseif spellID == aura_env.ids.CrashLightning then
            -- Alpha Wolf activated
            aura_env.MinAlphaWolf = GetTime() + 8
        elseif spellID == aura_env.ids.Stormstrike then
            aura_env.StormstrikeLastUsed = GetTime()
        elseif spellID == aura_env.ids.Windstrike then
            aura_env.WindstrikeLastUsed = GetTime()
        elseif spellID == aura_env.ids.LavaLash then
            aura_env.LavaLashLastUsed = GetTime()
        end
    end
    
    if subEvent == "SPELL_AURA_REMOVED" then
        if spellID == aura_env.ids.MaelstromWeapon then
            aura_env.TempestMaelstromCount = aura_env.TempestMaelstromCount + aura_env.SavedMaelstrom
            aura_env.SavedMaelstrom = 0
        elseif spellID == aura_env.ids.AwakeningStorms then
            aura_env.AwakeningStormsTempest = true
        end
    end
    
    if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_APPLIED_DOSE") and spellID == aura_env.ids.MaelstromWeapon then
        aura_env.SavedMaelstrom = min(aura_env.SavedMaelstrom + amount, 10)
    end
    
    -- Alpha Wolf Reset
    if subEvent == "SPELL_SUMMON" and (spellID == 426516 or spellID == 228562 or spellID == 262627) then
        aura_env.MinAlphaWolf = 0
    end
    return
end
