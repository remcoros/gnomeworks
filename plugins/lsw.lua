
-- LSW plugin Interface
do
	local plugin

	local function RegisterWithLSW()
		if not LSW then return end

		if not LSW.buttonScripts then
			print("|cffff0000GnomeWorks LSW support requires an update to your local copy of LilSparky's Workshop")
			return
		end

		local valueColumn
		local costColumn
		local scrollFrame

		local reagentCostColumn
		local reagentScrollFrame

		local queueScrollFrame
		local queueCostColumn

		local shoppingListScrollFrame
		local shoppingListCostColumn


		local itemCache

		local totalQueueCost = 0
		local totalQueueValue = 0


		local itemFateColor={
			["d"]="ff008000",
			["a"]="ff909050",
			["v"]="ff206080",
			["?"]="ff800000",
		}

		local fateString={["a"]="Auction", ["v"]="Vendor", ["d"]="Disenchant"}



		local costFilterMenu = {
		}

		local costFilterParameters = {
			{
				name = "HideUnprofitable",
				text = "Hide Unprofitable",
				enabled = false,
				func = function(entry)
					return (entry.value or 0) < (entry.cost or 0)
				end,
			},
		}




		local function columnControl(cellFrame,button,source)
			local filterMenuFrame = GnomeWorksMenuFrame
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

		local function columnTooltip(cellFrame, text)
			GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(text,1,1,1,true)

			GameTooltip:AddLine("Left-click to Sort")
			GameTooltip:AddLine("Right-click to Adjust Filterings")

			GameTooltip:Show()
		end


		local valueColumnHeader = {
			name = "Value",
			width = 50,
			headerAlign = "CENTER",
			align = "RIGHT",
			font = "GameFontHighlightSmall",
	--		filterMenu = costFilterMenu,
			sortCompare = function(a,b)
				return (a.value or 0) - (b.value or 0)
			end,
			draw = function (rowFrame, cellFrame, entry)
				if not entry.subGroup then
					local itemFate = entry.fate or "?"
					local costAmount = entry.cost or 0
					local valueAmount = entry.value or 0

					local itemFateString = string.format("|c%s%s|r", itemFateColor[itemFate], itemFate)
					local hilight = (costAmount or 0) < (valueAmount or 0)
					local valueText

					if itemFate == "a" and itemCache[itemID] and itemCache[itemID].BOP then
						valueText = BOP_STRING
					elseif itemFate == "d" and itemCache[itemID] and not itemCache[itemID].disenchantValue then
						valueText = NO_DE_STRING
					else
						if LSWConfig.valueAsPercent then
							if (costAmount > 0 and valueAmount >= 0) then
								local per = valueAmount / costAmount

								if per < .1 then
									per = math.floor(per*1000)/10
									valueText = string.format("%2.1f%%",per)
								elseif per > 10 then
									per = math.floor(per*10)/10
									valueText = string.format("%2.1fx",per)
								else
									per = math.floor(per*100)
									valueText = per.."%"
								end

								if (hilight) then
									valueText = "|cffd0d0d0"..valueText..itemFateString
								else
									valueText = "|cffd02020"..valueText..itemFateString
								end

							elseif (valueAmount >= 0) then
								valueText = "inf"..itemFateString
							end
						else
							if LSWConfig.singleColumn then
								valueText = (LSW:FormatMoney((valueAmount or 0) - (costAmount or 0),hilight) or "--")..itemFateString
							else
								if (valueAmount or -1) < 0 then
									valueText = "   --"..itemFateString
								else
									valueText = (LSW:FormatMoney(valueAmount,hilight) or "--")..itemFateString
								end
							end
						end
					end


					cellFrame.text:SetText(valueText)
				else
					cellFrame.text:SetText("")
				end
			end,
			OnClick = function (cellFrame, button, source)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.valueButton.OnClick(cellFrame, button)
				else
					columnControl(cellFrame, button, source)
				end
			end,
			OnEnter = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.valueButton.OnEnter(cellFrame)
				else
					columnTooltip(cellFrame, "LSW Skill Value")
				end
			end,
			OnLeave = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.valueButton.OnLeave(cellFrame)
				else
					GameTooltip:Hide()
				end
			end,

			enabled = function()
				return GnomeWorks.tradeID ~= 53428
			end,
		}



		local costColumnHeader = {
			name = "Cost",
			width = 50,
			headerAlign = "CENTER",
			align = "RIGHT",
			font = "GameFontHighlightSmall",
			filterMenu = costFilterMenu,
			sortCompare = function(a,b)
				return (a.cost or 0) - (b.cost or 0)
			end,
			draw = function (rowFrame, cellFrame, entry)
				if not entry.subGroup then
					cellFrame.text:SetText((LSW:FormatMoney(entry.cost,false) or "").."  ")
				else
					cellFrame.text:SetText("")
				end
			end,
			OnClick = function (cellFrame, button, source)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.costButton.OnClick(cellFrame, button)
				else
					columnControl(cellFrame,button,source)
				end
			end,
			OnEnter = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.costButton.OnEnter(cellFrame)
				else
					columnTooltip(cellFrame, "LSW Skill Cost")
				end
			end,
			OnLeave = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
					cellFrame:SetID(entry.index)
					LSW.buttonScripts.costButton.OnLeave(cellFrame)
				else
					GameTooltip:Hide()
				end
			end,

			enabled = function()
				return GnomeWorks.tradeID ~= 53428 and not LSWConfig.singleColumn
			end,
		}



		local function ReagentCost_Tooltip(itemID, recipeID, numNeeded, parentFrame)
			local LSWTooltip = GameTooltip

			LSWTooltip:SetOwner(parentFrame or LSW.parentFrame, "ANCHOR_NONE")
			LSWTooltip:SetPoint("BOTTOMLEFT", parentFrame or LSW.parentFrame, "BOTTOMRIGHT")

			local total = 0

			local pad = ""

			local residualMaterials = {}

			if not recipeID and itemID > 0 then
				LSWTooltip:AddLine("Cost Breakdown for "..(GetItemInfo(itemID) or itemID))

				total = LSW.buttonScripts.CostButton_AddItem(itemID, numNeeded, 1, residualMaterials)
			else
