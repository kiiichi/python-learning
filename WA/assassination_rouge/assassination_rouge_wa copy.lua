----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

-- Kichi --
_G.KLIST = { 
    AssassinationRogue = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

aura_env.GarroteSnapshots = {}
aura_env.CrimsonTempestSnapshots = {}
aura_env.LastCrimsonTempestCount = 0
aura_env.Envenom1 = 0
aura_env.Envenom2 = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Ambush = 8676,
    ColdBlood1 = 382245, -- Kichi add for different id
    ColdBlood2 = 456330, -- Kichi add for different id
    CrimsonTempest = 121411,
    Deathmark = 360194,
    EchoingReprimand = 385616,
    Envenom = 32645,
    FanOfKnives = 51723,
    Garrote = 703,
    Kingsbane = 385627,
    Mutilate = 1329,
    Rupture = 1943,
    Shiv = 5938,
    SliceAndDice = 315496,
    ThistleTea = 381623,
    Vanish = 1856,
    
    -- Talents
    AmplifyingPoisonTalent = 381664,
    ArterialPrecisionTalent = 400783,
    BlindsideTalent = 328085,
    CausticSpatterTalent = 421975,
    DarkestNightTalent = 457058,
    DashingScoundrelTalent = 381797,
    DeathstalkersMarkTalent = 457052,
    HandOfFateTalent = 452536,
    ImprovedGarroteTalent = 381632,
    IndiscriminateCarnageTalent = 381802,
    InevitabileEndTalent = 454434,
    KingsbaneTalent = 385627,
    LightweightShivTalent = 394983,
    MasterAssassinTalent = 255989,
    MomentumOfDespairTalent = 457067,
    PoisonBombTalent = 255544,
    ScentOfBloodTalent = 381799,
    ShroudedSuffocationTalent = 385478,
    SubterfugeTalent = 108208,
    ThrownPrecisionTalent = 381629,
    ViciousVenomsTalent = 381634,
    TwistTheKnifeTalent = 381669,
    ZoldyckRecipeTalent = 381798,
    SuddenDemiseTalent = 423136,
    ForcedInductionTalent = 470668,
    
    -- Auras
    AmplifyingPoisonDebuff = 383414,
    BlindsideBuff = 121153,
    CausticSpatterDebuff = 421976,
    ClearTheWitnessesBuff = 457178,
    ColdBloodBuff1 = 382245, -- Kichi add for different id
    ColdBloodBuff2 = 456330, -- Kichi add for different id
    CrimsonTempestDebuff = 121411, 
    DarkestNightBuff = 457280,
    DeadlyPoisonDebuff = 2818,
    DeathstalkersMarkDebuff = 457129,
    DeathmarkDebuff = 360194,
    EnvenomBuff = 32645,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    GarroteDebuff = 703,
    IndiscriminateCarnageBuff = 385747,
    KingsbaneDebuff = 385627,
    LingeringDarknessBuff = 457273,
    MasterAssassinBuff = 256735,
    MomentumOfDespairBuff = 457115,
    VanishBuff = 11327,
    RuptureDebuff = 1943,
    ScentOfBloodBuff = 394080,
    SliceAndDiceBuff = 315496,
    ShivDebuff = 319504,
    SubterfugeBuff = 115192,
    StealthBuff = 1784,
    ThistleTeaBuff = 381623,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

-- Kichi --
-- Kichi --
aura_env.KTrig = function(Name, ...)
    WeakAuras.ScanEvents("K_TRIGED", Name, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    if aura_env.FlagKTrigCD then
        WeakAuras.ScanEvents("K_TRIGED_CD", "Clear", ...)
    end
    aura_env.FlagKTrigCD = flase
end

aura_env.KTrigCD = function(Name, ...)
    WeakAuras.ScanEvents("K_TRIGED_CD", Name, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    aura_env.FlagKTrigCD = false
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    -- Kichi --
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) and (not nomana) then return false end
    
    -- Kichi --
    -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Duration = Cooldown.duration
    local Remaining = Cooldown.startTime + Duration - GetTime()
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())

    if not OffCooldown then return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    if InRange == false then
        aura_env.OutOfRange = true
        --return false
    end
    
    return true
end

aura_env.IsCasting = function(spellID)
    return select(9, UnitCastingInfo("player")) == spellID
end

aura_env.GetStacks = function(unit, spellID, filter)
    local _,_,Stacks = WA_GetUnitAura(unit, spellID, filter)
    if Stacks == nil then Stacks = 0 end
    return Stacks
end

aura_env.GetPlayerStacks = function(spellID)
    return aura_env.GetStacks("player", spellID)
end

aura_env.GetTargetStacks = function(spellID)
    return aura_env.GetStacks("target", spellID, "PLAYER|HARMFUL")
end

aura_env.GetRemainingAuraDuration = function(unit, spellID, filter)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if filter == nil then filter = "PLAYER" end
    local AuraFound = WA_GetUnitAura(unit, spellID, filter)
    
    if AuraFound == nil then return 0 end
    local Expiration = select(6, WA_GetUnitAura(unit, spellID, filter))
    if Expiration == nil then return 0 end
    return Expiration - GetTime()
end

-- Kichi --
aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    local duration = aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
    if duration == nil then duration = 0 end
    return duration
end

aura_env.GetSpellChargesFractional = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local CurrentCharges = ChargeInfo.currentCharges
    if ChargeInfo.cooldownStartTime == 0 then return CurrentCharges end
    
    local FractionalCharge = (GetTime() - ChargeInfo.cooldownStartTime) / ChargeInfo.cooldownDuration
    return CurrentCharges + FractionalCharge
end

aura_env.GetTimeToNextCharge = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local MissingCharges = ChargeInfo.maxCharges - ChargeInfo.currentCharges
    if MissingCharges == 0 then return 0 end
    
    local TimeRemaining = ChargeInfo.cooldownStartTime + ChargeInfo.cooldownDuration - GetTime()
    return TimeRemaining
end

aura_env.GetTimeToFullCharges = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local MissingCharges = ChargeInfo.maxCharges - ChargeInfo.currentCharges
    if MissingCharges == 0 then return 0 end
    
    local TimeRemaining = ChargeInfo.cooldownStartTime + ChargeInfo.cooldownDuration - GetTime()
    if MissingCharges > 1 then 
        TimeRemaining = TimeRemaining + (ChargeInfo.cooldownDuration * (MissingCharges-1))
    end
    return TimeRemaining
end

aura_env.TargetTimeToXPct = function(Pct, Default)
    if Default == nil then
        local c = a < b -- Throw an error
    end
    
    if HeroLib == nil then
        return Default
    end
    
    return HeroLib.Unit.Target:TimeToX(Pct)
end

aura_env.FightRemains = function(Default, NearbyRange)
    if Default == nil then
        local c = a < b -- Throw an error
    end
    
    if HeroLib == nil then
        return Default
    end
    
    return HeroLib.FightRemains(HeroLib.Unit.Player:GetEnemiesInRange(NearbyRange))
end

aura_env.GetRemainingSpellCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    if ChargeInfo and C_Spell.GetSpellCharges(spellID).currentCharges >= 1 then return 0 end
    
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Remaining = Cooldown.startTime + Cooldown.duration - GetTime()
    if (Cooldown.duration == 0 or Cooldown.duration == WeakAuras.gcdDuration()) then Remaining = 0 end
    return Remaining
end

aura_env.IsAuraRefreshable = function(SpellID, Unit, Filter)
    -- Kichi --
    -- local Filter = ""
    if Unit == nil then 
        Unit = "target" 
        Filter = "HARMFUL|PLAYER" 
    end
    
    local _,_,_,_,Duration,ExpirationTime = WA_GetUnitAura(Unit, SpellID, Filter)
    if Duration == nil then return true end
    
    local RemainingTime = ExpirationTime - GetTime()
    
    return (RemainingTime / Duration) < 0.3
end

-- Kichi fix
aura_env.GetRemainingStealthDuration = function()
    if WA_GetUnitAura("player", aura_env.ids.Stealth) then return 999999999 end
    
    local SubterfugeExpiration = select(6, WA_GetUnitAura("player", aura_env.ids.SubterfugeBuff))
    if SubterfugeExpiration ~= nil then return SubterfugeExpiration end
    
    local ShadowDanceExpiration = select(6, WA_GetUnitAura("player", aura_env.ids.ShadowDanceBuff))
    if ShadowDanceExpiration ~= nil then return ShadowDanceExpiration end
    
    return 0
end

aura_env.HasBloodlust = function()
    return (WA_GetUnitBuff("player", 2825) or WA_GetUnitBuff("player", 264667) or WA_GetUnitBuff("player", 80353) or WA_GetUnitBuff("player", 32182) or WA_GetUnitBuff("player", 390386) or WA_GetUnitBuff("player", 386540))
end

aura_env.PlayerHasBuff = function(spellID)
    return WA_GetUnitBuff("player", spellID) ~= nil
end

aura_env.TargetHasDebuff = function(spellID)
    return WA_GetUnitDebuff("target", spellID, "PLAYER|HARMFUL") ~= nil
end

-- Kichi --
aura_env.FullGCD = function()
    local baseGCD = 1.5
    local FullGCDnum = math.max(0.75, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core1--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function()
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
    local GetRemainingStealthDuration = aura_env.GetRemainingStealthDuration
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------  
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1928)
    
    local CurrentComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    -- Kichi add detecting charged combo points
    local ChargedCmoboPointsInArray = GetUnitChargedPowerPoints("player")
    local ChargedCmoboPoints = ChargedCmoboPointsInArray and #ChargedCmoboPointsInArray or 0

    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    
    -- Kichi add charged combo points and normal combo points
    -- local EffectiveComboPoints = CurrentComboPoints
    local EffectiveComboPoints = (CurrentComboPoints > 0) and (CurrentComboPoints + math.min(ChargedCmoboPoints, 1) * (2 + (IsPlayerSpell(ids.ForcedInductionTalent) and 1 or 0) )) or 0

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

            if IsAuraRefreshable(ids.Garrote, unit, "HARMFUL|PLAYER") and ( aura_env.GarroteSnapshots[UnitGUID(unit)] <= 1 or aura_env.PlayerHasBuff(392403) or aura_env.PlayerHasBuff(392401) ) then
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
    Variables.EffectiveSpendCp = max(MaxComboPoints - 2, 5)
    
    -- Conditional to check if there is only one enemy
    Variables.SingleTarget = NearbyEnemies <= 1
    
    -- Combined Energy Regen needed to saturate, with an additional check to account for m+ build archetypes
    Variables.RegenSaturated = EnergyRegen > 30 + 10 * ( IsPlayerSpell(ids.DashingScoundrelTalent) and 0 or 1 )
    
    -- Pooling Setup, check for cooldowns
    Variables.InCooldowns = TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.ShivDebuff)
    
    -- Check upper bounds of energy to begin spending
    Variables.UpperLimitEnergy = (CurrentEnergy/MaxEnergy*100) >= ( 80 - 10 * (IsPlayerSpell(ids.ViciousVenomsTalent) and 2 or 0) - (30 * (IsPlayerSpell(ids.AmplifyingPoisonTalent) and 1 or 0)) )
    
    -- Checking for cooldowns soon
    Variables.CdSoon = IsPlayerSpell(ids.KingsbaneTalent) and GetRemainingSpellCooldown(ids.Kingsbane) < 3 and not OffCooldown(ids.Kingsbane)
    
    -- Pooling Condition all together
    Variables.NotPooling = Variables.InCooldowns or PlayerHasBuff(ids.DarkestNightBuff) or Variables.UpperLimitEnergy or FightRemains(60, NearbyRange) <= 20
    
    -- Check what the maximum Scent of Blood stacks is currently
    -- Kichi --
    Variables.ScentEffectiveMaxStacks = min(( NearbyEnemies * (IsPlayerSpell(ids.ScentOfBloodTalent) and 2 or 0) )*2, 20)
    
    -- We are Scent Saturated when our stack count is hitting the maximum
    Variables.ScentSaturation = GetPlayerStacks(ids.ScentOfBloodBuff) >= Variables.ScentEffectiveMaxStacks
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
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
    -- if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTeaBuff) and GetRemainingDebuffDuration("target", ids.ShivDebuff) >= 6 and not TargetHasDebuff(ids.KingsbaneDebuff) or not PlayerHasBuff(ids.ThistleTeaBuff) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) <= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) then
    -- same with NG
    if OffCooldown(ids.ThistleTea) and ( IsPlayerSpell(ids.DeathstalkersMarkTalent) and ( not PlayerHasBuff(ids.ThistleTeaBuff) and GetRemainingDebuffDuration("target", ids.ShivDebuff) >= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) <= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) ) then
    ExtraGlows.ThistleTea = true 
    end
    
    -- Cold Blood with similar conditions to Envenom,
    if OffCooldown(ids.ColdBlood1) and ( GetRemainingSpellCooldown(ids.Deathmark) > 10 and not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) and not PlayerHasBuff(ids.VanishBuff) and ( not OffCooldown(ids.Kingsbane) or not (NearbyEnemies < 2) ) and not OffCooldown(ids.Deathmark) ) then
    ExtraGlows.ColdBlood = true end

    -- Vold Blood for Edge Case or Envenoms during shiv
    if OffCooldown(ids.ColdBlood1) and ( ( GetPlayerStacks(ids.FateboundCoinHeadsBuff) > 0 and GetPlayerStacks(ids.FateboundCoinTailsBuff) > 0) or TargetHasDebuff(ids.ShivDebuff) and ( GetRemainingSpellCooldown(ids.Deathmark) > 50 and not (SetPieces >= 4 and IsPlayerSpell(ids.HandOfFateTalent)) or TargetHasDebuff(ids.KingsbaneDebuff) and (SetPieces >= 4 and IsPlayerSpell(ids.HandOfFateTalent)) or not IsPlayerSpell(ids.InevitabileEndTalent) and EffectiveComboPoints >= Variables.EffectiveSpendCp ) ) then
        ExtraGlows.ColdBlood = true end

    -- -- actions.cds+=/cold_blood,use_off_gcd=1,if=(buff.fatebound_coin_tails.stack>0&buff.fatebound_coin_heads.stack>0)|debuff.shiv.up&(cooldown.deathmark.remains>50&(!set_bonus.tww3_fatebound_4pc)|dot.kingsbane.ticking&(set_bonus.tww3_fatebound_4pc)|!talent.inevitabile_end&effective_combo_points>=variable.effective_spend_cp)
    -- if OffCooldown(ids.ColdBlood1) and (
    --     (GetPlayerStacks(ids.FateboundCoinTailsBuff) > 0 and GetPlayerStacks(ids.FateboundCoinHeadsBuff) > 0)
    --     or (
    --         TargetHasDebuff(ids.ShivDebuff)
    --         and (
    --             (GetRemainingSpellCooldown(ids.Deathmark) > 50 and not (SetPieces >= 4 and IsPlayerSpell(ids.HandOfFateTalent)))
    --             or (TargetHasDebuff(ids.KingsbaneDebuff) and (SetPieces >= 4 and IsPlayerSpell(ids.HandOfFateTalent)))
    --             or (not IsPlayerSpell(ids.InevitabileEndTalent) and EffectiveComboPoints >= Variables.EffectiveSpendCp)
    --         )
    --     )
    -- ) then
    --     ExtraGlows.ColdBlood = true
    -- end

    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)

    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Damage over time abilities
    local AoeDot = function()
        Variables.DotFinisherCondition = EffectiveComboPoints >= Variables.EffectiveSpendCp

        -- Kichi modyfied for earlier use CrimsonTempest if has SuddenDemiseTalent
        -- Crimson Tempest on 2+ Targets
        if OffCooldown(ids.CrimsonTempest) and ( NearbyEnemies >= 2 and IsAuraRefreshable(ids.CrimsonTempest) and Variables.DotFinisherCondition and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.CrimsonTempest) > 6 or IsPlayerSpell(ids.SuddenDemiseTalent) ) and not PlayerHasBuff(ids.DarkestNightBuff) ) then
            KTrig("Crimson Tempest") return true end
        
        -- Kichi --
        if OffCooldown(ids.Garrote) and aura_env.config["PerformanceMode"] == true and ( MaxComboPoints - EffectiveComboPoints >= 1 and NearbyRefreshableGarroted > 0 and not Variables.RegenSaturated and not IsPlayerSpell(ids.DashingScoundrelTalent) ) then
            KTrig("Garrote", "TAB") return true end

        -- Kichi modyfied for use Garrote if has SuddenDemiseTalent
        -- Garrote upkeep in AoE to reach energy saturation
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and not Variables.RegenSaturated and NearbyEnemies <= 3 and not IsPlayerSpell(ids.DashingScoundrelTalent) and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 or IsPlayerSpell(ids.SuddenDemiseTalent)) ) then
            KTrig("Garrote") return true end
        
        -- Kichi --
        if OffCooldown(ids.Rupture) and aura_env.config["PerformanceMode"] == true and ( Variables.DotFinisherCondition and NearbyRefreshableRuptured > 0 and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and ( not Variables.RegenSaturated and ( IsPlayerSpell(ids.ScentOfBloodTalent) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) or true ) ) ) and true and not PlayerHasBuff(ids.DarkestNightBuff) ) then
            KTrig("Rupture", "TAB") return true end
        
        -- Kichi modyfied for use Rupture if has SuddenDemiseTalent
        -- Rupture upkeep in AoE to reach energy/scent saturation or to spread for damage
        if OffCooldown(ids.Rupture) and ( Variables.DotFinisherCondition and IsAuraRefreshable(ids.Rupture) and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and ( not Variables.RegenSaturated or not Variables.ScentSaturation ) and ( TargetTimeToXPct(0, 60) > (7 + (IsPlayerSpell(ids.DashingScoundrelTalent) and 5 or 0) + (Variables.RegenSaturated and 6 or 0)) or IsPlayerSpell(ids.SuddenDemiseTalent) ) and not PlayerHasBuff(ids.DarkestNightBuff)) then
            KTrig("Rupture") return true end
        
        -- Need to test
        -- -- Kichi --
        -- if OffCooldown(ids.Rupture) and aura_env.config["PerformanceMode"] == true and ( Variables.DotFinisherCondition and NearbyRefreshableRuptured > 0 and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and Variables.RegenSaturated and not Variables.ScentSaturation and true and not PlayerHasBuff(ids.DarkestNightBuff)) then
        --     KTrig("Rupture", "TAB") return true end
        
        -- Kichi modyfied for use Garrote if has SuddenDemiseTalent
        -- Garrote as a special generator for the last CP before a finisher for edge case handling
        if OffCooldown(ids.Garrote) and ( IsAuraRefreshable(ids.Garrote) and MaxComboPoints - EffectiveComboPoints == 1 and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or GetRemainingDebuffDuration("target", ids.Garrote) <= 2 and NearbyEnemies >= 3 ) and ( GetRemainingDebuffDuration("target", ids.Garrote) <= 2 * 2 and NearbyEnemies >= 3 ) and ( ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) ) > 4 or IsPlayerSpell(ids.SuddenDemiseTalent) ) and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 ) then
            KTrig("Garrote") return true end
    end
    
    -- Core damage over time abilities used everywhere 
    local CoreDot = function()
        -- Kichi modyfied for SuddenDemiseTalent
        -- Maintain Garrote
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 or IsPlayerSpell(ids.SuddenDemiseTalent)) ) then
            KTrig("Garrote") return true end
        
        -- Kichi modyfied for SuddenDemiseTalent
        -- Maintain Rupture unless darkest night is up
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > ( 4 + ( (IsPlayerSpell(ids.DashingScoundrelTalent) and 1 or 0) * 5 ) + ( (Variables.RegenSaturated and 1 or 0) * 6 ) ) or IsPlayerSpell(ids.SuddenDemiseTalent) ) and (not PlayerHasBuff(ids.DarkestNightBuff) or IsPlayerSpell(ids.CausticSpatterTalent) and not TargetHasDebuff(ids.CausticSpatterDebuff)) ) then
            KTrig("Rupture") return true end

        -- Kichi modyfied for simc fixed
        -- Maintain Crimson Tempest unless it would remove a stronger cast
        if OffCooldown(ids.CrimsonTempest) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.CrimsonTempestDebuff) and not PlayerHasBuff(ids.DarkestNightBuff) and not IsPlayerSpell(ids.AmplifyingPoisonTalent) ) then
            KTrig("Crimson Tempest") return true end
    end
    
    -- Direct Damage Abilities Envenom at applicable cp if not pooling, capped on amplifying poison stacks, on an animacharged CP, or in aoe.
    local Direct = function()
        -- Maintain Caustic Spatter
        Variables.UseCausticFiller = IsPlayerSpell(ids.CausticSpatterTalent) and TargetHasDebuff(ids.Rupture) and ( not TargetHasDebuff(ids.CausticSpatterDebuff) or GetRemainingDebuffDuration("target", ids.CausticSpatterDebuff) <= 2 ) and MaxComboPoints - EffectiveComboPoints >= 1 and not (NearbyEnemies < 2)     
        
        if OffCooldown(ids.Mutilate) and ( Variables.UseCausticFiller ) then
            KTrig("Mutilate") return true end
        
        if OffCooldown(ids.Ambush) and ( Variables.UseCausticFiller ) then
            KTrig("Ambush") return true end

        -- Base Envenom Condition
        if OffCooldown(ids.Envenom) and ( not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) ) then
            KTrig("Envenom") return true end
        
        -- Special Envenom handling for Darkest Night
        if OffCooldown(ids.Envenom) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= MaxComboPoints ) then
            KTrig("Envenom") return true end
        
        -- Various checks to see if we need to use a generator
        Variables.UseFiller = CurrentComboPoints <= Variables.EffectiveSpendCp and not Variables.CdSoon or Variables.NotPooling or not (NearbyEnemies < 2)
        
        if OffCooldown(ids.FanOfKnives) and ( PlayerHasBuff(ids.ClearTheWitnessesBuff) and ( NearbyEnemies >= 2 - ( ( PlayerHasBuff(ids.LingeringDarknessBuff) or not IsPlayerSpell(ids.ViciousVenomsTalent) ) and 1 or 0 ) ) ) then
            KTrig("Fan of Knives") return true end
        
        -- Kichi modified for simc fixed
        Variables.FokTargetCount = ( NearbyEnemies >= 3 - (IsPlayerSpell(ids.ThrownPrecisionTalent) and 1 or 0) + (IsPlayerSpell(ids.ViciousVenomsTalent) and 1 or 0) + (IsPlayerSpell(ids.BlindsideTalent) and 1 or 0) )

        -- Fan of Knives at 6cp for special case Darkest Night
        if OffCooldown(ids.FanOfKnives) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 6 and ( not IsPlayerSpell(ids.ViciousVenomsTalent) or NearbyEnemies >= 2) ) then
            KTrig("Fan of Knives") return true end
        
        -- Kichi add NotPooling check--
        -- Fan of Knives at 3+ targets, accounting for various edge cases
        if OffCooldown(ids.FanOfKnives) and (Variables.UseFiller and Variables.FokTargetCount ) then
            -- KTrig("Fan of Knives") return true end
            if Variables.NotPooling
            then
                KTrig("Fan of Knives") return true
            else
                KTrig("Fan of Knives") return true 
            end
        end
        
        -- Ambush on Blindside/Subterfuge. Do not use Ambush from stealth during Kingsbane & Deathmark.
        if OffCooldown(ids.Ambush) and ( Variables.UseFiller and ( PlayerHasBuff(ids.BlindsideBuff) or IsStealthed ) and ( not TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.Deathmark) == false or PlayerHasBuff(ids.BlindsideBuff) ) ) then
            -- KTrig("Ambush") return true end
            if Variables.NotPooling
            then
                KTrig("Ambush") return true
            else
                KTrig("Ambush") return true 
            end
        end
            
        
        -- Tab-Mutilate to apply Deadly Poison at 2 targets if not using Fan of Knives
        if OffCooldown(ids.Mutilate) and ( not TargetHasDebuff(ids.DeadlyPoisonDebuff) and not TargetHasDebuff(ids.AmplifyingPoisonDebuff) and Variables.UseFiller and NearbyEnemies == 2 ) then
            -- KTrig("Mutilate") return true end
            if Variables.NotPooling
            then
                KTrig("Mutilate") return true
            else
                KTrig("Mutilate") return true 
            end 
        end
        
        -- Fallback Mutilate if all else fails
        if OffCooldown(ids.Mutilate) and ( Variables.UseFiller ) then
            -- KTrig("Mutilate") return true end
            if Variables.NotPooling 
            then
                KTrig("Mutilate") return true
            else
                KTrig("Mutilate") return true 
            end 
        end
    end
    
    -- Shiv conditions
    local Shiv = function()
        -- Generic Variables to check for basic shiv eligibility
        Variables.ShivCondition = not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.Garrote) and TargetHasDebuff(ids.Rupture) and NearbyEnemies <= 5
        
        Variables.ShivKingsbaneCondition = IsPlayerSpell(ids.Kingsbane) and PlayerHasBuff(ids.Envenom) and Variables.ShivCondition

        -- Shiv for Fatebound Edge Case Coins Before Deathmark + Kingsbane with new Tier Set
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( OffCooldown(ids.Deathmark) or GetRemainingSpellCooldown(ids.Deathmark) <= 1 ) and ( OffCooldown(ids.Kingsbane) or GetRemainingSpellCooldown(ids.Kingsbane) <= 2 ) and ( SetPieces >= 2 and IsPlayerSpell(ids.HandOfFateTalent) ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end

        -- Shiv for aoe with Arterial Precision
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.ArterialPrecisionTalent) and not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.GarroteDebuff) and TargetHasDebuff(ids.RuptureDebuff) and NearbyEnemies >= 4 and TargetHasDebuff(ids.CrimsonTempestDebuff) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and IsPlayerSpell(ids.ZoldyckRecipeTalent) or GetSpellChargesFractional(ids.Shiv) >= 1.9 ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Single-charge Shiv case for Kingsbane
        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.Kingsbane) < ( 8 + 3 * (( SetPieces >= 4 and IsPlayerSpell(ids.DeathstalkersMarkTalent) ) and 1 or 0)) or not TargetHasDebuff(ids.Kingsbane) and GetRemainingSpellCooldown(ids.Kingsbane) >= 20 ) and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end

        -- Shiv for big Darkest Night Envenom during Lingering Darkness
        if OffCooldown(ids.Shiv) and ( GetTargetStacks(ids.DeathstalkersMarkDebuff) <= 2 and EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.LingeringDarknessBuff) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) < ( 8 + 3 * (( SetPieces >= 4 and IsPlayerSpell(ids.DeathstalkersMarkTalent) ) and 1 or 0)) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) > 4 or GetRemainingSpellCooldown(ids.Kingsbane) <= 1 and GetSpellChargesFractional(ids.Shiv) >= 1.7 ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Fallback shiv for arterial during deathmark - WIP needs checking when Fatebound Kingsbane stacks are fixed, as it currently is munching shiv before the last 8 seconds of KB.
        if OffCooldown(ids.Shiv) and ( TargetHasDebuff(ids.DeathmarkDebuff) and IsPlayerSpell(ids.ArterialPrecisionTalent) and not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.GarroteDebuff) and TargetHasDebuff(ids.RuptureDebuff) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Fallback if no special cases apply
        if OffCooldown(ids.Shiv) and ( not TargetHasDebuff(ids.DeathmarkDebuff) and not IsPlayerSpell(ids.KingsbaneTalent) and Variables.ShivCondition and ( TargetHasDebuff(ids.CrimsonTempestDebuff) or IsPlayerSpell(ids.AmplifyingPoisonTalent) ) and ( ( ( (IsPlayerSpell(ids.LightweightShivTalent) and 1 or 0) + 1 ) - GetSpellChargesFractional(ids.Shiv) ) * 30 < GetRemainingSpellCooldown(ids.Deathmark) ) ) then
        -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end

        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.Kingsbane) and not IsPlayerSpell(ids.ArterialPrecisionTalent) and Variables.ShivCondition and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end
        
        -- Kichi add for practical next fight use
        -- Dump Shiv on fight end
        if OffCooldown(ids.Shiv) and ( FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.Shiv).currentCharges * ( 8 + 3 * (( SetPieces >= 4 and IsPlayerSpell(ids.DeathstalkersMarkTalent) ) and 1 or 0)) ) then
            -- KTrig("Shiv") return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shiv")
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                KTrig("Shiv")
                return true
            end
        end

        -- Kichi add for get full use of Shiv's CD
        if OffCooldown(ids.Shiv) and ( GetSpellChargesFractional(ids.Shiv) > 1.9 and SetPieces >= 4 and GetTargetStacks(ids.DeathstalkersMarkDebuff) <= 2 and (MaxComboPoints - EffectiveComboPoints < 2) and (GetRemainingSpellCooldown(ids.Deathmark) > 30) and (GetRemainingSpellCooldown(ids.Kingsbane) > 30 or not IsPlayerSpell(ids.KingsbaneTalent)) ) then
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

        -- Kichi add for parctical use
        if OffCooldown(ids.Ambush) and ( not TargetHasDebuff(ids.DeathstalkersMarkDebuff) and IsPlayerSpell(ids.DeathstalkersMarkTalent) and not PlayerHasBuff(ids.DarkestNightBuff) and GetRemainingAuraDuration("player", ids.SubterfugeBuff) > 0 and GetRemainingAuraDuration("player", ids.SubterfugeBuff) <= FullGCD()  ) then
            KTrig("Ambush", "Glow") return true end

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
        
        -- Kichi replce "==" to ">=" because of charged combopoint
        -- Envenom to maintain the buff during Subterfuge
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and TargetHasDebuff(ids.Kingsbane) and GetRemainingAuraDuration("player", ids.Envenom) <= 3 and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= 7) ) then
            KTrig("Envenom") return true end
        
        -- Kichi replce "==" to ">=" because of charged combopoint
        -- Envenom during Master Assassin in single target
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and GetRemainingAuraDuration("player", ids.MasterAssassinBuff) < -1 and (NearbyEnemies < 2) and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= 7) ) then
            KTrig("Envenom") return true end
        
        -- Kichi -- for quick danmage
        if OffCooldown(ids.CrimsonTempest) and ( NearbyEnemies >= aura_env.config["CrimsonTempestThreshold"] and EffectiveComboPoints >= 3 and GetRemainingDebuffDuration("target", ids.CrimsonTempest) <= 2 and not PlayerHasBuff(ids.DarkestNightBuff) and ( Variables.ScentSaturation or GetPlayerStacks(ids.ScentOfBloodBuff) >= 12 ) and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.CrimsonTempest) > 6 or IsPlayerSpell(ids.SuddenDemiseTalent)) ) then
            KTrig("Crimson Tempest") return true end

        -- Kichi -- for quick danmage
        Variables.DeathmarkConditionInStealthed = TargetHasDebuff(ids.Rupture) and ( Variables.DeathmarkKingsbaneCondition or NearbyEnemies > 1 and EffectiveComboPoints >= Variables.EffectiveSpendCp and Variables.ScentSaturation and ( TargetHasDebuff(ids.CrimsonTempest) or not IsPlayerSpell(ids.CrimsonTempest) == true ) ) and not TargetHasDebuff(ids.Deathmark) and ( not IsPlayerSpell(ids.MasterAssassinTalent) or TargetHasDebuff(ids.Garrote) )

        -- Kichi -- for quick danmage
        if OffCooldown(ids.Deathmark) and ( ( (Variables.DeathmarkConditionInStealthed) and TargetTimeToXPct(0, 60) >= 10 ) or FightRemains(60, NearbyRange) <= 20 ) then
            -- KTrig("Deathmark") return true end
            if aura_env.config[tostring(ids.Deathmark)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Deathmark", "Quick")
            elseif aura_env.config[tostring(ids.Deathmark)] ~= true then
                KTrig("Deathmark")
                return true
            end
        end

        -- Kichi -- for quick danmage
        if Shiv() then 
            -- return true end
            if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
            elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                return true
            end
        end

        -- Kichi -- for quick danmage
        if OffCooldown(ids.Kingsbane) and ( ( TargetHasDebuff(ids.ShivDebuff) or GetRemainingSpellCooldown(ids.Shiv) < 6 ) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and TargetHasDebuff(ids.Deathmark) or FightRemains(60, NearbyRange) <= 15 ) then
            -- KTrig("Kingsbane") return true end
            if aura_env.config[tostring(ids.Kingsbane)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kingsbane")
            elseif aura_env.config[tostring(ids.Kingsbane)] ~= true then
                KTrig("Kingsbane")
                return true
            end
        end

        -- Kichi -- for quick danmage
        if OffCooldown(ids.Kingsbane) and ( ( TargetHasDebuff(ids.ShivDebuff) or GetRemainingSpellCooldown(ids.Shiv) < 6 ) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and ( GetRemainingSpellCooldown(ids.Deathmark) >= 50 and not TargetHasDebuff(ids.Deathmark) ) or FightRemains(60, NearbyRange) <= 15 ) then
            -- KTrig("Kingsbane") return true end
            if aura_env.config[tostring(ids.Kingsbane)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kingsbane", "Quick")
            elseif aura_env.config[tostring(ids.Kingsbane)] ~= true then
                KTrig("Kingsbane")
                return true
            end
        end
        
        -- Kichi -- for 1.dot check way 2.add NearbyRuptured < NearbyEnemies in a or gate 3.SuddenDemiseTalent
        -- Rupture during Indiscriminate Carnage
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.IndiscriminateCarnageBuff) and NearbyRefreshableRuptured > 0 and ( ( IsPlayerSpell(ids.CausticSpatterTalent) and not TargetHasDebuff(ids.CausticSpatterDebuff) and not TargetHasDebuff(ids.RuptureDebuff) ) or not PlayerHasBuff(ids.DarkestNightBuff) ) and (not Variables.RegenSaturated or not Variables.ScentSaturation or (( not IsPlayerSpell(ids.DashingScoundrelTalent) or not IsPlayerSpell(ids.PoisonBombTalent)) and PlayerHasBuff(ids.IndiscriminateCarnageBuff) and not TargetHasDebuff(ids.Rupture) ) or NearbyRuptured < NearbyEnemies ) and ( TargetTimeToXPct(0, 60) > 15 or IsPlayerSpell(ids.SuddenDemiseTalent) ) ) then
            KTrig("Rupture") return true end
        
        -- Kichi -- for 1.dot check way 2.SuddenDemiseTalent
        -- Improved Garrote: Apply or Refresh with buffed Garrotes, accounting for Indiscriminate Carnage
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( NearbyRefreshableGarroted > 0 or ( not TargetHasDebuff(ids.Garrote) or NearbyUnenhancedGarroted > 0 ) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) and NearbyGarroted < NearbyEnemies ) ) and not (NearbyEnemies < 2) and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 2 or IsPlayerSpell(ids.SuddenDemiseTalent)) and MaxComboPoints - EffectiveComboPoints > 2 - (PlayerHasBuff(ids.DarkestNightBuff) and 2 or 0)) then
            KTrig("Garrote") return true end

        -- Kichi -- for 1.dot check way
        -- Improve Garrote: Apply or Refresh Improved Garrotes as a final check
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( ( not TargetHasDebuff(ids.Garrote) or NearbyUnenhancedGarroted > 0 ) or IsAuraRefreshable(ids.Garrote) ) and MaxComboPoints - EffectiveComboPoints >= 1 + 2 * (IsPlayerSpell(ids.ShroudedSuffocationTalent) and 1 or 0) ) then
            KTrig("Garrote") return true end

        -- Kichi modify for simc fixed
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and MaxComboPoints - EffectiveComboPoints >= 1 + 2 * (IsPlayerSpell(ids.ShroudedSuffocationTalent) and 1 or 0) and GetRemainingAuraDuration("player", ids.IndiscriminateCarnageBuff) <= FullGCD() and NearbyEnemies > 6 ) then
            KTrig("Garrote") return true end

        -- Kichi modify for simc fixed
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and MaxComboPoints - EffectiveComboPoints >= 1 + 2 * (IsPlayerSpell(ids.ShroudedSuffocationTalent) and 1 or 0) and GetRemainingAuraDuration("player", ids.IndiscriminateCarnageBuff) <= FullGCD() and NearbyEnemies <= 6 and GetRemainingSpellCooldown(ids.Vanish) > 17 and not PlayerHasBuff(ids.VanishBuff) ) then
            KTrig("Garrote") return true end            


    end
    
    -- Stealth Cooldowns Vanish Sync for Improved Garrote with Deathmark
    local Vanish = function()
        -- Vanish to fish for Fateful Ending
        if OffCooldown(ids.Vanish) and ( TargetHasDebuff(ids.DeathmarkDebuff) and (PlayerHasBuff(ids.ColdBloodBuff1) or PlayerHasBuff(ids.ColdBloodBuff2)) and GetPlayerStacks(ids.FateboundCoinTailsBuff) >= 1 and GetPlayerStacks(ids.FateboundCoinHeadsBuff) >= 1 ) then
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
        
        -- Vanish for cleaving Improved Garrotes with Indiscriminate Carnage
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.IndiscriminateCarnageTalent) and IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and NearbyEnemies > 2 and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Vanish) > 15  ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish fallback for Master Assassin during Deathmark
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.MasterAssassinTalent) and TargetHasDebuff(ids.Deathmark) and GetRemainingDebuffDuration("target", ids.Kingsbane) <= 6 + 3 * (IsPlayerSpell(ids.SubterfugeTalent) and 2 or 0) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish fallback for Improved Garrote during Deathmark if no add waves are expected
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and ( TargetHasDebuff(ids.Deathmark) )  ) then   
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
        Variables.DeathmarkKingsbaneCondition = GetRemainingSpellCooldown(ids.Kingsbane) <= 2 and PlayerHasBuff(ids.EnvenomBuff)
        
        -- Deathmark to be used if not stealthed, Rupture is up, and all other talent conditions are satisfied
        Variables.DeathmarkCondition = TargetHasDebuff(ids.RuptureDebuff) and ( Variables.DeathmarkKingsbaneCondition or NearbyEnemies > 1 and GetRemainingAuraDuration("player", ids.SliceAndDiceBuff) > 5 or not IsPlayerSpell(ids.KingsbaneTalent) and TargetHasDebuff(ids.CrimsonTempestDebuff) ) and not TargetHasDebuff(ids.DeathmarkDebuff)
        
        -- Kichi change condition, swap Deathmark and Shiv sequence for simc fixed
        -- Check for Applicable Shiv usage
        if not TargetHasDebuff(ids.ShivDebuff) and ( not PlayerHasBuff(ids.DarkestNightBuff) and NearbyEnemies < 2 or PlayerHasBuff(ids.DarkestNightBuff) and NearbyEnemies > 1 ) then
            if Shiv() then 
                -- return true end
                if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                    return true
                end
            end
        end

        -- Kichi change condition, swap Deathmark and Shiv sequence for simc fixed
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

        -- Kichi change condition, swap Deathmark and Shiv sequence for simc fixed
        -- Check for Applicable Shiv usage
        if not TargetHasDebuff(ids.ShivDebuff) and not PlayerHasBuff(ids.DarkestNightBuff) and NearbyEnemies > 1 then
            if Shiv() then 
                -- return true end
                if aura_env.config[tostring(ids.Shiv)] == true and aura_env.FlagKTrigCD then
                elseif aura_env.config[tostring(ids.Shiv)] ~= true then
                    return true
                end
            end
        end

        if OffCooldown(ids.Kingsbane) and ( ( TargetHasDebuff(ids.ShivDebuff) or GetRemainingSpellCooldown(ids.Shiv) < 6 ) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and ( GetRemainingSpellCooldown(ids.Deathmark) >= 50 - 15 * ( (SetPieces >= 4 and IsPlayerSpell(ids.HandOfFateTalent)) and 1 or 0 ) or TargetHasDebuff(ids.Deathmark) ) or FightRemains(60, NearbyRange) <= 15 ) then
            -- KTrig("Kingsbane") return true end
            if aura_env.config[tostring(ids.Kingsbane)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kingsbane")
            elseif aura_env.config[tostring(ids.Kingsbane)] ~= true then
                KTrig("Kingsbane")
                return true
            end
        end
        
        if not IsStealthed and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 or IsPlayerSpell(ids.IndiscriminateCarnageTalent) and not IsPlayerSpell(ids.ImprovedGarroteTalent) and not Variables.ScentSaturation and NearbyRuptured < NearbyEnemies and NearbyEnemies >= 3 then
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
    if IsStealthed or PlayerHasBuff(ids.IndiscriminateCarnageBuff) or HasImprovedGarroteBuff or abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) > 0 then
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
    KTrigCD("Clear")

