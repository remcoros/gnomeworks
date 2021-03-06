




local Window = {}

--[[
 the SetBackdrop system has some texture coordinate problems, so i wrote this to emulate

 i'm creating an invisible frame for sizing simplicity, but the textures are actually parented to the real frame (so they are place in the correct drawing layer)
 even tho they are referenced from this invisible frame (as indices into the frame table)
]]

do
	local opposingPoint = {
		["LEFT"] = "RIGHT",
		["RIGHT"] = "LEFT",
		["TOP"] = "BOTTOM",
		["BOTTOM"] = "TOP",
	}


	local textureQuads = {
		LEFT = 0,
		RIGHT = 1,
		TOP = 2,
		BOTTOM = 3,
		TOPLEFT = 4,
		TOPRIGHT = 5,
		BOTTOMLEFT = 6,
		BOTTOMRIGHT = 7,
	}

	local LEFTRIGHT = {"LEFT", "RIGHT"}
	local TOPBOTTOM = {"TOP", "BOTTOM"}
	local ALLQUADS = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOP", "BOTTOM"}
	local CORNERS = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

	local mouseHintTexture


	local function ResizeBetterBackdrop(frame)
		if not frame then
			return
		end

		local w,h = frame:GetWidth()-frame.edgeSize*2, frame:GetHeight()-frame.edgeSize*2

		for k,i in pairs(LEFTRIGHT) do
			local t = frame["texture"..i]

			local y = h/frame.edgeSize

			local q = textureQuads[i]

			t:SetTexCoord(q*.125, q*.125+.125, 0, y)
		end

		for k,i in pairs(TOPBOTTOM) do
			local t = frame["texture"..i]

			local y = w/frame.edgeSize

			local q = textureQuads[i]

			local x1 = q*.125
			local x2 = q*.125+.125

			t:SetTexCoord(x1,0, x2,0, x1,y, x2, y)
		end

		frame.textureBG:SetTexCoord(0,w/frame.tileSize, 0,h/frame.tileSize)
	end


	local function SetBetterBackdropColor(frame,...)
		if not frame or not frame.backDrop then
			return
		end

		local backDrop = frame.backDrop

		backDrop.textureLEFT:SetVertexColor(...)
		backDrop.textureRIGHT:SetVertexColor(...)
		backDrop.textureBOTTOM:SetVertexColor(...)
		backDrop.textureTOP:SetVertexColor(...)

		backDrop.textureTOPLEFT:SetVertexColor(...)
		backDrop.textureTOPRIGHT:SetVertexColor(...)
		backDrop.textureBOTTOMLEFT:SetVertexColor(...)
		backDrop.textureBOTTOMRIGHT:SetVertexColor(...)

		backDrop.textureBG:SetVertexColor(...)
	end



	local function SetBetterBackdrop(frame, bd)
		if not frame.backDrop then
			frame.backDrop = CreateFrame("Frame", nil, frame)


			for k,i in pairs(ALLQUADS) do
				frame.backDrop["texture"..i] =  frame:CreateTexture(nil, "ARTWORK")
			end

			frame.backDrop.textureBG = frame:CreateTexture(nil,"ARTWORK")
		end

		frame.backDrop.edgeSize = bd.edgeSize
		frame.backDrop.tileSize = bd.tileSize

		frame.backDrop:SetPoint("TOPLEFT",frame,"TOPLEFT",-bd.insets.left, bd.insets.top)
		frame.backDrop:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT", bd.insets.right, -bd.insets.bottom)

		local w,h = frame:GetWidth()-bd.edgeSize*2, frame:GetHeight()-bd.edgeSize*2

		frame.backDrop.textureBG:SetTexture(bd.bgFile, bd.tile)

		for k,i in pairs(CORNERS) do
			local t = frame.backDrop["texture"..i]

			t:SetTexture(bd.edgeFile)
			t:SetPoint(i, frame.backDrop)
			t:SetWidth(bd.edgeSize)
			t:SetHeight(bd.edgeSize)

			local q = textureQuads[i]

			t:SetTexCoord(q*.125,q*.125+.125, 0,1)

		end

		for k,i in pairs(LEFTRIGHT) do
			local t = frame.backDrop["texture"..i]

			t:SetTexture(bd.edgeFile, true)
			t:SetPoint(i, frame.backDrop)
			t:SetPoint("BOTTOM", frame.backDrop, "BOTTOM", 0, bd.edgeSize)
			t:SetPoint("TOP", frame.backDrop, "TOP", 0, -bd.edgeSize)
			t:SetWidth(bd.edgeSize)

			local y = h/bd.edgeSize

			local q = textureQuads[i]

			t:SetTexCoord(q*.125, q*.125+.125, 0, y)
		end

		for k,i in pairs(TOPBOTTOM) do
			local t = frame.backDrop["texture"..i]

			t:SetTexture(bd.edgeFile, true)
			t:SetPoint(i, frame.backDrop)
			t:SetPoint("LEFT", frame.backDrop, "LEFT", bd.edgeSize, 0)
			t:SetPoint("RIGHT", frame.backDrop, "RIGHT", -bd.edgeSize, 0)
			t:SetHeight(bd.edgeSize)

			local y = w/bd.edgeSize

			local q = textureQuads[i]

			local x1 = q*.125
			local x2 = q*.125+.125

			if i == "TOP" then
				x1,x2 = x2, x1
			end

			t:SetTexCoord(x1,0, x2,0, x1,y, x2, y)
		end

		frame.backDrop.textureBG:SetPoint("TOPLEFT", frame.backDrop, "TOPLEFT", bd.edgeSize, -bd.edgeSize)
		frame.backDrop.textureBG:SetPoint("BOTTOMRIGHT", frame.backDrop, "BOTTOMRIGHT", -bd.edgeSize, bd.edgeSize)


		frame.backDrop.textureBG:SetTexCoord(0,w/bd.tileSize, 0,h/bd.tileSize)

		frame.backDrop:SetScript("OnSizeChanged", ResizeBetterBackdrop)
	end



	local function GetSizingPoint(frame)
		local x,y = GetCursorPosition()
		local s = frame:GetEffectiveScale()
		local resizeWidth = 20

		local left,bottom,width,height = frame:GetRect()

		x = x/s - left
		y = y/s - bottom

		if x < resizeWidth then
			if y < resizeWidth then return "BOTTOMLEFT" end

			if y > height-resizeWidth then return "TOPLEFT" end

			return "LEFT"
		end

		if x > width-resizeWidth then
			if y < resizeWidth then return "BOTTOMRIGHT" end

			if y > height-resizeWidth then return "TOPRIGHT" end

			return "RIGHT"
		end

		if y < resizeWidth then return "BOTTOM" end

		if y > height-resizeWidth then return "TOP" end

		return "UNKNOWN"
	end



	local function DockWindow(frame, parent, point, relativePoint, offX, offY)
		point = point or "LEFT"
		relativePoint = relativePoint or opposingPoint[point] or "CENTER"
		offX = offX or 0
		offY = offY or 0

		frame:SetPoint(point, parent, relativePoint, offX, offY)

		frame.dockParent = parent
		frame.dockPoint = point
		frame.dockParams = { point, parent, relativePoint, offX, offY }

		parent.dockChildren[frame] = frame.dockParams

		if point == "LEFT" or point == "RIGHT" then
			frame:SetHeight(parent:GetHeight())
		else
			frame:SetWidth(parent:GetWidth())
		end


		if not frame.dockTab then
			frame.dockTab = CreateFrame("Button",nil,parent)

			local tab = frame.dockTab

			tab:SetPoint(point,parent,relativePoint,offX,offY)
			tab:SetWidth(24)
			tab:SetHeight(96)

			tab:EnableMouse(true)

			local bg = tab:CreateTexture(nil,"ARTWORK")
