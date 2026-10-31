--!nonstrict
-- NovaEngine/UI/NovaUI.lua
-- Clean dark UI: Aimbot, Combat (ESP), Settings.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
	Background = Color3.fromRGB(14, 14, 18),
	Surface = Color3.fromRGB(23, 23, 29),
	SurfaceAlt = Color3.fromRGB(30, 30, 38),
	Sidebar = Color3.fromRGB(18, 18, 23),
	Accent = Color3.fromRGB(126, 94, 255),
	Accent2 = Color3.fromRGB(0, 205, 255),
	Text = Color3.fromRGB(240, 240, 248),
	Muted = Color3.fromRGB(138, 138, 156),
	Stroke = Color3.fromRGB(44, 44, 56),
	Track = Color3.fromRGB(44, 44, 56),
	Danger = Color3.fromRGB(255, 92, 92),
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local NovaUI = {}
NovaUI.__index = NovaUI

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		(inst :: any)[k] = v
	end
	return inst
end

local function tween(obj, props, duration, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local activePopup = nil

local function closePopup()
	if activePopup then
		if activePopup.backdrop then activePopup.backdrop:Destroy() end
		if activePopup.popup then activePopup.popup:Destroy() end
		activePopup = nil
	end
end

local function createToggle(parent, text, default, order, callback)
	local row = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
	})
	row.Parent = parent
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row
	local rowStroke = create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.65 })
	rowStroke.Parent = row

	local label = create("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local track = create("Frame", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -52, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
	})
	track.Parent = row
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local knob = create("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = Color3.fromRGB(245, 245, 250),
		BorderSizePixel = 0,
	})
	knob.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = knob

	local state = default and true or false
	local function apply(animate)
		local targetX = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		local targetColor = state and Theme.Accent or Theme.Track
		if animate then
			tween(knob, { Position = targetX }, 0.18)
			tween(track, { BackgroundColor3 = targetColor }, 0.18)
		else
			knob.Position = targetX
			track.BackgroundColor3 = targetColor
		end
	end
	apply(false)

	row.MouseEnter:Connect(function()
		tween(row, { BackgroundTransparency = 0.55 }, 0.15)
		tween(rowStroke, { Transparency = 0.4 }, 0.15)
	end)
	row.MouseLeave:Connect(function()
		tween(row, { BackgroundTransparency = 1 }, 0.15)
		tween(rowStroke, { Transparency = 0.65 }, 0.15)
	end)

	row.Activated:Connect(function()
		state = not state
		apply(true)
		if callback then callback(state) end
	end)

	return row
end

