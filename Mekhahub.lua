--[[
    MEKHA HUB - PREMIUM UI
    Красивый интерфейс в стиле Cosmic Hub
    Fling Things and People
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// Цветовая схема
local Colors = {
    Background = Color3.fromRGB(14, 12, 22),
    Panel = Color3.fromRGB(22, 18, 34),
    PanelLight = Color3.fromRGB(30, 25, 45),
    Accent = Color3.fromRGB(138, 80, 255),
    AccentLight = Color3.fromRGB(180, 130, 255),
    Text = Color3.fromRGB(235, 230, 250),
    TextDim = Color3.fromRGB(140, 135, 165),
    Success = Color3.fromRGB(80, 220, 140),
    Danger = Color3.fromRGB(255, 80, 100),
}

local SelectedPlayer = nil
local Flags = { AntiGrab = false, GucciAnti = false, AntiBlobman = false, AntiKick = false }

--// ============================================
--// ФУНКЦИИ
--// ============================================
local function EnableAntiGrab(on)
    Flags.AntiGrab = on
    if not on then return end
    RunService.Heartbeat:Connect(function()
        if not Flags.AntiGrab then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "GrabPoint" and obj:IsA("Attachment") then
                local p = obj.Parent
                if p and p:IsA("BasePart") and not p:IsDescendantOf(char) then
                    p.CanCollide = false
                    p.Massless = true
                end
            end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part.Name == "GrabPoint" then part:Destroy() end
        end
    end)
end

local function EnableGucciAnti(on)
    Flags.GucciAnti = on
    if not on then return end
    RunService.Heartbeat:Connect(function()
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
    end)
end

local function EnableAntiBlobman(on)
    Flags.AntiBlobman = on
    if not on then return end
    RunService.Heartbeat:Connect(function()
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
    end)
end

local function EnableAntiKick(on)
    Flags.AntiKick = on
    if not on then return end
    RunService.Heartbeat:Connect(function()
        if not Flags.AntiKick then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Magnitude > 200 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            local model = hum.SeatPart:FindFirstAncestorOfClass("Model")
            if model and model.Name:lower():find("blobman") then
                hum.Sit = false
            end
        end
    end)
end

local function BlobmanKick()
    if not SelectedPlayer then
        print("[Mekha] Выбери игрока!")
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tChar = SelectedPlayer.Character
    if not tChar then return end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end

    local blobman = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("blobman") and obj:IsA("Model") then
            blobman = obj
            break
        end
    end
    if not blobman then
        print("[Mekha] Blobman не найден!")
        return
    end

    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 6, 0)
    local seat = blobman:FindFirstChildWhichIsA("Seat", true)
    if seat then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then seat:Sit(hum) end
    end
    print("[Mekha] Blobman кик на " .. SelectedPlayer.Name)
end

--// ============================================
--// UI
--// ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MekhaPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

--// Кнопка открытия (плавающая)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 20, 0.35, 0)
OpenBtn.BackgroundColor3 = Colors.Accent
OpenBtn.Text = "☄"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local openStroke = Instance.new("UIStroke", OpenBtn)
openStroke.Color = Colors.AccentLight
openStroke.Thickness = 2

local openGradient = Instance.new("UIGradient", OpenBtn)
openGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 180)),
})
openGradient.Rotation = 45

--// Главное окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 480)
Main.Position = UDim2.new(0.5, -160, 0.5, -240)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Colors.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3

--// Градиент фона
local bgGradient = Instance.new("UIGradient", Main)
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 18, 34)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 12, 22)),
})
bgGradient.Rotation = 135

--// Верхняя панель (заголовок)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Colors.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Colors.Panel
headerFix.BorderSizePixel = 0
headerFix.Parent = Header

local headerGradient = Instance.new("UIGradient", Header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 25, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 18, 34)),
})
headerGradient.Rotation = 90

--// Логотип
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 12, 0, 10)
Logo.BackgroundColor3 = Colors.Accent
Logo.Text = "☄"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Header
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)

--// Название
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -120, 0, 22)
TitleLbl.Position = UDim2.new(0, 60, 0, 12)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "MEKHA HUB"
TitleLbl.TextColor3 = Colors.Text
TitleLbl.TextSize = 16
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Header

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, -120, 0, 16)
SubLbl.Position = UDim2.new(0, 60, 0, 32)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Fling Things and People"
SubLbl.TextColor3 = Colors.TextDim
SubLbl.TextSize = 11
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.Parent = Header

--// Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -42, 0, 15)
CloseBtn.BackgroundColor3 = Colors.PanelLight
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

--// Минимизировать
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -78, 0, 15)
MinBtn.BackgroundColor3 = Colors.PanelLight
MinBtn.Text = "—"
MinBtn.TextColor3 = Colors.Text
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

--// Контейнер контента
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -80)
Content.Position = UDim2.new(0, 10, 0, 70)
Content.BackgroundTransparency = 1
Content.Parent = Main

