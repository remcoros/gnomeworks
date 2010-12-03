



local VERSION = ("@project-revision@")


local LARGE_NUMBER = 1000000



do
	-- filter the text of the skill button
	-- only set up for english clients at the moment


	local GLYPH_MATCH_STRING	= "(%w+) Glyph"
	local GLYPH_REPLACEMENT_STRING	= "Glyph of"
	local GLYPH_TOKEN_MAJOR		= "Major"
	local GLYPH_TOKEN_MINOR		= "Minor"
	local GLYPH_TOKEN_PRIME		= "Prime"

	local ENCHANTING_REPLACEMENT_STRING = "Enchant "


	glyphTypes = {}

	local glyphTypeColor = {
		[GLYPH_TOKEN_MAJOR] = "|cffff40a0",
		[GLYPH_TOKEN_MINOR] = "|cffa040f0",
		[GLYPH_TOKEN_PRIME] = "|cff80a0ff",
	}

	local tooltipScanner = _G["GWParsingTooltip"] or CreateFrame("GameTooltip", "GWParsingTooltip", getglobal("ANCHOR_NONE"), "GameTooltipTemplate")


	local function GlyphType(itemID)
		if not glyphTypes then
			glyphTypes = {}
		end


		if not glyphTypes[itemID] then
			local tooltip = tooltipScanner

			tooltip:SetHyperlink("item:"..itemID)

			local tiplines = tooltip:NumLines()

			for i=2, tiplines, 1 do
				local lineText = getglobal("GWParsingTooltipTextLeft"..i):GetText() or " "


				local g = string.match(lineText, GLYPH_MATCH_STRING)

				if g then
					glyphTypes[itemID] = g
					break
				end
			end
		end

		return glyphTypes[itemID]
	end


	function GnomeWorks:FilterRecipeName(text, itemID, recipeID)
		if not text then
		--	LSW:ChatMessage(button:GetName())
			return
		end

		if itemID and string.match(text, GLYPH_REPLACEMENT_STRING) then
			local glyphType = GlyphType(itemID)

			if glyphType then
				local newText = string.gsub(text, GLYPH_REPLACEMENT_STRING, (glyphTypeColor[glyphType] or "")..glyphType..":|r")

				return newText
			end
		end

		if recipeID and string.match(text, ENCHANTING_REPLACEMENT_STRING) then
			local newText = string.gsub(text, ENCHANTING_REPLACEMENT_STRING, "")
			return newText
		end

		return text
	end
end


