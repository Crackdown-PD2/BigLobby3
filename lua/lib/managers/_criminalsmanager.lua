if Global.load_level == true and Global.game_settings.level_id == "vit" then return end
if Global.load_level == true and Global.game_settings.level_id == "pex" then return end

if BigLobbyGlobals.allow_more_bots_settings then
	CriminalsManager.MAX_NR_TEAM_AI = BigLobbyGlobals:num_bot_slots()
end
-- Not sure how useful this is, just updating it in case.
CriminalsManager.MAX_NR_CRIMINALS = BigLobbyGlobals:num_player_slots()