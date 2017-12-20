-- moneytweakdata.lua - MoneyTweakData:init, fixes infinite money loss at the results/exp screen.
-- Must be in this seperate hook as the main init function is called on the loading of the tweak_data lua file, so this hook will be added after the main call of it has already taken place
-- This method prevents issues with other mods that may also touch this function
-- Gets called after every call of the init function on the MoneyTweakData class table, init is called in tweak_data after it has already been initialized for a particular difficulty
Hooks:PostHook(MoneyTweakData, "init", "BigLobbyModifyMoneyTweak", function(self)
	self.alive_humans_multiplier = self._create_value_table(1, self.alive_players_max, BigLobbyGlobals:num_player_slots(), false, 1)
end)
