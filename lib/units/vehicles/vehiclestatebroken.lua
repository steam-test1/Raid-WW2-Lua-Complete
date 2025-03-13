VehicleStateBroken = VehicleStateBroken or class(BaseVehicleState)

function VehicleStateBroken:init(unit)
	BaseVehicleState.init(self, unit)
end

function VehicleStateBroken:enter(state_data, enter_data)
	self._driving_ext:_stop_engine_sound()
	self._driving_ext:_start_broken_engine_sound()
	self:adjust_interactions()

	if Network:is_server() then
		self._driving_ext:set_input(0, 0, 1, 1, false, false, 2)
	end

	local player_vehicle = managers.player:get_vehicle()

	if player_vehicle and player_vehicle.vehicle_unit == self._unit then
		managers.notification:add_notification({
			duration = 3,
			shelf_life = 5,
			id = "hud_vehicle_broken",
			text = managers.localization:text("hud_vehicle_broken")
		})
	end

	if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_FULL_DAMAGED)
	end

	self._unit:interaction():set_contour("standard_color", 1)
end

function VehicleStateBroken:adjust_interactions()
	VehicleStateBroken.super.adjust_interactions(self)

	if self._driving_ext:is_interaction_allowed() and self._unit:damage() and self._unit:damage():has_sequence(VehicleDrivingExt.INTERACT_ENTRY_ENABLED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_INTERACTION_ENABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_ENTRY_DISABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_LOOT_ENABLED)
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.INTERACT_REPAIR_ENABLED)

		self._driving_ext._interaction_enter_vehicle = false

		if self._driving_ext._has_trunk then
			self._driving_ext._interaction_trunk = true
		else
			self._driving_ext._interaction_loot = true
		end

		self._driving_ext._interaction_repair = true
	end
end

function VehicleStateBroken:get_action_for_interaction(pos, locator, tweak_data)
	local action = VehicleDrivingExt.INTERACT_INVALID
	local seat, seat_distance = self._driving_ext:get_available_seat(pos)
	local loot_point, loot_point_distance = self._driving_ext:get_nearest_loot_point(pos)

	if self._driving_ext:is_loot_interaction_enabled() and seat and loot_point and loot_point_distance <= seat_distance and self._driving_ext:has_loot_stored() then
		action = VehicleDrivingExt.INTERACT_LOOT

		self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_ENTER)
	else
		action = VehicleDrivingExt.INTERACT_REPAIR
		local multiplier = managers.player:upgrade_value("interaction", "handyman_vehicle_speed_multipler", 1)

		self._unit:interaction():set_override_timer_value(VehicleDrivingExt.TIME_REPAIR * multiplier)
	end

	return action
end

function VehicleStateBroken:stop_vehicle()
	return true
end

function VehicleStateBroken:exit(state_data)
	self._driving_ext:_stop_engine_sound()
end
