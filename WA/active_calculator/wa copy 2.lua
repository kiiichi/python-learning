
-- PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED CLEU:SPELL_CAST_SUCCESS UNIT_SPELLCAST_START UNIT_SPELLCAST_SUCCEEDED UNIT_SPELLCAST_CHANNEL_START UNIT_SPELLCAST_INTERRUPTED UNIT_SPELLCAST_STOP
     

PLAYER_REGEN_DISABLED
PLAYER_REGEN_ENABLED
UNIT_SPELLCAST_START
UNIT_SPELLCAST_CHANNEL_START
UNIT_SPELLCAST_SUCCEEDED
K_DOWNTIME_OVER




-- ====== 载入时初始化 ======
aura_env.showTime = 0
aura_env.showPercent = 100.0
aura_env.totalDowntime = 0
aura_env.playerInCombat = false
aura_env.battleStartTime = 0
aura_env.lastCast = 0

-- 通知 WeakAuras 开始统计空闲时间
aura_env.downtime_start = GetTime()
WeakAuras.ScanEvents("K_DOWNTIME_START")


-- ====== 主函数 ======
function(allstates, event, arg1, arg2, arg3, ...)
    local eventTime = GetTime()
    local newState

    -- ====== 战斗进入 ======
    if event == "PLAYER_REGEN_DISABLED" then
        if not aura_env.playerInCombat and UnitAffectingCombat("player") then
            aura_env.playerInCombat = true
            aura_env.showTime = 0
            aura_env.showPercent = 100.0
            aura_env.totalDowntime = 0
            aura_env.battleStartTime = eventTime
            aura_env.lastCast = eventTime
            print("[ENTER COMBAT] Reset showTime/showPercent:", aura_env.showTime, aura_env.showPercent)
        end
    end

    -- ====== 战斗退出 ======
    if event == "PLAYER_REGEN_ENABLED" then
        local env = aura_env
        C_Timer.After(3, function()
            if not UnitAffectingCombat("player") then
                env.playerInCombat = false
                env.totalDowntime = 0
                env.showTime = 0
                env.showPercent = 100.0
                env.lastCast = 0
                print("[LEAVE COMBAT] Reset showTime/showPercent:", env.showTime, env.showPercent)
            end
        end)
    end

    -- ====== 空闲时间结束事件 ======
    if event == "K_DOWNTIME_OVER" then
        local downtime = arg1
        newState = {
            downtime = floor(downtime * 1000),
            downtimeEndedAt = eventTime,
        }

        -- 累加总 downtime
        aura_env.totalDowntime = aura_env.totalDowntime + downtime

        -- 更新 showTime / showPercent
        if aura_env.playerInCombat then
            local battleDuration = eventTime - aura_env.battleStartTime
            aura_env.showTime = tonumber(string.format("%.2f", aura_env.totalDowntime))
            if battleDuration > 0 then
                aura_env.showPercent = tonumber(string.format("%.1f", (1 - aura_env.totalDowntime / battleDuration) * 100))
            else
                aura_env.showPercent = 100.0
            end
        end

        print("[K_DOWNTIME_OVER] showTime:", aura_env.showTime, "showPercent:", aura_env.showPercent)

    -- ====== 读条 / 引导施法开始 ======
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local downtimeEndedAt = allstates[""] and allstates[""].downtimeEndedAt or 0
        local gcd = C_Spell.GetSpellCooldown(61304)
        if gcd.startTime ~= downtimeEndedAt then
            newState = { downtime = 0 }  -- 暂停 downtime
        end
        aura_env.lastCast = eventTime
        print("[SPELLCAST_START] showTime:", aura_env.showTime, "showPercent:", aura_env.showPercent)

    -- ====== 瞬发施法成功 ======
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local downtimeEndedAt = allstates[""] and allstates[""].downtimeEndedAt or 0
        local spellId = arg3
        local spell = C_Spell.GetSpellInfo(spellId)
        local isInstantCast = spell.castTime == 0
        local gcd = C_Spell.GetSpellCooldown(61304)
        if isInstantCast and gcd.startTime ~= downtimeEndedAt then
            newState = { downtime = 0 }  -- 暂停 downtime
        end
        aura_env.lastCast = eventTime
        print("[SPELLCAST_SUCCEEDED] showTime:", aura_env.showTime, "showPercent:", aura_env.showPercent)

    else
        -- 初始化状态
        if not allstates[""] then
            newState = { downtime = 0 }
        end
    end

    -- ====== 更新状态 ======
    if newState then
        allstates:Update("", newState)
    end

    return true
end



{
    showTime = {
        type = "number",
        display = "Instant Downtime",
        total = "totalDowntime",
    },
    showPercent = {
        type = "number",
        display = "Total Downtime",
    },

}