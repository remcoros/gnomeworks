






do
	local GnomeWorks = GnomeWorks

	local clientVersion, clientBuild = GetBuildInfo()


	local frame = CreateFrame("Button")

	local frameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frameText:SetJustifyH("CENTER")
	frameText:SetPoint("LEFT")
	frameText:SetPoint("RIGHT")
	frameText:SetPoint("BOTTOM")
	frameText:SetTextColor(1,1,1)
	frameText:SetText("GnomeWorks")


	local frameInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frameInfo:SetJustifyH("CENTER")
	frameInfo:SetPoint("LEFT")
	frameInfo:SetPoint("RIGHT")
	frameInfo:SetPoint("TOP")
	frameInfo:SetTextColor(1,1,1)
	frameInfo:SetText("Click to skip stalled scans")



	local linkDecodeList = {}
	local playerNameList = {}

	local decodeIndex
	local scanDepth

	local callBack

	local frameOpen

	local deactivatedFrames = {}


	local unlinkableTrades = {
		[2656] = true,         -- smelting (from mining)
		[53428] = true,			-- runeforging
		[51005] = true,			-- milling
		[13262] = true,			-- disenchant
		[31252] = true,			-- prospecting

		[100000] = true,		-- "Common Skills",
		[100001] = true,		-- "Vendor Conversion",
	}


	local function DeactivateEvents(event)
--print("deactivate frames for",event)
		deactivatedFrames[event] = { GetFramesRegisteredForEvent(event) }

		for k,f in pairs(deactivatedFrames[event]) do
--print("deactivate frame: ",f:GetName() or f)
			f:UnregisterEvent(event)
		end
	end


	local function ReactivateEvents(event)
--print("reactivate frames for",event)
		if deactivatedFrames[event] then
			for k,f in pairs(deactivatedFrames[event]) do
				f:RegisterEvent(event)
--print("reactivate frame: ",f:GetName() or f)
			end

			deactivatedFrames[event] = nil
		end
	end


	local function ExitDecodeProcess()
		frame:Hide()

		frame:UnregisterEvent("TRADE_SKILL_SHOW")
--		frame:UnregisterEvent("TRADE_SKILL_UPDATE")
		frame:UnregisterEvent("TRADE_SKILL_CLOSE")

		frame:SetScript("OnEvent", nil)

		local playerList = GnomeWorks.data.playerData

		for playerName, playerData in pairs(playerList) do
			if playerName ~= "All Recipes" then
				local linkList = playerData.links

				if linkList then
					for tradeID, tradeLink in pairs(linkList) do
						GnomeWorks:RecordKnownSpells(tradeID, playerName)
					end
				end
			end
		end

		ReactivateEvents("TRADE_SKILL_SHOW")
		ReactivateEvents("TRADE_SKILL_UPDATE")

--print("done scanning known skills")
		GnomeWorks:ScheduleTimer(callBack,.25)
	end



	local function OpenNextLink()
		decodeIndex = decodeIndex + 1
--print("open next link")

		if decodeIndex <= #linkDecodeList then
--print(linkDecodeList[decodeIndex])
frameText:SetText("Scanning: "..playerNameList[decodeIndex].." "..linkDecodeList[decodeIndex])
			local tradeString = string.match(linkDecodeList[decodeIndex], "(trade:%d+:%d+:%d+:[0-9a-fA-F]+:[A-Za-z0-9+/]+)")
			ItemRefTooltip:SetHyperlink(tradeString)
		else
			if false and decodeIndex == #linkDecodeList+1 and GetSpellInfo(GetSpellInfo(2656)) then		-- forced false because it appears castspellbyname is protected and needs a mouse click

				local smelting = GetSpellInfo(2656)

				CastSpellByName(smelting) -- force a scan of smelting because smelting links don't work
			else
				GnomeWorks:ScheduleTimer(ExitDecodeProcess,.01)
--				ExitDecodeProcess()
			end
		end
	end

	local function OnUpdate(frame, elapsed)
		frame.countDown = (frame.countDown or 0) - elapsed

		if frame.countDown < 0 then
			if linkDecodeList[decodeIndex] then
				local tradeString = string.match(linkDecodeList[decodeIndex], "(trade:%d+:%d+:%d+:[0-9a-fA-F]+:[A-Za-z0-9+/]+)")
				ItemRefTooltip:SetHyperlink(tradeString)
			end

			local isLinked,playerName = IsTradeSkillLinked()

			local recipeCount = 0


			local numTradeSkills = GetNumTradeSkills()
			for i = 1, numTradeSkills do
				local gotNil = false

				if GetTradeSkillItemLink(i) then -- and GetItemInfo(GetTradeSkillItemLink(i)) then
					local numReagents = GetTradeSkillNumReagents(i)
					for r = 1, numReagents do
						if not GetTradeSkillReagentItemLink(i,r) then -- or not GetItemInfo(GetTradeSkillReagentItemLink(i,r)) then
							gotNil = true
							break
						end
					end
				else
					local name, skillType = GetTradeSkillInfo(i)

					if skillType ~= "header" then
						gotNil = true
					end
				end

				if not gotNil then
					recipeCount = recipeCount + 1
				end
			end


			if playerName then
				frameText:SetText((playerName or "??").." "..(linkDecodeList[decodeIndex] or "??").." "..(recipeCount or "??").."/"..numTradeSkills.." recipes")
			else
				playerName = UnitName("player")

				local tradeName = GetTradeSkillLine()

				frameText:SetText(playerName.." "..tradeName.." "..numTradeSkills.." recipes")
			end



			frame.countDown = 1
		end
	end


	local function ScanEventHandler(frame, event)
