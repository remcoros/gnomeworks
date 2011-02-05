


local libScrollKit = {}



-- shell sort function
-- Written by Rici Lake. The author disclaims all copyright and offers no warranty.
--
-- This module returns a single function (not a table) whose interface is upwards-
-- compatible with the interface to table.sort:
--
-- array = shellsort(array, before, n)
-- array is an array of comparable elements to be sorted in place
-- before is a function of two arguments which returns true if its first argument
--    should be before the second argument in the second result. It must define
--    a total order on the elements of array.
--      Alternatively, before can be one of the strings "<" or ">", in which case
--    the comparison will be done with the indicated operator.
--    If before is omitted, the default value is "<"
-- n is the number of elements in the array. If it is omitted, #array will be used.
-- For convenience, shellsort returns its first argument.


local shellsort do
  local incs = { 1391376,
                 463792, 198768, 86961, 33936,
                 13776, 4592, 1968, 861, 336,
                 112, 48, 21, 7, 3, 1 }

  local function ssup(t, n)
    for _, h in ipairs(incs) do
      for i = h + 1, n do
        local v = t[i]
        for j = i - h, 1, -h do
          local testval = t[j]
          if not (v < testval) then break end
          t[i] = testval; i = j
        end
        t[i] = v
      end
    end
    return t
  end

  local function ssdown(t, n)
    for _, h in ipairs(incs) do
      for i = h + 1, n do
        local v = t[i]
        for j = i - h, 1, -h do
          local testval = t[j]
          if not (v > testval) then break end
          t[i] = testval; i = j
        end
        t[i] = v
      end
    end
    return t
  end

  local function ssgeneral(t, n, before)
    for _, h in ipairs(incs) do
      for i = h + 1, n do
        local v = t[i]
        for j = i - h, 1, -h do
          local testval = t[j]
          if not before(v, testval) then break end
          t[i] = testval; i = j
        end
        t[i] = v
      end
    end
    return t
  end

  function shellsort(t, before, n)
    n = n or #t
    if not before or before == "<" then return ssup(t, n)
    elseif before == ">" then return ssdown(t, n)
    else return ssgeneral(t, n, before)
    end
  end
end


do
	local serial = 0

	local lib = libScrollKit

-- the following functions are designed to be filled in by the user:
	local function InitColumns(scrollFrame, rowFrame)
	end

	local function DrawColumns(scrollFrame, rowFrame, rowData)
	end

	local function IsEntryFiltered(scrollFrame)
		return false
	end

-- standard api functions:
	local function RowFrameOnEnter(rowFrame)
		local scrollFrame = rowFrame.scrollFrame

		scrollFrame.mouseOverIndex = rowFrame.rowIndex

		if rowFrame.rowIndex > 0 and scrollFrame.selectable then
			if IsShiftKeyDown() and scrollFrame.firstSelection and IsMouseButtonDown() then
				local index = rowFrame.rowIndex + (scrollFrame.scrollOffset or 0)

				table.wipe(scrollFrame.selection)

				if scrollFrame.firstSelection < index then
					for i=scrollFrame.firstSelection,index do
						scrollFrame.selection[scrollFrame.dataMap[i]] = true
					end
				else
					for i=index,scrollFrame.firstSelection do
						scrollFrame.selection[scrollFrame.dataMap[i]] = true
					end
				end

				if scrollFrame.DrawRowHighlight then
					for i=1,scrollFrame.numRows do
						scrollFrame:DrawRowHighlight(scrollFrame.rowFrame[i])
					end
				end

				scrollFrame.lastSelection = index
			else
				if scrollFrame.DrawRowHighlight then
					scrollFrame:DrawRowHighlight(rowFrame)
				end
			end
		else
			if scrollFrame.DrawRowHighlight then
				scrollFrame:DrawRowHighlight(rowFrame)
			end
		end
	end

	local function RowFrameOnLeave(rowFrame)
		local scrollFrame = rowFrame.scrollFrame

		scrollFrame.mouseOverIndex = nil

		if scrollFrame.DrawRowHighlight then
			scrollFrame:DrawRowHighlight(rowFrame)
		end
	end

	local function RowFrameOnClick(rowFrame, ...)
		local scrollFrame = rowFrame.scrollFrame

		if rowFrame.rowIndex > 0 and scrollFrame.selectable then
			local index = rowFrame.rowIndex + (scrollFrame.scrollOffset or 0)
			local dataIndex = scrollFrame.dataMap[index]

			if IsControlKeyDown() then
				scrollFrame.selection[dataIndex] = (scrollFrame.selection[dataIndex] == nil) or nil
			else
				if not scrollFrame.selection[dataIndex] and not IsShiftKeyDown() then
					table.wipe(scrollFrame.selection)
				end
			end

			if not IsShiftKeyDown() or not scrollFrame.firstSelection then
				scrollFrame.firstSelection = index
			else
				table.wipe(scrollFrame.selection)

				if scrollFrame.firstSelection < index then
					for i=scrollFrame.firstSelection,index do
						scrollFrame.selection[scrollFrame.dataMap[i]] = true
					end
				else
					for i=index,scrollFrame.firstSelection do
						scrollFrame.selection[scrollFrame.dataMap[i]] = true
					end
				end
			end

			scrollFrame.selection[dataIndex] = true

			for i=1,scrollFrame.numRows do
				scrollFrame:DrawRowHighlight(scrollFrame.rowFrame[i])
			end
		end
	end


	local function InitRow(scrollFrame, rowIndex)
		if not scrollFrame.rowFrame[rowIndex] then
			local parent = (rowIndex == 0 and scrollFrame) or scrollFrame.scrollChild

			scrollFrame.rowFrame[rowIndex] = CreateFrame("Frame",nil,parent)

			rowFrame = scrollFrame.rowFrame[rowIndex]

			rowFrame:SetPoint("TOPLEFT",scrollFrame,"TOPLEFT",0,-(rowIndex-1)*scrollFrame.rowHeight)
			rowFrame:SetPoint("BOTTOMRIGHT",scrollFrame,"TOPRIGHT",0,-(rowIndex)*scrollFrame.rowHeight)

