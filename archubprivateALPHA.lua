-- HUB BY @ARCTURUSZZ
-- GET ICONS HERE: https://github.com/frappedevs/lucideblox/blob/master/src/modules/util/icons.json

-- Load Native UI Library
local Library = (getgenv and getgenv().NATIVELIBRARY) or loadstring(game:HttpGet("https://getnative.cc/script/interface", true))()
getgenv().NATIVELIBRARY = Library

-- Services (declare once at the top)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AnchorRemote = ReplicatedStorage:WaitForChild("Anchor")
local mouse = LocalPlayer:GetMouse()


-- UI Init
local Init = Library:Init({
    Name = "Arc's Native Hub",
    Parent = game:GetService("CoreGui"),
    Callback = function(self) end,
})

-- Main Window
local Window = Init:CreateWindow({
    Name = "Arc's Hub | SA (v1.0)",
    Visible = true,
    Silent = false,
    Asset = true, -- Enables advanced theming and icons if supported
    Keybind = Enum.KeyCode.RightShift,
    Callback = function(self) end,
})

-- Scripts Tab (Main)
local ScriptTab = Window:CreateTab({
    Name = "Scripts",
    Icon = "rbxassetid://7733960981", -- Script icon
    LayoutOrder = 1,
    Home = true,
    Callback = function(self) end,
})

local ScriptSection = ScriptTab:CreateSection({
    Name = "Main scripts",
    Visible = true,
    LayoutOrder = 1,
    Callback = function(self) end,
})
-----------------------------------------------
-- 15s Timestop Toggle
-----------------------------------------------
local timestopConnection

ScriptSection:CreateToggle({
    Name = "15s TIMESTOP",
    Initial = false,
    LayoutOrder = 1,
    Value = false,
    Callback = function(self, state)
        if state then
            timestopConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
                    local args = {15, "jotaroova"}
                    local success, err = pcall(function()
                        ReplicatedStorage:WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
                    end)
                    if success then
                        print("Timestop activated via CTRL")
                    else
                        warn("Timestop failed: " .. tostring(err))
                    end
                end
            end)
            print("Timestop enabled - Press Left Control to activate")
        else
            if timestopConnection then
                timestopConnection:Disconnect()
                timestopConnection = nil
            end
            print("Timestop disabled")
        end
    end,
})

--------------------------------------------------
-- TIMESTOP MOVEMENT
--------------------------------------------------

local moveLoopActive = false

local function collectParts(parent)
    local parts = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(parts, child)
        end
        for _, grandChild in ipairs(child:GetChildren()) do
            if grandChild:IsA("BasePart") then
                table.insert(parts, grandChild)
            end
        end
    end
    return parts
end

local function anchorParts(parts, anchor)
    for _, part in ipairs(parts) do
        game:GetService("ReplicatedStorage"):WaitForChild("Anchor"):FireServer(part, anchor)
    end
end

local function toggleMovementLoop()
    while moveLoopActive do
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character then
            local character = player.Character
            local partsToToggle = collectParts(character)
            anchorParts(partsToToggle, false)

            local stand = character:FindFirstChild("Stand")
            if stand then
                local standPartsToToggle = collectParts(stand)
                anchorParts(standPartsToToggle, false)
            end
        end
        task.wait(1)
    end
end

-- GUI Toggle Integration
ScriptSection:CreateToggle({
    Name = "LIHOK SA TIMESTOP",
    Initial = false,
    LayoutOrder = 2,
    Value = false,
    Callback = function(self, state)
        if state then
            moveLoopActive = true
            task.spawn(toggleMovementLoop)
            print("Movement enabled in timestops")
        else
            moveLoopActive = false

            local player = game:GetService("Players").LocalPlayer
            if player and player.Character then
                local character = player.Character
                local partsToToggle = collectParts(character)
                anchorParts(partsToToggle, true)

                local stand = character:FindFirstChild("Stand")
                if stand then
                    local standPartsToToggle = collectParts(stand)
                    anchorParts(standPartsToToggle, true)
                end
            end
            print("Movement disabled in timestops")
        end
    end,
})


-- D4C Clone Toggle
local f2Connection, f3Connection, inputEndedConnection
local isHoldingF2, isHoldingF3 = false, false

