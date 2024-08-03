-- Ensure the script runs only on the client
if not game:GetService("RunService"):IsClient() then
    return
end

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Function to create draggable frames
local function createDraggableFrame(parent, size, position, backgroundColor, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = backgroundColor
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerRadius
    corner.Parent = frame
    
    return frame
end

-- Create main GUI frame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerTrackerGui"
screenGui.Parent = playerGui

local mainFrame = createDraggableFrame(screenGui, UDim2.new(0.3, 0, 0.5, 0), UDim2.new(0.35, 0, 0.25, 0), Color3.fromRGB(0, 0, 0), UDim.new(0, 10))

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Select a player to track"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0.7, 0)
scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = mainFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Parent = scrollFrame

local backButton = Instance.new("TextButton")
backButton.Size = UDim2.new(0.3, 0, 0.1, 0)
backButton.Position = UDim2.new(0.1, 0, 0.85, 0)
backButton.Text = "Back"
backButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
backButton.BorderSizePixel = 0
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.Font = Enum.Font.SourceSansBold
backButton.TextScaled = true
backButton.Parent = mainFrame

local cornerBackButton = Instance.new("UICorner")
cornerBackButton.CornerRadius = UDim.new(0, 10)
cornerBackButton.Parent = backButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
closeButton.Position = UDim2.new(0.9, 0, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextScaled = true
closeButton.Parent = mainFrame

local cornerCloseButton = Instance.new("UICorner")
cornerCloseButton.CornerRadius = UDim.new(0, 10)
cornerCloseButton.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

backButton.MouseButton1Click:Connect(function()
    camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or nil
    camera.CameraType = Enum.CameraType.Custom
end)

local currentTargetPlayer = nil

local function setCameraToFreeView(targetPlayer)
    currentTargetPlayer = targetPlayer
    local humanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        camera.CameraSubject = humanoid
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- Update player list
local function updatePlayerList()
    -- Clear previous list
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Create new buttons for each player
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, 0, 0.07, 0)
            playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            playerButton.BorderSizePixel = 0
            playerButton.Text = p.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Font = Enum.Font.SourceSansBold
            playerButton.TextScaled = true
            playerButton.TextWrapped = true
            playerButton.TextTruncate = Enum.TextTruncate.AtEnd
            playerButton.Parent = scrollFrame

            local cornerPlayerButton = Instance.new("UICorner")
            cornerPlayerButton.CornerRadius = UDim.new(0, 10)
            cornerPlayerButton.Parent = playerButton

            playerButton.MouseButton1Click:Connect(function()
                -- Start tracking the player
                print("Tracking player: " .. p.Name)
                setCameraToFreeView(p)
            end)
        end
    end

    -- Update CanvasSize for scrolling
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0.07 * (#game.Players:GetPlayers() - 1), 0)
end

-- Update player list on start
updatePlayerList()

-- Update player list when players are added or removed
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(function(leavingPlayer)
    updatePlayerList()
    if currentTargetPlayer == leavingPlayer then
        -- Reset camera to the player if the tracked player leaves
        camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or nil
        camera.CameraType = Enum.CameraType.Custom
        currentTargetPlayer = nil
    end
end)
