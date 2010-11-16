



local GnomeWorks = GnomeWorks

do
	local shoppingListFrame
	local shoppingListPlayer

	local queueList = { "bank", "guildBank", "alt", "vendor", "auction" }

	local inventoryColors = {
--		queue = "|cffff0000",
		bag = "|cffffff80",
		vendor = "|cff80ff80",
		bank =  "|cffffa050",
		guildBank = "|cff5080ff",
		alt = "|cffff80ff",
		auction = "|cffb0b000",
	}


	local columnHeaders = {
		{
			name = "#",
			align = "CENTER",
			width = 30,
			font = "GameFontHighlightSmall",
			draw =	function (rowFrame,cellFrame,entry)
						cellFrame.text:SetTextColor(1,1,1)
						cellFrame.text:SetText(entry.count)
					end,
		}, -- [1]
		{
--			font = "GameFontHighlight",
			button = {
				normalTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				highlightTexture = "Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga",
				width = 14,
				height = 14,
			},
			name = "Reagent",
			width = 250,
			OnClick = function(cellFrame, button, source)
							if cellFrame:GetParent().rowIndex>0 then
								local entry = cellFrame:GetParent().data

								if entry.subGroup and source == "button" then
									entry.subGroup.expanded = not entry.subGroup.expanded
									sf:Refresh()
								else
--									if entry.source == "bank" then
										if GnomeWorks.atBank then
											GnomeWorks:BankCollectItems(entry.itemID, entry.count)
										end
--									elseif entry.source == "guildBank" then
										if GnomeWorks.atGuildBank then
											GnomeWorks:GuildBankCollectItems(entry.itemID, entry.count)
										end
--									elseif entry.source == "vendor" then
										if GnomeWorks.atVendor then
											GnomeWorks:BuyVendorItems(GnomeWorks.player, entry.itemID, entry.count)
										end
--									elseif entry.source == "auction" then
										if GnomeWorks.atAuctionHouse then
											GnomeWorks:BeginSingleReagentScan(entry.itemID)
										end
--									end
								end
							else
								if source == "button" then
									cellFrame.collapsed = not cellFrame.collapsed

									if not cellFrame.collapsed then
										GnomeWorks:CollapseAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
									else
										GnomeWorks:ExpandAllHeaders(sf.data.entries)
										sf:Refresh()

										cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
										cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
									end
								end
							end
						end,
			draw =	function (rowFrame,cellFrame,entry)
						cellFrame.text:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8+4+12, 0)
						cellFrame.button:SetPoint("LEFT", cellFrame, "LEFT", entry.depth*8, 0)

						if entry.subGroup then
							if entry.subGroup.expanded then
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_open.tga")
							else
								cellFrame.button:SetNormalTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
								cellFrame.button:SetHighlightTexture("Interface\\AddOns\\GnomeWorks\\Art\\expand_arrow_closed.tga")
							end

							cellFrame.button:Show()

							cellFrame.text:SetFormattedText("%s%s",entry.color,entry.name)

							cellFrame.text:SetFontObject("GameFontHighlight")
						else
							cellFrame.button:Hide()

							cellFrame.text:SetFormattedText("|T%s:%d:%d:0:-2|t %s%s", GetItemIcon(entry.itemID) or "",cellFrame:GetHeight()+1,cellFrame:GetHeight()+1,entry.color,(GetItemInfo(entry.itemID)) or "item:"..entry.itemID)

							cellFrame.text:SetFontObject("GameFontHighlightsmall")
						end
					end,
		}, -- [2]
	}


	function GnomeWorks:ShoppingListUpdate(player)
		if sf then
			player = player or self.player

			for k,queue in pairs(queueList) do
				local itemCount = 0

				if not sf.data.entries[k] then
					sf.data.entries[k] = {}
					sf.data.entries[k].subGroup = { expanded = true, entries = {} }
				end

				sf.data.entries[k].name = queue
				sf.data.entries[k].index = k

				sf.data.entries[k].color = inventoryColors[queue]

				local data = sf.data.entries[k].subGroup.entries

				if self.data[queue.."Queue"][player] then
					for itemID,count in pairs(self.data[queue.."Queue"][player]) do
						if count then
							itemCount = itemCount + 1

	--print((GetItemInfo(itemID)),"x",count)

							if data[itemCount] then
								data[itemCount].itemID = itemID
								data[itemCount].count = count
								data[itemCount].index = itemCount
							else
								data[itemCount] = { itemID = itemID, count = count, index = itemCount, color = inventoryColors[queue], source = queue }
							end
						end
					end
				end

				sf.data.entries[k].subGroup.numEntries = itemCount
			end

			sf:Refresh()
		end
	end


	function GnomeWorks:ShoppingListShow(player)
		if sf then												-- it's possible that this might get called prior to full initialization
			if LSW and LSW.Initialize then
				LSW:Initialize()
			end

			local parentFrame = sf:GetParent():GetParent()

			parentFrame:Show()

			self:ShoppingListUpdate(player)
		end
	end


	function GnomeWorks:BuildShoppingListScrollFrame(frame)

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


		shoppingListFrame = CreateFrame("Frame",nil,frame)
		shoppingListFrame:SetPoint("BOTTOMLEFT",20,20)
		shoppingListFrame:SetPoint("TOP", frame, "CENTER", 0, -85)
		shoppingListFrame:SetPoint("RIGHT", frame, -20,0)



		sf = GnomeWorks:CreateScrollingTable(shoppingListFrame, ScrollPaneBackdrop, columnHeaders, ResizeFrame)

		sf.data = { entries = {} }

		self:RegisterMessageDispatch("GnomeWorksQueueCountsChanged GnomeWorksInventoryScanComplete", function() GnomeWorks:ShoppingListUpdate() end)

--[[
		sf.IsEntryFiltered = function(self, entry)
			if entry.manualEntry then
				return false
			end


--			if true then return false end

--print("filter", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numNeeded)
			if entry.command == "collect" and entry.count < 1 then
				return true
			elseif entry.command == "create" and entry.count < 1 then
				return true
			else
--print("filter", entry.command, GetItemInfo(entry.itemID), entry.numAvailable, entry.count, entry.numBag, entry.numNeeded)
				return false
			end
		end
]]
--[[
		local function UpdateRowData(scrollFrame,entry,firstCall)
			local player = shoppingListPlayer
--print("update row data", entry.command, entry.recipeID and GetSpellLink(entry.recipeID) or entry.itemID and GetItemInfo(entry.itemID))

			local itemID = entry.itemID
			local recipeID = entry.recipeID

			if itemID then
				entry.inQueue = GnomeWorks:GetInventoryCount(itemID, player, "queue")

				entry.bag = GnomeWorks:GetInventoryCount(itemID, player, "bag")
				entry.bank = GnomeWorks:GetInventoryCount(itemID, player, "bank")
				entry.guildBank = GnomeWorks:GetInventoryCount(itemID, player, "guildBank")
				entry.alt = GnomeWorks:GetInventoryCount(itemID, "faction", "bank")
			end

			if entry.command == "create" then
				if entry.numCraftable >= entry.count then
					if entry.subGroup then
						entry.subGroup.expanded = false
					end
				end

				if entry.count > 0 then
					entry.noHide = true
				else
					entry.noHide = false
				end
			end

--print("done updating")
		end


		sf:RegisterRowUpdate(UpdateRowData)
]]
	end
end