do
	local frame
	local sf

	local clientVersion, clientBuild = GetBuildInfo()

	local insetBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 10, right = 10, top = 10, bottom = 10 }
			}


	local skillFrame

	local colorWhite = { ["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0 }
	local colorBlack = { ["r"] = 0.0, ["g"] = 1.0, ["b"] = 0.0, ["a"] = 0.0 }
	local colorDark = { ["r"] = 1.1, ["g"] = 0.1, ["b"] = 0.1, ["a"] = 0.0 }

	local highlightOff = { ["r"] = 0.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 0.0 }
	local highlightSelected = { ["r"] = 0.5, ["g"] = 0.5, ["b"] = 0.5, ["a"] = 0.5 }
	local highlightSelectedMouseOver = { ["r"] = 1, ["g"] = 1, ["b"] = 0.5, ["a"] = 0.5 }


	local colorFilteringEnabled = { 1,1,.0, .25 }


	local tooltipScanner = _G["GWParsingTooltip"] or CreateFrame("GameTooltip", "GWParsingTooltip", getglobal("ANCHOR_NONE"), "GameTooltipTemplate")

	tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")


	local tooltipRecipeCache = {}
	local tooltipRecipeCacheLeft =  {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}		-- 20 lines
	local tooltipRecipeCacheRight = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}		-- 20 lines


	local containerIndex = { "bag", "bank" }

--[[
	local inventoryIndex = { "bag", "vendor", "bank", "mail", "guildBank", "alt" }

	local inventoryColorBlindTag = {
		bag = "",
		vendor = "v",
		bank = "b",
		mail = "m",
		guildBank = "g",
		alt = "a",
	}

	local inventoryColors = {
		bag = "|cffffff80",
		vendor = "|cff80ff80",
		bank =  "|cffffa050",
		guildBank = "|cff5080ff",
		mail = "|cff60fff0",
		alt = "|cffff80ff",
	}


	local inventoryFormat = {}
	local inventoryTags = {}

	for k,v in pairs(inventoryColors) do
		inventoryTags[k] = v..k
	end
]]

	local inventoryIndex = GnomeWorks.system.inventoryIndex
	local inventoryColors = GnomeWorks.system.inventoryColors
	local inventoryFormat = GnomeWorks.system.inventoryFormat
	local inventoryTags = GnomeWorks.system.inventoryTags



	local selectedRows = {}

	local detailsOpen



	local playerSelectMenu
	local pluginMenu


	local columnHeaders


	local itemQualityColor = {}

	for i=0,7 do
		local r,g,b = GetItemQualityColor(i)
		itemQualityColor[i] = { r=r, g=g, b=b }
--		itemQualityColor[i].r, itemQualityColor[i].g, itemQualityColor[i].b = GetItemQualityColor(i)
	end


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
	}



	local filterMenuFrame = GnomeWorksMenuFrame or CreateFrame("Frame", "GnomeWorksMenuFrame", UIParent, "UIDropDownMenuTemplate")


	local activeFilterList = {}



	local function filterText(entry, textFilter)
		if textFilter and textFilter ~= "" then

			if entry.recipeID then
				local recipeID = entry.recipeID

				if recipeID > 0 then
					if not tooltipRecipeCache[recipeID] then
						local tipLines = tooltipScanner:NumLines()

						tooltipRecipeCache[recipeID] = tipLines

						tooltipScanner:SetOwner(frame, "ANCHOR_NONE")
						tooltipScanner:SetHyperlink("spell:"..entry.recipeID)

						for i=#tooltipRecipeCacheLeft,tipLines do
							tooltipRecipeCacheLeft[i] = {}
							tooltipRecipeCacheRight[i] = {}
						end

						for i=1, tipLines do
							if _G["GWParsingTooltipTextLeft"..i]:GetText() then
								tooltipRecipeCacheLeft[i][recipeID] = string.lower(_G["GWParsingTooltipTextLeft"..i]:GetText())
							end

							if _G["GWParsingTooltipTextRight"..i]:GetText() then
								tooltipRecipeCacheRight[i][recipeID] = string.lower(_G["GWParsingTooltipTextRight"..i]:GetText())
							end
						end
					end

					local tipLines = tooltipRecipeCache[recipeID]

					for w in string.gmatch(textFilter, "%S+") do
						local found

						for i=1, tipLines do
							if tooltipRecipeCacheLeft[i][recipeID] and string.find(tooltipRecipeCacheLeft[i][recipeID], w, 1, true) then
								found = true
								break
							end

							if tooltipRecipeCacheRight[i][recipeID] and string.find(tooltipRecipeCacheRight[i][recipeID], w, 1, true) then
								found = true
								break
							end
						end

						if not found then
							return true
						end
					end
				else
					for w in string.gmatch(textFilter, "%S+") do
						local found
						local recipeName = string.lower(GnomeWorks:GetRecipeName(recipeID))

						if string.find(recipeName, w) then
							found = true
						else
							local results, reagents = GnomeWorks:GetRecipeData(recipeID)

							for id in pairs(results) do
								if string.find(string.lower(GetItemInfo(id)),w) then
									found = true
									break
								end
							end

							if not found and reagents then
								for id in pairs(reagents) do
									if id and string.find(string.lower(GetItemInfo(id)),w) then
										found = true
										break
									end
								end
							end
						end

						if not found then
							return true
						end
					end
				end
			end
		end

		return false
	end


	local searchTextParameters = {
		name = "SearchText",
		enabled = false,
		func = filterText,
		arg = "",
	}

	activeFilterList["SearchText"] = searchTextParameters



	function GnomeWorks:CreateFilterMenu(filterParameters, menu, column)
		local function filterSet(button, setting)
			filterParameters[setting].enabled = not filterParameters[setting].enabled

			if filterParameters[setting].OnClick then
				filterParameters[setting].OnClick(filterParameters,setting)
			end


			if filterParameters[setting].enabled then
				activeFilterList[filterParameters[setting].name] = filterParameters[setting]
			else
				activeFilterList[filterParameters[setting].name] = nil
			end


			local filtersEnabled = false

			for filterName,filter in pairs(filterParameters) do
				if filter.enabled then
					filtersEnabled = true
					break
				end
			end

			if filtersEnabled then
				column.headerBgColor = colorFilteringEnabled
			else
				column.headerBgColor = nil
			end

			sf:Refresh()
		end


		menu.parameters = filterParameters

		for filterName,filter in pairs(filterParameters) do
			local menuEntry = {
				text = filter.text,
				icon = filter.icon,
				tooltipText = filter.tooltip,
				func = filterSet,
				arg1 = filterName,
				notCheckable = filter.notCheckable,
				menuList = filter.menuList,
				hasArrow = filter.menuList ~= nil,
			}

			if filter.checked then
				menuEntry.checked = filter.checked
			else
				menuEntry.checked = function()
					return filterParameters[filterName].enabled
				end
			end

			if filter.coords then
				menuEntry.tCoordLeft,menuEntry.tCoordRight,menuEntry.tCoordBottom,menuEntry.tCoordTop = unpack(filter.coords)
			end


			table.insert(menu, menuEntry)
		end
	end

	local function radioButton(parameters, index)
		for k,v in pairs(parameters) do
			if k ~= index then
				v.enabled = false
			end
		end

		CloseDropDownMenus()
	end



	local craftSourceMenu = {
	}

	local craftFilterMenu

	craftFilterMenu = {
		{
			text = "Filter by Craftability: "..inventoryColors.alt.."alts",
			menuList = craftSourceMenu,
			hasArrow = true,
			filterIndex = #inventoryIndex,
			func = function()
				local parameters = craftSourceMenu.parameters
				local index = craftFilterMenu[1].filterIndex

				craftSourceMenu[index].func(nil, craftSourceMenu[index].arg1)
				craftFilterMenu[1].checked = parameters[index].enabled
			end,
			checked = false,
		},
	}


	local function adjustCraftFilterSource(parameters, index)
		radioButton(parameters, index)

		craftFilterMenu[1].checked = parameters[index].enabled
		craftFilterMenu[1].filterIndex = index
		craftFilterMenu[1].text = "Filter by Craftability: "..parameters[index].text
	end


	local craftFilterParameters = {}

	for i,key in pairs(inventoryIndex) do
		craftFilterParameters[i] = {
			name = "Craftability"..key,
			text = inventoryTags[key],
			enabled = false,
			func = function(entry)
				if entry and entry[key] and entry[key] > 0 then
					return false
				end

				return true
			end,
			notCheckable = true,
			checked = false,
			OnClick = adjustCraftFilterSource,
		}
	end




	local inventorySourceMenu = {
	}

	local inventoryFilterMenu

	inventoryFilterMenu = {
		{
			text = "Filter by Inventory: "..inventoryColors.alt.."alts",
			menuList = inventorySourceMenu,
			hasArrow = true,
			filterIndex = #inventoryIndex,
			func = function()
				local parameters = inventorySourceMenu.parameters
				local index = inventoryFilterMenu[1].filterIndex

				inventorySourceMenu[index].func(nil, inventorySourceMenu[index].arg1)
				inventoryFilterMenu[1].checked = parameters[index].enabled
			end,
			checked = false,
		},
	}


	local function adjustInventoryFilterSource(parameters, index)
		radioButton(parameters, index)

		inventoryFilterMenu[1].checked = parameters[index].enabled
		inventoryFilterMenu[1].filterIndex = index
		inventoryFilterMenu[1].text = "Filter by Inventory: "..parameters[index].text
	end


	local inventoryFilterParameters = {}

	for i,key in pairs(inventoryIndex) do
		inventoryFilterParameters[i] = {
			name = "Inventory"..key,
			text = inventoryTags[key],
			enabled = false,
			func = function(entry)
				if entry and entry[key] and entry[key] > 0 then
					return false
				end

				return true
			end,
			notCheckable = true,
			checked = false,
			OnClick = adjustInventoryFilterSource,
		}
	end



	local levelFilterMenu = {
	}

	local levelFilterParameters = {
		{
			name = "playerUsable",
			text = "Player Meets Level Requirement",
			enabled = false,
			func = function(entry)
				if entry and UnitLevel("player") >= (entry.itemLevel or 0) then
					return false
				else
					return true
				end
			end,
		},
	}




	local recipeLevelMenu = {
	}

	local recipeFilterMenu

	recipeFilterMenu = {
		{
			text = "Filter by Difficulty",
			menuList = recipeLevelMenu,
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			tCoordLeft=0, tCoordRight=1, tCoordBottom=.5, tCoordTop=.75,
			hasArrow = true,
			filterIndex = 3,
			func = function()
				local parameters = recipeLevelMenu.parameters
				local index = recipeFilterMenu[1].filterIndex

				recipeLevelMenu[index].func(nil, recipeLevelMenu[index].arg1)

				recipeFilterMenu[1].checked = parameters[index].enabled
			end,
			checked = false,
		},
	}

	local function adjustFilterIcon(parameters, index)
		radioButton(parameters, index)

		recipeFilterMenu[1].checked = parameters[index].enabled
		recipeFilterMenu[1].tCoordBottom = index/4-.25
		recipeFilterMenu[1].tCoordTop = index/4
		recipeFilterMenu[1].filterIndex = index

	end

	local recipeLevelParameters = {
		{
			name = "DifficultyOptimal",
			text = "",
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			coords = {0,1,0,.25},
			enabled = false,
			func = function(entry)
				local difficulty = GnomeWorks:GetSkillDifficultyLevel(entry.index)
				if difficulty > 3 then
					return false
				else
					return true
				end
			end,
			notCheckable = true,
			checked = false,
			OnClick = adjustFilterIcon,
		},
		{
			name = "DifficultyMedium",
			text = "",
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			coords = {0,1,.25,.5},
			func = function(entry)
				local difficulty = GnomeWorks:GetSkillDifficultyLevel(entry.index)
				if difficulty > 2 then
					return false
				else
					return true
				end
			end,
			notCheckable = true,
			checked = false,
			OnClick = adjustFilterIcon,
		},
		{
			name = "DifficultyEasy",
			text = "",
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			coords = {0,1,.5,.75},
			enabled = false,
			func = function(entry)
				local difficulty = GnomeWorks:GetSkillDifficultyLevel(entry.index)
				if difficulty > 1 then
					return false
				else
					return true
				end
			end,
			notCheckable = true,
			checked = false,
			OnClick = adjustFilterIcon,
		},
	}



	local function columnControl(cellFrame,button,source)
		local scrollFrame = cellFrame:GetParent():GetParent()

		if button == "RightButton" then
			if cellFrame.header.filterMenu then
				local x, y = GetCursorPosition()
				local uiScale = UIParent:GetEffectiveScale()

				EasyMenu(cellFrame.header.filterMenu, filterMenuFrame, UIParent, x/uiScale,y/uiScale, "MENU", 5)
			end
		else
			scrollFrame.sortInvert = (scrollFrame.SortCompare == cellFrame.header.sortCompare) and not scrollFrame.sortInvert

			scrollFrame:HighlightColumn(cellFrame.header.name, scrollFrame.sortInvert)
			scrollFrame.SortCompare = cellFrame.header.sortCompare
			scrollFrame:Refresh()
		end
	end




	columnHeaders = {
		{
			name = "Level",
			align = "CENTER",
			width = 36,
			font = "GameFontHighlightSmall",
			sortCompare = function(a,b)
				return (a.itemLevel or 0) - (b.itemLevel or 0)
			end,
			enabled = function()
				return GnomeWorks.tradeID ~= 53428
			end,
			filterMenu = levelFilterMenu,
			draw = function (rowFrame,cellFrame,entry)
							if entry.subGroup then
								cellFrame.text:SetText("")
								return
							end

							local cr,cg,cb = 1,1,1

							if entry.subGroup then
								cr,cg,cb = 1,.82,0
							else
								if entry.itemColor then
									cr,cg,cb = entry.itemColor.r, entry.itemColor.g, entry.itemColor.b
								end
							end

							cellFrame.text:SetFormattedText("%s",entry.itemLevel or "")
							cellFrame.text:SetTextColor(cr,cg,cb)
						end,
			OnClick = function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex == 0 then
								columnControl(cellFrame, button, source)
							end
						end,
			OnEnter =	function (cellFrame)
								if cellFrame:GetParent().rowIndex == 0 then
									GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
									GameTooltip:ClearLines()
									GameTooltip:AddLine("Required Skill Level",1,1,1,true)

									GameTooltip:AddLine("Left-click to Sort")
									GameTooltip:AddLine("Right-click to Adjust Filterings")

									GameTooltip:Show()
								end
							end,
			OnLeave = 	function()
								GameTooltip:Hide()
							end,
		}, -- [1]
		{
			button = {
				normalTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				highlightTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				width = 14,
				height = 14,
			},
			font = "GameFontHighlight",
			name = "Recipe",
			width = 250,
			sortCompare = function(a,b)
				return (a.index or 0) - (b.index or 0)
			end,
			filterMenu = recipeFilterMenu,
			OnClick = function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex>0 then
								local entry = cellFrame:GetParent().data

								if entry.subGroup and source == "button" then
									entry.subGroup.expanded = not entry.subGroup.expanded
									sf:Refresh()
								elseif not entry.subGroup then
									GnomeWorks:SelectEntry(entry)
									sf:Draw()
								end
							else
								if source ~= "button" then
									columnControl(cellFrame, button, source)
								else
									cellFrame.collapsed = not cellFrame.collapsed

									if not cellFrame.collapsed then
										GnomeWorks:CollapseAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
									else
										GnomeWorks:ExpandAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
									end
								end
							end
						end,
			draw =	function (rowFrame,cellFrame,entry)
						cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8+4+12, 0)

						if entry.subGroup then
							if entry.subGroup.expanded then
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
							else
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
							end

							cellFrame.text:SetFormattedText("%s (%d Recipes)",entry.name,#entry.subGroup.entries)
							cellFrame.button:Show()

						else
							local itemLink = GnomeWorks:GetTradeSkillItemLink(entry.index)
							local spellName = GnomeWorks:GetRecipeName(entry.recipeID)

							if itemLink then
								local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

								spellName = GnomeWorks:FilterRecipeName(spellName, itemID, entry.recipeID)
							end


							cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %s", GnomeWorks:GetTradeSkillIcon(entry.index) or "", cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,spellName or "recipe:"..entry.recipeID)

							cellFrame.button:Hide()
						end


						local cr,cg,cb = 1,0,0

						if entry.subGroup then
							cr,cg,cb = 1,.82,0
						else
							if not entry.skillColor then
								entry.skillColor = GnomeWorks:GetSkillColor(entry.index)
							end

							if entry.skillColor then
								cr,cg,cb = entry.skillColor.r, entry.skillColor.g, entry.skillColor.b
							end
						end

						cellFrame.text:SetTextColor(cr,cg,cb)
					end,

			OnEnter =	function (cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Recipe Name",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								GameTooltip:SetOwner(cellFrame.scrollFrame, "ANCHOR_NONE")
								GameTooltip:ClearLines()


								local spaceLeft = cellFrame.scrollFrame:GetLeft()
								local spaceRight = GetScreenWidth() - cellFrame.scrollFrame:GetRight()

								if spaceRight > spaceLeft then
									GameTooltip:SetPoint("TOPLEFT",cellFrame.scrollFrame, "TOPRIGHT")
								else
									GameTooltip:SetPoint("TOPRIGHT",cellFrame.scrollFrame, "TOPLEFT")
								end

								if not entry.subGroup then
									if true or entry.recipeID > 0 then
										local spellLink = GetSpellLink(entry.recipeID)

										if spellLink then
											GameTooltip:SetHyperlink(spellLink)
										else
											local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

											GameTooltip:AddLine(GnomeWorks:GetRecipeName(entry.recipeID))

											GameTooltip:AddLine("Reagents:",1,1,1)

											for itemID, numMade in pairs(reagents) do
												local _,link = GetItemInfo(itemID)

												GameTooltip:AddDoubleLine("    "..(link or "item:"..itemID), numMade)
											end

											GameTooltip:AddLine(" ")

											GameTooltip:AddLine("Results:",1,1,1)

											for itemID, numMade in pairs(results) do
												local _,link = GetItemInfo(itemID)

												GameTooltip:AddDoubleLine("    "..(link or "item:"..itemID), numMade)
											end

										end
									else
										GameTooltip:SetHyperlink("item:"..(-entry.recipeID))
									end
								end


								GameTooltip:Show()

							end
						end,
			OnLeave = 	function()
							GameTooltip:Hide()
						end,
		}, -- [2]
		{
			font = "GameFontHighlightSmall",
			name = "Craftable",
			width = 60,
			align = "CENTER",
			sortCompare = function(a,b)
				return (a.totalInventory or 0) - (b.totalInventory or 0)
			end,
			enabled = function()
				return GnomeWorks.tradeID ~= 53428
			end,
			filterMenu = craftFilterMenu,
			OnClick = 	function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex == 0 then
								columnControl(cellFrame, button, source)
							end
						end,
			draw =	function (rowFrame,cellFrame,entry)
							if entry.subGroup then
								cellFrame.text:SetText("")
								return
							end

							if GnomeWorksDB.vendorOnly[entry.recipeID] then
								if entry.bag and entry.bag ~= 0 then
									cellFrame.text:SetFormattedText("%s|r+%s\226\136\158",string.format(inventoryFormat.bag,entry.bag),GnomeWorks.system.inventoryColors.vendor)
								else
									cellFrame.text:SetText(GnomeWorks.system.inventoryColors.vendor.."\226\136\158")
								end
							else
								local display = ""
								local low, hi
								local lowKey, hiKey

								for k,inv in ipairs(inventoryIndex) do
									if entry[inv]>0 then
										low = k
										lowKey = inv
										break
									end
								end

								if low then
									for i=#inventoryIndex,low+1,-1 do
										local key = inventoryIndex[i]
										if key ~= "guildBank" or GnomeWorks.data.playerData[GnomeWorks.player].guild then
											local key2 = inventoryIndex[i-1]

											if key2 ~= "guildBank" or GnomeWorks.data.playerData[GnomeWorks.player].guild then
												if entry[key] > entry[key2] then
													hi = i
													hiKey = key
													break
												end
											end
										end
									end

									if hi and entry[hiKey] > entry[lowKey] then
										local lowString = string.format(inventoryFormat[lowKey],entry[lowKey])
										local hiString = string.format(inventoryFormat[hiKey],entry[hiKey]-entry[lowKey])

										display = lowString.."+"..hiString
									else
										display = string.format(inventoryFormat[lowKey],entry[lowKey])
									end
								end

								cellFrame.text:SetText(display)
							end
						end,

			OnEnter =	function (cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Craftability Counts",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								if entry and entry.recipeID then
									if GnomeWorksDB.vendorOnly[entry.recipeID] then
										GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
										GameTooltip:ClearLines()
										GameTooltip:AddLine("Recipe Craftability",1,1,1,true)
										GameTooltip:AddLine(GnomeWorks.player.."'s Inventory")

										if entry.bag and entry.bag>0 then
											GameTooltip:AddDoubleLine("|cffffff80bags",entry.bag)
										end

										GameTooltip:AddLine("\226\136\158 = unlimited through vendor")
										GameTooltip:Show()

									elseif entry.alt and entry.alt + entry.guildBank > 0 then
										GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
										GameTooltip:ClearLines()
										GameTooltip:AddLine("Recipe Craftability",1,1,1,true)
										GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

										local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

										local prevCount = 0
										for i,key in pairs(inventoryIndex) do
											if key ~= "guildBank" or checkGuildBank then
												local count = entry[key] or 0

												if count > prevCount then
													GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key]..(count-prevCount))
												end

												prevCount = count
											end

--[[
											if count ~= prevCount then
												if count ~= 0 then
													GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key]..count)
												end
												prevCount = count
											end
]]
										end


										GameTooltip:Show()
									end
								end
							end
						end,
			OnLeave = 	function()
							GameTooltip:Hide()
						end,
		}, -- [3]
		{
			font = "GameFontHighlightSmall",
			name = "Inventory",
			width = 60,
			align = "CENTER",
			sortCompare = function(a,b)
				return (a.altInventory or 0) - (b.altInventory or 0)
			end,
			enabled = function()
				return GnomeWorks.tradeID ~= 53428
			end,
			filterMenu = inventoryFilterMenu,
			OnClick = 	function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex == 0 then
								columnControl(cellFrame, button, source)
							end
						end,
			draw =	function (rowFrame,cellFrame,entry)
							if entry.subGroup then
								cellFrame.text:SetText("")
								return
							end

							local display = ""
							local low, hi
							local lowKey, hiKey
							local lowValue, hiValue

							for k,inv in ipairs(inventoryIndex) do
								local value = entry.inventory[inv]
								if value>0 then
									low = k
									lowKey = inv
									lowValue = value
									break
								end
							end

							if low then
								for i=#inventoryIndex,low+1,-1 do
									local key = inventoryIndex[i]

									if entry.inventory[key] > 0 then
										hi = i
										hiKey = key
										hiValue = entry.inventory[key]
										break
									end
								end

								if hi then
									local lowString = string.format(inventoryFormat[lowKey],lowValue)
									local hiString = string.format(inventoryFormat[hiKey],hiValue)

									display = lowString.."+"..hiString
								else
									display = string.format(inventoryFormat[lowKey],lowValue)
								end
							end

							cellFrame.text:SetText(display)
						end,

			OnEnter =	function (cellFrame)
							if cellFrame:GetParent().rowIndex == 0 then
								GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
								GameTooltip:ClearLines()
								GameTooltip:AddLine("Inventory Counts",1,1,1,true)

								GameTooltip:AddLine("Left-click to Sort")
								GameTooltip:AddLine("Right-click to Adjust Filterings")

								GameTooltip:Show()
							else
								local entry = cellFrame:GetParent().data

								if entry and entry.recipeID then
									if entry.totalInventory > 0 then
										GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
										GameTooltip:ClearLines()
										GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

										local itemID = entry.itemID

										local prev = 0
										local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

										for i,key in pairs(inventoryIndex) do
											if key ~= "vendor" and (key ~= "guildBank" or checkGuildBank) then
												local count = entry.inventory[key] or 0

												if count ~= 0 then -- prev ~= count and count ~= 0 then

													if key == "alt" then
														GameTooltip:AddDoubleLine(inventoryTags[key], inventoryColors[key]..(count-prev))

														GameTooltip:AddLine("    ")

														GameTooltip:AddLine("alt item locations:",.8,.8,.8)
														for inventoryName, containers in pairs(GnomeWorks.data.inventoryData) do
															if inventoryName ~= GnomeWorks.player then
																local bag = 0
																if containers.bag and containers.bag[itemID] then
																	GameTooltip:AddDoubleLine("   "..inventoryColors.alt..inventoryName.."/bag",inventoryColors.alt..containers.bag[itemID])

																	bag = containers.bag[itemID]
																end
																if containers.bank and containers.bank[itemID] and containers.bank[itemID] > bag then
																	if string.find(inventoryName,"GUILD:") then
																		local guildName = string.match(inventoryName,"GUILD:(.+)")
																		if guildName ~= GnomeWorks.data.playerData[GnomeWorks.player].guild then
																			GameTooltip:AddDoubleLine("   "..inventoryColors.alt..guildName.."/guildBank",inventoryColors.alt..(containers.bank[itemID] - bag))
																		end
																	else
																		GameTooltip:AddDoubleLine("   "..inventoryColors.alt..inventoryName.."/bank",inventoryColors.alt..(containers.bank[itemID] - bag))
																	end
																end
															end
														end
													else
														GameTooltip:AddDoubleLine(inventoryTags[key],inventoryColors[key]..count)
													end
												end

												prev = count
											end
										end


										GameTooltip:Show()
									end
								end
							end
						end,
			OnLeave = 	function()
							GameTooltip:Hide()
						end,
		}, -- [4]
	}


	GnomeWorks:CreateFilterMenu(levelFilterParameters, levelFilterMenu, columnHeaders[1])
	GnomeWorks:CreateFilterMenu(recipeLevelParameters, recipeLevelMenu, columnHeaders[2])
	GnomeWorks:CreateFilterMenu(craftFilterParameters, craftSourceMenu, columnHeaders[3])
	GnomeWorks:CreateFilterMenu(inventoryFilterParameters, inventorySourceMenu, columnHeaders[4])



	local function ResizeMainWindow()
		if sf then
			if not GnomeWorks.selectedSkill then
				GnomeWorks.detailFrame:Hide()
				GnomeWorks.reagentFrame:Hide()
			end

			if GnomeWorks.detailFrame:IsShown() then
				skillFrame:SetPoint("BOTTOMLEFT",GnomeWorks.detailFrame,"TOPLEFT",0,40)
			else
				skillFrame:SetPoint("BOTTOMLEFT",20,55)
			end
		end
	end



	local function BuildScrollingTable()

		local function ResizeSkillFrame(scrollFrame,width,height)
			if scrollFrame then
				scrollFrame.columnWidth[2] = scrollFrame.columnWidth[2] + width - scrollFrame.headerWidth
				scrollFrame.headerWidth = width

				local x = 0

				for i=1,#scrollFrame.columnFrames do
					local w = scrollFrame.columnFrames[i]:IsShown() and scrollFrame.columnWidth[i] or 0

					scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
					scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+w,0)

					x = x + w
				end
			end
		end

		local ScrollPaneBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 9.5, right = 9.5, top = 9.5, bottom = 11.5 }
			}

		skillFrame = CreateFrame("Frame",nil,frame)
		skillFrame:SetPoint("BOTTOMLEFT",20,20)
		skillFrame:SetPoint("TOP", frame, 0, -70 - GnomeWorksDB.config.scrollFrameLineHeight)
		skillFrame:SetPoint("RIGHT", frame, -20,0)

		sf = GnomeWorks:CreateScrollingTable(skillFrame, ScrollPaneBackdrop, columnHeaders, ResizeSkillFrame)

		skillFrame.scrollFrame = sf



		sf.IsEntryFiltered = function(self, entry)
			for k,filter in pairs(activeFilterList) do
				if filter.enabled then
					if filter.func(entry, filter.arg) then
						return true
					end
				end
			end

			return false
		end



		local function UpdateRowData(scrollFrame,entry,firstCall)
			local player = GnomeWorks.player

			if not entry.subGroup then
				local results, reagents = GnomeWorks:GetRecipeData(entry.recipeID, player)

				if next(reagents) then
					local onHand = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "bag")

					local bag = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "craftedBag")
					local vendor = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "vendor craftedBag")
					local bank = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "vendor craftedBank")
					local mail = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "vendor craftedMail")
					local guildBank = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "vendor craftedGuildBank")
					local alt = GnomeWorks:InventoryRecipeIterations(entry.recipeID, "faction", "vendor craftedMail")

