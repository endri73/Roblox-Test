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

-- ===== LOADING SCREEN =====
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player       = Players.LocalPlayer
local playerGui    = player:WaitForChild("PlayerGui")

local loadGui = Instance.new("ScreenGui")
loadGui.Name           = "NovaLoader"
loadGui.ResetOnSpawn   = false
loadGui.IgnoreGuiInset = true
loadGui.Parent         = playerGui

local bg = Instance.new("Frame")
bg.Size                   = UDim2.fromScale(1,1)
bg.BackgroundColor3       = Color3.new(0,0,0)
bg.BackgroundTransparency = 0.25
bg.BorderSizePixel        = 0
bg.Parent                 = loadGui

local function makeLbl(text, yOff, size, color, bold)
    local l = Instance.new("TextLabel")
    l.AnchorPoint          = Vector2.new(0.5, 0)
    l.Position             = UDim2.new(0.5, 0, 0.42, yOff)
    l.Size                 = UDim2.new(0, 300, 0, size + 6)
    l.BackgroundTransparency = 1
    l.Text                 = text
    l.TextColor3           = color or Color3.new(1,1,1)
    l.Font                 = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    l.TextSize             = size
    l.Parent               = bg
    return l
end

local logoFrame = Instance.new("Frame")
logoFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
logoFrame.Position         = UDim2.new(0.5, 0, 0.42, 0)
logoFrame.Size             = UDim2.fromOffset(54, 54)
logoFrame.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
logoFrame.BorderSizePixel  = 0
logoFrame.Parent           = bg
local _uc = Instance.new("UICorner"); _uc.CornerRadius = UDim.new(0,14); _uc.Parent = logoFrame
local _nl = Instance.new("TextLabel")
_nl.Size = UDim2.fromScale(1,1); _nl.BackgroundTransparency = 1
_nl.Text = "N"; _nl.TextColor3 = Color3.new(1,1,1)
_nl.Font = Enum.Font.GothamBold; _nl.TextSize = 30; _nl.Parent = logoFrame

makeLbl("Nova Scripts",  64, 22, Color3.new(1,1,1),                       true)
makeLbl("Loading Script",100, 14, Color3.fromRGB(160,160,176),             false)

local barTrack = Instance.new("Frame")
barTrack.AnchorPoint      = Vector2.new(0.5, 0)
barTrack.Position         = UDim2.new(0.5, 0, 0.42, 134)
barTrack.Size             = UDim2.new(0, 220, 0, 5)
barTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
barTrack.BorderSizePixel  = 0
barTrack.Parent           = bg
local _btc = Instance.new("UICorner"); _btc.CornerRadius = UDim.new(0,5); _btc.Parent = barTrack

local barFill = Instance.new("Frame")
barFill.Size             = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
barFill.BorderSizePixel  = 0
barFill.Parent           = barTrack
local _bfc = Instance.new("UICorner"); _bfc.CornerRadius = UDim.new(0,5); _bfc.Parent = barFill

local function setProgress(pct)
    TweenService:Create(barFill,
        TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.new(math.clamp(pct,0,1), 0, 1, 0) }
    ):Play()
end

-- ===== PRE-LOAD =====
local moduleList = {
    "Config.lua",
    "Core/Theme.lua",
    "Core/Helpers.lua",
    "Core/Drag.lua",
    "GUI/Builder.lua",
    "GUI/Nav.lua",
    "GUI/Profile.lua",
    "GUI/CloseModal.lua",
    "GUI/Widgets/Toggle.lua",
    "GUI/Widgets/Slider.lua",
    "GUI/Widgets/Dropdown.lua",
    "GUI/Widgets/Keybind.lua",
    "GUI/Widgets/ColorPicker.lua",
    "Aimbot/FOV.lua",
    "Aimbot/Aimbot.lua",
    "ESP/Markers.lua",
    "ESP/Distance.lua",
    "ESP/Lines.lua",
    "ESP/Skeleton.lua",
    "ESP/DisplayRange.lua",
    "Settings/InterfaceScale.lua",
    "Settings/Keybind.lua",
}

