






do
	local reagentID, page
	local reagentName
	local reagentScanAbort

	local callBack

	local reagentList

	local auctionData



	local function RecordAuctionEntry(reagentID, count, buyOut, seller)
--		print((GetItemInfo(reagentID)), count, math.floor(buyOut/100)/100)
		local newEntry = { count = count, buyOut = buyOut, seller = seller }

		if not auctionData[reagentID] then
			auctionData[reagentID] = { newEntry }
		else
			auctionData[#auctionData + 1] = newEntry
		end
	end



	local function SendQuery()
		if not reagentScanAbort then
			QueryAuctionItems(reagentName, nil, nil, 0, 0, 0, page, 0, nil, nil)
print("query", reagentName, reagentID)

			GnomeWorks:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		end
	end


	function GnomeWorks:AUCTION_ITEM_LIST_UPDATE(...)
		GnomeWorks:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")

		local num, totalNum = GetNumAuctionItems("list")

		local numPages = math.ceil(totalNum / 50)

		for i=1,num do
			local name, texture, count, _, _, _, _, _, buyOut, _, _, seller = GetAuctionItemInfo("list",i)

			if name == reagentName and buyOut then
				RecordAuctionEntry(reagentID, count, buyOut, seller)
			end
		end

		page = page + 1

		if page < numPages then
			self:ScheduleTimer(SendQuery, .5)
		else
			page = 0
			reagentID = next(reagentList, reagentID)
			if reagentID and reagentID > 0 then
				reagentName = GetItemInfo(reagentID)

				self:ScheduleTimer(SendQuery, .5)
			else
				callBack()
			end
		end
	end


	function GnomeWorks:BeginReagentScan(reagents, func)

		auctionData = self.data.auctionData

		reagentList = reagents
		callBack = func

		for id in pairs(reagents) do
			if auctionData[id] then
				table.wipe(auctionData[id])
			end
		end


		page = 0
		reagentID = next(reagentList)
		if reagentID then
			reagentName = GetItemInfo(reagentID)

			SendQuery()
		end
	end


	function GnomeWorks:StopReagentScan()
		reagentScanAbort = true
	end



	function GnomeWorks:AUCTION_HOUSE_SHOW(...)
		self.IsAtAuctionHouse = true
--		self:BeginReagentScan(GnomeWorks.data.inventoryData[(UnitName("player"))].queue, function() print("DONE WITH SCAN") end)

		self:ShoppingListShow((UnitName("player")), "vendorQueue")
	end


	function GnomeWorks:AUCTION_HOUSE_CLOSE(...)
		self.IsAtAuctionHouse = false
		self:StopReagentScan()
	end



end
