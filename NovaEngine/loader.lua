--!nonstrict
-- NovaEngine/loader.lua
-- Entry point. Execute:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/loader.lua"))()
-- Loads every module from the repo and starts the UI.

local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/"

local Players = game:GetService("Players")

local compile = loadstring or load
local fetch = game.HttpGet

assert(type(fetch) == "function", "[NovaEngine] game:HttpGet is missing — open this in a client executor.")
assert(type(compile) == "function", "[NovaEngine] loadstring is missing — open this in a client executor.")

local function httpGet(path)
	local url = BASE .. path
	local ok, body = pcall(fetch, game, url)
	if not ok or type(body) ~= "string" or #body == 0 or body:find("404: Not Found", 1, true) then
		error(("[NovaEngine] Fetch failed: %s\n%s"):format(url, tostring(body)), 0)
	end
	return body
end

local function loadModule(path)
	local source = httpGet(path)
	local chunk, compileErr = compile(source, path)
	if not chunk then
		error(("[NovaEngine] Compile failed: %s\n%s"):format(path, tostring(compileErr)), 0)
	end
	local ok, result = pcall(chunk)
	if not ok then
		error(("[NovaEngine] Module error: %s\n%s"):format(path, tostring(result)), 0)
	end
	if type(result) ~= "table" then
		error(("[NovaEngine] %s did not return a table."):format(path), 0)
	end
	return result
end

local function waitForLocalPlayer()
	local player = Players.LocalPlayer
	local deadline = os.clock() + 8
	while not player and os.clock() < deadline do
		task.wait(0.1)
		player = Players.LocalPlayer
	end
	assert(player, "[NovaEngine] LocalPlayer is nil — run this on the client, not the server.")
	return player
end

local function clearOld(player)
	local playerGui = player:WaitForChild("PlayerGui")
	for _, name in ipairs({ "NovaUI", "NovaLoading", "NovaFOV", "NovaESP" }) do
		local existing = playerGui:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end
end

local function start()
	local player = waitForLocalPlayer()
	clearOld(player)

	local LoadingScreen = loadModule("Loading/LoadingScreen.lua")
	local NovaUI = loadModule("UI/NovaUI.lua")
	local Aimbot = loadModule("Aimbot/Aimbot.lua")
	local FOV = loadModule("Aimbot/FOV.lua")

	local ESPShared = loadModule("ESP/Shared.lua")
	local ESPBox = loadModule("ESP/Box.lua")
	local ESPName = loadModule("ESP/Name.lua")
	local ESPDistance = loadModule("ESP/Distance.lua")
	local ESPLines = loadModule("ESP/Lines.lua")
	local ESPSkeleton = loadModule("ESP/Skeleton.lua")
	local ESP = loadModule("ESP/ESP.lua")

	local loading = LoadingScreen.new()
	local steps = {
		{ text = "Initializing engine...", target = 20 },
		{ text = "Loading interface...", target = 45 },
		{ text = "Loading aimbot...", target = 65 },
		{ text = "Loading ESP...", target = 85 },
		{ text = "Finishing up...", target = 100 },
	}
	for _, step in ipairs(steps) do
		loading:SetStatus(step.text)
		loading:SetProgress(step.target)
		task.wait(0.4)
	end
	loading:Finish()

	local aimbot = Aimbot.new({
		Enabled = false,
		FOVRadius = 120,
		TargetPart = "Head",
	})

	local fov = FOV.new(120, Color3.fromRGB(126, 94, 255))
	fov:SetVisible(false)

	local esp = ESP.new({
		Shared = ESPShared,
		Color = Color3.fromRGB(126, 94, 255),
		Modules = {
			Box = ESPBox,
			Name = ESPName,
			Distance = ESPDistance,
			Lines = ESPLines,
			Skeleton = ESPSkeleton,
		},
	})
	esp:Start()

	local ui
	ui = NovaUI.new({
		onToggle = function(id, state)
			if id == "aimbot" then
				aimbot:SetEnabled(state)
			elseif id == "aimfov" then
				fov:SetVisible(state)
			elseif id == "markers" then
				esp:SetOption("ShowMarkers", state)
			elseif id == "names" then
				esp:SetOption("ShowNames", state)
			elseif id == "distance" then
				esp:SetOption("ShowDistance", state)
			elseif id == "lines" then
				esp:SetOption("ShowLines", state)
			elseif id == "skeleton" then
				esp:SetOption("ShowSkeleton", state)
			end
		end,
		onSlider = function(id, value)
			if id == "fovradius" then
				fov:SetRadius(value)
				aimbot.Config.FOVRadius = value
			end
		end,
		onChoice = function(id, option)
			if id == "targetmode" then
				aimbot.Config.TargetPart = option
			end
		end,
		onColor = function(id, color)
			if id == "espcolor" then
				esp:SetColor(color)
				fov:SetColor(color)
			end
		end,
		onClose = function()
			aimbot:SetEnabled(false)
			fov:SetVisible(false)
			esp:SetOption("ShowMarkers", false)
			esp:SetOption("ShowNames", false)
			esp:SetOption("ShowDistance", false)
			esp:SetOption("ShowLines", false)
			esp:SetOption("ShowSkeleton", false)
		end,
	})

	_G.NovaEngine = {
		UI = ui,
		Aimbot = aimbot,
		FOV = fov,
		ESP = esp,
	}
end

local ok, err = pcall(start)
if not ok then
	warn("[NovaEngine] " .. tostring(err))
	return false
end

return true
