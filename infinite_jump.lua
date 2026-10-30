
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local infiniteJump = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "InfiniteJumpGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "InfJumpButton"
button.Size = UDim2.new(0, 150, 0, 45)
button.Position = UDim2.new(0.5, -75, 0.7, 0)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.Text = "INF JUMP: OFF"
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

button.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump

    button.Text = infiniteJump and "INF JUMP: ON" or "INF JUMP: OFF"
    button.BackgroundColor3 = infiniteJump
        and Color3.fromRGB(0, 150, 90)
        or Color3.fromRGB(35, 35, 45)
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
