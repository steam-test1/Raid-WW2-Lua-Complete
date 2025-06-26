core:import("CoreMissionScriptElement")

ElementBlurZone = ElementBlurZone or class(CoreMissionScriptElement.MissionScriptElement)

function ElementBlurZone:init(...)
	ElementBlurZone.super.init(self, ...)
end

function ElementBlurZone:destroy()
	managers.environment_controller:clear_blurzone(self:_get_unique_id())
end

function ElementBlurZone:client_on_executed(...)
	self:on_executed(...)
end

function ElementBlurZone:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	managers.environment_controller:set_blurzone(self:_get_unique_id(), self._values.mode, self._values.position, self._values.radius, self._values.height)
	ElementBlurZone.super.on_executed(self, instigator)
end

function ElementBlurZone:operation_remove()
	managers.environment_controller:set_blurzone(self:_get_unique_id(), 0, self._values.position, self._values.radius, self._values.height)
end

function ElementBlurZone:_get_unique_id()
	return self._sync_id .. "_" .. self._id
end
