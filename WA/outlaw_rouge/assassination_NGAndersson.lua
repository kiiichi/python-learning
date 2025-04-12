----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

_G.NGWA = { 
    AssassinationRogue = { 
        aura_env.config["ExcludeList1"],
        aura_env.config["ExcludeList2"],
        aura_env.config["ExcludeList3"],
        aura_env.config["ExcludeList4"],
    }
}

aura_env.GarroteSnapshots = {}
aura_env.Envenom1 = 0
aura_env.Envenom2 = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Ambush = 8676,
    ColdBlood = 382245,
    CrimsonTempest = 121411,
    Deathmark = 360194,
    EchoingReprimand = 385616,
    Envenom = 32645,
    FanOfKnives = 51723,
    Garrote = 703,
    Kingsbane = 385627,
    Mutilate = 1329,
    Rupture = 1943,
    Shiv = 5938,
    SliceAndDice = 315496,
    ThistleTea = 381623,
    Vanish = 1856,
    
    -- Talents
    AmplifyingPoisonTalent = 381664,
    ArterialPrecisionTalent = 400783,
    BlindsideTalent = 328085,
    CausticSpatterTalent = 421975,
    DashingScoundrelTalent = 381797,
    DeathstalkersMarkTalent = 457052,
    HandOfFateTalent = 452536,
    ImprovedGarroteTalent = 381632,
    IndiscriminateCarnageTalent = 381802,
    KingsbaneTalent = 385627,
    LightweightShivTalent = 394983,
    MasterAssassinTalent = 255989,
    MomentumOfDespairTalent = 457067,
    ScentOfBloodTalent = 381799,
    ShroudedSuffocationTalent = 385478,
    SubterfugeTalent = 108208,
    ThrownPrecisionTalent = 381629,
    ViciousVenomsTalent = 381634,
    TwistTheKnifeTalent = 381669,
    
    -- Auras
    AmplifyingPoisonDebuff = 383414,
    BlindsideBuff = 121153,
    CausticSpatterDebuff = 421976,
    ClearTheWitnessesBuff = 457178,
    CrimsonTempestDebuff = 121411,
    DarkestNightBuff = 457280,
    DeadlyPoisonDebuff = 2818,
    DeathstalkersMarkDebuff = 457129,
    EnvenomBuff = 32645,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    IndiscriminateCarnageBuff = 385747,
    KingsbaneDebuff = 385627,
    LingeringDarknessBuff = 457273,
    MasterAssassinBuff = 256735,
    MomentumOfDespairBuff = 457115,
    VanishBuff = 11327,
    ScentOfBloodBuff = 394080,
    ShivDebuff = 319504,
    SubterfugeBuff = 115192,
    StealthBuff = 1784,
    ThistleTeaBuff = 381623,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

aura_env.NGSend = function(Name, ...)
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name, ...)
    WeakAuras.ScanEvents("NG_OUT_OF_RANGE", aura_env.OutOfRange)
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) and (not nomana) then return false end
    
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

aura_env.GetRemainingStealthDuration = function()
    if WA_GetUnitAura("player", aura_env.ids.Stealth) then return 999999999 end
    
    local SubterfugeExpiration = select(6, WA_GetUnitAura("player", aura_env.ids.Subterfuge))
    if SubterfugeExpiration ~= nil then return SubterfugeExpiration end
    
    local ShadowDanceExpiration = select(6, WA_GetUnitAura("player", aura_env.ids.ShadowDanceBuff))
    if ShadowDanceExpiration ~= nil then return ShadowDanceExpiration end
    
    return 0
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

---- Keybind Assistance ----------------------------------------------------------------------------------------
-- Based on https://wago.io/7bcXDdPqi
-- Initilize setup
_G.kbTable_master = {}
_G.UseKeybindAssistance = aura_env.config.UseKeybindAssistance
local SpamAura = ""
local SpamCount = 0
local Updated = false

