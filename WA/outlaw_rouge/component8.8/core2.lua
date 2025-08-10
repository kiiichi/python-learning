env.test = function(_, _, _, _, sourceGUID, _, _, _, _, _, _, _, spellId, ...)
    if sourceGUID == UnitGUID("PLAYER") then
        if spellId == aura_env.ids.RollTheBones then
            -- Initial prediction
            local Expires = GetTime() + 30
            if aura_env.RTBContainerExpires and aura_env.RTBContainerExpires > GetTime() then
                local Offset = math.min(aura_env.RTBContainerExpires - GetTime(), 9)
                aura_env.RTBContainerExpires = Expires + Offset
            else
                aura_env.RTBContainerExpires = Expires
            end
        elseif spellId == aura_env.ids.KillingSpree and IsPlayerSpell(aura_env.ids.DisorientingStrikesTalent) then
            aura_env.DisorientingStrikesCount = 2
        elseif spellId == aura_env.ids.SinisterStrike or spellId == aura_env.ids.Ambush then
            aura_env.DisorientingStrikesCount = max(aura_env.DisorientingStrikesCount - 1, 0)
        elseif spellId == aura_env.ids.CoupDeGrace and GetTime() - aura_env.PrevCoupCast > 5 and WeakAuras.GetNumSetItemsEquipped(1928) and aura_env.IsPlayerSpell(ids.CoupDeGraceTalent) then
            aura_env.HasTww34PcTricksterBuff = true
        elseif spellId == aura_env.ids.CoupDeGrace then
            aura_env.HasTww34PcTricksterBuff = false
            aura_env.PrevCoupCast = GetTime()
        end
        
        if spellId == aura_env.ids.KillingSpree then
            aura_env.LastKillingSpree = GetTime()
        end
    end
end
