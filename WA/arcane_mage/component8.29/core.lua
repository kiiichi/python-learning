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
    local IsSpellKnown = C_SpellBook.IsSpellKnown
    -- Kichi --
    local KTrig = aura_env.KTrig
    local KTrigCD = aura_env.KTrigCD
    aura_env.FlagKTrigCD = true
    local FullGCD = aura_env.FullGCD
    local TalentRank = aura_env.TalentRank
    local IsChanneling = aura_env.IsChanneling

    ---@class idsTable
    local ids = aura_env.ids
    aura_env.OutOfRange = false
    local Variables = {}
    local GcdMax = max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75)
    
    ---- Setup Data -----------------------------------------------------------------------------------------------     
    local SetPieces = WeakAuras.GetNumSetItemsEquipped(1924)
    local OldSetPieces = WeakAuras.GetNumSetItemsEquipped(1872)
    
    local CurrentArcaneCharges = UnitPower("player", Enum.PowerType.ArcaneCharges)
    local MaxArcaneCharges = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)
    local CurrentMana = UnitPower("player", Enum.PowerType.Mana)
    local MaxMana = UnitPowerMax("player", Enum.PowerType.Mana)
    local NetherPrecisionStacks = GetPlayerStacks(ids.NetherPrecisionBuff)
    
    local CurrentCast = select(9, UnitCastingInfo("player"))
    if CurrentCast ~= nil then
        if CurrentCast == ids.ArcaneBlast then
            CurrentArcaneCharges = min(4, CurrentArcaneCharges+1)
            NetherPrecisionStacks = max(0, NetherPrecisionStacks - 1)
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

    -- Kichi --
    -- Only recommend things when something's targeted
    if aura_env.config["NeedTarget"] then
        if UnitExists("target") == false or UnitCanAttack("player", "target") == false then
            WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows)
            KTrig("Clear", nil)
            KTrigCD("Clear", nil) 
            return end
    end
    
    ---- Variables -------------------------------------------------------------------------------------------
    
    Variables.SoulBurst = aura_env.config["SoulBurstSwitch"]
    if SetPieces >= 4 and IsSpellKnown(ids.SpellfireSpheresTalent) and IsSpellKnown(ids.ResonanceTalent) and not IsSpellKnown(ids.MagisSparkTalent) and ( NearbyEnemies >= 3 ) and Variables.SoulBurst 
    and not (aura_env.config["SoulBurstSwitchBack"] == true and GetRemainingSpellCooldown(ids.Evocation)>80 and ( GetRemainingSpellCooldown(ids.ArcaneSurge) < (GcdMax * 3) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 5 or false ) ) then
        Variables.SoulCd = true
    else
        Variables.SoulCd = false
    end

    Variables.AoeTargetCount = 2
    
    if not IsSpellKnown(ids.ArcingCleaveTalent) then
    Variables.AoeTargetCount = 9 end
    
    if not TargetHasDebuff(ids.TouchOfTheMagiDebuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) == 0 then
        Variables.Opener = true 
    else 
        aura_env.UsedOrb = false
        aura_env.UsedMissiles = false
        aura_env.UsedBarrage = false
        Variables.Opener = false
    end
    
    Variables.AoeList = aura_env.config["AoeList"]

    ---- No GCDs - Can glow at the same time as a regular ability ------------------------------------------------- 
    local ExtraGlows = {}
    
    WeakAuras.ScanEvents("K_TRIGED_EXTRA", ExtraGlows, nil)
    
    ---- Normal GCDs -------------------------------------------------------------------------------------------
    
    local CdOpener = function()
        -- Touch of the Magi used if you just used Arcane Surge, the wait simulates the time it takes to queue another spell after Touch when you Surge into Touch, otherwise we'll Touch off cooldown either after Barrage or if we just need Charges.
        -- Kichi because use TouchOfTheMagi macro so remove: ( ( CurrentArcaneCharges < 4 and not (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage) ) ) or (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage) ) )
        -- Kichi remove: FightRemains(60, NearbyRange) < 15
        if OffCooldown(ids.TouchOfTheMagi) and ( aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge) or ( GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 and OffCooldown(ids.TouchOfTheMagi) and true ) ) then
            -- KTrig("Touch Of The Magi") return true end
            if aura_env.config[tostring(ids.TouchOfTheMagi)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Touch Of The Magi")
            elseif aura_env.config[tostring(ids.TouchOfTheMagi)] ~= true then
                KTrig("Touch Of The Magi")
                return true
            end
        end
        
        if OffCooldown(ids.ArcaneBlast) and ( PlayerHasBuff(ids.PresenceOfMind) ) then
            KTrig("Arcane Blast") return true end
        
        -- Use Orb for Charges on the opener if you have High Voltage as the Missiles will generate the remaining Charge you need
        if OffCooldown(ids.ArcaneOrb) and ( IsSpellKnown(ids.HighVoltageTalent) and Variables.Opener and not aura_env.UsedOrb ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        -- Barrage before Evocation if Tempo will expire
        if OffCooldown(ids.ArcaneBarrage) and Variables.Opener and not aura_env.UsedBarrage and ( PlayerHasBuff(ids.ArcaneTempoBuff) and OffCooldown(ids.Evocation) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < GcdMax * 5 ) then
            KTrig("Arcane Barrage") return true end
        
        -- Kichi remove: FightRemains(60, NearbyRange) < 25
        if OffCooldown(ids.Evocation) and ( GetRemainingSpellCooldown(ids.ArcaneSurge) < (GcdMax * 3) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 5 or false ) then
            -- KTrig("Evocation") return true end
            if aura_env.config[tostring(ids.Evocation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Evocation")
            elseif aura_env.config[tostring(ids.Evocation)] ~= true then
                KTrig("Evocation")
                return true
            end
        end
        
        -- Use Missiles to get Nether Precision up for your burst window, clipping logic applies as long as you don't have Aether Attunement.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and not aura_env.UsedMissiles and ( ((aura_env.PrevCast == ids.Evocation or IsCasting(ids.Evocation)) or (aura_env.PrevCast == ids.ArcaneSurge or IsCasting(ids.ArcaneSurge)) or Variables.Opener ) and NetherPrecisionStacks == 0 ) then
            KTrig("Arcane Missiles") return true end
        
        -- Kichi remove: FightRemains(60, NearbyRange) < 25
        if OffCooldownNotCasting(ids.ArcaneSurge) and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < ( max(C_Spell.GetSpellInfo(ids.ArcaneSurge).castTime/1000, WeakAuras.gcdDuration()) + ( GcdMax * ( (CurrentArcaneCharges == 4) and 1 or 0 ) ) ) or false ) then
            -- KTrig("Arcane Surge") return true end
            if aura_env.config[tostring(ids.ArcaneSurge)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Surge")
            elseif aura_env.config[tostring(ids.ArcaneSurge)] ~= true then
                KTrig("Arcane Surge")
                return true
            end
        end

    end
    
    -- actions.cd_opener_soul=arcane_surge,if=(cooldown.touch_of_the_magi.remains<15)
    -- actions.cd_opener_soul+=/evocation,if=buff.arcane_surge.up&(buff.arcane_surge.remains<=8.5|((buff.glorious_incandescence.up|buff.intuition.react)&buff.arcane_surge.remains<=10))
    -- actions.cd_opener_soul+=/touch_of_the_magi,if=(buff.arcane_surge.remains<=2.5&prev_gcd.1.arcane_barrage)|(cooldown.evocation.remains>40&cooldown.evocation.remains<60&prev_gcd.1.arcane_barrage)
    local CdOpenerSoul = function()
        -- Arcane Surge if Touch of the Magi cooldown is less than 15 seconds
        if OffCooldownNotCasting(ids.ArcaneSurge) and (GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 15) then
            -- KTrig("Arcane Surge") return true end
            if aura_env.config[tostring(ids.ArcaneSurge)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Surge")
            elseif aura_env.config[tostring(ids.ArcaneSurge)] ~= true then
                KTrig("Arcane Surge")
                return true
            end
        end

        -- Evocation if Arcane Surge buff is up and (buff duration <= 8.5 or (Glorious Incandescence or Intuition up and buff duration <= 10))
        -- Kichi change time number for simc fix
        if OffCooldown(ids.Evocation) and PlayerHasBuff(ids.ArcaneSurgeBuff) and (
            GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) <= 11 or
            ((PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff)) and GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) <= 13)
        ) then
            -- KTrig("Evocation") return true end
            if aura_env.config[tostring(ids.Evocation)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Evocation")
            elseif aura_env.config[tostring(ids.Evocation)] ~= true then
                KTrig("Evocation")
                return true
            end
        end

        -- Touch of the Magi if Arcane Surge buff remains <= 2.5 and previous GCD was Arcane Barrage or Evocation cooldown > 40 and < 60 and previous GCD was Arcane Barrage
        -- Kichi use arcane_barrage micro so remove: aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)
        if OffCooldown(ids.TouchOfTheMagi) and ( (PlayerHasBuff(ids.ArcaneSurgeBuff) and
            GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) <= 2.5 and ( true )) or ( GetRemainingSpellCooldown(ids.Evocation) > 40 and GetRemainingSpellCooldown(ids.Evocation) < 60 and ( true )) )
        then
            -- KTrig("Touch Of The Magi") return true end
            if aura_env.config[tostring(ids.TouchOfTheMagi)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Touch Of The Magi")
            elseif aura_env.config[tostring(ids.TouchOfTheMagi)] ~= true then
                KTrig("Touch Of The Magi")
                return true
            end
        end
    end

    local Spellslinger = function()
        -- With Shifting Shards we can use Shifting Power whenever basically favoring cooldowns slightly, without it though we want to use it outside of cooldowns, don't cast if it'll conflict with Intuition expiration.
        if OffCooldown(ids.ShiftingPower) and ( ( ( ( ( ( C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges == 0 ) and GetRemainingSpellCooldown(ids.ArcaneOrb) > 16 ) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 20 ) and PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > ( 12 + 6 * GcdMax ) ) or 
                ( (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) and IsSpellKnown(ids.ShiftingShardsTalent) and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) and ( PlayerHasBuff(ids.ArcaneSurgeBuff) or TargetHasDebuff(ids.TouchOfTheMagiDebuff) or GetRemainingSpellCooldown(ids.Evocation) < 20 ) ) ) and 
            FightRemains(60, NearbyRange) > 10 and ( GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) > GcdMax * 2.5 or PlayerHasBuff(ids.ArcaneTempoBuff) == false ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power")
                return true
            end
        end

        if OffCooldown(ids.Supernova) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) <= GcdMax and GetPlayerStacks(ids.UnerringProficiencyBuff) == 30 ) then
            -- KTrig("Supernova") return true end
            if aura_env.config[tostring(ids.Supernova)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Supernova")
            elseif aura_env.config[tostring(ids.Supernova)] ~= true then
                KTrig("Supernova")
                return true
            end
        end
        
        -- Orb if you need charges.
        if OffCooldown(ids.ArcaneOrb) and ( CurrentArcaneCharges < 4 ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end

        -- Barrage if Tempo is about to expire.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) <= GcdMax * 2 ) then
            KTrig("Arcane Barrage") return true end
        
        -- Use Aether Attunement up before casting Touch if you have S2 4pc equipped to avoid munching.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 3 and PlayerHasBuff(ids.ClearcastingBuff) and (OldSetPieces >= 4) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Kichi use micro to instead --
        -- -- Barrage if Touch is up or will be up while Barrage is in the air.
        -- if OffCooldown(ids.ArcaneBarrage) and ( ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.050 ), GcdMax ) ) and ( GetRemainingSpellCooldown(ids.ArcaneSurge) > 30 and GetRemainingSpellCooldown(ids.ArcaneSurge) < 75 ) ) then
        --     KTrig("Arcane Barrage") return true end

        -- Anticipate the Intuition granted from the Season 3 set bonus.
        if OffCooldown(ids.ArcaneBarrage) and ( CurrentArcaneCharges == 4 and GetPlayerStacks(ids.ArcaneHarmonyBuff) >= 20 and SetPieces >= 4 ) then
            KTrig("Arcane Barrage") return true end
        
        -- Use Clearcasting procs to keep Nether Precision up, if you don't have S2 4pc try to pool Aether Attunement for cooldown windows.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( ( PlayerHasBuff(ids.ClearcastingBuff) and (NetherPrecisionStacks == 0) and ( ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 7 and GetRemainingSpellCooldown(ids.ArcaneSurge) > GcdMax * 7 ) or GetPlayerStacks(ids.ClearcastingBuff) > 1 or not IsSpellKnown(ids.MagisSparkTalent) or ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * 4 and GetPlayerStacks(ids.AetherAttunementBuff) == 0 ) or (OldSetPieces >= 4) ) ) or ( FightRemains(60, NearbyRange) < 5 and PlayerHasBuff(ids.ClearcastingBuff) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Missile to refill charges if you have High Voltage and either Aether Attunement or more than one Clearcasting proc. Recheck AOE
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( IsPlayerSpell(ids.HighVoltageTalent) and ( GetPlayerStacks(ids.ClearcastingBuff) > 1 or ( PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) ) ) and CurrentArcaneCharges < 3 ) then
            KTrig("Arcane Missiles") return true end

        -- Use Intuition.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.IntuitionBuff) ) then
            KTrig("Arcane Barrage") return true end

        -- Make sure to always activate Spark!
        if OffCooldown(ids.ArcaneBlast) and ( aura_env.NeedArcaneBlastSpark or PlayerHasBuff(ids.LeydrinkerBuff) ) then
            KTrig("Arcane Blast") return true end
        
        -- In single target, spending your Nether Precision stacks on Blast is a higher priority in single target.
        if OffCooldown(ids.ArcaneBlast) and ( (NetherPrecisionStacks > 0) and GetPlayerStacks(ids.ArcaneHarmonyBuff) <= 16 and CurrentArcaneCharges == 4 and NearbyEnemies == 1 ) then
            KTrig("Arcane Blast") return true end

        -- Barrage if you're going to run out of mana and have Orb ready.
        if OffCooldown(ids.ArcaneBarrage) and ( (CurrentMana/MaxMana*100) < 10 and PlayerHasBuff(ids.ArcaneSurgeBuff) == false and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Orb in ST if you don't have Charged Orb, will overcap soon, and before entering cooldowns.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies == 1 and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) < 6 or not IsSpellKnown(ids.ChargedOrbTalent) or PlayerHasBuff(ids.ArcaneSurgeBuff) or GetSpellChargesFractional(ids.ArcaneOrb) > 1.5 ) ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end

        -- Barrage if you have orb coming off cooldown in AOE and you don't have enough harmony stacks to make it worthwhile to hold for set proc.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies >= 2 and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax and ( GetPlayerStacks(ids.ArcaneHarmonyBuff) <= ( 8 + ( 10 * (SetPieces >= 4 and 0 or 1) ) ) ) and ( ( ( (aura_env.PrevCast == ids.ArcaneBarrage or IsCasting(ids.ArcaneBarrage)) or (aura_env.PrevCast == ids.ArcaneOrb or IsCasting(ids.ArcaneOrb)) ) and NetherPrecisionStacks == 1 ) or NetherPrecisionStacks == 2 or (NetherPrecisionStacks == 0) ) ) then
            KTrig("Arcane Barrage") return true end

        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 2 and ( CurrentArcaneCharges == 4 and not (SetPieces >= 4) ) ) then
            KTrig("Arcane Barrage") return true end

        -- Orb if you're low on Harmony stacs.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies > 1 and GetPlayerStacks(ids.ArcaneHarmonyBuff) < 20 and ( PlayerHasBuff(ids.ArcaneSurgeBuff) or (NetherPrecisionStacks > 0) or NearbyEnemies >= 7 ) and (SetPieces >= 4) ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        -- Arcane Barrage in AOE if you have Aether Attunement ready and High Voltage
        if OffCooldown(ids.ArcaneBarrage) and ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies >= 2 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.AetherAttunementBuff) and PlayerHasBuff(ids.ClearcastingBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Use Orb more aggressively if cleave and a little less in AOE.
        if OffCooldown(ids.ArcaneOrb) and ( NearbyEnemies > 1 and ( NearbyEnemies < 3 or PlayerHasBuff(ids.ArcaneSurgeBuff) or ( (NetherPrecisionStacks > 0) ) ) and (SetPieces >= 4) ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end

        -- Barrage if Orb is available in AOE.
        if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 1 and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) then
            KTrig("Arcane Barrage") return true end
        
        -- If you have High Voltage throw out a Barrage before you need to use Clearcasting for NP.
        if OffCooldown(ids.ArcaneBarrage) and ( IsSpellKnown(ids.HighVoltageTalent) and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 ) then
            KTrig("Arcane Barrage") return true end

        -- Barrage with Orb Barrage or execute if you have orb up and no Nether Precision or no way to get another and use Arcane Orb to recover Arcane Charges, old resources for Touch of the Magi if you have Magi's Spark. Skip this with Season 3 set.
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies <= 1 and ( IsSpellKnown(ids.OrbBarrageTalent) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) ) ) and ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax ) and CurrentArcaneCharges == 4 and ( GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 6 or not IsSpellKnown(ids.MagisSparkTalent) ) and ( (NetherPrecisionStacks == 0) or ( NetherPrecisionStacks == 1 and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) and not ( SetPieces >= 4 ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- -- Kichi add to modify 4.14 simc to lower arcane_blast frequency in AOE
        -- if OffCooldown(ids.ArcaneBarrage) and ( NearbyEnemies > 1 and ( aura_env.NeedArcaneBlastSpark == false or not IsPlayerSpell(ids.MagisSparkTalent) ) and CurrentArcaneCharges > 2 ) then
        --     KTrig("Arcane Barrage") return true end
        
        -- -- Kichi add to modify 4.14 simc to lower arcane_blast frequency in AOE
        -- if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( NearbyEnemies > 1 and IsPlayerSpell(ids.HighVoltageTalent) and PlayerHasBuff(ids.ClearcastingBuff) and CurrentArcaneCharges < 3 ) then
        --     KTrig("Arcane Missiles") return true end

        -- Kichi add distance check for Arcane Explosion: and WeakAuras.CheckRange("target", 10, "<=")
        -- Use Explosion for your first charge or if you have High Voltage you can use it for charge 2 and 3, but at a slightly higher target count.
        if OffCooldown(ids.ArcaneExplosion) and WeakAuras.CheckRange("target", 10, "<=") and ( NearbyEnemies > 1 and ( ( CurrentArcaneCharges < 1 and not IsSpellKnown(ids.HighVoltageTalent) ) or ( CurrentArcaneCharges < 3 and ( GetPlayerStacks(ids.ClearcastingBuff) == 0 or IsSpellKnown(ids.ReverberateTalent) ) ) ) ) then   
            KTrig("Arcane Explosion") return true end

        -- Kichi add distance check for Arcane Explosion: and WeakAuras.CheckRange("target", 10, "<=")
        -- You can use Arcane Explosion in single target for your first 2 charges when you have no Clearcasting procs and aren't out of mana. This is only a very slight gain for some profiles so don't feel you have to do this.
        if OffCooldown(ids.ArcaneExplosion) and WeakAuras.CheckRange("target", 10, "<=") and ( NearbyEnemies == 1 and CurrentArcaneCharges < 2 and not PlayerHasBuff(ids.ClearcastingBuff) ) then
            KTrig("Arcane Explosion") return true end
        
        -- Barrage in execute if you're at the end of Touch or at the end of Surge windows. Skip this with Season 3 set.
        if OffCooldown(ids.ArcaneBarrage) and ( ( ( ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( GcdMax * 1.25 ) ) and ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) > 0.75 ) ) or ( ( GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) < GcdMax ) and PlayerHasBuff(ids.ArcaneSurgeBuff) ) ) and CurrentArcaneCharges == 4 ) and not ( SetPieces >= 4 ) ) then
            KTrig("Arcane Barrage") return true end
            
        -- Nothing else to do? Blast. Out of mana? Barrage.
        if OffCooldown(ids.ArcaneBlast) then
            KTrig("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            KTrig("Arcane Barrage") return true end
    end
    
    local Sunfury = function()
        -- For Sunfury, Shifting Power only when you're not under the effect of any cooldowns.
        if OffCooldown(ids.ShiftingPower) and ( ( ( PlayerHasBuff(ids.ArcaneSurgeBuff) == false and PlayerHasBuff(ids.SiphonStormBuff) == false and TargetHasDebuff(ids.TouchOfTheMagiDebuff) == false and GetRemainingSpellCooldown(ids.Evocation) > 15 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > 10 ) and FightRemains(60, NearbyRange) > 10 ) and PlayerHasBuff(ids.ArcaneSoulBuff) == false and ( not PlayerHasBuff(ids.IntuitionBuff) or (PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) > 3.5 ) ) ) then
            -- KTrig("Shifting Power") return true end
            if aura_env.config[tostring(ids.ShiftingPower)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Shifting Power")
            elseif aura_env.config[tostring(ids.ShiftingPower)] ~= true then
                KTrig("Shifting Power")
                return true
            end
        end

        -- When Arcane Soul is up, use Missiles to generate Nether Precision as needed while also ensuring you end Soul with 3 Clearcasting.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( (NetherPrecisionStacks == 0) and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.ArcaneSoulBuff) and GetRemainingAuraDuration("player", ids.ArcaneSoulBuff) > GcdMax * ( 4 - (PlayerHasBuff(ids.ClearcastingBuff) and 1 or 0) ) ) then
            KTrig("Arcane Missiles") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.ArcaneSoulBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Dump a clearcasting proc before you go into Soul if you have one.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.ArcaneSurgeBuff) and GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) < GcdMax * 2 ) then
            KTrig("Arcane Missiles") return true end

        -- Prioritize Tempo and Intuition if they are about to expire.
        if OffCooldown(ids.ArcaneBarrage) and ( ( PlayerHasBuff(ids.ArcaneTempoBuff) and GetRemainingAuraDuration("player", ids.ArcaneTempoBuff) < ( GcdMax + ( GcdMax * ( NetherPrecisionStacks == 1 and 1 or 0 ) ) ) ) or ( PlayerHasBuff(ids.IntuitionBuff) and GetRemainingAuraDuration("player", ids.IntuitionBuff) < ( GcdMax + ( GcdMax * ( NetherPrecisionStacks == 1 and 1 or 0 ) ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Gamble on Orb Barrage in AOE to prevent overcapping on Harmony stacks.
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.OrbBarrageTalent) and NearbyEnemies > 1 and GetPlayerStacks(ids.ArcaneHarmonyBuff) >= 18 and ( ( NearbyEnemies > 3 and ( IsSpellKnown(ids.ResonanceTalent) or IsSpellKnown(ids.HighVoltageTalent) ) ) or (NetherPrecisionStacks == 0) or NetherPrecisionStacks == 1 or ( NetherPrecisionStacks == 2 and GetPlayerStacks(ids.ClearcastingBuff) == 3 ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Spend Aether Attunement if you have 4pc S2 set before Touch.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and (OldSetPieces >= 4) and PlayerHasBuff(ids.AetherAttunementBuff) and GetRemainingSpellCooldown(ids.TouchOfTheMagi) < GcdMax * ( 3 - ( 1.5 * ( ( NearbyEnemies > 3 and ( not IsSpellKnown(ids.TimeLoopTalent) or IsSpellKnown(ids.ResonanceTalent) ) ) and 1 or 0 ) ) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- -- Kichi use micro to instead --
        -- -- Barrage into Touch if you have charges when it comes up.
        -- if OffCooldown(ids.ArcaneBarrage) and ( CurrentArcaneCharges == 4 and ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.05 ), GcdMax ) ) and not Variables.SoulCd ) then
        --  KTrig("Arcane Barrage") return true end
        -- if OffCooldown(ids.ArcaneBarrage) and ( ( OffCooldown(ids.TouchOfTheMagi) or GetRemainingSpellCooldown(ids.TouchOfTheMagi) < min( ( 0.75 + 0.05 ), GcdMax ) ) and ( not PlayerHasBuff(ids.ArcaneSurgeBuff) or ( PlayerHasBuff(ids.ArcaneSurgeBuff) and GetRemainingAuraDuration("player", ids.ArcaneSurgeBuff) <= 2.5 ) ) and Variables.SoulCd ) then
        -- --  KTrig("Arcane Barrage") return true end

        -- Blast if Magi's Spark is up.
        if OffCooldown(ids.ArcaneBlast) and ( aura_env.NeedArcaneBlastSpark and CurrentArcaneCharges == 4 ) then
            KTrig("Arcane Blast") return true end

        -- -- Blast whenever you have the bonus from Leydrinker or Magi's Spark up, don't let spark expire in AOE.
        -- if OffCooldown(ids.ArcaneBlast) and ( ( ( aura_env.NeedArcaneBlastSpark and ( ( GetRemainingDebuffDuration("target", ids.TouchOfTheMagiDebuff) < ( (C_Spell.GetSpellInfo(ids.ArcaneBlast).castTime/1000) + max(1.5/(1+0.01*UnitSpellHaste("player")), 0.75) ) ) or NearbyEnemies <= 1 or IsPlayerSpell(ids.LeydrinkerTalent) ) ) or PlayerHasBuff(ids.LeydrinkerBuff) ) and CurrentArcaneCharges == 4 and ( (NetherPrecisionStacks > 0) or GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) then
        --     KTrig("Arcane Blast") return true end
        
        -- AOE Barrage conditions revolve around sending Barrages various talents. Whenever you have Clearcasting and Nether Precision or if you have Aether Attunement to recharge with High Voltage. Whenever you have Orb Barrage you should gamble basically any chance you get in execute. Lastly, with Arcane Orb available, you can send Barrage as long as you're not going to use Touch soon and don't have a reason to use Blast up.
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies > 1 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and NetherPrecisionStacks == 1 ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( IsSpellKnown(ids.HighVoltageTalent) and NearbyEnemies > 1 and CurrentArcaneCharges == 4 and PlayerHasBuff(ids.ClearcastingBuff) and PlayerHasBuff(ids.AetherAttunementBuff) and PlayerHasBuff(ids.GloriousIncandescenceBuff) == false and PlayerHasBuff(ids.IntuitionBuff) == false ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 2 and IsSpellKnown(ids.OrbBarrageTalent) and IsSpellKnown(ids.HighVoltageTalent) and not aura_env.NeedArcaneBlastSpark and CurrentArcaneCharges == 4 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) and ( (NetherPrecisionStacks > 0) or ( (NetherPrecisionStacks == 0) and GetPlayerStacks(ids.ClearcastingBuff) == 0 ) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        if OffCooldown(ids.ArcaneBarrage) and ( ( NearbyEnemies > 2 or ( NearbyEnemies > 1 and (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) ) ) and GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax and CurrentArcaneCharges == 4 and GetRemainingSpellCooldown(ids.TouchOfTheMagi) > GcdMax * 6 and ( not aura_env.NeedArcaneBlastSpark or not IsSpellKnown(ids.MagisSparkTalent) ) and (NetherPrecisionStacks > 0) and ( IsSpellKnown(ids.HighVoltageTalent) or ( ( not PlayerHasBuff(ids.LeydrinkerBuff) or ( (UnitHealth("target")/UnitHealthMax("target")*100) < 35 and IsSpellKnown(ids.ArcaneBombardmentTalent) and NearbyEnemies >= 4 and IsSpellKnown(ids.ResonanceTalent) ) ) and NetherPrecisionStacks == 2 ) or ( NetherPrecisionStacks == 1 and not PlayerHasBuff(ids.ClearcastingBuff) ) ) ) then
            KTrig("Arcane Barrage") return true end
        
        -- Kichi add: () for NG wrong
        -- Missiles to recoup Charges with High Voltage or maintain Nether Precision and combine it with other Barrage buffs.
        if OffCooldown(ids.ArcaneMissiles) and not IsChanneling(ids.ArcaneMissiles) and ( PlayerHasBuff(ids.ClearcastingBuff) and ( ( IsSpellKnown(ids.HighVoltageTalent) and CurrentArcaneCharges < 4 ) or ( NetherPrecisionStacks == 0 and (GetPlayerStacks(ids.ClearcastingBuff) > 1 or GetPlayerStacks(ids.SpellfireSpheresBuff) == 6 or PlayerHasBuff(ids.BurdenOfPowerBuff) or PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff)) ) ) ) then
            KTrig("Arcane Missiles") return true end
        
        -- Kichi remove for same with simc
        -- -- Barrage with Burden if 2-4 targets and you have a way to recoup Charges, however skip this is you have Bauble and don't have High Voltage.
        -- if OffCooldown(ids.ArcaneBarrage) and ( ( CurrentArcaneCharges == 4 and NearbyEnemies > 1 and NearbyEnemies < 5 and PlayerHasBuff(ids.BurdenOfPowerBuff) and ( ( IsSpellKnown(ids.HighVoltageTalent) and PlayerHasBuff(ids.ClearcastingBuff) ) or PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) or ( GetRemainingSpellCooldown(ids.ArcaneOrb) < GcdMax or C_Spell.GetSpellCharges(ids.ArcaneOrb).currentCharges > 0 ) ) ) and ( not IsSpellKnown(ids.ConsortiumsBaubleTalent) or IsSpellKnown(ids.HighVoltageTalent) ) ) then
        --     KTrig("Arcane Barrage") return true end
        
        -- Arcane Orb to recover Charges quickly if below 3.
        if OffCooldown(ids.ArcaneOrb) and ( CurrentArcaneCharges < 3 ) then
            -- KTrig("Arcane Orb") return true end
            if aura_env.config[tostring(ids.ArcaneOrb)] == true and aura_env.FlagKTrigCD then
                KTrigCD("Arcane Orb")
            elseif aura_env.config[tostring(ids.ArcaneOrb)] ~= true then
                KTrig("Arcane Orb")
                return true
            end
        end
        
        -- Barrage with Intuition or Incandescence.
        if OffCooldown(ids.ArcaneBarrage) and ( PlayerHasBuff(ids.GloriousIncandescenceBuff) or PlayerHasBuff(ids.IntuitionBuff) ) then
            KTrig("Arcane Barrage") return true end
        
        -- In AOE, Presence of Mind is used to build Charges. Arcane Explosion can be used to build your first Charge.
        --if OffCooldown(ids.PresenceOfMind) and ( ( CurrentArcaneCharges == 3 or CurrentArcaneCharges == 2 ) and NearbyEnemies >= 3 ) then
        --    KTrig("Presence Of Mind") return true end
        
        -- Kichi add distance check for Arcane Explosion
        if OffCooldown(ids.ArcaneExplosion) and WeakAuras.CheckRange("target", 10, "<=") and ( CurrentArcaneCharges < 2 and NearbyEnemies > 1 ) then
            KTrig("Arcane Explosion") return true end
        
        if OffCooldown(ids.ArcaneBlast) then
            KTrig("Arcane Blast") return true end
        
        if OffCooldown(ids.ArcaneBarrage) then
            KTrig("Arcane Barrage") return true end
    end
    
    if OffCooldown(ids.ArcaneBarrage) and ( FightRemains(60, NearbyRange) < 2 ) then
        KTrig("Arcane Barrage") return true end
    
    -- Enter cooldowns, then action list depending on your hero talent choices
    if not Variables.SoulCd then 
        if CdOpener() then return true end 
    end

    if Variables.SoulCd then
        if CdOpenerSoul() then return true end
    end
    
    if IsSpellKnown(ids.SpellfireSpheresTalent) then
        if Sunfury() then return true end end
    
    if not IsSpellKnown(ids.SpellfireSpheresTalent) then
        if Spellslinger() then return true end end
    
    if OffCooldown(ids.ArcaneBarrage) then
        KTrig("Arcane Barrage") return true end

    -- Kichi --
    KTrig("Clear")
    KTrigCD("Clear")

end
