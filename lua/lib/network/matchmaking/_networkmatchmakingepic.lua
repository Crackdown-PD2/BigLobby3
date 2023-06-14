-- Used in `NetworkMatchMakingEPIC:create_lobby(settings)` when calling `Steam:create_lobby(f, NetworkMatchMakingEPIC.OPEN_SLOTS, "invisible")`
-- If not adjusted to new player limit will prevent Steam allowing a connection, failing it.
NetworkMatchMakingEPIC.OPEN_SLOTS = BigLobbyGlobals:num_player_slots()

-- Prevent non BigLobby players from finding/joining this game.
if not BigLobbyGlobals:is_small_lobby() then
	-- Version is included in search key now, not sure of any benefit changing game version?
	-- Assign a gameversion, to prevent outdated clients from connecting
	--NetworkMatchMakingEPIC.GAMEVERSION = BigLobbyGlobals:gameversion()

	-- Use the existing search key and concatenate `:biglobby-{{version}}` to it
	-- so other mods can use this filter/isolation method. If search key has not been
	-- modified prior it's value is likely `nil`.
	local bl_key = ":biglobby-" .. BigLobbyGlobals:version()
	local current_key = NetworkMatchMakingEPIC._BUILD_SEARCH_INTEREST_KEY
	NetworkMatchMakingEPIC._BUILD_SEARCH_INTEREST_KEY = current_key and current_key .. bl_key or bl_key
end
