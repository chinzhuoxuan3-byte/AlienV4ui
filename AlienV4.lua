local AlienV4 = {}
AlienV4.__index = AlienV4

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local THEME = {
	Background = Color3.fromRGB(15, 15, 20),
	CategoryBg = Color3.fromRGB(20, 20, 28),
	TabBg = Color3.fromRGB(25, 25, 35),
	TabSelected = Color3.fromRGB(35, 35, 50),
	Accent = Color3.fromRGB(80, 120, 200),
	AccentHover = Color3.fromRGB(100, 140, 220),
	Text = Color3.fromRGB(220, 220, 230),
	TextDim = Color3.fromRGB(140, 140, 160),
	TextDisabled = Color3.fromRGB(80, 80, 100),
	Border = Color3.fromRGB(45, 45, 65),
	ToggleOn = Color3.fromRGB(60, 180, 100),
	ToggleOff = Color3.fromRGB(60, 60, 80),
	SliderFill = Color3.fromRGB(80, 120, 200),
	SliderBg = Color3.fromRGB(30, 30, 45),
	ButtonBg = Color3.fromRGB(35, 35, 52),
	ButtonHover = Color3.fromRGB(50, 50, 72),
	InputBg = Color3.fromRGB(18, 18, 26),
	ScrollBar = Color3.fromRGB(50, 50, 70),
	TitleBar = Color3.fromRGB(18, 18, 26),
	CategoryHeader = Color3.fromRGB(30, 30, 45),
	Notification = Color3.fromRGB(20, 20, 30),
	NotificationBorder = Color3.fromRGB(80, 120, 200),
}

local FONT = Enum.Font.GothamBold
local FONT_REG = Enum.Font.Gotham
local FONT_SEMI = Enum.Font.GothamSemibold

local function tween(obj, props, t, style, dir)
	local info = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function makeDraggable(frame, handle)
	local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			frame.Position = UDim2.new(
				framePos.X.Scale, framePos.X.Offset + delta.X,
				framePos.Y.Scale, framePos.Y.Offset + delta.Y
			)
		end
	end)
end

local function newInstance(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in pairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function stroke(parent, color, thickness)
	return newInstance("UIStroke", {
		Color = color or THEME.Border,
		Thickness = thickness or 1,
		Parent = parent,
	})
end

local function corner(parent, radius)
	return newInstance("UICorner", {
		CornerRadius = UDim.new(0, radius or 4),
		Parent = parent,
	})
end

local function padding(parent, t, b, l, r)
	return newInstance("UIPadding", {
		PaddingTop = UDim.new(0, t or 4),
		PaddingBottom = UDim.new(0, b or 4),
		PaddingLeft = UDim.new(0, l or 6),
		PaddingRight = UDim.new(0, r or 6),
		Parent = parent,
	})
end

local function listLayout(parent, dir, pad, align)
	return newInstance("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, pad or 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		Parent = parent,
	})
end

