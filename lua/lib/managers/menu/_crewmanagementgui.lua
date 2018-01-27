
-- Removes the hard coded 3 preferred characters  
function CrewManagementGui:select_characters(data, gui)
	local preferred = managers.blackmarket:preferred_henchmen()
	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1
	if data.equipped_by then
		print("unselect")
		managers.blackmarket:set_preferred_henchmen(data.equipped_by, nil)
	else
		local index = math.min(#preferred + 1, num_player_slots)

		print(index, #preferred)
		managers.blackmarket:set_preferred_henchmen(index, data.name)
	end

	gui:reload()
end