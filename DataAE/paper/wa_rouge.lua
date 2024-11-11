function(allstates, event, ...)
    -- 技能信息表
    local spells = {
        [2823] = {name = "夺命药膏", cost = {energy = 0, comboPoints = 0}},
        [1784] = {name = "潜行", cost = {energy = 0, comboPoints = 0}},
        [703] = {name = "锁喉", cost = {energy = 45, comboPoints = -1}, cooldown = 6},
        [1943] = {name = "割裂", cost = {energy = 24, comboPoints = 1}},
        [32645] = {name = "毒伤", cost = {energy = 33, comboPoints = 6}},
        [121411] = {name = "猩红风暴", cost = {energy = 42, comboPoints = 6}},
        [315496] = {name = "切割", cost = {energy = 22, comboPoints = 6}},      
        [1329] = {name = "毁伤", cost = {energy = 50, comboPoints = -2}},
        [385616] = {name = "申斥回响", cost = {energy = 10, comboPoints = -2}, cooldown = 45},
        [8676] = {name = "伏击", cost = {energy = 0, comboPoints = -2}},
        [51723] = {name = "刀扇", cost = {energy = 35, comboPoints = -1}},
        [1856] = {name = "消失", cost = {energy = 0, comboPoints = 0}, cooldown = 120},
        [360194] = {name = "死亡印记", cost = {energy = 0, comboPoints = 0}, cooldown = 120},
        [5938] = {name = "毒刃", cost = {energy = 30, comboPoints = -1}, cooldown = 30},
        [385627] = {name = "君王之灾", cost = {energy = 0, comboPoints = 0}, cooldown = 60},
        [381623] = {name = "菊花茶", cost = {energy = -100, comboPoints = 0}, cooldown = 60},
    }
    
    -- 获取玩家状态
    local function getPlayerState()
        return {
            energy = UnitPower("player", Enum.PowerType.Energy),
            comboPoints = UnitPower("player", Enum.PowerType.ComboPoints),
            maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints),
            targetHealth = UnitHealth("target"),
            inCombat = UnitAffectingCombat("player"),
            buffs = {},
            debuffs = {},
            cooldowns = {},
            aoeTargets = 0,
            animaCharged = false,
            improvedGarrote = false,
        }
    end
    
    -- 检查buff和CD
    local function checkBuffsAndCDs(state)
        local function checkAura(spellId, unit, auraType)
            local name, _, count, _, duration, expirationTime, source, _, _, id = AuraUtil.FindAuraByName(C_Spell.GetSpellInfo(spellId).name, unit, auraType)
            if id == spellId and (unit == "player" or source == "player") then
                return {active = true, count = count or 0, remaining = expirationTime and (expirationTime - GetTime()) or 0}
            end
            return {active = false, count = 0, remaining = 0}
        end
        
        local buffIds = 
        {
            2823, --涂药
            1784,  --潜行
            115191,
            11327, --消失
            315496,  -- 切割
            392401, --强化锁喉2
            392403, --强化锁候1
            32645, --毒伤
            381623, --菊花茶
            394080, --血之气息
            457178, --见者灭尽
            323559, --申斥回响3
            323560, --申斥回响4
            354838, --申斥回响5
            457280, --至黑之夜
            394095, --君王之灾
            455366, --锯齿骨刺
        }
        local debuffIds = 
        {
            703, -- 锁喉
            1943, -- 割裂
            121411, --猩红风暴
            360194, -- 死亡标记
            385627, --君王之灾
            319504, --毒刃
            394036, --锯齿骨刺
        }
        
        for _, id in ipairs(buffIds) do
            state.buffs[id] = checkAura(id, "player", "HELPFUL")
        end
        
        for _, id in ipairs(debuffIds) do
            state.debuffs[id] = checkAura(id, "target", "HARMFUL")
        end
        
        -- 检查技能CD
        for spellId, spellInfo in pairs(spells) do
            local spellCD = C_Spell.GetSpellCooldown(spellId)
            state.cooldowns[spellId] = (spellCD.startTime + spellCD.duration) - GetTime()
        end
        
        
        -- 申斥充能状态
        local function checkAnimaCharged()
            local buffs = {}
            local i = 1
            while true do
                local auraData = C_UnitAuras.GetAuraDataByIndex("player", i)
                if not auraData then break end
                if auraData.spellId == 323559 or auraData.spellId == 323560 or auraData.spellId == 354838 then
                    if auraData.applications == state.comboPoints then return true end
                end
                i = i + 1
            end
            return false
        end
        state.animaCharged = checkAnimaCharged()
        --强化锁候状态
        state.improvedGarrote = state.buffs[392403].active or state.buffs[392401].active
        
        -- -- 统计受到锁喉或者割裂影响的目标数量
        -- state.aoeTargets = 0
        -- for i = 1, 40 do
        --     local unit = "nameplate" .. i
        --     if UnitExists(unit) and UnitCanAttack("player", unit) then
        --         local lockthroatDebuff = checkAura(703, unit, "HARMFUL")
        --         local ruptureDebuff = checkAura(1943, unit, "HARMFUL")
        --         if lockthroatDebuff.active or ruptureDebuff.active then
        --             state.aoeTargets = state.aoeTargets + 1
        --         end
        --     end
        -- end
        
        --附近敌人数量
        local function getNearbyEnemiesCount()
            local count = 0
            for i = 1, 40 do
                local unit = "nameplate" .. i
                if UnitExists(unit) and UnitCanAttack("player", unit) then
                    local inRange = CheckInteractDistance(unit, 3)  -- 3 代表 10 码范围
                    if inRange then
                        count = count + 1
                    end
                end
            end
            return count
        end
        state.aoeTargets = getNearbyEnemiesCount()
    end
    
    -- 获取技能冷却信息
    local function getSpellCooldown(spellId)
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
    
    -- 优先级判断函数
    local function getPriority(state, excludeSpell)
        local function canUseSpell(id)
            local spellInfo = spells[id]
            -- if not IsSpellKnown(id) then
            --     return false
            -- end
            if (state.cooldowns[id] and state.cooldowns[id] > 1) then
                return false
            end
            -- if spellInfo.cost.energy and state.energy < spellInfo.cost.energy then
            --     return false
            -- end
            if spellInfo.cost.comboPoints > 0 and state.comboPoints < 1 then
                return false
            end
            return true
        end
        
        local priorityList = {
            {id = 1784, condition = function() -- 潜行
                    return not state.inCombat and excludeSpell ~= 1784
                    and not (state.buffs[1784].active or state.buffs[11327].active or state.buffs[115191].active)
            end},
            {id = 2823, condition = function() -- 涂药
                    return state.buffs[2823].remaining < 300 and excludeSpell ~= 2823
            end},
            {id = 381623, condition = function() -- 菊花茶
                    return not state.buffs[381623].active 
                    and state.debuffs[385627].active 
                    and state.debuffs[385627].remaining < 6 
                    and excludeSpell ~= 381623
            end},
            {id = 8676, condition = function() -- 伏击
                    return state.buffs[1784].active and not state.buffs[457280].active and excludeSpell ~= 8676
            end},
            {id = 1943, condition = function() -- 4目标补割裂
                    return state.comboPoints > 4 
                    and not state.debuffs[385627].active
                    and (state.improvedGarrote and state.debuffs[1943].remaining < 35)
                    and  (state.aoeTargets > 3 and state.buffs[394080].count < 16)
            end},
            {id = 1943, condition = function() -- 割裂
                    return state.comboPoints > 4 and state.debuffs[1943].remaining < 3 and excludeSpell ~= 1943
            end},
            {id = 703, condition = function() -- 补强化锁喉
                    return state.improvedGarrote 
                    and state.buffs[392401].remaining < 2
                    and state.debuffs[703].remaining < 18
                    and excludeSpell ~= 703 
            end},
            {id = 703, condition = function() -- 4目标强化锁喉
                    return state.aoeTargets > 3 and state.improvedGarrote and state.comboPoints < 5
            end},
            {id = 121411, condition = function() -- 猩红风暴
                    return state.aoeTargets > 1 and state.debuffs[121411].remaining < 8 and (state.comboPoints > 5 or state.animaCharged)
            end},
            {id = 315496, condition = function() -- 切割
                    return state.comboPoints > 4 and state.buffs[315496].remaining < 3 and excludeSpell ~= 315496
            end},
            {id = 32645, condition = function() -- 毒伤
                    return (state.buffs[32645].remaining < 3 or state.debuffs[385627].active) and (state.comboPoints > 4 or state.animaCharged)
            end},
            {id = 703, condition = function() -- 锁候
                    return state.debuffs[703].remaining < 3 and excludeSpell ~= 703
            end},
            {id = 385616, condition = function() -- 申斥回响
                    return state.comboPoints < 6 and excludeSpell ~= 385616
            end},
            {id = 360194, condition = function() -- 死亡印记
                    return not state.buffs[392401].active
                    and excludeSpell ~= 360194
                    and canUseSpell(385627)
                    and state.targetHealth > 50000000  -- 只在目标血量大于5000W时使用
            end},
            {id = 5938, condition = function() -- 毒刃
                    return not state.buffs[392401].active
                    and not state.debuffs[319504].active 
                    and canUseSpell(385627) 
                    and excludeSpell ~= 5938
            end},
            {id = 385627, condition = function() -- 君王之灾
                    return not state.buffs[392401].active and excludeSpell ~= 385627
            end},
            {id = 5938, condition = function() -- 毒刃
                    return not state.debuffs[319504].active 
                    and state.buffs[394095].active and state.buffs[394095].remaining < 9
                    and excludeSpell ~= 5938
            end},
            {id = 51723, condition = function() -- 3目标刀扇
                    return state.aoeTargets > 2 and state.comboPoints < 5 and not state.animaCharged
            end},
            {id = 51723, condition = function() -- 刀扇
                    return state.comboPoints < 5 and not state.animaCharged and state.buffs[457178].active and excludeSpell ~= 51723
            end},
            {id = 1329, condition = function() -- 毁伤
                    return state.comboPoints < 5 and not state.animaCharged
            end},
            -- {id = 1943, condition = function() -- 4目标补割裂
            --     return state.comboPoints > 5 and state.debuffs[1943].remaining < 12 and excludeSpell ~= 1943
            -- end},
        }
        
        for _, spell in ipairs(priorityList) do
            if canUseSpell(spell.id) and spell.condition() then
                return spell.id
            end
        end
        
        return 0
    end
    
    -- 主逻辑
    local state = getPlayerState()
    
    checkBuffsAndCDs(state)
    
    local firstPriority = getPriority(state)
    -- print(firstPriority)
    local firstCharges, firstCD, firstMaxCharges = getSpellCooldown(firstPriority)
    
    -- 更新状态
    if spells[firstPriority] then
        local spellInfo = spells[firstPriority]
        state.energy = math.max(state.energy - spellInfo.cost.energy, 0)
        --强化锁候
        local costCP = spellInfo.cost.comboPoints
        if firstPriority == 703 and state.improvedGarrote then
            costCP = -3
        end
        state.comboPoints = math.min(math.max(state.comboPoints - costCP, 0), state.maxComboPoints)
        state.animaCharged = false
        
        --锯齿骨刺
        if firstPriority == 1943 and state.buffs[455366].active then
            state.comboPoints = math.min(state.aoeTargets * 3, 6)
        end
        -- print(state.comboPoints)
        -- 减少所有 BUFF 和 DOT 的持续时间 1s 秒
        for _, buff in pairs(state.buffs) do
            buff.remaining = math.max(buff.remaining - 1, 0)
        end
        for _, debuff in pairs(state.debuffs) do
            debuff.remaining = math.max(debuff.remaining - 1, 0)
            debuff.active = debuff.remaining > 0
        end
    end
    
    local secondPriority = getPriority(state, firstPriority)
    local secondCharges, secondCD, secondMaxCharges = getSpellCooldown(secondPriority)
    -- print(secondPriority)
    
    -- 辅助函数：安全地获取法术图标
    local function getSafeSpellIcon(spellId)
        if not spellId or spellId == 0 then
            return 0  
        end
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        return spellInfo and spellInfo.iconID or 0
    end
    
    -- 更新 allstates
    allstates[1] = {
        show = true,
        changed = true,
        icon = getSafeSpellIcon(firstPriority),
        spell = firstPriority,
        cooldown = firstCD,
        charges = firstCharges,
        maxCharges = firstMaxCharges
    }
    
    allstates[2] = {
        show = secondPriority ~= 0,
        changed = true,
        icon = getSafeSpellIcon(secondPriority), 
        spell = secondPriority,
        cooldown = secondCD,
        charges = secondCharges,
        maxCharges = secondMaxCharges
    }
    
    return true
end

