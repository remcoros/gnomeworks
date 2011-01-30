






do
	local reagentID, page
	local reagentName
	local reagentScanAbort

	local reagentList

	local auctionData

	local buyoutList = {}


	local frame
	local buyFrame
	local reagentFrame

	local GWAuctionTabID

	local auctionTab


	local purchaseEntry

	local purchaseIsPending



	local function QuickMoneyFormat(copper)
		local silver = copper/100
		local gold = silver/100
		local kgold = gold/1000


		if kgold >= 1 then
			return "|cffffd100"..math.floor(kgold*10+.5)/10 .."k"
		end

		if gold >= 1 then
			return "|Cffffd100"..math.floor(gold*100+.5)/100 .."g"
		end

		if silver >= 1 then
			return "|cffe6e6e6"..math.floor(silver*100+.5)/100 .."s"
		end

		return "|cffc8602c"..copper .. "c"
	end


	local timeOutTimer


	local function SendQuery()
	end

	function SendQuery(eventHandler)
		if not reagentScanAbort then
			if CanSendAuctionQuery() then

				QueryAuctionItems(reagentName, nil, nil, 0, 0, 0, page, 0, nil, nil)
--print("query", reagentName, reagentID)

				if eventHandler then
					GnomeWorks:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", eventHandler)
				else
					GnomeWorks:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
				end
			else
				timeOutTimer = GnomeWorks:ScheduleTimer(SendQuery,.1,eventHandler)
			end
		else
