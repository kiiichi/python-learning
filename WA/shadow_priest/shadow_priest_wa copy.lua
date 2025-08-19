----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
WeakAuras.WatchGCD()

aura_env.PrevCastTime = 0
aura_env.ShadowfiendExpiration = 0
aura_env.Archon4pcStacks = 0
aura_env.LastShadowCrash = 0
_G.KLIST = { 
    ShadowPriest = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    DarkAscension = 391109,
    DevouringPlague = 335467,
    DivineStar = 122121,
    Halo = 120644,
    MindBlast = 8092,
    MindFlay = 15407,
    MindSpike = 73510, -- Check if this is exist
    MindSpikeInsanity = 407466, -- Check if this is exist
    Mindbender = 200174,
    ShadowCrash = 205385,
    ShadowWordDeath = 32379,
    ShadowWordPain = 589,
    Shadowfiend = 34433, -- NG name incorrect
    VampiricTouch = 34914,
    VoidBlast = 450983,
    VoidBolt = 205448,
    VoidEruption = 228260,
    VoidTorrent = 263165,
    VoidVolley = 1242173,
    Voidwraith = 451235,
    
    -- Talents
    DepthOfShadowsTalent = 451308,
    DeathspeakerTalent = 392507,
    DescendingDarknessTalent = 1242666,
    DevourMatterTalent = 451840,
    DistortedRealityTalent = 409044,
    EmpoweredSurgesTalent = 453799,
    EntropicRiftTalent = 447444,
    InescapableTormentTalent = 373427,
    InnerQuietusTalent = 448278,
    InsidiousIreTalent = 373212,
    MindDevourerTalent = 373202,
    MindMeltTalent = 391090,
    MindsEyeTalent = 407470,
    PerfectedFormTalent = 453917,
    PowerSurgeTalent = 453109,
    PsychicLinkTalent = 199484,
    VoidBlastTalent = 450405,
    VoidEmpowermentTalent = 450138,
    
    -- Buffs/Debuffs
    AscensionBuff = 391109,
    DevouringPlagueDebuff = 335467,
    EntropicRiftBuff = 449887, -- Actually the Void Heart buff since Entropic Rift doesn't have a buff.
    MindDevourerBuff = 373204,
    MindFlayInsanityBuff = 391401,
    PowerSurgeBuff = 453113,
    UnfurlingDarknessBuff = 341282,
    UnfurlingDarknessCdBuff = 341291,
    VampiricTouchDebuff = 34914,
    VoidformBuff = 194249,
    VoidVolleyBuff = 1242171,
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
    if (not usable) and nomana then return false end
    
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
    if IsPlayerSpell(457042) then ids.ShadowCrash = 457042 end
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1927)
    
    local CurrentInsanity = UnitPower("player", Enum.PowerType.Insanity)
    local MaxInsanity = UnitPowerMax("player", Enum.PowerType.Insanity)
    
    local NearbyEnemies = 0
    local NearbyRange = 46
    local UndottedEnemies = 0
    local DottedEnemies = 0
    local DevouredEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
            
            local FoundExcludedNPC = false
            for _, ID in ipairs(_G.KLIST.ShadowPriest) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    FoundExcludedNPC = true
                    break
                end
            end
            
            if FoundExcludedNPC == false then
                if WA_GetUnitDebuff(unit, ids.VampiricTouch, "PLAYER|HARMFUL") ~= nil then
                    DottedEnemies = DottedEnemies + 1
                elseif UnitClassification(unit) ~= "minus" then 
                    UndottedEnemies = UndottedEnemies + 1
                end
                if WA_GetUnitDebuff(unit, ids.DevouringPlague, "PLAYER|HARMFUL") ~= nil then
                    DevouredEnemies = DevouredEnemies + 1
                end
            end
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    
    local ShadowfiendDuration = max(0, aura_env.ShadowfiendExpiration - GetTime())
    
    -- WeakAuras.ScanEvents("NG_VAMPIRIC_TOUCH_SPREAD", DottedEnemies, UndottedEnemies)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
        KTrig("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    local Variables = {}
    Variables.DrForcePrio = true
    Variables.MeForcePrio = true
    Variables.MaxVts = 12
    Variables.IsVtPossible = false
    Variables.HoldingCrash = false
    
    local AoeVariables = function()
        Variables.MaxVts = min(NearbyEnemies, 12)
        
        Variables.IsVtPossible = false
        
        if TargetTimeToXPct(0, 60) >= 18 then
        Variables.IsVtPossible = true end
        
        -- TODO: Revamp to fix undesired behaviour with unstacked fights
        Variables.DotsUp = ( DottedEnemies + 8 * ( ((GetTime() - aura_env.LastShadowCrash < 2) ) and 1 or 0)) >= Variables.MaxVts or not Variables.IsVtPossible
        
        if Variables.HoldingCrash and IsPlayerSpell(ids.ShadowCrash) then
            Variables.HoldingCrash = ( Variables.MaxVts - DottedEnemies ) < 4 end
        
        Variables.ManualVtsApplied = ( DottedEnemies + 8 * (not Variables.HoldingCrash and 1 or 0) ) >= Variables.MaxVts or not Variables.IsVtPossible
    end
    
    local Aoe = function()
        if AoeVariables() then return true end
        
        -- High Priority action to put out Vampiric Touch on enemies that will live at least 18 seconds, up to 12 targets manually while prepping AoE
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and TargetTimeToXPct(0, 60) >= 18 and ( TargetHasDebuff(ids.VampiricTouchDebuff) or not Variables.DotsUp ) and ( Variables.MaxVts > 0 and not Variables.ManualVtsApplied and not (GetTime() - aura_env.LastShadowCrash < 2) ) and not PlayerHasBuff(ids.EntropicRiftBuff) ) then
            KTrig("Vampiric Touch") return true end
        
        -- Use Shadow Crash to apply Vampiric Touch to as many adds as possible while being efficient with Vampiric Touch refresh windows
        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsAuraRefreshable(ids.VampiricTouchDebuff) or GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) <= TargetTimeToXPct(0, 60) and not PlayerHasBuff(ids.VoidformBuff) ) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
    end
    
    local Cds = function()
        -- Make sure Mindbender is active before popping Dark Ascension unless you have insignificant talent points or too many targets
        if OffCooldownNotCasting(ids.Halo) and ( IsPlayerSpell(ids.PowerSurgeTalent) and ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 and IsPlayerSpell(ids.Mindbender) or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) or not IsPlayerSpell(ids.DarkAscension) ) and ( C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or not OffCooldown(ids.VoidTorrent) or not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 4  or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent)) ) then
            -- KTrig("Halo") return true end
            if aura_env.config[tostring(ids.Halo)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Halo")
            elseif aura_env.config[tostring(ids.Halo)] ~= true then
                KTrig("Halo")
                return true
            end
        end
        
        -- Make sure Mindbender is active before popping Void Eruption and dump charges of Mind Blast before casting
        if OffCooldownNotCasting(ids.VoidEruption) and ( ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) ) and C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent) or PlayerHasBuff(ids.PowerSurgeBuff) ) then
            -- KTrig("Void Eruption") return true end
            if aura_env.config[tostring(ids.VoidEruption)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Eruption")
            elseif aura_env.config[tostring(ids.VoidEruption)] ~= true then
                KTrig("Void Eruption")
                return true
            end
        end
            
        -- Use Dark Ascension when you have enough Insanity to cast Devouring Plague.
        if OffCooldownNotCasting(ids.DarkAscension) and ( (ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent)) and (DevouredEnemies >= 1 or CurrentInsanity >= (20 - (5 * (not IsPlayerSpell(ids.MindsEyeTalent) and 1 or 0)) + (5 * (IsPlayerSpell(ids.DistortedRealityTalent) and 1 or 0 )) - (((ShadowfiendDuration > 0) and 1 or 0) * 2)) ) ) then
            -- KTrig("Dark Ascension") return true end
            if aura_env.config[tostring(ids.DarkAscension)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Ascension")
            elseif aura_env.config[tostring(ids.DarkAscension)] ~= true then
                KTrig("Dark Ascension")
                return true
            end
        end
    end
    
    local Main = function()
        if NearbyEnemies < 3 then
            Variables.DotsUp = TargetHasDebuff(ids.VampiricTouchDebuff) or IsCasting(ids.VampiricTouch) or (GetTime() - aura_env.LastShadowCrash < 2) end
        
        if FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 and ( not Variables.HoldingCrash or NearbyEnemies > 2 ) then
            if Cds() then return true end end
        
        -- Kichi add for human reaction time
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.PerfectedFormTalent) and GetRemainingAuraDuration("player", ids.VoidformBuff)-0.5 <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Devouring Plague", "Glow") return true end

        -- Use Shadowfiend and Mindbender on cooldown as long as Vampiric Touch and Shadow Word: Pain are active and sync with Dark Ascension
        if OffCooldown(ids.Shadowfiend) and GetRemainingSpellCooldown(ids.Mindbender) == 0 and GetRemainingSpellCooldown(ids.Voidwraith) == 0 and ( ( TargetHasDebuff(ids.ShadowWordPain) and Variables.DotsUp or (GetTime() - aura_env.LastShadowCrash < 2) ) and ( not OffCooldown(ids.Halo) or not IsPlayerSpell(ids.PowerSurgeTalent) ) and ( FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 ) and ( not IsPlayerSpell(ids.DarkAscension) or GetRemainingSpellCooldown(ids.DarkAscension) < 1.5 or FightRemains(60, NearbyRange) < 15 ) ) then
            -- KTrig("Shadowfiend") return true end
            if aura_env.config[tostring(ids.Shadowfiend)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadowfiend")
            elseif aura_env.config[tostring(ids.Shadowfiend)] ~= true then
                KTrig("Shadowfiend")
                return true
            end
        end
        
        -- High Priority Shadow Word: Death when you are forcing the bonus from Devour Matter
        if OffCooldown(ids.ShadowWordDeath) and ( (UnitGetTotalAbsorbs("target") > 0) and IsPlayerSpell(ids.DevourMatterTalent) ) then
            KTrig("Shadow Word Death") return true end
        
        -- Blast more burst :wicked:
        if OffCooldownNotCasting(ids.VoidBlast) and ( ( GetRemainingDebuffDuration("target", ids.DevouringPlague) >= max(C_Spell.GetSpellInfo(ids.VoidBlast).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5 or (select(8, UnitChannelInfo("player")) == ids.VoidTorrent) and IsPlayerSpell(ids.VoidEmpowermentTalent) ) and ( MaxInsanity - CurrentInsanity >= 16 or GetTimeToFullCharges(ids.MindBlast) <= 1.5 or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5) ) then
            KTrig("Void Blast") return true end
        
        -- Do not let Voidform Expire if you can avoid it.
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.PerfectedFormTalent) and GetRemainingAuraDuration("player", ids.VoidformBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Devouring Plague") return true end
        
        -- Use Voidbolt on the enemy with the largest time to die. We do no care about dots because Voidbolt is only accessible inside voidform which guarantees maximum effect
        if GetRemainingSpellCooldown(ids.VoidBolt) == 0 and not IsCasting(ids.VoidBolt) and (PlayerHasBuff(ids.VoidformBuff) or IsCasting(ids.VoidEruption)) and ( MaxInsanity - CurrentInsanity > 16 and GetRemainingSpellCooldown(ids.VoidBolt) <= 0.1 ) then
            -- KTrig("Void Bolt") return true end
            if aura_env.config[tostring(ids.VoidEruption)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Bolt")
            elseif aura_env.config[tostring(ids.VoidEruption)] ~= true then
                KTrig("Void Bolt")
                return true
            end
        end

        
        -- Do not overcap on insanity
        if OffCooldown(ids.DevouringPlague) and ( DevouredEnemies <= 1 and GetRemainingDebuffDuration("target", ids.DevouringPlague) <= 1.5 and ( not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 3 ) or MaxInsanity - CurrentInsanity <= 35 or PlayerHasBuff(ids.MindDevourerBuff) or PlayerHasBuff(ids.EntropicRiftBuff) or PlayerHasBuff(ids.PowerSurgeBuff) and ( SetPieces >= 4 and IsPlayerSpell(ids.PowerSurgeTalent) and aura_env.Archon4pcStacks < 4 ) and PlayerHasBuff(ids.AscensionBuff) ) then      
            KTrig("Devouring Plague") return true end
        
        -- Use Void Torrent if it will get near full Mastery Value
        if OffCooldownNotCasting(ids.VoidTorrent) and ( not Variables.HoldingCrash and (GetRemainingDebuffDuration("target", ids.DevouringPlagueDebuff) >= 2.5 and ( GetRemainingSpellCooldown(ids.DarkAscension) >= 12 or not IsPlayerSpell(ids.DarkAscension) or not IsPlayerSpell(ids.VoidBlastTalent) ) or GetRemainingSpellCooldown(ids.VoidEruption) <= 3 and IsPlayerSpell(ids.VoidEruption) ) ) then
            --KTrig("Void Torrent") return true end
            if aura_env.config[tostring(ids.VoidTorrent)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Torrent")
            elseif aura_env.config[tostring(ids.VoidTorrent)] ~= true then
                KTrig("Void Torrent")
                return true
            end
        end
        
        -- Use Void Volley if it would expire soon
        if PlayerHasBuff(ids.VoidVolleyBuff) and ( GetRemainingAuraDuration("player", ids.VoidVolleyBuff) <= 5 or PlayerHasBuff(ids.EntropicRiftBuff) and GetRemainingSpellCooldown(ids.VoidBlast) > GetRemainingAuraDuration("player", ids.EntropicRiftBuff) or TargetTimeToXPct(0, 60) <= 5 ) then
            -- NGSend("Void Volley") return true end
            if aura_env.config[tostring(ids.VoidTorrent)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Volley")
            elseif aura_env.config[tostring(ids.VoidTorrent)] ~= true then
                KTrig("Void Volley")
                return true
            end
        end

        -- MFI is a good button
        if OffCooldown(ids.MindFlay) and ( PlayerHasBuff(ids.MindFlayInsanityBuff) ) then
            KTrig("Mind Flay") return true end
        
        -- Use Shadow Crash as long as you are not holding for adds and Vampiric Touch is within pandemic range
        if OffCooldown(ids.ShadowCrash) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and not Variables.HoldingCrash and not (GetTime() - aura_env.LastShadowCrash < 2) ) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
        
        -- Put out Vampiric Touch on enemies that will live at least 12s and Shadow Crash is not available soon
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and TargetTimeToXPct(0, 60) > 12 and ( TargetHasDebuff(ids.VampiricTouchDebuff) or not Variables.DotsUp ) and ( Variables.MaxVts > 0 or NearbyEnemies <= 1 ) and ( GetRemainingSpellCooldown(ids.ShadowCrash) >= GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) or Variables.HoldingCrash or not IsPlayerSpell(ids.ShadowCrash) ) and ( not (GetTime() - aura_env.LastShadowCrash < 2) or not IsPlayerSpell(ids.ShadowCrash) ) ) then
            KTrig("Vampiric Touch") return true end
        
        -- Use all charges of Mind Blast if Vampiric Touch and Shadow Word: Pain are active and Mind Devourer is not active or you are prepping Void Eruption
        if OffCooldown(ids.MindBlast) and (C_Spell.GetSpellCharges(ids.MindBlast).currentCharges > 1 or not IsCasting(ids.MindBlast)) and ( not PlayerHasBuff(ids.MindDevourerBuff) or not IsPlayerSpell(ids.MindDevourerTalent) or OffCooldown(ids.VoidEruption) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Mind Blast") return true end

        if PlayerHasBuff(ids.VoidVolleyBuff) then
            KTrig("Void Volley") return true end
        
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.VoidEruption) or PlayerHasBuff(ids.PowerSurgeBuff) or IsPlayerSpell(ids.DistortedRealityTalent) ) then      
            KTrig("Devouring Plague") return true end
        
        if OffCooldownNotCasting(ids.Halo) and ( NearbyEnemies > 1 ) then
            -- KTrig("Halo") return true end
            if aura_env.config[tostring(ids.Halo)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Halo")
            elseif aura_env.config[tostring(ids.Halo)] ~= true then
                KTrig("Halo")
                return true
            end
        end

        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsPlayerSpell(ids.DescendingDarknessTalent) ) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end

        if OffCooldown(ids.ShadowWordDeath) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < ( 20 + 15 * (IsPlayerSpell(ids.DeathspeakerTalent) and 1 or 0) ) ) then
            KTrig("Shadow Word Death") return true end

        if OffCooldown(ids.ShadowWordDeath) and ( IsPlayerSpell(ids.InescapableTormentTalent) and ShadowfiendDuration > 0 ) then
            KTrig("Shadow Word Death") return true end
        if OffCooldown(ids.MindFlay) then
            KTrig("Mind Flay") return true end

        if OffCooldown(ids.DivineStar) then
            -- KTrig("Divine Star") return true end
            if aura_env.config[tostring(ids.DivineStar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Divine Star")
            elseif aura_env.config[tostring(ids.DivineStar)] ~= true then
                KTrig("Divine Star")
                return true
            end
        end

    end
    
    if NearbyEnemies > 2 then
        if Aoe() then return true end end
    
    if Main() then return true end
    
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

function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    
    if spellID == aura_env.ids.Halo then
        aura_env.Archon4pcStacks = 0
    elseif spellID == aura_env.ids.DevouringPlague then
        -- Each cast of Devouring Plague increases the stacks by 1
        aura_env.Archon4pcStacks = aura_env.Archon4pcStacks + 1
    elseif spellID == aura_env.ids.ShadowCrash then
        aura_env.LastShadowCrash = GetTime()
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core3--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- K_UPDATE_SHADOWFIEND_EXPIRATION

function(Event, Expiration)
    if Expiration ~= nil then
        aura_env.ShadowfiendExpiration = Expiration
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.NearbyEnemies = 0

---@class idsTable
aura_env.ids = {
    -- Abilities
    DarkAscension = 391109,
    DevouringPlague = 335467,
    DivineStar = 122121,
    Halo = 120644,
    MindBlast = 8092,
    MindFlay = 15407,
    MindSpike = 73510, -- Check if this is exist
    MindSpikeInsanity = 407466, -- Check if this is exist
    Mindbender = 200174,
    ShadowCrash = 205385,
    ShadowWordDeath = 32379,
    ShadowWordPain = 589,
    Shadowfiend = 34433, -- NG name incorrect
    VampiricTouch = 34914,
    VoidBlast = 450983,
    VoidBolt = 205448,
    VoidEruption = 228260,
    VoidTorrent = 263165,
    VoidVolley = 1242173,
    Voidwraith = 451235,
    
    -- Talents
    DepthOfShadowsTalent = 451308,
    DeathspeakerTalent = 392507,
    DescendingDarknessTalent = 1242666,
    DevourMatterTalent = 451840,
    DistortedRealityTalent = 409044,
    EmpoweredSurgesTalent = 453799,
    EntropicRiftTalent = 447444,
    InescapableTormentTalent = 373427,
    InnerQuietusTalent = 448278,
    InsidiousIreTalent = 373212,
    MindDevourerTalent = 373202,
    MindMeltTalent = 391090,
    MindsEyeTalent = 407470,
    PerfectedFormTalent = 453917,
    PowerSurgeTalent = 453109,
    PsychicLinkTalent = 199484,
    VoidBlastTalent = 450405,
    VoidEmpowermentTalent = 450138,
    
    -- Buffs/Debuffs
    AscensionBuff = 391109,
    DevouringPlagueDebuff = 335467,
    EntropicRiftBuff = 449887, -- Actually the Void Heart buff since Entropic Rift doesn't have a buff.
    MindDevourerBuff = 373204,
    MindFlayInsanityBuff = 391401,
    PowerSurgeBuff = 453113,
    UnfurlingDarknessBuff = 341282,
    UnfurlingDarknessCdBuff = 341291,
    VampiricTouchDebuff = 34914,
    VoidformBuff = 194249,
    VoidVolleyBuff = 1242171,
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
----------Name plate load--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.ShouldShowDebuff = function(unit)
    if (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.KLIST then
            for _, ID in ipairs(_G.KLIST.ShadowPriest) do                
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
----------Name plate core--------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Shadowfiend core-----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_SUMMON, CLEU:SPELL_CAST_SUCCESS, PLAYER_TOTEM_UPDATE

function(allStates, event, timestamp, subEvent, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)  
    
    -- MB/SF initial cast check
    if UnitGUID("player") == sourceGUID and subEvent == "SPELL_SUMMON" and (spellID == 200174 or spellID == 34433 or spellID == 451235) then
        local BaseDuration = 15
        local EndTime = GetTime() + BaseDuration
        
        local SpellInfo = C_Spell.GetSpellInfo(spellID)
        
        allStates["bender"] = {
            show = true,
            changed = true,
            progressType = "timed",
            duration = BaseDuration,
            expirationTime = EndTime,
            autoHide = true,
            name = SpellInfo.name,
            icon = SpellInfo.iconID,
        }
        WeakAuras.ScanEvents("K_UPDATE_SHADOWFIEND_EXPIRATION", EndTime)
        return true
    end
    
    -- Extend duration if Inescapable Torment active
    if UnitGUID("player") == sourceGUID and subEvent == "SPELL_CAST_SUCCESS" and IsPlayerSpell(373427) and (spellID == 8092 or spellID == 32379) then
        if allStates["bender"] and allStates["bender"].show then            
            allStates["bender"].duration = allStates["bender"].duration + 0.7
            allStates["bender"].expirationTime = allStates["bender"].expirationTime + 0.7
            allStates["bender"].changed = true
            
            WeakAuras.ScanEvents("K_UPDATE_SHADOWFIEND_EXPIRATION", allStates["bender"].expirationTime)
            return true
        end
    end
end