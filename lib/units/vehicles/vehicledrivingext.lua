require("lib/units/vehicles/BaseVehicleState")
require("lib/units/vehicles/VehicleStateBroken")
require("lib/units/vehicles/VehicleStateDriving")
require("lib/units/vehicles/VehicleStateInactive")
require("lib/units/vehicles/VehicleStateInvalid")
require("lib/units/vehicles/VehicleStateLocked")
require("lib/units/vehicles/VehicleStateParked")
require("lib/units/vehicles/VehicleStateSecured")
require("lib/units/vehicles/VehicleStateFrozen")
require("lib/units/vehicles/VehicleStateBlocked")

VehicleDrivingExt = VehicleDrivingExt or class()
VehicleDrivingExt.SEAT_PREFIX = "v_"
VehicleDrivingExt.INTERACTION_PREFIX = "interact_"
VehicleDrivingExt.EXIT_PREFIX = "v_exit_"
VehicleDrivingExt.THIRD_PREFIX = "v_third_"
VehicleDrivingExt.LOOT_PREFIX = "v_"
VehicleDrivingExt.INTERACT_INVALID = -1
VehicleDrivingExt.INTERACT_ENTER = 0
VehicleDrivingExt.INTERACT_LOOT = 1
VehicleDrivingExt.INTERACT_REPAIR = 2
VehicleDrivingExt.INTERACT_DRIVE = 3
VehicleDrivingExt.INTERACT_TRUNK = 4
VehicleDrivingExt.STATE_INVALID = "invalid"
VehicleDrivingExt.STATE_INACTIVE = "inactive"
VehicleDrivingExt.STATE_PARKED = "parked"
VehicleDrivingExt.STATE_DRIVING = "driving"
VehicleDrivingExt.STATE_BROKEN = "broken"
VehicleDrivingExt.STATE_LOCKED = "locked"
VehicleDrivingExt.STATE_SECURED = "secured"
VehicleDrivingExt.STATE_FROZEN = "frozen"
VehicleDrivingExt.STATE_BLOCKED = "blocked"
VehicleDrivingExt.TIME_ENTER = 0.15
VehicleDrivingExt.TIME_REPAIR = 5
VehicleDrivingExt.INTERACT_ENTRY_ENABLED = "state_vis_icon_entry_enabled"
VehicleDrivingExt.INTERACT_ENTRY_DISABLED = "state_vis_icon_entry_disabled"
VehicleDrivingExt.INTERACT_LOOT_ENABLED = "state_vis_icon_loot_enabled"
VehicleDrivingExt.INTERACT_LOOT_DISABLED = "state_vis_icon_loot_disabled"
VehicleDrivingExt.INTERACT_REPAIR_ENABLED = "state_vis_icon_repair_enabled"
VehicleDrivingExt.INTERACT_REPAIR_DISABLED = "state_vis_icon_repair_disabled"
VehicleDrivingExt.INTERACT_INTERACTION_ENABLED = "state_interaction_enabled"
VehicleDrivingExt.INTERACT_INTERACTION_DISABLED = "state_interaction_disabled"
VehicleDrivingExt.SEQUENCE_HALF_DAMAGED = "int_seq_med_damaged"
VehicleDrivingExt.SEQUENCE_FULL_DAMAGED = "int_seq_full_damaged"
VehicleDrivingExt.SEQUENCE_REPAIRED = "int_seq_repaired"
VehicleDrivingExt.SEQUENCE_TRUNK_OPEN = "anim_trunk_open"
VehicleDrivingExt.SEQUENCE_TRUNK_CLOSE = "anim_trunk_close"
VehicleDrivingExt.cumulative_dt = 0
VehicleDrivingExt.cumulative_gravity = 0
VehicleDrivingExt.PLAYER_CAPSULE_OFFSET = Vector3(0, 0, -150)
VehicleDrivingExt.SPECIAL_OBJECTIVE_TYPE_DRIVING = "special_objective_type_driving"
VehicleDrivingExt.SPECIAL_LOOT_GERMAN_SPY_CARRY_ID = "german_spy"

-- Lines 66-149
function VehicleDrivingExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("vehicle_driving"), true)

	self._vehicle = self._unit:vehicle()

	if self._vehicle == nil then
		print("[DRIVING] unit doesn't contain a vehicle")
	end

	self._vehicle_view = self._unit:get_object(Idstring("v_driver"))

	if self._vehicle_view == nil then
		print("[DRIVING] vehicle doesn't contain driver view point")
	end

	self._drop_time_delay = nil
	self._last_synced_position = Vector3(0, 0, 0)
	self._shooting_stance_allowed = true
	self._position_counter = 0
	self._position_dt = 0
	self._positions = {}
	self._could_not_move = false
	self._last_input_fwd_dt = 0
	self._last_input_bwd_dt = 0
	self._last_sync_t = 0
	self._pos_reservation_id = nil
	self._pos_reservation = nil
	self.inertia_modifier = self.inertia_modifier or 1
	self._old_speed = Vector3(0, 0, 0)

	managers.vehicle:add_vehicle(self._unit)
	self._unit:set_body_collision_callback(callback(self, self, "collision_callback"))
	self:set_tweak_data(tweak_data.vehicle[self.tweak_data])

	self._interaction_allowed = true

	self:_setup_states()
	self:set_state(VehicleDrivingExt.STATE_INACTIVE, true)

	self._interaction_enter_vehicle = true
	self._interaction_trunk = true
	self._interaction_loot = false
	self._interaction_repair = false
	self._trunk_open = false
	self._has_trunk = self._unit:damage():has_sequence(VehicleDrivingExt.SEQUENCE_TRUNK_OPEN)

	if not self._has_trunk then
		self._interaction_loot = true
	end

	self:enable_loot_interaction()
	self:enable_accepting_loot()
	self:_setup_sound()

	self._loot = {}
	self.hud_label_offset = self._tweak_data.hud_label_offset or self._unit:oobb():size().z
end

-- Lines 151-193
function VehicleDrivingExt:_setup_sound()
	self._playing_slip_sound_dt = 0
	self._playing_reverse_sound_dt = 0
	self._playing_engine_sound = false
	self._hit_soundsource = SoundDevice:create_source("vehicle_hit")
	self._slip_soundsource = SoundDevice:create_source("vehicle_slip")

	if self._tweak_data.sound.slip_locator then
		self._slip_soundsource:link(self._unit:get_object(Idstring(self._tweak_data.sound.slip_locator)))
	else
		debug_pause("[VehicleDrivingExt][init] Slip sound source locator not specified for the vehicle:  ", inspect(self._unit))
	end

	self._bump_soundsource = SoundDevice:create_source("vehicle_bump")

	if self._tweak_data.sound.bump_locator then
		self._bump_soundsource:link(self._unit:get_object(Idstring(self._tweak_data.sound.bump_locator)))
	else
		debug_pause("[VehicleDrivingExt][init] Bump sound source locator not specified for the vehicle:  ", inspect(self._unit))
	end

	self._bump_soundsource:link(self._unit:get_object(Idstring(self._tweak_data.sound.bump_locator)))

	self._door_soundsource = SoundDevice:create_source("vehicle_door")

	self._door_soundsource:link(self._unit:get_object(Idstring("v_driver")))

	self._engine_soundsource = nil
	local snd_engine = self._unit:get_object(Idstring("snd_engine"))

	if snd_engine then
		self._engine_soundsource = SoundDevice:create_source("vehicle_engine")

		self._engine_soundsource:link(snd_engine)
	end

	self._wheel_jounce = {}
	self._reverse_sound = self._tweak_data.sound.going_reverse
	self._reverse_sound_stop = self._tweak_data.sound.going_reverse_stop
	self._slip_sound = self._tweak_data.sound.slip
	self._slip_sound_stop = self._tweak_data.sound.slip_stop
	self._bump_sound = self._tweak_data.sound.bump
	self._bump_rtpc = self._tweak_data.sound.bump_rtpc
	self._hit_sound = self._tweak_data.sound.hit
	self._hit_rtpc = self._tweak_data.sound.hit_rtpc
	self._hit_enemy = self._tweak_data.sound.hit_enemy
end

-- Lines 195-208
function VehicleDrivingExt:_setup_states()
	local unit = self._unit
	self._states = {
		broken = VehicleStateBroken:new(unit),
		driving = VehicleStateDriving:new(unit),
		inactive = VehicleStateInactive:new(unit),
		invalid = VehicleStateInvalid:new(unit),
		locked = VehicleStateLocked:new(unit),
		parked = VehicleStateParked:new(unit),
		secured = VehicleStateSecured:new(unit),
		frozen = VehicleStateFrozen:new(unit),
		blocked = VehicleStateBlocked:new(unit)
	}
end

-- Lines 210-212
function VehicleDrivingExt:get_tweak_data()
	return self._tweak_data
end

