aura_env.NearbyEnemies = 0

---@class idsTable
aura_env.ids = {
    -- Abilities
    AstralCommunion = 400636,
    CelestialAlignment = 194223,
    CelestialAlignmentCooldown = 383410,
    ConvokeTheSpirits = 391528,
    ForceOfNature = 205636,
    FullMoon = 274283,
    FuryOfElune = 202770,
    HalfMoon = 274282,
    Incarnation = 102560,
    Moonfire = 8921,
    NewMoon = 274281,
    Starfall = 191034,
    Starfire = 194153,
    Starsurge = 78674,
    StellarFlare = 202347,
    Sunfire = 93402,
    WarriorOfElune = 202425,
    WildMushroom = 88747,
    Wrath = 190984,
    
    -- Talents
    AetherialKindlingTalent = 327541,
    AstralSmolderTalent = 394058,
    BoundlessMoonlightTalent = 424058,
    ControlOfTheDreamTalent = 434249,
    DreamSurgeTalent = 433831,
    EarlySpringTalent = 428937,
    GreaterAlignmentTalent = 450184,
    IncarnationTalent = 102560,
    LunarCallingTalent = 429523,
    NaturesBalanceTalent = 202430,
    NaturesGraceTalent = 450347,
    OrbitBreakerTalent = 383197,
    OrbitalStrikeTalent = 390378,
    PowerOfTheDreamTalent = 434220,
    SoulOfTheForestTalent = 114107,
    StarlordTalent = 202345,
    TreantsOfTheMoonTalent = 428544,
    UmbralEmbraceTalent = 393760,
    UmbralIntensityTalent = 383195,
    WhirlingStarsTalent = 468743,
    WildSurgesTalent = 406890,
    
    -- Buffs/Debuffs
    BalanceOfAllThingsArcaneBuff = 394050,
    BalanceOfAllThingsNatureBuff = 394049,
    CelestialAlignmentOrbitalStrikeBuff = 383410,
    CelestialAlignmentBuff = 194223,
    DreamstateBuff = 450346,
    FungalGrowthDebuff = 81281,
    IncarnationOrbitalStrikeBuff = 390414,
    IncarnationBuff = 102560,
    EclipseLunarBuff = 48518,
    EclipseSolarBuff = 48517,
    HarmonyOfTheGroveBuff = 428735,
    MoonfireDebuff = 164812,
    SolsticeBuff = 343648,
    StarlordBuff = 279709,
    StarweaversWarpBuff = 393942,
    StarweaversWeftBuff = 393944,
    SunfireDebuff = 164815,
    TouchTheCosmosBuff = 450360,
    UmbralEmbraceBuff = 393763,
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