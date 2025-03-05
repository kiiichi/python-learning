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
