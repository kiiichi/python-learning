env123.test123 = function()
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
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local CurrentFocus = UnitPower("player", Enum.PowerType.Focus)
    local MaxFocus = UnitPowerMax("player", Enum.PowerType.Focus)
    
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1871)
    
    local CurrentCast = select(9, UnitCastingInfo("player"))
    if CurrentCast ~= nil then
        if CurrentCast == ids.SteadyShot then
            CurrentFocus = CurrentFocus + 10
        elseif CurrentCast == ids.AimedShot then
            CurrentFocus = CurrentFocus - 35
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

    local HasPreciseShots = PlayerHasBuff(ids.PreciseShotsBuff) or IsCasting(ids.AimedShot)
    local TargetHasSpottersMark = TargetHasDebuff(ids.SpottersMarkDebuff) and not IsCasting(ids.AimedShot)
    local HasMovingTarget = PlayerHasBuff(ids.MovingTargetBuff) and not IsCasting(ids.AimedShot)

    -- Kichi --
    local LunarStormReady = PlayerHasBuff(ids.LunarStormReadyBuff) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") == 0
    local HasTrickShots = PlayerHasBuff(ids.Volley) or PlayerHasBuff(ids.TrickShotsBuff) and not IsCasting(ids.AimedShot) and not (select(8, UnitChannelInfo("player")) == ids.RapidFire) and not ( aura_env.PrevCast == ids.RapidFire )

    -- Kichi --
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
    
    -- Trueshot
    -- Kichi --
    if OffCooldown(ids.Trueshot) and NearbyEnemies > 0 and NearbyEnemies < 3 and HasMovingTarget and (not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) > 7 ) then
        ExtraGlows.Trueshot = true
    end

    if OffCooldown(ids.Trueshot) and NearbyEnemies > 2 and HasMovingTarget and (not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) > 7 ) and not OffCooldown(ids.Volley) then
        ExtraGlows.Trueshot = true
    end
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local St = function()
        -- Hold Volley for up to its whole cooldown for multiple target situations, also make sure Rapid Fire will be available to stack extra Bullestorm stacks during it without Aspect of the Hydra.
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and ( IsPlayerSpell(ids.AspectOfTheHydraTalent) or NearbyEnemies == 1 or not HasPreciseShots and ( GetRemainingSpellCooldown(ids.RapidFire) + max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) < 6 or not IsPlayerSpell(ids.BulletstormTalent) ) ) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kichi --
        -- Prioritize Rapid Fire to trigger Lunar Storm or to stack extra Bulletstorm when Volley Trick Shots is up without Aspect of the Hydra.
        if OffCooldown(ids.RapidFire) and ( IsPlayerSpell(ids.SentinelTalent) and LunarStormReady or not IsPlayerSpell(ids.AspectOfTheHydraTalent) and IsPlayerSpell(ids.BulletstormTalent) and NearbyEnemies > 1 and HasTrickShots and ( not HasPreciseShots or not IsPlayerSpell(ids.NoScopeTalent) ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end

        -- Prioritize 4pc double bonus by casting Explosive Shot and following up with Aimed Shot when Lock and Load is up, as long as Precise Shots would not be wasted.
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (SetPieces >= 4) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.LockAndLoadBuff) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and (SetPieces >= 4) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and PlayerHasBuff(ids.LockAndLoadBuff) ) then
            KTrig("Aimed Shot") return true end
        
        -- For Double Tap, lower Volley in priority until Trueshot has already triggered Double Tap.
        if OffCooldown(ids.Volley) and ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kill Shot/Black Arrow become the primary Precise Shot spenders for Headshot builds. For all Precise Shot spenders, skip to Aimed Shot if both Spotter's Mark and Moving Target are already up.
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.KillShot) and ( IsPlayerSpell(ids.HeadshotTalent) and HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not IsPlayerSpell(ids.HeadshotTalent) and PlayerHasBuff(ids.RazorFragmentsBuff) ) then
            KTrig("Kill Shot") return true end
        
        -- With either Symphonic Arsenal or Small Game Hunter, Multi-Shot can be used as the Precise Shots spender on 2 targets without Aspect of the Hydra.
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) and NearbyEnemies > 1 and not IsPlayerSpell(ids.AspectOfTheHydraTalent) and ( IsPlayerSpell(ids.SymphonicArsenalTalent) or IsPlayerSpell(ids.SmallGameHunterTalent) ) ) then
            KTrig("Multishot") return true end
        
        if OffCooldown(ids.ArcaneShot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) ) then
            KTrig("Arcane Shot") return true end
        
        -- Prioritize Aimed Shot a bit higher than Rapid Fire if it's close to charge capping and Bulletstorm is up.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and GetTimeToFullCharges(ids.AimedShot) < max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) + (C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000) and ( not IsPlayerSpell(ids.BulletstormTalent) or PlayerHasBuff(ids.BulletstormBuff) ) and IsPlayerSpell(ids.WindrunnerQuiverTalent) ) then
            KTrig("Aimed Shot") return true end
        
        -- With Sentinel, hold Rapid Fire for up to 1/3 of its cooldown to trigger Lunar Storm as soon as possible. Don't reset Bulletstorm if it's been stacked over 10 unless it can be re-stacked over 10.
        if OffCooldown(ids.RapidFire) and ( ( not IsPlayerSpell(ids.SentinelTalent) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > GetSpellBaseCooldown(ids.RapidFire)/1000 / 3 ) and ( not IsPlayerSpell(ids.BulletstormTalent) or GetPlayerStacks(ids.BulletstormBuff) <= 10 or IsPlayerSpell(ids.AspectOfTheHydraTalent) and NearbyEnemies > 1 ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- Aimed Shot if we've spent Precise Shots to trigger Spotter's Mark and Moving Target. With No Scope this means Precise Shots could be up when Aimed Shot is cast.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) then
            KTrig("Aimed Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( not (SetPieces >= 4) or not IsPlayerSpell(ids.PrecisionDetonationTalent) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( not IsPlayerSpell(ids.HeadshotTalent) ) then
            KTrig("Black Arrow") return true end
        
        -- Steady Shot is our only true filler due to the Aimed Shot cdr.
        if OffCooldown(ids.SteadyShot) then
            KTrig("Steady Shot") return true end
    end
        
    local Trickshots = function()
        -- Kichi --
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and HasTrickShots and not OffCooldown(ids.RapidFire) and OffCooldown(ids.Trueshot) ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end

        -- Kichi --
        if OffCooldown(ids.Volley) and ( not IsPlayerSpell(ids.DoubleTapTalent) and GetRemainingSpellCooldown(ids.Trueshot) > 10 ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end

        -- Kichi --
        -- Swap targets to spend Precise Shots from No Scope after applying Spotter's Mark already to the primary target.
        if OffCooldown(ids.Multishot) and ( HasPreciseShots and ( not TargetHasSpottersMark or not HasMovingTarget ) or not HasTrickShots or GetRemainingAuraDuration("player", ids.TrickShotsBuff) <= WeakAuras.gcdDuration() ) then
            KTrig("Multishot") return true end
    
        -- For Double Tap, lower Volley in priority until Trueshot has already triggered Double Tap.
        if OffCooldown(ids.Volley) and ( IsPlayerSpell(ids.DoubleTapTalent) and PlayerHasBuff(ids.DoubleTapBuff) == false ) then
            -- KTrig("Volley") return true end
            if aura_env.config[tostring(ids.Volley)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Volley")
            elseif aura_env.config[tostring(ids.Volley)] ~= true then
                KTrig("Volley")
                return true
            end
        end
        
        -- Kichi --
        if OffCooldown(ids.ExplosiveShot) and OffCooldown(ids.Trueshot) and HasTrickShots and not OffCooldown(ids.Volley) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end

        -- Always cast Black Arror with Trick Shots up for Bleak Powder.
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( HasTrickShots ) then
            KTrig("Black Arrow") return true end

        -- Prioritize Aimed Shot a bit higher than Rapid Fire if it's close to charge capping and Bulletstorm is up.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and HasTrickShots and PlayerHasBuff(ids.BulletstormBuff) and GetTimeToFullCharges(ids.AimedShot) <= max(C_Spell.GetSpellInfo(ids.AimedShot).castTime/1000, WeakAuras.gcdDuration()) ) then
            KTrig("Aimed Shot") return true end
        
        -- Kichi fix LunarStormCooldownBuff and LunarStormReady bug --
        -- With Sentinel, hold Rapid Fire for up to 1/3 of its cooldown to trigger Lunar Storm as soon as possible.
        if OffCooldown(ids.RapidFire) and ( GetRemainingAuraDuration("player", ids.TrickShotsBuff) > max(C_Spell.GetSpellInfo(ids.RapidFire).castTime/1000, WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.SentinelTalent) or GetRemainingAuraDuration("player", ids.LunarStormCooldownBuff, "HARMFUL") > GetSpellBaseCooldown(ids.RapidFire)/1000 / 3 or LunarStormReady ) ) then
            -- KTrig("Rapid Fire") return true end
            if aura_env.config[tostring(ids.RapidFire)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Rapid Fire")
            elseif aura_env.config[tostring(ids.RapidFire)] ~= true then
                KTrig("Rapid Fire")
                return true
            end
        end
        
        -- With Precision Detonation, wait until a follow up Aimed Shot would not waste Precise Shots to cast. Require Lock and Load active if using the 4pc.
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.PrecisionDetonationTalent) and ( PlayerHasBuff(ids.LockAndLoadBuff) or not (SetPieces >= 4) ) and ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) ) then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        -- Aimed Shot if we've spent Precise Shots to trigger Spotter's Mark and Moving Target. With No Scope this means Precise Shots could be up when Aimed Shot is cast.
        if OffCooldown(ids.AimedShot) and not (IsCasting(ids.AimedShot) and C_Spell.GetSpellCharges(ids.AimedShot).currentCharges == 1) and ( ( not HasPreciseShots or TargetHasSpottersMark and HasMovingTarget ) and HasTrickShots ) then
            KTrig("Aimed Shot") return true end
        
        -- Kichi --
        if OffCooldown(ids.ExplosiveShot) and HasTrickShots then
            -- KTrig("Explosive Shot") return true end
            if aura_env.config[tostring(ids.ExplosiveShot)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Explosive Shot")
            elseif aura_env.config[tostring(ids.ExplosiveShot)] ~= true then
                KTrig("Explosive Shot")
                return true
            end
        end
        
        if OffCooldown(ids.SteadyShot) and ( CurrentFocus + 40 < MaxFocus ) then
            KTrig("Steady Shot") return true end
        
        if OffCooldown(ids.Multishot) then
            KTrig("Multishot") return true end
    end

    if NearbyEnemies < 3 or not IsPlayerSpell(ids.TrickShotsTalent) then
        if St() then return true end end
    
    if NearbyEnemies > 2 then
        if Trickshots() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")

end
