local orig__NetworkManager = {
	start_network = NetworkManager.start_network,
	on_peer_added = NetworkManager.on_peer_added
}

-- Modified to alter the display of player count in lobbies
function NetworkManager:on_peer_added(peer, peer_id)
	orig__NetworkManager.on_peer_added(self, peer, peer_id)

	if Network:is_server() then
		-- Change the crime.net display to show the % of players relative to the lobby size set by host.
		local ratio = managers.network:session():amount_of_players() / BigLobbyGlobals:num_player_slots()
		local ratio_to_icon = math.clamp( math.ceil(4 * ratio), 1, 4 )

		managers.network.matchmake:set_num_players( ratio_to_icon )
	end
end


-- Adds two new handlers for network messages to handle the `biglobby__` prefix modifications.
function NetworkManager:start_network()
	if not self._started then
		self:register_handler("biglobby__connection", BigLobby__ConnectionNetworkHandler)
		self:register_handler("biglobby__unit", BigLobby__UnitNetworkHandler)
	end

	orig__NetworkManager.start_network(self)
end
