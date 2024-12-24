function()
    local spellID = 44614
    if spellID == nil then
        local c = a < b -- Throw an error
        print("Error: spellID is nil")
    end
    
    if not IsPlayerSpell(spellID) then print("Error: spellID is not player spell") return false end
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) and (not nomana) then print("No usable/mana") return false end
    
    local Duration = C_Spell.GetSpellCooldown(spellID).duration
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    if not OffCooldown then print("Not OffCooldown") return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    if InRange == 0 then
        aura_env.OutOfRange = true
        return false
    end
    
    print("Spell is ready")
    return true
end