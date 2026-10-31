--!nonstrict
-- NovaEngine/Aimbot/FOV.lua
-- Rrethi i FOV-së në ekran + konfigurim radiusi.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FOV = {}
FOV.__index = FOV

local function new(class, props)
	local inst = Instance.new(class)
	for key, value in pairs(props or {}) do
		(inst :: any)[key] = value
	end
	return inst
end

function FOV.new(radius, color)
	local self = setmetatable({}, FOV)
	self.Radius = radius or 120
	self.Color = color or Color3.fromRGB(0, 229, 255)

	local gui = new("ScreenGui", {
		Name = "NovaFOV",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 40,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local circle = new("Frame", {
		Name = "Circle",
		Size = UDim2.fromOffset(self.Radius * 2, self.Radius * 2),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	circle.Parent = gui
	new("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = circle
	local stroke = new("UIStroke", {
		Color = self.Color,
		Thickness = 1.5,
		Transparency = 0.45,
	})
	stroke.Parent = circle

	self.Circle = circle
	self.Stroke = stroke
	return self
end

function FOV:SetRadius(radius)
	self.Radius = radius
	local target = UDim2.fromOffset(radius * 2, radius * 2)
	local t = TweenService:Create(self.Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target })
	t:Play()
	return t
end

function FOV:SetVisible(state)
	if self.Circle then
		self.Circle.Visible = state
	end
end

function FOV:Destroy()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return FOV