local function createSlider(parent, text, minValue, maxValue, default, order, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.35,
		LayoutOrder = order,
	})
	row.Parent = parent
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row

	local label = create("TextLabel", {
		Size = UDim2.new(1, -90, 0, 24),
		Position = UDim2.fromOffset(14, 5),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local valueLabel = create("TextLabel", {
		Size = UDim2.fromOffset(64, 24),
		Position = UDim2.new(1, -78, 0, 5),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = tostring(default),
		TextColor3 = Theme.Accent,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	valueLabel.Parent = row

	local track = create("Frame", {
		Size = UDim2.new(1, -28, 0, 6),
		Position = UDim2.fromOffset(14, 36),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
	})
	track.Parent = row
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = create("Frame", {
		Size = UDim2.fromScale(math.clamp((default - minValue) / (maxValue - minValue), 0, 1), 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	})
	fill.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill

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

local function createCollapsible(parent, order, height)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = order,
	})
	holder.Parent = parent

	return {
		holder = holder,
		setOpen = function(open)
			tween(holder, { Size = UDim2.new(1, 0, 0, open and (height or 56) or 0) }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end,
	}
end

local function createSegmented(parent, text, options, default, order, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	})
	row.Parent = parent
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row
	local rowStroke = create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.65 })
	rowStroke.Parent = row

	local label = create("TextLabel", {
		Size = UDim2.new(1, -210, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local container = create("Frame", {
		Size = UDim2.fromOffset(190, 34),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
	})
	container.Parent = row
	create("UICorner", { CornerRadius = UDim.new(0, 7) }).Parent = container

	local list = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	list.Parent = container

	local count = #options
	local buttonWidth = math.floor((190 - 8 - 4 * (count - 1)) / count)
	local buttons = {}

	local function select(option)
		for opt, btn in pairs(buttons) do
			local active = opt == option
			tween(btn, { BackgroundColor3 = active and Theme.Accent or Theme.Background, BackgroundTransparency = active and 0 or 1 }, 0.15)
			btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Theme.Muted
		end
	end

	for i, option in ipairs(options) do
		local btn = create("TextButton", {
			Size = UDim2.fromOffset(buttonWidth, 26),
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = option,
			Font = FONT,
			TextSize = 12,
			TextColor3 = Theme.Muted,
			AutoButtonColor = false,
			LayoutOrder = i,
		})
		btn.Parent = container
		create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = btn
		buttons[option] = btn
		btn.Activated:Connect(function()
			select(option)
			if callback then callback(option) end
		end)
	end

	select(default)
	return row
end

local function createColorRow(parent, gui, text, defaultColor, order, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	})
	row.Parent = parent
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row
	create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.65 }).Parent = row

	local label = create("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local swatch = create("TextButton", {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = defaultColor,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	swatch.Parent = row
	create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = swatch
	create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.2 }).Parent = swatch

	swatch.Activated:Connect(function()
		if activePopup then
			closePopup()
			return
		end

		local backdrop = create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 90,
		})
		backdrop.Parent = gui

		local popup = create("Frame", {
			Size = UDim2.fromOffset(188, 118),
			Position = UDim2.fromOffset(swatch.AbsolutePosition.X - 150, swatch.AbsolutePosition.Y + 34),
			BackgroundColor3 = Theme.SurfaceAlt,
			BorderSizePixel = 0,
			ZIndex = 91,
		})
		popup.Parent = gui
		create("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = popup
		create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }).Parent = popup

		local grid = create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		grid.Parent = popup
		create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8) }).Parent = popup

		for h = 0, 7 do
			for s = 0, 2 do
				local color = Color3.fromHSV(h / 8, 0.72, (s == 0 and 1) or (s == 1 and 0.82) or 0.6)
				local cell = create("TextButton", {
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = color,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					LayoutOrder = h * 3 + s,
					ZIndex = 92,
				})
				cell.Parent = popup
				create("UICorner", { CornerRadius = UDim.new(0, 4) }).Parent = cell
				cell.Activated:Connect(function()
					swatch.BackgroundColor3 = color
					closePopup()
					if callback then callback(color) end
				end)
			end
		end

		backdrop.Activated:Connect(function()
			closePopup()
		end)

		activePopup = { popup = popup, backdrop = backdrop }
	end)

	return row
end

