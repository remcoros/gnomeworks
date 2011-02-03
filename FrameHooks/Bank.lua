

do
	local bankLocked
	local bankBags = { -1, 5,6,7,8,9,10,11 }
	local bankScanComplete
	local bankCollectLocked

	local bagCache = { {}, {}, {}, {}, {}}

	local updateTimer


	local function FindBagSlot(itemID, count)
		if not itemID then return nil end

		local _, _, _, _, _, _, _, stackSize = GetItemInfo(itemID)

		local itemType = GetItemFamily(itemID)

		-- if item can go into a special bag, prefer to place it in one of those first
		if itemType then
			for bag = 1, 4 do
				local bagType = GetItemFamily(GetInventoryItemID("player",ContainerIDToInventoryID(bag)))

				if bagType and bagType ~= 0 and bit.band(bagType, itemType) == bagType then

					for i = 1, GetContainerNumSlots(bag) do
						if not bagCache[bag+1][i] then
							local link = GetContainerItemLink(bag, i)

							if link then
								local slotItemID = tonumber(string.match(link, "item:(%d+)"))

								if itemID == slotItemID then
									local _, inBag, locked  = GetContainerItemInfo(bag, i)

									if not locked and count + inBag <= stackSize then
										bagCache[bag+1][i] = true
										return bag, i
									end
								end
							else
								bagCache[bag+1][i] = true
								return bag,i
							end
						end
					end
				end
			end
		end

		-- if it can't fit in a special bag, then try any bag
		for bag = 0, 4 do
			local bagType = bag==0 and 0 or GetItemFamily(GetInventoryItemID("player",ContainerIDToInventoryID(bag)))

			if bagType == 0 then
				for i = 1, GetContainerNumSlots(bag) do
					if not bagCache[bag+1][i] then

						local link = GetContainerItemLink(bag, i)

						if link then
							local slotItemID = tonumber(string.match(link, "item:(%d+)"))

							if itemID == slotItemID then
								local _, inBag, locked  = GetContainerItemInfo(bag, i)

								if not locked and count + inBag <= stackSize then
									bagCache[bag+1][i] = true
									return bag, i
								end
							end
						else
							bagCache[bag+1][i] = true
							return bag, i
						end
					end
				end
			end
		end

		return nil
	end



	function GnomeWorks:BankCollectItems(singleItemID, singleItemCount)		-- pass an itemID, nil to collect all needed itemID or itemID, count to collect a specified number
--print("BankCollectItems")
		if bankCollectLocked then return end
--print("not-locked out")

		bankCollectLocked = true

		local itemMoved
		bankScanComplete = true
		-- temporarily disable bag update scanning while we're grabbing items from the bank.  we'll do a manual adjustment after each retrieval
		self:UnregisterEvent("BAG_UPDATE")


		local bagErr

		for id,cache in pairs(bagCache) do
			table.wipe(cache)
		end

		local player = self.player or UnitName("player")

		for k,bag in pairs(bankBags) do
			for i = 1, GetContainerNumSlots(bag), 1 do
				if GetContainerItemInfo(bag, i) then
					local link = GetContainerItemLink(bag, i)

					if link then
						local itemID = tonumber(string.match(link, "item:(%d+)"))

						if (singleItemID and itemID == singleItemID) or (not singleItemID and itemID) then

							local count = singleItemCount or self.data.shoppingQueueData[player].bank[itemID]

							if count and count > 0 then
								local _,numAvailable = GetContainerItemInfo(bag, i)

								ClearCursor()

								local itemName, _, _, _, _, _, _, stackSize = GetItemInfo(link)

								local numMoved

								if numAvailable < count then
									numMoved = numAvailable
								else
									numMoved = count
								end

								local toBag, toSlot = FindBagSlot(itemID, numMoved)

								if toBag then
			--						PickupContainerItem(bag, i)
									SplitContainerItem(bag, i, numMoved)

									PickupContainerItem(toBag, toSlot)


									if singleItemCount then
										singleItemCount = singleItemCount - numMoved
									else
										self.data.shoppingQueueData[player].bank[itemID] = self.data.shoppingQueueData[player].bank[itemID] - numMoved
									end

									self:print(string.format("collecting %s x %s from bank",itemName,numMoved))
									itemMoved = true
								elseif not bagErr then
									self:warning("cannot collect some items due to lack of bag space")
									bagErr = true
								end
							end
						end
					end
				end
			end
		end

		bankCollectLocked = nil

		self:RegisterEvent("BAG_UPDATE")

		if itemMoved then
			self:ScheduleTimer("InventoryScan",.25)
		end
	end


	function GnomeWorks:BANKFRAME_OPENED(...)
		if bankLocked then return end

		bankScanComplete = true


		bankLocked = true

		local bagErr

		local player = self.player or UnitName("player")

		for k,bag in pairs(bankBags) do
			for i = 1, GetContainerNumSlots(bag), 1 do
				if GetContainerItemInfo(bag, i) then
					local link = GetContainerItemLink(bag, i)

					if not link then
						bankScanComplete = false
					end
				end
			end
		end

		if bankScanComplete then
