---@class idsTable
aura_env.ids = {
    -- Abilities
    AimedShot = 19434,
    ArcaneShot = 185358,
    BlackArrow = 466930,
    ExplosiveShot = 212431,
    KillShot = 53351,
    Multishot = 257620,
    RapidFire = 257044,
    SteadyShot = 56641,
    Trueshot = 288613,
    Volley = 260243,
    
    -- Talents
    AspectOfTheHydraTalent = 470945,
    BlackArrowTalent = 466932,
    BulletstormTalent = 389019,
    DoubleTapTalent = 473370,
    HeadshotTalent = 471363,
    LunarStormTalent = 450385,
    NoScopeTalent = 473385,
    PrecisionDetonationTalent = 471369,
    RazorFragmentsTalent = 384790,
    SentinelTalent = 450369,
    SmallGameHunterTalent = 459802,
    SymphonicArsenalTalent = 450383,
    TrickShotsTalent = 257621,
    VolleyTalent = 260243,
    WindrunnerQuiverTalent = 473523,
    
    -- Buffs/Debuffs
    BulletstormBuff = 389020,
    DoubleTapBuff = 260402,
    LockAndLoadBuff = 194594,
    LunarStormCooldownBuff = 451803,
    LunarStormReadyBuff = 451805,
    MovingTargetBuff = 474293,
    PreciseShotsBuff = 260242,
    RazorFragmentsBuff = 388998,
    SpottersMarkDebuff = 466872,
    TrickShotsBuff = 257622,
    TrueshotBuff = 288613,
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