-- Lines 214-270
function VehicleDrivingExt:set_tweak_data(data)
	self._tweak_data = data
	self._seats = deep_clone(self._tweak_data.seats)
	self._loot_points = deep_clone(self._tweak_data.loot_points)
	self._secure_loot = self._tweak_data.secure_loot

	for _, seat in pairs(self._seats) do
		seat.occupant = nil
		seat.object = self._unit:get_object(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat.name))
		seat.third_object = self._unit:get_object(Idstring(VehicleDrivingExt.THIRD_PREFIX .. seat.name))
		seat.SO_object = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))

		if not seat.SO_object then
			Application:error("[VehicleDrivingExt:set_tweak_data] No exit point for seat ", seat.name)
		end
	end

	for _, loot_point in pairs(self._loot_points) do
		loot_point.object = self._unit:get_object(Idstring(VehicleDrivingExt.LOOT_PREFIX .. loot_point.name))
	end

	if self._unit:character_damage() then
		self._unit:character_damage():set_tweak_data(data)
	end

	self._last_drop_position = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()

	if Network:is_server() and self._tweak_data.skins then
		for skin_name, skin in pairs(self._tweak_data.skins) do
			if not skin.sequence then
				Application:error("[VehicleDrivingExt][set_tweak_data] Vehicle skin without a sequence:  ", skin_name)

				break
			end

			if skin.dlc and managers.dlc:is_dlc_unlocked(skin.dlc) then
				if not self._unit:damage():has_sequence(skin.sequence) then
					Application:error("[VehicleDrivingExt][set_tweak_data] Vehicle doesn't have a sequence for the skin:  ", skin_name, inspect(skin))

					break
				end

				if managers.network and managers.network:session() then
					managers.network:session():send_to_peers_synched("sync_vehicle_skin", self._unit, skin.sequence)
				end

				self:set_skin(skin.sequence)

				break
			end
		end
	end
end

-- Lines 272-275
function VehicleDrivingExt:set_skin(skin_name)
	self._unit:damage():run_sequence_simple(skin_name)

	self._skin_sequence = skin_name
end

-- Lines 277-279
function VehicleDrivingExt:get_view()
	return self._vehicle_view
end

-- Lines 281-349
function VehicleDrivingExt:update(unit, t, dt)
	if Application:editor() and not Global.running_simulation then
		return
	end

	if not alive(self._unit) or not managers.vehicle:get_vehicle_from_key(self._unit:key()) then
		Application:debug("[VehicleDrivingExt:update] VEHICLE DEAD")

		return
	end

	self:_manage_position_reservation()

	if Network:is_server() then
		if self._vehicle:is_active() then
			self:drop_loot()
		end

		self:_catch_loot()
	end

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() then
			local ai_movement = seat.occupant:movement()

			ai_movement:set_position(seat.third_object:position())
			ai_movement:set_rotation(seat.third_object:rotation())
		end
	end

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() and seat.occupant:character_damage():is_downed() then
			self:evacuate_seat(seat)
		end
	end

	self._current_state:update(t, dt)
end

-- Lines 354-372
function VehicleDrivingExt:_manage_position_reservation()
	if not self._pos_reservation_id and managers.navigation and managers.navigation:is_data_ready() then
		self:_create_position_reservation()

		return
	end

	if self._pos_reservation then
		local pos = self._unit:position()
		local distance = mvector3.distance(pos, self._pos_reservation.position)

		if distance > 100 then
			self._pos_reservation.position = pos

			managers.navigation:move_pos_rsrv(self._pos_reservation)

			local nav_seg_id = managers.navigation:get_nav_seg_from_pos(pos, true)
			self.current_world_id = managers.navigation:get_world_for_nav_seg(nav_seg_id)
		end
	end
end

-- Lines 374-382
function VehicleDrivingExt:_create_position_reservation()
	self._pos_reservation_id = managers.navigation:get_pos_reservation_id()

	if self._pos_reservation_id then
		self._pos_reservation = {
			radius = 500,
			position = self._unit:position(),
			filter = self._pos_reservation_id
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)

		local nav_seg_id = managers.navigation:get_nav_seg_from_pos(self._unit:position(), true)
		self.current_world_id = managers.navigation:get_world_for_nav_seg(nav_seg_id)
	end
end

-- Lines 385-393
function VehicleDrivingExt:_delete_position_reservation()
	Application:trace("[VehicleDrivingExt][_delete_position_reservation] ")

	if self._pos_reservation then
		Application:trace("[VehicleDrivingExt][_delete_position_reservation] deleting position reservation")
		managers.navigation:unreserve_pos(self._pos_reservation)

		self._pos_reservation = nil
		self._pos_reservation_id = nil
	end
end

-- Lines 398-400
function VehicleDrivingExt:get_action_for_interaction(pos, locator)
	return self._current_state:get_action_for_interaction(pos, locator, self._tweak_data)
end

-- Lines 403-406
function VehicleDrivingExt:set_interaction_allowed(allowed)
	self._interaction_allowed = allowed

	self._current_state:adjust_interactions()
end

-- Lines 409-411
function VehicleDrivingExt:is_interaction_allowed()
	return self._interaction_allowed
end

-- Lines 414-430
function VehicleDrivingExt:is_interaction_enabled(action)
	if not self:is_interaction_allowed() then
		return false
	end

	local result = false

	if action == VehicleDrivingExt.INTERACT_ENTER or action == VehicleDrivingExt.INTERACT_DRIVE then
		result = self._interaction_enter_vehicle
	elseif action == VehicleDrivingExt.INTERACT_LOOT then
		result = self._interaction_loot and self:is_loot_interaction_enabled()
	elseif action == VehicleDrivingExt.INTERACT_REPAIR then
		result = self._interaction_repair
	elseif action == VehicleDrivingExt.INTERACT_TRUNK then
		result = self._interaction_trunk
	end

	return result
end

-- Lines 433-463
function VehicleDrivingExt:set_state(name, do_not_sync)
	if name == self._current_state_name or self._current_state_name == VehicleDrivingExt.STATE_SECURED then
		return
	end

	local exit_data = nil

	if self._current_state then
		exit_data = self._current_state:exit(self._state_data, name)
	end

	local new_state = self._states[name] or self._states[VehicleDrivingExt.STATE_PARKED]

	if new_state then
		self._current_state = new_state
		self._current_state_name = name
		self._state_enter_t = managers.player:player_timer():time()

		new_state:enter(self._state_data, exit_data)
	else
		Application:error("[VehicleDrivingExt:set_state()] Failed to set new state or use fallback state!", name, self._unit)
	end

	if not do_not_sync and managers.network and managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "state", self._unit, name, nil)
	end
end

-- Lines 465-467
function VehicleDrivingExt:get_state_name()
	return self._current_state_name
end

-- Lines 470-472
function VehicleDrivingExt:lock()
	self:set_state(VehicleDrivingExt.STATE_LOCKED)
end

-- Lines 475-481
function VehicleDrivingExt:unlock()
	if not self._vehicle:is_active() then
		self:set_state(VehicleDrivingExt.STATE_INACTIVE)
	else
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end
end

-- Lines 484-496
function VehicleDrivingExt:secure()
	local carry_ext = self._unit:carry_data()

	if Network:is_server() then
		local silent = false
		local carry_id = carry_ext:carry_id()
		local multiplier = carry_ext:multiplier()

		managers.loot:secure(carry_id, multiplier, silent)
	end

	self:set_state(VehicleDrivingExt.STATE_SECURED)
end

-- Lines 499-502
function VehicleDrivingExt:break_down()
	self._unit:character_damage():damage_mission(100000)
	self:set_state(VehicleDrivingExt.STATE_BROKEN)
end

-- Lines 506-508
function VehicleDrivingExt:damage(damage)
	self._unit:character_damage():damage_mission(damage)
end

-- Lines 511-517
function VehicleDrivingExt:activate()
	if self:num_players_inside() > 0 then
		self:set_state(VehicleDrivingExt.STATE_DRIVING)
	else
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end
end

-- Lines 520-522
function VehicleDrivingExt:deactivate()
	self:set_state(VehicleDrivingExt.STATE_FROZEN)
end

-- Lines 524-526
function VehicleDrivingExt:block()
	self:set_state(VehicleDrivingExt.STATE_BLOCKED)
end

