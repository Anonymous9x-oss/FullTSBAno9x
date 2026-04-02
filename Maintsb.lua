--[[
    Anonymous9x TSB Strong  v5.0
    The Strongest Battlegrounds
    By Anonymous9x
    website : https://anonymous9x-site.pages.dev/
    youtube : https://youtube.com/@anonymous9xch
    ─────────────────────────────────────────────
    All executors  |  PC + Mobile + Touch + Mouse
    Monochrome UI  |  Loading  |  FPS/Ping Status
    Float-icon minimize  |  Zero cursor bugs
]]

-- ══════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════
local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local SG        = game:GetService("StarterGui")
local LP        = Players.LocalPlayer
local Cam       = workspace.CurrentCamera

-- ══════════════════════════════════════════════
-- CHARACTER  (auto re-link on respawn)
-- ══════════════════════════════════════════════
local char, hum, hrp
local function linkChar(c)
    char = c
    hum  = c:WaitForChild("Humanoid",         10)
    hrp  = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then linkChar(LP.Character) end
LP.CharacterAdded:Connect(linkChar)

-- ══════════════════════════════════════════════
-- TSB ATTRIBUTE INIT
-- ══════════════════════════════════════════════
local function initTSB()
    pcall(function()
        local uid = tostring(LP.UserId)
        workspace:SetAttribute("VIPServer",      uid)
        workspace:SetAttribute("VIPServerOwner", LP.Name)
        if LP:GetAttribute("ExtraSlots")    == nil then LP:SetAttribute("ExtraSlots",    false) end
        if LP:GetAttribute("EmoteSearchBar") == nil then LP:SetAttribute("EmoteSearchBar",false) end
        if workspace:GetAttribute("NoDashCooldown") == nil then workspace:SetAttribute("NoDashCooldown",false) end
        if workspace:GetAttribute("NoFatigue")       == nil then workspace:SetAttribute("NoFatigue",      false) end
    end)
end
initTSB()

-- ══════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════
local S = {
    followOn=false, soloHacker=false, dragHold=false,
    camLock=false,  antiVoid=false,
    followMode="HEAD", studDist=3, followSpeed=20, camDist=12,
    target=nil,
    speedOn=false, speedVal=1.5,
    jumpOn=false,  jumpVal=50,
    walkspeed=16,  wsOn=false,
    noDashCD=false, noFatigue=false,
    extraSlots=false, emoteSearch=false,
    autoTapOn=false, tapDelay=0.2, tapSkill="Pukulan Biasa",
}
local _orbit       = 0
local autoTapAlive = false

-- ══════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════
local function getTHRP()
    if not S.target then return nil end
    local c = S.target.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getTHead()
    if not S.target then return nil end
    local c = S.target.Character
    return c and c:FindFirstChild("Head")
