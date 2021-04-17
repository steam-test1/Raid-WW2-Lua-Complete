ElementVehicleOperator = ElementVehicleOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementVehicleOperator:init(...)
	ElementVehicleOperator.super.init(self, ...)
end

-- Lines 7-9
function ElementVehicleOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 12-15
function ElementVehicleOperator:_get_unit(unit_id)
	local unit = managers.worldcollection:get_unit_with_id(unit_id, nil, self._mission_script:sync_id())

	return unit
end

-- Lines 18-34
function ElementVehicleOperator:_apply_operator(unit)
	if unit then
		local extension = unit:npc_vehicle_driving() or unit:vehicle_driving()

		if extension then
			local call = extension[self._values.operation]

			if call then
				call(extension, tonumber(self._values.damage))
			else
				Application:error("Vehicle Operator applied to a unit that doesn't support the specified operation - opertion: ", self._values.operation)
			end
		else
			Application:error("Vehicle Operator applied to a unit that isn't a vehicle: ", inspect(unit))
		end
	else
		Application:error("Vehicle Operator applied to a unit that doesn't exist - operator: ", inspect(self._unit))
	end
end

-- Lines 37-57
function ElementVehicleOperator:on_executed(instigator)
	Application:debug("ElementVehicleOperator:on_executed")

	if not self._values.enabled then
		return
	end

	if self._values.use_instigator then
		if instigator then
			self:_apply_operator(instigator)
		end
	else
		for _, id in ipairs(self._values.elements) do
			local unit = self:_get_unit(id)

			self:_apply_operator(unit)
		end
	end

	ElementVehicleOperator.super.on_executed(self, instigator)
end
