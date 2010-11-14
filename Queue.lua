



--[[

	create = craft it
	collect = vendor or ah
	fromBank = from bank
	fromAlt = from alt (and alt name?)
	fromGuildBank = from guildBank

]]



local LARGE_NUMBER = 1000000


do
	local GnomeWorks = GnomeWorks

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


	local inventoryIndex = { "bag", "vendor", "bank", "guildBank", "alt" }

	local collectInventories = { "bank", "guildBank", "alt" }


	local inventoryColors = {
--		queue = "|cffff0000",
		bag = "|cffffff80",
		vendor = "|cff80ff80",
		bank =  "|cffffa050",
		guildBank = "|cff5080ff",
		alt = "|cffff80ff",
	}

	local inventoryTags = {}

	for k,v in pairs(inventoryColors) do
		inventoryTags[k] = v..k
	end


	local queueFrame

	local queuePlayer

	local currentRecipe



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
	end


	local function AdjustQueueCounts(player, entry)
		if entry.subGroup then
			local count = entry.count
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

			if entry.reserved then
				for itemID, numNeeded in pairs(reagents) do
					local needed = count * numNeeded

					entry.reserved[itemID] = math.max(0,math.min(needed, GnomeWorks:GetInventoryCount(itemID, player, "bag queue")))
				end
			end

			for k,reagent in ipairs(entry.subGroup.entries) do

				reagent.parent = entry.subGroup.entries


				if reagent.command == "collect" then
					local sourceQueue

					local itemID = reagent.itemID

					local numAvailable = LARGE_NUMBER

					if reagent.source then
						if reagent.source ~= "alt" then
							numAvailable = GnomeWorks:GetInventoryCountExclusive(itemID, player, reagent.source)
						else
							numAvailable = GnomeWorks:GetInventoryCountExclusive(itemID, "faction", "bank", player)
						end

						sourceQueue = GnomeWorks.data[reagent.source.."Queue"][player]

--print((GetItemInfo(itemID)),GnomeWorks.data[sourceQueue][player][itemID] or 0)
						numAvailable = numAvailable - (sourceQueue[itemID] or 0)
					elseif GnomeWorks:VendorSellsItem(reagent.itemID) then
						sourceQueue = GnomeWorks.data.vendorQueue[player]
					else
						sourceQueue = GnomeWorks.data.auctionQueue[player]
					end

					local stillNeeded = ((reagents and reagents[itemID]) or 1) * entry.count - (entry.reserved and entry.reserved[itemID] or 0)

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(numAvailable)

					if entry.reserved then
						entry.reserved[itemID] = (entry.reserved[itemID] or 0) + reagent.count
					end

					if sourceQueue then
--print(entry,k,(GetItemInfo(itemID)),reagent.source,reagent.count, sourceQueue[itemID] or 0)
						if sourceQueue[itemID] or reagent.count>0 then
							sourceQueue[itemID] = (sourceQueue[itemID] or 0) + reagent.count
						end
					end

				elseif reagent.command == "create" then
					local itemID = reagent.itemID
					local resultsReagent,reagentsReagent,tradeID = GnomeWorks:GetRecipeData(reagent.recipeID,player)

					local numAvailable = GnomeWorks:InventoryRecipeIterations(reagent.recipeID, player, "bag queue") * resultsReagent[itemID]

					reagent.numCraftable = numAvailable

					local stillNeeded = ((reagents and reagents[itemID]) or 1) * entry.count - (entry.reserved and entry.reserved[itemID] or 0)

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(stillNeeded / resultsReagent[reagent.itemID])

					if entry.reserved then
						entry.reserved[itemID] = (entry.reserved[itemID] or 0) + reagent.count * resultsReagent[itemID]
					end

					AdjustQueueCounts(player, reagent)

					for itemID,numNeeded in pairs(reagentsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, numNeeded * reagent.count)
					end

					for itemID,numMade in pairs(resultsReagent) do
						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * reagent.count)
					end

					if tradeID == 100001 then					-- vendor conversion
						local vendorQueue = GnomeWorks.data.vendorQueue[player]
						vendorQueue[itemID] = (vendorQueue[itemID] or 0) + reagent.count

						if vendorQueue[itemID] == 0 then
							vendorQueue[itemID] = nil
						end
					end
				end
			end
		end
	end


	local function ReserveReagentsIntoQueue(player, queue)
