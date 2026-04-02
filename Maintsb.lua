-- ============================================================================
-- Anonymous9x TSB Strong — v1.0 FIXED
-- The Strongest Battlegrounds | Full Feature Script
-- By Anonymous9x
-- ============================================================================
-- Fix: UI drag system now works, no black screen
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================================
-- CHARACTER MANAGEMENT
-- ============================================================================
local char, hum, hrp
local function linkCharacter(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10) or c:FindFirstChildOfClass("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart", 10) or c:FindFirstChild("HumanoidRootPart")
end
if LocalPlayer.Character then linkCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(linkCharacter)

-- ============================================================================
-- TSB ATTRIBUTE INIT
-- ============================================================================
local function initTSBAttributes()
    local uid = tostring(LocalPlayer.UserId)
    local name = LocalPlayer.Name
    pcall(function() workspace:SetAttribute("VIPServer", uid) end)
    pcall(function() workspace:SetAttribute("VIPServerOwner", name) end)
    pcall(function()
        if LocalPlayer:GetAttribute("ExtraSlots") == nil then LocalPlayer:SetAttribute("ExtraSlots", false) end
        if LocalPlayer:GetAttribute("EmoteSearchBar") == nil then LocalPlayer:SetAttribute("EmoteSearchBar", false) end
        if workspace:GetAttribute("NoDashCooldown") == nil then workspace:SetAttribute("NoDashCooldown", false) end
        if workspace:GetAttribute("NoFatigue") == nil then workspace:SetAttribute("NoFatigue", false) end
    end)
end
initTSBAttributes()

-- ============================================================================
-- GLOBAL STATE
-- ============================================================================
local State = {
    followOn = false,
    soloHacker = false,
    dragHold = false,
    camLock = false,
    antiVoid = false,
    followMode = "HEAD",
    studDist = 3,
    followSpeed = 20,
    camDist = 12,
    target = nil,
    speedOn = false,
    speedVal = 1.5,
    jumpOn = false,
    jumpVal = 50,
    walkspeed = 16,
    wsOn = false,
    noDashCD = false,
    noFatigue = false,
    extraSlots = false,
    emoteSearch = false,
}
local _orbitAngle = 0

-- ============================================================================
-- HELPERS
-- ============================================================================
local function getTargetHRP()
    if not State.target then return nil end
    local c = State.target.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getTargetHead()
    if not State.target then return nil end
    local c = State.target.Character
    return c and c:FindFirstChild("Head")
end

local function getAllEnemies()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then table.insert(list, {player = p, hrp = h}) end
        end
    end
    return list
end

local function getPlayerNames()
    local names = {"— None —"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

-- ============================================================================
-- COMBAT ENGINE (RunService.Heartbeat)
-- ============================================================================
RunService.Heartbeat:Connect(function(dt)
    if not hrp or not char then return end

    if State.speedOn and hum then
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            pcall(function() hrp.CFrame = hrp.CFrame + (dir * State.speedVal) end)
        end
    end

    if State.wsOn and hum then
        pcall(function() if hum.WalkSpeed ~= State.walkspeed then hum.WalkSpeed = State.walkspeed end end)
    end

    if State.jumpOn and hum then
        pcall(function() hum.JumpHeight = State.jumpVal end)
    end

    if State.antiVoid and hrp.Position.Y < -250 then
        pcall(function() hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z) end)
    end

    local targets = {}
    if State.soloHacker then
        targets = getAllEnemies()
    elseif State.followOn and State.target then
        local tHRP = getTargetHRP()
        if tHRP then table.insert(targets, {player = State.target, hrp = tHRP}) end
    end

    if #targets > 0 then
        local primary = targets[1]
        local tHRP = primary.hrp
        local tPos = tHRP.Position
        local dist = State.studDist
        local newCF = nil
        if State.followMode == "ORBIT" then
            _orbitAngle = _orbitAngle + dt * (State.followSpeed * 0.12)
            local ox = math.cos(_orbitAngle) * dist
            local oz = math.sin(_orbitAngle) * dist
            local orbPos = Vector3.new(tPos.X + ox, tPos.Y, tPos.Z + oz)
            newCF = CFrame.lookAt(orbPos, tPos)
        elseif State.followMode == "HEAD" then
            local head = getTargetHead()
            local headY = head and head.Position.Y or (tPos.Y + 2.5)
            local look = tHRP.CFrame.LookVector.Unit
            newCF = CFrame.lookAt(Vector3.new(tPos.X, headY, tPos.Z) + (look * dist), Vector3.new(tPos.X, headY, tPos.Z))
        elseif State.followMode == "FEET" then
            local look = tHRP.CFrame.LookVector.Unit
            local feetY = tPos.Y - 2.5
            newCF = CFrame.lookAt(Vector3.new(tPos.X + look.X * dist, feetY, tPos.Z + look.Z * dist), Vector3.new(tPos.X, feetY, tPos.Z))
        end
        if newCF then pcall(function() hrp.CFrame = newCF end) end

        if State.dragHold then
            for _, entry in ipairs(targets) do
                pcall(function()
                    local offset = Vector3.new(math.random(-1,1)*0.5, 0.3, math.random(-1,1)*0.5)
                    entry.hrp.CFrame = CFrame.new(hrp.Position + offset)
                end)
            end
        end
    end

    if State.camLock and State.target then
        local tHead = getTargetHead()
        local tHRP = getTargetHRP()
        local lookAt = tHead and tHead.Position or (tHRP and tHRP.Position)
        if lookAt then
            pcall(function()
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, lookAt)
            end)
        end
    end
end)