ScriptSection:CreateToggle({
    Name = "D4C CLONES",
    Initial = false,
    LayoutOrder = 3,
    Value = false,
    Callback = function(self, state)
        local Main = ReplicatedStorage:WaitForChild("Main")
        local InputRemote = Main:WaitForChild("Input")
        local DeathRemote = Main:WaitForChild("Death")

        local f2Loop, f3Loop

        local function bindKeys()
            f2Connection = UserInputService.InputBegan:Connect(function(input, isProcessed)
                if not isProcessed and input.KeyCode == Enum.KeyCode.F2 then
                    if not isHoldingF2 then
                        isHoldingF2 = true
                        f2Loop = RunService.RenderStepped:Connect(function()
                            pcall(function()
                                InputRemote:FireServer("Alternate", "Clone")
                            end)
                            task.wait(0.1)
                        end)
                    end
                end
            end)

            f3Connection = UserInputService.InputBegan:Connect(function(input, isProcessed)
                if not isProcessed and input.KeyCode == Enum.KeyCode.F3 then
                    if not isHoldingF3 then
                        isHoldingF3 = true
                        f3Loop = RunService.RenderStepped:Connect(function()
                            pcall(function()
                                DeathRemote:FireServer("Alternate", "Death")
                            end)
                            task.wait(0)
                        end)
                    end
                end
            end)

            inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.F2 and isHoldingF2 then
                    isHoldingF2 = false
                    if f2Loop then f2Loop:Disconnect() f2Loop = nil end
                elseif input.KeyCode == Enum.KeyCode.F3 and isHoldingF3 then
                    isHoldingF3 = false
                    if f3Loop then f3Loop:Disconnect() f3Loop = nil end
                end
            end)
        end

        local function unbindKeys()
            if f2Connection then f2Connection:Disconnect() f2Connection = nil end
            if f3Connection then f3Connection:Disconnect() f3Connection = nil end
            if inputEndedConnection then inputEndedConnection:Disconnect() inputEndedConnection = nil end
            if f2Loop then f2Loop:Disconnect() f2Loop = nil end
            if f3Loop then f3Loop:Disconnect() f3Loop = nil end
            isHoldingF2, isHoldingF3 = false, false
        end

        if state then
            bindKeys()
            print("D4C Clone/Death keybinds enabled")
        else
            unbindKeys()
            print("D4C Clone/Death keybinds disabled")
        end
    end,
})

-------------------------------------------
-- STW COUNTER
-------------------------------------------
local attackLoopConnection

ScriptSection:CreateToggle({
    Name = "STW COUNTER",
    Initial = false,
    LayoutOrder = 4,
    Value = false,
    Callback = function(self, state)
        local Main = ReplicatedStorage:WaitForChild("Main")
        local InputRemote = Main:WaitForChild("Input")

        -- Function to start attack loop
        local function startAttackLoop()
            local lastFire = 0
            attackLoopConnection = RunService.RenderStepped:Connect(function()
                if tick() - lastFire >= 1 then
                    pcall(function()
                        InputRemote:FireServer("Alternate", "STWRTZ", true)
                    end)
                    lastFire = tick()
                end
            end)
        end

        -- Cleanup function
        local function stopAttackLoop()
            if attackLoopConnection then
                attackLoopConnection:Disconnect()
                attackLoopConnection = nil
            end
        end

        if state then
            stopAttackLoop() -- Ensure any previous is cleaned up
            startAttackLoop()
            print("STW Counter activated")
        else
            stopAttackLoop()
            print("STW Counter deactivated")
        end
    end,
})

-------------------------------------------
-- RIFT SLICE
-------------------------------------------
local riftInputBeganConn, riftInputEndedConn
local riftSliceActive = false
local riftSliceLoop = nil

