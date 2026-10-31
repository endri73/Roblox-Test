--!nonstrict
-- NovaEngine/Main.client.lua
-- Loader kryesor: loading screen -> module -> UI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("NovaEngine")

local LoadingScreen = require(Modules.Loading.LoadingScreen)
local NovaUI = require(Modules.UI.NovaUI)
local Aimbot = require(Modules.Aimbot.Aimbot)
local FOV = require(Modules.Aimbot.FOV)
local Markers = require(Modules.ESP.Markers)

local loader = LoadingScreen.new()

local STEPS = {
	{ text = "Duke inicializuar engine...", target = 20 },
	{ text = "Duke ngarkuar UI...", target = 45 },
	{ text = "Duke ngarkuar Aimbot...", target = 65 },
	{ text = "Duke ngarkuar ESP...", target = 85 },
	{ text = "Duke përfunduar...", target = 100 },
}

for _, step in ipairs(STEPS) do
	loader:SetStatus(step.text)
	loader:SetProgress(step.target)
	task.wait(0.45)
end

loader:Finish()

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
