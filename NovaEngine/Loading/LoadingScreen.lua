--!nonstrict
-- NovaEngine/Loading/LoadingScreen.lua
-- Loading screen premium: Nova Scripts, pulse, progress, exit animacion.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ACCENT   = Color3.fromRGB(108, 92, 231)
local ACCENT_2 = Color3.fromRGB(0, 200, 255)
local DEEP     = Color3.fromRGB(10, 10, 14)

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

local function new(class, props)
	local inst = Instance.new(class)
	for key, value in pairs(props or {}) do
		(inst :: any)[key] = value
	end
	return inst
end

local function tween(instance, props, duration, style, direction)
	local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(instance, info, props)
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

	local gui = new("ScreenGui", {
		Name = "NovaLoading",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local root = new("CanvasGroup", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = DEEP,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		GroupTransparency = 1,
	})
	root.Parent = gui
	self.Root = root

	local scale = new("UIScale", { Scale = 0.94 })
	scale.Parent = root
	self.Scale = scale

	-- Glow i butë (pa asete të jashtme)
	for i, spec in ipairs({
		{ size = 620, transparency = 0.95 },
		{ size = 440, transparency = 0.92 },
		{ size = 280, transparency = 0.88 },
	}) do
		local glow = new("Frame", {
			Name = "Glow" .. i,
			Size = UDim2.fromOffset(spec.size, spec.size),
			Position = UDim2.fromScale(0.5, 0.42),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = ACCENT,
			BackgroundTransparency = spec.transparency,
			BorderSizePixel = 0,
			ZIndex = 1,
		})
		glow.Parent = root
		new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = glow
	end

	local logoBox = new("Frame", {
		Name = "LogoBox",
		Size = UDim2.fromOffset(72, 72),
		Position = UDim2.fromScale(0.5, 0.36),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(24, 22, 34),
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	logoBox.Parent = root
	new("UICorner", { CornerRadius = UDim.new(0, 16) }).Parent = logoBox
	local logoStroke = new("UIStroke", {
		Color = ACCENT,
		Thickness = 1.5,
		Transparency = 0.25,
	})
	logoStroke.Parent = logoBox
	self.LogoBox = logoBox

	local logoText = new("TextLabel", {
		Name = "Logo",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "N",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 34,
		ZIndex = 4,
	})
	logoText.Parent = logoBox

	local title = new("TextLabel", {
		Name = "Title",
		Size = UDim2.new(0, 400, 0, 32),
		Position = UDim2.new(0.5, 0, 0.36, 58),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "Nova Scripts",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 26,
		ZIndex = 3,
	})
	title.Parent = root
	new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ACCENT),
			ColorSequenceKeypoint.new(1, ACCENT_2),
		}),
		Rotation = 0,
	}).Parent = title

	local status = new("TextLabel", {
		Name = "Status",
		Size = UDim2.new(0, 400, 0, 20),
		Position = UDim2.new(0.5, 0, 0.36, 96),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "Duke u nisur...",
		TextColor3 = Color3.fromRGB(160, 158, 180),
		TextSize = 14,
		TextTransparency = 0,
		ZIndex = 3,
	})
	status.Parent = root
	self.Status = status

	local percent = new("TextLabel", {
		Name = "Percent",
		Size = UDim2.new(0, 400, 0, 20),
		Position = UDim2.new(0.5, 0, 0.72, -30),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "Loading... 0%",
		TextColor3 = Color3.fromRGB(200, 198, 220),
		TextSize = 13,
		ZIndex = 3,
	})
	percent.Parent = root
	self.Percent = percent

	local track = new("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(320, 8),
		Position = UDim2.new(0.5, 0, 0.72, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(32, 30, 44),
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	track.Parent = root
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track

	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 4,
	})
	fill.Parent = track
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill
	new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ACCENT),
			ColorSequenceKeypoint.new(1, ACCENT_2),
		}),
	}).Parent = fill
	new("UIStroke", {
		Color = ACCENT_2,
		Thickness = 1,
		Transparency = 0.35,
	}).Parent = fill
	self.Fill = fill

	-- Entry: scale-up & fade-in
	tween(root, { GroupTransparency = 0 }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(scale, { Scale = 1 }, 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Pulse loop
	task.spawn(function()
		while self._alive do
			tween(logoBox, { Size = UDim2.fromOffset(78, 78) }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(logoStroke, { Transparency = 0.05 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.9)
			if not self._alive then break end
			tween(logoBox, { Size = UDim2.fromOffset(68, 68) }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(logoStroke, { Transparency = 0.35 }, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(0.9)
		end
	end)

	return self
end

function LoadingScreen:SetStatus(text)
	if not self._alive then return end
	self._statusToken += 1
	local token = self._statusToken
	local out = tween(self.Status, { TextTransparency = 1 }, 0.15)
	out.Completed:Once(function()
		if token ~= self._statusToken then return end
		self.Status.Text = text
		tween(self.Status, { TextTransparency = 0 }, 0.25)
	end)
end

function LoadingScreen:SetProgress(value)
	if not self._alive then return end
	value = math.clamp(value, 0, 100)
	local from = self._progress
	self._progress = value
	tween(self.Fill, { Size = UDim2.fromScale(value / 100, 1) }, 0.4)
	tweenNumber(from, value, 0.4, function(current)
		if self.Percent then
			self.Percent.Text = string.format("Loading... %d%%", math.floor(current + 0.5))
		end
	end)
end

function LoadingScreen:Finish()
	if not self._alive then return end
	self._alive = false

	tween(self.Fill, { Size = UDim2.fromScale(1, 1) }, 0.25)
	tweenNumber(self._progress, 100, 0.25, function(current)
		if self.Percent then
			self.Percent.Text = string.format("Loading... %d%%", math.floor(current + 0.5))
		end
	end)
	self._progress = 100

	local slide = tween(self.Root, {
		Position = UDim2.fromScale(0, -1),
		GroupTransparency = 1,
	}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(self.Scale, { Scale = 1.08 }, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

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
