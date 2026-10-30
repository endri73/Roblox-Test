--[=[
    NOVA UI - Full Engine Monolith Build
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NovaUI")
if old then old:Destroy() end

local Config = {
    AimbotEnabled = false,
    FieldOfView = 90,
    Sensitivity = 50,
    TargetMode = "Default",
    AimbotAccent = Color3.fromRGB(108, 92, 231),
    ShowMarkers = true,
    ShowNames = true,
    ShowDistance = false,
    MarkerColor = Color3.fromRGB(108, 92, 231),
    DisplayRange = 500,
    UIAnimations = true,
    PerformanceMode = false,
    InterfaceScale = "Medium",
    ThemeAccent = Color3.fromRGB(108, 92, 231),
    ToggleKey = Enum.KeyCode.RightShift,
}

local Theme = {
    Background = Color3.fromRGB(13, 13, 17),
    Sidebar = Color3.fromRGB(18, 18, 25),
    Card = Color3.fromRGB(22, 22, 31),
    CardHover = Color3.fromRGB(31, 29, 45),
    Accent = Config.ThemeAccent,
    White = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(160, 160, 176),
}

local function Create(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do obj[key] = value end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    Create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function Stroke(parent, color, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Accent,
        Thickness = 1,
        Transparency = transparency or 0.7,
    }, parent)
end

local function Pad(parent, amount)
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount),
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
    }, parent)
end

local function Tween(obj, props, duration)
    if not Config.UIAnimations or Config.PerformanceMode then
        for k, v in pairs(props) do obj[k] = v end
        return
    end
    TweenService:Create(obj, TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local gui = Create("ScreenGui", {
    Name = "NovaUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Transparency = 0.7
fovCircle.Thickness = 1.5
fovCircle.Color = Config.AimbotAccent
fovCircle.Filled = false

local main = Create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.82, 0.78),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
}, gui)
Corner(main, 18)
local mainStroke = Stroke(main, Theme.Accent, 0.55)
Create("UISizeConstraint", {MinSize = Vector2.new(320, 350), MaxSize = Vector2.new(1100, 760)}, main)

local scales = { Smaller = 0.75, Small = 0.9, Medium = 1.05 }
local uiScale = Create("UIScale", {Scale = scales[Config.InterfaceScale] or 1.05}, main)

local sidebar = Create("Frame", {
    Name = "Sidebar", Size = UDim2.new(0, 190, 1, 0),
    BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
}, main)
Corner(sidebar, 18)
local sideContent = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}, sidebar)
Pad(sideContent, 16)

local logo = Create("Frame", {Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, sideContent)
Corner(logo, 12)
Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "N", TextColor3 = Theme.White, Font = Enum.Font.GothamBold, TextSize = 22}, logo)
Create("TextLabel", {
    Position = UDim2.new(0, 48, 0, 0), Size = UDim2.new(1, -48, 0, 38),
    BackgroundTransparency = 1, Text = "NOVA", TextColor3 = Theme.White,
    TextSize = 22, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
}, sideContent)

local nav = Create("Frame", {Position = UDim2.new(0, 0, 0, 75), Size = UDim2.new(1, 0, 0, 180), BackgroundTransparency = 1}, sideContent)
Create("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, nav)

local content = Create("Frame", {
    Name = "Content", Position = UDim2.new(0, 206, 0, 0),
    Size = UDim2.new(1, -222, 1, 0), BackgroundTransparency = 1,
}, main)
Pad(content, 18)
local header = Create("Frame", {Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1}, content)
local breadcrumb = Create("TextLabel", {
    Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1,
    Text = "NOVA / CONTROL PANEL", TextColor3 = Theme.Muted,
    TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local heading = Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, -40, 0, 35),
    BackgroundTransparency = 1, Text = "Aimbot Settings", TextColor3 = Theme.White,
    TextSize = 26, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local contentArea = Create("Frame", {Position = UDim2.new(0, 0, 0, 75), Size = UDim2.new(1, 0, 1, -75), BackgroundTransparency = 1}, content)

local pages = {}
local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, contentArea)
    Pad(page, 4)
    Create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

local function CreateCard(parent, height)
    local card = Create("Frame", {Size = UDim2.new(1, -8, 0, height or 60), BackgroundColor3 = Theme.Card, BorderSizePixel = 0}, parent)
    Corner(card, 12)
    return card
end

local function AddLabel(parent, text, position, size, textSize, color)
    return Create("TextLabel", {
        Position = position, Size = size, BackgroundTransparency = 1,
        Text = text, TextColor3 = color or Theme.White, TextSize = textSize or 15,
        Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function CreateToggle(parent, title, default, configKey, onChanged)
    local card = CreateCard(parent, 60)
    AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(1, -85, 1, 0), 15)
    local switch = Create("TextButton", {
        Position = UDim2.new(1, -60, 0.5, -12), Size = UDim2.fromOffset(45, 24),
        BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55, 55, 65),
        Text = "", AutoButtonColor = false,
    }, card)
    Corner(switch, 20)
    local knob = Create("Frame", {
        Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, default and 24 or 3, 0, 3),
        BackgroundColor3 = Theme.White, BorderSizePixel = 0,
    }, switch)
    Corner(knob, 20)
    local enabled = default
    local function set(value)
        enabled = value == true
        Config[configKey] = enabled
        Tween(switch, {BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(55, 55, 65)})
        Tween(knob, {Position = UDim2.new(0, enabled and 24 or 3, 0, 3)})
        if onChanged then onChanged(enabled) end
    end
    switch.MouseButton1Click:Connect(function() set(not enabled) end)
    return {Get = function() return enabled end, Set = set}