--			print("abort?")
		end
	end



	local function EntryIsCurrent(entry)
		local num, totalNum = GetNumAuctionItems("list")

		local numPages = math.ceil(totalNum / 50)


		for i=1,num do
			local name, texture, count, _, _, _, _, _, buyOut, _, _, seller = GetAuctionItemInfo("list",i)

			if name == reagentName and count == entry.count and buyOut == entry.buyOut then
				return i
			end
		end
	end


	local function FindEntry()
		local num, totalNum = GetNumAuctionItems("list")
		GnomeWorks:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		local entry = purchaseEntry

		local found = EntryIsCurrent(entry)

		if not found then
			page = page + 1

			local numPages = math.ceil(totalNum / 50)


			if page < numPages then
				SendQuery(FindEntry)
			else
				print("can't find it")
			end
		else
			buyFrame.sf:Refresh()
		end
	end



	local function ProcessPurchase(entry)
		if not entry then
			return
		end

		purchaseIsPending = nil

		table.remove(buyFrame.sf.data.entries, entry.dataIndex)

		GnomeWorks.data.auctionInventory[reagentID] = GnomeWorks.data.auctionInventory[reagentID] - entry.count

		GnomeWorks.data.inventoryData[UnitName("player")].mail[reagentID] = (GnomeWorks.data.inventoryData[UnitName("player")].mail[reagentID] or 0) + entry.count

		GnomeWorks:InventoryScan()
		buyFrame.sf:Refresh()

		GnomeWorks:print("Purchased.")
	end


	local function ReportFailedPurchase()
		GnomeWorks:warning("Could not complete purchase.")

		purchaseIsPending = nil

		buyFrame.sf:Draw()
	end


	local function BuyAuctionEntry(entry)
		local num, totalNum = GetNumAuctionItems("list")

		local numPages = math.ceil(totalNum / 50)

		local found = EntryIsCurrent(entry)

		reagentID = frame.reagentButton.itemID

		if found then
			GnomeWorks:printf("buying %s x %d for %s",(GetItemInfo(reagentID)),entry.count,QuickMoneyFormat(entry.buyOut))

			PlaceAuctionBid("list", found, entry.buyOut)

			PurchaseIsPending = true

			GnomeWorks:ExecuteOnEvent("UPDATE_PENDING_MAIL", ProcessPurchase, entry, 2.0, ReportFailedPurchase)
		else
			page = 0

			purchaseEntry = entry
			SendQuery(FindEntry)
		end
	end



	local function AuctionFrame_OnClick(cellFrame, button, source)
		local rowFrame = cellFrame:GetParent()

		if rowFrame.rowIndex>0 then
			local entry = rowFrame.data

			if not purchaseIsPending then
				BuyAuctionEntry(entry)
			else
				GnomeWorks:warning("can't purchase yet.")
			end
		end

		GameTooltip:Hide()
	end


	local function AuctionFrame_OnEnter(cellFrame, button)
		local rowFrame = cellFrame:GetParent()

		if rowFrame.rowIndex>0 then
			local entry = rowFrame.data

			GameTooltip:SetOwner(cellFrame.scrollFrame,"ANCHOR_NONE")
			GameTooltip:SetPoint("TOPRIGHT",cellFrame,"TOPLEFT")

			if purchaseIsPending then
				GameTooltip:AddLine("|cffff0000Waiting for purchase confirmation")
				GameTooltip:Show()
			else
				if EntryIsCurrent(entry) then
					GameTooltip:AddLine("Click To Buy")
					GameTooltip:Show()
				else
					GameTooltip:AddLine("Click to Search")
					GameTooltip:Show()
				end
			end
		end
	end



	local function BuildScrollingBuyFrame(frame)

		local columnHeaders = {
			{
	--			font = "GameFontHighlight",
				buttonX = {
					normalTexture = "Interface\\Icons\\INV_Misc_Bag_10",
					highlightTexture = "Interface\\InventoryItems\\WoWUnknownItem01",
					width = 14,
					height = 14,
				},
				align = "CENTER",
				name = "Cost Per",
				width = 90,
				OnEnter = AuctionFrame_OnEnter,
				OnLeave = function()
								GameTooltip:Hide()
							end,
				draw =	function (rowFrame,cellFrame,entry)
							cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", 16, 0)
							cellFrame.text:SetText(QuickMoneyFormat(entry.buyOut/entry.count))

							local alpha

							if EntryIsCurrent(entry) then
								alpha = 1
							else
								alpha = .5
							end

							if entry.buyIt then
								cellFrame.text:SetTextColor(0,1,0,alpha)
							else
								cellFrame.text:SetTextColor(1,0,0,alpha)
							end
						end,
				OnClick = AuctionFrame_OnClick,
			}, -- [1]
			{
				name = "Count",
				align = "CENTER",
				width = 50,
				font = "GameFontHighlightSmall",
				OnEnter = AuctionFrame_OnEnter,
				OnLeave = function()
								GameTooltip:Hide()
							end,
				draw =	function (rowFrame,cellFrame,entry)
							cellFrame.text:SetText(entry.count)

							local alpha

							if EntryIsCurrent(entry) then
								alpha = 1
							else
								alpha = .5
							end

							if entry.buyIt then
								cellFrame.text:SetTextColor(0,1,0,alpha)
							else
								cellFrame.text:SetTextColor(1,0,0,alpha)
							end
						end,
				OnClick = AuctionFrame_OnClick,
			}, -- [2]

			{
	--			font = "GameFontHighlight",
				name = "Total Buyout",
				width = 90,
				align = "CENTER",
				draw =	function (rowFrame,cellFrame,entry)
							cellFrame.text:SetText(QuickMoneyFormat(entry.buyOut))

							local alpha

							if EntryIsCurrent(entry) then
								alpha = 1
							else
								alpha = .5
							end


							if entry.buyIt then
								cellFrame.text:SetTextColor(0,1,0,alpha)
							else
								cellFrame.text:SetTextColor(1,0,0,alpha)
							end
						end,
				OnClick = AuctionFrame_OnClick,
				OnEnter = AuctionFrame_OnEnter,
				OnLeave = function()
								GameTooltip:Hide()
							end,
			}, -- [3]
		}


		local function ResizeFrame(scrollFrame,width,height)

			if scrollFrame then
				scrollFrame.columnWidth[2] = scrollFrame.columnWidth[2] + width - scrollFrame.headerWidth
				scrollFrame.headerWidth = width

				local x = 0

				for i=1,#scrollFrame.columnFrames do
					scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
					scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+scrollFrame.columnWidth[i],0)

					x = x + scrollFrame.columnWidth[i]
				end
			end
		end

		local ScrollPaneBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 9.5, right = 9.5, top = 9.5, bottom = 11.5 }
			}




