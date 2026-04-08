-- ═══════════════════════════════════════════
--   Anonymous9x MM2  |  v1.02
--   All Executor  |  Mobile + PC
-- ═══════════════════════════════════════════

if game.PlaceId ~= 142823291 then return end
if not game:IsLoaded() then
    local ok = pcall(function() game.Loaded:Wait() end)
    if not ok then repeat task.wait() until game:IsLoaded() end
end

-- ─── SERVICES ────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local Workspace        = game:GetService("Workspace")
local _cr = cloneref or function(x) return x end
Players=_cr(Players) RunService=_cr(RunService)
TweenService=_cr(TweenService) ReplicatedStorage=_cr(ReplicatedStorage) Workspace=_cr(Workspace)

local env = getgenv and getgenv() or _G

-- ─── PLAYER REFS ─────────────────────────────
local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum  = Char:FindFirstChildWhichIsA("Humanoid")
local Root = (Hum and Hum.RootPart) or Char:FindFirstChild("HumanoidRootPart")
local BP   = LP:FindFirstChild("Backpack") or LP:WaitForChild("Backpack")

LP.CharacterAdded:Connect(function(c)
    repeat task.wait() until c and c.Parent
    Char = c
    Hum  = c:WaitForChild("Humanoid", 10)
    Root = (Hum and Hum.RootPart) or c:FindFirstChild("HumanoidRootPart")
    BP   = LP:FindFirstChild("Backpack") or LP:WaitForChild("Backpack", 10)
end)

-- ─── GUI PARENT ──────────────────────────────
local guiP
pcall(function() guiP = gethui and gethui() end)
if not guiP then pcall(function() guiP = game:GetService("CoreGui") end) end
if not guiP then guiP = LP.PlayerGui end

for _,n in ipairs({"Ano9xV3","Ano9xNF"}) do
    local x = guiP:FindFirstChild(n) if x then x:Destroy() end
end

-- ════════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════════
local NF = Instance.new("ScreenGui")
NF.Name="Ano9xNF" NF.ResetOnSpawn=false NF.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
NF.DisplayOrder=999 NF.IgnoreGuiInset=true NF.Parent=guiP

local _nSlot=0
local function Notify(title, msg)
    _nSlot=_nSlot+1
    local slot=_nSlot
    local yB=-(10+(slot-1)*60)
    local f=Instance.new("Frame",NF)
    f.Size=UDim2.new(0,200,0,48) f.AnchorPoint=Vector2.new(1,1)
    f.Position=UDim2.new(1,220,1,yB)
    f.BackgroundColor3=Color3.fromRGB(13,13,13) f.BorderSizePixel=0 f.ZIndex=10
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local s=Instance.new("UIStroke",f) s.Color=Color3.fromRGB(255,255,255) s.Thickness=0.8 s.Transparency=0.78
    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(0,2,0,28) bar.Position=UDim2.new(0,0,0.5,-14)
    bar.BackgroundColor3=Color3.fromRGB(210,210,210) bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local t1=Instance.new("TextLabel",f)
    t1.Size=UDim2.new(1,-10,0,18) t1.Position=UDim2.new(0,8,0,7)
    t1.BackgroundTransparency=1 t1.Text=title t1.TextColor3=Color3.fromRGB(245,245,245)
    t1.Font=Enum.Font.GothamBold t1.TextSize=11 t1.TextXAlignment=Enum.TextXAlignment.Left t1.ZIndex=11
    local t2=Instance.new("TextLabel",f)
    t2.Size=UDim2.new(1,-10,0,15) t2.Position=UDim2.new(0,8,0,27)
    t2.BackgroundTransparency=1 t2.Text=msg t2.TextColor3=Color3.fromRGB(130,130,130)
    t2.Font=Enum.Font.Gotham t2.TextSize=10 t2.TextXAlignment=Enum.TextXAlignment.Left
    t2.TextWrapped=true t2.ZIndex=11
    TweenService:Create(f,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
        {Position=UDim2.new(1,-10,1,yB)}):Play()
    task.delay(3.6,function()
        TweenService:Create(f,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
            {Position=UDim2.new(1,220,1,yB)}):Play()
        task.wait(0.22) if f and f.Parent then f:Destroy() end
        _nSlot=math.max(0,_nSlot-1)
    end)
end

-- ════════════════════════════════════════════
--  MAIN SCREENGUI
-- ════════════════════════════════════════════
local SG=Instance.new("ScreenGui")
SG.Name="Ano9xV3" SG.ResetOnSpawn=false SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.DisplayOrder=100 SG.IgnoreGuiInset=true SG.Parent=guiP

-- ─── MINIMIZE ICON (right-center, fixed, no drag) ─
local MinBtn=Instance.new("ImageButton",SG)
MinBtn.Name="MinBtn" MinBtn.Size=UDim2.new(0,44,0,44)
MinBtn.AnchorPoint=Vector2.new(1,0.5) MinBtn.Position=UDim2.new(1,-5,0.5,0)
MinBtn.Image="rbxassetid://97269958324726"
MinBtn.BackgroundColor3=Color3.fromRGB(12,12,12) MinBtn.BorderSizePixel=0
MinBtn.Visible=false MinBtn.ZIndex=60
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,8)
local ms=Instance.new("UIStroke",MinBtn) ms.Color=Color3.fromRGB(255,255,255) ms.Thickness=1 ms.Transparency=0.6

-- ════════════════════════════════════════════
--  DIMENSIONS  (wider + shorter)
-- ════════════════════════════════════════════
local UW    = 370   -- width
local UH    = 318   -- height
local HDR_H = 36
local INFO_H= 48
local SIDE_W= 62
local CONT_H= UH - HDR_H - INFO_H   -- 234

-- ─── MAIN FRAME ──────────────────────────────
local MF=Instance.new("Frame",SG)
MF.Name="MF" MF.Size=UDim2.new(0,UW,0,UH)
MF.Position=UDim2.new(0.5,-UW/2,0.5,-UH/2)
MF.BackgroundColor3=Color3.fromRGB(10,10,10) MF.BorderSizePixel=0 MF.ZIndex=2
-- NOTE: ClipsDescendants OFF on MF so header buttons are never clipped
MF.ClipsDescendants=false
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,10)
local mfSt=Instance.new("UIStroke",MF) mfSt.Color=Color3.fromRGB(255,255,255) mfSt.Thickness=1 mfSt.Transparency=0.8

-- ─── HEADER ──────────────────────────────────
-- Plain Frame, rounded top only via UICorner on a separate visual backing
-- We do NOT use a corner fixer frame that could block button inputs
local HDR=Instance.new("Frame",MF)
HDR.Name="HDR" HDR.Size=UDim2.new(1,0,0,HDR_H) HDR.Position=UDim2.new(0,0,0,0)
HDR.BackgroundColor3=Color3.fromRGB(16,16,16) HDR.BorderSizePixel=0 HDR.ZIndex=3
HDR.ClipsDescendants=false
-- Round all corners then overlay bottom portion to square it
Instance.new("UICorner",HDR).CornerRadius=UDim.new(0,10)
-- Bottom square-off: frame behind content area covers the bottom-round of header
local HDR_SQ=Instance.new("Frame",MF)
HDR_SQ.Size=UDim2.new(1,0,0,10) HDR_SQ.Position=UDim2.new(0,0,0,HDR_H-10)
HDR_SQ.BackgroundColor3=Color3.fromRGB(16,16,16) HDR_SQ.BorderSizePixel=0 HDR_SQ.ZIndex=3
-- This square frame is BEHIND the content area (ZIndex=3), no buttons on it

