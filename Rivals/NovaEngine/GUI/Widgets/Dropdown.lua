local function Build(H, theme)
    return function(parent, title, options, configKey, config, onChanged)
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.5, 0, 1, 0), 15, theme.White, theme)

        local selected = options[1]
        local button = H.Create("TextButton", {
            Position         = UDim2.new(1, -145, 0.5, -16),
            Size             = UDim2.fromOffset(130, 32),
            BackgroundColor3 = Color3.fromRGB(35, 34, 47),
            Text             = selected .. "  ▾",
            TextColor3       = theme.White,
            TextSize         = 13,
            Font             = Enum.Font.GothamMedium,
            AutoButtonColor  = false,
        }, card)
        H.Corner(button, 8)

        local function set(value)
            if not table.find(options, value) then return end
            selected          = value
            button.Text       = selected .. "  ▾"
            config[configKey] = selected
            if onChanged then onChanged(selected) end
        end

        button.MouseButton1Click:Connect(function()
            local index = table.find(options, selected) or 1
            set(options[index % #options + 1])
        end)

        return { Get = function() return selected end, Set = set }
    end
end

return Build