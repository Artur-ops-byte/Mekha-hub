--[[
    ╔══════════════════════════════════════════════╗
    ║      MEKHA HUB - ULTIMATE EDITION v3.2       ║
    ║      Fling Things and People                 ║
    ║      ПК + Телефон • Super Strength • Kick    ║
    ╚══════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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
    Warning = Color3.fromRGB(255, 180, 60),
}

local SelectedPlayer = nil
local Flags = {
    AntiGrab=false, GucciAnti=false, AntiBlobman=false, AntiKick=false,
    AntiFling=false, AntiTeleport=false, FlingAura=false, KickAura=false,
    AntiLag=false, AutoAntiLag=false,
    Fly=false, Speed=false, Jump=false, InfiniteJump=false, NoClip=false,
    ESP=false, Fullbright=false, XRay=false,
    Immortality=false, LagServer=false, BlobmanLoop=false,
    SuperStrength=false, SuperGrab=false,
}
local SpeedValue = 50
local JumpValue = 100
local LagIntensity = 3
local FlingStrength = 350
local connections = {}
local espFolder = Instance.new("Folder", game:GetService("CoreGui"))
espFolder.Name = "MekhaESP"

local function Track(conn)
    table.insert(connections, conn)
    return conn
end

--// SUPER STRENGTH
local superConn = nil
local function EnableSuperStrength(on)
    Flags.SuperStrength = on
    if superConn then superConn:Disconnect() superConn = nil end
    if not on then return end
    superConn = workspace.ChildAdded:Connect(function(model)
        if not Flags.SuperStrength then return end
        if model.Name ~= "GrabParts" then return end
        task.wait(0.1)
        local grabPart = model:FindFirstChild("GrabPart")
        if not grabPart then return end
        local weld = grabPart:FindFirstChild("WeldConstraint")
        if not weld then return end
        local partToImpulse = weld.Part1
        if not partToImpulse then return end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlingVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = partToImpulse
        local conn
        conn = model:GetPropertyChangedSignal("Parent"):Connect(function()
            if model.Parent == nil then
                if Flags.SuperStrength then
                    bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * FlingStrength
                    game:GetService("Debris"):AddItem(bv, 1)
                else
                    bv:Destroy()
                end
                if conn then conn:Disconnect() end
            end
        end)
    end)
end

--// SUPER GRAB
local superGrabConn = nil
local function EnableSuperGrab(on)
    Flags.SuperGrab = on
    if superGrabConn then superGrabConn:Disconnect() superGrabConn = nil end
    if not on then return end
    superGrabConn = RunService.Heartbeat:Connect(function()
        if not Flags.SuperGrab then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - char.HumanoidRootPart.Position).Magnitude < 5 then
                    hrp.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                    hrp.Massless = false
                end
            end
        end
    end)
end

--// ЗАЩИТА
local function EnableAntiGrab(on)
    Flags.AntiGrab = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.AntiGrab then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "GrabPoint" and obj:IsA("Attachment") then
                local p = obj.Parent
                if p and p:IsA("BasePart") and not p:IsDescendantOf(char) then
                    p.CanCollide = false p.Massless = true
                end
            end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part.Name == "GrabPoint" then part:Destroy() end
        end
    end))
end

local function EnableGucciAnti(on)
    Flags.GucciAnti = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
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
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.AntiBlobman then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            local model = hum.SeatPart:FindFirstAncestorOfClass("Model")
            if model and model.Name:lower():find("blobman") then
                hum.Sit = false hum.Jump = true
            end
        end
    end))
end

local function EnableAntiKick(on)
    Flags.AntiKick = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.AntiKick then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 200 then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end
    end))
end

local function EnableAntiFling(on)
    Flags.AntiFling = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.AntiFling then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 150 then
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end))
end

local lastPos = nil
local function EnableAntiTeleport(on)
    Flags.AntiTeleport = on
    if not on then return end
    task.spawn(function()
        while Flags.AntiTeleport do
            task.wait(0.1)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if lastPos then
                    local dist = (hrp.Position - lastPos).Magnitude
                    if dist > 50 and dist < 5000 then
                        hrp.CFrame = CFrame.new(lastPos)
                    end
                end
                lastPos = hrp.Position
            end
        end
    end)
end

--// ANTI LAG
local antiLagActive = false
local antiLagConns = {}

