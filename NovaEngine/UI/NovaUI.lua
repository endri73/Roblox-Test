--!nonstrict
-- NovaEngine/UI/NovaUI.lua  v2
-- rebuilt clean — sharper palette, glowing tabs, knob sliders, pill segmented, HSV color picker

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ── palette ──────────────────────────────────────────────────────────────────
local T = {
	Bg          = Color3.fromRGB(10,  10,  15),   -- near-black base
	Surface     = Color3.fromRGB(19,  19,  26),   -- card surface
	SurfaceHov  = Color3.fromRGB(26,  26,  36),   -- hover lift
	Sidebar     = Color3.fromRGB(14,  14,  20),   -- sidebar well
	Accent      = Color3.fromRGB(124, 92,  252),  -- violet primary
	AccentSoft  = Color3.fromRGB(124, 92,  252),  -- same, used at lower alpha in tweens
	Cyan        = Color3.fromRGB(0,   212, 255),  -- secondary
	Text        = Color3.fromRGB(235, 235, 245),
	Muted       = Color3.fromRGB(110, 110, 132),
	Stroke      = Color3.fromRGB(38,  38,  52),   -- hairline borders
	Track       = Color3.fromRGB(32,  32,  44),   -- slider / toggle track
	Danger      = Color3.fromRGB(255, 80,  80),
	Knob        = Color3.fromRGB(255, 255, 255),
}

local FONT  = Enum.Font.GothamMedium
local FONTB = Enum.Font.GothamBold

