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

aura_env.RTBContainerExpires = 0
aura_env.DisorientingStrikesCount = 0

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

-- Kichi --
aura_env.OffCooldown = function(spellID)
    if spellID == nil then
        local c = a < b -- Throw an error
    end
    
    if not IsPlayerSpell(spellID) then return false end
    -- Kichi --
    -- if aura_env.config[tostring(spellID)] == false then return false end
    
    local usable, nomana = C_Spell.IsSpellUsable(spellID)
    -- Kichi only for outlaw killing spree --
    -- if (not usable) and (not nomana) then return false end
    if (not usable) and not(WA_GetUnitBuff("player", 51690) ~= nil) and (not nomana) then return false end
    
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

aura_env.IsAuraRefreshable = function(SpellID, Unit, Filter)
    -- Kichi --
    -- local Filter = ""
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

-- Kichi --
aura_env.GetRemainingDebuffDuration = function(unit, spellID)
    local duration = aura_env.GetRemainingAuraDuration(unit, spellID, "HARMFUL|PLAYER")
    if duration == nil then duration = 0 end
    return duration
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
    -- Kichi for custom variables --
    local BFHeadsup = 1 -- How many seconds before the expiration of the Blade Flurry buff should the Blade Flurry icon glow: from 0 to 3, default 1.
    local BRKSEnergy = 50 -- How low your energy must for the aura to recommend Blade Rush: from 0 to 100, default 50.
    local ThistleTeaEnergy = 50 -- How low your energy must for the aura to recommend Thistle Tea: from 0 to 200, default 50.
    
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
    local HasDisorientingStrikes = aura_env.DisorientingStrikesCount > 0
    
    -- Kichi --
    local NearbyEnemies = 0
    local NearbyRange = 8
    local FurtherEnemies = 0
    local FurtherRange = 12
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and UnitIsFriend("player", unit) == false and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
        if UnitExists(unit) and UnitIsFriend("player", unit) == false and WeakAuras.CheckRange(unit, FurtherRange, "<=") then
            FurtherEnemies = FurtherEnemies + 1
        end
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_FURTHER_ENEMIES", FurtherEnemies)

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
    
    -- -- RangeChecker (Melee)
    -- if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    Variables.AmbushCondition = ( IsPlayerSpell(ids.HiddenOpportunityTalent) or MaxComboPoints - CurrentComboPoints >= 2 + (IsPlayerSpell(ids.ImprovedAmbushTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) and CurrentEnergy >= 50
    
    -- Use finishers if at -1 from max combo points, or -2 in Stealth with Crackshot. With the hero trees, Hidden Opportunity builds also finish at -2 if Audacity or Opportunity is active.
    Variables.FinishCondition = CurrentComboPoints >= MaxComboPoints - 1 - ( (IsStealthed and IsPlayerSpell(ids.CrackshotTalent) or ( IsPlayerSpell(ids.HandOfFateTalent) or IsPlayerSpell(ids.FlawlessFormTalent) ) and IsPlayerSpell(ids.HiddenOpportunityTalent) and ( PlayerHasBuff(ids.AudacityBuff) or PlayerHasBuff(ids.OpportunityBuff) ) ) and 1 or 0)
    -- WeakAuras.ScanEvents("K_TRIGED_FINISH", Variables.FinishCondition)
    -- Variable that counts how many buffs are ahead of RtB's pandemic range, which is only possible by using KIR.
    Variables.BuffsAbovePandemic = ( GetRemainingAuraDuration("player", ids.BroadsideBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.TrueBearingBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.GrandMeleeBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.BuriedTreasureBuff) > 39 and 1 or 0 ) + ( GetRemainingAuraDuration("player", ids.SkullAndCrossbonesBuff) > 39 and 1 or 0 )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    -- Maintain Adrenaline Rush if it is not active. Use at low CPs with Improved AR.
    if OffCooldown(ids.AdrenalineRush) and ( not PlayerHasBuff(ids.AdrenalineRush) and ( not Variables.FinishCondition or not IsPlayerSpell(ids.ImprovedAdrenalineRushTalent) ) ) then
        ExtraGlows.AdrenalineRush = true
    end
    
    -- If using Improved AR, recast AR if it is already active at low CPs.
    if OffCooldown(ids.AdrenalineRush) and ( PlayerHasBuff(ids.AdrenalineRush) and IsPlayerSpell(ids.ImprovedAdrenalineRushTalent) and CurrentComboPoints <= 2 ) then
        ExtraGlows.AdrenalineRush = true
    end
    
    -- High priority Ghostly Strike as it is off-gcd. 1 FTH builds prefer to not use it at max CPs.
    if OffCooldown(ids.GhostlyStrike) and ( CurrentComboPoints < MaxComboPoints or TalentRank(ids.FanTheHammerTalentNode) > 1 ) then
        ExtraGlows.GhostlyStrike = true
    end
    
    -- Thistle Tea
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTea) and ( CurrentEnergy < aura_env.config["ThistleTeaEnergy"] or TargetTimeToXPct(0, 999) < C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) ) then
        ExtraGlows.ThistleTea = true
    end
    
    -- With a natural 5 buff roll, use Keep it Rolling when you obtain the remaining buff from Count the Odds.
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffNormal >= 5 and RTBBuffCount == 6 ) then
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
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    
    -- Builders
    local Build = function()
        -- High priority Ambush for Hidden Opportunity builds.
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.AudacityBuff) ) then
            KTrig("Ambush") return true end

        -- Trickster builds should prioritize Sinister Strike during Disorienting Strikes. HO builds prefer to do this only at 3 Escalating Blade stacks and not at max Opportunity stacks.
        if OffCooldown(ids.SinisterStrike) and ( HasDisorientingStrikes and not IsStealthed and ( GetPlayerStacks(ids.EscalatingBladeBuff) > 2 and GetPlayerStacks(ids.OpportunityBuff) < (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) or not IsPlayerSpell(ids.HiddenOpportunityTalent) ) and GetPlayerStacks(ids.EscalatingBladeBuff) < 4 ) then
            KTrig("Sinister Strike") return true end
            
        -- With Audacity + Hidden Opportunity + Fan the Hammer, consume Opportunity to proc Audacity any time Ambush is not available.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and IsPlayerSpell(ids.AudacityBuff) and IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.OpportunityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) then
            KTrig("Pistol Shot") return true end
        
        -- Without Hidden Opportunity, prioritize building CPs with Blade Flurry at 4+ targets, with low CPs unless AR isn't active.
        if OffCooldown(ids.BladeFlurry) and ( IsPlayerSpell(ids.DeftManeuversTalent) and NearbyEnemies >= 4 and ( CurrentComboPoints <= 2 or not PlayerHasBuff(ids.AdrenalineRushBuff) ) ) then
            KTrig("Blade Flurry") return true end

        -- With 2 ranks in Fan the Hammer, consume Opportunity as a higher priority if at max stacks or if it will expire.
        if OffCooldown(ids.PistolShot) and ( TalentRank(ids.FanTheHammerTalentNode) > 1 and PlayerHasBuff(ids.OpportunityBuff) and ( GetPlayerStacks(ids.OpportunityBuff) >= (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) or GetRemainingAuraDuration("player", ids.OpportunityBuff) < 2 ) ) then
            KTrig("Pistol Shot") return true end
        
        -- With Fan the Hammer, consume Opportunity if it will not overcap CPs, or with 1 CP at minimum.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxComboPoints - CurrentComboPoints >= ( 1 + ( (IsPlayerSpell(ids.QuickDrawTalent) and 1 or 0) + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) ) * ( TalentRank(ids.FanTheHammerTalentNode) + 1 ) ) or CurrentComboPoints <= (IsPlayerSpell(ids.RuthlessnessTalent) and 1 or 0) ) ) then
            KTrig("Pistol Shot") return true end
        
        -- If not using Fan the Hammer, then consume Opportunity based on energy, when it will exactly cap CPs, or when using Quick Draw.
        if OffCooldown(ids.PistolShot) and ( not IsPlayerSpell(ids.FanTheHammerTalent) and PlayerHasBuff(ids.OpportunityBuff) and ( MaxEnergy - CurrentEnergy > 75 or MaxComboPoints - CurrentComboPoints <= 1 + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) or IsPlayerSpell(ids.QuickDrawTalent) or IsPlayerSpell(ids.AudacityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) ) then
            KTrig("Pistol Shot") return true end

        -- Use Coup de Grace at low CP if Sinister Strike would otherwise be used.
        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace and (not IsStealthed) then
            KTrig("Dispatch") return true end

        -- Fallback pooling just so Sinister Strike is never casted if Ambush is available for Hidden Opportunity builds
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) ) then
            KTrig("Ambush") return true end
        
        if OffCooldown(ids.SinisterStrike) then
            KTrig("Sinister Strike") return true end
    end
    
    local Finish = function()
        if OffCooldown(ids.KillingSpree) then
            -- KTrig("Killing Spree") return true end
            if aura_env.config[tostring(ids.KillingSpree)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Killing Spree")
            elseif aura_env.config[tostring(ids.KillingSpree)] ~= true then
                KTrig("Killing Spree")
                return true
            end
        end

        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace then
            KTrig("Dispatch") return true end
        
        -- Finishers Use Between the Eyes outside of Stealth to maintain the buff, or with Ruthless Precision active, or to proc Greenskins Wickers if not active. Trickster builds can also send BtE on cooldown.
        if OffCooldown(ids.BetweenTheEyes) and ( ( PlayerHasBuff(ids.RuthlessPrecisionBuff) or GetRemainingAuraDuration("player", ids.BetweenTheEyesBuff) < 4 or not IsPlayerSpell(ids.MeanStreakTalent) ) and ( not PlayerHasBuff(ids.GreenskinsWickersBuff) or not IsPlayerSpell(ids.GreenskinsWickersTalent) ) ) then
            KTrig("Between the Eyes") return true end
        
        --if OffCooldown(ids.CoupDeGrace) then
        --    KTrig("Coup De Grace") return true end
        
        if OffCooldown(ids.Dispatch) then
            KTrig("Dispatch") return true end
    end

    local VanishUsage = function()
        -- Flex Vanish usage for standard builds. Without Killing Spree, attempt to hold Vanish for when BtE is on cooldown and Ruthless Precision is active. Also with Keep it Rolling, hold Vanish if we haven't done the first roll after KIR yet.
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.KillingSpreeTalent) and not OffCooldown(ids.BetweenTheEyes) and GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 4 and ( GetRemainingSpellCooldown(ids.KeepItRolling) > 150 and RTBBuffNormal > 0 or not IsPlayerSpell(ids.KeepItRollingTalent) ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end

        -- Supercharger builds that do not use Killing Spree should also Vanish if Supercharger becomes active.
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.KillingSpreeTalent) and GetUnitChargedPowerPoints("player") ~= nil  ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Builds with Killing Spree can freely Vanish if KS is not up soon.
        if OffCooldown(ids.Vanish) and ( GetRemainingSpellCooldown(ids.KillingSpree) > 30 ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish if about to cap on charges or sim duration is ending.
        if OffCooldown(ids.Vanish) and ( GetTimeToFullCharges(ids.Vanish) < 15 or FightRemains(60, NearbyRange) < 8 ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
    end
    
    -- Flex Vanish usage for builds lacking one of the mandatory stealth talents. APL support for these builds is considered limited.
    local VanishUsageOffMeta = function()
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and not IsPlayerSpell(ids.CrackshotTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and ( Variables.AmbushCondition or not IsPlayerSpell(ids.HiddenOpportunityTalent) ) and ( not OffCooldown(ids.BetweenTheEyes) and PlayerHasBuff(ids.RuthlessPrecisionBuff) or PlayerHasBuff(ids.RuthlessPrecisionBuff) == false or GetRemainingAuraDuration("player", ids.AdrenalineRushBuff) < 3 ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.CrackshotTalent) and Variables.FinishCondition ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.HiddenOpportunityTalent) and not PlayerHasBuff(ids.AudacityBuff) and GetPlayerStacks(ids.OpportunityBuff) < (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) and Variables.AmbushCondition ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and not IsPlayerSpell(ids.HiddenOpportunityTalent) and IsPlayerSpell(ids.FatefulEndingTalent) and ( not PlayerHasBuff(ids.FateboundLuckyCoinBuff) and ( GetPlayerStacks(ids.FateboundCoinTailsBuff) >= 5 or GetPlayerStacks(ids.FateboundCoinHeadsBuff) >= 5 ) or PlayerHasBuff(ids.FateboundLuckyCoinBuff) and not OffCooldown(ids.BetweenTheEyes) ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        if OffCooldown(ids.Vanish) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) and not IsPlayerSpell(ids.CrackshotTalent) and not IsPlayerSpell(ids.HiddenOpportunityTalent) and not IsPlayerSpell(ids.FatefulEndingTalent) and IsPlayerSpell(ids.TakeEmBySurpriseTalent) and not PlayerHasBuff(ids.TakeEmBySurpriseBuff) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
    end
    
    local Cds = function()
        -- Maintain Blade Flurry on 2+ targets.
        if OffCooldown(ids.BladeFlurry) and ( NearbyEnemies >= 2 and GetRemainingAuraDuration("player", ids.BladeFlurry) < BFHeadsup ) then
            KTrig("Blade Flurry") return true end
        
        -- Maintain Roll the Bones: cast without any buffs.
        if OffCooldown(ids.RollTheBones) and ( RTBBuffCount == 0 ) then
            KTrig("Roll the Bones") return true end
        
        -- With TWW2 set, recast Roll the Bones if we will roll away between 0-1 buffs. If KIR was recently used on a natural 5 buff, then wait until all buffs are below around 41s remaining.
        if OffCooldown(ids.RollTheBones) and ( (SetPieces >= 4) and RTBBuffWillLose <= 1 and ( Variables.BuffsAbovePandemic < 5 or RTBBuffMaxRemains < 42 ) ) then
            KTrig("Roll the Bones") return true end
        
        -- With TWW2 set, recast Roll the Bones with at most 2 buffs active regardless of duration. Supercharger builds will also roll if we will lose between 0-4 buffs, but KIR Supercharger builds wait until they are all below 11s remaining.
        if OffCooldown(ids.RollTheBones) and ( (SetPieces >= 4) and ( RTBBuffCount <= 2 or (RTBBuffMaxRemains < 11 or not IsPlayerSpell(ids.KeepItRolling)) and RTBBuffWillLose < 5 and IsPlayerSpell(ids.SuperchargerTalent) ) ) then
            KTrig("Roll the Bones") return true end
        
        -- Without TWW2 set or Sleight of Hand, recast Roll the Bones to override 1 buff into 2 buffs with Loaded Dice, or reroll any 2 buffs with Loaded Dice+Supercharger. Hidden Opportunity builds can also reroll 2 buffs with Loaded Dice to try for BS/RP/TB.
        if OffCooldown(ids.RollTheBones) and ( not (SetPieces >= 4) and ( RTBBuffWillLose <= (PlayerHasBuff(ids.LoadedDiceBuff) and 1 or 0) or IsPlayerSpell(ids.SuperchargerTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 or IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 and not PlayerHasBuff(ids.BroadsideBuff) and not PlayerHasBuff(ids.RuthlessPrecisionBuff) and not PlayerHasBuff(ids.TrueBearingBuff) ) ) then
            KTrig("Roll the Bones") return true end
        
        -- If necessary, standard builds prioritize using Vanish at any CP to prevent Adrenaline Rush downtime.
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and not IsStealthed and GetRemainingAuraDuration("player", ids.AdrenalineRushBuff) < 2 and GetRemainingSpellCooldown(ids.AdrenalineRush) > 30 ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end

        -- If not at risk of losing Adrenaline Rush, run finishers to use Killing Spree or Coup de Grace as a higher priority than Vanish.
        if not IsStealthed and ( OffCooldown(ids.KillingSpree) and IsPlayerSpell(ids.KillingSpreeTalent) or GetPlayerStacks(ids.EscalatingBladeBuff) >= 4 ) and Variables.FinishCondition then
            Finish() return true end
        
        -- If not at risk of losing Adrenaline Rush, call flexible Vanish rules to be used at finisher CPs.
        if not IsStealthed and IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and Variables.FinishCondition then
            if VanishUsage() then return true end end
        
        if not IsStealthed and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) or not IsPlayerSpell(ids.CrackshotTalent) or not IsPlayerSpell(ids.SubterfugeTalent) ) then
            if VanishUsageOffMeta() then return true end end
        
        -- Use Blade Rush at minimal energy outside of stealth
        if OffCooldown(ids.BladeRush) and ( CurrentEnergy < BRKSEnergy and not IsStealthed ) then
            KTrig("Blade Rush") return true end
    end
        
    local Stealth = function()
        -- High priority Between the Eyes for Crackshot, except not directly out of Shadowmeld.
        if OffCooldown(ids.BetweenTheEyes) and ( Variables.FinishCondition and IsPlayerSpell(ids.CrackshotTalent) and ( not PlayerHasBuff(ids.Shadowmeld) or IsStealthed ) ) then
            KTrig("Between the Eyes") return true end
        
        if OffCooldown(ids.Dispatch) and ( Variables.FinishCondition ) then
            KTrig("Dispatch") return true end
        
        -- 2 Fan the Hammer Crackshot builds can consume Opportunity in stealth with max stacks, Broadside, and 1 CP, or with Greenskins active
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.CrackshotTalent) and TalentRank(ids.FanTheHammerTalentNode) > 1 and GetPlayerStacks(ids.OpportunityBuff) >= 6 and ( PlayerHasBuff(ids.BroadsideBuff) and CurrentComboPoints <= 1 or PlayerHasBuff(ids.GreenskinsWickersBuff) ) ) then
            KTrig("Pistol Shot") return true end
        
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) ) then
            KTrig("Ambush") return true end
    end
    
    if Cds() then return true end
    
    -- High priority stealth list, will fall through if no conditions are met.
    if IsStealthed then
        if Stealth() then return true end end
    
    if Variables.FinishCondition then
        Finish() return true end
    
    if Build() then return true end

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
        end
    end
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