--C:\Program Files\Games\World of Warcraft\Blizzard Interface Art (enUS)\Spellbook\UI-SpellBook-Tab-Unselected.blp

--			bg:SetTexture("Interface\\Spellbook\\SpellBook-SkillLineTab.blp")
			bg:SetTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected.blp")

--			bg:SetRotation(3.14159/2)
			bg:SetTexCoord(0,.3, 1,.3, 0,.8, 1,.8)

			bg:SetAllPoints()


			local t = tab:CreateTexture(nil,"OVERLAY")

			t:SetTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")

			t:SetPoint("LEFT")
			t:SetWidth(16)
			t:SetHeight(32)

			t:SetVertexColor(1,1,1,.75)

			tab:SetScript("OnClick", function() frame:Show() end)
			frame:HookScript("OnShow", function(f) f.dockTab:Hide() end)
			frame:HookScript("OnHide", function(f) f.dockTab:Show() end)

			tab:Hide()
		end
	end



	function Window:CreateResizableWindow(frameName, windowTitle, width, height, resizeFunction, config)
		local frame = CreateFrame("Frame",frameName,UIParent)
--		frame:Hide()

--		frame:SetFrameStrata("DIALOG")

		frame:SetClampedToScreen(true)

		frame:SetResizable(true)
		frame:SetMovable(true)