if entry.recipeID == 3915 then
--					print("craftedMail iterations",GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "craftedMail"))
--					print("craftedMail iterations",GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, "craftedMail"))
end

					if onHand > 0 then
						entry.craftable = true
					else
						entry.craftable = nil
					end

					entry.bag = bag
					entry.vendor = vendor
					entry.bank = bank
					entry.mail = mail
					entry.guildBank = guildBank
					entry.alt = math.max(alt, guildBank)
				else
					entry.bag = 0
					entry.vendor = 0
					entry.bank = 0
					entry.guildBank = 0
					entry.alt = 0
					entry.mail = 0

					entry.craftable = nil
				end

				local itemLink = (entry.index and GnomeWorks:GetTradeSkillItemLink(entry.index))


				if not entry.itemColor then

					local _,itemRarity,reqLevel
					local itemColor

					if itemLink then
						_,_,itemRarity,_,reqLevel = GetItemInfo(itemLink)

						itemColor = itemQualityColor[itemRarity]


					else
						itemColor = itemQualityColor[0]
					end

					if reqLevel and reqLevel > 0 then
						entry.itemLevel = reqLevel
					end

					entry.itemColor = itemColor
				end

				if not entry.inventory then
					entry.inventory = {}
				end

				for k,inv in ipairs(inventoryIndex) do
					entry.inventory[inv] = 0
				end

				entry.totalInventory = 0

				if itemLink then

					local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

					entry.itemID = itemID

					if itemID then
						for k,inv in ipairs(inventoryIndex) do
							if inv == "alt" then
								entry.inventory[inv] = GnomeWorks:GetInventoryCount(itemID, "faction", "mail")
							else
								entry.inventory[inv] = GnomeWorks:GetInventoryCount(itemID, player, inv)
							end

							entry.totalInventory = entry.totalInventory + entry.inventory[inv]
						end
					end
				end
			end


		end


		sf:RegisterRowUpdate(UpdateRowData)


		return skillFrame
	end


	local function ScanComplete()
		local player = GnomeWorks.player
		local tradeID = GnomeWorks.tradeID

		GnomeWorks:UpdateTradeButtons(player,tradeID)
		GnomeWorks:ShowStatus()
		GnomeWorks:ShowSkillList()

		if not GnomeWorks.selectedEntry then
			for i=1,#sf.dataMap do
				if not sf.dataMap[i].subGroup then
					GnomeWorks:SelectEntry(sf.dataMap[i])
					break
				end
			end
		end

		ResizeMainWindow()

		GnomeWorks:SendMessageDispatch("GnomeWorksDetailsChanged")
	end


	function GnomeWorks:DoTradeSkillUpdate()