--		GnomeWorks.auctionFrame = auctionFrame

		local sf = GnomeWorks:CreateScrollingTable(frame, ScrollPaneBackdrop, columnHeaders, ResizeFrame)


--		sf.childrenFirst = true

		sf.IsEntryFiltered = function(self, entry)
			return false
		end


		local function UpdateRowData(scrollFrame,entry)
		end

		sf:RegisterRowUpdate(UpdateRowData)


		frame.sf = sf
	end



	local function BuildScrollingReagentFrame(frame)

		local columnHeaders = {
			{
	--			font = "GameFontHighlight",
				buttonX = {
					normalTexture = "Interface\\Icons\\INV_Misc_Bag_10",
					highlightTexture = "Interface\\InventoryItems\\WoWUnknownItem01",
					width = 14,
					height = 14,
				},
				align = "RIGHT",
				name = "Reagent",
				width = 30,
--				OnEnter = AuctionFrame_OnEnter,
				OnLeave = function()
								GameTooltip:Hide()
							end,
				draw =	function (rowFrame,cellFrame,entry)
							cellFrame.text:SetPoint("RIGHT", cellFrame, "RIGHT", -8, 0)
							cellFrame.text:SetText(GetItemInfo(entry.itemID))

							local player = GnomeWorks.player or UnitName("player")
							local needed = GnomeWorks.data.shoppingQueueData[player].auction[entry.itemID] or 0
							local available = GnomeWorks.data.auctionInventory[entry.itemID] or 0

							if available == 0 then
								cellFrame.text:SetTextColor(1,0,0)
							elseif needed == 0 then
								cellFrame.text:SetTextColor(.5,.5,.5)
							elseif available >= needed then
								cellFrame.text:SetTextColor(0,1,0)
							else
								cellFrame.text:SetTextColor(1,1,0)
							end
						end,
				OnClick = function (cellFrame, button, source)
								local rowFrame = cellFrame:GetParent()

								if rowFrame.rowIndex>0 then
									local entry = rowFrame.data

									GnomeWorks:BeginSingleReagentScan(entry.itemID)
									rowFrame.scrollFrame.selectedIndex = entry.index
								end


							end
			}, -- [1]
		}


		local function ResizeFrame(scrollFrame,width,height)

		if scrollFrame then
				scrollFrame.columnWidth[1] = scrollFrame.columnWidth[1] + width - scrollFrame.headerWidth
				scrollFrame.headerWidth = width

				local x = 0

				for i=1,#scrollFrame.columnFrames do
					scrollFrame.columnFrames[i]:SetPoint("LEFT",scrollFrame, "LEFT", x,0)
					scrollFrame.columnFrames[i]:SetPoint("RIGHT",scrollFrame, "LEFT", x+scrollFrame.columnWidth[i],0)

					x = x + scrollFrame.columnWidth[i]
				end
			end
		end

		local ScrollPaneBackdrop  = {
				bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBackground.tga",
				edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\frameInsetSmallBorder.tga",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 9.5, right = 9.5, top = 9.5, bottom = 11.5 }
			}




--		GnomeWorks.auctionFrame = auctionFrame

		local sf = GnomeWorks:CreateScrollingTable(frame, ScrollPaneBackdrop, columnHeaders, ResizeFrame)


--		sf.childrenFirst = true

		sf.IsEntryFiltered = function(self, entry)
			return false
		end


		local function UpdateRowData(scrollFrame,entry)
		end

		sf:RegisterRowUpdate(UpdateRowData)

		sf.data = { entries = {} }

		frame.sf = sf
	end



	function GnomeWorks:CreateAuctionWindow()
		local function ResizeWindow()
		end


--		frame = self.Window:CreateResizableWindow("GnomeWorksAuctionFrame", "Auctions", 300, 300, ResizeWindow, GnomeWorksDB.config)