--		frame:SetUserPlaced(true)
		frame:EnableMouse(true)
		frame:SetDontSavePosition(true)


		if not config.window then
			config.window = {}
		end

		if not config.window[frameName] then
			config.window[frameName] = { x = 0, y = 0, width = width, height = height, r=1,g=1,b=1,opacity=1, scale = 1}
		end

		frame.config = config.window[frameName]
--[[
frame.config.scale = 1.5
frame.config.width = width
frame.config.height = height
frame.config.x = 0
frame.config.y = 0
]]

		local x, y = frame.config.x, frame.config.y
		local width, height = frame.config.width, frame.config.height

		local r,g,b = frame.config.r or 255, frame.config.g or 255, frame.config.b or 255
		local opacity = frame.config.opacity or 1
		local scale = frame.config.scale or 1

		frame:SetPoint("CENTER",x,y)
		frame:SetWidth(width)
		frame:SetHeight(height)

		frame:SetAlpha(math.max(.1,opacity))

		frame:SetScale(scale)

		frame.dockChildren = {}


		frame.resizeFunction = resizeFunction


		SetBetterBackdrop(frame,{bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBackground.tga",
												edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBorder.tga",
												tile = true, tileSize = 48, edgeSize = 48,
												insets = { left = 3, right = 3, top = 3, bottom = 3 }})

		SetBetterBackdropColor(frame, r,g,b)

--[[
		self:SetBetterBackdrop(frame,{bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\resizableBarberFrameBG.tga",
												edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\resizableBarberFrameBorder.tga",
												tile = true, tileSize = 48, edgeSize = 48,
												insets = { left = 4, right = 4, top = 4, bottom = 4 }})
]]

		local OnSizeChange

		function OnSizeChange(frame, w,h)
			if frame.sizingMode == "SCALE" then
				local oldScale = frame:GetScale()

--				local oldW, oldH = frame.config.width / (frame.config.scale or 1), frame.config.height / (frame.config.scale or 1)
				local oldW, oldH = frame.config.width, frame.config.height

print(frame:GetName() or frame, oldScale * w / oldW)
				local newScale = oldScale * w / oldW
				if (newScale > .25 and newScale < 5) then
					frame:SetScript("OnSizeChanged", nil)

					frame:SetScale(newScale)