end
local function allEnemies()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then t[#t+1] = {player=p, hrp=h} end
        end
    end
    return t
end
local function playerNames()
    local n = {"None"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then n[#n+1] = p.Name end
    end
    return n
end

-- ══════════════════════════════════════════════
-- AUTO TAP ENGINE
-- ══════════════════════════════════════════════
local function findSkillBtn(skill)
    local map = {
        ["Pukulan Biasa"]     = {"Pukulan Biasa","Basic Attack","Attack"},
        ["Pukulan Berurutan"] = {"Pukulan Berurutan","Combo","Jab"},
        ["Dorong"]            = {"Dorong","Push"},
        ["Uppercut"]          = {"Uppercut","Upper"},
    }
    local texts = map[skill] or {skill}
    for _, gui in ipairs(LP.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, btn in ipairs(gui:GetDescendants()) do
                if btn:IsA("TextButton") and btn.Visible then
                    local t = btn.Text:match("^%s*(.-)%s*$") or ""
                    for _, pat in ipairs(texts) do
                        if t:find(pat, 1, true) then return btn end
                    end
                end
            end
        end
    end
end
local function tapLoop()
    while autoTapAlive do
        if S.autoTapOn and S.target and char and hrp then
            local btn = findSkillBtn(S.tapSkill)
            if btn then
                pcall(function() btn.MouseButton1Click:Fire() end)
                pcall(function() btn.Activated:Fire() end)
            end
        end
        task.wait(S.tapDelay)
    end
end

-- ══════════════════════════════════════════════
-- COMBAT ENGINE  (Heartbeat)
-- ══════════════════════════════════════════════
RS.Heartbeat:Connect(function(dt)
    if not hrp or not char then return end

    if S.speedOn and hum then
        local d = hum.MoveDirection
        if d.Magnitude > 0 then
            pcall(function() hrp.CFrame = hrp.CFrame + d * S.speedVal end)
        end
    end
    if S.wsOn and hum then
        pcall(function() if hum.WalkSpeed ~= S.walkspeed then hum.WalkSpeed = S.walkspeed end end)
    end
    if S.jumpOn and hum then
        pcall(function() hum.JumpHeight = S.jumpVal end)
    end
    if S.antiVoid and hrp.Position.Y < -250 then
        pcall(function() hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z) end)
    end

    local targets = {}
    if S.soloHacker then
        targets = allEnemies()
    elseif S.followOn and S.target then
        local tH = getTHRP()
        if tH then targets[1] = {player=S.target, hrp=tH} end
    end

    if #targets > 0 then
        local tHRP  = targets[1].hrp
        local tPos  = tHRP.Position
        local dist  = S.studDist
        local newCF = nil

        if S.followMode == "ORBIT" then
            _orbit = _orbit + dt * S.followSpeed * 0.12
            newCF  = CFrame.lookAt(
                Vector3.new(tPos.X + math.cos(_orbit)*dist, tPos.Y, tPos.Z + math.sin(_orbit)*dist),
                tPos
            )
        elseif S.followMode == "HEAD" then
            local head  = getTHead()
            local headY = head and head.Position.Y or tPos.Y + 2.5
            local look  = tHRP.CFrame.LookVector
            newCF = CFrame.lookAt(
                Vector3.new(tPos.X, headY, tPos.Z) + look * dist,
                Vector3.new(tPos.X, headY, tPos.Z)
            )
        elseif S.followMode == "FEET" then
            local look = tHRP.CFrame.LookVector
            local fy   = tPos.Y - 2.5
            newCF = CFrame.lookAt(
                Vector3.new(tPos.X + look.X*dist, fy, tPos.Z + look.Z*dist),
                Vector3.new(tPos.X, fy, tPos.Z)
            )
        end

        if newCF then pcall(function() hrp.CFrame = newCF end) end

        if S.dragHold then
            for _, en in ipairs(targets) do
                pcall(function()
                    en.hrp.CFrame = CFrame.new(hrp.Position +
                        Vector3.new(math.random(-1,1)*0.5, 0.3, math.random(-1,1)*0.5))
                end)
            end
        end
    end

    if S.camLock and S.target then
        local look = (getTHead() or getTHRP())
        if look then
            pcall(function()
                Cam.CameraType = Enum.CameraType.Scriptable
                Cam.CFrame     = CFrame.lookAt(Cam.CFrame.Position, look.Position)
            end)
        end
    end
end)

-- ══════════════════════════════════════════════
-- THEME  (monochrome: black / gray / white only)
-- ══════════════════════════════════════════════
local K = {
    winBG      = Color3.fromRGB(12, 12, 15),
    sidebar    = Color3.fromRGB(17, 17, 21),
    content    = Color3.fromRGB(13, 13, 17),
    titleBG    = Color3.fromRGB( 9,  9, 12),
    statusBG   = Color3.fromRGB( 9,  9, 12),
    card       = Color3.fromRGB(23, 23, 29),
    cardHov    = Color3.fromRGB(29, 29, 37),
    sep        = Color3.fromRGB(32, 32, 42),
    border     = Color3.fromRGB(40, 40, 52),
    borderHi   = Color3.fromRGB(62, 62, 78),
    white      = Color3.new(1, 1, 1),
    textPri    = Color3.fromRGB(222, 222, 228),
    textSec    = Color3.fromRGB(125, 125, 140),
    textDim    = Color3.fromRGB( 72,  72,  88),
    secLbl     = Color3.fromRGB(155, 155, 168),
    tOn        = Color3.fromRGB(185, 185, 198),
    tOff       = Color3.fromRGB( 40,  40,  52),
    slFill     = Color3.fromRGB(175, 175, 190),
    slTrack    = Color3.fromRGB( 36,  36,  48),
    btnBG      = Color3.fromRGB( 26,  26,  34),
    btnHov     = Color3.fromRGB( 36,  36,  46),
    btnPre     = Color3.fromRGB( 46,  46,  58),
    profileBG  = Color3.fromRGB( 15,  15,  19),
    loadBG     = Color3.fromRGB(  8,   8,  10),
    loadCard   = Color3.fromRGB( 17,  17,  21),
}

-- ══════════════════════════════════════════════
-- ROOT SCREENGUI
-- ══════════════════════════════════════════════
pcall(function() game.CoreGui:FindFirstChild("__A9xTSB5"):Destroy() end)

local root = Instance.new("ScreenGui")
root.Name             = "__A9xTSB5"
root.DisplayOrder     = 999
root.ResetOnSpawn     = false
root.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset   = true
pcall(function() root.Parent = game.CoreGui end)
if not root.Parent then root.Parent = LP.PlayerGui end

-- ══════════════════════════════════════════════
-- LOADING SCREEN
-- ══════════════════════════════════════════════
local loadBG = Instance.new("Frame")
loadBG.Size               = UDim2.fromScale(1, 1)
loadBG.BackgroundColor3   = K.loadBG
loadBG.BackgroundTransparency = 0
loadBG.ZIndex             = 5000
loadBG.Parent             = root

local loadCard = Instance.new("Frame")
loadCard.Size             = UDim2.fromOffset(270, 148)
loadCard.Position         = UDim2.new(0.5, -135, 0.5, -74)
loadCard.BackgroundColor3 = K.loadCard
loadCard.BackgroundTransparency = 0
loadCard.BorderSizePixel  = 0
loadCard.ZIndex           = 5001
loadCard.Parent           = loadBG
Instance.new("UICorner", loadCard).CornerRadius = UDim.new(0, 10)
local lcS = Instance.new("UIStroke", loadCard)
lcS.Color = K.border; lcS.Thickness = 1

-- Icon in load card
local lcIconF = Instance.new("Frame")
lcIconF.Size             = UDim2.fromOffset(48, 48)
lcIconF.Position         = UDim2.new(0.5, -24, 0, 14)
lcIconF.BackgroundColor3 = K.card
lcIconF.BorderSizePixel  = 0
lcIconF.ZIndex           = 5002
lcIconF.Parent           = loadCard
Instance.new("UICorner", lcIconF).CornerRadius = UDim.new(0, 9)

local lcIconI = Instance.new("ImageLabel")
lcIconI.Size               = UDim2.fromOffset(44, 44)
lcIconI.Position           = UDim2.fromOffset(2, 2)
lcIconI.BackgroundTransparency = 1
lcIconI.Image              = ""
lcIconI.ZIndex             = 5003
lcIconI.Parent             = lcIconF
Instance.new("UICorner", lcIconI).CornerRadius = UDim.new(0, 8)

task.spawn(function()
    pcall(function()
        local img = Players:GetUserThumbnailAsync(
            97269958324726,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        lcIconI.Image = img
    end)
end)

local function makeLbl(parent, txt, y, size, color, zIdx)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1, -16, 0, 16)
    l.Position           = UDim2.fromOffset(8, y)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = size
    l.TextColor3         = color
    l.TextXAlignment     = Enum.TextXAlignment.Center
    l.ZIndex             = zIdx
    l.Parent             = parent
    return l
end

local lcTitle = makeLbl(loadCard, "Anonymous9x TSB Strong", 70, 12, K.textPri, 5002)
local lcSub   = makeLbl(loadCard, "Initializing...", 88, 9,  K.textSec, 5002)
local lcVer   = makeLbl(loadCard, "v5.0 Beta  |  By Anonymous9x", 130, 8, K.textDim, 5002)

-- Progress track
local lcTrack = Instance.new("Frame")
lcTrack.Size             = UDim2.new(1, -24, 0, 3)
lcTrack.Position         = UDim2.fromOffset(12, 114)
lcTrack.BackgroundColor3 = K.sep
lcTrack.BorderSizePixel  = 0
lcTrack.ZIndex           = 5002
lcTrack.Parent           = loadCard
Instance.new("UICorner", lcTrack).CornerRadius = UDim.new(1, 0)

local lcFill = Instance.new("Frame")
lcFill.Size             = UDim2.fromOffset(0, 3)
lcFill.BackgroundColor3 = K.white
lcFill.BorderSizePixel  = 0
lcFill.ZIndex           = 5003
lcFill.Parent           = lcTrack
Instance.new("UICorner", lcFill).CornerRadius = UDim.new(1, 0)

-- Animate loading then destroy
task.spawn(function()
    local steps = {
        {msg = "Loading modules...",  pct = 0.30},
        {msg = "Fetching profile...", pct = 0.65},
        {msg = "Building UI...",      pct = 0.90},
        {msg = "Ready!",              pct = 1.00},
    }
    for _, s in ipairs(steps) do
        lcSub.Text = s.msg
        TS:Create(lcFill, TweenInfo.new(0.30, Enum.EasingStyle.Quad),
            {Size = UDim2.new(s.pct, 0, 1, 0)}):Play()
        task.wait(0.42)
    end
    task.wait(0.25)
    TS:Create(loadBG, TweenInfo.new(0.35, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 1}):Play()
    TS:Create(loadCard, TweenInfo.new(0.30, Enum.EasingStyle.Quad),
        {BackgroundTransparency = 1}):Play()
    task.wait(0.38)
    pcall(function() loadBG:Destroy() end)
end)

-- ══════════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════════
local WIN_W  = 476
local WIN_H  = 396
local SIDE_W = 120
local TH     = 36   -- titlebar height
local SH     = 22   -- statusbar height

local vp = Cam.ViewportSize
if vp.X < 10 then task.wait(0.12); vp = Cam.ViewportSize end

local win = Instance.new("Frame")
win.Name               = "Win"
win.Size               = UDim2.fromOffset(WIN_W, WIN_H)
win.Position           = UDim2.fromOffset(
    math.max(0, math.floor((vp.X - WIN_W)/2)),
    math.max(0, math.floor((vp.Y - WIN_H)/3))
)
win.BackgroundColor3   = K.winBG
win.BackgroundTransparency = 0.10
win.BorderSizePixel    = 0
win.ClipsDescendants   = false
win.ZIndex             = 200
win.Parent             = root
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

local winS = Instance.new("UIStroke", win)
winS.Color = K.border; winS.Thickness = 1

-- ══════════════════════════════════════════════
-- TITLE BAR
-- ══════════════════════════════════════════════
local titlebar = Instance.new("Frame")
titlebar.Name               = "TB"
titlebar.Size               = UDim2.new(1, 0, 0, TH)
titlebar.BackgroundColor3   = K.titleBG
titlebar.BackgroundTransparency = 0.08
titlebar.BorderSizePixel    = 0
titlebar.ZIndex             = 202
titlebar.Parent             = win
Instance.new("UICorner", titlebar).CornerRadius = UDim.new(0, 8)

-- Cover bottom rounded corners of titlebar
local tbPatch = Instance.new("Frame")
tbPatch.Size             = UDim2.new(1, 0, 0, 8)
tbPatch.Position         = UDim2.new(0, 0, 1, -8)
tbPatch.BackgroundColor3 = K.titleBG
tbPatch.BackgroundTransparency = 0.08
tbPatch.BorderSizePixel  = 0
tbPatch.ZIndex           = 201
tbPatch.Parent           = titlebar

-- Title separator
local tbSep = Instance.new("Frame")
tbSep.Size             = UDim2.new(1, 0, 0, 1)
tbSep.Position         = UDim2.new(0, 0, 1, -1)
tbSep.BackgroundColor3 = K.sep
tbSep.BorderSizePixel  = 0
tbSep.ZIndex           = 203
tbSep.Parent           = titlebar

-- Logo icon frame
local logoF = Instance.new("Frame")
logoF.Size             = UDim2.fromOffset(24, 24)
logoF.Position         = UDim2.new(0, 9, 0.5, -12)
logoF.BackgroundColor3 = K.card
logoF.BorderSizePixel  = 0
logoF.ZIndex           = 204
logoF.Parent           = titlebar
Instance.new("UICorner", logoF).CornerRadius = UDim.new(0, 6)
local logoS = Instance.new("UIStroke", logoF)
logoS.Color = K.borderHi; logoS.Thickness = 1

local logoI = Instance.new("ImageLabel")
logoI.Size               = UDim2.fromOffset(20, 20)
logoI.Position           = UDim2.fromOffset(2, 2)
logoI.BackgroundTransparency = 1
logoI.Image              = ""
logoI.ZIndex             = 205
logoI.Parent             = logoF
Instance.new("UICorner", logoI).CornerRadius = UDim.new(0, 5)

task.spawn(function()
    pcall(function()
        local img = Players:GetUserThumbnailAsync(
            97269958324726,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        logoI.Image = img
    end)
end)

-- Title label
local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1, -155, 1, 0)
titleLbl.Position           = UDim2.fromOffset(40, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "Anonymous9x TSB Strong"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 11
titleLbl.TextColor3         = K.textPri
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 204
titleLbl.Parent             = titlebar

-- Version badge
local verF = Instance.new("Frame")
verF.Size             = UDim2.fromOffset(46, 15)
verF.Position         = UDim2.new(0, 40 + 168, 0.5, -7)
verF.BackgroundColor3 = K.card
verF.BorderSizePixel  = 0
verF.ZIndex           = 204
verF.Parent           = titlebar
Instance.new("UICorner", verF).CornerRadius = UDim.new(1, 0)
local verS = Instance.new("UIStroke", verF)
verS.Color = K.borderHi; verS.Thickness = 1

local verL = Instance.new("TextLabel")
verL.Size               = UDim2.fromScale(1, 1)
verL.BackgroundTransparency = 1
verL.Text               = "v5.0"
verL.Font               = Enum.Font.GothamBold
verL.TextSize           = 8
verL.TextColor3         = K.textSec
verL.ZIndex             = 205
verL.Parent             = verF

-- Minimize button (−)
local minBtn = Instance.new("TextButton")
minBtn.Size               = UDim2.fromOffset(24, 20)
minBtn.Position           = UDim2.new(1, -54, 0.5, -10)
minBtn.BackgroundColor3   = Color3.fromRGB(35, 35, 46)
minBtn.BackgroundTransparency = 0
minBtn.BorderSizePixel    = 0
minBtn.Text               = "−"
minBtn.Font               = Enum.Font.GothamBold
minBtn.TextSize           = 13
minBtn.TextColor3         = K.textSec
minBtn.AutoButtonColor    = false
minBtn.Selectable         = false
minBtn.ZIndex             = 205
minBtn.Parent             = titlebar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)

-- Close button (×)
local closeBtn = Instance.new("TextButton")
closeBtn.Size               = UDim2.fromOffset(24, 20)
closeBtn.Position           = UDim2.new(1, -26, 0.5, -10)
closeBtn.BackgroundColor3   = Color3.fromRGB(35, 35, 46)
closeBtn.BackgroundTransparency = 0
closeBtn.BorderSizePixel    = 0
closeBtn.Text               = "×"
closeBtn.Font               = Enum.Font.GothamBold
closeBtn.TextSize           = 14
closeBtn.TextColor3         = K.textSec
closeBtn.AutoButtonColor    = false
closeBtn.Selectable         = false
closeBtn.ZIndex             = 205
closeBtn.Parent             = titlebar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- Hover for control buttons
for _, b in ipairs({minBtn, closeBtn}) do
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {
            BackgroundColor3 = Color3.fromRGB(52, 52, 66),
            TextColor3       = K.white,
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 46),
            TextColor3       = K.textSec,
        }):Play()
    end)
