




LibStagedExecution = {}

local lib = LibStagedExecution

do
	local frame = CreateFrame("Frame")

	local function ProcessSegments(frame, elapsed)
		local list = frame.list

		list.delay = list.delay - elapsed

		if list.delay < 0 then
			local entry = list.segments[1]

			if entry then
				if entry.func() or entry.retry > 30 then
					table.remove(list.segments,1)

					if not list.segments[1] then
						frame:Hide()
					end
				else
					list.delay = entry.delay or 1

					entry.retry = entry.retry + 1
				end
			else
				frame:Hide()
			end
		end
	end



	local function AddSegment(list, func, delay)
		local entry = { func = func, delay = delay, retry = 0 }

		if func then
			list.segments[#list.segments+1] = entry
		else
			print("ERROR: nil func passed to AddSegment")
		end
	end


	local function Execute(list)
		list.frame:Show()
	end

	local function Pause(list)
		list.frame:Hide()
	end

	local function Clear(list)
		list.segments = {}
		list.frame:Hide()
	end


	function lib:NewList()
		local list = {}

		list.frame = CreateFrame("Frame")
		list.frame:Hide()
		list.frame.list = list

		list.frame:SetScript("OnUpdate",ProcessSegments)

		list.delay = 0
		list.segments = {}
		list.AddSegment = AddSegment
		list.Execute = Execute

		return list
	end
end

