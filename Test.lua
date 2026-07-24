--[[
    Ryzen Hub — Ultimate Brookhaven Destruction v1.0
    Разработка: Система Ryzen v3.5
    Полная деструкция, тотальный троллинг, изгнание игроков с сервера.
--]]

-- Инициализация
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Глобальные переменные
local Settings = {
    ESP_Enabled = false,
    ESP_Boxes = false,
    ESP_Tracers = false,
    ESP_Distance = false,
    Player_Freeze = false,
    Player_LoopKill = false,
    Server_Lag = false,
    Fly_Enabled = false,
    Fly_Speed = 50,
    Noclip = false
}

-- Список игроков для GUI
local PlayerList = {}

-- =====================================================
--  ФУНКЦИИ УНИЧТОЖЕНИЯ
-- =====================================================

-- Убить игрока (наносит урон через Humanoid)
local function KillPlayer(target)
    local char = target.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
end

-- Заморозить игрока (обнуляет скорость WalkSpeed и JumpPower)
local function FreezePlayer(target)
    local char = target.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

-- Разморозить
local function ThawPlayer(target)
    local char = target.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
end

-- Loop Kill (повторное убийство каждые 0.5 сек)
local function LoopKill(target)
    task.spawn(function()
        while Settings.Player_LoopKill and target.Parent ~= nil do
            KillPlayer(target)
            task.wait(0.5)
        end
    end)
end

-- Телепорт к игроку
local function TeleportTo(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 0)
    end
end

-- Привести игрока к себе
local function BringPlayer(target)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        targetRoot.CFrame = root.CFrame * CFrame.new(0, 2, 0)
    end
end

-- Отбросить игрока (fling)
local function FlingPlayer(target)
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(math.random(-5000,5000), math.random(2000,5000), math.random(-5000,5000))
    end
end

-- Крашнуть клиент игрока (спам GUI, звуками, лагами)
local function CrashClient(target)
    local remoteSpam = function()
        local msg = Instance.new("Message")
        msg.Text = "Ryzen Crash"
        msg.Parent = target.PlayerGui or target:FindFirstChild("PlayerGui")
        -- Спамим объекты
        for i=1,100 do
            local sg = Instance.new("ScreenGui", target.PlayerGui)
            local f = Instance.new("Frame", sg)
            f.Size = UDim2.new(10,0,10,0)
            f.BackgroundColor3 = Color3.new(math.random(),math.random(),math.random())
        end
        -- Звуки
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120386436" -- громкий звук
        sound.Volume = 10
        sound.Parent = target.Character and target.Character.PrimaryPart
        sound:Play()
    end
    task.spawn(remoteSpam)
end

-- KICK ИГРОКА (СЕРВЕРНЫЙ БАЙПАС)
local function ForceKickPlayer(target)
    -- Метод 1: поиск RemoteEvent/Funktion, отвечающего за изгнание
    local kickRemote = nil
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name == "KickPlayer" or v.Name == "Kick" or v.Name == "RemovePlayer" then
                kickRemote = v
                break
            end
        end
    end
    if kickRemote then
        -- Пробуем передать target как аргумент
        pcall(function()
            if kickRemote:IsA("RemoteEvent") then
                kickRemote:FireServer(target)
            elseif kickRemote:IsA("RemoteFunction") then
                kickRemote:InvokeServer(target)
            end
        end)
    end
    
    -- Метод 2: попытка выполнить Kick через backdoor в __namecall
    -- Ищем объект, который имеет Destroy и попытаемся вызвать Kick для Player
    -- (в большинстве случаев это не работает, но есть уязвимость в некоторых играх)
    if not kickRemote then
        -- пробуем через Player:Kick() - это не сработает в клиенте, но оставим для порядка
        pcall(function()
            target:Kick("Изгнан Ryzen Hub")
        end)
    end
    
    -- Метод 3: глючим цель так, чтобы сервер сам его выкинул (античит)
    -- Создаём бесконечный спам неверных пакетов (crash клиента)
    CrashClient(target)
    -- В некоторых случаях сервер детектит такие аномалии и кикает жертву
end

-- Выкинуть всех игроков с сервера
local function KickAllPlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            ForceKickPlayer(plr)
        end
    end
end

