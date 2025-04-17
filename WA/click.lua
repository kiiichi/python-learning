----------------------
---- Spell 1 Load ----
----------------------
local e = aura_env
local lyr = 1
local name = "超级加速器"
local cvr = CreateFrame("Frame")
local p,rt,rp,x,y = e.region:GetPoint()
local w,h = e.region:GetSize()
cvr:EnableMouse(true)
cvr:SetPropagateMouseClicks(false)
cvr:SetPassThroughButtons("RightButton")
cvr:SetFrameLevel(lyr*2+1)
cvr:SetPoint(p,rt,rp, 0, 0)
cvr:SetSize(w,h)
cvr:SetScript('OnUpdate', function()
        local tmp = g_spellBitMask
        p,rt,rp,x,y = e.region:GetPoint()      
        if(y < 1) then
            tmp = bit.bor(bit.lshift(1,lyr), tmp)
        else
            tmp = bit.band(bit.bnot(bit.lshift(1,lyr)), tmp)
        end
        if(tmp == g_spellBitMask) then
            --return
        else
            g_spellBitMask = tmp
        end
        
        for i=1,lyr,1 do
            tmp = bit.rshift(tmp,1)
            if (bit.band(tmp,1) == 1) then 
                if(i <= lyr) then
                    cvr:SetSize(0, 0)
                    return
                end
            end
        end
        cvr:SetSize(w,h)
end)


----------------------
---- Spell 2 Load ----
----------------------
local e = aura_env
local lyr = 2
local name = "狂暴"
local cvr = CreateFrame("Frame")
local p,rt,rp,x,y = e.region:GetPoint()
local w,h = e.region:GetSize()
cvr:EnableMouse(true)
cvr:SetPropagateMouseClicks(false)
cvr:SetPassThroughButtons("RightButton")
cvr:SetFrameLevel(lyr*2+1)
cvr:SetPoint(p,rt,rp, 0, 0)
cvr:SetSize(w,h)
cvr:SetScript('OnUpdate', function()
        local tmp = g_spellBitMask
        p,rt,rp,x,y = e.region:GetPoint()      
        if(y < 1) then
            tmp = bit.bor(bit.lshift(1,lyr), tmp)
        else
            tmp = bit.band(bit.bnot(bit.lshift(1,lyr)), tmp)
        end
        if(tmp == g_spellBitMask) then
            --return
        else
            g_spellBitMask = tmp
        end
        
        for i=1,lyr,1 do
            tmp = bit.rshift(tmp,1)
            if (bit.band(tmp,1) == 1) then 
                if(i <= lyr) then
                    cvr:SetSize(0, 0)
                    return
                end
            end
        end
        cvr:SetSize(w,h)
end)


-------------------------
---- Spell 隔离 Load ----
-------------------------
g_spellBitMask = 0
g_enableKeyboard = false
g_bindingKey = 'F6'
if (not (aura_env.config.bindingKey == nil)) and (aura_env.config.enableKeyboard) then
    g_enableKeyboard = true
    g_bindingKey = aura_env.config.bindingKey 
    --print("启用按键绑定:"..g_bindingKey)
else
    g_enableKeyboard = false
end

local spellnamelist = {
    "超级加速器",--1
    "狂暴",--2
    "精灵之火（野性）",--3
    "割裂",--4
    "野蛮咆哮",--5
    "裂伤（豹）",--6 
    "猛虎之怒",--7
    "斜掠",--8
    "横扫（豹）",--9
    "凶猛撕咬",--10
    "撕碎",--11
    "攻击",--12
}

