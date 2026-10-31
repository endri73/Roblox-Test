local UIS = game:GetService("UserInputService")

local function Build(config, main)
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == config.ToggleKey then
            main.Visible = not main.Visible
        end
    end)
end

return Build