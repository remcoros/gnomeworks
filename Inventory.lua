

local function DebugSpam(...)
	print(...)
end


local stringIteratorList = {}

local function StringIterator(list)
	if not stringIteratorList[list] then
		stringIteratorList[list] = { strsplit(" ",list) }
	end

	return stringIteratorList[list]
end


local LARGE_NUMBER = 1000000




-- guild toggle options
do
	local plugin

	local function RegisterAccessToggle()

		local function Init()
			local function toggle(guild,tab)
				if tab then
					return function()
						GnomeWorksDB.config.altGuildAccess[guild][tab] = not GnomeWorksDB.config.altGuildAccess[guild][tab]

						GnomeWorks:InventoryScan()
					end
				else
					return function()
						local on

						for i=1,6 do
							if GnomeWorksDB.config.altGuildAccess[guild][i] then
								on = true
								break
							end
						end

						for i=1,6 do
							GnomeWorksDB.config.altGuildAccess[guild][i] = not on
						end

						GnomeWorks:InventoryScan()
					end
				end
			end


			local guilds = 0

			for guildName,inv in pairs(GnomeWorks.data.guildInventory) do
				guilds = guilds + 1

				local button = plugin:AddButton(guildName, toggle(guildName))
				button.checked = 	function()
										if not GnomeWorksDB.config.altGuildAccess[guildName] then
											return false
										end

										for t in ipairs(GnomeWorks.data.guildInventory[guildName]) do
											if GnomeWorksDB.config.altGuildAccess[guildName][t] then
												return true
											end
										end

										return false
									end


				button.keepShownOnClick = 1


				if not GnomeWorksDB.config.altGuildAccess[guildName] then
					GnomeWorksDB.config.altGuildAccess[guildName] = {false, false, false, false, false, false }
				end

				for tab in pairs(inv) do
					local tabButton = button:AddButton("tab "..tab, toggle(guildName,tab))
					tabButton.checked = function() return GnomeWorksDB.config.altGuildAccess[guildName] and GnomeWorksDB.config.altGuildAccess[guildName][tab] end

					tabButton.keepShownOnClick = 1
				end
			end

			if guilds == 0 then
				plugin:AddButton("No Guild Inventories Found")
			end
		end

		Init()

		return true
	end



	plugin = GnomeWorks:RegisterPlugin("Alt GuildBank Access", RegisterAccessToggle)
end



