--[[
  Anonymous9x TSB Strong  v6.0
  The Strongest Battlegrounds
  By Anonymous9x
  ──────────────────────────────────────────
  CURSOR BUG ROOT CAUSE & FIX:
    TextButton on Delta mobile triggers text
    input mode → shows | cursor.
    Fix: ALL clickable elements use ImageButton
    instead of TextButton. ImageButton NEVER
    shows a text cursor under any executor.

  DRAG ROOT CAUSE & FIX:
    Frame.InputBegan is unreliable on Delta
    mobile. Fix: use global UIS.InputBegan
    and check coords against header bounds.

  STATUS BAR:
    FPS + Ping rendered INSIDE panel header,
    not outside.
]]

-- ═════════════════════════════════════════
-- SERVICES
-- ═════════════════════════════════════════
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local SG      = game:GetService("StarterGui")
local LP      = Players.LocalPlayer
local Cam     = workspace.CurrentCamera

-- ═════════════════════════════════════════
-- CHARACTER
-- ═════════════════════════════════════════
local char, hum, hrp
local function linkChar(c)
    char = c
    hum  = c:WaitForChild("Humanoid", 10)
    hrp  = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then linkChar(LP.Character) end
LP.CharacterAdded:Connect(linkChar)

-- ═════════════════════════════════════════
-- TSB ATTRIBUTES
-- ═════════════════════════════════════════
local function initTSB()
    pcall(function()
        workspace:SetAttribute("VIPServer",      tostring(LP.UserId))
        workspace:SetAttribute("VIPServerOwner", LP.Name)
        if LP:GetAttribute("ExtraSlots")          == nil then LP:SetAttribute("ExtraSlots",        false) end
        if LP:GetAttribute("EmoteSearchBar")      == nil then LP:SetAttribute("EmoteSearchBar",    false) end
        if workspace:GetAttribute("NoDashCooldown") == nil then workspace:SetAttribute("NoDashCooldown", false) end
        if workspace:GetAttribute("NoFatigue")      == nil then workspace:SetAttribute("NoFatigue",      false) end
    end)
end
initTSB()

-- ═════════════════════════════════════════
-- STATE
-- ═════════════════════════════════════════
local S = {
    followOn=false, soloHacker=false, dragHold=false,
    camLock=false, antiVoid=false,
    mode="HEAD", dist=3, speed=20, camDist=12, target=nil,
    speedOn=false, speedVal=1.5,
    jumpOn=false, jumpVal=50,
    ws=16, wsOn=false,
    tapOn=false, tapDelay=0.2, tapSkill="Pukulan Biasa",
    noDash=false, noFatigue=false, extraSlots=false, emoteSearch=false,
}
local orbit = 0
local tapAlive = false

-- ═════════════════════════════════════════
-- HELPERS
-- ═════════════════════════════════════════
local function getHRP()
    if not S.target then return nil end
    local c = S.target.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHead()
    if not S.target then return nil end
    local c = S.target.Character
    return c and c:FindFirstChild("Head")
end
local function allEnemies()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then t[#t+1] = {p=p, hrp=h} end
        end
    end
    return t
end
local function pNames()
    local n = {"None"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then n[#n+1] = p.Name end
    end
    return n
end

-- ═════════════════════════════════════════
-- AUTO TAP
-- ═════════════════════════════════════════
local SKILL_MAP = {
    ["Pukulan Biasa"]     = {"Pukulan Biasa","Basic Attack","Attack"},
    ["Pukulan Berurutan"] = {"Pukulan Berurutan","Combo","Jab"},
    ["Dorong"]            = {"Dorong","Push"},
    ["Uppercut"]          = {"Uppercut","Upper"},
}
local function tapLoop()
    while tapAlive do
        if S.tapOn and S.target and char and hrp then
            local texts = SKILL_MAP[S.tapSkill] or {S.tapSkill}
            for _, g in ipairs(LP.PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Enabled then
                    for _, b in ipairs(g:GetDescendants()) do
                        if b:IsA("TextButton") and b.Visible then
                            local t = (b.Text or ""):match("^%s*(.-)%s*$") or ""
                            for _, pat in ipairs(texts) do
                                if t:find(pat, 1, true) then
                                    pcall(function() b.MouseButton1Click:Fire() end)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(S.tapDelay)
    end
end

-- ═════════════════════════════════════════
-- COMBAT ENGINE
-- ═════════════════════════════════════════
RS.Heartbeat:Connect(function(dt)
    if not hrp or not char then return end
    if S.speedOn and hum then
        local d = hum.MoveDirection
        if d.Magnitude > 0 then
            pcall(function() hrp.CFrame = hrp.CFrame + d * S.speedVal end)
        end
    end
    if S.wsOn and hum then
        pcall(function() if hum.WalkSpeed ~= S.ws then hum.WalkSpeed = S.ws end end)
    end
    if S.jumpOn and hum then
        pcall(function() hum.JumpHeight = S.jumpVal end)
    end
    if S.antiVoid and hrp.Position.Y < -250 then
        pcall(function() hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z) end)
    end
    local targets = S.soloHacker and allEnemies() or (function()
        if S.followOn and S.target then
            local th = getHRP()
            if th then return {{p=S.target, hrp=th}} end
        end
        return {}
    end)()
    if #targets > 0 then
        local th   = targets[1].hrp
        local tPos = th.Position
        local dist = S.dist
        local cf   = nil
        if S.mode == "ORBIT" then
            orbit = orbit + dt * S.speed * 0.12
            cf = CFrame.lookAt(
                Vector3.new(tPos.X + math.cos(orbit)*dist, tPos.Y, tPos.Z + math.sin(orbit)*dist),
                tPos)
        elseif S.mode == "HEAD" then
            local head  = getHead()
            local hy    = head and head.Position.Y or tPos.Y + 2.5
            local look  = th.CFrame.LookVector
            cf = CFrame.lookAt(Vector3.new(tPos.X, hy, tPos.Z) + look*dist,
                               Vector3.new(tPos.X, hy, tPos.Z))
        elseif S.mode == "FEET" then
            local look = th.CFrame.LookVector
            local fy   = tPos.Y - 2.5
            cf = CFrame.lookAt(
                Vector3.new(tPos.X + look.X*dist, fy, tPos.Z + look.Z*dist),
                Vector3.new(tPos.X, fy, tPos.Z))
        end
        if cf then pcall(function() hrp.CFrame = cf end) end
        if S.dragHold then
            for _, en in ipairs(targets) do
                pcall(function()
                    en.hrp.CFrame = CFrame.new(hrp.Position +
                        Vector3.new(math.random(-1,1)*0.4, 0.2, math.random(-1,1)*0.4))
                end)
            end
        end
    end
    if S.camLock and S.target then
        local lk = getHead() or getHRP()
        if lk then
            pcall(function()
                Cam.CameraType = Enum.CameraType.Scriptable
                Cam.CFrame     = CFrame.lookAt(Cam.CFrame.Position, lk.Position)
            end)
        end
    end
end)

-- ═════════════════════════════════════════
-- DESTROY OLD GUI
-- ═════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("_A9TSB6"):Destroy() end)

-- ═════════════════════════════════════════
-- ROOT
-- ═════════════════════════════════════════
local root = Instance.new("ScreenGui")
root.Name           = "_A9TSB6"
root.DisplayOrder   = 999
root.ResetOnSpawn   = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset = true
pcall(function() root.Parent = game.CoreGui end)
if not root.Parent then root.Parent = LP.PlayerGui end

-- ═════════════════════════════════════════
-- COLOUR PALETTE  (black / grey / white only)
-- ═════════════════════════════════════════
local C = {
    win     = Color3.fromRGB(15, 15, 18),
    header  = Color3.fromRGB(10, 10, 13),
    sidebar = Color3.fromRGB(13, 13, 16),
    content = Color3.fromRGB(17, 17, 21),
    card    = Color3.fromRGB(22, 22, 27),
    cardH   = Color3.fromRGB(28, 28, 34),
    sep     = Color3.fromRGB(30, 30, 38),
    border  = Color3.fromRGB(38, 38, 50),
    borderH = Color3.fromRGB(58, 58, 76),
    trkBg   = Color3.fromRGB(32, 32, 40),
    trkFill = Color3.fromRGB(175,175,188),
    tOn     = Color3.fromRGB(175,175,188),
    tOff    = Color3.fromRGB(38, 38, 50),
    white   = Color3.new(1,1,1),
    pri     = Color3.fromRGB(220,220,226),
    sec     = Color3.fromRGB(115,115,130),
    dim     = Color3.fromRGB(70,  70, 85),
    secLbl  = Color3.fromRGB(130,130,145),
}

-- ═════════════════════════════════════════
-- DIMENSIONS
-- ═════════════════════════════════════════
local W  = 454   -- window width
local H  = 372   -- window height
local SW = 112   -- sidebar width
local HDR = 38   -- header height
local STH = 20   -- status strip height

-- ═════════════════════════════════════════
-- WINDOW
-- ═════════════════════════════════════════
local vp = Cam.ViewportSize
if vp.X < 10 then task.wait(0.1); vp = Cam.ViewportSize end

local win = Instance.new("Frame")
win.Name               = "Win"
win.Size               = UDim2.fromOffset(W, H)
win.Position           = UDim2.fromOffset(
    math.max(4, math.floor((vp.X - W)/2)),
    math.max(4, math.floor((vp.Y - H)/3)))
win.BackgroundColor3   = C.win
win.BackgroundTransparency = 0
win.BorderSizePixel    = 0
win.ClipsDescendants   = false
win.ZIndex             = 10
win.Parent             = root
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 7)
local winS = Instance.new("UIStroke", win)
winS.Color = C.border; winS.Thickness = 1

-- ═════════════════════════════════════════
-- HEADER
-- ═════════════════════════════════════════
local header = Instance.new("Frame")
header.Name             = "Header"
header.Size             = UDim2.new(1, 0, 0, HDR)
header.BackgroundColor3 = C.header
header.BackgroundTransparency = 0
header.BorderSizePixel  = 0
header.ZIndex           = 11
header.Parent           = win
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 7)

