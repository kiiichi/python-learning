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
        --if OffCooldown(ids.IceFloes) and ( PlayerHasBuff(ids.IceFloesBuff) == false ) then
        --    NGSend("Ice Floes") return true end
        
        if OffCooldown(ids.IceNova) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.ConeOfCold) and ( not IsPlayerSpell(ids.ColdestSnapTalent) and NearbyEnemies >= 2 ) then
            NGSend("Cone of Cold") return true end
        
        --if OffCooldown(ids.ArcaneExplosion) and ( (CurrentMana/MaxMana*100) > 30 and NearbyEnemies >= 2 ) then
        --    NGSend("Arcane Explosion") return true end
        
        --if OffCooldown(ids.FireBlast) then
        --    NGSend("Fire Blast") return true end
        
        if OffCooldown(ids.IceLance) then
            NGSend("Ice Lance") return true end
    end
        
    local AoeFf = function()
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostfire Bolt") return true end
        
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) then
            NGSend("Cone of Cold") return true end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and TIME SINCE FIGHT START REMOVE MANUALLY - aura_env.ConeOfColdLastUsed > 8 ) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 ) ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.IceLance) and ( GetPlayerStacks(ids.ExcessFireBuff) == 2 and OffCooldown(ids.CometStorm) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetRemainingSpellCooldown(ids.ConeOfCold) > 10 or OffCooldown(ids.ConeOfCold) ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            NGSend("Frostfire Bolt") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
        
    local AoeSs = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and not OffCooldown(ids.FrozenOrb) and ( (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) or (aura_env.PrevCast == ids.FrozenOrb or IsCasting(ids.FrozenOrb)) and GetRemainingSpellCooldown(ids.CometStorm) > 5 ) and ( not IsPlayerSpell(ids.DeathsChillTalent) or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) >= 15 ) ) then
            NGSend("Cone of Cold") return true end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or not IsPlayerSpell(ids.GlacialSpikeTalent) ) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.IceNova) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.IceNova) and ( IsPlayerSpell(ids.UnerringProficiencyTalent) and CurrentTime - aura_env.ConeOfColdLastUsed < 10 and CurrentTime - aura_env.ConeOfColdLastUsed > 7 ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 12 or GetPlayerStacks(ids.DeathsChillBuff) == 12 and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostbolt") return true end
        
        if OffCooldown(ids.CometStorm) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) ) ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end
        
    local CleaveFf = function()
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 4 or GetPlayerStacks(ids.DeathsChillBuff) == 4 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostfire Bolt") return true end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and not (aura_env.PrevCast == ids.Freeze) ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and not (aura_env.PrevCast == ids.Freeze) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.Blizzard) and ( PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            NGSend("Frostfire Bolt") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
        
    local CleaveSs = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and not (aura_env.PrevCast == ids.Freeze) ) then
            NGSend("Flurry") return true end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    NGSend("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            NGSend("Ice Nova") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 30 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) ) ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 6 or GetPlayerStacks(ids.DeathsChillBuff) == 6 and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            NGSend("Frostbolt") return true end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.FreezingRainTalent) and IsPlayerSpell(ids.IceCallerTalent) ) then
            NGSend("Blizzard") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end
        
    local StFf = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and PlayerHasBuff(ids.ExcessFireBuff) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.FrozenOrb) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            NGSend("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
        
    local StSs = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) ) then
            NGSend("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            NGSend("Comet Storm") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 30 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            NGSend("Frozen Orb") return true end
        
        if OffCooldown(ids.RayOfFrost) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) ) then
            NGSend("Ray of Frost") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) ) ) then
            NGSend("Glacial Spike") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( FightRemains(60, NearbyRange) + 15 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            NGSend("Shifting Power") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or GetTargetStacks(ids.WintersChillDebuff) ) then
            NGSend("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            NGSend("Frostbolt") return true end
        
        if Movement() then return true end
    end

    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies >= 3 then
        AoeFf() return true end
    
    if NearbyEnemies >= 3 then
        AoeSs() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) and NearbyEnemies == 2 then
        CleaveFf() return true end
    
    if NearbyEnemies == 2 then
        CleaveSs() return true end
    
    if IsPlayerSpell(ids.FrostfireBoltTalent) then
        StFf() return true end
    
    if StSs() then return true end
    
    NGSend("Clear")
end