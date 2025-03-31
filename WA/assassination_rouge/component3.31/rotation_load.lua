aura_env.NearbyGarroted = 0
aura_env.MissingGarrote = 0
aura_env.NearbyRuptured = 0
aura_env.MissingRupture = 0

---@class idsTable
aura_env.ids = {
    -- Abilities
    Ambush = 8676,
    ColdBlood = 382245,
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
    DashingScoundrelTalent = 381797,
    DeathstalkersMarkTalent = 457052,
    HandOfFateTalent = 452536,
    ImprovedGarroteTalent = 381632,
    IndiscriminateCarnageTalent = 381802,
    KingsbaneTalent = 385627,
    LightweightShivTalent = 394983,
    MasterAssassinTalent = 255989,
    MomentumOfDespairTalent = 457067,
    ScentOfBloodTalent = 381799,
    ShroudedSuffocationTalent = 385478,
    SubterfugeTalent = 108208,
    ThrownPrecisionTalent = 381629,
    ViciousVenomsTalent = 381634,
    TwistTheKnifeTalent = 381669,
    SuddenDemiseTalent = 423136,
    
    -- Auras
    AmplifyingPoisonDebuff = 383414,
    BlindsideBuff = 121153,
    CausticSpatterDebuff = 421976,
    ClearTheWitnessesBuff = 457178,
    CrimsonTempestDebuff = 121411,
    DarkestNightBuff = 457280,
    DeadlyPoisonDebuff = 2818,
    DeathstalkersMarkDebuff = 457129,
    EnvenomBuff = 32645,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    IndiscriminateCarnageBuff = 385747,
    KingsbaneDebuff = 385627,
    LingeringDarknessBuff = 457273,
    MasterAssassinBuff = 256735,
    MomentumOfDespairBuff = 457115,
    VanishBuff = 11327,
    ScentOfBloodBuff = 394080,
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
