--[=[
    NovaEngine main.lua — entry point (Rregulluar dhe Pastruar)
]=]

local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/main/Rivals/NovaEngine/"

local Cache = {}

local function HttpGet(url)
    if game.HttpGet then return game.HttpGet(game, url) end
    if request then return request({ Url = url, Method = "GET" }).Body end
    if http_request then return http_request({ Url = url, Method = "GET" }).Body end
    error("asnjë metodë HTTP në këtë executor")
end

local function LoadModule(path)
    if Cache[path] ~= nil then return Cache[path] end
    local url = BASE .. path

    local ok, src = pcall(function() return HttpGet(url) end)
    if not ok or type(src) ~= "string" or #src < 10 then
        warn("[NOVA] fetch fail " .. path .. " :: " .. tostring(src))
        return nil
    end
    if src:sub(1, 1) == "<" then
        warn("[NOVA] HTML error page " .. path)
        return nil
    end

    local fn, cerr = loadstring(src, "@" .. path)
    if not fn then
        warn("[NOVA] compile fail " .. path .. " :: " .. tostring(cerr))
        return nil
    end

    local rok, res = pcall(fn)
    if not rok then
        warn("[NOVA] runtime fail " .. path .. " :: " .. tostring(res))
        return nil
    end

    Cache[path] = res
    return res
end

local function Need(path)
    local m = LoadModule(path)
    if m == nil then error("[NOVA] required module missing: " .. path) end
    return m
end

-- 1) Ngarkimi i moduleve
local Config              = Need("Config.lua")
local AimbotLogic         = Need("Aimbot/Aimbot.lua")
local FOVLogic            = Need("Aimbot/FOV.lua")
local MarkersLogic        = Need("ESP/Markers.lua")
local DistanceLogic       = Need("ESP/Distance.lua")
local DisplayRangeLogic   = Need("ESP/DisplayRange.lua")
local InterfaceScaleLogic = Need("Settings/InterfaceScale.lua")

-- 2) Ngarkimi i GUI.lua
local GUIBuilder = Need("GUI.lua")

local ok, handle = pcall(function()
    if type(GUIBuilder) == "function" then
        return GUIBuilder({
            Config              = Config,
            AimbotLogic         = AimbotLogic,
            FOVLogic            = FOVLogic,
            MarkersLogic        = MarkersLogic,
            DistanceLogic       = DistanceLogic,
            DisplayRangeLogic   = DisplayRangeLogic,
            InterfaceScaleLogic = InterfaceScaleLogic,
        })
    elseif type(GUIBuilder) == "table" and GUIBuilder.Init then
        return GUIBuilder.Init({
            Config              = Config,
            AimbotLogic         = AimbotLogic,
            FOVLogic            = FOVLogic,
            MarkersLogic        = MarkersLogic,
            DistanceLogic       = DistanceLogic,
            DisplayRangeLogic   = DisplayRangeLogic,
            InterfaceScaleLogic = InterfaceScaleLogic,
        })
    end
end)

if ok then
    print("[NOVA] GUI u ndërtua me sukses")
else
    warn("[NOVA] GUI dështoi: " .. tostring(handle))
end
