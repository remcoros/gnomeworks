

local scrollMakingTradeID = 100003


do
	local skillList = {}
	local recipeList, trade


	local scrollIDs = {
		[27951] = 37603, -- Enchant Boots - Dexterity
		[7418] = 38679, -- Enchant Bracer - Minor Health
		[7420] = 38766, -- Enchant Chest - Minor Health
		[7426] = 38767, -- Enchant Chest - Minor Absorption
		[7428] = 38768, -- Enchant Bracer - Minor Deflection
		[7443] = 38769, -- Enchant Chest - Minor Mana
		[7454] = 38770, -- Enchant Cloak - Minor Resistance
		[7457] = 38771, -- Enchant Bracer - Minor Stamina
		[7745] = 38772, -- Enchant 2H Weapon - Minor Impact
		[7748] = 38773, -- Enchant Chest - Lesser Health
		[7766] = 38774, -- Enchant Bracer - Minor Spirit
		[7771] = 38775, -- Enchant Cloak - Minor Protection
		[7776] = 38776, -- Enchant Chest - Lesser Mana
		[7779] = 38777, -- Enchant Bracer - Minor Agility
		[7782] = 38778, -- Enchant Bracer - Minor Strength
		[7786] = 38779, -- Enchant Weapon - Minor Beastslayer
		[7788] = 38780, -- Enchant Weapon - Minor Striking
		[7793] = 38781, -- Enchant 2H Weapon - Lesser Intellect
		[7857] = 38782, -- Enchant Chest - Health
		[7859] = 38783, -- Enchant Bracer - Lesser Spirit
		[7861] = 38784, -- Enchant Cloak - Lesser Fire Resistance
		[7863] = 38785, -- Enchant Boots - Minor Stamina
		[7867] = 38786, -- Enchant Boots - Minor Agility
		[13378] = 38787, -- Enchant Shield - Minor Stamina
		[13380] = 38788, -- Enchant 2H Weapon - Lesser Spirit
		[13419] = 38789, -- Enchant Cloak - Minor Agility
		[13421] = 38790, -- Enchant Cloak - Lesser Protection
		[13464] = 38791, -- Enchant Shield - Lesser Protection
		[13485] = 38792, -- Enchant Shield - Lesser Spirit
		[13501] = 38793, -- Enchant Bracer - Lesser Stamina
		[13503] = 38794, -- Enchant Weapon - Lesser Striking
		[13522] = 38795, -- Enchant Cloak - Lesser Shadow Resistance
		[13529] = 38796, -- Enchant 2H Weapon - Lesser Impact
		[13536] = 38797, -- Enchant Bracer - Lesser Strength
		[13538] = 38798, -- Enchant Chest - Lesser Absorption
		[13607] = 38799, -- Enchant Chest - Mana
		[13612] = 38800, -- Enchant Gloves - Mining
		[13617] = 38801, -- Enchant Gloves - Herbalism
		[13620] = 38802, -- Enchant Gloves - Fishing
		[13622] = 38803, -- Enchant Bracer - Lesser Intellect
		[13626] = 38804, -- Enchant Chest - Minor Stats
		[13631] = 38805, -- Enchant Shield - Lesser Stamina
		[13635] = 38806, -- Enchant Cloak - Defense
		[13637] = 38807, -- Enchant Boots - Lesser Agility
		[13640] = 38808, -- Enchant Chest - Greater Health
		[13642] = 38809, -- Enchant Bracer - Spirit
		[13644] = 38810, -- Enchant Boots - Lesser Stamina
		[13646] = 38811, -- Enchant Bracer - Lesser Deflection
		[13648] = 38812, -- Enchant Bracer - Stamina
		[13653] = 38813, -- Enchant Weapon - Lesser Beastslayer
		[13655] = 38814, -- Enchant Weapon - Lesser Elemental Slayer
		[13657] = 38815, -- Enchant Cloak - Fire Resistance
		[13659] = 38816, -- Enchant Shield - Spirit
		[13661] = 38817, -- Enchant Bracer - Strength
		[13663] = 38818, -- Enchant Chest - Greater Mana
		[13687] = 38819, -- Enchant Boots - Lesser Spirit
		[13689] = 38820, -- Enchant Shield - Lesser Block
		[13693] = 38821, -- Enchant Weapon - Striking
		[13695] = 38822, -- Enchant 2H Weapon - Impact
		[13698] = 38823, -- Enchant Gloves - Skinning
		[13700] = 38824, -- Enchant Chest - Lesser Stats
		[13746] = 38825, -- Enchant Cloak - Greater Defense
		[13794] = 38826, -- Enchant Cloak - Resistance
		[13815] = 38827, -- Enchant Gloves - Agility
		[13817] = 38828, -- Enchant Shield - Stamina
		[13822] = 38829, -- Enchant Bracer - Intellect
		[13836] = 38830, -- Enchant Boots - Stamina
		[13841] = 38831, -- Enchant Gloves - Advanced Mining
		[13846] = 38832, -- Enchant Bracer - Greater Spirit
		[13858] = 38833, -- Enchant Chest - Superior Health
		[13868] = 38834, -- Enchant Gloves - Advanced Herbalism
		[13882] = 38835, -- Enchant Cloak - Lesser Agility
		[13887] = 38836, -- Enchant Gloves - Strength
		[13890] = 38837, -- Enchant Boots - Minor Speed
		[13898] = 38838, -- Enchant Weapon - Fiery Weapon
		[13905] = 38839, -- Enchant Shield - Greater Spirit
		[13915] = 38840, -- Enchant Weapon - Demonslaying
		[13917] = 38841, -- Enchant Chest - Superior Mana
		[13931] = 38842, -- Enchant Bracer - Deflection
		[13933] = 38843, -- Enchant Shield - Frost Resistance
		[13935] = 38844, -- Enchant Boots - Agility
		[13937] = 38845, -- Enchant 2H Weapon - Greater Impact
		[13939] = 38846, -- Enchant Bracer - Greater Strength
		[13941] = 38847, -- Enchant Chest - Stats
		[13943] = 38848, -- Enchant Weapon - Greater Striking
		[13945] = 38849, -- Enchant Bracer - Greater Stamina
		[13947] = 38850, -- Enchant Gloves - Riding Skill
		[13948] = 38851, -- Enchant Gloves - Minor Haste
		[20008] = 38852, -- Enchant Bracer - Greater Intellect
		[20009] = 38853, -- Enchant Bracer - Superior Spirit
		[20010] = 38854, -- Enchant Bracer - Superior Strength
		[20011] = 38855, -- Enchant Bracer - Superior Stamina
		[20012] = 38856, -- Enchant Gloves - Greater Agility
		[20013] = 38857, -- Enchant Gloves - Greater Strength
		[20014] = 38858, -- Enchant Cloak - Greater Resistance
		[20015] = 38859, -- Enchant Cloak - Superior Defense
		[20016] = 38860, -- Enchant Shield - Vitality
		[20017] = 38861, -- Enchant Shield - Greater Stamina
		[20020] = 38862, -- Enchant Boots - Greater Stamina
		[20023] = 38863, -- Enchant Boots - Greater Agility
		[20024] = 38864, -- Enchant Boots - Spirit
		[20025] = 38865, -- Enchant Chest - Greater Stats
		[20026] = 38866, -- Enchant Chest - Major Health
		[20028] = 38867, -- Enchant Chest - Major Mana
		[20029] = 38868, -- Enchant Weapon - Icy Chill
		[20030] = 38869, -- Enchant 2H Weapon - Superior Impact
		[20031] = 38870, -- Enchant Weapon - Superior Striking
		[20032] = 38871, -- Enchant Weapon - Lifestealing
		[20033] = 38872, -- Enchant Weapon - Unholy Weapon
		[20034] = 38873, -- Enchant Weapon - Crusader
		[20035] = 38874, -- Enchant 2H Weapon - Major Spirit
		[20036] = 38875, -- Enchant 2H Weapon - Major Intellect
		[21931] = 38876, -- Enchant Weapon - Winter's Might
		[22749] = 38877, -- Enchant Weapon - Spellpower
		[22750] = 38878, -- Enchant Weapon - Healing Power
		[23799] = 38879, -- Enchant Weapon - Strength
		[23800] = 38880, -- Enchant Weapon - Agility
		[23801] = 38881, -- Enchant Bracer - Mana Regeneration
		[23802] = 38882, -- Enchant Bracer - Healing Power
		[23803] = 38883, -- Enchant Weapon - Mighty Spirit
		[23804] = 38884, -- Enchant Weapon - Mighty Intellect
		[25072] = 38885, -- Enchant Gloves - Threat
		[25073] = 38886, -- Enchant Gloves - Shadow Power
		[25074] = 38887, -- Enchant Gloves - Frost Power
		[25078] = 38888, -- Enchant Gloves - Fire Power
		[25079] = 38889, -- Enchant Gloves - Healing Power
		[25080] = 38890, -- Enchant Gloves - Superior Agility
		[25081] = 38891, -- Enchant Cloak - Greater Fire Resistance
		[25082] = 38892, -- Enchant Cloak - Greater Nature Resistance
		[25083] = 38893, -- Enchant Cloak - Stealth
		[25084] = 38894, -- Enchant Cloak - Subtlety
		[25086] = 38895, -- Enchant Cloak - Dodge
		[27837] = 38896, -- Enchant 2H Weapon - Agility
		[27899] = 38897, -- Enchant Bracer - Brawn
		[27905] = 38898, -- Enchant Bracer - Stats
		[27906] = 38899, -- Enchant Bracer - Major Defense
		[27911] = 38900, -- Enchant Bracer - Superior Healing
		[27913] = 38901, -- Enchant Bracer - Restore Mana Prime
		[27914] = 38902, -- Enchant Bracer - Fortitude
		[27917] = 38903, -- Enchant Bracer - Spellpower
		[27944] = 38904, -- Enchant Shield - Tough Shield
		[27945] = 38905, -- Enchant Shield - Intellect
		[27946] = 38906, -- Enchant Shield - Shield Block
		[27947] = 38907, -- Enchant Shield - Resistance
		[27948] = 38908, -- Enchant Boots - Vitality
		[27950] = 38909, -- Enchant Boots - Fortitude
		[27954] = 38910, -- Enchant Boots - Surefooted
		[27957] = 38911, -- Enchant Chest - Exceptional Health
		[27958] = 38912, -- Enchant Chest - Exceptional Mana
		[27960] = 38913, -- Enchant Chest - Exceptional Stats
		[27961] = 38914, -- Enchant Cloak - Major Armor
		[27962] = 38915, -- Enchant Cloak - Major Resistance
		[27967] = 38917, -- Enchant Weapon - Major Striking
		[27968] = 38918, -- Enchant Weapon - Major Intellect
		[27971] = 38919, -- Enchant 2H Weapon - Savagery
		[27972] = 38920, -- Enchant Weapon - Potency
		[27975] = 38921, -- Enchant Weapon - Major Spellpower
		[27977] = 38922, -- Enchant 2H Weapon - Major Agility
		[27981] = 38923, -- Enchant Weapon - Sunfire
		[27982] = 38924, -- Enchant Weapon - Soulfrost
		[27984] = 38925, -- Enchant Weapon - Mongoose
		[28003] = 38926, -- Enchant Weapon - Spellsurge
		[28004] = 38927, -- Enchant Weapon - Battlemaster
		[33990] = 38928, -- Enchant Chest - Major Spirit
		[33991] = 38929, -- Enchant Chest - Restore Mana Prime
		[33992] = 38930, -- Enchant Chest - Major Resilience
		[33993] = 38931, -- Enchant Gloves - Blasting
		[33994] = 38932, -- Enchant Gloves - Precise Strikes
		[33995] = 38933, -- Enchant Gloves - Major Strength
		[33996] = 38934, -- Enchant Gloves - Assault
		[33997] = 38935, -- Enchant Gloves - Major Spellpower
		[33999] = 38936, -- Enchant Gloves - Major Healing
		[34001] = 38937, -- Enchant Bracer - Major Intellect
		[34002] = 38938, -- Enchant Bracer - Assault
		[34003] = 38939, -- Enchant Cloak - Spell Penetration
		[34004] = 38940, -- Enchant Cloak - Greater Agility
		[34005] = 38941, -- Enchant Cloak - Greater Arcane Resistance
		[34006] = 38942, -- Enchant Cloak - Greater Shadow Resistance
		[34007] = 38943, -- Enchant Boots - Cat's Swiftness
		[34008] = 38944, -- Enchant Boots - Boar's Speed
		[34009] = 38945, -- Enchant Shield - Major Stamina
		[34010] = 38946, -- Enchant Weapon - Major Healing
		[42620] = 38947, -- Enchant Weapon - Greater Agility
		[42974] = 38948, -- Enchant Weapon - Executioner
		[44383] = 38949, -- Enchant Shield - Resilience
		[44483] = 38950, -- Enchant Cloak - Superior Frost Resistance
		[44484] = 38951, -- Enchant Gloves - Expertise
		[44488] = 38953, -- Enchant Gloves - Precision
		[44489] = 38954, -- Enchant Shield - Defense
		[44492] = 38955, -- Enchant Chest - Mighty Health
		[44494] = 38956, -- Enchant Cloak - Superior Nature Resistance
		[44500] = 38959, -- Enchant Cloak - Superior Agility
		[44506] = 38960, -- Enchant Gloves - Gatherer
		[44508] = 38961, -- Enchant Boots - Greater Spirit
		[44509] = 38962, -- Enchant Chest - Greater Mana Restoration
		[44510] = 38963, -- Enchant Weapon - Exceptional Spirit
		[44513] = 38964, -- Enchant Gloves - Greater Assault
		[44524] = 38965, -- Enchant Weapon - Icebreaker
		[44528] = 38966, -- Enchant Boots - Greater Fortitude
		[44529] = 38967, -- Enchant Gloves - Major Agility
		[44555] = 38968, -- Enchant Bracers - Exceptional Intellect
		[44556] = 38969, -- Enchant Cloak - Superior Fire Resistance
		[60616] = 38971, -- Enchant Bracers - Striking
		[44576] = 38972, -- Enchant Weapon - Lifeward
		[44582] = 38973, -- Enchant Cloak - Spell Piercing
		[44584] = 38974, -- Enchant Boots - Greater Vitality
		[44588] = 38975, -- Enchant Chest - Exceptional Resilience
		[44589] = 38976, -- Enchant Boots - Superior Agility
		[44590] = 38977, -- Enchant Cloak - Superior Shadow Resistance
		[44591] = 38978, -- Enchant Cloak - Titanweave
		[44592] = 38979, -- Enchant Gloves - Exceptional Spellpower
		[44593] = 38980, -- Enchant Bracers - Major Spirit
		[44595] = 38981, -- Enchant 2H Weapon - Scourgebane
		[44596] = 38982, -- Enchant Cloak - Superior Arcane Resistance
		[44598] = 38984, -- Enchant Bracers - Expertise
		[60623] = 38986, -- Enchant Boots - Icewalker
		[44616] = 38987, -- Enchant Bracers - Greater Stats
		[44621] = 38988, -- Enchant Weapon - Giant Slayer
		[44623] = 38989, -- Enchant Chest - Super Stats
		[44625] = 38990, -- Enchant Gloves - Armsman
		[44629] = 38991, -- Enchant Weapon - Exceptional Spellpower
		[44630] = 38992, -- Enchant 2H Weapon - Greater Savagery
		[44631] = 38993, -- Enchant Cloak - Shadow Armor
		[44633] = 38995, -- Enchant Weapon - Exceptional Agility
		[44635] = 38997, -- Enchant Bracers - Greater Spellpower
		[46578] = 38998, -- Enchant Weapon - Deathfrost
		[46594] = 38999, -- Enchant Chest - Defense
		[47051] = 39000, -- Enchant Cloak - Steelweave
		[47672] = 39001, -- Enchant Cloak - Mighty Armor
		[47766] = 39002, -- Enchant Chest - Greater Defense
		[47899] = 39004, -- Enchant Cloak - Wisdom
		[47900] = 39005, -- Enchant Chest - Super Health
		[47901] = 39006, -- Enchant Boots - Tuskarr's Vitality
		[59625] = 43987, -- Enchant Weapon - Black Magic
		[60606] = 44449, -- Enchant Boots - Assault
		[60621] = 44453, -- Enchant Weapon - Greater Potency
		[60653] = 44455, -- Enchant Shield - Greater Intellect
		[60609] = 44456, -- Enchant Cloak - Speed
		[60663] = 44457, -- Enchant Cloak - Major Agility
		[60668] = 44458, -- Enchant Gloves - Crusher
		[60691] = 44463, -- Enchant 2H Weapon - Massacre
		[60692] = 44465, -- Enchant Chest - Powerful Stats
		[60707] = 44466, -- Enchant Weapon - Superior Potency
		[60714] = 44467, -- Enchant Weapon - Mighty Spellpower
		[60763] = 44469, -- Enchant Boots - Greater Assault
		[60767] = 44470, -- Enchant Bracers - Superior Spellpower
		[59621] = 44493, -- Enchant Weapon - Berserking
		[59619] = 44497, -- Enchant Weapon - Accuracy
		[44575] = 44815, -- Enchant Bracers - Greater Assault
		[62256] = 44947, -- Enchant Bracers - Major Stamina
		[62948] = 45056, -- Enchant Staff - Greater Spellpower
		[62959] = 45060, -- Enchant Staff - Spellpower
		[63746] = 45628, -- Enchant Boots - Lesser Accuracy
		[64441] = 46026, -- Enchant Weapon - Blade Ward
		[64579] = 46098, -- Enchant Weapon - Blood Draining
		[71692] = 50816, -- Enchant Gloves - Angler
		[74132] = 52687, -- Enchant Gloves - Mastery
		[74189] = 52743, -- Enchant Boots - Earthen Vitality
		[74191] = 52744, -- Enchant Chest - Mighty Stats
		[74192] = 52745, -- Enchant Cloak - Greater Spell Piercing
		[74193] = 52746, -- Enchant Bracer - Speed
		[74195] = 52747, -- Enchant Weapon - Mending
		[74197] = 52748, -- Enchant Weapon - Avalanche
		[74198] = 52749, -- Enchant Gloves - Haste
		[74199] = 52750, -- Enchant Boots - Haste
		[74200] = 52751, -- Enchant Chest - Stamina
		[74201] = 52752, -- Enchant Bracer - Critical Strike
		[74202] = 52753, -- Enchant Cloak - Intellect
		[74207] = 52754, -- Enchant Shield - Protection
		[74211] = 52755, -- Enchant Weapon - Elemental Slayer
		[74212] = 52756, -- Enchant Gloves - Exceptional Strength
		[74213] = 52757, -- Enchant Boots - Major Agility
		[74214] = 52758, -- Enchant Chest - Mighty Resilience
		[74220] = 52759, -- Enchant Gloves - Greater Expertise
		[74223] = 52760, -- Enchant Weapon - Hurricane
		[74225] = 52761, -- Enchant Weapon - Heartsong
		[74226] = 52762, -- Enchant Shield - Blocking
		[74229] = 52763, -- Enchant Bracer - Dodge
		[74230] = 52764, -- Enchant Cloak - Critical Strike
		[74231] = 52765, -- Enchant Chest - Exceptional Spirit
		[74232] = 52766, -- Enchant Bracer - Precision
		[74234] = 52767, -- Enchant Cloak - Protection
		[74235] = 52768, -- Enchant Off-Hand - Superior Intellect
		[74236] = 52769, -- Enchant Boots - Precision
		[74237] = 52770, -- Enchant Bracer - Exceptional Spirit
		[74238] = 52771, -- Enchant Boots - Mastery
		[74239] = 52772, -- Enchant Bracer - Greater Expertise
		[74240] = 52773, -- Enchant Cloak - Greater Intellect
		[74242] = 52774, -- Enchant Weapon - Power Torrent
		[74244] = 52775, -- Enchant Weapon - Windwalk
		[74246] = 52776, -- Enchant Weapon - Landslide
		[74247] = 52777, -- Enchant Cloak - Greater Critical Strike
		[74248] = 52778, -- Enchant Bracer - Greater Critical Strike
		[74250] = 52779, -- Enchant Chest - Peerless Stats
		[74251] = 52780, -- Enchant Chest - Greater Stamina
		[74252] = 52781, -- Enchant Boots - Assassin's Step
		[74253] = 52782, -- Enchant Boots - Lavawalker
		[74254] = 52783, -- Enchant Gloves - Mighty Strength
		[74255] = 52784, -- Enchant Gloves - Greater Mastery
		[74256] = 52785, -- Enchant Bracer - Greater Speed
		[95471] = 68134, -- Enchant 2H Weapon - Mighty Agility
	}


	local function ScrollMakingSpellID(enchantID)
		return enchantID+400000
	end

	local function ScrollMakingEnchantID(spellID)
		return spellID-400000
	end


	local reagents = {}
	local results = {}


	local api = {}




	local function AttachVellum()

		if GnomeWorks.isProcessing then
			UseItemByName(38682)
		end

		return true
	end



	local f = CreateFrame("Frame")

	f:RegisterEvent("UPDATE_TRADESKILL_RECAST")


	f:SetScript("OnEvent", function(frame,event)
		local count = GetTradeskillRepeatCount()

		if count > 0 then
			GnomeWorks:ScheduleTimer(AttachVellum, 1)

--			UseItemByName(38682)
		end
	end)

	f:Hide()




	api.SpellCastCheck = function(recipeID, spellID)
		local enchantID = ScrollMakingEnchantID(recipeID)
		if enchantID == spellID then
			return true
		end
	end


	api.DoTradeSkill = function(recipeID, count)
		CastSpellByName(GetSpellInfo(7411))

		local enchantID = ScrollMakingEnchantID(recipeID)
		local skillIndex = GnomeWorks:FindRecipeSkillIndex(enchantID)

		if skillIndex then
