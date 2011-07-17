

-- over achiever plugin.  mostly taken from overachiever tradeskill module
do
	local plugin

	local function RegisterWithOverAchiever()
		if not Overachiever then return end

		local L = OVERACHIEVER_STRINGS
		local GetAchievementInfo = Overachiever.GetAchievementInfo
--		local LBI = LibStub:GetLibrary("LibBabble-Inventory-3.0"):GetReverseLookupTable()

		local TradeSkillLookup = {}

		do
			local TradeSkillAch = {
				[2550] = {
					GourmetNorthrend = true,
					GourmetOutland = true,
					GourmetCataclysm = true,
				}
			}

			local lookup, id, name, _, completed

			for tradeID, list in pairs(TradeSkillAch) do
				TradeSkillLookup[tradeID] = {}
				lookup = TradeSkillLookup[tradeID]

				for ach in pairs(list) do
					id = OVERACHIEVER_ACHID[ach]

					for i=1,GetAchievementNumCriteria(id) do
						name, _, completed = GetAchievementCriteriaInfo(id, i)

						if (not completed) then
							lookup[name] = lookup[name] or {}
							lookup[name][id] = i
						end
					end
				end
			end

			TradeSkillAch = nil

			local function renameObjective(tab, line, ...)
				if (line) then
					local old, new = strsplit("=", line)

					if (new and tab[old]) then
						tab[new] = tab[old]
						tab[old] = nil
					end

					renameObjective(tab, ...)
				end
			end