--print("Scan Event Handler",event)
		if event == "TRADE_SKILL_SHOW" then
			TradeSkillSetFilter(-1, -1)

			local isLinked, playerName = IsTradeSkillLinked()
			local numSkills = GetNumTradeSkills())

			if playerName and linkDecodeList[decodeIndex] then
				frameText:SetText(playerName.." "..linkDecodeList[decodeIndex].." "..numSkills.." recipes")
--print(playerName.." "..linkDecodeList[decodeIndex].." "..GetNumTradeSkills().." recipes")
			else
				playerName = UnitName("player")

				local tradeName = GetTradeSkillLine()

				frameText:SetText(playerName.." "..tradeName.." "..numSkills.." recipes")
			end


			local recipeCount = 0

			for i = 1, numSkills do
				local gotNil = false

				if GetTradeSkillItemLink(i) then --  and GetItemInfo(GetTradeSkillItemLink(i)) then
					local numReagents = GetTradeSkillNumReagents(i)
					for r = 1, numReagents do
						if not GetTradeSkillReagentItemLink(i,r) then -- or not GetItemInfo(GetTradeSkillReagentItemLink(i,r)) then
							gotNil = true
							break
						end
					end
				else
					local name, skillType = GetTradeSkillInfo(i)

					if skillType ~= "header" then
						gotNil = true
					end
				end

				if not gotNil then
					recipeCount = recipeCount + 1
				end
			end


			local skillName, skillType = GetTradeSkillInfo(1)
			local gotNil


			if recipeCount == numSkills then
				local knownSpells = GnomeWorks.data.knownSpells[playerName]
				local knownItems = GnomeWorks.data.knownItems[playerName]

				for i = 1, numSkills do
					local _,skillType = GetTradeSkillInfo(i)

					if skillType ~= "header" then
						local recipeLink = GetTradeSkillRecipeLink(i)

						if not recipeLink then
							gotNil = true
							break
						else
							local spellID = tonumber(recipeLink:match("enchant:(%d+)"))
							knownSpells[spellID] = i
						end

						local itemLink = GetTradeSkillItemLink(i)

						if not itemLink then
							gotNil = true
							break
						else
							local itemID = tonumber(itemLink:match("item:(%d+)"))

							if itemID then
								knownItems[itemID] = i
							end
						end
					end
				end

				if not gotNil then
--					GnomeWorks.data.knownSpells[playerName] = knownSpells
--					GnomeWorks.data.knownItems[playerName] = knownItems
--print(playerName, GnomeWorks.data.knownSpells[playerName], GnomeWorks.data.knownItems[playerName])

					OpenNextLink()
				end
			end
		elseif event == "TRADE_SKILL_CLOSE" then
			scanDepth = scanDepth - 1

			if scanDepth>0 then
				OpenNextLink()
			else
				scanDepth = 50
				GnomeWorks:ScheduleTimer(OpenNextLink,.01)
			end
		end
	end



	function GnomeWorks:DecodeTradeLinks(func)
		frame:SetPoint("CENTER")
		frame:SetWidth(400)
		frame:SetHeight(20)
		frame:Show()

		self.Window:SetBetterBackdrop(frame,{bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBackground.tga",
												edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBorder.tga",
												tile = true, tileSize = 8, edgeSize = 8,
												insets = { left = 3, right = 3, top = 3, bottom = 3 }})

		frameText:SetText("GnomeWorks is scanning trade links...")

		callBack = func
		local playerList = self.data.playerData



--		TradeSkillFrame_Update();

		DeactivateEvents("TRADE_SKILL_SHOW")
		DeactivateEvents("TRADE_SKILL_UPDATE")


		if not self.data.knownSpells then
			self.data.knownSpells = {}
		end


		if not self.data.knownItems then
			self.data.knownItems = {}
		end


		for playerName, playerData in pairs(playerList) do
--print(playerName)
			if playerName ~= "All Recipes" then
				local linkList = playerData.links

				self.data.knownSpells[playerName] = {}
				self.data.knownItems[playerName] = {}

				if linkList and playerData.build == clientBuild then
					for tradeID, tradeLink in pairs(linkList) do
--print(tradeID)
						if not unlinkableTrades[tradeID] and tradeLink then
--print(GetSpellLink(tradeID) or tradeID)
							linkDecodeList[#linkDecodeList+1] = tradeLink
							playerNameList[#playerNameList+1] = playerName
						end
					end
				end
			end
		end

--[[
		local playerName = UnitName("player")
		local playerData = playerList[playerName]
		local linkList = playerData.links

		if linkList then
			for tradeID, tradeLink in pairs(linkList) do
--print(tradeID)
				if not unlinkableTrades[tradeID] then
--print(GetSpellLink(tradeID) or tradeID)
					linkDecodeList[#linkDecodeList+1] = tradeLink
					playerNameList[#playerNameList+1] = playerName
				end
			end
		end
]]

		frame:RegisterEvent("TRADE_SKILL_SHOW")
--		frame:RegisterEvent("TRADE_SKILL_UPDATE")
		frame:RegisterEvent("TRADE_SKILL_CLOSE")

--		frame:RegisterAllEvents()

		frame:SetScript("OnEvent", ScanEventHandler)
		frame:SetScript("OnUpdate", OnUpdate)

		frame:SetScript("OnClick", CloseTradeSkill)

		decodeIndex = 0
		scanDepth = 50
		OpenNextLink()
	end
end
