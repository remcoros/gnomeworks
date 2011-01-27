
local modName, modTable = ...


local VERSION = ("@project-revision@")

if not tonumber(VERSION) then
	VERSION = "113"
end


GnomeWorks = { plugins = {} }
GnomeWorksDB = {}




LibStub("AceEvent-3.0"):Embed(GnomeWorks)
LibStub("AceTimer-3.0"):Embed(GnomeWorks)



do
	local f = CreateFrame("Frame")


	f:SetScript("OnEvent",function(f,...)
		print(...)
	end)

--	f:RegisterAllEvents()

end



do
	local f = CreateFrame("Frame")

	local timer = {}
	local handler = {}
	local failure = {}


--	GnomeWorks:ExecuteOnEvent("UPDATE_PENDING_MAIL", ProcessPurchase, entry, 0.25, ReportFailedPurchase)



	function GnomeWorks:ExecuteOnEvent(event, funcSuccess, argSuccess, timeOut, funcFail, argFail)
		timer[event] = timeOut
		handler[event] = { funcSuccess, argSuccess }
		failure[event] = { funcFail, argFail }

		f:RegisterEvent(event)
	end


	local function RemoveEvent(event)
		timer[event] = nil
		handler[event] = nil
		failure[event] = nil
		f:UnregisterEvent(event)
	end


	local function EventHandler(frame, event, ...)
		if handler[event] then
			local func,arg = unpack(handler[event])

			func(arg,...)
			RemoveEvent(event)
		end
	end


	local function OnUpdate(frame, elapsed)
		for event in pairs(failure) do
			if timer[event] then
				timer[event] = timer[event] - elapsed
				if timer[event] < 0 then
					local func,arg = unpack(failure[event])

					if func then
						func(arg)
					end

					RemoveEvent(event)
				end
			end
		end
	end


	f:SetScript("OnUpdate", OnUpdate)

	f:SetScript("OnEvent", EventHandler)

end


do
	local tipBackDrop = {
			bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
			tile=true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 4 }
		}

	local pluginInputBox = CreateFrame("Frame", nil, UIParent)

	pluginInputBox:SetBackdrop(tipBackDrop)
	pluginInputBox:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	pluginInputBox:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)

	pluginInputBox:SetHeight(40)
	pluginInputBox:SetWidth(150)
	pluginInputBox:Hide()

	do
		local label = pluginInputBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		label:SetPoint("TOPLEFT",5,-5)
		label:SetHeight(13)
		label:SetPoint("RIGHT",-5,0)
		label:SetJustifyH("LEFT")

		pluginInputBox.label = label

		local editBox = CreateFrame("EditBox",nil,pluginInputBox)
		editBox:SetPoint("BOTTOMLEFT",5,5)
		editBox:SetHeight(13)
		editBox:SetPoint("RIGHT",-5,0)
		editBox:SetJustifyH("LEFT")

		editBox:SetAutoFocus(true)

		editBox:SetScript("OnEnterPressed",function(f) pluginInputBox:Hide() EditBox_ClearFocus(f) pluginInputBox:SetVariable(f:GetText()) end)
		editBox:SetScript("OnEscapePressed", function(f) pluginInputBox:Hide() EditBox_ClearFocus(f) end)
		editBox:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
		editBox:SetScript("OnEditFocusGained", EditBox_HighlightText)

		editBox:EnableMouse(true)
		editBox:SetFontObject("GameFontHighlightSmall")

		pluginInputBox.editBox = editBox

		pluginInputBox:SetScript("OnUpdate", function(p)
			UIDropDownMenu_StopCounting(p.button:GetParent())
		end)


		pluginInputBox:SetScript("OnHide", function(p)
			p:Hide()
		end)
	end


	local function buttonAddButton(button, text, func)
		if not button.menuList then
			button.menuList = {}
			button.hasArrow = true
		end

		local new = { text = text, func = func }

		table.insert(button.menuList, new)

		return new
	end


	local function AddButton(plugin, text, func)
		local new = { text = text, func = func }

		new.AddButton = buttonAddButton

		table.insert(plugin.menuList, new)

		return new
	end


	function pluginInputBox:SetVariable(value)
		local varTable = pluginInputBox.varTable
		varTable.value = value
		pluginInputBox.plugin:Update()

		varTable.menuButton.text = string.format(varTable.format, varTable.value)
		pluginInputBox.button:SetText(varTable.menuButton.text)
	end



	local function DoTextEntry(button, plugin, var)
		pluginInputBox.label:SetText(plugin.variables[var].label)
		pluginInputBox.editBox:SetText(plugin.variables[var].value)
		pluginInputBox:Show()
		pluginInputBox:SetPoint("TOPLEFT",button,"TOPRIGHT",10,0)

		pluginInputBox.plugin = plugin
		pluginInputBox.varTable = plugin.variables[var]
		pluginInputBox.button = button

