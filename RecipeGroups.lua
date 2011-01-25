
local function DebugSpam(...)
-- print(...)
end


local groupLabelAdded = {}
local groupLabels = {}



local OVERALL_PARENT_GROUP_NAME = "*ALL*"

local skillLevel = {
	["optimal"]	        = 4,
	["medium"]          = 3,
	["easy"]            = 2,
	["trivial"]	        = 1,
}


local function RemoveLabel(player,tradeID,label)
	local d

	for k,v in pairs(groupLabels[player..":"..tradeID]) do
		if v.name == label then
			d = k
			break
		end
	end

	if d then
		groupLabelAdded[player..":"..tradeID..":"..label] = nil

		return table.remove(groupLabels[player..":"..tradeID],d)
	end
end


function GnomeWorks:RecipeGroupRename(oldName, newName)
	local oldKey =  self.player..":"..self.tradeID..":"..oldName
	local newKey = self.player..":"..self.tradeID..":"..newName

	if self.data.groupList[oldKey] then
		self.data.groupList[newKey] = self.data.groupList[oldKey]
		self.data.groupList[oldKey] = nil

		local list = self.data.groupList[newKey]

		self.data.recipeGroupData[newKey] = self.data.recipeGroupData[oldKey]
		self.data.recipeGroupData[oldKey] = nil

		for groupName, groupData in pairs(list) do
			groupData.key = newKey
			groupData.label = newName
		end

		for k,v in pairs(groupLabels[self.player..":"..self.tradeID]) do
			if v.name == oldName then
				v.name = newName
				break
			end
		end

		groupLabelAdded[oldKey] = nil
		groupLabelAdded[newKey] = true
	end
end


function GnomeWorks:RecipeGroupValidate(player, tradeID, label, name)
	if player and tradeID and label then
		local key = player..":"..tradeID..":"..label
		local groupList = self.data.groupList

		if groupList[key] then
			if name == OVERALL_PARENT_GROUP_NAME then
				name = nil
			end

			return player, tradeID, label, name
		end

		local labelKey = player..":"..tradeID

		if groupLabels[labelKey] then
			local label = groupLabels[labelKey][1]

			key = labelKey..":"..label.name

			local groupName = label.subGroup.name

			if groupName == OVERALL_PARENT_GROUP_NAME then
				groupName = nil
			end

			return player, tradeID, label.name, groupName
		end
	end
end


function GnomeWorks:RecipeGroupFind(player, tradeID, label, name)
	if player and tradeID and label then
		local key = player..":"..tradeID..":"..label
		local groupList = self.data.groupList

		if groupList and groupList[key] and groupList[key][name or OVERALL_PARENT_GROUP_NAME] then
			return groupList[key][name or OVERALL_PARENT_GROUP_NAME]
		end
	end
end


function GnomeWorks:RecipeGroupFindRecipe(group, recipeID)
	if group then
		local entries = group.entries

		if entries then
			for i=1,#entries do
				if entries[i].recipeID then
					return entries[i]
				end
			end
		end
	end
end


-- creates a new recipe group
-- player = for whom the group is being created
-- tradeID = tradeID of the group
-- label = meta-group of groups.  for example, "blizzard" is defined for the standard blizzard groups.  this allows multiple group settings
-- name = new group name (optional -- not specified means the overall parent group)
--
-- returns the newly created group record
local serial = 0
function GnomeWorks:RecipeGroupNew(player, tradeID, label, name)
	local existingGroup = self:RecipeGroupFind(player, tradeID, label, name)

	if existingGroup then
--DebugSpam("group "..existingGroup.key.."/"..existingGroup.name.." exists")
		return existingGroup
	else
--DebugSpam("new group "..(name or OVERALL_PARENT_GROUP_NAME))

		local key = player..":"..tradeID..":"..label

		local newGroup = { expanded = true, key = key, label = label, name = name or OVERALL_PARENT_GROUP_NAME, entries = {}, index = serial, locked = false }

