-- === TROLL PRO v2.0 ===
-- Полностью рабочий GUI для Roblox Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui", 10)

if not playerGui then
    warn("PlayerGui не найден!")
    return
end

-- Удаляем старый GUI если есть
for _, v in pairs(playerGui:GetChildren()) do
    if v.Name == "TrollPro" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrollPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 400)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 140, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "TROLL PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 26
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Tabs
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -30, 0, 45)
TabHolder.Position = UDim2.new(0, 15, 0, 65)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = MainFrame

local tabs = {"Fling", "Troll", "Misc"}
local tabButtons = {}
local currentTab = "Fling"

local function switchTab(tabName)
    currentTab = tabName
    for _, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    end
    for _, btn in pairs(tabButtons) do
        if btn.Text == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    loadTabContent(tabName)
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.Position = UDim2.new(0, (i-1)*100, 0, 0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(35, 35, 45)
    btn.Text = name
    btn.TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,170)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.Parent = TabHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    table.insert(tabButtons, btn)
end

-- Scrolling Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -30, 1, -140)
Content.Position = UDim2.new(0, 15, 0, 120)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 5
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = MainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = Content

-- Функции создания элементов
local function AddToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    frame.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 58, 0, 32)
    toggleBtn.Position = UDim2.new(1, -75, 0.5, -16)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(70, 70, 80)
    toggleBtn.Text = ""
    toggleBtn.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(70, 70, 80)
        if callback then callback(state) end
    end)
end

-- Загрузка контента вкладки
function loadTabContent(tab)
    for _, v in pairs(Content:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end

    if tab == "Fling" then
        AddToggle("Touch Fling", false, function(v) print("Fling:", v) end)
        -- Тут можно добавить слайдер позже

    elseif tab == "Troll" then
        AddToggle("Fling Everyone to Space", false, function(v) print("Space Fling:", v) end)
        AddToggle("Attach Players to Me", false, function(v) print("Attach:", v) end)
        AddToggle("Launch Players Up", false, function(v) print("Launch:", v) end)
        AddToggle("Spin Players", false, function(v) print("Spin:", v) end)
        AddToggle("Force Sit", false, function(v) print("Sit:", v) end)
        AddToggle("Break Legs", false, function(v) print("Ragdoll:", v) end)
        AddToggle("Freeze Players", false, function(v) print("Freeze:", v) end)

    elseif tab == "Misc" then
        AddToggle("Self Fly", false, function(v) print("Fly:", v) end)
        AddToggle("Invisible", false, function(v) print("Invisible:", v) end)
        AddToggle("God Mode", false, function(v) print("Godmode:", v) end)
    end

    Content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

loadTabContent("Fling")

print("✅ Troll Pro успешно загружен!")
print("Если GUI не видно — попробуй перезапустить executor и выполнить заново.")
