function MenuSceneManager:_setup_lobby_characters()
	local num_player_slots = BigLobbyGlobals:num_player_slots()




	-- Original Code --
	if self._lobby_characters then
		for _, unit in ipairs(self._lobby_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end
	self._lobby_characters = {}
	self._characters_offset = Vector3(0, -200, -130)
	-- End Original Code --




	-- Code changed was:
	-- Replacing hardcoded 4 with variable num_player_slots
	-- Replacing the local masks variable from hardcoded table to dynamically generated via loop
	-- Replacing self._characters_rotation from hardcoded table to dynamically generated via loop
	self._characters_rotation = {}

	-- Dynamically building a range of rotations, used below and by MenuSceneManager:set_lobby_character_out_fit
	local min = -130
	local max = -56
	local range = min - max
	local steps = range / (num_player_slots-1)
	-- The first half of rotations is for all peers except local peer:
	for i = 1, num_player_slots do
		self._characters_rotation[i] = (((i-1) * steps) + max)
	end

	-- The second half of rotations is what the local peer uses based on their peer id:
	for i = 1, num_player_slots do
		self._characters_rotation[i+num_player_slots] = (((i-1) * steps) + max)
	end

	-- Dummy string filled with "dallas" because that's what it was originally
	local masks = {}
	for i = 1, num_player_slots do
		masks[i] = "dallas"
	end


	-- This added logic should alter positioning of players to start at the center
	-- and expand outwards as the player count grows.
	local offset = 0 -- Starting offset
	local peer_rotations = #self._characters_rotation/2
	-- eg 4/2->2, 5/2->2.5->3, 6/2->3, 7/2->3.5->4
	local center_index = math.ceil(peer_rotations/2)
	local function get_new_index(index)
		local is_even = index%2==0
		local new_index = is_even and center_index + offset or center_index - offset
		-- After adding one to the left and one to the right, increase the offset
		-- Unless starting index is odd, then increase straight after(no left/right)
		if not is_even then offset = offset + 1 end

		return new_index
	end


	-- Only code changed here was replacing a hardcoded value of 4 with the variable
	-- num_player_slots and adding the local function above for set_yaw_pitch_roll
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	for i = 1, num_player_slots do
		mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[get_new_index(i)], 0, 0)
		mvector3.set(pos, self._characters_offset)
		mvector3.rotate_with(pos, rot)
		mvector3.set(mvec, pos)
		mvector3.negate(mvec)
		mvector3.set_z(mvec, 0)
		mrotation.set_look_at(rot, mvec, math_up)
		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)
		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[ masks[i] ].unit, unit, nil, masks[i])
		table.insert(self._lobby_characters, unit)
		self:set_lobby_character_visible(i, false, true)
	end
end