-- 3 dot accent
for i=0,2 do
    local d=Instance.new("Frame",HDR)
    d.Size=UDim2.new(0,5,0,5)
    d.Position=UDim2.new(0,10+i*9,0.5,-2)
    d.BackgroundColor3=i==0 and Color3.fromRGB(255,255,255) or Color3.fromRGB(55,55,55)
    d.BorderSizePixel=0 d.ZIndex=5
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
end

local TitleL=Instance.new("TextLabel",HDR)
TitleL.Size=UDim2.new(1,-110,1,0) TitleL.Position=UDim2.new(0,42,0,0)
TitleL.BackgroundTransparency=1 TitleL.Text="Anonymous9x MM2"
TitleL.TextColor3=Color3.fromRGB(255,255,255) TitleL.Font=Enum.Font.GothamBold
TitleL.TextSize=12 TitleL.TextXAlignment=Enum.TextXAlignment.Left TitleL.ZIndex=5

local VerL=Instance.new("TextLabel",HDR)
VerL.Size=UDim2.new(0,28,0,12) VerL.Position=UDim2.new(0,192,0.5,-6)
VerL.BackgroundTransparency=1 VerL.Text="v1.02"
VerL.TextColor3=Color3.fromRGB(65,65,65) VerL.Font=Enum.Font.Gotham VerL.TextSize=9 VerL.ZIndex=5

-- ─── WINDOW BUTTONS (TextButton, ZIndex=10, large touch target) ─────
-- IMPORTANT: These are direct children of HDR, NOT behind any covering frame
-- ZIndex=10 ensures they're always on top within HDR
local function makeWBtn(xOff, txt)
    local b=Instance.new("TextButton",HDR)
    b.Size=UDim2.new(0,24,0,24)
    b.Position=UDim2.new(1,xOff,0.5,-12)
    b.BackgroundColor3=Color3.fromRGB(38,38,38)
    b.Text=txt b.TextColor3=Color3.fromRGB(185,185,185)
    b.Font=Enum.Font.GothamBold b.TextSize=10
    b.BorderSizePixel=0 b.AutoButtonColor=false b.ZIndex=10
    b.ClipsDescendants=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    -- hover tween
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(58,58,58)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,38,38)}):Play()
    end)
    return b
end
local BClose = makeWBtn(-28, "x")
local BMini  = makeWBtn(-56, "_")

-- ─── DRAG HANDLE (TextButton covers header drag zone) ─────────────────
-- KEY FIX: TextButton.MouseButton1Down fires reliably on Delta mobile touch
-- Covers header width minus right 70px (where close/min buttons are)
local DragBtn=Instance.new("TextButton",HDR)
DragBtn.Name="DragHandle"
DragBtn.Size=UDim2.new(1,-70,1,0) DragBtn.Position=UDim2.new(0,0,0,0)
DragBtn.BackgroundTransparency=1 DragBtn.Text=""
DragBtn.ZIndex=4   -- below window buttons (ZIndex=10) but captures drag area
DragBtn.AutoButtonColor=false DragBtn.BorderSizePixel=0

-- ─── PLAYER INFO BAR ─────────────────────────
local INFO=Instance.new("Frame",MF)
INFO.Name="INFO" INFO.Size=UDim2.new(1,0,0,INFO_H) INFO.Position=UDim2.new(0,0,0,HDR_H)
INFO.BackgroundColor3=Color3.fromRGB(14,14,14) INFO.BorderSizePixel=0 INFO.ZIndex=3

local idiv=Instance.new("Frame",INFO)
idiv.Size=UDim2.new(1,0,0,1) idiv.Position=UDim2.new(0,0,1,-1)
idiv.BackgroundColor3=Color3.fromRGB(26,26,26) idiv.BorderSizePixel=0 idiv.ZIndex=4

local AVA=Instance.new("ImageLabel",INFO)
AVA.Size=UDim2.new(0,32,0,32) AVA.Position=UDim2.new(0,12,0.5,-16)
AVA.BackgroundColor3=Color3.fromRGB(25,25,25) AVA.BorderSizePixel=0 AVA.ZIndex=4
Instance.new("UICorner",AVA).CornerRadius=UDim.new(1,0)
local aSt=Instance.new("UIStroke",AVA) aSt.Color=Color3.fromRGB(255,255,255) aSt.Thickness=0.8 aSt.Transparency=0.7
task.spawn(function()
    pcall(function()
        AVA.Image=Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
    end)
end)

local DN=Instance.new("TextLabel",INFO)
DN.Size=UDim2.new(1,-56,0,17) DN.Position=UDim2.new(0,50,0,8)
DN.BackgroundTransparency=1 DN.Text=LP.DisplayName
DN.TextColor3=Color3.fromRGB(255,255,255) DN.Font=Enum.Font.GothamBold DN.TextSize=12
DN.TextXAlignment=Enum.TextXAlignment.Left DN.ZIndex=4

local UN=Instance.new("TextLabel",INFO)
UN.Size=UDim2.new(1,-56,0,12) UN.Position=UDim2.new(0,50,0,27)
UN.BackgroundTransparency=1 UN.Text="@"..LP.Name
UN.TextColor3=Color3.fromRGB(88,88,88) UN.Font=Enum.Font.Gotham UN.TextSize=10
UN.TextXAlignment=Enum.TextXAlignment.Left UN.ZIndex=4

local UB=Instance.new("TextLabel",INFO)
UB.Size=UDim2.new(0,68,0,13) UB.Position=UDim2.new(1,-74,0,6)
UB.BackgroundColor3=Color3.fromRGB(20,20,20) UB.BorderSizePixel=0
UB.Text="ID "..LP.UserId UB.TextColor3=Color3.fromRGB(60,60,60)
UB.Font=Enum.Font.Gotham UB.TextSize=8 UB.ZIndex=4
Instance.new("UICorner",UB).CornerRadius=UDim.new(0,4)

-- ─── CONTENT WRAPPER ─────────────────────────
local TOP=HDR_H+INFO_H   -- 84px

local WRAP=Instance.new("Frame",MF)
WRAP.Name="WRAP" WRAP.Size=UDim2.new(1,0,0,CONT_H) WRAP.Position=UDim2.new(0,0,0,TOP)
WRAP.BackgroundTransparency=1 WRAP.BorderSizePixel=0 WRAP.ClipsDescendants=true WRAP.ZIndex=2

-- ─── SIDEBAR ─────────────────────────────────
local SB=Instance.new("Frame",WRAP)
SB.Name="SB" SB.Size=UDim2.new(0,SIDE_W,1,0) SB.Position=UDim2.new(0,0,0,0)
SB.BackgroundColor3=Color3.fromRGB(14,14,14) SB.BorderSizePixel=0 SB.ZIndex=3

