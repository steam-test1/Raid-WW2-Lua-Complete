GroupAIStateZone = GroupAIStateZone or class(GroupAIStateRaid)

-- Lines 3-7
function GroupAIStateZone:init()
	GroupAIStateZone.super.init(self)

	self._tweak_data = tweak_data.group_ai.street
end

-- Lines 9-11
function GroupAIStateZone:nav_ready_listener_key()
	return "GroupAIStateZone"
end
