local BASE = "https://raw.githubusercontent.com/endri73/Roblox-Test/refs/heads/main/Rivals/NovaEngine/Main.lua"
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
        warn("[NOVA] fetch fail: " .. path)
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

-- boot
local ok, err = pcall(function()
    local TweenService = game:GetService("TweenService")

    local config     = Need("Config.lua")
    local BuildTheme = Need("Core/Theme.lua")
    local BuildH     = Need("Core/Helpers.lua")
    local BuildDrag  = Need("Core/Drag.lua")

    local theme  = BuildTheme(config)
    local H      = BuildH(theme)
    local tween  = H.Tween(config, TweenService)

    local BuildGUI     = Need("GUI/Builder.lua")
    local refs         = BuildGUI(H, theme, config)

    -- pages
    local function CreatePage(name)
        local page = H.Create("ScrollingFrame", {
            Name                    = name,
            Size                    = UDim2.fromScale(1, 1),
            BackgroundTransparency  = 1,
            BorderSizePixel         = 0,
            ScrollBarThickness      = 3,
            ScrollBarImageColor3    = theme.Accent,
            CanvasSize              = UDim2.new(),
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
            Visible                 = false,
        }, refs.contentArea)
        H.Pad(page, 4)
        H.Create("UIListLayout", {
            Padding   = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)
        return page
    end

    local pages = {
        Aimbot   = CreatePage("Aimbot"),
        ESP      = CreatePage("ESP"),
        Settings = CreatePage("Settings"),
    }

    -- widgets
    local MakeToggle      = Need("GUI/Widgets/Toggle.lua")(H, theme, tween)
    local MakeSlider      = Need("GUI/Widgets/Slider.lua")(H, theme, tween)
    local MakeDropdown    = Need("GUI/Widgets/Dropdown.lua")(H, theme)
    local MakeKeybind     = Need("GUI/Widgets/Keybind.lua")(H, theme)
    local MakeColor, ApplyAccent = Need("GUI/Widgets/ColorPicker.lua")(H, theme, tween, refs.gui)

    -- FOV
    local BuildFOV = Need("Aimbot/FOV.lua")
    local fov      = BuildFOV(config)

    -- controls
    local controls = {}
    controls.AimbotEnabled  = MakeToggle(pages.Aimbot,   "Enable Feature",    false, "AimbotEnabled",  config)
    controls.FieldOfView    = MakeSlider(pages.Aimbot,   "Field of View",     10, 300, 90,  "FieldOfView",   config)
    controls.Sensitivity    = MakeSlider(pages.Aimbot,   "Sensitivity",       1, 100,  50,  "Sensitivity",   config)
    controls.TargetMode     = MakeDropdown(pages.Aimbot, "Target Mode",       {"Default","Nearest","Custom"}, "TargetMode", config)
    controls.AimbotAccent   = MakeColor(pages.Aimbot,    "Accent Color",      "AimbotAccent", config)

    controls.ShowMarkers    = MakeToggle(pages.ESP,      "Show Markers",      true,  "ShowMarkers",  config)
    controls.ShowNames      = MakeToggle(pages.ESP,      "Show Names",        true,  "ShowNames",    config)
    controls.ShowDistance   = MakeToggle(pages.ESP,      "Show Distance",     false, "ShowDistance", config)
    controls.MarkerColor    = MakeColor(pages.ESP,       "Marker Color",      "MarkerColor", config)
    controls.DisplayRange   = MakeSlider(pages.ESP,      "Display Range",     50, 1000, 500, "DisplayRange", config)

    controls.UIAnimations   = MakeToggle(pages.Settings, "UI Animations",     true,  "UIAnimations",   config)
    controls.PerformanceMode= MakeToggle(pages.Settings, "Performance Mode",  false, "PerformanceMode",config)
    controls.InterfaceScale = MakeDropdown(pages.Settings,"Interface Scale",  {"Smaller","Small","Medium"}, "InterfaceScale", config,
        Need("Settings/InterfaceScale.lua")(refs.uiScale, tween))
    controls.ToggleKey      = MakeKeybind(pages.Settings, "Toggle GUI Key",   "ToggleKey", config)
    controls.ThemeAccent    = MakeColor(pages.Settings,  "Theme Accent",      "ThemeAccent", config,
        function(color) ApplyAccent(color, refs.mainStroke, refs.logo, fov.Raw, pages) end)

    -- close modal
    local BuildClose  = Need("GUI/CloseModal.lua")
    local closeHandle = BuildClose(H, theme, tween, refs.main, refs.gui, controls, fov.Raw, config)
    refs.close.MouseButton1Click:Connect(closeHandle.showWarning)

    -- profile, nav, drag
    Need("GUI/Profile.lua")(H, theme, refs.sideContent)
    local SelectTab = Need("GUI/Nav.lua")(H, theme, tween, refs.nav, pages, refs.heading, refs.breadcrumb)
    Need("Core/Drag.lua")(refs.header, refs.main)

    -- ESP
    local espCache   = {}
    local Markers    = Need("ESP/Markers.lua")
    local Distance   = Need("ESP/Distance.lua")
    Need("ESP/DisplayRange.lua")(config, espCache, Markers, Distance, closeHandle.closed)

    -- aimbot loop
    Need("Aimbot/Aimbot.lua")(config, fov, refs.main, closeHandle.closed)

    -- settings keybind
    Need("Settings/Keybind.lua")(config, refs.main)

    SelectTab("Aimbot")
end)

if not ok then
    -- error visible në screen
    local sg    = Instance.new("ScreenGui")
    sg.Name     = "NovaBootError"
    sg.ResetOnSpawn = false
    sg.Parent   = game:GetService("CoreGui")
    local lbl   = Instance.new("TextLabel")
    lbl.Size    = UDim2.new(1, 0, 0, 80)
    lbl.Position = UDim2.new(0, 0, 0.45, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(18, 0, 0)
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    lbl.TextScaled = true
    lbl.TextWrapped = true
    lbl.Text   = "[NOVA BOOT ERROR] " .. tostring(err)
    lbl.Parent = sg
end
