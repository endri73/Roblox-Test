--!nonstrict
-- NovaEngine/Loading/LoadingScreen.lua
-- Minimal centered loader: purple N tile, title, status line, progress bar.

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
	Accent = Color3.fromRGB(126, 94, 255),
	Text   = Color3.fromRGB(255, 255, 255),
	Muted  = Color3.fromRGB(158, 158, 172),
	Track  = Color3.fromRGB(132, 130, 186),
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

-- LoadingScreen.new()
--   :SetStatus(text)              — line under the title
--   :SetProgress(value)           — 0..100
--   :SetProgress(current, total)  — current/total
--   :Finish(callback)             — fade out, destroy, then callback()
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new()
	local self = setmetatable({}, LoadingScreen)
	self._alive = true
	self._progress = 0

	local gui = create("ScreenGui", {
		Name           = "NovaLoading",
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
		DisplayOrder   = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = PlayerGui
	self._gui = gui

	-- dim the world behind the loader
	local backdrop = create("Frame", {
		Name             = "Backdrop",
		Size             = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ZIndex           = 1,
	})
	backdrop.Parent = gui
	self._backdrop = backdrop
	tween(backdrop, { BackgroundTransparency = 0.45 }, 0.4)

	-- centered stack
	local container = create("Frame", {
		Name                   = "Container",
		Size                   = UDim2.fromOffset(360, 176),
		Position               = UDim2.fromScale(0.5, 0.5),
		AnchorPoint            = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex                 = 2,
	})
	container.Parent = gui
	self._container = container

	local scale = create("UIScale", { Scale = 0.94 })
	scale.Parent = container
	self._scale = scale
	tween(scale, { Scale = 1 }, 0.45)

	-- logo tile
	local tile = create("Frame", {
		Name             = "Logo",
		Size             = UDim2.fromOffset(74, 74),
		Position         = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint      = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	tile.Parent = container
	create("UICorner", { CornerRadius = UDim.new(0, 16) }).Parent = tile
	self._tile = tile

	local letter = create("TextLabel", {
		Name                   = "Letter",
		Size                   = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font                   = FONT_BOLD,
		Text                   = "N",
		TextColor3             = Theme.Text,
		TextSize               = 34,
		ZIndex                 = 4,
	})
	letter.Parent = tile
	self._letter = letter

	-- title
	local title = create("TextLabel", {
		Name                   = "Title",
		Size                   = UDim2.new(1, 0, 0, 32),
		Position               = UDim2.fromOffset(0, 88),
		BackgroundTransparency = 1,
		Font                   = FONT_BOLD,
		Text                   = "Nova Scripts",
		TextColor3             = Theme.Text,
		TextSize               = 26,
		TextTransparency       = 1,
		ZIndex                 = 3,
	})
	title.Parent = container
	self._title = title

	-- status
	local status = create("TextLabel", {
		Name                   = "Status",
		Size                   = UDim2.new(1, 0, 0, 20),
		Position               = UDim2.fromOffset(0, 122),
		BackgroundTransparency = 1,
		Font                   = FONT,
		Text                   = "Loading Script",
		TextColor3             = Theme.Muted,
		TextSize               = 15,
		TextTransparency       = 1,
		ZIndex                 = 3,
	})
	status.Parent = container
	self._status = status

	-- progress track
	local track = create("Frame", {
		Name             = "Track",
		Size             = UDim2.fromOffset(280, 6),
		Position         = UDim2.fromOffset(40, 156),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0.35,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	track.Parent = container
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = track
	self._track = track

	local fill = create("Frame", {
		Name             = "Fill",
		Size             = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 4,
	})
	fill.Parent = track
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = fill
	self._fill = fill

	-- entrance
	tween(title, { TextTransparency = 0 }, 0.45)
	tween(status, { TextTransparency = 0 }, 0.55)
	tween(track, { BackgroundTransparency = 0.35 }, 0.55)

	return self
end

function LoadingScreen:SetStatus(text)
	if not self._alive or not self._status then
		return
	end
	self._status.Text = text or ""
end

-- Accepts SetProgress(value) with 0..100, or SetProgress(current, total).
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
	if self._fill then
		tween(self._fill, { Size = UDim2.fromScale(pct, 1) }, 0.25)
	end
end

function LoadingScreen:Finish(callback)
	if not self._alive then
		if callback then
			task.spawn(callback)
		end
		return
	end

	if self._fill then
		tween(self._fill, { Size = UDim2.fromScale(1, 1) }, 0.18)
	end
	if self._status then
		self._status.Text = "Ready"
	end

	task.wait(0.25)

	tween(self._container, { Position = UDim2.new(0.5, 0, 0.5, -12) }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(self._title, { TextTransparency = 1 }, 0.35)
	tween(self._status, { TextTransparency = 1 }, 0.35)
	tween(self._tile, { BackgroundTransparency = 1 }, 0.35)
	tween(self._letter, { TextTransparency = 1 }, 0.35)
	tween(self._track, { BackgroundTransparency = 1 }, 0.35)
	tween(self._fill, { BackgroundTransparency = 1 }, 0.35)
	tween(self._backdrop, { BackgroundTransparency = 1 }, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(0.45)

	self._alive = false
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end

	if callback then
		task.spawn(callback)
	end
end

function LoadingScreen:Destroy()
	self._alive = false
	if self._gui then
		self._gui:Destroy()
		self._gui = nil
	end
end

return LoadingScreen