-- ============================================================================
-- UI THEME
-- ============================================================================
local T = {
    bg = Color3.fromRGB(14, 14, 18),
    sidebar = Color3.fromRGB(20, 20, 26),
    content = Color3.fromRGB(16, 16, 21),
    titlebar = Color3.fromRGB(11, 11, 15),
    card = Color3.fromRGB(26, 26, 34),
    cardHover = Color3.fromRGB(32, 32, 42),
    separator = Color3.fromRGB(34, 34, 44),
    textPrimary = Color3.fromRGB(228, 228, 235),
    textSec = Color3.fromRGB(145, 145, 165),
    textDim = Color3.fromRGB(90, 90, 110),
    textSection = Color3.fromRGB(99, 102, 241),
    accent = Color3.fromRGB(99, 102, 241),
    accentDim = Color3.fromRGB(65, 68, 200),
    accentBright = Color3.fromRGB(138,141, 255),
    toggleOn = Color3.fromRGB(99, 102, 241),
    toggleOff = Color3.fromRGB(52, 52, 68),
    toggleKnob = Color3.new(1,1,1),
    sliderFill = Color3.fromRGB(99, 102, 241),
    sliderTrack = Color3.fromRGB(42, 42, 58),
    sliderKnob = Color3.new(1,1,1),
    btnPrimary = Color3.fromRGB(99, 102, 241),
    btnDanger = Color3.fromRGB(210, 55, 55),
    btnNeutral = Color3.fromRGB(36, 36, 48),
    btnSuccess = Color3.fromRGB(52, 168, 100),
    profileBG = Color3.fromRGB(22, 22, 30),
    avatarBorder = Color3.fromRGB(99, 102, 241),
    dropBG = Color3.fromRGB(24, 24, 32),
    dropItem = Color3.fromRGB(30, 30, 40),
    dropHover = Color3.fromRGB(38, 38, 52),
    tabActive = Color3.fromRGB(30, 30, 42),
    tabInactive = Color3.fromRGB(20, 20, 26),
    white = Color3.new(1,1,1),
    youtube = Color3.fromRGB(255, 0, 0),
    shadow = Color3.fromRGB(0,0,0),
}

local D = {
    winW = 560,
    winH = 440,
    sideW = 158,
    titleH = 44,
    padX = 10,
    padY = 10,
    elemH = 36,
    sectionH = 24,
    corner = UDim.new(0, 8),
    cornerSm = UDim.new(0, 5),
    cornerPill = UDim.new(1,0),
}

-- ============================================================================
-- SCREEN GUI ROOT
-- ============================================================================
pcall(function() game.CoreGui:FindFirstChild("__A9xTSBStrong"):Destroy() end)
local root = Instance.new("ScreenGui")
root.Name = "__A9xTSBStrong"
root.DisplayOrder = 1000
root.ResetOnSpawn = false
root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
root.IgnoreGuiInset = true
pcall(function() root.Parent = game.CoreGui end)
if not root.Parent then root.Parent = LocalPlayer.PlayerGui end

-- ============================================================================
-- WINDOW FRAME
-- ============================================================================
local vp = Camera.ViewportSize
if vp.X == 0 or vp.Y == 0 then task.wait(0.1) vp = Camera.ViewportSize end
local wX = math.max(0, math.floor((vp.X - D.winW) / 2))
local wY = math.max(0, math.floor((vp.Y - D.winH) / 2))

local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.fromOffset(D.winW, D.winH)
win.Position = UDim2.fromOffset(wX, wY)
win.BackgroundColor3 = T.bg
win.BackgroundTransparency = 0
win.BorderSizePixel = 0
win.ClipsDescendants = false
win.ZIndex = 10
win.Parent = root
Instance.new("UICorner", win).CornerRadius = D.corner

local winBorder = Instance.new("UIStroke")
winBorder.Color = Color3.fromRGB(40,40,56)
winBorder.Thickness = 1
winBorder.Parent = win

-- ============================================================================
-- DRAG SYSTEM (FIXED)
-- ============================================================================
local dragging = false
local touchId = nil
local startInput = nil
local startPanelPos = nil

local function isInBtnZone(px)
    local abs = win.AbsolutePosition
    local sz = win.AbsoluteSize
    return px > abs.X + sz.X - 90
end

-- This function will be called after titleBar is created
local function setupDrag(titleBar)
    titleBar.InputBegan:Connect(function(inp)
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouch or isMouse) then return end
        if isInBtnZone(inp.Position.X) then return end
        dragging = true
        touchId = inp
        startInput = Vector2.new(inp.Position.X, inp.Position.Y)
        startPanelPos = Vector2.new(win.AbsolutePosition.X, win.AbsolutePosition.Y)
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseMove
        if not (isTouch or isMouse) then return end
        if isTouch and inp ~= touchId then return end
        local cur = Vector2.new(inp.Position.X, inp.Position.Y)
        local d = cur - startInput
        local vp2 = Camera.ViewportSize
        local nx = math.clamp(startPanelPos.X + d.X, 0, vp2.X - D.winW)
        local ny = math.clamp(startPanelPos.Y + d.Y, 0, vp2.Y - D.winH)
        win.Position = UDim2.fromOffset(nx, ny)
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp == touchId or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            touchId = nil
        end
    end)
end

-- ============================================================================
-- TITLE BAR
-- ============================================================================
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, D.titleH)
titleBar.Position = UDim2.fromOffset(0, 0)
titleBar.BackgroundColor3 = T.titlebar
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 12
titleBar.Parent = win
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = D.corner

local titlePatch = Instance.new("Frame")
titlePatch.Size = UDim2.new(1, 0, 0, D.corner.Offset)
titlePatch.Position = UDim2.new(0, 0, 1, -D.corner.Offset)
titlePatch.BackgroundColor3 = T.titlebar
titlePatch.BackgroundTransparency = 0
titlePatch.BorderSizePixel = 0
titlePatch.ZIndex = 11
titlePatch.Parent = titleBar

local titleIcon = Instance.new("Frame")
titleIcon.Name = "Icon"
titleIcon.Size = UDim2.fromOffset(22,22)
titleIcon.Position = UDim2.new(0,12,0.5,-11)
titleIcon.BackgroundColor3 = T.accent
titleIcon.BorderSizePixel = 0
titleIcon.ZIndex = 13
titleIcon.Parent = titleBar
Instance.new("UICorner", titleIcon).CornerRadius = UDim.new(0,4)

