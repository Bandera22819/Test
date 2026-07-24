-- Touch Fling (Fully Working GUI) для Roblox Executor
-- Работает в играх с включёнными коллизиями (collision)
-- Просто включи и коснись игрока — его откинет

-- Gui to Lua
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local TextButton = Instance.new("TextButton")

-- Properties
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.3885, 0, 0.4278, 0)
Frame.Size = UDim2.new(0, 158, 0, 110)

Frame_2.Parent = Frame
Frame_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame_2.BorderSizePixel = 0
Frame_2.Size = UDim2.new(0, 158, 0, 25)

TextLabel.Parent = Frame_2
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0.1128, 0, -0.0152, 0)
TextLabel.Size = UDim2.new(0, 121, 0, 26)
TextLabel.Font = Enum.Font.Sarpanch
TextLabel.Text = "Touch Fling"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 25

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.1139, 0, 0.4182, 0)
TextButton.Size = UDim2.new(0, 121, 0, 37)
TextButton.Font = Enum.Font.SourceSansItalic
TextButton.Text = "OFF"
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextSize = 20

-- Draggable
Frame.Active = true
Frame.Draggable = true

-- Main Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local toggleButton = TextButton
local hiddenfling = false
local flingThread

-- Anti-detection (fake decal)
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

local function fling()
    local lp = Players.LocalPlayer
    local c, hrp, vel, movel = nil, nil, nil, 0.1

    while hiddenfling do
        RunService.Heartbeat:Wait()

        c = lp.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")

        if hrp then
            vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

toggleButton.MouseButton1Click:Connect(function()
    hiddenfling = not hiddenfling
    toggleButton.Text = hiddenfling and "ON" or "OFF"

    if hiddenfling then
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    else
        hiddenfling = false
    end
end)

print("Touch Fling загружен! Включи и коснись игрока.")