-- patch bottom corners of header
local hPatch = Instance.new("Frame")
hPatch.Size             = UDim2.new(1, 0, 0, 7)
hPatch.Position         = UDim2.new(0, 0, 1, -7)
hPatch.BackgroundColor3 = C.header
hPatch.BackgroundTransparency = 0
hPatch.BorderSizePixel  = 0
hPatch.ZIndex           = 10
hPatch.Parent           = header

local hBorder = Instance.new("Frame")
hBorder.Size             = UDim2.new(1, 0, 0, 1)
hBorder.Position         = UDim2.new(0, 0, 1, -1)
hBorder.BackgroundColor3 = C.sep
hBorder.BorderSizePixel  = 0
hBorder.ZIndex           = 12
hBorder.Parent           = header

-- Logo: use rbxassetid directly (no GetUserThumbnailAsync needed)
local logoF = Instance.new("Frame")
logoF.Size             = UDim2.fromOffset(26, 26)
logoF.Position         = UDim2.new(0, 8, 0.5, -13)
logoF.BackgroundColor3 = C.card
logoF.BorderSizePixel  = 0
logoF.ZIndex           = 12
logoF.Parent           = header
Instance.new("UICorner", logoF).CornerRadius = UDim.new(0, 6)
local logoS = Instance.new("UIStroke", logoF); logoS.Color = C.borderH; logoS.Thickness = 1

local logoImg = Instance.new("ImageLabel")
logoImg.Size               = UDim2.fromOffset(22, 22)
logoImg.Position           = UDim2.fromOffset(2, 2)
logoImg.BackgroundTransparency = 1
logoImg.Image              = "rbxassetid://97269958324726"
logoImg.ScaleType          = Enum.ScaleType.Crop
logoImg.ZIndex             = 13
logoImg.Parent             = logoF
Instance.new("UICorner", logoImg).CornerRadius = UDim.new(0, 5)

-- Title
local titleL = Instance.new("TextLabel")
titleL.Size               = UDim2.new(0, 170, 1, 0)
titleL.Position           = UDim2.fromOffset(42, 0)
titleL.BackgroundTransparency = 1
titleL.Text               = "Ano9x TSB Strong"
titleL.Font               = Enum.Font.GothamBold
titleL.TextSize           = 11
titleL.TextColor3         = C.pri
titleL.TextXAlignment     = Enum.TextXAlignment.Left
titleL.ZIndex             = 12
titleL.Parent             = header

-- Version badge
local verF = Instance.new("Frame")
verF.Size             = UDim2.fromOffset(38, 14)
verF.Position         = UDim2.new(0, 215, 0.5, -7)
verF.BackgroundColor3 = C.card
verF.BorderSizePixel  = 0
verF.ZIndex           = 12
verF.Parent           = header
Instance.new("UICorner", verF).CornerRadius = UDim.new(1, 0)
local verS = Instance.new("UIStroke", verF); verS.Color = C.borderH; verS.Thickness = 1
local verL = Instance.new("TextLabel")
verL.Size               = UDim2.fromScale(1, 1)
verL.BackgroundTransparency = 1
verL.Text               = "v6.0"
verL.Font               = Enum.Font.GothamBold
verL.TextSize           = 8
verL.TextColor3         = C.sec
verL.ZIndex             = 13
verL.Parent             = verF

