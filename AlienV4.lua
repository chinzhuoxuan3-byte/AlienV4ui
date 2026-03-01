local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlienV4_Vape"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local UI_WIDTH = 80
local UI_HEIGHT = 200
local BAR_HEIGHT = 20
local ITEM_HEIGHT = 18
local SLIDER_HEIGHT = 28
local INPUT_HEIGHT = 26

local ACCENT = Color3.fromRGB(0, 255, 120)
local ACCENT_DIM = Color3.fromRGB(0, 180, 80)
local BG = Color3.fromRGB(0, 0, 0)
local BG2 = Color3.fromRGB(10, 10, 10)
local BORDER = Color3.fromRGB(55, 55, 55)
local TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(180, 180, 180)
local TEXT_OFF = Color3.fromRGB(110, 110, 110)
local RED = Color3.fromRGB(255, 60, 60)
local YELLOW = Color3.fromRGB(255, 200, 0)
local BLUE = Color3.fromRGB(80, 140, 255)
local PURPLE = Color3.fromRGB(160, 80, 255)

local FeatureStates = {}
local FeatureCallbacks = {}
local SliderValues = {}
local DropdownValues = {}
local TextValues = {}
local KeybindValues = {}
local ColorValues = {}
local CategoryStates = {}
local ActiveSubUIs = {}
local SubUIFrames = {}
local SubUIOrder = {}
local ListeningKeybind = nil

local Notifications = {}
local NotifCount = 0

local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function mkCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 3)
    c.Parent = parent
    return c
end

local function mkStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or BORDER
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function mkPad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 3)
    p.PaddingBottom = UDim.new(0, b or 3)
    p.PaddingLeft = UDim.new(0, l or 5)
    p.PaddingRight = UDim.new(0, r or 5)
    p.Parent = parent
    return p
end

local function mkList(parent, dir, spacing)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, spacing or 0)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function mkLabel(parent, text, size, color, font, xalign)
    local l = Instance.new("TextLabel")
    l.Text = text or ""
    l.TextSize = size or 9
    l.TextColor3 = color or TEXT_WHITE
    l.Font = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.BorderSizePixel = 0
    l.Parent = parent
    return l
end

local StatusPanel = Instance.new("Frame")
StatusPanel.Name = "StatusPanel"
StatusPanel.Size = UDim2.new(0, 160, 1, 0)
StatusPanel.Position = UDim2.new(1, -165, 0, 8)
StatusPanel.BackgroundTransparency = 1
StatusPanel.BorderSizePixel = 0
StatusPanel.Parent = ScreenGui

local StatusLayout = Instance.new("UIListLayout")
StatusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
StatusLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatusLayout.Padding = UDim.new(0, 2)
StatusLayout.Parent = StatusPanel

local function updateStatusPanel()
    for _, child in ipairs(StatusPanel:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    local activeList = {}
    for name, state in pairs(FeatureStates) do
        if state then
            table.insert(activeList, name)
        end
    end
    table.sort(activeList, function(a, b)
        return #a > #b
    end)
    for i, name in ipairs(activeList) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 0, 0, 15)
        container.AutomaticSize = Enum.AutomaticSize.X
        container.BackgroundTransparency = 0.35
        container.BackgroundColor3 = BG
        container.BorderSizePixel = 0
        container.LayoutOrder = i
        container.Parent = StatusPanel

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.BackgroundTransparency = 1
        lbl.Text = name .. "  "
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextColor3 = TEXT_WHITE
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.BorderSizePixel = 0
        mkPad(lbl, 0, 0, 4, 2)
        lbl.Parent = container

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 2, 1, 0)
        bar.Position = UDim2.new(1, 0, 0, 0)
        bar.BorderSizePixel = 0
        bar.BackgroundColor3 = ACCENT
        bar.Parent = container
    end
end

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 200, 1, 0)
NotifContainer.Position = UDim2.new(0.5, -100, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.BorderSizePixel = 0
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 3)
NotifLayout.Parent = NotifContainer

local function pushNotif(title, desc, notifType, duration)
    NotifCount = NotifCount + 1
    local col = ACCENT
    if notifType == "warn" then col = YELLOW
    elseif notifType == "error" then col = RED
    elseif notifType == "info" then col = BLUE end

    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(1, 0, 0, 44)
    nf.BackgroundColor3 = BG
    nf.BackgroundTransparency = 0.2
    nf.BorderSizePixel = 0
    nf.LayoutOrder = NotifCount
    nf.Parent = NotifContainer
    mkCorner(nf, 3)
    mkStroke(nf, col, 1)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = col
    accent.BorderSizePixel = 0
    accent.Parent = nf

    local t1 = mkLabel(nf, title, 10, TEXT_WHITE, Enum.Font.GothamBold)
    t1.Size = UDim2.new(1, -10, 0, 16)
    t1.Position = UDim2.new(0, 8, 0, 4)

    local t2 = mkLabel(nf, desc or "", 9, TEXT_DIM, Enum.Font.Gotham)
    t2.Size = UDim2.new(1, -10, 0, 20)
    t2.Position = UDim2.new(0, 8, 0, 20)
    t2.TextWrapped = true

    task.delay(duration or 3, function()
        tw(nf, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.35)
        nf:Destroy()
    end)
end

local function createBaseFrame(name)
    local f = Instance.new("Frame")
    f.Name = name
    f.BackgroundColor3 = BG
    f.BackgroundTransparency = 0.45
    f.Size = UDim2.fromOffset(UI_WIDTH, UI_HEIGHT)
    f.BorderSizePixel = 0
    f.Visible = false
    f.ClipsDescendants = true
    mkStroke(f, BORDER, 1)
    return f
end

local function createTitleBar(parent, text, color)
    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, 0, 0, BAR_HEIGHT)
    bar.BackgroundColor3 = BG2
    bar.BackgroundTransparency = 0.15
    bar.BorderSizePixel = 0
    bar.Text = text
    bar.Font = Enum.Font.GothamBold
    bar.TextSize = 9
    bar.TextColor3 = color or TEXT_WHITE
    bar.AutoButtonColor = false
    bar.Parent = parent

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 1)
    accent.Position = UDim2.new(0, 0, 1, -1)
    accent.BackgroundColor3 = color or ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = bar

    return bar
end

local function createScrollContent(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -BAR_HEIGHT)
    scroll.Position = UDim2.new(0, 0, 0, BAR_HEIGHT)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 0
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.BorderSizePixel = 0
    scroll.Parent = parent
    mkList(scroll)
    return scroll
end

local function setCollapseLogic(titleBar, contentFrame, mainFrame)
    local expanded = true
    titleBar.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetH = expanded and UI_HEIGHT or BAR_HEIGHT
        tw(mainFrame, {Size = UDim2.fromOffset(UI_WIDTH, targetH)}, 0.28, Enum.EasingStyle.Quart)
        if not expanded then
            task.delay(0.15, function()
                if not expanded then contentFrame.Visible = false end
            end)
        else
            contentFrame.Visible = true
        end
    end)