end



----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED

function(event, _, subEvent, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellID)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then 
        aura_env.PrevCast = spellID 
        if spellID == aura_env.ids.Envenom then
            if IsPlayerSpell(aura_env.ids.TwistTheKnifeTalent) and aura_env.Envenom1 < GetTime() then
                aura_env.Envenom1 = aura_env.Envenom1
                aura_env.Envenom2 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            else
                aura_env.Envenom1 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            end
        elseif spellID == aura_env.ids.CrimsonTempest then
            local NearbyEnemies = 0
            for i = 1, 40 do
                local unit = "nameplate"..i
                if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, 10, "<=") then
                    NearbyEnemies = NearbyEnemies + 1
                end
            end
            aura_env.LastCrimsonTempestCount = min(NearbyEnemies, 5)
        end
    end
    
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
        if spellID == aura_env.ids.Garrote then
            local Multiplier = (aura_env.PlayerHasBuff(392403) or aura_env.PlayerHasBuff(392401)) and 1.5 or 1
            
            aura_env.GarroteSnapshots[targetGUID] = Multiplier
        elseif spellID == aura_env.ids.CrimsonTempestDebuff then
            aura_env.CrimsonTempestSnapshots[targetGUID] = aura_env.LastCrimsonTempestCount
        end
    end

    -- Kichi --
    if subEvent == "SPELL_AURA_REMOVED" then 
        if spellID == aura_env.ids.Garrote then
            aura_env.GarroteSnapshots[targetGUID] = nil
        end
    end