--					frame:SetWidth(w/newScale)
--					frame:SetHeight(h/newScale)
					frame:SetSize(w/newScale, h/newScale)

					frame:SetScript("OnSizeChanged", OnSizeChange)

					if frame.dockChildren then
						for child,params in pairs(frame.dockChildren) do
							child:SetScale(newScale)
						end
					end

					h = h / newScale
				end
			end

			if frame.dockChildren then
				for child,params in pairs(frame.dockChildren) do
					child:SetHeight(h)
				end
			end


			if frame.resizeFunction then
				frame.resizeFunction()
			end
		end


--		frame:SetScript("OnSizeChanged", OnSizeChange)

		frame.SavePosition = function(f)
			local config = f.config

			config.width = f:GetWidth()
			config.height = f:GetHeight()

			config.scale = f:GetScale()

			local s = f:GetEffectiveScale()

			local cx, cy = f:GetCenter()
			local ux, uy = UIParent:GetCenter()


			config.x = (cx*config.scale - ux)/config.scale
			config.y = (cy*config.scale - uy)/config.scale

			if f.resizeFunction then
				f.resizeFunction()
			end
		end

		frame.SaveSize = function(f)
			local config = f.config

			config.width = f:GetWidth()
			config.height = f:GetHeight()

			config.scale = f:GetScale()
		end

--[[
		mouseHintTexture = frame:CreateTexture(nil,"OVERLAY")
		mouseHintTexture:SetWidth(32)
		mouseHintTexture:SetHeight(32)
		mouseHintTexture:Show()
		mouseHintTexture:SetTexture("Interface\\AddOns\\GnomeWorks\\Art\\arrow.tga")

--		mouseHintTexture:SetPoint("CENTER",UIParent,"BOTTOMLEFT",100,100)

		frame:SetScript("OnUpdate", function()

			if mouseHintTexture:IsShown() then
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				mouseHintTexture:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x/uiScale,y/uiScale)

--				mouseHintTexture:
			end
		end)

		frame:SetScript("OnEnter", function() print("OnEnter") mouseHintTexture:Show() end)
		frame:SetScript("OnLeave", function() print("OnLeave") mouseHintTexture:Hide() end)
]]

		frame:SetScript("OnUpdate", function(frame)
			if frame.sizingMode then
				local p = frame.sizingPoint
				local scale = frame:GetEffectiveScale()

				local x,y = GetCursorPosition()

				x = x / scale
				y = y / scale

				local l,r,b,t = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()

				local minW, minH = frame:GetMinResize()

				local s = frame:GetScale()

				if frame.sizingMode == "SCALE" then
					local sx,sy = 1,1

					local oldScale = s

					local maxWidth = (r-l)*2/s
					local minWidth = (r-l)*.5/s

					if p == "LEFT" or p == "TOPLEFT" or p == "BOTTOMLEFT" then
						local newL = x
						local minL = r - maxWidth
						local maxL = r - minWidth

						if newL < minL then
							newL = minL
						end

						if newL > maxL then
							newL = maxL
						end

						sx = (r - newL) / (r-l)
						l = newL
					elseif p == "RIGHT" or p == "TOPRIGHT" or p == "BOTTOMRIGHT" then
						local newR = x
						local minR = l + minWidth
						local maxR = l + maxWidth

						if newR < minR then
							newR = minR
						end

						if newR > maxR then
							newR = maxR
						end
						sx = (newR - l) / (r-l)
					end
--[[
					if p == "TOP" or p == "TOPLEFT" or p == "TOPRIGHT" then
						sy = (y - b) / (t-b)
					elseif p == "BOTTOM" or p == "BOTTOMLEFT" or p == "BOTTOMRIGHT" then
						sy = (t - y) / (t-b)
						b = y
					end
]]
					local newS

					if math.abs(1-sx) > math.abs(1-sy) then
						newS = sx
					else
						newS = sy
					end

					s = s * newS

					if s < .5 then s = .5 end
					if s > 2 then s = 2 end

					newS = s/oldScale

					local w = r-l
					local h = t-b


					frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l/newS,b/newS)