for i, path in ipairs(moduleList) do
    LoadModule(path)
    setProgress(i / #moduleList)
    task.wait()
end

-- ===== BUILD =====
local ok, err = pcall(function()
    local config     = Need("Config.lua")
    local theme      = Need("Core/Theme.lua")(config)
    local H          = Need("Core/Helpers.lua")(theme)
    local tween      = H.Tween(config, TweenService)
    local refs       = Need("GUI/Builder.lua")(H, theme, config)

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

    local MakeToggle             = Need("GUI/Widgets/Toggle.lua")(H, theme, tween)
    local MakeSlider             = Need("GUI/Widgets/Slider.lua")(H, theme, tween)
    local MakeDropdown           = Need("GUI/Widgets/Dropdown.lua")(H, theme)
    local MakeKeybind            = Need("GUI/Widgets/Keybind.lua")(H, theme)
    local MakeColor, ApplyAccent = Need("GUI/Widgets/ColorPicker.lua")(H, theme, tween, refs.gui)

    local fov = Need("Aimbot/FOV.lua")(config)

    local controls = {}

    controls.AimbotEnabled = MakeToggle(pages.Aimbot, "Enable Aimbot",  false, "AimbotEnabled", config)
    controls.FieldOfView   = MakeSlider(pages.Aimbot, "Field of View",  10, 300, 90, "FieldOfView",  config)
    controls.Sensitivity   = MakeSlider(pages.Aimbot, "Sensitivity",    1, 100,  50, "Sensitivity",  config)
    controls.AimbotMode    = MakeDropdown(pages.Aimbot,"Aimbot Mode",   {"Head","Body"}, "AimbotMode", config)
    controls.AimbotAccent  = MakeColor(pages.Aimbot,  "FOV Color",      "AimbotAccent", config,
        function(col) fov.Raw.Color = col end)

    controls.ShowMarkers   = MakeToggle(pages.ESP, "Show Markers",  true,  "ShowMarkers",  config)
    controls.ShowNames     = MakeToggle(pages.ESP, "Show Names",    true,  "ShowNames",    config)
    controls.ShowDistance  = MakeToggle(pages.ESP, "Show Distance", false, "ShowDistance", config)
    controls.ShowLines     = MakeToggle(pages.ESP, "Show Lines",    false, "ShowLines",    config)
    controls.ShowSkeleton  = MakeToggle(pages.ESP, "Show Skeleton", false, "ShowSkeleton", config)
    controls.ESPColor      = MakeColor(pages.ESP, "ESP Color",
        {"ESPColor","MarkerColor","LineColor","SkeletonColor"}, config)

    controls.InterfaceScale = MakeDropdown(pages.Settings, "Interface Scale",
        {"Small","Medium","Big"}, "InterfaceScale", config,
        Need("Settings/InterfaceScale.lua")(refs.uiScale, tween))
    controls.ToggleKey      = MakeKeybind(pages.Settings, "Toggle GUI Key", "ToggleKey", config)
    controls.ThemeAccent    = MakeColor(pages.Settings, "Theme Accent", "ThemeAccent", config,
        function(col) ApplyAccent(col, refs.mainStroke, refs.logo, fov.Raw, pages) end)

    refs.uiScale.Scale = 0.9  -- Medium default

    local espCache = {}
    local Lines    = Need("ESP/Lines.lua")()
    local Skeleton = Need("ESP/Skeleton.lua")()

    local closeHandle = Need("GUI/CloseModal.lua")(
        H, theme, tween, refs.main, refs.gui,
        controls, fov.Raw, config, espCache, Lines, Skeleton)
    refs.close.MouseButton1Click:Connect(closeHandle.showWarning)

    Need("GUI/Profile.lua")(H, theme, refs.sideContent)
    local SelectTab = Need("GUI/Nav.lua")(
        H, theme, tween, refs.nav, pages, refs.heading, refs.breadcrumb)
    Need("Core/Drag.lua")(refs.header, refs.main)

    Need("ESP/DisplayRange.lua")(
        config, espCache,
        Need("ESP/Markers.lua"),
        Need("ESP/Distance.lua"),
        Lines, Skeleton, closeHandle.closed)

    Need("Aimbot/Aimbot.lua")(config, fov, refs.main, closeHandle.closed)
    Need("Settings/Keybind.lua")(config, refs.main)

    SelectTab("Aimbot")

    -- fade out loader
    task.delay(0.1, function()
        TweenService:Create(bg,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1 }
        ):Play()
        for _, child in ipairs(bg:GetDescendants()) do
            if child:IsA("TextLabel") then
                pcall(function()
                    TweenService:Create(child,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quint),
                        { TextTransparency = 1 }
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