-- ── helpers ───────────────────────────────────────────────────────────────────
local function mk(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do (i :: any)[k] = v end
	if parent then i.Parent = parent end
	return i
end

local function tw(obj, props, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props):Play()
end

local function corner(r, parent)
	return mk("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(color, thick, alpha, parent)
	return mk("UIStroke", { Color = color, Thickness = thick or 1, Transparency = alpha or 0 }, parent)
end

local function pad(t, l, r, b, parent)
	return mk("UIPadding", {
		PaddingTop    = UDim.new(0, t or 0),
		PaddingLeft   = UDim.new(0, l or 0),
		PaddingRight  = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
	}, parent)
end

local function list(dir, spacing, parent)
	return mk("UIListLayout", {
		FillDirection       = dir or Enum.FillDirection.Vertical,
		Padding             = UDim.new(0, spacing or 6),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment   = Enum.VerticalAlignment.Top,
	}, parent)
end

-- ── popup state ───────────────────────────────────────────────────────────────
local activePopup = nil
local function closePopup()
	if not activePopup then return end
	if activePopup.backdrop then activePopup.backdrop:Destroy() end
	if activePopup.popup   then activePopup.popup:Destroy()   end
	activePopup = nil
end

-- ── toggle ────────────────────────────────────────────────────────────────────
local function createToggle(parent, text, default, order, cb)
	local row = mk("TextButton", {
		Size                = UDim2.new(1, 0, 0, 44),
		BackgroundColor3    = T.Surface,
		BackgroundTransparency = 0.4,
		Text                = "",
		AutoButtonColor     = false,
		LayoutOrder         = order,
	}, parent)
	corner(10, row)
	local rs = stroke(T.Stroke, 1, 0.55, row)

	mk("TextLabel", {
		Size             = UDim2.new(1, -68, 1, 0),
		Position         = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = text,
		TextColor3       = T.Text,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, row)

	-- track
	local track = mk("Frame", {
		Size             = UDim2.fromOffset(40, 22),
		Position         = UDim2.new(1, -54, 0.5, 0),
		AnchorPoint      = Vector2.new(0, 0.5),
		BackgroundColor3 = T.Track,
		BorderSizePixel  = 0,
	}, row)
	corner(11, track)

	-- knob — larger, with a subtle shadow ring
	local knob = mk("Frame", {
		Size             = UDim2.fromOffset(16, 16),
		Position         = UDim2.fromOffset(3, 3),
		BackgroundColor3 = T.Knob,
		BorderSizePixel  = 0,
	}, track)
	corner(8, knob)
	stroke(Color3.fromRGB(0,0,0), 1, 0.7, knob)

	local state = default and true or false
	local function apply(animate)
		local kx    = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		local trcol = state and T.Accent or T.Track
		if animate then
			tw(knob,  { Position        = kx     }, 0.16)
			tw(track, { BackgroundColor3 = trcol  }, 0.16)
		else
			knob.Position         = kx
			track.BackgroundColor3 = trcol
		end
	end
	apply(false)

	row.MouseEnter:Connect(function()
		tw(row, { BackgroundTransparency = 0.15 }, 0.12)
		tw(rs,  { Transparency = 0.3 }, 0.12)
	end)
	row.MouseLeave:Connect(function()
		tw(row, { BackgroundTransparency = 0.4 }, 0.12)
		tw(rs,  { Transparency = 0.55 }, 0.12)
	end)
	row.Activated:Connect(function()
		state = not state
		apply(true)
		if cb then cb(state) end
	end)

	return row
end

-- ── slider ────────────────────────────────────────────────────────────────────
local function createSlider(parent, text, minV, maxV, default, order, cb)
	local row = mk("Frame", {
		Size                = UDim2.new(1, 0, 0, 56),
		BackgroundColor3    = T.Surface,
		BackgroundTransparency = 0.35,
		LayoutOrder         = order,
	}, parent)
	corner(10, row)
	stroke(T.Stroke, 1, 0.55, row)

	mk("TextLabel", {
		Size             = UDim2.new(1, -88, 0, 24),
		Position         = UDim2.fromOffset(14, 7),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = text,
		TextColor3       = T.Text,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, row)

	local valLbl = mk("TextLabel", {
		Size             = UDim2.fromOffset(68, 24),
		Position         = UDim2.new(1, -78, 0, 7),
		BackgroundTransparency = 1,
		Font             = FONTB,
		Text             = tostring(default),
		TextColor3       = T.Accent,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Right,
	}, row)

	-- track container — gives 8px horizontal padding from row edges
	local trackBg = mk("Frame", {
		Size             = UDim2.new(1, -28, 0, 4),
		Position         = UDim2.fromOffset(14, 40),
		BackgroundColor3 = T.Track,
		BorderSizePixel  = 0,
	}, row)
	corner(2, trackBg)

	local fill = mk("Frame", {
		Size             = UDim2.fromScale(math.clamp((default - minV) / (maxV - minV), 0, 1), 1),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
	}, trackBg)
	corner(2, fill)

	-- thumb knob — sits on top of trackBg
	local thumb = mk("Frame", {
		Size             = UDim2.fromOffset(14, 14),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(math.clamp((default - minV) / (maxV - minV), 0, 1), 0, 0.5, 0),
		BackgroundColor3 = T.Knob,
		BorderSizePixel  = 0,
		ZIndex           = 2,
	}, trackBg)
	corner(7, thumb)
	stroke(T.Accent, 1.5, 0, thumb)

	local dragging = false
	local function setFromX(x)
		local rel   = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
		local value = math.floor(minV + (maxV - minV) * rel + 0.5)
		fill.Size          = UDim2.fromScale(rel, 1)
		thumb.Position     = UDim2.new(rel, 0, 0.5, 0)
		valLbl.Text        = tostring(value)
		if cb then cb(value) end
	end

	trackBg.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(inp.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.Touch) then
			setFromX(inp.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return row
end

-- ── collapsible ───────────────────────────────────────────────────────────────
local function createCollapsible(parent, order, height)
	local holder = mk("Frame", {
		Size                = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants    = true,
		LayoutOrder         = order,
	}, parent)
	return {
		holder  = holder,
		setOpen = function(open)
			tw(holder, { Size = UDim2.new(1, 0, 0, open and (height or 60) or 0) },
				0.24, Enum.EasingStyle.Quad)
		end,
	}
end

-- ── segmented (pill style) ────────────────────────────────────────────────────
local function createSegmented(parent, text, options, default, order, cb)
	local row = mk("Frame", {
		Size                = UDim2.new(1, 0, 0, 44),
		BackgroundColor3    = T.Surface,
		BackgroundTransparency = 0.4,
		LayoutOrder         = order,
	}, parent)
	corner(10, row)
	stroke(T.Stroke, 1, 0.55, row)

	mk("TextLabel", {
		Size             = UDim2.new(1, -218, 1, 0),
		Position         = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = text,
		TextColor3       = T.Text,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, row)

	-- pill container
	local pill = mk("Frame", {
		Size             = UDim2.fromOffset(196, 32),
		Position         = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint      = Vector2.new(1, 0.5),
		BackgroundColor3 = T.Track,
		BorderSizePixel  = 0,
	}, row)
	corner(16, pill)
	pad(3, 3, 3, 3, pill)
	list(Enum.FillDirection.Horizontal, 3, pill)

	local count = #options
	local btnW  = math.floor((196 - 6 - 3 * (count - 1)) / count)
	local btns  = {}

	local function select(opt)
		for o, b in pairs(btns) do
			local on = o == opt
			tw(b, {
				BackgroundColor3    = on and T.Accent or T.Track,
				BackgroundTransparency = on and 0 or 1,
				TextColor3          = on and Color3.new(1,1,1) or T.Muted,
			}, 0.15)
		end
	end

	for i, opt in ipairs(options) do
		local b = mk("TextButton", {
			Size                = UDim2.fromOffset(btnW, 26),
			BackgroundColor3    = T.Track,
			BackgroundTransparency = 1,
			BorderSizePixel     = 0,
			Text                = opt,
			Font                = FONT,
			TextSize            = 12,
			TextColor3          = T.Muted,
			AutoButtonColor     = false,
			LayoutOrder         = i,
		}, pill)
		corner(13, b)
		btns[opt] = b
		b.Activated:Connect(function()
			select(opt)
			if cb then cb(opt) end
		end)
	end
	select(default)
	return row
end

-- ── color picker (HSV ring replaced with curated palette + HSV columns) ───────
local function createColorRow(parent, gui, text, defaultColor, order, cb)
	local row = mk("Frame", {
		Size                = UDim2.new(1, 0, 0, 44),
		BackgroundColor3    = T.Surface,
		BackgroundTransparency = 0.4,
		LayoutOrder         = order,
	}, parent)
	corner(10, row)
	stroke(T.Stroke, 1, 0.55, row)

	mk("TextLabel", {
		Size             = UDim2.new(1, -68, 1, 0),
		Position         = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = text,
		TextColor3       = T.Text,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, row)

	local swatch = mk("TextButton", {
		Size             = UDim2.fromOffset(28, 28),
		Position         = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint      = Vector2.new(1, 0.5),
		BackgroundColor3 = defaultColor,
		BorderSizePixel  = 0,
		Text             = "",
		AutoButtonColor  = false,
	}, row)
	corner(8, swatch)
	stroke(Color3.fromRGB(255,255,255), 1.5, 0.65, swatch)

	swatch.Activated:Connect(function()
		if activePopup then closePopup() return end

		local backdrop = mk("TextButton", {
			Size                = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			Text                = "",
			AutoButtonColor     = false,
			ZIndex              = 90,
		}, gui)

		-- popup panel
		local popup = mk("Frame", {
			Size             = UDim2.fromOffset(206, 130),
			Position         = UDim2.fromOffset(
				math.max(8, swatch.AbsolutePosition.X - 162),
				swatch.AbsolutePosition.Y + 36
			),
			BackgroundColor3 = T.Surface,
			BorderSizePixel  = 0,
			ZIndex           = 91,
		}, gui)
		corner(12, popup)
		stroke(T.Stroke, 1, 0.3, popup)
		-- subtle top-edge glow
		mk("Frame", {
			Size             = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 0.5,
			BorderSizePixel  = 0,
			ZIndex           = 92,
		}, popup)

		pad(10, 10, 10, 10, popup)

		-- 8 hues × 4 values — 4 rows of 8 swatches
		local grid = mk("Frame", {
			Size             = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex           = 92,
		}, popup)

		local COLS, ROWS = 9, 4
		local cellW, cellH = 16, 22
		local gapX, gapY  = 3, 4

		local hues  = { 0, 0.04, 0.08, 0.6, 0.67, 0.73, 0.81, 0.88, 0.95 }
		local vals  = { 1, 0.78, 0.58, 0.38 }
		local sats  = { 0.85, 0.80, 0.72, 0.60 }

		for row_i, v in ipairs(vals) do
			for col_i, h in ipairs(hues) do
				local color = (h == 0 and row_i > 1)
					and Color3.fromHSV(0, 0, 1.1 - row_i * 0.28)
					or  Color3.fromHSV(h, sats[row_i], v)

				local cell = mk("TextButton", {
					Size             = UDim2.fromOffset(cellW, cellH),
					Position         = UDim2.fromOffset(
						(col_i - 1) * (cellW + gapX),
						(row_i - 1) * (cellH + gapY)
					),
					BackgroundColor3 = color,
					BorderSizePixel  = 0,
					Text             = "",
					AutoButtonColor  = false,
					ZIndex           = 93,
				}, grid)
				corner(4, cell)

				cell.MouseEnter:Connect(function()
					tw(cell, { Size = UDim2.fromOffset(cellW + 2, cellH + 2) }, 0.08)
				end)
				cell.MouseLeave:Connect(function()
					tw(cell, { Size = UDim2.fromOffset(cellW, cellH) }, 0.08)
				end)
				cell.Activated:Connect(function()
					swatch.BackgroundColor3 = color
					closePopup()
					if cb then cb(color) end
				end)
			end
		end

		backdrop.Activated:Connect(closePopup)
		activePopup = { popup = popup, backdrop = backdrop }
	end)

	return row
end

-- ── keybind ───────────────────────────────────────────────────────────────────
local function createKeybind(parent, text, order, cb)
	local row = mk("Frame", {
		Size                = UDim2.new(1, 0, 0, 44),
		BackgroundColor3    = T.Surface,
		BackgroundTransparency = 0.4,
		LayoutOrder         = order,
	}, parent)
	corner(10, row)
	stroke(T.Stroke, 1, 0.55, row)

	mk("TextLabel", {
		Size             = UDim2.new(1, -130, 1, 0),
		Position         = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = text,
		TextColor3       = T.Text,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, row)

	local btn = mk("TextButton", {
		Size             = UDim2.fromOffset(108, 30),
		Position         = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint      = Vector2.new(1, 0.5),
		BackgroundColor3 = T.Track,
		BorderSizePixel  = 0,
		Text             = "None",
		Font             = FONT,
		TextSize         = 13,
		TextColor3       = T.Muted,
		AutoButtonColor  = false,
	}, row)
	corner(8, btn)
	stroke(T.Stroke, 1, 0.4, btn)

	local listening = false
	local current   = nil

	btn.Activated:Connect(function()
		listening  = true
		btn.Text      = "Press a key…"
		btn.TextColor3 = T.Accent
		tw(btn, { BackgroundColor3 = T.SurfaceHov }, 0.12)
	end)
	UserInputService.InputBegan:Connect(function(inp, gp)
		if not listening then return end
		if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if gp then return end
		listening     = false
		current       = inp.KeyCode
		btn.Text       = current.Name
		btn.TextColor3 = T.Text
		tw(btn, { BackgroundColor3 = T.Track }, 0.12)
		if cb then cb(current) end
	end)

	return { getKey = function() return current end }
end

-- ── section label ─────────────────────────────────────────────────────────────
local function sectionLabel(parent, text, order)
	mk("TextLabel", {
		Size             = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font             = FONTB,
		Text             = string.upper(text),
		TextColor3       = T.Muted,
		TextSize         = 10,
		TextXAlignment   = Enum.TextXAlignment.Left,
		LayoutOrder      = order,
	}, parent)
end

-- ── NovaUI class ─────────────────────────────────────────────────────────────
local NovaUI = {}
NovaUI.__index = NovaUI

function NovaUI.new(config)
	local self    = setmetatable({}, NovaUI)
	self._config  = config or {}
	self._pages   = {}
	self._tabs    = {}
	self._activeTab = nil
	self.Keybind  = nil

	-- screen gui
	local gui = mk("ScreenGui", {
		Name              = "NovaUI",
		ResetOnSpawn      = false,
		IgnoreGuiInset    = true,
		ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
		DisplayOrder      = 50,
	}, PlayerGui)
	self.Gui = gui

	-- root container (draggable)
	local container = mk("Frame", {
		Name             = "Container",
		Size             = UDim2.fromOffset(620, 430),
		Position         = UDim2.fromScale(0.5, 0.5),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, gui)
	self.Container = container

	local scale = mk("UIScale", { Scale = 1 }, container)
	self.Scale  = scale

	-- outer glow / shadow — two layers
	mk("Frame", {
		Name             = "GlowOuter",
		Size             = UDim2.new(1, 40, 1, 40),
		Position         = UDim2.new(0.5, 0, 0.5, 12),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.88,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	}, container)
	corner(20, container:FindFirstChild("GlowOuter"))

	mk("Frame", {
		Name             = "Shadow",
		Size             = UDim2.new(1, 22, 1, 22),
		Position         = UDim2.new(0.5, 0, 0.5, 10),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.48,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	}, container)
	corner(16, container:FindFirstChild("Shadow"))

	-- window
	local window = mk("Frame", {
		Name             = "Window",
		Size             = UDim2.fromScale(1, 1),
		Position         = UDim2.fromScale(0.5, 0.5),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundColor3 = T.Bg,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = 2,
	}, container)
	corner(14, window)
	stroke(T.Accent, 1, 0.72, window)  -- subtle violet border
	self.Window = window

	-- top gradient shimmer bar
	mk("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.3,
		BorderSizePixel  = 0,
		ZIndex           = 10,
	}, window)

	-- header
	local header = mk("Frame", {
		Name             = "Header",
		Size             = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		ZIndex           = 3,
	}, window)

	-- logo — "NOVA" with accent dot
	local logoFrame = mk("Frame", {
		Size             = UDim2.fromOffset(90, 50),
		Position         = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		ZIndex           = 4,
	}, header)
	mk("TextLabel", {
		Size             = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font             = FONTB,
		Text             = "NOVA",
		TextColor3       = T.Text,
		TextSize         = 17,
		TextXAlignment   = Enum.TextXAlignment.Left,
		LetterSpacing    = 4,
		ZIndex           = 5,
	}, logoFrame)
	-- accent dot after NOVA
	mk("Frame", {
		Size             = UDim2.fromOffset(5, 5),
		Position         = UDim2.fromOffset(58, 26),
		BackgroundColor3 = T.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 5,
	}, logoFrame)
	corner(3, logoFrame:FindFirstChildWhichIsA("Frame"))

	-- version muted
	mk("TextLabel", {
		Size             = UDim2.fromOffset(60, 50),
		Position         = UDim2.new(0, 78, 0, 0),
		BackgroundTransparency = 1,
		Font             = FONT,
		Text             = "v2",
		TextColor3       = T.Muted,
		TextSize         = 11,
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = 4,
	}, header)

	-- close button
	local closeBtn = mk("TextButton", {
		Size             = UDim2.fromOffset(28, 28),
		Position         = UDim2.new(1, -40, 0, 11),
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 0,
		Text             = "✕",
		Font             = FONTB,
		TextSize         = 12,
		TextColor3       = T.Muted,
		AutoButtonColor  = false,
		ZIndex           = 5,
	}, header)
	corner(8, closeBtn)
	stroke(T.Stroke, 1, 0.5, closeBtn)

	closeBtn.MouseEnter:Connect(function()
		tw(closeBtn, { BackgroundColor3 = T.Danger, TextColor3 = Color3.new(1,1,1) }, 0.13)
	end)
	closeBtn.MouseLeave:Connect(function()
		tw(closeBtn, { BackgroundColor3 = T.Surface, TextColor3 = T.Muted }, 0.13)
	end)
	closeBtn.Activated:Connect(function() self:Close() end)

	-- divider under header
	mk("Frame", {
		Size             = UDim2.new(1, -28, 0, 1),
		Position         = UDim2.fromOffset(14, 50),
		BackgroundColor3 = T.Stroke,
		BackgroundTransparency = 0.3,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	}, window)

	-- sidebar
	local sidebar = mk("Frame", {
		Name             = "Sidebar",
		Size             = UDim2.new(0, 162, 1, -68),
		Position         = UDim2.fromOffset(10, 58),
		BackgroundColor3 = T.Sidebar,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	}, window)
	corner(10, sidebar)
	stroke(T.Stroke, 1, 0.6, sidebar)
	list(Enum.FillDirection.Vertical, 4, sidebar)
	pad(10, 8, 8, 10, sidebar)

	-- content
	local content = mk("Frame", {
		Name             = "Content",
		Size             = UDim2.new(1, -186, 1, -68),
		Position         = UDim2.fromOffset(182, 58),
		BackgroundTransparency = 1,
		ZIndex           = 3,
	}, window)
	self.Content = content

	-- tabs
	local tabDefs = {
		{ id = "aimbot",   label = "Aimbot",   icon = "◈" },
		{ id = "combat",   label = "Combat",   icon = "◎" },
		{ id = "settings", label = "Settings", icon = "⚙" },
	}

	for order, def in ipairs(tabDefs) do
		local btn = mk("TextButton", {
			Name                = def.id,
			Size                = UDim2.new(1, 0, 0, 38),
			BackgroundColor3    = T.Surface,
			BackgroundTransparency = 1,
			Text                = "",
			AutoButtonColor     = false,
			LayoutOrder         = order,
			ZIndex              = 4,
		}, sidebar)
		corner(9, btn)

		-- left accent bar (hidden by default)
		local accentBar = mk("Frame", {
			Size             = UDim2.new(0, 3, 0, 18),
			Position         = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint      = Vector2.new(0, 0.5),
			BackgroundColor3 = T.Accent,
			BorderSizePixel  = 0,
			ZIndex           = 6,
			Visible          = false,
		}, btn)
		corner(2, accentBar)

		local icon = mk("TextLabel", {
			Size             = UDim2.fromOffset(22, 38),
			Position         = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Font             = FONTB,
			Text             = def.icon,
			TextColor3       = T.Muted,
			TextSize         = 14,
			ZIndex           = 5,
		}, btn)

		local lbl = mk("TextLabel", {
			Size             = UDim2.new(1, -44, 1, 0),
			Position         = UDim2.fromOffset(38, 0),
			BackgroundTransparency = 1,
			Font             = FONT,
			Text             = def.label,
			TextColor3       = T.Muted,
			TextSize         = 14,
			TextXAlignment   = Enum.TextXAlignment.Left,
			ZIndex           = 5,
		}, btn)

		local page = mk("Frame", {
			Name             = def.id .. "Page",
			Size             = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible          = false,
			ZIndex           = 3,
		}, content)
		local scroller = mk("ScrollingFrame", {
			Size                = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel     = 0,
			ScrollBarThickness  = 3,
			ScrollBarImageColor3 = T.Accent,
			ScrollBarImageTransparency = 0.5,
			CanvasSize          = UDim2.fromScale(1, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex              = 3,
		}, page)
		pad(6, 4, 14, 6, scroller)
		list(Enum.FillDirection.Vertical, 6, scroller)
		self._pages[def.id] = scroller

		btn.Activated:Connect(function() self:SelectTab(def.id) end)
		btn.MouseEnter:Connect(function()
			if self._activeTab ~= def.id then
				tw(btn, { BackgroundTransparency = 0.6 }, 0.12)
			end
		end)
		btn.MouseLeave:Connect(function()
			if self._activeTab ~= def.id then
				tw(btn, { BackgroundTransparency = 1 }, 0.12)
			end
		end)

		self._tabs[def.id] = { button = btn, icon = icon, label = lbl, bar = accentBar, page = page }
	end

	local onToggle = self._config.onToggle
	local onSlider = self._config.onSlider
	local onChoice = self._config.onChoice
	local onColor  = self._config.onColor

	-- ── Aimbot page ───────────────────────────────────────────────────────────
	sectionLabel(self._pages.aimbot, "Targeting", 0)
	createToggle(self._pages.aimbot, "Aimbot", false, 1, function(s)
		if onToggle then onToggle("aimbot", s) end
	end)

	local fovCol = createCollapsible(self._pages.aimbot, 3, 62)
	local fovSlider = createSlider(fovCol.holder, "Aim FOV", 40, 400, 120, 0, function(v)
		if onSlider then onSlider("fovradius", v) end
	end)
	fovSlider.Position = UDim2.fromOffset(0, 0)
	fovSlider.Size     = UDim2.new(1, 0, 0, 56)

	createToggle(self._pages.aimbot, "Show FOV Circle", false, 2, function(s)
		fovCol.setOpen(s)
		if onToggle then onToggle("aimfov", s) end
	end)

	sectionLabel(self._pages.aimbot, "Mode", 3)
	createSegmented(self._pages.aimbot, "Target Part", { "Head", "Body" }, "Head", 4, function(o)
		if onChoice then onChoice("targetmode", o) end
	end)
	createSlider(self._pages.aimbot, "Sensitivity", 1, 100, 50, 5, function(v)
		if onSlider then onSlider("sensitivity", v) end
	end)

	-- ── Combat page ───────────────────────────────────────────────────────────
	sectionLabel(self._pages.combat, "ESP Overlays", 0)
	createToggle(self._pages.combat, "Markers",  false, 1, function(s) if onToggle then onToggle("markers",  s) end end)
	createToggle(self._pages.combat, "Names",    false, 2, function(s) if onToggle then onToggle("names",    s) end end)
	createToggle(self._pages.combat, "Distance", false, 3, function(s) if onToggle then onToggle("distance", s) end end)
	createToggle(self._pages.combat, "Lines",    false, 4, function(s) if onToggle then onToggle("lines",    s) end end)
	createToggle(self._pages.combat, "Skeleton", false, 5, function(s) if onToggle then onToggle("skeleton", s) end end)

	sectionLabel(self._pages.combat, "Appearance", 5)
	createColorRow(self._pages.combat, gui, "ESP Color", T.Accent, 6, function(c)
		if onColor then onColor("espcolor", c) end
	end)
	createSlider(self._pages.combat, "Display Range", 50, 1000, 500, 7, function(v)
		if onSlider then onSlider("displayrange", v) end
	end)

	-- ── Settings page ─────────────────────────────────────────────────────────
	sectionLabel(self._pages.settings, "Interface", 0)
	createSegmented(self._pages.settings, "Scale", { "Small", "Medium", "Large" }, "Medium", 1, function(o)
		self:SetScale(o)
		if onChoice then onChoice("scale", o) end
	end)
	createToggle(self._pages.settings, "UI Animations", true, 2, function(s)
		if onToggle then onToggle("animations", s) end
	end)

	sectionLabel(self._pages.settings, "Keybinds", 2)
	createKeybind(self._pages.settings, "Toggle GUI", 3, function(k)
		self.Keybind = k
	end)

	-- ── drag ──────────────────────────────────────────────────────────────────
	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = inp.Position
			startPos  = container.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - dragStart
			container.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
		or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- keybind listener
	self._keyConnection = UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if self.Keybind and inp.KeyCode == self.Keybind then
			self:Toggle()
		end
	end)

	self:SelectTab("aimbot")
	self:Open()
	return self
end

function NovaUI:SelectTab(id)
	if self._activeTab == id then return end
	self._activeTab = id

	for tabId, parts in pairs(self._tabs) do
		local on = tabId == id
		tw(parts.button, { BackgroundTransparency = on and 0.25 or 1 }, 0.15)
		tw(parts.icon,   { TextColor3 = on and T.Accent or T.Muted }, 0.15)
		tw(parts.label,  { TextColor3 = on and T.Text   or T.Muted }, 0.15)
		parts.bar.Visible = on
		parts.page.Visible = on
	end
end

function NovaUI:SetScale(opt)
	local v = opt == "Small" and 0.84 or opt == "Large" and 1.16 or 1
	tw(self.Scale, { Scale = v }, 0.2)
end

function NovaUI:Open()
	self.Gui.Enabled = true
	self.Window.Size = UDim2.fromScale(0.88, 0.88)
	self.Window.BackgroundTransparency = 0.3
	tw(self.Window, { Size = UDim2.fromScale(1,1), BackgroundTransparency = 0 },
		0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function NovaUI:Close()
	local t = TweenService:Create(self.Window,
		TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.fromScale(0.88, 0.88), BackgroundTransparency = 0.3 })
	t:Play()
	t.Completed:Once(function() self.Gui.Enabled = false end)
end

function NovaUI:Toggle()
	if self.Gui.Enabled then self:Close() else self:Open() end
end

function NovaUI:SetVisible(state)
	if state then self:Open() else self:Close() end
end

function NovaUI:Destroy()
	closePopup()
	if self._keyConnection then self._keyConnection:Disconnect() end
	if self.Gui then self.Gui:Destroy() end
end

return NovaUI
