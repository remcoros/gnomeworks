





do

-- courtesy of nandini

	local cooldownGroups = {
	Alchemy = {
	  ["Transmute"] = {
	   duration = 72000 , -- 20 hours, in seconds
	   spells = {
		11479 , -- Transmute: Iron to Gold
		11480 , -- Transmute: Mithril to Truesilver
		60350 , -- Transmute: Titanium

		17559 , -- Transmute: Air to Fire
		17560 , -- Transmute: Fire to Earth
		17561 , -- Transmute: Earth to Water
		17562 , -- Transmute: Water to Air
		17563 , -- Transmute: Undeath to Water
		17565 , -- Transmute: Life to Earth
		17566 , -- Transmute: Earth to Life

		28585 , -- Transmute: Primal Earth to Life
		28566 , -- Transmute: Primal Air to Fire
		28567 , -- Transmute: Primal Earth to Water
		28568 , -- Transmute: Primal Fire to Earth
		28569 , -- Transmute: Primal Water to Air
		28580 , -- Transmute: Primal Shadow to Water
		28581 , -- Transmute: Primal Water to Shadow
		28582 , -- Transmute: Primal Mana to Fire
		28583 , -- Transmute: Primal Fire to Mana
		28584 , -- Transmute: Primal Life to Earth
		53771 , -- Transmute: Eternal Life to Shadow
		53773 , -- Transmute: Eternal Life to Fire
		53774 , -- Transmute: Eternal Fire to Water
		53775 , -- Transmute: Eternal Fire to Life
		53776 , -- Transmute: Eternal Air to Water
		53777 , -- Transmute: Eternal Air to Earth
		53779 , -- Transmute: Eternal Shadow to Earth
		53780 , -- Transmute: Eternal Shadow to Life
		53781 , -- Transmute: Eternal Earth to Air
		53782 , -- Transmute: Eternal Earth to Shadow
		53783 , -- Transmute: Eternal Water to Air
		53784 , -- Transmute: Eternal Water to Fire

		66658 , -- Transmute: Ametrine
		66659 , -- Transmute: Cardinal Ruby
		66660 , -- Transmute: King's Amber
		66662 , -- Transmute: Dreadstone
		66663 , -- Transmute: Majestic Zircon
		66664 , -- Transmute: Eye of Zul
	   } ,
	  } ,
	 } ,
	 Mining = {
	  ["Titansteel"] = {
	   duration = 72000 , -- 20 hours, in seconds
	   spells = {
		52208 , -- Smelt Titansteel
	   } ,
	  } ,
	 } ,
	 Inscription = {
	  ["Minor research"]  = {
	   duration = 72000 , -- 20 hours, in seconds
	   spells = {
		61288 , -- Minor Inscription Research
	   } ,
	  } ,
	  ["Northrend research"] = {
	   duration = 72000 , -- 20 hours, in seconds
	   spells = {
		61177 , -- Northrend Inscription Research
	   } ,
	  } ,
	 } ,
	 Enchanting = {
	  ["Void Sphere"] = {
	   duration = 172800 , -- 48 hours, in seconds
	   spells = {
		28028 , -- Void Sphere
	   } ,
	  } ,
	 } ,
	}

	local spellCooldown = {}

	for tradeSkill, cooldownGroup in pairs(cooldownGroups) do
		for groupName, data in pairs(cooldownGroup) do
			for i=1,#data.spells do
				spellCooldown[ data.spells[i] ] = cooldownGroup
			end
		end
	end

	function GnomeWorks:GetSpellCooldownGroup(recipeID)
		return spellCooldown[recipeID]
	end


--[[
-- pseudo trade info
	local tradeName = {
		[100000] = "Common",
		[100001] = "Vendor",
		[100003] = "Scroll Making",
	}

	local tradeLink = {
		[100000] = "[Common]",
		[100001] = "[Vendor]",
		[100003] = "[Scroll Making]",
	}

	local tradeIcon = {
		[100000] = "Interface\\Icons\\Ability_Creature_Cursed_01",
		[100001] = "Interface\\Icons\\INV_Misc_Bag_10",
		[100003] = "Interface\\Icons\\INV_Scroll_07",
	}
]]


