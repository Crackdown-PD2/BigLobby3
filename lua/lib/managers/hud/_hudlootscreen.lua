-- To avoid overriding `HUDLootScreen:init()` for a loop in the middle of it I'm
-- hooking the first method afterwards to add the extra peers to the required table.
-- It should be safe approach and allow for the rest of the init method to use the
-- extra peers.
HUDLootScreen._init_extra_peers = true

function HUDLootScreen:set_num_visible(peers_num)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	if HUDLootScreen._init_extra_peers then
		for i = 5, num_player_slots do
			self:create_peer(self._peers_panel, i)
		end

		-- This is only run once for `HUDLootScreen:init()`
		HUDLootScreen._init_extra_peers = false
	end

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	self._num_visible = math.max(self._num_visible, peers_num)
	for i = 1, num_player_slots do
		self._peers_panel:child("peer" .. i):set_visible(i <= self._num_visible)
	end
	self._peers_panel:set_h(self._num_visible * 110)
	self._peers_panel:set_center_y(self._hud_panel:h() * 0.5)

	-- TODO: Is this console code useful for reworking the UI layout?
	if managers.menu:is_console() and self._num_visible >= 4 then
		self._peers_panel:move(0, 30)
	end
end


function HUDLootScreen:clear_other_peers(peer_id)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	peer_id = peer_id or self:get_local_peer_id()
	for i = 1, num_player_slots do
		if i ~= peer_id then
			self:remove_peer(i)
		end
	end
end


function HUDLootScreen:check_all_ready()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	local ready = true
	for i = 1, num_player_slots do
		if self._peer_data[i].active and ready then
			ready = self._peer_data[i].ready
		end
	end
	return ready
end


function HUDLootScreen:update(t, dt)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	for peer_id = 1, num_player_slots do
		if self._peer_data[peer_id].wait_t then
			self._peer_data[peer_id].wait_t = math.max(self._peer_data[peer_id].wait_t - dt, 0)
			local panel = self._peers_panel:child("peer" .. tostring(peer_id))
			local card_info_panel = panel:child("card_info")
			local main_text = card_info_panel:child("main_text")
			main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen", {
				time = math.ceil(self._peer_data[peer_id].wait_t)
			}))
			local _, _, _, hh = main_text:text_rect()
			main_text:set_h(hh + 2)
			if self._peer_data[peer_id].wait_t == 0 then
				main_text:set_text(managers.localization:to_upper_text("menu_l_choose_card_chosen_suspense"))
				local joker = self._peer_data[peer_id].joker
				local steam_drop = self._peer_data[peer_id].steam_drop
				local effects = self._peer_data[peer_id].effects
				panel:child("card" .. self._peer_data[peer_id].selected):animate(callback(self, self, "flipcard"), steam_drop and 5.5 or 2.5, callback(self, self, "show_item"), peer_id, effects)
				self._peer_data[peer_id].wait_t = false
			end
		end
	end
end
