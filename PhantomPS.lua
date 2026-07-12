-- Fun Hub v5 - Fly + Speed Boost 29.8 + Giant Potion Speed 35.5 + Auto Flash Steal + Look Down/Up + Respawn + Lagger + Draggable + Keybind Q + Animation
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    if PlayerGui:FindFirstChild("FunHubV5") then PlayerGui["FunHubV5"]:Destroy() end
end)

local speedBoostMax = 29.8
local giantPotionSpeed = 35.5 -- SPEED DU GIANT POTION
local targetFovValue = 70
local toggleStates = {}
local boostConn = nil
local fovConn = nil
local flyConnection = nil
local bv, bg = nil, nil
local flySpeed = 80 -- BOOSTÉ À 80
local GREY = Color3.fromRGB(150, 150, 150) -- CONTOURS GRIS
local ACTIVE_GREY = Color3.fromRGB(80, 80, 80) -- GRIS POUR BOUTONS ACTIFS
local fakeCarpet = nil
local laggerConn = nil

-- CONFIG FLASH POSITION - METS TES COORDS ICI
local FLASH_POSITION = Vector3.new(-330.768, -7.318, 74.481)

-- ========== GUI BASE ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FunHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 415) -- +35 pour Lagger
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -207.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- NOIR PUR
MainFrame.BackgroundTransparency = 0 -- 100% NOIR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- ========== ANIMATION RONDS BLANCS ==========
local function createParticle()
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    particle.Position = UDim2.new(1, 10, 0, math.random(40, 400))
    particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    particle.BackgroundTransparency = math.random(3, 7) / 10
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
    particle.Parent = MainFrame
    
    local tweenInfo = TweenInfo.new(
        math.random(4, 8),
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(particle, tweenInfo, {
        Position = UDim2.new(-0.1, 0, particle.Position.Y.Scale, particle.Position.Y.Offset)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        particle:Destroy()
    end)
end

spawn(function()
    while MainFrame.Parent do
        createParticle()
        task.wait(math.random(3, 8) / 10)
    end
end)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 4.5
mainStroke.Color = GREY -- CONTOUR GRIS
mainStroke.Transparency = 0.08
mainStroke.ZIndex = 2
mainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, -14, 0, 34)
TitleBar.Position = UDim2.new(0, 7, 0, 7)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10) -- NOIR FONCÉ
TitleBar.BackgroundTransparency = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 9)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -65, 1, 0)
TitleLbl.Position = UDim2.new(0, 32, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "PHANTOMPS" -- TITRE CHANGÉ
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255) -- BLANC PUR
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 13 -- PLUS GROS
TitleLbl.TextStrokeTransparency = 0 -- CONTOUR NOIR POUR NETTETÉ
TitleLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TitleLbl.ZIndex = 3
TitleLbl.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- BLANC PUR
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11 -- PLUS GROS
CloseBtn.TextStrokeTransparency = 0
CloseBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.ZIndex = 3
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ========== FONCTION LAGGER ==========
local function toggleLagger()
    if laggerConn then
        laggerConn:Disconnect()
        laggerConn = nil
        toggleStates["Lagger"] = false
        laggerBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        laggerBtn.Text = "💥 Lagger OFF"
        print("💥 Lagger OFF")
    else
        toggleStates["Lagger"] = true
        laggerBtn.BackgroundColor3 = ACTIVE_GREY -- GRIS QUAND ACTIF
        laggerBtn.Text = "💥 Lagger ON"
        print("💥 Lagger ON - ça va freeze")
        
        laggerConn = RunService.Heartbeat:Connect(function()
            for i = 1, 50 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(1, 1)
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1
                part.Parent = Workspace
                game:GetService("Debris"):AddItem(part, 0.1)
            end
        end)
    end
end

-- ========== FONCTION RESPAWN INSTANT ==========
local function respawnPlayer()
    print("💀 Respawn instant")
    LocalPlayer:LoadCharacter() -- Respawn instant au spawn normal
end

-- ========== FONCTION LOOK DOWN ==========
local function lookDown()
    local camCF = Camera.CFrame
    Camera.CFrame = camCF * CFrame.Angles(math.rad(-20), 0, 0)
    print("👇 Vision baissée légèrement")
end

-- ========== FONCTION LOOK UP ==========
local function lookUp()
    local camCF = Camera.CFrame
    Camera.CFrame = camCF * CFrame.Angles(math.rad(20), 0, 0)
    print("👆 Vision levée légèrement")
