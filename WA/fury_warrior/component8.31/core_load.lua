WeakAuras.WatchGCD()

---- Spell IDs ------------------------------------------------------------------------------------------------
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

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    -- Kichi --
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) or nomana then return false end
    
    -- Kichi --
    -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Duration = Cooldown.duration
    local Remaining = Cooldown.startTime + Duration - GetTime()

    -- Kichi updata 25.8.26
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75))

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

-- Kichi --
aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    local duration = aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
    if duration == nil then duration = 0 end
    return duration
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

aura_env.IsAuraRefreshable = function(SpellID, Unit, Filter)
    -- Kichi --
    -- local Filter = ""
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

-- Kichi --
aura_env.FullGCD = function()
    local baseGCD = 1.5
    local FullGCDnum = math.max(0.75, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end

aura_env.KTrigCD = function(Name, customData, ...)
    if customData == nil then
        if aura_env.config["SavingCD"] == false and aura_env.FightRemains(60, 40) <= aura_env.config["SavingCDTime"] then
            customData = "Saving" 
        elseif aura_env.config["SavingCD"] == true and aura_env.FightRemains(60, 40) <= aura_env.config["SavingCDTime"] then
            Name = "Clear"
        end
    end
    WeakAuras.ScanEvents("K_TRIGED_CD", Name, customData, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    aura_env.FlagKTrigCD = false
end
