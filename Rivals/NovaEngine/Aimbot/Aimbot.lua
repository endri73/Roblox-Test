local AimbotModule = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

function AimbotModule.GetTarget(Config)
    local bestTarget = nil
    local shortestDist = math.huge
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                if dist <= Config.FieldOfView and dist < shortestDist then
                    shortestDist = dist
                    bestTarget = hrp
                end
            end
        end
    end
    return bestTarget
end

function AimbotModule.Step(Config)
    if not Config.AimbotEnabled then return end
    local target = AimbotModule.GetTarget(Config)
    if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPos = target.Position
        local sensitivityFactor = math.clamp(Config.Sensitivity / 100, 0.05, 1)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), sensitivityFactor)
    end
end

return AimbotModule