



local GnomeWorks = GnomeWorks





do
	local backDrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 10, right = 10, top = 10, bottom = 10 }
			}

	local detailFrame
	local height = 120
	local detailsWidth = 240

	local reagentFrame
	local sf


	local itemColorVendor = "|cff80ff80"
	local itemColorCrafted = "|cff40a0ff"
	local itemColorNormal = "|cffffffff"

--	local inventoryIndex = { "bag", "bank", "mail", "guildBank", "alt" }

--	local craftedInventoryIndex = { "craftedBag", "craftedBank", "craftedMail", "craftedGuildBank" }

--	local craftedInventoryBasis = { craftedBag = "bag", craftedBank = "bank", craftedMail = "mail", craftedGuildBank = "guildBank" }

	local inventoryColors = GnomeWorks.system.inventoryColors
	local inventoryFormat = GnomeWorks.system.inventoryFormat
	local inventoryTags = GnomeWorks.system.inventoryTags


	local tooltipScanner =  _G["GWParsingTooltip"] or CreateFrame("GameTooltip", "GWParsingTooltip", getglobal("ANCHOR_NONE"), "GameTooltipTemplate")

	tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")


	local tableMenuList = {}


	local function ReagentSourceColor(recipeID, reagentID)
		if GnomeWorksDB.preferredSource[reagentID] == recipeID then
			return "|cff00ff00"
		end

		if GnomeWorksDB.recipeBlackList[recipeID] then
			return "|cffff0000"
		end

		return "|cffffffff"
	end



	local function AdjustReagentSource(frame, recipeID, reagentID,...)
		reagentID = frame.arg2

		if not IsShiftKeyDown() then

			if GnomeWorksDB.preferredSource[reagentID] == recipeID then
				GnomeWorksDB.preferredSource[reagentID] = nil
			elseif GnomeWorksDB.preferredSource[reagentID] then
				for i=2, UIDROPDOWNMENU_MAXBUTTONS do
					local button = _G["DropDownList1Button"..i]

					if button.arg1 == GnomeWorksDB.preferredSource[reagentID] then
						GnomeWorksDB.preferredSource[reagentID] = recipeID
						local colorCode = ReagentSourceColor(button.arg1, reagentID)

						button:SetText(colorCode..GnomeWorks:GetRecipeName(button.arg1))
						break
					end
				end

				GnomeWorksDB.preferredSource[reagentID] = recipeID
			else
				GnomeWorksDB.preferredSource[reagentID] = recipeID
			end

			local colorCode = ReagentSourceColor(recipeID, reagentID)

			UIDropDownMenu_SetButtonText(1, frame.value, GnomeWorks:GetRecipeName(recipeID), colorCode)

		else
			GnomeWorksDB.recipeBlackList[recipeID] = not GnomeWorksDB.recipeBlackList[recipeID] or nil

			local results = GnomeWorks:GetRecipeData(recipeID)

			for itemID in pairs(results) do
				GnomeWorks:CraftabilityPurge(GnomeWorks.player, itemID)
			end

			local colorCode = ReagentSourceColor(recipeID, reagentID)

			UIDropDownMenu_SetButtonText(1, frame.value, GnomeWorks:GetRecipeName(recipeID), colorCode)
		end
	end


	local function GoToRecipe(frame, recipeID)
		CloseDropDownMenus()
		GnomeWorks:PushSelection()
		GnomeWorks:SelectRecipe(recipeID)
	end


	local function GenerateTableMenu(title, reagentID, data, clickFunc, colorFunc, shortCut, tipTitle, tipText)
		local button = tableMenuList[1] or {}

		button.text = title
--		button.isTitle = true
		button.notCheckable = true
		button.fontObject = "GameFontNormal"

		tableMenuList[1] = button

		local b = 2

		for recipeID,numMade in pairs(data) do
			if GnomeWorks:IsSpellKnown(recipeID) then
				local button = tableMenuList[b] or {}

				button.text = GnomeWorks:GetRecipeName(recipeID)
				button.func = clickFunc
				button.arg1 = recipeID
				button.arg2 = reagentID
				button.value = b
				button.notCheckable = true
				button.keepShownOnClick = true


				button.tooltipTitle = tipTitle
				button.tooltipText = tipText
				button.tooltipOnButton = true

				button.colorCode = colorFunc and colorFunc(recipeID,reagentID)

				tableMenuList[b] = button
				b = b + 1
			end
		end

		for i=b,#tableMenuList do
			tableMenuList[i] = nil
		end

		if #tableMenuList > 1 then
			if shortCut then
				clickFunc(GnomeWorksMenuFrame, tableMenuList[2].arg1, tableMenuList[2].arg2)
			else
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				EasyMenu(tableMenuList, GnomeWorksMenuFrame, UIParent, x/uiScale,y/uiScale, "MENU", 5)
			end
		end

