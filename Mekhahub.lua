--[[
    MEKHA HUB v3.5 - STABLE EDITION
    Fling Things and People
    Рабочие визуалы • Быстрый Anti Grab • Без лагов
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local C = {
    BG = Color3.fromRGB(14, 12, 22),
    Panel = Color3.fromRGB(22, 18, 34),
    PanelLight = Color3.fromRGB(32, 27, 48),
    Accent = Color3.fromRGB(138, 80, 255),
    AccentLight = Color3.fromRGB(180, 130, 255),
    Text = Color3.fromRGB(235, 230, 250),
    TextDim = Color3.fromRGB(140, 135, 165),
    Success = Color3.fromRGB(80, 220, 140),
    Danger = Color3.fromRGB(255, 80, 100),
}

local Flags = {
    SuperStrength = false,
    AntiGrab = false, GucciAnti = false, AntiBlobman = false,
    AntiFling = false, AntiTeleport = false, AntiKick = false,
    AntiLag = false, AutoAntiLag = false,
    Fly = false, Speed = false, Jump = false, InfiniteJump = false, NoClip = false,
    ESP = false, Fullbright = false,
    Immortality = false,
}
local SpeedValue = 50
local JumpValue = 100
local FlingStrength = 8500000
local connections = {}
local espFolder = Instance.new("Folder", game:GetService("CoreGui"))
espFolder.Name = "MekhaESP"

-- Менеджер соединений (фикс лагов)
local FeatureConns = {}
local function SetFeature(name, conn)
    if FeatureConns[name] then
        pcall(function() FeatureConns[name]:Disconnect() end)
    end
    FeatureConns[name] = conn
end
local function ClearFeature(name)
    if FeatureConns[name] then
        pcall(function() FeatureConns[name]:Disconnect() end)
        FeatureConns[name] = nil
    end
end

--// ============================================
--// SUPER STRENGTH (рабочий)
--// ============================================
local superConn = nil
local function EnableSuperStrength(on)
    Flags.SuperStrength = on
    if superConn then superConn:Disconnect() superConn = nil end
    if not on then return end

    superConn = Workspace.ChildAdded:Connect(function(NewModel)
        if not Flags.SuperStrength then return end
        if NewModel.Name ~= "GrabParts" then return end

        local success, PartToImpulse = pcall(function()
            return NewModel:WaitForChild("GrabPart", 2):WaitForChild("WeldConstraint", 2).Part1
        end)
        if not success or not PartToImpulse then return end

        local VelocityObject = Instance.new("BodyVelocity")
        VelocityObject.Name = "FlingVelocity"
        VelocityObject.Parent = PartToImpulse

        local conn
        conn = NewModel:GetPropertyChangedSignal("Parent"):Connect(function()
            if NewModel.Parent == nil then
                if Flags.SuperStrength then
                    VelocityObject.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    VelocityObject.Velocity = Workspace.CurrentCamera.CFrame.LookVector * FlingStrength
                    Debris:AddItem(VelocityObject, 1)
                else
                    VelocityObject:Destroy()
                end
                if conn then conn:Disconnect() end
            end
        end)
    end)
end

--// ============================================
--// ЗАЩИТА (быстрая, без лагов)
--// ============================================
local function EnableAntiGrab(on)
    Flags.AntiGrab = on
    ClearFeature("AntiGrab")
    if not on then return end
    SetFeature("AntiGrab", RunService.Heartbeat:Connect(function()
        if not Flags.AntiGrab then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Убираем GrabPoint со своего персонажа
        for _, obj in ipairs(char:GetDescendants()) do
            if obj.Name == "GrabPoint" then obj:Destroy() end
        end

        -- Ищем только рядом (20 стадов)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and (tHrp.Position - hrp.Position).Magnitude < 20 then
                    for _, obj in ipairs(plr.Character:GetDescendants()) do
                        if obj.Name == "GrabPoint" and obj:IsA("Attachment") then
                            local p = obj.Parent
                            if p and p:IsA("BasePart") then
                                p.CanCollide = false
                                p.Massless = true
                            end
                        end
                    end
                end
            end
        end
    end))
end

local function EnableGucciAnti(on)
    Flags.GucciAnti = on
    ClearFeature("GucciAnti")
    if not on then return end
    SetFeature("GucciAnti", RunService.Heartbeat:Connect(function()
        if not Flags.GucciAnti then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.1, 0.5)
                    part.Massless = false
                end)
            end
        end
    end))
end

local function EnableAntiBlobman(on)
    Flags.AntiBlobman = on
    ClearFeature("AntiBlobman")
    if not on then return end
    SetFeature("AntiBlobman", RunService.Heartbeat:Connect(function()
        if not Flags.AntiBlobman then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            local model = hum.SeatPart:FindFirstAncestorOfClass("Model")
            if model and model.Name:lower():find("blobman") then
                hum.Sit = false
                hum.Jump = true
            end
        end
    end))
