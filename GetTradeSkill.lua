




--[[
	CloseTradeSkill() - Closes an open trade skill window.
	CollapseTradeSkillSubClass(index) - Collapses the specified subclass header row.
	DoTradeSkill(index[, repeatTimes]) - Performs the tradeskill a specified # of times.
	ExpandTradeSkillSubClass(index) - Expands the specified subclass header row.
	GetFirstTradeSkill() - Returns the index of the first non-header trade skill entry.
	GetNumTradeSkills() - Get the number of trade skill entries (including headers).
	GetTradeSkillCooldown(index) - Returns the number of seconds left for a skill to cooldown.
	GetTradeSkillDescription(index) - Returns the description text of the indicated trade skill.
	GetTradeSkillIcon(index) - Returns the texture name of a tradeskill's icon.
	GetTradeSkillInfo(index) - Retrieves information about a specific trade skill.
	GetTradeSkillInvSlotFilter(slotIndex) - Returns 1 if items corresponding to slotIndex are currently visible, otherwise nil.
	GetTradeSkillInvSlots() - Returns a list of the available inventory slot types.
	GetTradeSkillItemLink(index) - Returns the itemLink for a trade skill item.
	GetTradeSkillLine() - Returns information about the selected skill line.
	GetTradeSkillListLink() - Returns the TradeSkillLink for a trade skill.
	GetTradeSkillNumMade(index) - Gets the number of items made in a single use of a skill.
	GetTradeSkillNumReagents(tradeSkillRecipeId) - Returns the number of different reagents required.
	GetTradeSkillReagentInfo(tradeSkillRecipeId, reagentId) - Returns data on the reagent, including a count of the player's inventory.
	GetTradeSkillReagentItemLink(index, reagentId) - Returns the itemLink for one of the reagents needed to craft the given item
	GetTradeSkillRecipeLink(index) - Returns the EnchantLink for a trade skill.
	GetTradeSkillSelectionIndex() - Returns the Id of the currently selected trade skill, 0 if none selected.
	GetTradeSkillSubClassFilter(filterIndex) - Returns 1 if items corresponding to filterIndex are currently visible, otherwise nil.
	GetTradeSkillSubClasses() - Returns a list of the valid subclasses.
	GetTradeSkillTools(index) - Returns information about the tools needed for a tradeskill.
	GetTradeskillRepeatCount() - Returns the number of times the current item is being crafted.
	IsTradeskillTrainer() - Returns 1 if trainer is for a tradeskill.
	IsTradeSkillLinked() - Returns true if you're inspecting a tradeskill link rather then looking at your own tradeskills
	SelectTradeSkill(index) - Select a specific trade skill in the list.
	SetTradeSkillInvSlotFilter(slotIndex, onOff[, exclusive] ) - Set the inventory slot type filter.
	SetTradeSkillSubClassFilter(slotIndex, onOff[,exclusive] ) - Set the subclass filter.
	StopTradeSkillRepeat() - Stops creating additional queued items.
	TradeSkillOnlyShowMakeable(onlyMakable) - Controls whether only recipes you have the reagents to craft are shown.
]]--

do
--[[
	local unlinkableTrades = {
		[2656] = true,			-- smelting (from mining)
		[53428] = true,			-- runeforging
		[51005] = true,			-- milling
		[13262] = true,			-- disenchant
		[31252] = true,			-- prospecting

		[100000] = true,		-- common skills
		[100001] = true,		-- vendor conversion
		[100003] = true,		-- scroll making
	}

	local fakeTrades = {
		[51005] = true,			-- milling
		[13262] = true,			-- disenchant
		[31252] = true,			-- prospecting

		[100000] = true,		-- common skills
		[100001] = true,		-- vendor conversions
		[100003] = true,		-- scroll making
	}

	local tradeIcon = {
		[100000] = "Interface\\Icons\\Ability_Creature_Cursed_01",
		[100001] = "Interface\\Icons\\INV_Misc_Bag_10",
		[100003] = "Interface\\Icons\\INV_Scroll_07",

	}
]]


	local OverRide = {}

	local tradeIDList = GnomeWorks.system.tradeIDList
	local unlinkableTrades = GnomeWorks.system.unlinkableTrades
	local pseudoTrades = GnomeWorks.system.pseudoTrades
	local fakeTrades = GnomeWorks.system.fakeTrades


	function GnomeWorks:AddPseudoTrade(tradeID, api)
		if not self.data.pseudoTradeData then
			self.data.pseudoTradeData = {}
		end

		if not self.data.pseudoTradeRecipes then
			self.data.pseudoTradeRecipes = {}
		end

		local data = self.data.pseudoTradeData

		data[tradeID] = {}

		data[tradeID].tradeID = tradeID

		if api then
			for xface, func in pairs(api) do

				data[tradeID][xface] = func
			end
		end

		table.insert(tradeIDList, tradeID)

		pseudoTrades[tradeID] = (api.GetTradeName and api.GetTradeName()) or GetSpellInfo(tradeID)
		unlinkableTrades[tradeID] = true
		fakeTrades[tradeID] = not GetSpellInfo(tradeID)

		GnomeWorks:SetTradeIDByName(pseudoTrades[tradeID],tradeID)

		return data[tradeID], self.data.pseudoTradeRecipes
	end


	function GnomeWorks:RecordKnownSpells(tradeID, player)