--		UIDropDownMenu_StopCounting(button:GetParent())
		pluginInputBox:SetParent(button)
	end


	local function AddInput(plugin, var)
		if plugin.variables[var] then
			local new = {
				arg1 = plugin,
				arg2 = var,
				notCheckable = true,
				func = DoTextEntry,
				keepShownOnClick = true,
			}


			new.text = string.format(plugin.variables[var].format, plugin.variables[var].value)

			plugin.variables[var].menuButton = new

			table.insert(plugin.menuList, new)

			return new
		else
			GnomeWorks:warning(plugin.name,"tried to add an input entry a non-existant variable ("..(var or "nil")..")")
		end
	end


	--[[

		GnomeWorks:RegisterPlugin(name, initialize)

		name - name of plugin (eg "LilSparky's Workshop")
		initialize - function to call prior to initializing gnomeworks

		returns plugin table (used for connecting other functions to plugin)
	]]

	function GnomeWorks:RegisterPlugin(name, initialize)
		local plugin = {
			name = name,
			AddButton = AddButton,
			AddInput = AddInput,
			enabled = true,
			initialize = initialize,
			menuList = {
			},
			variables = {
			},
			Update = function() end,
		}

		GnomeWorks.plugins[name] = plugin

		return plugin
	end
end


do
	GnomeWorks.system = {
		inventoryIndex = { "bag", "vendor", "bank", "mail", "sale", "guildBank", "alt" },

		inventoryColorBlindTag = {
			bag = "",
			vendor = "v",
			bank = "b",
			mail = "m",
			sale = "s",
			guildBank = "g",
			alt = "a",
			auction = "$",
		},

		inventoryColors = {
			bag = 		"|cffffff80",		-- yellow
			vendor = 	"|cff80ff80",		-- green
			bank =  	"|cffffa050",		-- salmon
			guildBank = "|cff5080ff",		-- blue
			alt = 		"|cffff80ff",		-- pink
			auction = 	"|cffb0b000",		-- gold
			mail = 		"|cff60fff0",		-- teal
			sale = 		"|cff30b080",		-- dark green
		},

		inventoryFormat = {},

		inventoryTags = {},

		factionContainer = "guildBank",

		inventoryBasis = {
			bag = "bag queue",
			vendor = "bag vendor queue",
			bank = "bag vendor bank queue",
			mail = "bag vendor bank mail queue",
			sale = "bag vendor bank mail sale queue",
			guildBank = "bag vendor bank mail sale guildBank queue",
		},


		containerIndex = { "bag", "bank", "mail", "sale" },

		collectInventories = { "bank", "mail", "sale", "guildBank", "alt" },
	}


	for k,v in pairs(GnomeWorks.system.inventoryColors) do
		GnomeWorks.system.inventoryTags[k] = v..k

		if ( ENABLE_COLORBLIND_MODE == "1" ) then
			GnomeWorks.system.inventoryFormat[k] = string.format("%%s|cffa0a0a0%s|r", GnomeWorks.system.inventoryColorBlindTag[k])
		else
			GnomeWorks.system.inventoryFormat[k] = string.format("%s%%s|r",v)
		end
	end



	function GnomeWorks:SetUpColorBlindMode(state)
		for k,v in pairs(GnomeWorks.system.inventoryColors) do
			if ( state == "1" ) then
				GnomeWorks.system.inventoryFormat[k] = string.format("%%d|cffa0a0a0%s|r", GnomeWorks.system.inventoryColorBlindTag[k])
			else
				GnomeWorks.system.inventoryFormat[k] = string.format("%s%%d|r",v)
			end
		end

		GnomeWorks:SendMessageDispatch("SkillListChanged")
	end
