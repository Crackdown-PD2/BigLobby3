-- Modified to support rendering UI text for additional peers in lobby screen.
-- Instead of overriding methods, I am now hooking them and continuiing the loop
-- to handle >4 peers.
local orig__ContractBoxGui = {
	create_contract_box = ContractBoxGui.create_contract_box,
	update = ContractBoxGui.update
}


function ContractBoxGui:create_contract_box()
	orig__ContractBoxGui.create_contract_box(self)

	if not managers.network:session() then
		return
	end
	
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for i = 5, num_player_slots do
		local peer = managers.network:session():peer(i)
		if peer then
			local peer_pos = managers.menu_scene:character_screen_position(i)
			local peer_name = peer:name()

			if peer_pos then
				self:create_character_text(i, peer_pos.x, peer_pos.y, peer_name)
			end
		end
	end
end


-- Modified to support rendering UI text for additional peers.
function ContractBoxGui:update(t, dt)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	for i = 5, num_player_slots do
		self:update_character(i)
	end

	orig__ContractBoxGui.update(self, t, dt)
end