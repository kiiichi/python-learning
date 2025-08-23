----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
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
    RemorselessWinterBuff1 = 196770, -- Initial RemorselessWinter
    RemorselessWinterBuff2 = 1233152, -- RemorselessWinter if has FrozenDominionTalent
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


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core1--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function()
    if (aura_env.LastUpdate and aura_env.LastUpdate > GetTime() - aura_env.config["UpdateFrequency"])
    then
        return 
    end
    aura_env.LastUpdate = GetTime()
    
    ---- Setup ----------------------------------------------------------------------------------------------------
    local CurrentTime = GetTime()
    
    local OffCooldown = aura_env.OffCooldown
    local OffCooldownNotCasting = aura_env.OffCooldownNotCasting
    local GetRemainingAuraDuration = aura_env.GetRemainingAuraDuration
    local GetRemainingDebuffDuration = aura_env.GetRemainingDebuffDuration
    local GetRemainingSpellCooldown = aura_env.GetRemainingSpellCooldown
    local IsCasting = aura_env.IsCasting
    local GetPlayerStacks = aura_env.GetPlayerStacks
    local GetTargetStacks = aura_env.GetTargetStacks
    local PlayerHasBuff = aura_env.PlayerHasBuff
    local TargetHasDebuff = aura_env.TargetHasDebuff
    local HasBloodlust = aura_env.HasBloodlust    
    local GetSpellChargesFractional = aura_env.GetSpellChargesFractional
    local GetTimeToNextCharge = aura_env.GetTimeToNextCharge
    local GetTimeToFullCharges = aura_env.GetTimeToFullCharges
    local TargetTimeToXPct = aura_env.TargetTimeToXPct
    local FightRemains = aura_env.FightRemains
    local IsAuraRefreshable = aura_env.IsAuraRefreshable
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1919)
    
    local CurrentRunes = 0
    local RuneCooldownDuration = select(2, GetRuneCooldown(1))
    local RuneCooldownStarts = {}
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            CurrentRunes = CurrentRunes + 1
        end
        table.insert(RuneCooldownStarts, start)
    end
    table.sort(RuneCooldownStarts)
    local TimeToXRunes = function(X)
        if RuneCooldownStarts[X] == 0 then return 0 end
        return RuneCooldownStarts[X] + RuneCooldownDuration - GetTime()
    end
    
    local CurrentRunicPower = UnitPower("player", Enum.PowerType.RunicPower)
    local MaxRunicPower = UnitPowerMax("player", Enum.PowerType.RunicPower)
    
    local NearbyRange = 10
    local NearbyEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)
    -- WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    local Variables = {}
    
    Variables.TwoHandCheck = (select(9, C_Item.GetItemInfo(GetInventoryItemLink("player", 16))) == "INVTYPE_2HWEAPON")
    
    Variables.StPlanning = NearbyEnemies <= 1
    
    Variables.AddsRemain = NearbyEnemies >= 2
    
    Variables.SendingCds = ( Variables.StPlanning or Variables.AddsRemain )
    
    Variables.CooldownCheck = ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrostBuff) ) or not IsPlayerSpell(ids.PillarOfFrost) or FightRemains(60, NearbyRange) < 20

    Variables.FwfBuffs = (GetRemainingAuraDuration("player", ids.PillarOfFrost) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or (PlayerHasBuff(ids.UnholyStrengthBuff) and GetRemainingAuraDuration("player", ids.UnholyStrengthBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3) or (IsPlayerSpell(ids.BonegrinderTalent) and PlayerHasBuff(ids.BonegrinderFrostBuff) and GetRemainingAuraDuration("player", ids.BonegrinderFrostBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and (NearbyEnemies > 1 or GetTargetStacks(ids.RazoriceDebuff) == 5 or IsPlayerSpell(ids.ShatteringBladeTalent))

    Variables.RunePooling = IsPlayerSpell(ids.ReapersMarkTalent) and GetRemainingSpellCooldown(ids.ReapersMark) < 6 and CurrentRunes < 3 and Variables.SendingCds

    Variables.RpPooling = IsPlayerSpell(ids.BreathOfSindragosaTalent) and GetRemainingSpellCooldown(ids.BreathOfSindragosa) < 4 * WeakAuras.gcdDuration() and CurrentRunicPower < (60 + ( 35 + 5 * (PlayerHasBuff(ids.IcyOnslaughtBuff) and 1 or 0 ) - ( 10 * CurrentRunes )) ) and Variables.SendingCds 

    -- Kichi fix because NG wrong
    -- Frostscythe is equal at 3 targets, except with Rider 4pc which brings Obliterate higher at 3, unless cleaving strikes is up
    Variables.FrostscythePrio = 3 + ( ( (SetPieces >= 4 ) and not ( IsPlayerSpell(ids.CleavingStrikesTalent) and (PlayerHasBuff(ids.RemorselessWinterBuff1) or PlayerHasBuff(ids.RemorselessWinterBuff2) ) ) ) and 1 or 0 )

    Variables.BreathOfSindragosaCheck = IsPlayerSpell(ids.BreathOfSindragosaTalent) and (GetRemainingSpellCooldown(ids.BreathOfSindragosa) > 20 or ( OffCooldown(ids.BreathOfSindragosa) and CurrentRunicPower >= ( 60 - 20 * (IsPlayerSpell(ids.ReapersMarkTalent) and 1 or 0) ) ) )
    

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Empower Rune Weapon
    if OffCooldown(ids.EmpowerRuneWeapon) and ( CurrentRunes < 2 or not PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunicPower < 35 + ((IsPlayerSpell(ids.IcyOnslaughtTalent) and 1 or 0) * GetPlayerStacks(ids.IcyOnslaughtBuff) * 5 ) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    if OffCooldown(ids.EmpowerRuneWeapon) and ( GetTimeToFullCharges(ids.EmpowerRuneWeapon) <= 6 and GetPlayerStacks(ids.KillingMachineBuff) < 1 + (IsPlayerSpell(ids.KillingStreakTalent) and 1 or 0) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    -- Pillar of Frost
    if OffCooldown(ids.PillarOfFrost) and ( not IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) or FightRemains(60, NearbyRange) < 20 ) then
        ExtraGlows.PillarOfFrost = true end

    if OffCooldown(ids.PillarOfFrost) and ( IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and Variables.BreathOfSindragosaCheck and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) ) then
        ExtraGlows.PillarOfFrost = true end

    -- Breath of Sindragosa
    if OffCooldown(ids.BreathOfSindragosa) and ( not PlayerHasBuff(ids.BreathOfSindragosaBuff) and ( PlayerHasBuff(ids.PillarOfFrostBuff) or FightRemains(60, NearbyRange) < 20 ) ) then
        ExtraGlows.BreathOfSindragosa = true end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Action List
    local Aoe = function()
        if OffCooldown(ids.Frostscythe) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) ) then
            KTrig("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) or not TargetHasDebuff(ids.FrostFeverDebuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and PlayerHasBuff(ids.FrostbaneBuff) ) then
            KTrig("Frost Strike") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and NearbyEnemies < 5 and not Variables.RpPooling and not IsPlayerSpell(ids.FrostbaneTalent) ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Frostscythe) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.GlacialAdvance) and ( not Variables.RpPooling ) then
            KTrig("Glacial Advance") return true end

        if OffCooldown(ids.Frostscythe) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Howling Blast") return true end
    end
    
    -- Cooldowns
    local Cooldowns = function()
        if OffCooldown(ids.RemorselessWinter) and not IsPlayerSpell(ids.FrozenDominionTalent) and ( Variables.SendingCds and ( NearbyEnemies > 1 or IsPlayerSpell(ids.GatheringStormTalent ) or ( GetPlayerStacks(ids.GatheringStormBuff) == 10 and GetRemainingAuraDuration("player", ids.GatheringStormBuff) < WeakAuras.gcdDuration() * 2 ) ) and FightRemains(60, NearbyRange) > 10 ) then
            -- KTrig("Remorseless Winter") return true end
            if aura_env.config[tostring(ids.RemorselessWinter)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Remorseless Winter")
            elseif aura_env.config[tostring(ids.RemorselessWinter)] ~= true then
                KTrig("Remorseless Winter")
                return true
            end
        end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and not IsPlayerSpell(ids.BreathOfSindragosaTalent) ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end
                    
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and IsPlayerSpell(ids.BreathOfSindragosaTalent) and CurrentRunicPower >= 60 ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end

        if OffCooldown(ids.ReapersMark) and ( PlayerHasBuff(ids.PillarOfFrost) or GetRemainingSpellCooldown(ids.PillarOfFrost) > 5 or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Reapers Mark") return true end
            if aura_env.config[tostring(ids.ReapersMark)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Reapers Mark")
            elseif aura_env.config[tostring(ids.ReapersMark)] ~= true then
                KTrig("Reapers Mark")
                return true
            end
        end            

        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies <= 1 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not IsPlayerSpell(ids.ObliterationTalent) or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs or FightRemains(10, NearbyRange) < 3 ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies >= 2 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and IsPlayerSpell(ids.ObliterationTalent) and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not Variables.TwoHandCheck or not PlayerHasBuff(ids.PillarOfFrost) and Variables.TwoHandCheck and GetRemainingSpellCooldown(ids.PillarOfFrost) > 0 or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end        
        if OffCooldown(ids.RaiseDead) then
            -- KTrig("Raise Dead") return true end
            if aura_env.config[tostring(ids.RaiseDead)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Raise Dead")
            elseif aura_env.config[tostring(ids.RaiseDead)] ~= true then
                KTrig("Raise Dead")
                return true
            end
        end
        
        if OffCooldown(ids.SoulReaper) and ( IsPlayerSpell(ids.ReaperOfSoulsTalent) and PlayerHasBuff(ids.ReaperOfSoulsBuff) and GetPlayerStacks(ids.KillingMachineBuff) < 2) then
            KTrig("Soul Reaper") return true end
    end
    
    -- Single Target Rotation
    local SingleTarget = function()
        if OffCooldown(ids.Obliterate) and ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3 ) ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) ) then
            KTrig("Howling Blast") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling ) then
            KTrig("Frost Strike") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( not IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling and MaxRunicPower - CurrentRunicPower < 30 ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.FrostStrike) and ( not Variables.RpPooling ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Howling Blast") return true end
    end
    
    -- Choose Action list to run
    if Cooldowns() then return true end
    
    if NearbyEnemies >= 3 then
        Aoe() return true end
    
    if SingleTarget() then return true end
    
    KTrig("Clear")
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Trigger2----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
--     if sourceGUID ~= UnitGUID("player") then return false end
    
--     if spellID == aura_env.ids.ArmyOfTheDead then
--         aura_env.ArmyExpiration = GetTime() + 30
--     elseif spellID == aura_env.ids.SummonGargoyle or spellID == aura_env.ids.DarkArbiter then
--         aura_env.GargoyleExpiration = GetTime() + 25
--     elseif spellID == aura_env.ids.Apocalypse then
--         aura_env.ApocalypseExpiration = GetTime() + 20
--     elseif spellID == aura_env.ids.RaiseAbomination then
--         aura_env.AbominationExpiration = GetTime() + 30
--     end
-- end



----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load-----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

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
    RemorselessWinterBuff1 = 196770, -- Initial RemorselessWinter
    RemorselessWinterBuff2 = 1233152, -- RemorselessWinter if has FrozenDominionTalent
    RimeBuff = 59052,
    UnholyStrengthBuff = 53365,
    UnleashedFrenzyBuff = 376907,
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

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Trigger--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function(allstates, event, spellID, customData)
    
    local ids = aura_env.ids
    local GetSpellCooldown = aura_env.GetSpellCooldown
    local GetSafeSpellIcon = aura_env.GetSafeSpellIcon
    local firstPriority = nil
    local firstIcon = 0
    local firstCharges, firstCD, firstMaxCharges = 0, 0, 0

    if spellID and spellID ~= "Clear" then
        local key = spellID:gsub(" (%a)", function(c) return c:upper() end):gsub(" ", "")
        firstPriority = ids[key]
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end

    if spellID == "Clear" then
        firstIcon = 0
        firstCharges, firstCD, firstMaxCharges = 0, 0, 0
    end
    -- 更新 allstates
    allstates[1] = {
        show = true,
        changed = true,
        icon = firstIcon,
        spell = firstPriority,
        cooldown = firstCD,
        charges = firstCharges,
        maxCharges = firstMaxCharges
    }
    
    return true
end