local function EnableAntiLag(on)
    antiLagActive = on
    if not on then
        for _, c in ipairs(antiLagConns) do pcall(function() c:Disconnect() end) end
        antiLagConns = {}
        return
    end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
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
    table.insert(antiLagConns, workspace.DescendantAdded:Connect(function(obj)
        if not antiLagActive then return end
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

local autoAntiLagActive = false
local autoAntiLagConn = nil
local lastAutoLagTime = 0
local AUTO_LAG_COOLDOWN = 300

local function EnableAutoAntiLag(on)
    autoAntiLagActive = on
    if autoAntiLagConn then autoAntiLagConn:Disconnect() autoAntiLagConn = nil end
    if not on then return end
    local frameCount = 0
    local lastCheck = tick()
    autoAntiLagConn = RunService.Heartbeat:Connect(function()
        if not autoAntiLagActive then return end
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
                    if autoAntiLagActive then EnableAntiLag(false) end
                end)
            end
        end
    end)
end

local function EnableImmortality(on)
    Flags.Immortality = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
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

local lagConn = nil
local function EnableLagServer(on)
    Flags.LagServer = on
    if lagConn then lagConn:Disconnect() lagConn = nil end
    if not on then return end
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then table.insert(remotes, obj) end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") then table.insert(remotes, obj) end
    end
    if #remotes == 0 then return end
    lagConn = RunService.Heartbeat:Connect(function()
        if not Flags.LagServer then return end
        for i = 1, LagIntensity do
            for _, r in ipairs(remotes) do
                pcall(function() r:FireServer() end)
            end
        end
    end)
end

local function EnableFlingAura(on)
    Flags.FlingAura = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.FlingAura then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and (tHrp.Position - hrp.Position).Magnitude < 15 then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(9e9, 9e9, 9e9)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = tHrp
                    game:GetService("Debris"):AddItem(bv, 0.15)
                end
            end
        end
    end))
end

local function EnableKickAura(on)
    Flags.KickAura = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.KickAura then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if tHrp and (tHrp.Position - hrp.Position).Magnitude < 15 then
                    tHrp.CFrame = CFrame.new(0, 5000, 0)
                    task.wait(0.05)
                    tHrp.CFrame = CFrame.new(0, -5000, 0)
                end
            end
        end
    end))
end

local flyBV, flyBG
local function EnableFly(on)
    Flags.Fly = on
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if on then
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 1000
        Track(RunService.RenderStepped:Connect(function()
            if not Flags.Fly or not flyBV or not flyBV.Parent then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
            flyBV.Velocity = move.Magnitude > 0 and move.Unit * SpeedValue or Vector3.new(0,0,0)
            flyBG.CFrame = cam.CFrame
        end))
    else
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
    end
end

local function EnableSpeed(on)
    Flags.Speed = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.Speed then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = SpeedValue end
    end))
end

local function EnableJump(on)
    Flags.Jump = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.Jump then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = JumpValue hum.UseJumpPower = true end
    end))
end