end

local function EnableAntiFling(on)
    Flags.AntiFling = on
    ClearFeature("AntiFling")
    if not on then return end
    SetFeature("AntiFling", RunService.Heartbeat:Connect(function()
        if not Flags.AntiFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 150 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end))
end

local function EnableAntiKick(on)
    Flags.AntiKick = on
    ClearFeature("AntiKick")
    if not on then return end
    SetFeature("AntiKick", RunService.Heartbeat:Connect(function()
        if not Flags.AntiKick then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 200 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end))
end

local lastPos = nil
local function EnableAntiTeleport(on)
    Flags.AntiTeleport = on
    ClearFeature("AntiTeleport")
    if not on then return end
    SetFeature("AntiTeleport", RunService.Heartbeat:Connect(function()
        if not Flags.AntiTeleport then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if lastPos then
            local dist = (hrp.Position - lastPos).Magnitude
            if dist > 50 and dist < 5000 then
                hrp.CFrame = CFrame.new(lastPos)
            end
        end
        lastPos = hrp.Position
    end))
end

--// ============================================
--// ANTI LAG (без лагов)
--// ============================================
local function EnableAntiLag(on)
    Flags.AntiLag = on
    ClearFeature("AntiLag")
    if not on then return end

    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("PostEffect") then
                obj.Enabled = false
            end
        end)
    end

    SetFeature("AntiLag", Workspace.DescendantAdded:Connect(function(obj)
        if not Flags.AntiLag then return end
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end
        end)
    end))
end

local autoAntiLagConn = nil
local lastAutoLagTime = 0
local AUTO_LAG_COOLDOWN = 300

local function EnableAutoAntiLag(on)
    Flags.AutoAntiLag = on
    if autoAntiLagConn then autoAntiLagConn:Disconnect() autoAntiLagConn = nil end
    if not on then return end

    local frameCount = 0
    local lastCheck = tick()
    autoAntiLagConn = RunService.Heartbeat:Connect(function()
        if not Flags.AutoAntiLag then return end
        frameCount += 1
        local now = tick()
        if now - lastCheck >= 1 then
            local fps = frameCount / (now - lastCheck)
            frameCount = 0
            lastCheck = now
            if fps < 20 and now - lastAutoLagTime > AUTO_LAG_COOLDOWN then
                EnableAntiLag(true)
                lastAutoLagTime = now
                task.delay(AUTO_LAG_COOLDOWN, function()
                    if Flags.AutoAntiLag then EnableAntiLag(false) end
                end)
            end
        end
    end)
end

--// ============================================
--// IMMORTALITY
--// ============================================
local function EnableImmortality(on)
    Flags.Immortality = on
    ClearFeature("Immortality")
    if not on then return end
    SetFeature("Immortality", RunService.Heartbeat:Connect(function()
        if not Flags.Immortality then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.BreakJointsOnDeath = false
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -50 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
        end
    end))
end

--// ============================================
--// ДВИЖЕНИЕ
--// ============================================
local flyBV, flyBG
local function EnableFly(on)
    Flags.Fly = on
    ClearFeature("Fly")
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if not on then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 1000

    SetFeature("Fly", RunService.RenderStepped:Connect(function()
        if not Flags.Fly or not flyBV or not flyBV.Parent then return end
        local cam = Workspace.CurrentCamera
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = move.Magnitude > 0 and move.Unit * SpeedValue or Vector3.new(0, 0, 0)
        flyBG.CFrame = cam.CFrame
    end))
end

local function EnableSpeed(on)
    Flags.Speed = on
    ClearFeature("Speed")
    if not on then return end
    SetFeature("Speed", RunService.Heartbeat:Connect(function()
        if not Flags.Speed then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = SpeedValue end
    end))
end

local function EnableJump(on)
    Flags.Jump = on
    ClearFeature("Jump")
    if not on then return end
    SetFeature("Jump", RunService.Heartbeat:Connect(function()
        if not Flags.Jump then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = JumpValue hum.UseJumpPower = true end
    end))
end

