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
    
    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1923)
    -- local SetPieces = 4
    local CurrentFocus = UnitPower("player", Enum.PowerType.Focus)
    local MaxFocus = UnitPowerMax("player", Enum.PowerType.Focus)
    local HowlSummonReady = PlayerHasBuff(ids.HowlBearBuff) or PlayerHasBuff(ids.HowlBoarBuff) or PlayerHasBuff(ids.HowlWyvernBuff)
    
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
    -- WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)

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
    -- Kichi --
    local ExtraGlows = {}

    if not IsPlayerSpell(ids.BlackArrowTalent) and OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) and not OffCooldown(ids.BestialWrath) then
        ExtraGlows.CallOfTheWild = true 
    end

    if IsPlayerSpell(ids.BlackArrowTalent) and OffCooldown(ids.CallOfTheWild) and not OffCooldown(ids.Bloodshed) and TargetHasDebuff(468572) then
        ExtraGlows.CallOfTheWild = true 
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        -- Kichi replace GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) with 12 and add GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) > 0
        if OffCooldown(ids.BestialWrath) and ( ( (GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) - 12 < ( 12 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 0.5 )) and GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) > 0 ) or SetPieces < 4 or false )  then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end
        
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < FullGCD() or GetSpellChargesFractional(ids.BarbedShot) >= GetSpellChargesFractional(ids.KillCommand) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end
        
        if OffCooldown(ids.Multishot) and ( not WA_GetUnitBuff("pet", ids.BeastCleavePetBuff) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or GetRemainingSpellCooldown(ids.CallOfTheWild) > 0 ) ) then
            KTrig("Multishot") return true end

        -- if OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) then
        --     -- KTrig("Call Of The Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end

        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end

        -- Kichi --
        if OffCooldown(ids.KillCommandSummon) and HowlSummonReady then 
            -- KTrig("Kill Command") return true end
            if aura_env.config[tostring(ids.KillCommandSummon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kill Command Summon")
            elseif aura_env.config[tostring(ids.KillCommandSummon)] ~= true then
                KTrig("Kill Command Summon")
                return true
            end
        end

        -- Waiting to modify this
        if OffCooldown(ids.KillCommand) and not HowlSummonReady then 
            KTrig("Kill Command") return true end        

        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()) < FullGCD() * 2 or GetPlayerStacks(ids.HogstriderBuff) > 3 or not IsPlayerSpell(ids.Multishot) ) then 
            KTrig("Cobra Shot") return true end
    end

    local Drcleave = function()
        if OffCooldown(ids.KillShot) then
            KTrig("Kill Shot") return true end
        
        if OffCooldown(ids.BestialWrath) and ( GetRemainingSpellCooldown(ids.CallOfTheWild) > 20 or not IsPlayerSpell(ids.CallOfTheWild) ) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end

        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < FullGCD() ) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end

        if OffCooldown(ids.Multishot) and ( not WA_GetUnitBuff("pet", ids.BeastCleavePetBuff) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or GetRemainingSpellCooldown(ids.CallOfTheWild) ) ) then
            KTrig("Multishot") return true end
        
        -- if OffCooldown(ids.CallOfTheWild) then
        --     -- KTrig("Call Of The Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end

        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end
        
        if OffCooldown(ids.BarbedShot) and ( GetSpellChargesFractional(ids.BarbedShot) >= GetSpellChargesFractional(ids.KillCommand) ) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.KillCommand) then
            KTrig("Kill Command") return true end
        
        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()) < FullGCD() * 2 ) then
            KTrig("Cobra Shot") return true end
        
        if OffCooldown(ids.ExplosiveShot) then
            KTrig("Explosive Shot") return true end
    end
    
    local Drst = function()
        if OffCooldown(ids.KillShot) then
            KTrig("Kill Shot") return true end
        
        if OffCooldown(ids.BestialWrath) and ( GetRemainingSpellCooldown(ids.CallOfTheWild) > 20 or not IsPlayerSpell(ids.CallOfTheWild) ) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end        

        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < FullGCD() ) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end
                
        -- if OffCooldown(ids.CallOfTheWild) then
        --     -- KTrig("Call Of The Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.KillCommand) then
            KTrig("Kill Command") return true end
        
        if OffCooldown(ids.BarbedShot) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            KTrig("Cobra Shot") return true end
    end
    
    local St = function()
        if OffCooldown(ids.BestialWrath) and ( ( (GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) - 12 < ( 12 / max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 0.5 )) and GetRemainingAuraDuration("player", ids.HowlOfThePackLeaderCooldownBuff) > 0 ) or SetPieces < 4 ) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end

        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) < FullGCD() ) then
            KTrig("Barbed Shot") return true end
        
        -- if OffCooldown(ids.CallOfTheWild) then
        --     -- KTrig("Call Of The Wild") return true end
        --     if aura_env.config[tostring(ids.CallOfTheWild)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Call Of The Wild")
        --     elseif aura_env.config[tostring(ids.CallOfTheWild)] ~= true then
        --         KTrig("Call Of The Wild")
        --         return true
        --     end
        -- end

        if OffCooldown(ids.Bloodshed) then
            -- KTrig("Bloodshed") return true end
            if aura_env.config[tostring(ids.Bloodshed)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bloodshed")
            elseif aura_env.config[tostring(ids.Bloodshed)] ~= true then
                KTrig("Bloodshed")
                return true
            end
        end

        -- Kichi add for keep HowlSummonReady
        if OffCooldown(ids.KillCommand) and HowlSummonReady and ( GetSpellChargesFractional(ids.KillCommand) >= GetSpellChargesFractional(ids.BarbedShot) and not ( GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) > FullGCD() and GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) < FullGCD() * 2 and not HowlSummonReady and GetTimeToFullCharges(ids.KillCommand) > FullGCD()) ) then
            -- KTrig("Kill Command") return true end
            if aura_env.config[tostring(ids.KillCommandSummon)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Kill Command Summon")
            elseif aura_env.config[tostring(ids.KillCommandSummon)] ~= true then
                KTrig("Kill Command Summon")
                return true
            end
        end

        -- Kichi add for keep HowlSummonReady
        if OffCooldown(ids.KillCommand) and not HowlSummonReady and ( GetSpellChargesFractional(ids.KillCommand) >= GetSpellChargesFractional(ids.BarbedShot) and not ( GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) > FullGCD() and GetRemainingAuraDuration("player", ids.LeadFromTheFrontBuff) < FullGCD() * 2 and not HowlSummonReady and GetTimeToFullCharges(ids.KillCommand) > FullGCD()) ) then
            KTrig("Kill Command") return true end
        
        if OffCooldown(ids.BarbedShot) then
            KTrig("Barbed Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            KTrig("Cobra Shot") return true end
    end

    if IsPlayerSpell(ids.BlackArrowTalent) and ( NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3) then
        if Drst() then return true end end
    
    if IsPlayerSpell(ids.BlackArrowTalent) and ( NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1) then
        if Drcleave() then return true end end
    
    if not IsPlayerSpell(ids.BlackArrowTalent) and (NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3) then
        if St() then return true end end
    
    if not IsPlayerSpell(ids.BlackArrowTalent) and (NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1) then
        if Cleave() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    KTrigCD("Clear")

end
