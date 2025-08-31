WeakAuras.WatchGCD()
aura_env.showTime = 0
aura_env.showPercent = 100.0
aura_env.lastCast = 0
aura_env.wasteGCDTime = 0
aura_env.battleDuration = 0
aura_env.battleStartTime = 0
aura_env.playerInCombat = false
aura_env.stunInLastCast = false


-- CLEU:SPELL_CAST_SUCCESS PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED

-- 活跃度检测系统
local ActiveTimeTracker = {
    lastActiveTime = time(),
    isInCombat = false,
    isChanneling = false,
    channelStartTime = 0,
    totalChannelTime = 0,
    frame = CreateFrame("Frame")
}

-- 注册事件
ActiveTimeTracker.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ActiveTimeTracker.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
ActiveTimeTracker.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
ActiveTimeTracker.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
ActiveTimeTracker.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
ActiveTimeTracker.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
ActiveTimeTracker.frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

-- 设置事件处理函数
ActiveTimeTracker.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, _, _, _, _, spellID = ...
        if subEvent == "SPELL_CAST_SUCCESS" then
            ActiveTimeTracker:UpdateActiveTime()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        ActiveTimeTracker.isInCombat = true
        ActiveTimeTracker:UpdateActiveTime()
    elseif event == "PLAYER_REGEN_ENABLED" then
        ActiveTimeTracker.isInCombat = false
        ActiveTimeTracker:UpdateActiveTime()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, castID, spellID = ...
        if unit == "player" then
            ActiveTimeTracker.isChanneling = true
            ActiveTimeTracker.channelStartTime = time()
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit, castID, spellID = ...
        if unit == "player" and ActiveTimeTracker.isChanneling then
            ActiveTimeTracker.isChanneling = false
            local channelEndTime = time()
            local channelDuration = channelEndTime - ActiveTimeTracker.channelStartTime
            ActiveTimeTracker.totalChannelTime = ActiveTimeTracker.totalChannelTime + channelDuration
            ActiveTimeTracker:UpdateActiveTime()
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, spellID = ...
        if unit == "player" and ActiveTimeTracker.isChanneling then
            ActiveTimeTracker.isChanneling = false
            local channelEndTime = time()
            local channelDuration = channelEndTime - ActiveTimeTracker.channelStartTime
            ActiveTimeTracker.totalChannelTime = ActiveTimeTracker.totalChannelTime + channelDuration
            ActiveTimeTracker:UpdateActiveTime()
        end
    end
end)

-- 更新活跃时间
function ActiveTimeTracker:UpdateActiveTime()
    if not self.isChanneling then
        self.lastActiveTime = time()
    end
end

-- 获取实际活跃时间（排除引导时间）
function ActiveTimeTracker:GetTrueActiveTime()
    local currentTime = time()
    local elapsedTime = currentTime - self.lastActiveTime
    
    if self.isChanneling then
        local currentChannelTime = currentTime - self.channelStartTime
        elapsedTime = elapsedTime - currentChannelTime
    end
    
    return elapsedTime - self.totalChannelTime
end

-- 检查是否活跃（可自定义不活跃阈值）
function ActiveTimeTracker:CheckActiveStatus(inactivityThreshold)
    inactivityThreshold = inactivityThreshold or 300 -- 默认5分钟
    local trueActiveTime = self:GetTrueActiveTime()
    
    if trueActiveTime > inactivityThreshold then
        return false, trueActiveTime
    else
        return true, trueActiveTime
    end
end

-- 定期检查活跃状态（可选）
local checkInterval = 30 -- 30秒检查一次
C_Timer.NewTicker(checkInterval, function()
    local isActive, activeTime = ActiveTimeTracker:CheckActiveStatus()
    if not isActive then
        -- 这里可以添加不活跃时的处理，比如打印提示信息
        print("您已经 " .. math.floor(activeTime/60) .. " 分钟没有活跃操作了！")
    end
end)

-- 提供外部接口以便其他插件调用
function GetActiveTimeTracker()
    return ActiveTimeTracker
end