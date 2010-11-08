




do
	local vendorThrottle


	local function RecordMerchantItem(itemID, i)
		if GnomeWorks.data.reagentUsage[itemID] and not GnomeWorksDB.vendorItems[itemID] then -- and not GnomeWorksDB.results[spoofedRecipeID] then
			local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)

			if numAvailable == -1 then					-- unlimited stock items only
				local itemCount = GetMerchantItemCostInfo(i)

				if not extendedCost then
					GnomeWorks:print("recording vendor item: ",name)
					GnomeWorksDB.vendorItems[itemID] = true
				else
					GnomeWorks:RecordVendorConversion(itemID, i)
				end
			end
		end
	end

	local function QuickMoneyFormat(copper)
		local silver = copper/100
		local gold = silver/100
		local kgold = gold/1000


		if kgold > 1 then
			return "|cffffd100"..math.floor(kgold*10+.5)/10 .."k"
		end

		if gold > 1 then
			return "|Cffffd100"..math.floor(gold*100+.5)/100 .."g"
		end

		if silver > 1 then
			return "|cffe6e6e6"..math.floor(silver*100+.5)/100 .."s"
		end

		return "|cffc8602c"..copper .. "c"
	end


	local purchaseLockout

	function GnomeWorks:BuyVendorItems(player, singleItemID, singleItemCount)
		if purchaseLockout then
			return
		end

		purchaseLockout = true

		local vendorQueue = self.data.vendorQueue[player]
		local totalSpent = 0

		for i=1,GetMerchantNumItems() do
			local link = GetMerchantItemLink(i)

			if link then
				local itemID = tonumber(string.match(link, "item:(%d+)"))

				if (singleItemID and itemID == singleItemID) or (not singleItemID and itemID) then
					local count = singleItemCount or vendorQueue[itemID]

					if count and count > 0 then
						local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(i)
						local _, _, _, _, _, _, _, stackSize = GetItemInfo(link)

						local numPurchase = count/quantity
	--print(numAvailable)
						if numAvailable ~= 0 then
							local numStacksNeeded    		= math.floor(count/stackSize)
							local subStackCount        		= math.ceil(count-(numStacksNeeded*stackSize))
							if numStacksNeeded > 0 then
								for l=1,numStacksNeeded do
									BuyMerchantItem(i,stackSize)
								end
							end
							if subStackCount > 0 then
								BuyMerchantItem(i,subStackCount)
							end

							if singleItemCount then
								singleItemCount = singleItemCount - numPurchase*quantity
							else
								vendorQueue[itemID] = vendorQueue[itemID] - numPurchase * quantity
							end

							self:print("auto-purchased",name,"x",numPurchase * quantity)

							totalSpent = totalSpent + price * numPurchase
						end

					end
				end
			end
		end

		self:ScheduleTimer("InventoryScan",.25)

		if totalSpent>0 then
			self:print("spent on reagents: ",QuickMoneyFormat(totalSpent))
		end

		purchaseLockout = nil
	end



	local merchantLocked
	local merchantIncomplete

	function GnomeWorks:VendorScan(...)
		if merchantLocked then return end

		merchantIncomplete = false
		merchantLocked = true

		local totalSpent = 0

		for i=1,GetMerchantNumItems() do
			if GetMerchantItemInfo(i) then
				local link = GetMerchantItemLink(i)

				if link then
					local itemID = tonumber(string.match(link, "item:(%d+)"))

					RecordMerchantItem(itemID, i)
				else
					merchantIncomplete = true
				end
			else
				merchantIncomplete = true
			end
		end


		if not merchantIncomplete then
--			self:BuyVendorItems(self.player or UnitName("Player"))
		end

		merchantLocked = nil
	end


	function GnomeWorks:MERCHANT_SHOW(...)
		self.atVendor = true

		local player = UnitName("player")
		local vendorQueue = self.data.vendorQueue[player]

		if vendorQueue and next(vendorQueue) then
--[[
			if not self.MainWindow:IsVisible() then
				self.player = player
				self:ShowQueueList(player)
			end
]]
			self:ShoppingListShow((UnitName("player")))
		end

		self:MERCHANT_UPDATE(...)
	end


	function GnomeWorks:MERCHANT_UPDATE(...)
		if vendorThrottle then
			self:CancelTimer(vendorThrottle, true)
		end

		vendorThrottle = self:ScheduleTimer("VendorScan",.25)
	end

	function GnomeWorks:MERCHANT_CLOSE(...)
		self.atVendor = false
	end
end