local sbDiv=Instance.new("Frame",WRAP)
sbDiv.Size=UDim2.new(0,1,1,0) sbDiv.Position=UDim2.new(0,SIDE_W,0,0)
sbDiv.BackgroundColor3=Color3.fromRGB(24,24,24) sbDiv.BorderSizePixel=0 sbDiv.ZIndex=3

-- ─── SCROLL FRAME ────────────────────────────
-- NO UIListLayout, NO AutomaticCanvasSize — manual y positioning
local SCW = UW - SIDE_W - 1   -- 307
local SCX = SIDE_W + 1

local SC=Instance.new("ScrollingFrame",WRAP)
SC.Name="SC" SC.Size=UDim2.new(0,SCW,1,0) SC.Position=UDim2.new(0,SCX,0,0)
SC.BackgroundTransparency=1 SC.BorderSizePixel=0
SC.ScrollBarThickness=2 SC.ScrollBarImageColor3=Color3.fromRGB(52,52,52)
SC.CanvasSize=UDim2.new(0,0,0,0) SC.ElasticBehavior=Enum.ElasticBehavior.Never
SC.ZIndex=3 SC.ClipsDescendants=true

-- ─── TAB CONTAINERS (plain Frame, no layout) ─
local tabs={}
local function makeTab(name)
    local f=Instance.new("Frame",SC)
    f.Name=name f.Size=UDim2.new(1,0,0,0)
    f.Position=UDim2.new(0,0,0,0)
    f.BackgroundTransparency=1 f.BorderSizePixel=0 f.Visible=false f.ZIndex=3
    tabs[name]={frame=f, y=8}
    return tabs[name]
end

local PLAYER = makeTab("Player")
local MISC   = makeTab("Misc")

-- ════════════════════════════════════════════
--  ITEM BUILDERS  (manual y-tracking, no layout)
-- ════════════════════════════════════════════
local PAD_X = 6
local ITEM_W= SCW - PAD_X*2   -- 295

local function finalizeTab(tab)
    tab.y=tab.y+6
    tab.frame.Size=UDim2.new(1,0,0,tab.y)
end
local function flushCanvas(tabName)
    if tabs[tabName] then
        SC.CanvasSize=UDim2.new(0,0,0,tabs[tabName].y)
        SC.CanvasPosition=Vector2.new(0,0)
    end
end

-- Section label
local function addSection(tab, text)
    local lbl=Instance.new("TextLabel",tab.frame)
    lbl.Size=UDim2.new(0,ITEM_W,0,18) lbl.Position=UDim2.new(0,PAD_X,0,tab.y)
    lbl.BackgroundTransparency=1 lbl.Text=text
    lbl.TextColor3=Color3.fromRGB(65,65,65) lbl.Font=Enum.Font.GothamBold lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=4
    tab.y=tab.y+21
end

-- Toggle
local function addToggle(tab, label, default, cb)
    local H=32
    local f=Instance.new("Frame",tab.frame)
    f.Size=UDim2.new(0,ITEM_W,0,H) f.Position=UDim2.new(0,PAD_X,0,tab.y)
    f.BackgroundColor3=Color3.fromRGB(18,18,18) f.BorderSizePixel=0 f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-46,1,0) lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(225,225,225) lbl.Font=Enum.Font.Gotham lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.TextWrapped=true lbl.ZIndex=5

    local pill=Instance.new("Frame",f)
    pill.Size=UDim2.new(0,28,0,14) pill.Position=UDim2.new(1,-36,0.5,-7)
    pill.BackgroundColor3=Color3.fromRGB(40,40,40) pill.BorderSizePixel=0 pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,10,0,10) knob.Position=UDim2.new(0,2,0.5,-5)
    knob.BackgroundColor3=Color3.fromRGB(100,100,100) knob.BorderSizePixel=0 knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local state=default or false
    local function setState(v,silent)
        state=v
        TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=v and Color3.fromRGB(230,230,230) or Color3.fromRGB(40,40,40)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.12),{
            Position=v and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5),
            BackgroundColor3=v and Color3.fromRGB(10,10,10) or Color3.fromRGB(100,100,100)
        }):Play()
        if not silent and cb then task.spawn(cb,v) end
    end
    setState(state,true)

    -- TextButton hitbox (more reliable than InputBegan on Delta)
    local hit=Instance.new("TextButton",f)
    hit.Size=UDim2.new(1,0,1,0) hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=7
    hit.AutoButtonColor=false hit.BorderSizePixel=0
    hit.MouseButton1Click:Connect(function() setState(not state) end)

    tab.y=tab.y+H+4
end

-- Button
local function addButton(tab, label, cb)
    local H=30
    local b=Instance.new("TextButton",tab.frame)
    b.Size=UDim2.new(0,ITEM_W,0,H) b.Position=UDim2.new(0,PAD_X,0,tab.y)
    b.BackgroundColor3=Color3.fromRGB(18,18,18) b.Text=label
    b.TextColor3=Color3.fromRGB(225,225,225) b.Font=Enum.Font.Gotham b.TextSize=11
    b.BorderSizePixel=0 b.AutoButtonColor=false b.ZIndex=4
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local s=Instance.new("UIStroke",b) s.Color=Color3.fromRGB(42,42,42) s.Thickness=1
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(34,34,34)}):Play()
        task.delay(0.12,function() TweenService:Create(b,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(18,18,18)}):Play() end)
        task.spawn(cb)
    end)
    tab.y=tab.y+H+4
end

-- Slider
local function addSlider(tab, label, minV, maxV, def, cb)
    local H=46
    local f=Instance.new("Frame",tab.frame)
    f.Size=UDim2.new(0,ITEM_W,0,H) f.Position=UDim2.new(0,PAD_X,0,tab.y)
    f.BackgroundColor3=Color3.fromRGB(18,18,18) f.BorderSizePixel=0 f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)

    local nL=Instance.new("TextLabel",f)
    nL.Size=UDim2.new(0.62,0,0,16) nL.Position=UDim2.new(0,10,0,6)
    nL.BackgroundTransparency=1 nL.Text=label
    nL.TextColor3=Color3.fromRGB(205,205,205) nL.Font=Enum.Font.Gotham nL.TextSize=10
    nL.TextXAlignment=Enum.TextXAlignment.Left nL.ZIndex=5

    local vL=Instance.new("TextLabel",f)
    vL.Size=UDim2.new(0.36,0,0,16) vL.Position=UDim2.new(0.63,0,0,6)
    vL.BackgroundTransparency=1 vL.TextColor3=Color3.fromRGB(138,138,138)
    vL.Font=Enum.Font.Gotham vL.TextSize=10
    vL.TextXAlignment=Enum.TextXAlignment.Right vL.ZIndex=5

    local trk=Instance.new("Frame",f)
    trk.Size=UDim2.new(1,-20,0,3) trk.Position=UDim2.new(0,10,0,33)
    trk.BackgroundColor3=Color3.fromRGB(35,35,35) trk.BorderSizePixel=0 trk.ZIndex=5
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",trk)
    fill.Size=UDim2.new(0,0,1,0) fill.BackgroundColor3=Color3.fromRGB(210,210,210)
    fill.BorderSizePixel=0 fill.ZIndex=6
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local kn=Instance.new("Frame",trk)
    kn.Size=UDim2.new(0,10,0,10) kn.Position=UDim2.new(0,-4,0.5,-5)
    kn.BackgroundColor3=Color3.fromRGB(255,255,255) kn.BorderSizePixel=0 kn.ZIndex=7
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    local cur=def
    local function setV(raw)
        local v=math.clamp(math.floor((tonumber(raw) or minV)*10+0.5)/10,minV,maxV)
        cur=v
        local p=(v-minV)/(maxV-minV)
        fill.Size=UDim2.new(p,0,1,0) kn.Position=UDim2.new(p,-4,0.5,-5)
        vL.Text=tostring(v) pcall(cb,v)
    end
    setV(def)

    local sdrag=false
    local tHit=Instance.new("TextButton",trk)
    tHit.Size=UDim2.new(1,14,1,16) tHit.Position=UDim2.new(0,-7,0,-6)
    tHit.BackgroundTransparency=1 tHit.Text="" tHit.ZIndex=8 tHit.AutoButtonColor=false
    -- Use MouseButton1Down for Delta touch reliability
    tHit.MouseButton1Down:Connect(function(x,_)
        sdrag=true
        setV(minV+(math.clamp((x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1))*(maxV-minV))
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sdrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            setV(minV+(math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1))*(maxV-minV))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sdrag=false end
    end)

    tab.y=tab.y+H+4