local function EnableInfJump(on)
    Flags.InfiniteJump = on
    ClearFeature("InfiniteJump")
    if not on then return end
    SetFeature("InfiniteJump", UserInputService.JumpRequest:Connect(function()
        if not Flags.InfiniteJump then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
end

local function EnableNoClip(on)
    Flags.NoClip = on
    ClearFeature("NoClip")
    if not on then return end
    SetFeature("NoClip", RunService.Stepped:Connect(function()
        if not Flags.NoClip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))
end

--// ============================================
--// ВИЗУАЛЫ (рабочие)
--// ============================================
local espConn = nil
local function AddESPToPlayer(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if plr.Character:FindFirstChild("MekhaHighlight") then return end
    if espFolder:FindFirstChild(plr.Name) then return end
    local hl = Instance.new("Highlight")
    hl.Name = plr.Name
    hl.Adornee = plr.Character
    hl.FillColor = C.Danger
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.Parent = espFolder
end

local function EnableESP(on)
    Flags.ESP = on
    if espConn then espConn:Disconnect() espConn = nil end

    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            AddESPToPlayer(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(1)
                if Flags.ESP then AddESPToPlayer(plr) end
            end)
        end
        espConn = Players.PlayerAdded:Connect(function(plr)
            task.wait(1)
            if Flags.ESP then AddESPToPlayer(plr) end
        end)
    else
        espFolder:ClearAllChildren()
    end
end

local function EnableFullbright(on)
    Flags.Fullbright = on
    if on then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 5
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 2
    end
end

--// ============================================
--// UI
--// ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MekhaUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 20, 0.35, 0)
OpenBtn.BackgroundColor3 = C.Accent
OpenBtn.Text = "☄"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.TextSize = 24
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Viewport = Workspace.CurrentCamera.ViewportSize
local WIDTH = IsMobile and math.min(340, Viewport.X - 20) or 680
local HEIGHT = IsMobile and math.min(Viewport.Y - 100, 440) or 450

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
if IsMobile then
    Main.Position = UDim2.new(0, (Viewport.X - WIDTH) / 2, 0, 60)
else
    Main.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
end
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.Accent ms.Thickness = 1.5 ms.Transparency = 0.3

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = C.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 36, 0, 36)
Logo.Position = UDim2.new(0, 10, 0, 10)
Logo.BackgroundColor3 = C.Accent
Logo.Text = "☄"
Logo.TextColor3 = Color3.new(1, 1, 1)
Logo.TextSize = 20
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Header
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -160, 0, 20)
TitleLbl.Position = UDim2.new(0, 54, 0, 10)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "MEKHA HUB"
TitleLbl.TextColor3 = C.Text
TitleLbl.TextSize = 14
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Header

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, -160, 0, 16)
SubLbl.Position = UDim2.new(0, 54, 0, 28)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "v3.5 • Stable"
SubLbl.TextColor3 = C.TextDim
SubLbl.TextSize = 10
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -68, 0, 13)
CloseBtn.BackgroundColor3 = C.Danger
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 28, 0, 28)
ExitBtn.Position = UDim2.new(1, -36, 0, 13)
ExitBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 160)
ExitBtn.Text = "⏻"
ExitBtn.TextColor3 = Color3.new(1, 1, 1)
ExitBtn.TextSize = 14
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.Parent = Header
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame")
if IsMobile then
    Sidebar.Size = UDim2.new(1, -16, 0, 42)
    Sidebar.Position = UDim2.new(0, 8, 0, 62)
else
    Sidebar.Size = UDim2.new(0, 150, 1, -75)
    Sidebar.Position = UDim2.new(0, 10, 0, 65)
end
Sidebar.BackgroundColor3 = C.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, -8, 1, -8)
TabScroll.Position = UDim2.new(0, 4, 0, 4)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 0
TabScroll.ScrollingDirection = IsMobile and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.FillDirection = IsMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
TabLayout.Parent = TabScroll

local Content = Instance.new("Frame")
if IsMobile then
    Content.Size = UDim2.new(1, -16, 1, -175)
    Content.Position = UDim2.new(0, 8, 0, 112)
else
    Content.Size = UDim2.new(1, -180, 1, -75)
    Content.Position = UDim2.new(0, 170, 0, 65)
end
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C.Accent
    page.Visible = false
    page.Parent = Content
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 6)
    l.Parent = page
    Pages[name] = page
    return page
end

local P_Strength = CreatePage("Strength")
local P_Defense = CreatePage("Defense")
local P_Move = CreatePage("Movement")
local P_Visual = CreatePage("Visuals")
local P_Misc = CreatePage("Misc")

local function ShowPage(name, tabBtn)
    for _, p in pairs(Pages) do p.Visible = false end
    if Pages[name] then Pages[name].Visible = true end
    for _, t in ipairs(TabScroll:GetChildren()) do
        if t:IsA("TextButton") then
            TweenService:Create(t, TweenInfo.new(0.2), {BackgroundColor3 = C.PanelLight}):Play()
            t.TextColor3 = C.TextDim
        end
    end
    if tabBtn then
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
        tabBtn.TextColor3 = C.Text
    end
end

