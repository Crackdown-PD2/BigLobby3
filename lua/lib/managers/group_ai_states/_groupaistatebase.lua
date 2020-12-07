-- Modified to support full team size instead of hardcoded 3, not hugely relevant as is a bot thing.
function GroupAIStateBase:on_criminal_team_AI_enabled_state_changed()
	local num_player_slots = BigLobbyGlobals:num_player_slots() - 1

	-- Only code changed was replacing hardcoded 3 with variable num_player_slots
	if Network:is_client() then
		return
	end
	if managers.groupai:state():team_ai_enabled() then
		self:fill_criminal_team_with_AI()
	else
		for i = 1, num_player_slots do
			self:remove_one_teamAI()
		end
	end
end

Hooks:PostHook( GroupAIStateBase , "whisper_mode" , "GroupAIStateBasePostWhisperMode" , function( self )
	for _, ai in pairs(self:all_AI_criminals()) do
		if self._whisper_mode == true and BigLobbyGlobals.auto_stop_all_bots_settings then
			ai.unit:movement():set_should_stay(true)
		elseif self._whisper_mode == false and BigLobbyGlobals.auto_stop_all_bots_settings then
			ai.unit:movement():set_should_stay(false)
		end
	end
end )