-- Load custom options
local custMod = aura_env.config.KeybindSettings.custMod
local shiftMod = aura_env.config.KeybindSettings.shiftMod
local ctrlMod = aura_env.config.KeybindSettings.ctrlMod
local altMod = aura_env.config.KeybindSettings.altMod
local custMouse = aura_env.config.KeybindSettings.custMouse
local btnMouse = aura_env.config.KeybindSettings.btnMouse
local shiftMouse = aura_env.config.KeybindSettings.shiftMouse
local ctrlMouse = aura_env.config.KeybindSettings.ctrlMouse
local altMouse = aura_env.config.KeybindSettings.altMouse
local spamOpt = aura_env.config.KeybindSettings.spamOpt
local crtog1 = aura_env.config.KeybindSettings.crtog1
local creplace1 = aura_env.config.KeybindSettings.creplace1
local crwith1 = aura_env.config.KeybindSettings.crwith1
local crtog2 = aura_env.config.KeybindSettings.crtog2
local creplace2 = aura_env.config.KeybindSettings.creplace2
local crwith2 = aura_env.config.KeybindSettings.crwith2
local crtog3 = aura_env.config.KeybindSettings.crtog3
local creplace3 = aura_env.config.KeybindSettings.creplace3
local crwith3 = aura_env.config.KeybindSettings.crwith3

-- Function to check for WA causing spam
local function spamCheck(checkAura)
    local lastAura = SpamAura
    local prompt = ""
    if not checkAura then
        prompt = "Global update initiated"
        return false, prompt
    elseif (lastAura and checkAura == lastAura) then
        if SpamCount > 3 then
            return true
        elseif SpamCount == 3 then
            prompt = checkAura.." is spamming and will be ignored"
            SpamCount = SpamCount +1
            return true, prompt
        end
    else 
        prompt = checkAura.." triggered an update"
        SpamAura = checkAura
        SpamCount = SpamCount +1
        return false , prompt
    end
end

