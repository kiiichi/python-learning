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
    ArcingCleaveTalent = 231564,
    ArcaneTempoTalent = 383980,
    ArcaneHarmonyTalent = 384452,
    ChargedOrbTalent = 384651,
    ConsortiumsBaubleTalent = 461260,
    EnlightenedTalent = 321387,
    ImpetusTalent = 383676,
    LeydrinkerTalent = 452196,
    MagisSparkTalent = 454016,
    SplinteringSorceryTalent = 443739,
    HighVoltageTalent = 461248,
    ShiftingShardsTalent = 444675,
    OrbBarrageTalent = 384858,
    ResonanceTalent = 205028,
    ReverberateTalent = 281482,
    SpellfireSpheresTalent = 448601,
    TimeLoopTalent = 452924,
    
    -- Buffs
    AetherAttunementBuff = 453601,
    AethervisionBuff = 467634,
    ArcaneHarmonyBuff = 384455,
    ArcaneSurgeBuff = 365362,
    ArcaneTempoBuff = 383997,
    ClearcastingBuff = 263725,
    LeydrinkerBuff = 453758,
    NetherPrecisionBuff = 383783,
    -- Kichi fix this id beacause it is wrong --
    IntuitionBuff = 1223797,
    UnerringProficiencyBuff = 444981,
    SiphonStormBuff = 384267,
    BurdenOfPowerBuff = 451049,
    GloriousIncandescenceBuff = 451073,
    ArcaneSoulBuff = 451038,
    TouchOfTheMagiDebuff = 210824,
}

---- Utility Functions ----------------------------------------------------------------------------------------
aura_env.OutOfRange = false

