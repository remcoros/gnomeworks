

local GnomeWorks = GnomeWorks
local LARGE_NUMBER = 1000000


do
	local frame
	local sf

	local doTradeEntry


	local clientVersion, clientBuild = GetBuildInfo()

	local insetBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 10, right = 10, top = 10, bottom = 10 }
			}


	local colorWhite = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 }
	local colorBlack = { ["r"] = 0.0, ["g"] = 1.0, ["b"] = 0.0, ["a"] = 0.0 }
	local colorDark = { ["r"] = 1.1, ["g"] = 0.1, ["b"] = 0.1, ["a"] = 0.0 }

	local highlightOff = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.0 }
	local highlightSelected = { ["r"] = 0.5, ["g"] = 0.5, ["b"] = 0.5, ["a"] = 0.5 }
	local highlightSelectedMouseOver = { ["r"] = 1, ["g"] = 1, ["b"] = 0.5, ["a"] = 0.5 }


	local inventoryIndex = { "bag", "vendor", "bank", "mail", "guildBank", "alt" }

--	local collectInventories = { "bank", "mail", "guildBank", "alt" }

--[[
	local inventoryColors = {
--		queue = "|cffff0000",
		bag = "|cffffff80",
		vendor = "|cff80ff80",
		bank =  "|cffffa050",
		guildBank = "|cff5080ff",
		mail = "|cff60fff0",
		alt = "|cffff80ff",
	}

	local inventoryTags = {}

	for k,v in pairs(inventoryColors) do
		inventoryTags[k] = v..k
	end
]]

	local inventoryColors = GnomeWorks.system.inventoryColors
	local inventoryFormat = GnomeWorks.system.inventoryFormat
	local inventoryTags = GnomeWorks.system.inventoryTags

	local queueFrame

	local queuePlayer

	local currentRecipe


	local queueQueue = {}



	local queueColors = {
		needsMaterials = {1,0,0},
		needsVendor = {0,1,0},
		needsCrafting = {0,1,1}
	}




	local function ColumnControl(cellFrame,button,source,menu)
		local menuFrame = GnomeWorksMenuFrame
		local scrollFrame = cellFrame:GetParent():GetParent()
		currentRecipe = cellFrame:GetParent().data


			if cellFrame.header[menu] then
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				EasyMenu(cellFrame.header[menu], menuFrame, UIParent, x/uiScale,y/uiScale, "MENU", 5)
			end

--[[
		else
			scrollFrame.sortInvert = (scrollFrame.SortCompare == cellFrame.header.sortCompare) and not scrollFrame.sortInvert

			scrollFrame:HighlightColumn(cellFrame.header.name, scrollFrame.sortInvert)
			scrollFrame.SortCompare = cellFrame.header.sortCompare
			scrollFrame:Refresh()
		end
]]

	end



	local function ResizeMainWindow()
		GnomeWorks:SendMessageDispatch("FrameMoved")
	end




	local function CalculateCheapestPath(recipeID, player, inventoryDelta, auctionDelta)
		if recipeID then
			local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID, player)
			local auctionQueue = GnomeWorks.data.auctionQueue[player]

			if reagents then
				local savedInventoryDelta = {}
				local savedAuctionDelta = {}

				for reagentID in pairs(reagents) do
					savedInventoryDelta[reagentID] = inventoryDelta[reagentID]
					savedAuctionDelta[reagentID] = auctionDelta[reagentID]
				end

				local totalCost = 0

				for reagentID, numNeeded in pairs(reagents) do
					local itemSource = GnomeWorks.data.itemSource[reagentID]
					local needed = numNeeded

					local vendorCost
					local vendorSource

					if GnomeWorks:VendorSellsItem(reagentID) then
						vendorCost = GnomeWorks:GetVendorCost(reagentID)
						vendorSource = "vendor"
					end

					local available = GnomeWorks:GetFactionInventoryCount(reagentID) - GnomeWorks:GetInventoryCount(reagentID, player, "queue") + (inventoryDelta[reagentID] or 0)

					if available > needed then
						available = needed
					end

					needed = needed - available

					inventoryDelta[reagentID] = (inventoryDelta[reagentID] or 0) - available

					while needed>0 do
						local minCost = vendorCost
						local selectedSource = vendorSource

						local auctionCost = GnomeWorks:GetAuctionCost(reagentID, needed, ((auctionQueue and auctionQueue[reagentID]) or 0) - (auctionDelta[reagentID] or 0))

						if not minCost or auctionCost < minCost then
							minCost = auctionCost
							selectedSource = "auction"
						end

						if itemSource then
							for sourceRecipeID, numMade in pairs(itemSource) do
								local cost = CalculateCheapestPath(sourceRecipeID, player, inventoryDelta, auctionDelta)

								if cost then
									if not minCost or minCost > cost then
										minCost = cost
										selectedSource = sourceRecipeID
									end
								end
							end
						end

						if minCost then
							if selectedSource == "auction" then
								auctionDelta[reagentID] = (auctionDelta[reagentID] or 0) - 1
							end

							totalCost = totalCost + minCost
						else
							totalCost = nil
							break
						end
					end

					if not totalCost then
						break
					end
				end

				for reagentID in pairs(reagents) do
					inventoryDelta[reagentID] = savedInventoryDelta[reagentID]
					auctionDelta[reagentID] = savedAuctionDelta[reagentID]
				end

				return totalCost
			end
		end
	end


	local function AddItemsToShoppingList(player, entry)
		if player and entry and entry.subGroup.entries then
			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]

			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			for k,reagent in ipairs(entry.subGroup.entries) do
				reagent.parent = entry.subGroup.entries
				local itemID = reagent.itemID

				if reagent.command == "collect" then
					local sourceQueue

					if reagent.source then
						sourceQueue = shoppingQueueData[reagent.source]
					elseif GnomeWorks:VendorSellsItem(reagent.itemID) then
						sourceQueue = shoppingQueueData.vendor
					else
						sourceQueue = shoppingQueueData.auction
					end

					if sourceQueue then
						if sourceQueue[itemID] or reagent.count>0 then
							sourceQueue[itemID] = (sourceQueue[itemID] or 0) + reagent.count
						end
					end

				elseif reagent.command == "create" then
					local resultsReagent,reagentsReagent,tradeID = GnomeWorks:GetRecipeData(reagent.recipeID,player)

					AddItemsToShoppingList(player, reagent)

					for itemID,numNeeded in pairs(reagentsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, numNeeded * reagent.count)
					end

					for itemID,numMade in pairs(resultsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * reagent.count)
					end

					if tradeID == 1000001 then					-- vendor conversion
						local vendorQueue = shoppingQueueData.vendor
						vendorQueue[itemID] = (vendorQueue[itemID] or 0) + reagent.count

						if vendorQueue[itemID] == 0 then
							vendorQueue[itemID] = nil
						end
					end
				end
			end
		end
	end



	local function AdjustQueueCounts(player, entry)
		local adjustments = 0

		if entry.subGroup then
			local count = entry.count
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			local numCraftable = count

			local cost = 0

			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]

			if not entry.reserved then
				entry.reserved = {}
			end


			local reagentsChanged

			if not entry.reagentTree then
				entry.reagentTree = {}
				reagentsChanged = true
			end

			if entry.count ~= entry.oldCount then
				entry.oldCount = entry.count

				reagentsChanged = true
			end

			for index,source in ipairs(GnomeWorksDB.config.inventoryIndex) do
				local treeSource = "reagentTree-"..source

				if not entry[treeSource] then
					entry[treeSource] = {}
					reagentsChanged = true
				end

				local entryTreeSource = entry[treeSource]

				for reagentID in pairs(entry.reagentTree) do
					local inventory = GnomeWorks:GetInventoryCount(reagentID, player, source)

					local oldInventory = entryTreeSource[reagentID]

					if not oldInventory then
						reagentsChanged = true
					end

					if inventory ~= oldInventory then
						entryTreeSource[reagentID] = inventory
						reagentsChanged = true
					end
				end
			end


			if not reagentsChanged then
				AddItemsToShoppingList(player, entry)
				return 0
			end


			for itemID, numNeeded in pairs(reagents) do
				local needed = count * numNeeded

				entry.reserved[itemID] = math.max(0,math.min(needed, GnomeWorks:GetInventoryCount(itemID, player, "bag queue")))
			end


			for k,reagent in ipairs(entry.subGroup.entries) do
				reagent.parent = entry.subGroup.entries

				if reagent.command == "collect" then
					local sourceQueue

					local itemID = reagent.itemID

					entry.reagentTree[reagent.itemID] = reagents[reagent.itemID]


					local numAvailable = LARGE_NUMBER

					if reagent.source then
						if reagent.source ~= "alt" then
							numAvailable = GnomeWorks:GetInventoryCount(itemID, player, reagent.source)
						else
							numAvailable = GnomeWorks:GetFactionInventoryCount(itemID, player)
						end

						sourceQueue = shoppingQueueData[reagent.source]

						numAvailable = numAvailable - (sourceQueue[itemID] or 0)
					elseif GnomeWorks:VendorSellsItem(reagent.itemID) then
						sourceQueue = shoppingQueueData.vendor
					else
						sourceQueue = shoppingQueueData.auction

						numAvailable = GnomeWorks.data.auctionInventory[itemID] or 0

						numAvailable = numAvailable - (sourceQueue[itemID] or 0)
					end

					local stillNeeded = ((reagents and reagents[itemID]) or 1) * entry.count - entry.reserved[itemID]

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(numAvailable)

					entry.reserved[itemID] = entry.reserved[itemID] + reagent.count

					if sourceQueue then
						if sourceQueue[itemID] or reagent.count>0 then
							sourceQueue[itemID] = (sourceQueue[itemID] or 0) + reagent.count
						end
					end

					adjustments = adjustments + 1
				elseif reagent.command == "create" then
					local itemID = reagent.itemID
					local resultsReagent,reagentsReagent,tradeID = GnomeWorks:GetRecipeData(reagent.recipeID,player)
					local numAvailable = 0

					if resultsReagent then
						numAvailable = GnomeWorks:InventoryRecipeIterations(reagent.recipeID, player, "bag queue") * resultsReagent[itemID]
					end

					reagent.numCraftable = numAvailable

					local stillNeeded = ((reagents and reagents[itemID]) or 1) * entry.count - entry.reserved[itemID]

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(stillNeeded / resultsReagent[reagent.itemID])


					adjustments = adjustments + AdjustQueueCounts(player, reagent) + 1

					entry.reserved[itemID] = entry.reserved[itemID] + reagent.count * resultsReagent[itemID]

					for reagentID, numNeeded in pairs(reagent.reagentTree) do
						entry.reagentTree[reagentID] = (entry.reagentTree[reagentID] or 0) + numNeeded
					end


					for itemID,numNeeded in pairs(reagentsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, numNeeded * reagent.count)
					end

					for itemID,numMade in pairs(resultsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * reagent.count)
					end

					if tradeID == 1000001 then					-- vendor conversion
						local vendorQueue = shoppingQueueData.vendor
						vendorQueue[itemID] = (vendorQueue[itemID] or 0) + reagent.count

						if vendorQueue[itemID] == 0 then
							vendorQueue[itemID] = nil
						end
					end
				end
			end

