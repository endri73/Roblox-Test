--!nonstrict
-- NovaEngine/UI/NovaUI.lua
-- Klient: dritare kryesore, sidebar me tabs, draggable, animacione.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local THEME = {
	Background = Color3.fromRGB(17, 17, 21),
	Surface    = Color3.fromRGB(26, 26, 32),
	Sidebar    = Color3.fromRGB(21, 21, 26),
	Accent     = Color3.fromRGB(0, 229, 255),
	Text       = Color3.fromRGB(236, 236, 245),
	Muted      = Color3.fromRGB(138, 138, 154),
	Stroke     = Color3.fromRGB(46, 46, 58),
	Track      = Color3.fromRGB(50, 50, 62),
}

local NovaUI = {}
NovaUI.__index = NovaUI

local function new(class, props)
	local inst = Instance.new(class)
	for key, value in pairs(props or {}) do
		(inst :: any)[key] = value
	end
	return inst
end

local function tween(instance, props, duration, style, direction)
	local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

local function createToggle(parent, text, default, order, callback)
	local row = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = THEME.Surface,
		BackgroundTransparency = 0.35,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
	})
	row.Parent = parent
	new("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row

	local label = new("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = THEME.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local track = new("Frame", {
		Size = UDim2.fromOffset(36, 18),
		Position = UDim2.new(1, -48, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = THEME.Track,
		BorderSizePixel = 0,
	})
	track.Parent = row
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = THEME.Text,
		BorderSizePixel = 0,
	})
	knob.Parent = track
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = knob

	local state = default and true or false
	local function apply(animate)
		local targetX = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
		local targetColor = state and THEME.Accent or THEME.Track
		if animate then
			tween(knob, { Position = targetX }, 0.18)
			tween(track, { BackgroundColor3 = targetColor }, 0.18)
		else
			knob.Position = targetX
			track.BackgroundColor3 = targetColor
		end
	end
	apply(false)

	row.Activated:Connect(function()
		state = not state
		apply(true)
		if callback then callback(state) end
	end)

	return row
end