end

local function createSeparatorLine(parent)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = BORDER
    sep.BackgroundTransparency = 0.4
    sep.BorderSizePixel = 0
    sep.Parent = parent
    return sep
end

local function createCategoryHeader(parent, text)
    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 14)
    hdr.BackgroundColor3 = BG2
    hdr.BackgroundTransparency = 0.3
    hdr.Text = text
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 8
    hdr.TextColor3 = ACCENT
    hdr.TextXAlignment = Enum.TextXAlignment.Center
    hdr.BorderSizePixel = 0
    hdr.Parent = parent
    return hdr
end

local function createFeatureToggle(parent, name, defaultState, callback)
    FeatureStates[name] = defaultState or false
    if callback then FeatureCallbacks[name] = callback end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    btn.BackgroundTransparency = FeatureStates[name] and 0.55 or 1
    btn.BackgroundColor3 = FeatureStates[name] and ACCENT or BG
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 9
    btn.TextColor3 = FeatureStates[name] and TEXT_WHITE or TEXT_DIM
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 2, 1, 0)
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.BackgroundColor3 = ACCENT
    indicator.BackgroundTransparency = FeatureStates[name] and 0 or 1
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    btn.MouseButton1Click:Connect(function()
        FeatureStates[name] = not FeatureStates[name]
        local state = FeatureStates[name]
        tw(btn, {
            BackgroundTransparency = state and 0.55 or 1,
            BackgroundColor3 = state and ACCENT or BG,
            TextColor3 = state and TEXT_WHITE or TEXT_DIM,
        }, 0.2)
        tw(indicator, {BackgroundTransparency = state and 0 or 1}, 0.2)
        updateStatusPanel()
        if FeatureCallbacks[name] then
            pcall(FeatureCallbacks[name], state)
        end
    end)

    return btn
end

