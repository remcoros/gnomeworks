

-- over achiever plugin.  mostly taken from overachiever tradeskill module
do
	local plugin

	local function RegisterWithOverAchiever()
		if not Overachiever then return end

		local L = OVERACHIEVER_STRINGS
		local GetAchievementInfo = Overachiever.GetAchievementInfo
		local LBI = LibStub:GetLibrary("LibBabble-Inventory-3.0"):GetReverseLookupTable()

		local TradeSkillLookup = {}

		do
			local TradeSkillAch = {
				Cooking = {
					GourmetNorthrend = true,
					GourmetOutland = true
				}
			}

			local lookup, id, name, _, completed

			for tradeName, list in pairs(TradeSkillAch) do
				TradeSkillLookup[tradeName] = {}
				lookup = TradeSkillLookup[tradeName]

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


			if (L.TRADE_COOKING_OBJRENAME) then
				renameObjective( TradeSkillLookup.Cooking, strsplit("\n", L.TRADE_COOKING_OBJRENAME) )
			end

			renameObjective = nil
		end


		local list

		local function TradeSkillCheck(tradeName, name, getList)
			local lookup = TradeSkillLookup[tradeName][name]

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



		-- ---------- Support for other addons: ----------

		-- Skillet:
		if (Skillet) then
		  local lilsparkys = not not Skillet.version:find("LS")

		  local function sortByAchRequired(tradeName, a, b)
		-- This groups recipes that are required by the same number of achievements together. Each group is ordered according
		-- to the first achievement (by ID) that requires each recipe, sorting them first by the achievement name, then the
		-- achievement ID, then the recipe name. Recipes that are required by the most achievements go first.
			if (a and b) then
			  -- Support for lilsparky's branch:
			  if (lilsparkys) then
				a, b = a.skillIndex, b.skillIndex
				tradeName = GetTradeSkillLine()
			  end

			  local aName = GetTradeSkillInfo(a)
			  local bName = GetTradeSkillInfo(b)
			  tradeName = LBI[tradeName]

			  if (TradeSkillLookup[tradeName]) then
				-- Get number of achievements that require this recipe:
				a = TradeSkillCheck(tradeName, aName, true)
				local aNum = a and #a or 0
				if (a) then  -- This can't wait since TradeSkillCheck is going to be called again, which wipes the table.
				  sort(a)
				  a = a[1]
				end
				b = TradeSkillCheck(tradeName, bName, true)
				local bNum = b and #b or 0

				if (aNum ~= bNum) then
				  return aNum > bNum  -- Notice that we check greater-than, not less-than here.
				elseif (aNum > 0) then  -- If both are greater than zero:
				  sort(b)
				  b = b[1]
				  local aID, aV = GetAchievementInfo(a)
				  local bID, bV = GetAchievementInfo(b)
				  if (aID ~= bID) then
					if (aV ~= bV) then
					  return aV < bV
					else
					  return aID < bID
					end
				  end
				end
			  end

			  -- Fall back to names by alphabetical order:
			  return aName < bName

			else
			  return not b
			end
		  end

		  Skillet:AddRecipeSorter(L.TRADE_SKILLET_ACHSORT, sortByAchRequired)

		  local orig_get_extra = Skillet.GetExtraItemDetailText
		  Skillet.GetExtraItemDetailText = function(obj, tradeskill, skill_index)
			--print("Skillet.GetExtraItemDetailText")
			local before = orig_get_extra(obj, tradeskill, skill_index)
			tradeskill = LBI[tradeskill]
			local achs = TradeSkillLookup[tradeskill] and TradeSkillCheck(tradeskill, GetTradeSkillInfo(skill_index), true)
			if (not achs) then  return before;  end

			local myvalue = "|TInterface\\AddOns\\Overachiever_Trade\\AchShieldGlow:0|t |cffffd100" ..
			  L.REQUIREDFORMETATIP .. "|cffffffff"
			local _, name
			if (#achs > 1) then
			  for i,id in ipairs(achs) do
				_, name = GetAchievementInfo(id)
				myvalue = myvalue.."|n  - "..name
			  end
			else
			  _, name = GetAchievementInfo(achs[1])
			  myvalue = myvalue.."  "..name
			end
			myvalue = myvalue.."|r"

			if (before) then
			  return before .. "|n" .. myvalue
			else
			  return myvalue
			end
		  end

		  local orig_get_prefix = Skillet.GetRecipeNamePrefix
		  Skillet.GetRecipeNamePrefix = function(obj, tradeskill, skill_index)
			local before = orig_get_prefix(tradeskill, skill_index)

			-- Support for lilsparky's branch:
			if (lilsparkys) then
			  tradeskill = GetTradeSkillLine()
			end
			tradeskill = LBI[tradeskill]

			local ach = TradeSkillLookup[tradeskill] and TradeSkillCheck(tradeskill, GetTradeSkillInfo(skill_index), false)
			if (not ach) then  return before;  end

			local myvalue = "|TInterface\\AddOns\\Overachiever\\AchShield:16:16:-4:-2|t"
			if (before) then
			  return myvalue .. before
			else
			  return myvalue
			end
		  end

		  local function SkilletButtonOnClick(self)
			if ( (not lilsparkys and IsControlKeyDown()) or (lilsparkys and IsAltKeyDown()) ) then
			  local index = self:GetID()
			  if (index) then
				local tradeName = LBI[GetTradeSkillLine()]
				local id = TradeSkillLookup[tradeName] and TradeSkillCheck(tradeName, GetTradeSkillInfo(index), false)
				if (id) then  Overachiever.OpenToAchievement(id);  end
			  end
			end
		  end

		  local SkilletButtonOnEnter
		  if (lilsparkys) then
		  -- For some reason, lilsparky's branch explicitly removed support for GetExtraItemDetailText, so we're "forcing"
		  -- our way in, at least to the tooltips:
			function SkilletButtonOnEnter(self)
			  currentButton = self
			  local index = self:GetID()
			  if (index and not self.locked) then
				local tradeName = LBI[GetTradeSkillLine()]
				local achlist = TradeSkillLookup[tradeName] and TradeSkillCheck(tradeName, GetTradeSkillInfo(index), true)
				if (achlist) then
				  -- The custom tooltip used by Skillet doesn't handle AddTexture, or we'd use that instead of this method:
				  SkilletTradeskillTooltip:AddLine("|TInterface\\AddOns\\Overachiever_Trade\\AchShieldGlow:0|t |cffffd100" .. L.REQUIREDFORMETATIP)
				  Overachiever.AddAchListToTooltip(SkilletTradeskillTooltip, achlist)
				  SkilletTradeskillTooltip:Show()
				end
			  end
			end

			-- Needed for when the button's contents change while the cursor is over it:
			local orig_Skillet_SkillButton_OnEnter = Skillet.SkillButton_OnEnter
			Skillet.SkillButton_OnEnter = function(obj, button, ...)
			  orig_Skillet_SkillButton_OnEnter(obj, button, ...)
			  if (currentButton) then  SkilletButtonOnEnter(currentButton);  end
			end
		  end

		  local hookedOnClick = {}

		  local function SkilletButtonPreShow(button)
			if (not hookedOnClick[button]) then
			  hookedOnClick[button] = true
			  button:HookScript("OnClick", SkilletButtonOnClick)
			  if (lilsparkys) then
				button:HookScript("OnEnter", SkilletButtonOnEnter)
				button:HookScript("OnLeave", skillButtonOnLeave)  -- so currentButton will be set to nil
			  end
			end
			return button
		  end

		  Skillet:AddPreButtonShowCallback(SkilletButtonPreShow)

		end


		-- ---------- End addon support section. ----------



		skillButtonOnEnter = skillButtonOnEnter or function(self, _, calledByExamine)
		  currentButton = self
		  local icon = icons[self]
		  if (icon.name) then
			local achlist = TradeSkillCheck(LBI[GetTradeSkillLine()], icon.name, true)
			if (achlist) then
			  GameTooltip:SetOwner(self, "ANCHOR_NONE")
			  GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -45, 0)
			  GameTooltip:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
			  GameTooltip:AddLine(L.REQUIREDFORMETATIP)
			  GameTooltip:AddLine(" ")
			  Overachiever.AddAchListToTooltip(GameTooltip, achlist)
			  GameTooltip:AddLine(" ")
			  GameTooltip:Show()
			  return true
			elseif (not calledByExamine) then
			-- A criteria must have been earned while the Trade Skills frame was open. Reexamine it:
			  ExamineTradeSkillUI()
			end
		  end
		end

		if (ExamineTradeSkillUI == nil) then
		  function ExamineTradeSkillUI()
			-- Hide all icons:
			for btn, icon in pairs(icons) do
			  icon:Hide()
			  highlights[icon]:Hide()
			  icon.name = nil
			end

			local tradeName = LBI[GetTradeSkillLine()]
			if (TradeSkillLookup[tradeName]) then
			  -- Find icons that should be displayed:
			  local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
			  local skillName, skillType
			  for i=1,TRADE_SKILLS_DISPLAYED do
				skillName, skillType = GetTradeSkillInfo(i + skillOffset)
				if (skillName and skillType ~= "header" and TradeSkillCheck(tradeName, skillName)) then
				  local icon = GetIcon( _G["TradeSkillSkill"..i] )
				  icon:Show()
				  highlights[icon]:Show()
				  icon.name = skillName
				end
			  end
			end

			-- Needed for when the button's contents change while the cursor is over it:
			if (currentButton and not skillButtonOnEnter(currentButton, nil, true)) then
			  GameTooltip:Hide()  -- Hide tooltip if skillButtonOnEnter didn't show it.
			end
		  end

		  hooksecurefunc("TradeSkillFrame_Update", ExamineTradeSkillUI)
		end


		local function UpdateData(scrollFrame, entry)
			local results, reagents, tradeID = GnomeWorks:GetRecipeData(entry.recipeID)

			local tradeName = GnomeWorks:GetTradeName(tradeID)

			entry.achievementID = nil

			if TradeSkillLookup[tradeName] then
				local recipeAchievementList = TradeSkillLookup[tradeName][GnomeWorks:GetRecipeName(entry.recipeID)]

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
	--		LSW:ChatMessage("LilSparky's Workshop plugging into Skillet (v"..Skillet.version..")");

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

--						menuList = SubMenu,
					},
				}

--[[
				for flag,name in pairs(sourceFlags) do
					local button = {
						text = name,
						func = function()
							if not ARLSourceFlags[flag] then
								ARLSourceFlags[flag] = true
							else
								ARLSourceFlags[flag] = nil
							end

							GWScrollFrame:Refresh()
						end,
						checked = function() return ARLSourceFlags[flag] end
					}

					ARLSourceFlags[flag] = true

					sourceFlagBitValue[flag] = math.pow(2,flag-1)

					table.insert(SubMenu, button)
				end
]]

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

					local tradeName = GnomeWorks:GetTradeName(tradeID)

					if TradeSkillLookup[tradeName] then
						local recipeAchievementList = TradeSkillLookup[tradeName][GnomeWorks:GetRecipeName(recipeID)]

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

						local tradeName = GnomeWorks:GetTradeName(tradeID)

						if TradeSkillLookup[tradeName] then
							local recipeAchievementList = TradeSkillLookup[tradeName][GnomeWorks:GetRecipeName(recipeID)]

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


