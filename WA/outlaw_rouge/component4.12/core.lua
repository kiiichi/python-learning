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
    local FullGCD = aura_env.FullGCD
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------  
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1687)
    
    local CurrentComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    
    local EffectiveComboPoints = CurrentComboPoints
    
    local Envenom1Remains = ((aura_env.Envenom1 < CurrentTime) and 0 or (aura_env.Envenom1 - CurrentTime))
    
    local IsStealthed = PlayerHasBuff(ids.SubterfugeBuff) or PlayerHasBuff(ids.StealthBuff)
    local HasImprovedGarroteBuff = PlayerHasBuff(392403) or PlayerHasBuff(392401)
    
    local EnergyRegen = GetPowerRegen()
    local DotTickRate = 2 / (1+0.01*UnitSpellHaste("player"))
    local LethalPoisons = 0
    local PoisonedBleeds = 0
    local BleedIds = {
        703, -- Garrote
        1943, -- Rupture
        360826, -- Deathmark Garrote
        360830, -- Deathmark Rupture
    }
    local PoisonIds = {
        8680, -- Wound Poison
        2818, -- Deadly Poison
        383414, -- Amplifying Poison
    }
    local IsLethalPoisoned = function(unit)
        for _, Id in ipairs(PoisonIds) do
            if WA_GetUnitDebuff(unit, Id, "PLAYER") then
                return true
            end
        end
        return false
    end
    
    local NearbyRange = 10 -- Fan of Knives range is 10 yards
    local NearbyEnemies = 0
    local NearbyGarroted = 0
    local NearbyRuptured = 0
    -- Kichi --
    local NearbyShortGarroted = 0
    local NearbyUnenhancedGarroted = 0
    local NearbyRefreshableGarroted = 0
    local NearbyRefreshableRuptured = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.Garrote, "PLAYER") then
                NearbyGarroted = NearbyGarroted + 1
            end
            
            if WA_GetUnitDebuff(unit, ids.Rupture, "PLAYER") then
                NearbyRuptured = NearbyRuptured + 1
            end

            -- Kichi --
            if GetRemainingDebuffDuration(unit, ids.Garrote) < 12 then 
                NearbyShortGarroted = NearbyShortGarroted + 1
            end
            if aura_env.GarroteSnapshots[UnitGUID(unit)] == nil then 
                aura_env.GarroteSnapshots[UnitGUID(unit)] = 0
            end
            if aura_env.GarroteSnapshots[UnitGUID(unit)] <= 1 then
                NearbyUnenhancedGarroted = NearbyUnenhancedGarroted + 1
            end

            if IsAuraRefreshable(ids.Garrote, unit, "HARMFUL|PLAYER") and aura_env.GarroteSnapshots[UnitGUID(unit)] <= 1 then
                NearbyRefreshableGarroted = NearbyRefreshableGarroted + 1
            end
            if IsAuraRefreshable(ids.Rupture, unit, "HARMFUL|PLAYER") then
                NearbyRefreshableRuptured = NearbyRefreshableRuptured + 1
            end

            -- Energy Regen
            if IsLethalPoisoned(unit) then
                LethalPoisons = LethalPoisons + 1
                
                for _, Id in ipairs(BleedIds) do
                    if WA_GetUnitDebuff(unit, Id, "PLAYER") then
                        PoisonedBleeds = PoisonedBleeds + 1
                    end
                end
            end
        end
    end
    
    -- print("------------------")
    -- print("NearbyEnemies: " .. NearbyEnemies)
    -- print("NearbyGarroted: " .. NearbyGarroted)
    -- print("NearbyRuptured: " .. NearbyRuptured)
    -- print("NearbyShortGarroted: " .. NearbyShortGarroted)
    -- print("NearbyUnenhancedGarroted: " .. NearbyUnenhancedGarroted)
    -- print("NearbyRefreshableGarroted: " .. NearbyRefreshableGarroted)
    -- print("NearbyRefreshableRuptured: " .. NearbyRefreshableRuptured)

    if not (NearbyGarroted < NearbyEnemies) then
        WeakAuras.ScanEvents("K_NEARBY_GARROTED_SAT")
    end
    if not (NearbyRuptured < NearbyEnemies) then
        WeakAuras.ScanEvents("K_NEARBY_RUPTURED_SAT")
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    -- WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)

    -- Venomous Wounds
    EnergyRegen = EnergyRegen + (PoisonedBleeds * 7) / DotTickRate

    -- Dashing Scoundrel -- Estimate ~90% Envenom uptime for energy regen approximation
    if IsPlayerSpell(ids.DashingScoundrelTalent) then
        EnergyRegen = EnergyRegen + ((0.9 * LethalPoisons * (GetCritChance() / 100)) / DotTickRate)
    end

    -- WeakAuras.ScanEvents("NG_GARROTE_DATA", NearbyGarroted, NearbyEnemies)
    -- WeakAuras.ScanEvents("NG_RUPTURE_DATA", NearbyRuptured, NearbyEnemies)
    -- Kichi --
    WeakAuras.ScanEvents("K_GARROTE_DATA", NearbyGarroted, NearbyEnemies)
    WeakAuras.ScanEvents("K_RUPTURE_DATA", NearbyRuptured, NearbyEnemies)

    -- print("NearbyEnemies: " .. NearbyEnemies)
    -- print("NearbyGarroted: " .. NearbyGarroted)
    -- print("NearbyRuptured: " .. NearbyRuptured)
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    
    -- Determine combo point finish condition
    Variables.EffectiveSpendCp = max(MaxComboPoints - 2, 5 * (IsPlayerSpell(ids.HandOfFateTalent) and 1 or 0))
    
    -- Conditional to check if there is only one enemy
    Variables.SingleTarget = NearbyEnemies < 2
    
    -- Combined Energy Regen needed to saturate
    Variables.RegenSaturated = EnergyRegen > 30
    
    -- Pooling Setup, check for cooldowns
    Variables.InCooldowns = TargetHasDebuff(ids.Deathmark) or TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.ShivDebuff)
    
    -- Check upper bounds of energy to begin spending
    Variables.UpperLimitEnergy = (CurrentEnergy/MaxEnergy*100) >= ( 50 - 10 * (IsPlayerSpell(ids.ViciousVenomsTalent) and 2 or 0) )
    
    -- Checking for cooldowns soon
    Variables.CdSoon = GetRemainingSpellCooldown(ids.Kingsbane) < 3 and not OffCooldown(ids.Kingsbane)
    
    -- Pooling Condition all together
    Variables.NotPooling = Variables.InCooldowns or not Variables.CdSoon and PlayerHasBuff(ids.DarkestNightBuff) or Variables.UpperLimitEnergy or FightRemains(60, NearbyRange) <= 20
    
    -- Check what the maximum Scent of Blood stacks is currently
    -- Kichi --
    Variables.ScentEffectiveMaxStacks = min(( NearbyEnemies * (IsPlayerSpell(ids.ScentOfBloodTalent) and 2 or 0) )*2, 20)
    
    -- We are Scent Saturated when our stack count is hitting the maximum
    Variables.ScentSaturation = GetPlayerStacks(ids.ScentOfBloodBuff) >= Variables.ScentEffectiveMaxStacks
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    -- Kichi --
    local ExtraGlows = {}

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    -- Use with shiv or in niche cases at the end of Kingsbane if not already up
    -- if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTeaBuff) and GetRemainingDebuffDuration("target", ids.ShivDebuff) >= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) <= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) then
    -- Kichi --
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTeaBuff) and GetRemainingDebuffDuration("target", ids.ShivDebuff) >= 6 and not TargetHasDebuff(ids.KingsbaneDebuff) or not PlayerHasBuff(ids.ThistleTeaBuff) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) <= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) then
        ExtraGlows.ThistleTea = true 
    end
    
    -- Cold Blood with similar conditions to Envenom,
    if OffCooldown(ids.ColdBlood) and ( GetRemainingSpellCooldown(ids.Deathmark) > 10 and not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) and not PlayerHasBuff(ids.VanishBuff) and ( not OffCooldown(ids.Kingsbane) or not (NearbyEnemies < 2) ) and not OffCooldown(ids.Deathmark) ) then
    ExtraGlows.ColdBlood = true end
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)

    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Damage over time abilities
    local AoeDot = function()
        -- Crimson Tempest on 2+ Targets
        if OffCooldown(ids.CrimsonTempest) and ( NearbyEnemies >= 2 and IsAuraRefreshable(ids.CrimsonTempest) and EffectiveComboPoints >= Variables.EffectiveSpendCp and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.CrimsonTempest) > 6 ) then
            KTrig("Crimson Tempest") return true end
        
        -- Kichi --
        if OffCooldown(ids.Garrote) and aura_env.config["PerformanceMode"] == true and ( MaxComboPoints - EffectiveComboPoints >= 1 and NearbyRefreshableGarroted > 0 and not Variables.RegenSaturated ) then
            KTrig("Garrote", "TAB") return true end

        -- Garrote upkeep in AoE to reach energy saturation
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and not Variables.RegenSaturated and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 ) then
            KTrig("Garrote") return true end
        
        -- Kichi --
        if OffCooldown(ids.Rupture) and aura_env.config["PerformanceMode"] == true and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and NearbyRefreshableRuptured > 0 and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and ( not Variables.RegenSaturated and ( IsPlayerSpell(ids.ScentOfBloodTalent) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) or true ) ) ) and true and not PlayerHasBuff(ids.DarkestNightBuff) ) then
            KTrig("Rupture", "TAB") return true end
        
        -- Rupture upkeep in AoE to reach energy or scent of blood saturation
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and ( not Variables.RegenSaturated and ( IsPlayerSpell(ids.ScentOfBloodTalent) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) or TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > 15 ) ) ) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > ( 7 + ( (IsPlayerSpell(ids.DashingScoundrelTalent) and 1 or 0) * 5 ) + ( (Variables.RegenSaturated and 1 or 0) * 6 ) ) and not PlayerHasBuff(ids.DarkestNightBuff) ) then
            KTrig("Rupture") return true end
        
        -- Kichi --
        if OffCooldown(ids.Rupture) and aura_env.config["PerformanceMode"] == true and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and NearbyRefreshableRuptured > 0 and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and Variables.RegenSaturated and not Variables.ScentSaturation and true and not PlayerHasBuff(ids.DarkestNightBuff)) then
            KTrig("Rupture", "TAB") return true end

        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and Variables.RegenSaturated and not Variables.ScentSaturation and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > 19) and not PlayerHasBuff(ids.DarkestNightBuff)) then
            KTrig("Rupture") return true end
        
        -- Garrote as a special generator for the last CP before a finisher for edge case handling
        if OffCooldown(ids.Garrote) and ( IsAuraRefreshable(ids.Garrote) and MaxComboPoints - EffectiveComboPoints >= 1 and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or GetRemainingDebuffDuration("target", ids.Garrote) <= 2 and NearbyEnemies >= 3 ) and ( GetRemainingDebuffDuration("target", ids.Garrote) <= 2 * 2 and NearbyEnemies >= 3 ) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) ) > 4 and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 ) then
            KTrig("Garrote") return true end
    end
    
    -- Core damage over time abilities used everywhere 
    local CoreDot = function()
        -- Maintain Garrote
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 ) then
            KTrig("Garrote") return true end
        
        -- Maintain Rupture unless darkest night is up
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > ( 4 + ( (IsPlayerSpell(ids.DashingScoundrelTalent) and 1 or 0) * 5 ) + ( (Variables.RegenSaturated and 1 or 0) * 6 ) ) and (not PlayerHasBuff(ids.DarkestNightBuff) or IsPlayerSpell(ids.CausticSpatterTalent) and not TargetHasDebuff(ids.CausticSpatterDebuff)) ) then
            KTrig("Rupture") return true end

        -- Maintain Crimson Tempest
        if OffCooldown(ids.CrimsonTempest) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.CrimsonTempestDebuff) and ( not PlayerHasBuff(ids.DarkestNightBuff) ) and not IsPlayerSpell(ids.AmplifyingPoisonTalent) ) then
            KTrig("Crimson Tempest") return true end
    end
    
    -- Direct Damage Abilities Envenom at applicable cp if not pooling, capped on amplifying poison stacks, on an animacharged CP, or in aoe.
    local Direct = function()
        if OffCooldown(ids.Envenom) and ( not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) and not PlayerHasBuff(ids.VanishBuff) ) then
            KTrig("Envenom") return true end
        
        -- Special Envenom handling for Darkest Night
        if OffCooldown(ids.Envenom) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= MaxComboPoints ) then
            KTrig("Envenom") return true end
        
        -- Check if we should be using a filler
        Variables.UseFiller = CurrentComboPoints <= Variables.EffectiveSpendCp and not Variables.CdSoon or Variables.NotPooling or not (NearbyEnemies < 2)
        
        Variables.FokTargetCount = ( PlayerHasBuff(ids.ClearTheWitnessesBuff) and ( NearbyEnemies >= 2 - (( PlayerHasBuff(ids.LingeringDarknessBuff) or not IsPlayerSpell(ids.ViciousVenomsTalent) ) and 1 or 0) ) ) or ( NearbyEnemies >= 3 - (( IsPlayerSpell(ids.MomentumOfDespairTalent) and IsPlayerSpell(ids.ThrownPrecisionTalent) ) and 1 or 0) + (IsPlayerSpell(ids.ViciousVenomsTalent) and 1 or 0) + (IsPlayerSpell(ids.BlindsideTalent) and 1 or 0) )

        -- Maintain Caustic Spatter
        Variables.UseCausticFiller = IsPlayerSpell(ids.CausticSpatterTalent) and TargetHasDebuff(ids.Rupture) and ( not TargetHasDebuff(ids.CausticSpatterDebuff) or GetRemainingDebuffDuration("target", ids.CausticSpatterDebuff) <= 3 ) and MaxComboPoints - EffectiveComboPoints > 1 and not (NearbyEnemies < 2)     
        
        if OffCooldown(ids.Mutilate) and ( Variables.UseCausticFiller ) then
            KTrig("Mutilate") return true end
        
        if OffCooldown(ids.Ambush) and ( Variables.UseCausticFiller ) then
            KTrig("Ambush") return true end

        -- Fan of Knives at 6cp for Darkest Night
        if OffCooldown(ids.FanOfKnives) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 6 and ( not IsPlayerSpell(ids.ViciousVenomsTalent) or NearbyEnemies >= 2) ) then
            KTrig("Fan of Knives") return true end
        
        -- Fan of Knives at 3+ targets, accounting for various edge cases
        -- Kichi --
        if OffCooldown(ids.FanOfKnives) and (Variables.UseFiller and Variables.FokTargetCount ) then
            -- KTrig("Fan of Knives") return true end
            if Variables.NotPooling
            then
                KTrig("Fan of Knives") return true
            else
                KTrig("Fan of Knives", "Not Good") return true 
            end
        end
        
        -- Ambush on Blindside/Subterfuge. Do not use Ambush from stealth during Kingsbane & Deathmark.
        if OffCooldown(ids.Ambush) and ( Variables.UseFiller and ( PlayerHasBuff(ids.BlindsideBuff) or IsStealthed ) and ( not TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.Deathmark) == false or PlayerHasBuff(ids.BlindsideBuff) ) ) then
            -- KTrig("Ambush") return true end
            if Variables.NotPooling
            then
                KTrig("Ambush") return true
            else
                KTrig("Ambush", "Not Good") return true 
            end
        end
            
        
        -- Tab-Mutilate to apply Deadly Poison at 2 targets if not using Fan of Knives
        if OffCooldown(ids.Mutilate) and ( not TargetHasDebuff(ids.DeadlyPoisonDebuff) and not TargetHasDebuff(ids.AmplifyingPoisonDebuff) and Variables.UseFiller and NearbyEnemies == 2 ) then
            -- KTrig("Mutilate") return true end
            if Variables.NotPooling
            then
                KTrig("Mutilate") return true
            else
                KTrig("Mutilate", "Not Good") return true 
            end 
        end
        
        -- Fallback Mutilate
        if OffCooldown(ids.Mutilate) and ( Variables.UseFiller ) then
            -- KTrig("Mutilate") return true end
            if Variables.NotPooling 
            then
                KTrig("Mutilate") return true
            else
                KTrig("Mutilate", "Not Good") return true 
            end 
        end
    end
    
    -- Shiv conditions
    local Shiv = function()
        Variables.ShivCondition = not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.Garrote) and TargetHasDebuff(ids.Rupture) and NearbyEnemies <= 5
        
        Variables.ShivKingsbaneCondition = IsPlayerSpell(ids.Kingsbane) and PlayerHasBuff(ids.Envenom) and Variables.ShivCondition
        
        -- Shiv for aoe with Arterial Precision
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.ArterialPrecisionTalent) and Variables.ShivCondition and NearbyEnemies >= 4 and TargetHasDebuff(ids.CrimsonTempest) ) then      
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Shiv cases for Kingsbane
        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.Kingsbane) < 8 or not TargetHasDebuff(ids.Kingsbane) and GetRemainingSpellCooldown(ids.Kingsbane) >= 20 ) and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end

        -- Shiv for big Darkest Night Envenom during Lingering Darkness
        if OffCooldown(ids.Shiv) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.LingeringDarknessBuff) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) < 8 or GetRemainingSpellCooldown(ids.Kingsbane) <= 1 and GetSpellChargesFractional(ids.Shiv) >= 1.7 ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Fallback shiv for arterial during deathmark
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.ArterialPrecisionTalent) and not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.Garrote) and TargetHasDebuff(ids.Rupture) and TargetHasDebuff(ids.Deathmark) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Fallback if no special cases apply
        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.Kingsbane) and not IsPlayerSpell(ids.ArterialPrecisionTalent) and Variables.ShivCondition and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Dump Shiv on fight end
        if OffCooldown(ids.Shiv) and ( FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.Shiv).currentCharges * 8 ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
    end
    
    -- Stealthed Actions
    local Stealthed = function()
        -- Apply Deathstalkers Mark if it has fallen off or waiting for Rupture in AoE
        if OffCooldown(ids.Ambush) and ( not TargetHasDebuff(ids.DeathstalkersMarkDebuff) and IsPlayerSpell(ids.DeathstalkersMarkTalent) and EffectiveComboPoints < Variables.EffectiveSpendCp and ( TargetHasDebuff(ids.Rupture) or NearbyEnemies <= 1 or not IsPlayerSpell(ids.SubterfugeTalent)) ) then
            KTrig("Ambush") return true end
        
        -- Make sure to have Shiv up during Kingsbane as a final check
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.KingsbaneTalent) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) < 8 and ( not TargetHasDebuff(ids.ShivDebuff) or GetRemainingDebuffDuration("target", ids.ShivDebuff) < 1 ) and PlayerHasBuff(ids.EnvenomBuff) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Envenom to maintain the buff during Subterfuge
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and TargetHasDebuff(ids.Kingsbane) and GetRemainingAuraDuration("player", ids.Envenom) <= 3 and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 7) ) then
            KTrig("Envenom") return true end
        
        -- Envenom during Master Assassin in single target
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and GetRemainingAuraDuration("player", ids.MasterAssassinBuff) < -1 and (NearbyEnemies < 2) and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 7) ) then
            KTrig("Envenom") return true end
        
        -- Rupture during Indiscriminate Carnage
        -- if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.IndiscriminateCarnageBuff) and (IsAuraRefreshable(ids.Rupture) or NearbyRuptured < NearbyEnemies) and ( not Variables.RegenSaturated or not Variables.ScentSaturation or not TargetHasDebuff(ids.Rupture) ) and TargetTimeToXPct(0, 60) > 15 ) then
        -- Kichi --
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.IndiscriminateCarnageBuff) and NearbyRefreshableRuptured > 0 and ( not Variables.RegenSaturated or not Variables.ScentSaturation or not TargetHasDebuff(ids.Rupture) or NearbyRuptured < NearbyEnemies ) and true ) then
            KTrig("Rupture") return true end
        
        -- Improved Garrote: Apply or Refresh with buffed Garrotes, accounting for Indiscriminate Carnage
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( NearbyShortGarroted > 0 or ( not TargetHasDebuff(ids.Garrote) or NearbyUnenhancedGarroted > 0 ) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) and NearbyGarroted < NearbyEnemies ) ) and not (NearbyEnemies < 2) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 2 and MaxComboPoints - EffectiveComboPoints > 2 - (PlayerHasBuff(ids.DarkestNightBuff) and 2 or 0)) then
            KTrig("Garrote") return true end
        
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and MaxComboPoints - EffectiveComboPoints >= 1 + 2 * (IsPlayerSpell(ids.ShroudedSuffocationTalent) and 1 or 0) ) then
            KTrig("Garrote") return true end
    end
    
    -- Stealth Cooldowns Vanish Sync for Improved Garrote with Deathmark
    local Vanish = function()
        -- Vanish to fish for Fateful Ending
        if OffCooldown(ids.Vanish) and ( not PlayerHasBuff(ids.FateboundLuckyCoinBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( GetPlayerStacks(ids.FateboundCoinTailsBuff) >= 5 or GetPlayerStacks(ids.FateboundCoinHeadsBuff) >= 5 ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish to spread Garrote during Deathmark without Indiscriminate Carnage
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.MasterAssassinTalent) and not IsPlayerSpell(ids.IndiscriminateCarnageTalent) and IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and ( TargetHasDebuff(ids.Deathmark) or GetRemainingSpellCooldown(ids.Deathmark) < 4 ) and MaxComboPoints - EffectiveComboPoints >= min(NearbyEnemies, 4) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish for cleaving Garrotes with Indiscriminate Carnage
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.IndiscriminateCarnageTalent) and IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and NearbyEnemies > 2 and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Vanish) > 15  ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish fallback for Master Assassin
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.MasterAssassinTalent) and TargetHasDebuff(ids.Deathmark) and GetRemainingDebuffDuration("target", ids.Kingsbane) <= 6 + 3 * (IsPlayerSpell(ids.SubterfugeTalent) and 2 or 0) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish", "APL5")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish fallback for Improved Garrote during Deathmark if no add waves are expected
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and ( TargetHasDebuff(ids.Deathmark) or GetRemainingSpellCooldown(ids.Deathmark) < 4 )  ) then   
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
    end
    
    -- Cooldowns
    local Cds = function()
        -- Wait on Deathmark for Garrote with MA and check for Kingsbane
        Variables.DeathmarkMaCondition = not IsPlayerSpell(ids.MasterAssassinTalent) or TargetHasDebuff(ids.Garrote)
        
        Variables.DeathmarkKingsbaneCondition = not IsPlayerSpell(ids.Kingsbane) or GetRemainingSpellCooldown(ids.Kingsbane) <= 2
        
        -- Deathmark to be used if not stealthed, Rupture is up, and all other talent conditions are satisfied
        Variables.DeathmarkCondition = not IsStealthed and GetRemainingAuraDuration("player", ids.SliceAndDice) > 5 and TargetHasDebuff(ids.Rupture) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and not TargetHasDebuff(ids.Deathmark) and Variables.DeathmarkMaCondition and Variables.DeathmarkKingsbaneCondition
        
        -- Cast Deathmark if the target will survive long enough
        if OffCooldown(ids.Deathmark) and ( ( Variables.DeathmarkCondition and TargetTimeToXPct(0, 60) >= 10 ) or FightRemains(60, NearbyRange) <= 20 ) then
            -- KTrig("Deathmark") return true end
            if aura_env.config[tostring(ids.Deathmark)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Deathmark")
            elseif aura_env.config[tostring(ids.Deathmark)] ~= true then
                KTrig("Deathmark")
                return true
            end
        end
        
        -- Check for Applicable Shiv usage
        if Shiv() then 
            -- return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                return true
            end
        end
        
        if OffCooldown(ids.Kingsbane) and ( ( TargetHasDebuff(ids.ShivDebuff) or GetRemainingSpellCooldown(ids.Shiv) < 6 ) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and ( GetRemainingSpellCooldown(ids.Deathmark) >= 50 or TargetHasDebuff(ids.Deathmark) ) or FightRemains(60, NearbyRange) <= 15 ) then
            -- KTrig("Kingsbane") return true end
            if aura_env.config[tostring(ids.Kingsbane)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kingsbane")
            elseif aura_env.config[tostring(ids.Kingsbane)] ~= true then
                KTrig("Kingsbane")
                return true
            end
        end
        
        if not IsStealthed and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 then
            if Vanish() then 
                --return true end end
                if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                    return true
                end
            end
        end

    end

    -- Call Stealthed Actions
    if IsStealthed or HasImprovedGarroteBuff or abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) > 0 then
        if Stealthed() then 
            -- print("Stealthed")
            return true end end
    
    -- Call Cooldowns    
    if Cds() then 
        -- print("Cds")
        return true end
    
    -- Call Core DoT effects
    if CoreDot() then 
        -- print("CoreDot")
        return true end
    
    -- Call AoE DoTs when in AoE
    if not (NearbyEnemies < 2) then
        if AoeDot() then 
            -- print("AoeDot")
            return true end end
    
    -- Call Direct Damage Abilities
    if Direct() then 
        -- print("Direct")
        return true end
    
    KTrig("Clear")

end
