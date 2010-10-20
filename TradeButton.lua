

do
	local tradeButtonParent
	local playerGUID


	local pseudoTrades = {
--		[2656] = true,         -- smelting (from mining)
--		[53428] = true,			-- runeforging
		[51005] = true,			-- milling
		[13262] = true,			-- disenchant
		[31252] = true,			-- prospecting

		[100000] = true,
		[100001] = true,
	}



	function OnLeave(frame)
		GameTooltip:Hide()
	end


	local function OnEnter(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")

		GameTooltip:ClearLines()
		GameTooltip:AddLine(frame.tradeName,1,1,1)
--		GameTooltip:AddLine("click to shop",.7,.7,.7)

		GameTooltip:Show()
	end

	local function OnClick(frame, button)
		if frame.tradeLink then
--			local tradeString = string.match(frame.tradeLink, "(trade:%d+:%d+:%d+:[0-9A-F]+:[0-9A-Za-z+/]+)")
--			SetItemRef(tradeString,frame.tradeLink, button)
			if IsShiftKeyDown() then
				if (not ChatEdit_InsertLink(frame.tradeLink)) then
					ChatEdit_GetLastActiveWindow():Show()
					ChatEdit_InsertLink(frame.tradeLink)
				end
			else
				GnomeWorks:OpenTradeLink(frame.tradeLink, GnomeWorks.player)
			end
		else
			if IsShiftKeyDown() then
				local spellName = GetSpellInfo(frame.tradeID)
				local _,link = GetSpellLink(frame.tradeID)

--				link = string.gsub(link,spellName,string.format("%s's Ultimate %s Service",(UnitName("player")),spellName))

				if (not ChatEdit_InsertLink(link) ) then
					ChatEdit_GetLastActiveWindow():Show()
					ChatEdit_InsertLink(link)
				end
			elseif ((GetTradeSkillLine() == "Mining" and "Smelting") or GetTradeSkillLine()) ~= frame.tradeName or IsTradeSkillLinked() then
				CastSpellByName(frame.tradeName)
			end
		end

		if frame.tradeID == GnomeWorks.tradeID then
			frame:SetChecked(1)
		else
			frame:SetChecked(0)
		end
	end


	function GnomeWorks:CreateTradeButtons(tradeSkillList, parentFrame)
		local buttonSize = 64
		local position = 0 -- pixel
		local spacing = 5
		local scale = parentFrame:GetHeight()/buttonSize

		local frame = CreateFrame("Frame", nil, parentFrame)

		frame:SetPoint("TOP")
		frame:SetWidth((buttonSize * #tradeSkillList + spacing  * (#tradeSkillList-1)))
		frame:SetHeight(buttonSize)

		frame:Show()


		frame:SetScale(scale)

		tradeButtonParent = frame

		frame.buttons = {}

		for i=1,#tradeSkillList,1 do
			local tradeID = tradeSkillList[i]
			local spellName = self:GetTradeName(tradeID)
			local tradeLink

--			local spellName, _, spellIcon = GetSpellInfo(tradeID)
			local spellIcon = GnomeWorks:GetTradeIcon(tradeID)

			local button = CreateFrame("CheckButton", "GWTSButton"..i, frame, "ActionButtonTemplate")

			button:SetAlpha(0.8)

			button:SetPoint("TOPLEFT", position, 0)
			button:SetWidth(buttonSize)
			button:SetHeight(buttonSize)

			_G["GWTSButton"..i.."NormalTexture"]:SetAllPoints(button)			-- for some reason they added an offset in the template in 4.0.1

			button:SetNormalTexture(spellIcon)
			button:SetPushedTexture(spellIcon)

			button.tradeName = spellName
			button.tradeID = tradeID

			button:SetScript("OnEnter", OnEnter)
			button:SetScript("OnLeave", OnLeave)
			button:SetScript("OnClick", OnClick)

			position = position + (buttonSize+spacing)
			button:Show()

			frame.buttons[i] = button

		end

		return frame
	end


	function GnomeWorks:UpdateTradeButtons(player, tradeID)
		if tradeButtonParent then
			local frame = tradeButtonParent
			local position = 0
			local spacing = 5
			local buttonSize = 64

			local links = self:GetTradeLinkList(player)

			for i,button in ipairs(frame.buttons) do
				if links[button.tradeID] then
					button:Show()

					button.tradeLink = links[button.tradeID]

					if player == (UnitName("player")) then
--						if not GnomeWorks:IsPseudoTrade(button.tradeID) then
						if not pseudoTrades[button.tradeID] then
							button.tradeLink = nil
						end
					end
--print(button.tradeID, links[button.tradeID], button.tradeLink)


					button:SetPoint("TOPLEFT", position, 0)
					position = position + (buttonSize+spacing)
				else
					button:Hide()
					button.spell = nil
				end

				if button.tradeID == tradeID then
					button:SetChecked(1)
				else
					button:SetChecked(0)
				end
			end


			local totalWidth = position-spacing


			frame:SetWidth(totalWidth)

			local parentFrame = frame:GetParent()
			local scale = parentFrame:GetHeight()/buttonSize

			parentFrame:SetWidth(math.max(totalWidth*scale,200))
		end
	end
end