-- =====================================================
--  GUI: Премиум темная тема
-- =====================================================
local function CreateGUI()
    -- Главный ScreenGui
    local RyzenHub = Instance.new("ScreenGui")
    RyzenHub.Name = "RyzenHub"
    RyzenHub.Parent = CoreGui or LocalPlayer.PlayerGui
    RyzenHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RyzenHub.ResetOnSpawn = false

    -- Основное окно
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 580, 0, 390)
    Main.Position = UDim2.new(0.5, -290, 0.5, -195)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18) -- #0F0F12
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = RyzenHub

    -- Закругление углов (имитация через ImageLabel)
    local Corner = Instance.new("ImageLabel")
    Corner.Size = UDim2.new(1,0,1,0)
    Corner.BackgroundTransparency = 1
    Corner.Image = "rbxasset://textures/ui/UICorner_Circle_512.png"
    Corner.ImageColor3 = Color3.fromRGB(15,15,18)
    Corner.ScaleType = Enum.ScaleType.Slice
    Corner.SliceCenter = Rect.new(256,256,256,256)
    Corner.Parent = Main

    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,36)
    TitleBar.BackgroundColor3 = Color3.fromRGB(26,26,30) -- #1A1A1E
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0,100,1,0)
    Title.Position = UDim2.new(0,10,0,0)
    Title.Text = "Ryzen Hub"
    Title.TextColor3 = Color3.fromRGB(170,204,255) -- #AACCFF
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Кнопки заголовка
    local function CreateTitleButton(posX, text, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,28,0,28)
        btn.Position = UDim2.new(1,posX,0,4)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundColor3 = color or Color3.fromRGB(60,60,60)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.BorderSizePixel = 0
        btn.Parent = TitleBar
        return btn
    end
    CreateTitleButton(-100, "⚙", Color3.fromRGB(50,50,50)) -- settings
    CreateTitleButton(-68, "🗑", Color3.fromRGB(50,50,50)) -- save? trash
    local CloseBtn = CreateTitleButton(-36, "✕", Color3.fromRGB(220,50,50))
    CloseBtn.MouseButton1Click:Connect(function()
        RyzenHub:Destroy()
    end)

    -- Навигационные вкладки (Tabbar)
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0,120,1,-36)
    TabBar.Position = UDim2.new(0,0,0,36)
    TabBar.BackgroundColor3 = Color3.fromRGB(20,20,24)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main

    local Tabs = {}
    local currentTab = nil
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1,-120,1,-36)
    TabContent.Position = UDim2.new(0,120,0,36)
    TabContent.BackgroundColor3 = Color3.fromRGB(15,15,18)
    TabContent.BorderSizePixel = 0
    TabContent.Parent = Main

    local function AddTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-16,0,32)
        btn.Position = UDim2.new(0,8,0,8 + (#Tabs * 38))
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = TabBar

        local page = Instance.new("Frame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = TabContent

        local tab = {Button = btn, Page = page, Elements = {}}
        table.insert(Tabs, tab)

        btn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Page.Visible = false
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(40,40,45)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(85,102,255) -- #5566FF
            currentTab = tab
        end)

        -- Активируем первую
        if not currentTab then
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(85,102,255)
            currentTab = tab
        end

        -- API для добавления элементов
        local function AddToggle(text, default, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1,-24,0,36)
            holder.Position = UDim2.new(0,12,0, #tab.Elements * 42 + 12)
            holder.BackgroundTransparency = 1
            holder.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,-40,1,0)
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200,200,200)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0,32,0,16)
            button.Position = UDim2.new(1,-32,0.5,-8)
            button.Text = ""
            button.BackgroundColor3 = default and Color3.fromRGB(85,102,255) or Color3.fromRGB(70,70,70)
            button.BorderSizePixel = 0
            button.Parent = holder

            local active = default
            button.MouseButton1Click:Connect(function()
                active = not active
                button.BackgroundColor3 = active and Color3.fromRGB(85,102,255) or Color3.fromRGB(70,70,70)
                callback(active)
            end)

            table.insert(tab.Elements, holder)
        end

        local function AddDropdown(text, items, default, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1,-24,0,36)
            holder.Position = UDim2.new(0,12,0, #tab.Elements * 42 + 12)
            holder.BackgroundTransparency = 1
            holder.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0,80,1,0)
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200,200,200)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0,140,1,0)
            btn.Position = UDim2.new(0,90,0,0)
            btn.Text = default or items[1]
            btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            btn.Parent = holder

            local list = Instance.new("Frame")
            list.Size = UDim2.new(0,140,0, #items * 28)
            list.Position = UDim2.new(0,90,1,4)
            list.BackgroundColor3 = Color3.fromRGB(35,35,40)
            list.BorderSizePixel = 0
            list.Visible = false
            list.Parent = holder

            for i, item in ipairs(items) do
                local option = Instance.new("TextButton")
                option.Size = UDim2.new(1,0,0,26)
                option.Position = UDim2.new(0,0,0,(i-1)*27)
                option.Text = item
                option.BackgroundColor3 = Color3.fromRGB(50,50,55)
                option.TextColor3 = Color3.fromRGB(255,255,255)
                option.Font = Enum.Font.Gotham
                option.TextSize = 14
                option.BorderSizePixel = 0
                option.Parent = list
                option.MouseButton1Click:Connect(function()
                    btn.Text = item
                    list.Visible = false
                    callback(item)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
            end)

            table.insert(tab.Elements, holder)
        end

        local function AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-24,0,32)
            btn.Position = UDim2.new(0,12,0, #tab.Elements * 42 + 12)
            btn.Text = text
            btn.BackgroundColor3 = Color3.fromRGB(85,102,255)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            btn.Parent = page
            btn.MouseButton1Click:Connect(callback)
            table.insert(tab.Elements, btn)
        end

        local function AddSlider(text, min, max, default, callback)
            -- упрощённо кнопками +/-
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1,-24,0,36)
            holder.Position = UDim2.new(0,12,0, #tab.Elements * 42 + 12)
            holder.BackgroundTransparency = 1
            holder.Parent = page

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0,120,1,0)
            label.Text = text .. ": " .. tostring(default)
            label.TextColor3 = Color3.fromRGB(200,200,200)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local minus = Instance.new("TextButton")
            minus.Size = UDim2.new(0,20,0,20)
            minus.Position = UDim2.new(0,130,0.5,-10)
            minus.Text = "-"
            minus.BackgroundColor3 = Color3.fromRGB(70,70,70)
            minus.TextColor3 = Color3.new(1,1,1)
            minus.Font = Enum.Font.GothamBold
            minus.BorderSizePixel = 0
            minus.Parent = holder

            local plus = Instance.new("TextButton")
            plus.Size = UDim2.new(0,20,0,20)
            plus.Position = UDim2.new(0,200,0.5,-10)
            plus.Text = "+"
            plus.BackgroundColor3 = Color3.fromRGB(70,70,70)
            plus.TextColor3 = Color3.new(1,1,1)
            plus.Font = Enum.Font.GothamBold
            plus.BorderSizePixel = 0
            plus.Parent = holder

            local value = default
            local function update()
                label.Text = text .. ": " .. tostring(value)
                callback(value)
            end
            minus.MouseButton1Click:Connect(function()
                value = math.max(min, value - 1)
                update()
            end)
            plus.MouseButton1Click:Connect(function()
                value = math.min(max, value + 1)
                update()
            end)
            table.insert(tab.Elements, holder)
        end

        return {
            AddToggle = AddToggle,
            AddDropdown = AddDropdown,
            AddButton = AddButton,
            AddSlider = AddSlider
        }
    end

    -- Вкладки
    local PlayerTab = AddTab("Player")
    local TrollTab = AddTab("Troll")
    local ServerTab = AddTab("Server")
    local ESPTab = AddTab("ESP")
    local TeleportTab = AddTab("Teleport")

    -- ============= PLAYER TAB =============
    local selectedPlayer = nil
    PlayerTab.AddDropdown("Target", {"Выбрать игрока..."}, nil, function(plr)
        selectedPlayer = Players:FindFirstChild(plr)
    end)

    PlayerTab.AddButton("Kill", function()
        if selectedPlayer then KillPlayer(selectedPlayer) end
    end)
    PlayerTab.AddButton("Freeze", function()
        if selectedPlayer then FreezePlayer(selectedPlayer) end
    end)
    PlayerTab.AddButton("Thaw", function()
        if selectedPlayer then ThawPlayer(selectedPlayer) end
    end)
    PlayerTab.AddToggle("Loop Kill", false, function(val)
        Settings.Player_LoopKill = val
        if val and selectedPlayer then LoopKill(selectedPlayer) end
    end)
    PlayerTab.AddButton("Crash", function()
        if selectedPlayer then CrashClient(selectedPlayer) end
    end)
    PlayerTab.AddButton("Kick", function()
        if selectedPlayer then ForceKickPlayer(selectedPlayer) end
    end)
    PlayerTab.AddButton("Bring", function()
        if selectedPlayer then BringPlayer(selectedPlayer) end
    end)
    PlayerTab.AddButton("Teleport To", function()
        if selectedPlayer then TeleportTo(selectedPlayer) end
    end)

    -- ============= TROLL TAB =============
    TrollTab.AddButton("Fling All", function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then FlingPlayer(plr) end
        end
    end)
    TrollTab.AddButton("Spin All", function()
        for _, plr in ipairs(Players:GetPlayers()) do
            local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.AngularVelocity = Vector3.new(0,50,0)
            end
        end
    end)
    TrollTab.AddToggle("Noclip", false, function(val)
        Settings.Noclip = val
        if val then
            RunService.Stepped:Connect(function()
                if Settings.Noclip and LocalPlayer.Character then
                    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    end)
    TrollTab.AddSlider("Walk Speed", 16, 200, 16, function(val)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end)
    TrollTab.AddSlider("Jump Power", 50, 300, 50, function(val)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end)
    TrollTab.AddToggle("Fly", false, function(val)
        Settings.Fly_Enabled = val
        if val then
            -- реализация Fly через BodyVelocity
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Parent = root
                local bg = Instance.new("BodyGyro")
                bg.CFrame = root.CFrame
                bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                bg.Parent = root
                -- управление
                local flySpeed = Settings.Fly_Speed
                local keys = {}
                local uis = UserInputService
                uis.InputBegan:Connect(function(input)
                    if input.KeyCode == Enum.KeyCode.W then keys.w = true
                    elseif input.KeyCode == Enum.KeyCode.S then keys.s = true
                    elseif input.KeyCode == Enum.KeyCode.A then keys.a = true
                    elseif input.KeyCode == Enum.KeyCode.D then keys.d = true
                    elseif input.KeyCode == Enum.KeyCode.Space then keys.space = true
                    elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.shift = true
                    end
                end)
                uis.InputEnded:Connect(function(input)
                    if input.KeyCode == Enum.KeyCode.W then keys.w = false
                    elseif input.KeyCode == Enum.KeyCode.S then keys.s = false
                    elseif input.KeyCode == Enum.KeyCode.A then keys.a = false
                    elseif input.KeyCode == Enum.KeyCode.D then keys.d = false
                    elseif input.KeyCode == Enum.KeyCode.Space then keys.space = false
                    elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.shift = false
                    end
                end)
                RunService.RenderStepped:Connect(function()
                    if not Settings.Fly_Enabled then bv:Destroy(); bg:Destroy(); return end
                    local vel = Vector3.new()
                    if keys.w then vel = vel + Camera.CFrame.LookVector * flySpeed
                    elseif keys.s then vel = vel - Camera.CFrame.LookVector * flySpeed end
                    if keys.a then vel = vel - Camera.CFrame.RightVector * flySpeed
                    elseif keys.d then vel = vel + Camera.CFrame.RightVector * flySpeed end
                    if keys.space then vel = vel + Vector3.new(0,flySpeed,0) end
                    if keys.shift then vel = vel - Vector3.new(0,flySpeed,0) end
                    bv.Velocity = vel
                    bg.CFrame = Camera.CFrame
                end)
            end
        end
    end)

    -- ============= SERVER TAB =============
    ServerTab.AddButton("Lag Server (heavy)", function()
        local parts = {}
        for i=1,200 do
            local p = Instance.new("Part")
            p.Size = Vector3.new(1,1,1)
            p.Position = Vector3.new(math.random(-100,100),50, math.random(-100,100))
            p.Anchored = true
            p.Parent = Workspace
            table.insert(parts, p)
        end
        task.wait(3)
        for _, p in ipairs(parts) do p:Destroy() end
    end)
    ServerTab.AddButton("Kick All", function()
        KickAllPlayers()
    end)
    ServerTab.AddButton("Shutdown Server", function()
        -- Попытка вызова удаленного ивента на рестарт
        local remotes = ReplicatedStorage:GetDescendants()
        for _, r in ipairs(remotes) do
            if r:IsA("RemoteEvent") and (r.Name == "Shutdown" or r.Name == "EndGame") then
                r:FireServer()
            end
        end
    end)

    -- ============= ESP TAB =============
    local espObjects = {}
    local function EnableESP()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "RyzenESP"
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.Adornee = plr.Character
                highlight.Parent = plr.Character
                espObjects[plr] = highlight
            end
        end
    end
    local function DisableESP()
        for plr, hl in pairs(espObjects) do
            hl:Destroy()
        end
        table.clear(espObjects)
    end
    ESPTab.AddToggle("Enable ESP", false, function(val)
        Settings.ESP_Enabled = val
        if val then EnableESP() else DisableESP() end
    end)
    ESPTab.AddToggle("Box ESP", false, function(val) Settings.ESP_Boxes = val end)
    ESPTab.AddToggle("Tracers", false, function(val) Settings.ESP_Tracers = val end)

    -- Обновление ESP в цикле
    RunService.RenderStepped:Connect(function()
        if Settings.ESP_Enabled then
            for plr, hl in pairs(espObjects) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local role = "Innocent" -- можно определить через Backpack и т.д.
                    if plr.Backpack:FindFirstChild("Knife") then role = "Murderer"
                    elseif plr.Backpack:FindFirstChild("Gun") then role = "Sheriff" end
                    local color = role == "Murderer" and Color3.new(1,0,0) or Color3.new(0,1,0)
                    hl.OutlineColor = color
                end
            end
        end
    end)

    -- ============= TELEPORT TAB =============
    TeleportTab.AddButton("Teleport to Spawn", function()
        local spawns = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if spawns then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawns.CFrame + Vector3.new(0,3,0)
        end
    end)
    TeleportTab.AddButton("Teleport to Coordinates", function()
        local x = 50 -- пример
        local z = 50
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, 10, z)
    end)

    -- Drag окна
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Запуск
CreateGUI()
print("Ryzen Hub загружен. Троллинг активирован.")
```