local function EnableInfJump(on)
    Flags.InfiniteJump = on
    if not on then return end
    Track(UserInputService.JumpRequest:Connect(function()
        if not Flags.InfiniteJump then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
end

local function EnableNoClip(on)
    Flags.NoClip = on
    if not on then return end
    Track(RunService.Stepped:Connect(function()
        if not Flags.NoClip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))
end

local function EnableESP(on)
    Flags.ESP = on
    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = Instance.new("Highlight", espFolder)
                hl.Adornee = plr.Character
                hl.FillColor = C.Danger
                hl.OutlineColor = Color3.new(1,1,1)
            end
        end
    else
        espFolder:ClearAllChildren()
    end
end

local function EnableFullbright(on)
    Flags.Fullbright = on
    if on then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 5
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 2
    end
end

local function EnableXRay(on)
    Flags.XRay = on
    if not on then return end
    Track(RunService.Heartbeat:Connect(function()
        if not Flags.XRay then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                if not obj:FindFirstChild("MekhaXRay") then
                    local x = Instance.new("SelectionBox")
                    x.Name = "MekhaXRay"
                    x.Adornee = obj
                    x.LineThickness = 0.02
                    x.Color3 = C.Accent
                    x.Parent = obj
                end
            end
        end
    end))
end

local blobLoopConn = nil
local function EnableBlobmanLoop(on)
    Flags.BlobmanLoop = on
    if blobLoopConn then blobLoopConn:Disconnect() blobLoopConn = nil end
    if not on then return end
    blobLoopConn = RunService.Heartbeat:Connect(function()
        if not Flags.BlobmanLoop or not SelectedPlayer then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tChar = SelectedPlayer.Character
        local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        local blobman
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("blobman") and obj:IsA("Model") then blobman = obj break end
        end
        if not blobman then return end
        hrp.CFrame = tHrp.CFrame * CFrame.new(0, 6, 0)
        local seat = blobman:FindFirstChildWhichIsA("Seat", true)
        if seat then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then seat:Sit(hum) end
        end
    end)
end

local function BlobmanKick()
    if not SelectedPlayer then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tChar = SelectedPlayer.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end
    local blobman
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("blobman") and obj:IsA("Model") then blobman = obj break end
    end
    if not blobman then return end
    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 6, 0)
    local seat = blobman:FindFirstChildWhichIsA("Seat", true)
    if seat then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then seat:Sit(hum) end
    end
end

local function NormalKick()
    if not SelectedPlayer then return end
    local tChar = SelectedPlayer.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end
    tHrp.CFrame = CFrame.new(0, 5000, 0)
    task.wait(0.3)
    tHrp.CFrame = CFrame.new(0, -5000, 0)
end

local function KickAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 5000, 0)
                task.wait(0.05)
                hrp.CFrame = CFrame.new(0, -5000, 0)
            end
        end
    end
end

--// UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MekhaUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Красивая кнопка
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 0.35, 0)
OpenBtn.BackgroundColor3 = C.BG
OpenBtn.Text = ""
OpenBtn.AutoButtonColor = false
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local outerGlow = Instance.new("Frame", OpenBtn)
outerGlow.Size = UDim2.new(1, 16, 1, 16)
outerGlow.Position = UDim2.new(0, -8, 0, -8)
outerGlow.BackgroundColor3 = C.Accent
outerGlow.BackgroundTransparency = 0.8
outerGlow.BorderSizePixel = 0
outerGlow.ZIndex = 0
Instance.new("UICorner", outerGlow).CornerRadius = UDim.new(1, 0)
local glowGradient = Instance.new("UIGradient", outerGlow)
glowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 20, 140)),
})
glowGradient.Rotation = 45

local btnBg = Instance.new("Frame", OpenBtn)
btnBg.Size = UDim2.new(1, 0, 1, 0)
btnBg.BackgroundColor3 = C.Accent
btnBg.BorderSizePixel = 0
btnBg.ZIndex = 1
Instance.new("UICorner", btnBg).CornerRadius = UDim.new(1, 0)
local bgGrad = Instance.new("UIGradient", btnBg)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 100, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 60, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 30, 180)),
})
bgGrad.Rotation = 135

local btnStroke = Instance.new("UIStroke", btnBg)
btnStroke.Color = Color3.fromRGB(200, 160, 255)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.2

local orbit = Instance.new("Frame", OpenBtn)
orbit.Size = UDim2.new(1, 6, 1, 6)
orbit.Position = UDim2.new(0, -3, 0, -3)
orbit.BackgroundTransparency = 1
orbit.ZIndex = 2
Instance.new("UICorner", orbit).CornerRadius = UDim.new(1, 0)
local orbitStroke = Instance.new("UIStroke", orbit)
orbitStroke.Color = Color3.fromRGB(220, 180, 255)
orbitStroke.Thickness = 1
orbitStroke.Transparency = 0.4
local orbitGrad = Instance.new("UIGradient", orbitStroke)
orbitGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, C.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 30, 180)),
})
orbitGrad.Rotation = 0

local Icon = Instance.new("TextLabel", OpenBtn)
Icon.Size = UDim2.new(1, 0, 1, 0)
Icon.BackgroundTransparency = 1
Icon.Text = "☄"
Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
Icon.TextSize = 28
Icon.Font = Enum.Font.GothamBold
Icon.ZIndex = 3
local iconStroke = Instance.new("UIStroke", Icon)
iconStroke.Color = Color3.fromRGB(255, 255, 255)
iconStroke.Thickness = 0.5
iconStroke.Transparency = 0.5

