----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()
-- Kichi --
_G.KLIST = { 
    BeastMasteryHunter = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    ------ Abilities
    CobraShot = 193455,
    BarbedShot = 217200,
    Multishot = 2643,
    BestialWrath = 19574,
    BlackArrow = 466930,
    Bloodshed = 321530,
    DireBeast = 120679,
    CallOfTheWild = 359844,
    KillCommand = 34026,
    KillShot = 53351,
    ExplosiveShot = 212431,
    -- Kichi --
    KillCommandSummon = 34026,  
    
    ------ Talents
    BarbedScalesTalent = 469880,
    BeastCleaveTalent = 115939,
    BlackArrowTalent = 466932,
    BleakPowderTalent = 467911,
    BloodyFrenzyTalent = 407412,
    CullTheHerdTalent = 445717,
    DireCleaveTalent = 1217524,
    FuriousAssaultTalent = 445699,
    HuntmastersCallTalent = 459730,
    KillerCobraTalent = 199532,
    SavageryTalent = 424557,
    ScentOfBloodTalent = 193532,
    ShadowHoundsTalent = 430707,
    ThunderingHoovesTalent = 459693,
    VenomsBiteTalent = 459565,
    WildCallTalent = 185789,
    
    ------ Auras
    BeastCleavePetBuff = 118455,
    BeastCleaveBuff = 268877,
    CallOfTheWildBuff = 359844,
    DeathblowBuff = 378770,
    FrenzyBuff = 272790,
    HogstriderBuff = 472640,
    HowlBearBuff = 472325,
    HowlBoarBuff = 472324,
    HowlWyvernBuff = 471878,
    HuntmastersCallBuff = 459731,
    HuntersPreyBuff = 378215,
    SerpentStingDebuff = 271788,
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
    -- Kichi --
    -- if TimeRemaining <= WeakAuras.gcdDuration() then TimeRemaining = 0 end

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

-- Kichi --
aura_env.FullGCD = function()
    local baseGCD = 1.5
    local FullGCDnum = math.max(1, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
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
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1871)
    local CurrentFocus = UnitPower("player", Enum.PowerType.Focus)
    local MaxFocus = UnitPowerMax("player", Enum.PowerType.Focus)
    local HowlSummonReady = PlayerHasBuff(ids.HowlBearBuff) or PlayerHasBuff(ids.HowlBoarBuff) or PlayerHasBuff(ids.HowlWyvernBuff)
    
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
    -- WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)

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
    -- Kichi --
    local ExtraGlows = {}

    if OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) and not OffCooldown(ids.BestialWrath) then
        ExtraGlows.CallOfTheWild = true 
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        if OffCooldown(ids.BestialWrath) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end

        if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.HuntmastersCallTalent) and GetPlayerStacks(ids.HuntmastersCallBuff) == 2 ) then
            -- KTrig("Dire Beast") return true end
            if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dire Beast")
            elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
                KTrig("Dire Beast")
                return true
            end
        end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( GetRemainingAuraDuration("player", ids.BeastCleaveBuff) and PlayerHasBuff(ids.WitheringFireBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- Kichi --
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) <= WeakAuras.gcdDuration() or math.floor(GetSpellChargesFractional(ids.BarbedShot)) > math.floor(GetSpellChargesFractional(ids.KillCommand)) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            KTrig("Barbed Shot") return true end
        
        -- Kichi --
        if OffCooldown(ids.Multishot) and ( not(GetRemainingAuraDuration("pet", ids.BeastCleavePetBuff) > WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or true ) ) then
            KTrig("Multishot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( GetRemainingAuraDuration("player", ids.BeastCleaveBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- -- Kichi --    
        -- if OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) then
        --     -- KTrig("Call of the Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end
        
        -- Kichi --
        if OffCooldown(ids.KillCommandSummon) and HowlSummonReady then 
            -- KTrig("Kill Command") return true end
            if aura_env.config[tostring(ids.KillCommandSummon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kill Command Summon")
            elseif aura_env.config[tostring(ids.KillCommandSummon)] ~= true then
                KTrig("Kill Command Summon")
                return true
            end
        end

        -- Kichi --
        -- if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.ShadowHoundsTalent) or IsPlayerSpell(ids.DireCleaveTalent) ) then
        -- --if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.ShadowHoundsTalent) or IsPlayerSpell(ids.DireCleaveTalent) ) and ( (CurrentFocus + GetPowerRegen()*WeakAuras.gcdDuration() + 20) < MaxFocus ) and (GetSpellChargesFractional(ids.BarbedShot) + GetSpellChargesFractional(ids.KillCommand) < 2 ) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end

        -- Waiting to modify this
        if OffCooldown(ids.KillCommand) and not HowlSummonReady then 
            KTrig("Kill Command") return true end
        
        -- Kichi --
        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()*WeakAuras.gcdDuration()) < (WeakAuras.gcdDuration() + FullGCD()*2 ) or GetPlayerStacks(ids.HogstriderBuff) > 3 ) then
            KTrig("Cobra Shot") return true end
        
        -- Kichi --    
        if OffCooldown(ids.DireBeast) then
        --if OffCooldown(ids.DireBeast) and ( (CurrentFocus + GetPowerRegen()*WeakAuras.gcdDuration() + 20) < MaxFocus ) then
            -- KTrig("Dire Beast") return true end
            if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dire Beast")
            elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
                KTrig("Dire Beast")
                return true
            end
        end
        
        if OffCooldown(ids.ExplosiveShot) then
            KTrig("Explosive Shot") return true end

    end
    
    local St = function()
        if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.HuntmastersCallTalent) ) then
            -- KTrig("Dire Beast") return true end
            if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dire Beast")
            elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
                KTrig("Dire Beast")
                return true
            end
        end
        
        if OffCooldown(ids.BestialWrath) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end
                    
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( PlayerHasBuff(ids.WitheringFireBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- Waiting to modify this
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) <= WeakAuras.gcdDuration() or math.floor(GetSpellChargesFractional(ids.BarbedShot)) > math.floor(GetSpellChargesFractional(ids.KillCommand)) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            KTrig("Barbed Shot") return true end
        
        -- if OffCooldown(ids.CallOfTheWild) then
        --     -- KTrig("Call of the Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end
        
        -- Kichi --
        if OffCooldown(ids.KillCommandSummon) and HowlSummonReady then 
            -- KTrig("Kill Command") return true end
            if aura_env.config[tostring(ids.KillCommandSummon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kill Command Summon")
            elseif aura_env.config[tostring(ids.KillCommandSummon)] ~= true then
                KTrig("Kill Command Summon")
                return true
            end
        end

        if OffCooldown(ids.KillCommand) and not HowlSummonReady then 
            KTrig("Kill Command") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            KTrig("Cobra Shot") return true end
        
        if OffCooldown(ids.DireBeast) then
            -- KTrig("Dire Beast") return true end
            if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dire Beast")
            elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
                KTrig("Dire Beast")
                return true
            end
        end
    end
    
    if NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3 then
        if St() then return true end end
    
    if NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1 then
        if Cleave() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

---@class idsTable
aura_env.ids = {
    ------ Abilities
    CobraShot = 193455,
    BarbedShot = 217200,
    Multishot = 2643,
    BestialWrath = 19574,
    BlackArrow = 466930,
    Bloodshed = 321530,
    DireBeast = 120679,
    CallOfTheWild = 359844,
    KillCommand = 34026,
    KillShot = 53351,
    ExplosiveShot = 212431,
    -- Kichi --
    KillCommandSummon = 34026,  
    
    ------ Talents
    BarbedScalesTalent = 469880,
    BeastCleaveTalent = 115939,
    BlackArrowTalent = 466932,
    BleakPowderTalent = 467911,
    BloodyFrenzyTalent = 407412,
    CullTheHerdTalent = 445717,
    DireCleaveTalent = 1217524,
    FuriousAssaultTalent = 445699,
    HuntmastersCallTalent = 459730,
    KillerCobraTalent = 199532,
    SavageryTalent = 424557,
    ScentOfBloodTalent = 193532,
    ShadowHoundsTalent = 430707,
    ThunderingHoovesTalent = 459693,
    VenomsBiteTalent = 459565,
    WildCallTalent = 185789,
    
    ------ Auras
    BeastCleavePetBuff = 118455,
    BeastCleaveBuff = 268877,
    CallOfTheWildBuff = 359844,
    DeathblowBuff = 378770,
    FrenzyBuff = 272790,
    HogstriderBuff = 472640,
    HowlBearBuff = 472325,
    HowlBoarBuff = 472324,
    HowlWyvernBuff = 471878,
    HuntmastersCallBuff = 459731,
    HuntersPreyBuff = 378215,
    SerpentStingDebuff = 271788,
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

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Name plate load--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.ShouldShowDebuff = function(unit)
    if (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.KLIST then
            for _, ID in ipairs(_G.KLIST.BeastMasteryHunter) do                
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




function(event, spellID, customData)
    if spellID == "Kill Command" or spellID == "Kill Command Summon" then
        return true
    end
    return false
end

function(event, spellID, customData)
    if event == "K_TRIGED" then
        if spellID == "Kill Command" or spellID == "Kill Command Summon" then
            return true
        end
    end
    if event == "K_TRIGED_CD" then
        if spellID == "Kill Command" or spellID == "Kill Command Summon" then
            return true
        end
    end
end

