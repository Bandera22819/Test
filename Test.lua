-- Touch Fling PRO + Troll Tab
-- Красивый тёмный GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 130, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "TROLL PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 55)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"Fling", "Troll", "Misc"}
local TabButtons = {}
local CurrentTab = "Fling"

local function createTab(name, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 35)
    btn.Position = UDim2.new(0, x, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = TabFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateContent()
    end)

    table.insert(TabButtons, btn)
    return btn
end

createTab("Fling", 10)
createTab("Troll", 110)
createTab("Misc", 210)

-- Content Frame
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -120)
Content.Position = UDim2.new(0, 10, 0, 105)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 6
Content.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Content

-- Переменные
local flingEnabled = false
local power = 12000

-- Функции
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Parent = Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 28)
    toggle.Position = UDim2.new(1, -65, 0.5, -14)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(60, 60, 65)
    toggle.Text = ""
    toggle.Parent = frame

    local tcorner = Instance.new("UICorner")
    tcorner.CornerRadius = UDim.new(1, 0)
    tcorner.Parent = toggle

    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(60, 60, 65)
        callback(enabled)
    end)
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Parent = Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 8)
    slider.Position = UDim2.new(0.05, 0, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    slider.Parent = frame

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1,0)
    sc.Parent = slider

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    fill.Parent = slider
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = fill
end

-- Troll функции
local function FlingToSpace(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(0, 500, 0)
    end
end

local function AttachToMe(target)
    if target and target.Character and lp.Character then
        local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")
        local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and tHrp then
            tHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -3)
        end
    end
end

-- Основной контент обновляется в зависимости от вкладки
local function updateContent()
    for _, child in pairs(Content:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    if CurrentTab == "Fling" then
        createToggle("Touch Fling", false, function(v) flingEnabled = v end)
        createSlider("Power", 2000, 25000, 12000, function(v) power = v end)

    elseif CurrentTab == "Troll" then
        createToggle("Fling to Space (Target)", false, function(v)
            if v then
                spawn(function()
                    while v do
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr \~= lp then FlingToSpace(plr) end
                        end
                        wait(0.8)
                    end
                end)
            end
        end)

        createToggle("Attach to Me", false, function(v)
            if v then
                spawn(function()
                    while v do
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr \~= lp then AttachToMe(plr) end
                        end
                        wait(0.3)
                    end
                end)
            end
        end)

        createToggle("Spin Players", false, function(v)
            -- Spin logic
        end)

        createToggle("Break Legs (Ragdoll)", false, function() end)
        createToggle("Force Sit", false, function() end)
        createToggle("Launch Up", false, function(v)
            if v then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr \~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 300, 0)
                    end
                end
            end
        end)
        createToggle("Freeze Position", false, function() end)
        createToggle("Invisible Troll", false, function() end)

    elseif CurrentTab == "Misc" then
        createToggle("Self Fly", false, function() end)
        createToggle("Godmode", false, function() end)
        createToggle("Chat Spam", false, function() end)
    end
end

updateContent()

print("Troll Pro GUI загружен!")
print("Переключайся между вкладками Fling / Troll / Misc")