local shine = Instance.new("Frame", OpenBtn)
shine.Size = UDim2.new(0.5, 0, 0.25, 0)
shine.Position = UDim2.new(0.15, 0, 0.1, 0)
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.7
shine.BorderSizePixel = 0
shine.ZIndex = 4
Instance.new("UICorner", shine).CornerRadius = UDim.new(1, 0)

local isHovered = false
OpenBtn.MouseEnter:Connect(function()
    isHovered = true
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 66, 0, 66)}):Play()
    TweenService:Create(outerGlow, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(iconStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
end)
OpenBtn.MouseLeave:Connect(function()
    isHovered = false
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    TweenService:Create(outerGlow, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    TweenService:Create(iconStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
end)
OpenBtn.MouseButton1Down:Connect(function()
    TweenService:Create(OpenBtn, TweenInfo.new(0.08), {Size = UDim2.new(0, 54, 0, 54)}):Play()
    TweenService:Create(btnBg, TweenInfo.new(0.08), {BackgroundTransparency = 0.2}):Play()
end)
OpenBtn.MouseButton1Up:Connect(function()
    TweenService:Create(OpenBtn, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
        Size = isHovered and UDim2.new(0, 66, 0, 66) or UDim2.new(0, 60, 0, 60)
    }):Play()
    TweenService:Create(btnBg, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)

task.spawn(function()
    while OpenBtn.Parent do
        TweenService:Create(outerGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(orbitStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.1}):Play()
        task.wait(1.5)
        TweenService:Create(outerGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(orbitStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.5}):Play()
        task.wait(1.5)
    end
end)

task.spawn(function()
    while OpenBtn.Parent do
        for i = 0, 360, 3 do
            if not OpenBtn.Parent then break end
            orbitGrad.Rotation = i
            task.wait(0.03)
        end
    end
end)

task.spawn(function()
    while OpenBtn.Parent do
        TweenService:Create(Icon, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Rotation = 8}):Play()
        task.wait(1.2)
        TweenService:Create(Icon, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Rotation = -8}):Play()
        task.wait(1.2)
    end
end)

local WIDTH = IsMobile and 360 or 680
local HEIGHT = IsMobile and 500 or 450

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
Main.Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
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
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = C.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local hf = Instance.new("Frame")
hf.Size = UDim2.new(1, 0, 0, 20)
hf.Position = UDim2.new(0, 0, 1, -20)
hf.BackgroundColor3 = C.Panel hf.BorderSizePixel = 0
hf.Parent = Header
local hg = Instance.new("UIGradient", Header)
hg.Color = ColorSequence.new(Color3.fromRGB(40,28,70), C.Panel)
hg.Rotation = 90

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 12, 0, 10)
Logo.BackgroundColor3 = C.Accent
Logo.Text = "☄"
Logo.TextColor3 = Color3.new(1,1,1)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Header
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -200, 0, 22)
TitleLbl.Position = UDim2.new(0, 60, 0, 12)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "MEKHA HUB"
TitleLbl.TextColor3 = C.Text
TitleLbl.TextSize = 16
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Header

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, -200, 0, 16)
SubLbl.Position = UDim2.new(0, 60, 0, 32)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Fling Things and People • Ultimate v3.2"
SubLbl.TextColor3 = C.TextDim
SubLbl.TextSize = 11
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -114, 0, 15)
MinBtn.BackgroundColor3 = C.PanelLight
MinBtn.Text = "—"
MinBtn.TextColor3 = C.Text
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -78, 0, 15)
CloseBtn.BackgroundColor3 = C.Danger
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 30, 0, 30)
ExitBtn.Position = UDim2.new(1, -42, 0, 15)
ExitBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 160)
ExitBtn.Text = "⏻"
ExitBtn.TextColor3 = Color3.new(1,1,1)
ExitBtn.TextSize = 16
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.Parent = Header
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame")
if IsMobile then
    Sidebar.Size = UDim2.new(1, -20, 0, 40)
    Sidebar.Position = UDim2.new(0, 10, 0, 70)
else
    Sidebar.Size = UDim2.new(0, 150, 1, -80)
    Sidebar.Position = UDim2.new(0, 10, 0, 70)
end
Sidebar.BackgroundColor3 = C.Panel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local TabContainer = Instance.new("Frame")
if IsMobile then
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
else
    TabContainer.Size = UDim2.new(1, -20, 1, -20)
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
end
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 6)
TabLayout.FillDirection = IsMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
TabLayout.Parent = TabContainer