--print("DO UPDATE")
		if frame:IsVisible() then
--print("SCAN TRADE")
			self:ScanTrade()
		end
	end


	function GnomeWorks:CHAT_MSG_SKILL()
		self:ParseSkillList()
		self:DoTradeSkillUpdate()
	end


	function GnomeWorks:TRADE_SKILL_SHOW()
--print("TRADE_SKILL_SHOW")
		if IsControlKeyDown() then
			if frame:IsShown() then
				frame:Hide()
				frame.title:Hide()
			end

			self.blizzardFrameShow()
		else
			self:GetTradeIDFromAPI()

			TradeSkillFrame_Update()						-- seems to fix the early bailout of trade skill iterations

			self:ResetSkillSelect()

			if self.updateTimer then
				self:CancelTimer(self.updateTimer, true)
			end

			self.updateTimer = self:ScheduleTimer("DoTradeSkillUpdate",.1)

			if self.hideMainWindow then
				self.hideMainWindow = nil
				CloseTradeSkill()
			else
				frame:Show()
				frame.title:Show()
				sf:Show()
			end
		end
	end


	function GnomeWorks:ShowSkillList()
		local player = self.player
		local tradeID = self.tradeID

		if player and tradeID then
--			local key = player..":"..tradeID

			local player, tradeID, label, groupName = self:RecipeGroupValidate(player, tradeID, self.groupLabel or "By Category", self.group)

			local group = self:RecipeGroupFind(player, tradeID, label, groupName)

			self.group = groupName
			self.groupLabel = label

			local groupLabel = label

			if groupName then
				groupLabel = groupLabel.."/"..groupName
			end

			if groupLabel then
				UIDropDownMenu_SetText(GnomeWorksGrouping, "Group "..groupLabel)
			else
				UIDropDownMenu_SetText(GnomeWorksGrouping, "--")
			end

			sf.data = group
			sf:Refresh()
			sf:Show()
		else
			sf.data = {}
			sf:Refresh()
			sf:Show()
		end
	end


	function GnomeWorks:SkillListDraw(selected)
		sf.selectedIndex = selected or self.selectedSkill