--			GnomeWorks:RegisterMessageDispatch("TradeProcessing", AttachVellum, "AttachVellum")

			DoTradeSkill(skillIndex, 1)
--			GnomeWorks:PickUpItem(38682)
			UseItemByName(38682)
		end
	end

	api.GetRecipeName = function(recipeID)
		local enchantID = ScrollMakingEnchantID(recipeID)
		local scrollID = scrollIDs[enchantID]

		return (GetItemInfo(scrollID))
	end

	api.GetRecipeData = function(recipeID)
		if results[recipeID] then
			return results[recipeID], reagents[recipeID], scrollMakingTradeID
		end
	end


	api.GetNumTradeSkills = function()
		return #skillList
	end

	api.GetTradeSkillItemLink = function(index)
		local recipeID = skillList[index]

		local enchantID = ScrollMakingEnchantID(recipeID)
		local scrollID = scrollIDs[enchantID]

		if scrollID then
			local _,link = GetItemInfo(scrollID)

			return link
		end
	end

	api.GetTradeSkillRecipeLink = function(index)
		local recipeID = skillList[index]

		if recipeID then
			local enchantID = ScrollMakingEnchantID(recipeID)
			local scrollID = scrollIDs[enchantID]
			return "|cff80a0ff|Henchant:"..recipeID.."|h["..(GetItemInfo(scrollID)).."]|h|r"
		end
	end


	api.GetTradeSkillLine = function()
		local rank, maxRank = GnomeWorks:GetTradeSkillRanks(GnomeWorks.player, 7411)
		return "Scroll Making", rank, maxRank
	end

	api.GetTradeSkillInfo = function(index)
		local recipeID = skillList[index]

		return (recipeID and (GetItemInfo(recipeID))) or "nil", "optimal"
	end

	api.GetTradeSkillIcon = function(index)
		local recipeID = skillList[index]
		local enchantID = ScrollMakingEnchantID(recipeID)
		local scrollID = scrollIDs[enchantID]

		return GetItemIcon(scrollID)
	end

	api.IsTradeSkillLinked = function()
		return true
	end