--					frame:SetSize(w,h)

					frame:SetScale(s)

					if frame.dockChildren then
						for child,params in pairs(frame.dockChildren) do
							child:SetScale(s)
						end
					end
				else
					if p == "LEFT" or p == "TOPLEFT" or p == "BOTTOMLEFT" then
						l = x
						if r-l < minW then
							l = r-minW
						end
					elseif p == "RIGHT" or p == "TOPRIGHT" or p == "BOTTOMRIGHT" then
						r = x

						if r-l < minW then
							r = l+minW
						end
					end

					if p == "TOP" or p == "TOPLEFT" or p == "TOPRIGHT" then
						t = y
						if t-b < minH then
							t = b+minH
						end
					elseif p == "BOTTOM" or p == "BOTTOMLEFT" or p == "BOTTOMRIGHT" then
						b = y
						if t-b < minH then
							b = t-minH
						end
					end

					local w = r-l
					local h = t-b

					frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l,b)
					frame:SetSize(w,h)

					if frame.dockChildren then
						for child,params in pairs(frame.dockChildren) do
							child:SetHeight(h)
						end
					end
				end


				if frame.resizeFunction then
					frame.resizeFunction()
				end
			end
		end)


		frame:SetScript("OnMouseDown", function()
			local sizePoint = GetSizingPoint(frame)

			if sizePoint ~= "UNKNOWN" then
				if not frame.dockParent or not frame.dockParent:IsShown() then
					if IsShiftKeyDown() then
						frame.sizingMode = "SCALE"
					else
						frame.sizingMode = "RESHAPE"
					end
					frame.sizingPoint = sizePoint

--					frame:StartSizing(sizePoint)
				else
					if sizePoint == opposingPoint[frame.dockPoint] then
						if IsShiftKeyDown() then
							frame.sizingMode = "SCALE"
						else
							frame.sizingMode = "RESHAPE"
							frame.sizingPoint = sizePoint
						end


--						frame:StartSizing(sizePoint)
					end
				end
			end
		end)

		frame:SetScript("OnMouseUp", function()
			if not frame.dockParent or not frame.dockParent:IsShown() then
				frame.sizingMode = nil
				frame:StopMovingOrSizing()
				frame:SavePosition()
			else
				frame.sizingMode = nil
				frame:StopMovingOrSizing()
				frame:SaveSize()

				frame:ClearAllPoints()
				frame:SetPoint(unpack(frame.dockParams))
			end
		end)

		frame:SetScript("OnHide", function()
			if not frame.dockParent or not frame.dockParent:IsShown() then
				frame.sizingMode = nil
				frame:StopMovingOrSizing()
				frame:SavePosition()
			end

			for child,params in pairs(frame.dockChildren) do
				local config = child.config

				local x, y = config.x, config.y
				local width, height = config.width, config.height
				local scale = config.scale


				child:ClearAllPoints()

				child:SetPoint("CENTER",x,y)
				child:SetWidth(width)
				child:SetHeight(height)
				child:SetScale(scale)

				if child.resizeFunction then
					child.resizeFunction()
				end
			end
		end)


		frame:SetScript("OnShow", function()
			local width, height = frame:GetWidth(), frame:GetHeight()
			local scale = frame.config.scale

			for child,params in pairs(frame.dockChildren) do
				child:ClearAllPoints()
--				child:SetWidth(width)
				child:SetHeight(height)
				child:SetScale(scale)

				child:SetPoint(unpack(params))
			end
		end)


		local windowMenu = {
--			{ text = "** DEBUG: Raise Frame Level **", notCheckable = 1, func = function() local level = frame.mover:GetFrameLevel() print("raise level",level) frame.mover:SetFrameLevel(level+1) end },
--			{ text = "** DEBUG: Lower Frame Level **", notCheckable = 1, func = function() local level = frame.mover:GetFrameLevel() print("lower level",level) frame.mover:SetFrameLevel(level-1) end },
			{ text = "Raise Frame", notCheckable = 1, func = function() frame:SetFrameStrata("DIALOG")  if frame.title then frame.title:SetFrameStrata("DIALOG") end end },
			{ text = "Lower Frame", notCheckable = 1, func = function() frame:SetFrameStrata("LOW") if frame.title then frame.title:SetFrameStrata("LOW") end end },
			{
				text = "Frame Color    ",
				notCheckable = 1,
				func = function(...)
--					print("function",...)
				end,

				swatchFunc = function(...)
					local f = UIDROPDOWNMENU_MENU_VALUE
					local r,g,b = ColorPickerFrame:GetColorRGB()

					f.config.r, f.config.g, f.config.b = r,g,b

					if f.title then
						f.title.textureLeft:SetVertexColor(r,g,b)
						f.title.textureCenter:SetVertexColor(r,g,b)
						f.title.textureRight:SetVertexColor(r,g,b)
					end

					SetBetterBackdropColor(f, r,g,b)
				end,

				opacityFunc = function(...)
					local f = UIDROPDOWNMENU_MENU_VALUE
					local opacity = 1-OpacitySliderFrame:GetValue()

					f.config.opacity = opacity

					f:SetAlpha(math.max(.1,opacity))

					if f.title then
						f.title:SetAlpha(math.max(.1,opacity))
					end
				end,

				cancelFunc = function(...)
					local previousValues = ...

					local f = UIDROPDOWNMENU_MENU_VALUE
					local r,g,b = previousValues.r, previousValues.g, previousValues.b

					f.config.r, f.config.g, f.config.b = r,g,b

					if f.title then
						f.title.textureLeft:SetVertexColor(r,g,b)
						f.title.textureCenter:SetVertexColor(r,g,b)
						f.title.textureRight:SetVertexColor(r,g,b)
					end

					SetBetterBackdropColor(f, r,g,b)


					local opacity = 1-previousValues.opacity

					f.config.opacity = opacity

					f:SetAlpha(math.max(.1,opacity))

					if f.title then
						f.title:SetAlpha(math.max(.1,opacity))
					end
				end,

				hasColorSwatch = true,
				hasOpacity = 1,
			},
		}