--		self.selectedSkill = selected
		sf:Draw()
	end

	function GnomeWorks:ShowStatus()
		local rank, maxRank = self:GetTradeSkillRank()
		self.levelStatusBar:SetMinMaxValues(0,maxRank)
		self.levelStatusBar.estimatedLevel:SetMinMaxValues(0,maxRank)
		self.levelStatusBar:SetValue(rank)
		self.levelStatusBar.estimatedLevel:SetValue(rank)
		self.levelStatusBar:Show()

		local estimatedSkillUp = GnomeWorks.data.skillUpRanks[GnomeWorks.tradeID]

		if estimatedSkillUp then
			self.levelStatusBar.estimatedLevel:SetValue(estimatedSkillUp)
		end

		self.playerNameFrame:SetFormattedText("%s - %s", self.player or "??", self:GetTradeName(self.tradeID) or "??")
	end


	function GnomeWorks:UpdateMainWindow()
		self:ShowSkillList()
		self:ShowStatus()
		self:UpdateTradeButtons(self.player,self.tradeID)
	end


	function GnomeWorks:TRADE_SKILL_UPDATE(...)
--print("MAIN WINDOW TRADE_SKILL_UPDATE")
		if self.updateTimer then
			self:CancelTimer(self.updateTimer, true)
		end

		self.updateTimer = self:ScheduleTimer("DoTradeSkillUpdate",.1)
	end


	function GnomeWorks:TRADE_SKILL_CLOSE()
		frame.title:Hide()
		frame:Hide()
	end

	function GnomeWorks:SetFilterText(text)
		local textFilter = string.lower(text)

		if (text ~= "") then
			searchTextParameters.enabled = true
			searchTextParameters.arg = textFilter
		else
			searchTextParameters.enabled = false
			searchTextParameters.arg = ""
		end

		self:SendMessageDispatch("GnomeWorksSkillListChanged")
