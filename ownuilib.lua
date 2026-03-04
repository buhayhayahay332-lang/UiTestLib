

local UILib = {}
UILib.__index = UILib
UILib.Version = "1.0.0"


-- SERVICES

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")


-- THEME/COLORS

local Theme = {
    -- Background colors
    Background = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(35, 35, 40),
    Tertiary = Color3.fromRGB(45, 45, 50),
    
    -- Accent colors
    Accent = Color3.fromRGB(88, 101, 242),  -- Discord blurple
    AccentHover = Color3.fromRGB(108, 121, 255),
    AccentActive = Color3.fromRGB(68, 81, 222),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(100, 100, 100),
    
    -- Status colors
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(240, 71, 71),
    
    -- Border
    Border = Color3.fromRGB(60, 60, 65),
    
    -- Transparency
    Transparency = {
        Full = 0,
        High = 0.1,
        Medium = 0.3,
        Low = 0.7
    }
}


-- UTILITY FUNCTIONS

local function Tween(object, properties, duration, style, direction)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function RippleEffect(button, clickPosition)
    local ripple = Instance.new("ImageLabel")
    ripple.Name = "Ripple"
    ripple.BackgroundTransparency = 1
    ripple.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ripple.ImageTransparency = 0.5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        ImageTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end


-- CREATE MAIN LIBRARY

function UILib:New(config)
    config = config or {}
    
    local Library = {
        Name = config.Name or "UI Library",
        Theme = config.Theme or Theme,
        Windows = {},
        Flags = {},
        ConfigFolder = config.ConfigFolder or "UILibConfigs"
    }
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILib_" .. Library.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    Library.ScreenGui = ScreenGui
    
    setmetatable(Library, UILib)
    return Library
end


-- CREATE WINDOW

function UILib:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Name = config.Name or "Window",
        Size = config.Size or UDim2.new(0, 550, 0, 600),
        Position = config.Position or UDim2.new(0.5, -275, 0.5, -300),
        Tabs = {},
        CurrentTab = nil,
        Library = self
    }
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Window.Size
    MainFrame.Position = Window.Position
    MainFrame.BackgroundColor3 = self.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = self.ScreenGui
    
    -- UICorner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = self.Theme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    -- Title fix (remove bottom corners)
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 10)
    TitleFix.Position = UDim2.new(0, 0, 1, -10)
    TitleFix.BackgroundColor3 = self.Theme.Secondary
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Window.Name
    TitleLabel.TextColor3 = self.Theme.TextPrimary
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = self.Theme.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "×"
    CloseButton.TextColor3 = self.Theme.TextPrimary
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 91, 91)})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = self.Theme.Error})
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -175, 1, -50)
    ContentContainer.Position = UDim2.new(0, 165, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentContainer = ContentContainer
    
    -- Make draggable
    MakeDraggable(MainFrame, TitleBar)
    
    table.insert(self.Windows, Window)
    
    setmetatable(Window, {__index = self})
    return Window
end


-- CREATE TAB

function UILib:CreateTab(config)
    config = config or {}
    
    local Tab = {
        Name = config.Name or "Tab",
        Icon = config.Icon,
        Window = self,
        Elements = {}
    }
    
    -- Tab Button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = Tab.Name
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = self.Library.Theme.Tertiary
    TabButton.BorderSizePixel = 0
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    -- Tab Label
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Size = UDim2.new(1, -10, 1, 0)
    TabLabel.Position = UDim2.new(0, 10, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = Tab.Name
    TabLabel.TextColor3 = self.Library.Theme.TextSecondary
    TabLabel.TextSize = 14
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.Parent = TabButton
    
    -- Tab Content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = Tab.Name .. "_Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = self.Library.Theme.Accent
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = TabContent
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 5)
    ContentPadding.PaddingRight = UDim.new(0, 5)
    ContentPadding.PaddingTop = UDim.new(0, 5)
    ContentPadding.PaddingBottom = UDim.new(0, 5)
    ContentPadding.Parent = TabContent
    
    -- Auto-resize canvas
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab click
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = self.Library.Theme.Tertiary
            tab.Label.TextColor3 = self.Library.Theme.TextSecondary
            tab.Content.Visible = false
        end
        
        TabButton.BackgroundColor3 = self.Library.Theme.Accent
        TabLabel.TextColor3 = self.Library.Theme.TextPrimary
        TabContent.Visible = true
        self.CurrentTab = Tab
    end)
    
    -- Hover effects
    TabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= Tab then
            Tween(TabButton, {BackgroundColor3 = self.Library.Theme.Secondary})
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= Tab then
            Tween(TabButton, {BackgroundColor3 = self.Library.Theme.Tertiary})
        end
    end)
    
    Tab.Button = TabButton
    Tab.Label = TabLabel
    Tab.Content = TabContent
    Tab.ContentList = ContentList
    
    table.insert(self.Tabs, Tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        TabButton.BackgroundColor3 = self.Library.Theme.Accent
        TabLabel.TextColor3 = self.Library.Theme.TextPrimary
        TabContent.Visible = true
        self.CurrentTab = Tab
    end
    
    setmetatable(Tab, {__index = self})
    return Tab
end


-- CREATE BUTTON

function UILib:CreateButton(config)
    config = config or {}
    
    local Button = Instance.new("TextButton")
    Button.Name = config.Name or "Button"
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = self.Window.Library.Theme.Accent
    Button.BorderSizePixel = 0
    Button.Text = config.Text or config.Name or "Button"
    Button.TextColor3 = self.Window.Library.Theme.TextPrimary
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    Button.Parent = self.Content
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    -- Click handler
    Button.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        local relativePos = mouse - Button.AbsolutePosition
        RippleEffect(Button, relativePos)
        
        if config.Callback then
            config.Callback()
        end
    end)
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        Tween(Button, {BackgroundColor3 = self.Window.Library.Theme.AccentHover})
    end)
    
    Button.MouseLeave:Connect(function()
        Tween(Button, {BackgroundColor3 = self.Window.Library.Theme.Accent})
    end)
    
    Button.MouseButton1Down:Connect(function()
        Tween(Button, {BackgroundColor3 = self.Window.Library.Theme.AccentActive})
    end)
    
    Button.MouseButton1Up:Connect(function()
        Tween(Button, {BackgroundColor3 = self.Window.Library.Theme.AccentHover})
    end)
    
    return Button
