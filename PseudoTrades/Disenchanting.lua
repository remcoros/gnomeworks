


do

--	local ArmorID = "Armor"
--	local WeaponID = "Weapon"
	local WeaponID
	local ArmorID

	GameTooltip:Hide()
	GameTooltip:SetHyperlink("item:1512")
	GameTooltip:SetHyperlink("item:1376")



	local reagentID = {
		["[Arcane Dust]"]= 22445,
		["[Dream Dust]"]= 11176,
		["[Soul Dust]"] = 11083,
		["[Strange Dust]"] = 10940,
		["[Vision Dust]"] = 11137,
		["[Illusion Dust]"] = 16204,
		["[Infinite Dust]"] = 34054,

		["[Dream Shard]"] = 34052,
		["[Greater Astral Essence]"] = 11082,
		["[Greater Cosmic Essence]"] = 34055,
		["[Greater Eternal Essence]"] = 16203,
		["[Greater Magic Essence]"] = 10939,
		["[Greater Mystic Essence]"] = 11135,
		["[Greater Nether Essence]"] = 11175,
		["[Greater Planar Essence]"] = 22446,

		["[Large Brilliant Shard]"] = 14344,
		["[Large Glimmering Shard]"]  = 11084,
		["[Large Glowing Shard]"]  = 11139,
		["[Large Prismatic Shard]"]  = 22449,
		["[Large Radiant Shard]"]  = 11178,
		["[Lesser Astral Essence]"] = 10998,
		["[Lesser Cosmic Essence]"] = 34056,
		["[Lesser Eternal Essence]"] = 16202,
		["[Lesser Magic Essence]"]= 10938,
		["[Lesser Mystic Essence]"] = 11134,
		["[Lesser Nether Essence]"] = 11174,
		["[Lesser Planar Essence]"] = 22447,

		["[Small Brilliant Shard]"]  = 14343,
		["[Small Dream Shard]"] = 34053,
		["[Small Glimmering Shard]"] = 10978,
		["[Small Glowing Shard]"] = 11138,
		["[Small Prismatic Shard]"] = 22448,
		["[Small Radiant Shard]"] = 11177,

		["[Nexus Crystal]"] = 20725,
		["[Abyss Crystal]"] = 34057,
		["[Void Crystal]"] = 22450,
	}


	local reagentSourceTable = {
		["Armor"] = {
			[5] = "[Strange Dust]		80%		1-2x	[Lesser Magic Essence]		20%		1-2x	[NIL]						0%",
			[16] = "[Strange Dust] 		75% 	2-3x 	[Greater Magic Essence] 	20% 	1-2x 	[Small Glimmering Shard] 	5%",
			[21] = "[Strange Dust] 		75% 	4-6x 	[Lesser Astral Essence] 	15% 	1-2x 	[Small Glimmering Shard] 	10%",
			[26] = "[Soul Dust] 		75% 	1-2x 	[Greater Astral Essence] 	20% 	1-2x 	[Large Glimmering Shard] 	5%",
			[31] = "[Soul Dust] 		75% 	2-5x 	[Lesser Mystic Essence] 	20% 	1-2x 	[Small Glowing Shard] 		5%",
			[36] = "[Vision Dust] 		75% 	1-2x 	[Greater Mystic Essence] 	20% 	1-2x 	[Large Glowing Shard] 		5%",
			[41] = "[Vision Dust] 		75% 	2-5x 	[Lesser Nether Essence] 	20% 	1-2x 	[Small Radiant Shard] 		5%",
			[46] = "[Dream Dust] 		75% 	1-2x 	[Greater Nether Essence] 	20% 	1-2x 	[Large Radiant Shard] 		5%",
			[51] = "[Dream Dust] 		75% 	2-5x 	[Lesser Eternal Essence] 	20% 	1-2x 	[Small Brilliant Shard] 	5%",
			[56] = "[Illusion Dust] 	75% 	1-2x 	[Greater Eternal Essence] 	20% 	1-2x 	[Large Brilliant Shard] 	5%",
			[61] = "[Illusion Dust] 	75% 	2-5x 	[Greater Eternal Essence] 	20% 	2-3x 	[Large Brilliant Shard] 	5%",
			[66] = "[Arcane Dust] 		75% 	1-3x 	[Lesser Planar Essence] 	22% 	1-3x 	[Small Prismatic Shard] 	3%",
			[81] = "[Arcane Dust] 		75% 	2-3x 	[Lesser Planar Essence] 	22% 	2-3x 	[Small Prismatic Shard] 	3%",
			[100] = "[Arcane Dust] 		75% 	2-5x 	[Greater Planar Essence] 	22% 	1-2x 	[Large Prismatic Shard] 	3%",
			[121] = "[Infinite Dust] 	75% 	1-2x 	[Lesser Cosmic Essence] 	22% 	1-2x 	[Small Dream Shard] 		3%",
			[152] = "[Infinite Dust] 	75% 	2-5x 	[Greater Cosmic Essence] 	22% 	1-2x 	[Dream Shard] 				3%",
		},
		["Weapon"] = {
			[6] =	"[Strange Dust] 	20% 	1-2x 	[Lesser Magic Essence] 		80% 	1-2x	[NIL]						0%",
			[16] = 	"[Strange Dust] 	20% 	2-3x 	[Greater Magic Essence] 	75% 	1-2x 	[Small Glimmering Shard] 	5%",
			[21] =	"[Strange Dust] 	15% 	4-6x 	[Lesser Astral Essence] 	75% 	1-2x 	[Small Glimmering Shard] 	10%",
			[26] =	"[Soul Dust] 		20% 	1-2x 	[Greater Astral Essence] 	75% 	1-2x 	[Large Glimmering Shard] 	5%",
			[31] =	"[Soul Dust] 		20% 	2-5x 	[Lesser Mystic Essence] 	75% 	1-2x 	[Small Glowing Shard] 		5%",
			[36] =	"[Vision Dust] 		20% 	1-2x 	[Greater Mystic Essence] 	75% 	1-2x 	[Large Glowing Shard] 		5%",
			[41] =	"[Vision Dust]		20% 	2-5x 	[Lesser Nether Essence] 	75% 	1-2x 	[Small Radiant Shard] 		5%",
			[46] =	"[Dream Dust]		20% 	1-2x 	[Greater Nether Essence] 	75% 	1-2x 	[Large Radiant Shard] 		5%",
			[51] =	"[Dream Dust]		22% 	2-5x 	[Lesser Eternal Essence] 	75% 	1-2x 	[Small Brilliant Shard] 	3%",
			[56] =	"[Illusion Dust] 	22% 	1-2x 	[Greater Eternal Essence] 	75% 	1-2x 	[Large Brilliant Shard] 	3%",
			[61] =	"[Illusion Dust] 	22% 	2-5x 	[Greater Eternal Essence] 	75% 	2-3x 	[Large Brilliant Shard] 	3%",
			[66] =	"[Arcane Dust] 		22% 	2-3x 	[Lesser Planar Essence] 	75% 	2-3x 	[Small Prismatic Shard] 	3%",
			[100] =	"[Arcane Dust] 		22% 	2-5x 	[Greater Planar Essence] 	75% 	1-2x 	[Large Prismatic Shard] 	3%",
			[121] =	"[Infinite Dust] 	22% 	1-2x 	[Lesser Cosmic Essence] 	75% 	1-2x 	[Small Dream Shard] 		3%",
			[152] =	"[Infinite Dust] 	22% 	2-5x 	[Greater Cosmic Essence] 	75% 	1-2x 	[Dream Shard] 				3%",
		},
		["Rare"] = {
			[11] =	"[Small Glimmering Shard] 	100%	[NIL]				0%",
			[26] =	"[Large Glimmering Shard] 	100%	[NIL]				0%",
			[31] =	"[Small Glowing Shard] 		100%	[NIL]				0%",
			[36] = 	"[Large Glowing Shard] 		100%	[NIL]				0%",
			[41] =	"[Small Radiant Shard] 		100%	[NIL]				0%",
			[46] =	"[Large Radiant Shard] 		100%	[NIL]				0%",
			[51] =	"[Small Brilliant Shard] 	100%	[NIL]				0%",
			[56] =	"[Large Brilliant Shard] 	99.5%	[Nexus Crystal] 	0.5%",
			[66] =	"[Small Prismatic Shard] 	99.5%	[Nexus Crystal] 	0.5%",
			[100] =	"[Large Prismatic Shard] 	99.5%	[Void Crystal]	 	0.5%",
			[121] =	"[Small Dream Shard] 		99.5%	[Abyss Crystal] 	0.5%",
			[165] =	"[Dream Shard] 				99.5%	[Abyss Crystal] 	0.5%",
		},
		["Epic Armor"] = {
			[40] =	"[Small Radiant Shard] 		2-4x",
			[46] = 	"[Large Radiant Shard] 		2-4x",
			[51] =	"[Small Brilliant Shard] 	2-4x",
			[56] =	"[Nexus Crystal] 			1-1x",
			[61] =	"[Nexus Crystal] 			1-2x",
			[95] =	"[Void Crystal] 			1-2x",
			[105] =	"[Void Crystal] 			1.66-1.66x",		-- 1-2x 	33% 1x, 67% 2x
			[165] =	"[Abyss Crystal] 			1-1x",
			[201] =	"[Abyss Crystal] 			1-2x",
		},
		["Epic Weapon"] = {
			[40] =	"[Small Radiant Shard] 		2-4x",
			[46] = 	"[Large Radiant Shard] 		2-4x",
			[51] =	"[Small Brilliant Shard] 	2-4x",
			[56] =	"[Nexus Crystal] 			1-1x",
			[61] =	"[Nexus Crystal] 			1-2x",
			[76] =	"[Nexus Crystal]			1.66-1.66x",		-- 1-2x 	33% 1x, 67% 2x		THIS IS THE ONLY DIFFERENCE FROM ARMOR
			[95] =	"[Void Crystal] 			1-2x",
			[105] =	"[Void Crystal] 			1.66-1.66x",		-- 1-2x 	33% 1x, 67% 2x
			[165] =	"[Abyss Crystal] 			1-1x",
			[201] =	"[Abyss Crystal] 			1-2x",
		}
	}

	local reagentBrackets = { "Armor", "Weapon", "Rare", "Epic Armor", "Epic Weapon" }

	local disenchantTable = { }


	local deExclusions = { [11287] = true, [11288] = true, [11289] = true, [11290] = true }		-- wands can't be de'd


	local deReagents = {}
	local deResults = {}
	local deNames = {}

	local bracketNames = {}


	local function BuildReagentTables()
		local armor = reagentSourceTable["Armor"]
		local weapon = reagentSourceTable["Weapon"]
		local rare = reagentSourceTable["Rare"]
		local epicArmor = reagentSourceTable["Epic Armor"]
		local epicWeapon = reagentSourceTable["Epic Weapon"]

		local armorTable = {}
		local baseLevel = 5
		local newTable = nil

		local name = nil

		for level=5,250 do
			local line

			if armor[level] then
				baseLevel = level
				newTable = {}

				line = string.gsub(armor[baseLevel], "%s+", " ")

				local dustName, dustPercent, dustMin, dustMax, essenceName, essencePercent, essenceMin, essenceMax, shardName, shardPercent = string.match(line, "(%b[]) ([%d%.]+)%% ([%d%.]+)-([%d%.]+)x (%b[]) ([%d%.]+)%% ([%d%.]+)-([%d%.]+)x (%b[]) ([%d%.]+)%%")

				if dustName and reagentID[dustName] then
					newTable[reagentID[dustName]] =  tonumber(dustPercent)/ 100 * (tonumber(dustMin) + tonumber(dustMax)) / 2
				end

				if essenceName and reagentID[essenceName] then
					newTable[reagentID[essenceName]] =  tonumber(essencePercent)/ 100 * (tonumber(essenceMin) + tonumber(essenceMax)) / 2
				end

				if shardName and reagentID[shardName] then
					newTable[reagentID[shardName]] =  tonumber(shardPercent)/ 100
				end

				armorTable[level] = newTable
			else
				armorTable[level] = newTable
			end
		end

		disenchantTable[ArmorID.."2"] = armorTable


		local weaponTable = {}
		local baseLevel = 6
		local newTable = nil

		for level=6,250 do
			local line

			if weapon[level] then
				baseLevel = level
				newTable = {}

				line = string.gsub(weapon[baseLevel], "%s+", " ")

				local dustName, dustPercent, dustMin, dustMax, essenceName, essencePercent, essenceMin, essenceMax, shardName, shardPercent = string.match(line, "(%b[]) ([%d%.]+)%% ([%d%.]+)-([%d%.]+)x (%b[]) ([%d%.]+)%% ([%d%.]+)-([%d%.]+)x (%b[]) ([%d%.]+)%%")

				if dustName and reagentID[dustName] then
					newTable[reagentID[dustName]] =  tonumber(dustPercent)/ 100 * (tonumber(dustMin) + tonumber(dustMax)) / 2
				end

				if essenceName and reagentID[essenceName] then
					newTable[reagentID[essenceName]] =  tonumber(essencePercent)/ 100 * (tonumber(essenceMin) + tonumber(essenceMax)) / 2
				end

				if shardName and reagentID[shardName] then
					newTable[reagentID[shardName]] =  tonumber(shardPercent)/ 100
				end


				weaponTable[level] = newTable
			else
				weaponTable[level] = newTable
			end
		end

		disenchantTable[WeaponID.."2"] = weaponTable



		local rareTable = {}
		local baseLevel = 11
		local newTable = nil

		for level=11,250 do
			local line

			if rare[level] then
				baseLevel = level
				newTable = {}

				line = string.gsub(rare[baseLevel], "%s+", " ")

				local shardName, shardPercent, crystalName, crystalPercent = string.match(line, "(%b[]) ([%d%.]+)%% (%b[]) ([%d%.]+)%%")

				if shardName and reagentID[shardName] then
					newTable[reagentID[shardName]] =  (tonumber(shardPercent)) / 100
				end

				if crystalName and reagentID[crystalName] then
					newTable[reagentID[crystalName]] =  (tonumber(crystalPercent)) / 100
				end

				rareTable[level] = newTable
			else
				rareTable[level] = newTable
			end
		end

		disenchantTable[WeaponID.."3"] = rareTable
		disenchantTable[ArmorID.."3"] = rareTable



		local epicArmorTable = {}
		local baseLevel = 40
		local newTable = nil

		for level=40,250 do
			local line

			if epicArmor[level] then
				baseLevel = level
				newTable = {}

				line = string.gsub(epicArmor[baseLevel], "%s+", " ")

				local shardName, shardMin, shardMax = string.match(line, "(%b[]) ([%d%.]+)-([%d%.]+)x")

				if shardName and reagentID[shardName] then
					newTable[reagentID[shardName]] =  (tonumber(shardMin) + tonumber(shardMax)) / 2
				end

				epicArmorTable[level] = newTable
			else
				epicArmorTable[level] = newTable
			end
		end

		disenchantTable[ArmorID.."4"] = epicArmorTable




		local epicWeaponTable = {}
		local baseLevel = 40
		local newTable = nil

		for level=40,250 do
			local line

			if epicWeapon[level] then
				baseLevel = level
				newTable = {}

				line = string.gsub(epicWeapon[baseLevel], "%s+", " ")

				local shardName, shardMin, shardMax = string.match(line, "(%b[]) ([%d%.]+)-([%d%.]+)x")

				if shardName and reagentID[shardName] then
					newTable[reagentID[shardName]] =  (tonumber(shardMin) + tonumber(shardMax)) / 2
				end

				epicWeaponTable[level] = newTable
			else
				epicWeaponTable[level] = newTable
			end
		end

		disenchantTable[WeaponID.."4"] = epicWeaponTable
	end



	local skillList = {}

	local api = {}

	api.DoTradeSkill = function(recipeID)
		CastSpellByName("/use "..GetSpellInfo(-recipeID))
	end

	api.GetRecipeName = function(recipeID)
		if deNames[recipeID] then
			return deNames[recipeID]
		end
	end

	api.GetRecipeData = function(recipeID)
		if deResults[recipeID] then
			return deResults[recipeID], deReagents[recipeID], 13262
		end
	end


	api.GetNumTradeSkills = function()
		return #skillList
	end

	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]
		if deResults[recipeID] then
			local itemID = next(deResults[recipeID])

			local _,link = GetItemInfo(itemID)

			return link
		end
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
		return (GetSpellInfo(13262)), 1, 1
	end

	api.GetTradeSkillInfo = function(index)
		local recipeID = skillList[index]

		return (GetSpellInfo(recipeID)) or "nil", "optimal"
	end

	api.GetTradeSkillIcon = function(index)
		local recipeID = skillList[index]
		local itemID = next(deResults[recipeID])

		return GetItemIcon(itemID)
	end

	api.IsTradeSkillLinked = function()
		return true
	end




	api.ConfigureMacroText = function(recipeID)
		return "/cast "..(GetSpellInfo(13262)).."\n/use "..GetItemInfo(next(deReagents[recipeID]))
	end


	local function GetRecipeBracket(recipeID)
		local itemID = -recipeID

		if deExclusions[itemID] then
			return
		end

		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType = GetItemInfo(itemID)

		if itemName and itemRarity > 1 and itemRarity < 5 and (itemType == ArmorID or itemType == WeaponID) then
			if itemRarity == 4 then
				return "Epic "..itemType
			end

			if itemRarity == 3 then
				return "Rare"
			end

			if itemRarity == 2 then
				return itemType
			end
		end
	end


	api.RecordKnownSpells = function(player)
		local enchantingRank = GnomeWorks:GetTradeSkillRank(player, 7411)


		if enchantingRank > 0 then
			local knownItems = GnomeWorks.data.knownItems[player]
			local knownSpells = GnomeWorks.data.knownSpells[player]


			for i = 1, #skillList, 1 do
				local recipeID = skillList[i]

				if knownItems and knownItems[-recipeID] then

					local itemID = -recipeID
					local itemName, itemLink, itemRarity, itemLevel  = GetItemInfo(itemID)
					local reqLevel = 1

					if itemLevel >= 21 and itemLevel <= 60 then
						reqLevel = (math.ceil(itemLevel/5)-4) * 25
					else
						if itemRarity < 5 then
							if itemLevel < 100 then
								reqLevel = 225
							elseif itemLevel < 130 then
								reqLevel = 275
							elseif itemLevel < 154 then
								reqLevel = 325
							else
								reqLevel = 350
							end
						else
							if itemLevel < 90 then
								reqLevel = 225
							elseif itemLevel < 130 then
								reqLevel = 300
							elseif itemLevel < 154 then
								reqLevel = 325
							elseif itemLevel < 200 then
								reqLevel = 350
							end
						end
					end

					if reqLevel <= enchantingRank then
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

		local mainGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Bracket")


		local knownItems = GnomeWorks.data.knownItems[player]


		mainGroup.locked = true
		mainGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(mainGroup)

		local bracketGroup = {}

		for i = 1, #reagentBrackets do
			local newGroup = GnomeWorks:RecipeGroupNew(player, tradeID, "By Bracket", reagentBrackets[i])
			newGroup.autoGroup = true

			bracketGroup[reagentBrackets[i]] = newGroup

			GnomeWorks:RecipeGroupAddSubGroup(mainGroup, newGroup, i, true)
		end


		local flatGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"Flat")

		flatGroup.locked = true
		flatGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(flatGroup)

		local groupList = {}

		local numHeaders = #reagentBrackets

		for i = 1, #skillList, 1 do
			local subSpell, extra

			local recipeID = skillList[i]

			if knownItems and knownItems[-recipeID] then
				GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)

				local bracketName = GetRecipeBracket(recipeID)

				GnomeWorks:RecipeGroupAddRecipe(bracketGroup[bracketName], recipeID, i, true)
			end
		end

		GnomeWorks:InventoryScan()

		collectgarbage("collect")

		GnomeWorks:ScheduleTimer("UpdateMainWindow",.1)
		GnomeWorks:SendMessageDispatch("GnomeWorksScanComplete")
		return
	end


	local function GetDisenchantTable(itemID)
		if deExclusions[itemID] then
			return
		end

		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType = GetItemInfo(itemID)

		if itemName and itemRarity > 1 and itemRarity < 5 and (itemType == ArmorID or itemType == WeaponID) then
			local tableName = itemType..itemRarity

			if disenchantTable[tableName] and disenchantTable[tableName][itemLevel] then
				return disenchantTable[tableName][itemLevel]
			end
		end
	end


	local SetUpRecipeTimer

	local function SetUpRecipes()
		_, _, _, _, _, WeaponID = GetItemInfo(1512)				-- crude battle axe
		_, _, _, _, _, ArmorID = GetItemInfo(1376)				-- frayed cloak


		if WeaponID and ArmorID then
			local trade,recipeList  = GnomeWorks:AddPseudoTrade(13262,api)

			BuildReagentTables()

			for itemID, source in pairs(GnomeWorks.data.itemSource) do
				local deTable = GetDisenchantTable(itemID)

				if deTable then
					skillList[#skillList + 1] = -itemID

					recipeList[-itemID] = trade

					deReagents[-itemID] = { [itemID] = 1 }
					deResults[-itemID] = deTable
					deNames[-itemID] = string.format("Disenchant %s",GetItemInfo(itemID) or "item:"..itemID)

					GnomeWorks:AddToReagentCache(itemID, -itemID, 1)

					for material, numMade in pairs(deTable) do
						GnomeWorks:AddToItemCache(material, -itemID, numMade)
					end
				end
			end

			trade.skillList = skillList

			GnomeWorks:CancelTimer(SetUpRecipeTimer)
		end
	end


	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes", function ()
		SetUpRecipeTimer = GnomeWorks:ScheduleRepeatingTimer(SetUpRecipes, 1)
--		SetUpRecipes()
		return true
	end)
end





