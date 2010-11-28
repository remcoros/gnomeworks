






do
	local frame = CreateFrame("Frame")

	frame:SetScript("OnEvent",function(frame,event,...)
		if string.find(event,"MAIL") then
			print(event,...)
		end
	end)

--	frame:RegisterAllEvents()
	frame:Hide()

	function GnomeWorks:MAIL_SHOW()
		CheckInbox()
	end


	function GnomeWorks:MAIL_INBOX_UPDATE()
		numItems, totalItems = GetInboxNumItems()
		local player = UnitName("player")

		GnomeWorks.player = player

		GnomeWorks:InventoryScan()

		local invData = self.data.inventoryData[player].mail
		local bankData = self.data.inventoryData[player].bank

		for itemID,count in pairs(invData) do
			invData[itemID] = 0
		end

		for itemID, count in pairs(bankData) do
			invData[itemID] = bankData[itemID]
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
	end

	function GnomeWorks:MAIL_CLOSE()
	end
end




