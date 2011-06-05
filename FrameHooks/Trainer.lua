




do
	local throttle

	function GnomeWorks:TrainerScan()
		local addedRecipes

		for i=1, GetNumTrainerServices() do
			local serviceName, serviceSubText, serviceType, texture, reqLevel = GetTrainerServiceInfo(i)

			local recipeID

			for r in pairs(GnomeWorksDB.results) do
				if GetSpellInfo(r) == serviceName then
					recipeID = r
					break
				end
			end

			if recipeID then
				local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

				local skill, level = GetTrainerServiceSkillReq(i)

				if skill == GetSpellInfo(2575) then				-- mining
					skill = GetSpellInfo(2656)						-- smelting
				end


				if GnomeWorks:GetTradeName(tradeID) == skill and not self.data.trainableSpells[recipeID] then
					self.data.trainableSpells[recipeID] = level

					GnomeWorks.data.recipeSkillLevels[1][recipeID] = level

					addedRecipes = true
				end
			end
		end

		GnomeWorks:DoTradeSkillUpdate()
	end


	function GnomeWorks:TRAINER_SHOW(...)
		if IsTradeskillTrainer() then
			self.atTrainer = true

			self:TRAINER_UPDATE(...)
		end
	end


	function GnomeWorks:TRAINER_UPDATE(...)
		if throttle then
			self:CancelTimer(throttle, true)
			throttle = nil
		end

		throttle = self:ScheduleTimer("TrainerScan",.25)
	end

	function GnomeWorks:TRAINER_CLOSE(...)
		self.atTrianer = false
	end
end

