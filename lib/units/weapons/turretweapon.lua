TurretWeapon = TurretWeapon or class()
local mvec_to = Vector3()

function TurretWeapon:init(unit)
	self._unit = unit
	self._name_id = self.name_id
	self._overheat_skill_id = self._name_id .. "_overheat_reduction"

	self:set_active(true)

	self._locator_fire = unit:get_object(Idstring("fire_1"))
	self._locator_shells = unit:get_object(Idstring("shells"))
	self._overheating_smoke_locator = unit:get_object(Idstring("es_smoke")) or unit:get_object(Idstring("es_smoke_1"))
	self._number_of_barrels = tweak_data.weapon[self.name_id].number_of_barrels or 1
	self._current_barrel = 1

	self:_setup_fire_effects()
	self:_setup_smoke_effects()

	self._shell_ejection_effect = tweak_data.weapon[self.name_id].shell_ejection_effect and Idstring(tweak_data.weapon[self.name_id].shell_ejection_effect)
	self._shell_ejection_effect_table = nil

	if self._shell_ejection_effect then
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._locator_shells
		}
	end

	self._trail_effect_table = {
		effect = RaycastWeaponBase.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._sound_fire = SoundDevice:create_source("turret_fire")

	if self._locator_fire then
		self._sound_fire:link(self._locator_fire)
	end

	self._bullet_class = InstantBulletBase
	self._bullet_slotmask = self._bullet_class:bullet_slotmask()
	self._next_fire_allowed = 0
	self._locator_fpv = unit:get_object(Idstring("first_person_view"))
	self._locator_tpp = unit:get_object(Idstring("third_person_placement"))
	self._locator_tpp_orig = unit:get_object(Idstring("third_person_placement_orig")) or self._locator_tpp
	self._SO_object = unit:get_object(Idstring("third_person_placement_orig")) or self._locator_tpp_orig
	self._joint_heading = unit:get_object(Idstring("anim_heading"))
	self._joint_pitch = unit:get_object(Idstring("anim_pitch"))
	self._joint_pitch_original_pos = Vector3(self._joint_pitch:local_position().x, self._joint_pitch:local_position().y, self._joint_pitch:local_position().z)
	self._joint_heading_original_pos = Vector3(self._joint_heading:local_position().x, self._joint_heading:local_position().y, self._joint_heading:local_position().z)
	self._joint_root_time_limit = 10
	self._joint_root_elapsed_time = 0
	self._sound_movement = SoundDevice:create_source("turret_movement")

	if self._joint_pitch then
		self._sound_movement:link(self._joint_pitch)
	end

	self._sound_fire_start = tweak_data.weapon[self.name_id].sound_fire_start
	self._sound_fire_stop = tweak_data.weapon[self.name_id].sound_fire_stop
	self._sound_fire_start_fps = tweak_data.weapon[self.name_id].sound_fire_start_fps
	self._sound_fire_stop_fps = tweak_data.weapon[self.name_id].sound_fire_stop_fps
	self._sound_movement_start = tweak_data.weapon[self.name_id].sound_movement_start
	self._sound_movement_stop = tweak_data.weapon[self.name_id].sound_movement_stop
	self._fire_type = tweak_data.weapon[self.name_id].fire_type or "auto"
	self._bullet_type = tweak_data.weapon[self.name_id].bullet_type
	self._fire_range = tweak_data.weapon[self.name_id].fire_range
	self._mode = nil
	self._puppet_unit = nil
	self._puppet_stance = tweak_data.weapon[self.name_id].puppet_stance or "sitting"
	self._player_on = false
	self._turret_info = {}
	self._alert_events = {}
	self._alert_size = 100000
	self._alert_fires = {}
	self._damage = tweak_data.weapon[self.name_id].damage
	self._damage_npc = tweak_data.weapon[self.name_id].DAMAGE
	self._suppression = tweak_data.weapon[self.name_id].SUPPRESSION
	self._overheat_current = 0
	self._overheat_time = tweak_data.weapon[self.name_id].overheat_time or 1
	self._overheat_speed = tweak_data.weapon[self.name_id].overheat_speed or 0
	self._overheated = false

	self:_enable_overheating_smoke(false)

	self._heat_material = tweak_data.weapon[self.name_id].heat_material
	self._heat_material_parameter = tweak_data.weapon[self.name_id].heat_material_parameter
	self._setup = {
		turret_weapon_initialized = false,
		ignore_units = {
			self._unit
		}
	}
	self._SO_id = nil
	local usable_by_npc = tweak_data.weapon[self.name_id].usable_by_npc or false
	self._automatic_SO = usable_by_npc
	self._lock_fire = false

	managers.groupai:state():register_usable_turret(self)
end

function TurretWeapon:_init()
end

function TurretWeapon:post_init()
	self._unit:base():post_init()
end

function TurretWeapon:pre_destroy()
end

function TurretWeapon:set_visibility_state(visible)
	Application:error("[TurretWeapon] TurretWeapon:set_visibility_state: Implement me.")
end

function TurretWeapon:out_of_ammo()
	return false
end

function TurretWeapon:can_auto_reload()
	Application:error("[TurretWeapon] TurretWeapon:out_of_ammo(): Implement me.")
end

function TurretWeapon:set_laser_enabled()
	Application:error("[TurretWeapon] TurretWeapon:set_laser_enabled(): Implement me.")
end

function TurretWeapon:setup(setup_data, damage_multiplier)
end

function TurretWeapon:initialize_sentry(unit)
	if not alive(self._unit) then
		return
	end

	local owner = unit or managers.player:player_unit()
	local attached_data = SentryGunBase._attach(self._unit:position(), self._unit:rotation())

	self._unit:base():setup(owner, 1, 1, 1, 1, 1, false, attached_data)
	self._unit:base():activate_as_module("combatant", self.name_id)
	managers.network:session():send_to_peers_synched("sync_ground_turret_activate_as_module", self._unit)

	self._overheat_time = tweak_data.weapon[self.name_id].overheat_time

	if not self._overheat_current then
		self._overheat_current = 0
	end

	self._unit:brain():switch_off(true)
	self._unit:movement():set_active(false)

	self._setup.turret_weapon_initialized = true
end

function TurretWeapon:_setup_fire_effects()
	local muzzle_effect_tweak = tweak_data.weapon[self.name_id].muzzle_effect and Idstring(tweak_data.weapon[self.name_id].muzzle_effect)
	self._muzzle_effect_table = {}
	self._muzzle_effect = muzzle_effect_tweak

	for barrel_id = 1, self._number_of_barrels do
		local fire_locator_property_name = "_locator_fire_" .. barrel_id
		local fire_locator_object_name = Idstring("fire_" .. barrel_id)
		self[fire_locator_property_name] = self._unit:get_object(fire_locator_object_name)

		if muzzle_effect_tweak then
			table.insert(self._muzzle_effect_table, {
				force_synch = false,
				effect = self._muzzle_effect,
				parent = self[fire_locator_property_name]
			})
		end
	end
end

function TurretWeapon:_setup_smoke_effects()
	self._overheating_smoke_effect_table = {}
	self._overheating_smoke_effect = Idstring("effects/vanilla/smoke/smoke_turret_heated_001")

	for barrel_id = 1, self._number_of_barrels do
		local smoke_locator_property_name = "_locator_smoke_" .. barrel_id
		local smoke_locator_object_name = Idstring("es_smoke_" .. barrel_id)
		self[smoke_locator_property_name] = self._unit:get_object(smoke_locator_object_name)

		if self[smoke_locator_property_name] then
			table.insert(self._overheating_smoke_effect_table, {
				force_synch = false,
				effect = self._overheating_smoke_effect,
				parent = self[smoke_locator_property_name]
			})
		end
	end
end

function TurretWeapon:activate_sentry()
	self._moving = false

	self._unit:brain():switch_on()
	self._unit:movement():set_active(true)
end

function TurretWeapon:deactivate_sentry()
	self._moving = false

	self._unit:brain():switch_off(true)
	self._unit:movement():set_active(false)
end

function TurretWeapon:player_on()
	return self._player_on
end

function TurretWeapon:set_player_on(is_on)
	self._player_on = is_on
end

function TurretWeapon:set_mountable()
	if self._administered_unit_data then
		return
	end

	if not Network:is_server() then
		managers.network:session():send_to_host("sync_ground_turret_create_SO", self._unit)
	else
		self:_create_turret_SO()
	end
end

function TurretWeapon:debug_switch_on()
	self._unit:brain():switch_on()
	self._unit:movement():set_active(true)
end

function TurretWeapon:debug_switch_off()
	self._unit:brain():switch_off(true)
	self._unit:movement():set_active(false)
end

function TurretWeapon:debug_deactivate()
	self:deactivate()
end

function TurretWeapon:update(unit, t, dt)
	SoundDevice:set_rtpc("turret_heat_rtpc", self._overheat_current * 100)

	if self._mode and self._mode == "enemy" and not alive(self._puppet_unit) then
		Application:trace("TurretWeapon:update: ghost turret detected.")
		self:deactivate()
	end

	self:_reduce_heat(dt)

	if self._heat_material and self._heat_material_parameter then
		local ids_heat_material = Idstring(self._heat_material)
		local ids_heat_material_param = Idstring(self._heat_material_parameter)
		local materials = self._unit:materials()

		for _, material in ipairs(materials) do
			if ids_heat_material == material:name() then
				local start_verheating_threshold = 0.5

				if start_verheating_threshold < self._overheat_current then
					material:set_variable(ids_heat_material_param, (self._overheat_current - start_verheating_threshold) * 1 / start_verheating_threshold)
				else
					material:set_variable(ids_heat_material_param, 0)
				end
			end
		end
	end

	if not self._active then
		return
	end

	if self._turret_shell then
		self:_update_shell_movement(dt)
	end

	self:_update_turret_rot(dt)

	if alive(self._puppet_unit) and self._puppet_stance == "standing" then
		self:_upd_puppet_movement()
	end
end

function TurretWeapon:on_unit_set_enabled(enable)
	self._unit:interaction():set_active(enable, true)
end

function TurretWeapon:set_turret_rot(dt)
	if not alive(self._unit) or not self._turret_user or not self._joint_heading or not self._joint_pitch then
		return
	end

	local player_unit = managers.player:player_unit()

	if not player_unit then
		Application:trace("TurretWeapon:_set_turret_rot - missing player unit ")

		return
	end

	local player_rotation = managers.player:player_unit():movement():m_head_rot()
	self._player_rotation = player_rotation
end

function TurretWeapon:deactivate()
	self._unit:brain():switch_off(true)
	self._unit:movement():set_active(false)
	self:set_active(false)
	self:stop_autofire()

	self._mode = nil

	if alive(self._puppet_unit) then
		self._puppet_unit:inventory():show_equipped_unit()

		if not self._puppet_unit:character_damage():dead() then
			self._puppet_unit:movement():play_redirect("e_so_mg34_exit")

			self._puppet_unit:unit_data().turret_weapon = nil

			self._puppet_unit:unlink()

			if Network:is_server() then
				self._puppet_unit:brain():set_objective({
					is_default = true,
					type = "attack"
				})
			end
		end
	end

	self._puppet_unit = nil
	self._puppet_walking = false
	self._administered_unit_data = nil

	self._unit:interaction():set_active(true, true)

	if self._unit:damage() and self._unit:damage():has_sequence("turret_is_available") then
		self._unit:damage():run_sequence_simple("turret_is_available")
	end

	local team = managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player"))

	self._unit:movement():set_team(team)

	self._player_rotation = nil

	managers.network:session():send_to_peers_synched("sync_ground_turret_deactivate", self._unit)
end

function TurretWeapon:get_current_heat()
	return self._overheat_current
end

function TurretWeapon:is_overheating()
	return self._overheated
end

function TurretWeapon:_reduce_heat(dt)
	if not self._shooting then
		self._overheat_time = tweak_data.weapon[self.name_id].overheat_time or 1
		self._overheat_current = math.clamp(self._overheat_current - 1 / (self._overheat_time or 1) * dt, 0, 1)
	end

	if self._overheat_current > 0 and self._overheat_current < 0.1 then
		self:_enable_overheating_smoke(false)
	end

	if self._overheat_current == 0 then
		self._overheated = false
	end
end

function TurretWeapon:_increase_heat()
	if alive(self._puppet_unit) then
		return
	end

	local warcry_multiplier = 1

	if managers.warcry:active() and managers.warcry:get_active_warcry_name() == "berserk" then
		warcry_multiplier = managers.player:upgrade_value("player", "warcry_overheat_multiplier", 1)
	end

	local overheat_delta = self._overheat_speed * managers.player:upgrade_value("player", self._overheat_skill_id, 1) * warcry_multiplier
	self._overheat_current = math.clamp(self._overheat_current + overheat_delta, 0, 1)

	if self._overheat_current >= 1 then
		self._overheated = true

		self:stop_autofire()
		self:_enable_overheating_smoke(true)
	end
end

function TurretWeapon:_enable_overheating_smoke(enabled)
	if self._overheating_smoke_effect and enabled then
		for barrel_id = 1, self._number_of_barrels do
			if self._overheating_smoke_effect_table[barrel_id] then
				local smoke_spawn_name = "_overheating_smoke_spawn_" .. barrel_id
				self[smoke_spawn_name] = World:effect_manager():spawn(self._overheating_smoke_effect_table[barrel_id])
			end
		end
	else
		for barrel_id = 1, self._number_of_barrels do
			local smoke_spawn_name = "_overheating_smoke_spawn_" .. barrel_id

			if self[smoke_spawn_name] then
				World:effect_manager():fade_kill(self[smoke_spawn_name])

				self[smoke_spawn_name] = nil
			end
		end
	end
end

function TurretWeapon:_update_heading_rotation(dt, target_heading_rot)
	local anim_lerp = dt * 4
	local smooth_heading_rot = self._joint_heading:rotation():slerp(target_heading_rot, anim_lerp)

	self._joint_heading:set_rotation(smooth_heading_rot)

	local heading_diff = Rotation:rotation_difference(smooth_heading_rot, target_heading_rot)

	return math.abs(heading_diff:yaw())
end

function TurretWeapon:_update_animation_pitch(anim_name, dt, target_pitch)
	local anims = self._unit:anim_groups()
	local anim_exists = false
	local anim_id_name = Idstring(anim_name)

	for _, v in pairs(anims) do
		if v == anim_id_name then
			anim_exists = true

			break
		end
	end

	if not anim_exists then
		return 0
	end

	local MAX_ANGLE = tweak_data.weapon[self.name_id].MAX_PITCH_ANGLE
	local MIN_ANGLE = tweak_data.weapon[self.name_id].MIN_PITCH_ANGLE
	local pitch_percentage = (target_pitch - MIN_ANGLE) * 100 / (MAX_ANGLE - MIN_ANGLE)
	local MAX_TIME = self._unit:anim_length(anim_id_name)
	local CUR_ANIM_TIME = self._unit:anim_time(anim_id_name)
	local anim_pitch = CUR_ANIM_TIME * (MAX_ANGLE - MIN_ANGLE) / MAX_TIME
	local anim_t = pitch_percentage * MAX_TIME / 100
	local anim_dir = 1

	if target_pitch < anim_pitch then
		anim_dir = -1
	end

	self._unit:anim_play_to(anim_id_name, anim_t, anim_dir)

	return math.abs(target_pitch - anim_pitch)
end

function TurretWeapon:_reset_pitch()
	local heading = self._joint_heading:rotation()

	self._joint_pitch:set_rotation(heading)
	self:_reset_animation("anim_arm")
end

function TurretWeapon:_update_rotation_pitch(dt, target_pitch_rot)
	local anim_lerp = 4 * dt
	local MAX_ANGLE = tweak_data.weapon[self.name_id].MAX_PITCH_ANGLE
	local MIN_ANGLE = tweak_data.weapon[self.name_id].MIN_PITCH_ANGLE
	local current_pitch = self._joint_pitch:rotation():pitch()
	local target_pitch = target_pitch_rot:pitch()
	local new_pitch = (1 - anim_lerp) * current_pitch + anim_lerp * target_pitch
	new_pitch = math.clamp(new_pitch, MIN_ANGLE, MAX_ANGLE)
	local rot = self._joint_pitch:rotation()

	mrotation.set_yaw_pitch_roll(rot, rot:yaw(), new_pitch, rot:roll())
	self._joint_pitch:set_rotation(rot)

	return math.abs(new_pitch - current_pitch)
end

function TurretWeapon:_reset_animation(name)
	local id_name = Idstring(name)
	local anims = self._unit:anim_groups()
	local exists = false

	for _, v in pairs(anims) do
		if v == id_name then
			exists = true

			break
		end
	end

	if not exists then
		return
	end

	local MAX_ANGLE = tweak_data.weapon[self.name_id].MAX_PITCH_ANGLE
	local MIN_ANGLE = tweak_data.weapon[self.name_id].MIN_PITCH_ANGLE
	local time = 0 - MIN_ANGLE

	self._unit:anim_set_time(id_name, 0)
end

function TurretWeapon:_update_pitch(dt, target_pitch_rot)
	local delta_pitch = 0
	delta_pitch = delta_pitch + self:_update_rotation_pitch(dt, target_pitch_rot)

	self:_update_animation_pitch("anim_arm", dt, target_pitch_rot:pitch())

	return delta_pitch
end

function TurretWeapon:_update_turret_rot(dt)
	if not self._player_rotation then
		return
	end

	if self._joint_root_time_limit < self._joint_root_elapsed_time then
		self._joint_root_elapsed_time = 0

		self._joint_pitch:set_local_position(self._joint_pitch_original_pos)
		self._joint_heading:set_local_position(self._joint_heading_original_pos)
	end

	self._joint_root_elapsed_time = self._joint_root_elapsed_time + dt

	self._unit:set_moving(2)

	self._turret_info.target_rot_heading = self._player_rotation:yaw()
	self._turret_info.target_rot_pitch = self._player_rotation:pitch()
	local target_heading_rot = Rotation(self._turret_info.target_rot_heading, self._joint_heading:local_rotation():pitch(), 0)
	local target_pitch_rot = Rotation(self._turret_info.target_rot_heading, self._turret_info.target_rot_pitch, 0)
	local delta_heading = self:_update_heading_rotation(dt, target_heading_rot)
	local delta_pitch = 0

	if self._turret_user or self._puppet_stance == "sitting" then
		delta_pitch = self:_update_pitch(dt, target_pitch_rot)
	else
		self:_reset_pitch()
	end

	local movement_diff = delta_pitch + delta_heading

	if movement_diff > 1 and not self._moving then
		self._moving = true

		if self._sound_movement_start then
			self._sound_movement:post_event(self._sound_movement_start)
		end
	end

	if movement_diff <= 1 and self._moving then
		self._moving = false

		self:stop_moving_sound()
	end
end

function TurretWeapon:stop_moving_sound()
	if self._sound_movement then
		self._sound_movement:stop()
	end
end

function TurretWeapon:sync_turret_rotation(player_rotation)
	self._player_rotation = player_rotation
end

function TurretWeapon:set_ammo(amount)
end

function TurretWeapon:start_autofire()
	if self._shooting or self._lock_fire then
		return
	end

	self:_sound_autofire_start()

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
	self._rate_of_fire = 1 / (tweak_data.weapon[self.name_id].rate_of_fire / 60)
	self._overheat_speed = self._rate_of_fire / self._overheat_time

	self:_play_recoil_animation()
end

function TurretWeapon:stop_autofire()
	if self._shooting then
		self:_sound_autofire_end()

		self._shooting = nil
	end
end

function TurretWeapon:trigger_held(blanks, expend_ammo, shoot_player, target_unit, damage_multiplier)
	if not self._shooting then
		return false
	end

	local fired = nil

	if not self._lock_fire and self._next_fire_allowed <= Application:time() then
		fired = self:fire(blanks, expend_ammo, shoot_player, target_unit, damage_multiplier)

		if fired then
			if self._unit:damage() and self._unit:damage():has_sequence("fired") then
				self._unit:damage():run_sequence_simple("fired")
			end

			self._next_fire_allowed = self._next_fire_allowed + self._rate_of_fire

			self:_increase_heat()
		end
	end

	return fired
end

function TurretWeapon:_upd_puppet_movement()
	if self._puppet_stance == "sitting" then
		return
	end

	local fire_locator = self:_get_fire_locator()
	local current_position = fire_locator:position()
	local current_direction = fire_locator:rotation():y()

	mvector3.negate(current_direction)
	mvector3.multiply(current_direction, 1000)

	local original_position = self._unit:position()
	local original_direction = self._unit:rotation():y()

	mvector3.multiply(original_direction, 1000)

	local deflection = original_direction:angle(current_direction)
	local deflection_direction = math.sign((original_direction - current_direction):to_polar_with_reference(current_direction, math.UP).spin)
	local spin_max = self._unit:movement()._spin_max or deflection
	local deflection_normalized = deflection / math.abs(spin_max)
	local redirect_animation = "e_so_mg34_aim_right"
	local redirect_state = Idstring("std/stand/so/idle/e_so_mg34_aim_right")

	if deflection_direction < 0 then
		redirect_animation = "e_so_mg34_aim_left"
		redirect_state = Idstring("std/stand/so/idle/e_so_mg34_aim_left")
	end

	local position_difference = (self._puppet_unit:position() - self._SO_object:position()):length()

	if position_difference > 1 then
		self._puppet_unit:warp_to(self._SO_object:rotation(), self._SO_object:position())
	end

	self._puppet_unit:anim_state_machine():set_parameter(redirect_state, "t", deflection_normalized)

	local result = self._puppet_unit:movement():play_redirect(redirect_animation)
end

function TurretWeapon:_play_recoil_animation()
	if alive(self._puppet_unit) then
		self._puppet_unit:movement():play_redirect("recoil_turret_m2")
	end
end

function TurretWeapon:fire(blanks, expend_ammo, shoot_player, target_unit, damage_multiplier)
	if self._overheated or self._lock_fire then
		return
	end

	damage_multiplier = damage_multiplier or 1
	local fire_locator = self:_get_fire_locator()
	local from_pos = fire_locator:position()
	local fire_direction_fp = fire_locator:rotation():y()
	local fire_direction_tp = not self._puppet_unit and self._joint_pitch and self._joint_pitch:rotation():y()

	if fire_direction_tp then
		mvector3.negate(fire_direction_tp)
	end

	local direction = fire_direction_fp

	if fire_direction_tp then
		direction = fire_direction_tp
	end

	mvector3.negate(direction)
	mvector3.spread(direction, 1)

	if self._muzzle_effect then
		World:effect_manager():spawn(self._muzzle_effect_table[self._current_barrel])

		if self._shell_ejection_effect_table then
			World:effect_manager():spawn(self._shell_ejection_effect_table)
		end
	end

	local anim_groups = self._unit:anim_groups()

	for _, anim_name in ipairs(anim_groups) do
		local current_barrel_name = Idstring("ag_barrel_fire_" .. self._current_barrel)

		if anim_name == current_barrel_name then
			self._unit:anim_set_time(anim_name, 0)
			self._unit:anim_play(anim_name, 1)

			break
		end
	end

	local ray_res = nil

	if self._bullet_type == "shell" then
		if not self._turret_shell_sound_source then
			self._turret_shell_sound_source = SoundDevice:create_source("turret_shell_explode")
		end

		ray_res = self:_fire_shell(from_pos, direction)
	else
		ray_res = self:_fire_raycast(from_pos, direction, shoot_player, target_unit, damage_multiplier)
	end

	self:_sound_fire_single()

	self._current_barrel = self._current_barrel % self._number_of_barrels + 1

	self:_alert()

	return true
end

function TurretWeapon:_update_shell_movement(dt)
	if not self._turret_shell then
		return
	end

	if not self._shell_cumulative_gravity then
		self._shell_cumulative_gravity = 0
	end

	self._shell_cumulative_gravity = self._shell_cumulative_gravity + 9.81 * dt
	local shell_velocity = 60000
	local fire_position = self._locator_fire:position()
	local old_shell_position = Vector3(self._turret_shell.position.x, self._turret_shell.position.y, self._turret_shell.position.z)
	self._turret_shell.position = self._turret_shell.position + self._turret_shell.direction * shell_velocity * dt + Vector3(0, 0, -self._shell_cumulative_gravity)
	local shell_distance = mvector3.distance(fire_position, self._turret_shell.position)

	if self._fire_range < shell_distance then
		Application:debug("TurretWeapon:_update_shell_movement: BOOM!")
		self:_turret_shell_explode(self._turret_shell.position, nil, true)

		self._turret_shell = nil
		self._shell_cumulative_gravity = 0
	else
		self:_turret_shell_explode(old_shell_position, self._turret_shell.position, false)
	end
end

function TurretWeapon:_fire_shell(from_pos, direction)
	self._turret_shell = {
		position = from_pos,
		direction = direction
	}
	self._shell_cumulative_gravity = 0
end

function TurretWeapon:_turret_shell_explode(from_pos, to_pos, detonate_now)
	local shell_position = from_pos

	if not detonate_now then
		local col_ray = World:raycast("ray", from_pos, to_pos, "ignore_unit", self._setup.ignore_units)

		if not col_ray then
			return
		end

		shell_position = col_ray.hit_position
		self._turret_shell = nil
		self._shell_cumulative_gravity = 0
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/vanilla/explosions/vehicle_explosion"),
		position = shell_position,
		normal = math.UP
	})

	if self._turret_shell_sound_source then
		self._turret_shell_sound_source:set_position(shell_position)
		self._turret_shell_sound_source:post_event("dynamite_explosion")
	end

	local pos = shell_position
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local damage = tweak_data.weapon[self.name_id].damage or 1000
	local damage_radius = tweak_data.weapon[self.name_id].damage_radius or 1000
	local player_damage = tweak_data.weapon[self.name_id].player_damage or 10
	local armor_piercing = tweak_data.weapon[self.name_id].armor_piercing
	local curve_pow = 3
	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		alert_radius = 10000,
		hit_pos = pos,
		range = damage_radius,
		collision_slotmask = slot_mask,
		curve_pow = curve_pow,
		damage = damage,
		player_damage = player_damage,
		ignore_unit = managers.player:local_player(),
		user = managers.player:local_player(),
		armor_piercing = armor_piercing
	})

	managers.network:session():send_to_peers_synched("sync_ground_turret_shell_explosion", self._unit, pos, damage_radius, damage, player_damage, curve_pow)