end

-- ══════════════════════════════════════════════
-- STATUS BAR  (FPS  Ping  Version  Free)
-- ══════════════════════════════════════════════
local statusBar = Instance.new("Frame")
statusBar.Size               = UDim2.new(1, 0, 0, SH)
statusBar.Position           = UDim2.fromOffset(0, TH)
statusBar.BackgroundColor3   = K.statusBG
statusBar.BackgroundTransparency = 0.12
statusBar.BorderSizePixel    = 0
statusBar.ZIndex             = 202
statusBar.Parent             = win

local sbSep = Instance.new("Frame")
sbSep.Size             = UDim2.new(1, 0, 0, 1)
sbSep.Position         = UDim2.new(0, 0, 1, -1)
sbSep.BackgroundColor3 = K.sep
sbSep.BorderSizePixel  = 0
sbSep.ZIndex           = 203
sbSep.Parent           = statusBar

local sbLayout = Instance.new("UIListLayout")
sbLayout.FillDirection     = Enum.FillDirection.Horizontal
sbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
sbLayout.Padding           = UDim.new(0, 0)
sbLayout.Parent            = statusBar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingLeft = UDim.new(0, 10)
sbPad.Parent      = statusBar

-- Status item factory
local fpsVal, pingVal

local function makeSbItem(tag, val, order)
    local f = Instance.new("Frame")
    f.Size               = UDim2.fromOffset(88, SH)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = order
    f.ZIndex             = 203
    f.Parent             = statusBar

    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.fromOffset(28, SH)
    tl.BackgroundTransparency = 1
    tl.Text               = tag
    tl.Font               = Enum.Font.GothamBold
    tl.TextSize           = 8
    tl.TextColor3         = K.textDim
    tl.ZIndex             = 204
    tl.Parent             = f

    local vl = Instance.new("TextLabel")
    vl.Size               = UDim2.fromOffset(54, SH)
    vl.Position           = UDim2.fromOffset(28, 0)
    vl.BackgroundTransparency = 1
    vl.Text               = val
    vl.Font               = Enum.Font.GothamBold
    vl.TextSize           = 8
    vl.TextColor3         = K.textPri
    vl.ZIndex             = 204
    vl.Parent             = f

    -- Vertical separator
    local vs = Instance.new("Frame")
    vs.Size             = UDim2.fromOffset(1, 11)
    vs.Position         = UDim2.new(1, -1, 0.5, -5)
    vs.BackgroundColor3 = K.sep
    vs.BorderSizePixel  = 0
    vs.ZIndex           = 203
    vs.Parent           = f

    return vl
end

fpsVal  = makeSbItem("FPS",  "60",   1)
pingVal = makeSbItem("Ping", "0ms",  2)

-- Static items
local function makeSbStatic(txt, order)
    local f = Instance.new("Frame")
    f.Size               = UDim2.fromOffset(88, SH)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = order
    f.ZIndex             = 203
    f.Parent             = statusBar

    local l = Instance.new("TextLabel")
    l.Size               = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 8
    l.TextColor3         = K.textSec
    l.ZIndex             = 204
    l.Parent             = f

    local vs = Instance.new("Frame")
    vs.Size             = UDim2.fromOffset(1, 11)
    vs.Position         = UDim2.new(1, -1, 0.5, -5)
    vs.BackgroundColor3 = K.sep
    vs.BorderSizePixel  = 0
    vs.ZIndex           = 203
    vs.Parent           = f
end

makeSbStatic("v5.0 Beta", 3)
makeSbStatic("FREE",      4)

-- Real-time FPS / Ping
local _fpsT = 0
local _fpsN = 0
RS.Heartbeat:Connect(function(dt)
    _fpsN = _fpsN + 1
    _fpsT = _fpsT + dt
    if _fpsT >= 0.5 then
        fpsVal.Text = tostring(math.floor(_fpsN / _fpsT))
        _fpsN = 0; _fpsT = 0
    end
    pcall(function()
        pingVal.Text = tostring(math.floor(LP:GetNetworkPing() * 1000)) .. "ms"
    end)
end)

-- ══════════════════════════════════════════════
-- BODY  (sidebar + content)
-- ══════════════════════════════════════════════
local BODY_Y = TH + SH

local body = Instance.new("Frame")
body.Name               = "Body"
body.Size               = UDim2.new(1, 0, 1, -BODY_Y)
body.Position           = UDim2.fromOffset(0, BODY_Y)
body.BackgroundTransparency = 1
body.BorderSizePixel    = 0
body.ClipsDescendants   = true
body.ZIndex             = 201
body.Parent             = win