--		sf:Refresh()
	end


	function GnomeWorks:ScrollToIndex(skillIndex)
		local rowIndex = 1

		for i=1,#sf.dataMap do
			if sf.dataMap[i].index == skillIndex then
				rowIndex = i
				break
			end
		end

		if rowIndex <= sf.scrollOffset then
			sf.scrollBar:SetValue((rowIndex-1) * sf.rowHeight)
		elseif rowIndex > sf.scrollOffset + sf.numRows then
			sf.scrollBar:SetValue((rowIndex - sf.numRows)*sf.rowHeight)
		end
	end


	local SelectTradeLink do
		local function SelectTradeSkill(menuFrame, player, tradeLink)
			ToggleDropDownMenu(1, nil, playerSelectMenu, menuFrame, menuFrame:GetWidth(), 0)
			local tradeString = string.match(tradeLink, "(trade:%d+:%d+:%d+:[0-9a-fA-F]+:[A-Za-z0-9+/]+)")

			if (UnitName("player")) == player then
				local tradeName = GetSpellInfo(string.match(tradeString, "trade:(%d+)"))

				if ((GnomeWorks:GetTradeSkillLine() == "Mining" and "Smelting") or GnomeWorks:GetTradeSkillLine()) ~= tradeName or GnomeWorks:IsTradeSkillLinked() then
					CastSpellByName(tradeName)
				end
			else
				GnomeWorks:OpenTradeLink(tradeLink,player)
			end
		end

		local function InitMenu(menuFrame, level)
			if (level == 1) then  -- character names
				local title = {}
				local playerMenu = {}

				title.text = "Select Player and Tradeskill"
--				title.isTitle = true
--				title.notClickable = true
				title.fontObject = "GameFontNormal"

				title.notCheckable = 1

				UIDropDownMenu_AddButton(title)

				local index = 1

				for k,player in pairs(GnomeWorks.data.toonList) do
					data = GnomeWorks.data.playerData[player]

					if data.build == clientBuild then
						playerMenu.text = player
						playerMenu.hasArrow = true
						playerMenu.value = player
						playerMenu.disabled = false

						playerMenu.notCheckable = 1

						UIDropDownMenu_AddButton(playerMenu)
						index = index + 1
					end
				end
			end

			if (level == 2) then  -- skills per player
				local links = GnomeWorks:GetTradeLinkList(UIDROPDOWNMENU_MENU_VALUE)
				local skillButton = {}

				for index, tradeID in ipairs(tradeIDList) do
					if links[tradeID] then
						local rank, maxRank = string.match(links[tradeID], "trade:%d+:(%d+):(%d+)")
						local spellName, spellLink, spellIcon = GnomeWorks:GetTradeInfo(tradeID)

						skillButton.text = string.format("%s |cff00ff00[%s/%s]|r", spellName, rank, maxRank)
						skillButton.value = tradeID

						skillButton.icon = spellIcon

						skillButton.arg1 = UIDROPDOWNMENU_MENU_VALUE
						skillButton.arg2 = links[tradeID]
						skillButton.func = SelectTradeSkill

						skillButton.checked = (tradeID == GnomeWorks.tradeID and UIDROPDOWNMENU_MENU_VALUE == GnomeWorks.player)

						skillButton.disabled = false

						UIDropDownMenu_AddButton(skillButton, level)
					end
				end
			end
		end

		function SelectTradeLink(frame)
			if not playerSelectMenu then
				playerSelectMenu = CreateFrame("Frame", "GWPlayerSelectMenu", UIParent, "UIDropDownMenuTemplate")
			end

			UIDropDownMenu_Initialize(playerSelectMenu, InitMenu, "MENU")
			ToggleDropDownMenu(1, nil, playerSelectMenu, frame, 0, 0)
		end
	end


	local function CreateButtons(buttonConfig, buttons, dataTable)
		local position = 0

		for i, config in pairs(buttonConfig) do
			if not config.style or config.style == "Button" then
				local newButton = GnomeWorks:CreateButton(controlFrame, 18)

				newButton:SetPoint("LEFT", position,0)
				newButton:SetWidth(config.width)
				newButton:SetNormalFontObject("GameFontNormalSmall")
				newButton:SetHighlightFontObject("GameFontHighlightSmall")
				newButton:SetDisabledFontObject("GameFontDisableSmall")

				newButton:SetText(config.text)

				newButton:SetScript("OnClick", config.operation)

				newButton.validate = config.validate

				buttons[i] = newButton

				newButton.setting = config.setting


				position = position + config.width


				if config.name then
					buttons[config.name] = newButton
				end
			else
				local newButton = CreateFrame(config.style, nil, controlFrame)

				newButton:SetPoint("LEFT", position,0)
				newButton:SetWidth(config.width)
				newButton:SetHeight(18)
				newButton:SetFontObject("GameFontHighlightSmall")
--				newButton:SetHighlightFontObject("GameFontHighlightSmall")