-- ─── FPS / Ping inside header (right side) ──────────────
local fpsL = Instance.new("TextLabel")
fpsL.Size               = UDim2.fromOffset(72, HDR)
fpsL.Position           = UDim2.new(1, -120, 0, 0)
fpsL.BackgroundTransparency = 1
fpsL.Text               = "FPS  60"
fpsL.Font               = Enum.Font.GothamBold
fpsL.TextSize           = 9
fpsL.TextColor3         = C.sec
fpsL.TextXAlignment     = Enum.TextXAlignment.Right
fpsL.ZIndex             = 12
fpsL.Parent             = header

local pingL = Instance.new("TextLabel")
pingL.Size               = UDim2.fromOffset(72, HDR)
pingL.Position           = UDim2.new(1, -120, 0, 0)   -- same x, stacked via secondary text
pingL.BackgroundTransparency = 1
pingL.Text               = "0ms"
pingL.Font               = Enum.Font.Gotham
pingL.TextSize           = 8
pingL.TextColor3         = C.dim
pingL.TextXAlignment     = Enum.TextXAlignment.Right
pingL.ZIndex             = 12
pingL.Parent             = header

-- Two-line FPS/Ping stack
fpsL.Size     = UDim2.fromOffset(72, 18)
fpsL.Position = UDim2.new(1, -120, 0, 4)
pingL.Size    = UDim2.fromOffset(72, 14)
pingL.Position = UDim2.new(1, -120, 0, 21)

-- Realtime update
local _ft = 0; local _fn = 0
RS.Heartbeat:Connect(function(dt)
    _fn = _fn + 1; _ft = _ft + dt
    if _ft >= 0.5 then
        fpsL.Text = "FPS  " .. tostring(math.floor(_fn/_ft))
        _fn = 0; _ft = 0
    end
    pcall(function()
        local ms = math.floor(LP:GetNetworkPing() * 1000)
        pingL.Text = ms .. " ms"
    end)
end)

-- ─── Minimize / Close (ImageButton — NO cursor ever) ────
local function makeCtrlBtn(xOff, symbol)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.fromOffset(24, 20)
    b.Position           = UDim2.new(1, xOff, 0.5, -10)
    b.BackgroundColor3   = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 13
    b.Parent             = header
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text               = symbol
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 13
    lbl.TextColor3         = C.sec
    lbl.ZIndex             = 14
    lbl.Parent             = b
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3=C.cardH}):Play()
        lbl.TextColor3 = C.white
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.1), {BackgroundColor3=C.card}):Play()
        lbl.TextColor3 = C.sec
    end)
    return b
end

local minBtn   = makeCtrlBtn(-54, "−")
local closeBtn = makeCtrlBtn(-26, "×")

-- ═════════════════════════════════════════
-- BODY
-- ═════════════════════════════════════════
local body = Instance.new("Frame")
body.Size               = UDim2.new(1, 0, 1, -HDR)
body.Position           = UDim2.fromOffset(0, HDR)
body.BackgroundTransparency = 1
body.BorderSizePixel    = 0
body.ClipsDescendants   = true
body.ZIndex             = 11
body.Parent             = win

-- ═════════════════════════════════════════
-- SIDEBAR
-- ═════════════════════════════════════════
local sidebar = Instance.new("Frame")
sidebar.Size               = UDim2.fromOffset(SW, H - HDR)
sidebar.BackgroundColor3   = C.sidebar
sidebar.BackgroundTransparency = 0
sidebar.BorderSizePixel    = 0
sidebar.ClipsDescendants   = true
sidebar.ZIndex             = 12
sidebar.Parent             = body

local sideR = Instance.new("Frame")
sideR.Size             = UDim2.new(0, 1, 1, 0)
sideR.Position         = UDim2.new(1, -1, 0, 0)
sideR.BackgroundColor3 = C.sep
sideR.BorderSizePixel  = 0
sideR.ZIndex           = 13
sideR.Parent           = sidebar

-- ─── Profile ─────────────────────────────
local profF = Instance.new("Frame")
profF.Size             = UDim2.new(1, 0, 0, 78)
profF.BackgroundColor3 = C.header
profF.BackgroundTransparency = 0
profF.BorderSizePixel  = 0
profF.ZIndex           = 13
profF.Parent           = sidebar

-- avatar ring
local avRing = Instance.new("Frame")
avRing.Size             = UDim2.fromOffset(38, 38)
avRing.Position         = UDim2.new(0.5, -19, 0, 7)
avRing.BackgroundColor3 = C.borderH
avRing.BorderSizePixel  = 0
avRing.ZIndex           = 14
avRing.Parent           = profF
Instance.new("UICorner", avRing).CornerRadius = UDim.new(1, 0)

local avImg = Instance.new("ImageLabel")
avImg.Size               = UDim2.fromOffset(34, 34)
avImg.Position           = UDim2.fromOffset(2, 2)
avImg.BackgroundColor3   = C.card
avImg.BackgroundTransparency = 0
avImg.Image              = ""
avImg.ScaleType          = Enum.ScaleType.Crop
avImg.ZIndex             = 15
avImg.Parent             = avRing
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    pcall(function()
        avImg.Image = Players:GetUserThumbnailAsync(
            LP.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150)
    end)
end)

local dispL = Instance.new("TextLabel")
dispL.Size               = UDim2.new(1, -4, 0, 12)
dispL.Position           = UDim2.fromOffset(2, 49)
dispL.BackgroundTransparency = 1
dispL.Text               = LP.DisplayName
dispL.Font               = Enum.Font.GothamBold
dispL.TextSize           = 9
dispL.TextColor3         = C.pri
dispL.TextXAlignment     = Enum.TextXAlignment.Center
dispL.TextTruncate       = Enum.TextTruncate.AtEnd
dispL.ZIndex             = 14
dispL.Parent             = profF

local userL = Instance.new("TextLabel")
userL.Size               = UDim2.new(1, -4, 0, 10)
userL.Position           = UDim2.fromOffset(2, 62)
userL.BackgroundTransparency = 1
userL.Text               = "@" .. LP.Name
userL.Font               = Enum.Font.Gotham
userL.TextSize           = 8
userL.TextColor3         = C.sec
userL.TextXAlignment     = Enum.TextXAlignment.Center
userL.TextTruncate       = Enum.TextTruncate.AtEnd
userL.ZIndex             = 14
userL.Parent             = profF

local profSep = Instance.new("Frame")
profSep.Size             = UDim2.new(1, 0, 0, 1)
profSep.Position         = UDim2.new(0, 0, 1, -1)
profSep.BackgroundColor3 = C.sep
profSep.BorderSizePixel  = 0
profSep.ZIndex           = 14
profSep.Parent           = profF

