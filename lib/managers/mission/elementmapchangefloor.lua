core:import("CoreMissionScriptElement")

ElementMapChangeFloor = ElementMapChangeFloor or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-8
function ElementMapChangeFloor:init(...)
	ElementMapChangeFloor.super.init(self, ...)

	self._network_execute = false
end

-- Lines 10-12
function ElementMapChangeFloor:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 14-16
function ElementMapChangeFloor:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 18-26
function ElementMapChangeFloor:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.hud:change_map_floor(self._values.floor)
	ElementMapChangeFloor.super.on_executed(self, instigator)
end

-- Lines 28-29
function ElementMapChangeFloor:operation_remove()
end