_ManagerFrame = CreateFrame("Frame", "SafeBtnManager", UIParent, "SecureHandlerStateTemplate")
_ManagerFrame.Execute = SecureHandlerExecute
_ManagerFrame.WrapScript = function(self, frame, script, preBody, postBody) return SecureHandlerWrapScript(frame, script, self, preBody, postBody) end
_ManagerFrame.SetFrameRef = SecureHandlerSetFrameRef
_ManagerFrame:SetAttribute("BindingKey", g_bindingKey)
_ManagerFrame:Execute([[
    Manager = self
    BindLyr = nil
    --GhostBtns = newtable()
    ResetLyr = nil
    CheckLyrs = newtable()
    deepest = 12
    lastdeepest = 100
    spellName = "攻击"
    bindingKey = self:GetAttribute("BindingKey")

    onBindLyrClick = [==[
        if (lastdeepest == deepest) then
            return
        end
        if (deepest > 1) and (deepest <12) then
            if (deepest == 11) then
                spellName = "撕碎"
            elseif (deepest == 10) then
                spellName = "凶猛撕咬"
            elseif (deepest == 9) then
                spellName = "横扫（豹）"
            elseif (deepest == 8) then
                spellName = "斜掠"
            elseif (deepest == 7) then
                spellName = "猛虎之怒"
            elseif (deepest == 6) then
                spellName = "裂伤（豹）"
            elseif (deepest == 5) then
                spellName = "野蛮咆哮"
            elseif (deepest == 4) then
                spellName = "割裂"
            elseif (deepest == 3) then
                spellName = "精灵之火（野性）"
            elseif (deepest == 2) then
                spellName = "狂暴"
            end
            BindLyr:SetAttribute("type", "spell")
            BindLyr:SetAttribute("spell", spellName)
        elseif (deepest ==1) then
            BindLyr:SetAttribute("type", "item")
            spellName = "10"
            BindLyr:SetAttribute("item", spellName)
        elseif(deepest == 12) then
            BindLyr:SetAttribute("type", "macro")
            spellName = "/startattack"
            BindLyr:SetAttribute("macrotext", spellName)
        else
            --print("error")
        end
        if(deepest <= 12) then
            lastdeepest = deepest
            --print("Bind: ",spellName,deepest)
        end
    ]==]
        
    onResetLyrClick = [==[
        if (deepest <= 12) then
            deepest = 100
            --BindLyr:SetAttribute("type", "macro")
            --BindLyr:SetAttribute("macrotext", "/startattack")
        end
    ]==]
        
    onCheckLyrClick = [==[
        local index = ...
        local chk =  CheckLyrs[index]
        if(deepest > index) then
            deepest = index
        end
        --print("onCheckLyrClick: "..chk:GetName().." deepest=",deepest)
    ]==]

]])

local p, rt, rp, x, y = aura_env.region:GetPoint()
local w,h = aura_env.region:GetSize()

for i, spellname in ipairs(spellnamelist) do
    local chk = CreateFrame("Button", "CheckLyr".. i, UIParent, "SecureActionButtonTemplate")
    _ManagerFrame:SetFrameRef("CheckLyr", chk)
    chk:RegisterForClicks("AnyDown")
    chk:SetPropagateMouseClicks(true)
    chk:SetPassThroughButtons("RightButton")
    chk:SetFrameLevel(i*2)
    chk:SetPoint(p, rt, rp, 0, 0)
    chk:SetSize(w,h)
    
    _ManagerFrame:Execute(string.format([[
        local index = %d
        local chk = Manager:GetFrameRef("CheckLyr")
        CheckLyrs[index] = chk
    ]], i))
    
    _ManagerFrame:WrapScript(chk, "OnClick", string.format([[Manager:Run(onCheckLyrClick, %d)]],i))
    
end

local bndlyr = CreateFrame("Button", "BndLyr", UIParent, "SecureActionButtonTemplate")
_ManagerFrame:SetFrameRef("BindLyr", bndlyr)
bndlyr:RegisterForClicks("AnyUp")
bndlyr:SetPropagateMouseClicks(true)
bndlyr:SetPassThroughButtons("RightButton")
bndlyr:SetFrameLevel(200)
bndlyr:SetPoint(p, rt, rp, 0, 0)
bndlyr:SetSize(w,h)
_ManagerFrame:Execute([[
    local bndlyr = Manager:GetFrameRef("BindLyr")
    BindLyr = bndlyr
]])
_ManagerFrame:WrapScript(bndlyr, "OnClick", [[Manager:Run(onBindLyrClick)]])


local rstlyr = CreateFrame("Button", "RstLyr", UIParent, "SecureActionButtonTemplate")
_ManagerFrame:SetFrameRef("RstLyr", rstlyr)
rstlyr:RegisterForClicks("AnyDown")
rstlyr:SetPropagateMouseClicks(true)
rstlyr:SetPassThroughButtons("RightButton")
rstlyr:SetFrameLevel(100)
rstlyr:SetPoint(p, rt, rp, 0, 0)
rstlyr:SetSize(w,h)
_ManagerFrame:Execute([[
    local rstlyr = Manager:GetFrameRef("RstLyr")
    ResetLyr = rstlyr
]])
_ManagerFrame:WrapScript(rstlyr, "OnClick", [[Manager:Run(onResetLyrClick)]])


local btmbtn = CreateFrame("Button", "BmBtn", UIParent, "SecureActionButtonTemplate")
btmbtn:RegisterForClicks("AnyDown")
btmbtn:SetPropagateMouseClicks(false)
btmbtn:SetPassThroughButtons("RightButton")
btmbtn:SetFrameLevel(1)
btmbtn:SetPoint(p, rt, rp, 0, 0)
btmbtn:SetSize(w,h)
btmbtn:SetAttribute("type", "macro")
btmbtn:SetAttribute("macrotext", "/startattack")




