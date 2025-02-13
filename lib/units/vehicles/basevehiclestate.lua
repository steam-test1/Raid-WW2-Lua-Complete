BaseVehicleState = BaseVehicleState or class()

function BaseVehicleState:init(unit)
	self._unit = unit
	self._driving_ext = unit:vehicle_driving()
end

function BaseVehicleState:update(t, dt)
	self._driving_ext:state_out_update(t, dt)
end

function BaseVehicleState:enter(state_data, enter_data)
end

function BaseVehicleState:exit(state_data)
end

function BaseVehicleState:get_action_for_interaction(pos, locator, tweak_data)
	local locator_name = locator:name()

	for _, seat in pairs(self._driving_ext:seats()) do
		if seat.locator_name == locator_name then
			if seat.driving and not seat.occupant then
				return VehicleDrivingExt.INTERACT_DRIVE
			else
				return VehicleDrivingExt.INTERACT_ENTER
			end
		end
	end

	if self._driving_ext:is_loot_interaction_enabled() and self._driving_ext:has_loot_stored() then
		for _, loot_point in pairs(self._driving_ext:loot_points()) do
			if loot_point.locator_name == locator_name then
				return VehicleDrivingExt.INTERACT_LOOT
			end
		end
	end

	if self._driving_ext:repair_locator() == locator_name then
		return VehicleDrivingExt.INTERACT_REPAIR
	end

	if self._driving_ext:trunk_locator() == locator_name then
		return VehicleDrivingExt.INTERACT_TRUNK
	end

	return VehicleDrivingExt.INTERACT_INVALID
end

function BaseVehicleState:adjust_interactions()
	if not self._driving_ext:is_interaction_allowed() then
		self:disable_interactions()
	end
end

function BaseVehicleState:disable_interactions()
	if self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_DISABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_DISABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_DISABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_DISABLED)

		self._driving_ext._interaction_enter_vehicle = false
		self._driving_ext._interaction_loot = false
		self._driving_ext._interaction_trunk = false
		self._driving_ext._interaction_repair = false
	end
end

function BaseVehicleState:allow_exit()
	return true
end

function BaseVehicleState:is_vulnerable()
	return false
end

function BaseVehicleState:stop_vehicle()
	return false
end
