--!nonstrict
-- NovaEngine/ESP/Markers.lua
-- ESP: Highlight + Billboard emri/distanca. Update i throttled.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Markers = {}
Markers.__index = Markers

function Markers.new(config)
	local self = setmetatable({}, Markers)
	self.Config = {
		Enabled = false,
		FillColor = Color3.fromRGB(108, 92, 231),
		OutlineColor = Color3.fromRGB(0, 200, 255),
		ShowNames = true,
		MaxDistance = 900,
		UpdateRate = 0.1,
	}
	for key, value in pairs(config or {}) do
		self.Config[key] = value
	end
	self._entries = {}
	self._connection = nil
	self._accumulator = 0
	return self
end

function Markers:_createEntry(character)
	local highlight = Instance.new("Highlight")
	highlight.Name = "NovaHighlight"
	highlight.FillColor = self.Config.FillColor
	highlight.FillTransparency = 0.65
	highlight.OutlineColor = self.Config.OutlineColor
	highlight.OutlineTransparency = 0.1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = character
	highlight.Parent = Workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NovaBillboard"
	billboard.Size = UDim2.fromOffset(160, 24)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = self.Config.MaxDistance
	billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	billboard.Parent = character

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.4
	label.Text = ""
	label.Parent = billboard

	return { highlight = highlight, billboard = billboard, label = label }
end

function Markers:_removeEntry(player)
	local entry = self._entries[player]
	if not entry then return end
	if entry.highlight then entry.highlight:Destroy() end
	if entry.billboard then entry.billboard:Destroy() end
	self._entries[player] = nil
end

function Markers:_sync()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and not self._entries[player] then
			self._entries[player] = self:_createEntry(player.Character)
		end
	end

	local camera = Workspace.CurrentCamera
	for player, entry in pairs(self._entries) do
		if not player.Parent or not player.Character then
			self:_removeEntry(player)
		else
			local character = player.Character
			entry.highlight.Adornee = character
			local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
			if entry.billboard.Adornee ~= head then
				entry.billboard.Adornee = head
			end
			if self.Config.ShowNames and head and camera then
				local distance = math.floor((head.Position - camera.CFrame.Position).Magnitude)
				entry.label.Text = string.format("%s [%dm]", player.Name, distance)
			else
				entry.label.Text = ""
			end
		end
	end
end

function Markers:Start()
	if self._connection then return end
	self._connection = RunService.Heartbeat:Connect(function(dt)
		if not self.Config.Enabled then return end
		self._accumulator += dt
		if self._accumulator >= self.Config.UpdateRate then
			self._accumulator = 0
			self:_sync()
		end
	end)
end

function Markers:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	for player in pairs(self._entries) do
		self:_removeEntry(player)
	end
end

function Markers:SetEnabled(state)
	self.Config.Enabled = state
	if state then
		self:Start()
	else
		self:Stop()
	end
end

function Markers:Destroy()
	self:Stop()
end

return Markers