local titleIconLbl = Instance.new("TextLabel")
titleIconLbl.Size = UDim2.fromScale(1,1)
titleIconLbl.BackgroundTransparency = 1
titleIconLbl.Text = "A"
titleIconLbl.Font = Enum.Font.GothamBlack
titleIconLbl.TextSize = 13
titleIconLbl.TextColor3 = T.white
titleIconLbl.TextXAlignment = Enum.TextXAlignment.Center
titleIconLbl.ZIndex = 14
titleIconLbl.Parent = titleIcon

local titleLbl = Instance.new("TextLabel")
titleLbl.Name = "Title"
titleLbl.Size = UDim2.new(1, -200, 1, 0)
titleLbl.Position = UDim2.fromOffset(42,0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Anonymous9x TSB Strong"
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextColor3 = T.textPrimary
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 13
titleLbl.Parent = titleBar

local verTag = Instance.new("TextLabel")
verTag.Size = UDim2.fromOffset(40,18)
verTag.Position = UDim2.new(0, 42+200, 0.5, -9)
verTag.BackgroundColor3 = T.accentDim
verTag.BackgroundTransparency = 0
verTag.Text = "v1.0"
verTag.Font = Enum.Font.GothamBold
verTag.TextSize = 9
verTag.TextColor3 = T.white
verTag.ZIndex = 13
verTag.Parent = titleBar
Instance.new("UICorner", verTag).CornerRadius = UDim.new(1,0)

local minBtn = Instance.new("TextButton")
minBtn.Name = "Minimize"
minBtn.Size = UDim2.fromOffset(26,22)
minBtn.Position = UDim2.new(1, -66, 0.5, -11)
minBtn.BackgroundColor3 = Color3.fromRGB(50,50,64)
minBtn.BorderSizePixel = 0
minBtn.Text = "_"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.TextColor3 = T.textSec
minBtn.ZIndex = 14
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,4)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.fromOffset(26,22)
closeBtn.Position = UDim2.new(1, -34, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,45,45)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.TextColor3 = T.white
closeBtn.ZIndex = 14
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)

-- Setup drag
setupDrag(titleBar)

-- Minimize logic
local isMinimized = false
local bodyFrame
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if bodyFrame then bodyFrame.Visible = not isMinimized end
    local targetH = isMinimized and D.titleH or D.winH
    TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(D.winW, targetH)}):Play()
    minBtn.Text = isMinimized and "+" or "_"
end)
closeBtn.MouseButton1Click:Connect(function()
    pcall(function() root:Destroy() end)
    pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
end)

-- ============================================================================
-- BODY (sidebar + content)
-- ============================================================================
bodyFrame = Instance.new("Frame")
bodyFrame.Name = "Body"
bodyFrame.Size = UDim2.new(1, 0, 1, -D.titleH)
bodyFrame.Position = UDim2.fromOffset(0, D.titleH)
bodyFrame.BackgroundTransparency = 1
bodyFrame.BorderSizePixel = 0
bodyFrame.ClipsDescendants = true
bodyFrame.ZIndex = 11
bodyFrame.Parent = win

-- ============================================================================
-- SIDEBAR
-- ============================================================================
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.fromOffset(D.sideW, D.winH - D.titleH)
sidebar.Position = UDim2.fromOffset(0,0)
sidebar.BackgroundColor3 = T.sidebar
sidebar.BackgroundTransparency = 0
sidebar.BorderSizePixel = 0
sidebar.ClipsDescendants = true
sidebar.ZIndex = 12
sidebar.Parent = bodyFrame

local sideEdge = Instance.new("Frame")
sideEdge.Size = UDim2.new(0,1,1,0)
sideEdge.Position = UDim2.new(1,-1,0,0)
sideEdge.BackgroundColor3 = T.separator
sideEdge.BackgroundTransparency = 0
sideEdge.BorderSizePixel = 0
sideEdge.ZIndex = 13
sideEdge.Parent = sidebar

-- ============================================================================
-- PROFILE SECTION
-- ============================================================================
local profileSection = Instance.new("Frame")
profileSection.Name = "Profile"
profileSection.Size = UDim2.new(1,0,0,90)
profileSection.Position = UDim2.fromOffset(0,0)
profileSection.BackgroundColor3 = T.profileBG
profileSection.BackgroundTransparency = 0
profileSection.BorderSizePixel = 0
profileSection.ZIndex = 13
profileSection.Parent = sidebar

local avatarBG = Instance.new("Frame")
avatarBG.Name = "AvatarBG"
avatarBG.Size = UDim2.fromOffset(44,44)
avatarBG.Position = UDim2.new(0.5,-22,0,10)
avatarBG.BackgroundColor3 = T.avatarBorder
avatarBG.BackgroundTransparency = 0
avatarBG.BorderSizePixel = 0
avatarBG.ZIndex = 14
avatarBG.Parent = profileSection
Instance.new("UICorner", avatarBG).CornerRadius = UDim.new(1,0)

local avatarImg = Instance.new("ImageLabel")
avatarImg.Name = "Avatar"
avatarImg.Size = UDim2.fromOffset(40,40)
avatarImg.Position = UDim2.fromOffset(2,2)
avatarImg.BackgroundColor3 = T.profileBG
avatarImg.BackgroundTransparency = 0
avatarImg.Image = ""
avatarImg.ZIndex = 15
avatarImg.Parent = avatarBG
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1,0)

task.spawn(function()
    pcall(function()
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size150x150
        local img,_ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
        avatarImg.Image = img
    end)
end)

local displayNameLbl = Instance.new("TextLabel")
displayNameLbl.Name = "DisplayName"
displayNameLbl.Size = UDim2.new(1,-8,0,14)
displayNameLbl.Position = UDim2.new(0,4,0,58)
displayNameLbl.BackgroundTransparency = 1
displayNameLbl.Text = LocalPlayer.DisplayName
displayNameLbl.Font = Enum.Font.GothamBold
displayNameLbl.TextSize = 11
displayNameLbl.TextColor3 = T.textPrimary
displayNameLbl.TextXAlignment = Enum.TextXAlignment.Center
displayNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
displayNameLbl.ZIndex = 14
displayNameLbl.Parent = profileSection

