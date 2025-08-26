WeakAuras.WatchGCD()

aura_env.DemonsurgeAbyssalGazeBuff = false
aura_env.DemonsurgeAnnihilationBuff = false
aura_env.DemonsurgeConsumingFireBuff = false
aura_env.DemonsurgeDeathSweepBuff = false
aura_env.DemonsurgeSigilOfDoomBuff = false
aura_env.ReaversGlaiveLastUsed = 0
aura_env.LastDeathSweep = 999999999

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbyssalGaze = 452497,
    Annihilation = 201427,
    BladeDance = 188499,
    ConsumingFire = 452487,
    ChaosStrike = 162794,
    DeathSweep = 210152,
    DemonsBite = 162243,
    EssenceBreak = 258860,
    EyeBeam = 198013,
    FelBarrage = 258925,
    FelRush = 195072,
    Felblade = 232893,
    GlaiveTempest = 342817,
    ImmolationAura = 258920,
    Metamorphosis = 191427,
    ReaversGlaive = 442294,
    SigilOfDoom = 452490,
    SigilOfFlame = 204596,
    SigilOfSpite = 390163,
    TheHunt = 370965,
    ThrowGlaive = 185123,
    VengefulRetreat = 198793,
    
    -- Talents
    AFireInsideTalent = 427775,
    ArtOfTheGlaiveTalent = 442290,
    BlindFuryTalent = 203550,
    BurningWoundTalent = 391189,
    ChaosTheoryTalent = 389687,
    ChaoticTransformationTalent = 388112,
    CycleOfHatredTalent = 258887,
    DemonBladesTalent = 203555,
    DemonicTalent = 213410,
    DemonsurgeTalent = 452402,
    EssenceBreakTalent = 258860,
    ExergyTalent = 206476,
    FelBarrageTalent = 258925,
    FlameboundTalent = 452413,
    FlamesOfFuryTalent = 389694,
    FuriousThrowsTalent = 393029,
    InertiaTalent = 427640,
    InitiativeTalent = 388108,
    IsolatedPreyTalent = 388113,
    LooksCanKillTalent = 320415,
    QuickenedSigilsTalent = 209281,
    RagefireTalent = 388107,
    RestlessHunterTalent = 390142,
    ScreamingBrutalityTalent = 1220506,
    ShatteredDestinyTalent = 388116,
    SoulscarTalent = 388106,
    StudentOfSufferingTalent = 452412,
    TacticalRetreatTalent = 389688,
    UnboundChaosTalent = 347461,
    
    -- Auras
    ChaosTheoryBuff = 390195,
    CycleOfHatredBuff = 1214887,
    DemonSoulTww3Buff = 1238676,
    DemonsurgeBuff = 452416,
    EssenceBreakDebuff = 320338,
    ExergyBuff = 208628,
    FelBarrageBuff = 258925,
    GlaiveFlurryBuff = 442435,
    ImmolationAuraBuff = 258920,

    ImmolationAuraBuff1 = 427910, -- Kichi add...
    ImmolationAuraBuff2 = 427911,
    ImmolationAuraBuff3 = 427912,
    ImmolationAuraBuff4 = 427913,
    ImmolationAuraBuff5 = 427914,
    ImmolationAuraBuff6 = 427915,
    ImmolationAuraBuff7 = 427916,
    ImmolationAuraBuff8 = 427917,

    InertiaBuff = 1215159,
    InertiaTriggerBuff = 427641,
    InitiativeBuff = 391215,
    InnerDemonBuff = 390145,
    MetamorphosisBuff = 162264,
    NecessarySacrificeBuff = 1217055,
    ReaversMarkDebuff = 442624,
    RendingStrikeBuff = 442442,
    StudentOfSufferingBuff = 453239,
    TacticalRetreatBuff = 389890,
    ThrillOfTheFightDamageBuff = 442688, -- Kichi fix because NG‘s wrong
    ThrillOfTheFightSpeedBuff = 442695, -- Kichi add
    UnboundChaosBuff = 347462,
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
    if (not usable) or nomana then return false end
    
    -- Kichi --
    -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Duration = Cooldown.duration
    local Remaining = Cooldown.startTime + Duration - GetTime()

    -- Kichi updata 25.8.26
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75))

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

aura_env.OffCooldownNotCasting = function(spellID)
    return aura_env.OffCooldown(spellID) and not aura_env.IsCasting(spellID)
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
    local FullGCDnum = math.max(1, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end

aura_env.StartTimeFromCooldown = function(spellID)
    local StartTime = C_Spell.GetSpellCooldown(spellID).startTime
    if StartTime == 0  then
        return 99999
    end
    local LeftTime = GetTime() - StartTime
    if LeftTime <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) then
        return 99999
    end
    return LeftTime
end
