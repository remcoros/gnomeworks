

-- Queue Profitable Recipes (requires LSW)

do
	local plugin


	local scrollFrame



	local function Register()

		if not LSW then return false end


		local function QueueProfitableRecipe(recipeID)
			local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

			local cost = LSW:GetSkillCost(recipeID)/10000
			local value = LSW:GetSkillValue(recipeID)/10000


			if results and cost and value then
				local itemID = next(results)
				local onHand = GnomeWorks:GetFactionInventoryCount(itemID)

				local count = tonumber(plugin.variables.queueCount.value) - onHand

				if count > 0 then
					if value > cost then

						local profit = value - cost
						local profitRatio = value / cost

						if profit > tonumber(plugin.variables.profitThreshold.value) and profitRatio > (tonumber(plugin.variables.profitRatioThreshold.value)/100+1) then
							if value > tonumber(plugin.variables.valueThreshold.value) then
								if cost < tonumber(plugin.variables.costThreshold.value) then
									GnomeWorks:AddToQueue(GnomeWorks.player,tradeID,recipeID,count)
								end
							end
						end
					end
				end
			end
		end


		local function QueueProfitableEntries(group)
			if group then
				for i=1,group.numData or #group.entries do
					local entry = group.entries[i]

					if entry.subGroup then
						QueueProfitableEntries(entry.subGroup)
					else
						QueueProfitableRecipe(entry.recipeID)
					end
				end
			end
		end


		local function QueueProfitableRecipes()
			local label,name = string.split("/",plugin.variables.recipeGroup.value)

			local group = GnomeWorks:RecipeGroupFind(GnomeWorks.player, GnomeWorks.tradeID, label,name)

			QueueProfitableEntries(group)
		end



		local function QueueProfitableRecipesTBR()
			local knownRecipes = GnomeWorks.data.knownSpells[GnomeWorks.player]
			local tradeName = GetTradeSkillLine()

			for recipeID in pairs(knownRecipes) do
				local results,reagents,tradeID = GnomeWorks:GetRecipeData(recipeID)

				if GnomeWorks:GetTradeName(tradeID) == tradeName then
					local cost = LSW:GetSkillCost(recipeID)/10000
					local value = LSW:GetSkillValue(recipeID)/10000

					if results and cost and value then
						local onHand = GnomeWorks:GetFactionInventoryCount((next(results)))

						local count = tonumber(plugin.variables.queueCount.value) - onHand

						if count > 0 then
							if value > cost then

								local profit = value - cost
								local profitRatio = value / cost

								if profit > tonumber(plugin.variables.profitThreshold.value) and profitRatio > (tonumber(plugin.variables.profitRatioThreshold.value)/100+1) then
									if value > tonumber(plugin.variables.valueThreshold.value) then
										if cost < tonumber(plugin.variables.costThreshold.value) then
											GnomeWorks:AddToQueue(GnomeWorks.player,tradeID,recipeID,count)
										end
									end
								end
							end
						end
					end
				end
			end
		end


		local function RecipeGroupSelect(menuButton, group)
			CloseDropDownMenus()

			if not group then
				group = groupLabels[GnomeWorks.player..":"..GnomeWorks.tradeID][1].subGroup
			end

			local var = plugin.variables.recipeGroup
			var.value = group.label.."/"..group.name

			var.menuButton.text = string.format(var.format, var.value)
		end



		local function ConstructRecipeGroups(menuFrame,level)
			local entries

			if level == 3 then
				if GnomeWorks.tradeID and GnomeWorks.player then
					entries = GnomeWorks.groupLabels[GnomeWorks.player..":"..GnomeWorks.tradeID]
				end
			elseif UIDROPDOWNMENU_MENU_VALUE and type(UIDROPDOWNMENU_MENU_VALUE)=="table" then
				entries = UIDROPDOWNMENU_MENU_VALUE.entries
			end

			if not entries then
				return 0
			end

			local numGroupsAdded = 0

			local entry = {}


			for i=1,#entries do
				if entries[i].subGroup then
					local group = entries[i].subGroup

					entry.hasArrow = false

					for k,v in ipairs(group.entries) do
						if v.subGroup then
							entry.hasArrow = true
							break
						end
					end

					entry.text = entries[i].name
					entry.value = group

					entry.func = RecipeGroupSelect
					entry.arg1 = group

					entry.checked = false

					entry.colorCode = nil

					entry.menuList = ConstructRecipeGroups
--					entry.value = ConstructRecipeGroups

					if plugin.variables.recipeGroup.value == group.name then
						entry.checked = true
					end

					UIDropDownMenu_AddButton(entry, level)

					numGroupsAdded = numGroupsAdded + 1
				end
			end

			return numGroupsAdded
		end





		local function Init()
			plugin.variables.queueCount = { value = 5, label = "Number to Queue:", format = "Number to Queue: |cff80ff80%s" }
			plugin.variables.minCount = { value = 0, label = "Skip if fewer than:", format = "Skip if fewer than: |cff80ff80%s" }
			plugin.variables.profitRatioThreshold = { value = 25, label = "Profit Margin (percent):", format = "Profit Margin: |cff80ff80%s%%" }
			plugin.variables.profitThreshold = { value = 0, label = "Profit (in gold):", format = "Profit: |cff80ff80%sg" }
			plugin.variables.costThreshold = { value = 100, label = "Max Cost (in gold):", format = "Max Cost: |cff80ff80%sg" }
			plugin.variables.valueThreshold = { value = 5, label = "Min Value (in gold):", format = "Min Value |cff80ff80%sg" }
			plugin.variables.recipeGroup = {
				value = "Flat",
				label = "Select Recipe Group",
				format = "Recipe Group: |cff80ff80%s",
			}


			plugin:AddInput("profitRatioThreshold")
			plugin:AddInput("profitThreshold")
			plugin:AddInput("costThreshold")
			plugin:AddInput("valueThreshold")
			plugin:AddInput("queueCount")
			plugin:AddInput("minCount")
			plugin:AddMenu("recipeGroup", ConstructRecipeGroups)


			plugin:AddButton("Go", QueueProfitableRecipes).notCheckable = true
		end

		Init()

		return true
	end


	plugin = GnomeWorks:RegisterPlugin("Queue Profitable", Register)
end


