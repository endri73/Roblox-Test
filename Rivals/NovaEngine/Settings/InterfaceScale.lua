local scales = { Smaller = 0.75, Small = 0.9, Medium = 1.05 }

local function Build(uiScale, tween)
    return function(value)
        tween(uiScale, { Scale = scales[value] or 1 }, 0.2)
    end
end

return Build