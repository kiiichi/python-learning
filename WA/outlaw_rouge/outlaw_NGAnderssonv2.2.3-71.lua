----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.RTBContainerExpires = 0
aura_env.DisorientingStrikesCount = 0
aura_env.HasTww34PcTricksterBuff = false
aura_env.LastKillingSpree = 0
aura_env.PrevCoupCast = 99999999

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
    CoupDeGraceTalent = 441423,
    CrackshotTalent = 423703,
    DeftManeuversTalent = 381878,
    DisorientingStrikesTalent = 441274,
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
    NimbleFlurryTalent = 441367,
    QuickDrawTalent = 196938,
    RuthlessnessTalent = 14161,
    SealFateTalent = 14190,
    SleightOfHandTalent = 381839,
    SubterfugeTalent = 108208,
    SuperchargerTalent = 470347,
    SurprisingStrikesTalent = 441273,
    TakeEmBySurpriseTalent = 382742,
    UnderhandedUpperHandTalent = 424044,
    UnseenBladeTalent = 441146,
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
    local IsSpellKnown = C_SpellBook.IsSpellKnown
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------    
    local Variables = {}
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1928)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1876)
    local CurrentComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    
    local IsStealthed = PlayerHasBuff(ids.SubterfugeBuff) or PlayerHasBuff(ids.Stealth) or PlayerHasBuff(ids.VanishBuff)
    
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    local HasDisorientingStrikes = aura_env.DisorientingStrikesCount > 0
    
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
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables.AmbushCondition = ( IsSpellKnown(ids.HiddenOpportunityTalent) or MaxComboPoints - CurrentComboPoints >= 2 + (IsSpellKnown(ids.ImprovedAmbushTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) and CurrentEnergy >= 50
    
    -- Use finishers if at -1 from max combo points, or -2 in Stealth with Crackshot. With the hero trees, Hidden Opportunity builds also finish at -2 if Audacity or Opportunity is active.
    Variables.FinishCondition = CurrentComboPoints >= MaxComboPoints - 1 - ( (IsStealthed and IsSpellKnown(ids.CrackshotTalent) or ( IsSpellKnown(ids.HandOfFateTalent) or IsSpellKnown(ids.UnseenBladeTalent) ) and IsSpellKnown(ids.HiddenOpportunityTalent) and ( PlayerHasBuff(ids.AudacityBuff) or PlayerHasBuff(ids.OpportunityBuff) ) ) and 1 or 0)
    
    -- Variable that counts how many buffs are ahead of RtB's pandemic range, which is only possible by using KIR.
    Variables.BuffsAbovePandemic = ( GetRemainingAuraDuration("player", ids.BroadsideBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.TrueBearingBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.GrandMeleeBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.BuriedTreasureBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.SkullAndCrossbonesBuff) > 39 and 1 or 0 )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
        NGSend("Clear", nil) return end
    
    -- Maintain Adrenaline Rush. With Improved AR, recast at low CPs even if already active. With TWW3 Fatebound, attempt to send AR alondside Vanish if there is a Vanish charge available.
    if OffCooldown(ids.AdrenalineRush) and ( not PlayerHasBuff(ids.AdrenalineRush) and ( not Variables.FinishCondition or not IsSpellKnown(ids.ImprovedAdrenalineRushTalent) ) or PlayerHasBuff(ids.AdrenalineRushBuff) and CurrentComboPoints <= 2 and ( GetSpellChargesFractional(ids.Vanish) < 1 or not ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) ) ) then
        ExtraGlows.AdrenalineRush = true
    end
    
    -- High priority Ghostly Strike as it is off-gcd. Trickster builds with 1 point in Fan the Hammer prefer not to use it at max CPs.
    if OffCooldown(ids.GhostlyStrike) and ( IsSpellKnown(ids.HandOfFateTalent) and  ( GetSpellChargesFractional(ids.Vanish) < 1 or not ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) ) or IsSpellKnown(ids.UnseenBladeTalent) and ( CurrentComboPoints < MaxComboPoints or IsSpellKnown(ids.FanTheHammerTalent) ) ) then
        ExtraGlows.GhostlyStrike = true
    end
    
    -- Thistle Tea
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTea) and ( CurrentEnergy < aura_env.config["ThistleTeaEnergy"] or TargetTimeToXPct(0, 999) < C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) ) then
        ExtraGlows.ThistleTea = true
    end
    
    -- Use Keep it Rolling immediately with any 4 RTB buffs. If a natural 5 buff is rolled, then wait until the final 6th buff is obtained from Count the Odds.
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffCount >= 4 and RTBBuffNormal <= 2 or RTBBuffNormal >= 5 and RTBBuffCount == 6 ) then
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
    
    -- Builders
    local Build = function()
        -- High priority Ambush with Hidden Opportunity.
        if OffCooldown(ids.Ambush) and ( IsSpellKnown(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.AudacityBuff) ) then
            NGSend("Ambush") return true end
        
        -- Outside of stealth, Trickster builds should prioritize Sinister Strike when Unseen Blade is guaranteed. This is mostly neutral/irrelevant for Hidden Opportunity builds.
        if OffCooldown(ids.SinisterStrike) and ( HasDisorientingStrikes and not IsStealthed and not IsSpellKnown(ids.HiddenOpportunityTalent) and GetPlayerStacks(ids.EscalatingBladeBuff) < 4 and not
        aura_env.HasTww34PcTricksterBuff) then
            NGSend("Sinister Strike") return true end
        
        -- With Audacity + Hidden Opportunity + Fan the Hammer, consume Opportunity to proc Audacity any time Ambush is not available.
        if OffCooldown(ids.PistolShot) and ( IsSpellKnown(ids.FanTheHammerTalent) and IsSpellKnown(ids.AudacityBuff) and IsSpellKnown(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.OpportunityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) then
            NGSend("Pistol Shot") return true end
        
        -- Without Hidden Opportunity, prioritize building CPs with Blade Flurry at 4+ targets. Trickster shoulds prefer to use this at low CPs unless AR isn't active.
        if OffCooldown(ids.BladeFlurry) and ( IsSpellKnown(ids.DeftManeuversTalent) and NearbyEnemies >= 4 and ( CurrentComboPoints <= 2 or not PlayerHasBuff(ids.AdrenalineRushBuff) or not IsSpellKnown(ids.UnseenBladeTalent)) ) then
            NGSend("Blade Flurry") return true end
        
        -- At sustain 3 targets (2 target for Fatebound 1FTH), Blade Flurry can be used to build CPs if we are missing CPs equal to the amount it will give.
        if OffCooldown(ids.BladeFlurry) and ( IsSpellKnown(ids.DeftManeuversTalent) and MaxComboPoints - CurrentComboPoints == NearbyEnemies + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) and NearbyEnemies >= 3 - (IsSpellKnown(ids.HandOfFateTalent) and 1 or 0) and IsSpellKnown(ids.FanTheHammerTalent) ) then
            NGSend("Blade Flurry") return true end
        
        -- With 2 ranks in Fan the Hammer, consume Opportunity as a higher priority if at max stacks or if it will expire.
        if OffCooldown(ids.PistolShot) and ( IsSpellKnown(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( GetPlayerStacks(ids.OpportunityBuff) >= (IsSpellKnown(ids.FanTheHammerTalent) and 6 or 1) or GetRemainingAuraDuration("player", ids.OpportunityBuff) < 2 ) ) then
            NGSend("Pistol Shot") return true end
        
        -- With Fan the Hammer, consume Opportunity if it will not overcap CPs, or with 1 CP at minimum.
        if OffCooldown(ids.PistolShot) and ( IsSpellKnown(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxComboPoints - CurrentComboPoints >= ( 1 + ( (IsSpellKnown(ids.QuickDrawTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) * ( (IsSpellKnown(ids.FanTheHammerTalent) and 1 or 0) + 1 ) ) or CurrentComboPoints <= (IsSpellKnown(ids.RuthlessnessTalent) and 1 or 0) ) ) then
            NGSend("Pistol Shot") return true end
        
        -- If not using Fan the Hammer, then consume Opportunity based on energy, when it will exactly cap CPs, or when using Quick Draw.
        if OffCooldown(ids.PistolShot) and ( not IsSpellKnown(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxEnergy - CurrentEnergy > 75 or MaxComboPoints - CurrentComboPoints <= 1 + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) or IsSpellKnown(ids.QuickDrawTalent) or IsSpellKnown(ids.AudacityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) ) then
            NGSend("Pistol Shot") return true end
        
        -- Use Coup de Grace at low CPs if Sinister Strike would otherwise be used.
        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace and (not IsStealthed) then
            NGSend("Dispatch") return true end
        
        -- Fallback pooling just so Sinister Strike is never casted if Ambush is available with Hidden Opportunity.
        if OffCooldown(ids.Ambush) and ( IsSpellKnown(ids.HiddenOpportunityTalent) ) then
            NGSend("Ambush") return true end
        
        if OffCooldown(ids.SinisterStrike) then
            NGSend("Sinister Strike") return true end
    end
    
    local Finish = function()
        -- Keep it Rolling builds with 2FTH should cancel Killing Spree after reaching max CPs during the animation.
        if OffCooldown(ids.KillingSpree) then
            NGSend("Killing Spree") return true end
        
        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace then
            NGSend("Dispatch") return true end
        
        -- Outside of stealth, use Between the Eyes to maintain the buff, or with Ruthless Precision active, or to proc Greenskins Wickers if not active. Trickster builds can also send BtE on cooldown.
        if OffCooldown(ids.BetweenTheEyes) and ( ( PlayerHasBuff(ids.RuthlessPrecisionBuff) or GetRemainingAuraDuration("player", ids.BetweenTheEyesBuff) < 4 or not IsSpellKnown(ids.HandOfFateTalent) ) and ( not PlayerHasBuff(ids.GreenskinsWickersBuff) or not IsSpellKnown(ids.GreenskinsWickersTalent) ) ) then
            NGSend("Between the Eyes") return true end
        
        if OffCooldown(ids.Dispatch) then
            NGSend("Dispatch") return true end
    end
    
    local Vanish = function()
        -- Vanish usage for standard builds  TWW3 Fatebound always attempts to align Vanish with Ghostly Strike.
        if OffCooldown(ids.Vanish) and ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) and OffCooldown(ids.GhostlyStrike) and IsSpellKnown(ids.GhostlyStrike) ) then
            NGSend("Vanish") return true end

        -- Fatebound without TWW3, or builds without Killing Spree attempt to hold Vanish for when BtE is on cooldown and Ruthless Precision is active.
        if OffCooldown(ids.Vanish) and ( ( IsSpellKnown(ids.HandOfFateTalent) or not IsSpellKnown(ids.KillingSpreeTalent) ) and ( not OffCooldown(ids.BetweenTheEyes) and GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 4 or GetUnitChargedPowerPoints("player") ~= nil ) and ( not ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) or not IsSpellKnown(ids.GhostlyStrike) ) ) then
            NGSend("Vanish") return true end
        
        -- Trickster builds with Killing Spree should Vanish if Killing Spree is not up soon. With TWW3 Trickster, attempt to align Vanish with a recently used Coup de Grace.
        if OffCooldown(ids.Vanish) and ( IsSpellKnown(ids.UnseenBladeTalent) and IsSpellKnown(ids.KillingSpreeTalent) and GetRemainingSpellCooldown(ids.KillingSpree) > 30 and (CurrentTime - aura_env.LastKillingSpree) <= 10 or not (SetPieces >= 4) ) then
            NGSend("Vanish") return true end
        
        -- Vanish if about to cap charges or sim duration is ending soon. TWW3 Fatebound will sit on max charges for an upcoming Ghostly Strike.
        if OffCooldown(ids.Vanish) and ( GetTimeToFullCharges(ids.Vanish) < 15 and ( not ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) or not IsSpellKnown(ids.GhostlyStrike) ) or FightRemains(60, NearbyRange) < GetSpellChargesFractional(ids.Vanish) * 8 ) then
            NGSend("Vanish") return true end
    end
    
    local RollTheBones = function()
        -- With TWW2, Sleight of Hand, or Supercharger: roll if you will lose 0 or 1 buffs. This includes rolling immediately after KIR. With TWW2, don't roll immediately after a natural 5 buff KIR.
        if OffCooldown(ids.RollTheBones) and ( ( OldSetPieces >= 4 or IsSpellKnown(ids.SleightOfHandTalent) or IsSpellKnown(ids.SuperchargerTalent) ) and RTBBuffWillLose <= 1 and ( Variables.BuffsAbovePandemic < 5 or RTBBuffMaxRemains < 42 or OldSetPieces < 4 ) ) then
            NGSend("Roll the Bones") return true end

        -- With TWW2, or Supercharger with either Loaded Dice or Sleight of Hand without KIR: roll over any 2 buffs.
        if OffCooldown(ids.RollTheBones) and ( ( OldSetPieces >= 4 or IsSpellKnown(ids.SuperchargerTalent) and ( PlayerHasBuff(ids.LoadedDiceBuff) or IsSpellKnown(ids.SleightOfHandTalent) and not IsSpellKnown(ids.KeepItRollingTalent) ) ) and RTBBuffCount <= 2 ) then
            NGSend("Roll the Bones") return true end
        
        -- With TWW2, roll over 3-4 buffs, but KIR builds only if all buffs are under ~10 seconds remaining.
        if OffCooldown(ids.RollTheBones) and ( OldSetPieces >= 4 and RTBBuffWillLose < 5 and ( RTBBuffMaxRemains < 11 or not IsSpellKnown(ids.KeepItRollingTalent) ) ) then
            NGSend("Roll the Bones") return true end
            
        -- Without TWW2, HO builds without Supercharger can roll over 2 buffs with Loaded Dice active and you won't lose Broadside, Ruthless Precision, or True Bearing.
        if OffCooldown(ids.RollTheBones) and ( not (OldSetPieces >= 4) and not IsSpellKnown(ids.KeepItRollingTalent) and not IsSpellKnown(ids.SuperchargerTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 and not PlayerHasBuff(ids.BroadsideBuff) and not PlayerHasBuff(ids.RuthlessPrecisionBuff) and not PlayerHasBuff(ids.TrueBearingBuff) ) then
            NGSend("Roll the Bones") return true end
    end
    
    local Cds = function()
        -- Maintain Blade Flurry at 2+ targets.
        if OffCooldown(ids.BladeFlurry) and ( NearbyEnemies >= 2 and GetRemainingAuraDuration("player", ids.BladeFlurry) < aura_env.config["BFHeadsup"] ) then
            NGSend("Blade Flurry") return true end
        
        -- Call the various Roll the Bones rules.
        if RollTheBones() then return true end
        
        -- If necessary, standard builds prioritize using Vanish at any CP to prevent Adrenaline Rush downtime.
        if OffCooldown(ids.Vanish) and ( IsSpellKnown(ids.UnderhandedUpperHandTalent) and IsSpellKnown(ids.SubterfugeTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and not IsStealthed and GetRemainingAuraDuration("player", ids.AdrenalineRushBuff) < 2 and GetRemainingSpellCooldown(ids.AdrenalineRush) > 30 ) then
            NGSend("Vanish") return true end
        
        -- If not at risk of losing Adrenaline Rush, run finishers to use Killing Spree or Coup de Grace as a higher priority than Vanish.
        if not IsStealthed and ( OffCooldown(ids.KillingSpree) and IsSpellKnown(ids.KillingSpreeTalent) or GetPlayerStacks(ids.EscalatingBladeBuff) >= 4 or aura_env.HasTww34PcTricksterBuff ) and Variables.FinishCondition then
            Finish() return true end
        
        -- If not at risk of losing Adrenaline Rush, call flexible Vanish rules to be used at finisher CPs, or Fatebound TWW3 can Vanish at low CPs if AR is ready.
        if not IsStealthed and IsSpellKnown(ids.CrackshotTalent) and IsSpellKnown(ids.UnderhandedUpperHandTalent) and IsSpellKnown(ids.SubterfugeTalent) and ( PlayerHasBuff(ids.AdrenalineRushBuff) and Variables.FinishCondition and ( not OffCooldown(ids.AdrenalineRush) or not ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) ) or ( SetPieces >= 2 and IsSpellKnown(ids.HandOfFateTalent) ) and OffCooldown(ids.AdrenalineRush) and CurrentComboPoints <= 2 ) then
            if Vanish() then return true end end
        
        -- Fallback Vanish for builds lacking one of the mandatory stealth talents. If possible, Vanish for AR, otherwise for Ambush when Audacity isn't active, or otherwise to proc Take 'em By Surprise or Fatebound coins.
        if OffCooldown(ids.Vanish) and ( not IsStealthed and ( Variables.FinishCondition or not IsSpellKnown(ids.CrackshotTalent) ) and ( not IsSpellKnown(ids.UnderhandedUpperHandTalent) or not IsSpellKnown(ids.SubterfugeTalent) or not IsSpellKnown(ids.CrackshotTalent) ) and ( PlayerHasBuff(ids.AdrenalineRushBuff) and IsSpellKnown(ids.SubterfugeTalent) and IsSpellKnown(ids.UnderhandedUpperHandTalent) or ( ( not IsSpellKnown(ids.SubterfugeTalent) or not IsSpellKnown(ids.UnderhandedUpperHandTalent) ) and IsSpellKnown(ids.HiddenOpportunityTalent) and not PlayerHasBuff(ids.AudacityBuff) and GetPlayerStacks(ids.OpportunityBuff) < (IsSpellKnown(ids.FanTheHammerTalent) and 6 or 1) and Variables.AmbushCondition or ( not IsSpellKnown(ids.HiddenOpportunityTalent) and ( IsSpellKnown(ids.TakeEmBySurpriseTalent) or IsSpellKnown(ids.DoubleJeopardyTalent) ) ) ) ) ) then
            NGSend("Vanish") return true end
        
        -- Use Blade Rush at minimal energy outside of stealth
        if OffCooldown(ids.BladeRush) and ( CurrentEnergy < aura_env.config["BRKSEnergy"] and not IsStealthed ) then
            NGSend("Blade Rush") return true end
    end
    
    local Stealth = function()
        -- High priority Between the Eyes for Crackshot, except not directly out of Shadowmeld.
        if OffCooldown(ids.BetweenTheEyes) and ( Variables.FinishCondition and IsSpellKnown(ids.CrackshotTalent) and ( not PlayerHasBuff(ids.Shadowmeld) or IsStealthed ) ) then
            NGSend("Between the Eyes") return true end
        
        if OffCooldown(ids.Dispatch) and ( Variables.FinishCondition ) then
            NGSend("Dispatch") return true end
        
        -- Inside stealth, 2FTH builds can consume Opportunity for Greenskins, or with max stacks + Broadside active + minimal CPs.
        if OffCooldown(ids.PistolShot) and ( IsSpellKnown(ids.CrackshotTalent) and IsSpellKnown(ids.FanTheHammerTalent) and GetPlayerStacks(ids.OpportunityBuff) >= 6 and ( PlayerHasBuff(ids.BroadsideBuff) and CurrentComboPoints <= 1 or PlayerHasBuff(ids.GreenskinsWickersBuff) ) ) then
            NGSend("Pistol Shot") return true end
        
        if OffCooldown(ids.Ambush) and ( IsSpellKnown(ids.HiddenOpportunityTalent) ) then
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
    if sourceGUID == UnitGUID("PLAYER") then
        if spellId == aura_env.ids.RollTheBones then
            -- Initial prediction
            local Expires = GetTime() + 30
            if aura_env.RTBContainerExpires and aura_env.RTBContainerExpires > GetTime() then
                local Offset = math.min(aura_env.RTBContainerExpires - GetTime(), 9)
                aura_env.RTBContainerExpires = Expires + Offset
            else
                aura_env.RTBContainerExpires = Expires
            end
        elseif spellId == aura_env.ids.KillingSpree and IsPlayerSpell(aura_env.ids.DisorientingStrikesTalent) then
            aura_env.DisorientingStrikesCount = 2
        elseif spellId == aura_env.ids.SinisterStrike or spellId == aura_env.ids.Ambush then
            aura_env.DisorientingStrikesCount = max(aura_env.DisorientingStrikesCount - 1, 0)
        elseif spellId == aura_env.ids.CoupDeGrace and GetTime() - aura_env.PrevCoupCast > 5 and WeakAuras.GetNumSetItemsEquipped(1928) and IsPlayerSpell(aura_env.ids.CoupDeGraceTalent) then
            aura_env.HasTww34PcTricksterBuff = true
        elseif spellId == aura_env.ids.CoupDeGrace then
            aura_env.HasTww34PcTricksterBuff = false
            aura_env.PrevCoupCast = GetTime()
        end
        
        if spellId == aura_env.ids.KillingSpree then
            aura_env.LastKillingSpree = GetTime()
        end
    end
end