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
    local KTrigTinyCD = aura_env.KTrigTinyCD
    aura_env.FlagKTrigCD = true
    local FullGCD = aura_env.FullGCD
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    -- Kichi fix for NG wrong
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1931)
    -- local SetPieces = WeakAuras.GetNumSetItemsEquipped(1879)
    
    local CurrentRage = UnitPower("player", Enum.PowerType.Rage)
    local MaxRage = UnitPowerMax("player", Enum.PowerType.Rage)
    
    local NearbyEnemies = 0
    local NearbyRange = 25
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end    
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables = {}
    Variables.StPlanning = NearbyEnemies <= 1
    
    Variables.AddsRemain = NearbyEnemies >= 2
    
    Variables.ExecutePhase = ( IsPlayerSpell(ids.MassacreTalent) and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 ) or (UnitHealth("target")/UnitHealthMax("target")*100) < 2
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Recklessness
    if OffCooldown(ids.Recklessness) and ( ( not IsPlayerSpell(ids.AngerManagementTalent) and IsPlayerSpell(ids.TitansTormentTalent) ) or IsPlayerSpell(ids.AngerManagementTalent) or not IsPlayerSpell(ids.TitansTormentTalent) ) then
        ExtraGlows.Recklessness = true
    end
    
    -- Avatar
    if OffCooldown(ids.Avatar) then
        ExtraGlows.Avatar = true
    end
    
    -- Kichi --
    if aura_env.config["SavingCD"] == false and FightRemains(60, 40) <= aura_env.config["SavingCDTime"] then
        WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, "Saving")
    elseif aura_env.config["SavingCD"] == true and FightRemains(60, 40) <= aura_env.config["SavingCDTime"] then
        WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
    else WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    end

    -- Kichi --
    local NoMeatCleaverBuff = GetPlayerStacks(ids.MeatCleaverBuff) == 0 or GetPlayerStacks(ids.MeatCleaverBuff) == 1 and ( aura_env.ListenSpellInMeatCleaver == ids.Execute or aura_env.ListenSpellInMeatCleaver == ids.Onslaught or aura_env.ListenSpellInMeatCleaver == ids.Rampage or aura_env.ListenSpellInMeatCleaver == ids.RagingBlow or aura_env.ListenSpellInMeatCleaver == ids.Bloodthirst )

    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Slayer = function()
        -- Kichi replace WeakAuras.gcdDuration() to FullGCD()
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.AshenJuggernautBuff) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) < FullGCD() ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetRemainingAuraDuration("player", ids.SuddenDeathBuff) < 2 and not Variables.ExecutePhase ) then
            KTrig("Execute") return true end

        -- Kichi add for quick 4 pc buff
        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and ( IsPlayerSpell(ids.RecklessAbandonTalent) and GetRemainingSpellCooldown(ids.Avatar) >= 24 or IsPlayerSpell(ids.AngerManagementTalent) and GetRemainingSpellCooldown(ids.Recklessness) >= 15 and ( PlayerHasBuff(ids.Avatar) or GetRemainingSpellCooldown(ids.Avatar) >= 8 ) ) ) then
            -- KTrig("Bladestorm") return true end
            if aura_env.config[tostring(ids.Bladestorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bladestorm")
            elseif aura_env.config[tostring(ids.Bladestorm)] ~= true then
                KTrig("Bladestorm")
                return true
            end
        end

        -- Kichi update for simc 9.3 update
        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( OffCooldown(ids.Bladestorm) and ( OffCooldown(ids.Avatar) or OffCooldown(ids.Recklessness) or PlayerHasBuff(ids.Avatar) or PlayerHasBuff(ids.RecklessnessBuff) ) and PlayerHasBuff(ids.EnrageBuff) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end

        -- Kichi update for simc 9.3 update
        -- actions.slayer+=/odyns_fury,if=active_enemies>1&talent.titanic_rage&buff.meat_cleaver.stack=0
        if OffCooldown(ids.OdynsFury) and NearbyEnemies > 1 and IsPlayerSpell(ids.TitanicRageTalent) and NoMeatCleaverBuff then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and ( IsPlayerSpell(ids.RecklessAbandonTalent) and GetRemainingSpellCooldown(ids.Avatar) >= 24 or IsPlayerSpell(ids.AngerManagementTalent) and GetRemainingSpellCooldown(ids.Recklessness) >= 15 and ( PlayerHasBuff(ids.Avatar) or GetRemainingSpellCooldown(ids.Avatar) >= 8 ) ) ) then
            -- KTrig("Bladestorm") return true end
            if aura_env.config[tostring(ids.Bladestorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bladestorm")
            elseif aura_env.config[tostring(ids.Bladestorm)] ~= true then
                KTrig("Bladestorm")
                return true
            end
        end
        
        -- Kichi change "GetPlayerStacks(ids.MeatCleaverBuff) == 0" to "NoMeatCleaverBuff" for fast prediction
        if OffCooldown(ids.Whirlwind) and ( NearbyEnemies >= 2 and IsPlayerSpell(ids.MeatCleaverTalent) and NoMeatCleaverBuff ) then
            KTrig("Whirlwind") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) and PlayerHasBuff(ids.BrutalFinishBuff) ) then
            KTrig("Onslaught") return true end

        -- Kichi replace WeakAuras.gcdDuration() to FullGCD()
        if OffCooldown(ids.Rampage) and ( GetRemainingAuraDuration("player", ids.EnrageBuff) < FullGCD() ) then
            KTrig("Rampage") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetPlayerStacks(ids.SuddenDeathBuff) == 2 and PlayerHasBuff(ids.EnrageBuff) and not PlayerHasBuff(ids.BrutalFinishBuff) ) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetTargetStacks(ids.MarkedForExecutionDebuff) >= aura_env.config["MarkedForExecutionDebuffStacks"] and PlayerHasBuff(ids.EnrageBuff) ) then
            KTrig("Execute") return true end
        
        -- Kichi update for simc 9.3 update
        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( not IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow and ( C_Spell.GetSpellCharges(ids.RagingBlow).currentCharges == 2 or PlayerHasBuff(ids.BrutalFinishBuff) and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            KTrig("Crushing Blow") return true end
        
        -- Kichi replace WeakAuras.gcdDuration() to FullGCD()
        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath and ( GetPlayerStacks(ids.BloodcrazeBuff) >= 1 or ( IsPlayerSpell(ids.UproarTalent) and GetRemainingDebuffDuration("target", ids.BloodbathDotDebuff) < 40 and IsPlayerSpell(ids.BloodborneTalent) ) or PlayerHasBuff(ids.EnrageBuff) and GetRemainingAuraDuration("player", ids.EnrageBuff) < FullGCD() ) then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( NearbyEnemies>=8 and SetPieces>=4 or PlayerHasBuff(ids.BrutalFinishBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) < 5 and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage > 115 ) then
            KTrig("Rampage") return true end

        -- Kichi update for simc 9.3 update
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( Variables.ExecutePhase and TargetHasDebuff(ids.MarkedForExecutionDebuff) and PlayerHasBuff(ids.EnrageBuff) and NearbyEnemies > 1 ) then
            KTrig("Execute") return true end

        -- Kichi update for simc 9.3 update
        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) and PlayerHasBuff(ids.BrutalFinishBuff) and PlayerHasBuff(ids.EnrageBuff) and GetPlayerStacks(ids.BloodcrazeBuff) >= 5 and NearbyEnemies == 1 or not (SetPieces >= 4) and NearbyEnemies > 4 ) then
            KTrig("Bloodthirst") return true end

        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            KTrig("Crushing Blow") return true end

        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( PlayerHasBuff(ids.OpportunistBuff) ) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) and GetPlayerStacks(ids.BloodcrazeBuff) >= 4 ) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.RagingBlow) and ( GetSpellChargesFractional(ids.RagingBlow) == 2 ) then
            KTrig("Raging Blow") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            KTrig("Onslaught") return true end

        if OffCooldown(ids.RagingBlow) then
            KTrig("Raging Blow") return true end

        if OffCooldown(ids.Rampage) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.SuddenDeathBuff) ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.Bloodthirst) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.ThunderousRoar) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.WreckingThrow) then
            KTrig("Wrecking Throw") return true end
        
        if OffCooldown(ids.Whirlwind) then
            KTrig("Whirlwind") return true end
        
        --if OffCooldown(ids.StormBolt) and ( PlayerHasBuff(ids.BladestormBuff) ) then
        --    KTrig("Storm Bolt") return true end
    end
    
    local Thane = function()
        if OffCooldown(ids.Ravager) then
            -- KTrig("Ravager") return true end
            if aura_env.config[tostring(ids.Ravager)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ravager")
            elseif aura_env.config[tostring(ids.Ravager)] ~= true then
                KTrig("Ravager")
                return true
            end
        end

        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.ChampionsMightTalent) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end
        
        -- Kichi change "GetPlayerStacks(ids.MeatCleaverBuff) == 0" to "NoMeatCleaverBuff" for fast prediction
        if OffCooldown(ids.ThunderClap) and ( NoMeatCleaverBuff and IsPlayerSpell(ids.MeatCleaverTalent) and NearbyEnemies >= 2 ) then
            KTrig("Thunder Clap") return true end
        
        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.MeatCleaverTalent) ) then
            KTrig("Thunder Blast") return true end

        -- Kichi replace WeakAuras.gcdDuration() to FullGCD()
        if OffCooldown(ids.Rampage) and ( not PlayerHasBuff(ids.EnrageBuff) or ( IsPlayerSpell(ids.Bladestorm) and GetRemainingSpellCooldown(ids.Bladestorm) <= FullGCD() and not TargetHasDebuff(ids.ChampionsMightDebuff) ) ) then
            KTrig("Rampage") return true end
        
        -- Kichi replace WeakAuras.gcdDuration() to FullGCD()
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( IsPlayerSpell(ids.AshenJuggernautTalent) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) <= FullGCD() ) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.UnhingedTalent) ) then
            -- KTrig("Bladestorm") return true end
            if aura_env.config[tostring(ids.Bladestorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bladestorm")
            elseif aura_env.config[tostring(ids.Bladestorm)] ~= true then
                KTrig("Bladestorm")
                return true
            end
        end

        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 115 and IsPlayerSpell(ids.RecklessAbandonTalent) and PlayerHasBuff(ids.RecklessnessBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) >= 3 ) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            KTrig("Crushing Blow") return true end
        
        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            KTrig("Onslaught") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( IsPlayerSpell(ids.ViciousContemptTalent) and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 ) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 100 ) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.Bloodthirst) then
            KTrig("Bloodthirst") return true end

        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.RagingBlow) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) then
            KTrig("Rampage") return true end

        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( not IsPlayerSpell(ids.MeatCleaverTalent) ) then
            KTrig("Thunder Blast") return true end

        if OffCooldown(ids.ThunderousRoar) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( not IsPlayerSpell(ids.ChampionsMightTalent) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.WreckingThrow) then
            KTrig("Wrecking Throw") return true end
        
        if OffCooldown(ids.ThunderClap) then
            KTrig("Thunder Clap") return true end

        if OffCooldown(ids.Whirlwind) then
            KTrig("Whirlwind") return true end
    end
    
    if IsPlayerSpell(ids.SlayersDominanceTalent) then
        Slayer() return true end
    
    if IsPlayerSpell(ids.LightningStrikesTalent) then
        Thane() return true end
    
    KTrig("Clear")
    KTrigCD("Clear")

end