--print("RESERVE", player, queue)
		if queue then
			for k,entry in ipairs(queue) do
				entry.parent = queue

				if entry.command == "create" then
					entry.numCraftable = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "bag queue")

					AdjustQueueCounts(player, entry)

					local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)

					for itemID,numNeeded in pairs(reagents) do
						GnomeWorks:ReserveItemForQueue(player, itemID, numNeeded * entry.count)
					end

					for itemID,numMade in pairs(results) do
--						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * entry.count)
					end
				end
			end
		end
	end



	local function ReserveReagentsIntoQueueOLD(player, queue)
--print("RESERVE", player, queue)
		if queue then
			for k,entry in ipairs(queue) do
				entry.parent = queue

				if entry.command == "create" then
					entry.numCraftable = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "bag queue")

					AdjustQueueCounts(player, entry)

					if entry.subGroup then
						ReserveReagentsIntoQueue(player, entry.subGroup.entries)
					end


					local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)


					for itemID,numMade in pairs(results) do
						GnomeWorks:ReserveItemForQueue(player, itemID, -numMade * entry.count)
					end

					if reagents then
						for reagentID,numNeeded in pairs(reagents) do
							GnomeWorks:ReserveItemForQueue(player, reagentID, numNeeded * entry.count)
						end
					end
				elseif entry.command == "collect" then
--					local numAvailable = GnomeWorks:GetInventoryCount(entry.itemID, player, entry.source or "bag queue")

--					local inQueue = math.max(0,math.min(entry.numNeeded, numAvailable))

--					entry.count = entry.count - inQueue
----					GnomeWorks:ReserveItemForQueue(player, entry.itemID, entry.numNeeded)

				elseif entry.command == "options" then
					local numAvailable = GnomeWorks:GetInventoryCount(entry.itemID, player, "bag queue")
					local inQueue = math.min(entry.numNeeded, numAvailable)

--					entry.count = entry.count - inQueue

					AdjustQueueCounts(player, entry)
				end

			end
		end
	end





	local function ZeroQueue(queue)
		if queue then
			for k,q in pairs(queue) do
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

--			noHide = true,
		}

		if GnomeWorksDB.reagents[recipeID] then
			for itemID, numNeeded in pairs(GnomeWorksDB.reagents[recipeID]) do
				local needed = count * numNeeded

				newEntry.reserved[itemID] = math.min(needed, GnomeWorks:GetInventoryCount(itemID, player, "bag queue"))
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



		local stillNeeded = numNeeded - GnomeWorks:GetInventoryCount(reagentID, player, "bag")

		for k,inv in pairs(collectInventories) do
			local numAvailable = LARGE_NUMBER

			if inv ~= "alt" then
				numAvailable = GnomeWorks:GetInventoryCountExclusive(reagentID, player, inv)
			else
				numAvailable = GnomeWorks:GetInventoryCountExclusive(reagentID, "faction", "bank", player)
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

--[[
				for recipeID, numMade in pairs(source[reagentID]) do
					local cooldownGroup = GnomeWorks:GetSpellCooldownGroup(recipeID)

					if cooldownGroup then
						if cooldownUsed[cooldownGroup] then
							break
						end

						cooldownUsed[cooldownGroup] = true
					end
]]



			local craftOptions = {}


-- add recipe sources:
			for recipeID,numMade in pairs(source[reagentID]) do
				if numMade > .1 then
					local cooldownGroup = GnomeWorks:GetSpellCooldownGroup(recipeID)

					if not cooldownGroup and GnomeWorks:IsSpellKnown(recipeID, player) then -- and not cooldownUsed[cooldownGroup] then
						local recursive

						local results, reagents = GnomeWorks:GetRecipeData(recipeID)

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
					if GnomeWorks:IsSpellKnown(recipeID, player) then
						local cooldownGroup = GnomeWorks:GetSpellCooldownGroup(recipeID)

						if cooldownGroup then
							cooldownUsed[cooldownGroup] = true
						end
					end
				end
			end

			if #craftOptions>100000 then --disabled for now...
				local optionGroup = { index = 1, command = "options", itemID = reagentID, numNeeded = numNeeded, count = numNeeded, subGroup = { entries = {}, expanded = false }}

				table.insert(queue.subGroup.entries, optionGroup)

				for i=1,#craftOptions do
					table.insert(optionGroup.subGroup.entries, craftOptions[i])
				end
			elseif #craftOptions>0 then
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