end

-- Dropdown
local function addDropdown(tab, label, opts, cb)
    local H=30
    local IH=22
    local f=Instance.new("Frame",tab.frame)
    f.Size=UDim2.new(0,ITEM_W,0,H) f.Position=UDim2.new(0,PAD_X,0,tab.y)
    f.BackgroundColor3=Color3.fromRGB(18,18,18) f.BorderSizePixel=0 f.ZIndex=4 f.ClipsDescendants=false
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)

    local nL=Instance.new("TextLabel",f)
    nL.Size=UDim2.new(0.44,0,1,0) nL.Position=UDim2.new(0,10,0,0)
    nL.BackgroundTransparency=1 nL.Text=label
    nL.TextColor3=Color3.fromRGB(205,205,205) nL.Font=Enum.Font.Gotham nL.TextSize=11
    nL.TextXAlignment=Enum.TextXAlignment.Left nL.ZIndex=5

    local sel=Instance.new("TextButton",f)
    sel.Size=UDim2.new(0.53,-4,0,22) sel.Position=UDim2.new(0.47,0,0.5,-11)
    sel.BackgroundColor3=Color3.fromRGB(24,24,24) sel.Text="None"
    sel.TextColor3=Color3.fromRGB(155,155,155) sel.Font=Enum.Font.Gotham sel.TextSize=10
    sel.BorderSizePixel=0 sel.AutoButtonColor=false sel.ZIndex=5 sel.ClipsDescendants=false
    Instance.new("UICorner",sel).CornerRadius=UDim.new(0,4)
    local ss=Instance.new("UIStroke",sel) ss.Color=Color3.fromRGB(40,40,40) ss.Thickness=1

    local dp=Instance.new("Frame",sel)
    dp.Size=UDim2.new(1,0,0,0) dp.Position=UDim2.new(0,0,1,2)
    dp.BackgroundColor3=Color3.fromRGB(20,20,20) dp.BorderSizePixel=0
    dp.Visible=false dp.ZIndex=20 dp.ClipsDescendants=true
    Instance.new("UICorner",dp).CornerRadius=UDim.new(0,4)
    Instance.new("UIStroke",dp).Color=Color3.fromRGB(38,38,38)

    local open=false
    local items={}
    local function build(o)
        for _,b in ipairs(items) do pcall(function() b:Destroy() end) end items={}
        for idx,opt in ipairs(o) do
            local ob=Instance.new("TextButton",dp)
            ob.Size=UDim2.new(1,0,0,IH) ob.Position=UDim2.new(0,0,0,(idx-1)*IH)
            ob.BackgroundTransparency=1 ob.Text=opt
            ob.TextColor3=Color3.fromRGB(188,188,188) ob.Font=Enum.Font.Gotham ob.TextSize=10
            ob.BorderSizePixel=0 ob.AutoButtonColor=false ob.ZIndex=21
            ob.MouseButton1Click:Connect(function()
                sel.Text=opt open=false dp.Visible=false pcall(cb,opt)
            end)
            table.insert(items,ob)
        end
        dp.Size=UDim2.new(1,0,0,#o*IH)
    end
    build(opts)
    sel.MouseButton1Click:Connect(function() open=not open dp.Visible=open end)

    local api={}
    function api:Refresh(_,o) build(o or {}) end
    function api:Set(v) sel.Text=v or "None" end

    tab.y=tab.y+H+4
    return f,api
end

-- ════════════════════════════════════════════
--  GAME HELPERS
-- ════════════════════════════════════════════
local function getRoles()
    local ok,data=pcall(function() return ReplicatedStorage:FindFirstChild("GetPlayerData",true):InvokeServer() end)
    if not ok or not data then return {} end
    local r={} for p,d in pairs(data) do if not d.Dead then r[p]=d.Role end end return r
end
local function getMurdPos()
    local ok,data=pcall(function() return ReplicatedStorage:FindFirstChild("GetPlayerData",true):InvokeServer() end)
    if not ok or not data then return nil,false end
    for p,d in pairs(data) do
        if d.Role=="Murderer" then
            local pl=Players:FindFirstChild(p) if not pl then continue end
            if pl==LP then return nil,true end
            local c=pl.Character if not c then continue end
            local h=c:FindFirstChild("HumanoidRootPart") if h then return h.Position,false end
        end
    end
    return nil,false
end
local function Fling(tp)
    if not(Char and Hum and Root) then return end
    local TC=tp.Character if not TC then return end
    local TH=TC:FindFirstChildOfClass("Humanoid")
    local THead=TC:FindFirstChild("Head")
    local Acc=TC:FindFirstChildOfClass("Accessory")
    local Handle=Acc and Acc:FindFirstChild("Handle")
    env.OldPos=Root.CFrame
    repeat task.wait() Workspace.CurrentCamera.CameraSubject=THead or Handle or TH
    until Workspace.CurrentCamera.CameraSubject==THead or Handle or TH
    local function FP(bp,Pos,Ang)
        local cf=CFrame.new(bp.Position)*Pos*Ang
        Root.CFrame=cf Char:SetPrimaryPartCFrame(cf)
        Root.Velocity=Vector3.new(9e7,9e8,9e7) Root.RotVelocity=Vector3.new(9e8,9e8,9e8)
    end
    local function SFB(bp)
        local s,ang=tick(),0 env.timeout=env.timeout or 2.5
        repeat
            if Root and TH then ang=ang+100
                for _,off in ipairs({CFrame.new(0,1.5,0),CFrame.new(0,-1.5,0),CFrame.new(2.25,1.5,-2.25),CFrame.new(-2.25,-1.5,2.25)}) do
                    FP(bp,off+TH.MoveDirection,CFrame.Angles(math.rad(ang),0,0)) task.wait()
                end
            end
        until bp.Velocity.Magnitude>500 or tick()-s>env.timeout
    end
    local BV=Instance.new("BodyVelocity") BV.Name="A9xFl" BV.Velocity=Vector3.new(9e8,9e8,9e8)
    BV.MaxForce=Vector3.new(math.huge,math.huge,math.huge) BV.Parent=Root
    Hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    local tgt=(TH and TH.RootPart) or THead or Handle
    if tgt then SFB(tgt) end
    BV:Destroy() Hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    repeat task.wait() Workspace.CurrentCamera.CameraSubject=Hum until Workspace.CurrentCamera.CameraSubject==Hum
    repeat
        local cf=env.OldPos*CFrame.new(0,.5,0) Root.CFrame=cf Char:SetPrimaryPartCFrame(cf)
        Hum:ChangeState("GettingUp")
        for _,p in ipairs(Char:GetChildren()) do if p:IsA("BasePart") then p.Velocity,p.RotVelocity=Vector3.zero,Vector3.zero end end
        task.wait()
    until (Root.Position-env.OldPos.p).Magnitude<25
end

-- ════════════════════════════════════════════
--  PLAYER TAB
-- ════════════════════════════════════════════
addSection(PLAYER,"MOVEMENT")
addToggle(PLAYER,"Infinity Jump",false,function(v)
    env.InfiniteJump=v
    UserInputService.JumpRequest:Connect(function()
        if env.InfiniteJump and Char and Hum then Hum:ChangeState("Jumping") end
    end)
    Notify("Infinity Jump",v and "ON" or "OFF")
end)
addToggle(PLAYER,"Noclip",false,function(v)
    env.Noclip=v
    if not v and Char then for _,c in pairs(Char:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=true end end end
    task.spawn(function()
        while env.Noclip do
            if Char then for _,c in pairs(Char:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false end end end
            task.wait()
        end
    end)
    Notify("Noclip",v and "ON" or "OFF")
end)
addSlider(PLAYER,"WalkSpeed",16,350,16,function(v)
    env.Walkspeed=v if Char and Hum then Hum.WalkSpeed=v end
end)
addToggle(PLAYER,"WalkSpeed Auto",false,function(v)
    env.KeepWS=v
    task.spawn(function()
        while env.KeepWS do
            if Char and Hum and Hum.WalkSpeed~=(env.Walkspeed or 16) then Hum.WalkSpeed=env.Walkspeed or 16 end
            task.wait()
        end
    end)
    Notify("WalkSpeed Auto",v and "ON" or "OFF")
end)
addSlider(PLAYER,"JumpPower",50,500,50,function(v)
    env.Jumppower=v if Char and Hum then Hum.JumpPower=v end
end)
addToggle(PLAYER,"JumpPower Auto",false,function(v)
    env.KeepJP=v
    task.spawn(function()
        while env.KeepJP do
            if Char and Hum and Hum.JumpPower~=(env.Jumppower or 50) then Hum.JumpPower=env.Jumppower or 50 end
            task.wait()
        end
    end)
    Notify("JumpPower Auto",v and "ON" or "OFF")
end)
addSection(PLAYER,"SURVIVAL")
addToggle(PLAYER,"God Mode",false,function(v)
    env.GodMode=v
    local gc
    local function upd()
        if gc then gc:Disconnect() gc=nil end
        if Hum then gc=Hum.HealthChanged:Connect(function()
            if env.GodMode and Hum.Health<Hum.MaxHealth then Hum.Health=Hum.MaxHealth end
        end) end
    end
    LP.CharacterAdded:Connect(function(c) Char=c Hum=c:WaitForChild("Humanoid",10) upd() end)
    upd()
    Notify("God Mode",v and "ON" or "OFF")
end)
finalizeTab(PLAYER)

-- ════════════════════════════════════════════
--  MISC TAB
-- ════════════════════════════════════════════
addSection(MISC,"ESP")
addToggle(MISC,"ESP Player (Role)",false,function(v)
    env.ESP=v
    local RC={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(80,140,255),Hero=Color3.fromRGB(255,215,0),Innocent=Color3.fromRGB(80,255,80),Default=Color3.fromRGB(200,200,200)}
    local function clrESP() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then
        local h=p.Character:FindFirstChild("Head") if h then local e=h:FindFirstChild("RESP") if e then e:Destroy() end end
        local hl=p.Character:FindFirstChild("RHL") if hl then hl:Destroy() end
    end end end
    local function mkESP(head,role,nm)
        local bb=Instance.new("BillboardGui") bb.Name="RESP" bb.Adornee=head bb.Size=UDim2.new(5,0,5,0) bb.AlwaysOnTop=true bb.Parent=head
        local l=Instance.new("TextLabel",bb) l.Name="RL" l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.TextStrokeTransparency=0 l.TextSize=14 l.TextColor3=RC[role] or RC.Default l.Font=Enum.Font.FredokaOne l.Text=role.." | "..nm
    end
    local function mkHL(char,role)
        local ex=char:FindFirstChild("RHL") if ex then ex:Destroy() end
        local hl=Instance.new("Highlight") hl.Name="RHL" hl.FillColor=RC[role] or RC.Default hl.OutlineColor=Color3.new(1,1,1) hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.FillTransparency=0.4 hl.OutlineTransparency=0 hl.Parent=char
    end
    local function upd()
        local roles=getRoles()
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then
            local h=p.Character:FindFirstChild("Head") if not h then continue end
            local role=roles[p.Name] or "Default"
            if not h:FindFirstChild("RESP") then mkESP(h,role,p.Name)
            else local l=h.RESP:FindFirstChild("RL") if l then l.Text=role.." | "..p.Name l.TextColor3=RC[role] or RC.Default end end
            local hl=p.Character:FindFirstChild("RHL")
            if not hl then mkHL(p.Character,role) else hl.FillColor=RC[role] or RC.Default end
        end end
    end
    if v then task.spawn(function() while env.ESP do pcall(upd) task.wait(0.25) end clrESP() end)
    else clrESP() end
    Notify("ESP Player",v and "ON" or "OFF")
end)
addToggle(MISC,"ESP Gun",false,function(v)
    env.GunESP=v
    if not v then local g=Workspace:FindFirstChild("GunDrop",true) if g then
        local gh=g:FindFirstChild("GH") if gh then gh:Destroy() end
        local ge=g:FindFirstChild("GE") if ge then ge:Destroy() end
    end end
    task.spawn(function()
        while env.GunESP do
            local g=Workspace:FindFirstChild("GunDrop",true) if g then
                if not g:FindFirstChild("GH") then local hl=Instance.new("Highlight",g) hl.Name="GH" hl.FillColor=Color3.new(1,1,0) hl.OutlineColor=Color3.new(1,1,1) hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.FillTransparency=0.4 hl.OutlineTransparency=0.5 end
                if not g:FindFirstChild("GE") then local bb=Instance.new("BillboardGui") bb.Name="GE" bb.Adornee=g bb.Size=UDim2.new(5,0,5,0) bb.AlwaysOnTop=true bb.Parent=g local l=Instance.new("TextLabel",bb) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.TextStrokeTransparency=0 l.TextColor3=Color3.fromRGB(255,255,0) l.Font=Enum.Font.FredokaOne l.TextSize=16 l.Text="Gun Drop" end
            end task.wait(0.1)
        end
    end)
    Notify("ESP Gun",v and "ON" or "OFF")
end)
addSection(MISC,"GUN")
addButton(MISC,"Grab Gun",function()
    if not(Char and Root) then return end
    local g=Workspace:FindFirstChild("GunDrop",true)
    if g then
        if firetouchinterest then firetouchinterest(Root,g,0) firetouchinterest(Root,g,1) else g.CFrame=Root.CFrame end
        Notify("Grab Gun","Grabbed!")
    else Notify("Grab Gun","No gun on map") end
end)
addToggle(MISC,"Auto Grab Gun",false,function(v)
    env.AGG=v
    task.spawn(function()
        while env.AGG do
            if Char and Root then local g=Workspace:FindFirstChild("GunDrop",true) if g then
                if firetouchinterest then firetouchinterest(Root,g,0) firetouchinterest(Root,g,1) else g.CFrame=Root.CFrame end
            end end task.wait(0.1)
        end
    end)
    Notify("Auto Grab Gun",v and "ON" or "OFF")
end)
addButton(MISC,"Steal Gun (Sheriff/Hero)",function()
    if not(Char and Hum and BP) then return end
    local stolen=false
    for _,p in pairs(Players:GetPlayers()) do if p~=LP then
        if p.Character and p.Character:FindFirstChild("Gun") then
            p.Character.Gun.Parent=Char Hum:EquipTool(Char:FindFirstChild("Gun")) Hum:UnequipTools() stolen=true
        elseif p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun") then
            p.Backpack.Gun.Parent=BP Hum:EquipTool(BP:FindFirstChild("Gun")) Hum:UnequipTools() stolen=true
        end
    end end
    Notify("Steal Gun",stolen and "Stolen!" or "No gun found")
end)
addToggle(MISC,"Shoot Murder Button",false,function(v)
    local gp pcall(function() gp=gethui and gethui() end)
    if not gp then pcall(function() gp=game:GetService("CoreGui") end) end
    if not gp then gp=LP.PlayerGui end
    if v then
        if not gp:FindFirstChild("GunW") then
            local G=Instance.new("ScreenGui",gp) G.Name="GunW" G.ResetOnSpawn=false G.DisplayOrder=200 G.IgnoreGuiInset=true
            local tb=Instance.new("TextButton",G) tb.Draggable=true tb.Position=UDim2.new(0.5,160,0.5,-150) tb.Size=UDim2.new(0,54,0,42) tb.BackgroundColor3=Color3.fromRGB(15,15,15) tb.Text="SHOOT\nMURD" tb.TextColor3=Color3.fromRGB(255,255,255) tb.Font=Enum.Font.GothamBold tb.TextSize=9 tb.BorderSizePixel=0 tb.TextWrapped=true tb.AutoButtonColor=false
            Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
            local ts=Instance.new("UIStroke",tb) ts.Color=Color3.fromRGB(255,255,255) ts.Thickness=1 ts.Transparency=0.68
            tb.MouseButton1Click:Connect(function()
                if Char and Char:FindFirstChild("Gun") then
                    pcall(function() local tp=getMurdPos() Char.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1,tp,"AH2") end)
                    Notify("Shoot Murder","Fired!")
                else Notify("Shoot Murder","Equip gun first") end
            end)
        end
    else local w=gp:FindFirstChild("GunW") if w then w:Destroy() end end
    Notify("Shoot Murder Btn",v and "Shown" or "Hidden")
end)
addToggle(MISC,"Gun Aimbot",false,function(v)
    if not env._AbInit then
        env._AbInit=true env._AbOk=false
        pcall(function()
            if not getnamecallmethod or not checkcaller then return end
            local mt=(getrawmetatable and getrawmetatable(game)) or (debug and debug.getmetatable and debug.getmetatable(game))
            if not mt then return end
            local hf
            local function h(self,...)
                local m=getnamecallmethod()
                if not checkcaller() and m=="InvokeServer" and tostring(self)=="RemoteFunction" and env.GunAimbot then return nil end
                return hf(self,...)
            end
            if hookmetamethod and newcclosure then hf=hookmetamethod(game,"__namecall",newcclosure(h)) env._AbOk=true
            elseif mt and setreadonly and newcclosure then setreadonly(mt,false) hf=mt.__namecall mt.__namecall=newcclosure(h) setreadonly(mt,true) env._AbOk=true
            elseif hookmetamethod then hf=hookmetamethod(game,"__namecall",h) env._AbOk=true end
        end)
    end
    if not env._AbOk then Notify("Gun Aimbot","Executor not supported") return end
    env.GunAimbot=v env.GBC=env.GBC or {}
    if not v then if env.GBC.c then env.GBC.c:Disconnect() env.GBC.c=nil end Notify("Gun Aimbot","OFF") return end
    task.spawn(function()
        while env.GunAimbot do
            if Char and Char:FindFirstChild("Gun") then
                local gun=Char:FindFirstChild("Gun") local ks=gun:FindFirstChild("KnifeLocal") local cb2=ks and ks:FindFirstChild("CreateBeam") local rem=cb2 and cb2:FindFirstChild("RemoteFunction")
                if rem and not env.GBC.c then env.GBC.c=gun.Activated:Connect(function()
                    local tp,isSelf=getMurdPos() if tp and not isSelf then rem:InvokeServer(1,tp,"AH2") end
                end) end
            else if env.GBC.c then env.GBC.c:Disconnect() env.GBC.c=nil end end
            task.wait(0.25)
        end
        if env.GBC.c then env.GBC.c:Disconnect() env.GBC.c=nil end
    end)
    Notify("Gun Aimbot","ON")
end)
addSection(MISC,"COMBAT")
addToggle(MISC,"Touch Fling",false,function(v)
    env.TF=v
    task.spawn(function()
        local vel,mv=nil,0.1
        while env.TF do
            if Root and Char and Char.Parent then
                RunService.Heartbeat:Wait() vel=Root.Velocity Root.Velocity=vel*9e8+Vector3.new(0,9e8,0)
                RunService.RenderStepped:Wait() if Root and Root.Parent then Root.Velocity=vel end
                RunService.Stepped:Wait() if Root and Root.Parent then Root.Velocity=vel+Vector3.new(0,mv,0) mv=mv*-1 end
            else task.wait() end
        end
    end)
    Notify("Touch Fling",v and "ON" or "OFF")
end)
addToggle(MISC,"Noclip Players (AntiFling)",false,function(v)
    env.NCP=v
    if not v then for _,p in pairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,pt in pairs(p.Character:GetDescendants()) do if pt:IsA("BasePart") then pt.CanCollide=true end end end end end
    task.spawn(function()
        while env.NCP do for _,p in pairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,pt in pairs(p.Character:GetDescendants()) do if pt:IsA("BasePart") then pt.CanCollide=false end end end end task.wait() end
    end)
    Notify("Noclip Players",v and "ON" or "OFF")
end)
addSlider(MISC,"Fling Timeout",0.5,10,2.5,function(v) env.timeout=v end)
addButton(MISC,"Fling Murderer",function()
    local found=false for p,r in pairs(getRoles()) do if r=="Murderer" then
        local pl=Players:FindFirstChild(p) if pl and pl~=LP then found=true Notify("Fling","Flinging: "..p) task.spawn(Fling,pl) break end
    end end
    if not found then Notify("Fling Murderer","No Murderer found") end
end)
addButton(MISC,"Fling Sheriff / Hero",function()
    local found=false for p,r in pairs(getRoles()) do if r=="Sheriff" or r=="Hero" then
        local pl=Players:FindFirstChild(p) if pl and pl~=LP then found=true Notify("Fling",r..": "..p) task.spawn(Fling,pl) break end
    end end
    if not found then Notify("Fling Sheriff/Hero","No target found") end
end)
-- ─── SELECT PLAYER: inline scrollable list ───────────────────────────────
-- Section label
local _selSecLbl = Instance.new("TextLabel", MISC.frame)
_selSecLbl.Size=UDim2.new(0,ITEM_W,0,18) _selSecLbl.Position=UDim2.new(0,PAD_X,0,MISC.y)
_selSecLbl.BackgroundTransparency=1 _selSecLbl.Text="SELECT PLAYER"
_selSecLbl.TextColor3=Color3.fromRGB(65,65,65) _selSecLbl.Font=Enum.Font.GothamBold _selSecLbl.TextSize=9
_selSecLbl.TextXAlignment=Enum.TextXAlignment.Left _selSecLbl.ZIndex=4
MISC.y = MISC.y + 21

-- Selected player display label
local _selDisp = Instance.new("Frame", MISC.frame)
_selDisp.Size=UDim2.new(0,ITEM_W,0,26) _selDisp.Position=UDim2.new(0,PAD_X,0,MISC.y)
_selDisp.BackgroundColor3=Color3.fromRGB(18,18,18) _selDisp.BorderSizePixel=0 _selDisp.ZIndex=4
Instance.new("UICorner",_selDisp).CornerRadius=UDim.new(0,6)
local _selDispTxt = Instance.new("TextLabel",_selDisp)
_selDispTxt.Size=UDim2.new(1,-10,1,0) _selDispTxt.Position=UDim2.new(0,10,0,0)
_selDispTxt.BackgroundTransparency=1 _selDispTxt.Text="None selected"
_selDispTxt.TextColor3=Color3.fromRGB(115,115,115) _selDispTxt.Font=Enum.Font.Gotham _selDispTxt.TextSize=10
_selDispTxt.TextXAlignment=Enum.TextXAlignment.Left _selDispTxt.ZIndex=5
MISC.y = MISC.y + 26 + 4

-- Player list scroll container (fixed 120px height, manual canvas)
local PLH = 120   -- player list box height
local _plBox = Instance.new("Frame", MISC.frame)
_plBox.Size=UDim2.new(0,ITEM_W,0,PLH) _plBox.Position=UDim2.new(0,PAD_X,0,MISC.y)
_plBox.BackgroundColor3=Color3.fromRGB(15,15,15) _plBox.BorderSizePixel=0 _plBox.ZIndex=4 _plBox.ClipsDescendants=true
Instance.new("UICorner",_plBox).CornerRadius=UDim.new(0,6)
local _plStroke=Instance.new("UIStroke",_plBox) _plStroke.Color=Color3.fromRGB(32,32,32) _plStroke.Thickness=1

local _plScroll = Instance.new("ScrollingFrame", _plBox)
_plScroll.Size=UDim2.new(1,0,1,0) _plScroll.Position=UDim2.new(0,0,0,0)
_plScroll.BackgroundTransparency=1 _plScroll.BorderSizePixel=0
_plScroll.ScrollBarThickness=2 _plScroll.ScrollBarImageColor3=Color3.fromRGB(55,55,55)
_plScroll.CanvasSize=UDim2.new(0,0,0,0) _plScroll.ElasticBehavior=Enum.ElasticBehavior.Never
_plScroll.ZIndex=5 _plScroll.ClipsDescendants=true

MISC.y = MISC.y + PLH + 4

-- Refresh button
local _refBtn = Instance.new("TextButton", MISC.frame)
_refBtn.Size=UDim2.new(0,ITEM_W,0,26) _refBtn.Position=UDim2.new(0,PAD_X,0,MISC.y)
_refBtn.BackgroundColor3=Color3.fromRGB(20,20,20) _refBtn.Text="Refresh Player List"
_refBtn.TextColor3=Color3.fromRGB(170,170,170) _refBtn.Font=Enum.Font.Gotham _refBtn.TextSize=10
_refBtn.BorderSizePixel=0 _refBtn.AutoButtonColor=false _refBtn.ZIndex=4
Instance.new("UICorner",_refBtn).CornerRadius=UDim.new(0,6)
local _refSt=Instance.new("UIStroke",_refBtn) _refSt.Color=Color3.fromRGB(38,38,38) _refSt.Thickness=1
MISC.y = MISC.y + 26 + 4

-- Player list builder (manual y, no UIListLayout)
local _tgt = nil
local _selBtns = {}
local PLR_ITEM_H = 30

local function buildPlayerList()
    -- clear old buttons
    for _, b in ipairs(_selBtns) do pcall(function() b:Destroy() end) end
    _selBtns = {}

    local py = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local pb = Instance.new("TextButton", _plScroll)
            pb.Size=UDim2.new(1,-4,0,PLR_ITEM_H) pb.Position=UDim2.new(0,2,0,py)
            pb.BackgroundTransparency=1 pb.Text=p.Name
            pb.TextColor3=Color3.fromRGB(185,185,185) pb.Font=Enum.Font.Gotham pb.TextSize=11
            pb.TextXAlignment=Enum.TextXAlignment.Left pb.BorderSizePixel=0 pb.AutoButtonColor=false pb.ZIndex=6
            -- left pad text
            local pPad=Instance.new("UIPadding",pb) pPad.PaddingLeft=UDim.new(0,8)
            -- selection highlight bar
            local hiBar=Instance.new("Frame",pb) hiBar.Name="HiBar"
            hiBar.Size=UDim2.new(0,2,0,18) hiBar.Position=UDim2.new(0,0,0.5,-9)
            hiBar.BackgroundColor3=Color3.fromRGB(255,255,255) hiBar.BorderSizePixel=0 hiBar.Visible=false hiBar.ZIndex=7
            Instance.new("UICorner",hiBar).CornerRadius=UDim.new(1,0)

            pb.MouseButton1Click:Connect(function()
                -- deselect all
                for _,ob in ipairs(_selBtns) do
                    pcall(function()
                        ob.TextColor3=Color3.fromRGB(185,185,185)
                        local h=ob:FindFirstChild("HiBar") if h then h.Visible=false end
                    end)
                end
                -- select this
                _tgt = p.Name
                pb.TextColor3=Color3.fromRGB(255,255,255)
                hiBar.Visible=true
                _selDispTxt.Text=p.Name
                _selDispTxt.TextColor3=Color3.fromRGB(230,230,230)
                Notify("Target","Set: "..p.Name)
            end)

            -- keep current selection highlighted after rebuild
            if p.Name == _tgt then
                pb.TextColor3=Color3.fromRGB(255,255,255)
                hiBar.Visible=true
            end

            table.insert(_selBtns, pb)
            py = py + PLR_ITEM_H
        end
    end

    _plScroll.CanvasSize = UDim2.new(0,0,0,py)

    -- Update display if selected player left
    if _tgt and not Players:FindFirstChild(_tgt) then
        _tgt=nil _selDispTxt.Text="None selected" _selDispTxt.TextColor3=Color3.fromRGB(115,115,115)
    end
end

buildPlayerList()

_refBtn.MouseButton1Click:Connect(function()
    TweenService:Create(_refBtn,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(34,34,34)}):Play()
    task.delay(0.12,function() TweenService:Create(_refBtn,TweenInfo.new(0.07),{BackgroundColor3=Color3.fromRGB(20,20,20)}):Play() end)
    buildPlayerList()
    Notify("Player List","Refreshed!")
end)

-- Real-time auto refresh
Players.PlayerAdded:Connect(function() task.wait(0.1) buildPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) buildPlayerList() end)
addButton(MISC,"Fling Selected Player",function()
    if _tgt then
        local p=Players:FindFirstChild(_tgt)
        if p and p~=LP then Notify("Fling","Flinging: ".._tgt) task.spawn(Fling,p)
        else Notify("Fling","Player not in game") end
    else Notify("Fling","Select a player first") end
end)
addSection(MISC,"TELEPORT")
addButton(MISC,"Teleport To Map",function()
    local m=Workspace:FindFirstChild("CoinContainer",true)
    if m and m.Parent then
        local pt=m:FindFirstChildWhichIsA("BasePart",true) or m.Parent:FindFirstChildWhichIsA("BasePart",true)
        if pt then local cf=pt.CFrame*CFrame.new(0,2,0)
            if Char and Char.PrimaryPart then Char:PivotTo(cf) elseif Root then Root.CFrame=cf end
            Notify("Teleport","Teleported to Map")
        else Notify("Teleport","Map part not found") end
    else Notify("Teleport","Map not loaded") end
end)
addButton(MISC,"Teleport To Lobby",function()
    local lb=Workspace:FindFirstChild("Lobby",true)
    if lb and lb.Parent then
        local pt=lb:FindFirstChildWhichIsA("BasePart",true) or lb.Parent:FindFirstChildWhichIsA("BasePart",true)
        if pt then local cf=pt.CFrame*CFrame.new(0,2,0)
            if Char and Char.PrimaryPart then Char:PivotTo(cf) elseif Root then Root.CFrame=cf end
            Notify("Teleport","Teleported to Lobby")
        else Notify("Teleport","Lobby not found") end
    else Notify("Teleport","Lobby not found") end
end)
finalizeTab(MISC)