local usernameLbl = Instance.new("TextLabel")
usernameLbl.Name = "Username"
usernameLbl.Size = UDim2.new(1,-8,0,12)
usernameLbl.Position = UDim2.new(0,4,0,73)
usernameLbl.BackgroundTransparency = 1
usernameLbl.Text = "@" .. LocalPlayer.Name
usernameLbl.Font = Enum.Font.Gotham
usernameLbl.TextSize = 9
usernameLbl.TextColor3 = T.textSec
usernameLbl.TextXAlignment = Enum.TextXAlignment.Center
usernameLbl.TextTruncate = Enum.TextTruncate.AtEnd
usernameLbl.ZIndex = 14
usernameLbl.Parent = profileSection

local profSep = Instance.new("Frame")
profSep.Size = UDim2.new(1,0,0,1)
profSep.Position = UDim2.new(0,0,1,-1)
profSep.BackgroundColor3 = T.separator
profSep.BackgroundTransparency = 0
profSep.BorderSizePixel = 0
profSep.ZIndex = 14
profSep.Parent = profileSection

-- ============================================================================
-- SIDEBAR TAB BUTTONS
-- ============================================================================
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Name = "TabButtons"
tabButtonsFrame.Size = UDim2.new(1,0,0,160)
tabButtonsFrame.Position = UDim2.fromOffset(0,90)
tabButtonsFrame.BackgroundTransparency = 1
tabButtonsFrame.BorderSizePixel = 0
tabButtonsFrame.ZIndex = 13
tabButtonsFrame.Parent = sidebar

local tabList = Instance.new("UIListLayout")
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0,2)
tabList.Parent = tabButtonsFrame

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0,6)
tabPad.PaddingRight = UDim.new(0,6)
tabPad.PaddingTop = UDim.new(0,8)
tabPad.Parent = tabButtonsFrame

local TAB_DEFS = {
    {id = "Combat", label = "Combat"},
    {id = "Movement", label = "Movement"},
    {id = "Exploits", label = "Exploits"},
    {id = "Teleport", label = "Teleport"},
}

local tabBtns = {}
local tabPanels = {}
local activeTab = "Combat"

local function setActiveTab(id)
    activeTab = id
    for _, def in ipairs(TAB_DEFS) do
        local btn = tabBtns[def.id]
        local panel = tabPanels[def.id]
        if btn then
            if def.id == id then
                btn.BackgroundColor3 = T.tabActive
                btn.TextColor3 = T.textPrimary
                if btn:FindFirstChild("Accent") then btn.Accent.BackgroundTransparency = 0 end
            else
                btn.BackgroundColor3 = T.tabInactive
                btn.TextColor3 = T.textSec
                if btn:FindFirstChild("Accent") then btn.Accent.BackgroundTransparency = 1 end
            end
        end
        if panel then panel.Visible = (def.id == id) end
    end
end

for i, def in ipairs(TAB_DEFS) do
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. def.id
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = T.tabInactive
    btn.BorderSizePixel = 0
    btn.Text = def.label
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = T.textSec
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = i
    btn.ZIndex = 14
    btn.Parent = tabButtonsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0,28)
    bp.Parent = btn
    local accentBar = Instance.new("Frame")
    accentBar.Name = "Accent"
    accentBar.Size = UDim2.fromOffset(3,18)
    accentBar.Position = UDim2.new(0,8,0.5,-9)
    accentBar.BackgroundColor3 = T.accent
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 15
    accentBar.Parent = btn
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1,0)
    local bId = def.id
    btn.MouseButton1Click:Connect(function() setActiveTab(bId) end)
    tabBtns[def.id] = btn
end

-- ============================================================================
-- SOCIAL LINKS
-- ============================================================================
local socialFrame = Instance.new("Frame")
socialFrame.Name = "Social"
socialFrame.Size = UDim2.new(1,0,0,64)
socialFrame.Position = UDim2.new(0,0,1,-64)
socialFrame.BackgroundColor3 = T.profileBG
socialFrame.BackgroundTransparency = 0
socialFrame.BorderSizePixel = 0
socialFrame.ZIndex = 13
socialFrame.Parent = sidebar

local socialSep = Instance.new("Frame")
socialSep.Size = UDim2.new(1,0,0,1)
socialSep.BackgroundColor3 = T.separator
socialSep.BackgroundTransparency = 0
socialSep.BorderSizePixel = 0
socialSep.ZIndex = 14
socialSep.Parent = socialFrame

local webBtn = Instance.new("TextButton")
webBtn.Name = "WebBtn"
webBtn.Size = UDim2.new(1,-12,0,24)
webBtn.Position = UDim2.fromOffset(6,8)
webBtn.BackgroundColor3 = T.btnPrimary
webBtn.BorderSizePixel = 0
webBtn.Text = "My Website"
webBtn.Font = Enum.Font.GothamBold
webBtn.TextSize = 10
webBtn.TextColor3 = T.white
webBtn.ZIndex = 14
webBtn.Parent = socialFrame
Instance.new("UICorner", webBtn).CornerRadius = UDim.new(0,5)
webBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://anonymous9x-site.pages.dev/") end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anonymous9x",
            Text = "Website URL copied to clipboard!",
            Duration = 4,
        })
    end)
end)

local ytBtn = Instance.new("TextButton")
ytBtn.Name = "YTBtn"
ytBtn.Size = UDim2.new(1,-12,0,22)
ytBtn.Position = UDim2.fromOffset(6,36)
ytBtn.BackgroundColor3 = T.youtube
ytBtn.BorderSizePixel = 0
ytBtn.Text = "YouTube @anonymous9xch"
ytBtn.Font = Enum.Font.GothamBold
ytBtn.TextSize = 9
ytBtn.TextColor3 = T.white
ytBtn.ZIndex = 14
ytBtn.Parent = socialFrame
Instance.new("UICorner", ytBtn).CornerRadius = UDim.new(0,5)
ytBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://youtube.com/@anonymous9xch?si=1HClEtCjJCqUjoXj") end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anonymous9x",
            Text = "YouTube URL copied to clipboard!",
            Duration = 4,
        })
    end)
