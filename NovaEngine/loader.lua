--!nonstrict
-- NovaEngine/loader.lua
-- Entry point. Ekzekuto:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/loader.lua"))()
-- Merr modulet direkt nga repo-ja dhe i nis — pa require, pa ModuleScript.

local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/"

local Players = game:GetService("Players")

local compile = loadstring or load
local fetch = game.HttpGet

assert(type(fetch) == "function", "[NovaEngine] game:HttpGet mungon — hape në client executor.")
assert(type(compile) == "function", "[NovaEngine] loadstring mungon — hape në client executor.")

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
		error(("[NovaEngine] %s nuk ktheu table."):format(path), 0)
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
	assert(player, "[NovaEngine] LocalPlayer nil — hape në client, jo në server.")
	return player
end

local function clearOld(player)
	local playerGui = player:WaitForChild("PlayerGui")
	for _, name in ipairs({ "NovaUI", "NovaLoading", "NovaFOV" }) do
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
	local Markers = loadModule("ESP/Markers.lua")

	local loading = LoadingScreen.new()
	local steps = {
		{ text = "Duke inicializuar engine...", target = 20 },
		{ text = "Duke ngarkuar UI...", target = 45 },
		{ text = "Duke ngarkuar Aimbot...", target = 65 },
		{ text = "Duke ngarkuar ESP...", target = 85 },
		{ text = "Duke përfunduar...", target = 100 },
	}
	for _, step in ipairs(steps) do
		loading:SetStatus(step.text)
		loading:SetProgress(step.target)
		task.wait(0.45)
	end
	loading:Finish()

	local aimbot = Aimbot.new()
	local fov = FOV.new(120)
	local markers = Markers.new()
	fov:SetVisible(false)

	local ui
	ui = NovaUI.new({
		onToggle = function(id, state)
			if id == "aimbot" then
				aimbot:SetEnabled(state)
				fov:SetVisible(state)
			elseif id == "esp" then
				markers:SetEnabled(state)
			end
		end,
		onSlider = function(id, value)
			if id == "fov" then
				fov:SetRadius(value)
				aimbot.Config.MaxDistance = value * 6
			elseif id == "opacity" then
				ui.Window.BackgroundTransparency = 1 - (value / 100)
			end
		end,
	})

	_G.NovaEngine = {
		UI = ui,
		Aimbot = aimbot,
		FOV = fov,
		Markers = markers,
	}
end

local ok, err = pcall(start)
if not ok then
	warn("[NovaEngine] " .. tostring(err))
	return false
end

return true