--[[
-- specialization info
	local specializations = {
		[26798] = {				-- mooncloth tailor
			[26751] = {
				[21845] = 2
			},
			[56001] = {
				[41594] = 2
			}
		},
		[26801] = {				-- shadowweave
			[36686] = {
				[24272] = 2
			},
			[56002] = {
				[41593] = 2
			},
		[26797] = {				-- spellfire
			[31373] = {
				[24271] = 2
			},
			[56003] = {
				[41595] = 2
			}
		}
	}
]]



	local specializations = {
-- mooncloth
		[26751] = {
			specID = 26798,
			results = {
				[21845] = 2
			},
		},
		[56001] = {
			specID = 26798,
			results = {
				[41594] = 2
			},
		},
-- shadowweave
		[36686] = {
			specID = 26801,
			results = {
				[24272] = 2
			},
		},
		[56002] = {
			specID = 26801,
			results = {
				[41593] = 2
			},
		},
-- spellfire
		[31373] = {
			specID = 26797,
			results = {
				[24271] = 2
			},
		},
		[56003] = {
			specID = 26797,
			results = {
				[41595] = 2
			}
		},
	}

	local recipeOverRide = {
--[[
-- shadowy tarot (demons deck)
		[59491] = {
			results = {
				[44143] = .2,
				[44155] = .2,
				[44156] = .2,
				[44157] = .2,
				[44154] = .2,
			},
		},

-- arcane tarot (mages deck)
		[59487] = {
			results = {
				[44144] = .2,
				[44145] = .2,
				[44165] = .2,
				[44146] = .2,
				[44147] = .2,
			},
		},

-- strange tarot (deck of swords)
		[59480] = {
			results = {
				[37145] = .25,
				[37147] = .25,
				[37159] = .25,
				[37160] = .25,
			},
		},
-- mysterious tarot (rogues deck)
		[48247] = {
			results = {
				[37140] = .333,
				[37143] = .333,
				[37156] = .333,
			},
		},
]]
	}


	function GnomeWorks:GetRecipeName(recipeID)
		if recipeID then
			local pseudoTrade = self.data.pseudoTradeRecipes[recipeID]
			if pseudoTrade then
				return pseudoTrade.GetRecipeName(recipeID)
			end

			return GnomeWorksDB.names[recipeID] or (GetSpellInfo(recipeID))
		end
	end

	function GnomeWorks:GetTradeName(tradeID)
		if not tradeID then return "unknown" end

		local pseudoTrade = self.data.pseudoTradeData[tradeID]

		if pseudoTrade and pseudoTrade.GetTradeName then
			return pseudoTrade.GetTradeName()
		end

		return GetSpellInfo(tradeID)
	end

	--[[
	function GnomeWorks:GetTradeInfo(recipeID)
		local pseudoTrade = self.data.pseudoTradeRecipes[recipeID]
print("getTradeInfo", recipeID)
		if pseudoTrade then
			local tradeID = pseudoTrade.tradeID

			if tradeName[tradeID] then
				return tradeName[tradeID], tradeLink[tradeID], tradeIcon[tradeID]
			else
				return GetSpellInfo(tradeID)
			end
		else
			local tradeID = GnomeWorksDB.tradeIDs[recipeID]

			if tradeName[tradeID] then
				return tradeName[tradeID], tradeLink[tradeID], tradeIcon[tradeID]
			else
				return GetSpellInfo(tradeID)
			end
		end
	end
]]
	function GnomeWorks:GetTradeInfo(tradeID)
		local pseudoTrade = self.data.pseudoTradeData[tradeID]

		if pseudoTrade and pseudoTrade.GetTradeName then
			return pseudoTrade.GetTradeName(), pseudoTrade.GetTradeLink(), pseudoTrade.GetTradeIcon()
		else
			return GetSpellInfo(tradeID)
		end
	end


	function GnomeWorks:GetRecipePriority(recipeID)
		local pseudoTrade = self.data.pseudoTradeRecipes[recipeID]

		if pseudoTrade then
			return pseudoTrade.priority
		end

		return 1
	end


	function GnomeWorks:GetRecipeTradeID(recipeID)
		local pseudoTrade = self.data.pseudoTradeRecipes[recipeID]
		if pseudoTrade then
			return pseudoTrade.tradeID
		end

		return GnomeWorksDB.tradeIDs[recipeID]
	end

	local skillColor = {
		["unknown"]			= { r = 1.00, g = 0.00, b = 0.00,},
		["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25,},
		["medium"]          = { r = 1.00, g = 1.00, b = 0.00,},
		["easy"]            = { r = 0.25, g = 0.75, b = 0.25,},
		["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50,},
		["header"]          = { r = 1.00, g = 0.82, b = 0,   },
	}

	local skillLevelNames = { "unknown", "optimal", "medium", "easy", "trivial" }

	function GnomeWorks:GetRecipeDifficulty(recipeID)
		local rank,maxRank,estimatedRank,bonus = GnomeWorks:GetTradeSkillRank()
		rank = (estimatedRank or rank) - (bonus or 0)

		for i=1,#skillLevelNames-1 do
			if rank<(GnomeWorks.data.recipeSkillLevels[i][recipeID] or 0) then
				return 6-i,skillLevelNames[i],skillColor[skillLevelNames[i]]
			end
		end

		return 1,"trivial",skillColor["trivial"]
	end


	function GnomeWorks:GetRecipeData(recipeID, player)
		local pseudoTrade = self.data.pseudoTradeRecipes
		if pseudoTrade and pseudoTrade[recipeID] then
			return pseudoTrade[recipeID].GetRecipeData(recipeID)
		end

		local results,reagents = GnomeWorksDB.results[recipeID], GnomeWorksDB.reagents[recipeID]

		player = player or self.player or (UnitName("player"))

		local spec = specializations[recipeID]
		if spec and self.data.playerData[player] then
			local playerSpec = self.data.playerData[player].specializations

			if playerSpec and playerSpec[spec.specID] then
				results = spec.results
			end
		end

		if recipeOverRide[recipeID] then
			results = recipeOverRide[recipeID].results or results
			reagents = recipeOverRide[recipeID].reagents or reagents
		end

		return results, reagents, GnomeWorksDB.tradeIDs[recipeID]
	end
end


-- add smelting data from wowhead html source
do
	local smeltingRecipesData = '{"cat":11,"colors":[75,115,122,130],"creates":[2842,1,1],"id":2658,"learnedat":75,"level":0,"name":"5Smelt Silver","nskillup":1,"reagents":[[2775,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":200},{"cat":11,"colors":[0,65,90,115],"creates":[2841,2,2],"id":2659,"learnedat":65,"level":0,"name":"6Smelt Bronze","nskillup":1,"reagents":[[2840,1],[3576,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":200},{"cat":11,"colors":[155,170,177,185],"creates":[3577,1,1],"id":3308,"learnedat":155,"level":0,"name":"5Smelt Gold","nskillup":1,"reagents":[[2776,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":2500},{"cat":11,"colors":[125,130,145,160],"creates":[3575,1,1],"id":3307,"learnedat":125,"level":0,"name":"6Smelt Iron","nskillup":1,"reagents":[[2772,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":500},{"cat":11,"colors":[0,65,70,75],"creates":[3576,1,1],"id":3304,"learnedat":65,"level":0,"name":"6Smelt Tin","nskillup":1,"reagents":[[2771,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":50},{"cat":11,"colors":[0,0,0,165],"creates":[3859,1,1],"id":3569,"learnedat":165,"level":0,"name":"6Smelt Steel","nskillup":1,"reagents":[[3575,1],[3857,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":2500},{"cat":11,"colors":[1,25,47,70],"creates":[2840,1,1],"id":2657,"learnedat":1,"level":0,"name":"6Smelt Copper","nskillup":1,"reagents":[[2770,1]],"schools":1,"skill":[186],"source":[10]},{"cat":11,"colors":[230,250,270,290],"creates":[6037,1,1],"id":10098,"learnedat":230,"level":0,"name":"5Smelt Truesilver","nskillup":1,"reagents":[[7911,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":10000},{"cat":11,"colors":[0,175,202,230],"creates":[3860,1,1],"id":10097,"learnedat":175,"level":0,"name":"6Smelt Mithril","nskillup":1,"reagents":[[3858,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":5000},{"cat":11,"colors":[230,300,305,310],"creates":[11371,1,1],"id":14891,"learnedat":230,"level":0,"name":"6Smelt Dark Iron","nskillup":1,"reagents":[[11370,8]],"schools":1,"skill":[186]},{"cat":11,"colors":[230,250,270,290],"creates":[12359,1,1],"id":16153,"learnedat":230,"level":0,"name":"6Smelt Thorium","nskillup":1,"reagents":[[10620,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":20000},{"cat":11,"colors":[0,275,300,325],"creates":[23445,1,1],"id":29356,"learnedat":275,"level":0,"name":"6Smelt Fel Iron","nskillup":1,"reagents":[[23424,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":40000},{"cat":11,"colors":[0,325,332,340],"creates":[23446,1,1],"id":29358,"learnedat":325,"level":0,"name":"6Smelt Adamantite","nskillup":1,"reagents":[[23425,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":40000},{"cat":11,"colors":[0,350,357,365],"creates":[23447,1,1],"id":29359,"learnedat":350,"level":0,"name":"5Smelt Eternium","nskillup":1,"reagents":[[23427,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":40000},{"cat":11,"colors":[0,350,357,375],"creates":[23448,1,1],"id":29360,"learnedat":350,"level":0,"name":"5Smelt Felsteel","nskillup":1,"reagents":[[23445,3],[23447,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":40000},{"cat":11,"colors":[0,0,0,375],"creates":[23449,1,1],"id":29361,"learnedat":375,"level":0,"name":"5Smelt Khorium","nskillup":1,"reagents":[[23426,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":100000},{"cat":11,"colors":[0,0,0,375],"creates":[23573,1,1],"id":29686,"learnedat":375,"level":0,"name":"6Smelt Hardened Adamantite","nskillup":1,"reagents":[[23446,10]],"schools":1,"skill":[186],"source":[6],"trainingcost":100000},{"cat":11,"colors":[0,0,0,300],"creates":[22573,10,10],"id":35750,"learnedat":300,"level":0,"name":"6Earth Shatter","nskillup":1,"reagents":[[22452,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":10000},{"cat":11,"colors":[0,0,0,300],"creates":[22574,10,10],"id":35751,"learnedat":300,"level":0,"name":"6Fire Sunder","nskillup":1,"reagents":[[21884,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":10000},{"cat":11,"colors":[0,0,0,375],"creates":[35128,1,1],"id":46353,"learnedat":375,"level":0,"name":"5Smelt Hardened Khorium","nskillup":1,"reagents":[[23449,3],[23573,1]],"schools":1,"skill":[186],"source":[2]},{"cat":11,"colors":[0,350,362,375],"creates":[36916,1,1],"id":49252,"learnedat":350,"level":0,"name":"6Smelt Cobalt","nskillup":1,"reagents":[[36909,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":100000},{"cat":11,"colors":[0,0,0,400],"creates":[36913,1,1],"id":49258,"learnedat":400,"level":0,"name":"6Smelt Saronite","nskillup":1,"reagents":[[36912,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":150000},{"cat":11,"colors":[0,0,0,450],"creates":[37663,1,1],"id":55208,"learnedat":450,"level":0,"name":"5Smelt Titansteel","nskillup":1,"reagents":[[41163,3],[36860,1],[35624,1],[35627,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":200000},{"cat":11,"colors":[0,0,0,450],"creates":[41163,1,1],"id":55211,"learnedat":450,"level":0,"name":"5Smelt Titanium","nskillup":1,"reagents":[[36910,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":200000},{"cat":11,"colors":[300,350,362,375],"creates":[17771,1,1],"id":22967,"learnedat":300,"level":0,"name":"2Smelt Enchanted Elementium","nskillup":1,"reagents":[[18562,1],[12360,10],[17010,1],[18567,3]],"schools":1,"skill":[186],"source":[2]},{"cat":11,"colors":[0,250,255,260],"creates":[12655,1,1],"id":70524,"learnedat":250,"level":0,"name":"6Enchanted Thorium","nskillup":1,"reagents":[[12359,1],[11176,3]],"schools":1,"skill":[186],"source":[6],"trainingcost":10000},{"cat":11,"colors":[0,500,500,525],"creates":[53039,1,1],"id":74537,"learnedat":500,"level":0,"name":"6Smelt Hardened Elementium","nskillup":0,"reagents":[[52186,10],[52327,4]],"schools":1,"skill":[186],"source":[6],"trainingcost":50000},{"cat":11,"colors":[0,475,475,500],"creates":[52186,1,1],"id":74530,"learnedat":475,"level":0,"name":"6Smelt Elementium","nskillup":0,"reagents":[[52185,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":50000},{"cat":11,"colors":[0,0,0,525],"creates":[51950,1,1],"id":74529,"learnedat":525,"level":0,"name":"5Smelt Pyrite","nskillup":0,"reagents":[[52183,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":50000},{"cat":11,"colors":[0,425,437,475],"creates":[54849,1,1],"id":84038,"learnedat":425,"level":0,"name":"6Smelt Obsidium","nskillup":0,"reagents":[[53038,2]],"schools":1,"skill":[186],"source":[6],"trainingcost":50000}'
	local smeltingRecipeData2 = '{"classs":7,"id":17771,"level":60,"name":"2Enchanted Elementium Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_thorium","n":"Smelt Enchanted Elementium","s":186,"t":6,"ti":22967}],"subclass":7},{"classs":7,"id":37663,"level":80,"name":"5Titansteel Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_titansteel_blue","n":"Smelt Titansteel","s":186,"t":6,"ti":55208}],"subclass":7},{"classs":7,"id":23447,"level":70,"name":"5Eternium Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_11","n":"Smelt Eternium","s":186,"t":6,"ti":29359}],"subclass":7},{"classs":7,"id":23449,"level":70,"name":"5Khorium Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_09","n":"Smelt Khorium","s":186,"t":6,"ti":29361}],"subclass":7},{"classs":7,"id":35128,"level":70,"name":"5Hardened Khorium","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_thorium","n":"Smelt Hardened Khorium","s":186,"t":6,"ti":46353}],"subclass":7},{"classs":7,"id":23448,"level":60,"name":"5Felsteel Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_felsteel","n":"Smelt Felsteel","s":186,"t":6,"ti":29360}],"subclass":7},{"classs":7,"id":2842,"level":10,"name":"5Silver Bar","reqlevel":9,"slot":0,"source":[1,2,4],"sourcemore":[{"c":11,"icon":"inv_ingot_01","n":"Smelt Silver","s":186,"t":6,"ti":2658},{"z":40}],"subclass":7},{"classs":7,"id":52186,"level":83,"name":"6Elementium Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_misc_pyriumbar","n":"Smelt Elementium","s":186,"t":6,"ti":74530}],"subclass":7},{"classs":7,"id":53039,"level":83,"name":"6Hardened Elementium Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_misc_ebonsteelbar","n":"Smelt Hardened Elementium","s":186,"t":6,"ti":74537}],"subclass":7},{"classs":7,"id":54849,"level":81,"name":"6Obsidium Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_stone_15","n":"Smelt Obsidium","s":186,"t":6,"ti":84038}],"subclass":7},{"classs":7,"id":36913,"level":80,"name":"6Saronite Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_yoggthorite","n":"Smelt Saronite","s":186,"t":6,"ti":49258}],"subclass":7},{"classs":7,"id":36916,"level":72,"name":"6Cobalt Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_cobalt","n":"Smelt Cobalt","s":186,"t":6,"ti":49252}],"subclass":7},{"classs":7,"id":22573,"level":65,"name":"6Mote of Earth","slot":0,"source":[1,2,5],"sourcemore":[{"c":11,"icon":"inv_elemental_mote_earth01","n":"Earth Shatter","s":186,"t":6,"ti":35750}],"subclass":10},{"classs":7,"id":22574,"level":65,"name":"6Mote of Fire","slot":0,"source":[1,2,5],"sourcemore":[{"c":11,"icon":"inv_elemental_mote_fire01","n":"Fire Sunder","s":186,"t":6,"ti":35751}],"subclass":10},{"classs":7,"id":23446,"level":65,"name":"6Adamantite Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_10","n":"Smelt Adamantite","s":186,"t":6,"ti":29358}],"subclass":7},{"classs":7,"id":23573,"level":65,"name":"6Hardened Adamantite Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_adamantite","n":"Smelt Hardened Adamantite","s":186,"t":6,"ti":29686}],"subclass":7},{"classs":7,"id":23445,"level":60,"name":"6Fel Iron Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_feliron","n":"Smelt Fel Iron","s":186,"t":6,"ti":29356}],"subclass":7},{"classs":7,"id":11371,"level":50,"name":"6Dark Iron Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_mithril","n":"Smelt Dark Iron","s":186,"t":6,"ti":14891}],"subclass":7},{"classs":7,"id":12359,"level":50,"name":"6Thorium Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_07","n":"Smelt Thorium","s":186,"t":6,"ti":16153}],"subclass":7},{"classs":7,"id":3860,"level":40,"name":"6Mithril Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_06","n":"Smelt Mithril","s":186,"t":6,"ti":10097}],"subclass":7},{"classs":7,"id":3859,"level":35,"name":"6Steel Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_steel","n":"Smelt Steel","s":186,"t":6,"ti":3569}],"subclass":7},{"classs":7,"id":3575,"level":30,"name":"6Iron Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_iron","n":"Smelt Iron","s":186,"t":6,"ti":3307}],"subclass":7},{"classs":7,"id":2841,"level":20,"name":"6Bronze Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_bronze","n":"Smelt Bronze","s":186,"t":6,"ti":2659}],"subclass":7},{"classs":7,"id":3576,"level":20,"name":"6Tin Bar","slot":0,"source":[1],"sourcemore":[{"c":11,"icon":"inv_ingot_05","n":"Smelt Tin","s":186,"t":6,"ti":3304}],"subclass":7},{"classs":7,"id":2840,"level":10,"name":"6Copper Bar","slot":0,"source":[1,2],"sourcemore":[{"c":11,"icon":"inv_ingot_02","n":"Smelt Copper","s":186,"t":6,"ti":2657},{"icon":"inv_misc_gift_01","n":"Smokywood Pastures Gift Pack","q":1,"t":3,"ti":17727}],"subclass":7},{"classs":7,"id":51950,"level":85,"name":"5Pyrium Bar","slot":0,"source":[1],"subclass":7},{"classs":7,"id":41163,"level":80,"name":"5Titanium Bar","slot":0,"source":[1],"subclass":7},{"classs":7,"id":6037,"level":50,"name":"5Truesilver Bar","slot":0,"source":[1,2],"subclass":7},{"classs":7,"id":3577,"level":30,"name":"5Gold Bar","slot":0,"source":[1,2],"subclass":7},{"classs":7,"id":12655,"level":55,"name":"6Enchanted Thorium Bar","slot":0,"source":[1],"subclass":7}'


-- format: {"cat":11,"colors":[75,115,122,130],"creates":[2842,1,1],"id":2658,"learnedat":75,"level":0,"name":"5Smelt Silver","nskillup":1,"reagents":[[2775,1]],"schools":1,"skill":[186],"source":[6],"trainingcost":200}
	local function AddSmeltingData()
		for data in string.gmatch(smeltingRecipesData,"%b{}") do
			local orange, yellow, green, gray = string.match(data,'"colors":%[(%d+),(%d+),(%d+),(%d+)%]')
			orange = tonumber(orange)
			yellow = tonumber(yellow)
			green = tonumber(green)
			gray = tonumber(gray)

			local recipeID = tonumber(string.match(data,'"id":(%d+)'))

			local skillUps = tonumber(string.match(data,'"nskillup":(%d+)')) or 1

			local itemID,numMadeMin,numMadeMax = string.match(data,'"creates":%[(%d+),(%d+),(%d+)%]')

			itemID = tonumber(itemID)
			local numMade = ((tonumber(numMadeMin) or 1) + (tonumber(numMadeMax or numMadeMin) or 1))/2

			local reagentString = string.match(data,'"reagents":(%b[])')

			GnomeWorksDB.tradeIDs[recipeID] = 2656
			GnomeWorksDB.results[recipeID] = { [itemID] = numMade }
			GnomeWorksDB.reagents[recipeID] = {}
			GnomeWorksDB.skillUps[recipeID] = (skillUps~=1) and skillUps

			GnomeWorks.data.recipeSkillLevels[2][recipeID] = yellow
			GnomeWorks.data.recipeSkillLevels[3][recipeID] = green
			GnomeWorks.data.recipeSkillLevels[4][recipeID] = gray

			GnomeWorks:AddToItemCache(itemID, recipeID, numMade)

--			print("spell",(GetSpellLink(recipeID)))
--			print("creates", (GetItemInfo(itemID)), "x", numMade)
--			print("needs:")
			for reagentData in string.gmatch(reagentString, "%b[]") do
				local itemID, numNeeded = string.match(reagentData,"(%d+),(%d+)")
				itemID = tonumber(itemID)
				numNeeded = tonumber(numNeeded)
--				print("    ",(GetItemInfo(itemID)), "x", numNeeded)
				GnomeWorksDB.reagents[recipeID][itemID] = numNeeded
				GnomeWorks:AddToReagentCache(itemID, recipeID, numNeeded)
			end
		end
	end


	GnomeWorks:RegisterMessageDispatch("AddSpoofedRecipes",AddSmeltingData)

end


