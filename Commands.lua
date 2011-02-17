






do
	GnomeWorks.commands = {}

	GnomeWorks.commands.show = {
		func = function(args)
			local player = "All Recipes"
			local tradeID = GnomeWorks:GetTradeIDByName(args) or 3273

			local tradeLink = GnomeWorks.data.playerData[player].links[tradeID]
	--print("show",player,tradeID,tradeLink)
			GnomeWorks:OpenTradeLink(tradeLink,player)
		end,
		usage = "    /gw show [tradeName]\n    open tradeskill frame"
	}


	GnomeWorks.commands.debug = {
		func = function(...)
			local arg = ...

			if not arg then
				GnomeWorks:print("show time report")
				GnomeWorks:MessageDispatchTimeReportToggle()
			else
				if arg == "fixframes" then
					GnomeWorks:print("fixing frames")
					GnomeWorks:FixFrames(GnomeWorks.MainWindow)
				else
					GnomeWorks:warning("bad argument(s) for debug command:",arg)
				end
			end
		end,
		usage = "    /gw debug [debugCommand]\n    display message debugging frame or issue debug command"
	}


	GnomeWorks.commands.help = {
		func = function(...)
			print("/gw commands:")

			for name,command in pairs(GnomeWorks.commands) do
				print(name,"-")
				print(command.usage)
			end
		end,
		usage = "    /gw help\n    display list of slash commands"
	}
end

