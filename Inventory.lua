

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

do
	local itemVisited = {}
	local GnomeWorks = GnomeWorks
	local GnomeworksDB = GnomeWorksDB

	local bagThrottleTimer


	function GnomeWorks:BAG_UPDATE(event,bag)
		if bagThrottleTimer then
			self:CancelTimer(bagThrottleTimer, true)
		end

		bagThrottleTimer = self:ScheduleTimer("InventoryScan",.1)
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
	function GnomeWorks:InventoryReagentCraftability(craftabilityTable, reagentID, player, containerList)
		if craftabilityTable[reagentID] then
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
				if self:IsSpellKnown(childRecipeID, player) then
					if count >= 1 then
--print("Child Recipe", reagentID, childRecipeID)
						local childResults, childReagents = self:GetRecipeData(childRecipeID)

						numReagentsCraftable = numReagentsCraftable + CalculateRecipeCrafting(craftabilityTable, childReagents, player, containerList) * count
					end
				end
			end
		end

		local inventoryCount = self:GetInventoryCount(reagentID, player, containerList) + numReagentsCraftable

		craftabilityTable[reagentID] = inventoryCount
--[[
		if inventoryCount ~= 0 then
			craftabilityTable[reagentID] = inventoryCount
		else
			craftabilityTable[reagentID] = nil
		end
]]

		itemVisited[reagentID] = false										-- okay to calculate this reagent again

		return inventoryCount
	end





	-- recipe iteration check: calculate how many times a recipe can be iterated with materials available
	-- (not to be confused with the reagent craftability which is designed to determine how many craftable reagents are available for recipe iterations)
	function GnomeWorks:InventoryRecipeIterations(recipeID, player, containerList)
--		local recipe = GnomeWorksDB.recipeDB[recipeID]


		local results, reagents = self:GetRecipeData(recipeID)


		if reagents then													-- make sure that recipe is in the database before continuing
			local numCraftable

			local vendorOnly = true

			for reagentID, numNeeded in pairs(reagents) do
				local reagentAvailability = self:GetInventoryCount(reagentID, player, containerList)

				if not self:VendorSellsItem(reagentID) then
					vendorOnly = nil
				end

				numCraftable = math.min(numCraftable or LARGE_NUMBER, math.floor(reagentAvailability/numNeeded))
			end

			if not numCraftable then
				numCraftable = LARGE_NUMBER
			end

			GnomeWorksDB.vendorOnly[recipeID] = vendorOnly

			return math.max(0,numCraftable)
		else
			DEFAULT_CHAT_FRAME:AddMessage("can't calc craft iterations!")
		end

		return 0
	end



	function GnomeWorks:SetInventoryCount(itemID, player, container, count)
		self.data.inventoryData[player][container][itemID] = count
	end


	function GnomeWorks:ReserveItemForQueue(player, itemID, count)
		local inv = self.data.inventoryData[player]["queue"]

		inv[itemID] = (inv[itemID] or 0) - count					-- queue "inventory" is negative meaning that it requires these items


--		print(player, (GetItemInfo(itemID)), count, -inv[itemID])
	end


	function GnomeWorks:GetInventoryCount(itemID, player, containerList)
		if player ~= "faction" then
			local inventoryData = self.data.inventoryData[player]

			if inventoryData then
				local count = 0

				for k,container in pairs(StringIterator(containerList)) do -- string.gmatch(containerList, "%a+") do
					if container == "vendor" then
						if self:VendorSellsItem(itemID) then
							return LARGE_NUMBER
						end
					elseif container == "guildBank" and self.data.playerData[player].guild then
						local key = "GUILD:"..self.data.playerData[player].guild

						if self.data.inventoryData[key] and self.data.inventoryData[key].bank then
							count = count + (self.data.inventoryData[key].bank[itemID] or 0)
						end

						count = count + (inventoryData.bank[itemID] or 0)
					else
						if inventoryData[container] then
							count = count + (inventoryData[container][itemID] or 0)
						end
					end
				end

				return count
			end

			return 0
		else -- faction-wide materials
			local count = 0


			for k,container in pairs(StringIterator(containerList)) do -- string.gmatch(containerList, "%a+") do
				if container == "vendor" then
					if self:VendorSellsItem(itemID) then
						return LARGE_NUMBER
					end
				end


				for inv, inventoryData in pairs(self.data.inventoryData) do
					local c = container

					if container == "craftedGuildBank" and self.data.playerData[inv] and not self.data.playerData[inv].guild then
						c = "craftedBank"
					end

					if inventoryData[c] then
						count = count + (inventoryData[c][itemID] or 0)
					end
				end

			end

			return count
		end

		return 0
	end


	local containerChild = {
		["bank"] = "bag",
		["guildBank"] = "bank",
	}