--			rowFrame:SetFrameLevel(rowFrame:GetFrameLevel()+10)

			rowFrame.rowIndex = rowIndex

			rowFrame.highlight = rowFrame:CreateTexture(nil, "OVERLAY")
			rowFrame.highlight:SetTexture(1,1,1,1)
			rowFrame.highlight:SetAllPoints(rowFrame)

			if rowIndex == 0 then
				rowFrame.highlight:Hide()
			end

--			rowFrame.highlight:SetVertexColor(.5,.5,.5, .15)
			rowFrame.highlight:SetVertexColor(.5,.5,.5, 0)

			scrollFrame:InitColumns(rowFrame)

			rowFrame.scrollFrame = scrollFrame

			rowFrame.OnClick = RowFrameOnClick
			rowFrame.OnEnter = RowFrameOnEnter
			rowFrame.OnLeave = RowFrameOnLeave
		end

		return scrollFrame.rowFrame[rowIndex]
	end

	local function DrawRow(scrollFrame, rowIndex)
		if scrollFrame.InitRow then
			local rowFrame = scrollFrame.rowFrame[rowIndex] or scrollFrame:InitRow(rowIndex)

			rowFrame:Show()

			rowIndex = rowIndex + scrollFrame.scrollOffset

			if rowIndex <= scrollFrame.numData then
				if scrollFrame.DrawRowHighlight then
					scrollFrame:DrawRowHighlight(rowFrame, scrollFrame.dataMap[rowIndex])
				end

				scrollFrame:DrawColumns(rowFrame, scrollFrame.dataMap[rowIndex])
			else
				rowFrame:Hide()
			end
		end
	end


	local function Draw(scrollFrame)
		local DrawRow = scrollFrame.DrawRow

		if not scrollFrame:IsVisible() then
			return
		end

		scrollFrame.numRows = math.floor(scrollFrame:GetHeight()/scrollFrame.rowHeight)

		if scrollFrame.numRows < scrollFrame.numData then
			local maxValue = math.floor((scrollFrame.numData+1) * scrollFrame.rowHeight - scrollFrame:GetHeight()+.5)

			scrollFrame.scrollBar:Show()
			scrollFrame:SetPoint("RIGHT",scrollFrame:GetParent(),-18,0)
			scrollFrame.scrollBar:SetMinMaxValues(0, maxValue)
			scrollFrame.scrollBar:SetValueStep(1) --scrollFrame.rowHeight)

			local scrollUpButton = scrollFrame.scrollUpButton
			local scrollDownButton = scrollFrame.scrollDownButton

			-- Arrow button handling

			if ( scrollFrame.scrollBar:GetValue() == 0 ) then
				scrollUpButton:Disable();
			else
				scrollUpButton:Enable();
			end
			if ((scrollFrame.scrollBar:GetValue() - maxValue) == 0) then
				scrollDownButton:Disable();
			else
				scrollDownButton:Enable();
			end
		else
			scrollFrame.scrollBar:SetMinMaxValues(0, 0)
			scrollFrame.scrollBar:SetValue(0)

			scrollFrame:SetPoint("RIGHT",scrollFrame:GetParent(),0,0)
			scrollFrame.scrollBar:Hide()
		end

		if DrawRow then
			for i=0,scrollFrame.numRows+2 do
				DrawRow(scrollFrame, i)
			end

			if scrollFrame.numRows+2 < #scrollFrame.rowFrame then
				for i=scrollFrame.numRows+2,#scrollFrame.rowFrame do
					scrollFrame.rowFrame[i]:Hide()
				end
			end
		else
			print("draw row is not set!")
		end
	end




	local function SortCompare(scrollFrame, a,b)
		while a.subGroup and #a.subGroup.entries>1 do
			a = a.subGroup.entries[1]
		end

		while b.subGroup and #b.subGroup.entries>1 do
			b = b.subGroup.entries[1]
		end


		local result = scrollFrame.SortCompare(a,b)

		if result == 0 then
			result = a.index - b.index
		end

		if scrollFrame.sortInvert then
			result = -result
		end

		if result > 0 then return true end
		return false
	end


