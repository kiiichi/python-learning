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
    Ascendance = 114051,
    ChainLightning = 188443,
    CrashLightning = 187874,
    DoomWinds = 384352,
    ElementalBlast = 117014,
    FeralSpirit = 51533,
    FireNova = 333974,
    FlameShock = 470411,
    FrostShock = 196840,
    FrostShockIceStrike = 342240,
    IceStrike = 470194,
    LavaBurst = 51505,
    LavaLash = 60103,
    LightningBolt = 188196,
    PrimordialWave = 375982,
    PrimordialStorm = 1218090,
    Stormstrike = 17364,
    Sundering = 197214,
    SurgingTotem = 444995,
    Tempest = 452201,
    VoltaicBlaze = 470057,
    Windstrike = 115356,
    
    -- Talents
    AlphaWolfTalent = 198434,
    AscendanceTalent = 114051,
    AshenCatalystTalent = 390370,
    AwakeningStormsTalent = 455129,
    ConvergingStormsTalent = 384363,
    CrashingStormsTalent =  334308,
    DeeplyRootedElementsTalent = 378270,
    DoomWindsTalent = 384352,
    EarthsurgeTalent = 455590,
    ElementalAssaultTalent = 210853,
    ElementalSpiritsTalent = 262624,
    FeralSpiritTalent = 51533,
    FireNovaTalent = 333974,
    FlowingSpiritsTalent = 469314,
    HailstormTalent = 334195,
    LashingFlamesTalent = 334046,
    LegacyOfTheFrostWitchTalent = 384450,
    MoltenAssaultTalent = 334033,
    OverflowingMaelstromTalent = 384149,
    PrimordialWaveTalent = 375982,
    PrimordialStormTalent = 1218047,
    RagingMaelstromTalent = 384143,
    StaticAccumulation = 384411,
    StormblastTalent = 319930,
    StormflurryTalent = 344357,
    SuperchargeTalent = 455110,
    SurgingTotemTalent = 444995,
    SwirlingMaelstromTalent = 384359,
    TempestTalent = 454009,
    ThorimsInvocationTalent = 384444,
    TotemicRebound = 445025,
    UnrelentingStormsTalent = 470490,
    UnrulyWindsTalent = 390288,
    VoltaicBlazeTalent = 470053,
    WitchDoctorsAncestryTalent = 384447,
    
    -- Buffs
    ArcDischargeBuff = 455097,
    AscendanceBuff = 114051,
    AshenCatalystBuff = 390371,
    AwakeningStormsBuff = 462131,
    ClCrashLightningBuff = 333964,
    ConvergingStormsBuff = 198300,
    CracklingSurgeBuff = 224127,
    CrashLightningBuff = 187878,
    DoomWindsBuff = 466772,
    EarthenWeaponBuff = 392375,
    ElectrostaticWagerBuff = 1223410,
    FeralSpiritBuff = 333957,
    FlameShockDebuff = 188389,
    HailstormBuff = 334196,
    HotHandBuff = 215785,
    IceStrikeBuff = 384357,
    IcyEdgeBuff = 224126,
    LashingFlamesDebuff = 334168,
    LegacyOfTheFrostWitchBuff = 384451,
    LightningRodDebuff = 197209,
    LivelyTotemsBuff = 461242,
    MaelstromWeaponBuff = 344179,
    MoltenWeaponBuff = 224125,
    PrimordialWaveBuff = 375986,
    PrimordialStormBuff = 1218125,
    SplinteredElementsBuff = 382043,
    StormblastBuff = 470466,
    StormsurgeBuff = 201846,
    TempestBuff = 454015,
    TotemicReboundBuff = 458269,
    VolcanicStrengthBuff = 409833,
    WhirlingAirBuff = 453409,
    WhirlingEarthBuff = 453406,
    WhirlingFireBuff = 453405,
}

aura_env.LastTISpell = aura_env.ids.LightningBolt
aura_env.TempestMaelstromCount = 0
aura_env.SavedMaelstrom = 0
aura_env.MinAlphaWolf = 0
aura_env.LightningBoltLastUsed = 0
aura_env.ChainLightningLastUsed = 0
aura_env.TempestLastUsed = 0
aura_env.LavaLashLastUsed = 0
aura_env.StormstrikeLastUsed = 0
aura_env.WindstrikeLastUsed = 0

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
    -- Kichi --
    -- Kichi --
    if (not usable) or nomana then return false end
--    if (not usable) and (not nomana) then return false end
    
    local Duration = C_Spell.GetSpellCooldown(spellID).duration
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    if not OffCooldown then return false end
    
    local SpellIdx, SpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellID)
    local InRange = (SpellIdx and C_SpellBook.IsSpellBookItemInRange(SpellIdx, SpellBank, "target")) -- safety
    
    -- Kichi --
    -- Kichi --
    -- if InRange == 0 then
    --     aura_env.OutOfRange = true
    --     --return false
    -- end
    if InRange == false then
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

aura_env.IsAuraRefreshable = function(SpellID, Unit)
    local Filter = ""
    -- if Unit == nil then 
    if Unit ~= "player" then 
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

aura_env.HasBloodlust = function()
    return (WA_GetUnitBuff("player", 2825) or WA_GetUnitBuff("player", 264667) or WA_GetUnitBuff("player", 80353) or WA_GetUnitBuff("player", 32182) or WA_GetUnitBuff("player", 390386) or WA_GetUnitBuff("player", 386540))
