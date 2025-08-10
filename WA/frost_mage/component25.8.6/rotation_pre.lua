---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneExplosion = 1449,
    Blizzard = 190356,
    CometStorm = 153595,
    ConeOfCold = 120,
    Flurry = 44614,
    Freeze = 33395,
    FrostNova = 122,
    FrostfireBolt = 431044,
    FrozenOrb = 84714,
    Frostbolt = 116,
    GlacialSpike = 199786,
    IceLance = 30455,
    IceNova = 157997,
    IcyVeins = 12472,
    RayOfFrost = 205021,
    ShiftingPower = 382440,
    
    -- Talents
    ColdestSnapTalent = 417493,
    ColdFrontTalent = 382110,
    CometStormTalent = 153595,
    DeathsChillTalent = 450331,
    DeepShatterTalent = 378749,
    ExcessFrostTalent = 438611,
    FreezingRainTalent = 270233,
    FreezingWindsTalent = 382103,
    FrostfireBoltTalent = 431044,
    FrozenTouchTalent = 205030,
    GlacialSpikeTalent = 199786,
    IceCallerTalent = 236662,
    IsothermicCoreTalent = 431095,
    RayOfFrostTalent = 205021,
    SlickIceTalent = 382144,
    SplinteringColdTalent = 379049,
    SplinteringRayTalent = 418733,
    SplinterstormTalent = 443742,
    UnerringProficiencyTalent = 444974,
    
    -- Buffs
    BrainFreezeBuff = 190446,
    DeathsChillBuff = 454371,
    ExcessFireBuff = 438624,
    ExcessFrostBuff = 438611,
    FingersOfFrostBuff = 44544,
    FreezingRainBuff = 270232,
    FrostfireEmpowermentBuff = 431177,
    IciclesBuff = 205473,
    IcyVeinsBuff = 12472,
    SpymastersWebBuff = 444959,
    WintersChillDebuff = 228358,
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

