local BASE  = "https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/Rivals/NovaEngine/"
local Cache = {}
local FAIL  = {}

local function HttpGet(url)
    if syn and syn.request then return syn.request({ Url = url, Method = "GET" }).Body end
    if request      then return request(     { Url = url, Method = "GET" }).Body end
    if http_request then return http_request({ Url = url, Method = "GET" }).Body end
    error("[NOVA] asnjë metodë HTTP e njohur")
end

local function LoadModule(path)
    if Cache[path] ~= nil then
        return Cache[path] == FAIL and nil or Cache[path]
    end
    local ok, src = pcall(HttpGet, BASE .. path)
    if not ok or type(src) ~= "string" or #src < 20
    or src:find("^%s*<!") or src:find("404: Not Found") then
        warn("[NOVA] fetch fail: " .. path .. " :: " .. tostring(src))
        Cache[path] = FAIL
        return nil
    end
    local fn, cerr = loadstring(src, "@" .. path)
    if not fn then
        warn("[NOVA] compile fail: " .. path .. " :: " .. tostring(cerr))
        Cache[path] = FAIL
        return nil
    end
    local rok, res = pcall(fn)
    if not rok then
        warn("[NOVA] runtime fail: " .. path .. " :: " .. tostring(res))
        Cache[path] = FAIL
        return nil
    end
    Cache[path] = res ~= nil and res or FAIL
    return Cache[path] == FAIL and nil or Cache[path]
end

local function Need(path)
    local m = LoadModule(path)
    if m == nil then error("[NOVA] module missing: " .. path) end
    return m
end

-- ===== LOADING SCREEN =====
local Players   = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local loadGui = Instance.new("ScreenGui")
loadGui.Name          = "NovaLoader"
loadGui.ResetOnSpawn  = false
loadGui.IgnoreGuiInset = true
loadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadGui.Parent        = playerGui

local bg = Instance.new("Frame")
bg.Size                   = UDim2.fromScale(1, 1)
bg.BackgroundColor3       = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.25
bg.BorderSizePixel        = 0
bg.Parent                 = loadGui

-- Logo N
local logoFrame = Instance.new("Frame")
logoFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
logoFrame.Position         = UDim2.new(0.5, 0, 0.42, 0)
logoFrame.Size             = UDim2.fromOffset(54, 54)
logoFrame.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
logoFrame.BorderSizePixel  = 0
logoFrame.Parent           = bg
local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0, 14)
lc.Parent = logoFrame
local logoText = Instance.new("TextLabel")
logoText.Size                   = UDim2.fromScale(1, 1)
logoText.BackgroundTransparency = 1
logoText.Text                   = "N"
logoText.TextColor3             = Color3.new(1, 1, 1)
logoText.Font                   = Enum.Font.GothamBold
logoText.TextSize               = 30
logoText.Parent                 = logoFrame

-- Nova Scripts
local titleLbl = Instance.new("TextLabel")
titleLbl.AnchorPoint          = Vector2.new(0.5, 0)
titleLbl.Position             = UDim2.new(0.5, 0, 0.42, 64)
titleLbl.Size                 = UDim2.new(0, 300, 0, 30)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                 = "Nova Scripts"
titleLbl.TextColor3           = Color3.new(1, 1, 1)
titleLbl.Font                 = Enum.Font.GothamBold
titleLbl.TextSize             = 22
titleLbl.Parent               = bg

-- Loading Script
local subLbl = Instance.new("TextLabel")
subLbl.AnchorPoint          = Vector2.new(0.5, 0)
subLbl.Position             = UDim2.new(0.5, 0, 0.42, 100)
subLbl.Size                 = UDim2.new(0, 300, 0, 22)
subLbl.BackgroundTransparency = 1
subLbl.Text                 = "Loading Script"
subLbl.TextColor3           = Color3.fromRGB(160, 160, 176)
subLbl.Font                 = Enum.Font.GothamMedium
subLbl.TextSize             = 14
subLbl.Parent               = bg

-- progress bar track
local barTrack = Instance.new("Frame")
barTrack.AnchorPoint      = Vector2.new(0.5, 0)
barTrack.Position         = UDim2.new(0.5, 0, 0.42, 134)
barTrack.Size             = UDim2.new(0, 220, 0, 5)
barTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
barTrack.BorderSizePixel  = 0
barTrack.Parent           = bg
local btc = Instance.new("UICorner"); btc.CornerRadius = UDim.new(0,5); btc.Parent = barTrack

