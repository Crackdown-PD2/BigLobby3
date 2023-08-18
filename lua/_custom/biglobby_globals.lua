if not Global.BigLobbyPersist then
	Global.BigLobbyPersist = {
		num_players = nil -- Set when joining lobbies, nil'd upon leaving
	}
end


if not _G.BigLobbyGlobals then
	_G.BigLobbyGlobals = {}

	-- Settings affected by BigLobby Mod Options
	BigLobbyGlobals.num_players_settings     	= nil
	BigLobbyGlobals.num_bots_settings        	= nil
	BigLobbyGlobals.allow_more_bots_settings 	= nil
	BigLobbyGlobals.auto_stop_all_bots_settings = nil

	-- Load custom lua files without specifying them in mod.txt --
	BigLobbyGlobals.ModPath = ModPath
	BigLobbyGlobals.SavePath = SavePath

	BigLobbyGlobals.ClassPath = "lua/_custom/"

	BigLobbyGlobals.Classes = {
		"menu.lua",
		"husl.lua"
	}

	for _, class in pairs(BigLobbyGlobals.Classes) do
		dofile(BigLobbyGlobals.ModPath .. BigLobbyGlobals.ClassPath .. class)
	end
	-- End custom lua load --


	-- Initializing menu will apply the default/saved settings
	BigLobbyGlobals.Menu = bkin_bl__menu:new()

	-- Set to the size of lobby you join, otherwise use your lobby size preferences for hosting
	BigLobbyGlobals.num_players = Global.BigLobbyPersist.num_players or BigLobbyGlobals.num_players_settings


	function BigLobbyGlobals:num_player_slots()
		return self.num_players
	end


	-- It's probably not going to cause any problems, but I'm capping the
	-- bot_slots to the lobby size just in case
	function BigLobbyGlobals:num_bot_slots()
		return math.min(self.num_bots_settings, self:num_player_slots())
	end


	-- Regular lobby / Seamless switching support
	function BigLobbyGlobals:is_small_lobby()
		--TODO: Changing lobby slot size without reloading mods such as in
		-- Crime.Net won't properly update filters. Don't enable until working better
		return false --self.num_players<=4
	end


	-- Semantic versioning
	function BigLobbyGlobals:version()
		return "3.27.3"
	end


	-- GameVersion for matchmaking, integer is expected
	function BigLobbyGlobals:gameversion()
		return 3273
	end


	-- These tables show the network messages we've modified in the network settings pdmod
	-- We will use them for switching to biglobby prefixed messages when in big lobbies.
	local connection_network_handler_funcs = {
		'kick_peer',
		'remove_peer_confirmation',
		'join_request_reply',
		'peer_handshake',
		'peer_exchange_info',
		'connection_established',
		'mutual_connection',
		'set_member_ready',
		'request_drop_in_pause',
		'drop_in_pause_confirmation',
		'set_peer_synched',
		'dropin_progress',
		'report_dead_connection',
		'preplanning_reserved',
		'draw_preplanning_event',
		'sync_explode_bullet',
		'sync_flame_bullet',
        'sync_crime_spree_level',
		'sync_player_installed_mod'
	}

	local unit_network_handler_funcs = {
		'set_unit',
		'remove_corpse_by_id',
		'mission_ended',
		'sync_trip_mine_setup',
		'from_server_sentry_gun_place_result',
		'place_sentry_gun',
		'picked_up_sentry_gun',
		'sync_equipment_setup',
		'sync_ammo_bag_setup',
		'on_sole_criminal_respawned',
		'sync_grenades',
		'sync_carry_data',
		'sync_throw_projectile',
		'sync_attach_projectile',
		'sync_unlock_asset',
		'sync_equipment_possession',
		'sync_remove_equipment_possession',
		'mark_minion',
		'sync_statistics_result',
		'suspicion',
		'sync_enter_vehicle_host',
		'sync_vehicle_player',
		'sync_exit_vehicle',
		'server_give_vehicle_loot_to_player',
		'sync_give_vehicle_loot_to_player',
		'sync_vehicle_interact_trunk',
		'server_secure_loot',
		'sync_secure_loot'
	}

	-- Builds a single table from our two string based keys for each handler above
	BigLobbyGlobals.network_handler_funcs = {}
	function add_handler_funcs(handler_funcs)
		for i = 1, #handler_funcs do
			BigLobbyGlobals.network_handler_funcs[handler_funcs[i]] = true
		end
	end

	add_handler_funcs(connection_network_handler_funcs)
	add_handler_funcs(unit_network_handler_funcs)


	-- Takes the network keys we defined above and prefixes any matches on the given handler
	function BigLobbyGlobals:rename_handler_funcs(NetworkHandler)
		for key, value in pairs(BigLobbyGlobals.network_handler_funcs) do
			if NetworkHandler[key] then
				NetworkHandler['biglobby__' .. key] = NetworkHandler[key]
			end
		end
	end


	-- Nothing calls this anymore for the time being.
	local log_data = true -- Can use to turn the logging on/off
	function BigLobbyGlobals:logger(content, use_chat)
		if log_data then
			if not content then return end

			if use_chat then
				managers.chat:_receive_message(ChatManager.GAME, "BigLobby", content, tweak_data.system_chat_color)
			end

			log(content)
		end
	end

end
