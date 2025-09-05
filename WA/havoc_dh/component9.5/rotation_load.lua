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
