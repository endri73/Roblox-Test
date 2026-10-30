local GUI = {}

function GUI.Create(settings, onToggle)
    local player = game:GetService("Players").LocalPlayer

    local screen = Instance.new("ScreenGui")
    screen.Name = "InfiniteJumpGUI"
    screen.ResetOnSpawn = false
    screen.Parent = player:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Size = settings.ButtonSize
    button.Position = settings.ButtonPosition
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Text = "INF JUMP: OFF"
    button.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        settings.Enabled = not settings.Enabled

        button.Text = settings.Enabled and "INF JUMP: ON" or "INF JUMP: OFF"

        button.BackgroundColor3 = settings.Enabled
            and Color3.fromRGB(0, 150, 90)
            or Color3.fromRGB(35, 35, 45)

        onToggle(settings.Enabled)
    end)

    return screen
end

return GUI