end

aura_env.PlayerHasBuff = function(spellID)
    return WA_GetUnitBuff("player", spellID) ~= nil
end

aura_env.PetHasBuff = function(spellID)
    return WA_GetUnitBuff("pet", spellID) ~= nil
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
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1877)
    
    local NearbyRange = 10
    local NearbyEnemies = 0
    local MissingFlameShock = 0
    local FlameShockedEnemies = 0
    local MissingLashingFlames = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then 
            NearbyEnemies = NearbyEnemies + 1
            if not WA_GetUnitDebuff(unit, ids.FlameShockDebuff, "PLAYER|HARMFUL") then
                MissingFlameShock = MissingFlameShock + 1
            else
                FlameShockedEnemies = FlameShockedEnemies + 1
            end
            
            if not WA_GetUnitDebuff(unit, ids.LashingFlamesDebuff, "PLAYER|HARMFUL") then
                MissingLashingFlames = MissingLashingFlames + 1
            end
        end
    end
    
    local MaxMaelstromStacks = IsPlayerSpell(ids.RagingMaelstromTalent) and 10 or 5
    local WolvesOut = 0
    local EarthenWeaponBuffs = 0
    AuraUtil.ForEachAura("player", "HELPFUL", nil, function(name, icon, _, _, _, _, _, _, _, spellID)
            if spellID == 224125 or spellID == 224126 or spellID == 224127 or spellID == ids.EarthenWeaponBuff then
                if spellID == ids.EarthenWeaponBuff then
                    EarthenWeaponBuffs = EarthenWeaponBuffs + 1
                end
                WolvesOut = WolvesOut + 1
            end
    end)
    
    local SurgingTotemActive = false
    for i = 1, 4 do
        local _, _, _, _, icon = GetTotemInfo(i)
        if icon == 5927655 then SurgingTotemActive = true end
    end
    
    local MinAlphaWolfRemains = max(aura_env.MinAlphaWolf - GetTime(), 0)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    Variables.MinTalentedCdRemains = min(min( ( ( GetRemainingSpellCooldown(ids.FeralSpirit) / ( 4 * (IsPlayerSpell(ids.WitchDoctorsAncestryTalent) and 1 or 0) ) ) + 1000 * (IsPlayerSpell(ids.FeralSpiritTalent) and 0 or 1) ), ( GetRemainingSpellCooldown(ids.DoomWinds) + 1000 * (IsPlayerSpell(ids.DoomWindsTalent) and 0 or 1) )), ( GetRemainingSpellCooldown(ids.Ascendance) + 1000 * (IsPlayerSpell(ids.AscendanceTalent) and 0 or 1) ) )
    
    Variables.ExpectedLbFunnel = 1 * ( 1 + (TargetHasDebuff(ids.LightningRodDebuff) and 1 or 0) * ( 1 + (PlayerHasBuff(ids.PrimordialWaveBuff) and 1 or 0) * FlameShockedEnemies * 1.75 ) * 1.1 )
    
    Variables.ExpectedClFunnel = 0.6 * ( 1 + (TargetHasDebuff(ids.LightningRodDebuff) and 1 or 0) * ( min(NearbyEnemies, ( 3 + 2 * (IsPlayerSpell(ids.CrashingStormsTalent) and 1 or 0) ) ) ) * 1.1 )
    
    -- Multi target action priority list
    local Aoe = function()
        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and (IsPlayerSpell(ids.ElementalSpiritsTalent) or IsPlayerSpell(ids.AlphaWolfTalent)) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.FlameShock) and ( IsPlayerSpell(ids.MoltenAssaultTalent) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.Ascendance) and ( ( TargetHasDebuff(ids.FlameShockDebuff) or not IsPlayerSpell(ids.MoltenAssaultTalent) ) and aura_env.LastTISpell == ids.ChainLightning ) then
            NGSend("Ascendance") return true end
        
        if PlayerHasBuff(ids.TempestBuff) and ( GetPlayerStacks(ids.ArcDischargeBuff) < 1 and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks and not IsPlayerSpell(ids.RagingMaelstromTalent) ) or ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) ) or ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and ( aura_env.TempestMaelstromCount > 30 ) ) ) then
            NGSend("Tempest") return true end

        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and ( GetRemainingSpellCooldown(ids.DoomWinds) > 30 or GetRemainingSpellCooldown(ids.DoomWinds) < 7 ) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.DoomWinds) then
            NGSend("Doom Winds") return true end
        
        if OffCooldown(ids.PrimordialWave) and ( TargetHasDebuff(ids.FlameShockDebuff) and ( FlameShockedEnemies == NearbyEnemies or FlameShockedEnemies == 6 ) ) then
            NGSend("Primordial Wave") return true end
        
        if PlayerHasBuff(ids.PrimordialStormBuff) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) and ( PlayerHasBuff(ids.DoomWindsBuff) or GetRemainingSpellCooldown(ids.DoomWinds) > 15 or GetRemainingAuraDuration("player", ids.PrimordialStormBuff) < 3 ) ) then
            NGSend("Primordial Storm") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.ConvergingStormsTalent) and GetPlayerStacks(ids.ElectrostaticWagerBuff) > 6 or not PlayerHasBuff(ids.CrashLightningBuff) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) and ( IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 and aura_env.LastTISpell == ids.ChainLightning ) then  
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.ConvergingStormsTalent) and IsPlayerSpell(ids.AlphaWolfTalent) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and ( GetPlayerStacks(ids.ConvergingStormsBuff) == 6 and GetPlayerStacks(ids.StormblastBuff) > 0 and PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) and GetPlayerStacks(ids.MaelstromWeaponBuff) <= 8 ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.CrashLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) <= 8 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze and ( GetPlayerStacks(ids.MaelstromWeaponBuff) <= 8 ) then
            NGSend("Voltaic Blaze") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and not PlayerHasBuff(ids.PrimordialStormBuff) and ( GetRemainingSpellCooldown(ids.CrashLightning) >= 1 or not IsPlayerSpell(ids.AlphaWolfTalent) ) ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies == 6 or ( FlameShockedEnemies >= 4 and FlameShockedEnemies == NearbyEnemies ) ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.Stormstrike) and ( IsPlayerSpell(ids.StormblastTalent) and IsPlayerSpell(ids.StormflurryTalent) ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze then
            NGSend("Voltaic Blaze") return true end
        
        if OffCooldown(ids.LavaLash) and ( IsPlayerSpell(ids.LashingFlamesTalent) or IsPlayerSpell(ids.MoltenAssaultTalent) and TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike and ( IsPlayerSpell(ids.HailstormTalent) and not PlayerHasBuff(ids.IceStrikeBuff) ) then 
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.FrostShock) and ( IsPlayerSpell(ids.HailstormTalent) and PlayerHasBuff(ids.HailstormBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.Sundering) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.FlameShock) and ( IsPlayerSpell(ids.MoltenAssaultTalent) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        -- NG Added
        if OffCooldown(ids.FlameShock) and ( ( IsPlayerSpell(ids.FireNovaTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        -- Required target switching, so commented it out.
        --if OffCooldown(ids.FlameShock) and ( ( IsPlayerSpell(ids.FireNovaTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) and ( FlameShockedEnemies < NearbyEnemies ) and FlameShockedEnemies < 6 ) then
        --    NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies >= 3 ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.Stormstrike) and ( PlayerHasBuff(ids.CrashLightningBuff) and ( IsPlayerSpell(ids.DeeplyRootedElementsTalent) or GetPlayerStacks(ids.ConvergingStormsBuff) == 6 ) ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.CrashingStormsTalent) and PlayerHasBuff(ids.ClCrashLightningBuff) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.Stormstrike) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.LavaLash) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies >= 2 ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and not PlayerHasBuff(ids.PrimordialStormBuff) ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.FrostShock) and ( not IsPlayerSpell(ids.HailstormTalent) ) then
            NGSend("Frost Shock") return true end
    end
    
    -- Multi target action priority list for the Totemic hero talent tree
    local AoeTotemic = function()
        if OffCooldown(ids.SurgingTotem) then
            NGSend("Surging Totem") return true end
        
        if OffCooldown(ids.Ascendance) and ( aura_env.LastTISpell == ids.ChainLightning ) then
            NGSend("Ascendance") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) and ( IsPlayerSpell(ids.AshenCatalystTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.CrashingStormsTalent) and ( NearbyEnemies >= 15 - 5 * (IsPlayerSpell(ids.UnrulyWindsTalent) and 1 or 0) ) ) then
            NGSend("Crash Lightning") return true end

        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and ((GetRemainingSpellCooldown(ids.DoomWinds) > 30 or GetRemainingSpellCooldown(ids.DoomWinds) < 7) and (GetRemainingSpellCooldown(ids.PrimordialWave) < 2 or PlayerHasBuff(ids.PrimordialStormBuff) or not IsPlayerSpell(ids.PrimordialStormTalent))) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.DoomWinds) and ( not IsPlayerSpell(ids.ElementalSpiritsTalent) ) then
            NGSend("Doom Winds") return true end
        
        if PlayerHasBuff(ids.PrimordialStormBuff) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) and ( GetRemainingSpellCooldown(ids.DoomWinds) > 3 ) ) then
            NGSend("Primordial Storm") return true end
        
        if OffCooldown(ids.PrimordialWave) and ( TargetHasDebuff(ids.FlameShockDebuff) and ( FlameShockedEnemies == NearbyEnemies or FlameShockedEnemies == 6 ) ) then
            NGSend("Primordial Wave") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) then
            NGSend("Windstrike") return true end

        if OffCooldown(ids.ElementalBlast) and ( ( not IsPlayerSpell(ids.ElementalSpiritsTalent) or ( IsPlayerSpell(ids.ElementalSpiritsTalent) and ( C_Spell.GetSpellCharges(ids.ElementalBlast).currentCharges == C_Spell.GetSpellCharges(ids.ElementalBlast).maxCharges or WolvesOut >= 2 ) ) ) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks and ( not IsPlayerSpell(ids.CrashingStormsTalent) or NearbyEnemies <= 3 ) ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.LavaLash) and ( PlayerHasBuff(ids.HotHandBuff) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) and ( GetPlayerStacks(ids.ElectrostaticWagerBuff) > 8 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Sundering) and ( PlayerHasBuff(ids.DoomWindsBuff) or IsPlayerSpell(ids.EarthsurgeTalent) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) or not IsPlayerSpell(ids.LegacyOfTheFrostWitchTalent) ) and SurgingTotemActive ) then
            NGSend("Sundering") return true end

        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 and GetPlayerStacks(ids.ElectrostaticWagerBuff) > 4 and not PlayerHasBuff(ids.ClCrashLightningBuff) and PlayerHasBuff(ids.DoomWindsBuff) ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 and not PlayerHasBuff(ids.PrimordialStormBuff) ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.CrashLightning) and ( PlayerHasBuff(ids.DoomWindsBuff) or not PlayerHasBuff(ids.CrashLightningBuff) or ( IsPlayerSpell(ids.AlphaWolfTalent) and WolvesOut and MinAlphaWolfRemains == 0 ) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze then
            NGSend("Voltaic Blaze") return true end

        if OffCooldown(ids.FireNova) and ( ( TargetHasDebuff(ids.FlameShockDebuff) and ( FlameShockedEnemies == NearbyEnemies or FlameShockedEnemies == 6 ) ) and PlayerHasBuff(ids.LivelyTotemsBuff) ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.LavaLash) and ( IsPlayerSpell(ids.MoltenAssaultTalent) and TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.FrostShock) and ( IsPlayerSpell(ids.HailstormTalent) and PlayerHasBuff(ids.HailstormBuff) and PlayerHasBuff(ids.LivelyTotemsBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.CrashingStormsTalent) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FireNova) and ( TargetHasDebuff(ids.FlameShockDebuff) and ( FlameShockedEnemies == NearbyEnemies or FlameShockedEnemies == 6 ) ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.FrostShock) and ( IsPlayerSpell(ids.HailstormTalent) and PlayerHasBuff(ids.HailstormBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end

        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike and ( IsPlayerSpell(ids.HailstormTalent) and not PlayerHasBuff(ids.IceStrikeBuff) ) then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and not PlayerHasBuff(ids.PrimordialStormBuff) ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and not PlayerHasBuff(ids.PrimordialStormBuff) ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.Sundering) and ( PlayerHasBuff(ids.DoomWindsBuff) or IsPlayerSpell(ids.EarthsurgeTalent) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) or not IsPlayerSpell(ids.LegacyOfTheFrostWitchTalent) ) and SurgingTotemActive ) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies == 6 or ( FlameShockedEnemies >= 4 and FlameShockedEnemies == NearbyEnemies ) ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze then
            NGSend("Voltaic Blaze") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike and ( IsPlayerSpell(ids.HailstormTalent) and not PlayerHasBuff(ids.IceStrikeBuff) ) then 
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.FrostShock) and ( IsPlayerSpell(ids.HailstormTalent) and PlayerHasBuff(ids.HailstormBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.Sundering) and ( ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) or not IsPlayerSpell(ids.LegacyOfTheFrostWitchTalent) ) and SurgingTotemActive ) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.FlameShock) and ( IsPlayerSpell(ids.MoltenAssaultTalent) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies >= 3 ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.LavaLash) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
    end
    
    -- Funnel action priority list
    local Funnel = function()
        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and ( IsPlayerSpell(ids.ElementalSpiritsTalent) ) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.SurgingTotem) then
            NGSend("Surging Totem") return true end
        
        if OffCooldown(ids.Ascendance) then
            NGSend("Ascendance") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) and ( ( IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 ) or GetPlayerStacks(ids.ConvergingStormsBuff) == 6 ) then
            NGSend("Windstrike") return true end
        
        if PlayerHasBuff(ids.TempestBuff) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks or ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and ( aura_env.TempestMaelstromCount > 30 or GetPlayerStacks(ids.AwakeningStormsBuff) == 2 ) ) ) then
            NGSend("Tempest") return true end
        
        if OffCooldown(ids.LightningBolt) and ( ( FlameShockedEnemies == NearbyEnemies or FlameShockedEnemies == 6 ) and PlayerHasBuff(ids.PrimordialWaveBuff) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks and ( not PlayerHasBuff(ids.SplinteredElementsBuff) or FightRemains(60, NearbyRange) <= 12  ) ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and IsPlayerSpell(ids.ElementalSpiritsTalent) and WolvesOut >= 4 ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.LightningBolt) and ( IsPlayerSpell(ids.SuperchargeTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks and ( Variables.ExpectedLbFunnel > Variables.ExpectedClFunnel ) ) then        
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.ChainLightning) and ( ( IsPlayerSpell(ids.SuperchargeTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks ) or PlayerHasBuff(ids.ArcDischargeBuff) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.LavaLash) and ( ( IsPlayerSpell(ids.MoltenAssaultTalent) and TargetHasDebuff(ids.FlameShockDebuff) and ( FlameShockedEnemies < NearbyEnemies ) and FlameShockedEnemies < 6 ) or ( IsPlayerSpell(ids.AshenCatalystTalent) and GetPlayerStacks(ids.AshenCatalystBuff) == 8 ) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.PrimordialWave) and ( not PlayerHasBuff(ids.PrimordialWaveBuff) ) then
            NGSend("Primordial Wave") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( not IsPlayerSpell(ids.ElementalSpiritsTalent) or ( IsPlayerSpell(ids.ElementalSpiritsTalent) and ( C_Spell.GetSpellCharges(ids.ElementalBlast).currentCharges == C_Spell.GetSpellCharges(ids.ElementalBlast).maxCharges or PlayerHasBuff(ids.FeralSpiritBuff) ) ) ) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.DoomWinds) then
            NGSend("Doom Winds") return true end
        
        if OffCooldown(ids.Stormstrike) and ( GetPlayerStacks(ids.ConvergingStormsBuff) == 6 ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.LavaBurst) and not IsPlayerSpell(ids.ElementalBlast) and ( ( GetPlayerStacks(ids.MoltenWeaponBuff) > GetPlayerStacks(ids.CracklingSurgeBuff) ) and GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks ) then
            NGSend("Lava Burst") return true end
        
        if OffCooldown(ids.LightningBolt) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks and ( Variables.ExpectedLbFunnel > Variables.ExpectedClFunnel ) ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) == MaxMaelstromStacks ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.CrashLightning) and ( PlayerHasBuff(ids.DoomWindsBuff) or not PlayerHasBuff(ids.CrashLightningBuff) or ( IsPlayerSpell(ids.AlphaWolfTalent) and WolvesOut and MinAlphaWolfRemains == 0 ) or ( IsPlayerSpell(ids.ConvergingStormsTalent) and GetPlayerStacks(ids.ConvergingStormsBuff) < 6 ) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Sundering) and ( PlayerHasBuff(ids.DoomWindsBuff) or IsPlayerSpell(ids.EarthsurgeTalent) ) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies == 6 or ( FlameShockedEnemies >= 4 and FlameShockedEnemies == NearbyEnemies ) ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike and ( IsPlayerSpell(ids.HailstormTalent) and not PlayerHasBuff(ids.IceStrikeBuff) ) then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.FrostShock) and ( IsPlayerSpell(ids.HailstormTalent) and PlayerHasBuff(ids.HailstormBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.Sundering) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.FlameShock) and ( IsPlayerSpell(ids.MoltenAssaultTalent) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        -- NG Added
        if OffCooldown(ids.FlameShock) and ( ( IsPlayerSpell(ids.FireNovaTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) and not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        -- Required target switching, so commented it out.
        --if OffCooldown(ids.FlameShock) and ( ( IsPlayerSpell(ids.FireNovaTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) and ( FlameShockedEnemies < NearbyEnemies ) and FlameShockedEnemies < 6 ) then
        --    NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies >= 3 ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.Stormstrike) and ( PlayerHasBuff(ids.CrashLightningBuff) and IsPlayerSpell(ids.DeeplyRootedElementsTalent) ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.CrashingStormsTalent) and PlayerHasBuff(ids.ClCrashLightningBuff) and NearbyEnemies >= 4 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.Stormstrike) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.LavaLash) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies >= 2 ) then
            NGSend("Fire Nova") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( not IsPlayerSpell(ids.ElementalSpiritsTalent) or ( IsPlayerSpell(ids.ElementalSpiritsTalent) and ( C_Spell.GetSpellCharges(ids.ElementalBlast).currentCharges == C_Spell.GetSpellCharges(ids.ElementalBlast).maxCharges or PlayerHasBuff(ids.FeralSpiritBuff) ) ) ) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.LavaBurst) and not IsPlayerSpell(ids.ElementalBlast) and ( ( GetPlayerStacks(ids.MoltenWeaponBuff) > GetPlayerStacks(ids.CracklingSurgeBuff) ) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) then
            NGSend("Lava Burst") return true end
        
        if OffCooldown(ids.LightningBolt) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and ( Variables.ExpectedLbFunnel > Variables.ExpectedClFunnel ) ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.ChainLightning) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) then
            NGSend("Chain Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.FrostShock) and ( not IsPlayerSpell(ids.HailstormTalent) ) then
            NGSend("Frost Shock") return true end
    end
    
    -- Single target action priority list
    local Single = function()
        
        if PlayerHasBuff(ids.PrimordialStormBuff) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 or GetRemainingAuraDuration("player", ids.PrimordialStormBuff) <= 4 and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) ) then
            NGSend("Primordial Storm") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) and ( IsPlayerSpell(ids.AshenCatalystTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) or IsPlayerSpell(ids.LashingFlamesTalent) ) ) then  
            NGSend("Flame Shock") return true end

        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and ( ( GetRemainingSpellCooldown(ids.DoomWinds) > 30 or GetRemainingSpellCooldown(ids.DoomWinds) < 7 ) ) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) and ( IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 and aura_env.LastTISpell == ids.LightningBolt ) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.DoomWinds) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) and ( GetRemainingSpellCooldown(ids.FeralSpirit) > 30 or GetRemainingSpellCooldown(ids.FeralSpirit) < 2 ) ) then
            NGSend("Doom Winds") return true end
        
        if OffCooldown(ids.PrimordialWave) and ( TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Primordial Wave") return true end
        
        if OffCooldown(ids.Ascendance) and ( ( TargetHasDebuff(ids.FlameShockDebuff) or not IsPlayerSpell(ids.PrimordialWaveTalent) or not IsPlayerSpell(ids.AshenCatalystTalent) ) ) then
            NGSend("Ascendance") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) and ( IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 and aura_env.LastTISpell == ids.LightningBolt ) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( ( not IsPlayerSpell(ids.OverflowingMaelstromTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) or ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) ) and GetSpellChargesFractional(ids.ElementalBlast) >= 1.8 ) then
            NGSend("Elemental Blast") return true end

        if PlayerHasBuff(ids.TempestBuff) and ( ( GetPlayerStacks(ids.TempestBuff) == 3 and ( aura_env.TempestMaelstromCount > 30 or GetPlayerStacks(ids.AwakeningStormsBuff) == 3 ) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) ) then
            NGSend("Tempest") return true end
        
        if OffCooldown(ids.LightningBolt) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 and not PlayerHasBuff(ids.PrimordialStormBuff) and GetPlayerStacks(ids.ArcDischargeBuff) > 1 ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( ( not IsPlayerSpell(ids.OverflowingMaelstromTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 ) or ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) ) ) then
            NGSend("Elemental Blast") return true end
        
        if PlayerHasBuff(ids.TempestBuff) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) then
            NGSend("Tempest") return true end
        
        if OffCooldown(ids.LightningBolt) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 9 ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.LavaLash) and ( ( PlayerHasBuff(ids.HotHandBuff) and ( GetPlayerStacks(ids.AshenCatalystBuff) == 8 ) ) or ( GetRemainingDebuffDuration("target", ids.FlameShockDebuff) <= 2 and not IsPlayerSpell(ids.VoltaicBlazeTalent) ) or (IsPlayerSpell(ids.LashingFlamesTalent) and not TargetHasDebuff(ids.LashingFlamesDebuff)) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) and ( ( PlayerHasBuff(ids.DoomWindsBuff) and GetPlayerStacks(ids.ElectrostaticWagerBuff) > 1 ) or GetPlayerStacks(ids.ElectrostaticWagerBuff) > 8 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and ( PlayerHasBuff(ids.DoomWindsBuff) or GetPlayerStacks(ids.StormblastBuff) > 0 ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.UnrelentingStormsTalent) and IsPlayerSpell(ids.AlphaWolfTalent) and MinAlphaWolfRemains == 0 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.LavaLash) and ( PlayerHasBuff(ids.HotHandBuff) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) and ( (SetPieces >= 4) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze then
            NGSend("Voltaic Blaze") return true end
        
        if OffCooldown(ids.Stormstrike) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.LavaLash) and ( IsPlayerSpell(ids.ElementalAssaultTalent) and IsPlayerSpell(ids.MoltenAssaultTalent) and TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Lava Lash") return true end

        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.LightningBolt) and ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 5 and not PlayerHasBuff(ids.PrimordialStormBuff) ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.FrostShock) and ( PlayerHasBuff(ids.HailstormBuff) ) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.Sundering) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FrostShock) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies ) then
            NGSend("Fire Nova") return true end
        
        --if OffCooldown(ids.EarthElemental) then
        --    NGSend("Earth Elemental") return true end
        
        if OffCooldown(ids.FlameShock) then
            NGSend("Flame Shock") return true end
    end
    
    -- Single target action priority list for the Totemic hero talent tree
    local SingleTotemic = function()
        if OffCooldown(ids.SurgingTotem) then
            NGSend("Surging Totem") return true end
        
        if OffCooldown(ids.Ascendance) and ( aura_env.LastTISpell == ids.LightningBolt and SurgingTotemActive > 4 and ( GetPlayerStacks(ids.TotemicReboundBuff) >= 3 or GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 ) ) then
            NGSend("Ascendance") return true end
        
        if OffCooldown(ids.FlameShock) and ( not TargetHasDebuff(ids.FlameShockDebuff) and ( IsPlayerSpell(ids.AshenCatalystTalent) or IsPlayerSpell(ids.PrimordialWaveTalent) ) ) then
            NGSend("Flame Shock") return true end
        
        if OffCooldown(ids.LavaLash) and ( PlayerHasBuff(ids.HotHandBuff) ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.FeralSpirit) and not IsPlayerSpell(ids.FlowingSpiritsTalent) and ( ( ( GetRemainingSpellCooldown(ids.DoomWinds) > 23 or GetRemainingSpellCooldown(ids.DoomWinds) < 7 ) and ( GetRemainingSpellCooldown(ids.PrimordialWave) < 20 or PlayerHasBuff(ids.PrimordialStormBuff) or not IsPlayerSpell(ids.PrimordialStormTalent) ) ) ) then
            NGSend("Feral Spirit") return true end
        
        if OffCooldown(ids.PrimordialWave) and ( TargetHasDebuff(ids.FlameShockDebuff) ) then
            NGSend("Primordial Wave") return true end
        
        if OffCooldown(ids.DoomWinds) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) ) then
            NGSend("Doom Winds") return true end
        
        if PlayerHasBuff(ids.PrimordialStormBuff) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) or not IsPlayerSpell(ids.LegacyOfTheFrostWitchTalent) ) and ( GetRemainingSpellCooldown(ids.DoomWinds) >= 15 or PlayerHasBuff(ids.DoomWindsBuff) ) ) then
            NGSend("Primordial Storm") return true end
        
        if OffCooldown(ids.Sundering) and ( PlayerHasBuff(ids.AscendanceBuff) and SurgingTotemActive and IsPlayerSpell(ids.EarthsurgeTalent) and PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) and GetPlayerStacks(ids.TotemicReboundBuff) >= 5 and GetPlayerStacks(ids.EarthenWeaponBuff) >= 2 ) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) and ( IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) > 0 and aura_env.LastTISpell == ids.LightningBolt ) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.Sundering) and ( PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) and ( ( GetRemainingSpellCooldown(ids.Ascendance) >= 10 and IsPlayerSpell(ids.AscendanceTalent) ) or not IsPlayerSpell(ids.AscendanceTalent) ) and SurgingTotemActive and GetPlayerStacks(ids.TotemicReboundBuff) >= 3 and not PlayerHasBuff(ids.AscendanceBuff) ) then
            NGSend("Sundering") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.UnrelentingStormsTalent) and IsPlayerSpell(ids.AlphaWolfTalent) and MinAlphaWolfRemains == 0 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.LavaBurst) and not IsPlayerSpell(ids.ElementalBlast) and ( not IsPlayerSpell(ids.ThorimsInvocationTalent) and GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 and PlayerHasBuff(ids.WhirlingAirBuff) == false ) then
            NGSend("Lava Burst") return true end
        
        if OffCooldown(ids.ElementalBlast) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) and ( PlayerHasBuff(ids.PrimordialStormBuff) == false or GetRemainingAuraDuration("player", ids.PrimordialStormBuff) > 4 ) ) then
            NGSend("Elemental Blast") return true end
        
        if OffCooldown(ids.Stormstrike) and ( PlayerHasBuff(ids.DoomWindsBuff) and PlayerHasBuff(ids.LegacyOfTheFrostWitchBuff) ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.LightningBolt) and ( ( GetPlayerStacks(ids.MaelstromWeaponBuff) >= 10 ) and ( PlayerHasBuff(ids.PrimordialStormBuff) == false or GetRemainingAuraDuration("player", ids.PrimordialStormBuff) > 4 ) ) then
            NGSend("Lightning Bolt") return true end
        
        if OffCooldown(ids.CrashLightning) and ( GetPlayerStacks(ids.ElectrostaticWagerBuff) > 4 ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.Stormstrike) and ( PlayerHasBuff(ids.DoomWindsBuff) or GetPlayerStacks(ids.StormblastBuff) > 1 ) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.LavaLash) and ( PlayerHasBuff(ids.WhirlingFireBuff) or GetPlayerStacks(ids.AshenCatalystBuff) >= 8 ) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.Stormstrike) and PlayerHasBuff(ids.Ascendance) then
            NGSend("Windstrike") return true end
        
        if OffCooldown(ids.Stormstrike) then
            NGSend("Stormstrike") return true end
        
        if OffCooldown(ids.LavaLash) then
            NGSend("Lava Lash") return true end
        
        if OffCooldown(ids.CrashLightning) and ( (SetPieces >= 4) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FlameShock) and FindSpellOverrideByID(ids.FlameShock) == ids.VoltaicBlaze then
            NGSend("Voltaic Blaze") return true end
        
        if OffCooldown(ids.CrashLightning) and ( IsPlayerSpell(ids.UnrelentingStormsTalent) ) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.IceStrike) or OffCooldown(ids.FrostShock) and FindSpellOverrideByID(ids.FrostShock) == ids.FrostShockIceStrike and ( not PlayerHasBuff(ids.IceStrikeBuff) ) then
            NGSend("Ice Strike") return true end
        
        if OffCooldown(ids.CrashLightning) then
            NGSend("Crash Lightning") return true end
        
        if OffCooldown(ids.FrostShock) then
            NGSend("Frost Shock") return true end
        
        if OffCooldown(ids.FireNova) and ( FlameShockedEnemies ) then
            NGSend("Fire Nova") return true end
        
        --if OffCooldown(ids.EarthElemental) then
        --    NGSend("Earth Elemental") return true end
        
        if OffCooldown(ids.FlameShock) and ( not IsPlayerSpell(ids.VoltaicBlazeTalent) ) then
            NGSend("Flame Shock") return true end
    end
    
    if NearbyEnemies <= 1 and not IsPlayerSpell(ids.SurgingTotemTalent) then
        if Single() then return true end end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.SurgingTotemTalent) then
        if SingleTotemic() then return true end end
    
    if NearbyEnemies > 1 and aura_env.config["UseFunnelRotation"] == false and not IsPlayerSpell(ids.SurgingTotemTalent) then
        if Aoe() then return true end end
    
    if NearbyEnemies > 1 and aura_env.config["UseFunnelRotation"] == false and IsPlayerSpell(ids.SurgingTotemTalent) then
        if AoeTotemic() then return true end end
    
    if NearbyEnemies > 1 and aura_env.config["UseFunnelRotation"] == true then
        if Funnel() then return true end end
    
    NGSend("Clear")
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_DRAIN, CLEU:SPELL_AURA_REMOVED, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_APPLIED_DOSE, CLEU:SPELL_SUMMON


