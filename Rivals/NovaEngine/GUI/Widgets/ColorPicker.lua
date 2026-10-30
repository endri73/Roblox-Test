local palette = {
    Color3.fromRGB(108, 92,  231),
    Color3.fromRGB(0,   210, 255),
    Color3.fromRGB(255, 90,  140),
    Color3.fromRGB(72,  211, 151),
    Color3.fromRGB(255, 190, 80),
}

local function Build(H, theme, tween, gui)
    local function ApplyAccent(color, mainStroke, logo, fovCircle, pages)
        theme.Accent     = color
        mainStroke.Color = color
        logo.BackgroundColor3 = color
        fovCircle.Color  = color
        for _, page in pairs(pages) do
            page.ScrollBarImageColor3 = color
        end
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("Frame") and (desc.Name == "Indicator" or desc.Name == "Fill") then
                desc.BackgroundColor3 = color
            elseif desc:IsA("TextLabel") and desc.TextColor3 == Color3.fromRGB(108, 92, 231) then
                desc.TextColor3 = color
            end
        end
    end

    local function CreateColorPicker(parent, title, configKey, config, onChanged)
        local card = H.CreateCard(parent, 60)
        H.AddLabel(card, title, UDim2.new(0, 15, 0, 0), UDim2.new(0.6, 0, 1, 0), 15, theme.White, theme)

        local index   = 1
        local preview = H.Create("TextButton", {
            Position         = UDim2.new(1, -53, 0.5, -15),
            Size             = UDim2.fromOffset(34, 30),
            BackgroundColor3 = palette[index],
            Text             = "",
            AutoButtonColor  = false,
        }, card)
        H.Corner(preview, 8)

        local function set(colorIndex)
            index             = ((colorIndex - 1) % #palette) + 1
            tween(preview, { BackgroundColor3 = palette[index] })
            config[configKey] = palette[index]
            if onChanged then onChanged(palette[index]) end
        end

        preview.MouseButton1Click:Connect(function() set(index % #palette + 1) end)
        return { Get = function() return palette[index] end, Set = set }
    end

    return CreateColorPicker, ApplyAccent
end

return Build