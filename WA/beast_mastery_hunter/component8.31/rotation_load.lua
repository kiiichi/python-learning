---@class idsTable
aura_env.ids = {
    ------ Abilities
    CobraShot = 193455,
    BarbedShot = 217200,
    Multishot = 2643,
    BestialWrath = 19574,
    BlackArrow = 466930,
    Bloodshed = 321530,
    DireBeast = 120679,
    CallOfTheWild = 359844,
    KillCommand = 34026,
    KillShot = 53351,
    ExplosiveShot = 212431,
    -- Kichi --
    KillCommandSummon = 34026,  
    
    ------ Talents
    BarbedScalesTalent = 469880,
    BeastCleaveTalent = 115939,
    BlackArrowTalent = 466932,
    BleakPowderTalent = 467911,
    BloodyFrenzyTalent = 407412,
    CullTheHerdTalent = 445717,
    DireCleaveTalent = 1217524,
    FuriousAssaultTalent = 445699,
    HuntmastersCallTalent = 459730,
    KillerCobraTalent = 199532,
    SavageryTalent = 424557,
    ScentOfBloodTalent = 193532,
    ShadowHoundsTalent = 430707,
    ThunderingHoovesTalent = 459693,
    VenomsBiteTalent = 459565,
    WildCallTalent = 185789,
    
    ------ Auras
    BeastCleavePetBuff = 118455,
    BeastCleaveBuff = 268877,
    CallOfTheWildBuff = 359844,
    DeathblowBuff = 378770,
    FrenzyBuff = 272790,
    HogstriderBuff = 472640,
    HowlBearBuff = 472325,
    HowlBoarBuff = 472324,
    HowlWyvernBuff = 471878,
    HuntmastersCallBuff = 459731,
    HuntersPreyBuff = 378215,
    SerpentStingDebuff = 271788,
    WitheringFireBuff = 466991,
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