local barFill = Instance.new("Frame")
barFill.Size             = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
barFill.BorderSizePixel  = 0
barFill.Parent           = barTrack
local bfc = Instance.new("UICorner"); bfc.CornerRadius = UDim.new(0,5); bfc.Parent = barFill

-- lista e moduleve me peshë
local modules = {
    { path = "Config.lua",                  w = 1 },
    { path = "Core/Theme.lua",              w = 1 },
    { path = "Core/Helpers.lua",            w = 1 },
    { path = "Core/Drag.lua",               w = 1 },
    { path = "GUI/Builder.lua",             w = 2 },
    { path = "GUI/Nav.lua",                 w = 1 },
    { path = "GUI/Profile.lua",             w = 1 },
    { path = "GUI/CloseModal.lua",          w = 1 },
    { path = "GUI/Widgets/Toggle.lua",      w = 1 },
    { path = "GUI/Widgets/Slider.lua",      w = 1 },
    { path = "GUI/Widgets/Dropdown.lua",    w = 1 },
    { path = "GUI/Widgets/Keybind.lua",     w = 1 },
    { path = "GUI/Widgets/ColorPicker.lua", w = 1 },
    { path = "Aimbot/FOV.lua",              w = 1 },
    { path = "Aimbot/Aimbot.lua",           w = 1 },
    { path = "ESP/Markers.lua",             w = 1 },
    { path = "ESP/Distance.lua",            w = 1 },
    { path = "ESP/Lines.lua",               w = 1 },
    { path = "ESP/Skeleton.lua",            w = 1 },
    { path = "ESP/DisplayRange.lua",        w = 1 },
    { path = "Settings/InterfaceScale.lua", w = 1 },
    { path = "Settings/Keybind.lua",        w = 1 },
}

local totalW   = 0
for _, m in ipairs(modules) do totalW = totalW + m.w end
local loaded   = {}
local doneW    = 0

local function setProgress(pct)
    TweenService:Create(barFill,
        TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.new(pct, 0, 1, 0) }
    ):Play()
end

-- pre-load të gjitha modulet me progress
for _, m in ipairs(modules) do
    loaded[m.path] = LoadModule(m.path)
    doneW = doneW + m.w
    setProgress(doneW / totalW)
    task.wait()  -- lë frame të renderohet
end

