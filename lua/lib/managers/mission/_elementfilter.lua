-- Store the original _check_players function for use later
local orig__ElementFilter = {}
orig__ElementFilter._check_players = ElementFilter._check_players


-- This function must be modified to allow for proper objective activation with greater than 4 players
function ElementFilter:_check_players()




	-- Original Code --
	local players = Global.running_simulation and managers.editor:mission_player()
	players = players or managers.network:session() and managers.network:session():amount_of_players()
	if not players then
		return false
	end
	-- End Original Code --




	-- Check for >4 players for objective activation fixing
	if self._values.player_4 and players >= 4 then
		return true
	end

	-- Call the original function and return its value if the code above does not return anything
	return orig__ElementFilter._check_players(self)
end
