--!nonstrict
-- NovaEngine/Loading/LoadingScreen.lua
-- Premium loading screen. English, crisp text, layered glow.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ACCENT = Color3.fromRGB(126, 94, 255)
local ACCENT2 = Color3.fromRGB(0, 205, 255)
local DEEP = Color3.fromRGB(10, 10, 14)

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		(inst :: any)[k] = v
	end
	return inst
end

local function tween(obj, props, duration, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function tweenNumber(from, to, duration, onUpdate)
	local value = Instance.new("NumberValue")
	value.Value = from
	local t = TweenService:Create(value, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = to })
	local conn = value:GetPropertyChangedSignal("Value"):Connect(function()
		onUpdate(value.Value)
	end)
	t:Play()
	t.Completed:Once(function()
		conn:Disconnect()
		value:Destroy()
	end)
	return t
end

function LoadingScreen.new()
	local self = setmetatable({}, LoadingScreen)
	self._alive = true
	self._progress = 0
	self._statusToken = 0

	local gui = create("ScreenGui", {
		Name = "NovaLoading",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local root = create("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = DEEP,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	root.Parent = gui
	self.Root = root

	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	content.Parent = root
	self.Content = content

	local scale = create("UIScale", { Scale = 0.94 })
	scale.Parent = content
	self.Scale = scale

	for i, spec in ipairs({
		{ size = 700, transparency = 0.94 },
		{ size = 480, transparency = 0.91 },
		{ size = 300, transparency = 0.86 },
	}) do
		local glow = create("Frame", {
			Name = "Glow" .. i,
			Size = UDim2.fromOffset(spec.size, spec.size),
			Position = UDim2.fromScale(0.5, 0.36),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ACCENT,
			BackgroundTransparency = spec.transparency,
			BorderSizePixel = 0,
		})
		glow.Parent = content
		create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = glow
	end

	local logoCard = create("Frame", {
		Name = "LogoCard",
		Size = UDim2.fromOffset(78, 78),
		Position = UDim2.fromScale(0.5, 0.33),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(23, 21, 33),
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	logoCard.Parent = content
	create("UICorner", { CornerRadius = UDim.new(0, 18) }).Parent = logoCard
	local logoStroke = create("UIStroke", { Color = ACCENT, Thickness = 1.5, Transparency = 0.2 })
	logoStroke.Parent = logoCard
	self.LogoCard = logoCard

	local logoScale = create("UIScale", { Scale = 1 })
	logoScale.Parent = logoCard
	self.LogoScale = logoScale

	local logo = create("TextLabel", {
		Name = "Logo",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "N",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 38,
		ZIndex = 4,
	})
	logo.Parent = logoCard

	local title = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(0, 420, 0, 34),
		Position = UDim2.new(0.5, 0, 0.33, 54),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "NOVA",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 30,
		ZIndex = 3,
	})
	title.Parent = content
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ACCENT),
			ColorSequenceKeypoint.new(1, ACCENT2),
		}),
	}).Parent = title

	local subtitle = create("TextLabel", {
		Name = "Subtitle",
		Size = UDim2.new(0, 420, 0, 18),
		Position = UDim2.new(0.5, 0, 0.33, 88),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = "Nova Scripts",
		TextColor3 = Color3.fromRGB(150, 148, 170),
		TextSize = 13,
		ZIndex = 3,
	})
	subtitle.Parent = content

	local status = create("TextLabel", {
		Name = "Status",
		Size = UDim2.new(0, 420, 0, 18),
		Position = UDim2.new(0.5, 0, 0.33, 112),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = "Starting up...",
		TextColor3 = Color3.fromRGB(128, 126, 148),
		TextSize = 13,
		ZIndex = 3,
	})
	status.Parent = content
	self.Status = status

	local percentLabel = create("TextLabel", {
		Name = "Percent",
		Size = UDim2.new(0, 420, 0, 18),
		Position = UDim2.new(0.5, 0, 0.72, -30),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = FONT_BOLD,
		Text = "0%",
		TextColor3 = Color3.fromRGB(210, 208, 228),
		TextSize = 13,
		ZIndex = 3,
	})
	percentLabel.Parent = content
	self.Percent = percentLabel

	local track = create("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(340, 8),
		Position = UDim2.new(0.5, 0, 0.72, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(32, 30, 44),
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	track.Parent = content
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 4,
	})
	fill.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ACCENT),
			ColorSequenceKeypoint.new(1, ACCENT2),
		}),
	}).Parent = fill
	create("UIStroke", { Color = ACCENT2, Thickness = 1, Transparency = 0.45 }).Parent = fill
	self.Fill = fill

	-- Entry
	tween(root, { BackgroundTransparency = 0.04 }, 0.45)
	tween(scale, { Scale = 1 }, 0.5)
	title.TextTransparency = 1
	subtitle.TextTransparency = 1
	status.TextTransparency = 1
	percentLabel.TextTransparency = 1
	tween(title, { TextTransparency = 0 }, 0.5)
	tween(subtitle, { TextTransparency = 0 }, 0.6)
	tween(status, { TextTransparency = 0 }, 0.7)
	tween(percentLabel, { TextTransparency = 0 }, 0.7)

	-- Pulse
	task.spawn(function()
		while self._alive do
			tween(logoScale, { Scale = 1.07 }, 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(logoStroke, { Transparency = 0.02 }, 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.85)
			if not self._alive then break end
			tween(logoScale, { Scale = 1 }, 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(logoStroke, { Transparency = 0.2 }, 0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.85)
		end
	end)

	return self
end

function LoadingScreen:SetStatus(text)
	if not self._alive then return end
	self._statusToken += 1
	local token = self._statusToken
	local out = tween(self.Status, { TextTransparency = 1 }, 0.12)
	out.Completed:Once(function()
		if token ~= self._statusToken then return end
		self.Status.Text = text
		tween(self.Status, { TextTransparency = 0 }, 0.22)
	end)
end

function LoadingScreen:SetProgress(value)
	if not self._alive then return end
	value = math.clamp(value, 0, 100)
	local from = self._progress
	self._progress = value
	tween(self.Fill, { Size = UDim2.fromScale(value / 100, 1) }, 0.35)
	tweenNumber(from, value, 0.35, function(current)
		if self.Percent then
			self.Percent.Text = string.format("%d%%", math.floor(current + 0.5))
		end
	end)
end

function LoadingScreen:Finish()
	if not self._alive then return end
	self._alive = false

	tween(self.Fill, { Size = UDim2.fromScale(1, 1) }, 0.25)
	tweenNumber(self._progress, 100, 0.25, function(current)
		if self.Percent then
			self.Percent.Text = string.format("%d%%", math.floor(current + 0.5))
		end
	end)
	self._progress = 100

	local slide = tween(self.Content, { Position = UDim2.fromScale(0, -1) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tween(self.Scale, { Scale = 1.05 }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	tween(self.Root, { BackgroundTransparency = 1 }, 0.4)

	slide.Completed:Once(function()
		if self.Gui then
			self.Gui:Destroy()
			self.Gui = nil
		end
	end)
end

function LoadingScreen:Destroy()
	self._alive = false
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return LoadingScreen
