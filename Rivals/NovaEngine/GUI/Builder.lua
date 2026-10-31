local Players = game:GetService("Players")

local function Build(H, theme, config)
    local player    = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local old = playerGui:FindFirstChild("NovaUI")
    if old then old:Destroy() end

    local gui = H.Create("ScreenGui", {
        Name             = "NovaUI",
        ResetOnSpawn     = false,
        IgnoreGuiInset   = true,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local main = H.Create("Frame", {
        Name             = "Main",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.fromScale(0.5, 0.5),
        Size             = UDim2.fromScale(0.82, 0.78),
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
    }, gui)
    H.Corner(main, 18)
    local mainStroke = H.Stroke(main, theme.Accent, 0.55)
    H.Create("UISizeConstraint", {
        MinSize = Vector2.new(320, 350),
        MaxSize = Vector2.new(1100, 760),
    }, main)
    local uiScale = H.Create("UIScale", { Scale = 1 }, main)

    -- Sidebar
    local sidebar = H.Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 190, 1, 0),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel  = 0,
    }, main)
    H.Corner(sidebar, 18)
    local sideContent = H.Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, sidebar)
    H.Pad(sideContent, 16)

    -- Logo
    local logo = H.Create("Frame", {
        Size             = UDim2.fromOffset(38, 38),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
    }, sideContent)
    H.Corner(logo, 12)
    H.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size      = UDim2.fromScale(1, 1),
        Text      = "N",
        TextColor3 = theme.White,
        Font      = Enum.Font.GothamBold,
        TextSize  = 22,
    }, logo)
    H.Create("TextLabel", {
        Position         = UDim2.new(0, 48, 0, 0),
        Size             = UDim2.new(1, -48, 0, 38),
        BackgroundTransparency = 1,
        Text             = "NOVA",
        TextColor3       = theme.White,
        TextSize         = 22,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, sideContent)

    -- Nav container
    local nav = H.Create("Frame", {
        Position         = UDim2.new(0, 0, 0, 75),
        Size             = UDim2.new(1, 0, 0, 180),
        BackgroundTransparency = 1,
    }, sideContent)
    H.Create("UIListLayout", {
        Padding   = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, nav)

    -- Content zona kryesore
    local content = H.Create("Frame", {
        Name             = "Content",
        Position         = UDim2.new(0, 206, 0, 0),
        Size             = UDim2.new(1, -222, 1, 0),
        BackgroundTransparency = 1,
    }, main)
    H.Pad(content, 18)

    -- Header
    local header = H.Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 65),
        BackgroundTransparency = 1,
    }, content)
    local breadcrumb = H.Create("TextLabel", {
        Size             = UDim2.new(1, -40, 0, 18),
        BackgroundTransparency = 1,
        Text             = "NOVA / CONTROL PANEL",
        TextColor3       = theme.Muted,
        TextSize         = 12,
        Font             = Enum.Font.GothamMedium,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, header)
    local heading = H.Create("TextLabel", {
        Position         = UDim2.new(0, 0, 0, 20),
        Size             = UDim2.new(1, -40, 0, 35),
        BackgroundTransparency = 1,
        Text             = "Aimbot Settings",
        TextColor3       = theme.White,
        TextSize         = 26,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, header)

    -- Content area — ku shfaqen pages/tabs
    local contentArea = H.Create("Frame", {
        Name             = "ContentArea",
        Position         = UDim2.new(0, 0, 0, 75),
        Size             = UDim2.new(1, 0, 1, -75),
        BackgroundTransparency = 1,
    }, content)

    -- Close button
    local close = H.Create("TextButton", {
        AnchorPoint      = Vector2.new(1, 0),
        Position         = UDim2.new(1, -15, 0, 12),
        Size             = UDim2.fromOffset(28, 28),
        BackgroundColor3 = theme.Card,
        Text             = "×",
        TextColor3       = theme.Muted,
        TextSize         = 20,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
    }, main)
    H.Corner(close, 8)

    return {
        gui         = gui,
        main        = main,
        mainStroke  = mainStroke,
        uiScale     = uiScale,
        sidebar     = sidebar,
        sideContent = sideContent,
        logo        = logo,
        nav         = nav,
        header      = header,
        breadcrumb  = breadcrumb,
        heading     = heading,
        contentArea = contentArea,
        close       = close,
    }
end

return Build