--print("wants to record spells for",tradeID, player)
--		if not self.data.knownSpells[player] then
--			self.data.knownSpells[player] = {}
--		end

		if self.data.pseudoTradeData[tradeID] and self.data.pseudoTradeData[tradeID].RecordKnownSpells then
			self.data.pseudoTradeData[tradeID].RecordKnownSpells(player)
		end
	end


	function GnomeWorks:ScanPseudoTrade(tradeID)
		if self.data.pseudoTradeData[tradeID] then
			self.data.pseudoTradeData[tradeID].Scan()
		end
	end


	function GnomeWorks:GetTradeIcon(tradeID)
		local pseudoTrade = self.data.pseudoTradeData[tradeID]

		if pseudoTrade and pseudoTrade.GetTradeIcon then
			return pseudoTrade.GetTradeIcon()
		end

		local _,_,icon = GetSpellInfo(tradeID)

		return icon
	end



	function OverRide.GetTradeSkillIcon(index)
		if index and index<0 then
			local results = GnomeWorks:GetRecipeData(-index)

			return GetItemIcon(next(results))
		else
			return GetTradeSkillIcon(index)
		end
	end

	function OverRide.GetTradeSkillItemLink(index)
		if index and index<0 then
			local results = GnomeWorks:GetRecipeData(-index)

			if results then
				local _,itemLink = GetItemInfo(next(results))

				return itemLink
			end
		else
			return GetTradeSkillItemLink(index)
		end
	end

	function OverRide.GetTradeSkillRecipeLink(index)
		if index and index<0 then
			return GetSpellLink(-index)
		else
			return GetTradeSkillRecipeLink(index)
		end
	end


	local skillLevelNames = { "unknown", "optimal", "medium", "easy", "trivial" }

	function OverRide.GetTradeSkillInfo(index)
		if index<0 then
			local rank,maxRank,estimatedRank = GnomeWorks:GetTradeSkillRank()
			rank = estimatedRank or rank

			local spellName = GetSpellInfo(-index)

			for i=1,#skillLevelNames-1 do
				if rank<(GnomeWorks.data.recipeSkillLevels[i][-index] or 0) then
					return spellName, skillLevelNames[i]
				end
			end

			return (GetSpellInfo(-index)), "trivial"
		else
			return GetTradeSkillInfo(index)
		end
	end



	local tradeSkillAPIs = {
--		"GetFirstTradeSkill",
		"GetNumTradeSkills",
		"GetTradeSkillCooldown",
		"GetTradeSkillDescription",
		"GetTradeSkillIcon",
		"GetTradeSkillInfo",
--		"GetTradeSkillInvSlotFilter",
--		"GetTradeSkillInvSlots",
		"GetTradeSkillItemLink",
		"GetTradeSkillLine",
--		"GetTradeSkillListLink",
		"GetTradeSkillNumMade",
--		"GetTradeSkillNumReagents",
--		"GetTradeSkillReagentInfo",
--		"GetTradeSkillReagentItemLink",
		"GetTradeSkillRecipeLink",
		"GetTradeSkillSelectionIndex",
--		"GetTradeSkillSubClassFilter",
--		"GetTradeSkillSubClasses",
		"GetTradeSkillTools",
--		"GetTradeskillRepeatCount",
		"IsTradeSkillLinked",
	}


	for k,api in pairs(tradeSkillAPIs) do
--		if PseudoTrade[api] then
			GnomeWorks[api] = function(self, ...)
				local trade = self.data.pseudoTradeData[self.tradeID]
				if trade then
					if self.player ~= UnitName("player") and trade[api] then
						return trade[api](...)
					end
					local currentTradeSkill = GetTradeSkillLine()

					if currentTradeSkill == GetSpellInfo(2575) then
						currentTradeSkill = GetSpellInfo(2656)
					end

					if currentTradeSkill ~= GetSpellInfo(self.tradeID) and trade[api] then
						return trade[api](...)
					end

					return
				end

				if OverRide[api] then
					return OverRide[api](...)
				end

				return _G[api](...)
			end
--		else
--			GnomeWorks[api] = function(self,...)
--				return _G[api](...)
--			end
--		end
	end



	function GnomeWorks:IsPseudoTrade(tradeID)
		if fakeTrades[tradeID] or (unlinkableTrades[tradeID] and ((tradeID == 2656 or tradeID == 53428) and not GetSpellLink((GetSpellInfo(tradeID))))) then
			return true
		end

		return false
	end


end
