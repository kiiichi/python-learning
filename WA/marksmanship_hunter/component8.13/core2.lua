env.test = function(event, timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID)
    if sourceGUID ~= UnitGUID("player") then return false end
    aura_env.PrevCast = spellID
    aura_env.PrevCastTime = GetTime()
    return
end