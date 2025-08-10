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

aura_env.ArmyExpiration = 0
aura_env.GargoyleExpiration = 0
aura_env.ApocalypseExpiration = 0
aura_env.AbominationExpiration = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    Apocalypse = 275699,
    ArmyOfTheDead = 42650,
    DarkArbiter = 207349,
    DarkTransformation = 63560,
    DeathAndDecay = 43265,
    DeathCoil = 47541,
    Defile = 152280,
    Desecrate = 1234698,
    Epidemic = 207317,
    FesteringStrike = 85948,
    FesteringScythe = 458128,
    LegionOfSouls = 383269,
    Outbreak = 77575, 
    RaiseAbomination = 455395,
    RaiseDead = 46584,
    ScourgeStrike = 55090,
    SoulReaper = 343294,
    SummonGargoyle = 49206,
    UnholyAssault = 207289,
    VampiricStrike = 433895,
    
    -- Talents
    ApocalypseTalent = 275699,
    BurstingSoresTalent = 207264,
    CoilOfDevastationTalent = 390270,
    CommanderOfTheDeadTalent = 390259,
    DesecrateTalent = 1234559,
    DoomedBiddingTalent = 455386,
    EbonFeverTalent = 207269,
    FesteringScytheTalent = 455397,
    FestermightTalent = 377590,
    FrenziedBloodthirstTalent = 434075,
    GiftOfTheSanlaynTalent = 434152,
    HarbingerOfDoomTalent = 276023,
    HungeringThirstTalent = 444037,
    ImprovedDeathCoilTalent = 377580,
    ImprovedDeathStrikeTalent = 374277,
    MenacingMagusTalent = 455135,
    MorbidityTalent = 377592,
    PestilenceTalent = 277234,
    PlaguebringerTalent = 390175,
    RaiseAbominationTalent = 455395,
    RottenTouchTalent = 390275,
    SuperstrainTalent = 390283,
    UnholyBlightTalent = 460448,
    UnholyGroundTalent = 374265,
    VampiricStrikeTalent = 433901,
    
    -- Buffs/Debuffs
    AFeastOfSoulsBuff = 440861,
    BloodPlagueDebuff = 55078,
    ChainsOfIceTrollbaneSlowDebuff = 444826,
    CommanderOfTheDeadBuff = 390260,
    DarkTransformationBuff = 63560,
    DeathAndDecayBuff = 188290,
    DeathRotDebuff = 377540,
    EssenceOfTheBloodQueenBuff = 433925,
    FesteringScytheBuff = 458123,
    FesteringScytheStacksBuff = 459238,
    FesteringWoundDebuff = 194310,
    FestermightBuff = 377591,
    FrostFeverDebuff = 55095,
    GiftOfTheSanlaynBuff = 434153,
    InflictionOfSorrowBuff = 460049,
    LegionOfSoulsBuff = 383269,
    RottenTouchDebuff = 390276,
    RunicCorruptionBuff = 51460,
    SuddenDoomBuff = 81340,
    VirulentPlagueDebuff = 191587,
    VisceralStrengthUnholyBuff = 1234532,
    WinningStreakBuff = 1216813,
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

aura_env.IsAuraRefreshable = function(SpellID, Unit)
    local Filter = ""
    if Unit ~= "player" then 
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

aura_env.HasBloodlust = function()
    return (WA_GetUnitBuff("player", 2825) or WA_GetUnitBuff("player", 264667) or WA_GetUnitBuff("player", 80353) or WA_GetUnitBuff("player", 32182) or WA_GetUnitBuff("player", 390386) or WA_GetUnitBuff("player", 386540))
end

aura_env.PlayerHasBuff = function(spellID)
    return WA_GetUnitBuff("player", spellID) ~= nil
end