-- inventory toggle options
do
	function GnomeWorks:BuildInventoryHeirarchy()
		local config = GnomeWorksDB.config
		local basis = self.system.inventoryBasis
		local source = "queue"
		local purge

		local index = config.inventoryIndex

		table.wipe(index)
		table.wipe(basis)


		for k,container in ipairs(GnomeWorks.system.inventoryIndex) do
			if config.inventoryTracked[container] then
				local newSource = source.." "..container

				basis[container] = newSource

				source = newSource

				if container ~= "alt" then
					GnomeWorks.system.factionContainer = container
				end

				index[#index+1] = container

			else
				purge = true
			end

			if purge then
				GnomeWorks:CraftableInventoryPurge(container)
			end
		end

		table.wipe(config.containerIndex)

		for k,container in ipairs(GnomeWorks.system.containerIndex) do
			if config.inventoryTracked[container] then
				config.containerIndex[#config.containerIndex+1] = container
			end
		end


		table.wipe(config.collectInventories)

		for k,container in ipairs(GnomeWorks.system.collectInventories) do
			if config.inventoryTracked[container] then
				config.collectInventories[#config.collectInventories+1] = container
			end
		end

		GnomeWorks:InventoryScan()
	end


--[[
	function GnomeWorks:DisableInventoryContainer(container)
		local config = GnomeWorksDB.config

		config.inventoryTracked[container] = false

		GnomeWorks:BuildInventoryHeirarchy()
	end


	function GnomeWorks:EnableInventoryContainer(container)
		local config = GnomeWorksDB.config

		config.inventoryTracked[container] = true

		GnomeWorks:BuildInventoryHeirarchy()
	end
]]
	local plugin

	local function RegisterInventoryToggle()

		local function Init()
			local function toggle(inv)
				return function()
					GnomeWorksDB.config.inventoryTracked[inv] = not GnomeWorksDB.config.inventoryTracked[inv]

					GnomeWorks:BuildInventoryHeirarchy()
				end
			end


			for k,inv in ipairs(GnomeWorks.system.inventoryIndex) do
				local button = plugin:AddButton(GnomeWorks.system.inventoryColors[inv]..inv, toggle(inv))
				button.checked = function() return GnomeWorksDB.config.inventoryTracked[inv] end

				button.keepShownOnClick = 1
			end
		end

		Init()

		return true
	end



	plugin = GnomeWorks:RegisterPlugin("Toggle Inventories", RegisterInventoryToggle)
end




do
	local itemVisited = {}
	local GnomeWorks = GnomeWorks
	local GnomeworksDB = GnomeWorksDB


	function GnomeWorks:CraftabilityPurge(player, itemID)
		player = player or self.player or UnitName("player")

		if not itemID then
			for container,data in pairs(self.data.craftabilityData[player]) do
				table.wipe(data)
			end
		else
			local reagentUsage = self.data.reagentUsage[itemID]
			if self.data.craftabilityData[player] then
				for container,data in pairs(self.data.craftabilityData[player]) do
					data[itemID] = nil
					if reagentUsage then
						itemUncached = self:UncacheReagentCounts(player, data, reagentUsage)
					end
				end
			end
		end
	end


	function GnomeWorks:Restack(itemID,minSize)
		local _, itemLink, _, _, _, _, _, stackSize = GetItemInfo(itemID)

		if not minSize then
			minSize = stackSize
		end

		if GetItemCount(itemID)<minSize then
			return
		end

		local targetBag
		local targetSlot
		local targetSize


		for bag = 0, 4 do
			for i = 1, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, i)
				local bagItemID

				if link then
					bagItemID = tonumber(string.match(link,"item:(%d+)"))
				end

				if itemID == bagItemID then

					local _, inBag, locked  = GetContainerItemInfo(bag, i)

					if not targetSlot then
						if not locked and inBag <= minSize then
							targetBag = bag
							targetSlot = i
							targetSize = inBag
						end
					else
						if not locked then
							numMoved = math.min(stackSize-targetSize, inBag)

							SplitContainerItem(bag, i, numMoved)

							PickupContainerItem(targetBag, targetSlot)

							targetSize = targetSize + numMoved

							return
						end
					end
				end
			end
		end
	end




	local bagThrottleTimer

--[[
	local inventoryList = {
		"craftedBag", "craftedBank", "craftedMail", "craftedGuildBank"
	}

	local inventorySourceTable = {
		craftedBag = "bag queue",
		craftedBank = "bag bank queue",
		craftedMail = "bag bank mail queue",
		craftedGuildBank = "bag bank mail guildBank queue",
	}
]]

	local longestScanTime = .25




	function GnomeWorks:BagScan()
		local player = UnitName("player")
		local invData = self.data.inventoryData[player]
		local craftData = self.data.craftabilityData[player]

		local inventoryTracked = GnomeWorksDB.config.inventoryTracked

		if invData then
			local bag = invData.bag
			local bank = invData.bank

			local itemUncached

			for itemID in pairs(GnomeWorks.data.trackedItems) do
				local inBag = GetItemCount(itemID)
				local inBank = GetItemCount(itemID,true) - inBag
				local recahe

				if (bag[itemID] or 0) ~= inBag then
					bag[itemID] = inBag
					recache = true
				end

				if (bank[itemID] or 0) ~= inBank then
					bank[itemID] = inBank
					recache = true
				end

				if recache then
					local reagentUsage = self.data.reagentUsage[itemID]

					for invLabel,isTracked in pairs(inventoryTracked) do
						if isTracked then
							if craftData[invLabel] then

								craftData[invLabel][itemID] = nil
								if reagentUsage then
									itemUncached = self:UncacheReagentCounts(player, craftData[invLabel], reagentUsage)
								end
							end
						end
					end
				end
			end

			if itemUncached then
				GnomeWorks:InventoryProcess(player)

				GnomeWorks:SendMessageDispatch("InventoryScanComplete")
			else
--				GnomeWorks:InventoryProcess(player)

				GnomeWorks:SendMessageDispatch("InventoryScanComplete")
			end
		end
	end




	function GnomeWorks:BAG_UPDATE(event,bag)
		if bagThrottleTimer then
			self:CancelTimer(bagThrottleTimer, true)
		end

		if false and GnomeWorks.isProcessing then
			bagThrottleTimer = self:ScheduleTimer("BagScan",5)
		else
			bagThrottleTimer = self:ScheduleTimer("BagScan",.01)
		end
	end



	local function CalculateRecipeCrafting(craftabilityTable, reagents, player, containerList)
		if not reagents or not containerList then
			return 0
		end

		local numCraftable = LARGE_NUMBER

		for reagentID, numNeeded in pairs(reagents) do
			local numReagentCraftable = craftabilityTable[reagentID] or GnomeWorks:InventoryReagentCraftability(craftabilityTable, reagentID, player, containerList)

			numCraftable = math.min(numCraftable, math.floor(numReagentCraftable/numNeeded))
		end

		return  numCraftable
	end


	-- recursive reagent craftability check
	-- utilizes all containers passed to it ("bag", "bank", "queue", "guildbank", "mail", etc)
	function GnomeWorks:InventoryReagentCraftability(craftabilityTable, reagentID, player, containerList, forceRecache)
		if not forceRecache and craftabilityTable[reagentID] then
			return craftabilityTable[reagentID]		-- return the cached value
		end

		if itemVisited[reagentID] then
			return 0			-- we've been here before, so bail out to avoid infinite loop
		end

		itemVisited[reagentID] = true


		local recipeSource = GnomeWorks.data.itemSource[reagentID]

		local numReagentsCraftable = 0

		if recipeSource then
			for childRecipeID, count in pairs(recipeSource) do
				if self:IsSpellKnown(childRecipeID, player) and not GnomeWorksDB.recipeBlackList[recipeID] then
					if count >= 1 then
--print("Child Recipe", reagentID, childRecipeID)
						local childResults, childReagents = self:GetRecipeData(childRecipeID)

						numReagentsCraftable = numReagentsCraftable + CalculateRecipeCrafting(craftabilityTable, childReagents, player, containerList) * count
					end
				end
			end
		end

--		local inventoryCount = self:GetInventoryCount(reagentID, player, containerList) + numReagentsCraftable

		local inventoryCount = self:GetInventoryCount(reagentID, player, containerList) + numReagentsCraftable

		craftabilityTable[reagentID] = inventoryCount

		itemVisited[reagentID] = false										-- okay to calculate this reagent again
		return inventoryCount
	end



	-- recipe iteration check: calculate how many times a recipe can be iterated with materials available
	-- (not to be confused with the reagent craftability which is designed to determine how many craftable reagents are available for recipe iterations)
	function GnomeWorks:InventoryRecipeIterations(recipeID, player, containerList)
--		local recipe = GnomeWorksDB.recipeDB[recipeID]


		local results, reagents = self:GetRecipeData(recipeID)


		if reagents then													-- make sure that recipe is in the database before continuing
			local numCraftable = LARGE_NUMBER

			local vendorOnly = true

			for reagentID, numNeeded in pairs(reagents) do

				local reagentAvailability

				if not containerList then
					reagentAvailability = self:GetInventoryCount(reagentID,player,"bag") or 0
				else
					if player ~= "faction" and containerList ~= "alt" then
						reagentAvailability = self:GetCraftableInventoryCount(reagentID, player, containerList)
					else
						reagentAvailability = self:GetCraftableInventoryCount(reagentID, player, GnomeWorksDB.config.inventoryIndex[#GnomeWorksDB.config.inventoryIndex-1])
											 + self:GetFactionInventoryCount(reagentID, GnomeWorks.player)
					end
				end

--print(GnomeWorks:GetRecipeName(recipeID), (GetItemInfo(reagentID)), containerList, reagentAvailability)
				if not self:VendorSellsItem(reagentID) then
					vendorOnly = nil
				end

				numCraftable = math.min(numCraftable, math.floor(reagentAvailability/numNeeded))
			end

			GnomeWorksDB.vendorOnly[recipeID] = vendorOnly

			return math.max(0,numCraftable)
		else
--			DEFAULT_CHAT_FRAME:AddMessage("can't calc craft iterations!")
		end

		return 0
	end



	function GnomeWorks:SetInventoryCount(itemID, player, container, count)
		self.data.inventoryData[player][container][itemID] = count
	end


	function GnomeWorks:UncacheReagentCounts(player, invData, reagentUsage)
		local uncached

		for recipeID in pairs(reagentUsage) do
			if self.data.knownSpells[player][recipeID] then

				local results, reagents = self:GetRecipeData(recipeID)

				if results then
					for itemID in pairs(results) do
						if invData[itemID] then
							uncached = true
							invData[itemID] = nil

							local subUsage = self.data.reagentUsage[itemID]

							if subUsage then
								self:UncacheReagentCounts(player, invData, subUsage)
							end
						end
					end
				end
			end
		end

		return uncached
	end



	function GnomeWorks:ReserveItemForQueue(player, itemID, count)
		local invData = self.data.inventoryData[player]
		local craftData = self.data.craftabilityData[player]

		local inv = invData.queue

		inv[itemID] = (inv[itemID] or 0) - count					-- queue "inventory" is negative meaning that it requires these items

		local reagentUsage = self.data.reagentUsage[itemID]


		local inventoryTracked = GnomeWorksDB.config.inventoryTracked


		for invLabel,isTracked in pairs(inventoryTracked) do
			if isTracked then
				if craftData[invLabel] then
					craftData[invLabel][itemID] = nil
					if reagentUsage then
						self:UncacheReagentCounts(player, craftData[invLabel], reagentUsage)
					end
				end
			end
		end
	end



	local function GetGuildInventory(itemID, guildInfo)
		local count = 0

		if itemID and guildInfo then
			local guildName = guildInfo.name
			local invData = GnomeWorks.data.guildInventory[guildName]
			local tabAccess = guildInfo.tabs

			if invData then
				for tab,tabData in ipairs(invData) do
					if tabData[itemID] and tabAccess[tab] then
						count = count + tabData[itemID]
					end
				end
			end
		end

		return count
	end



	function GnomeWorks:GetInventoryCount(itemID, player, containerList)
		local inventoryData = self.data.inventoryData[player]

		if inventoryData then
			local guildInfo = self.data.playerData[player].guildInfo

			local count = 0

			for k,container in pairs(StringIterator(containerList)) do -- string.gmatch(containerList, "%a+") do
				if container == "vendor" then
					if self:VendorSellsItem(itemID) then
						return LARGE_NUMBER
					end
				elseif container == "guildBank" and guildInfo then
					count = count + GetGuildInventory(itemID, guildInfo)
				else
					if inventoryData[container] and inventoryData[container][itemID] then
						count = count + inventoryData[container][itemID]
					end
				end
			end

			return count
		end

		return 0
	end


	function GnomeWorks:GetCraftableInventoryCount(itemID, player, containerList)
		local inventoryData = self.data.craftabilityData[player]

		if inventoryData then
			local guildInfo = self.data.playerData[player].guildInfo

			local count = 0

			for k,container in pairs(StringIterator(containerList)) do -- string.gmatch(containerList, "%a+") do
				if inventoryData[container] and inventoryData[container][itemID] then
					count = count + inventoryData[container][itemID]
				else

					local inventoryBasis = self.system.inventoryBasis[container]
--print("calculate counts", container, itemID, (GetItemInfo(itemID)))--, debugstack(1,2,0))

					if inventoryBasis and inventoryData[container] then
						self:InventoryReagentCraftability(inventoryData[container], itemID, player, inventoryBasis)
--if itemID == 4371 then
--	print("calculating craftability",container, "basis", inventoryBasis, inventoryData[container][itemID])
--end
						count = count + (inventoryData[container][itemID] or 0)
					else
						count = count or 0
					end
				end
			end

			return count
		end

		return 0
	end


-- factionwide inventory counts
	function GnomeWorks:GetFactionInventoryCount(itemID, factionPlayer)
--		if self:VendorSellsItem(itemID) then
--			return LARGE_NUMBER
--		end

		local count = 0
		local inventoryIndex = GnomeWorksDB.config.containerIndex

		for player, inventoryData in pairs(self.data.inventoryData) do
			if player ~= factionPlayer then

				for k,container in ipairs(inventoryIndex) do
					if inventoryData[container] then
						count = count + (inventoryData[container][itemID] or 0)
					end
				end
			end
		end

		local playerGuild = factionPlayer and self.data.playerData[factionPlayer] and self.data.playerData[factionPlayer].guild

		local altGuildAccess = GnomeWorksDB.config.altGuildAccess

		for guild,inventoryData in pairs(self.data.guildInventory) do
			if guild ~= playerGuild then

				for tab,tabData in ipairs(inventoryData) do
					if altGuildAccess[guild] and altGuildAccess[guild][tab] then
						count = count + (tabData[itemID] or 0)
					end
				end
			end
		end

		return count
	end



	function GnomeWorks:InventoryProcess(player)
		player = player or self.player
		local inventory = self.data.inventoryData[player]
		local craftData = self.data.craftabilityData[player]

		local scanTime = GetTime()

--		for inv,data in pairs(craftData) do
--			table.wipe(data)
--		end

--[[
		if craftedGuildBank then
			local key = "GUILD:"..self.data.playerData[player].guild

			local guildBankInventory = self.data.inventoryData[key]

			if guildBankInventory and guildBankInventory.bank then
				for reagentID, count in pairs(guildBankInventory.bank) do
					craftedGuildBank[reagentID] = (craftedGuildBank[reagentID] or 0) + count
				end
			end
		end
]]

		local inventoryTracked = GnomeWorksDB.config.inventoryTracked

		for inv,isTracked in ipairs(inventoryTracked) do
			if isTracked then
				table.wipe(itemVisited)

				local invData = inventory[inv]

				if invData then
					for itemID in pairs(GnomeWorks.data.itemSource) do
						self:InventoryReagentCraftability(invData, itemID, player, inventorySourceTable[inv])
					end
				end
			end
		end


		local elapsed = GetTime()-scanTime

		if elapsed > longestScanTime then
			DebugSpam("|cffff0000WARNING: GnomeWorks Inventory Scan took ",math.floor(elapsed*100)/100," seconds")
			longestScanTime = elapsed
		end
	end



	function GnomeWorks:InventoryScan(playerOverride)
		local player = playerOverride or self.player
		local inventory = self.data.inventoryData[player]
		local craftData = self.data.craftabilityData[player]

		if inventory then
			if self.data.playerData[player].guild then
				if not craftData.guildBank then
					craftData.guildBank = {}
				end
			else
				craftData.guildBank = nil
			end


			if player == (UnitName("player")) then
				for itemID in pairs(GnomeWorks.data.trackedItems) do
					local inBag = GetItemCount(itemID)
					local inBank = GetItemCount(itemID,true)

					if inBag>0 then
						inventory["bag"][itemID] = inBag
					else
						inventory["bag"][itemID] = nil
					end

					if inBank>0 then
						inventory["bank"][itemID] = inBank - inBag
					else
						inventory["bank"][itemID] = nil
					end
			--DebugSpam(inventoryData[reagentID])
				end
			end



--[[
			if player == "Judithpriest" then
				for itemID in pairs(GnomeWorks.data.trackedItems) do
					inventory.bag[itemID] = mod(itemID, 20)
					inventory.bank[itemID] = mod(itemID, 50)
			--DebugSpam(inventoryData[reagentID])
				end
			end
]]
		end

		GnomeWorks:InventoryProcess(playeOverride)

		GnomeWorks:SendMessageDispatch("InventoryScanComplete")
--	DebugSpam("InventoryScan Complete")

	end




	function GnomeWorks:CraftableInventoryPurge(container)
		for player,t in pairs(self.data.craftabilityData) do
			if t[container] then
				table.wipe(t[container])
			end
		end
	end
end