--[[
info.r = [1 - 255]  --  Red color value of the color swatch
info.g = [1 - 255]  --  Green color value of the color swatch
info.b = [1 - 255]  --  Blue color value of the color swatch
info.colorCode = [STRING] -- "|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
info.swatchFunc = [function()]  --  Function called by the color picker on color change
info.hasOpacity = [nil, 1]  --  Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0]  --  Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
info.cancelFunc
]]
		local windowMenuFrame = CreateFrame("Frame", "GWWindowMenuFrame", getglobal("UIParent"), "UIDropDownMenuTemplate")


		local mover = CreateFrame("Frame",frameName.."Mover",frame)
		mover:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
		mover:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)

		mover:EnableMouse(true)

		mover:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				if not frame.dockParent or not frame.dockParent:IsShown() then
					frame:StartMoving()
				end
			else
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				local entry = windowMenu[3]

				local f = frame


				entry.r,entry.g,entry.b = f.config.r or 255, f.config.g or 255, f.config.b or 255

				entry.opacity = f.config.opacity or 1

				entry.value = f

				EasyMenu(windowMenu, windowMenuFrame, getglobal("UIParent"), x/uiScale,y/uiScale, "MENU", 5)
			end
		end)

		mover:SetScript("OnMouseUp", function()
			if not frame.dockParent or not frame.dockParent:IsShown() then
				frame:StopMovingOrSizing()
				frame:SavePosition()
			end
		end)

		mover:SetScript("OnHide", function()
			if not frame.dockParent or not frame.dockParent:IsShown() then
				frame:StopMovingOrSizing()
				frame:SavePosition()
			end
		end)



		mover:SetHitRectInsets(15,15,15,15)

		frame.mover = mover



		if windowTitle then
			local title = CreateFrame("Button",nil,UIParent)

			local titleSize = 20

			title:SetHeight(titleSize)

			title.textureLeft = title:CreateTexture(nil, "BORDER")
			title.textureLeft:SetTexture("Interface\\AddOns\\GnomeWorks\\Art\\headerTexture.tga")
			title.textureLeft:SetPoint("LEFT",0,0)
			title.textureLeft:SetWidth(titleSize*2)
			title.textureLeft:SetHeight(titleSize)
			title.textureLeft:SetTexCoord(0, 1, 0, .5)

			title.textureRight = title:CreateTexture(nil, "BORDER")
			title.textureRight:SetTexture("Interface\\AddOns\\GnomeWorks\\Art\\headerTexture.tga")
			title.textureRight:SetPoint("RIGHT",0,0)
			title.textureRight:SetWidth(titleSize*2)
			title.textureRight:SetHeight(titleSize)
			title.textureRight:SetTexCoord(0, 1.0, 0.5, 1.0)


			title.textureCenter = title:CreateTexture(nil, "BORDER")
			title.textureCenter:SetTexture("Interface\\AddOns\\GnomeWorks\\Art\\headerTextureCenter.tga", true)
			title.textureCenter:SetHeight(titleSize)
	--		title.textureCenter:SetWidth(30)
			title.textureCenter:SetPoint("LEFT",titleSize*2,0)
			title.textureCenter:SetPoint("RIGHT",-titleSize*2,0)
			title.textureCenter:SetTexCoord(0.0, 1.0, 0.0, 1.0)


			title.textureLeft:SetVertexColor(r,g,b)
			title.textureCenter:SetVertexColor(r,g,b)
			title.textureRight:SetVertexColor(r,g,b)

			title:SetAlpha(math.max(.1,opacity))

			title:SetPoint("BOTTOM",frame,"TOP",0,0)

			title:EnableMouse(true)

			title:Hide()


