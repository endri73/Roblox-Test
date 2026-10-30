local UIS = game:GetService("UserInputService")

local function Build(H, theme, tween, gui)

    -- HSV → Color3
    local function hsvToColor3(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        i = i % 6
        if i == 0 then r,g,b = v,t,p
        elseif i == 1 then r,g,b = q,v,p
        elseif i == 2 then r,g,b = p,v,t
        elseif i == 3 then r,g,b = p,q,v
        elseif i == 4 then r,g,b = t,p,v
        elseif i == 5 then r,g,b = v,p,q
        end
        return Color3.fromRGB(r*255, g*255, b*255)
    end

    local function color3ToHsv(c)
        return Color3.toHSV(c)
    end

    local function CreatePickerPanel(startColor, onPick, onClose)
        local h0, s0, v0 = color3ToHsv(startColor)

        local panel = H.Create("Frame", {
            Size             = UDim2.fromOffset(240, 220),
            BackgroundColor3 = Color3.fromRGB(22, 22, 31),
            BorderSizePixel  = 0,
            ZIndex           = 50,
        }, gui)
        H.Corner(panel, 10)
        H.Stroke(panel, theme.Accent, 0.4)

        -- SV square
        local sq = H.Create("ImageLabel", {
            Position         = UDim2.new(0, 10, 0, 10),
            Size             = UDim2.fromOffset(175, 155),
            BackgroundColor3 = Color3.fromHSV(h0, 1, 1),
            BorderSizePixel  = 0,
            Image            = "rbxassetid://4155801252",  -- white→transparent gradient
            ZIndex           = 51,
        }, panel)
        H.Corner(sq, 6)
        -- overlay nero→transparent
        local sqDark = H.Create("ImageLabel", {
            Size             = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image            = "rbxassetid://4155801252",
            ImageColor3      = Color3.new(0,0,0),
            Rotation         = 90,
            ZIndex           = 52,
        }, sq)

        -- cursore SV
        local svKnob = H.Create("Frame", {
            Size             = UDim2.fromOffset(10, 10),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(s0, 0, 1 - v0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel  = 0,
            ZIndex           = 55,
        }, sq)
        H.Corner(svKnob, 10)

        -- hue slider (vertical)
        local hueBar = H.Create("ImageLabel", {
            Position         = UDim2.new(0, 193, 0, 10),
            Size             = UDim2.fromOffset(18, 155),
            Image            = "rbxassetid://3641066030",
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel  = 0,
            ZIndex           = 51,
        }, panel)
        H.Corner(hueBar, 4)

        local hueKnob = H.Create("Frame", {
            Size             = UDim2.new(1, 4, 0, 4),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0.5, 0, h0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel  = 0,
            ZIndex           = 55,
        }, hueBar)
        H.Corner(hueKnob, 4)

        -- preview box
        local preview = H.Create("Frame", {
            Position         = UDim2.new(0, 10, 0, 175),
            Size             = UDim2.fromOffset(155, 28),
            BackgroundColor3 = startColor,
            BorderSizePixel  = 0,
            ZIndex           = 51,
        }, panel)
        H.Corner(preview, 6)

        -- confirm button
        local confirmBtn = H.Create("TextButton", {
            Position         = UDim2.new(0, 173, 0, 175),
            Size             = UDim2.fromOffset(57, 28),
            BackgroundColor3 = theme.Accent,
            Text             = "OK",
            TextColor3       = theme.White,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = 51,
        }, panel)
        H.Corner(confirmBtn, 6)

        local curH, curS, curV = h0, s0, v0

        local function rebuild()
            sq.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
            local col = hsvToColor3(curH, curS, curV)
            preview.BackgroundColor3 = col
            svKnob.Position  = UDim2.new(curS, 0, 1 - curV, 0)
            hueKnob.Position = UDim2.new(0.5, 0, curH, 0)
            return col
        end

        -- SV drag
        local draggingSV = false
        local sqBtn = H.Create("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
            Text = "", ZIndex = 56,
        }, sq)
        sqBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = true
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if draggingSV and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = inp.Position
                curS = math.clamp((rel.X - sq.AbsolutePosition.X) / sq.AbsoluteSize.X, 0, 1)
                curV = 1 - math.clamp((rel.Y - sq.AbsolutePosition.Y) / sq.AbsoluteSize.Y, 0, 1)
                rebuild()
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = false
            end
        end)

        -- hue drag
        local draggingH = false
        local hueBtn = H.Create("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
            Text = "", ZIndex = 56,
        }, hueBar)
        hueBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingH = true
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if draggingH and inp.UserInputType == Enum.UserInputType.MouseMovement then
                curH = math.clamp((inp.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                rebuild()
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingH = false
            end
        end)

        confirmBtn.MouseButton1Click:Connect(function()
            local col = hsvToColor3(curH, curS, curV)
            panel:Destroy()
            if onPick then onPick(col) end
        end)

        return panel
    end

    local function SetPanelPosition(panel, button)
        local abs = button.AbsolutePosition
        local sz  = button.AbsoluteSize
        local gSz = gui.AbsoluteSize
        local pw  = 240
        local ph  = 220
        local x   = abs.X + sz.X / 2 - pw / 2
        local y   = abs.Y - ph - 8
        if y < 0 then y = abs.Y + sz.Y + 8 end
        if x + pw > gSz.X then x = gSz.X - pw - 8 end
        if x < 0 then x = 8 end
        panel.Position = UDim2.fromOffset(x, y)
    end

    local function ApplyAccent(color, mainStroke, logo, fovCircle, pages)
        theme.Accent          = color
        mainStroke.Color      = color
        logo.BackgroundColor3 = color
        fovCircle.Color       = color
        for _, page in pairs(pages) do
            page.ScrollBarImageColor3 = color
        end
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("Frame") and (desc.Name == "Indicator" or desc.Name == "Fill") then
                desc.BackgroundColor3 = color
            end
        end
    end

    local function CreateColorPicker(parent, title, configKey, config, onChanged)
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.6, 0, 1, 0), 15, theme.White, theme)

        local currentColor = config[configKey] or Color3.fromRGB(108, 92, 231)
        local preview = H.Create("TextButton", {
            Position         = UDim2.new(1, -53, 0.5, -15),
            Size             = UDim2.fromOffset(34, 30),
            BackgroundColor3 = currentColor,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 10,
        }, card)
        H.Corner(preview, 8)

        local activePanel = nil
        preview.MouseButton1Click:Connect(function()
            if activePanel then
                activePanel:Destroy()
                activePanel = nil
                return
            end
            activePanel = CreatePickerPanel(currentColor, function(col)
                currentColor           = col
                preview.BackgroundColor3 = col
                config[configKey]      = col
                activePanel            = nil
                if onChanged then onChanged(col) end
            end, function()
                activePanel = nil
            end)
            SetPanelPosition(activePanel, preview)
        end)

        return {
            Get = function() return currentColor end,
            Set = function(col)
                currentColor             = col
                preview.BackgroundColor3 = col
                config[configKey]        = col
            end,
        }
    end

    return CreateColorPicker, ApplyAccent
end

return Build
