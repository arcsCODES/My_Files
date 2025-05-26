-- ============================================================
-- SECTION 1: Caricamento di Fluent GUI
-- ============================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

if not Fluent then
    warn("⚠️ Unable to load Fluent GUI!")
    return
end

-- ============================================================
-- SECTION 2: Servizi e Variabili Globali
-- ============================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local virtualInput = game:GetService("VirtualInputManager")
local localPlayer = game.Players.LocalPlayer
local Players = game:GetService("Players")
local Options = Fluent.Options
local TweenService = game:GetService("TweenService")

-- ============================================================
-- SECTION 3: Creazione della Finestra GUI
-- ============================================================
local Window = Fluent:CreateWindow({
    Title = "CipherX Hub " .. Fluent.Version,
    SubTitle = "by SniderTrader", -- Sostituisci con il tuo nome
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- L'effetto blur potrebbe essere rilevabile, impostare su false per disabilitarlo
    Theme = "Amethyst", -- Dark, Darker, Light Aqua, Rose, Amethyst, NSExpression
    MinimizeKey = Enum.KeyCode.LeftControl -- Usato quando non c'è un tasto di minimizzazione predefinito
})

-- Fluent fornisce icone Lucide (https://lucide.dev/icons/) per le tab, le icone sono opzionali
local Tabs = {
    OP = Window:AddTab({ Title = "OP", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "" })
}

-- ============================================================
-- SECTION 4: Funzioni di Utilità
-- ============================================================
local function EquipKnife()
    local char = localPlayer.Character
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Knife") then
        backpack.Knife.Parent = char
    end
end

local function ClickM1()
    virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ============================================================
-- SECTION 5: OP TAB - Auto Kill, ESP, God Mode
-- ============================================================
-----------------------------------
-- 5.1 Auto Kill All (Extended Distance)
-----------------------------------
Tabs.OP:AddButton({
    Title = "Auto Kill All",
    Description = "Attacca automaticamente i giocatori vicini",
    Callback = function()
        local function AutoKillAll()
            local knife = localPlayer:FindFirstChild("Backpack") and localPlayer.Backpack:FindFirstChild("Knife")
            if not knife then
                Fluent:Notify({ Title = "Auto Kill", Content = "Non hai un coltello!", Duration = 3 })
                return
            end

            Fluent:Notify({ Title = "Auto Kill", Content = "Auto Kill attivato...", Duration = 2 })

            local players = game:GetService("Players"):GetPlayers()
            local maxDistance = 500

            for _, player in pairs(players) do
                if player ~= localPlayer then
                    local character = player.Character
                    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                        local distance = (localPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).magnitude
                        if distance <= maxDistance then
                            EquipKnife()
                            repeat
                                localPlayer.Character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                                for i = 1, 3 do ClickM1() end
                                task.wait(0.1)
                            until (not character:FindFirstChild("Humanoid")) or (character.Humanoid.Health <= 0)
                        end
                    end
                end
            end

            Fluent:Notify({ Title = "Auto Kill", Content = "Azione completata.", Duration = 3 })
        end
        AutoKillAll()
    end
})

-----------------------------------
-- 5.2 ESP (Murder/Sheriff Tags)
-----------------------------------
local espEnabled = false
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "CipherX_ESP"

local function createESP(player, role)
    local tag = Instance.new("BillboardGui")
    tag.Name = "ESP_Tag"
    tag.Size = UDim2.new(0, 100, 0, 40)
    tag.Adornee = player.Character:WaitForChild("Head")
    tag.AlwaysOnTop = true
    local label = Instance.new("TextLabel", tag)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = role
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = role == "Murder" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 170, 255)
    tag.Parent = espFolder
end

local function removeAllESP()
    for _, gui in ipairs(espFolder:GetChildren()) do
        if gui:IsA("BillboardGui") and gui.Name == "ESP_Tag" then
            gui:Destroy()
        end
    end
end

local function updateESP()
    if espEnabled then
        removeAllESP()
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local hasKnife = (player.Backpack and player.Backpack:FindFirstChild("Knife")) or player.Character:FindFirstChild("Knife")
                local hasGun = (player.Backpack and player.Backpack:FindFirstChild("Gun")) or player.Character:FindFirstChild("Gun")
                if hasKnife then createESP(player, "Murder") elseif hasGun then createESP(player, "Sheriff") end
            end
        end
    else
        removeAllESP()
    end
end

-- Modifica qui: Utilizza una variabile booleana locale per tracciare lo stato del toggle
local isEspToggled = false

local espToggle = Tabs.OP:AddToggle("ESPMurderSheriff", { Title = "ESP Murder/Sheriff", Default = false })
espToggle:OnChanged(function()
    espEnabled = Options.ESPMurderSheriff.Value
    isEspToggled = espEnabled -- Aggiorna la variabile locale
end)

task.spawn(function()
    while true do
        -- Controlla la variabile locale per decidere se aggiornare l'ESP
        if isEspToggled then
            updateESP()
        else
            removeAllESP()
        end
        task.wait(2)
    end
end)

-----------------------------------
-- 5.3 God Mode
-----------------------------------
local godModeEnabled = false
local humanoid = nil
local healthCheckConnection = nil