-- Lines 531-563
function VehicleDrivingExt:add_loot(carry_id, multiplier)
	Application:debug("[VehicleDrivingExt:add_loot] START:", carry_id, multiplier)

	if not carry_id or carry_id == "" then
		return false
	end

	if self._tweak_data.max_loot_bags <= #self._loot then
		return false
	end

	table.insert(self._loot, {
		carry_id = carry_id,
		multiplier = multiplier
	})
	managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, true, #self._loot)

	local carry_tweak_data = tweak_data.carry[carry_id]
	self._max_loot = carry_tweak_data.is_corpse and 1 or self._tweak_data.max_loot_bags

	managers.hud:set_vehicle_loot_info(self._unit, self._loot, #self._loot, self._max_loot)

	local bag_type_seq = "action_add_bag_" .. carry_id

	if self._unit:damage():has_sequence(bag_type_seq) then
		self._unit:damage():run_sequence_simple(bag_type_seq)
	elseif self._unit:damage():has_sequence("action_add_bag") then
		self._unit:damage():run_sequence_simple("action_add_bag")
	end

	if self._secure_loot then
		Application:trace("[VehicleDrivingExt:add_loot] secure the loot", carry_id, multiplier)

		local silent = self._secure_loot == "secure_silent"

		managers.loot:secure(carry_id, multiplier, silent)
	end
end

-- Lines 565-586
function VehicleDrivingExt:sync_loot(carry_id, multiplier)
	if not carry_id or carry_id == "" then
		return false
	end

	table.insert(self._loot, {
		carry_id = carry_id,
		multiplier = multiplier
	})
	managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, true, #self._loot)

	local carry_tweak_data = tweak_data.carry[carry_id]
	self._max_loot = carry_tweak_data.is_corpse and 1 or self._tweak_data.max_loot_bags

	managers.hud:set_vehicle_loot_info(self._unit, self._loot, #self._loot, self._max_loot)

	local count = #self._loot
	local bag_type_seq_carry = "int_seq_sync_slot_" .. count .. "_" .. carry_id
	local bag_type_seq = "int_seq_sync_slot_" .. count

	if self._unit:damage():has_sequence(bag_type_seq_carry) then
		self._unit:damage():run_sequence_simple(bag_type_seq_carry)
	elseif self._unit:damage():has_sequence(bag_type_seq) then
		self._unit:damage():run_sequence_simple(bag_type_seq)
	end
end

-- Lines 589-621
function VehicleDrivingExt:remove_loot(carry_id, multiplier)
	if not carry_id or carry_id == "" then
		Application:error("[VehicleDrivingExt] Trying to remove loot without a carry ID!")

		return false
	end

	for i = #self._loot, 1, -1 do
		local loot = self._loot[i]

		if loot.carry_id == carry_id and loot.multiplier == multiplier then
			table.remove(self._loot, i)

			local bag_type_seq = "action_remove_bag_" .. carry_id

			if self._unit:damage():has_sequence(bag_type_seq) then
				self._unit:damage():run_sequence_simple(bag_type_seq)
			elseif self._unit:damage():has_sequence("action_remove_bag") then
				self._unit:damage():run_sequence_simple("action_remove_bag")
			end

			local display_bag = true

			if #self._loot == 0 then
				display_bag = false
			end

			managers.hud:set_vehicle_label_carry_info(self._unit:unit_data().name_label_id, display_bag, #self._loot)

			local carry_tweak_data = tweak_data.carry[carry_id]
			self._max_loot = carry_tweak_data.is_corpse and 1 or self._tweak_data.max_loot_bags

			managers.hud:set_vehicle_loot_info(self._unit, self._loot, #self._loot, self._max_loot)

			return true
		end
	end

	return false
end

-- Lines 624-627
function VehicleDrivingExt:get_random_loot()
	local entry = math.random(#self._loot)

	return entry
end

-- Lines 629-631
function VehicleDrivingExt:get_loot()
	return self._loot
end

-- Lines 633-636
function VehicleDrivingExt:get_current_loot_amount()
	local entry = #self._loot

	return entry
end

-- Lines 638-647
function VehicleDrivingExt:get_carry_id_loot_amount(carry_id)
	local count = 0

	for i = #self._loot, 1, -1 do
		local loot = self._loot[i]

		if loot.carry_id == carry_id then
			count = count + 1
		end
	end

	return count
end

-- Lines 649-658
function VehicleDrivingExt:get_carry_id_loot(carry_id)
	local loots = {}

	for i = 1, #self._loot do
		local loot = self._loot[i]

		if loot.carry_id == carry_id then
			table.insert(loots, loot)
		end
	end

	return loots
end

-- Lines 660-662
function VehicleDrivingExt:get_max_loot()
	return self._max_loot or self._tweak_data.max_loot_bags
end

-- Lines 664-669
function VehicleDrivingExt:has_loot_stored()
	if self._loot and #self._loot > 0 then
		return true
	end

	return false
end

-- Lines 671-678
function VehicleDrivingExt:give_vehicle_loot_to_player(peer_id)
	if Network:is_server() then
		self:server_give_vehicle_loot_to_player(peer_id)
	else
		managers.network:session():send_to_host("server_give_vehicle_loot_to_player", self._unit, peer_id)
	end
end

-- Lines 681-693
function VehicleDrivingExt:server_give_vehicle_loot_to_player(peer_id)
	local loot_index = self:get_good_carry_item()

	if not loot_index then
		Application:debug("[VehicleDrivingExt:server_give_vehicle_loot_to_player] No good carry item gotten!")

		return
	end

	local loot = self:get_loot()[loot_index]

	if loot then
		managers.network:session():send_to_peers_synched("sync_give_vehicle_loot_to_player", self._unit, loot.carry_id, loot.multiplier, peer_id)
		self:sync_give_vehicle_loot_to_player(loot.carry_id, loot.multiplier, peer_id)
	end
end

-- Lines 696-703
function VehicleDrivingExt:get_good_carry_item()
	for idx, carry_item in ipairs(self:get_loot()) do
		if managers.player:local_can_carry(carry_item.carry_id) then
			return idx
		end
	end

	return 0
end

-- Lines 706-722
function VehicleDrivingExt:sync_give_vehicle_loot_to_player(carry_id, multiplier, peer_id)
	if not self:remove_loot(carry_id, multiplier) then
		Application:error("[VehicleDrivingExt] Trying to remove loot that is not in the vehicle: ", carry_id)

		return
	end

	if peer_id == managers.network:session():local_peer():id() then
		managers.player:add_carry(carry_id, multiplier, true, false, 1)
	end

	if self._unit:carry_align() then
		self._unit:carry_align():client_remove_carry(carry_id)
	end
end

-- Lines 725-751
function VehicleDrivingExt:drop_loot()
	if not self:_should_drop_loot() then
		return
	end

	local loot_index = self:get_good_carry_item()

	if not loot_index then
		Application:debug("[VehicleDrivingExt:drop_loot] No good carry item gotten!")

		return
	end

	local loot = self:get_loot()[loot_index]

	if loot then
		local pos = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()
		local velocity = self._vehicle:velocity()

		mvector3.normalize(velocity)
		mvector3.multiply(velocity, -300)

		local drop_point = pos + velocity

		Application:debug("dropping loot    " .. inspect(self._unit:position()) .. "      " .. inspect(drop_point))

		local rot = self._unit:rotation()
		local dir = Vector3(0, 0, 0)

		managers.player:server_drop_carry(loot.carry_id, loot.multiplier, drop_point, rot, dir, 0, nil, nil)
	end
end

-- Lines 754-756
function VehicleDrivingExt:_should_drop_loot()
	return false
end

-- Lines 759-770
function VehicleDrivingExt:_store_loot(unit)
	if self._tweak_data and self._tweak_data.max_loot_bags <= #self._loot then
		return
	end

	if Network:is_server() then
		self:server_store_loot_in_vehicle(unit)
	else
		managers.network:session():send_to_host("server_store_loot_in_vehicle", self._unit, unit)
	end
end

-- Lines 773-788
function VehicleDrivingExt:server_store_loot_in_vehicle(unit)
	Application:trace("VehicleDrivingExt:server_store_loot_in_vehicle")

	if self._unit:carry_align() then
		self._unit:carry_align():server_store_carry(unit)
	end

	local carry_ext = unit:carry_data()
	local carry_id = carry_ext:carry_id()
	local multiplier = carry_ext:multiplier()

	managers.network:session():send_to_peers_synched("sync_store_loot_in_vehicle", self._unit, unit, carry_id, multiplier)
	self:sync_store_loot_in_vehicle(unit, carry_id, multiplier)
end

-- Lines 791-801
function VehicleDrivingExt:sync_store_loot_in_vehicle(unit, carry_id, multiplier)
	Application:trace("VehicleDrivingExt:sync_store_loot_in_vehicle", carry_id)

	if alive(unit) then
		local carry_ext = unit:carry_data()

		carry_ext:disarm()
		carry_ext:set_value(0)
		unit:set_slot(0)
	end

	self:add_loot(carry_id, multiplier)
end

-- Lines 803-815
function VehicleDrivingExt:_loot_filter_func(carry_data)
	local carry_id = carry_data:carry_id()

	if self._tweak_data.loot_filter and not not self._tweak_data.loot_filter[carry_id] then
		return self._tweak_data.loot_filter[carry_id]
	end

	local carry_data = tweak_data.carry[carry_id]
	local carry_id_allowed = not self._tweak_data.allow_only_filtered and (carry_data.is_unique_loot or carry_data.loot_value or carry_data.loot_outlaw_value)

	return carry_id_allowed
end

-- Lines 818-844
function VehicleDrivingExt:_catch_loot()
	if not self:is_accepting_loot_enabled() then
		return
	end

	if self._tweak_data and self._tweak_data.max_loot_bags <= #self._loot or not self._interaction_loot then
		return false
	end

	for _, loot_point in pairs(self._loot_points) do
		if loot_point.object then
			local pos = loot_point.object:position()
			local equipement = World:find_units_quick("sphere", pos, 150, 14)

			for _, unit in ipairs(equipement) do
				local carry_data = unit:carry_data()

				if carry_data and carry_data:can_secure() and self:_loot_filter_func(carry_data) then
					self:_store_loot(unit)

					break
				end
			end
		end
	end
end

-- Lines 847-861
function VehicleDrivingExt:get_nearest_loot_point(pos)
	local nearest_loot_point = nil
	local min_distance = 1e+20

	for name, loot_point in pairs(self._loot_points) do
		if loot_point.object then
			local loot_point_pos = loot_point.object:position()
			local distance = mvector3.distance(loot_point_pos, pos)

			if distance < min_distance then
				min_distance = distance
				nearest_loot_point = loot_point
			end
		end
	end

	return nearest_loot_point, min_distance
end

-- Lines 864-874
function VehicleDrivingExt:loot_contains_german_spy()
	if self._loot then
		for _, loot_data in pairs(self._loot) do
			if loot_data.carry_id == VehicleDrivingExt.SPECIAL_LOOT_GERMAN_SPY_CARRY_ID then
				return true
			end
		end
	end

	return false
end

-- Lines 877-882
function VehicleDrivingExt:interact_trunk()
	local vehicle = self._unit
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_vehicle_interact_trunk", vehicle, peer_id)
	self:_interact_trunk(vehicle)
end

-- Lines 885-904
function VehicleDrivingExt:_interact_trunk(vehicle)
	local driving_ext = vehicle:vehicle_driving()

	if driving_ext._trunk_open then
		vehicle:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_TRUNK_CLOSE)

		driving_ext._trunk_open = false
		driving_ext._interaction_loot = false
	else
		vehicle:damage():run_sequence_simple(VehicleDrivingExt.SEQUENCE_TRUNK_OPEN)

		driving_ext._trunk_open = true
		driving_ext._interaction_loot = true
	end
end

-- Lines 908-916
function VehicleDrivingExt:enable_loot_interaction()
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_loot_enabled", self._unit, true)
	end

	self._loot_interaction_enabled = true
end

-- Lines 921-929
function VehicleDrivingExt:disable_loot_interaction()
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_loot_enabled", self._unit, false)
	end

	self._loot_interaction_enabled = false
end

-- Lines 933-935
function VehicleDrivingExt:is_loot_interaction_enabled()
	return self._loot_interaction_enabled and not self._secure_loot
end

-- Lines 939-947
function VehicleDrivingExt:enable_accepting_loot()
	Application:trace("[VehicleDrivingExt][enable_accepting_loot] Accepting loot enabled")

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_accepting_loot", self._unit, true)
	end

	self._accepting_loot_enabled = true
end

-- Lines 951-959
function VehicleDrivingExt:disable_accepting_loot()
	Application:trace("[VehicleDrivingExt][enable_accepting_loot] Accepting loot disabled")

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_vehicle_accepting_loot", self._unit, false)
	end

	self._accepting_loot_enabled = false
end

-- Lines 963-965
function VehicleDrivingExt:is_accepting_loot_enabled()
	return self._accepting_loot_enabled
end

-- Lines 969-974
function VehicleDrivingExt:enter_vehicle(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end
end

-- Lines 976-982
function VehicleDrivingExt:is_player_in_vehicle()
	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() == nil then
			return true
		end
	end
end

-- Lines 984-1027
function VehicleDrivingExt:reserve_seat(player, position, seat_name)
	local seat = nil

	if position then
		seat = self:get_available_seat(position)
	else
		for _, s in pairs(self._seats) do
			if s.name == seat_name then
				seat = s
			end
		end

		if alive(seat.occupant) and seat.occupant:brain() == nil then
			seat = self:get_available_seat(player:position())
		end
	end

	if seat == nil then
		return nil
	end

	if alive(seat.occupant) and seat.occupant:brain() then
		seat.previous_occupant = seat.occupant
	end

	seat.occupant = player

	if seat.drive_SO_data then
		local SO_data = seat.drive_SO_data
		seat.drive_SO_data = nil

		if SO_data.SO_registered then
			managers.groupai:state():remove_special_objective(SO_data.SO_id)
		end

		if alive(SO_data.unit) then
			SO_data.unit:brain():set_objective(nil)
		end
	end

	return seat
end

-- Lines 1030-1088
function VehicleDrivingExt:place_player_on_seat(player, seat_name, move, previous_seat)
	local number_of_seats = 0

	for _, seat in pairs(self._seats) do
		number_of_seats = number_of_seats + 1

		if seat.name == seat_name then
			if not move and seat.occupant and seat.occupant ~= player then
				local empty_seat = self:find_empty_seat()
				local ps = previous_seat or empty_seat

				if alive(seat.occupant) then
					self:_move_ai_to_seat(seat, ps, seat.occupant)
				end
			end

			if player == managers.player:local_player() then
				self:_activate_seat_sound_environment(seat, previous_seat)
			end

			seat.occupant = player

			if not move then
				self._door_soundsource:set_position(seat.object:position())
				self._door_soundsource:post_event(self._tweak_data.sound.door_close)

				local count = self:_number_in_the_vehicle()

				if count == 1 and self._current_state_name == VehicleDrivingExt.STATE_INACTIVE then
					local dialog = seat == self._seats.driver and "gen_vehicle_player_in_driver_position" or "gen_vehicle_player_in_passenger_position"

					managers.dialog:queue_dialog(dialog, {
						skip_idle_check = true,
						instigator = player
					})
				end

				if count == 1 and self._current_state_name ~= VehicleDrivingExt.STATE_BROKEN and self._current_state_name ~= VehicleDrivingExt.STATE_BLOCKED then
					self:start(player)
				end
			end

			self:_chk_register_drive_SO()

			if alive(self._seats.driver.occupant) and (self._current_state_name == VehicleDrivingExt.STATE_INACTIVE or self._current_state_name == VehicleDrivingExt.STATE_PARKED) then
				self:set_state(VehicleDrivingExt.STATE_DRIVING)
			end
		end
	end

	if number_of_seats == self:_number_in_the_vehicle() then
		self._interaction_enter_vehicle = false

		managers.dialog:queue_dialog("gen_vehicle_good_to_go", {
			skip_idle_check = true
		})
	end

	if self:num_players_inside() > 0 then
		local attention_setting_name = "vehicle_enemy_cbt"
		local attention_desc = tweak_data.attention.settings[attention_setting_name]
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, attention_desc, attention_setting_name)

		self._unit:attention():set_attention(attention_setting, nil)
		self._unit:attention():set_team(player:movement():team())
	end
end

-- Lines 1094-1111
function VehicleDrivingExt:_activate_seat_sound_environment(seat, previous_seat)
	local sound_source = self._unit:sound_source()
	local same_environment = previous_seat and seat.sound_environment_start and previous_seat.sound_environment_start and seat.sound_environment_start == previous_seat.sound_environment_start
	local play_environment_end = previous_seat and previous_seat.sound_environment_end and not same_environment

	if play_environment_end then
		Application:trace("[VehicleDrivingExt][_activate_seat_sound_environment] Stopping sound environment for the previous seat, playing: ", previous_seat.sound_environment_end)
		sound_source:post_event(previous_seat.sound_environment_end)
	end

	if seat.sound_environment_start and (not previous_seat or not same_environment) then
		Application:trace("[VehicleDrivingExt][_activate_seat_sound_environment] Starting sound environment for the new seat playing: ", seat.sound_environment_start)
		sound_source:post_event(seat.sound_environment_start)
	end
end

-- Lines 1115-1122
function VehicleDrivingExt:_stop_seat_sound_environment()
	local seat = self:find_seat_for_player(managers.player:local_player())

	if seat and seat.sound_environment_end then
		Application:trace("[VehicleDrivingExt][_stop_seat_sound_environment] Starting sound environment for the new seat playing: ", seat.sound_environment_start)

		local sound_source = self._unit:sound_source()

		sound_source:post_event(seat.sound_environment_end)
	end
end

-- Lines 1125-1139
function VehicleDrivingExt:move_player_to_seat(player, new_player_seat, previous_seat, previous_occupant)
	if previous_occupant then
		self:_move_ai_to_seat(new_player_seat, previous_seat, previous_occupant)
	elseif previous_seat then
		previous_seat.occupant = nil
	end

	local move = previous_seat ~= nil or previous_occupant ~= nil

	self:place_player_on_seat(player, new_player_seat.name, move, previous_seat)

	new_player_seat.previous_occupant = nil

	if previous_seat.driving then
		self:set_input(0, 0, 0, 0, false, false)
	end

	managers.hud:player_changed_vehicle_seat()
end

-- Lines 1141-1147
function VehicleDrivingExt:find_empty_seat()
	for name, seat in pairs(self._seats) do
		if not seat.occupant then
			return seat
		end
	end
end

-- Lines 1150-1178
function VehicleDrivingExt:_move_ai_to_seat(from_seat, to_seat, previous_occupant)
	local ai_unit = previous_occupant

	ai_unit:unlink()

	from_seat.occupant = nil
	local ai_movement = ai_unit:movement()
	ai_unit:movement().vehicle_seat = to_seat

	if to_seat then
		to_seat.occupant = ai_unit

		ai_movement:set_position(to_seat.third_object:position())
		ai_movement:set_rotation(to_seat.third_object:rotation())

		ai_movement.vehicle_unit = self._unit
		ai_movement.vehicle_seat = to_seat

		ai_movement.vehicle_unit:link(Idstring(VehicleDrivingExt.THIRD_PREFIX .. ai_movement.vehicle_seat.name), ai_unit, ai_unit:orientation_object():name())

		local team_ai_animation = self._tweak_data.animations[to_seat.name]

		if self:shooting_stance_mandatory() and to_seat.shooting_pos and to_seat.has_shooting_mode then
			team_ai_animation = team_ai_animation .. "_shooting"
		end

		ai_unit:movement():play_redirect(team_ai_animation, 0)
	end
end

-- Lines 1181-1183
function VehicleDrivingExt:allow_exit()
	return self._current_state:allow_exit()
end

-- Lines 1185-1187
function VehicleDrivingExt:kick()
	managers.player:set_player_state("standard")
end

-- Lines 1191-1217
function VehicleDrivingExt:exit_vehicle(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end

	self:_stop_seat_sound_environment()

	seat.occupant = nil
	self._interaction_enter_vehicle = true

	if not alive(self._seats.driver.occupant) and self._current_state_name ~= VehicleDrivingExt.STATE_BROKEN and self._current_state_name ~= VehicleDrivingExt.STATE_LOCKED and self._current_state_name ~= VehicleDrivingExt.STATE_BLOCKED then
		self:set_state(VehicleDrivingExt.STATE_PARKED)
	end

	local count = self:_number_in_the_vehicle()

	if count == 0 then
		self:_evacuate_vehicle()
	end
end

-- Lines 1220-1230
function VehicleDrivingExt:_evacuate_vehicle()
	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() then
			self:evacuate_seat(seat)
		end
	end

	self:_unregister_drive_SO()
	self._unit:attention():set_attention(nil, nil)
end

-- Lines 1232-1254
function VehicleDrivingExt:evacuate_seat(seat)
	seat.occupant:unlink()

	seat.occupant:movement().vehicle_unit = nil
	seat.occupant:movement().vehicle_seat = nil

	if seat.occupant:character_damage():dead() then
		-- Nothing
	elseif Network:is_server() then
		seat.occupant:movement():action_request({
			sync = true,
			body_part = 1,
			type = "idle"
		})
	end

	local rot = seat.SO_object:rotation()
	local pos = seat.SO_object:position()

	seat.occupant:movement():set_rotation(rot)
	seat.occupant:movement():set_position(pos)

	seat.occupant = nil
end

-- Lines 1257-1311
function VehicleDrivingExt:find_exit_position(player)
	local seat = self:find_seat_for_player(player)
	local exit_position = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))
	local result = {
		position = exit_position:position(),
		rotation = exit_position:rotation()
	}
	local rot = self._vehicle:rotation()
	local offset = Vector3(0, 0, 100)

	mvector3.rotate_with(offset, rot)

	local found_exit = true
	local slot_mask = World:make_slot_mask(1, 11, 39)
	local ray = World:raycast("ray_type", "body bag mover", "ray", player:position() + offset, exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask, "ignore_unit", self._unit)

	if ray and ray.unit then
		found_exit = false

		for _, seat in pairs(self._tweak_data.seats) do
			local seat_exit_position = self._unit:get_object(Idstring(VehicleDrivingExt.EXIT_PREFIX .. seat.name))
			ray = World:raycast("ray_type", "body bag mover", "ray", player:position() + offset, seat_exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask, "ignore_unit", self._unit)

			if not ray or not ray.unit then
				exit_position = seat_exit_position
				found_exit = true

				break
			end
		end

		if not found_exit then
			local i_alt = 1
			local alt_exit_position = self._unit:get_object(Idstring("v_exit_alternate_" .. i_alt))

			while alt_exit_position do
				ray = World:raycast("ray_type", "body bag mover", "ray", player:position() + offset, alt_exit_position:position() + offset, "sphere_cast_radius", 35, "slot_mask", slot_mask, "ignore_unit", self._unit)

				if not ray or not ray.unit then
					exit_position = alt_exit_position
					found_exit = true

					break
				end

				i_alt = i_alt + 1
				alt_exit_position = self._unit:get_object(Idstring("v_exit_alternate_" .. i_alt))
			end
		end

		result = {
			position = exit_position:position(),
			rotation = exit_position:rotation()
		}
	end

	if not found_exit then
		Application:error("[VehicleDrivingExt]  find_exit_position - no exit position")

		result.position = result.position + Vector3(0, 0, 100)

		return nil
	end

	return result
end

-- Lines 1314-1323
function VehicleDrivingExt:get_object_placement(player)
	local seat = self:find_seat_for_player(player)

	if seat then
		local obj_pos = self._vehicle:object_position(seat.object)
		local obj_rot = self._vehicle:object_rotation(seat.object)

		return obj_pos, obj_rot
	end

	print("[VehicleDrivingExt:get_object_placement] Seat not found for player!")

	return nil, nil
end

-- Lines 1327-1366
function VehicleDrivingExt:get_available_seat(position)
	local nearest_seat = nil
	local min_distance = 1e+20
	local min_seat_distance = 1e+20

	for name, seat in pairs(self._seats) do
		local object = self._unit:get_object(Idstring(VehicleDrivingExt.INTERACTION_PREFIX .. seat.name))

		if object ~= nil then
			local seat_pos = object:position()
			local distance = mvector3.distance(seat_pos, position)

			if distance < min_distance then
				min_distance = distance
			end

			if not alive(seat.occupant) and distance < min_seat_distance then
				nearest_seat = seat
				min_seat_distance = distance
			end
		end
	end

	if not nearest_seat then
		for name, seat in pairs(self._seats) do
			local object = self._unit:get_object(Idstring(VehicleDrivingExt.INTERACTION_PREFIX .. seat.name))

			if object ~= nil then
				local seat_pos = object:position()
				local distance = mvector3.distance(seat_pos, position)

				if distance < min_distance then
					min_distance = distance
				end

				if seat.occupant:brain() and distance < min_seat_distance then
					nearest_seat = seat
					min_seat_distance = distance
				end
			end
		end
	end

	return nearest_seat, min_distance
end

-- Lines 1368-1375
function VehicleDrivingExt:has_driving_seat()
	for _, seat in pairs(self._seats) do
		if seat.driving then
			return true
		end
	end

	return false
end

-- Lines 1377-1388
function VehicleDrivingExt:get_next_seat(player)
	local seat = self:find_seat_for_player(player)
	local next_seat = self._seats[seat.next_seat]

	while next_seat and next_seat ~= seat do
		if not next_seat.occupant or next_seat.occupant and next_seat.occupant:brain() then
			return next_seat
		end

		next_seat = self._seats[next_seat.next_seat]
	end

	return nil
end

-- Lines 1391-1399
function VehicleDrivingExt:find_seat_for_player(player)
	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant == player then
			return seat
		end
	end

	return nil
end

-- Lines 1401-1409
function VehicleDrivingExt:num_players_inside()
	local num_players = 0

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and not seat.occupant:brain() then
			num_players = num_players + 1
		end
	end

	return num_players
end

-- Lines 1411-1425
function VehicleDrivingExt:get_random_occupant(include_driver)
	local occupants = {}

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and (include_driver or seat.name ~= "driver") then
			table.insert(occupants, seat.occupant)
		end
	end

	if #occupants > 0 then
		return occupants[math.random(#occupants)]
	end

	return nil
end

-- Lines 1430-1489
function VehicleDrivingExt:on_team_ai_enter(ai_unit)
	local original_seat = ai_unit:movement().vehicle_seat
	local target_seat = original_seat

	if target_seat.occupant then
		if target_seat.occupant == ai_unit then
			return
		end

		target_seat = self:find_empty_seat()

		if not target_seat then
			Application:error("[VehicleDrivingExt][on_team_ai_enter] Team AI failed to enter the vehicle - all seats are taken. Target seat: ", ai_unit:movement().vehicle_seat.name)

			ai_unit:movement().vehicle_unit = nil
			ai_unit:movement().vehicle_seat = nil

			if Network:is_server() then
				ai_unit:movement():action_request({
					sync = true,
					body_part = 1,
					type = "idle"
				})
			end

			local rot = original_seat.SO_object:rotation()
			local pos = original_seat.SO_object:position()

			ai_unit:movement():set_rotation(rot)
			ai_unit:movement():set_position(pos)

			return
		end
	end

	self._unit:link(Idstring(VehicleDrivingExt.THIRD_PREFIX .. target_seat.name), ai_unit, ai_unit:orientation_object():name())

	target_seat.occupant = ai_unit

	managers.hud:ai_entered_vehicle(ai_unit, self._unit)
	Application:debug("VehicleDrivingExt:on_team_ai_enter")
	self._door_soundsource:set_position(target_seat.object:position())
	self._door_soundsource:post_event(self._tweak_data.sound.door_close)

	if target_seat ~= ai_unit:movement().vehicle_seat then
		local team_ai_animation = self._tweak_data.animations[target_seat.name]

		if self:shooting_stance_mandatory() and target_seat.shooting_pos and target_seat.has_shooting_mode then
			team_ai_animation = team_ai_animation .. "_shooting"
		end

		ai_unit:movement().vehicle_seat = target_seat

		ai_unit:movement():play_redirect(team_ai_animation, 0)
	end
end

-- Lines 1491-1493
function VehicleDrivingExt:seats()
	return self._seats
end

-- Lines 1495-1505
function VehicleDrivingExt:get_seat_data_by_seat_name(seat_name)
	if self._seats then
		for index, seat_data in pairs(self._seats) do
			if seat_data.name == seat_name then
				return seat_data
			end
		end

		return nil
	end

	return nil
end

-- Lines 1508-1514
function VehicleDrivingExt:sync_occupant(seat, occupant)
	self._unit:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat.name), occupant)

	if occupant:brain() then
		occupant:movement().vehicle_unit = self._unit
		occupant:movement().vehicle_seat = seat
	end
end

-- Lines 1518-1526
function VehicleDrivingExt:on_vehicle_death()
	self:set_state(VehicleDrivingExt.STATE_BROKEN)

	local occupant = self:get_random_occupant(true)

	if occupant then
		managers.dialog:queue_dialog("gen_vehicle_at_0_percent", {
			skip_idle_check = true,
			instigator = occupant
		})
	end
end

-- Lines 1529-1532
function VehicleDrivingExt:repair_vehicle(instigator)
	self._unit:character_damage():revive(instigator)
	self:set_state(VehicleDrivingExt.STATE_DRIVING)
end

-- Lines 1535-1537
function VehicleDrivingExt:is_vulnerable()
	return self._current_state:is_vulnerable()
end

-- Lines 1541-1547
function VehicleDrivingExt:start(player)
	self._unit:set_extension_update_enabled(Idstring("vehicle_driving"), true)
	self:_start(player)

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "start", self._unit, player)
	end
end

-- Lines 1550-1552
function VehicleDrivingExt:sync_start(player)
	self:_start(player)
end

-- Lines 1555-1561
function VehicleDrivingExt:_start(player)
	local seat = self:find_seat_for_player(player)

	if seat == nil then
		return
	end

	self:activate_vehicle()
end

-- Lines 1563-1572
function VehicleDrivingExt:activate_vehicle()
	if not self._vehicle:is_active() then
		self._unit:damage():run_sequence_simple("driving")
		self._vehicle:set_active(true)
		self:set_state(VehicleDrivingExt.STATE_DRIVING)
	end

	self._last_drop_position = self._unit:get_object(Idstring(self._tweak_data.loot_drop_point)):position()
	self._drop_time_delay = TimerManager:main():time()
end

-- Lines 1575-1580
function VehicleDrivingExt:stop()
	self:_stop()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_vehicle_driving", "stop", self._unit, nil)
	end
end

-- Lines 1583-1585
function VehicleDrivingExt:sync_stop()
	self:_stop()
end

-- Lines 1588-1596
function VehicleDrivingExt:_stop(do_not_sync_state)
	print("[DRIVING] VehicleDrivingExt: _stop()")
	self:stop_all_sound_events()
	self._unit:damage():run_sequence_simple("not_driving")
	self._vehicle:set_active(false)

	self._drop_time_delay = nil

	self:set_state(VehicleDrivingExt.STATE_INACTIVE, do_not_sync_state)
end

-- Lines 1599-1634
function VehicleDrivingExt:set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear, dt, y_axis)
	if self._current_state:stop_vehicle() then
		accelerate = 0
		steer = 0
		gear_up = false
		gear_down = false
		brake = 1
	elseif dt and y_axis > 0 then
		self._last_input_fwd_dt = self._last_input_fwd_dt + dt
	elseif dt and y_axis < 0 then
		self._last_input_bwd_dt = self._last_input_bwd_dt + dt
	end

	self:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)

	if managers.network:session() then
		local pos = self._vehicle:position()

		managers.network:session():send_to_peers_synched("sync_vehicle_set_input", self._unit, accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)

		local distance = mvector3.distance(self._last_synced_position, pos)
		local t = TimerManager:game():time()
		local sync_dt = t - self._last_sync_t

		if distance > 1 and tweak_data.network.driving.network_wait_delta_t < sync_dt then
			managers.network:session():send_to_peers_synched("sync_vehicle_state", self._unit, self._vehicle:position(), self._vehicle:rotation(), self._vehicle:velocity())

			self._last_synced_position = pos
			self._last_sync_t = t
		end
	end
