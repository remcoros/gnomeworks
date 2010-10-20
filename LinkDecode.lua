






do
	local GnomeWorks = GnomeWorks

	local frame = CreateFrame("Frame")

	local frameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frameText:SetJustifyH("CENTER")
	frameText:SetPoint("LEFT")
	frameText:SetPoint("RIGHT")
	frameText:SetTextColor(1,1,1)
	frameText:SetText("GnomeWorks")


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

--		frame:UnregisterEvent("TRADE_SKILL_SHOW")
		frame:UnregisterEvent("TRADE_SKILL_UPDATE")
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
--		ReactivateEvents("TRADE_SKILL_UPDATE")

--print("done scanning known skills")
		GnomeWorks:ScheduleTimer(callBack,.25)
	end



	local function OpenNextLink()
		decodeIndex = decodeIndex + 1

		if decodeIndex <= #linkDecodeList then
--print(linkDecodeList[decodeIndex])
frameText:SetText("Scanning: "..playerNameList[decodeIndex].." "..linkDecodeList[decodeIndex])
			local tradeString = string.match(linkDecodeList[decodeIndex], "(trade:%d+:%d+:%d+:[0-9a-fA-F]+:[A-Za-z0-9+/]+)")
			ItemRefTooltip:SetHyperlink(tradeString)
		else
			if decodeIndex == #linkDecodeList+1 and GetSpellInfo(GetSpellInfo(2656)) then
--print("scan smelting")
				CastSpellByName(GetSpellInfo(2656)) -- force a scan of smelting because smelting links don't work in pre-cata
			else
				ExitDecodeProcess()
			end
		end
	end


	local function ScanEventHandler(frame, event)
--print("Scan Event Handler",event)
		if event == "TRADE_SKILL_SHOW" then
			frameOpen = true
		elseif event == "TRADE_SKILL_UPDATE" then
			local skillName, skillType = GetTradeSkillInfo(1)
			local gotNil
--print("skillName:",skillName, type(skillName))
			if skillType == "header" then
				local _,playerName = IsTradeSkillLinked()

				frameText:SetText(playerName.." "..linkDecodeList[decodeIndex].." "..GetNumTradeSkills().." recipes")

				local knownSpells = {}
				local knownItems = {}

				for i = 1, GetNumTradeSkills() do
					local _,skillType = GetTradeSkillInfo(i)

					if skillType ~= "header" then
						local recipeLink = GetTradeSkillRecipeLink(i)
--print(recipeLink)
						if not recipeLink then
							gotNil = true
							break
						else
							local spellID = tonumber(recipeLink:match("enchant:(%d+)"))
--print(spellID)
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
					GnomeWorks.data.knownSpells[playerName] = knownSpells
					GnomeWorks.data.knownItems[playerName] = knownItems
--print(playerName, GnomeWorks.data.knownSpells[playerName])
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
		frame:SetHeight(50)
		frame:Show()

		self.Window:SetBetterBackdrop(frame,{bgFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBackground.tga",
												edgeFile = "Interface\\AddOns\\GnomeWorks\\Art\\newFrameBorder.tga",
												tile = true, tileSize = 16, edgeSize = 16,
												insets = { left = 3, right = 3, top = 3, bottom = 3 }})



		frameText:SetText("GnomeWorks is scanning trade links...")

		callBack = func
		local playerList = self.data.playerData

		DeactivateEvents("TRADE_SKILL_SHOW")
--		DeactivateEvents("TRADE_SKILL_UPDATE")


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
			end
		end

--		frame:RegisterEvent("TRADE_SKILL_SHOW")
		frame:RegisterEvent("TRADE_SKILL_UPDATE")
		frame:RegisterEvent("TRADE_SKILL_CLOSE")

		frame:SetScript("OnEvent", ScanEventHandler)

		decodeIndex = 0
		scanDepth = 50
		OpenNextLink()
	end
end
