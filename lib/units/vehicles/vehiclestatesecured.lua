VehicleStateSecured = VehicleStateSecured or class(BaseVehicleState)

function VehicleStateSecured:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateSecured:enter(state_data, enter_data)
	self._driving_ext:_stop_engine_sound()
	self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	self:adjust_interactions()

	if Network:is_server() then
		self._driving_ext:set_input(0, 0, 1, 1, false, false, 2)
	end
end

function VehicleStateSecured:adjust_interactions()
	VehicleStateSecured.super.adjust_interactions(self)

	if self._driving_ext:is_interaction_allowed() then
		if self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
			self._driving_ext._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_DISABLED)
			self._driving_ext._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_DISABLED)
			self._driving_ext._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_DISABLED)
			self._driving_ext._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_DISABLED)
		end

		self._interaction_enter_vehicle = false
		self._interaction_loot = false

		if self._driving_ext._has_trunk then
			self._driving_ext._interaction_trunk = true
		else
			self._driving_ext._interaction_loot = true
		end

		self._interaction_repair = false
	end
end

function VehicleStateSecured:stop_vehicle()
	return true
end