local function ensureFullHealth()
    if godModeEnabled and humanoid and humanoid.Health < humanoid.MaxHealth then
        humanoid.Health = humanoid.MaxHealth
    end
end

local function updateGodModeState(character)
    if character then
        humanoid = character:WaitForChild("Humanoid")
        if godModeEnabled then
            humanoid.MaxHealth = math.huge
            humanoid.Health = humanoid.MaxHealth
            if not healthCheckConnection then healthCheckConnection = RunService.Heartbeat:Connect(ensureFullHealth) end
        else
            humanoid.MaxHealth = 100
            if humanoid.Health > 100 then humanoid.Health = 100 end
            if healthCheckConnection then healthCheckConnection:Disconnect(); healthCheckConnection = nil end
        end
    end
end

local godModeToggle = Tabs.OP:AddToggle("GodMode", { Title = "God Mode", Default = false })
godModeToggle:OnChanged(function()
    godModeEnabled = Options.GodMode.Value
    updateGodModeState(localPlayer.Character)
end)

localPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateGodModeState(character)
end)

-- ============================================================
-- SECTION 6: PLAYER TAB - Dropdown, View, Noclip, Walk Speed, Jump Power, Fly
-- ============================================================
local selectedPlayer = nil
local teleportSpeed = 50 -- Velocità predefinita per il teletrasporto

local playerListDropdown = Tabs.Player:AddDropdown("SelectedPlayer", {
    Title = "Select Player",
    Values = {},
    Default = "None",
})

local function UpdatePlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= localPlayer then table.insert(names, p.Name) end end
    playerListDropdown:SetValues(names)
end

playerListDropdown:OnChanged(function() selectedPlayer = Players:FindFirstChild(Options.SelectedPlayer.Value) end)

local viewPlayerToggle = Tabs.Player:AddToggle("ViewSelected", { Title = "View Selected Player", Default = false })
viewPlayerToggle:OnChanged(function()
    local state = Options.ViewSelected.Value
    local cam = workspace.CurrentCamera
    if state and selectedPlayer and selectedPlayer.Character then
        cam.CameraSubject = selectedPlayer.Character:WaitForChild("Head")
        cam.CameraType = Enum.CameraType.Attach
    else
        cam.CameraSubject = localPlayer.Character:WaitForChild("Humanoid")
        cam.CameraType = Enum.CameraType.Custom
    end
end)

task.spawn(function() while true do UpdatePlayerList() task.wait(5) end end)

local noclipEnabled = false
local noclipConnection
local function noclipLoop()
    local char = localPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end

local noclipToggle = Tabs.Player:AddToggle("Noclip", { Title = "Noclip", Default = false })
noclipToggle:OnChanged(function()
    noclipEnabled = Options.Noclip.Value
    if noclipEnabled then noclipConnection = RunService.Stepped:Connect(noclipLoop)
    elseif noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil; noclipLoop() end
end)

-- SLIDER PER LA VELOCITÀ DEL PERSONAGGIO (WalkSpeed)
local walkSpeed = 16 -- Velocità predefinita
local walkSpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Min = 1,
    Max = 100,
    Default = walkSpeed,
    Rounding = 0,
})
walkSpeedSlider:OnChanged(function(value)
    walkSpeed = value
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- SLIDER PER LA POTENZA DEL SALTO (JumpPower)
local jumpPower = 50 -- Potenza di salto predefinita
local jumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Min = 10,
    Max = 200,
    Default = jumpPower,
    Rounding = 0,
})
jumpPowerSlider:OnChanged(function(value)
    jumpPower = value
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.JumpPower = value
    end
end)

local flying = false
local flySpeed = 50
local flyConnection
local flyVelocity

local flySpeedSlider = Tabs.Player:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = flySpeed,
    Rounding = 0,
})
flySpeedSlider:OnChanged(function(value) flySpeed = value end)

local function startFlying()
    local char = localPlayer.Character
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if char and rootPart then
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyVelocity.P = 1250
        flyVelocity.Name = "FlyVelocity"
        flyVelocity.Parent = rootPart
        flyConnection = RunService.RenderStepped:Connect(function()
            local camCF = workspace.CurrentCamera.CFrame
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then flyVelocity.Velocity = move.Unit * flySpeed else flyVelocity.Velocity = Vector3.new(0, 0, 0) end
        end)
    else
        Fluent:Notify({ Title = "Error", Content = "Character non trovato!", Duration = 2 })
        flying = false
    end
end

local function stopFlying()
    flying = false
    if flyVelocity then flyVelocity:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
end

local flyToggle = Tabs.Player:AddToggle("FlyImproved", { Title = "Fly (Improved)", Default = false })
flyToggle:OnChanged(function()
    flying = Options.FlyImproved.Value
    if flying then startFlying() else stopFlying() end
end)


Window:SelectTab(1)

Fluent:Notify({ Title = "CipherX Hub", Content = "Script caricato!", Duration = 5 })

-- Imposta la velocità iniziale del personaggio all'avvio dello script
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = 16
    LocalPlayer.Character.Humanoid.JumpPower = 50
end