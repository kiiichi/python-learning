----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

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
    HowlOfThePackLeaderCooldownBuff = 471877,
    HowlWyvernBuff = 471878,
    HuntmastersCallBuff = 459731,
    HuntersPreyBuff = 378215,
    LeadFromTheFrontBuff = 472743,
    SerpentStingDebuff = 271788,
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1923)
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
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    --local ExtraGlows = {}
    
    --WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        if OffCooldown(ids.BestialWrath) and ( GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) - GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) < ( 12 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 0.5 ) or SetPieces < 4 or IsPlayerSpell(ids.Multishot) )  then
            NGSend("Bestial Wrath") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < WeakAuras.gcdDuration() or GetSpellChargesFractional(ids.BarbedShot) >= GetSpellChargesFractional(ids.KillCommand) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            NGSend("Bloodshed") return true end
        
        if OffCooldown(ids.Multishot) and ( not WA_GetUnitBuff("pet", ids.BeastCleavePetBuff) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or GetRemainingSpellCooldown(ids.CallOfTheWild) > 0 ) ) then
            NGSend("Multishot") return true end
        
        if OffCooldown(ids.CallOfTheWild) then
            NGSend("Call of the Wild") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.KillCommand) then
            NGSend("Kill Command") return true end
        
        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()) < WeakAuras.gcdDuration() * 2 or GetPlayerStacks(ids.HogstriderBuff) > 3 or not IsPlayerSpell(ids.Multishot) ) then 
            NGSend("Cobra Shot") return true end        
    end
    
    local Drcleave = function()
        if OffCooldown(ids.KillShot) then
            NGSend("Kill Shot") return true end
        
        if OffCooldown(ids.BestialWrath) and ( GetRemainingSpellCooldown(ids.CallOfTheWild) > 20 or not IsPlayerSpell(ids.CallOfTheWild) ) then
            NGSend("Bestial Wrath") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < WeakAuras.gcdDuration() ) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            NGSend("Bloodshed") return true end
        
        if OffCooldown(ids.Multishot) and ( not WA_GetUnitBuff("pet", ids.BeastCleavePetBuff) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or GetRemainingSpellCooldown(ids.CallOfTheWild) ) ) then
            NGSend("Multishot") return true end
        
        if OffCooldown(ids.CallOfTheWild) then
            NGSend("Call of the Wild") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            NGSend("Explosive Shot") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetSpellChargesFractional(ids.BarbedShot) >= GetSpellChargesFractional(ids.KillCommand) ) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.KillCommand) then
            NGSend("Kill Command") return true end
        
        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()) < WeakAuras.gcdDuration() * 2 ) then
            NGSend("Cobra Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) then
            NGSend("Explosive Shot") return true end
    end
    
    local Drst = function()
        if OffCooldown(ids.KillShot) then
            NGSend("Kill Shot") return true end
        
        if OffCooldown(ids.BestialWrath) and ( GetRemainingSpellCooldown(ids.CallOfTheWild) > 20 or not IsPlayerSpell(ids.CallOfTheWild) ) then
            NGSend("Bestial Wrath") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < WeakAuras.gcdDuration() ) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            NGSend("Bloodshed") return true end
        
        if OffCooldown(ids.CallOfTheWild) then
            NGSend("Call of the Wild") return true end
        
        if OffCooldown(ids.KillCommand) then
            NGSend("Kill Command") return true end
        
        if OffCooldown(ids.BarbedShot) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            NGSend("Cobra Shot") return true end
    end
    
    local St = function()
        if OffCooldown(ids.BestialWrath) and ( GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) - GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) < ( 12 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 0.5 ) or SetPieces < 4 ) then
            NGSend("Bestial Wrath") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < WeakAuras.gcdDuration() ) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.CallOfTheWild) then
            NGSend("Call of the Wild") return true end
        
        if OffCooldown(ids.Bloodshed) then
            NGSend("Bloodshed") return true end
        
        if OffCooldown(ids.KillCommand) and ( GetSpellChargesFractional(ids.KillCommand) >= GetSpellChargesFractional(ids.BarbedShot) and not ( GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) > WeakAuras.gcdDuration() and GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) < WeakAuras.gcdDuration() * 2 and not HowlSummonReady and GetTimeToFullCharges(ids.KillCommand) > WeakAuras.gcdDuration()) ) then
            NGSend("Kill Command") return true end
        
        if OffCooldown(ids.BarbedShot) then
            NGSend("Barbed Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            NGSend("Cobra Shot") return true end
    end
    
    if IsPlayerSpell(ids.BlackArrowTalent) and ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3) then
        if Drst() then return true end end
    
    if IsPlayerSpell(ids.BlackArrowTalent) and ( NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1) then
        if Drcleave() then return true end end
    
    if not IsPlayerSpell(ids.BlackArrowTalent) and (NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3) then
        if St() then return true end end
    
    if not IsPlayerSpell(ids.BlackArrowTalent) and (NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1) then
        if Cleave() then return true end end
    
    NGSend("Clear")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


