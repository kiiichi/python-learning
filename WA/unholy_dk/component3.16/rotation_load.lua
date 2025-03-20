---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbominationLimb = 383269,
    Apocalypse = 275699,
    ArmyOfTheDead = 42650,
    DarkArbiter = 207349,
    DarkTransformation = 63560,
    DeathAndDecay = 43265,
    DeathCoil = 47541,
    Defile = 152280,
    Epidemic = 207317,
    FesteringStrike = 85948, 
    Outbreak = 77575, 
    RaiseAbomination = 455395,
    RaiseDead = 46584,
    ScourgeStrike = 55090,
    SoulReaper = 343294,
    SummonGargoyle = 49206,
    UnholyAssault = 207289,
    VampiricStrike = 433895,
    VileContagion = 390279,
    
    -- Talents
    ApocalypseTalent = 275699,
    BurstingSoresTalent = 207264,
    CoilOfDevastationTalent = 390270,
    CommanderOfTheDeadTalent = 390259,
    DoomedBiddingTalent = 455386,
    EbonFeverTalent = 207269,
    FestermightTalent = 377590,
    FrenziedBloodthirstTalent = 434075,
    GiftOfTheSanlaynTalent = 434152,
    HarbingerOfDoomTalent = 276023,
    HungeringThirstTalent = 444037,
    ImprovedDeathCoilTalent = 377580,
    ImprovedDeathStrikeTalent = 374277,
    MenacingMagusTalent = 455135,
    MorbidityTalent = 377592,
    PlaguebringerTalent = 390175,
    RaiseAbominationTalent = 455395,
    RottenTouchTalent = 390275,
    SuperstrainTalent = 390283,
    UnholyBlightTalent = 460448,
    UnholyGroundTalent = 374265,
    VampiricStrikeTalent = 433901,
    
    -- Buffs/Debuffs
    AFeastOfSoulsBuff = 440861,
    BloodPlagueDebuff = 55078,
    ChainsOfIceTrollbaneSlowDebuff = 444826,
    CommanderOfTheDeadBuff = 390260,
    DarkTransformationBuff = 63560,
    DeathAndDecayBuff = 188290,
    DeathRotDebuff = 377540,
    EssenceOfTheBloodQueenBuff = 433925,
    FesteringScytheBuff = 458128, -- 458123
    FesteringWoundDebuff = 194310,
    FestermightBuff = 377591,
    FrostFeverDebuff = 55095,
    GiftOfTheSanlaynBuff = 434153,
    InflictionOfSorrowBuff = 460049,
    RottenTouchDebuff = 390276,
    RunicCorruptionBuff = 51460,
    SuddenDoomBuff = 81340,
    VirulentPlagueDebuff = 191587,
    WinningStreakBuff = 1216813,
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