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

    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    if IsPlayerSpell(ids.Defile) then ids.DeathAndDecay = ids.Defile end
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1919)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1867)
    
    local CurrentRunes = 0
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            CurrentRunes = CurrentRunes + 1
        end
    end
    
    local CurrentRunicPower = UnitPower("player", Enum.PowerType.RunicPower)
    local MaxRunicPower = UnitPowerMax("player", Enum.PowerType.RunicPower)
    
    local GargoyleRemaining = max(aura_env.GargoyleExpiration - GetTime(), 0)
    local ApocalypseRemaining = max(aura_env.ApocalypseExpiration - GetTime(), 0)
    local ArmyRemaining = max(aura_env.ArmyExpiration - GetTime(), 0)
    local AbominationRemaining = max(aura_env.AbominationExpiration - GetTime(), 0)
    
    local TargetsWithFesteringWounds = 0
    local NearbyEnemies = 0
    local NearbyRange = 10
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.FesteringWoundDebuff, "PLAYER||HARMFUL") ~= nil then
                TargetsWithFesteringWounds = TargetsWithFesteringWounds + 1
            end
        end
    end
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)
    -- WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    if NearbyEnemies <= 1 then
    Variables.StPlanning = true else Variables.StPlanning = false end
    
    if NearbyEnemies >= 2 then
    Variables.AddsRemain = true else Variables.AddsRemain = false end
    
    if GetRemainingSpellCooldown(ids.Apocalypse) < 5 and GetTargetStacks(ids.FesteringWoundDebuff) < 4 and GetRemainingSpellCooldown(ids.UnholyAssault) > 5 then
    Variables.ApocTiming = 5 else Variables.ApocTiming = 2 end
    
    if GetRemainingSpellCooldown(ids.SummonGargoyle) > 5 and CurrentRunicPower < 40 then
    Variables.PoolingRunicPower = true else Variables.PoolingRunicPower = false end
    
    if ( GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming or not IsPlayerSpell(ids.Apocalypse) ) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and GetRemainingSpellCooldown(ids.UnholyAssault) < 20 and IsPlayerSpell(ids.UnholyAssault) and Variables.StPlanning or TargetHasDebuff(ids.RottenTouchDebuff) and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or GetTargetStacks(ids.FesteringWoundDebuff) >= 4 - (AbominationRemaining > 0 and 1 or 0) ) or FightRemains(10, NearbyRange) < 5 and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 then
    Variables.PopWounds = true else Variables.PopWounds = false end
    
    if ( not IsPlayerSpell(ids.RottenTouchTalent) or IsPlayerSpell(ids.RottenTouchTalent) and not TargetHasDebuff(ids.RottenTouchDebuff) or MaxRunicPower - CurrentRunicPower < 20 ) and ( ( IsPlayerSpell(ids.ImprovedDeathCoilTalent) and ( NearbyEnemies == 2 or IsPlayerSpell(ids.CoilOfDevastationTalent) ) or CurrentRunes < 3 or GargoyleRemaining or PlayerHasBuff(ids.SuddenDoomBuff) or not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) >= 4 ) ) then
    Variables.SpendRp = true else Variables.SpendRp = false end
    
    Variables.SanCoilMult = (GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) >= 4 and 2 or 1)
    
    Variables.EpidemicTargets = 3 + (IsPlayerSpell(ids.ImprovedDeathCoilTalent) and 1 or 0) + ((IsPlayerSpell(ids.FrenziedBloodthirstTalent) and 1 or 0) * Variables.SanCoilMult) + ((IsPlayerSpell(ids.HungeringThirstTalent) and IsPlayerSpell(ids.HarbingerOfDoomTalent) and PlayerHasBuff(ids.SuddenDoomBuff)) and 1 or 0)

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.ArmyOfTheDead) and not IsPlayerSpell(ids.RaiseAbomination) and not IsPlayerSpell(ids.LegionOfSouls) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( IsPlayerSpell(ids.CommanderOfTheDeadTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 or not IsPlayerSpell(ids.CommanderOfTheDeadTalent) and NearbyEnemies >= 1 ) or FightRemains(30, NearbyRange) < 35 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( not IsPlayerSpell(ids.VampiricStrikeTalent) or ( ApocalypseRemaining > 0 or not IsPlayerSpell(ids.ApocalypseTalent))) or FightRemains(25, NearbyRange) < 30 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.SummonGargoyle) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( PlayerHasBuff(ids.CommanderOfTheDeadBuff) or not IsPlayerSpell(ids.CommanderOfTheDeadTalent) and NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 25 ) then
        ExtraGlows.SummonGargoyle = true
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AOE
    local Aoe = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            -- KTrig("Festering Scythe") return true end
            if aura_env.config[tostring(ids.FesteringScythe)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Festering Scythe")
            elseif aura_env.config[tostring(ids.FesteringScythe)] ~= true then
                KTrig("Festering Scythe")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( CurrentRunes < 4 and NearbyEnemies < Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( CurrentRunes < 4 and NearbyEnemies > Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) then
            KTrig("Epidemic") return true end

        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.BurstingSoresTalent) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            KTrig("Epidemic") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            KTrig("Scourge Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming or PlayerHasBuff(ids.FesteringScytheBuff) ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 2 ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and GetRemainingSpellCooldown(ids.Apocalypse) > WeakAuras.gcdDuration() or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and TargetHasDebuff(ids.VirulentPlagueDebuff) ) then
            KTrig("Scourge Strike") return true end
    end
    
    -- AoE Burst
    local AoeBurst = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            -- KTrig("Festering Scythe") return true end
            if aura_env.config[tostring(ids.FesteringScythe)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Festering Scythe")
            elseif aura_env.config[tostring(ids.FesteringScythe)] ~= true then
                KTrig("Festering Scythe")
                return true
            end
        end

        -- Kichi 8.9 add "GetTimeToFullCharges(ids.DeathAndDecay) < 3 and TargetHasDebuff(ids.VirulentPlagueDebuff)" to qickly move into burst phase
        if OffCooldown(ids.DeathAndDecay) and FindSpellOverrideByID(ids.DeathAndDecay) ~= ids.Desecrate and ( TargetsWithFesteringWounds >= NearbyEnemies and IsPlayerSpell(ids.DesecrateTalent) and ( IsPlayerSpell(ids.FesteringScytheTalent) and TargetsWithFesteringWounds == 0 and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 and not PlayerHasBuff(ids.FesteringScytheBuff) or not IsPlayerSpell(ids.FesteringScytheTalent))) then
            -- KTrig("Death And Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death And Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death And Decay")
                return true
            end
        end

        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and NearbyEnemies < Variables.EpidemicTargets and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and PlayerHasBuff(ids.SuddenDoomBuff) and TargetsWithFesteringWounds < NearbyEnemies * 0.4 or PlayerHasBuff(ids.SuddenDoomBuff) and ( IsPlayerSpell(ids.DoomedBiddingTalent) and IsPlayerSpell(ids.MenacingMagusTalent) or IsPlayerSpell(ids.RottenTouchTalent) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() ) or CurrentRunes < 2 ) or
            ( (CurrentRunes < 4 or NearbyEnemies < 4) and NearbyEnemies < Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) ) then
            KTrig("Death Coil") return true end
        
        -- 4.25 update from Kichi 4.12 simc modify to 4.25 raw simc, not very sure it is better
        -- if OffCooldown(ids.Epidemic) and ( ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike or CurrentRunes < 1 and NearbyEnemies > 7 ) and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoomBuff) or PlayerHasBuff(ids.SuddenDoomBuff) and ( PlayerHasBuff(ids.AFeastOfSoulsBuff) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRotDebuff) < 10 ) or CurrentRunes < 2 ) ) then
        -- if OffCooldown(ids.Epidemic) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoomBuff) or PlayerHasBuff(ids.SuddenDoomBuff) and ( PlayerHasBuff(ids.AFeastOfSoulsBuff) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRotDebuff) < 10 ) or CurrentRunes < 2 ) or ( CurrentRunes < 4 and NearbyEnemies > Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) ) then
        if OffCooldown(ids.Epidemic) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and PlayerHasBuff(ids.SuddenDoomBuff) and TargetsWithFesteringWounds < NearbyEnemies * 0.4 or PlayerHasBuff(ids.SuddenDoomBuff) and ( PlayerHasBuff(ids.AFeastOfSoulsBuff) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRotDebuff) < 10 ) or CurrentRunes < 2 ) or ( CurrentRunes < 4 and NearbyEnemies >= Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) ) then
            KTrig("Epidemic") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            KTrig("Scourge Strike") return true end
        
        -- Kichi for Scourge Scy modify 4.12 and also combined with 4.25 simc update --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike or PlayerHasBuff(ids.DeathAndDecayBuff) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( Variables.EpidemicTargets <= NearbyEnemies ) then
            KTrig("Epidemic") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) <= 2 ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) then
            KTrig("Scourge Strike") return true end
    end
    
    -- AoE Setup
    local AoeSetup = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            -- KTrig("Festering Scythe") return true end
            if aura_env.config[tostring(ids.FesteringScythe)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Festering Scythe")
            elseif aura_env.config[tostring(ids.FesteringScythe)] ~= true then
                KTrig("Festering Scythe")
                return true
            end
        end

        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( GetTimeToFullCharges(ids.DeathAndDecay) < 3 and TargetHasDebuff(ids.VirulentPlagueDebuff) or TargetsWithFesteringWounds >= NearbyEnemies and ( CurrentRunes > 3 or CurrentRunicPower < 30 ) or IsPlayerSpell(ids.DesecrateTalent) and ( IsPlayerSpell(ids.FesteringScytheTalent) and TargetsWithFesteringWounds == 0 and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 and not PlayerHasBuff(ids.FesteringScytheBuff) or not IsPlayerSpell(ids.FesteringScytheTalent) ) ) ) then
            -- KTrig("Death And Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death And Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death And Decay")
                return true
            end
        end

        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( TargetsWithFesteringWounds == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() and ( (GetRemainingSpellCooldown(ids.DarkTransformation) > 0 or IsPlayerSpell(ids.Apocalypse) ) and GetRemainingSpellCooldown(ids.UnholyAssault) > 0 or GetRemainingSpellCooldown(ids.UnholyAssault) > 0 or not IsPlayerSpell(ids.UnholyAssault) ) ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoomBuff) and NearbyEnemies < Variables.EpidemicTargets and CurrentRunes < 4 ) then
            KTrig("Death Coil") return true end

        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and Variables.EpidemicTargets <= NearbyEnemies and CurrentRunes < 4 ) then
            KTrig("Epidemic") return true end
        
        -- Kichi fix for 4.12 NGA because his mistake --
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( not IsPlayerSpell(ids.BurstingSoresTalent) or TargetsWithFesteringWounds >= NearbyEnemies or TargetsWithFesteringWounds >= 8 or not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.Defile) and CurrentRunes > 3 ) ) then
            -- KTrig("Death And Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death And Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death And Decay")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets and ( PlayerHasBuff(ids.SuddenDoomBuff) or TargetsWithFesteringWounds >= NearbyEnemies or TargetsWithFesteringWounds >= 8 ) ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and Variables.EpidemicTargets <= NearbyEnemies and ( PlayerHasBuff(ids.SuddenDoomBuff) or TargetsWithFesteringWounds >= NearbyEnemies or TargetsWithFesteringWounds >= 8 ) ) then
            KTrig("Epidemic") return true end
            
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            KTrig("Epidemic") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( TargetsWithFesteringWounds < 8 and not TargetsWithFesteringWounds >= NearbyEnemies ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike  ) then
            KTrig("Scourge Strike") return true end
    end
    
    -- Non-Sanlayn CDs
    local Cds = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end

        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() * 2 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 2 and WA_GetUnitBuff("pet", ids.DarkTransformationBuff) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end
        
        -- Kichi fix for continue outbreak in 2025.8.9
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.SuperstrainTalent) and ( IsAuraRefreshable(ids.FrostFeverDebuff) or IsAuraRefreshable(ids.BloodPlagueDebuff) ) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.PlaguebringerTalent)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) * 3 ) ) then
        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.SuperstrainTalent) and ( IsAuraRefreshable(ids.FrostFeverDebuff) or IsAuraRefreshable(ids.BloodPlagueDebuff) ) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.PlaguebringerTalent)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and true ) ) then
            KTrig("Outbreak") return true end
    end
    
    -- Non-Sanlayn CDs AoE
    local CdsAoe = function()
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end
        
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 ) ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or CurrentRunes < 3 or ( SetPieces >= 2 and not IsPlayerSpell(ids.VampiricStrikeTalent))) ) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end
        
        if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlagueDebuff) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
            KTrig("Outbreak") return true end
    end
    
    -- Sanlayn CDs AoE
    local CdsAoeSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 ) ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and PlayerHasBuff(ids.DarkTransformationBuff) and GetRemainingAuraDuration("player", ids.DarkTransformationBuff) < 12 ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end
                
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 or CurrentRunes < 3 ) ) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end

        -- Kichi 4.17 for NGA4.12 update and fix a bug (NGA's "(" position wrong) and remove RaiseAbomination check
        -- if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not TargetHasDebuff(ids.VirulentPlagueDebuff) and Variables.EpidemicTargets < NearbyEnemies or ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 ) and ( true ) ) ) then
        -- Kichi 4.17 remove GetRemainingSpellCooldown(big cd) check and optimize from simc
        -- if OffCooldown(ids.Outbreak) and ( true and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not TargetHasDebuff(ids.VirulentPlagueDebuff) and Variables.EpidemicTargets < NearbyEnemies or ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 5 ) ) ) then
        if OffCooldown(ids.Outbreak) and ( ( ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 or OldSetPieces >= 4 and IsPlayerSpell(ids.SuperstrainTalent) and floor(GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) / 1.5) < 5 and AbominationRemaining <= 0 ) ) 