ScriptSection:CreateToggle({
    Name = "REAVER RIFT SLICE",
    Initial = false,
    LayoutOrder = 5,
    Value = false,
    Callback = function(self, state)
        local Main = ReplicatedStorage:WaitForChild("Main")
        local InputRemote = Main:WaitForChild("Input")

        local function startRiftSliceLoop()
            riftSliceLoop = task.spawn(function()
                while riftSliceActive do
                    pcall(function()
                        InputRemote:FireServer("Alternate", "RiftSlice")
                    end)
                    task.wait(0.05)
                end
            end)
        end

        local function onInputBegan(input, gameProcessedEvent)
            if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.F and not riftSliceActive then
                riftSliceActive = true
                startRiftSliceLoop()
            end
        end

        local function onInputEnded(input)
            if input.KeyCode == Enum.KeyCode.F then
                riftSliceActive = false
            end
        end

        if state then
            riftInputBeganConn = UserInputService.InputBegan:Connect(onInputBegan)
            riftInputEndedConn = UserInputService.InputEnded:Connect(onInputEnded)
            print("Rift Slice enabled")
        else
            if riftInputBeganConn then riftInputBeganConn:Disconnect() riftInputBeganConn = nil end
            if riftInputEndedConn then riftInputEndedConn:Disconnect() riftInputEndedConn = nil end
            riftSliceActive = false
            print("Rift Slice disabled")
        end
    end,
})

-------------------------------------------
-- GER RTZ
-------------------------------------------
local rtzConnection

ScriptSection:CreateToggle({
    Name = "GER RTZ",
    Initial = false,
    LayoutOrder = 6,
    Value = false,
    Callback = function(self, state)
        local InputRemote = ReplicatedStorage:WaitForChild("Main"):WaitForChild("Input")
        local debounce = false

        local function triggerRTZ()
            if debounce then return end
            debounce = true
            pcall(function()
                InputRemote:FireServer("Alternate", "RTZ", true)
            end)
            task.delay(0.5, function() debounce = false end) -- cooldown to avoid spamming
        end

        if state then
            rtzConnection = UserInputService.InputBegan:Connect(function(input, isProcessed)
                if not isProcessed and input.KeyCode == Enum.KeyCode.B then
                    triggerRTZ()
                end
            end)
            print("GER RTZ enabled")
        else
            if rtzConnection then
                rtzConnection:Disconnect()
                rtzConnection = nil
            end
            print("GER RTZ disabled")
        end
    end,
})

-------------------------------------------
-- BLOCK GLITCH
-------------------------------------------
ScriptSection:CreateToggle({
    Name = "BLOCK GLITCH",
    Initial = false,
    LayoutOrder = 7,
    Value = false,
    Callback = function(self, state)
        local Main = ReplicatedStorage:WaitForChild("Main")
        local InputRemote = Main:WaitForChild("Input")

        if state then
            -- Enable block
            pcall(function()
                InputRemote:FireServer("Alternate", "Block")
            end)
            print("Blocking enabled (glitch)")
        else
            -- Optionally try disabling or resetting block if needed
            pcall(function()
                InputRemote:FireServer("Alternate", "Block") -- Some games use same trigger to toggle off
            end)
            print("Blocking disabled (glitch)")
        end
    end,
})

-------------------------------------------
-- HG EMERALD SPLASH
-------------------------------------------
local emeraldSplashConnection
local PROJECTILE_COUNT = 50

ScriptSection:CreateToggle({
    Name = "HG EMERALD SPLASH",
    Initial = false,
    LayoutOrder = 8,
    Value = false,
    Callback = function(self, state)
        local InputRemote = ReplicatedStorage:WaitForChild("Main"):WaitForChild("Input")
        local LocalPlayer = Players.LocalPlayer
        local Mouse = LocalPlayer:GetMouse()

        local function fireEmeraldBurst()
            if not Mouse or not Mouse.Hit then return end

            local basePosition = Mouse.Hit.Position

            for i = 1, PROJECTILE_COUNT do
                local angle = math.random() * 2 * math.pi
                local distance = math.random(4, 8)
                local height = math.random(-2, 2)

                local offset = Vector3.new(
                    math.cos(angle) * distance,
                    height,
                    math.sin(angle) * distance
                )

                local targetCFrame = CFrame.new(basePosition + offset)

                -- Safe fire
                pcall(function()
                    InputRemote:FireServer("Alternate", "EmeraldProjectile2", false, targetCFrame)
                end)
            end
        end

        local function onInputBegan(input, isProcessed)
            if not isProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
                fireEmeraldBurst()
            end
        end

        if state then
            emeraldSplashConnection = UserInputService.InputBegan:Connect(onInputBegan)
            print("HG Emerald Splash enabled. Hold LCTRL to fire.")
        else
            if emeraldSplashConnection then
                emeraldSplashConnection:Disconnect()
                emeraldSplashConnection = nil
            end
            print("HG Emerald Splash disabled.")
        end
    end,
})