--[[
	api.ConfigureMacroText = function(recipeID)
		local enchanting = GetSpellInfo(7411)
		local recipeName = \"..GetSpellInfo(ScrollMakingEnchantID(recipeID))..\"

		local castString = "/cast "..enchanting.."\r/script for i=1,1000 do if GetTradeSkillInfo(i)=="..recipeName.." then DoTradeSkill(i) break end end\r/use "..GetItemInfo(38682)

		return castString

--		return "/cast "..(GetSpellInfo(13262)).."\n/use "..GetItemInfo(next(deReagents[recipeID]))
	end
]]


	api.RecordKnownSpells = function(player)
		local knownSpells = GnomeWorks.data.knownSpells[player]

		for spellID in pairs(knownSpells) do
			if scrollIDs[spellID] and knownSpells[spellID] then
				local recipeID = ScrollMakingSpellID(scrollIDs[spellID])

				knownSpells[recipeID] = true
			end
		end
	end




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

--		local groupList = {}

--		local numHeaders = #reagentBrackets

		local knownSpells = GnomeWorks.data.knownSpells[player]

		for i = 1, #skillList, 1 do
			local subSpell, extra

			local recipeID = skillList[i]

			local enchantID = ScrollMakingEnchantID(recipeID)

			if knownSpells[enchantID] then
				knownSpells[recipeID] = true
				GnomeWorks:RecipeGroupAddRecipe(flatGroup, recipeID, i, true)
			end
		end

		GnomeWorks:CraftabilityPurge()
		GnomeWorks:InventoryScan()

		collectgarbage("collect")