local function createSliderItem(parent, name, min, max, default, suffix, callback)
    SliderValues[name] = default or min
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, SLIDER_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 13)
    topRow.BackgroundTransparency = 1
    topRow.BorderSizePixel = 0
    topRow.Parent = wrapper

    local nameLbl = mkLabel(topRow, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 5, 0, 0)

    local valLbl = mkLabel(topRow, tostring(default or min) .. (suffix or ""), 8, ACCENT, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.4, -5, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 5)
    track.Position = UDim2.new(0, 5, 0, 16)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BackgroundTransparency = 0.2
    track.BorderSizePixel = 0
    track.Parent = wrapper
    mkCorner(track, 2)

    local pct = (SliderValues[name] - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = track
    mkCorner(fill, 2)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 7, 0, 7)
    knob.Position = UDim2.new(pct, -3, 0.5, -3)
    knob.BackgroundColor3 = TEXT_WHITE
    knob.BorderSizePixel = 0
    knob.Parent = track
    mkCorner(knob, 4)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 8)
    hitbox.Position = UDim2.new(0, 0, 0, -4)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.BorderSizePixel = 0
    hitbox.Parent = track

    local dragging = false
    local function updateSlider(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.round((min + (max - min) * rel) * 10) / 10
        SliderValues[name] = val
        tw(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.05)
        tw(knob, {Position = UDim2.new(rel, -3, 0.5, -3)}, 0.05)
        valLbl.Text = tostring(val) .. (suffix or "")
        if callback then pcall(callback, val) end
    end

    hitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(inp)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(inp)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return wrapper
end

local function createDropdownItem(parent, name, options, default, callback)
    DropdownValues[name] = default or options[1]
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local nameLbl = mkLabel(wrapper, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(0.44, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 5, 0, 0)

    local ddBtn = Instance.new("TextButton")
    ddBtn.Size = UDim2.new(0.56, -3, 0, 14)
    ddBtn.Position = UDim2.new(0.44, 0, 0.5, -7)
    ddBtn.BackgroundColor3 = BG2
    ddBtn.BackgroundTransparency = 0.2
    ddBtn.Text = tostring(DropdownValues[name]) .. " v"
    ddBtn.Font = Enum.Font.Gotham
    ddBtn.TextSize = 8
    ddBtn.TextColor3 = TEXT_WHITE
    ddBtn.BorderSizePixel = 0
    ddBtn.AutoButtonColor = false
    ddBtn.Parent = wrapper
    mkCorner(ddBtn, 2)
    mkStroke(ddBtn, BORDER, 1)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0.56, -3, 0, 0)
    listFrame.Position = UDim2.new(0.44, 0, 1, 0)
    listFrame.BackgroundColor3 = BG2
    listFrame.BackgroundTransparency = 0.1
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 10
    listFrame.Parent = wrapper
    mkCorner(listFrame, 2)
    mkStroke(listFrame, BORDER, 1)
    mkList(listFrame)

    local function buildDropList()
        for _, c in pairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 14)
            ob.BackgroundTransparency = opt == DropdownValues[name] and 0.5 or 1
            ob.BackgroundColor3 = opt == DropdownValues[name] and ACCENT or BG
            ob.Text = tostring(opt)
            ob.Font = Enum.Font.Gotham
            ob.TextSize = 8
            ob.TextColor3 = TEXT_WHITE
            ob.BorderSizePixel = 0
            ob.AutoButtonColor = false
            ob.Parent = listFrame
            ob.MouseButton1Click:Connect(function()
                DropdownValues[name] = opt
                ddBtn.Text = tostring(opt) .. " v"
                listFrame.Visible = false
                buildDropList()
                if callback then pcall(callback, opt) end
            end)
        end
        listFrame.Size = UDim2.new(0.56, -3, 0, #options * 14)
    end
    buildDropList()

    local open = false
    ddBtn.MouseButton1Click:Connect(function()
        open = not open
        listFrame.Visible = open
    end)

    return wrapper
end

local function createKeybindItem(parent, name, default, callback)
    KeybindValues[name] = default or Enum.KeyCode.Unknown
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local nameLbl = mkLabel(wrapper, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(0.56, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 5, 0, 0)

    local kBtn = Instance.new("TextButton")
    kBtn.Size = UDim2.new(0.44, -5, 0, 14)
    kBtn.Position = UDim2.new(0.56, 0, 0.5, -7)
    kBtn.BackgroundColor3 = BG2
    kBtn.BackgroundTransparency = 0.2
    kBtn.Text = "[" .. KeybindValues[name].Name .. "]"
    kBtn.Font = Enum.Font.GothamBold
    kBtn.TextSize = 8
    kBtn.TextColor3 = ACCENT
    kBtn.BorderSizePixel = 0
    kBtn.AutoButtonColor = false
    kBtn.Parent = wrapper
    mkCorner(kBtn, 2)
    mkStroke(kBtn, BORDER, 1)

    local listening = false
    kBtn.MouseButton1Click:Connect(function()
        listening = true
        ListeningKeybind = name
        kBtn.Text = "[...]"
        kBtn.TextColor3 = YELLOW
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
            KeybindValues[name] = inp.KeyCode
            kBtn.Text = "[" .. inp.KeyCode.Name .. "]"
            kBtn.TextColor3 = ACCENT
            listening = false
            ListeningKeybind = nil
            if callback then pcall(callback, inp.KeyCode) end
        end
    end)

    return wrapper
end

local function createTextInputItem(parent, name, placeholder, default, callback)
    TextValues[name] = default or ""
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, INPUT_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local nameLbl = mkLabel(wrapper, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(1, -8, 0, 11)
    nameLbl.Position = UDim2.new(0, 5, 0, 1)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 13)
    box.Position = UDim2.new(0, 5, 0, 12)
    box.BackgroundColor3 = BG2
    box.BackgroundTransparency = 0.2
    box.Text = default or ""
    box.PlaceholderText = placeholder or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 8
    box.TextColor3 = TEXT_WHITE
    box.PlaceholderColor3 = TEXT_OFF
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = wrapper
    mkCorner(box, 2)
    mkStroke(box, BORDER, 1)

    box.FocusLost:Connect(function()
        TextValues[name] = box.Text
        if callback then pcall(callback, box.Text) end
    end)

    return wrapper
end

local function createColorItem(parent, name, default, callback)
    ColorValues[name] = default or Color3.fromRGB(255, 255, 255)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local nameLbl = mkLabel(wrapper, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 5, 0, 0)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 28, 0, 12)
    preview.Position = UDim2.new(1, -33, 0.5, -6)
    preview.BackgroundColor3 = ColorValues[name]
    preview.BorderSizePixel = 0
    preview.Parent = wrapper
    mkCorner(preview, 2)
    mkStroke(preview, BORDER, 1)

    return wrapper, function(c)
        ColorValues[name] = c
        preview.BackgroundColor3 = c
        if callback then pcall(callback, c) end
    end
end

local function createLabelItem(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 8
    lbl.TextColor3 = color or TEXT_OFF
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.BorderSizePixel = 0
    lbl.Parent = parent
    return lbl
end

local function createValueDisplayItem(parent, name, value, color)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Parent = parent

    local nameLbl = mkLabel(wrapper, name, 8, TEXT_DIM, Enum.Font.Gotham)
    nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 5, 0, 0)

    local valLbl = mkLabel(wrapper, tostring(value), 8, color or ACCENT, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.4, -5, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)

    return wrapper, valLbl
end

local function createCategoryToggle(parent, name, callback)
    CategoryStates[name] = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = BG
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 9
    btn.TextColor3 = TEXT_DIM
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    local arrow = mkLabel(btn, ">", 8, TEXT_OFF, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    arrow.Size = UDim2.new(0, 14, 1, 0)
    arrow.Position = UDim2.new(1, -16, 0, 0)

    btn.MouseButton1Click:Connect(function()
        CategoryStates[name] = not CategoryStates[name]
        local state = CategoryStates[name]
        tw(btn, {
            BackgroundTransparency = state and 0.6 or 1,
            BackgroundColor3 = state and ACCENT or BG,
            TextColor3 = state and TEXT_WHITE or TEXT_DIM,
        }, 0.22)
        arrow.TextColor3 = state and ACCENT or TEXT_OFF
        arrow.Text = state and "v" or ">"
        if callback then pcall(callback, state) end
    end)

    return btn
end

local function createSubWindow(name, accentColor, buildFunc)
    local sub = createBaseFrame(name .. "_Sub")
    sub.Parent = ScreenGui

    local subTitle = createTitleBar(sub, name, accentColor)
    local subScroll = createScrollContent(sub)
    setCollapseLogic(subTitle, subScroll, sub)
    SubUIFrames[name] = sub

    if buildFunc then buildFunc(subScroll) end
end

local function toggleSubUI(name)
    local target = SubUIFrames[name]
    if not target then return end
    local idx = table.find(ActiveSubUIs, name)
    if idx then
        table.remove(ActiveSubUIs, idx)
        target.Visible = false
    else
        table.insert(ActiveSubUIs, name)
        if MainFrame and MainFrame.Visible then target.Visible = true end
    end
end

local MainFrame = createBaseFrame("MainFrame")
MainFrame.Position = UDim2.new(0.5, -(UI_WIDTH / 2), 0.18, 0)
MainFrame.Parent = ScreenGui

local MainTitle = createTitleBar(MainFrame, "AlienV4", ACCENT)
local MainScroll = createScrollContent(MainFrame)
setCollapseLogic(MainTitle, MainScroll, MainFrame)

RunService.RenderStepped:Connect(function()
    if MainFrame.Visible then
        local baseX = MainFrame.AbsolutePosition.X + UI_WIDTH + 4
        local baseY = MainFrame.AbsolutePosition.Y
        for i, name in ipairs(ActiveSubUIs) do
            local sub = SubUIFrames[name]
            if sub then
                sub.Visible = true
                sub.Position = UDim2.new(0, baseX + (i - 1) * (UI_WIDTH + 4), 0, baseY)
            end
        end
    else
        for _, name in ipairs(ActiveSubUIs) do
            local sub = SubUIFrames[name]
            if sub then sub.Visible = false end
        end
    end
end)

createSubWindow("战斗", ACCENT, function(scroll)
    createCategoryHeader(scroll, "自瞄")
    createFeatureToggle(scroll, "自瞄锁定", false, function(state)
        pushNotif("自瞄锁定", state and "已启用" or "已禁用", state and "info" or "warn", 2)
    end)
    createFeatureToggle(scroll, "锁定头部", false)
    createFeatureToggle(scroll, "穿墙自瞄", false)
    createFeatureToggle(scroll, "预判领先", false)
    createSliderItem(scroll, "瞄准范围", 0, 500, 200, "px")
    createSliderItem(scroll, "瞄准平滑", 0, 100, 50, "%")
    createDropdownItem(scroll, "锁定优先", {"最近", "最低血量", "随机", "视角中心"}, "最近")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "射击")
    createFeatureToggle(scroll, "无后坐力", false)
    createFeatureToggle(scroll, "快速填装", false)
    createFeatureToggle(scroll, "自动射击", false)
    createFeatureToggle(scroll, "穿透射击", false)
    createSliderItem(scroll, "射击延迟", 0, 500, 0, "ms")
    createSliderItem(scroll, "连射次数", 1, 10, 1, "x")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "近战")
    createFeatureToggle(scroll, "自动近战", false)
    createFeatureToggle(scroll, "攻击范围+", false)
    createSliderItem(scroll, "攻击距离", 4, 20, 6, "m")
    createSliderItem(scroll, "攻速倍率", 1, 5, 1, "x")
    createKeybindItem(scroll, "自瞄按键", Enum.KeyCode.Q)
    createKeybindItem(scroll, "自动攻击键", Enum.KeyCode.E)
end)