end

local function CreateSlider(parent, title, minimum, maximum, default, configKey, onChanged)
    local card = CreateCard(parent, 75)
    AddLabel(card, title, UDim2.new(0, 15, 0, 10), UDim2.new(0.7, 0, 0, 22), 15)
    local valueLabel = Create("TextLabel", {
        Position = UDim2.new(1, -65, 0, 10), Size = UDim2.fromOffset(50, 22),
        BackgroundTransparency = 1, Text = tostring(default), TextColor3 = Theme.Accent,
        TextSize = 15, Font = Enum.Font.GothamBold,
    }, card)
    local track = Create("Frame", {
        Position = UDim2.new(0, 15, 0, 48), Size = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = Color3.fromRGB(48, 47, 59), BorderSizePixel = 0,
    }, card)
    Corner(track, 5)
    local function pctFor(v) return math.clamp((v - minimum) / (maximum - minimum), 0, 1) end
    local initial = pctFor(default)
    local fill = Create("Frame", {Size = UDim2.new(initial, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0}, track)
    Corner(fill, 5)
    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(initial, 0, 0.5, 0),
        Size = UDim2.fromOffset(13, 13), BackgroundColor3 = Theme.White, BorderSizePixel = 0,
    }, track)
    Corner(knob, 10)
    local hitbox = Create("TextButton", {Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0.5, -12), BackgroundTransparency = 1, Text = ""}, track)
    local value = default
    local draggingSlider = false
    local function setValue(v)
        value = math.clamp(math.floor(v + 0.5), minimum, maximum)
        local p = pctFor(value)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        Config[configKey] = value
        if onChanged then onChanged(value) end
    end
    local function update(input)
        if track.AbsoluteSize.X <= 0 then return end
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(minimum + (maximum - minimum) * p)
    end
    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input)
        end
    end)
    local moveConnection = UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    local endConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
    end)
    return {Get = function() return value end, Set = setValue}
end

local function CreateDropdown(parent, title, options, configKey, onChanged)
    local card = CreateCard(parent, 60)
    AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.5, 0, 1, 0), 15)
    local selected = options[1]
    local button = Create("TextButton", {
        Position = UDim2.new(1, -145, 0.5, -16), Size = UDim2.fromOffset(130, 32),
        BackgroundColor3 = Color3.fromRGB(35, 34, 47), Text = selected .. "  ▾",
        TextColor3 = Theme.White, TextSize = 13, Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
    }, card)
    Corner(button, 8)
    local function set(value)
        if not table.find(options, value) then return end
        selected = value
        button.Text = selected .. "  ▾"
        Config[configKey] = selected
        if onChanged then onChanged(selected) end
    end
    button.MouseButton1Click:Connect(function()
        local index = table.find(options, selected) or 1
        set(options[index % #options + 1])
    end)
    return {Get = function() return selected end, Set = set}
end

local function CreateKeybind(parent, title, configKey, onChanged)
    local card = CreateCard(parent, 60)
    AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.5, 0, 1, 0), 15)
    local selectedKey = Config[configKey]
    local button = Create("TextButton", {
        Position = UDim2.new(1, -145, 0.5, -16), Size = UDim2.fromOffset(130, 32),
        BackgroundColor3 = Color3.fromRGB(35, 34, 47), Text = selectedKey.Name,
        TextColor3 = Theme.White, TextSize = 13, Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
    }, card)
    Corner(button, 8)
    local listening = false
    button.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        button.Text = "..."
        button.TextColor3 = Theme.Accent
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                selectedKey = input.KeyCode
                Config[configKey] = selectedKey
                button.Text = selectedKey.Name
                button.TextColor3 = Theme.White
                listening = false
                connection:Disconnect()
                if onChanged then onChanged(selectedKey) end
            end
        end)
    end)
    return {Get = function() return selectedKey end}