--		tableMenuList[1].fontObject = nil
	end


	local function columnControl(cellFrame,button,source)
		local filterMenuFrame = GnomeWorksFilterMenuFrame
		local scrollFrame = cellFrame:GetParent():GetParent()

		if button == "RightButton" then
			if cellFrame.header.filterMenu then
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				EasyMenu(cellFrame.header.filterMenu, filterMenuFrame, UIParent, x/uiScale,y/uiScale, "MENU", 5)
			end
		else
			scrollFrame.sortInvert = (scrollFrame.SortCompare == cellFrame.header.sortCompare) and not scrollFrame.sortInvert

			scrollFrame:HighlightColumn(cellFrame.header.name, scrollFrame.sortInvert)
			scrollFrame.SortCompare = cellFrame.header.sortCompare
			scrollFrame:Refresh()
		end
	end


	local columnHeaders = {
		{
			name= "#",
			align = "CENTER",
			width = 25,
			sortCompare = function(a,b)
				return (a.numNeeded or 0) - (b.numNeeded or 0)
			end,
			dataField = "numNeeded",
			draw =	function (rowFrame,cellFrame,entry)
						cellFrame.text:SetText(entry.numNeeded)

						if entry.numNeeded <= entry.totalCraftable then
							cellFrame.text:SetTextColor(0,1,0)
						else
							cellFrame.text:SetTextColor(1,0,0)
						end
					end,
			OnEnter = 	function(cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("# Required",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
--								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								if entry and entry.id then
									GameTooltip:SetOwner(reagentFrame, "ANCHOR_RIGHT")
									GameTooltip:SetHyperlink("item:"..entry.id)
									GameTooltip:Show()
								end
							end
						end,
			OnLeave =	function()
							GameTooltip:Hide()
						end,
			OnClick = function(cellFrame, button, source)
				if cellFrame:GetParent().rowIndex==0 then
					columnControl(cellFrame, button, source)
				end
			end,
		}, -- [1]
		{
			name = "Reagent",
			sortCompare = function(a,b)
				return (a.index or 0) - (b.index or 0)
			end,
			width = 100,
			OnClick = function(cellFrame, button, source)
				if cellFrame:GetParent().rowIndex==0 then
					columnControl(cellFrame, button, source)
				else
					local entry = cellFrame:GetParent().data

					local itemSource = GnomeWorks.data.itemSource[entry.id]

					if itemSource then
						if button == "LeftButton" then
							GenerateTableMenu("Jump to Reagent Source",entry.id, itemSource, GoToRecipe, ReagentSourceColor, true)
						elseif button == "RightButton" then
							GenerateTableMenu("Adjust Reagent Source",entry.id, itemSource, AdjustReagentSource, ReagentSourceColor, false, "Adjust Recipe Parameters","click to select |cff00ff00preferred source|r\nshift-click to toggle |cffff0000blacklisted recipe|r")
						end
					end
				end
			end,
			OnEnter = 	function(cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Reagent",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
--								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								if entry and entry.id then
									GameTooltip:SetOwner(reagentFrame, "ANCHOR_RIGHT")
									GameTooltip:SetHyperlink("item:"..entry.id)
									GameTooltip:Show()
								end
							end
						end,
			OnLeave =	function()
							GameTooltip:Hide()
						end,
			draw =	function (rowFrame,cellFrame,entry)
						cellFrame.text:SetFormattedText(" |T%s:0|t %s%s", entry.icon or "",entry.color,entry.name or "item:"..(entry.itemID or "??"))
					end,
		}, -- [2]
		{
			name = "Craftable",
			width = 70,
			align = "CENTER",
			OnClick = function(cellFrame, button, source)
				if cellFrame:GetParent().rowIndex==0 then
					columnControl(cellFrame, button, source)
				end
			end,
			OnEnter =	function (cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Reagents Craftable",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
--								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								local shown = 0


								if entry  then
									GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
									GameTooltip:ClearLines()
									GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

									local itemID = entry.id

									local prev = 0
									local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

									local inventoryIndex = GnomeWorksDB.config.inventoryIndex
									local basis = GnomeWorks.system.inventoryBasis

									for i,key in pairs(inventoryIndex) do

										if entry.vendorItem and basis[key] and string.find(basis[key],"vendor") then
											GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key].."\226\136\158")
											shown = shown + 1
											break
										else
											if key ~= "vendor" and (key ~= "guildBank" or checkGuildBank) then
												local count = (entry[key] or 0) - prev
												prev = entry[key] or 0
	--print(key,count)
												if count > 0 then --prev ~= count and count ~= 0 then

													if  key == "alt" then
														GameTooltip:AddDoubleLine(inventoryTags[key], inventoryColors[key]..count)

														shown = shown + 1

														GameTooltip:AddLine("    ")

														GameTooltip:AddLine("alt item locations:",.8,.8,.8)
														for inventoryName, containers in pairs(GnomeWorks.data.inventoryData) do

															if inventoryName ~= UnitName("player") then

																local altContainer
																local altCount

																for k,inv in ipairs(inventoryIndex) do
																	if containers[inv] and containers[inv][itemID] then
																		if containers[inv][itemID] > (altCount or 0) then
																			altContainer = inv
																			altCount = containers[inv][itemID]
																		end
																	end
																end

																if altContainer then
																	local container = altContainer
																	GameTooltip:AddDoubleLine("   "..inventoryColors.alt..inventoryName.."/"..container,inventoryColors.alt..altCount)
																	shown = shown + 1
																end
															end
														end


														local playerGuild = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

														for guild,guildInventoryData in pairs(GnomeWorks.data.guildInventory) do
															if guild ~= playerGuild then
																for tab,tabData in ipairs(guildInventoryData) do
																	if tabData[itemID] then
																		if tabData[itemID] > 0 then
																			GameTooltip:AddDoubleLine("   "..inventoryColors.alt..guild.."/tab"..tab,inventoryColors.alt..tabData[itemID])
																			shown = shown + 1
																		end
																	end
																end
															end
														end
													else
														GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key]..count)
														shown = shown + 1
													end
												end
											end
										end
									end


									if entry.reserved>0 then
										GameTooltip:AddLine(" ")
										GameTooltip:AddDoubleLine("|cffff0000reserved","|cffff0000"..entry.reserved)
										shown = shown + 1
									end

									if shown == 0 then
										GameTooltip:AddLine("none found",1,0,0)
									end

									GameTooltip:Show()
								end
							end
						end,
			OnLeave =	function()
							GameTooltip:Hide()
						end,

			draw =	function (rowFrame,cellFrame,entry)
						local display = "|cffff00000"
						local low, hi
						local lowKey, hiKey
						local lowValue, hiValue
						local vendor

						local inventoryIndex = GnomeWorksDB.config.inventoryIndex

						for k,inv in ipairs(inventoryIndex) do
							local value = entry[inv]
							if value>0 then
								low = k
								lowKey = inv
								lowValue = value
								break
							end
						end

						if low then
							for i=#inventoryIndex,low+1,-1 do
								local key = inventoryIndex[i]

								if key == "vendor" and entry.vendorItem then
									vendor = true
									break
								end

								if entry[key] > entry[inventoryIndex[i-1]] then
									hi = i
									hiKey = key
									hiValue = entry[key]
									break
								end
							end

							if vendor then
								local lowString = string.format(inventoryFormat[lowKey],lowValue)
								local hiString = string.format(inventoryFormat.vendor,"\226\136\158")

								display = lowString.."+"..hiString
							elseif hi and lowValue < hiValue then
								local lowString = string.format(inventoryFormat[lowKey],lowValue)
								local hiString = string.format(inventoryFormat[hiKey],hiValue-lowValue)

								display = lowString.."+"..hiString
							elseif lowKey == "vendor" then
								display = string.format(inventoryFormat.vendor,"\226\136\158")
							else
								display = string.format(inventoryFormat[lowKey],lowValue)
							end
						elseif entry.vendorItem then
							display = string.format(inventoryFormat.vendor,"\226\136\158")
						end

						if entry.reserved > 0 then
							display = display.."|cffff0000-"..entry.reserved
						end

						cellFrame.text:SetText(display)
					end,
		}, -- [3]
		{
			name = "Inventory",
			width = 70,
			align = "CENTER",
			OnClick = function(cellFrame, button, source)
				if cellFrame:GetParent().rowIndex==0 then
					columnControl(cellFrame, button, source)
				end
			end,
			OnEnter =	function (cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Reagent Availability",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
--								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								if entry  then
									GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
									GameTooltip:ClearLines()
									GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

									local itemID = entry.id

									local prev = 0

									local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

									local inventoryIndex = GnomeWorksDB.config.inventoryIndex

									local shown = 0

									for i,key in ipairs(inventoryIndex) do
										if key ~= "vendor" and (key ~= "guildBank" or checkGuildBank) then
											local count = entry.inventory[key] or 0

											if count ~= 0 then
												GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key]..count)
											end

											shown = shown + 1

											prev = count
										end
									end

									if GnomeWorksDB.config.inventoryTracked.alt and entry.inventory.alt>0 then
										GameTooltip:AddLine("    ")

										GameTooltip:AddLine("alt item locations:",.8,.8,.8)
										for player, containers in pairs(GnomeWorks.data.inventoryData) do
											if player ~= GnomeWorks.player then
												for i,key in ipairs(inventoryIndex) do
													if key ~= "vendor" and key ~= "guildBank" and key ~= "alt" then
														local count = containers[key] and containers[key][itemID]

														if count and count > 0 then
															GameTooltip:AddDoubleLine("   "..inventoryColors.alt..player.."/"..key,inventoryColors.alt..count)
														end
													end
												end

											end
										end


										local playerGuild = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

										for guild,guildInventoryData in pairs(GnomeWorks.data.guildInventory) do
											if guild ~= playerGuild then
												for tab,tabData in ipairs(guildInventoryData) do
													if tabData[itemID] then
														if tabData[itemID] > 0 then
															GameTooltip:AddDoubleLine("   "..inventoryColors.alt..guild.."/tab"..tab,inventoryColors.alt..tabData[itemID])
															shown = shown + 1
														end
													end
												end
											end
										end
									end


									if shown == 0 then
										GameTooltip:AddLine("none found",1,0,0)
									end

									GameTooltip:Show()
								end
							end
						end,
			OnLeave =	function()
							GameTooltip:Hide()
						end,

			draw =	function (rowFrame,cellFrame,entry)
						local display = "|cffff00000"
						local low, hi
						local lowKey, hiKey
						local lowValue, hiValue
						local vendor

						local inventoryIndex = GnomeWorksDB.config.inventoryIndex

						for k,inv in ipairs(inventoryIndex) do
							if inv ~= "vendor" then
								local value = entry.inventory[inv]

								if value>0 then
									low = k
									lowKey = inv
									lowValue = value
									break
								end
							end
						end

						if low then
							for i=#inventoryIndex,low+1,-1 do
								local key = inventoryIndex[i]

								if key ~= "vendor" then
									if entry.inventory[key] > 0 then
										hi = i
										hiKey = key
										hiValue = entry.inventory[key]
										break
									end
								end
							end

							if hi and lowValue and hiValue then
								local lowString = string.format(inventoryFormat[lowKey],lowValue)
								local hiString = string.format(inventoryFormat[hiKey],hiValue)

								display = lowString.."+"..hiString
							elseif lowKey == "vendor" then
								display = string.format(inventoryFormat.vendor,"\226\136\158")
							else
								display = string.format(inventoryFormat[lowKey],lowValue)
							end
						end

						cellFrame.text:SetText(display)
					end,
		}, -- [4]
	}





	function GnomeWorks:CreateReagentFrame(parentFrame)
		local function ResizeReagentFrame(scrollFrame, width, height)
			scrollFrame.columnWidth[2] = scrollFrame.columnWidth[2] + width - scrollFrame.headerWidth
			scrollFrame.headerWidth = width

			local x = 0

			for i=1,#scrollFrame.columnFrames do
				scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
				scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+scrollFrame.columnWidth[i],0)

				x = x + scrollFrame.columnWidth[i]
			end
		end


		local ScrollPaneBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 9.5, right = 9.5, top = 9.5, bottom = 9.5 }
			}

		reagentFrame = CreateFrame("Frame",nil,parentFrame)
		reagentFrame:SetPoint("BOTTOM",0,20)
		reagentFrame:SetPoint("TOP", detailFrame, "TOP", 0, 15 - GnomeWorksDB.config.displayOptions.scrollFrameLineHeight)
		reagentFrame:SetPoint("RIGHT", parentFrame, -20,0)
		reagentFrame:SetPoint("LEFT", detailFrame, "RIGHT", 5,0)

		GnomeWorks.reagentFrame = reagentFrame