-- ══════════════════════════════════════════════
-- SIDEBAR
-- ══════════════════════════════════════════════
local sidebar = Instance.new("Frame")
sidebar.Size               = UDim2.fromOffset(SIDE_W, WIN_H - BODY_Y)
sidebar.BackgroundColor3   = K.sidebar
sidebar.BackgroundTransparency = 0.08
sidebar.BorderSizePixel    = 0
sidebar.ClipsDescendants   = true
sidebar.ZIndex             = 202
sidebar.Parent             = body

local sideEdge = Instance.new("Frame")
sideEdge.Size             = UDim2.new(0, 1, 1, 0)
sideEdge.Position         = UDim2.new(1, -1, 0, 0)
sideEdge.BackgroundColor3 = K.sep
sideEdge.BorderSizePixel  = 0
sideEdge.ZIndex           = 203
sideEdge.Parent           = sidebar

-- ── Profile ──────────────────────────────────────────────
local profF = Instance.new("Frame")
profF.Size             = UDim2.new(1, 0, 0, 82)
profF.BackgroundColor3 = K.profileBG
profF.BackgroundTransparency = 0.15
profF.BorderSizePixel  = 0
profF.ZIndex           = 203
profF.Parent           = sidebar

local avRing = Instance.new("Frame")
avRing.Size             = UDim2.fromOffset(42, 42)
avRing.Position         = UDim2.new(0.5, -21, 0, 8)
avRing.BackgroundColor3 = K.white
avRing.BorderSizePixel  = 0
avRing.ZIndex           = 204
avRing.Parent           = profF
Instance.new("UICorner", avRing).CornerRadius = UDim.new(1, 0)

local avImg = Instance.new("ImageLabel")
avImg.Size               = UDim2.fromOffset(38, 38)
avImg.Position           = UDim2.fromOffset(2, 2)
avImg.BackgroundColor3   = K.card
avImg.BackgroundTransparency = 0
avImg.Image              = ""
avImg.ZIndex             = 205
avImg.Parent             = avRing
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    pcall(function()
        local img = Players:GetUserThumbnailAsync(
            LP.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        avImg.Image = img
    end)
end)

local dispLbl = Instance.new("TextLabel")
dispLbl.Size               = UDim2.new(1, -4, 0, 13)
dispLbl.Position           = UDim2.fromOffset(2, 54)
dispLbl.BackgroundTransparency = 1
dispLbl.Text               = LP.DisplayName
dispLbl.Font               = Enum.Font.GothamBold
dispLbl.TextSize           = 10
dispLbl.TextColor3         = K.textPri
dispLbl.TextXAlignment     = Enum.TextXAlignment.Center
dispLbl.TextTruncate       = Enum.TextTruncate.AtEnd
dispLbl.ZIndex             = 204
dispLbl.Parent             = profF

local userLbl = Instance.new("TextLabel")
userLbl.Size               = UDim2.new(1, -4, 0, 10)
userLbl.Position           = UDim2.fromOffset(2, 68)
userLbl.BackgroundTransparency = 1
userLbl.Text               = "@" .. LP.Name
userLbl.Font               = Enum.Font.Gotham
userLbl.TextSize           = 8
userLbl.TextColor3         = K.textSec
userLbl.TextXAlignment     = Enum.TextXAlignment.Center
userLbl.TextTruncate       = Enum.TextTruncate.AtEnd
userLbl.ZIndex             = 204
userLbl.Parent             = profF

local profSep = Instance.new("Frame")
profSep.Size             = UDim2.new(1, 0, 0, 1)
profSep.Position         = UDim2.new(0, 0, 1, -1)
profSep.BackgroundColor3 = K.sep
profSep.BorderSizePixel  = 0
profSep.ZIndex           = 204
profSep.Parent           = profF

-- ── Tab Buttons ──────────────────────────────────────────
local tabsF = Instance.new("Frame")
tabsF.Size               = UDim2.new(1, 0, 0, 148)
tabsF.Position           = UDim2.fromOffset(0, 82)
tabsF.BackgroundTransparency = 1
tabsF.BorderSizePixel    = 0
tabsF.ZIndex             = 203
tabsF.Parent             = sidebar

local tabsL = Instance.new("UIListLayout")
tabsL.SortOrder = Enum.SortOrder.LayoutOrder
tabsL.Padding   = UDim.new(0, 1)
tabsL.Parent    = tabsF

local tabsP = Instance.new("UIPadding")
tabsP.PaddingLeft   = UDim.new(0, 5)
tabsP.PaddingRight  = UDim.new(0, 5)
tabsP.PaddingTop    = UDim.new(0, 6)
tabsP.Parent        = tabsF

local TAB_DEFS = {
    {id="AutoKill", label="Auto Kill"},
    {id="Movement", label="Movement"},
    {id="Exploits", label="Exploits"},
    {id="Teleport", label="Teleport"},
}
local tabBtns   = {}
local tabPanels = {}
local activeTab = "AutoKill"

-- Forward declare for the header update
local cHeaderLbl

local function setActive(id)
    activeTab = id
    for _, def in ipairs(TAB_DEFS) do
        local btn = tabBtns[def.id]
        local pan = tabPanels[def.id]
        local on  = def.id == id
        if btn then
            TS:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3   = on and K.cardHov or K.winBG,
                BackgroundTransparency = on and 0 or 1,
                TextColor3         = on and K.textPri or K.textSec,
            }):Play()
            if btn:FindFirstChild("Acc") then
                btn.Acc.BackgroundTransparency = on and 0 or 1
            end
        end
        if pan then pan.Visible = on end
    end
    if cHeaderLbl then
        local labels = {AutoKill="Auto Kill", Movement="Movement", Exploits="Exploits", Teleport="Teleport"}
        cHeaderLbl.Text = labels[id] or id
    end
end

for i, def in ipairs(TAB_DEFS) do
    local id  = def.id
    local btn = Instance.new("TextButton")
    btn.Name               = "Tab_" .. id
    btn.Size               = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3   = K.winBG
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel    = 0
    btn.Text               = def.label
    btn.Font               = Enum.Font.GothamSemibold
    btn.TextSize           = 10
    btn.TextColor3         = K.textSec
    btn.TextXAlignment     = Enum.TextXAlignment.Left
    btn.LayoutOrder        = i
    btn.AutoButtonColor    = false   -- PREVENTS ROBLOX DEFAULT COLOR CHANGE
    btn.Selectable         = false   -- PREVENTS CURSOR / | BUG
    btn.ZIndex             = 204
    btn.Parent             = tabsF
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0, 22)
    bp.Parent      = btn

    local acc = Instance.new("Frame")
    acc.Name             = "Acc"
    acc.Size             = UDim2.fromOffset(2, 14)
    acc.Position         = UDim2.new(0, 7, 0.5, -7)
    acc.BackgroundColor3 = K.white
    acc.BackgroundTransparency = 1
    acc.BorderSizePixel  = 0
    acc.ZIndex           = 205
    acc.Parent           = btn
    Instance.new("UICorner", acc).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        pcall(function() UIS:ReleaseFocus() end)
        setActive(id)
    end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= id then
            TS:Create(btn, TweenInfo.new(0.10), {
                BackgroundTransparency = 0.65,
                TextColor3 = K.textPri,
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= id then
            TS:Create(btn, TweenInfo.new(0.10), {
                BackgroundTransparency = 1,
                TextColor3 = K.textSec,
            }):Play()
        end
    end)
    tabBtns[id] = btn
end

-- ── Social links ─────────────────────────────────────────
local socialF = Instance.new("Frame")
socialF.Size             = UDim2.new(1, 0, 0, 58)
socialF.Position         = UDim2.new(0, 0, 1, -58)
socialF.BackgroundColor3 = K.profileBG
socialF.BackgroundTransparency = 0.15
socialF.BorderSizePixel  = 0
socialF.ZIndex           = 203
socialF.Parent           = sidebar

local ssep = Instance.new("Frame")
ssep.Size             = UDim2.new(1, 0, 0, 1)
ssep.BackgroundColor3 = K.sep
ssep.BorderSizePixel  = 0
ssep.ZIndex           = 204
ssep.Parent           = socialF

local function makeSocBtn(txt, yOff)
    local b = Instance.new("TextButton")
    b.Size               = UDim2.new(1, -10, 0, 20)
    b.Position           = UDim2.fromOffset(5, yOff)
    b.BackgroundColor3   = K.btnBG
    b.BackgroundTransparency = 0
    b.BorderSizePixel    = 0
    b.Text               = txt
    b.Font               = Enum.Font.GothamBold
    b.TextSize           = 8
    b.TextColor3         = K.textPri
    b.AutoButtonColor    = false
    b.Selectable         = false
    b.ZIndex             = 204
    b.Parent             = socialF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke", b)
    bs.Color = K.border; bs.Thickness = 1
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = K.btnHov}):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.10), {BackgroundColor3 = K.btnBG}):Play()
    end)
    return b
