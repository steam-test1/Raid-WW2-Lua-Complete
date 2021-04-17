ElementEnvironmentEffect = ElementEnvironmentEffect or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-6
function ElementEnvironmentEffect:init(...)
	self._has_executed = false

	ElementEnvironmentEffect.super.init(self, ...)
end

-- Lines 8-11
function ElementEnvironmentEffect:stop_simulation(...)
	managers.environment_effects:stop(self._values.effect)
	ElementEnvironmentEffect.super.destroy(self, ...)
end

-- Lines 14-16
function ElementEnvironmentEffect:pre_destroy()
	managers.environment_effects:stop(self._values.effect)
end

-- Lines 18-20
function ElementEnvironmentEffect:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 22-24
function ElementEnvironmentEffect:save(data)
	data.has_executed = self._has_executed
end

-- Lines 26-31
function ElementEnvironmentEffect:load(data)
	self._has_executed = data.has_executed

	if self._has_executed == true then
		managers.environment_effects:use(self._values.effect)
	end
end

-- Lines 33-50
function ElementEnvironmentEffect:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self._has_executed = true

	if self._values.local_only and instigator == managers.player:local_player() then
		local action = self._values.action

		if action == "set" then
			managers.environment_effects:use(self._values.effect)
		elseif action == "remove" then
			managers.environment_effects:stop(self._values.effect)
		end
	end

	ElementEnvironmentEffect.super.on_executed(self, instigator)
end
