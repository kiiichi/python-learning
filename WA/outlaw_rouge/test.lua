function()

    local OffCooldown = function(spellID)
        if spellID == nil then
            local c = a < b -- Throw an error
        end
        
        if not IsPlayerSpell(spellID) then return false end
        -- Kichi --
        -- if aura_env.config[tostring(spellID)] == false then return false end
        
        local usable, nomana = C_Spell.IsSpellUsable(spellID)
        -- Kichi only for outlaw killing spree --
        -- if (not usable) and (not nomana) then return false end
        if (not usable) and not(WA_GetUnitBuff("player", 51690) ~= nil) or nomana then print("1") return false end
        
        -- Kichi --
        -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
        -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
        local Cooldown = C_Spell.GetSpellCooldown(spellID)
        local Duration = Cooldown.duration
        local Remaining = Cooldown.startTime + Duration - GetTime()
        local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())

        if not OffCooldown then print("2") return false end
        
        local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
        local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
        
        if InRange == false then
            aura_env.OutOfRange = true
            --return false
        end
        print("3")
        return true
    end

    OffCooldown(193315) -- Blade Flurry




    return true




end



function()
    local spellID = 61304
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    print("usable", usable, "nomana", nomana)

    return true
end