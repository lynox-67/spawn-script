print("(custom, AC:SaB) ANTICHEAT BYPASSED")

local spawnDelay = 3.2

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local rfBrainrot = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/AdminService/SpawnBrainrot")

local rfStartEvent = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/AdminService/StartEvent")

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "BrainrotSpawner"

ScreenGui.ResetOnSpawn = false

ScreenGui.Parent = player:WaitForChild("PlayerGui")

local function makeMobileDraggable(obj)

    local dragging, dragStart, startPos

    obj.InputBegan:Connect(function(i)

        if i.UserInputType == Enum.UserInputType.Touch then

            dragging = true

            dragStart = i.Position

            startPos = obj.Position

        end

    end)

    UIS.InputChanged:Connect(function(i)

        if dragging and i.UserInputType == Enum.UserInputType.Touch then

            local delta = i.Position - dragStart

            obj.Position = UDim2.new(

                startPos.X.Scale,

                startPos.X.Offset + delta.X,

                startPos.Y.Scale,

                startPos.Y.Offset + delta.Y

            )

        end

    end)

    obj.InputEnded:Connect(function(i)

        if i.UserInputType == Enum.UserInputType.Touch then

            dragging = false

        end

    end)

end

local ToggleButton = Instance.new("ImageButton")

ToggleButton.Size = UDim2.new(0,70,0,70)

ToggleButton.Position = UDim2.new(1,-90,0,20)

ToggleButton.BackgroundTransparency = 1

ToggleButton.Image = "rbxassetid://95003172478442"

ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")

ToggleCorner.CornerRadius = UDim.new(1,0)

ToggleCorner.Parent = ToggleButton

makeMobileDraggable(ToggleButton)

local Main = Instance.new("Frame")

Main.Size = UDim2.new(0, 260, 0, 310)

Main.Position = UDim2.new(0.5, -130, 0.5, -155)

Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

Main.BorderSizePixel = 0

Main.Visible = false

Main.Parent = ScreenGui

makeMobileDraggable(Main)

local UICorner = Instance.new("UICorner")

UICorner.CornerRadius = UDim.new(0, 12)

UICorner.Parent = Main

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, 0, 0, 40)

Title.BackgroundTransparency = 1

Title.Text = "Zeros Brainrot Spawner"

Title.TextColor3 = Color3.fromRGB(255, 255, 255)

Title.Font = Enum.Font.GothamBold

Title.TextSize = 20

Title.Parent = Main

local function makeBox(placeholder, y)

    local box = Instance.new("TextBox")

    box.Size = UDim2.new(1, -30, 0, 35)

    box.Position = UDim2.new(0, 15, 0, y)

    box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)

    box.TextColor3 = Color3.fromRGB(255, 255, 255)

    box.PlaceholderText = placeholder

    box.Text = ""

    box.Font = Enum.Font.Gotham

    box.ClearTextOnFocus = true

    box.TextSize = 16

    box.Parent = Main

    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    return box

end

local BrainrotBox = makeBox("Brainrot", 50)

local MutationBox = makeBox("Mutation", 95)

local TraitBox = makeBox("Trait", 140)

local LoopBtn = Instance.new("TextButton")

LoopBtn.Size = UDim2.new(1, -30, 0, 40)

LoopBtn.Position = UDim2.new(0, 15, 0, 185)

LoopBtn.BackgroundColor3 = Color3.fromRGB(70, 170, 255)

LoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

LoopBtn.Font = Enum.Font.GothamBold

LoopBtn.TextSize = 18

LoopBtn.Text = "Looped: Off"

LoopBtn.Parent = Main

Instance.new("UICorner", LoopBtn).CornerRadius = UDim.new(0, 10)

local SpawnBtn = Instance.new("TextButton")

SpawnBtn.Size = UDim2.new(1, -30, 0, 40)

SpawnBtn.Position = UDim2.new(0, 15, 0, 235)

SpawnBtn.BackgroundColor3 = Color3.fromRGB(90, 200, 90)

SpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

SpawnBtn.Font = Enum.Font.GothamBold

SpawnBtn.TextSize = 18

SpawnBtn.Text = "Spawn"

SpawnBtn.Parent = Main

Instance.new("UICorner", SpawnBtn).CornerRadius = UDim.new(0, 10)

local looped = false

local function getBoxText(box)

    return box.Text ~= "" and box.Text or ""

end

local function spawnBrainrot()

    local brainrotName = getBoxText(BrainrotBox)

    local mutation = getBoxText(MutationBox)

    local trait = getBoxText(TraitBox)

    rfBrainrot:InvokeServer(brainrotName, mutation, trait)

    if brainrotName == "Meowl" then

        task.wait(1.6)

        rfStartEvent:InvokeServer("Meowl")

    elseif brainrotName == "Strawberry Elephant" then

        task.wait(2.4)

        rfStartEvent:InvokeServer("Strawberry")

    end

end

LoopBtn.MouseButton1Click:Connect(function()

    looped = not looped

    LoopBtn.Text = looped and "Looped: On" or "Looped: Off"

    if looped then

        task.spawn(function()

            while looped do

                spawnBrainrot()

                task.wait(spawnDelay)

            end

        end)

    end

end)

SpawnBtn.MouseButton1Click:Connect(spawnBrainrot)

ToggleButton.MouseButton1Click:Connect(function()

    ToggleButton:TweenSize(

        UDim2.new(0,60,0,60),

        Enum.EasingDirection.Out,

        Enum.EasingStyle.Quad,

        0.08,

        true,

        function()

            ToggleButton:TweenSize(

                UDim2.new(0,70,0,70),

                Enum.EasingDirection.Out,

                Enum.EasingStyle.Quad,

                0.08,

                true

            )

        end

    )

    Main.Visible = not Main.Visible

end)
