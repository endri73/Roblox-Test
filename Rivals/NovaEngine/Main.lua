local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/main/Rivals/NovaEngine/"

local function LoadModule(path)
    local success, result = pcall(function()
        local source = game:HttpGet(BASE .. path)
        local compiled = loadstring(source)

        assert(compiled, "Kompilimi dështoi: " .. path)

        return compiled()
    end)

    if not success then
        warn("[NOVA] Gabim në " .. path .. ": " .. tostring(result))
        return nil
    end

    print("[NOVA] Loaded:", path)
    return result
end

-- CONFIG
local Config = LoadModule("Config.lua")

if not Config then
    warn("[NOVA] Config nuk u ngarkua!")
    return
end

-- AIMBOT
local AimbotLogic = LoadModule("Aimbot/Aimbot.lua")
local FOVLogic = LoadModule("Aimbot/FOV.lua")

-- ESP
local MarkersLogic = LoadModule("ESP/Markers.lua")
local NamesLogic = LoadModule("ESP/Names.lua")
local DistanceLogic = LoadModule("ESP/Distance.lua")
local DisplayRangeLogic = LoadModule("ESP/DisplayRange.lua")

-- SETTINGS
local InterfaceScaleLogic = LoadModule("Settings/InterfaceScale.lua")
