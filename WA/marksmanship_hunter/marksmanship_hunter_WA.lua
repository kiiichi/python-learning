----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.PrevCastTime = 0
aura_env.PrevCast = 0

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
    SalvoTalent = 400456,
    SentinelTalent = 450369,
    ShrapnelShotTalent = 473520,
    SmallGameHunterTalent = 459802,
    SymphonicArsenalTalent = 450383,
    TrickShotsTalent = 257621,
    VolleyTalent = 260243,
    WindrunnerQuiverTalent = 473523,
    -- Kichi add for simc 18bda32_8.9 fix
    MagneticGunpowderTalent = 473522,
    IncendiaryAmmunitionTalent = 471428,

    -- Buffs/Debuffs
    BulletstormBuff = 389020,
    DeathblowBuff = 378770,
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
    -- Kichi add for simc 18bda32_8.9 fix
    LunarStormTargetDebuff = 450884,
    VolleyBuff = 260243,
    ExplosiveShotDebuff = 212431,
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
    local CurrentFocus = UnitPower("player", Enum.PowerType.Focus)
    local MaxFocus = UnitPowerMax("player", Enum.PowerType.Focus)
    
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1923)
    
    local CurrentCast = select(9, UnitCastingInfo("player"))
    if CurrentCast ~= nil then
        if CurrentCast == ids.SteadyShot then
            CurrentFocus = CurrentFocus + 10
        elseif CurrentCast == ids.AimedShot then
            CurrentFocus = CurrentFocus - 35
        end
    end
    
    local NearbyEnemies = 0
    local NearbyRange = 40
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    local HasPreciseShots = PlayerHasBuff(ids.PreciseShotsBuff) or IsCasting(ids.AimedShot)
    local TargetHasSpottersMark = TargetHasDebuff(ids.SpottersMarkDebuff) and not IsCasting(ids.AimedShot)
    local HasMovingTarget = PlayerHasBuff(ids.MovingTargetBuff) and not IsCasting(ids.AimedShot)

    -- Kichi --
    local LunarStormReady = PlayerHasBuff(ids.LunarStormReadyBuff) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") == 0
    local HasTrickShots = PlayerHasBuff(ids.Volley) or PlayerHasBuff(ids.TrickShotsBuff) and not IsCasting(ids.AimedShot) and not (select(8, UnitChannelInfo("player")) == ids.RapidFire) and not ( aura_env.PrevCast == ids.RapidFire )

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Trueshot in Trickshots group
    if OffCooldown(ids.Trueshot) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.TrickShotsTalent) ) and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( (GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > 23) or not IsPlayerSpell(ids.SentinelTalent) ) and GetRemainingSpellCooldown(ids.RapidFire) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) ) then
        ExtraGlows.Trueshot = true
    end

    -- Trueshot in St group
    if OffCooldown(ids.Trueshot) and NearbyEnemies <= 1  and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( (GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > 23) or not IsPlayerSpell(ids.SentinelTalent) ) and GetRemainingSpellCooldown(ids.RapidFire) ) then
        ExtraGlows.Trueshot = true
    end

    -- Trueshot in Cleave group
    if OffCooldown(ids.Trueshot) and ( NearbyEnemies > 1 and not IsPlayerSpell(ids.TrickShotsTalent) or NearbyEnemies == 2 )and ( ( PlayerHasBuff(ids.DoubleTapBuff) == false or not IsPlayerSpell(ids.VolleyTalent) ) and ( not LunarStormReady or not IsPlayerSpell(ids.DoubleTapTalent) or not IsPlayerSpell(ids.VolleyTalent) ) and ( not HasPreciseShots or HasMovingTarget or not IsPlayerSpell(ids.VolleyTalent) ) ) then
        ExtraGlows.Trueshot = true
    end


    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        -- Kichi remove for simc 18bda32_8.9 fix
        -- if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and ( PlayerHasBuff(ids.TrueshotBuff) == false or not IsPlayerSpell(ids.WindrunnerQuiverTalent) ) ) then
        --     -- KTrig("Explosive Shot") return true end
        --     if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Explosive Shot")
        --     elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
        --         KTrig("Explosive Shot")
        --         return true
        --     end
        -- end

        -- Kichi modify for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) == false and GetSpellChargesFractional(ids.AimedShot) < 1 ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( HasPreciseShots and not HasMovingTarget and OffCooldown(ids.Trueshot) ) then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.Volley) and ( ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false or not IsPlayerSpell(ids.AspectOfTheHydraTalent) ) and ( not HasPreciseShots or HasMovingTarget ) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.BulletstormTalent) and PlayerHasBuff(ids.BulletstormBuff) == false and ( not IsPlayerSpell(ids.DoubleTapTalent) or PlayerHasBuff(ids.DoubleTapBuff) or not IsPlayerSpell(ids.AspectOfTheHydraTalent) and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) and ( not HasPreciseShots or HasMovingTarget or not IsPlayerSpell(ids.VolleyTalent) ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and ( not HasPreciseShots or HasMovingTarget ) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kichi move to NoneGCD for simc 18bda32_8.9 fix
        -- if OffCooldown(ids.Trueshot) and ( ( PlayerHasBuff(ids.DoubleTapBuff) == false or not IsPlayerSpell(ids.VolleyTalent) ) and ( PlayerHasBuff(ids.LunarStormReadyBuff) == false or not IsPlayerSpell(ids.DoubleTapTalent) or not IsPlayerSpell(ids.VolleyTalent) ) and ( not HasPreciseShots or HasMovingTarget or not IsPlayerSpell(ids.VolleyTalent) ) ) then
        --     -- KTrig("Trueshot") return true end
        --     if aura_env.config[tostring(ids.Trueshot)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Trueshot")
        --     elseif aura_env.config[tostring(ids.Trueshot)] ~= true then
        --         KTrig("Trueshot")
        --         return true
        --     end
        -- end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to. Sentinel only seems to like this due to the Precise Shots gcd bug.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.LunarStormTalent) and PlayerHasBuff(ids.LunarStormCooldownBuff) == false and ( not HasPreciseShots or HasMovingTarget or GetRemainingSpellCooldown(ids.Volley) and GetRemainingSpellCooldown(ids.Trueshot) or not IsPlayerSpell(ids.VolleyTalent) ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Kill Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- Kichi add for simc 18bda32_8.9 fix to let cast aimed shot right after trueshot
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( PlayerHasBuff(ids.TrueshotBuff) == true and TargetHasSpottersMark and IsPlayerSpell(ids.SentinelTalent) ) then
            KTrig("Aimed Shot") return true end

        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) and not IsPlayerSpell(ids.AspectOfTheHydraTalent) and ( IsPlayerSpell(ids.SymphonicArsenalTalent) or IsPlayerSpell(ids.SmallGameHunterTalent) ) ) then
            KTrig("Multishot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            KTrig("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a little higher when close to capping charges.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) <= 10 or IsPlayerSpell(ids.AspectOfTheHydraTalent) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) or PlayerHasBuff(ids.TrueshotBuff) == false ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) ) then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.SteadyShot) then
            KTrig("Steady Shot") return true end
    end

    local St = function()
        -- Kichi remove for simc 18bda32_8.9 fix
        -- if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and PlayerHasBuff(ids.TrueshotBuff) == false ) then
        --     -- KTrig("Explosive Shot") return true end
        --     if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Explosive Shot")
        --     elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
        --         KTrig("Explosive Shot")
        --         return true
        --     end
        -- end

        -- Kichi add for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) == false and GetSpellChargesFractional(ids.AimedShot) < 1 ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kichi move to NoneGCD for simc 18bda32_8.9 fix
        -- if OffCooldown(ids.Trueshot) and ( PlayerHasBuff(ids.DoubleTapBuff) == false ) then
        --     -- KTrig("Trueshot") return true end
        --     if aura_env.config[tostring(ids.Trueshot)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Trueshot")
        --     elseif aura_env.config[tostring(ids.Trueshot)] ~= true then
        --         KTrig("Trueshot")
        --         return true
        --     end
        -- end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to. Sentinel only seems to like this due to the Precise Shots gcd bug.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.LunarStormTalent) and PlayerHasBuff(ids.LunarStormCooldownBuff) == false ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end        

        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Kill Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) or IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then 
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            KTrig("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a little higher when close to capping charges.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end

        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) or PlayerHasBuff(ids.TrueshotBuff) == false ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.SteadyShot) then
            KTrig("Steady Shot") return true end
    end
    
    local Trickshots = function()
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and PlayerHasBuff(ids.TrueshotBuff) == false and ( not IsPlayerSpell(ids.ShrapnelShotTalent) or PlayerHasBuff(ids.LockAndLoadBuff) == false ) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end

        -- Kichi modify for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) == false and GetSpellChargesFractional(ids.AimedShot) < 1 ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end

        -- Kichi modify for simc 18bda32_8.9 for more explosive shot
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.MagneticGunpowderTalent) and HasPreciseShots and ( PlayerHasBuff(ids.TrueshotBuff) == false or (GetSpellChargesFractional(ids.AimedShot) < 1) ) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        -- Kichi modify for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( not IsPlayerSpell(ids.ShrapnelShotTalent) or PlayerHasBuff(ids.LockAndLoadBuff) == false ) ) and ( (GetSpellChargesFractional(ids.AimedShot) < 2) and PlayerHasBuff(ids.TrueshotBuff) == true or (GetSpellChargesFractional(ids.AimedShot) < 1) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.BulletstormTalent) and PlayerHasBuff(ids.BulletstormBuff) == false and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- Kichi modify for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.SentinelTalent) and ( LunarStormReady or (GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > 18) ) and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) or HasPreciseShots or PlayerHasBuff(ids.TrickShotsBuff) == false ) then
            KTrig("Black Arrow") return true end
        
        -- Kichi modify for simc 18bda32_8.9 for no multishot in volley
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and not HasMovingTarget or PlayerHasBuff(ids.TrickShotsBuff) == false ) and not ( PlayerHasBuff(ids.VolleyBuff) and (GetSpellChargesFractional(ids.AimedShot) >= 1) and GetRemainingAuraDuration("player", ids.VolleyBuff) > max(C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000, WeakAuras.gcdDuration()) ) then
            KTrig("Multishot") return true end
        
        -- Kichi move to None GCDs
        -- if OffCooldown(ids.Trueshot) and ( PlayerHasBuff(ids.DoubleTapBuff) == false ) then
        --     -- KTrig("Trueshot") return true end
        --     if aura_env.config[tostring(ids.Trueshot)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Trueshot")
        --     elseif aura_env.config[tostring(ids.Trueshot)] ~= true then
        --         KTrig("Trueshot")
        --         return true
        --     end
        -- end

        -- Kichi modify for simc 18bda32_8.9 for more stacks of aimed shot
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( not IsPlayerSpell(ids.SalvoTalent) or not IsPlayerSpell(ids.PrecisionDetonationTalent) or ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) ) and ( (GetSpellChargesFractional(ids.AimedShot) < 2) and PlayerHasBuff(ids.TrueshotBuff) == true or (GetSpellChargesFractional(ids.AimedShot) < 1) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kichi modify for simc 18bda32_8.9 for more aimed shot in volley
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) and PlayerHasBuff(ids.BulletstormBuff) and GetTimeToFullCharges(ids.AimedShot) < WeakAuras.gcdDuration() or PlayerHasBuff(ids.VolleyBuff) ) then
            KTrig("Aimed Shot") return true end
        
        -- Kichi add for PrecisionDetonationTalent
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( TargetHasDebuff(ids.ExplosiveShotDebuff) and IsPlayerSpell(ids.PrecisionDetonationTalent) and PlayerHasBuff(ids.TrickShotsBuff) ) then
            KTrig("Aimed Shot") return true end

        if OffCooldown(ids.RapidFire) and ( GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.BlackArrowTalent) or PlayerHasBuff(ids.DeathblowBuff) == false ) and ( not IsPlayerSpell(ids.NoScopeTalent) or TargetHasSpottersMark ) and ( IsPlayerSpell(ids.NoScopeTalent) or PlayerHasBuff(ids.BulletstormBuff) == false ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) == false and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) ) then 
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and not TargetHasDebuff(ids.SpottersMarkDebuff) and ( not IsPlayerSpell(ids.ShrapnelShotTalent) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.SteadyShot) and ( CurrentFocus + 20 < MaxFocus ) then
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.Multishot) then
            KTrig("Multishot") return true end
    end
    
    
    
    if NearbyEnemies > 2 and IsPlayerSpell(ids.TrickShotsTalent) then
        if Trickshots() then return true end end
    
    if NearbyEnemies > 1 then
        if Cleave() then return true end end
    
    if NearbyEnemies <= 1 then
        if St() then return true end end    

    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")

end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS

function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    return
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

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
    SalvoTalent = 400456,
    SentinelTalent = 450369,
    ShrapnelShotTalent = 473520,
    SmallGameHunterTalent = 459802,
    SymphonicArsenalTalent = 450383,
    TrickShotsTalent = 257621,
    VolleyTalent = 260243,
    WindrunnerQuiverTalent = 473523,
    -- Kichi add for simc 18bda32_8.9 fix
    MagneticGunpowderTalent = 473522,
    IncendiaryAmmunitionTalent = 471428,

    -- Buffs/Debuffs
    BulletstormBuff = 389020,
    DeathblowBuff = 378770,
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
    -- Kichi add for simc 18bda32_8.9 fix
    LunarStormTargetDebuff = 450884,
    VolleyBuff = 260243,
    ExplosiveShotDebuff = 212431,
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
----------Rotation Trig ----------------------------------------------------------------------------------------------
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
        -- print(spellID)
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
