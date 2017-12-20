-- Instead of overriding methods, I am now hooking them and continuiing the loop
-- to handle >4 peers.
local orig__MenuComponentManager = {
	create_contract_gui = MenuComponentManager.create_contract_gui,
	show_contract_character = MenuComponentManager.show_contract_character
}


-- I believe this creates/updates label state based on what the player is doing?
function MenuComponentManager:create_contract_gui()
	orig__MenuComponentManager.create_contract_gui(self)

	local num_player_slots = BigLobbyGlobals:num_player_slots()
	local peers_state = managers.menu:get_all_peers_state() or {}

	for i = 5, num_player_slots do
		self._contract_gui:update_character_menu_state(i, peers_state[i])
	end
end


-- Shows the peer label over character with alpha of 1 if loaded, or 0.4 if still
-- in a loading/joining state?
function MenuComponentManager:show_contract_character(state)
	orig__MenuComponentManager.create_contract_gui(self, state)

	local num_player_slots = BigLobbyGlobals:num_player_slots()

	if self._contract_gui then
		for i = 5, num_player_slots do
			self._contract_gui:set_character_panel_alpha(i, state and 1 or 0.4)
		end
	end
end