createSubWindow("移动", BLUE, function(scroll)
    createCategoryHeader(scroll, "速度")
    createFeatureToggle(scroll, "行走加速", false, function(state)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = state and SliderValues["行走速度"] or 16
            end
        end)
    end)
    createSliderItem(scroll, "行走速度", 16, 200, 50, "", function(v)
        pcall(function()
            if FeatureStates["行走加速"] then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = v
                end
            end
        end)
    end)
    createFeatureToggle(scroll, "无限跳跃", false)
    createSliderItem(scroll, "跳跃高度", 50, 300, 50, "")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "飞行")
    createFeatureToggle(scroll, "飞行模式", false, function(state)
        pushNotif("飞行模式", state and "已启用飞行" or "已禁用飞行", state and "info" or "warn", 2)
    end)
    createSliderItem(scroll, "飞行速度", 10, 300, 60, "")
    createSliderItem(scroll, "飞行加速度", 1, 20, 5, "")
    createFeatureToggle(scroll, "悬浮模式", false)
    createFeatureToggle(scroll, "无重力", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "穿越")
    createFeatureToggle(scroll, "穿墙行走", false)
    createFeatureToggle(scroll, "无碰撞体", false)
    createFeatureToggle(scroll, "地板穿透", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "传送")
    createFeatureToggle(scroll, "传送至鼠标", false)
    createFeatureToggle(scroll, "传送至玩家", false)
    createDropdownItem(scroll, "传送目标", {"最近玩家", "随机玩家", "指定坐标"}, "最近玩家")
    createKeybindItem(scroll, "飞行按键", Enum.KeyCode.F)
    createKeybindItem(scroll, "传送按键", Enum.KeyCode.G)
end)

createSubWindow("视觉", PURPLE, function(scroll)
    createCategoryHeader(scroll, "ESP透视")
    createFeatureToggle(scroll, "方框透视", false)
    createFeatureToggle(scroll, "线条指向", false)
    createFeatureToggle(scroll, "显示名称", false)
    createFeatureToggle(scroll, "血条透视", false)
    createFeatureToggle(scroll, "距离显示", false)
    createFeatureToggle(scroll, "武器显示", false)
    createFeatureToggle(scroll, "队伍透视", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "样式")
    createDropdownItem(scroll, "方框样式", {"实线框", "角框", "3D框"}, "角框")
    createDropdownItem(scroll, "血条位置", {"左侧", "右侧", "顶部", "底部"}, "左侧")
    createSliderItem(scroll, "ESP透明度", 0, 100, 80, "%")
    createSliderItem(scroll, "描边厚度", 1, 4, 1, "px")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "准星")
    createFeatureToggle(scroll, "自定义准星", false)
    createDropdownItem(scroll, "准星样式", {"十字", "点状", "圆形", "方形"}, "十字")
    createSliderItem(scroll, "准星大小", 4, 40, 12, "px")
    createSliderItem(scroll, "准星透明度", 0, 100, 0, "%")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "环境")
    createFeatureToggle(scroll, "全亮模式", false, function(state)
        pcall(function()
            game:GetService("Lighting").Brightness = state and 10 or 1
            game:GetService("Lighting").GlobalShadows = not state
        end)
    end)
    createFeatureToggle(scroll, "移除雾效", false)
    createFeatureToggle(scroll, "第三人称", false)
    createSliderItem(scroll, "视野范围", 70, 120, 70, "°", function(v)
        pcall(function() Camera.FieldOfView = v end)
    end)
end)

createSubWindow("玩家", YELLOW, function(scroll)
    createCategoryHeader(scroll, "角色")
    createFeatureToggle(scroll, "无敌模式", false)
    createFeatureToggle(scroll, "无限体力", false)
    createFeatureToggle(scroll, "快速回血", false)
    createSliderItem(scroll, "生命值", 1, 1000, 100, "hp")
    createSliderItem(scroll, "护甲值", 0, 500, 0, "ar")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "物理")
    createFeatureToggle(scroll, "低重力", false)
    createFeatureToggle(scroll, "超级弹跳", false)
    createFeatureToggle(scroll, "超速冲刺", false)
    createSliderItem(scroll, "重力系数", 0, 200, 100, "%")
    createSliderItem(scroll, "摩擦力", 0, 100, 50, "%")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "属性")
    createFeatureToggle(scroll, "攻击力+", false)
    createFeatureToggle(scroll, "防御力+", false)
    createSliderItem(scroll, "伤害倍率", 1, 100, 1, "x")
    createSliderItem(scroll, "防御倍率", 1, 10, 1, "x")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "工具")
    createTextInputItem(scroll, "名称修改", "输入新名称", LocalPlayer.DisplayName)
    createFeatureToggle(scroll, "隐藏角色", false)
    createFeatureToggle(scroll, "假人模式", false)
    createDropdownItem(scroll, "角色状态", {"正常", "透明", "发光", "隐形"}, "正常")
    createKeybindItem(scroll, "无敌按键", Enum.KeyCode.H)
end)

createSubWindow("利用", RED, function(scroll)
    createCategoryHeader(scroll, "服务端")
    createFeatureToggle(scroll, "服务端崩溃", false)
    createFeatureToggle(scroll, "远程监听", false)
    createFeatureToggle(scroll, "事件记录", false)
    createFeatureToggle(scroll, "脚本执行器", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "绕过")
    createFeatureToggle(scroll, "反检测", false, function(state)
        pushNotif("反检测", state and "保护已启用" or "保护已关闭", state and "info" or "warn", 2)
    end)
    createFeatureToggle(scroll, "匿名模式", false)
    createFeatureToggle(scroll, "速度绕过", false)
    createFeatureToggle(scroll, "飞行绕过", false)
    createDropdownItem(scroll, "绕过级别", {"低", "中", "高", "极限"}, "中")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "拍摄")
    createFeatureToggle(scroll, "相机锁定", false)
    createFeatureToggle(scroll, "相机冻结", false)
    createSliderItem(scroll, "相机速度", 1, 100, 10, "")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "远程")
    createFeatureToggle(scroll, "Fire远程", false)
    createFeatureToggle(scroll, "拦截远程", false)
    createTextInputItem(scroll, "远程名称", "RemoteEvent名称", "")
    createKeybindItem(scroll, "执行按键", Enum.KeyCode.Delete)
end)

