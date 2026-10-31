local function Build(H, theme, tween, main, gui, controls, fovCircle, config, espCache, Lines, Skeleton)
    local overlay = H.Create("Frame", {
        Name                   = "CloseWarning",
        Size                   = UDim2.fromScale(1, 1),
        BackgroundColor3       = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35,
        Visible                = false,
        ZIndex                 = 20,
    }, main)
    H.Corner(overlay, 18)

    local modal = H.Create("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.fromScale(0.5, 0.5),
        Size             = UDim2.new(0.82, 0, 0, 190),
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
        ZIndex           = 21,
    }, overlay)
    H.Corner(modal, 14)
    H.Stroke(modal, theme.Accent, 0.45)

    H.Create("TextLabel", {
        Position               = UDim2.new(0,18,0,16),
        Size                   = UDim2.new(1,-36,0,28),
        BackgroundTransparency = 1,
        Text                   = "WARNING!",
        TextColor3             = theme.White,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 20,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 22,
    }, modal)

    H.Create("TextLabel", {
        Position               = UDim2.new(0,18,0,50),
        Size                   = UDim2.new(1,-36,0,65),
        BackgroundTransparency = 1,
        Text                   = "If you close NOVA, all active options will be turned off. To use it again, you must run the script from the beginning.",
        TextColor3             = theme.Muted,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextWrapped            = true,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Top,
        ZIndex                 = 22,
    }, modal)

    local cancelBtn = H.Create("TextButton", {
        Position        = UDim2.new(0,18,1,-48),
        Size            = UDim2.new(0.46,-8,0,32),
        BackgroundColor3 = Color3.fromRGB(48,47,59),
        Text            = "Cancel",
        TextColor3      = theme.White,
        Font            = Enum.Font.GothamSemibold,
        TextSize        = 14,
        ZIndex          = 22,
    }, modal)
    H.Corner(cancelBtn, 8)

    local confirmBtn = H.Create("TextButton", {
        Position        = UDim2.new(0.54,0,1,-48),
        Size            = UDim2.new(0.46,-18,0,32),
        BackgroundColor3 = Color3.fromRGB(190,65,80),
        Text            = "Close NOVA",
        TextColor3      = theme.White,
        Font            = Enum.Font.GothamSemibold,
        TextSize        = 14,
        ZIndex          = 22,
    }, modal)
    H.Corner(confirmBtn, 8)

    local closed = false

    local function shutdownESP()
        -- fik të gjithë Drawing objects
        pcall(function() fovCircle.Visible = false end)
        if Lines    then Lines.CleanupAll()    end
        if Skeleton then Skeleton.CleanupAll() end
        -- fik highlights dhe billboards
        if espCache then
            for _, esp in pairs(espCache) do
                pcall(function()
                    esp.Highlight.Enabled  = false
                    esp.Highlight.Parent   = nil
                    esp.NameLabel.Visible  = false
                    esp.Billboard.Parent   = nil
                end)
            end
        end
    end

    local function animateClose(onComplete)
        if closed then return end
        closed = true
        shutdownESP()
        if config.UIAnimations and not config.PerformanceMode then
            tween(main, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.25)
            task.delay(0.25, function()
                if onComplete then onComplete() end
            end)
        else
            if onComplete then onComplete() end
        end
    end

    cancelBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
    end)

    confirmBtn.MouseButton1Click:Connect(function()
        animateClose(function()
            for _, ctrl in pairs(controls) do
                if ctrl.Cleanup then ctrl.Cleanup() end
            end
            gui:Destroy()
        end)
    end)

    return {
        overlay     = overlay,
        closed      = function() return closed end,
        showWarning = function() if not closed then overlay.Visible = true end end,
    }
end

return Build