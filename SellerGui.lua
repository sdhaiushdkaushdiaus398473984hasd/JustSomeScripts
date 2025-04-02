local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Function to send chat commands
local function sendCommand(command)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/" .. command, "All")
end

-- Variables to track state
local isMinimized = false
local droppingStatus = false
local undergroundStatus = false
local activeDropdowns = {}
local activeTab = 1

-- Animation configurations
local animationSpeed = 0.3
local animationStyle = Enum.EasingStyle.Quad
local animationDirection = Enum.EasingDirection.Out

-- UI Colors
local colors = {
    background = Color3.fromRGB(20, 20, 30),
    titleBar = Color3.fromRGB(30, 30, 45),
    button = Color3.fromRGB(40, 80, 170),
    buttonHover = Color3.fromRGB(60, 100, 200),
    secondaryButton = Color3.fromRGB(40, 50, 80),
    dropdown = Color3.fromRGB(30, 35, 60),
    tabActive = Color3.fromRGB(40, 80, 170),
    tabInactive = Color3.fromRGB(30, 40, 70),
    text = Color3.fromRGB(230, 230, 230),
    subtext = Color3.fromRGB(180, 180, 180),
    statusSuccess = Color3.fromRGB(80, 200, 120),
    statusWarning = Color3.fromRGB(230, 180, 40),
    statusInfo = Color3.fromRGB(80, 130, 255)
}

-- Create ScreenGui
local controllerUI = Instance.new("ScreenGui")
controllerUI.Name = "DropperControllerUI"
controllerUI.ResetOnSpawn = false
controllerUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
controllerUI.Parent = player.PlayerGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = controllerUI

-- Add rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Create title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = colors.titleBar
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Add rounded corners to top of title bar
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -90, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Dropper Controller"
titleText.TextColor3 = colors.text
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -40, 0, 2)
closeButton.BackgroundTransparency = 1
closeButton.Text = "✕"
closeButton.TextColor3 = colors.text
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 36, 0, 36)
minimizeButton.Position = UDim2.new(1, -76, 0, 2)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Text = "—"
minimizeButton.TextColor3 = colors.text
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = titleBar

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundColor3 = colors.background
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Create tabs container
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 0, 40)
tabsContainer.Position = UDim2.new(0, 0, 0, 0)
tabsContainer.BackgroundColor3 = colors.titleBar
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = contentFrame

-- Create tab buttons
local tabs = {
    {name = "Money", icon = ""},
    {name = "Movement", icon = ""},
    {name = "System", icon = ""}
}

local tabButtons = {}
local tabWidth = 1 / #tabs

for i, tab in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tab.name .. "Tab"
    tabButton.Size = UDim2.new(tabWidth, 0, 1, 0)
    tabButton.Position = UDim2.new(tabWidth * (i-1), 0, 0, 0)
    tabButton.BackgroundColor3 = i == 1 and colors.tabActive or colors.tabInactive
    tabButton.Text = tab.name
    tabButton.TextColor3 = colors.text
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabsContainer
    
    tabButtons[i] = tabButton
end

-- Create tab content frames
local tabContents = {}

for i, tab in ipairs(tabs) do
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = tab.name .. "Content"
    tabContent.Size = UDim2.new(1, -20, 1, -100)
    tabContent.Position = UDim2.new(0, 10, 0, 50)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = i == 1
    tabContent.Parent = contentFrame
    
    tabContents[i] = tabContent
end

-- Create a status indicator
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(1, -20, 0, 36)
statusFrame.Position = UDim2.new(0, 10, 1, -45)
statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = contentFrame

-- Status rounded corners
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = colors.statusSuccess
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextTransparency = 0
statusLabel.Parent = statusFrame

-- Function to update status
local function updateStatus(status, color)
    statusLabel.Text = "Status: " .. status
    statusLabel.TextColor3 = color or colors.statusSuccess
end

