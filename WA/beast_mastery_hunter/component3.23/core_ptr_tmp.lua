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
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1871)
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
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)

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

    if OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) and not OffCooldown(ids.BestialWrath) then
        ExtraGlows.CallOfTheWild = true 
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local Cleave = function()
        if OffCooldown(ids.BestialWrath) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end

        -- if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.HuntmastersCallTalent) and GetPlayerStacks(ids.HuntmastersCallBuff) == 2 ) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( GetRemainingAuraDuration("player", ids.BeastCleaveBuff) and PlayerHasBuff(ids.WitheringFireBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- Kichi --
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) <= WeakAuras.gcdDuration() or math.floor(GetSpellChargesFractional(ids.BarbedShot)) > math.floor(GetSpellChargesFractional(ids.KillCommand)) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            KTrig("Barbed Shot") return true end
        
        -- Kichi --
        if OffCooldown(ids.Multishot) and ( not(GetRemainingAuraDuration("pet", ids.BeastCleavePetBuff) > WeakAuras.gcdDuration()) and ( not IsPlayerSpell(ids.BloodyFrenzyTalent) or true ) ) then
            KTrig("Multishot") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( GetRemainingAuraDuration("player", ids.BeastCleaveBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- -- Kichi --    
        -- if OffCooldown(ids.CallOfTheWild) and ( GetSpellChargesFractional(ids.BarbedShot) < 1 ) then
        --     -- KTrig("Call of the Wild") return true end
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

        -- Kichi --
        -- if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.ShadowHoundsTalent) or IsPlayerSpell(ids.DireCleaveTalent) ) then
        -- --if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.ShadowHoundsTalent) or IsPlayerSpell(ids.DireCleaveTalent) ) and ( (CurrentFocus + GetPowerRegen()*WeakAuras.gcdDuration() + 20) < MaxFocus ) and (GetSpellChargesFractional(ids.BarbedShot) + GetSpellChargesFractional(ids.KillCommand) < 2 ) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end

        -- Waiting to modify this
        if OffCooldown(ids.KillCommand) and not HowlSummonReady then 
            KTrig("Kill Command") return true end
        
        -- Kichi --
        if OffCooldown(ids.CobraShot) and ( ((MaxFocus - CurrentFocus) / GetPowerRegen()*WeakAuras.gcdDuration()) < (WeakAuras.gcdDuration() + FullGCD()*2 ) or GetPlayerStacks(ids.HogstriderBuff) > 3 ) then
            KTrig("Cobra Shot") return true end
        
        -- Kichi --    
        -- if OffCooldown(ids.DireBeast) then
        -- --if OffCooldown(ids.DireBeast) and ( (CurrentFocus + GetPowerRegen()*WeakAuras.gcdDuration() + 20) < MaxFocus ) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.ExplosiveShot) then
            KTrig("Explosive Shot") return true end

    end
    
    local St = function()
        -- if OffCooldown(ids.DireBeast) and ( IsPlayerSpell(ids.HuntmastersCallTalent) ) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
        
        if OffCooldown(ids.BestialWrath) then
            -- KTrig("Bestial Wrath") return true end
            if aura_env.config[tostring(ids.BestialWrath)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Bestial Wrath")
            elseif aura_env.config[tostring(ids.BestialWrath)] ~= true then
                KTrig("Bestial Wrath")
                return true
            end
        end
                    
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow and ( PlayerHasBuff(ids.WitheringFireBuff) ) then
            KTrig("Black Arrow") return true end
        
        -- Waiting to modify this
        if OffCooldown(ids.BarbedShot) and ( GetTimeToFullCharges(ids.BarbedShot) <= WeakAuras.gcdDuration() or math.floor(GetSpellChargesFractional(ids.BarbedShot)) > math.floor(GetSpellChargesFractional(ids.KillCommand)) or IsPlayerSpell(ids.CallOfTheWild) and OffCooldown(ids.CallOfTheWild) or HowlSummonReady and GetTimeToFullCharges(ids.BarbedShot) < 8 ) then
            KTrig("Barbed Shot") return true end
        
        -- if OffCooldown(ids.CallOfTheWild) then
        --     -- KTrig("Call of the Wild") return true end
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

        if OffCooldown(ids.KillCommand) and not HowlSummonReady then 
            KTrig("Kill Command") return true end
        
        if OffCooldown(ids.KillShot) and FindSpellOverrideByID(ids.KillShot) == ids.BlackArrow then
            KTrig("Black Arrow") return true end
        
        if OffCooldown(ids.ExplosiveShot) and ( IsPlayerSpell(ids.ThunderingHoovesTalent) ) then
            KTrig("Explosive Shot") return true end
        
        if OffCooldown(ids.CobraShot) then
            KTrig("Cobra Shot") return true end
        
        -- if OffCooldown(ids.DireBeast) then
        --     -- KTrig("Dire Beast") return true end
        --     if aura_env.config[tostring(ids.DireBeast)] == true and aura_env.FlagKTrigCD then
        --         KTrigCD("Dire Beast")
        --     elseif aura_env.config[tostring(ids.DireBeast)] ~= true then
        --         KTrig("Dire Beast")
        --         return true
        --     end
        -- end
    end
    
    if NearbyEnemies < 2 or not IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies < 3 then
        if St() then return true end end
    
    if NearbyEnemies > 2 or IsPlayerSpell(ids.BeastCleaveTalent) and NearbyEnemies > 1 then
        if Cleave() then return true end end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")
end