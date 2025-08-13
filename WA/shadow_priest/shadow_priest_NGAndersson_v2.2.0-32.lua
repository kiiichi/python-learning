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
_G.NGWA = { 
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
    Mindbender = 200174,
    ShadowCrash = 205385,
    ShadowWordDeath = 32379,
    ShadowWordPain = 589,
    Shadowfiend = 34433,
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

aura_env.NGSend = function(Name)
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name)
    WeakAuras.ScanEvents("NG_OUT_OF_RANGE", aura_env.OutOfRange)
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    if aura_env.config[tostring(spellID)] == false then return false end
    
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
    if IsPlayerSpell(457042) then ids.ShadowCrash = 457042 end
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1927)
    
    local CurrentInsanity = UnitPower("player", Enum.PowerType.Insanity)
    local MaxInsanity = UnitPowerMax("player", Enum.PowerType.Insanity)
    
    local NearbyEnemies = 0
    local NearbyRange = 40
    local UndottedEnemies = 0
    local DottedEnemies = 0
    local DevouredEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
            
            local FoundExcludedNPC = false
            for _, ID in ipairs(_G.NGWA.ShadowPriest) do                
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
    
    local ShadowfiendDuration = max(0, aura_env.ShadowfiendExpiration - GetTime())
    
    WeakAuras.ScanEvents("NG_VAMPIRIC_TOUCH_SPREAD", DottedEnemies, UndottedEnemies)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)
    
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
            NGSend("Vampiric Touch") return true end
        
        -- Use Shadow Crash to apply Vampiric Touch to as many adds as possible while being efficient with Vampiric Touch refresh windows
        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsAuraRefreshable(ids.VampiricTouchDebuff) or GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) <= TargetTimeToXPct(0, 60) and not PlayerHasBuff(ids.VoidformBuff) ) then
            NGSend("Shadow Crash") return true end
    end
    
    local Cds = function()
        -- Make sure Mindbender is active before popping Dark Ascension unless you have insignificant talent points or too many targets
        if OffCooldownNotCasting(ids.Halo) and ( IsPlayerSpell(ids.PowerSurgeTalent) and ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 and IsPlayerSpell(ids.Mindbender) or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) or not IsPlayerSpell(ids.DarkAscension) ) and ( C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or not OffCooldown(ids.VoidTorrent) or not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 4  or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent)) ) then
            NGSend("Halo") return true end
        
        -- Make sure Mindbender is active before popping Void Eruption and dump charges of Mind Blast before casting
        if OffCooldownNotCasting(ids.VoidEruption) and ( ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) ) and C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent) or PlayerHasBuff(ids.PowerSurgeBuff) ) then
            NGSend("Void Eruption") return true end
        
        -- Use Dark Ascension when you have enough Insanity to cast Devouring Plague.
        if OffCooldownNotCasting(ids.DarkAscension) and ( (ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent)) and (DevouredEnemies >= 1 or CurrentInsanity >= (20 - (5 * (not IsPlayerSpell(ids.MindsEyeTalent) and 1 or 0)) + (5 * (IsPlayerSpell(ids.DistortedRealityTalent) and 1 or 0 )) - (((ShadowfiendDuration > 0) and 1 or 0) * 2)) ) ) then
            NGSend("Dark Ascension") return true end
    end
    
    local Main = function()
        if NearbyEnemies < 3 then
            Variables.DotsUp = TargetHasDebuff(ids.VampiricTouchDebuff) or IsCasting(ids.VampiricTouch) or (GetTime() - aura_env.LastShadowCrash < 2) end
        
        if FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 and ( not Variables.HoldingCrash or NearbyEnemies > 2 ) then
            if Cds() then return true end end
        
        -- Use Shadowfiend and Mindbender on cooldown as long as Vampiric Touch and Shadow Word: Pain are active and sync with Dark Ascension
        if OffCooldown(ids.Shadowfiend) and GetRemainingSpellCooldown(ids.Mindbender) == 0 and GetRemainingSpellCooldown(ids.Voidwraith) == 0 and ( ( TargetHasDebuff(ids.ShadowWordPain) and Variables.DotsUp or (GetTime() - aura_env.LastShadowCrash < 2) ) and ( not OffCooldown(ids.Halo) or not IsPlayerSpell(ids.PowerSurgeTalent) ) and ( FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 ) and ( not IsPlayerSpell(ids.DarkAscension) or GetRemainingSpellCooldown(ids.DarkAscension) < 1.5 or FightRemains(60, NearbyRange) < 15 ) ) then
            NGSend("Shadowfiend") return true end
        
        -- High Priority Shadow Word: Death when you are forcing the bonus from Devour Matter
        if OffCooldown(ids.ShadowWordDeath) and ( (UnitGetTotalAbsorbs("target") > 0) and IsPlayerSpell(ids.DevourMatterTalent) ) then
            NGSend("Shadow Word Death") return true end
        
        -- Blast more burst :wicked:
        if OffCooldownNotCasting(ids.VoidBlast) and ( ( GetRemainingDebuffDuration("target", ids.DevouringPlague) >= max(C_Spell.GetSpellInfo(ids.VoidBlast).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5 or (select(8, UnitChannelInfo("player")) == ids.VoidTorrent) and IsPlayerSpell(ids.VoidEmpowermentTalent) ) and ( MaxInsanity - CurrentInsanity >= 16 or GetTimeToFullCharges(ids.MindBlast) <= 1.5 or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5) ) then
            NGSend("Void Blast") return true end
        
        -- Do not let Voidform Expire if you can avoid it.
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.PerfectedFormTalent) and GetRemainingAuraDuration("player", ids.VoidformBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and IsPlayerSpell(ids.VoidEruption) ) then
            NGSend("Devouring Plague") return true end
        
        -- Use Voidbolt on the enemy with the largest time to die. We do no care about dots because Voidbolt is only accessible inside voidform which guarantees maximum effect
        if GetRemainingSpellCooldown(ids.VoidBolt) == 0 and not IsCasting(ids.VoidBolt) and (PlayerHasBuff(ids.VoidformBuff) or IsCasting(ids.VoidEruption)) and ( MaxInsanity - CurrentInsanity > 16 and GetRemainingSpellCooldown(ids.VoidBolt) <= 0.1 ) then
            NGSend("Void Bolt") return true end
        
        -- Do not overcap on insanity
        if OffCooldown(ids.DevouringPlague) and ( DevouredEnemies <= 1 and GetRemainingDebuffDuration("target", ids.DevouringPlague) <= 1.5 and ( not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 3 ) or MaxInsanity - CurrentInsanity <= 35 or PlayerHasBuff(ids.MindDevourerBuff) or PlayerHasBuff(ids.EntropicRiftBuff) or PlayerHasBuff(ids.PowerSurgeBuff) and ( SetPieces >= 4 and IsPlayerSpell(ids.PowerSurgeTalent) and aura_env.Archon4pcStacks < 4 ) and PlayerHasBuff(ids.AscensionBuff) ) then      
            NGSend("Devouring Plague") return true end
        
        -- Use Void Torrent if it will get near full Mastery Value
        if OffCooldownNotCasting(ids.VoidTorrent) and ( not Variables.HoldingCrash and (GetRemainingDebuffDuration("target", ids.DevouringPlagueDebuff) >= 2.5 and ( GetRemainingSpellCooldown(ids.DarkAscension) >= 12 or not IsPlayerSpell(ids.DarkAscension) or not IsPlayerSpell(ids.VoidBlastTalent) ) or GetRemainingSpellCooldown(ids.VoidEruption) <= 3 and IsPlayerSpell(ids.VoidEruption) ) ) then
            NGSend("Void Torrent") return true end

        -- Use Void Volley if it would expire soon
        if PlayerHasBuff(ids.VoidVolleyBuff) and ( GetRemainingAuraDuration("player", ids.VoidVolleyBuff) <= 5 or PlayerHasBuff(ids.EntropicRiftBuff) and GetRemainingSpellCooldown(ids.VoidBlast) > GetRemainingAuraDuration("player", ids.EntropicRiftBuff) or TargetTimeToXPct(0, 60) <= 5 ) then
            NGSend("Void Volley") return true end
        
        -- MFI is a good button
        if OffCooldown(ids.MindFlay) and ( PlayerHasBuff(ids.MindFlayInsanityBuff) ) then
            NGSend("Mind Flay Insanity") return true end

        -- Use Shadow Crash as long as you are not holding for adds and Vampiric Touch is within pandemic range
        if OffCooldown(ids.ShadowCrash) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and not Variables.HoldingCrash and not (GetTime() - aura_env.LastShadowCrash < 2) ) then
            NGSend("Shadow Crash") return true end

        -- Put out Vampiric Touch on enemies that will live at least 12s and Shadow Crash is not available soon
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and TargetTimeToXPct(0, 60) > 12 and ( TargetHasDebuff(ids.VampiricTouchDebuff) or not Variables.DotsUp ) and ( Variables.MaxVts > 0 or NearbyEnemies <= 1 ) and ( GetRemainingSpellCooldown(ids.ShadowCrash) >= GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) or Variables.HoldingCrash or not IsPlayerSpell(ids.ShadowCrash) ) and ( not (GetTime() - aura_env.LastShadowCrash < 2) or not IsPlayerSpell(ids.ShadowCrash) ) ) then
            NGSend("Vampiric Touch") return true end

        -- Use all charges of Mind Blast if Vampiric Touch and Shadow Word: Pain are active and Mind Devourer is not active or you are prepping Void Eruption
        if OffCooldown(ids.MindBlast) and (C_Spell.GetSpellCharges(ids.MindBlast).currentCharges > 1 or not IsCasting(ids.MindBlast)) and ( not PlayerHasBuff(ids.MindDevourerBuff) or not IsPlayerSpell(ids.MindDevourerTalent) or OffCooldown(ids.VoidEruption) and IsPlayerSpell(ids.VoidEruption) ) then
            NGSend("Mind Blast") return true end

        if PlayerHasBuff(ids.VoidVolleyBuff) then
            NGSend("Void Volley") return true end

        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.VoidEruption) or PlayerHasBuff(ids.PowerSurgeBuff) or IsPlayerSpell(ids.DistortedRealityTalent) ) then      
            NGSend("Devouring Plague") return true end

        if OffCooldownNotCasting(ids.Halo) and ( NearbyEnemies > 1 ) then
            NGSend("Halo") return true end

        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsPlayerSpell(ids.DescendingDarknessTalent) ) then
            NGSend("Shadow Crash") return true end

        if OffCooldown(ids.ShadowWordDeath) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < ( 20 + 15 * (IsPlayerSpell(ids.DeathspeakerTalent) and 1 or 0) ) ) then
            NGSend("Shadow Word Death") return true end

        if OffCooldown(ids.ShadowWordDeath) and ( IsPlayerSpell(ids.InescapableTormentTalent) and ShadowfiendDuration > 0 ) then
            NGSend("Shadow Word Death") return true end

        if OffCooldown(ids.MindFlay) then
            NGSend("Mind Flay") return true end

        if OffCooldown(ids.DivineStar) then
            NGSend("Divine Star") return true end
    end
    
    if NearbyEnemies > 2 then
        if Aoe() then return true end end
    
    if Main() then return true end
    
    NGSend("Clear")
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

