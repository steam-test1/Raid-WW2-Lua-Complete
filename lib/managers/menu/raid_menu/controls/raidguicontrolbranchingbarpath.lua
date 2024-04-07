RaidGUIControlBranchingBarPath = RaidGUIControlBranchingBarPath or class(RaidGUIControl)
RaidGUIControlBranchingBarPath.STATE_LOCKED = "STATE_LOCKED"
RaidGUIControlBranchingBarPath.STATE_FULL = "STATE_FULL"
RaidGUIControlBranchingBarPath.STATE_ACTIVE = "STATE_ACTIVE"
RaidGUIControlBranchingBarPath.STATE_DISABLED = "STATE_DISABLED"

function RaidGUIControlBranchingBarPath:init(parent, params)
	RaidGUIControlBranchingBarPath.super.init(self, parent, params)

	self._starting_point_index = params.starting_point_index
	self._starting_point = params.starting_point
	self._ending_point_index = params.ending_point_index
	self._ending_point = params.ending_point
	self._progress = params.progress or 0
	self._state = params.state or self.STATE_ACTIVE
end

function RaidGUIControlBranchingBarPath:set_locked()
	return
end

function RaidGUIControlBranchingBarPath:set_active()
	return
end

function RaidGUIControlBranchingBarPath:set_full()
	return
end

function RaidGUIControlBranchingBarPath:set_disabled()
	return
end

function RaidGUIControlBranchingBarPath:set_progress(progress)
	self._progress = progress
end

function RaidGUIControlBranchingBarPath:state()
	return self._state
end

function RaidGUIControlBranchingBarPath:endpoints()
	return {
		self._starting_point_index,
		self._ending_point_index
	}
end

function RaidGUIControlBranchingBarPath:init_to_state(state)
	return
end
