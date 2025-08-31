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
