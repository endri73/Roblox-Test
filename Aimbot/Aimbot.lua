--!nonstrict
-- NovaEngine/Aimbot/Aimbot.lua
-- Mouse aim: moves the cursor toward the target while the right mouse button
-- is held. When Roblox locks the cursor (MouseBehavior ~= Default) the cursor
-- cannot be moved, so the camera is lerped instead.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- WorldToViewportPoint excludes the top bar inset, GetMouseLocation does not.
-- Adding the inset puts both in the same screen space as the cursor.
local function viewportToScreen(point)
	local inset = GuiService:GetGuiInset()
	return Vector2.new(point.X + inset.X, point.Y + inset.Y)
end

-- Executors expose mousemoverel either as a global or on getgenv(). Resolve it
-- per call so a late-loaded executor function is still picked up.
local function getMouseMoveRel()
	local fn = nil
	pcall(function()
		fn = mousemoverel
	end)
	if type(fn) ~= "function" then
		pcall(function()
			fn = getgenv().mousemoverel
		end)
	end
	if type(fn) == "function" then
		return fn
	end
	return nil
end

local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new(config)
	local self = setmetatable({}, Aimbot)
	self.Config = {
		Enabled = false,
		RequireRightClick = true,
		FOVRadius = 120,
		TargetPart = "Head", -- "Head" or "Body"
		Smoothing = 0.3,
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

	local myTeam = LocalPlayer.Team
	local best, bestScore = nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			-- TeamCheck only applies when the local player actually has a team.
			local sameTeam = self.Config.TeamCheck and myTeam ~= nil and player.Team == myTeam

			if character and humanoid and humanoid.Health > 0 and not sameTeam then
				local part = partFor(character, self.Config.TargetPart)
				if part then
					local distance = (part.Position - camera.CFrame.Position).Magnitude
					if distance <= self.Config.MaxDistance then
						local screen, onScreen = camera:WorldToViewportPoint(part.Position)
						if onScreen then
							local screenPos = viewportToScreen(screen)
							local score = (screenPos - mousePos).Magnitude
							if score <= self.Config.FOVRadius and score < bestScore then
								best = {
									character = character,
									part = part,
									position = part.Position,
									screen = screenPos,
								}
								bestScore = score
							end
						end
					end
				end
			end
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

		local mouseMoveRel = getMouseMoveRel()
		local cursorLocked = UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default

		if mouseMoveRel then
			local delta = (target.screen - mousePos) * self.Config.Smoothing
			pcall(mouseMoveRel, delta.X, delta.Y)
		end

		-- Locked cursor (shift-lock / first person) ignores mousemoverel, and
		-- executors without it need a fallback, so nudge the camera too.
		if cursorLocked or not mouseMoveRel then
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
