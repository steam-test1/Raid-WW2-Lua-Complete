NPCRaycastWeaponBase = NPCRaycastWeaponBase or class(RaycastWeaponBase)
NPCRaycastWeaponBase._VOICES = {
	"a",
	"b",
	"c"
}
NPCRaycastWeaponBase._next_i_voice = {}

-- Lines 5-74
function NPCRaycastWeaponBase:init(unit)
	RaycastWeaponBase.super.init(self, unit, false)

	self._unit = unit
	self._name_id = self.name_id or "thomspon_npc"
	self.name_id = nil
	self._bullet_slotmask = managers.slot:get_mask("bullet_impact_targets")
	self._blank_slotmask = managers.slot:get_mask("bullet_blank_impact_targets")

	self:_create_use_setups()

	self._setup = {}
	self._digest_values = false

	self:set_ammo_max(tweak_data.weapon[self._name_id].AMMO_MAX)
	self:set_ammo_total(self:get_ammo_max())
	self:set_ammo_max_per_clip(tweak_data.weapon[self._name_id].CLIP_AMMO_MAX)
	self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())

	self._damage = tweak_data.weapon[self._name_id].DAMAGE
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("fire"))
	self._sound_fire = SoundDevice:create_source("fire")

	self._sound_fire:link(self._unit:orientation_object())

	self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/vanilla/weapons/muzzleflash_maingun")
	self._muzzle_effect_table = {
		force_synch = false,
		effect = self._muzzle_effect,
		parent = self._obj_fire
	}
	self._use_shell_ejection_effect = self:ejects_shells() and SystemInfo:platform() == Idstring("WIN32")

	if self._use_shell_ejection_effect then
		self._obj_shell_ejection = self._unit:get_object(Idstring("a_shell"))
		self._shell_ejection_effect = Idstring(self:weapon_tweak_data().shell_ejection or "effects/vanilla/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._trail_effect_table = {
		effect = self.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._flashlight_light_lod_enabled = true

	if false and self._multivoice then
		if not NPCRaycastWeaponBase._next_i_voice[self._name_id] then
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		end

		self._voice = NPCRaycastWeaponBase._VOICES[NPCRaycastWeaponBase._next_i_voice[self._name_id]]

		if NPCRaycastWeaponBase._next_i_voice[self._name_id] == #NPCRaycastWeaponBase._VOICES then
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		else
			NPCRaycastWeaponBase._next_i_voice[self._name_id] = NPCRaycastWeaponBase._next_i_voice[self._name_id] + 1
		end
	else
		self._voice = "a"
	end

	if self._unit:get_object(Idstring("ls_flashlight")) then
		self._flashlight_data = {
			light = self._unit:get_object(Idstring("ls_flashlight")),
			effect = self._unit:effect_spawner(Idstring("flashlight"))
		}

		self._flashlight_data.light:set_far_range(400)
		self._flashlight_data.light:set_spot_angle_end(25)
		self._flashlight_data.light:set_multiplier(2)
	end

	if tweak_data.weapon[self._name_id].has_suppressor then
		self._sound_fire:set_switch("suppressed", tweak_data.weapon[self._name_id].has_suppressor)
	end
end

-- Lines 80-98
function NPCRaycastWeaponBase:setup(setup_data)
	self._autoaim = setup_data.autoaim
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_size = tweak_data.weapon[self._name_id].alert_size
	self._alert_fires = {}
	self._suppression = tweak_data.weapon[self._name_id].suppression
	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._hit_player = setup_data.hit_player and true or false
	self._setup = setup_data
	self._setup.user_sound_variant = 1
end

-- Lines 102-106
function NPCRaycastWeaponBase:start_autofire(nr_shots)
	self:_sound_autofire_start(nr_shots)

	self._next_fire_allowed = math.max(self._next_fire_allowed, Application:time())
	self._shooting = true
end

-- Lines 109-111
function NPCRaycastWeaponBase:fire_mode()
	return tweak_data.weapon[self._name_id].auto and "auto" or "single"
end

-- Lines 113-115
function NPCRaycastWeaponBase:recoil_wait()
	return self:fire_mode() == "auto" and self:weapon_tweak_data().auto.fire_rate or nil
end

-- Lines 119-125
function NPCRaycastWeaponBase:stop_autofire()
	if not self._shooting then
		return
	end

	self:_sound_autofire_end()

	self._shooting = nil
end

-- Lines 129-135
function NPCRaycastWeaponBase:singleshot(...)
	local fired = self:fire(...)

	if fired then
		self:_sound_singleshot()
	end

	return fired
end

-- Lines 139-148
function NPCRaycastWeaponBase:trigger_held(...)
	local fired = nil

	if self._next_fire_allowed <= Application:time() then
		fired = self:fire(...)

		if fired then
			self._next_fire_allowed = self._next_fire_allowed + tweak_data.weapon[self._name_id].auto.fire_rate
		end
	end

	return fired
end

-- Lines 152-154
function NPCRaycastWeaponBase:add_damage_multiplier(damage_multiplier)
	self._damage = self._damage * damage_multiplier
end

local mto = Vector3()
local mfrom = Vector3()
local mspread = Vector3()

-- Lines 161-200
function NPCRaycastWeaponBase:fire_blank(direction, impact)
	local user_unit = self._setup.user_unit

	self._unit:m_position(mfrom)

	local rays = {}

	if impact then
		mvector3.set(mspread, direction)
		mvector3.spread(mspread, 5)
		mvector3.set(mto, mspread)
		mvector3.multiply(mto, 20000)
		mvector3.add(mto, mfrom)

		local col_ray = World:raycast("ray", mfrom, mto, "slot_mask", self._blank_slotmask, "ignore_unit", self._setup.ignore_units)

		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mspread)

		local trail = (not col_ray or col_ray.distance > 650) and World:effect_manager():spawn(self._trail_effect_table) or nil

		if col_ray then
			local bullet_class = self._bullet_class or InstantBulletBase

			bullet_class:on_collision(col_ray, self._unit, user_unit, self._damage, true)

			if trail then
				World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
			end

			table.insert(rays, col_ray)
		end
	end

	World:effect_manager():spawn(self._muzzle_effect_table)
	self:_sound_singleshot()
