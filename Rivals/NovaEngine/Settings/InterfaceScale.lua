local scales = { Small = 0.75, Medium = 0.9, Big = 1.05 }

local function Build(uiScale, tween)
    return function(value)
        tween(uiScale, { Scale = scales[value] or 0.9 }, 0.2)
    end
end

return Build
