GroupAIStateRaid = GroupAIStateRaid or class(GroupAIStateBesiege)

-- Lines 3-7
function GroupAIStateRaid:init()
	GroupAIStateRaid.super.init(self)

	self._tweak_data = tweak_data.group_ai.raid
end

-- Lines 9-11
function GroupAIStateRaid:nav_ready_listener_key()
	return "GroupAIStateRaid"
end
