local function Apply(esp, config)
    esp.Highlight.Enabled      = config.ShowMarkers
    esp.Highlight.FillColor    = config.MarkerColor
    esp.Highlight.OutlineColor = config.MarkerColor
end

local function CreateHighlight(char)
    local h               = Instance.new("Highlight")
    h.FillTransparency    = 0.5
    h.OutlineTransparency = 0
    h.Parent              = char
    return h
end

return { Apply = Apply, CreateHighlight = CreateHighlight }