end


-- CREATE TOGGLE

function UILib:CreateToggle(config)
    config = config or {}
    
    local Toggle = {
        State = config.Default or false,
        Flag = config.Flag
    }
    
    local Container = Instance.new("Frame")
    Container.Name = config.Name or "Toggle"
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = self.Window.Library.Theme.Secondary
    Container.BorderSizePixel = 0
    Container.Parent = self.Content
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Toggle"
    Label.TextColor3 = self.Window.Library.Theme.TextPrimary
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    -- Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = self.Window.Library.Theme.Tertiary
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    -- Toggle Circle
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = self.Window.Library.Theme.TextPrimary
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local function SetState(state)
        Toggle.State = state
        
        if state then
            Tween(ToggleButton, {BackgroundColor3 = self.Window.Library.Theme.Accent})
            Tween(Circle, {Position = UDim2.new(1, -18, 0.5, -8)})
        else
            Tween(ToggleButton, {BackgroundColor3 = self.Window.Library.Theme.Tertiary})
            Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -8)})
        end
        
        if config.Callback then
            config.Callback(state)
        end
        
        if Toggle.Flag then
            self.Window.Library.Flags[Toggle.Flag] = state
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        SetState(not Toggle.State)
    end)
    
    -- Set initial state
    SetState(Toggle.State)
    
    Toggle.SetState = SetState
    return Toggle
end

-- Continue in next message...
-- ============================================================
-- MODERN LUAU GUI LIBRARY - PART 2
-- Additional UI Elements
-- ============================================================


-- CREATE SLIDER

function UILib:CreateSlider(config)
    config = config or {}
    
    local Slider = {
        Min = config.Min or 0,
        Max = config.Max or 100,
        Default = config.Default or 50,
        Increment = config.Increment or 1,
        Flag = config.Flag,
        Value = config.Default or 50
    }
    
    local Container = Instance.new("Frame")
    Container.Name = config.Name or "Slider"
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundColor3 = self.Window.Library.Theme.Secondary
    Container.BorderSizePixel = 0
    Container.Parent = self.Content
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Slider"
    Label.TextColor3 = self.Window.Library.Theme.TextPrimary
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    -- Value Label
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Slider.Value)
    ValueLabel.TextColor3 = self.Window.Library.Theme.Accent
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container
    
    -- Slider Background
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 6)
    SliderBG.Position = UDim2.new(0, 10, 1, -15)
    SliderBG.BackgroundColor3 = self.Window.Library.Theme.Tertiary
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Container
    
    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(1, 0)
    SliderBGCorner.Parent = SliderBG
    
    -- Slider Fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = self.Window.Library.Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    -- Slider Button
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new(0, -8, 0.5, -8)
    SliderButton.BackgroundColor3 = self.Window.Library.Theme.TextPrimary
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.AutoButtonColor = false
    SliderButton.Parent = SliderFill
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    local function SetValue(value)
        value = math.clamp(value, Slider.Min, Slider.Max)
        value = math.floor((value - Slider.Min) / Slider.Increment + 0.5) * Slider.Increment + Slider.Min
        Slider.Value = value
        
        local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
        
        Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
        ValueLabel.Text = tostring(value)
        
        if config.Callback then
            config.Callback(value)
        end
        
        if Slider.Flag then
            self.Window.Library.Flags[Slider.Flag] = value
        end
    end
    
    local dragging = false
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBG.AbsolutePosition.X
            local sliderSize = SliderBG.AbsoluteSize.X
            local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
            SetValue(value)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SliderBG.AbsolutePosition.X
            local sliderSize = SliderBG.AbsoluteSize.X
            local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
            SetValue(value)
        end
    end)
    
    SetValue(Slider.Default)
    
    Slider.SetValue = SetValue
    return Slider
end


-- CREATE DROPDOWN