function( _,_,subEvent,_,sourceGUID,_,_,_,_,_,_,_,spellID,_, amount)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then
        aura_env.PrevCast = spellID
        
        if spellID == aura_env.ids.LightningBolt then
            aura_env.LastTISpell = aura_env.ids.LightningBolt
            aura_env.LightningBoltLastUsed = GetTime()
        elseif spellID == aura_env.ids.ChainLightning then
            aura_env.LastTISpell = aura_env.ids.ChainLightning
            aura_env.ChainLightningLastUsed = GetTime()
            -- Alpha Wolf activated
            aura_env.MinAlphaWolf = GetTime() + 8
        elseif spellID == aura_env.ids.Tempest then
            aura_env.TempestLastUsed = GetTime()
            if aura_env.AwakeningStormsTempest == true then
                aura_env.AwakeningStormsTempest = false
            else
                aura_env.TempestMaelstromCount = 0
            end
        elseif spellID == aura_env.ids.CrashLightning then
            -- Alpha Wolf activated
            aura_env.MinAlphaWolf = GetTime() + 8
        elseif spellID == aura_env.ids.Stormstrike then
            aura_env.StormstrikeLastUsed = GetTime()
        elseif spellID == aura_env.ids.Windstrike then
            aura_env.WindstrikeLastUsed = GetTime()
        elseif spellID == aura_env.ids.LavaLash then
            aura_env.LavaLashLastUsed = GetTime()
        end
    end
    
    if subEvent == "SPELL_AURA_REMOVED" then
        if spellID == aura_env.ids.MaelstromWeapon then
            aura_env.TempestMaelstromCount = aura_env.TempestMaelstromCount + aura_env.SavedMaelstrom
            aura_env.SavedMaelstrom = 0
        elseif spellID == aura_env.ids.AwakeningStorms then
            aura_env.AwakeningStormsTempest = true
        end
    end
    
    if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_APPLIED_DOSE") and spellID == aura_env.ids.MaelstromWeapon then
        aura_env.SavedMaelstrom = min(aura_env.SavedMaelstrom + amount, 10)
    end
    
    -- Alpha Wolf Reset
    if subEvent == "SPELL_SUMMON" and (spellID == 426516 or spellID == 228562 or spellID == 262627) then
        aura_env.MinAlphaWolf = 0
    end
    return