-- NG_UPDATE_SHADOWFIEND_EXPIRATION

function(Event, Expiration)
    if Expiration ~= nil then
        aura_env.ShadowfiendExpiration = Expiration
    end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Name plate load--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

aura_env.ShouldShowDebuff = function(unit)
    if UnitAffectingCombat(unit) and not UnitIsFriend("player", unit) and UnitClassification(unit) ~= "minus" and not WA_GetUnitDebuff(unit, aura_env.config["DebuffID"]) then
        if _G.NGWA then
            for _, ID in ipairs(_G.NGWA.ShadowPriest) do                
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
        WeakAuras.ScanEvents("NG_UPDATE_SHADOWFIEND_EXPIRATION", EndTime)
        return true
    end
    
    -- Extend duration if Inescapable Torment active
    if UnitGUID("player") == sourceGUID and subEvent == "SPELL_CAST_SUCCESS" and IsPlayerSpell(373427) and (spellID == 8092 or spellID == 32379) then
        if allStates["bender"] and allStates["bender"].show then            
            allStates["bender"].duration = allStates["bender"].duration + 0.7
            allStates["bender"].expirationTime = allStates["bender"].expirationTime + 0.7
            allStates["bender"].changed = true
            
            WeakAuras.ScanEvents("NG_UPDATE_SHADOWFIEND_EXPIRATION", allStates["bender"].expirationTime)
            return true
        end
    end
end