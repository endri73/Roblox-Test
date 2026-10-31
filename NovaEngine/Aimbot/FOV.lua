local UIS    = game:GetService("UserInputService")

local function Build(config)
    local circle      = Drawing.new("Circle")
    circle.Visible    = false
    circle.Transparency = 0.7
    circle.Thickness  = 1.5
    circle.Color      = config.AimbotAccent
    circle.Filled     = false

    local function Update(mainVisible)
        if not config.AimbotEnabled then
            circle.Visible = false
            return
        end
        circle.Position = UIS:GetMouseLocation()
        circle.Radius   = config.FieldOfView
        circle.Color    = config.AimbotAccent
        circle.Visible  = mainVisible
    end

    local function Destroy()
        pcall(function() circle:Remove() end)
    end

    return { Update = Update, Destroy = Destroy, Raw = circle }
end

return Build