-- ===== BUILD =====
local ok, err = pcall(function()
local config = loaded["Config.lua"]

if config == nil then
    error("Config.lua failed to load. Check the download and compilation errors above.")
end

if type(config) ~= "table" then
    error("Config.lua returned " .. type(config) .. " instead of a table.")
end
    local BuildTheme = loaded["Core/Theme.lua"]        or error("Core/Theme.lua")
    local BuildH     = loaded["Core/Helpers.lua"]      or error("Core/Helpers.lua")

    local theme = BuildTheme(config)
    local H     = BuildH(theme)
    local tween = H.Tween(config, TweenService)

    local refs  = (loaded["GUI/Builder.lua"])(H, theme, config)

    local function CreatePage(name)
        local page = H.Create("ScrollingFrame", {
            Name                   = name,
            Size                   = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = theme.Accent,
            CanvasSize             = UDim2.new(),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = false,
        }, refs.contentArea)
        H.Pad(page, 4)
        H.Create("UIListLayout", {
            Padding   = UDim.new(0,12),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        return page
    end

    local pages = {
        Aimbot   = CreatePage("Aimbot"),
        ESP      = CreatePage("ESP"),
        Settings = CreatePage("Settings"),
    }

    local MakeToggle             = loaded["GUI/Widgets/Toggle.lua"](H, theme, tween)
    local MakeSlider             = loaded["GUI/Widgets/Slider.lua"](H, theme, tween)
    local MakeDropdown           = loaded["GUI/Widgets/Dropdown.lua"](H, theme)
    local MakeKeybind            = loaded["GUI/Widgets/Keybind.lua"](H, theme)
    local MakeColor, ApplyAccent = loaded["GUI/Widgets/ColorPicker.lua"](H, theme, tween, refs.gui)

    local fov = loaded["Aimbot/FOV.lua"](config)

    local controls = {}

    -- Aimbot
    controls.AimbotEnabled = MakeToggle(pages.Aimbot, "Enable Aimbot",  false, "AimbotEnabled", config)
    controls.FieldOfView   = MakeSlider(pages.Aimbot, "Field of View",  10, 300, 90, "FieldOfView",  config)
    controls.Sensitivity   = MakeSlider(pages.Aimbot, "Sensitivity",    1, 100,  50, "Sensitivity",  config)
    controls.AimbotMode    = MakeDropdown(pages.Aimbot,"Aimbot Mode",   {"Head","Body"}, "AimbotMode", config)
    controls.AimbotAccent  = MakeColor(pages.Aimbot,  "FOV Color",      "AimbotAccent", config,
        function(col) fov.Raw.Color = col end)

    -- ESP — një color picker për të gjitha ngjyrat ESP
    controls.ShowMarkers   = MakeToggle(pages.ESP, "Show Markers",      true,  "ShowMarkers",  config)
    controls.ShowNames     = MakeToggle(pages.ESP, "Show Names",        true,  "ShowNames",    config)
    controls.ShowDistance  = MakeToggle(pages.ESP, "Show Distance",     false, "ShowDistance", config)
    controls.ShowLines     = MakeToggle(pages.ESP, "Show Lines",        false, "ShowLines",    config)
    controls.ShowSkeleton  = MakeToggle(pages.ESP, "Show Skeleton",     false, "ShowSkeleton", config)
    -- një picker, ndryshon ESPColor që përdoret nga të gjitha
    controls.ESPColor      = MakeColor(pages.ESP, "ESP Color",
        {"ESPColor","MarkerColor","LineColor","SkeletonColor"}, config)

    -- Settings
    controls.InterfaceScale = MakeDropdown(pages.Settings, "Interface Scale",
        {"Small","Medium","Big"}, "InterfaceScale", config,
        loaded["Settings/InterfaceScale.lua"](refs.uiScale, tween))
    controls.ToggleKey      = MakeKeybind(pages.Settings, "Toggle GUI Key", "ToggleKey", config)
    controls.ThemeAccent    = MakeColor(pages.Settings, "Theme Accent",  "ThemeAccent", config,
        function(col) ApplyAccent(col, refs.mainStroke, refs.logo, fov.Raw, pages) end)

    -- set Medium në fillim
    refs.uiScale.Scale = 0.9

    local espCache = {}
    local Lines    = loaded["ESP/Lines.lua"]()
    local Skeleton = loaded["ESP/Skeleton.lua"]()

    local closeHandle = loaded["GUI/CloseModal.lua"](
        H, theme, tween, refs.main, refs.gui, controls, fov.Raw, config, espCache, Lines, Skeleton)
    refs.close.MouseButton1Click:Connect(closeHandle.showWarning)

    loaded["GUI/Profile.lua"](H, theme, refs.sideContent)
    local SelectTab = loaded["GUI/Nav.lua"](H, theme, tween, refs.nav, pages, refs.heading, refs.breadcrumb)
    loaded["Core/Drag.lua"](refs.header, refs.main)

    local Markers  = loaded["ESP/Markers.lua"]
    local Distance = loaded["ESP/Distance.lua"]
    loaded["ESP/DisplayRange.lua"](config, espCache, Markers, Distance, Lines, Skeleton, closeHandle.closed)

    loaded["Aimbot/Aimbot.lua"](config, fov, refs.main, closeHandle.closed)
    loaded["Settings/Keybind.lua"](config, refs.main)

    SelectTab("Aimbot")

    -- fshi loading screen me fade
    task.delay(0.1, function()
        TweenService:Create(bg,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1 }
        ):Play()
        for _, child in ipairs(bg:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then
                pcall(function()
                    TweenService:Create(child,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quint),
                        { BackgroundTransparency = 1, TextTransparency = 1 }
                    ):Play()
                end)
            end
        end
        task.delay(0.45, function() loadGui:Destroy() end)
    end)
end)

if not ok then
    pcall(function() loadGui:Destroy() end)
    local sg             = Instance.new("ScreenGui")
    sg.Name              = "NovaBootError"
    sg.ResetOnSpawn      = false
    sg.Parent            = playerGui
    local lbl            = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1,0,0,80)
    lbl.Position         = UDim2.new(0,0,0.45,0)
    lbl.BackgroundColor3 = Color3.fromRGB(18,0,0)
    lbl.TextColor3       = Color3.fromRGB(255,80,80)
    lbl.TextScaled       = true
    lbl.TextWrapped      = true
    lbl.Text             = "[NOVA BOOT ERROR] " .. tostring(err)
    lbl.Parent           = sg
end