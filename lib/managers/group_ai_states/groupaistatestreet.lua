GroupAIStateStreet = GroupAIStateStreet or class(GroupAIStateRaid)

-- Lines 5-12
function GroupAIStateStreet:init()
	GroupAIStateStreet.super.init(self)
	Application:warn("[GroupAIStateStreet:init] This groupAi state is not properly implemented!")
end

-- Lines 14-16
function GroupAIStateStreet:nav_ready_listener_key()
	return "GroupAIStateStreet"
end