end



local defaultConfig = {
	scrollFrameLineHeight = 15,
	currentGroup = { self = {}, alt = {} },
	currentFilter = { self = {}, alt = {} },

	inventoryTracked = {
		bag = true,
		vendor = true,
		bank = true,
		guildBank = true,
		alt = true,
		mail = true,
		sale = true
	},

	inventoryIndex = { "bag", "vendor", "bank", "mail", "sale", "guildBank", "alt" },

	containerIndex = { "bag", "bank", "mail", "sale" },

	collectInventories = { "bank", "mail", "sale", "guildBank", "alt" },

	altGuildAccess = {},
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

	function GnomeWorks:printf(format,...)
		self:print(string.format(format,...))
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
		local clientVersion, clientBuild = GetBuildInfo()

		GnomeWorks:print("Initializing (r"..VERSION..")")

		if GnomeWorks.serverData and tonumber(GnomeWorksDB.gwVersion or 0) < 111 then
			GnomeWorksDB.serverData = {}
			GnomeWorks:warning("deleting server data due to format change")
		end

		GnomeWorksDB.gwVersion = VERSION


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



		local function DeepCopy(src,dst)
			for k,v in pairs(src) do
				if dst[k] == nil then
					dst[k] = v
				else
					if type(v) == "table" then
						if type(dst[k]) ~= "table" then
							dst[k] = {}
						end

						DeepCopy(v, dst[k])
					end
				end
			end
		end


		if not GnomeWorksDB.config then
			GnomeWorksDB.config = {}
		end


		DeepCopy(defaultConfig, GnomeWorksDB.config)



		local function InitDBTables(var, ...)
			if var then
				if not GnomeWorksDB[var] then
					GnomeWorksDB[var] = {}
				end

				if ... then
					InitDBTables(...)
				end
			end
		end

		InitDBTables("serverData", "vendorItems", "results", "names", "reagents", "tradeIDs", "skillUps", "vendorOnly")



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
					InitServerDBTables(server, ...)
				end
			end
		end


		InitServerDBTables(factionServer, "guildInventory", "auctionInventory")


--		InitServerDBTables(factionServer, "auctionData")


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
			InitServerPlayerDBTables(factionServer, player, "playerData", "inventoryData", "craftabilityData", "shoppingQueueData", "queueData", "recipeGroupData", "cooldowns", "knownSpells", "knownItems")

			local invData = GnomeWorks.data.inventoryData[player]
			local craftabilityData = GnomeWorks.data.craftabilityData[player]
			local shoppingQueueData = GnomeWorks.data.shoppingQueueData[player]

			for k, container in pairs(GnomeWorksDB.config.inventoryIndex) do
				if container ~= "alt" and container ~= "vendor" and container ~= "guildBank" then
					if not invData[container] then
						invData[container] = {}
					end
				end

				if not craftabilityData[container] then
					craftabilityData[container] = {}
				end

				if container ~= "bag" then
					if not shoppingQueueData[container] then
						shoppingQueueData[container] = {}
					end
				end
			end

			if not shoppingQueueData.auction then
				shoppingQueueData.auction = {}
			end
		end

		GnomeWorks.data.auctionData = {}

--		InitServerPlayerDBTables(factionServer, "auctionHouse", "inventoryData")
--		GnomeWorks.data.inventoryData.auctionHouse = {}

		GnomeWorks.data.skillUpRanks = {}


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

		GnomeWorks.data.trainableSpells = {}

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

		GnomeWorks:BuildInventoryHeirarchy()


		GnomeWorks.data.selectionStack = {}

		GnomeWorks:SendMessageDispatch("AddSpoofedRecipes")



		GnomeWorks.data.groupList = {}

--		print("reagetUsage mem usage = ",math.floor(memUsage(reagentUsage)/1024).."kb")




		GnomeWorks.groupLabel = "By Category"

		GnomeWorks:InventoryScan()


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
		TradeSkillOnlyShowSkillUps(false)
		TradeSkillOnlyShowMakeable(false)
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

		for inventoryName,inventoryData in pairs(self.data.craftabilityData) do
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


		GnomeWorks:RegisterEvent("TRAINER_UPDATE")
		GnomeWorks:RegisterEvent("TRAINER_SHOW")
		GnomeWorks:RegisterEvent("TRAINER_CLOSE")


		GnomeWorks:RegisterEvent("BAG_UPDATE")

		GnomeWorks:RegisterEvent("BANKFRAME_OPENED")
		GnomeWorks:RegisterEvent("BANKFRAME_CLOSED")

		GnomeWorks:RegisterEvent("GUILDBANKFRAME_OPENED")
		GnomeWorks:RegisterEvent("GUILDBANKFRAME_CLOSED")
		GnomeWorks:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")

		GnomeWorks:RegisterEvent("PLAYER_GUILD_UPDATE")


		GnomeWorks:RegisterEvent("AUCTION_HOUSE_SHOW")
		GnomeWorks:RegisterEvent("AUCTION_HOUSE_CLOSED")

		GnomeWorks:RegisterEvent("PLAYER_LOGOUT")


		GnomeWorks:RegisterEvent("MAIL_SHOW")
		GnomeWorks:RegisterEvent("MAIL_INBOX_UPDATE")
		GnomeWorks:RegisterEvent("MAIL_CLOSED")


		GnomeWorks:ScheduleRepeatingTimer(function() GnomeWorks:SendMessageDispatch("HeartBeat") end, 5)


		GnomeWorks:InventoryScan()

		return true
	end


	local function ParseTradeLinks()
		return GnomeWorks:ParseSkillList()
	end


	local function RegisterSlashCommands()
		SLASH_GNOMEWORKS1 = "/gw"


		local function SlashHandler(message, editbox)
			if message then
				local command, args = string.lower(message):match("^(%S*)%s*(.-)$")

				if GnomeWorks.commands[command] then
					GnomeWorks.commands[command](args)
				else
					GnomeWorks:warning("unrecognized command:",command,args)
				end
			end
		end

		SlashCmdList["GNOMEWORKS"] = SlashHandler

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

			GnomeWorks:RegisterEvent("GUILD_RECIPE_KNOWN_BY_MEMBERS")

--			GnomeWorks:RegisterEvent("GUILD_ROSTER_UPDATE")

			for name,plugin in pairs(GnomeWorks.plugins) do
	--print("initializing",name)
				local status, returnValue = pcall(plugin.initialize)
				if status then
					plugin.loaded = returnValue
				else
					GnomeWorks:warning(name,"could not be initialized")
					GnomeWorks:warning(returnValue)
				end
			end


			hooksecurefunc("SetItemRef", function(s,link,button)
				if string.find(s,"trade:") then
					GnomeWorks:CacheTradeSkillLink(link)
				end
			end)

			collectgarbage("collect")

			GnomeWorks:ScheduleTimer("TRADE_SKILL_UPDATE", 0.01)

			RegisterSlashCommands()

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



	GnomeWorks:RegisterEvent("CVAR_UPDATE", function(event,cvar,state)
		if cvar == "USE_COLORBLIND_MODE" then
			GnomeWorks:SetUpColorBlindMode(state)
		end
	end)


	initList:AddSegment(InitializeData, "GnomeWorks: InitializeData")
	initList:AddSegment(ParseTradeLinks, "GnomeWorks: ParseTradeLinks")
	initList:AddSegment(ParseKnownRecipes, "GnomeWorks: ParseKnownRecipes")
	initList:AddSegment(CreateUI, "GnomeWorks: CreateUI")
	initList:AddSegment(RegisterEvents, "GnomeWorks: RegisterEvents")

	local function registerLoad()
--print("gw registering addon_load event")
		GnomeWorks:RegisterEvent("ADDON_LOADED", function(event, name)
--		print("gnomeworks detected the loading of "..tostring(name))
			if string.lower(name) == string.lower(modName) then
				GnomeWorks:UnregisterEvent(event)

				initList:Execute()
			end
		end)
	end


	registerLoad()

--	GnomeWorks:ScheduleTimer(registerLoad, 0.0)

--	print("gw parsed")
end


