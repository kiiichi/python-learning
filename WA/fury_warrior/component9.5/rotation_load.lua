WeakAuras.WatchGCD()

---@class idsTable
aura_env.ids = {
    -- Abilities
    Avatar = 107574,
    Bladestorm = 227847,
    Bloodbath = 335096,
    Bloodthirst = 23881,
    ChampionsSpear = 376079,
    CrushingBlow = 335097,
    Execute = 5308,
    ExecuteMassacre = 280735,
    OdynsFury = 385059,
    Onslaught = 315720,
    RagingBlow = 85288,
    Rampage = 184367,
    Ravager = 228920,
    Recklessness = 1719,
    Slam = 1464,
    ThunderBlast = 435222,
    ThunderClap = 6343,
    ThunderousRoar = 384318,
    Whirlwind = 190411,
    WreckingThrow = 384110,
    
    -- Talents
    AngerManagementTalent = 152278,
    AshenJuggernautTalent = 392536,
    BladestormTalent = 227847,
    BloodborneTalent = 385703,
    ChampionsMightTalent = 386284,
    ExecuteMassacreTalent = 206315,
    ImprovedWhirlwindTalent = 12950,
    LightningStrikesTalent = 434969,
    MassacreTalent = 206315,
    MeatCleaverTalent = 280392,
    RecklessAbandonTalent = 396749,
    SlaughteringStrikesTalent = 388004,
    SlayersDominanceTalent = 444767,
    TenderizeTalent = 388933,
    TitanicRageTalent = 394329,
    TitansTormentTalent = 390135,
    UnhingedTalent = 386628,
    UproarTalent = 391572,
    ViciousContemptTalent = 383885,
    
    -- Buffs/Debuffs
    AshenJuggernautBuff = 392537,
    BloodbathDotDebuff = 113344,
    BloodcrazeBuff = 393951,
    BrutalFinishBuff = 446918,
    BurstOfPowerBuff = 437121,
    ChampionsMightDebuff = 376080,
    EnrageBuff = 184362,
    ImminentDemiseBuff = 445606,
    MarkedForExecutionDebuff = 445584,
    MeatCleaverBuff = 85739,
    OdynsFuryTormentMhDebuff = 385060,
    OpportunistBuff = 456120,
    RavagerBuff = 228920,
    RecklessnessBuff = 1719,
    SlaughteringStrikesBuff = 393931,
    SuddenDeathBuff = 290776,
    WhirlwindBuff = 85739,
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
