for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
	ai.unit:movement():set_should_stay(true)
end