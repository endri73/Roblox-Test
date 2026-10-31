local function Build(H, theme, tween, nav, pages, heading, breadcrumb)
    local navItems = {
        { Name = "Aimbot",   Icon = "◎" },
        { Name = "ESP",      Icon = "◈" },
        { Name = "Settings", Icon = "⚙" },
    }
    local activeTab = nil

    local function SelectTab(name)
        activeTab        = name
        heading.Text     = name .. " Settings"
        breadcrumb.Text  = "NOVA / " .. string.upper(name)
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
        for _, child in ipairs(nav:GetChildren()) do
            if child:IsA("TextButton") then
                local active = child.Name == name
                tween(child, { BackgroundColor3 = active and theme.CardHover or theme.Sidebar })
                local ind = child:FindFirstChild("Indicator")
                if ind then tween(ind, { BackgroundTransparency = active and 0 or 1 }) end
            end
        end
    end

    for index, item in ipairs(navItems) do
        local button = H.Create("TextButton", {
            Name             = item.Name,
            Size             = UDim2.new(1, 0, 0, 43),
            BackgroundColor3 = theme.Sidebar,
            Text             = "",
            AutoButtonColor  = false,
            LayoutOrder      = index,
        }, nav)
        H.Corner(button, 9)

        H.Create("Frame", {
            Name                 = "Indicator",
            Position             = UDim2.new(0, 0, 0.2, 0),
            Size                 = UDim2.new(0, 3, 0.6, 0),
            BackgroundColor3     = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
        }, button)

        H.Create("TextLabel", {
            Position             = UDim2.new(0, 13, 0, 0),
            Size                 = UDim2.fromOffset(25, 43),
            BackgroundTransparency = 1,
            Text                 = item.Icon,
            TextColor3           = theme.Accent,
            TextSize             = 21,
            Font                 = Enum.Font.GothamBold,
        }, button)

        H.Create("TextLabel", {
            Position             = UDim2.new(0, 43, 0, 0),
            Size                 = UDim2.new(1, -48, 1, 0),
            BackgroundTransparency = 1,
            Text                 = item.Name,
            TextColor3           = theme.White,
            TextSize             = 14,
            Font                 = Enum.Font.GothamMedium,
            TextXAlignment       = Enum.TextXAlignment.Left,
        }, button)

        button.MouseButton1Click:Connect(function() SelectTab(item.Name) end)
        button.MouseEnter:Connect(function()
            if activeTab ~= item.Name then
                tween(button, { BackgroundColor3 = theme.Card })
            end
        end)
        button.MouseLeave:Connect(function()
            if activeTab ~= item.Name then
                tween(button, { BackgroundColor3 = theme.Sidebar })
            end
        end)
    end

    return SelectTab
end

return Build