--			title:SetFrameStrata("DIALOG")

			title:SetScript("OnDoubleClick", function(self, button)
				if button == "LeftButton" then
					PlaySound("igMainMenuOptionCheckBoxOn")
					if frame:IsVisible() then
						frame:Hide()
					else
						frame:Show()
					end
				end
			end)

			title:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					frame:StartMoving()
				else
					local x, y = GetCursorPosition()
					local uiScale = UIParent:GetEffectiveScale()
					local entry = windowMenu[3]
					local f = frame

					entry.r,entry.g,entry.b = f.config.r or 255, f.config.g or 255, f.config.b or 255

					entry.opacity = f.config.opacity or 1

					entry.value = f

					EasyMenu(windowMenu, windowMenuFrame, getglobal("UIParent"), x/uiScale,y/uiScale, "MENU", 5)
				end
			end)
			title:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() frame:SavePosition() end)
			title:SetScript("OnHide", function() frame:StopMovingOrSizing() frame:SavePosition() end)




			local text = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			text:SetJustifyH("CENTER")
			text:SetPoint("CENTER",0,0)
			text:SetTextColor(1,1,.4)
			text:SetText(windowTitle)

			title.text = text
			title:SetWidth(text:GetStringWidth()+titleSize*4)


			local w = title.textureCenter:GetWidth()
			local h = title.textureCenter:GetHeight()
			title.textureCenter:SetTexCoord(0.0, (w/h), 0.0, 1.0)




			local updateTimer = 0

			title:SetScript("OnUpdate", function(f,elapsed)
				updateTimer = updateTimer + elapsed

				if updateTimer > 1 then
					if frame:GetFrameLevel() > (frame.highLevel or 0) then
						frame.highLevel = frame:GetFrameLevel()
					end

					f.text:SetText(windowTitle.." "..frame:GetFrameLevel().."/"..frame.highLevel)
					updateTimer = 0
				end
			end)


			title:SetToplevel(true)

			frame.title = title
		end

		frame:SetToplevel(true)

