GroupAIStateZone = GroupAIStateZone or class(GroupAIStateRaid)

function GroupAIStateZone:init()
	GroupAIStateZone.super.init(self)

	self._tweak_data = tweak_data.group_ai.zone
end

function GroupAIStateZone:nav_ready_listener_key()
	return "GroupAIStateZone"
end
