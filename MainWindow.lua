



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

	local tooltipScanner = _G["GWParsingTooltip"] or CreateFrame("GameTooltip", "GWParsingTooltip", ANCHOR_NONE, "GameTooltipTemplate")


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

--[[
		if recipeID and string.match(text, ENCHANTING_REPLACEMENT_STRING) then
			local newText = string.gsub(text, ENCHANTING_REPLACEMENT_STRING, "")
			return newText
		end
]]
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


	local tooltipScanner = _G["GWParsingTooltip"] or CreateFrame("GameTooltip", "GWParsingTooltip", ANCHOR_NONE, "GameTooltipTemplate")

	tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")


	local tooltipRecipeCache = {}
	local tooltipRecipeCacheLeft =  {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}		-- 20 lines
	local tooltipRecipeCacheRight = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}		-- 20 lines




--	local inventoryIndex = GnomeWorks.system.inventoryIndex
--	local inventoryColors = GnomeWorks.system.inventoryColors
--	local inventoryFormat = GnomeWorks.system.inventoryFormat
--	local inventoryTags = GnomeWorks.system.inventoryTags



	local playerSelectMenu
	local pluginMenu, optionsMenu


	local columnHeaders


	local itemQualityColor = {}

	for i=0,7 do
		local r,g,b = GetItemQualityColor(i)
		itemQualityColor[i] = { r=r, g=g, b=b }