end

function TurretWeapon:_get_fire_locator()
	local fire_locator = self["_locator_fire_" .. self._current_barrel] or self._locator_fire_1

	return fire_locator
end

function TurretWeapon:_get_puppet_locator()
	return self._locator_tpp
end

function TurretWeapon:_get_smoke_locator()
	local smoke_locator = self["_locator_smoke_" .. self._current_barrel] or self._locator_smoke_1

	return smoke_locator
end

function TurretWeapon:_alert()
	local weapon_stats = tweak_data.weapon.stats
	local stats = tweak_data.weapon[self:get_name_id()].stats
	local alert_size = weapon_stats.alert_size[stats.alert_size]
	local new_alert = {
		"bullet",
		self._locator_fire_1:position(),
		alert_size,
		[5] = managers.player:player_unit(),
		self._locator_fire_1:position()
	}

	managers.groupai:state():propagate_alert(new_alert)
end

local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

function TurretWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit, damage_multiplier)
	local result = {}
	local hit_unit = nil

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, tweak_data.weapon[self._name_id].FIRE_RANGE)
	mvector3.add(mvec_to, from_pos)

	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local player_hit, player_ray_data = nil

	if shoot_player then
		player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, col_ray, from_pos, direction)

		if player_hit then
			local damage = self:_apply_dmg_mul(self:get_damage(), col_ray or player_ray_data, from_pos)

			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, self._unit, damage)
		end
	end

	local char_hit = nil

	if not player_hit and col_ray then
		local damage = self:_apply_dmg_mul(self:get_damage(), col_ray, from_pos)
		char_hit = InstantBulletBase:on_collision(col_ray, self._unit, self._turret_user or self._unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(self._suppression)
	end

	if not col_ray or col_ray.distance > 600 then
		self:_spawn_trail_effect(direction, col_ray)
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	return result
end

function TurretWeapon:_spawn_trail_effect(direction, col_ray)
	local current_fire_object_name = "_locator_fire_" .. self._current_barrel

	self[current_fire_object_name]:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

function TurretWeapon:_apply_dmg_mul(damage, col_ray, from_pos)
	local damage_out = damage

	if tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE then
		local ray_dis = col_ray.distance or mvector3.distance(from_pos, col_ray.position)
		local ranges = tweak_data.weapon[self._name_id].DAMAGE_MUL_RANGE
		local i_range = nil

		for test_i_range, range_data in ipairs(ranges) do
			if ray_dis < range_data[1] or test_i_range == #ranges then
				i_range = test_i_range

				break
			end
		end

		if i_range == 1 or ranges[i_range][1] < ray_dis then
			damage_out = damage_out * ranges[i_range][2]
		else
			local dis_lerp = (ray_dis - ranges[i_range - 1][1]) / (ranges[i_range][1] - ranges[i_range - 1][1])
			damage_out = damage_out * math.lerp(ranges[i_range - 1][2], ranges[i_range][2], dis_lerp)
		end
	end

	return damage_out
end

function TurretWeapon:_sound_autofire_start()
	if self._fire_type == "auto" and self._sound_fire_start then
		local sound_event = alive(self._turret_user) and self._turret_user == managers.player:player_unit() and self._sound_fire_start_fps or self._sound_fire_start

		self._sound_fire:post_event("turret_heat")
		self._sound_fire:post_event(sound_event)
	end
end

function TurretWeapon:_sound_autofire_end()
	if self._fire_type == "auto" and self._sound_fire and self._sound_fire_stop then
		local sound_event = alive(self._turret_user) and self._turret_user == managers.player:player_unit() and self._sound_fire_stop_fps or self._sound_fire_stop

		self._sound_fire:post_event("turret_heat_stop")
		self._sound_fire:post_event(sound_event)

		if self._overheated then
			self._sound_fire:post_event("turret_cool_down")
		end
	end
end

function TurretWeapon:_sound_fire_single()
	if self._fire_type == "single" then
		local sound_event = alive(self._turret_user) and self._turret_user == managers.player:player_unit() and self._sound_fire_start_fps or self._sound_fire_start

		self._sound_fire:post_event(sound_event)
	end
end

function TurretWeapon:_sound_autofire_end_empty()
end

function TurretWeapon:_sound_autofire_end_cooldown()
end

function TurretWeapon:ammo_total()
end

function TurretWeapon:ammo_max()
end

function TurretWeapon:on_team_set(team_data)
	self._foe_teams = team_data.foes
end

function TurretWeapon:get_name_id()
	return self.name_id
end

function TurretWeapon:weapon_tweak_data()
	return tweak_data.weapon[self.name_id]
end

function TurretWeapon:has_part()
end

function TurretWeapon:update_laser()
end

function TurretWeapon:on_death()
end

function TurretWeapon:has_shield()
	return false
end

function TurretWeapon:unregister()
end

function TurretWeapon:save(save_data)
	local my_save_data = {}
	save_data.weapon = my_save_data
	my_save_data.foe_teams = self._foe_teams
	my_save_data.alert = self._alert_events and true or nil
	my_save_data.player_on = self._player_on

	if self._puppet_unit then
		local peer = managers.network:session():dropin_peer()

		managers.enemy:add_delayed_clbk("delay_sync_turret_unit" .. tostring(self._puppet_unit:key()), callback(self, self, "_delay_sync_turret_unit", peer), TimerManager:game():time() + 0.5)
	end
end

function TurretWeapon:load(save_data)
	local my_save_data = save_data.weapon
	self._foe_teams = my_save_data.foe_teams
	self._auto_reload = my_save_data.auto_reload
	self._player_on = my_save_data.player_on
	self._setup = {
		ignore_units = {
			self._unit
		}
	}

	if not my_save_data.alert then
		self._alert_events = nil
	end
end

function TurretWeapon:_delay_sync_turret_unit(peer)
	if not managers.network:session() then
		return
	end

	if not peer then
		return
	end

	if not alive(self._puppet_unit) then
		return
	end

	peer:send_queued_sync("sync_ground_turret_SO_completed", self._unit, self._puppet_unit)
end

function TurretWeapon:destroy(unit)
	if self._sound_fire then
		self._sound_fire:stop()

		self._sound_fire = nil
	end

	if self._sound_movement then
		self._sound_movement:stop()

		self._sound_movement = nil
	end

	if self._turret_shell_sound_source then
		self._turret_shell_sound_source:stop()

		self._turret_shell_sound_source = nil
	end
end

function TurretWeapon:_create_turret_SO()
	if not alive(self._unit) then
		return
	end

	if not self._automatic_SO then
		return
	end

	self._SO_object = self._unit:get_object(Idstring("third_person_placement_orig")) or self._locator_tpp

	if not alive(self._SO_object) then
		return
	end

	local variant = tweak_data.weapon[self._name_id].anim_enter
	local tracker_align = managers.navigation:create_nav_tracker(self._SO_object:position(), false)
	local align_nav_seg = tracker_align:nav_segment()
	local align_pos = self._SO_object:position()
	local align_rot = self._SO_object:rotation()
	local align_area = managers.groupai:state():get_area_from_nav_seg_id(align_nav_seg)

	managers.navigation:destroy_nav_tracker(tracker_align)

	local turret_objective = {
		pose = "stand",
		destroy_clbk_key = false,
		type = "turret",
		haste = "run",
		nav_seg = align_nav_seg,
		area = align_area,
		pos = align_pos,
		rot = align_rot,
		fail_clbk = callback(self, self, "on_turret_SO_failed"),
		complete_clbk = callback(self, self, "on_turret_SO_completed"),
		action = {
			align_sync = true,
			needs_full_blend = true,
			type = "act",
			body_part = 1,
			variant = variant,
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				walk = -1
			}
		}
	}
	local SO_descriptor = {
		interval = -1,
		search_dis_sq = 4000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = turret_objective,
		search_pos = turret_objective.pos,
		access = managers.navigation:convert_access_filter_to_number({
			"gangster",
			"security",
			"security_patrol",
			"cop",
			"fbi",
			"swat",
			"murky"
		}),
		admin_clbk = callback(self, self, "on_turret_SO_administered")
	}
	local SO_id = "turret_" .. tostring(self._unit:key())
	self._SO_data = {
		SO_registered = true,
		SO_id = SO_id,
		align_area = align_area
	}

	managers.groupai:state():add_special_objective(SO_id, SO_descriptor)
