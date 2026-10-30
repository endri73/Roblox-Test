local Camera = workspace.CurrentCamera

local function Build()
    local lines = {}

    local function GetOrCreate(player)
        if not lines[player] then
            local line       = Drawing.new("Line")
            line.Thickness   = 1
            line.Color       = Color3.fromRGB(108, 92, 231)
            line.Transparency = 0.2
            line.Visible     = false
            lines[player]    = line
        end
        return lines[player]
    end

    local function Update(player, hrp, config, inRange)
        local line = GetOrCreate(player)
        if not config.ShowLines or not inRange then
            line.Visible = false
            return
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            line.Visible = false
            return
        end
        local vp       = Camera.ViewportSize
        line.From      = Vector2.new(vp.X / 2, vp.Y)  -- fund i screen
        line.To        = Vector2.new(screenPos.X, screenPos.Y)
        line.Color     = config.LineColor
        line.Visible   = true
    end

    local function Hide(player)
        if lines[player] then
            lines[player].Visible = false
        end
    end

    local function Cleanup(player)
        if lines[player] then
            pcall(function() lines[player]:Remove() end)
            lines[player] = nil
        end
    end

    local function CleanupAll()
        for p, line in pairs(lines) do
            pcall(function() line:Remove() end)
        end
        lines = {}
    end

    return {
        Update     = Update,
        Hide       = Hide,
        Cleanup    = Cleanup,
        CleanupAll = CleanupAll,
    }
end

return Build