--!nonstrict
-- NovaEngine/Aimbot/FOV.lua
-- FOV circle that follows the mouse cursor.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GetMouseLocation excludes the top bar inset; this GUI ignores it, so add it back.
local function insetOffset()
	local inset = GuiService:GetGuiInset()
	return Vector2.new(inset.X, inset.Y)
end

local FOV = {}
FOV.__index = FOV

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		(inst :: any)[k] = v
	end
	return inst
end

function FOV.new(radius, color)
	local self = setmetatable({}, FOV)
	self.Radius = radius or 120
	self.Color = color or Color3.fromRGB(126, 94, 255)

	local gui = create("ScreenGui", {
		Name = "NovaFOV",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 45,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	local circle = create("Frame", {
		Name = "Circle",
		Size = UDim2.fromOffset(self.Radius * 2, self.Radius * 2),
		Position = UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	circle.Parent = gui
	create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = circle
	local stroke = create("UIStroke", {
		Color = self.Color,
		Thickness = 1.5,
		Transparency = 0.35,
	})
	stroke.Parent = circle

	self.Circle = circle
	self.Stroke = stroke

	self._connection = RunService.RenderStepped:Connect(function()
		if not circle.Visible then return end
		local mouse = UserInputService:GetMouseLocation() + insetOffset()
		circle.Position = UDim2.fromOffset(mouse.X, mouse.Y)
	end)

	return self
end

function FOV:SetRadius(radius)
	self.Radius = radius
	local target = UDim2.fromOffset(radius * 2, radius * 2)
	TweenService:Create(self.Circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target }):Play()
end

function FOV:SetColor(color)
	self.Color = color
	if self.Stroke then
		TweenService:Create(self.Stroke, TweenInfo.new(0.15), { Color = color }):Play()
	end
end

function FOV:SetVisible(state)
	if self.Circle then
		self.Circle.Visible = state
	end
end

function FOV:Destroy()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return FOV
