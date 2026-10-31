--!nonstrict
-- NovaEngine/loader.lua
-- Entry point. Ekzekuto:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/loader.lua"))()
-- Merr Main.client.lua + të gjithë modulet nga i njëjti repo dhe nis UI-në.

local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/NovaEngine/"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MODULES = {
	{ folder = "Loading", name = "LoadingScreen", path = "Loading/LoadingScreen.lua" },
	{ folder = "UI",      name = "NovaUI",        path = "UI/NovaUI.lua" },
	{ folder = "Aimbot",  name = "Aimbot",        path = "Aimbot/Aimbot.lua" },
	{ folder = "Aimbot",  name = "FOV",           path = "Aimbot/FOV.lua" },
	{ folder = "ESP",     name = "Markers",       path = "ESP/Markers.lua" },
}

local fetch = game.HttpGet
local compile = loadstring or load

assert(type(fetch) == "function", "[NovaEngine] game:HttpGet nuk ekziston — ekzekutoje në executor.")
assert(type(compile) == "function", "[NovaEngine] loadstring nuk ekziston — ekzekutoje në executor.")

local function httpGet(path)
	local url = BASE .. path
	local ok, body = pcall(fetch, game, url)
	if not ok or type(body) ~= "string" or #body == 0 or body:find("404: Not Found", 1, true) then
		error(("[NovaEngine] Fetch failed: %s\n%s"):format(url, tostring(body)), 0)
	end
	return body
end

local function clearOld()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	for _, name in ipairs({ "NovaUI", "NovaLoading", "NovaFOV" }) do
		local existing = playerGui:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end
end

local function buildModules()
	local old = ReplicatedStorage:FindFirstChild("NovaEngine")
	if old then
		old:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "NovaEngine"
	root.Parent = ReplicatedStorage

	local folders = {}
	local function getFolder(name)
		if not folders[name] then
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = root
			folders[name] = folder
		end
		return folders[name]
	end

	for _, spec in ipairs(MODULES) do
		local source = httpGet(spec.path)
		local module = Instance.new("ModuleScript")
		module.Name = spec.name
		module.Source = source
		module.Parent = getFolder(spec.folder)
	end

	return root
end

local function runMain()
	local source = httpGet("Main.client.lua")
	local chunk, err = compile(source, "NovaEngine/Main.client.lua")
	if not chunk then
		error("[NovaEngine] Compile failed: " .. tostring(err), 0)
	end
	local ok, runErr = pcall(chunk)
	if not ok then
		error("[NovaEngine] Runtime error: " .. tostring(runErr), 0)
	end
end

local ok, err = pcall(function()
	clearOld()
	buildModules()
	runMain()
end)

if not ok then
	warn("[NovaEngine] " .. tostring(err))
	return false
end

return true
