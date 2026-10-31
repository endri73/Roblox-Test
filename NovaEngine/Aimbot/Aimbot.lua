--!nonstrict
-- NovaEngine/Aimbot/Aimbot.lua
-- Aimbot client-side: kamera lerp drejt target-it brenda FOV.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Aimbot = {}
Aimbot.__index = Aimbot

local function getCamera()
	return Workspace.CurrentCamera
end

function Aimbot.new(config)
	local self = setmetatable({}, Aimbot)
	self.Config = {
		Enabled = false,
		Smoothing = 0.35,
		MaxDistance = 600,
		TeamCheck = true,
		WallCheck = false,
		TargetPart = "Head",
	}
	for key, value in pairs(config or {}) do
		self.Config[key] = value
	end
	self.Target = nil
	self._connection = nil
	return self
end

function Aimbot:IsValidTarget(character)
	if not character or not character.Parent then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player or player == LocalPlayer then
		return false
	end
	if self.Config.TeamCheck and player.Team == LocalPlayer.Team then
		return false
	end
	return true
end

function Aimbot:GetTarget()
	local camera = getCamera()
	if not camera then return nil end

	local cameraPos = camera.CFrame.Position
	local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestScore = nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local character = player.Character
		if not self:IsValidTarget(character) then continue end

		local part = character:FindFirstChild(self.Config.TargetPart) or character:FindFirstChild("HumanoidRootPart")
		if not part then continue end

		local distance = (part.Position - cameraPos).Magnitude
		if distance > self.Config.MaxDistance then continue end

		local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local score = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		if score < bestScore then
			best = { character = character, part = part, screen = screenPos, score = score }
			bestScore = score
		end
	end

	return best
end

function Aimbot:AimAt(target)
	local camera = getCamera()
	if not camera or not target then return end
	local look = CFrame.lookAt(camera.CFrame.Position, target.part.Position)
	camera.CFrame = camera.CFrame:Lerp(look, self.Config.Smoothing)
end

function Aimbot:Start()
	if self._connection then return end
	self._connection = RunService.RenderStepped:Connect(function()
		if not self.Config.Enabled then return end
		local target = self:GetTarget()
		self.Target = target
		if target then
			self:AimAt(target)
		end
	end)
end

function Aimbot:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	self.Target = nil
end

function Aimbot:SetEnabled(state)
	self.Config.Enabled = state
	if state then
		self:Start()
	else
		self:Stop()
	end
end

function Aimbot:SetSmoothing(value)
	self.Config.Smoothing = math.clamp(value, 0.01, 1)
end

function Aimbot:Destroy()
	self:Stop()
	self.Target = nil
end

return Aimbot
