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
        -- Kichi fix for NG mistake
        elseif spellId == aura_env.ids.CoupDeGrace and (aura_env.PrevCoupCast == 0 or GetTime() - aura_env.PrevCoupCast > 5) and WeakAuras.GetNumSetItemsEquipped(1928)>=4 and IsPlayerSpell(aura_env.ids.CoupDeGraceTalent) then
            aura_env.HasTww34PcTricksterBuff = true
            aura_env.PrevCoupCast = GetTime()
        elseif spellId == aura_env.ids.CoupDeGrace then
            aura_env.HasTww34PcTricksterBuff = false
            aura_env.PrevCoupCast = GetTime()
        end
    
        if spellId == aura_env.ids.KillingSpree then
            aura_env.LastKillingSpree = GetTime()
        end

        -- Kichi add
        if spellId == aura_env.ids.CoupDeGrace then
            aura_env.LastCoupDeGrace = GetTime()
        end
        if GetTime() - aura_env.PrevCoupCast > 5 then
            aura_env.HasTww34PcTricksterBuff = false
        end
    
    end
end