createSubWindow("客户端", ACCENT, function(scroll)
    createCategoryHeader(scroll, "界面")
    createFeatureToggle(scroll, "显示FPS", false)
    createFeatureToggle(scroll, "显示Ping", false)
    createFeatureToggle(scroll, "显示坐标", false)
    createFeatureToggle(scroll, "显示速度", false)
    createFeatureToggle(scroll, "通知开关", true)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "性能")
    createFeatureToggle(scroll, "低画质模式", false, function(state)
        pcall(function()
            settings().Rendering.QualityLevel = state and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
    end)
    createDropdownItem(scroll, "画质等级", {"自动", "1", "3", "5", "7", "10"}, "自动")
    createSliderItem(scroll, "帧率上限", 30, 240, 60, "fps")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "主题")
    createDropdownItem(scroll, "强调色", {"绿色", "蓝色", "紫色", "红色", "橙色"}, "绿色", function(v)
        local colorMap = {
            ["绿色"] = Color3.fromRGB(0,255,120),
            ["蓝色"] = Color3.fromRGB(80,140,255),
            ["紫色"] = Color3.fromRGB(160,80,255),
            ["红色"] = Color3.fromRGB(255,60,60),
            ["橙色"] = Color3.fromRGB(255,140,30),
        }
        ACCENT = colorMap[v] or ACCENT
    end)
    createSliderItem(scroll, "界面透明度", 0, 90, 45, "%")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "快捷键")
    createKeybindItem(scroll, "显示/隐藏UI", Enum.KeyCode.RightShift, function(key) end)
    createKeybindItem(scroll, "紧急关闭", Enum.KeyCode.End, function()
        pushNotif("紧急关闭", "所有功能已停用", "error", 3)
        for k in pairs(FeatureStates) do FeatureStates[k] = false end
        updateStatusPanel()
    end)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "关于")
    createLabelItem(scroll, "AlienV4 Vape风格", ACCENT)
    createLabelItem(scroll, "版本 1.0.0", TEXT_OFF)
end)

local categoryOrder = {"战斗", "移动", "视觉", "玩家", "利用", "客户端"}
for _, catName in ipairs(categoryOrder) do
    createCategoryToggle(MainScroll, catName, function(state)
        toggleSubUI(catName)
    end)
end

local FPSDisplay, PingDisplay, CoordsDisplay, SpeedDisplay
local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoHUD"
infoFrame.Size = UDim2.new(0, 90, 0, 0)
infoFrame.Position = UDim2.new(0, 4, 1, -4)
infoFrame.AnchorPoint = Vector2.new(0, 1)
infoFrame.BackgroundTransparency = 1
infoFrame.BorderSizePixel = 0
infoFrame.Parent = ScreenGui
mkList(infoFrame, Enum.FillDirection.Vertical, 1)

local function mkHUDLabel(text)
    local lf = Instance.new("Frame")
    lf.Size = UDim2.new(1, 0, 0, 13)
    lf.BackgroundColor3 = BG
    lf.BackgroundTransparency = 0.35
    lf.BorderSizePixel = 0
    lf.Parent = infoFrame
    local lbl = mkLabel(lf, text, 8, TEXT_WHITE, Enum.Font.GothamBold)
    lbl.Size = UDim2.new(1, -4, 1, 0)
    lbl.Position = UDim2.new(0, 3, 0, 0)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 2, 1, 0)
    bar.BackgroundColor3 = ACCENT
    bar.BorderSizePixel = 0
    bar.Parent = lf
    return lbl, lf
end

local FPSLabel, FPSFrame = mkHUDLabel("FPS: --")
local PingLabel, PingFrame = mkHUDLabel("Ping: --")
local CoordsLabel, CoordsFrame = mkHUDLabel("XYZ: --")
local SpeedLabel, SpeedFrame = mkHUDLabel("SPD: --")
FPSFrame.Visible = false
PingFrame.Visible = false
CoordsFrame.Visible = false
SpeedFrame.Visible = false

local frameCount = 0
local lastFPSTime = tick()
local lastFPS = 60

RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFPSTime >= 0.5 then
        lastFPS = math.round(frameCount / (now - lastFPSTime))
        frameCount = 0
        lastFPSTime = now
    end

    FPSFrame.Visible = FeatureStates["显示FPS"] or false
    PingFrame.Visible = FeatureStates["显示Ping"] or false
    CoordsFrame.Visible = FeatureStates["显示坐标"] or false
    SpeedFrame.Visible = FeatureStates["显示速度"] or false

    if FeatureStates["显示FPS"] then
        local fpsColor = lastFPS >= 50 and ACCENT or (lastFPS >= 30 and YELLOW or RED)
        FPSLabel.Text = "FPS: " .. lastFPS
        FPSLabel.TextColor3 = fpsColor
    end

    if FeatureStates["显示Ping"] then
        pcall(function()
            local ping = LocalPlayer:GetNetworkPing() * 1000
            local pingRound = math.round(ping)
            local pingColor = pingRound < 80 and ACCENT or (pingRound < 150 and YELLOW or RED)
            PingLabel.Text = "Ping: " .. pingRound .. "ms"
            PingLabel.TextColor3 = pingColor
        end)
    end

    if FeatureStates["显示坐标"] then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                CoordsLabel.Text = math.round(pos.X) .. "," .. math.round(pos.Y) .. "," .. math.round(pos.Z)
            end
        end)
    end

    if FeatureStates["显示速度"] then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local vel = char.HumanoidRootPart.Velocity
                local spd = math.round(Vector3.new(vel.X, 0, vel.Z).Magnitude)
                SpeedLabel.Text = "SPD: " .. spd
            end
        end)
    end

    if FeatureStates["无限跳跃"] then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    if FeatureStates["低重力"] then
        pcall(function()
            workspace.Gravity = (SliderValues["重力系数"] or 100) * 0.196
        end)
    else
        pcall(function()
            if workspace.Gravity ~= 196.2 and not FeatureStates["低重力"] then
                workspace.Gravity = 196.2
            end
        end)
    end

    if FeatureStates["全亮模式"] then
        pcall(function()
            game:GetService("Lighting").Brightness = 10
            game:GetService("Lighting").GlobalShadows = false
        end)
    end
end)

local MainButton = Instance.new("TextButton")
MainButton.Name = "MainToggleBtn"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainButton.BackgroundTransparency = 0.1
MainButton.Size = UDim2.fromOffset(38, 38)
MainButton.Position = UDim2.new(0.04, 0, 0.42, 0)
MainButton.Text = "A"
MainButton.Font = Enum.Font.GothamBold
MainButton.TextColor3 = ACCENT
MainButton.TextSize = 18
MainButton.AutoButtonColor = false
MainButton.ZIndex = 10
mkCorner(MainButton, 4)

local MainButtonStroke = mkStroke(MainButton, BORDER, 1)