--// Список игроков (мобилка)
local PlayerList
if IsMobile then
    PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, 0, 0, 140)
    PlayerList.Position = UDim2.new(0, 0, 0, 0)
    PlayerList.BackgroundColor3 = Colors.Panel
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 4
    PlayerList.ScrollBarImageColor3 = Colors.Accent
    PlayerList.Parent = Content
    Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = PlayerList

    local pad = Instance.new("UIPadding", PlayerList)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
end

--// Обновить список
local function RefreshList()
    if not PlayerList then return end
    for _, c in ipairs(PlayerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 32)
            btn.BackgroundColor3 = Colors.PanelLight
            btn.Text = "  " .. plr.Name
            btn.TextColor3 = Colors.Text
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = PlayerList
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = plr
                for _, c in ipairs(PlayerList:GetChildren()) do
                    if c:IsA("TextButton") then
                        TweenService:Create(c, TweenInfo.new(0.2), {BackgroundColor3 = Colors.PanelLight}):Play()
                    end
                end
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
            end)
        end
    end
end

--// Позиция элементов управления
local startY = IsMobile and 150 or 0

--// Функция создания тумблера
local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.Position = UDim2.new(0, 0, 0, startY)
    frame.BackgroundColor3 = Colors.Panel
    frame.BorderSizePixel = 0
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Индикатор-точка
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -95, 0.5, -4)
    dot.BackgroundColor3 = default and Colors.Success or Colors.TextDim
    dot.BorderSizePixel = 0
    dot.Parent = frame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    -- Кнопка
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 26)
    btn.Position = UDim2.new(1, -80, 0.5, -13)
    btn.BackgroundColor3 = default and Colors.Accent or Colors.PanelLight
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Colors.Text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.Accent or Colors.PanelLight
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.Success or Colors.TextDim
        }):Play()
        if callback then callback(state) end
    end)

    startY = startY + 48
end

--// Тумблеры
CreateToggle("Anti Grab", false, EnableAntiGrab)
CreateToggle("Gucci Anti", false, EnableGucciAnti)
CreateToggle("Anti Blobman", false, EnableAntiBlobman)
CreateToggle("Anti Kick", false, EnableAntiKick)

--// Кнопка Blobman Kick
local KickBtn = Instance.new("TextButton")
KickBtn.Size = UDim2.new(1, 0, 0, 48)
KickBtn.Position = UDim2.new(0, 0, 0, startY + 8)
KickBtn.BackgroundColor3 = Colors.Accent
KickBtn.Text = "☄  BLOBMAN KICK"
KickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KickBtn.TextSize = 14
KickBtn.Font = Enum.Font.GothamBold
KickBtn.Parent = Content
Instance.new("UICorner", KickBtn).CornerRadius = UDim.new(0, 12)

local kickGradient = Instance.new("UIGradient", KickBtn)
kickGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 40, 200)),
})
kickGradient.Rotation = 45

KickBtn.MouseButton1Click:Connect(function()
    TweenService:Create(KickBtn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 46)}):Play()
    task.wait(0.1)
    TweenService:Create(KickBtn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 48)}):Play()
    BlobmanKick()
end)

--// Кнопка обновления (мобилка)
if IsMobile then
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Size = UDim2.new(1, 0, 0, 32)
    RefreshBtn.Position = UDim2.new(0, 0, 0, startY + 62)
    RefreshBtn.BackgroundColor3 = Colors.PanelLight
    RefreshBtn.Text = "🔄  Обновить список"
    RefreshBtn.TextColor3 = Colors.TextDim
    RefreshBtn.TextSize = 12
    RefreshBtn.Font = Enum.Font.Gotham
    RefreshBtn.Parent = Content
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 8)

    RefreshBtn.MouseButton1Click:Connect(RefreshList)
    RefreshList()
    Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) RefreshList() end)
end

--// Анимация открытия
local function OpenMenu()
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 480),
        Position = UDim2.new(0.5, -160, 0.5, -240)
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

--// Минимизация
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 320, 0, 60)
        }):Play()
        Content.Visible = false
    else
        TweenService:Create(Main, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 320, 0, 480)
        }):Play()
        task.wait(0.2)
        Content.Visible = true
    end
end)

--// Анимация кнопки открытия (пульсация)
task.spawn(function()
    while OpenBtn.Parent do
        TweenService:Create(openStroke, TweenInfo.new(1.5), {Transparency = 0.6}):Play()
        task.wait(1.5)
        TweenService:Create(openStroke, TweenInfo.new(1.5), {Transparency = 0}):Play()
        task.wait(1.5)
    end
end)

--// ПК: хоткей K
if not IsMobile then
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.K then
            local target = Mouse.Target
            if target then
                local model = target:FindFirstAncestorOfClass("Model")
                if model then
                    local plr = Players:GetPlayerFromCharacter(model)
                    if plr and plr ~= LocalPlayer then
                        SelectedPlayer = plr
                        BlobmanKick()
                    end
                end
            end
        end
    end)
end

print([[
╔════════════════════════════════════╗
║  ☄ MEKHA HUB - PREMIUM             ║
║  Платформа: ]] .. (IsMobile and "Телефон" or "ПК") .. [[
║  Нажми ☄ чтобы открыть меню        ║
╚════════════════════════════════════╝
]])
