--[=[
    NovaUI.lua - Vetëm Ndërfaqja Grafike (UI)
]=]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NovaUI")
if old then old:Destroy() end

local Theme = {
    Background = Color3.fromRGB(13, 13, 17),
    Sidebar = Color3.fromRGB(18, 18, 25),
    Card = Color3.fromRGB(22, 22, 31),
    CardHover = Color3.fromRGB(31, 29, 45),
    Accent = Color3.fromRGB(108, 92, 231),
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

local gui = Create("ScreenGui", {
    Name = "NovaUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

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
local uiScale = Create("UIScale", {Scale = 1.05}, main)

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

CreatePage("Aimbot")
CreatePage("ESP")
CreatePage("Settings")

return {
    Gui = gui,
    MainFrame = main,
    UIScale = uiScale,
    Pages = pages,
    Header = header,
    Heading = heading,
    Breadcrumb = breadcrumb
}