end

function TurretWeapon:active()
	return self._active
end

function TurretWeapon:sync_administered_unit(unit)
	self._administered_unit_data = {
		unit = unit
	}
end

function TurretWeapon:on_turret_SO_administered(unit, SO)
	managers.network:session():send_to_peers_synched("sync_ground_turret_SO_administered", self._unit, unit)

	if not self._setup.turret_weapon_initialized then
		self:initialize_sentry(unit)
	end

	self._administered_unit_data = {
		unit = unit,
		SO = SO
	}
end

function TurretWeapon:on_turret_SO_failed(unit)
	self._administered_to_unit = nil
	self._mode = nil
	self._puppet_unit = nil
end

function TurretWeapon:on_turret_SO_completed(unit)
	if not alive(unit) then
		return
	end

	unit:brain():set_logic("turret", nil)

	self._puppet_unit = unit
	self._puppet_unit:unit_data().turret_weapon = self
	self._last_puppet_position = unit:position()
	self._puppet_walking = false
	local enter_turret_anim_name = tweak_data.weapon[self.name_id].anim_enter

	self._puppet_unit:movement():enter_turret_animation(enter_turret_anim_name, callback(self, self, "activate_turret"))

	local team = self._puppet_unit:movement():team()

	self._unit:movement():set_team(team)
	self._unit:interaction():set_active(false, true)
	managers.network:session():send_to_peers_synched("sync_ground_turret_SO_completed", self._unit, unit)