local accentDot = Instance.new("Frame")
accentDot.Size = UDim2.new(0, 5, 0, 5)
accentDot.Position = UDim2.new(1, -7, 0, 2)
accentDot.BackgroundColor3 = ACCENT
accentDot.BorderSizePixel = 0
accentDot.ZIndex = 11
accentDot.Parent = MainButton
mkCorner(accentDot, 3)

MainButton.MouseEnter:Connect(function()
    tw(MainButton, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.1)
end)
MainButton.MouseLeave:Connect(function()
    tw(MainButton, {BackgroundColor3 = Color3.fromRGB(8, 8, 8)}, 0.1)
end)

local lastSavedPos = MainFrame.Position

local function initDragging()
    local mainDrag, btnDrag, btnMoved = false, false, false
    local mStart, mPosStart, bStart, bPosStart

    MainTitle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            mainDrag = true
            mStart = inp.Position
            mPosStart = MainFrame.Position
        end
    end)

    MainButton.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            btnDrag = true
            btnMoved = false
            bStart = inp.Position
            bPosStart = MainButton.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            if mainDrag then
                local d = inp.Position - mStart
                MainFrame.Position = UDim2.new(mPosStart.X.Scale, mPosStart.X.Offset + d.X, mPosStart.Y.Scale, mPosStart.Y.Offset + d.Y)
                lastSavedPos = MainFrame.Position
            elseif btnDrag then
                local d = inp.Position - bStart
                if d.Magnitude > 6 then btnMoved = true end
                MainButton.Position = UDim2.new(bPosStart.X.Scale, bPosStart.X.Offset + d.X, bPosStart.Y.Scale, bPosStart.Y.Offset + d.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        local t = inp.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            mainDrag = false
            if btnDrag then
                btnDrag = false
                if not btnMoved then
                    local showing = not MainFrame.Visible
                    MainFrame.Visible = showing
                    if showing then
                        MainFrame.Position = lastSavedPos
                    end
                    tw(MainButton, {TextColor3 = showing and ACCENT or TEXT_DIM}, 0.15)
                    accentDot.BackgroundColor3 = showing and ACCENT or TEXT_OFF
                else
                    local screenW = ScreenGui.AbsoluteSize.X
                    local snapLeft = MainButton.AbsolutePosition.X < screenW / 2
                    local snapPos = snapLeft
                        and UDim2.new(0, 4, MainButton.Position.Y.Scale, MainButton.Position.Y.Offset)
                        or UDim2.new(1, -42, MainButton.Position.Y.Scale, MainButton.Position.Y.Offset)
                    tw(MainButton, {Position = snapPos}, 0.3, Enum.EasingStyle.Back)
                end
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if ListeningKeybind then return end
    if inp.KeyCode == KeybindValues["显示/隐藏UI"] then
        local showing = not MainFrame.Visible
        MainFrame.Visible = showing
        tw(MainButton, {TextColor3 = showing and ACCENT or TEXT_DIM}, 0.15)
        accentDot.BackgroundColor3 = showing and ACCENT or TEXT_OFF
    elseif inp.KeyCode == KeybindValues["紧急关闭"] then
        for k in pairs(FeatureStates) do FeatureStates[k] = false end
        updateStatusPanel()
        pushNotif("紧急关闭", "所有功能已停用", "error", 3)
    elseif inp.KeyCode == KeybindValues["飞行按键"] then
        FeatureStates["飞行模式"] = not FeatureStates["飞行模式"]
        updateStatusPanel()
    elseif inp.KeyCode == KeybindValues["自瞄按键"] then
        FeatureStates["自瞄锁定"] = not FeatureStates["自瞄锁定"]
        updateStatusPanel()
    end
end)

initDragging()
pushNotif("AlienV4", "已成功加载 Vape风格", "info", 4)

createSubWindow("武器", Color3.fromRGB(255, 120, 0), function(scroll)
    createCategoryHeader(scroll, "枪械改装")
    createFeatureToggle(scroll, "无限弹药", false)
    createFeatureToggle(scroll, "无需换弹", false)
    createFeatureToggle(scroll, "快速换弹", false)
    createFeatureToggle(scroll, "无散射", false)
    createFeatureToggle(scroll, "弹道追踪", false)
    createSliderItem(scroll, "子弹速度", 1, 100, 10, "x")
    createSliderItem(scroll, "子弹大小", 1, 20, 1, "x")
    createSliderItem(scroll, "弹匣容量", 1, 999, 30, "发")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "射速")
    createFeatureToggle(scroll, "全自动", false)
    createSliderItem(scroll, "射速", 1, 60, 10, "rps")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "伤害")
    createFeatureToggle(scroll, "一击必杀", false)
    createSliderItem(scroll, "伤害倍率", 1, 100, 1, "x")
    createSliderItem(scroll, "爆头倍率", 1, 50, 2, "x")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "物理")
    createFeatureToggle(scroll, "子弹穿透", false)
    createFeatureToggle(scroll, "子弹反弹", false)
    createSliderItem(scroll, "后坐力", 0, 100, 50, "%")
    createDropdownItem(scroll, "开火模式", {"单发", "点射", "全自动", "散弹"}, "全自动")
    createKeybindItem(scroll, "武器切换键", Enum.KeyCode.Tab)
end)

createSubWindow("世界", Color3.fromRGB(0, 200, 255), function(scroll)
    createCategoryHeader(scroll, "环境")
    createFeatureToggle(scroll, "时间冻结", false)
    createFeatureToggle(scroll, "天气控制", false)
    createFeatureToggle(scroll, "无雨", false)
    createDropdownItem(scroll, "时间段", {"白天", "黄昏", "夜晚", "凌晨"}, "白天", function(v)
        pcall(function()
            local timeMap = {["白天"]=14, ["黄昏"]=18, ["夜晚"]=0, ["凌晨"]=4}
            game:GetService("Lighting").ClockTime = timeMap[v] or 14
        end)
    end)
    createSliderItem(scroll, "时钟时间", 0, 24, 14, "h", function(v)
        pcall(function() game:GetService("Lighting").ClockTime = v end)
    end)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "物理")
    createFeatureToggle(scroll, "慢动作", false, function(state)
        pcall(function()
            workspace:GetPropertyChangedSignal("DistributedGameTime"):Wait()
        end)
    end)
    createSliderItem(scroll, "世界重力", 0, 400, 196, "", function(v)
        pcall(function() workspace.Gravity = v end)
    end)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "对象")
    createFeatureToggle(scroll, "移除树木", false)
    createFeatureToggle(scroll, "移除建筑", false)
    createFeatureToggle(scroll, "线框模式", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "网络")
    createFeatureToggle(scroll, "包延迟模拟", false)
    createSliderItem(scroll, "模拟延迟", 0, 1000, 0, "ms")
    createSliderItem(scroll, "数据包丢失", 0, 100, 0, "%")
