core:import("CoreMissionScriptElement")

ElementDropPoint = ElementDropPoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDropPoint:init(...)
	ElementDropPoint.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

function ElementDropPoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementDropPoint:client_on_executed(...)
	self:on_executed(...)
end

function ElementDropPoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementDropPoint.super.on_executed(self, instigator)
end

function ElementDropPoint:operation_remove()
end
