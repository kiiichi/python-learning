----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.TemplarStrikeExpires = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
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

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

aura_env.NGSend = function(Name, Extra)
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name, Extra)
    WeakAuras.ScanEvents("NG_OUT_OF_RANGE", aura_env.OutOfRange)
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    if aura_env.config[tostring(spellID)] == false then return false end
    
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
    local NGSend = aura_env.NGSend
    
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1689)
    local CurrentHolyPower = UnitPower("player", Enum.PowerType.HolyPower)
    
    local NearbyEnemies = 0
    local NearbyRange = 8
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    local TemplarStrikeRemaining = max(aura_env.TemplarStrikeExpires - GetTime(), 0)
    local CrusadeRemainingCooldown = ((IsPlayerSpell(ids.Crusade) and not IsPlayerSpell(ids.RadiantGloryTalent)) and GetRemainingSpellCooldown(ids.Crusade) or 0)
    local AvengingWrathRemainingCooldown = ((IsPlayerSpell(ids.AvengingWrath) and not IsPlayerSpell(ids.RadiantGloryTalent) and not IsPlayerSpell(ids.Crusade)) and GetRemainingSpellCooldown(ids.AvengingWrath) or 0)
    local CrusadeOffCooldown = ((IsPlayerSpell(ids.Crusade) and not IsPlayerSpell(ids.RadiantGloryTalent)) and GetRemainingSpellCooldown(ids.Crusade) == 0 or false)
    local AvengingWrathOffCooldown = ((IsPlayerSpell(ids.AvengingWrath) and not IsPlayerSpell(ids.RadiantGloryTalent) and not IsPlayerSpell(ids.Crusade)) and GetRemainingSpellCooldown(ids.AvengingWrath) == 0 or false)
    
    if IsPlayerSpell(ids.RadiantGloryTalent) then ids.CrusadeBuff = ids.RadiantGloryCrusadeBuff end
    if IsPlayerSpell(ids.RadiantGloryTalent) then ids.AvengingWrathBuff = ids.RadiantGloryAvangeningWrathBuff end
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Avenging Wrath
    if AvengingWrathOffCooldown and ( ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and IsPlayerSpell(ids.DivineAuxiliaryTalent) and ( GetRemainingSpellCooldown(ids.ExecutionSentence) == 0 or GetRemainingSpellCooldown(ids.FinalReckoning) == 0 ) ) ) then
    ExtraGlows.AvengingWrath = true end
    
    if CrusadeOffCooldown and ( CurrentHolyPower >= 3 ) then
    ExtraGlows.Crusade = true end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cooldowns = function()
        if OffCooldown(ids.ExecutionSentence) and ( ( not PlayerHasBuff(ids.CrusadeBuff) and CrusadeRemainingCooldown > 15 or GetPlayerStacks(ids.CrusadeBuff) == 10 or AvengingWrathRemainingCooldown < 0.75 or AvengingWrathRemainingCooldown > 15 or IsPlayerSpell(ids.RadiantGloryTalent) ) and ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and ( IsPlayerSpell(ids.DivineAuxiliaryTalent) or IsPlayerSpell(ids.RadiantGloryTalent) ) ) and ( GetRemainingSpellCooldown(ids.DivineHammer) > 5 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) and ( TargetTimeToXPct(0, 60) > 8 and not IsPlayerSpell(ids.ExecutionersWillTalent) or TargetTimeToXPct(0, 60) > 12 ) and GetRemainingSpellCooldown(ids.WakeOfAshes) < WeakAuras.gcdDuration() ) then
            NGSend("Execution Sentence") return true end
        
        if OffCooldown(ids.FinalReckoning) and ( ( CurrentHolyPower >= 3 or CurrentHolyPower >= 2 and ( IsPlayerSpell(ids.DivineAuxiliaryTalent) or IsPlayerSpell(ids.RadiantGloryTalent) ) ) and ( not IsPlayerSpell(ids.Crusade) and AvengingWrathRemainingCooldown > 10 or CrusadeRemainingCooldown > 0 and ( not PlayerHasBuff(ids.CrusadeBuff) or GetPlayerStacks(ids.CrusadeBuff) >= 10 ) or IsPlayerSpell(ids.RadiantGloryTalent) and ( PlayerHasBuff(ids.AvengingWrathBuff) or IsPlayerSpell(ids.Crusade) and GetRemainingSpellCooldown(ids.WakeOfAshes) < WeakAuras.gcdDuration() ) ) ) then
            NGSend("Final Reckoning") return true end
    end
    
    local Finishers = function()
        Variables.DsCastable = ( NearbyEnemies >= 2 or PlayerHasBuff(ids.EmpyreanPowerBuff) or not IsPlayerSpell(ids.FinalVerdict) and IsPlayerSpell(ids.TempestOfTheLightbringerTalent) ) and not PlayerHasBuff(ids.EmpyreanLegacyBuff) and not ( PlayerHasBuff(ids.DivineArbiterBuff) and GetPlayerStacks(ids.DivineArbiterBuff) > 24 )
        
        if FindSpellOverrideByID(ids.WakeOfAshes) == ids.HammerOfLight and (FindSpellOverrideByID(ids.WakeOfAshes) == ids.HammerOfLight or not IsPlayerSpell(ids.DivineHammer) or PlayerHasBuff(ids.DivineHammerBuff) or GetRemainingSpellCooldown(ids.DivineHammer) > 10) then
            NGSend("Hammer of Light") return true end
        
        if OffCooldown(ids.DivineHammer) and ( not PlayerHasBuff(ids.DivineHammerBuff) ) then
            NGSend("Divine Hammer") return true end
        
        if OffCooldown(ids.DivineStorm) and ( Variables.DsCastable and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) and ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) ) then
            NGSend("Divine Storm") return true end
        
        if OffCooldown(ids.JusticarsVengeance) and ( ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) ) then
            NGSend("Justicars Vengeance") return true end
        
        if OffCooldown(ids.TemplarsVerdict) and ( ( not IsPlayerSpell(ids.Crusade) or GetRemainingSpellCooldown(ids.Crusade) > WeakAuras.gcdDuration() * 3 or PlayerHasBuff(ids.CrusadeBuff) and GetPlayerStacks(ids.CrusadeBuff) < 10 or IsPlayerSpell(ids.RadiantGloryTalent) ) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and (GetRemainingSpellCooldown(ids.DivineHammer) > 0 or PlayerHasBuff(ids.DivineHammerBuff) or not IsPlayerSpell(ids.DivineHammer)) ) then
            NGSend("Templars Verdict") return true end
    end
    
    local Generators = function()
        if (CurrentHolyPower == 5 or CurrentHolyPower == 4 and PlayerHasBuff(ids.DivineResonanceBuff) or PlayerHasBuff(ids.AllInBuff)) and GetRemainingSpellCooldown(ids.WakeOfAshes) > 0 then
            if Finishers() then return true end end

        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash and ( TemplarStrikeRemaining < WeakAuras.gcdDuration() * 2 ) then
            NGSend("Templar Slash") return true end

        if OffCooldown(ids.BladeOfJustice) and (not TargetHasDebuff(ids.ExpurgationDebuff) and IsPlayerSpell(ids.HolyFlamesTalent) and GetRemainingSpellCooldown(ids.DivineToll) > 0 ) then
            NGSend("Blade of Justice") return true end

        if OffCooldown(ids.WakeOfAshes) and FindSpellOverrideByID(ids.WakeOfAshes) ~= ids.HammerOfLight and ( ( not IsPlayerSpell(ids.LightsGuidanceTalent) or CurrentHolyPower >= 2 and IsPlayerSpell(ids.LightsGuidanceTalent) ) and ( AvengingWrathRemainingCooldown > 6 or GetRemainingSpellCooldown(ids.Crusade) > 6 or IsPlayerSpell(ids.RadiantGloryTalent) ) and ( not IsPlayerSpell(ids.ExecutionSentence) or GetRemainingSpellCooldown(ids.ExecutionSentence) > 4 or TargetTimeToXPct(0, 60) < 8 ) ) then
            NGSend("Wake of Ashes") return true end
        
        if OffCooldown(ids.DivineToll) and ( CurrentHolyPower <= 2 and ( ( AvengingWrathRemainingCooldown > 15 or GetRemainingSpellCooldown(ids.Crusade) > 15 or IsPlayerSpell(ids.RadiantGloryTalent) or FightRemains(60, NearbyRange) < 8 ) ) ) then   
            NGSend("Divine Toll") return true end
        
        if Finishers() then return true end
        
        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash and ( TemplarStrikeRemaining < WeakAuras.gcdDuration() and NearbyEnemies >= 2 ) then
            NGSend("Templar Slash") return true end
        
        if OffCooldown(ids.BladeOfJustice) and ( NearbyEnemies >= 2 and IsPlayerSpell(ids.BladeOfVengeanceTalent) ) then
            NGSend("Blade of Justice") return true end
        
        if OffCooldown(ids.HammerOfWrath) and ( ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BlessedChampionTalent) ) and PlayerHasBuff(ids.BlessingOfAnsheBuff) ) then
            NGSend("Hammer of Wrath") return true end
            
        if OffCooldown(ids.TemplarStrike) then
            NGSend("Templar Strike") return true end
        
        if OffCooldown(ids.Judgment) then
            NGSend("Judgment") return true end
        
        if OffCooldown(ids.BladeOfJustice) then
            NGSend("Blade of Justice") return true end
        
        if OffCooldown(ids.HammerOfWrath) and ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BlessedChampionTalent) ) then
            NGSend("Hammer of Wrath") return true end
        
        if FindSpellOverrideByID(ids.TemplarStrike) == ids.TemplarSlash then
            NGSend("Templar Slash") return true end
        
        if OffCooldown(ids.CrusaderStrike) and not IsPlayerSpell(ids.TemplarStrikesTalent) and not IsPlayerSpell(ids.CrusadingStrikesTalent) then
            NGSend("Crusader Strike") return true end
            
        if OffCooldown(ids.HammerOfWrath) then
            NGSend("Hammer of Wrath") return true end
    end
    
    if Cooldowns() then return true end
    
    if Generators() then return true end
    
    NGSend("Clear")
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    
    if spellID == aura_env.ids.TemplarStrike then
        aura_env.TemplarStrikeExpires = GetTime() + 5
    end
    
    return
end