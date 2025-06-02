----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

_G.KLIST = { 
    BalanceDruid = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

aura_env.OrbitBreakerBuffStacks = 0
aura_env.LastFullMoon = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AstralCommunion = 400636,
    CelestialAlignment = 194223,
    CelestialAlignmentCooldown = 383410,
    ConvokeTheSpirits = 391528,
    ForceOfNature = 205636,
    FullMoon = 274283,
    FuryOfElune = 202770,
    HalfMoon = 274282,
    Incarnation = 102560,
    Moonfire = 8921,
    NewMoon = 274281,
    Starfall = 191034,
    Starfire = 194153,
    Starsurge = 78674,
    StellarFlare = 202347,
    Sunfire = 93402,
    WarriorOfElune = 202425,
    WildMushroom = 88747,
    Wrath = 190984,
    
    -- Talents
    AetherialKindlingTalent = 327541,
    AstralSmolderTalent = 394058,
    BoundlessMoonlightTalent = 424058,
    ControlOfTheDreamTalent = 434249,
    DreamSurgeTalent = 433831,
    EarlySpringTalent = 428937,
    GreaterAlignmentTalent = 450184,
    IncarnationTalent = 102560,
    LunarCallingTalent = 429523,
    NaturesBalanceTalent = 202430,
    NaturesGraceTalent = 450347,
    OrbitBreakerTalent = 383197,
    OrbitalStrikeTalent = 390378,
    PowerOfTheDreamTalent = 434220,
    SoulOfTheForestTalent = 114107,
    StarlordTalent = 202345,
    TreantsOfTheMoonTalent = 428544,
    UmbralEmbraceTalent = 393760,
    UmbralIntensityTalent = 383195,
    WhirlingStarsTalent = 468743,
    WildSurgesTalent = 406890,
    
    -- Buffs/Debuffs
    BalanceOfAllThingsArcaneBuff = 394050,
    BalanceOfAllThingsNatureBuff = 394049,
    CelestialAlignmentOrbitalStrikeBuff = 383410,
    CelestialAlignmentBuff = 194223,
    DreamstateBuff = 450346,
    FungalGrowthDebuff = 81281,
    IncarnationOrbitalStrikeBuff = 390414,
    IncarnationBuff = 102560,
    EclipseLunarBuff = 48518,
    EclipseSolarBuff = 48517,
    HarmonyOfTheGroveBuff = 428735,
    MoonfireDebuff = 164812,
    SolsticeBuff = 343648,
    StarlordBuff = 279709,
    StarweaversWarpBuff = 393942,
    StarweaversWeftBuff = 393944,
    SunfireDebuff = 164815,
    TouchTheCosmosBuff = 450360,
    UmbralEmbraceBuff = 393763,
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
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1694)
    
    local CurrentEclipseID = (PlayerHasBuff(ids.EclipseSolarBuff) and ids.EclipseSolarBuff or nil)
    if CurrentEclipseID == nil then CurrentEclipseID = (PlayerHasBuff(ids.EclipseLunarBuff) and ids.EclipseLunarBuff or nil) end
    
    local CurrentAstralPower = UnitPower("player", Enum.PowerType.AstralPower)
    local MaxAstralPower = UnitPowerMax("player", Enum.PowerType.AstralPower)
    
    local _, _, _, _, CurrentCast = select(5, UnitCastingInfo("player"))
    local GoingIntoLunar = false
    local GoingIntoSolar = false
    if CurrentCast ~= nil then
        if CurrentCast == ids.Wrath then
            CurrentAstralPower = CurrentAstralPower + 6
            if ( IsPlayerSpell(ids.WildSurgesTalent) ) then
                CurrentAstralPower = CurrentAstralPower + 2
            end
            if C_Spell.GetSpellCastCount(ids.Wrath) == 1 then
                GoingIntoLunar = true
            end
        elseif CurrentCast == ids.Starfire then
            CurrentAstralPower = CurrentAstralPower + 10
            if ( IsPlayerSpell(ids.WildSurgesTalent) ) then
                CurrentAstralPower = CurrentAstralPower + 2
            end
            if C_Spell.GetSpellCastCount(ids.Starfire) == 1 then
                GoingIntoSolar = true
            end
        elseif CurrentCast == ids.NewMoon then
            CurrentAstralPower = CurrentAstralPower + 10
        elseif CurrentCast == ids.HalfMoon then
            CurrentAstralPower = CurrentAstralPower + 20
        elseif CurrentCast == ids.FullMoon then
            CurrentAstralPower = CurrentAstralPower + 40
        end
    end
    
    ids.CaInc = (IsPlayerSpell(ids.IncarnationTalent) and ids.Incarnation or ids.CelestialAlignmentCooldown)
    if IsPlayerSpell(ids.IncarnationTalent) then
        ids.CaIncBuff = IsPlayerSpell(ids.OrbitalStrikeTalent) and ids.IncarnationOrbitalStrikeBuff or ids.IncarnationBuff
    else
        ids.CaIncBuff = IsPlayerSpell(ids.OrbitalStrikeTalent) and ids.CelestialAlignmentOrbitalStrikeBuff or ids.CelestialAlignmentBuff
    end
    local CaIncOffCooldown = (GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation)) or (GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation))
    
    local HasMoonCharge = C_Spell.GetSpellCharges(ids.NewMoon).currentCharges > 2 or (C_Spell.GetSpellCharges(ids.NewMoon).currentCharges == 1 and not IsCasting(ids.NewMoon) and not IsCasting(ids.HalfMoon) and not IsCasting(ids.FullMoon))
    
    local InEclipse = (PlayerHasBuff(ids.EclipseLunarBuff) or GoingIntoLunar) or (PlayerHasBuff(ids.EclipseSolarBuff) or GoingIntoSolar)
    
    local NearbyRange = 45
    local NearbyEnemies = 0
    local MoonfiredEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.MoonfireDebuff, "PLAYER") then
                MoonfiredEnemies = MoonfiredEnemies + 1
            end
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        KTrig("Clear", nil) return end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables.PassiveAsp = 6 / (1-UnitSpellHaste("player")/100) + (IsPlayerSpell(ids.NaturesBalanceTalent) and 1 or 0) + (IsPlayerSpell(ids.OrbitBreakerTalent) and 1 or 0) * (TargetHasDebuff(ids.MoonfireDebuff) and 1 or 0) * ( (aura_env.OrbitBreakerBuffStacks > ( 27 - 2 * (PlayerHasBuff(ids.SolsticeBuff) and 1 or 0) ) ) and 1 or 0) * 24
    
    Variables.ConvokeCondition = FightRemains(60, NearbyRange) < 5 or ( PlayerHasBuff(ids.CaIncBuff) or GetRemainingSpellCooldown(ids.CaInc) > 40 ) and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) or GetRemainingSpellCooldown(ids.ForceOfNature) > 15 )
    
    Variables.EclipseRemains = max(GetRemainingAuraDuration("player", ids.EclipseLunarBuff), GetRemainingAuraDuration("player", ids.EclipseSolarBuff))
    
    Variables.EnterLunar = IsPlayerSpell(ids.LunarCallingTalent) or NearbyEnemies > 3 - ( ( IsPlayerSpell(ids.UmbralEmbraceTalent) or IsPlayerSpell(ids.SoulOfTheForestTalent)) and 1 or 0)
    
    Variables.BoatStacks = GetPlayerStacks(ids.BalanceOfAllThingsArcaneBuff) + GetPlayerStacks(ids.BalanceOfAllThingsNatureBuff)
    
    Variables.CaEffectiveCd = max(GetRemainingSpellCooldown(ids.CaInc), GetRemainingSpellCooldown(ids.ForceOfNature))
    
    Variables.PreCdCondition = ( not IsPlayerSpell(ids.WhirlingStarsTalent) or not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 3 or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > GetTimeToFullCharges(ids.CaInc) + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) ) and GetRemainingSpellCooldown(ids.CaInc) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and not PlayerHasBuff(ids.CaIncBuff)
    
    Variables.CdCondition = Variables.PreCdCondition and ( FightRemains(60, NearbyRange) < ( 15 + 5 * (IsPlayerSpell(ids.IncarnationTalent) and 1 or 0) ) * ( 1 - (IsPlayerSpell(ids.WhirlingStarsTalent) and 1 or 0) * 0.2 ) or TargetTimeToXPct(0, 60) > 10 and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.WarriorOfElune) and NearbyEnemies <= 1 and ( IsPlayerSpell(ids.LunarCallingTalent) or not IsPlayerSpell(ids.LunarCallingTalent) and Variables.EclipseRemains <= 7 ) then
        ExtraGlows.WarriorOfElune = true
    end
    
    if OffCooldown(ids.WarriorOfElune) and NearbyEnemies > 1 and ( not IsPlayerSpell(ids.LunarCallingTalent) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < 7 or IsPlayerSpell(ids.LunarCallingTalent) ) then
        ExtraGlows.WarriorOfElune = true
    end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE APL
    local Aoe = function()
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and InEclipse and (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar) ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starfall) and ( MaxAstralPower - CurrentAstralPower <= Variables.PassiveAsp + 6 ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end

        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.MoonfireDebuff) ) > 6 and (not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or NearbyEnemies - MoonfiredEnemies > 6 or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) and select(2, GetInstanceInfo()) ~= "raid" ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Sunfire) and ( (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.SunfireDebuff) ) > 6 - ( NearbyEnemies / 2 ) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.MoonfireDebuff) ) > 6 and (not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or NearbyEnemies - MoonfiredEnemies > 6 or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) and not select(2, GetInstanceInfo()) ~= "raid" ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and ( not InEclipse or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) ) and not GoingIntoLunar and not Variables.PreCdCondition ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and ( not InEclipse or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) ) and not GoingIntoSolar ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.StellarFlare) and ( IsAuraRefreshable(ids.StellarFlare) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.StellarFlare) > 7 + NearbyEnemies ) and NearbyEnemies < ( 11 - (IsPlayerSpell(ids.UmbralIntensityTalent) and 1 or 0) - ( 2 * (IsPlayerSpell(ids.AstralSmolderTalent) and 1 or 0) ) - (IsPlayerSpell(ids.LunarCallingTalent) and 1 or 0) ) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end
        
        if OffCooldown(ids.ForceOfNature) and ( Variables.PreCdCondition or GetTimeToFullCharges(ids.CaInc) + 5 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 and ( not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 10 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + C_Spell.GetSpellCooldown(ids.ConvokeTheSpirits).duration + 5 ) and ( FightRemains(60, NearbyRange) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 + 5 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.CaInc) + 7 ) or IsPlayerSpell(ids.WhirlingStarsTalent) and IsPlayerSpell(ids.ConvokeTheSpirits) and GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > C_Spell.GetSpellCooldown(ids.ForceOfNature).duration - 10 and FightRemains(60, NearbyRange) > GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 6 ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.FuryOfElune) and ( InEclipse ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Celestial Alignment") return true end
            if aura_env.config[tostring(ids.CelestialAlignment)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Celestial Alignment")
            elseif aura_env.config[tostring(ids.CelestialAlignment)] ~= true then
                KTrig("Celestial Alignment")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Incarnation") return true end
            if aura_env.config[tostring(ids.Incarnation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Incarnation")
            elseif aura_env.config[tostring(ids.Incarnation)] ~= true then
                KTrig("Incarnation")
                return true
            end
        end
        
        if OffCooldown(ids.WarriorOfElune) and ( not IsPlayerSpell(ids.LunarCallingTalent) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < 7 or IsPlayerSpell(ids.LunarCallingTalent) and not PlayerHasBuff(ids.DreamstateBuff) ) then
            -- KTrig("Warrior Of Elune") return true end
            if aura_env.config[tostring(ids.WarriorOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Warrior Of Elune")
            elseif aura_env.config[tostring(ids.WarriorOfElune)] ~= true then
                KTrig("Warrior Of Elune")
                return true
            end
        end
        
        if OffCooldown(ids.Starfire) and ( ( not IsPlayerSpell(ids.LunarCallingTalent) and NearbyEnemies <= 1 ) and ( (PlayerHasBuff(ids.EclipseSolarBuff) or GoingIntoSolar) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) or CurrentEclipseID == nil ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starfall) and ( PlayerHasBuff(ids.StarweaversWarpBuff) or PlayerHasBuff(ids.TouchTheCosmosBuff) ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.StarweaversWeftBuff) ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Starfall) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.ConvokeTheSpirits) and ( ( not PlayerHasBuff(ids.DreamstateBuff) and not PlayerHasBuff(ids.UmbralEmbraceBuff) and NearbyEnemies < 7 or NearbyEnemies <= 1 ) and ( FightRemains(60, NearbyRange) < 5 or ( PlayerHasBuff(ids.CaIncBuff) or GetRemainingSpellCooldown(ids.CaInc) > 40 ) and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) or GetRemainingSpellCooldown(ids.ForceOfNature) > 15 ) ) ) then
            -- KTrig("Convoke The Spirits") return true end
            if aura_env.config[tostring(ids.ConvokeTheSpirits)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Convoke The Spirits")
            elseif aura_env.config[tostring(ids.ConvokeTheSpirits)] ~= true then
                KTrig("Convoke The Spirits")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.NewMoon or IsCasting(ids.FullMoon)) then
            -- KTrig("New Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("New Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("New Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.HalfMoon or IsCasting(ids.NewMoon)) then
            -- KTrig("Half Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Half Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Half Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.FullMoon or IsCasting(ids.HalfMoon)) then
            -- KTrig("Full Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Full Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Full Moon")
                return true
            end
        end
        
        if OffCooldown(ids.WildMushroom) and ( aura_env.PrevCast ~= ids.WildMushroom and not IsCasting(ids.WildMushroom) and not TargetHasDebuff(ids.FungalGrowthDebuff) ) then
            -- KTrig("Wild Mushroom") return true end
            if aura_env.config[tostring(ids.WildMushroom)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wild Mushroom")
            elseif aura_env.config[tostring(ids.WildMushroom)] ~= true then
                KTrig("Wild Mushroom")
                return true
            end
        end
        
        if OffCooldown(ids.ForceOfNature) and ( not IsPlayerSpell(ids.DreamSurgeTalent) ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.Starfire) and ( IsPlayerSpell(ids.LunarCallingTalent) or ( PlayerHasBuff(ids.EclipseLunarBuff) or GoingIntoLunar) and NearbyEnemies > 3 - ( ( IsPlayerSpell(ids.UmbralEmbraceTalent) or IsPlayerSpell(ids.SoulOfTheForestTalent) ) and 1 or 0 ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Wrath) then
            KTrig("Wrath") return true end
    end
    
    -- ST APL
    local St = function()
        if OffCooldown(ids.WarriorOfElune) and ( IsPlayerSpell(ids.LunarCallingTalent) or not IsPlayerSpell(ids.LunarCallingTalent) and Variables.EclipseRemains <= 7 ) then
            -- KTrig("Warrior Of Elune") return true end
            if aura_env.config[tostring(ids.WarriorOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Warrior Of Elune")
            elseif aura_env.config[tostring(ids.WarriorOfElune)] ~= true then
                KTrig("Warrior Of Elune")
                return true
            end
        end

        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar and not Variables.CdCondition ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar and not Variables.CdCondition) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Sunfire) and ( GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 3 or (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) and ( IsPlayerSpell(ids.DreamSurgeTalent) and OffCooldown(ids.ForceOfNature) or IsPlayerSpell(ids.BoundlessMoonlightTalent) and Variables.CdCondition ) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 3 and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) then
            KTrig("Moonfire") return true end
        
        if GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Celestial Alignment") return true end
            if aura_env.config[tostring(ids.CelestialAlignment)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Celestial Alignment")
            elseif aura_env.config[tostring(ids.CelestialAlignment)] ~= true then
                KTrig("Celestial Alignment")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Incarnation") return true end
            if aura_env.config[tostring(ids.Incarnation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Incarnation")
            elseif aura_env.config[tostring(ids.Incarnation)] ~= true then
                KTrig("Incarnation")
                return true
            end
        end
        
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and ( not InEclipse or (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar) ) ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and ( not InEclipse or (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar) ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starsurge) and ( Variables.CdCondition and MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 20 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.ForceOfNature) and ( Variables.PreCdCondition or GetTimeToFullCharges(ids.CaInc) + 5 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 and ( not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 10 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + C_Spell.GetSpellCooldown(ids.ConvokeTheSpirits).duration + 5 ) and ( FightRemains(60, NearbyRange) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 + 5 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.CaInc) + 7 ) or IsPlayerSpell(ids.WhirlingStarsTalent) and IsPlayerSpell(ids.ConvokeTheSpirits) and GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > C_Spell.GetSpellCooldown(ids.ForceOfNature).duration - 10 and FightRemains(60, NearbyRange) > GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 6 ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.FuryOfElune) and ( 5 + Variables.PassiveAsp < MaxAstralPower - CurrentAstralPower ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end
            
        if OffCooldown(ids.Starfall) and ( PlayerHasBuff(ids.StarweaversWarpBuff) ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.Starsurge) and ( IsPlayerSpell(ids.StarlordTalent) and GetPlayerStacks(ids.StarlordBuff) < 3 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Sunfire) and ( (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Starsurge) and ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and Variables.ConvokeCondition and MaxAstralPower - CurrentAstralPower < 50) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.ConvokeTheSpirits) and ( Variables.ConvokeCondition ) then
            -- KTrig("Convoke The Spirits") return true end
            if aura_env.config[tostring(ids.ConvokeTheSpirits)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Convoke The Spirits")
            elseif aura_env.config[tostring(ids.ConvokeTheSpirits)] ~= true then
                KTrig("Convoke The Spirits")
                return true
            end
        end

        if OffCooldown(ids.StellarFlare) and ( IsAuraRefreshable(ids.StellarFlare) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.StellarFlare) > 7 + NearbyEnemies ) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end

        if OffCooldown(ids.Starsurge) and ( GetRemainingAuraDuration("player", ids.StarlordBuff) > 4 and Variables.BoatStacks >= 3 or FightRemains(60, NearbyRange) < 4 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.NewMoon or IsCasting(ids.FullMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 10 or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("New Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("New Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("New Moon")
                return true
            end
        end

        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.HalfMoon or IsCasting(ids.NewMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 20 and ( GetRemainingAuraDuration("player", ids.EclipseLunarBuff) > max(C_Spell.GetSpellInfo(ids.HalfMoon).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EclipseSolarBuff) > max(C_Spell.GetSpellInfo(ids.HalfMoon).castTime/1000, WeakAuras.gcdDuration()) ) or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("Half Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Half Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Half Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.FullMoon or IsCasting(ids.HalfMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 40 and ( GetRemainingAuraDuration("player", ids.EclipseLunarBuff) > max(C_Spell.GetSpellInfo(ids.FullMoon).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EclipseSolarBuff) > max(C_Spell.GetSpellInfo(ids.FullMoon).castTime/1000, WeakAuras.gcdDuration()) ) or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("Full Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Full Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Full Moon")
                return true
            end
        end

        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.StarweaversWeftBuff) or PlayerHasBuff(ids.TouchTheCosmosBuff) ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Starsurge) and ( MaxAstralPower - CurrentAstralPower < Variables.PassiveAsp + 6 + ( 10 + Variables.PassiveAsp ) * ( ( GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < ( max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and 1 or 0 ) ) then
            KTrig("Starsurge") return true end
        
        -- if OffCooldown(ids.ForceOfNature) and ( not IsPlayerSpell(ids.DreamSurgeTalent) ) then
        --     -- KTrig("Force Of Nature") return true end
        --     if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Force Of Nature")
        --     elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
        --         KTrig("Force Of Nature")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.WildMushroom) and ( aura_env.PrevCast ~= ids.WildMushroom and not IsCasting(ids.WildMushroom) and not TargetHasDebuff(ids.FungalGrowthDebuff) ) then
            -- KTrig("Wild Mushroom") return true end
            if aura_env.config[tostring(ids.WildMushroom)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wild Mushroom")
            elseif aura_env.config[tostring(ids.WildMushroom)] ~= true then
                KTrig("Wild Mushroom")
                return true
            end
        end

        if OffCooldown(ids.Starfire) and ( IsPlayerSpell(ids.LunarCallingTalent) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Wrath) then
            KTrig("Wrath") return true end
    end
    
    if NearbyEnemies > 1 then
        Aoe() return true end
    
    if St() then return true end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_PERIODIC_ENERGIZE, CLEU:SPELL_DAMAGE

function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, ...)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        aura_env.PrevCast = spellID
        
        if destGUID == aura_env.ids.FullMoon then
            aura_env.LastFullMoon = GetTime()
        end
    elseif subEvent == "SPELL_PERIODIC_ENERGIZE" then
        if spellID == 202497 then -- Shooting Stars
            aura_env.OrbitBreakerBuffStacks = aura_env.OrbitBreakerBuffStacks + 1
        end
    elseif subEvent == "SPELL_DAMAGE" then
        if spellID == aura_env.ids.FullMoon and GetTime() - aura_env.LastFullMoon > 1 then
            aura_env.OrbitBreakerBuffStacks = 0
        end
    end
    return
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Nameplate Load----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.ShouldShowDebuff = function(unit)
    if UnitAffectingCombat(unit) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.KLIST and _G.KLIST.BalanceDruid then
            for _, ID in ipairs(_G.KLIST.BalanceDruid) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    return false
                end
            end
        end
        return true
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Nameplate Trig----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED, UNIT_THREAT_LIST_UPDATE, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED

function(allstates, event, Unit, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID)
    
    if event == "UNIT_THREAT_LIST_UPDATE" and Unit:find("nameplate") then
        if aura_env.ShouldShowDebuff(Unit) and not allstates[Unit] then
            allstates[Unit] = {
                show = true,
                changed = true,
                icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                unit = Unit
            }
            return true
        end
    end
    
    if event == "NAME_PLATE_UNIT_ADDED" then
        if Unit:find("nameplate") and aura_env.ShouldShowDebuff(Unit) and not allstates[Unit] then
            allstates[Unit] = {
                show = true,
                changed = true,
                icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                unit = Unit
            }
            return true
        end
    end
    
    if event == "NAME_PLATE_UNIT_REMOVED" then
        if allstates[Unit] then
            allstates[Unit] = {
                show = false,
                changed = true
            }
            return true
        end
    end
    
    if subEvent == "SPELL_AURA_APPLIED" then
        if sourceGUID == UnitGUID("player") and spellID == aura_env.config["DebuffID"] then
            local UnitToken = UnitTokenFromGUID(destGUID)
            if UnitToken ~= nil and UnitToken:find("nameplate") then
                allstates[UnitToken] = {
                    show = false,
                    changed = true,
                }
                return true
            end
        end
    elseif subEvent == "SPELL_AURA_REMOVED" then
        if sourceGUID == UnitGUID("player") then
            local UnitToken = UnitTokenFromGUID(destGUID)
            if UniToken ~= nil and UnitToken:find("nameplate") and aura_env.ShouldShowDebuff(UnitToken) and not allstates[UnitToken] then
                allstates[UnitToken] = {
                    show = true,
                    changed = true,
                    icon = C_Spell.GetSpellTexture(aura_env.config["DebuffID"]),
                    unit = UnitToken
                }
                return true
            end
        end
    end
end

