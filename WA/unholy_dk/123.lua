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
    RaiseAbomination = 455395,
    AbominationLimb = 383269,
    Apocalypse = 275699,
    ArmyOfTheDead = 42650,
    DarkArbiter = 207349,
    DarkTransformation = 63560,
    DeathAndDecay = 43265,
    DeathCoil = 47541,
    Defile = 152280,
    Epidemic = 207317,
    FesteringStrike = 85948, 
    Outbreak = 77575, 
    RaiseDead = 46584,
    ScourgeStrike = 55090,
    SoulReaper = 343294,
    SummonGargoyle = 49206,
    UnholyAssault = 207289,
    VileContagion = 390279,
    VampiricStrike = 433895,
    
    -- Talents
    VampiricStrikeTalent = 433901,
    Morbidity = 377592,
    DoomedBidding = 455386,
    CoilOfDevastation = 390270,
    ImprovedDeathCoil = 377580,
    GiftOfTheSanlayn = 434152,
    RottenTouch = 390275,
    BurstingSores = 207264,
    EbonFever = 207269,
    Superstrain = 390283,
    CommanderOfTheDead = 390259,
    Plaguebringer = 390175,
    ImprovedDeathStrike = 374277,
    UnholyBlight = 460448,
    UnholyGround = 374265,
    MenacingMagusTalent = 455135,
    FrenziedBloodthirstTalent = 434075,
    HungeringThirstTalent = 444037,
    HarbingerOfDoomTalent = 276023,
    
    -- Buffs/Debuffs
    AFeastOfSouls = 440861,
    ChainsOfIceTrollbaneSlow = 444826,
    VirulentPlague = 191587,
    FesteringWound = 194310,
    EssenceOfTheBloodQueen = 433925,
    GiftOfTheSanlaynBuff = 434153,
    RottenTouchDebuff = 390276,
    CommanderOfTheDeadBuff = 390260,
    InflictionOfSorrow = 460049,
    DeathAndDecayBuff = 188290,
    RunicCorruption = 51460,
    FrostFever = 55095,
    BloodPlague = 55078,
    SuddenDoom = 81340,
    Festermight = 377591,
    DeathRot = 377540,
    FesteringScythe = 458128,
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
        return false
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