--[[
		local x = frame:CreateTexture(nil,"ARTWORK")

		x:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
		x:SetTexture("Interface/DialogFrame/UI-DialogBox-Corner")
		x:SetWidth(32)
		x:SetHeight(32)
]]

		local closeButton = CreateFrame("Button",nil,frame,"UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT",5,5)
		closeButton:SetScript("OnClick", function() frame:Hide() if frame.title then frame.title:Hide() end end)
		closeButton:SetFrameLevel(closeButton:GetFrameLevel()+1)
		closeButton:SetHitRectInsets(8,8,8,8)



		frame.DockWindow = DockWindow


		frame.SetBetterBackDrop = SetBetterBackDrop
		frame.SetBetterBackDropColor = SetBetterBackDropColor


		return frame
	end

	function Window:SetBetterBackdrop(...)
		SetBetterBackdrop(...)
	end

	function Window:SetBetterBackdropColor(...)
		SetBetterBackdropColor(...)
	end

	GnomeWorks.Window = Window



	local buttonTextureNames = {"Highlight", "Disabled", "Up", "Down"}

	function GnomeWorks:CreateButton(parent, height, template, name)
		local newButton = CreateFrame("Button", name, parent, template)
		newButton:SetHeight(height)
		newButton:SetWidth(50)
		newButton:SetPoint("CENTER")

		newButton.state = {}

		for k,state in pairs(buttonTextureNames) do
			local f = CreateFrame("Frame",nil,newButton)
			f:SetAllPoints()

			if state ~= "Highlight" then
				f:SetFrameLevel(f:GetFrameLevel()-1)
			end

			local leftTexture = f:CreateTexture(nil,"BACKGROUND")
			local rightTexture = f:CreateTexture(nil,"BACKGROUND")
			local middleTexture = f:CreateTexture(nil,"BACKGROUND")

			leftTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..state)
			rightTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..state)
			middleTexture:SetTexture("Interface\\Buttons\\UI-Panel-Button-"..state)

			leftTexture:SetTexCoord(0,.25*.625, 0,.6875)
			rightTexture:SetTexCoord(.75*.625,1*.625, 0,.6875)
			middleTexture:SetTexCoord(.25*.625,.75*.625, 0,.6875)

			leftTexture:SetPoint("LEFT")
			leftTexture:SetWidth(height)
			leftTexture:SetHeight(height)

			rightTexture:SetPoint("RIGHT")
			rightTexture:SetWidth(height)
			rightTexture:SetHeight(height)

			middleTexture:SetPoint("LEFT", height, 0)
			middleTexture:SetPoint("RIGHT", -height, 0)
			middleTexture:SetHeight(height)

			if state == "Highlight" then
				leftTexture:SetBlendMode("ADD")
				rightTexture:SetBlendMode("ADD")
				middleTexture:SetBlendMode("ADD")
			end

--				middleTexture:Hide()

			newButton.state[state] = f

			if state ~= "Up" then
				f:Hide()
			end
		end

		newButton.origDisable = newButton.Disable
		newButton.origEnable = newButton.Enable

		newButton.Disable = function(b)
			b.state.Up:Hide()
			b.state.Disabled:Show()
			if not InCombatLockdown() then
				b:origDisable()
			end
		end

		newButton.Enable = function(b)
			b.state.Up:Show()
			b.state.Disabled:Hide()
			if not InCombatLockdown() then
				b:origEnable()
			end
		end


		newButton:HookScript("OnEnter", function(b) b.state.Highlight:Show() end)
		newButton:HookScript("OnLeave", function(b) b.state.Highlight:Hide() end)

		newButton:HookScript("OnMouseDown", function(b) if b:IsEnabled() then b.state.Down:Show() b.state.Up:Hide() end end)
		newButton:HookScript("OnMouseUp", function(b) if b:IsEnabled() then b.state.Down:Hide() b.state.Up:Show() end end)

		return newButton
	end
end
