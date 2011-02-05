
-- Skill Up plugin Interface
do
	local plugin

	local libPT

	local scrollFrame

	local rank, maxRank, estimatedRank


	local skillColors = {
		["unknown"]			= { r = 1.00, g = 0.00, b = 0.00, level = 5, alttext="???", cstring = "|cffff0000"},
		["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25, level = 4, alttext="+++", cstring = "|cffff8040"},
		["medium"]          = { r = 1.00, g = 1.00, b = 0.00, level = 3, alttext="++",  cstring = "|cffffff00"},
		["easy"]            = { r = 0.25, g = 0.75, b = 0.25, level = 2, alttext="+",   cstring = "|cff40c000"},
		["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50, level = 1, alttext="",    cstring = "|cff808080"},
		["header"]          = { r = 1.00, g = 0.82, b = 0,    level = 0, alttext="",    cstring = "|cffffc800"},
	}

	local function Register()
		local function GetSkillLevels(id)
			return RecipeSkillLevels[1][id] or 0, RecipeSkillLevels[2][id] or 0, RecipeSkillLevels[3][id] or 0, RecipeSkillLevels[4][id] or 0
		end


		local function GetSkillLevelColor(id, rank)
			if not id then return skillColors["unknown"] end

			local orange, yellow, green, gray = GetSkillLevels(id)

			if rank >= gray then return skillColors["trivial"] end

			if rank >= green then return skillColors["easy"] end

			if rank >= yellow then return skillColors["moderate"] end

			if rank >= orange then return skillColors["optimal"] end

			return skillColors["unknown"]
		end


		local function GetSkillUpChance(id, rank)
			local orange, yellow, green, gray  = GetSkillLevels(id)

			if rank < orange or rank >= gray then
				return 0
			elseif rank < yellow then
				return 1
			elseif rank >= yellow and rank < green then

				local chance =  1-(rank-yellow+1)/(green-yellow+1)*.5

				return chance
			else
				local chance = (1-(rank-green+1)/(gray-green+1))*.5

				return chance
			end
		end




--[[
		local costFilterMenu = {
		}

		local costFilterParameters = {
			{
				name = "HideUnprofitable",
				text = "Hide Unprofitable",
				enabled = false,
				func = function(entry)
					return (entry.value or 0) < (entry.cost or 0)
				end,
			},
		}
]]


		local function ColumnControl(cellFrame,button,source)
			local filterMenuFrame = GnomeWorksMenuFrame
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

		local function ColumnTooltip(cellFrame, text)
			GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(text,1,1,1,true)

			GameTooltip:AddLine("Left-click to Sort")
--			GameTooltip:AddLine("Right-click to Adjust Filterings")

			GameTooltip:Show()
		end


		local skillUpColumnHeader = {
			name = "Skill Up",
			width = 50,
			headerAlign = "CENTER",
			align = "RIGHT",
			font = "GameFontHighlightSmall",
	--		filterMenu = costFilterMenu,
			sortCompare = function(a,b)
				return (a.skillUp or 0) - (b.skillUp or 0)
			end,

			draw = function (rowFrame, cellFrame, entry)
				if not entry.subGroup then
					local s = entry.skillUp or 0

					cellFrame.text:SetText((math.floor(s*10000)/100).."%")

					if s == 0 then
						cellFrame.text:SetTextColor(.5,.5,.5)
					elseif s >= 1 then
						cellFrame.text:SetTextColor(1,.5,.25)
					elseif s < .5 then
						s = s*2
						cellFrame.text:SetTextColor(.25+.75*s, .75+.25*s, .25-.25*s)
					elseif s < 1 then
						s = (s-.5)*2

						cellFrame.text:SetTextColor(1, 1-.5*s, .25*s)
					end
				else
					cellFrame.text:SetTextColor(1,.82,0)
					cellFrame.text:SetText("")
				end
			end,
			OnClick = function (cellFrame, button, source)
				if cellFrame:GetParent().rowIndex>0 then
				else
					ColumnControl(cellFrame, button, source)
				end
			end,
			OnEnter = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
				else
					ColumnTooltip(cellFrame, "Skill Up Chance")
				end
			end,
			OnLeave = function (cellFrame)
				if cellFrame:GetParent().rowIndex>0 then
				else
					GameTooltip:Hide()
				end
			end,

			enabled = function()
				local realRank,maxRank,estimatedRank,bonus = GnomeWorks:GetTradeSkillRank(GnomeWorks.player, GnomeWorks.tradeID)
				rank = (estimatedRank or realRank) - (bonus or 0)

				if not plugin.enabled then
					return
				end

				if scrollFrame:IsVisible() then
					if rank and maxRank and realRank < maxRank then
						if not GnomeWorks.data.pseudoTradeData[GnomeWorks.tradeID] then
							return true
						end
					end
				end
			end,
		}



		local function UpdateData(scrollFrame, entry)
			if GnomeWorks.tradeID and GnomeWorks.player then
				local skillName, skillType = GetTradeSkillInfo(entry.index)

				if skillType ~= "header" and entry.recipeID then

					entry.skillUp = GetSkillUpChance(entry.recipeID, rank)

					if entry.skillUp == 1 then
						entry.skillUp = entry.skillUp * (GnomeWorksDB.skillUps[entry.recipeID] or 1)
					end

--[[
					local itemLink = GnomeWorks:GetTradeSkillItemLink(entry.index)

					if itemLink then
						local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

						entry.skillUp = GetSkillUpChance(itemID or -entry.recipeID, rank) * (GnomeWorksDB.skillUps[entry.recipeID] or 1)
					end
]]
				end
			end
		end


		local function Init()
	--		LSW:ChatMessage("LilSparky's Workshop plugging into Skillet (v"..Skillet.version..")");

			scrollFrame = GnomeWorks:GetSkillListScrollFrame()

			scrollFrame:RegisterRowUpdate(UpdateData, plugin)

			local skillUpColumn = scrollFrame:AddColumn(skillUpColumnHeader, plugin)

--			GnomeWorks:CreateFilterMenu(costFilterParameters, costFilterMenu, costColumnHeader)



			local function togglePlugin()
				plugin.enabled = not plugin.enabled

				scrollFrame:Refresh()
			end

			local button = plugin:AddButton("Enabled", togglePlugin)

			button.checked = function() return plugin.enabled end

		end

		Init()

		return true
	end

	plugin = GnomeWorks:RegisterPlugin("SkillUp Chance", Register, (ENABLE_COLORBLIND_MODE == "1"))

end