--		GnomeWorks.Window:SetBetterBackdrop(reagentFrame,backDrop)


		columnHeaders[2].width = reagentFrame:GetWidth() - 90

		sf = GnomeWorks:CreateScrollingTable(reagentFrame, ScrollPaneBackdrop, columnHeaders, ResizeReagentFrame)

		reagentFrame.scrollFrame = sf


		sf.data = { entries = {  } }

		for i=1,8 do
			sf.data.entries[i] = { index = i, id = 0, numNeeded = 0 }
		end

		sf.numData = 0
		sf.data.numEntries = 0

		function GnomeWorks:HideReagents()
			reagentFrame:Hide()
		end

		function GnomeWorks:ShowReagents(index)
			if not index or not self.tradeID then return end

			local recipeID

			if index < 0 then
				recipeID = -index
			else
				if self.data.pseudoTradeData[self.tradeID] then
					local trade = self.data.pseudoTradeData[self.tradeID]

					recipeID = trade.skillList[index]
				else
					recipeID = self.data.skillDB[self.player..":"..self.tradeID] and self.data.skillDB[self.player..":"..self.tradeID].recipeID[index]
				end
			end

			reagentFrame:Show()

--			local skillData = self:GetSkillData(index)

--			local recipeID = self.data.skillDB[self.player..":"..self.tradeID] and self.data.skillDB[self.player..":"..self.tradeID].recipeID[index] or self.data.pseudoTrade[self.tradeID][index]

			if recipeID then
