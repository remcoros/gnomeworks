



local GnomeWorks = GnomeWorks




-- message dispatch
do
	local dispatchIndex = {}
	local timingTable = {}
	local dispatchTable = {}
	local currentProcess

	local unregisteredEnvironments = {}


	local frame


	function GnomeWorks:RegisterMessageDispatch(messageList, func, postProcess)
		for message in string.gmatch(messageList, "%a+") do
			if dispatchTable[message] then
				local t = dispatchTable[message]
				if postProcess then
					t[#t+1] = func
				else
					table.insert(t,1,func)
				end


			else
				dispatchTable[message] = { func }
				timingTable[#timingTable+1] = { name = message, iterations=0, elapsed=0, index = #timingTable+1, maxTime = 0 }
				dispatchIndex[message] = #timingTable
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

				for k,func in ipairs(t) do
					if func ~= "delete" then
						hooks = hooks + 1

						if type(func) == "function" and func() then					-- message returns true when it's set to fire once
							t[k] = "delete"
						elseif type(func) == "string" and GnomeWorks[func](GnomeWorks) then
							t[k] = "delete"
						end
					end
				end

				times.listeners = hooks
				times.iterations = times.iterations + hooks

				local elapsed = (GetTime() - timeStart)

				if elapsed > times.maxTime then
					times.maxTime = elapsed
				end


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
				align = "LEFT",
				name = "event",
				width = 90,
				dataField = "name",
				OnClick = function (cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()

							if rowFrame.rowIndex > 0 then
								local entry = rowFrame.data

								GnomeWorks:SendMessageDispatch(entry.name)
							end
						end,
			},
			{
				name = "hooks",
				align = "CENTER",
				width = 60,
				dataField = "listeners",
			},
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