-- sorts and then counts the entries that aren't filtered out
	local function SortData(scrollFrame, data)

		if data and data.entries then
			local count = 0

			for i=1,data.numEntries or #data.entries do
				local entry = data.entries[i]


				if entry.subGroup then
					local subCount = SortData(scrollFrame, entry.subGroup)
					if subCount>0 or entry.noHide then
						count = count + subCount + 1
					end
				else
					if not scrollFrame:IsEntryFiltered(entry) then
						count = count + 1
					end
				end
			end

			if scrollFrame.SortCompare then
				if data.numEntries then
					shellsort(data.entries, function(a,b) return SortCompare(scrollFrame, a,b) end, data.numEntries)
				else
					table.sort(data.entries, function(a,b) return SortCompare(scrollFrame, a,b) end )
				end

			end

			data.numVisible = count

			return count
		end

		return 0
	end


	local function FilterData(scrollFrame, data, depth, index)
		local num = 0
		local map = scrollFrame.dataMap

		if data and data.entries and map then
			local numEntries = data.numEntries or #data.entries
			for i=1,numEntries do
				local entry = data.entries[i]
				entry.depth = depth

				if entry.subGroup then
					if ((entry.subGroup.numEntries or #entry.subGroup.entries) == 0 and entry.subGroup.manualEntry) or entry.subGroup.numVisible>0 then
						if scrollFrame.childrenFirst then
							if entry.subGroup.expanded then
								num = num + FilterData(scrollFrame, entry.subGroup, depth+1, num+index)
							end

							map[num+index] = entry
							entry.dataIndex = num+index

							num = num + 1
						else
							map[num+index] = entry
							entry.dataIndex = num+index

							num = num +1

							if entry.subGroup.expanded then
								num = num + FilterData(scrollFrame, entry.subGroup, depth+1, num+index)
							end
						end
					elseif entry.noHide then
						map[num+index] = entry
						entry.dataIndex = num+index

						num = num + 1
					end
				else
					if not scrollFrame:IsEntryFiltered(entry) then
						map[num+index] = entry
						entry.dataIndex = num+index

						num = num + 1
					end
				end
			end
		end
		return num
	end



	local function UpdateData(scrollFrame, data, depth, firstCall)
		if scrollFrame:IsVisible() and data and data.entries and depth < 3 then

			for i=1,data.numEntries or #data.entries do
				local entry = data.entries[i]

				entry.depth = depth

				if entry.subGroup then
					for name,reg in pairs(scrollFrame.rowUpdateRegistry) do
						if not reg.plugin or reg.plugin.enabled then
							reg.func(scrollFrame, entry, firstCall)
							firstCall = nil
						end
					end

					if entry.subGroup then
						UpdateData(scrollFrame, entry.subGroup, depth+1, firstCall)
					end
				else
					for name,reg in pairs(scrollFrame.rowUpdateRegistry) do
						if not reg.plugin or reg.plugin.enabled then
							reg.func(scrollFrame, entry, firstCall)
							firstCall = nil
						end
					end
				end
			end
		end
	end

	local function RefreshRows(scrollFrame)
		if #scrollFrame.rowUpdateRegistry>0 then
			scrollFrame:UpdateData(scrollFrame.data, 0, true)
		end

		scrollFrame:SortData(scrollFrame.data)

		scrollFrame.numData = scrollFrame:FilterData(scrollFrame.data, 0, 1)

		scrollFrame:Draw()
	end


	local function OnEnter(frame)
		local rowFrame = frame:GetParent()

		if frame.OnEnter then
			if not frame:OnEnter() then
				if rowFrame.OnEnter then
					rowFrame:OnEnter()
				end
			end
		else
			if rowFrame.OnEnter then
				rowFrame:OnEnter()
			end
		end


	end


	local function OnLeave(frame)
		local rowFrame = frame:GetParent()

		if frame.OnLeave then
			if not frame:OnLeave() then
				if rowFrame.OnLeave then
					rowFrame:OnLeave()
				end
			end
		else
			if rowFrame.OnLeave then
				rowFrame:OnLeave()
			end
		end
	end


	local function OnClick(frame, ...)
		local rowFrame = frame:GetParent()
		local scrollFrame = rowFrame:GetParent():GetParent()

		-- if frame has click function, the call it.  if it returns true, then don't call parent onclick (if it exists)
		if frame.OnClick then
			if not frame:OnClick(...) then
				if rowFrame.OnClick then
					rowFrame:OnClick(...)
				end
			end
		else
			if rowFrame.OnClick then
				rowFrame:OnClick(...)
			end
		end


	end


	local function SetHandlerScripts(scrollFrame, cellFrame)
		cellFrame:SetScript("OnClick", scrollFrame.OnClick)
		cellFrame:SetScript("OnEnter", scrollFrame.OnEnter)
		cellFrame:SetScript("OnLeave", scrollFrame.OnLeave)
--[[
		if cellFrame.button then
			cellFrame.button:SetScript("OnClick", function(frame, mouseButton) scrollFrame.OnClick(cellFrame, mouseButton, "button") end)
--			cellFrame.button:SetScript("OnEnter", function(frame, mouseButton) scrollFrame.OnEnter(cellFrame) end)
--			cellFrame.button:SetScript("OnLeave", function(frame, mouseButton) scrollFrame.OnLeave(cellFrame) end)
		end
]]
	end


	local function RegisterRowUpdate(scrollFrame, func, plugin)
		table.insert(scrollFrame.rowUpdateRegistry, { func = func, plugin = plugin })
	end



	local function ScrollFrameEventHandler(scrollFrame, event, ...)
		if event == "MODIFIER_STATE_CHANGED" and MouseIsOver(scrollFrame) then
			local key, state = ...

			if key == "LCTRL" or key == "RCTRL" then
				if state == 1 and scrollFrame.keyboardEnabled then
					scrollFrame:EnableKeyboard(scrollFrame.keyboardEnabled)
				else
					scrollFrame:EnableKeyboard(false)
				end
			end
		end
	end


	local function ScrollFrameKeyDispatch(scrollFrame, key)
		if scrollFrame.keyboardDispatch[key] then
			return scrollFrame.keyboardDispatch[key](scrollFrame,key)
		end
	end


	local function RegisterKeyboardInput(scrollFrame, key, func)
		scrollFrame.keyboardDispatch[key] = func
	end


	local function EnableKeyboardInput(scrollFrame)
		scrollFrame.keyboardEnabled = true

		scrollFrame:RegisterEvent("MODIFIER_STATE_CHANGED")

		scrollFrame:SetScript("OnKeyUp", ScrollFrameKeyDispatch)

		scrollFrame:EnableKeyboard(false)
	end



	function lib:Create(frame, rowHeight, recycle)
		local sf

		if recycle and recycle.scrollChild then
			sf = recycle
		else
			serial = serial + 1

			sf = CreateFrame("ScrollFrame", "ScrollFrame"..serial, frame) -- , "UIPanelScrollFrameTemplate")

			sf.scrollChild = CreateFrame("Frame", nil, sf)


			sf:SetScrollChild(sf.scrollChild)

			sf.scrollBar = CreateFrame("Slider", "ScrollFrame"..serial.."ScrollBar", sf)

			sf.scrollBar:SetWidth(16)

			sf.scrollBar:SetPoint("TOPRIGHT", frame, -1, -16)
			sf.scrollBar:SetPoint("BOTTOMRIGHT", frame, -1, 16)


			sf.scrollBar.background = sf.scrollBar:CreateTexture(nil,"BACKGROUND")
			sf.scrollBar.background:SetTexture(0.05,0.05,0.05,1.0)
			sf.scrollBar.background:SetWidth(16)
			sf.scrollBar.background:SetPoint("TOPRIGHT", frame, -1,-16)
			sf.scrollBar.background:SetPoint("BOTTOMRIGHT", frame, -1, 16)

			sf.scrollUpButton = CreateFrame("Button", nil, sf.scrollBar, "UIPanelScrollUpButtonTemplate")
			sf.scrollUpButton:SetPoint("TOP", 0, 15)
			sf.scrollUpButton:SetScript("OnClick", function(button)
				local parent = button:GetParent()
				local scrollStep = parent.scrollStep or (parent:GetHeight()/2)
				parent:SetValue(parent:GetValue() - scrollStep)
				PlaySound("UChatScrollButton")
			end)

			sf.scrollDownButton = CreateFrame("Button", nil, sf.scrollBar, "UIPanelScrollDownButtonTemplate")
			sf.scrollDownButton:SetPoint("BOTTOM", 0, -15)
			sf.scrollDownButton:SetScript("OnClick", function(button)
				local parent = button:GetParent()
				local scrollStep = parent.scrollStep or (parent:GetHeight()/2)
				parent:SetValue(parent:GetValue() + scrollStep)
				PlaySound("UChatScrollButton")
			end)


			local thumb = sf:CreateTexture()
			thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")

			thumb:SetWidth(18)
			thumb:SetHeight(24)

			thumb:SetTexCoord(.2, .8, .125, .875)


			sf.scrollBar:SetThumbTexture(thumb)


			sf.scrollBar:SetScript("OnValueChanged", function(f,v) sf:SetVerticalScroll(v) end)


			sf:SetScript("OnScrollRangeChanged", nil)

			sf:SetScript("OnLoad", ScrollFrame_OnLoad)

			sf:SetScript("OnMouseWheel", ScrollFrameTemplate_OnMouseWheel)


			sf:SetScript("OnEvent", ScrollFrameEventHandler)
		end


		sf:EnableKeyboard(false)


		sf:SetPoint("TOP")
		sf:SetPoint("LEFT")
		sf:SetPoint("RIGHT")
		sf:SetPoint("BOTTOM")

		sf.rowHeight = rowHeight
		sf.rowFrame = sf.rowFrame or {}

		sf.numRows = math.floor(frame:GetHeight()/rowHeight+1)

		sf.data = {}
		sf.dataMap = {}
		sf.numData = 0

		sf.scrollOffset = 0


		sf.rowUpdateRegistry = {}


		sf.RegisterRowUpdate = RegisterRowUpdate


		sf.Draw = Draw
		sf.DrawRow = DrawRow
		sf.InitRow = InitRow

		sf.InitColumns = InitColumns
		sf.DrawColumns = DrawColumns


		sf.UpdateData = UpdateData
		sf.FilterData = FilterData
		sf.SortData = SortData
		sf.SortCompare = nil
		sf.IsEntryFiltered = IsEntryFiltered

		sf.RefreshRows = RefreshRows

		sf.EnableKeyboardInput = EnableKeyboardInput
		sf.RegisterKeyboardInput = RegisterKeyboardInput


		sf.SetHandlerScripts = SetHandlerScripts

		sf.OnClick = OnClick
		sf.OnEnter = OnEnter
		sf.OnLeave = OnLeave


		sf.keyboardDispatch = {}

		sf.selection = {}
		sf.firstSelection = nil
		sf.lastSelection = nil

		sf:SetScript("OnSizeChanged", Draw)



		sf:SetScript("OnVerticalScroll", function(frame, value) frame.scrollOffset = math.floor(value/frame.rowHeight+.5) sf:Draw() end)





		return sf
	end
end



do
	local colorWhite = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 }
	local colorBlack = { ["r"] = 0.0, ["g"] = 1.0, ["b"] = 0.0, ["a"] = 0.0 }
	local colorDark = { ["r"] = 1.1, ["g"] = 0.1, ["b"] = 0.1, ["a"] = 0.0 }

	local highlightOff = {  0.0,  0.0,  0.0, 0.0 }

	local highlightSelected = { 1,1,.7, .35 }
	local highlightMouseOver = { .5,.5,.7, .35 }
	local highlightSelectedMouseOver = {  1,  1,  0.7, 0.2 }

	local menuFrame = GnomeWorksMenuFrame or CreateFrame("Frame", "GnomeWorksMenuFrame", UIParent, "UIDropDownMenuTemplate")


	local font = "GameFontHighlightSmall"


	function GnomeWorks:CollapseAllHeaders(entries)
		for i=1,#entries do
			if entries[i].subGroup then
				entries[i].subGroup.expanded = false
				GnomeWorks:CollapseAllHeaders(entries[i].subGroup.entries)
			end
		end
	end


	function GnomeWorks:ExpandAllHeaders(entries)
		for i=1,#entries do
			if entries[i].subGroup then
				entries[i].subGroup.expanded = true
				GnomeWorks:ExpandAllHeaders(entries[i].subGroup.entries)
			end
		end
	end

	local function ToggleColumnDisplay(menuEntry, column, scrollFrame)
		column.hidden = not column.hidden
		scrollFrame:Refresh()
	end

	local function SelectColumns(scrollFrame)
		local x, y = GetCursorPosition()
		local uiScale = UIParent:GetEffectiveScale()

		local cols = scrollFrame.columnMenu
		local headers = scrollFrame.columnHeaders

		for i = 1, #headers do
			cols[i].text = headers[i].name
			cols[i].checked = not headers[i].hidden
			local visible = not headers[i].enabled or (type(headers[i].enabled)=="function" and headers[i].enabled())
			cols[i].disabled = not visible
			cols[i].arg1 = headers[i]
			cols[i].arg2 = scrollFrame
			cols[i].func = ToggleColumnDisplay
		end

		EasyMenu(cols, menuFrame, UIParent, x/uiScale,y/uiScale, "MENU", 5)
	end


	local function CellFrameClearIcons(cellFrame)
		if cellFrame.iconList then
			for k,icon in ipairs(cellFrame.iconList) do
				icon:Hide()
			end
			cellFrame.iconCount = 0
		end
	end


	local function CellFrameAddIcon(cellFrame, iconTexture)
		if not cellFrame.iconList then
			cellFrame.iconList = {}
			cellFrame.iconCount = 0
		end

		cellFrame.iconCount = cellFrame.iconCount + 1

		local count = cellFrame.iconCount
		local list = cellFrame.iconList

		if not list[count] then
			local t = cellFrame:CreateTexture()
			local w = cellFrame:GetHeight()-2

			t:SetWidth(w)
			t:SetPoint("TOP", cellFrame, "TOP", 0,-1)
			t:SetPoint("BOTTOM", cellFrame, "BOTTOM", 0,1)
			t:SetPoint("RIGHT", cellFrame,"RIGHT", -w*(count-.5), 0)

			list[count] = t
		end

		list[count]:SetTexture(iconTexture)
		list[count]:Show()
	end



	function GnomeWorks:CreateScrollingTable(parentFrame, backDrop, columnHeaders, onResize)
