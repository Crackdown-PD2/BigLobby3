-- Modified to support displaying additional peers loadouts.
-- TODO: This becomes undesirable the larger the player count and requires a reworked UI.
function TeamLoadoutItem:init(panel, text, i)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing two hardcoded values of 4 with the variable num_player_slots
	TeamLoadoutItem.super.init(self, panel, text, i)
	self._player_slots = {}
	local quarter_width = self._panel:w() / num_player_slots
	local slot_panel
	for i = 1, num_player_slots do
		local old_right = slot_panel and slot_panel:right() or 0
		slot_panel = self._panel:panel({
			x = old_right,
			y = 0,
			w = quarter_width,
			h = self._panel:h(),
			valign = "grow"
		})
		self._player_slots[i] = {}
		self._player_slots[i].panel = slot_panel
		self._player_slots[i].outfit = {}
		local kit_menu = managers.menu:get_menu("kit_menu")
		if kit_menu then
			local kit_slot = kit_menu.renderer:get_player_slot_by_peer_id(i)
			if kit_slot then
				local outfit = kit_slot.outfit
				local character = kit_slot.params and kit_slot.params.character
				if outfit and character then
					self:set_slot_outfit(i, character, outfit)
				end
			end
		end
	end
end


-- Modified to support additional players. Seems to just reduce font size when needed?
function TeamLoadoutItem:reduce_to_small_font()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	-- Only code changed was replacing hardcoded 4 with variable num_player_slots
	TeamLoadoutItem.super.reduce_to_small_font(self)
	for i = 1, num_player_slots do
		if self._player_slots[i].box then
			self._player_slots[i].box:create_sides(self._player_slots[i].panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end
end
