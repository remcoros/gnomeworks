

-- Queue Profitable Recipes (requires LSW)

do
	local plugin


	local scrollFrame



	local function Register()

		function QueueProfitableRecipes()
			local knownRecipes = GnomeWorks.data.knownSpells[GnomeWorks.player]
			local tradeName = GetTradeSkillLine()

			for recipeID in pairs(knownRecipes) do
				local results,reagents,tradeID = GnomeWorks:GetRecipeData(recipeID)

				if GnomeWorks:GetTradeName(tradeID) == tradeName then
					local cost = LSW:GetSkillCost(recipeID)/10000
					local value = LSW:GetSkillValue(recipeID)/10000

					if results and cost and value then
						local onHand = GnomeWorks:GetFactionInventoryCount(next(results))

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



		local function Init()
			plugin.variables.queueCount = { value = 5, label = "Number to Queue:", format = "Number to Queue: |cff80ff80%s" }
			plugin.variables.profitRatioThreshold = { value = 25, label = "Profit Margin (percent):", format = "Profit Margin: |cff80ff80%s%%" }
			plugin.variables.profitThreshold = { value = 0, label = "Profit (in gold):", format = "Profit: |cff80ff80%sg" }
			plugin.variables.costThreshold = { value = 100, label = "Max Cost (in gold):", format = "Max Cost: |cff80ff80%sg" }
			plugin.variables.valueThreshold = { value = 5, label = "Min Value (in gold):", format = "Min Value |cff80ff80%sg" }


			plugin:AddInput("profitRatioThreshold")
			plugin:AddInput("profitThreshold")
			plugin:AddInput("costThreshold")
			plugin:AddInput("valueThreshold")
			plugin:AddInput("queueCount")

			plugin:AddButton("Go", QueueProfitableRecipes).notCheckable = true
		end

		Init()

		return true
	end

	plugin = GnomeWorks:RegisterPlugin("Queue Profitable", Register)

end