--					AddEntryToQueue(craftOptions[i], queue.subGroup.entries)

					queue.subGroup.entries[i].parent = queue.subGroup.entries
				end
			end
--[[
		else
			local stillNeeded = numNeeded - GnomeWorks:GetInventoryCount(reagentID, player, "bag")

			for k,inv in pairs(collectInventories) do
				local numAvailable = LARGE_NUMBER

				if inv ~= "alt" then
					numAvailable = GnomeWorks:GetInventoryCountExclusive(reagentID, player, inv)
				else
					numAvailable = GnomeWorks:GetInventoryCountExclusive(reagentID, "faction", "bank", player)
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

			table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded))
]]
		end

		table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded))


--		if cooldownGroup then
--			cooldownUsed[cooldownGroup] = nil
--		end

		recursionLimiter[reagentID] = nil

		return newEntry, count
	end


	local function CreateQueue(player, recipeID, count, tradeID, sourcePlayer, index)
		local results,reagents = GnomeWorks:GetRecipeData(recipeID,player)
--		local reagents = GnomeWorksDB.reagents[recipeID]
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
		}

		for itemID, numNeeded in pairs(reagents) do
			local needed = count * numNeeded * numMade

			queue.reserved[itemID] = math.min(needed, GnomeWorks:GetInventoryCount(itemID, queuePlayer, "bag queue"))
		end

		if reagents then
			queue.subGroup = {expanded = false, entries = {} }

			for reagentID,numNeeded in pairs(reagents) do
				AddReagentToQueue(queue, reagentID, numNeeded * count, queuePlayer)
			end
		end

		return queue
	end



	function GnomeWorks:AddToQueue(player, tradeID, recipeID, count)
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
			local newQueue = CreateQueue(player, recipeID, count, tradeID, sourcePlayer, #queueData)

			newQueue.parent = queueData

			table.insert(queueData, newQueue)
		end


		self:SendMessageDispatch("GnomeWorksQueueChanged")
		self:SendMessageDispatch("GnomeWorksSkillListChanged")
		self:SendMessageDispatch("GnomeWorksDetailsChanged")
	end



	function BuildSourceQueues(player, queue)
		local vendorQueue = GnomeWorks.data.vendorQueue[player]
		local auctionQueue = GnomeWorks.data.auctionQueue[player]
		local bankQueue = GnomeWorks.data.bankQueue[player]
		local guildBankQueue = GnomeWorks.data.guildBankQueue[player]
		local altQueue = GnomeWorks.data.altQueue[player]

		if queue then
			for k,entry in ipairs(queue) do
				if entry.command == "collect" then
					local sourceQueue

					if not entry.source then
						if GnomeWorks:VendorSellsItem(entry.itemID) then
							sourceQueue = vendorQueue
						else
							sourceQueue = auctionQueue
						end
					elseif entry.source == "bank" then
						sourceQueue = bankQueue
					elseif entry.source == "guildBank" then
						sourceQueue = guildBankQueue
					elseif entry.source == "alt" then
						sourceQueue = altQueue
					end

					if sourceQueue then
						sourceQueue[entry.itemID] = (sourceQueue[entry.itemID] or 0) + entry.count

						if sourceQueue[entry.itemID] == 0 then
							sourceQueue[entry.itemID] = nil
						end
					end

				elseif entry.command == "create" then
					local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

					if tradeID == 100001 then					-- vendor conversion
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



	local function BuildFlatQueueOLD(flatQueue, queue)
		local reagentList = {}

		for k,entry in pairs(queue) do
			local results, reagents = GnomeWorks:GetRecipeData(entry.recipeID)

			for reagentID, numNeeded in pairs(reagents) do
				reagentList[reagentID] = (reagentList[reagentID] or 0) + numNeeded * entry.count
			end
		end

--		local tempQueue = { subGroup = { entries = flatQueue } }

		for reagentID, numNeeded in pairs(reagentList) do
--			local function AddReagentToQueue(queue, reagentID, numNeeded, player)

			local optionGroup = { index = 1, command = "options", itemID = reagentID, numNeeded = numNeeded, count = numNeeded, subGroup = { entries = {}, expanded = false }}

			local entry, count = AddReagentToQueue(optionGroup, reagentID, numNeeded, player)

			flatQueue[#flatQueue+1] = optionGroup
		end

		for k,entry in pairs(queue) do
			local f = {}

			for k,v in pairs(entry) do
				if k ~= "subGroup" then
					f[k] = v
				end
			end

			flatQueue[#flatQueue+1] = f
		end
	end


--[[
		local newEntry = {
			index = index,
			command = "collect",
			itemID = reagentID,
			numNeeded = numNeeded,
			count=count,
			source=source,
		}
]]




	local function BuildFlatQueue(flatQueue, queue)
		for k,entry in pairs(queue) do
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
		local player = player or (self.data.playerData[self.player] and self.player) or UnitName("player")
		queuePlayer = player

		if player then
			frame.playerNameFrame:SetFormattedText("%s Queue",player)

			if not self.data.queueData[player] then
				self.data.queueData[player] = {}
			end

			local queue = self.data.queueData[player]


			if not sf.data then
				sf.data = {}
			end

			self.data.inventoryData[player].queue = table.wipe(self.data.inventoryData[player].queue or {})

			self.data.vendorQueue[player] = table.wipe(self.data.vendorQueue[player] or {})
			self.data.auctionQueue[player] = table.wipe(self.data.auctionQueue[player] or {})
			self.data.bankQueue[player] = table.wipe(self.data.bankQueue[player] or {})
			self.data.guildBankQueue[player] = table.wipe(self.data.guildBankQueue[player] or {})
			self.data.altQueue[player] = table.wipe(self.data.altQueue[player] or {})


			ReserveReagentsIntoQueue(player, self.data.queueData[player])

--			BuildSourceQueues(player, self.data.queueData[player])

			self:SendMessageDispatch("GnomeWorksQueueCountsChanged")

			if not self.data.flatQueue then
				self.data.flatQueue = {}
			end

			self.data.flatQueue[player] = table.wipe(self.data.flatQueue[player] or {})


			BuildFlatQueue(self.data.flatQueue[player], self.data.queueData[player])


			if GnomeWorksDB.config.queueLayoutFlat then
				sf.data.entries = self.data.flatQueue[player]
			else
				sf.data.entries = self.data.queueData[player]
			end

--			self.data.inventoryData[player].queue = table.wipe(self.data.inventoryData[player].queue or {})

--			ReserveReagentsIntoQueue(player, self.data.flatQueue[player])




			sf:Refresh()
--			sf:Show()
			frame:Show()

			frame:SetToplevel(true)

--			if self.IsAtAuctionHouse then
--				GnomeWorks:BeginReagentScan(GnomeWorks.data.inventoryData[player].queue, function() print("DONE WITH SCAN") end)
--			end
		end
	end


	local function FirstCraftableEntry(queue)
		if queue then
			for k,q in pairs(queue) do
				if q.command == "create" and (q.count or 0) > 0 then
					local count = GnomeWorks:InventoryRecipeIterations(q.recipeID, queuePlayer, "bag")
					if count>0 then
						return q, count
					end
				end

				if q.subGroup then
					local first,count = FirstCraftableEntry(q.subGroup.entries)

					if first then
						return first,count
					end
				end
			end
		end
	end

	local function DeleteQueueEntry(queue, entry)
		for k,q in pairs(queue) do
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
			GnomeWorks.IsProcessing = false
			self:SendMessageDispatch("GnomeWorksProcessing")
		end
	end


	function GnomeWorks:SpellCastCompleted(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST COMPLETED", ...)
--print(event,unit,spell,rank,lineID,spellID)

		if unit == "player"	and doTradeEntry and spellID == doTradeEntry.recipeID then
			if doTradeEntry.manualEntry then
				doTradeEntry.count = doTradeEntry.count - 1
--print("tickDown")
				if doTradeEntry.count == 0 then
					DeleteQueueEntry(self.data.queueData[queuePlayer], doTradeEntry)

					doTradeEntry = nil
					GnomeWorks.processSpell = nil

					GnomeWorks.IsProcessing = false
					self:SendMessageDispatch("GnomeWorksProcessing")
				end
			else
				if doTradeEntry.count < 1 then
					StopTradeSkillRepeat()
--print("STOP REPEAT")
				end
			end

			self:ShowQueueList()
		end
	end


	function GnomeWorks:SpellCastStop(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST START", spellID, doTradeEntry and doTradeEntry.recipeID)

		if unit == "player" then
			GnomeWorks.IsProcessing = false
			self:SendMessageDispatch("GnomeWorksProcessing")
		end
	end


	function GnomeWorks:SpellCastStart(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST START", spellID, doTradeEntry and doTradeEntry.recipeID)

		if unit == "player"	and doTradeEntry and spellID == doTradeEntry.recipeID then

			CURRENT_TRADESKILL = GetTradeSkillLine()

			GnomeWorks.IsProcessing = true
			self:SendMessageDispatch("GnomeWorksProcessing")
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
						if pseudoTrade.DoTradeSkill(entry.recipeID, entry.count) then
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

			GnomeWorks:InventoryScan()

			GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
			GnomeWorks:SendMessageDispatch("GnomeWorksDetailsChanged")
			GnomeWorks:SendMessageDispatch("GnomeWorksSkillListChanged")
		end


		local function StopProcessing()
			StopTradeSkillRepeat()
		end


		local buttons = {}

		local function ConfigureButton(button)
			local entry = FirstCraftableEntry(GnomeWorks.data.queueData[queuePlayer])

			if GnomeWorks.IsProcessing then
				button:SetFormattedText("Processing...")
				button:Disable()
				button:Show()

				if not InCombatLockdown() then
					button.secure:Hide()
				end

				EditMacro("GWProcess", "GWProcess", 977, "", false, false)
			elseif entry then
				local _,_,tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

				button:SetFormattedText("Process %s x %d",GnomeWorks:GetRecipeName(entry.recipeID) or "spell:"..entry.recipeID,math.min(entry.numCraftable,entry.count))
				button:Enable()

				local pseudoTrade = GnomeWorks.data.pseudoTradeData[tradeID]

				local macroText

				if pseudoTrade and pseudoTrade.ConfigureMacroText then
					macroText = pseudoTrade.ConfigureMacroText(entry.recipeID)
					doTradeEntry = entry

					if not InCombatLockdown() then
						button.secure:Show()
						button.secure:SetAttribute("type", "macro")
						button.secure:SetAttribute("macrotext", macroText)
					end

					EditMacro("GWProcess", "GWProcess", 977, macroText, false, false)				-- 97, 7
				elseif tradeID then
					button:SetScript("OnClick", ProcessQueue)

					if not InCombatLockdown() then
						button.secure:Hide()

						EditMacro("GWProcess", "GWProcess", 977, "/click GWProcess", false, false)
					end
--[[
					local spellName = GetSpellInfo(entry.recipeID)

					local openTrade = ""

					if GnomeWorks:IsTradeSkillLinked() or GnomeWorks.player ~= UnitName("player") or GnomeWorks.tradeID ~= entry.tradeID or GetFirstTradeSkill()==0 then
						if not GnomeWorks.MainWindow:IsVisible() then
							openTrade = "/script GnomeWorks.hideMainWindow = true\n"
						end

						openTrade = "/cast "..GnomeWorks:GetTradeName(entry.tradeID).."\n"
					end

					doTradeEntry = entry

					local castText = "/script for i=1,1000 do if GetTradeSkillInfo(i)=='"..spellName.."' then DoTradeSkill(i,"..entry.count..") end end"

					macroText = openTrade..castText

					if tradeID == 2550 then -- cooking
--						macroText = macroText.."\r/cast "..(GetSpellInfo(818))
					end
]]
				else
					print("tradeID is nil for entry", entry, entry.recipeID)
				end



--				print(macroText)
			else
				button:Disable()
				button:SetText("Nothing To Process")
			end
		end


		local buttonConfig = {
--			{ text = "Process", operation = ProcessQueue, width = 250, validate = SetProcessLabel, lineBreak = true, template = "SecureActionButtonTemplate" },
			{ text = "Process", name = "GWProcess", width = 250, validate = ConfigureButton, lineBreak = true, addSecure=true, template = "SecureActionButtonTemplate" },
			{ text = "Stop", operation = StopProcessing, width = 125 },
			{ text = "Clear", operation = ClearQueue, width = 125 },
		}



		local position = 0
		local line = 0

		controlFrame = CreateFrame("Frame", nil, frame)


--		controlFrame:SetPoint("LEFT",20,0)
--		controlFrame:SetPoint("RIGHT",-20,0)


		for i, config in pairs(buttonConfig) do
			if not config.style or config.style == "Button" then
--				local newButton = CreateFrame("Button", nil, controlFrame, "UIPanelButtonTemplate")

				local newButton = GnomeWorks:CreateButton(controlFrame, 18, nil, config.name)

				if config.addSecure then
					newButton.secure = CreateFrame("Button",nil, newButton, config.template, (config.name or config.text).."Secure")

					newButton.secure:SetAllPoints(newButton)

					newButton.secure:HookScript("OnEnter", function(b) newButton.state.Highlight:Show() end)
					newButton.secure:HookScript("OnLeave", function(b) newButton.state.Highlight:Hide() end)

					newButton.secure:HookScript("OnMouseDown", function(b) if newButton:IsEnabled()>0 then newButton.state.Down:Show() newButton.state.Up:Hide() end end)
					newButton.secure:HookScript("OnMouseUp", function(b) if newButton:IsEnabled()>0 then newButton.state.Down:Hide() newButton.state.Up:Show() end end)
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
					newButton:validate()
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
		end

		controlFrame:SetHeight(20+line*20)
		controlFrame:SetWidth(position)

		GnomeWorks:RegisterMessageDispatch("GnomeWorksQueueCountsChanged GnomeWorksProcessing", function()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end)

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

		GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
	end





	local function OpDeleteQueueEntry(button,entry)
		CloseDropDownMenus()
		local entryNum

		local queue = GnomeWorks.data.queueData[queuePlayer]

		for k,v in ipairs(queue) do
			if v == entry then
				entryNum = k
			end
		end

		if entryNum then
			table.remove(queue, entryNum)

			GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
			GnomeWorks:SendMessageDispatch("GnomeWorksSkillListChanged")
			GnomeWorks:SendMessageDispatch("GnomeWorksDetailsChanged")
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

		GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged GnomeWorksSkillListChanged GnomeWorksDetailsChanged")
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

		GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged GnomeWorksSkillListChanged GnomeWorksDetailsChanged")
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

									GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
									GnomeWorks:SendMessageDispatch("GnomeWorksSkillListChanged")
									GnomeWorks:SendMessageDispatch("GnomeWorksDetailsChanged")

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

							if entry.command ~= "options" then
								if entry.numCraftable then
									if entry.numCraftable == 0 then
										cellFrame.text:SetTextColor(1,0,0)
									elseif entry.count > entry.numCraftable then
										cellFrame.text:SetTextColor(.8,.8,0)
									else
										cellFrame.text:SetTextColor(1,1,1)
									end
								end
							else
								cellFrame.text:SetTextColor(1,1,1)
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
			},
			recipeMenuCrafted = {
				{
					text = "Select Item Source",
					notCheckable = true,
					hasArrow = true,
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
											GnomeWorks:SelectRecipe(entry.recipeID)
										end
									elseif button == "RightButton" then
										if entry.manualEntry then
											local recipeMenu = cellFrame.header.recipeMenuManualEntry

											for i=1,#recipeMenu do
												recipeMenu[i].arg1 = entry
											end

											ColumnControl(cellFrame, button, source, "recipeMenuManualEntry")
										else
											local recipeMenu = cellFrame.header.recipeMenuCrafted

											local sortMenu = {}

--											for recipeID in pairs(GnomeWorks.data.itemSource[entry.itemID]) do
											local list = entry.parent

											list = list or entry.control[1].parent

											for k,subEntry in ipairs(list) do
												if (subEntry.command == "create" or subEntry.command == "collect") and subEntry.itemID == entry.itemID then
													local menuEntry = {}

													local results = GnomeWorks:GetRecipeData(subEntry.recipeID)

													if subEntry.command == "create" then
														menuEntry.text = math.ceil(subEntry.numNeeded / results[subEntry.itemID]).." x "..GnomeWorks:GetRecipeName(subEntry.recipeID)
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
						if entry.control and not entry.manualEntry then
							entry.depth = 2
						else
							entry.depth = 0
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
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %s (%s)",icon or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,GnomeWorks:GetRecipeName(entry.recipeID), entry.sourcePlayer)
								else
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %s",icon or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,GnomeWorks:GetRecipeName(entry.recipeID))
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
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t |cffd0d090 %s (%sx%d)",icon or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,GnomeWorks:GetRecipeName(entry.recipeID),(GetItemInfo(entry.itemID)),entry.count * results[entry.itemID])
								else
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t |cffd0d090 %s",icon or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,GnomeWorks:GetRecipeName(entry.recipeID))
								end
							end
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
								cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t |ca040ffffCraft|r |cffc0c0c0%s",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,GetItemIcon(entry.itemID) or "",itemName)
							else
								local c = "|cffb0b000"

								if GnomeWorks:VendorSellsItem(entry.itemID) then
									c = "|cff00b000"
								end



								if not entry.source then
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %sPurchase|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,c,itemName)
								else
									cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %sFrom %s|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1, inventoryColors[entry.source],entry.source,itemName)
								end
							end
--[[
							if GnomeWorks:VendorSellsItem(entry.itemID) then
								cellFrame.text:SetTextColor(0,.7,0)
							else
								cellFrame.text:SetTextColor(.7,.7,0)
							end
]]
						elseif entry.command == "options" then
							cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t Crafting Options for %s", GetItemIcon(entry.itemID),cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,(GetItemInfo(entry.itemID)))
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
		queueFrame:SetPoint("BOTTOM",frame,"CENTER",0,-25)
		queueFrame:SetPoint("TOP", frame, 0, -60)
		queueFrame:SetPoint("RIGHT", frame, -20,0)


--		GnomeWorks.queueFrame = queueFrame

		sf = GnomeWorks:CreateScrollingTable(queueFrame, ScrollPaneBackdrop, columnHeaders, ResizeQueueFrame)


--		sf.childrenFirst = true

		sf.IsEntryFiltered = function(self, entry)
			if entry.manualEntry then
--			print("manual entry", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numBag, entry.numNeeded)
				return false
			end


--			if true then return false end

--print("filter", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numNeeded)
			if entry.command == "collect" and entry.count < 1 then
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
				entry.alt = GnomeWorks:GetInventoryCount(itemID, "faction", "bank")
			end

			if entry.command == "create" then
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



	function GnomeWorks:CreateQueueWindow()
		frame = self.Window:CreateResizableWindow("GnomeWorksQueueFrame", nil, 300, 300, ResizeMainWindow, GnomeWorksDB.config)

		frame:DockWindow(self.MainWindow)


		frame:SetMinResize(300,300)

		BuildQueueScrollingFrame()

		shoppingListSF = GnomeWorks:BuildShoppingListScrollFrame(frame)



		local playerName = CreateFrame("Button", nil, frame)

		playerName:SetWidth(240)
		playerName:SetHeight(16)
		playerName:SetText("UNKNOWN")
		playerName:SetPoint("TOP",frame,"TOP",0,-10)

		playerName:SetNormalFontObject("GameFontNormal")
		playerName:SetHighlightFontObject("GameFontHighlight")

		playerName:EnableMouse(false)


--		playerName:RegisterForClicks("AnyUp")

--		playerName:SetScript("OnClick", self.SelectTradeLink)

		playerName:SetFrameLevel(playerName:GetFrameLevel()+1)


		frame.playerNameFrame = playerName


		self:RegisterMessageDispatch("GnomeWorksQueueChanged GnomeWorksTradeScanComplete GnomeWorksInventoryScanComplete", function() if frame:IsShown() then GnomeWorks:ShowQueueList() end end)


		local LayoutMenu = {
			{ text = "Grouped", func = function() GnomeWorksDB.config.queueLayoutFlat = nil GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged") frame.layoutSelection:SetText("Layout: Grouped") end },
			{ text = "Flat", func = function() GnomeWorksDB.config.queueLayoutFlat = true GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged") frame.layoutSelection:SetText("Layout: Flat") end },
		}


		local function AdjustQueueLayout(frame)
			if GnomeWorksDB.config.queueLayoutFlat then
				LayoutMenu[1].checked = false
				LayoutMenu[2].checked = true
			else
				LayoutMenu[1].checked = true
				LayoutMenu[2].checked = false
			end

			local x, y = GetCursorPosition()
			local uiScale = UIParent:GetEffectiveScale()

--			EasyMenu(LayoutMenu, GnomeWorksMenuFrame, UIParent, x/uiScale, y/uiScale, "MENU", 5)

			GnomeWorksDB.config.queueLayoutFlat = not GnomeWorksDB.config.queueLayoutFlat

			if GnomeWorksDB.config.queueLayoutFlat then
				frame:SetText("Layout: Flat")
			else
				frame:SetText("Layout: Grouped")
			end

			GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
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

