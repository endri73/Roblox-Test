--[=[
    NovaEngine Main Loader Script
    Kjo është skedar kryesor që lidh të gjitha dosjet dhe modulet bashkë.
]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Ngarkimi i Moduleve nga Dosjet
local scriptFolder = script.Parent
local Config = require(scriptFolder.Config)

local AimbotLogic = require(scriptFolder.Aimbot.Aimbot)
local FOVLogic = require(scriptFolder.Aimbot.FOV)

local MarkersLogic = require(scriptFolder.ESP.Markers)
local NamesLogic = require(scriptFolder.ESP.Names)
local DistanceLogic = require(scriptFolder.ESP.Distance)
local DisplayRangeLogic = require(scriptFolder.ESP.DisplayRange)

local InterfaceScaleLogic = require(scriptFolder.Settings.InterfaceScale)
local UIAnimLogic = require(scriptFolder.Settings.UIAnimations)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

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
uiScale.Scale = InterfaceScaleLogic.GetScale(Config.InterfaceScale)
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
    FOVLogic.Update(Config, main.Visible)
    AimbotLogic.Step(Config)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local dist = DistanceLogic.Calculate(Camera, char.HumanoidRootPart.Position)

            if DisplayRangeLogic.IsInRange(dist, Config.DisplayRange) then
                MarkersLogic.ApplyHighlight(char, Config.ShowMarkers, Config.MarkerColor)
            else
                MarkersLogic.ApplyHighlight(char, false, Config.MarkerColor)
            end
        end
    end
end)