--		local rows = floor((parentFrame:GetHeight() - 15) / 15)
--		local LibScrollingTable = LibStub("ScrollingTable")

--		local st = LibScrollingTable:CreateST(columnHeaders,rows,nil,nil,parentFrame)

		local lineHeight = GnomeWorksDB.config.scrollFrameLineHeight or 15

		local sf = libScrollKit:Create(parentFrame, lineHeight)

		if not self.scrollFrameList then
			self.scrollFrameList = {}
		end

		table.insert(self.scrollFrameList, sf)


		sf.columnHighlight = sf:CreateTexture(nil,"BACKGROUND")
		sf.columnHighlight:SetTexture("Interface\\Buttons\\BLUEGRAD64.blp")

		sf.columnHeaders = columnHeaders
		sf.columnWidth = {}
		sf.headerWidth = 0

		sf.columnFrames = {}

		sf.columnMenu = {}

		for i=1,#columnHeaders do
			sf.columnWidth[i] = sf.columnHeaders[i].width
			sf.columnMenu[i] = {}

			local c = CreateFrame("Frame",nil,sf)

			c:SetPoint("TOP")
			c:SetPoint("BOTTOM")
			c:SetPoint("LEFT", sf, "LEFT", sf.headerWidth, 0)
			c:SetPoint("RIGHT", sf, "LEFT", sf.headerWidth + sf.columnWidth[i],0)

			c:SetFrameLevel(c:GetFrameLevel()-1)

			self.Window:SetBetterBackdrop(c,backDrop)


			sf.columnFrames[i] = c

			sf.columnFrames[columnHeaders[i].name] = c


			sf.headerWidth = sf.headerWidth + sf.columnHeaders[i].width
		end


		sf.HighlightColumn = function(scrollFrame,index,invert)
			local t = scrollFrame.columnHighlight

			t:SetAllPoints(scrollFrame.columnFrames[index])
			t:Show()
			t:SetVertexColor(1,1,1,.075)

			if invert then
				t:SetTexCoord(0,1,1,0)
			else
				t:SetTexCoord(0,1,0,1)
			end
		end


		local function AdjustColumnWidths()
			sf.headerWidth = 0

			for i=1,#columnHeaders do
