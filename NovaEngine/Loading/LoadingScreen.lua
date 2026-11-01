--!nonstrict
-- NovaEngine/Loading/LoadingScreen.lua

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")

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

-- ─────────────────────────────────────────────
-- LoadingScreen.new(totalModules)
--   totalModules  — number of modules being loaded
--
-- returns:
--   :SetStatus(text)         — status line
--   :SetProgress(n, total)   — progress bar
--   :Finish(callback)        — fade-out → destroy → callback()
-- ─────────────────────────────────────────────
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(totalModules)
	local self = setmetatable({}, LoadingScreen)
	self._total = totalModules or 1
	self._current = 0

	-- gui root
	local gui = create("ScreenGui", {
		Name           = "NovaLoading",
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
		DisplayOrder   = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = PlayerGui
	self._gui  = gui

	-- full-screen backdrop
	local backdrop = create("Frame", {
		Size             = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	})
	backdrop.Parent = gui
	self._backdrop  = backdrop

	-- subtle radial glow centre
	local glow = create("Frame", {
		Size             = UDim2.fromOffset(520, 520),
		Position         = UDim2.fromScale(0.5, 0.5),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.92,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	})
	glow.Parent = backdrop
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = glow

	-- card
	local card = create("Frame", {
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
	self._card = card

	-- logo
	local logo = create("TextLabel", {
		Name               = "Logo",
		Size               = UDim2.new(1, 0, 0, 42),
		Position           = UDim2.fromOffset(0, 28),
		BackgroundTransparency = 1,
		Font               = FONT_BOLD,
		Text               = "NOVA",
		TextColor3         = Theme.Text,
		TextSize            = 28,
		TextXAlignment     = Enum.TextXAlignment.Center,
		ZIndex             = 3,
	})
	logo.Parent = card

	-- accent line under logo
	local accentLine = create("Frame", {
		Size             = UDim2.fromOffset(40, 2),
		Position         = UDim2.new(0.5, 0, 0, 72),
		AnchorPoint      = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	accentLine.Parent = card
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = accentLine

	-- status label
	local statusLabel = create("TextLabel", {
		Name               = "Status",
		Size               = UDim2.new(1, -32, 0, 18),
		Position           = UDim2.fromOffset(16, 98),
		BackgroundTransparency = 1,
		Font               = FONT,
		Text               = "Initializing...",
		TextColor3         = Theme.Muted,
		TextSize           = 12,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextTruncate       = Enum.TextTruncate.AtEnd,
		ZIndex             = 3,
	})
	statusLabel.Parent = card
	self._statusLabel  = statusLabel

	-- progress track
	local track = create("Frame", {
		Size             = UDim2.new(1, -32, 0, 4),
		Position         = UDim2.fromOffset(16, 122),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	track.Parent = card
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = create("Frame", {
		Size             = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 4,
	})
	fill.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill
	self._fill = fill

	-- percent label
	local pctLabel = create("TextLabel", {
		Size               = UDim2.new(1, -32, 0, 16),
		Position           = UDim2.fromOffset(16, 130),
		BackgroundTransparency = 1,
		Font               = FONT,
		Text               = "0%",
		TextColor3         = Theme.Accent,
		TextSize            = 11,
		TextXAlignment     = Enum.TextXAlignment.Right,
		ZIndex             = 3,
	})
	pctLabel.Parent = card
	self._pctLabel  = pctLabel

	-- version / tag
	create("TextLabel", {
		Size               = UDim2.new(1, -32, 0, 16),
		Position           = UDim2.new(0, 16, 1, -24),
		BackgroundTransparency = 1,
		Font               = FONT,
		Text               = "v5  •  Rivals",
		TextColor3         = Color3.fromRGB(60, 60, 75),
		TextSize            = 11,
		TextXAlignment     = Enum.TextXAlignment.Left,
		ZIndex             = 3,
	}).Parent = card

	-- dot spinner
	local spinnerFrame = create("Frame", {
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
			Size             = UDim2.fromOffset(6, 6),
			Position         = UDim2.fromOffset((i - 1) * 14, 2),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.6,
			BorderSizePixel  = 0,
			ZIndex           = 4,
		})
		dot.Parent = spinnerFrame
		create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = dot
		dots[i] = dot
	end
	self._dots = dots

	-- entrance: card slides up from slight offset + fade in
	card.Position = UDim2.new(0.5, 0, 0.5, 18)
	card.BackgroundTransparency = 1
	tween(card, { Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- start dot animation
	self:_animateDots()

	return self
end

function LoadingScreen:_animateDots()
	local i = 0
	task.spawn(function()
		while self._gui and self._gui.Parent do
			i = (i % 3) + 1
			for idx, dot in ipairs(self._dots) do
				tween(dot, { BackgroundTransparency = idx == i and 0 or 0.72 }, 0.18)
			end
			task.wait(0.38)
		end
	end)
end

function LoadingScreen:SetStatus(text)
	if self._statusLabel then
		self._statusLabel.Text = text or ""
	end
end

function LoadingScreen:SetProgress(current, total)
	local pct = math.clamp((current or 0) / (total or 1), 0, 1)
	if self._fill then
		tween(self._fill, { Size = UDim2.fromScale(pct, 1) }, 0.22)
	end
	if self._pctLabel then
		self._pctLabel.Text = math.floor(pct * 100) .. "%"
	end
end

function LoadingScreen:Finish(callback)
	-- fill to 100% first
	if self._fill then
		tween(self._fill, { Size = UDim2.fromScale(1, 1) }, 0.18)
	end
	if self._pctLabel then self._pctLabel.Text = "100%" end
	if self._statusLabel then self._statusLabel.Text = "Ready." end

	task.wait(0.32)

	-- fade out backdrop
	tween(self._backdrop, { BackgroundTransparency = 1 }, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(self._card,     { BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(0.5)

	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end

	if callback then
		task.spawn(callback)
	end
end

return LoadingScreen