end

local webBtn = makeSocBtn("My Website", 7)
webBtn.MouseButton1Click:Connect(function()
    pcall(function() UIS:ReleaseFocus() end)
    pcall(function() setclipboard("https://anonymous9x-site.pages.dev/") end)
    pcall(function() SG:SetCore("SendNotification",
        {Title="A9X", Text="Website URL copied!", Duration=3}) end)
end)

local ytBtn = makeSocBtn("YouTube  @anonymous9xch", 31)
ytBtn.MouseButton1Click:Connect(function()
    pcall(function() UIS:ReleaseFocus() end)
    pcall(function() setclipboard("https://youtube.com/@anonymous9xch") end)
    pcall(function() SG:SetCore("SendNotification",
        {Title="A9X", Text="YouTube URL copied!", Duration=3}) end)
end)

-- ══════════════════════════════════════════════
-- CONTENT AREA
-- ══════════════════════════════════════════════
local cArea = Instance.new("Frame")
cArea.Name               = "Content"
cArea.Size               = UDim2.new(1, -SIDE_W, 1, 0)
cArea.Position           = UDim2.fromOffset(SIDE_W, 0)
cArea.BackgroundColor3   = K.content
cArea.BackgroundTransparency = 0.08
cArea.BorderSizePixel    = 0
cArea.ClipsDescendants   = true
cArea.ZIndex             = 202
cArea.Parent             = body

-- Content header strip
local cHead = Instance.new("Frame")
cHead.Size             = UDim2.new(1, 0, 0, 28)
cHead.BackgroundColor3 = K.titleBG
cHead.BackgroundTransparency = 0.10
cHead.BorderSizePixel  = 0
cHead.ZIndex           = 203
cHead.Parent           = cArea

local chSep = Instance.new("Frame")
chSep.Size             = UDim2.new(1, 0, 0, 1)
chSep.Position         = UDim2.new(0, 0, 1, -1)
chSep.BackgroundColor3 = K.sep
chSep.BorderSizePixel  = 0
chSep.ZIndex           = 204
chSep.Parent           = cHead

cHeaderLbl = Instance.new("TextLabel")
cHeaderLbl.Size               = UDim2.new(1, -14, 1, 0)
cHeaderLbl.Position           = UDim2.fromOffset(12, 0)
cHeaderLbl.BackgroundTransparency = 1
cHeaderLbl.Text               = "Auto Kill"
cHeaderLbl.Font               = Enum.Font.GothamBold
cHeaderLbl.TextSize           = 10
cHeaderLbl.TextColor3         = K.textPri
cHeaderLbl.TextXAlignment     = Enum.TextXAlignment.Left
cHeaderLbl.ZIndex             = 204
cHeaderLbl.Parent             = cHead

-- ══════════════════════════════════════════════
-- UI COMPONENT LIBRARY
-- ══════════════════════════════════════════════

local function makeTabPanel(id)
    local s = Instance.new("ScrollingFrame")
    s.Name                 = "P_" .. id
    s.Size                 = UDim2.new(1, 0, 1, -28)
    s.Position             = UDim2.fromOffset(0, 28)
    s.BackgroundTransparency = 1
    s.BorderSizePixel      = 0
    s.ScrollBarThickness   = 2
    s.ScrollBarImageColor3 = Color3.fromRGB(65, 65, 82)
    s.ScrollingDirection   = Enum.ScrollingDirection.Y
    s.CanvasSize           = UDim2.fromOffset(0, 0)
    s.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    s.Visible              = false
    s.ZIndex               = 203
    s.Parent               = cArea
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, 3)
    l.Parent    = s
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,7); p.PaddingRight  = UDim.new(0,7)
    p.PaddingTop  = UDim.new(0,7); p.PaddingBottom = UDim.new(0,7)
    p.Parent = s
    tabPanels[id] = s
    return s
end

local function mkSection(parent, title, order)
    local f = Instance.new("Frame")
    f.Size               = UDim2.new(1,0,0,20)
    f.BackgroundTransparency = 1
    f.LayoutOrder        = order
    f.ZIndex             = 204
    f.Parent             = parent
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text               = title:upper()
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 8
    l.TextColor3         = K.secLbl
    l.TextXAlignment     = Enum.TextXAlignment.Left
    l.ZIndex             = 205
    l.Parent             = f
    local ln = Instance.new("Frame")
    ln.Size             = UDim2.new(1,0,0,1)
    ln.Position         = UDim2.new(0,0,1,-1)
    ln.BackgroundColor3 = K.sep
    ln.BorderSizePixel  = 0
    ln.ZIndex           = 205
    ln.Parent           = f
    return f
end

local function mkToggle(parent, opts)
    local h = opts.sub and 44 or 32
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,h)
    card.BackgroundColor3   = K.card
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.order
    card.ZIndex             = 204
    card.Parent             = parent
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,6)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(1,-48,0,14)
    tl.Position           = UDim2.fromOffset(9, opts.sub and 6 or 9)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize           = 10
    tl.TextColor3         = K.textPri
    tl.TextXAlignment     = Enum.TextXAlignment.Left
    tl.ZIndex             = 205
    tl.Parent             = card
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-48,0,11)
        sl.Position           = UDim2.fromOffset(9,21)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize           = 8
        sl.TextColor3         = K.textSec
        sl.TextXAlignment     = Enum.TextXAlignment.Left
        sl.ZIndex             = 205
        sl.Parent             = card
    end
    local TW,TH2 = 30,16
    local track = Instance.new("Frame")
    track.Size             = UDim2.fromOffset(TW,TH2)
    track.Position         = UDim2.new(1,-(TW+8),0.5,-(TH2/2))
    track.BackgroundColor3 = opts.val and K.tOn or K.tOff
    track.BorderSizePixel  = 0
    track.ZIndex           = 205
    track.Parent           = card
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)
    local KS = TH2-4
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KS,KS)
    knob.Position         = opts.val and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = K.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 206
    knob.Parent           = track
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local value = opts.val or false
    local function setV(v)
        value = v
        TS:Create(track,TweenInfo.new(0.13,Enum.EasingStyle.Quad),{BackgroundColor3=v and K.tOn or K.tOff}):Play()
        TS:Create(knob, TweenInfo.new(0.13,Enum.EasingStyle.Quad),{Position=v and UDim2.fromOffset(TW-KS-2,2) or UDim2.fromOffset(2,2)}):Play()
        if opts.cb then opts.cb(v) end
    end
    local hit = Instance.new("TextButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Text               = ""
    hit.AutoButtonColor    = false
    hit.Selectable         = false
    hit.ZIndex             = 207
    hit.Parent             = card
    hit.MouseButton1Click:Connect(function() pcall(function() UIS:ReleaseFocus() end); setV(not value) end)
    hit.MouseEnter:Connect(function() TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=K.cardHov}):Play() end)
    hit.MouseLeave:Connect(function() TS:Create(card,TweenInfo.new(0.10),{BackgroundColor3=K.card}):Play() end)
    return card, setV
end