end

-- Lines 1636-1638
function VehicleDrivingExt:sync_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
	self:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
end

-- Lines 1640-1642
function VehicleDrivingExt:sync_state(position, rotation, velocity)
	self._vehicle:adjust_vehicle_state(position, rotation, velocity)
end

-- Lines 1644-1646
function VehicleDrivingExt:sync_vehicle_state(new_state)
	self:set_state(new_state, true)
end

-- Lines 1648-1654
function VehicleDrivingExt:_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
	local gear_shift = 0

	if gear_up then
		gear_shift = 1
	end

	if gear_down then
		gear_shift = -1
	end

	self._vehicle:set_input(accelerate, steer, brake, handbrake, gear_shift, forced_gear)
end

-- Lines 1660-1676
function VehicleDrivingExt:_wake_nearby_dynamics()
	if not self:is_driving_fast() then
		return
	end

	local radius = 250
	local pos = self._vehicle:position() + self._vehicle:velocity() / 12
	local slotmask = World:make_slot_mask(1)
	local units = World:find_units_quick("sphere", pos, radius, slotmask)

	for _, unit in pairs(units) do
		if unit:damage() then
			unit:damage():has_then_run_sequence_simple("car_destructable")
		end
	end
end

-- Lines 1679-1686
function VehicleDrivingExt:_should_push(unit)
	for _, seat in pairs(self._seats) do
		if seat.occupant == unit or seat.drive_SO_data and seat.drive_SO_data.unit == unit then
			return false
		end
	end

	return true