aura_env.PetHasBuff = function(spellID)
    return WA_GetUnitBuff("pet", spellID) ~= nil
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
    
    if IsPlayerSpell(aura_env.ids.ImprovedDeathStrike) then 
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
    local PetHasBuff = aura_env.PetHasBuff
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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1867)
    
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
            if WA_GetUnitDebuff(unit, ids.FesteringWound, "PLAYER||HARMFUL") ~= nil then
                TargetsWithFesteringWounds = TargetsWithFesteringWounds + 1
            end
        end
    end
    
    WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    if NearbyEnemies == 1 then
    Variables.StPlanning = true else Variables.StPlanning = false end
    
    if NearbyEnemies >= 2 then
    Variables.AddsRemain = true else Variables.AddsRemain = false end
    
    if GetRemainingSpellCooldown(ids.Apocalypse) < 5 and GetTargetStacks(ids.FesteringWound) < 1 and GetRemainingSpellCooldown(ids.UnholyAssault) > 5 then
    Variables.ApocTiming = 3 else Variables.ApocTiming = 0 end
    
    if IsPlayerSpell(ids.VileContagion) and GetRemainingSpellCooldown(ids.VileContagion) < 3 and CurrentRunicPower < 30 then
    Variables.PoolingRunicPower = true else Variables.PoolingRunicPower = false end
    
    if ( GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming or not IsPlayerSpell(ids.Apocalypse) ) and ( GetTargetStacks(ids.FesteringWound) >= 1 and GetRemainingSpellCooldown(ids.UnholyAssault) < 20 and IsPlayerSpell(ids.UnholyAssault) and Variables.StPlanning or TargetHasDebuff(ids.RottenTouchDebuff) and GetTargetStacks(ids.FesteringWound) >= 1 or GetTargetStacks(ids.FesteringWound) >= 4 - (AbominationRemaining > 0 and 1 or 0) ) or FightRemains(10, NearbyRange) < 5 and GetTargetStacks(ids.FesteringWound) >= 1 then
    Variables.PopWounds = true else Variables.PopWounds = false end
    
    if ( not IsPlayerSpell(ids.RottenTouch) or IsPlayerSpell(ids.RottenTouch) and not TargetHasDebuff(ids.RottenTouchDebuff) or MaxRunicPower - CurrentRunicPower < 20 ) and ( ( IsPlayerSpell(ids.ImprovedDeathCoil) and ( NearbyEnemies == 2 or IsPlayerSpell(ids.CoilOfDevastation) ) or CurrentRunes < 3 or GargoyleRemaining or PlayerHasBuff(ids.SuddenDoom) or not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) >= 4 ) ) then
    Variables.SpendRp = true else Variables.SpendRp = false end
    
    Variables.EpidemicTargets = 3 + (IsPlayerSpell(ids.ImprovedDeathCoil) and 1 or 0) + ( (IsPlayerSpell(ids.FrenziedBloodthirstTalent) and GetPlayerStacks(ids.EssenceOfTheBloodQueen) > 5) and 1 or 0 ) + ( (IsPlayerSpell(ids.HungeringThirstTalent) and IsPlayerSpell(ids.HarbingerOfDoomTalent) and PlayerHasBuff(ids.SuddenDoom)) and 1 or 0 )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.ArmyOfTheDead) and not IsPlayerSpell(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( IsPlayerSpell(ids.CommanderOfTheDead) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 or not IsPlayerSpell(ids.CommanderOfTheDead) and NearbyEnemies >= 1 ) or FightRemains(30, NearbyRange) < 35 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.RaiseAbomination) and ( ( Variables.StPlanning or Variables.AddsRemain ) or FightRemains(25, NearbyRange) < 30 ) then
        ExtraGlows.ArmyOfTheDead = true
    end
    
    if OffCooldown(ids.SummonGargoyle) and ( ( Variables.StPlanning or Variables.AddsRemain ) and ( PlayerHasBuff(ids.CommanderOfTheDeadBuff) or not IsPlayerSpell(ids.CommanderOfTheDead) and NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 25 ) then
        ExtraGlows.SummonGargoyle = true
    end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AOE
    local Aoe = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 and PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.BurstingSores) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming or PlayerHasBuff(ids.FesteringScythe) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 2 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 and GetRemainingSpellCooldown(ids.Apocalypse) > WeakAuras.gcdDuration() or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and TargetHasDebuff(ids.VirulentPlague) ) then
            NGSend("Scourge Strike") return true end
    end
    
    -- AoE Burst
    local AoeBurst = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and NearbyEnemies < Variables.EpidemicTargets and ( not IsPlayerSpell(ids.BurstingSores) or IsPlayerSpell(ids.BurstingSores) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoom) or PlayerHasBuff(ids.SuddenDoom) and ( IsPlayerSpell(ids.DoomedBidding) and IsPlayerSpell(ids.MenacingMagusTalent) or IsPlayerSpell(ids.RottenTouch) or GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() ) ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike and ( not IsPlayerSpell(ids.BurstingSores) or IsPlayerSpell(ids.BurstingSores) and TargetsWithFesteringWounds < NearbyEnemies and TargetsWithFesteringWounds < NearbyEnemies * 0.4 and PlayerHasBuff(ids.SuddenDoom) or PlayerHasBuff(ids.SuddenDoom) and ( PlayerHasBuff(ids.AFeastOfSouls) or GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() or GetTargetStacks(ids.DeathRot) < 10 ) ) ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) >= 1 or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) <= 2 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) then
            NGSend("Scourge Strike") return true end
    end
    
    -- AoE Setup
    local AoeSetup = function()
        if OffCooldown(ids.FesteringStrike) and ( PlayerHasBuff(ids.FesteringScythe)) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and ( not IsPlayerSpell(ids.BurstingSores) and not IsPlayerSpell(ids.VileContagion) or TargetsWithFesteringWounds == NearbyEnemies or TargetsWithFesteringWounds >= 8 or not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.Defile) ) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( not IsPlayerSpell(ids.VileContagion) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.VileContagion) < 5 or TargetsWithFesteringWounds == NearbyEnemies and GetTargetStacks(ids.FesteringWound) <= 4 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoom) and NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower and PlayerHasBuff(ids.SuddenDoom) ) then
            NGSend("Epidemic") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() and GetTargetStacks(ids.FesteringWound) == 0 or TargetsWithFesteringWounds < NearbyEnemies ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and NearbyEnemies < Variables.EpidemicTargets ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.Epidemic) and ( not Variables.PoolingRunicPower ) then
            NGSend("Epidemic") return true end
    end
    
    -- Non-San'layn Cooldowns
    local Cds = function()
        if OffCooldown(ids.DarkTransformation) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < 8 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 1 ) or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( GetRemainingSpellCooldown(ids.Apocalypse) < WeakAuras.gcdDuration() * 2 or not IsPlayerSpell(ids.Apocalypse) or NearbyEnemies >= 2 and PlayerHasBuff(ids.DarkTransformation) ) or FightRemains(60, NearbyRange) < 20 ) then
            print("Cds Unholy Assault")
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Superstrain) and ( IsAuraRefreshable(ids.FrostFever) or IsAuraRefreshable(ids.BloodPlague) ) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.Plaguebringer)) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) * 3 ) ) then
            NGSend("Outbreak") return true end
        
        if OffCooldown(ids.AbominationLimb) and ( Variables.StPlanning and not PlayerHasBuff(ids.SuddenDoom) and ( PlayerHasBuff(ids.Festermight) and GetPlayerStacks(ids.Festermight) > 8 or not IsPlayerSpell(ids.Festermight) ) and ( ApocalypseRemaining < 5 or not IsPlayerSpell(ids.Apocalypse) ) and GetTargetStacks(ids.FesteringWound) <= 2 or FightRemains(60, NearbyRange) < 12 ) then
            NGSend("Abomination Limb") return true end
        
    end
    
    -- Non-San'layn AoE Cooldowns
    local CdsAoe = function()
        if OffCooldown(ids.VileContagion) and ( GetTargetStacks(ids.FesteringWound) >= 4 and ( GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or PlayerHasBuff(ids.DeathAndDecayBuff) and GetTargetStacks(ids.FesteringWound) >= 4 ) or Variables.AddsRemain and GetTargetStacks(ids.FesteringWound) == 6 ) then
            NGSend("Vile Contagion") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and ( GetTargetStacks(ids.FesteringWound) >= 2 and GetRemainingSpellCooldown(ids.VileContagion) < 3 or not IsPlayerSpell(ids.VileContagion) ) ) then
            print("CdsAoe Unholy Assault")
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.DarkTransformation) and ( Variables.AddsRemain and ( GetRemainingSpellCooldown(ids.VileContagion) > 5 or not IsPlayerSpell(ids.VileContagion) or PlayerHasBuff(ids.DeathAndDecayBuff) or GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 ) ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.Outbreak) and ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
            NGSend("Outbreak") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and CurrentRunes <= 3 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.AbominationLimb) and ( Variables.AddsRemain ) then
            NGSend("Abomination Limb") return true end
        
    end
    
    -- San'layn AoE Cooldowns
    local CdsAoeSan = function()
        if OffCooldown(ids.DarkTransformation) and ( Variables.AddsRemain and ( PlayerHasBuff(ids.DeathAndDecayBuff) or NearbyEnemies <= 3 ) ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.VileContagion) and ( GetTargetStacks(ids.FesteringWound) >= 4  and ( GetRemainingSpellCooldown(ids.DeathAndDecay) < 3 or PlayerHasBuff(ids.DeathAndDecayBuff) and GetTargetStacks(ids.FesteringWound) >= 4 ) or Variables.AddsRemain and GetTargetStacks(ids.FesteringWound) == 6 ) then
            NGSend("Vile Contagion") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.AddsRemain and ( GetTargetStacks(ids.FesteringWound) >= 2 and GetRemainingSpellCooldown(ids.VileContagion) < 6 or not IsPlayerSpell(ids.VileContagion) ) ) then
            print("CdsAoeSan Unholy Assault")
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Outbreak) and ( ( floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
            NGSend("Outbreak") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.AddsRemain and CurrentRunes <= 3 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.AbominationLimb) and ( Variables.AddsRemain ) then
            NGSend("Abomination Limb") return true end
    end
    
    -- San'layn Cooldowns
    local CdsSan = function()
        if OffCooldown(ids.DarkTransformation) and ( NearbyEnemies >= 1 and Variables.StPlanning and ( IsPlayerSpell(ids.Apocalypse) and (ApocalypseRemaining > 0) or not IsPlayerSpell(ids.Apocalypse) ) or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Dark Transformation") return true end
        
        if OffCooldown(ids.UnholyAssault) and ( Variables.StPlanning and ( PetHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("pet", ids.DarkTransformation) < 12 ) or FightRemains(60, NearbyRange) < 20 ) then
            print("CdsSan Unholy Assault")
            NGSend("Unholy Assault") return true end
        
        if OffCooldown(ids.Apocalypse) and ( Variables.StPlanning or FightRemains(60, NearbyRange) < 20 ) then
            NGSend("Apocalypse") return true end
        
        if OffCooldown(ids.Outbreak) and ( TargetTimeToXPct(0, 60) > GetRemainingDebuffDuration("target", ids.VirulentPlague) and floor(GetRemainingDebuffDuration("target", ids.VirulentPlague) / 1.5) < 5 and ( IsAuraRefreshable(ids.VirulentPlague) or IsPlayerSpell(ids.Morbidity) and PlayerHasBuff(ids.InflictionOfSorrow) and IsPlayerSpell(ids.Superstrain) and IsAuraRefreshable(ids.FrostFever) and IsAuraRefreshable(ids.BloodPlague) ) and ( not IsPlayerSpell(ids.UnholyBlight) or IsPlayerSpell(ids.UnholyBlight) and GetRemainingSpellCooldown(ids.DarkTransformation) > 0 ) and ( not IsPlayerSpell(ids.RaiseAbomination) or IsPlayerSpell(ids.RaiseAbomination) and GetRemainingSpellCooldown(ids.RaiseAbomination) > 0 ) ) then
            NGSend("Outbreak") return true end
        
        if OffCooldown(ids.AbominationLimb) and ( NearbyEnemies >= 1 and Variables.StPlanning and not PlayerHasBuff(ids.GiftOfTheSanlayn) and not PlayerHasBuff(ids.SuddenDoom) and PlayerHasBuff(ids.Festermight) and GetTargetStacks(ids.FesteringWound) <= 2 or not PlayerHasBuff(ids.GiftOfTheSanlayn) and FightRemains(60, NearbyRange) < 12 ) then
            NGSend("Abomination Limb") return true end
    end
    
    -- Cleave
    local Cleave = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) < 4 or PlayerHasBuff(ids.FesteringScythe) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming and GetTargetStacks(ids.FesteringWound) < 4 ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            NGSend("Scourge Strike") return true end
        
    end
    
    -- San'layn Fishing
    local SanFishing = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and IsPlayerSpell(ids.DoomedBidding) or SetPieces >= 4 and GetPlayerStacks(ids.EssenceOfTheBloodQueen) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.DeathCoil) and ( FindSpellOverrideByID(ids.ScourgeStrike) ~= ids.VampiricStrike ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( GetTargetStacks(ids.FesteringWound) >= 3 - (AbominationRemaining > 0 and 1 or 0) and GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 3 - (AbominationRemaining > 0 and 1 or 0) ) then
            NGSend("Festering Strike") return true end
    end
    
    -- Single Target San'layn
    local SanSt = function()
        if OffCooldown(ids.DeathAndDecay) and ( not PlayerHasBuff(ids.DeathAndDecayBuff) and IsPlayerSpell(ids.UnholyGround) and GetRemainingSpellCooldown(ids.DarkTransformation) < 5 ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( PlayerHasBuff(ids.SuddenDoom) and GetRemainingAuraDuration("player", ids.GiftOfTheSanlayn) and ( IsPlayerSpell(ids.DoomedBidding) or IsPlayerSpell(ids.RottenTouch) ) or CurrentRunes < 3 and not PlayerHasBuff(ids.RunicCorruption) or SetPieces >= 4 and CurrentRunicPower > 80 or PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetPlayerStacks(ids.EssenceOfTheBloodQueen) == 7 and IsPlayerSpell(ids.FrenziedBloodthirstTalent) and SetPieces >= 4 and GetPlayerStacks(ids.WinningStreakBuff) == 10 and CurrentRunes <= 3 and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueen) > 3 ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike or IsPlayerSpell(ids.GiftOfTheSanlayn) and PlayerHasBuff(ids.DarkTransformation) and GetRemainingAuraDuration("player", ids.DarkTransformation) < WeakAuras.gcdDuration() ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike and GetTargetStacks(ids.FesteringWound) >= 1 ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( ( GetTargetStacks(ids.FesteringWound) == 0 and GetRemainingSpellCooldown(ids.Apocalypse) < Variables.ApocTiming ) or ( IsPlayerSpell(ids.GiftOfTheSanlayn) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) or not IsPlayerSpell(ids.GiftOfTheSanlayn) ) and ( PlayerHasBuff(ids.FesteringScythe) or GetTargetStacks(ids.FesteringWound) <= 1 ) ) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( ( not IsPlayerSpell(ids.Apocalypse) or GetRemainingSpellCooldown(ids.Apocalypse) > Variables.ApocTiming ) and ( GetTargetStacks(ids.FesteringWound) >= 3 - (AbominationRemaining > 0 and 1 or 0) or FindSpellOverrideByID(ids.ScourgeStrike) == ids.VampiricStrike ) ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and GetRemainingDebuffDuration("target", ids.DeathRot) < WeakAuras.gcdDuration() or ( PlayerHasBuff(ids.SuddenDoom) and GetTargetStacks(ids.FesteringWound) >= 1 or CurrentRunes < 2 ) ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( GetTargetStacks(ids.FesteringWound) > 4 ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            NGSend("Death Coil") return true end
    end
    
    -- Single Taget Non-San'layn
    local St = function()
        if OffCooldown(ids.SoulReaper) and ( (UnitHealth("target")/UnitHealthMax("target")*100) <= 35 and FightRemains(60, NearbyRange) > 5 ) then
            NGSend("Soul Reaper") return true end
        
        if OffCooldown(ids.ScourgeStrike) and (TargetHasDebuff(ids.ChainsOfIceTrollbaneSlow)) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathAndDecay) and ( IsPlayerSpell(ids.UnholyGround) and not PlayerHasBuff(ids.DeathAndDecayBuff) and ( ApocalypseRemaining > 0 or AbominationRemaining > 0 or GargoyleRemaining > 0 ) ) then
            NGSend("Death and Decay") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower and Variables.SpendRp or FightRemains(60, NearbyRange) < 10 ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.FesteringStrike) and ( GetTargetStacks(ids.FesteringWound) < 4 and (not Variables.PopWounds or PlayerHasBuff(ids.FesteringScythe))) then
            NGSend("Festering Strike") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( Variables.PopWounds ) then
            NGSend("Scourge Strike") return true end
        
        if OffCooldown(ids.DeathCoil) and ( not Variables.PoolingRunicPower ) then
            NGSend("Death Coil") return true end
        
        if OffCooldown(ids.ScourgeStrike) and ( not Variables.PopWounds and GetTargetStacks(ids.FesteringWound) >= 4 ) then
            NGSend("Scourge Strike") return true end
    end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        print("1")
        if CdsAoeSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies >= 2 then
        print("2")
        if CdsAoe() then return true end end
    
    if IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 1 then
        print("3")
        if CdsSan() then return true end end
    
    if not IsPlayerSpell(ids.VampiricStrikeTalent) and NearbyEnemies == 1 then
        print("4")
        if Cds() then return true end end
    
    if NearbyEnemies == 2 then
        if Cleave() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) and GetRemainingSpellCooldown(ids.DeathAndDecay) < 10 then
        if AoeSetup() then return true end end
    
    if NearbyEnemies >= 3 and ( PlayerHasBuff(ids.DeathAndDecayBuff) or PlayerHasBuff(ids.DeathAndDecay) and TargetsWithFesteringWounds >= ( NearbyEnemies * 0.5 ) ) then
        if AoeBurst() then return true end end
    
    if NearbyEnemies >= 3 and not PlayerHasBuff(ids.DeathAndDecayBuff) then
        if Aoe() then return true end end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.GiftOfTheSanlayn) and not OffCooldown(ids.DarkTransformation) and not PlayerHasBuff(ids.GiftOfTheSanlaynBuff) and GetRemainingAuraDuration("player", ids.EssenceOfTheBloodQueen) < GetRemainingSpellCooldown(ids.DarkTransformation) + 3 then
        SanFishing() return true end
    
    if NearbyEnemies <= 1 and IsPlayerSpell(ids.VampiricStrikeTalent) then
        if SanSt() then return true end end
    
    if NearbyEnemies <= 1 and not IsPlayerSpell(ids.VampiricStrikeTalent) then
        if St() then return true end end
    
    WeakAuras.ScanEvents("NG_GLOW_EXCLUSIVE", "Clear", nil)
end






























