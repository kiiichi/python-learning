----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.PrevArcaneBlast = 0
aura_env.UsedOrb = false
aura_env.UsedMissiles = false
aura_env.UsedBarrage = false
aura_env.NeedArcaneBlastSpark = false

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneBarrage = 44425,
    ArcaneBlast = 30451,
    ArcaneExplosion = 1449,
    ArcaneMissiles = 5143,
    ArcaneOrb = 153626,
    ArcaneSurge = 365350,
    Evocation = 12051,
    PresenceOfMind = 205025,
    ShiftingPower = 382440,
    Supernova = 157980,
    TouchOfTheMagi = 321507,
    
    -- Talents
    ArcaneBombardmentTalent = 384581,
    ArcaneHarmonyTalent = 384452,
    ArcaneTempoTalent = 383980,
    ArcingCleaveTalent = 231564,
    ChargedOrbTalent = 384651,
    ConsortiumsBaubleTalent = 461260,
    EnlightenedTalent = 321387,
    HighVoltageTalent = 461248,
    ImpetusTalent = 383676,
    LeydrinkerTalent = 452196,
    MagisSparkTalent = 454016,
    OrbBarrageTalent = 384858,
    ResonanceTalent = 205028,
    ReverberateTalent = 281482,
    ShiftingShardsTalent = 444675,
    SpellfireSpheresTalent = 448601,
    SplinteringSorceryTalent = 443739,
    TimeLoopTalent = 452924,
    
    -- Buffs
    AetherAttunementBuff = 453601,
    AethervisionBuff = 467634,
    ArcaneHarmonyBuff = 384455,
    ArcaneSoulBuff = 451038,
    ArcaneSurgeBuff = 365362,
    ArcaneTempoBuff = 383997,
    BurdenOfPowerBuff = 451049,
    ClearcastingBuff = 263725,
    GloriousIncandescenceBuff = 451073,
    IntuitionBuff = 449394,
    LeydrinkerBuff = 453758,
    NetherPrecisionBuff = 383783,
    SiphonStormBuff = 384267,
    SpellfireSpheresBuff = 448604,
    TouchOfTheMagiDebuff = 210824,
    UnerringProficiencyBuff = 444981,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

