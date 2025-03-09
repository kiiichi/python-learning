env.test = function()
    if (aura_env.LastUpdate and aura_env.LastUpdate > GetTime() - aura_env.config["UpdateFrequency"])
    then
        return 
    end
    aura_env.LastUpdate = GetTime()
    
    ---- Setup ----------------------------------------------------------------------------------------------------
    local CurrentTime = GetTime()
    
    local OffCooldown = aura_env.OffCooldown
    local OffCooldownNotCasting = aura_env.OffCooldownNotCasting
    local GetRemainingAuraDuration = aura_env.GetRemainingAuraDuration
    local GetRemainingDebuffDuration = aura_env.GetRemainingDebuffDuration
    local GetRemainingSpellCooldown = aura_env.GetRemainingSpellCooldown
    local IsCasting = aura_env.IsCasting
    local GetPlayerStacks = aura_env.GetPlayerStacks
    local GetTargetStacks = aura_env.GetTargetStacks
    local PlayerHasBuff = aura_env.PlayerHasBuff
    local TargetHasDebuff = aura_env.TargetHasDebuff
    local HasBloodlust = aura_env.HasBloodlust
    local GetSpellChargesFractional = aura_env.GetSpellChargesFractional
    local GetTimeToNextCharge = aura_env.GetTimeToNextCharge
    local GetTimeToFullCharges = aura_env.GetTimeToFullCharges
    local TargetTimeToXPct = aura_env.TargetTimeToXPct
    local FightRemains = aura_env.FightRemains
    local IsAuraRefreshable = aura_env.IsAuraRefreshable
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1689)
    local CurrentHolyPower = UnitPower("player", Enum.PowerType.HolyPower)
    
    local NearbyEnemies = 0
    local NearbyRange = 8
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)
    
    local TemplarStrikeRemaining = max(aura_env.TemplarStrikeExpires - GetTime(), 0)
    local CrusadeRemainingCooldown = ((IsPlayerSpell(ids.Crusade) and not IsPlayerSpell(ids.RadiantGloryTalent)) and GetRemainingSpellCooldown(ids.Crusade) or 0)
    local AvengingWrathRemainingCooldown = ((IsPlayerSpell(ids.AvengingWrath) and not IsPlayerSpell(ids.RadiantGloryTalent) and not IsPlayerSpell(ids.Crusade)) and GetRemainingSpellCooldown(ids.AvengingWrath) or 0)
    local CrusadeOffCooldown = ((IsPlayerSpell(ids.Crusade) and not IsPlayerSpell(ids.RadiantGloryTalent)) and GetRemainingSpellCooldown(ids.Crusade) == 0 or false)
    local AvengingWrathOffCooldown = ((IsPlayerSpell(ids.AvengingWrath) and not IsPlayerSpell(ids.RadiantGloryTalent) and not IsPlayerSpell(ids.Crusade)) and GetRemainingSpellCooldown(ids.AvengingWrath) == 0 or false)
    
    if IsPlayerSpell(ids.RadiantGloryTalent) then ids.CrusadeBuff = ids.RadiantGloryCrusadeBuff end
    if IsPlayerSpell(ids.RadiantGloryTalent) then ids.AvengingWrathBuff = ids.RadiantGloryAvangeningWrathBuff end
    
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}

    -- Avenging Wrath
    if AvengingWrathOffCooldown and ( ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and IsPlayerSpell(ids.DivineAuxiliaryTalent) and ( GetRemainingSpellCooldown(ids.ExecutionSentence) == 0 or GetRemainingSpellCooldown(ids.FinalReckoning) == 0 ) ) ) then
    ExtraGlows.AvengingWrath = true end
    
    if CrusadeOffCooldown and ( CurrentHolyPower >= 3 ) then
    ExtraGlows.Crusade = true end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cooldowns = function()
        if OffCooldown(ids.ExecutionSentence) and ( ( not PlayerHasBuff(ids.CrusadeBuff) and CrusadeRemainingCooldown > 15 or GetPlayerStacks(ids.CrusadeBuff) == 10 or AvengingWrathRemainingCooldown < 0.75 or AvengingWrathRemainingCooldown > 15 or IsPlayerSpell(ids.RadiantGloryTalent) ) and ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and ( IsPlayerSpell(ids.DivineAuxiliaryTalent) or IsPlayerSpell(ids.RadiantGloryTalent) ) ) and ( GetRemainingSpellCooldown(ids.DivineHammer) > 5 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) and ( TargetTimeToXPct(0, 60) > 8 and not IsPlayerSpell(ids.ExecutionersWillTalent) or TargetTimeToXPct(0, 60) > 12 ) and GetRemainingSpellCooldown(ids.WakeOfAshes) < WeakAuras.gcdDuration() ) then
            -- KTrig("Execution Sentence") return true end
            if aura_env.config[tostring(ids.ExecutionSentence)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Execution Sentence")
            elseif aura_env.config[tostring(ids.ExecutionSentence)] ~= true then
                KTrig("Execution Sentence")
                return true
            end
        end
        
        if OffCooldown(ids.FinalReckoning) and ( ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and ( IsPlayerSpell(ids.DivineAuxiliaryTalent) or IsPlayerSpell(ids.RadiantGloryTalent) ) ) and ( not IsPlayerSpell(ids.Crusade) and AvengingWrathRemainingCooldown > 10 or CrusadeRemainingCooldown > 0 and ( not PlayerHasBuff(ids.CrusadeBuff) or GetPlayerStacks(ids.CrusadeBuff) >= 10 ) or IsPlayerSpell(ids.RadiantGloryTalent) and ( PlayerHasBuff(ids.AvengingWrathBuff) or IsPlayerSpell(ids.Crusade) and GetRemainingSpellCooldown(ids.WakeOfAshes) < WeakAuras.gcdDuration() ) ) ) then
            -- KTrig("Final Reckoning") return true end
            if aura_env.config[tostring(ids.FinalReckoning)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Final Reckoning")
            elseif aura_env.config[tostring(ids.FinalReckoning)] ~= true then
                KTrig("Final Reckoning")
                return true
            end
        end

    end
    
    local Finishers = function()
        Variables.DsCastable = ( NearbyEnemies >= 2 or PlayerHasBuff(ids.EmpyreanPowerBuff) or not IsPlayerSpell(ids.FinalVerdict) and IsPlayerSpell(ids.TempestOfTheLightbringerTalent) ) and not PlayerHasBuff(ids.EmpyreanLegacyBuff) and not ( PlayerHasBuff(ids.DivineArbiterBuff) and GetPlayerStacks(ids.DivineArbiterBuff) > 24 )
        
        if FindSpellOverrideByID(ids.WakeOfAshes) == ids.HammerOfLight and (FindSpellOverrideByID(ids.WakeOfAshes) == ids.HammerOfLight or not IsPlayerSpell(ids.DivineHammer) or PlayerHasBuff(ids.DivineHammerBuff) or GetRemainingSpellCooldown(ids.DivineHammer) > 10) then
            KTrig("Hammer of Light") return true end
        
        if OffCooldown(ids.DivineHammer) and ( not PlayerHasBuff(ids.DivineHammerBuff) ) then
            -- KTrig("Divine Hammer") return true end
            if aura_env.config[tostring(ids.DivineHammer)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Divine Hammer")
            elseif aura_env.config[tostring(ids.DivineHammer)] ~= true then
                KTrig("Divine Hammer")
                return true
            end
        end
        
        if OffCooldown(ids.DivineStorm) and ( Variables.DsCastable and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) and ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) ) then
            KTrig("Divine Storm") return true end
        
        if OffCooldown(ids.JusticarsVengeance) and ( ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) ) then
            KTrig("Justicars Vengeance") return true end
        
        if OffCooldown(ids.TemplarsVerdict) and ( ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) ) then
            KTrig("Templars Verdict") return true end
    end
    
    local Generators = function()
        if (CurrentHolyPower == 5 or CurrentHolyPower == 4 and PlayerHasBuff(ids.DivineResonanceBuff) or PlayerHasBuff(ids.AllInBuff)) and GetRemainingSpellCooldown(ids.WakeOfAshes) > 0 then
            if Finishers() then return true end end

        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash and ( TemplarStrikeRemaining < WeakAuras.gcdDuration() * 2 ) then
            KTrig("Templar Slash") return true end

        if OffCooldown(ids.BladeOfJustice) and (not TargetHasDebuff(ids.ExpurgationDebuff) and IsPlayerSpell(ids.HolyFlamesTalent) and GetRemainingSpellCooldown(ids.DivineToll) > 0 ) then
            KTrig("Blade of Justice") return true end

        if OffCooldown(ids.WakeOfAshes) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and ( ( not IsPlayerSpell(ids.LightsGuidanceTalent) or CurrentHolyPower >= 2 and IsPlayerSpell(ids.LightsGuidanceTalent) ) and ( AvengingWrathRemainingCooldown > 6 or GetRemainingSpellCooldown(ids.Crusade) > 6 or IsPlayerSpell(ids.RadiantGloryTalent) ) and ( not IsPlayerSpell(ids.ExecutionSentence) or GetRemainingSpellCooldown(ids.ExecutionSentence) > 4 or TargetTimeToXPct(0, 60) < 8 ) ) then
            -- KTrig("Wake of Ashes") return true end
            if aura_env.config[tostring(ids.WakeOfAshes)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wake of Ashes")
            elseif aura_env.config[tostring(ids.WakeOfAshes)] ~= true then
                KTrig("Wake of Ashes")
                return true
            end
        end
        
        if OffCooldown(ids.DivineToll) and ( CurrentHolyPower <= 2 and ( ( AvengingWrathRemainingCooldown > 15 or GetRemainingSpellCooldown(ids.Crusade) > 15 or IsPlayerSpell(ids.RadiantGloryTalent) or FightRemains(60, NearbyRange) < 8 ) ) ) then   
            -- KTrig("Divine Toll") return true end
            if aura_env.config[tostring(ids.DivineToll)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Divine Toll")
            elseif aura_env.config[tostring(ids.DivineToll)] ~= true then
                KTrig("Divine Toll")
                return true
            end
        end
        
        if Finishers() then return true end
        
        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash and ( TemplarStrikeRemaining < WeakAuras.gcdDuration() and NearbyEnemies >= 2 ) then
            KTrig("Templar Slash") return true end
        
        if OffCooldown(ids.BladeOfJustice) and ( NearbyEnemies >= 2 and IsPlayerSpell(ids.BladeOfVengeanceTalent) ) then
            KTrig("Blade of Justice") return true end
        
        if OffCooldown(ids.HammerOfWrath) and ( ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BlessedChampionTalent) ) and PlayerHasBuff(ids.BlessingOfAnsheBuff) ) then
            KTrig("Hammer of Wrath") return true end
            
        if OffCooldown(ids.TemplarStrike) then
            KTrig("Templar Strike") return true end
        
        if OffCooldown(ids.Judgment) then
            KTrig("Judgment") return true end
        
        if OffCooldown(ids.BladeOfJustice) then
            KTrig("Blade of Justice") return true end
        
        if OffCooldown(ids.HammerOfWrath) and ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BlessedChampionTalent) ) then
            KTrig("Hammer of Wrath") return true end
        
        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash then
            KTrig("Templar Slash") return true end
        
        if OffCooldown(ids.CrusaderStrike) and not IsPlayerSpell(ids.TemplarStrikesTalent) and not IsPlayerSpell(ids.CrusadingStrikesTalent) then
            KTrig("Crusader Strike") return true end
            
        if OffCooldown(ids.HammerOfWrath) then
            KTrig("Hammer of Wrath") return true end
    end
    
    if Cooldowns() then return true end
    
    if Generators() then return true end
    
    -- Kichi --
    KTrig("Clear")
    KTrigCD("Clear")
end

