--!nonstrict
-- NovaEngine/Main.client.lua
-- Studio entry point: loading screen -> modules -> UI.
-- For executors use NovaEngine/loader.lua instead.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("NovaEngine")

local LoadingScreen = require(Modules.Loading.LoadingScreen)
local NovaUI = require(Modules.UI.NovaUI)
local Aimbot = require(Modules.Aimbot.Aimbot)
local FOV = require(Modules.Aimbot.FOV)

local ESPShared = require(Modules.ESP.Shared)
local ESPBox = require(Modules.ESP.Box)
local ESPName = require(Modules.ESP.Name)
local ESPDistance = require(Modules.ESP.Distance)
local ESPLines = require(Modules.ESP.Lines)
local ESPSkeleton = require(Modules.ESP.Skeleton)
local ESP = require(Modules.ESP.ESP)

local ACCENT = Color3.fromRGB(126, 94, 255)

local loading = LoadingScreen.new()

local STEPS = {
	{ text = "Initializing engine...", target = 20 },
	{ text = "Loading interface...", target = 45 },
	{ text = "Loading aimbot...", target = 65 },
	{ text = "Loading ESP...", target = 85 },
	{ text = "Finishing up...", target = 100 },
}

for _, step in ipairs(STEPS) do
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

local fov = FOV.new(120, ACCENT)
fov:SetVisible(false)

local esp = ESP.new({
	Shared = ESPShared,
	Color = ACCENT,
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
		elseif id == "scale" then
			ui:SetScale(option)
		end
	end,
	onColor = function(id, color)
		if id == "espcolor" then
			esp:SetColor(color)
			fov:SetColor(color)
		end
	end,
})

_G.NovaEngine = {
	UI = ui,
	Aimbot = aimbot,
	FOV = fov,
	ESP = esp,
}