--		GnomeWorks:ScheduleTimer("UpdateMainWindow",.1)
		GnomeWorks:SendMessageDispatch("TradeScanComplete")
		return
	end




	local function SetUpRecipes(trade,recipeList)
		reagents = {}
		results = {}
		skillList = {}

		for enchantID, scrollID in pairs(scrollIDs) do
			local recipeID = ScrollMakingSpellID(enchantID)

			for i=1,4 do
				GnomeWorks.data.recipeSkillLevels[i][recipeID] = GnomeWorks.data.recipeSkillLevels[i][enchantID]
			end

			local enchantReagents = GnomeWorksDB.reagents[enchantID]

			if enchantReagents then
				skillList[#skillList +1] = recipeID

				recipeList[recipeID] = trade

				reagents[recipeID] = {}

				for itemID, numNeeded in pairs(enchantReagents) do
					reagents[recipeID][itemID] = numNeeded
					GnomeWorks:AddToReagentCache(itemID, recipeID, 1)
				end

				reagents[recipeID][38682] = 1
				results[recipeID] = { [scrollID] = 1 }

				GnomeWorks:AddToReagentCache(38682, recipeID, 1)
				GnomeWorks:AddToItemCache(scrollID, recipeID, 1)
			end
		end
	end

	api.GetTradeName = function()
		return "Scroll Making"
	end


	api.GetTradeLink = function()
		return "[Scroll Making]"
	end


	api.GetTradeIcon = function()
		return "Interface\\Icons\\INV_Scroll_07"
	end



	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes", function ()
		local trade,recipeList  = GnomeWorks:AddPseudoTrade(scrollMakingTradeID,api)
		SetUpRecipes(trade,recipeList)
		trade.skillList = skillList

		GnomeWorks.system.levelBasis[scrollMakingTradeID] = 7411

		return true
	end)
end