end)

-- ============================================================================
-- CONTENT AREA
-- ============================================================================
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -D.sideW, 1, 0)
contentArea.Position = UDim2.fromOffset(D.sideW, 0)
contentArea.BackgroundColor3 = T.content
contentArea.BackgroundTransparency = 0
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.ZIndex = 12
contentArea.Parent = bodyFrame

local contentHeader = Instance.new("Frame")
contentHeader.Name = "Header"
contentHeader.Size = UDim2.new(1,0,0,36)
contentHeader.BackgroundColor3 = T.titlebar
contentHeader.BackgroundTransparency = 0
contentHeader.BorderSizePixel = 0
contentHeader.ZIndex = 13
contentHeader.Parent = contentArea

local contentHeaderLbl = Instance.new("TextLabel")
contentHeaderLbl.Name = "Label"
contentHeaderLbl.Size = UDim2.new(1,-16,1,0)
contentHeaderLbl.Position = UDim2.fromOffset(14,0)
contentHeaderLbl.BackgroundTransparency = 1
contentHeaderLbl.Text = "Combat"
contentHeaderLbl.Font = Enum.Font.GothamBold
contentHeaderLbl.TextSize = 12
contentHeaderLbl.TextColor3 = T.textPrimary
contentHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
contentHeaderLbl.ZIndex = 14
contentHeaderLbl.Parent = contentHeader

local hdrLine = Instance.new("Frame")
hdrLine.Size = UDim2.new(1,0,0,1)
hdrLine.Position = UDim2.new(0,0,1,-1)
hdrLine.BackgroundColor3 = T.separator
hdrLine.BorderSizePixel = 0
hdrLine.ZIndex = 14
hdrLine.Parent = contentHeader

local _origSetActive = setActiveTab
setActiveTab = function(id)
    _origSetActive(id)
    contentHeaderLbl.Text = id
end

-- ============================================================================
-- UI COMPONENT LIBRARY
-- ============================================================================
local function makeTabPanel(tabId)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Panel_" .. tabId
    scroll.Size = UDim2.new(1,0,1,-36)
    scroll.Position = UDim2.fromOffset(0,36)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,120)
    scroll.CanvasSize = UDim2.fromOffset(0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ZIndex = 13
    scroll.Parent = contentArea
    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,4)
    list.Parent = scroll
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, D.padX)
    pad.PaddingRight = UDim.new(0, D.padX)
    pad.PaddingTop = UDim.new(0, D.padY)
    pad.PaddingBottom = UDim.new(0, D.padY)
    pad.Parent = scroll
    tabPanels[tabId] = scroll
    return scroll
end

local function makeSection(parent, title, order)
    local f = Instance.new("Frame")
    f.Name = "Section_" .. title:gsub(" ","_")
    f.Size = UDim2.new(1,0,0, D.sectionH)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.ZIndex = 14
    f.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title:upper()
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextColor3 = T.textSection
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15
    lbl.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = T.separator
    line.BackgroundTransparency = 0
    line.BorderSizePixel = 0
    line.ZIndex = 15
    line.Parent = f
    return f
end

local function makeToggle(parent, opts)
    local h = opts.subtitle and 48 or D.elemH
    local card = Instance.new("Frame")
    card.Name = "Toggle_" .. opts.title:gsub(" ","_")
    card.Size = UDim2.new(1,0,0, h)
    card.BackgroundColor3 = T.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    card.LayoutOrder = opts.order
    card.ZIndex = 14
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,6)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-60,0,18)
    titleLbl.Position = UDim2.fromOffset(12, opts.subtitle and 8 or 9)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = opts.title
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = T.textPrimary
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 15
    titleLbl.Parent = card
    if opts.subtitle then
        local subLbl = Instance.new("TextLabel")
        subLbl.Size = UDim2.new(1,-60,0,14)
        subLbl.Position = UDim2.fromOffset(12,26)
        subLbl.BackgroundTransparency = 1
        subLbl.Text = opts.subtitle
        subLbl.Font = Enum.Font.Gotham
        subLbl.TextSize = 9
        subLbl.TextColor3 = T.textSec
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.ZIndex = 15
        subLbl.Parent = card
    end
    local trackW, trackH = 36,20
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.fromOffset(trackW, trackH)
    track.Position = UDim2.new(1, -(trackW+10), 0.5, -(trackH/2))
    track.BackgroundColor3 = opts.default and T.toggleOn or T.toggleOff
    track.BorderSizePixel = 0
    track.ZIndex = 15
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local knobSize = trackH-4
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(knobSize, knobSize)
    knob.Position = opts.default and UDim2.fromOffset(trackW - knobSize - 2, 2) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = T.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local value = opts.default or false
    local function setToggle(v)
        value = v
        local kx = v and (trackW - knobSize - 2) or 2
        TweenService:Create(track, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {BackgroundColor3 = v and T.toggleOn or T.toggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {Position = UDim2.fromOffset(kx,2)}):Play()
        if opts.callback then opts.callback(v) end
    end
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.fromScale(1,1)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 17
    clickBtn.Parent = card
    clickBtn.MouseButton1Click:Connect(function() setToggle(not value) end)
    clickBtn.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3 = T.cardHover}):Play()
    end)
    clickBtn.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.10), {BackgroundColor3 = T.card}):Play()
    end)
    return card, setToggle
end

