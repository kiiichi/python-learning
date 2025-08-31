WeakAuras.WatchGCD()
aura_env.FurtherEnemies = 0
aura_env.NearbyEnemies = 0

---@class idsTable
aura_env.ids = {
    
    -- Abilities
    AdrenalineRush = 13750,
    Ambush = 8676,
    BetweenTheEyes = 315341,
    BladeFlurry = 13877,
    BladeRush = 271877,
    ColdBlood = 382245,
    CoupDeGrace = 441776,
    Dispatch = 2098,
    EchoingReprimand = 385616,
    GhostlyStrike = 196937,
    KeepItRolling = 381989,
    KillingSpree = 51690,
    MarkedForDeath = 137619,
    PistolShot = 185763,
    RollTheBones = 315508,
    Shadowmeld = 135201,
    SinisterStrike = 193315,
    SliceAndDice = 315496,
    ThistleTea = 381623,
    Vanish = 1856,
    
    -- Talents
    CoupDeGraceTalent = 441423,
    CrackshotTalent = 423703,
    DeftManeuversTalent = 381878,
    DisorientingStrikesTalent = 441274,
    DoubleJeopardyTalent = 454430,
    FanTheHammerTalent = 381846,
    FanTheHammerTalentNode = 90666,
    FatefulEndingTalent = 454428,
    FlawlessFormTalent = 441321,
    GreenskinsWickersTalent = 386823,
    HandOfFateTalent = 452536,
    HiddenOpportunityTalent = 383281,
    ImprovedAdrenalineRushTalent = 395422,
    ImprovedAmbushTalent = 381620,
    ImprovedBetweenTheEyesTalent = 235484,
    KeepItRollingTalent = 381989,
    KillingSpreeTalent = 51690,
    LoadedDiceTalent = 256170,
    MeanStreakTalent = 453428,
    NimbleFlurryTalent = 441367,
    QuickDrawTalent = 196938,
    RuthlessnessTalent = 14161,
    SealFateTalent = 14190,
    SleightOfHandTalent = 381839,
    SubterfugeTalent = 108208,
    SuperchargerTalent = 470347,
    SurprisingStrikesTalent = 441273,
    TakeEmBySurpriseTalent = 382742,
    UnderhandedUpperHandTalent = 424044,
    UnseenBladeTalent = 441146,
    WithoutATraceTalent = 382513,
    
    -- Buffs
    AdrenalineRushBuff = 13750,
    AudacityBuff = 386270,
    BetweenTheEyesBuff = 315341,
    BroadsideBuff = 193356,
    BuriedTreasureBuff = 199600,
    EscalatingBladeBuff = 441786,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    GrandMeleeBuff = 193358,
    GreenskinsWickersBuff = 394131,
    LoadedDiceBuff = 256171,
    OpportunityBuff = 195627,
    RuthlessPrecisionBuff = 193357,
    SkullAndCrossbonesBuff = 199603,
    Stealth = 115191,
    SubterfugeBuff = 115192,
    TakeEmBySurpriseBuff = 385907,
    TrueBearingBuff = 193359,
    VanishBuff = 11327,
    -- Kichi -- 
    KillingSpreeBuff = 51690,
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