-- ─── Tab Buttons (ImageButton — zero cursor risk) ────────
local TABS = {
    {id="Kill",     label="Auto Kill"},
    {id="Move",     label="Movement"},
    {id="Exploit",  label="Exploits"},
    {id="Teleport", label="Teleport"},
}
local tabBtns   = {}
local tabPanels = {}
local activeTab = "Kill"
local cTabLbl   -- forward decl

local function setTab(id)
    activeTab = id
    for _, def in ipairs(TABS) do
        local btn = tabBtns[def.id]
        local pan = tabPanels[def.id]
        local on  = def.id == id
        if btn then
            TS:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3   = on and C.cardH or C.sidebar,
                BackgroundTransparency = on and 0 or 1,
            }):Play()
            if btn:FindFirstChild("Txt") then
                btn.Txt.TextColor3 = on and C.white or C.sec
            end
            if btn:FindFirstChild("Acc") then
                btn.Acc.BackgroundTransparency = on and 0 or 1
            end
        end
        if pan then pan.Visible = on end
    end
    if cTabLbl then cTabLbl.Text = id == "Kill" and "Auto Kill" or id end
end

local tabsF = Instance.new("Frame")
tabsF.Size               = UDim2.new(1, 0, 0, 140)
tabsF.Position           = UDim2.fromOffset(0, 78)
tabsF.BackgroundTransparency = 1
tabsF.BorderSizePixel    = 0
tabsF.ZIndex             = 13
tabsF.Parent             = sidebar

local tabsLL = Instance.new("UIListLayout")
tabsLL.SortOrder = Enum.SortOrder.LayoutOrder
tabsLL.Padding   = UDim.new(0, 1)
tabsLL.Parent    = tabsF

local tabsPad = Instance.new("UIPadding")
tabsPad.PaddingLeft  = UDim.new(0, 5)
tabsPad.PaddingRight = UDim.new(0, 5)
tabsPad.PaddingTop   = UDim.new(0, 5)
tabsPad.Parent       = tabsF

for i, def in ipairs(TABS) do
    local id = def.id
    -- USE ImageButton, NOT TextButton → no cursor ever
    local btn = Instance.new("ImageButton")
    btn.Name               = "Tab_"..id
    btn.Size               = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3   = C.sidebar
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = i
    btn.ZIndex             = 14
    btn.Parent             = tabsF
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    -- Accent bar
    local acc = Instance.new("Frame")
    acc.Name             = "Acc"
    acc.Size             = UDim2.fromOffset(2, 12)
    acc.Position         = UDim2.new(0, 6, 0.5, -6)
    acc.BackgroundColor3 = C.white
    acc.BackgroundTransparency = 1
    acc.BorderSizePixel  = 0
    acc.ZIndex           = 15
    acc.Parent           = btn
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.Name               = "Txt"
    lbl.Size               = UDim2.new(1, -18, 1, 0)
    lbl.Position           = UDim2.fromOffset(16, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = def.label
    lbl.Font               = Enum.Font.GothamSemibold
    lbl.TextSize           = 10
    lbl.TextColor3         = C.sec
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 15
    lbl.Parent             = btn

    btn.MouseButton1Click:Connect(function() setTab(id) end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= id then
            TS:Create(btn, TweenInfo.new(0.10), {BackgroundTransparency=0.7}):Play()
            lbl.TextColor3 = C.pri
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= id then
            TS:Create(btn, TweenInfo.new(0.10), {BackgroundTransparency=1}):Play()
            lbl.TextColor3 = C.sec
        end
    end)
    tabBtns[id] = btn
end

-- ─── Social (ImageButton) ─────────────────────────────────
local socF = Instance.new("Frame")
socF.Size             = UDim2.new(1, 0, 0, 52)
socF.Position         = UDim2.new(0, 0, 1, -52)
socF.BackgroundColor3 = C.header
socF.BackgroundTransparency = 0
socF.BorderSizePixel  = 0
socF.ZIndex           = 13
socF.Parent           = sidebar

local socTop = Instance.new("Frame")
socTop.Size             = UDim2.new(1, 0, 0, 1)
socTop.BackgroundColor3 = C.sep
socTop.BorderSizePixel  = 0
socTop.ZIndex           = 14
socTop.Parent           = socF

local function mkSocBtn(txt, yOff)
    local b = Instance.new("ImageButton")
    b.Size               = UDim2.new(1, -10, 0, 18)
    b.Position           = UDim2.fromOffset(5, yOff)
    b.BackgroundColor3   = C.card
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Image              = ""
    b.AutoButtonColor    = false
    b.ZIndex             = 14
    b.Parent             = socF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 8
    l.TextColor3         = C.pri
    l.ZIndex             = 15
    l.Parent             = b
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.cardH}):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3=C.card}):Play()
    end)
    return b
end

local webB = mkSocBtn("My Website", 6)
webB.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://anonymous9x-site.pages.dev/") end)
    pcall(function() SG:SetCore("SendNotification",{Title="A9X",Text="Website URL copied!",Duration=3}) end)
end)

local ytB = mkSocBtn("YouTube  @anonymous9xch", 28)
ytB.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://youtube.com/@anonymous9xch") end)
    pcall(function() SG:SetCore("SendNotification",{Title="A9X",Text="YouTube URL copied!",Duration=3}) end)
end)

-- ═════════════════════════════════════════
-- CONTENT AREA
-- ═════════════════════════════════════════
local cArea = Instance.new("Frame")
cArea.Size               = UDim2.new(1, -SW, 1, 0)
cArea.Position           = UDim2.fromOffset(SW, 0)
cArea.BackgroundColor3   = C.content
cArea.BackgroundTransparency = 0
cArea.BorderSizePixel    = 0
cArea.ClipsDescendants   = true
cArea.ZIndex             = 12
cArea.Parent             = body

local cBar = Instance.new("Frame")
cBar.Size             = UDim2.new(1, 0, 0, 24)
cBar.BackgroundColor3 = C.header
cBar.BackgroundTransparency = 0
cBar.BorderSizePixel  = 0
cBar.ZIndex           = 13
cBar.Parent           = cArea

local cBarSep = Instance.new("Frame")
cBarSep.Size             = UDim2.new(1, 0, 0, 1)
cBarSep.Position         = UDim2.new(0, 0, 1, -1)
cBarSep.BackgroundColor3 = C.sep
cBarSep.BorderSizePixel  = 0
cBarSep.ZIndex           = 14
cBarSep.Parent           = cBar