-- ════════════════════════════════════════════
--  SIDEBAR BUTTONS (manual y, no layout)
-- ════════════════════════════════════════════
local TAB_LIST={{name="Player",tab=PLAYER},{name="Misc",tab=MISC}}
local _active=nil

local function switchTab(name)
    _active=name
    for _,t in ipairs(TAB_LIST) do
        t.tab.frame.Visible=(t.name==name)
        if t.name==name then flushCanvas(name) end
    end
    for _,ch in ipairs(SB:GetChildren()) do
        if ch:IsA("TextButton") then
            local isC=(ch.Name==name.."SBtn")
            TweenService:Create(ch,TweenInfo.new(0.12),{TextColor3=isC and Color3.fromRGB(255,255,255) or Color3.fromRGB(82,82,82)}):Play()
            local ind=ch:FindFirstChild("Ind") if ind then ind.Visible=isC end
        end
    end
end

local sbY=8
for i,t in ipairs(TAB_LIST) do
    local SBH=40
    local sb=Instance.new("TextButton",SB)
    sb.Name=t.name.."SBtn"
    sb.Size=UDim2.new(1,0,0,SBH) sb.Position=UDim2.new(0,0,0,sbY)
    sb.BackgroundTransparency=1 sb.Text=t.name
    sb.TextColor3=Color3.fromRGB(82,82,82) sb.Font=Enum.Font.GothamBold sb.TextSize=11
    sb.BorderSizePixel=0 sb.AutoButtonColor=false sb.ZIndex=4

    local ind=Instance.new("Frame",sb) ind.Name="Ind"
    ind.Size=UDim2.new(0,2,0,16) ind.Position=UDim2.new(0,0,0.5,-8)
    ind.BackgroundColor3=Color3.fromRGB(255,255,255) ind.BorderSizePixel=0 ind.Visible=false ind.ZIndex=5
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)

    sb.MouseButton1Click:Connect(function() switchTab(t.name) end)
    sbY=sbY+SBH+2
