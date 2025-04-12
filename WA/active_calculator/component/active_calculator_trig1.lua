env.test = function(event, _, subEvent, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellID)
    local FullGCD = 1
    local timestamp = 0
    local delta = 0
    local showTime = 0
    local showPercent = 100.0

    -- 进入战斗
    if event == "PLAYER_REGEN_DISABLED" then
        print("Entering Combat")
        if not aura_env.playerInCombat and UnitAffectingCombat("player") then
            print("Confirmed in Combat")
            aura_env.playerInCombat = true
            aura_env.showTime = 0
            aura_env.showPercent = 100.0
            aura_env.wasteGCDTime = 0  
            timestamp = GetTime()
            aura_env.battleStartTime = timestamp 
            aura_env.lastCast = timestamp
        end
    end

    if event == "PLAYER_REGEN_ENABLED" then
        print("Leaving Combat, checking again in 3s...")
        
        local env = aura_env -- 避免延迟执行时作用域丢失
        C_Timer.After(3, function()
            if not UnitAffectingCombat("player") then
                print("Confirmed out of Combat after 3s")
                env.playerInCombat = false
                env.wasteGCDTime = 0
                env.lastCast = 0
            else
                print("Still in combat after 3s, ignoring exit")
            end
        end)
    end

    -- 只处理玩家施放的法术
    if subEvent == "SPELL_CAST_SUCCESS" and sourceGUID ~= UnitGUID("player") then return true end

    -- 计算 GCD 利用率
    if subEvent == "SPELL_CAST_SUCCESS" and aura_env.playerInCombat then
        FullGCD = WeakAuras.gcdDuration()
        print("Full GCD: " .. FullGCD .. " seconds")
        timestamp = GetTime()
        aura_env.battleDuration = timestamp - aura_env.battleStartTime

        if aura_env.lastCast > 0 then
            delta = math.max(0, timestamp - aura_env.lastCast - FullGCD)
            if delta > 0 then
                aura_env.wasteGCDTime = aura_env.wasteGCDTime + delta
                print("Total Wasted: " .. aura_env.wasteGCDTime .. " seconds")
                print("Current Wasted: " .. delta .. " seconds")

                showTime = string.format("%.2f", aura_env.wasteGCDTime)
                if aura_env.battleDuration > 0 then
                    showPercent = string.format("%.2f", (1 - aura_env.wasteGCDTime / aura_env.battleDuration) * 100)
                else
                    showPercent = "100.00"
                end
                aura_env.showTime = showTime
                aura_env.showPercent = showPercent
            else 
                print("Save time: " .. delta .. " seconds")
            end
        end
        aura_env.lastCast = timestamp
    end

    return true
end