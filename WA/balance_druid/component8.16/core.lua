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
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1921)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1694)
    
    local CurrentEclipseID = (PlayerHasBuff(ids.EclipseSolarBuff) and ids.EclipseSolarBuff or nil)
    if CurrentEclipseID == nil then CurrentEclipseID = (PlayerHasBuff(ids.EclipseLunarBuff) and ids.EclipseLunarBuff or nil) end
    
    local CurrentAstralPower = UnitPower("player", Enum.PowerType.AstralPower)
    local MaxAstralPower = UnitPowerMax("player", Enum.PowerType.AstralPower)
    
    local _, _, _, _, CurrentCast = select(5, UnitCastingInfo("player"))
    local GoingIntoLunar = false
    local GoingIntoSolar = false
    if CurrentCast ~= nil then
        if CurrentCast == ids.Wrath then
            CurrentAstralPower = CurrentAstralPower + 6
            if ( IsPlayerSpell(ids.WildSurgesTalent) ) then
                CurrentAstralPower = CurrentAstralPower + 2
            end
            if C_Spell.GetSpellCastCount(ids.Wrath) == 1 then
                GoingIntoLunar = true
            end
        elseif CurrentCast == ids.Starfire then
            CurrentAstralPower = CurrentAstralPower + 10
            if ( IsPlayerSpell(ids.WildSurgesTalent) ) then
                CurrentAstralPower = CurrentAstralPower + 2
            end
            if C_Spell.GetSpellCastCount(ids.Starfire) == 1 then
                GoingIntoSolar = true
            end
        elseif CurrentCast == ids.NewMoon then
            CurrentAstralPower = CurrentAstralPower + 10
        elseif CurrentCast == ids.HalfMoon then
            CurrentAstralPower = CurrentAstralPower + 20
        elseif CurrentCast == ids.FullMoon then
            CurrentAstralPower = CurrentAstralPower + 40
        end
    end
    
    ids.CaInc = (IsPlayerSpell(ids.IncarnationTalent) and ids.Incarnation or ids.CelestialAlignmentCooldown)
    if IsPlayerSpell(ids.IncarnationTalent) then
        ids.CaIncBuff = IsPlayerSpell(ids.OrbitalStrikeTalent) and ids.IncarnationOrbitalStrikeBuff or ids.IncarnationBuff
    else
        ids.CaIncBuff = IsPlayerSpell(ids.OrbitalStrikeTalent) and ids.CelestialAlignmentOrbitalStrikeBuff or ids.CelestialAlignmentBuff
    end
    local CaIncOffCooldown = (GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation)) or (GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation))
    
    local HasMoonCharge = C_Spell.GetSpellCharges(ids.NewMoon).currentCharges > 2 or (C_Spell.GetSpellCharges(ids.NewMoon).currentCharges == 1 and not IsCasting(ids.NewMoon) and not IsCasting(ids.HalfMoon) and not IsCasting(ids.FullMoon))
    
    local InEclipse = (PlayerHasBuff(ids.EclipseLunarBuff) or GoingIntoLunar) or (PlayerHasBuff(ids.EclipseSolarBuff) or GoingIntoSolar)
    
    local NearbyRange = 45
    local NearbyEnemies = 0
    local MoonfiredEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
            if WA_GetUnitDebuff(unit, ids.MoonfireDebuff, "PLAYER") then
                MoonfiredEnemies = MoonfiredEnemies + 1
            end
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    
    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Variables ------------------------------------------------------------------------------------------------
    -- Variable to establish passive AP gen
    Variables.PassiveAsp = 6 / (1-UnitSpellHaste("player")/100) + (IsPlayerSpell(ids.NaturesBalanceTalent) and 1 or 0) + (((IsPlayerSpell(ids.BounteousBloomTalent) and CurrentTime - aura_env.LastForceOfNature < 10) and 1 or 0) * 15) + (IsPlayerSpell(ids.OrbitBreakerTalent) and 1 or 0) * (TargetHasDebuff(ids.MoonfireDebuff) and 1 or 0) * ( (aura_env.OrbitBreakerBuffStacks > ( 27 - 2 * (PlayerHasBuff(ids.SolsticeBuff) and 1 or 0) ) ) and 1 or 0) * 24
    
    -- Convoke condition variable
    Variables.ConvokeCondition = FightRemains(60, NearbyRange) < 5 or ( PlayerHasBuff(ids.CaIncBuff) or GetRemainingSpellCooldown(ids.CaInc) > 40 ) and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) or GetRemainingSpellCooldown(ids.ForceOfNature) > 15 )
    
    -- Variable used to write time remaining on Eclipse
    Variables.EclipseRemains = max(GetRemainingAuraDuration("player", ids.EclipseLunarBuff), GetRemainingAuraDuration("player", ids.EclipseSolarBuff))
    
    -- Variable used to enter Eclipse. Negate variable.enter_lunar to enter Solar Eclipse.
    Variables.EnterLunar = IsPlayerSpell(ids.LunarCallingTalent) or NearbyEnemies > 3 - ( ( IsPlayerSpell(ids.UmbralEmbraceTalent) or IsPlayerSpell(ids.SoulOfTheForestTalent)) and 1 or 0)
    
    -- Variable used for Balance of All Things stacks
    Variables.BoatStacks = GetPlayerStacks(ids.BalanceOfAllThingsArcaneBuff) + GetPlayerStacks(ids.BalanceOfAllThingsNatureBuff)
    
    Variables.CaEffectiveCd = max(GetRemainingSpellCooldown(ids.CaInc), GetRemainingSpellCooldown(ids.ForceOfNature))
    
    -- Pre_Cd Condition referenced in every CD except for when using 11.2 Keeper Set
    Variables.PreCdCondition = ( not IsPlayerSpell(ids.WhirlingStarsTalent) or not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 3 or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > GetTimeToFullCharges(ids.CaInc) + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) ) and GetRemainingSpellCooldown(ids.CaInc) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and not PlayerHasBuff(ids.CaIncBuff)
    
    -- CD_condition used for CA/Incarn
    Variables.CdCondition = Variables.PreCdCondition and ( FightRemains(60, NearbyRange) < ( 15 + 5 * (IsPlayerSpell(ids.IncarnationTalent) and 1 or 0) ) * ( 1 - (IsPlayerSpell(ids.WhirlingStarsTalent) and 1 or 0) * 0.2 ) or TargetTimeToXPct(0, 60) > 10 and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) )

    -- This APL is worse than original after the changes so no point running it
    Variables.Tww3Keeper4Pc = ( IsPlayerSpell(ids.DreamSurgeTalent) and SetPieces > 4 )

    -- Keeper 11.2 CA condition ( These have gotten out of hand. NG won't update these without a reeeally good reason. )
    Variables.KotgCaCondition = Variables.Tww3Keeper4Pc and MaxAstralPower - CurrentAstralPower <= 50 and GetRemainingSpellCooldown(ids.ForceOfNature) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 and ( GetTimeToFullCharges(ids.CaInc) < 10 or not PlayerHasBuff(ids.CaIncBuff) and ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 4 or not IsPlayerSpell(ids.ConvokeTheSpirits) ) ) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) and ( GetRemainingAuraDuration("player", ids.DryadBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and PlayerHasBuff(ids.DryadBuff) or PlayerHasBuff(ids.DryadsFavorBuff) ) or FightRemains(60, NearbyRange) < 16

    -- Keeper 11.2 Incarn condition ( These have gotten out of hand. NG won't update these without a reeeally good reason. )
    Variables.KotgIncCondition = Variables.Tww3Keeper4Pc and MaxAstralPower - CurrentAstralPower <= 50 and GetRemainingSpellCooldown(ids.ForceOfNature) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and  FightRemains(60, NearbyRange) < min( GetTimeToFullCharges(ids.CaInc), GetRemainingSpellCooldown(ids.ForceOfNature) )

    -- Variable to pool Astral Power for CA with 11.2 4pc
    Variables.PoolForCd = CurrentAstralPower < 36 * 3 and ( OffCooldown(ids.ConvokeTheSpirits) or not IsPlayerSpell(ids.ConvokeTheSpirits) and not PlayerHasBuff(ids.CaIncBuff) )

    -- Variable to pool Astral Power for Dryads Favor with 11.2 4pc
    Variables.PoolInCa = PlayerHasBuff(ids.DryadBuff) and ( ( CurrentAstralPower - C_Spell.GetSpellPowerCost(ids.Starsurge)[1].cost ) + ( max( 0, ( GetRemainingAuraDuration("player", ids.DryadBuff) - max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) ) * ( 8 / max(C_Spell.GetSpellInfo(ids.Wrath).castTime/1000, WeakAuras.gcdDuration()) ) + Variables.PassiveAsp ) < C_Spell.GetSpellPowerCost(ids.Starsurge)[1].cost * 2
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}

    if OffCooldown(ids.WarriorOfElune) and Variables.Tww3Keeper4Pc and NearbyEnemies <= 1 and ( Variables.EclipseRemains <= 7 and not PlayerHasBuff(ids.DreamstateBuff) and UnitAffectingCombat("player") ) then
        ExtraGlows.WarriorOfElune = true
    end
    if OffCooldown(ids.WarriorOfElune) and not Variables.Tww3Keeper4Pc and NearbyEnemies <= 1 and ( ( IsPlayerSpell(ids.LunarCallingTalent) or not IsPlayerSpell(ids.LunarCallingTalent) and Variables.EclipseRemains <= 7 ) and not PlayerHasBuff(ids.DreamstateBuff) and UnitAffectingCombat("player") ) then
        ExtraGlows.WarriorOfElune = true
    end
    
    if OffCooldown(ids.WarriorOfElune) and NearbyEnemies > 1 and ( not IsPlayerSpell(ids.LunarCallingTalent) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < 7 or IsPlayerSpell(ids.LunarCallingTalent) and not PlayerHasBuff(ids.DreamstateBuff) and UnitAffectingCombat("player") ) then
    -- if OffCooldown(ids.WarriorOfElune) and NearbyEnemies > 1 and ( not IsPlayerSpell(ids.LunarCallingTalent) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < 7 or IsPlayerSpell(ids.LunarCallingTalent) ) then
        ExtraGlows.WarriorOfElune = true
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE APL
    local Aoe = function()
        -- Spend Dryads Favor on AoE (this is wonky)
        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.DryadsFavorBuff) ) then
            KTrig("Starsurge") return true end

        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and InEclipse and (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar) ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starfall) and ( MaxAstralPower - CurrentAstralPower <= Variables.PassiveAsp + 6 ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end

        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.MoonfireDebuff) ) > 6 and (not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or NearbyEnemies - MoonfiredEnemies > 6 or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) and select(2, GetInstanceInfo()) ~= "raid" ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Sunfire) and ( (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.SunfireDebuff) ) > 6 - ( NearbyEnemies / 2 ) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.MoonfireDebuff) ) > 6 and (not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or NearbyEnemies - MoonfiredEnemies > 6 or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) and not select(2, GetInstanceInfo()) ~= "raid" ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and ( not InEclipse or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) ) and not GoingIntoLunar and not Variables.PreCdCondition ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and ( not InEclipse or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) ) and not GoingIntoSolar ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.StellarFlare) and ( IsAuraRefreshable(ids.StellarFlare) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.StellarFlare) > 7 + NearbyEnemies ) and NearbyEnemies < ( 11 - (IsPlayerSpell(ids.UmbralIntensityTalent) and 1 or 0) - ( 2 * (IsPlayerSpell(ids.AstralSmolderTalent) and 1 or 0) ) - (IsPlayerSpell(ids.LunarCallingTalent) and 1 or 0) ) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end
        
        if OffCooldown(ids.ForceOfNature) and ( Variables.PreCdCondition or GetTimeToFullCharges(ids.CaInc) + 5 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 and ( not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 10 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + C_Spell.GetSpellCooldown(ids.ConvokeTheSpirits).duration + 5 ) and ( FightRemains(60, NearbyRange) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 + 5 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.CaInc) + 7 ) or IsPlayerSpell(ids.WhirlingStarsTalent) and IsPlayerSpell(ids.ConvokeTheSpirits) and GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > C_Spell.GetSpellCooldown(ids.ForceOfNature).duration - 10 and FightRemains(60, NearbyRange) > GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 6 ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.FuryOfElune) and ( InEclipse ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end

        -- Kichi add this for pre-cast for Incarnation
        if OffCooldown(ids.FuryOfElune) and ( Variables.CdCondition ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Celestial Alignment") return true end
            if aura_env.config[tostring(ids.CelestialAlignment)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Celestial Alignment")
            elseif aura_env.config[tostring(ids.CelestialAlignment)] ~= true then
                KTrig("Celestial Alignment")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Incarnation") return true end
            if aura_env.config[tostring(ids.Incarnation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Incarnation")
            elseif aura_env.config[tostring(ids.Incarnation)] ~= true then
                KTrig("Incarnation")
                return true
            end
        end
        
        -- Kichi moved this to No GCDs part -- 
        -- if OffCooldown(ids.WarriorOfElune) and ( not IsPlayerSpell(ids.LunarCallingTalent) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < 7 or IsPlayerSpell(ids.LunarCallingTalent) and not PlayerHasBuff(ids.DreamstateBuff) ) then
        --     -- KTrig("Warrior Of Elune") return true end
        --     if aura_env.config[tostring(ids.WarriorOfElune)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Warrior Of Elune")
        --     elseif aura_env.config[tostring(ids.WarriorOfElune)] ~= true then
        --         KTrig("Warrior Of Elune")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.Starfire) and ( ( not IsPlayerSpell(ids.LunarCallingTalent) and NearbyEnemies <= 1 ) and ( (PlayerHasBuff(ids.EclipseSolarBuff) or GoingIntoSolar) and GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) or CurrentEclipseID == nil ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starfall) and ( PlayerHasBuff(ids.StarweaversWarpBuff) or PlayerHasBuff(ids.TouchTheCosmosBuff) ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.StarweaversWeftBuff) ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Starfall) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.ConvokeTheSpirits) and ( ( not PlayerHasBuff(ids.DreamstateBuff) and not PlayerHasBuff(ids.UmbralEmbraceBuff) and NearbyEnemies < 7 or NearbyEnemies <= 1 ) and ( FightRemains(60, NearbyRange) < 5 or ( PlayerHasBuff(ids.CaIncBuff) or GetRemainingSpellCooldown(ids.CaInc) > 40 ) and ( not IsPlayerSpell(ids.DreamSurgeTalent) or PlayerHasBuff(ids.HarmonyOfTheGroveBuff) or GetRemainingSpellCooldown(ids.ForceOfNature) > 15 ) ) ) then
            -- KTrig("Convoke The Spirits") return true end
            if aura_env.config[tostring(ids.ConvokeTheSpirits)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Convoke The Spirits")
            elseif aura_env.config[tostring(ids.ConvokeTheSpirits)] ~= true then
                KTrig("Convoke The Spirits")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.NewMoon or IsCasting(ids.FullMoon)) then
            -- KTrig("New Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("New Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("New Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.HalfMoon or IsCasting(ids.NewMoon)) then
            -- KTrig("Half Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Half Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Half Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.FullMoon or IsCasting(ids.HalfMoon)) then
            -- KTrig("Full Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Full Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Full Moon")
                return true
            end
        end
        
        if OffCooldown(ids.WildMushroom) and ( aura_env.PrevCast ~= ids.WildMushroom and not IsCasting(ids.WildMushroom) and not TargetHasDebuff(ids.FungalGrowthDebuff) ) then
            -- KTrig("Wild Mushroom") return true end
            if aura_env.config[tostring(ids.WildMushroom)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wild Mushroom")
            elseif aura_env.config[tostring(ids.WildMushroom)] ~= true then
                KTrig("Wild Mushroom")
                return true
            end
        end
        
        if OffCooldown(ids.ForceOfNature) and ( not IsPlayerSpell(ids.DreamSurgeTalent) ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.Starfire) and ( IsPlayerSpell(ids.LunarCallingTalent) or ( PlayerHasBuff(ids.EclipseLunarBuff) or GoingIntoLunar) and NearbyEnemies > 3 - ( ( IsPlayerSpell(ids.UmbralEmbraceTalent) or IsPlayerSpell(ids.SoulOfTheForestTalent) ) and 1 or 0 ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Wrath) then
            KTrig("Wrath") return true end
    end
    
    -- ST APL
    local St = function()

        -- Kichi moved this to No GCDs part --
        -- if OffCooldown(ids.WarriorOfElune) and ( IsPlayerSpell(ids.LunarCallingTalent) or not IsPlayerSpell(ids.LunarCallingTalent) and Variables.EclipseRemains <= 7 ) then
        --     -- KTrig("Warrior Of Elune") return true end
        --     if aura_env.config[tostring(ids.WarriorOfElune)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Warrior Of Elune")
        --     elseif aura_env.config[tostring(ids.WarriorOfElune)] ~= true then
        --         KTrig("Warrior Of Elune")
        --         return true
        --     end
        -- end

        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar and not Variables.CdCondition ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar and not Variables.CdCondition) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Sunfire) and ( GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 3 or (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) and ( IsPlayerSpell(ids.DreamSurgeTalent) and OffCooldown(ids.ForceOfNature) or IsPlayerSpell(ids.BoundlessMoonlightTalent) and Variables.CdCondition ) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 3 and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) then
            KTrig("Moonfire") return true end
        
        if GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Celestial Alignment") return true end
            if aura_env.config[tostring(ids.CelestialAlignment)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Celestial Alignment")
            elseif aura_env.config[tostring(ids.CelestialAlignment)] ~= true then
                KTrig("Celestial Alignment")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation) and ( Variables.CdCondition ) then
            -- KTrig("Incarnation") return true end
            if aura_env.config[tostring(ids.Incarnation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Incarnation")
            elseif aura_env.config[tostring(ids.Incarnation)] ~= true then
                KTrig("Incarnation")
                return true
            end
        end
        
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and ( not InEclipse or (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) and not GoingIntoLunar) ) ) then
            KTrig("Wrath") return true end
        
        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and ( not InEclipse or (Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not GoingIntoSolar) ) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Starsurge) and ( Variables.CdCondition and MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 20 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.ForceOfNature) and ( Variables.PreCdCondition or GetTimeToFullCharges(ids.CaInc) + 5 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 and ( not IsPlayerSpell(ids.ConvokeTheSpirits) or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 10 + 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + C_Spell.GetSpellCooldown(ids.ConvokeTheSpirits).duration + 5 ) and ( FightRemains(60, NearbyRange) > GetSpellBaseCooldown(ids.ForceOfNature)/1000 + 5 or FightRemains(60, NearbyRange) < GetRemainingSpellCooldown(ids.CaInc) + 7 ) or IsPlayerSpell(ids.WhirlingStarsTalent) and IsPlayerSpell(ids.ConvokeTheSpirits) and GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > C_Spell.GetSpellCooldown(ids.ForceOfNature).duration - 10 and FightRemains(60, NearbyRange) > GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + 6 ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end
        
        if OffCooldown(ids.FuryOfElune) and ( 5 + Variables.PassiveAsp < MaxAstralPower - CurrentAstralPower ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end
            
        if OffCooldown(ids.Starfall) and ( PlayerHasBuff(ids.StarweaversWarpBuff) ) then
            -- KTrig("Starfall") return true end
            if aura_env.config[tostring(ids.Starfall)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Starfall")
            elseif aura_env.config[tostring(ids.Starfall)] ~= true then
                KTrig("Starfall")
                return true
            end
        end
        
        if OffCooldown(ids.Starsurge) and ( IsPlayerSpell(ids.StarlordTalent) and GetPlayerStacks(ids.StarlordBuff) < 3 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Sunfire) and ( (IsAuraRefreshable(ids.SunfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 5.4) ) then
            KTrig("Sunfire") return true end
        
        if OffCooldown(ids.Moonfire) and ( (IsAuraRefreshable(ids.MoonfireDebuff) and not IsPlayerSpell(ids.AetherialKindlingTalent) or GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 6.6) and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) then
            KTrig("Moonfire") return true end
        
        if OffCooldown(ids.Starsurge) and ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and Variables.ConvokeCondition and MaxAstralPower - CurrentAstralPower < 50) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.ConvokeTheSpirits) and ( Variables.ConvokeCondition ) then
            -- KTrig("Convoke The Spirits") return true end
            if aura_env.config[tostring(ids.ConvokeTheSpirits)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Convoke The Spirits")
            elseif aura_env.config[tostring(ids.ConvokeTheSpirits)] ~= true then
                KTrig("Convoke The Spirits")
                return true
            end
        end

        if OffCooldown(ids.StellarFlare) and ( IsAuraRefreshable(ids.StellarFlare) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.StellarFlare) > 7 + NearbyEnemies ) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end

        if OffCooldown(ids.Starsurge) and ( GetRemainingAuraDuration("player", ids.StarlordBuff) > 4 and Variables.BoatStacks >= 3 or FightRemains(60, NearbyRange) < 4 ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.NewMoon or IsCasting(ids.FullMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 10 or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("New Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("New Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("New Moon")
                return true
            end
        end

        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.HalfMoon or IsCasting(ids.NewMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 20 and ( GetRemainingAuraDuration("player", ids.EclipseLunarBuff) > max(C_Spell.GetSpellInfo(ids.HalfMoon).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EclipseSolarBuff) > max(C_Spell.GetSpellInfo(ids.HalfMoon).castTime/1000, WeakAuras.gcdDuration()) ) or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("Half Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Half Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Half Moon")
                return true
            end
        end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.FullMoon or IsCasting(ids.HalfMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 40 and ( GetRemainingAuraDuration("player", ids.EclipseLunarBuff) > max(C_Spell.GetSpellInfo(ids.FullMoon).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EclipseSolarBuff) > max(C_Spell.GetSpellInfo(ids.FullMoon).castTime/1000, WeakAuras.gcdDuration()) ) or FightRemains(60, NearbyRange) < 20 or GetRemainingSpellCooldown(ids.CaInc) > 15 ) then
            -- KTrig("Full Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Full Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Full Moon")
                return true
            end
        end

        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.StarweaversWeftBuff) or PlayerHasBuff(ids.TouchTheCosmosBuff) ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Starsurge) and ( MaxAstralPower - CurrentAstralPower < Variables.PassiveAsp + 6 + ( 10 + Variables.PassiveAsp ) * ( ( GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < ( max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and 1 or 0 ) ) then
            KTrig("Starsurge") return true end
        
        -- if OffCooldown(ids.ForceOfNature) and ( not IsPlayerSpell(ids.DreamSurgeTalent) ) then
        --     -- KTrig("Force Of Nature") return true end
        --     if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Force Of Nature")
        --     elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
        --         KTrig("Force Of Nature")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.WildMushroom) and ( aura_env.PrevCast ~= ids.WildMushroom and not IsCasting(ids.WildMushroom) and not TargetHasDebuff(ids.FungalGrowthDebuff) ) then
            -- KTrig("Wild Mushroom") return true end
            if aura_env.config[tostring(ids.WildMushroom)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wild Mushroom")
            elseif aura_env.config[tostring(ids.WildMushroom)] ~= true then
                KTrig("Wild Mushroom")
                return true
            end
        end

        if OffCooldown(ids.Starfire) and ( IsPlayerSpell(ids.LunarCallingTalent) ) then
            KTrig("Starfire") return true end
        
        if OffCooldown(ids.Wrath) then
            KTrig("Wrath") return true end
    end

        -- Make Warrior of Elune work if talented (don't talent this)
    local KotgSt = function()
        -- -- Kichi moved this to No GCDs part --
        -- if OffCooldown(ids.WarriorOfElune) and ( Variables.EclipseRemains <= 7 ) then
        --     KTrig("Warrior of Elune") return true end

        -- Enter Eclipse if variable.enter_lunar is true or false
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) or ( Variables.KotgCaCondition or Variables.KotgIncCondition ) and PlayerHasBuff(ids.PartingSkiesBuff) and ( Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) or CurrentEclipseID == nil ) ) then
            KTrig("Wrath") return true end

        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and InEclipse and Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) and not PlayerHasBuff(ids.DryadsFavorBuff) and not ( Variables.KotgCaCondition or not Variables.KotgIncCondition ) ) then
            KTrig("Starfire") return true end

        -- Use dots if less than 3 seconds remaining or if you're about to use CDs
        if OffCooldown(ids.Moonfire) and ( ( GetRemainingDebuffDuration("target", ids.MoonfireDebuff) < 3 and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) or not TargetHasDebuff(ids.MoonfireDebuff) ) then
            KTrig("Moonfire") return true end

        if OffCooldown(ids.Sunfire) and ( GetRemainingDebuffDuration("target", ids.SunfireDebuff) < 3 or GetRemainingDebuffDuration("target", ids.SunfireDebuff) < min( 12, (PlayerHasBuff(ids.CaIncBuff) and select(5, WA_GetUnitAura("player", ids.CaIncBuff)) or 0) ) and Variables.KotgCaCondition and not PlayerHasBuff(ids.CaIncBuff) ) then
            KTrig("Sunfire") return true end

        -- Run kotg_pre_cd list for cooldwns
        if OffCooldown(ids.FuryOfElune) and ( not PlayerHasBuff(ids.CaIncBuff) and Variables.KotgCaCondition or GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > C_Spell.GetSpellCooldown(ids.FuryOfElune).duration ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end

        -- Cooldowns
        if GetRemainingSpellCooldown(ids.CelestialAlignmentCooldown) == 0 and aura_env.config[tostring(ids.CelestialAlignment)] and not IsPlayerSpell(ids.Incarnation) and ( Variables.KotgCaCondition ) then
            -- KTrig("Celestial Alignment") return true end
            if aura_env.config[tostring(ids.CelestialAlignment)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Celestial Alignment")
            elseif aura_env.config[tostring(ids.CelestialAlignment)] ~= true then
                KTrig("Celestial Alignment")
                return true
            end
        end
        
        if GetRemainingSpellCooldown(ids.Incarnation) == 0 and aura_env.config[tostring(ids.Incarnation)] and IsPlayerSpell(ids.Incarnation) and ( Variables.KotgIncCondition ) then
            -- KTrig("Incarnation") return true end
            if aura_env.config[tostring(ids.Incarnation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Incarnation")
            elseif aura_env.config[tostring(ids.Incarnation)] ~= true then
                KTrig("Incarnation")
                return true
            end
        end
        
        -- Starsurge with 4pc buff and CA/Incarn up
        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.DryadsFavorBuff) and PlayerHasBuff(ids.CaIncBuff) ) then
            KTrig("Starsurge") return true end

        -- Enter Lunar from out of Eclipse
        if OffCooldown(ids.Wrath) and ( Variables.EnterLunar and ( CurrentEclipseID == nil or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Wrath).castTime/1000) ) ) then
            KTrig("Wrath") return true end

        if OffCooldown(ids.Starfire) and ( not Variables.EnterLunar and ( CurrentEclipseID == nil or Variables.EclipseRemains < (C_Spell.GetSpellInfo(ids.Starfire).castTime/1000) ) ) then
            KTrig("Starfire") return true end

        -- Use Stellar Flare if you're about to use CDs and the duration is less than the duration of your CDs
        if OffCooldown(ids.StellarFlare) and ( GetRemainingDebuffDuration("target", ids.StellarFlareDebuff) <= (PlayerHasBuff(ids.CaIncBuff) and select(5, WA_GetUnitAura("player", ids.CaIncBuff)) or 0) and Variables.PoolForCd or GetRemainingDebuffDuration("target", ids.StellarFlareDebuff) <= (PlayerHasBuff(ids.CaIncBuff) and 1 or 0) and not PlayerHasBuff(ids.DryadsFavorBuff) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end

        -- Wrath to pool AP before using CDs
        if OffCooldown(ids.Wrath) and ( Variables.PoolForCd ) then
            KTrig("Wrath") return true end

        -- Hard force 2 Starsurge casts at start of Dryad
        if OffCooldown(ids.Starsurge) and ( GetRemainingAuraDuration("player", ids.DryadBuff) > 8 and PlayerHasBuff(ids.DryadBuff) ) then
            KTrig("Starsurge") return true end


        -- Use Treants if Dryad is up and the duration is less than Treants duration + 2 globals ( Too long now, NG won't update )
        if OffCooldown(ids.ForceOfNature) and ( PlayerHasBuff(ids.DryadBuff) and (PlayerHasBuff(ids.HarmonyOfTheGroveBuff) and select(5, WA_GetUnitAura("player", ids.HarmonyOfTheGroveBuff)) or 0) > GetRemainingAuraDuration("player", ids.DryadBuff) + 2 or not PlayerHasBuff(ids.CaIncBuff) and ( C_Spell.GetSpellCooldown(ids.ForceOfNature).duration < 5 + ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) + ( 15 * (IsPlayerSpell(ids.ControlOfTheDreamTalent) and 1 or 0) ) ) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Force Of Nature") return true end
            if aura_env.config[tostring(ids.ForceOfNature)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Force Of Nature")
            elseif aura_env.config[tostring(ids.ForceOfNature)] ~= true then
                KTrig("Force Of Nature")
                return true
            end
        end

        -- Proceed with rotation
        if OffCooldown(ids.FuryOfElune) and ( 5 + Variables.PassiveAsp < MaxAstralPower - CurrentAstralPower and ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) > 8 or not IsPlayerSpell(ids.ConvokeTheSpirits) ) or FightRemains(60, NearbyRange) < 8 + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) then
            -- KTrig("Fury Of Elune") return true end
            if aura_env.config[tostring(ids.FuryOfElune)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Fury Of Elune")
            elseif aura_env.config[tostring(ids.FuryOfElune)] ~= true then
                KTrig("Fury Of Elune")
                return true
            end
        end

        if OffCooldown(ids.Starfall) and ( PlayerHasBuff(ids.StarweaversWarpBuff) ) then
            KTrig("Starfall") return true end

        if OffCooldown(ids.Starsurge) and ( IsPlayerSpell(ids.StarlordTalent) and GetPlayerStacks(ids.StarlordBuff) < 3 and not Variables.PoolInCa and not ( Variables.ConvokeCondition and OffCooldown(ids.ConvokeTheSpirits) ) ) then
            KTrig("Starsurge") return true end

        if OffCooldown(ids.Sunfire) and ( IsAuraRefreshable(ids.SunfireDebuff) ) then
            KTrig("Sunfire") return true end

        if OffCooldown(ids.Moonfire) and ( IsAuraRefreshable(ids.MoonfireDebuff) and ( not IsPlayerSpell(ids.TreantsOfTheMoonTalent) or GetRemainingSpellCooldown(ids.ForceOfNature) > 3 and not PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) ) then
            KTrig("Moonfire") return true end

        -- Convoke when Convoke variable is true and Harmony of the Grove is up
        if OffCooldown(ids.Starsurge) and ( GetRemainingSpellCooldown(ids.ConvokeTheSpirits) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 and Variables.ConvokeCondition and CurrentAstralPower > 36 and GetRemainingAuraDuration("player", ids.DryadBuff) > 4 + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and PlayerHasBuff(ids.DryadBuff) and FightRemains(60, 0) > 5 ) then
            KTrig("Starsurge") return true end

        if OffCooldown(ids.ConvokeTheSpirits) and ( Variables.ConvokeCondition and PlayerHasBuff(ids.HarmonyOfTheGroveBuff) ) then
            -- KTrig("Convoke The Spirits") return true end
            if aura_env.config[tostring(ids.ConvokeTheSpirits)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Convoke The Spirits")
            elseif aura_env.config[tostring(ids.ConvokeTheSpirits)] ~= true then
                KTrig("Convoke The Spirits")
                return true
            end
        end
        if OffCooldown(ids.StellarFlare) and ( IsAuraRefreshable(ids.StellarFlare) and ( TargetTimeToXPct(0, 60) - GetRemainingDebuffDuration("target", ids.StellarFlare) > 7 + NearbyEnemies ) and not PlayerHasBuff(ids.CaIncBuff) ) then
            -- KTrig("Stellar Flare") return true end
            if aura_env.config[tostring(ids.StellarFlare)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Stellar Flare")
            elseif aura_env.config[tostring(ids.StellarFlare)] ~= true then
                KTrig("Stellar Flare")
                return true
            end
        end
        
        if OffCooldown(ids.Starsurge) and ( ( GetRemainingAuraDuration("player", ids.StarlordBuff) > 4 and Variables.BoatStacks >= 7 or FightRemains(60, NearbyRange) < 4 ) and not Variables.PoolInCa ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.NewMoon or IsCasting(ids.FullMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 10 and (( PlayerHasBuff(ids.HarmonyOfTheGroveBuff) and not PlayerHasBuff(ids.CaIncBuff) or PlayerHasBuff(ids.CaIncBuff) and not OffCooldown(ids.CaInc)) or GetTimeToFullCharges(ids.NewMoon) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("New Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("New Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("New Moon")
                return true
            end
        end
                    
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.HalfMoon or IsCasting(ids.NewMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 20 and (( PlayerHasBuff(ids.HarmonyOfTheGroveBuff) and not PlayerHasBuff(ids.CaIncBuff) or PlayerHasBuff(ids.CaIncBuff) and not OffCooldown(ids.CaInc)) or GetTimeToFullCharges(ids.NewMoon) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Half Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Half Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Half Moon")
                return true
            end
        end
                            
        if OffCooldown(ids.NewMoon) and HasMoonCharge and (FindSpellOverrideByID(ids.NewMoon) == ids.FullMoon or IsCasting(ids.HalfMoon)) and ( MaxAstralPower - CurrentAstralPower > Variables.PassiveAsp + 40 and (( PlayerHasBuff(ids.HarmonyOfTheGroveBuff) and not PlayerHasBuff(ids.CaIncBuff) or PlayerHasBuff(ids.CaIncBuff) and not OffCooldown(ids.CaInc)) or GetTimeToFullCharges(ids.NewMoon) < GetRemainingSpellCooldown(ids.ConvokeTheSpirits) ) or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Full Moon") return true end
            if aura_env.config[tostring(ids.NewMoon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Full Moon")
            elseif aura_env.config[tostring(ids.NewMoon)] ~= true then
                KTrig("Full Moon")
                return true
            end
        end

        if OffCooldown(ids.Starsurge) and ( PlayerHasBuff(ids.StarweaversWeftBuff) or PlayerHasBuff(ids.TouchTheCosmosBuff) ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.Starsurge) and ( MaxAstralPower - CurrentAstralPower < Variables.PassiveAsp + 6 + ( 10 + Variables.PassiveAsp ) * ( ( GetRemainingAuraDuration("player", ids.EclipseSolarBuff) < ( max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 2 ) ) and 1 or 0 ) and not Variables.PoolInCa ) then
            KTrig("Starsurge") return true end
        
        if OffCooldown(ids.WildMushroom) and ( aura_env.PrevCast ~= ids.WildMushroom and not IsCasting(ids.WildMushroom) and GetRemainingAuraDuration("target", ids.FungalGrowthDebuff) < 2 ) then
            -- KTrig("Wild Mushroom") return true end
            if aura_env.config[tostring(ids.WildMushroom)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Wild Mushroom")
            elseif aura_env.config[tostring(ids.WildMushroom)] ~= true then
                KTrig("Wild Mushroom")
                return true
            end
        end
        
        if OffCooldown(ids.Wrath) then
            KTrig("Wrath") return true end

    end

    -- Run AoE action list when more than 1 target
    if NearbyEnemies > 1 then
        Aoe() return true end
    
    -- RUN ST action list when just 1 target and no 11.2 Keeper 4pc
    if not Variables.Tww3Keeper4Pc and NearbyEnemies <= 1 then
        if St() then return true end end

    -- Run ST action list for 11.2 Keeper 4pc
    if Variables.Tww3Keeper4Pc and NearbyEnemies <= 1 then
        if KotgSt() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")
end
