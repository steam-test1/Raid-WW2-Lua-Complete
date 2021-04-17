ElementEnvironmentOperator = ElementEnvironmentOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-6
function ElementEnvironmentOperator:init(...)
	self._has_executed = false

	ElementEnvironmentOperator.super.init(self, ...)
end

-- Lines 8-13
function ElementEnvironmentOperator:stop_simulation(...)
	if self._old_default_environment then
		managers.viewport:set_default_environment(self._old_default_environment, nil, nil)
	end

	ElementEnvironmentOperator.super.destroy(self, ...)
end

-- Lines 16-18
function ElementEnvironmentOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 20-22
function ElementEnvironmentOperator:save(data)
	data.has_executed = self._has_executed
end

-- Lines 24-30
function ElementEnvironmentOperator:load(data)
	self._has_executed = data.has_executed

	if self._has_executed == true then
		self._old_default_environment = managers.viewport:default_environment()

		managers.viewport:set_default_environment(self._values.environment, nil, nil)
	end
end

-- Lines 32-43
function ElementEnvironmentOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self._has_executed = true
	self._old_default_environment = managers.viewport:default_environment()

	managers.viewport:set_default_environment(self._values.environment, nil, nil)
	ElementEnvironmentOperator.super.on_executed(self, instigator)
end