function UILib:CreateDropdown(config)
    config = config or {}
    
    local Dropdown = {
        Options = config.Options or {},
        Default = config.Default,
        Flag = config.Flag,
        Value = config.Default,
        Open = false
    }
    
    local Container = Instance.new("Frame")
    Container.Name = config.Name or "Dropdown"
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = self.Window.Library.Theme.Secondary
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = false
    Container.ZIndex = 10
    Container.Parent = self.Content
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    -- Dropdown Button
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 35)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.Parent = Container
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Dropdown.Value or config.Name or "Select..."
    Label.TextColor3 = self.Window.Library.Theme.TextPrimary
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownButton
    
    -- Arrow
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -25, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = self.Window.Library.Theme.TextSecondary
    Arrow.TextSize = 12
    Arrow.Font = Enum.Font.Gotham
    Arrow.Parent = DropdownButton
    
    -- Options Container
    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionsContainer.Position = UDim2.new(0, 0, 1, 5)
    OptionsContainer.BackgroundColor3 = self.Window.Library.Theme.Tertiary
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.ClipsDescendants = true
    OptionsContainer.Visible = false
    OptionsContainer.ZIndex = 11
    OptionsContainer.Parent = Container
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = OptionsContainer
    
    local OptionsList = Instance.new("UIListLayout")
    OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsList.Padding = UDim.new(0, 2)
    OptionsList.Parent = OptionsContainer
    
    local function SetValue(value)
        Dropdown.Value = value
        Label.Text = value
        
        if config.Callback then
            config.Callback(value)
        end
        
        if Dropdown.Flag then
            self.Window.Library.Flags[Dropdown.Flag] = value
        end
    end
    
    local function Toggle()
        Dropdown.Open = not Dropdown.Open
        
        if Dropdown.Open then
            OptionsContainer.Visible = true
            local targetSize = math.min(#Dropdown.Options * 32 + 4, 200)
            Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2)
            Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Tween(OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Tween(Arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                OptionsContainer.Visible = false
            end)
        end
    end
    
    DropdownButton.MouseButton1Click:Connect(Toggle)
    
    -- Create options
    for _, option in ipairs(Dropdown.Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -4, 0, 30)
        OptionButton.BackgroundColor3 = self.Window.Library.Theme.Tertiary
        OptionButton.BorderSizePixel = 0
        OptionButton.Text = option
        OptionButton.TextColor3 = self.Window.Library.Theme.TextPrimary
        OptionButton.TextSize = 13
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = 12
        OptionButton.Parent = OptionsContainer
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 4)
        OptionCorner.Parent = OptionButton
        
        OptionButton.MouseButton1Click:Connect(function()
            SetValue(option)
            Toggle()
        end)
        
        OptionButton.MouseEnter:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = self.Window.Library.Theme.Accent})
        end)
        
        OptionButton.MouseLeave:Connect(function()
            Tween(OptionButton, {BackgroundColor3 = self.Window.Library.Theme.Tertiary})
        end)
    end
    
    if Dropdown.Default then
        SetValue(Dropdown.Default)
    end
    
    Dropdown.SetValue = SetValue
    return Dropdown
end


-- CREATE TEXTBOX

function UILib:CreateTextBox(config)
    config = config or {}
    
    local TextBox = {
        Flag = config.Flag,
        Value = config.Default or ""
    }
    
    local Container = Instance.new("Frame")
    Container.Name = config.Name or "TextBox"
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = self.Window.Library.Theme.Secondary
    Container.BorderSizePixel = 0
    Container.Parent = self.Content
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container
    
    -- TextBox
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -20, 1, 0)
    Input.Position = UDim2.new(0, 10, 0, 0)
    Input.BackgroundTransparency = 1
    Input.PlaceholderText = config.Placeholder or "Enter text..."
    Input.Text = config.Default or ""
    Input.TextColor3 = self.Window.Library.Theme.TextPrimary
    Input.PlaceholderColor3 = self.Window.Library.Theme.TextSecondary
    Input.TextSize = 14
    Input.Font = Enum.Font.Gotham
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.ClearTextOnFocus = false
    Input.Parent = Container
    
    Input.FocusLost:Connect(function(enterPressed)
        TextBox.Value = Input.Text
        
        if config.Callback then
            config.Callback(Input.Text)
        end
        
        if TextBox.Flag then
            self.Window.Library.Flags[TextBox.Flag] = Input.Text
        end
    end)
    
    return TextBox
end


-- CREATE LABEL

function UILib:CreateLabel(config)
    config = config or {}
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = config.Text or "Label"
    Label.TextColor3 = self.Window.Library.Theme.TextSecondary
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Parent = self.Content
    
    return Label
end


-- CREATE SECTION

function UILib:CreateSection(config)
    config = config or {}
    
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.Parent = self.Content
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = config.Name or "Section"
    SectionLabel.TextColor3 = self.Window.Library.Theme.Accent
    SectionLabel.TextSize = 16
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = Section
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -5)
    Line.BackgroundColor3 = self.Window.Library.Theme.Border
    Line.BorderSizePixel = 0
    Line.Parent = Section
    
    return Section
end

return UILib
