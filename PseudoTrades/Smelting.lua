

-- smelting support


-- add smelting data from wowhead html source
do
	local smeltingData = {
		[74529] = {			--Smelt Pyrite
			reagents = {
				[52183] = 2
			},
			results = {
				[51950] = 1
			},
			levels = "0/0/525",
		},
		[74537] = {			--Smelt Hardened Elementium
			reagents = {
				[52186] = 10,
				[52327] = 4
			},
			results = {
				[53039] = 1
			},
			levels = "500/500/525",
		},
		[46353] = {			--Smelt Hardened Khorium
			reagents = {
				[23449] = 3,
				[23573] = 1
			},
			results = {
				[35128] = 1
			},
			levels = "0/0/375",
		},
		[3307] = {			--Smelt Iron
			reagents = {
				[2772] = 1
			},
			results = {
				[3575] = 1
			},
			levels = "130/145/160",
		},
		[2658] = {			--Smelt Silver
			reagents = {
				[2775] = 1
			},
			results = {
				[2842] = 1
			},
			levels = "115/122/130",
		},
		[10097] = {			--Smelt Mithril
			reagents = {
				[3858] = 1
			},
			results = {
				[3860] = 1
			},
			levels = "175/202/230",
		},
		[55208] = {			--Smelt Titansteel
			reagents = {
				[36860] = 1,
				[35627] = 1,
				[41163] = 3,
				[35624] = 1
			},
			results = {
				[37663] = 1
			},
			levels = "0/0/450",
		},
		[29686] = {			--Smelt Hardened Adamantite
			reagents = {
				[23446] = 10
			},
			results = {
				[23573] = 1
			},
			levels = "0/0/375",
		},
		[29356] = {			--Smelt Fel Iron
			reagents = {
				[23424] = 2
			},
			results = {
				[23445] = 1
			},
			levels = "275/300/325",
		},
		[10098] = {			--Smelt Truesilver
			reagents = {
				[7911] = 1
			},
			results = {
				[6037] = 1
			},
			levels = "250/270/290",
		},
		[3569] = {			--Smelt Steel
			reagents = {
				[3575] = 1,
				[3857] = 1
			},
			results = {
				[3859] = 1
			},
			levels = "0/0/165",
		},
		[49258] = {			--Smelt Saronite
			reagents = {
				[36912] = 2
			},
			results = {
				[36913] = 1
			},
			levels = "0/0/400",
		},
		[55211] = {			--Smelt Titanium
			reagents = {
				[36910] = 2
			},
			results = {
				[41163] = 1
			},
			levels = "0/0/450",
		},
		[29358] = {			--Smelt Adamantite
			reagents = {
				[23425] = 2
			},
			results = {
				[23446] = 1
			},
			levels = "325/332/340",
		},
		[29361] = {			--Smelt Khorium
			reagents = {
				[23426] = 2
			},
			results = {
				[23449] = 1
			},
			levels = "0/0/375",
		},
		[29359] = {			--Smelt Eternium
			reagents = {
				[23427] = 2
			},
			results = {
				[23447] = 1
			},
			levels = "350/357/365",
		},
		[74530] = {			--Smelt Elementium
			reagents = {
				[52185] = 2
			},
			results = {
				[52186] = 1
			},
			levels = "475/475/500",
		},
		[3304] = {			--Smelt Tin
			reagents = {
				[2771] = 1
			},
			results = {
				[3576] = 1
			},
			levels = "65/70/75",
		},
		[16153] = {			--Smelt Thorium
			reagents = {
				[10620] = 1
			},
			results = {
				[12359] = 1
			},
			levels = "250/270/290",
		},
		[3308] = {			--Smelt Gold
			reagents = {
				[2776] = 1
			},
			results = {
				[3577] = 1
			},
			levels = "170/177/185",
		},
		[2659] = {			--Smelt Bronze
			reagents = {
				[2840] = 1,
				[3576] = 1
			},
			results = {
				[2841] = 2
			},
			levels = "65/90/115",
		},
		[49252] = {			--Smelt Cobalt
			reagents = {
				[36909] = 1
			},
			results = {
				[36916] = 1
			},
			levels = "350/362/375",
		},
		[29360] = {			--Smelt Felsteel
			reagents = {
				[23445] = 3,
				[23447] = 2
			},
			results = {
				[23448] = 1
			},
			levels = "350/357/375",
		},
		[14891] = {			--Smelt Dark Iron
			reagents = {
				[11370] = 8
			},
			results = {
				[11371] = 1
			},
			levels = "300/305/310",
		},
		[22967] = {			--Smelt Enchanted Elementium
			reagents = {
				[12360] = 10,
				[17010] = 1,
				[18562] = 1,
				[18567] = 3
			},
			results = {
				[17771] = 1
			},
			levels = "350/362/375",
		},
		[2657] = {			--Smelt Copper
			reagents = {
				[2770] = 1
			},
			results = {
				[2840] = 1
			},
			levels = "25/47/70",
		},
		[35751] = {			--Fire Sunder
			reagents = {
				[21884] = 1
			},
			results = {
				[22574] = 10
			},
			levels = "0/0/300",
		},
		[84038] = {			--Smelt Obsidium
			reagents = {
				[53038] = 2
			},
			results = {
				[54849] = 1
			},
			levels = "425/437/475",
		},
		[70524] = {			--Enchanted Thorium Bar
			reagents = {
				[12359] = 1,
				[11176] = 3
			},
			results = {
				[12655] = 1
			},
			levels = "250/255/260",
		},
		[35750] = {			--Earth Shatter
			reagents = {
				[22452] = 1
			},
			results = {
				[22573] = 10
			},
			levels = "0/0/300",
		}
	}

	local skillList = {}

	local api = {}


	api.SpellCastCheck = function(recipeID, spellID)
		local enchantID = ScrollMakingEnchantID(recipeID)
		if enchantID == spellID then
			return true
		end
	end


	api.DoTradeSkill = function(recipeID, count)
		CastSpellByName(GetSpellInfo(2656))

		local skillIndex = GnomeWorks:FindRecipeSkillIndex(recipeID)

		if skillIndex then
			DoTradeSkill(skillIndex, count)
		end
	end

	api.GetRecipeName = function(recipeID)
		return (GetItemInfo(recipeID))
	end

	api.GetRecipeData = function(recipeID)
		if smeltingData[recipeID].results then
			return smeltingData[recipeID].results, smeltingData[recipeID].reagents, 2656
		end
	end


	api.GetNumTradeSkills = function()
		return #skillList
	end


	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]

		if recipeID then
			itemID = next(smeltingData[recipeID].results)

			if itemID then
				local _,link = GetItemInfo(itemID)

				return link
			end
		end
	end

	api.GetTradeSkillRecipeLink = function(index)
		local recipeID = skillList[index]

		if recipeID then
			return GetSpellLink(recipeID)
		end
	end


	api.GetTradeSkillLine = function()
		local rank, maxRank = GnomeWorks:GetTradeSkillRanks(GnomeWorks.player, 2656)
		return (GetSpellInfo(2656)), rank, maxRank
	end

	api.GetTradeSkillInfo = function(index)
		local recipeID = skillList[index]

		return (recipeID and (GetSpellInfo(recipeID))) or "nil", "optimal"
	end

	api.GetTradeSkillIcon = function(index)
		local recipeID = skillList[index]

		return GetSpellTexture(recipeID)
	end

	api.IsTradeSkillLinked = function()
		return true
	end


	api.RecordKnownSpells = function(player)
		local knownSpells = GnomeWorks.data.knownSpells[player]
	end