end

function TurretWeapon:sync_create_SO()
	self:enable_automatic_SO(true)
end

function TurretWeapon:sync_SO_completed(puppet_unit)
	if not alive(puppet_unit) then
		return
	end

	local position_difference = (puppet_unit:position() - self._SO_object:position()):length()
	position_difference = (puppet_unit:position() - self._SO_object:position()):length()
	self._puppet_unit = puppet_unit
	self._puppet_unit:unit_data().turret_weapon = self
	self._last_puppet_position = puppet_unit:position()
	self._puppet_walking = false
	local enter_turret_anim_name = tweak_data.weapon[self.name_id].anim_enter

	self._puppet_unit:movement():enter_turret_animation(enter_turret_anim_name, callback(self, self, "activate_turret"))
	self._puppet_unit:inventory():hide_equipped_unit()
	self._unit:interaction():set_active(false, true)
end

function TurretWeapon:sync_cancel_SO()
	self:enable_automatic_SO(false)
end

function TurretWeapon:remove_administered_SO()
	local result = self._SO_data and managers.groupai:state():remove_special_objective(self._SO_data.SO_id)
end

function TurretWeapon:is_available()
	return not self._mode and not self._administered_unit_data and self._active
end

function TurretWeapon:set_weapon_user(user)
	self._turret_user = user
	self._player_rotation = nil