--[[
			if (L.TRADE_COOKING_OBJRENAME) then
				renameObjective( TradeSkillLookup.Cooking, strsplit("\n", L.TRADE_COOKING_OBJRENAME) )
			end
]]
			renameObjective = nil
		end


		local list

		local function TradeSkillCheck(tradeID, name, getList)
			local lookup = TradeSkillLookup[tradeID][name]

			if (lookup) then
				local anyIncomplete

				if (getList) then
					list = list and wipe(list) or {}
				end

				for id,i in pairs(lookup) do
					_, _, completed = GetAchievementCriteriaInfo(id, i)

					if (completed) then
						lookup[id] = nil
					else
						if (not getList) then
							return id
						end

						anyIncomplete = true
						list[#list+1] = id
					end
				end

				if (anyIncomplete) then
					return list
				end
			end
		end


		local icons, highlights = {}
		local currentButton

		local ExamineTradeSkillUI

		local skillButtonOnEnter

		local function skillButtonOnLeave()
			currentButton = nil
			GameTooltip:Hide()
		end

		local function skillButtonOnClick(self)
			if (IsControlKeyDown()) then
				local icon = icons[self]
				if (icon.name) then
					local id = TradeSkillCheck(LBI[GetTradeSkillLine()], icon.name)
					if (id) then  Overachiever.OpenToAchievement(id);  end
				end
			end
		end

		local function GetIcon(skillButton)
			  local icon = icons[skillButton]
			  if (icon) then  return icon;  end
			  icon = skillButton:CreateTexture(nil, "OVERLAY")
			  icon:SetTexture("Interface\\AddOns\\Overachiever\\AchShield")
			  icon:SetWidth(12)
			  icon:SetHeight(12)
			  icon:SetPoint("LEFT", skillButton, "LEFT", 7, 0)
			  icons[skillButton] = icon

			  local highlight = skillButton:CreateTexture(nil, "HIGHLIGHT")
			  highlight:SetTexture("Interface\\AddOns\\Overachiever_Trade\\AchShieldGlow")
			  highlight:SetWidth(12)
			  highlight:SetHeight(12)
			  highlight:SetPoint("CENTER", icon, "CENTER")
			  highlights = highlights or {}
			  highlights[icon] = highlight

			  -- Tooltip handling:
			  local prev = skillButton:GetScript("OnEnter")

			  if (prev) then
					skillButton:HookScript("OnEnter", skillButtonOnEnter)
			  else
					skillButton:SetScript("OnEnter", skillButtonOnEnter)
			  end
			  prev = skillButton:GetScript("OnLeave")

			  if (prev) then
					skillButton:HookScript("OnLeave", skillButtonOnLeave)
			  else
					skillButton:SetScript("OnLeave", skillButtonOnLeave)
			  end

			  -- OnClick hook:
			  skillButton:HookScript("OnClick", skillButtonOnClick)

			  if (skillButton:IsMouseOver()) then
					currentButton = skillButton  -- Causes ExamineTradeSkillUI to trigger skillButtonOnEnter.
			  end

			  return icon
		end

		-- ---------- End addon support section. ----------


		local function UpdateData(scrollFrame, entry)
			local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

			entry.achievementID = nil

			if TradeSkillLookup[tradeID] then
				local recipeAchievementList = TradeSkillLookup[tradeID][GnomeWorks:GetRecipeName(entry.recipeID)]

				if recipeAchievementList then
					for achievementID, i in pairs(recipeAchievementList) do

						local _,_,completed = GetAchievementCriteriaInfo(achievementID, i)

						if not completed then
							entry.achievementID = achievementID
							break
						end
					end
				end
			end

			if entry.achievementID then
				local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Icon, RewardText = GetAchievementInfo(entry.achievementID)


				entry.iconList.achievementID = Icon --  "Interface\\AddOns\\Overachiever\\AchShield"
			else
				entry.iconList.achievementID = nil
			end
		end



		local function Init()
			local GWFrame = GnomeWorks:GetMainFrame()
			local GWScrollFrame = GnomeWorks:GetSkillListScrollFrame()
			local recipeFilterMenu = GWScrollFrame.filterMenu

			local GWDetailFrame = GnomeWorks:GetDetailFrame()

			local FilterMenu = {} do
				local SubMenu = {
				}

				local FilterParameters = {
					{
						name = "OverAchiever",
						text = "OverAchiever: Filter by Achievement",
						enabled = false,
						func = function(entry)
							if entry and entry.achievementID then
								return false
							end

							return true
						end,
					},
				}

				GnomeWorks:CreateFilterMenu(FilterParameters, FilterMenu, GWScrollFrame.columnHeaders[2])


				for k,v in pairs(FilterMenu) do
					table.insert(GWScrollFrame.columnHeaders[2].filterMenu, v)
				end
			end


			local leftInfoText, rightInfoText



			GWDetailFrame:RegisterInfoFunction(function(index,recipeID,left,right)
				if plugin.enabled and recipeID then
					local addedData


					local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)


					if TradeSkillLookup[tradeID] then
						local recipeAchievementList = TradeSkillLookup[tradeID][GnomeWorks:GetRecipeName(recipeID)]

						leftInfoText = left .. "|TInterface\\AddOns\\Overachiever_Trade\\AchShieldGlow:0|t |cffffd100" .. L.REQUIREDFORMETATIP .. "|cffffffff\n"
						rightInfoText = right .. "\n"

						if recipeAchievementList then
							for id in pairs(recipeAchievementList) do
								local _,name,_,completed = GetAchievementInfo(id)

								leftInfoText = leftInfoText .. name .. "\n"
								rightInfoText = rightInfoText .. "\n"

								addedData = true
							end
						end
					end

					if addedData then
						return leftInfoText, rightInfoText
					else
						return left, right
					end
				end
			end)


			scrollFrame = GnomeWorks:GetSkillListScrollFrame()

			scrollFrame:RegisterRowUpdate(UpdateData, plugin)


			hooksecurefunc(GameTooltip,"SetHyperlink", function(self, link)
				if plugin.enabled and scrollFrame:IsVisible() then
					local recipeID = string.match(link,"spell:(%d+)") or string.match(link,"enchant:(%d+)")

					if recipeID then
						recipeID = tonumber(recipeID)

						local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

						if TradeSkillLookup[tradeID] then
							local recipeAchievementList = TradeSkillLookup[tradeID][GnomeWorks:GetRecipeName(recipeID)]

							if recipeAchievementList then
								local addLines

								for achievementID, i in pairs(recipeAchievementList) do

									local _,name,_,completed = GetAchievementInfo(achievementID)

									if not completed then
										addLines = true
									end
								end

								if addLines then
									GameTooltip:AddLine(" ")
									GameTooltip:AddLine(L.REQUIREDFORMETATIP)
									for achievementID, i in pairs(recipeAchievementList) do

										local _,name,_,completed = GetAchievementInfo(achievementID)

										if not completed then
											GameTooltip:AddLine(name, 1, 1, 1)
										end
									end
								end
							end
						end
					end
				end
			end)


			local function togglePlugin()
				plugin.enabled = not plugin.enabled
			end

			local button = plugin:AddButton("Enabled", togglePlugin)

			button.checked = function() return plugin.enabled end
		end


		Init()

		return true
	end

	plugin = GnomeWorks:RegisterPlugin("OverAchiever", RegisterWithOverAchiever)

end


