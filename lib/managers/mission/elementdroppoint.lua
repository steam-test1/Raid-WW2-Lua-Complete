core:import("CoreMissionScriptElement")

ElementDropPoint = ElementDropPoint or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-13
function ElementDropPoint:init(...)
	ElementDropPoint.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

-- Lines 15-17
function ElementDropPoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 19-21
function ElementDropPoint:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 23-34
function ElementDropPoint:on_executed(instigator)
	return

	if not self._values.enabled then
		return
	end

	ElementDropPoint.super.on_executed(self, instigator)
end

-- Lines 36-37
function ElementDropPoint:operation_remove()
end