-------------------------------------------
-- VTW KNIFE
-------------------------------------------
local knifeBeganConnection -- For InputBegan
local knifeEndedConnection -- For InputEnded
local holdingKnifeConnection -- For Heartbeat
local isHolding = false -- Flag to track if the key is being held down

local function throwKnife()
    local targetPosition = mouse.Hit.Position
    local args = {
        [1] = "Alternate",
        [2] = "Knife",
        [3] = targetPosition
    }
    ReplicatedStorage:WaitForChild("Main"):WaitForChild("Input"):FireServer(unpack(args))
end

ScriptSection:CreateToggle({
    Name = "VTW KNIFE",
    Initial = false,
    LayoutOrder = 9,
    Value = false,
    Callback = function(self, state)
        if state then
            knifeBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == Enum.KeyCode.One then
                    if not isHolding then
                        isHolding = true
                        holdingKnifeConnection = RunService.Heartbeat:Connect(function()
                            if isHolding then
                                throwKnife()
                            end
                        end)
                    end
                end
            end)
            
            knifeEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == Enum.KeyCode.One then
                    isHolding = false
                    if holdingKnifeConnection then
                        holdingKnifeConnection:Disconnect()
                        holdingKnifeConnection = nil
                    end
                end
            end)

            print("Knife throw enabled")
        else
            if knifeBeganConnection then
                knifeBeganConnection:Disconnect()
                knifeBeganConnection = nil
            end
            if knifeEndedConnection then
                knifeEndedConnection:Disconnect()
                knifeEndedConnection = nil
            end
            if holdingKnifeConnection then
                holdingKnifeConnection:Disconnect()
                holdingKnifeConnection = nil
            end
            isHolding = false
            print("Knife throw disabled")
        end
    end,
})

-------------------------------------------
-- STANDLESS COUNTER
-------------------------------------------
local counterCoroutine

ScriptSection:CreateToggle({
    Name = "STANDLESS COUNTER",
    Initial = false,
    LayoutOrder = 10,
    Value = false,
    Callback = function(self, state)
        local args = {"Alternate", "Counter"}
        local main = ReplicatedStorage:WaitForChild("Main")
        local input = main:WaitForChild("Input")

        local function counterLoop()
            while state do
                input:FireServer(unpack(args))
                wait(0.5)
            end
        end

        if state then
            if counterCoroutine then
                counterCoroutine = nil
            end
            counterCoroutine = coroutine.create(counterLoop)
            coroutine.resume(counterCoroutine)
            print("Counter attack of Standless enabled")
        else
            counterCoroutine = nil
            print("Counter attack of Standless disabled")
        end
    end,
})



-- ==================================================
-- SECTION 2: OTHER SCRIPTS
-- ==================================================
local S2Section = ScriptTab:CreateSection({
    Name = "Other scripts",
    Visible = true,
    LayoutOrder = 11,
    Callback = function(self) end,
})

S2Section:CreateButton({
    Name = "ARC'S UTILITY",
    Initial = false,
    LayoutOrder = 1,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-STANDSAWAKENING/refs/heads/main/SA_UTILITY.lua",true))()
    end,
})

S2Section:CreateButton({
    Name = "INF YIELD",
    Initial = false,
    LayoutOrder = 2,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
    end,
})

S2Section:CreateButton({
    Name = "TP LOOP LIKOD SA PLAYER",
    Initial = false,
    LayoutOrder = 3,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-UNIVERSAL/refs/heads/main/FollowPlayersBack.lua",true))()
    end,
})

S2Section:CreateButton({
    Name = "PLAYER TELEPORTASYON",
    Initial = false,
    LayoutOrder = 4,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-UNIVERSAL/refs/heads/main/PlayerTeleportation.lua"))()
    end,
})

