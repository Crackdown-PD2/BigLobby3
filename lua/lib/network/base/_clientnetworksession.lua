local orig__ClientNetworkSession = {}
orig__ClientNetworkSession.on_join_request_reply = ClientNetworkSession.on_join_request_reply


function ClientNetworkSession:on_join_request_reply(...)
	-- Place params in table
	local params = {...}

	-- Get params we want based on if the func signature is correct
	local reply = params[1]
	local sender = #params==15 and params[15] -- last param should now be 15
	local num_players = sender and type(params[16]) == "number" and params[16]

	-- If the response is `1`(ok), set BigLobby to use host preference or 4 if
	-- a regular lobby (num_players param is falsey).
	if reply == HostNetworkSession.JOIN_REPLY.OK then
		-- Persisting the value across BLT reloads is required, otherwise when you
		-- reach the mission briefing screen, it will use your prefs not hosts.
		Global.BigLobbyPersist.num_players = num_players or 4

		-- Updates state for current BLT instance
		BigLobbyGlobals.num_players = Global.BigLobbyPersist.num_players
	end

	-- Assign sender to original param 16 for the original func call to use
	if sender then params[16] = params[15] end

	-- Pass params on to the original call
	orig__ClientNetworkSession.on_join_request_reply(self, unpack(params))
end