aura_env.NGSend = function(Name, ...)
    aura_env.Sent = true
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", Name, ...)
    WeakAuras.ScanEvents("NG_OUT_OF_RANGE", aura_env.OutOfRange)
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not C_SpellBook.IsSpellKnown(spellID) then return false end
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
    local IsSpellKnown = C_SpellBook.IsSpellKnown
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    local GcdMax = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
    
    ---- Setup Data -----------------------------------------------------------------------------------------------   
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1924)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1872)
    
    local CurrentArcaneCharges = UnitPower("player", Enum.PowerType.ArcaneCharges)
    local MaxArcaneCharges = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    local CurrentMana = UnitPower("player", Enum.PowerType.Mana)
    local MaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    local NetherPrecisionStacks = GetPlayerStacks(ids.NetherPrecisionBuff)
    
    local CurrentCast = select(9, UnitCastingInfo("player"))
    if CurrentCast ~= nil then
        if CurrentCast == ids.ArcaneBlast then
            CurrentArcaneCharges = min(4, CurrentArcaneCharges+1)
            NetherPrecisionStacks = max(0, NetherPrecisionStacks - 1)
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
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
        
    ---- Variables -------------------------------------------------------------------------------------------
    
    Variables.SoulBurst = false
    if SetPieces >= 4 and IsSpellKnown(ids.SpellfireSpheresTalent) and IsSpellKnown(ids.ResonanceTalent) and not IsSpellKnown(ids.MagisSparkTalent) and ( NearbyEnemies >= 3 ) and Variables.SoulBurst then
        Variables.SoulCd = true
    else
        Variables.SoulCd = false
    end

    Variables.AoeTargetCount = 2
    
    if not IsSpellKnown(ids.ArcingCleaveTalent) then
    Variables.AoeTargetCount = 9 end
    
    if not TargetHasDebuff(ids.TouchOfTheMagiDebuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) == 0 then
        Variables.Opener = true 
    else 
        aura_env.UsedOrb = false
        aura_env.UsedMissiles = false
        aura_env.UsedBarrage = false
        Variables.Opener = false
    end
    
    Variables.AoeList = aura_env.config["AoeList"]

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)

    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local CdOpener = function()
        -- Touch of the Magi used if you just used Arcane Surge, the wait simulates the time it takes to queue another spell after Touch when you Surge into Touch, otherwise we'll Touch off cooldown either after Barrage or if we just need Charges.
        if OffCooldown(ids.TouchOfTheMagi) and ( aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge) or ( GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 and OffCooldown(ids.TouchOfTheMagi) and ( ( CurrentArcaneCharges < 4 and not (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage) ) ) or (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage) ) ) ) or FightRemains(60, NearbyRange) < 15 ) then
            NGSend("Touch of the Magi") return true end
        
        if OffCooldown(ids.ArcaneBlast) and ( PlayerHasBuff(ids.PresenceOfMind) ) then
            NGSend("Arcane Blast") return true end
        
        -- Use Orb for Charges on the opener if you have High Voltage as the Missiles will generate the remaining Charge you need
        if OffCooldown(ids.ArcaneOrb) and ( IsSpellKnown(ids.HighVoltageTalent) and Variables.Opener and not aura_env.UsedOrb ) then
            NGSend("Arcane Orb") return true end
        
        -- Barrage before Evocation if Tempo will expire
        if OffCooldown(ids.ArcaneBarrage) and Variables.Opener and not aura_env.UsedBarrage and ( PlayerHasBuff(ids.ArcaneTempoBuff) and OffCooldown(ids.Evocation) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < GcdMax * 5 ) then
            NGSend("Arcane Barrage") return true end
        
        if OffCooldown(ids.Evocation) and ( GetRemainingSpellCooldown(ids.ArcaneSurge) < (GcdMax * 3) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 5 or FightRemains(60, NearbyRange) < 25 ) then
            NGSend("Evocation") return true end
        
        -- Use Missiles to get Nether Precision up for your burst window, clipping logic applies as long as you don't have Aether Attunement.
        if OffCooldown(ids.ArcaneMissiles) and not aura_env.UsedMissiles and ( ((aura_env.PrevCast == ids.Evocation or IsCasting(ids.Evocation)) or (aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge)) or Variables.Opener ) and NetherPrecisionStacks == 0 ) then
            NGSend("Arcane Missiles") return true end
        
        if OffCooldownNotCasting(ids.ArcaneSurge) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < ( max(C_Spell.GetSpellInfo(ids.ArcaneSurge).castTime/1000, WeakAuras.gcdDuration()) + ( GcdMax * ( (CurrentArcaneCharges == 4) and 1 or 0 ) ) ) or FightRemains(60, NearbyRange) < 25 ) then
            NGSend("Arcane Surge") return true end
    end

    -- Alternate tier set opener for AOE. Surge, then Evocate 5-7s later, then Touch when Surge has a few seconds remaining.
    -- Not added by NG because it's not enabled in the APL by default and I'm lazy.
    -- local CdOpenerSoul = function()
    --actions.cd_opener_soul=arcane_surge,if=(cooldown.touch_of_the_magi.remains<15)
    --actions.cd_opener_soul+=/evocation,if=buff.arcane_surge.up&(buff.arcane_surge.remains<=8.5|((buff.glorious_incandescence.up|buff.intuition.react)&buff.arcane_surge.remains<=10))
    --actions.cd_opener_soul+=/touch_of_the_magi,if=(buff.arcane_surge.remains<=2.5&prev_gcd.1.arcane_barrage)|(cooldown.evocation.remains>40&cooldown.evocation.remains<60&prev_gcd.1.arcane_barrage)
    -- end
    
    local Spellslinger = function()
        -- With Shifting Shards we can use Shifting Power whenever basically favoring cooldowns slightly, without it though we want to use it outside of cooldowns, don't cast if it'll conflict with Intuition expiration.
        if OffCooldown(ids.ShiftingPower) and ( ( ( ( ( ( C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges == 0 ) and GetRemainingSpellCooldown(ids.ArcaneOrb) > 16 ) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 20 ) and PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > ( 12 + 6 * GcdMax ) ) or 
                ( (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) and IsSpellKnown(ids.ShiftingShardsTalent) and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and ( PlayerHasBuff(ids.ArcaneSurgeBuff) or TargetHasDebuff(ids.TouchOfTheMagiDebuff) or GetRemainingSpellCooldown(ids.Evocation) < 20 ) ) ) and 
            FightRemains(60, NearbyRange) > 10 and ( GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) > GcdMax * 2.5 or PlayerHasBuff(ids.ArcaneTempoBuff) == false ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.Supernova) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) <= GcdMax and GetPlayerStacks(ids.UnerringProficiencyBuff) == 30 ) then
            NGSend("Supernova") return true end
        
        -- Orb if you need charges.
        if OffCooldown(ids.ArcaneOrb) and ( CurrentArcaneCharges < 4 ) then
            NGSend("Arcane Orb") return true end
        
        -- Barrage if Tempo is about to expire.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) <= GcdMax * 2 ) then
            NGSend("Arcane Barrage") return true end
        
        -- Use Aether Attunement up before casting Touch if you have S2 4pc equipped to avoid munching.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 3 and PlayerHasBuff(ids.ClearcastingBuff) and (OldSetPieces >= 4) ) then
            NGSend("Arcane Missiles") return true end
        
        -- Barrage if Touch is up or will be up while Barrage is in the air.
        if OffCooldown(ids.ArcaneBarrage) and ( ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.050 ), GcdMax ) ) and ( GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 and GetRemainingSpellCooldown(ids.ArcaneSurge) < 75 ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Anticipate the Intuition granted from the Season 3 set bonus.
        if OffCooldown(ids.ArcaneBarrage) and ( CurrentArcaneCharges == 4 and GetPlayerStacks(ids.ArcaneHarmonyBuff) >= 20 and SetPieces >= 4 ) then
            NGSend("Arcane Barrage") return true end
        
        -- Use Clearcasting procs to keep Nether Precision up, if you don't have S2 4pc try to pool Aether Attunement for cooldown windows.
        if OffCooldown(ids.ArcaneMissiles) and ( ( PlayerHasBuff(ids.ClearcastingBuff) and (NetherPrecisionStacks == 0) and ( ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 7 and GetRemainingSpellCooldown(ids.ArcaneSurge) > GcdMax * 7 ) or GetPlayerStacks(ids.ClearcastingBuff) > 1 or not IsSpellKnown(ids.MagisSparkTalent) or ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 4 and GetPlayerStacks(ids.AetherAttunementBuff) == 0 ) or (OldSetPieces >= 4) ) ) or ( FightRemains(60, NearbyRange) < 5 and PlayerHasBuff(ids.ClearcastingBuff) ) ) then
            NGSend("Arcane Missiles") return true end
        
        -- Missile to refill charges if you have High Voltage and either Aether Attunement or more than one Clearcasting proc. Recheck AOE
        if OffCooldown(ids.ArcaneMissiles) and ( IsSpellKnown(ids.HighVoltageTalent) and ( GetPlayerStacks(ids.ClearcastingBuff) > 1 or ( PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) ) ) and CurrentArcaneCharges < 3 ) then
            NGSend("Arcane Missiles") return true end
        
        -- Use Intuition.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.IntuitionBuff) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Make sure to always activate Spark!
        if OffCooldown(ids.ArcaneBlast) and ( aura_env.NeedArcaneBlastSpark or PlayerHasBuff(ids.LeydrinkerBuff) ) then
            NGSend("Arcane Blast") return true end

        -- In single target, spending your Nether Precision stacks on Blast is a higher priority in single target.
        if OffCooldown(ids.ArcaneBlast) and ( (NetherPrecisionStacks > 0) and GetPlayerStacks(ids.ArcaneHarmonyBuff) <= 16 and CurrentArcaneCharges == 4 and NearbyEnemies == 1 ) then
            NGSend("Arcane Blast") return true end

        -- Barrage if you're going to run out of mana and have Orb ready.
        if OffCooldown(ids.ArcaneBarrage) and ( (CurrentMana/MaxMana*100) < 10 and PlayerHasBuff(ids.ArcaneSurgeBuff) == false and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) ) then
            NGSend("Arcane Barrage") return true end

        -- Orb in ST if you don't have Charged Orb, will overcap soon, and before entering cooldowns.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies == 1 and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 6 or not IsSpellKnown(ids.ChargedOrbTalent) or PlayerHasBuff(ids.ArcaneSurgeBuff) or GetSpellChargesFractional(ids.ArcaneOrb) > 1.5 ) ) then
            NGSend("Arcane Orb") return true end

        -- Barrage if you have orb coming off cooldown in AOE and you don't have enough harmony stacks to make it worthwhile to hold for set proc.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies >= 2 and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax and ( GetPlayerStacks(ids.ArcaneHarmonyBuff) <= ( 8 + ( 10 * (SetPieces >= 4 and 0 or 1) ) ) ) and ( ( ( (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) or (aura_env.PrevCast == ids.ArcaneOrb or IsCasting(ids.ArcaneOrb)) ) and NetherPrecisionStacks == 1 ) or NetherPrecisionStacks == 2 or (NetherPrecisionStacks == 0) ) ) then
            NGSend("Arcane Barrage") return true end

        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 2 and ( CurrentArcaneCharges == 4 and not (SetPieces >= 4) ) ) then
            NGSend("Arcane Barrage") return true end

        -- Orb if you're low on Harmony stacs.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies > 1 and GetPlayerStacks(ids.ArcaneHarmonyBuff) < 20 and ( PlayerHasBuff(ids.ArcaneSurgeBuff) or (NetherPrecisionStacks > 0) or NearbyEnemies >= 7 ) and (SetPieces >= 4) ) then
            NGSend("Arcane Orb") return true end

        -- Arcane Barrage in AOE if you have Aether Attunement ready and High Voltage
        if OffCooldown(ids.ArcaneBarrage) and ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies >= 2 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.AetherAttunementBuff) and PlayerHasBuff(ids.ClearcastingBuff) ) then
            NGSend("Arcane Barrage") return true end

        -- Use Orb more aggressively if cleave and a little less in AOE.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies > 1 and ( NearbyEnemies < 3 or PlayerHasBuff(ids.ArcaneSurgeBuff) or ( (NetherPrecisionStacks > 0) ) ) and (SetPieces >= 4) ) then
            NGSend("Arcane Orb") return true end

        -- Barrage if Orb is available in AOE.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 1 and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) then
            NGSend("Arcane Barrage") return true end

        -- If you have High Voltage throw out a Barrage before you need to use Clearcasting for NP.
        if OffCooldown(ids.ArcaneBarrage) and ( IsSpellKnown(ids.HighVoltageTalent) and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 ) then
            NGSend("Arcane Barrage") return true end
        
        -- Barrage with Orb Barrage or execute if you have orb up and no Nether Precision or no way to get another and use Arcane Orb to recover Arcane Charges, old resources for Touch of the Magi if you have Magi's Spark. Skip this with Season 3 set.
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies <= 1 and ( IsSpellKnown(ids.OrbBarrageTalent) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) ) ) and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) and CurrentArcaneCharges == 4 and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 6 or not IsSpellKnown(ids.MagisSparkTalent) ) and ( (NetherPrecisionStacks == 0) or ( NetherPrecisionStacks == 1 and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) and not ( SetPieces >= 4 ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Use Explosion for your first charge or if you have High Voltage you can use it for charge 2 and 3, but at a slightly higher target count.
        if OffCooldown(ids.ArcaneExplosion) and ( NearbyEnemies > 1 and ( ( CurrentArcaneCharges < 1 and not IsSpellKnown(ids.HighVoltageTalent) ) or ( CurrentArcaneCharges < 3 and ( GetPlayerStacks(ids.ClearcastingBuff) == 0 or IsSpellKnown(ids.ReverberateTalent) ) ) ) ) then   
            NGSend("Arcane Explosion") return true end
        
        -- You can use Arcane Explosion in single target for your first 2 charges when you have no Clearcasting procs and aren't out of mana. This is only a very slight gain for some profiles so don't feel you have to do this.
        if OffCooldown(ids.ArcaneExplosion) and ( NearbyEnemies == 1 and CurrentArcaneCharges < 2 and not PlayerHasBuff(ids.ClearcastingBuff) ) then
            NGSend("Arcane Explosion") return true end
        
        -- Barrage in execute if you're at the end of Touch or at the end of Surge windows. Skip this with Season 3 set.
        if OffCooldown(ids.ArcaneBarrage) and ( ( ( ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( GcdMax * 1.25 ) ) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) > 0.75 ) ) or ( ( GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) < GcdMax ) and PlayerHasBuff(ids.ArcaneSurgeBuff) ) ) and CurrentArcaneCharges == 4 ) and not ( SetPieces >= 4 ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Nothing else to do? Blast. Out of mana? Barrage.
        if OffCooldown(ids.ArcaneBlast) then
            NGSend("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            NGSend("Arcane Barrage") return true end
    end
    
    local Sunfury = function()
        -- For Sunfury, Shifting Power only when you're not under the effect of any cooldowns.
        if OffCooldown(ids.ShiftingPower) and ( ( ( PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and GetRemainingSpellCooldown(ids.Evocation) > 15 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > 10 ) and FightRemains(60, NearbyRange) > 10 ) and PlayerHasBuff(ids.ArcaneSoulBuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) ) then
            NGSend("Shifting Power") return true end
        
        -- When Arcane Soul is up, use Missiles to generate Nether Precision as needed while also ensuring you end Soul with 3 Clearcasting.
        if OffCooldown(ids.ArcaneMissiles) and ( (NetherPrecisionStacks == 0) and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.ArcaneSoulBuff) and GetRemainingAuraDuration("player", ids.ArcaneSoulBuff) > GcdMax * ( 4 - (PlayerHasBuff(ids.ClearcastingBuff) and 1 or 0) ) ) then
            NGSend("Arcane Missiles") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.ArcaneSoulBuff) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Dump a clearcasting proc before you go into Soul if you have one.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.ArcaneSurgeBuff) and GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) < GcdMax * 2 ) then
            NGSend("Arcane Missiles") return true end

        -- Prioritize Tempo and Intuition if they are about to expire.
        if OffCooldown(ids.ArcaneBarrage) and ( ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < ( GcdMax + ( GcdMax * ( NetherPrecisionStacks == 1 and 1 or 0 ) ) ) ) or ( PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) < ( GcdMax + ( GcdMax * ( NetherPrecisionStacks == 1 and 1 or 0 ) ) ) ) ) then
            NGSend("Arcane Barrage") return true end

        -- Gamble on Orb Barrage in AOE to prevent overcapping on Harmony stacks.
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.OrbBarrageTalent) and NearbyEnemies > 1 and GetPlayerStacks(ids.ArcaneHarmonyBuff) >= 18 and ( ( NearbyEnemies > 3 and ( IsSpellKnown(ids.ResonanceTalent) or IsSpellKnown(ids.HighVoltageTalent) ) ) or (NetherPrecisionStacks == 0) or NetherPrecisionStacks == 1 or ( NetherPrecisionStacks == 2 and GetPlayerStacks(ids.ClearcastingBuff) == 3 ) ) ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Spend Aether Attunement if you have 4pc S2 set before Touch.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and (OldSetPieces >= 4) and PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * ( 3 - ( 1.5 * ( ( NearbyEnemies > 3 and ( not IsSpellKnown(ids.TimeLoopTalent) or IsSpellKnown(ids.ResonanceTalent) ) ) and 1 or 0 ) ) ) ) then
            NGSend("Arcane Missiles") return true end
        
        -- Barrage into Touch if you have charges when it comes up.
        if OffCooldown(ids.ArcaneBarrage) and ( CurrentArcaneCharges == 4 and ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.05 ), GcdMax ) ) and not Variables.SoulCd ) then
            NGSend("Arcane Barrage") return true end
            
        if OffCooldown(ids.ArcaneBarrage) and ( ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.05 ), GcdMax ) ) and ( not PlayerHasBuff(ids.ArcaneSurgeBuff) or ( PlayerHasBuff(ids.ArcaneSurgeBuff) and GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) <= 2.5 ) ) and Variables.SoulCd ) then
            NGSend("Arcane Barrage") return true end
        
        -- Blast if Magi's Spark is up.
        if OffCooldown(ids.ArcaneBlast) and ( aura_env.NeedArcaneBlastSpark and CurrentArcaneCharges == 4 ) then
            NGSend("Arcane Blast") return true end

        -- AOE Barrage conditions revolve around sending Barrages various talents. Whenever you have Clearcasting and Nether Precision or if you have Aether Attunement to recharge with High Voltage. Whenever you have Orb Barrage you should gamble basically any chance you get in execute. Lastly, with Arcane Orb available, you can send Barrage as long as you're not going to use Touch soon and don't have a reason to use Blast up.
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies > 1 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 ) ) then
            NGSend("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies > 1 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) and PlayerHasBuff(ids.GloriousIncandescenceBuff) == false and PlayerHasBuff(ids.IntuitionBuff) == false ) ) then
            NGSend("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 2 and IsSpellKnown(ids.OrbBarrageTalent) and IsSpellKnown(ids.HighVoltageTalent) and not aura_env.NeedArcaneBlastSpark and CurrentArcaneCharges == 4 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) and ( (NetherPrecisionStacks > 0) or ( (NetherPrecisionStacks == 0) and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) ) then
            NGSend("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 2 or ( NearbyEnemies > 1 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) ) ) and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 6 and ( not aura_env.NeedArcaneBlastSpark or not IsSpellKnown(ids.MagisSparkTalent) ) and (NetherPrecisionStacks > 0) and ( IsSpellKnown(ids.HighVoltageTalent) or ( ( not PlayerHasBuff(ids.LeydrinkerBuff) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) and NearbyEnemies >= 4 and IsSpellKnown(ids.ResonanceTalent) ) ) and NetherPrecisionStacks == 2 ) or ( NetherPrecisionStacks == 1 and not PlayerHasBuff(ids.ClearcastingBuff) ) ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Missiles to recoup Charges with High Voltage or maintain Nether Precision and combine it with other Barrage buffs.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and ( ( IsSpellKnown(ids.HighVoltageTalent) and CurrentArcaneCharges < 4 ) or ( NetherPrecisionStacks == 0 and GetPlayerStacks(ids.ClearcastingBuff) > 1 or GetPlayerStacks(ids.SpellfireSpheresBuff) == 6 or PlayerHasBuff(ids.BurdenOfPowerBuff) or PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) ) ) ) then
            NGSend("Arcane Missiles") return true end
        
        -- Barrage with Burden if 2-4 targets and you have a way to recoup Charges, however skip this is you have Bauble and don't have High Voltage.
        if OffCooldown(ids.ArcaneBarrage) and ( ( CurrentArcaneCharges == 4 and NearbyEnemies > 1 and NearbyEnemies < 5 and PlayerHasBuff(ids.BurdenOfPowerBuff) and ( ( IsSpellKnown(ids.HighVoltageTalent) and PlayerHasBuff(ids.ClearcastingBuff) ) or PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) or ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax or C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges > 0 ) ) ) and ( not IsSpellKnown(ids.ConsortiumsBaubleTalent) or IsSpellKnown(ids.HighVoltageTalent) ) ) then
            NGSend("Arcane Barrage") return true end
        
        -- Arcane Orb to recover Charges quickly if below 3.
        if OffCooldown(ids.ArcaneOrb) and ( CurrentArcaneCharges < 3 ) then
            NGSend("Arcane Orb") return true end
        
        -- Barrage with Intuition or Incandescence.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) ) then
            NGSend("Arcane Barrage") return true end
        
        -- In AOE, Presence of Mind is used to build Charges. Arcane Explosion can be used to build your first Charge.
        --if OffCooldown(ids.PresenceOfMind) and ( ( CurrentArcaneCharges == 3 or CurrentArcaneCharges == 2 ) and NearbyEnemies >= 3 ) then
        --    NGSend("Presence of Mind") return true end
        
        if OffCooldown(ids.ArcaneExplosion) and ( CurrentArcaneCharges < 2 and NearbyEnemies > 1 ) then
            NGSend("Arcane Explosion") return true end
        
        if OffCooldown(ids.ArcaneBlast) then
            NGSend("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            NGSend("Arcane Barrage") return true end
    end
    
    if OffCooldown(ids.ArcaneBarrage) and ( FightRemains(60, NearbyRange) < 2 ) then
        NGSend("Arcane Barrage") return true end
    
    -- Enter cooldowns, then action list depending on your hero talent choices
    if not Variables.SoulCd then 
        if CdOpener() then return true end 
    end

    if Variables.SoulCd then
        --if CdOpenerSoul() then return true end
    end
    
    if IsSpellKnown(ids.SpellfireSpheresTalent) then
        if Sunfury() then return true end end
    
    if not IsSpellKnown(ids.SpellfireSpheresTalent) then
        if Spellslinger() then return true end end
    
    if OffCooldown(ids.ArcaneBarrage) then
        NGSend("Arcane Barrage") return true end
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
    if spellID == aura_env.ids.ArcaneBlast then
        aura_env.NeedArcaneBlastSpark = false
        aura_env.PrevArcaneBlast = GetTime()
    elseif spellID == aura_env.ids.ArcaneOrb then
        aura_env.UsedOrb = true
    elseif spellID == aura_env.ids.ArcaneMissiles then
        aura_env.UsedMissiles = true
    elseif spellID == aura_env.ids.ArcaneBarrage then
        aura_env.UsedBarrage = true
    elseif spellID == aura_env.ids.TouchOfTheMagi then
        aura_env.NeedArcaneBlastSpark = true
    end
    return
end