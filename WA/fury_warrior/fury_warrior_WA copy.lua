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
    local FullGCDnum = math.max(0.75, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Trigger1----------------------------------------------------------------------------------------------------
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1879)
    
    local CurrentRage = UnitPower("player", Enum.PowerType.Rage)
    local MaxRage = UnitPowerMax("player", Enum.PowerType.Rage)
    
    local NearbyEnemies = 0
    local NearbyRange = 25
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end    
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables = {}
    Variables.StPlanning = NearbyEnemies <= 1
    
    Variables.AddsRemain = NearbyEnemies >= 2
    
    Variables.ExecutePhase = ( IsPlayerSpell(ids.MassacreTalent) and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 ) or (UnitHealth("target")/UnitHealthMax("target")*100) < 2
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Recklessness
    if OffCooldown(ids.Recklessness) and ( ( not IsPlayerSpell(ids.AngerManagementTalent) and IsPlayerSpell(ids.TitansTormentTalent) ) or IsPlayerSpell(ids.AngerManagementTalent) or not IsPlayerSpell(ids.TitansTormentTalent) ) then
        ExtraGlows.Recklessness = true
    end
    
    -- Avatar
    if OffCooldown(ids.Avatar) then
        ExtraGlows.Avatar = true
    end
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    

    -- Kichi --
    if GetPlayerStacks(ids.MeatCleaverBuff) == 1 then 
        local ListenLastCastInMeatCleaverBuff = aura_env.PrevCast
    else local ListenLastCastInMeatCleaverBuff = 0
    end

    NoMeatCleaverBuff = GetPlayerStacks(ids.MeatCleaverBuff) == 0 or GetPlayerStacks(ids.MeatCleaverBuff) == 1 and ( ListenLastCastInMeatCleaverBuff == ids.Execute or ListenLastCastInMeatCleaverBuff == ids.Onslaught or ListenLastCastInMeatCleaverBuff == ids.Rampage or ListenLastCastInMeatCleaverBuff == ids.RagingBlow or ListenLastCastInMeatCleaverBuff == ids.Bloodthirst )
    print(NoMeatCleaverBuff)


    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Slayer = function()
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.AshenJuggernautBuff) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) <= WeakAuras.gcdDuration() ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetRemainingAuraDuration("player", ids.SuddenDeathBuff) < 2 and not Variables.ExecutePhase ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 ) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( OffCooldown(ids.Bladestorm) and ( OffCooldown(ids.Avatar) or OffCooldown(ids.Recklessness) or PlayerHasBuff(ids.Avatar) or PlayerHasBuff(ids.RecklessnessBuff) ) and PlayerHasBuff(ids.EnrageBuff) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end

        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and ( IsPlayerSpell(ids.RecklessAbandonTalent) and GetRemainingSpellCooldown(ids.Avatar) >= 24 or IsPlayerSpell(ids.AngerManagementTalent) and GetRemainingSpellCooldown(ids.Recklessness) >= 15 and ( PlayerHasBuff(ids.Avatar) or GetRemainingSpellCooldown(ids.Avatar) >= 8 ) ) ) then
            -- KTrig("Bladestorm") return true end
            if aura_env.config[tostring(ids.Bladestorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bladestorm")
            elseif aura_env.config[tostring(ids.Bladestorm)] ~= true then
                KTrig("Bladestorm")
                return true
            end
        end
        
        if OffCooldown(ids.Whirlwind) and ( NearbyEnemies >= 2 and IsPlayerSpell(ids.MeatCleaverTalent) and GetPlayerStacks(ids.MeatCleaverBuff) == 0 ) then
            KTrig("Whirlwind") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) and PlayerHasBuff(ids.BrutalFinishBuff) ) then
            KTrig("Onslaught") return true end

        if OffCooldown(ids.Rampage) and ( GetRemainingAuraDuration("player", ids.EnrageBuff) < WeakAuras.gcdDuration() ) then
            KTrig("Rampage") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetPlayerStacks(ids.SuddenDeathBuff) == 2 and PlayerHasBuff(ids.EnrageBuff) ) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetTargetStacks(ids.MarkedForExecutionDebuff) > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow and ( C_Spell.GetSpellCharges(ids.RagingBlow).currentCharges == 2 or PlayerHasBuff(ids.BrutalFinishBuff) and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            KTrig("Crushing Blow") return true end
        
        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath and ( GetPlayerStacks(ids.BloodcrazeBuff) >= 1 or ( IsPlayerSpell(ids.UproarTalent) and GetRemainingDebuffDuration("target", ids.BloodbathDotDebuff) < 40 and IsPlayerSpell(ids.BloodborneTalent) ) or PlayerHasBuff(ids.EnrageBuff) and GetRemainingAuraDuration("player", ids.EnrageBuff) < WeakAuras.gcdDuration() ) then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( PlayerHasBuff(ids.BrutalFinishBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) < 5 and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage > 115 ) then
            KTrig("Rampage") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( Variables.ExecutePhase and TargetHasDebuff(ids.MarkedForExecutionDebuff) and PlayerHasBuff(ids.EnrageBuff) ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) and PlayerHasBuff(ids.BrutalFinishBuff) and PlayerHasBuff(ids.EnrageBuff) or NearbyEnemies >= 6 ) then
            KTrig("Bloodthirst") return true end

        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            KTrig("Crushing Blow") return true end

        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( PlayerHasBuff(ids.OpportunistBuff) ) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) ) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.RagingBlow) and ( GetSpellChargesFractional(ids.RagingBlow) == 2 ) then
            KTrig("Raging Blow") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            KTrig("Onslaught") return true end

        if OffCooldown(ids.RagingBlow) then
            KTrig("Raging Blow") return true end

        if OffCooldown(ids.Rampage) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.SuddenDeathBuff) ) then
            KTrig("Execute") return true end

        if OffCooldown(ids.Bloodthirst) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.ThunderousRoar) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.WreckingThrow) then
            KTrig("Wrecking Throw") return true end
        
        if OffCooldown(ids.Whirlwind) then
            KTrig("Whirlwind") return true end
        
        --if OffCooldown(ids.StormBolt) and ( PlayerHasBuff(ids.BladestormBuff) ) then
        --    KTrig("Storm Bolt") return true end
    end
    
    local Thane = function()
        if OffCooldown(ids.Ravager) then
            -- KTrig("Ravager") return true end
            if aura_env.config[tostring(ids.Ravager)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ravager")
            elseif aura_env.config[tostring(ids.Ravager)] ~= true then
                KTrig("Ravager")
                return true
            end
        end

        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.ChampionsMightTalent) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end
        
        if OffCooldown(ids.ThunderClap) and ( GetPlayerStacks(ids.MeatCleaverBuff) == 0 and IsPlayerSpell(ids.MeatCleaverTalent) and NearbyEnemies >= 2 ) then
            KTrig("Thunder Clap") return true end
        
        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.MeatCleaverTalent) ) then
            KTrig("Thunder Blast") return true end

        if OffCooldown(ids.Rampage) and ( not PlayerHasBuff(ids.EnrageBuff) or ( IsPlayerSpell(ids.Bladestorm) and GetRemainingSpellCooldown(ids.Bladestorm) <= WeakAuras.gcdDuration() and not TargetHasDebuff(ids.ChampionsMightDebuff) ) ) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( IsPlayerSpell(ids.AshenJuggernautTalent) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) <= WeakAuras.gcdDuration() ) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.UnhingedTalent) ) then
            -- KTrig("Bladestorm") return true end
            if aura_env.config[tostring(ids.Bladestorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bladestorm")
            elseif aura_env.config[tostring(ids.Bladestorm)] ~= true then
                KTrig("Bladestorm")
                return true
            end
        end

        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            KTrig("Bloodbath") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 115 and IsPlayerSpell(ids.RecklessAbandonTalent) and PlayerHasBuff(ids.RecklessnessBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) >= 3 ) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            KTrig("Crushing Blow") return true end
        
        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            KTrig("Onslaught") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( IsPlayerSpell(ids.ViciousContemptTalent) and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 ) then
            KTrig("Bloodthirst") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 100 ) then
            KTrig("Rampage") return true end
        
        if OffCooldown(ids.Bloodthirst) then
            KTrig("Bloodthirst") return true end

        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.RagingBlow) then
            KTrig("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) then
            KTrig("Rampage") return true end

        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( not IsPlayerSpell(ids.MeatCleaverTalent) ) then
            KTrig("Thunder Blast") return true end

        if OffCooldown(ids.ThunderousRoar) then
            -- KTrig("Thunderous Roar") return true end
            if aura_env.config[tostring(ids.ThunderousRoar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Thunderous Roar")
            elseif aura_env.config[tostring(ids.ThunderousRoar)] ~= true then
                KTrig("Thunderous Roar")
                return true
            end
        end

        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            -- KTrig("Odyns Fury") return true end
            if aura_env.config[tostring(ids.OdynsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Odyns Fury")
            elseif aura_env.config[tostring(ids.OdynsFury)] ~= true then
                KTrig("Odyns Fury")
                return true
            end
        end

        if OffCooldown(ids.ChampionsSpear) and ( not IsPlayerSpell(ids.ChampionsMightTalent) ) then
            -- KTrig("Champions Spear") return true end
            if aura_env.config[tostring(ids.ChampionsSpear)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Champions Spear")
            elseif aura_env.config[tostring(ids.ChampionsSpear)] ~= true then
                KTrig("Champions Spear")
                return true
            end
        end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) then
            KTrig("Execute") return true end
        
        if OffCooldown(ids.WreckingThrow) then
            KTrig("Wrecking Throw") return true end
        
        if OffCooldown(ids.ThunderClap) then
            KTrig("Thunder Clap") return true end

        if OffCooldown(ids.Whirlwind) then
            KTrig("Whirlwind") return true end
    end
    
    if IsPlayerSpell(ids.SlayersDominanceTalent) then
        Slayer() return true end
    
    if IsPlayerSpell(ids.LightningStrikesTalent) then
        Thane() return true end
    
    KTrig("Clear")
    KTrigCD("Clear")

end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Trigger2----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS

function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    return
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

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

