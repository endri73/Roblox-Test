--!nonstrict
-- NovaEngine/Loading/LoadingScreen.lua
-- Centered card loading screen: logo, status, progress, dot spinner.

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
	Background = Color3.fromRGB(14, 14, 18),
	Surface    = Color3.fromRGB(23, 23, 29),
	Accent     = Color3.fromRGB(126, 94, 255),
	Accent2    = Color3.fromRGB(0, 205, 255),
	Text       = Color3.fromRGB(240, 240, 248),
	Muted      = Color3.fromRGB(138, 138, 156),
	Stroke     = Color3.fromRGB(44, 44, 56),
}

local FONT      = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		(inst :: any)[k] = v
	end
	return inst
end

local function tween(obj, props, duration, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

-- LoadingScreen.new(totalModules)
--   :SetStatus(text)                  — status line
--   :SetProgress(value)               — 0..100
--   :SetProgress(current, total)      — current/total
--   :Finish(callback)                 — fade out, destroy, then callback()
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(totalModules)
	local self = setmetatable({}, LoadingScreen)
	self._total = totalModules or 1
	self._progress = 0
	self._alive = true

	local gui = create("ScreenGui", {
		Name           = "NovaLoading",
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
		DisplayOrder   = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local backdrop = create("Frame", {
		Name             = "Backdrop",
		Size             = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	})
	backdrop.Parent = gui
	self.Backdrop = backdrop

	local glow = create("Frame", {
		Name                   = "Glow",
		Size                   = UDim2.fromOffset(520, 520),
		Position               = UDim2.fromScale(0.5, 0.5),
		AnchorPoint            = Vector2.new(0.5, 0.5),
		BackgroundColor3       = Theme.Accent,
		BackgroundTransparency = 0.92,
		BorderSizePixel        = 0,
		ZIndex                 = 1,
	})
	glow.Parent = backdrop
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = glow

	local card = create("Frame", {
		Name             = "Card",
		Size             = UDim2.fromOffset(340, 220),
		Position         = UDim2.fromScale(0.5, 0.5),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel  = 0,
		ZIndex           = 2,
	})
	card.Parent = backdrop
	create("UICorner", { CornerRadius = UDim.new(0, 14) }).Parent = card
	create("UIStroke", {
		Color        = Theme.Stroke,
		Thickness    = 1,
		Transparency = 0.3,
	}).Parent = card
	self.Card = card

	local logo = create("TextLabel", {
		Name                   = "Logo",
		Size                   = UDim2.new(1, 0, 0, 42),
		Position               = UDim2.fromOffset(0, 28),
		BackgroundTransparency = 1,
		Font                   = FONT_BOLD,
		Text                   = "NOVA",
		TextColor3             = Theme.Text,
		TextSize               = 28,
		TextXAlignment         = Enum.TextXAlignment.Center,
		ZIndex                 = 3,
	})
	logo.Parent = card

	local accentLine = create("Frame", {
		Name             = "AccentLine",
		Size             = UDim2.fromOffset(40, 2),
		Position         = UDim2.new(0.5, 0, 0, 72),
		AnchorPoint      = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	accentLine.Parent = card
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = accentLine

	local statusLabel = create("TextLabel", {
		Name                   = "Status",
		Size                   = UDim2.new(1, -32, 0, 18),
		Position               = UDim2.fromOffset(16, 98),
		BackgroundTransparency = 1,
		Font                   = FONT,
		Text                   = "Initializing...",
		TextColor3             = Theme.Muted,
		TextSize               = 12,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextTruncate           = Enum.TextTruncate.AtEnd,
		ZIndex                 = 3,
	})
	statusLabel.Parent = card
	self.Status = statusLabel

	local track = create("Frame", {
		Name             = "Track",
		Size             = UDim2.new(1, -32, 0, 4),
		Position         = UDim2.fromOffset(16, 122),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	track.Parent = card
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = create("Frame", {
		Name             = "Fill",
		Size             = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 4,
	})
	fill.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill
	self.Fill = fill

	local pctLabel = create("TextLabel", {
		Name                   = "Percent",
		Size                   = UDim2.new(1, -32, 0, 16),
		Position               = UDim2.fromOffset(16, 132),
		BackgroundTransparency = 1,
		Font                   = FONT,
		Text                   = "0%",
		TextColor3             = Theme.Accent,
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Right,
		ZIndex                 = 3,
	})
	pctLabel.Parent = card
	self.Percent = pctLabel

	local version = create("TextLabel", {
		Name                   = "Version",
		Size                   = UDim2.new(1, -32, 0, 16),
		Position               = UDim2.new(0, 16, 1, -24),
		BackgroundTransparency = 1,
		Font                   = FONT,
		Text                   = "v2  •  NovaEngine",
		TextColor3             = Color3.fromRGB(60, 60, 75),
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Left,
		ZIndex                 = 3,
	})
	version.Parent = card

	local spinnerFrame = create("Frame", {
		Name                   = "Spinner",
		Size                   = UDim2.fromOffset(48, 10),
		Position               = UDim2.new(1, -16, 1, -24),
		AnchorPoint            = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		ZIndex                 = 3,
	})
	spinnerFrame.Parent = card

	local dots = {}
	for i = 1, 3 do
		local dot = create("Frame", {
			Name                   = "Dot" .. i,
			Size                   = UDim2.fromOffset(6, 6),
			Position               = UDim2.fromOffset((i - 1) * 14, 2),
			BackgroundColor3       = Theme.Accent,
			BackgroundTransparency = 0.6,
			BorderSizePixel        = 0,
			ZIndex                 = 4,
		})
		dot.Parent = spinnerFrame
		create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = dot
		dots[i] = dot
	end
	self.Dots = dots

	card.Position = UDim2.new(0.5, 0, 0.5, 18)
	card.BackgroundTransparency = 1
	tween(card, {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0,
	}, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	self:_animateDots()

	return self
end

function LoadingScreen:_animateDots()
	local index = 0
	task.spawn(function()
		while self._alive and self.Gui and self.Gui.Parent do
			index = (index % 3) + 1
			for i, dot in ipairs(self.Dots) do
				tween(dot, { BackgroundTransparency = (i == index) and 0 or 0.72 }, 0.18)
			end
			task.wait(0.38)
		end
	end)
end

function LoadingScreen:SetStatus(text)
	if not self._alive or not self.Status then
		return
	end
	self.Status.Text = text or ""
end

-- Accepts either SetProgress(value) with 0..100, or SetProgress(current, total).
function LoadingScreen:SetProgress(current, total)
	if not self._alive then
		return
	end

	local pct
	if total then
		pct = math.clamp((current or 0) / math.max(total, 1), 0, 1)
	else
		pct = math.clamp((current or 0) / 100, 0, 1)
	end

	self._progress = pct
	if self.Fill then
		tween(self.Fill, { Size = UDim2.fromScale(pct, 1) }, 0.22)
	end
	if self.Percent then
		self.Percent.Text = string.format("%d%%", math.floor(pct * 100 + 0.5))
	end
end

function LoadingScreen:Finish(callback)
	if not self._alive then
		if callback then
			task.spawn(callback)
		end
		return
	end

	if self.Fill then
		tween(self.Fill, { Size = UDim2.fromScale(1, 1) }, 0.18)
	end
	if self.Percent then
		self.Percent.Text = "100%"
	end
	if self.Status then
		self.Status.Text = "Ready."
	end

	task.wait(0.32)

	tween(self.Backdrop, { BackgroundTransparency = 1 }, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(self.Card, { BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(self.Card, { Position = UDim2.new(0.5, 0, 0.5, -14) }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(0.5)

	self._alive = false
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end

	if callback then
		task.spawn(callback)
	end
end

function LoadingScreen:Destroy()
	self._alive = false
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return LoadingScreen