-- Main Function for populating keybind table
function _G.kbTable_refresh(auraName)
    -- If we haven't enabled Keybind Assistance, do nothing.
    if _G.UseKeybindAssist == false then return end
    
    -- Checks if master table is created before running
    if not _G.kbTable_master then return end
    
    -- Checks if same WA has been spamming and stops it
    local spamResult, spamPrompt = spamCheck(auraName)
    -- Console printout of check results
    if spamOpt and spamPrompt then print (spamPrompt) end
    if spamResult then return; end
    
    for slotID=1,180 do
        local actionType, actionID, _ = GetActionInfo(slotID)
        local noMouse = true        
        
        -- NIL check actionID then populate keybind table
        -- Keybinds beyond #156 haven't been test yet
        if actionID then
            local action = slotID
            local modact = 1+(action-1)%12
            local bindstring = ""
            if (action < 25 or action > 72) and (action <145) then
                bindstring = 'ACTIONBUTTON'..modact
            elseif action < 73 and action > 60 then
                bindstring = 'MULTIACTIONBAR1BUTTON'..modact
            elseif action < 61 and action > 48 then
                bindstring = 'MULTIACTIONBAR2BUTTON'..modact
            elseif action < 37 and action > 24 then
                bindstring = 'MULTIACTIONBAR3BUTTON'..modact
            elseif action < 49 and action > 36 then
                bindstring = 'MULTIACTIONBAR4BUTTON'..modact
            elseif action < 157 and action > 144 then
                bindstring = 'MULTIACTIONBAR5BUTTON'..modact
            end
            local keyBind = GetBindingKey(bindstring)
            
            if keyBind then
                
                -- Truncates mouse button keybinds
                local mouseMod, mouseBtn, btnNum = keyBind:match("(.*)(BUTTON)(.*)")
                if mouseBtn then
                    noMouse = false
                    if custMouse then
                        if mouseMod == 'SHIFT-' then
                            mouseMod = shiftMouse
                        elseif mouseMod == 'CTRL-' then
                            mouseMod = ctrlMouse
                        elseif mouseMod == 'ALT-'then
                            mouseMod = altMouse
                        end
                        keyBind = mouseMod..btnMouse..btnNum
                    end
                end
                
                
                -- Truncates other modifier keys
                if custMod and noMouse then
                    local keyMod,_,keyNum = keyBind:match("(.*)(-)(.*)")
                    if keyMod then
                        if keyMod == 'SHIFT' then
                            keyMod = shiftMod
                        elseif keyMod == 'CTRL' then
                            keyMod = ctrlMod
                        elseif keyMod == 'ALT'then
                            keyMod = altMod
                        end 
                        keyBind = keyMod..keyNum
                    end
                end
                
                -- Custom string replace for uncommon keybinds
                if crtog1 then
                    local creplace = keyBind:gsub(creplace1, crwith1)
                    keyBind = creplace
                end
                if crtog2 then
                    local creplace = keyBind:gsub(creplace2, crwith2)
                    keyBind = creplace
                end
                if crtog3 then
                    local creplace = keyBind:gsub(creplace3, crwith3)
                    keyBind = creplace
                end
                
                -- Items are stored with item name as key to bypass inventory requirement
                if actionType == 'item' then
                    actionID = GetItemInfo(actionID)
                end
                
                -- Check for nil, changed or empty keybinds before populating
                if keyBind and actionID and kbTable_master[actionID] ~= keyBind then
                    kbTable_master[actionID] = keyBind
                    Updated = true                  
                end
            end
        end
    end
    -- Clear spamcheck to allow WAs to check for updates
    if Updated then 
        SpamAura = ""
        SpamCount = 0
    end
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1687)
    
    local CurrentComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    
    local EffectiveComboPoints = CurrentComboPoints
    
    local Envenom1Remains = ((aura_env.Envenom1 < CurrentTime) and 0 or (aura_env.Envenom1 - CurrentTime))
    
    local IsStealthed = PlayerHasBuff(ids.SubterfugeBuff) or PlayerHasBuff(ids.StealthBuff)
    local HasImprovedGarroteBuff = PlayerHasBuff(392403) or PlayerHasBuff(392401)
    
    local EnergyRegen = GetPowerRegen()
    local DotTickRate = 2 / (1+0.01*UnitSpellHaste("player"))
    local LethalPoisons = 0
    local PoisonedBleeds = 0
    local BleedIds = {
        703, -- Garrote
        1943, -- Rupture
        360826, -- Deathmark Garrote
        360830, -- Deathmark Rupture
    }
    local PoisonIds = {
        8680, -- Wound Poison
        2818, -- Deadly Poison
        383414, -- Amplifying Poison
    }
    local IsLethalPoisoned = function(unit)
        for _, Id in ipairs(PoisonIds) do
            if WA_GetUnitDebuff(unit, Id, "PLAYER") then
                return true
            end
        end
        return false
    end
    
    local NearbyRange = 10 -- Fan of Knives range is 10 yards
    local NearbyEnemies = 0
    local NearbyGarroted = 0
    local NearbyRuptured = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.Garrote, "PLAYER") then
                NearbyGarroted = NearbyGarroted + 1
            end
            
            if WA_GetUnitDebuff(unit, ids.Rupture, "PLAYER") then
                NearbyRuptured = NearbyRuptured + 1
            end
            
            -- Energy Regen
            if IsLethalPoisoned(unit) then
                LethalPoisons = LethalPoisons + 1
                
                for _, Id in ipairs(BleedIds) do
                    if WA_GetUnitDebuff(unit, Id, "PLAYER") then
                        PoisonedBleeds = PoisonedBleeds + 1
                    end
                end
            end
        end
    end
    
    -- Venomous Wounds
    EnergyRegen = EnergyRegen + (PoisonedBleeds * 7) / DotTickRate
    
    -- Dashing Scoundrel -- Estimate ~90% Envenom uptime for energy regen approximation
    if IsPlayerSpell(ids.DashingScoundrelTalent) then
        EnergyRegen = EnergyRegen + ((0.9 * LethalPoisons * (GetCritChance() / 100)) / DotTickRate)
    end
    
    WeakAuras.ScanEvents("NG_GARROTE_DATA", NearbyGarroted, NearbyEnemies)
    WeakAuras.ScanEvents("NG_RUPTURE_DATA", NearbyRuptured, NearbyEnemies)
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    
    -- Determine combo point finish condition
    Variables.EffectiveSpendCp = max(MaxComboPoints - 2, 5 * (IsPlayerSpell(ids.HandOfFateTalent) and 1 or 0))
    
    -- Conditional to check if there is only one enemy
    Variables.SingleTarget = NearbyEnemies < 2
    
    -- Combined Energy Regen needed to saturate
    Variables.RegenSaturated = EnergyRegen > 30
    
    -- Pooling Setup, check for cooldowns
    Variables.InCooldowns = TargetHasDebuff(ids.Deathmark) or TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.ShivDebuff)
    
    -- Check upper bounds of energy to begin spending
    Variables.UpperLimitEnergy = (CurrentEnergy/MaxEnergy*100) >= ( 50 - 10 * (IsPlayerSpell(ids.ViciousVenomsTalent) and 2 or 0) )
    
    -- Checking for cooldowns soon
    Variables.CdSoon = GetRemainingSpellCooldown(ids.Kingsbane) < 3 and not OffCooldown(ids.Kingsbane)
    
    -- Pooling Condition all together
    Variables.NotPooling = Variables.InCooldowns or not Variables.CdSoon and PlayerHasBuff(ids.DarkestNightBuff) or Variables.UpperLimitEnergy or FightRemains(60, NearbyRange) <= 20
    
    -- Check what the maximum Scent of Blood stacks is currently
    Variables.ScentEffectiveMaxStacks = min(( NearbyEnemies * (IsPlayerSpell(ids.ScentOfBloodTalent) and 2 or 0) ), 20)
    
    -- We are Scent Saturated when our stack count is hitting the maximum
    Variables.ScentSaturation = GetPlayerStacks(ids.ScentOfBloodBuff) >= Variables.ScentEffectiveMaxStacks
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
        NGSend("Clear", nil) return end
    
    -- Use with shiv or in niche cases at the end of Kingsbane if not already up
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTeaBuff) and GetRemainingDebuffDuration("target", ids.ShivDebuff) >= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) <= 6 or not PlayerHasBuff(ids.ThistleTeaBuff) and FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) then
        ExtraGlows.ThistleTea = true 
    end
    
    -- Cold Blood with similar conditions to Envenom,
    if OffCooldown(ids.ColdBlood) and ( GetRemainingSpellCooldown(ids.Deathmark) > 10 and not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) and not PlayerHasBuff(ids.VanishBuff) and ( not OffCooldown(ids.Kingsbane) or not (NearbyEnemies < 2) ) and not OffCooldown(ids.Deathmark) ) then
    ExtraGlows.ColdBlood = true end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Damage over time abilities
    local AoeDot = function()
        -- Crimson Tempest on 2+ Targets
        if OffCooldown(ids.CrimsonTempest) and ( NearbyEnemies >= 2 and IsAuraRefreshable(ids.CrimsonTempest) and EffectiveComboPoints >= Variables.EffectiveSpendCp and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.CrimsonTempest) > 6 ) then
            NGSend("Crimson Tempest") return true end
        
        -- Garrote upkeep in AoE to reach energy saturation
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and not Variables.RegenSaturated and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 ) then
            NGSend("Garrote") return true end
        
        -- Rupture upkeep in AoE to reach energy or scent of blood saturation
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and ( not Variables.RegenSaturated and ( IsPlayerSpell(ids.ScentOfBloodTalent) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) or TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > 15 ) ) ) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > ( 7 + ( (IsPlayerSpell(ids.DashingScoundrelTalent) and 1 or 0) * 5 ) + ( (Variables.RegenSaturated and 1 or 0) * 6 ) ) and not PlayerHasBuff(ids.DarkestNightBuff) ) then
            NGSend("Rupture") return true end
        
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and (not TargetHasDebuff(ids.Kingsbane) or PlayerHasBuff(ids.ColdBlood)) and Variables.RegenSaturated and not Variables.ScentSaturation and (TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > 19) and not PlayerHasBuff(ids.DarkestNightBuff)) then
            NGSend("Rupture") return true end
        
        -- Garrote as a special generator for the last CP before a finisher for edge case handling
        if OffCooldown(ids.Garrote) and ( IsAuraRefreshable(ids.Garrote) and MaxComboPoints - EffectiveComboPoints >= 1 and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or GetRemainingDebuffDuration("target", ids.Garrote) <= 2 and NearbyEnemies >= 3 ) and ( GetRemainingDebuffDuration("target", ids.Garrote) <= 2 * 2 and NearbyEnemies >= 3 ) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) ) > 4 and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 ) then
            NGSend("Garrote") return true end
    end
    
    -- Core damage over time abilities used everywhere 
    local CoreDot = function()
        -- Maintain Garrote
        if OffCooldown(ids.Garrote) and ( MaxComboPoints - EffectiveComboPoints >= 1 and ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) and IsAuraRefreshable(ids.Garrote) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 12 ) then
            NGSend("Garrote") return true end
        
        -- Maintain Rupture unless darkest night is up
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.Rupture) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Rupture) > ( 4 + ( (IsPlayerSpell(ids.DashingScoundrelTalent) and 1 or 0) * 5 ) + ( (Variables.RegenSaturated and 1 or 0) * 6 ) ) and (not PlayerHasBuff(ids.DarkestNightBuff) or IsPlayerSpell(ids.CausticSpatterTalent) and not TargetHasDebuff(ids.CausticSpatterDebuff)) ) then
            NGSend("Rupture") return true end

        -- Maintain Crimson Tempest
        if OffCooldown(ids.CrimsonTempest) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and IsAuraRefreshable(ids.CrimsonTempestDebuff) and ( not PlayerHasBuff(ids.DarkestNightBuff) ) and not IsPlayerSpell(ids.AmplifyingPoisonTalent) ) then
            NGSend("Crimson Tempest") return true end
    end
    
    -- Direct Damage Abilities Envenom at applicable cp if not pooling, capped on amplifying poison stacks, on an animacharged CP, or in aoe.
    local Direct = function()
        if OffCooldown(ids.Envenom) and ( not PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( Variables.NotPooling or GetTargetStacks(ids.AmplifyingPoisonDebuff) >= 20 or not (NearbyEnemies < 2) ) and not PlayerHasBuff(ids.VanishBuff) ) then
            NGSend("Envenom") return true end
        
        -- Special Envenom handling for Darkest Night
        if OffCooldown(ids.Envenom) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= MaxComboPoints ) then
            NGSend("Envenom") return true end
        
        -- Check if we should be using a filler
        Variables.UseFiller = CurrentComboPoints <= Variables.EffectiveSpendCp and not Variables.CdSoon or Variables.NotPooling or not (NearbyEnemies < 2)
        
        Variables.FokTargetCount = ( PlayerHasBuff(ids.ClearTheWitnessesBuff) and ( NearbyEnemies >= 2 - (( PlayerHasBuff(ids.LingeringDarknessBuff) or not IsPlayerSpell(ids.ViciousVenomsTalent) ) and 1 or 0) ) ) or ( NearbyEnemies >= 3 - (( IsPlayerSpell(ids.MomentumOfDespairTalent) and IsPlayerSpell(ids.ThrownPrecisionTalent) ) and 1 or 0) + (IsPlayerSpell(ids.ViciousVenomsTalent) and 1 or 0) + (IsPlayerSpell(ids.BlindsideTalent) and 1 or 0) )

        -- Maintain Caustic Spatter
        Variables.UseCausticFiller = IsPlayerSpell(ids.CausticSpatterTalent) and TargetHasDebuff(ids.Rupture) and ( not TargetHasDebuff(ids.CausticSpatterDebuff) or GetRemainingDebuffDuration("target", ids.CausticSpatterDebuff) <= 3 ) and MaxComboPoints - EffectiveComboPoints > 1 and not (NearbyEnemies < 2)     
        
        if OffCooldown(ids.Mutilate) and ( Variables.UseCausticFiller ) then
            NGSend("Mutilate") return true end
        
        if OffCooldown(ids.Ambush) and ( Variables.UseCausticFiller ) then
            NGSend("Ambush") return true end

        -- Fan of Knives at 6cp for Darkest Night
        if OffCooldown(ids.FanOfKnives) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 6 and ( not IsPlayerSpell(ids.ViciousVenomsTalent) or NearbyEnemies >= 2) ) then
            NGSend("Fan of Knives") return true end
        
        -- Fan of Knives at 3+ targets, accounting for various edge cases
        if OffCooldown(ids.FanOfKnives) and (Variables.UseFiller and Variables.FokTargetCount ) then
            NGSend("Fan of Knives") return true end
        
        -- Ambush on Blindside/Subterfuge. Do not use Ambush from stealth during Kingsbane & Deathmark.
        if OffCooldown(ids.Ambush) and ( Variables.UseFiller and ( PlayerHasBuff(ids.BlindsideBuff) or IsStealthed ) and ( not TargetHasDebuff(ids.Kingsbane) or TargetHasDebuff(ids.Deathmark) == false or PlayerHasBuff(ids.BlindsideBuff) ) ) then
            NGSend("Ambush") return true end
        
        -- Tab-Mutilate to apply Deadly Poison at 2 targets if not using Fan of Knives
        if OffCooldown(ids.Mutilate) and ( not TargetHasDebuff(ids.DeadlyPoisonDebuff) and not TargetHasDebuff(ids.AmplifyingPoisonDebuff) and Variables.UseFiller and NearbyEnemies == 2 ) then
            NGSend("Mutilate") return true end
        
        -- Fallback Mutilate
        if OffCooldown(ids.Mutilate) and ( Variables.UseFiller ) then
            NGSend("Mutilate") return true end
    end
    
    -- Shiv conditions
    local Shiv = function()
        Variables.ShivCondition = not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.Garrote) and TargetHasDebuff(ids.Rupture) and NearbyEnemies <= 5
        
        Variables.ShivKingsbaneCondition = IsPlayerSpell(ids.Kingsbane) and PlayerHasBuff(ids.Envenom) and Variables.ShivCondition
        
        -- Shiv for aoe with Arterial Precision
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.ArterialPrecisionTalent) and Variables.ShivCondition and NearbyEnemies >= 4 and TargetHasDebuff(ids.CrimsonTempest) ) then      
            NGSend("Shiv") return true end
        
        -- Shiv cases for Kingsbane
        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.Kingsbane) < 8 or not TargetHasDebuff(ids.Kingsbane) and GetRemainingSpellCooldown(ids.Kingsbane) >= 20 ) and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            NGSend("Shiv") return true end

        -- Shiv for big Darkest Night Envenom during Lingering Darkness
        if OffCooldown(ids.Shiv) and ( PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.LingeringDarknessBuff) ) then
            NGSend("Shiv") return true end
        
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.LightweightShivTalent) and Variables.ShivKingsbaneCondition and ( TargetHasDebuff(ids.Kingsbane) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) < 8 or GetRemainingSpellCooldown(ids.Kingsbane) <= 1 and GetSpellChargesFractional(ids.Shiv) >= 1.7 ) ) then
            NGSend("Shiv") return true end
        
        -- Fallback shiv for arterial during deathmark
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.ArterialPrecisionTalent) and not TargetHasDebuff(ids.ShivDebuff) and TargetHasDebuff(ids.Garrote) and TargetHasDebuff(ids.Rupture) and TargetHasDebuff(ids.Deathmark) ) then
            NGSend("Shiv") return true end
        
        -- Fallback if no special cases apply
        if OffCooldown(ids.Shiv) and ( not IsPlayerSpell(ids.Kingsbane) and not IsPlayerSpell(ids.ArterialPrecisionTalent) and Variables.ShivCondition and ( not IsPlayerSpell(ids.CrimsonTempest) or (NearbyEnemies < 2) or TargetHasDebuff(ids.CrimsonTempest) ) ) then
            NGSend("Shiv") return true end
        
        -- Dump Shiv on fight end
        if OffCooldown(ids.Shiv) and ( FightRemains(60, NearbyRange) <= C_Spell.GetSpellCharges(ids.Shiv).currentCharges * 8 ) then
            NGSend("Shiv") return true end
    end
    
    -- Stealthed Actions
    local Stealthed = function()
        -- Apply Deathstalkers Mark if it has fallen off or waiting for Rupture in AoE
        if OffCooldown(ids.Ambush) and ( not TargetHasDebuff(ids.DeathstalkersMarkDebuff) and IsPlayerSpell(ids.DeathstalkersMarkTalent) and EffectiveComboPoints < Variables.EffectiveSpendCp and ( TargetHasDebuff(ids.Rupture) or NearbyEnemies <= 1 or not IsPlayerSpell(ids.SubterfugeTalent)) ) then
            NGSend("Ambush") return true end
        
        -- Make sure to have Shiv up during Kingsbane as a final check
        if OffCooldown(ids.Shiv) and ( IsPlayerSpell(ids.KingsbaneTalent) and TargetHasDebuff(ids.KingsbaneDebuff) and GetRemainingDebuffDuration("target", ids.KingsbaneDebuff) < 8 and ( not TargetHasDebuff(ids.ShivDebuff) or GetRemainingDebuffDuration("target", ids.ShivDebuff) < 1 ) and PlayerHasBuff(ids.EnvenomBuff) ) then
            NGSend("Shiv") return true end
        
        -- Envenom to maintain the buff during Subterfuge
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and TargetHasDebuff(ids.Kingsbane) and GetRemainingAuraDuration("player", ids.Envenom) <= 3 and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 7) ) then
            NGSend("Envenom") return true end
        
        -- Envenom during Master Assassin in single target
        if OffCooldown(ids.Envenom) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and GetRemainingAuraDuration("player", ids.MasterAssassinBuff) < -1 and (NearbyEnemies < 2) and (TargetHasDebuff(ids.DeathstalkersMarkDebuff) or PlayerHasBuff(ids.ColdBlood) or PlayerHasBuff(ids.DarkestNightBuff) and EffectiveComboPoints == 7) ) then
            NGSend("Envenom") return true end
        
        -- Rupture during Indiscriminate Carnage
        if OffCooldown(ids.Rupture) and ( EffectiveComboPoints >= Variables.EffectiveSpendCp and PlayerHasBuff(ids.IndiscriminateCarnageBuff) and (IsAuraRefreshable(ids.Rupture) or NearbyRuptured < NearbyEnemies) and ( not Variables.RegenSaturated or not Variables.ScentSaturation or not TargetHasDebuff(ids.Rupture) ) and TargetTimeToXPct(0, 60) > 15 ) then
            NGSend("Rupture") return true end
        
        -- Improved Garrote: Apply or Refresh with buffed Garrotes, accounting for Indiscriminate Carnage
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( GetRemainingDebuffDuration("target", ids.Garrote) < 12 or ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or ( PlayerHasBuff(ids.IndiscriminateCarnageBuff) and NearbyGarroted < NearbyEnemies ) ) and not (NearbyEnemies < 2) and TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Garrote) > 2 and MaxComboPoints - EffectiveComboPoints > 2 - (PlayerHasBuff(ids.DarkestNightBuff) and 2 or 0)) then
            NGSend("Garrote") return true end
        
        if OffCooldown(ids.Garrote) and ( HasImprovedGarroteBuff and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and MaxComboPoints - EffectiveComboPoints >= 1 + 2 * (IsPlayerSpell(ids.ShroudedSuffocationTalent) and 1 or 0) ) then
            NGSend("Garrote") return true end
    end
    
    -- Stealth Cooldowns Vanish Sync for Improved Garrote with Deathmark
    local Vanish = function()
        -- Vanish to fish for Fateful Ending
        if OffCooldown(ids.Vanish) and ( not PlayerHasBuff(ids.FateboundLuckyCoinBuff) and EffectiveComboPoints >= Variables.EffectiveSpendCp and ( GetPlayerStacks(ids.FateboundCoinTailsBuff) >= 5 or GetPlayerStacks(ids.FateboundCoinHeadsBuff) >= 5 ) ) then
            NGSend("Vanish") return true end
        
        -- Vanish to spread Garrote during Deathmark without Indiscriminate Carnage
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.MasterAssassinTalent) and not IsPlayerSpell(ids.IndiscriminateCarnageTalent) and IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and ( TargetHasDebuff(ids.Deathmark) or GetRemainingSpellCooldown(ids.Deathmark) < 4 ) and MaxComboPoints - EffectiveComboPoints >= min(NearbyEnemies, 4) ) then
            NGSend("Vanish") return true end
        
        -- Vanish for cleaving Garrotes with Indiscriminate Carnage
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.IndiscriminateCarnageTalent) and IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and NearbyEnemies > 2 and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.Vanish) > 15  ) ) then
            NGSend("Vanish") return true end
        
        -- Vanish fallback for Master Assassin
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.MasterAssassinTalent) and TargetHasDebuff(ids.Deathmark) and GetRemainingDebuffDuration("target", ids.Kingsbane) <= 6 + 3 * (IsPlayerSpell(ids.SubterfugeTalent) and 2 or 0) ) then
            NGSend("Vanish") return true end
        
        -- Vanish fallback for Improved Garrote during Deathmark if no add waves are expected
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.ImprovedGarroteTalent) and OffCooldown(ids.Garrote) and ( ( not TargetHasDebuff(ids.Garrote) or aura_env.GarroteSnapshots[UnitGUID("target")] <= 1 ) or IsAuraRefreshable(ids.Garrote) ) and ( TargetHasDebuff(ids.Deathmark) or GetRemainingSpellCooldown(ids.Deathmark) < 4 )  ) then   
            NGSend("Vanish") return true end
    end
    
    -- Cooldowns
    local Cds = function()
        -- Wait on Deathmark for Garrote with MA and check for Kingsbane
        Variables.DeathmarkMaCondition = not IsPlayerSpell(ids.MasterAssassinTalent) or TargetHasDebuff(ids.Garrote)
        
        Variables.DeathmarkKingsbaneCondition = not IsPlayerSpell(ids.Kingsbane) or GetRemainingSpellCooldown(ids.Kingsbane) <= 2
        
        -- Deathmark to be used if not stealthed, Rupture is up, and all other talent conditions are satisfied
        Variables.DeathmarkCondition = not IsStealthed and GetRemainingAuraDuration("player", ids.SliceAndDice) > 5 and TargetHasDebuff(ids.Rupture) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and not TargetHasDebuff(ids.Deathmark) and Variables.DeathmarkMaCondition and Variables.DeathmarkKingsbaneCondition
        
        -- Cast Deathmark if the target will survive long enough
        if OffCooldown(ids.Deathmark) and ( ( Variables.DeathmarkCondition and TargetTimeToXPct(0, 60) >= 10 ) or FightRemains(60, NearbyRange) <= 20 ) then
            NGSend("Deathmark") return true end
        
        -- Check for Applicable Shiv usage
        if Shiv() then return true end
        
        if OffCooldown(ids.Kingsbane) and ( ( TargetHasDebuff(ids.ShivDebuff) or GetRemainingSpellCooldown(ids.Shiv) < 6 ) and ( PlayerHasBuff(ids.Envenom) or NearbyEnemies > 1 ) and ( GetRemainingSpellCooldown(ids.Deathmark) >= 50 or TargetHasDebuff(ids.Deathmark) ) or FightRemains(60, NearbyRange) <= 15 ) then
            NGSend("Kingsbane") return true end
        
        if not IsStealthed and abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) == 0 then
            if Vanish() then return true end end
    end
    
    -- Call Stealthed Actions
    if IsStealthed or HasImprovedGarroteBuff or abs(GetRemainingAuraDuration("player", ids.MasterAssassinBuff)) > 0 then
        if Stealthed() then return true end end
    
    -- Call Cooldowns    
    if Cds() then return true end
    
    -- Call Core DoT effects
    if CoreDot() then return true end
    
    -- Call AoE DoTs when in AoE
    if not (NearbyEnemies < 2) then
        if AoeDot() then return true end end
    
    -- Call Direct Damage Abilities
    if Direct() then return true end
    
    NGSend("Clear")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED

function(event, _, subEvent, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellID)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if subEvent == "SPELL_CAST_SUCCESS" then 
        aura_env.PrevCast = spellID 
        if spellID == aura_env.ids.Envenom then
            if IsPlayerSpell(aura_env.ids.TwistTheKnifeTalent) and aura_env.Envenom1 < GetTime() then
                aura_env.Envenom1 = aura_env.Envenom1
                aura_env.Envenom2 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            else
                aura_env.Envenom1 = aura_env.GetRemainingAuraDuration("player", aura_env.ids.Envenom) + GetTime()
            end
        end
    end
    
    if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
        if spellID == aura_env.ids.Garrote then
            local Multiplier = (aura_env.PlayerHasBuff(392403) or aura_env.PlayerHasBuff(392401)) and 1.5 or 1
            
            aura_env.GarroteSnapshots[targetGUID] = Multiplier
        end
    end
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Garrote Load------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.NearbyGarroted = 0
aura_env.MissingGarrote = 0

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Garrote Trig------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- NG_GARROTE_DATA

function(event, NearbyGarroted, NearbyEnemies)
    aura_env.NearbyGarroted = NearbyGarroted
    aura_env.MissingGarrote = NearbyEnemies - NearbyGarroted
    return true
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rupture Load------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.NearbyRuptured = 0
aura_env.MissingRupture = 0

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rupture Trig------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- NG_RUPTURE_DATA

function(event, NearbyRuptured, NearbyEnemies)
    aura_env.NearbyRuptured = NearbyRuptured
    aura_env.MissingRupture = NearbyEnemies - NearbyRuptured
    return true
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Nameplate Load----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.ShouldShowDebuff = function(unit)
    if UnitAffectingCombat(unit) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.NGWA and _G.NGWA.AssassinationRogue then
            for _, ID in ipairs(_G.NGWA.AssassinationRogue) do                
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