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
    BullseyeTalent = 204089,
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
    
    -- Buffs/Debuffs
    BulletstormBuff = 389020,
    BullseyeBuff = 204090,
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
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

aura_env.NGSend = function(Name, Extra)
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name, Extra)
    WeakAuras.ScanEvents("NG_OUT_OF_RANGE", aura_env.OutOfRange)
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    if aura_env.config[tostring(spellID)] == false then return false end
    
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
            elseif action >= 145 and action <= 156 then
                bindstring = 'MULTIACTIONBAR5BUTTON'..modact
            elseif action >= 157 and action <= 168 then
                bindstring = 'MULTIACTIONBAR6BUTTON'..modact
            elseif action >= 169 and action <= 180 then
                bindstring = 'MULTIACTIONBAR7BUTTON'..modact
            end
            local keyBind = GetBindingKey(bindstring)
            
            
            -- Skip forms you're not currently in
            local FormSkip = false
            if WA_GetUnitBuff("player", 768) and action >= 97 and action <= 120 then FormSkip = true -- Cat, includes Prowlbar
            elseif WA_GetUnitBuff("player", 5487) and ((action >= 73 and action <= 96) or (action >= 109 and action <= 120)) then FormSkip = true -- Bear
            elseif WA_GetUnitBuff("player", 24858) and action >= 73 and action <= 108 then FormSkip = true -- Moonkin
            elseif not (WA_GetUnitBuff("player", 768) or WA_GetUnitBuff("player", 5487) or WA_GetUnitBuff("player", 24858)) and action > 73 and action <= 120 then FormSkip = true end -- No form?
            
            if keyBind and not FormSkip then
                
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
    
    local HasPreciseShots = PlayerHasBuff(ids.PreciseShotsBuff) or IsCasting(ids.AimedShot)
    local TargetHasSpottersMark = TargetHasDebuff(ids.SpottersMarkDebuff) and not IsCasting(ids.AimedShot)
    local HasMovingTarget = PlayerHasBuff(ids.MovingTargetBuff) and not IsCasting(ids.AimedShot)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    local Variables = {}

    -- Hold the final Trueshot for Bullseye stacks if necessary.
    Variables.TrueshotReady = not IsPlayerSpell(ids.BullseyeTalent) or FightRemains(60, NearbyRange) > 90 + 15 or GetPlayerStacks(ids.BullseyeBuff) == 30 or FightRemains(60, NearbyRange) < 25
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and ( PlayerHasBuff(ids.TrueshotBuff) == false or not IsPlayerSpell(ids.WindrunnerQuiverTalent) ) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( HasPreciseShots and not HasMovingTarget and Variables.TrueshotReady ) then
            NGSend("Black Arrow") return true end
        
        if OffCooldown(ids.Volley) and ( ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false or not IsPlayerSpell(ids.AspectOfTheHydraTalent) ) and ( not HasPreciseShots or HasMovingTarget ) ) then
            NGSend("Volley") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.BulletstormTalent) and PlayerHasBuff(ids.BulletstormBuff) == false and ( not IsPlayerSpell(ids.DoubleTapTalent) or PlayerHasBuff(ids.DoubleTapBuff) or not IsPlayerSpell(ids.AspectOfTheHydraTalent) and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) and ( not HasPreciseShots or HasMovingTarget or not IsPlayerSpell(ids.VolleyTalent) ) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and ( not HasPreciseShots or HasMovingTarget ) ) then
            NGSend("Volley") return true end
        
        if OffCooldown(ids.Trueshot) and ( Variables.TrueshotReady and ( PlayerHasBuff(ids.DoubleTapBuff) == false or not IsPlayerSpell(ids.VolleyTalent) ) and ( PlayerHasBuff(ids.LunarStormReadyBuff) == false or not IsPlayerSpell(ids.DoubleTapTalent) or not IsPlayerSpell(ids.VolleyTalent) ) and ( not HasPreciseShots or HasMovingTarget or not IsPlayerSpell(ids.VolleyTalent) ) ) then
            NGSend("Trueshot") return true end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to. Sentinel only seems to like this due to the Precise Shots gcd bug.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            NGSend("Steady Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.LunarStormTalent) and PlayerHasBuff(ids.LunarStormCooldownBuff) == false and ( not HasPreciseShots or HasMovingTarget or GetRemainingSpellCooldown(ids.Volley) > 0 and GetRemainingSpellCooldown(ids.Trueshot) > 0 or not IsPlayerSpell(ids.VolleyTalent) ) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            NGSend("Kill Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            NGSend("Black Arrow") return true end
        
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) and not IsPlayerSpell(ids.AspectOfTheHydraTalent) and ( IsPlayerSpell(ids.SymphonicArsenalTalent) or IsPlayerSpell(ids.SmallGameHunterTalent) ) ) then
            NGSend("Multishot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            NGSend("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a little higher when close to capping charges.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) <= 10 or IsPlayerSpell(ids.AspectOfTheHydraTalent) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) or PlayerHasBuff(ids.TrueshotBuff) == false ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) ) then
            NGSend("Black Arrow") return true end
        
        if OffCooldown(ids.SteadyShot) then
            NGSend("Steady Shot") return true end
    end
    
    local Drst = function()
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and PlayerHasBuff(ids.TrueshotBuff) == false and not PlayerHasBuff(ids.LockAndLoadBuff) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            NGSend("Volley") return true end
        
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            NGSend("Steady Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) or IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            NGSend("Black Arrow") return true end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( PlayerHasBuff(ids.TrueshotBuff) and not HasPreciseShots or PlayerHasBuff(ids.LockAndLoadBuff) and HasMovingTarget ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( not PlayerHasBuff(ids.DeathblowBuff) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.Trueshot) and ( Variables.TrueshotReady and not PlayerHasBuff(ids.DoubleTapBuff) and not PlayerHasBuff(ids.DeathblowBuff) ) then
            NGSend("Trueshot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            NGSend("Arcane Shot") return true end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.SteadyShot) then
            NGSend("Steady Shot") return true end
    end
    
    local Sentst = function()
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and PlayerHasBuff(ids.TrueshotBuff) == false ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            NGSend("Volley") return true end
        
        if OffCooldown(ids.Trueshot) and ( Variables.TrueshotReady and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            NGSend("Trueshot") return true end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to. Sentinel only seems to like this due to the Precise Shots gcd bug.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            NGSend("Steady Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.LunarStormTalent) and PlayerHasBuff(ids.LunarStormCooldownBuff) == false ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            NGSend("Kill Shot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            NGSend("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a little higher when close to capping charges.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) or PlayerHasBuff(ids.TrueshotBuff) == false ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.SteadyShot) then
            NGSend("Steady Shot") return true end
    end
    
    local Trickshots = function()
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and PlayerHasBuff(ids.TrueshotBuff) == false and ( not IsPlayerSpell(ids.ShrapnelShotTalent) or PlayerHasBuff(ids.LockAndLoadBuff) == false ) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( not IsPlayerSpell(ids.ShrapnelShotTalent) or PlayerHasBuff(ids.LockAndLoadBuff) == false ) ) then
            NGSend("Volley") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.BulletstormTalent) and PlayerHasBuff(ids.BulletstormBuff) == false and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.SentinelTalent) and PlayerHasBuff(ids.LunarStormCooldownBuff) == false and GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) ) then
            NGSend("Rapid Fire") return true end
        
        -- Queue Steady Shot after Aimed Shot if a Deathblow hasn't already been up long enough to be reacted to.
        if OffCooldown(ids.SteadyShot) and ( IsPlayerSpell(ids.BlackArrowTalent) and CurrentFocus + 20 < MaxFocus and (IsCasting(ids.AimedShot) or aura_env.PrevCast == ids.AimedShot and GetTime() - aura_env.PrevCastTime < 0.15) and not PlayerHasBuff(ids.DeathblowBuff) and PlayerHasBuff(ids.TrueshotBuff) == false and GetRemainingSpellCooldown(ids.Trueshot) ) then
            NGSend("Steady Shot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) or HasPreciseShots or PlayerHasBuff(ids.TrickShotsBuff) == false ) then
            NGSend("Black Arrow") return true end
        
        -- Retarget to possibly spread an extra Spotter's Mark if able.
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and not HasMovingTarget or PlayerHasBuff(ids.TrickShotsBuff) == false ) then
            NGSend("Multishot") return true end
        
        if OffCooldown(ids.Trueshot) and ( Variables.TrueshotReady and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            NGSend("Trueshot") return true end
        
        if OffCooldown(ids.Volley) and ( PlayerHasBuff(ids.DoubleTapBuff) == false and ( not IsPlayerSpell(ids.SalvoTalent) or not IsPlayerSpell(ids.PrecisionDetonationTalent) or ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) ) then
            NGSend("Volley") return true end
        
        -- Prioritize Aimed Shot a little higher when close to capping charges.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) and PlayerHasBuff(ids.BulletstormBuff) and GetTimeToFullCharges(ids.AimedShot) < WeakAuras.gcdDuration() ) then
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.RapidFire) and ( GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.BlackArrowTalent) or PlayerHasBuff(ids.DeathblowBuff) == false ) and ( not IsPlayerSpell(ids.NoScopeTalent) or not TargetHasSpottersMark ) and ( IsPlayerSpell(ids.NoScopeTalent) or PlayerHasBuff(ids.BulletstormBuff) == false ) ) then
            NGSend("Rapid Fire") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and IsPlayerSpell(ids.ShrapnelShotTalent) and PlayerHasBuff(ids.LockAndLoadBuff) == false and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.TrickShotsBuff) ) then 
            NGSend("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( not IsPlayerSpell(ids.ShrapnelShotTalent) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.SteadyShot) and ( CurrentFocus + 20 < MaxFocus ) then
            NGSend("Steady Shot") return true end
        
        if OffCooldown(ids.Multishot) then
            NGSend("Multishot") return true end
    end
    
    
    
    if NearbyEnemies > 2 and IsPlayerSpell(ids.TrickShotsTalent) then
        if Trickshots() then return true end end
    
    if NearbyEnemies > 1 then
        if Cleave() then return true end end
    
    if NearbyEnemies <= 1 and ( IsPlayerSpell(ids.BlackArrowTalent) ) then
        if Drst() then return true end end
    
    if NearbyEnemies <= 1 and ( not IsPlayerSpell(ids.BlackArrowTalent) ) then
        if Sentst() then return true end end
    
    NGSend("Clear")
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
    aura_env.PrevCastTime = GetTime()
    return
end