--print("adjusting recipe iteration count and reserved",GnomeWorks:GetRecipeName(entry.recipeID))
			if not entry.manualEntry then
				for itemID in pairs(entry.reserved) do
--if itemID == 43122 or entry.itemID == 43122 then
--	print("    ",(GetItemInfo(itemID)),entry.count, entry.reserved[itemID])
--end
					entry.count = math.min(entry.count, math.floor(entry.reserved[itemID]/(reagents[itemID] or 1)))
				end
			end
		end

		return adjustments
	end



	local function PreventOverBuy(player, entry)
		if entry.subGroup then
			local count = entry.count
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			for itemID, numNeeded in pairs(reagents) do
				entry.reserved[itemID] = entry.reserved[itemID] - (numNeeded * count)
			end

			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]


--			for k,reagent in ipairs(entry.subGroup.entries) do
			for k=#entry.subGroup.entries,1,-1 do
				local reagent = entry.subGroup.entries[k]

				local itemID = reagent.itemID

				if entry.reserved[itemID]>0 then

					if reagent.command == "collect" then
						local sourceQueue

						if reagent.source then
							sourceQueue = shoppingQueueData[reagent.source]
						elseif GnomeWorks:VendorSellsItem(reagent.itemID) then
							sourceQueue = shoppingQueueData.vendor
						else
							sourceQueue = shoppingQueueData.auction
						end

						if sourceQueue[itemID] then
							if entry.reserved[itemID] > reagent.count then
								entry.reserved[itemID] = entry.reserved[itemID] - reagent.count

								sourceQueue[itemID] = sourceQueue[itemID] - reagent.count

								reagent.count = 0
							else
								sourceQueue[itemID] = sourceQueue[itemID] - entry.reserved[itemID]
								reagent.count = reagent.count - entry.reserved[itemID]
							end
						end
					elseif reagent.command == "create" then
						PreventOverBuy(player, reagent)
					end
				end
			end
		end
	end


	local function CalculateTotalReagents(player, entry, dataTable)

		if entry.subGroup then
			local count = entry.count
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			for itemID, numNeeded in pairs(reagents) do
				dataTable[itemID] = (dataTable[itemID] or 0) + (numNeeded*count - (entry.reserved[itemID] or 0))
			end

			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]


--			for k,reagent in ipairs(entry.subGroup.entries) do
			for k=#entry.subGroup.entries,1,-1 do
				local reagent = entry.subGroup.entries[k]

				local itemID = reagent.itemID

				if count>0 then
					if reagent.command == "create" then
						CalculateTotalReagents(player, reagent, dataTable)
					end
				end
			end
		end
	end


	local function CalculateQueueCosts(player, entry)
		if entry.subGroup then
			local count = entry.count
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			local cost = 0

--			for k,reagent in ipairs(entry.subGroup.entries) do
			for k=#entry.subGroup.entries,1,-1 do
				local reagent = entry.subGroup.entries[k]

				local itemID = reagent.itemID

				if (entry.reserved[itemID] or 0)>0 then
					if reagent.command == "collect" then
						if reagent.source then
							reagent.cost = 0
						elseif GnomeWorks:VendorSellsItem(itemID) then
							reagent.cost = GnomeWorks:GetVendorCost(itemID) * reagent.count
						else
							reagent.cost = GnomeWorks:GetAuctionCost(itemID, reagent.count)
						end

						cost = cost + reagent.cost

					elseif reagent.command == "create" then
						cost = cost + CalculateQueueCosts(player, reagent)
					end
				end
			end

			return cost
		end

		return 0
	end


	local function GetSkillLevels(id)
		local gray = GnomeWorks.data.recipeSkillLevels[3][id] or 1
		local yellow = GnomeWorks.data.recipeSkillLevels[2][id] or 1
		local orange = GnomeWorks.data.recipeSkillLevels[1][id] or 1

		local green = math.ceil((gray + yellow)/2)

		return orange, yellow, green, gray
	end


	local function CalculateQueueSkillups(player, entry, tradeTable)
		if entry.subGroup then
			for k,reagent in ipairs(entry.subGroup.entries) do
				if reagent.command == "create" then
					 CalculateQueueSkillups(player, reagent, tradeTable)
				end
			end
		end

		if entry.command == "create" then
			local count = entry.count
			local factor = GnomeWorksDB.skillUps[entry.recipeID] or 1

			local results,reagents,tradeID = GnomeWorks:GetRecipeData(entry.recipeID,player)

			local orange, yellow, green, gray = GetSkillLevels(entry.recipeID)

			local rank, maxRank, estimatedRank, bonus = GnomeWorks:GetTradeSkillRank(player, tradeID)

			if rank >= maxRank then
				return
			end


			local effectiveRank = rank - bonus

			if not tradeTable[tradeID] then
				tradeTable[tradeID] = rank
			end


			if effectiveRank + count*factor < yellow then
				tradeTable[tradeID] = tradeTable[tradeID] + count*factor
			elseif effectiveRank >= gray then
				-- nothing
			else
				while count>0 do
					local rank = tradeTable[tradeID] - bonus

					if effectiveRank >= gray then
						count = 0
					elseif effectiveRank < yellow then
						rank = rank + factor
						count = count - 1
					elseif effectiveRank >= yellow and effectiveRank < green then
						local chance =  1-(effectiveRank-yellow+1)/(effectiveRank-yellow+1)*.5
						count = count - (1/chance)
						if count >= 0 then
							rank = rank + 1
						end
					else
						local chance = (1-(effectiveRank-green+1)/(effectiveRank-green+1))*.5
						count = count - (1/chance)
						if count >= 0 then
							rank = rank + 1
						end
					end

					tradeTable[tradeID] = rank
				end
			end
		end
	end



	local sourceScore = {
		["bank"] = 0,
		["guildBank"] = 1,
		["alt"] = 2,
	}

	local function OptimalPriceQueueSort(a,b)
		if a.itemID == b.itemID then
			if a.cost == b.cost then
				return (sourceScore[a.source or ""] or 3) <  (sourceScore[b.source or ""] or 3)
			else
				return a.cost < b.cost
			end
		else
			return a.itemID < b.itemID
		end
	end



	local function UpdateQueue(player, queue)
		local AdjustCountsTime = 0
		local CalculateQueueSkillUpsTime = 0
		local CalculateQueueCostsTime = 0
		local adjustments = 0
		local invTime = 0
		local reagentTime = 0
		local reserveTime = 0
		local reserveCount = 0

		if queue then
			queue.reagentTree = table.wipe(queue.reagentTree or {})
			queue.totalReagents = table.wipe(queue.totalReagents or {})

			for k,entry in ipairs(queue) do
				entry.parent = queue

				if entry.command == "create" then
local start = GetTime()
					entry.numCraftable = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "bag queue")
invTime = invTime + GetTime()-start

local start = GetTime()
					adjustments = adjustments + AdjustQueueCounts(player, entry)
AdjustCountsTime = AdjustCountsTime + GetTime() - start

					for reagentID, numNeeded in pairs(entry.reagentTree) do
						queue.reagentTree[reagentID] = (queue.reagentTree[reagentID] or 0) + numNeeded
					end


					CalculateTotalReagents(player,entry,queue.totalReagents)

--					PreventOverBuy(player, entry)
local start = GetTime()
					CalculateQueueCosts(player, entry)
CalculateQueueCostsTime = CalculateQueueCostsTime + GetTime() - start

local start = GetTime()
					if GnomeWorksDB.config.displayOptions.estimateLevel then
						CalculateQueueSkillups(player, entry, GnomeWorks.data.skillUpRanks)
					end
CalculateQueueSkillUpsTime = CalculateQueueSkillUpsTime + GetTime() - start

--					table.sort(entry.subGroup.entries, OptimalPriceQueueSort)

