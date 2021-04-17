RaidGUIControlBranchingBarNode = RaidGUIControlBranchingBarNode or class(RaidGUIControl)
RaidGUIControlBranchingBarNode.STATE_INACTIVE = "STATE_INACTIVE"
RaidGUIControlBranchingBarNode.STATE_HOVER = "STATE_HOVER"
RaidGUIControlBranchingBarNode.STATE_ACTIVE = "STATE_ACTIVE"
RaidGUIControlBranchingBarNode.STATE_SELECTED = "STATE_SELECTED"
RaidGUIControlBranchingBarNode.STATE_PENDING = "STATE_PENDING"
RaidGUIControlBranchingBarNode.STATE_PENDING_BLOCKED = "STATE_PENDING_BLOCKED"
RaidGUIControlBranchingBarNode.STATE_DISABLED = "STATE_DISABLED"

-- Lines 11-19
function RaidGUIControlBranchingBarNode:init(parent, params)
	RaidGUIControlBranchingBarNode.super.init(self, parent, params)
	self:_create_panel()

	self._parents = params.parents or {
		1
	}
	self._level = params.level or 1
	self._state = params.state or self.STATE_INACTIVE
end

-- Lines 21-31
function RaidGUIControlBranchingBarNode:_create_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_node"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w
	panel_params.h = self._params.h
	self._object = self._panel:panel(panel_params)
end

-- Lines 37-38
function RaidGUIControlBranchingBarNode:set_inactive()
end

-- Lines 42-43
function RaidGUIControlBranchingBarNode:set_selected()
end

-- Lines 47-48
function RaidGUIControlBranchingBarNode:set_active()
end

-- Lines 52-53
function RaidGUIControlBranchingBarNode:set_pending()
end

-- Lines 57-58
function RaidGUIControlBranchingBarNode:set_pending_blocked()
end

-- Lines 62-63
function RaidGUIControlBranchingBarNode:set_disabled()
end

-- Lines 65-67
function RaidGUIControlBranchingBarNode:state()
	return self._state
end

-- Lines 69-71
function RaidGUIControlBranchingBarNode:parents()
	return self._parents
end

-- Lines 73-75
function RaidGUIControlBranchingBarNode:level()
	return self._level
end

-- Lines 77-78
function RaidGUIControlBranchingBarNode:init_to_state(state)
end
