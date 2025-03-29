---@class idsTable
aura_env.ids = {
    -- Abilities
    AvengingWrath = 31884,
    ExecutionSentence = 343527,
    TemplarsVerdict = 85256,
    FinalVerdict = 383328,
    WakeOfAshes = 255937,
    DivineToll = 375576,
    HammerOfWrath = 24275,
    TemplarSlash = 406647,
    TemplarStrike = 407480,
    BladeOfJustice = 184575,
    Judgment = 20271,
    FinalReckoning = 343721,
    DivineStorm = 53385,
    DivineHammer = 198034,
    Crusade = 231895,
    JusticarsVengeance = 215661,
    CrusaderStrike = 35395,
    HammerOfLight = 427453,
    
    -- Talents
    BladeOfVengeanceTalent = 403826,
    BlessedChampionTalent = 403010,
    BoundlessJudgmentTalent = 405278,
    CrusadingStrikesTalent = 404542,
    DivineAuxiliaryTalent = 406158,
    ExecutionersWillTalent = 406940,
    HolyBladeTalent = 383342,
    HolyFlamesTalent = 406545,
    LightsGuidanceTalent = 427445,
    RadiantGloryTalent = 458359,
    TempestOfTheLightbringerTalent = 383396,
    TemplarStrikesTalent = 406646,
    VanguardsMomentumTalent = 383314,
    VengefulWrathTalent = 406835,
    
    -- Buffs/Debuffs
    AllInBuff = 1216837,
    AvengingWrathBuff = 31884,
    BlessingOfAnsheBuff = 445206,
    CrusadeBuff = 231895,
    DivineArbiterBuff = 406975,
    DivineHammerBuff = 198034,
    DivineResonanceBuff = 384029,
    EmpyreanLegacyBuff = 387178,
    EmpyreanPowerBuff = 326733,
    ExpurgationDebuff = 383346,
    JudgmentDebuff = 197277,
    RadiantGloryAvangeningWrathBuff = 454351,
    RadiantGloryCrusadeBuff = 454373,
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
