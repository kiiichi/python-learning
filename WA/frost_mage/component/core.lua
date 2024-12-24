------------------
-- 核心触发器1 --
------------------
env.test = function()
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
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
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
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)

    local CurrentIcicles = GetPlayerStacks(ids.IciclesBuff)
    if IsCasting(ids.Frostbolt) then CurrentIcicles = min(CurrentIcicles + 1, 5) 
    elseif IsCasting(ids.GlacialSpike) then CurrentIcicles = 0 end
    
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Icy Veins
    if OffCooldown(ids.IcyVeins) and (GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) then
        ExtraGlows.IcyVeins = true
    end
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    Variables.Boltspam = IsPlayerSpell(ids.SplinterstormTalent) and IsPlayerSpell(ids.ColdFrontTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent) and IsPlayerSpell(ids.FrozenTouchTalent) or IsPlayerSpell(ids.FrostfireBoltTalent) and IsPlayerSpell(ids.DeepShatterTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent)
    
    Variables.TargetIsFrozen = TargetHasDebuff(ids.IceNova) or TargetHasDebuff(ids.Freeze) or TargetHasDebuff(ids.FrostNova)
    
    local Movement = function()
        if OffCooldown(ids.IceNova) then
            KTrig("Ice Nova") return true end
        
        if OffCooldown(ids.ConeOfCold) and ( not IsPlayerSpell(ids.ColdestSnapTalent) and NearbyEnemies >= 2 ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end
        
        if OffCooldown(ids.ArcaneExplosion) and ( (CurrentMana/MaxMana*100) > 30 and NearbyEnemies >= 2 ) then
            KTrig("Arcane Explosion") return true end
        
        if OffCooldown(ids.IceLance) then
            KTrig("Ice Lance") return true end
    end
    
    local AoeFf = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not ((aura_env.PrevCast == ids.FrostfireBolt or aura_env.PrevCast2 == ids.FrostfireBolt) and GetTime() - aura_env.PrevCastTime < 0.25 or IsCasting(ids.FrostfireBolt)) ) )  then
            KTrig("Frostfire Bolt") 
            return true end
        
        -- if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and GetRemainingSpellCooldown(ids.ConeOfCold) and not (aura_env.PrevCast2 == ids.ConeOfCold) ) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) and GetRemainingSpellCooldown(ids.ConeOfCold) and not (aura_env.PrevCast2 == ids.ConeOfCold) ) and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Ice Nova") 
            return true end
        
        if OffCooldown(ids.FrozenOrb) and ( not (aura_env.PrevCast == ids.ConeOfCold or IsCasting(ids.ConeOfCold)) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.CometStorm) and ( GetRemainingSpellCooldown(ids.ConeOfCold) > 6 or OffCooldown(ids.ConeOfCold) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( PlayerHasBuff(ids.ExcessFrostBuff) and GetRemainingSpellCooldown(ids.CometStorm) > 5 or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
            KTrig("Flurry") 
            return true end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) ) then
            KTrig("Blizzard") 
            return true end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFrostBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            KTrig("Frostfire Bolt") 
            return true end
        
        if OffCooldown(ids.GlacialSpike) and ( ( NearbyEnemies <= 6 or not IsPlayerSpell(ids.IceCallerTalent) ) and CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) ) then
            KTrig("Ice Lance")
            return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
            KTrig("Flurry") 
            return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") 
            return true end
        
        if Movement() then return true end

    end
    
    local AoeSs = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and not OffCooldown(ids.FrozenOrb) and ( (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) or (aura_env.PrevCast == ids.FrozenOrb or IsCasting(ids.FrozenOrb)) and GetRemainingSpellCooldown(ids.CometStorm) > 5 ) and ( not IsPlayerSpell(ids.DeathsChillTalent) or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) >= 12 ) ) then
            -- KTrig("Cone of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone of Cold") 
                return true
            end
        end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Flurry") 
            return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( NearbyEnemies < 5 and (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or NearbyEnemies >= 5 and CurrentTime - aura_env.ConeOfColdLastUsed < 6 and CurrentTime - aura_env.ConeOfColdLastUsed > 6 - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) then
            KTrig("Ice Nova") 
            return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") 
            return true end
        
        if OffCooldown(ids.CometStorm) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) or NearbyEnemies >= 5 ) then
            KTrig("Blizzard") 
            return true end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or NearbyEnemies < 5 and (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) and not PlayerHasBuff(ids.FingersOfFrostBuff) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local CleaveFf = function()
        if OffCooldown(ids.CometStorm) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < 6 or GetPlayerStacks(ids.DeathsChillBuff) == 6 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostfire Bolt") return true end
        
        -- if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Ice Nova") return true end
        
        -- if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or CurrentIcicles >= 3 ) and not (aura_env.PrevCast == ids.Freeze) ) then
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or CurrentIcicles >= 3 or not IsPlayerSpell(ids.GlacialSpikeTalent) and (aura_env.PrevCast == ids.FrostfireBolt and (GetTime() - aura_env.PrevCastTime < 1 or IsCasting(ids.FrostfireBolt)))  ) and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and not (aura_env.PrevCast == ids.Freeze) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            else
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFrostBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            KTrig("Frostfire Bolt") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( not PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        -- if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or GetTargetStacks(ids.WintersChillDebuff) > 0 and not Variables.Boltspam ) then
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and (  not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or GetTargetStacks(ids.WintersChillDebuff) == 0  ) or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) and not Variables.Boltspam ) then

            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local CleaveSs = function()
        if OffCooldown(ids.CometStorm) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false ) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        --if OffCooldown(ids.Freeze) and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
        --    KTrig("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and not (aura_env.PrevCast == ids.Freeze) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false ) then
            KTrig("Ice Nova") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 22 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and OffCooldown(ids.IceNova) and not PlayerHasBuff(ids.FingersOfFrostBuff) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and ( GetPlayerStacks(ids.DeathsChillBuff) < ( 8 + 4 * (IsPlayerSpell(ids.SlickIceTalent) and 1 or 0) ) or GetPlayerStacks(ids.DeathsChillBuff) == ( 8 + 4 * (IsPlayerSpell(ids.SlickIceTalent) and 1 or 0) ) and not (aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or not Variables.Boltspam and (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local StFf = function()
        if OffCooldown(ids.CometStorm) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        -- if OffCooldown(ids.Flurry) and ( Variables.Boltspam and OffCooldown(ids.Flurry) and CurrentIcicles < 5 and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
        if OffCooldown(ids.Flurry) and ( Variables.Boltspam and OffCooldown(ids.Flurry) and (CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent)) and GetTargetStacks(ids.WintersChillDebuff) == 0 ) then
            KTrig("Flurry") return true end
        
        -- if OffCooldown(ids.Flurry) and ( not Variables.Boltspam and OffCooldown(ids.Flurry) and CurrentIcicles < 5 and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
        if OffCooldown(ids.Flurry) and ( not Variables.Boltspam and OffCooldown(ids.Flurry) and (CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.IceLance) and ( Variables.Boltspam and PlayerHasBuff(ids.ExcessFireBuff) and not PlayerHasBuff(ids.BrainFreezeBuff) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 and ( not Variables.Boltspam or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 15 ) ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.FrozenOrb) and ( Variables.Boltspam and PlayerHasBuff(ids.IcyVeinsBuff) == false or not Variables.Boltspam and not PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( ( PlayerHasBuff(ids.IcyVeinsBuff) == false or not Variables.Boltspam ) and GetRemainingSpellCooldown(ids.IcyVeins) > 10 and GetRemainingSpellCooldown(ids.FrozenOrb) > 10 and ( not IsPlayerSpell(ids.CometStormTalent) or GetRemainingSpellCooldown(ids.CometStorm) > 10 ) and ( not IsPlayerSpell(ids.RayOfFrostTalent) or GetRemainingSpellCooldown(ids.RayOfFrost) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        -- if OffCooldown(ids.IceLance) and ( not Variables.Boltspam and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) ) then
        if OffCooldown(ids.IceLance) and ( not Variables.Boltspam and ( PlayerHasBuff(ids.FingersOfFrostBuff) and GetTargetStacks(ids.WintersChillDebuff) == 0 or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) ) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local StSs = function()
        if OffCooldown(ids.CometStorm) and ( (aura_env.PrevCast == ids.Flurry or IsCasting(ids.Flurry)) and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) or (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 22 or PlayerHasBuff(ids.IcyVeinsBuff) ) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldown(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 or GetRemainingSpellCooldown(ids.Flurry) < max(C_Spell.GetSpellInfo(ids.GlacialSpike).castTime/1000, WeakAuras.gcdDuration()) and GetRemainingSpellCooldown(ids.Flurry) > 0 ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( Variables.Boltspam and GetTargetStacks(ids.WintersChillDebuff) > 0 and PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( not Variables.Boltspam and GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            -- KTrig("Ray of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( GetRemainingSpellCooldown(ids.IcyVeins) > 10 and not OffCooldown(ids.Flurry) and ( Variables.Boltspam or PlayerHasBuff(ids.IcyVeinsBuff) == false or GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 10 ) and ( FightRemains(60, NearbyRange) + 10 > GetRemainingSpellCooldown(ids.IcyVeins) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.Frostbolt) and ( Variables.Boltspam and GetRemainingAuraDuration("player", ids.IcyVeinsBuff) > 9 and GetPlayerStacks(ids.DeathsChillBuff) < 8 ) then
            KTrig("Frostbolt") return true end
        
        if OffCooldown(ids.IceLance) and ( Variables.Boltspam and ( GetTargetStacks(ids.WintersChillDebuff) == 2 or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) and OffCooldown(ids.Flurry) ) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( not Variables.Boltspam and ( PlayerHasBuff(ids.FingersOfFrostBuff) and not (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (GetTargetStacks(ids.WintersChillDebuff) > 0 and not (GetTargetStacks(ids.WintersChillDebuff) == 1 and (IsCasting(ids.FrostfireBolt) or IsCasting(ids.GlacialSpike))) ) ) ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
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
        StFf() return true
    else
        StSs() return true 
    end
    
    KTrig("Clear")
    KTrigCD("Clear")
    
end