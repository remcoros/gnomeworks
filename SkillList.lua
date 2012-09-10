





local function DebugSpam(...)
--	print(...)
end


do
	local clientVersion, clientBuild = GetBuildInfo()

	local updateEventFrames

	local skillTypeStyle = {
		["unknown"]			= { r = 1.00, g = 0.00, b = 0.00, level = 5, alttext="???", cstring = "|cffff0000"},
		["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25, level = 4, alttext="+++", cstring = "|cffff8040"},
		["medium"]          = { r = 1.00, g = 1.00, b = 0.00, level = 3, alttext="++",  cstring = "|cffffff00"},
		["easy"]            = { r = 0.25, g = 0.75, b = 0.25, level = 2, alttext="+",   cstring = "|cff40c000"},
		["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50, level = 1, alttext="",    cstring = "|cff808080"},
		["header"]          = { r = 1.00, g = 0.82, b = 0,    level = 0, alttext="",    cstring = "|cffffc800"},
	}

	local skillTypeColor = {
		["unknown"]			= { r = 1.00, g = 0.00, b = 0.00,},
		["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25,},
		["medium"]          = { r = 1.00, g = 1.00, b = 0.00,},
		["easy"]            = { r = 0.25, g = 0.75, b = 0.25,},
		["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50,},
		["header"]          = { r = 1.00, g = 0.82, b = 0,   },
	}

--[[
	local tradeIDList = {
		2259,           -- alchemy
		2018,           -- blacksmithing
		7411,           -- enchanting
		4036,           -- engineering
		45357,			-- inscription
		25229,          -- jewelcrafting
		2108,           -- leatherworking
--		2575,			-- mining (or smelting?)
		2656,           -- smelting (from mining)
		3908,           -- tailoring
		2550,           -- cooking
		3273,           -- first aid

		53428,			-- runeforging


		51005,			-- milling
		13262,			-- disenchant
		31252,			-- prospecting



		100000,			-- "Common Skills",
		100001,			-- "Vendor Conversion",
		100003,			-- "Scroll Making"
	}

--	local tradeIDList = { 2259, 2018, 7411, 4036, 45357, 25229, 2108, 3908,  2550, 3273 }

	local unlinkableTrades = {
		[2656] = true,         -- smelting (from mining)
		[53428] = true,			-- runeforging
		[51005] = true,			-- milling
		[13262] = true,			-- disenchant
		[31252] = true,			-- prospecting

		[100000] = true,		-- "Common Skills",
		[100001] = true,		-- "Vendor Conversion",
		[100003] = true, 		-- "Scroll Making",
	}


	local pseudoTrades = {
		[51005] = GetSpellInfo(51005),			-- milling
		[13262] = GetSpellInfo(13262),			-- disenchant
		[31252] = GetSpellInfo(31252),			-- prospecting

		[100000] = "Common",
		[100001] = "Vendor",
		[100003] = "Scroll Making",
	}


	local fakeTrades = {
		[100000] = "Common",
		[100001] = "Vendor",
		[100003] = "Scroll Making",
	}
]]


	local tradeIDList = GnomeWorks.system.tradeIDList
	local unlinkableTrades = GnomeWorks.system.unlinkableTrades
	local pseudoTrades = GnomeWorks.system.pseudoTrades
	local fakeTrades = GnomeWorks.system.fakeTrades
	local levelBasis = GnomeWorks.system.levelBasis


	-- only tailoring for now
	local tradeSpecializations = {
		[26798] = 3908,		-- mooncloth tailoring
		[26801] = 3908,		-- shadowweave tailoring
		[26797] = 3908,		-- spellfire tailoring
	}

	local racialBonuses = {
		[7411] = { racial = 28877, bonus = 10},			-- arcane affinity, +10 enchanting
		[2259] = { racial = 69045, bonus = 15},			-- better living thru chemistry, +15 alchemy
		[4036] = { racial = 20593, bonus = 15},			-- engineering specialization, +15 engineering
		[25229] = { racial = 28875, bonus = 15},			-- gem cutting, +15 jewelcrafting
	}


	local recipeIsCached = {}


	local skillIndexLookup = {}


	local tradeIDByName = {}

	for index, id in pairs(tradeIDList) do
--		local tradeName = string.lower(GnomeWorks:GetTradeName(id))
		local tradeName = string.lower(GetSpellInfo(id))
		tradeIDByName[tradeName] = id
	end

	tradeIDByName[string.lower(GetSpellInfo(2575))] = 2656	-- special case for mining/smelting


	GnomeWorks.data = { skillDB = {}, linkDB = {} }
	local data = GnomeWorks.data

	local linkDB = data.linkDB


	local dataScanned = {}



	local function GetIDFromLink(link)
		if link then
			local id = string.match(link,"item:(%d+)")  or string.match(link,"spell:(%d+)") or string.match(link,"enchant:(%d+)") or string.match(link,"trade:(%d+)")

			return tonumber(id)
		end
	end


	local function AddToDataTable(dataTable, a, b, num)
		if a and b then
			if dataTable[a] then
				dataTable[a][b] = num
			else
				dataTable[a] = { [b] = num }
			end

			return dataTable[a]
		end
	end


	function GnomeWorks:AddToItemCache(itemID, recipeID, numMade)
		GnomeWorks.data.trackedItems[itemID] = true
		GnomeWorks:CraftabilityPurge(self.player, itemID)
		return AddToDataTable(GnomeWorks.data.itemSource, itemID, recipeID, numMade)
	end


	function GnomeWorks:AddToReagentCache(reagentID, recipeID, numNeeded)
		GnomeWorks.data.trackedItems[reagentID] = true
		return AddToDataTable(GnomeWorks.data.reagentUsage, reagentID, recipeID, numNeeded)
	end


	function GnomeWorks:SetTradeIDByName(name, id)
		tradeIDByName[string.lower(name)] = id
	end

	function GnomeWorks:GetTradeIDByName(name)
		return tradeIDByName[string.lower(name)]
	end


	function GnomeWorks:CacheTradeSkillLink(link)
		if link and string.match(link,"trade:") then
			local isLinked,player = IsTradeSkillLinked()

			if player and isLinked then
				if player == UnitName("player") then
					player = "All Recipes"
				end


				if not GnomeWorks.data.playerData[player] then

					local tradeID = self:GetTradeIDByName(GetTradeSkillLine())

					if not linkDB[player] then
						linkDB[player] = {}
					end

					linkDB[player][tradeID] = link
				end
			end
		end
	end


	local playerDataFields = { "links", "guildInfo", "specializations", "rank", "maxRank", "bonus" }

	function GnomeWorks:ParseSkillList()
DebugSpam("parsing skill list")
		local playerName = UnitName("player")

		local guild = GetGuildInfo("player")


		if not self.data.playerData[playerName] then
			self.data.playerData[playerName] = { links = {}, guildInfo = {}, specializations = {}, rank = {}, maxRank = {}, bonus = {} }
		end

		local playerData = self.data.playerData[playerName]

		for k,field in pairs(playerDataFields) do
			if not playerData[field] then
				playerData[field] = {}
			end
		end

		table.wipe(playerData.links)
		table.wipe(playerData.rank)
		table.wipe(playerData.maxRank)
		table.wipe(playerData.bonus)

		playerData.build = clientBuild

		playerData.guild = guild

		if guild then
			if not GnomeWorksDB.config.altGuildAccess[guild] then
				GnomeWorksDB.config.altGuildAccess[guild] = { false, false, false, false, false, false }
			end

			if playerData.guildInfo.name ~= guild then
				playerData.guildInfo.name = guild
				playerData.guildInfo.tabs = { true,true,true,true,true,true } -- default to full access until scan says otherwise
			end
		else
			table.wipe(playerData.guildInfo)
		end

--		{ links = {}, build = clientBuild, guild = GetGuildInfo("player"), guildInfo = { name = GetGuildInfo("player"), tabs = {} }, specializations = {} }

		local function AddProfession(index)
			if index then
				local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier = GetProfessionInfo(index)

				if name then
					local tradeID = self:GetTradeIDByName(name)

					if tradeID then
						local link, tradeLink = GetSpellLink(tradeID)

						if racialBonuses[tradeID] then
							if GetSpellLink((GetSpellInfo(racialBonuses[tradeID].racial))) then
								skillModifier = skillModifier + racialBonuses[tradeID].bonus
							end
						end

						if not tradeLink then
							tradeLink = "|cffffd000|Htrade:"..tradeID..":"..skillLevel..":"..maxSkillLevel..":0:/|h["..GnomeWorks:GetTradeName(tradeID).."]|h|r"
						end

						playerData.links[tradeID] = tradeLink

						playerData.rank[tradeID] = skillLevel
						playerData.maxRank[tradeID] = maxSkillLevel
						playerData.bonus[tradeID] = skillModifier
					end
				end
			end
		end

		local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()

		AddProfession(prof1)
		AddProfession(prof2)
		AddProfession(cooking)
		AddProfession(firstAid)

		for k,id in pairs(tradeIDList) do
			if not playerData.links[id] then
				if not fakeTrades[id] then
					local link, tradeLink = GetSpellLink((GetSpellInfo(id)))

					if link then
	DebugSpam("found ", link, tradeLink)

						if unlinkableTrades[id]  then
							local rank = 1
							local maxRank = 1
							local bonus = 0

							if levelBasis[id] then
								rank = playerData.rank[levelBasis[id]]
								maxRank = playerData.maxRank[levelBasis[id]]
								bonus = playerData.bonus[levelBasis[id]]
							end

							tradeLink = "|cffffd000|Htrade:"..id..":"..rank..":"..maxRank..":0:/|h["..GnomeWorks:GetTradeName(id).."]|h|r"			-- fake link for data collection purposes

							self:RecordKnownSpells(playerName, id)

							playerData.links[id] = tradeLink

							playerData.rank[id] = rank
							playerData.maxRank[id] = maxRank
							playerData.bonus[id] = bonus
						elseif not tradeLink then
							return false
						end
					end
				else
					local baseTradeID = levelBasis[id]

					if not baseTradeID or GetSpellLink((GetSpellInfo(baseTradeID))) then
						local rank = 1
						local maxRank = 1
						local bonus = 0

						if baseTradeID then
							rank = playerData.rank[baseTradeID] or 1
							maxRank = playerData.maxRank[baseTradeID] or rank
							bonus = playerData.bonus[baseTradeID] or 0
						end

						playerData.links[id] = "|cffffd000|Htrade:"..id..":"..rank..":"..maxRank..":0:/|h["..pseudoTrades[id].."]|h|r"

						playerData.rank[id] = rank
						playerData.maxRank[id] = maxRank
						playerData.bonus[id] = bonus
					end
				end
			end
		end

		for spellID,tradeID in pairs(tradeSpecializations) do
			local spellName = GetSpellInfo(spellID)

			if GetSpellInfo(spellName) then
				playerData.specializations[spellID] = tradeID
			end
		end

		playerName = "All Recipes"
		self.data.playerData[playerName] = { links = {}, build = clientBuild, specializations = {}, rank = {}, maxRank = {}, bonus = {} }

		local playerData = self.data.playerData[playerName]

		for k,id in pairs(tradeIDList) do
			if not fakeTrades[id] then
				local link, tradeLink = GetSpellLink(id)

				if tradeLink then
					local tradeID,ranks,guid,bitMap,tail = string.match(tradeLink,"(|c%x+|Htrade:%d+):(%d+:%d+):([0-9a-fA-F]+:)([A-Za-z0-9+/]+)(|h%[[^]]+%]|h|r)")

					local fullBitMap = string.rep("/",string.len(bitMap or ""))

					playerData.links[id] = string.format("%s:525:525:%s%s%s",tradeID, guid, fullBitMap, tail)

	--				print(playerData.links[id])
				else
					playerData.links[id] = "|cffffd000|Htrade:"..id..":1:1:0:/|h["..GnomeWorks:GetTradeName(id).."]|h|r"			-- fake link for data collection purposes
				end
			else
				playerData.links[id] = "|cffffd000|Htrade:"..id..":1:1:0:/|h["..pseudoTrades[id].."]|h|r"
			end

			playerData.rank[id] = 525
			playerData.maxRank[id] = 525
			playerData.bonus[id] = 0
		end
DebugSpam("done parsing skill list")

--[[
		for k,name in pairs({"Smelting", "Mining"}) do
			for k,spellID in pairs({2575, 2656 }) do
				for i=4,10 do
					local bitMap = string.rep("/",i)
					local tradeString = "trade:"..spellID..":1:1:10000000345738B:"..bitMap
					local tradeLink = "|cffffd000|H"..tradeString.."|h["..name.."]|h|r"
					SetItemRef(tradeString,tradeLink,"LeftButton")

					print(tradeString, tradeLink)
				end
			end
		end
]]

		return true
	end



	function GnomeWorks:CHAT_MSG_SKILL()
		self:ScheduleTimer("ParseSkillList",.05)
--		self:ParseSkillList()
		if self.updateTimer then
			self:CancelTimer(self.updateTimer, true)
		end

		self.updateTimer = self:ScheduleTimer("DoTradeSkillUpdate",.1)
	end




	function GnomeWorks:OpenTradeLink(tradeLink, player)
		if tradeLink then
			local tradeString = string.match(tradeLink, "(trade:%d+:%d+:%d+:[0-9a-fA-F]+:[A-Za-z0-9+/]+)")

			local tradeID = string.match(tradeString,"trade:(%d+)")

			tradeID = tonumber(tradeID)

			if unlinkableTrades[tradeID] then
				self:UnregisterEvent("TRADE_SKILL_CLOSE")
				CloseTradeSkill()
				self:RegisterEvent("TRADE_SKILL_CLOSE")

--print("pseudotrades not yet implemented")
				self.tradeID = tradeID
				self.player = player
				self.tradeIsLinked = true
--				self:SelectSkill(1)

				self:ScanPseudoTrade(tradeID)

				self:ScheduleTimer("UpdateMainWindow",.01)
--				self:UpdateMainWindow()
			else
				SetItemRef(tradeString,tradeLink,"LeftButton")
			end
		end
	end


	local function SelectEntryByIndex(data,index)
		if data then
			for k,v in ipairs(data.entries) do

				if v.index == index then
					return v
				end

				if v.subGroup then
					local entry = SelectEntryByIndex(v.subGroup, index)

					if entry then
						return entry
					end
				end
			end
		end
	end


	function GnomeWorks:SelectSkill(index)
		self.selectedSkill = index

		if unlinkableTrades[self.tradeID] then
			self:ShowDetails(index)
			self:ShowReagents(index)

			self:ScrollToIndex(index)

--			self:SkillListDraw(index)
		else
			if index then
				local skillName, skillType = GetTradeSkillInfo(index)

				if skillType ~= "header" and skillType ~= "subheader" then
					SelectTradeSkill(index)
					self:ShowDetails(index)
					self:ShowReagents(index)

					self:ScrollToIndex(index)

--					self:SkillListDraw(index)


	--				self:ShowSkillList()


				else
		--			self:HideDetails()
		--			self:HideReagents()

		--			SelectTradeSkill(index)

				end
			end
		end

		self:SendMessageDispatch("SelectionChanged")
	end


	function GnomeWorks:SelectEntry(entry)
		self:SelectSkill(entry.index)

		self.selectedEntry = entry
		self.skillFrame.scrollFrame.selectedEntry = GnomeWorks.selectedEntry
		GnomeWorks:SendMessageDispatch("SelectionChanged")
	end


	function GnomeWorks:ResetSkillSelect()
		self.selectedEntry = nil
	end


	function GnomeWorks:FindRecipeSkillIndex(recipeID)
		if not recipeID then
			return
		end


		local enchantString = "enchant:"..recipeID.."|h"
		local spellString = "spell:"..recipeID.."|h"

		for i=1,GnomeWorks:GetNumTradeSkills() do
			local link, spellRecipeID = GnomeWorks:GetTradeSkillRecipeLink(i)

			if spellRecipeID == recipeID or (link and (string.find(link, enchantString) or string.find(link, spellString))) then
				return i
			end
		end
	end




	function GnomeWorks:DoRecipeSelection(recipeID)
--print("DoRecipeSelection",GnomeWorks:GetRecipeName(recipeID))
		if not recipeID then
			if GnomeWorks.selectedEntry then
				recipeID = GnomeWorks.selectedEntry.recipeID
			else
				return
			end
		end

		local skillIndex = GnomeWorks:FindRecipeSkillIndex(recipeID)

		if skillIndex then
			GnomeWorks:SelectSkill(skillIndex)

			GnomeWorks.selectedEntry = SelectEntryByIndex(GnomeWorks.skillFrame.scrollFrame.data, skillIndex)

			GnomeWorks.skillFrame.scrollFrame.selectedEntry = GnomeWorks.selectedEntry


			GnomeWorks:SendMessageDispatch("SelectionChanged")
		end

		return true
	end


	function GnomeWorks:SelectRecipe(recipeID)
--print("SelectRecipe",GnomeWorks:GetRecipeName(recipeID))

		if not recipeID then return end

		if type(recipeID) == "table" then
			recipeID = next(recipeID) or recipeID[1]				-- TODO: dropdown for selection?
		end

		local player = self.player or UnitName("player")
		local _,_,tradeID = GnomeWorks:GetRecipeData(recipeID)

		if tradeID ~= self.tradeID then
--			GnomeWorks:RegisterMessageDispatch("TradeScanComplete", function() GnomeWorks:DoRecipeSelection(recipeID) return true end, "SelectRecipe")			-- return true = fire once
--			GnomeWorks:RegisterMessageDispatch("TradeScanComplete", function() GnomeWorks:DoRecipeSelection() return true end, "SelectRecipe")			-- return true = fire once

			if player == (UnitName("player")) and not pseudoTrades[tradeID] then
				if tradeID then
					CastSpellByName((GetSpellInfo(tradeID)))
				end
			else
				self:OpenTradeLink(self:GetTradeLink(tradeID, player), player)
			end
		else
			GnomeWorks:DoRecipeSelection(recipeID)
		end
	end



	function GnomeWorks:PushSelection()
		if self.selectedEntry then
			local newEntry = { player = self.player, tradeID = self.tradeID, recipeID = self.selectedEntry.recipeID }

			table.insert(self.data.selectionStack, newEntry)
		end
	end


	function GnomeWorks:PopSelection()
		local stack = self.data.selectionStack
		local lastEntry = #stack

		if lastEntry>0 then
			local player,tradeID,recipeID = stack[lastEntry].player, stack[lastEntry].tradeID, stack[lastEntry].recipeID
--print(player,tradeID,skill)
			if tradeID ~= self.tradeID then
				GnomeWorks:RegisterMessageDispatch("TradeScanComplete", function() GnomeWorks:DoRecipeSelection(recipeID) return true end, "SelectRecipe")			-- return true = fire once

				if player == (UnitName("player")) and not pseudoTrades[tradeID] then
					if tradeID then
						CastSpellByName((GetSpellInfo(tradeID)))
					end
				else
					self:OpenTradeLink(self:GetTradeLink(tradeID, player), player)
				end
			else
				GnomeWorks:DoRecipeSelection(recipeID)
			end

			stack[lastEntry] = nil
		end
	end



	local function UnregisterUpdateEvents()
		updateEventFrames = { GetFramesRegisteredForEvent("TRADE_SKILL_UPDATE") }

		for k,f in pairs(updateEventFrames) do
			f:UnregisterEvent("TRADE_SKILL_UPDATE")
		end
	end

	local function RegisterUpdateEvents()
		for k,f in pairs(updateEventFrames) do
			f:RegisterEvent("TRADE_SKILL_UPDATE")
		end

		updateEventFrames = nil
	end


	function GnomeWorks:AddTrainableSkills(player, tradeID)
		local flatGroup = self:RecipeGroupFind(player,tradeID,"Flat")
		local categoryGroup = self:RecipeGroupFind(player,tradeID,"By Category")
		local slotGroup = self:RecipeGroupFind(player,tradeID,"By Slot")

		local subCategoryGroup = self:RecipeGroupNew(self.player, self.tradeID, "By Category", "Trainable")

		local subSlotGroup = self:RecipeGroupNew(self.player, self.tradeID, "By Slot", "Trainable")

		local index = 2000

		for recipeID,level in pairs(self.data.trainableSpells) do
			if self:GetRecipeTradeID(recipeID) == tradeID and not (self.data.knownSpells[player] and self.data.knownSpells[player][recipeID]) then
				GnomeWorks:RecipeGroupAddRecipe(subSlotGroup, recipeID, -recipeID, true)
				GnomeWorks:RecipeGroupAddRecipe(subCategoryGroup, recipeID, -recipeID, true)
				GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, -recipeID, true)

				index = index + 1
			end
		end

		self:RecipeGroupAddSubGroup(slotGroup, subSlotGroup, 1500, true)
		self:RecipeGroupAddSubGroup(categoryGroup, subCategoryGroup, 1500, true)
	end



	function GnomeWorks:GenerateTradeSkillLink(player)
		local guid = 0

		if GnomeWorksDB.guidList[player] then
			guid = GnomeWorksDB.guidList[player]
		end

		local link = GnomeWorks.libTSScan:GenerateLink(guid)

		return link
	end



	function GnomeWorks:GetTradeIDFromAPI()
		local tradeID

		local tradeName, rank, maxRank = GetTradeSkillLine()
DebugSpam("GetTradeSkill: "..(tradeName or "nil").." "..rank)

		-- get the tradeID from the tradeName name (data collected earlier).
		tradeID = self:GetTradeIDByName(tradeName)

		if tradeID == 2656 then				-- stuff the rank info into the fake smelting link for this character
			self.data.playerData[UnitName("player")].links[tradeID] = "|cffffd000|Htrade:2656:"..rank..":"..maxRank..":0:/|h["..GetSpellInfo(tradeID) .."]|h|r"			-- fake link for data collection purposes
		end

		self.tradeID = tradeID
		self.tradeIsLinked = IsTradeSkillLinked()
	end


	local scanTimeStart
	function GnomeWorks:ScanTrade()
DebugSpam("SCAN TRADE")
		if self.scanInProgress == true then
DebugSpam("SCAN BUSY!")
			return
		end


		if not self.tradeID then
		assert(false)
			return
		end

		scanTimeStart = GetTime()

		local tradeID = self.tradeID
		local player


		local isLinked, playerLinked = IsTradeSkillLinked()

		if isLinked then
			self:CacheTradeSkillLink(self:GenerateTradeSkillLink(playerLinked)) -- this makes a temporary slot, then it will be over-written by the hooked method

			player = playerLinked
			if player == UnitName("player") then
				player = "All Recipes"
			end
		else
			player = UnitName("player")
		end

		if IsTradeSkillGuild() then
			player = "Guild Recipes"
		end

		if not player then
			GnomeWorks:warning("ScanTrade can't find player name.  ",IsTradeSkillLinked())
			player = "Unknown"
		end

		self.player = player

		local name, skillType = GetTradeSkillInfo(1)

		local key = player..":"..tradeID

		dataScanned[key] = false


		if skillType ~= "header" and skillType ~= "subheader" then
--			self:ScheduleTimer("UpdateMainWindow",.1)

--			return
		end



		self.scanInProgress = true


	-- Unregsiter all frames from reacitng to update events since we're likely to generate a number of them in the scan
		UnregisterUpdateEvents()

		local numSkills = GetNumTradeSkills()
		for i = 1, numTradeSkills do
			local skillName, skillType, _, isExpanded = GetTradeSkillInfo(i)

			if skillType == "header" or skillType == "subheader" then
				if not isExpanded then
					ExpandTradeSkillSubClass(i)
				end

			end
		end

		local tradeName, rank, maxRank = GetTradeSkillLine()


DebugSpam("Scanning Trade "..(tradeName or "nil")..":"..(tradeID or "nil").." "..numSkills.." recipes")





		if not data.skillDB[key] then
			data.skillDB[key] = { difficulty = {}, recipeID = {}, cooldown = {}}
		end


		local recipe = data.skillDB[key].recipeID
		local difficulty = data.skillDB[key].difficulty
		local cooldown = data.skillDB[key].cooldown


		local results = GnomeWorksDB.results
		local tradeIDs = GnomeWorksDB.tradeIDs
		local reagents = GnomeWorksDB.reagents
		local skillUps = GnomeWorksDB.skillUps


		local lastHeader = nil
		local gotNil


		local currentGroup = nil


		local mainGroup
		local slotGroup

		if GetTradeSkillSubClasses() then
			mainGroup = self:RecipeGroupNew(player,tradeID,"By Category")

			mainGroup.locked = true
			mainGroup.autoGroup = true

			self:RecipeGroupClearEntries(mainGroup)
		end


		if GetTradeSkillInvSlots() then
			slotGroup = self:RecipeGroupNew(player,tradeID,"By Slot")

			slotGroup.locked = true
			slotGroup.autoGroup = true

			self:RecipeGroupClearEntries(slotGroup)
		end


		local flatGroup = self:RecipeGroupNew(player,tradeID,"Flat")

		flatGroup.locked = true
		flatGroup.autoGroup = true

		self:RecipeGroupClearEntries(flatGroup)


		if not self.data.knownSpells[player] then
			self.data.knownSpells[player] = {}
		end

		if not self.data.knownItems[player] then
			self.data.knownItems[player] = {}
		end


		local knownSpells = self.data.knownSpells[player]

		local knownItems = self.data.knownItems[player]


		local groupList = {}



		local numHeaders = 0

		for i = 1, numSkills, 1 do
			local localNil

			repeat
				local subSpell, extra

				local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(i)

				localNil = nil


				if skillName then
					if skillType == "header" or skillType == "subheader" then
						numHeaders = numHeaders + 1

						local groupName

						if groupList[skillName] then
							groupList[skillName] = groupList[skillName]+1
							groupName = skillName.." "..groupList[skillName]
						else
							groupList[skillName] = 1
							groupName = skillName
						end

--						currentGroup = self:RecipeGroupNew(player, tradeID, "By Category", groupName)
--						currentGroup.autoGroup = true

--						self:RecipeGroupAddSubGroup(mainGroup, currentGroup, i, true)
					else
						local recipeLink = GetTradeSkillRecipeLink(i)
						local recipeID = GetIDFromLink(recipeLink)


						if not recipeID then
							gotNil = true
							localNil = true
							break
						end


						GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)

						knownSpells[recipeID] = true



						if currentGroup then
--							GnomeWorks:RecipeGroupAddRecipe(currentGroup, recipeID, i, true)
						else
--							GnomeWorks:RecipeGroupAddRecipe(mainGroup, recipeID, i, true)
						end



						local cd = GetTradeSkillCooldown(i)

						recipe[i] = recipeID
						difficulty[i] = skillType

						if cd then
							cooldown[i] = cd + time()

--							skillDBString = skillDBString.." cd=" .. cd + time()
-- TODO: SaveCooldown info
						end


						skillIndexLookup[recipeID] = i

						if numSkillUps and numSkillUps > 1 then
							skillUps[recipeID] = numSkillUps
						else
							skillUps[recipeID] = nil
						end

						if not results[recipeID] or not recipeIsCached[recipeID] then
							local itemLink = GetTradeSkillItemLink(i)

							if not itemLink then
								gotNil = true
								localNil = true
								break
							end


							local itemID, numMade = -recipeID, 1				-- itemID = RecipeID, numMade = 1 for enchants/item enhancements



							if GetItemInfo(itemLink) then
								itemID = GetIDFromLink(itemLink)

								knownItems[itemID] = true

								local minMade,maxMade = GetTradeSkillNumMade(i)

								numMade = (minMade + maxMade) / 2

								GnomeWorks:AddToItemCache(itemID, recipeID, numMade)					-- add a cross reference for the source of particular items
							end




							local reagentData = {}

							for j=1, GetTradeSkillNumReagents(i), 1 do
								local reagentName, _, numNeeded = GetTradeSkillReagentInfo(i,j)

								local reagentID = 0

								if reagentName then
									local reagentLink = GetTradeSkillReagentItemLink(i,j)

									reagentID = GetIDFromLink(reagentLink)
								else
									localNil = true
									gotNil = true
									break
								end

								reagentData[reagentID] = numNeeded

								self:AddToReagentCache(reagentID, recipeID, numNeeded)
--								self:ItemDataAddUsedInRecipe(reagentID, recipeID)				-- add a cross reference for where a particular item is used
							end

							reagents[recipeID] = reagentData
							tradeIDs[recipeID] = tradeID
							results[recipeID] = { [itemID] = numMade }

							if localNil then
								recipeIsCached[recipeID] = nil
								results[recipeID] = nil
							end

							recipeIsCached[recipeID] = true
						else
							for itemID in pairs(results[recipeID]) do
								knownItems[itemID] = true
							end
						end


					end
				else
					gotNil = true
				end
			until true

			if localNil and recipeID then
				recipeIsCached[recipeID] = nil
				results[recipeID] = nil
			end
		end




	DebugSpam("Scan Complete",(tradeName or "nil"))


		if mainGroup then
			self:ScanCategoryGroups(mainGroup)
		end


		if slotGroup then
			self:ScanSlotGroups(slotGroup)
		end


		local scanTimeEnd = GetTime()


		if self.data.craftabilityData[self.player] then
			for inv, data in pairs(self.data.craftabilityData[self.player]) do
				table.wipe(data)
			end
		end


		self:InventoryScan()



-- re-regsiter the update events again now that we're done scanning
		RegisterUpdateEvents()


--		self:RecipeGroupConstructDBString(mainGroup)
--		self:RecipeGroupConstructDBString(flatGroup)
--		self:RecipeGroupConstructDBString(slotGroup)

		self.scanInProgress = false


		if numHeaders > 0 and not gotNil then
			dataScanned[key] = true
--print(key, "data scanned")

			self:AddTrainableSkills(player, tradeID)
		else
--print(key, "not scanned")
			self:ScheduleTimer("ScanTrade",2)
		end

		if scanTimeEnd - scanTimeStart > .25 then
			GnomeWorks:warning("trade skill scan took", scanTimeEnd - scanTimeStart,"seconds")
		end


--		self:ScheduleTimer("UpdateMainWindow",.1)
		self:SendMessageDispatch("TradeScanComplete")
--		self:SendMessageDispatch("GnomeWorksDetailsChanged")



		return skillData, player, tradeID
	end


	function GnomeWorks:IsTradeSkillDataCurrent(player, tradeID)
		if player and tradeID then
			local key = player..":"..tradeID
--print("is it scanned?",key, dataScanned[key])
			return dataScanned[key]
		end
	end

--[[
	function SkilletData:EnchantingRecipeSlotAssign(recipeID, slot)
		local recipeString = Skillet.db.account.recipeDB[recipeID]

		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)

		if itemString == "0" then
			itemString = "0:"..slot

			Skillet.db.account.recipeDB[recipeID] = tradeID.." 0:"..slot.." "..reagentString.." "..toolString

			Skillet:GetRecipe(recipeID)
	--DEFAULT_CHAT_FRAME:AddMessage(Skillet.data.recipeList[recipeID].name or "noName")

			Skillet.data.recipeList[recipeID].slot = slot
		end
	end



	local invSlotLookup = {
		["HEADSLOT"] = "HeadSlot",
		["NECKSLOT"] = "NeckSlot",
		["SHOULDERSLOT"] = "ShoulderSlot",
		["CHESTSLOT"] = "ChestSlot",
		["WAISTSLOT"] = "WaistSlot",
		["LEGSSLOT"] = "LegsSlot",
		["FEETSLOT"] = "FeetSlot",
		["WRISTSLOT"] = "WristSlot",
		["HANDSSLOT"] = "HandsSlot",
		["FINGER0SLOT"] = "Finger0Slot",
		["TRINKET0SLOT"] = "Trinket0Slot",
		["BACKSLOT"] =	"BackSlot",
		["ENCHSLOT_WEAPON"] = "MainHandSlot",
		["ENCHSLOT_2HWEAPON"] = "MainHandSlot",
		["SHIELDSLOT"] = "SecondaryHandSlot",
	}
]]


	function GnomeWorks:ScanCategoryGroups(mainGroup)
		local groupList = {}
		local gotNil

--		self:UnregisterEvent("TRADE_SKILL_UPDATE")

		if mainGroup then

			local TradeSkillSlots = { GetTradeSkillSubClasses() }

			self:RecipeGroupClearEntries(mainGroup)

			for i = 1, #TradeSkillSlots do
				local groupName
				local slotName = TradeSkillSlots[i]
				local subslots = { GetTradeSkillSubCategories(i) }

				local invSlot

				if not slotName then
					DebugSpam("Skipping nil (probably sub-slot)")
				else

					if groupList[slotName] then
						groupList[slotName] = groupList[slotName] + 1
						groupName = slotName.." "..groupList[slotName]
					else
						groupList[slotName] = 1
						groupName = slotName
					end

					local currentGroup = self:RecipeGroupNew(self.player, self.tradeID, "By Category", groupName)

					SetTradeSkillCategoryFilter(i, 0)

					local numSkills = GetNumTradeSkills()
					for s = 1, numSkills do
						local recipeLink = GetTradeSkillRecipeLink(s)

						if recipeLink then
							local recipeID = GetIDFromLink(recipeLink)
							if skillIndexLookup[recipeID] then
								self:RecipeGroupAddRecipe(currentGroup, recipeID, skillIndexLookup[recipeID], true)
							end
						end
					end

					for j, slot in pairs(subslots) do
						DebugSpam("Subslot:",slot)
						SetTradeSkillCategoryFilter(i, j)

						local numSkills = GetNumTradeSkills()
						for s = 1, numSkills do
							local recipeLink = GetTradeSkillRecipeLink(s)

							if recipeLink then
								local recipeID = GetIDFromLink(recipeLink)
--DebugSpam("adding "..(recipeLink or "nil").." to "..groupName)
--print(skillIndexLookup[recipeID])
								if skillIndexLookup[recipeID] then
									self:RecipeGroupAddRecipe(currentGroup, recipeID, skillIndexLookup[recipeID], true)
								end
							end
						end
					end

					self:RecipeGroupAddSubGroup(mainGroup, currentGroup, i + 1000, true)
				end
			end

			SetTradeSkillCategoryFilter(0, 0)
		end
	end


	function GnomeWorks:ScanSlotGroups(mainGroup)
		local groupList = {}

--		self:UnregisterEvent("TRADE_SKILL_UPDATE")

		if mainGroup then

			local TradeSkillSlots = { GetTradeSkillInvSlots() }

			self:RecipeGroupClearEntries(mainGroup)

			for i=1,#TradeSkillSlots do
				local groupName
				local slotName = TradeSkillSlots[i]

				local invSlot

				if groupList[slotName] then
					groupList[slotName] = groupList[slotName]+1
					groupName = slotName.." "..groupList[slotName]
				else
					groupList[slotName] = 1
					groupName = slotName
				end

				local currentGroup = self:RecipeGroupNew(self.player, self.tradeID, "By Slot", groupName)

				SetTradeSkillInvSlotFilter(i,1,1)

				for s=1,GetNumTradeSkills() do
					local recipeLink = GetTradeSkillRecipeLink(s)


--[[
					if TradeSkillSlots[i] ~= "NONEQUIPSLOT" then
						invSlot = GetInventorySlotInfo(invSlotLookup[ TradeSkillSlots[i] ])
						self:EnchantingRecipeSlotAssign(recipeID, invSlot)
					end
]]


					if recipeLink then
						local recipeID = GetIDFromLink(recipeLink)
--DebugSpam("adding "..(recipeLink or "nil").." to "..groupName)
						if skillIndexLookup[recipeID] then
							self:RecipeGroupAddRecipe(currentGroup, recipeID, skillIndexLookup[recipeID], true)
						end
					end

				end

				self:RecipeGroupAddSubGroup(mainGroup, currentGroup, i+1000, true)
			end
		end

		SetTradeSkillInvSlotFilter(0,1,1)

--		self:RegisterEvent("TRADE_SKILL_UPDATE")
	end


	function GnomeWorks:GetTradeSkillRankNonPlayer(player, tradeID)
		if not tradeID and not IsTradeSkillLinked() then
			local skill, rank, maxRank = self:GetTradeSkillLine()

			local skillUps = self.data.skillUpRanks[tradeID]
			if skillUps then
				if skillUps > maxRank then
					maxRank = math.ceil(skillUps / 75) * 75
				end
			end

			return rank, maxRank, self.data.skillUpRanks[self.tradeID]
		end

		tradeID = tradeID or self.tradeID
		player = player or self.player

		local link = (self.data.playerData[player] and self.data.playerData[player].links and self.data.playerData[player].links[tradeID])

		if not link then
			link = linkDB[player] and linkDB[player][tradeID]

			if not link then
				return 0, 0
			end
		end

		local rank, maxRank = string.match(link, "trade:%d+:(%d+):(%d+)")

		rank = tonumber(rank)
		maxRank = tonumber(maxRank)

		local skillUps = self.data.skillUpRanks[tradeID]
		if skillUps then
			if skillUps > maxRank then
				maxRank = math.ceil(skillUps / 75) * 75
			end
		end

		return rank, maxRank, self.data.skillUpRanks[tradeID]
	end


	function GnomeWorks:GetTradeSkillRank(player, tradeID)
		if player == "Guild Recipes" then
			return 525, 525
		end

		tradeID = tradeID or self.tradeID
		player = player or self.player

		local data = self.data.playerData[player]

		if not data then
			return self:GetTradeSkillRankNonPlayer(player, tradeID)
		end

		if not data.rank then
			return 0, 0
		end

		local rank = data.rank[tradeID] or 1
		local maxRank = data.maxRank[tradeID] or 75
		local bonus = data.bonus[tradeID] or 0

		local skillUps = self.data.skillUpRanks[tradeID]
		if skillUps then
			if skillUps > maxRank then
				maxRank = math.ceil(skillUps / 75) * 75
			end
		end

		return rank, maxRank, skillUps, bonus
	end


	function GnomeWorks:GetSkillColor(index)
		local skillName, skillType = self:GetTradeSkillInfo(index)

		return skillTypeColor[skillType]
	end

	function GnomeWorks:GetSkillDifficultyLevel(index)
		local skillName, skillType = self:GetTradeSkillInfo(index)

		return skillTypeStyle[skillType or "unknown"].level
	end

	function GnomeWorks:GetSkillDifficulty(index)
		local skillName, skillType = self:GetTradeSkillInfo(index)

		return skilltype
	end


	function GnomeWorks:GetTradeLinkList(player)
		player = player or self.player

		return (self.data.playerData[player] and self.data.playerData[player].links) or linkDB[player]
	end

	function GnomeWorks:GetTradeLink(tradeID, player)
		return self:GetTradeLinkList(player)[tradeID]
	end


	function GnomeWorks:IsSpellKnown(recipeID, player)
		if player == "All Recipes" then return true end

		player = player or self.player

		if self.data.knownSpells[player] and self.data.knownSpells[player][recipeID] then
			return true,true
		else
			local skillNeeded = self.data.trainableSpells[recipeID]
			if skillNeeded then
				local tradeID = self:GetRecipeTradeID(recipeID)

				local rank,maxRank,estimatedRank = self:GetTradeSkillRank(player, tradeID)

				if (estimatedRank or rank ) >= skillNeeded then
					return true, false
				end
			end

			return false,false
		end
	end
end
