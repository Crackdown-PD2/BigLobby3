-- Store original functions from the ones we modify
local orig_NetworkPeer = {
	send = NetworkPeer.send
}


function NetworkPeer:send(func_name, ...)
	-- In biglobby mode if the func is matched, call the prefixed version instead
	if not BigLobbyGlobals:is_small_lobby() and BigLobbyGlobals.network_handler_funcs[func_name] then
		func_name = 'biglobby__' .. func_name
	end

	-- Call Original Code
	orig_NetworkPeer.send(self, func_name, ...)
end