end)

createSubWindow("杂项", Color3.fromRGB(180, 180, 180), function(scroll)
    createCategoryHeader(scroll, "聊天")
    createFeatureToggle(scroll, "消息记录", false)
    createFeatureToggle(scroll, "自动聊天", false)
    createTextInputItem(scroll, "自动消息", "输入自动消息内容", "你好！")
    createSliderItem(scroll, "消息间隔", 1, 60, 5, "s")
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "反制")
    createFeatureToggle(scroll, "阻止踢出", false)
    createFeatureToggle(scroll, "防止封禁", false)
    createFeatureToggle(scroll, "反举报", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "调试")
    createFeatureToggle(scroll, "显示碰撞箱", false)
    createFeatureToggle(scroll, "显示路径", false)
    createFeatureToggle(scroll, "输出远程", false)
    createFeatureToggle(scroll, "控制台日志", false)
    createSeparatorLine(scroll)
    createCategoryHeader(scroll, "工具")
    createFeatureToggle(scroll, "自动收集", false)
    createFeatureToggle(scroll, "自动完成任务", false)
    createFeatureToggle(scroll, "范围互动", false)
    createSliderItem(scroll, "互动范围", 1, 100, 10, "m")
    createKeybindItem(scroll, "杂项按键", Enum.KeyCode.M)
end)

local extraOrder = {"武器", "世界", "杂项"}
for _, catName in ipairs(extraOrder) do
    createCategoryToggle(MainScroll, catName, function(state)
        toggleSubUI(catName)
    end)
end

local function createFloatingESPRenderer()
    local connection
    local function startESP()
        connection = RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not FeatureStates["方框透视"] and not FeatureStates["线条指向"] and not FeatureStates["显示名称"] then continue end
                pcall(function()
                    local char = player.Character
                    if not char then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum then return end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if not onScreen then return end
                end)
            end
        end)
    end
    startESP()
    return function()
        if connection then connection:Disconnect() end
    end
end
createFloatingESPRenderer()

local keybindWatcher = UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if ListeningKeybind then return end
    for name, key in pairs(KeybindValues) do
        if inp.KeyCode == key and FeatureStates[name] ~= nil then
        end
    end
end)

local function autoSaveConfig()
    task.spawn(function()
        while true do
            task.wait(30)
            local cfg = {
                features = {},
                sliders = {},
                dropdowns = {},
                keybinds = {},
            }
            for k, v in pairs(FeatureStates) do cfg.features[k] = v end
            for k, v in pairs(SliderValues) do cfg.sliders[k] = v end
            for k, v in pairs(DropdownValues) do cfg.dropdowns[k] = v end
        end
    end)
end
autoSaveConfig()

local pingHistory = {}
local function trackPing()
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                local p = math.round(LocalPlayer:GetNetworkPing() * 1000)
                table.insert(pingHistory, p)
                if #pingHistory > 60 then table.remove(pingHistory, 1) end
            end)
        end
    end)
end
trackPing()

local function getAveragePing()
    if #pingHistory == 0 then return 0 end
    local sum = 0
    for _, v in ipairs(pingHistory) do sum = sum + v end
    return math.round(sum / #pingHistory)
end

local statWindow = createBaseFrame("StatWindow")
statWindow.Size = UDim2.fromOffset(90, 100)
statWindow.Position = UDim2.new(0, 4, 0, 4)
statWindow.Parent = ScreenGui
statWindow.Visible = false

local statTitle = createTitleBar(statWindow, "Stats", ACCENT)
local statScroll = createScrollContent(statWindow)
setCollapseLogic(statTitle, statScroll, statWindow)

local _, avgPingLbl = createValueDisplayItem(statScroll, "均Ping", "-- ms", YELLOW)
local _, fpsStatLbl = createValueDisplayItem(statScroll, "FPS", "--", ACCENT)
local _, activeCountLbl = createValueDisplayItem(statScroll, "功能数", "0", BLUE)
local _, playerCountLbl = createValueDisplayItem(statScroll, "玩家数", "0", TEXT_DIM)

RunService.Heartbeat:Connect(function()
    if not statWindow.Visible then return end
    pcall(function()
        avgPingLbl.Text = getAveragePing() .. " ms"
        fpsStatLbl.Text = tostring(lastFPS)
        local cnt = 0
        for _, v in pairs(FeatureStates) do if v then cnt = cnt + 1 end end
        activeCountLbl.Text = tostring(cnt)
        playerCountLbl.Text = tostring(#Players:GetPlayers())
    end)
end)

createCategoryToggle(MainScroll, "数据面板", function(state)
    statWindow.Visible = state
end)

local function addQuickActions()
    createSeparatorLine(MainScroll)
    createCategoryHeader(MainScroll, "快速操作")

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    resetBtn.BackgroundTransparency = 0.7
    resetBtn.BackgroundColor3 = RED
    resetBtn.Text = "重置所有"
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 9
    resetBtn.TextColor3 = TEXT_WHITE
    resetBtn.BorderSizePixel = 0
    resetBtn.AutoButtonColor = false
    resetBtn.Parent = MainScroll

    local panicBtn = Instance.new("TextButton")
    panicBtn.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    panicBtn.BackgroundTransparency = 0.6
    panicBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    panicBtn.Text = "紧急停止"
    panicBtn.Font = Enum.Font.GothamBold
    panicBtn.TextSize = 9
    panicBtn.TextColor3 = RED
    panicBtn.BorderSizePixel = 0
    panicBtn.AutoButtonColor = false
    panicBtn.Parent = MainScroll

    resetBtn.MouseButton1Click:Connect(function()
        for k in pairs(FeatureStates) do FeatureStates[k] = false end
        updateStatusPanel()
        pushNotif("重置", "所有开关已关闭", "warn", 2)
        tw(resetBtn, {BackgroundColor3 = ACCENT}, 0.1)
        task.delay(0.3, function() tw(resetBtn, {BackgroundColor3 = RED}, 0.2) end)
    end)

    panicBtn.MouseButton1Click:Connect(function()
        for k in pairs(FeatureStates) do FeatureStates[k] = false end
        updateStatusPanel()
        MainFrame.Visible = false
        pushNotif("紧急停止", "UI已隐藏，功能已停用", "error", 4)
    end)
end
addQuickActions()

Players.PlayerAdded:Connect(function(plr)
    pushNotif("玩家加入", plr.DisplayName .. " 加入了游戏", "info", 3)
end)
Players.PlayerRemoving:Connect(function(plr)
    pushNotif("玩家离开", plr.DisplayName .. " 离开了游戏", "warn", 3)
end)

updateStatusPanel()

local function createContextMenu()
    local ctx = Instance.new("Frame")
    ctx.Name = "ContextMenu"
    ctx.Size = UDim2.fromOffset(90, 0)
    ctx.AutomaticSize = Enum.AutomaticSize.Y
    ctx.BackgroundColor3 = BG
    ctx.BackgroundTransparency = 0.15
    ctx.BorderSizePixel = 0
    ctx.Visible = false
    ctx.ZIndex = 100
    ctx.Parent = ScreenGui
    mkCorner(ctx, 3)
    mkStroke(ctx, BORDER, 1)
    mkList(ctx)

    local ctxItems = {
        {"复制坐标", function()
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local p = char.HumanoidRootPart.Position
                    pushNotif("坐标复制", math.round(p.X)..","..math.round(p.Y)..","..math.round(p.Z), "info", 2)
                end
            end)
        end},
        {"传送到此", function()
            pushNotif("传送", "功能需在游戏中实现", "warn", 2)
        end},
        {"复位角色", function()
            pcall(function()
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
            end)
        end},
        {"刷新角色", function()
            pcall(function()
                LocalPlayer:LoadCharacter()
            end)
        end},
        {"关闭菜单", function()
            ctx.Visible = false
        end},
    }

    for _, item in ipairs(ctxItems) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 18)
        btn.BackgroundTransparency = 1
        btn.Text = item[1]
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 9
        btn.TextColor3 = TEXT_DIM
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = ctx
        btn.MouseEnter:Connect(function()
            tw(btn, {TextColor3 = TEXT_WHITE, BackgroundTransparency = 0.7}, 0.1)
            btn.BackgroundColor3 = ACCENT
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {TextColor3 = TEXT_DIM, BackgroundTransparency = 1}, 0.1)
        end)
        btn.MouseButton1Click:Connect(function()
            ctx.Visible = false
            if item[2] then pcall(item[2]) end
        end)
    end

    UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            ctx.Position = UDim2.new(0, inp.Position.X + 4, 0, inp.Position.Y + 4)
            ctx.Visible = not ctx.Visible
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if ctx.Visible then
                task.delay(0.1, function() ctx.Visible = false end)
            end
        end
    end)

    return ctx
