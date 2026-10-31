--!nonstrict
-- NovaEngine/ESP/Lines.lua
-- Show Lines: bottom-center of the screen to the target's feet.

local Lines = {}
Lines.__index = Lines

function Lines.new(gui, shared, config)
	local self = setmetatable({}, Lines)
	self._gui = gui
	self._shared = shared
	self._config = config
	self._items = {}
	return self
end

function Lines:_item(player)
	local item = self._items[player]
	if item then
		return item
	end

	local frame = self._shared.create("Frame", {
		Name = "Line",
		BackgroundColor3 = self._config.Color,
		BorderSizePixel = 0,
		Visible = false,
	})
	frame.Parent = self._gui

	item = { frame = frame }
	self._items[player] = item
	return item
end

function Lines:Update(player, ctx)
	if not ctx then
		self:Hide(player)
		return
	end

	local item = self:_item(player)
	local viewport = ctx.camera.ViewportSize
	local from = Vector2.new(viewport.X / 2, viewport.Y)
	local to = Vector2.new(ctx.top.X, ctx.top.Y + ctx.height)
	self._shared.setLine(item.frame, from, to, ctx.color, 1)
end

function Lines:Hide(player)
	local item = self._items[player]
	if item then
		item.frame.Visible = false
	end
end

function Lines:SetColor(color)
	for _, item in pairs(self._items) do
		item.frame.BackgroundColor3 = color
	end
end

function Lines:Remove(player)
	local item = self._items[player]
	if item then
		item.frame:Destroy()
		self._items[player] = nil
	end
end

function Lines:Destroy()
	for _, item in pairs(self._items) do
		item.frame:Destroy()
	end
	self._items = {}
end

return Lines
