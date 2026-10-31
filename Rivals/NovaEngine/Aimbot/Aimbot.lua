local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function Build(config, fov, main, closed)
    local player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local function getTarget()
        local bestTarget  = nil
        local shortestDist = math.huge
        local mouseLoc    = UIS:GetMouseLocation()

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player
            and p.Character
            and p.Character:FindFirstChild("HumanoidRootPart")
            and p.Character:FindFirstChild("Humanoid")
            and p.Character.Humanoid.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if dist <= config.FieldOfView and dist < shortestDist then
                        shortestDist = dist
                        bestTarget   = hrp
                    end
                end
            end
        end
        return bestTarget
    end

    RunService.RenderStepped:Connect(function()
        if closed() then return end
        fov.Update(main.Visible)

        if config.AimbotEnabled then
            local target = getTarget()
            if target and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local factor = math.clamp(config.Sensitivity / 100, 0.05, 1)
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, target.Position), factor)
            end
        end
    end)
end

return Build