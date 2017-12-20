-- Levels that trigger events that depend on all players inside become a problem with >4 players
-- This caps the `total_players` variable to 4. The vehicle events are triggered by a listener
-- fired by `VehicleManager:on_player_entered_vehicle(vehicle_unit, player)`
-- Only change to this function is the 2nd line added to do the cap.
function VehicleManager:all_players_in_vehicles()
	local total_players = managers.network:session():amount_of_alive_players()
	total_players = total_players > 4 and 4 or total_players

	local players_in_vehicles = 0
	for _, vehicle in pairs(self._vehicles) do
		players_in_vehicles = players_in_vehicles + vehicle:vehicle_driving():num_players_inside()
	end

	return total_players == players_in_vehicles
end
