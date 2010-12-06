

do
	local prospectingResults = {
		[36912] = { --Saronite Ore
			[36929] = 0.275, --Huge Citrine
			[36930] = 0.062, --Monarch Topaz
			[36923] = 0.275, --Chalcedony
			[36924] = 0.062, --Sky Sapphire
			[36932] = 0.275, --Dark Jade
			[36918] = 0.062, --Scarlet Ruby
			[36926] = 0.275, --Shadow Crystal
			[36927] = 0.06, --Twilight Opal
			[36920] = 0.27, --Sun Crystal
			[36933] = 0.06, --Forest Emerald
			[36921] = 0.06, --Autumn\'s Glow
			[36917] = 0.27, --Bloodstone
		},
		[23424] = { --Fel Iron Ore
			[23441] = 0.012, --Nightseye
			[23438] = 0.012, --Star of Elune
			[23112] = 0.27, --Golden Draenite
			[23439] = 0.012, --Noble Topaz
			[23437] = 0.012, --Talasite
			[23117] = 0.26, --Azure Moonstone
			[23436] = 0.012, --Living Ruby
			[23440] = 0.012, --Dawnstone
			[21929] = 0.27, --Flame Spessarite
			[23079] = 0.27, --Deep Peridot
			[23077] = 0.265, --Blood Garnet
			[23107] = 0.265, --Shadow Draenite
		},
		[2771] = { --Tin Ore
			[3864] = 0.034, --Citrine
			[1210] = 0.575, --Shadowgem
			[1529] = 0.032, --Jade
			[7909] = 0.032, --Aquamarine
			[1705] = 0.58, --Lesser Moonstone
			[1206] = 0.585, --Moss Agate
		},
		[23425] = { --Adamantite Ore
			[23441] = 0.034, --Nightseye
			[23438] = 0.034, --Star of Elune
			[23112] = 0.275, --Golden Draenite
			[23439] = 0.036, --Noble Topaz
			[23079] = 0.275, --Deep Peridot
			[23437] = 0.036, --Talasite
			[23117] = 0.27, --Azure Moonstone
			[23436] = 0.034, --Living Ruby
			[23440] = 0.034, --Dawnstone
			[21929] = 0.28, --Flame Spessarite
			[24243] = 1, --nil
			[23077] = 0.275, --Blood Garnet
			[23107] = 0.27, --Shadow Draenite
		},
		[2770] = { --Copper Ore
			[818] = 0.5, --Tigerseye
			[1210] = 0.1, --Shadowgem
			[774] = 0.5, --Malachite
		},
		[36909] = { --Cobalt Ore
			[36929] = 0.375, --Huge Citrine
			[36930] = 0.012, --Monarch Topaz
			[36923] = 0.375, --Chalcedony
			[36924] = 0.012, --Sky Sapphire
			[36932] = 0.375, --Dark Jade
			[36918] = 0.014, --Scarlet Ruby
			[36926] = 0.37, --Shadow Crystal
			[36927] = 0.012, --Twilight Opal
			[36920] = 0.37, --Sun Crystal
			[36917] = 0.365, --Bloodstone
			[36921] = 0.012, --Autumn\'s Glow
			[36933] = 0.012, --Forest Emerald
		},
		[36910] = { --Titanium Ore
			[36917] = 0.37, --Bloodstone
			[36918] = 0.064, --Scarlet Ruby
			[36919] = 0.064, --nil
			[36920] = 0.355, --Sun Crystal
			[36921] = 0.06, --Autumn\'s Glow
			[36922] = 0.064, --nil
			[36923] = 0.365, --Chalcedony
			[36924] = 0.062, --Sky Sapphire
			[36925] = 0.064, --nil
			[36926] = 0.365, --Shadow Crystal
			[36927] = 0.062, --Twilight Opal
			[36928] = 0.066, --nil
			[46849] = 0.875, --nil
			[36930] = 0.064, --Monarch Topaz
			[36931] = 0.07, --nil
			[36932] = 0.37, --Dark Jade
			[36933] = 0.06, --Forest Emerald
			[36934] = 0.068, --nil
			[36929] = 0.37, --Huge Citrine
		},
		[3858] = { --Mithril Ore
			[12364] = 0.024, --Huge Emerald
			[12361] = 0.024, --Blue Sapphire
			[3864] = 0.52, --Citrine
			[12800] = 0.024, --Azerothian Diamond
			[7909] = 0.525, --Aquamarine
			[7910] = 0.53, --Star Ruby
			[12799] = 0.026, --Large Opal
		},
		[10620] = { --Thorium Ore
			[12799] = 0.4, --Large Opal
			[23112] = 0.002, --Golden Draenite
			[23079] = 0.002, --Deep Peridot
			[12361] = 0.39, --Blue Sapphire
			[23117] = 0.002, --Azure Moonstone
			[12800] = 0.39, --Azerothian Diamond
			[23077] = 0.002, --Blood Garnet
			[21929] = 0.002, --Flame Spessarite
			[12364] = 0.395, --Huge Emerald
			[23107] = 0.002, --Shadow Draenite
			[7910] = 0.3, --Star Ruby
		},
		[2772] = { --Iron Ore
			[3864] = 0.525, --Citrine
			[1529] = 0.535, --Jade
			[7909] = 0.05, --Aquamarine
			[1705] = 0.525, --Lesser Moonstone
			[7910] = 0.05, --Star Ruby
		},
	}


	local prospectingNames = {}

	local prospectingReagents = {}

	local prospectingLevels = {
		[36912] = 400, --Saronite Ore
		[36909] = 350, --Cobalt Ore
		[23425] = 325, --Adamantite Ore
		[23424] = 275, --Fel Iron Ore
		[10620] = 250, --Thorium Ore
		[3858] = 175, --Mithril Ore
		[2772] = 125, -- Iron Ore
		[2771] = 50, --Tin Ore
		[2770] = 20, --Copper Ore
	}


	local skillList = {}

	local api = {}



	-- spoof recipes for prospected ores -> gems
	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes", function ()
		local trade,recipeList  = GnomeWorks:AddPseudoTrade(31252, api)

		trade.priority = .75


		for oreID, gemTable in pairs(prospectingResults) do
			recipeList[-oreID] = trade


			skillList[#skillList + 1] = -oreID


			prospectingReagents[-oreID] = { [oreID] = 5 }
			prospectingNames[-oreID] = string.format("Prospect %s",GetItemInfo(oreID) or "item:"..oreID)

			GnomeWorks:AddToReagentCache(oreID, -oreID, 5)

			for gemID, numMade in pairs(gemTable) do
				GnomeWorks:AddToItemCache(gemID, -oreID, numMade)
			end
		end


		trade.skillList = skillList


		api.RecordKnownSpells((UnitName("player")))

		return true
	end)



	api.DoTradeSkill = function(recipeID)
		CastSpellByName("/use "..GetSpellInfo(-recipeID))
	end

	api.GetRecipeName = function(recipeID)
		if type(recipeID) == "string" then
			return recipeID
		end

		if prospectingNames[recipeID] then
			if string.find(prospectingNames[recipeID],"item:") then
				if GetItemInfo(-recipeID) then
					prospectingNames[recipeID] = string.format("Prospect %s",GetItemInfo(-recipeID))
				end
			end

			return prospectingNames[recipeID]
		end
	end

	api.GetRecipeData = function(recipeID)
		if prospectingResults[-recipeID] then
			return prospectingResults[-recipeID], prospectingReagents[recipeID], 31252
		end
	end



	api.GetNumTradeSkills = function()
		return #skillList
	end


	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]

		if not recipe or type(recipeID) == "string" then
			return
		end

		local itemID = next(prospectingResults[-recipeID])

		local _,link = GetItemInfo(itemID)

		return link
	end


	api.GetTradeSkillRecipeLink = function(index)
		local recipeID = skillList[index]

		if type(recipeID) == "string" then
			return
		end

		return "|cff80a0ff|Henchant:"..recipeID.."|h["..prospectingNames[recipeID].."]|h|r"
	end


	api.GetTradeSkillLine = function()
		return (GetSpellInfo(31252)), 1, 1
	end


	api.GetTradeSkillInfo = function(index)
		local recipeID = skillList[index]

		if type(recipeID) == "string" then
			return recipeID, "header"
		end

		if prospectingNames[-recipeID] then
			if string.find(prospectingNames[-recipeID],"item:") then
				if GetItemInfo(recipeID) then
					prospectingNames[-recipeID] = string.format("Prospect %s",GetItemInfo(recipeID))
				end
			end
		end

		return prospectingNames[-recipeID], "optimal"
	end


	api.GetTradeSkillIcon = function(index)
		local recipeID = skillList[index]

		if type(recipeID) == "string" then
			return
		end

		local itemID = next(prospectingResults[-recipeID])

		return GetItemIcon(itemID)
	end


	api.IsTradeSkillLinked = function()
		return true
	end




	api.ConfigureMacroText = function(recipeID)
		return "/cast "..GetSpellInfo(31252).."\r/use "..GetItemInfo(-recipeID)
	end



	api.RecordKnownSpells = function(player)
		local jewelcraftingRank = GnomeWorks:GetTradeSkillRank(player, 25229)

		if jewelcraftingRank > 0 then
			local knownSpells = GnomeWorks.data.knownSpells[player]


			for i = 1, #skillList, 1 do
				if type(skillList[i]) ~= "string" then

					local recipeID = skillList[i]

					if (prospectingLevels[-recipeID] or 0) <= jewelcraftingRank then
						knownSpells[recipeID] = i
					end
				end
			end
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

		api.RecordKnownSpells(player)

		for i = 1, #skillList, 1 do
			local subSpell, extra

			if type(skillList[i]) == "string" then
				local groupName = skillList[i]

				numHeaders = numHeaders + 1

				currentGroup = GnomeWorks:RecipeGroupNew(player, tradeID, "By Bracket", groupName)
				currentGroup.autoGroup = true

				GnomeWorks:RecipeGroupAddSubGroup(mainGroup, currentGroup, i, true)
			else
				local recipeID = skillList[i]

				if GnomeWorks:IsSpellKnown(recipeID, player) then
					GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)
				end
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

end