end

-- ========== FONCTION POUR EQUIP FLASH ==========
local function EquipFlash()
    local flashTool = LocalPlayer.Backpack:FindFirstChild("Flash Teleport") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Flash Teleport"))
    if flashTool then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(flashTool)
            print("⚡ Flash Teleport équipé!")
        end
    else
        print("❌ Flash Teleport pas trouvé dans le backpack")
    end
end

-- ========== FONCTION POUR EQUIP CARPET ==========
local function EquipCarpet()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local carpet = backpack and backpack:FindFirstChild("Flying Carpet") or (char and char:FindFirstChild("Flying Carpet"))
    if carpet and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(carpet)
            task.wait(0.02)
            print("🪄 Flying Carpet équipé!")
        end
    else
        print("❌ Flying Carpet pas trouvé dans le backpack")
    end
end

-- ========== CLONE CARPET VISUEL ==========
local function AttachFakeCarpet()
    local char = LocalPlayer.Character
    if not char then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local carpetTool = backpack and backpack:FindFirstChild("Flying Carpet")
    if not carpetTool then return end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool.Name:lower():find("brain") or currentTool.Name:lower():find("rot")) then
        if fakeCarpet then fakeCarpet:Destroy() end

        fakeCarpet = carpetTool.Handle:Clone()
        fakeCarpet.Name = "FakeCarpet"
        fakeCarpet.Parent = char

        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        if rightHand then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = rightHand
            weld.Part1 = fakeCarpet
            weld.Parent = fakeCarpet
            fakeCarpet.CFrame = rightHand.CFrame * CFrame.new(0, -1, 0)
        end
        print("🪄 Carpet visuel attaché avec le brainrot!")
    else
        EquipCarpet()
    end
end

local function RemoveFakeCarpet()
    if fakeCarpet then
        fakeCarpet:Destroy()
        fakeCarpet = nil
    end
end

-- ========== SPEED BOOST ==========
local function enableSpeedBoost(targetSpeed)
    if boostConn then boostConn:Disconnect() end
    boostConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            hrp.Velocity = Vector3.new(flatDir.X * targetSpeed, hrp.Velocity.Y, flatDir.Z * targetSpeed)
        end
    end)
end

local function disableSpeedBoost()
    if boostConn then boostConn:Disconnect() boostConn = nil end
end

-- ========== FLY ==========
local function toggleFly()
    if flyConnection then
        flyConnection:Disconnect()
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        RemoveFakeCarpet()
        flyConnection = nil
        bv = nil
        bg = nil
        toggleStates["Fly"] = false
        flyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        flyBtn.Text = "🕹 Fly OFF (Q)"
    else
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("brain") or tool.Name:lower():find("rot")) then
            print("❌ Fly désactivé : tu as un brainrot dans les mains")
            return
        end

        AttachFakeCarpet()
        local root = LocalPlayer.Character.HumanoidRootPart
        bv = Instance.new("BodyVelocity")
        bg = Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 12500
        bv.Parent = root
        bg.Parent = root

        flyConnection = RunService.Heartbeat:Connect(function()
            local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if currentTool and (currentTool.Name:lower():find("brain") or currentTool.Name:lower():find("rot")) then
                print("❌ Fly coupé : brainrot détecté")
                toggleFly()
                return
            end

            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            bv.Velocity = moveDir * flySpeed
            bg.CFrame = Camera.CFrame
        end)
    end
end

-- ========== AUTO FLASH ON STEAL ====================
local flashEnabled = false
local flashConnection = nil

local function toggleFlash()
    flashEnabled = not flashEnabled

    if flashEnabled then
        print("⚡ Auto Flash activé - Équipe Flash + TP après vol avec E")
        EquipFlash()

        flashConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not flashEnabled then return end

            if input.KeyCode == Enum.KeyCode.E then
                EquipCarpet()
                task.wait(0.15)

                if LocalPlayer.Character then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name:lower():find("brain") or tool.Name:lower():find("rot")) then
                        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(FLASH_POSITION)
                            print("⚡ FLASH! TP hors de la base après vol")
                        end
                    end
                end
            end
        end)
    else
        print("⚡ Auto Flash désactivé")
        if flashConnection then
            flashConnection:Disconnect()
            flashConnection = nil
        end
    end
end