local function createSlider(parent, text, minValue, maxValue, default, order, callback)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = THEME.Surface,
		BackgroundTransparency = 0.35,
		LayoutOrder = order,
	})
	row.Parent = parent
	new("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row

	local label = new("TextLabel", {
		Size = UDim2.new(1, -80, 0, 22),
		Position = UDim2.fromOffset(12, 4),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = THEME.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local valueLabel = new("TextLabel", {
		Size = UDim2.fromOffset(56, 22),
		Position = UDim2.new(1, -68, 0, 4),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = tostring(default),
		TextColor3 = THEME.Accent,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	valueLabel.Parent = row

	local track = new("Frame", {
		Size = UDim2.new(1, -24, 0, 6),
		Position = UDim2.fromOffset(12, 32),
		BackgroundColor3 = THEME.Track,
		BorderSizePixel = 0,
	})
	track.Parent = row
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = new("Frame", {
		Size = UDim2.fromScale((default - minValue) / (maxValue - minValue), 1),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
	})
	fill.Parent = track
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill

	local dragging = false
	local function setFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(minValue + (maxValue - minValue) * rel + 0.5)
		fill.Size = UDim2.fromScale(rel, 1)
		valueLabel.Text = tostring(value)
		if callback then callback(value) end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return row
end

function NovaUI.new(config)
	local self = setmetatable({}, NovaUI)
	self._config = config or {}
	self._pages = {}
	self._tabs = {}
	self._activeTab = nil

	local gui = new("ScreenGui", {
		Name = "NovaUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 50,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local shadow = new("Frame", {
		Name = "Shadow",
		Size = UDim2.fromOffset(556, 396),
		Position = UDim2.new(0.5, 0, 0.5, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 1,
	})
	shadow.Parent = gui
	new("UICorner", { CornerRadius = UDim.new(0, 14) }).Parent = shadow
	self.Shadow = shadow

	local window = new("CanvasGroup", {
		Name = "Window",
		Size = UDim2.fromOffset(540, 380),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ZIndex = 2,
	})
	window.Parent = gui
	self.Window = window
	new("UICorner", { CornerRadius = UDim.new(0, 12) }).Parent = window
	new("UIStroke", {
		Color = THEME.Stroke,
		Thickness = 1,
		Transparency = 0.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}).Parent = window

	local header = new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})
	header.Parent = window

	local title = new("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -56, 1, 0),
		Position = UDim2.fromOffset(18, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "NOVA",
		TextColor3 = THEME.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	})
	title.Parent = header

	local close = new("TextButton", {
		Name = "Close",
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.new(1, -38, 0, 8),
		BackgroundColor3 = THEME.Surface,
		BackgroundTransparency = 1,
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = THEME.Muted,
		AutoButtonColor = false,
		ZIndex = 5,
	})
	close.Parent = header
	new("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = close

	close.MouseEnter:Connect(function()
		tween(close, { BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 90, 90) }, 0.15)
	end)
	close.MouseLeave:Connect(function()
		tween(close, { BackgroundTransparency = 1, TextColor3 = THEME.Muted }, 0.15)
	end)
	close.Activated:Connect(function()
		self:Close()
	end)

	local sidebar = new("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 152, 1, -56),
		Position = UDim2.fromOffset(10, 48),
		BackgroundColor3 = THEME.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	sidebar.Parent = window
	new("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = sidebar
	new("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}).Parent = sidebar
	new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}).Parent = sidebar

	local content = new("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -172, 1, -56),
		Position = UDim2.fromOffset(162, 48),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})
	content.Parent = window
	self.Content = content

	local tabDefs = {
		{ id = "general", label = "General", icon = "◆" },
		{ id = "combat", label = "Combat", icon = "⚔" },
		{ id = "settings", label = "Settings", icon = "⚙" },
	}

	for order, def in ipairs(tabDefs) do
		local button = new("TextButton", {
			Name = def.id,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = THEME.Surface,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 4,
		})
		button.Parent = sidebar
		new("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = button

		local icon = new("TextLabel", {
			Name = "Icon",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = def.icon,
			TextColor3 = THEME.Muted,
			TextSize = 14,
			ZIndex = 5,
		})
		icon.Parent = button

		local label = new("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.fromOffset(38, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = def.label,
			TextColor3 = THEME.Muted,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
		})
		label.Parent = button

		local indicator = new("Frame", {
			Name = "Indicator",
			Size = UDim2.new(0, 3, 0, 18),
			Position = UDim2.new(0, -8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = THEME.Accent,
			BorderSizePixel = 0,
			ZIndex = 5,
			Visible = false,
		})
		indicator.Parent = button
		new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = indicator

		local page = new("CanvasGroup", {
			Name = def.id .. "Page",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Visible = false,
			ZIndex = 3,
		})
		page.Parent = content
		new("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 6),
		}).Parent = page
		new("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}).Parent = page
		self._pages[def.id] = page

		button.Activated:Connect(function()
			self:SelectTab(def.id)
		end)
		button.MouseEnter:Connect(function()
			if self._activeTab ~= def.id then
				tween(button, { BackgroundTransparency = 0 }, 0.15)
			end
		end)
		button.MouseLeave:Connect(function()
			if self._activeTab ~= def.id then
				tween(button, { BackgroundTransparency = 1 }, 0.15)
			end
		end)

		self._tabs[def.id] = { button = button, icon = icon, label = label, indicator = indicator }
	end

	local onToggle = self._config.onToggle
	local onSlider = self._config.onSlider

	createToggle(self._pages.general, "Streamer Mode", false, 1, function(state)
		if onToggle then onToggle("streamer", state) end
	end)
	createToggle(self._pages.general, "Auto Execute", true, 2, function(state)
		if onToggle then onToggle("autoexecute", state) end
	end)
	createSlider(self._pages.general, "UI Scale", 50, 150, 100, 3, function(value)
		if onSlider then onSlider("uiscale", value) end
	end)

	createToggle(self._pages.combat, "Aimbot", false, 1, function(state)
		if onToggle then onToggle("aimbot", state) end
	end)
	createSlider(self._pages.combat, "FOV Radius", 40, 400, 120, 2, function(value)
		if onSlider then onSlider("fov", value) end
	end)
	createToggle(self._pages.combat, "ESP Markers", false, 3, function(state)
		if onToggle then onToggle("esp", state) end
	end)

	createToggle(self._pages.settings, "Dark Mode", true, 1, function(state)
		if onToggle then onToggle("darkmode", state) end
	end)
	createSlider(self._pages.settings, "Window Opacity", 30, 100, 100, 2, function(value)
		if onSlider then onSlider("opacity", value) end
	end)

	-- Draggable
	local dragging = false
	local dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			shadow.Position = UDim2.new(window.Position.X.Scale, window.Position.X.Offset, window.Position.Y.Scale, window.Position.Y.Offset + 10)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	self:SelectTab("general")
	self:Open()

	return self
end

function NovaUI:SelectTab(id)
	if self._activeTab == id then
		return
	end
	self._activeTab = id

	for tabId, parts in pairs(self._tabs) do
		local active = tabId == id
		tween(parts.button, { BackgroundTransparency = active and 0 or 1 }, 0.2)
		tween(parts.icon, { TextColor3 = active and THEME.Accent or THEME.Muted }, 0.2)
		tween(parts.label, { TextColor3 = active and THEME.Text or THEME.Muted }, 0.2)
		parts.indicator.Visible = active
	end

	for pageId, page in pairs(self._pages) do
		if pageId == id then
			page.Visible = true
			page.GroupTransparency = 1
			tween(page, { GroupTransparency = 0 }, 0.2)
		else
			page.Visible = false
		end
	end
end

function NovaUI:Open()
	self.Gui.Enabled = true
	self.Window.GroupTransparency = 1
	self.Window.Size = UDim2.fromOffset(460, 324)
	self.Shadow.BackgroundTransparency = 1
	self.Shadow.Size = UDim2.fromOffset(480, 340)
	tween(self.Window, { GroupTransparency = 0, Size = UDim2.fromOffset(540, 380) }, 0.28)
	tween(self.Shadow, { BackgroundTransparency = 0.55, Size = UDim2.fromOffset(556, 396) }, 0.28)
end

function NovaUI:Close()
	local t = tween(self.Window, { GroupTransparency = 1, Size = UDim2.fromOffset(460, 324) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(self.Shadow, { BackgroundTransparency = 1, Size = UDim2.fromOffset(480, 340) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	t.Completed:Once(function()
		self.Gui.Enabled = false
	end)
end

function NovaUI:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return NovaUI