-- Function to close all open dropdowns
local function closeAllDropdowns()
    for _, dropdown in pairs(activeDropdowns) do
        if dropdown.Visible then
            local closeTween = TweenService:Create(
                dropdown, 
                TweenInfo.new(animationSpeed, animationStyle, animationDirection),
                {Position = UDim2.new(1, 10, 0, dropdown.Position.Y.Offset)}
            )
            
            closeTween:Play()
            closeTween.Completed:Connect(function()
                dropdown.Visible = false
            end)
        end
    end
    
    -- Clear the active dropdowns table
    activeDropdowns = {}
end

-- Animation functions
local function minimizeUI()
    if isMinimized then return end
    
    local minimizeTween = TweenService:Create(
        contentFrame, 
        TweenInfo.new(animationSpeed, animationStyle, animationDirection),
        {Size = UDim2.new(1, 0, 0, 0)}
    )
    
    minimizeTween:Play()
    isMinimized = true
    minimizeButton.Text = "+"
end

local function maximizeUI()
    if not isMinimized then return end
    
    local maximizeTween = TweenService:Create(
        contentFrame, 
        TweenInfo.new(animationSpeed, animationStyle, animationDirection),
        {Size = UDim2.new(1, 0, 1, -40)}
    )
    
    maximizeTween:Play()
    isMinimized = false
    minimizeButton.Text = "—"
end

-- Tab switching functionality
for i, button in ipairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        -- Update tab appearance
        for j, otherButton in ipairs(tabButtons) do
            otherButton.BackgroundColor3 = j == i and colors.tabActive or colors.tabInactive
        end
        
        -- Show selected tab content
        for j, content in ipairs(tabContents) do
            content.Visible = j == i
        end
        
        activeTab = i
        closeAllDropdowns()
    end)
end

-- Button functionality
minimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        maximizeUI()
    else
        minimizeUI()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    controllerUI.Enabled = false
end)

-- Toggle key functionality
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Home then
        controllerUI.Enabled = not controllerUI.Enabled
    end
end)

-- Function to create a side dropdown menu with animation
local function createSideDropdown(parent, options, callback, button)
    local dropdownHeight = #options * 36 + 30 -- Extra height for the X button
    
    -- Check if a dropdown with the same name already exists and remove it
    local existingDropdown = parent:FindFirstChild("SideDropdown_" .. button.Name)
    if existingDropdown then
        existingDropdown:Destroy()
    end
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = "SideDropdown_" .. button.Name
    dropdown.Size = UDim2.new(0, 150, 0, dropdownHeight)
    dropdown.Position = UDim2.new(1, 10, 0, 0) -- Initial position off-screen
    dropdown.BackgroundColor3 = colors.dropdown
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
    dropdown.Parent = parent
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    -- Close button for dropdown
    local dropdownClose = Instance.new("TextButton")
    dropdownClose.Name = "CloseButton"
    dropdownClose.Size = UDim2.new(0, 30, 0, 30)
    dropdownClose.Position = UDim2.new(1, -30, 0, 0)
    dropdownClose.BackgroundTransparency = 1
    dropdownClose.Text = "✕"
    dropdownClose.TextColor3 = colors.text
    dropdownClose.TextSize = 14
    dropdownClose.Font = Enum.Font.GothamBold
    dropdownClose.ZIndex = 11
    dropdownClose.Parent = dropdown
    
    -- Add dropdown label
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "DropdownLabel"
    dropdownLabel.Size = UDim2.new(1, -35, 0, 30)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = "Select Option"
    dropdownLabel.TextColor3 = colors.text
    dropdownLabel.TextSize = 14
    dropdownLabel.Font = Enum.Font.GothamSemibold
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.ZIndex = 11
    dropdownLabel.Parent = dropdown
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option.name .. "Button"
        optionButton.Size = UDim2.new(1, -20, 0, 30)
        optionButton.Position = UDim2.new(0, 10, 0, 30 + (i-1) * 36)
        optionButton.BackgroundColor3 = colors.secondaryButton
        optionButton.BackgroundTransparency = 0.2
        optionButton.Text = option.label or option.name
        optionButton.TextColor3 = colors.text
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.GothamSemibold
        optionButton.ZIndex = 11
        optionButton.Parent = dropdown
        
        -- Add rounded corners to buttons
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = optionButton
        
        -- Add hover effect
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 0.2
        end)
        
        -- Option click handler
        optionButton.MouseButton1Click:Connect(function()
            callback(option)
            
            -- Close with animation
            local closeTween = TweenService:Create(
                dropdown, 
                TweenInfo.new(animationSpeed, animationStyle, animationDirection),
                {Position = UDim2.new(1, 10, 0, dropdown.Position.Y.Offset)}
            )
            
            closeTween:Play()
            closeTween.Completed:Connect(function()
                dropdown.Visible = false
                table.remove(activeDropdowns, table.find(activeDropdowns, dropdown))
            end)
        end)
    end
    
    -- Close button functionality
    dropdownClose.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(
            dropdown, 
            TweenInfo.new(animationSpeed, animationStyle, animationDirection),
            {Position = UDim2.new(1, 10, 0, dropdown.Position.Y.Offset)}
        )
        
        closeTween:Play()
        closeTween.Completed:Connect(function()
            dropdown.Visible = false
            table.remove(activeDropdowns, table.find(activeDropdowns, dropdown))
        end)
    end)
    
    return dropdown
