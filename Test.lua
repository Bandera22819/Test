local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = {Enabled = false, Type = "Box", Color = Color3.fromRGB(85, 102, 255)},
    Aim = {Enabled = false, Silent = false, FOV = 100, Target = "Closest", QuickToggle = false},
}

-- Drawing objects (Optimization)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Radius = Settings.Aim.FOV

local Window = Rayfield:CreateWindow({Name = "HypeAI | Pro Edition"})

-- ESP Logic Fix
local TabEsp = Window:CreateTab("Esp", "eye")
local ESPToggle = TabEsp:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = function(v) Settings.ESP.Enabled = v end})
local ESPStyle = TabEsp:CreateDropdown({Name = "ESP Type", Options = {"Box", "Skeleton"}, CurrentOption = {"Box"}, Callback = function(v) Settings.ESP.Type = v[1] end})
local ESPColor = TabEsp:CreateColorPicker({Name = "ESP Color", Color = Color3.fromRGB(85, 102, 255), Callback = function(c) Settings.ESP.Color = c end})

-- Aimbot Logic Fix + Misc Quick Toggle
local TabAim = Window:CreateTab("Aimbot", "crosshair")
local AimToggle = TabAim:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) Settings.Aim.Enabled = v end})
local FOVSlider = TabAim:CreateSlider({Name = "FOV Radius", Range = {0, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) 
    Settings.Aim.FOV = v
    FOVCircle.Radius = v
end})
local QuickToggleBtn = TabAim:CreateButton({Name = "Misc: Quick Toggle Aimbot", Callback = function()
    Settings.Aim.QuickToggle = not Settings.Aim.QuickToggle
    Settings.Aim.Enabled = Settings.Aim.QuickToggle
    Rayfield:Notify({Title = "Aimbot", Content = "Fast Toggle: " .. tostring(Settings.Aim.QuickToggle)})
end})

-- Render Loop (ESP + FOV)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Settings.Aim.Enabled
    FOVCircle.Color = Settings.ESP.Color

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.ESP.Enabled then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    -- Логика отображения по типу
                    if Settings.ESP.Type == "Box" then
                        -- Рендер Box (упрощено для примера)
                    elseif Settings.ESP.Type == "Skeleton" then
                        -- Логика отрисовки линий костей
                    end
                end
            end
        end
    end
end)

-- Silent Aimbot Fix
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Settings.Aim.Enabled and method == "FindPartOnRay" then
        -- Автоматический выбор ближайшего к прицелу
        local closest = nil
        local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local pos = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local d = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if d < Settings.Aim.FOV and d < dist then
                    dist = d
                    closest = p.Character.Head
                end
            end
        end
        if closest then args[1] = Ray.new(Camera.CFrame.Position, (closest.Position - Camera.CFrame.Position).Unit * 500) end
    end
    return oldNamecall(self, unpack(args))
end)
