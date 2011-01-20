


--[[


	GnomeWorks public API


	very much a work in progress!!!


	]]






do





	--[[

		GnomeWorks:GetMainFrame()

		returns the blizzard "Frame" object for the main gnomeworks main window
	]]

	function GnomeWorks:GetMainFrame()
		return self.MainWindow
	end

	function GnomeWorks:GetDetailFrame()
		return self.detailFrame
	end

	function GnomeWorks:GetSkillListFrame()
		return self.skillFrame
	end


	--[[
		GnomeWorks:GetSkillListScrollFrame()

		returns the gnomeworks "ScrollFrame" object for the main window skill list
	]]
	function GnomeWorks:GetSkillListScrollFrame()
		return self.skillFrame.scrollFrame
	end

	function GnomeWorks:GetReagentListScrollFrame()
		return self.reagentFrame.scrollFrame
	end

	function GnomeWorks:GetQueueListScrollFrame()
		return self.queueFrame.scrollFrame
	end

	function GnomeWorks:GetShoppingListScrollFrame()
		return self.shoppingListFrame.scrollFrame
	end



	--[[
		GnomeWorks:GetQueue(player)

		returns the queue object for a particular player (or the current player if player is not passed)

		queue object methods:
			CraftItem(itemID, count)
			CraftRecipe(recipeID, count)
			DeleteItem(itemID)
			DeleteRecipe(itemID)
			CreateProcessButton()
	]]
--	function GnomeWorks:GetQueue(player)
--		return self.data.queue
--	end

end