--[[
	local function AddRecipe(trade,recipeID)
		local recipeList = self.data.pseudoTradeRecipes

		local enchantResults, enchantReagents = GnomeWorks:GetRecipeData(recipeID)

		if enchantResults then
			local itemID,numMade = next(enchantResults)

			if itemID < 0 then
				local scrollName, scrollLink = GetItemInfo(itemID)

				if scrollLink then
					local scrollID = string.match(scrollLink, "item:(%d+)")

					if scrollID then
						local scrollRecipeID = ScrollMakingSpellID(enchantID)

						for i=1,4 do
							GnomeWorks.data.recipeSkillLevels[i][scrollRecipeID] = GnomeWorks.data.recipeSkillLevels[i][enchantID]
						end

						local enchantReagents = GnomeWorksDB.reagents[enchantID]

						if enchantReagents then
							skillList[#skillList +1] = scrollRecipeID

							recipeList[scrollRecipeID] = trade

							reagents[scrollRecipeID] = {}

							for itemID, numNeeded in pairs(enchantReagents) do
								reagents[scrollRecipeID][itemID] = numNeeded
								GnomeWorks:AddToReagentCache(itemID, scrollRecipeID, 1)
							end

							reagents[scrollRecipeID][38682] = 1
							results[scrollRecipeID] = { [scrollID] = 1 }

							GnomeWorks:AddToReagentCache(38682, scrollRecipeID, 1)
							GnomeWorks:AddToItemCache(scrollID, scrollRecipeID, 1)
						end
					end
				end
			end
		end
	end
]]


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

--[[
		local slotGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Slot")

		slotGroup.locked = true
		slotGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(slotGroup)


		local levelGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Level")

		levelGroup.locked = true
		levelGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(levelGroup)
]]


		local flatGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"Flat")

		flatGroup.locked = true
		flatGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(flatGroup)


		local knownSpells = GnomeWorks.data.knownSpells[player]

		for i = 1, #skillList, 1 do
			local subSpell, extra

			local recipeID = skillList[i]


			if knownSpells[recipeID] or player == "All Recipes" then
				GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)

