----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Load--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

aura_env.DemonsurgeAbyssalGazeBuff = false
aura_env.DemonsurgeAnnihilationBuff = false
aura_env.DemonsurgeConsumingFireBuff = false
aura_env.DemonsurgeDeathSweepBuff = false
aura_env.DemonsurgeSigilOfDoomBuff = false
aura_env.ReaversGlaiveLastUsed = 0
aura_env.LastDeathSweep = 999999999
---- Spell IDs ------------------------------------------------------------------------------------------------
---@class idsTable
aura_env.ids = {
    -- Abilities
    AbyssalGaze = 452497,
    Annihilation = 201427,
    BladeDance = 188499,
    ConsumingFire = 452487,
    ChaosStrike = 162794,
    DeathSweep = 210152,
    DemonsBite = 162243,
    EssenceBreak = 258860,
    EyeBeam = 198013,
    FelBarrage = 258925,
    FelRush = 195072,
    Felblade = 232893,
    GlaiveTempest = 342817,
    ImmolationAura = 258920,
    Metamorphosis = 191427,
    ReaversGlaive = 442294,
    SigilOfDoom = 452490,
    SigilOfFlame = 204596,
    SigilOfSpite = 390163,
    TheHunt = 370965,
    ThrowGlaive = 185123,
    VengefulRetreat = 198793,
    
    -- Talents
    AFireInsideTalent = 427775,
    ArtOfTheGlaiveTalent = 442290,
    BlindFuryTalent = 203550,
    BurningWoundTalent = 391189,
    ChaosTheoryTalent = 389687,
    ChaoticTransformationTalent = 388112,
    CycleOfHatredTalent = 258887,
    DemonBladesTalent = 203555,
    DemonicTalent = 213410,
    DemonsurgeTalent = 452402,
    EssenceBreakTalent = 258860,
    ExergyTalent = 206476,
    FelBarrageTalent = 258925,
    FlameboundTalent = 452413,
    FlamesOfFuryTalent = 389694,
    FuriousThrowsTalent = 393029,
    InertiaTalent = 427640,
    InitiativeTalent = 388108,
    IsolatedPreyTalent = 388113,
    LooksCanKillTalent = 320415,
    QuickenedSigilsTalent = 209281,
    RagefireTalent = 388107,
    RestlessHunterTalent = 390142,
    ScreamingBrutalityTalent = 1220506,
    ShatteredDestinyTalent = 388116,
    SoulscarTalent = 388106,
    StudentOfSufferingTalent = 452412,
    TacticalRetreatTalent = 389688,
    UnboundChaosTalent = 347461,
    
    -- Auras
    ChaosTheoryBuff = 390195,
    CycleOfHatredBuff = 1214887,
    DemonSoulTww3Buff = 1238676,
    DemonsurgeBuff = 452416,
    EssenceBreakDebuff = 320338,
    ExergyBuff = 208628,
    FelBarrageBuff = 258925,
    GlaiveFlurryBuff = 442435,
    ImmolationAuraBuff = 258920,
    InertiaBuff = 1215159,
    InertiaTriggerBuff = 427641,
    InitiativeBuff = 391215,
    InnerDemonBuff = 390145,
    MetamorphosisBuff = 162264,
    NecessarySacrificeBuff = 1217055,
    ReaversMarkDebuff = 442624,
    RendingStrikeBuff = 442442,
    StudentOfSufferingBuff = 453239,
    TacticalRetreatBuff = 389890,
    ThrillOfTheFightDamageBuff = 422688,
    UnboundChaosBuff = 347462,
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
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------    
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1920)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1868)
    
    local CurrentFury = UnitPower("player", Enum.PowerType.Fury)
    local MaxFury = UnitPowerMax("player", Enum.PowerType.Fury)
    
    local NearbyEnemies = 0
    local NearbyRange = 10
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
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    Variables.RgDs = 0
    
    -- Fury generated per second
    Variables.FuryGen = (IsPlayerSpell(ids.DemonBladesTalent) and 1 or 0) * ( 1 / ( 2.6 * GetMeleeHaste() ) * ( (( IsPlayerSpell(ids.DemonsurgeTalent) and PlayerHasBuff(ids.MetamorphosisBuff) ) and 1 or 0) * 3 + 12 ) ) + GetPlayerStacks(ids.ImmolationAuraBuff) * 6 + (PlayerHasBuff(ids.TacticalRetreatBuff) and 1 or 0) * 10
    
    Variables.FsTier342Piece = SetPieces >= 2
    
    -- Aldrachi Reaver
    local ArCooldown = function()
        if OffCooldown(ids.Metamorphosis) and ( ( ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or IsPlayerSpell(ids.CycleOfHatredTalent) and GetRemainingSpellCooldown(ids.EyeBeam) >= 13 ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or TargetHasDebuff(ids.EssenceBreakDebuff) ) and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) and GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or ( CurrentTime - aura_env.LastDeathSweep < 3 ) ) ) and not IsPlayerSpell(ids.InertiaTalent) and not IsPlayerSpell(ids.EssenceBreakTalent)  ) then
            NGSend("Metamorphosis") return true end
        
        if OffCooldown(ids.Metamorphosis) and ( ( GetRemainingSpellCooldown(ids.BladeDance) > 0 and ( ( ( CurrentTime - aura_env.LastDeathSweep < 3 ) or PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and ( PlayerHasBuff(ids.InnerDemonBuff) == false and ( PlayerHasBuff(ids.RendingStrikeBuff) == false or not IsPlayerSpell(ids.RestlessHunterTalent) or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) ) and ( IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.EssenceBreakTalent) )  ) then
            NGSend("Metamorphosis") return true end
        
        if OffCooldownNotCasting(ids.TheHunt) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( (TargetHasDebuff(ids.ReaversMarkDebuff) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent)) or not IsPlayerSpell(ids.ArtOfTheGlaiveTalent) ) and FindSpellOverrideByID(ids.ThrowGlaive) ~= ids.ReaversGlaive and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 or PlayerHasBuff(ids.MetamorphosisBuff) == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) ) then
            NGSend("The Hunt") return true end
        
        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingDebuffDuration("target", ids.ReaversMarkDebuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) ) and GetRemainingSpellCooldown(ids.BladeDance) > 0 ) then
            NGSend("Sigil of Spite") return true end
    end
    
    local ArFelBarrage = function()
        Variables.GeneratorUp = GetRemainingSpellCooldown(ids.Felblade) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.SigilOfFlame) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
        
        Variables.GcdDrain = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 32
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.EyeBeam) and ( ( PlayerHasBuff(ids.FelBarrageBuff) == false or CurrentFury > 45 and IsPlayerSpell(ids.BlindFuryTalent) ) ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.EssenceBreak) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 2 or PlayerHasBuff(ids.FelBarrageBuff) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > GetTimeToNextCharge(ids.ImmolationAura) + 3 ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and NearbyEnemies > 1 ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.BladeDance) and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.FelBarrage) and ( CurrentFury > 100 ) then
            NGSend("Fel Barrage") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) and CurrentFury > 20 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.FelBarrageBuff) and MaxFury - CurrentFury > 40 ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( CurrentFury - Variables.GcdDrain - 30 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.BladeDance) and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Blade Dance") return true end
        
        -- actions.ar_fel_barrage+=/fel_rush,if=buff.unbound_chaos.up
        
        if OffCooldownNotCasting(ids.TheHunt) and ( CurrentFury > 40 ) then
            NGSend("The Hunt") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingSpellCooldown(ids.FelBarrage) > 0 and GetRemainingSpellCooldown(ids.FelBarrage) < 10 and CurrentFury > 100 or PlayerHasBuff(ids.FelBarrageBuff) and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) * Variables.FuryGen - GetRemainingAuraDuration("player", ids.FelBarrageBuff) * 32 ) > 0 ) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
    end
    
    local ArMeta = function()
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) or OffCooldown(ids.Metamorphosis) and not IsPlayerSpell(ids.RestlessHunterTalent) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.VengefulRetreat) and ( IsPlayerSpell(ids.InitiativeTalent) and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and ( GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.6 or GetRemainingSpellCooldown(ids.EssenceBreak) > 10 or not IsPlayerSpell(ids.EssenceBreakTalent) ) or IsPlayerSpell(ids.RestlessHunterTalent) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) ) then
            NGSend("Vengeful Retreat") return true end
        
        -- actions.ar_meta+=/annihilation,if=talent.restless_hunter&buff.rending_strike.up&cooldown.essence_break.up&cooldown.metamorphosis.up
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 1 and GetRemainingSpellCooldown(ids.BladeDance) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and GetRemainingSpellCooldown(ids.Metamorphosis) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) then
            NGSend("Felblade") return true end
        
        -- actions.ar_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3
        
        if OffCooldown(ids.EssenceBreak) and ( CurrentFury >= 30 and IsPlayerSpell(ids.RestlessHunterTalent) and OffCooldown(ids.Metamorphosis) and ( IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaBuff) or not IsPlayerSpell(ids.InertiaTalent) ) and GetRemainingSpellCooldown(ids.BladeDance) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) and GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) < 0.5 and GetRemainingSpellCooldown(ids.BladeDance) > 0 or PlayerHasBuff(ids.InnerDemonBuff) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and ( GetRemainingSpellCooldown(ids.EyeBeam) <= 0.5 or GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.5 or GetRemainingSpellCooldown(ids.BladeDance) <= 5.5 or GetRemainingAuraDuration("player", ids.InitiativeBuff) < 0 ) ) then       
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and NearbyEnemies > 2 ) then
            NGSend("Fel Rush") return true end
        
        -- actions.ar_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&cooldown.blade_dance.remains<gcd.max*3&cooldown.metamorphosis.remains
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and NearbyEnemies > 2 ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( C_Spell.GetSpellCharges(ids.ImmolationAura).currentCharges == 2 and NearbyEnemies > 1 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.BladeDance) > 0 or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.EssenceBreak) and ( CurrentFury > 20 and ( GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or OffCooldown(ids.BladeDance) ) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and not IsPlayerSpell(ids.InertiaTalent) or PlayerHasBuff(ids.InertiaBuff) ) and ( not IsPlayerSpell(ids.ShatteredDestinyTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 4 ) or FightRemains(60, NearbyRange) < 10 ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.EyeBeam) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or CurrentFury > 60 ) ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( IsPlayerSpell(ids.SoulscarTalent) and IsPlayerSpell(ids.FuriousThrowsTalent) and NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( C_Spell.GetSpellCharges(ids.ThrowGlaive).currentCharges == 2 or GetTimeToFullCharges(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.BladeDance) ) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingSpellCooldown(ids.BladeDance) > 0 or CurrentFury > 60 or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < 5 and OffCooldown(ids.Felblade) or TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 and MaxFury - CurrentFury >= 30 + Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + NearbyEnemies  * (IsPlayerSpell(ids.FlamesOfFuryTalent) and 2 or 0 ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury >= 40 + Variables.FuryGen * 0.5 and not PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and aura_env.OutOfRange == true and MaxFury - CurrentFury >= 30 + Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + NearbyEnemies * ( IsPlayerSpell(ids.FlamesOfFuryTalent) and 2 or 0 ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( aura_env.OutOfRange == true and GetTimeToNextCharge(ids.ImmolationAura) < ( max(GetRemainingSpellCooldown(ids.EyeBeam), GetRemainingAuraDuration("player", ids.MetamorphosisBuff)) ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation then
            NGSend("Annihilation") return true end
        
        -- NG ADDED LOW PRIO IMMO AURA FOR SINGLE TARGET!
        if OffCooldown(ids.ImmolationAura) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( not PlayerHasBuff(ids.UnboundChaosBuff) and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and not TargetHasDebuff(ids.EssenceBreakDebuff) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.FelRush) and ( GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
    end
    
    local Ar = function()
        Variables.RgInc = PlayerHasBuff(ids.RendingStrikeBuff) == false and PlayerHasBuff(ids.GlaiveFlurryBuff) and OffCooldown(ids.BladeDance) or Variables.RgInc and ( CurrentTime - aura_env.LastDeathSweep < 1 )      
        
        Variables.FelBarrage = IsPlayerSpell(ids.FelBarrageTalent) and ( GetRemainingSpellCooldown(ids.FelBarrage) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 or NearbyEnemies > 2 ) or PlayerHasBuff(ids.FelBarrageBuff) )
        
        if OffCooldown(ids.ChaosStrike) and ( PlayerHasBuff(ids.RendingStrikeBuff) and PlayerHasBuff(ids.GlaiveFlurryBuff) and ( Variables.RgDs == 2 or NearbyEnemies > 2 )) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.RendingStrikeBuff) and PlayerHasBuff(ids.GlaiveFlurryBuff) and ( Variables.RgDs == 2 or NearbyEnemies > 2 ) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.ThrowGlaive) and FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive and ( PlayerHasBuff(ids.GlaiveFlurryBuff) == false and PlayerHasBuff(ids.RendingStrikeBuff) == false and GetRemainingAuraDuration("player", ids.ThrillOfTheFightDamageBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 + ( (Variables.RgDs == 2) and 1 or 0 ) + (( GetRemainingSpellCooldown(ids.TheHunt) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) and 1 or 0) * 3 + (( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and IsPlayerSpell(ids.ShatteredDestinyTalent) ) and 1 or 0) * 3 and ( Variables.RgDs == 0 or Variables.RgDs == 1 and OffCooldown(ids.BladeDance) or Variables.RgDs == 2 and GetRemainingSpellCooldown(ids.BladeDance) > 0 ) and ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or not ( CurrentTime - aura_env.LastDeathSweep < 1 ) or not Variables.RgInc ) and NearbyEnemies < 3 and CurrentTime - aura_env.ReaversGlaiveLastUsed > 5 and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 2 or GetRemainingSpellCooldown(ids.EyeBeam) < 10 or FightRemains(60, NearbyRange) < 10 ) and ( TargetTimeToXPct(0, 50) >= 10 or FightRemains(60, NearbyRange) <= 10 ) or FightRemains(60, NearbyRange) <= 10 ) then
            NGSend("Reavers Glaive") return true end
        
        if OffCooldown(ids.ThrowGlaive) and FindSpellOverrideByID(ids.ThrowGlaive) == ids.ReaversGlaive and ( PlayerHasBuff(ids.GlaiveFlurryBuff) == false and PlayerHasBuff(ids.RendingStrikeBuff) == false and GetRemainingAuraDuration("player", ids.ThrillOfTheFightDamageBuff) < 4 and ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or not ( CurrentTime - aura_env.LastDeathSweep < 1 ) or not Variables.RgInc ) and NearbyEnemies > 2 and TargetTimeToXPct(0, 50) >= 10 and not TargetHasDebuff(ids.EssenceBreakDebuff) or FightRemains(60, NearbyRange) <= 10 ) then
            NGSend("Reavers Glaive") return true end
        
        if ArCooldown() then return true end
        
        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.BladeDance) > 0 and GetRemainingDebuffDuration("target", ids.ReaversMarkDebuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) and ( GetRemainingAuraDuration("player", ids.NecessarySacrificeBuff) >= 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) or not (OldSetPieces >= 4) or GetRemainingSpellCooldown(ids.EyeBeam) > 8 ) and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) + (IsPlayerSpell(ids.ShatteredDestinyTalent) and 1 or 0) >= GetRemainingAuraDuration("player", ids.NecessarySacrificeBuff) + 2 - (IsPlayerSpell(ids.QuickenedSigilsTalent) and 1 or 0) ) or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Sigil of Spite") return true end
        
        if Variables.FelBarrage then
            return ArFelBarrage() end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > GetTimeToNextCharge(ids.ImmolationAura) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            NGSend("Immolation Aura") return true end
        
        -- actions.ar+=/fel_rush,if=buff.unbound_chaos.up&active_enemies>2&(!talent.inertia|cooldown.eye_beam.remains+2>buff.unbound_chaos.remains)
        
        -- Lineup Vengeful retreat with Eyebeam casts for Tactical retreat builds
        if OffCooldown(ids.VengefulRetreat) and ( IsPlayerSpell(ids.InitiativeTalent) and IsPlayerSpell(ids.TacticalRetreatTalent) and (OffCooldown(ids.EyeBeam) and ( IsPlayerSpell(ids.RestlessHunterTalent) or GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) ) and (not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false) ) then
            NGSend("Vengeful Retreat") return true end
        
        if OffCooldown(ids.VengefulRetreat) and ( IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.TacticalRetreatTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 15 and 0 < 0.3 or 0 < 0.2 and GetRemainingSpellCooldown(ids.EyeBeam) <= 0 and GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false ) ) then
            NGSend("Vengeful Retreat") return true end
        
        -- talent.initiative&(cooldown.eye_beam.remains>15&gcd.remains<0.3|gcd.remains<0.2&cooldown.eye_beam.remains<=gcd.remains&(buff.unbound_chaos.up|action.immolation_aura.recharge_time>6|!talent.inertia|talent.momentum)&(cooldown.metamorphosis.remains>10|cooldown.blade_dance.remains<gcd.max*2&(talent.inertia|talent.momentum|buff.metamorphosis.up)))&(!talent.student_of_suffering|cooldown.sigil_of_flame.remains)&time>10&(!variable.trinket1_steroids&!variable.trinket2_steroids|variable.trinket1_steroids&(trinket.1.cooldown.remains<gcd.max*3|trinket.1.cooldown.remains>20)|variable.trinket2_steroids&(trinket.2.cooldown.remains<gcd.max*3|trinket.2.cooldown.remains>20|talent.shattered_destiny))&(cooldown.metamorphosis.remains|hero_tree.aldrachi_reaver)&time>20
        
        if Variables.FelBarrage or not IsPlayerSpell(ids.DemonBladesTalent) and IsPlayerSpell(ids.FelBarrageTalent) and ( PlayerHasBuff(ids.FelBarrageBuff) or OffCooldown(ids.FelBarrage) ) and PlayerHasBuff(ids.MetamorphosisBuff) == false then       
            return ArFelBarrage() end
        
        if OffCooldown(ids.Felblade) and ( not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies == 1 and PlayerHasBuff(ids.UnboundChaosBuff) and PlayerHasBuff(ids.InitiativeBuff) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) == false ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) <= 0.5 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 and IsPlayerSpell(ids.LooksCanKillTalent) or NearbyEnemies > 1 ) ) then
            NGSend("Felblade") return true end
        
        if PlayerHasBuff(ids.MetamorphosisBuff) then
            return ArMeta() end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaBuff) == false and GetRemainingSpellCooldown(ids.BladeDance) < 4 and ( GetRemainingSpellCooldown(ids.EyeBeam) > 5 and GetRemainingSpellCooldown(ids.EyeBeam) > GetRemainingAuraDuration("player", ids.UnboundChaosBuff) or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.VengefulRetreat) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + 1 ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( FightRemains(60, NearbyRange) < 15 and GetRemainingSpellCooldown(ids.BladeDance) > 0 and IsPlayerSpell(ids.RagefireTalent) ) then
            NGSend("Immolation Aura") return true end
        
        -- # actions.ar+=/blade_dance,if=buff.rending_strike.down&buff.glaive_flurry.up&active_enemies>2&cooldown.eye_beam.remains<=4&buff.thrill_of_the_fight_damage.remains<gcd.max&raid_event.adds.remains>10&(cooldown.immolation_aura.remains|!talent.burning_wound) actions.ar+=/eye_beam,if=!talent.essence_break&(!talent.chaotic_transformation|cooldown.metamorphosis.remains<5+3*talent.shattered_destiny|cooldown.metamorphosis.remains>10)&(active_enemies>desired_targets*2|raid_event.adds.in>30-talent.cycle_of_hatred.rank*2.5*buff.cycle_of_hatred.stack)&(!talent.initiative|cooldown.vengeful_retreat.remains>5|cooldown.vengeful_retreat.up&active_enemies>2|talent.shattered_destiny)
        
        -- NG Removed "and not PlayerHasBuff(ids.GlaiveFlurryBuff)"
        if OffCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.BladeDance) < 7 and ( ( PlayerHasBuff(ids.ThrillOfTheFightDamageBuff) or not PlayerHasBuff(ids.RendingStrikeBuff) ) ) ) then
            NGSend("Eye Beam") return true end
        
        -- talent.essence_break&(cooldown.essence_break.remains<gcd.max*2+5*talent.shattered_destiny|talent.shattered_destiny&cooldown.essence_break.remains>10)&(cooldown.blade_dance.remains<7|raid_event.adds.up)&(!talent.initiative|cooldown.vengeful_retreat.remains>10|!talent.inertia&!talent.momentum|raid_event.adds.up)&(active_enemies+3>=desired_targets+raid_event.adds.count|raid_event.adds.in>30-talent.cycle_of_hatred.rank*6)&(!talent.inertia|buff.inertia_trigger.up|action.immolation_aura.charges=0&action.immolation_aura.recharge_time>5)&(!raid_event.adds.up|raid_event.adds.remains>8)&(!variable.trinket1_steroids&!variable.trinket2_steroids|variable.trinket1_steroids&(trinket.1.cooldown.remains<gcd.max*3|trinket.1.cooldown.remains>20)|variable.trinket2_steroids&(trinket.2.cooldown.remains<gcd.max*3|trinket.2.cooldown.remains>20))|fight_remains<10
        
        if OffCooldown(ids.BladeDance) and ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or NearbyEnemies >= 2 and PlayerHasBuff(ids.GlaiveFlurryBuff) ) and PlayerHasBuff(ids.RendingStrikeBuff) == false ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( PlayerHasBuff(ids.RendingStrikeBuff) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.SigilOfFlame) and (NearbyEnemies > 3 or TargetHasDebuff(ids.EssenceBreakDebuff) == false) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury >= 40 + Variables.FuryGen * 0.5 and not PlayerHasBuff(ids.InertiaTriggerBuff) and ( not IsPlayerSpell(ids.BlindFuryTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 5 ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.GlaiveTempest) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.FuriousThrowsTalent) and IsPlayerSpell(ids.SoulscarTalent) and ( not IsPlayerSpell(ids.ScreamingBrutalityTalent) or GetSpellChargesFractional(ids.ThrowGlaive) >= 2 or GetTimeToFullCharges(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.BladeDance) ) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( GetRemainingSpellCooldown(ids.EyeBeam) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 or CurrentFury >= 70 - Variables.FuryGen * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) - ( IsPlayerSpell(ids.BlindFuryTalent) and 30 or 0) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.Felblade) and ( not IsPlayerSpell(ids.AFireInsideTalent) and CurrentFury < 40 ) then
            NGSend("Felblade") return true end
        
        -- NG REMOVED "NearbyEnemies > 2"
        if OffCooldown(ids.ImmolationAura) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.OutOfRange == true and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > 25 ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and NearbyEnemies > 1 ) then
            NGSend("Fel Rush") return true end
    end
    
    -- Fel-Scarred
    local FsCooldown = function()
        if OffCooldown(ids.Metamorphosis) and ( ( ( ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or IsPlayerSpell(ids.CycleOfHatredTalent) and GetRemainingSpellCooldown(ids.EyeBeam) >= 13 ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or TargetHasDebuff(ids.EssenceBreakDebuff) ) and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) and GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) and not IsPlayerSpell(ids.InertiaTalent) and not IsPlayerSpell(ids.EssenceBreakTalent) ) then
            NGSend("Metamorphosis") return true end
        
        if OffCooldown(ids.Metamorphosis) and ( ( GetRemainingSpellCooldown(ids.BladeDance) > 0 and ( ( ( CurrentTime - aura_env.LastDeathSweep < 3 ) or PlayerHasBuff(ids.MetamorphosisBuff) and GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and PlayerHasBuff(ids.FelBarrageBuff) == false or not IsPlayerSpell(ids.ChaoticTransformationTalent) or FightRemains(60, NearbyRange) < 30 ) and ( PlayerHasBuff(ids.InnerDemonBuff) == false and ( not IsPlayerSpell(ids.RestlessHunterTalent) or ( CurrentTime - aura_env.LastDeathSweep < 1 ) ) ) ) and ( IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.EssenceBreakTalent) ) ) then       
            NGSend("Metamorphosis") return true end
        
        if OffCooldownNotCasting(ids.TheHunt) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 or PlayerHasBuff(ids.MetamorphosisBuff) == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) and PlayerHasBuff(ids.MetamorphosisBuff) == false or FightRemains(60, NearbyRange) <= 30 ) then
            NGSend("The Hunt") return true end
        
        -- actions.fs_cooldown+=/the_hunt,if=debuff.essence_break.down&(active_enemies>=desired_targets+raid_event.adds.count|raid_event.adds.in>90)&(debuff.reavers_mark.up|!hero_tree.aldrachi_reaver)&buff.reavers_glaive.down&(buff.metamorphosis.remains>5|buff.metamorphosis.down)&(!talent.initiative|buff.initiative.up|time>5)&time>5&(!talent.inertia&buff.unbound_chaos.down|buff.inertia_trigger.down)&(!talent.inertia&(hero_tree.aldrachi_reaver|buff.metamorphosis.down)|hero_tree.felscarred&cooldown.metamorphosis.up|fight_remains<cooldown.metamorphosis.remains)
        
        if OffCooldown(ids.SigilOfSpite) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.BladeDance) ) then
            NGSend("Sigil of Spite") return true end
    end
    
    local FsFelBarrage = function()
        Variables.GeneratorUp = GetRemainingSpellCooldown(ids.Felblade) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.SigilOfFlame) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
        
        Variables.GcdDrain = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 32
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.EyeBeam) and ( ( PlayerHasBuff(ids.FelBarrageBuff) == false or CurrentFury > 45 and IsPlayerSpell(ids.BlindFuryTalent) ) and ( NearbyEnemies > 1 ) ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.EssenceBreak) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and PlayerHasBuff(ids.MetamorphosisBuff) ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 2 or PlayerHasBuff(ids.FelBarrageBuff) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > GetTimeToNextCharge(ids.ImmolationAura) + 3 ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( PlayerHasBuff(ids.FelBarrageBuff) == false and NearbyEnemies > 1 ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.BladeDance) and ( PlayerHasBuff(ids.FelBarrageBuff) == false ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.FelBarrage) and ( CurrentFury > 100 ) then
            NGSend("Fel Barrage") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) and CurrentFury > 20 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 30 ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and MaxFury - CurrentFury > 40 and PlayerHasBuff(ids.FelBarrageBuff) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.FelBarrageBuff) and MaxFury - CurrentFury > 40 and OffCooldown(ids.Felblade) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( CurrentFury - Variables.GcdDrain - 30 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.BladeDance) and ( CurrentFury - Variables.GcdDrain - 35 > 0 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.TheHunt) and ( CurrentFury > 40 ) then
            NGSend("The Hunt") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) < 3 or Variables.GeneratorUp or CurrentFury > 80 or Variables.FuryGen > 18 ) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( CurrentFury - Variables.GcdDrain - 40 > 20 and ( GetRemainingSpellCooldown(ids.FelBarrage) > 0 and GetRemainingSpellCooldown(ids.FelBarrage) < 10 and CurrentFury > 100 or PlayerHasBuff(ids.FelBarrageBuff) and ( GetRemainingAuraDuration("player", ids.FelBarrageBuff) * Variables.FuryGen - GetRemainingAuraDuration("player", ids.FelBarrageBuff) * 32 ) > 0 ) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
    end
    
    local FsMeta = function()
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) and ( not PlayerHasBuff(ids.ImmolationAuraBuff) or not Variables.FsTier342Piece ) and ( not PlayerHasBuff(ids.DemonSoulTww3Buff) or not SetPieces >= 4 ) or aura_env.PrevCast == ids.Metamorphosis and not Variables.FsTier342Piece or aura_env.DemonsurgeDeathSweepBuff and Variables.FsTier342Piece and GetRemainingAuraDuration("player", ids.DemonsurgeBuff) < 5 or ( Variables.FsTier342Piece and OffCooldown(ids.Metamorphosis) and IsPlayerSpell(ids.InertiaTalent) ) or NearbyEnemies >= 3 and aura_env.DemonsurgeDeathSweepBuff and ( not IsPlayerSpell(ids.InertiaTalent) or not PlayerHasBuff(ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.VengefulRetreat) > 0 or PlayerHasBuff(ids.InertiaBuff) ) and ( not IsPlayerSpell(ids.EssenceBreak) or TargetHasDebuff(ids.EssenceBreakDebuff) or GetRemainingSpellCooldown(ids.EssenceBreak) >= 5 ) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and IsPlayerSpell(ids.StudentOfSufferingTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and 
            ( IsPlayerSpell(ids.StudentOfSufferingTalent) and 
                ( ( IsPlayerSpell(ids.EssenceBreakTalent) and GetRemainingSpellCooldown(ids.EssenceBreak) > 30 - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or 
                        GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + (IsPlayerSpell(ids.InertiaTalent) and 1 or 0) and 
                        (( GetRemainingSpellCooldown(ids.VengefulRetreat) <= WeakAuras.gcdDuration() or PlayerHasBuff(ids.InitiativeBuff) ) and 1 or 0) + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( ( GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and 1 or 0 ) ) or
                    ( not IsPlayerSpell(ids.EssenceBreakTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= 10 or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) ) ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.VengefulRetreat) and ( IsPlayerSpell(ids.InitiativeTalent) and ( 0 < 0.3 or IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) > 0 and ( GetPlayerStacks(ids.CycleOfHatredBuff) == 2 or GetPlayerStacks(ids.CycleOfHatredBuff) == 3 ) ) and ( GetRemainingSpellCooldown(ids.Metamorphosis) and ( aura_env.DemonsurgeAnnihilationBuff == false and aura_env.DemonsurgeDeathSweepBuff == false ) or IsPlayerSpell(ids.RestlessHunterTalent) and aura_env.DemonsurgeAnnihilationBuff == false ) and ( not IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.UnboundChaosBuff) == false or PlayerHasBuff(ids.InertiaTriggerBuff) == false ) and ( not IsPlayerSpell(ids.EssenceBreakTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) > 18 or GetRemainingSpellCooldown(ids.EssenceBreak) <= 0 + (IsPlayerSpell(ids.InertiaTalent) and 1 or 0) * 1.5 and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or ( PlayerHasBuff(ids.StudentOfSufferingBuff) or GetRemainingSpellCooldown(ids.SigilOfFlame) > 5 ) ) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 5 or GetRemainingSpellCooldown(ids.EyeBeam) <= 0 or OffCooldown(ids.EyeBeam) ) or OffCooldown(ids.Metamorphosis) and GetPlayerStacks(ids.DemonsurgeBuff) > 1 and IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.InertiaTalent) ) then
            NGSend("Vengeful Retreat") return true end
        
        if OffCooldown(ids.VengefulRetreat) and ( Variables.FsTier342Piece and not PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InitiativeTalent) ) then
            NGSend("Vengeful Retreat") return true end
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.InertiaTalent) and Variables.FsTier342Piece and PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            NGSend("Felblade") return true end
        
        -- &active_enemies<3 actions.fs_meta+=/fel_rush,if=talent.inertia&variable.fs_tier34_2piece&buff.inertia_trigger.up&(active_enemies>=3|cooldown.felblade.remains) actions.fs_meta+=/felblade,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&hero_tree.aldrachi_reaver&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3 actions.fs_meta+=/felblade,if=talent.inertia&buff.inertia_trigger.up&debuff.essence_break.down&buff.demonsurge_hardcast.up&buff.demonsurge.stack=0&buff.demonsurge_death_sweep.up actions.fs_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&debuff.essence_break.down&buff.demonsurge_hardcast.up&buff.demonsurge.stack=0&buff.demonsurge_death_sweep.up&cooldown.felblade.remains actions.fs_meta+=/fel_rush,if=talent.inertia&buff.inertia_trigger.up&cooldown.essence_break.remains<=1&hero_tree.aldrachi_reaver&cooldown.blade_dance.remains<=gcd.max*2&cooldown.metamorphosis.remains<=gcd.max*3 actions.fs_meta+=/essence_break,if=fury>=30&talent.restless_hunter&cooldown.metamorphosis.up&(talent.inertia&buff.inertia.up|!talent.inertia)&cooldown.blade_dance.remains<=gcd.max&(hero_tree.felscarred&buff.demonsurge_annihilation.down|hero_tree.aldrachi_reaver)
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( ( IsPlayerSpell(ids.EssenceBreakTalent) and aura_env.DemonsurgeDeathSweepBuff and ( PlayerHasBuff(ids.InertiaBuff) and ( GetRemainingSpellCooldown(ids.EssenceBreak) > GetRemainingAuraDuration("player", ids.InertiaBuff) or not IsPlayerSpell(ids.EssenceBreakTalent) ) or GetRemainingSpellCooldown(ids.Metamorphosis) <= 5 and PlayerHasBuff(ids.InertiaTriggerBuff) == false or PlayerHasBuff(ids.InertiaBuff) and aura_env.DemonsurgeAbyssalGazeBuff ) or IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) == false and GetRemainingSpellCooldown(ids.VengefulRetreat) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and PlayerHasBuff(ids.InertiaBuff) == false ) and ( not Variables.FsTier342Piece or not IsPlayerSpell(ids.InertiaTalent) or NearbyEnemies >= 3 and TargetHasDebuff(ids.EssenceBreakDebuff) ) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.BladeDance) < GetRemainingAuraDuration("player", ids.MetamorphosisBuff) or GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) and GetRemainingDebuffDuration("target", ids.EssenceBreakDebuff) < 0.5 or IsPlayerSpell(ids.RestlessHunterTalent) and ( aura_env.DemonsurgeAnnihilationBuff or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) and PlayerHasBuff(ids.InnerDemonBuff) ) and OffCooldown(ids.EssenceBreak) and OffCooldown(ids.Metamorphosis) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( ( aura_env.DemonsurgeAnnihilationBuff and IsPlayerSpell(ids.RestlessHunterTalent) ) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and GetRemainingSpellCooldown(ids.BladeDance) or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.Felblade) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.BladeDance) <= 5.5 and ( IsPlayerSpell(ids.EssenceBreakTalent) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.5 or not IsPlayerSpell(ids.EssenceBreakTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) >= GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) and GetRemainingSpellCooldown(ids.BladeDance) <= 4.5 and ( GetRemainingSpellCooldown(ids.BladeDance) or GetRemainingSpellCooldown(ids.BladeDance) <= 0.5 ) ) or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) <= 5.5 + (IsPlayerSpell(ids.ShatteredDestinyTalent) and 1 or 0) * 2 ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.InertiaTriggerBuff) and IsPlayerSpell(ids.InertiaTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) and ( GetRemainingSpellCooldown(ids.Felblade) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 0.6 or NearbyEnemies > 2 ) ) then
            NGSend("Fel Rush") return true end
        
        -- |cooldown.felblade.remains&buff.metamorphosis.remains<=5.6-talent.shattered_destiny*gcd.max*2) actions.fs_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.metamorphosis.remains&(!hero_tree.felscarred|cooldown.eye_beam.remains&(!buff.demonsurge_hardcast.up|cooldown.essence_break.remains<=0.5)|buff.demonsurge_hardcast.up&cooldown.eye_beam.remains<=0.6) actions.fs_meta+=/fel_rush,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.metamorphosis.remains&(!hero_tree.felscarred|cooldown.eye_beam.remains&(!buff.demonsurge_hardcast.up|cooldown.essence_break.remains<=0.5)|buff.demonsurge_hardcast.up&cooldown.eye_beam.remains<=gcd.max)&(active_enemies>2|hero_tree.felscarred)&cooldown.felblade.remains actions.fs_meta+=/felblade,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.blade_dance.remains<gcd.max*3&(!hero_tree.felscarred|cooldown.eye_beam.remains)&cooldown.metamorphosis.remains actions.fs_meta+=/fel_rush,if=buff.inertia_trigger.up&talent.inertia&debuff.essence_break.down&cooldown.blade_dance.remains<gcd.max*3&(!hero_tree.felscarred|cooldown.eye_beam.remains)&cooldown.metamorphosis.remains&(active_enemies>2|hero_tree.felscarred) actions.fs_meta+=/immolation_aura,if=charges=2&active_enemies>1&debuff.essence_break.down
        
        if OffCooldown(ids.ImmolationAura) and ( ( NearbyEnemies > 1 or IsPlayerSpell(ids.AFireInsideTalent) and ( IsPlayerSpell(ids.IsolatedPreyTalent) or Variables.FsTier342Piece ) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( NearbyEnemies >= 3 or GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or Variables.FsTier342Piece and GetRemainingAuraDuration("player", ids.ImmolationAuraBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or Variables.FsTier342Piece and not PlayerHasBuff(ids.ImmolationAuraBuff) ) ) then
            NGSend("Immolation Aura") return true end
        
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( PlayerHasBuff(ids.InnerDemonBuff) and GetRemainingSpellCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or GetRemainingSpellCooldown(ids.Metamorphosis) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) then
            NGSend("Annihilation") return true end
        
        -- actions.fs_meta+=/sigil_of_doom,if=debuff.essence_break.down&(buff.demonsurge_sigil_of_doom.up&cooldown.blade_dance.remains|talent.student_of_suffering&((talent.essence_break&cooldown.essence_break.remains>30-gcd.max|cooldown.essence_break.remains<=gcd.max*3&(!talent.inertia|buff.inertia_trigger.up))|(!talent.essence_break&(cooldown.eye_beam.remains>=30|cooldown.eye_beam.remains<=gcd.max))))
        
        if OffCooldown(ids.EssenceBreak) and ( CurrentFury > 20 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and not Variables.FsTier342Piece or Variables.FsTier342Piece and PlayerHasBuff(ids.MetamorphosisBuff) ) and ( PlayerHasBuff(ids.InertiaTriggerBuff) == false or PlayerHasBuff(ids.InertiaBuff) and GetRemainingAuraDuration("player", ids.InertiaBuff) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not IsPlayerSpell(ids.InertiaTalent) or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) <= GetRemainingSpellCooldown(ids.Metamorphosis) ) and ( not IsPlayerSpell(ids.ShatteredDestinyTalent) or GetRemainingSpellCooldown(ids.EyeBeam) > 4 ) and ( NearbyEnemies > 1 or GetRemainingSpellCooldown(ids.Metamorphosis) > 5 and GetRemainingSpellCooldown(ids.EyeBeam) ) and ( not GetPlayerStacks(ids.CycleOfHatredBuff) == 3 or PlayerHasBuff(ids.InitiativeBuff) or not IsPlayerSpell(ids.InitiativeTalent) or not IsPlayerSpell(ids.CycleOfHatredTalent) ) or FightRemains(60, NearbyRange) < 5 ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.DemonsurgeSigilOfDoomBuff and not aura_env.DemonsurgeDeathSweepBuff and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) >= 20 or GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or aura_env.DemonsurgeSigilOfDoomBuff ) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and PlayerHasBuff(ids.DemonsurgeBuff) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and aura_env.DemonsurgeConsumingFireBuff and GetRemainingSpellCooldown(ids.BladeDance) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and MaxFury - CurrentFury > 10 + Variables.FuryGen ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.EyeBeam) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) or SetPieces < 4 ) ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.EyeBeam) and ( aura_env.DemonsurgeAbyssalGazeBuff and TargetHasDebuff(ids.EssenceBreakDebuff) == false and PlayerHasBuff(ids.InnerDemonBuff) == false and ( GetPlayerStacks(ids.CycleOfHatredBuff) < 4 or GetRemainingSpellCooldown(ids.EssenceBreak) >= 20 - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) or GetRemainingSpellCooldown(ids.SigilOfFlame) and IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or not IsPlayerSpell(ids.EssenceBreak) ) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) >= 7 or SetPieces < 4 ) ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.BladeDance) and FindSpellOverrideByID(ids.BladeDance) == ids.DeathSweep and ( ( GetRemainingSpellCooldown(ids.EssenceBreak) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or TargetHasDebuff(ids.EssenceBreakDebuff) or not IsPlayerSpell(ids.EssenceBreakTalent) ) and ( not PlayerHasBuff(ids.ImmolationAuraBuff) or not Variables.FsTier342Piece or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) and ( not PlayerHasBuff(ids.DemonSoulTww3Buff) or SetPieces < 4 or NearbyEnemies >= 3 or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) ) then
            NGSend("Death Sweep") return true end
        
        if OffCooldown(ids.GlaiveTempest) and ( TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.BladeDance) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or CurrentFury > 60 ) ) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 2 and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            NGSend("Sigil of Flame") return true end
        
        -- actions.fs_meta+=/throw_glaive,if=talent.soulscar&talent.furious_throws&active_enemies>1&debuff.essence_break.down
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation and ( GetRemainingSpellCooldown(ids.BladeDance) or CurrentFury > 60 or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) < 5 ) then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 and aura_env.OutOfRange and not IsPlayerSpell(ids.StudentOfSufferingTalent) ) then
            NGSend("Sigil of Flame") return true end
        
        -- actions.fs_meta+=/felblade,if=(buff.out_of_range.down|fury.deficit>40+variable.fury_gen*(0.5%gcd.max))&!buff.inertia.up actions.fs_meta+=/sigil_of_flame,if=debuff.essence_break.down&buff.out_of_range.down
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and aura_env.OutOfRange == true and GetTimeToNextCharge(ids.ImmolationAura) < ( max(GetRemainingSpellCooldown(ids.EyeBeam), GetRemainingAuraDuration("player", ids.MetamorphosisBuff) ) ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.Felblade) and ( ( aura_env.OutOfRange == true or MaxFury - CurrentFury > 40 + Variables.FuryGen * ( 0.5 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) and not PlayerHasBuff(ids.InertiaTriggerBuff) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.ChaosStrike) and FindSpellOverrideByID(ids.ChaosStrike) == ids.Annihilation then
            NGSend("Annihilation") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.FelRush) and ( GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
            
        -- NG ADDED LOW PRIO IMMO AURA FOR SINGLE TARGET!
        if OffCooldown(ids.ImmolationAura) then
            NGSend("Immolation Aura") return true end
        
    end
    
    local Fs = function()
        Variables.FelBarrage = IsPlayerSpell(ids.FelBarrageTalent) and ( GetRemainingSpellCooldown(ids.FelBarrage) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 0 or NearbyEnemies > 2 ) or PlayerHasBuff(ids.FelBarrageBuff) )
        
        if FsCooldown() then return true end
        
        if Variables.FelBarrage then
            return FsFelBarrage() end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > GetTimeToNextCharge(ids.ImmolationAura) ) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( PlayerHasBuff(ids.MetamorphosisBuff) == false or GetRemainingAuraDuration("player", ids.MetamorphosisBuff) > 5 ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( NearbyEnemies > 2 and IsPlayerSpell(ids.RagefireTalent) and TargetHasDebuff(ids.EssenceBreakDebuff) == false ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.Felblade) and ( IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies <= 2 and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.EyeBeam) - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 <= GetRemainingAuraDuration("player", ids.UnboundChaosBuff) or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( IsPlayerSpell(ids.UnboundChaosTalent) and PlayerHasBuff(ids.UnboundChaosBuff) and not IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies > 3 and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.EyeBeam) - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 <= GetRemainingAuraDuration("player", ids.UnboundChaosBuff) ) ) then
            NGSend("Fel Rush") return true end
        
        if PlayerHasBuff(ids.MetamorphosisBuff) then
            return FsMeta() end
        
        if OffCooldown(ids.VengefulRetreat) and ( IsPlayerSpell(ids.InitiativeTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) > 15 and 0 < 0.3 or 0 < 0.2 and GetRemainingSpellCooldown(ids.EyeBeam) <= 0 and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and ( not IsPlayerSpell(ids.StudentOfSufferingTalent) or GetRemainingSpellCooldown(ids.SigilOfFlame) ) and ( GetRemainingSpellCooldown(ids.EssenceBreak) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.SigilOfFlame) or GetRemainingSpellCooldown(ids.EssenceBreak) >= 18 or not IsPlayerSpell(ids.StudentOfSufferingTalent) ) and GetRemainingSpellCooldown(ids.Metamorphosis) > 10 ) then
            NGSend("Vengeful Retreat") return true end
        
        if Variables.FelBarrage or not IsPlayerSpell(ids.DemonBladesTalent) and IsPlayerSpell(ids.FelBarrageTalent) and ( PlayerHasBuff(ids.FelBarrageBuff) or OffCooldown(ids.FelBarrage) ) and PlayerHasBuff(ids.MetamorphosisBuff) == false then
            return FsFelBarrage() end
        
        -- actions.fs+=/felblade,if=!talent.inertia&active_enemies=1&buff.unbound_chaos.up&buff.initiative.up&debuff.essence_break.down&buff.metamorphosis.down actions.fs+=/felblade,if=buff.inertia_trigger.up&talent.inertia&buff.inertia.down&cooldown.blade_dance.remains<4&cooldown.eye_beam.remains>5&cooldown.eye_beam.remains>buff.unbound_chaos.remains-2 actions.fs+=/fel_rush,if=buff.unbound_chaos.up&talent.inertia&buff.inertia.down&cooldown.blade_dance.remains<4&cooldown.eye_beam.remains>5&(action.immolation_aura.charges>0|action.immolation_aura.recharge_time+2<cooldown.eye_beam.remains|cooldown.eye_beam.remains>buff.unbound_chaos.remains-2)
        
        if OffCooldown(ids.ImmolationAura) and ( Variables.FsTier342Piece and ( GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not PlayerHasBuff(ids.ImmolationAuraBuff) and ( GetRemainingSpellCooldown(ids.EyeBeam) < 3 and ( not IsPlayerSpell(ids.EssenceBreak) or GetPlayerStacks(ids.CycleOfHatredBuff) < 4 ) or IsPlayerSpell(ids.EssenceBreak) and GetRemainingSpellCooldown(ids.EssenceBreak) <= 5 or IsPlayerSpell(ids.EssenceBreak) and ( ( GetRemainingSpellCooldown(ids.EyeBeam) < 3 and 1 or 0 ) * GetRemainingSpellCooldown(ids.EssenceBreak) ) > GetTimeToNextCharge(ids.ImmolationAura) ) ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( Variables.FsTier342Piece and ( ( GetRemainingSpellCooldown(ids.EyeBeam) + GetRemainingSpellCooldown(ids.Metamorphosis) ) < 10 ) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( IsPlayerSpell(ids.AFireInsideTalent) and IsPlayerSpell(ids.BurningWoundTalent) and GetTimeToFullCharges(ids.ImmolationAura) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.ImmolationAura) and ( FightRemains(60, NearbyRange) < 15 and GetRemainingSpellCooldown(ids.BladeDance) and IsPlayerSpell(ids.RagefireTalent) ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( IsPlayerSpell(ids.StudentOfSufferingTalent) and ( GetRemainingSpellCooldown(ids.EyeBeam) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or not IsPlayerSpell(ids.InitiativeTalent) ) and ( GetRemainingSpellCooldown(ids.EssenceBreak) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or not IsPlayerSpell(ids.EssenceBreakTalent) ) and ( GetRemainingSpellCooldown(ids.Metamorphosis) > 10 or GetRemainingSpellCooldown(ids.BladeDance) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) ) then
            NGSend("Sigil of Flame") return true end
        
        -- actions.fs+=/eye_beam,if=!talent.essence_break&(!talent.chaotic_transformation|cooldown.metamorphosis.remains<5+3*talent.shattered_destiny|cooldown.metamorphosis.remains>10)&(active_enemies>desired_targets*2|raid_event.adds.in>30-talent.cycle_of_hatred.rank*2.5*buff.cycle_of_hatred.stack)&(!talent.initiative|cooldown.vengeful_retreat.remains>5|cooldown.vengeful_retreat.up&active_enemies>2|talent.shattered_destiny)&(!talent.student_of_suffering|cooldown.sigil_of_flame.remains)
        
        if OffCooldown(ids.EyeBeam) and ( ( not IsPlayerSpell(ids.InitiativeTalent) or PlayerHasBuff(ids.InitiativeBuff) or GetRemainingSpellCooldown(ids.VengefulRetreat) >= 10 or OffCooldown(ids.Metamorphosis) or IsPlayerSpell(ids.InitiativeTalent) and not IsPlayerSpell(ids.TacticalRetreatTalent) ) and ( GetRemainingSpellCooldown(ids.BladeDance) < 7 ) ) then
            NGSend("Eye Beam") return true end
        
        if OffCooldown(ids.Felblade) and ( Variables.FsTier342Piece and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and ( PlayerHasBuff(ids.ImmolationAuraBuff) or GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) <= 0.5 or GetRemainingSpellCooldown(ids.TheHunt) <= 0.5 ) and NearbyEnemies <= 2 ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.FelRush) and ( Variables.FsTier342Piece and IsPlayerSpell(ids.InertiaTalent) and PlayerHasBuff(ids.InertiaTriggerBuff) and ( PlayerHasBuff(ids.ImmolationAuraBuff) or GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or GetRemainingSpellCooldown(ids.TheHunt) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( NearbyEnemies > 2 or GetRemainingSpellCooldown(ids.Felblade) > GetRemainingAuraDuration("player", ids.InertiaTriggerBuff) ) ) then
            NGSend("Fel Rush") return true end
        
        if OffCooldown(ids.EssenceBreak) and ( not IsPlayerSpell(ids.InertiaTalent) and GetRemainingSpellCooldown(ids.EyeBeam) > 5 ) then
            NGSend("Essence Break") return true end
        
        if OffCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 and ( NearbyEnemies > 3 or IsPlayerSpell(ids.ScreamingBrutalityTalent) and IsPlayerSpell(ids.SoulscarTalent) ) ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( Variables.FsTier342Piece and ( PlayerHasBuff(ids.ImmolationAuraBuff) or TargetHasDebuff(ids.EssenceBreak) ) ) then
            NGSend("Chaos Strike") return true end
        
        if OffCooldown(ids.BladeDance) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 ) then
            NGSend("Blade Dance") return true end
        
        if OffCooldown(ids.GlaiveTempest) then
            NGSend("Glaive Tempest") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( NearbyEnemies > 3 and not IsPlayerSpell(ids.StudentOfSufferingTalent) ) then
            NGSend("Sigil of Flame") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( TargetHasDebuff(ids.EssenceBreakDebuff) ) then
            NGSend("Chaos Strike") return true end
        
        -- actions.fs+=/sigil_of_flame,if=talent.student_of_suffering&((cooldown.eye_beam.remains<4&cooldown.metamorphosis.remains>20)|(cooldown.eye_beam.remains<gcd.max&cooldown.metamorphosis.up)) actions.fs+=/felblade,if=buff.out_of_range.up&buff.inertia_trigger.down  actions.fs+=/throw_glaive,if=active_enemies>2&talent.furious_throws&(!talent.screaming_brutality|charges=2|full_recharge_time<cooldown.blade_dance.remains) actions.fs+=/immolation_aura,if=talent.a_fire_inside&talent.isolated_prey&talent.flamebound&active_enemies=1&cooldown.eye_beam.remains>=gcd.max
        
        if OffCooldown(ids.Felblade) and ( MaxFury - CurrentFury > 40 + Variables.FuryGen * ( 0.5 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and ( GetRemainingSpellCooldown(ids.VengefulRetreat) >= GetSpellBaseCooldown(ids.Felblade)/1000 + 0.5 and IsPlayerSpell(ids.InertiaTalent) and NearbyEnemies == 1 or not IsPlayerSpell(ids.InertiaTalent) or IsPlayerSpell(ids.ArtOfTheGlaiveTalent) or GetRemainingSpellCooldown(ids.EssenceBreak) ) and GetRemainingSpellCooldown(ids.Metamorphosis) and GetRemainingSpellCooldown(ids.EyeBeam) >= 0.5 + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * (( IsPlayerSpell(ids.StudentOfSufferingTalent) and GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and 1 or 0) and ( not Variables.FsTier342Piece or Variables.FsTier342Piece and not PlayerHasBuff(ids.ImmolationAuraBuff) and not OffCooldown(ids.ImmolationAura) ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.ChaosStrike) and ( GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 or ( CurrentFury >= 70 - 30 * (( IsPlayerSpell(ids.StudentOfSufferingTalent) and ( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) ) and 1 or 0) - (PlayerHasBuff(ids.ChaosTheoryBuff) and 1 or 0) * 20 - Variables.FuryGen ) ) then
            NGSend("Chaos Strike") return true end
        
        -- actions.fs+=/chaos_strike,if=cooldown.eye_beam.remains>=gcd.max*3|(fury>=70+(talent.untethered_fury*50-20*talent.blind_fury.rank)*hero_tree.felscarred-38*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=gcd.max|cooldown.sigil_of_flame.up))-buff.chaos_theory.up*20-variable.fury_gen) actions.fs+=/chaos_strike,if=cooldown.eye_beam.remains>=gcd.max*2|(cooldown.eye_beam.remains>=gcd+gcd.max*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=5|cooldown.sigil_of_flame.up))&(fury>=70-20*talent.blind_fury.rank-38*(talent.student_of_suffering&(cooldown.sigil_of_flame.remains<=gcd.max|cooldown.sigil_of_flame.up))-(talent.essence_break&talent.inertia&cooldown.felblade.up*40)-variable.fury_gen*2))
        
        if OffCooldown(ids.ImmolationAura) and ( not Variables.FsTier342Piece and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 1 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) and (( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) and 1 or 0) ) or NearbyEnemies > 2 ) then
            NGSend("Immolation Aura") return true end
        
        if OffCooldown(ids.Felblade) and ( aura_env.OutOfRange == true and PlayerHasBuff(ids.InertiaTriggerBuff) == false and GetRemainingSpellCooldown(ids.EyeBeam) >= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 1 + (IsPlayerSpell(ids.StudentOfSufferingTalent) and 1 or 0) and ( GetRemainingSpellCooldown(ids.SigilOfFlame) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or OffCooldown(ids.SigilOfFlame) ) ) ) then
            NGSend("Felblade") return true end
        
        if OffCooldown(ids.SigilOfFlame) and ( aura_env.OutOfRange == true and TargetHasDebuff(ids.EssenceBreakDebuff) == false and not IsPlayerSpell(ids.StudentOfSufferingTalent) and ( not IsPlayerSpell(ids.FelBarrageTalent) or GetRemainingSpellCooldown(ids.FelBarrage) > 25 ) ) then
            NGSend("Sigil of Flame") return true end
        
        -- actions.fs+=/felblade,if=cooldown.blade_dance.remains>=0.5&cooldown.blade_dance.remains<gcd.max actions.fs+=/demons_bite
        
        if OffCooldown(ids.DemonsBite) and not IsPlayerSpell(ids.DemonBladesTalent) then
            NGSend("Demons Bite") return true end
        
        if OffCooldown(ids.ThrowGlaive) and ( GetTimeToNextCharge(ids.ThrowGlaive) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.ThrowGlaive) > 1.01 ) and aura_env.OutOfRange == true and NearbyEnemies > 1 and not IsPlayerSpell(ids.FuriousThrowsTalent) ) then
            NGSend("Throw Glaive") return true end
        
        if OffCooldown(ids.FelRush) and ( PlayerHasBuff(ids.UnboundChaosBuff) == false and GetTimeToNextCharge(ids.FelRush) < GetRemainingSpellCooldown(ids.EyeBeam) and TargetHasDebuff(ids.EssenceBreakDebuff) == false and ( GetRemainingSpellCooldown(ids.EyeBeam) > 8 or GetSpellChargesFractional(ids.FelRush) > 1.01 ) and NearbyEnemies > 1 ) then
            NGSend("Fel Rush") return true end
    end
    
    -- Separate actionlists for each hero tree
    if IsPlayerSpell(ids.ArtOfTheGlaiveTalent) then
        if Ar() then return true end end
    
    if IsPlayerSpell(ids.DemonsurgeTalent) then
        if Fs() then return true end end
    
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
    aura_env.LastDeathSweep = GetTime()
    
    -- Consumed Demonsurge explosion.
    if spellID == aura_env.ids.Annihilation then
        aura_env.DemonsurgeAnnihilationBuff = false
    elseif spellID == aura_env.ids.ConsumingFire then
        aura_env.DemonsurgeConsumingFireBuff = false
    elseif spellID == aura_env.ids.DeathSweep then
        aura_env.DemonsurgeDeathSweepBuff = false
    elseif spellID == aura_env.ids.AbyssalGaze then
        aura_env.DemonsurgeAbyssalGazeBuff = false
    elseif spellID == aura_env.ids.SigilOfDoom then
        aura_env.DemonsurgeSigilOfDoomBuff = false
    end
    
    if spellID == aura_env.ids.Metamorphosis then
        aura_env.DemonsurgeAbyssalGaze = true
        aura_env.DemonsurgeAnnihilationBuff = true
        aura_env.DemonsurgeConsumingFireBuff = true
        aura_env.DemonsurgeDeathSweepBuff = true
        aura_env.DemonsurgeSigilOfDoomBuff = true
        return
    end
    
    if spellID == aura_env.ids.ReaversGlaive then
        aura_env.ReaversGlaiveLastUsed = GetTime()
    end
    
    return
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Core3--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- CLEU:SPELL_AURA_APPLIED

