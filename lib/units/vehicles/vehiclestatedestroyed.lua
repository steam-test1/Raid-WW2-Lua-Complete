VehicleStateDestroyed = VehicleStateDestroyed or class(BaseVehicleState)

function VehicleStateDestroyed:enter(state_data, enter_data)
	Application:info("[VehicleStateDestroyed:enter] DESTROYED!")
	self._driving_ext:_stop_engine_sound()
	self._driving_ext:_start_broken_engine_sound()
	self._driving_ext:_cleanup_vehicle_visuals()
	self._driving_ext:_evacuate_vehicle()

	if Network:is_server() then
		self._driving_ext:set_input(0, 0, 1, 1, false, false, 2)

		if self._driving_ext:is_map_waypoint_enabled() then
			self._driving_ext:disable_map_waypoint()
		end
	end

	local player_vehicle = managers.player:get_vehicle()

	if player_vehicle and player_vehicle.vehicle_unit == self._unit then
		managers.notification:add_notification({
			id = "hud_vehicle_broken",
			duration = 3,
			shelf_life = 5,
			text = managers.localization:text("hud_vehicle_broken")
		})
		managers.player:set_player_state("standard")
	end

	self:disable_interactions()

	if self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_FULL_DESTROYED) then
		self._unit:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_FULL_DESTROYED)
	end

	if Network:is_server() then
		local damage_params = {
			range = 1200,
			damage = 300,
			alert_radius = 20000,
			no_raycast_check_characters = true,
			player_damage = 125,
			curve_pow = 3,
			hit_pos = self._unit:position(),
			collision_slotmask = managers.slot:get_mask("explosion_targets"),
			ignore_unit = self._unit
		}

		managers.explosion:detect_and_give_dmg(damage_params)
	end

	self._unit:interaction():set_contour("standard_color", 1)
end

function VehicleStateDestroyed:exit(state_data)
	self._driving_ext:_stop_engine_sound()
end

function VehicleStateDestroyed:get_action_for_interaction(pos, locator, tweak_data)
	return VehicleDrivingExt.INTERACT_INVALID
end

function VehicleStateDestroyed:allow_exit()
	return true
end

function VehicleStateDestroyed:stop_vehicle()
	return true
end

function VehicleStateDestroyed:is_vulnerable()
	return false
end