end

local palette = {
    Color3.fromRGB(108, 92, 231),
    Color3.fromRGB(0, 210, 255),
    Color3.fromRGB(255, 90, 140),
    Color3.fromRGB(72, 211, 151),
    Color3.fromRGB(255, 190, 80),
}

local function ApplyAccent(color)
    Theme.Accent = color
    Config.ThemeAccent = color
    mainStroke.Color = color
    logo.BackgroundColor3 = color
    fovCircle.Color = color
end

local function CreateColorPicker(parent, title, configKey, onChanged)
    local card = CreateCard(parent, 60)
    AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.6, 0, 1, 0), 15)
    local index = 1
    local preview = Create("TextButton", {
        Position = UDim2.new(1, -53, 0.5, -15), Size = UDim2.fromOffset(34, 30),
        BackgroundColor3 = palette[index], Text = "", AutoButtonColor = false,
    }, card)
    Corner(preview, 8)
    local function set(colorIndex)
        index = ((colorIndex - 1) % #palette) + 1
        Tween(preview, {BackgroundColor3 = palette[index]})
        Config[configKey] = palette[index]
        if onChanged then onChanged(palette[index]) end
    end
    preview.MouseButton1Click:Connect(function() set(index % #palette + 1) end)
    return {Get = function() return palette[index] end, Set = set}
end

local aimbotPage = CreatePage("Aimbot")
CreateToggle(aimbotPage, "Enable Feature", false, "AimbotEnabled")
CreateSlider(aimbotPage, "Field of View", 10, 300, 90, "FieldOfView")
CreateSlider(aimbotPage, "Sensitivity", 1, 100, 50, "Sensitivity")
CreateDropdown(aimbotPage, "Target Mode", {"Default", "Nearest", "Custom"}, "TargetMode")
CreateColorPicker(aimbotPage, "Accent Color", "AimbotAccent")

local espPage = CreatePage("ESP")
CreateToggle(espPage, "Show Markers", true, "ShowMarkers")
CreateToggle(espPage, "Show Names", true, "ShowNames")
CreateToggle(espPage, "Show Distance", false, "ShowDistance")
CreateColorPicker(espPage, "Marker Color", "MarkerColor")
CreateSlider(espPage, "Display Range", 50, 1000, 500, "DisplayRange")

local settingsPage = CreatePage("Settings")
CreateToggle(settingsPage, "UI Animations", true, "UIAnimations")
CreateToggle(settingsPage, "Performance Mode", false, "PerformanceMode")
CreateDropdown(settingsPage, "Interface Scale", {"Smaller", "Small", "Medium"}, "InterfaceScale", function(value)
    Tween(uiScale, {Scale = scales[value] or 1.05}, 0.2)
end)
CreateKeybind(settingsPage, "Toggle GUI Key", "ToggleKey")
CreateColorPicker(settingsPage, "Theme Accent", "ThemeAccent", ApplyAccent)

local navItems = {
    {Name = "Aimbot", Icon = "◎"},
    {Name = "ESP", Icon = "◈"},
    {Name = "Settings", Icon = "⚙"},
}
local activeTab = nil
local function SelectTab(name)
    activeTab = name
    heading.Text = name .. " Settings"
    breadcrumb.Text = "NOVA / " .. string.upper(name)
    for pageName, page in pairs(pages) do page.Visible = pageName == name end
    for _, child in ipairs(nav:GetChildren()) do
        if child:IsA("TextButton") then
            local active = child.Name == name
            Tween(child, {BackgroundColor3 = active and Theme.CardHover or Theme.Sidebar})
            local indicator = child:FindFirstChild("Indicator")
            if indicator then Tween(indicator, {BackgroundTransparency = active and 0 or 1}) end
        end
    end
end

for index, item in ipairs(navItems) do
    local button = Create("TextButton", {
        Name = item.Name, Size = UDim2.new(1, 0, 0, 43), BackgroundColor3 = Theme.Sidebar,
        Text = "", AutoButtonColor = false, LayoutOrder = index,
    }, nav)
    Corner(button, 9)
    local indicator = Create("Frame", {
        Name = "Indicator", Position = UDim2.new(0, 0, 0.2, 0), Size = UDim2.new(0, 3, 0.6, 0),
        BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
    }, button)
    Corner(indicator, 5)
    Create("TextLabel", {Position = UDim2.new(0, 13, 0, 0), Size = UDim2.fromOffset(25, 43), BackgroundTransparency = 1, Text = item.Icon, TextColor3 = Theme.Accent, TextSize = 21, Font = Enum.Font.GothamBold}, button)
    Create("TextLabel", {Position = UDim2.new(0, 43, 0, 0), Size = UDim2.new(1, -48, 1, 0), BackgroundTransparency = 1, Text = item.Name, TextColor3 = Theme.White, TextSize = 14, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left}, button)
    button.MouseButton1Click:Connect(function() SelectTab(item.Name) end)
end

SelectTab("Aimbot")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        main.Visible = not main.Visible
    end
end)

local close = Create("TextButton", {
    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -15, 0, 12),
    Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Theme.Card,
    Text = "×", TextColor3 = Theme.Muted, TextSize = 20,
    Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, main)
Corner(close, 8)

local closed = false
close.MouseButton1Click:Connect(function()
    if closed then return end
    closed = true
    if Config.UIAnimations then
        Tween(main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() pcall(function() fovCircle:Remove() end); gui:Destroy() end)
    else
        pcall(function() fovCircle:Remove() end)
        gui:Destroy()
    end
end)

local espCache = {}
RunService.RenderStepped:Connect(function()
    if closed then return end

    if Config.AimbotEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = Config.FieldOfView
        fovCircle.Color = Config.AimbotAccent
        fovCircle.Visible = main.Visible

        local bestTarget = nil
        local shortestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= Config.FieldOfView and dist < shortestDist then
                        shortestDist = dist
                        bestTarget = hrp
                    end
                end
            end
        end

        if bestTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local sensitivityFactor = math.clamp(Config.Sensitivity / 100, 0.05, 1)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, bestTarget.Position), sensitivityFactor)
        end
    else
        fovCircle.Visible = false
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local dist = (hrp.Position - Camera.CFrame.Position).Magnitude

                if dist <= Config.DisplayRange then
                    local esp = espCache[p]
                    if not esp then
                        esp = {
                            Highlight = Instance.new("Highlight"),
                            Billboard = Instance.new("BillboardGui"),
                            NameLabel = Instance.new("TextLabel"),
                        }
                        esp.Highlight.Parent = char
                        esp.Highlight.FillTransparency = 0.5
                        esp.Highlight.OutlineTransparency = 0

                        esp.Billboard.Size = UDim2.new(0, 100, 0, 50)
                        esp.Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                        esp.Billboard.AlwaysOnTop = true
                        esp.Billboard.Parent = char

                        esp.NameLabel.Size = UDim2.new(1, 0, 1, 0)
                        esp.NameLabel.BackgroundTransparency = 1
                        esp.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        esp.NameLabel.TextStrokeTransparency = 0.5
                        esp.NameLabel.TextSize = 13
                        esp.NameLabel.Font = Enum.Font.GothamBold
                        esp.NameLabel.Parent = esp.Billboard

                        espCache[p] = esp
                    end

                    esp.Highlight.Enabled = Config.ShowMarkers
                    esp.Highlight.FillColor = Config.MarkerColor
                    esp.Highlight.OutlineColor = Config.MarkerColor

                    local displayText = ""
                    if Config.ShowNames then displayText = p.DisplayName end
                    if Config.ShowDistance then
                        displayText = displayText .. (displayText ~= "" and " [" .. math.floor(dist) .. "m]" or math.floor(dist) .. "m")
                    end

                    esp.NameLabel.Text = displayText
                    esp.NameLabel.Visible = (Config.ShowNames or Config.ShowDistance) and displayText ~= ""
                else
                    if espCache[p] then
                        espCache[p].Highlight.Enabled = false
                        espCache[p].NameLabel.Visible = false
                    end
                end
            else
                if espCache[p] then
                    espCache[p].Highlight.Enabled = false
                    espCache[p].NameLabel.Visible = false
                end
            end
        end
    end
end)

local dragging = false
local dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
