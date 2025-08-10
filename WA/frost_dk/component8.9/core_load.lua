WeakAuras.WatchGCD()

-- Death Strike Prediction
aura_env.DamageTaken = {} -- Table to store damage taken
aura_env.LastSec = 5 -- How long damage events are taken into account
aura_env.BasePercentage = 0.25 -- Percentage of the damage that is being healed
aura_env.MinHealPercentage = 0.07 -- Minimum percentage that Death Strike gives

-- Table to exclude certain abilities that deal damage but do not increase the healing done by DS
aura_env.exclude = {
    [243237] = true, --Bursting
}

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbominationLimb = 383269,
    BreathOfSindragosa = 1249658,
    ChainsOfIce = 45524,
    ChillStreak = 305392,
    DeathAndDecay = 43265,
    EmpowerRuneWeapon = 47568,
    FrostStrike = 49143,
    Frostscythe = 207230,
    FrostwyrmsFury = 279302,
    GlacialAdvance = 194913,
    HornOfWinter = 57330,
    HowlingBlast = 49184,
    Obliterate = 49020,
    PillarOfFrost = 51271,
    RaiseDead = 46585,
    ReapersMark = 439843,
    RemorselessWinter = 196770,
    SoulReaper = 343294,
    
    -- Talents
    AFeastOfSoulsTalent = 444072,
    ApocalypseNowTalent = 444040,
    ArcticAssaultTalent = 456230,
    AvalancheTalent = 207142,
    BindInDarknessTalent = 440031,
    BitingColdTalent = 377056,
    BonegrinderTalent = 377098,
    BreathOfSindragosaTalent = 1249658,
    CleavingStrikesTalent = 316916,
    ColdHeartTalent = 281208,
    DarkTalonsTalent = 436687,
    EmpowerRuneWeaponTalent = 47568,
    EnduringStrengthTalent = 377190,
    FrigidExecutionerTalent = 377073,
    FrostbaneTalent = 455993,
    FrostboundWillTalent = 1238680,
    FrostwyrmsFuryTalent = 279302,
    FrozenDominionTalent = 377226,
    GatheringStormTalent = 194912,
    GlacialAdvanceTalent = 194913,
    IcebreakerTalent = 392950,
    IcyOnslaughtTalent = 1230272,
    IcyTalonsTalent = 194878,
    ImprovedDeathStrikeTalent = 374277,
    KillingStreakTalent = 1230153,
    ObliterationTalent = 281238,
    RageOfTheFrozenChampionTalent = 377076,
    ReaperOfSoulsTalent = 440002,
    ReapersMarkTalent = 439843,
    RidersChampionTalent = 444005,
    ShatteredFrostTalent = 455993,
    ShatteringBladeTalent = 207057,
    SmotheringOffenseTalent = 435005,
    TheLongWinterTalent = 456240,
    UnholyGroundTalent = 374265,
    UnleashedFrenzyTalent = 376905,
    WitherAwayTalent = 441894,
    
    -- Buffs/Debuffs
    AFeastOfSoulsBuff = 440861,
    BonegrinderFrostBuff = 377103,
    BreathOfSindragosaBuff = 1249658,
    ColdHeartBuff = 281209,
    DeathAndDecayBuff = 188290,
    ExterminateBuff = 441416,
    ExterminatePainfulDeathBuff = 447954,
    FrostbaneBuff = 1229310,
    FrostFeverDebuff = 55095,
    GatheringStormBuff = 211805,
    IcyOnslaughtBuff = 1230273,
    IcyTalonsBuff = 194879,
    KillingMachineBuff = 51124,
    MograinesMightBuff = 444505,
    PillarOfFrostBuff = 51271,
    RazoriceDebuff = 51714,
    ReaperOfSoulsBuff = 469172,
    ReapersMarkDebuff = 434765,
    RemorselessWinterBuff = 196770,
    RimeBuff = 59052,
    UnholyStrengthBuff = 53365,
    UnleashedFrenzyBuff = 376907,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false


