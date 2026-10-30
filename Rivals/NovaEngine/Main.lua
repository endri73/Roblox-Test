--[=[
    NOVA UI - Main Loader Script
    Kjo skedar orkestron dhe ngarkon të gjitha modulet nga GitHub.
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NovaUI")
if old then old:Destroy() end

-- Bazë URL e repository-t tënd në GitHub
local repoBase = "https://raw.githubusercontent.com/endri73/Roblox-Test/main/Rivals/NovaEngine/"

-- Funksion për të ngarkuar modulet nga GitHub në mënyrë të sigurt
local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(repoBase .. path))()
    end)
    if success and result then
        return result
    else
        warn("Nuk u arrit të ngarkohej moduli: " .. path .. " -> " .. tostring(result))
        return nil
    end
end

-- Ngarkimi i Config dhe Moduleve
local Config = loadModule("Config.lua")
local AimbotLogic = loadModule("Aimbot/Aimbot.lua")
local FOVLogic = loadModule("Aimbot/FOV.lua")
local MarkersLogic = loadModule("ESP/Markers.lua")
local NamesLogic = loadModule("ESP/Names.lua")
local DistanceLogic = loadModule("ESP/Distance.lua")
local DisplayRangeLogic = loadModule("ESP/DisplayRange.lua")
local InterfaceScaleLogic = loadModule("Settings/InterfaceScale.lua")

if not Config then
    warn("Kujdes: Konfigurimi nuk u ngarkua si duhet!")
    return
end

-- Inicializimi i GUI kryesor
local gui = Instance.new("ScreenGui")
gui.Name = "NovaUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromScale(0.82, 0.78)
main.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
main.BorderSizePixel = 0
main.Parent = gui

local uiScale = Instance.new("UIScale")
if InterfaceScaleLogic then
    uiScale.Scale = InterfaceScaleLogic.GetScale(Config.InterfaceScale)
else
    uiScale.Scale = 1.05
end
uiScale.Parent = main

-- Toggle GUI shfaqje / fshehje me Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.ToggleKey then
        main.Visible = not main.Visible
    end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    if FOVLogic and FOVLogic.Update then
        FOVLogic.Update(Config, main.Visible)
    end
    if AimbotLogic and AimbotLogic.Step then
        AimbotLogic.Step(Config)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local dist = 0
            if DistanceLogic and DistanceLogic.Calculate then
                dist = DistanceLogic.Calculate(Camera, char.HumanoidRootPart.Position)
            else
                dist = (char.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            end

            local inRange = true
            if DisplayRangeLogic and DisplayRangeLogic.IsInRange then
                inRange = DisplayRangeLogic.IsInRange(dist, Config.DisplayRange)
            end

            if inRange then
                if MarkersLogic and MarkersLogic.ApplyHighlight then
                    MarkersLogic.ApplyHighlight(char, Config.ShowMarkers, Config.MarkerColor)
                end
            else
                if MarkersLogic and MarkersLogic.ApplyHighlight then
                    MarkersLogic.ApplyHighlight(char, false, Config.MarkerColor)
                end
            end
        end
    end
end)