function MenuSceneManager:_select_lobby_character_pose(peer_id, unit, weapon_info)




	-- Original Code --
	local state = unit:play_redirect(Idstring("idle_menu"))
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(weapon_info.factory_id)
	local category = tweak_data.weapon[weapon_id].category
	local lobby_poses = self._lobby_poses[weapon_id]
	lobby_poses = lobby_poses or self._lobby_poses[category]
	lobby_poses = lobby_poses or self._lobby_poses.generic
	if type(lobby_poses[1]) == "string" then
		local pose = lobby_poses[math.random(#lobby_poses)]
		unit:anim_state_machine():set_parameter(state, pose, 1)
	else
	-- End Original Code --




		-- Only modification is to use modulus to make sure our lobby peer is given a pose
		local pose = lobby_poses[(peer_id % #lobby_poses) + 1][math.random(#lobby_poses[(peer_id % #lobby_poses) + 1])]




	-- Original Code --
		unit:anim_state_machine():set_parameter(state, pose, 1)
	end
	-- End Original Code --
end


-- TODO: This shouldn't be relevant to gameplay, should be safe to delete.
-- Not required for this mod to work, just updates the test function to work with more players
-- Only for testing (literally no relevance to the game)
-- function MenuSceneManager:test_show_all_lobby_characters(enable_card, pose)
-- 	local num_player_slots = 15--BigLobbyGlobals:num_player_slots()
-- 	pose = pose or "lobby_generic_idle1"
--
-- 	local mvec = Vector3()
-- 	local math_up = math.UP
-- 	local pos = Vector3()
-- 	local rot = Rotation()
-- 	-- Forcing all `self._ti` to be static 1, this was for a predictable outcome
-- 	-- since each call of this function was to test the feature with the client
-- 	-- player in each of the different player slots?
-- 	self._ti = 1--(self._ti or 0) + 1
-- 	--self._ti = (self._ti - 1) % num_player_slots + 1
-- 	for i = 1, num_player_slots do
-- 		local is_me = i == self._ti
-- 		log("TEST LOBBY, is_me = " .. tostring(is_me) .. ", i: " .. tostring(i))
-- 		local unit = self._lobby_characters[i]
-- 		if unit and alive(unit) then
-- 			if enable_card then
-- 				self:set_character_card(i, math.random(25), unit)
-- 			else
-- 				-- Was forcing the pose for some reason instead of fix below?
-- 				self:_set_character_unit_pose(pose, unit)
-- 				-- local state = unit:play_redirect(Idstring("idle_menu"))
-- 				-- Only 4 variations of lobby_generic_idle? 4%4=0 though, might want to + 1 if 0?
-- 				-- unit:anim_state_machine():set_parameter(state, "lobby_generic_idle" .. i%4, 1)
-- 			end
-- 			-- Uses 0+i for rotation index unless it's your player unit then 4+i for some reason?
-- 			-- I guess this explains the 8 values in `self._characters_rotation`, the last half are specific to the client player
-- 			-- TODO: Therefore 4 should really be half of the table size?
-- 			-- will break if not enough rotation indices use a modulus? (or you know, just make the table dynamically built)
-- 			mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and 4 or 0) + i], 0, 0)
-- 			mvector3.set(pos, self._characters_offset)
-- 			if is_me then
-- 				mvector3.set_y(pos, mvector3.y(pos) + 100)
-- 			end
-- 			mvector3.rotate_with(pos, rot)
-- 			mvector3.set(mvec, pos)
-- 			mvector3.negate(mvec)
-- 			mvector3.set_z(mvec, 0)
-- 			mrotation.set_look_at(rot, mvec, math_up)
-- 			unit:set_position(pos)
-- 			unit:set_rotation(rot)
-- 			local character = managers.blackmarket:equipped_character()
-- 			local mask_blueprint = managers.blackmarket:equipped_mask().blueprint
-- 			self:change_lobby_character(i, character)
-- 			unit = self._lobby_characters[i]
-- 			self:set_character_mask_by_id(managers.blackmarket:equipped_mask().mask_id, mask_blueprint, unit, i)
-- 			self:set_character_armor(managers.blackmarket:equipped_armor(), unit)
-- 			self:set_lobby_character_visible(i, true)
-- 		end
-- 	end
-- 	-- I seem to have added this, I guess it was for replacing all the dallas with my own unit? and thus weapons.
-- 	managers.menu_scene:_set_character_equipment()
-- end


-- Modified to hide additional peers.
function MenuSceneManager:hide_all_lobby_characters()
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	for i = 1, num_player_slots do
		self:set_lobby_character_visible(i, false, true)
	end
end


-- Affects the x or y position by an offset for a player model in lobby?
-- TODO: needs to support additional players?
-- function MenuSceneManager:character_screen_position(peer_id)
-- 	local unit = self._lobby_characters[peer_id]
-- 	if unit and alive(unit) then
-- 		local is_me = peer_id == managers.network:session():local_peer():id()
-- 		local peer_3_x_offset = 0
-- 		if peer_id == 3 then
-- 			peer_3_x_offset = is_me and -20 or -40
-- 		end
-- 		local peer_y_offset = 0
-- 		if peer_id == 2 then
-- 			peer_y_offset = is_me and -3 or 0
-- 		elseif peer_id == 3 then
-- 			peer_y_offset = is_me and -7 or 0
-- 		elseif peer_id == 4 then
-- 			peer_y_offset = is_me and 5 or 0
-- 		end
-- 		local spine_pos = unit:get_object(Idstring("Spine")):position() + Vector3(peer_3_x_offset, 0, -5 + 15 * (peer_id % 4) + peer_y_offset)
-- 		return self._workspace:world_to_screen(self._camera_object, spine_pos)
-- 	end
-- end

-- TODO: Probably safe to delete?
-- TODO: Instances of 4 might benefit from being increased to additional player value? I don't think they're related..
-- function MenuSceneManager:mouse_moved(o, x, y)
-- 	if managers.menu_component:input_focus() == true or managers.menu_component:input_focus() == 1 then
-- 		return false, "arrow"
-- 	end
-- 	if self._character_grabbed then
-- 		self._character_yaw = self._character_yaw + (x - self._character_grabbed_current_x) / 4
-- 		if self._use_character_pan and self._character_values and self._scene_templates and self._scene_templates[self._current_scene_template] then
-- 			local new_z = mvector3.z(self._character_values.pos_target) - (y - self._character_grabbed_current_y) / 12
-- 			local default_z = mvector3.z(self._scene_templates and self._scene_templates[self._current_scene_template].character_pos or self._character_values.pos_current)
-- 			new_z = math.clamp(new_z, default_z - 20, default_z + 10)
-- 			mvector3.set_z(self._character_values.pos_target, new_z)
-- 		end
-- 		self._character_unit:set_rotation(Rotation(self._character_yaw, self._character_pitch))
-- 		self._character_grabbed_current_x = x
-- 		self._character_grabbed_current_y = y
-- 		return true, "grab"
-- 	end
-- 	if self._item_grabbed then
-- 		if self._item_unit and alive(self._item_unit.unit) then
-- 			local diff = (y - self._item_grabbed_current_y) / 4
-- 			self._item_yaw = (self._item_yaw + (x - self._item_grabbed_current_x) / 4) % 360
-- 			local yaw_sin = math.sin(self._item_yaw)
-- 			local yaw_cos = math.cos(self._item_yaw)
-- 			local treshhold = math.sin(45)
-- 			if yaw_cos > -treshhold and yaw_cos < treshhold then
-- 			else
-- 				self._item_pitch = math.clamp(self._item_pitch + diff * yaw_cos, -30, 30)
-- 			end
-- 			if yaw_sin > -treshhold and yaw_sin < treshhold then
-- 			else
-- 				self._item_roll = math.clamp(self._item_roll - diff * yaw_sin, -30, 30)
-- 			end
-- 			mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
-- 			mrotation.set_zero(self._item_rot)
-- 			mrotation.multiply(self._item_rot, self._camera_object:rotation())
-- 			mrotation.multiply(self._item_rot, self._item_rot_temp)
-- 			mrotation.multiply(self._item_rot, self._item_rot_mod)
-- 			self._item_unit.unit:set_rotation(self._item_rot)
-- 			local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)
-- 			self._item_unit.unit:set_position(new_pos)
-- 			self._item_unit.unit:set_moving(2)
-- 		end
-- 		self._item_grabbed_current_x = x
-- 		self._item_grabbed_current_y = y
-- 		return true, "grab"
-- 	elseif self._item_move_grabbed and self._item_unit and alive(self._item_unit.unit) then
-- 		local diff_x = (x - self._item_move_grabbed_current_x) / 4
-- 		local diff_y = (y - self._item_move_grabbed_current_y) / 4
-- 		local move_v = Vector3(diff_x, 0, -diff_y):rotate_with(self._camera_object:rotation())
-- 		mvector3.add(self._item_rot_pos, move_v)
-- 		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)
-- 		self._item_unit.unit:set_position(new_pos)
-- 		self._item_unit.unit:set_moving(2)
-- 		self._item_move_grabbed_current_x = x
-- 		self._item_move_grabbed_current_y = y
-- 		return true, "grab"
-- 	end
-- 	if self._use_item_grab and self._item_grab:inside(x, y) then
-- 		return true, "hand"
-- 	end
-- 	if self._use_character_grab and self._character_grab:inside(x, y) then
-- 		return true, "hand"
-- 	end
-- 	if self._use_character_grab2 and self._character_grab2:inside(x, y) then
-- 		return true, "hand"
-- 	end
-- end