--[[
		newGroup.expanded = true
		newGroup.key = key
		newGroup.name = name or OVERALL_PARENT_GROUP_NAME
		newGroup.entries = {}
		newGroup.skillIndex = serial
		newGroup.locked = nil
]]

		serial = serial + 1

		if not self.data.groupList then
			self.data.groupList = {}
		end

		if not self.data.groupList[key] then
			self.data.groupList[key] = {}
		end

		self.data.groupList[key][newGroup.name] = newGroup

		if not groupLabelAdded[key] and newGroup.name == OVERALL_PARENT_GROUP_NAME then
			if not groupLabels[player..":"..tradeID] then
				groupLabels[player..":"..tradeID] = {}
			end

			table.insert(groupLabels[player..":"..tradeID], { name = label, subGroup = newGroup } )

			groupLabelAdded[key] = true
		end



		return newGroup
	end
end


function GnomeWorks:RecipeGroupClearEntries(group)
	if group then
		for i=1,#group.entries do
			if group.entries[i].subGroup then
				self:RecipeGroupClearEntries(group.entries[i].subGroup)
			end
		end

		group.entries = {}
	end
end


function GnomeWorks:RecipeGroupCopy(s, d, noDB)
	if s and d then
		local player, tradeID, label = string.split(":", d.key)

		d.index = s.index
		d.expanded = s.expanded
		d.entries = {}

		for i=1,#s.entries do
			if s.entries[i].subGroup then
				local newGroup = self:RecipeGroupNew(player, tradeID, label, s.entries[i].name)

				newGroup.manualEntry = true

				self:RecipeGroupCopy(s.entries[i].subGroup, newGroup, noDB)

				self:RecipeGroupAddSubGroup(d, newGroup, s.entries[i].index, noDB)
			else
				self:RecipeGroupAddRecipe(d, s.entries[i].recipeID, s.entries[i].index, noDB)
			end
		end
	end
end




function GnomeWorks:RecipeGroupAddRecipe(group, recipeID, index, noDB)
	recipeID = tonumber(recipeID)

	if group and recipeID then
		local currentEntry

		for i=1,#group.entries do
			if group.entries[i].recipeID == recipeID then
				currentEntry = group.entries[i]
				break
			end
		end

		if not currentEntry then
			local newEntry = { recipeID = recipeID, name = self:GetRecipeName(recipeID), index = index, parent = group }

--[[
			newEntry.recipeID = recipeID
			newEntry.name = self:GetRecipeName(recipeID)
			newEntry.skillIndex = skillIndex
			newEntry.parent = group
]]

			table.insert(group.entries, newEntry)

			currentEntry = newEntry
		else
			currentEntry.subGroup = subGroup
			currentEntry.index = index
			currentEntry.name = self:GetRecipeName(recipeID)
			currentEntry.parent = group
		end

		if not noDB then
			self:RecipeGroupConstructDBString(group)
		end

		return currentEntry
	end
end


function GnomeWorks:RecipeGroupAddSubGroup(group, subGroup, index, noDB)
	if group and subGroup then
		local currentEntry

		for i=1,#group.entries do
			if group.entries[i].subGroup == subGroup then
				currentEntry = group.entries[i]
				break
			end
		end

		if not currentEntry then
			local newEntry = { subGroup = subGroup, index = index, name = subGroup.name, parent = group }

			subGroup.parent = group
			subGroup.index = index
--[[
			newEntry.subGroup = subGroup
			newEntry.skillIndex = skillIndex
			newEntry.name = subGroup.name
			newEntry.parent = group
]]
			table.insert(group.entries, newEntry)
		else
			subGroup.parent = group
			subGroup.index = index

			currentEntry.subGroup = subGroup
			currentEntry.index = index
			currentEntry.name = subGroup.name
			currentEntry.parent = group
		end

		if not noDB then
			self:RecipeGroupConstructDBString(group)
		end
	end
end


function GnomeWorks:RecipeGroupPasteEntry(entry, group)
	if entry and group and entry.parent ~= group then
		local player = self.player
		local tradeID = self.tradeID
		local label = self.groupLabel
DEFAULT_CHAT_FRAME:AddMessage("paste "..entry.name.." into "..group.name)

--		local parentGroup = self:RecipeGroupFind(player, tradeID, label, self.currentGroup)
		local parentGroup = group

		if entry.subGroup then
			 if entry.subGroup == group then
			 	return
			end

			local newName, newIndex = self:RecipeGroupNewName(group.key, entry.name)

			local newGroup = self:RecipeGroupNew(player, tradeID, label, newName)

			self:RecipeGroupAddSubGroup(parentGroup, newGroup, newIndex)

			if entry.subGroup.entries then
