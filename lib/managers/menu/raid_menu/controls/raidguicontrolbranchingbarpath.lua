RaidGUIControlBranchingBarPath = RaidGUIControlBranchingBarPath or class(RaidGUIControl)
RaidGUIControlBranchingBarPath.STATE_LOCKED = "STATE_LOCKED"
RaidGUIControlBranchingBarPath.STATE_FULL = "STATE_FULL"
RaidGUIControlBranchingBarPath.STATE_ACTIVE = "STATE_ACTIVE"
RaidGUIControlBranchingBarPath.STATE_DISABLED = "STATE_DISABLED"

-- Lines 8-19
function RaidGUIControlBranchingBarPath:init(parent, params)
	RaidGUIControlBranchingBarPath.super.init(self, parent, params)

	self._starting_point_index = params.starting_point_index
	self._starting_point = params.starting_point
	self._ending_point_index = params.ending_point_index
	self._ending_point = params.ending_point
	self._progress = params.progress or 0
	self._state = params.state or self.STATE_ACTIVE
end

-- Lines 23-24
function RaidGUIControlBranchingBarPath:set_locked()
end

-- Lines 28-29
function RaidGUIControlBranchingBarPath:set_active()
end

-- Lines 33-34
function RaidGUIControlBranchingBarPath:set_full()
end

-- Lines 38-39
function RaidGUIControlBranchingBarPath:set_disabled()
end

-- Lines 41-43
function RaidGUIControlBranchingBarPath:set_progress(progress)
	self._progress = progress
end

-- Lines 45-47
function RaidGUIControlBranchingBarPath:state()
	return self._state
end

-- Lines 49-51
function RaidGUIControlBranchingBarPath:endpoints()
	return {
		self._starting_point_index,
		self._ending_point_index
	}
end

-- Lines 53-54
function RaidGUIControlBranchingBarPath:init_to_state(state)
end