--				newButton:SetText(config.text or "")

				newButton.validate = config.validate

				if config.style == "EditBox" then
					newButton:SetAutoFocus(false)

					newButton:SetNumeric(true)

					newButton:SetScript("OnEnterPressed", EditBox_ClearFocus)
					newButton:SetScript("OnEscapePressed", EditBox_ClearFocus)
					newButton:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
					newButton:SetScript("OnEditFocusGained", EditBox_HighlightText)


					newButton:SetScript("OnTextChanged", function(f)
						local n = f:GetNumber()

						if n<=0 then
							f:SetText("")

							dataTable[config.setting] = 1
						else
							dataTable[config.setting] = n
						end
					end)

					newButton:SetJustifyH("CENTER")
					newButton:SetJustifyV("CENTER")

					local searchBackdrop  = {
							bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
							edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
							tile = true, tileSize = 16, edgeSize = 16,
							insets = { left = 10, right = 10, top = 8, bottom = 10 }
						}

					GnomeWorks.Window:SetBetterBackdrop(newButton, searchBackdrop)

					newButton:SetText("")
					newButton:SetMaxLetters(4)


					newButton:SetNumber(config.default)
				end

				buttons[i] = newButton

				if config.name then
					buttons[config.name] = newButton
				end

				position = position + config.width
			end
		end

		return position
	end


	local function CreateQueueButtons(frame)
		local dataTable = {}
		local buttons = {}

		local function MaterialsOnHand(button)
			local entry = GnomeWorks.selectedEntry

			if entry then
				if entry.craftable then
					button:Enable()
					return
				end
			end
			button:Disable()
		end


		local function MaterialsOnAlt(button)

			local entry = GnomeWorks.selectedEntry

			if entry then
				if entry.alt and entry.alt >= 1 then
					button:Enable()
					return
				end
			end

			button:Disable()
		end

		local function Create(button)
			local numItems = dataTable[button.setting]
			local entry = GnomeWorks.selectedEntry

			EditBox_ClearFocus(buttons.queueCountButton)

			if numItems then
				DoTradeSkill(GnomeWorks.selectedSkill, numItems)
			else
				DoTradeSkill(GnomeWorks.selectedSkill, entry.bag)
			end
		end


		local function AddToQueue(button)
			local numItems = dataTable[button.setting]
			local entry = GnomeWorks.selectedEntry

			EditBox_ClearFocus(buttons.queueCountButton)

--			local recipeLink = self:GetTradeSkillRecipeLink(GnomeWorks.selectedSkill)

--			local recipeID = tonumber(string.match(recipeLink, "enchant:(%d+)"))

			if not numItems then


				local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(next(GnomeWorksDB.results[entry.recipeID]))

				if entry.alt < 1 then
					numItems = itemStackCount
				else
					if entry.bag > 1 then
						numItems = entry.bag
					elseif entry.vendor > 1 then
						numItems = entry.vendor
					elseif entry.bank > 1 then
						numItems = entry.bank
					else
						numItems = entry.alt
					end
				end



				if numItems == LARGE_NUMBER then
					numItems = itemStackCount
				end
			end

			GnomeWorks:ShowQueueList()
			if entry then
				GnomeWorks:AddToQueue(GnomeWorks.player, GnomeWorks.tradeID, entry.recipeID, numItems)
			end
		end




		local buttonConfig = {
			{ text = "Create", operation = Create, width = 50, setting = "queueCount", validate = MaterialsOnHand },
			{ text = "Queue", operation = AddToQueue, setting = "queueCount", width = 50 },
			{ style = "EditBox", setting = "queueCount", width = 50, default = 1, name = "queueCountButton"},
			{ text = "Create All", operation = Create, width = 70, validate = MaterialsOnHand },
			{ text = "Queue All", operation = AddToQueue, width = 70, validate = MaterialsOnAlt },
		}


		controlFrame = CreateFrame("Frame", nil, frame)

		controlFrame:SetHeight(20)
		controlFrame:SetWidth(200)

		controlFrame:SetPoint("TOPLEFT", GnomeWorks.skillFrame, "BOTTOMLEFT", 0, -2)

		local position = CreateButtons(buttonConfig, buttons, dataTable)

		controlFrame:SetWidth(position)

		buttons.queueCountButton:RegisterEvent("UPDATE_TRADESKILL_RECAST")

		buttons.queueCountButton:SetScript("OnEvent", function(frame)
--print("UPDATE RECAST", ...)
			frame:SetNumber(GetTradeskillRepeatCount())
		end)


		GnomeWorks:RegisterMessageDispatch("GnomeWorksDetailsChanged HeartBeat", function()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end)

		return controlFrame
	end


	local function CreateOptionButtons(frame)
		local dataTable = {}
		local layoutMode


		local function PopRecipe()
			GnomeWorks:PopSelection()
		end


		local ShowPlugins do
			local function InitMenu(menuFrame, level)
				if (level == 1) then  -- plugins
					local title = {}
					local button = {}

					title.text = "Plugins"
					title.fontObject = "GameFontNormal"

					UIDropDownMenu_AddButton(title)

					local count = 0

					for name,data in pairs(GnomeWorks.plugins) do
						if data.loaded then
							button.text = name
							button.hasArrow = #data.menuList>0
							button.value = data.menuList
							button.disabled = false

							UIDropDownMenu_AddButton(button)
							count = count + 1
						end
					end

					if count == 0 then
						button.text = "No Plugins Found"
						button.disabled = true

						UIDropDownMenu_AddButton(button)
					end
				end

				if (level == 2) then  -- functions per plugin
					for index, button in ipairs(UIDROPDOWNMENU_MENU_VALUE) do
						UIDropDownMenu_AddButton(button, level)
					end
				end
			end

			function ShowPlugins(frame)
				if not pluginMenu then
					pluginMenu = CreateFrame("Frame", "GWPluginMenu", UIParent, "UIDropDownMenuTemplate")
				end

				UIDropDownMenu_Initialize(pluginMenu, InitMenu, "MENU")
				ToggleDropDownMenu(1, nil, pluginMenu, frame, 0, 0)
			end
		end


		local function ToggleLayoutMode()
			layoutMode = not layoutMode

			for k,f in ipairs(GnomeWorks.scrollFrameList) do
				if not layoutMode then
					f.controlOverlay:Hide()
				else
					f.controlOverlay:Show()
				end
			end
		end



		local buttons = {}


		local buttonConfig = {
--			{ text = "Back", operation = PopRecipe, width = 50 },
			{ text = "Adjust Layout", operation = ToggleLayoutMode, width = 100 },
			{ text = "Plugins", operation = ShowPlugins, width = 50 },
		}


		controlFrame = CreateFrame("Frame", nil, frame)

		controlFrame:SetHeight(20)
		controlFrame:SetWidth(200)

		controlFrame:SetPoint("TOPRIGHT", GnomeWorks.skillFrame, "BOTTOMRIGHT", 0, -2)

		local position = CreateButtons(buttonConfig, buttons, dataTable)

		controlFrame:SetWidth(position)

		GnomeWorks:RegisterMessageDispatch("GnomeWorksDetailsChanged", function()
--			sf:Draw()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end)

		return controlFrame
	end


	local function CreateControlFrame(parent)
		local frame = CreateFrame("Frame",nil,parent)

		frame.QueueButtons = CreateQueueButtons(frame)
		frame.OptionButtons = CreateOptionButtons(frame)

		return frame
	end


	function GnomeWorks:CreateMainWindow()
		frame = self.Window:CreateResizableWindow("GnomeWorksFrame", "GnomeWorks (r"..VERSION..")", 600, 400, ResizeMainWindow, GnomeWorksDB.config)

		frame:Hide()

		frame:SetMinResize(500,400)

		local rightSideWidth = 300


		self.detailFrame = self:CreateDetailFrame(frame)
		self.reagentFrame = self:CreateReagentFrame(frame)

		self.skillFrame = BuildScrollingTable()

		self.controlFrame = CreateControlFrame(frame)

		local tradeButtonFrame = CreateFrame("Frame", nil, frame)
		tradeButtonFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20,-48)
		tradeButtonFrame:SetWidth(rightSideWidth)
		tradeButtonFrame:SetHeight(18)



		self:CreateTradeButtons(tradeIDList, tradeButtonFrame)
