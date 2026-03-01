local AlienV4 = {}
AlienV4.__index = AlienV4
AlienV4.Flags = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local THEME = {
	BG         = Color3.fromRGB(12, 12, 18),
	BG2        = Color3.fromRGB(18, 18, 26),
	BG3        = Color3.fromRGB(24, 24, 34),
	Border     = Color3.fromRGB(40, 40, 58),
	Accent     = Color3.fromRGB(70, 110, 200),
	Text       = Color3.fromRGB(210, 210, 220),
	TextDim    = Color3.fromRGB(130, 130, 150),
	TextOff    = Color3.fromRGB(70, 70, 90),
	ToggleOn   = Color3.fromRGB(55, 170, 90),
	ToggleOff  = Color3.fromRGB(50, 50, 68),
	SliderFill = Color3.fromRGB(70, 110, 200),
	SliderBg   = Color3.fromRGB(28, 28, 40),
	BtnBg      = Color3.fromRGB(28, 28, 40),
	BtnHover   = Color3.fromRGB(38, 38, 55),
	InputBg    = Color3.fromRGB(15, 15, 22),
	NotifBg    = Color3.fromRGB(18, 18, 26),
	CatSel     = Color3.fromRGB(28, 28, 42),
	ColHdr     = Color3.fromRGB(22, 22, 32),
	Scrollbar  = Color3.fromRGB(45, 45, 65),
}

local function tw(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function new(cls, props, parent)
	local o = Instance.new(cls)
	for k, v in pairs(props or {}) do
		o[k] = v
	end
	if parent then o.Parent = parent end
	return o
end

local function corner(p, r)
	new("UICorner", {CornerRadius = UDim.new(0, r or 4)}, p)
end

local function stroke(p, col, th)
	new("UIStroke", {Color = col or THEME.Border, Thickness = th or 1}, p)
end

local function pad(p, t, b, l, r)
	new("UIPadding", {
		PaddingTop    = UDim.new(0, t or 4),
		PaddingBottom = UDim.new(0, b or 4),
		PaddingLeft   = UDim.new(0, l or 6),
		PaddingRight  = UDim.new(0, r or 6),
	}, p)
end

local function vlist(p, spacing)
	new("UIListLayout", {
		FillDirection       = Enum.FillDirection.Vertical,
		Padding             = UDim.new(0, spacing or 0),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	}, p)
end

local function mklabel(parent, txt, size, col, font, xa, extraProps)
	local l = new("TextLabel", {
		Text                   = txt,
		TextSize               = size or 11,
		TextColor3             = col or THEME.Text,
		Font                   = font or Enum.Font.GothamSemibold,
		BackgroundTransparency = 1,
		TextXAlignment         = xa or Enum.TextXAlignment.Left,
		TextYAlignment         = Enum.TextYAlignment.Center,
	}, parent)
	if extraProps then
		for k, v in pairs(extraProps) do l[k] = v end
	end
	return l
end

local function makeDrag(frame, handle)
	local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			mousePos  = inp.Position
			framePos  = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local d = inp.Position - mousePos
			frame.Position = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + d.X,
				framePos.Y.Scale, framePos.Y.Offset + d.Y
			)
		end
	end)
end