end

-- Lines 1689-1692
function VehicleDrivingExt:is_driving_fast()
	local vel = self._vehicle:velocity()

	return vel:length() > 220
end

-- Lines 1694-1757
function VehicleDrivingExt:_detect_npc_collisions()
	if not self:is_driving_fast() then
		return
	end

	local oobb = self._unit:oobb()
	local slotmask = managers.slot:get_mask("flesh")
	local units = World:find_units("intersect", "obb", oobb:center(), oobb:x(), oobb:y(), oobb:z(), slotmask)

	for _, unit in pairs(units) do
		local unit_is_criminal = unit:in_slot(managers.slot:get_mask("all_criminals"))

		if unit_is_criminal then
			-- Nothing
		elseif unit:character_damage() and not unit:character_damage():dead() then
			local vel = self._vehicle:velocity()

			self._hit_soundsource:set_position(unit:position())
			self._hit_soundsource:set_rtpc(self._hit_rtpc, math.clamp(vel:length() / 100 * 2, 0, 100))
			self._hit_soundsource:post_event(self._hit_enemy)
			Application:trace("[VehicleDrivingExt][_detect_npc_collisions] SPLAT")

			local occupant = self:get_random_occupant(false)

			if occupant then
				managers.dialog:queue_dialog("gen_vehicle_hits_enemy", {
					skip_idle_check = true,
					instigator = occupant
				})
			end

			local damage_ext = unit:character_damage()
			local attack_data = {
				variant = "explosion",
				damage = damage_ext._HEALTH_INIT or 1000
			}

			if self._seats.driver.occupant == managers.player:local_player() then
				attack_data.attacker_unit = managers.player:local_player()
			end

			damage_ext:damage_mission(attack_data)

			if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
				unit:movement()._active_actions[1]:force_ragdoll()
			end

			local nr_u_bodies = unit:num_bodies()
			local i_u_body = 0

			while nr_u_bodies > i_u_body do
				local u_body = unit:body(i_u_body)

				if u_body:enabled() and u_body:dynamic() then
					local body_mass = u_body:mass()

					u_body:push_at(body_mass / math.random(2), vel * 2.5, u_body:position())
				end

				i_u_body = i_u_body + 1
			end

			if self._seats.driver.occupant == managers.player:local_player() then
				managers.statistics:add_to_killed_by_vehicle()
			end
		end
	end