--				sf.columnWidth[i] = sf.columnHeaders[i].width
				local c = sf.columnFrames[i]

				c:SetPoint("LEFT", sf, "LEFT", sf.headerWidth, 0)
				c:SetPoint("RIGHT", sf, "LEFT", sf.headerWidth + sf.columnWidth[i],0)

				sf.headerWidth = sf.headerWidth + sf.columnWidth[i]
			end
		end



		sf.AddColumn = function(scrollFrame, header, plugin)
			local newIndex = #scrollFrame.columnHeaders+1

			local c = CreateFrame("Frame",nil,sf)

			c:SetPoint("TOP")
			c:SetPoint("BOTTOM")
			c:SetPoint("LEFT", sf, "LEFT", sf.headerWidth, 0)
			c:SetPoint("RIGHT", sf, "LEFT", sf.headerWidth + header.width,0)

			c:SetFrameLevel(c:GetFrameLevel()-1)

			self.Window:SetBetterBackdrop(c,backDrop)

			scrollFrame.columnFrames[newIndex] = c
			scrollFrame.columnFrames[header.name] = c

			scrollFrame.headerWidth = scrollFrame.headerWidth + header.width


			sf.columnMenu[newIndex] = {}
			scrollFrame.columnWidth[newIndex] = header.width
			scrollFrame.columnHeaders[newIndex] = header

			onResize(sf,sf:GetWidth(), sf:GetHeight())

			return header
		end


		local editBox = CreateFrame("EditBox", nil, UIParent)

		local function EditBoxSave(editBox)
			editBox.cellFrame.text:Show()
			editBox:Hide()

			editBox.callBack(editBox.cellFrame, editBox:GetText())
		end


		local function EditBoxExit(editBox)
			editBox.cellFrame.text:Show()
			editBox:Hide()
		end



		local function CellFrameEdit(cellFrame, text, callBack)
			editBox:SetParent(cellFrame)
			editBox:SetAllPoints(cellFrame.text)
			editBox:SetFontObject(cellFrame.scrollFrame.columnHeaders[cellFrame.index].font)
			editBox.callBack = callBack
			editBox.cellFrame = cellFrame
			editBox.entry = cellFrame:GetParent().data

			editBox:SetText(text)
			editBox:HighlightText()
			editBox:SetFocus()
			editBox:Show()
			cellFrame.text:Hide()
		end


		editBox:SetScript("OnTabPressed", EditBoxSave)
		editBox:SetScript("OnEnterPressed", EditBoxSave)
		editBox:SetScript("OnEscapePressed", function(f) f:ClearFocus() end)
		editBox:SetScript("OnEditFocusLost", EditBoxExit)
