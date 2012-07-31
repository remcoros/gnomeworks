

do
	local prospectingResults = {
		[2770] = { --Copper Ore
			[818] = 0.501, --Tigerseye
			[1210] = 0.099, --Shadowgem
			[774] = 0.499, --Malachite
		},
		[2771] = { --Tin Ore
			[3864] = 0.032, --Citrine
			[1210] = 0.399, --Shadowgem
			[1529] = 0.033, --Jade
			[1206] = 0.398, --Moss Agate
			[1705] = 0.4, --Lesser Moonstone
			[7909] = 0.031, --Aquamarine
		},
		[2772] = { --Iron Ore
			[3864] = 0.371, --Citrine
			[1529] = 0.368, --Jade
			[7910] = 0.048, --Star Ruby
			[1705] = 0.363, --Lesser Moonstone
			[7909] = 0.05, --Aquamarine
		},
		[10620] = { --Thorium Ore
			[12364] = 0.335, --Huge Emerald
			[12361] = 0.336, --Blue Sapphire
			[12799] = 0.333, --Large Opal
			[12800] = 0.332, --Azerothian Diamond
			[7910] = 0.161, --Star Ruby
		},
		[3858] = { --Mithril Ore
			[12364] = 0.023, --Huge Emerald
			[12361] = 0.025, --Blue Sapphire
			[12799] = 0.027, --Large Opal
			[12800] = 0.025, --Azerothian Diamond
			[7909] = 0.366, --Aquamarine
			[7910] = 0.37, --Star Ruby
			[3864] = 0.367, --Citrine
		},
		[23424] = { --Fel Iron Ore
			[23441] = 0.012, --Nightseye
			[23438] = 0.012, --Star of Elune
			[23112] = 0.189, --Golden Draenite
			[23439] = 0.013, --Noble Topaz
			[23437] = 0.012, --Talasite
			[23117] = 0.178, --Azure Moonstone
			[23436] = 0.012, --Living Ruby
			[23440] = 0.012, --Dawnstone
			[21929] = 0.183, --Flame Spessarite
			[23079] = 0.183, --Deep Peridot
			[23077] = 0.185, --Blood Garnet
			[23107] = 0.183, --Shadow Draenite
		},
		[23425] = { --Adamantite Ore
			[23441] = 0.036, --Nightseye
			[23438] = 0.036, --Star of Elune
			[23112] = 0.187, --Golden Draenite
			[23437] = 0.037, --Talasite
			[23439] = 0.038, --Noble Topaz
			[23079] = 0.186, --Deep Peridot
			[23117] = 0.179, --Azure Moonstone
			[23436] = 0.037, --Living Ruby
			[23440] = 0.037, --Dawnstone
			[21929] = 0.184, --Flame Spessarite
			[24243] = 1, --Adamantite Powder
			[23077] = 0.181, --Blood Garnet
			[23107] = 0.183, --Shadow Draenite
		},
		[36909] = { --Cobalt Ore
			[36929] = 0.255, --Huge Citrine
			[36930] = 0.014, --Monarch Topaz
			[36923] = 0.248, --Chalcedony
			[36924] = 0.012, --Sky Sapphire
			[36917] = 0.244, --Bloodstone
			[36918] = 0.012, --Scarlet Ruby
			[36926] = 0.254, --Shadow Crystal
			[36927] = 0.012, --Twilight Opal
			[36920] = 0.246, --Sun Crystal
			[36932] = 0.246, --Dark Jade
			[36921] = 0.012, --Autumn's Glow
			[36933] = 0.013, --Forest Emerald
		},
		[36912] = { --Saronite Ore
			[36929] = 0.184, --Huge Citrine
			[36930] = 0.041, --Monarch Topaz
			[36923] = 0.181, --Chalcedony
			[36924] = 0.044, --Sky Sapphire
			[36917] = 0.182, --Bloodstone
			[36918] = 0.041, --Scarlet Ruby
			[36926] = 0.182, --Shadow Crystal
			[36927] = 0.041, --Twilight Opal
			[36920] = 0.185, --Sun Crystal
			[36932] = 0.185, --Dark Jade
			[36921] = 0.04, --Autumn's Glow
			[36933] = 0.041, --Forest Emerald
		},
		[36910] = { --Titanium Ore
			[36917] = 0.251, --Bloodstone
			[36918] = 0.042, --Scarlet Ruby
			[36919] = 0.04, --Cardinal Ruby
			[36920] = 0.246, --Sun Crystal
			[36921] = 0.041, --Autumn's Glow
			[36922] = 0.046, --King's Amber
			[36923] = 0.255, --Chalcedony
			[36924] = 0.042, --Sky Sapphire
			[36925] = 0.046, --Majestic Zircon
			[36926] = 0.252, --Shadow Crystal
			[36927] = 0.04, --Twilight Opal
			[36928] = 0.045, --Dreadstone
			[36929] = 0.251, --Huge Citrine
			[36930] = 0.043, --Monarch Topaz
			[36931] = 0.046, --Ametrine
			[36932] = 0.252, --Dark Jade
			[36933] = 0.041, --Forest Emerald
			[36934] = 0.045, --Eye of Zul
		},
		[53038] = { --Obsidium Ore
			[52178] = 0.25, --Zephyrite
			[52179] = 0.25, --Alicite
			[52180] = 0.25, --Nightstone
			[52181] = 0.25, --Hessonite
			[52182] = 0.25, --Jasper
			[52177] = 0.25, --Carnelian
			[52195] = 0.015, --Amberjewel
			[52194] = 0.015, --Demonseye
			[52192] = 0.015, --Dream Emerald
			[52193] = 0.015, --Ember Topaz
			[52190] = 0.015, --Inferno Ruby
			[52191] = 0.015, --Ocean Sapphire
		},
		[52185] = { --Elementium Ore
			[52178] = 0.1875, --Zephyrite
			[52179] = 0.1875, --Alicite
			[52180] = 0.1875, --Nightstone
			[52181] = 0.1875, --Hessonite
			[52182] = 0.1875, --Jasper
			[52177] = 0.1875, --Carnelian
			[52195] = 0.0417, --Amberjewel
			[52194] = 0.0417, --Demonseye
			[52192] = 0.0417, --Dream Emerald
			[52193] = 0.0417, --Ember Topaz
			[52190] = 0.0417, --Inferno Ruby
			[52191] = 0.0417, --Ocean Sapphire
		},
		[52183] = { --Pyrite Ore
			[52327] = 2.0, --Volatile Earth
			[52178] = 0.16, --Zephyrite
			[52179] = 0.16, --Alicite
			[52180] = 0.16, --Nightstone
			[52181] = 0.16, --Hessonite
			[52182] = 0.16, --Jasper
			[52177] = 0.16, --Carnelian
			[52195] = 0.08, --Amberjewel
			[52194] = 0.08, --Demonseye
			[52192] = 0.08, --Dream Emerald
			[52193] = 0.08, --Ember Topaz
			[52190] = 0.08, --Inferno Ruby
			[52191] = 0.08, --Ocean Sapphire
		},
	}


	local prospectingNames = {}

	local prospectingReagents = {}

	local prospectingLevels = {
		[52183] = 500, --Pyrite Ore
		[52185] = 475, --Elementium Ore
		[53038] = 425, --Obsidium Ore
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

		GnomeWorks.system.levelBasis[31252] = 25229

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

		return "|cff80a0ff|Henchant:"..recipeID.."|h["..prospectingNames[recipeID].."]|h|r", recipeID
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
		GnomeWorks:SendMessageDispatch("TradeScanComplete")

		return
	end

end






