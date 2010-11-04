



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
--			local reagents = GnomeWorksDB.reagents[entry.recipeID]
--			local results = GnomeWorksDB.results[entry.recipeID]
			local results,reagents = GnomeWorks:GetRecipeData(entry.recipeID,player)
if not results or not reagents then
	print(results, reagents, entry.recipeID, GnomeWorks:GetRecipeName(entry.recipeID))
end

			if entry.reserved then
				for itemID, numNeeded in pairs(reagents) do
					local needed = count * numNeeded

					entry.reserved[itemID] = math.max(0,math.min(needed, GnomeWorks:GetInventoryCount(itemID, player, "bag queue")))
				end
			end

			for k,reagent in ipairs(entry.subGroup.entries) do
				if reagent.command == "collect" then
					local itemID = reagent.itemID

					local numAvailable = LARGE_NUMBER

					if reagent.source then
						if reagent.source ~= "alt" then
							numAvailable = GnomeWorks:GetInventoryCountExclusive(itemID, player, reagent.source)
						else
							numAvailable = GnomeWorks:GetInventoryCountExclusive(itemID, "faction", "bank", player)
						end

--						local sourceQueue = reagent.source.."Queue"
--print((GetItemInfo(itemID)),GnomeWorks.data[sourceQueue][player][itemID] or 0)
--						numAvailable = numAvailable - (GnomeWorks.data[sourceQueue][player][itemID] or 0)
					end

					local stillNeeded = reagents[itemID] * entry.count - (entry.reserved[itemID])

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(numAvailable)

					entry.reserved[itemID] = (entry.reserved[itemID]) + reagent.count
				else
					local itemID = reagent.itemID
					local resultsReagent,reagentsReagent = GnomeWorks:GetRecipeData(reagent.recipeID,player)
if not resultsReagent then
	print(GetItemInfo(reagent.itemID or 0) or reagent.itemID, reagent.recipeID, reagent.command)
end
					local numAvailable = GnomeWorks:InventoryRecipeIterations(reagent.recipeID, player, "bag queue") * resultsReagent[itemID]
					local stillNeeded = reagents[itemID] * entry.count - (entry.reserved[itemID])

					if numAvailable > stillNeeded then
						numAvailable = stillNeeded
					end

					reagent.count = math.ceil(stillNeeded / resultsReagent[reagent.itemID])

					entry.reserved[itemID] = (entry.reserved[itemID]) + reagent.count * resultsReagent[itemID]


					AdjustQueueCounts(player, reagent)
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