end

-- Lines 1760-1795
function VehicleDrivingExt:_detect_collisions(t, dt)
	local current_speed = self._vehicle:velocity()

	if dt ~= 0 and self._vehicle:is_active() then
		local dv = self._old_speed - current_speed
		local gforce = math.abs(dv:length() / 100 / dt) / 9.81

		if gforce > 16 then
			local ray_from = self._seats.driver.object:position() + Vector3(0, 0, 100)
			local distance = mvector3.copy(self._old_speed)

			mvector3.normalize(distance)
			mvector3.multiply(distance, 300)

			local ray = World:raycast("ray", ray_from, ray_from + distance, "sphere_cast_radius", 75, "slot_mask", managers.slot:get_mask("world_geometry"))

			if ray and ray.unit then
				self:on_impact(ray, gforce, self._old_speed)
			elseif self._seats.passenger_front then
				ray_from = self._seats.passenger_front.object:position() + Vector3(0, 0, 100)
				ray = World:raycast("ray", ray_from, ray_from + distance, "sphere_cast_radius", 75, "slot_mask", managers.slot:get_mask("world_geometry"))

				if ray and ray.unit then
					self:on_impact(ray, gforce, self._old_speed)
				else
					self:on_impact(nil, gforce, self._old_speed)
				end
			end
		end
	end

	self._old_speed = current_speed
end

-- Lines 1798-1876
function VehicleDrivingExt:_detect_invalid_possition(t, dt)
	local respawn = false
	local rot = self._vehicle:rotation()

	if rot:z().z < 0.6 and not self._invalid_position_since then
		self._invalid_position_since = t
	elseif rot:z().z >= 0.6 and self._invalid_position_since then
		self._invalid_position_since = nil
	end

	local velocity = self._vehicle:velocity():length()

	if velocity < 10 and not self._stopped_since then
		self._stopped_since = t
	elseif velocity >= 10 and self._stopped_since then
		self._stopped_since = nil
	end

	if self._stopped_since and t - self._stopped_since > 0.2 and self._invalid_position_since and t - self._invalid_position_since > 0.2 then
		respawn = true
	end

	local state = self._vehicle:get_state()
	local speed = state:get_speed()
	local gear = state:get_gear()

	if self._current_state_name == VehicleDrivingExt.STATE_DRIVING then
		local condition = gear ~= 1 and velocity < 10 and speed < 0.5 and self._last_input_fwd_dt > 0.2 and self._last_input_bwd_dt > 0.2 and self._stopped_since and t - self._stopped_since > 0.5

		if condition then
			self._could_not_move = condition
		elseif speed > 0.5 then
			self._could_not_move = false
			self._last_input_bwd_dt = 0
			self._last_input_fwd_dt = 0
		end
	end

	self.respawn_available = respawn or self._could_not_move
	self._position_dt = self._position_dt + dt

	if self._position_dt > 1 then
		if not self.respawn_available and speed > 2 and rot:z().z >= 0.9 then
			if not self._positions[self._position_counter] then
				self._positions[self._position_counter] = {}
			end

			self._positions[self._position_counter].pos = self._vehicle:position()
			self._positions[self._position_counter].rot = self._vehicle:rotation()
			self._positions[self._position_counter].oobb = self._unit:oobb()
			self._position_counter = self._position_counter + 1

			if self._position_counter == 20 then
				self._position_counter = 0
				self._position_counter_turnover = true
			end
		end

		self._position_dt = 0
	end

	if self.respawn_available and not self._respawn_available_since then
		self._respawn_available_since = t
		local occupant = self:get_random_occupant(false)

		if occupant then
			managers.dialog:queue_dialog("gen_vehicle_rough_ride", {
				skip_idle_check = true,
				instigator = occupant
			})
		end
	elseif not self.respawn_available then
		self._respawn_available_since = nil
	end

	if self._respawn_available_since and t - self._respawn_available_since > 10 then
		self:respawn_vehicle(true)
	end