end



----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Ascendance = 114051,
    ChainLightning = 188443,
    CrashLightning = 187874,
    DoomWinds = 384352,
    ElementalBlast = 117014,
    FeralSpirit = 51533,
    FireNova = 333974,
    FlameShock = 470411,
    FrostShock = 196840,
    FrostShockIceStrike = 342240,
    IceStrike = 470194,
    LavaBurst = 51505,
    LavaLash = 60103,
    LightningBolt = 188196,
    PrimordialWave = 375982,
    PrimordialStorm = 1218090,
    Stormstrike = 17364,
    Sundering = 197214,
    SurgingTotem = 444995,
    Tempest = 452201,
    VoltaicBlaze = 470057,
    Windstrike = 115356,
    
    -- Talents
    AlphaWolfTalent = 198434,
    AscendanceTalent = 114051,
    AshenCatalystTalent = 390370,
    AwakeningStormsTalent = 455129,
    ConvergingStormsTalent = 384363,
    CrashingStormsTalent =  334308,
    DeeplyRootedElementsTalent = 378270,
    DoomWindsTalent = 384352,
    EarthsurgeTalent = 455590,
    ElementalAssaultTalent = 210853,
    ElementalSpiritsTalent = 262624,
    FeralSpiritTalent = 51533,
    FireNovaTalent = 333974,
    FlowingSpiritsTalent = 469314,
    HailstormTalent = 334195,
    LashingFlamesTalent = 334046,
    LegacyOfTheFrostWitchTalent = 384450,
    MoltenAssaultTalent = 334033,
    OverflowingMaelstromTalent = 384149,
    PrimordialWaveTalent = 375982,
    PrimordialStormTalent = 1218047,
    RagingMaelstromTalent = 384143,
    StaticAccumulation = 384411,
    StormblastTalent = 319930,
    StormflurryTalent = 344357,
    SuperchargeTalent = 455110,
    SurgingTotemTalent = 444995,
    SwirlingMaelstromTalent = 384359,
    TempestTalent = 454009,
    ThorimsInvocationTalent = 384444,
    TotemicRebound = 445025,
    UnrelentingStormsTalent = 470490,
    UnrulyWindsTalent = 390288,
    VoltaicBlazeTalent = 470053,
    WitchDoctorsAncestryTalent = 384447,
    
    -- Buffs
    ArcDischargeBuff = 455097,
    AscendanceBuff = 114051,
    AshenCatalystBuff = 390371,
    AwakeningStormsBuff = 462131,
    ClCrashLightningBuff = 333964,
    ConvergingStormsBuff = 198300,
    CracklingSurgeBuff = 224127,
    CrashLightningBuff = 187878,
    DoomWindsBuff = 466772,
    EarthenWeaponBuff = 392375,
    ElectrostaticWagerBuff = 1223410,
    FeralSpiritBuff = 333957,
    FlameShockDebuff = 188389,
    HailstormBuff = 334196,
    HotHandBuff = 215785,
    IceStrikeBuff = 384357,
    IcyEdgeBuff = 224126,
    LashingFlamesDebuff = 334168,
    LegacyOfTheFrostWitchBuff = 384451,
    LightningRodDebuff = 197209,
    LivelyTotemsBuff = 461242,
    MaelstromWeaponBuff = 344179,
    MoltenWeaponBuff = 224125,
    PrimordialWaveBuff = 375986,
    PrimordialStormBuff = 1218125,
    SplinteredElementsBuff = 382043,
    StormblastBuff = 470466,
    StormsurgeBuff = 201846,
    TempestBuff = 454015,
    TotemicReboundBuff = 458269,
    VolcanicStrengthBuff = 409833,
    WhirlingAirBuff = 453409,
    WhirlingEarthBuff = 453406,
    WhirlingFireBuff = 453405,
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