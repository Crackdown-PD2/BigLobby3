-- Disable achievement progress if lobby size is greater than 4 players.
local orig__AchievmentManager = {
	award               = AchievmentManager.award,
	_give_reward        = AchievmentManager._give_reward,
	award_progress      = AchievmentManager.award_progress,
	award_steam         = AchievmentManager.award_steam,
	steam_unlock_result = AchievmentManager.steam_unlock_result
}


function AchievmentManager:disable_achievements()
	-- `managers.network:session()` is here to prevent false positive, you should
	-- be able to unlock achievements while not in a game and have the mod enabled
	local m_session = managers.network:session()

	local isRegularAmount = m_session and (m_session:amount_of_players() > 4)
	local isRegularSize   = m_session and BigLobbyGlobals:is_small_lobby()

	return isRegularAmount or isRegularSize
end


function AchievmentManager.award(self, ...)
	if not self:disable_achievements() then
		orig__AchievmentManager.award(self, ...)
	end
end


function AchievmentManager._give_reward(self, ...)
	if not self:disable_achievements() then
		orig__AchievmentManager._give_reward(self, ...)
	end
end


function AchievmentManager.award_progress(self, ...)
	if not self:disable_achievements() then
		orig__AchievmentManager.award_progress(self, ...)
	end
end


function AchievmentManager.award_steam(self, ...)
	if not self:disable_achievements() then
		orig__AchievmentManager.award_steam(self, ...)
	end
end


-- Original is defined in dot notation, presumably doesn't expect self to be
-- passed in as first param?
function AchievmentManager.steam_unlock_result(...)
	if not AchievmentManager:disable_achievements() then
		orig__AchievmentManager.steam_unlock_result(...)
	end
end