function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    if sourceGUID ~= UnitGUID("player") then return false end
    
    if destGUID == aura_env.ids.MetamorphosisBuff and IsPlayerSpell(ids.Demonsurge) then
        -- aura_env.DemonsurgeAbyssalGaze = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeAnnihilationBuff = true
        -- aura_env.DemonsurgeConsumingFireBuff = true Only when manually casting Metamorphosis
        aura_env.DemonsurgeDeathSweepBuff = true
    end
    return
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()
aura_env.FurtherEnemies = 0
aura_env.NearbyEnemies = 0

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
    DisorientingStrikesTalent = 441274,
    DoubleJeopardyTalent = 454430,
    FanTheHammerTalent = 381846,
    FanTheHammerTalentNode = 90666,
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
    SubterfugeTalent = 108208,
    SuperchargerTalent = 470347,
    SurprisingStrikesTalent = 441273,
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
    -- Kichi -- 
    KillingSpreeBuff = 51690,
}

aura_env.GetSpellCooldown = function(spellId)
    local spellCD = C_Spell.GetSpellCooldown(spellId)
    local spellCharges = C_Spell.GetSpellCharges(spellId)
    if spellCharges then
        local rechargeTime = (spellCharges.currentCharges < spellCharges.maxCharges) and (spellCharges.cooldownStartTime + spellCharges.cooldownDuration - GetTime()) or 0
        return spellCharges.currentCharges, rechargeTime, spellCharges.maxCharges
    elseif spellCD then
        local remainingCD = (spellCD.startTime and spellCD.duration) and math.max(spellCD.startTime + spellCD.duration - GetTime(), 0) or 0
        return 0, remainingCD, 0
    else
        return 0, 0, 0
    end