--				local results, reagents, tradeID = self:GetRecipeData(skillData.id)

--				sf.data.entries = recipeData.reagentData

--				sf.numData = #recipeData.reagentData

				local i = 0

				local results, reagents = self:GetRecipeData(recipeID)

				if reagents then
					for reagentID, numNeeded in pairs(reagents) do
						i = i + 1
						sf.data.entries[i].id = reagentID
						sf.data.entries[i].numNeeded = numNeeded
						sf.data.entries[i].index = i
					end
				end

				sf.data.numEntries = i

				sf:Refresh()
			end
		end


		local function UpdateRowData(scrollFrame,entry,firstCall)
			local player = GnomeWorks.player
			local itemID = entry.id

			if GnomeWorks:VendorSellsItem(itemID) then
				entry.vendorItem = true
			else
				entry.vendorItem = false
			end


			entry.reserved = 0 --  math.abs(math.min(0,GnomeWorks:GetInventoryCount(entry.id, GnomeWorks.player, "queue")))

			if not entry.inventory then
				entry.inventory = {}
			end


			if itemID then
				for k,inv in ipairs(GnomeWorksDB.config.inventoryIndex) do
					if GnomeWorksDB.config.inventoryTracked[inv] then

						if inv ~= "alt" then
							entry.inventory[inv] = GnomeWorks:GetInventoryCount(itemID, player, inv)
							entry[inv] = GnomeWorks:GetCraftableInventoryCount(itemID, player, inv)
						else
							entry.inventory.alt = GnomeWorks:GetFactionInventoryCount(itemID, player)

							entry.alt = entry.totalCraftable + GnomeWorks:GetFactionInventoryCount(itemID, player)
						end

						entry.totalCraftable = entry[inv]
					end
				end
			end


			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(entry.id)



			if GnomeWorks:VendorSellsItem(entry.id) then
				entry.color = itemColorVendor
			elseif GnomeWorks.data.itemSource[entry.id] then
				entry.color = itemColorCrafted
			else
				entry.color = itemColorNormal
			end

			entry.icon = itemTexture

			entry.name = itemName
		end

		sf:RegisterRowUpdate(UpdateRowData)


		GnomeWorks:RegisterMessageDispatch("SelectionChanged", function()
--print(GetTime(), "details changed")
			GnomeWorks:ShowReagents(GnomeWorks.selectedSkill)
		end, "ShowReagents")

		return reagentFrame
	end


	function GnomeWorks:CreateDetailFrame(frame)
		local COLORORANGE = "|cffff8040"
		local COLORYELLOW = "|cffffff00"
		local COLORGREEN =  "|cff40c040"
		local COLORGRAY =   "|cff808080"

		detailFrame = CreateFrame("Frame",nil,frame)

		detailFrame.textScroll = CreateFrame("ScrollFrame", "GWDetailFrame", detailFrame)



		detailFrame.scrollChild = CreateFrame("Frame",nil,detailFrame.textScroll)
		detailFrame.textScroll:SetScrollChild(detailFrame.scrollChild)

		GnomeWorks.Window:SetBetterBackdrop(detailFrame.textScroll,backDrop)
		GnomeWorks.Window:SetBetterBackdrop(detailFrame,backDrop)

		detailFrame:SetHeight(height)
		detailFrame:SetWidth(detailsWidth)

		detailFrame:SetPoint("BOTTOMLEFT", 20,20)


		detailFrame.textScroll:SetPoint("BOTTOMRIGHT",detailFrame,-2,2)
		detailFrame.textScroll:SetPoint("TOPLEFT",detailFrame,2,-35)

		detailFrame.scrollChild:SetWidth(detailsWidth-4)
		detailFrame.scrollChild:SetHeight(height-37)

		detailFrame.scrollChild:SetAlpha(1)



		detailFrame.levelsBar = {}

		detailFrame.levelsBar.bg = CreateFrame("Frame",nil,detailFrame)
		detailFrame.levelsBar.bg:SetHeight(15)
		detailFrame.levelsBar.bg:SetPoint("BOTTOMLEFT",detailFrame,"TOPLEFT",0,1)
		detailFrame.levelsBar.bg:SetPoint("BOTTOMRIGHT",detailFrame,"TOPRIGHT",0,1)
		GnomeWorks.Window:SetBetterBackdrop(detailFrame.levelsBar.bg,backDrop)


		local function StatusBarOnEnter(bar)
			GameTooltip:SetOwner(bar, "ANCHOR_TOP")
