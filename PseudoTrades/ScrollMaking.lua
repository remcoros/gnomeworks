

local scrollMakingTradeID = 1000003


do
	local skillList = {}
	local recipeList, trade

	--	320	total recipes
	--	313	total scrolls
	local scrollIDs = {
		-- [???????] = 38958, -- Enchant Weapon - Exceptional Intellect can't find corresponding recipe
		-- [???????] = 38957, -- Enchant Weapon - Exceptional Striking can't find corresponding recipe
		-- [???????] = 5421, -- Fiery Blaze Enchantment can't find corresponding recipe
		-- [???????] = 38994, -- Enchant Weapon - Exceptional Healing can't find corresponding recipe
		-- [???????] = 38996, -- Enchant Bracers - Major Healing can't find corresponding recipe
		-- [???????] = 38983, -- Enchant Shield - Mighty Stamina can't find corresponding recipe
		-- [???????] = 38970, -- Enchant Gloves - Exceptional Healing can't find corresponding recipe
		[20023] = 38863, -- Enchant Boots - Greater Agility  (1)
		[13746] = 38825, -- Enchant Cloak - Greater Defense  (2)
		[44528] = 38966, -- Enchant Boots - Greater Fortitude  (3)
		[64579] = 46098, -- Enchant Weapon - Blood Draining  (4)
		[13693] = 38821, -- Enchant Weapon - Striking  (5)
		[47766] = 39002, -- Enchant Chest - Greater Dodge  (6)
		[60623] = 38986, -- Enchant Boots - Icewalker  (7)
		[27913] = 38901, -- Enchant Bracer - Restore Mana Prime  (8)
		[62256] = 44947, -- Enchant Bracer - Major Stamina  (9)
		[23803] = 38883, -- Enchant Weapon - Mighty Spirit  (10)
		[44555] = 38968, -- Enchant Bracer - Exceptional Intellect  (11)
		[96262] = 68786, -- Enchant Bracer - Mighty Intellect  (12)
		[47898] = 39003, -- Enchant Cloak - Greater Speed  (13)
		[7859] = 38783, -- Enchant Bracer - Lesser Spirit  (14)
		[74254] = 52783, -- Enchant Gloves - Mighty Strength  (15)
		[96261] = 68785, -- Enchant Bracer - Major Strength  (16)
		[20009] = 38853, -- Enchant Bracer - Superior Spirit  (17)
		[27972] = 38920, -- Enchant Weapon - Potency  (18)
		[20010] = 38854, -- Enchant Bracer - Superior Strength  (19)
		[74247] = 52777, -- Enchant Cloak - Greater Critical Strike  (20)
		[34009] = 38945, -- Enchant Shield - Major Stamina  (21)
		[27906] = 38899, -- Enchant Bracer - Greater Dodge  (22)
		[74192] = 52745, -- Enchant Cloak - Greater Spell Piercing  (23)
		[44575] = 44815, -- Enchant Bracer - Greater Assault  (24)
		[27899] = 38897, -- Enchant Bracer - Brawn  (25)
		[7443] = 38769, -- Enchant Chest - Minor Mana  (26)
		[27951] = 37603, -- Enchant Boots - Dexterity  (27)
		[34005] = 38941, -- Enchant Cloak - Greater Arcane Resistance  (28)
		[46594] = 38999, -- Enchant Chest - Dodge  (29)
		[71692] = 50816, -- Enchant Gloves - Angler  (30)
		[27837] = 38896, -- Enchant 2H Weapon - Agility  (31)
		[13898] = 38838, -- Enchant Weapon - Fiery Weapon  (32)
		[7782] = 38778, -- Enchant Bracer - Minor Strength  (33)
		[27954] = 38910, -- Enchant Boots - Surefooted  (34)
		[74255] = 52784, -- Enchant Gloves - Greater Mastery  (35)
		[33994] = 38932, -- Enchant Gloves - Precise Strikes  (36)
		[25084] = 38894, -- Enchant Cloak - Subtlety  (37)
		[20031] = 38870, -- Enchant Weapon - Superior Striking  (38)
		[60616] = 38971, -- Enchant Bracer - Assault  (39)
		[13905] = 38839, -- Enchant Shield - Greater Spirit  (40)
		[27905] = 38898, -- Enchant Bracer - Stats  (41)
		[74202] = 52753, -- Enchant Cloak - Intellect  (42)
		[44625] = 38990, -- Enchant Gloves - Armsman  (43)
		[13887] = 38836, -- Enchant Gloves - Strength  (44)
		[74212] = 52756, -- Enchant Gloves - Exceptional Strength  (45)
		[13858] = 38833, -- Enchant Chest - Superior Health  (46)
		[7857] = 38782, -- Enchant Chest - Health  (47)
		[60606] = 44449, -- Enchant Boots - Assault  (48)
		[13642] = 38809, -- Enchant Bracer - Spirit  (49)
		[20029] = 38868, -- Enchant Weapon - Icy Chill  (50)
		[33997] = 38935, -- Enchant Gloves - Major Spellpower  (51)
		[44483] = 38950, -- Enchant Cloak - Superior Frost Resistance  (52)
		[33992] = 38930, -- Enchant Chest - Major Resilience  (53)
		[20013] = 38857, -- Enchant Gloves - Greater Strength  (54)
		[13501] = 38793, -- Enchant Bracer - Lesser Stamina  (55)
		[44621] = 38988, -- Enchant Weapon - Giant Slayer  (56)
		[13917] = 38841, -- Enchant Chest - Superior Mana  (57)
		[74239] = 52772, -- Enchant Bracer - Greater Expertise  (58)
		[44598] = 38984, -- Enchant Bracer - Expertise  (59)
		[60714] = 44467, -- Enchant Weapon - Mighty Spellpower  (60)
		[27961] = 38914, -- Enchant Cloak - Major Armor  (61)
		[74220] = 52759, -- Enchant Gloves - Greater Expertise  (62)
		[46578] = 38998, -- Enchant Weapon - Deathfrost  (63)
		[44635] = 38997, -- Enchant Bracer - Greater Spellpower  (64)
		[34006] = 38942, -- Enchant Cloak - Greater Shadow Resistance  (65)
		[27981] = 38923, -- Enchant Weapon - Sunfire  (66)
		[44513] = 38964, -- Enchant Gloves - Greater Assault  (67)
		[23802] = 38882, -- Enchant Bracer - Healing Power  (68)
		[20035] = 38874, -- Enchant 2H Weapon - Major Spirit  (69)
		[44596] = 38982, -- Enchant Cloak - Superior Arcane Resistance  (70)
		[42974] = 38948, -- Enchant Weapon - Executioner  (71)
		[7745] = 38772, -- Enchant 2H Weapon - Minor Impact  (72)
		[44556] = 38969, -- Enchant Cloak - Superior Fire Resistance  (73)
		[23799] = 38879, -- Enchant Weapon - Strength  (74)
		[34001] = 38937, -- Enchant Bracer - Major Intellect  (75)
		[27950] = 38909, -- Enchant Boots - Fortitude  (76)
		[74234] = 52767, -- Enchant Cloak - Protection  (77)
		[74226] = 52762, -- Enchant Shield - Mastery  (78)
		[47901] = 39006, -- Enchant Boots - Tuskarr's Vitality  (79)
		[13937] = 38845, -- Enchant 2H Weapon - Greater Impact  (80)
		[13522] = 38795, -- Enchant Cloak - Lesser Shadow Resistance  (81)
		[27967] = 38917, -- Enchant Weapon - Major Striking  (82)
		[44623] = 38989, -- Enchant Chest - Super Stats  (83)
		[74223] = 52760, -- Enchant Weapon - Hurricane  (84)
		[27971] = 38919, -- Enchant 2H Weapon - Savagery  (85)
		[74240] = 52773, -- Enchant Cloak - Greater Intellect  (86)
		[27944] = 38904, -- Enchant Shield - Lesser Dodge  (87)
		[13915] = 38840, -- Enchant Weapon - Demonslaying  (88)
		[20034] = 38873, -- Enchant Weapon - Crusader  (89)
		[13661] = 38817, -- Enchant Bracer - Strength  (90)
		[34007] = 38943, -- Enchant Boots - Cat's Swiftness  (91)
		[44484] = 38951, -- Enchant Gloves - Expertise  (92)
		[74191] = 52744, -- Enchant Chest - Mighty Stats  (93)
		[13836] = 38830, -- Enchant Boots - Stamina  (94)
		[20033] = 38872, -- Enchant Weapon - Unholy Weapon  (95)
		[44631] = 38993, -- Enchant Cloak - Shadow Armor  (96)
		[74242] = 52774, -- Enchant Weapon - Power Torrent  (97)
		[13657] = 38815, -- Enchant Cloak - Fire Resistance  (98)
		[74200] = 52751, -- Enchant Chest - Stamina  (99)
		[13485] = 38792, -- Enchant Shield - Lesser Spirit  (100)
		[21931] = 38876, -- Enchant Weapon - Winter's Might  (101)
		[60692] = 44465, -- Enchant Chest - Powerful Stats  (102)
		[60609] = 44456, -- Enchant Cloak - Speed  (103)
		[44500] = 38959, -- Enchant Cloak - Superior Agility  (104)
		[60621] = 44453, -- Enchant Weapon - Greater Potency  (105)
		[27947] = 38907, -- Enchant Shield - Resistance  (106)
		[20014] = 38858, -- Enchant Cloak - Greater Resistance  (107)
		[13653] = 38813, -- Enchant Weapon - Lesser Beastslayer  (108)
		[74225] = 52761, -- Enchant Weapon - Heartsong  (109)
		[47900] = 39005, -- Enchant Chest - Super Health  (110)
		[59621] = 44493, -- Enchant Weapon - Berserking  (111)
		[44633] = 38995, -- Enchant Weapon - Exceptional Agility  (112)
		[74230] = 52764, -- Enchant Cloak - Critical Strike  (113)
		[7428] = 38768, -- Enchant Bracer - Minor Dodge  (114)
		[27962] = 38915, -- Enchant Cloak - Major Resistance  (115)
		[13868] = 38834, -- Enchant Gloves - Advanced Herbalism  (116)
		[13378] = 38787, -- Enchant Shield - Minor Stamina  (117)
		[7793] = 38781, -- Enchant 2H Weapon - Lesser Intellect  (118)
		[25074] = 38887, -- Enchant Gloves - Frost Power  (119)
		[74235] = 52768, -- Enchant Off-Hand - Superior Intellect  (120)
		[13538] = 38798, -- Enchant Chest - Lesser Absorption  (121)
		[25072] = 38885, -- Enchant Gloves - Threat  (122)
		[44509] = 38962, -- Enchant Chest - Greater Mana Restoration  (123)
		[13612] = 38800, -- Enchant Gloves - Mining  (124)
		[25079] = 38889, -- Enchant Gloves - Healing Power  (125)
		[7776] = 38776, -- Enchant Chest - Lesser Mana  (126)
		[33996] = 72070, -- Enchant Gloves - Assault  (127)
		[74237] = 52770, -- Enchant Bracer - Exceptional Spirit  (128)
		[13626] = 38804, -- Enchant Chest - Minor Stats  (129)
		[7867] = 38786, -- Enchant Boots - Minor Agility  (130)
		[27984] = 38925, -- Enchant Weapon - Mongoose  (131)
		[74197] = 52748, -- Enchant Weapon - Avalanche  (132)
		[44589] = 38976, -- Enchant Boots - Superior Agility  (133)
		[25081] = 38891, -- Enchant Cloak - Greater Fire Resistance  (134)
		[27948] = 38908, -- Enchant Boots - Vitality  (135)
		[13617] = 38801, -- Enchant Gloves - Herbalism  (136)
		[27946] = 38906, -- Enchant Shield - Parry  (137)
		[44582] = 38973, -- Enchant Cloak - Spell Piercing  (138)
		[7863] = 38785, -- Enchant Boots - Minor Stamina  (139)
		[44508] = 38961, -- Enchant Boots - Greater Spirit  (140)
		[13620] = 38802, -- Enchant Gloves - Fishing  (141)
		[74252] = 52781, -- Enchant Boots - Assassin's Step  (142)
		[25082] = 38892, -- Enchant Cloak - Greater Nature Resistance  (143)
		[44591] = 38978, -- Enchant Cloak - Superior Dodge  (144)
		[13648] = 38812, -- Enchant Bracer - Stamina  (145)
		[13644] = 38810, -- Enchant Boots - Lesser Stamina  (146)
		[13607] = 38799, -- Enchant Chest - Mana  (147)
		[27911] = 38900, -- Enchant Bracer - Superior Healing  (148)
		[47051] = 39000, -- Enchant Cloak - Greater Dodge  (149)
		[33991] = 38929, -- Enchant Chest - Restore Mana Prime  (150)
		[42620] = 38947, -- Enchant Weapon - Greater Agility  (151)
		[60668] = 44458, -- Enchant Gloves - Crusher  (152)
		[20015] = 38859, -- Enchant Cloak - Superior Defense  (153)
		[25086] = 38895, -- Enchant Cloak - Dodge  (154)
		[20032] = 38871, -- Enchant Weapon - Lifestealing  (155)
		[13941] = 38847, -- Enchant Chest - Stats  (156)
		[74132] = 52687, -- Enchant Gloves - Mastery  (157)
		[34010] = 38946, -- Enchant Weapon - Major Healing  (158)
		[33995] = 38933, -- Enchant Gloves - Major Strength  (159)
		[13948] = 38851, -- Enchant Gloves - Minor Haste  (160)
		[23804] = 38884, -- Enchant Weapon - Mighty Intellect  (161)
		[44588] = 38975, -- Enchant Chest - Exceptional Resilience  (162)
		[34003] = 38939, -- Enchant Cloak - Spell Penetration  (163)
		[27977] = 38922, -- Enchant 2H Weapon - Major Agility  (164)
		[34002] = 38938, -- Enchant Bracer - Lesser Assault  (165)
		[74232] = 52766, -- Enchant Bracer - Precision  (166)
		[44506] = 38960, -- Enchant Gloves - Gatherer  (167)
		[25083] = 38893, -- Enchant Cloak - Stealth  (168)
		[25080] = 38890, -- Enchant Gloves - Superior Agility  (169)
		[25078] = 38888, -- Enchant Gloves - Fire Power  (170)
		[74248] = 52778, -- Enchant Bracer - Greater Critical Strike  (171)
		[74256] = 52785, -- Enchant Bracer - Greater Speed  (172)
		[13882] = 38835, -- Enchant Cloak - Lesser Agility  (173)
		[7786] = 38779, -- Enchant Weapon - Minor Beastslayer  (174)
		[20016] = 38860, -- Enchant Shield - Vitality  (175)
		[7766] = 38774, -- Enchant Bracer - Minor Spirit  (176)
		[22749] = 38877, -- Enchant Weapon - Spellpower  (177)
		[20008] = 38852, -- Enchant Bracer - Greater Intellect  (178)
		[20028] = 38867, -- Enchant Chest - Major Mana  (179)
		[33990] = 38928, -- Enchant Chest - Major Spirit  (180)
		[27975] = 38921, -- Enchant Weapon - Major Spellpower  (181)
		[20026] = 38866, -- Enchant Chest - Major Health  (182)
		[20025] = 38865, -- Enchant Chest - Greater Stats  (183)
		[20011] = 38855, -- Enchant Bracer - Superior Stamina  (184)
		[20024] = 38864, -- Enchant Boots - Spirit  (185)
		[20020] = 38862, -- Enchant Boots - Greater Stamina  (186)
		[20017] = 38861, -- Enchant Shield - Greater Stamina  (187)
		[20012] = 38856, -- Enchant Gloves - Greater Agility  (188)
		[44595] = 38981, -- Enchant 2H Weapon - Scourgebane  (189)
		[13947] = 38850, -- Enchant Gloves - Riding Skill  (190)
		[44510] = 38963, -- Enchant Weapon - Exceptional Spirit  (191)
		[13939] = 38846, -- Enchant Bracer - Greater Strength  (192)
		[13935] = 38844, -- Enchant Boots - Agility  (193)
		[13933] = 38843, -- Enchant Shield - Frost Resistance  (194)
		[47899] = 39004, -- Enchant Cloak - Wisdom  (195)
		[7418] = 38679, -- Enchant Bracer - Minor Health  (196)
		[13655] = 38814, -- Enchant Weapon - Lesser Elemental Slayer  (197)
		[13931] = 38842, -- Enchant Bracer - Dodge  (198)
		[13890] = 38837, -- Enchant Boots - Minor Speed  (199)
		[74253] = 52782, -- Enchant Boots - Lavawalker  (200)
		[13846] = 38832, -- Enchant Bracer - Greater Spirit  (201)
		[13841] = 38831, -- Enchant Gloves - Advanced Mining  (202)
		[13822] = 38829, -- Enchant Bracer - Intellect  (203)
		[13817] = 38828, -- Enchant Shield - Stamina  (204)
		[13815] = 38827, -- Enchant Gloves - Agility  (205)
		[74195] = 52747, -- Enchant Weapon - Mending  (206)
		[7779] = 38777, -- Enchant Bracer - Minor Agility  (207)
		[96264] = 68784, -- Enchant Bracer - Agility  (208)
		[25073] = 38886, -- Enchant Gloves - Shadow Power  (209)
		[27960] = 38913, -- Enchant Chest - Exceptional Stats  (210)
		[13464] = 38791, -- Enchant Shield - Lesser Protection  (211)
		[74231] = 52765, -- Enchant Chest - Exceptional Spirit  (212)
		[7788] = 38780, -- Enchant Weapon - Minor Striking  (213)
		[13689] = 38820, -- Enchant Shield - Lesser Parry  (214)
		[44576] = 38972, -- Enchant Weapon - Lifeward  (215)
		[13637] = 38807, -- Enchant Boots - Lesser Agility  (216)
		[13687] = 38819, -- Enchant Boots - Lesser Spirit  (217)
		[13663] = 38818, -- Enchant Chest - Greater Mana  (218)
		[44383] = 38949, -- Enchant Shield - Resilience  (219)
		[74213] = 52757, -- Enchant Boots - Major Agility  (220)
		[13659] = 38816, -- Enchant Shield - Spirit  (221)
		[63746] = 45628, -- Enchant Boots - Lesser Accuracy  (222)
		[13695] = 38822, -- Enchant 2H Weapon - Impact  (223)
		[27958] = 38912, -- Enchant Chest - Exceptional Mana  (224)
		[13943] = 38848, -- Enchant Weapon - Greater Striking  (225)
		[59625] = 43987, -- Enchant Weapon - Black Magic  (226)
		[13646] = 38811, -- Enchant Bracer - Lesser Dodge  (227)
		[13640] = 38808, -- Enchant Chest - Greater Health  (228)
		[13635] = 38806, -- Enchant Cloak - Defense  (229)
		[44529] = 38967, -- Enchant Gloves - Major Agility  (230)
		[13700] = 38824, -- Enchant Chest - Lesser Stats  (231)
		[44616] = 38987, -- Enchant Bracer - Greater Stats  (232)
		[60691] = 44463, -- Enchant 2H Weapon - Massacre  (233)
		[44524] = 38965, -- Enchant Weapon - Icebreaker  (234)
		[60707] = 44466, -- Enchant Weapon - Superior Potency  (235)
		[13631] = 38805, -- Enchant Shield - Lesser Stamina  (236)
		[7420] = 38766, -- Enchant Chest - Minor Health  (237)
		[23800] = 38880, -- Enchant Weapon - Agility  (238)
		[20036] = 38875, -- Enchant 2H Weapon - Major Intellect  (239)
		[13622] = 38803, -- Enchant Bracer - Lesser Intellect  (240)
		[28003] = 38926, -- Enchant Weapon - Spellsurge  (241)
		[74236] = 52769, -- Enchant Boots - Precision  (242)
		[44488] = 38953, -- Enchant Gloves - Precision  (243)
		[74229] = 52763, -- Enchant Bracer - Superior Dodge  (244)
		[13536] = 38797, -- Enchant Bracer - Lesser Strength  (245)
		[60767] = 44470, -- Enchant Bracer - Superior Spellpower  (246)
		[60663] = 44457, -- Enchant Cloak - Major Agility  (247)
		[44592] = 38979, -- Enchant Gloves - Exceptional Spellpower  (248)
		[44629] = 38991, -- Enchant Weapon - Exceptional Spellpower  (249)
		[13529] = 38796, -- Enchant 2H Weapon - Lesser Impact  (250)
		[13945] = 38849, -- Enchant Bracer - Greater Stamina  (251)
		[13380] = 38788, -- Enchant 2H Weapon - Lesser Spirit  (252)
		[74201] = 52752, -- Enchant Bracer - Critical Strike  (253)
		[13421] = 38790, -- Enchant Cloak - Lesser Protection  (254)
		[62948] = 45056, -- Enchant Staff - Greater Spellpower  (255)
		[60653] = 44455, -- Enchant Shield - Greater Intellect  (256)
		[74198] = 52749, -- Enchant Gloves - Haste  (257)
		[13794] = 38826, -- Enchant Cloak - Resistance  (258)
		[34004] = 38940, -- Enchant Cloak - Greater Agility  (259)
		[7861] = 38784, -- Enchant Cloak - Lesser Fire Resistance  (260)
		[27914] = 38902, -- Enchant Bracer - Fortitude  (261)
		[13698] = 38823, -- Enchant Gloves - Skinning  (262)
		[44590] = 38977, -- Enchant Cloak - Superior Shadow Resistance  (263)
		[44593] = 38980, -- Enchant Bracer - Major Spirit  (264)
		[74246] = 52776, -- Enchant Weapon - Landslide  (265)
		[7457] = 38771, -- Enchant Bracer - Minor Stamina  (266)
		[7771] = 38775, -- Enchant Cloak - Minor Protection  (267)
		[13419] = 38789, -- Enchant Cloak - Minor Agility  (268)
		[74244] = 52775, -- Enchant Weapon - Windwalk  (269)
		[34008] = 38944, -- Enchant Boots - Boar's Speed  (270)
		[44494] = 38956, -- Enchant Cloak - Superior Nature Resistance  (271)
		[59619] = 44497, -- Enchant Weapon - Accuracy  (272)
		[23801] = 38881, -- Enchant Bracer - Mana Regeneration  (273)
		[7748] = 38773, -- Enchant Chest - Lesser Health  (274)
		[7454] = 38770, -- Enchant Cloak - Minor Resistance  (275)
		[7426] = 38767, -- Enchant Chest - Minor Absorption  (276)
		[44492] = 38955, -- Enchant Chest - Mighty Health  (277)
		[74251] = 52780, -- Enchant Chest - Greater Stamina  (278)
		[44584] = 38974, -- Enchant Boots - Greater Vitality  (279)
		[47672] = 39001, -- Enchant Cloak - Mighty Armor  (280)
		[74214] = 52758, -- Enchant Chest - Mighty Resilience  (281)
		[27968] = 38918, -- Enchant Weapon - Major Intellect  (282)
		[28004] = 38927, -- Enchant Weapon - Battlemaster  (283)
		[20030] = 38869, -- Enchant 2H Weapon - Superior Impact  (284)
		[13503] = 38794, -- Enchant Weapon - Lesser Striking  (285)
		[74207] = 52754, -- Enchant Shield - Protection  (286)
		[74193] = 52746, -- Enchant Bracer - Speed  (287)
		[33999] = 38936, -- Enchant Gloves - Major Healing  (288)
		[33993] = 38931, -- Enchant Gloves - Blasting  (289)
		[64441] = 46026, -- Enchant Weapon - Blade Ward  (290)
		[27945] = 38905, -- Enchant Shield - Intellect  (291)
		[27982] = 38924, -- Enchant Weapon - Soulfrost  (292)
		[27917] = 38903, -- Enchant Bracer - Spellpower  (293)
		[62959] = 45060, -- Enchant Staff - Spellpower  (294)
		[44630] = 38992, -- Enchant 2H Weapon - Greater Savagery  (295)
		[74189] = 52743, -- Enchant Boots - Earthen Vitality  (296)
		[60763] = 44469, -- Enchant Boots - Greater Assault  (297)
		[22750] = 38878, -- Enchant Weapon - Healing Power  (298)
		[74211] = 52755, -- Enchant Weapon - Elemental Slayer  (299)
		[74199] = 52750, -- Enchant Boots - Haste  (300)
		[44489] = 38954, -- Enchant Shield - Dodge  (301)
		[95471] = 68134, -- Enchant 2H Weapon - Mighty Agility  (302)
		[74238] = 52771, -- Enchant Boots - Mastery  (303)
		[27957] = 38911, -- Enchant Chest - Exceptional Health  (304)
		[74250] = 52779, -- Enchant Chest - Peerless Stats  (305)
		[104408] = 74716, -- Enchant Boots - Greater Precision (306)
		[104385] = 74701, -- Enchant Bracer - Major Dodge (307)
		[104393] = 74707, -- Enchant Chest - Mighty Spirit (308)
		[104392] = 74706, -- Enchant Chest - Super Resilience (309)
		[104403] = 74712, -- Enchant Cloak - Superior Intellect (310)
		[104416] = 74719, -- Enchant Gloves - Greater Haste (311)
		[104430] = 74725, -- Enchant Weapon - Elemental Force (312)
		[104409] = 74717, -- Enchant Boots - Blurred Speed (313)
		[104407] = 74715, -- Enchant Boots - Greater Haste (314)
		[104397] = 74709, -- Enchant Chest - Superior Stamina (315)
		[104398] = 74710, -- Enchant Cloak - Accuracy (316)
		[104417] = 74720, -- Enchant Gloves - Superior Expertise (317)
		[104425] = 74723, -- Enchant Weapon - Windsong (318)
		[104414] = 74718, -- Enchant Boots - Pandaren's Step (319)
		[104395] = 74708, -- Enchant Chest - Glorious Stats (320)
		[104401] = 74711, -- Enchant Cloak - Greater Protection (321)
		[104419] = 74721, -- Enchant Gloves - Super Strength (322)
		[104420] = 74722, -- Enchant Gloves - Superior Mastery (323)
		[104445] = 74729, -- Enchant Off-Hand - Major Intellect (324)
		[130758] = 89737, -- Enchant Shield - Greater Parry (325)
		[104440] = 74727, -- Enchant Weapon - Colossus (326)
		[104390] = 74704, -- Enchant Bracer - Exceptional Strength (327)
		[104391] = 74705, -- Enchant Bracer - Greater Agility (328)
		[104389] = 74703, -- Enchant Bracer - Super Intellect (329)
		[104434] = 74726, -- Enchant Weapon - Dancing Steel (330)
		[104427] = 74724, -- Enchant Weapon - Jade Spirit (331)
		[104442] = 74728, -- Enchant Weapon - River's Song (332)
	}
	local recipeLevels = {
		[0] = {20008,20016,20024,20032,13617,13637,13657,13661,13689,13693,23801,13817,25079,13841,20009,20025,13378,13905,13917,13937,13941,13945,23802,64579,7779,13522,7793,13538,25072,25080,20026,20034,13622,13626,13642,13646,7857,7859,7861,7863,7867,22749,13698,23803,44636,7418,7420,7426,7428,13822,25073,25081,13846,20011,20035,13882,93841,13890,13419,22750,23804,27924,13503,25074,25082,20012,13607,20036,13631,13635,13655,13659,13663,27837,13687,13695,64441,13815,25083,20013,20029,13887,13380,13915,59636,13931,13935,13939,13943,13947,13464,7766,7776,7782,13536,25084,20014,20030,13612,13620,13644,13648,17180,13700,23799,7745,44506,63746,7411,21931,13794,13746,13836,7443,20015,20023,71692,13868,7457,7454,13858,20010,7748,20017,74216,13421,13933,13898,13948,20033,23800,13653,13485,17181,74217,13501,7771,20031,7786,7788,13529,74218,44645,74215,20020,20028,13640,25078,},
		[60] = {60616,44488,62948,44584,44616,44489,44633,60714,60763,42974,44555,44635,44492,44508,44524,44556,47766,60621,60653,44509,44621,60606,44494,44510,47672,60623,60767,44575,44623,44528,44576,60609,59619,47898,44513,44529,44625,47899,27958,59621,47900,60707,62256,44590,60692,44595,60691,44630,62959,44588,44484,44500,44631,44591,44483,44596,44582,44593,47901,44589,44629,46578,44598,60668,59625,60663,44592,},
		[35] = {33996,27905,27913,27977,42620,33997,27906,27914,27946,27954,33999,34001,34002,27948,27972,28004,34003,44383,34004,47051,27957,27981,34005,33990,34006,27926,27950,27982,33991,34007,33992,27971,27911,27927,27951,27967,27975,27962,27961,33993,34009,27945,27899,33994,34010,27947,28003,27920,46594,27960,27968,27984,33995,27944,27917,34008,25086,},
		[300] = {74220,74252,74189,74253,74254,74191,74255,74192,74256,74193,96262,74226,74195,96264,74197,74229,74198,74199,74231,74200,74232,74201,74202,74234,74236,74237,74238,74207,74240,74242,74211,74223,95471,74212,74247,74213,74230,74214,74246,74251,74225,74235,96261,74248,74132,74244,74250,74239,},
		[372] = {104393,104392,104395,104397,104409,104407,104408,104414,104390,104391,104389,104385,104417,104416,104419,104420,104425,104440,104434,104427,104442,104430,104403,104398,104401,104445,},
		[417] = {130758,},
	}
	local recipeSlots = {
		[5] = {7420,7443,7426,7748,7776,7857,13538,13607,13626,13640,13663,13700,13858,13917,13941,20026,20028,20025,27958,44623,44492,47766,44588,44509,47900,60692,33991,27957,33990,27960,33992,46594,74191,74200,74214,74231,74251,74250,104393,104392,104395,104397},
		[8] = {7863,13637,13644,13687,13836,63746,13890,13935,20020,20024,20023,7867,60606,44528,60623,44584,44508,44589,60763,47901,27948,27950,27951,34008,34007,27954,74189,74199,74213,74236,74238,74252,74253,104409,104407,104408,104414},
		[9] = {7418,7428,7457,7766,7779,7782,7859,13501,13536,13622,13642,13646,13648,13661,13822,13846,13931,13939,13945,20008,20009,23801,20010,23802,20011,60616,44555,44635,44616,44593,44598,44575,60767,62256,34002,27899,34001,27905,27906,27911,27913,27914,27917,74193,74201,74229,74232,74237,74239,96264,96261,96262,74248,74256,104390,104391,104389,104385},
		[10] = {13620,13617,13612,13698,13815,13841,13868,13887,13948,13947,20012,20013,25078,25074,25079,25073,25080,25072,44506,71692,44592,44484,44488,44529,44513,60668,44625,33993,33996,33995,33999,33997,33994,74132,74198,74212,74220,74255,74254,104417,104416,104419,104420},
		[11] = {27924,44645,44636,59636,74216,74218,74217,74215,27920,27926,27927},
		[13] = {7786,7788,13503,13653,13655,21931,13693,13915,13943,13898,20029,23800,23799,20033,20034,22750,20032,23804,23803,22749,20031,64441,64579,46578,42974,60621,44629,44510,44633,44524,44576,44621,60714,60707,59619,59621,59625,27968,27967,42620,34010,27975,27972,28004,28003,27981,27984,27982,74197,74195,74211,74223,74225,74246,74242,74244,104425,104440,104434,104427,104442,104430},
		[14] = {13378,13464,13485,13631,13659,13689,13817,13905,13933,20017,20016,60653,44489,27944,27945,34009,44383,27946,27947,74207,74226,74235,130758,104445},
		[16] = {7454,7771,13419,13421,7861,13522,13635,13657,13746,13794,13882,20014,20015,25081,25082,25083,25084,60609,44582,44500,44596,44556,44483,44494,44590,60663,47898,47672,44591,44631,47899,25086,34004,27961,34003,27962,34005,34006,47051,74192,74202,74230,74234,74240,74247},
		[17] = {7786,7788,7793,7745,13380,13503,13529,13653,13655,21931,13693,13695,13915,13937,13943,13898,20029,27837,23800,23799,20030,20033,20036,20035,20034,22750,20032,23804,23803,22749,20031,64441,64579,46578,42974,60621,62959,44629,44510,44630,44633,44524,44576,60691,44595,44621,60714,60707,59619,59621,59625,62948,27968,27967,42620,27971,34010,27975,27972,27977,28004,28003,27981,27984,27982,74197,74195,95471,74211,74223,74225,74246,74242,74244,104425,104440,104434,104427,104442,104430},
		[20] = {7411,7418,7428,7420,7443,7426,7454,7412,7457,7766,7748,7779,7782,7776,7771,7786,7788,7793,7745,13378,13380,13419,13421,13464,7859,7857,7413,7863,7861,13501,13485,13522,13536,13538,13503,13529,13607,13620,13617,13612,13622,13626,13635,13631,13637,13640,13642,13644,13646,13648,13657,13653,13655,13661,13659,13663,13687,21931,13689,13693,13695,13700,13698,13746,13794,13822,13815,13817,13836,13841,13846,13858,63746,13890,13882,13868,13887,13917,13905,13915,13935,13931,13933,13937,13939,13945,13941,13943,17181,17180,13948,13947,20008,20020,20014,20017,13898,20009,20012,20024,20026,20016,20015,20029,27837,23801,20028,23800,23799,20030,20023,20010,20013,20033,20036,20035,23802,20011,20025,25081,25082,25083,25084,25078,25074,25079,25073,25080,25072,20034,22750,20032,23804,23803,22749,20031,27924,44506,71692,44645,44636,59636,7867,64441,64579,74216,74218,74217,74215,93841,27958,51313,46578,60609,60616,44592,44623,42974,44555,60606,60621,44528,60623,62959,44582,44635,44492,60653,44629,44500,44616,47766,44596,44556,44483,44494,44590,44510,44593,44584,44484,44630,44508,44488,44589,44588,44529,44513,44633,44598,44509,60663,44489,74258,47900,60668,44524,44576,60691,44595,44575,47898,47672,44621,44591,44625,60714,60707,60763,47901,60767,60692,44631,47899,59619,59621,59625,62948,62256,13920,28029,34002,33991,25086,27948,27899,34001,33993,34004,27961,33996,27944,27905,27957,27950,27906,33990,27911,34003,27945,34009,27962,44383,27913,27951,33995,27946,27968,27967,27960,33992,42620,27971,27914,34005,34006,33999,34010,27975,27972,27977,34008,34007,33997,33994,27920,27947,28004,28003,27917,46594,27954,27926,27981,47051,27927,27984,27982,74189,74191,74132,74193,74192,74197,74195,74199,74198,74201,74200,74202,74207,95471,74212,74211,74213,74214,74220,74223,74226,74225,74229,74230,74232,74231,74234,74235,74236,74237,74238,74239,74240,96264,96261,96262,74252,74253,74248,74256,74251,74250,74247,74255,74254,74246,74242,74244,104393,104392,104395,104397,104409,104407,104408,104414,104390,104391,104389,104385,104417,104416,104419,104420,104425,104440,104434,104427,104442,104430,130758,104403,104398,104401,104445},
		[21] = {7786,7788,13503,13653,13655,21931,13693,13915,13943,13898,20029,23800,23799,20033,20034,22750,20032,23804,23803,22749,20031,64441,64579,46578,42974,60621,44629,44510,44633,44524,44576,44621,60714,60707,59619,59621,59625,27968,27967,42620,34010,27975,27972,28004,28003,27981,27984,27982,74197,74195,74211,74223,74225,74246,74242,74244,104425,104440,104434,104427,104442,104430},
		[22] = {7786,7788,13503,13653,13655,21931,13693,13915,13943,13898,20029,23800,23799,20033,20034,22750,20032,23804,23803,22749,20031,64441,64579,46578,42974,60621,44629,44510,44633,44524,44576,44621,60714,60707,59619,59621,59625,27968,27967,42620,34010,27975,27972,28004,28003,27981,27984,27982,74197,74195,74211,74223,74225,74246,74242,74244,104425,104440,104434,104427,104442,104430},
		[23] = {74235,104445},
	}

	local slotNames = {
		[5] = INVTYPE_CHEST,
		[8] = INVTYPE_FEET,
		[9] = INVTYPE_WRIST,
		[10] = INVTYPE_HAND,
		[11] = INVTYPE_FINGER,
		[13] = INVTYPE_WEAPONMAINHAND,
		[14] = INVTYPE_SHIELD,
		[16] = INVTYPE_CLOAK,
		[17] = INVTYPE_2HWEAPON,
		[21] = INVTYPE_WEAPONMAINHAND,
		[22] = INVTYPE_WEAPONOFFHAND,
		[23] = INVTYPE_HOLDABLE,
	}


	local levelNames = {
		[0] = "No Level Restriction",
		[35] = "Requires Level 35+ Item",
		[60] = "Requires Level 60+ Item",
		[300] = "Requires Level 300+ Item",
		[372] = "Requires Level 372+ Item",
		[417] = "Requires Level 417+ Item",
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

		if recipeID then
			local enchantID = ScrollMakingEnchantID(recipeID)
			local scrollID = scrollIDs[enchantID]

			if scrollID then
				local _,link = GetItemInfo(scrollID)

				return link
			end
		end
	end

	api.GetTradeSkillRecipeLink = function(index)
		local recipeID = skillList[index]

		if recipeID then
			local enchantID = ScrollMakingEnchantID(recipeID)
			local scrollID = scrollIDs[enchantID]
			return "|cff80a0ff|Henchant:"..(recipeID or "nil").."|h["..(GetItemInfo(scrollID) or "nil").."]|h|r"
		end
	end


	api.GetTradeSkillLine = function()
		local rank, maxRank = GnomeWorks:GetTradeSkillRank(GnomeWorks.player, 7411)
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

		if not knownSpells then return end

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


		local slotGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Slot")

		slotGroup.locked = true
		slotGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(slotGroup)


		local levelGroup = GnomeWorks:RecipeGroupNew(player,tradeID,"By Level")

		levelGroup.locked = true
		levelGroup.autoGroup = true

		GnomeWorks:RecipeGroupClearEntries(levelGroup)



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
			end
		end


		GnomeWorks:CraftabilityPurge()
		GnomeWorks:InventoryScan()

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

			for i=1,3 do
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




