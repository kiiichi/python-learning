----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

-- Death Strike Prediction
aura_env.DamageTaken = {} -- Table to store damage taken
aura_env.LastSec = 5 -- How long damage events are taken into account
aura_env.BasePercentage = 0.25 -- Percentage of the damage that is being healed
aura_env.MinHealPercentage = 0.07 -- Minimum percentage that Death Strike gives

-- Table to exclude certain abilities that deal damage but do not increase the healing done by DS
aura_env.exclude = {
    [243237] = true, --Bursting
}

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbominationLimb = 383269,
    BreathOfSindragosa = 1249658,
    ChainsOfIce = 45524,
    ChillStreak = 305392,
    DeathAndDecay = 43265,
    EmpowerRuneWeapon = 47568,
    FrostStrike = 49143,
    Frostscythe = 207230,
    FrostwyrmsFury = 279302,
    GlacialAdvance = 194913,
    HornOfWinter = 57330,
    HowlingBlast = 49184,
    Obliterate = 49020,
    PillarOfFrost = 51271,
    RaiseDead = 46585,
    ReapersMark = 439843,
    RemorselessWinter = 196770,
    SoulReaper = 343294,
    
    -- Talents
    AFeastOfSoulsTalent = 444072,
    ApocalypseNowTalent = 444040,
    ArcticAssaultTalent = 456230,
    AvalancheTalent = 207142,
    BindInDarknessTalent = 440031,
    BitingColdTalent = 377056,
    BonegrinderTalent = 377098,
    BreathOfSindragosaTalent = 1249658,
    CleavingStrikesTalent = 316916,
    ColdHeartTalent = 281208,
    DarkTalonsTalent = 436687,
    EmpowerRuneWeaponTalent = 47568,
    EnduringStrengthTalent = 377190,
    FrigidExecutionerTalent = 377073,
    FrostbaneTalent = 455993,
    FrostboundWillTalent = 1238680,
    FrostwyrmsFuryTalent = 279302,
    FrozenDominionTalent = 377226,
    GatheringStormTalent = 194912,
    GlacialAdvanceTalent = 194913,
    IcebreakerTalent = 392950,
    IcyOnslaughtTalent = 1230272,
    IcyTalonsTalent = 194878,
    ImprovedDeathStrikeTalent = 374277,
    KillingStreakTalent = 1230153,
    ObliterationTalent = 281238,
    RageOfTheFrozenChampionTalent = 377076,
    ReaperOfSoulsTalent = 440002,
    ReapersMarkTalent = 439843,
    RidersChampionTalent = 444005,
    ShatteredFrostTalent = 455993,
    ShatteringBladeTalent = 207057,
    SmotheringOffenseTalent = 435005,
    TheLongWinterTalent = 456240,
    UnholyGroundTalent = 374265,
    UnleashedFrenzyTalent = 376905,
    WitherAwayTalent = 441894,
    
    -- Buffs/Debuffs
    AFeastOfSoulsBuff = 440861,
    BonegrinderFrostBuff = 377103,
    BreathOfSindragosaBuff = 1249658,
    ColdHeartBuff = 281209,
    DeathAndDecayBuff = 188290,
    ExterminateBuff = 441416,
    ExterminatePainfulDeathBuff = 447954,
    FrostbaneBuff = 1229310,
    FrostFeverDebuff = 55095,
    GatheringStormBuff = 211805,
    IcyOnslaughtBuff = 1230273,
    IcyTalonsBuff = 194879,
    KillingMachineBuff = 51124,
    MograinesMightBuff = 444505,
    PillarOfFrostBuff = 51271,
    RazoriceDebuff = 51714,
    ReaperOfSoulsBuff = 469172,
    ReapersMarkDebuff = 434765,
    RemorselessWinterBuff = 196770,
    RimeBuff = 59052,
    UnholyStrengthBuff = 53365,
    UnleashedFrenzyBuff = 376907,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

aura_env.NGSend = function(Name, ExtraData)
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name, ExtraData)
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