local function mkSlider(parent, opts)
    local step = opts.step or 1
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,46)
    card.BackgroundColor3   = K.card
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.order
    card.ZIndex             = 204
    card.Parent             = parent
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,6)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(0.58,0,0,13)
    tl.Position           = UDim2.fromOffset(9,7)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize           = 10
    tl.TextColor3         = K.textPri
    tl.TextXAlignment     = Enum.TextXAlignment.Left
    tl.ZIndex             = 205
    tl.Parent             = card
    local defStr = (step < 1) and string.format("%.1f", opts.def) or tostring(math.floor(opts.def))
    local vl = Instance.new("TextLabel")
    vl.Size               = UDim2.new(0.42,-9,0,13)
    vl.Position           = UDim2.new(0.58,0,0,7)
    vl.BackgroundTransparency = 1
    vl.Text               = defStr .. (opts.suf or "")
    vl.Font               = Enum.Font.GothamBold
    vl.TextSize           = 10
    vl.TextColor3         = K.textPri
    vl.TextXAlignment     = Enum.TextXAlignment.Right
    vl.ZIndex             = 205
    vl.Parent             = card
    local track = Instance.new("Frame")
    track.Name             = "Tr"
    track.Size             = UDim2.new(1,-18,0,4)
    track.Position         = UDim2.fromOffset(9,27)
    track.BackgroundColor3 = K.slTrack
    track.BorderSizePixel  = 0
    track.ZIndex           = 205
    track.Parent           = card
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)
    local rng = math.max(0.001, opts.max - opts.min)
    local pct = (opts.def - opts.min) / rng
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = K.slFill
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 206
    fill.Parent           = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local KD = 11
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(KD,KD)
    knob.Position         = UDim2.new(pct,-KD/2,0.5,-KD/2)
    knob.BackgroundColor3 = K.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 207
    knob.Parent           = track
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local value  = opts.def
    local isDrag = false
    local function updX(ax)
        local ta = track.AbsolutePosition
        local ts = track.AbsoluteSize
        if ts.X < 1 then return end
        local rel = math.clamp((ax - ta.X) / ts.X, 0, 1)
        value = math.floor((opts.min + rel * rng) / step + 0.5) * step
        value = math.clamp(value, opts.min, opts.max)
        local p = (value - opts.min) / rng
        fill.Size     = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-KD/2,0.5,-KD/2)
        local disp = (step < 1) and string.format("%.1f",value) or tostring(math.floor(value))
        vl.Text = disp .. (opts.suf or "")
        if opts.cb then opts.cb(value) end
    end
    local hit = Instance.new("TextButton")
    hit.Size               = UDim2.fromScale(1,1)
    hit.BackgroundTransparency = 1
    hit.Text               = ""
    hit.AutoButtonColor    = false
    hit.Selectable         = false
    hit.ZIndex             = 208
    hit.Parent             = track
    hit.MouseButton1Down:Connect(function(x,_) isDrag=true; updX(x) end)
    hit.TouchLongPress:Connect(function() isDrag=true end)
    hit.TouchPan:Connect(function(_,pos,_) if isDrag and pos[1] then updX(pos[1].X) end end)
    UIS.InputChanged:Connect(function(inp)
        if not isDrag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then updX(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then isDrag=false end
    end)
    return card
end

local function mkDropdown(parent, opts)
    local IH   = 24
    local listH = #opts.options * IH + 4
    local card = Instance.new("Frame")
    card.Size               = UDim2.new(1,0,0,36)
    card.BackgroundColor3   = K.card
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel    = 0
    card.LayoutOrder        = opts.order
    card.ClipsDescendants   = false
    card.ZIndex             = 210
    card.Parent             = parent
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,6)
    local tl = Instance.new("TextLabel")
    tl.Size               = UDim2.new(0.44,0,0,13)
    tl.Position           = UDim2.fromOffset(9,11)
    tl.BackgroundTransparency = 1
    tl.Text               = opts.title
    tl.Font               = Enum.Font.GothamSemibold
    tl.TextSize           = 10
    tl.TextColor3         = K.textPri
    tl.TextXAlignment     = Enum.TextXAlignment.Left
    tl.ZIndex             = 211
    tl.Parent             = card
    local selBtn = Instance.new("TextButton")
    selBtn.Size               = UDim2.new(0.55,-6,0,22)
    selBtn.Position           = UDim2.new(0.45,0,0.5,-11)
    selBtn.BackgroundColor3   = Color3.fromRGB(18,18,24)
    selBtn.BackgroundTransparency = 0
    selBtn.BorderSizePixel    = 0
    selBtn.Text               = opts.def or opts.options[1]
    selBtn.Font               = Enum.Font.GothamSemibold
    selBtn.TextSize           = 9
    selBtn.TextColor3         = K.textPri
    selBtn.AutoButtonColor    = false
    selBtn.Selectable         = false
    selBtn.ZIndex             = 211
    selBtn.Parent             = card
    Instance.new("UICorner",selBtn).CornerRadius = UDim.new(0,5)
    local sbS = Instance.new("UIStroke",selBtn)
    sbS.Color = K.border; sbS.Thickness = 1
    local chev = Instance.new("TextLabel")
    chev.Size               = UDim2.fromOffset(12,22)
    chev.Position           = UDim2.new(1,-14,0,0)
    chev.BackgroundTransparency = 1
    chev.Text               = "v"
    chev.Font               = Enum.Font.GothamBold
    chev.TextSize           = 7
    chev.TextColor3         = K.textSec
    chev.ZIndex             = 212
    chev.Parent             = selBtn
    local dropL = Instance.new("Frame")
    dropL.Size             = UDim2.fromOffset(10, listH)
    dropL.Position         = UDim2.new(selBtn.Position.X.Scale, selBtn.Position.X.Offset, 1, 2)
    dropL.BackgroundColor3 = Color3.fromRGB(18,18,24)
    dropL.BackgroundTransparency = 0
    dropL.BorderSizePixel  = 0
    dropL.Visible          = false
    dropL.ZIndex           = 220
    dropL.Parent           = card
    Instance.new("UICorner",dropL).CornerRadius = UDim.new(0,6)
    local dlS = Instance.new("UIStroke",dropL)
    dlS.Color = K.border; dlS.Thickness = 1
    local dlL = Instance.new("UIListLayout")
    dlL.SortOrder = Enum.SortOrder.LayoutOrder; dlL.Parent = dropL
    local dlP = Instance.new("UIPadding")
    dlP.PaddingTop=UDim.new(0,2); dlP.PaddingBottom=UDim.new(0,2)
    dlP.PaddingLeft=UDim.new(0,2); dlP.PaddingRight=UDim.new(0,2)
    dlP.Parent = dropL
    local isOpen = false
    local selected = opts.def or opts.options[1]
    local function closeDD() isOpen=false; dropL.Visible=false end
    local function openDD()
        local sw = selBtn.AbsoluteSize.X
        dropL.Size = UDim2.fromOffset(math.max(sw, 80), listH)
        isOpen=true; dropL.Visible=true
    end
    for i, opt in ipairs(opts.options) do
        local o   = opt
        local itm = Instance.new("TextButton")
        itm.Size               = UDim2.new(1,0,0,IH)
        itm.BackgroundColor3   = Color3.fromRGB(18,18,24)
        itm.BackgroundTransparency = 0
        itm.BorderSizePixel    = 0
        itm.Text               = o
        itm.Font               = Enum.Font.GothamSemibold
        itm.TextSize           = 9
        itm.TextColor3         = K.textPri
        itm.LayoutOrder        = i
        itm.AutoButtonColor    = false
        itm.Selectable         = false
        itm.ZIndex             = 221
        itm.Parent             = dropL
        Instance.new("UICorner",itm).CornerRadius = UDim.new(0,4)
        local ip = Instance.new("UIPadding"); ip.PaddingLeft=UDim.new(0,7); ip.Parent=itm
        itm.MouseEnter:Connect(function() itm.BackgroundColor3=K.cardHov end)
        itm.MouseLeave:Connect(function() itm.BackgroundColor3=Color3.fromRGB(18,18,24) end)
        itm.MouseButton1Click:Connect(function()
            pcall(function() UIS:ReleaseFocus() end)
            selected=o; selBtn.Text=o; closeDD()
            if opts.cb then opts.cb(o) end
        end)
    end
    selBtn.MouseButton1Click:Connect(function()
        pcall(function() UIS:ReleaseFocus() end)
        if isOpen then closeDD() else openDD() end
    end)
    return card, function() return selected end
