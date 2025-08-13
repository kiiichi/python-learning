aura_env.NearbyEnemies = 0

---@class idsTable
aura_env.ids = {
    -- Abilities
    DarkAscension = 391109,
    DevouringPlague = 335467,
    DivineStar = 122121,
    Halo = 120644,
    MindBlast = 8092,
    MindFlay = 15407,
    MindSpike = 73510, -- Check if this is exist
    MindSpikeInsanity = 407466, -- Check if this is exist
    Mindbender = 200174,
    ShadowCrash = 205385,
    ShadowWordDeath = 32379,
    ShadowWordPain = 589,
    Shadowfiend = 34433, -- NG name incorrect
    VampiricTouch = 34914,
    VoidBlast = 450983,
    VoidBolt = 205448,
    VoidEruption = 228260,
    VoidTorrent = 263165,
    VoidVolley = 1242173,
    Voidwraith = 451235,
    
    -- Talents
    DepthOfShadowsTalent = 451308,
    DeathspeakerTalent = 392507,
    DescendingDarknessTalent = 1242666,
    DevourMatterTalent = 451840,
    DistortedRealityTalent = 409044,
    EmpoweredSurgesTalent = 453799,
    EntropicRiftTalent = 447444,
    InescapableTormentTalent = 373427,
    InnerQuietusTalent = 448278,
    InsidiousIreTalent = 373212,
    MindDevourerTalent = 373202,
    MindMeltTalent = 391090,
    MindsEyeTalent = 407470,
    PerfectedFormTalent = 453917,
    PowerSurgeTalent = 453109,
    PsychicLinkTalent = 199484,
    VoidBlastTalent = 450405,
    VoidEmpowermentTalent = 450138,
    
    -- Buffs/Debuffs
    AscensionBuff = 391109,
    DevouringPlagueDebuff = 335467,
    EntropicRiftBuff = 449887, -- Actually the Void Heart buff since Entropic Rift doesn't have a buff.
    MindDevourerBuff = 373204,
    MindFlayInsanityBuff = 391401,
    PowerSurgeBuff = 453113,
    UnfurlingDarknessBuff = 341282,
    UnfurlingDarknessCdBuff = 341291,
    VampiricTouchDebuff = 34914,
    VoidformBuff = 194249,
    VoidVolleyBuff = 1242171,
}



aura_env.GetSpellCooldown = function(spellId)
    local spellCD = C_Spell.GetSpellCooldown(spellId)
    local spellCharges = C_Spell.GetSpellCharges(spellId)
    if spellCharges then
        local rechargeTime = (spellCharges.currentCharges < spellCharges.maxCharges) and (spellCharges.cooldownStartTime + spellCharges.cooldownDuration - GetTime()) or 0
        return spellCharges.currentCharges, rechargeTime, spellCharges.maxCharges
    elseif spellCD then
        local remainingCD = (spellCD.startTime and spellCD.duration) and math.max(spellCD.startTime + spellCD.duration - GetTime(), 0) or 0
        return 0, remainingCD, 0
    else
        return 0, 0, 0
    end
end

aura_env.GetSafeSpellIcon = function(spellId)
    if not spellId or spellId == 0 then
        return 0  
    end
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    return spellInfo and spellInfo.iconID or 0
end
