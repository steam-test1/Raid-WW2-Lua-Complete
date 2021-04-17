core:import("CoreMissionScriptElement")

ElementBarrage = ElementBarrage or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementBarrage:init(...)
	ElementBarrage.super.init(self, ...)
end

-- Lines 9-39
function ElementBarrage:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self._values.type or not self._values.operation then
		return
	end

	if self._values.operation == "start" then
		local tweak_data = tweak_data.barrage[self._values.type]

		if not tweak_data then
			Application:error("[Barrage] Barrage tweak data doesn't exist for barrage type: ", self._values.type)

			return
		end

		managers.barrage:start_barrage(tweak_data)
	elseif self._values.operation == "stop" then
		managers.barrage:stop_barrage()
	elseif self._values.operation == "set_spotter_type" then
		local tweak_data = tweak_data.barrage[self._values.type]

		if not tweak_data then
			Application:error("[Barrage] Barrage tweak data doesn't exist for barrage type: ", self._values.type)

			return
		end

		managers.barrage:set_spotter_barrage_type(tweak_data)
	else
		Application:error("[Barrage] Barrage manager doesn't support operation: ", self._values.operation)
	end

	ElementBarrage.super.on_executed(self, instigator)
end

-- Lines 41-43
function ElementBarrage:client_on_executed(...)
	ElementBarrage.super.on_executed(self)
end
