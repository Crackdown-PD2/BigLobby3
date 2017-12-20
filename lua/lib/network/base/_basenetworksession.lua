local orig_BaseNetworkSession = {
	check_peer_preferred_character = BaseNetworkSession.check_peer_preferred_character
}


-- Modified to support additional peers.
function BaseNetworkSession:on_network_stopped()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for k = 1, num_player_slots do
		self:on_drop_in_pause_request_received(k, nil, false)
		local peer = self:peer(k)
		if peer then
			peer:unit_delete()
		end
	end
	if self._local_peer then
		self:on_drop_in_pause_request_received(self._local_peer:id(), nil, false)
	end

	-- Resets host lobby size preference when leaving their lobby
	Global.BigLobbyPersist.num_players = nil
	-- Update this variable in case the player left from lobby screen (doesn't reload the mod)
	BigLobbyGlobals.num_players = BigLobbyGlobals.num_players_settings--Global.BigLobbyPersist.num_players
end


-- Modified to support additional peers.
function BaseNetworkSession:_get_peer_outfit_versions_str()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	local outfit_versions_str = ""
	for peer_id = 1, num_player_slots do
		local peer
		if peer_id == self._local_peer:id() then
			peer = self._local_peer
		else
			peer = self._peers[peer_id]
		end
		if peer and peer:waiting_for_player_ready() then
			outfit_versions_str = outfit_versions_str .. tostring(peer_id) .. "-" .. peer:outfit_version() .. "."
		end
	end
	return outfit_versions_str
end


-- Modified to provide all peers with a character, regardless of free characters.
function BaseNetworkSession:check_peer_preferred_character(preferred_character)
	local all_characters = clone(CriminalsManager.character_names())
	local character

	-- Only get a character through the normal method if one is availiable
	if #self._peers_all < #all_characters then
		-- Call Original Code
		character = orig_BaseNetworkSession.check_peer_preferred_character(self, preferred_character)
	end

	-- Get a new character if all have already been taken
	if character == nil then
		-- Allow them to use their preferred character first
		local preferreds = string.split(preferred_character, " ")
		for _, preferred in ipairs(preferreds) do
			if table.contains(all_characters, preferred) then
				return preferred
			end
		end

		-- Fallback to just getting a random character
		character = all_characters[math.random(#all_characters)]
	end

	return character
end
