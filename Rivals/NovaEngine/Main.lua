-- Nova Engine loader — fetch, cache, retry, need-guard
local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/main/Rivals/NovaEngine/"

local Cache = {}

local function HttpGet(url)
    if game.HttpGet then return game.HttpGet(url) end
    if request then return request({ Url = url, Method = "GET" }).Body end
    if http_request then return http_request({ Url = url, Method = "GET" }).Body end
    error("no HTTP method available")
end

local function fetchWithRetry(url, tries)
    tries = tries or 3
    local lastErr
    for i = 1, tries do
        local ok, src = pcall(HttpGet, url)
        if ok and type(src) == "string" and #src > 0 then
            return src
        end
        lastErr = ok and "empty body" or tostring(src)
        task.wait(0.2 * i)
    end
    return nil, lastErr
end

local function LoadModule(path)
    if Cache[path] ~= nil then return Cache[path] end

    local url = BASE .. path
    local source, err = fetchWithRetry(url)
    if not source then
        warn(("[NOVA] fetch fail %s :: %s"):format(path, tostring(err)))
        return nil
    end

    -- GitHub returns an HTML error page for missing files; detect and bail
    if source:sub(1, 1) == "<" or #source < 20 then
        warn(("[NOVA] bad body %s :: starts %q"):format(path, source:sub(1, 60)))
        return nil
    end

    local fn, compileErr = loadstring(source, "@" .. path)
    if not fn then
        warn(("[NOVA] compile fail %s :: %s"):format(path, tostring(compileErr)))
        return nil
    end

    local ok, result = pcall(fn)
    if not ok then
        warn(("[NOVA] runtime fail %s :: %s"):format(path, tostring(result)))
        return nil
    end

    Cache[path] = result
    return result
end

-- hard require: stops init if a core module is missing
local function Need(path)
    local m = LoadModule(path)
    if m == nil then
        error("[NOVA] required module missing: " .. path)
    end
    return m
end

-- resolve folder listings without hitting the HTML page
-- we know the file names per folder, so we ask for them explicitly
local Folders = {
    Config   = { "Config.lua" },
    Aimbot   = { "Aimbot/Aimbot.lua", "Aimbot/FOV.lua" },
    ESP      = { "ESP/Markers.lua", "ESP/Names.lua", "ESP/Distance.lua", "ESP/DisplayRange.lua" },
    Settings = { "Settings/InterfaceScale.lua" },
}

local function LoadFolder(name)
    local files = Folders[name]
    if not files then
        warn("[NOVA] unknown folder: " .. name)
        return nil
    end
    local out = {}
    for _, rel in ipairs(files) do
        local mod = LoadModule(rel)
        out[rel] = mod
        if mod == nil then
            warn("[NOVA] " .. rel .. " did not load")
        end
    end
    return out
end

-- boot
local Config = Need("Config.lua")

local Aimbot   = LoadFolder("Aimbot")
local ESP      = LoadFolder("ESP")
local Settings = LoadFolder("Settings")

print("[NOVA] boot complete")