local function CreateTab(name, page, icon)
    local tab = Instance.new("TextButton")
    if IsMobile then
        tab.Size = UDim2.new(0, 82, 1, 0)
    else
        tab.Size = UDim2.new(1, 0, 0, 32)
    end
    tab.BackgroundColor3 = C.PanelLight
    tab.Text = icon .. " " .. name
    tab.TextColor3 = C.TextDim
    tab.TextSize = IsMobile and 10 or 11
    tab.Font = Enum.Font.GothamBold
    tab.Parent = TabScroll
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 8)
    tab.MouseButton1Click:Connect(function() ShowPage(name, tab) end)
    return tab
end

local tabStrength = CreateTab("Strength", P_Strength, "💪")
CreateTab("Defense", P_Defense, "🔒")
CreateTab("Move", P_Move, "🏃")
CreateTab("Visual", P_Visual, "👁")
CreateTab("Misc", P_Misc, "⚙")
ShowPage("Strength", tabStrength)

task.defer(function()
    if IsMobile then
        TabScroll.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 10, 0, 0)
    else
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end
end)

local function CreateToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.48, -3, 0, 40)
    frame.BackgroundColor3 = C.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.Text
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 24)
    btn.Position = UDim2.new(1, -58, 0.5, -12)
    btn.BackgroundColor3 = default and C.Accent or C.PanelLight
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = C.Text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and C.Accent or C.PanelLight}):Play()
        if callback then callback(state) end
    end)
    return frame
end

local function CreateButton(parent, name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color or C.PanelLight
    btn.Text = name
    btn.TextColor3 = C.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = C.Panel
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = C.Text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 32)
    bar.BackgroundColor3 = C.PanelLight
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local v = math.floor(min + (max - min) * rel)
            label.Text = name .. ": " .. v
            if callback then callback(v) end
        end
    end)
end

-- STRENGTH
CreateToggle(P_Strength, "Super Strength", false, EnableSuperStrength)
CreateSlider(P_Strength, "Fling Strength", 100, 1000000000, 8500000, function(v) FlingStrength = v end)

-- DEFENSE
CreateToggle(P_Defense, "Anti Grab", false, EnableAntiGrab)
CreateToggle(P_Defense, "Gucci Anti", false, EnableGucciAnti)
CreateToggle(P_Defense, "Anti Blobman", false, EnableAntiBlobman)
CreateToggle(P_Defense, "Anti Fling", false, EnableAntiFling)
CreateToggle(P_Defense, "Anti Teleport", false, EnableAntiTeleport)
CreateToggle(P_Defense, "Anti Kick", false, EnableAntiKick)
CreateToggle(P_Defense, "Anti Lag", false, EnableAntiLag)
CreateToggle(P_Defense, "Auto Anti Lag", false, EnableAutoAntiLag)

-- MOVE
CreateToggle(P_Move, "Fly", false, EnableFly)
CreateToggle(P_Move, "Speed Hack", false, EnableSpeed)
CreateToggle(P_Move, "Jump Boost", false, EnableJump)
CreateToggle(P_Move, "Infinite Jump", false, EnableInfJump)
CreateToggle(P_Move, "NoClip", false, EnableNoClip)
CreateSlider(P_Move, "Speed Value", 16, 300, 50, function(v) SpeedValue = v end)
CreateSlider(P_Move, "Jump Value", 50, 500, 100, function(v) JumpValue = v end)

-- VISUAL
CreateToggle(P_Visual, "ESP", false, EnableESP)
CreateToggle(P_Visual, "Fullbright", false, EnableFullbright)

-- MISC
CreateToggle(P_Misc, "Immortality", false, EnableImmortality)
CreateButton(P_Misc, "🔄 Rejoin Server", Color3.fromRGB(40, 60, 50), function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
CreateButton(P_Misc, "🛑 Выгрузить", Color3.fromRGB(100, 30, 50), function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(FeatureConns) do pcall(function() c:Disconnect() end) end
    espFolder:ClearAllChildren()
    ScreenGui:Destroy()
end)

local function OpenMenu()
    Main.Visible = true
    if IsMobile then
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0, Viewport.X/2, 0, 60)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, WIDTH, 0, HEIGHT),
            Position = UDim2.new(0, (Viewport.X - WIDTH)/2, 0, 60)
        }):Play()
    else
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, WIDTH, 0, HEIGHT),
            Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
        }):Play()
    end
end

local function CloseMenu()
    TweenService:Create(Main, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.2)
    Main.Visible = false
end

OpenBtn.MouseButton1Click:Connect(function()
    if Main.Visible then CloseMenu() else OpenMenu() end
end)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

ExitBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(FeatureConns) do pcall(function() c:Disconnect() end) end
    espFolder:ClearAllChildren()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end)
    ScreenGui:Destroy()
end)

print("[Mekha Hub v3.5] Загружено! Stable edition.")