end

function TurretWeapon:activate_turret()
	if alive(self._puppet_unit) and self._puppet_stance == "sitting" then
		self._unit:link(Idstring("third_person_placement"), self._puppet_unit)
	end

	self:activate_sentry()

	self._mode = "enemy"

	self:set_active(true)

	if Network:is_server() and self._unit:damage() and self._unit:damage():has_sequence("turret_is_occupied") then
		self._unit:damage():run_sequence_simple("turret_is_occupied")
	end
end

function TurretWeapon:keep_ai_attached()
	self._unit:brain():keep_ai_attached()
end

function TurretWeapon:add_outline()
	if Network:is_server() then
		self._unit:contour():add("highlight", true)
	end
end

function TurretWeapon:remove_outline()
	if Network:is_server() then
		self._unit:contour():remove("highlight", true)
	end
end

function TurretWeapon:enable_automatic_SO(enabled)
	if not self._automatic_SO then
		return
	end

	if enabled then
		self:set_mountable()
	else
		self:_cancel_active_SO()
	end
end

function TurretWeapon:on_player_enter()
	self._player_on = true

	if Network:is_server() then
		if self._unit:damage() and self._unit:damage():has_sequence("turret_is_occupied") then
			self._unit:damage():run_sequence_simple("turret_is_occupied")
		end

		if self._unit:damage() and self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact")
		end

		managers.network:session():send_to_peers_synched("sync_player_on", self._unit, self._player_on)
	else
		managers.network:session():send_to_host("sync_ground_turret_activate_triggers", self._unit)
	end

	local team = managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player"))

	self._unit:movement():set_team(team)

	if not self._lock_fire and managers.player:get_turret_unit() == self._unit then
		managers.hud:player_turret_flak_insert()
	end

	self:enable_automatic_SO(false)
