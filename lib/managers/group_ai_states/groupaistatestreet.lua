GroupAIStateStreet = GroupAIStateStreet or class(GroupAIStateRaid)

function GroupAIStateStreet:init()
	GroupAIStateStreet.super.init(self)
	Application:warn("[GroupAIStateStreet:init] This groupAi state is not properly implemented!")
end

function GroupAIStateStreet:nav_ready_listener_key()
	return "GroupAIStateStreet"
end
