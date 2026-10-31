local Camera = workspace.CurrentCamera

local function GetDist(hrp)
    return (hrp.Position - Camera.CFrame.Position).Magnitude
end

local function FormatLabel(p, dist, config)
    local text = ""
    if config.ShowNames then
        text = p.DisplayName
    end
    if config.ShowDistance then
        local suffix = math.floor(dist) .. "m"
        text = text ~= "" and (text .. " [" .. suffix .. "]") or suffix
    end
    return text
end

return { GetDist = GetDist, FormatLabel = FormatLabel }