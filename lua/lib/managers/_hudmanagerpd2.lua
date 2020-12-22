-- This references 4 as in the 4th panel on the UI(one on the furtherest right) by default.
-- Otherwise known as the local players UI panel.
-- By updating this value, we keep that consistency that the player is used to.
HUDManager.PLAYER_PANEL = BigLobbyGlobals:num_player_slots()
if BL2Options then return end
--Nothing seems to call this, I don't think it's even used.. Panels are created somewhere else
function HUDManager:_create_teammates_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end
	local h = self:teampanels_height()
	local teammates_panel = hud.panel:panel({
		name = "teammates_panel",
		h = h,
		y = hud.panel:h() - h,
		halign = "grow",
		valign = "bottom"
	})
	local teammate_w = 204
	local player_gap = 240
	local small_gap = (teammates_panel:w() - player_gap - teammate_w * HUDManager.PLAYER_PANEL) / (HUDManager.PLAYER_PANEL - 1)
	for i = 1, HUDManager.PLAYER_PANEL do
		local is_player = i == HUDManager.PLAYER_PANEL
		--do break end -- unhandled boolean indicator -- Decompile error here, hopefully not causing problems.

		self._hud.teammate_panels_data[i] = {
			taken = false, --this was true, but causes problem with add_teammate_panel() and data.taken, so maybe bad decompile bug from above?
			special_equipments = {}
		}
		local pw = teammate_w + (is_player and 0 or 64)
		local teammate = HUDTeammate:new(i, teammates_panel, is_player, pw)
		local x = math.floor((pw + small_gap) * (i - 1) + (i == HUDManager.PLAYER_PANEL and player_gap or 0))
		teammate._panel:set_x(math.floor(x))
		table.insert(self._teammate_panels, teammate)
		if is_player then
			teammate:add_panel()
		end
	end
end


-- TODO: nil check added, must have been causing a problem in past, not sure if still valid problem
-- Possibly safe to delete
local orig__HUDManager = {}
orig__HUDManager.add_weapon = HUDManager.add_weapon
function HUDManager:add_weapon(data)
	if not self._teammate_panels[HUDManager.PLAYER_PANEL] and not self._teammate_panels[HUDManager.PLAYER_PANEL]:panel() then
		log("[HUDManager :add_weapon] teammate_panels[HUDManager.PLAYER_PANEL] or teammate_panels[HUDManager.PLAYER_PANEL]:panel() is nil, HUDManager.PLAYER_PANEL = " .. tostring(HUDManager.PLAYER_PANEL))
		return
	end


	orig__HUDManager.add_weapon(self, data)
end


-- `self:set_teammate_callsign(i, ai and 5 or peer_id)`
-- Replaced hardcoded 5 with (HUDManager.PLAYER_PANEL + 1)
-- TODO: Can probably wrap the function call and make the fix afterwards
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
	for i, data in ipairs(self._hud.teammate_panels_data) do
		if not data.taken then
			self._teammate_panels[i]:add_panel()
			self._teammate_panels[i]:set_peer_id(peer_id)
			self._teammate_panels[i]:set_ai(ai)
			self:set_teammate_callsign(i, ai and (HUDManager.PLAYER_PANEL + 1) or peer_id) -- TODO: this should cater for AI properly(change that 5 to dynamic variable)




	-- Original Code --
			self:set_teammate_name(i, player_name)
			self:set_teammate_state(i, ai and "ai" or "player")
			if peer_id then
				local peer_equipment = managers.player:get_synced_equipment_possession(peer_id) or {}
				for equipment, amount in pairs(peer_equipment) do
					self:add_teammate_special_equipment(i, {
						id = equipment,
						icon = tweak_data.equipments.specials[equipment].icon,
						amount = amount
					})
				end
				local peer_deployable_equipment = managers.player:get_synced_deployable_equipment(peer_id)
				if peer_deployable_equipment then
					local icon = tweak_data.equipments[peer_deployable_equipment.deployable].icon
					self:set_deployable_equipment(i, {
						icon = icon,
						amount = peer_deployable_equipment.amount
					})
				end
				local peer_cable_ties = managers.player:get_synced_cable_ties(peer_id)
				if peer_cable_ties then
					local icon = tweak_data.equipments.specials.cable_tie.icon
					self:set_cable_tie(i, {
						icon = icon,
						amount = peer_cable_ties.amount
					})
				end
				local peer_grenades = managers.player:get_synced_grenades(peer_id)
				if peer_grenades then
					local icon = tweak_data.blackmarket.projectiles[peer_grenades.grenade].icon
					self:set_teammate_grenades(i, {
						icon = icon,
						amount = Application:digest_value(peer_grenades.amount, false)
					})
				end
			end
			local unit = managers.criminals:character_unit_by_name(character_name)
			if alive(unit) then
				local weapon = unit:inventory():equipped_unit()
				if alive(weapon) then
					local icon = weapon:base():weapon_tweak_data().hud_icon
					local equipped_selection = unit:inventory():equipped_selection()
					self:_set_teammate_weapon_selected(i, equipped_selection, icon)
				end
			end
			local peer_ammo_info = managers.player:get_synced_ammo_info(peer_id)
			if peer_ammo_info then
				for selection_index, ammo_info in pairs(peer_ammo_info) do
					self:set_teammate_ammo_amount(i, selection_index, unpack(ammo_info))
				end
			end
			local peer_carry_data = managers.player:get_synced_carry(peer_id)
			if peer_carry_data then
				self:set_teammate_carry_info(i, peer_carry_data.carry_id, managers.loot:get_real_value(peer_carry_data.carry_id, peer_carry_data.multiplier))
			end
			data.taken = true
			return i
		end
	end
	-- End Original Code --
end

function HUDManager:set_teammate_health(i, data)
	if i and self._teammate_panels and self._teammate_panels[i] then
		self._teammate_panels[i]:set_health(data)
	end
end