end
switchTab("Player")

-- ════════════════════════════════════════════
--  DRAG — TextButton drag handle (Delta touch fix)
-- ════════════════════════════════════════════
-- Root cause of previous drag failure:
-- Frame.InputBegan is unreliable on Delta mobile touch.
-- TextButton.MouseButton1Down fires consistently on all executors incl. Delta.
do
    local drag=false
    local dStart=Vector2.new(0,0)
    local fStart=MF.Position

    DragBtn.MouseButton1Down:Connect(function(x, y)
        drag=true
        dStart=Vector2.new(x, y)
        fStart=MF.Position
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local cur=Vector2.new(i.Position.X, i.Position.Y)
            local d=cur-dStart
            MF.Position=UDim2.new(fStart.X.Scale, fStart.X.Offset+d.X, fStart.Y.Scale, fStart.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
end

-- ════════════════════════════════════════════
--  MINIMIZE / CLOSE  (smooth elastic animations)
-- ════════════════════════════════════════════
local _animating = false

BMini.MouseButton1Click:Connect(function()
    if _animating then return end _animating=true
    -- Shrink down with Quart ease
    TweenService:Create(MF, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size=UDim2.new(0,UW,0,0), BackgroundTransparency=0.5}):Play()
    task.delay(0.23, function()
        MF.Visible=false
        MF.Size=UDim2.new(0,UW,0,UH)
        MF.BackgroundTransparency=0
        MinBtn.Visible=true
        _animating=false
    end)
end)

MinBtn.MouseButton1Click:Connect(function()
    if _animating then return end _animating=true
    MinBtn.Visible=false
    MF.Visible=true
    MF.Size=UDim2.new(0,UW,0,0)
    MF.BackgroundTransparency=0.6
    -- Grow open with Back elastic bounce
    TweenService:Create(MF, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size=UDim2.new(0,UW,0,UH), BackgroundTransparency=0}):Play()
    task.delay(0.33, function() _animating=false end)
end)

BClose.MouseButton1Click:Connect(function()
    if _animating then return end _animating=true
    TweenService:Create(MF, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Size=UDim2.new(0,UW,0,0), BackgroundTransparency=1}):Play()
    task.delay(0.21, function()
        pcall(function() SG:Destroy() NF:Destroy() end)
    end)
end)

-- ════════════════════════════════════════════
--  WELCOME
-- ════════════════════════════════════════════
task.delay(0.5,function()
    Notify("Anonymous9x MM2","Welcome, "..LP.DisplayName.."!")
end)