end

function TurretWeapon:on_player_exit()
	self._player_on = false

	if self._shooting then
		self:_sound_autofire_end()
	end

	if Network:is_server() then
		if self._unit:damage() and self._unit:damage():has_sequence("player_exit") then
			self._unit:damage():run_sequence_simple("player_exit")
		end

		managers.network:session():send_to_peers_synched("sync_player_on", self._unit, self._player_on)
	else
		managers.network:session():send_to_host("sync_ground_turret_exit_triggers", self._unit)
	end

	self:stop_moving_sound()
end

function TurretWeapon:sync_activate_triggers()
	if self._unit:damage() and self._unit:damage():has_sequence("turret_is_occupied") then
		self._unit:damage():run_sequence_simple("turret_is_occupied")
	end

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact")
	end

	self._player_on = true

	managers.network:session():send_to_peers_synched("sync_player_on", self._unit, self._player_on)
end

function TurretWeapon:sync_exit_triggers()
	if self._unit:damage() and self._unit:damage():has_sequence("player_exit") then
		self._unit:damage():run_sequence_simple("player_exit")
	end

	self._player_on = false

	managers.network:session():send_to_peers_synched("sync_player_on", self._unit, self._player_on)
end

function TurretWeapon:_cancel_active_SO()
	if self._administered_unit_data and alive(self._administered_unit_data.unit) and self._administered_unit_data.unit:character_damage() and self._administered_unit_data.unit:character_damage().dead and not self._administered_unit_data.unit:character_damage():dead() then
		if Network:is_server() then
			self._administered_unit_data.unit:brain():set_objective(nil)
			self._administered_unit_data.unit:brain():set_logic("idle", nil)
			self._administered_unit_data.unit:brain():action_request({
				sync = true,
				body_part = 2,
				type = "idle"
			})
			self:on_turret_SO_failed(self._administered_unit_data.unit)

			self._administered_unit_data = nil
		else
			managers.network:session():send_to_host("sync_ground_turret_cancel_SO", self._unit)
		end
	end

	self:remove_administered_SO()
