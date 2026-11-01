--!nonstrict
-- NovaEngine/ESP/Distance.lua
-- Show Distance: meters below the box.

local Distance = {}
Distance.__index = Distance

function Distance.new(gui, shared, config)
	local self = setmetatable({}, Distance)
	self._gui = gui
	self._shared = shared
	self._config = config
	self._items = {}
	return self
end

function Distance:_item(player)
	local item = self._items[player]
	if item then
		return item
	end

	local label = self._shared.create("TextLabel", {
		Name = "Distance",
		Size = UDim2.fromOffset(220, 16),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = self._shared.FONT,
		Text = "",
		TextColor3 = self._config.Color,
		TextSize = 13,
		TextStrokeTransparency = 0.4,
		Visible = false,
	})
	label.Parent = self._gui

	item = { label = label }
	self._items[player] = item
	return item
end

function Distance:Update(player, ctx)
	if not ctx then
		self:Hide(player)
		return
	end

	local item = self:_item(player)
	item.label.Position = UDim2.fromOffset(ctx.top.X, ctx.top.Y + ctx.height + 2)
	item.label.Text = tostring(math.floor(ctx.distance)) .. "m"
	item.label.TextColor3 = ctx.color
	item.label.Visible = true
end

function Distance:Hide(player)
	local item = self._items[player]
	if item then
		item.label.Visible = false
	end
end

function Distance:SetColor(color)
	for _, item in pairs(self._items) do
		item.label.TextColor3 = color
	end
end

function Distance:Remove(player)
	local item = self._items[player]
	if item then
		item.label:Destroy()
		self._items[player] = nil
	end
end

function Distance:Destroy()
	for _, item in pairs(self._items) do
		item.label:Destroy()
	end
	self._items = {}
end

return Distance
