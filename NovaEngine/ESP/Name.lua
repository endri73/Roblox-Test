--!nonstrict
-- NovaEngine/ESP/Name.lua
-- Show Names: player name above the box.

local Name = {}
Name.__index = Name

function Name.new(gui, shared, config)
	local self = setmetatable({}, Name)
	self._gui = gui
	self._shared = shared
	self._config = config
	self._items = {}
	return self
end

function Name:_item(player)
	local item = self._items[player]
	if item then
		return item
	end

	local label = self._shared.create("TextLabel", {
		Name = "Name",
		Size = UDim2.fromOffset(220, 18),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Font = self._shared.FONT_BOLD,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextStrokeTransparency = 0.35,
		Visible = false,
	})
	label.Parent = self._gui

	item = { label = label }
	self._items[player] = item
	return item
end

function Name:Update(player, ctx)
	if not ctx then
		self:Hide(player)
		return
	end

	local item = self:_item(player)
	item.label.Position = UDim2.fromOffset(ctx.top.X, ctx.top.Y - 3)
	item.label.Text = player.Name
	item.label.Visible = true
end

function Name:Hide(player)
	local item = self._items[player]
	if item then
		item.label.Visible = false
	end
end

function Name:SetColor(color)
	for _, item in pairs(self._items) do
		item.label.TextColor3 = color
	end
end

function Name:Remove(player)
	local item = self._items[player]
	if item then
		item.label:Destroy()
		self._items[player] = nil
	end
end

function Name:Destroy()
	for _, item in pairs(self._items) do
		item.label:Destroy()
	end
	self._items = {}
end

return Name
