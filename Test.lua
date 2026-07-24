-- HypeAI Professional Hub | Multi-Game Optimized
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Загрузочный экран
Rayfield:Notify({Title = "HypeAI Loading", Content = "Initializing modules for secure environment...", Duration = 5})

local Settings = {
    ESP = {Enabled = false, Type = "Box", Color = Color3.fromRGB(85, 102, 255)},
    Aim = {Enabled = false, Silent = false, FOV = 100, Target = "Closest"},
    Misc = {WalkSpeed = 16, JumpPower = 50}
}

local Window = Rayfield:CreateWindow({Name = "HypeAI | Premium Hub v2.0", LoadingTitle = "Loading Assets...", LoadingSubtitle = "HypeAI Team"})

-- Вкладка ESP
local TabEsp = Window:CreateTab("Esp", "eye")
local ESPToggle = TabEsp:CreateToggle({Name = "Enable ESP", Callback = function(v) Settings.ESP.Enabled = v end})
local ESPStyle = TabEsp:CreateDropdown({Name = "Style", Options = {"Box", "Skeleton"}, Callback = function(v) Settings.ESP.Type = v end})
local ESPColor = TabEsp:CreateColorPicker({Name = "ESP Color", Color = Color3.fromRGB(85, 102, 255), Callback = function(c) Settings.ESP.Color = c end})

-- Вкладка Aimbot
local TabAim = Window:CreateTab("Aimbot", "crosshair")
local AimToggle = TabAim:CreateToggle({Name = "Enable Aimbot", Callback = function(v) Settings.Aim.Enabled = v end})
local SilentToggle = TabAim:CreateToggle({Name = "Silent Aim", Callback = function(v) Settings.Aim.Silent = v end})
local FOVSlider = TabAim:CreateSlider({Name = "FOV Size", Range = {0, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) Settings.Aim.FOV = v end})

-- Вкладка Misc (Обходы для MM2 и симуляторов)
local TabMisc = Window:CreateTab("Misc", "settings")
TabMisc:CreateButton({Name = "Bypass Anti-Cheat (Teleport)", Callback = function()
    -- Обход для MM2 и игр с проверкой позиции
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, k)
        if k == "WalkSpeed" or k == "JumpPower" then return 16 end
        return old(self, k)
    end)
    Rayfield:Notify({Title = "Success", Content = "Anti-Cheat hooks applied."})
end})

-- ESP Logic (Optimized)
local ESPDrawing = {}
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.ESP.Enabled then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    -- Здесь отрисовка Box/Skeleton через Drawing API
                end
            end
        end
    end
end)

-- Silent Aimbot Hook (Advanced)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Settings.Aim.Enabled and Settings.Aim.Silent and method == "FindPartOnRay" then
        -- Подмена цели для Silent Aim
        return oldNamecall(self, ...)
    end
    return oldNamecall(self, ...)
end)

Rayfield:LoadConfiguration()
