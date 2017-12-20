-- Instead of overriding methods, I am now hooking them and continuiing the loop
-- to handle >4 peers.
local orig__HUDMissionBriefing = {
	init = HUDMissionBriefing.init
}


function HUDMissionBriefing:init(...)
	orig__HUDMissionBriefing.init(self, ...)

	local num_player_slots = BigLobbyGlobals:num_player_slots()

	local text_font = tweak_data.menu.pd2_small_font
	local text_font_size = tweak_data.menu.pd2_small_font_size

	-- Adjust height of panel to accomodate for the amount of player slots
	self._ready_slot_panel:set_h( text_font_size * num_player_slots + 20 )

	-- Adds player slot panels for peers >4
	if not self._singleplayer then
		local voice_icon, voice_texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_talk")
		local infamy_icon, infamy_rect = tweak_data.hud_icons:get_icon_data("infamy_icon")
		for i = 5, num_player_slots do




	-- Original Code --
			local color_id = i
			local color = tweak_data.chat_colors[color_id]
			local slot_panel = self._ready_slot_panel:panel({
				name = "slot_" .. tostring(i),
				h = text_font_size,
				y = (i - 1) * text_font_size + 10,
				x = 10,
				w = self._ready_slot_panel:w() - 20
			})
			local criminal = slot_panel:text({
				name = "criminal",
				font_size = text_font_size,
				font = text_font,
				color = color,
				text = tweak_data.gui.LONGEST_CHAR_NAME,
				blend_mode = "add",
				align = "left",
				vertical = "center"
			})
			local voice = slot_panel:bitmap({
				name = "voice",
				texture = voice_icon,
				visible = false,
				layer = 2,
				texture_rect = voice_texture_rect,
				w = voice_texture_rect[3],
				h = voice_texture_rect[4],
				color = color,
				x = 10
			})
			local name = slot_panel:text({
				name = "name",
				text = managers.localization:text("menu_lobby_player_slot_available") .. "  ",
				font = text_font,
				font_size = text_font_size,
				color = color:with_alpha(0.5),
				align = "left",
				vertical = "center",
				w = 256,
				h = text_font_size,
				layer = 1,
				blend_mode = "add"
			})
			local status = slot_panel:text({
				name = "status",
				visible = false,
				text = "  ",
				font = text_font,
				font_size = text_font_size,
				align = "right",
				vertical = "center",
				w = 256,
				h = text_font_size,
				layer = 1,
				blend_mode = "add",
				color = tweak_data.screen_colors.text:with_alpha(0.5)
			})
			local infamy = slot_panel:bitmap({
				name = "infamy",
				texture = infamy_icon,
				texture_rect = infamy_rect,
				visible = false,
				layer = 2,
				color = color,
				y = 1
			})
			local detection = slot_panel:panel({
				name = "detection",
				layer = 2,
				visible = false,
				w = slot_panel:h(),
				h = slot_panel:h()
			})
			local detection_ring_left_bg = detection:bitmap({
				name = "detection_left_bg",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				alpha = 0.2,
				blend_mode = "add",
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right_bg = detection:bitmap({
				name = "detection_right_bg",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				alpha = 0.2,
				blend_mode = "add",
				w = detection:w(),
				h = detection:h()
			})
			detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())
			local detection_ring_left = detection:bitmap({
				name = "detection_left",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				blend_mode = "add",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})
			local detection_ring_right = detection:bitmap({
				name = "detection_right",
				texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
				render_template = "VertexColorTexturedRadial",
				blend_mode = "add",
				layer = 1,
				w = detection:w(),
				h = detection:h()
			})
			detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())
			local detection_value = slot_panel:text({
				name = "detection_value",
				font_size = text_font_size,
				font = text_font,
				color = color,
				text = " ",
				blend_mode = "add",
				align = "left",
				vertical = "center"
			})
			detection:set_left(slot_panel:w() * 0.65)
			detection_value:set_left(detection:right() + 2)
			detection_value:set_visible(detection:visible())
			local _, _, w, _ = criminal:text_rect()
			voice:set_left(w + 2)
			criminal:set_w(w)
			criminal:set_align("right")
			criminal:set_text("")
			name:set_left(voice:right() + 2)
			status:set_right(slot_panel:w())
			infamy:set_left(name:x())
		end
		BoxGuiObject:new(self._ready_slot_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
	-- End Original Code --
end
