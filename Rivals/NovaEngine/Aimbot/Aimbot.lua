local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function Build(config, fov, main, closed)
    local player = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local function getBone(char)
        if config.AimbotMode == "Head" then
            return char:FindFirstChild("Head")
        else
            return char:FindFirstChild("HumanoidRootPart")
        end
    end

    local function getTarget()
        local bestTarget   = nil
        local shortestDist = math.huge
        local mouseLoc     = UIS:GetMouseLocation()

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player
            and p.Character
            and p.Character:FindFirstChild("HumanoidRootPart")
            and p.Character:FindFirstChild("Humanoid")
            and p.Character.Humanoid.Health > 0 then
                local bone = getBone(p.Character)
                if bone then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(bone.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                        if dist <= config.FieldOfView and dist < shortestDist then
                            shortestDist = dist
                            bestTarget   = bone
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    RunService.RenderStepped:Connect(function()
        if closed() then return end
        fov.Update()

        if config.AimbotEnabled then
            local target = getTarget()
            if target and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local screenPos = Camera:WorldToViewportPoint(target.Position)
                local vp        = Camera.ViewportSize
                local centerX   = vp.X / 2
                local centerY   = vp.Y / 2
                -- delta nga qendra e screen drejt target
                local dx = screenPos.X - centerX
                local dy = screenPos.Y - centerY
                local factor = math.clamp(config.Sensitivity / 100, 0.05, 1)
                -- lëviz mouse-in gradualisht drejt target
                mousemoverel(dx * factor, dy * factor)
            end
        end
    end)
end

return Build
