-- This function contains a variable `names` which is a table of dummy name strings.
-- Unfortunately the function is massive and that data is hardcoded at the start of
-- the function. Thankfully we might still be able to work around it without breaking
-- other mods such as hud mods which may heavily modify this code.
local orig__HUDTeammate = {
	init = HUDTeammate.init
}


function HUDTeammate:init(i, teammates_panel, is_player, width)
	-- Main difference in this function is based on the `main_player` variable
	-- This refers to the local/client player, so as long as we can make that
	-- true when appropriate and false when not, we should be good. Just need to
	-- fix some settings after the original function finishes and hopefully
	-- everything works as it should.
	local fake_i = 1
	local real_player_panel = HUDManager.PLAYER_PANEL

	if (i == HUDManager.PLAYER_PANEL) then
		fake_i = 4
		HUDManager.PLAYER_PANEL = 4
	end

	orig__HUDTeammate.init(self, fake_i, teammates_panel, is_player, width)

	-- Fix some properties to align with the real i value.
	self._id = i
	self._panel:set_name("" .. i)
	self._panel:child("callsign"):set_color(tweak_data.chat_colors[i]:with_alpha(1))

	HUDManager.PLAYER_PANEL = real_player_panel
end