local start = GetTime()
					local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)


					for k,reagent in ipairs(entry.subGroup.entries) do
						if reagent.command == "missing" then
							if not GnomeWorks:VendorSellsItem(reagent.itemID) then

								reagent.count = entry.count * (reagents[reagent.itemID] or 0) - math.max(entry.reserved[reagent.itemID],0)
							else
								reagent.count = 0
							end
						end
					end
reagentTime = reagentTime + GetTime() - start

local start = GetTime()
					for itemID,numNeeded in pairs(reagents) do
						reserveCount = reserveCount + 1
						GnomeWorks:ReserveItemForQueue(player, itemID, numNeeded * entry.count)
					end
reserveTime = reserveTime + GetTime() - start
--					for itemID,numMade in pairs(results) do
--						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * entry.count)
--					end
				end
			end
		end
--[[
		print("CalculateQueueSkillups",CalculateQueueSkillUpsTime)
		print("CalculateQueueCosts",CalculateQueueCostsTime)
		print("AdjustCounts",AdjustCountsTime)
		print("inv", invTime)
		print("reagent", reagentTime)
		print("reserve", reserveTime, reserveCount)
		print("total adjustments",adjustments)
]]
	end


	local function SortQueue(player, queue)
		if queue then
			for k,entry in ipairs(queue) do
				if entry.command == "create" then
					table.sort(entry.subGroup.entries, function(a,b)
						if a.itemID == b.itemID then
							if a.cost == b.cost then
								return (a.source or "ah") < (b.source or "ah")
							else
								return a.cost < b.cost
							end
						else
							return a.itemID < b.itemID
						end
					end)
				end
			end
		end
	end



	local function ZeroQueue(queue)
		if queue then
			for k,q in ipairs(queue) do
				q.count = 0

				if q.subGroup then
					ZeroQueue(q.subGroup.entries)
				end
			end
		end
	end



	local function InitRecipeEntry(index, recipeID, reagentID, count, numNeeded)
		local newEntry = {
			index = index,
			recipeID = recipeID,
			count = count,

			itemID = reagentID,
			numNeeded = numNeeded,

			command = "create",

			reserved = {},

			priority = GnomeWorks:GetRecipePriority(recipeID),

			reagentTree = {},
--			noHide = true,
		}

		if GnomeWorksDB.reagents[recipeID] then
			for itemID, numNeeded in pairs(GnomeWorksDB.reagents[recipeID]) do
				local needed = count * numNeeded

				newEntry.reagentTree[itemID] = numNeeded * count

				newEntry.reserved[itemID] = math.min(needed, GnomeWorks:GetInventoryCount(itemID, GnomeWorks.player, "bag queue"))
			end
		end


		return newEntry
	end


	local function InitReagentEntry(index, reagentID, numNeeded, count, source)
		local newEntry = {
			index = index,
			command = "collect",
			itemID = reagentID,
			numNeeded = numNeeded,
			count=count,
			source=source,
		}
		return newEntry
	end


	local function AddEntryToQueue(entry, queueData)
		local queueAdded

		for i=1,#queueData do
			if entry.command == "create" and queueData[i].command == "create" and queueData[i].recipeID == entry.recipeID then
				local results,reagents = GnomeWorks:GetRecipeData(queueData[i].recipeID,player)

				queueData[i].count = queueData[i].count + entry.count

				queueData[i].numNeeded = queueData[i].count * results[queueData[i].itemID]

				queueData[i].control[#queueData[i].control+1] = entry

				queueAdded = true

				break
			end

			if entry.command == "collect" and queueData[i].command == "collect" and queueData[i].itemID == entry.itemID and queueData[i].source == entry.source then
				queueData[i].count = queueData[i].count + entry.count

				queueData[i].control[#queueData[i].control+1] = entry

				queueAdded = true
			end
		end

		if not queueAdded then
			local newEntry = {
				index = #queueData,
				command = entry.command,
				itemID = entry.itemID,
				recipeID = entry.recipeID,
				source = entry.source,
				count = entry.count,
				control = {entry},
				manualEntry = entry.manualEntry,

				reagentTree = entry.reagentTree,
			}

			queueData[#queueData+1] = newEntry
		end
	end



	local recursionLimiter = {}
	local cooldownUsed = {}

	local function AddReagentToQueue(queue, reagentID, numNeeded, player)
		if not reagentID then return nil, 0 end

		if recursionLimiter[reagentID] then return nil, 0 end

		recursionLimiter[reagentID] = true

		local source = GnomeWorks.data.itemSource

		local collectInventories = GnomeWorksDB.config.collectInventories


		local stillNeeded = numNeeded - GnomeWorks:GetInventoryCount(reagentID, player, "bag")

		for k,inv in pairs(collectInventories) do
			local numAvailable = LARGE_NUMBER

			if inv ~= "alt" then
				numAvailable = GnomeWorks:GetInventoryCount(reagentID, player, inv)
			else
				numAvailable = GnomeWorks:GetFactionInventoryCount(reagentID, player)
			end

			if numAvailable > stillNeeded then
				numAvailable = stillNeeded
			end


			table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, numAvailable,inv))


			stillNeeded = stillNeeded - numAvailable

--				stillNeeded = stillNeeded - GnomeWorks:GetInventoryCount(reagentID, player, inv)

			if stillNeeded < 0 then
				stillNeeded = 0
			end
		end


		if source[reagentID] then
			local craftingOptions = 0

--[[
			for recipeID, numMade in pairs(source[reagentID]) do
				if GnomeWorks:IsSpellKnown(sourceRecipeID, player) then
					craftingOptions = craftingOptions + 1
				end
			end
]]

			local craftOptions = {}


-- add recipe sources:
			for recipeID,numMade in pairs(source[reagentID]) do
				if numMade > .1 then
					local cooldownGroup = GnomeWorks:GetSpellCooldownGroup(recipeID)

					local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

					if not cooldownGroup and GnomeWorks:IsSpellKnown(recipeID, player) and not GnomeWorksDB.recipeBlackList[recipeID] and not GnomeWorksDB.recipeBlackList[tradeID] then -- and not cooldownUsed[cooldownGroup] then
						local recursive

						if reagents then
							for reagentID,numNeeded in pairs(reagents) do
								if recursionLimiter[reagentID] then
									recursive = true
									break
								end
							end
						end

						if not recursive then
							local count = math.ceil(numNeeded / numMade)

							local queueEntry = InitRecipeEntry(#craftOptions+1, recipeID, reagentID, count, numNeeded)

							table.insert(craftOptions, queueEntry)

							if reagents then
								queueEntry.subGroup = {expanded = false, entries = {} }

								for reagentID,numNeeded in pairs(reagents) do
									AddReagentToQueue(queueEntry, reagentID, numNeeded * count, player)
								end
							end
						end
					end
				end
			end


			for recipeID,numMade in pairs(source[reagentID]) do
				if numMade > .1 then

					local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

					if GnomeWorks:IsSpellKnown(recipeID, player) and not GnomeWorksDB.recipeBlackList[recipeID] and not GnomeWorksDB.recipeBlackList[tradeID] then
						local cooldownGroup = GnomeWorks:GetSpellCooldownGroup(recipeID)

						if cooldownGroup then
							cooldownUsed[cooldownGroup] = true
						end
					end
				end
			end

			if #craftOptions>0 then
				table.sort(craftOptions, function(a,b)
					if a.priority < b.priority then
						return false
					elseif a.priority > b.priority then
						return true
					else
						return a.recipeID < b.recipeID
					end
				end)

				local indexStart = #queue.subGroup.entries

				for i=1,#craftOptions do
					craftOptions[i].index = i + indexStart

					table.insert(queue.subGroup.entries, craftOptions[i])

					queue.subGroup.entries[i].parent = queue.subGroup.entries
				end
			end

		end

		table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded))


--		if cooldownGroup then
--			cooldownUsed[cooldownGroup] = nil
--		end

		recursionLimiter[reagentID] = nil