-- Kichi --
-- Kichi --
aura_env.KTrig = function(Name, ...)
    WeakAuras.ScanEvents("K_TRIGED", Name, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    if aura_env.FlagKTrigCD then
        WeakAuras.ScanEvents("K_TRIGED_CD", "Clear", ...)
    end
    aura_env.FlagKTrigCD = flase
end

aura_env.KTrigCD = function(Name, ...)
    WeakAuras.ScanEvents("K_TRIGED_CD", Name, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    aura_env.FlagKTrigCD = false
end


aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    -- Kichi --
    -- Kichi --
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) then return false end
    
    local Duration = C_Spell.GetSpellCooldown(spellID).duration
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    if not OffCooldown then return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    if InRange == false then
        aura_env.OutOfRange = true
        --return false
    end
    
    return true
end

aura_env.IsCasting = function(spellID)
    return select(9, UnitCastingInfo("player")) == spellID
end

aura_env.OffCooldownNotCasting = function(spellID)
    return aura_env.OffCooldown(spellID) and not aura_env.IsCasting(spellID)
end

aura_env.GetStacks = function(unit, spellID, filter)
    local _,_,Stacks = WA_GetUnitAura(unit, spellID, filter)
    if Stacks == nil then Stacks = 0 end
    return Stacks
end

aura_env.GetPlayerStacks = function(spellID)
    return aura_env.GetStacks("player", spellID)
end

aura_env.GetTargetStacks = function(spellID)
    return aura_env.GetStacks("target", spellID, "PLAYER|HARMFUL")
end

aura_env.GetRemainingAuraDuration = function(unit, spellID, filter)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if filter == nil then filter = "PLAYER" end
    local AuraFound = WA_GetUnitAura(unit, spellID, filter)
    
    if AuraFound == nil then return 0 end
    local Expiration = select(6, WA_GetUnitAura(unit, spellID, filter))
    if Expiration == nil then return 0 end
    return Expiration - GetTime()
end

aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    return aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
end

aura_env.GetSpellChargesFractional = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local CurrentCharges = ChargeInfo.currentCharges
    if ChargeInfo.cooldownStartTime == 0 then return CurrentCharges end
    
    local FractionalCharge = (GetTime() - ChargeInfo.cooldownStartTime) / ChargeInfo.cooldownDuration
    return CurrentCharges + FractionalCharge
end

aura_env.GetTimeToNextCharge = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local MissingCharges = ChargeInfo.maxCharges - ChargeInfo.currentCharges
    if MissingCharges == 0 then return 0 end
    
    local TimeRemaining = ChargeInfo.cooldownStartTime + ChargeInfo.cooldownDuration - GetTime()
    return TimeRemaining
end

aura_env.GetTimeToFullCharges = function(spellID)
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    local MissingCharges = ChargeInfo.maxCharges - ChargeInfo.currentCharges
    if MissingCharges == 0 then return 0 end
    
    local TimeRemaining = ChargeInfo.cooldownStartTime + ChargeInfo.cooldownDuration - GetTime()
    if MissingCharges > 1 then 
        TimeRemaining = TimeRemaining + (ChargeInfo.cooldownDuration * (MissingCharges-1))
    end
    return TimeRemaining
end

aura_env.TargetTimeToXPct = function(Pct, Default)
    if Default == nil then
        local c = a < b -- Throw an error
    end
    
    if HeroLib == nil then
        return Default
    end
    
    return HeroLib.Unit.Target:TimeToX(Pct)
end

aura_env.FightRemains = function(Default, NearbyRange)
    if Default == nil then
        local c = a < b -- Throw an error
    end
    
    if HeroLib == nil then
        return Default
    end
    
    return HeroLib.FightRemains(HeroLib.Unit.Player:GetEnemiesInRange(NearbyRange))
end

aura_env.IsAuraRefreshable = function(SpellID, Unit)
    local Filter = ""
    if Unit == nil then 
        Unit = "target" 
        Filter = "HARMFUL|PLAYER" 
    end
    
    local _,_,_,_,Duration,ExpirationTime = WA_GetUnitAura(Unit, SpellID, Filter)
    if Duration == nil then return true end
    
    local RemainingTime = ExpirationTime - GetTime()
    
    return (RemainingTime / Duration) < 0.3
end

aura_env.GetRemainingSpellCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    local ChargeInfo = C_Spell.GetSpellCharges(spellID)
    if ChargeInfo and C_Spell.GetSpellCharges(spellID).currentCharges >= 1 then return 0 end
    
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Remaining = Cooldown.startTime + Cooldown.duration - GetTime()
    if (Cooldown.duration == 0 or Cooldown.duration == WeakAuras.gcdDuration()) then Remaining = 0 end
    return Remaining
end

aura_env.CalcDeathStrikeHeal = function()
    local i = 1
    local CurrentTime = GetTime()
    local TotalDamage = 0
    while aura_env.DamageTaken[i] do
        local EntryTime = aura_env.DamageTaken[i][1]
        local EntryDamage = aura_env.DamageTaken[i][2]
        
        -- Remove outdated entry or add damage
        if CurrentTime > EntryTime + aura_env.LastSec then
            table.remove(aura_env.DamageTaken, i)
        else
            TotalDamage = TotalDamage + EntryDamage
            i = i + 1
        end
    end
    
    local BasePercentage = aura_env.BasePercentage
    local MinHealPercentage = aura_env.MinHealPercentage
    
    if IsPlayerSpell(aura_env.ids.ImprovedDeathStrikeTalent) then 
        BasePercentage = BasePercentage * 1.05
        MinHealPercentage = MinHealPercentage * 1.05
    end
    
    --Versatility
    local Vers = 1 + ((GetCombatRatingBonus(29) + GetVersatilityBonus(30)) / 100)
    
    --Guardian Spirit
    local GS = 1 + (select(16, WA_GetUnitBuff("player", 47788)) or 0) / 100
    
    --Divine Hymn
    local DH = 1 + 0.04 * (select(3, WA_GetUnitBuff("player", 64844)) or 0)
    
    local TotalHeal = TotalDamage * BasePercentage
    local HealPercentage = TotalHeal / UnitHealthMax("player")
    HealPercentage = math.max(MinHealPercentage, HealPercentage)
    HealPercentage = HealPercentage * Vers * GS * DH
    
    TotalHeal = HealPercentage * UnitHealthMax("player")
    return TotalHeal
end

aura_env.HasBloodlust = function()
    return (WA_GetUnitBuff("player", 2825) or WA_GetUnitBuff("player", 264667) or WA_GetUnitBuff("player", 80353) or WA_GetUnitBuff("player", 32182) or WA_GetUnitBuff("player", 390386) or WA_GetUnitBuff("player", 386540))
end

aura_env.PlayerHasBuff = function(spellID)
    return WA_GetUnitBuff("player", spellID) ~= nil
end

aura_env.TargetHasDebuff = function(spellID)
    return WA_GetUnitDebuff("target", spellID, "PLAYER|HARMFUL") ~= nil
end