--		frame:SetMaxResize(300,1000)
--		frame:SetMinResize(300,200)

----		frame:DockWindow(self.MainWindow)

		LoadAddOn("Blizzard_AuctionUI")

		frame = CreateFrame("Frame", nil, AuctionFrame)

		frame:SetPoint("TOPLEFT",0,0)
		frame:SetPoint("BOTTOMRIGHT",0,0)


		buyFrame = CreateFrame("Frame", nil, frame)

		buyFrame:SetPoint("TOPLEFT",190,-103)
		buyFrame:SetPoint("BOTTOMRIGHT",-10,40)


		reagentFrame = CreateFrame("Frame", nil, frame)

		reagentFrame:SetPoint("TOPLEFT",20,-103)
		reagentFrame:SetPoint("BOTTOMRIGHT",frame, "BOTTOMLEFT", 180,40)




		frame:Hide()



		local lastTab = _G["AuctionFrameTab"..AuctionFrame.numTabs]

		local tabs = AuctionFrame.numTabs + 1

		GWAuctionTabID = tabs


		auctionTab = CreateFrame("Button", "AuctionFrameTab"..tabs, AuctionFrame, "AuctionTabTemplate")


		auctionTab:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", -8,0)
		auctionTab:SetID(tabs)
		auctionTab:SetText("|cff80ff80GnomeWorks")

--		auctionTab:SetWidth(70)
		PanelTemplates_TabResize(auctionTab,0)


		PanelTemplates_SetNumTabs(AuctionFrame, tabs)
		PanelTemplates_EnableTab(AuctionFrame, tabs)



		local originalAuctionFrameTab_OnClick = AuctionFrameTab_OnClick

		function AuctionFrameTab_OnClick(self, ...)
			local index = self:GetID()

			frame:Hide()

			originalAuctionFrameTab_OnClick(self, ...)

			if index == GWAuctionTabID then
				frame:Show()
				AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft")
				AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top")
				AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight")
				AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft")
				AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
				AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
			end
		end


		BuildScrollingBuyFrame(buyFrame)
		BuildScrollingReagentFrame(reagentFrame)

--		frame:Hide()


		local button = CreateFrame("Button", "GWAuctionItemIcon", buyFrame, "ActionButtonTemplate")

		button:SetAlpha(0.8)

		button:SetPoint("BOTTOMLEFT", buyFrame, "TOPLEFT", 20, 20)
		button:SetWidth(32)
		button:SetHeight(32)

		button:EnableMouse(true)

		GWAuctionItemIconNormalTexture:SetAllPoints(button)			-- for some reason they added an offset in the template in 4.0.1

		button:SetScript("OnEnter", function(b)
			GameTooltip:SetOwner(b,"ANCHOR_NONE")
			GameTooltip:SetHyperlink("item:"..(b.itemID or 0))
			GameTooltip:SetPoint("BOTTOMLEFT", b, "TOPRIGHT")
			GameTooltip:Show()
		end)

		button:SetScript("OnLeave", function() GameTooltip:Hide() end)
		button:SetScript("OnClick", function(b) GnomeWorks:BeginSingleReagentScan(b.itemID) end )

		button:Show()

		button:SetFrameLevel(button:GetFrameLevel()+1)


		local text = button:CreateFontString(nil,"OVERLAY", "GameFontHighlight")

		text:SetJustifyH("LEFT")
		text:SetPoint("LEFT",button,"RIGHT",5,10)
		text:SetPoint("RIGHT",frame,"RIGHT",-20,10)
		text:SetHeight(16)

		button.count = text


		text = button:CreateFontString(nil,"OVERLAY", "GameFontHighlight")

		text:SetJustifyH("LEFT")
		text:SetPoint("LEFT",button,"RIGHT",5,-10)
		text:SetPoint("RIGHT",frame,"RIGHT",-20,-10)
		text:SetHeight(16)

		button.needed = text



		frame.reagentButton = button



		local function BeginAuctionScan()
			GnomeWorks:BeginReagentScan(GnomeWorks.player)
		end

		local function CancelAuctionScan()
			GnomeWorks:StopReagentScan()
		end

		local function ConfigureAuctionButton(button)

			if GnomeWorks.atAuctionHouse then
				if GnomeWorks.auctionScanning then
					button:SetText("Cancel Auction Scan")
					button:SetScript("OnClick", CancelAuctionScan)
				else
					button:SetText("Scan Auctions")
					button:SetScript("OnClick", BeginAuctionScan)
				end

				button:Enable()
			else
				button:SetText("Scan Auctions")
				button:Disable()
			end
		end


		local scanButton = GnomeWorks:CreateButton(frame, 24)

		scanButton:SetPoint("BOTTOMRIGHT",-8,14)
		scanButton:SetWidth(250)

		scanButton:SetText("Scan Auctions")

		scanButton:SetNormalFontObject("GameFontNormal")
		scanButton:SetHighlightFontObject("GameFontHighlight")
		scanButton:SetDisabledFontObject("GameFontDisable")

		GnomeWorks:RegisterMessageDispatch("HeartBeat AuctionScan", function() ConfigureAuctionButton(scanButton) end, "ConfigureAuctionButtons")

		ConfigureAuctionButton(scanButton)


		return frame
	end






	function GnomeWorks:ShowAuctionWindow()
		if reagentID then
			local icon = GetItemIcon(reagentID)

			frame.reagentButton.itemID = reagentID

			if icon then
				frame.reagentButton:SetNormalTexture(icon)
				frame.reagentButton:SetPushedTexture(icon)

				local player = self.player or UnitName("player")

				local auctionQueue = self.data.shoppingQueueData[player].auction

				frame.reagentButton.count:SetFormattedText("%d %s (%d pages)",self.data.auctionInventory[reagentID] or 0,(GetItemInfo(reagentID)),page or 0)