--			local r,g,b = SkilletSkillName:GetTextColor()
--			GameTooltip:AddLine(SkilletSkillName:GetText(),r,g,b)

			recipeID = detailFrame.levelsBar.recipeID

			local gray = GnomeWorks.data.recipeSkillLevels[3][recipeID] or 1
			local yellow = GnomeWorks.data.recipeSkillLevels[2][recipeID] or 1
			local orange = GnomeWorks.data.recipeSkillLevels[1][recipeID] or 1

			local green = (gray + yellow)/2

			GameTooltip:AddLine(COLORORANGE..orange.."|r/"..COLORYELLOW..yellow.."|r/"..COLORGREEN..green.."|r/"..COLORGRAY..gray)

			GameTooltip:Show()
		end


		local function CreateStatusBar(level, r,g,b,a)
			local bar = CreateFrame("StatusBar",nil,detailFrame.levelsBar.bg)

			bar:SetPoint("LEFT",2,0)
			bar:SetPoint("RIGHT",-2,0)

			bar:SetHeight(8)

			bar:SetOrientation("HORIZONTAL")
			bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
			bar:SetStatusBarColor(r,g,b)

			bar:SetFrameLevel(bar:GetFrameLevel()+level)

			bar:SetScript("OnEnter",StatusBarOnEnter)
			bar:SetScript("OnLeave",function() GameTooltip:Hide() end)
			return bar
		end

		detailFrame.levelsBar.current = CreateStatusBar(6, .05, .1, .4)
		detailFrame.levelsBar.current:SetHeight(4)
