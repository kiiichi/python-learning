---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbominationLimb = 383269,
    BreathOfSindragosa = 1249658,
    ChainsOfIce = 45524,
    ChillStreak = 305392,
    DeathAndDecay = 43265,
    EmpowerRuneWeapon = 47568,
    FrostStrike = 49143,
    Frostscythe = 207230,
    FrostwyrmsFury = 279302,
    GlacialAdvance = 194913,
    HornOfWinter = 57330,
    HowlingBlast = 49184,
    Obliterate = 49020,
    PillarOfFrost = 51271,
    RaiseDead = 46585,
    ReapersMark = 439843,
    RemorselessWinter = 196770,
    SoulReaper = 343294,
    
    -- Talents
    AFeastOfSoulsTalent = 444072,
    ApocalypseNowTalent = 444040,
    ArcticAssaultTalent = 456230,
    AvalancheTalent = 207142,
    BindInDarknessTalent = 440031,
    BitingColdTalent = 377056,
    BonegrinderTalent = 377098,
    BreathOfSindragosaTalent = 1249658,
    CleavingStrikesTalent = 316916,
    ColdHeartTalent = 281208,
    DarkTalonsTalent = 436687,
    EmpowerRuneWeaponTalent = 47568,
    EnduringStrengthTalent = 377190,
    FrigidExecutionerTalent = 377073,
    FrostbaneTalent = 455993,
    FrostboundWillTalent = 1238680,
    FrostwyrmsFuryTalent = 279302,
    FrozenDominionTalent = 377226,
    GatheringStormTalent = 194912,
    GlacialAdvanceTalent = 194913,
    IcebreakerTalent = 392950,
    IcyOnslaughtTalent = 1230272,
    IcyTalonsTalent = 194878,
    ImprovedDeathStrikeTalent = 374277,
    KillingStreakTalent = 1230153,
    ObliterationTalent = 281238,
    RageOfTheFrozenChampionTalent = 377076,
    ReaperOfSoulsTalent = 440002,
    ReapersMarkTalent = 439843,
    RidersChampionTalent = 444005,
    ShatteredFrostTalent = 455993,
    ShatteringBladeTalent = 207057,
    SmotheringOffenseTalent = 435005,
    TheLongWinterTalent = 456240,
    UnholyGroundTalent = 374265,
    UnleashedFrenzyTalent = 376905,
    WitherAwayTalent = 441894,
    
    -- Buffs/Debuffs
    AFeastOfSoulsBuff = 440861,
    BonegrinderFrostBuff = 377103,
    BreathOfSindragosaBuff = 1249658,
    ColdHeartBuff = 281209,
    DeathAndDecayBuff = 188290,
    ExterminateBuff = 441416,
    ExterminatePainfulDeathBuff = 447954,
    FrostbaneBuff = 1229310,
    FrostFeverDebuff = 55095,
    GatheringStormBuff = 211805,
    IcyOnslaughtBuff = 1230273,
    IcyTalonsBuff = 194879,
    KillingMachineBuff = 51124,
    MograinesMightBuff = 444505,
    PillarOfFrostBuff = 51271,
    RazoriceDebuff = 51714,
    ReaperOfSoulsBuff = 469172,
    ReapersMarkDebuff = 434765,
    RemorselessWinterBuff = 196770,
    RimeBuff = 59052,
    UnholyStrengthBuff = 53365,
    UnleashedFrenzyBuff = 376907,
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