end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Nameplate Load----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- Kichi --
aura_env.ShouldShowDebuff = function(unit)
    if (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.KLIST then
            for _, ID in ipairs(_G.KLIST.AssassinationRogue) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    return false
                end
            end
        end
        
        return true
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Nameplate Trig----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED, UNIT_THREAT_LIST_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED

function(allstates, event, Unit, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID)
    
    if event == "UNIT_THREAT_LIST_UPDATE" and Unit:find("nameplate") then
        if aura_env.ShouldShowDebuff(Unit) and not allstates[Unit] then
            allstates[Unit] = {
                show = true,
                changed = true,
                icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                unit = Unit
            }
            return true
        end
    end
    
    if event == "NAME_PLATE_UNIT_ADDED" then
        if Unit:find("nameplate") and aura_env.ShouldShowDebuff(Unit) and not allstates[Unit] then
            allstates[Unit] = {
                show = true,
                changed = true,
                icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                unit = Unit
            }
            return true
        end
    end
    
    if event == "NAME_PLATE_UNIT_REMOVED" then
        if allstates[Unit] then
            allstates[Unit] = {
                show = false,
                changed = true
            }
            return true
        end
    end
    
    if subEvent == "SPELL_AURA_APPLIED" then
        if sourceGUID == UnitGUID("player") and spellID == aura_env.config["DebuffID"] then
            local UnitToken = UnitTokenFromGUID(destGUID)
            if UnitToken ~= nil and UnitToken:find("nameplate") then
                allstates[UnitToken] = {
                    show = false,
                    changed = true,
                }
                return true
            end
        end
    elseif subEvent == "SPELL_AURA_REMOVED" then
        if sourceGUID == UnitGUID("player") then
            local UnitToken = UnitTokenFromGUID(destGUID)
            if UniToken ~= nil and UnitToken:find("nameplate") and aura_env.ShouldShowDebuff(UnitToken) and not allstates[UnitToken] then
                allstates[UnitToken] = {
                    show = true,
                    changed = true,
                    icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                    unit = UnitToken
                }
                return true
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.NearbyGarroted = 0
aura_env.MissingGarrote = 0
aura_env.NearbyRuptured = 0
aura_env.MissingRupture = 0

WeakAuras.WatchGCD()

-- Kichi --
_G.KLIST = { 
    AssassinationRogue = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

aura_env.GarroteSnapshots = {}
aura_env.CrimsonTempestSnapshots = {}
aura_env.LastCrimsonTempestCount = 0
aura_env.Envenom1 = 0
aura_env.Envenom2 = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Ambush = 8676,
    ColdBlood1 = 382245, -- Kichi add for different id
    ColdBlood2 = 456330, -- Kichi add for different id
    CrimsonTempest = 121411,
    Deathmark = 360194,
    EchoingReprimand = 385616,
    Envenom = 32645,
    FanOfKnives = 51723,
    Garrote = 703,
    Kingsbane = 385627,
    Mutilate = 1329,
    Rupture = 1943,
    Shiv = 5938,
    SliceAndDice = 315496,
    ThistleTea = 381623,
    Vanish = 1856,
    
    -- Talents
    AmplifyingPoisonTalent = 381664,
    ArterialPrecisionTalent = 400783,
    BlindsideTalent = 328085,
    CausticSpatterTalent = 421975,
    DarkestNightTalent = 457058,
    DashingScoundrelTalent = 381797,
    DeathstalkersMarkTalent = 457052,
    HandOfFateTalent = 452536,
    ImprovedGarroteTalent = 381632,
    IndiscriminateCarnageTalent = 381802,
    InevitabileEndTalent = 454434,
    KingsbaneTalent = 385627,
    LightweightShivTalent = 394983,
    MasterAssassinTalent = 255989,
    MomentumOfDespairTalent = 457067,
    PoisonBombTalent = 255544,
    ScentOfBloodTalent = 381799,
    ShroudedSuffocationTalent = 385478,
    SubterfugeTalent = 108208,
    ThrownPrecisionTalent = 381629,
    ViciousVenomsTalent = 381634,
    TwistTheKnifeTalent = 381669,
    ZoldyckRecipeTalent = 381798,
    SuddenDemiseTalent = 423136,
    ForcedInductionTalent = 470668,
    
    -- Auras
    AmplifyingPoisonDebuff = 383414,
    BlindsideBuff = 121153,
    CausticSpatterDebuff = 421976,
    ClearTheWitnessesBuff = 457178,
    ColdBloodBuff1 = 382245, -- Kichi add for different id
    ColdBloodBuff2 = 456330, -- Kichi add for different id
    CrimsonTempestDebuff = 121411, 
    DarkestNightBuff = 457280,
    DeadlyPoisonDebuff = 2818,
    DeathstalkersMarkDebuff = 457129,
    DeathmarkDebuff = 360194,
    EnvenomBuff = 32645,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    GarroteDebuff = 703,
    IndiscriminateCarnageBuff = 385747,
    KingsbaneDebuff = 385627,
    LingeringDarknessBuff = 457273,
    MasterAssassinBuff = 256735,
    MomentumOfDespairBuff = 457115,
    VanishBuff = 11327,
    RuptureDebuff = 1943,
    ScentOfBloodBuff = 394080,
    SliceAndDiceBuff = 315496,
    ShivDebuff = 319504,
    SubterfugeBuff = 115192,
    StealthBuff = 1784,
    ThistleTeaBuff = 381623,
}




aura_env.GetSpellCooldown = function(spellId)
    local spellCD = C_Spell.GetSpellCooldown(spellId)
    local spellCharges = C_Spell.GetSpellCharges(spellId)
    if spellCharges then
        local rechargeTime = (spellCharges.currentCharges < spellCharges.maxCharges) and (spellCharges.cooldownStartTime + spellCharges.cooldownDuration - GetTime()) or 0
        return spellCharges.currentCharges, rechargeTime, spellCharges.maxCharges
    elseif spellCD then
        local remainingCD = (spellCD.startTime and spellCD.duration) and math.max(spellCD.startTime + spellCD.duration - GetTime(), 0) or 0
        return 0, remainingCD, 0
    else
        return 0, 0, 0
    end
end

aura_env.GetSafeSpellIcon = function(spellId)
    if not spellId or spellId == 0 then
        return 0  
    end
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    return spellInfo and spellInfo.iconID or 0
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Trig ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function(allstates, event, spellID, customData)
    
    local ids = aura_env.ids
    local GetSpellCooldown = aura_env.GetSpellCooldown
    local GetSafeSpellIcon = aura_env.GetSafeSpellIcon
    local firstPriority = nil
    local firstIcon = 0
    local firstCharges, firstCD, firstMaxCharges = 0, 0, 0

    if spellID and spellID ~= "Clear" then
        -- print(spellID)
        local key = spellID:gsub(" (%a)", function(c) return c:upper() end):gsub(" ", "")
        firstPriority = ids[key]
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end

    if spellID == "Clear" then
        firstIcon = 0
        firstCharges, firstCD, firstMaxCharges = 0, 0, 0
    end
    -- 更新 allstates
    allstates[1] = {
        show = true,
        changed = true,
        icon = firstIcon,
        spell = firstPriority,
        cooldown = firstCD,
        charges = firstCharges,
        maxCharges = firstMaxCharges
    }
    
    return true
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Trig3------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- K_GARROTE_DATA

function(event, NearbyGarroted, NearbyEnemies)
    aura_env.NearbyGarroted = NearbyGarroted
    aura_env.MissingGarrote = NearbyEnemies - NearbyGarroted
    return true
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Trig4------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- K_RUPTURE_DATA

function(event, NearbyRuptured, NearbyEnemies)
    aura_env.NearbyRuptured = NearbyRuptured
    aura_env.MissingRupture = NearbyEnemies - NearbyRuptured
    return true
end
