WeakAuras.WatchGCD()

---- Spell IDs ------------------------------------------------------------------------------------------------
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
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) or nomana then return false end
    
    -- Kichi --
    -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Duration = Cooldown.duration
    local Remaining = Cooldown.startTime + Duration - GetTime()
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())

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