end

-- Command sections organized by tabs
local commandSections = {
    -- Tab 1: Money Actions
    {
        name = "Money Actions",
        tabIndex = 1,
        commands = {
            {
                name = "Drop Money",
                command = "drop",
                description = "Start dropping money",
                statusUpdate = "Dropping Money...",
                statusColor = colors.statusWarning
            },
            {
                name = "Stop Dropping",
                command = "stop",
                description = "Stop dropping money",
                statusUpdate = "Stopped Dropping",
                statusColor = colors.statusSuccess
            },
            {
                name = "Custom Drop",
                command = "cdrop",
                description = "Drop specific amount",
                hasInput = true,
                placeholder = "Amount (e.g. 10k, 5m)",
                statusUpdate = "Custom Dropping",
                statusColor = colors.statusWarning
            },
            {
                name = "Toggle Wallet",
                command = "wallet",
                description = "Toggle wallet equipped",
                statusUpdate = "Wallet Toggled",
                statusColor = colors.statusInfo
            },
            {
                name = "Money Stats",
                command = "dropped",
                description = "Show money on ground",
                statusUpdate = "Showing Money Stats",
                statusColor = colors.statusInfo
            }
        }
    },
    -- Tab 2: Movement & Positioning
    {
        name = "Movement Actions",
        tabIndex = 2,
        commands = {
            {
                name = "Underground",
                command = "ground",
                description = "Go under ground",
                statusUpdate = "Going Underground",
                statusColor = colors.statusInfo
            },
            {
                name = "Float",
                command = "float",
                description = "Toggle float/airwalk",
                statusUpdate = "Toggled Float",
                statusColor = colors.statusInfo
            },
            {
                name = "Setup Location",
                command = "setup",
                description = "Go to a specific location",
                hasDropdown = true,
                dropdownOptions = {
                    {name = "bank", label = "Bank"},
                    {name = "club", label = "Club"},
                    {name = "train", label = "Train"}
                },
                statusUpdate = "Setting up location",
                statusColor = colors.statusInfo
            },
            {
                name = "Go To Spot",
                command = "spot",
                description = "Go to controller's spot",
                statusUpdate = "Going to Spot",
                statusColor = colors.statusInfo
            },
            {
                name = "Bring Alts",
                command = "bring",
                description = "Bring alts to controller",
                statusUpdate = "Bringing Alts",
                statusColor = colors.statusInfo
            }
        }
    },
    -- Tab 3: System Settings
    {
        name = "System Settings",
        tabIndex = 3,
        commands = {
            {
                name = "Reset Character",
                command = "reset",
                description = "Reset character",
                statusUpdate = "Character Reset",
                statusColor = Color3.fromRGB(230, 100, 100)
            },
            {
                name = "Rejoin Server",
                command = "rejoin",
                description = "Rejoin the server",
                statusUpdate = "Rejoining Server...",
                statusColor = Color3.fromRGB(230, 100, 100)
            },
            {
                name = "Chat Messages",
                command = "chats",
                description = "Enable/disable messages",
                hasDropdown = true,
                dropdownOptions = {
                    {name = "on", label = "Enable"},
                    {name = "off", label = "Disable"}
                },
                statusUpdate = "Chat Setting Updated",
                statusColor = colors.statusInfo
            },
            {
                name = "FPS Limit",
                command = "fps",
                description = "Set FPS limit",
                hasInput = true,
                placeholder = "FPS value (e.g. 30)",
                statusUpdate = "FPS Limit Set",
                statusColor = colors.statusInfo
            },
            {
                name = "Say Message",
                command = "say",
                description = "Send a chat message",
                hasInput = true,
                placeholder = "Message to say",
                statusUpdate = "Message Sent",
                statusColor = colors.statusInfo
            }
        }
    }
}