end

-- Lines 1878-1929
function VehicleDrivingExt:respawn_vehicle(auto_respawn)
	self.respawn_available = false

	if auto_respawn then
		-- Nothing
	end

	print("Respawning vehicle on last valid position")

	self._stopped_since = nil
	self._invalid_position_since = nil
	self._last_input_bwd_dt = 0
	self._last_input_fwd_dt = 0
	self._could_not_move = false
	local counter = self._position_counter - 4

	if counter < 0 then
		if self._position_counter_turnover then
			counter = 20 + counter
		else
			counter = 0
		end
	end

	self._position_counter = self._position_counter - 1

	if self._position_counter < 0 then
		if self._position_counter_turnover then
			self._position_counter = 20 + self._position_counter
		else
			self._position_counter = 0
		end
	end

	Application:debug("Using respawn position on the index:", counter)

	while counter >= 0 do
		if self._positions[counter] and self:_check_respawn_spot_valid(counter) then
			print("[VehicleDrivingExt:respawn_vehicle] respawning vehicle on position, counter", counter)
			self._vehicle:set_position(self._positions[counter].pos)
			self._vehicle:set_rotation(self._positions[counter].rot)

			break
		else
			Application:debug("[VehicleDrivingExt:respawn_vehicle] Trying to respawn vehicle on occupied position", counter)

			counter = counter - 1
		end
	end
end

-- Lines 1931-1940
function VehicleDrivingExt:_check_respawn_spot_valid(counter)
	local oobb = self._positions[counter].oobb
	local slotmask = managers.slot:get_mask("all")
	local units = World:find_units(self._unit, "intersect", "obb", oobb:center(), oobb:x() * 0.8, oobb:y() * 0.8, oobb:z() * 0.8, slotmask)

	if #units > 0 then
		return false
	else
		return true
	end
end

-- Lines 1945-2042
function VehicleDrivingExt:_play_sound_events(t, dt)
	local state = self._vehicle:get_state()
	local slip = false
	local bump = false
	local going_reverse = false
	local speed = state:get_speed() * 3.6

	for id, wheel_state in pairs(state:wheel_states()) do
		local current_jounce = wheel_state:jounce()
		local last_frame_jounce = self._wheel_jounce[id]

		if last_frame_jounce == nil then
			last_frame_jounce = 0
		end

		local dj = current_jounce - last_frame_jounce
		local jerk = dj / dt

		if self._tweak_data.sound.bump_treshold < jerk then
			bump = true
		end

		self._wheel_jounce[id] = current_jounce

		if self._tweak_data.sound.lateral_slip_treshold < math.abs(wheel_state:lat_slip()) then
			slip = true
		elseif self._tweak_data.sound.longitudal_slip_treshold < math.abs(wheel_state:long_slip()) and state:get_rpm() > 500 then
			slip = true
		end
	end

	if state:get_gear() == 0 and speed > 0.5 then
		going_reverse = true
	end

	if slip and self._slip_sound then
		if self._playing_slip_sound_dt == 0 then
			self._slip_soundsource:post_event(self._slip_sound)

			self._playing_slip_sound_dt = self._playing_slip_sound_dt + dt
		end
	elseif self._playing_slip_sound_dt > 0.1 then
		self._slip_soundsource:post_event(self._slip_sound_stop)

		self._playing_slip_sound_dt = 0
	end

	if self._playing_slip_sound_dt > 0 then
		self._playing_slip_sound_dt = self._playing_slip_sound_dt + dt
	end

	if going_reverse and self._reverse_sound then
		if self._playing_reverse_sound_dt == 0 then
			self._door_soundsource:post_event(self._reverse_sound)

			self._playing_reverse_sound_dt = self._playing_reverse_sound_dt + dt
		end
	elseif self._playing_reverse_sound_dt > 0.1 then
		self._door_soundsource:post_event(self._reverse_sound_stop)

		self._playing_reverse_sound_dt = 0
	end

	if self._playing_reverse_sound_dt > 0 then
		self._playing_reverse_sound_dt = self._playing_reverse_sound_dt + dt
	end

	if bump and self._bump_sound then
		self._bump_soundsource:set_rtpc(self._bump_rtpc, 2 * math.clamp(speed, 0, 100))
		self._bump_soundsource:post_event(self._bump_sound)

		local occupant = self:get_random_occupant(false)

		if occupant then
			managers.dialog:queue_dialog("gen_vehicle_rough_ride", {
				skip_idle_check = true,
				instigator = occupant
			})
		end
	end

	local current_gear = self._vehicle:get_state():get_gear()

	if not self._last_gear then
		self._last_gear = current_gear
	end

	if self._last_gear ~= 1 and current_gear ~= self._last_gear and self._tweak_data.sound.gear_shift then
		self._engine_soundsource:post_event(self._tweak_data.sound.gear_shift)
	end

	self._last_gear = current_gear

	self:_play_engine_sound(state)
end

-- Lines 2045-2063
function VehicleDrivingExt:_start_engine_sound()
	if not self._playing_engine_sound and self._engine_soundsource then
		self._playing_engine_sound = true

		if self._tweak_data.sound.engine_start then
			self._engine_soundsource:post_event(self._tweak_data.sound.engine_start)
		else
			Application:error("[Vehicle] No sound specified for engine_start")
		end

		if self._tweak_data.sound.engine_sound_event then
			self._engine_soundsource:post_event(self._tweak_data.sound.engine_sound_event)

			self._playing_engine_sound = true
		else
			Application:error("[Vehicle] No sound specified for engine_sound_event")
		end

		Application:trace("VehicleDrivingExt:_start_engine_sound() engine start: ", inspect(self._tweak_data.sound.engine_start))
		Application:trace("VehicleDrivingExt:_start_engine_sound(): engine sound event", inspect(self._tweak_data.sound.engine_start))
	end
end

-- Lines 2066-2075
function VehicleDrivingExt:_stop_engine_sound()
	if self._playing_engine_sound and self._engine_soundsource then
		if self._tweak_data.sound.engine_stop then
			self._engine_soundsource:post_event(self._tweak_data.sound.engine_stop)
		else
			self._engine_soundsource:stop()
		end

		self._playing_engine_sound = false
	end
end

-- Lines 2077-2082
function VehicleDrivingExt:_start_broken_engine_sound()
	if not self._playing_engine_sound and self._engine_soundsource and self._tweak_data.sound.broken_engine then
		self._engine_soundsource:post_event(self._tweak_data.sound.broken_engine)

		self._playing_engine_sound = true
	end
end

-- Lines 2084-2114
function VehicleDrivingExt:_play_engine_sound(state)
	local speed = state:get_speed() * 3.6
	local rpm = state:get_rpm()
	local max_speed = self._tweak_data.max_speed
	local max_rpm = self._vehicle:get_max_rpm()
	local relative_speed = speed / max_speed

	if relative_speed > 1 then
		relative_speed = 1
	end

	self._relative_rpm = rpm / max_rpm

	if self._relative_rpm > 1 then
		self._relative_rpm = 1
	end

	if self._engine_soundsource == nil then
		return
	end

	if not self._playing_engine_sound then
		return
	end

	local rpm_rtpc = math.round(self._relative_rpm * 100)
	local speed_rtpc = math.round(relative_speed * 100)

	self._engine_soundsource:set_rtpc(self._tweak_data.sound.engine_rpm_rtpc, rpm_rtpc)
	self._engine_soundsource:set_rtpc(self._tweak_data.sound.engine_speed_rtpc, speed_rtpc)
end

-- Lines 2117-2121
function VehicleDrivingExt:play_horn_sound()
	if self._tweak_data.sound.horn_start then
		self._unit:sound_source():post_event(self._tweak_data.sound.horn_start)
	end
end

-- Lines 2124-2128
function VehicleDrivingExt:stop_horn_sound()
	if self._tweak_data.sound.horn_stop then
		self._unit:sound_source():post_event(self._tweak_data.sound.horn_stop)
	end
end

-- Lines 2131-2139
function VehicleDrivingExt:stop_all_sound_events()
	self._hit_soundsource:stop()
	self._slip_soundsource:stop()
	self._bump_soundsource:stop()

	if self._engine_soundsource then
		self._engine_soundsource:stop()
	end

	self._playing_slip_sound_dt = 0
end

-- Lines 2143-2148
function VehicleDrivingExt:_unregister_drive_SO()
	for _, seat in pairs(self._seats) do
		self:_unregister_drive_SO_seat(seat)
	end
end

-- Lines 2150-2167
function VehicleDrivingExt:_unregister_drive_SO_seat(seat)
	if seat.drive_SO_data then
		local SO_data = seat.drive_SO_data
		seat.drive_SO_data = nil

		if SO_data.SO_registered then
			managers.groupai:state():remove_special_objective(SO_data.SO_id)
		end

		if alive(SO_data.unit) then
			SO_data.unit:brain():set_objective(nil)
		end
	end
end

