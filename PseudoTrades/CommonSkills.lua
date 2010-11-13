


do

	local commonRecipes = {
		[44122] = {
			name = "Lesser Cosmic Essence",
			reagents = {
				[34055] = 1, --Greater Cosmic Essence
			},
			results = {
				[34056] = 3, --Lesser Cosmic Essence
			},
		},
		[32977] = {
			name = "Greater Planar Essence",
			reagents = {
				[22447] = 3, --Lesser Planar Essence
			},
			results = {
				[22446] = 1, --Greater Planar Essence
			},
		},
		[56041] = {
			name = "Crystallized Earth",
			reagents = {
				[35624] = 1, --Eternal Earth
			},
			results = {
				[37701] = 10, --Crystallized Earth
			},
		},
		[56043] = {
			name = "Crystallized Life",
			reagents = {
				[35625] = 1, --Eternal Life
			},
			results = {
				[37704] = 10, --Crystallized Life
			},
		},
		[56045] = {
			name = "Crystallized Air",
			reagents = {
				[35623] = 1, --Eternal Air
			},
			results = {
				[37700] = 10, --Crystallized Air
			},
		},
		[49245] = {
			name = "Create Eternal Water",
			reagents = {
				[37705] = 10, --Crystallized Water
			},
			results = {
				[35622] = 1, --Eternal Water
			},
		},
		[13497] = {
			name = "Greater Astral Essence",
			reagents = {
				[10998] = 3, --Lesser Astral Essence
			},
			results = {
				[11082] = 1, --Greater Astral Essence
			},
		},
		[13498] = {
			name = "Lesser Astral Essence",
			reagents = {
				[11082] = 1, --Greater Astral Essence
			},
			results = {
				[10998] = 3, --Lesser Astral Essence
			},
		},
		[59926] = {
			name = "Borean Leather",
			reagents = {
				[33567] = 5, --Borean Leather Scraps
			},
			results = {
				[33568] = 1, --Borean Leather
			},
		},
		[61755] = {
			name = "Create Dream Shard",
			reagents = {
				[34053] = 3, --Small Dream Shard
			},
			results = {
				[34052] = 1, --Dream Shard
			},
		},
		[13632] = {
			name = "Greater Mystic Essence",
			reagents = {
				[11134] = 3, --Lesser Mystic Essence
			},
			results = {
				[11135] = 1, --Greater Mystic Essence
			},
		},
		[13633] = {
			name = "Lesser Mystic Essence",
			reagents = {
				[11135] = 1, --Greater Mystic Essence
			},
			results = {
				[11134] = 3, --Lesser Mystic Essence
			},
		},
		[44123] = {
			name = "Greater Cosmic Essence",
			reagents = {
				[34056] = 3, --Lesser Cosmic Essence
			},
			results = {
				[34055] = 1, --Greater Cosmic Essence
			},
		},
		[49234] = {
			name = "Create Eternal Air",
			reagents = {
				[37700] = 10, --Crystallized Air
			},
			results = {
				[35623] = 1, --Eternal Air
			},
		},
		[56040] = {
			name = "Crystallized Water",
			reagents = {
				[35622] = 1, --Eternal Water
			},
			results = {
				[37705] = 10, --Crystallized Water
			},
		},
		[56042] = {
			name = "Crystallized Fire",
			reagents = {
				[36860] = 1, --Eternal Fire
			},
			results = {
				[37702] = 10, --Crystallized Fire
			},
		},
		[56044] = {
			name = "Crystallized Shadow",
			reagents = {
				[35627] = 1, --Eternal Shadow
			},
			results = {
				[37703] = 10, --Crystallized Shadow
			},
		},
		[49244] = {
			name = "Create Eternal Fire",
			reagents = {
				[37702] = 10, --Crystallized Fire
			},
			results = {
				[36860] = 1, --Eternal Fire
			},
		},
		[49246] = {
			name = "Create Eternal Shadow",
			reagents = {
				[37703] = 10, --Crystallized Shadow
			},
			results = {
				[35627] = 1, --Eternal Shadow
			},
		},
		[49248] = {
			name = "Create Eternal Earth",
			reagents = {
				[37701] = 10, --Crystallized Earth
			},
			results = {
				[35624] = 1, --Eternal Earth
			},
		},
		[20040] = {
			name = "Lesser Eternal Essence",
			reagents = {
				[16203] = 1, --Greater Eternal Essence
			},
			results = {
				[16202] = 3, --Lesser Eternal Essence
			},
		},
		[13361] = {
			name = "Greater Magic Essence",
			reagents = {
				[10938] = 3, --Lesser Magic Essence
			},
			results = {
				[10939] = 1, --Greater Magic Essence
			},
		},
		[13362] = {
			name = "Lesser Magic Essence",
			reagents = {
				[10939] = 1, --Greater Magic Essence
			},
			results = {
				[10938] = 3, --Lesser Magic Essence
			},
		},
		[32978] = {
			name = "Lesser Planar Essence",
			reagents = {
				[22446] = 1, --Greater Planar Essence
			},
			results = {
				[22447] = 3, --Lesser Planar Essence
			},
		},
		[28100] = {
			name = "Create Primal Air",
			reagents = {
				[22572] = 10, --Mote of Air
			},
			results = {
				[22451] = 1, --Primal Air
			},
		},
		[28101] = {
			name = "Create Primal Earth",
			reagents = {
				[22573] = 10, --Mote of Earth
			},
			results = {
				[22452] = 1, --Primal Earth
			},
		},
		[28102] = {
			name = "Create Primal Fire",
			reagents = {
				[22574] = 10, --Mote of Fire
			},
			results = {
				[21884] = 1, --Primal Fire
			},
		},
		[28103] = {
			name = "Create Primal Water",
			reagents = {
				[22578] = 10, --Mote of Water
			},
			results = {
				[21885] = 1, --Primal Water
			},
		},
		[28104] = {
			name = "Create Primal Shadow",
			reagents = {
				[22577] = 10, --Mote of Shadow
			},
			results = {
				[22456] = 1, --Primal Shadow
			},
		},
		[28105] = {
			name = "Create Primal Mana",
			reagents = {
				[22576] = 10, --Mote of Mana
			},
			results = {
				[22457] = 1, --Primal Mana
			},
		},
		[28106] = {
			name = "Create Primal Life",
			reagents = {
				[22575] = 10, --Mote of Life
			},
			results = {
				[21886] = 1, --Primal Life
			},
		},
		[20039] = {
			name = "Greater Eternal Essence",
			reagents = {
				[16202] = 3, --Lesser Eternal Essence
			},
			results = {
				[16203] = 1, --Greater Eternal Essence
			},
		},
		[49247] = {
			name = "Create Eternal Life",
			reagents = {
				[37704] = 10, --Crystallized Life
			},
			results = {
				[35625] = 1, --Eternal Life
			},
		},
		[13739] = {
			name = "Greater Nether Essence",
			reagents = {
				[11174] = 3, --Lesser Nether Essence
			},
			results = {
				[11175] = 1, --Greater Nether Essence
			},
		},
		[13740] = {
			name = "Lesser Nether Essence",
			reagents = {
				[11175] = 1, --Greater Nether Essence
			},
			results = {
				[11174] = 3, --Lesser Nether Essence
			},
		},
	}


	local skillList = {}

	local api = {}

	api.DoTradeSkill = function(recipeID)
		CastSpellByName("/use "..GetSpellInfo(-recipeID))
	end

	api.GetRecipeName = function(recipeID)
		if commonRecipes[recipeID] then
			return commonRecipes[recipeID].name
		end
	end

	api.GetRecipeData = function(recipeID)
		if commonRecipes[recipeID] then
			return commonRecipes[recipeID].results, commonRecipes[recipeID].reagents,100000
		end
	end


	api.GetNumTradeSkills = function()
		return #skillList
	end

	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]
		local itemID = next(commonRecipes[recipeID].results)

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
		local itemID = next(commonRecipes[recipeID].results)

		return GetItemIcon(itemID)
	end

	api.IsTradeSkillLinked = function()
		return true
	end




	api.ConfigureMacroText = function(recipeID)
		return "/use "..GetItemInfo(next(commonRecipes[recipeID].reagents))

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


		api.RecordKnownSpells(player)


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
		local trade,recipeList  = GnomeWorks:AddPseudoTrade(100000,api)

		trade.priority = 1.25


		for recipeID, data in pairs(commonRecipes) do
			skillList[#skillList + 1] = recipeID

			recipeList[recipeID] = trade


			for itemID, numNeeded in pairs(data.results) do
				GnomeWorks:AddToItemCache(itemID, recipeID, numMade)
			end

			for reagentID, numNeeded in pairs(data.reagents) do
				GnomeWorks:AddToReagentCache(reagentID, recipeID, numNeeded)
			end
		end

		trade.skillList = skillList

		api.RecordKnownSpells((UnitName("player")))

		return true
	end)
end