DEFAULT_CHAT_FRAME:AddMessage((entry.subGroup.name or "nil") .. " " .. #entry.subGroup.entries)
				for i=1,#entry.subGroup.entries do
DEFAULT_CHAT_FRAME:AddMessage((entry.subGroup.entries[i].name or "nil") .. " " .. newGroup.name)

					self:RecipeGroupPasteEntry(entry.subGroup.entries[i], newGroup)
				end
			end
		else
			local newIndex = self.data.skillIndexLookup[player][entry.recipeID]

			if not newIndex then
				newIndex = #self.db.server.skillDB[player][tradeID]+1
				self.db.server.skillDB[player][tradeID][newIndex] = "x"..entry.recipeID
			end

			self:RecipeGroupAddRecipe(parentGroup, entry.recipeID, newIndex)
		end
	end
end


function GnomeWorks:RecipeGroupMoveEntry(entry, group)
	if entry and group and entry.parent ~= group then

		if entry.subGroup then
			 if entry.subGroup == group then
			 	return
			end
		end

		local entryGroup = entry.parent
		local loc

		for i=1,#entryGroup.entries do
			if entryGroup.entries[i] == entry then
				loc = i
				break
			end
		end


		table.remove(entryGroup.entries, loc)

		table.insert(group.entries, entry)

		entry.parent = group

		self:RecipeGroupConstructDBString(group)
		self:RecipeGroupConstructDBString(entryGroup)
	end
end



function GnomeWorks:RecipeGroupDeleteGroup(group)
	if group then
		for i=1,#group.entries do
			if group.entries[i].subGroup then
				self.RecipeGroupDeleteGroup(group.entries[i].subGroup)
			end
		end

		group.entries = nil

		self.data.recipeGroupData[group.key][group.name] = nil
	end
end


function GnomeWorks:RecipeGroupDeleteEntry(entry)
	if entry then

		local entryGroup = entry.parent
		local loc

		if not entryGroup.entries then return end

		for i=1,#entryGroup.entries do
			if entryGroup.entries[i] == entry then
				loc = i
				break
			end
		end

		table.remove(entryGroup.entries, loc)

		if entry.subGroup then
			self:RecipeGroupDeleteGroup(entry.subGroup)
		end

		self:RecipeGroupConstructDBString(entryGroup)
	end
end


function GnomeWorks:RecipeGroupNewName(key, name)
	local index = 1

	if key and name then

		local groupList = self.data.groupList[key]

		for v in pairs(groupList) do
			index = index + 1
		end

		if groupList[name] then
			local tempName = name.." "
			local suffix = 2

			while groupList[tempName..suffix] do
				suffix = suffix + 1
			end

			name = tempName..suffix
		end
	end

	return name, index
end


function GnomeWorks:RecipeGroupRenameEntry(entry, name)
	if entry and name then
		local key = entry.parent.key


		if entry.subGroup then
			local oldName = entry.subGroup.name
			local groupList = self.data.groupList[key]

			if oldName ~= name then

				name = self:RecipeGroupNewName(key, name)

				entry.subGroup.name = name

				groupList[name] = groupList[oldName]
				groupList[oldName] = nil

				entry.name = name
			end
		end

		self:RecipeGroupConstructDBString(entry.parent)

		return name
	end
end


function GnomeWorks:RecipeGroupSort(group, sortMethod, reverse)
	if group then
		for v, entry in pairs(group.entries) do
			if entry.subGroup and entry.subGroup ~= group then
				self:RecipeGroupSort(entry.subGroup, sortMethod, reverse)
			end
		end

		if group.entries and #group.entries>1 then
			if reverse then
				table.sort(group.entries, function(a,b)
					return sortMethod(self.tradeID, b, a)
				end)
			else
				table.sort(group.entries, function(a,b)
					return sortMethod(self.tradeID, a, b)
				end)
			end
		end
	end
end



function GnomeWorks:RecipeGroupFlatten(group, depth, list, index)
	local num = 0

	if group and list then
		for v, entry in pairs(group.entries) do
			if entry.subGroup then
				local newSkill = entry
				local inSub = 0

				newSkill.depth = depth

				if (index>0) then
					newSkill.parentIndex = index
				else
					newSkill.parentIndex = nil
				end


				num = num + 1
				list[num + index] = newSkill

				if entry.subGroup.expanded then
					inSub = self:RecipeGroupFlatten(entry.subGroup, depth+1, list, num+index)
				end

				num = num + inSub

--[[
				if inSub == 0 and entry.subGroup.expanded then			-- if no items are added in a sub-group, then don't add the sub-group header
					num = num - 1
				else
					num = num + inSub
				end
]]
			else
				entry.depth = depth

--DEFAULT_CHAT_FRAME:AddMessage("id: "..newSkill.spellID)

				if (index>0) then
					entry.parentIndex = index
				else
					entry.parentIndex = nil
				end

				num = num + 1
				list[num + index] = entry

--[[
				local skillData = self:GetSkill(self.currentPlayer, self.currentTrade, entry.skillIndex)
				local recipe = self:GetRecipe(entry.recipeID)

				if skillData then
					local 	filterLevel = ((skillLevel[entry.difficulty] or skillLevel[skillData.difficulty] or 4) < (self:GetTradeSkillOption("filterLevel")))
					local filterCraftable = false

					if self:GetTradeSkillOption("hideuncraftable") then
						if not (skillData.numCraftable > 0 and self:GetTradeSkillOption("filterInventory-bag")) and
						   not (skillData.numCraftableVendor > 0 and self:GetTradeSkillOption("filterInventory-vendor")) and
						   not (skillData.numCraftableBank > 0 and self:GetTradeSkillOption("filterInventory-bank")) and
						   not (skillData.numCraftableAlts > 0 and self:GetTradeSkillOption("filterInventory-alts")) then
							filterCraftable = true
						end
					end


					if self.recipeFilters then
						for _,f in pairs(self.recipeFilters) do
							if f.filterMethod(f.namespace, entry.skillIndex) then
								filterCraftable = true
							end
						end
					end


					local newSkill = entry

					newSkill.depth = depth
					newSkill.skillData = skillData
					newSkill.spellID = recipe.spellID
--DEFAULT_CHAT_FRAME:AddMessage("id: "..newSkill.spellID)

					if (index>0) then
						newSkill.parentIndex = index
					else
						newSkill.parentIndex = nil
					end

					if not (filterLevel or filterCraftable) then
						num = num + 1
						list[num + index] = newSkill
					end
				end
	]]
			end
		end
	end

	return num
end




function GnomeWorks:RecipeGroupDump(group)
	if group then
		local groupString = group.key.."/"..group.name.."="..group.index

		for v,entry in pairs(group.entries) do
			if not entry.subGroup then
				groupString = groupString..":"..entry.recipeID
			else
				groupString = groupString..":"..entry.subGroup.name
				self:RecipeGroupDump(entry.subGroup)
			end
		end

		DebugSpam(groupString)
	else
		DebugSpam("no match")
	end
end


-- make a db string for saving groups
function GnomeWorks:RecipeGroupConstructDBString(group)
--print("constructing group db strings "..group.name)

	if group and not group.autoGroup then
		local key = group.key
		local player, tradeID, label = string.split(":",key)

		tradeID = tonumber(tradeID)

		local dbTable = {}

		if not self.data.groupList[key].autoGroup then
--			local groupString = group.index

			dbTable[#dbTable+1] = group.index

			for v,entry in pairs(group.entries) do
				if not entry.subGroup then
					dbTable[#dbTable+1] = entry.index.."="..entry.recipeID
				else
					dbTable[#dbTable+1] = "g"..entry.index	--entry.subGroup.name
					self:RecipeGroupConstructDBString(entry.subGroup)
				end
			end

			local groupString = table.concat(dbTable,":")

			if not self.data.recipeGroupData[key] then
				self.data.recipeGroupData[key] = {}
			end
--print(groupString)
			self.data.recipeGroupData[key][group.name] = groupString
		end
	end
end




function GnomeWorks:RecipeGroupPruneList()
	if false and self.data.groupList then
		for key, group in pairs(self.data.groupList) do
			if type(group)=="table" and name ~= OVERALL_PARENT_GROUP_NAME and group.parent == nil then
				self.data.groupList[key] = nil
				if self.data.recipeGroupData and self.data.recipeGroupData[key] then
					self.data.recipeGroupData[key][name] = nil
				end
			end
		end
	end
end


function GnomeWorks:InitGroupList(key, autoGroup)
	if not self.data.groupList then
		self.data.groupList = {}
	end

	if not self.data.groupList[key] then
		self.data.groupList[key] = {}
	end

	self.data.groupList[key].autoGroup = autoGroup
end



function GnomeWorks:RecipeGroupDeconstructDBStrings()
-- pass 1: create all groups
--print("deconstruct group strings")
	local groupNames = {}
	local serial = 1

	for key, groupList in pairs(self.data.recipeGroupData) do
		local player, tradeID, label = string.split(":", key)
		tradeID = tonumber(tradeID)
--print(key,groupList)
--print(player, self.player, tradeID, self.tradeID)
--assert(self.player)

		if player == self.player and tradeID == self.tradeID then
			self:InitGroupList(key)

			for name,list in pairs(groupList) do

				local group = self:RecipeGroupNew(player, tradeID, label, name)

				group.manualEntry = true

				local groupContents = string.match(list,"(%d+)")
				local groupIndex = (groupContents) or serial

				serial = serial + 1
				group.index = tonumber(groupIndex)
--print("adding", player, tradeID, label, name, groupIndex)
				groupNames[label..groupIndex] = name
			end
		end
	end


	for key, groupList in pairs(self.data.recipeGroupData) do
		local player, tradeID, label = string.split(":", key)

		tradeID = tonumber(tradeID)

		if player == self.player and tradeID == self.tradeID  then

			for name,list in pairs(groupList) do
				local group = self:RecipeGroupFind(player, tradeID, label, name)

				local groupIndex = group.index

				if not group.initialized then
					group.initialized = true

					local groupContents = { string.split(":",list) }


					for j=2,#groupContents do
--print(groupContents[j])
						local skillIndex, recipeID = string.match(groupContents[j],"(%d+)=(%d+)")
						local groupID = string.match(groupContents[j],"g(%d+)")

						if groupID then
							local id = (groupID)
--print("linking", player, tradeID, label, id, groupNames[id])

							local subGroup = self:RecipeGroupFind(player, tradeID, label, groupNames[label..id])

							if subGroup then
								self:RecipeGroupAddSubGroup(group, subGroup, subGroup.index, true)
							else
								GnomeWorks:error("can't properly construct recipe groups")
							end
						elseif recipeID and skillIndex then
							recipeID = tonumber(recipeID)
							skillIndex = tonumber(skillIndex)

							self:RecipeGroupAddRecipe(group, recipeID, skillIndex, true)
						end
					end
				end
			end

			self:RecipeGroupPruneList()
		end
	end

	DebugSpam("done making groups")
end


function GnomeWorks:RecipeGroupGenerateAutoGroups()
	local player = self.player

	local dataModule = self.dataGatheringModules[player]

	if dataModule then
		dataModule.RecipeGroupGenerateAutoGroups(dataModule)
	end
end



do
	local groupNameEdit = CreateFrame("EditBox", nil, UIParent)

	groupNameEdit:SetWidth(300)
	groupNameEdit:SetHeight(16)


--[[
	<EditBox name="GroupButtonNameEdit" historyLines="0" autoFocus="true" hidden="true">
		<Size>
  			<AbsDimension x="293" y="16" />
  		</Size>
		<FontString inherits="GameFontNormalSmall" justifyH="RIGHT">
			<Anchors>
				<Anchor point="LEFT">
					<Offset>
						<AbsDimension x="20" y="0" />
					</Offset>
				</Anchor>
			</Anchors>
			<Color r="1" g="1" b="1" a="1"/>
		</FontString>
		<Scripts>
			<OnClick>
			</OnClick>
			<OnTabPressed>
				Skillet:GroupNameEditSave()
			</OnTabPressed>
			<OnEnterPressed>
				Skillet:GroupNameEditSave()
			</OnEnterPressed>
			<OnEscapePressed>
				this:ClearFocus()
			</OnEscapePressed>
			<OnTextChanged>
			</OnTextChanged>
			<OnEditFocusLost>
				this:Hide()
				SkilletRecipeGroupDropdownButton:Show()
				Skillet:UpdateTradeSkillWindow()
			</OnEditFocusLost>
			<OnEditFocusGained>
				this:HighlightText()
			</OnEditFocusGained>
		</Scripts>
	</EditBox>
]]


	-- Called when the user selects an item in the group drop down
	function RecipeGroupSelect(menuButton, group)
--	DebugSpam("select grouping",label,dropDown)
--		self:SetTradeSkillOption("grouping", label)
		CloseDropDownMenus()

		if not group then
			group = groupLabels[GnomeWorks.player..":"..GnomeWorks.tradeID][1].subGroup
		end


		GnomeWorks.groupLabel = group.label
		GnomeWorks.group = group.name


		if IsTradeSkillLinked() or IsTradeSkillGuild() then
			GnomeWorksDB.config.currentGroup.alt[GnomeWorks.tradeID] = group.label.."/"..group.name
		else
			GnomeWorksDB.config.currentGroup.self[GnomeWorks.tradeID] = group.label.."/"..group.name
		end

--		GnomeWorks:RecipeGroupDropdown_OnShow(dropDown)

--		self:RecipeGroupGenerateAutoGroups()
--		self:SortAndFilterRecipes()
--		self:UpdateTradeSkillWindow()

		GnomeWorks:SendMessageDispatch("SkillListChanged")
	end


	function GnomeWorks:RecipeGroupIsLocked()
--		if self.groupLabel == "Flat" or self.groupLabel == "By Category" then return true end
		local group = self:RecipeGroupFind(self.player, self.tradeID, self.groupLabel)

		if group and group.locked then
			return true
		end


		return false
--		if self.config.lockedGroup[self.groupLabel] then
--			return true
--		end
	end


	local function DropDown_Init(menuFrame,level)
		local entries

		if level == 1 then
			if GnomeWorks.tradeID and GnomeWorks.player then
				entries = groupLabels[GnomeWorks.player..":"..GnomeWorks.tradeID]
			end
		elseif UIDROPDOWNMENU_MENU_VALUE and type(UIDROPDOWNMENU_MENU_VALUE)=="table" then
			entries = UIDROPDOWNMENU_MENU_VALUE.entries
		end

		if not entries then
			return 0
		end

		local numGroupsAdded = 0

		local entry = {}


		for i=1,#entries do
			if entries[i].subGroup then
				local group = entries[i].subGroup

				entry.hasArrow = false

				for k,v in ipairs(group.entries) do
					if v.subGroup then
						entry.hasArrow = true
						break
					end
				end

				entry.text = entries[i].name
				entry.value = group

				entry.func = RecipeGroupSelect
				entry.arg1 = group

				entry.checked = false

				entry.colorCode = nil


				if level == 1 and GnomeWorks.groupLabel == group.label then
					if not GnomeWorks.group then
						entry.checked = true
					else
						entry.colorCode = "|cffc0ffc0"
					end
				end

				if GnomeWorks.groupLabel == group.label and GnomeWorks.group == group.name then
					entry.checked = true
				end

				UIDropDownMenu_AddButton(entry, level)

				numGroupsAdded = numGroupsAdded + 1
			end
		end

		return numGroupsAdded
	end



	-- Called when the grouping drop down is displayed
	function GnomeWorks:RecipeGroupDropdown_OnShow(dropDown)
		UIDropDownMenu_Initialize(dropDown, DropDown_Init)
		dropDown.displayMode = "MENU"
		self:RecipeGroupDeconstructDBStrings()


		local groupLabel = self.groupLabel or "By Category"

		if self.group and self.group ~= OVERALL_PARENT_GROUP_NAME then
			groupLabel = groupLabel.."/"..self.group
		end

--		UIDropDownMenu_SetSelectedID(dropDown, groupLabel, true)
		UIDropDownMenu_SetText(dropDown, "Group |cffc0ffc0"..groupLabel)
	end


	--[[
	function GnomeWorks:ToggleTradeSkillOptionDropDown(option)
		self:ToggleTradeSkillOption(option)
		self:RecipeGroupDropdown_OnShow()

		self:SortAndFilterRecipes()
		self:UpdateTradeSkillWindow()
	end
	]]



	function GnomeWorks:RecipeGroupOpNew()
		local label = "Custom"
		local serial = 1
		local player = self.player
		local tradeID = self.tradeID

		local groupList = self.data.groupList

		while groupList[player..":"..tradeID..":"..label] do
			serial = serial + 1
			label = "Custom "..serial
		end

		local newMain = self:RecipeGroupNew(player, tradeID, label)
		local oldMain = self:RecipeGroupFind(player, tradeID, "Flat")

		self:RecipeGroupCopy(oldMain, newMain, false)

		self:RecipeGroupConstructDBString(newMain)

		RecipeGroupSelect(nil,newMain)
	end


	function GnomeWorks:RecipeGroupOpCopy()
		local label = "Custom"
		local serial = 1
		local player = self.player
		local tradeID = self.tradeID

		local groupList = self.data.groupList

		while groupList[player..":"..tradeID..":"..label] do
			serial = serial + 1
			label = "Custom "..serial
		end

		local newMain = self:RecipeGroupNew(player, tradeID, label)
		local oldMain = self:RecipeGroupFind(player, tradeID, self.groupLabel)

		self:RecipeGroupCopy(oldMain, newMain, false)

		self:RecipeGroupConstructDBString(newMain)

		RecipeGroupSelect(nil,newMain)
	end



	local function GroupNameEditSave(editBox)
		local newName = editBox:GetText()

		GnomeWorks:RecipeGroupRename(GnomeWorks.groupLabel, newName)

		editBox:Hide()
		GnomeWorksGroupingText:Show()
		GnomeWorksGroupingText:SetText("Group |cffc0ffc0"..newName)

		GnomeWorks.groupLabel = newName
	end


	function GnomeWorks:RecipeGroupOpRename()
		if not self:RecipeGroupIsLocked() then
			groupNameEdit:SetText(self.groupLabel)
			groupNameEdit:SetParent(GnomeWorksGrouping)
			groupNameEdit:SetPoint("LEFT", GnomeWorksGroupingLeft, "RIGHT",0,0)
			groupNameEdit:SetPoint("RIGHT", GnomeWorksGroupingRight, "LEFT",0,0)

			groupNameEdit:Show()
			GnomeWorksGroupingText:Hide()
			groupNameEdit:SetFocus()

		end
	end


	function GnomeWorks:RecipeGroupOpLock()
		local label = self.groupLabel

		if label ~= "Blizzard" and label ~= "Flat" then
--			self:ToggleTradeSkillOption(label.."-locked")
		end
	end


	function GnomeWorks:RecipeGroupOpDelete()
		if not self:RecipeGroupIsLocked() then
			local player = self.player
			local tradeID = self.tradeID
			local label = self.groupLabel

			self.data.groupList[player..":"..tradeID..":"..label] = nil
			self.data.recipeGroupData[player..":"..tradeID..":"..label] = nil


			RemoveLabel(player,tradeID,label)




			collectgarbage("collect")

			RecipeGroupSelect()
		end
	end



	local groupOpMenu = {
		{
			text = "New",
			func = function() GnomeWorks:RecipeGroupOpNew() end,
			notCheckable = true,

		},
		{
			text = "Copy",
			func = function() GnomeWorks:RecipeGroupOpCopy() end,
			notCheckable = true,
		},
		{
			text = "Rename",
			func = function() GnomeWorks:RecipeGroupOpRename() end,
			notCheckable = true,
		},
--[[
		{
			text = "Lock/Unlock",
			func = function() GnomeWorks:RecipeGroupOpLock() end,
			notCheckable = true,
		},
]]
		{
			text = "Delete",
			func = function() GnomeWorks:RecipeGroupOpDelete() end,
			notCheckable = true,
		},
	}


	-- Called when the grouping operators drop down is displayed
	function GnomeWorks:RecipeGroupOperations_OnClick()
		if not RecipeGroupOpsMenu then
			CreateFrame("Frame", "GWRecipeGroupOpsMenu", UIParent, "UIDropDownMenuTemplate")
		end

		local x, y = GetCursorPosition()
		local uiScale = UIParent:GetEffectiveScale()

		EasyMenu(groupOpMenu, GWRecipeGroupOpsMenu, UIParent, x/uiScale,y/uiScale, "MENU", 5)
	--	UIDropDownMenu_Initialize(RecipeGroupOpsMenu, GnomeWorksRecipeGroupOpsMenu_Init, "MENU")
	--	ToggleDropDownMenu(1, nil, RecipeGroupOpsMenu, this, this:GetWidth(), 0)
	end



	groupNameEdit:SetScript("OnTabPressed", GroupNameEditSave)
	groupNameEdit:SetScript("OnEnterPressed", GroupNameEditSave)
	groupNameEdit:SetScript("OnEscapePressed", function(f) f:ClearFocus() end)
	groupNameEdit:SetScript("OnEditFocusLost", function(f) f:Hide() GnomeWorksGroupingText:Show() end)
	groupNameEdit:SetScript("OnEditFocusGained", function(f) f:HighlightText() end)

	groupNameEdit:SetAutoFocus(false)

	groupNameEdit:SetFontObject("GameFontHighlightSmall")

end





