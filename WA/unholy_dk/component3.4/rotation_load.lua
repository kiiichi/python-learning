---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    RaiseAbomination = 455395,
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
    RaiseDead = 46584,
    ScourgeStrike = 55090,
    SoulReaper = 343294,
    SummonGargoyle = 49206,
    UnholyAssault = 207289,
    VileContagion = 390279,
    VampiricStrike = 433895,
    
    -- Talents
    VampiricStrikeTalent = 433901,
    Morbidity = 377592,
    DoomedBidding = 455386,
    CoilOfDevastation = 390270,
    ImprovedDeathCoil = 377580,
    GiftOfTheSanlayn = 434152,
    RottenTouch = 390275,
    BurstingSores = 207264,
    EbonFever = 207269,
    Superstrain = 390283,
    CommanderOfTheDead = 390259,
    Plaguebringer = 390175,
    ImprovedDeathStrike = 374277,
    UnholyBlight = 460448,
    UnholyGround = 374265,
    MenacingMagusTalent = 455135,
    FrenziedBloodthirstTalent = 434075,
    HungeringThirstTalent = 444037,
    HarbingerOfDoomTalent = 276023,
    
    -- Buffs/Debuffs
    AFeastOfSouls = 440861,
    ChainsOfIceTrollbaneSlow = 444826,
    VirulentPlague = 191587,
    FesteringWound = 194310,
    EssenceOfTheBloodQueen = 433925,
    GiftOfTheSanlaynBuff = 434153,
    RottenTouchDebuff = 390276,
    CommanderOfTheDeadBuff = 390260,
    InflictionOfSorrow = 460049,
    DeathAndDecayBuff = 188290,
    RunicCorruption = 51460,
    FrostFever = 55095,
    BloodPlague = 55078,
    SuddenDoom = 81340,
    Festermight = 377591,
    DeathRot = 377540,
    FesteringScythe = 458123,
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