--		return newEntry, count
	end


	local function CreateQueue(player, recipeID, count, sourcePlayer, index)
		local results,reagents,tradeID = GnomeWorks:GetRecipeData(recipeID,player)
		local itemID, numMade = next(results)

		local queue = {
			index = index,
			recipeID = recipeID,
			count = count,
			tradeID = tradeID,
			sourcePlayer = sourcePlayer,
			manualEntry = true,

			numNeeded = count * numMade,
			itemID = itemID,
			noHide = true,

			command = "create",

			reserved = {},

			reagentTree = {},
		}

		for itemID, numNeeded in pairs(reagents) do
			local needed = count * numNeeded * numMade

			queue.reserved[itemID] = math.min(needed, GnomeWorks:GetInventoryCount(itemID, queuePlayer, "bag queue"))
		end

		if reagents then
			queue.subGroup = {expanded = false, entries = {} }

			for reagentID,numNeeded in pairs(reagents) do
				AddReagentToQueue(queue, reagentID, numNeeded * count, queuePlayer)

				local missingItems = {
					index = #queue.subGroup.entries,
					count = 10,
					itemID = reagentID,

					command = "missing",
				}

				queue.subGroup.entries[#queue.subGroup.entries+1] = missingItems
			end
		end

		return queue
	end




	function GnomeWorks:ExecuteAddToQueue(player, tradeID, recipeID, count)
		local sourcePlayer

		if not self.data.playerData[player] then
			sourcePlayer = player
			player = queuePlayer
		end

		local queueData = self.data.queueData[player]

		local queueAdded

		for i=1,#queueData do
			if queueData[i].recipeID == recipeID then
				if queueData[i].sourcePlayer == sourcePlayer then
					local results,reagents = GnomeWorks:GetRecipeData(queueData[i].recipeID,player)

					queueData[i].count = queueData[i].count + count

					queueData[i].numNeeded = queueData[i].count * results[queueData[i].itemID]

					queueAdded = true

					break
				end
			end
		end

		if not queueAdded then
			local newQueue = CreateQueue(player, recipeID, count, sourcePlayer, #queueData)

			newQueue.parent = queueData

			table.insert(queueData, newQueue)
		end
	end


	local function ProcessQueueQueue()
		if #queueQueue > 0 then
			for i=1,50 do
				if #queueQueue > 0 then
					local entry = table.remove(queueQueue,1)

					GnomeWorks:ExecuteAddToQueue(unpack(entry))
				else
					break
				end
			end

			GnomeWorks:SendMessageDispatch("QueueChanged")
		end
	end


	local queueQueueTimer
	function GnomeWorks:AddToQueue(player, tradeID, recipeID, count)
		local entry = { player, tradeID, recipeID, count }

		queueQueue[#queueQueue+1] = entry

		if not queueQueueTimer then
			queueQueueTimer = GnomeWorks:ScheduleRepeatingTimer(ProcessQueueQueue, 0.01)
		end
	end





	local function BuildSourceQueues(player, queue)
		if queue then
			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]

			for k,entry in ipairs(queue) do
				if entry.command == "collect" then
					local sourceQueue

					if not entry.source then
						if GnomeWorks:VendorSellsItem(entry.itemID) then
							sourceQueue = shoppingQueueData.vendor
						else
							sourceQueue = shoppingQueueData.auction
						end
					else
						sourceQueue = shoppingQueueData[entry.source]
					end


					if sourceQueue then
						sourceQueue[entry.itemID] = (sourceQueue[entry.itemID] or 0) + entry.count

						if sourceQueue[entry.itemID] == 0 then
							sourceQueue[entry.itemID] = nil
						end
					end

				elseif entry.command == "create" then
					local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

					local vendorQueue = shoppingQueueData.vendor

					if tradeID == 1000001 then					-- vendor conversion
						vendorQueue[entry.itemID] = (vendorQueue[entry.itemID] or 0) + entry.count

						if vendorQueue[entry.itemID] == 0 then
							vendorQueue[entry.itemID] = nil
						end
					end
				end

				if entry.subGroup then
					BuildSourceQueues(player, entry.subGroup.entries)
				end
			end
		end
	end



	local function BuildFlatQueue(flatQueue, queue)
		for k,entry in ipairs(queue) do
			if entry.subGroup then
				BuildFlatQueue(flatQueue, entry.subGroup.entries)
			end

			if entry.count > 0 then
--print("add",(GetItemInfo(entry.itemID)),entry.count,entry.source)
				AddEntryToQueue(entry,flatQueue)
			end
		end
	end


	function GnomeWorks:ShowQueueList(player)
		local start = GetTime()

		local rank, maxRank, estimatedSkillUp = self:GetTradeSkillRank()

		local player = player or (self.data.playerData[self.player] and self.player) or UnitName("player")
		queuePlayer = player

		table.wipe(GnomeWorks.data.skillUpRanks)

		if player then
local start = GetTime()
			frame.playerNameFrame:SetFormattedText("%s Queue",player)

			if not self.data.queueData[player] then
				self.data.queueData[player] = {}
			end

			local queue = self.data.queueData[player]

			if not sf.data then
				sf.data = {}
			end

			self.data.inventoryData[player].queue = table.wipe(self.data.inventoryData[player].queue or {})

			for shoppingList,data in pairs(self.data.shoppingQueueData[player]) do
				table.wipe(data)
			end
--print("init", GetTime()-start)

local start = GetTime()
			UpdateQueue(player, self.data.queueData[player])
--print("update queue", GetTime()-start)

--			BuildSourceQueues(player, self.data.queueData[player])

local start = GetTime()
			if not self.data.flatQueue then
				self.data.flatQueue = {}
			end

			self.data.flatQueue[player] = table.wipe(self.data.flatQueue[player] or {})

			BuildFlatQueue(self.data.flatQueue[player], queue)

			self:SendMessageDispatch("QueueCountsChanged")

			if GnomeWorksDB.config.queueLayoutFlat then
				sf.data.entries = self.data.flatQueue[player]
			else
				sf.data.entries = self.data.queueData[player]
			end
--print("flat layout", GetTime()-start)

--			queue.reagentTree = table.wipe(queue.reagentTree or {})

--[[
			for i=1,#queue do
				for itemID, numNeeded in pairs(queue[i].reagentTree) do
					queue.reagentTree[itemID] = (queue.reagentTree[itemID] or 0) + numNeeded
				end
			end
]]
local start = GetTime()
			GnomeWorks:ShoppingListUpdate(player)
--print("shopping list update", GetTime()-start)

--			GnomeWorks:PrepAuctionScan(queue)

local start = GetTime()
			local newRank, _, newEstimatedSkillUp = self:GetTradeSkillRank()

			if newRank ~= rank or newEstimatedSkillUp ~= estimatedSkillUp then
				self:SendMessageDispatch("SkillRanksChanged")
			end
--print("skill ranks changed", GetTime()-start)


local start = GetTime()
			sf:Refresh()
--print("refresh data", GetTime()-start)

--			sf:Show()
local start = GetTime()
			frame:Show()
			frame:SetToplevel(true)
--print("show data", GetTime()-start)
		end

--		print("total time", GetTime()-start)
	end


	local function FirstCraftableEntry(queue)
		if queue then
			for k,q in ipairs(queue) do
				if q.subGroup then
					local first,count = FirstCraftableEntry(q.subGroup.entries)

					if first then
						return first,count
					end
				end

				if q.command == "create" and (q.count or 0) > 0 then
					local count = GnomeWorks:InventoryRecipeIterations(q.recipeID, queuePlayer)
					if count>0 then
						return q, count
					end
				end
			end
		end
	end

	local function DeleteQueueEntry(queue, entry)
		for k,q in ipairs(queue) do
			if q == entry then
				table.remove(queue, k)
				return true
			end

			if q.subGroup then
				if DeleteQueueEntry(q.subGroup.entries, entry) then
					return true
				end
			end
		end
	end


	function GnomeWorks:SpellCastFailed(event,unit,spell,rank)
--print("SPELL CAST FAILED", ...)
		if unit == "player" then
			doTradeEntry = nil
			GnomeWorks.isProcessing = false
			self:SendMessageDispatch("TradeProcessing")
		end
	end


	function GnomeWorks:SpellCastCompleted(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST COMPLETED")
--print(event,unit,spell,rank,lineID,spellID)


		if unit == "player"	and doTradeEntry then
			local _,_,recipeTradeID = GnomeWorks:GetRecipeData(doTradeEntry.recipeID)

			local recipeID = doTradeEntry.recipeID

			local pseudoTrade = GnomeWorks.data.pseudoTradeData[recipeTradeID]

			if pseudoTrade and pseudoTrade.SpellCastCheck and pseudoTrade.SpellCastCheck(recipeID, spellID) then
				recipeID = spellID
			end

			if spellID == recipeID then
				if doTradeEntry.manualEntry then
					local entry = doTradeEntry

					if doTradeEntry.control then
						entry = doTradeEntry.control[1]
					end

					entry.count = entry.count - 1

					if entry.count == 0 then
						DeleteQueueEntry(self.data.queueData[queuePlayer], entry)

						if doTradeEntry.control then
							table.remove(doTradeEntry.control,1)

							if #doTradeEntry.control == 0 then
								doTradeEntry = nil
								GnomeWorks.processSpell = nil

								GnomeWorks.isProcessing = false
								self:SendMessageDispatch("TradeProcessing")
							end
						else
							doTradeEntry = nil
							GnomeWorks.processSpell = nil

							GnomeWorks.isProcessing = false
							self:SendMessageDispatch("TradeProcessing")
						end
					end
				else
					if doTradeEntry.count < 1 then
						StopTradeSkillRepeat()
					end
				end

				self:ShowQueueList()
			elseif spellID == recipeTradeID then
				if GnomeWorks:IsPseudoTrade(spellID) then
					local entry = doTradeEntry

					if doTradeEntry.control then
						entry = doTradeEntry.control[1]
					end

					entry.count = entry.count - 1

					if doTradeEntry.manualEntry then

						if entry.count == 0 then
							DeleteQueueEntry(self.data.queueData[queuePlayer], entry)

							if doTradeEntry.control then
								table.remove(doTradeEntry.control,1)

								if #doTradeEntry.control == 0 then
									doTradeEntry = nil
									GnomeWorks.processSpell = nil

									GnomeWorks.isProcessing = false
								end
							else
								doTradeEntry = nil
								GnomeWorks.processSpell = nil

								GnomeWorks.isProcessing = false
							end
						end
					end

					GnomeWorks:ShowQueueList()
					self:SendMessageDispatch("TradeProcessing")
				end
			end
		end
	end


	function GnomeWorks:SpellCastStop(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST START", spellID, doTradeEntry and doTradeEntry.recipeID)

		if unit == "player" then
			GnomeWorks.isProcessing = false
			self:SendMessageDispatch("TradeProcessing")
		end
	end


	function GnomeWorks:SpellCastStart(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST START", spellID, doTradeEntry and doTradeEntry.recipeID)

		if unit == "player"	and doTradeEntry and spellID == doTradeEntry.recipeID then

			CURRENT_TRADESKILL = GetTradeSkillLine()

			GnomeWorks.isProcessing = true
			self:SendMessageDispatch("TradeProcessing")
		end
	end


	local function CreateControlButtons(frame)
		local function ProcessQueue()
			local entry, craftable

			if GnomeWorksDB.config.queueLayoutFlat then
				entry, craftable = FirstCraftableEntry(GnomeWorks.data.flatQueue[queuePlayer])
			else
				entry, craftable = FirstCraftableEntry(GnomeWorks.data.queueData[queuePlayer])
			end



			if entry then
--				local tradeID = GnomeWorksDB.tradeIDs[entry.recipeID]
				local _,_,tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

				local numRepeat = math.min(craftable, entry.count)

				if GnomeWorks:IsPseudoTrade(tradeID) then
--					GnomeWorks:print(GnomeWorks:GetTradeName(tradeID),"isn't functional yet.")
					local pseudoTrade = GnomeWorks.data.pseudoTradeData[tradeID]


					if pseudoTrade and pseudoTrade.DoTradeSkill then
						doTradeEntry = entry


						if not GnomeWorks.MainWindow:IsVisible() then
							GnomeWorks.hideMainWindow = true
             			end

						local result = pseudoTrade.DoTradeSkill(entry.recipeID, entry.count)

						if result then
							if entry.manualEntry then
								DeleteQueueEntry(GnomeWorks.data.queueData[queuePlayer], entry)
							end
						end
					end
				else
--				print(entry.recipeID, GnomeWorks:GetRecipeName(entry.recipeID), entry.count, entry.numAvailable)
					if GetSpellLink((GetSpellInfo(tradeID))) then
						if GnomeWorks:IsTradeSkillLinked() or GnomeWorks.player ~= UnitName("player") or GnomeWorks.tradeID ~= tradeID or GetFirstTradeSkill()==0 then
							if not GnomeWorks.MainWindow:IsVisible() then
								GnomeWorks.hideMainWindow = true
							end

							CastSpellByName((GetSpellInfo(tradeID)))
						end

						local skillIndex

						local enchantString = "enchant:"..entry.recipeID.."|h"

						for i=1,GetNumTradeSkills() do
							local link = GetTradeSkillRecipeLink(i)

							if link and string.find(link, enchantString) then

								skillIndex = i
								break
							end
						end

						if skillIndex then
							doTradeEntry = entry
							GnomeWorks:print("executing",GnomeWorks:GetRecipeName(entry.recipeID),"x",numRepeat)
							DoTradeSkill(skillIndex,numRepeat>=1 and numRepeat)
						else
							doTradeEntry = nil
							GnomeWorks:print("can't find recipe:",GnomeWorks:GetRecipeName(entry.recipeID))
						end

	--					GnomeWorks:ProcessRecipe(tradeID, entry.recipeID, math.max(entry.count, entry.numAvailable))
					else
						GnomeWorks:print("can't process",GnomeWorks:GetRecipeName(entry.recipeID),"on this character")
					end
				end
			else
				GnomeWorks:print("nothing craftable")
			end
		end


		local function ClearQueue()
			table.wipe(GnomeWorks.data.queueData[queuePlayer])
			table.wipe(GnomeWorks.data.inventoryData[queuePlayer].queue)
			for inv, data in pairs (GnomeWorks.data.craftabilityData[queuePlayer]) do
				table.wipe(data)
			end

			table.wipe(GnomeWorks.data.skillUpRanks)

			GnomeWorks:InventoryProcess()
			GnomeWorks:SendMessageDispatch("QueueChanged SkillRanksChanged SkillListChanged")
		end


		local function StopProcessing()
			StopTradeSkillRepeat()
		end


		local buttons = {}

		local function ConfigureButton(button)
--print("configure button")
			local entry, craftable

			if GnomeWorksDB.config.queueLayoutFlat then
				if not GnomeWorks.data.flatQueue or not GnomeWorks.data.flatQueue[queuePlayer] then
					return
				end

				entry, craftable = FirstCraftableEntry(GnomeWorks.data.flatQueue[queuePlayer])

				if entry then
					entry.numCraftable = craftable
				end
			else
				entry, craftable = FirstCraftableEntry(GnomeWorks.data.queueData[queuePlayer])
			end

			if GnomeWorks.isProcessing then
				button:SetFormattedText("Processing...")
				button:Disable()
				button:Show()

				if not InCombatLockdown() then
					button.secure:Hide()
				end

				EditMacro("GWProcess", "GWProcess", 977, "", false, false)
			elseif entry then
				local _,_,tradeID = GnomeWorks:GetRecipeData(entry.recipeID)
--print(entry.count)

				local count = math.max(math.min(craftable or 1,entry.count or 1),1)

				button:SetFormattedText("Process %s x %d",GnomeWorks:GetRecipeName(entry.recipeID) or "spell:"..entry.recipeID,count)
				button:Enable()

				local pseudoTrade = GnomeWorks.data.pseudoTradeData[tradeID]

				local macroText

				if pseudoTrade and pseudoTrade.ConfigureMacroText then
					macroText = pseudoTrade.ConfigureMacroText(entry.recipeID)
					doTradeEntry = entry

					if not InCombatLockdown() then
						button.secure:Show()
						local scale = button:GetEffectiveScale()/button.secure:GetEffectiveScale()
						local bottom = button:GetBottom()*scale
						local top = button:GetTop()*scale
						local left = button:GetLeft()*scale
						local right = button:GetRight()*scale

						button.secure:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",left,top)
						button.secure:SetPoint("BOTTOMRIGHT","UIParent","BOTTOMLEFT",right,bottom)

						button.secure:SetAttribute("type", "macro")
						button.secure:SetAttribute("macrotext", macroText)

					end

					EditMacro("GWProcess", "GWProcess", 977, macroText, false, false)				-- 97, 7
				elseif tradeID then
					button:SetScript("OnClick", ProcessQueue)

					if not InCombatLockdown() then
						button.secure:Hide()
						button.secure:ClearAllPoints()

						EditMacro("GWProcess", "GWProcess", 977, "/click GWProcess", false, false)
					end
				else
					print("tradeID is nil for entry", entry, entry.recipeID)
				end
			else
				button:Disable()

				if not InCombatLockdown() then
					button.secure:Hide()
					button.secure:ClearAllPoints()
				end

				button:SetText("Nothing To Process")
			end
		end

		local function BeginAuctionScan()
			GnomeWorks:BeginReagentScan()
		end

		local function CancelAuctionScan()
			GnomeWorks:StopReagentScan()
		end

		local function ConfigureAuctionButton(button)

			if GnomeWorks.atAuctionHouse then
				if GnomeWorks.auctionScanning then
					button:SetText("Cancel Auction Scan")
					button:SetScript("OnClick", CancelAuctionScan)
				else
					button:SetText("Scan Auctions")
					button:SetScript("OnClick", BeginAuctionScan)
				end

				button:Enable()
			else
				button:SetText("Scan Auctions")
				button:Disable()
			end
		end


		local buttonConfig = {
--			{ text = "Process", operation = ProcessQueue, width = 250, validate = SetProcessLabel, lineBreak = true, template = "SecureActionButtonTemplate" },
			{ text = "Nothing To Process", name = "GWProcess", width = 250, validate = ConfigureButton, lineBreak = true, addSecure=true, template = "SecureActionButtonTemplate",
						updateEvent = "QueueCountsChanged QueueChanged TradeProcessing InventoryScanComplete HeartBeat FrameMoved" },
			{ text = "Stop", operation = StopProcessing, width = 125 },
			{ text = "Clear", operation = ClearQueue, width = 125, lineBreak = true },
			{ text = "Scan Auctions", width = 250, validate = ConfigureAuctionButton, updateEvent = "HeartBeat AuctionScanComplete" }
		}



		local position = 0
		local line = 0

		local eventTable = { }

		local controlFrame = CreateFrame("Frame", nil, frame)


--		controlFrame:SetPoint("LEFT",20,0)
--		controlFrame:SetPoint("RIGHT",-20,0)


		for i, config in pairs(buttonConfig) do
			if not config.style or config.style == "Button" then
--				local newButton = CreateFrame("Button", nil, controlFrame, "UIPanelButtonTemplate")

				local newButton = GnomeWorks:CreateButton(controlFrame, 18, nil, config.name)

				if config.addSecure then
					newButton.secure = CreateFrame("Button",(config.name or config.text).."Secure", UIParent, config.template)

					newButton.secure:SetFrameStrata("HIGH")
					newButton.secure:SetFrameLevel(newButton.secure:GetFrameLevel()+128)

--newButton.secure:SetNormalTexture("Interface\\Buttons\\UI-Listbox-Highlight")

--					newButton.secure:SetAllPoints(newButton)

					newButton.secure:HookScript("OnEnter", function(b) newButton.state.Highlight:Show() end)
					newButton.secure:HookScript("OnLeave", function(b) newButton.state.Highlight:Hide() end)

					newButton.secure:HookScript("OnMouseDown", function(b) if newButton:IsEnabled() then newButton.state.Down:Show() newButton.state.Up:Hide() end end)
					newButton.secure:HookScript("OnMouseUp", function(b) if newButton:IsEnabled() then newButton.state.Down:Hide() newButton.state.Up:Show() end end)
				end


				newButton:SetPoint("LEFT", position,-line*20)
				if config.width then
					newButton:SetWidth(config.width)
				else
					newButton:SetPoint("RIGHT")
					line = line + 1
				end


				newButton:SetNormalFontObject("GameFontNormalSmall")
				newButton:SetHighlightFontObject("GameFontHighlightSmall")
				newButton:SetDisabledFontObject("GameFontDisableSmall")

				newButton:SetText(config.text)

				if config.operation then
					newButton:SetScript("OnClick", config.operation)
				end

				newButton.validate = config.validate

				buttons[i] = newButton


				if newButton.validate then
--					newButton:validate()
				end


				position = position + (config.width or 0)
			else
				local newButton = CreateFrame(config.style, nil, controlFrame)

				newButton:SetPoint("LEFT", position,line*20)
				if config.width then
					newButton:SetWidth(config.width)
				else
					newButton:SetPoint("RIGHT")
					line = line + 1
				end
				newButton:SetHeight(18)
				newButton:SetFontObject("GameFontHighlightSmall")
--				newButton:SetHighlightFontObject("GameFontHighlightSmall")

--				newButton:SetText(config.text or "")

				newButton.validate = config.validate

				if config.style == "EditBox" then
					newButton:SetAutoFocus(false)

					newButton:SetNumeric(true)

--					newButton:SetScript("OnEnterPressed", EditBox_ClearFocus)
					newButton:SetScript("OnEscapePressed", EditBox_ClearFocus)
					newButton:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
					newButton:SetScript("OnEditFocusGained", EditBox_HighlightText)


					newButton:SetScript("OnEnterPressed", function(f)
						local n = f:GetNumber()

						if n<=0 then
							f:SetNumber(1)

							buttons[1].count = 1
							buttons[2].count = 1
						else
							buttons[1].count = n
							buttons[2].count = n
						end

						EditBox_ClearFocus(f)
					end)

					newButton:SetJustifyH("CENTER")
					newButton:SetJustifyV("CENTER")

					local searchBackdrop  = {
							bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
							edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
							tile = true, tileSize = 16, edgeSize = 16,
							insets = { left = 10, right = 10, top = 8, bottom = 10 }
						}

					self.Window:SetBetterBackdrop(newButton, searchBackdrop)

					buttons[1].count = config.default
					buttons[2].count = config.default

--					newButton:SetNumber()

					newButton:SetText("")
					newButton:SetMaxLetters(4)

				end

				buttons[i] = newButton

				position = position + (config.width or 0)
			end

			if config.lineBreak then
				line = line + 1
				position = 0
			end

			if config.updateEvent then
				eventTable[#eventTable+1] = config.updateEvent
			end
		end

		controlFrame:SetHeight(line*20)
		controlFrame:SetWidth(position)

		local eventList = table.concat(eventTable," ")

		GnomeWorks:RegisterMessageDispatch(eventList, function()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end, "ValidateQueueButtons")

		return controlFrame
	end




	local function OpQueueRecipeSwap(button, a,b)
		CloseDropDownMenus()

		if a and b then
			if a.parent == b.parent then
				local p = a.parent

				if a.index < b.index then
					table.remove(p,b.index)
					table.insert(p,a.index,b)
				else
					table.remove(p,a.index)
					table.insert(p,b.index,a)
				end

				for k,v in ipairs(p) do
					v.index = k
				end

				a.expanded, b.expanded = b.expanded, a.expanded
			else
				if b.control then
					for i,entry in ipairs(b.control) do
--print(i,entry.command,GnomeWorks:GetRecipeName(entry.recipeID))

						if entry.itemID == b.itemID then
							local p = entry.parent
							local swapEntry
							local swapIndex

							for k,subEntry in ipairs(p) do
	--print(i,k,subEntry.command,(GetItemInfo(subEntry.itemID)),subEntry.source)
								if subEntry.command == a.command and subEntry.itemID == a.itemID and subEntry.recipeID == a.recipeID and subEntry.source == a.source then
									swapEntry = subEntry
									swapIndex = k
									break
								end
							end

							if swapEntry then
								table.remove(p,swapIndex)
								table.insert(p,1,swapEntry)

								for k,v in ipairs(p) do
									v.index = k
								end
							else
								print("error reordering recipes!")
							end
						end
					end
				end
			end
		end

		GnomeWorks:SendMessageDispatch("QueueChanged")
	end



	local function OpDeleteQueueEntry(button,entry)
		CloseDropDownMenus()
		local deleted

		local queue = GnomeWorks.data.queueData[queuePlayer]

		if entry.control then
			for k,v in ipairs(entry.control) do
				if DeleteQueueEntry(queue, v) then
					deleted = true
				end
			end
		else
			deleted = DeleteQueueEntry(queue, entry)
		end

		if deleted then
			GnomeWorks:SendMessageDispatch("QueueChanged")
		end
	end


	local function OpMoveQueueEntryToBottom(button,entry)
		if entry.control then
			for k,entry in ipairs(entry.control) do
				OpDeleteQueueEntry(button, entry)
				table.insert(GnomeWorks.data.queueData[queuePlayer], entry)
			end
		else
			OpDeleteQueueEntry(button, entry)
			table.insert(GnomeWorks.data.queueData[queuePlayer], entry)
		end

		GnomeWorks:SendMessageDispatch("QueueChanged")
	end

	local function OpMoveQueueEntryToTop(button,entry)
		if entry.control then
			for k,entry in ipairs(entry.control) do
				OpDeleteQueueEntry(button, entry)
				table.insert(GnomeWorks.data.queueData[queuePlayer], 1, entry)
			end
		else
			OpDeleteQueueEntry(button, entry)
			table.insert(GnomeWorks.data.queueData[queuePlayer], 1, entry)
		end

		GnomeWorks:SendMessageDispatch("QueueChanged")
	end




	local columnHeaders = {
		{
			name = "#",
			align = "CENTER",
			width = 30,
			font = "GameFontHighlightSmall",
			OnClick = function(cellFrame, button, source)
							local rowFrame = cellFrame:GetParent()
							if rowFrame.rowIndex>0 then
								local entry = rowFrame.data
--print(entry.manualEntry)

								if entry.manualEntry then
									if button == "RightButton" then
										entry.count = entry.count - 1
									else
										entry.count = entry.count + 1
									end

									if entry.count < 1 then
										entry.count = 1
									end

									GnomeWorks:SendMessageDispatch("QueueChanged")

--									GnomeWorks:ShowQueueList()
								end
							end
						end,
			OnEnter = function(cellFrame, button)
							local rowFrame = cellFrame:GetParent()
							if rowFrame.rowIndex>0 then
								local entry = rowFrame.data

								local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,GnomeWorks.player)				--GnomeWorksDB.results[entry.recipeID]
--								local reagents = GnomeWorksDB.reagents[entry.recipeID]


								if entry then
									GameTooltip:SetOwner(rowFrame, "ANCHOR_TOPRIGHT")
									GameTooltip:ClearLines()


									if false and entry.itemID then
										GameTooltip:AddLine(select(2,GetItemInfo(entry.itemID)))

										local required = entry.numNeeded
										local deficit = entry.count

										if entry.command == "create" then
											deficit = entry.count * results[entry.itemID]
										end

										local inQueue = deficit + (entry.bag or 0) - entry.numNeeded


										if required>0 then
											local prevCount = 0

											GameTooltip:AddDoubleLine("Required", required)

											GameTooltip:AddLine("Current Stock:",1,1,1)

											local inventoryIndex = GnomeWorksDB.config.inventoryIndex

											for i,key in pairs(inventoryIndex) do
												if key ~= "vendor" then
													local count = entry[key] or 0

													if count ~= prevCount then
														GameTooltip:AddDoubleLine(inventoryTags[key],count)
														prevCount = count
													end
												end
											end

											if entry.command == "create" then
												if entry.numCraftable > 0 then
													GameTooltip:AddDoubleLine("craftable",entry.numCraftable * results[entry.itemID])
													prevCount = entry.numCraftable * results[entry.itemID]
												else
	--													GameTooltip:AddLine("None craftable")
												end
											end

											if inQueue > 0 then
												GameTooltip:AddDoubleLine("|cffff8000reserved",inQueue)
											end

											if prevCount == 0 then
	--												GameTooltip:AddLine("None available")
											end

											if prevCount ~= 0 then
												if deficit > 0 then
													GameTooltip:AddDoubleLine("|cffff0000total deficit:",deficit)
												end
											end


											if entry.reagents then
												GameTooltip:AddLine("")
												GameTooltip:AddLine("Required Reagents:")
												for reagentID,numNeeded in pairs(reagents) do
													GameTooltip:AddDoubleLine("    "..GetItemInfo(reagentID),numNeeded)
												end
											end
										end
									elseif entry.recipeID then
										GameTooltip:AddLine(GetSpellLink(entry.recipeID))
										GameTooltip:AddDoubleLine("Requested", entry.count)
										GameTooltip:AddDoubleLine("Craftable", entry.numCraftable)

										if entry.reagents then
											GameTooltip:AddLine("")
											GameTooltip:AddLine("Required Reagents:")
											for reagentID,numNeeded in pairs(reagents) do
												GameTooltip:AddDoubleLine("    "..GetItemInfo(reagentID),numNeeded)
											end
										end
									end

									GameTooltip:Show()
								end
							end
						end,
			OnLeave = function()
							GameTooltip:Hide()
						end,
			draw =	function (rowFrame,cellFrame,entry)
--print(entry.manualEntry,entry.command, entry.recipeID or entry.itemID, entry.count, entry.numAvailable)

							if entry.command == "create" then
								if entry.numCraftable then
									if entry.numCraftable == 0 then
										cellFrame.text:SetTextColor(1,0,0)
									elseif entry.count > entry.numCraftable then
										cellFrame.text:SetTextColor(.8,.8,0)
									else
										cellFrame.text:SetTextColor(1,1,1)
									end
								else
									cellFrame.text:SetTextColor(1,1,1)
								end
							elseif entry.command == "collect" then
								cellFrame.text:SetTextColor(1,1,1)
							elseif entry.command == "missing" then
								cellFrame.text:SetTextColor(1,0,0)
							end

							cellFrame.text:SetText(entry.count)
						end,
		}, -- [1]
		{
--			font = "GameFontHighlight",
			button = {
				normalTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				highlightTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				width = 14,
				height = 14,
			},
			name = "Item",
			width = 250,
			recipeMenuManualEntry = {
				{
					text = "Move To Top",
					func = OpMoveQueueEntryToTop,
					notCheckable = true,
				},
				{
					text = "Move To Bottom",
					func = OpMoveQueueEntryToBottom,
					notCheckable = true,
				},
				{
					text = "Delete",
					func = OpDeleteQueueEntry,
					notCheckable = true,
				},
				{
					text = "Filter Auctions by Reagent Tree",
					notCheckable = true,
					hasArrow = false,
					func = function(menuEntry,queue) GnomeWorks:PrepAuctionScan(queue) end,
				},
			},
			recipeMenuCrafted = {
				{
					text = "Select Item Source",
					notCheckable = true,
					hasArrow = true,
				},
				{
					text = "Filter Auctions by Reagent Tree",
					notCheckable = true,
					hasArrow = false,
					func = function(menuEntry,queue) GnomeWorks:PrepAuctionScan(queue) end,
				},
			},
			OnClick = function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex>0 then
								local entry = cellFrame:GetParent().data

								if entry.subGroup and source == "button" then
									entry.subGroup.expanded = not entry.subGroup.expanded
									sf:Refresh()
								else
									if button == "LeftButton" then
										if entry.recipeID then
											GnomeWorks:PushSelection()
											GnomeWorks.MainWindow:Show()
											GnomeWorks:SelectRecipe(entry.recipeID)
										end
									elseif button == "RightButton" then
										if entry.manualEntry then
											local recipeMenu = cellFrame.header.recipeMenuManualEntry

											for i=1,#recipeMenu do
												recipeMenu[i].arg1 = entry
											end

											recipeMenu[4].arg1 = entry

											if GnomeWorks.atAuctionHouse then
												recipeMenu[4].disabled = nil
												recipeMenu[4].colorCode = "|cffffffff"
											else
												recipeMenu[4].disabled = true
												recipeMenu[4].colorCode = "|cff808080"
											end

											ColumnControl(cellFrame, button, source, "recipeMenuManualEntry")
										else
											local recipeMenu = cellFrame.header.recipeMenuCrafted

											local sortMenu = {}

											local hasReagents

--											for recipeID in pairs(GnomeWorks.data.itemSource[entry.itemID]) do
											local list = entry.parent

											list = list or entry.control[1].parent

											for k,subEntry in ipairs(list) do
												if (subEntry.command == "create" or subEntry.command == "collect") and subEntry.itemID == entry.itemID then
													local menuEntry = {}

													local results,reagents,tradeID = GnomeWorks:GetRecipeData(subEntry.recipeID)

													if subEntry.command == "create" then
														hasReagents = true
														menuEntry.text = math.ceil((entry.numNeeded or 0) / results[subEntry.itemID]).." x "..GnomeWorks:GetRecipeName(subEntry.recipeID)
													else
														local c = "|cffb0b000"

														local itemName = GetItemInfo(entry.itemID) or "item:"..entry.itemID

														if GnomeWorks:VendorSellsItem(entry.itemID) then
															c = "|cff00b000"
														end

														if not subEntry.source then
															menuEntry.text = string.format("%d x %sPurchase|r |cffc0c0c0%s",entry.numNeeded or entry.count,c,itemName)
														else
															menuEntry.text = string.format("%d x %sFrom %s|r |cffc0c0c0%s",entry.numNeeded or entry.count, inventoryColors[subEntry.source],subEntry.source,itemName)
														end
													end
													menuEntry.checked = subEntry == entry
													menuEntry.arg1 = subEntry
													menuEntry.arg2 = entry
													menuEntry.func = OpQueueRecipeSwap

													sortMenu[#sortMenu+1] = menuEntry
												end
											end

											recipeMenu[1].text = string.format("Select Source for %s x %d",(GetItemInfo(entry.itemID) or "item:"..entry.itemID),entry.numNeeded or entry.count)
											recipeMenu[1].menuList = sortMenu

											recipeMenu[2].arg1 = entry

											if GnomeWorks.atAuctionHouse and hasReagents then
												recipeMenu[2].disabled = false
												recipeMenu[2].colorCode = "|cffffffff"
											else
												recipeMenu[2].disabled = true
												recipeMenu[2].colorCode = "|cff808080"
											end

											ColumnControl(cellFrame, button, source, "recipeMenuCrafted")
										end
									end
								end
							else
								if source == "button" then
									cellFrame.collapsed = not cellFrame.collapsed

									if not cellFrame.collapsed then
										GnomeWorks:CollapseAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
									else
										GnomeWorks:ExpandAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
									end
								end
							end
						end,
			draw =	function (rowFrame,cellFrame,entry)
						if entry.control then
							if not entry.manualEntry then
								entry.depth = 2
							else
								entry.depth = 0
							end
						end

						cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8+4+12, 0)
						cellFrame.button:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8, 0)
						local craftable

						if entry.subGroup and (entry.command == "options" or entry.count > (entry.numCraftable or 0)) then
							if entry.subGroup.expanded then
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
							else
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
							end

--							cellFrame.text:SetFormattedText("%s (%d Recipes)",entry.name,#entry.subGroup.entries)
							cellFrame.button:Show()

							craftable = true
						else
							cellFrame.button:Hide()
						end

						local needsScan = GnomeWorksDB.results[entry.recipeID]==nil

						if entry.manualEntry then
							cellFrame.text:SetFontObject("GameFontHighlight")
						else
							cellFrame.text:SetFontObject("GameFontHighlightsmall")
						end



						if entry.command == "create" then
							local name, rank, icon = GnomeWorks:GetTradeInfo(entry.recipeID)


							if entry.manualEntry then
								if entry.sourcePlayer then
									cellFrame.text:SetFormattedText("|T%s:0|t %s (%s)",icon or "",GnomeWorks:GetRecipeName(entry.recipeID), entry.sourcePlayer)
								else
									cellFrame.text:SetFormattedText("|T%s:0|t %s",icon or "",GnomeWorks:GetRecipeName(entry.recipeID))
								end
							else

								if entry.itemID then
									icon = GetItemIcon(entry.itemID)
								end
--[[
								if entry.command == "create" then
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t |cffd0d090%s: %s (x%d)",icon or "",GnomeWorks:GetTradeName(entry.tradeID),GnomeWorks:GetRecipeName(entry.recipeID),entry.results[entry.itemID])
								else
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t |cffd0d090%s: %s",icon or "",GnomeWorks:GetTradeName(entry.tradeID),GnomeWorks:GetRecipeName(entry.recipeID))
								end
]]
--								local results = GnomeWorksDB.results[entry.recipeID]
								local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,GnomeWorks.player)

								if entry.command == "create" and results[entry.itemID] ~= 1 then
									cellFrame.text:SetFormattedText("|T%s:0|t |cffd0d090%s (%s x %d)",icon or "",GnomeWorks:GetRecipeName(entry.recipeID),(GetItemInfo(entry.itemID)),entry.count * results[entry.itemID])
								else
									cellFrame.text:SetFormattedText("|T%s:0|t |cffd0d090%s",icon or "",GnomeWorks:GetRecipeName(entry.recipeID))
								end
							end

							cellFrame.text:SetTextColor(1,1,1)
--[[
							if needsScan then
								cellFrame.text:SetTextColor(1,0,0, (entry.manualEntry and 1) or .75)
							elseif entry.manualEntry then
								cellFrame.text:SetTextColor(1,1,1,1)
							else
								cellFrame.text:SetTextColor(.3,1,1,.75)
							end
]]

						elseif entry.command == "collect" then

							if not GetItemInfo(entry.itemID) then
								GameTooltip:SetHyperlink("item:"..entry.itemID)
							end

							local itemName = GetItemInfo(entry.itemID) or "item:"..entry.itemID

							if craftable and entry.subGroup.expanded then
								cellFrame.text:SetFormattedText("|T%s:0|t |ca040ffffCraft|r |cffc0c0c0%s",GetItemIcon(entry.itemID) or "",itemName)
							else
								local c = "|cffb0b000"

								if GnomeWorks:VendorSellsItem(entry.itemID) then
									c = "|cff00b000"
								end



								if not entry.source then
									cellFrame.text:SetFormattedText("|T%s:0|t %sPurchase|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "",c,itemName)
								else
									cellFrame.text:SetFormattedText("|T%s:0|t %sFrom %s|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "", inventoryColors[entry.source],entry.source,itemName)
								end
							end

							cellFrame.text:SetTextColor(1,1,1)
--[[
							if GnomeWorks:VendorSellsItem(entry.itemID) then
								cellFrame.text:SetTextColor(0,.7,0)
							else
								cellFrame.text:SetTextColor(.7,.7,0)
							end
]]
						elseif entry.command == "missing" then
							cellFrame.text:SetFormattedText("|T%s:0|t Missing Reagent: %s", GetItemIcon(entry.itemID) or "",(GetItemInfo(entry.itemID)) or "")
							cellFrame.text:SetTextColor(1,0,0)
						elseif entry.command == "options" then
							cellFrame.text:SetFormattedText("|T%s:0|t Missing Reagent: %s", GetItemIcon(entry.itemID) or "",(GetItemInfo(entry.itemID)) or "")
							cellFrame.text:SetTextColor(.8,.25,.8)
						end
					end,
		}, -- [2]
	}



	local function BuildQueueScrollingFrame()

		local function ResizeQueueFrame(scrollFrame,width,height)
			if scrollFrame then
				scrollFrame.columnWidth[2] = scrollFrame.columnWidth[2] + width - scrollFrame.headerWidth
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


		queueFrame = CreateFrame("Frame",nil,frame)
		queueFrame:SetPoint("LEFT",20,0)
		queueFrame:SetPoint("BOTTOM",frame,"CENTER",0,-5)
		queueFrame:SetPoint("TOP", frame, 0, -60)
		queueFrame:SetPoint("RIGHT", frame, -20,0)


--		GnomeWorks.queueFrame = queueFrame

		sf = GnomeWorks:CreateScrollingTable(queueFrame, ScrollPaneBackdrop, columnHeaders, ResizeQueueFrame)

		sf.selectable = true

		sf.DropSelection = function(scrollFrame, index)
--			scrollFrame.SortCompare = nil
			local dataMap = scrollFrame.dataMap
			local selection = scrollFrame.selection
			local numData = scrollFrame.numData

			local entry = dataMap[index]

			local parentGroup = scrollFrame.data

			local postInsert

			if not entry.manualEntry and not entry.control then
				return
			end


			for entry,value in pairs(selection) do
				local parent = scrollFrame.data

				if value and not selection[parent] then
					local loc

					for i=1,#parent.entries do
						if parent.entries[i] == entry then
							loc = i
							break
						end
					end

					if loc then
						if loc < index then
							postInsert = true
						end

						table.remove(parent.entries, loc)
					end
				end
			end

			local targetIndex = 1

			for i=1,parentGroup.numEntries or #parentGroup.entries do
				if parentGroup.entries[i] == entry then
					targetIndex = i

					if postInsert then
						targetIndex = targetIndex + 1
					end

					break
				end
			end

			if targetIndex then

				for i=1,numData do
					local entry = dataMap[i]

					if selection[entry] and (entry.manualEntry or entry.control) then
						table.insert(parentGroup.entries, targetIndex, entry)

						targetIndex = targetIndex + 1

						entry.parent = parentGroup

						if parentGroup.numEntries then
							parentGroup.numEntries = parentGroup.numEntries + 1
						end
					end
				end
			end

			scrollFrame:Refresh()
		end


--		sf.childrenFirst = true

		sf.IsEntryFiltered = function(self, entry)
			if entry.manualEntry then
--			print("manual entry", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numBag, entry.numNeeded)
				return false
			end


--			if true then return false end

--print("filter", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numNeeded)
			if (entry.command == "collect" or entry.command == "missing") and entry.count < 1 then
				return true
			elseif entry.command == "create" and entry.count < 1 then
				return true
			else
--print("filter", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numBag, entry.numNeeded)
				return false
			end
		end

--[[
		sf.IsEntryFiltered = function(self, entry)
			for k,filter in pairs(filterParameters) do
				if filter.enabled then
					if filter.func(entry) then
						return true
					end
				end
			end

			if textFilter and textFilter ~= "" then
				for w in string.gmatch(textFilter, "%a+") do
					if string.match(string.lower(entry.name), w, 1, true)==nil then
						return true
					end
				end
			end

			return false
		end
]]

		local function UpdateRowData(scrollFrame,entry,firstCall)
			local player = queuePlayer
--print("update row data", entry.command, entry.recipeID and GetSpellLink(entry.recipeID) or entry.itemID and GetItemInfo(entry.itemID))

			local itemID = entry.itemID
			local recipeID = entry.recipeID

			if itemID then
				entry.inQueue = GnomeWorks:GetInventoryCount(itemID, player, "queue")

				entry.bag = GnomeWorks:GetInventoryCount(itemID, player, "bag")
				entry.bank = GnomeWorks:GetInventoryCount(itemID, player, "bank")
				entry.guildBank = GnomeWorks:GetInventoryCount(itemID, player, "guildBank")
				entry.alt = GnomeWorks:GetFactionInventoryCount(itemID)
			end

			if entry.command == "create" then
				if entry.control then
					entry.numCraftable = 0

					for k,v in ipairs(entry.control) do
						entry.numCraftable = v.numCraftable
					end
				end

				if not entry.numCraftable then
					entry.numCraftable = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "bag queue")
				end


				if (entry.numCraftable or 0) >= (entry.count or 0) then
					if entry.subGroup then
						entry.subGroup.expanded = false
					end
				end

				if entry.count > 0 then
					entry.noHide = true
				else
					entry.noHide = false
				end
			end

--print("done updating")
		end


		sf:RegisterRowUpdate(UpdateRowData)
	end


	local SelectPlayer do
		local function DoSelection(menuFrame, player)
			CloseDropDownMenus()

			GnomeWorks:ShowQueueList(player)
		end

		local function InitMenu(menuFrame, level)
			if (level == 1) then  -- character names
				local title = {}
				local playerMenu = {}

				title.text = "Select Player"
				title.fontObject = "GameFontNormal"

				title.notCheckable = 1

				UIDropDownMenu_AddButton(title)

				local index = 1

				playerMenu.func = DoSelection

				for k,player in pairs(GnomeWorks.data.toonList) do
					local data = GnomeWorks.data.playerData[player]

					if data.build == clientBuild then
						playerMenu.text = player
--						playerMenu.hasArrow = nil
						playerMenu.arg1 = player
						playerMenu.disabled = false


						playerMenu.checked = player == queuePlayer


--						playerMenu.notCheckable = nil

						UIDropDownMenu_AddButton(playerMenu)
						index = index + 1
					end
				end
			end
		end

		function SelectPlayer(frame)
			if not GWPlayerSelectMenu then
				CreateFrame("Frame", "GWPlayerSelectMenu", UIParent, "UIDropDownMenuTemplate")
			end

			UIDropDownMenu_Initialize(GWPlayerSelectMenu, InitMenu, "MENU")
			ToggleDropDownMenu(1, nil, GWPlayerSelectMenu, frame, 0, 0)
		end
	end


	function GnomeWorks:CreateQueueWindow()
		frame = self.Window:CreateResizableWindow("GnomeWorksQueueFrame", nil, 300, 300, ResizeMainWindow, GnomeWorksDB.config)

		frame:DockWindow(self.MainWindow)


		frame:SetMinResize(300,300)

		BuildQueueScrollingFrame()

		local shoppingListSF = GnomeWorks:BuildShoppingListScrollFrame(frame)


		self.queueFrame = { scrollFrame = sf}
		self.shoppingListFrame = { scrollFrame = shoppingListSF }


		local playerName = CreateFrame("Button", nil, frame)

		playerName:SetWidth(240)
		playerName:SetHeight(16)
		playerName:SetText("UNKNOWN")
		playerName:SetPoint("TOP",frame,"TOP",0,-10)

		playerName:SetNormalFontObject("GameFontNormal")
		playerName:SetHighlightFontObject("GameFontHighlight")

		playerName:EnableMouse(false)

		playerName:RegisterForClicks("AnyUp")

		playerName:SetScript("OnClick", SelectPlayer)

		playerName:SetFrameLevel(playerName:GetFrameLevel()+1)


		frame.playerNameFrame = playerName


		self:RegisterMessageDispatch("QueueChanged TradeScanComplete InventoryScanComplete AuctionScanComplete", function() if frame:IsShown() then GnomeWorks:ShowQueueList() end end, "ShowQueueList")



		local function AdjustQueueLayout(frame)
			GnomeWorksDB.config.queueLayoutFlat = not GnomeWorksDB.config.queueLayoutFlat

			if GnomeWorksDB.config.queueLayoutFlat then
				frame:SetText("Layout: Flat")
			else
				frame:SetText("Layout: Grouped")
			end

			GnomeWorks:SendMessageDispatch("QueueChanged")
		end

		local layoutSelection = CreateFrame("Button", nil, frame)
		layoutSelection:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",20,-45)
		layoutSelection:SetPoint("RIGHT", frame,"RIGHT",-20,0)
		layoutSelection:SetHeight(16)

		if GnomeWorksDB.config.queueLayoutFlat then
			layoutSelection:SetText("Layout: Flat")
		else
			layoutSelection:SetText("Layout: Grouped")
		end

		layoutSelection:SetNormalFontObject("GameFontNormal")
		layoutSelection:SetHighlightFontObject("GameFontHighlight")

		layoutSelection:EnableMouse(true)

		layoutSelection:RegisterForClicks("AnyUp")

		layoutSelection:SetScript("OnClick", AdjustQueueLayout)

		layoutSelection:SetFrameLevel(layoutSelection:GetFrameLevel()+1)

		frame.layoutSelection = layoutSelection


		local control = CreateControlButtons(frame)

		control:SetPoint("TOP", sf, "BOTTOM", 0,5)


		table.insert(UISpecialFrames, "GnomeWorksQueueFrame")

		frame:HookScript("OnShow", function() PlaySound("igCharacterInfoOpen")  GnomeWorks:ShowQueueList() end)
		frame:HookScript("OnHide", function() PlaySound("igCharacterInfoClose") end)


		frame:Hide()

		return frame
	end

end

