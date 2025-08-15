----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.FrozenOrbRemains = 0
aura_env.ConeOfColdLastUsed = 0
aura_env.FlagKTrigCD = true

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneExplosion = 1449,
    Blizzard = 190356,
    CometStorm = 153595,
    ConeOfCold = 120,
    Flurry = 44614,
    Freeze = 33395,
    FrostNova = 122,
    FrostfireBolt = 431044,
    FrozenOrb = 84714,
    Frostbolt = 116,
    GlacialSpike = 199786,
    IceLance = 30455,
    IceNova = 157997,
    IcyVeins = 12472,
    RayOfFrost = 205021,
    ShiftingPower = 382440,
    
    -- Talents
    ColdestSnapTalent = 417493,
    ColdFrontTalent = 382110,
    CometStormTalent = 153595,
    DeathsChillTalent = 450331,
    DeepShatterTalent = 378749,
    ExcessFrostTalent = 438611,
    FreezingRainTalent = 270233,
    FreezingWindsTalent = 382103,
    FrostfireBoltTalent = 431044,
    FrozenTouchTalent = 205030,
    GlacialSpikeTalent = 199786,
    IceCallerTalent = 236662,
    IsothermicCoreTalent = 431095,
    RayOfFrostTalent = 205021,
    SlickIceTalent = 382144,
    SplinteringColdTalent = 379049,
    SplinteringRayTalent = 418733,
    SplinterstormTalent = 443742,
    UnerringProficiencyTalent = 444974,

    -- Buffs
    BrainFreezeBuff = 190446,
    DeathsChillBuff = 454371,
    ExcessFireBuff = 438624,
    ExcessFrostBuff = 438611,
    FingersOfFrostBuff = 44544,
    FreezingRainBuff = 270232,
    FrostfireEmpowermentBuff = 431177,
    IciclesBuff = 205473,
    IcyVeinsBuff = 12472,
    SpymastersWebBuff = 444959,
    WintersChillDebuff = 228358,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

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
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) and (not nomana) then return false end
    
    local Duration = C_Spell.GetSpellCooldown(spellID).duration
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    if not OffCooldown then return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    if InRange == 0 then
        aura_env.OutOfRange = true
        return false
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
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1691)
    local CurrentMana = UnitPower("player", Enum.PowerType.Mana)
    local MaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    
    local NearbyEnemies = 0
    local NearbyRange = 40
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and select(6, strsplit("-", UnitGUID(unit))) ~= "229296" then -- Skip Orb of Ascendance
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    local CurrentIcicles = GetPlayerStacks(ids.IciclesBuff)
    if IsCasting(ids.Frostbolt) then CurrentIcicles = min(CurrentIcicles + 1, 5) 
    elseif IsCasting(ids.GlacialSpike) then CurrentIcicles = 0 end
    
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
    
    -- Icy Veins
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and ( IsPlayerSpell(ids.FrostfireBoltTalent) or NearbyEnemies >= 3 ) ) then
        ExtraGlows.IcyVeins = true end
    
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and IsPlayerSpell(ids.SplinterstormTalent) ) then
        ExtraGlows.IcyVeins = true end

    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    Variables.Boltspam = IsPlayerSpell(ids.SplinterstormTalent) and IsPlayerSpell(ids.ColdFrontTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent) and IsPlayerSpell(ids.FrozenTouchTalent) or IsPlayerSpell(ids.FrostfireBoltTalent) and IsPlayerSpell(ids.DeepShatterTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent)
    
    Variables.TargetIsFrozen = TargetHasDebuff(ids.IceNova) or TargetHasDebuff(ids.Freeze) or TargetHasDebuff(ids.FrostNova)
    
    local Movement = function()
        --if OffCooldown(ids.IceFloes) and ( PlayerHasBuff(ids.IceFloesBuff) == false ) then
        --    KTrig("Ice Floes") return true end

        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true then
            KTrig("Ice Nova") return true end
        
        if OffCooldown(ids.ConeOfCold) and ( not IsPlayerSpell(ids.ColdestSnapTalent) and NearbyEnemies >= 2 ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end
        
        --if OffCooldown(ids.ArcaneExplosion) and ( (CurrentMana/MaxMana*100) > 30 and NearbyEnemies >= 2 ) then
        --    KTrig("Arcane Explosion") return true end
        
        --if OffCooldown(ids.FireBlast) then
        --    KTrig("Fire Blast") return true end

        
        if OffCooldown(ids.IceLance) then
            KTrig("Ice Lance") return true end
    end
    
    local AoeFf = function()
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not ((aura_env.PrevCast == ids.FrostfireBolt or aura_env.PrevCast2 == ids.FrostfireBolt) and GetTime() - aura_env.PrevCastTime < 0.25 or IsCasting(ids.FrostfireBolt)) ) )  then
            KTrig("Frostfire Bolt") 
            return true end
        
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end

        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and TIME SINCE FIGHT START REMOVE MANUALLY - aura_env.ConeOfColdLastUsed > 8 ) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 ) ) then
            KTrig("Ice Nova") 
            return true end
        
        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.IceLance) and ( GetPlayerStacks(ids.ExcessFireBuff) == 2 and OffCooldown(ids.CometStorm) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            KTrig("Blizzard") return true end

        if OffCooldown(ids.CometStorm) and ( GetRemainingSpellCooldown(ids.ConeOfCold) > 10 or OffCooldown(ids.ConeOfCold) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end

        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            KTrig("Frostfire Bolt") return true end
        
        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) or ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.FrozenOrb) ) or ( IsPlayerSpell(ids.CometStormTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.CometStorm) ) ) ) then
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance")
            return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") 
            return true end
        
        if Movement() then return true end

    end
    
    local AoeSs = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and not OffCooldown(ids.FrozenOrb) and ( (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) or (aura_env.PrevCast == ids.FrozenOrb or IsCasting(ids.FrozenOrb)) and GetRemainingSpellCooldown(ids.CometStorm) > 5 ) and ( not IsPlayerSpell(ids.DeathsChillTalent) or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) >= 15 ) ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or not IsPlayerSpell(ids.GlacialSpikeTalent) ) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Flurry") 
            return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            KTrig("Ice Nova") 
            return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( IsPlayerSpell(ids.UnerringProficiencyTalent) and CurrentTime - aura_env.ConeOfColdLastUsed < 10 and CurrentTime - aura_env.ConeOfColdLastUsed > 7 ) then
            KTrig("Ice Nova") 
            return true end

        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            KTrig("Blizzard") 
            return true end

        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 12 or GetPlayerStacks(ids.DeathsChillBuff) == 12 and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") 
            return true end
        
        if OffCooldown(ids.CometStorm) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) or ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.FrozenOrb) ) or ( IsPlayerSpell(ids.CometStormTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.CometStorm) ) ) ) then
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local CleaveFf = function()
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 4 or GetPlayerStacks(ids.DeathsChillBuff) == 4 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostfire Bolt") return true end

        -- if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    KTrig("Freeze") return true end

        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Ice Nova") return true end

        -- if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or CurrentIcicles >= 3 ) and not (aura_env.PrevCast == ids.Freeze) ) then
        -- if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or CurrentIcicles >= 3 or not IsPlayerSpell(ids.GlacialSpikeTalent) and (aura_env.PrevCast == ids.FrostfireBolt and (GetTime() - aura_env.PrevCastTime < 1 or IsCasting(ids.FrostfireBolt)))  ) and not (aura_env.PrevCast == ids.Freeze) ) then
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.CometStorm) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.Blizzard) and ( PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            KTrig("Blizzard") 
            return true end

        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            else
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            KTrig("Frostfire Bolt") return true end
        
        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
        -- if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) or ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.FrozenOrb) ) or ( IsPlayerSpell(ids.CometStormTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.CometStorm) ) or ( IsPlayerSpell(ids.RayOfFrostTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.RayOfFrost) ) ) ) then
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        -- if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or GetTargetStacks(ids.WintersChillDebuff) > 0 and not Variables.Boltspam ) then
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local CleaveSs = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Flurry") return true end

        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    KTrig("Freeze") return true end

        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Ice Nova") return true end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 30 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        if OffCooldown(ids.RayOfFrost) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end

        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 6 or GetPlayerStacks(ids.DeathsChillBuff) == 6 and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") return true end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.FreezingRainTalent) and IsPlayerSpell(ids.IceCallerTalent) ) then
            KTrig("Blizzard") 
            return true end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local StFf = function()
        -- if OffCooldown(ids.Flurry) and ( Variables.Boltspam and OffCooldown(ids.Flurry) and CurrentIcicles < 5 and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
        -- if OffCooldown(ids.Flurry) and ( Variables.Boltspam and OffCooldown(ids.Flurry) and (CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent)) and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            KTrig("Flurry") return true end
        
        -- if OffCooldown(ids.Flurry) and ( not Variables.Boltspam and OffCooldown(ids.Flurry) and CurrentIcicles < 5 and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
        -- if OffCooldown(ids.Flurry) and ( not Variables.Boltspam and OffCooldown(ids.Flurry) and (CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end

        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end

        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        -- if OffCooldown(ids.ShiftingPower) and ( ( PlayerHasBuff(ids.IcyVeinsBuff) == false or not Variables.Boltspam ) and GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
        -- if OffCooldown(ids.ShiftingPower) and ( ( PlayerHasBuff(ids.IcyVeinsBuff) == false or not Variables.Boltspam ) and GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) or ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.FrozenOrb) ) or ( IsPlayerSpell(ids.CometStormTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.CometStorm) ) or ( IsPlayerSpell(ids.RayOfFrostTalent) and FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.RayOfFrost) ) ) ) then
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local StSs = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end

        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 30 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end

        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies >= 3 then
        AoeFf() return true end
    
    if NearbyEnemies >= 3 then
        AoeSs() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies == 2 then
        CleaveFf() return true end
    
    if NearbyEnemies == 2 then
        CleaveSs() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) then
        StFf() return true end
    
    if StSs() then return true end
    
    KTrig("Clear")
    KTrigCD("Clear")
    
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS

function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast3 = aura_env.PrevCast2
    aura_env.PrevCast2 = aura_env.PrevCast
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    
    if spellID == aura_env.ids.FrozenOrb then
        aura_env.FrozenOrbRemains = GetTime() + 15
    elseif spellID == aura_env.ids.ConeOfCold then
        aura_env.ConeOfColdLastUsed = GetTime()
    end
    
    local KTrigCD = aura_env.KTrigCD
    KTrigCD("Clear")

    return
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load-----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneExplosion = 1449,
    Blizzard = 190356,
    CometStorm = 153595,
    ConeOfCold = 120,
    Flurry = 44614,
    Freeze = 33395,
    FrostNova = 122,
    FrostfireBolt = 431044,
    FrozenOrb = 84714,
    Frostbolt = 116,
    GlacialSpike = 199786,
    IceLance = 30455,
    IceNova = 157997,
    IcyVeins = 12472,
    RayOfFrost = 205021,
    ShiftingPower = 382440,
    
    -- Talents
    ColdestSnapTalent = 417493,
    ColdFrontTalent = 382110,
    CometStormTalent = 153595,
    DeathsChillTalent = 450331,
    DeepShatterTalent = 378749,
    ExcessFrostTalent = 438611,
    FreezingRainTalent = 270233,
    FreezingWindsTalent = 382103,
    FrostfireBoltTalent = 431044,
    FrozenTouchTalent = 205030,
    GlacialSpikeTalent = 199786,
    IceCallerTalent = 236662,
    IsothermicCoreTalent = 431095,
    RayOfFrostTalent = 205021,
    SlickIceTalent = 382144,
    SplinteringColdTalent = 379049,
    SplinteringRayTalent = 418733,
    SplinterstormTalent = 443742,
    UnerringProficiencyTalent = 444974,
    
    -- Buffs
    BrainFreezeBuff = 190446,
    DeathsChillBuff = 454371,
    ExcessFireBuff = 438624,
    ExcessFrostBuff = 438611,
    FingersOfFrostBuff = 44544,
    FreezingRainBuff = 270232,
    FrostfireEmpowermentBuff = 431177,
    IciclesBuff = 205473,
    IcyVeinsBuff = 12472,
    SpymastersWebBuff = 444959,
    WintersChillDebuff = 228358,
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

    if spellID == "Arcane Explosion" then
        firstPriority = ids.ArcaneExplosion
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Blizzard" then
        firstPriority = ids.Blizzard
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Comet Storm" then
        firstPriority = ids.CometStorm
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Cone of Cold" then
        firstPriority = ids.ConeOfCold
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Flurry" then
        firstPriority = ids.Flurry
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Freeze" then
        firstPriority = ids.Freeze
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Frostfire Bolt" then
        firstPriority = ids.FrostfireBolt
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Frozen Orb" then
        firstPriority = ids.FrozenOrb
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Frostbolt" then
        firstPriority = ids.Frostbolt
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Glacial Spike" then
        firstPriority = ids.GlacialSpike
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Ice Lance" then
        firstPriority = ids.IceLance
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Ice Nova" then
        firstPriority = ids.IceNova
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Icy Veins" then
        firstPriority = ids.IcyVeins
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Ray of Frost" then
        firstPriority = ids.RayOfFrost
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end
    if spellID == "Shifting Power" then
        firstPriority = ids.ShiftingPower
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