and ( IsPlayerSpell(ids.UnholyBlightTalent) and not (not IsPlayerSpell(ids.Apocalypse) and OffCooldown(ids.DarkTransformation)) or not IsPlayerSpell(ids.UnholyBlightTalent) ) 
and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) 
and ( not TargetHasDebuff(ids.VirulentPlagueDebuff) and Variables.EpidemicTargets < NearbyEnemies or ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 5 ) ) 
or PlayerHasBuff(ids.VisceralStrengthUnholyBuff)  ) then
            KTrig("Outbreak") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and CurrentRunes <= 3 ) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end

    end
    
    -- Sanlayn CDs Cleave
    local CdsCleaveSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        if OffCooldown(ids.Apocalypse) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end
        
        if OffCooldown(ids.UnholyAssault) and ( WA_GetUnitBuff("pet", ids.DarkTransformationBuff) and GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) < 12 or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end

        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5 < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 ) and ( not IsPlayerSpell(ids.RaiseAbominationTalent) or IsPlayerSpell(ids.RaiseAbominationTalent) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 5 ) ) then
        -- Kichi 4.17 remove GetRemainingSpellCooldown(big cd) check and optimize from simc
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5 < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbominationTalent) or IsPlayerSpell(ids.RaiseAbominationTalent) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) or PlayerHasBuff(ids.VisceralStrengthUnholyBuff) ) then
            KTrig("Outbreak") return true end
        
    end

    -- Sanlayn CDs ST
    local CdsSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Apocalypse") return true end
            if aura_env.config[tostring(ids.Apocalypse)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Apocalypse")
            elseif aura_env.config[tostring(ids.Apocalypse)] ~= true then
                KTrig("Apocalypse")
                return true
            end
        end

        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( WA_GetUnitBuff("pet", ids.DarkTransformationBuff) and GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) < 12 ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end
        
        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) ) then
        -- Kichi 4.17 remove GetRemainingSpellCooldown(big cd) check and optimize from simc
        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) ) then
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) or PlayerHasBuff(ids.VisceralStrengthUnholyBuff) ) then
            KTrig("Outbreak") return true end

        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) and floor(GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) / 1.5) < 5 and IsPlayerSpell(ids.SuperstrainTalent) and (OldSetPieces >= 4) and IsAuraRefreshable(ids.FrostFeverDebuff) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbominationTalent) or IsPlayerSpell(ids.RaiseAbominationTalent) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) ) then
            KTrig("Outbreak") return true end
    end

        -- Shared CDs
    local CdsShared = function()
        if IsPlayerSpell(ids.LegionOfSouls) and GetRemainingSpellCooldown(ids.LegionOfSouls) == 0 and ( (Variables.StPlanning or Variables.AddsRemain) and (TargetsWithFesteringWounds < NearbyEnemies or ( IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.Apocalypse) < 3 or not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) < 3 ))) then
            -- KTrig("Legion Of Souls") return true end
            if aura_env.config[tostring(ids.LegionOfSouls)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Legion Of Souls")
            elseif aura_env.config[tostring(ids.LegionOfSouls)] ~= true then
                KTrig("Legion Of Souls")
                return true
            end
        end

        if FindSpellOverrideByID(ids.DeathAndDecay) == ids.Desecrate and ( NearbyEnemies >= 2 and ( not IsPlayerSpell(ids.FesteringScytheTalent) or GetPlayerStacks(ids.FesteringScytheStacksBuff) < NearbyEnemies and not PlayerHasBuff(ids.FesteringScytheBuff) ) and ( NearbyEnemies > 1 and TargetsWithFesteringWounds < NearbyEnemies or TargetsWithFesteringWounds >= NearbyEnemies or TargetsWithFesteringWounds == 0 and IsPlayerSpell(ids.FesteringScytheTalent) and not PlayerHasBuff(ids.FesteringScytheBuff) and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 ) ) then
            -- KTrig("Desecrate") return true end
            if aura_env.config[tostring(ids.Desecrate)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Desecrate")
            elseif aura_env.config[tostring(ids.Desecrate)] ~= true then
                KTrig("Desecrate")
                return true
            end
        end

    end
    
    -- Cleave
    local Cleave = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and Variables.AddsRemain or IsPlayerSpell(ids.GiftOfTheSanlaynTalent) ) then
            -- KTrig("Death And Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death And Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death And Decay")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and IsPlayerSpell(ids.ImprovedDeathCoilTalent) ) then
            KTrig("Death Coil") return true end

        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and not IsPlayerSpell(ids.ImprovedDeathCoilTalent) ) then
            KTrig("Death Coil") return true end
    
        -- Kichi 4.16 add for split Scourge Strike and Festering Strike
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff) ) then
            -- KTrig("Festering Scythe") return true end
            if aura_env.config[tostring(ids.FesteringScythe)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Festering Scythe")
            elseif aura_env.config[tostring(ids.FesteringScythe)] ~= true then
                KTrig("Festering Scythe")
                return true
            end
        end

        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) < 2 or PlayerHasBuff(ids.FesteringScytheBuff) ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.FesteringStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming and GetTargetStacks(ids.FesteringWoundDebuff) < 1 ) then
            KTrig("Festering Strike") return true end
        
        -- Kichi for Scourge Scy modify --
        if not PlayerHasBuff(ids.FesteringScytheBuff) and OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            KTrig("Scourge Strike") return true end
        
    end
    
    -- San'layn Fishing
    local SanFishing = function()
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.InflictionOfSorrowBuff) ) then
            KTrig("Scourge Strike") return true end

        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            -- KTrig("Death And Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death And Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death And Decay")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoomBuff) and IsPlayerSpell(ids.DoomedBiddingTalent) or OldSetPieces >= 4 and GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( GetTargetStacks(ids.FesteringWoundDebuff) >= 3 - (AbominationRemaining > 0 and 1 or 0) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 3 - (AbominationRemaining > 0 and 1 or 0) ) then
            KTrig("Festering Strike") return true end
    end
    
    -- San'layn Single Target
    local SanSt = function()
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.InflictionOfSorrowBuff) ) then
            KTrig("Scourge Strike") return true end

        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff) ) then
            -- KTrig("Festering Scythe") return true end
            if aura_env.config[tostring(ids.FesteringScythe)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Festering Scythe")
            elseif aura_env.config[tostring(ids.FesteringScythe)] ~= true then
                KTrig("Festering Scythe")
                return true
            end
        end

        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoomBuff) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlaynBuff) and ( IsPlayerSpell(ids.DoomedBiddingTalent) or IsPlayerSpell(ids.RottenTouchTalent) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruptionBuff) or OldSetPieces >= 4 and CurrentRunicPower > 80 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and OldSetPieces >= 4 and GetPlayerStacks(ids.WinningStreakBuff) == 10 and CurrentRunes <= 3 and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueenBuff) > 3 ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and PlayerHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("player", ids.DarkTransformation) < WeakAuras.gcdDuration() ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( ( GetTargetStacks(ids.FesteringWoundDebuff) == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming ) or not PlayerHasBuff(ids.DarkTransformationBuff) and not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) < 10 and GetTargetStacks(ids.FesteringWoundDebuff) <= 3 and ( CurrentRunes > 4 or CurrentRunicPower < 80 ) or ( IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or not IsPlayerSpell(ids.GiftOfTheSanlaynTalent) ) and GetTargetStacks(ids.FesteringWoundDebuff) <= 1 ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( not IsPlayerSpell(ids.ApocalypseTalent) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and ( not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 and GetTargetStacks(ids.FesteringWoundDebuff) >= 3 - (AbominationRemaining > 0 and 1 or 0) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or ( PlayerHasBuff(ids.SuddenDoomBuff) and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or CurrentRunes < 2 ) ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) > 4 ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            KTrig("Death Coil") return true end

        if OffCooldown(ids.FesteringStrike) and ( ( not IsPlayerSpell(ids.ApocalypseTalent) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and CurrentRunes >= 4 ) then
            KTrig("Festering Strike") return true end

    end
    
    -- Non-San'layn Single Target
    local St = function()
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and (TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff)) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and Variables.SpendRp or FightRemains(60, NearbyRange) < 10 ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 4 and (not Variables.PopWounds or PlayerHasBuff(ids.FesteringScytheBuff))) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) >= 4 ) then
            KTrig("Scourge Strike") return true end
    end

    if CdsShared() then return true end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 3 then
        -- print("1")
        if CdsAoeSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        -- print("2")
        if CdsAoe() then return true end end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 2 then
        -- print("3")
        if CdsCleaveSan() then return true end end

    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies <= 1 then
        -- print("4")
        if CdsSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies <= 1 then
        -- print("5")
        if Cds() then return true end end
    
    if NearbyEnemies == 2 then
        -- print("6")
        if Cleave() then return true end end
    
    if NearbyEnemies >= 3 and GetRemainingSpellCooldown(ids.DeathAndDecay) < 7 and not PlayerHasBuff(ids.LegionOfSoulsBuff) and ( GetRemainingAuraDuration("player", ids.DeathAndDecayBuff) < 3 or TargetsWithFesteringWounds < (NearbyEnemies/2) ) then
        -- print("7")
        if AoeSetup() then return true end end
    
    if NearbyEnemies >= 3 and ( PlayerHasBuff(ids.DeathAndDecayBuff) or PlayerHasBuff(ids.DeathAndDecayBuff) and (TargetsWithFesteringWounds >= ( NearbyEnemies * 0.5 ) or IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies < 16 or IsPlayerSpell(ids.DesecrateTalent) and TargetsWithFesteringWounds >= NearbyEnemies and IsPlayerSpell(ids.BurstingSoresTalent)) ) then
        -- print("8")
        if AoeBurst() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) then
        -- print("9")
        if Aoe() then return true end end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and not OffCooldown(ids.DarkTransformation) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and not IsPlayerSpell(ids.Apocalypse) and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueenBuff) < GetRemainingSpellCooldown(ids.DarkTransformation) + 3 then
        -- print("10")
        SanFishing() return true end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.VampiricStrikeTalent) then
        if SanSt() then return true end end
    
    if NearbyEnemies <= 1 and not IsPlayerSpell(ids.VampiricStrikeTalent) then
        if St() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    KTrigCD("Clear")
    
end