local function createKeybind(parent, text, order, callback)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	})
	row.Parent = parent
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = row
	create("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.65 }).Parent = row

	local label = create("TextLabel", {
		Size = UDim2.new(1, -130, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	label.Parent = row

	local button = create("TextButton", {
		Size = UDim2.fromOffset(104, 28),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Text = "None",
		Font = FONT,
		TextSize = 13,
		TextColor3 = Theme.Muted,
		AutoButtonColor = false,
	})
	button.Parent = row
	create("UICorner", { CornerRadius = UDim.new(0, 7) }).Parent = button

	local listening = false
	local current = nil

	button.Activated:Connect(function()
		listening = true
		button.Text = "Press a key..."
		button.TextColor3 = Theme.Accent
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not listening then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if gameProcessed then return end
		listening = false
		current = input.KeyCode
		button.Text = current.Name
		button.TextColor3 = Theme.Text
		if callback then callback(current) end
	end)

	return {
		getKey = function()
			return current
		end,
	}
end

function NovaUI.new(config)
	local self = setmetatable({}, NovaUI)
	self._config = config or {}
	self._pages = {}
	self._tabs = {}
	self._activeTab = nil
	self.Keybind = nil

	local gui = create("ScreenGui", {
		Name = "NovaUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 50,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local container = create("Frame", {
		Name = "Container",
		Size = UDim2.fromOffset(600, 420),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	})
	container.Parent = gui
	self.Container = container

	local scale = create("UIScale", { Scale = 1 })
	scale.Parent = container
	self.Scale = scale

	local shadow = create("Frame", {
		Name = "Shadow",
		Size = UDim2.new(1, 18, 1, 18),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 1,
	})
	shadow.Parent = container
	create("UICorner", { CornerRadius = UDim.new(0, 16) }).Parent = shadow
	self.Shadow = shadow

	local window = create("Frame", {
		Name = "Window",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 2,
	})
	window.Parent = container
	create("UICorner", { CornerRadius = UDim.new(0, 12) }).Parent = window
	create("UIStroke", {
		Color = Theme.Stroke,
		Thickness = 1,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}).Parent = window
	self.Window = window

	local header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})
	header.Parent = window

	local title = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.fromOffset(18, 0),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "NOVA",
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4,
	})
	title.Parent = header

	local close = create("TextButton", {
		Name = "Close",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -42, 0, 9),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 1,
		Text = "✕",
		Font = FONT_BOLD,
		TextSize = 14,
		TextColor3 = Theme.Muted,
		AutoButtonColor = false,
		ZIndex = 5,
	})
	close.Parent = header
	create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = close

	close.MouseEnter:Connect(function()
		tween(close, { BackgroundTransparency = 0, TextColor3 = Theme.Danger }, 0.15)
	end)
	close.MouseLeave:Connect(function()
		tween(close, { BackgroundTransparency = 1, TextColor3 = Theme.Muted }, 0.15)
	end)
	close.Activated:Connect(function()
		self:Close()
	end)

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 164, 1, -60),
		Position = UDim2.fromOffset(10, 50),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	sidebar.Parent = window
	create("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = sidebar
	create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}).Parent = sidebar
	create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}).Parent = sidebar

	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -186, 1, -60),
		Position = UDim2.fromOffset(184, 50),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})
	content.Parent = window
	self.Content = content

	local tabDefs = {
		{ id = "aimbot", label = "Aimbot", icon = "◈" },
		{ id = "combat", label = "Combat", icon = "◎" },
		{ id = "settings", label = "Settings", icon = "⚙" },
	}

	for order, def in ipairs(tabDefs) do
		local button = create("TextButton", {
			Name = def.id,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 4,
		})
		button.Parent = sidebar
		create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = button

		local icon = create("TextLabel", {
			Name = "Icon",
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = FONT_BOLD,
			Text = def.icon,
			TextColor3 = Theme.Muted,
			TextSize = 15,
			ZIndex = 5,
		})
		icon.Parent = button

		local label = create("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, -46, 1, 0),
			Position = UDim2.fromOffset(40, 0),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = def.label,
			TextColor3 = Theme.Muted,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
		})
		label.Parent = button

		local indicator = create("Frame", {
			Name = "Indicator",
			Size = UDim2.new(0, 3, 0, 18),
			Position = UDim2.new(0, -8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			ZIndex = 5,
			Visible = false,
		})
		indicator.Parent = button
		create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = indicator

		local page = create("Frame", {
			Name = def.id .. "Page",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 3,
		})
		page.Parent = content
		create("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 6),
		}).Parent = page
		create("UIListLayout", {
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
	local onChoice = self._config.onChoice
	local onColor = self._config.onColor

	-- Aimbot page
	createToggle(self._pages.aimbot, "Aimbot", false, 1, function(state)
		if onToggle then onToggle("aimbot", state) end
	end)

	local fovCollapse = createCollapsible(self._pages.aimbot, 3, 58)
	local fovRow = createSlider(fovCollapse.holder, "Aim FOV", 40, 400, 120, 0, function(value)
		if onSlider then onSlider("fovradius", value) end
	end)
	fovRow.Position = UDim2.fromOffset(0, 0)
	fovRow.Size = UDim2.new(1, 0, 0, 52)

	createToggle(self._pages.aimbot, "Aim FOV", false, 2, function(state)
		fovCollapse.setOpen(state)
		if onToggle then onToggle("aimfov", state) end
	end)

	createSegmented(self._pages.aimbot, "Target Mode", { "Head", "Body" }, "Head", 4, function(option)
		if onChoice then onChoice("targetmode", option) end
	end)

	-- Combat page
	createToggle(self._pages.combat, "Show Markers", false, 1, function(state)
		if onToggle then onToggle("markers", state) end
	end)
	createToggle(self._pages.combat, "Show Names", false, 2, function(state)
		if onToggle then onToggle("names", state) end
	end)
	createToggle(self._pages.combat, "Show Distance", false, 3, function(state)
		if onToggle then onToggle("distance", state) end
	end)
	createToggle(self._pages.combat, "Show Lines", false, 4, function(state)
		if onToggle then onToggle("lines", state) end
	end)
	createToggle(self._pages.combat, "Show Skeleton", false, 5, function(state)
		if onToggle then onToggle("skeleton", state) end
	end)
	createColorRow(self._pages.combat, gui, "ESP Color", Theme.Accent, 6, function(color)
		if onColor then onColor("espcolor", color) end
	end)

	-- Settings page
	createSegmented(self._pages.settings, "Interface Scale", { "Small", "Medium", "Big" }, "Medium", 1, function(option)
		self:SetScale(option)
		if onChoice then onChoice("scale", option) end
	end)
	createKeybind(self._pages.settings, "Toggle GUI Key", 2, function(key)
		self.Keybind = key
	end)

	self:ApplyKeybind()

	-- Dragging
	local dragging = false
	local dragStart, startPos
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = container.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	self:SelectTab("aimbot")
	self:Open()

	return self
end

function NovaUI:ApplyKeybind()
	if self._keyConnection then
		self._keyConnection:Disconnect()
		self._keyConnection = nil
	end
	self._keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if self.Keybind and input.KeyCode == self.Keybind then
			self:Toggle()
		end
	end)
end

function NovaUI:SelectTab(id)
	if self._activeTab == id then return end
	self._activeTab = id

	for tabId, parts in pairs(self._tabs) do
		local active = tabId == id
		tween(parts.button, { BackgroundTransparency = active and 0 or 1 }, 0.2)
		tween(parts.icon, { TextColor3 = active and Theme.Accent or Theme.Muted }, 0.2)
		tween(parts.label, { TextColor3 = active and Theme.Text or Theme.Muted }, 0.2)
		parts.indicator.Visible = active
	end

	for pageId, page in pairs(self._pages) do
		page.Visible = pageId == id
	end
end

function NovaUI:SetScale(option)
	local value = 1
	if option == "Small" then
		value = 0.85
	elseif option == "Big" then
		value = 1.15
	end
	tween(self.Scale, { Scale = value }, 0.2)
end

function NovaUI:Open()
	self.Gui.Enabled = true
	self.Window.Size = UDim2.fromScale(0.92, 0.92)
	tween(self.Window, { Size = UDim2.fromScale(1, 1) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function NovaUI:Close()
	local t = tween(self.Window, { Size = UDim2.fromScale(0.92, 0.92) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	t.Completed:Once(function()
		self.Gui.Enabled = false
	end)
end

function NovaUI:Toggle()
	if self.Gui.Enabled then
		self:Close()
	else
		self:Open()
	end
end

function NovaUI:SetVisible(state)
	if state then
		self:Open()
	else
		self:Close()
	end
end

function NovaUI:Destroy()
	closePopup()
	if self._keyConnection then
		self._keyConnection:Disconnect()
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

return NovaUI