end

aura_env.GetSafeSpellIcon = function(spellId)
    if not spellId or spellId == 0 then
        return 0  
    end
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    return spellInfo and spellInfo.iconID or 0
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Trig ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function(allstates, event, spellID, customData)
    
    local ids = aura_env.ids
    local GetSpellCooldown = aura_env.GetSpellCooldown
    local GetSafeSpellIcon = aura_env.GetSafeSpellIcon
    local firstPriority = nil
    local firstIcon = 0
    local firstCharges, firstCD, firstMaxCharges = 0, 0, 0

    if spellID and spellID ~= "Clear" then
        -- print(spellID)
        local key = spellID:gsub(" (%a)", function(c) return c:upper() end):gsub(" ", "")
        firstPriority = ids[key]
        firstIcon = GetSafeSpellIcon(firstPriority)
        firstCharges, firstCD, firstMaxCharges = GetSpellCooldown(firstPriority)
    end

    if spellID == "Clear" then
        firstIcon = 0
        firstCharges, firstCD, firstMaxCharges = 0, 0, 0
    end
    -- 更新 allstates
    allstates[1] = {
        show = true,
        changed = true,
        icon = firstIcon,
        spell = firstPriority,
        cooldown = firstCD,
        charges = firstCharges,
        maxCharges = firstMaxCharges
    }
    
    return true
end



function()
    if aura_env.NearbyEnemies and aura_env.FurtherEnemies then
        if aura_env.NearbyEnemies <= 8 then
            return aura_env.NearbyEnemies.." / "..aura_env.FurtherEnemies
        else return "8 / "..aura_env.FurtherEnemies
        end
    end
end