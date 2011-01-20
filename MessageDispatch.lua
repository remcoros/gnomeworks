



local GnomeWorks = GnomeWorks




-- message dispatch
do
	local dispatchIndex = {}
	local timingTable = {}
	local dispatchTable = {}
	local currentProcess

	local unregisteredEnvironments = {}


	local frame


	function GnomeWorks:RegisterMessageDispatch(messageList, func, name)
		for message in string.gmatch(messageList, "%a+") do
			if not dispatchTable[message] then
				dispatchTable[message] = {}

				timingTable[#timingTable+1] = { name = message, iterations=0, elapsed=0, index = #timingTable+1, maxTime = 0, subGroup = { entries = dispatchTable[message], expanded = false} }
				dispatchIndex[message] = #timingTable
			end

			local t = dispatchTable[message]
			local alreadyAdded

			for i=1,#t do
				if t[i].func == func then
					alreadyAdded = true
					break
				end
			end

			if not alreadyAdded then
				local newEntry = {
					func = func,
					name = name,
					iterations=0,
					elapsed=0,
					index = #t+1,
					maxTime = 0
				}

				t[#t+1] = newEntry
			end
		end

		if frame and frame:IsVisible() then
			frame.sf:Refresh()
		end
	end


	function GnomeWorks:SendMessageDispatch(messageList)
		for message in string.gmatch(messageList, "%a+") do
			if dispatchTable[message] then
				t = dispatchTable[message]
				local times = timingTable[dispatchIndex[message]]

				local timeStart = GetTime()

				local hooks = 0

				for k,entry in ipairs(t) do
					if entry ~= "delete" then
						hooks = hooks + 1

						local entryTimeStart = GetTime()

						if type(entry.func) == "function" and entry.func() then					-- message returns true when it's set to fire once
							t[k] = "delete"
						elseif type(entry.func) == "string" and GnomeWorks[entry.func](GnomeWorks) then
							t[k] = "delete"
						end

						local elapsed = (GetTime()-entryTimeStart)

						entry.elapsed = entry.elapsed + elapsed
						entry.iterations = entry.iterations + 1
						entry.last = elapsed

						if elapsed > entry.maxTime then
							entry.maxTime = elapsed
						end

					end
				end

				times.listeners = hooks
				times.iterations = times.iterations + hooks

				local elapsed = (GetTime() - timeStart)

				if elapsed > times.maxTime then
					times.maxTime = elapsed
				end

				times.last = elapsed

				times.elapsed = times.elapsed + elapsed

				local s,e = 1,#t

				while s <= e do
					if t[s] == "delete" then
						t[s] = t[e]
						t[e] = nil
						e = e - 1
					else
						s = s + 1
					end
				end
			else
				local env = getfenv(1)

				if not unregisteredEnvironments[env] then
--					GnomeWorks:warning(message,"unregistered message sent from",env)
					unregisteredEnvironments = env
				end
			end
		end

		if frame and frame:IsVisible() then
			frame.sf:Refresh()
		end
	end



	local function CreateDebugFrame()
		local columnHeaders = {
			{
				font = "GameFontHighlight",
				button = {
					normalTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
					highlightTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
					width = 14,
					height = 14,
				},
				align = "LEFT",
				name = "event",
				width = 90,
				dataField = "name",
				draw =	function (rowFrame,cellFrame,entry)
							cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8+4+12, 0)

							if entry.subGroup then
								if entry.subGroup.expanded then
									cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
									cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
								else
									cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
									cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
								end

								cellFrame.text:SetText(entry.name or tostring(entry.func))
								cellFrame.button:Show()

								rowFrame:SetAlpha(1)
							else
								cellFrame.text:SetText(entry.name or tostring(entry.func))
								cellFrame.button:Hide()

								rowFrame:SetAlpha(.5)
							end
						end,
				OnClick = function (cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()
							local entry = rowFrame.data


							if rowFrame.rowIndex > 0 then
								if source == "button" then
									entry.subGroup.expanded = not entry.subGroup.expanded
									cellFrame.scrollFrame:Refresh()
								else
									if entry.subGroup then
										GnomeWorks:SendMessageDispatch(entry.name)
									else
										local entryTimeStart = GetTime()

										entry.func()

										local elapsed = (GetTime()-entryTimeStart)

										entry.elapsed = entry.elapsed + elapsed
										entry.iterations = entry.iterations + 1
										entry.last = elapsed

										if elapsed > entry.maxTime then
											entry.maxTime = elapsed
										end

										cellFrame.scrollFrame:Draw()
									end
								end
							else
								if source == "button" then
									cellFrame.collapsed = not cellFrame.collapsed

									if not cellFrame.collapsed then
										GnomeWorks:CollapseAllHeaders(cellFrame.scrollFrame.data.entries)
										cellFrame.scrollFrame:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
									else
										GnomeWorks:ExpandAllHeaders(cellFrame.scrollFrame.data.entries)
										cellFrame.scrollFrame:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
									end
								end
							end
						end,
			},
--[[
			{
				name = "hooks",
				align = "CENTER",
				width = 60,
				dataField = "listeners",
			},
]]
			{
				name = "count",
				align = "CENTER",
				width = 60,
				dataField = "iterations",
				OnClick = function (cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()

							if rowFrame.rowIndex > 0 then
								local entry = rowFrame.data

								entry.iterations = 0

								cellFrame.scrollFrame:Draw()
							end
						end,
			},
			{
				name = "elapsed",
				align = "CENTER",
				width = 60,
				dataField = "elapsed",
				precision = 100,
				OnClick = function (cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()

							if rowFrame.rowIndex > 0 then
								local entry = rowFrame.data

								entry.elapsed = 0

								cellFrame.scrollFrame:Draw()
							end
						end,
			},
			{
				name = "per",
				align = "CENTER",
				width = 60,
				dataField = "elapsedPerIteration",
				precision = 100,
			},
			{
				name = "max",
				align = "CENTER",
				width = 60,
				dataField = "maxTime",
				precision = 100,
				OnClick = function (cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()

							if rowFrame.rowIndex > 0 then
								local entry = rowFrame.data

								entry.maxTime = 0

								cellFrame.scrollFrame:Draw()
							end
						end,
			},
			{
				name = "last",
				align = "CENTER",
				width = 60,
				dataField = "last",
				precision = 100,
			},
	--
		}


		local function ResizeFrame(scrollFrame,width,height)

			if scrollFrame then
				scrollFrame.columnWidth[1] = scrollFrame.columnWidth[1] + width - scrollFrame.headerWidth
				scrollFrame.headerWidth = width

				local x = 0

				for i=1,#scrollFrame.columnFrames do
					scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
					scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+scrollFrame.columnWidth[i],0)

					x = x + scrollFrame.columnWidth[i]
				end
			end
		end


		local ScrollPaneBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 9.5, right = 9.5, top = 9.5, bottom = 11.5 }
			}



		frame = GnomeWorks.Window:CreateResizableWindow("GnomeWorksMessageTimerFrame", "Dispatch Times", 500, 300, ResizeWindow, GnomeWorksDB.config)


		local subFrame = CreateFrame("Frame", nil, frame)

		subFrame:SetPoint("TOPLEFT",20,-30)
		subFrame:SetPoint("BOTTOMRIGHT",-20,20)

		local sf = GnomeWorks:CreateScrollingTable(subFrame, ScrollPaneBackdrop, columnHeaders, ResizeFrame)


		sf.IsEntryFiltered = function(self, entry)
			return false
		end


		local function UpdateRowData(scrollFrame,entry)
			if entry.iterations>0 then
				entry.elapsedPerIteration = entry.elapsed / entry.iterations
			else
				entry.elapsedPerIteration = 0
			end
		end

		sf:RegisterRowUpdate(UpdateRowData)


		sf.data = { entries = timingTable }

		frame.sf = sf

	end



	function GnomeWorks:MessageDispatchTimeReportToggle()
		if not frame then
			CreateDebugFrame()

			frame:Show()
			frame.title:Show()

			frame.sf:Refresh()
		else
			if frame:IsVisible() then
				frame:Hide()
				frame.title:Hide()
			else
				frame:Show()
				frame.title:Show()

				frame.sf:Refresh()
			end
		end
	end
end
