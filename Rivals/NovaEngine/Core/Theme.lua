local function Build(config)
    return {
        Background = Color3.fromRGB(13, 13, 17),
        Sidebar    = Color3.fromRGB(18, 18, 25),
        Card       = Color3.fromRGB(22, 22, 31),
        CardHover  = Color3.fromRGB(31, 29, 45),
        Accent     = config.ThemeAccent,
        White      = Color3.fromRGB(255, 255, 255),
        Muted      = Color3.fromRGB(160, 160, 176),
    }
end

return Build