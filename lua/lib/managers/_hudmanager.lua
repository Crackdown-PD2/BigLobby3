-- Modified to prevent UI bug, local player is no longer panel index 4, but a dynamic
-- value set to `HUDManager.PLAYER_PANEL`.
if BL2Options then return end
function HUDManager:reset_player_hpbar()
	-- Only code changed was replacing two values hardcoded as 4 with the variable HUDManager.PLAYER_PANEL
	local crim_entry = managers.criminals:character_static_data_by_name(managers.criminals:local_character_name())
	if not crim_entry then
		return
	end
	local color_id = managers.network:session():local_peer():id()
	self:set_teammate_callsign(HUDManager.PLAYER_PANEL, color_id)
	self:set_teammate_name(HUDManager.PLAYER_PANEL, managers.network:session():local_peer():name())
end