-- I run the original method, but then need to correct a hardcoded 4 which requires running a bunch
-- of logic again. Should be safe.


local orig__MenuSceneManager = {}
orig__MenuSceneManager.set_lobby_character_out_fit = MenuSceneManager.set_lobby_character_out_fit
function MenuSceneManager:set_lobby_character_out_fit(i, outfit_string, rank)
	local num_player_slots = BigLobbyGlobals:num_player_slots()

	orig__MenuSceneManager.set_lobby_character_out_fit(self, i, outfit_string, rank)




	-- Original Code -- as far as flow and relevance is concerned at least.
	local unit = self._lobby_characters[i]
	local is_me = i == managers.network:session():local_peer():id()
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()
	-- End Original Code --




	-- Only the hardcoded 4 here is changed to a variable
	-- The 4 refers to halfway point of the rotation table, not player count.
	mrotation.set_yaw_pitch_roll(rot, self._characters_rotation[(is_me and num_player_slots or 0) + i], 0, 0)




	-- Original Code --
	mvector3.set(pos, self._characters_offset)
	if is_me then
		mvector3.set_y(pos, mvector3.y(pos) + 100)
	end
	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mrotation.set_look_at(rot, mvec, math_up)
	unit:set_position(pos)
	unit:set_rotation(rot)
	self:set_lobby_character_visible(i, true)
	-- End Original Code --
end
