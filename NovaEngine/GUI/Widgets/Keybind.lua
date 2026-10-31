local UIS = game:GetService("UserInputService")

local function Build(H, theme)
    return function(parent, title, configKey, config, onChanged)
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.5, 0, 1, 0), 15, theme.White, theme)

        local selectedKey = config[configKey]
        local button = H.Create("TextButton", {
            Position         = UDim2.new(1, -145, 0.5, -16),
            Size             = UDim2.fromOffset(130, 32),
            BackgroundColor3 = Color3.fromRGB(35, 34, 47),
            Text             = selectedKey.Name,
            TextColor3       = theme.White,
            TextSize         = 13,
            Font             = Enum.Font.GothamMedium,
            AutoButtonColor  = false,
        }, card)
        H.Corner(button, 8)

        local listening = false
        button.MouseButton1Click:Connect(function()
            if listening then return end
            listening         = true
            button.Text       = "..."
            button.TextColor3 = theme.Accent
            local conn
            conn = UIS.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    selectedKey       = input.KeyCode
                    config[configKey] = selectedKey
                    button.Text       = selectedKey.Name
                    button.TextColor3 = theme.White
                    listening         = false
                    conn:Disconnect()
                    if onChanged then onChanged(selectedKey) end
                end
            end)
        end)

        return { Get = function() return selectedKey end }
    end
end

return Build