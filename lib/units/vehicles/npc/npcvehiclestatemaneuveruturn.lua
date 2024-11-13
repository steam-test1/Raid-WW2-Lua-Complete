NpcVehicleStateManeuverUTurn = NpcVehicleStateManeuverUTurn or class(NpcVehicleStateManeuver)

function NpcVehicleStateManeuverUTurn:init(unit)
	NpcBaseVehicleState.init(self, unit)
end

function NpcVehicleStateManeuverUTurn:on_enter(npc_driving_ext)
	NpcVehicleStateManeuverUTurn.super.on_enter(self, npc_driving_ext)

	local delayed_tick = Application:time() + 0.5
	self._maneuver_actions = {
		{
			tick_at = nil,
			duration = 0.5,
			input = nil,
			tick_at = delayed_tick,
			input = {
				steering = nil,
				acceleration = 1,
				gear = nil,
				handbrake = 1,
				brake = 1,
				steering = NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_FULL_LEFT,
				gear = NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_FIRST
			}
		},
		{
			tick_at = nil,
			duration = 1,
			input = nil,
			tick_at = delayed_tick,
			input = {
				steering = nil,
				acceleration = 1,
				gear = nil,
				handbrake = 0,
				brake = 0,
				steering = NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_FULL_RIGHT,
				gear = NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_REVERSE
			}
		},
		{
			tick_at = 0,
			duration = 0.5,
			input = nil,
			input = {
				steering = nil,
				acceleration = 1,
				gear = nil,
				handbrake = 0,
				brake = 0,
				steering = NpcVehicleDrivingExt.DRIVE_CONTROLS_STEER_STRAIGHT,
				gear = NpcVehicleDrivingExt.DRIVE_CONTROLS_GEAR_FIRST
			}
		}
	}
	self._current_maneuver_action_idx = 1
	local current_action = self._maneuver_actions[self._current_maneuver_action_idx]
end

function NpcVehicleStateManeuverUTurn:update(npc_driving_ext, t, dt)
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

function NpcVehicleStateManeuverUTurn:name()
	return NpcVehicleDrivingExt.STATE_MANEUVER_U_TURN
end

function NpcVehicleStateManeuverUTurn:change_state(npc_driving_ext)
	if not self._maneuver_actions[self._current_maneuver_action_idx] then
		npc_driving_ext:set_state(NpcVehicleDrivingExt.STATE_PURSUIT)
	end
end

function NpcVehicleStateManeuverUTurn:is_maneuvering()
	return true
end