end

local function mkButton(parent, opts)
    local h = opts.sub and 42 or 30
    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1,0,0,h)
    btn.BackgroundColor3   = K.btnBG
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel    = 0
    btn.Text               = ""
    btn.LayoutOrder        = opts.order
    btn.AutoButtonColor    = false
    btn.Selectable         = false
    btn.ZIndex             = 204
    btn.Parent             = parent
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke",btn)
    bS.Color = K.border; bS.Thickness = 1
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,-12,0,14)
    lbl.Position           = UDim2.fromOffset(9, opts.sub and 6 or 8)
    lbl.BackgroundTransparency = 1
    lbl.Text               = opts.title
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 10
    lbl.TextColor3         = K.textPri
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 205
    lbl.Parent             = btn
    if opts.sub then
        local sl = Instance.new("TextLabel")
        sl.Size               = UDim2.new(1,-12,0,10)
        sl.Position           = UDim2.fromOffset(9,23)
        sl.BackgroundTransparency = 1
        sl.Text               = opts.sub
        sl.Font               = Enum.Font.Gotham
        sl.TextSize           = 8
        sl.TextColor3         = K.textSec
        sl.TextXAlignment     = Enum.TextXAlignment.Left
        sl.ZIndex             = 205
        sl.Parent             = btn
    end
    btn.MouseButton1Click:Connect(function()
        pcall(function() UIS:ReleaseFocus() end)
        TS:Create(btn,TweenInfo.new(0.07),{BackgroundColor3=K.btnPre}):Play()
        task.delay(0.14,function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=K.btnBG}):Play() end)
        if opts.cb then opts.cb() end
    end)
    btn.MouseEnter:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=K.btnHov}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn,TweenInfo.new(0.10),{BackgroundColor3=K.btnBG}):Play() end)
    return btn
end

local function mkDiv(parent, order)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = K.sep
    f.BackgroundTransparency = 0.35
    f.BorderSizePixel  = 0
    f.LayoutOrder      = order
    f.ZIndex           = 204
    f.Parent           = parent
    return f
end

-- ══════════════════════════════════════════════
-- BUILD PANELS
-- ══════════════════════════════════════════════
for _, def in ipairs(TAB_DEFS) do makeTabPanel(def.id) end

-- ── AUTO KILL ────────────────────────────────
local ak = tabPanels["AutoKill"]
local _o = 0; local function o() _o=_o+1; return _o end

mkSection(ak, "Target", o())
mkDropdown(ak, {title="Select Target", options=playerNames(), def="None", order=o(), cb=function(v)
    S.target = (v=="None") and nil or Players:FindFirstChild(v)
end})

mkSection(ak, "Follow Mode", o())
mkDropdown(ak, {title="Mode", options={"HEAD","ORBIT","FEET"}, def="HEAD", order=o(), cb=function(v)
    S.followMode=v; _orbit=0
end})
mkSlider(ak, {title="Stud Distance", min=1, max=20, def=3,  suf=" st", step=0.5, order=o(), cb=function(v) S.studDist=v end})
mkSlider(ak, {title="Follow Speed",  min=5, max=100,def=20, suf="",   step=1,   order=o(), cb=function(v) S.followSpeed=v end})

mkSection(ak, "Auto Attack", o())
mkToggle(ak, {title="Auto Tap", sub="Tap attack buttons automatically", val=false, order=o(), cb=function(v)
    S.autoTapOn=v
    if v and not autoTapAlive then autoTapAlive=true; task.spawn(tapLoop)
    else autoTapAlive=false end
end})
mkSlider(ak, {title="Tap Delay", min=0.05, max=2, def=0.2, suf="s", step=0.05, order=o(), cb=function(v) S.tapDelay=v end})
mkDropdown(ak, {title="Attack Skill", options={"Pukulan Biasa","Pukulan Berurutan","Dorong","Uppercut"}, def="Pukulan Biasa", order=o(), cb=function(v) S.tapSkill=v end})

mkSection(ak, "Actions", o())
mkToggle(ak, {title="Follow Target", sub="Stick to selected target", val=false, order=o(), cb=function(v)
    S.followOn=v; if not v then pcall(function() Cam.CameraType=Enum.CameraType.Custom end) end
end})
mkToggle(ak, {title="Solo Hacker", sub="Follow all players", val=false, order=o(), cb=function(v) S.soloHacker=v end})
mkToggle(ak, {title="Drag Hold", sub="Pull targets to your position", val=false, order=o(), cb=function(v) S.dragHold=v end})
mkToggle(ak, {title="Cam Lock", sub="Camera locks onto target", val=false, order=o(), cb=function(v)
    S.camLock=v; if not v then pcall(function() Cam.CameraType=Enum.CameraType.Custom end) end
end})
mkSlider(ak, {title="Cam Distance", min=5, max=80, def=12, suf=" st", step=1, order=o(), cb=function(v)
    S.camDist=v; pcall(function() LP.CameraMaxZoomDistance=v; LP.CameraMinZoomDistance=v end)
end})
mkToggle(ak, {title="Anti Void", sub="Rescue if character falls below -250Y", val=false, order=o(), cb=function(v) S.antiVoid=v end})

mkDiv(ak, o())
mkButton(ak, {title="Stop All Combat", sub="Disable every follow and lock feature", order=o(), cb=function()
    S.followOn=false; S.soloHacker=false; S.dragHold=false
    S.camLock=false; S.antiVoid=false; S.target=nil
    pcall(function() Cam.CameraType=Enum.CameraType.Custom end)
end})
mkButton(ak, {title="Teleport to Target", order=o(), cb=function()
    if not S.target then return end
    local c=S.target.Character; local tH=c and c:FindFirstChild("HumanoidRootPart")
    if tH and hrp then pcall(function() hrp.CFrame=tH.CFrame+Vector3.new(3,0,0) end) end
end})

-- ── MOVEMENT ─────────────────────────────────
local mv = tabPanels["Movement"]
local _m = 0; local function m() _m=_m+1; return _m end

mkSection(mv, "Speed", m())
mkToggle(mv, {title="Speed Boost", sub="TP-walk in move direction", val=false, order=m(), cb=function(v) S.speedOn=v end})
mkSlider(mv, {title="Boost Value", min=0.1, max=10, def=1.5, suf="x", step=0.1, order=m(), cb=function(v) S.speedVal=v end})
mkToggle(mv, {title="Walkspeed Lock", sub="Force Humanoid.WalkSpeed", val=false, order=m(), cb=function(v)
    S.wsOn=v; if not v and hum then pcall(function() hum.WalkSpeed=16 end) end
end})
mkSlider(mv, {title="Walkspeed", min=0, max=500, def=16, suf="", step=1, order=m(), cb=function(v)
    S.walkspeed=v; if hum then pcall(function() hum.WalkSpeed=v end) end
end})

mkSection(mv, "Jump", m())
mkToggle(mv, {title="Jump Boost", sub="Override jump height", val=false, order=m(), cb=function(v)
    S.jumpOn=v; if hum then pcall(function() hum.UseJumpPower=not v end) end
end})
mkSlider(mv, {title="Jump Height", min=7, max=500, def=50, suf="", step=1, order=m(), cb=function(v)
    S.jumpVal=v; if hum then pcall(function() hum.JumpHeight=v end) end
end})

mkSection(mv, "World", m())
mkSlider(mv, {title="Gravity",    min=0,  max=200, def=196,step=1, order=m(), cb=function(v) pcall(function() workspace.Gravity=v end) end})
mkSlider(mv, {title="Field of View", min=30, max=120, def=70, step=1, order=m(), cb=function(v) pcall(function() Cam.FieldOfView=v end) end})

mkDiv(mv, m())
mkButton(mv, {title="Reset All Movement", order=m(), cb=function()
    S.speedOn=false; S.wsOn=false; S.jumpOn=false
    if hum then pcall(function() hum.WalkSpeed=16; hum.JumpHeight=7.2; hum.UseJumpPower=false end) end
    pcall(function() workspace.Gravity=196.2; Cam.FieldOfView=70 end)
end})