--				local recipeID = -itemID

				LSWTooltip:AddLine("Cost Breakdown for "..GnomeWorks:GetRecipeName(recipeID))

				local results,reagents = GnomeWorks:GetRecipeData(recipeID)

				if LSW.recipeCache.reagents[recipeID] then
					local costAmount = LSW:GetSkillCost(recipeID)

					for itemID, numNeeded in pairs(LSW.recipeCache.reagents[recipeID]) do
						total = total + LSW.buttonScripts.CostButton_AddItem(itemID, numNeeded, 1, residualMaterials)
					end
				end

			end

			if LSWConfig.costBasis == COST_BASIS_PURCHASE then
				LSWTooltip:AddDoubleLine("Total estimated purchase cost: ", LSW:FormatMoney(total,true).."  ")
			else
				LSWTooltip:AddDoubleLine("Total estimated reagent value: ", LSW:FormatMoney(total,true).."  ")
			end

			local residualsShow

			for residualID, residualCount in pairs(residualMaterials) do
				if residualCount > 0 then
					residualsShow = true
				end
			end

			if residualsShow then
				local totalResidualValue = 0

				LSWTooltip:AddLine(" ")
				LSWTooltip:AddLine("Residual Reagents:")

				for residualID, residualCount in pairs(residualMaterials) do
					if residualCount > 0.001 then
						local residualValue
						local _, reagentName = GetItemInfo(residualID)

						if LSWConfig.residualPricing == COST_BASIS_RESALE then
							LSW.UpdateItemValue(residualID)
							residualValue = itemCache[residualID].bestValue * residualCount
							LSWTooltip:AddDoubleLine("    "..reagentName.." x "..residualCount, LSW:FormatMoney(residualValue, true)..(itemCache[residualID].fate or "?"))
						else
							LSW.UpdateItemCost(residualID)
							residualValue = itemCache[residualID].bestCost * residualCount
							LSWTooltip:AddDoubleLine("    "..reagentName.." x "..residualCount, LSW:FormatMoney(residualValue, true)..(itemCache[residualID].source or "?"))
						end

						totalResidualValue = totalResidualValue + residualValue
					end
				end

				LSWTooltip:AddDoubleLine("Total residual reagent value: ", LSW:FormatMoney(totalResidualValue,true).."  ")
			end

			LSWTooltip:Show()

			return total
		end


		local reagentCostColumnHeader = {
			name = "Cost",
			width = 50,
			headerAlign = "CENTER",
			align = "RIGHT",
			font = "GameFontHighlightSmall",
	--		filterMenu = costFilterMenu,
			sortCompare = function(a,b)
				return (a.cost or 0) - (b.cost or 0)
			end,
			draw = function (rowFrame, cellFrame, entry)
				if not entry.subGroup then
					cellFrame.text:SetText((LSW:FormatMoney(entry.cost,true) or "").."  ")
				else
					cellFrame.text:SetText("")
				end
			end,
			OnClick = function (cellFrame, button, source)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
	--				cellFrame:SetID(entry.skillIndex)
	--				LSW.buttonScripts.costButton.OnClick(cellFrame, button)
				else
					columnControl(cellFrame,button,source)
				end
			end,
			OnEnter = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data

					ReagentCost_Tooltip(entry.id, nil, entry.numNeeded)

	--				cellFrame:SetID(entry.skillIndex)
	--				LSW.buttonScripts.costButton.OnEnter(cellFrame)
				else
					columnTooltip(cellFrame, "LSW Reagent Cost")
				end
			end,
			OnLeave = function (cellFrame)
				GameTooltip:Hide()
			end,
		}



		local queueCostColumnHeader = {
			name = "Cost",
			width = 50,
			headerAlign = "CENTER",
			align = "RIGHT",
			font = "GameFontHighlightSmall",
	--		filterMenu = costFilterMenu,
			sortCompare = function(a,b)
				return (a.cost or 0) - (b.cost or 0)
			end,
			draw = function (rowFrame, cellFrame, entry)
				if entry.command == "collect" then
					cellFrame.text:SetText((LSW:FormatMoney(entry.cost,false) or "??"))
					cellFrame.text:SetJustifyH("LEFT")
				else
					cellFrame.text:SetText((LSW:FormatMoney(entry.cost,true) or "??"))
					cellFrame.text:SetJustifyH("RIGHT")
				end
			end,
			OnClick = function (cellFrame, button, source)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data
	--				cellFrame:SetID(entry.skillIndex)
	--				LSW.buttonScripts.costButton.OnClick(cellFrame, button)
				else
	--				columnControl(cellFrame,button,source)
				end
			end,
			OnEnter = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
					local entry = cellFrame:GetParent().data

					ReagentCost_Tooltip(entry.itemID, entry.recipeID, entry.count, queueScrollFrame)

	--				cellFrame:SetID(entry.skillIndex)
	--				LSW.buttonScripts.costButton.OnEnter(cellFrame)
				else
					GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
					GameTooltip:ClearLines()
					GameTooltip:AddLine("LSW Entry Cost",1,1,1,true)

					GameTooltip:AddDoubleLine("|cffffffffTotal Reagent Value:",LSW:FormatMoney(totalQueueValue,true))
					GameTooltip:AddDoubleLine("|cffffffffOut-of-Pocket Cost:",LSW:FormatMoney(totalQueueCost,true))

					GameTooltip:Show()
				end
			end,
			OnLeave = function (cellFrame)
				GameTooltip:Hide()
			end,
		}



		local function updateData(scrollFrame, entry)
			local skillName, skillType, itemLink, recipeLink, itemID, recipeID = LSW:GetTradeSkillData(entry.index)


			if skillType ~= "header" then
				LSW.UpdateSingleRecipePrice(entry.recipeID)
				entry.value, entry.fate = LSW:GetSkillValue(entry.recipeID, globalFate)
				entry.cost = LSW:GetSkillCost(entry.recipeID)
			end
		end


		local function updateReagentData(scrollFrame, entry)
			entry.cost = LSW:GetItemCost(entry.id) * entry.numNeeded
		end


		local function updateQueueData(scrollFrame, entry)
			if entry == scrollFrame.data.entries[1] then
				totalQueueCost = 0
				totalQueueValue = 0
			end

			if entry.command == "create" then
				LSW.UpdateSingleRecipePrice(entry.recipeID)

				entry.cost = (LSW:GetSkillCost(entry.recipeID) or 0) * (entry.count)

				totalQueueValue = totalQueueValue + entry.cost
			else
				entry.cost = 0

				if not entry.source then
					if GnomeWorks:VendorSellsItem(entry.itemID) then
						local name,_,_,_,_,_,_,_,_,tex,sellCost = GetItemInfo(entry.itemID)

						entry.cost = sellCost*4 * (entry.count)
					else
						entry.cost = LSW.auctionCost(entry.itemID) * (entry.count)
					end
				end

				totalQueueCost = totalQueueCost + entry.cost
			end
		end




		local function refreshWindow()
			if LSWConfig.singleColumn then
				valueColumn.name = "Profit"
			else
				valueColumn.name = "Value"
			end

			scrollFrame:Refresh()
			reagentScrollFrame:Refresh()
			queueScrollFrame:Refresh()
		end


		local function Init()
	--		LSW:ChatMessage("LilSparky's Workshop plugging into Skillet (v"..Skillet.version..")");





			scrollFrame = GnomeWorks:GetSkillListScrollFrame()

			scrollFrame:RegisterRowUpdate(updateData, plugin)

			valueColumn = scrollFrame:AddColumn(valueColumnHeader, plugin)
			costColumn = scrollFrame:AddColumn(costColumnHeader, plugin)

			scrollFrame.columnFrames["Profit"] = scrollFrame.columnFrames["Value"]						-- "name" drives column identification so alias the variable name to the registered name

			GnomeWorks:CreateFilterMenu(costFilterParameters, costFilterMenu, costColumnHeader)



			reagentScrollFrame = GnomeWorks:GetReagentListScrollFrame()
			reagentScrollFrame:RegisterRowUpdate(updateReagentData, plugin)

			reagentCostColumn = reagentScrollFrame:AddColumn(reagentCostColumnHeader, plugin)

	--		GnomeWorks:CreateFilterMenu(costFilterParameters, reagentCostFilterMenu, reagentCostColumnHeader)


			queueScrollFrame = GnomeWorks:GetQueueListScrollFrame()
			queueScrollFrame:RegisterRowUpdate(updateQueueData, plugin)

			queueCostColumn = queueScrollFrame:AddColumn(queueCostColumnHeader, plugin)



			itemCache = LSW.itemCache


			LSW.parentFrame = GnomeWorks:GetMainFrame()

			LSW.RefreshWindow = refreshWindow


			function LSW:GetTradeSkillData(id)
				local skillName, skillType = GnomeWorks:GetTradeSkillInfo(id)
				local itemLink = GnomeWorks:GetTradeSkillItemLink(id)
				local recipeLink = GnomeWorks:GetTradeSkillRecipeLink(id)

				local itemID = LSW:FindID(itemLink)
				local recipeID = LSW:FindID(recipeLink)

				if itemID and recipeID and recipeID == tradeID then
					local scroll = LSW.scrollData[recipeID]

					if scroll then
						itemID = scroll.scrollID					-- for enchants, the item created is a scroll
						scrollVellum = 38682
					else
						itemID = -recipeID
					end
				end

				return skillName, skillType, itemLink, recipeLink, itemID, recipeID
			end

			local function togglePlugin()
				plugin.enabled = not plugin.enabled
			end

			local button = plugin:AddButton("Enabled", togglePlugin)

			button.checked = function() return plugin.enabled end



			local f = CreateFrame("Frame")

			local function AddPseudoTradeRecipes()
				local recipeList = GnomeWorks.data.pseudoTradeRecipes
				local recipeCache = LSW.recipeCache

				for recipeID, tradeID in pairs(recipeList) do
					local results,reagents = GnomeWorks:GetRecipeData(recipeID)

					recipeCache.reagents[recipeID] = reagents
					recipeCache.results[recipeID] = results

					for itemID in pairs(reagents) do
						LSW.AddToItemCache(itemID)
					end

					for itemID,numMade in pairs(results) do
						LSW.AddToItemCache(itemID, recipeID, numMade)
					end
				end

				f:Hide()
			end


			f:RegisterEvent("TRADE_SKILL_SHOW")

			f:SetScript("OnEvent", AddPseudoTradeRecipes)
		end


		local function Test()
			if GnomeWorks then
				return true
			end

			return false
		end


		LSW:RegisterFrameSupport("GnomeWorks", Test, Init)


		return true
	end


	plugin = GnomeWorks:RegisterPlugin("LilSparky's Workshop", RegisterWithLSW)

end


