WeakAuras.WatchGCD()

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Ascendance = 114051,
    ChainLightning = 188443,
    CrashLightning = 187874,
    DoomWinds = 384352,
    ElementalBlast = 117014,
    FeralSpirit = 51533,
    FireNova = 333974,
    FlameShock = 470411,
    FrostShock = 196840,
    FrostShockIceStrike = 342240,
    IceStrike = 470194,
    LavaBurst = 51505,
    LavaLash = 60103,
    LightningBolt = 188196,
    PrimordialWave = 375982,
    PrimordialStorm = 1218090,
    Stormstrike = 17364,
    Sundering = 197214,
    SurgingTotem = 444995,
    Tempest = 452201,
    VoltaicBlaze = 470057,
    Windstrike = 115356,
    
    -- Talents
    AlphaWolfTalent = 198434,
    AscendanceTalent = 114051,
    AshenCatalystTalent = 390370,
    AwakeningStormsTalent = 455129,
    ConvergingStormsTalent = 384363,
    CrashingStormsTalent =  334308,
    DeeplyRootedElementsTalent = 378270,
    DoomWindsTalent = 384352,
    EarthsurgeTalent = 455590,
    ElementalAssaultTalent = 210853,
    ElementalSpiritsTalent = 262624,
    FeralSpiritTalent = 51533,
    FireNovaTalent = 333974,
    FlowingSpiritsTalent = 469314,
    HailstormTalent = 334195,
    LashingFlamesTalent = 334046,
    LegacyOfTheFrostWitchTalent = 384450,
    MoltenAssaultTalent = 334033,
    OverflowingMaelstromTalent = 384149,
    PrimordialWaveTalent = 375982,
    PrimordialStormTalent = 1218047,
    RagingMaelstromTalent = 384143,
    StaticAccumulation = 384411,
    StormblastTalent = 319930,
    StormflurryTalent = 344357,
    SuperchargeTalent = 455110,
    SurgingTotemTalent = 444995,
    SwirlingMaelstromTalent = 384359,
    TempestTalent = 454009,
    ThorimsInvocationTalent = 384444,
    TotemicRebound = 445025,
    UnrelentingStormsTalent = 470490,
    UnrulyWindsTalent = 390288,
    VoltaicBlazeTalent = 470053,
    WitchDoctorsAncestryTalent = 384447,
    
    -- Buffs
    ArcDischargeBuff = 455097,
    AscendanceBuff = 114051,
    AshenCatalystBuff = 390371,
    AwakeningStormsBuff = 462131,
    ClCrashLightningBuff = 333964,
    ConvergingStormsBuff = 198300,
    CracklingSurgeBuff = 224127,
    CrashLightningBuff = 187878,
    DoomWindsBuff = 466772,
    EarthenWeaponBuff = 392375,
    ElectrostaticWagerBuff = 1223410,
    FeralSpiritBuff = 333957,
    FlameShockDebuff = 188389,
    HailstormBuff = 334196,
    HotHandBuff = 215785,
    IceStrikeBuff = 384357,
    IcyEdgeBuff = 224126,
    LashingFlamesDebuff = 334168,
    LegacyOfTheFrostWitchBuff = 384451,
    LightningRodDebuff = 197209,
    LivelyTotemsBuff = 461242,
    MaelstromWeaponBuff = 344179,
    MoltenWeaponBuff = 224125,
    PrimordialWaveBuff = 375986,
    PrimordialStormBuff = 1218125,
    SplinteredElementsBuff = 382043,
    StormblastBuff = 470466,
    StormsurgeBuff = 201846,
    TempestBuff = 454015,
    TotemicReboundBuff = 458269,
    VolcanicStrengthBuff = 409833,
    WhirlingAirBuff = 453409,
    WhirlingEarthBuff = 453406,
    WhirlingFireBuff = 453405,
}

aura_env.LastTISpell = aura_env.ids.LightningBolt
aura_env.TempestMaelstromCount = 0
aura_env.SavedMaelstrom = 0
aura_env.MinAlphaWolf = 0
aura_env.LightningBoltLastUsed = 0
aura_env.ChainLightningLastUsed = 0
aura_env.TempestLastUsed = 0
aura_env.LavaLashLastUsed = 0
aura_env.StormstrikeLastUsed = 0
aura_env.WindstrikeLastUsed = 0

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
    
    local Duration = C_Spell.GetSpellCooldown(spellID).duration
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    if not OffCooldown then return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    if InRange == 0 then
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

aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    return aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
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

aura_env.IsAuraRefreshable = function(SpellID, Unit)
    local Filter = ""
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
aura_env.PetHasBuff = function(spellID)
    return WA_GetUnitBuff("pet", spellID) ~= nil
end

aura_env.TargetHasDebuff = function(spellID)
    return WA_GetUnitDebuff("target", spellID, "PLAYER|HARMFUL") ~= nil
end