-- ── EXPLOITS ─────────────────────────────────
local ex = tabPanels["Exploits"]
local _e = 0; local function e() _e=_e+1; return _e end

mkSection(ex, "TSB Attributes", e())
mkToggle(ex, {title="No Dash Cooldown", sub="workspace NoDashCooldown = true", val=false, order=e(), cb=function(v)
    S.noDashCD=v; pcall(function() workspace:SetAttribute("NoDashCooldown",v) end)
end})
mkToggle(ex, {title="No Fatigue", sub="workspace NoFatigue = true", val=false, order=e(), cb=function(v)
    S.noFatigue=v; pcall(function() workspace:SetAttribute("NoFatigue",v) end)
end})

mkSection(ex, "Emotes", e())
mkToggle(ex, {title="Extra Emote Slots", sub="LocalPlayer ExtraSlots = true", val=false, order=e(), cb=function(v)
    S.extraSlots=v; pcall(function() LP:SetAttribute("ExtraSlots",v) end)
end})
mkToggle(ex, {title="Emote Search Bar", sub="LocalPlayer EmoteSearchBar = true", val=false, order=e(), cb=function(v)
    S.emoteSearch=v; pcall(function() LP:SetAttribute("EmoteSearchBar",v) end)
end})

mkSection(ex, "Server", e())
mkButton(ex, {title="Spoof VIP Owner", sub="Sets VIPServer to your UserId", order=e(), cb=function()
    pcall(function() workspace:SetAttribute("VIPServer",tostring(LP.UserId)); workspace:SetAttribute("VIPServerOwner",LP.Name) end)
end})
mkButton(ex, {title="Apply All Attributes", order=e(), cb=function()
    initTSB()
    pcall(function() workspace:SetAttribute("NoDashCooldown",S.noDashCD); workspace:SetAttribute("NoFatigue",S.noFatigue) end)
    pcall(function() LP:SetAttribute("ExtraSlots",S.extraSlots); LP:SetAttribute("EmoteSearchBar",S.emoteSearch) end)
end})

-- ── TELEPORT ─────────────────────────────────
local tp = tabPanels["Teleport"]
local _t = 0; local function t() _t=_t+1; return _t end

mkSection(tp, "Map Locations", t())
local LOCS = {
    {"Middle",             CFrame.new(148,441,27)},
    {"Atomic Room",        CFrame.new(1079,155,23003)},
    {"Death Counter Room", CFrame.new(-92,29,20347)},
    {"Baseplate",          CFrame.new(968,20,23088)},
    {"Mountain 1",         CFrame.new(266,699,458)},
    {"Mountain 2",         CFrame.new(551,630,-265)},
    {"Mountain 3",         CFrame.new(-107,642,-328)},
}
for _, loc in ipairs(LOCS) do
    local cf = loc[2]
    mkButton(tp, {title=loc[1], order=t(), cb=function()
        if hrp then pcall(function() hrp.CFrame=cf end) end
    end})
end

mkSection(tp, "Player Teleport", t())
mkButton(tp, {title="Teleport to Target", sub="Select target in Auto Kill tab first", order=t(), cb=function()
    if not S.target then return end
    local c=S.target.Character; local tH=c and c:FindFirstChild("HumanoidRootPart")
    if tH and hrp then pcall(function() hrp.CFrame=tH.CFrame+Vector3.new(3,0,0) end) end
end})
mkButton(tp, {title="Bring Target to Me", order=t(), cb=function()
    if not S.target or not hrp then return end
    local c=S.target.Character; local tH=c and c:FindFirstChild("HumanoidRootPart")
    if tH then pcall(function() tH.CFrame=hrp.CFrame+Vector3.new(2,0,0) end) end
end})

-- ══════════════════════════════════════════════
-- DRAG  (title bar only, not sidebar or content)
-- ══════════════════════════════════════════════
do
    local drag=false; local tRef=nil; local sP=nil; local sW=nil

    local function inCtrl(px)
        local ax = titlebar.AbsolutePosition.X
        local aw = titlebar.AbsoluteSize.X
        return px > ax + aw - 62
    end

    titlebar.InputBegan:Connect(function(inp)
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isT or isM) then return end
        if inCtrl(inp.Position.X) then return end
        drag=true; tRef=inp
        sP = Vector2.new(inp.Position.X, inp.Position.Y)
        sW = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        local isT = inp.UserInputType == Enum.UserInputType.Touch
        local isM = inp.UserInputType == Enum.UserInputType.MouseMove
        if not (isT or isM) then return end
        if isT and inp ~= tRef then return end
        local d   = Vector2.new(inp.Position.X, inp.Position.Y) - sP
        local vp2 = Cam.ViewportSize
        win.Position = UDim2.fromOffset(
            math.clamp(sW.X + d.X, 0, vp2.X - WIN_W),
            math.clamp(sW.Y + d.Y, 0, vp2.Y - WIN_H)
        )
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp == tRef or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=false; tRef=nil
        end
    end)
end

-- ══════════════════════════════════════════════
-- FLOAT ICON  (appears when minimized)
-- ══════════════════════════════════════════════
local floatF = Instance.new("Frame")
floatF.Name               = "FloatIcon"
floatF.Size               = UDim2.fromOffset(48, 48)
floatF.BackgroundColor3   = Color3.fromRGB(10, 10, 13)
floatF.BackgroundTransparency = 0
floatF.BorderSizePixel    = 0
floatF.Visible            = false
floatF.ZIndex             = 600
floatF.Parent             = root
Instance.new("UICorner", floatF).CornerRadius = UDim.new(0, 10)

local fiS = Instance.new("UIStroke", floatF)
fiS.Color = K.white; fiS.Thickness = 1.3

local fiImg = Instance.new("ImageLabel")
fiImg.Size               = UDim2.fromOffset(42, 42)
fiImg.Position           = UDim2.fromOffset(3, 3)
fiImg.BackgroundTransparency = 1
fiImg.Image              = ""
fiImg.ZIndex             = 601
fiImg.Parent             = floatF
Instance.new("UICorner", fiImg).CornerRadius = UDim.new(0, 8)

task.spawn(function()
    pcall(function()
        local img = Players:GetUserThumbnailAsync(
            97269958324726,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        fiImg.Image = img
    end)
end)

local function anchorFloat()
    local vp2 = Cam.ViewportSize
    if vp2.X < 10 then vp2 = Vector2.new(800, 600) end
    floatF.Position = UDim2.fromOffset(vp2.X - 60, math.floor(vp2.Y/2) - 24)
end
anchorFloat()

local fiBtn = Instance.new("TextButton")
fiBtn.Size               = UDim2.fromScale(1, 1)
fiBtn.BackgroundTransparency = 1
fiBtn.Text               = ""
fiBtn.AutoButtonColor    = false
fiBtn.Selectable         = false
fiBtn.ZIndex             = 602
fiBtn.Parent             = floatF

fiBtn.MouseButton1Click:Connect(function()
    pcall(function() UIS:ReleaseFocus() end)
    floatF.Visible = false
    win.Visible    = true
    minBtn.Text    = "−"
end)

fiBtn.MouseEnter:Connect(function()
    TS:Create(floatF, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    }):Play()
end)
fiBtn.MouseLeave:Connect(function()
    TS:Create(floatF, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    }):Play()
end)

-- ══════════════════════════════════════════════
-- MINIMIZE / CLOSE
-- ══════════════════════════════════════════════
minBtn.MouseButton1Click:Connect(function()
    pcall(function() UIS:ReleaseFocus() end)
    win.Visible = false
    anchorFloat()
    floatF.Visible = true
    minBtn.Text    = "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    pcall(function() UIS:ReleaseFocus() end)
    pcall(function() root:Destroy() end)
    pcall(function() Cam.CameraType = Enum.CameraType.Custom end)
end)

-- ══════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════
setActive("AutoKill")

task.spawn(function()
    task.wait(1.8)
    pcall(function()
        dispLbl.Text = LP.DisplayName
        userLbl.Text = "@" .. LP.Name
    end)
end)

task.spawn(function()
    task.wait(2.8)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title    = "Anonymous9x TSB Strong",
            Text     = "v5.0 Ready  |  All systems online",
            Duration = 4,
        })
    end)
end)

-- END
