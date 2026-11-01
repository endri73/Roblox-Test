--!nonstrict
-- NovaEngine/Aimbot/Aimbot.lua
-- Cursor aim. Strategy order:
--   1. mousemoveabs  — puts the cursor exactly on the target part
--   2. mousemoverel  — moves the cursor by the remaining delta
--   3. camera lerp   — when the executor exposes neither
-- Active only while the right mouse button is held.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- WorldToViewportPoint excludes the top bar inset, GetMouseLocation does not.
local function viewportToScreen(point)
	local inset = GuiService:GetGuiInset()
	return Vector2.new(point.X + inset.X, point.Y + inset.Y)
end

local ABS_NAMES = { "mousemoveabs", "MouseMoveAbs", "mouse_move_abs" }
local REL_NAMES = { "mousemoverel", "MouseMoveRel", "mouse_move_rel" }

-- Executors disagree on where they expose input functions: global env, _G, or
-- only on getgenv(). Try all three, cheapest first, and cache the hit.
local function resolveGlobal(names)
	for _, name in ipairs(names) do
		local ok, fn = pcall(function()
			return getgenv()[name]
		end)
		if ok and type(fn) == "function" then
			return fn
		end
		local ok2, fn2 = pcall(function()
			return _G[name]
		end)
		if ok2 and type(fn2) == "function" then
			return fn2
		end
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
		Smoothing = 0.35,
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
	self._moveAbs = resolveGlobal(ABS_NAMES)
	self._moveRel = resolveGlobal(REL_NAMES)
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

function Aimbot:_aim(camera, target, mousePos)
	local delta = target.screen - mousePos
	local factor = math.clamp(self.Config.Smoothing, 0.05, 1)
	local cursorLocked = UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default

	if self._moveAbs and not cursorLocked then
		local nextPos = mousePos + delta * factor
		pcall(self._moveAbs, math.floor(nextPos.X + 0.5), math.floor(nextPos.Y + 0.5))
		return
	end

	if self._moveRel and not cursorLocked then
		pcall(self._moveRel, delta.X * factor, delta.Y * factor)
		return
	end

	-- No cursor control available (or the cursor is locked): turn the camera.
	local look = CFrame.lookAt(camera.CFrame.Position, target.position)
	camera.CFrame = camera.CFrame:Lerp(look, math.clamp(factor * 1.5, 0.05, 1))
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

		self:_aim(camera, target, mousePos)
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
