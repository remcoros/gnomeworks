
local modName, modTable = ...


local VERSION = ("@project-revision@")



GnomeWorks = { plugins = {} }
GnomeWorksDB = {}




LibStub("AceEvent-3.0"):Embed(GnomeWorks)
LibStub("AceTimer-3.0"):Embed(GnomeWorks)

--[[
-- execution holds
-- the idea here is to put off processing until a particular event has fired
-- this is needed for syncing data from the server
do
	local executionHoldFrame = CreateFrame("Frame",nil,UIParent)
	executionHoldFrame.hold = {}

--	executionHoldFrame:RegisterAllEvents()

	executionHoldFrame:SetScript("OnEvent", function(frame, event, ...)
--if string.find(event,"UNIT_SPELL") then
--	print("execution hold system",event)
--end
		if frame.hold[event] then
			for method, params in pairs(frame.hold[event]) do
				GnomeWorks[method](GnomeWorks, event, ...)
			end

			frame.hold[event] = nil

			frame:UnregisterEvent(event)
		end
	end)


	-- this flags an event as delaying operations that need this particular function
	function GnomeWorks:SetExecutionHold(event)
--print("set hold event",event)
		executionHoldFrame:RegisterEvent(event)

		if not executionHoldFrame.hold[event] then
			executionHoldFrame.hold[event] = {}
		end
	end

	-- this function is called by any method that relies on up-to-date info
	-- if there is a hold for the event, then the method is tabled until the event has fired
	function GnomeWorks:GetExecutionHold(event, method, ...)
--print("check for hold on", event)
		if not executionHoldFrame.hold[event] then
			return false
		else
			if not executionHoldFrame.hold[event][method] then
				executionHoldFrame.hold[event][method] = {...}
			end
		end

		return true
	end
end
]]