-- gets the inventory count exclusive of heirarchy
	function GnomeWorks:GetInventoryCountExclusive(itemID, player, containerList, factionPlayer)
		if player ~= "faction" then
			local inventoryData = self.data.inventoryData[player]

			if inventoryData then
				local count = 0

				for k,container in pairs(StringIterator(containerList)) do  -- string.gmatch(containerList, "%a+") do
					if container == "vendor" then
						if self:VendorSellsItem(itemID) then
							return LARGE_NUMBER
						end
					elseif container == "guildBank" and self.data.playerData[player].guild then
						local key = "GUILD:"..self.data.playerData[player].guild

						if self.data.inventoryData[key] and self.data.inventoryData[key].bank then
							count = count + (self.data.inventoryData[key].bank[itemID] or 0)
						end
					else
						if inventoryData[container] then
							if containerChild[container] and inventoryData[containerChild[container]] then
								count = count + (inventoryData[container][itemID] or 0) - (inventoryData[containerChild[container]][itemID] or 0)
							else
								count = count + (inventoryData[container][itemID] or 0)
							end
						end
					end
				end

				return count
			end

			return 0
		else -- faction-wide materials
			local count = 0

			for k,container in pairs(StringIterator(containerList)) do  --string.gmatch(containerList, "%a+") do
				if container == "vendor" then
					if self:VendorSellsItem(itemID) then
						return LARGE_NUMBER
					end
				end

				for inv, inventoryData in pairs(self.data.inventoryData) do
					if inv ~= factionPlayer then
						if container == "craftedGuildBank" and self.data.playerData[inv] and not self.data.playerData[inv].guild then
							container = "craftedBank"
						end

						if inventoryData[container] then
							count = count + (inventoryData[container][itemID] or 0)
						end
					end
				end
			end

			return count
		end

		return 0
	end


	local invscan = 1

	function GnomeWorks:InventoryScan(playerOverride)
		local scanTime = GetTime()
	--DEFAULT_CHAT_FRAME:AddMessage("InventoryScan "..invscan)
		invscan = invscan + 1
		local player = playerOverride or self.player
		local inventory = self.data.inventoryData[player]

		if inventory then
			if not inventory["bag"] then
				inventory["bag"] = {}
			end

			if not inventory["bank"] then
				inventory["bank"] = {}
			end

			if not inventory["craftedBag"] then
				inventory["craftedBag"] = {}
			end

			if not inventory["craftedBank"] then
				inventory["craftedBank"] = {}
			end


			if self.data.playerData[player].guild then
				if not inventory["craftedGuildBank"] then
					inventory["craftedGuildBank"] = {}
				end
			else
				inventory["craftedGuildBank"] = nil
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
						inventory["bank"][itemID] = inBank
					else
						inventory["bank"][itemID] = nil
					end
			--DebugSpam(inventoryData[reagentID])
				end
			end




			local craftedBag = table.wipe(inventory["craftedBag"])
			local craftedBank = table.wipe(inventory["craftedBank"])
			local craftedGuildBank = inventory["craftedGuildBank"] and table.wipe(inventory["craftedGuildBank"])

			for reagentID, count in pairs(inventory["bag"]) do
				craftedBag[reagentID] = count
			end

			for reagentID, count in pairs(inventory["bank"]) do
				craftedBank[reagentID] = count
				if craftedGuildBank then
					craftedGuildBank[reagentID] = count
				end
			end

			if craftedGuildBank then
				local key = "GUILD:"..self.data.playerData[player].guild

				local guildBankInventory = self.data.inventoryData[key]

				if guildBankInventory and guildBankInventory.bank then
					for reagentID, count in pairs(guildBankInventory.bank) do
						craftedGuildBank[reagentID] = (craftedGuildBank[reagentID] or 0) + count
					end
				end
			end


			table.wipe(itemVisited)							-- this is a simple infinite loop avoidance scheme: basically, don't visit the same node twice

			for itemID in pairs(GnomeWorks.data.itemSource) do
				self:InventoryReagentCraftability(craftedBag, itemID, player, "craftedBag queue")
				self:InventoryReagentCraftability(craftedBank, itemID, player, "craftedBank queue")
				if craftedGuildBank then
					self:InventoryReagentCraftability(craftedGuildBank, itemID, player, "craftedGuildBank queue")
				end
			end


-- assign nil's to all 0 count items
			for name, container in pairs(inventory) do
				for itemID, count in pairs(container) do
					if count == 0 then
						craftedBag[itemID] = nil
					end
				end
			end
		end



--	DebugSpam("InventoryScan Complete")
		local elapsed = GetTime()-scanTime

		if elapsed > .5 then
			DebugSpam("|cffff0000WARNING: GnomeWorks Inventory Scan took ",math.floor(elapsed*100)/100," seconds")
		end

		GnomeWorks:SendMessageDispatch("GnomeWorksInventoryScanComplete")
--		GnomeWorks:SendMessageDispatch("GnomeWorksQueueChanged")
		GnomeWorks:SendMessageDispatch("GnomeWorksSkillListChanged")
		GnomeWorks:SendMessageDispatch("GnomeWorksDetailsChanged")
	end

end
