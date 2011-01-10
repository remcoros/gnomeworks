


--[[


	GnomeWorks public API


	very much a work in progress!!!


	]]






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



	local function AddButton(plugin, text, func)
		local new = { text = text, func = func }

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

		GnomeWorks:RegisterPlugin(name, shortName)

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





	--[[

		GnomeWorks:GetMainFrame()

		returns the blizzard "Frame" object for the main gnomeworks main window
	]]

	function GnomeWorks:GetMainFrame()
		return self.MainWindow
	end

	function GnomeWorks:GetDetailFrame()
		return self.detailFrame
	end

	function GnomeWorks:GetSkillListFrame()
		return self.skillFrame
	end


	--[[
		GnomeWorks:GetSkillListScrollFrame()

		returns the gnomeworks "ScrollFrame" object for the main window skill list
	]]
	function GnomeWorks:GetSkillListScrollFrame()
		return self.skillFrame.scrollFrame
	end

	function GnomeWorks:GetReagentListScrollFrame()
		return self.reagentFrame.scrollFrame
	end

	function GnomeWorks:GetQueueListScrollFrame()
		return self.queueFrame.scrollFrame
	end

	function GnomeWorks:GetShoppingListScrollFrame()
		return self.shoppingListFrame.scrollFrame
	end



	--[[
		GnomeWorks:GetQueue(player)

		returns the queue object for a particular player (or the current player if player is not passed)

		queue object methods:
			CraftItem(itemID, count)
			CraftRecipe(recipeID, count)
			DeleteItem(itemID)
			DeleteRecipe(itemID)
			CreateProcessButton()
	]]
--	function GnomeWorks:GetQueue(player)
--		return self.data.queue
--	end

end



