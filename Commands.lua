






do
	GnomeWorks.commands = {}

	GnomeWorks.commands.show = function(args)
		local player = "All Recipes"
		local tradeID = GnomeWorks:GetTradeIDByName(args) or 3273

		local tradeLink = GnomeWorks.data.playerData[player].links[tradeID]
--print("show",player,tradeID,tradeLink)
		GnomeWorks:OpenTradeLink(tradeLink,player)
	end


end

