
local vendorConversionTradeID = 100001

do
	local skillList = {}
	local recipeList, trade


	local function VendorConversionSpellID(itemID)
		return itemID+200000
	end

	local function VendorConversionItemID(spellID)
		return spellID-200000
	end


	function GnomeWorks:RecordVendorConversion(itemID, index)
		local spoofedRecipeID = VendorConversionSpellID(itemID)
		local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(index)
		local itemCount = GetMerchantItemCostInfo(index)

		local reagents = {}

		local recipes = GnomeWorksDB.vendorConversionRecipes

		if not recipes[spoofedRecipeID] then

			for n=1,itemCount do
				local itemTexture, itemValue, itemLink, itemName = GetMerchantItemCostItem(index, n)

				if itemLink then
					local costItemID = tonumber(string.match(itemLink,"item:(%d+)"))

					reagents[costItemID] = itemValue

					GnomeWorks:AddToReagentCache(costItemID, spoofedRecipeID, itemValue)
				else
					-- currency conversions.  hmm...
					return -- bail out cuz this stuff is tba
				end
			end

			recipes[spoofedRecipeID] = {}

			recipes[spoofedRecipeID].results = { [itemID] = quantity }


			recipes[spoofedRecipeID].name = string.format("Vendor Conversion: %s",name)

			recipes[spoofedRecipeID].reagents = reagents


			skillList[#skillList + 1] = spoofedRecipeID

			for player, knownSpellList in pairs(GnomeWorks.data.knownSpells) do
				knownSpellList[spoofedRecipeID] = #skillList
			end


			recipeList[spoofedRecipeID] = trade

			for reagentID, numNeeded in pairs(reagents) do
				GnomeWorks:AddToReagentCache(reagentID, spoofedRecipeID, numNeeded)
			end

			GnomeWorks:AddToItemCache(itemID, spoofedRecipeID, quantity)



			GnomeWorks:print("recording vendor conversion for item: ",name)
		end
	end





	local api = {}

	api.DoTradeSkill = function(recipeID, count)
		count = count or 1

		if GnomeWorks.atVendor then
			local itemID = VendorConversionItemID(recipeID)

			for i=1,GetMerchantNumItems() do
				local itemLink = GetMerchantItemLink(i)

				if itemLink then
					local merchantItemID = tonumber(string.match(itemLink,"item:(%d+)"))

					if merchantItemID == itemID then
						BuyMerchantItem(i,count)

						return true						-- return true will delete the entry
					end
				end
			end

			GnomeWorks:warning("Couldn't find item at vendor")
		else
			GnomeWorks:warning("Not at vendor")
		end
	end

	api.GetRecipeName = function(recipeID)
		if GnomeWorksDB.vendorConversionRecipes[recipeID] then
			return GnomeWorksDB.vendorConversionRecipes[recipeID].name
		end
	end

	api.GetRecipeData = function(recipeID)
		if GnomeWorksDB.vendorConversionRecipes[recipeID] then
			return GnomeWorksDB.vendorConversionRecipes[recipeID].results, GnomeWorksDB.vendorConversionRecipes[recipeID].reagents, vendorConversionTradeID
		end
	end


	api.GetNumTradeSkills = function()
		return #skillList
	end

	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]
		local itemID = next(GnomeWorksDB.vendorConversionRecipes[recipeID].results)

		local _,link = GetItemInfo(itemID)

		return link
	end

	api.GetTradeSkillRecipeLink = function(index)
		local recipeID = skillList[index]

		if recipeID < 0 then
			return "enchant:"..recipeID
		else
			return GetSpellLink(recipeID)
		end
	end


	api.GetTradeSkillLine = function()
		return "Common Skills", 1, 1
	end

	api.GetTradeSkillInfo = function(index)
		local recipeID = skillList[index]

		return (GetSpellInfo(recipeID)) or "nil", "optimal"
	end

	api.GetTradeSkillIcon = function(index)
		local recipeID = skillList[index]
		local itemID = next(GnomeWorksDB.vendorConversionRecipes[recipeID].results)

		return GetItemIcon(itemID)
	end

	api.IsTradeSkillLinked = function()
		return true
	end


	api.RecordKnownSpells = function(player)
		local knownSpells = GnomeWorks.data.knownSpells[player]

		if knownSpells then
			for i = 1, #skillList, 1 do
				local recipeID = skillList[i]

				knownSpells[recipeID] = i
			end
		else
			print("no known spells for",player)
		end
	end


	api.Scan = function()
		if not GnomeWorks.tradeID then
			return
		end

		local tradeID = GnomeWorks.tradeID
		local player = GnomeWorks.player

		local key = player..":"..tradeID

		local lastHeader = nil
		local gotNil = false

		local currentGroup = nil


		local flatGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"Flat")

		flatGroup.locked = true
		flatGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(flatGroup)

		local groupList = {}

		local numHeaders = 0

		for i = 1, #skillList, 1 do
			local subSpell, extra

			local skillName, skillType -- = GetTradeSkillInfo(i)

			if skillType == "header" then
				numHeaders = numHeaders + 1

				local groupName

				if groupList[skillName] then
					groupList[skillName] = groupList[skillName]+1
					groupName = skillName.." "..groupList[skillName]
				else
					groupList[skillName] = 1
					groupName = skillName
				end

				currentGroup = GnomeWorks:RecipeGroupNew(player, tradeID, "By Category", groupName)
				currentGroup.autoGroup = true

				GnomeWorks:RecipeGroupAddSubGroup(mainGroup, currentGroup, i, true)
			else
				local recipeID = skillList[i]

				GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)

--[[
				if currentGroup then
					GnomeWorks:RecipeGroupAddRecipe(currentGroup, recipeID, i, true)
				else
					GnomeWorks:RecipeGroupAddRecipe(mainGroup, recipeID, i, true)
				end
]]
--				difficulty[i] = "optimal"


--				skillIndexLookup[recipeID] = i
			end
		end

		GnomeWorks:InventoryScan()

		collectgarbage("collect")

		GnomeWorks:ScheduleTimer("UpdateMainWindow",.1)
		GnomeWorks:SendMessageDispatch("GnomeWorksScanComplete")
		return
	end




	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes", function ()
		trade,recipeList  = GnomeWorks:AddPseudoTrade(vendorConversionTradeID,api)


		if not GnomeWorksDB.vendorConversionRecipes then
			GnomeWorksDB.vendorConversionRecipes = {}
		end

		local recipes = GnomeWorksDB.vendorConversionRecipes

		for recipeID, data in pairs(recipes) do
			skillList[#skillList + 1] = recipeID

			recipeList[recipeID] = trade

			GnomeWorks:AddToItemCache(itemID, recipeID, numMade)

			for reagentID, numNeeded in pairs(data.reagents) do
				GnomeWorks:AddToReagentCache(reagentID, recipeID, numNeeded)
			end
		end

		mainRecipeList = recipeList

		trade.skillList = skillList

		return true
	end)
end