-- Function to create button with hover effect
local function createButton(parent, data, yPos)
    local buttonHeight = data.hasInput and 80 or 55
    
    -- Button container
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = data.name .. "Frame"
    buttonFrame.Size = UDim2.new(1, -10, 0, buttonHeight)
    buttonFrame.Position = UDim2.new(0, 5, 0, yPos)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = parent
    
    -- Add tooltip above button with fixed height
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(1, -10, 0, 20)
    tooltip.Position = UDim2.new(0, 5, 0, 0)
    tooltip.BackgroundTransparency = 1
    tooltip.Text = data.description
    tooltip.TextColor3 = colors.subtext
    tooltip.TextSize = 12
    tooltip.Font = Enum.Font.GothamMedium
    tooltip.TextXAlignment = Enum.TextXAlignment.Left
    tooltip.TextWrapped = true
    tooltip.TextYAlignment = Enum.TextYAlignment.Center
    tooltip.Parent = buttonFrame
    
    -- Create button
    local button = Instance.new("TextButton")
    button.Name = data.name .. "Button"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Position = UDim2.new(0, 0, 0, 20)
    button.BackgroundColor3 = colors.button
    button.Text = data.name
    button.TextColor3 = colors.text
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.Parent = buttonFrame
    
    -- Add rounded corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = colors.buttonHover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = colors.button
    end)
    
    -- If command requires input
    if data.hasInput then
        local inputBox = Instance.new("TextBox")
        inputBox.Name = "InputBox"
        inputBox.Size = UDim2.new(1, 0, 0, 30)
        inputBox.Position = UDim2.new(0, 0, 0, 57)
        inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        inputBox.Text = ""
        inputBox.PlaceholderText = data.placeholder or "Input value..."
        inputBox.TextColor3 = colors.text
        inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
        inputBox.TextSize = 14
        inputBox.Font = Enum.Font.GothamMedium
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = buttonFrame
        
        -- Add rounded corners to input
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputBox
        
        -- Button functionality with input
        button.MouseButton1Click:Connect(function()
            local inputValue = inputBox.Text
            if inputValue and inputValue ~= "" then
                sendCommand(data.command .. " " .. inputValue)
            else
                sendCommand(data.command)
            end
            
            -- Update status
            if data.statusUpdate then
                updateStatus(data.statusUpdate, data.statusColor)
            end
        end)
    elseif data.hasDropdown then
        -- Create side dropdown menu
        local dropdownMenu = createSideDropdown(
            mainFrame, -- Changed from contentFrame to mainFrame for better positioning
            data.dropdownOptions,
            function(option)
                sendCommand(data.command .. " " .. option.name)
                updateStatus(data.statusUpdate .. ": " .. option.label, data.statusColor)
            end,
            button
        )
        
        -- Button click to show dropdown with animation
        button.MouseButton1Click:Connect(function()
            closeAllDropdowns() -- Close any open dropdowns
            
            -- Calculate proper position relative to the main frame
            local buttonAbsPos = button.AbsolutePosition
            local mainFrameAbsPos = mainFrame.AbsolutePosition
            local yOffset = buttonAbsPos.Y - mainFrameAbsPos.Y
            
            -- Update position
            dropdownMenu.Position = UDim2.new(1, 10, 0, yOffset)
            dropdownMenu.Visible = true
            
            -- Add to active dropdowns table
            table.insert(activeDropdowns, dropdownMenu)
            
            -- Animate dropdown opening
            local openTween = TweenService:Create(
                dropdownMenu, 
                TweenInfo.new(animationSpeed, animationStyle, animationDirection),
                {Position = UDim2.new(1, -160, 0, yOffset)}
            )
            
            openTween:Play()
        end)
    else
        -- Standard button functionality
        button.MouseButton1Click:Connect(function()
            sendCommand(data.command)
            
            -- Update status
            if data.statusUpdate then
                updateStatus(data.statusUpdate, data.statusColor)
            end
            
            -- For specific commands, update tracking variables
            if data.command == "drop" then
                droppingStatus = true
            elseif data.command == "stop" then
                droppingStatus = false
            elseif data.command == "ground" then
                undergroundStatus = not undergroundStatus
            end
        end)
    end
    
    return buttonHeight + 5 -- Return height including gap