--			self:BankCollectItems()
		end

		self.atBank = true

		local bankQueue = self.data.shoppingQueueData[(UnitName("player"))].bank

		if bankQueue and next(bankQueue) then
			self:ShoppingListShow((UnitName("player")))
		end

		bankLocked = nil
	end

	function GnomeWorks:BANKFRAME_CLOSED(...)
		self.atBank = false
	end



	function GnomeWorks:GUILDBANKFRAME_OPENED(...)
		local numTabs = GetNumGuildBankTabs()

		for tab=1,numTabs do
			QueryGuildBankTab(tab)
		end

		self.atGuildBank = true

		local guildBankQueue = self.data.shoppingQueueData[(UnitName("player"))].guildBank

		if guildBankQueue and next(guildBankQueue) then
			self:ShoppingListShow((UnitName("player")))
		end
	end


	function GnomeWorks:GUILDBANKFRAME_CLOSED(...)
		self.atGuildBank = false
	end



	function GnomeWorks:GuildBankCollectItems(singleItemID, singleItemCount)		-- pass an itemID, nil to collect all needed itemID or itemID, count to collect a specified number
		if bankCollectLocked then return end

		bankCollectLocked = true


		local itemMoved
		local bagErr

		local player = UnitName("player")
		local playerData = self.data.playerData

		local guild = playerData[player].guild or GetGuildInfo("player")

		-- temporarily disable bag update scanning while we're grabbing items from the bank.  we'll do a manual adjustment after each retrieval
		self:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
		self:UnregisterEvent("BAG_UPDATE")


		local numTabs = GetNumGuildBankTabs()

		for tab=1,numTabs do
			if playerData[player].guildInfo.tabs[tab] then
				local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tab)

				if numWithdrawals > 0 and remainingWithdrawals > 0 then
					for slot=1,98 do

						local link = GetGuildBankItemLink(tab,slot)

						if link then
							local _,numAvailable = GetGuildBankItemInfo(tab, slot)
							local itemID = tonumber(string.match(link, "item:(%d+)"))

							if (singleItemID and itemID == singleItemID) or (not singleItemID and itemID) then
								local count = singleItemCount or self.data.shoppingQueueData[player].guildBank[itemID]

								if count and count > 0 then
									ClearCursor()

									local itemName, _, _, _, _, _, _, stackSize = GetItemInfo(link)

									local numMoved

									if numAvailable < count then
										numMoved = numAvailable
									else
										numMoved = count
									end

									local toBag, toSlot = FindBagSlot(itemID, numMoved)

									if toBag then
										SplitGuildBankItem(tab, slot, numMoved)

										PickupContainerItem(toBag, toSlot)

										if singleItemCount then
											singleItemCount = singleItemCount - numMoved
										else
											self.data.shoppingQueueData[player].guildBank[itemID] = self.data.shoppingQueueData[player].guildBank[itemID] - numMoved
										end

										self:print(string.format("collecting %s x %s from guild bank",itemName,numMoved))
										itemMoved = true
									elseif not bagErr then
										self:warning("cannot collect some items due to lack of bag space")
										bagErr = true
									end
								end
							end
						end
					end
				end
			end
		end

		bankCollectLocked = nil

		self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
		self:RegisterEvent("BAG_UPDATE")


		self:InventoryScan()
	end


	function GnomeWorks:GuildBankScan(...)
		if bankLocked then return end

		bankLocked = true
		bankScanComplete = true

		local itemMoved

		local player = UnitName("player")
		local playerData = self.data.playerData[player]

		local guild = GetGuildInfo("player")

		playerData.guildInfo.name = guild

		if not playerData.guildInfo.tabs then
			playerData.guildInfo.tabs = {}
		end

		if not self.data.guildInventory[guild] then
			self.data.guildInventory[guild] = {}
		end

		local invData = self.data.guildInventory[guild]


		table.wipe(invData)
--		table.wipe(playerData.guildInfo.tabs)

		local numTabs = GetNumGuildBankTabs()


		for tab=1,numTabs do
			local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tab)

			invData[tab] = {}

			if IsGuildLeader() or numWithdrawals>0 then
				playerData.guildInfo.tabs[tab] = true
			else
				playerData.guildInfo.tabs[tab] = false
			end

			for slot=1,98 do
				if GetGuildBankItemInfo(tab,slot) then
					local link = GetGuildBankItemLink(tab,slot)

					if link then
						local _,numAvailable = GetGuildBankItemInfo(tab, slot)
						local itemID = tonumber(string.match(link, "item:(%d+)"))

						if self.data.trackedItems[itemID] then
							invData[tab][itemID] = (invData[tab][itemID] or 0) + numAvailable
						end
					else
						bankScanComplete = false
					end
				end
			end
		end

		bankLocked = nil

		local dependency

		for k,inv in ipairs(GnomeWorksDB.config.inventoryIndex) do
			if inv == "guildBank" then
				dependency = k
				break
			end
		end

		for playerName, playerData in pairs(self.data.playerData) do
			if playerData.guild == guild then
				if dependency then
					for i=dependency,#GnomeWorksDB.config.inventoryIndex do
						if self.data.craftabilityData[playerName][GnomeWorksDB.config.inventoryIndex[i]] then
							table.wipe(self.data.craftabilityData[playerName][GnomeWorksDB.config.inventoryIndex[i]])
						end
					end
				end
			end
		end

		self:InventoryScan()

		if bankScanComplete then
--			self:GuildBankCollectItems()
		end
	end


	function GnomeWorks:GUILDBANKBAGSLOTS_CHANGED(...)
		if updateTimer then
			self:CancelTimer(updateTimer, true)
		end

		updateTimer = self:ScheduleTimer("GuildBankScan",.5)
	end
end


