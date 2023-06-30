SentryGunWeapon = SentryGunWeapon or class()
local tmp_rot1 = Rotation()

-- Lines 5-39
function SentryGunWeapon:init(unit)
	self._unit = unit
	self._timer = TimerManager:game()
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("a_detect"))
	self._effect_align = {
		self._unit:get_object(Idstring("fire")),
		self._unit:get_object(Idstring("fire"))
	}

	if self._laser_align_name then
		self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
	end

	self._interleaving_fire = 1
	self._trail_effect_table = {
		effect = RaycastWeaponBase.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._ammo_sync_resolution = 100

	if Network:is_server() then
		self._ammo_total = 1
		self._ammo_max = self._ammo_total
		self._ammo_sync = 100
	else
		self._ammo_total = 1
		self._ammo_max = self._ammo_total
		self._ammo_ratio = 1
	end

	self._spread_mul = 1
end

-- Lines 43-71
function SentryGunWeapon:_init()
	self._name_id = self._unit:base():get_name_id()
	self._tweak_data = tweak_data.weapon[self._name_id]
	self._bullet_slotmask = managers.slot:get_mask(Network:is_server() and "bullet_impact_targets" or "bullet_blank_impact_targets")
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._muzzle_effect = Idstring(self._tweak_data.muzzleflash or "effects/vanilla/weapons/muzzleflash_maingun")
	self._muzzle_effect_table = {
		{
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._effect_align[1]
		},
		{
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._effect_align[2]
		}
	}
	self._use_shell_ejection_effect = _G.IS_PC

	if self._use_shell_ejection_effect then
		self._obj_shell_ejection = self._unit:get_object(Idstring("shell"))
		self._shell_ejection_effect = Idstring(tweak_data.weapon[self._name_id].shell_ejection or "effects/vanilla/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._damage = self._tweak_data.DAMAGE
	self._alert_events = {}
	self._alert_size = self._tweak_data.alert_size
	self._alert_fires = {}
	self._suppression = self._tweak_data.SUPPRESSION
end

-- Lines 75-98
function SentryGunWeapon:setup(setup_data, damage_multiplier)
	self:_init()

	self._setup = setup_data
	self._owner = setup_data.user_unit
	self._damage = tweak_data.weapon[self._name_id].DAMAGE * damage_multiplier
	self._spread_mul = setup_data.spread_mul
	self._auto_reload = setup_data.auto_reload

	if setup_data.alert_AI then
		self._alert_events = {}
		self._alert_size = tweak_data.weapon[self._name_id].alert_size
		self._alert_fires = {}
	else
		self._alert_events = nil
		self._alert_size = nil
		self._alert_fires = nil
	end

	if setup_data.bullet_slotmask then
		self._bullet_slotmask = setup_data.bullet_slotmask
	end
end

-- Lines 102-112
function SentryGunWeapon:update(unit, t, dt)
	if self._blink_start_t then
		local period = 0.55
		local phase = (t - self._blink_start_t) % period / period

		if phase < 0.5 then
			self._laser_unit:base():set_on()
		else
			self._laser_unit:base():set_off()
		end
	end
end

-- Lines 116-119
function SentryGunWeapon:set_ammo(amount)
	self._ammo_total = amount
	self._ammo_max = math.max(self._ammo_max, amount)
end

-- Lines 123-136
function SentryGunWeapon:_setup_contour()
	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
		return
	end

	if self._unit:contour() and self:out_of_ammo() then
		self._unit:contour():remove("deployable_active")

		if managers.player:has_category_upgrade("sentry_gun", "can_reload") then
			self._unit:contour():add("deployable_disabled")
		end
	end
end

-- Lines 140-156
function SentryGunWeapon:change_ammo(amount)
	self._ammo_total = math.min(math.ceil(self._ammo_total + amount), self._ammo_max)
	local ammo_percent = self._ammo_total / self._ammo_max
	local resolution_step = math.ceil(ammo_percent / self._ammo_sync_resolution)

	self:_setup_contour()

	if ammo_percent == 0 or resolution_step ~= self._ammo_sync then
		self._ammo_sync = resolution_step

		self._unit:network():send("sentrygun_ammo", self._ammo_sync)

		if self._unit:interaction() then
			self._unit:interaction():set_dirty(true)
		end
	end
end

-- Lines 159-169
function SentryGunWeapon:sync_ammo(ammo_ratio)
	self._ammo_ratio = ammo_ratio * self._ammo_sync_resolution

	self._unit:base():set_waiting_for_refill(false)

	if self._unit:interaction() then
		self._unit:interaction():set_dirty(true)
	end

	self:_setup_contour()
end

-- Lines 173-175
function SentryGunWeapon:set_spread_mul(spread_mul)
	self._spread_mul = spread_mul
end

-- Lines 179-187
function SentryGunWeapon:start_autofire()
	if self._shooting then
		return
	end

	self:_sound_autofire_start()

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
	self._fire_start_t = self._timer:time()
end

-- Lines 191-205
function SentryGunWeapon:stop_autofire()
	if not self._shooting then
		return
	end

	if self:out_of_ammo() then
		self:_sound_autofire_end_empty()
	elseif self._timer:time() - self._fire_start_t > 3 then
		self:_sound_autofire_end_cooldown()
	else
		self:_sound_autofire_end()
	end

	self._shooting = nil
end

-- Lines 209-219
function SentryGunWeapon:trigger_held(blanks, expend_ammo, shoot_player, target_unit)
	local fired = nil

	if self._next_fire_allowed <= self._timer:time() then
		fired = self:fire(blanks, expend_ammo, shoot_player, target_unit)

		if fired then
			self._next_fire_allowed = self._next_fire_allowed + tweak_data.weapon[self._name_id].auto.fire_rate
			self._interleaving_fire = self._interleaving_fire == 1 and 2 or 1
		end
	end

	return fired
end

-- Lines 223-248
function SentryGunWeapon:fire(blanks, expend_ammo, shoot_player, target_unit)
	if expend_ammo then
		if self._ammo_total <= 0 then
			return
		end

		self:change_ammo(-1)
	end

	local fire_obj = self._effect_align[self._interleaving_fire]
	local from_pos = fire_obj:position()
	local direction = fire_obj:rotation():y()

	mvector3.spread(direction, tweak_data.weapon[self._name_id].SPREAD * self._spread_mul)
	World:effect_manager():spawn(self._muzzle_effect_table[self._interleaving_fire])

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	local ray_res = self:_fire_raycast(from_pos, direction, shoot_player, target_unit)

	if self._alert_events and ray_res.rays then
		RaycastWeaponBase._check_alert(self, ray_res.rays, from_pos, direction, self._unit)
	end

	self._unit:movement():give_recoil()

	return ray_res
end

local mvec_to = Vector3()

-- Lines 253-293
function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
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
			local damage = self:_apply_dmg_mul(self._damage, col_ray or player_ray_data, from_pos)

			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, self._unit, damage)
		end
	end

	local char_hit = nil

	if not player_hit and col_ray then
		local damage = self:_apply_dmg_mul(self._damage, col_ray, from_pos)
		char_hit = InstantBulletBase:on_collision(col_ray, self._unit, self._unit, damage)
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

-- Lines 297-320
function SentryGunWeapon:_apply_dmg_mul(damage, col_ray, from_pos)
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

-- Lines 324-326
function SentryGunWeapon:_sound_autofire_start()
	self._autofire_sound_event = self._unit:sound_source():post_event(self._fire_start_snd_event)
end

-- Lines 330-336
function SentryGunWeapon:_sound_autofire_end()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	self._unit:sound_source():post_event(self._fire_stop_snd_event)
end

-- Lines 340-348
function SentryGunWeapon:_sound_autofire_end_empty()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	if self._depleted_snd_event then
		self._unit:sound_source():post_event(self._depleted_snd_event)
	end
end

-- Lines 352-359
function SentryGunWeapon:_sound_autofire_end_cooldown()
	if self._autofire_sound_event then
		self._autofire_sound_event:stop()

		self._autofire_sound_event = nil
	end

	self._unit:sound_source():post_event(self._fire_stop_snd_event)
	self._unit:sound_source():post_event(self._fire_cooldown_snd_event)
end

-- Lines 363-370
function SentryGunWeapon:_spawn_trail_effect(direction, col_ray)
	self._effect_align[self._interleaving_fire]:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

-- Lines 374-380
function SentryGunWeapon:out_of_ammo()
	if self._ammo_total then
		return self._ammo_total == 0
	else
		return self._ammo_ratio == 0
	end
end

-- Lines 384-390
function SentryGunWeapon:ammo_ratio()
	if self._ammo_total then
		return self._ammo_total / self._ammo_max
	else
		return self._ammo_ratio
	end
end

-- Lines 394-396
function SentryGunWeapon:ammo_total()
	return self._ammo_total
end

-- Lines 400-402
function SentryGunWeapon:ammo_max()
	return self._ammo_max
end

-- Lines 406-408
function SentryGunWeapon:can_auto_reload()
	return self._auto_reload
end

-- Lines 412-414
function SentryGunWeapon:on_team_set(team_data)
	self._foe_teams = team_data.foes
end

-- Lines 418-444
function SentryGunWeapon:set_laser_enabled(mode, blink)
	if mode then
		self:_set_laser_state(true)

		if mode ~= self._laser_unit:base():theme_type() then
			self._laser_unit:base():set_color_by_theme(mode)
		end

		if blink then
			if not self._blink_start_t then
				self._blink_start_t = TimerManager:game():time()

				self._unit:set_extension_update_enabled(Idstring("weapon"), true)
			end
		else
			self._laser_unit:base():set_on()

			self._blink_start_t = nil

			self._unit:set_extension_update_enabled(Idstring("weapon"), false)
		end
	elseif alive(self._laser_unit) then
		self:_set_laser_state(false)

		if self._blink_start_t then
			self._blink_start_t = nil

			self._unit:set_extension_update_enabled(Idstring("weapon"), false)
		end
	end
end

-- Lines 448-449
function SentryGunWeapon:_set_laser_state(state)
end

-- Lines 453-455
function SentryGunWeapon:has_laser()
	return false
end

-- Lines 459-483
function SentryGunWeapon:update_laser()
	if not self:has_laser() then
		return
	end

	local laser_mode, blink = nil

	if self._unit:character_damage():dead() then
		-- Nothing
	elseif self._unit:movement():is_activating() then
		laser_mode = "turret_module_active"
	elseif self._unit:movement():is_inactivating() then
		laser_mode = "turret_module_active"
		blink = true
	elseif self._unit:movement():is_inactivated() then
		laser_mode = nil
	elseif self._unit:movement():rearming() then
		laser_mode = "turret_module_rearming"
		blink = true
	elseif self._unit:movement():team().foes[tweak_data.levels:get_default_team_ID("player")] then
		laser_mode = "turret_module_active"
	else
		laser_mode = "turret_module_mad"
	end

	self:set_laser_enabled(laser_mode, blink)
end

-- Lines 487-498
function SentryGunWeapon:save(save_data)
	local my_save_data = {}
	save_data.weapon = my_save_data

	if self._spread_mul ~= 1 then
		my_save_data.spread_mul = self._spread_mul
	end

	my_save_data.ammo_ratio = self:ammo_ratio()
	my_save_data.foe_teams = self._foe_teams
	my_save_data.auto_reload = self._auto_reload
	my_save_data.alert = self._alert_events and true or nil
end

-- Lines 502-521
function SentryGunWeapon:load(save_data)
	self._name_id = self._unit:base():get_name_id()

	self:_init()

	local my_save_data = save_data.weapon
	self._ammo_ratio = my_save_data.ammo_ratio or self._ammo_ratio
	self._spread_mul = my_save_data.spread_mul or 1
	self._foe_teams = my_save_data.foe_teams
	self._auto_reload = my_save_data.auto_reload
	self._setup = {
		ignore_units = {
			self._unit
		}
	}

	if not my_save_data.alert then
		self._alert_events = nil
	end
end

-- Lines 525-527
function SentryGunWeapon:destroy(unit)
	self:_set_laser_state(nil)
end

-- Lines 531-533
function SentryGunWeapon:weapon_tweak_data()
	return tweak_data.weapon[self._name_id]
end

-- Lines 537-539
function SentryGunWeapon:adjust_target_pos(target_pos)
	return target_pos
end