cTabLbl = Instance.new("TextLabel")
cTabLbl.Size               = UDim2.new(1, -10, 1, 0)
cTabLbl.Position           = UDim2.fromOffset(10, 0)
cTabLbl.BackgroundTransparency = 1
cTabLbl.Text               = "Auto Kill"
cTabLbl.Font               = Enum.Font.GothamBold
cTabLbl.TextSize            = 10
cTabLbl.TextColor3          = C.pri
cTabLbl.TextXAlignment      = Enum.TextXAlignment.Left
cTabLbl.ZIndex              = 14
cTabLbl.Parent              = cBar

-- ═════════════════════════════════════════
-- UI COMPONENT LIBRARY
-- All clickable = ImageButton → no cursor
-- ═════════════════════════════════════════

local function mkPanel(id)
    local s = Instance.new("ScrollingFrame")
    s.Name                 = "P_"..id
    s.Size                 = UDim2.new(1, 0, 1, -24)
    s.Position             = UDim2.fromOffset(0, 24)
    s.BackgroundTransparency = 1
    s.BorderSizePixel      = 0
    s.ScrollBarThickness   = 2
    s.ScrollBarImageColor3 = C.borderH
    s.ScrollingDirection   = Enum.ScrollingDirection.Y
    s.CanvasSize           = UDim2.fromOffset(0, 0)
    s.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    s.Visible              = false
    s.ZIndex               = 13
    s.Parent               = cArea
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0,3); l.Parent = s
    local p = Instance.new("UIPadding")
    p.PaddingLeft=UDim.new(0,7); p.PaddingRight=UDim.new(0,7)
    p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,6)
    p.Parent = s
    tabPanels[id] = s
    return s
end

local function mkSec(par, title, ord)
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1,0,0,18)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = ord
    f.ZIndex             = 14
    f.Parent             = par
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text               = title:upper()
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 8
    l.TextColor3         = C.secLbl
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.ZIndex             = 15
    l.Parent             = f
    local ln = Instance.new("Frame")
    ln.Size             = UDim2.new(1,0,0,1)
    ln.Position         = UDim2.new(0,0,1,-1)
    ln.BackgroundColor3 = C.sep
    ln.BorderSizePixel  = 0
    ln.ZIndex           = 15
    ln.Parent           = f
    return f
end