local function makeSlider(parent, opts)
    local step = opts.step or 1
    local h = 52
    local card = Instance.new("Frame")
    card.Name = "Slider_" .. opts.title:gsub(" ","_")
    card.Size = UDim2.new(1,0,0, h)
    card.BackgroundColor3 = T.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    card.LayoutOrder = opts.order
    card.ZIndex = 14
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,6)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6,0,0,16)
    titleLbl.Position = UDim2.fromOffset(12,8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = opts.title
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = T.textPrimary
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 15
    titleLbl.Parent = card
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4,-12,0,16)
    valLbl.Position = UDim2.new(0.6,0,0,8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(opts.default) .. (opts.suffix or "")
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = T.accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 15
    valLbl.Parent = card
    local trackH = 6
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -24, 0, trackH)
    track.Position = UDim2.fromOffset(12,30)
    track.BackgroundColor3 = T.sliderTrack
    track.BorderSizePixel = 0
    track.ZIndex = 15
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local pct = (opts.default - opts.min) / (opts.max - opts.min)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = T.sliderFill
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local knobD = 14
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(knobD, knobD)
    knob.Position = UDim2.new(pct, -knobD/2, 0.5, -knobD/2)
    knob.BackgroundColor3 = T.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local value = opts.default
    local dragging = false
    local function updateFromAbsX(absX)
        local tAbs = track.AbsolutePosition
        local tSz = track.AbsoluteSize
        local rel = math.clamp((absX - tAbs.X) / tSz.X, 0, 1)
        local raw = opts.min + rel * (opts.max - opts.min)
        value = math.floor(raw / step + 0.5) * step
        value = math.clamp(value, opts.min, opts.max)
        local p = (value - opts.min) / (opts.max - opts.min)
        fill.Size = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p, -knobD/2, 0.5, -knobD/2)
        local disp = (step < 1) and string.format("%.1f", value) or tostring(math.floor(value))
        valLbl.Text = disp .. (opts.suffix or "")
        if opts.callback then opts.callback(value) end
    end
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1,0,1,0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.ZIndex = 18
    hitbox.Parent = track
    hitbox.MouseButton1Down:Connect(function(x) dragging = true; updateFromAbsX(x) end)
    hitbox.TouchLongPress:Connect(function() dragging = true end)
    hitbox.TouchPan:Connect(function(_, positions) if dragging and positions[1] then updateFromAbsX(positions[1].X) end end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            updateFromAbsX(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return card
end

local function makeDropdown(parent, opts)
    local h = 40
    local card = Instance.new("Frame")
    card.Name = "DD_" .. opts.title:gsub(" ","_")
    card.Size = UDim2.new(1,0,0, h)
    card.BackgroundColor3 = T.card
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    card.LayoutOrder = opts.order
    card.ClipsDescendants = false
    card.ZIndex = 20
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,6)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5,0,0,16)
    titleLbl.Position = UDim2.fromOffset(12,12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = opts.title
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = T.textPrimary
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 21
    titleLbl.Parent = card
    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0.48, -8, 0, 26)
    selBtn.Position = UDim2.new(0.52, 0, 0.5, -13)
    selBtn.BackgroundColor3 = T.dropBG
    selBtn.BorderSizePixel = 0
    selBtn.Text = opts.default or opts.options[1]
    selBtn.Font = Enum.Font.GothamSemibold
    selBtn.TextSize = 10
    selBtn.TextColor3 = T.textPrimary
    selBtn.ZIndex = 21
    selBtn.Parent = card
    Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0,5)
    local selBtnStroke = Instance.new("UIStroke")
    selBtnStroke.Color = T.separator
    selBtnStroke.Thickness = 1
    selBtnStroke.Parent = selBtn
    local itemH = 28
    local listH = #opts.options * itemH + 4
    local dropList = Instance.new("Frame")
    dropList.Name = "DropList"
    dropList.Size = UDim2.fromOffset(selBtn.Size.X.Offset, listH)
    dropList.Position = UDim2.new(selBtn.Position.X.Scale, selBtn.Position.X.Offset, 1, 2)
    dropList.BackgroundColor3 = T.dropBG
    dropList.BackgroundTransparency = 0
    dropList.BorderSizePixel = 0
    dropList.Visible = false
    dropList.ZIndex = 30
    dropList.Parent = card
    Instance.new("UICorner", dropList).CornerRadius = UDim.new(0,6)
    local dlStroke = Instance.new("UIStroke")
    dlStroke.Color = T.separator
    dlStroke.Thickness = 1
    dlStroke.Parent = dropList
    local ddList = Instance.new("UIListLayout")
    ddList.SortOrder = Enum.SortOrder.LayoutOrder
    ddList.Padding = UDim.new(0,0)
    ddList.Parent = dropList
    local ddPad = Instance.new("UIPadding")
    ddPad.PaddingTop = UDim.new(0,2)
    ddPad.PaddingBottom = UDim.new(0,2)
    ddPad.PaddingLeft = UDim.new(0,2)
    ddPad.PaddingRight = UDim.new(0,2)
    ddPad.Parent = dropList
    local isOpen = false
    local selected = opts.default or opts.options[1]
    local function closeDropdown()
        isOpen = false
        dropList.Visible = false
    end
    local function openDropdown()
        local sw = selBtn.AbsoluteSize.X
        dropList.Size = UDim2.fromOffset(sw, listH)
        isOpen = true
        dropList.Visible = true
    end
    for i, opt in ipairs(opts.options) do
        local o = opt
        local item = Instance.new("TextButton")
        item.Name = "Item_" .. o
        item.Size = UDim2.new(1,0,0, itemH)
        item.BackgroundColor3 = T.dropItem
        item.BackgroundTransparency = 0
        item.BorderSizePixel = 0
        item.Text = o
        item.Font = Enum.Font.GothamSemibold
        item.TextSize = 10
        item.TextColor3 = T.textPrimary
        item.LayoutOrder = i
        item.ZIndex = 31
        item.Parent = dropList
        Instance.new("UICorner", item).CornerRadius = UDim.new(0,4)
        local ip = Instance.new("UIPadding")
        ip.PaddingLeft = UDim.new(0,8)
        ip.Parent = item
        item.MouseEnter:Connect(function() item.BackgroundColor3 = T.dropHover end)
        item.MouseLeave:Connect(function() item.BackgroundColor3 = T.dropItem end)
        item.MouseButton1Click:Connect(function()
            selected = o
            selBtn.Text = o
            closeDropdown()
            if opts.callback then opts.callback(o) end
        end)
    end
    selBtn.MouseButton1Click:Connect(function()
        if isOpen then closeDropdown() else openDropdown() end
    end)
    return card, function() return selected end
end