aura_env.CalcDeathStrikeHeal = function()
    local i = 1
    local CurrentTime = GetTime()
    local TotalDamage = 0
    while aura_env.DamageTaken[i] do
        local EntryTime = aura_env.DamageTaken[i][1]
        local EntryDamage = aura_env.DamageTaken[i][2]
        
        -- Remove outdated entry or add damage
        if CurrentTime > EntryTime + aura_env.LastSec then
            table.remove(aura_env.DamageTaken, i)
        else
            TotalDamage = TotalDamage + EntryDamage
            i = i + 1
        end
    end
    
    local BasePercentage = aura_env.BasePercentage
    local MinHealPercentage = aura_env.MinHealPercentage
    
    if IsPlayerSpell(aura_env.ids.ImprovedDeathStrikeTalent) then 
        BasePercentage = BasePercentage * 1.05
        MinHealPercentage = MinHealPercentage * 1.05
    end
    
    --Versatility
    local Vers = 1 + ((GetCombatRatingBonus(29) + GetVersatilityBonus(30)) / 100)
    
    --Guardian Spirit
    local GS = 1 + (select(16, WA_GetUnitBuff("player", 47788)) or 0) / 100
    
    --Divine Hymn
    local DH = 1 + 0.04 * (select(3, WA_GetUnitBuff("player", 64844)) or 0)
    
    local TotalHeal = TotalDamage * BasePercentage
    local HealPercentage = TotalHeal / UnitHealthMax("player")
    HealPercentage = math.max(MinHealPercentage, HealPercentage)
    HealPercentage = HealPercentage * Vers * GS * DH
    
    TotalHeal = HealPercentage * UnitHealthMax("player")
    return TotalHeal
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1919)
    
    local CurrentRunes = 0
    local RuneCooldownDuration = select(2, GetRuneCooldown(1))
    local RuneCooldownStarts = {}
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            CurrentRunes = CurrentRunes + 1
        end
        table.insert(RuneCooldownStarts, start)
    end
    table.sort(RuneCooldownStarts)
    local TimeToXRunes = function(X)
        if RuneCooldownStarts[X] == 0 then return 0 end
        return RuneCooldownStarts[X] + RuneCooldownDuration - GetTime()
    end
    
    local CurrentRunicPower = UnitPower("player", Enum.PowerType.RunicPower)
    local MaxRunicPower = UnitPowerMax("player", Enum.PowerType.RunicPower)
    
    local NearbyRange = 10
    local NearbyEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    local Variables = {}
    
    Variables.TwoHandCheck = (select(9, C_Item.GetItemInfo(GetInventoryItemLink("player", 16))) == "INVTYPE_2HWEAPON")
    
    Variables.StPlanning = NearbyEnemies <= 1
    
    Variables.AddsRemain = NearbyEnemies >= 2
    
    Variables.SendingCds = ( Variables.StPlanning or Variables.AddsRemain )
    
    Variables.CooldownCheck = ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrostBuff) ) or not IsPlayerSpell(ids.PillarOfFrost) or FightRemains(60, NearbyRange) < 20

    Variables.FwfBuffs = (GetRemainingAuraDuration("player", ids.PillarOfFrost) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or (PlayerHasBuff(ids.UnholyStrengthBuff) and GetRemainingAuraDuration("player", ids.UnholyStrengthBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3) or (IsPlayerSpell(ids.BonegrinderTalent) and PlayerHasBuff(ids.BonegrinderFrostBuff) and GetRemainingAuraDuration("player", ids.BonegrinderFrostBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and (NearbyEnemies > 1 or GetTargetStacks(ids.RazoriceDebuff) == 5 or IsPlayerSpell(ids.ShatteringBladeTalent))

    Variables.RunePooling = IsPlayerSpell(ids.ReapersMarkTalent) and GetRemainingSpellCooldown(ids.ReapersMark) < 6 and CurrentRunes < 3 and Variables.SendingCds

    Variables.RpPooling = IsPlayerSpell(ids.BreathOfSindragosaTalent) and GetRemainingSpellCooldown(ids.BreathOfSindragosa) < 4 * WeakAuras.gcdDuration() and CurrentRunicPower < (60 + ( 35 + 5 * (PlayerHasBuff(ids.IcyOnslaughtBuff) and 1 or 0 ) - ( 10 * CurrentRunes )) ) and Variables.SendingCds 

    -- Frostscythe is equal at 3 targets, except with Rider 4pc which brings Obliterate higher at 3, unless cleaving strikes is up
    Variables.FrostscythePrio = 3 + ( ( (SetPieces >= 4 and IsPlayerSpell(ids.RidersChampionTalent)) and not ( IsPlayerSpell(ids.CleavingStrikesTalent) and PlayerHasBuff(ids.RemorselessWinterBuff) ) ) and 1 or 0 )

    Variables.BreathOfSindragosaCheck = IsPlayerSpell(ids.BreathOfSindragosaTalent) and (GetRemainingSpellCooldown(ids.BreathOfSindragosa) > 20 or ( OffCooldown(ids.BreathOfSindragosa) and CurrentRunicPower >= ( 60 - 20 * (IsPlayerSpell(ids.ReapersMarkTalent) and 1 or 0) ) ) )
    

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Empower Rune Weapon
    if OffCooldown(ids.EmpowerRuneWeapon) and ( CurrentRunes < 2 or not PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunicPower < 35 + ((IsPlayerSpell(ids.IcyOnslaughtTalent) and 1 or 0) * GetPlayerStacks(ids.IcyOnslaughtBuff) * 5 ) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    if OffCooldown(ids.EmpowerRuneWeapon) and ( GetTimeToFullCharges(ids.EmpowerRuneWeapon) <= 6 and GetPlayerStacks(ids.KillingMachineBuff) < 1 + (IsPlayerSpell(ids.KillingStreakTalent) and 1 or 0) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    -- Pillar of Frost
    if OffCooldown(ids.PillarOfFrost) and ( not IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) or FightRemains(60, NearbyRange) < 20 ) then
        ExtraGlows.PillarOfFrost = true end

    if OffCooldown(ids.PillarOfFrost) and ( IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and Variables.BreathOfSindragosaCheck and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) ) then
        ExtraGlows.PillarOfFrost = true end

    -- Breath of Sindragosa
    if OffCooldown(ids.BreathOfSindragosa) and ( not PlayerHasBuff(ids.BreathOfSindragosaBuff) and ( PlayerHasBuff(ids.PillarOfFrostBuff) or FightRemains(60, NearbyRange) < 20 ) ) then
        ExtraGlows.BreathOfSindragosa = true end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Action List
    local Aoe = function()
        if OffCooldown(ids.Frostscythe) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            NGSend("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) ) then
            NGSend("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) or not TargetHasDebuff(ids.FrostFeverDebuff) ) then
            NGSend("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and PlayerHasBuff(ids.FrostbaneBuff) ) then
            NGSend("Frost Strike") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and NearbyEnemies < 5 and not Variables.RpPooling and not IsPlayerSpell(ids.FrostbaneTalent) ) then
            NGSend("Frost Strike") return true end

        if OffCooldown(ids.Frostscythe) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling and NearbyEnemies >= Variables.FrostscythePrio ) then
            NGSend("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            NGSend("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            NGSend("Howling Blast") return true end

        if OffCooldown(ids.GlacialAdvance) and ( not Variables.RpPooling ) then
            NGSend("Glacial Advance") return true end

        if OffCooldown(ids.Frostscythe) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            NGSend("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            NGSend("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            NGSend("Howling Blast") return true end
    end
    
    -- Cooldowns
    local Cooldowns = function()
        if OffCooldown(ids.RemorselessWinter) and not IsPlayerSpell(ids.FrozenDominionTalent) and ( Variables.SendingCds and ( NearbyEnemies > 1 or IsPlayerSpell(ids.GatheringStormTalent ) or ( GetPlayerStacks(ids.GatheringStormBuff) == 10 and GetRemainingAuraDuration("player", ids.GatheringStormBuff) < WeakAuras.gcdDuration() * 2 ) ) and FightRemains(60, NearbyRange) > 10 ) then
            NGSend("Remorseless Winter") return true end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and not IsPlayerSpell(ids.BreathOfSindragosaTalent) ) then
            NGSend("Frostwyrms Fury") return true end
                    
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and IsPlayerSpell(ids.BreathOfSindragosaTalent) and CurrentRunicPower >= 60 ) then
            NGSend("Frostwyrms Fury") return true end

        if OffCooldown(ids.ReapersMark) and ( PlayerHasBuff(ids.PillarOfFrost) or GetRemainingSpellCooldown(ids.PillarOfFrost) > 5 or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Reapers Mark") return true end

        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies <= 1 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not IsPlayerSpell(ids.ObliterationTalent) or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs or FightRemains(10, NearbyRange) < 3 ) then
            NGSend("Frostwyrms Fury") return true end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies >= 2 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            NGSend("Frostwyrms Fury") return true end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and IsPlayerSpell(ids.ObliterationTalent) and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not Variables.TwoHandCheck or not PlayerHasBuff(ids.PillarOfFrost) and Variables.TwoHandCheck and GetRemainingSpellCooldown(ids.PillarOfFrost) > 0 or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            NGSend("Frostwyrms Fury") return true end
        
        if OffCooldown(ids.RaiseDead) then
            NGSend("Raise Dead") return true end
        
        if OffCooldown(ids.SoulReaper) and ( IsPlayerSpell(ids.ReaperOfSoulsTalent) and PlayerHasBuff(ids.ReaperOfSoulsBuff) and GetPlayerStacks(ids.KillingMachineBuff) < 2) then
            NGSend("Soul Reaper") return true end
    end
    
    -- Single Target Rotation
    local SingleTarget = function()
        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes <= 3 ) ) then
            NGSend("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) ) then
            NGSend("Howling Blast") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling ) then
            NGSend("Frost Strike") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            NGSend("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( not IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling and MaxRunicPower - CurrentRunicPower < 30 ) then
            NGSend("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            NGSend("Obliterate") return true end

        if OffCooldown(ids.FrostStrike) and ( not Variables.RpPooling ) then
            NGSend("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            NGSend("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            NGSend("Howling Blast") return true end
    end
    
    -- Choose Action list to run
    if Cooldowns() then return true end
    
    if NearbyEnemies >= 3 then
        Aoe() return true end
    
    if SingleTarget() then return true end
    
    NGSend("Clear")
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core2--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_DAMAGE, CLEU:RANGE_DAMAGE, CLEU:SWING_DAMAGE, CLEU:SPELL_PERIODIC_DAMAGE, CLEU:SPELL_BUILDING_DAMAGE, CLEU:SPELL_ABSORBED

-- Based on https://wago.io/NkaTBpcPW
-- Based on https://wago.io/NkaTBpcPW
function(event, ...)
    
    local timestamp, subevent = select(1, ...)
    
    -- PLAYER DAMAGE TAKEN FOR DEATH STRIKE
    if select(8, ...) == UnitGUID("player") then
        
        --set selection offset to amount for baseline SWING_DAMAGE
        local offset = 12
        
        --handle SPELL_ABSORBED events
        if subevent == "SPELL_ABSORBED" then
            
            -- If a spell gets absorbed instead of a melee hit, there are 3 additional parameters regarding which spell got absorbed, so move the offset 3 more places
            local spellid, spellname = select(offset, ...)
            if C_Spell.GetSpellInfo(spellid) and C_Spell.GetSpellInfo(spellid).name == spellname then
                --check for excluded spellids before moving the offset
                if aura_env.exclude[spellid] then
                    return
                end
                offset = offset + 3
            end
            
            -- Absorb value is 7 places further
            offset = offset + 7
            table.insert(aura_env.DamageTaken, {GetTime(), (select(offset, ...)), timestamp})
            
            -- Handle regular XYZ_DAMAGE events
        elseif subevent:find("_DAMAGE") then
            
            -- Don't include environmental damage (like falling etc)
            if not subevent:find("ENVIRONMENTAL") then
                
                -- Move offset by 3 places for spell info for RANGE_ and SPELL_ prefixes
                if subevent:find("SPELL") then
                    -- Check for excluded spellids before moving the offset
                    local spellid = select(offset, ...)
                    if aura_env.exclude[spellid] then
                        return
                    end
                    offset = offset + 3
                elseif subevent:find("RANGE") then
                    offset = offset + 3
                end
                
                -- Damage event
                table.insert(aura_env.DamageTaken, {GetTime(), (select(offset, ...)), timestamp})
                
            end
        end
    end
end