end

function TurretWeapon:on_puppet_damaged(data, damage_info)
	if not alive(self._puppet_unit) then
		return
	end

	local player_is_visible = self._unit:movement():is_target_visible()

	if not player_is_visible then
		managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
		self:deactivate()

		return
	end

	local attacker_unit = damage_info.attacker_unit

	managers.network:session():send_to_peers_synched("sync_ground_turret_puppet_damaged", self._unit, attacker_unit)

	local damage_by_team = attacker_unit:movement():team()

	if damage_by_team.id == "criminal1" then
		local shot_from_behind = self._unit:movement():is_unit_behind(attacker_unit)

		if shot_from_behind then
			managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
			self:deactivate()

			return
		end
	end

	self._activate_turret_clbk_id = "activate_turret_" .. tostring(self._puppet_unit:key())
	local dazed_duration = tweak_data.weapon[self.name_id].dazed_duration or 3

	self:deactivate_sentry()
	managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
	managers.queued_tasks:queue(self._activate_turret_clbk_id, self.activate_turret, self, nil, dazed_duration)
end

function TurretWeapon:on_puppet_death(data, damage_info)
	managers.network:session():send_to_peers_synched("sync_ground_turret_puppet_death", self._unit)
	managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
	self:deactivate()
	self:_create_turret_SO()
