ElementEnvironmentAreaOperator = ElementEnvironmentAreaOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-6
function ElementEnvironmentAreaOperator:init(...)
	self._has_executed = false

	ElementEnvironmentAreaOperator.super.init(self, ...)
end

-- Lines 8-10
function ElementEnvironmentAreaOperator:stop_simulation(...)
	ElementEnvironmentAreaOperator.super.destroy(self, ...)
end

-- Lines 12-14
function ElementEnvironmentAreaOperator:save(data)
	data.has_executed = self._has_executed
end

-- Lines 16-28
function ElementEnvironmentAreaOperator:load(data)
	self._has_executed = data.has_executed

	if self._has_executed == true then
		local environment_area = managers.environment_area:get_area_by_name(self._values.environment_area)

		if environment_area then
			environment_area:set_environment(self._values.environment)
		end
	end
end

-- Lines 30-32
function ElementEnvironmentAreaOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 34-50
function ElementEnvironmentAreaOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local environment_area = managers.environment_area:get_area_by_name(self._values.environment_area)

	if environment_area then
		environment_area:set_environment(self._values.environment)
	end

	self._has_executed = true

	ElementEnvironmentAreaOperator.super.on_executed(self, instigator)
end