local function makeButton(parent, opts)
    local h = opts.subtitle and 48 or 36
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_" .. opts.title:gsub(" ","_")
    btn.Size = UDim2.new(1,0,0, h)
    btn.BackgroundColor3 = opts.color or T.btnNeutral
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = opts.order
    btn.ZIndex = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-16,0,18)
    lbl.Position = UDim2.fromOffset(12, opts.subtitle and 8 or 9)
    lbl.BackgroundTransparency = 1
    lbl.Text = opts.title
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = T.white
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15
    lbl.Parent = btn
    if opts.subtitle then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1,-16,0,14)
        sub.Position = UDim2.fromOffset(12,27)
        sub.BackgroundTransparency = 1
        sub.Text = opts.subtitle
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 9
        sub.TextColor3 = Color3.new(1,1,1)
        sub.TextTransparency = 0.3
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 15
        sub.Parent = btn
    end
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3 = (opts.color or T.btnNeutral):Lerp(T.white, 0.15)}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3 = opts.color or T.btnNeutral}):Play()
        end)
        if opts.callback then opts.callback() end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3 = (opts.color or T.btnNeutral):Lerp(T.white, 0.08)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.10), {BackgroundColor3 = opts.color or T.btnNeutral}):Play()
    end)
    return btn
end

local function makeDivider(parent, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = T.separator
    f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.ZIndex = 14
    f.Parent = parent
    return f
end

-- ============================================================================
-- CREATE TAB PANELS
-- ============================================================================
for _, def in ipairs(TAB_DEFS) do
    makeTabPanel(def.id)
end

-- ============================================================================
-- COMBAT TAB
-- ============================================================================
local combatPanel = tabPanels["Combat"]
local _order = 0
local function co() _order = _order + 1; return _order end

makeSection(combatPanel, "Target Selection", co())
local ddTargetCard, getTarget = makeDropdown(combatPanel, {
    title = "Select Target",
    options = getPlayerNames(),
    default = "— None —",
    order = co(),
    callback = function(val)
        if val == "— None —" then State.target = nil
        else State.target = Players:FindFirstChild(val) end
    end,
})

makeSection(combatPanel, "Follow Mode", co())
makeDropdown(combatPanel, {
    title = "Follow Mode",
    options = {"HEAD", "ORBIT", "FEET"},
    default = "HEAD",
    order = co(),
    callback = function(val) State.followMode = val; _orbitAngle = 0 end,
})

makeSlider(combatPanel, { title = "Stud Distance", min = 1, max = 20, default = 3, suffix = " st", step = 0.5, order = co(), callback = function(val) State.studDist = val end, })
makeSlider(combatPanel, { title = "Follow Speed", min = 5, max = 100, default = 20, suffix = "", step = 1, order = co(), callback = function(val) State.followSpeed = val end, })

makeSection(combatPanel, "Actions", co())
makeToggle(combatPanel, { title = "Follow Target", subtitle = "Stick to selected target", default = false, order = co(), callback = function(val) State.followOn = val; if not val then pcall(function() Camera.CameraType = Enum.CameraType.Custom end) end end, })
makeToggle(combatPanel, { title = "Solo Hacker", subtitle = "Follow all players simultaneously", default = false, order = co(), callback = function(val) State.soloHacker = val end, })
makeToggle(combatPanel, { title = "Drag Hold", subtitle = "Pull targets to your position", default = false, order = co(), callback = function(val) State.dragHold = val end, })
makeToggle(combatPanel, { title = "Cam Lock", subtitle = "Camera locks onto target", default = false, order = co(), callback = function(val) State.camLock = val; if not val then pcall(function() Camera.CameraType = Enum.CameraType.Custom end) end end, })
makeSlider(combatPanel, { title = "Camera Distance", min = 5, max = 80, default = 12, suffix = " st", step = 1, order = co(), callback = function(val) State.camDist = val; pcall(function() LocalPlayer.CameraMaxZoomDistance = val; LocalPlayer.CameraMinZoomDistance = val end) end, })
makeToggle(combatPanel, { title = "Anti Void", subtitle = "Rescue if character falls below -250Y", default = false, order = co(), callback = function(val) State.antiVoid = val end, })

makeDivider(combatPanel, co())
makeButton(combatPanel, { title = "Stop All Combat", subtitle = "Disable all follow / lock features", color = T.btnDanger, order = co(), callback = function()
    State.followOn = false; State.soloHacker = false; State.dragHold = false; State.camLock = false; State.antiVoid = false; State.target = nil
    pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
end, })
makeButton(combatPanel, { title = "Teleport to Target", color = T.btnNeutral, order = co(), callback = function()
    if not State.target then return end
    local c = State.target.Character
    local tH = c and c:FindFirstChild("HumanoidRootPart")
    if tH and hrp then pcall(function() hrp.CFrame = tH.CFrame + Vector3.new(3,0,0) end) end
end, })

-- ============================================================================
-- MOVEMENT TAB
-- ============================================================================
local movPanel = tabPanels["Movement"]
local _mo = 0
local function mo() _mo = _mo + 1; return _mo end

makeSection(movPanel, "Speed", mo())
makeToggle(movPanel, { title = "Speed Boost", subtitle = "TP-walk in move direction", default = false, order = mo(), callback = function(val) State.speedOn = val end, })
makeSlider(movPanel, { title = "Boost Value", min = 0.1, max = 10, default = 1.5, suffix = "x", step = 0.1, order = mo(), callback = function(val) State.speedVal = val end, })
makeToggle(movPanel, { title = "Walkspeed Lock", subtitle = "Force Humanoid.WalkSpeed", default = false, order = mo(), callback = function(val) State.wsOn = val; if not val and hum then pcall(function() hum.WalkSpeed = 16 end) end end, })
makeSlider(movPanel, { title = "Walkspeed", min = 0, max = 500, default = 16, suffix = "", step = 1, order = mo(), callback = function(val) State.walkspeed = val; if hum then pcall(function() hum.WalkSpeed = val end) end end, })

makeSection(movPanel, "Jump", mo())
makeToggle(movPanel, { title = "Jump Boost", subtitle = "Override jump height", default = false, order = mo(), callback = function(val) State.jumpOn = val; if hum then pcall(function() hum.UseJumpPower = not val end) end end, })
makeSlider(movPanel, { title = "Jump Height", min = 7, max = 500, default = 50, suffix = "", step = 1, order = mo(), callback = function(val) State.jumpVal = val; if hum then pcall(function() hum.JumpHeight = val end) end end, })

makeSection(movPanel, "World", mo())
makeSlider(movPanel, { title = "Gravity", min = 0, max = 200, default = 196, suffix = "", step = 1, order = mo(), callback = function(val) pcall(function() workspace.Gravity = val end) end, })
makeSlider(movPanel, { title = "Field of View", min = 30, max = 120, default = 70, suffix = "", step = 1, order = mo(), callback = function(val) pcall(function() Camera.FieldOfView = val end) end, })

makeDivider(movPanel, mo())
makeButton(movPanel, { title = "Reset Movement", color = T.btnDanger, order = mo(), callback = function()
    State.speedOn = false; State.wsOn = false; State.jumpOn = false
    if hum then pcall(function() hum.WalkSpeed = 16; hum.JumpHeight = 7.2; hum.UseJumpPower = false end) end
    pcall(function() workspace.Gravity = 196.2; Camera.FieldOfView = 70 end)
end, })

-- ============================================================================
-- EXPLOITS TAB
-- ============================================================================
local expPanel = tabPanels["Exploits"]
local _eo = 0
local function eo() _eo = _eo + 1; return _eo end

makeSection(expPanel, "TSB Game Attributes", eo())
makeToggle(expPanel, { title = "No Dash Cooldown", subtitle = "workspace NoDashCooldown = true", default = false, order = eo(), callback = function(val) State.noDashCD = val; pcall(function() workspace:SetAttribute("NoDashCooldown", val) end) end, })
makeToggle(expPanel, { title = "No Fatigue", subtitle = "workspace NoFatigue = true", default = false, order = eo(), callback = function(val) State.noFatigue = val; pcall(function() workspace:SetAttribute("NoFatigue", val) end) end, })

makeSection(expPanel, "Emote System", eo())
makeToggle(expPanel, { title = "Extra Emote Slots", subtitle = "LocalPlayer ExtraSlots = true", default = false, order = eo(), callback = function(val) State.extraSlots = val; pcall(function() LocalPlayer:SetAttribute("ExtraSlots", val) end) end, })
makeToggle(expPanel, { title = "Emote Search Bar", subtitle = "LocalPlayer EmoteSearchBar = true", default = false, order = eo(), callback = function(val) State.emoteSearch = val; pcall(function() LocalPlayer:SetAttribute("EmoteSearchBar", val) end) end, })

makeSection(expPanel, "Server Spoof", eo())
makeButton(expPanel, { title = "Spoof VIP Server Owner", subtitle = "Sets VIPServer attribute to your UID", color = T.btnNeutral, order = eo(), callback = function()
    pcall(function() workspace:SetAttribute("VIPServer", tostring(LocalPlayer.UserId)); workspace:SetAttribute("VIPServerOwner", LocalPlayer.Name) end)
end, })
makeButton(expPanel, { title = "Apply All Attributes", color = T.btnPrimary, order = eo(), callback = function()
    initTSBAttributes()
    pcall(function() workspace:SetAttribute("NoDashCooldown", State.noDashCD) end)
    pcall(function() workspace:SetAttribute("NoFatigue", State.noFatigue) end)
    pcall(function() LocalPlayer:SetAttribute("ExtraSlots", State.extraSlots) end)
    pcall(function() LocalPlayer:SetAttribute("EmoteSearchBar", State.emoteSearch) end)
end, })

-- ============================================================================
-- TELEPORT TAB
-- ============================================================================
local tpPanel = tabPanels["Teleport"]
local _to = 0
local function tto() _to = _to + 1; return _to end

makeSection(tpPanel, "Map Locations", tto())
local TP_LOCATIONS = {
    {name = "Middle", pos = CFrame.new(148, 441, 27)},
    {name = "Atomic Room", pos = CFrame.new(1079, 155, 23003)},
    {name = "Death Counter Room", pos = CFrame.new(-92, 29, 20347)},
    {name = "Baseplate", pos = CFrame.new(968, 20, 23088)},
    {name = "Mountain 1", pos = CFrame.new(266, 699, 458)},
    {name = "Mountain 2", pos = CFrame.new(551, 630, -265)},
    {name = "Mountain 3", pos = CFrame.new(-107, 642, -328)},
}
for _, loc in ipairs(TP_LOCATIONS) do
    makeButton(tpPanel, { title = loc.name, color = T.btnNeutral, order = tto(), callback = function() if hrp then pcall(function() hrp.CFrame = loc.pos end) end end, })
end

makeSection(tpPanel, "Player Teleport", tto())
makeButton(tpPanel, { title = "Teleport to Target", subtitle = "Select target in Combat tab first", color = T.btnPrimary, order = tto(), callback = function()
    if not State.target then return end
    local c = State.target.Character
    local tHRP = c and c:FindFirstChild("HumanoidRootPart")
    if tHRP and hrp then pcall(function() hrp.CFrame = tHRP.CFrame + Vector3.new(3,0,0) end) end
end, })
makeButton(tpPanel, { title = "Bring Target to Me", color = T.btnNeutral, order = tto(), callback = function()
    if not State.target or not hrp then return end
    local c = State.target.Character
    local tHRP = c and c:FindFirstChild("HumanoidRootPart")
    if tHRP then pcall(function() tHRP.CFrame = hrp.CFrame + Vector3.new(2,0,0) end) end
end, })

-- ============================================================================
-- BOOT
-- ============================================================================
setActiveTab("Combat")

task.spawn(function()
    task.wait(2)
    pcall(function()
        displayNameLbl.Text = LocalPlayer.DisplayName
        usernameLbl.Text = "@" .. LocalPlayer.Name
    end)
end)

task.spawn(function()
    task.wait(0.5)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anonymous9x TSB Strong",
            Text = "Script loaded successfully!",
            Duration = 4,
        })
    end)
end)

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
