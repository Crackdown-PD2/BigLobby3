function CrimeSpreeMissionButton:_get_mission_category(mission)
	if not mission.add then return end
	if mission.add <= 5 then
		return "short"
	elseif mission.add <= 7 then
		return "medium"
	else
		return "long"
	end
end