--		itemQualityColor[i].r, itemQualityColor[i].g, itemQualityColor[i].b = GetItemQualityColor(i)
	end


	local tradeIDList = GnomeWorks.system.tradeIDList



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
			text = "Filter by Craftability: "..GnomeWorks.system.inventoryColors.alt.."alts",
			menuList = craftSourceMenu,
			hasArrow = true,
			filterIndex = #GnomeWorks.system.inventoryIndex,
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

	for i,key in pairs(GnomeWorks.system.inventoryIndex) do
		craftFilterParameters[i] = {
			name = "Craftability"..key,
			text = GnomeWorks.system.inventoryTags[key],
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
			text = "Filter by Inventory: "..GnomeWorks.system.inventoryColors.alt.."alts",
			menuList = inventorySourceMenu,
			hasArrow = true,
			filterIndex = #GnomeWorks.system.inventoryIndex,
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

	for i,key in pairs(GnomeWorks.system.inventoryIndex) do
		inventoryFilterParameters[i] = {
			name = "Inventory"..key,
			text = GnomeWorks.system.inventoryTags[key],
			enabled = false,
			func = function(entry)
				if entry and entry.inventory[key] and entry.inventory[key] > 0 then
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
			name = "DifficultyUnknown",
			text = "",
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			coords = {0,1,0,.25},
			enabled = false,
			func = function(entry)
				local difficulty = GnomeWorks:GetRecipeDifficulty(entry.recipeID)

				if difficulty > 4 then
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
			name = "DifficultyOptimal",
			text = "",
			icon = "Interface\\AddOns\\GnomeWorks\\Art\\skill_colors.tga",
			coords = {0,1,.25,.5},
			enabled = false,
			func = function(entry)
				local difficulty = GnomeWorks:GetRecipeDifficulty(entry.recipeID)

				if difficulty > 3 and difficulty < 5 then
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
			coords = {0,1,.5,.75},
			func = function(entry)
				local difficulty = GnomeWorks:GetRecipeDifficulty(entry.recipeID)

				if difficulty > 2 and difficulty < 5 then
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
			coords = {0,1,.75,1.0},
			enabled = false,
			func = function(entry)
				local difficulty = GnomeWorks:GetRecipeDifficulty(entry.recipeID)

				if difficulty > 1 and difficulty < 5 then
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



	local function RenameGroup(cellFrame, newName)
		local entry  = cellFrame:GetParent().data

		entry.name = GnomeWorks:RecipeGroupRenameEntry(entry, newName)

		sf:Refresh()
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
								local thisClick = GetTime()

								if entry.subGroup then
									if source == "button" then
										entry.subGroup.expanded = not entry.subGroup.expanded
										sf:Refresh()
									else
										local lastClick = source

										if lastClick < .4 then
											if not GnomeWorks:RecipeGroupIsLocked() then
												cellFrame:Edit(entry.name, RenameGroup)
											end
										end
									end
								else
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

						cellFrame:ClearIcons()

						if entry.iconList then
							for k,icon in pairs(entry.iconList) do
								cellFrame:AddIcon(icon)
							end
						end

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

							if GnomeWorks.player ~= "All Recipes" then
								local known,reallyKnown = GnomeWorks:IsSpellKnown(entry.recipeID,GnomeWorks.player) -- trainable will but not yet learned will return true, false

								if not reallyKnown then
									local rankNeeded = GnomeWorks.data.trainableSpells[entry.recipeID]
									spellName = string.format("%s |cff803030(trainable at %s)",spellName,rankNeeded or "??")
								end
							end


--							cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %s", GnomeWorks:GetTradeSkillIcon(entry.index) or "", cellFrame:GetHeight()-1,cellFrame:GetHeight()-1,spellName or "recipe:"..entry.recipeID)
							cellFrame.text:SetFormattedText("|T%s:0|t %s", GnomeWorks:GetTradeSkillIcon(entry.index) or "",spellName or "recipe:"..entry.recipeID)

							cellFrame.button:Hide()
						end


						local alpha = 1

						local cr,cg,cb = 1,0,0

						if entry.subGroup then
							cr,cg,cb = 1,.82,0
						else
--							if not entry.skillColor then
							_,_,entry.skillColor = GnomeWorks:GetRecipeDifficulty(entry.recipeID)
--							end

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

										local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

										if spellLink then
											GameTooltip:SetHyperlink(spellLink)
										elseif tradeID == 53428 then
											GameTooltip:SetSpellByID(entry.recipeID)
										else
											GameTooltip:SetHyperlink("item:"..next(results))
--											GameTooltip:AddLine(GnomeWorks:GetRecipeName(entry.recipeID))

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

									if entry.cooldown then
										GameTooltip:AddLine(" ")
										GameTooltip:AddDoubleLine("|cffff0000"..COOLDOWN_REMAINING,"|cffff0000"..SecondsToTime(entry.cooldown))
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
				return (a.totalCraftable or 0) - (b.totalCraftable or 0)
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

							local inventoryIndex = GnomeWorksDB.config.inventoryIndex

							if GnomeWorksDB.vendorOnly[entry.recipeID] then
								if entry.bag and entry.bag ~= 0 then
									cellFrame.text:SetFormattedText("%s|r+%s\226\136\158",string.format(GnomeWorks.system.inventoryFormat.bag,entry.bag),GnomeWorks.system.inventoryColors.vendor)
								else
									cellFrame.text:SetText(GnomeWorks.system.inventoryColors.vendor.."\226\136\158")
								end
							else
								local display = ""
								local low, hi
								local lowKey, hiKey

								local playerData = GnomeWorks.data.playerData[GnomeWorks.player]

								for k,inv in ipairs(inventoryIndex) do
									if (entry[inv] or 0) >0 then
										low = k
										lowKey = inv
										break
									end
								end

								if low then
									for i=#inventoryIndex,low+1,-1 do
										local key = inventoryIndex[i]
										if key ~= "guildBank" or (playerData and playerData.guild) then
											local key2 = inventoryIndex[i-1]

											if key2 ~= "guildBank" or (playerData and playerData.guild)  then
												if entry[key] > entry[key2] then
													hi = i
													hiKey = key
													break
												end
											end
										end
									end

									if hi and entry[hiKey] > entry[lowKey] then
										local lowString = string.format(GnomeWorks.system.inventoryFormat[lowKey],entry[lowKey])
										local hiString = string.format(GnomeWorks.system.inventoryFormat[hiKey],entry[hiKey]-entry[lowKey])

										display = lowString.."+"..hiString
									else
										display = string.format(GnomeWorks.system.inventoryFormat[lowKey],entry[lowKey])
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

									else --if entry.alt and entry.alt + entry.guildBank > 0 then
										GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
										GameTooltip:ClearLines()
										GameTooltip:AddLine("Recipe Craftability",1,1,1,true)
										GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

										local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

										local inventoryIndex = GnomeWorksDB.config.inventoryIndex

										local prevCount = 0
										for i,key in pairs(inventoryIndex) do
											if key ~= "guildBank" or checkGuildBank then
												local count = entry[key] or 0

												if count > prevCount then
													GameTooltip:AddDoubleLine(GnomeWorks.system.inventoryTags[key],GnomeWorks.system.inventoryColors[key]..(count-prevCount))
													prevCount = count
												end


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
				return (a.totalInventory or 0) - (b.totalInventory or 0)
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

							local inventoryIndex = GnomeWorksDB.config.inventoryIndex

							local display = ""
							local low, hi
							local lowKey, hiKey
							local lowValue, hiValue

							if entry.inventory then
								for k,inv in ipairs(inventoryIndex) do
									local value = entry.inventory[inv]
									if (value or 0) >0 then
										low = k
										lowKey = inv
										lowValue = value
										break
									end
								end

								if low then
									for i=#inventoryIndex,low+1,-1 do
										local key = inventoryIndex[i]

										if (entry.inventory[key] or 0) > 0 then
											hi = i
											hiKey = key
											hiValue = entry.inventory[key]
											break
										end
									end

									if hi then
										local lowString = string.format(GnomeWorks.system.inventoryFormat[lowKey],lowValue)
										local hiString = string.format(GnomeWorks.system.inventoryFormat[hiKey],hiValue)

										display = lowString.."+"..hiString
									else
										display = string.format(GnomeWorks.system.inventoryFormat[lowKey],lowValue)
									end
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
									if (entry.totalInventory or 0) > 0 then
										GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
										GameTooltip:ClearLines()
										GameTooltip:AddLine("Recipe Craft Results",1,1,1,true)
										GameTooltip:AddLine(GnomeWorks.player.."'s inventory")

										local itemID = entry.itemID

										local prev = 0
										local checkGuildBank = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

										local inventoryIndex = GnomeWorksDB.config.inventoryIndex

										for i,key in ipairs(inventoryIndex) do
											if key ~= "vendor" and (key ~= "guildBank" or checkGuildBank) then
												local count = entry.inventory[key] or 0

												if count ~= 0 then
													GameTooltip:AddDoubleLine(GnomeWorks.system.inventoryTags[key],GnomeWorks.system.inventoryColors[key]..count)
												end

												prev = count
											end
										end

										if GnomeWorksDB.config.inventoryTracked.alt and entry.inventory.alt>0 then
											GameTooltip:AddLine("    ")

											GameTooltip:AddLine("alt item locations:",.8,.8,.8)
											for player, containers in pairs(GnomeWorks.data.inventoryData) do
												if player ~= GnomeWorks.player then
													for i,key in ipairs(inventoryIndex) do
														if key ~= "vendor" and key ~= "guildBank" and key ~= "alt" then
															local count = containers[key][itemID]

															if count and count > 0 then
																GameTooltip:AddDoubleLine("   "..GnomeWorks.system.inventoryColors.alt..player.."/"..key,GnomeWorks.system.inventoryColors.alt..count)
															end
														end
													end

												end
											end

											local playerGuild = GnomeWorks.data.playerData[GnomeWorks.player] and GnomeWorks.data.playerData[GnomeWorks.player].guild

											for guild,guildInventoryData in pairs(GnomeWorks.data.guildInventory) do
												if guild ~= playerGuild then
													for tab,tabData in ipairs(guildInventoryData) do
														if tabData[itemID] then
															if tabData[itemID] > 0 then
																GameTooltip:AddDoubleLine("   "..GnomeWorks.system.inventoryColors.alt..guild.."/tab"..tab,GnomeWorks.system.inventoryColors.alt..tabData[itemID])
															end
														end
													end
												end
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

			if true or GnomeWorks.detailFrame:IsShown() then
				skillFrame:SetPoint("BOTTOMLEFT",GnomeWorks.detailFrame,"TOPLEFT",0,40)
			else
				skillFrame:SetPoint("BOTTOMLEFT",20,55)
			end
		end

		GnomeWorks:SendMessageDispatch("FrameMoved")
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
		skillFrame:SetPoint("TOP", frame, 0, -70 - GnomeWorksDB.config.displayOptions.scrollFrameLineHeight)
		skillFrame:SetPoint("RIGHT", frame, -20,0)

		sf = GnomeWorks:CreateScrollingTable(skillFrame, ScrollPaneBackdrop, columnHeaders, ResizeSkillFrame)

		skillFrame.scrollFrame = sf

		sf.selectable = true



		local function CreateEmptyGroup(scrollFrame)
			if not GnomeWorks:RecipeGroupIsLocked() then
				local player = GnomeWorks.player
				local tradeID = GnomeWorks.tradeID
				local label = GnomeWorks.groupLabel

				local name, index = GnomeWorks:RecipeGroupNewName(player..":"..tradeID..":"..label, "New Group")

				local newGroup = GnomeWorks:RecipeGroupNew(player, tradeID, label, name)

				newGroup.manualEntry = true

				local parentGroup = GnomeWorks:RecipeGroupFind(player, tradeID, label, GnomeWorks.group)

				GnomeWorks:RecipeGroupAddSubGroup(parentGroup, newGroup, index)

				GnomeWorks:SendMessageDispatch("SkillListChanged")
			end
		end

		local function CreateGroup(scrollFrame)
			if not GnomeWorks:RecipeGroupIsLocked() then
				local player = GnomeWorks.player
				local tradeID = GnomeWorks.tradeID
				local label = GnomeWorks.groupLabel

				local name, index = GnomeWorks:RecipeGroupNewName(player..":"..tradeID..":"..label, "New Group")

				local newGroup = GnomeWorks:RecipeGroupNew(player, tradeID, label, name)

				newGroup.manualEntry = true

				local parentGroup --  = GnomeWorks:RecipeGroupFind(player, tradeID, label, GnomeWorks.group)

				for entry in pairs(scrollFrame.selection) do
--					if scrollFrame.selection[scrollFrame.dataMap[i]] then
--						local entry = scrollFrame.dataMap[i]

						if not parentGroup then
							parentGroup = entry.parent
						end

						GnomeWorks:RecipeGroupMoveEntry(entry, newGroup)
--					end
				end

				GnomeWorks:RecipeGroupAddSubGroup(parentGroup, newGroup, index)

				GnomeWorks:SendMessageDispatch("SkillListChanged")
			end
		end

		local function SelectAll(scrollFrame)
			for i=1,scrollFrame.numData do
				scrollFrame.selection[scrollFrame.dataMap[i]] = true
			end

			scrollFrame:Draw()
		end

		local function DeselectAll(scrollFrame)
			table.wipe(scrollFrame.selection)

			scrollFrame:Draw()
		end

		local function CopyEntries(scrollFrame)
			if scrollFrame.copyBuffer then
				table.wipe(scrollFrame.copyBuffer)
			else
				scrollFrame.copyBuffer = {}
			end

			for i=1,scrollFrame.numData do
				if scrollFrame.selection[scrollFrame.dataMap[i]] == true then
					scrollFrame.copyBuffer[#scrollFrame.copyBuffer+1] = scrollFrame.dataMap[i]
				end
			end
		end


		local function PasteEntries(scrollFrame)
			if not GnomeWorks:RecipeGroupIsLocked() and scrollFrame.copyBuffer then
				local entry

				for i=1,scrollFrame.numData do
					if scrollFrame.selection[scrollFrame.dataMap[i]] == true then
						entry = scrollFrame.dataMap[i]
						break
					end
				end

				local parentGroup = entry.subGroup or entry.parent

				for index,pasteEntry in ipairs(scrollFrame.copyBuffer) do
					GnomeWorks:RecipeGroupPasteEntry(pasteEntry, parentGroup)
				end

				GnomeWorks:SendMessageDispatch("SkillListChanged")
			end
		end



		local function DeleteEntries(scrollFrame)
			if not GnomeWorks:RecipeGroupIsLocked() then
				for entry,value in pairs(scrollFrame.selection) do
					if value then
						GnomeWorks:RecipeGroupDeleteEntry(entry)
					end
				end


--				self:RecipeGroupAddSubGroup(parentGroup, newGroup, index)

				GnomeWorks:SendMessageDispatch("SkillListChanged")
			end
		end

		sf:EnableKeyboardInput()

		sf:RegisterKeyboardInput("N", CreateEmptyGroup)
		sf:RegisterKeyboardInput("G", CreateGroup)
		sf:RegisterKeyboardInput("A", SelectAll)
		sf:RegisterKeyboardInput("D", DeselectAll)
		sf:RegisterKeyboardInput("C", CopyEntries)
		sf:RegisterKeyboardInput("V", PasteEntries)
		sf:RegisterKeyboardInput("X", function(f) CopyEntries(f) DeleteEntries(f) end )
		sf:RegisterKeyboardInput("DELETE", DeleteEntries)
		sf:RegisterKeyboardInput("BACKSPACE", DeleteEntries)


		sf.IsEntryFiltered = function(self, entry)
			if not GnomeWorksDB.config.displayOptions.trainingMode then
				local difficulty = GnomeWorks:GetRecipeDifficulty(entry.recipeID)

				if difficulty > 4 then
					return true
				end
			end

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

			if not entry.iconList then
				entry.iconList = {}
			end

			local inventoryIndex = GnomeWorksDB.config.inventoryIndex

			if not entry.subGroup then
				local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID, player)

				if next(reagents) then
					local onHand = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player)

					local totalCraftable = 0
					for inv,isTracked in pairs(GnomeWorksDB.config.inventoryTracked) do
						if isTracked then
							local iterations = GnomeWorks:InventoryRecipeIterations(entry.recipeID, player, inv)

							entry[inv] = iterations

							if iterations > totalCraftable then
								totalCraftable = iterations
							end
						end
					end

					if onHand > 0 then
						entry.craftable = onHand
					else
						entry.craftable = nil
					end

					entry.totalCraftable = totalCraftable
				else
					for inv,isTracked in pairs(GnomeWorksDB.config.inventoryTracked) do
						if isTracked then
							entry[inv] = 0
						end
					end

					entry.craftable = nil

					if tradeID == 53428 then
						entry.craftable = 1
					end
				end


				if entry.index > 0 and entry.recipeID then
					if GetTradeSkillLine() == GetSpellInfo(GnomeWorks:GetRecipeTradeID(entry.recipeID)) then
						entry.index = GnomeWorks:FindRecipeSkillIndex(entry.recipeID) or -entry.recipeID
					end
				end

				entry.cooldown = GnomeWorks:GetTradeSkillCooldown(entry.index)

				if entry.cooldown then
					entry.iconList.cooldown = "Interface\\Icons\\INV_Misc_PocketWatch_01"
				else
					entry.iconList.cooldown = nil
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


				local inventoryIndex = GnomeWorksDB.config.inventoryIndex


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
								entry.inventory[inv] = GnomeWorks:GetFactionInventoryCount(itemID, player)
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

		if IsTradeSkillGuild() then
			GnomeWorks.queryCraftersButton:Show()
		else
			GnomeWorks.queryCraftersButton:Hide()
		end

		GnomeWorks:UpdateTradeButtons(player,tradeID)
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

		GnomeWorks:SendMessageDispatch("SelectionChanged")

		GnomeWorks:ScheduleTimer("ShowStatus",.1)
--		GnomeWorks:ShowStatus()
	end


	function GnomeWorks:DoTradeSkillUpdate()
		self.updateTimer = nil

		if frame:IsVisible() then
			self:ScanTrade()
		end
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

			if GnomeWorks.selectedEntry then
				local recipeID = GnomeWorks.selectedEntry.recipeID

				if recipeID then
--					GnomeWorks:RegisterMessageDispatch("TradeScanComplete", function() GnomeWorks:DoRecipeSelection(recipeID) return true end, "SelectRecipe")			-- return true = fire once
				end
			end

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

			local groupLabel, group

			if IsTradeSkillLinked() or IsTradeSkillGuild() then
				groupLabel, group = string.split("/",GnomeWorksDB.config.currentGroup.alt[tradeID] or "")
			else
				groupLabel, group = string.split("/",GnomeWorksDB.config.currentGroup.self[tradeID] or "")
			end

			local player, tradeID, label, groupName = self:RecipeGroupValidate(player, tradeID, groupLabel or "By Category", group)
--print( player, tradeID, label, groupName)

			local group = self:RecipeGroupFind(player, tradeID, label, groupName)


			self.group = groupName
			self.groupLabel = label

			local groupLabel = label

			if groupName then
				groupLabel = groupLabel.."/"..groupName
			end

			if groupLabel then
				UIDropDownMenu_SetText(GnomeWorksGrouping, "Group |cffc0ffc0"..groupLabel)
			else
				UIDropDownMenu_SetText(GnomeWorksGrouping, "|cffff0000--")
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


	function GnomeWorks:ShowStatus()
		local rank, maxRank, estimatedSkillUp = self:GetTradeSkillRank(self.player)


		self.levelStatusBar:SetMinMaxValues(0,maxRank)
		self.levelStatusBar:SetValue(rank)
		self.levelStatusBar.estimatedLevel:SetMinMaxValues(0,maxRank)

--		self.levelStatusBar:Show()


		if estimatedSkillUp then
			self.levelStatusBar.estimatedLevel:SetValue(estimatedSkillUp)
		else
			self.levelStatusBar.estimatedLevel:SetValue(rank)
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

		if self.showTimer then
			self:CancelTimer(self.showTimer, true)
		end

		self.showTimer = self:ScheduleTimer(function() self.showTimer = nil GnomeWorks:SendMessageDispatch("SkillListChanged") end, .5)

--		self:SendMessageDispatch("SkillListChanged")
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

		local function SelectGuildTradeSkill(menuFrame, skillID)
			ToggleDropDownMenu(1, nil, playerSelectMenu, menuFrame, menuFrame:GetWidth(), 0)
			ViewGuildRecipes(skillID)
		end


		local function OpenGuildRoster()
			ShowUIPanel(GuildFrame)
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

				local guildName = GetGuildInfo("player")

				if guildName then
					playerMenu.text = "|cff80ff80"..guildName

					playerMenu.hasArrow = true

--					playerMenu.func = OpenGuildRoster

					playerMenu.value = "GUILD:"..guildName
					playerMenu.disabled = false
					playerMenu.notCheckable = 1

					UIDropDownMenu_AddButton(playerMenu)
					index = index + 1

					QueryGuildRecipes()
				end
			end

			if (level == 2) then  -- skills per player
				if string.find(UIDROPDOWNMENU_MENU_VALUE,"GUILD:") then
					local skillButton = {}

					QueryGuildRecipes()

					local numTradeSkill = GetNumGuildTradeSkill()

					for i = 1, numTradeSkill do
						local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, class, online, zone, skill, classFileName = GetGuildTradeSkillInfo(i)


						if not playerName and CanViewGuildRecipes(skillID) then
							skillButton.text = headerName -- .."["..skill.."]"
							skillButton.value = skillID

							skillButton.icon = iconTexture

							skillButton.arg1 = skillID
							skillButton.func = SelectGuildTradeSkill

							skillButton.disabled = false

							UIDropDownMenu_AddButton(skillButton, level)
						end
					end
				else
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


		local function MarerialsSomewhere(button)
			local entry = GnomeWorks.selectedEntry

			if entry then
				if entry.totalCraftable and entry.totalCraftable >= 1 then
					button:Enable()
					return
				end
			end

			button:Disable()
		end


		local function CheckModifierKey(button)
			if IsShiftKeyDown() then
				button:SetText("Queue+")
			else
				button:SetText("Queue")
			end
		end


		local function Create(button)
			local numItems = dataTable[button.setting]
			local entry = GnomeWorks.selectedEntry

			EditBox_ClearFocus(buttons.queueCountButton)

			if numItems then
				DoTradeSkill(GnomeWorks.selectedSkill, numItems)
			else
				if entry.craftable then
					DoTradeSkill(GnomeWorks.selectedSkill, entry.craftable)
				end
			end
		end


		local function AddEntryToQueue(entry, count)
			if entry then
				if entry.subGroup then
					for i=1,entry.subGroup.numData or #entry.subGroup.entries do
						AddEntryToQueue(entry.subGroup.entries[i],count)
					end
				else
					GnomeWorks:AddToQueue(GnomeWorks.player, GnomeWorks.tradeID, entry.recipeID, count)
				end
			end
		end


		local function AddToQueue(button)
			local numItems = dataTable[button.setting]
			local entry = GnomeWorks.selectedEntry

			EditBox_ClearFocus(buttons.queueCountButton)

			GnomeWorks:ShowQueueList()

			if not numItems then
				local results, reagents = GnomeWorks:GetRecipeData(entry.recipeID)

				local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(next(results))

				if entry.totalCraftable < 1 then
					numItems = itemStackCount
				else
					for k,inv in ipairs(GnomeWorksDB.config.inventoryIndex) do
						if entry[inv] and entry[inv]>0 then
							numItems = entry[inv]
							break
						end
					end
				end


				if numItems == LARGE_NUMBER then
					numItems = itemStackCount
				end


				if entry then
					GnomeWorks:AddToQueue(GnomeWorks.player, GnomeWorks.tradeID, entry.recipeID, numItems)
				end
			elseif not IsShiftKeyDown() then
				if entry then
					GnomeWorks:AddToQueue(GnomeWorks.player, GnomeWorks.tradeID, entry.recipeID, numItems)
				end
			else
				for entry in pairs(scrollFrame.selection) do
					AddEntryToQueue(entry,numItems)
				end
			end
		end




		local buttonConfig = {
			{ text = "Create", operation = Create, width = 50, setting = "queueCount", validate = MaterialsOnHand },
			{ text = "Queue", operation = AddToQueue, setting = "queueCount", width = 50, validate = CheckModifierKey },
			{ style = "EditBox", setting = "queueCount", width = 50, default = 1, name = "queueCountButton"},
			{ text = "Create All", operation = Create, width = 70, validate = MaterialsOnHand },
			{ text = "Queue All", operation = AddToQueue, width = 70, validate = MaterialsSomewhere },
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


		GnomeWorks:RegisterMessageDispatch("SelectionChanged HeartBeat ModifierStateChange", function()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end,"ConfigureCraftingButtons")

		return controlFrame
	end


	local function CreateOptionButtons(frame)
		local dataTable = {}
		local layoutMode


		local function PopRecipe()
			GnomeWorks:PopSelection()
		end


		local ShowPlugins do
			local function InitMenu(menuFrame, level, menuList)
				if (level == 1) then  -- plugins
					local title = {}
					local button = {}

					title.text = "Plugins"
					title.fontObject = "GameFontNormal"
					title.notCheckable = true

					UIDropDownMenu_AddButton(title)

					local count = 0

					for name,data in pairs(GnomeWorks.plugins) do
						if data.loaded then
							button.text = name
							button.hasArrow = #data.menuList>0
							button.menuList = data.menuList
							button.disabled = false
							button.notCheckable = true

							UIDropDownMenu_AddButton(button)
							count = count + 1
						end
					end

					if count == 0 then
						button.text = "No Plugins Found"
						button.disabled = true
						button.notCheckable = true

						UIDropDownMenu_AddButton(button)
					end
				elseif (level or 0) > 1 then
--					local menuList = UIDROPDOWNMENU_MENU_VALUE

					if type(menuList) == "table" then
						for index = 1, #menuList do
							local button = menuList[index]
							if type(button) == "table" then
								if (button.text) then
									button.index = index
									button.value = button.menuList
									UIDropDownMenu_AddButton( button, level )
								end
							end
						end
					elseif type(menuList) == "function" then		-- if menuList is a function, then call it to add buttons
						menuList(menuFrame, level)
					end

--					for index, button in ipairs(UIDROPDOWNMENU_MENU_VALUE) do
--						UIDropDownMenu_AddButton(button, level)
--					end
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


		local ShowOptions do
			local function InitMenu(menuFrame, level, menuList)
				if (level == 1) then  -- options
					local title = {}
					local button = {}

					title.text = "Options"
					title.fontObject = "GameFontNormal"
					title.notCheckable = true

					UIDropDownMenu_AddButton(title)

					local count = 0

					for name,data in pairs(GnomeWorks.options) do
						if data.loaded then
							button.text = name
							button.hasArrow = #data.menuList>0
							button.menuList = data.menuList
							button.disabled = false
							button.notCheckable = true

							UIDropDownMenu_AddButton(button)
							count = count + 1
						end
					end

					if count == 0 then
						button.text = "No Options Found"
						button.disabled = true
						button.notCheckable = true

						UIDropDownMenu_AddButton(button)
					end
				elseif (level or 0) > 1 then
--					local menuList = UIDROPDOWNMENU_MENU_VALUE

					if type(menuList) == "table" then
						for index = 1, #menuList do
							local button = menuList[index]
							if type(button) == "table" then
								if (button.text) then
									button.index = index
									button.value = button.menuList
									UIDropDownMenu_AddButton( button, level )
								end
							end
						end
					elseif type(menuList) == "function" then		-- if menuList is a function, then call it to add buttons
						menuList(menuFrame, level)
					end

--					for index, button in ipairs(UIDROPDOWNMENU_MENU_VALUE) do
--						UIDropDownMenu_AddButton(button, level)
--					end
				end
			end

			function ShowOptions(frame)
				if not optionsMenu then
					optionsMenu = CreateFrame("Frame", "GWOptionMenu", UIParent, "UIDropDownMenuTemplate")
				end

				UIDropDownMenu_Initialize(optionsMenu, InitMenu, "MENU")
				ToggleDropDownMenu(1, nil, optionsMenu, frame, 0, 0)
			end
		end


		local function ToggleLayoutMode()
			CloseDropDownMenus()

			layoutMode = not layoutMode

			for k,f in ipairs(GnomeWorks.scrollFrameList) do
				if not layoutMode then
					f.controlOverlay:Hide()
				else
					f.controlOverlay:Show()
				end
			end
		end

		local b = GnomeWorks.options["Display Options"]:AddButton("Edit Layout", ToggleLayoutMode)
		b.notCheckable = true

		local buttons = {}


		local buttonConfig = {
			{ text = "Back", operation = PopRecipe, width = 50 },
			{ text = "Options", operation = ShowOptions, width = 60 },
			{ text = "Plugins", operation = ShowPlugins, width = 60 },
		}


		controlFrame = CreateFrame("Frame", nil, frame)

		controlFrame:SetHeight(20)
		controlFrame:SetWidth(200)

		controlFrame:SetPoint("TOPRIGHT", GnomeWorks.skillFrame, "BOTTOMRIGHT", 0, -2)

		local position = CreateButtons(buttonConfig, buttons, dataTable)

		controlFrame:SetWidth(position)

		GnomeWorks:RegisterMessageDispatch("SelectionChanged", function()
--			sf:Draw()
			for i, b in pairs(buttons) do
				if b.validate then
					b:validate()
				end
			end
		end,"ConfigureUIButtons")

		return controlFrame
	end


	local function CreateControlFrame(parent)
		local frame = CreateFrame("Frame",nil,parent)

		frame.QueueButtons = CreateQueueButtons(frame)
		frame.OptionButtons = CreateOptionButtons(frame)

		return frame
	end



	local function QueryGuildCrafters()
		QueryGuildMembersForRecipe()
	end


	local function InitToolTip(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_NONE")
		GameTooltip:ClearLines()


		local spaceLeft = frame:GetLeft()
		local spaceRight = GetScreenWidth() - sf:GetRight()

		if spaceRight > spaceLeft then
			GameTooltip:SetPoint("TOPLEFT",frame, "TOPRIGHT")
		else
			GameTooltip:SetPoint("TOPRIGHT",frame, "TOPLEFT")
		end
	end


	local function ShowGuildCrafters()
		InitToolTip(GnomeWorks.queryCraftersButton)

		local skillLineID, recipeID, numMembers = GetGuildRecipeInfoPostQuery()

		if recipeID and recipeID == GnomeWorks.selectedEntry.recipeID then
			GameTooltip:AddLine(GetSpellLink(recipeID))

			for i = 1, numMembers, 1 do
				local name, online = GetGuildRecipeMember(i)

				GameTooltip:AddDoubleLine("|cffffffff"..name, online and "|cff00ff00ONLINE" or "|cffff0000OFFLINE")
			end
		else
			GameTooltip:AddLine("Click to Query")
		end

		GameTooltip:Show()
	end


	local function HideGuildCrafters()
		GameTooltip:Hide()
	end



	function GnomeWorks:GUILD_RECIPE_KNOWN_BY_MEMBERS()
		ShowGuildCrafters()
	end


	function GnomeWorks:CreateMainWindow()
--[[
		for i=1,128 do
			local f = CreateFrame("Frame",nil,UIParent)
			f:SetSize(200,200)
			f:SetPoint("CENTER",0,0)
			f:SetBackdrop({
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 12, right = 10, top = 10, bottom = 10 }
			})

			print(i, f:GetFrameLevel())

			f:SetFrameLevel(i)
		end
]]

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

--function UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
		UIDropDownMenu_SetAnchor(groupSelection, 0,20, "TOPRIGHT", "GnomeWorksGroupingMiddle","BOTTOMRIGHT")

		groupSelection:SetScript("OnShow", function(dropDown) GnomeWorks:RecipeGroupDropdown_OnShow(dropDown) end)

		GnomeWorks:RegisterMessageDispatch("TradeScanComplete", function() GnomeWorks:RecipeGroupDropdown_OnShow(groupSelection) end)



		local groupOperations = CreateFrame("Button", "GnomeWorksGroupOps", groupSelection)

		groupOperations:SetPoint("LEFT",GnomeWorksGroupingMiddle,"RIGHT",6,2)
		groupOperations:SetWidth(28)
		groupOperations:SetHeight(28)

		groupOperations:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
		groupOperations:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
		groupOperations:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round")

		groupOperations:SetScript("OnClick", GnomeWorks.RecipeGroupOperations_OnClick)




		local levelBackDrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 12, right = 12, top = 12, bottom = 12 }
			}



		local estimatedLevel = CreateFrame("StatusBar", "GWEstimatedRank", frame)
		local level = CreateFrame("StatusBar", "GWRank", estimatedLevel)


		level:SetAllPoints(estimatedLevel)


		estimatedLevel:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-20,-34)
		estimatedLevel:SetPoint("LEFT",tradeButtonFrame)
		estimatedLevel:SetHeight(8)

		estimatedLevel:SetOrientation("HORIZONTAL")
		estimatedLevel:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		estimatedLevel:SetStatusBarColor(.05,.5,1,1)