--		editBox:SetScript("OnEditFocusGained", function(f) f:HighlightText() end)

--		editBox:SetAutoFocus(false)

		editBox:SetFontObject("GameFontHighlightSmall")

		editBox:Hide()



		sf.InitColumns = function(scrollFrame, rowFrame)
			local width = rowFrame:GetWidth()
			local cols = rowFrame.cols
			local x = 0
			local headers = scrollFrame.columnHeaders

			local nameBase = scrollFrame:GetName().."-"..rowFrame.rowIndex.."x"

			if true or not cols or #cols ~= #headers then
				local rowHeight = scrollFrame.rowHeight

				if not rowFrame.cols then
					rowFrame.cols = {}
				end

				for i=1,#headers do
					if not rowFrame.cols[i] then
						local c = CreateFrame("Button", nameBase..i,rowFrame) -- nil, rowFrame)

						c.index = i
						c.scrollFrame = scrollFrame

						c:EnableMouse(true)
						c:RegisterForClicks("AnyUp")

						c:SetHeight(rowHeight)
						c:SetPoint("LEFT",scrollFrame.columnFrames[i])
						c:SetPoint("RIGHT",scrollFrame.columnFrames[i])
						c:SetPoint("TOP",rowFrame)


						if rowFrame.rowIndex == 0 then
							c.bg = c:CreateTexture(nil, "OVERLAY")
							c.bg:SetTexture(1,1,1,1)
							c.bg:SetVertexColor(1,1,1,1)
	--						c.bg:Show()
							c.bg:SetPoint("TOPLEFT",0,0)
							c.bg:SetPoint("BOTTOMRIGHT",0,0)


							c.text = c:CreateFontString(nil, "OVERLAY", font)
						else
							c.text = c:CreateFontString(nil, "OVERLAY", headers[i].font or font)
						end

						c.text:SetPoint("TOP",c)
						c.text:SetPoint("BOTTOM",c)
						c.text:SetPoint("LEFT", c)
						c.text:SetPoint("RIGHT", c, "RIGHT", -2,0)
						c.text:SetJustifyH((rowFrame.rowIndex==0 and headers[i].headerAlign) or headers[i].align or "LEFT")

						c.OnClick = function(frame,mb)
							local func = frame.scrollFrame.columnHeaders[frame.index].OnClick
							local now = GetTime()
							local last = frame.lastClick or 0

							if func
								then func(frame,mb,now-last)
							end

							frame.lastClick = now
						end

						c.OnEnter = function(frame,mb) local func = frame.scrollFrame.columnHeaders[frame.index].OnEnter if func then func(frame,mb) end end
						c.OnLeave = function(frame,mb) local func = frame.scrollFrame.columnHeaders[frame.index].OnLeave if func then func(frame,mb) end end


						c.Edit = CellFrameEdit


						c.ClearIcons = CellFrameClearIcons
						c.AddIcon = CellFrameAddIcon


						rowFrame.cols[i] = c

						c.header = headers[i]

						scrollFrame:SetHandlerScripts(c)
					end


					if headers[i].button and not rowFrame.cols[i].button then
						local c = rowFrame.cols[i]

						c.button = CreateFrame("button", nil, c)
						c.button:SetWidth(headers[i].button.width or 16)
						c.button:SetHeight(headers[i].button.height or 16)
						c.button:SetNormalTexture(headers[i].button.normalTexture)
						c.button:SetHighlightTexture(headers[i].button.highlightTexture)

						c.button:SetPoint("LEFT")

						if rowFrame.rowIndex == 0 then
							c.text:SetPoint("LEFT",c,"LEFT",16,0)
						end


						c.button:SetScript("OnClick", function(frame, mouseButton)
							c.scrollFrame.columnHeaders[c.index].OnClick(c, mouseButton, "button")
						end)