--[[
					local numAvailable = GnomeWorks:GetInventoryCount(entry.itemID, player, "bag queue")



					entry.count = math.ceil((entry.numNeeded - numAvailable)/entry.results[entry.itemID])

					if entry.count < 0 then
						entry.count = 0
					end

					entry.noHide = true
]]
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


	local recursionLimiter = {}
	local cooldownUsed = {}

	local function AddReagentToQueue(queue, reagentID, numNeeded, player)
		if not reagentID then return nil, 0 end

		if recursionLimiter[reagentID] then return nil, 0 end

		recursionLimiter[reagentID] = true

		local source = GnomeWorks.data.itemSource

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

				for i=1,#craftOptions do
					table.insert(queue.subGroup.entries, craftOptions[i])
				end
			else
				local stillNeeded = numNeeded - GnomeWorks:GetInventoryCount(reagentID, player, "bag queue")

				for k,inv in pairs(collectInventories) do

					table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded,inv))

					if inv ~= "alt" then
						stillNeeded = stillNeeded - GnomeWorks:GetInventoryCountExclusive(reagentID, player, inv)
					else
						stillNeeded = stillNeeded - GnomeWorks:GetInventoryCountExclusive(reagentID, "faction", "bank")
					end

					if stillNeeded < 0 then
						stillNeeded = 0
					end
				end

				table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded))
			end
		else
			local stillNeeded = numNeeded - GnomeWorks:GetInventoryCount(reagentID, player, "bag queue")

			for k,inv in pairs(collectInventories) do

				table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded,inv))

				stillNeeded = stillNeeded - GnomeWorks:GetInventoryCount(reagentID, player, inv)

				if stillNeeded < 0 then
					stillNeeded = 0
				end
			end

			table.insert(queue.subGroup.entries, InitReagentEntry(#queue.subGroup.entries+1, reagentID, numNeeded, stillNeeded))
		end


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
				end

				if entry.subGroup then
					BuildSourceQueues(player, entry.subGroup.entries)
				end
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

			ReserveReagentsIntoQueue(player, self.data.queueData[player])

			self.data.vendorQueue[player] = table.wipe(self.data.vendorQueue[player] or {})
			self.data.auctionQueue[player] = table.wipe(self.data.auctionQueue[player] or {})
			self.data.bankQueue[player] = table.wipe(self.data.bankQueue[player] or {})
			self.data.guildBankQueue[player] = table.wipe(self.data.guildBankQueue[player] or {})
			self.data.altQueue[player] = table.wipe(self.data.altQueue[player] or {})

			BuildSourceQueues(player, self.data.queueData[player])

			self:SendMessageDispatch("GnomeWorksQueueCountsChanged")

			sf.data.entries = self.data.queueData[player]


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
					if GnomeWorks:InventoryRecipeIterations(q.recipeID, queuePlayer, "bag")>0 then
						return q
					end
				end

				if q.subGroup then
					local f = FirstCraftableEntry(q.subGroup.entries)

					if f then return f end
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


	function GnomeWorks:SpellCastCompleted(event,unit,spell,rank)
--print("SPELL CAST COMPLETED", ...)

		if unit == "player"	and doTradeEntry and spell == GetSpellInfo(doTradeEntry.recipeID) then
			if doTradeEntry.manualEntry then
				doTradeEntry.count = doTradeEntry.count - 1

				if doTradeEntry.count == 0 then
					DeleteQueueEntry(self.data.queueData[queuePlayer], doTradeEntry)

					doTradeEntry = nil
					GnomeWorks.processSpell = nil

					GnomeWorks.IsProcessing = false
				end
			else
				if doTradeEntry.count < 1 then
					StopTradeSkillRepeat()
				end
			end

			self:ShowQueueList()
		end
	end


	function GnomeWorks:SpellCastStart(event,unit,spell,rank,lineID,spellID)
--print("SPELL CAST START", spellID, doTradeEntry and doTradeEntry.recipeID)

		if unit == "player"	and doTradeEntry and spellID == doTradeEntry.recipeID then
			GnomeWorks.IsProcessing = true
			self:SendMessageDispatch("GnomeWorksProcessing")
		end
	end


	local function CreateControlButtons(frame)
		local function ProcessQueue()
			local entry = FirstCraftableEntry(GnomeWorks.data.queueData[queuePlayer])

			if entry then
--				local tradeID = GnomeWorksDB.tradeIDs[entry.recipeID]
				local _,_,tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

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
							GnomeWorks:print("executing",GnomeWorks:GetRecipeName(entry.recipeID),"x",math.min(entry.count, entry.numCraftable))
							DoTradeSkill(skillIndex,math.min(entry.count, entry.numCraftable))
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
			table.wipe(GnomeWorks.data.inventoryData[queuePlayer]["queue"])


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

				button.secure:Hide()

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

					button.secure:Show()
					button.secure:SetAttribute("type", "macro")
					button.secure:SetAttribute("macrotext", macroText)

					EditMacro("GWProcess", "GWProcess", 977, macroText, false, false)				-- 97, 7
				elseif tradeID then
					button:SetScript("OnClick", ProcessQueue)
					button.secure:Hide()

					EditMacro("GWProcess", "GWProcess", 977, "/click GWProcess", false, false)
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

				p[a.index], p[b.index] = p[b.index], p[a.index]

				a.index, b.index = b.index, a.index
				a.expanded, b.expanded = b.expanded, a.expanded
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
		OpDeleteQueueEntry(button, entry)
		table.insert(GnomeWorks.data.queueData[queuePlayer], entry)

		GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged GnomeWorksSkillListChanged GnomeWorksDetailsChanged")
	end

	local function OpMoveQueueEntryToTop(button,entry)
		OpDeleteQueueEntry(button, entry)
		table.insert(GnomeWorks.data.queueData[queuePlayer], 1, entry)

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


									if entry.itemID then
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
									else
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
					text = "Select Recipe Source",
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
									if entry.recipeID then
										if button == "LeftButton" then
											GnomeWorks:PushSelection()
											GnomeWorks:SelectRecipe(entry.recipeID)
										else
											if entry.manualEntry then
												local recipeMenu = cellFrame.header.recipeMenuManualEntry

												for i=1,#recipeMenu do
													recipeMenu[i].arg1 = entry
												end

												ColumnControl(cellFrame, button, source, "recipeMenuManualEntry")
											else
												local recipeMenu = cellFrame.header.recipeMenuCrafted

												local sortMenu = {}

--												for recipeID in pairs(GnomeWorks.data.itemSource[entry.itemID]) do
												for k,subEntry in ipairs(entry.parent) do
													if subEntry.command == "create" then
														local menuEntry = {}

														local results = GnomeWorks:GetRecipeData(subEntry.recipeID)

														menuEntry.text = math.ceil(subEntry.numNeeded / results[subEntry.itemID]).." x "..GnomeWorks:GetRecipeName(subEntry.recipeID)
														menuEntry.checked = subEntry == entry
														menuEntry.arg1 = subEntry
														menuEntry.arg2 = entry
														menuEntry.func = OpQueueRecipeSwap

														sortMenu[#sortMenu+1] = menuEntry
													end
												end

												recipeMenu[1].menuList = sortMenu

												ColumnControl(cellFrame, button, source, "recipeMenuCrafted")
											end
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
						cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8+4+12, 0)
						cellFrame.button:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8, 0)
						local craftable

						if entry.subGroup and (entry.command == "options" or entry.count > entry.numCraftable) then
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
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t %s (%s)",icon or "",GnomeWorks:GetRecipeName(entry.recipeID), entry.sourcePlayer)
								else
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t %s",icon or "",GnomeWorks:GetRecipeName(entry.recipeID))
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
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t |cffd0d090 %s (x%d)",icon or "",GnomeWorks:GetRecipeName(entry.recipeID),results[entry.itemID])
								else
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t |cffd0d090 %s",icon or "",GnomeWorks:GetRecipeName(entry.recipeID))
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
								cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t |ca040ffffCraft|r |cffc0c0c0%s",GetItemIcon(entry.itemID) or "",itemName)
							else
								local c = "|cffb0b000"

								if GnomeWorks:VendorSellsItem(entry.itemID) then
									c = "|cff00b000"
								end



								if not entry.source then
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t %sPurchase|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "",c,itemName)
								else
									cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t %sFrom %s%s|r |cffc0c0c0%s", GetItemIcon(entry.itemID) or "",c, inventoryColors[entry.source],entry.source,itemName)
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
							cellFrame.text:SetFormattedText("|T%s:16:16:0:-2|t Crafting Options for %s", GetItemIcon(entry.itemID),(GetItemInfo(entry.itemID)))
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
		queueFrame:SetPoint("TOP", frame, 0, -45)
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
				if entry.numCraftable >= entry.count then
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


		frame:SetMinResize(300,200)

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


		local control = CreateControlButtons(frame)

		control:SetPoint("TOP", sf, "BOTTOM", 0,5)


		table.insert(UISpecialFrames, "GnomeWorksQueueFrame")

		frame:HookScript("OnShow", function() PlaySound("igCharacterInfoOpen")  GnomeWorks:ShowQueueList() end)
		frame:HookScript("OnHide", function() PlaySound("igCharacterInfoClose") end)


		frame:Hide()

		return frame
	end

end