end

-- Function to create UI elements
local function createCommandUI()
    -- Create commands for each tab
    for _, section in ipairs(commandSections) do
        local targetTab = tabContents[section.tabIndex]
        local yOffset = 10
        
        -- Command buttons
        for _, cmd in ipairs(section.commands) do
            local buttonHeight = createButton(targetTab, cmd, yOffset)
            yOffset = yOffset + buttonHeight
        end
    end
end

-- Create the UI elements
createCommandUI()

-- Handle clicks outside dropdowns to close them
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        
        -- Check if click is outside dropdowns
        for _, dropdown in pairs(activeDropdowns) do
            if dropdown and dropdown.Visible then
                local dropdownPos = dropdown.AbsolutePosition
                local dropdownSize = dropdown.AbsoluteSize
                
                if not (mousePos.X >= dropdownPos.X and 
                       mousePos.X <= dropdownPos.X + dropdownSize.X and
                       mousePos.Y >= dropdownPos.Y and
                       mousePos.Y <= dropdownPos.Y + dropdownSize.Y) then
                    
                    local closeTween = TweenService:Create(
                        dropdown, 
                        TweenInfo.new(animationSpeed, animationStyle, animationDirection),
                        {Position = UDim2.new(1, 10, 0, dropdown.Position.Y.Offset)}
                    )
                    
                    closeTween:Play()
                    closeTween.Completed:Connect(function()
                        dropdown.Visible = false
                        table.remove(activeDropdowns, table.find(activeDropdowns, dropdown))
                    end)
                end
            end
        end
    end
end)

-- Periodic status updates
spawn(function()
    while wait(1) do
        if droppingStatus then
            updateStatus("Dropping Money...", colors.statusWarning)
        elseif undergroundStatus then
            updateStatus("Underground", colors.statusInfo)
        end
    end
end)

-- Notify that UI is loaded
game.StarterGui:SetCore("SendNotification", {
    Title = "Dropper Controller";
    Text = "Loaded! Press Home to toggle UI.";
    Duration = 5;
})

print("Redesigned Dropper Controller UI loaded!")
