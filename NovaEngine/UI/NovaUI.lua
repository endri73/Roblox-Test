-- NovaEngine/UI/NovaUI.lua
-- NOVA / compact modern interface
-- Keeps the existing NovaUI.new(config) callback contract.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
    bg = Color3.fromRGB(12, 14, 19),
    panel = Color3.fromRGB(18, 21, 29),
    card = Color3.fromRGB(24, 28, 38),
    cardHover = Color3.fromRGB(30, 35, 47),
    line = Color3.fromRGB(43, 49, 64),
    text = Color3.fromRGB(239, 242, 250),
    muted = Color3.fromRGB(135, 145, 164),
    accent = Color3.fromRGB(104, 124, 255),
    accentSoft = Color3.fromRGB(42, 51, 91),
    red = Color3.fromRGB(255, 95, 110),
    green = Color3.fromRGB(78, 210, 155),
}
local FONT = Enum.Font.GothamMedium
local BOLD = Enum.Font.GothamBold

local UI = {}
UI.__index = UI

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function stroke(parent, color, transparency)
    return make("UIStroke", {
        Color = color or C.line,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
end

local function pad(parent, left, right, top, bottom)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, parent)
end

local function animate(obj, props, duration)
    local t = TweenService:Create(obj, TweenInfo.new(duration or .18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function label(parent, text, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or C.text,
        TextSize = size or 13,
        Font = font or FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function card(parent, height, order)
    local f = make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        LayoutOrder = order or 0,
    }, parent)
    corner(f, 11)
    stroke(f, C.line, .35)
    return f
end

local function section(parent, title, subtitle, order)
    local f = make("Frame", {
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundTransparency = 1,
        LayoutOrder = order or 0,
    }, parent)
    local t = label(f, title, 15, C.text, BOLD)
    t.Size = UDim2.new(1, 0, 0, 22)
    local s = label(f, subtitle or "", 11, C.muted)
    s.Position = UDim2.fromOffset(0, 22)
    s.Size = UDim2.new(1, 0, 0, 17)
    return f
end

local function page(parent)
    local p = make("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, parent)
    pad(p, 2, 10, 4, 12)
    make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, p)
    return p
end

local function toggle(parent, title, description, default, order, callback)
    local f = card(parent, description and 62 or 50, order)
    local name = label(f, title, 13, C.text, BOLD)
    name.Position = UDim2.fromOffset(13, description and 9 or 0)
    name.Size = UDim2.new(1, -75, 0, description and 21 or 50)

    if description then
        local sub = label(f, description, 10, C.muted)
        sub.Position = UDim2.fromOffset(13, 31)
        sub.Size = UDim2.new(1, -75, 0, 17)
    end

    local track = make("Frame", {
        Size = UDim2.fromOffset(39, 22),
        Position = UDim2.new(1, -14, .5, 0),
        AnchorPoint = Vector2.new(1, .5),
        BackgroundColor3 = C.line,
        BorderSizePixel = 0,
    }, f)
    corner(track, 20)

    local knob = make("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = C.text,
        BorderSizePixel = 0,
    }, track)
    corner(knob, 20)

    local state = default == true
    local function set(value, instant)
        state = value
        local pos = state and UDim2.fromOffset(20, 3) or UDim2.fromOffset(3, 3)
        local color = state and C.accent or C.line
        if instant then
            knob.Position, track.BackgroundColor3 = pos, color
        else
            animate(knob, {Position = pos})
            animate(track, {BackgroundColor3 = color})
        end
    end
    set(state, true)

    local hit = make("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, f)
    hit.Activated:Connect(function()
        set(not state)
        if callback then callback(state) end
    end)
    hit.MouseEnter:Connect(function() animate(f, {BackgroundColor3 = C.cardHover}) end)
    hit.MouseLeave:Connect(function() animate(f, {BackgroundColor3 = C.card}) end)
    return f
end

local function slider(parent, title, min, max, default, order, callback)
    local f = card(parent, 69, order)
    local name = label(f, title, 13, C.text, BOLD)
    name.Position = UDim2.fromOffset(13, 7)
    name.Size = UDim2.new(1, -90, 0, 22)

    local valueText = label(f, tostring(default), 12, C.accent, BOLD)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Position = UDim2.new(1, -70, 0, 7)
    valueText.Size = UDim2.fromOffset(56, 22)

    local track = make("Frame", {
        Position = UDim2.fromOffset(13, 43),
        Size = UDim2.new(1, -26, 0, 5),
        BackgroundColor3 = C.line,
        BorderSizePixel = 0,
    }, f)
    corner(track, 10)

    local fill = make("Frame", {
        Size = UDim2.fromScale(math.clamp((default - min) / (max - min), 0, 1), 1),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
    }, track)
    corner(fill, 10)

    local dot = make("Frame", {
        Size = UDim2.fromOffset(13, 13),
        Position = UDim2.new(fill.Size.X.Scale, -6, .5, 0),
        AnchorPoint = Vector2.new(0, .5),
        BackgroundColor3 = C.text,
        BorderSizePixel = 0,
    }, track)
    corner(dot, 20)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local value = math.floor(min + (max - min) * rel + .5)
        fill.Size = UDim2.fromScale(rel, 1)
        dot.Position = UDim2.new(rel, -6, .5, 0)
        valueText.Text = tostring(value)
        if callback then callback(value) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    local moveConn = UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    local endConn = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    f.Destroying:Connect(function()
        moveConn:Disconnect()
        endConn:Disconnect()
    end)
    return f
end

local function segmented(parent, title, options, default, order, callback)
    local f = card(parent, 58, order)
    local name = label(f, title, 13, C.text, BOLD)
    name.Position = UDim2.fromOffset(13, 0)
    name.Size = UDim2.new(1, -20, 0, 23)

    local holder = make("Frame", {
        Position = UDim2.fromOffset(10, 28),
        Size = UDim2.new(1, -20, 0, 24),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
    }, f)
    corner(holder, 7)
    local layout = make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, holder)
    local buttons, selected = {}, default

    local function choose(value)
        selected = value
        for option, button in pairs(buttons) do
            local active = option == value
            animate(button, {
                BackgroundColor3 = active and C.accent or C.bg,
                TextColor3 = active and C.text or C.muted,
            }, .14)
        end
    end

    for i, option in ipairs(options) do
        local b = make("TextButton", {
            Size = UDim2.new(1 / #options, -3, 1, 0),
            BackgroundColor3 = C.bg,
            Text = option,
            TextColor3 = C.muted,
            TextSize = 11,
            Font = FONT,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = i,
        }, holder)
        corner(b, 5)
        buttons[option] = b
        b.Activated:Connect(function()
            choose(option)
            if callback then callback(option) end
        end)
    end
    choose(default)
    return f
end

local function keybind(parent, title, order, callback)
    local f = card(parent, 50, order)
    local name = label(f, title, 13, C.text, BOLD)
    name.Position = UDim2.fromOffset(13, 0)
    name.Size = UDim2.new(1, -125, 1, 0)

    local button = make("TextButton", {
        Size = UDim2.fromOffset(94, 29),
        Position = UDim2.new(1, -11, .5, 0),
        AnchorPoint = Vector2.new(1, .5),
        BackgroundColor3 = C.bg,
        Text = "None",
        TextColor3 = C.muted,
        TextSize = 11,
        Font = BOLD,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, f)
    corner(button, 7)

    local listening, current = false, nil
    button.Activated:Connect(function()
        listening = true
        button.Text = "Press key..."
        button.TextColor3 = C.accent
    end)
    local connection = UIS.InputBegan:Connect(function(input, processed)
        if not listening or processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        current = input.KeyCode
        button.Text = current.Name
        button.TextColor3 = C.text
        if callback then callback(current) end
    end)
    f.Destroying:Connect(function() connection:Disconnect() end)
    return {getKey = function() return current end}
end

local function colorPicker(parent, gui, title, default, order, callback)
    local f = card(parent, 50, order)
    local name = label(f, title, 13, C.text, BOLD)
    name.Position = UDim2.fromOffset(13, 0)
    name.Size = UDim2.new(1, -65, 1, 0)

    local swatch = make("TextButton", {
        Size = UDim2.fromOffset(27, 27),
        Position = UDim2.new(1, -12, .5, 0),
        AnchorPoint = Vector2.new(1, .5),
        BackgroundColor3 = default,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, f)
    corner(swatch, 7)
    stroke(swatch, C.line, .1)

    local palette = {
        Color3.fromRGB(104,124,255), Color3.fromRGB(0,195,255),
        Color3.fromRGB(78,210,155), Color3.fromRGB(255,190,80),
        Color3.fromRGB(255,95,110), Color3.fromRGB(210,110,255),
        Color3.fromRGB(245,245,250), Color3.fromRGB(130,145,165),
    }
    local popup
    swatch.Activated:Connect(function()
        if popup then popup:Destroy(); popup = nil; return end
        popup = make("Frame", {
            Size = UDim2.fromOffset(166, 78),
            Position = UDim2.new(1, -178, 1, 5),
            BackgroundColor3 = C.panel,
            BorderSizePixel = 0,
            ZIndex = 20,
        }, gui)
        corner(popup, 10)
        stroke(popup, C.line, 0)
        pad(popup, 9, 9, 9, 9)
        make("UIGridLayout", {
            CellSize = UDim2.fromOffset(29, 25),
            CellPadding = UDim2.fromOffset(7, 7),
        }, popup)
        for _, color in ipairs(palette) do
            local b = make("TextButton", {
                BackgroundColor3 = color,
                Text = "",
                BorderSizePixel = 0,
                ZIndex = 21,
            }, popup)
            corner(b, 6)
            b.Activated:Connect(function()
                swatch.BackgroundColor3 = color
                popup:Destroy()
                popup = nil
                if callback then callback(color) end
            end)
        end
    end)
    return f
end

function UI.new(config)
    local self = setmetatable({}, UI)
    self._config = config or {}
    self._pages, self._tabs = {}, {}
    self._activeTab = nil
    self.Keybind = nil

    local gui = make("ScreenGui", {
        Name = "NovaUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    }, playerGui)
    self.Gui = gui

    local scale = make("UIScale", {Scale = 1}, nil)
    self.Scale = scale

    local root = make("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(690, 470),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    scale.Parent = root
    corner(root, 15)
    stroke(root, C.line, .05)
    self.Window = root

    local top = make("Frame", {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, root)
    local accentBar = make("Frame", {
        Size = UDim2.new(0, 3, 0, 31),
        Position = UDim2.fromOffset(0, 17),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
    }, top)
    corner(accentBar, 5)

    local brand = label(top, "NOVA", 18, C.text, BOLD)
    brand.Position = UDim2.fromOffset(22, 9)
    brand.Size = UDim2.fromOffset(100, 25)
    local sub = label(top, "CONTROL CENTER  /  v2.0", 9, C.muted, BOLD)
    sub.Position = UDim2.fromOffset(23, 34)
    sub.Size = UDim2.fromOffset(190, 16)

    local statusDot = make("Frame", {
        Size = UDim2.fromOffset(7, 7),
        Position = UDim2.new(1, -93, .5, -3),
        BackgroundColor3 = C.green,
        BorderSizePixel = 0,
    }, top)
    corner(statusDot, 10)
    local status = label(top, "READY", 10, C.muted, BOLD)
    status.Position = UDim2.new(1, -80, .5, -9)
    status.Size = UDim2.fromOffset(48, 18)

    local close = make("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -42, .5, 0),
        AnchorPoint = Vector2.new(0, .5),
        BackgroundColor3 = C.card,
        Text = "×",
        TextColor3 = C.muted,
        TextSize = 19,
        Font = FONT,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, top)
    corner(close, 8)
    close.Activated:Connect(function() self:Close() end)
    close.MouseEnter:Connect(function() animate(close, {BackgroundColor3 = C.red, TextColor3 = C.text}) end)
    close.MouseLeave:Connect(function() animate(close, {BackgroundColor3 = C.card, TextColor3 = C.muted}) end)

    local sidebar = make("Frame", {
        Position = UDim2.fromOffset(12, 77),
        Size = UDim2.new(0, 158, 1, -89),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, root)
    corner(sidebar, 11)
    pad(sidebar, 8, 8, 12, 8)
    make("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)

    local content = make("Frame", {
        Position = UDim2.fromOffset(183, 77),
        Size = UDim2.new(1, -195, 1, -89),
        BackgroundTransparency = 1,
    }, root)
    self.Content = content

    local tabs = {
        {"aimbot", "◈", "AIMBOT"},
        {"combat", "◎", "VISUALS"},
        {"settings", "⚙", "SETTINGS"},
    }

    for i, def in ipairs(tabs) do
        local id, iconText, title = def[1], def[2], def[3]
        local b = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 43),
            BackgroundColor3 = C.panel,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = i,
        }, sidebar)
        corner(b, 8)

        local mark = label(b, iconText, 16, C.muted, BOLD)
        mark.Position = UDim2.fromOffset(10, 0)
        mark.Size = UDim2.fromOffset(22, 43)
        local txt = label(b, title, 11, C.muted, BOLD)
        txt.Position = UDim2.fromOffset(39, 0)
        txt.Size = UDim2.new(1, -45, 1, 0)

        local indicator = make("Frame", {
            Size = UDim2.fromOffset(3, 19),
            Position = UDim2.new(0, 0, .5, 0),
            AnchorPoint = Vector2.new(0, .5),
            BackgroundColor3 = C.accent,
            BorderSizePixel = 0,
            Visible = false,
        }, b)
        corner(indicator, 5)

        local p = page(content)
        self._pages[id] = p
        self._tabs[id] = {button = b, icon = mark, label = txt, indicator = indicator}
        b.Activated:Connect(function() self:SelectTab(id) end)
        b.MouseEnter:Connect(function()
            if self._activeTab ~= id then animate(b, {BackgroundColor3 = C.card}) end
        end)
        b.MouseLeave:Connect(function()
            if self._activeTab ~= id then animate(b, {BackgroundColor3 = C.panel}) end
        end)
    end

    local cfg = self._config
    local onToggle, onSlider = cfg.onToggle, cfg.onSlider
    local onChoice, onColor = cfg.onChoice, cfg.onColor

    section(self._pages.aimbot, "Aim assistance", "Configure targeting preferences", 1)
    toggle(self._pages.aimbot, "Aimbot", "Enable or disable the feature", false, 2, function(v)
        if onToggle then onToggle("aimbot", v) end
    end)
    toggle(self._pages.aimbot, "Aim FOV", "Show the field-of-view radius", false, 3, function(v)
        if onToggle then onToggle("aimfov", v) end
    end)
    slider(self._pages.aimbot, "FOV radius", 40, 400, 120, 4, function(v)
        if onSlider then onSlider("fovradius", v) end
    end)
    segmented(self._pages.aimbot, "Target point", {"Head", "Body"}, "Head", 5, function(v)
        if onChoice then onChoice("targetmode", v) end
    end)

    section(self._pages.combat, "Visual options", "Customize on-screen indicators", 1)
    toggle(self._pages.combat, "Player markers", "Display player markers", false, 2, function(v)
        if onToggle then onToggle("markers", v) end
    end)
    toggle(self._pages.combat, "Player names", "Display player names", false, 3, function(v)
        if onToggle then onToggle("names", v) end
    end)
    toggle(self._pages.combat, "Distance", "Display distance labels", false, 4, function(v)
        if onToggle then onToggle("distance", v) end
    end)
    toggle(self._pages.combat, "Tracer lines", "Display directional lines", false, 5, function(v)
        if onToggle then onToggle("lines", v) end
    end)
    toggle(self._pages.combat, "Skeleton", "Display player skeletons", false, 6, function(v)
        if onToggle then onToggle("skeleton", v) end
    end)
    colorPicker(self._pages.combat, gui, "Visual color", C.accent, 7, function(v)
        if onColor then onColor("espcolor", v) end
    end)

    section(self._pages.settings, "Preferences", "Personalize the interface", 1)
    segmented(self._pages.settings, "Interface scale", {"Small", "Medium", "Big"}, "Medium", 2, function(v)
        self:SetScale(v)
        if onChoice then onChoice("scale", v) end
    end)
    self._keyControl = keybind(self._pages.settings, "Toggle menu key", 3, function(key)
        self.Keybind = key
    end)

    -- Drag from the top bar.
    local dragging, dragStart, startPos = false, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, root.Position
        end
    end)
    local dragMove = UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local dragEnd = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    root.Destroying:Connect(function()
        dragMove:Disconnect()
        dragEnd:Disconnect()
    end)

    self:ApplyKeybind()
    self:SelectTab("aimbot")
    self:Open()
    return self
end

function UI:ApplyKeybind()
    if self._keyConnection then self._keyConnection:Disconnect() end
    self._keyConnection = UIS.InputBegan:Connect(function(input, processed)
        if not processed and self.Keybind and input.KeyCode == self.Keybind then
            self:Toggle()
        end
    end)
end

function UI:SelectTab(id)
    if self._activeTab == id or not self._pages[id] then return end
    self._activeTab = id
    for tabId, parts in pairs(self._tabs) do
        local active = tabId == id
        animate(parts.button, {BackgroundColor3 = active and C.accentSoft or C.panel})
        animate(parts.icon, {TextColor3 = active and C.accent or C.muted})
        animate(parts.label, {TextColor3 = active and C.text or C.muted})
        parts.indicator.Visible = active
        self._pages[tabId].Visible = active
        if active then self._pages[tabId].CanvasPosition = Vector2.zero end
    end
end

function UI:SetScale(option)
    local values = {Small = .88, Medium = 1, Big = 1.12}
    animate(self.Scale, {Scale = values[option] or 1}, .2)
end

function UI:Open()
    self.Gui.Enabled = true
    self.Window.Visible = true
    self.Window.Size = UDim2.fromOffset(660, 445)
    animate(self.Window, {Size = UDim2.fromOffset(690, 470)}, .22)
end

function UI:Close()
    local t = animate(self.Window, {Size = UDim2.fromOffset(660, 445)}, .16)
    t.Completed:Once(function()
        if self.Gui then self.Gui.Enabled = false end
    end)
end

function UI:Toggle()
    if self.Gui.Enabled then self:Close() else self:Open() end
end

function UI:SetVisible(state)
    if state then self:Open() else self:Close() end
end

function UI:Destroy()
    if self._keyConnection then
        self._keyConnection:Disconnect()
        self._keyConnection = nil
    end
    if self.Gui then self.Gui:Destroy() end
end

return UI
