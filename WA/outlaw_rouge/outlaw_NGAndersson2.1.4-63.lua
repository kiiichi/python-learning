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
    AdrenalineRush = 13750,
    Ambush = 8676,
    BetweenTheEyes = 315341,
    BladeFlurry = 13877,
    BladeRush = 271877,
    ColdBlood = 382245,
    CoupDeGrace = 441776,
    Dispatch = 2098,
    EchoingReprimand = 385616,
    GhostlyStrike = 196937,
    KeepItRolling = 381989,
    KillingSpree = 51690,
    MarkedForDeath = 137619,
    PistolShot = 185763,
    RollTheBones = 315508,
    Shadowmeld = 135201,
    SinisterStrike = 193315,
    SliceAndDice = 315496,
    ThistleTea = 381623,
    Vanish = 1856,
    
    -- Talents
    CrackshotTalent = 423703,
    DeftManeuversTalent = 381878,
    DoubleJeopardyTalent = 454430,
    FanTheHammerTalent = 381846,
    FatefulEndingTalent = 454428,
    FlawlessFormTalent = 441321,
    GreenskinsWickersTalent = 386823,
    HandOfFateTalent = 452536,
    HiddenOpportunityTalent = 383281,
    ImprovedAdrenalineRushTalent = 395422,
    ImprovedAmbushTalent = 381620,
    ImprovedBetweenTheEyesTalent = 235484,
    KeepItRollingTalent = 381989,
    KillingSpreeTalent = 51690,
    LoadedDiceTalent = 256170,
    MeanStreakTalent = 453428,
    QuickDrawTalent = 196938,
    RuthlessnessTalent = 14161,
    SealFateTalent = 14190,
    SubterfugeTalent = 108208,
    SuperchargerTalent = 470347,
    TakeEmBySurpriseTalent = 382742,
    UnderhandedUpperHandTalent = 424044,
    WithoutATraceTalent = 382513,
    
    -- Buffs
    AdrenalineRushBuff = 13750,
    AudacityBuff = 386270,
    BetweenTheEyesBuff = 315341,
    BroadsideBuff = 193356,
    BuriedTreasureBuff = 199600,
    EscalatingBladeBuff = 441786,
    FateboundCoinHeadsBuff = 452923,
    FateboundCoinTailsBuff = 452917,
    FateboundLuckyCoinBuff = 452562,
    GrandMeleeBuff = 193358,
    GreenskinsWickersBuff = 394131,
    LoadedDiceBuff = 256171,
    OpportunityBuff = 195627,
    RuthlessPrecisionBuff = 193357,
    SkullAndCrossbonesBuff = 199603,
    Stealth = 115191,
    SubterfugeBuff = 115192,
    TakeEmBySurpriseBuff = 385907,
    TrueBearingBuff = 193359,
    VanishBuff = 11327,
}

aura_env.RTBContainerExpires = 0

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