--		estimatedLevel:SetMinMaxValues(1,75)
--		estimatedLevel:SetValue(75)


		level:SetOrientation("HORIZONTAL")
		level:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		level:SetStatusBarColor(.05,.05,.75,1)

--		level:SetMinMaxValues(1,75)
--		level:SetValue(75)



		self.Window:SetBetterBackdrop(estimatedLevel, levelBackDrop)
		self.Window:SetBetterBackdropColor(estimatedLevel, 1,1,1,.5)

		local levelText = level:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		levelText:SetPoint("LEFT",0,1)
		levelText:SetHeight(13)
		levelText:SetPoint("RIGHT",0,1)
		levelText:SetJustifyH("CENTER")

		level.text = levelText

		level.estimatedLevel = estimatedLevel
		estimatedLevel.level = level


		estimatedLevel:HookScript("OnValueChanged", function(frame, value)
			local minValue, maxValue = frame:GetMinMaxValues()
			local level = frame.level:GetValue()

			if value/maxValue > .5 then
				levelText:SetJustifyH("LEFT")
			else
				levelText:SetJustifyH("RIGHT")
			end

			if value ~= level then
				levelText:SetFormattedText("  %d(+%d)/%d  ",level,value-level,maxValue)
			else
				levelText:SetFormattedText("  %d/%d  ",level,maxValue)
			end
		end)


		level:HookScript("OnValueChanged", function(frame, value)
			local minValue, maxValue = frame:GetMinMaxValues()

			if value/maxValue > .5 then
				levelText:SetJustifyH("LEFT")
			else
				levelText:SetJustifyH("RIGHT")
			end

			levelText:SetFormattedText("  %d/%d  ",value,maxValue)
		end)


		self.levelStatusBar = level




		local playerName = CreateFrame("Button", nil, frame)

		playerName:SetPoint("LEFT",tradeButtonFrame)
		playerName:SetWidth(rightSideWidth)
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




