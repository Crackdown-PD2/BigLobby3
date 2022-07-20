-- Updates colours to support UI elements for additional peers while avoiding those
-- that affect gameplay such as orange and yellow

local num_player_slots = BigLobbyGlobals:num_player_slots()

-- AI assigned colour:
local team_ai = Vector3(0.2, 0.8, 1)

-- Fixed colours
tweak_data.peer_vector_colors = {}

-- This doesn't appear to be referenced, not sure why it still exists in codebase
tweak_data.peer_colors = {}

-- Make sure we have enough colours to support the number of player slots
local steps = 360 / num_player_slots
for i = 0, num_player_slots - 1 do
	-- RGB channels
	local hue = i * steps
	local col = Vector3(_G.HUSL.huslp_to_rgb(hue, 100, 60))

	table.insert(tweak_data.peer_vector_colors, col)
	table.insert(tweak_data.peer_colors, tostring("team_colour_") .. i)
end

math.randomseed(42)
table.shuffle(tweak_data.peer_vector_colors)
math.randomseed(os.time())

-- AI labels will use the last value so we add it at the end
table.insert(tweak_data.peer_vector_colors, team_ai)
table.insert(tweak_data.peer_colors, "mrai")

-- Dynamically added now based on peer_vector_colors table
tweak_data.chat_colors = {}
for i = 1, #tweak_data.peer_vector_colors do
	tweak_data.chat_colors[i] = Color(tweak_data.peer_vector_colors[i]:unpack())
end

-- Use the same colours created for chat for preplanning
tweak_data.preplanning_peer_colors = {}
for i = 1, #tweak_data.peer_vector_colors do
	tweak_data.preplanning_peer_colors[i] = Color(tweak_data.peer_vector_colors[i]:unpack())
end

tweak_data.team_ai.stop_action.distance = 10000000000000000