-- Lines 2170-2189
function VehicleDrivingExt:_chk_register_drive_SO()
	if not Network:is_server() or not managers.navigation:is_data_ready() then
		return
	end

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and not seat.occupant:brain() then
			self:_unregister_drive_SO_seat(seat)
		elseif not seat.drive_SO_data then
			self:_create_seat_SO(seat)
		end
	end
end

-- Lines 2192-2280
function VehicleDrivingExt:_create_seat_SO(seat)
	if seat.drive_SO_data then
		return
	end

	local SO_filter = managers.groupai:state():get_unit_type_filter("criminal")
	local tracker_align = managers.navigation:create_nav_tracker(seat.SO_object:position(), false)
	local align_nav_seg = tracker_align:nav_segment()
	local align_pos = seat.SO_object:position()
	local align_rot = seat.SO_object:rotation()
	local align_area = managers.groupai:state():get_area_from_nav_seg_id(align_nav_seg)

	managers.navigation:destroy_nav_tracker(tracker_align)

	local team_ai_animation = self._tweak_data.animations[seat.name]

	if self:shooting_stance_mandatory() and seat.shooting_pos and seat.has_shooting_mode then
		team_ai_animation = team_ai_animation .. "_shooting"
	end

	local haste = "walk"

	if managers.groupai:state()._police_called then
		haste = "run"
	end

	local ride_objective = {
		pose = "stand",
		destroy_clbk_key = false,
		type = "act",
		haste = haste,
		nav_seg = align_nav_seg,
		area = align_area,
		pos = align_pos,
		rot = align_rot,
		fail_clbk = callback(self, self, "on_drive_SO_failed", seat),
		action = {
			align_sync = false,
			needs_full_blend = true,
			type = "act",
			body_part = 1,
			variant = team_ai_animation,
			blocks = {
				act = 1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				walk = -1
			}
		},
		objective_type = VehicleDrivingExt.SPECIAL_OBJECTIVE_TYPE_DRIVING
	}
	local SO_descriptor = {
		interval = 0,
		base_chance = 1,
		AI_group = "friendlies",
		chance_inc = 0,
		usage_amount = 1,
		objective = ride_objective,
		search_pos = ride_objective.pos,
		verification_clbk = callback(self, self, "clbk_drive_SO_verification"),
		admin_clbk = callback(self, self, "on_drive_SO_administered", seat)
	}
	local SO_id = "ride_" .. tostring(self._unit:key()) .. seat.name
	seat.drive_SO_data = {
		SO_registered = true,
		SO_id = SO_id,
		align_area = align_area,
		ride_objective = ride_objective
	}

	managers.groupai:state():add_special_objective(SO_id, SO_descriptor)
end

-- Lines 2283-2289
function VehicleDrivingExt:clbk_drive_SO_verification(candidate_unit)
	if candidate_unit:movement():cool() then
		return false
	end

	return true
end

-- Lines 2292-2308
function VehicleDrivingExt:on_drive_SO_administered(seat, unit)
	if not alive(self._unit) then
		return
	end

	if seat.drive_SO_data.unit then
		debug_pause("[VehicleDrivingExt:on_drive_SO_administered] Already had a unit!!!!", seat.name, unit, seat.drive_SO_data.unit)
	end

	seat.drive_SO_data.unit = unit
	seat.drive_SO_data.SO_registered = false
	unit:movement().vehicle_unit = self._unit
	unit:movement().vehicle_seat = seat

	managers.network:session():send_to_peers_synched("sync_ai_vehicle_action", "enter", self._unit, seat.name, unit)
end

-- Lines 2312-2314
function VehicleDrivingExt:on_drive_SO_started(seat, unit)
end

-- Lines 2318-2324
function VehicleDrivingExt:on_drive_SO_completed(seat, unit)
	if not alive(self._unit) then
		return
	end

	self:_place_ai_on_seat(seat, unit)
end

-- Lines 2328-2345
function VehicleDrivingExt:on_drive_SO_failed(seat, unit)
	if not alive(self._unit) then
		return
	end

	if not seat.drive_SO_data then
		return
	end

	if unit ~= seat.drive_SO_data.unit then
		debug_pause_unit(unit, "[VehicleDrivingExt:on_drive_SO_failed] team ai thinks he is riding", unit)

		return
	end

	seat.drive_SO_data = nil

	self:_create_seat_SO(seat)
end

-- Lines 2348-2363
function VehicleDrivingExt:_place_ai_on_seat(seat, unit)
	local rot = seat.third_object:rotation()
	local pos = seat.third_object:position()

	unit:set_rotation(rot)
	unit:set_position(pos)

	seat.occupant = unit

	self._unit:link(Idstring(VehicleDrivingExt.THIRD_PREFIX .. seat.name), unit)

	if managers.network:session() then
		-- Nothing
	end

	unit:brain():set_active(false)
end

-- Lines 2366-2405
function VehicleDrivingExt:sync_ai_vehicle_action(action, seat_name, unit)
	if action == "enter" then
		for _, seat in pairs(self._seats) do
			if seat.name == seat_name then
				local rot = seat.third_object:rotation()
				local pos = seat.third_object:position()
				unit:movement().vehicle_unit = self._unit
				unit:movement().vehicle_seat = seat

				self._door_soundsource:post_event(self._tweak_data.sound.door_close)
			end
		end
	elseif action == "exit" then
		unit:movement().vehicle_unit = nil
		unit:movement().vehicle_seat = nil
	else
		debug_pause("[VehicleDrivingExt:sync_ai_vehicle_action] Unknown value for parameter action!", "action", action)
	end
end

-- Lines 2407-2423
function VehicleDrivingExt:collision_callback(tag, unit, body, other_unit, other_body, position, normal, velocity, ...)
	if other_unit and other_unit:npc_vehicle_driving() then
		local attack_data = {
			damage = 1
		}

		other_unit:character_damage():damage_collision(attack_data)
	elseif other_unit and other_unit:damage() and other_body and other_body:extension() then
		local damage = 1

		other_body:extension().damage:damage_collision(self._unit, normal, position, velocity, damage, velocity)
	end
end

-- Lines 2426-2466
function VehicleDrivingExt:on_impact(ray, gforce, velocity)
	Application:debug("Impact detected, gforce: ", gforce)

	if ray then
		self._hit_soundsource:set_position(ray.hit_position)
	else
		self._hit_soundsource:set_position(self._unit:position())
	end

	if self._hit_sound then
		self._hit_soundsource:set_rtpc(self._hit_rtpc, math.clamp(gforce / 2.5, 0, 100))
		self._hit_soundsource:post_event(self._hit_sound)
	end

	local damage_ammount = gforce > 5 and math.ceil(gforce * 2) or false

	if not damage_ammount then
		return
	end

	if ray then
		local body = ray.body

		if ray.unit and ray.unit:damage() and ray.body and ray.body:extension() then
			ray.body:extension().damage:damage_collision(self._unit, ray.normal, ray.position, velocity, damage_ammount, velocity)
		end
	end

	local attack_data = {
		damage = damage_ammount,
		col_ray = ray
	}

	self._unit:character_damage():damage_collision(attack_data)

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:camera() then
			seat.occupant:camera():play_shaker("player_land", gforce / 100)
		end
	end
end

-- Lines 2468-2470
function VehicleDrivingExt:shooting_stance_allowed()
	return self._shooting_stance_allowed
end

-- Lines 2472-2474
function VehicleDrivingExt:shooting_stance_mandatory()
	return self:loot_contains_german_spy()
end

-- Lines 2476-2485
function VehicleDrivingExt:_number_in_the_vehicle()
	local count = 0

	for _, seat in pairs(self._seats) do
		if alive(seat.occupant) and seat.occupant:brain() == nil then
			count = count + 1
		end
	end

	return count
end

-- Lines 2487-2494
function VehicleDrivingExt:clear_all_visual_props()
	for _, loot in ipairs(self._loot) do
		if loot.visual_prop then
			Application:debug("[VehicleDrivingExt:clear_all_visual_props()] visual_prop", loot.visual_prop)
			loot.visual_prop:set_slot(0)
		end
	end
end

-- Lines 2498-2513
function VehicleDrivingExt:pre_destroy(unit)
	self:_stop_seat_sound_environment()
	self._hit_soundsource:stop()
	self._slip_soundsource:stop()
	self._bump_soundsource:stop()
	self._door_soundsource:stop()

	if self._engine_soundsource then
		self._engine_soundsource:stop()
	end

	self:_delete_position_reservation()
end

-- Lines 2516-2520
function VehicleDrivingExt:destroy()
	self:clear_all_visual_props()
	managers.hud:_remove_name_label(self._unit:unit_data().name_label_id)
	managers.hud:remove_vehicle_name_label(self._unit:unit_data().name_label_id)
end

-- Lines 2536-2542
function VehicleDrivingExt:save(data)
	data.vehicle_driving = {
		loot_interaction_enabled = self._loot_interaction_enabled,
		accepting_loot_enabled = self._accepting_loot_enabled,
		sequence_applied = self._skin_sequence
	}
end

-- Lines 2546-2564
function VehicleDrivingExt:load(data)
	if data.vehicle_driving and data.vehicle_driving.loot_interaction_enabled then
		self:enable_loot_interaction()
	else
		self:disable_loot_interaction()
	end

	if data.vehicle_driving and data.vehicle_driving.accepting_loot_enabled then
		self:enable_accepting_loot()
	else
		self:disable_accepting_loot()
	end

	local sequence_applied = data.vehicle_driving.sequence_applied

	if sequence_applied then
		self:set_skin(sequence_applied)
	end
end