-- message dispatch
do
	local dispatchTable = {}

	function GnomeWorks:RegisterMessageDispatch(messageList, func)
		for message in string.gmatch(messageList, "%a+") do
			if dispatchTable[message] then
				local t = dispatchTable[message]
				t[#t+1] = func
			else
				dispatchTable[message] = { func }
			end
		end
	end


	function GnomeWorks:SendMessageDispatch(messageList)
		for message in string.gmatch(messageList, "%a+") do
			if dispatchTable[message] then
				t = dispatchTable[message]

				for k,func in pairs(t) do
--collectgarbage("collect")
					if func ~= "delete" then
						if type(func) == "function" and func() then					-- message returns true when it's set to fire once
							t[k] = "delete"
						elseif type(func) == "string" and GnomeWorks[func](GnomeWorks) then
							t[k] = "delete"
						end
					end
				end

				local s,e = 1,#t

				while s <= e do
					if t[s] == "delete" then
						t[s] = t[e]
						t[e] = nil
						e = e - 1
					else
						s = s + 1
					end
				end
			end
		end
	end
end



local defaultConfig = {
	scrollFrameLineHeight = 15,
}




-- handle load sequence
do
	-- To fix Blizzard's bug caused by the new "self:SetFrameLevel(2);"
	local function FixFrameLevel(level, ...)
		for i = 1, select("#", ...) do
			local button = select(i, ...)
			button:SetFrameLevel(level)
		end
	end
	local function FixMenuFrameLevels()
		local f = DropDownList1
		local i = 1
		while f do
			FixFrameLevel(f:GetFrameLevel() + 2, f:GetChildren())
			i = i + 1
			f = _G["DropDownList"..i]
		end
	end

	-- To fix Blizzard's bug caused by the new "self:SetFrameLevel(2);"
	hooksecurefunc("UIDropDownMenu_CreateFrames", FixMenuFrameLevels)


	function memUsage(t)
		local slots = 0
		local bytes = 0
		local size = 1

		for k,v in pairs(t) do
			if type(v)=="table" then
				bytes = bytes + memUsage(v)
			end
			slots = slots + 1
			if slots > size then
				size = size * 2
			end
		end

		return bytes + size * 40
	end

	function GnomeWorks:print(...)
		print("|cffa080f0GnomeWorks:",...)
	end

	function GnomeWorks:warning(...)
		print("|cffff2020GnomeWorks:",...)
	end


	function GnomeWorks:PLAYER_GUILD_UPDATE(...)
		if self.data.playerData[UnitName("player")] then
			self.data.playerData[UnitName("player")].guild = GetGuildInfo("player")

			self:InventoryScan()
		end
	end


	local function InitializeData()
		GnomeWorks:print("Initializing (r"..VERSION..")")

		local player = UnitName("player")

		LoadAddOn("Blizzard_TradeSkillUI")

		GnomeWorks.blizzardFrameShow = TradeSkillFrame_Show

		TradeSkillFrame_Show = function()
		end


		local factionServer = GetRealmName().."-"..UnitFactionGroup("player")


		if LibStub then
			GnomeWorks.libPT = LibStub:GetLibrary("LibPeriodicTable-3.1", true)
--			self.libTS = LibStub:GetLibrary("LibTradeSkill", true)
		end


		local function InitDBTables(var, ...)
			if var then
				if not GnomeWorksDB[var] then
					GnomeWorksDB[var] = {}
				end

				if ... then
					InitDBTables(...)
				end

--				GnomeWorks.data[var] = GnomeWorksDB[var]
			end
		end

		InitDBTables("config", "serverData", "vendorItems", "results", "names", "reagents", "tradeIDs", "vendorOnly")


		for k,v in pairs(defaultConfig) do
			if not GnomeWorksDB.config[k] then
				GnomeWorksDB.config[k] = v
			end
		end


		local function InitServerDBTables(server, var, ...)
			if var then
				if not GnomeWorksDB.serverData[server] then
					GnomeWorksDB.serverData[server] = { [var] = {}}
				else
					if not GnomeWorksDB.serverData[server][var] then
						GnomeWorksDB.serverData[server][var] = {}
					end
				end

				GnomeWorks.data[var] = GnomeWorksDB.serverData[server][var]

				if ... then
					InitServerDBTables(server, player, ...)
				end
			end
		end


		InitServerDBTables(factionServer, "auctionData")


		local function InitServerPlayerDBTables(server, player, var, ...)
			if var then
				if not GnomeWorksDB.serverData[server] then
					GnomeWorksDB.serverData[server] = { [var] = {}}
				else
					if not GnomeWorksDB.serverData[server][var] then
						GnomeWorksDB.serverData[server][var] = {}
					end
				end

				if not GnomeWorksDB.serverData[server][var][player] then
					GnomeWorksDB.serverData[server][var][player] = {}
				end

				GnomeWorks.data[var] = GnomeWorksDB.serverData[server][var]

				if ... then
					InitServerPlayerDBTables(server, player, ...)
				end
			end
		end

		for k, player in pairs({ player, "All Recipes" } ) do
			InitServerPlayerDBTables(factionServer, player, "playerData", "inventoryData", "queueData", "recipeGroupData", "cooldowns", "vendorQueue","bankQueue","guildBankQueue","auctionQueue","altQueue", "knownSpells", "knownItems")
		end


		for player, spellList in pairs(GnomeWorks.data.knownSpells) do
			 local list = {}

			if type(spellList) == "string" then
				for recipeID in string.gmatch(spellList,"(%d+):") do
					list[tonumber(recipeID)] = true
				end
			end

			GnomeWorks.data.knownSpells[player]	= list
		end


		for player, itemList in pairs(GnomeWorks.data.knownItems) do
			 local list = {}

			if type(itemList) == "string" then
				for itemID in string.gmatch(itemList,"(%d+):") do
					list[tonumber(itemID)] = true
				end
			end

			GnomeWorks.data.knownItems[player]	= list
		end



		local trackedItems = {}


		local itemSource = {}
		GnomeWorks.data.itemSource = itemSource

		for recipeID, results in pairs(GnomeWorksDB.results) do
			for itemID, numMade in pairs(results) do
--				GnomeWorks:AddToItemCache(itemID, recipeID, numMade)

				if itemSource[itemID] then
					itemSource[itemID][recipeID] = numMade
				else
					itemSource[itemID] = { [recipeID] = numMade }
				end

				trackedItems[itemID] = true
			end
		end

--		print("itemSource mem usage = ",math.floor(memUsage(itemSource)/1024).."kb")

		local reagentUsage = {}
		GnomeWorks.data.reagentUsage = reagentUsage

		for recipeID, reagents in pairs(GnomeWorksDB.reagents) do
			for itemID, numNeeded in pairs(reagents) do
				if reagentUsage[itemID] then
					reagentUsage[itemID][recipeID] = numNeeded
				else
					reagentUsage[itemID] = { [recipeID] = numNeeded }
				end

				trackedItems[itemID] = true
			end
		end


		GnomeWorks.data.trackedItems = trackedItems


		GnomeWorks.data.groupList = {}

--		print("reagetUsage mem usage = ",math.floor(memUsage(reagentUsage)/1024).."kb")


--		GnomeWorks.data.inventoryData["All Recipes"] = {}
--		GnomeWorks.data.constructionQueue = {}
		GnomeWorks.data.selectionStack = {}

		GnomeWorks:SendMessageDispatch("AddSpoofedRecipes")

--		GnomeWorks:ConstructPseudoTrades("All Recipes")
--		GnomeWorks:ConstructPseudoTrades(player)

--		GnomeWorks:PopulateQueues()


		GnomeWorks.groupLabel = "By Category"



		GnomeWorks.data.toonList = {}
		local list = GnomeWorks.data.toonList

		for toon in pairs(GnomeWorks.data.playerData) do
			if toon ~= player and toon ~= "All Recipes" then
				table.insert(list,toon)
			end
		end

		table.sort(list)
		table.insert(list,"All Recipes")
		table.insert(list,1,player)

		SetTradeSkillSubClassFilter(0, 1, 1)
		SetTradeSkillItemNameFilter("")
		SetTradeSkillItemLevelFilter(0,0)

		return true
	end


	function GnomeWorks:PLAYER_LOGOUT()
		for inventoryName,inventoryData in pairs(self.data.inventoryData) do
			for container, containerData in pairs(inventoryData) do
				for itemID, num in pairs(containerData) do
					if num == 0 then
						containerData[itemID] = nil
					end
				end
			end
		end

		local function ConcatLists(list)
			for player,listData in pairs(self.data[list]) do
				local array = {}

				for id in pairs(listData) do
					array[#array+1] = id
				end

				array[#array+1] = ":"

				self.data[list][player] = table.concat(array,":")
			end
		end

		ConcatLists("knownSpells")
		ConcatLists("knownItems")
	end


--[[
	function GnomeWorks:CHAT_MSG_SYSTEM(event,arg1)
print("CHAT_MSG_SYSTEM",arg1)
		if string.find(arg1,ERR_SKILL_UP_SI) then
print(arg1)
			self:DoTradeSkillUpdate()
		end

		if string.find(arg1,ERR_LEARN_RECIPE_S) then
print(arg1)
			self:DoTradeSkillUpdate()
		end
	end
]]

	local function RegisterEvents()
		GnomeWorks:RegisterEvent("MERCHANT_UPDATE")
		GnomeWorks:RegisterEvent("MERCHANT_SHOW")
		GnomeWorks:RegisterEvent("MERCHANT_CLOSE")


		GnomeWorks:RegisterEvent("BAG_UPDATE")

		GnomeWorks:RegisterEvent("BANKFRAME_OPENED")
		GnomeWorks:RegisterEvent("BANKFRAME_CLOSED")

		GnomeWorks:RegisterEvent("GUILDBANKFRAME_OPENED")
		GnomeWorks:RegisterEvent("GUILDBANKFRAME_CLOSED")
		GnomeWorks:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")

		GnomeWorks:RegisterEvent("PLAYER_GUILD_UPDATE")


		GnomeWorks:RegisterEvent("AUCTION_HOUSE_SHOW")
		GnomeWorks:RegisterEvent("AUCTION_HOUSE_CLOSE")

		GnomeWorks:RegisterEvent("PLAYER_LOGOUT")
		return true
	end


	local function ParseTradeLinks()
		return GnomeWorks:ParseSkillList()
	end


	local function CreateUI()
		if not InCombatLockdown() then
			GnomeWorks.MainWindow = GnomeWorks:CreateMainWindow()

			GnomeWorks.QueueWindow = GnomeWorks:CreateQueueWindow()

			if IsAddOnLoaded("AddOnLoader") then
				GnomeWorks.MainWindow:Hide()
			end

			GnomeWorks:RegisterEvent("TRADE_SKILL_SHOW")
	--		GnomeWorks:RegisterEvent("TRADE_SKILL_UPDATE")
			GnomeWorks:RegisterEvent("TRADE_SKILL_CLOSE")

			GnomeWorks:RegisterEvent("CHAT_MSG_SKILL")

			GnomeWorks:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "SpellCastCompleted")

			GnomeWorks:RegisterEvent("UNIT_SPELLCAST_FAILED", "SpellCastFailed")
			GnomeWorks:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "SpellCastFailed")

			GnomeWorks:RegisterEvent("UNIT_SPELLCAST_STOP", "SpellCastStop")
			GnomeWorks:RegisterEvent("UNIT_SPELLCAST_START", "SpellCastStart")

			for name,plugin in pairs(GnomeWorks.plugins) do
	--print("initializing",name)
				plugin.loaded = plugin.initialize()
			end


			hooksecurefunc("SetItemRef", function(s,link,button)
				if string.find(s,"trade:") then
					GnomeWorks:CacheTradeSkillLink(link)
				end
			end)

			collectgarbage("collect")

			GnomeWorks:ScheduleTimer("TRADE_SKILL_UPDATE", 0.01)

			return true
		end
	end


	local function ParseKnownRecipes()

--		GnomeWorks:ScheduleTimer(function() GnomeWorks:DecodeTradeLinks(CreateUI) end, 2)

		return true
	end



	function GnomeWorks:OnTradeSkillShow()
		self:Initialize()

		GnomeWorks:TRADE_SKILL_SHOW()
		GnomeWorks:TRADE_SKILL_UPDATE()
	end

	local initList = LibStagedExecution:NewList()




	if not IsAddOnLoaded("AddOnLoader") then
		GnomeWorks:RegisterEvent("ADDON_LOADED", function(event, name)
			if string.lower(name) == string.lower(modName) then
				GnomeWorks:UnregisterEvent(event)
--				GnomeWorks:ScheduleTimer("OnLoad",.01)



				initList:AddSegment(InitializeData)
				initList:AddSegment(ParseTradeLinks)
				initList:AddSegment(ParseKnownRecipes)
				initList:AddSegment(CreateUI)
				initList:AddSegment(RegisterEvents)


				initList:Execute()
			end
		end )
	else
		GnomeWorks:RegisterEvent("ADDON_LOADED", function(event, name)
--			print("gnomeworks detected the loading of "..tostring(name))
			if string.lower(name) == string.lower(modName) then
				GnomeWorks:UnregisterEvent(event)

				initList:AddSegment(InitializeData)
				initList:AddSegment(ParseTradeLinks)
				initList:AddSegment(ParseKnownRecipes)
				initList:AddSegment(CreateUI)
				initList:AddSegment(RegisterEvents)


				initList:Execute()

--				GnomeWorks:ScheduleTimer("OnLoad",1)
--				GnomeWorks:OnLoad()
--				GnomeWorks:Initialize()
--				GnomeWorks.MainWindow:Hide()

			end
		end)
	end
end