aura_env.TargetHasDebuff = function(spellID)
    return WA_GetUnitDebuff("target", spellID, "PLAYER|HARMFUL") ~= nil
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
    if IsPlayerSpell(ids.Defile) then ids.DeathAndDecay = ids.Defile end
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1919)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1867)
    
    local CurrentRunes = 0
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            CurrentRunes = CurrentRunes + 1
        end
    end
    
    local CurrentRunicPower = UnitPower("player", Enum.PowerType.RunicPower)
    local MaxRunicPower = UnitPowerMax("player", Enum.PowerType.RunicPower)
    
    local GargoyleRemaining = max(aura_env.GargoyleExpiration - GetTime(), 0)
    local ApocalypseRemaining = max(aura_env.ApocalypseExpiration - GetTime(), 0)
    local ArmyRemaining = max(aura_env.ArmyExpiration - GetTime(), 0)
    local AbominationRemaining = max(aura_env.AbominationExpiration - GetTime(), 0)
    
    local TargetsWithFesteringWounds = 0
    local NearbyEnemies = 0
    local NearbyRange = 10
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.FesteringWoundDebuff, "PLAYER||HARMFUL") ~= nil then
                TargetsWithFesteringWounds = TargetsWithFesteringWounds + 1
            end
        end
    end
    
    WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    if NearbyEnemies <= 1 then
    Variables.StPlanning = true else Variables.StPlanning = false end
    
    if NearbyEnemies >= 2 then
    Variables.AddsRemain = true else Variables.AddsRemain = false end
    
    if GetRemainingSpellCooldown(ids.Apocalypse) < 5 and GetTargetStacks(ids.FesteringWoundDebuff) < 4 and GetRemainingSpellCooldown(ids.UnholyAssault) > 5 then
    Variables.ApocTiming = 5 else Variables.ApocTiming = 2 end
    
    if GetRemainingSpellCooldown(ids.SummonGargoyle) > 5 and CurrentRunicPower < 40 then
    Variables.PoolingRunicPower = true else Variables.PoolingRunicPower = false end
    
    if ( GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming or not IsPlayerSpell(ids.Apocalypse) ) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and GetRemainingSpellCooldown(ids.UnholyAssault) < 20 and IsPlayerSpell(ids.UnholyAssault) and Variables.StPlanning or TargetHasDebuff(ids.RottenTouchDebuff) and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or GetTargetStacks(ids.FesteringWoundDebuff) >= 4 - (AbominationRemaining > 0 and 1 or 0) ) or FightRemains(10, NearbyRange) < 5 and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 then
    Variables.PopWounds = true else Variables.PopWounds = false end
    
    if ( not IsPlayerSpell(ids.RottenTouchTalent) or IsPlayerSpell(ids.RottenTouchTalent) and not TargetHasDebuff(ids.RottenTouchDebuff) or MaxRunicPower - CurrentRunicPower < 20 ) and ( ( IsPlayerSpell(ids.ImprovedDeathCoilTalent) and ( NearbyEnemies == 2 or IsPlayerSpell(ids.CoilOfDevastationTalent) ) or CurrentRunes < 3 or GargoyleRemaining or PlayerHasBuff(ids.SuddenDoomBuff) or not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) >= 4 ) ) then
    Variables.SpendRp = true else Variables.SpendRp = false end
    
    Variables.SanCoilMult = (GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) >= 4 and 2 or 1)
    
    Variables.EpidemicTargets = 3 + (IsPlayerSpell(ids.ImprovedDeathCoilTalent) and 1 or 0) + ((IsPlayerSpell(ids.FrenziedBloodthirstTalent) and 1 or 0) * Variables.SanCoilMult) + ((IsPlayerSpell(ids.HungeringThirstTalent) and IsPlayerSpell(ids.HarbingerOfDoomTalent) and PlayerHasBuff(ids.SuddenDoomBuff)) and 1 or 0)
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.ArmyOfTheDead) and not IsPlayerSpell(ids.RaiseAbomination) and not IsPlayerSpell(ids.LegionOfSouls) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( IsPlayerSpell(ids.CommanderOfTheDeadTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 or not IsPlayerSpell(ids.CommanderOfTheDeadTalent) and NearbyEnemies >= 1 ) or FightRemains(30, NearbyRange) < 35 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( not IsPlayerSpell(ids.VampiricStrikeTalent) or ( ApocalypseRemaining > 0 or not IsPlayerSpell(ids.ApocalypseTalent))) or FightRemains(25, NearbyRange) < 30 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.SummonGargoyle) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( PlayerHasBuff(ids.CommanderOfTheDeadBuff) or not IsPlayerSpell(ids.CommanderOfTheDeadTalent) and NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 25 ) then
        ExtraGlows.SummonGargoyle = true
    end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE
    local Aoe = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( CurrentRunes < 4 and NearbyEnemies < Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( CurrentRunes < 4 and NearbyEnemies > Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.BurstingSoresTalent) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming or PlayerHasBuff(ids.FesteringScytheBuff) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 2 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 and GetRemainingSpellCooldown(ids.Apocalypse) > WeakAuras.gcdDuration() or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and TargetHasDebuff(ids.VirulentPlagueDebuff) ) then
            NGSend("Scourge Strike") return true end
    end
    
    -- AoE Burst
    local AoeBurst = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            NGSend("Festering Strike") return true end

        if OffCooldown(ids.DeathAndDecay) and FindSpellOverrideByID(ids.DeathAndDecay) ~= ids.Desecrate and ( TargetsWithFesteringWounds == NearbyEnemies and IsPlayerSpell(ids.DesecrateTalent) and ( IsPlayerSpell(ids.FesteringScytheTalent) and TargetsWithFesteringWounds == 0 and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 and not PlayerHasBuff(ids.FesteringScytheBuff) or not IsPlayerSpell(ids.FesteringScytheTalent))) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and NearbyEnemies < Variables.EpidemicTargets and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and PlayerHasBuff(ids.SuddenDoomBuff) and TargetsWithFesteringWounds < NearbyEnemies * 0.4 or PlayerHasBuff(ids.SuddenDoomBuff) and ( IsPlayerSpell(ids.DoomedBiddingTalent) and IsPlayerSpell(ids.MenacingMagusTalent) or IsPlayerSpell(ids.RottenTouchTalent) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() ) or CurrentRunes < 2 ) or
            ( CurrentRunes < 4 or NearbyEnemies < 4 and NearbyEnemies < Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and ( not IsPlayerSpell(ids.BurstingSoresTalent) or IsPlayerSpell(ids.BurstingSoresTalent) and PlayerHasBuff(ids.SuddenDoomBuff) and TargetsWithFesteringWounds < NearbyEnemies * 0.4 or PlayerHasBuff(ids.SuddenDoomBuff) and ( PlayerHasBuff(ids.AFeastOfSoulsBuff) or GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRotDebuff) < 10 ) or CurrentRunes < 2 ) or ( CurrentRunes < 4 and NearbyEnemies >= Variables.EpidemicTargets and PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and WeakAuras.gcdDuration() <= 1.0 and ( FightRemains(60, NearbyRange) > GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) * 2 ) ) ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike or PlayerHasBuff(ids.DeathAndDecayBuff) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( Variables.EpidemicTargets <= NearbyEnemies ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) <= 2 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) then
            NGSend("Scourge Strike") return true end
    end
    
    -- AoE Setup
    local AoeSetup = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff)) then
            NGSend("Festering Strike") return true end

        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( TargetsWithFesteringWounds == NearbyEnemies and ( CurrentRunes > 3 or CurrentRunicPower < 30 ) or IsPlayerSpell(ids.DesecrateTalent) and ( IsPlayerSpell(ids.FesteringScytheTalent) and TargetsWithFesteringWounds == 0 and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 and not PlayerHasBuff(ids.FesteringScytheBuff) or not IsPlayerSpell(ids.FesteringScytheTalent) ) ) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( TargetsWithFesteringWounds == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() and ( (GetRemainingSpellCooldown(ids.DarkTransformation) > 0 or IsPlayerSpell(ids.Apocalypse) ) and GetRemainingSpellCooldown(ids.UnholyAssault) > 0 or GetRemainingSpellCooldown(ids.UnholyAssault) > 0 or not IsPlayerSpell(ids.UnholyAssault) ) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoomBuff) and NearbyEnemies < Variables.EpidemicTargets and CurrentRunes < 4 ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and Variables.EpidemicTargets <= NearbyEnemies and CurrentRunes < 4 ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( not IsPlayerSpell(ids.BurstingSoresTalent) or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds >= 8 or not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.Defile) and CurrentRunes > 3 ) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets and ( PlayerHasBuff(ids.SuddenDoomBuff) or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds >= 8 ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and Variables.EpidemicTargets <= NearbyEnemies and ( PlayerHasBuff(ids.SuddenDoomBuff) or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds >= 8 ) ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( TargetsWithFesteringWounds < 8 and not TargetsWithFesteringWounds == NearbyEnemies ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike  ) then
            NGSend("Scourge Strike") return true end
    end
    
    -- Non-Sanlayn CDs
    local Cds = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() * 2 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 2 and WA_GetUnitBuff("pet", ids.DarkTransformationBuff) ) or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.SuperstrainTalent) and ( IsAuraRefreshable(ids.FrostFeverDebuff) or IsAuraRefreshable(ids.BloodPlagueDebuff) ) ) and ( not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.PlaguebringerTalent)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) * 3 ) ) then
            NGSend("Outbreak") return true end
    end
    
    -- Non-Sanlayn CDs AoE
    local CdsAoe = function()
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain ) then
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 ) ) then
            NGSend("Dark Transformation") return true end

        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or CurrentRunes < 3 or ( SetPieces >= 2 and not IsPlayerSpell(ids.VampiricStrikeTalent))) ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlagueDebuff) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
            NGSend("Outbreak") return true end
    end
    
    -- Sanlayn CDs AoE
    local CdsAoeSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 ) ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and PlayerHasBuff(ids.DarkTransformationBuff) and GetRemainingAuraDuration("player", ids.DarkTransformationBuff) < 12 ) then
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 or CurrentRunes < 3 ) ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.Outbreak) and ( ( ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 or OldSetPieces >= 4 and IsPlayerSpell(ids.SuperstrainTalent) and floor(GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) / 1.5) < 5 and AbominationRemaining <= 0 ) and ( IsPlayerSpell(ids.UnholyBlightTalent) and not (not IsPlayerSpell(ids.Apocalypse) and OffCooldown(ids.DarkTransformation)) or not IsPlayerSpell(ids.UnholyBlightTalent) ) and IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( not TargetHasDebuff(ids.VirulentPlagueDebuff) and Variables.EpidemicTargets < NearbyEnemies or ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 5 ) ) or PlayerHasBuff(ids.VisceralStrengthUnholyBuff) ) then
            NGSend("Outbreak") return true end
    end
    
    -- Sanlayn CDs Cleave
    local CdsCleaveSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.Apocalypse) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( WA_GetUnitBuff("pet", ids.DarkTransformationBuff) and GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) < 12 or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5 < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbominationTalent) or IsPlayerSpell(ids.RaiseAbominationTalent) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) or PlayerHasBuff(ids.VisceralStrengthUnholyBuff) ) then
            NGSend("Outbreak") return true end
    end
    
    -- Sanlayn CDs ST
    local CdsSan = function()
        if OffCooldown(ids.DarkTransformation) and not IsPlayerSpell(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Dark Transformation") return true end

        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( WA_GetUnitBuff("pet", ids.DarkTransformationBuff) and GetRemainingAuraDuration("pet", ids.DarkTransformationBuff) < 12 ) or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Unholy Assault") return true end

        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlagueDebuff) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlagueDebuff) or IsPlayerSpell(ids.MorbidityTalent) and PlayerHasBuff(ids.InflictionOfSorrowBuff) and IsPlayerSpell(ids.SuperstrainTalent) and IsAuraRefreshable(ids.FrostFeverDebuff) and IsAuraRefreshable(ids.BloodPlagueDebuff) ) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) or PlayerHasBuff(ids.VisceralStrengthUnholyBuff) ) then
            NGSend("Outbreak") return true end

        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) and floor(GetRemainingDebuffDuration("target", ids.FrostFeverDebuff) / 1.5) < 5 and IsPlayerSpell(ids.SuperstrainTalent) and (OldSetPieces >= 4) and IsAuraRefreshable(ids.FrostFeverDebuff) and ( IsPlayerSpell(ids.Apocalypse) or not IsPlayerSpell(ids.UnholyBlightTalent) or IsPlayerSpell(ids.UnholyBlightTalent) and GetRemainingSpellCooldown(ids.DarkTransformation) > 6 ) and ( not IsPlayerSpell(ids.RaiseAbominationTalent) or IsPlayerSpell(ids.RaiseAbominationTalent) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 6 ) ) then
            NGSend("Outbreak") return true end
    end

    -- Shared CDs
    local CdsShared = function()
        if IsPlayerSpell(ids.LegionOfSouls) and GetRemainingSpellCooldown(ids.LegionOfSouls) == 0 and ( (Variables.StPlanning or Variables.AddsRemain) and (TargetsWithFesteringWounds < NearbyEnemies or ( IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.Apocalypse) < 3 or not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) < 3 ))) then
            NGSend("Legion of Souls") return true end

        if FindSpellOverrideByID(ids.DeathAndDecay) == ids.Desecrate and ( NearbyEnemies >= 2 and ( not IsPlayerSpell(ids.FesteringScytheTalent) or GetPlayerStacks(ids.FesteringScytheStacksBuff) < NearbyEnemies and not PlayerHasBuff(ids.FesteringScytheBuff) ) and ( NearbyEnemies > 1 and TargetsWithFesteringWounds < NearbyEnemies or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds == 0 and IsPlayerSpell(ids.FesteringScytheTalent) and not PlayerHasBuff(ids.FesteringScytheBuff) and GetPlayerStacks(ids.FesteringScytheStacksBuff) < 10 ) ) then
            NGSend("Desecrate") return true end
    end
    
    -- Cleave
    local Cleave = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and Variables.AddsRemain or IsPlayerSpell(ids.GiftOfTheSanlaynTalent) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and IsPlayerSpell(ids.ImprovedDeathCoilTalent) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and not IsPlayerSpell(ids.ImprovedDeathCoilTalent) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) < 2 or PlayerHasBuff(ids.FesteringScytheBuff) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming and GetTargetStacks(ids.FesteringWoundDebuff) < 1 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            NGSend("Scourge Strike") return true end
        
    end
    
    -- San'layn Fishing
    local SanFishing = function()
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.InflictionOfSorrowBuff) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoomBuff) and IsPlayerSpell(ids.DoomedBiddingTalent) or OldSetPieces >= 4 and GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( GetTargetStacks(ids.FesteringWoundDebuff) >= 3 - (AbominationRemaining > 0 and 1 or 0) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 3 - (AbominationRemaining > 0 and 1 or 0) ) then
            NGSend("Festering Strike") return true end
    end
    
    -- San'layn Single Target
    local SanSt = function()
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.InflictionOfSorrowBuff) ) then
            NGSend("Scourge Strike") return true end

        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScytheBuff) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoomBuff) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlaynBuff) and ( IsPlayerSpell(ids.DoomedBiddingTalent) or IsPlayerSpell(ids.RottenTouchTalent) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruptionBuff) or OldSetPieces >= 4 and CurrentRunicPower > 80 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetPlayerStacks(ids.EssenceOfTheBloodQueenBuff) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and OldSetPieces >= 4 and GetPlayerStacks(ids.WinningStreakBuff) == 10 and CurrentRunes <= 3 and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueenBuff) > 3 ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and PlayerHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("player", ids.DarkTransformation) < WeakAuras.gcdDuration() ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( ( GetTargetStacks(ids.FesteringWoundDebuff) == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming ) or not PlayerHasBuff(ids.DarkTransformationBuff) and not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) < 10 and GetTargetStacks(ids.FesteringWoundDebuff) <= 3 and ( CurrentRunes > 4 or CurrentRunicPower < 80 ) or ( IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or not IsPlayerSpell(ids.GiftOfTheSanlaynTalent) ) and GetTargetStacks(ids.FesteringWoundDebuff) <= 1 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( not IsPlayerSpell(ids.ApocalypseTalent) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and ( not IsPlayerSpell(ids.Apocalypse) and GetRemainingSpellCooldown(ids.DarkTransformation) > 5 and GetTargetStacks(ids.FesteringWoundDebuff) >= 3 - (AbominationRemaining > 0 and 1 or 0) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and GetRemainingDebuffDuration("target", ids.DeathRotDebuff) < WeakAuras.gcdDuration() or ( PlayerHasBuff(ids.SuddenDoomBuff) and GetTargetStacks(ids.FesteringWoundDebuff) >= 1 or CurrentRunes < 2 ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) > 4 ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            NGSend("Death Coil") return true end

        if OffCooldown(ids.FesteringStrike) and ( ( not IsPlayerSpell(ids.ApocalypseTalent) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and CurrentRunes >= 4 ) then
            NGSend("Festering Strike") return true end
    end
    
    -- Non-San'layn Single Target
    local St = function()
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and (TargetHasDebuff(ids.ChainsOfIceTrollbaneSlowDebuff)) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and Variables.SpendRp or FightRemains(60, NearbyRange) < 10 ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWoundDebuff) < 4 and (not Variables.PopWounds or PlayerHasBuff(ids.FesteringScytheBuff))) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWoundDebuff) >= 4 ) then
            NGSend("Scourge Strike") return true end
    end
    
    if CdsShared() then return true end

    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 3 then
        if CdsAoeSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        if CdsAoe() then return true end end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 2 then
        if CdsCleaveSan() then return true end end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies <= 1 then
        if CdsSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies <= 1 then
        if Cds() then return true end end
    
    if NearbyEnemies == 2 then
        if Cleave() then return true end end
    
    if NearbyEnemies >= 3 and GetRemainingSpellCooldown(ids.DeathAndDecay) < 7 and not PlayerHasBuff(ids.LegionOfSoulsBuff) and ( GetRemainingAuraDuration("player", ids.DeathAndDecayBuff) < 3 or TargetsWithFesteringWounds < (NearbyEnemies/2) ) then
        if AoeSetup() then return true end end
    
    if NearbyEnemies >= 3 and ( PlayerHasBuff(ids.DeathAndDecayBuff) or PlayerHasBuff(ids.DeathAndDecayBuff) and (TargetsWithFesteringWounds >= ( NearbyEnemies * 0.5 ) or IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies < 16 or IsPlayerSpell(ids.DesecrateTalent) and TargetsWithFesteringWounds == NearbyEnemies and IsPlayerSpell(ids.BurstingSoresTalent)) ) then
        if AoeBurst() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) then
        if Aoe() then return true end end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.GiftOfTheSanlaynTalent) and not OffCooldown(ids.DarkTransformation) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and not IsPlayerSpell(ids.Apocalypse) and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueenBuff) < GetRemainingSpellCooldown(ids.DarkTransformation) + 3 then
        SanFishing() return true end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.VampiricStrikeTalent) then
        if SanSt() then return true end end
    
    if NearbyEnemies <= 1 and not IsPlayerSpell(ids.VampiricStrikeTalent) then
        if St() then return true end end
    
    NGSend("Clear")
end


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Trigger2----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_DAMAGE, CLEU:RANGE_DAMAGE, CLEU:SWING_DAMAGE, CLEU:SPELL_PERIODIC_DAMAGE, CLEU:SPELL_BUILDING_DAMAGE, CLEU:SPELL_ABSORBED

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



----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Trigger3----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_CAST_SUCCESS

function( _,_,_,_,sourceGUID,_,_,_,_,_,_,_,spellID,_,_,_,_)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if spellID == aura_env.ids.ArmyOfTheDead then
        aura_env.ArmyExpiration = GetTime() + 30
    elseif spellID == aura_env.ids.SummonGargoyle or spellID == aura_env.ids.DarkArbiter then
        aura_env.GargoyleExpiration = GetTime() + 25
    elseif spellID == aura_env.ids.Apocalypse then
        aura_env.ApocalypseExpiration = GetTime() + 20
    elseif spellID == aura_env.ids.RaiseAbomination then
        aura_env.AbominationExpiration = GetTime() + 30
    end
end