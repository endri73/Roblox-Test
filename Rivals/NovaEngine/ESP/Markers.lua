local MarkersModule = {}

function MarkersModule.ApplyHighlight(character, enabled, color)
    local highlight = character:FindFirstChildOfClass("Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Parent = character
    end
    highlight.Enabled = enabled
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end

return MarkersModule