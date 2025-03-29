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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1694)
    
    local CurrentEnergy = UnitPower("player", Enum.PowerType.Energy)
    local MaxEnergy = UnitPowerMax("player", Enum.PowerType.Energy)
    local EffectiveComboPoints = UnitPower("player", Enum.PowerType.ComboPoints)
    local MaxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints)
    local IsBerserk = PlayerHasBuff(ids.Berserk) or PlayerHasBuff(ids.Incarnation)
    local BsIncBuff = (PlayerHasBuff(ids.Berserk) and ids.Berserk or ids.Incarnation)
    
    local NearbyRange = 10
    local NearbyEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    -- Determine Bloodtalons
    local BloodTalonsCount = 0
    if IsPlayerSpell(ids.BloodtalonsTalent) then
        if aura_env.RakeCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.ShredCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.ThrashCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.FeralFrenzyCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.SwipeCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.MoonfireCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
        if aura_env.BrutalSlashCast - GetTime() >= 0 then BloodTalonsCount = BloodTalonsCount + 1 end
    end
    
    local RipSnapshots = aura_env.RipSnapshots
    local RakeSnapshots = aura_env.RakeSnapshots
    local AppliableRakeMultiplier = 1
    local AppliableRipMultiplier = 1
    if IsStealthed() or PlayerHasBuff(ids.SuddenAmbushBuff) then
        AppliableRakeMultiplier = AppliableRakeMultiplier * 1.6
    end
    if PlayerHasBuff(ids.TigersFury) then
        AppliableRakeMultiplier = AppliableRakeMultiplier * 1.15
        AppliableRipMultiplier = AppliableRipMultiplier * 1.15
    end
    if PlayerHasBuff(ids.Berserk) then
        AppliableRakeMultiplier = AppliableRakeMultiplier * 1.15
        AppliableRipMultiplier = AppliableRipMultiplier * 1.15
    end
    if PlayerHasBuff(ids.BloodtalonsBuff) then
        AppliableRipMultiplier = AppliableRipMultiplier * 1.25
    end
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("NG_GLOW_EXTRAS", {})
        NGSend("Clear", nil) return end
    
    -- RangeChecker (Melee)
    if C_Item.IsItemInRange(16114, "target") == false then aura_env.OutOfRange = true end
    
    
    ---- Variables -----------------------------------------------------------------------------------------------
    -- most expensive bt cycle is Shred + Thrash + Rake, 40+40+35 for 115 energy. During incarn it is 32+32+28 for 92energy
    Variables.EffectiveEnergy = CurrentEnergy + ( 40 * GetPlayerStacks(ids.ClearcastingBuff) ) + ( 3 * GetPowerRegen() ) + ( 50 * ((GetRemainingSpellCooldown(ids.TigersFury) < 3.5) and 1 or 0) )
    
    -- estimated time until we have enough energy to proc bloodtalons.
    Variables.TimeToPool = ( ( 115 - Variables.EffectiveEnergy - ( 23 * (PlayerHasBuff(ids.Incarnation) and 1 or 0) ) ) / GetPowerRegen() )
    
    -- capped on clearcasting stacks
    Variables.CcCapped = GetPlayerStacks(ids.ClearcastingBuff) == ( 1 + (IsPlayerSpell(ids.MomentOfClarityTalent) and 1 or 0) )
    
    -- try to proc bt if we have 1 or 0 stacks of bloodtalons
    Variables.NeedBt = IsPlayerSpell(ids.BloodtalonsTalent) and GetPlayerStacks(ids.BloodtalonsBuff) <= 1
    
    -- optional variable that sends regrowth and renewal casts. Turned off by default
    Variables.Regrowth = false
    
    -- optional variable that forgoes shredding in AoE. Turned off by default
    Variables.EasySwipe = false

    -- NG TODO - don't be lazy.
    Variables.Holdconvoke = false
    Variables.HoldBerserk = false
    
    ids.BsInc = IsPlayerSpell(ids.Incarnation) and ids.Incarnation or ids.Berserk
    
    -- this returns true if we have a dot nearing pandemic range
    Variables.DotRefreshSoon = ( not IsPlayerSpell(ids.ThrashingClawsTalent) and ( GetRemainingDebuffDuration("target", ids.ThrashDebuff) - (12 * 0.8) * 0.3 <= 2 ) ) or ( IsPlayerSpell(ids.LunarInspirationTalent) and ( GetRemainingDebuffDuration("target", ids.MoonfireDebuff) - (18 * 0.8) * 0.3 <= 2 ) ) or ( ( (TargetHasDebuff(ids.RakeDebuff) and RakeSnapshots[UnitGUID("target")] or 0) < 1.6 or PlayerHasBuff(ids.SuddenAmbushBuff) ) and ( GetRemainingDebuffDuration("target", ids.RakeDebuff) - (15 * 0.8) * 0.3 <= 2 ) )
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    if OffCooldown(ids.TigersFury) and ( ( MaxEnergy - CurrentEnergy > 35 or EffectiveComboPoints == 5 or EffectiveComboPoints >= 3 and IsAuraRefreshable(ids.Rip) and PlayerHasBuff(ids.BloodtalonsBuff)) and ( FightRemains(60, NearbyRange) <= 15 or ( GetRemainingSpellCooldown(ids.BsInc) > 20 and TargetTimeToXPct(0, 60) > 5 ) or ( OffCooldown(ids.BsInc) and TargetTimeToXPct(0, 60) > 12 or TargetTimeToXPct(0, 60) == FightRemains(60, NearbyRange) ) ) ) then
        ExtraGlows.TigersFury = true
    end
    
    -- Berserk / Incarn
    if IsPlayerSpell(ids.Incarnation) and (PlayerHasBuff(ids.TigersFuryBuff) and not Variables.HoldBerserk) then
        if OffCooldown(ids.Incarnation) then
            ExtraGlows.Berserk = true
        end
    elseif OffCooldown(ids.Berserk) and (PlayerHasBuff(ids.TigersFuryBuff) and not Variables.HoldBerserk) then
        ExtraGlows.Berserk = true
    end
    
    WeakAuras.ScanEvents("NG_GLOW_EXTRAS", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Finisher = function()
        -- maintain/upgrade pws, if we have 6.5+s left on pw, we will instead bite if we have rampant ferocity talented. Without rampant, we will bite a vined target with 6 or fewer targets. If we have Ravage, we use specifically Ravage at 7 or fewer targets.
        if OffCooldown(ids.PrimalWrath) and ( NearbyEnemies > 1 and ( ( GetRemainingDebuffDuration("target", ids.Rip) < 6.5 and not IsBerserk or IsAuraRefreshable(ids.Rip) ) or ( not IsPlayerSpell(ids.RampantFerocityTalent) and ( NearbyEnemies > 1 and not TargetHasDebuff(ids.BloodseekerVinesDebuff) and not PlayerHasBuff(ids.RavageBuff) or NearbyEnemies > 6 + (IsPlayerSpell(ids.Ravage) and 1 or 0) ) ) ) ) then
            NGSend("Primal Wrath") return true end
        
        -- rip if single target or pw isnt up. Rip with bloodtalons if talented. If tigers fury will be up before rip falls off, then delay refresh
        if OffCooldown(ids.Rip) and ( IsAuraRefreshable(ids.Rip) and ( not IsPlayerSpell(ids.PrimalWrath) or NearbyEnemies <= 1 ) and ( PlayerHasBuff(ids.BloodtalonsBuff) or not IsPlayerSpell(ids.BloodtalonsTalent) ) and ( PlayerHasBuff(ids.TigersFury) or GetRemainingDebuffDuration("target", ids.Rip) < GetRemainingSpellCooldown(ids.TigersFury) ) and ( GetRemainingDebuffDuration("target", ids.Rip) < FightRemains(60, NearbyRange) or GetRemainingDebuffDuration("target", ids.Rip) < 4 and PlayerHasBuff(ids.RavageBuff) ) ) then
            NGSend("Rip") return true end
        
        if OffCooldown(ids.FerociousBite) and ( (CurrentEnergy >= 50 or PlayerHasBuff(ids.ApexPredatorsCravingBuff)) and ( not IsBerserk ) ) then
            NGSend("Ferocious Bite") return true end
        
        if OffCooldown(ids.FerociousBite) then
            NGSend("Ferocious Bite") return true end
    end
    
    local AoeBuilder = function()
        -- this variable tracks whether or not we've started our bt sequence
        aura_env.ProccingBt = Variables.NeedBt
        
        -- maintain thrash highest prio
        if OffCooldown(ids.ThrashCat) and ( IsAuraRefreshable(ids.ThrashDebuff) and not IsPlayerSpell(ids.ThrashingClawsTalent) and not ( Variables.NeedBt and (aura_env.ThrashCast - GetTime() >= 0) ) ) then
            NGSend("Thrash") return true end
        
        -- avoid capping brs charges. Also send brutal slashes/ws swipe in aoe, even if we need to proc bloodtalons, during berserk.
        if OffCooldown(ids.BrutalSlash) and ( GetTimeToFullCharges(ids.BrutalSlash) < 4 or TargetTimeToXPct(0, 60) < 4 or (IsBerserk and NearbyEnemies >= 3 - (IsPlayerSpell(ids.RavageTalent) and 1 or 0) ) and not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) and (not IsBerserk or NearbyEnemies < 3 - (IsPlayerSpell(ids.RavageTalent) and 1 or 0) ) ) ) then
            NGSend("Brutal Slash") return true end

        if OffCooldown(ids.SwipeCat) and ( IsPlayerSpell(ids.WildSlashesTalent) and (TargetTimeToXPct(0, 60) < 4 or IsBerserk and NearbyEnemies >= 3 - (IsPlayerSpell(ids.RavageTalent) and 1 or 0) ) and ( not Variables.NeedBt and aura_env.SwipeCast - GetTime() >= 0 and (not IsBerserk or NearbyEnemies < 3 - (IsPlayerSpell(ids.RavageTalent) and 1 or 0) ) ) ) then
            NGSend("Swipe") return true end
        
        -- with wild slashes we swipe at 5+ targets over raking/moonfire
        if OffCooldown(ids.SwipeCat) and ( TargetTimeToXPct(0, 60) < 4 or ( IsPlayerSpell(ids.WildSlashesTalent) and NearbyEnemies > 4 and not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) ) then
            NGSend("Swipe") return true end
        
        if OffCooldown(ids.Prowl) and ( IsAuraRefreshable(ids.RakeDebuff) or RakeSnapshots[UnitGUID("target")] < 1.4 and not ( Variables.NeedBt and (aura_env.RakeCast - GetTime() >= 0) ) and OffCooldown(ids.Rake) and not PlayerHasBuff(ids.SuddenAmbushBuff) and not Variables.CcCapped ) then
            NGSend("Prowl") return true end
        
        -- dcr rake > moonfire
        if OffCooldown(ids.Rake) and ( IsAuraRefreshable(ids.RakeDebuff) and IsPlayerSpell(ids.DoubleclawedRakeTalent) and not ( Variables.NeedBt and (aura_env.RakeCast - GetTime() >= 0) ) and not Variables.CcCapped ) then
            NGSend("Rake") return true end
        
        -- at 3t with wild slashes, swipe is better than moonfiring/st rake
        if OffCooldown(ids.SwipeCat) and ( IsPlayerSpell(ids.WildSlashesTalent) and NearbyEnemies > 2 and not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) then
            NGSend("Swipe Cat") return true end
        
        -- li moonfire is better than non-dcr rake in aoe
        if OffCooldown(ids.MoonfireCat) and IsPlayerSpell(ids.LunarInspirationTalent) and ( IsAuraRefreshable(ids.MoonfireDebuff) and not ( Variables.NeedBt and (aura_env.MoonfireCast - GetTime() >= 0) ) and not Variables.CcCapped ) then
            NGSend("Moonfire") return true end
        
        if OffCooldown(ids.Rake) and ( IsAuraRefreshable(ids.RakeDebuff) and not ( Variables.NeedBt and (aura_env.RakeCast - GetTime() >= 0) ) and not Variables.CcCapped ) then
            NGSend("Rake") return true end
        
        -- fillers
        if OffCooldown(ids.BrutalSlash) and ( not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) then
            NGSend("Brutal Slash") return true end
        
        if OffCooldown(ids.SwipeCat) and ( not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) then
            NGSend("Swipe") return true end
        
        if OffCooldown(ids.Shred) and ( not PlayerHasBuff(ids.SuddenAmbushBuff) and not Variables.EasySwipe and not ( Variables.NeedBt and (aura_env.ShredCast - GetTime() >= 0) ) ) then
            NGSend("Shred") return true end
        
        if OffCooldown(ids.ThrashCat) and ( not IsPlayerSpell(ids.ThrashingClawsTalent) and not ( Variables.NeedBt and (aura_env.ThrashCast - GetTime() >= 0) ) ) then
            NGSend("Thrash") return true end
        
        -- fallback bt actions
        if OffCooldown(ids.Rake) and ( IsPlayerSpell(ids.DoubleclawedRakeTalent) and PlayerHasBuff(ids.SuddenAmbushBuff) and Variables.NeedBt and (aura_env.RakeCast - GetTime() <= 0) ) then
            NGSend("Rake") return true end
        
        if OffCooldown(ids.MoonfireCat) and IsPlayerSpell(ids.LunarInspirationTalent) and ( Variables.NeedBt and (aura_env.MoonfireCast - GetTime() <= 0) ) then
            NGSend("Moonfire") return true end
        
        if OffCooldown(ids.Rake) and ( PlayerHasBuff(ids.SuddenAmbushBuff) and Variables.NeedBt and (aura_env.RakeCast - GetTime() <= 0) ) then
            NGSend("Rake") return true end
        
        if OffCooldown(ids.Shred) and ( Variables.NeedBt and (aura_env.ShredCast - GetTime() <= 0) and not Variables.EasySwipe ) then
            NGSend("Shred") return true end
        
        if OffCooldown(ids.Rake) and ( RakeSnapshots[UnitGUID("target")] < 1.6 and Variables.NeedBt and (aura_env.RakeCast - GetTime() <= 0) ) then
            NGSend("Rake") return true end
        
        if OffCooldown(ids.ThrashCat) and ( Variables.NeedBt and (aura_env.ShredCast - GetTime() <= 0) ) then
            NGSend("Thrash") return true end
    end
    
    local Builder = function()
        -- this variable tracks whether or not we've started our bt sequence
        aura_env.ProccingBt = Variables.NeedBt
        
        if OffCooldown(ids.Prowl) and ( CurrentEnergy >= 35 and not PlayerHasBuff(ids.SuddenAmbushBuff) and ( IsAuraRefreshable(ids.RakeDebuff) or RakeSnapshots[UnitGUID("target")] < 1.4 ) and not ( Variables.NeedBt and (aura_env.RakeCast - GetTime() >= 0) ) and PlayerHasBuff(ids.TigersFury) and not PlayerHasBuff(ids.ShadowmeldBuff) ) then
            NGSend("Prowl") return true end
        
        -- upgrade to stealth rakes, otherwise refresh in pandemic. Delay rake as long as possible if it would downgrade
        if OffCooldown(ids.Rake) and ( ( ( IsAuraRefreshable(ids.RakeDebuff) and AppliableRakeMultiplier >= (TargetHasDebuff(ids.RakeDebuff) and RakeSnapshots[UnitGUID("target")] or 0) or GetRemainingDebuffDuration("target", ids.RakeDebuff) < 3.5 ) or PlayerHasBuff(ids.SuddenAmbushBuff) and AppliableRakeMultiplier > (TargetHasDebuff(ids.RakeDebuff) and RakeSnapshots[UnitGUID("target")] or 0) ) and not ( Variables.NeedBt and (aura_env.RakeCast - GetTime() >= 0) ) and ( IsPlayerSpell(ids.ThrivingGrowthTalent) or not IsBerserk) ) then
            NGSend("Rake") return true end

        if OffCooldown(ids.Shred) and ( PlayerHasBuff(ids.SuddenAmbushBuff) and IsBerserk ) then
            NGSend("Shred") return true end
        
        if OffCooldown(ids.BrutalSlash) and ( GetTimeToFullCharges(ids.BrutalSlash) < 4 and not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) then
            NGSend("Brutal Slash") return true end
        
        if OffCooldown(ids.MoonfireCat) and IsPlayerSpell(ids.LunarInspirationTalent) and ( IsAuraRefreshable(ids.MoonfireDebuff) ) then
            NGSend("Moonfire") return true end
        
        if OffCooldown(ids.ThrashCat) and ( not IsBerserk and IsAuraRefreshable(ids.ThrashDebuff) and not IsPlayerSpell(ids.ThrashingClawsTalent) ) then
            NGSend("Thrash") return true end
        
        if OffCooldown(ids.Shred) and ( PlayerHasBuff(ids.ClearcastingBuff) and not ( Variables.NeedBt and (aura_env.ShredCast - GetTime() >= 0) ) ) then
            NGSend("Shred") return true end
        
        -- pool energy if we need to refresh dor in the next 1.5s
        if ( Variables.DotRefreshSoon and MaxEnergy - CurrentEnergy > 70 and not Variables.NeedBt and not IsBerserk and GetRemainingSpellCooldown(ids.TigersFury) > 3 ) then
            NGSend("Pool Resource") return true end
        
        if OffCooldown(ids.BrutalSlash) and ( not ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() >= 0) ) ) then
            NGSend("Brutal Slash") return true end
        
        if OffCooldown(ids.Shred) and ( not ( Variables.NeedBt and (aura_env.ShredCast - GetTime() >= 0) ) ) then
            NGSend("Shred") return true end

        if OffCooldown(ids.ThrashCat) and ( IsAuraRefreshable(ids.ThrashDebuff) and not IsPlayerSpell(ids.ThrashingClawsTalent) ) then
            NGSend("Thrash") return true end
        
        if OffCooldown(ids.SwipeCat) and ( Variables.NeedBt and (aura_env.SwipeCast - GetTime() <= 0) ) then
            NGSend("Swipe") return true end
        
        -- clip rake for bt if it wont downgrade its snapshot
        if OffCooldown(ids.Rake) and ( Variables.NeedBt and (aura_env.RakeCast - GetTime() <= 0) and AppliableRakeMultiplier >= (TargetHasDebuff(ids.RakeDebuff) and RakeSnapshots[UnitGUID("target")] or 0) ) then
            NGSend("Rake") return true end
        
        if OffCooldown(ids.MoonfireCat) and IsPlayerSpell(ids.LunarInspirationTalent) and ( Variables.NeedBt and (aura_env.MoonfireCast - GetTime() <= 0) ) then
            NGSend("Moonfire") return true end
        
        if OffCooldown(ids.ThrashCat) and ( Variables.NeedBt and (aura_env.ThrashCast - GetTime() <= 0) ) then
            NGSend("Thrash") return true end
    end
    
    local Cooldown = function()        
        if OffCooldown(ids.FeralFrenzy) and ( ( PlayerHasBuff(ids.TigersFuryBuff) or not IsPlayerSpell(ids.SavageFuryTalent) or not IsPlayerSpell(ids.ThrivingGrowthTalent) ) and EffectiveComboPoints <= 1 + (IsBerserk and 1 or 0) ) then
            NGSend("Feral Frenzy") return true end
        
        if OffCooldown(ids.ConvokeTheSpirits) and ( FightRemains(60, NearbyRange) < 5 or IsBerserk and GetRemainingAuraDuration("player", BsIncBuff) < 5 - (IsPlayerSpell(ids.AshamanesGuidanceTalent) and 1 or 0) or PlayerHasBuff(ids.TigersFuryBuff) and not Variables.Holdconvoke and ( EffectiveComboPoints <= 4 or PlayerHasBuff(BsIncBuff) and EffectiveComboPoints <= 3 ) ) then
            NGSend("Convoke the Spirits") return true end
    end
    
    if OffCooldown(ids.Prowl) and ( IsBerserk == false and not PlayerHasBuff(ids.Prowl) ) then
        NGSend("Prowl") return true end
    
    if OffCooldown(ids.Rake) and ( PlayerHasBuff(ids.ShadowmeldBuff) or PlayerHasBuff(ids.Prowl) ) then
        NGSend("Rake") return true end
    
    if OffCooldown(ids.AdaptiveSwarm) and ( GetTargetStacks(ids.AdaptiveSwarmDamageDebuff) < 3 and ( not TargetHasDebuff(ids.AdaptiveSwarmDamageDebuff) or GetRemainingDebuffDuration("target", ids.AdaptiveSwarmDamageDebuff) < 2 ) and not (aura_env.PrevCast == ids.AdaptiveSwarm and GetTime() - aura_env.PrevCastTime < 0.15) and ( NearbyEnemies <= 1 or not IsPlayerSpell(ids.UnbridledSwarmTalent) ) and ( TargetHasDebuff(ids.Rip) or IsPlayerSpell(ids.Ravage) ) ) then
        NGSend("Adaptive Swarm") return true end
    
    if OffCooldown(ids.AdaptiveSwarm) and ( PlayerHasBuff(ids.CatFormBuff) and GetTargetStacks(ids.AdaptiveSwarmDamageDebuff) < 3 and IsPlayerSpell(ids.UnbridledSwarmTalent) and NearbyEnemies > 1 and TargetHasDebuff(ids.Rip) ) then
        NGSend("Adaptive Swarm") return true end
    
    if OffCooldown(ids.FerociousBite) and ( PlayerHasBuff(ids.ApexPredatorsCravingBuff) and not ( Variables.NeedBt and BloodTalonsCount == 2 ) ) then
        NGSend("Ferocious Bite") return true end
    
    if TargetHasDebuff(ids.Rip) then
        if Cooldown() then return true end end
    
    if OffCooldown(ids.Rip) and ( NearbyEnemies <= 1 and IsPlayerSpell(ids.ThrivingGrowthTalent) and not ( IsPlayerSpell(ids.RagingFuryTalent) and IsPlayerSpell(ids.VeinripperTalent) ) and ( PlayerHasBuff(ids.BloodtalonsBuff) or not IsPlayerSpell(ids.BloodtalonsTalent) ) and (GetRemainingDebuffDuration("target", ids.Rip) < 5 and GetRemainingAuraDuration("player", ids.TigersFury) > 10 and EffectiveComboPoints >= 3 or(( GetRemainingAuraDuration("player", ids.TigersFury) < 3 and EffectiveComboPoints == 5) or GetRemainingAuraDuration("player", ids.TigersFury) <= 1) and PlayerHasBuff(ids.TigersFury) and EffectiveComboPoints >= 3 and GetRemainingDebuffDuration("target", ids.Rip) < GetRemainingAuraDuration("player", ids.TigersFury) ) ) then
        NGSend("Rip") return true end

    if IsBerserk and not PlayerHasBuff(ids.RavageBuff) and not PlayerHasBuff(ids.CoiledToSpringBuff) and IsPlayerSpell(ids.RavageTalent) and IsPlayerSpell(ids.CoiledToSpringTalent) and NearbyEnemies <= 2 then
        if Builder() then return true end end
    
    if EffectiveComboPoints == 5 then
        if Finisher() then return true end end
    
    if NearbyEnemies <= 1 and EffectiveComboPoints < 5 and ( Variables.TimeToPool <= 0 or not Variables.NeedBt or aura_env.ProccingBt ) then
        if Builder() then return true end end
    
    if NearbyEnemies >= 2 and EffectiveComboPoints < 5 and ( Variables.TimeToPool <= 0 or not Variables.NeedBt or aura_env.ProccingBt ) then
        if AoeBuilder() then return true end end
    
    NGSend("Clear")
end