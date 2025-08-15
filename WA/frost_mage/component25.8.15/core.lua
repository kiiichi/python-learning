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
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) and select(6, strsplit("-", UnitGUID(unit))) ~= "229296" then -- Skip Orb of Ascendance
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
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and ( IsPlayerSpell(ids.FrostfireBoltTalent) or NearbyEnemies >= 3 ) ) then
        ExtraGlows.IcyVeins = true end
    
    if OffCooldown(ids.IcyVeins) and ( GetRemainingAuraDuration("player", ids.IcyVeinsBuff) < 1.5 and IsPlayerSpell(ids.SplinterstormTalent) ) then
        ExtraGlows.IcyVeins = true end

    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    Variables.Boltspam = IsPlayerSpell(ids.SplinterstormTalent) and IsPlayerSpell(ids.ColdFrontTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent) and IsPlayerSpell(ids.FrozenTouchTalent) or IsPlayerSpell(ids.FrostfireBoltTalent) and IsPlayerSpell(ids.DeepShatterTalent) and IsPlayerSpell(ids.SlickIceTalent) and IsPlayerSpell(ids.DeathsChillTalent)
    
    Variables.TargetIsFrozen = TargetHasDebuff(ids.IceNova) or TargetHasDebuff(ids.Freeze) or TargetHasDebuff(ids.FrostNova)

    -- Kichi add for equipment check
    Variables.ArazsRitualForgeEquipped = C_Item.IsEquippedItem(242402)

    local Movement = function()
        if OffCooldown(ids.Flurry) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        if OffCooldown(ids.CometStorm) and ( IsPlayerSpell(ids.SplinterstormTalent) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end


        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true then
            KTrig("Ice Nova") return true end
        
        if OffCooldown(ids.IceLance) then
            KTrig("Ice Lance") return true end
    end
    
    local FfAoe = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) then
            -- KTrig("Cone Of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone Of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone Of Cold") 
                return true
            end
        end

        if OffCooldown(ids.Freeze) and aura_env.config["Freezable"] == true and ( not (aura_env.PrevCast == ids.Freeze) and (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm) ) ) ) then
           KTrig("Freeze") return true end
        
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( not (aura_env.PrevCast == ids.Freeze) and (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm) ) ) ) then
            KTrig("Ice Nova") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and not ( aura_env.PrevCast == ids.Freeze ) and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike) ) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            KTrig("Blizzard") return true end

        -- During Icy Veins stack Death's Chill to 12 while keeping Blizzard and Frozen Orb on cooldown.
        if OffCooldown(ids.FrostfireBolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 9 or GetPlayerStacks(ids.DeathsChillBuff) == 9 and not (aura_env.PrevCast == ids.FrostfireBolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostfire Bolt") return true end
        
        -- Don't munch Excess Fire before pressing the 2nd Comet Storm in the Cone of Cold sequence. Only relevant for Deaths Chill builds.
        if OffCooldown(ids.IceLance) and ( IsPlayerSpell(ids.DeathsChillTalent) and GetPlayerStacks(ids.ExcessFireBuff) == 2 and OffCooldown(ids.CometStorm) ) then
            KTrig("Ice Lance") return true end

        -- Hold Comet Storm for up to 12 seconds for Cone of Cold.
        if OffCooldown(ids.CometStorm) and ( GetRemainingSpellCooldown(ids.ConeOfCold) > 12 or OffCooldown(ids.ConeOfCold) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            -- KTrig("Ray Of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray Of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray Of Frost") 
                return true
            end
        end

        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        -- Cast Flurry to spend Excess Frost.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ExcessFrostBuff) ) then
            KTrig("Flurry") return true end

        -- Kichi add equipment check for simc
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( not Variables.ArazsRitualForgeEquipped or not PlayerHasBuff(ids.IcyVeinsBuff) ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) and GetRemainingSpellCooldown(ids.Blizzard) > 6 * max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end
        
        if OffCooldown(ids.FrostfireBolt) and ( PlayerHasBuff(ids.FrostfireEmpowermentBuff) and not PlayerHasBuff(ids.ExcessFireBuff) ) then
            KTrig("Frostfire Bolt") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end
    
    local FfCleave = function()
        -- If one of your targets doesnt have Winter's Chill up, target-swap and queue a Flurry after casting Glacial Spike, Frostfire Bolt or Comet Storm.
        if OffCooldown(ids.Flurry) and ( TargetHasDebuff(ids.WintersChillDebuff) == false and OffCooldown(ids.Flurry) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) or (aura_env.PrevCast == ids.CometStorm or IsCasting(ids.CometStorm)) ) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.CometStorm) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end

        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and PlayerHasBuff(ids.FreezingRainBuff) ) then
            KTrig("Blizzard") return true end

        -- Kichi add equipment check for simc
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( not Variables.ArazsRitualForgeEquipped or PlayerHasBuff(ids.IcyVeinsBuff) == false ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        -- Without Death's Chill talented, also cast Ice Lance into any target with 2 stacks of Winter's Chill.
        if OffCooldown(ids.IceLance) and ( not IsPlayerSpell(ids.DeathsChillTalent) and GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            KTrig("Ice Lance") return true end

        -- Always cast Frostfire Bolt at the target with the lowest number of Winter's Chill stacks.
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end

    local FfSt = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            KTrig("Flurry") return true end

        -- Cast Flurry with 3+ Icicles to guarantee shattering the Glacial Spike + Pyroblast into Winter's Chill. This also means queueing Flurry when casting Frostfire Bolt with 2+ Icicles and overcapping freely.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and ( CurrentIcicles >= 3 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end

        if OffCooldown(ids.RayOfFrost) and ( GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            -- KTrig("Ray Of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray Of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray Of Frost") 
                return true
            end
        end

        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        if OffCooldown(ids.FrozenOrb) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        -- Kichi add equipment check for simc
        -- With Araz's Ritual Forge equipped only cast Shifting Power outside of Icy Veins to create more overlap with subsequent Icy Veins.
        if OffCooldown(ids.ShiftingPower) and ( ( not Variables.ArazsRitualForgeEquipped or PlayerHasBuff(ids.IcyVeinsBuff) == false ) and GetRemainingSpellCooldown(ids.IcyVeins) > 8 and ( GetRemainingSpellCooldown(ids.CometStorm) > 8 or not IsPlayerSpell(ids.CometStormTalent) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end

    -- The Boltspam roation is used whenever all of Death's Chill, Cold Front, Slick Ice and at least one point of Deep Shatter is talented.
    local FfStBoltspam = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            KTrig("Flurry") return true end
        
        -- Queue Flurry whenever casting Frostfire Bolt with 2+ Icicles.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.FrostfireBolt or IsCasting(ids.FrostfireBolt)) and CurrentIcicles >= 3 ) then
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.CometStorm) and ( GetTargetStacks(ids.WintersChillDebuff) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetRemainingSpellCooldown(ids.CometStorm) > 8 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) == 2 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) and CurrentIcicles == 0 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.FrostfireBolt) then
            KTrig("Frostfire Bolt") return true end
        
        if Movement() then return true end
    end

    local SsAoe = function()
        if OffCooldown(ids.ConeOfCold) and ( IsPlayerSpell(ids.ColdestSnapTalent) and ( (aura_env.PrevCast == ids.FrozenOrb or IsCasting(ids.FrozenOrb)) or GetRemainingSpellCooldown(ids.FrozenOrb) > 30 ) ) then
            -- KTrig("Cone Of Cold") return true end
            if aura_env.config[tostring(ids.ConeOfCold)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Cone Of Cold")
            elseif aura_env.config[tostring(ids.ConeOfCold)] ~= true then
                KTrig("Cone Of Cold") 
                return true
            end
        end

        -- Cast Ice Nova against 5+ freezable targets to consume the Winter's Chill debuff applied by Cone of Cold in the very last moment of its duration.
        if OffCooldown(ids.IceNova) and aura_env.config["Freezable"] == true and ( ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) or IsPlayerSpell(ids.UnerringProficiencyTalent) ) and NearbyEnemies >= 5 and CurrentTime - aura_env.ConeOfColdLastUsed < 8 and CurrentTime - aura_env.ConeOfColdLastUsed > 7 ) then
            KTrig("Ice Nova") return true end

        -- Cast Pet Freeze whenever you cast Glacial Spike against freezable targets to shatter the second Glacial Spike.
        if OffCooldown(ids.Freeze) and aura_env.config["Freezable"] == true and ( (UnitLevel("target") > 0 and not Variables.TargetIsFrozen) and ( (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) or not IsPlayerSpell(ids.GlacialSpikeTalent) and CurrentTime - aura_env.ConeOfColdLastUsed > 8 ) ) then
            KTrig("Freeze") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and GetTargetStacks(ids.WintersChillDebuff) == 0 and TargetHasDebuff(ids.WintersChillDebuff) == false and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            KTrig("Flurry") return true end

        -- Cast Flurry regardless of Winter's Chill to spend the Cold Front buff.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and PlayerHasBuff(ids.ColdFrontReadyBuff) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( IsPlayerSpell(ids.IceCallerTalent) or IsPlayerSpell(ids.FreezingRainTalent) ) then
            KTrig("Blizzard") 
            return true end
        
        if OffCooldown(ids.CometStorm) and ( IsPlayerSpell(ids.GlacialAssaultTalent) or PlayerHasBuff(ids.IcyVeinsBuff) == false ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        if OffCooldown(ids.RayOfFrost) and ( IsPlayerSpell(ids.SplinteringRayTalent) and PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            -- KTrig("Ray Of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray Of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray Of Frost") 
                return true
            end
        end
        
        if OffCooldown(ids.ShiftingPower) and ( IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        -- Not munching Fingers of Frost is more important than munching Icicles.
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 and IsPlayerSpell(ids.GlacialSpikeTalent) ) then
            KTrig("Ice Lance") return true end

        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        -- During Icy Veins stack Deaths Chill to 9 before using regular Ice Lances.
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 6 or GetPlayerStacks(ids.DeathsChillBuff) == 6 and not (IsCasting(ids.Frostbolt) or aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end
        
        if OffCooldown(ids.ShiftingPower) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local SsCleave = function()
        -- Flurry the off-target after Glacial Spike to make it shatter on both targets.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            KTrig("Flurry") return true end
        -- With Shifting Shards talented cast Flurry with or without precast to spend the Cold Front buff.
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and IsPlayerSpell(ids.ShiftingShardsTalent) and PlayerHasBuff(ids.ColdFrontReadyBuff) ) then
            KTrig("Flurry") return true end

        -- Not munching Fingers of Frost is more important than munching Icicles.
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) == 2 and IsPlayerSpell(ids.GlacialSpikeTalent) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        if OffCooldown(ids.CometStorm) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 and IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end
        
        -- Kichi add equipment check for simc
        if OffCooldown(ids.ShiftingPower) and ( not Variables.ArazsRitualForgeEquipped and C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 or IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end

        -- Kichi add because simc has it, but NG not have it
        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            KTrig("Blizzard") return true end

        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        -- In Icy Veins only ever cast Ice Lance with Fingers of Frost until you have at least 10 Deaths Chill stacks.
        if OffCooldown(ids.Frostbolt) and ( IsPlayerSpell(ids.DeathsChillTalent) and PlayerHasBuff(ids.IcyVeinsBuff) and ( GetPlayerStacks(ids.DeathsChillBuff) < 8 or GetPlayerStacks(ids.DeathsChillBuff) == 8 and not (IsCasting(ids.Frostbolt) or aura_env.PrevCast == ids.Frostbolt and GetTime() - aura_env.PrevCastTime < 0.15) ) ) then
            KTrig("Frostbolt") return true end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end
        
        -- Kichi add equipment check for simc
        if OffCooldown(ids.ShiftingPower) and ( Variables.ArazsRitualForgeEquipped and PlayerHasBuff(ids.IcyVeinsBuff) == false and C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
        if Movement() then return true end
    end
    
    local SsSt = function()
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and (aura_env.PrevCast == ids.GlacialSpike or IsCasting(ids.GlacialSpike)) ) then        
            KTrig("Flurry") return true end
        
        if OffCooldown(ids.Flurry) and ( OffCooldown(ids.Flurry) and TargetHasDebuff(ids.WintersChillDebuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 0 and ( CurrentIcicles < 5 or not IsPlayerSpell(ids.GlacialSpikeTalent) ) and (aura_env.PrevCast == ids.Frostbolt or IsCasting(ids.Frostbolt)) ) then
            KTrig("Flurry") return true end

        if OffCooldown(ids.FrozenOrb) and ( OffCooldown(ids.FrozenOrb) ) then
            -- KTrig("Frozen Orb") return true end
            if aura_env.config[tostring(ids.FrozenOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frozen Orb")
            elseif aura_env.config[tostring(ids.FrozenOrb)] ~= true then
                KTrig("Frozen Orb") 
                return true
            end
        end

        if OffCooldown(ids.CometStorm) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) > 0 and IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            -- KTrig("Comet Storm") return true end
            if aura_env.config[tostring(ids.CometStorm)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Comet Storm")
            elseif aura_env.config[tostring(ids.CometStorm)] ~= true then
                KTrig("Comet Storm") 
                return true
            end
        end

        if OffCooldown(ids.RayOfFrost) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and GetTargetStacks(ids.WintersChillDebuff) == 1 ) then
            -- KTrig("Ray Of Frost") return true end
            if aura_env.config[tostring(ids.RayOfFrost)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Ray Of Frost")
            elseif aura_env.config[tostring(ids.RayOfFrost)] ~= true then
                KTrig("Ray Of Frost") 
                return true
            end
        end

        -- Kichi add equipment check for simc
        if OffCooldown(ids.ShiftingPower) and ( not Variables.ArazsRitualForgeEquipped and C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 or IsPlayerSpell(ids.ShiftingShardsTalent) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        -- Cast Glacial Spike if you can shatter it into Winter's Chill or with a followup Flurry.
        if OffCooldownNotCasting(ids.GlacialSpike) and ( CurrentIcicles == 5 and ( OffCooldown(ids.Flurry) or GetTargetStacks(ids.WintersChillDebuff) > 0 ) ) then
            -- KTrig("Glacial Spike") return true end
            if aura_env.config[tostring(ids.GlacialSpike)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Glacial Spike")
            elseif aura_env.config[tostring(ids.GlacialSpike)] ~= true then
                KTrig("Glacial Spike") 
                return true
            end
        end
        
        if OffCooldownNotCasting(ids.Blizzard) and ( PlayerHasBuff(ids.IcyVeinsBuff) == false and PlayerHasBuff(ids.FreezingRainBuff) and IsPlayerSpell(ids.IceCallerTalent) ) then
            KTrig("Blizzard") return true end
        
        if OffCooldown(ids.IceLance) and ( PlayerHasBuff(ids.FingersOfFrostBuff) ) then
            KTrig("Ice Lance") return true end

        if OffCooldown(ids.IceLance) and ( GetTargetStacks(ids.WintersChillDebuff) > 0 ) then
            KTrig("Ice Lance") return true end

        -- Kichi add equipment check for simc
        if OffCooldown(ids.ShiftingPower) and ( Variables.ArazsRitualForgeEquipped and PlayerHasBuff(ids.IcyVeinsBuff) == false and C_Spell.GetSpellCharges(ids.Flurry).currentCharges < 2 and GetRemainingSpellCooldown(ids.IcyVeins) > 8 ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power") 
                return true
            end
        end

        if OffCooldown(ids.Frostbolt) then
            KTrig("Frostbolt") return true end
        
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
    
    KTrig("Clear")
    KTrigCD("Clear")
    
end
