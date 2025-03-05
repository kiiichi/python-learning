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
    local PetHasBuff = aura_env.PetHasBuff
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1867)
    
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
            if WA_GetUnitDebuff(unit, ids.FesteringWound, "PLAYER||HARMFUL") ~= nil then
                TargetsWithFesteringWounds = TargetsWithFesteringWounds + 1
            end
        end
    end
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)
    WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Kichi --
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
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    if NearbyEnemies == 1 then
    Variables.StPlanning = true else Variables.StPlanning = false end
    
    if NearbyEnemies >= 2 then
    Variables.AddsRemain = true else Variables.AddsRemain = false end
    
    if GetRemainingSpellCooldown(ids.Apocalypse) < 5 and GetTargetStacks(ids.FesteringWound) < 1 and GetRemainingSpellCooldown(ids.UnholyAssault) > 5 then
    Variables.ApocTiming = 3 else Variables.ApocTiming = 0 end
    
    if IsPlayerSpell(ids.VileContagion) and GetRemainingSpellCooldown(ids.VileContagion) < 3 and CurrentRunicPower < 30 then
    Variables.PoolingRunicPower = true else Variables.PoolingRunicPower = false end
    
    if ( GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming or not IsPlayerSpell(ids.Apocalypse) ) and ( GetTargetStacks(ids.FesteringWound) >= 1 and GetRemainingSpellCooldown(ids.UnholyAssault) < 20 and IsPlayerSpell(ids.UnholyAssault) and Variables.StPlanning or TargetHasDebuff(ids.RottenTouchDebuff) and GetTargetStacks(ids.FesteringWound) >= 1 or GetTargetStacks(ids.FesteringWound) >= 4 - (AbominationRemaining > 0 and 1 or 0) ) or FightRemains(10, NearbyRange) < 5 and GetTargetStacks(ids.FesteringWound) >= 1 then
    Variables.PopWounds = true else Variables.PopWounds = false end
    
    if ( not IsPlayerSpell(ids.RottenTouch) or IsPlayerSpell(ids.RottenTouch) and not TargetHasDebuff(ids.RottenTouchDebuff) or MaxRunicPower - CurrentRunicPower < 20 ) and ( ( IsPlayerSpell(ids.ImprovedDeathCoil) and ( NearbyEnemies == 2 or IsPlayerSpell(ids.CoilOfDevastation) ) or CurrentRunes < 3 or GargoyleRemaining or PlayerHasBuff(ids.SuddenDoom) or not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) >= 4 ) ) then
    Variables.SpendRp = true else Variables.SpendRp = false end
    
    Variables.EpidemicTargets = 3 + (IsPlayerSpell(ids.ImprovedDeathCoil) and 1 or 0) + ( (IsPlayerSpell(ids.FrenziedBloodthirstTalent) and GetPlayerStacks(ids.EssenceOfTheBloodQueen) > 5) and 1 or 0 ) + ( (IsPlayerSpell(ids.HungeringThirstTalent) and IsPlayerSpell(ids.HarbingerOfDoomTalent) and PlayerHasBuff(ids.SuddenDoom)) and 1 or 0 )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.ArmyOfTheDead) and not IsPlayerSpell(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( IsPlayerSpell(ids.CommanderOfTheDead) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 or not IsPlayerSpell(ids.CommanderOfTheDead) and NearbyEnemies >= 1 ) or FightRemains(30, NearbyRange) < 35 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) or FightRemains(25, NearbyRange) < 30 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.SummonGargoyle) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( PlayerHasBuff(ids.CommanderOfTheDeadBuff) or not IsPlayerSpell(ids.CommanderOfTheDead) and NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 25 ) then
        ExtraGlows.SummonGargoyle = true
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AOE
    local Aoe = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 and PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.BurstingSores) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            KTrig("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming or PlayerHasBuff(ids.FesteringScythe) ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 2 ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 and GetRemainingSpellCooldown(ids.Apocalypse) > WeakAuras.gcdDuration() or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and TargetHasDebuff(ids.VirulentPlague) ) then
            KTrig("Scourge Strike") return true end
    end
    
    -- AoE Burst
    local AoeBurst = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and NearbyEnemies < Variables.EpidemicTargets and ( not IsPlayerSpell(ids.BurstingSores) or IsPlayerSpell(ids.BurstingSores) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoom) or PlayerHasBuff(ids.SuddenDoom) and ( IsPlayerSpell(ids.DoomedBidding) and IsPlayerSpell(ids.MenacingMagusTalent) or IsPlayerSpell(ids.RottenTouch) or GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() ) ) ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and ( not IsPlayerSpell(ids.BurstingSores) or IsPlayerSpell(ids.BurstingSores) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoom) or PlayerHasBuff(ids.SuddenDoom) and ( PlayerHasBuff(ids.AFeastOfSouls) or GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRot) < 10 ) ) ) then
            KTrig("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) then
            KTrig("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) <= 2 ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) then
            KTrig("Scourge Strike") return true end
    end
    
    -- AoE Setup
    local AoeSetup = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( not IsPlayerSpell(ids.BurstingSores) and not IsPlayerSpell(ids.VileContagion) or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds >= 8 or not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.Defile) ) ) then
            -- KTrig("Death and Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death and Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death and Decay")
                return true
            end
        end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( not IsPlayerSpell(ids.VileContagion) ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.VileContagion) < 5 or TargetsWithFesteringWounds == NearbyEnemies and GetTargetStacks(ids.FesteringWound) <= 4 ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoom) and NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoom) ) then
            KTrig("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() and GetTargetStacks(ids.FesteringWound) == 0 or TargetsWithFesteringWounds < NearbyEnemies ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            KTrig("Epidemic") return true end
    end
    
    -- Non-San'layn Cooldowns
    local Cds = function()
        if OffCooldown(ids.DarkTransformation) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < 8 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end

        --if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() * 2 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 2 and PlayerHasBuff(ids.DarkTransformation) ) or FightRemains(60, NearbyRange) < 20 ) then
        -- Kichi 3.3 for replace PlayerHasBuff to PetHasBuff
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() * 2 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 2 and PetHasBuff(ids.DarkTransformation) ) or FightRemains(60, NearbyRange) < 20 ) then
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
        
        -- kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Superstrain) and ( IsAuraRefreshable(ids.FrostFever) or IsAuraRefreshable(ids.BloodPlague) ) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.Plaguebringer)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) * 3 ) ) then
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Superstrain) and ( IsAuraRefreshable(ids.FrostFever) or IsAuraRefreshable(ids.BloodPlague) ) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.Plaguebringer)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and true ) ) then
            KTrig("Outbreak") return true end
        
        -- Kichi 3.3 for remove Abomination Limb
        -- if OffCooldown(ids.AbominationLimb) and ( Variables.StPlanning and not PlayerHasBuff(ids.SuddenDoom) and ( PlayerHasBuff(ids.Festermight) and GetPlayerStacks(ids.Festermight) > 8 or not IsPlayerSpell(ids.Festermight) ) and ( ApocalypseRemaining < 5 or not IsPlayerSpell(ids.Apocalypse) ) and GetTargetStacks(ids.FesteringWound) <= 2 or FightRemains(60, NearbyRange) < 12 ) then
        --     -- KTrig("Abomination Limb") return true end
        --     if aura_env.config[tostring(ids.AbominationLimb)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Abomination Limb")
        --     elseif aura_env.config[tostring(ids.AbominationLimb)] ~= true then
        --         KTrig("Abomination Limb")
        --         return true
        --     end
        -- end
        
    end
    
    -- Non-San'layn AoE Cooldowns
    local CdsAoe = function()
        if OffCooldown(ids.VileContagion) and ( GetTargetStacks(ids.FesteringWound) >= 4 and ( GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or PlayerHasBuff(ids.DeathAndDecayBuff) and GetTargetStacks(ids.FesteringWound) >= 4 ) or Variables.AddsRemain and GetTargetStacks(ids.FesteringWound) == 6 ) then
            -- KTrig("Vile Contagion") return true end
            if aura_env.config[tostring(ids.VileContagion)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vile Contagion")
            elseif aura_env.config[tostring(ids.VileContagion)] ~= true then
                KTrig("Vile Contagion")
                return true
            end
        end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and ( GetTargetStacks(ids.FesteringWound) >= 2 and GetRemainingSpellCooldown(ids.VileContagion) < 3 or not IsPlayerSpell(ids.VileContagion) ) ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end
        
        if OffCooldown(ids.DarkTransformation) and ( Variables.AddsRemain and ( GetRemainingSpellCooldown(ids.VileContagion) > 5 or not IsPlayerSpell(ids.VileContagion) or PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 ) ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        -- kiichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
        if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and true ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and true ) ) then
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
        
        -- Kichi 3.3 for remove Abomination Limb
        -- if OffCooldown(ids.AbominationLimb) and ( Variables.AddsRemain ) then
        --     -- KTrig("Abomination Limb") return true end
        --     if aura_env.config[tostring(ids.AbominationLimb)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Abomination Limb")
        --     elseif aura_env.config[tostring(ids.AbominationLimb)] ~= true then
        --         KTrig("Abomination Limb")
        --         return true
        --     end
        -- end
        
    end
    
    -- San'layn AoE Cooldowns
    local CdsAoeSan = function()
        -- Kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.DarkTransformation) and ( Variables.AddsRemain and PlayerHasBuff(ids.DeathAndDecayBuff) ) then
        if OffCooldown(ids.DarkTransformation) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 ) ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        if OffCooldown(ids.VileContagion) and ( GetTargetStacks(ids.FesteringWound) >= 4  and ( GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or PlayerHasBuff(ids.DeathAndDecayBuff) and GetTargetStacks(ids.FesteringWound) >= 4 ) or Variables.AddsRemain and GetTargetStacks(ids.FesteringWound) == 6 ) then
            -- KTrig("Vile Contagion") return true end
            if aura_env.config[tostring(ids.VileContagion)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vile Contagion")
            elseif aura_env.config[tostring(ids.VileContagion)] ~= true then
                KTrig("Vile Contagion")
                return true
            end
        end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and ( GetTargetStacks(ids.FesteringWound) >= 2 and GetRemainingSpellCooldown(ids.VileContagion) < 6 or not IsPlayerSpell(ids.VileContagion) ) ) then
            -- KTrig("Unholy Assault") return true end
            if aura_env.config[tostring(ids.UnholyAssault)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Unholy Assault")
            elseif aura_env.config[tostring(ids.UnholyAssault)] ~= true then
                KTrig("Unholy Assault")
                return true
            end
        end

        -- kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.Outbreak) and ( ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
        if OffCooldown(ids.Outbreak) and ( ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and true ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and true ) ) then
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
        
        -- Kichi 3.3 for remove Abomination Limb
        -- if OffCooldown(ids.AbominationLimb) and ( Variables.AddsRemain ) then
        --     -- KTrig("Abomination Limb") return true end
        --     if aura_env.config[tostring(ids.AbominationLimb)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Abomination Limb")
        --     elseif aura_env.config[tostring(ids.AbominationLimb)] ~= true then
        --         KTrig("Abomination Limb")
        --         return true
        --     end
        -- end

    end
    
    -- San'layn Cooldowns
    local CdsSan = function()
        if OffCooldown(ids.DarkTransformation) and ( NearbyEnemies >= 1 and Variables.StPlanning and ( IsPlayerSpell(ids.Apocalypse) and (ApocalypseRemaining > 0) or not IsPlayerSpell(ids.Apocalypse) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Dark Transformation") return true end
            if aura_env.config[tostring(ids.DarkTransformation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Transformation")
            elseif aura_env.config[tostring(ids.DarkTransformation)] ~= true then
                KTrig("Dark Transformation")
                return true
            end
        end
        
        -- if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( PlayerHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("player", ids.DarkTransformation) < 12 ) or FightRemains(60, NearbyRange) < 20 ) then
        -- Kichi 3.3 for replace PlayerHasBuff to PetHasBuff, GetRemainingAuraDuration("player", ids.DarkTransformation) to GetRemainingAuraDuration("pet", ids.DarkTransformation)
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( PetHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("pet", ids.DarkTransformation) < 12 ) or FightRemains(60, NearbyRange) < 20 ) then
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
        
        -- kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and PlayerHasBuff(ids.InflictionOfSorrow) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and PlayerHasBuff(ids.InflictionOfSorrow) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and true ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and true ) ) then
            KTrig("Outbreak") return true end
        
        -- Kichi 3.3 for remove Abomination Limb
        -- if OffCooldown(ids.AbominationLimb) and ( NearbyEnemies >= 1 and Variables.StPlanning and not PlayerHasBuff(ids.GiftOfTheSanlayn) and not PlayerHasBuff(ids.SuddenDoom) and PlayerHasBuff(ids.Festermight) and GetTargetStacks(ids.FesteringWound) <= 2 or not PlayerHasBuff(ids.GiftOfTheSanlayn) and FightRemains(60, NearbyRange) < 12 ) then
        --     -- KTrig("Abomination Limb") return true end
        --     if aura_env.config[tostring(ids.AbominationLimb)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Abomination Limb")
        --     elseif aura_env.config[tostring(ids.AbominationLimb)] ~= true then
        --         KTrig("Abomination Limb")
        --         return true
        --     end
        -- end

    end
    
    -- Cleave
    local Cleave = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) ) then
            -- KTrig("Death and Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death and Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death and Decay")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) < 4 or PlayerHasBuff(ids.FesteringScythe) ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming and GetTargetStacks(ids.FesteringWound) < 4 ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            KTrig("Scourge Strike") return true end
        
    end
    
    -- San'layn Fishing
    local SanFishing = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            -- KTrig("Death and Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death and Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death and Decay")
                return true
            end
        end
        
        -- if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and IsPlayerSpell(ids.DoomedBidding) ) then
        -- Kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.DeathCoil) and (( PlayerHasBuff(ids.SuddenDoom) and IsPlayerSpell(ids.DoomedBidding) ) or (aura_env.config["HaveTWW2Set4PC"] and GetPlayerStacks(ids.EssenceOfTheBloodQueen) > 6 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike)) then
        -- Kichi 3.3 for NGA v2.1.0-25
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and IsPlayerSpell(ids.DoomedBidding) or SetPieces >= 4 and GetPlayerStacks(ids.EssenceOfTheBloodQueen) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( GetTargetStacks(ids.FesteringWound) >= 3 - (AbominationRemaining > 0 and 1 or 0) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 3 - (AbominationRemaining > 0 and 1 or 0) ) then
            KTrig("Festering Strike") return true end
    end
    
    -- Single Target San'layn
    local SanSt = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.UnholyGround) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 ) then
            -- KTrig("Death and Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death and Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death and Decay")
                return true
            end
        end
        

        -- if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlayn) and ( IsPlayerSpell(ids.DoomedBidding) or IsPlayerSpell(ids.RottenTouch) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruption) ) then
        -- Kichi 2.18 for SimC e854775 2.13 TWW2_Death_Knight_Unholy.simc update--
        -- if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlayn) and ( IsPlayerSpell(ids.DoomedBidding) or IsPlayerSpell(ids.RottenTouch) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruption) or aura_env.config["HaveTWW2Set4PC"] and CurrentRunicPower > 80 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetPlayerStacks(ids.EssenceOfTheBloodQueen) > 6 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and aura_env.config["HaveTWW2Set4PC"] and GetPlayerStacks(ids.WinningStreak) > 9 and CurrentRunes < 3 and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueen) > 3 ) then
        -- Kichi 3.3 for NGA v2.1.0-25
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlayn) and ( IsPlayerSpell(ids.DoomedBidding) or IsPlayerSpell(ids.RottenTouch) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruption) or SetPieces >= 4 and CurrentRunicPower > 80 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetPlayerStacks(ids.EssenceOfTheBloodQueen) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and SetPieces >= 4 and GetPlayerStacks(ids.WinningStreakBuff) == 10 and CurrentRunes <= 3 and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueen) > 3 ) then
            KTrig("Death Coil") return true end
        
        -- if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike or IsPlayerSpell(ids.GiftOfTheSanlayn) and PlayerHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("player", ids.DarkTransformation) < WeakAuras.gcdDuration() ) then
        -- Kichi 3.3 for replace PlayerHasBuff to PetHasBuff, GetRemainingAuraDuration("player", ids.DarkTransformation) to GetRemainingAuraDuration("pet", ids.DarkTransformation)
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike or IsPlayerSpell(ids.GiftOfTheSanlayn) and PetHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("pet", ids.DarkTransformation) < WeakAuras.gcdDuration() ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and GetTargetStacks(ids.FesteringWound) >= 1 ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( ( GetTargetStacks(ids.FesteringWound) == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming ) or ( IsPlayerSpell(ids.GiftOfTheSanlayn) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or not IsPlayerSpell(ids.GiftOfTheSanlayn) ) and ( PlayerHasBuff(ids.FesteringScythe) or GetTargetStacks(ids.FesteringWound) <= 1 ) ) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( not IsPlayerSpell(ids.Apocalypse) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and ( GetTargetStacks(ids.FesteringWound) >= 3 - (AbominationRemaining > 0 and 1 or 0) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() or ( PlayerHasBuff(ids.SuddenDoom) and GetTargetStacks(ids.FesteringWound) >= 1 or CurrentRunes < 2 ) ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) > 4 ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            KTrig("Death Coil") return true end
    end
    
    -- Single Taget Non-San'layn
    local St = function()
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            KTrig("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and (TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow)) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( IsPlayerSpell(ids.UnholyGround) and not PlayerHasBuff(ids.DeathAndDecayBuff) and ( ApocalypseRemaining > 0 or AbominationRemaining > 0 or GargoyleRemaining > 0 ) ) then
            -- KTrig("Death and Decay") return true end
            if aura_env.config[tostring(ids.DeathAndDecay)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Death and Decay")
            elseif aura_env.config[tostring(ids.DeathAndDecay)] ~= true then
                KTrig("Death and Decay")
                return true
            end
        end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and Variables.SpendRp or FightRemains(60, NearbyRange) < 10 ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 4 and (not Variables.PopWounds or PlayerHasBuff(ids.FesteringScythe))) then
            KTrig("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            KTrig("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            KTrig("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) >= 4 ) then
            KTrig("Scourge Strike") return true end
    end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        -- print("1")
        if CdsAoeSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        -- print("2")
        if CdsAoe() then return true end end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 1 then
        -- print("3")
        if CdsSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 1 then
        -- print("4")
        if Cds() then return true end end
    
    if NearbyEnemies == 2 then
        if Cleave() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) and GetRemainingSpellCooldown(ids.DeathAndDecay) < 10 then
        if AoeSetup() then return true end end
    
    if NearbyEnemies >= 3 and ( PlayerHasBuff(ids.DeathAndDecayBuff) or PlayerHasBuff(ids.DeathAndDecay) and TargetsWithFesteringWounds >= ( NearbyEnemies * 0.5 ) ) then
        if AoeBurst() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) then
        if Aoe() then return true end end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.GiftOfTheSanlayn) and not OffCooldown(ids.DarkTransformation) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueen) < GetRemainingSpellCooldown(ids.DarkTransformation) + 3 then
        SanFishing() return true end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.VampiricStrikeTalent) then
        if SanSt() then return true end end
    
    if NearbyEnemies <= 1 and not IsPlayerSpell(ids.VampiricStrikeTalent) then
        if St() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    KTrigCD("Clear")
    
end