end

function TurretWeapon:on_puppet_damaged_client(attacker_unit)
	if not alive(self._puppet_unit) then
		return
	end

	if not alive(attacker_unit) then
		return
	end

	local player_is_visible = self._unit:movement():is_target_visible()

	if not player_is_visible then
		managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
		self:deactivate()

		return
	end

	local damage_by_team = attacker_unit:movement():team()

	if damage_by_team.id == "criminal1" then
		local shot_from_behind = self._unit:movement():is_unit_behind(attacker_unit)

		if shot_from_behind then
			managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
			self:deactivate()

			return
		end
	end

	self._activate_turret_clbk_id = "activate_turret_" .. tostring(self._puppet_unit:key())
	local dazed_duration = tweak_data.weapon[self.name_id].dazed_duration or 3

	self:deactivate_sentry()
	managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
	managers.queued_tasks:queue(self._activate_turret_clbk_id, self.activate_turret, self, nil, dazed_duration)
end

function TurretWeapon:on_puppet_death_client()
	managers.queued_tasks:unqueue_all(self._activate_turret_clbk_id, self)
	self:deactivate()
end

function TurretWeapon:set_active(state)
	self._active = state

	if state then
		self._unit:set_extension_update_enabled(Idstring("weapon"), true)
	else
		managers.queued_tasks:queue(nil, self._disable_extension, self, nil, 5, nil)
	end
end

function TurretWeapon:_disable_extension()
	if alive(self._unit) and not self._active then
		self._unit:set_extension_update_enabled(Idstring("weapon"), false)
	end
end

function TurretWeapon:deactivate_client()
	Application:trace("TurretWeapon:deactivate_client")

	if self._player_rotation then
		self._unit:set_moving(2)

		self._turret_info.target_rot_heading = self._player_rotation:yaw()
		self._turret_info.target_rot_pitch = self._player_rotation:pitch()
		local target_heading_rot = Rotation(self._turret_info.target_rot_heading, 0, 0)
		local target_pitch_rot = Rotation(self._turret_info.target_rot_heading, self._turret_info.target_rot_pitch, 0)

		self._joint_heading:set_rotation(target_heading_rot)

		if self._turret_user or self._puppet_stance == "sitting" then
			Application:trace("TurretWeapon:deactivate_client: ", inspect(target_heading_rot), inspect(target_pitch_rot))
			self._joint_pitch:set_rotation(Rotation(self._joint_pitch:rotation():yaw(), target_pitch_rot:pitch(), 0))
		else
			local heading = self._joint_heading:rotation()

			self._joint_pitch:set_rotation(heading)
		end
	end

	self._unit:brain():switch_off(true)
	self._unit:movement():set_active(false)
	self:set_active(false)
	self:_sound_autofire_end()

	self._shooting = nil
	self._mode = nil

	if alive(self._puppet_unit) then
		self._puppet_unit:inventory():show_equipped_unit()

		if not self._puppet_unit:character_damage():dead() then
			self._puppet_unit:movement():play_redirect("e_so_mg34_exit")

			self._puppet_unit:unit_data().turret_weapon = nil

			self._puppet_unit:unlink()
		end

		self._puppet_unit = nil
		self._puppet_walking = false
	end

	self._administered_unit_data = nil

	self._unit:interaction():set_active(true, true)

	if self._unit:damage() and self._unit:damage():has_sequence("turret_is_available") then
		self._unit:damage():run_sequence_simple("turret_is_available")
	end

	local team = managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player"))

	self._unit:movement():set_team(team)

	self._player_rotation = nil
end

function TurretWeapon:lock_fire(lock)
	self._lock_fire = lock

	if not self._lock_fire and managers.player:get_turret_unit() == self._unit then
		managers.hud:player_turret_flak_insert()
	end
end

function TurretWeapon:locked_fire()
	return self._lock_fire
end

function TurretWeapon:weapon_unlocked()
	Application:trace("TurretWeapon:weapon_unlocked: ", inspect(not self._lock_fire))

	return not self._lock_fire
end

function TurretWeapon:_shell_explosion_on_client(position, radius, damage, player_damage, curve_pow)
	Application:trace("TurretWeapon:_shell_explosion_on_client")

	local sound_event = "grenade_explode"
	local damage_radius = radius or tweak_data.weapon[self.name_id].damage_radius or 1000
	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = damage_radius * 2
	}

	managers.explosion:give_local_player_dmg(position, damage_radius, player_damage)
	managers.explosion:explode_on_client(position, math.UP, nil, damage, damage_radius, curve_pow, custom_params)
end

function TurretWeapon:adjust_target_pos(target_pos)
	return target_pos
end

function TurretWeapon:get_damage()
	if self._puppet_unit then
		return self._damage_npc
	else
		return self._damage
	end
end

function TurretWeapon:mode()
	return self._mode
end