--						c.button:Hide()
					end
				end
			end
		end


		sf.DrawRowHighlight = function(scrollFrame, rowFrame, entry)
			if rowFrame.rowIndex == 0 then
				return
			end

			local dark
			local index = rowFrame.rowIndex + scrollFrame.scrollOffset
			local dataIndex = scrollFrame.dataMap[index]

			local mouseOver = highlightMouseOver


			entry = entry or rowFrame.data


			if scrollFrame.selection[dataIndex] then
				mouseOver = highlightSelectedMouseOver
			end



			if entry and entry == scrollFrame.selectedEntry then
				rowFrame.highlight:SetVertexColor(unpack(highlightSelected))
			elseif scrollFrame.mouseOverIndex == rowFrame.rowIndex then
				rowFrame.highlight:SetVertexColor(unpack(mouseOver))
			elseif scrollFrame.selection[dataIndex] then
				if math.floor(rowFrame.rowIndex/2)*2 == rowFrame.rowIndex then  -- alternating gradient lines
					rowFrame.highlight:SetVertexColor(.4,.6,.4,.18)
				else
					rowFrame.highlight:SetVertexColor(0.4,.6,.4,.13)
				end
			else
				if math.floor(rowFrame.rowIndex/2)*2 == rowFrame.rowIndex then  -- alternating gradient lines
					rowFrame.highlight:SetVertexColor(.5,.5,.5,.03)
				else
					rowFrame.highlight:SetVertexColor(0,0,0,0)
				end
			end
		end


		sf.Refresh = function(scrollFrame)
			local headers = scrollFrame.columnHeaders
			local visibleWidth = 0
			local frameWidth = scrollFrame:GetWidth()

			local resizingColumn = scrollFrame.resizingColumn or 2

			if resizingColumn > #scrollFrame.columnWidth then
				resizingColumn = #scrollFrame.columnWidth
			end

			for i=1,#headers do
				local visible = not headers[i].enabled or (type(headers[i].enabled)=="function" and headers[i].enabled())
				local width = scrollFrame.columnWidth[i]

				if visible and not headers[i].hidden then
					scrollFrame.columnFrames[i]:Show()
				else
					scrollFrame.columnFrames[i]:Hide()
					width = 0
				end

				visibleWidth = visibleWidth + width
			end

			scrollFrame.columnWidth[resizingColumn] = scrollFrame.columnWidth[resizingColumn] + frameWidth - visibleWidth
			scrollFrame.headerWidth = frameWidth


			local x = 0

			for i=1,#headers do
				local width = scrollFrame.columnFrames[i]:IsShown() and scrollFrame.columnWidth[i] or 0

				scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
				scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+width,0)

				x = x + width
			end

			scrollFrame:RefreshRows()
		end


		sf.DrawColumns = function(scrollFrame, rowFrame, rowData)
			scrollFrame:InitColumns(rowFrame)
			local headers = scrollFrame.columnHeaders

			rowFrame.data = rowData

			if editBox:IsVisible() and editBox.cellFrame then
				if editBox.cellFrame:GetParent().data ~= editBox.entry then
					editBox:ClearFocus()
					editBox:Hide()
					editBox.cellFrame.text:Show()
				end
			end


			for i=1,#rowFrame.cols do
				local columnFrame = scrollFrame.columnFrames[i]

				if columnFrame and columnFrame:IsShown() then

					rowFrame.cols[i].text:SetJustifyH((rowFrame.rowIndex==0 and headers[i].headerAlign) or headers[i].align or "LEFT")


					if rowFrame.rowIndex == 0 then
						if headers[i].button then
							rowFrame.cols[i].text:SetPoint("LEFT",rowFrame.cols[i],"LEFT",16,0)
						else
							rowFrame.cols[i].text:SetPoint("LEFT",rowFrame.cols[i],"LEFT",0,0)
						end

						rowFrame.cols[i].text:SetText(headers[i].name)

						if headers[i].headerColor then
							rowFrame.cols[i].text:SetTextColor(unpack(headers[i].headerColor))
						else
							rowFrame.cols[i].text:SetTextColor(1,1,1)
						end

						if headers[i].headerBgColor then
							rowFrame.cols[i].bg:SetVertexColor(unpack(headers[i].headerBgColor))
							rowFrame.cols[i].bg:Show()
						else
							rowFrame.cols[i].bg:Hide()
						end
					else
						if MouseIsOver(rowFrame.cols[i]) then
							scrollFrame.OnLeave(rowFrame.cols[i])
							scrollFrame.OnEnter(rowFrame.cols[i])
						end

						if headers[i].draw and rowData then
							headers[i].draw(rowFrame,rowFrame.cols[i],rowData)
						else
							local data = rowData and rowData[headers[i].dataField] or ""

							if type(data) == "number" and headers[i].precision then
								data = math.floor(data*headers[i].precision+.5)/headers[i].precision
							end

							rowFrame.cols[i].text:SetText(data)
						end
					end

					if not headers[i].button then
						if rowFrame.cols[i].button then
							rowFrame.cols[i].button:Hide()
						end
					end

					rowFrame.cols[i]:Show()
				else
					rowFrame.cols[i]:Hide()
				end
			end
		end

		sf:SetScript("OnSizeChanged", function(frame,...) onResize(frame,...) frame:Draw() end)

		onResize(sf,sf:GetWidth(), sf:GetHeight())

		sf:Refresh()



		sf.controlOverlay = CreateFrame("Frame",nil,sf)


		local c = sf.controlOverlay
		c:SetPoint("TOPLEFT")
		c:SetPoint("BOTTOMRIGHT")
		c:SetFrameLevel(c:GetFrameLevel()+5)

		c.header = CreateFrame("Button",nil,c)
		c.header:SetPoint("TOPLEFT",c,"TOPLEFT",0,lineHeight)
		c.header:SetPoint("BOTTOMRIGHT",c,"TOPRIGHT")

		local t = c.header:CreateTexture(nil,"OVERLAY")
		t:SetPoint("TOPLEFT")
		t:SetPoint("BOTTOMRIGHT")
		t:SetTexture(1,1,0,.75)

		local fs = c.header:CreateFontString(nil,"OVERLAY", "GameFontBlack")

		fs:SetPoint("TOPLEFT")
		fs:SetPoint("BOTTOMRIGHT")
		fs:SetJustifyH("CENTER")

		fs:SetText("Click to enable/disable columns")


		c.columnPlacement = {}
		c.columnEdges = {}

		c:EnableMouse(true)
		c.header:EnableMouse(true)
		c.header:RegisterForClicks("AnyUp")

		c:Hide()


		c.header:SetScript("OnClick", function(frame)
			SelectColumns(sf)
		end)


		c:SetScript("OnShow", function(frame)
			for i=1,#sf.columnHeaders do
				if not frame.columnPlacement[i] then
					local f = CreateFrame("Frame", nil, c)
					f:SetPoint("TOPLEFT",sf.columnFrames[i])
					f:SetPoint("BOTTOMRIGHT",sf.columnFrames[i])


					local t = f:CreateTexture(nil,"OVERLAY")
					t:SetTexture(1,1,0,1)
					t:SetPoint("TOPLEFT")
					t:SetPoint("BOTTOMRIGHT")

					f:SetAlpha(.05)

					f.tex = t

					frame.columnPlacement[i] = f

					f:EnableMouse(true)
					f:SetScript("OnEnter", function(colFrame)
						colFrame:SetAlpha(.20)
						frame.dragEnd = i
						frame.dragEndFrame = colFrame
					end)

					f:SetScript("OnLeave", function(colFrame)
						if colFrame ~= frame.dragStartFrame then
							colFrame:SetAlpha(.05)
						end
						frame.dragEnd = nil
						frame.dragEndFrame = nil
					end)

					f:SetScript("OnMouseDown", function(colFrame)
						frame.dragStart = i
						frame.dragStartFrame = colFrame
						colFrame.tex:SetTexture(.5,1,0,1)
					end)


					f:SetScript("OnMouseUp", function(colFrame)
						if frame.dragStartFrame then
							frame.dragStartFrame.tex:SetTexture(1,1,0,1)
							frame.dragStartFrame:SetAlpha(0.05)

							if frame.dragEndFrame then
								if frame.dragStart == frame.dragEnd then
									frame.dragStart = nil
									frame.dragStartFrame = nil
								else
		--							sf.columnHeaders[frame.dragStart].width, sf.columnHeaders[frame.dragEnd].width = sf.columnHeaders[frame.dragEnd].width, sf.columnHeaders[frame.dragStart].width

									local t = table.remove(sf.columnHeaders,frame.dragStart)
									table.insert(sf.columnHeaders,frame.dragEnd,t)

									table.insert(sf.columnWidth,frame.dragEnd,table.remove(sf.columnWidth,frame.dragStart))


									frame.dragStart = nil
									frame.dragStartFrame = nil

									sf:Refresh()
								end
							end
						end

					end)

				end
			end

			for i=1,#sf.columnHeaders-1 do
				if not frame.columnEdges[i] then
					local f = CreateFrame("Frame", nil, c)
					f:SetFrameLevel(f:GetFrameLevel()+5)
--					f:SetPoint("CENTER",sf.columnFrames[i],"RIGHT")
					f:SetPoint("TOP",sf.columnFrames[i],"TOPRIGHT")
					f:SetPoint("BOTTOM",sf.columnFrames[i],"BOTTOMRIGHT")

					f:SetWidth(16)
--					f:SetHeight(32)


					local t = f:CreateTexture(nil,"OVERLAY")
					t:SetTexture(0,1,1,1)
					t:SetPoint("TOPLEFT")
					t:SetPoint("BOTTOMRIGHT")

					f:SetAlpha(.05)


					frame.columnPlacement[i] = f

					f.index = i

					f:EnableMouse(true)
					f:SetScript("OnEnter", function(frame)
						frame:SetAlpha(.2)
					end)

					f:SetScript("OnLeave", function(frame)
						frame:SetAlpha(.05)
					end)


					f:SetScript("OnMouseDown", function(frame)
						sf.columnSizeStart = GetCursorPosition()
						sf.columnSizeIndex = frame.index
					end)


					f:SetScript("OnMouseUp", function(frame)
						sf.columnSizeStart = nil
					end)
				end
			end
		end)


		c:SetScript("OnUpdate", function(frame, elapsed)
			if sf.columnSizeStart then
				local stop = GetCursorPosition()

				local delta = (stop - sf.columnSizeStart) / frame:GetEffectiveScale()

				local index = sf.columnSizeIndex

				sf.columnWidth[index]= sf.columnWidth[index] + delta
				sf.columnWidth[index+1] = sf.columnWidth[index+1] - delta

				sf.columnSizeStart = stop


				AdjustColumnWidths()
			end
		end)

--[[
		sf:RegisterEvent("MODIFIER_STATE_CHANGED")

		sf:SetScript("OnEvent",function(frame, event, ...)
--		print(frame,event,...)
			if event == "MODIFIER_STATE_CHANGED" then
				local metaKey, pressed = ...

				if metaKey == "LALT" or metaKey == "RALT" then
					if pressed == 1 then
						sf.controlOverlay:Show()
					else
						sf.controlOverlay:Hide()
					end
				end
			end
		end)
]]

		return sf
	end


end
