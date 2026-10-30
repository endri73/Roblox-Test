local BASE = "https://raw.githubusercontent.com/endri73/Inf-Jump/main/src/"

local function LoadModule(name)
    local url = BASE .. name .. ".lua"
    local source = game:HttpGet(url)

    return loadstring(source)()
end

local Settings = LoadModule("settings")
local InfiniteJump = LoadModule("infinite_jump")
local GUI = LoadModule("gui")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

InfiniteJump.Start(player, function()
    return Settings.Enabled
end)

GUI.Create(Settings, function(enabled)
    print("Infinite Jump:", enabled)
end)

print("Inf-Jump loaded successfully!")