aura_env.GetRemainingStealthDuration = function()
    if WA_GetUnitAura("player", aura_env.ids.Stealth) or WA_GetUnitAura("player", aura_env.ids.VanishBuff) then return 999999999 end
    
    local SubterfugeExpiration = select(6, WA_GetUnitAura("player", aura_env.ids.SubterfugeBuff))
    if SubterfugeExpiration ~= nil then return SubterfugeExpiration - GetTime() end
    
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
    
    ---- Setup Data -----------------------------------------------------------------------------------------------    
    local Variables = {}
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1876)
    local CurrentComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    
    local IsStealthed = PlayerHasBuff(ids.SubterfugeBuff) or PlayerHasBuff(ids.Stealth) or PlayerHasBuff(ids.VanishBuff)
    
    local EffectiveComboPoints = CurrentComboPoints
    
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    
    local NearbyEnemies = 0
    local NearbyRange = 8
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and UnitIsFriend("player", unit) == false and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    local RTBBuffCount = 0
    local RTBBuffMaxRemains = 0
    local RTBBuffMinRemains = 0
    local RTBBuffWillLose = 0
    local RTBBuffWillRetain = 0
    local RTBBuffNormal = 0
    local RTBContainerRemaining = max(aura_env.RTBContainerExpires - GetTime(), 0)
    local Buffids = {
        193356, -- Broadside
        193357, -- Ruthless Precision
        193358, -- Grand Melee
        193359, -- True Bearing
        199600, -- Buried Treasure
        199603, -- Skull and Crossbones
    }
    for _, Id in ipairs(Buffids) do
        if PlayerHasBuff(Id) then
            RTBBuffCount = RTBBuffCount + 1
            RTBBuffMaxRemains = math.max(RTBBuffMaxRemains, GetRemainingAuraDuration("player", Id))
            RTBBuffMinRemains = (RTBBuffMinRemains == 0 and GetRemainingAuraDuration("player", Id) or math.min(RTBBuffMinRemains, GetRemainingAuraDuration("player", Id)))
            if GetRemainingAuraDuration("player", Id) > RTBContainerRemaining + 0.3 then
                RTBBuffWillRetain = RTBBuffWillRetain + 1
            else
                if ( GetRemainingAuraDuration("player", Id) > RTBContainerRemaining - 0.3) then
                    RTBBuffNormal = RTBBuffNormal + 1
                end
                RTBBuffWillLose = RTBBuffWillLose + 1
            end
        end
    end
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables.AmbushCondition = ( IsPlayerSpell(ids.HiddenOpportunityTalent) or MaxComboPoints - CurrentComboPoints >= 2 + (IsPlayerSpell(ids.ImprovedAmbushTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) and CurrentEnergy >= 50
    
    -- Use finishers if at -1 from max combo points, or -2 in Stealth with Crackshot. With the hero trees, Hidden Opportunity builds also finish at -2 if Audacity or Opportunity is active.
    Variables.FinishCondition = CurrentComboPoints >= MaxComboPoints - 1 - ( (IsStealthed and IsPlayerSpell(ids.CrackshotTalent) or ( IsPlayerSpell(ids.HandOfFateTalent) or IsPlayerSpell(ids.FlawlessFormTalent) ) and IsPlayerSpell(ids.HiddenOpportunityTalent) and ( PlayerHasBuff(ids.AudacityBuff) or PlayerHasBuff(ids.OpportunityBuff) ) ) and 1 or 0)
    
    -- Variable that counts how many buffs are ahead of RtB's pandemic range, which is only possible by using KIR.
    Variables.BuffsAbovePandemic = ( GetRemainingAuraDuration("player", ids.BroadsideBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.TrueBearingBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.GrandMeleeBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.BuriedTreasureBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.SkullAndCrossbonesBuff) > 39 and 1 or 0 )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
        NGSend("Clear", nil) return end
    
    -- Maintain Adrenaline Rush. Recast while already active if using Impreved ADR and at low CPs.
    if OffCooldown(ids.AdrenalineRush) and ( not PlayerHasBuff(ids.AdrenalineRush) and ( not Variables.FinishCondition or not IsPlayerSpell(ids.ImprovedAdrenalineRushTalent) ) or IsPlayerSpell(ids.ImprovedAdrenalineRushTalent) and CurrentComboPoints <= 2 ) then
        ExtraGlows.AdrenalineRush = true
    end
    
    -- Ghostly Strike
    if OffCooldown(ids.GhostlyStrike) and ( CurrentComboPoints < MaxComboPoints ) then
        ExtraGlows.GhostlyStrike = true
    end
    
    -- Thistle Tea
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTea) and ( CurrentEnergy < aura_env.config["ThistleTeaEnergy"] or TargetTimeToXPct(0, 999) < C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) ) then
        ExtraGlows.ThistleTea = true
    end
    
    -- With a natural 5 buff roll, use Keep it Rolling when you obtain the remaining buff from Count the Odds and all buffs are within 30s remaining.
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffNormal >= 5 and RTBBuffCount == 6 and RTBBuffMaxRemains <= 30 ) then
        ExtraGlows.KeepItRolling = true
    end
    
    -- Without a natural 5 buff roll, use Keep it Rolling at any 4+ buffs
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffCount >= 4 and RTBBuffNormal <= 2 ) then
        ExtraGlows.KeepItRolling = true
    end
    
    -- Without a natural 5 buff roll, use Keep it Rolling at 3 buffs if you have the combination of Ruthless Precision + Broadside + True Bearing.
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffCount >= 3 and RTBBuffNormal <= 2 and PlayerHasBuff(ids.BroadsideBuff) and PlayerHasBuff(ids.RuthlessPrecisionBuff) and PlayerHasBuff(ids.TrueBearingBuff) ) then
        ExtraGlows.KeepItRolling = true
    end
    
    -- Cold Blood
    if OffCooldown(ids.ColdBlood) then
        ExtraGlows.ColdBlood = true
    end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- With multiple targets, this variable is checked to decide whether some CDs should be synced with Blade Flurry
    -- Variables.BladeFlurrySync = NearbyEnemies < 2  or GetRemainingAuraDuration("player", ids.BladeFlurry) > aura_env.config["BFHeadsup"]
    
    -- Builders
    local Build = function()
        -- High priority Ambush for Hidden Opportunity builds.
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.AudacityBuff) ) then
            NGSend("Ambush") return true end
        
        -- With Audacity + Hidden Opportunity + Fan the Hammer, consume Opportunity to proc Audacity any time Ambush is not available.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and IsPlayerSpell(ids.AudacityBuff) and IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.OpportunityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) then
            NGSend("Pistol Shot") return true end
        
        -- With Fan the Hammer, consume Opportunity as a higher priority if at max stacks or if it will expire.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( GetPlayerStacks(ids.OpportunityBuff) >= (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) or GetRemainingAuraDuration("player", ids.OpportunityBuff) < 2 ) ) then
            NGSend("Pistol Shot") return true end
        
        -- With Fan the Hammer, consume Opportunity if it will not overcap CPs, or with 1 CP at minimum.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxComboPoints - CurrentComboPoints >= ( 1 + ( (IsPlayerSpell(ids.QuickDrawTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) * ( (IsPlayerSpell(ids.FanTheHammerTalent) and 1 or 0) + 1 ) ) or CurrentComboPoints <= (IsPlayerSpell(ids.RuthlessnessTalent) and 1 or 0) ) ) then
            NGSend("Pistol Shot") return true end
        
        -- If not using Fan the Hammer, then consume Opportunity based on energy, when it will exactly cap CPs, or when using Quick Draw.
        if OffCooldown(ids.PistolShot) and ( not IsPlayerSpell(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxEnergy - CurrentEnergy > 75 or MaxComboPoints - CurrentComboPoints <= 1 + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) or IsPlayerSpell(ids.QuickDrawTalent) or IsPlayerSpell(ids.AudacityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) ) then
            NGSend("Pistol Shot") return true end
        
        -- Fallback pooling just so Sinister Strike is never casted if Ambush is available for Hidden Opportunity builds
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) ) then
            NGSend("Ambush") return true end
        
        if OffCooldown(ids.SinisterStrike) then
            NGSend("Sinister Strike") return true end
    end
        
    local Finish = function()
        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace then
            NGSend("Dispatch") return true end
        
        -- Finishers Use Between the Eyes outside of Stealth to maintain the buff, or with Ruthless Precision active, or to proc Greenskins Wickers if not active. Trickster builds can also send BtE on cooldown.
        if OffCooldown(ids.BetweenTheEyes) and ( ( PlayerHasBuff(ids.RuthlessPrecisionBuff) or GetRemainingAuraDuration("player", ids.BetweenTheEyesBuff) < 4 or not IsPlayerSpell(ids.MeanStreakTalent) ) and ( not PlayerHasBuff(ids.GreenskinsWickersBuff) or not IsPlayerSpell(ids.GreenskinsWickersTalent) ) ) then
            NGSend("Between the Eyes") return true end
        
        --if OffCooldown(ids.CoupDeGrace) then
        --    NGSend("Coup De Grace") return true end
        
        if OffCooldown(ids.Dispatch) then
            NGSend("Dispatch") return true end
    end
    
    local VanishUsage = function()
        -- Vanish usage for builds using Underhanded Upper Hand, Crackshot and Subterfuge.  Without Killing Spree, attempt to hold Vanish for when BtE is on cooldown and Ruthless Precision is active. Also with Keep it Rolling, hold Vanish if we haven't done the first roll after KIR yet.
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.KillingSpreeTalent) and not OffCooldown(ids.BetweenTheEyes) and GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 4 and ( GetRemainingSpellCooldown(ids.KeepItRolling) > 150 and RTBBuffNormal > 0 or not IsPlayerSpell(ids.KeepItRollingTalent) ) ) then
            NGSend("Vanish") return true end
        
        -- Vanish to prevent Adrenaline Rush downtime.
        if OffCooldown(ids.Vanish) and ( GetRemainingAuraDuration("player", ids.AdrenalineRushBuff) < 3 and GetRemainingSpellCooldown(ids.AdrenalineRush) > 10 ) then
            NGSend("Vanish") return true end
        
        -- Supercharger builds that do not use Killing Spree should Vanish if Supercharger is active.
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.KillingSpreeTalent) and GetUnitChargedPowerPoints("player") ~= nil  ) then
            NGSend("Vanish") return true end
        
        -- Builds with Killing Spree can freely Vanish if KS is not up soon.
        if OffCooldown(ids.Vanish) and ( GetRemainingSpellCooldown(ids.KillingSpree) > 15 ) then
            NGSend("Vanish") return true end
        
        -- Vanish if about to cap on charges or sim duration is ending.
        if OffCooldown(ids.Vanish) and ( GetTimeToFullCharges(ids.Vanish) < 15 or FightRemains(60, NearbyRange) < 8 ) then
            NGSend("Vanish") return true end
    end
    
    -- Vanish usage for builds lacking one of the mandatory talents Crackshot, Underhanded Upper Hand or Subterfuge. APL support for these builds is considered limited.
    local VanishUsageOffMeta = function()
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and not IsPlayerSpell(ids.CrackshotTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and ( Variables.AmbushCondition or not IsPlayerSpell(ids.HiddenOpportunityTalent) ) and ( not OffCooldown(ids.BetweenTheEyes) and PlayerHasBuff(ids.RuthlessPrecisionBuff) or PlayerHasBuff(ids.RuthlessPrecisionBuff) == false or GetRemainingAuraDuration("player", ids.AdrenalineRushBuff) < 3 ) ) then
            NGSend("Vanish") return true end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.CrackshotTalent) and Variables.FinishCondition ) then
            NGSend("Vanish") return true end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.HiddenOpportunityTalent) and not PlayerHasBuff(ids.AudacityBuff) and GetPlayerStacks(ids.OpportunityBuff) < (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) and Variables.AmbushCondition ) then
            NGSend("Vanish") return true end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and not IsPlayerSpell(ids.HiddenOpportunityTalent) and IsPlayerSpell(ids.FatefulEndingTalent) and ( not PlayerHasBuff(ids.FateboundLuckyCoinBuff) and ( GetPlayerStacks(ids.FateboundCoinTailsBuff) >= 5 or GetPlayerStacks(ids.FateboundCoinHeadsBuff) >= 5 ) or PlayerHasBuff(ids.FateboundLuckyCoinBuff) and not OffCooldown(ids.BetweenTheEyes) ) ) then
            NGSend("Vanish") return true end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and not IsPlayerSpell(ids.HiddenOpportunityTalent) and not IsPlayerSpell(ids.FatefulEndingTalent) and IsPlayerSpell(ids.TakeEmBySurpriseTalent) and not PlayerHasBuff(ids.TakeEmBySurpriseBuff) ) then
            NGSend("Vanish") return true end
    end
    
    local Cds = function()
        -- Maintain Blade Flurry on 2+ targets.
        if OffCooldown(ids.BladeFlurry) and ( NearbyEnemies >= 2 and GetRemainingAuraDuration("player", ids.BladeFlurry) < aura_env.config["BFHeadsup"] ) then
            NGSend("Blade Flurry") return true end
        
        -- With Deft Maneuvers, use Blade Flurry on cooldown at 5+ targets, or at 3-4 targets if missing combo points equal to the amount it would grant.
        if OffCooldown(ids.BladeFlurry) and ( IsPlayerSpell(ids.DeftManeuversTalent) and not Variables.FinishCondition and ( NearbyEnemies >= 3 and MaxComboPoints - CurrentComboPoints == NearbyEnemies + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) or NearbyEnemies >= 5 ) ) then
            NGSend("Blade Flurry") return true end
        
        -- Maintain Roll the Bones: cast without any buffs.
        if OffCooldown(ids.RollTheBones) and ( RTBBuffCount == 0 ) then
            NGSend("Roll the Bones") return true end
        
        -- With TWW2 set, recast Roll the Bones if we will roll away between 0-1 buffs. If KIR was recently used on a natural 5 buff, then wait until all buffs are below around 41s remaining.
        if OffCooldown(ids.RollTheBones) and ( (SetPieces >= 4) and RTBBuffWillLose <= 1 and ( Variables.BuffsAbovePandemic < 5 or RTBBuffMaxRemains < 42 ) ) then
            NGSend("Roll the Bones") return true end
        
        -- With TWW2 set, recast Roll the Bones with at most 2 buffs active regardless of duration. Supercharger builds will also roll if we will lose between 0-4 buffs, but KIR Supercharger builds wait until they are all below 11s remaining.
        if OffCooldown(ids.RollTheBones) and ( (SetPieces >= 4) and ( RTBBuffCount <= 2 or (RTBBuffMaxRemains < 11 or not IsPlayerSpell(ids.KeepItRolling)) and RTBBuffWillLose < 5 and IsPlayerSpell(ids.SuperchargerTalent) ) ) then
            NGSend("Roll the Bones") return true end
        
        -- Without TWW2 set or Sleight of Hand, recast Roll the Bones to override 1 buff into 2 buffs with Loaded Dice, or reroll any 2 buffs with Loaded Dice+Supercharger. Hidden Opportunity builds can also reroll 2 buffs with Loaded Dice to try for BS/RP/TB.
        if OffCooldown(ids.RollTheBones) and ( not (SetPieces >= 4) and ( RTBBuffWillLose <= (PlayerHasBuff(ids.LoadedDiceBuff) and 1 or 0) or IsPlayerSpell(ids.SuperchargerTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 or IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 and not PlayerHasBuff(ids.BroadsideBuff) and not PlayerHasBuff(ids.RuthlessPrecisionBuff) and not PlayerHasBuff(ids.TrueBearingBuff) ) ) then
            NGSend("Roll the Bones") return true end
        
        -- Killing Spree has higher priority than entering stealth.
        if OffCooldown(ids.KillingSpree) and ( Variables.FinishCondition and not IsStealthed ) then
            NGSend("Killing Spree") return true end
        
        -- Builds with Crackshot, Underhanded Upper Hand and Subterfuge use Vanish while Adrenaline Rush is active, the finisher condition is met, and not already in stealth. Trickster builds also consume Coup de Grace before Vanishing if it is ready.
        if not IsStealthed and IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and GetPlayerStacks(ids.EscalatingBladeBuff) < 4 and PlayerHasBuff(ids.AdrenalineRushBuff) and Variables.FinishCondition then
            if VanishUsage() then return true end end
        
        if not IsStealthed and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) or not IsPlayerSpell(ids.CrackshotTalent) or not IsPlayerSpell(ids.SubterfugeTalent) ) then
            if VanishUsageOffMeta() then return true end end
        
        -- Use Blade Rush at minimal energy outside of stealth
        if OffCooldown(ids.BladeRush) and ( CurrentEnergy < aura_env.config["BRKSEnergy"] and not IsStealthed ) then
            NGSend("Blade Rush") return true end
    end
    
    local Stealth = function()
        -- High priority Between the Eyes for Crackshot, except not directly out of Shadowmeld.
        if OffCooldown(ids.BetweenTheEyes) and ( Variables.FinishCondition and IsPlayerSpell(ids.CrackshotTalent) and ( not PlayerHasBuff(ids.Shadowmeld) or IsStealthed ) ) then
            NGSend("Between the Eyes") return true end
        
        if OffCooldown(ids.Dispatch) and ( Variables.FinishCondition ) then
            NGSend("Dispatch") return true end
        
        -- 2 Fan the Hammer Crackshot builds can consume Opportunity in stealth with max stacks, Broadside, and 1 CP, or with Greenskins active
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.FanTheHammerTalent) and GetPlayerStacks(ids.OpportunityBuff) >= 6 and ( PlayerHasBuff(ids.BroadsideBuff) and CurrentComboPoints <= 1 or PlayerHasBuff(ids.GreenskinsWickersBuff) ) ) then
            NGSend("Pistol Shot") return true end
        
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) ) then
            NGSend("Ambush") return true end
    end
    
    if Cds() then return true end
    
    -- High priority stealth list, will fall through if no conditions are met.
    if IsStealthed then
        if Stealth() then return true end end
    
    if Variables.FinishCondition then
        Finish() return true end
    
    if Build() then return true end
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS

function(_, _, _, _, sourceGUID, _, _, _, _, _, _, _, spellId, ...)
    if sourceGUID == UnitGUID("PLAYER") and spellId == 315508 then
        -- Initial prediction
        local Expires = GetTime() + 30
        if aura_env.RTBContainerExpires and aura_env.RTBContainerExpires > GetTime() then
            local Offset = math.min(aura_env.RTBContainerExpires - GetTime(), 9)
            aura_env.RTBContainerExpires = Expires + Offset
        else
            aura_env.RTBContainerExpires = Expires
        end
    end

