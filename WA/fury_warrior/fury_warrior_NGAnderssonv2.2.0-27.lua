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
    if (not usable) then return false end
    
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
    local NGSend = aura_env.NGSend
    
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
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
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
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Slayer = function()
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.AshenJuggernautBuff) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) <= WeakAuras.gcdDuration() ) then
            NGSend("Execute") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetRemainingAuraDuration("player", ids.SuddenDeathBuff) < 2 and not Variables.ExecutePhase ) then
            NGSend("Execute") return true end

        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 ) then
            NGSend("Thunderous Roar") return true end

        if OffCooldown(ids.ChampionsSpear) and ( OffCooldown(ids.Bladestorm) and ( OffCooldown(ids.Avatar) or OffCooldown(ids.Recklessness) or PlayerHasBuff(ids.Avatar) or PlayerHasBuff(ids.RecklessnessBuff) ) and PlayerHasBuff(ids.EnrageBuff) ) then
            NGSend("Champions Spear") return true end

        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and ( IsPlayerSpell(ids.RecklessAbandonTalent) and GetRemainingSpellCooldown(ids.Avatar) >= 24 or IsPlayerSpell(ids.AngerManagementTalent) and GetRemainingSpellCooldown(ids.Recklessness) >= 15 and ( PlayerHasBuff(ids.Avatar) or GetRemainingSpellCooldown(ids.Avatar) >= 8 ) ) ) then
            NGSend("Bladestorm") return true end
        
        if OffCooldown(ids.Whirlwind) and ( NearbyEnemies >= 2 and IsPlayerSpell(ids.MeatCleaverTalent) and GetPlayerStacks(ids.MeatCleaverBuff) == 0 ) then
            NGSend("Whirlwind") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) and PlayerHasBuff(ids.BrutalFinishBuff) ) then
            NGSend("Onslaught") return true end

        if OffCooldown(ids.Rampage) and ( GetRemainingAuraDuration("player", ids.EnrageBuff) < WeakAuras.gcdDuration() ) then
            NGSend("Rampage") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetPlayerStacks(ids.SuddenDeathBuff) == 2 and PlayerHasBuff(ids.EnrageBuff) ) then
            NGSend("Execute") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( GetTargetStacks(ids.MarkedForExecutionDebuff) > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            NGSend("Execute") return true end
        
        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            NGSend("Odyns Fury") return true end
        
        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow and ( C_Spell.GetSpellCharges(ids.RagingBlow).currentCharges == 2 or PlayerHasBuff(ids.BrutalFinishBuff) and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            NGSend("Crushing Blow") return true end
        
        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath and ( GetPlayerStacks(ids.BloodcrazeBuff) >= 1 or ( IsPlayerSpell(ids.UproarTalent) and GetRemainingDebuffDuration("target", ids.BloodbathDotDebuff) < 40 and IsPlayerSpell(ids.BloodborneTalent) ) or PlayerHasBuff(ids.EnrageBuff) and GetRemainingAuraDuration("player", ids.EnrageBuff) < WeakAuras.gcdDuration() ) then
            NGSend("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( PlayerHasBuff(ids.BrutalFinishBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) < 5 and ( not TargetHasDebuff(ids.ChampionsMightDebuff) or TargetHasDebuff(ids.ChampionsMightDebuff) and GetRemainingDebuffDuration("target", ids.ChampionsMightDebuff) > WeakAuras.gcdDuration() ) ) then
            NGSend("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage > 115 ) then
            NGSend("Rampage") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( Variables.ExecutePhase and TargetHasDebuff(ids.MarkedForExecutionDebuff) and PlayerHasBuff(ids.EnrageBuff) ) then
            NGSend("Execute") return true end

        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) and PlayerHasBuff(ids.BrutalFinishBuff) and PlayerHasBuff(ids.EnrageBuff) or NearbyEnemies >= 6 ) then
            NGSend("Bloodthirst") return true end

        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            NGSend("Crushing Blow") return true end

        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            NGSend("Bloodbath") return true end
        
        if OffCooldown(ids.RagingBlow) and ( PlayerHasBuff(ids.OpportunistBuff) ) then
            NGSend("Raging Blow") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ViciousContemptTalent) ) then
            NGSend("Bloodthirst") return true end
        
        if OffCooldown(ids.RagingBlow) and ( GetSpellChargesFractional(ids.RagingBlow) == 2 ) then
            NGSend("Raging Blow") return true end

        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            NGSend("Onslaught") return true end

        if OffCooldown(ids.RagingBlow) then
            NGSend("Raging Blow") return true end

        if OffCooldown(ids.Rampage) then
            NGSend("Rampage") return true end
        
        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            NGSend("Odyns Fury") return true end

        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( PlayerHasBuff(ids.SuddenDeathBuff) ) then
            NGSend("Execute") return true end

        if OffCooldown(ids.Bloodthirst) then
            NGSend("Bloodthirst") return true end
        
        if OffCooldown(ids.ThunderousRoar) then
            NGSend("Thunderous Roar") return true end

        if OffCooldown(ids.WreckingThrow) then
            NGSend("Wrecking Throw") return true end
        
        if OffCooldown(ids.Whirlwind) then
            NGSend("Whirlwind") return true end
        
        --if OffCooldown(ids.StormBolt) and ( PlayerHasBuff(ids.BladestormBuff) ) then
        --    NGSend("Storm Bolt") return true end
    end
    
    local Thane = function()
        if OffCooldown(ids.Ravager) then
            NGSend("Ravager") return true end
        
        if OffCooldown(ids.ThunderousRoar) and ( NearbyEnemies > 1 and PlayerHasBuff(ids.EnrageBuff) ) then
            NGSend("Thunderous Roar") return true end
        
        if OffCooldown(ids.ChampionsSpear) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.ChampionsMightTalent) ) then
            NGSend("Champions Spear") return true end
        
        if OffCooldown(ids.ThunderClap) and ( GetPlayerStacks(ids.MeatCleaverBuff) == 0 and IsPlayerSpell(ids.MeatCleaverTalent) and NearbyEnemies >= 2 ) then
            NGSend("Thunder Clap") return true end
        
        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.MeatCleaverTalent) ) then
            NGSend("Thunder Blast") return true end

        if OffCooldown(ids.Rampage) and ( not PlayerHasBuff(ids.EnrageBuff) or ( IsPlayerSpell(ids.Bladestorm) and GetRemainingSpellCooldown(ids.Bladestorm) <= WeakAuras.gcdDuration() and not TargetHasDebuff(ids.ChampionsMightDebuff) ) ) then
            NGSend("Rampage") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) and ( IsPlayerSpell(ids.AshenJuggernautTalent) and GetRemainingAuraDuration("player", ids.AshenJuggernautBuff) <= WeakAuras.gcdDuration() ) then
            NGSend("Execute") return true end
        
        if OffCooldown(ids.Bladestorm) and ( PlayerHasBuff(ids.EnrageBuff) and IsPlayerSpell(ids.UnhingedTalent) ) then
            NGSend("Bladestorm") return true end
        
        if OffCooldown(ids.Bloodthirst) and FindSpellOverrideByID(ids.Bloodthirst) == ids.Bloodbath then
            NGSend("Bloodbath") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 115 and IsPlayerSpell(ids.RecklessAbandonTalent) and PlayerHasBuff(ids.RecklessnessBuff) and GetPlayerStacks(ids.SlaughteringStrikesBuff) >= 3 ) then
            NGSend("Rampage") return true end
        
        if OffCooldown(ids.RagingBlow) and FindSpellOverrideByID(ids.RagingBlow) == ids.CrushingBlow then
            NGSend("Crushing Blow") return true end
        
        if OffCooldown(ids.Onslaught) and ( IsPlayerSpell(ids.TenderizeTalent) ) then
            NGSend("Onslaught") return true end
        
        if OffCooldown(ids.Bloodthirst) and ( IsPlayerSpell(ids.ViciousContemptTalent) and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 ) then
            NGSend("Bloodthirst") return true end
        
        if OffCooldown(ids.Rampage) and ( CurrentRage >= 100 ) then
            NGSend("Rampage") return true end
        
        if OffCooldown(ids.Bloodthirst) then
            NGSend("Bloodthirst") return true end

        if OffCooldown(ids.OdynsFury) and ( NearbyEnemies > 1 and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) ) then
            NGSend("Odyns Fury") return true end

        if OffCooldown(ids.RagingBlow) then
            NGSend("Raging Blow") return true end
        
        if OffCooldown(ids.Rampage) then
            NGSend("Rampage") return true end

        if GetRemainingSpellCooldown(ids.ThunderClap) == 0 and aura_env.config[tostring(ids.ThunderClap)] and FindSpellOverrideByID(ids.ThunderClap) == ids.ThunderBlast and ( not IsPlayerSpell(ids.MeatCleaverTalent) ) then
            NGSend("Thunder Blast") return true end

        if OffCooldown(ids.ThunderousRoar) then
            NGSend("Thunderous Roar") return true end
        
        if OffCooldown(ids.OdynsFury) and ( PlayerHasBuff(ids.EnrageBuff) or IsPlayerSpell(ids.TitanicRageTalent) ) then
            NGSend("Odyns Fury") return true end

        if OffCooldown(ids.ChampionsSpear) and ( not IsPlayerSpell(ids.ChampionsMightTalent) ) then
            NGSend("Champions Spear") return true end
        
        if OffCooldown(ids.Execute) and (GetRemainingSpellCooldown(ids.ExecuteMassacre) == 0 or not IsPlayerSpell(ids.ExecuteMassacreTalent)) then
            NGSend("Execute") return true end
        
        if OffCooldown(ids.WreckingThrow) then
            NGSend("Wrecking Throw") return true end
        
        if OffCooldown(ids.ThunderClap) then
            NGSend("Thunder Clap") return true end

        if OffCooldown(ids.Whirlwind) then
            NGSend("Whirlwind") return true end
    end
    
    if IsPlayerSpell(ids.SlayersDominanceTalent) then
        Slayer() return true end
    
    if IsPlayerSpell(ids.LightningStrikesTalent) then
        Thane() return true end
    
    NGSend("Clear")
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