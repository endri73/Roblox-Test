--!nonstrict
-- NovaEngine/ESP/Box.lua
-- Show Markers: the bounding box around each player.

local Box = {}
Box.__index = Box

function Box.new(gui, shared, config)
	local self = setmetatable({}, Box)
	self._gui = gui
	self._shared = shared
	self._config = config
	self._items = {}
	return self
end

function Box:_item(player)
	local item = self._items[player]
	if item then
		return item
	end

	local frame = self._shared.create("Frame", {
		Name = "Box",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
	})
	frame.Parent = self._gui

	local stroke = self._shared.create("UIStroke", {
		Color = self._config.Color,
		Thickness = 1,
		Transparency = 0.1,
	})
	stroke.Parent = frame

	item = { frame = frame, stroke = stroke }
	self._items[player] = item
	return item
end

function Box:Update(player, ctx)
	if not ctx then
		self:Hide(player)
		return
	end

	local item = self:_item(player)
	item.frame.Position = UDim2.fromOffset(ctx.top.X - ctx.width / 2, ctx.top.Y)
	item.frame.Size = UDim2.fromOffset(ctx.width, ctx.height)
	item.stroke.Color = ctx.color
	item.frame.Visible = true
end

function Box:Hide(player)
	local item = self._items[player]
	if item then
		item.frame.Visible = false
	end
end

function Box:SetColor(color)
	for _, item in pairs(self._items) do
		item.stroke.Color = color
	end
end

function Box:Remove(player)
	local item = self._items[player]
	if item then
		item.frame:Destroy()
		self._items[player] = nil
	end
end

function Box:Destroy()
	for _, item in pairs(self._items) do
		item.frame:Destroy()
	end
	self._items = {}
end

return Box