--detailFrame.levelsBar.current:Hide()


		detailFrame.levelsBar.green = CreateStatusBar(2, 0.25, 0.75, 0.25)
		detailFrame.levelsBar.yellow = CreateStatusBar(3, 1.00, 1.00, 0.00)
		detailFrame.levelsBar.orange = CreateStatusBar(4, 1.00, 0.5, 0.25)
		detailFrame.levelsBar.red = CreateStatusBar(5, 1.00, 0.00, 0.00)

--detailFrame.levelsBar.red:Hide()
--detailFrame.levelsBar.yellow:Hide()
--detailFrame.levelsBar.green:Hide()
--detailFrame.levelsBar.orange:Hide()

--		detailFrame.textScroll:SetScript("OnVerticalScroll", function(frame, value) print(value) end)

		detailFrame.textScroll:SetScript("OnScrollRangeChanged", function(frame, xRange, yRange)
--		print(frame, frame.maxScroll, yRange)
			frame.maxScroll =  yRange
			frame.scroll = 0

			frame:SetVerticalScroll(frame.scroll)
		end)
--[[
		detailFrame.textScroll:SetScript("OnEnter", function(frame)
			detailFrame.textScroll:SetVerticalScroll(detailFrame.maxScroll)
		end)

		detailFrame.textScroll:SetScript("OnLeave", function(frame)
			detailFrame.textScroll:SetVerticalScroll(0)
		end)
]]
		detailFrame.textScroll:SetScript("OnMouseWheel", function(frame, value)
--			print(frame, value, frame.scroll, frame.maxScroll)

			frame.scroll = frame.scroll - value * 16
			if frame.scroll < 0 then
				frame.scroll = 0
			end

			if frame.scroll > frame.maxScroll then
				frame.scroll = frame.maxScroll
			end

			frame:SetVerticalScroll(frame.scroll)
		end)

		detailFrame.textScroll:EnableMouseWheel(true)
		detailFrame.textScroll:EnableMouse(true)

		detailFrame.textScroll.maxScroll = 0
		detailFrame.textScroll.scroll = 0

		detailFrame.textScroll:SetVerticalScroll(0)


		local parentFrame = detailFrame.scrollChild


		local detailIconList = {}
		local detailNumMadeLabelList = {}


		local iconRow, iconColumn = 0,0

		for i=1,32 do
			local detailIcon = CreateFrame("Button",nil,detailFrame)

			detailIcon:EnableMouse(true)

			detailIcon:SetWidth(30)
			detailIcon:SetHeight(30)

			detailIcon:SetPoint("TOPLEFT", 3 + 33 * iconColumn, -3 - 33 * iconRow)

			iconColumn = iconColumn + 1

			if iconRow == 0 then
				if iconColumn == 3 then
					iconColumn = 0
					iconRow = 1
				end
			elseif iconColumn == 7 then
				iconColumn = 0
				iconRow = iconRow + 1
			end

			detailIcon:SetScript("OnClick", function(frame,...)
				local name,link = GetItemInfo(frame.itemID)
				HandleModifiedItemClick(link)
			end)

			detailIcon:SetScript("OnEnter", function(frame,...)
				if frame.itemID then
					GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
					if frame.itemID < 0 then
						GameTooltip:SetHyperlink("enchant:"..-frame.itemID)
					else
						GameTooltip:SetHyperlink("item:"..frame.itemID)
					end

					GameTooltip:AddLine("Shift-Click to Link Item")
					GameTooltip:Show()
				end
				CursorUpdate(self)
			end)

			detailIcon:SetScript("OnLeave", GameTooltip_HideResetCursor)



