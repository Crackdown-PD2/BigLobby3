if Global.load_level == true and Global.game_settings.level_id == "vit" then return end
if Global.load_level == true and Global.game_settings.level_id == "pex" then return end

if BigLobbyGlobals.allow_more_bots_settings then
	CriminalsManager.MAX_NR_TEAM_AI = BigLobbyGlobals:num_bot_slots()
end
-- Not sure how useful this is, just updating it in case.
CriminalsManager.MAX_NR_CRIMINALS = BigLobbyGlobals:num_player_slots()

-- AI colour id should be the last colour in the table, replaces the old value of '5'
function CriminalsManager:character_color_id_by_unit(unit)
	local last_colour_id = #tweak_data.chat_colors

	-- Only code changed was replacing hardcoded 5 with variable last_colour_id
	local search_key = unit:key()
	for id, data in pairs(self._characters) do
		if data.unit and data.taken and search_key == data.unit:key() then
			if data.data.ai then
				return last_colour_id
			end
			return data.peer_id
		end
	end
end
