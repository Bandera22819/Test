-- Улучшенный Touch Fling 2.0 (2026)
-- Красивый современный GUI + новые функции

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- Создаём красивый GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFlingPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.05
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Уголки и обводка
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 120, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "TOUCH FLING PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.075, 0, 0.22, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleButton.Text = "ВКЛЮЧИТЬ FLING"
ToggleButton.TextColor3 = Color3.fromRGB(255, 80, 80)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

-- Слайдер мощности
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Size = UDim2.new(0.85, 0, 0, 20)
PowerLabel.Position = UDim2.new(0.075, 0, 0.42, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.Text = "Мощность: 10000"
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.TextSize = 14
PowerLabel.Font = Enum.Font.Gotham
PowerLabel.Parent = MainFrame

local PowerSlider = Instance.new("Frame")
PowerSlider.Size = UDim2.new(0.85, 0, 0, 8)
PowerSlider.Position = UDim2.new(0.075, 0, 0.48, 0)
PowerSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PowerSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = PowerSlider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
SliderFill.Parent = PowerSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- Дополнительные функции
local Features = {
    AntiSelfFling = true,
    Notifications = true,
}

local function createCheckbox(text, posY, default)
    local checkFrame = Instance.new("Frame")
    checkFrame.Size = UDim2.new(0.85, 0, 0, 30)
    checkFrame.Position = UDim2.new(0.075, 0, posY, 0)
    checkFrame.BackgroundTransparency = 1
    checkFrame.Parent = MainFrame

    local checkBox = Instance.new("TextButton")
    checkBox.Size = UDim2.new(0, 24, 0, 24)
    checkBox.BackgroundColor3 = default and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(50, 50, 60)
    checkBox.Text = ""
    checkBox.Parent = checkFrame

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = checkBox

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 35, 0, 0)
    label.Size = UDim2.new(1, -35, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.Parent = checkFrame

    local enabled = default
    checkBox.MouseButton1Click:Connect(function()
        enabled = not enabled
        checkBox.BackgroundColor3 = enabled and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(50, 50, 60)
    end)

    return function() return enabled end
end

local getAntiSelf = createCheckbox("Анти-самофлинг", 0.58, true)
local getNotifications = createCheckbox("Уведомления", 0.68, true)

-- Переменные
local hiddenfling = false
local power = 10000
local flingThread

-- Логика слайдера
local dragging = false
PowerSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mousePos = UserInputService:GetMouseLocation()
        local relative = (mousePos.X - PowerSlider.AbsolutePosition.X) / PowerSlider.AbsoluteSize.X
        relative = math.clamp(relative, 0, 1)
        SliderFill.Size = UDim2.new(relative, 0, 1, 0)
        power = math.floor(relative * 20000) + 2000
        PowerLabel.Text = "Мощность: " .. power
    end
end)

-- Основная функция флинга (улучшенная)
local function fling()
    while hiddenfling do
        RunService.Heartbeat:Wait()
        local char = lp.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local vel = hrp.Velocity
        local multiplier = power / 1000

        hrp.Velocity = vel * multiplier + Vector3.new(0, power/2, 0)

        RunService.RenderStepped:Wait()
        hrp.Velocity = vel

        RunService.Stepped:Wait()
        if getAntiSelf() then
            hrp.Velocity = Vector3.new(vel.X * 0.1, 5, vel.Z * 0.1)
        else
            hrp.Velocity = vel + Vector3.new(0, 2, 0)
        end
    end
end

-- Toggle
ToggleButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    
    if hiddenfling then
        ToggleButton.Text = "ВЫКЛЮЧИТЬ FLING"
        ToggleButton.TextColor3 = Color3.fromRGB(80, 255, 120)
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
        
        if getNotifications() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Touch Fling Pro",
                Text = "Флинг включён! Коснись игроков 🔥",
                Duration = 3
            })
        end
    else
        ToggleButton.Text = "ВКЛЮЧИТЬ FLING"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        hiddenfling = false
    end
end)

-- Закрытие / Минимизация (добавь кнопку если хочешь)
print("✅ Touch Fling PRO загружен!")
print("Управление: Перетаскивай окно, используй слайдер мощности")
