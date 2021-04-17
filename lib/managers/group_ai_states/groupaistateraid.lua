GroupAIStateRaid = GroupAIStateRaid or class(GroupAIStateBesiege)

-- Lines 4-8
function GroupAIStateRaid:init()
	GroupAIStateRaid.super.init(self)

	self._tweak_data = tweak_data.group_ai.raid
end

-- Lines 10-12
function GroupAIStateRaid:nav_ready_listener_key()
	return "GroupAIStateRaid"
end