-- Toggle (ImageButton hit zone)
local function mkToggle(par, opts)
    local h = opts.sub and 40 or 30
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,h)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.ord
    card.ZIndex             = 14
    card.Parent             = par
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1,-46,0,13)
    tl.Position           = UDim2.fromOffset(8, opts.sub and 5 or 8)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize           = 10
    tl.TextColor3         = C.pri
    tl.TextXAlignment     = Enum.TextXAlignment.Left
    tl.ZIndex             = 15
    tl.Parent             = card
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-46,0,10)
        sl.Position           = UDim2.fromOffset(8,19)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize           = 8
        sl.TextColor3         = C.sec
        sl.TextXAlignment     = Enum.TextXAlignment.Left
        sl.ZIndex             = 15
        sl.Parent             = card
    end
    local TW,TH2 = 28,15
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.fromOffset(TW,TH2)
    trk.Position         = UDim2.new(1,-(TW+7),0.5,-(TH2/2))
    trk.BackgroundColor3 = opts.val and C.tOn or C.tOff
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 15
    trk.Parent           = card
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local KS = TH2-4
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KS,KS)
    knob.Position         = (opts.val and UDim2.fromOffset(TW-KS-2,2)) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 16
    knob.Parent           = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local val = opts.val or false
    local function setV(v)
        val = v
        TS:Create(trk,TweenInfo.new(0.12,Enum.EasingStyle.Quad),
            {BackgroundColor3 = v and C.tOn or C.tOff}):Play()
        TS:Create(knob,TweenInfo.new(0.12,Enum.EasingStyle.Quad),
            {Position = v and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        if opts.cb then opts.cb(v) end
    end
    -- ImageButton hit zone (never shows cursor)
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 17
    hit.Parent             = card
    hit.MouseButton1Click:Connect(function() setV(not val) end)
    hit.MouseEnter:Connect(function()
        TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play()
    end)
    hit.MouseLeave:Connect(function()
        TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play()
    end)
    return card, setV
end

-- Slider
local function mkSlider(par, opts)
    local step = opts.step or 1
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,42)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.ord
    card.ZIndex             = 14
    card.Parent             = par
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(0.6,0,0,12)
    tl.Position           = UDim2.fromOffset(8,6)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 10
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 15
    tl.Parent              = card
    local rng = math.max(0.001, opts.max - opts.min)
    local pct = (opts.def - opts.min) / rng
    local defStr = step < 1 and string.format("%.1f",opts.def) or tostring(math.floor(opts.def))
    local vl = Instance.new("TextLabel")
    vl.Size               = UDim2.new(0.4,-8,0,12)
    vl.Position           = UDim2.new(0.6,0,0,6)
    vl.BackgroundTransparency = 1
    vl.Text               = defStr .. (opts.suf or "")
    vl.Font               = Enum.Font.GothamBold
    vl.TextSize            = 10
    vl.TextColor3          = C.pri
    vl.TextXAlignment      = Enum.TextXAlignment.Right
    vl.ZIndex              = 15
    vl.Parent              = card
    local trk = Instance.new("Frame")
    trk.Name             = "Tr"
    trk.Size             = UDim2.new(1,-16,0,4)
    trk.Position         = UDim2.fromOffset(8,25)
    trk.BackgroundColor3 = C.trkBg
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 15
    trk.Parent           = card
    Instance.new("UICorner",trk).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = C.trkFill
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 16
    fill.Parent           = trk
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local KD = 10
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KD,KD)
    knob.Position         = UDim2.new(pct,-KD/2,0.5,-KD/2)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 17
    knob.Parent           = trk
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local value = opts.def
    local isDrag = false
    local function updX(ax)
        local ta = trk.AbsolutePosition
        local ts = trk.AbsoluteSize
        if ts.X < 1 then return end
        local rel = math.clamp((ax-ta.X)/ts.X,0,1)
        value = math.floor((opts.min + rel*rng)/step+0.5)*step
        value = math.clamp(value, opts.min, opts.max)
        local p = (value-opts.min)/rng
        fill.Size     = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-KD/2,0.5,-KD/2)
        local disp = step<1 and string.format("%.1f",value) or tostring(math.floor(value))
        vl.Text = disp..(opts.suf or "")
        if opts.cb then opts.cb(value) end
    end
    -- ImageButton hit zone
    local hit = Instance.new("ImageButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Image              = ""
    hit.AutoButtonColor    = false
    hit.ZIndex             = 18
    hit.Parent             = trk
    hit.MouseButton1Down:Connect(function(x) isDrag=true; updX(x) end)
    hit.TouchLongPress:Connect(function() isDrag=true end)
    hit.TouchPan:Connect(function(_,pos) if isDrag and pos[1] then updX(pos[1].X) end end)
    UIS.InputChanged:Connect(function(inp)
        if not isDrag then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch then updX(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then isDrag=false end
    end)
    return card
end

-- Dropdown
local function mkDrop(par, opts)
    local IH    = 22
    local listH = #opts.opts * IH + 4
    local card  = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,32)
    card.BackgroundColor3   = C.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.ord
    card.ClipsDescendants   = false
    card.ZIndex             = 20
    card.Parent             = par
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(0.46,0,0,12)
    tl.Position           = UDim2.fromOffset(8,10)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize            = 10
    tl.TextColor3          = C.pri
    tl.TextXAlignment      = Enum.TextXAlignment.Left
    tl.ZIndex              = 21
    tl.Parent              = card
    -- selector ImageButton
    local sel = Instance.new("ImageButton")
    sel.Size               = UDim2.new(0.52,-6,0,22)
    sel.Position           = UDim2.new(0.48,0,0.5,-11)
    sel.BackgroundColor3   = C.trkBg
    sel.BackgroundTransparency = 0
    sel.BorderSizePixel    = 0
    sel.Image              = ""
    sel.AutoButtonColor    = false
    sel.ZIndex             = 21
    sel.Parent             = card
    Instance.new("UICorner",sel).CornerRadius = UDim.new(0,4)
    local selL = Instance.new("TextLabel")
    selL.Size               = UDim2.new(1,-14,1,0)
    selL.Position           = UDim2.fromOffset(6,0)
    selL.BackgroundTransparency = 1
    selL.Text               = opts.def or opts.opts[1]
    selL.Font               = Enum.Font.GothamSemibold
    selL.TextSize            = 9
    selL.TextColor3          = C.pri
    selL.TextXAlignment      = Enum.TextXAlignment.Left
    selL.ZIndex              = 22
    selL.Parent              = sel
    local chv = Instance.new("TextLabel")
    chv.Size               = UDim2.fromOffset(12,22)
    chv.Position           = UDim2.new(1,-13,0,0)
    chv.BackgroundTransparency = 1
    chv.Text               = "v"
    chv.Font               = Enum.Font.GothamBold
    chv.TextSize            = 7
    chv.TextColor3          = C.sec
    chv.ZIndex              = 22
    chv.Parent              = sel
    local dList = Instance.new("Frame")
    dList.Size             = UDim2.fromOffset(10, listH)
    dList.Position         = UDim2.new(sel.Position.X.Scale, sel.Position.X.Offset, 1, 2)
    dList.BackgroundColor3 = C.trkBg
    dList.BackgroundTransparency = 0
    dList.BorderSizePixel  = 0
    dList.Visible          = false
    dList.ZIndex           = 30
    dList.Parent           = card
    Instance.new("UICorner",dList).CornerRadius = UDim.new(0,5)
    local dlS = Instance.new("UIStroke",dList); dlS.Color=C.border; dlS.Thickness=1
    local dlL = Instance.new("UIListLayout")
    dlL.SortOrder = Enum.SortOrder.LayoutOrder; dlL.Parent = dList
    local dlP = Instance.new("UIPadding")
    dlP.PaddingTop=UDim.new(0,2); dlP.PaddingBottom=UDim.new(0,2)
    dlP.PaddingLeft=UDim.new(0,2); dlP.PaddingRight=UDim.new(0,2); dlP.Parent=dList
    local isOpen = false
    local selected = opts.def or opts.opts[1]
    local function closeDD() isOpen=false; dList.Visible=false end
    local function openDD()
        dList.Size = UDim2.fromOffset(math.max(sel.AbsoluteSize.X, 90), listH)
        isOpen=true; dList.Visible=true
    end
    for i, opt in ipairs(opts.opts) do
        local o = opt
        local itm = Instance.new("ImageButton")
        itm.Size               = UDim2.new(1,0,0,IH)
        itm.BackgroundColor3   = C.trkBg
        itm.BackgroundTransparency = 0
        itm.BorderSizePixel    = 0
        itm.Image              = ""
        itm.AutoButtonColor    = false
        itm.LayoutOrder        = i
        itm.ZIndex             = 31
        itm.Parent             = dList
        Instance.new("UICorner",itm).CornerRadius = UDim.new(0,3)
        local il = Instance.new("TextLabel")
        il.Size               = UDim2.fromScale(1,1)
        il.BackgroundTransparency = 1
        il.Text               = o
        il.Font               = Enum.Font.GothamSemibold
        il.TextSize            = 9
        il.TextColor3          = C.pri
        il.TextXAlignment      = Enum.TextXAlignment.Left
        il.ZIndex              = 32
        il.Parent              = itm
        local ip = Instance.new("UIPadding"); ip.PaddingLeft=UDim.new(0,6); ip.Parent=il
        itm.MouseEnter:Connect(function() itm.BackgroundColor3=C.cardH end)
        itm.MouseLeave:Connect(function() itm.BackgroundColor3=C.trkBg end)
        itm.MouseButton1Click:Connect(function()
            selected=o; selL.Text=o; closeDD()
            if opts.cb then opts.cb(o) end
        end)
    end
    sel.MouseButton1Click:Connect(function()
        if isOpen then closeDD() else openDD() end
    end)
    return card, function() return selected end
end

-- Button (ImageButton)
local function mkBtn(par, opts)
    local h = opts.sub and 38 or 28
    local btn = Instance.new("ImageButton")
    btn.Size               = UDim2.new(1,0,0,h)
    btn.BackgroundColor3   = C.card
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel    = 0
    btn.Image              = ""
    btn.AutoButtonColor    = false
    btn.LayoutOrder        = opts.ord
    btn.ZIndex             = 14
    btn.Parent             = par
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)
    local bS = Instance.new("UIStroke",btn); bS.Color=C.border; bS.Thickness=1
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,-10,0,13)
    lbl.Position           = UDim2.fromOffset(8, opts.sub and 5 or 7)
    lbl.BackgroundTransparency = 1
    lbl.Text               = opts.title
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize            = 10
    lbl.TextColor3          = C.pri
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 15
    lbl.Parent              = btn
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-10,0,10)
        sl.Position           = UDim2.fromOffset(8,20)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize            = 8
        sl.TextColor3          = C.sec
        sl.TextXAlignment      = Enum.TextXAlignment.Left
        sl.ZIndex              = 15
        sl.Parent              = btn
    end
    btn.MouseButton1Click:Connect(function()
        TS:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play()
        task.delay(0.15,function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.cardH}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=C.card}):Play() end)
    return btn
