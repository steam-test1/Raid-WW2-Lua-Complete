NpcVehicleStateManeuverBackLeft = NpcVehicleStateManeuverBackLeft or class(NpcVehicleStateManeuver)

function NpcVehicleStateManeuverBackLeft:init(unit)
	NpcBaseVehicleState.init(self, unit)
end

function NpcVehicleStateManeuverBackLeft:on_enter(npc_driving_ext)
	NpcVehicleStateManeuverBackLeft.super.on_enter(self, npc_driving_ext)

	local delayed_tick = Application:time() + 0.5
	self._maneuver_actions = {
		{
			duration = 1,
			tick_at = delayed_tick,
			input = {
				brake = 0,
				acceleration = 1,
				handbrake = 0,
				steering = NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_FULL_RIGHT,
				gear = NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_REVERSE
			}
		},
		{
			tick_at = 0,
			duration = 1,
			input = {
				brake = 0,
				acceleration = 1,
				handbrake = 0,
				steering = NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_STRAIGHT,
				gear = NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_FIRST
			}
		}
	}
	self._current_maneuver_action_idx = 1
	local current_action = self._maneuver_actions[self._current_maneuver_action_idx]
end

function NpcVehicleStateManeuverBackLeft:update(npc_driving_ext, t, dt)
	local current_action = self._maneuver_actions[self._current_maneuver_action_idx]

	if current_action then
		if current_action.tick_at < t and t < current_action.tick_at + current_action.duration then
			npc_driving_ext:set_input(current_action.input.acceleration, current_action.input.steering, current_action.input.brake, current_action.input.handbrake, false, false, current_action.input.gear)
		elseif current_action.tick_at < t then
			self._current_maneuver_action_idx = self._current_maneuver_action_idx + 1
			current_action = self._maneuver_actions[self._current_maneuver_action_idx]

			if current_action then
				current_action.tick_at = t + current_action.duration
			end
		end
	end
end

function NpcVehicleStateManeuverBackLeft:name()
	return NpcVehicleDrivingExt.STATE_MANEUVER_BACK_LEFT
end

function NpcVehicleStateManeuverBackLeft:change_state(npc_driving_ext)
	if not self._maneuver_actions[self._current_maneuver_action_idx] then
		npc_driving_ext:set_state(NpcVehicleDrivingExt.STATE_PURSUIT)
	end
end

function NpcVehicleStateManeuverBackLeft:is_maneuvering()
	return true
end
