






do
--[[
	local frame = CreateFrame("Frame")

	frame:SetScript("OnEvent",function(frame,event,...)
		if string.find(event,"MAIL") then
			print(event,...)
		end
	end)

	frame:RegisterAllEvents()
--	frame:Hide()
]]



	local function CheckForAltNeeds()
		local player = UnitName("player")
		local topInventory = GnomeWorksDB.config.inventoryIndex[#GnomeWorksDB.config.inventoryIndex]

		for alt,queueData in pairs(GnomeWorks.data.shoppingQueueData) do
			if alt ~= player then
				for itemID, numNeeded in pairs(queueData.alt) do
					local itemName, itemLink = GetItemInfo(itemID)

					local numOnHand = GetItemCount(itemID)
					local numAvailable = GnomeWorks:GetCraftableInventoryCount(itemID,player,topInventory)

					if numAvailable then
						GnomeWorks:printf("%s needs %d x [%s].  you have %d on hand (%d total available)", alt, numNeeded, itemName or "item:"..itemID, numOnHand, numAvailable)
					end
				end
			end
		end
	end



	function GnomeWorks:MAIL_SHOW()
		GnomeWorks.atMail = true
		CheckInbox()

		CheckForAltNeeds()
	end



	function GnomeWorks:DoMailUpdate()
		local numItems, totalItems = GetInboxNumItems()
		local player = UnitName("player")
		local newItem

		GnomeWorks.player = player

		local invData = self.data.inventoryData[player].mail

		if next(invData) then
			newItem = true

			for itemID,count in pairs(invData) do
				invData[itemID] = 0
			end
		end


		for i=1,numItems do
			local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(i)

			if hasItem then
				for j=1,ATTACHMENTS_MAX_RECEIVE do

					local itemLink = GetInboxItemLink(i,j)

					if itemLink then

						local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

						if GnomeWorks.data.trackedItems[itemID] then
							local name, itemTexture, count, quality, canUse = GetInboxItem(i,j)

							invData[itemID] = (invData[itemID] or 0) + count

							newItem = true
						end
					end
				end
			end
		end


		if newItem then
			local dependency

			for k,inv in ipairs(GnomeWorksDB.config.inventoryIndex) do
				if inv == "mail" then
					dependency = k
					break
				end
			end

			if dependency then
				for i=dependency,#GnomeWorksDB.config.inventoryIndex do
					if self.data.craftabilityData[player][GnomeWorksDB.config.inventoryIndex[i]] then
						table.wipe(self.data.craftabilityData[player][GnomeWorksDB.config.inventoryIndex[i]])
					end
				end
			end
			
			self:InventoryScan()
		end

		self:SendMessageDispatch("MailUpdated")
	end


	local updateTimer
	function GnomeWorks:MAIL_INBOX_UPDATE()
		if updateTimer then
			GnomeWorks:CancelTimer(updateTimer, true)
			updateTimer = nil
		end

		updateTimer = GnomeWorks:ScheduleTimer("DoMailUpdate", .1)
	end


	function GnomeWorks:MAIL_CLOSED()
		GnomeWorks.atMail = false
--		self:DoMailUpdate() -- just in case
	end




--	GnomeWorks:RegisterMessageDispatch("MailUpdated", CheckForAltNeeds)
end




