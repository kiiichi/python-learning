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
    
    ---- Setup Data ----------------------------------------------------------------------------------------------- 
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1919)
    
    local CurrentRunes = 0
    local RuneCooldownDuration = select(2, GetRuneCooldown(1))
    local RuneCooldownStarts = {}
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            CurrentRunes = CurrentRunes + 1
        end
        table.insert(RuneCooldownStarts, start)
    end
    table.sort(RuneCooldownStarts)
    local TimeToXRunes = function(X)
        if RuneCooldownStarts[X] == 0 then return 0 end
        return RuneCooldownStarts[X] + RuneCooldownDuration - GetTime()
    end
    
    local CurrentRunicPower = UnitPower("player", Enum.PowerType.RunicPower)
    local MaxRunicPower = UnitPowerMax("player", Enum.PowerType.RunicPower)
    
    local NearbyRange = 10
    local NearbyEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") then
            NearbyEnemies = NearbyEnemies + 1
        end
    end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    WeakAuras.ScanEvents("K_NEARBY_Wounds", TargetsWithFesteringWounds)
    -- WeakAuras.ScanEvents("NG_DEATH_STRIKE_UPDATE", aura_env.CalcDeathStrikeHeal())
    
    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Rotation Variables ---------------------------------------------------------------------------------------
    local Variables = {}
    
    Variables.TwoHandCheck = (select(9, C_Item.GetItemInfo(GetInventoryItemLink("player", 16))) == "INVTYPE_2HWEAPON")
    
    Variables.StPlanning = NearbyEnemies <= 1
    
    Variables.AddsRemain = NearbyEnemies >= 2
    
    Variables.SendingCds = ( Variables.StPlanning or Variables.AddsRemain )
    
    Variables.CooldownCheck = ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrostBuff) ) or not IsPlayerSpell(ids.PillarOfFrost) or FightRemains(60, NearbyRange) < 20

    Variables.FwfBuffs = (GetRemainingAuraDuration("player", ids.PillarOfFrost) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 or (PlayerHasBuff(ids.UnholyStrengthBuff) and GetRemainingAuraDuration("player", ids.UnholyStrengthBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3) or (IsPlayerSpell(ids.BonegrinderTalent) and PlayerHasBuff(ids.BonegrinderFrostBuff) and GetRemainingAuraDuration("player", ids.BonegrinderFrostBuff) < max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) * 3 ) ) and (NearbyEnemies > 1 or GetTargetStacks(ids.RazoriceDebuff) == 5 or IsPlayerSpell(ids.ShatteringBladeTalent))

    Variables.RunePooling = IsPlayerSpell(ids.ReapersMarkTalent) and GetRemainingSpellCooldown(ids.ReapersMark) < 6 and CurrentRunes < 3 and Variables.SendingCds

    Variables.RpPooling = IsPlayerSpell(ids.BreathOfSindragosaTalent) and GetRemainingSpellCooldown(ids.BreathOfSindragosa) < 4 * WeakAuras.gcdDuration() and CurrentRunicPower < (60 + ( 35 + 5 * (PlayerHasBuff(ids.IcyOnslaughtBuff) and 1 or 0 ) - ( 10 * CurrentRunes )) ) and Variables.SendingCds 

    -- Kichi fix because NG wrong
    -- Frostscythe is equal at 3 targets, except with Rider 4pc which brings Obliterate higher at 3, unless cleaving strikes is up
    Variables.FrostscythePrio = 3 + ( ( (SetPieces >= 4 ) and not ( IsPlayerSpell(ids.CleavingStrikesTalent) and PlayerHasBuff(ids.RemorselessWinterBuff) ) ) and 1 or 0 )

    Variables.BreathOfSindragosaCheck = IsPlayerSpell(ids.BreathOfSindragosaTalent) and (GetRemainingSpellCooldown(ids.BreathOfSindragosa) > 20 or ( OffCooldown(ids.BreathOfSindragosa) and CurrentRunicPower >= ( 60 - 20 * (IsPlayerSpell(ids.ReapersMarkTalent) and 1 or 0) ) ) )
    

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Empower Rune Weapon
    if OffCooldown(ids.EmpowerRuneWeapon) and ( CurrentRunes < 2 or not PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunicPower < 35 + ((IsPlayerSpell(ids.IcyOnslaughtTalent) and 1 or 0) * GetPlayerStacks(ids.IcyOnslaughtBuff) * 5 ) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    if OffCooldown(ids.EmpowerRuneWeapon) and ( GetTimeToFullCharges(ids.EmpowerRuneWeapon) <= 6 and GetPlayerStacks(ids.KillingMachineBuff) < 1 + (IsPlayerSpell(ids.KillingStreakTalent) and 1 or 0) ) then
        ExtraGlows.EmpowerRuneWeapon = true end
    
    -- Pillar of Frost
    if OffCooldown(ids.PillarOfFrost) and ( not IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) or FightRemains(60, NearbyRange) < 20 ) then
        ExtraGlows.PillarOfFrost = true end

    if OffCooldown(ids.PillarOfFrost) and ( IsPlayerSpell(ids.BreathOfSindragosaTalent) and Variables.SendingCds and Variables.BreathOfSindragosaCheck and ( not IsPlayerSpell(ids.ReapersMarkTalent) or CurrentRunes >= 2 ) ) then
        ExtraGlows.PillarOfFrost = true end

    -- Breath of Sindragosa
    if OffCooldown(ids.BreathOfSindragosa) and ( not PlayerHasBuff(ids.BreathOfSindragosaBuff) and ( PlayerHasBuff(ids.PillarOfFrostBuff) or FightRemains(60, NearbyRange) < 20 ) ) then
        ExtraGlows.BreathOfSindragosa = true end
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    -- AoE Action List
    local Aoe = function()
        if OffCooldown(ids.Frostscythe) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3) ) ) then
            KTrig("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) or not TargetHasDebuff(ids.FrostFeverDebuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and PlayerHasBuff(ids.FrostbaneBuff) ) then
            KTrig("Frost Strike") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and NearbyEnemies < 5 and not Variables.RpPooling and not IsPlayerSpell(ids.FrostbaneTalent) ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Frostscythe) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.GlacialAdvance) and ( not Variables.RpPooling ) then
            KTrig("Glacial Advance") return true end

        if OffCooldown(ids.Frostscythe) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) and NearbyEnemies >= Variables.FrostscythePrio ) then
            KTrig("Frostscythe") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Obliterate") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Howling Blast") return true end
    end
    
    -- Cooldowns
    local Cooldowns = function()
        if OffCooldown(ids.RemorselessWinter) and not IsPlayerSpell(ids.FrozenDominionTalent) and ( Variables.SendingCds and ( NearbyEnemies > 1 or IsPlayerSpell(ids.GatheringStormTalent ) or ( GetPlayerStacks(ids.GatheringStormBuff) == 10 and GetRemainingAuraDuration("player", ids.GatheringStormBuff) < WeakAuras.gcdDuration() * 2 ) ) and FightRemains(60, NearbyRange) > 10 ) then
            -- KTrig("Remorseless Winter") return true end
            if aura_env.config[tostring(ids.RemorselessWinter)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Remorseless Winter")
            elseif aura_env.config[tostring(ids.RemorselessWinter)] ~= true then
                KTrig("Remorseless Winter")
                return true
            end
        end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and not IsPlayerSpell(ids.BreathOfSindragosaTalent) ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end
                    
        if OffCooldown(ids.FrostwyrmsFury) and ( IsPlayerSpell(ids.RidersChampionTalent) and IsPlayerSpell(ids.ApocalypseNowTalent) and Variables.SendingCds and ( GetRemainingSpellCooldown(ids.PillarOfFrost) < WeakAuras.gcdDuration() or FightRemains(60, NearbyRange) < 20 ) and IsPlayerSpell(ids.BreathOfSindragosaTalent) and CurrentRunicPower >= 60 ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end

        if OffCooldown(ids.ReapersMark) and ( PlayerHasBuff(ids.PillarOfFrost) or GetRemainingSpellCooldown(ids.PillarOfFrost) > 5 or FightRemains(60, NearbyRange) < 20 ) then
            -- KTrig("Reapers Mark") return true end
            if aura_env.config[tostring(ids.ReapersMark)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Reapers Mark")
            elseif aura_env.config[tostring(ids.ReapersMark)] ~= true then
                KTrig("Reapers Mark")
                return true
            end
        end            

        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies <= 1 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not IsPlayerSpell(ids.ObliterationTalent) or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs or FightRemains(10, NearbyRange) < 3 ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end
        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and NearbyEnemies >= 2 and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end        
        if OffCooldown(ids.FrostwyrmsFury) and ( not IsPlayerSpell(ids.ApocalypseNowTalent) and IsPlayerSpell(ids.ObliterationTalent) and ( IsPlayerSpell(ids.PillarOfFrost) and PlayerHasBuff(ids.PillarOfFrost) and not Variables.TwoHandCheck or not PlayerHasBuff(ids.PillarOfFrost) and Variables.TwoHandCheck and GetRemainingSpellCooldown(ids.PillarOfFrost) > 0 or not IsPlayerSpell(ids.PillarOfFrost) ) and Variables.FwfBuffs ) then
            -- KTrig("Frostwyrms Fury") return true end
            if aura_env.config[tostring(ids.FrostwyrmsFury)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Frostwyrms Fury")
            elseif aura_env.config[tostring(ids.FrostwyrmsFury)] ~= true then
                KTrig("Frostwyrms Fury")
                return true
            end
        end        
        if OffCooldown(ids.RaiseDead) then
            -- KTrig("Raise Dead") return true end
            if aura_env.config[tostring(ids.RaiseDead)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Raise Dead")
            elseif aura_env.config[tostring(ids.RaiseDead)] ~= true then
                KTrig("Raise Dead")
                return true
            end
        end
        
        if OffCooldown(ids.SoulReaper) and ( IsPlayerSpell(ids.ReaperOfSoulsTalent) and PlayerHasBuff(ids.ReaperOfSoulsBuff) and GetPlayerStacks(ids.KillingMachineBuff) < 2) then
            KTrig("Soul Reaper") return true end
    end
    
    -- Single Target Rotation
    local SingleTarget = function()
        if OffCooldown(ids.Obliterate) and ( GetPlayerStacks(ids.KillingMachineBuff) == 2 or (PlayerHasBuff(ids.KillingMachineBuff) and CurrentRunes >= 3 ) ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) and IsPlayerSpell(ids.FrostboundWillTalent) ) then
            KTrig("Howling Blast") return true end
        
        if OffCooldown(ids.FrostStrike) and ( GetTargetStacks(ids.RazoriceDebuff) == 5 and IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling ) then
            KTrig("Frost Strike") return true end
        
        if OffCooldown(ids.HowlingBlast) and ( PlayerHasBuff(ids.RimeBuff) ) then
            KTrig("Howling Blast") return true end

        if OffCooldown(ids.FrostStrike) and ( not IsPlayerSpell(ids.ShatteringBladeTalent) and not Variables.RpPooling and MaxRunicPower - CurrentRunicPower < 30 ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( PlayerHasBuff(ids.KillingMachineBuff) and not Variables.RunePooling ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.FrostStrike) and ( not Variables.RpPooling ) then
            KTrig("Frost Strike") return true end

        if OffCooldown(ids.Obliterate) and ( not Variables.RunePooling and not ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Obliterate") return true end

        if OffCooldown(ids.HowlingBlast) and ( not PlayerHasBuff(ids.KillingMachineBuff) and ( IsPlayerSpell(ids.ObliterationTalent) and PlayerHasBuff(ids.PillarOfFrostBuff) ) ) then
            KTrig("Howling Blast") return true end
    end
    
    -- Choose Action list to run
    if Cooldowns() then return true end
    
    if NearbyEnemies >= 3 then
        Aoe() return true end
    
    if SingleTarget() then return true end
    
    KTrig("Clear")
end
