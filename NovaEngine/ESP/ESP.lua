--!nonstrict
-- NovaEngine/ESP/ESP.lua
-- ESP manager. Owns the ScreenGui, builds the per-player context each tick,
-- and hands it to each layer module (Box, Name, Distance, Lines, Skeleton).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ESP = {}
ESP.__index = ESP

-- Module key -> config flag that enables it.
local LAYER_FLAGS = {
	Box = "ShowMarkers",
	Name = "ShowNames",
	Distance = "ShowDistance",
	Lines = "ShowLines",
	Skeleton = "ShowSkeleton",
}

local LAYER_ORDER = { "Box", "Name", "Distance", "Lines", "Skeleton" }

function ESP.new(config)
	config = config or {}

	local self = setmetatable({}, ESP)
	self.Config = {
		ShowMarkers = false,
		ShowNames = false,
		ShowDistance = false,
		ShowLines = false,
		ShowSkeleton = false,
		LinePosition = "Bottom",
		Color = config.Color or Color3.fromRGB(126, 94, 255),
		TeamCheck = false,
		MaxDistance = 1200,
		UpdateRate = 0.033,
	}

	self._shared = config.Shared
	self._modules = config.Modules or {}
	self._layers = {}
	self._known = {}
	self._connection = nil
	self._accumulator = 0

	assert(self._shared, "[NovaEngine] ESP needs Shared.")
	assert(self._shared.create, "[NovaEngine] ESP Shared is malformed.")

	local gui = self._shared.create("ScreenGui", {
		Name = "NovaESP",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 30,
	})
	gui.Parent = PlayerGui
	self.Gui = gui

	for _, key in ipairs(LAYER_ORDER) do
		local module = self._modules[key]
		if module and module.new then
			self._layers[key] = module.new(gui, self._shared, self.Config)
		end
	end

	return self
end

function ESP:_context(player)
	local camera = Workspace.CurrentCamera
	local character = player.Character
	if not camera or not character then
		return nil
	end

	if self.Config.TeamCheck and player.Team == LocalPlayer.Team then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	local head = character:FindFirstChild("Head")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not head or not root then
		return nil
	end

	local distance = (head.Position - camera.CFrame.Position).Magnitude
	if distance > self.Config.MaxDistance then
		return nil
	end

	local top = self._shared.project(camera, head.Position + Vector3.new(0, 0.6, 0))
	local bottom = self._shared.project(camera, root.Position - Vector3.new(0, 2.4, 0))
	if not top or not bottom then
		return nil
	end

	local height = math.max(bottom.Y - top.Y, 14)

	return {
		player = player,
		character = character,
		camera = camera,
		top = top,
		bottom = bottom,
		height = height,
		width = height * 0.42,
		distance = distance,
		color = self.Config.Color,
	}
end

function ESP:_sync()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self._known[player] = true
			local ctx = self:_context(player)
			for key, layer in pairs(self._layers) do
				if self.Config[LAYER_FLAGS[key]] then
					layer:Update(player, ctx)
				else
					layer:Hide(player)
				end
			end
		end
	end

	for player in pairs(self._known) do
		if not player.Parent then
			for _, layer in pairs(self._layers) do
				layer:Remove(player)
			end
			self._known[player] = nil
		end
	end
end

function ESP:SetOption(flag, state)
	self.Config[flag] = state and true or false
	if not state then
		for key, layer in pairs(self._layers) do
			if LAYER_FLAGS[key] == flag then
				for player in pairs(self._known) do
					layer:Hide(player)
				end
			end
		end
	end
end

function ESP:SetColor(color)
	self.Config.Color = color
	for _, layer in pairs(self._layers) do
		layer:SetColor(color)
	end
end

function ESP:Start()
	if self._connection then
		return
	end
	self._connection = RunService.RenderStepped:Connect(function(dt)
		self._accumulator += dt
		if self._accumulator >= self.Config.UpdateRate then
			self._accumulator = 0
			self:_sync()
		end
	end)
end

function ESP:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	for _, layer in pairs(self._layers) do
		layer:Destroy()
	end
	self._layers = {}
end

function ESP:Destroy()
	self:Stop()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
end

return ESP