--		local queryCrafters = CreateFrame("Button", nil, frame)

		local queryCrafters = GnomeWorks:CreateButton(frame, 22)


		queryCrafters:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20,-44)
		queryCrafters:SetPoint("LEFT", playerName, "LEFT", 0,0)
--		queryCrafters:SetHeight(18)
		queryCrafters:SetText(GUILD_TRADE_SKILL_VIEW_CRAFTERS)
--		queryCrafters:SetJustifyH("RIGHT")

		queryCrafters:SetNormalFontObject("GameFontNormal")
		queryCrafters:SetHighlightFontObject("GameFontHighlight")


		queryCrafters:EnableMouse(true)

		queryCrafters:RegisterForClicks("AnyUp")

		queryCrafters:SetScript("OnClick", QueryGuildCrafters)
		queryCrafters:SetScript("OnEnter", ShowGuildCrafters)
		queryCrafters:SetScript("OnLeave", HideGuildCrafters)

		queryCrafters:SetFrameLevel(playerName:GetFrameLevel()+1)

		self.queryCraftersButton = queryCrafters

		queryCrafters:Hide()




		self.SelectTradeLink = SelectTradeLink


		table.insert(UISpecialFrames, "GnomeWorksFrame")

		frame:HookScript("OnShow", function() PlaySound("igCharacterInfoOpen") end)
		frame:HookScript("OnHide", function() if frame:IsVisible() then PlaySound("igCharacterInfoClose") end CloseTradeSkill() end)


		self:RegisterMessageDispatch("TradeScanComplete InventoryScanComplete", ScanComplete, "ShowMainWindow")

		self:RegisterMessageDispatch("SkillListChanged SkillRanksChanged", function()
			self:ShowSkillList()

			self:SendMessageDispatch("SelectionChanged")
		end, "ShowSkillList")


		self:RegisterMessageDispatch("SelectionChanged", function()
			sf:Draw()
		end, "SkillListDraw")

		self:RegisterMessageDispatch("SkillRanksChanged", function()
			self:ShowStatus()
		end, "ShowStatus")




		return frame
	end

end
