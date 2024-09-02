function(allstates, event, ...)
    -- 技能信息表
    local spells = {
        [49020] = {cost = {runicPower = -20, runes = 2}},  -- 湮灭
        [49143] = {cost = {runicPower = 30, runes = 0}},   -- 冰霜打击
        [49184] = {cost = {runicPower = -10, runes = 1}},  -- 凛风冲击
        [196770] = {cost = {runicPower = 0, runes = 0}},    -- 冷酷寒冬
        [43265] = {cost = {runicPower = -10, runes = 1}, charges = 2, cooldown = 30},  -- 枯萎凋零
    }
    
    --技能缓存
    local spellBookCache = {}
    local function cachedFindSpellBookSlotBySpellID(spellID)
        if spellBookCache[spellID] == nil then
            spellBookCache[spellID] = FindSpellBookSlotBySpellID(spellID)
        end
        return spellBookCache[spellID]
    end
    
    -- 获取玩家状态
    local function getPlayerState()
        local state = {
            runicPower = UnitPower("player", Enum.PowerType.RunicPower),
            runes = 0,
            maxRunes = 6,  
            hasPet = UnitExists("pet"),
            targetExists = UnitExists("target"),
            inCombat = UnitAffectingCombat("player"),
            buffs = {},
            debuffs = {},
            cooldowns = {},
            targetCount = 0,
        }
        
        for i = 1, 6 do
            if select(3, GetRuneCooldown(i)) then
                state.runes = state.runes + 1
            end
        end
        return state
    end
    
    -- 检查buff和CD
    local function checkBuffsAndCDs(state)
        local function checkAura(spellId, unit, auraType)
            local name, _, count, _, duration, expirationTime, source, _, _, id = AuraUtil.FindAuraByName(C_Spell.GetSpellInfo(spellId).name, unit, auraType)
            if id == spellId and (unit == "player" or source == "player") then
                return {
                    active = true,
                    count = count or 0,
                    remaining = expirationTime and (expirationTime - GetTime()) or 0
                }
            end
            return {
                active = false,
                count = 0,
                remaining = 0
            }
        end
        
        state.buffs[51124] = checkAura(51124, "player", "HELPFUL") -- 杀戮机器
        state.buffs[59052] = checkAura(59052, "player", "HELPFUL") -- 冰霜之镰
        state.buffs[188290] = checkAura(188290, "player", "HELPFUL") -- 枯萎凋零
        state.buffs[194879] = checkAura(194879, "player", "HELPFUL") -- 冰冷之爪
        state.debuffs[55095] = checkAura(55095, "target", "HARMFUL") -- 冰霜疫病
        state.debuffs[51714] = checkAura(51714, "target", "HARMFUL") -- 锋锐之霜
        
        -- 检查技能CD
        for spellId, spellInfo in pairs(spells) do
            local spellCD = C_Spell.GetSpellCooldown(spellId)
            state.cooldowns[spellId] = (spellCD.startTime + spellCD.duration) - GetTime()
        end
        
        -- 统计受到冰霜疫病影响的目标数量
        state.frostFeverTargets = 0
        local function countFrostFeverTargets()
            local count = 0
            for i = 1, 40 do
                local unit = "nameplate" .. i
                if UnitExists(unit) and UnitCanAttack("player", unit) then
                    if checkAura(55095, unit, "HARMFUL").active then
                        count = count + 1
                    end
                end
            end
            return count
        end
        state.frostFeverTargets = countFrostFeverTargets()
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
            if not cachedFindSpellBookSlotBySpellID(id) then
                return false
            end
            if (state.cooldowns[id] and state.cooldowns[id] > 1.5) then
                return false
            end
            if spells[id].cost.runicPower > 0 and state.runicPower < spells[id].cost.runicPower then
                return false
            end
            if spells[id].cost.runes > 0 and state.runes < spells[id].cost.runes then
                return false
            end
            return true
        end
        
        local priorityList = {
            {id = 49143, condition = function() 
                    return state.buffs[194879].active and state.buffs[194879].remaining < 3 and excludeSpell ~= 49143 end}, --冰打补BUFF
            {id = 49184, condition = function() 
                    return not state.debuffs[55095].active and excludeSpell ~= 49184 end},  -- 凛风冲击
            {id = 196770, condition = function() 
            return true end},  -- 冷酷寒冬
            {id = 43265, condition = function() 
                    return state.frostFeverTargets > 1 and not state.buffs[188290].active and excludeSpell ~= 43265 end},  -- 枯萎凋零
            {id = 49020, condition = function() 
                    return state.buffs[51124].count > 0  end},  -- 湮灭
            {id = 49143, condition = function() 
                    return state.debuffs[51714].count >= 5 end},  -- 冰霜打击
            {id = 49184, condition = function() 
                    return state.buffs[59052].active and excludeSpell ~= 49184 end},  -- 凛风冲击
            {id = 49020, condition = function() 
                    return state.buffs[51124].count == 1  end},  -- 湮灭
            -- {id = 49143, condition = function() 
            --     return state.runicPower >= 100 end},  -- 冰霜打击
            {id = 49020, condition = function() 
            return state.runes >= 5 end},  -- 湮灭
            {id = 49143, condition = function() 
            return true end},  -- 冰霜打击
            {id = 49020, condition = function()
            return true end},  -- 湮灭
            {id = 49184, condition = function()
            return true end},  -- 默认凛风冲击
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
    local firstCharges, firstCD, firstMaxCharges = getSpellCooldown(firstPriority)
    -- print(firstPriority)
    -- 更新状态
    if spells[firstPriority] then
        state.runicPower = math.max(state.runicPower - spells[firstPriority].cost.runicPower, 0)
        state.runes = math.max(state.runes - spells[firstPriority].cost.runes, 0)
        
        if firstPriority == 49184 then  -- 凛风冲击
            state.debuffs[55095].active = true
        elseif firstPriority == 196770 then  -- 冷酷寒冬
            state.cooldowns[196770] = 20  
        elseif firstPriority == 49020 then  -- 湮灭
            state.buffs[51124].count = math.max(state.buffs[51124].count - 1, 0)
        elseif firstPriority == 49143 and state.debuffs[51714].count >= 5 then  -- 冰霜打击
            state.debuffs[51714].count = 0
        elseif firstPriority == 43265 then  -- 枯萎凋零
            state.buffs[188290].active = true
        end
        
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