-- Kichi --
-- Kichi --
aura_env.KTrig = function(Name, ...)

    -- Update to check if the spell power is enough --
    local spellID = aura_env.ids[Name:gsub(" (%a)", function(c) return c:upper() end):gsub(" ", "")]
    local _, insufficientPower = C_Spell.IsSpellUsable(spellID)

    WeakAuras.ScanEvents("K_TRIGED", Name, insufficientPower, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    if aura_env.FlagKTrigCD then
        WeakAuras.ScanEvents("K_TRIGED_CD", "Clear", ...)
    end
    aura_env.FlagKTrigCD = flase
end

aura_env.KTrigCD = function(Name, ...)

    WeakAuras.ScanEvents("K_TRIGED_CD", Name, ...)
    WeakAuras.ScanEvents("K_OUT_OF_RANGE", aura_env.OutOfRange)
    aura_env.FlagKTrigCD = false
end

aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    -- Kichi --
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    if (not usable) or nomana then return false end
    
    -- Kichi --
    -- local Duration = C_Spell.GetSpellCooldown(spellID).duration
    -- local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration()
    local Cooldown = C_Spell.GetSpellCooldown(spellID)
    local Duration = Cooldown.duration
    local Remaining = Cooldown.startTime + Duration - GetTime()
    local OffCooldown = Duration == nil or Duration == 0 or Duration == WeakAuras.gcdDuration() or (Remaining <= WeakAuras.gcdDuration())

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

-- Kichi --
aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    local duration = aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
    if duration == nil then duration = 0 end
    return duration
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

-- Kichi --
aura_env.FullGCD = function()
    local baseGCD = 1.5
    local FullGCDnum = math.max(1, baseGCD / (1 + UnitSpellHaste("player") / 100 ))
    return FullGCDnum
end

aura_env.TalentRank = function(nodeID)
    -- Need Kichi‘s custom WA to get the nodeID, it's not the spellID.
    local configID = C_ClassTalents.GetActiveConfigID()
    if configID then
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
        if nodeInfo and nodeInfo.currentRank then
            -- print("天赋层数:", nodeInfo.currentRank)
            return nodeInfo.currentRank
        end
    end
    if nodeInfo == nil then return 0 end
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
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    local FullGCD = aura_env.FullGCD
    local TalentRank = aura_env.TalentRank
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------     
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1872)
    
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
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Variables = {}
    Variables.AoeTargetCount = 2
    
    if not IsPlayerSpell(ids.ArcingCleaveTalent) then
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
    
    local CdOpener = function()
        -- Kichi remove (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) because use TouchOfTheMagi macro --
        -- Touch of the Magi used when Arcane Barrage is mid-flight or if you just used Arcane Surge and you don't have 4 Arcane Charges, the wait simulates the time it takes to queue another spell after Touch when you Surge into Touch, throws up Touch as soon as possible even without Barraging first if it's ready for miniburn.
        if OffCooldown(ids.TouchOfTheMagi) and ( true and ( GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) > 5 or IsCasting(ids.ArcaneSurge) or GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 ) or ( (aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge)) and (CurrentArcaneCharges < 4 or NetherPrecisionStacks == 0 )) or ( GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 and OffCooldown(ids.TouchOfTheMagi) and CurrentArcaneCharges < 4 and not (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) ) ) then
            -- KTrig("Touch Of The Magi") return true end
            if aura_env.config[tostring(ids.TouchOfTheMagi)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Touch Of The Magi")
            elseif aura_env.config[tostring(ids.TouchOfTheMagi)] ~= true then
                KTrig("Touch Of The Magi")
                return true
            end
        end
        
        if OffCooldown(ids.ArcaneBlast) and ( PlayerHasBuff(ids.PresenceOfMind) ) then
            KTrig("Arcane Blast") return true end
        
        -- Use Orb for Charges on the opener if you have High Voltage as the Missiles will generate the remaining Charge you need
        if OffCooldown(ids.ArcaneOrb) and ( IsPlayerSpell(ids.HighVoltageTalent) and Variables.Opener and not aura_env.UsedOrb ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        -- Barrage before Evocation if Tempo will expire
        if OffCooldown(ids.ArcaneBarrage) and Variables.Opener and not aura_env.UsedBarrage and ( PlayerHasBuff(ids.ArcaneTempoBuff) and OffCooldown(ids.Evocation) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 5 ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.Evocation) and ( GetRemainingSpellCooldown(ids.ArcaneSurge) < (max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 5 ) then
            -- KTrig("Evocation") return true end
            if aura_env.config[tostring(ids.Evocation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Evocation")
            elseif aura_env.config[tostring(ids.Evocation)] ~= true then
                KTrig("Evocation")
                return true
            end
        end
        
        -- Use Missiles to get Nether Precision up for your opener and to spend Aether Attunement if you have 4pc S2 set before Surging, clipping logic now applies to Aether Attunement in AOE when you have Time Loop talented and not Resonance.
        if OffCooldown(ids.ArcaneMissiles) and not aura_env.UsedMissiles and ( (((aura_env.PrevCast == ids.Evocation or IsCasting(ids.Evocation)) or (aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge))) or Variables.Opener ) and NetherPrecisionStacks == 0 and (not PlayerHasBuff(ids.AetherAttunementBuff) or SetPieces >= 4 ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Kichi modify this via add "or TargetHasDebuff(ids.TouchOfTheMagiDebuff)" to fix if good luck to get ArcaneSurge --
        if OffCooldownNotCasting(ids.ArcaneSurge) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < ( max(C_Spell.GetSpellInfo(ids.ArcaneSurge).castTime/1000, WeakAuras.gcdDuration()) + ( max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( (CurrentArcaneCharges == 4) and 1 or 0 ) ) ) or TargetHasDebuff(ids.TouchOfTheMagiDebuff) ) then
            -- KTrig("Arcane Surge") return true end
            if aura_env.config[tostring(ids.ArcaneSurge)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Surge")
            elseif aura_env.config[tostring(ids.ArcaneSurge)] ~= true then
                KTrig("Arcane Surge")
                return true
            end
        end

    end
    
    local Spellslinger = function()
        -- With Shifting Shards we can use Shifting Power whenever basically favoring cooldowns slightly, without it though we want to use it outside of cooldowns, don't cast if it'll conflict with Intuition expiration.
        if OffCooldown(ids.ShiftingPower) and ( ( ( ( ( ( C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges == (IsPlayerSpell(ids.ChargedOrbTalent) and 1 or 0) ) and GetRemainingSpellCooldown(ids.ArcaneOrb) ) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 23 ) and PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > ( 12 + 6 * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) or 
        ( (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) and IsPlayerSpell(ids.ShiftingShardsTalent) and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and ( PlayerHasBuff(ids.ArcaneSurgeBuff) or TargetHasDebuff(ids.TouchOfTheMagiDebuff) or GetRemainingSpellCooldown(ids.Evocation) < 20 ) ) ) and 
        FightRemains(60, NearbyRange) > 10 and ( GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2.5 or PlayerHasBuff(ids.ArcaneTempoBuff) == false ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power")
                return true
            end
        end

        if OffCooldown(ids.Supernova) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and GetPlayerStacks(ids.UnerringProficiencyBuff) == 30 ) then
            -- KTrig("Supernova") return true end
            if aura_env.config[tostring(ids.Supernova)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Supernova")
            elseif aura_env.config[tostring(ids.Supernova)] ~= true then
                KTrig("Supernova")
                return true
            end
        end
        
        -- Barrage if Tempo or Intuition are about to expire, for Tempo, you can Barrage a little earlier if you have Nether Precision.
        if OffCooldown(ids.ArcaneBarrage) and ( ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < (max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) + (max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 * ((NetherPrecisionStacks == 1) and 1 or 0)))) or ( PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Barrage if Harmony is over 18 stacks, or 12 with High Voltage and either no Nether Precision or your last stack of it.
        if OffCooldown(ids.ArcaneBarrage) and ( GetPlayerStacks(ids.ArcaneHarmonyBuff) >= ( 18 - ( 6 * (IsPlayerSpell(ids.HighVoltageTalent) and 1 or 0) ) ) and ( NetherPrecisionStacks == 0 or NetherPrecisionStacks == 1 or (NearbyEnemies > 3 and PlayerHasBuff(ids.ClearcastingBuff) and IsPlayerSpell(ids.HighVoltageTalent)) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Use Aether Attunement up before casting Touch if you have S2 4pc equipped to avoid munching.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 and PlayerHasBuff(ids.ClearcastingBuff) and (SetPieces >= 4) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Kichi use micro to instead --
        -- -- Barrage if Touch is up or will be up while Barrage is in the air.
        -- if OffCooldown(ids.ArcaneBarrage) and ( ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 50 ), max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) ) then
        --     KTrig("Arcane Barrage") return true end

        -- Barrage in AOE if you can refund Charges through High Voltage as soon as possible if you have Aether Attunement and Nether Precision up.
        if OffCooldown(ids.ArcaneBarrage) and ( IsPlayerSpell(ids.HighVoltageTalent) and IsPlayerSpell(ids.OrbBarrageTalent) and CurrentArcaneCharges > 1 and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) and ( NetherPrecisionStacks == 1 or ( (NetherPrecisionStacks > 0) and NearbyEnemies > 1 ) or ( ( (NetherPrecisionStacks > 0) or ( GetPlayerStacks(ids.ClearcastingBuff) < 3 and not PlayerHasBuff(ids.IntuitionBuff) ) ) and NearbyEnemies > 3 ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Use Clearcasting procs to keep Nether Precision up, if you don't have S2 4pc try to pool Aether Attunement for cooldown windows.
        if OffCooldown(ids.ArcaneMissiles) and ( ( PlayerHasBuff(ids.ClearcastingBuff) and (NetherPrecisionStacks == 0) and ( ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 and GetRemainingSpellCooldown(ids.ArcaneSurge) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 7 ) or GetPlayerStacks(ids.ClearcastingBuff) > 1 or not IsPlayerSpell(ids.MagisSparkTalent) or ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 and GetPlayerStacks(ids.AetherAttunementBuff) == 0 ) or (SetPieces >= 4) ) ) or ( FightRemains(60, NearbyRange) < 5 and PlayerHasBuff(ids.ClearcastingBuff) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Blast whenever you have the bonus from Leydrinker or Magi's Spark up, don't let spark expire in AOE.
        if OffCooldown(ids.ArcaneBlast) and ( ( ( aura_env.NeedArcaneBlastSpark and ( ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( (C_Spell.GetSpellInfo(ids.ArcaneBlast).castTime/1000) + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) or NearbyEnemies <= 1 or IsPlayerSpell(ids.LeydrinkerTalent) ) ) or PlayerHasBuff(ids.LeydrinkerBuff) ) and CurrentArcaneCharges == 4 and not IsPlayerSpell(ids.ChargedOrbTalent) and NearbyEnemies < 3 ) then
            KTrig("Arcane Blast") return true end
        
        -- Barrage in AOE with Orb Barrage under some minor restrictions if you can recoup Charges, pooling for Spark as Touch comes off cooldown.
        if OffCooldown(ids.ArcaneBarrage) and ( IsPlayerSpell(ids.OrbBarrageTalent) and NearbyEnemies > 1 and ( aura_env.NeedArcaneBlastSpark == false or not IsPlayerSpell(ids.MagisSparkTalent) ) and CurrentArcaneCharges == 4 and ( ( IsPlayerSpell(ids.HighVoltageTalent) and NearbyEnemies > 2 ) or ( ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 6 or not IsPlayerSpell(ids.MagisSparkTalent) ) or ( IsPlayerSpell(ids.ChargedOrbTalent) and GetSpellChargesFractional(ids.ArcaneOrb) > 1.8 ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Barrage in AOE if Orb is up or enemy is in execute range.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 1 and ( aura_env.NeedArcaneBlastSpark == false or not IsPlayerSpell(ids.MagisSparkTalent) ) and CurrentArcaneCharges == 4 and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) ) ) and ( NetherPrecisionStacks == 1 or ( (NetherPrecisionStacks == 0) and IsPlayerSpell(ids.HighVoltageTalent) ) or ( NetherPrecisionStacks == 2 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) and IsPlayerSpell(ids.HighVoltageTalent) ) ) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 6 or ( IsPlayerSpell(ids.ChargedOrbTalent) and GetSpellChargesFractional(ids.ArcaneOrb) > 1.8 ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Missile to refill charges if you have High Voltage and either Aether Attunement or more than one Clearcasting proc.
        if OffCooldown(ids.ArcaneMissiles) and ( IsPlayerSpell(ids.HighVoltageTalent) and ( GetPlayerStacks(ids.ClearcastingBuff) > 1 or ( PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) ) ) and CurrentArcaneCharges < 3 ) then
            KTrig("Arcane Missiles") return true end
        
        -- Orb below 3 charges in single target, at 0 charges, or 1 or 0 charge with High Voltage.
        if OffCooldown(ids.ArcaneOrb) and ( ( NearbyEnemies <= 1 and CurrentArcaneCharges < 3 ) or ( CurrentArcaneCharges < 1 or ( CurrentArcaneCharges < 2 and IsPlayerSpell(ids.HighVoltageTalent) ) ) ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.IntuitionBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Barrage in single target if you have High Voltage, last Nether Precision stack, Clearcasting and either Aether or Execute.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies <= 1 and IsPlayerSpell(ids.HighVoltageTalent) and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 and ( PlayerHasBuff(ids.AetherAttunementBuff) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Barrage if you have orb ready and either Orb Barrage or High Voltage, pool for Spark.
        if OffCooldown(ids.ArcaneBarrage) and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and CurrentArcaneCharges == 4 and (NetherPrecisionStacks == 0) and IsPlayerSpell(ids.OrbBarrageTalent) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 6 or not IsPlayerSpell(ids.MagisSparkTalent) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Barrage with Orb Barrage or execute if you have orb up and no Nether Precision or no way to get another.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies <= 1 and ( IsPlayerSpell(ids.OrbBarrageTalent) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) ) ) and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and CurrentArcaneCharges == 4 and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 6 or not IsPlayerSpell(ids.MagisSparkTalent) ) and ( (NetherPrecisionStacks == 0) or ( NetherPrecisionStacks == 1 and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Kichi add distance check for Arcane Explosion
        -- Use Explosion for your first charge or if you have High Voltage you can use it for charge 2 and 3, but at a slightly higher target count.
        if OffCooldown(ids.ArcaneExplosion) and WeakAuras.CheckRange("target", 10, "<=") and ( NearbyEnemies > 1 and ( ( CurrentArcaneCharges < 1 and not IsPlayerSpell(ids.HighVoltageTalent) ) or ( CurrentArcaneCharges < 3 and ( GetPlayerStacks(ids.ClearcastingBuff) == 0 or IsPlayerSpell(ids.ReverberateTalent) ) ) ) ) then   
            KTrig("Arcane Explosion") return true end

        -- Kichi add distance check for Arcane Explosion
        -- Arcane Explosion in single target for your first 2 charges when you have no Clearcasting procs and aren't out of mana.
        if OffCooldown(ids.ArcaneExplosion) and WeakAuras.CheckRange("target", 10, "<=") and ( NearbyEnemies == 1 and CurrentArcaneCharges < 2 and not PlayerHasBuff(ids.ClearcastingBuff) and (CurrentMana/MaxMana*100) > 10 ) then
            KTrig("Arcane Explosion") return true end
        
        -- Barrage in execute if you're at the end of Touch or at the end of Surge windows.
        if OffCooldown(ids.ArcaneBarrage) and ( ( ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 1.25 ) ) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) > 0.75 ) ) or ( ( GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) and PlayerHasBuff(ids.ArcaneSurgeBuff) ) ) and CurrentArcaneCharges == 4 ) then
            KTrig("Arcane Barrage") return true end
            
        -- Nothing else to do? Blast. Out of mana? Barrage.
        if OffCooldown(ids.ArcaneBlast) then
            KTrig("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            KTrig("Arcane Barrage") return true end
    end
    
    local Sunfury = function()
        -- For Sunfury, Shifting Power only when you're not under the effect of any cooldowns.
        if OffCooldown(ids.ShiftingPower) and ( ( ( PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and GetRemainingSpellCooldown(ids.Evocation) > 15 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > 10 ) and FightRemains(60, NearbyRange) > 10 ) and PlayerHasBuff(ids.ArcaneSoulBuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power")
                return true
            end
        end

        -- When Arcane Soul is up, use Missiles to generate Nether Precision as needed while also ensuring you end Soul with 3 Clearcasting.
        if OffCooldown(ids.ArcaneMissiles) and ( (NetherPrecisionStacks == 0) and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.ArcaneSoulBuff) and GetRemainingAuraDuration("player", ids.ArcaneSoulBuff) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 4 - (PlayerHasBuff(ids.ClearcastingBuff) and 1 or 0) ) ) then
            KTrig("Arcane Missiles") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.ArcaneSoulBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Prioritize Tempo and Intuition if they are about to expire, spend Aether Attunement if you have 4pc S2 set before Touch.
        if OffCooldown(ids.ArcaneBarrage) and ( ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) or ( PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsPlayerSpell(ids.OrbBarrageTalent) and NearbyEnemies > 1 and GetPlayerStacks(ids.ArcaneHarmonyBuff) >= 18 and ( ( NearbyEnemies > 3 and ( IsPlayerSpell(ids.ResonanceTalent) or IsPlayerSpell(ids.HighVoltageTalent) ) ) or (NetherPrecisionStacks == 0) or NetherPrecisionStacks == 1 or ( NetherPrecisionStacks == 2 and GetPlayerStacks(ids.ClearcastingBuff) == 3 ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and (SetPieces >= 4) and PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * ( 3 - ( 1.5 * ( NearbyEnemies > 3 and ( not IsPlayerSpell(ids.TimeLoopTalent) or IsPlayerSpell(ids.ResonanceTalent) ) ) ) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Blast whenever you have the bonus from Leydrinker or Magi's Spark up, don't let spark expire in AOE.
        if OffCooldown(ids.ArcaneBlast) and ( ( ( aura_env.NeedArcaneBlastSpark and ( ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( (C_Spell.GetSpellInfo(ids.ArcaneBlast).castTime/1000) + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) or NearbyEnemies <= 1 or IsPlayerSpell(ids.LeydrinkerTalent) ) ) or PlayerHasBuff(ids.LeydrinkerBuff) ) and CurrentArcaneCharges == 4 and ( (NetherPrecisionStacks > 0) or GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) then
            KTrig("Arcane Blast") return true end
        
        -- Barrage into Touch if you have charges when it comes up.
        if OffCooldown(ids.ArcaneBarrage) and ( CurrentArcaneCharges == 4 and ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 50 ), max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) ) then
            KTrig("Arcane Barrage") return true end

        -- AOE Barrage conditions are optimized for funnel, avoids overcapping Harmony stacks (line below Tempo line above), spending Charges when you have a way to recoup them via High Voltage or Orb while pooling sometimes for Touch with various talent optimizations.
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsPlayerSpell(ids.HighVoltageTalent) and NearbyEnemies > 1 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 1 and IsPlayerSpell(ids.HighVoltageTalent) and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) and PlayerHasBuff(ids.GloriousIncandescenceBuff) == false and PlayerHasBuff(ids.IntuitionBuff) == false ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 2 and IsPlayerSpell(ids.OrbBarrageTalent) and IsPlayerSpell(ids.HighVoltageTalent) and not aura_env.NeedArcaneBlastSpark and CurrentArcaneCharges == 4 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) and ( (NetherPrecisionStacks > 0) or ( (NetherPrecisionStacks == 0) and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( ( NearbyEnemies > 2 or ( NearbyEnemies > 1 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsPlayerSpell(ids.ArcaneBombardmentTalent) ) ) and GetRemainingSpellCooldown(ids.ArcaneOrb) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 6 and ( not aura_env.NeedArcaneBlastSpark or not IsPlayerSpell(ids.MagisSparkTalent) ) and (NetherPrecisionStacks > 0) and ( IsPlayerSpell(ids.HighVoltageTalent) or NetherPrecisionStacks == 2 or ( NetherPrecisionStacks == 1 and not PlayerHasBuff(ids.ClearcastingBuff) ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Missiles to recoup Charges, maintain Nether Precisioin, or keep from overcapping Clearcasting with High Voltage or in single target.
        if OffCooldown(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and ( ( IsPlayerSpell(ids.HighVoltageTalent) and CurrentArcaneCharges < 4 ) or (NetherPrecisionStacks == 0) or ( GetPlayerStacks(ids.ClearcastingBuff) == 3 and ( not IsPlayerSpell(ids.HighVoltageTalent) or NearbyEnemies <= 1 ) ) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Barrage with Burden if 2-4 targets and you have a way to recoup Charges, however skip this is you have Bauble and don't have High Voltage.
        if OffCooldown(ids.ArcaneBarrage) and ( ( CurrentArcaneCharges == 4 and NearbyEnemies > 1 and NearbyEnemies < 5 and PlayerHasBuff(ids.BurdenOfPowerBuff) and ( ( IsPlayerSpell(ids.HighVoltageTalent) and PlayerHasBuff(ids.ClearcastingBuff) ) or PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) or ( GetRemainingSpellCooldown(ids.ArcaneOrb) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) or C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges > 0 ) ) ) and ( not IsPlayerSpell(ids.ConsortiumsBaubleTalent) or IsPlayerSpell(ids.HighVoltageTalent) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Arcane Orb to recover Charges quickly if below 3.
        if OffCooldown(ids.ArcaneOrb) and ( CurrentArcaneCharges < 3 ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        -- Barrage with Intuition or Incandescence unless Touch is almost up or you don't have Magi's Spark talented.
        if OffCooldown(ids.ArcaneBarrage) and ( ( PlayerHasBuff(ids.GloriousIncandescenceBuff) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > 6 or not IsPlayerSpell(ids.MagisSparkTalent) ) ) or PlayerHasBuff(ids.IntuitionBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- In AOE, Presence of Mind is used to build Charges. Arcane Explosion can be used to build your first Charge.
        --if OffCooldown(ids.PresenceOfMind) and ( ( CurrentArcaneCharges == 3 or CurrentArcaneCharges == 2 ) and NearbyEnemies >= 3 ) then
        --    KTrig("Presence Of Mind") return true end
        
        if OffCooldown(ids.ArcaneExplosion) and ( CurrentArcaneCharges < 2 and NearbyEnemies > 1 ) then
            KTrig("Arcane Explosion") return true end
        
        if OffCooldown(ids.ArcaneBlast) then
            KTrig("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            KTrig("Arcane Barrage") return true end
    end
    
    if OffCooldown(ids.ArcaneBarrage) and ( FightRemains(60, NearbyRange) < 2 ) then
        KTrig("Arcane Barrage") return true end
    
    -- Enter cooldowns, then action list depending on your hero talent choices
    if CdOpener() then return true end
    
    if IsPlayerSpell(ids.SpellfireSpheresTalent) then
        if Sunfury() then return true end end
    
    if not IsPlayerSpell(ids.SpellfireSpheresTalent) then
        if Spellslinger() then return true end end
    
    if OffCooldown(ids.ArcaneBarrage) then
        KTrig("Arcane Barrage") return true end

    -- Kichi --
    KTrig("Clear")
    -- KTrigCD("Clear")

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

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------Rotation Load ----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

WeakAuras.WatchGCD()

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
    ArcingCleaveTalent = 231564,
    ArcaneTempoTalent = 383980,
    ArcaneHarmonyTalent = 384452,
    ChargedOrbTalent = 384651,
    ConsortiumsBaubleTalent = 461260,
    EnlightenedTalent = 321387,
    ImpetusTalent = 383676,
    LeydrinkerTalent = 452196,
    MagisSparkTalent = 454016,
    SplinteringSorceryTalent = 443739,
    HighVoltageTalent = 461248,
    ShiftingShardsTalent = 444675,
    OrbBarrageTalent = 384858,
    ResonanceTalent = 205028,
    ReverberateTalent = 281482,
    SpellfireSpheresTalent = 448601,
    TimeLoopTalent = 452924,
    
    -- Buffs
    AetherAttunementBuff = 453601,
    AethervisionBuff = 467634,
    ArcaneHarmonyBuff = 384455,
    ArcaneSurgeBuff = 365362,
    ArcaneTempoBuff = 383997,
    ClearcastingBuff = 263725,
    LeydrinkerBuff = 453758,
    NetherPrecisionBuff = 383783,
    -- Kichi fix this id beacause it is wrong --
    IntuitionBuff = 1223797,
    UnerringProficiencyBuff = 444981,
    SiphonStormBuff = 384267,
    BurdenOfPowerBuff = 451049,
    GloriousIncandescenceBuff = 451073,
    ArcaneSoulBuff = 451038,
    TouchOfTheMagiDebuff = 210824,
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
