local BASE = "https://raw.githubusercontent.com/endri73/Inf-Jump/main/src/"

local function LoadModule(moduleName, callback)
    print("[Inf-Jump] Loading:", moduleName)

    local success, result = pcall(callback)

    if not success then
        warn("[Inf-Jump ERROR] Module:", moduleName)
        warn("[Inf-Jump ERROR] Details:", tostring(result))
        return nil
    end

    print("[Inf-Jump] Loaded:", moduleName)
    return result
end

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
