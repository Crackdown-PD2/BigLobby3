-- Store original functions from the ones we modify
local orig_ElementAreaTrigger = {
	project_amount_all = ElementAreaTrigger.project_amount_all
}


-- Capping the value to 4 for `criminals`/`local_criminals` instigators to avoid
-- some event comparisons that fail above expected max value of 4.
-- Start of Framing Frame Day 2 where everyone needs to be in the train is said to be affected
function ElementAreaTrigger:project_amount_all()
	local i = orig_ElementAreaTrigger.project_amount_all(self)

	-- Ensure i is no higher than 4 for these instigators (May also want to include `ai_teammates`?)
	-- This value for these instigators includes both Peers and AI criminals
	if self._values.instigator == "criminals" or self._values.instigator == "local_criminals" then
		i = i > 4 and 4 or i
	end

	return i
end