local Content = Instance.new("Frame")
if IsMobile then
    Content.Size = UDim2.new(1, -20, 1, -200)
    Content.Position = UDim2.new(0, 10, 0, 120)
else
    Content.Size = UDim2.new(1, -180, 1, -80)
    Content.Position = UDim2.new(0, 170, 0, 70)
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
    l.Padding = UDim.new(0, 8)
    l.Parent = page
    Pages[name] = page
    return page
end

local P_Strength = CreatePage("Strength")
local P_Kick = CreatePage("Kick")
local P_Blob = CreatePage("Blobman")
local P_Visual = CreatePage("Visuals")
local P_Immortal = CreatePage("Immortal")
local P_Lag = CreatePage("Lag Server")
local P_Defense = CreatePage("Defense")
local P_Combat = CreatePage("Combat")
local P_Move = CreatePage("Movement")
local P_Misc = CreatePage("Misc")

local function ShowPage(name, tabBtn)
    for _, p in pairs(Pages) do p.Visible = false end
    if Pages[name] then Pages[name].Visible = true end
    for _, t in ipairs(TabContainer:GetChildren()) do
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
    tab.Size = IsMobile and UDim2.new(0, 72, 1, 0) or UDim2.new(1, 0, 0, 34)
    tab.BackgroundColor3 = C.PanelLight
    tab.Text = icon .. " " .. name
    tab.TextColor3 = C.TextDim
    tab.TextSize = IsMobile and 10 or 11
    tab.Font = Enum.Font.GothamBold
    tab.Parent = TabContainer
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 8)
    tab.MouseButton1Click:Connect(function() ShowPage(name, tab) end)
    return tab
end

local tabStrength = CreateTab("Strength", P_Strength, "💪")
CreateTab("Kick", P_Kick, "🔨")
CreateTab("Blobman", P_Blob, "🟣")
CreateTab("Visuals", P_Visual, "👁")
CreateTab("Immortal", P_Immortal, "🛡")
CreateTab("Lag", P_Lag, "📡")
CreateTab("Defense", P_Defense, "🔒")
CreateTab("Combat", P_Combat, "⚔")
CreateTab("Move", P_Move, "🏃")
CreateTab("Misc", P_Misc, "⚙")
ShowPage("Strength", tabStrength)

local function CreateToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.48, -4, 0, 42)
    frame.BackgroundColor3 = C.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.Text
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -78, 0.5, -4)
    dot.BackgroundColor3 = default and C.Success or C.TextDim
    dot.BorderSizePixel = 0
    dot.Parent = frame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 26)
    btn.Position = UDim2.new(1, -68, 0.5, -13)
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
        TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = state and C.Success or C.TextDim}):Play()
        if callback then callback(state) end
    end)
    return frame
end

local function CreateButton(parent, name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color or C.PanelLight
    btn.Text = name
    btn.TextColor3 = C.Text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = C.Panel
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = C.Text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 8)
    bar.Position = UDim2.new(0, 12, 0, 36)
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

local function CreatePlayerList(parent)
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 0, 120)
    list.BackgroundColor3 = C.Panel
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = C.Accent
    list.Parent = parent
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
    local layout = Instance.new("UIListLayout", list)
    layout.Padding = UDim.new(0, 4)
    local function refresh()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 30)
                btn.BackgroundColor3 = C.PanelLight
                btn.Text = "  " .. plr.Name
                btn.TextColor3 = C.Text
                btn.TextSize = 11
                btn.Font = Enum.Font.Gotham
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = list
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                btn.MouseButton1Click:Connect(function()
                    SelectedPlayer = plr
                    for _, c in ipairs(list:GetChildren()) do
                        if c:IsA("TextButton") then c.BackgroundColor3 = C.PanelLight end
                    end
                    btn.BackgroundColor3 = C.Accent
                end)
            end
        end
    end
    refresh()
    Track(Players.PlayerAdded:Connect(function() task.wait(0.5) refresh() end))
    Track(Players.PlayerRemoving:Connect(function() task.wait(0.5) refresh() end))
    return list
end

-- STRENGTH
CreateToggle(P_Strength, "Super Strength", false, EnableSuperStrength)
CreateSlider(P_Strength, "Fling Strength", 100, 1000000, 350, function(v) FlingStrength = v end)
CreateToggle(P_Strength, "Super Grab", false, EnableSuperGrab)

