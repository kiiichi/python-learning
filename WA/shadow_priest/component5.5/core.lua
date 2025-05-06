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
    if IsPlayerSpell(457042) then ids.ShadowCrash = 457042 end
    aura_env.OutOfRange = false
    
    ---- Setup Data -----------------------------------------------------------------------------------------------
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1875)
    
    local CurrentInsanity = UnitPower("player", Enum.PowerType.Insanity)
    local MaxInsanity = UnitPowerMax("player", Enum.PowerType.Insanity)
    
    local NearbyEnemies = 0
    local NearbyRange = 46
    local UndottedEnemies = 0
    local DottedEnemies = 0
    local DevouredEnemies = 0
    for i = 1, 40 do
        local unit = "nameplate"..i
        if UnitExists(unit) and not UnitIsFriend("player", unit) and WeakAuras.CheckRange(unit, NearbyRange, "<=") and (UnitAffectingCombat(unit) or aura_env.config["BypassCombatRequirement"]) then
            NearbyEnemies = NearbyEnemies + 1
            
            local FoundExcludedNPC = false
            for _, ID in ipairs(_G.KLIST.ShadowPriest) do                
                if UnitName(unit) == ID or select(6, strsplit("-", UnitGUID(unit))) == ID then
                    FoundExcludedNPC = true
                    break
                end
            end
            
            if FoundExcludedNPC == false then
                if WA_GetUnitDebuff(unit, ids.VampiricTouch, "PLAYER|HARMFUL") ~= nil then
                    DottedEnemies = DottedEnemies + 1
                elseif UnitClassification(unit) ~= "minus" then 
                    UndottedEnemies = UndottedEnemies + 1
                end
                if WA_GetUnitDebuff(unit, ids.DevouringPlague, "PLAYER|HARMFUL") ~= nil then
                    DevouredEnemies = DevouredEnemies + 1
                end
            end
        end
    end

    -- Kichi --
    WeakAuras.ScanEvents("K_NEARBY_ENEMIES", NearbyEnemies)
    
    local ShadowfiendDuration = max(0, aura_env.ShadowfiendExpiration - GetTime())
    
    WeakAuras.ScanEvents("NG_VAMPIRIC_TOUCH_SPREAD", DottedEnemies, UndottedEnemies)
    
    -- Only recommend things when something's targeted
    if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
        WeakAuras.ScanEvents("K_TRIGED_EXTRA", {})
        KTrig("Clear", nil) return end
    
    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    -- Kichi --
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    local Variables = {}
    Variables.DrForcePrio = false
    Variables.MeForcePrio = true
    Variables.MaxVts = 12
    Variables.IsVtPossible = false
    Variables.PoolingMindblasts = false
    Variables.HoldingCrash = false
    Variables.PoolForCds = ( GetRemainingSpellCooldown(ids.VoidEruption) <= 1.5 * 3 and IsPlayerSpell(ids.VoidEruption) or OffCooldown(ids.DarkAscension) and IsPlayerSpell(ids.DarkAscension) ) or IsPlayerSpell(ids.VoidTorrent) and IsPlayerSpell(ids.PsychicLinkTalent) and GetRemainingSpellCooldown(ids.VoidTorrent) <= 4 and ( NearbyEnemies > 1 ) and not PlayerHasBuff(ids.VoidformBuff)
    
    local AoeVariables = function()
        Variables.MaxVts = min(NearbyEnemies, 12)
        
        Variables.IsVtPossible = false
        
        if TargetTimeToXPct(0, 60) >= 18 then
        Variables.IsVtPossible = true end
        
        -- TODO: Revamp to fix undesired behaviour with unstacked fights
        Variables.DotsUp = ( DottedEnemies + 8 * ( ((aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 0.15) and IsPlayerSpell(ids.WhisperingShadowsTalent) ) and 1 or 0)) >= Variables.MaxVts or not Variables.IsVtPossible
        
        if Variables.HoldingCrash and IsPlayerSpell(ids.WhisperingShadowsTalent) then
            Variables.HoldingCrash = ( Variables.MaxVts - DottedEnemies ) < 4 end
        
        Variables.ManualVtsApplied = ( DottedEnemies + 8 * (not Variables.HoldingCrash and 1 or 0) ) >= Variables.MaxVts or not Variables.IsVtPossible
    end
    
    local Aoe = function()
        if AoeVariables() then return true end
        
        -- High Priority action to put out Vampiric Touch on enemies that will live at least 18 seconds, up to 12 targets manually while prepping AoE
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsAuraRefreshable(ids.VampiricTouchDebuff) and TargetTimeToXPct(0, 60) >= 18 and ( TargetHasDebuff(ids.VampiricTouchDebuff) or not Variables.DotsUp ) and ( Variables.MaxVts > 0 and not Variables.ManualVtsApplied and not (aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 0.15) or not IsPlayerSpell(ids.WhisperingShadowsTalent) ) and not PlayerHasBuff(ids.EntropicRiftBuff) ) then
            KTrig("Vampiric Touch") return true end
        
        -- Use Shadow Crash to apply Vampiric Touch to as many adds as possible while being efficient with Vampiric Touch refresh windows
        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsAuraRefreshable(ids.VampiricTouchDebuff) or GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) <= TargetTimeToXPct(0, 60) and not PlayerHasBuff(ids.VoidformBuff) ) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
    end
    
    local Cds = function()
        -- Make sure Mindbender is active before popping Dark Ascension unless you have insignificant talent points or too many targets
        if OffCooldownNotCasting(ids.Halo) and ( IsPlayerSpell(ids.PowerSurgeTalent) and ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 and IsPlayerSpell(ids.Mindbender) or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) or not IsPlayerSpell(ids.DarkAscension) ) and ( C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 4  or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent)) ) then
            -- KTrig("Halo") return true end
            if aura_env.config[tostring(ids.Halo)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Halo")
            elseif aura_env.config[tostring(ids.Halo)] ~= true then
                KTrig("Halo")
                return true
            end
        end
        
        -- Make sure Mindbender is active before popping Void Eruption and dump charges of Mind Blast before casting
        if OffCooldownNotCasting(ids.VoidEruption) and ( ( ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent) ) and C_Spell.GetSpellCharges(ids.MindBlast).currentCharges == 0 or PlayerHasBuff(ids.MindDevourerBuff) and IsPlayerSpell(ids.MindDevourerTalent) ) then
            -- KTrig("Void Eruption") return true end
            if aura_env.config[tostring(ids.VoidEruption)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Eruption")
            elseif aura_env.config[tostring(ids.VoidEruption)] ~= true then
                KTrig("Void Eruption")
                return true
            end
        end
            
        
        if OffCooldownNotCasting(ids.DarkAscension) and ( (ShadowfiendDuration > 0 and ShadowfiendDuration >= 4 or not IsPlayerSpell(ids.Mindbender) and not OffCooldown(ids.Shadowfiend) or NearbyEnemies > 2 and not IsPlayerSpell(ids.InescapableTormentTalent)) and (DevouredEnemies >= 1 or CurrentInsanity >= (15 + 5 * (not IsPlayerSpell(ids.MindsEyeTalent) and 1 or 0) + 5 * (IsPlayerSpell(ids.DistortedRealityTalent) and 1 or 0 ) - ((ShadowfiendDuration > 0) and 1 or 0) * 6) ) ) then
            -- KTrig("Dark Ascension") return true end
            if aura_env.config[tostring(ids.DarkAscension)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Dark Ascension")
            elseif aura_env.config[tostring(ids.DarkAscension)] ~= true then
                KTrig("Dark Ascension")
                return true
            end
        end
    end
    
    local EmpoweredFiller = function()
        if OffCooldown(ids.MindSpike) and PlayerHasBuff(ids.MindSpikeInsanityBuff) then
            KTrig("Mind Spike Insanity") return true end
            -- KTrig("Mind Spike") return true end
        
        if OffCooldown(ids.MindFlay) and ( PlayerHasBuff(ids.MindFlayInsanityBuff) ) then
            --KTrig("Mind Flay Insanity") return true end
            KTrig("Mind Flay") return true end
    end
    
    local Filler = function()
        if EmpoweredFiller() then return true end
        
        -- Cast Vampiric Touch to proc Unfurling Darkness
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsPlayerSpell(ids.UnfurlingDarknessTalent) and GetRemainingAuraDuration("player", ids.UnfurlingDarknessCdBuff, "PLAYER|HARMFUL") < max(C_Spell.GetSpellInfo(ids.VampiricTouch).castTime/1000, WeakAuras.gcdDuration()) and IsPlayerSpell(ids.InnerQuietusTalent) ) then
            KTrig("Vampiric Touch") return true end
        
        if OffCooldown(ids.ShadowWordDeath) and ( (UnitHealth("target")/UnitHealthMax("target")*100) < 20 or PlayerHasBuff(ids.DeathspeakerBuff) and TargetHasDebuff(ids.DevouringPlague) ) then
            KTrig("Shadow Word Death") return true end
        
        if OffCooldown(ids.ShadowWordDeath) and ( IsPlayerSpell(ids.InescapableTormentTalent) and ShadowfiendDuration > 0 ) then
            KTrig("Shadow Word Death") return true end
        
        --if OffCooldown(ids.MindFlay) and ( bugs and PlayerHasBuff(ids.VoidformBuff) and GetRemainingSpellCooldown(ids.VoidBolt) <= WeakAuras.gcdDuration() * 1.65738) then
        --    KTrig("Mind Flay")
        --end
        
        if OffCooldown(ids.DevouringPlague) and ( IsPlayerSpell(ids.EmpoweredSurgesTalent) and (PlayerHasBuff(ids.MindSpikeInsanityBuff) or PlayerHasBuff(ids.MindFlayInsanityBuff)) or PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Devouring Plague") return true end
        
        if OffCooldownNotCasting(ids.VampiricTouch) and ( IsPlayerSpell(ids.UnfurlingDarknessTalent) and GetRemainingAuraDuration("player", ids.UnfurlingDarknessCdBuff, "PLAYER|HARMFUL") < max(C_Spell.GetSpellInfo(ids.VampiricTouch).castTime/1000, WeakAuras.gcdDuration()) ) then
            KTrig("Vampiric Touch") return true end
        
        -- Save up to 20s if adds are coming soon.
        if OffCooldownNotCasting(ids.Halo) and ( NearbyEnemies > 1 ) then
            -- KTrig("Halo") return true end
            if aura_env.config[tostring(ids.Halo)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Halo")
            elseif aura_env.config[tostring(ids.Halo)] ~= true then
                KTrig("Halo")
                return true
            end
        end
        
        if EmpoweredFiller() then return true end
        
        if OffCooldown(ids.ShadowCrash) and (not Variables.HoldingCrash and IsPlayerSpell(ids.VoidEruption) and IsPlayerSpell(ids.PerfectedFormTalent)) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
        
        if OffCooldown(ids.MindSpike) then
            KTrig("Mind Spike") return true end
        
        if OffCooldown(ids.MindFlay) then
            KTrig("Mind Flay") return true end
        
        if OffCooldown(ids.DivineStar) then
            -- KTrig("Divine Star") return true end
            if aura_env.config[tostring(ids.DivineStar)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Divine Star")
            elseif aura_env.config[tostring(ids.DivineStar)] ~= true then
                KTrig("Divine Star")
                return true
            end
        end
        
        -- Use Shadow Crash while moving as a low-priority action when adds will not spawn in 20 seconds.
        if OffCooldown(ids.ShadowCrash) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
        
        -- Use Shadow Word: Death while moving as a low-priority action
        if OffCooldown(ids.ShadowWordDeath) then
            KTrig("Shadow Word Death") return true end
    end
    
    local Main = function()
        if NearbyEnemies < 3 then
            Variables.DotsUp = TargetHasDebuff(ids.VampiricTouchDebuff) or IsCasting(ids.VampiricTouch) or (aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 1) and IsPlayerSpell(ids.WhisperingShadowsTalent) end
        
        -- Are we pooling mindblasts? Currently only used for Voidweaver.
        if IsPlayerSpell(ids.VoidBlastTalent) and GetRemainingSpellCooldown(ids.VoidTorrent) <= (max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)) * (2 + (IsPlayerSpell(ids.MindMeltTalent) and 1 or 0) * 2) then
        Variables.PoolingMindblasts = true else Variables.PoolingMindblasts = false end
        
        if FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 and ( not Variables.HoldingCrash or NearbyEnemies > 2 ) then
            if Cds() then return true end end
        
        -- Use Shadowfiend and Mindbender on cooldown as long as Vampiric Touch and Shadow Word: Pain are active and sync with Dark Ascension
        if OffCooldown(ids.Shadowfiend) and GetRemainingSpellCooldown(ids.Mindbender) == 0 and GetRemainingSpellCooldown(ids.Voidwraith) == 0 and ( ( TargetHasDebuff(ids.ShadowWordPain) and Variables.DotsUp or (aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 1) and IsPlayerSpell(ids.WhisperingShadowsTalent) ) and ( FightRemains(60, NearbyRange) < 30 or TargetTimeToXPct(0, 60) > 15 ) and ( not IsPlayerSpell(ids.DarkAscension) or GetRemainingSpellCooldown(ids.DarkAscension) < 1.5 or FightRemains(60, NearbyRange) < 15 ) ) then
            -- KTrig("Shadowfiend") return true end
            if aura_env.config[tostring(ids.Shadowfiend)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadowfiend")
            elseif aura_env.config[tostring(ids.Shadowfiend)] ~= true then
                KTrig("Shadowfiend")
                return true
            end
        end
        
        -- High Priority Shadow Word: Death when you are forcing the bonus from Devour Matter
        if OffCooldown(ids.ShadowWordDeath) and ( (UnitGetTotalAbsorbs("target") > 0) and IsPlayerSpell(ids.DevourMatterTalent) ) then
            KTrig("Shadow Word Death") return true end
        
        -- Blast more burst :wicked:
        if OffCooldownNotCasting(ids.VoidBlast) and ( ( GetRemainingDebuffDuration("target", ids.DevouringPlague) >= max(C_Spell.GetSpellInfo(ids.VoidBlast).castTime/1000, WeakAuras.gcdDuration()) or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5 or (select(8, UnitChannelInfo("player")) == ids.VoidTorrent) and IsPlayerSpell(ids.VoidEmpowermentTalent) ) and ( MaxInsanity - CurrentInsanity >= 16 or GetTimeToFullCharges(ids.MindBlast) <= 1.5 or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5) and ( not IsPlayerSpell(ids.MindDevourerTalent) or not PlayerHasBuff(ids.MindDevourerBuff) or GetRemainingAuraDuration("player", ids.EntropicRiftBuff) <= 1.5 ) ) then
            KTrig("Void Blast") return true end
        
        -- Do not let Voidform Expire if you can avoid it.
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.PerfectedFormTalent) and GetRemainingAuraDuration("player", ids.VoidformBuff) <= max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Devouring Plague") return true end
        
        -- Complicated do not overcap mindblast and use it to protect against void bolt cd desync
        if OffCooldownNotCasting(ids.MindBlast) and ( IsPlayerSpell(ids.VoidEruption) and PlayerHasBuff(ids.VoidformBuff) and GetTimeToFullCharges(ids.MindBlast) <= 1.5 and ( not IsPlayerSpell(ids.InsidiousIreTalent) or GetRemainingDebuffDuration("target", ids.DevouringPlague) >= max(C_Spell.GetSpellInfo(ids.MindBlast).castTime/1000, WeakAuras.gcdDuration()) ) and ( GetRemainingSpellCooldown(ids.VoidBolt) / 1.5 - GetRemainingSpellCooldown(ids.VoidBolt) % 1.5 ) * 1.5 <= 0.25 and ( GetRemainingSpellCooldown(ids.VoidBolt) / 1.5 - GetRemainingSpellCooldown(ids.VoidBolt) % 1.5 ) >= 0.01 ) then
            KTrig("Mind Blast") return true end
        
        -- Use Voidbolt on the enemy with the largest time to die. We do no care about dots because Voidbolt is only accessible inside voidform which guarantees maximum effect
        if GetRemainingSpellCooldown(ids.VoidBolt) == 0 and not IsCasting(ids.VoidBolt) and (PlayerHasBuff(ids.VoidformBuff) or IsCasting(ids.VoidEruption)) and ( MaxInsanity - CurrentInsanity > 16 and GetRemainingSpellCooldown(ids.VoidBolt) <= 0.1 ) then
            -- KTrig("Void Bolt") return true end
            if aura_env.config[tostring(ids.VoidBolt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Bolt")
            elseif aura_env.config[tostring(ids.VoidBolt)] ~= true then
                KTrig("Void Bolt")
                return true
            end
        end

        
        -- Do not overcap on insanity
        if OffCooldown(ids.DevouringPlague) and ( DevouredEnemies <= 1 and GetRemainingDebuffDuration("target", ids.DevouringPlague) <= 1.5 and ( not IsPlayerSpell(ids.VoidEruption) or GetRemainingSpellCooldown(ids.VoidEruption) >= 1.5 * 3 ) or MaxInsanity - CurrentInsanity <= 16 ) then      
            KTrig("Devouring Plague") return true end
        
        -- Cast Void Torrent at very high priority if Voidweaver
        if OffCooldownNotCasting(ids.VoidTorrent) and ( ( TargetHasDebuff(ids.DevouringPlague) or IsPlayerSpell(ids.VoidEruption) and OffCooldown(ids.VoidEruption) ) and IsPlayerSpell(ids.EntropicRiftTalent) and not Variables.HoldingCrash and (GetRemainingSpellCooldown(ids.DarkAscension) >= 12 or not IsPlayerSpell(ids.DarkAscension) or not IsPlayerSpell(ids.VoidBlastTalent))) then
            --KTrig("Void Torrent") return true end
            if aura_env.config[tostring(ids.VoidTorrent)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Torrent")
            elseif aura_env.config[tostring(ids.VoidTorrent)] ~= true then
                KTrig("Void Torrent")
                return true
            end
        end
        
        -- Use Voidbolt on the enemy with the largest time to die. Force a cooldown check here to make sure SimC doesn't wait too long (i.e. weird MF:I desync with GCD)
        if GetRemainingSpellCooldown(ids.VoidBolt) == 0 and not IsCasting(ids.VoidBolt) and (PlayerHasBuff(ids.VoidformBuff) or IsCasting(ids.VoidEruption)) and ( GetRemainingSpellCooldown(ids.VoidBolt) / WeakAuras.gcdDuration() <= 0.1 ) then
            -- KTrig("Void Bolt") return true end
            if aura_env.config[tostring(ids.VoidBolt)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Bolt")
            elseif aura_env.config[tostring(ids.VoidBolt)] ~= true then
                KTrig("Void Bolt")
                return true
            end
        end
        
        -- Spend UFD as a high priority action
        if OffCooldownNotCasting(ids.VampiricTouch) and ( PlayerHasBuff(ids.UnfurlingDarknessBuff) and DottedEnemies <= 5) then
            KTrig("Vampiric Touch") return true end
        
        -- Do not overcap MSI or MFI during Empowered Surges (Archon).
        if ( GetPlayerStacks(ids.MindSpikeInsanityBuff) > 2 and IsPlayerSpell(ids.MindSpike) or GetPlayerStacks(ids.MindFlayInsanityBuff) > 2 and not IsPlayerSpell(ids.MindSpike) ) and IsPlayerSpell(ids.EmpoweredSurgesTalent) and not OffCooldown(ids.VoidEruption) then
            if EmpoweredFiller() then return true end end
        
        -- Spend your Insanity on Devouring Plague at will if the fight will end in less than 10s
        if OffCooldown(ids.DevouringPlague) and ( FightRemains(60, NearbyRange) <= 6 + 4 ) then
            KTrig("Devouring Plague") return true end
        
        -- Use Devouring Plague to maximize uptime. Short circuit if you are capping on Insanity within 35 With Distorted Reality can maintain more than one at a time in multi-target.
        if OffCooldown(ids.DevouringPlague) and ( MaxInsanity - CurrentInsanity <= 35 and IsPlayerSpell(ids.DistortedRealityTalent) or PlayerHasBuff(ids.MindDevourerBuff) and OffCooldown(ids.MindBlast) and ( GetRemainingSpellCooldown(ids.VoidEruption) >= 3 * 1.5 or not IsPlayerSpell(ids.VoidEruption) ) and IsPlayerSpell(ids.MindDevourerTalent) or PlayerHasBuff(ids.EntropicRiftBuff) ) then
            KTrig("Devouring Plague") return true end
        
        -- Use Void Torrent if it will get near full Mastery Value and you have Cthun and Void Eruption. Prune this action for Entropic Rift Builds.
        if OffCooldownNotCasting(ids.VoidTorrent) and ( not Variables.HoldingCrash and not IsPlayerSpell(ids.EntropicRiftTalent) and GetTimeToFullCharges(ids.MindBlast) >= 2 and GetRemainingDebuffDuration("target", ids.DevouringPlague) >= 2.5 ) then
            --KTrig("Void Torrent") return true end
            if aura_env.config[tostring(ids.VoidTorrent)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Void Torrent")
            elseif aura_env.config[tostring(ids.VoidTorrent)] ~= true then
                KTrig("Void Torrent")
                return true
            end
        end
        
        -- Use Shadow Crash as long as you are not holding for adds and Vampiric Touch is within pandemic range
        if OffCooldown(ids.ShadowCrash) and ( not Variables.HoldingCrash and IsAuraRefreshable(ids.VampiricTouchDebuff) and ( not IsPlayerSpell(ids.UnfurlingDarknessTalent) or NearbyEnemies > 1 ) ) then
            -- KTrig("Shadow Crash") return true end
            if aura_env.config[tostring(ids.ShadowCrash)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shadow Crash")
            elseif aura_env.config[tostring(ids.ShadowCrash)] ~= true then
                KTrig("Shadow Crash")
                return true
            end
        end
        
        -- Acquire UFD
        if OffCooldownNotCasting(ids.VampiricTouch) and (GetRemainingAuraDuration("player", ids.UnfurlingDarknessCdBuff, "PLAYER|HARMFUL") < max(C_Spell.GetSpellInfo(ids.VampiricTouch).castTime/1000, WeakAuras.gcdDuration()) and IsPlayerSpell(ids.UnfurlingDarknessTalent) and not PlayerHasBuff(ids.DarkAscension) and IsPlayerSpell(ids.InnerQuietusTalent) and DottedEnemies <= 5) then
            KTrig("Vampiric Touch") return true end
        
        -- Put out Vampiric Touch on enemies that will live at least 12s and Shadow Crash is not available soon
        if OffCooldownNotCasting(ids.VampiricTouch) and ( (not (aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 1) and IsAuraRefreshable(ids.VampiricTouchDebuff)) and TargetTimeToXPct(0, 60) > 12 and ( TargetHasDebuff(ids.VampiricTouchDebuff) or not Variables.DotsUp ) and ( Variables.MaxVts > 0 or NearbyEnemies <= 1 ) and ( GetRemainingSpellCooldown(ids.ShadowCrash) >= GetRemainingDebuffDuration("target", ids.VampiricTouchDebuff) or Variables.HoldingCrash or not IsPlayerSpell(ids.WhisperingShadowsTalent) ) and ( not (aura_env.PrevCast == ids.ShadowCrash and GetTime() - aura_env.PrevCastTime < 0.15) or not IsPlayerSpell(ids.WhisperingShadowsTalent) ) ) then
            KTrig("Vampiric Touch") return true end
        
        -- Use all charges of Mind Blast if Vampiric Touch and Shadow Word: Pain are active and Mind Devourer is not active or you are prepping Void Eruption
        if OffCooldown(ids.MindBlast) and (C_Spell.GetSpellCharges(ids.MindBlast).currentCharges > 1 or not IsCasting(ids.MindBlast)) and ( ( not PlayerHasBuff(ids.MindDevourerBuff) or not IsPlayerSpell(ids.MindDevourerTalent) or OffCooldown(ids.VoidEruption) and IsPlayerSpell(ids.VoidEruption) ) and not Variables.PoolingMindblasts ) then
            KTrig("Mind Blast") return true end
        
        if OffCooldown(ids.DevouringPlague) and ( PlayerHasBuff(ids.VoidformBuff) and IsPlayerSpell(ids.PerfectedFormTalent) and IsPlayerSpell(ids.VoidEruption) ) then
            KTrig("Devouring Plague") return true end
        
        if Filler() then return true end
    end
    
    if NearbyEnemies > 2 then
        if Aoe() then return true end end
    
    if Main() then return true end
    
    -- Kichi --
    KTrig("Clear")
    --KTrigCD("Clear")
end