end
local contextMenu = createContextMenu()

local function createWatermark()
    local wm = Instance.new("Frame")
    wm.Name = "Watermark"
    wm.Size = UDim2.new(0, 0, 0, 16)
    wm.AutomaticSize = Enum.AutomaticSize.X
    wm.Position = UDim2.new(0.5, 0, 0, 4)
    wm.AnchorPoint = Vector2.new(0.5, 0)
    wm.BackgroundColor3 = BG
    wm.BackgroundTransparency = 0.25
    wm.BorderSizePixel = 0
    wm.Parent = ScreenGui
    mkCorner(wm, 3)
    mkStroke(wm, ACCENT, 1)
    mkPad(wm, 0, 0, 6, 6)

    local wmLayout = Instance.new("UIListLayout")
    wmLayout.FillDirection = Enum.FillDirection.Horizontal
    wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    wmLayout.Padding = UDim.new(0, 6)
    wmLayout.Parent = wm

    local nameL = mkLabel(wm, "AlienV4", 9, ACCENT, Enum.Font.GothamBold)
    nameL.Size = UDim2.new(0, 0, 1, 0)
    nameL.AutomaticSize = Enum.AutomaticSize.X

    local sepL = mkLabel(wm, "|", 9, BORDER, Enum.Font.Gotham)
    sepL.Size = UDim2.new(0, 4, 1, 0)

    local userL = mkLabel(wm, LocalPlayer.DisplayName, 9, TEXT_DIM, Enum.Font.Gotham)
    userL.Size = UDim2.new(0, 0, 1, 0)
    userL.AutomaticSize = Enum.AutomaticSize.X

    local sep2L = mkLabel(wm, "|", 9, BORDER, Enum.Font.Gotham)
    sep2L.Size = UDim2.new(0, 4, 1, 0)

    local fpsWmL = mkLabel(wm, "60fps", 9, TEXT_OFF, Enum.Font.Gotham)
    fpsWmL.Size = UDim2.new(0, 0, 1, 0)
    fpsWmL.AutomaticSize = Enum.AutomaticSize.X

    RunService.Heartbeat:Connect(function()
        fpsWmL.Text = lastFPS .. "fps"
        local fpsOk = lastFPS >= 50
        fpsWmL.TextColor3 = fpsOk and ACCENT or RED
    end)

    return wm
end
createWatermark()

local function createPlayerList()
    local plPanel = createBaseFrame("PlayerListPanel")
    plPanel.Size = UDim2.fromOffset(100, 160)
    plPanel.Position = UDim2.new(1, -110, 0.5, -80)
    plPanel.Parent = ScreenGui
    plPanel.Visible = false

    local plTitle = createTitleBar(plPanel, "玩家列表", BLUE)
    local plScroll = createScrollContent(plPanel)
    setCollapseLogic(plTitle, plScroll, plPanel)

    local function refreshPlayerList()
        for _, c in pairs(plScroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            local pRow = Instance.new("Frame")
            pRow.Size = UDim2.new(1, 0, 0, 20)
            pRow.BackgroundTransparency = 1
            pRow.BorderSizePixel = 0
            pRow.Parent = plScroll

            local isLocal = plr == LocalPlayer
            local nameLbl = mkLabel(pRow, plr.DisplayName, 8, isLocal and ACCENT or TEXT_DIM, Enum.Font.Gotham)
            nameLbl.Size = UDim2.new(0.75, 0, 1, 0)
            nameLbl.Position = UDim2.new(0, 4, 0, 0)

            if not isLocal then
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0.25, -4, 0, 14)
                tpBtn.Position = UDim2.new(0.75, 0, 0.5, -7)
                tpBtn.BackgroundColor3 = BG2
                tpBtn.BackgroundTransparency = 0.2
                tpBtn.Text = "TP"
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.TextSize = 7
                tpBtn.TextColor3 = ACCENT
                tpBtn.BorderSizePixel = 0
                tpBtn.AutoButtonColor = false
                tpBtn.Parent = pRow
                mkCorner(tpBtn, 2)
                tpBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        local char = plr.Character
                        local myChar = LocalPlayer.Character
                        if char and myChar and char:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
                            myChar.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                            pushNotif("传送", "已传送至 " .. plr.DisplayName, "info", 2)
                        end
                    end)
                end)
            end
        end
    end

    refreshPlayerList()
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(function()
        task.delay(0.5, refreshPlayerList)
    end)

    createCategoryToggle(MainScroll, "玩家列表", function(state)
        plPanel.Visible = state
    end)

    return plPanel
end
createPlayerList()

task.delay(1, function()
    pushNotif("提示", "点击左侧按钮开启菜单", "info", 5)
end)
