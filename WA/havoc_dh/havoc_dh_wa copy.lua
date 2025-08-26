----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.DemonsurgeAbyssalGazeBuff = false
aura_env.DemonsurgeAnnihilationBuff = false
aura_env.DemonsurgeConsumingFireBuff = false
aura_env.DemonsurgeDeathSweepBuff = false
aura_env.DemonsurgeSigilOfDoomBuff = false
aura_env.ReaversGlaiveLastUsed = 0
aura_env.LastDeathSweep = 999999999

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbyssalGaze = 452497,
    Annihilation = 201427,
    BladeDance = 188499,
    ConsumingFire = 452487,
    ChaosStrike = 162794,
    DeathSweep = 210152,
    DemonsBite = 162243,
    EssenceBreak = 258860,
    EyeBeam = 198013,
    FelBarrage = 258925,
    FelRush = 195072,
    Felblade = 232893,
    GlaiveTempest = 342817,
    ImmolationAura = 258920,
    Metamorphosis = 191427,
    ReaversGlaive = 442294,
    SigilOfDoom = 452490,
    SigilOfFlame = 204596,
    SigilOfSpite = 390163,
    TheHunt = 370965,
    ThrowGlaive = 185123,
    VengefulRetreat = 198793,
    
    -- Talents
    AFireInsideTalent = 427775,
    ArtOfTheGlaiveTalent = 442290,
    BlindFuryTalent = 203550,
    BurningWoundTalent = 391189,
    ChaosTheoryTalent = 389687,
    ChaoticTransformationTalent = 388112,
    CycleOfHatredTalent = 258887,
    DemonBladesTalent = 203555,
    DemonicTalent = 213410,
    DemonsurgeTalent = 452402,
    EssenceBreakTalent = 258860,
    ExergyTalent = 206476,
    FelBarrageTalent = 258925,
    FlameboundTalent = 452413,
    FlamesOfFuryTalent = 389694,
    FuriousThrowsTalent = 393029,
    InertiaTalent = 427640,
    InitiativeTalent = 388108,
    IsolatedPreyTalent = 388113,
    LooksCanKillTalent = 320415,
    QuickenedSigilsTalent = 209281,
    RagefireTalent = 388107,
    RestlessHunterTalent = 390142,
    ScreamingBrutalityTalent = 1220506,
    ShatteredDestinyTalent = 388116,
    SoulscarTalent = 388106,
    StudentOfSufferingTalent = 452412,
    TacticalRetreatTalent = 389688,
    UnboundChaosTalent = 347461,
    
    -- Auras
    ChaosTheoryBuff = 390195,
    CycleOfHatredBuff = 1214887,
    DemonSoulTww3Buff = 1238676,
    DemonsurgeBuff = 452416,
    EssenceBreakDebuff = 320338,
    ExergyBuff = 208628,
    FelBarrageBuff = 258925,
    GlaiveFlurryBuff = 442435,
    ImmolationAuraBuff = 258920,

    ImmolationAuraBuff1 = 427910, -- Kichi add...
    ImmolationAuraBuff2 = 427911,
    ImmolationAuraBuff3 = 427912,
    ImmolationAuraBuff4 = 427913,
    ImmolationAuraBuff5 = 427914,
    ImmolationAuraBuff6 = 427915,
    ImmolationAuraBuff7 = 427916,
    ImmolationAuraBuff8 = 427917,

    InertiaBuff = 1215159,
    InertiaTriggerBuff = 427641,
    InitiativeBuff = 391215,
    InnerDemonBuff = 390145,
    MetamorphosisBuff = 162264,
    NecessarySacrificeBuff = 1217055,
    ReaversMarkDebuff = 442624,
    RendingStrikeBuff = 442442,
    StudentOfSufferingBuff = 453239,
    TacticalRetreatBuff = 389890,
    ThrillOfTheFightDamageBuff = 442688, -- Kichi fix because NG‘s wrong
    ThrillOfTheFightSpeedBuff = 442695, -- Kichi add
    UnboundChaosBuff = 347462,
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
    local FullGCDnum = math.max(1, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end

aura_env.StartTimeFromCooldown = function(spellID)
    local StartTime = C_Spell.GetSpellCooldown(spellID).startTime
    if StartTime == 0  then
        return 99999
    end
    local LeftTime = GetTime() - StartTime
    if LeftTime <= WeakAuras.gcdDuration() then
        return 99999
    end
    return LeftTime
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
    local FullGCD = aura_env.FullGCD

    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------    
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1920)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1868)

    -- Kichi -- 
    local StartTimeFromCooldown = aura_env.StartTimeFromCooldown(ids.TheHunt)
    local HasImmolationAuraBuff = PlayerHasBuff(ids.ImmolationAuraBuff) or PlayerHasBuff(ids.ImmolationAuraBuff1) or PlayerHasBuff(ids.ImmolationAuraBuff2) or PlayerHasBuff(ids.ImmolationAuraBuff3) or PlayerHasBuff(ids.ImmolationAuraBuff4) or PlayerHasBuff(ids.ImmolationAuraBuff5) or PlayerHasBuff(ids.ImmolationAuraBuff6) or PlayerHasBuff(ids.ImmolationAuraBuff7) or PlayerHasBuff(ids.ImmolationAuraBuff8)
    local ImmolationAuraStacks =  (PlayerHasBuff(ids.ImmolationAuraBuff) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff1) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff2) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff3) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff4) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff5) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff6) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff7) and 1 or 0) + (PlayerHasBuff(ids.ImmolationAuraBuff8) and 1 or 0)
    -- local ImmolationAuraMinDuration = ...
    local ImmolationAuraMaxDuration = max(
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff1),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff2),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff3),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff4),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff5),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff6),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff7),
        GetRemainingAuraDuration("player", ids.ImmolationAuraBuff8)
    )

    local CurrentFury = UnitPower("player", Enum.PowerType.Fury)
    local MaxFury = UnitPowerMax("player", Enum.PowerType.Fury)
    
    local NearbyEnemies = 0
    local NearbyRange = 10
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
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

    if OffCooldownNotCasting(ids.TheHunt) and (
    not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
    and not (aura_env.PrevCast == ids.ReaversGlaive)
    and ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) ) 
    and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) or PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff) > 10 )
    or
    not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
    and not (aura_env.PrevCast == ids.ReaversGlaive)
    and ( not OffCooldown(ids.EyeBeam) ) 
    and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) )
    )
    then   
        print("The Hunt 1")
        ExtraGlows.TheHunt = true 
    end
    
    if OffCooldownNotCasting(ids.TheHunt) and (
    not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
    and not (aura_env.PrevCast == ids.ReaversGlaive)
    and ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) ) 
    and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) or PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff) > 10 )
    or
    not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
    and not (aura_env.PrevCast == ids.ReaversGlaive)
    and ( not OffCooldown(ids.EyeBeam) ) 
    and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) )
    )

    and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( (TargetHasDebuff(ids.ReaversMarkDebuff) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent)) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent) ) and FindSpellOverrideByID(ids.ThrowGlaive) ~= ids.ReaversGlaive and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 or PlayerHasBuff(ids.MetamorphosisBuff) == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) ) then
        print("The Hunt 2")
        ExtraGlows.TheHunt = true 
    end

    if OffCooldown(ids.Metamorphosis) and ( ( ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or IsPlayerSpell(ids.CycleOfHatredTalent) and GetRemainingSpellCooldown(ids.EyeBeam) >= 13 ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or TargetHasDebuff(ids.EssenceBreakDebuff) ) and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) and GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or ( CurrentTime - aura_env.LastDeathSweep < 3 ) ) ) and not IsPlayerSpell(ids.InertiaTalent) and not IsPlayerSpell(ids.EssenceBreakTalent) and StartTimeFromCooldown>15 ) then
        print("Metamorphosis 1")
        ExtraGlows.Metamorphosis = true 
    end
    
    if OffCooldown(ids.Metamorphosis) and ( ( GetRemainingSpellCooldown(ids.BladeDance) > 0 and ( ( ( CurrentTime - aura_env.LastDeathSweep < 3 ) or PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and ( PlayerHasBuff(ids.InnerDemonBuff) == false and ( PlayerHasBuff(ids.RendingStrikeBuff) == false or not IsPlayerSpell(ids.RestlessHunterTalent) or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) ) and ( IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.EssenceBreakTalent) ) and StartTimeFromCooldown>15 ) then
        print("Metamorphosis 2")
        ExtraGlows.Metamorphosis = true 
    end


    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)

    -- print("==============")
    -- print( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) )
    -- print(GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff)>0 and GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) < 0.5 and GetRemainingSpellCooldown(ids.BladeDance) > 0 )
    -- print(PlayerHasBuff(ids.InnerDemonBuff) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) )



    ---- Normal GCDs -------------------------------------------------------------------------------------------
    Variables.RgDs = 0
    
    -- Fury generated per second
    Variables.FuryGen = (IsPlayerSpell(ids.DemonBladesTalent) and 1 or 0) * ( 1 / ( 2.6 * GetMeleeHaste() ) * ( (( IsPlayerSpell(ids.DemonsurgeTalent) and PlayerHasBuff(ids.MetamorphosisBuff) ) and 1 or 0) * 3 + 12 ) ) + ImmolationAuraStacks * 6 + (PlayerHasBuff(ids.TacticalRetreatBuff) and 1 or 0) * 10
    
    Variables.FsTier342Piece = SetPieces >= 2
    
    -- Aldrachi Reaver
    local ArCooldown = function()

        -- Kichi move to No GCD part
        -- if OffCooldown(ids.Metamorphosis) and ( ( ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or IsPlayerSpell(ids.CycleOfHatredTalent) and GetRemainingSpellCooldown(ids.EyeBeam) >= 13 ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or TargetHasDebuff(ids.EssenceBreakDebuff) ) and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) and GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or ( CurrentTime - aura_env.LastDeathSweep < 3 ) ) ) and not IsPlayerSpell(ids.InertiaTalent) and not IsPlayerSpell(ids.EssenceBreakTalent) and StartTimeFromCooldown>15 ) then
        --     print("Metamorphosis 1")
        --     -- KTrig("Metamorphosis") return true end
        --     if aura_env.config[tostring(ids.Metamorphosis)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Metamorphosis")
        --     elseif aura_env.config[tostring(ids.Metamorphosis)] ~= true then
        --         KTrig("Metamorphosis")
        --         return true
        --     end
        -- end
        
        -- Kichi move to No GCD part
        -- if OffCooldown(ids.Metamorphosis) and ( ( GetRemainingSpellCooldown(ids.BladeDance) > 0 and ( ( ( CurrentTime - aura_env.LastDeathSweep < 3 ) or PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and ( PlayerHasBuff(ids.InnerDemonBuff) == false and ( PlayerHasBuff(ids.RendingStrikeBuff) == false or not IsPlayerSpell(ids.RestlessHunterTalent) or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) ) and ( IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.EssenceBreakTalent) ) and StartTimeFromCooldown>15 ) then
        --     print("Metamorphosis 2")
        --     -- KTrig("Metamorphosis") return true end
        --     if aura_env.config[tostring(ids.Metamorphosis)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Metamorphosis")
        --     elseif aura_env.config[tostring(ids.Metamorphosis)] ~= true then
        --         KTrig("Metamorphosis")
        --         return true
        --     end
        -- end
        
        -- -- Kichi modify for save TheHunt CD
        -- -- Kichi move to NO GCD part
        -- if OffCooldownNotCasting(ids.TheHunt) 
        -- and not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
        -- and not (aura_env.PrevCast == ids.ReaversGlaive)
        -- and ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) ) 
        -- and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) or PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff)>10 )  -- Need to check if ThrillOfTheFightDamageBuff is necessary

        -- and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( (TargetHasDebuff(ids.ReaversMarkDebuff) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent)) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent) ) and FindSpellOverrideByID(ids.ThrowGlaive) ~= ids.ReaversGlaive and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 or PlayerHasBuff(ids.MetamorphosisBuff) == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) ) then
        --     -- KTrig("The Hunt") return true end
        --     if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("The Hunt")
        --     elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
        --         KTrig("The Hunt")
        --         return true
        --     end
        -- end
        
        -- Kichi fix for time lack
        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingDebuffDuration("target", ids.ReaversMarkDebuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) ) and GetRemainingSpellCooldown(ids.BladeDance) > 0 and StartTimeFromCooldown > 15 ) then
            -- KTrig("Sigil Of Spite") return true end
            if aura_env.config[tostring(ids.SigilOfSpite)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Spite")
            elseif aura_env.config[tostring(ids.SigilOfSpite)] ~= true then
                KTrig("Sigil Of Spite")
                return true
            end
        end

    end
    
    local ArFelBarrage = function()
        Variables.GeneratorUp = GetRemainingSpellCooldown(ids.Felblade) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.SigilOfFlame) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
        
        Variables.GcdDrain = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 32
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.EyeBeam) and ( ( PlayerHasBuff(ids.FelBarrageBuff) == false or CurrentFury > 45 and IsPlayerSpell(ids.BlindFuryTalent) ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.EssenceBreak) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 2 or PlayerHasBuff(ids.FelBarrageBuff) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > GetTimeToNextCharge(ids.ImmolationAura) + 3 ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end

        if OffCooldown(ids.GlaiveTempest) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and NearbyEnemies > 1 ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.FelBarrage) and ( CurrentFury > 100 ) then
            -- KTrig("Fel Barrage") return true end
            if aura_env.config[tostring(ids.FelBarrage)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fel Barrage")
            elseif aura_env.config[tostring(ids.FelBarrage)] ~= true then
                KTrig("Fel Barrage")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and PlayerHasBuff(ids.FelBarrageBuff) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) and CurrentFury > 20 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.FelBarrageBuff) and MaxFury - CurrentFury > 40 ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( CurrentFury - Variables.GcdDrain - 30 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Blade Dance") return true end
        
        -- actions.ar_fel_barrage+=/fel_rush,if=buff.unbound_chaos.up
        
        if OffCooldownNotCasting(ids.TheHunt) and ( CurrentFury > 40 ) then
            -- KTrig("The Hunt") return true end
            if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("The Hunt")
            elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
                KTrig("The Hunt")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingSpellCooldown(ids.FelBarrage) > 0 and GetRemainingSpellCooldown(ids.FelBarrage) < 10 and CurrentFury > 100 or PlayerHasBuff(ids.FelBarrageBuff) and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) * Variables.FuryGen - GetRemainingAuraDuration("player", ids.FelBarrageBuff) * 32 ) > 0 ) ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
    end
    
    local ArMeta = function()
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) or OffCooldown(ids.Metamorphosis) and not IsPlayerSpell(ids.RestlessHunterTalent) ) then
            KTrig("Death Sweep") return true end
        
        -- Kichi add UnitAffectingCombat check
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and ( GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.6 or GetRemainingSpellCooldown(ids.EssenceBreak) > 10 or not IsPlayerSpell(ids.EssenceBreakTalent) ) or IsPlayerSpell(ids.RestlessHunterTalent) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        -- actions.ar_meta+=/annihilation,if=talent.restless_hunter&buff.rending_strike.up&cooldown.essence_break.up&cooldown.metamorphosis.up
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 1 and GetRemainingSpellCooldown(ids.BladeDance) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and GetRemainingSpellCooldown(ids.Metamorphosis) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) then
            KTrig("Felblade") return true end
        
        -- actions.ar_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3
        
        if OffCooldown(ids.EssenceBreak) and ( CurrentFury >= 30 and IsPlayerSpell(ids.RestlessHunterTalent) and OffCooldown(ids.Metamorphosis) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaBuff) or not IsPlayerSpell(ids.InertiaTalent) ) and GetRemainingSpellCooldown(ids.BladeDance) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        -- Kichi add GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) > 0 for correction
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff)>0 and GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) < 0.5 and GetRemainingSpellCooldown(ids.BladeDance) > 0 or PlayerHasBuff(ids.InnerDemonBuff) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) ) then
            print("Annihilation in ArMeta 1")
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and ( GetRemainingSpellCooldown(ids.EyeBeam) <= 0.5 or GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.5 or GetRemainingSpellCooldown(ids.BladeDance) <= 5.5 or GetRemainingAuraDuration("player", ids.InitiativeBuff) < 0 ) ) then       
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and NearbyEnemies > 2 ) then
            KTrig("Fel Rush") return true end
        
        -- actions.ar_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&cooldown.blade_dance.remains<gcd.max*3&cooldown.metamorphosis.remains
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and NearbyEnemies > 2 ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( C_Spell.GetSpellCharges(ids.ImmolationAura).currentCharges == 2 and NearbyEnemies > 1 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.BladeDance) > 0 or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            print("Annihilation in ArMeta 2")
            KTrig("Annihilation") return true end
        
        -- Kichi add from simc
        -- actions.ar_meta+=/essence_break,if=variable.Ktime<20&buff.thrill_of_the_fight_damage.remains>gcd.max*4&buff.metamorphosis.remains>=gcd.max*2&cooldown.metamorphosis.up&cooldown.death_sweep.remains<=gcd.max&buff.inertia.up
        if OffCooldown(ids.EssenceBreak) and (
            StartTimeFromCooldown < 20 and
            PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) and
            GetRemainingAuraDuration("player", ids.ThrillOfTheFightDamageBuff) > FullGCD() * 4 and
            GetRemainingAuraDuration("player", ids.MetamorphosisBuff) >= FullGCD() * 2 and
            OffCooldown(ids.Metamorphosis) and
            GetRemainingSpellCooldown(ids.DeathSweep) <= FullGCD() and
            PlayerHasBuff(ids.InertiaBuff)
        ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end

        if OffCooldown(ids.EssenceBreak) and ( CurrentFury > 20 and ( GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or OffCooldown(ids.BladeDance) ) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and not IsPlayerSpell(ids.InertiaTalent) or PlayerHasBuff(ids.InertiaBuff) ) and ( not IsPlayerSpell(ids.ShatteredDestinyTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 4 ) or FightRemains(60, NearbyRange) < 10 ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.EyeBeam) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.GlaiveTempest) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or CurrentFury > 60 ) ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.ThrowGlaive) and ( IsPlayerSpell(ids.SoulscarTalent) and IsPlayerSpell(ids.FuriousThrowsTalent) and NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( C_Spell.GetSpellCharges(ids.ThrowGlaive).currentCharges == 2 or GetTimeToFullCharges(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.BladeDance) ) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingSpellCooldown(ids.BladeDance) > 0 or CurrentFury > 60 or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < 5 and OffCooldown(ids.Felblade) or TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            print("Annihilation in ArMeta 3")
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 and MaxFury - CurrentFury >= 30 + Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + NearbyEnemies  * (IsPlayerSpell(ids.FlamesOfFuryTalent) and 2 or 0 ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury >= 40 + Variables.FuryGen * 0.5 and not PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and aura_env.OutOfRange == true and MaxFury - CurrentFury >= 30 + Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + NearbyEnemies * ( IsPlayerSpell(ids.FlamesOfFuryTalent) and 2 or 0 ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( aura_env.OutOfRange == true and GetTimeToNextCharge(ids.ImmolationAura) < ( max(GetRemainingSpellCooldown(ids.EyeBeam), GetRemainingAuraDuration("player", ids.MetamorphosisBuff)) ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation then
            print("Annihilation in ArMeta 4")
            KTrig("Annihilation") return true end
        
        -- NG ADDED LOW PRIO IMMO AURA FOR SINGLE TARGET!
        if OffCooldown(ids.ImmolationAura) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ThrowGlaive) and ( not PlayerHasBuff(ids.UnboundChaosBuff) and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and not TargetHasDebuff(ids.EssenceBreakDebuff) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.FelRush) and ( GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
    end
    
    local ArOpener = function()

        print("Aropener")
        -- Kichi remove to Ar list for save TheHunt CD
        -- actions.ar_opener+=/the_hunt
        -- if OffCooldownNotCasting(ids.TheHunt) then
        --     KTrig("The Hunt") return true end

        -- Kichi add for maximun peak damage
        if OffCooldown(ids.ImmolationAura) and aura_env.config["MaxPeakDamage"]==true and IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and not PlayerHasBuff(ids.MetamorphosisBuff) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end

        -- Kichi add UnitAffectingCombat check
        -- actions.ar_opener+=/vengeful_retreat,use_off_gcd=1,if=talent.initiative&time>4&buff.metamorphosis.up&(!talent.inertia|buff.inertia_trigger.down)&buff.inner_demon.down&cooldown.blade_dance.remains&gcd.remains<0.1
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and StartTimeFromCooldown>4 and PlayerHasBuff(ids.MetamorphosisBuff) and (not IsPlayerSpell(ids.InertiaTalent) or PlayerHasBuff(ids.InertiaTriggerBuff) == false) and PlayerHasBuff(ids.InnerDemonBuff) == false and GetRemainingSpellCooldown(ids.BladeDance) > 0 ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end

        -- actions.ar_opener+=/death_sweep,if=!talent.chaotic_transformation&cooldown.metamorphosis.up&buff.glaive_flurry.up
        -- Kichi modify for "not IsPlayerSpell(ids.ChaoticTransformationTalent)" for simc fixed
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( IsPlayerSpell(ids.ChaoticTransformationTalent) and OffCooldown(ids.Metamorphosis) and PlayerHasBuff(ids.GlaiveFlurryBuff) ) then
            KTrig("Death Sweep") return true end

        -- actions.ar_opener+=/annihilation,if=buff.rending_strike.up&buff.thrill_of_the_fight_damage.down
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.RendingStrikeBuff) and not PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) ) then
            print("Annihilation in ArOpener 1")
            KTrig("Annihilation") return true end

        -- actions.ar_opener+=/felblade,if=!talent.inertia&talent.unbound_chaos&buff.unbound_chaos.up&buff.initiative.up&debuff.essence_break.down&active_enemies<=2
        if OffCooldown(ids.Felblade) and ( not IsPlayerSpell(ids.InertiaTalent) and IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and PlayerHasBuff(ids.InitiativeBuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) and NearbyEnemies <= 2 ) then
            KTrig("Felblade") return true end

        -- actions.ar_opener+=/fel_rush,if=!talent.inertia&talent.unbound_chaos&buff.unbound_chaos.up&buff.initiative.up&debuff.essence_break.down&active_enemies>2
        if OffCooldown(ids.FelRush) and ( not IsPlayerSpell(ids.InertiaTalent) and IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and PlayerHasBuff(ids.InitiativeBuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) and NearbyEnemies > 2 ) then
            KTrig("Fel Rush") return true end

        -- actions.ar_opener+=/annihilation,if=talent.inner_demon&buff.inner_demon.up&(!talent.essence_break|cooldown.essence_break.up)
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( IsPlayerSpell(ids.InnerDemonBuff) and PlayerHasBuff(ids.InnerDemonBuff) and (not IsPlayerSpell(ids.EssenceBreakTalent) or OffCooldown(ids.EssenceBreak)) ) then
            print("Annihilation in ArOpener 2")
            KTrig("Annihilation") return true end

        -- actions.ar_opener+=/essence_break,if=(buff.inertia.up|!talent.inertia)&buff.metamorphosis.up&cooldown.blade_dance.remains<=gcd.max&debuff.reavers_mark.up
        if OffCooldown(ids.EssenceBreak) and ( (PlayerHasBuff(ids.InertiaBuff) or not IsPlayerSpell(ids.InertiaTalent)) and PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingSpellCooldown(ids.BladeDance) <= FullGCD() and TargetHasDebuff(ids.ReaversMarkDebuff) ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end

        -- actions.ar_opener+=/felblade,if=buff.inertia_trigger.up&talent.inertia&talent.restless_hunter&cooldown.essence_break.up&cooldown.metamorphosis.up&buff.metamorphosis.up&cooldown.blade_dance.remains<=gcd.max
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and IsPlayerSpell(ids.RestlessHunterTalent) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) and PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingSpellCooldown(ids.BladeDance) <= FullGCD() ) then
            KTrig("Felblade") return true end

        -- # actions.ar_opener+=/fel_rush,if=buff.inertia_trigger.up&talent.inertia&talent.restless_hunter&cooldown.essence_break.up&cooldown.metamorphosis.up&buff.metamorphosis.up&cooldown.blade_dance.remains<=gcd.max

        -- actions.ar_opener+=/felblade,if=talent.inertia&buff.inertia_trigger.up&(buff.inertia.down&buff.metamorphosis.up)&debuff.essence_break.down&active_enemies<=2
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and not PlayerHasBuff(ids.InertiaBuff) and PlayerHasBuff(ids.MetamorphosisBuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) and NearbyEnemies <= 2 ) then
            KTrig("Felblade") return true end

        -- actions.ar_opener+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&(buff.inertia.down&buff.metamorphosis.up)&debuff.essence_break.down&(cooldown.felblade.remains|active_enemies>2)
        if OffCooldown(ids.FelRush) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and not PlayerHasBuff(ids.InertiaBuff) and PlayerHasBuff(ids.MetamorphosisBuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) and (GetRemainingSpellCooldown(ids.Felblade) > 0 or NearbyEnemies > 2) ) then
            KTrig("Fel Rush") return true end

        -- actions.ar_opener+=/felblade,if=talent.inertia&buff.inertia_trigger.up&buff.metamorphosis.up&cooldown.metamorphosis.remains&debuff.essence_break.down
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and not TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            KTrig("Felblade") return true end

        -- # actions.ar_opener+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&buff.metamorphosis.up&cooldown.metamorphosis.remains

        -- actions.ar_opener+=/the_hunt,if=(buff.metamorphosis.up&hero_tree.aldrachi_reaver&talent.shattered_destiny|!talent.shattered_destiny&hero_tree.aldrachi_reaver|hero_tree.felscarred)&(!talent.initiative|talent.inertia|buff.initiative.up|time>5)
        if OffCooldownNotCasting(ids.TheHunt) and (
            (PlayerHasBuff(ids.MetamorphosisBuff) and IsPlayerSpell(ids.ArtOfTheGlaiveTalent) and IsPlayerSpell(ids.ShatteredDestinyTalent))
            or (not IsPlayerSpell(ids.ShatteredDestinyTalent) and IsPlayerSpell(ids.ArtOfTheGlaiveTalent))
            or IsPlayerSpell(ids.DemonsurgeTalent)
        ) and (not IsPlayerSpell(ids.InitiativeTalent) or IsPlayerSpell(ids.InertiaTalent) or PlayerHasBuff(ids.InitiativeBuff) ) then
            -- KTrig("The Hunt") return true end
            if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("The Hunt")
            elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
                KTrig("The Hunt")
                return true
            end
        end

        -- actions.ar_opener+=/felblade,if=fury<40&buff.inertia_trigger.down&debuff.essence_break.down
        -- Kichi modify for simc fixed
        -- actions.ar_opener+=/felblade,if=fury<40&buff.inertia_trigger.down&debuff.essence_break.down&!(talent.a_fire_inside&talent.burning_wound&cooldown.immolation_aura.charges_fractional>1&buff.thrill_of_the_fight_damage.up)
        -- Kichi add "or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff) > 10 or Variables.RgInc" for smooth
        if OffCooldown(ids.Felblade) and CurrentFury < 40 and not PlayerHasBuff(ids.InertiaTriggerBuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) and not (
            IsPlayerSpell(ids.AFireInsideTalent) and
            IsPlayerSpell(ids.BurningWoundTalent) and
            GetSpellChargesFractional(ids.ImmolationAura) > 1 and
            (PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff) > 10 or Variables.RgInc )
        ) then
            KTrig("Felblade") return true end

        -- actions.ar_opener+=/reavers_glaive,if=debuff.reavers_mark.down&debuff.essence_break.down
        if OffCooldown(ids.ThrowGlaive) and FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive and not TargetHasDebuff(ids.ReaversMarkDebuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) then
            -- KTrig("Reavers Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Reavers Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Reavers Glaive")
                return true
            end
        end

        -- Kichi add for maximum peak danmage
        if OffCooldown(ids.EyeBeam) and aura_env.config["MaxPeakDamage"]==true and GetPlayerStacks(ids.CycleOfHatredBuff)<4 and (not PlayerHasBuff(ids.MetamorphosisBuff) or not TargetHasDebuff(ids.EssenceBreakDebuff) and not PlayerHasBuff(ids.InnerDemonBuff) and (GetRemainingSpellCooldown(ids.BladeDance) > 0 or IsPlayerSpell(ids.EssenceBreakTalent) and OffCooldown(ids.EssenceBreak))) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end

        -- actions.ar_opener+=/chaos_strike,if=buff.rending_strike.up&active_enemies>2
        if OffCooldown(ids.ChaosStrike) and PlayerHasBuff(ids.RendingStrikeBuff) and NearbyEnemies > 2 then
            KTrig("Chaos Strike") return true end

        -- actions.ar_opener+=/blade_dance,if=buff.glaive_flurry.up&active_enemies>2
        if OffCooldown(ids.BladeDance) and PlayerHasBuff(ids.GlaiveFlurryBuff) and NearbyEnemies > 2 then
            KTrig("Blade Dance") return true end

        -- actions.ar_opener+=/immolation_aura,if=talent.a_fire_inside&talent.burning_wound&buff.metamorphosis.down
        if OffCooldown(ids.ImmolationAura) and IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and not PlayerHasBuff(ids.MetamorphosisBuff) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end

        -- Kichi add for maximum peak danmage
        if OffCooldown(ids.BladeDance) and aura_env.config["MaxPeakDamage"]==true and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep then
            KTrig("Death Sweep") return true end

        -- actions.ar_opener+=/metamorphosis,if=buff.metamorphosis.up&cooldown.blade_dance.remains>gcd.max*2&buff.inner_demon.down&(!talent.restless_hunter|prev_gcd.1.death_sweep)&(cooldown.essence_break.remains|!talent.essence_break|!talent.chaotic_transformation)
        -- Kichi modify for simc fixed, add "or not OffCooldown(ids.EyeBeam)"
        if OffCooldown(ids.Metamorphosis) and (PlayerHasBuff(ids.MetamorphosisBuff) or not OffCooldown(ids.EyeBeam)) and GetRemainingSpellCooldown(ids.BladeDance) > WeakAuras.gcdDuration() * 2 and not PlayerHasBuff(ids.InnerDemonBuff) and (not IsPlayerSpell(ids.RestlessHunterTalent) or aura_env.PrevCast == ids.DeathSweep) and (GetRemainingSpellCooldown(ids.EssenceBreak) > 0 or not IsPlayerSpell(ids.EssenceBreakTalent) or not IsPlayerSpell(ids.ChaoticTransformationTalent)) then
            -- KTrig("Metamorphosis") return true end
            if aura_env.config[tostring(ids.Metamorphosis)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Metamorphosis")
            elseif aura_env.config[tostring(ids.Metamorphosis)] ~= true then
                KTrig("Metamorphosis")
                return true
            end
        end

        -- Kichi modify for simc fixed
        -- actions.ar_opener+=/sigil_of_spite,if=debuff.reavers_mark.up&(cooldown.eye_beam.remains&cooldown.metamorphosis.remains)&debuff.essence_break.down
        if OffCooldown(ids.SigilOfSpite) and TargetHasDebuff(ids.ReaversMarkDebuff) and not TargetHasDebuff(ids.EssenceBreakDebuff) then
            -- KTrig("Sigil Of Spite") return true end
            if aura_env.config[tostring(ids.SigilOfSpite)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Spite")
            elseif aura_env.config[tostring(ids.SigilOfSpite)] ~= true then
                KTrig("Sigil Of Spite")
                return true
            end
        end

        -- actions.ar_opener+=/eye_beam,if=buff.metamorphosis.down|debuff.essence_break.down&buff.inner_demon.down&(cooldown.blade_dance.remains|talent.essence_break&cooldown.essence_break.up)
        if OffCooldown(ids.EyeBeam) and (not PlayerHasBuff(ids.MetamorphosisBuff) or not TargetHasDebuff(ids.EssenceBreakDebuff) and not PlayerHasBuff(ids.InnerDemonBuff) and (GetRemainingSpellCooldown(ids.BladeDance) > 0 or IsPlayerSpell(ids.EssenceBreakTalent) and OffCooldown(ids.EssenceBreak))) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end

        -- actions.ar_opener+=/essence_break,if=cooldown.blade_dance.remains<gcd.max&!hero_tree.felscarred&!talent.shattered_destiny&buff.metamorphosis.up|cooldown.eye_beam.remains&cooldown.metamorphosis.remains
        if OffCooldown(ids.EssenceBreak) and GetRemainingSpellCooldown(ids.BladeDance) < WeakAuras.gcdDuration() and not IsPlayerSpell(ids.DemonsurgeTalent) and not IsPlayerSpell(ids.ShatteredDestinyTalent) and PlayerHasBuff(ids.MetamorphosisBuff) or GetRemainingSpellCooldown(ids.EyeBeam) > 0 and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end

        -- actions.ar_opener+=/death_sweep
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep then
            KTrig("Death Sweep") return true end

        -- actions.ar_opener+=/annihilation
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation then
            print("Annihilation in ArOpener 3")
            KTrig("Annihilation") return true end

        -- actions.ar_opener+=/demons_bite
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end

        -- actions.ar_opener+=/death_sweep
        if OffCooldown(ids.BladeDance) then
            KTrig("Death Sweep", "Not Good") return true end

        -- actions.ar_opener+=/annihilation
        if OffCooldown(ids.ChaosStrike) then
            print("Annihilation in ArOpener 4")
            KTrig("Annihilation", "Not Good") return true end

        KTrig("Demons Bite", "Not Good")

    end


    local Ar = function()

        Variables.RgInc = PlayerHasBuff(ids.RendingStrikeBuff) == false and PlayerHasBuff(ids.GlaiveFlurryBuff) and OffCooldown(ids.BladeDance) or Variables.RgInc and ( CurrentTime - aura_env.LastDeathSweep < 1 )      
        
        Variables.FelBarrage = IsPlayerSpell(ids.FelBarrageTalent) and ( GetRemainingSpellCooldown(ids.FelBarrage) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 or NearbyEnemies > 2 ) or PlayerHasBuff(ids.FelBarrageBuff) )
        
        if OffCooldown(ids.ChaosStrike) and ( PlayerHasBuff(ids.RendingStrikeBuff) and PlayerHasBuff(ids.GlaiveFlurryBuff) and ( Variables.RgDs == 2 or NearbyEnemies > 2 ) and StartTimeFromCooldown>10 ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.RendingStrikeBuff) and PlayerHasBuff(ids.GlaiveFlurryBuff) and ( Variables.RgDs == 2 or NearbyEnemies > 2 ) ) then
            print("Annihilation in Ar 1")
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.ThrowGlaive) and FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive and ( PlayerHasBuff(ids.GlaiveFlurryBuff) == false and PlayerHasBuff(ids.RendingStrikeBuff) == false and GetRemainingAuraDuration("player", ids.ThrillOfTheFightDamageBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 + ( (Variables.RgDs == 2) and 1 or 0 ) + (( GetRemainingSpellCooldown(ids.TheHunt) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) and 1 or 0) * 3 + (( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and IsPlayerSpell(ids.ShatteredDestinyTalent) ) and 1 or 0) * 3 and ( Variables.RgDs == 0 or Variables.RgDs == 1 and OffCooldown(ids.BladeDance) or Variables.RgDs == 2 and GetRemainingSpellCooldown(ids.BladeDance) > 0 ) and ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or not ( CurrentTime - aura_env.LastDeathSweep < 1 ) or not Variables.RgInc ) and NearbyEnemies < 3 and CurrentTime - aura_env.ReaversGlaiveLastUsed > 5 and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 2 or GetRemainingSpellCooldown(ids.EyeBeam) < 10 or FightRemains(60, NearbyRange) < 10 ) and ( TargetTimeToXPct(0, 50) >= 10 or FightRemains(60, NearbyRange) <= 10 ) or FightRemains(60, NearbyRange) <= 10 ) then
            -- KTrig("Reavers Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Reavers Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Reavers Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.ThrowGlaive) and FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive and ( PlayerHasBuff(ids.GlaiveFlurryBuff) == false and PlayerHasBuff(ids.RendingStrikeBuff) == false and (GetRemainingAuraDuration("player", ids.ThrillOfTheFightDamageBuff) < 4 or OffCooldown(ids.BladeDance)) and ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or not ( CurrentTime - aura_env.LastDeathSweep < 1 ) or not Variables.RgInc ) and NearbyEnemies > 2 and TargetTimeToXPct(0, 50) >= 10 and not TargetHasDebuff(ids.EssenceBreakDebuff) or FightRemains(60, NearbyRange) <= 10 ) then
            -- KTrig("Reavers Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Reavers Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Reavers Glaive")
                return true
            end
        end
        

        if ArCooldown() then return true end

        -- -- Kichi remove from opener to Ar list for save TheHunt CD、
        -- -- Kichi then move to NoneGCD part
        -- if OffCooldownNotCasting(ids.TheHunt) 
        -- and not (FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive) 
        -- and not (aura_env.PrevCast == ids.ReaversGlaive)
        -- and ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) ) 
        -- and not (PlayerHasBuff(ids.GlaiveFlurryBuff) or PlayerHasBuff(ids.RendingStrikeBuff) or PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff)>10 )  -- Need to check if ThrillOfTheFightDamageBuff is necessary
        -- then
        --     -- KTrig("The Hunt") return true end
        --     if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("The Hunt")
        --     elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
        --         KTrig("The Hunt")
        --         return true
        --     end
        -- end


        -- Kichi add and fix for opener
        if ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) and StartTimeFromCooldown<15 ) then
            return ArOpener() end
        
        -- -- Kichi add and fix for opener
        -- if ( (OffCooldown(ids.EyeBeam) or OffCooldown(ids.Metamorphosis) or OffCooldown(ids.EssenceBreak)) and (OffCooldown(ids.TheHunt) or GetRemainingSpellCooldown(ids.TheHunt) > 75) ) then
        --     if ArOpener() then return true end end

        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.BladeDance) > 0 and GetRemainingDebuffDuration("target", ids.ReaversMarkDebuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) and ( GetRemainingAuraDuration("player", ids.NecessarySacrificeBuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) or not (OldSetPieces >= 4) or GetRemainingSpellCooldown(ids.EyeBeam) > 8 ) and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) + (IsPlayerSpell(ids.ShatteredDestinyTalent) and 1 or 0) >= GetRemainingAuraDuration("player", ids.NecessarySacrificeBuff) + 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Sigil Of Spite") return true end
            if aura_env.config[tostring(ids.SigilOfSpite)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Spite")
            elseif aura_env.config[tostring(ids.SigilOfSpite)] ~= true then
                KTrig("Sigil Of Spite")
                return true
            end
        end
        
        if Variables.FelBarrage then
            return ArFelBarrage() end
        
        -- Kichi add (PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) and FightRemains(60, NearbyRange) > 10 ...) for simc fixed
        if OffCooldown(ids.ImmolationAura) and ((PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff)>10) and FightRemains(60, NearbyRange) > 10 or not IsPlayerSpell(ids.RagefireTalent) or not IsPlayerSpell(ids.AFireInsideTalent) ) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > GetTimeToNextCharge(ids.ImmolationAura) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        -- Kichi add (PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) and FightRemains(60, NearbyRange) > 10 ...) for simc fixed
        if OffCooldown(ids.ImmolationAura) and ((PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff)>10) and FightRemains(60, NearbyRange) > 10 or not IsPlayerSpell(ids.RagefireTalent) or not IsPlayerSpell(ids.AFireInsideTalent) ) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        -- actions.ar+=/fel_rush,if=buff.unbound_chaos.up&active_enemies>2&(!talent.inertia|cooldown.eye_beam.remains+2>buff.unbound_chaos.remains)
        
        -- Kichi add time check from simc
        -- Kichi add UnitAffectingCombat("player") check
        -- Lineup Vengeful retreat with Eyebeam casts for Tactical retreat builds
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and IsPlayerSpell(ids.TacticalRetreatTalent) and StartTimeFromCooldown>20 and (OffCooldown(ids.EyeBeam) and ( IsPlayerSpell(ids.RestlessHunterTalent) or GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) ) and (not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false) ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        -- Kichi add UnitAffectingCombat("player") check
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.TacticalRetreatTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 15 and 0 < 0.3 or 0 < 0.2 and GetRemainingSpellCooldown(ids.EyeBeam) <= 0 and GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) and StartTimeFromCooldown>20 and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false ) ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        -- talent.initiative&(cooldown.eye_beam.remains>15&gcd.remains<0.3|gcd.remains<0.2&cooldown.eye_beam.remains<=gcd.remains&(buff.unbound_chaos.up|action.immolation_aura.recharge_time>6|!talent.inertia|talent.momentum)&(cooldown.metamorphosis.remains>10|cooldown.blade_dance.remains<gcd.max*2&(talent.inertia|talent.momentum|buff.metamorphosis.up)))&(!talent.student_of_suffering|cooldown.sigil_of_flame.remains)&time>10&(!variable.trinket1_steroids&!variable.trinket2_steroids|variable.trinket1_steroids&(trinket.1.cooldown.remains<gcd.max*3|trinket.1.cooldown.remains>20)|variable.trinket2_steroids&(trinket.2.cooldown.remains<gcd.max*3|trinket.2.cooldown.remains>20|talent.shattered_destiny))&(cooldown.metamorphosis.remains|hero_tree.aldrachi_reaver)&time>20
        
        if Variables.FelBarrage or not IsPlayerSpell(ids.DemonBladesTalent) and IsPlayerSpell(ids.FelBarrageTalent) and ( PlayerHasBuff(ids.FelBarrageBuff) or OffCooldown(ids.FelBarrage) ) and PlayerHasBuff(ids.MetamorphosisBuff) == false then       
            return ArFelBarrage() end
        
        if OffCooldown(ids.Felblade) and ( not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies == 1 and PlayerHasBuff(ids.UnboundChaosBuff) and PlayerHasBuff(ids.InitiativeBuff) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) <= 0.5 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and IsPlayerSpell(ids.LooksCanKillTalent) or NearbyEnemies > 1 ) ) then
            KTrig("Felblade") return true end
        
        if PlayerHasBuff(ids.MetamorphosisBuff) then
            return ArMeta() end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaBuff) == false and GetRemainingSpellCooldown(ids.BladeDance) < 4 and ( GetRemainingSpellCooldown(ids.EyeBeam) > 5 and GetRemainingSpellCooldown(ids.EyeBeam) > GetRemainingAuraDuration("player", ids.UnboundChaosBuff) or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.VengefulRetreat) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + 1 ) ) then
            KTrig("Felblade") return true end
        
        -- Kichi add (PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) and FightRemains(60, NearbyRange) > 10 ...) for simc fixed
        if OffCooldown(ids.ImmolationAura) and ((PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or GetRemainingAuraDuration("player", ids.ThrillOfTheFightSpeedBuff)>10) and FightRemains(60, NearbyRange) > 10 or not IsPlayerSpell(ids.RagefireTalent) or not IsPlayerSpell(ids.AFireInsideTalent) ) and ( IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        -- Kichi add ( FightRemains(60, NearbyRange) > 10 ) for simc fixed
        if OffCooldown(ids.ImmolationAura) and ( FightRemains(60, NearbyRange) > 10 ) and ( FightRemains(60, NearbyRange) < 15 and GetRemainingSpellCooldown(ids.BladeDance) > 0 and IsPlayerSpell(ids.RagefireTalent) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        -- # actions.ar+=/blade_dance,if=buff.rending_strike.down&buff.glaive_flurry.up&active_enemies>2&cooldown.eye_beam.remains<=4&buff.thrill_of_the_fight_damage.remains<gcd.max&raid_event.adds.remains>10&(cooldown.immolation_aura.remains|!talent.burning_wound) actions.ar+=/eye_beam,if=!talent.essence_break&(!talent.chaotic_transformation|cooldown.metamorphosis.remains<5+3*talent.shattered_destiny|cooldown.metamorphosis.remains>10)&(active_enemies>desired_targets*2|raid_event.adds.in>30-talent.cycle_of_hatred.rank*2.5*buff.cycle_of_hatred.stack)&(!talent.initiative|cooldown.vengeful_retreat.remains>5|cooldown.vengeful_retreat.up&active_enemies>2|talent.shattered_destiny)
        
        -- Kichi add again and not PlayerHasBuff(ids.GlaiveFlurryBuff) , why he remove?
        -- NG Removed "and not PlayerHasBuff(ids.GlaiveFlurryBuff)"
        if OffCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.BladeDance) < 7 and ( ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or (not PlayerHasBuff(ids.RendingStrikeBuff) and not PlayerHasBuff(ids.GlaiveFlurryBuff)) ) ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        -- talent.essence_break&(cooldown.essence_break.remains<gcd.max*2+5*talent.shattered_destiny|talent.shattered_destiny&cooldown.essence_break.remains>10)&(cooldown.blade_dance.remains<7|raid_event.adds.up)&(!talent.initiative|cooldown.vengeful_retreat.remains>10|!talent.inertia&!talent.momentum|raid_event.adds.up)&(active_enemies+3>=desired_targets+raid_event.adds.count|raid_event.adds.in>30-talent.cycle_of_hatred.rank*6)&(!talent.inertia|buff.inertia_trigger.up|action.immolation_aura.charges=0&action.immolation_aura.recharge_time>5)&(!raid_event.adds.up|raid_event.adds.remains>8)&(!variable.trinket1_steroids&!variable.trinket2_steroids|variable.trinket1_steroids&(trinket.1.cooldown.remains<gcd.max*3|trinket.1.cooldown.remains>20)|variable.trinket2_steroids&(trinket.2.cooldown.remains<gcd.max*3|trinket.2.cooldown.remains>20))|fight_remains<10
        
        if OffCooldown(ids.BladeDance) and ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or NearbyEnemies >= 2 and PlayerHasBuff(ids.GlaiveFlurryBuff) ) and PlayerHasBuff(ids.RendingStrikeBuff) == false ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( PlayerHasBuff(ids.RendingStrikeBuff) ) then
            KTrig("Chaos Strike") return true end
        
        -- Kichi modify CurrentFury check from simc fixed
        if OffCooldown(ids.SigilOfFlame) and (NearbyEnemies > 3 or TargetHasDebuff(ids.EssenceBreakDebuff) == false) and CurrentFury<70 then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury >= 40 + Variables.FuryGen * 0.5 and not PlayerHasBuff(ids.InertiaTriggerBuff) and ( not IsPlayerSpell(ids.BlindFuryTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 5 ) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.GlaiveTempest) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and ( TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.FuriousThrowsTalent) and IsPlayerSpell(ids.SoulscarTalent) and ( not IsPlayerSpell(ids.ScreamingBrutalityTalent) or GetSpellChargesFractional(ids.ThrowGlaive) >= 2 or GetTimeToFullCharges(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.BladeDance) ) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and ( GetRemainingSpellCooldown(ids.EyeBeam) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 or CurrentFury >= 70 - Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) - ( IsPlayerSpell(ids.BlindFuryTalent) and 30 or 0) ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.Felblade) and ( not IsPlayerSpell(ids.AFireInsideTalent) and CurrentFury < 40 ) then
            KTrig("Felblade") return true end
        
        -- NG REMOVED "NearbyEnemies > 2"
        if OffCooldown(ids.ImmolationAura) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        -- Kichi modify CurrentFury check from simc fixed
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.OutOfRange == true and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > 25 )  and CurrentFury<70 ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and NearbyEnemies > 1 ) then
            KTrig("Fel Rush") return true end
    end
    
    -- Fel-Scarred
    local FsCooldown = function()
        if OffCooldown(ids.Metamorphosis) and ( ( ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or IsPlayerSpell(ids.CycleOfHatredTalent) and GetRemainingSpellCooldown(ids.EyeBeam) >= 13 ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or TargetHasDebuff(ids.EssenceBreakDebuff) ) and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) and GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) and not IsPlayerSpell(ids.InertiaTalent) and not IsPlayerSpell(ids.EssenceBreakTalent) ) then
            -- KTrig("Metamorphosis") return true end
            if aura_env.config[tostring(ids.Metamorphosis)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Metamorphosis")
            elseif aura_env.config[tostring(ids.Metamorphosis)] ~= true then
                KTrig("Metamorphosis")
                return true
            end
        end
        
        if OffCooldown(ids.Metamorphosis) and ( ( GetRemainingSpellCooldown(ids.BladeDance) > 0 and ( ( ( CurrentTime - aura_env.LastDeathSweep < 3 ) or PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and ( PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) ) and ( IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.EssenceBreakTalent) ) ) then       
            -- KTrig("Metamorphosis") return true end
            if aura_env.config[tostring(ids.Metamorphosis)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Metamorphosis")
            elseif aura_env.config[tostring(ids.Metamorphosis)] ~= true then
                KTrig("Metamorphosis")
                return true
            end
        end
        
        if OffCooldownNotCasting(ids.TheHunt) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 or PlayerHasBuff(ids.MetamorphosisBuff) == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) and PlayerHasBuff(ids.MetamorphosisBuff) == false or FightRemains(60, NearbyRange) <= 30 ) then
            -- KTrig("The Hunt") return true end
            if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("The Hunt")
            elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
                KTrig("The Hunt")
                return true
            end
        end
        
        -- actions.fs_cooldown+=/the_hunt,if=debuff.essence_break.down&(active_enemies>=desired_targets+raid_event.adds.count|raid_event.adds.in>90)&(debuff.reavers_mark.up|!hero_tree.aldrachi_reaver)&buff.reavers_glaive.down&(buff.metamorphosis.remains>5|buff.metamorphosis.down)&(!talent.initiative|buff.initiative.up|time>5)&time>5&(!talent.inertia&buff.unbound_chaos.down|buff.inertia_trigger.down)&(!talent.inertia&(hero_tree.aldrachi_reaver|buff.metamorphosis.down)|hero_tree.felscarred&cooldown.metamorphosis.up|fight_remains<cooldown.metamorphosis.remains)
        
        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.BladeDance) ) then
            -- KTrig("Sigil Of Spite") return true end
            if aura_env.config[tostring(ids.SigilOfSpite)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Spite")
            elseif aura_env.config[tostring(ids.SigilOfSpite)] ~= true then
                KTrig("Sigil Of Spite")
                return true
            end
        end
    end
    
    local FsFelBarrage = function()
        Variables.GeneratorUp = GetRemainingSpellCooldown(ids.Felblade) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.SigilOfFlame) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
        
        Variables.GcdDrain = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 32
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.EyeBeam) and ( ( PlayerHasBuff(ids.FelBarrageBuff) == false or CurrentFury > 45 and IsPlayerSpell(ids.BlindFuryTalent) ) and ( NearbyEnemies > 1 ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.EssenceBreak) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 2 or PlayerHasBuff(ids.FelBarrageBuff) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > GetTimeToNextCharge(ids.ImmolationAura) + 3 ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.GlaiveTempest) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and NearbyEnemies > 1 ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.FelBarrage) and ( CurrentFury > 100 ) then
            -- KTrig("Fel Barrage") return true end
            if aura_env.config[tostring(ids.FelBarrage)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fel Barrage")
            elseif aura_env.config[tostring(ids.FelBarrage)] ~= true then
                KTrig("Fel Barrage")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and PlayerHasBuff(ids.FelBarrageBuff) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) and CurrentFury > 20 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 30 ) ) then
            -- KTrig("Sigil Of Flame") return true end 
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.FelBarrageBuff) and MaxFury - CurrentFury > 40 and OffCooldown(ids.Felblade) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( CurrentFury - Variables.GcdDrain - 30 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.TheHunt) and ( CurrentFury > 40 ) then
            -- KTrig("The Hunt") return true end
            if aura_env.config[tostring(ids.TheHunt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("The Hunt")
            elseif aura_env.config[tostring(ids.TheHunt)] ~= true then
                KTrig("The Hunt")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingSpellCooldown(ids.FelBarrage) > 0 and GetRemainingSpellCooldown(ids.FelBarrage) < 10 and CurrentFury > 100 or PlayerHasBuff(ids.FelBarrageBuff) and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) * Variables.FuryGen - GetRemainingAuraDuration("player", ids.FelBarrageBuff) * 32 ) > 0 ) ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
    end
    
    local FsMeta = function()
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) and ( not HasImmolationAuraBuff or not Variables.FsTier342Piece ) and ( not PlayerHasBuff(ids.DemonSoulTww3Buff) or not SetPieces >= 4 ) or aura_env.PrevCast == ids.Metamorphosis and not Variables.FsTier342Piece or aura_env.DemonsurgeDeathSweepBuff and Variables.FsTier342Piece and GetRemainingAuraDuration("player", ids.DemonsurgeBuff) < 5 or ( Variables.FsTier342Piece and OffCooldown(ids.Metamorphosis) and IsPlayerSpell(ids.InertiaTalent) ) or NearbyEnemies >= 3 and aura_env.DemonsurgeDeathSweepBuff and ( not IsPlayerSpell(ids.InertiaTalent) or not PlayerHasBuff(ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.VengefulRetreat) > 0 or PlayerHasBuff(ids.InertiaBuff) ) and ( not IsPlayerSpell(ids.EssenceBreak) or TargetHasDebuff(ids.EssenceBreakDebuff) or GetRemainingSpellCooldown(ids.EssenceBreak) >= 5 ) ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and IsPlayerSpell(ids.StudentOfSufferingTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and 
            ( IsPlayerSpell(ids.StudentOfSufferingTalent) and 
                ( ( IsPlayerSpell(ids.EssenceBreakTalent) and GetRemainingSpellCooldown(ids.EssenceBreak) > 30 - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or 
                        GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + (IsPlayerSpell(ids.InertiaTalent) and 1 or 0) and 
                        (( GetRemainingSpellCooldown(ids.VengefulRetreat) <= WeakAuras.gcdDuration() or PlayerHasBuff(ids.InitiativeBuff) ) and 1 or 0) + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( ( GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and 1 or 0 ) ) or
                    ( not IsPlayerSpell(ids.EssenceBreakTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= 10 or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) ) ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        -- Kichi add UnitAffectingCombat("player") check
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and ( 0 < 0.3 or IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and ( GetPlayerStacks(ids.CycleOfHatredBuff) == 2 or GetPlayerStacks(ids.CycleOfHatredBuff) == 3 ) ) and ( GetRemainingSpellCooldown(ids.Metamorphosis) and ( aura_env.DemonsurgeAnnihilationBuff == false and aura_env.DemonsurgeDeathSweepBuff == false ) or IsPlayerSpell(ids.RestlessHunterTalent) and aura_env.DemonsurgeAnnihilationBuff == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) > 18 or GetRemainingSpellCooldown(ids.EssenceBreak) <= 0 + (IsPlayerSpell(ids.InertiaTalent) and 1 or 0) * 1.5 and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or ( PlayerHasBuff(ids.StudentOfSufferingBuff) or GetRemainingSpellCooldown(ids.SigilOfFlame) > 5 ) ) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 5 or GetRemainingSpellCooldown(ids.EyeBeam) <= 0 or OffCooldown(ids.EyeBeam) ) or OffCooldown(ids.Metamorphosis) and GetPlayerStacks(ids.DemonsurgeBuff) > 1 and IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.InertiaTalent) ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        -- Kichi add UnitAffectingCombat("player") check
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( Variables.FsTier342Piece and not PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InitiativeTalent) ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and Variables.FsTier342Piece and PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            KTrig("Felblade") return true end
        
        -- &active_enemies<3 actions.fs_meta+=/fel_rush,if=talent.inertia&variable.fs_tier34_2piece&buff.inertia_trigger.up&(active_enemies>=3|cooldown.felblade.remains) actions.fs_meta+=/felblade,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&hero_tree.aldrachi_reaver&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3 actions.fs_meta+=/felblade,if=talent.inertia&buff.inertia_trigger.up&debuff.essence_break.down&buff.demonsurge_hardcast.up&buff.demonsurge.stack=0&buff.demonsurge_death_sweep.up actions.fs_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&debuff.essence_break.down&buff.demonsurge_hardcast.up&buff.demonsurge.stack=0&buff.demonsurge_death_sweep.up&cooldown.felblade.remains actions.fs_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&hero_tree.aldrachi_reaver&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3 actions.fs_meta+=/essence_break,if=fury>=30&talent.restless_hunter&cooldown.metamorphosis.up&(talent.inertia&buff.inertia.up|!talent.inertia)&cooldown.blade_dance.remains<=gcd.max&(hero_tree.felscarred&buff.demonsurge_annihilation.down|hero_tree.aldrachi_reaver)
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( ( IsPlayerSpell(ids.EssenceBreakTalent) and aura_env.DemonsurgeDeathSweepBuff and ( PlayerHasBuff(ids.InertiaBuff) and ( GetRemainingSpellCooldown(ids.EssenceBreak) > GetRemainingAuraDuration("player", ids.InertiaBuff) or not IsPlayerSpell(ids.EssenceBreakTalent) ) or GetRemainingSpellCooldown(ids.Metamorphosis) <= 5 and PlayerHasBuff(ids.InertiaTriggerBuff) == false or PlayerHasBuff(ids.InertiaBuff) and aura_env.DemonsurgeAbyssalGazeBuff ) or IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) == false and GetRemainingSpellCooldown(ids.VengefulRetreat) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and PlayerHasBuff(ids.InertiaBuff) == false ) and ( not Variables.FsTier342Piece or not IsPlayerSpell(ids.InertiaTalent) or NearbyEnemies >= 3 and TargetHasDebuff(ids.EssenceBreakDebuff) ) ) then
            KTrig("Death Sweep") return true end
        
        -- Kichi add >0
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.BladeDance) < GetRemainingAuraDuration("player", ids.MetamorphosisBuff) or GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff)>0 and GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) < 0.5 or IsPlayerSpell(ids.RestlessHunterTalent) and ( aura_env.DemonsurgeAnnihilationBuff or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) and PlayerHasBuff(ids.InnerDemonBuff) ) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( ( aura_env.DemonsurgeAnnihilationBuff and IsPlayerSpell(ids.RestlessHunterTalent) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.BladeDance) or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.BladeDance) <= 5.5 and ( IsPlayerSpell(ids.EssenceBreakTalent) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.5 or not IsPlayerSpell(ids.EssenceBreakTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) >= GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.BladeDance) <= 4.5 and ( GetRemainingSpellCooldown(ids.BladeDance) or GetRemainingSpellCooldown(ids.BladeDance) <= 0.5 ) ) or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) <= 5.5 + (IsPlayerSpell(ids.ShatteredDestinyTalent) and 1 or 0) * 2 ) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.Felblade) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.6 or NearbyEnemies > 2 ) ) then
            KTrig("Fel Rush") return true end
        
        -- |cooldown.felblade.remains&buff.metamorphosis.remains<=5.6-talent.shattered_destiny*gcd.max*2) actions.fs_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.metamorphosis.remains&(!hero_tree.felscarred|cooldown.eye_beam.remains&(!buff.demonsurge_hardcast.up|cooldown.essence_break.remains<=0.5)|buff.demonsurge_hardcast.up&cooldown.eye_beam.remains<=0.6) actions.fs_meta+=/fel_rush,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.metamorphosis.remains&(!hero_tree.felscarred|cooldown.eye_beam.remains&(!buff.demonsurge_hardcast.up|cooldown.essence_break.remains<=0.5)|buff.demonsurge_hardcast.up&cooldown.eye_beam.remains<=gcd.max)&(active_enemies>2|hero_tree.felscarred)&cooldown.felblade.remains actions.fs_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.blade_dance.remains<gcd.max*3&(!hero_tree.felscarred|cooldown.eye_beam.remains)&cooldown.metamorphosis.remains actions.fs_meta+=/fel_rush,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.blade_dance.remains<gcd.max*3&(!hero_tree.felscarred|cooldown.eye_beam.remains)&cooldown.metamorphosis.remains&(active_enemies>2|hero_tree.felscarred) actions.fs_meta+=/immolation_aura,if=charges=2&active_enemies>1&debuff.essence_break.down
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 1 or IsPlayerSpell(ids.AFireInsideTalent) and ( IsPlayerSpell(ids.IsolatedPreyTalent) or Variables.FsTier342Piece ) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( NearbyEnemies >= 3 or GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or Variables.FsTier342Piece and ImmolationAuraMaxDuration <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or Variables.FsTier342Piece and not HasImmolationAuraBuff ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) and GetRemainingSpellCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            KTrig("Annihilation") return true end
        
        -- actions.fs_meta+=/sigil_of_doom,if=debuff.essence_break.down&(buff.demonsurge_sigil_of_doom.up&cooldown.blade_dance.remains|talent.student_of_suffering&((talent.essence_break&cooldown.essence_break.remains>30-gcd.max|cooldown.essence_break.remains<=gcd.max*3&(!talent.inertia|buff.inertia_trigger.up))|(!talent.essence_break&(cooldown.eye_beam.remains>=30|cooldown.eye_beam.remains<=gcd.max))))
        
        if OffCooldown(ids.EssenceBreak) and ( CurrentFury > 20 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and not Variables.FsTier342Piece or Variables.FsTier342Piece and PlayerHasBuff(ids.MetamorphosisBuff) ) and ( PlayerHasBuff(ids.InertiaTriggerBuff) == false or PlayerHasBuff(ids.InertiaBuff) and GetRemainingAuraDuration("player", ids.InertiaBuff) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not IsPlayerSpell(ids.InertiaTalent) or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) <= GetRemainingSpellCooldown(ids.Metamorphosis) ) and ( not IsPlayerSpell(ids.ShatteredDestinyTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 4 ) and ( NearbyEnemies > 1 or GetRemainingSpellCooldown(ids.Metamorphosis) > 5 and GetRemainingSpellCooldown(ids.EyeBeam) ) and ( not GetPlayerStacks(ids.CycleOfHatredBuff) == 3 or PlayerHasBuff(ids.InitiativeBuff) or not IsPlayerSpell(ids.InitiativeTalent) or not IsPlayerSpell(ids.CycleOfHatredTalent) ) or FightRemains(60, NearbyRange) < 5 ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and not aura_env.DemonsurgeDeathSweepBuff and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or aura_env.DemonsurgeSigilOfDoomBuff ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and PlayerHasBuff(ids.DemonsurgeBuff) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and aura_env.DemonsurgeConsumingFireBuff and GetRemainingSpellCooldown(ids.BladeDance) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and MaxFury - CurrentFury > 10 + Variables.FuryGen ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.EyeBeam) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) or SetPieces < 4 ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.EyeBeam) and ( aura_env.DemonsurgeAbyssalGazeBuff and TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false and ( GetPlayerStacks(ids.CycleOfHatredBuff) < 4 or GetRemainingSpellCooldown(ids.EssenceBreak) >= 20 - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) or GetRemainingSpellCooldown(ids.SigilOfFlame) and IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or not IsPlayerSpell(ids.EssenceBreak) ) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) >= 7 or SetPieces < 4 ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( ( GetRemainingSpellCooldown(ids.EssenceBreak) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) or not IsPlayerSpell(ids.EssenceBreakTalent) ) and ( not HasImmolationAuraBuff or not Variables.FsTier342Piece or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) and ( not PlayerHasBuff(ids.DemonSoulTww3Buff) or SetPieces < 4 or NearbyEnemies >= 3 or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) ) then
            KTrig("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or CurrentFury > 60 ) ) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        -- actions.fs_meta+=/throw_glaive,if=talent.soulscar&talent.furious_throws&active_enemies>1&debuff.essence_break.down
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingSpellCooldown(ids.BladeDance) or CurrentFury > 60 or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < 5 ) then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 and aura_env.OutOfRange and not IsPlayerSpell(ids.StudentOfSufferingTalent) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        -- actions.fs_meta+=/felblade,if=(buff.out_of_range.down|fury.deficit>40+variable.fury_gen*(0.5%gcd.max))&!buff.inertia.up actions.fs_meta+=/sigil_of_flame,if=debuff.essence_break.down&buff.out_of_range.down
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and aura_env.OutOfRange == true and GetTimeToNextCharge(ids.ImmolationAura) < ( max(GetRemainingSpellCooldown(ids.EyeBeam), GetRemainingAuraDuration("player", ids.MetamorphosisBuff) ) ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( ( aura_env.OutOfRange == true or MaxFury - CurrentFury > 40 + Variables.FuryGen * ( 0.5 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) and not PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation then
            KTrig("Annihilation") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.FelRush) and ( GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
            
        -- NG ADDED LOW PRIO IMMO AURA FOR SINGLE TARGET!
        if OffCooldown(ids.ImmolationAura) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
    end
    
    local Fs = function()
        Variables.FelBarrage = IsPlayerSpell(ids.FelBarrageTalent) and ( GetRemainingSpellCooldown(ids.FelBarrage) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 or NearbyEnemies > 2 ) or PlayerHasBuff(ids.FelBarrageBuff) )
        
        if FsCooldown() then return true end
        
        if Variables.FelBarrage then
            return FsFelBarrage() end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > GetTimeToNextCharge(ids.ImmolationAura) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies <= 2 and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.EyeBeam) - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 <= GetRemainingAuraDuration("player", ids.UnboundChaosBuff) or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) ) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies > 3 and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.EyeBeam) - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 <= GetRemainingAuraDuration("player", ids.UnboundChaosBuff) ) ) then
            KTrig("Fel Rush") return true end
        
        if PlayerHasBuff(ids.MetamorphosisBuff) then
            return FsMeta() end
        
        -- Kichi add UnitAffectingCombat("player") check
        if OffCooldown(ids.VengefulRetreat) and UnitAffectingCombat("player") and ( IsPlayerSpell(ids.InitiativeTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 15 and 0 < 0.3 or 0 < 0.2 and GetRemainingSpellCooldown(ids.EyeBeam) <= 0 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.SigilOfFlame) ) and ( GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.SigilOfFlame) or GetRemainingSpellCooldown(ids.EssenceBreak) >= 18 or not IsPlayerSpell(ids.StudentOfSufferingTalent) ) and GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) then
            -- KTrig("Vengeful Retreat") return true end
            if aura_env.config[tostring(ids.VengefulRetreat)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vengeful Retreat")
            elseif aura_env.config[tostring(ids.VengefulRetreat)] ~= true then
                KTrig("Vengeful Retreat")
                return true
            end
        end
        
        if Variables.FelBarrage or not IsPlayerSpell(ids.DemonBladesTalent) and IsPlayerSpell(ids.FelBarrageTalent) and ( PlayerHasBuff(ids.FelBarrageBuff) or OffCooldown(ids.FelBarrage) ) and PlayerHasBuff(ids.MetamorphosisBuff) == false then
            return FsFelBarrage() end
        
        -- actions.fs+=/felblade,if=!talent.inertia&active_enemies=1&buff.unbound_chaos.up&buff.initiative.up&debuff.essence_break.down&buff.metamorphosis.down actions.fs+=/felblade,if=buff.inertia_trigger.up&talent.inertia&buff.inertia.down&cooldown.blade_dance.remains<4&cooldown.eye_beam.remains>5&cooldown.eye_beam.remains>buff.unbound_chaos.remains-2 actions.fs+=/fel_rush,if=buff.unbound_chaos.up&talent.inertia&buff.inertia.down&cooldown.blade_dance.remains<4&cooldown.eye_beam.remains>5&(action.immolation_aura.charges>0|action.immolation_aura.recharge_time+2<cooldown.eye_beam.remains|cooldown.eye_beam.remains>buff.unbound_chaos.remains-2)
        
        if OffCooldown(ids.ImmolationAura) and ( Variables.FsTier342Piece and ( GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not HasImmolationAuraBuff and ( GetRemainingSpellCooldown(ids.EyeBeam) < 3 and ( not IsPlayerSpell(ids.EssenceBreak) or GetPlayerStacks(ids.CycleOfHatredBuff) < 4 ) or IsPlayerSpell(ids.EssenceBreak) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 5 or IsPlayerSpell(ids.EssenceBreak) and ( ( GetRemainingSpellCooldown(ids.EyeBeam) < 3 and 1 or 0 ) * GetRemainingSpellCooldown(ids.EssenceBreak) ) > GetTimeToNextCharge(ids.ImmolationAura) ) ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( Variables.FsTier342Piece and ( ( GetRemainingSpellCooldown(ids.EyeBeam) + GetRemainingSpellCooldown(ids.Metamorphosis) ) < 10 ) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.ImmolationAura) and ( FightRemains(60, NearbyRange) < 15 and GetRemainingSpellCooldown(ids.BladeDance) and IsPlayerSpell(ids.RagefireTalent) ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or not IsPlayerSpell(ids.InitiativeTalent) ) and ( GetRemainingSpellCooldown(ids.EssenceBreak) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not IsPlayerSpell(ids.EssenceBreakTalent) ) and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        -- actions.fs+=/eye_beam,if=!talent.essence_break&(!talent.chaotic_transformation|cooldown.metamorphosis.remains<5+3*talent.shattered_destiny|cooldown.metamorphosis.remains>10)&(active_enemies>desired_targets*2|raid_event.adds.in>30-talent.cycle_of_hatred.rank*2.5*buff.cycle_of_hatred.stack)&(!talent.initiative|cooldown.vengeful_retreat.remains>5|cooldown.vengeful_retreat.up&active_enemies>2|talent.shattered_destiny)&(!talent.student_of_suffering|cooldown.sigil_of_flame.remains)
        
        if OffCooldown(ids.EyeBeam) and ( ( not IsPlayerSpell(ids.InitiativeTalent) or PlayerHasBuff(ids.InitiativeBuff) or GetRemainingSpellCooldown(ids.VengefulRetreat) >= 10 or OffCooldown(ids.Metamorphosis) or IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.TacticalRetreatTalent) ) and ( GetRemainingSpellCooldown(ids.BladeDance) < 7 ) ) then
            -- KTrig("Eye Beam") return true end
            if aura_env.config[tostring(ids.EyeBeam)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Eye Beam")
            elseif aura_env.config[tostring(ids.EyeBeam)] ~= true then
                KTrig("Eye Beam")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( Variables.FsTier342Piece and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and ( HasImmolationAuraBuff or GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) <= 0.5 or GetRemainingSpellCooldown(ids.TheHunt) <= 0.5 ) and NearbyEnemies <= 2 ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( Variables.FsTier342Piece and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and ( HasImmolationAuraBuff or GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.TheHunt) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( NearbyEnemies > 2 or GetRemainingSpellCooldown(ids.Felblade) > GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) ) ) then
            KTrig("Fel Rush") return true end
        
        if OffCooldown(ids.EssenceBreak) and ( not IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) > 5 ) then
            -- KTrig("Essence Break") return true end
            if aura_env.config[tostring(ids.EssenceBreak)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Essence Break")
            elseif aura_env.config[tostring(ids.EssenceBreak)] ~= true then
                KTrig("Essence Break")
                return true
            end
        end
        
        if OffCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 and ( NearbyEnemies > 3 or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( Variables.FsTier342Piece and ( HasImmolationAuraBuff or TargetHasDebuff(ids.EssenceBreak) ) ) then
            KTrig("Chaos Strike") return true end
        
        if OffCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 ) then
            KTrig("Blade Dance") return true end
        
        if OffCooldown(ids.GlaiveTempest) then
            -- KTrig("Glaive Tempest") return true end
            if aura_env.config[tostring(ids.GlaiveTempest)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glaive Tempest")
            elseif aura_env.config[tostring(ids.GlaiveTempest)] ~= true then
                KTrig("Glaive Tempest")
                return true
            end
        end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 3 and not IsPlayerSpell(ids.StudentOfSufferingTalent) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        if OffCooldown(ids.ChaosStrike) and ( TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            KTrig("Chaos Strike") return true end
        
        -- actions.fs+=/sigil_of_flame,if=talent.student_of_suffering&((cooldown.eye_beam.remains<4&cooldown.metamorphosis.remains>20)|(cooldown.eye_beam.remains<gcd.max&cooldown.metamorphosis.up)) actions.fs+=/felblade,if=buff.out_of_range.up&buff.inertia_trigger.down  actions.fs+=/throw_glaive,if=active_enemies>2&talent.furious_throws&(!talent.screaming_brutality|charges=2|full_recharge_time<cooldown.blade_dance.remains) actions.fs+=/immolation_aura,if=talent.a_fire_inside&talent.isolated_prey&talent.flamebound&active_enemies=1&cooldown.eye_beam.remains>=gcd.max
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury > 40 + Variables.FuryGen * ( 0.5 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( GetRemainingSpellCooldown(ids.VengefulRetreat) >= GetSpellBaseCooldown(ids.Felblade)/1000 + 0.5 and IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies == 1 or not IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) ) and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) >= 0.5 + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * (( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and 1 or 0) and ( not Variables.FsTier342Piece or Variables.FsTier342Piece and not HasImmolationAuraBuff and not OffCooldown(ids.ImmolationAura) ) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 or ( CurrentFury >= 70 - 30 * (( IsPlayerSpell(ids.StudentOfSufferingTalent) and ( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) ) and 1 or 0) - (PlayerHasBuff(ids.ChaosTheoryBuff) and 1 or 0) * 20 - Variables.FuryGen ) ) then
            KTrig("Chaos Strike") return true end
        
        -- actions.fs+=/chaos_strike,if=cooldown.eye_beam.remains>=gcd.max*3|(fury>=70+(talent.untethered_fury*50-20*talent.blind_fury.rank)*hero_tree.felscarred-38*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=gcd.max|cooldown.sigil_of_flame.up))-buff.chaos_theory.up*20-variable.fury_gen) actions.fs+=/chaos_strike,if=cooldown.eye_beam.remains>=gcd.max*2|(cooldown.eye_beam.remains>=gcd+gcd.max*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=5|cooldown.sigil_of_flame.up))&(fury>=70-20*talent.blind_fury.rank-38*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=gcd.max|cooldown.sigil_of_flame.up))-(talent.essence_break&talent.inertia&cooldown.felblade.up*40)-variable.fury_gen*2))
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 1 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) and (( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) and 1 or 0) ) or NearbyEnemies > 2 ) then
            -- KTrig("Immolation Aura") return true end
            if aura_env.config[tostring(ids.ImmolationAura)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Immolation Aura")
            elseif aura_env.config[tostring(ids.ImmolationAura)] ~= true then
                KTrig("Immolation Aura")
                return true
            end
        end
        
        if OffCooldown(ids.Felblade) and ( aura_env.OutOfRange == true and PlayerHasBuff(ids.InertiaTriggerBuff) == false and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 1 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) and ( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) ) ) then
            KTrig("Felblade") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.OutOfRange == true and TargetHasDebuff(ids.EssenceBreakDebuff) == false and not IsPlayerSpell(ids.StudentOfSufferingTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > 25 ) ) then
            -- KTrig("Sigil Of Flame") return true end
            if aura_env.config[tostring(ids.SigilOfFlame)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Sigil Of Flame")
            elseif aura_env.config[tostring(ids.SigilOfFlame)] ~= true then
                KTrig("Sigil Of Flame")
                return true
            end
        end
        
        -- actions.fs+=/felblade,if=cooldown.blade_dance.remains>=0.5&cooldown.blade_dance.remains<gcd.max actions.fs+=/demons_bite
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            KTrig("Demons Bite") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            -- KTrig("Throw Glaive") return true end
            if aura_env.config[tostring(ids.ThrowGlaive)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Throw Glaive")
            elseif aura_env.config[tostring(ids.ThrowGlaive)] ~= true then
                KTrig("Throw Glaive")
                return true
            end
        end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and NearbyEnemies > 1 ) then
            KTrig("Fel Rush") return true end
    end
    

    -- Separate actionlists for each hero tree
    if IsPlayerSpell(ids.ArtOfTheGlaiveTalent) then
        if Ar() then return true end end
    
    if IsPlayerSpell(ids.DemonsurgeTalent) then
        if Fs() then return true end end
    
    KTrig("Clear")

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
    aura_env.LastDeathSweep = GetTime()
    
    -- Consumed Demonsurge explosion.
    if spellID == aura_env.ids.Annihilation then
        aura_env.DemonsurgeAnnihilationBuff = false
    elseif spellID == aura_env.ids.ConsumingFire then
        aura_env.DemonsurgeConsumingFireBuff = false
    elseif spellID == aura_env.ids.DeathSweep then
        aura_env.DemonsurgeDeathSweepBuff = false
    elseif spellID == aura_env.ids.AbyssalGaze then
        aura_env.DemonsurgeAbyssalGazeBuff = false
    elseif spellID == aura_env.ids.SigilOfDoom then
        aura_env.DemonsurgeSigilOfDoomBuff = false
    end
    
    if spellID == aura_env.ids.Metamorphosis then
        aura_env.DemonsurgeAbyssalGaze = true
        aura_env.DemonsurgeAnnihilationBuff = true
        aura_env.DemonsurgeConsumingFireBuff = true
        aura_env.DemonsurgeDeathSweepBuff = true
        aura_env.DemonsurgeSigilOfDoomBuff = true
        return
    end
    
    if spellID == aura_env.ids.ReaversGlaive then
        aura_env.ReaversGlaiveLastUsed = GetTime()
    end
    
    return
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core3--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_AURA_APPLIED

function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if destGUID == aura_env.ids.MetamorphosisBuff and IsPlayerSpell(ids.Demonsurge) then
        -- aura_env.DemonsurgeAbyssalGaze = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeAnnihilationBuff = true
        -- aura_env.DemonsurgeConsumingFireBuff = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeDeathSweepBuff = true
    end
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
    AbyssalGaze = 452497,
    Annihilation = 201427,
    BladeDance = 188499,
    ConsumingFire = 452487,
    ChaosStrike = 162794,
    DeathSweep = 210152,
    DemonsBite = 162243,
    EssenceBreak = 258860,
    EyeBeam = 198013,
    FelBarrage = 258925,
    FelRush = 195072,
    Felblade = 232893,
    GlaiveTempest = 342817,
    ImmolationAura = 258920,
    Metamorphosis = 191427,
    ReaversGlaive = 442294,
    SigilOfDoom = 452490,
    SigilOfFlame = 204596,
    SigilOfSpite = 390163,
    TheHunt = 370965,
    ThrowGlaive = 185123,
    VengefulRetreat = 198793,
    
    -- Talents
    AFireInsideTalent = 427775,
    ArtOfTheGlaiveTalent = 442290,
    BlindFuryTalent = 203550,
    BurningWoundTalent = 391189,
    ChaosTheoryTalent = 389687,
    ChaoticTransformationTalent = 388112,
    CycleOfHatredTalent = 258887,
    DemonBladesTalent = 203555,
    DemonicTalent = 213410,
    DemonsurgeTalent = 452402,
    EssenceBreakTalent = 258860,
    ExergyTalent = 206476,
    FelBarrageTalent = 258925,
    FlameboundTalent = 452413,
    FlamesOfFuryTalent = 389694,
    FuriousThrowsTalent = 393029,
    InertiaTalent = 427640,
    InitiativeTalent = 388108,
    IsolatedPreyTalent = 388113,
    LooksCanKillTalent = 320415,
    QuickenedSigilsTalent = 209281,
    RagefireTalent = 388107,
    RestlessHunterTalent = 390142,
    ScreamingBrutalityTalent = 1220506,
    ShatteredDestinyTalent = 388116,
    SoulscarTalent = 388106,
    StudentOfSufferingTalent = 452412,
    TacticalRetreatTalent = 389688,
    UnboundChaosTalent = 347461,
    
    -- Auras
    ChaosTheoryBuff = 390195,
    CycleOfHatredBuff = 1214887,
    DemonSoulTww3Buff = 1238676,
    DemonsurgeBuff = 452416,
    EssenceBreakDebuff = 320338,
    ExergyBuff = 208628,
    FelBarrageBuff = 258925,
    GlaiveFlurryBuff = 442435,
    ImmolationAuraBuff = 258920,

    ImmolationAuraBuff1 = 427910, -- Kichi add...
    ImmolationAuraBuff2 = 427911,
    ImmolationAuraBuff3 = 427912,
    ImmolationAuraBuff4 = 427913,
    ImmolationAuraBuff5 = 427914,
    ImmolationAuraBuff6 = 427915,
    ImmolationAuraBuff7 = 427916,
    ImmolationAuraBuff8 = 427917,

    InertiaBuff = 1215159,
    InertiaTriggerBuff = 427641,
    InitiativeBuff = 391215,
    InnerDemonBuff = 390145,
    MetamorphosisBuff = 162264,
    NecessarySacrificeBuff = 1217055,
    ReaversMarkDebuff = 442624,
    RendingStrikeBuff = 442442,
    StudentOfSufferingBuff = 453239,
    TacticalRetreatBuff = 389890,
    ThrillOfTheFightDamageBuff = 442688, -- Kichi fix because NG‘s wrong
    ThrillOfTheFightSpeedBuff = 442695, -- Kichi add
    UnboundChaosBuff = 347462,
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

function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    return
end


function()
    if aura_env.PrevCast == 198793 then
        return true
    else
        return false
    end
end