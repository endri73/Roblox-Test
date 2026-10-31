--!nonstrict
-- NovaEngine/Aimbot/Aimbot.lua
-- Mouse aim: moves the cursor toward the target while the right mouse button
-- is held. Camera lerp as fallback when the executor blocks mousemoverel.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local mouseMoveRel = nil
pcall(function()
	mouseMoveRel = mousemoverel
end)

local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new(config)
	local self = setmetatable({}, Aimbot)
	self.Config = {
		Enabled = false,
		RequireRightClick = true,
		FOVRadius = 120,
		TargetPart = "Head", -- "Head" or "Body"
		Smoothing = 0.28,
		MaxDistance = 900,
		TeamCheck = true,
	}
	for key, value in pairs(config or {}) do
		self.Config[key] = value
	end
	self.Target = nil
	self._connection = nil
	self._inputBegan = nil
	self._inputEnded = nil
	self._rightDown = false
	return self
end

local function partFor(character, mode)
	if mode == "Head" then
		return character:FindFirstChild("Head")
	end
	return character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("HumanoidRootPart")
end

function Aimbot:GetTarget(mousePos)
	local camera = Workspace.CurrentCamera
	if not camera then return nil end

	local best, bestScore = nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		local character = player.Character
		if not character then continue end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end

		if self.Config.TeamCheck and player.Team == LocalPlayer.Team then continue end

		local part = partFor(character, self.Config.TargetPart)
		if not part then continue end

		local distance = (part.Position - camera.CFrame.Position).Magnitude
		if distance > self.Config.MaxDistance then continue end

		local screen, onScreen = camera:WorldToViewportPoint(part.Position)
		if not onScreen then continue end

		local screenPos = Vector2.new(screen.X, screen.Y)
		local score = (screenPos - mousePos).Magnitude
		if score > self.Config.FOVRadius then continue end

		if score < bestScore then
			best = {
				character = character,
				part = part,
				position = part.Position,
				screen = screenPos,
			}
			bestScore = score
		end
	end

	return best
end

function Aimbot:Start()
	if self._connection then return end

	self._inputBegan = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self._rightDown = true
		end
	end)
	self._inputEnded = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self._rightDown = false
		end
	end)

	self._connection = RunService.RenderStepped:Connect(function()
		if not self.Config.Enabled then return end
		if self.Config.RequireRightClick and not self._rightDown then return end
		if UserInputService:GetFocusedTextBox() then return end

		local camera = Workspace.CurrentCamera
		if not camera then return end

		local mousePos = UserInputService:GetMouseLocation()
		local target = self:GetTarget(mousePos)
		self.Target = target
		if not target then return end

		if mouseMoveRel then
			local delta = (target.screen - mousePos) * self.Config.Smoothing
			pcall(mouseMoveRel, delta.X, delta.Y)
		else
			local look = CFrame.lookAt(camera.CFrame.Position, target.position)
			camera.CFrame = camera.CFrame:Lerp(look, self.Config.Smoothing)
		end
	end)
end

function Aimbot:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	if self._inputBegan then
		self._inputBegan:Disconnect()
		self._inputBegan = nil
	end
	if self._inputEnded then
		self._inputEnded:Disconnect()
		self._inputEnded = nil
	end
	self._rightDown = false
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

function Aimbot:Destroy()
	self:Stop()
end

return Aimbot
