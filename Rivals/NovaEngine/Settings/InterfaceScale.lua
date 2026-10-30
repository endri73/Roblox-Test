local InterfaceScaleModule = {}

local scales = {
    Smaller = 0.75,
    Small = 0.9,
    Medium = 1.05,
}

function InterfaceScaleModule.GetScale(scaleName)
    return scales[scaleName] or 1.05
end

return InterfaceScaleModule