-- ========== BOUTONS UI ==========
local function createButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 28)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255) -- BLANC PUR
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11 -- PLUS GROS
    btn.TextStrokeTransparency = 0 -- CONTOUR NOIR POUR NETTETÉ
    btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    btn.ZIndex = 2
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = GREY -- CONTOUR GRIS
    stroke.ZIndex = 2

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

local speedBtn = createButton("⚡ Speed Boost OFF [29.8]", 50)
speedBtn.MouseButton1Click:Connect(function()
    if toggleStates["Giant Potion Speed"] then
        toggleStates["Giant Potion Speed"] = false
        giantPotionBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        giantPotionBtn.Text = "🧪 Giant Potion Speed OFF [35.5]"
        disableSpeedBoost()
    end

    toggleStates["Speed Boost"] = not toggleStates["Speed Boost"]
    if toggleStates["Speed Boost"] then
        speedBtn.BackgroundColor3 = ACTIVE_GREY -- GRIS QUAND ACTIF
        speedBtn.Text = "⚡ Speed Boost ON [29.8]"
        enableSpeedBoost(speedBoostMax)
    else
        speedBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        speedBtn.Text = "⚡ Speed Boost OFF [29.8]"
        disableSpeedBoost()
    end
end)

local giantPotionBtn = createButton("🧪 Giant Potion Speed OFF [35.5]", 85)
giantPotionBtn.MouseButton1Click:Connect(function()
    if toggleStates["Speed Boost"] then
        toggleStates["Speed Boost"] = false
        speedBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        speedBtn.Text = "⚡ Speed Boost OFF [29.8]"
        disableSpeedBoost()
    end

    toggleStates["Giant Potion Speed"] = not toggleStates["Giant Potion Speed"]
    if toggleStates["Giant Potion Speed"] then
        giantPotionBtn.BackgroundColor3 = ACTIVE_GREY -- GRIS QUAND ACTIF
        giantPotionBtn.Text = "🧪 Giant Potion Speed ON [35.5]"
        enableSpeedBoost(giantPotionSpeed)
    else
        giantPotionBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        giantPotionBtn.Text = "🧪 Giant Potion Speed OFF [35.5]"
        disableSpeedBoost()
    end
end)

local flyBtn = createButton("🕹 Fly OFF (Q)", 120)
flyBtn.MouseButton1Click:Connect(function()
    toggleStates["Fly"] = not toggleStates["Fly"]
    if toggleStates["Fly"] then
        flyBtn.BackgroundColor3 = ACTIVE_GREY -- GRIS QUAND ACTIF
        flyBtn.Text = "🕹 Fly ON (Q)"
        toggleFly()
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        flyBtn.Text = "🕹 Fly OFF (Q)"
        toggleFly()
    end
end)

-- KEYBIND Q POUR FLY - LAISSE SUR Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleStates["Fly"] = not toggleStates["Fly"]
        if toggleStates["Fly"] then
            flyBtn.BackgroundColor3 = ACTIVE_GREY
            flyBtn.Text = "🕹 Fly ON (Q)"
            toggleFly()
        else
            flyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            flyBtn.Text = "🕹 Fly OFF (Q)"
            toggleFly()
        end
    end
end)

local flashBtn = createButton("⚡ Auto Flash OFF", 155)
flashBtn.MouseButton1Click:Connect(function()
    toggleStates["Auto Flash"] = not toggleStates["Auto Flash"]
    if toggleStates["Auto Flash"] then
        flashBtn.BackgroundColor3 = ACTIVE_GREY -- GRIS QUAND ACTIF
        flashBtn.Text = "⚡ Auto Flash ON"
        toggleFlash()
    else
        flashBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        flashBtn.Text = "⚡ Auto Flash OFF"
        toggleFlash()
    end
end)

local lookDownBtn = createButton("👇 Look Down", 190)
lookDownBtn.MouseButton1Click:Connect(function()
    lookDown()
end)

local lookUpBtn = createButton("👆 Look Up", 225)
lookUpBtn.MouseButton1Click:Connect(function()
    lookUp()
end)

local respawnBtn = createButton("💀 Respawn", 260)
respawnBtn.MouseButton1Click:Connect(function()
    respawnPlayer()
end)

local laggerBtn = createButton("💥 Lagger OFF", 295)
laggerBtn.MouseButton1Click:Connect(function()
    toggleLagger()
end)

print("✅ Fun Hub v5 chargé - Speed 29.8 + Giant Potion Speed 35.5 + Fly 80 + Auto Flash + Look Down/Up + Respawn + Lagger + Keybind Q + Animation")