end

local function mkDiv(par, ord)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = C.sep
    f.BackgroundTransparency = 0.3
    f.BorderSizePixel  = 0
    f.LayoutOrder      = ord
    f.ZIndex           = 14
    f.Parent           = par
    return f
end

-- ═════════════════════════════════════════
-- CREATE PANELS + FILL CONTENT
-- ═════════════════════════════════════════
for _, d in ipairs(TABS) do mkPanel(d.id) end

-- ── AUTO KILL ───────────────────────────
local kp = tabPanels["Kill"]
local _o = 0; local function o() _o=_o+1; return _o end

mkSec(kp,"Target",o())
mkDrop(kp,{title="Select Target",opts=pNames(),def="None",ord=o(),cb=function(v)
    S.target = v=="None" and nil or Players:FindFirstChild(v)
end})

mkSec(kp,"Follow",o())
mkDrop(kp,{title="Mode",opts={"HEAD","ORBIT","FEET"},def="HEAD",ord=o(),cb=function(v)
    S.mode=v; orbit=0
end})
mkSlider(kp,{title="Stud Distance",min=1,max=20,def=3,suf=" st",step=0.5,ord=o(),cb=function(v) S.dist=v end})
mkSlider(kp,{title="Follow Speed",min=5,max=100,def=20,suf="",step=1,ord=o(),cb=function(v) S.speed=v end})

mkSec(kp,"Attack",o())
mkToggle(kp,{title="Auto Tap",sub="Auto click attack buttons",val=false,ord=o(),cb=function(v)
    S.tapOn=v
    if v and not tapAlive then tapAlive=true; task.spawn(tapLoop) else tapAlive=false end
end})
mkSlider(kp,{title="Tap Delay",min=0.05,max=2,def=0.2,suf="s",step=0.05,ord=o(),cb=function(v) S.tapDelay=v end})
mkDrop(kp,{title="Skill",opts={"Pukulan Biasa","Pukulan Berurutan","Dorong","Uppercut"},def="Pukulan Biasa",ord=o(),cb=function(v) S.tapSkill=v end})

mkSec(kp,"Actions",o())
mkToggle(kp,{title="Follow Target",sub="Stick to selected target",val=false,ord=o(),cb=function(v)
    S.followOn=v; if not v then pcall(function() Cam.CameraType=Enum.CameraType.Custom end) end
end})
mkToggle(kp,{title="Solo Hacker",sub="Follow all players",val=false,ord=o(),cb=function(v) S.soloHacker=v end})
mkToggle(kp,{title="Drag Hold",sub="Pull targets to your position",val=false,ord=o(),cb=function(v) S.dragHold=v end})
mkToggle(kp,{title="Cam Lock",sub="Lock camera on target",val=false,ord=o(),cb=function(v)
    S.camLock=v; if not v then pcall(function() Cam.CameraType=Enum.CameraType.Custom end) end
end})
mkSlider(kp,{title="Cam Distance",min=5,max=80,def=12,suf=" st",step=1,ord=o(),cb=function(v)
    S.camDist=v; pcall(function() LP.CameraMaxZoomDistance=v; LP.CameraMinZoomDistance=v end)
end})
mkToggle(kp,{title="Anti Void",sub="Rescue below -250Y",val=false,ord=o(),cb=function(v) S.antiVoid=v end})

mkDiv(kp,o())
mkBtn(kp,{title="Stop All Combat",sub="Disable all follow and lock",ord=o(),cb=function()
    S.followOn=false; S.soloHacker=false; S.dragHold=false
    S.camLock=false; S.antiVoid=false; S.target=nil
    pcall(function() Cam.CameraType=Enum.CameraType.Custom end)
end})
mkBtn(kp,{title="Teleport to Target",ord=o(),cb=function()
    if not S.target then return end
    local th = getHRP()
    if th and hrp then pcall(function() hrp.CFrame=th.CFrame+Vector3.new(3,0,0) end) end
end})

-- ── MOVEMENT ────────────────────────────
local mp = tabPanels["Move"]
local _m = 0; local function m() _m=_m+1; return _m end

mkSec(mp,"Speed",m())
mkToggle(mp,{title="Speed Boost",sub="TP-walk on move",val=false,ord=m(),cb=function(v) S.speedOn=v end})
mkSlider(mp,{title="Boost Value",min=0.1,max=10,def=1.5,suf="x",step=0.1,ord=m(),cb=function(v) S.speedVal=v end})
mkToggle(mp,{title="Walkspeed Lock",sub="Force Humanoid.WalkSpeed",val=false,ord=m(),cb=function(v)
    S.wsOn=v; if not v and hum then pcall(function() hum.WalkSpeed=16 end) end
end})
mkSlider(mp,{title="Walkspeed",min=0,max=500,def=16,suf="",step=1,ord=m(),cb=function(v)
    S.ws=v; if hum then pcall(function() hum.WalkSpeed=v end) end
end})
mkSec(mp,"Jump",m())
mkToggle(mp,{title="Jump Boost",sub="Override jump height",val=false,ord=m(),cb=function(v)
    S.jumpOn=v; if hum then pcall(function() hum.UseJumpPower=not v end) end
end})
mkSlider(mp,{title="Jump Height",min=7,max=500,def=50,suf="",step=1,ord=m(),cb=function(v)
    S.jumpVal=v; if hum then pcall(function() hum.JumpHeight=v end) end
end})
mkSec(mp,"World",m())
mkSlider(mp,{title="Gravity",min=0,max=200,def=196,suf="",step=1,ord=m(),cb=function(v)
    pcall(function() workspace.Gravity=v end)
end})
mkSlider(mp,{title="FOV",min=30,max=120,def=70,suf="",step=1,ord=m(),cb=function(v)
    pcall(function() Cam.FieldOfView=v end)
end})
mkDiv(mp,m())
mkBtn(mp,{title="Reset All",ord=m(),cb=function()
    S.speedOn=false; S.wsOn=false; S.jumpOn=false
    if hum then pcall(function() hum.WalkSpeed=16; hum.JumpHeight=7.2; hum.UseJumpPower=false end) end
    pcall(function() workspace.Gravity=196.2; Cam.FieldOfView=70 end)
end})

-- ── EXPLOITS ────────────────────────────
local ep = tabPanels["Exploit"]
local _e = 0; local function e() _e=_e+1; return _e end

