----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.FrozenOrbRemains = 0
aura_env.ConeOfColdLastUsed = 0

---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    ArcaneExplosion = 1449,
    Blizzard = 190356,
    CometStorm = 153595,
    ConeOfCold = 120,
    Flurry = 44614,
    Freeze = 33395,
    FrostNova = 122,
    FrostfireBolt = 431044,
    FrozenOrb = 84714,
    Frostbolt = 116,
    GlacialSpike = 199786,
    IceLance = 30455,
    IceNova = 157997,
    IcyVeins = 12472,
    RayOfFrost = 205021,
    ShiftingPower = 382440,
    
    -- Talents
    ColdestSnapTalent = 417493,
    ColdFrontTalent = 382110,
    CometStormTalent = 153595,
    DeathsChillTalent = 450331,
    DeepShatterTalent = 378749,
    ExcessFrostTalent = 438611,
    FreezingRainTalent = 270233,
    FreezingWindsTalent = 382103,
    FrostfireBoltTalent = 431044,
    FrozenTouchTalent = 205030,
    GlacialAssaultTalent = 378947,
    GlacialSpikeTalent = 199786,
    IceCallerTalent = 236662,
    IsothermicCoreTalent = 431095,
    RayOfFrostTalent = 205021,
    ShiftingShardsTalent = 444675,
    SlickIceTalent = 382144,
    SplinteringColdTalent = 379049,
    SplinteringRayTalent = 418733,
    SplinterstormTalent = 443742,
    UnerringProficiencyTalent = 444974,
    
    -- Buffs
    BrainFreezeBuff = 190446,
    ColdFrontReadyBuff = 382114,
    DeathsChillBuff = 454371,
    ExcessFireBuff = 438624,
    ExcessFrostBuff = 438611,
    FingersOfFrostBuff = 44544,
    FreezingRainBuff = 270232,
    FrostfireEmpowermentBuff = 431177,
    IciclesBuff = 205473,
    IcyVeinsBuff = 12472,
    SpymastersWebBuff = 444959,
    WintersChillDebuff = 228358,
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
    local Variables = {}
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1691)
    local CurrentMana = UnitPower("player", Enum.PowerType.Mana)
    local MaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    
    local NearbyEnemies = 0
    local NearbyRange = 40
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and select(6, strsplit("-", UnitGUID(unit))) ~= "229296" then -- Skip Orb of Ascendance
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    local CurrentIcicles = GetPlayerStacks(ids.IciclesBuff)
    if IsCasting(ids.Frostbolt) then CurrentIcicles = min(CurrentIcicles + 1, 5) 
    elseif IsCasting(ids.GlacialSpike) then CurrentIcicles = 0 end
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Icy Veins
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and ( IsPlayerSpell(ids.FrostfireBoltTalent) or NearbyEnemies >= 3 ) ) then
    ExtraGlows.IcyVeins = true end
    
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and IsPlayerSpell(ids.SplinterstormTalent) ) then
    ExtraGlows.IcyVeins = true end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    Variables.Boltspam = IsPlayerSpell(ids.SplinterstormTalent) and IsPlayerSpell(ids.ColdFrontTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent) and IsPlayerSpell(ids.FrozenTouchTalent) or IsPlayerSpell(ids.FrostfireBoltTalent) and IsPlayerSpell(ids.DeepShatterTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent)
    
    Variables.TargetIsFrozen = TargetHasDebuff(ids.IceNova) or TargetHasDebuff(ids.Freeze) or TargetHasDebuff(ids.FrostNova)
    
    local Movement = function()
        if OffCooldown(ids.Flurry) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.CometStorm) and ( IsPlayerSpell(ids.SplinterstormTalent) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.IceNova) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.IceLance) then
            NGSend("Ice Lance") return true end
    end
    
    local FfAoe = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) then
            NGSend("Cone of Cold") return true end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and TIME SINCE FIGHT START REMOVE MANUALLY - aura_env.ConeOfColdLastUsed > 8 ) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and ( not (aura_env.PrevCast == ids.Freeze) and (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm) ) ) ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and not ( aura_env.PrevCast == ids.Freeze ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            NGSend("Blizzard") return true end
        
        -- During Icy Veins stack Death's Chill to 12 while keeping Blizzard and Frozen Orb on cooldown.
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostfire Bolt") return true end
        
        -- Don't munch Excess Fire before pressing the 2nd Comet Storm in the Cone of Cold sequence. Only relevant for Deaths Chill builds.
        if OffCooldown(ids.IceLance) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetPlayerStacks(ids.ExcessFireBuff) == 2 and OffCooldown(ids.CometStorm) ) then
            NGSend("Ice Lance") return true end
        
        -- Hold Comet Storm for up to 12 seconds for Cone of Cold.
        if OffCooldown(ids.CometStorm) and ( GetRemainingSpellCooldown(ids.ConeOfCold) > 12 or OffCooldown(ids.ConeOfCold) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        -- Cast Flurry to spend Excess Frost.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            NGSend("Flurry") return true end
        
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( not PlayerHasBuff(ids.IcyVeinsBuff) ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) and GetRemainingSpellCooldown(ids.Blizzard) > 6 * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            NGSend("Frostfire Bolt") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local FfCleave = function()
        -- If one of your targets doesnt have Winter's Chill up, target-swap and queue a Flurry after casting Glacial Spike, Frostfire Bolt or Comet Storm.
        if OffCooldown(ids.Flurry) and ( TargetHasDebuff(ids.WintersChillDebuff) == false and OffCooldown(ids.Flurry) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) then
            NGSend("Comet Storm") return true end
        
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and PlayerHasBuff(ids.FreezingRainBuff) ) then
            NGSend("Blizzard") return true end
        
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( PlayerHasBuff(ids.IcyVeinsBuff) == false ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        -- Without Death's Chill talented, also cast Ice Lance into any target with 2 stacks of Winter's Chill.
        if OffCooldown(ids.IceLance) and ( not IsPlayerSpell(ids.DeathsChillTalent) and GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            NGSend("Ice Lance") return true end
        
        -- Always cast Frostfire Bolt at the target with the lowest number of Winter's Chill stacks.
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local FfSt = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            NGSend("Flurry") return true end
        
        -- Cast Flurry with 3+ Icicles to guarantee shattering the Glacial Spike + Pyroblast into Winter's Chill. This also means queueing Flurry when casting Frostfire Bolt with 2+ Icicles and overcapping freely.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( CurrentIcicles >= 3 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( PlayerHasBuff(ids.IcyVeinsBuff) == false ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    -- The Boltspam roation is used whenever all of Death's Chill, Cold Front, Slick Ice and at least one point of Deep Shatter is talented.
    local FfStBoltspam = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            NGSend("Flurry") return true end
        
        -- Queue Flurry whenever casting Frostfire Bolt with 2+ Icicles.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) and CurrentIcicles >= 3 ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetRemainingSpellCooldown(ids.CometStorm) > 8 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and CurrentIcicles == 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local SsAoe = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and ( (aura_env.PrevCast == ids.FrozenOrb or IsCasting(ids.FrozenOrb)) or GetRemainingSpellCooldown(ids.FrozenOrb) > 30 ) ) then
            NGSend("Cone of Cold") return true end
        
        -- Cast Ice Nova against 5+ freezable targets to consume the Winter's Chill debuff applied by Cone of Cold in the very last moment of its duration.
        if OffCooldown(ids.IceNova) and ( ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) or IsPlayerSpell(ids.UnerringProficiencyTalent) ) and NearbyEnemies >= 5 and CurrentTime - aura_env.ConeOfColdLastUsed < 8 and CurrentTime - aura_env.ConeOfColdLastUsed > 7 ) then
            NGSend("Ice Nova") return true end
        
        -- Cast Pet Freeze whenever you cast Glacial Spike against freezable targets to shatter the second Glacial Spike.
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or not IsPlayerSpell(ids.GlacialSpikeTalent) and TIME SINCE FIGHT START REMOVE MANUALLY - aura_env.ConeOfColdLastUsed > 8 ) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            NGSend("Flurry") return true end
        
        -- Cast Flurry regardless of Winter's Chill to spend the Cold Front buff.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ColdFrontReadyBuff) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.CometStorm) and ( IsPlayerSpell(ids.GlacialAssaultTalent) or PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            NGSend("Shifting Power") return true end
        
        -- Not munching Fingers of Frost is more important than munching Icicles.
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 and IsPlayerSpell(ids.GlacialSpikeTalent) ) then
            NGSend("Ice Lance") return true end
        
        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) ) ) then
            NGSend("Glacial Spike") return true end
        
        -- During Icy Veins stack Deaths Chill to 9 before using regular Ice Lances.
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 6 or GetPlayerStacks(ids.DeathsChillBuff) == 6 and not (IsCasting(ids.Frostbolt) or aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostbolt") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local SsCleave = function()
        -- Flurry the off-target after Glacial Spike to make it shatter on both targets.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            NGSend("Flurry") return true end
        
        -- With Shifting Shards talented cast Flurry with or without precast to spend the Cold Front buff.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and IsPlayerSpell(ids.ShiftingShardsTalent) and PlayerHasBuff(ids.ColdFrontReadyBuff) ) then
            NGSend("Flurry") return true end
        
        -- Not munching Fingers of Frost is more important than munching Icicles.
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 and IsPlayerSpell(ids.GlacialSpikeTalent) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.CometStorm) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 and IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 or IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            NGSend("Shifting Power") return true end
        
        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        -- In Icy Veins only ever cast Ice Lance with Fingers of Frost until you have at least 10 Deaths Chill stacks.
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 8 or GetPlayerStacks(ids.DeathsChillBuff) == 8 and not (IsCasting(ids.Frostbolt) or aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostbolt") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local SsSt = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.CometStorm) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 and IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 or IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            NGSend("Shifting Power") return true end
        
        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies >= 3 then
        FfAoe() return true end
    
    if NearbyEnemies >= 3 then
        SsAoe() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies == 2 then
        FfCleave() return true end
    
    if NearbyEnemies == 2 then
        SsCleave() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and ( IsPlayerSpell(ids.GlacialSpikeTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.ColdFrontTalent) and IsPlayerSpell(ids.DeathsChillTalent) and IsPlayerSpell(ids.DeepShatterTalent) ) then
        FfStBoltspam() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) then
        FfSt() return true end
    
    if SsSt() then return true end
    
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
    aura_env.PrevCast3 = aura_env.PrevCast2
    aura_env.PrevCast2 = aura_env.PrevCast
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    
    if spellID == aura_env.ids.FrozenOrb then
        aura_env.FrozenOrbRemains = GetTime() + 15
    elseif spellID == aura_env.ids.ConeOfCold then
        aura_env.ConeOfColdLastUsed = GetTime()
    end
    
    return
end