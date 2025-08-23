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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1928)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1876)
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
    
    -- Maintain Adrenaline Rush. With Improved AR, recast at low CPs even if already active.
    if OffCooldown(ids.AdrenalineRush) and ( not PlayerHasBuff(ids.AdrenalineRush) and ( not Variables.FinishCondition or not IsPlayerSpell(ids.ImprovedAdrenalineRushTalent) ) or PlayerHasBuff(ids.AdrenalineRushBuff) and CurrentComboPoints <= 2 ) then
        ExtraGlows.AdrenalineRush = true
    end
    
    -- High priority Ghostly Strike as it is off-gcd. 1 FTH builds prefer to not use it at max CPs.
    if OffCooldown(ids.GhostlyStrike) and ( CurrentComboPoints < MaxComboPoints or TalentRank(ids.FanTheHammerTalentNode) > 1 ) then
        ExtraGlows.GhostlyStrike = true
    end
    
    -- Thistle Tea
    if OffCooldown(ids.ThistleTea) and ( not PlayerHasBuff(ids.ThistleTea) and ( CurrentEnergy < ThistleTeaEnergy or TargetTimeToXPct(0, 999) < C_Spell.GetSpellCharges(ids.ThistleTea).currentCharges * 6 ) ) then
        ExtraGlows.ThistleTea = true
    end
    
    -- Use Keep it Rolling immediately with any 4 RTB buffs. If a natural 5 buff is rolled, then wait until the final 6th buff is obtained from Count the Odds.
    if OffCooldown(ids.KeepItRolling) and ( RTBBuffCount >= 4 and RTBBuffNormal <= 2 or RTBBuffNormal >= 5 and RTBBuffCount == 6 ) then
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
        -- High priority Ambush with Hidden Opportunity.
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.AudacityBuff) ) then
            KTrig("Ambush") return true end

        -- Outside of stealth, Trickster builds should prioritize Sinister Strike when Unseen Blade is guaranteed. This is mostly neutral/irrelevant for Hidden Opportunity builds.
        if OffCooldown(ids.SinisterStrike) and ( HasDisorientingStrikes and not IsStealthed and not IsPlayerSpell(ids.HiddenOpportunityTalent) and GetPlayerStacks(ids.EscalatingBladeBuff) < 4 and not aura_env.HasTww34PcTricksterBuff) then
            KTrig("Sinister Strike") return true end
            
        -- With Audacity + Hidden Opportunity + Fan the Hammer, consume Opportunity to proc Audacity any time Ambush is not available.
        if OffCooldown(ids.PistolShot) and ( IsPlayerSpell(ids.FanTheHammerTalent) and IsPlayerSpell(ids.AudacityBuff) and IsPlayerSpell(ids.HiddenOpportunityTalent) and PlayerHasBuff(ids.OpportunityBuff) and not PlayerHasBuff(ids.AudacityBuff) ) then
            KTrig("Pistol Shot") return true end
        
        -- Without Hidden Opportunity, prioritize building CPs with Blade Flurry at 4+ targets. Trickster shoulds prefer to use this at low CPs unless AR isn't active.
        if OffCooldown(ids.BladeFlurry) and ( IsPlayerSpell(ids.DeftManeuversTalent) and NearbyEnemies >= 4 and ( CurrentComboPoints <= 2 or not PlayerHasBuff(ids.AdrenalineRushBuff) or not IsPlayerSpell(ids.UnseenBladeTalent)) ) then
            KTrig("Blade Flurry") return true end

        -- At sustain 3 targets (2 target for Fatebound 1FTH), Blade Flurry can be used to build CPs if we are missing CPs equal to the amount it will give.
        if OffCooldown(ids.BladeFlurry) and ( IsPlayerSpell(ids.DeftManeuversTalent) and MaxComboPoints - CurrentComboPoints == NearbyEnemies + (PlayerHasBuff(ids.BroadsideBuff) and 1 or 0) and NearbyEnemies >= 3 - (IsPlayerSpell(ids.HandOfFateTalent) and 1 or 0) and IsPlayerSpell(ids.FanTheHammerTalent) ) then
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

        -- Use Coup de Grace at low CPs if Sinister Strike would otherwise be used.
        if FindSpellOverrideByID(ids.Dispatch) == ids.CoupDeGrace and (not IsStealthed) then
            KTrig("Dispatch") return true end

        -- Fallback pooling just so Sinister Strike is never casted if Ambush is available with Hidden Opportunity.
        if OffCooldown(ids.Ambush) and ( IsPlayerSpell(ids.HiddenOpportunityTalent) ) then
            KTrig("Ambush") return true end
        
        if OffCooldown(ids.SinisterStrike) then
            KTrig("Sinister Strike") return true end
    end
    
    local Finish = function()
        -- Keep it Rolling builds should cancel Killing Spree after reaching max CPs during the animation.
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
        
        -- Outside of stealth, use Between the Eyes to maintain the buff, or with Ruthless Precision active, or to proc Greenskins Wickers if not active. Trickster builds can also send BtE on cooldown.
        if OffCooldown(ids.BetweenTheEyes) and ( ( PlayerHasBuff(ids.RuthlessPrecisionBuff) or GetRemainingAuraDuration("player", ids.BetweenTheEyesBuff) < 4 or not IsPlayerSpell(ids.MeanStreakTalent) ) and ( not PlayerHasBuff(ids.GreenskinsWickersBuff) or not IsPlayerSpell(ids.GreenskinsWickersTalent) ) ) then
            KTrig("Between the Eyes") return true end
        
        --if OffCooldown(ids.CoupDeGrace) then
        --    KTrig("Coup De Grace") return true end
        
        if OffCooldown(ids.Dispatch) then
            KTrig("Dispatch") return true end
    end

    local Vanish = function()
        -- Vanish usage for standard builds  Fatebound or builds without Killing Spree attempt to hold Vanish for when BtE is on cooldown and Ruthless Precision is active.
        if OffCooldown(ids.Vanish) and ( ( not IsPlayerSpell(ids.UnseenBladeTalent) or not IsPlayerSpell(ids.KillingSpreeTalent) ) and not OffCooldown(ids.BetweenTheEyes) and GetRemainingAuraDuration("player", ids.RuthlessPrecisionBuff) > 4 ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end

        -- Fatebound or builds without Killing Spree should also Vanish if Supercharger becomes active.
        if OffCooldown(ids.Vanish) and ( ( not IsPlayerSpell(ids.UnseenBladeTalent) or not IsPlayerSpell(ids.KillingSpreeTalent) ) and GetUnitChargedPowerPoints("player") ~= nil ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Trickster builds with Killing Spree should Vanish if Killing Spree is not up soon. With TWW3 Trickster, attempt to align Vanish with a recently used Coup de Grace.
        if OffCooldown(ids.Vanish) and ( IsPlayerSpell(ids.UnseenBladeTalent) and IsPlayerSpell(ids.KillingSpreeTalent) and GetRemainingSpellCooldown(ids.KillingSpree) > 30 and (CurrentTime - aura_env.LastKillingSpree) <= 10 or not (SetPieces >= 4) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
        -- Vanish if it is about to cap charges or sim duration is ending soon.
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
    
    local RollTheBones = function()
        -- Maintain Roll the Bones: cast without any buffs.
        if OffCooldown(ids.RollTheBones) and ( RTBBuffCount == 0 ) then
            KTrig("Roll the Bones") return true end
        
        -- With TWW2 (old tier), roll if you will lose 0 or 1 buffs. This includes rolling immediately after KIR. If you KIR'd a natural 5 roll, then wait until they approach pandemic range.
        if OffCooldown(ids.RollTheBones) and ( (OldSetPieces >= 4) and RTBBuffWillLose <= 1 and ( Variables.BuffsAbovePandemic < 5 or RTBBuffMaxRemains < 42 ) ) then
            KTrig("Roll the Bones") return true end
        
        --  With TWW2 (old tier), roll over any 2 buffs. HO builds also roll if you will lose 3-4 buffs, while KIR builds wait until they approach ~10s remaining.
        if OffCooldown(ids.RollTheBones) and ( (OldSetPieces >= 4) and ( RTBBuffCount <= 2 or (RTBBuffMaxRemains < 11 or not IsPlayerSpell(ids.KeepItRolling)) and RTBBuffWillLose < 5 and IsPlayerSpell(ids.SuperchargerTalent) and RTBBuffNormal > 0 ) ) then
            KTrig("Roll the Bones") return true end

        -- Without TWW2, roll if you will lose 0 buffs, or 1 buff with Loaded Dice active. This includes rolling immediately after KIR.
        if OffCooldown(ids.RollTheBones) and ( OldSetPieces < 4 and RTBBuffWillLose <= (PlayerHasBuff(ids.LoadedDiceBuff) and 1 or 0) ) then
            KTrig("Roll the Bones") return true end
        
        -- Without TWW2, roll over exactly 2 buffs with Loaded Dice and Supercharger.
        if OffCooldown(ids.RollTheBones) and ( OldSetPieces < 4 and IsPlayerSpell(ids.SuperchargerTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 ) then
            KTrig("Roll the Bones") return true end
        
        -- Without TWW2, HO builds without Supercharger can roll over 2 buffs with Loaded Dice active and you won't lose Broadside, Ruthless Precision, or True Bearing.
        if OffCooldown(ids.RollTheBones) and ( not (OldSetPieces >= 4) and not IsPlayerSpell(ids.KeepItRollingTalent) and not IsPlayerSpell(ids.SuperchargerTalent) and PlayerHasBuff(ids.LoadedDiceBuff) and RTBBuffCount <= 2 and not PlayerHasBuff(ids.BroadsideBuff) and not PlayerHasBuff(ids.RuthlessPrecisionBuff) and not PlayerHasBuff(ids.TrueBearingBuff) ) then
            KTrig("Roll the Bones") return true end
    end
    
    local Cds = function()
        -- Maintain Blade Flurry at 2+ targets.
        if OffCooldown(ids.BladeFlurry) and ( NearbyEnemies >= 2 and GetRemainingAuraDuration("player", ids.BladeFlurry) < BFHeadsup ) then
            KTrig("Blade Flurry") return true end
        
        -- Call the various Roll the Bones rules.
        if RollTheBones() then return true end
        
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
        if not IsStealthed and ( OffCooldown(ids.KillingSpree) and IsPlayerSpell(ids.KillingSpreeTalent) or GetPlayerStacks(ids.EscalatingBladeBuff) >= 4 or aura_env.HasTww34PcTricksterBuff ) and Variables.FinishCondition then
            Finish() return true end
        
        -- If not at risk of losing Adrenaline Rush, call flexible Vanish rules to be used at finisher CPs.
        if not IsStealthed and IsPlayerSpell(ids.CrackshotTalent) and IsPlayerSpell(ids.UnderhandedUpperHandTalent) and IsPlayerSpell(ids.SubterfugeTalent) and PlayerHasBuff(ids.AdrenalineRushBuff) and Variables.FinishCondition then
            if Vanish() then return true end end
        
        -- Fallback Vanish for builds lacking one of the mandatory stealth talents. If possible, Vanish for AR, otherwise for Ambush when Audacity isn't active, or otherwise to proc Take 'em By Surprise or Fatebound coins.
        if OffCooldown(ids.Vanish) and ( not IsStealthed and ( Variables.FinishCondition or not IsPlayerSpell(ids.CrackshotTalent) ) and ( not IsPlayerSpell(ids.UnderhandedUpperHandTalent) or not IsPlayerSpell(ids.SubterfugeTalent) or not IsPlayerSpell(ids.CrackshotTalent) ) and ( PlayerHasBuff(ids.AdrenalineRushBuff) and IsPlayerSpell(ids.SubterfugeTalent) and IsPlayerSpell(ids.UnderhandedUpperHandTalent) or ( ( not IsPlayerSpell(ids.SubterfugeTalent) or not IsPlayerSpell(ids.UnderhandedUpperHandTalent) ) and IsPlayerSpell(ids.HiddenOpportunityTalent) and not PlayerHasBuff(ids.AudacityBuff) and GetPlayerStacks(ids.OpportunityBuff) < (IsPlayerSpell(ids.FanTheHammerTalent) and 6 or 1) and Variables.AmbushCondition or ( not IsPlayerSpell(ids.HiddenOpportunityTalent) and ( IsPlayerSpell(ids.TakeEmBySurpriseTalent) or IsPlayerSpell(ids.DoubleJeopardyTalent) ) ) ) ) ) then
            -- KTrig("Vanish") return true end
            if aura_env.config[tostring(ids.Vanish)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Vanish")
            elseif aura_env.config[tostring(ids.Vanish)] ~= true then
                KTrig("Vanish")
                return true
            end
        end
        
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
        
        -- Inside stealth, 2FTH builds can consume Opportunity for Greenskins, or with max stacks + Broadside active + minimal CPs.
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
