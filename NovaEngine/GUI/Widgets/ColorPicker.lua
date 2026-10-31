local UIS = game:GetService("UserInputService")

local function Build(H, theme, tween, gui)

    local function hsvToColor3(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t2 = v * (1 - (1 - f) * s)
        i = i % 6
        if     i == 0 then r,g,b = v, t2, p
        elseif i == 1 then r,g,b = q, v,  p
        elseif i == 2 then r,g,b = p, v,  t2
        elseif i == 3 then r,g,b = p, q,  v
        elseif i == 4 then r,g,b = t2,p,  v
        elseif i == 5 then r,g,b = v, p,  q
        end
        return Color3.fromRGB(
            math.clamp(math.floor(r*255+0.5),0,255),
            math.clamp(math.floor(g*255+0.5),0,255),
            math.clamp(math.floor(b*255+0.5),0,255)
        )
    end

    -- ndërto hue bar me 18 segmente ngjyrash
    local function BuildHueBar(parent)
        local container = H.Create("Frame", {
            Size            = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
        }, parent)
        local steps = 18
        for i = 0, steps - 1 do
            local h   = i / steps
            local col = hsvToColor3(h, 1, 1)
            local seg = H.Create("Frame", {
                Position        = UDim2.new(0, 0, i/steps, 0),
                Size            = UDim2.new(1, 0, 1/steps, 1),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                ZIndex          = 52,
            }, container)
            if i == 0 then H.Corner(seg, 4) end
        end
        return container
    end

    -- ndërto SV square me gradiente të sakta
    local function BuildSVSquare(parent, hue)
        -- background: ngjyra e plotë e hue-it
        parent.BackgroundColor3 = hsvToColor3(hue, 1, 1)

        -- gradient horizontal: e bardhë → transparent (saturation)
        local satGrad = H.Create("Frame", {
            Size            = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ZIndex          = 53,
        }, parent)
        local satUI = Instance.new("UIGradient")
        satUI.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
        })
        satUI.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        satUI.Parent = satGrad

        -- gradient vertical: trasparent → e zezë (value)
        local valGrad = H.Create("Frame", {
            Size            = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ZIndex          = 54,
        }, parent)
        local valUI = Instance.new("UIGradient")
        valUI.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
        })
        valUI.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        valUI.Rotation = 90
        valUI.Parent   = valGrad

        return satUI, valUI
    end

    local function CreatePickerPanel(startColor, onPick)
        local h0, s0, v0 = Color3.toHSV(startColor)

        -- frame kryesor
        local panel = H.Create("Frame", {
            Size             = UDim2.fromOffset(255, 235),
            BackgroundColor3 = Color3.fromRGB(18, 18, 25),
            BorderSizePixel  = 0,
            ZIndex           = 100,
        }, gui)
        H.Corner(panel, 10)
        H.Stroke(panel, theme.Accent, 0.3)

        -- SV square
        local sq = H.Create("Frame", {
            Position        = UDim2.fromOffset(10, 10),
            Size            = UDim2.fromOffset(180, 160),
            BorderSizePixel = 0,
            ZIndex          = 51,
        }, panel)
        H.Corner(sq, 6)
        local satUI, valUI = BuildSVSquare(sq, h0)

        -- cursore SV
        local svKnob = H.Create("Frame", {
            Size            = UDim2.fromOffset(12, 12),
            AnchorPoint     = Vector2.new(0.5, 0.5),
            Position        = UDim2.new(s0, 0, 1 - v0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            ZIndex          = 60,
        }, sq)
        H.Corner(svKnob, 10)
        H.Stroke(svKnob, Color3.new(0,0,0), 0.3)

        -- hue bar
        local hueBar = H.Create("Frame", {
            Position        = UDim2.fromOffset(198, 10),
            Size            = UDim2.fromOffset(20, 160),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            ZIndex          = 51,
        }, panel)
        H.Corner(hueBar, 4)
        BuildHueBar(hueBar)

        -- cursore hue
        local hueKnob = H.Create("Frame", {
            Size            = UDim2.new(1, 6, 0, 4),
            AnchorPoint     = Vector2.new(0.5, 0.5),
            Position        = UDim2.new(0.5, 0, h0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            ZIndex          = 62,
        }, hueBar)
        H.Corner(hueKnob, 3)
        H.Stroke(hueKnob, Color3.new(0,0,0), 0.3)

        -- preview + OK
        local preview = H.Create("Frame", {
            Position        = UDim2.fromOffset(10, 182),
            Size            = UDim2.fromOffset(160, 26),
            BackgroundColor3 = startColor,
            BorderSizePixel = 0,
            ZIndex          = 51,
        }, panel)
        H.Corner(preview, 6)

        local okBtn = H.Create("TextButton", {
            Position        = UDim2.fromOffset(178, 182),
            Size            = UDim2.fromOffset(66, 26),
            BackgroundColor3 = theme.Accent,
            Text            = "OK",
            TextColor3      = theme.White,
            TextSize        = 13,
            Font            = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex          = 51,
        }, panel)
        H.Corner(okBtn, 6)

        local curH, curS, curV = h0, s0, v0

        local function rebuild()
            sq.BackgroundColor3  = hsvToColor3(curH, 1, 1)
            local col            = hsvToColor3(curH, curS, curV)
            preview.BackgroundColor3 = col
            svKnob.Position      = UDim2.new(curS, 0, 1 - curV, 0)
            hueKnob.Position     = UDim2.new(0.5, 0, curH, 0)
            return col
        end

        -- SV drag
        local draggingSV = false
        local sqHit = H.Create("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
            Text = "", ZIndex = 65,
        }, sq)
        sqHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = true
                local rx = math.clamp((inp.Position.X - sq.AbsolutePosition.X)/sq.AbsoluteSize.X,0,1)
                local ry = math.clamp((inp.Position.Y - sq.AbsolutePosition.Y)/sq.AbsoluteSize.Y,0,1)
                curS = rx; curV = 1 - ry; rebuild()
            end
        end)
        local moveConn = UIS.InputChanged:Connect(function(inp)
            if draggingSV and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local rx = math.clamp((inp.Position.X - sq.AbsolutePosition.X)/sq.AbsoluteSize.X,0,1)
                local ry = math.clamp((inp.Position.Y - sq.AbsolutePosition.Y)/sq.AbsoluteSize.Y,0,1)
                curS = rx; curV = 1 - ry; rebuild()
            end
        end)
        local endConn = UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = false
            end
        end)

        -- hue drag
        local draggingH = false
        local hueHit = H.Create("TextButton", {
            Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
            Text = "", ZIndex = 65,
        }, hueBar)
        hueHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingH = true
                curH = math.clamp((inp.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,1)
                rebuild()
            end
        end)
        local moveConn2 = UIS.InputChanged:Connect(function(inp)
            if draggingH and inp.UserInputType == Enum.UserInputType.MouseMovement then
                curH = math.clamp((inp.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,1)
                rebuild()
            end
        end)
        local endConn2 = UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingH = false
            end
        end)

        okBtn.MouseButton1Click:Connect(function()
            local col = hsvToColor3(curH, curS, curV)
            moveConn:Disconnect(); endConn:Disconnect()
            moveConn2:Disconnect(); endConn2:Disconnect()
            panel:Destroy()
            if onPick then onPick(col) end
        end)

        return panel
    end

    local function SetPanelPosition(panel, button)
        local abs = button.AbsolutePosition
        local sz  = button.AbsoluteSize
        local gSz = gui.AbsoluteSize
        local pw, ph = 255, 235
        local x = abs.X + sz.X/2 - pw/2
        local y = abs.Y - ph - 8
        if y < 0        then y = abs.Y + sz.Y + 8 end
        if x + pw > gSz.X then x = gSz.X - pw - 8 end
        if x < 0        then x = 8 end
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
            if desc:IsA("Frame") and (desc.Name == "Indicator") then
                desc.BackgroundColor3 = color
            end
        end
    end

    local function CreateColorPicker(parent, title, configKeys, config, onChanged)
        -- configKeys: string ose table me shumë keys që ndryshojnë të njëjtën ngjyrë
        local keys = type(configKeys) == "table" and configKeys or {configKeys}
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0,15,0,0), UDim2.new(0.6,0,1,0), 15, theme.White, theme)

        local currentColor = config[keys[1]] or Color3.fromRGB(108, 92, 231)
        local preview = H.Create("TextButton", {
            Position        = UDim2.new(1,-53,0.5,-15),
            Size            = UDim2.fromOffset(34, 30),
            BackgroundColor3 = currentColor,
            Text            = "",
            AutoButtonColor = false,
            ZIndex          = 10,
        }, card)
        H.Corner(preview, 8)
        H.Stroke(preview, theme.Accent, 0.5)

        local activePanel = nil
        preview.MouseButton1Click:Connect(function()
            if activePanel then
                activePanel:Destroy()
                activePanel = nil
                return
            end
            activePanel = CreatePickerPanel(currentColor, function(col)
                currentColor             = col
                preview.BackgroundColor3 = col
                for _, k in ipairs(keys) do config[k] = col end
                activePanel              = nil
                if onChanged then
                    onChanged(col)
                end
            end)
        end)

        return preview
    end

    return CreateColorPicker, ApplyAccent
end

return Build