mkSec(ep,"TSB Attributes",e())
mkToggle(ep,{title="No Dash Cooldown",sub="workspace NoDashCooldown",val=false,ord=e(),cb=function(v)
    S.noDash=v; pcall(function() workspace:SetAttribute("NoDashCooldown",v) end)
end})
mkToggle(ep,{title="No Fatigue",sub="workspace NoFatigue",val=false,ord=e(),cb=function(v)
    S.noFatigue=v; pcall(function() workspace:SetAttribute("NoFatigue",v) end)
end})
mkSec(ep,"Emotes",e())
mkToggle(ep,{title="Extra Emote Slots",val=false,ord=e(),cb=function(v)
    S.extraSlots=v; pcall(function() LP:SetAttribute("ExtraSlots",v) end)
end})
mkToggle(ep,{title="Emote Search Bar",val=false,ord=e(),cb=function(v)
    S.emoteSearch=v; pcall(function() LP:SetAttribute("EmoteSearchBar",v) end)
end})
mkSec(ep,"Server",e())
mkBtn(ep,{title="Spoof VIP Owner",sub="Sets VIPServer to your UserId",ord=e(),cb=function()
    pcall(function()
        workspace:SetAttribute("VIPServer",tostring(LP.UserId))
        workspace:SetAttribute("VIPServerOwner",LP.Name)
    end)
end})
mkBtn(ep,{title="Apply All Attributes",ord=e(),cb=initTSB})

-- ── TELEPORT ────────────────────────────
local tpp = tabPanels["Teleport"]
local _t = 0; local function t() _t=_t+1; return _t end

mkSec(tpp,"Map Locations",t())
local LOCS = {
    {"Middle",         CFrame.new(148,441,27)},
    {"Atomic Room",    CFrame.new(1079,155,23003)},
    {"Death Counter",  CFrame.new(-92,29,20347)},
    {"Baseplate",      CFrame.new(968,20,23088)},
    {"Mountain 1",     CFrame.new(266,699,458)},
    {"Mountain 2",     CFrame.new(551,630,-265)},
    {"Mountain 3",     CFrame.new(-107,642,-328)},
}
for _, loc in ipairs(LOCS) do
    local cf = loc[2]
    mkBtn(tpp,{title=loc[1],ord=t(),cb=function()
        if hrp then pcall(function() hrp.CFrame=cf end) end
    end})
end
mkSec(tpp,"Player Teleport",t())
mkBtn(tpp,{title="Teleport to Target",sub="Select target in Auto Kill first",ord=t(),cb=function()
    if not S.target then return end
    local th = getHRP()
    if th and hrp then pcall(function() hrp.CFrame=th.CFrame+Vector3.new(3,0,0) end) end
end})
mkBtn(tpp,{title="Bring Target to Me",ord=t(),cb=function()
    if not S.target or not hrp then return end
    local th = getHRP()
    if th then pcall(function() th.CFrame=hrp.CFrame+Vector3.new(2,0,0) end) end
end})

-- ═════════════════════════════════════════
-- DRAG  —  global UIS (reliable on all executors + mobile)
-- Header-only: check that position falls inside header bounds
-- ═════════════════════════════════════════
do
    local drag=false; local startIn=nil; local startWin=nil

    local function inHeader(x, y)
        local ap = header.AbsolutePosition
        local az = header.AbsoluteSize
        -- exclude right 60px (control buttons)
        return x >= ap.X and x <= ap.X + az.X - 60
           and y >= ap.Y and y <= ap.Y + az.Y
    end

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end   -- game processed = ignore
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isT or isM) then return end
        if not win.Visible then return end
        if not inHeader(inp.Position.X, inp.Position.Y) then return end
        drag    = true
        startIn = Vector2.new(inp.Position.X, inp.Position.Y)
        startWin = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseMove
        if not (isT or isM) then return end
        local d   = Vector2.new(inp.Position.X, inp.Position.Y) - startIn
        local vp2 = Cam.ViewportSize
        win.Position = UDim2.fromOffset(
            math.clamp(startWin.X + d.X, 0, vp2.X - W),
            math.clamp(startWin.Y + d.Y, 0, vp2.Y - H))
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- ═════════════════════════════════════════
-- FLOAT ICON  (minimize → icon right-center)
-- ═════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name               = "FI"
floatF.Size               = UDim2.fromOffset(46, 46)
floatF.BackgroundColor3   = C.header
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel    = 0
floatF.Visible            = false
floatF.ZIndex             = 500
floatF.Parent             = root
Instance.new("UICorner",floatF).CornerRadius = UDim.new(0,9)
local fiS = Instance.new("UIStroke",floatF); fiS.Color=C.white; fiS.Thickness=1.2

local fiImg = Instance.new("ImageLabel")
fiImg.Size               = UDim2.fromOffset(38,38)
fiImg.Position           = UDim2.fromOffset(4,4)
fiImg.BackgroundTransparency = 1
fiImg.Image              = "rbxassetid://97269958324726"
fiImg.ScaleType          = Enum.ScaleType.Crop
fiImg.ZIndex             = 501
fiImg.Parent             = floatF
Instance.new("UICorner",fiImg).CornerRadius = UDim.new(0,7)

local function anchorFloat()
    local vp2 = Cam.ViewportSize
    if vp2.X < 10 then vp2 = Vector2.new(800,600) end
    floatF.Position = UDim2.fromOffset(vp2.X - 56, math.floor(vp2.Y/2) - 23)
end
anchorFloat()

local fiBtn = Instance.new("ImageButton")
fiBtn.Size               = UDim2.fromScale(1,1)
fiBtn.BackgroundTransparency = 1
fiBtn.Image              = ""
fiBtn.AutoButtonColor    = false
fiBtn.ZIndex             = 502
fiBtn.Parent             = floatF
fiBtn.MouseButton1Click:Connect(function()
    floatF.Visible = false
    win.Visible    = true
end)
fiBtn.MouseEnter:Connect(function()
    TS:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.card}):Play()
end)
fiBtn.MouseLeave:Connect(function()
    TS:Create(floatF,TweenInfo.new(0.12),{BackgroundColor3=C.header}):Play()
end)

-- ═════════════════════════════════════════
-- MINIMIZE / CLOSE
-- ═════════════════════════════════════════
minBtn.MouseButton1Click:Connect(function()
    win.Visible    = false
    anchorFloat()
    floatF.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    pcall(function() root:Destroy() end)
    pcall(function() Cam.CameraType=Enum.CameraType.Custom end)
end)

-- ═════════════════════════════════════════
-- INIT
-- ═════════════════════════════════════════
setTab("Kill")

task.spawn(function()
    task.wait(1.5)
    pcall(function()
        dispL.Text = LP.DisplayName
        userL.Text = "@"..LP.Name
    end)
end)

task.spawn(function()
    task.wait(2.5)
    pcall(function()
        SG:SetCore("SendNotification",{
            Title="Anonymous9x TSB Strong",
            Text="v6.0 Ready — All systems online",
            Duration=4,
        })
    end)
end)