--			local detailNumMadeLabel = detailIcon:CreateFontString(nil,"OVERLAY", "GameFontGreenSmall")
			local detailNumMadeLabel = detailIcon:CreateFontString(nil,"OVERLAY", "SystemFont_Outline_Small")

			detailNumMadeLabel:SetHeight(9)

			detailNumMadeLabel:SetPoint("BOTTOMRIGHT",-2,2)
			detailNumMadeLabel:SetPoint("TOPLEFT",0,0)
			detailNumMadeLabel:SetJustifyH("RIGHT")
			detailNumMadeLabel:SetJustifyV("BOTTOM")

			detailIconList[i] = detailIcon
			detailNumMadeLabelList[i] = detailNumMadeLabel
		end



		local detailNameButton = CreateFrame("Button",nil,detailFrame)
		detailNameButton:SetPoint("TOPLEFT", detailIconList[1], "TOPRIGHT", 5,0)
		detailNameButton:SetPoint("RIGHT", -5,0)
		detailNameButton:SetHeight(30)


		local detailNameLabel = detailNameButton:CreateFontString(nil,"OVERLAY", "GameFontNormal")
		detailNameLabel:SetPoint("TOPLEFT")
		detailNameLabel:SetPoint("BOTTOMRIGHT")
		detailNameLabel:SetJustifyH("LEFT")
		detailNameLabel:SetTextColor(1,.8,0)


		detailNameButton:EnableMouse(true)

		detailNameButton:RegisterForClicks("AnyUp")


		detailNameButton:SetScript("OnClick", function(frame,...)
			HandleModifiedItemClick(GnomeWorks:GetTradeSkillRecipeLink(GnomeWorks.selectedSkill))
		end)

		detailNameButton:SetScript("OnEnter", function(frame,...)
			GameTooltip:SetOwner(frame, "ANCHOR_TOP")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(detailNameLabel:GetText())
			GameTooltip:AddLine("Shift-Click to Link Recipe\nCtrl-Click to Dress Up")
			GameTooltip:Show()

			detailNameLabel:SetTextColor(1,1,1)
		end)

		detailNameButton:SetScript("OnLeave", function(...)
			detailNameLabel:SetTextColor(1,.8,0)
			GameTooltip_HideResetCursor(...)
		end)



	-- scrolling part below


		detailFrame.infoFunctionList = {}


		function detailFrame:RegisterInfoFunction(func, plugin)
			local descriptionLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			descriptionLabel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0,0)
			descriptionLabel:SetWidth(detailsWidth - 10)
			descriptionLabel:SetHeight(0)
			descriptionLabel:SetJustifyH("LEFT")
			descriptionLabel:SetJustifyV("TOP")
			descriptionLabel:SetTextColor(1,1,1)


			local descriptionLabelRight = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			descriptionLabelRight:SetPoint("TOPLEFT", descriptionLabel, "TOPLEFT", 0,0)
			descriptionLabelRight:SetWidth(detailsWidth - 10)
			descriptionLabelRight:SetHeight(0)
			descriptionLabelRight:SetJustifyH("RIGHT")
			descriptionLabelRight:SetJustifyV("TOP")
			descriptionLabelRight:SetTextColor(1,1,1)

			local new = { func = func, plugin = plugin, leftFS = descriptionLabel, rightFS=descriptionLabelRight }

			table.insert(detailFrame.infoFunctionList, new)
		end


		detailFrame:RegisterInfoFunction(function(index,recipeID,left,right)
			if self:GetTradeSkillTools(index) then
				left = left .. string.format("%s %s\n",REQUIRES_LABEL,BuildColoredListString(self:GetTradeSkillTools(index)))
				right = right .. "\n"
			end
			return left,right
		end)

		detailFrame:RegisterInfoFunction(function(index,recipeID,left,right)
			if self:GetTradeSkillCooldown(index) then
				left = left .. string.format("|cffff0000%s %s\n",COOLDOWN_REMAINING,SecondsToTime(self:GetTradeSkillCooldown(index)))
				right = right .. "\n"
			end

			return left,right
		end)

		detailFrame:RegisterInfoFunction(function(index,recipeID,left,right)
			if GnomeWorks:IsPseudoTrade(GnomeWorks.tradeID) then
			else
				local link = self:GetTradeSkillItemLink(index)

				if link and strfind(link,"item:") then -- or strfind(link,"spell:") or strfind(link,"enchant:") then
					local firstLine = 2

					if strfind(link,"spell:") or strfind(link,"enchant:") then
						firstLine = 4
					end

					tooltipScanner:SetOwner(frame, "ANCHOR_NONE")
					tooltipScanner:SetHyperlink(link)

					local tiplines = tooltipScanner:NumLines()

					if firstLine < tiplines then
						for i=firstLine, tiplines do
							local fs = getglobal("GWParsingTooltipTextLeft"..i)

							local r,g,b,a = fs:GetTextColor()

							left = string.format("%s|c%2x%2x%2x%2x%s|r\n",left,a*255,r*255,g*255,b*255,fs:GetText())


							local fs = getglobal("GWParsingTooltipTextRight"..i)

							local r,g,b,a = fs:GetTextColor()

							right = string.format("%s|c%2x%2x%2x%2x%s|r\n",right,a*255,r*255,g*255,b*255,fs:GetText() or "")
						end
					else
						left = left..(self:GetTradeSkillDescription(index) or "").."\n"
						right = right .. "\n"
					end
				else
					left = left..(self:GetTradeSkillDescription(index) or "").."\n"
					right = right .. "\n"
				end
			end

			return left,right
		end)



		local function GetSkillLevels(id)
			local gray = GnomeWorks.data.recipeSkillLevels[3][id] or 1
			local yellow = GnomeWorks.data.recipeSkillLevels[2][id] or 1
			local orange = GnomeWorks.data.recipeSkillLevels[1][id] or 1

			local green = math.ceil((gray + yellow)/2)

			return orange, yellow, green, gray
		end

		function GnomeWorks:HideDetails()
			detailFrame:Hide()
		end

		function GnomeWorks:ShowDetails(index)
			if not index or not self.tradeID then return end

			local recipeID
			local isPseudoTrade

			if index < 0 then
				recipeID = -index
			else
				if self.data.pseudoTradeData[self.tradeID] then
					local trade = self.data.pseudoTradeData[self.tradeID]

					recipeID = trade.skillList[index]
					isPseudoTrade = true
				else
					recipeID = self.data.skillDB[self.player..":"..self.tradeID] and self.data.skillDB[self.player..":"..self.tradeID].recipeID[index]
				end
			end

			detailFrame:Show()

			local skillName = self:GetRecipeName(recipeID)

			for i=1,32 do
				detailIconList[i]:Hide()
			end


