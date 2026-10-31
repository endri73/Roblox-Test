local UIS = game:GetService("UserInputService")

local function Build(H, theme, tween)
    return function(parent, title, minimum, maximum, default, configKey, config, onChanged)
        local card = H.CreateCard(parent, 75)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 10), UDim2.new(0.7, 0, 0, 22), 15, theme.White, theme)

        local valueLabel = H.Create("TextLabel", {
            Position         = UDim2.new(1, -65, 0, 10),
            Size             = UDim2.fromOffset(50, 22),
            BackgroundTransparency = 1,
            Text             = tostring(default),
            TextColor3       = theme.Accent,
            TextSize         = 15,
            Font             = Enum.Font.GothamBold,
        }, card)

        local track = H.Create("Frame", {
            Position         = UDim2.new(0, 15, 0, 48),
            Size             = UDim2.new(1, -30, 0, 5),
            BackgroundColor3 = Color3.fromRGB(48, 47, 59),
            BorderSizePixel  = 0,
        }, card)
        H.Corner(track, 5)

        local function pctFor(v)
            return math.clamp((v - minimum) / (maximum - minimum), 0, 1)
        end

        local initial = pctFor(default)
        local fill = H.Create("Frame", {
            Size             = UDim2.new(initial, 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel  = 0,
        }, track)
        H.Corner(fill, 5)

        local knob = H.Create("Frame", {
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(initial, 0, 0.5, 0),
            Size             = UDim2.fromOffset(13, 13),
            BackgroundColor3 = theme.White,
            BorderSizePixel  = 0,
        }, track)
        H.Corner(knob, 10)

        local hitbox = H.Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 25),
            Position         = UDim2.new(0, 0, 0.5, -12),
            BackgroundTransparency = 1,
            Text             = "",
        }, track)

        local value   = default
        local dragging = false

        local function setValue(v)
            value             = math.clamp(math.floor(v + 0.5), minimum, maximum)
            local p           = pctFor(value)
            fill.Size         = UDim2.new(p, 0, 1, 0)
            knob.Position     = UDim2.new(p, 0, 0.5, 0)
            valueLabel.Text   = tostring(value)
            config[configKey] = value
            if onChanged then onChanged(value) end
        end

        local function update(input)
            if track.AbsoluteSize.X <= 0 then return end
            local p = math.clamp(
                (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(minimum + (maximum - minimum) * p)
        end

        hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)

        local moveConn = UIS.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement or
                input.UserInputType == Enum.UserInputType.Touch
            ) then update(input) end
        end)

        local endConn = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        return {
            Get     = function() return value end,
            Set     = setValue,
            Cleanup = function() moveConn:Disconnect(); endConn:Disconnect() end,
        }
    end
end

return Build