local function Build(H, theme, tween)
    return function(parent, title, default, configKey, config, onChanged)
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(1, -85, 1, 0), 15, theme.White, theme)

        local switch = H.Create("TextButton", {
            Position         = UDim2.new(1, -60, 0.5, -12),
            Size             = UDim2.fromOffset(45, 24),
            BackgroundColor3 = default and theme.Accent or Color3.fromRGB(55, 55, 65),
            Text             = "",
            AutoButtonColor  = false,
        }, card)
        H.Corner(switch, 20)

        local knob = H.Create("Frame", {
            Size             = UDim2.fromOffset(18, 18),
            Position         = UDim2.new(0, default and 24 or 3, 0, 3),
            BackgroundColor3 = theme.White,
            BorderSizePixel  = 0,
        }, switch)
        H.Corner(knob, 20)

        local enabled = default
        local function set(value)
            enabled          = value == true
            config[configKey] = enabled
            tween(switch, { BackgroundColor3 = enabled and theme.Accent or Color3.fromRGB(55, 55, 65) })
            tween(knob,   { Position = UDim2.new(0, enabled and 24 or 3, 0, 3) })
            if onChanged then onChanged(enabled) end
        end

        switch.MouseButton1Click:Connect(function() set(not enabled) end)
        return { Get = function() return enabled end, Set = set }
    end
end

return Build