






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

		for alt, queue in pairs(GnomeWorks.data.altQueue) do
			if alt ~= player then
				for itemID, numNeeded in pairs(queue) do
					local itemName, itemLink = GetItemInfo(itemID)

					local numOnHand = GetItemCount(itemID)
					local numAvailable = GnomeWorks:GetInventoryCount(itemID,player,"craftedGuildBank queue")

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
		numItems, totalItems = GetInboxNumItems()
		local player = UnitName("player")

		GnomeWorks.player = player

		local invData = self.data.inventoryData[player].mail

		for itemID,count in pairs(invData) do
			invData[itemID] = 0
		end

		for i=1,numItems do
			local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(i)

			if hasItem then
				for j=1,ATTACHMENTS_MAX_RECEIVE do


					local itemLink = GetInboxItemLink(i,j)

					if itemLink then
						local name, itemTexture, count, quality, canUse = GetInboxItem(i,j)
						local itemID = tonumber(string.match(itemLink,"item:(%d+)"))

						invData[itemID] = (invData[itemID] or 0) + count
					end
				end
			end
		end

		GnomeWorks:InventoryScan()

		GnomeWorks:SendMessageDispatch("MailUpdated")
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