--print(self.data.auctionQueue[self.player][reagentID], self.player, reagentID)

				if auctionQueue and auctionQueue[reagentID] then
					frame.reagentButton.needed:SetFormattedText("%d Needed",auctionQueue[reagentID] or 0)
					frame.reagentButton.needed:Show()
				else
					frame.reagentButton.needed:SetText("Unused in current queue configuration")
					frame.reagentButton.needed:Show()
				end

				frame.reagentButton:Show()
			else
				frame.reagentButton:Hide()
			end

			buyFrame.sf.data.entries = self.data.auctionData[reagentID]

			buyFrame.sf:Refresh()
			reagentFrame.sf:Refresh()

			if not frame:IsVisible() then
				AuctionFrameTab_OnClick(auctionTab, "LeftButton", false)
			end

--			frame:Show()
--			frame.title:Show()
		end
	end



	local function RecordAuctionEntry(reagentID, count, buyOut, seller,page)
--		print((GetItemInfo(reagentID)), count, math.floor(buyOut/100)/100)
		if count>0 then
			local newEntry = { count = count, buyOut = buyOut, seller = seller, page = page}

			GnomeWorks.data.auctionInventory[reagentID] = (GnomeWorks.data.auctionInventory[reagentID] or 0) + count

			if not auctionData[reagentID] then
				auctionData[reagentID] = { newEntry }
			else
				local list = auctionData[reagentID]
				list[#list + 1] = newEntry
			end
		end
	end





	local function SortAuctionData(a,b)
		local aPer,bPer =  a.buyOut/a.count, b.buyOut/b.count

		if aPer == bPer then
			if a.count == b.count then
				return a.page < b.page
			else
				return a.count < b.count
			end
		else
			return aPer < bPer
		end
	end

	local function FlagCheapest(data, start, count)
		for i=start,#data do
			if data[i].count <= count then
				data[i].buyIt = true
				count = count - data[i].count
			else
				data[i].buyIt = true
				count = count - data[i].count
			end

			if count <= 0 then
				break
			end
		end
	end


	local function FlagForPurchase(itemID, count)
		local data = GnomeWorks.data.auctionData[itemID]

		if data then
			local stillNeeded = count
			FlagCheapest(data, 1, count)
		end
	end



	function GnomeWorks:AUCTION_ITEM_LIST_UPDATE(...)
		if timeOutTimer then
			GnomeWorks:CancelTimer(timeOutTimer, true)
			timeOutTimer = nil
		end

		GnomeWorks:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")

		local num, totalNum = GetNumAuctionItems("list")

		local numPages = math.ceil(totalNum / 50)

		for i=1,num do
			local name, texture, count, _, _, _, _, _, buyOut, _, _, seller = GetAuctionItemInfo("list",i)


			if name == reagentName and buyOut>0 and reagentID then
--print(GetAuctionItemInfo("list",i))
				RecordAuctionEntry(reagentID, count, buyOut, seller, page)
			end
		end

		GnomeWorks:ShowAuctionWindow()

		page = page + 1

		if page < numPages then
			self:ScheduleTimer(SendQuery, .3)
		else

			if auctionData[reagentID] then
				table.sort(auctionData[reagentID], SortAuctionData)
			end

			local player = self.player or UnitName("player")

			if GnomeWorks.data.shoppingQueueData[player].auction then
				FlagForPurchase(reagentID, GnomeWorks.data.shoppingQueueData[player].auction[reagentID] or 0)
			end

			GnomeWorks:ShowAuctionWindow()

			page = 0
			reagentID = next(reagentList, reagentID)
			if reagentID and reagentID > 0 then
				reagentName = GetItemInfo(reagentID)

				self:ScheduleTimer(SendQuery, .3)
			else
				self.auctionScanning = nil
				self:SendMessageDispatch("AuctionScanComplete")
			end
		end
	end


	local function AddReagentsToReagentList(queue, reagents)
		if queue then
			for k,v in ipairs(queue) do
				if v.command == "collect" then
					if GetItemInfo(v.itemID) then
						reagents[v.itemID] = true
					end
				elseif v.command == "create" then
					AddReagentsToReagentList(v.subGroup.entries, reagents)
				end
			end
		end
	end


	function GnomeWorks:BeginReagentScan(player)

		SortAuctionItems("list", "buyout")

		if not IsAuctionSortReversed("list", "buyout") then
			SortAuctionItems("list", "buyout")
		end

		reagentScanAbort = nil

		GnomeWorks:PrepAuctionScan(player)


		auctionData = self.data.auctionData

		if not GnomeWorks.data.auctionInventory then
			GnomeWorks.data.auctionInventory = {}
		end


		for id in pairs(reagentList) do
			if auctionData[id] then
				table.wipe(auctionData[id])

				GnomeWorks.data.auctionInventory[id] = nil
			end
		end


		page = 0
		reagentID = next(reagentList)
		if reagentID then
			reagentName = GetItemInfo(reagentID)

			SendQuery()

			self.auctionScanning = true

			self:SendMessageDispatch("AuctionScan")
		end
	end


	function GnomeWorks:BeginSingleReagentScan(itemID)
		if itemID and GetItemInfo(itemID) then
			auctionData = self.data.auctionData

			self:ShowAuctionWindow()

			reagentList = { [itemID] = 1 }

			if auctionData[itemID] then
				table.wipe(auctionData[itemID])
			end

			GnomeWorks.data.auctionInventory[itemID] = nil


			page = 0
			reagentID = next(reagentList)
			if reagentID then
				reagentName = GetItemInfo(reagentID)

				SendQuery()

				self.auctionScanning = true
				self:SendMessageDispatch("AuctionScan")
			end
		end
	end



	function GnomeWorks:StopReagentScan()
		reagentScanAbort = true
		self.auctionScanning = nil

		self:SendMessageDispatch("AuctionScan AuctionScanComplete")
	end


	function GnomeWorks:PrepAuctionScan(player)
		local queueData = GnomeWorks.data.queueData[player]

		local reagents = table.wipe(reagentList or {})

		AddReagentsToReagentList(queueData, reagents)

--		self:ShowAuctionWindow()


		reagentList = reagents

		if reagentFrame then
			local data = reagentFrame.sf.data.entries

			local n = 0

			for itemID in pairs(reagentList) do
				n = n + 1
				if data[n] then
					data[n].itemID = itemID
				else
					data[n] = { index = n, itemID = itemID }
				end
			end

			reagentFrame.sf.data.numEntries = n

			reagentFrame.sf:Refresh()
		end
	end



	local function WipeDependendInventories(player,key)
		local inventoryIndex = GnomeWorksDB.config.inventoryIndex

		local dependency

		for k,inv in ipairs(inventoryIndex) do
			if inv == key then
				dependency = k
				break
			end
		end

		if dependency then
			for i=dependency,#inventoryIndex do
				if GnomeWorks.data.craftabilityData[player][inventoryIndex[i]] then
					table.wipe(GnomeWorks.data.craftabilityData[player][inventoryIndex[i]])
				end
			end
		end

		GnomeWorks:InventoryScan()
	end


	local ownedPage = 0
	local ownScanRunning

	function ScanOwnedAuctions()
		local player = UnitName("player")
		local numOwned,totalItems = GetNumAuctionItems("owner")
		local invData = GnomeWorks.data.inventoryData[player].sale
		local newItem

		local inventoryIndex = GnomeWorksDB.config.inventoryIndex

--print("scanning auctions", numOwned, totalItems, ownedPage)
		if not ownScanRunning then
			if next(invData) then
				newItem = true

				for itemID,count in pairs(invData) do
					invData[itemID] = 0
				end

				WipeDependendInventories(player, "sale")
			end

			ownedPage = 0
			ownScanRunning = true
		end


		for i=1,numOwned do
			local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus = GetAuctionItemInfo("owner", i)

			if saleStatus ~= 1 then
				local link = GetAuctionItemLink("owner",i)

				local itemID = tonumber(string.match(link,"item:(%d+)"))
--print(i,link, count, itemID)

				if GnomeWorks.data.trackedItems[itemID] then
					invData[itemID] = (invData[itemID] or 0) + count
					newItem = true
				end
			else
--				print(name, highBidder)
			end
		end


		if newItem then
			WipeDependendInventories(player, "sale")
		end

		if numOwned  < totalItems and (ownedPage+1)*NUM_AUCTION_ITEMS_PER_PAGE < totalItems then
			ownedPage = ownedPage + 1
			GetOwnerAuctionItems(ownedPage)
		else
			ownScanRunning = nil
			ownedPage = 0
		end
	end




	function GnomeWorks:AUCTION_HOUSE_SHOW(...)
		self.atAuctionHouse = true

		local player = (GnomeWorks.data.shoppingQueueData[self.player] and self.player) or UnitName("player")

		GnomeWorks:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", ScanOwnedAuctions)


		GetOwnerAuctionItems()



		if not frame then
			self:CreateAuctionWindow()

			buyFrame.sf.data = {}
			buyFrame.sf.selectedIndex = 1
		end




		local auctionQueue = GnomeWorks.data.shoppingQueueData[player].auction

		if auctionQueue and next(auctionQueue) then
			self:ShoppingListShow(self.player)
		end

		self:SendMessageDispatch("AuctionScan")
	end



	function GnomeWorks:AUCTION_HOUSE_CLOSED(...)
		self.atAuctionHouse = false

		if frame then
--			frame:Hide()
--			frame.title:Hide()
		end

		self:StopReagentScan()
	end



	function GnomeWorks:GetAuctionCost(itemID, count, skip)
		local data = self.data.auctionData[itemID]

		if data then
			skip = skip or 0

			local stillNeeded = count
			local cost = 0

			for k,v in pairs(data) do
				if skip < 1 then
					cost = cost + v.buyOut
					stillNeeded = stillNeeded - v.count

					if stillNeeded <= 0 then
						break
					end
				elseif v.count < skip then
					skip = skip - v.count
				else
					-- no cost since we've got some left over
					stillNeeded = stillNeeded - (v.count - skip)
					skip = 0
				end
			end

			return cost
		end

		return 10000000
	end
end