function AlienV4:CreateWindow(cfg)
	cfg = cfg or {}
	local W     = cfg.Width  or 620
	local H     = cfg.Height or 420
	local title = cfg.Title  or "AlienV4"

	-- Apply custom theme overrides
	if cfg.Theme then
		for k, v in pairs(cfg.Theme) do THEME[k] = v end
	end

	local gui = new("ScreenGui", {
		Name           = "AlienV4_" .. title,
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then
		gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Main window frame
	local main = new("Frame", {
		Name             = "Main",
		Size             = UDim2.new(0, W, 0, H),
		Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3 = THEME.BG,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	}, gui)
	corner(main, 5)
	stroke(main, THEME.Border, 1)

	-- Title bar
	local titleBar = new("Frame", {
		Size             = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = THEME.BG2,
		BorderSizePixel  = 0,
	}, main)
	corner(titleBar, 5)
	-- Flatten bottom corners of title bar
	new("Frame", {
		Size             = UDim2.new(1, 0, 0, 5),
		Position         = UDim2.new(0, 0, 1, -5),
		BackgroundColor3 = THEME.BG2,
		BorderSizePixel  = 0,
	}, titleBar)
	-- Bottom border line
	new("Frame", {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = THEME.Border,
		BorderSizePixel  = 0,
	}, titleBar)

	mklabel(titleBar, title, 12, THEME.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Left, {
		Size     = UDim2.new(1, -65, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
	})

	-- Close button
	local closeBtn = new("TextButton", {
		Text             = "×",
		Font             = Enum.Font.GothamBold,
		TextSize         = 18,
		TextColor3       = Color3.fromRGB(170, 60, 60),
		BackgroundTransparency = 1,
		Size             = UDim2.new(0, 28, 1, 0),
		Position         = UDim2.new(1, -28, 0, 0),
	}, titleBar)
	closeBtn.MouseEnter:Connect(function() tw(closeBtn, {TextColor3 = Color3.fromRGB(220,80,80)}, 0.08) end)
	closeBtn.MouseLeave:Connect(function() tw(closeBtn, {TextColor3 = Color3.fromRGB(170,60,60)}, 0.08) end)
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	-- Minimize button
	local minBtn = new("TextButton", {
		Text             = "−",
		Font             = Enum.Font.GothamBold,
		TextSize         = 18,
		TextColor3       = THEME.TextDim,
		BackgroundTransparency = 1,
		Size             = UDim2.new(0, 28, 1, 0),
		Position         = UDim2.new(1, -56, 0, 0),
	}, titleBar)
	minBtn.MouseEnter:Connect(function() tw(minBtn, {TextColor3 = THEME.Text}, 0.08) end)
	minBtn.MouseLeave:Connect(function() tw(minBtn, {TextColor3 = THEME.TextDim}, 0.08) end)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tw(main, {Size = minimized and UDim2.new(0, W, 0, 28) or UDim2.new(0, W, 0, H)}, 0.2)
	end)

	makeDrag(main, titleBar)

	-- Body
	local body = new("Frame", {
		Size             = UDim2.new(1, 0, 1, -28),
		Position         = UDim2.new(0, 0, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
	}, main)

	-- Left panel (category list)
	local CAT_W = 100
	local catPanel = new("Frame", {
		Size             = UDim2.new(0, CAT_W, 1, 0),
		BackgroundColor3 = THEME.BG2,
		BorderSizePixel  = 0,
	}, body)
	-- Right divider
	new("Frame", {
		Size             = UDim2.new(0, 1, 1, 0),
		Position         = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = THEME.Border,
		BorderSizePixel  = 0,
	}, catPanel)

	local catScroll = new("ScrollingFrame", {
		Size                 = UDim2.new(1, -1, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness   = 0,
		BorderSizePixel      = 0,
		CanvasSize           = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize  = Enum.AutomaticSize.Y,
	}, catPanel)
	vlist(catScroll, 0)

	-- Right content area
	local contentArea = new("Frame", {
		Size             = UDim2.new(1, -CAT_W, 1, 0),
		Position         = UDim2.new(0, CAT_W, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
	}, body)

	-- Notification container (floats right of window)
	local notifHolder = new("Frame", {
		Size             = UDim2.new(0, 220, 1, 0),
		Position         = UDim2.new(1, 8, 0, 0),
		BackgroundTransparency = 1,
	}, main)
	vlist(notifHolder, 5)

	local pages      = {}
	local currentTab = nil

	-- Window object
	local window = {}

	function window:Notify(opts)
		opts = opts or {}
		local nTitle = opts.Title       or "Notice"
		local nDesc  = opts.Description or ""
		local nTime  = opts.Duration    or 3
		local nType  = opts.Type        or "Info"

		local accentCol = THEME.Accent
		if nType == "Success" then accentCol = Color3.fromRGB(55,170,90)
		elseif nType == "Error" then accentCol = Color3.fromRGB(200,60,60)
		elseif nType == "Warning" then accentCol = Color3.fromRGB(200,155,40) end

		local nf = new("Frame", {
			Size             = UDim2.new(1, 0, 0, 56),
			BackgroundColor3 = THEME.NotifBg,
			BorderSizePixel  = 0,
		}, notifHolder)
		corner(nf, 4)
		stroke(nf, accentCol, 1)

		new("Frame", {
			Size             = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = accentCol,
			BorderSizePixel  = 0,
		}, nf)

		mklabel(nf, nTitle, 11, THEME.Text, Enum.Font.GothamBold, nil, {
			Size = UDim2.new(1, -12, 0, 18), Position = UDim2.new(0, 9, 0, 5),
		})
		local descLbl = mklabel(nf, nDesc, 10, THEME.TextDim, Enum.Font.Gotham, nil, {
			Size = UDim2.new(1, -12, 0, 28), Position = UDim2.new(0, 9, 0, 23),
		})
		descLbl.TextWrapped = true

		task.delay(nTime, function()
			tw(nf, {BackgroundTransparency = 1}, 0.25)
			task.wait(0.3)
			nf:Destroy()
		end)
	end

	function window:CreateTab(name)
		-- Category button (left panel)
		local catBtn = new("TextButton", {
			Text             = name,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 11,
			TextColor3       = THEME.TextDim,
			BackgroundColor3 = THEME.BG2,
			BorderSizePixel  = 0,
			Size             = UDim2.new(1, 0, 0, 22),
			TextXAlignment   = Enum.TextXAlignment.Left,
		}, catScroll)
		pad(catBtn, 0, 0, 10, 4)

		-- Active left indicator
		local bar = new("Frame", {
			Size             = UDim2.new(0, 2, 0.6, 0),
			Position         = UDim2.new(0, 0, 0.2, 0),
			BackgroundColor3 = THEME.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
		}, catBtn)

		-- Page (right content)
		local page = new("ScrollingFrame", {
			Size                 = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness   = 2,
			ScrollBarImageColor3 = THEME.Scrollbar,
			BorderSizePixel      = 0,
			CanvasSize           = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize  = Enum.AutomaticSize.Y,
			Visible              = false,
		}, contentArea)
		vlist(page, 2)
		pad(page, 5, 5, 5, 5)

		pages[name] = {page = page, btn = catBtn, bar = bar}

		local function selectTab()
			if currentTab and currentTab ~= name and pages[currentTab] then
				local old = pages[currentTab]
				old.page.Visible = false
				tw(old.btn, {TextColor3 = THEME.TextDim, BackgroundColor3 = THEME.BG2}, 0.1)
				tw(old.bar, {BackgroundTransparency = 1}, 0.1)
			end
			currentTab = name
			page.Visible = true
			tw(catBtn, {TextColor3 = THEME.Text, BackgroundColor3 = THEME.CatSel}, 0.1)
			tw(bar, {BackgroundTransparency = 0}, 0.1)
		end

		if not currentTab then selectTab() end

		catBtn.MouseButton1Click:Connect(selectTab)
		catBtn.MouseEnter:Connect(function()
			if currentTab ~= name then tw(catBtn, {BackgroundColor3 = THEME.BG3}, 0.08) end
		end)
		catBtn.MouseLeave:Connect(function()
			if currentTab ~= name then tw(catBtn, {BackgroundColor3 = THEME.BG2}, 0.08) end
		end)

		local tab = {}

		function tab:CreateSection(sname)
			local sec = new("Frame", {
				Size             = UDim2.new(1, 0, 0, 0),
				AutomaticSize    = Enum.AutomaticSize.Y,
				BackgroundColor3 = THEME.BG2,
				BorderSizePixel  = 0,
			}, page)
			corner(sec, 4)
			stroke(sec, THEME.Border, 1)

			-- Section header
			local hdr = new("Frame", {
				Size             = UDim2.new(1, 0, 0, 20),
				BackgroundColor3 = THEME.ColHdr,
				BorderSizePixel  = 0,
			}, sec)
			corner(hdr, 4)
			new("Frame", {
				Size             = UDim2.new(1, 0, 0, 4),
				Position         = UDim2.new(0, 0, 1, -4),
				BackgroundColor3 = THEME.ColHdr,
				BorderSizePixel  = 0,
			}, hdr)
			-- Accent bar on header
			new("Frame", {
				Size             = UDim2.new(0, 2, 0.55, 0),
				Position         = UDim2.new(0, 6, 0.225, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel  = 0,
			}, hdr)
			mklabel(hdr, sname, 10, THEME.TextDim, Enum.Font.GothamBold, nil, {
				Size     = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
			})

			-- Items container
			local items = new("Frame", {
				Size             = UDim2.new(1, 0, 0, 0),
				Position         = UDim2.new(0, 0, 0, 20),
				AutomaticSize    = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel  = 0,
			}, sec)
			vlist(items, 0)
			pad(items, 2, 4, 7, 7)

			local section = {}

			local function row(h)
				return new("Frame", {
					Size             = UDim2.new(1, 0, 0, h or 22),
					BackgroundTransparency = 1,
					BorderSizePixel  = 0,
				}, items)
			end

			-- TOGGLE
			function section:AddToggle(opts)
				opts = opts or {}
				local lbl     = opts.Name or "Toggle"
				local default = opts.Default == true
				local cb      = opts.Callback or function() end
				local flag    = opts.Flag

				local state = default
				local r = row(22)

				mklabel(r, lbl, 11, THEME.Text, Enum.Font.GothamSemibold, nil, {
					Size = UDim2.new(1, -44, 1, 0),
				})

				local track = new("Frame", {
					Size             = UDim2.new(0, 32, 0, 14),
					Position         = UDim2.new(1, -34, 0.5, -7),
					BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff,
					BorderSizePixel  = 0,
				}, r)
				corner(track, 7)

				local knob = new("Frame", {
					Size             = UDim2.new(0, 10, 0, 10),
					Position         = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel  = 0,
				}, track)
				corner(knob, 5)

				local hitbox = new("TextButton", {
					Text             = "",
					BackgroundTransparency = 1,
					Size             = UDim2.new(1, 0, 1, 0),
				}, r)

				local obj = {}
				function obj:Set(v)
					state = v
					tw(track, {BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff}, 0.12)
					tw(knob, {Position = state and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)}, 0.12)
					cb(state)
					if flag then AlienV4.Flags[flag] = state end
				end
				function obj:Get() return state end

				hitbox.MouseButton1Click:Connect(function() obj:Set(not state) end)
				if flag then AlienV4.Flags[flag] = state end
				return obj
			end

			-- SLIDER
			function section:AddSlider(opts)
				opts = opts or {}
				local lbl    = opts.Name or "Slider"
				local min    = opts.Min or 0
				local max    = opts.Max or 100
				local val    = math.clamp(opts.Default or min, min, max)
				local dec    = opts.Decimals or 0
				local suffix = opts.Suffix or ""
				local cb     = opts.Callback or function() end
				local flag   = opts.Flag

				local dragging = false

				local wrapper = new("Frame", {
					Size             = UDim2.new(1, 0, 0, 34),
					BackgroundTransparency = 1,
				}, items)

				local topRow = new("Frame", {
					Size             = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
				}, wrapper)
				mklabel(topRow, lbl, 11, THEME.Text, Enum.Font.GothamSemibold, nil, {
					Size = UDim2.new(0.7, 0, 1, 0),
				})
				local valLbl = mklabel(topRow, tostring(val)..suffix, 10, THEME.Accent, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right, {
					Size     = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.7, 0, 0, 0),
				})

				local track = new("Frame", {
					Size             = UDim2.new(1, 0, 0, 6),
					Position         = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = THEME.SliderBg,
					BorderSizePixel  = 0,
				}, wrapper)
				corner(track, 3)
				stroke(track, THEME.Border, 1)

				local pct = (val-min)/(max-min)
				local fill = new("Frame", {
					Size             = UDim2.new(pct, 0, 1, 0),
					BackgroundColor3 = THEME.SliderFill,
					BorderSizePixel  = 0,
				}, track)
				corner(fill, 3)

				local hitbox = new("TextButton", {
					Text             = "",
					BackgroundTransparency = 1,
					Size             = UDim2.new(1, 0, 1, 12),
					Position         = UDim2.new(0, 0, 0, -6),
				}, track)

				local function updateVal(inp)
					local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local raw = min + (max - min) * rel
					local mult = 10 ^ dec
					val = math.round(raw * mult) / mult
					tw(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.04)
					valLbl.Text = tostring(val) .. suffix
					cb(val)
					if flag then AlienV4.Flags[flag] = val end
				end

				hitbox.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateVal(inp)
					end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
						updateVal(inp)
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				local obj = {}
				function obj:Set(v)
					val = math.clamp(v, min, max)
					local p = (val-min)/(max-min)
					tw(fill, {Size = UDim2.new(p,0,1,0)}, 0.1)
					valLbl.Text = tostring(val)..suffix
					cb(val)
					if flag then AlienV4.Flags[flag] = val end
				end
				function obj:Get() return val end
				if flag then AlienV4.Flags[flag] = val end
				return obj
			end

			-- BUTTON
			function section:AddButton(opts)
				opts = opts or {}
				local lbl = opts.Name or "Button"
				local cb  = opts.Callback or function() end

				local btn = new("TextButton", {
					Text             = lbl,
					Font             = Enum.Font.GothamSemibold,
					TextSize         = 11,
					TextColor3       = THEME.Text,
					BackgroundColor3 = THEME.BtnBg,
					BorderSizePixel  = 0,
					Size             = UDim2.new(1, 0, 0, 22),
				}, items)
				corner(btn, 3)
				stroke(btn, THEME.Border, 1)

				btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = THEME.BtnHover}, 0.08) end)
				btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = THEME.BtnBg}, 0.08) end)
				btn.MouseButton1Click:Connect(function()
					tw(btn, {BackgroundColor3 = THEME.Accent}, 0.05)
					task.delay(0.14, function() tw(btn, {BackgroundColor3 = THEME.BtnBg}, 0.1) end)
					cb()
				end)

				local obj = {}
				function obj:SetText(t) btn.Text = t end
				return obj
			end

			-- DROPDOWN
			function section:AddDropdown(opts)
				opts = opts or {}
				local lbl      = opts.Name or "Dropdown"
				local itemList = opts.Items or {}
				local selected = opts.Default or itemList[1]
				local cb       = opts.Callback or function() end
				local flag     = opts.Flag

				local open = false

				local wrapper = new("Frame", {
					Size          = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
				}, items)
				vlist(wrapper, 1)

				local topRow = new("Frame", {
					Size             = UDim2.new(1, 0, 0, 22),
					BackgroundTransparency = 1,
				}, wrapper)
				mklabel(topRow, lbl, 11, THEME.Text, Enum.Font.GothamSemibold, nil, {
					Size = UDim2.new(0.46, 0, 1, 0),
				})

				local ddBtn = new("TextButton", {
					Text             = tostring(selected or "None") .. " ▾",
					Font             = Enum.Font.GothamSemibold,
					TextSize         = 10,
					TextColor3       = THEME.TextDim,
					BackgroundColor3 = THEME.BtnBg,
					BorderSizePixel  = 0,
					Size             = UDim2.new(0.54, 0, 1, 0),
					Position         = UDim2.new(0.46, 0, 0, 0),
				}, topRow)
				corner(ddBtn, 3)
				stroke(ddBtn, THEME.Border, 1)

				local ddList = new("Frame", {
					Size          = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = THEME.InputBg,
					BorderSizePixel  = 0,
					Visible       = false,
				}, wrapper)
				corner(ddList, 3)
				stroke(ddList, THEME.Border, 1)

				local function buildList()
					for _, c in pairs(ddList:GetChildren()) do
						if not c:IsA("UICorner") and not c:IsA("UIStroke") and not c:IsA("UIListLayout") then
							c:Destroy()
						end
					end
					if not ddList:FindFirstChildOfClass("UIListLayout") then
						vlist(ddList, 0)
					end
					for _, item in pairs(itemList) do
						local ib = new("TextButton", {
							Text             = tostring(item),
							Font             = Enum.Font.Gotham,
							TextSize         = 10,
							TextColor3       = item == selected and THEME.Text or THEME.TextDim,
							BackgroundColor3 = item == selected and THEME.CatSel or THEME.InputBg,
							BorderSizePixel  = 0,
							Size             = UDim2.new(1, 0, 0, 20),
							TextXAlignment   = Enum.TextXAlignment.Left,
						}, ddList)
						pad(ib, 0, 0, 8, 4)
						ib.MouseEnter:Connect(function() tw(ib, {BackgroundColor3 = THEME.BtnHover}, 0.08) end)
						ib.MouseLeave:Connect(function()
							tw(ib, {BackgroundColor3 = item==selected and THEME.CatSel or THEME.InputBg}, 0.08)
						end)
						ib.MouseButton1Click:Connect(function()
							selected = item
							ddBtn.Text = tostring(selected) .. " ▾"
							ddList.Visible = false
							open = false
							cb(selected)
							if flag then AlienV4.Flags[flag] = selected end
							buildList()
						end)
					end
				end
				buildList()

				ddBtn.MouseButton1Click:Connect(function()
					open = not open
					ddList.Visible = open
				end)

				local obj = {}
				function obj:Set(v)
					selected = v
					ddBtn.Text = tostring(v) .. " ▾"
					cb(v)
					if flag then AlienV4.Flags[flag] = v end
					buildList()
				end
				function obj:Get() return selected end
				function obj:Refresh(newItems) itemList = newItems; buildList() end
				if flag then AlienV4.Flags[flag] = selected end
				return obj
			end

			-- TEXTBOX
			function section:AddTextbox(opts)
				opts = opts or {}
				local lbl     = opts.Name or "Input"
				local ph      = opts.Placeholder or ""
				local default = opts.Default or ""
				local numOnly = opts.NumbersOnly or false
				local cb      = opts.Callback or function() end
				local flag    = opts.Flag

				local r = row(22)
				mklabel(r, lbl, 11, THEME.Text, Enum.Font.GothamSemibold, nil, {
					Size = UDim2.new(0.44, 0, 1, 0),
				})

				local box = new("TextBox", {
					Text              = default,
					PlaceholderText   = ph,
					Font              = Enum.Font.Gotham,
					TextSize          = 10,
					TextColor3        = THEME.Text,
					PlaceholderColor3 = THEME.TextOff,
					BackgroundColor3  = THEME.InputBg,
					BorderSizePixel   = 0,
					Size              = UDim2.new(0.56, 0, 1, 0),
					Position          = UDim2.new(0.44, 0, 0, 0),
					ClearTextOnFocus  = false,
				}, r)
				corner(box, 3)
				stroke(box, THEME.Border, 1)
				pad(box, 0, 0, 5, 4)

				box.FocusLost:Connect(function(enter)
					local t = box.Text
					if numOnly then
						t = t:gsub("[^%d%.%-]", "")
						box.Text = t
					end
					cb(t, enter)
					if flag then AlienV4.Flags[flag] = t end
				end)

				local obj = {}
				function obj:Get() return box.Text end
				function obj:Set(v)
					box.Text = tostring(v)
					cb(v)
					if flag then AlienV4.Flags[flag] = v end
				end
				if flag then AlienV4.Flags[flag] = default end
				return obj
			end

			-- KEYBIND
			function section:AddKeybind(opts)
				opts = opts or {}
				local lbl     = opts.Name or "Keybind"
				local default = opts.Default or Enum.KeyCode.Unknown
				local cb      = opts.Callback or function() end
				local flag    = opts.Flag

				local key = default
				local listening = false

				local r = row(22)
				mklabel(r, lbl, 11, THEME.Text, Enum.Font.GothamSemibold, nil, {
					Size = UDim2.new(0.6, 0, 1, 0),
				})

				local kBtn = new("TextButton", {
					Text             = "[" .. key.Name .. "]",
					Font             = Enum.Font.GothamSemibold,
					TextSize         = 10,
					TextColor3       = THEME.Accent,
					BackgroundColor3 = THEME.BtnBg,
					BorderSizePixel  = 0,
					Size             = UDim2.new(0.4, 0, 1, 0),
					Position         = UDim2.new(0.6, 0, 0, 0),
				}, r)
				corner(kBtn, 3)
				stroke(kBtn, THEME.Border, 1)

				kBtn.MouseButton1Click:Connect(function()
					listening = true
					kBtn.Text = "[...]"
					kBtn.TextColor3 = THEME.TextDim
				end)

				UserInputService.InputBegan:Connect(function(inp)
					if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
						key = inp.KeyCode
						kBtn.Text = "[" .. key.Name .. "]"
						kBtn.TextColor3 = THEME.Accent
						listening = false
						if flag then AlienV4.Flags[flag] = key end
					elseif not listening and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key then
						cb(key)
					end
				end)

				local obj = {}
				function obj:Set(k) key = k; kBtn.Text = "[" .. k.Name .. "]" end
				function obj:Get() return key end
				if flag then AlienV4.Flags[flag] = key end
				return obj
			end

			-- LABEL
			function section:AddLabel(txt)
				local lf = new("Frame", {
					Size             = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
				}, items)
				mklabel(lf, txt, 10, THEME.TextDim, Enum.Font.Gotham, nil, {
					Size = UDim2.new(1, 0, 1, 0),
				})
			end

			-- SEPARATOR
			function section:AddSeparator()
				new("Frame", {
					Size             = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = THEME.Border,
					BorderSizePixel  = 0,
				}, items)
			end

			return section
		end

		return tab
	end

	function window:SetTheme(t)
		for k, v in pairs(t) do THEME[k] = v end
	end

	function window:Destroy()
		gui:Destroy()
	end

	function window:Toggle()
		main.Visible = not main.Visible
	end

	return window
end

return AlienV4