-- KICK
local kHint = Instance.new("TextLabel")
kHint.Size = UDim2.new(1, 0, 0, 20)
kHint.BackgroundTransparency = 1
kHint.Text = "Выбери игрока:"
kHint.TextColor3 = C.TextDim
kHint.TextSize = 11
kHint.Font = Enum.Font.Gotham
kHint.TextXAlignment = Enum.TextXAlignment.Left
kHint.Parent = P_Kick

CreatePlayerList(P_Kick)
CreateButton(P_Kick, "🔨 Обычный Кик", Color3.fromRGB(70,40,50), NormalKick)
CreateButton(P_Kick, "☄ Кик Всех", Color3.fromRGB(90,40,80), KickAll)

CreateToggle(P_Blob, "Blobman Loop", false, EnableBlobmanLoop)
CreateButton(P_Blob, "🟣 Blobman Kick (разово)", Color3.fromRGB(60,40,80), BlobmanKick)

CreateToggle(P_Visual, "ESP (Highlight)", false, EnableESP)
CreateToggle(P_Visual, "Fullbright", false, EnableFullbright)
CreateToggle(P_Visual, "X-Ray (SelectionBox)", false, EnableXRay)

CreateToggle(P_Immortal, "Immortality", false, EnableImmortality)
CreateButton(P_Immortal, "❤ Восстановить HP", Color3.fromRGB(60,30,40), function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = hum.MaxHealth end
end)

CreateToggle(P_Lag, "Lag Server", false, EnableLagServer)
CreateSlider(P_Lag, "Интенсивность лага", 1, 20, 3, function(v) LagIntensity = v end)

CreateToggle(P_Defense, "Anti Grab", false, EnableAntiGrab)
CreateToggle(P_Defense, "Gucci Anti Grab", false, EnableGucciAnti)
CreateToggle(P_Defense, "Anti Blobman", false, EnableAntiBlobman)
CreateToggle(P_Defense, "Anti Kick", false, EnableAntiKick)
CreateToggle(P_Defense, "Anti Fling", false, EnableAntiFling)
CreateToggle(P_Defense, "Anti Teleport", false, EnableAntiTeleport)
CreateToggle(P_Defense, "Anti Lag", false, EnableAntiLag)
CreateToggle(P_Defense, "Auto Anti Lag", false, EnableAutoAntiLag)

CreateToggle(P_Combat, "Fling Aura", false, EnableFlingAura)
CreateToggle(P_Combat, "Kick Aura", false, EnableKickAura)

CreateToggle(P_Move, "Fly (WASD + Space)", false, EnableFly)
CreateToggle(P_Move, "Speed Hack", false, EnableSpeed)
CreateToggle(P_Move, "Jump Boost", false, EnableJump)
CreateToggle(P_Move, "Infinite Jump", false, EnableInfJump)
CreateToggle(P_Move, "NoClip", false, EnableNoClip)
CreateSlider(P_Move, "Speed Value", 16, 300, 50, function(v) SpeedValue = v end)
CreateSlider(P_Move, "Jump Value", 50, 500, 100, function(v) JumpValue = v end)

CreateButton(P_Misc, "🔄 Rejoin Server", Color3.fromRGB(40,60,50), function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
CreateButton(P_Misc, "🔫 Reset Character", Color3.fromRGB(70,40,40), function()
    LocalPlayer.Character:BreakJoints()
end)
CreateButton(P_Misc, "🛑 Выгрузить весь скрипт", Color3.fromRGB(100,30,50), function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    espFolder:ClearAllChildren()
    ScreenGui:Destroy()
end)

local function OpenMenu()
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, WIDTH, 0, HEIGHT),
        Position = UDim2.new(0.5, -WIDTH/2, 0.5, -HEIGHT/2)
    }):Play()
end

local function CloseMenu()
    TweenService:Create(Main, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
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
    espFolder:ClearAllChildren()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MekhaXRay" then obj:Destroy() end
    end
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, WIDTH, 0, 60)}):Play()
        Sidebar.Visible = false
        Content.Visible = false
    else
        TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0, WIDTH, 0, HEIGHT)}):Play()
        task.wait(0.2)
        Sidebar.Visible = true
        Content.Visible = true
    end
end)

print("[Mekha Hub v3.2] Загружено!")