S2Section:CreateButton({
    Name = "GET COORDINATES",
    Initial = false,
    LayoutOrder = 5,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-STANDSAWAKENING/refs/heads/main/GetCoordinatesScript.lua"))()
    end,
})

S2Section:CreateButton({
    Name = "NAMELESS ADMIN",
    Initial = false,
    LayoutOrder = 6,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-full/refs/heads/main/roblox%20scripts/universal/namelessAdmin.lua"))()
    end,
})








-- HBE TAB

-- HBE Tab (Example of another section)
local HBETab = Window:CreateTab({
    Name = "HBE",
    Icon = "rbxassetid://7734068321", -- Lightning or fire icon
    LayoutOrder = 2,
    Callback = function(self) end,
})

local HBESection = HBETab:CreateSection({
    Name = "HitBox expanders",
    Visible = true,
    LayoutOrder = 1,
    Callback = function(self) end,
})

HBESection:CreateButton({
    Name = "CMOON HBE",
    Initial = false,
    LayoutOrder = 1,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/CMOON%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "STW HBE",
    Initial = false,
    LayoutOrder = 2,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/STW(%2Bvamp)%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "SAMURAI HBE",
    Initial = false,
    LayoutOrder = 3,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/SAMURAI%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "SPOH HBE",
    Initial = false,
    LayoutOrder = 4,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/SPOH%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "ULF HBE",
    Initial = false,
    LayoutOrder = 5,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/ULF%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "VTW/TWGH HBE",
    Initial = false,
    LayoutOrder = 6,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/VTW%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "MIH HBE",
    Initial = false,
    LayoutOrder = 7,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/KCR%20HBE.txt"))()
    end,
})

HBESection:CreateButton({
    Name = "KC HBE",
    Initial = false,
    LayoutOrder = 8,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-SA-HBE/refs/heads/main/KC%20HBE.txt"))()
    end,
})






-- TIMESTOP SOUND TAB
local TSTab = Window:CreateTab({
    Name = "TS SOUNDS",
    Icon = "rbxassetid://7734063416", 
    LayoutOrder = 3,
    Callback = function(self) end,
})

local TSSection = TSTab:CreateSection({
    Name = "Timestop sounds",
    Visible = true,
    LayoutOrder = 1,
    Callback = function(self) end,
})

TSSection:CreateButton({
    Name = "(OLD) TW OVA",
    Initial = false,
    LayoutOrder = 1,
    Callback = function()
        local args = {15, "dioova"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "(OLD) SP OVA",
    Initial = false,
    LayoutOrder = 2,
    Callback = function()
        local args = {15, "jotaroova"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "JSP TS",
    Initial = false,
    LayoutOrder = 3,
    Callback = function()
        local args = {15, "jotaro"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "SPTW TS",
    Initial = false,
    LayoutOrder = 4,
    Callback = function()
        local args = {15, "P4"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "TWOH TS",
    Initial = false,
    LayoutOrder = 5,
    Callback = function()
        local args = {15, "diooh"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "STW TS",
    Initial = false,
    LayoutOrder = 6,
    Callback = function()
        local args = {15, "shadowdio"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "TW TS",
    Initial = false,
    LayoutOrder = 7,
    Callback = function()
        local args = {15, "theworldnew"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})

TSSection:CreateButton({
    Name = "TWAU TS",
    Initial = false,
    LayoutOrder = 8,
    Callback = function()
        local args = {15, "diego"}
        game:GetService("ReplicatedStorage"):WaitForChild("Main"):WaitForChild("Timestop"):FireServer(unpack(args))
    end,
})






local SoundTab = Window:CreateTab({
    Name = "SOUNDS",
    Icon = "rbxassetid://7734063416", 
    LayoutOrder = 4,
    Callback = function(self) end,
})

local SoundSection = SoundTab:CreateSection({
    Name = "Main",
    Visible = true,
    LayoutOrder = 1,
    Callback = function(self) end,
})

SoundSection:CreateButton({
    Name = "SOUNDS",
    Initial = false,
    LayoutOrder = 1,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/arcsCODES/RobloxScripts-full/refs/heads/main/roblox%20scripts/stands%20awakening/sounds.lua"))()
    end,
})