function AlienV4:CreateWindow(options)
	options = options or {}
	local title = options.Title or "AlienV4"
	local size = options.Size or UDim2.new(0, 620, 0, 420)
	local position = options.Position or UDim2.new(0.5, -310, 0.5, -210)
	local theme = options.Theme or {}
	for k, v in pairs(theme) do THEME[k] = v end

	local screenGui = newInstance("ScreenGui", {
		Name = "AlienV4_" .. title,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function() screenGui.Parent = CoreGui end)
	if not screenGui.Parent then screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

	local mainFrame = newInstance("Frame", {
		Name = "Main",
		Size = size,
		Position = position,
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	corner(mainFrame, 6)
	stroke(mainFrame, THEME.Border, 1)

	local titleBar = newInstance("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = THEME.TitleBar,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 6), Parent = titleBar })

	local titleFix = newInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -6),
		BackgroundColor3 = THEME.TitleBar,
		BorderSizePixel = 0,
		Parent = titleBar,
	})

	local titleLabel = newInstance("TextLabel", {
		Text = title,
		Font = FONT,
		TextSize = 13,
		TextColor3 = THEME.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Parent = titleBar,
	})

	local closeBtn = newInstance("TextButton", {
		Text = "×",
		Font = FONT,
		TextSize = 18,
		TextColor3 = THEME.TextDim,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -32, 0, 0),
		Parent = titleBar,
	})
	closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, { TextColor3 = Color3.fromRGB(220, 80, 80) }, 0.1) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, { TextColor3 = THEME.TextDim }, 0.1) end)

	local minimizeBtn = newInstance("TextButton", {
		Text = "−",
		Font = FONT,
		TextSize = 18,
		TextColor3 = THEME.TextDim,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -62, 0, 0),
		Parent = titleBar,
	})

	local minimized = false
	local contentFrame
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(mainFrame, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 32) }, 0.2)
		else
			tween(mainFrame, { Size = size }, 0.2)
		end
	end)
	minimizeBtn.MouseEnter:Connect(function() tween(minimizeBtn, { TextColor3 = THEME.Accent }, 0.1) end)
	minimizeBtn.MouseLeave:Connect(function() tween(minimizeBtn, { TextColor3 = THEME.TextDim }, 0.1) end)

	makeDraggable(mainFrame, titleBar)

	local bodyFrame = newInstance("Frame", {
		Name = "Body",
		Size = UDim2.new(1, 0, 1, -32),
		Position = UDim2.new(0, 0, 0, 32),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})

	local categoryList = newInstance("Frame", {
		Name = "CategoryList",
		Size = UDim2.new(0, 110, 1, 0),
		BackgroundColor3 = THEME.CategoryBg,
		BorderSizePixel = 0,
		Parent = bodyFrame,
	})
	stroke(categoryList, THEME.Border, 1)

	local catTitle = newInstance("TextLabel", {
		Text = "MODULES",
		Font = FONT,
		TextSize = 9,
		TextColor3 = THEME.TextDim,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = categoryList,
	})

	local catScroll = newInstance("ScrollingFrame", {
		Name = "CatScroll",
		Size = UDim2.new(1, 0, 1, -22),
		Position = UDim2.new(0, 0, 0, 22),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = THEME.ScrollBar,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Parent = categoryList,
	})
	listLayout(catScroll, Enum.FillDirection.Vertical, 1)
	padding(catScroll, 2, 2, 0, 0)

	local contentArea = newInstance("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 110, 0, 0),
		BackgroundTransparency = 1,
		Parent = bodyFrame,
	})

	local pages = {}
	local currentPage = nil
	local notifQueue = {}

	local notifContainer = newInstance("Frame", {
		Name = "Notifications",
		Size = UDim2.new(0, 240, 1, 0),
		Position = UDim2.new(1, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = mainFrame,
	})
	listLayout(notifContainer, Enum.FillDirection.Vertical, 6)

	local window = {}

	function window:Notify(options)
		options = options or {}
		local nTitle = options.Title or "Notification"
		local nDesc = options.Description or ""
		local nDuration = options.Duration or 3
		local nType = options.Type or "Info"

		local borderColor = THEME.NotificationBorder
		if nType == "Success" then borderColor = Color3.fromRGB(60, 180, 100)
		elseif nType == "Error" then borderColor = Color3.fromRGB(200, 60, 60)
		elseif nType == "Warning" then borderColor = Color3.fromRGB(200, 160, 40) end

		local notif = newInstance("Frame", {
			Name = "Notif",
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundColor3 = THEME.Notification,
			BorderSizePixel = 0,
			Parent = notifContainer,
		})
		corner(notif, 4)

		local accentLine = newInstance("Frame", {
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = borderColor,
			BorderSizePixel = 0,
			Parent = notif,
		})
		corner(accentLine, 2)

		newInstance("TextLabel", {
			Text = nTitle,
			Font = FONT,
			TextSize = 12,
			TextColor3 = THEME.Text,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -12, 0, 18),
			Position = UDim2.new(0, 10, 0, 6),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = notif,
		})
		newInstance("TextLabel", {
			Text = nDesc,
			Font = FONT_REG,
			TextSize = 11,
			TextColor3 = THEME.TextDim,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -12, 0, 30),
			Position = UDim2.new(0, 10, 0, 24),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = notif,
		})

		stroke(notif, borderColor, 1)
		notif.BackgroundTransparency = 1
		tween(notif, { BackgroundTransparency = 0 }, 0.2)

		task.delay(nDuration, function()
			tween(notif, { BackgroundTransparency = 1 }, 0.3)
			task.wait(0.35)
			notif:Destroy()
		end)
	end

	function window:CreateTab(name, icon)
		local tabBtn = newInstance("TextButton", {
			Name = name,
			Text = (icon and (icon .. "  ") or "") .. name,
			Font = FONT_SEMI,
			TextSize = 11,
			TextColor3 = THEME.TextDim,
			BackgroundColor3 = THEME.CategoryBg,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = catScroll,
		})
		padding(tabBtn, 0, 0, 10, 6)
		corner(tabBtn, 3)

		local indicator = newInstance("Frame", {
			Size = UDim2.new(0, 2, 0.7, 0),
			Position = UDim2.new(0, 0, 0.15, 0),
			BackgroundColor3 = THEME.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = tabBtn,
		})
		corner(indicator, 2)

		local page = newInstance("ScrollingFrame", {
			Name = name .. "_Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = THEME.ScrollBar,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Visible = false,
			Parent = contentArea,
		})
		listLayout(page, Enum.FillDirection.Vertical, 2)
		padding(page, 6, 6, 6, 8)

		pages[name] = { page = page, btn = tabBtn, indicator = indicator }

		if not currentPage then
			currentPage = name
			page.Visible = true
			tabBtn.TextColor3 = THEME.Text
			tabBtn.BackgroundColor3 = THEME.TabSelected
			indicator.BackgroundTransparency = 0
		end

		tabBtn.MouseButton1Click:Connect(function()
			if currentPage == name then return end
			if pages[currentPage] then
				pages[currentPage].page.Visible = false
				tween(pages[currentPage].btn, { TextColor3 = THEME.TextDim, BackgroundColor3 = THEME.CategoryBg }, 0.1)
				tween(pages[currentPage].indicator, { BackgroundTransparency = 1 }, 0.1)
			end
			currentPage = name
			page.Visible = true
			tween(tabBtn, { TextColor3 = THEME.Text, BackgroundColor3 = THEME.TabSelected }, 0.1)
			tween(indicator, { BackgroundTransparency = 0 }, 0.1)
		end)

		tabBtn.MouseEnter:Connect(function()
			if currentPage ~= name then
				tween(tabBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 42) }, 0.1)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if currentPage ~= name then
				tween(tabBtn, { BackgroundColor3 = THEME.CategoryBg }, 0.1)
			end
		end)

		local tab = {}

		local function makeSection(sectionName)
			local sectionFrame = newInstance("Frame", {
				Name = sectionName,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = THEME.TabBg,
				BorderSizePixel = 0,
				Parent = page,
			})
			corner(sectionFrame, 4)
			stroke(sectionFrame, THEME.Border, 1)

			local sectionHeader = newInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = THEME.CategoryHeader,
				BorderSizePixel = 0,
				Parent = sectionFrame,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sectionHeader })
			local headerFix = newInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 4),
				Position = UDim2.new(0, 0, 1, -4),
				BackgroundColor3 = THEME.CategoryHeader,
				BorderSizePixel = 0,
				Parent = sectionHeader,
			})

			newInstance("TextLabel", {
				Text = sectionName,
				Font = FONT,
				TextSize = 11,
				TextColor3 = THEME.TextDim,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sectionHeader,
			})

			local itemsFrame = newInstance("Frame", {
				Name = "Items",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 24),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = sectionFrame,
			})
			listLayout(itemsFrame, Enum.FillDirection.Vertical, 0)
			padding(itemsFrame, 2, 4, 6, 6)

			local section = {}

			function section:AddToggle(options)
				options = options or {}
				local lbl = options.Name or "Toggle"
				local default = options.Default or false
				local callback = options.Callback or function() end
				local flag = options.Flag

				local state = default
				local row = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Parent = itemsFrame,
				})

				newInstance("TextLabel", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -46, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})

				local toggleBg = newInstance("Frame", {
					Size = UDim2.new(0, 34, 0, 16),
					Position = UDim2.new(1, -36, 0.5, -8),
					BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff,
					BorderSizePixel = 0,
					Parent = row,
				})
				corner(toggleBg, 8)

				local knob = newInstance("Frame", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Parent = toggleBg,
				})
				corner(knob, 6)

				local btn = newInstance("TextButton", {
					Text = "",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Parent = row,
				})

				local toggleObj = {}
				function toggleObj:Set(val)
					state = val
					tween(toggleBg, { BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff }, 0.15)
					tween(knob, { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) }, 0.15)
					callback(state)
					if flag then AlienV4.Flags[flag] = state end
				end
				function toggleObj:Get() return state end

				btn.MouseButton1Click:Connect(function()
					toggleObj:Set(not state)
				end)

				if flag then AlienV4.Flags[flag] = state end
				return toggleObj
			end

			function section:AddSlider(options)
				options = options or {}
				local lbl = options.Name or "Slider"
				local min = options.Min or 0
				local max = options.Max or 100
				local default = options.Default or min
				local decimals = options.Decimals or 0
				local suffix = options.Suffix or ""
				local callback = options.Callback or function() end
				local flag = options.Flag

				local value = math.clamp(default, min, max)

				local row = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
					Parent = itemsFrame,
				})

				local topRow = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Parent = row,
				})
				newInstance("TextLabel", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.7, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = topRow,
				})
				local valLabel = newInstance("TextLabel", {
					Text = tostring(value) .. suffix,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Accent,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.7, 0, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = topRow,
				})

				local sliderBg = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 8),
					Position = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = THEME.SliderBg,
					BorderSizePixel = 0,
					Parent = row,
				})
				corner(sliderBg, 4)
				stroke(sliderBg, THEME.Border, 1)

				local fillPct = (value - min) / (max - min)
				local sliderFill = newInstance("Frame", {
					Size = UDim2.new(fillPct, 0, 1, 0),
					BackgroundColor3 = THEME.SliderFill,
					BorderSizePixel = 0,
					Parent = sliderBg,
				})
				corner(sliderFill, 4)

				local draggingSlider = false
				local sliderBtn = newInstance("TextButton", {
					Text = "",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Parent = sliderBg,
				})

				local function updateSlider(input)
					local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
					local raw = min + (max - min) * rel
					local mult = 10 ^ decimals
					value = math.round(raw * mult) / mult
					tween(sliderFill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.05)
					valLabel.Text = tostring(value) .. suffix
					callback(value)
					if flag then AlienV4.Flags[flag] = value end
				end

				sliderBtn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = true
						updateSlider(input)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateSlider(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						draggingSlider = false
					end
				end)

				local sliderObj = {}
				function sliderObj:Set(val)
					value = math.clamp(val, min, max)
					local pct = (value - min) / (max - min)
					tween(sliderFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.1)
					valLabel.Text = tostring(value) .. suffix
					callback(value)
					if flag then AlienV4.Flags[flag] = value end
				end
				function sliderObj:Get() return value end

				if flag then AlienV4.Flags[flag] = value end
				return sliderObj
			end

			function section:AddButton(options)
				options = options or {}
				local lbl = options.Name or "Button"
				local callback = options.Callback or function() end
				local desc = options.Description

				local btn = newInstance("TextButton", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundColor3 = THEME.ButtonBg,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 24),
					Parent = itemsFrame,
				})
				corner(btn, 3)
				stroke(btn, THEME.Border, 1)

				btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = THEME.ButtonHover }, 0.1) end)
				btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = THEME.ButtonBg }, 0.1) end)
				btn.MouseButton1Click:Connect(function()
					tween(btn, { BackgroundColor3 = THEME.Accent }, 0.05)
					task.delay(0.1, function() tween(btn, { BackgroundColor3 = THEME.ButtonBg }, 0.1) end)
					callback()
				end)

				local btnObj = {}
				function btnObj:SetText(t) btn.Text = t end
				return btnObj
			end

			function section:AddDropdown(options)
				options = options or {}
				local lbl = options.Name or "Dropdown"
				local items = options.Items or {}
				local default = options.Default or items[1]
				local multiSelect = options.MultiSelect or false
				local callback = options.Callback or function() end
				local flag = options.Flag

				local selected = default
				local open = false

				local container = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Parent = itemsFrame,
				})
				listLayout(container, Enum.FillDirection.Vertical, 2)

				local headerRow = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Parent = container,
				})
				newInstance("TextLabel", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = headerRow,
				})

				local ddBtn = newInstance("TextButton", {
					Text = tostring(selected) .. "  ▾",
					Font = FONT_SEMI,
					TextSize = 10,
					TextColor3 = THEME.TextDim,
					BackgroundColor3 = THEME.ButtonBg,
					BorderSizePixel = 0,
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Center,
					Parent = headerRow,
				})
				corner(ddBtn, 3)
				stroke(ddBtn, THEME.Border, 1)

				local ddList = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundColor3 = THEME.InputBg,
					BorderSizePixel = 0,
					Visible = false,
					AutomaticSize = Enum.AutomaticSize.Y,
					Parent = container,
				})
				corner(ddList, 3)
				stroke(ddList, THEME.Border, 1)
				listLayout(ddList, Enum.FillDirection.Vertical, 0)

				for _, item in pairs(items) do
					local itemBtn = newInstance("TextButton", {
						Text = tostring(item),
						Font = FONT_REG,
						TextSize = 11,
						TextColor3 = THEME.TextDim,
						BackgroundColor3 = THEME.InputBg,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 22),
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = ddList,
					})
					padding(itemBtn, 0, 0, 8, 6)
					itemBtn.MouseEnter:Connect(function() tween(itemBtn, { BackgroundColor3 = THEME.ButtonHover }, 0.1) end)
					itemBtn.MouseLeave:Connect(function()
						local c = (selected == item) and THEME.TabSelected or THEME.InputBg
						tween(itemBtn, { BackgroundColor3 = c }, 0.1)
					end)
					itemBtn.MouseButton1Click:Connect(function()
						selected = item
						ddBtn.Text = tostring(selected) .. "  ▾"
						ddList.Visible = false
						open = false
						callback(selected)
						if flag then AlienV4.Flags[flag] = selected end
					end)
				end

				ddBtn.MouseButton1Click:Connect(function()
					open = not open
					ddList.Visible = open
				end)

				local ddObj = {}
				function ddObj:Set(val) selected = val; ddBtn.Text = tostring(val) .. "  ▾"; callback(val); if flag then AlienV4.Flags[flag] = val end end
				function ddObj:Get() return selected end
				function ddObj:Refresh(newItems)
					for _, c in pairs(ddList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
					for _, item in pairs(newItems) do
						local itemBtn = newInstance("TextButton", {
							Text = tostring(item), Font = FONT_REG, TextSize = 11,
							TextColor3 = THEME.TextDim, BackgroundColor3 = THEME.InputBg,
							BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 22),
							TextXAlignment = Enum.TextXAlignment.Left, Parent = ddList,
						})
						padding(itemBtn, 0, 0, 8, 6)
					end
				end

				if flag then AlienV4.Flags[flag] = selected end
				return ddObj
			end

			function section:AddTextbox(options)
				options = options or {}
				local lbl = options.Name or "Input"
				local placeholder = options.Placeholder or "Type here..."
				local default = options.Default or ""
				local numOnly = options.NumbersOnly or false
				local callback = options.Callback or function() end
				local flag = options.Flag

				local row = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Parent = itemsFrame,
				})
				newInstance("TextLabel", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.45, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})
				local box = newInstance("TextBox", {
					Text = default,
					PlaceholderText = placeholder,
					Font = FONT_REG,
					TextSize = 11,
					TextColor3 = THEME.Text,
					PlaceholderColor3 = THEME.TextDisabled,
					BackgroundColor3 = THEME.InputBg,
					BorderSizePixel = 0,
					Size = UDim2.new(0.55, 0, 1, 0),
					Position = UDim2.new(0.45, 0, 0, 0),
					ClearTextOnFocus = false,
					Parent = row,
				})
				corner(box, 3)
				stroke(box, THEME.Border, 1)
				padding(box, 0, 0, 6, 6)

				box.FocusLost:Connect(function(enter)
					local t = box.Text
					if numOnly then t = t:gsub("[^%d%.%-]", "") box.Text = t end
					callback(t, enter)
					if flag then AlienV4.Flags[flag] = t end
				end)

				local tbObj = {}
				function tbObj:Get() return box.Text end
				function tbObj:Set(val) box.Text = tostring(val); callback(val); if flag then AlienV4.Flags[flag] = val end end
				if flag then AlienV4.Flags[flag] = default end
				return tbObj
			end

			function section:AddKeybind(options)
				options = options or {}
				local lbl = options.Name or "Keybind"
				local default = options.Default or Enum.KeyCode.Unknown
				local callback = options.Callback or function() end
				local flag = options.Flag

				local key = default
				local listening = false

				local row = newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
					Parent = itemsFrame,
				})
				newInstance("TextLabel", {
					Text = lbl,
					Font = FONT_SEMI,
					TextSize = 11,
					TextColor3 = THEME.Text,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.6, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = row,
				})
				local keyBtn = newInstance("TextButton", {
					Text = key.Name,
					Font = FONT_SEMI,
					TextSize = 10,
					TextColor3 = THEME.Accent,
					BackgroundColor3 = THEME.ButtonBg,
					BorderSizePixel = 0,
					Size = UDim2.new(0.4, 0, 1, 0),
					Position = UDim2.new(0.6, 0, 0, 0),
					Parent = row,
				})
				corner(keyBtn, 3)
				stroke(keyBtn, THEME.Border, 1)

				keyBtn.MouseButton1Click:Connect(function()
					listening = true
					keyBtn.Text = "..."
					keyBtn.TextColor3 = THEME.TextDim
				end)

				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode
						keyBtn.Text = key.Name
						keyBtn.TextColor3 = THEME.Accent
						listening = false
						if flag then AlienV4.Flags[flag] = key end
					elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
						callback(key)
					end
				end)

				local kbObj = {}
				function kbObj:Set(k) key = k; keyBtn.Text = k.Name end
				function kbObj:Get() return key end
				if flag then AlienV4.Flags[flag] = key end
				return kbObj
			end

			function section:AddLabel(text)
				newInstance("TextLabel", {
					Text = text,
					Font = FONT_REG,
					TextSize = 11,
					TextColor3 = THEME.TextDim,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = itemsFrame,
				})
			end

			function section:AddSeparator()
				newInstance("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = THEME.Border,
					BorderSizePixel = 0,
					Parent = itemsFrame,
				})
			end

			return section
		end

		function tab:CreateSection(name)
			return makeSection(name)
		end

		return tab
	end

	function window:SetTheme(newTheme)
		for k, v in pairs(newTheme) do THEME[k] = v end
	end

	function window:Destroy()
		screenGui:Destroy()
	end

	function window:Toggle()
		mainFrame.Visible = not mainFrame.Visible
	end

	return window
end

AlienV4.Flags = {}

return AlienV4