end

-- Lines 204-210
function NPCRaycastWeaponBase:destroy(unit)
	RaycastWeaponBase.super.pre_destroy(self, unit)

	if self._shooting then
		self:stop_autofire()
	end
end

-- Lines 214-215
function NPCRaycastWeaponBase:_get_spread(user_unit)
end

-- Lines 219-231
function NPCRaycastWeaponBase:_sound_autofire_start(nr_shots)
	local tweak_sound = tweak_data.weapon[self._name_id].sounds

	if tweak_sound and tweak_sound.autofire_start then
		self._sound_fire:post_event(tweak_sound.autofire_start)
	else
		self._sound_fire:post_event("thompson_fire_npc")
	end
end

-- Lines 235-245
function NPCRaycastWeaponBase:_sound_autofire_end()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds

	if tweak_sound and tweak_sound.autofire_stop then
		self._sound_fire:post_event(tweak_sound.autofire_stop)
	else
		self._sound_fire:post_event("thompson_fire_npc_stop")
	end
end

-- Lines 249-259
function NPCRaycastWeaponBase:_sound_singleshot()
	local tweak_sound = tweak_data.weapon[self._name_id].sounds
	local sound_name = tweak_sound.single

	if sound_name then
		self._sound_fire:post_event(sound_name)
	else
		Application:error("[NPCRaycastWeaponBase] The singleshot sound has not been set for weapon: ", self._name_id)
	end
end

local mvec_to = Vector3()

-- Lines 264-324
function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, target_unit)
	local enemy_type = ""

	if user_unit and user_unit:base() and user_unit:base()._tweak_table and tweak_data.character[user_unit:base()._tweak_table] then
		enemy_type = tweak_data.character[user_unit:base()._tweak_table].type
	end

	local character_data = managers.criminals:character_data_by_unit(user_unit)
	local is_team_ai = character_data ~= nil

	if not is_team_ai and managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE) then
		local effect_value_enemy_damage_modifier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE)
		dmg_mul = dmg_mul * effect_value_enemy_damage_modifier
	end

	local result = {}
	local hit_unit = nil

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, 20000)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local bullet_class = self._bullet_class or InstantBulletBase
	local player_hit, player_ray_data = nil

	if shoot_player and self._hit_player then
		player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction)

		if player_hit then
			bullet_class:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
		end
	end

	local char_hit = nil

	if not player_hit and col_ray then
		char_hit = bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
	end

	if not col_ray or col_ray.distance > 600 then
		self:_spawn_trail_effect(direction, col_ray)
	end

	result.hit_enemy = char_hit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	return result
end

-- Lines 328-336
function NPCRaycastWeaponBase:_spawn_trail_effect(direction, col_ray)
	self._obj_fire:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
	end
end

-- Lines 340-342
function NPCRaycastWeaponBase:has_flashlight_on()
	return self._flashlight_data and self._flashlight_data.on and true or false
end

-- Lines 344-346
function NPCRaycastWeaponBase:flashlight_data()
	return self._flashlight_data
end

-- Lines 348-366
function NPCRaycastWeaponBase:flashlight_state_changed()
	if not self._flashlight_data then
		return
	end

	if not self._flashlight_data.enabled or self._flashlight_data.dropped then
		return
	end

	if managers.game_play_central:flashlights_on() then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

-- Lines 368-384
function NPCRaycastWeaponBase:set_flashlight_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	self._flashlight_data.enabled = enabled

	if managers.game_play_central:flashlights_on() and enabled then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

-- Lines 386-398
function NPCRaycastWeaponBase:set_flashlight_light_lod_enabled(enabled)
	if not self._flashlight_data then
		return
	end

	self._flashlight_light_lod_enabled = enabled

	if self._flashlight_data.on and enabled then
		self._flashlight_data.light:set_enable(true)
	else
		self._flashlight_data.light:set_enable(false)
	end
end

-- Lines 400-401
function NPCRaycastWeaponBase:set_laser_enabled(state)
end
