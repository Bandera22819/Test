-- ESP, Aimbot & Misc Hub
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Settings = {
    ESP = { Enabled = false, Box = true, Skeleton = false, Color = Color3.fromRGB(85, 102, 255) },
    Aimbot = { Enabled = false, Silent = false, FOV = 100, TargetMode = "Closest" }, -- "Closest" or "First"
    Misc = { Speed = 16, Jump = 50 }
}

-- Вспомогательная функция для ESP
local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    
    RunService.RenderStepped:Connect(function()
        if Settings.ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                box.Visible = Settings.ESP.Box
                box.Color = Settings.ESP.Color
                box.Size = Vector2.new(100, 200)
                box.Position = Vector2.new(rootPos.X - 50, rootPos.Y - 100)
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then CreateESP(p) end
end

-- Основной цикл Aimbot
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot.Enabled then return end
    
    local target = nil
    local shortest = Settings.Aimbot.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            
            if onScreen and dist < shortest then
                target = p.Character.Head
                shortest = dist
                if Settings.Aimbot.TargetMode == "First" then break end
            end
        end
    end
    
    if target and Settings.Aimbot.Silent then
        -- Реализация Silent Aimbot: перехват выстрела
        -- Для полноценного Silent требуется hookmetamethod __namecall
    elseif target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end)

-- Интерфейс (UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "HypeAI | Internal Hub"})

local TabEsp = Window:CreateTab("Esp", "eye")
local TabAim = Window:CreateTab("Aimbot", "crosshair")
local TabMisc = Window:CreateTab("Misc", "settings")

TabEsp:CreateToggle({Name = "Enable ESP", Callback = function(v) Settings.ESP.Enabled = v end})
TabEsp:CreateColorPicker({Name = "ESP Color", Color = Color3.fromRGB(85, 102, 255), Callback = function(c) Settings.ESP.Color = c end})
TabEsp:CreateDropdown({Name = "Style", Options = {"Box", "Skeleton"}, Callback = function(o) Settings.ESP.Box = (o == "Box") end})

TabAim:CreateToggle({Name = "Aimbot Enabled", Callback = function(v) Settings.Aimbot.Enabled = v end})
TabAim:CreateToggle({Name = "Silent Aimbot", Callback = function(v) Settings.Aimbot.Silent = v end})
TabAim:CreateSlider({Name = "FOV Size", Range = {0, 500}, Increment = 10, Callback = function(v) Settings.Aimbot.FOV = v end})

TabMisc:CreateButton({Name = "Speed Hack", Callback = function() LP.Character.Humanoid.WalkSpeed = 50 end})
TabMisc:CreateButton({Name = "Infinite Jump", Callback = function() 
    game:GetService("UserInputService").JumpRequest:Connect(function() game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState("Jumping") end)
end})
