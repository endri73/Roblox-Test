--[=[
    NovaEngine Main — executor version
    Nuk përdor script.Parent, nuk përdor require().
    Merret si string nga loaderi, ekzekutohet me loadstring.
    Kthen funksion që pranon deps dhe ndërton GUI-n + loop-in.
]=]

return function(deps)
    assert(type(deps) == "table", "main.lua: deps table mungon")

    local Config              = assert(deps.Config, "Config mungon")
    local AimbotLogic         = assert(deps.AimbotLogic, "AimbotLogic mungon")
    local FOVLogic            = assert(deps.FOVLogic, "FOVLogic mungon")
    local MarkersLogic        = assert(deps.MarkersLogic, "MarkersLogic mungon")
    local DistanceLogic       = assert(deps.DistanceLogic, "DistanceLogic mungon")
    local DisplayRangeLogic   = assert(deps.DisplayRangeLogic, "DisplayRangeLogic mungon")
    local InterfaceScaleLogic = assert(deps.InterfaceScaleLogic, "InterfaceScaleLogic mungon")

    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService       = game:GetService("RunService")

    local LocalPlayer = Players.LocalPlayer
    local playerGui   = LocalPlayer:WaitForChild("PlayerGui")

    -- pastro GUI të vjetër nëse ekzekutohet dy herë
    local old = playerGui:FindFirstChild("NovaUI")
    if old then old:Destroy() end

    -- ===== GUI kryesor =====
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = UDim2.fromScale(0.82, 0.78)
    main.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Visible = true
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.ThemeAccent
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 16, 0, 10)
    title.Size = UDim2.new(1, -32, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.Text = "NOVA ENGINE"
    title.TextColor3 = Config.ThemeAccent
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 16, 0, 44)
    body.Size = UDim2.new(1, -32, 1, -60)
    body.Font = Enum.Font.Gotham
    body.Text = "Nova Engine aktiv.\nRightShift për të hapur/mbyllur."
    body.TextColor3 = Color3.fromRGB(200, 200, 210)
    body.TextSize = 14
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextWrapped = true
    body.Parent = main

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = InterfaceScaleLogic.GetScale(Config.InterfaceScale)
    uiScale.Parent = main

    -- ===== toggle key =====
    local toggleConn
    toggleConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Config.ToggleKey then
            main.Visible = not main.Visible
        end
    end)

    -- ===== main loop =====
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        -- sigurohemi që GUI ekziston ende
        if not gui.Parent then
            if renderConn then renderConn:Disconnect() end
            if toggleConn then toggleConn:Disconnect() end
            return
        end

        -- FOV update vetëm kur GUI i dukshëm
        pcall(function()
            FOVLogic.Update(Config, main.Visible)
        end)

        -- Aimbot step
        pcall(function()
            AimbotLogic.Step(Config)
        end)

        -- ESP për çdo lojtar
        local cam = workspace.CurrentCamera
        if cam then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local ok, err = pcall(function()
                            local dist = DistanceLogic.Calculate(cam, hrp.Position)
                            local inRange = DisplayRangeLogic.IsInRange(dist, Config.DisplayRange)
                            local shouldShow = Config.ShowMarkers and inRange
                            MarkersLogic.ApplyHighlight(char, shouldShow, Config.MarkerColor)
                        end)
                        if not ok then
                            -- heshtur; mos e mbush konsolën çdo frame
                        end
                    else
                        MarkersLogic.ApplyHighlight(char, false, Config.MarkerColor)
                    end
                end
            end
        end
    end)

    -- ===== cleanup automatik kur lojtari largohet / respawn =====
    LocalPlayer.OnTeleport:Connect(function()
        if renderConn then renderConn:Disconnect() end
        if toggleConn then toggleConn:Disconnect() end
        pcall(function() FOVLogic.Destroy() end)
        gui:Destroy()
    end)

    -- kthe handle nëse do t'i përdorësh jashtë
    return {
        Gui = gui,
        Main = main,
        Disconnect = function()
            if renderConn then renderConn:Disconnect() end
            if toggleConn then toggleConn:Disconnect() end
            pcall(function() FOVLogic.Destroy() end)
            gui:Destroy()
        end,
    }
end