--[[
				for slot,recipeList in pairs(recipeSlots) do
					for k,spellID in ipairs(recipeList) do
						if spellID == enchantID then
							local groupName = slotNames[slot]

							local subGroup, newGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Slot",groupName)

							GnomeWorks:RecipeGroupAddRecipe(subGroup, recipeID, i, true)

							if newGroup then
								GnomeWorks:RecipeGroupAddSubGroup(slotGroup, subGroup, i+1000, true)
							end
						end
					end
				end


				for level,recipeList in pairs(recipeLevels) do
					for k,spellID in ipairs(recipeList) do
						if spellID == enchantID then
							local groupName = levelNames[level]

							local subGroup, newGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Level",groupName)

							GnomeWorks:RecipeGroupAddRecipe(subGroup, recipeID, i, true)

							if newGroup then
								GnomeWorks:RecipeGroupAddSubGroup(levelGroup, subGroup, i+1000, true)
							end
						end
					end
				end
]]

			end

		end


		GnomeWorks:CraftabilityPurge()
		GnomeWorks:InventoryScan()

		collectgarbage("collect")

		GnomeWorks:SendMessageDispatch("TradeScanComplete")
		return
	end




	local function SetUpRecipes(trade,recipeList)
		for recipeID, data in pairs(smeltingData) do
			GnomeWorksDB.tradeIDs[recipeID] = 2656
			GnomeWorksDB.results[recipeID] = data.results
			GnomeWorksDB.reagents[recipeID] = data.reagents

			local yellow, green, gray = string.match(data.levels,"(%d+)/(%d+)/(%d+)")
			yellow = tonumber(yellow)
			green = tonumber(green)
			gray = tonumber(gray)

			GnomeWorks.data.recipeSkillLevels[2][recipeID] = yellow
			GnomeWorks.data.recipeSkillLevels[3][recipeID] = gray
--			GnomeWorks.data.recipeSkillLevels[4][recipeID] = gray

			for itemID,numMade in pairs(data.results) do
				GnomeWorks:AddToItemCache(itemID, recipeID, numMade)
			end

			for itemID,numNeeded in pairs(data.reagents) do
				GnomeWorks:AddToReagentCache(itemID, recipeID, numNeeded)
			end

			if recipeList then
				recipeList[recipeID] = trade
			end
		end
	end

	api.GetTradeName = function()
		return (GetSpellInfo(2656))
	end


	api.GetTradeLink = function()
		return GetSpellLink(2656)
	end


	api.GetTradeIcon = function()
		return GetSpellTexture(2656)
	end


	local function AddSmelting()
--		local trade,recipeList  = GnomeWorks:AddPseudoTrade(2656,api)
		SetUpRecipes(trade,recipeList)
--		trade.skillList = skillList
	end


	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes",AddSmelting)

end

