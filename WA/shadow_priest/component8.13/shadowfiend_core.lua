env.test = function(allStates, event, timestamp, subEvent, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)  
    
    -- MB/SF initial cast check
    if UnitGUID("player") == sourceGUID and subEvent == "SPELL_SUMMON" and (spellID == 200174 or spellID == 34433 or spellID == 451235) then
        local BaseDuration = 15
        local EndTime = GetTime() + BaseDuration
        
        local SpellInfo = C_Spell.GetSpellInfo(spellID)
        
        allStates["bender"] = {
            show = true,
            changed = true,
            progressType = "timed",
            duration = BaseDuration,
            expirationTime = EndTime,
            autoHide = true,
            name = SpellInfo.name,
            icon = SpellInfo.iconID,
        }
        WeakAuras.ScanEvents("K_UPDATE_SHADOWFIEND_EXPIRATION", EndTime)
        return true
    end
    
    -- Extend duration if Inescapable Torment active
    if UnitGUID("player") == sourceGUID and subEvent == "SPELL_CAST_SUCCESS" and IsPlayerSpell(373427) and (spellID == 8092 or spellID == 32379) then
        if allStates["bender"] and allStates["bender"].show then            
            allStates["bender"].duration = allStates["bender"].duration + 0.7
            allStates["bender"].expirationTime = allStates["bender"].expirationTime + 0.7
            allStates["bender"].changed = true
            
            WeakAuras.ScanEvents("K_UPDATE_SHADOWFIEND_EXPIRATION", allStates["bender"].expirationTime)
            return true
        end
    end
end