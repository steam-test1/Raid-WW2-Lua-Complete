VehicleStateLocked = VehicleStateLocked or class(BaseVehicleState)

function VehicleStateLocked:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateLocked:enter(state_data, enter_data)
	self._driving_ext:_stop_engine_sound()
	self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	self:disable_interactions()

	if Network:is_server() then
		self._driving_ext:set_input(0, 0, 1, 1, false, false, 2)
	end
end

function VehicleStateLocked:allow_exit()
	return true
end

function VehicleStateLocked:stop_vehicle()
	return true
end

function VehicleStateLocked:is_vulnerable()
	return false
end
