




do
	local throttle

	function GnomeWorks:TrainerScan()
		for i=1, GetNumTrainerServices() do
			local itemLink = GetTrainerServiceItemLink(i)

			if itemLink then
				local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

				local recipeList = GnomeWorks.data.itemSource[itemID]

				local recipeID = next(recipeList)

				local results, reagents, tradeID = GnomeWorks:GetRecipeData(recipeID)

				local skill, level = GetTrainerServiceSkillReq(i)

				if GetSpellInfo(tradeID) == skill then
					self.data.trainableSpells[recipeID] = level

					RecipeSkillLevels[1][recipeID] = level
				end
			end
		end

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

