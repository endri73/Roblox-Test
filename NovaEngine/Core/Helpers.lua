local function Build(theme)
    local H = {}

    function H.Create(className, props, parent)
        local obj = Instance.new(className)
        for k, v in pairs(props or {}) do obj[k] = v end
        obj.Parent = parent
        return obj
    end

    function H.Corner(parent, radius)
        H.Create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
    end

    function H.Stroke(parent, color, transparency)
        return H.Create("UIStroke", {
            Color        = color or theme.Accent,
            Thickness    = 1,
            Transparency = transparency or 0.7,
        }, parent)
    end

    function H.Pad(parent, amount)
        H.Create("UIPadding", {
            PaddingLeft   = UDim.new(0, amount),
            PaddingRight  = UDim.new(0, amount),
            PaddingTop    = UDim.new(0, amount),
            PaddingBottom = UDim.new(0, amount),
        }, parent)
    end

    function H.Tween(config, tweenService)
        return function(obj, props, duration)
            if not config.UIAnimations or config.PerformanceMode then
                for k, v in pairs(props) do obj[k] = v end
                return
            end
            tweenService:Create(
                obj,
                TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                props
            ):Play()
        end
    end

    function H.AddLabel(parent, text, position, size, textSize, color, theme2)
        return H.Create("TextLabel", {
            Position         = position,
            Size             = size,
            BackgroundTransparency = 1,
            Text             = text,
            TextColor3       = color or (theme2 or theme).White,
            TextSize         = textSize or 15,
            Font             = Enum.Font.GothamSemibold,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, parent)
    end

    function H.CreateCard(parent, height, theme2)
        local t = theme2 or theme
        local card = H.Create("Frame", {
            Size             = UDim2.new(1, -8, 0, height or 60),
            BackgroundColor3 = t.Card,
            BorderSizePixel  = 0,
        }, parent)
        H.Corner(card, 12)
        return card
    end

    return H
end

return Build