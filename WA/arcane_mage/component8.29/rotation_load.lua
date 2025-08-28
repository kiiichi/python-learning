WeakAuras.WatchGCD()

---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneBarrage = 44425,
    ArcaneBlast = 30451,
    ArcaneExplosion = 1449,
    ArcaneMissiles = 5143,
    ArcaneOrb = 153626,
    ArcaneSurge = 365350,
    Evocation = 12051,
    PresenceOfMind = 205025,
    ShiftingPower = 382440,
    Supernova = 157980,
    TouchOfTheMagi = 321507,
    
    -- Talents
    ArcaneBombardmentTalent = 384581,
    ArcaneHarmonyTalent = 384452,
    ArcaneTempoTalent = 383980,
    ArcingCleaveTalent = 231564,
    ChargedOrbTalent = 384651,
    ConsortiumsBaubleTalent = 461260,
    EnlightenedTalent = 321387,
    HighVoltageTalent = 461248,
    ImpetusTalent = 383676,
    LeydrinkerTalent = 452196,
    MagisSparkTalent = 454016,
    OrbBarrageTalent = 384858,
    ResonanceTalent = 205028,
    ReverberateTalent = 281482,
    ShiftingShardsTalent = 444675,
    SpellfireSpheresTalent = 448601,
    SplinteringSorceryTalent = 443739,
    TimeLoopTalent = 452924,
    
    -- Buffs
    AetherAttunementBuff = 453601,
    AethervisionBuff = 467634,
    ArcaneHarmonyBuff = 384455,
    ArcaneSoulBuff = 451038,
    ArcaneSurgeBuff = 365362,
    ArcaneTempoBuff = 383997,
    BurdenOfPowerBuff = 451049,
    ClearcastingBuff = 263725,
    GloriousIncandescenceBuff = 451073,
    -- Kichi fix this id beacause it is wrong --
    IntuitionBuff = 1223797,
    LeydrinkerBuff = 453758,
    NetherPrecisionBuff = 383783,
    SiphonStormBuff = 384267,
    SpellfireSpheresBuff = 448604,
    TouchOfTheMagiDebuff = 210824,
    UnerringProficiencyBuff = 444981,
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
