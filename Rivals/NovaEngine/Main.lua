-- Main.lua — versioni për executor, pa script.Parent, pa require
return function(deps)
    local Config              = deps.Config
    local AimbotLogic         = deps.AimbotLogic
    local FOVLogic            = deps.FOVLogic
    local MarkersLogic        = deps.MarkersLogic
    local DistanceLogic       = deps.DistanceLogic
    local DisplayRangeLogic   = deps.DisplayRangeLogic
    local InterfaceScaleLogic = deps.InterfaceScaleLogic

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local Camera = workspace.CurrentCamera

    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = UDim2.fromScale(0.82, 0.78)
    main.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    main.BorderSizePixel = 0
    main.Parent = gui

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = InterfaceScaleLogic.GetScale(Config.InterfaceScale)
    uiScale.Parent = main

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Config.ToggleKey then
            main.Visible = not main.Visible
        end
    end)

    RunService.RenderStepped:Connect(function()
        FOVLogic.Update(Config, main.Visible)
        AimbotLogic.Step(Config)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                local cam = workspace.CurrentCamera
                local dist = DistanceLogic.Calculate(cam, char.HumanoidRootPart.Position)
                local inRange = DisplayRangeLogic.IsInRange(dist, Config.DisplayRange)
                MarkersLogic.ApplyHighlight(char, Config.ShowMarkers and inRange, Config.MarkerColor)
            end
        end
    end)
end
