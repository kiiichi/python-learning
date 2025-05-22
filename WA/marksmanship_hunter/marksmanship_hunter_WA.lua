----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

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
    
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1871)
    
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
    
    -- Trueshot
    if OffCooldown(ids.Trueshot) then
        ExtraGlows.Trueshot = true
    end
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local St = function()
        -- Hold Volley for up to its whole cooldown for multiple target situations, also make sure Rapid Fire will be available to stack extra Bullestorm stacks during it without Aspect of the Hydra.
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and ( IsPlayerSpell(ids.AspectOfTheHydraTalent) or NearbyEnemies == 1 or not HasPreciseShots and ( GetRemainingSpellCooldown(ids.RapidFire) + max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) < 6 or not IsPlayerSpell(ids.BulletstormTalent) ) ) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Prioritize Rapid Fire to trigger Lunar Storm or to stack extra Bulletstorm when Volley Trick Shots is up without Aspect of the Hydra.
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.SentinelTalent) and PlayerHasBuff(ids.LunarStormReadyBuff) or not IsPlayerSpell(ids.AspectOfTheHydraTalent) and IsPlayerSpell(ids.BulletstormTalent) and NearbyEnemies > 1 and PlayerHasBuff(ids.TrickShotsBuff) and ( not HasPreciseShots or not IsPlayerSpell(ids.NoScopeTalent) ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end

        -- Prioritize 4pc double bonus by casting Explosive Shot and following up with Aimed Shot when Lock and Load is up, as long as Precise Shots would not be wasted.
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (SetPieces >= 4) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.LockAndLoadBuff) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (SetPieces >= 4) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.LockAndLoadBuff) ) then
            KTrig("Aimed Shot") return true end
        
        -- For Double Tap, lower Volley in priority until Trueshot has already triggered Double Tap.
        if OffCooldown(ids.Volley) and ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kill Shot/Black Arrow become the primary Precise Shot spenders for Headshot builds. For all Precise Shot spenders, skip to Aimed Shot if both Spotter's Mark and Moving Target are already up.
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Kill Shot") return true end
        
        -- With either Symphonic Arsenal or Small Game Hunter, Multi-Shot can be used as the Precise Shots spender on 2 targets without Aspect of the Hydra.
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( TargetHasSpottersMark or not HasMovingTarget ) and NearbyEnemies > 1 and not IsPlayerSpell(ids.AspectOfTheHydraTalent) and ( IsPlayerSpell(ids.SymphonicArsenalTalent) or IsPlayerSpell(ids.SmallGameHunterTalent) ) ) then
            KTrig("Multishot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( TargetHasSpottersMark or not HasMovingTarget ) ) then
            KTrig("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a bit higher than Rapid Fire if it's close to charge capping and Bulletstorm is up.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            KTrig("Aimed Shot") return true end
        
        -- With Sentinel, hold Rapid Fire for up to 1/3 of its cooldown to trigger Lunar Storm as soon as possible. Don't reset Bulletstorm if it's been stacked over 10 unless it can be re-stacked over 10.
        if OffCooldown(ids.RapidFire) and ( ( not IsPlayerSpell(ids.SentinelTalent) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > GetSpellBaseCooldown(ids.RapidFire)/1000 / 3 ) and ( not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) <= 10 or IsPlayerSpell(ids.AspectOfTheHydraTalent) and NearbyEnemies > 1 ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- Aimed Shot if we've spent Precise Shots to trigger Spotter's Mark and Moving Target. With No Scope this means Precise Shots could be up when Aimed Shot is cast.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( not (SetPieces >= 4) or not IsPlayerSpell(ids.PrecisionDetonationTalent) ) then
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
        
        -- Steady Shot is our only true filler due to the Aimed Shot cdr.
        if OffCooldown(ids.SteadyShot) then
            KTrig("Steady Shot") return true end
    end
        
    local Trickshots = function()
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end

        -- Swap targets to spend Precise Shots from No Scope after applying Spotter's Mark already to the primary target.
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( TargetHasSpottersMark or not HasMovingTarget ) or PlayerHasBuff(ids.TrickShotsBuff) == false ) then
            print("Multishot 1")
            KTrig("Multishot") return true end
    
        -- For Double Tap, lower Volley in priority until Trueshot has already triggered Double Tap.
        if OffCooldown(ids.Volley) and ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Always cast Black Arror with Trick Shots up for Bleak Powder.
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( PlayerHasBuff(ids.TrickShotsBuff) ) then
            print("Black Arrow 1")
            KTrig("Black Arrow") return true end

        -- Prioritize Aimed Shot a bit higher than Rapid Fire if it's close to charge capping and Bulletstorm is up.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) and PlayerHasBuff(ids.BulletstormBuff) and GetTimeToFullCharges(ids.AimedShot) < WeakAuras.gcdDuration() ) then
            print("Aimed Shot 1")
            KTrig("Aimed Shot") return true end
        
        -- With Sentinel, hold Rapid Fire for up to 1/3 of its cooldown to trigger Lunar Storm as soon as possible.
        if OffCooldown(ids.RapidFire) and ( GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.SentinelTalent) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > GetSpellBaseCooldown(ids.RapidFire)/1000 / 3 or PlayerHasBuff(ids.LunarStormReadyBuff) ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- With Precision Detonation, wait until a follow up Aimed Shot would not waste Precise Shots to cast. Require Lock and Load active if using the 4pc.
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and ( PlayerHasBuff(ids.LockAndLoadBuff) or not (SetPieces >= 4) ) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        -- Aimed Shot if we've spent Precise Shots to trigger Spotter's Mark and Moving Target. With No Scope this means Precise Shots could be up when Aimed Shot is cast.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) ) then
            print("Aimed Shot 2")
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.SteadyShot) and ( CurrentFocus + 20 < MaxFocus ) then
            print("Steady Shot 1")
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.Multishot) then
            print("Multishot 2")
            KTrig("Multishot") return true end
    end

    if NearbyEnemies < 3 or not IsPlayerSpell(ids.TrickShotsTalent) then
        if St() then return true end end
    
    if NearbyEnemies > 2 then
        print("1")
        print( GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL")  )
        print("2")
        print( GetSpellBaseCooldown(ids.RapidFire)/1000 / 3)
        if Trickshots() then return true end end
    
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