--[[
		local t = tradeButtonFrame:CreateTexture(nil,"OVERLAY")
		t:SetTexture(1,1,1,.5)
		t:SetPoint("TOPLEFT",-5,5)
		t:SetPoint("BOTTOMRIGHT",5,-5)
]]

--		self.tradeButtonFrame:ClearAllPoints()


--		self.detailFrame:SetScript("OnShow", function() ResizeMainWindow(frame) end)
--		self.detailFrame:SetScript("OnHide", function() ResizeMainWindow(frame) end)

		local searchBox = CreateFrame("EditBox","GnomeWorksSearch",frame)


		local searchBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 12, right = 10, top = 10, bottom = 10 }
			}

		self.Window:SetBetterBackdrop(searchBox, searchBackdrop)

		searchBox:SetFrameLevel(searchBox:GetFrameLevel()+1)

		searchBox:SetAutoFocus(false)

		searchBox:SetPoint("TOPLEFT", frame, 22,-50)
		searchBox:SetHeight(16)
		searchBox:SetPoint("RIGHT", tradeButtonFrame, "LEFT", -30,0)

		searchBox:SetScript("OnEnterPressed", EditBox_ClearFocus)
		searchBox:SetScript("OnEscapePressed", EditBox_ClearFocus)
		searchBox:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
		searchBox:SetScript("OnEditFocusGained", EditBox_HighlightText)

		searchBox:SetScript("OnTextChanged", function(f)
			if f.oldText ~= f:GetText() then
				GnomeWorks:SetFilterText(f:GetText())
			end

			f.oldText = f:GetText()
		end)



		searchBox:EnableMouse(true)
		searchBox:SetFontObject("GameFontHighlightSmall")

		local clearSearch = CreateFrame("Button", nil, searchBox)
		clearSearch:SetWidth(32)
		clearSearch:SetHeight(32)
		clearSearch:SetPoint("LEFT",searchBox,"RIGHT",-8,-2)
		clearSearch:SetNormalTexture("Interface\\Buttons\\CancelButton-Up")
		clearSearch:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
		clearSearch:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")
--		clearSearch:SetScale(1)

		clearSearch:SetScript("OnClick", function() searchBox:SetText("") EditBox_ClearFocus(searchBox) end)


		self.searchBoxFrame = searchBox


		local groupSelection = CreateFrame("Button", "GnomeWorksGrouping", frame, "UIDropDownMenuTemplate")
		groupSelection:SetPoint("BOTTOMLEFT",searchBox,"TOPLEFT",-5,2)
--		UIDropDownMenu_SetWidth(groupSelection, 200, 0)
--		groupSelection.noResize = nil

		GnomeWorksGroupingMiddle:SetPoint("RIGHT", searchBox,"RIGHT",-22,0)
--		groupSelection:SetHeight(16)


		groupSelection:SetScript("OnShow", function(dropDown) GnomeWorks:RecipeGroupDropdown_OnShow(dropDown) end)




		local levelBackDrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 12, right = 12, top = 12, bottom = 12 }
			}



		local estimatedLevel = CreateFrame("StatusBar", nil, frame)
		local level = CreateFrame("StatusBar", nil, estimatedLevel)


		level:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-20,-34)
		level:SetPoint("LEFT",tradeButtonFrame)
		level:SetHeight(8)


		level:SetOrientation("HORIZONTAL")
		level:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		level:SetStatusBarColor(.05,.05,.75,1)


		estimatedLevel:SetAllPoints(level)

		estimatedLevel:SetOrientation("HORIZONTAL")
		estimatedLevel:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		estimatedLevel:SetStatusBarColor(.05,.5,1,1)



		self.Window:SetBetterBackdrop(estimatedLevel, levelBackDrop)
		self.Window:SetBetterBackdropColor(estimatedLevel, 1,1,1,.5)

		local levelText = level:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		levelText:SetPoint("CENTER",0,1)
		levelText:SetHeight(13)
		levelText:SetWidth(100)
		levelText:SetJustifyH("CENTER")

		level.text = levelText

		level.estimatedLevel = estimatedLevel
		estimatedLevel.level = level


		estimatedLevel:SetScript("OnValueChanged", function(frame, value)
			local minValue, maxValue = frame:GetMinMaxValues()
			local level = frame.level:GetValue()

			if value ~= level then
				levelText:SetFormattedText("%d(%d)/%d",value,level,maxValue)
			end
		end)


		level:SetScript("OnValueChanged", function(frame, value)
			local minValue, maxValue = frame:GetMinMaxValues()

			frame.estimatedLevel:SetValue(value)

			levelText:SetFormattedText("%d/%d",value,maxValue)
		end)





		self.levelStatusBar = level



		local playerName = CreateFrame("Button", nil, frame)

		playerName:SetPoint("LEFT",tradeButtonFrame)
--		playerName:SetWidth(rightSideWidth)
		playerName:SetHeight(16)
		playerName:SetText("UNKNOWN")
		playerName:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-20,-15)

		playerName:SetNormalFontObject("GameFontNormal")
		playerName:SetHighlightFontObject("GameFontHighlight")

--		playerName:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Opaque")

		playerName:EnableMouse(true)

		playerName:RegisterForClicks("AnyUp")

		playerName:SetScript("OnClick", SelectTradeLink)

		playerName:SetFrameLevel(playerName:GetFrameLevel()+1)

		self.playerNameFrame = playerName


		self.SelectTradeLink = SelectTradeLink




		table.insert(UISpecialFrames, "GnomeWorksFrame")

		frame:HookScript("OnShow", function() PlaySound("igCharacterInfoOpen") end)
		frame:HookScript("OnHide", function() CloseTradeSkill() PlaySound("igCharacterInfoClose") end)


		self:RegisterMessageDispatch("GnomeWorksScanComplete", ScanComplete)

		self:RegisterMessageDispatch("GnomeWorksSkillListChanged", function()
			self:ShowSkillList()

			self:SendMessageDispatch("GnomeWorksDetailsChanged")
		end)


		self:RegisterMessageDispatch("SkillRanksChanged", function()
			self:ShowSkillList()
			self:ShowStatus()
		end)




		return frame
	end

end
