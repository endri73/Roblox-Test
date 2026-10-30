local Players = game:GetService("Players")

local function Build(H, theme, sideContent)
    local player  = Players.LocalPlayer

    local profile = H.Create("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = theme.Card,
        BorderSizePixel  = 0,
    }, sideContent)
    H.Corner(profile, 10)

    local avatar = H.Create("ImageLabel", {
        Position         = UDim2.new(0, 8, 0.5, -17),
        Size             = UDim2.fromOffset(34, 34),
        BackgroundColor3 = theme.CardHover,
        Image            = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
    }, profile)
    H.Corner(avatar, 50)

    H.AddLabel(profile, player.DisplayName,
        UDim2.new(0, 49, 0, 8), UDim2.new(1, -55, 0, 18), 13, theme.White, theme)

    local roleLabel = H.AddLabel(profile, "NOVA User",
        UDim2.new(0, 49, 0, 26), UDim2.new(1, -55, 0, 15), 11, theme.Muted, theme)
    roleLabel.Font = Enum.Font.Gotham
end

return Build