--			detailIconList[1]:SetNormalTexture(self:GetTradeSkillIcon(index))

			local results,reagents,tradeID = self:GetRecipeData(recipeID, self.player)

			local resultCount = 1

			if results then
				for itemID, numMade in pairs(results) do
					local itemIcon = GetItemIcon(itemID)

					if itemID < 0 then
						_,_,itemIcon = GetSpellInfo(-itemID)
					end

					detailIconList[resultCount]:SetNormalTexture(itemIcon)
					detailIconList[resultCount].itemID = itemID
					detailIconList[resultCount].count = numMade

					detailIconList[resultCount]:Show()

					if numMade ~= 1 then
						detailNumMadeLabelList[resultCount]:SetText(math.floor(numMade*100+.5)/100)
						detailNumMadeLabelList[resultCount]:Show()
					else
						detailNumMadeLabelList[resultCount]:Hide()
					end

					resultCount = resultCount + 1
				end
			end

			if resultCount >= 4 then
				detailFrame.textScroll:Hide()
			else
				detailFrame.textScroll:Show()
			end

			detailNameButton:SetPoint("TOPLEFT", detailIconList[1], "TOPRIGHT", 5 + 33 * math.min(2,(resultCount-2)),0)

			detailNameLabel:SetText(skillName)

			local pos = 0

			for k,entry in pairs(detailFrame.infoFunctionList) do
				local lineTextLeft,lineTextRight = "",""

				lineTextLeft, lineTextRight = entry.func(index, recipeID, lineTextLeft, lineTextRight)

				entry.leftFS:SetText(lineTextLeft)
				entry.rightFS:SetText(lineTextRight)

				entry.leftFS:SetPoint("TOPLEFT", 0,-pos)

				pos = pos + math.max(entry.leftFS:GetStringHeight(), entry.rightFS:GetStringHeight())

	--			descriptionLabel:Show()
	--			descriptionLabelRight:Show()
			end

			if not isPseudoTrade and results then
				local rank, maxRank, estimatedRank = GnomeWorks:GetTradeSkillRank()

				local orange, yellow, green, gray = GetSkillLevels(recipeID)

--print("update to new levels:", recipeID, GnomeWorks:GetRecipeName(recipeID), orange, yellow, green, gray)

				detailFrame.levelsBar.recipeID = recipeID

				detailFrame.levelsBar.green:SetMinMaxValues(1,maxRank)
				detailFrame.levelsBar.yellow:SetMinMaxValues(1,maxRank)
				detailFrame.levelsBar.orange:SetMinMaxValues(1,maxRank)
				detailFrame.levelsBar.red:SetMinMaxValues(1,maxRank)

				detailFrame.levelsBar.current:SetMinMaxValues(1,maxRank)


				detailFrame.levelsBar.green:SetValue(gray)
				detailFrame.levelsBar.yellow:SetValue(green)
				detailFrame.levelsBar.orange:SetValue(yellow)
				detailFrame.levelsBar.red:SetValue(orange)

				if estimatedRank then
					detailFrame.levelsBar.current:SetValue(estimatedRank)
				else
					detailFrame.levelsBar.current:SetValue(rank)
				end

				detailFrame.levelsBar.bg:Show()
			else
				detailFrame.levelsBar.bg:Hide()
			end

		end



		GnomeWorks:RegisterMessageDispatch("SelectionChanged", function()
			self:ShowDetails(self.selectedSkill)
		end, "ShowDetails")

		return detailFrame
	end



end
