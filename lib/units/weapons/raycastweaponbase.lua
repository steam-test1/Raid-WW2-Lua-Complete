local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()
RaycastWeaponBase = RaycastWeaponBase or class(UnitBase)
RaycastWeaponBase.TRAIL_EFFECT = Idstring("effects/vanilla/weapons/weapon_trail")
RaycastWeaponBase.RICOCHET_DISTANCE = 2000
RaycastWeaponBase.RICOCHET_FALLOFF = 0.75

function RaycastWeaponBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._name_id = self.name_id or "test_raycast_weapon"
	self.name_id = nil

	self:_create_use_setups()

	self._setup = {}
	self._digest_values = _G.IS_PC
	self._ammo_data = false
	local dont_replenish = false

	if not dont_replenish then
		self:replenish()
	end

	self.can_use_aim_assist = true
	self._aim_assist_data = tweak_data.weapon[self._name_id].aim_assist
	self._autohit_data = tweak_data.weapon[self._name_id].autohit
	self._autohit_current = self._autohit_data.INIT_RATIO
	self._shoot_through_data = {
		kills = 0,
		from = Vector3()
	}
	self._can_shoot_through_shield = tweak_data.weapon[self._name_id].can_shoot_through_shield
	self._can_shoot_through_enemy = tweak_data.weapon[self._name_id].can_shoot_through_enemy
	self._can_shoot_through_wall = tweak_data.weapon[self._name_id].can_shoot_through_wall
	self._bullet_class = InstantBulletBase
	self._bullet_slotmask = self._bullet_class:bullet_slotmask()
	self._blank_slotmask = self._bullet_class:blank_slotmask()
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("fire"))
	self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/vanilla/weapons/muzzleflash_maingun")
	self._muzzle_effect_table = {
		force_synch = true,
		effect = self._muzzle_effect,
		parent = self._obj_fire
	}
	self._muzzletrail_effect = self:weapon_tweak_data().muzzletrail and Idstring(self:weapon_tweak_data().muzzletrail) or false

	if self._muzzletrail_effect then
		self._muzzletrail_effect_table = {
			force_synch = true,
			effect = self._muzzletrail_effect,
			parent = self._obj_fire
		}
	end

	if self:ejects_shells() then
		self._use_shell_ejection_effect = true
		self._obj_shell_ejection = self._unit:get_object(Idstring("a_shell"))
		self._shell_ejection_effect = Idstring(self:weapon_tweak_data().shell_ejection or "effects/vanilla/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._sound_fire = SoundDevice:create_source("fire")

	self._sound_fire:link(self._unit:orientation_object())

	self._trail_effect_table = {
		effect = self.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._shot_fired_stats_table = {
		hit = false,
		weapon_unit = self._unit
	}
	self._ammo_pickup_amount = tweak_data.weapon[self._name_id].ammo_pickup_base or tweak_data.weapon.default_values.ammo_pickup_base
	self.effect_failed_check = false
end

function RaycastWeaponBase:change_fire_object(new_obj)
	self._obj_fire = new_obj
	self._muzzle_effect_table.parent = new_obj

	if self._muzzletrail_effect then
		self._muzzletrail_effect_table.parent = new_obj
	end
end

function RaycastWeaponBase:get_name_id()
	return self._name_id
end

function RaycastWeaponBase:is_melee_weapon()
	return false
end

function RaycastWeaponBase:get_weapon_hud_type()
	return false
end

function RaycastWeaponBase:has_part(part_id)
	return false
end

function RaycastWeaponBase:ejects_shells()
	return true
end

function RaycastWeaponBase:weapon_tweak_data()
	return tweak_data.weapon[self._name_id]
end

function RaycastWeaponBase:selection_index()
	return self:weapon_tweak_data().use_data.selection_index
end

function RaycastWeaponBase:get_stance_id()
	return self:weapon_tweak_data().use_stance or self:get_name_id()
end

function RaycastWeaponBase:movement_penalty()
	return tweak_data.upgrades.weapon_movement_penalty[self:weapon_tweak_data().category] or 1
end

function RaycastWeaponBase:armor_piercing_chance()
	return self:weapon_tweak_data().armor_piercing_chance or 0
end

function RaycastWeaponBase:got_silencer()
	return false
end

function RaycastWeaponBase:_create_use_setups()
	local sel_index = tweak_data.weapon[self._name_id].use_data.selection_index
	local align_place = tweak_data.weapon[self._name_id].use_data.align_place or "right_hand"
	local use_data = {}
	self._use_data = use_data
	local player_setup = {}
	use_data.player = player_setup
	player_setup.selection_index = sel_index
	player_setup.equip = {
		align_place = align_place
	}
	player_setup.unequip = {
		align_place = "back"
	}
	local npc_setup = {}
	use_data.npc = npc_setup
	npc_setup.selection_index = sel_index
	npc_setup.equip = {
		align_place = align_place
	}
	npc_setup.unequip = {}
end

function RaycastWeaponBase:get_use_data(character_setup)
	return self._use_data[character_setup]
end

function RaycastWeaponBase:setup(setup_data)
	self._autoaim = setup_data.autoaim
	local stats = tweak_data.weapon[self._name_id].stats
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_fires = {}
	local weapon_stats = tweak_data.weapon.stats

	if stats then
		self._zoom = self._zoom or weapon_stats.zoom[stats.zoom]
		self._alert_size = self._alert_size or weapon_stats.alert_size[stats.alert_size]
		self._suppression = self._suppression or weapon_stats.suppression[stats.suppression]
		self._spread = self._spread or weapon_stats.spread[stats.spread]
		self._recoil = self._recoil or weapon_stats.recoil[stats.recoil]
		self._spread_moving = self._spread_moving or weapon_stats.spread_moving[stats.spread_moving]
		self._concealment = self._concealment or weapon_stats.concealment[stats.concealment]
		self._value = self._value or weapon_stats.value[stats.value]

		for i, _ in pairs(weapon_stats) do
			local stat = self["_" .. tostring(i)]

			if not stat then
				self["_" .. tostring(i)] = weapon_stats[i][5]

				debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stat \"" .. tostring(i) .. "\"!")
			end
		end
	else
		debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stats block!")

		self._zoom = 60
		self._alert_size = 5000
		self._suppression = 1
		self._spread = 1
		self._recoil = 1
		self._spread_moving = 1
	end

	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._panic_suppression_chance = setup_data.panic_suppression_skill and self:weapon_tweak_data().panic_suppression_chance

	if self._panic_suppression_chance == 0 then
		self._panic_suppression_chance = false
	end

	self._setup = setup_data
	self._fire_mode = self._fire_mode or tweak_data.weapon[self._name_id].FIRE_MODE or "single"

	if self._setup.timer then
		self:set_timer(self._setup.timer)
	end
end

function RaycastWeaponBase:in_steelsight()
	local user_unit = self._setup and self._setup.user_unit
	local current_state = user_unit:movement()._current_state

	return current_state:in_steelsight()
end

function RaycastWeaponBase:fire_mode()
	if not self._fire_mode then
		self._fire_mode = tweak_data.weapon[self._name_id].FIRE_MODE or "single"
	end

	return self._fire_mode
end

function RaycastWeaponBase:fire_on_release()
	return false
end

function RaycastWeaponBase:dryfire()
	self:play_tweak_data_sound("dryfire")
end

function RaycastWeaponBase:recoil_wait()
	return tweak_data.weapon[self._name_id].FIRE_MODE == "auto" and self:weapon_tweak_data().fire_mode_data.fire_rate or nil
end

function RaycastWeaponBase:_fire_sound()
	self:play_tweak_data_sound(self:fire_mode() == "auto" and "fire_auto" or "fire_single", "fire")
end

function RaycastWeaponBase:start_shooting_allowed()
	return self._next_fire_allowed <= self._unit:timer():time()
end

function RaycastWeaponBase:shooting()
	return self._shooting
end

function RaycastWeaponBase:start_shooting()
	self:_fire_sound()

	self._next_fire_allowed = math.max(self._next_fire_allowed, self._unit:timer():time())
	self._shooting = true
end

function RaycastWeaponBase:stop_shooting()
	self:play_tweak_data_sound("stop_fire")

	self._shooting = nil
	self._kills_without_releasing_trigger = nil
end

function RaycastWeaponBase:trigger_pressed(...)
	local fired = nil

	if self:start_shooting_allowed() then
		fired = self:fire(...)

		if fired then
			local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
			self._next_fire_allowed = self._next_fire_allowed + next_fire
		end
	end

	return fired
end

function RaycastWeaponBase:trigger_held(...)
	local fired = nil

	if self._next_fire_allowed <= self._unit:timer():time() then
		fired = self:fire(...)

		if fired then
			self._next_fire_allowed = self._next_fire_allowed + (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
		end
	end

	return fired
end

function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CAN_ONLY_USE_WEAPON_CATEGORY) and self._setup.user_unit == managers.player:local_player() then
		local weapon_category_allowed = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_CAN_ONLY_USE_WEAPON_CATEGORY)

		if self:weapon_tweak_data().category ~= weapon_category_allowed then
			managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYER_CAN_ONLY_USE_WEAPON_CATEGORY, managers.network:session():local_peer():id())
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		managers.player:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if managers.player:has_category_upgrade("temporary", "no_ammo_cost") then
			managers.player:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end

	local consume_ammo = true

	if self._setup.user_unit == managers.player:player_unit() then
		consume_ammo = consume_ammo or not managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost"))
		consume_ammo = consume_ammo and not managers.player:has_category_upgrade("player", "warcry_no_reloads")
		local active_warcry = managers.warcry:get_active_warcry()

		if managers.warcry:active() and active_warcry.check_ammo_consumption then
			local warcry_consume_ammo = active_warcry:check_ammo_consumption()
			consume_ammo = consume_ammo and warcry_consume_ammo
		end
	end

	local base = self.parent_weapon and self.parent_weapon:base() or self

	if consume_ammo then
		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local ammo_usage = 1

		if managers.player:has_category_upgrade(self:weapon_tweak_data().category, "consume_no_ammo_chance") then
			local roll = math.rand(1)
			local chance = managers.player:upgrade_value(self:weapon_tweak_data().category, "consume_no_ammo_chance", 0)

			if roll < chance then
				ammo_usage = 0
			end
		end

		if self._setup.user_unit == managers.player:player_unit() and managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_AMMO_COST) then
			ammo_usage = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_AMMO_COST) or 1
		end

		local clip = base:get_ammo_remaining_in_clip()

		base:set_ammo_remaining_in_clip(clip - ammo_usage)

		if clip > 0 and clip - ammo_usage == 0 then
			if self._setup.user_unit == managers.player:player_unit() then
				if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYERS_CANT_EMPTY_CLIPS) then
					managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYERS_CANT_EMPTY_CLIPS, managers.network:session():local_peer():id())
				end

				if self:get_ammo_total() - ammo_usage == 0 then
					managers.hud:set_prompt("hud_no_ammo_prompt", utf8.to_upper(managers.localization:text("hint_no_ammo")))
				else
					managers.hud:set_prompt("hud_reload_prompt", utf8.to_upper(managers.localization:text("hint_reload", {
						BTN_RELOAD = managers.localization:btn_macro("reload")
					})))
				end
			end

			if self:weapon_tweak_data().animations and self:weapon_tweak_data().animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
				self:play_tweak_data_sound("magazine_empty")
			end
		end

		if self._setup.user_unit == managers.player:player_unit() and base:get_ammo_remaining_in_clip() == base:get_ammo_max_per_clip() and ammo_usage < 0 then
			ammo_usage = 0
		end

		local total = base:get_ammo_total()

		base:set_ammo_total(total - ammo_usage)

		local selection_index = self._use_data.player.selection_index

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_SHOOTING_PRIMARY_WEAPON_CONSUMES_BOTH_AMMOS) and self._setup.user_unit == managers.player:player_unit() and selection_index == 2 then
			local secondary_weapon_base_weapon = managers.player:player_unit():inventory():available_selections()[1].unit:base()
			local secondary_ammo_total = secondary_weapon_base_weapon:get_ammo_total()
			local secondary_ammo_clip = secondary_weapon_base_weapon:get_ammo_remaining_in_clip()

			if secondary_ammo_clip > 0 then
				secondary_weapon_base_weapon:set_ammo_remaining_in_clip(secondary_ammo_clip - ammo_usage)
			end

			secondary_weapon_base_weapon:set_ammo_total(secondary_ammo_total - ammo_usage)
			managers.hud:set_ammo_amount(1, secondary_weapon_base_weapon:ammo_info())
		end

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_SHOOTING_SECONDARY_WEAPON_FILLS_PRIMARY_AMMO) and self._setup.user_unit == managers.player:player_unit() and selection_index == 1 then
			local primary_weapon_base_weapon = managers.player:player_unit():inventory():available_selections()[2].unit:base()
			local primary_ammo_add_amount = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_SHOOTING_SECONDARY_WEAPON_FILLS_PRIMARY_AMMO) or 1
			local primary_ammo_current_total = primary_weapon_base_weapon:get_ammo_total()
			local primary_ammo_max = primary_weapon_base_weapon:get_ammo_max()
			local primary_ammo_max_per_clip = primary_weapon_base_weapon:calculate_ammo_max_per_clip()
			local primary_ammo_current_clip = primary_weapon_base_weapon:get_ammo_remaining_in_clip()

			if primary_ammo_max_per_clip - primary_ammo_current_clip > 0 then
				local max_ammo_to_add_in_clip = primary_ammo_max_per_clip - primary_ammo_current_clip

				if primary_ammo_add_amount > max_ammo_to_add_in_clip then
					primary_weapon_base_weapon:set_ammo_remaining_in_clip(primary_ammo_max_per_clip)
				else
					primary_weapon_base_weapon:set_ammo_remaining_in_clip(primary_ammo_add_amount + primary_ammo_current_clip)
				end
			end

			if primary_ammo_max - primary_ammo_current_total > 0 then
				local max_ammo_to_add = primary_ammo_max - primary_ammo_current_total

				if primary_ammo_add_amount > max_ammo_to_add then
					primary_weapon_base_weapon:set_ammo_total(primary_ammo_max)
				else
					primary_weapon_base_weapon:set_ammo_total(primary_ammo_current_total + primary_ammo_add_amount)
				end
			end

			managers.hud:set_ammo_amount(2, primary_weapon_base_weapon:ammo_info())
		end
	end

	if self._setup.user_unit == managers.player:player_unit() and managers.player:has_category_upgrade("player", "warcry_refill_clip") and not base:clip_full() then
		base:add_ammo(1, 1)
		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() + 1)
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	if alive(self._obj_fire) and self._muzzletrail_effect then
		for _, ray in ipairs(ray_res.rays) do
			local trail_direction = Vector3.normalized(ray.position - from_pos)

			self:_spawn_muzzletrail_effect(from_pos, trail_direction)
		end
	end

	if ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end

	return ray_res
end

function RaycastWeaponBase:_spawn_muzzle_effect(from_pos, dir)
	World:effect_manager():spawn(self._muzzle_effect_table)
end

function RaycastWeaponBase:_spawn_muzzletrail_effect(from_pos, dir)
	World:effect_manager():spawn(self._muzzletrail_effect_table)
end

function RaycastWeaponBase:_check_ammo_total(unit)
	if self:get_ammo_total() <= 0 and unit:base().is_local_player and unit:inventory():all_out_of_ammo() then
		PlayerStandard.say_line(unit:sound(), "g81x_plu")
	end
end

function RaycastWeaponBase:get_damage_falloff(col_ray, user_unit)
	if not col_ray or type(col_ray) ~= "table" then
		return 0
	end

	local distance = col_ray.distance or col_ray.unit and mvector3.distance(col_ray.unit:position(), user_unit:position()) or 0
	local damage_profile = self:weapon_tweak_data().damage_profile

	if damage_profile then
		local current_idx = #damage_profile
		local prev_idx = nil

		for i, profile in ipairs(damage_profile) do
			if distance <= profile.range then
				current_idx = i
				prev_idx = i - 1

				break
			end
		end

		if prev_idx == nil or prev_idx < 1 then
			return damage_profile[current_idx].damage * self:damage_multiplier(), distance
		else
			local a = damage_profile[current_idx - 1]
			local b = damage_profile[current_idx]
			local t = (distance - a.range) / (b.range - a.range)

			return math.lerp(a.damage, b.damage, t) * self:damage_multiplier(), distance
		end
	else
		Application:error("No damage profile for weapon: ", self._name_id)

		return 1 * self:damage_multiplier(), distance
	end
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = {}
	local hit_unit = nil
	shoot_player = shoot_player or false
	self._weapon_range = self._weapon_range or 20000
	local spread = self:_get_spread(user_unit)

	mvector3.set(mvec_spread_direction, direction)

	if spread then
		mvector3.spread(mvec_spread_direction, spread * (spread_mul or 1))
	end

	local ray_distance = shoot_through_data and shoot_through_data.ray_distance or self._weapon_range

	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
	local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if shoot_through_data and shoot_through_data.has_hit_wall then
		if not col_ray then
			return result
		end

		mvector3.set(mvec1, col_ray.ray)
		mvector3.multiply(mvec1, -5)
		mvector3.add(mvec1, col_ray.position)

		local ray_blocked = World:raycast("ray", mvec1, shoot_through_data.from, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report")

		if ray_blocked then
			return result
		end
	end

	local autoaim, suppression_enemies = self:check_autoaim(from_pos, direction)

	if self._autoaim then
		local weight = 0.1

		if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
			damage = self:get_damage_falloff(col_ray, user_unit)
			hit_unit = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
		elseif autoaim then
			local autohit_chance = 1
			autohit_chance = tweak_data.weapon[self._name_id].category == WeaponTweakData.WEAPON_CATEGORY_SNP and 1 or 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

			if autohit_mul then
				autohit_chance = autohit_chance * autohit_mul
			end

			if math.random() < autohit_chance then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)
				damage = self:get_damage_falloff(autoaim, user_unit)
				hit_unit = self._bullet_class:on_collision(autoaim, self._unit, user_unit, damage)
				col_ray = autoaim
			else
				self._autohit_current = self._autohit_current / (1 + weight)
			end
		elseif col_ray then
			damage = self:get_damage_falloff(col_ray, user_unit)
			hit_unit = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
		end

		self._shot_fired_stats_table.hit = hit_unit and true or false

		if (not shoot_through_data or hit_unit) and (not self._ammo_data or not self._ammo_data.ignore_statistic) and not self._rays then
			if ray_distance == self._weapon_range then
				self._shot_fired_stats_table.skip_bullet_count = shoot_through_data and true

				managers.statistics:shot_fired(self._shot_fired_stats_table)
			end
		else
			self._shot_fired_stats_table.skip_bullet_count = nil
		end
	elseif col_ray then
		damage = self:get_damage_falloff(col_ray, user_unit)
		hit_unit = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if suppression_enemies and self._suppression then
		result.enemies_in_cone = suppression_enemies
	end

	if (col_ray and col_ray.distance > 600 or not col_ray) and alive(self._obj_fire) then
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mvec_spread_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if col_ray then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
		end
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	if col_ray and col_ray.unit then
		local warcry_sniper_ricochet = tweak_data.weapon[self._name_id].category == WeaponTweakData.WEAPON_CATEGORY_SNP and managers.player:upgrade_value("player", "warcry_sniper_ricochet", false) == true

		repeat
			local kills, killed = nil

			if hit_unit then
				if not self._can_shoot_through_enemy and not warcry_sniper_ricochet then
					break
				end

				killed = hit_unit.type == "death"
				local unit_type = col_ray.unit:base() and col_ray.unit:base()._tweak_table
				local is_enemy = not CopDamage.is_civilian(unit_type)
				kills = (shoot_through_data and shoot_through_data.kills or 0) + (killed and is_enemy and 1 or 0)
			end

			self._shoot_through_data.kills = kills

			if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
				break
			end

			local has_hit_wall = shoot_through_data and shoot_through_data.has_hit_wall
			local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
			local is_shoot_through, is_shield, is_wall = nil

			if hit_unit then
				-- Nothing
			else
				local is_world_geometry = col_ray.unit:in_slot(managers.slot:get_mask("world_geometry"))

				if is_world_geometry then
					is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))

					if not is_shoot_through then
						if has_hit_wall or not self._can_shoot_through_wall then
							break
						end

						is_wall = true
					end
				else
					if not self._can_shoot_through_shield then
						break
					end

					is_shield = col_ray.unit:in_slot(8) and alive(col_ray.unit:parent())
				end
			end

			if not hit_unit and not is_shoot_through and not is_shield and not is_wall then
				break
			end

			local ray_from_unit = (hit_unit or is_shield) and col_ray.unit

			if is_shield then
				dmg_mul = (dmg_mul or 1) * 0.25
			end

			self._shoot_through_data.has_hit_wall = has_hit_wall or is_wall
			self._shoot_through_data.has_passed_shield = has_passed_shield or is_shield
			self._shoot_through_data.ray_from_unit = ray_from_unit
			self._shoot_through_data.ray_distance = ray_distance - col_ray.distance
			local is_ricocheting = killed and warcry_sniper_ricochet
			local closest_unit = is_ricocheting and self:_get_closest_target(col_ray.position, RaycastWeaponBase.RICOCHET_DISTANCE) or nil

			if is_ricocheting and closest_unit then
				self._shoot_through_data.ray_distance = math.min(RaycastWeaponBase.RICOCHET_DISTANCE, self._shoot_through_data.ray_distance * RaycastWeaponBase.RICOCHET_FALLOFF)
				local dir_to = closest_unit:movement():m_head_pos()

				mvector3.set(self._shoot_through_data.from, col_ray.position)
				mvector3.subtract(dir_to, self._shoot_through_data.from)
				mvector3.normalize(dir_to)
				managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, dir_to, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, self._shoot_through_data)
			else
				print("Shoot Through : Normal")
				mvector3.set(self._shoot_through_data.from, mvec_spread_direction)
				mvector3.multiply(self._shoot_through_data.from, is_shield and 5 or 40)
				mvector3.add(self._shoot_through_data.from, col_ray.position)
				managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, mvec_spread_direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, self._shoot_through_data)
			end
		until true
	end

	return result
end

function RaycastWeaponBase:_get_closest_target(position, radius)
	if not position or not radius then
		return nil
	end

	local units = World:find_units_quick("sphere", position, radius or 100, managers.slot:get_mask("trip_mine_targets"))

	if not units then
		return nil
	end

	local closest_target = nil
	local closest_target_distance = math.huge
	local team_id_player = tweak_data.levels:get_default_team_ID("player")

	for _, unit in ipairs(units) do
		if unit:movement() and unit:movement():team() then
			local team_id_ray = unit:movement():team().id

			if managers.groupai:state():team_data(team_id_player).foes[team_id_ray] then
				if not closest_target then
					closest_target = unit
				else
					local dis = mvector3.distance(closest_target:position(), unit:movement():m_head_pos())

					if closest_target_distance < dis then
						closest_target = unit
						closest_target_distance = dis
					end
				end
			end
		end
	end

	return closest_target
end

function RaycastWeaponBase:get_aim_assist(from_pos, direction, max_dist, use_aim_assist)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask
	local enemies = managers.enemy:all_enemies()

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit

		if enemy:base():lod_stage() == 1 and not enemy:in_slot(16) then
			local com = enemy:movement():m_com()

			mvec3_set(tar_vec, com)
			mvec3_sub(tar_vec, from_pos)

			local tar_aim_dot = mvec3_dot(direction, tar_vec)
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)

			if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < max_dist) then
				local error_dot = mvec3_dot(direction, tar_vec)
				local error_angle = math.acos(error_dot)
				local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
				local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

				if error_angle < autohit_min_angle then
					local percent_error = error_angle / autohit_min_angle

					if not closest_error or percent_error < closest_error then
						tar_vec_len = tar_vec_len + 100

						mvec3_mul(tar_vec, tar_vec_len)
						mvec3_add(tar_vec, from_pos)

						local vis_ray = World:raycast("ray", from_pos, tar_vec, "slot_mask", slotmask, "ignore_unit", ignore_units)

						if vis_ray and vis_ray.unit:key() == u_key and (not closest_error or error_angle < closest_error) then
							closest_error = error_angle
							closest_ray = vis_ray

							mvec3_set(tmp_vec1, com)
							mvec3_sub(tmp_vec1, from_pos)

							local d = mvec3_dot(direction, tmp_vec1)

							mvec3_set(tmp_vec1, direction)
							mvec3_mul(tmp_vec1, d)
							mvec3_add(tmp_vec1, from_pos)
							mvec3_sub(tmp_vec1, com)

							closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)
						end
					end
				end
			end
		end
	end

	return closest_ray
end

function RaycastWeaponBase:check_autoaim(from_pos, direction, max_dist, use_aim_assist)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask
	local enemies = managers.enemy:all_enemies()
	local suppression_near_angle = 50
	local suppression_far_angle = 5
	local suppression_enemies = nil

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit

		if enemy:base():lod_stage() == 1 and not enemy:in_slot(16) then
			local com = nil
			local wc_aim_head = managers.player:upgrade_value("player", "warcry_aim_assist_aim_at_head", false)

			if wc_aim_head == true and managers.player:get_current_state():in_steelsight() then
				com = enemy:movement():m_head_pos()
			else
				com = enemy:movement():m_com()
			end

			mvec3_set(tar_vec, com)
			mvec3_sub(tar_vec, from_pos)

			local tar_aim_dot = mvec3_dot(direction, tar_vec)

			if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < max_dist) then
				local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)
				local error_dot = mvec3_dot(direction, tar_vec)
				local error_angle = math.acos(error_dot)
				local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
				local suppression_min_angle = math_lerp(suppression_near_angle, suppression_far_angle, dis_lerp)

				if error_angle < suppression_min_angle then
					suppression_enemies = suppression_enemies or {}
					local percent_error = error_angle / suppression_min_angle
					suppression_enemies[enemy_data] = percent_error
				end

				local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)
				autohit_min_angle = autohit_min_angle * managers.player:upgrade_value("player", "warcry_aim_assist_radius", 1)

				if error_angle < autohit_min_angle then
					local percent_error = error_angle / autohit_min_angle

					if not closest_error or percent_error < closest_error then
						tar_vec_len = tar_vec_len + 100

						mvec3_mul(tar_vec, tar_vec_len)
						mvec3_add(tar_vec, from_pos)

						local vis_ray = World:raycast("ray", from_pos, tar_vec, "slot_mask", slotmask, "ignore_unit", ignore_units)

						if vis_ray and vis_ray.unit:key() == u_key and (not closest_error or error_angle < closest_error) then
							closest_error = error_angle
							closest_ray = vis_ray
						end
					end
				end
			end
		end
	end

	return closest_ray, suppression_enemies
end

local mvec_from_pos = Vector3()

function RaycastWeaponBase:_check_alert(rays, fire_pos, direction, user_unit)
	local group_ai = managers.groupai:state()
	local t = TimerManager:game():time()
	local exp_t = t + 1.5
	local mvec3_dis = mvector3.distance_sq
	local all_alerts = self._alert_events
	local alert_rad = self._alert_size / 4
	local from_pos = mvec_from_pos
	local tolerance = 250000

	mvector3.set(from_pos, direction)
	mvector3.multiply(from_pos, -alert_rad)
	mvector3.add(from_pos, fire_pos)

	for i = #all_alerts, 1, -1 do
		if all_alerts[i][3] < t then
			table.remove(all_alerts, i)
		end
	end

	if #rays > 0 then
		for _, ray in ipairs(rays) do
			local event_pos = ray.position

			for i = #all_alerts, 1, -1 do
				if mvec3_dis(all_alerts[i][1], event_pos) < tolerance and mvec3_dis(all_alerts[i][2], from_pos) < tolerance then
					event_pos = nil

					break
				end
			end

			if event_pos then
				table.insert(all_alerts, {
					event_pos,
					from_pos,
					exp_t
				})

				local new_alert = {
					"bullet",
					event_pos,
					alert_rad,
					self._setup.alert_filter,
					user_unit,
					from_pos
				}

				group_ai:propagate_alert(new_alert)
			end
		end
	end

	local fire_alerts = self._alert_fires
	local cached = false

	for i = #fire_alerts, 1, -1 do
		if fire_alerts[i][2] < t then
			table.remove(fire_alerts, i)
		elseif mvec3_dis(fire_alerts[i][1], fire_pos) < tolerance then
			cached = true

			break
		end
	end

	if not cached then
		table.insert(fire_alerts, {
			fire_pos,
			exp_t
		})

		local new_alert = {
			"bullet",
			fire_pos,
			self._alert_size,
			self._setup.alert_filter,
			user_unit,
			from_pos
		}

		group_ai:propagate_alert(new_alert)
	end
end

function RaycastWeaponBase:damage_player(col_ray, from_pos, direction)
	local unit = managers.player:player_unit()

	if not unit then
		return
	end

	local ray_data = {
		ray = direction,
		normal = -direction
	}
	local head_pos = unit:movement():m_head_pos()
	local head_dir = tmp_vec1
	local head_dis = mvec3_dir(head_dir, from_pos, head_pos)
	local shoot_dir = tmp_vec2

	mvec3_set(shoot_dir, col_ray and col_ray.ray or direction)

	local cos_f = mvec3_dot(shoot_dir, head_dir)

	if cos_f <= 0.1 then
		return
	end

	local b = head_dis / cos_f

	if not col_ray or b < col_ray.distance then
		if col_ray and b - col_ray.distance < 60 then
			unit:character_damage():build_suppression(self._suppression)
		end

		mvec3_set_l(shoot_dir, b)
		mvec3_mul(head_dir, head_dis)
		mvec3_sub(shoot_dir, head_dir)

		local proj_len = mvec3_len(shoot_dir)
		ray_data.position = head_pos + shoot_dir

		if not col_ray and proj_len < 60 then
			unit:character_damage():build_suppression(self._suppression)
		end

		if proj_len < 30 then
			if World:raycast("ray", from_pos, head_pos, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report") then
				return nil, ray_data
			else
				return true, ray_data
			end
		elseif proj_len < 100 and b > 500 and (not self.weapon_tweak_data or not self:weapon_tweak_data().no_whizby) then
			unit:character_damage():play_whizby(ray_data.position, self._unit:base().sentry_gun)
		end
	elseif b - col_ray.distance < 60 then
		unit:character_damage():build_suppression(self._suppression)
	end

	return nil, ray_data
end

function RaycastWeaponBase:force_hit(from_pos, direction, user_unit, impact_pos, impact_normal, hit_unit, hit_body)
	self:set_ammo_remaining_in_clip(math.max(0, self:get_ammo_remaining_in_clip() - 1))

	local col_ray = {
		position = impact_pos,
		ray = direction,
		normal = impact_normal,
		unit = hit_unit,
		body = hit_body or hit_unit:body(0)
	}

	self._bullet_class:on_collision(col_ray, self._unit, user_unit, self._damage)
end

function RaycastWeaponBase:tweak_data_anim_play(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_play(animations[anim], ...)

		return true
	end

	return false
end

function RaycastWeaponBase:anim_play(anim, speed_multiplier)
	if anim then
		local length = self._unit:anim_length(Idstring(anim))
		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim))
		self._unit:anim_play_to(Idstring(anim), length, speed_multiplier)
	end
end

function RaycastWeaponBase:tweak_data_anim_stop(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_stop(self:weapon_tweak_data().animations[anim], ...)

		return true
	end

	return false
end

function RaycastWeaponBase:anim_stop(anim)
	self._unit:anim_stop(Idstring(anim))
end

function RaycastWeaponBase:digest_value(value, digest)
	if self._digest_values then
		return Application:digest_value(value, digest)
	else
		return value
	end
end

function RaycastWeaponBase:set_ammo_max_per_clip(ammo_max_per_clip)
	if self._ammo_max_per_clip then
		if self._ammo_max_per_clip2 then
			print("haxor")
		end

		self._ammo_max_per_clip2 = self:digest_value(ammo_max_per_clip, true)
		self._ammo_max_per_clip = nil
	else
		self._ammo_max_per_clip = self:digest_value(ammo_max_per_clip, true)
		self._ammo_max_per_clip2 = nil
	end
end

function RaycastWeaponBase:get_ammo_max_per_clip()
	return self._ammo_max_per_clip and self:digest_value(self._ammo_max_per_clip, false) or self:digest_value(self._ammo_max_per_clip2, false)
end

function RaycastWeaponBase:set_ammo_max(ammo_max)
	if self._ammo_max then
		if self._ammo_max2 then
			print("haxor")
		end

		self._ammo_max2 = self:digest_value(ammo_max, true)
		self._ammo_max = nil
	else
		self._ammo_max = self:digest_value(ammo_max, true)
		self._ammo_max2 = nil
	end
end

function RaycastWeaponBase:get_ammo_max()
	return self._ammo_max and self:digest_value(self._ammo_max, false) or self:digest_value(self._ammo_max2, false)
end

function RaycastWeaponBase:get_ammo_ratio_excluding_clip()
	local ammo_in_clip = self:get_ammo_max_per_clip()
	local max_ammo = self:get_ammo_max() - ammo_in_clip
	local current_ammo = self:get_ammo_total() - ammo_in_clip

	if current_ammo == 0 then
		return 0
	end

	return current_ammo / max_ammo
end

function RaycastWeaponBase:get_max_ammo_excluding_clip()
	local ammo_in_clip = self:get_ammo_max_per_clip()
	local max_ammo = self:get_ammo_max() - ammo_in_clip

	return max_ammo
end

function RaycastWeaponBase:set_ammo_total(ammo_total)
	if ammo_total <= 0 then
		ammo_total = 0
	end

	self._ammo_total = self:digest_value(ammo_total, true)
end

function RaycastWeaponBase:get_ammo_total()
	local ammo_total = self._ammo_total and self:digest_value(self._ammo_total, false) or self:digest_value(self._ammo_total2, false)

	return ammo_total
end

function RaycastWeaponBase:get_ammo_ratio()
	local ammo_max = self:get_ammo_max()
	local ammo_total = self:get_ammo_total()

	return ammo_total / math.max(ammo_max, 1)
end

function RaycastWeaponBase:set_ammo_remaining_in_clip(ammo_remaining_in_clip)
	if ammo_remaining_in_clip < 0 then
		ammo_remaining_in_clip = 0
	end

	if self:get_ammo_max_per_clip() < ammo_remaining_in_clip then
		ammo_remaining_in_clip = self:get_ammo_max_per_clip()
	end

	if self._ammo_remaining_in_clip then
		if self._ammo_remaining_in_clip2 then
			print("haxor")
		end

		self._ammo_remaining_in_clip2 = self:digest_value(ammo_remaining_in_clip, true)
		self._ammo_remaining_in_clip = nil
	else
		self._ammo_remaining_in_clip = self:digest_value(ammo_remaining_in_clip, true)
		self._ammo_remaining_in_clip2 = nil
	end
end

function RaycastWeaponBase:get_ammo_remaining_in_clip()
	local ammo_remaining_in_clip = self._ammo_remaining_in_clip and self:digest_value(self._ammo_remaining_in_clip, false) or self:digest_value(self._ammo_remaining_in_clip2, false)

	return ammo_remaining_in_clip
end

function RaycastWeaponBase:selection_index()
	return tweak_data.weapon[self._name_id].use_data.selection_index
end

function RaycastWeaponBase:replenish()
	local ammo_max_multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "extra_ammo_multiplier", 1)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY) and (tweak_data.weapon[self._name_id].use_data.selection_index == 1 or tweak_data.weapon[self._name_id].use_data.selection_index == 2) then
		ammo_max_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY) or 1
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_PRIMARY_AMMO_CAPACITY) and tweak_data.weapon[self._name_id].use_data.selection_index == 2 then
		ammo_max_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_PRIMARY_AMMO_CAPACITY) or 1
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_SECONDARY_AMMO_CAPACITY) and tweak_data.weapon[self._name_id].use_data.selection_index == 1 then
		ammo_max_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_SECONDARY_AMMO_CAPACITY) or 1
	end

	local idx = self:selection_index()

	if idx then
		if idx == 1 then
			ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("weapon", "secondary_ammo_increase", 1)
			ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("player", "secondary_ammo_increase", 1)
		elseif idx == 2 then
			ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("weapon", "primary_ammo_increase", 1)
			ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("player", "primary_ammo_increase", 1)
		end
	end

	local ammo_max_per_clip = self:calculate_ammo_max_per_clip()
	local ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier)
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)

	self:set_ammo_max_per_clip(ammo_max_per_clip)
	self:set_ammo_max(ammo_max)
	self:set_ammo_total(ammo_max)
	self:set_ammo_remaining_in_clip(ammo_max_per_clip)

	self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP

	self:update_damage()
end

function RaycastWeaponBase:upgrade_blocked(category, upgrade)
	if not self:weapon_tweak_data().upgrade_blocks then
		return false
	end

	if not self:weapon_tweak_data().upgrade_blocks[category] then
		return false
	end

	return table.contains(self:weapon_tweak_data().upgrade_blocks[category], upgrade)
end

function RaycastWeaponBase:calculate_ammo_max_per_clip()
	local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX
	ammo = ammo + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

	if not self:upgrade_blocked("weapon", "clip_ammo_increase") then
		ammo = ammo + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
	end

	if not self:upgrade_blocked(tweak_data.weapon[self._name_id].category, "clip_ammo_increase") then
		ammo = ammo + managers.player:upgrade_value(tweak_data.weapon[self._name_id].category, "clip_ammo_increase", 0)
	end

	return ammo
end

function RaycastWeaponBase:_get_current_damage(dmg_mul)
	local damage = self._damage * (dmg_mul or 1)
	damage = damage * managers.player:temporary_upgrade_value("temporary", "combat_medic_damage_multiplier", 1)

	return damage
end

function RaycastWeaponBase:update_damage()
	if tweak_data.weapon[self._name_id].damage_profile then
		local damage_profile = tweak_data.weapon[self._name_id].damage_profile
		self._damage = damage_profile[1].damage * self:damage_multiplier()
	else
		self._damage = 1
	end
end

function RaycastWeaponBase:recoil()
	return self._recoil
end

function RaycastWeaponBase:spread_moving()
	return self._spread_moving
end

function RaycastWeaponBase:reload_speed_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "reload_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

	if managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		multiplier = multiplier + 1 - managers.player:upgrade_value("primary_weapon", "reload_speed_multiplier", 1)
	elseif managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		multiplier = multiplier + 1 - managers.player:upgrade_value("secondary_weapon", "reload_speed_multiplier", 1)
	end

	return multiplier
end

function RaycastWeaponBase:damage_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "damage_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "damage_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:melee_damage_multiplier()
	return managers.player:upgrade_value(self._name_id, "melee_multiplier", 1)
end

function RaycastWeaponBase:spread_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "spread_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("weapon", self:fire_mode() .. "_spread_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "spread_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:exit_run_speed_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "exit_run_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "exit_run_speed_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:recoil_addend()
	return 0
end

function RaycastWeaponBase:recoil_multiplier()
	local category = self:weapon_tweak_data().category
	local multiplier = managers.player:upgrade_value(category, "recoil_multiplier", 1)

	if managers.player:has_team_category_upgrade(category, "recoil_multiplier") then
		multiplier = multiplier * managers.player:team_upgrade_value(category, "recoil_multiplier", 1)
	elseif managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
		multiplier = multiplier * managers.player:team_upgrade_value(category, "suppression_recoil_multiplier", 1)
	end

	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "recoil_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:enter_steelsight_speed_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "enter_steelsight_speed_multiplier", 1)
	multiplier = multiplier * managers.player:temporary_upgrade_value("temporary", "combat_medic_enter_steelsight_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "enter_steelsight_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("player", "enter_steelsight_speed_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:fire_rate_multiplier()
	local multiplier = managers.player:upgrade_value(self:weapon_tweak_data().category, "fire_rate_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "fire_rate_multiplier", 1)

	return multiplier
end

function RaycastWeaponBase:upgrade_value(value, default)
	return managers.player:upgrade_value(self._name_id, value, default)
end

function RaycastWeaponBase:transition_duration()
	return self:weapon_tweak_data().transition_duration
end

function RaycastWeaponBase:melee_damage_info()
	local my_tweak_data = self:weapon_tweak_data()
	local dmg = my_tweak_data.damage_melee * self:melee_damage_multiplier()
	local dmg_effect = dmg * my_tweak_data.damage_melee_effect_mul

	return dmg, dmg_effect
end

function RaycastWeaponBase:ammo_info()
	return self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip(), self:get_ammo_total(), self:get_ammo_max()
end

function RaycastWeaponBase:set_ammo(ammo)
	local ammo_num = math.floor(ammo * self:get_ammo_max())

	Application:trace("[RaycastWeaponBase:set_ammo] new ammo count: ", ammo_num, math.min(self:get_ammo_max_per_clip(), ammo_num))
	self:set_ammo_total(ammo_num)
	self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), ammo_num))
end

function RaycastWeaponBase:set_ammo_with_empty_clip(ammo)
	local ammo_num = math.floor(ammo * self:get_ammo_max())

	Application:trace("[RaycastWeaponBase:set_ammo] new ammo count: ", ammo_num, math.min(self:get_ammo_max_per_clip(), ammo_num))
	self:set_ammo_total(ammo_num)
	self:set_ammo_remaining_in_clip(0)
end

function RaycastWeaponBase:ammo_full()
	return self:get_ammo_total() == self:get_ammo_max()
end

function RaycastWeaponBase:clip_full()
	return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip()
end

function RaycastWeaponBase:clip_empty()
	return self:get_ammo_remaining_in_clip() == 0
end

function RaycastWeaponBase:clip_not_empty()
	return self:get_ammo_remaining_in_clip() > 0
end

function RaycastWeaponBase:remaining_full_clips()
	return math.max(math.floor((self:get_ammo_total() - self:get_ammo_remaining_in_clip()) / self:get_ammo_max_per_clip()), 0)
end

function RaycastWeaponBase:zoom()
	return self._zoom
end

function RaycastWeaponBase:reload_expire_t()
	return nil
end

function RaycastWeaponBase:reload_enter_expire_t()
	return nil
end

function RaycastWeaponBase:reload_exit_expire_t()
	return nil
end

function RaycastWeaponBase:use_shotgun_reload()
	return nil
end

function RaycastWeaponBase:update_reloading(t, dt, time_left)
end

function RaycastWeaponBase:start_reload()
end

function RaycastWeaponBase:reload_interuptable()
	return false
end

function RaycastWeaponBase:on_reload()
	if self._setup.expend_ammo then
		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip()))
	else
		self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())
		self:set_ammo_total(self:get_ammo_max_per_clip())
	end

	managers.raid_job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)
end

function RaycastWeaponBase:ammo_max()
	return self:get_ammo_max() == self:get_ammo_total()
end

function RaycastWeaponBase:out_of_ammo()
	return self:get_ammo_total() == 0
end

function RaycastWeaponBase:can_reload()
	return self:get_ammo_remaining_in_clip() < self:get_ammo_total()
end

function RaycastWeaponBase:add_ammo_ratio(ratio)
	if ratio >= 1 and self:ammo_max() then
		return false
	end

	local max_ammo = self:get_ammo_max()
	local ammo = math.ceil(max_ammo * ratio - max_ammo)
	local total_ammo = self:get_ammo_total()
	total_ammo = math.clamp(total_ammo + ammo, 0, max_ammo)

	self:set_ammo_total(total_ammo)

	return true
end

function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	if self:ammo_max() then
		return false, 0
	end

	local multiplier_min = 1
	local multiplier_max = 1

	if self._ammo_data and self._ammo_data.ammo_pickup_min_mul then
		multiplier_min = self._ammo_data.ammo_pickup_min_mul
	else
		multiplier_min = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
	end

	if self._ammo_data and self._ammo_data.ammo_pickup_max_mul then
		multiplier_max = self._ammo_data.ammo_pickup_max_mul
	else
		multiplier_max = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
	end

	local add_amount = add_amount_override
	local picked_up = true
	add_amount = add_amount or self._ammo_pickup_amount
	add_amount = math.ceil(add_amount * (ratio or 1))
	local ammo_before_pickup = self:get_ammo_total()

	self:set_ammo_total(math.clamp(self:get_ammo_total() + add_amount, 0, self:get_ammo_max()))

	local ammo_actually_picked_up = self:get_ammo_total() - ammo_before_pickup

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_PICKED_UP_AMMO, {
		weapon = self._name_id,
		amount = ammo_actually_picked_up
	})

	if Application:production_build() then
		managers.player:add_weapon_ammo_gain(self._name_id, add_amount)
	end

	return picked_up, add_amount
end

function RaycastWeaponBase:add_ammo_from_bag(available)
	if self:ammo_max() then
		return 0
	end

	local ammo_max = self:get_ammo_max()
	local ammo_total = self:get_ammo_total()
	local wanted = 1 - ammo_total / ammo_max
	local can_have = math.min(wanted, available)

	self:set_ammo_total(math.min(ammo_max, ammo_total + math.ceil(can_have * ammo_max)))
	print(wanted, can_have, math.ceil(can_have * ammo_max), self:get_ammo_total())

	return can_have
end

function RaycastWeaponBase:reduce_ammo_by_procentage_of_total(ammo_procentage)
	local ammo_max = self:get_ammo_max()
	local ammo_total = self:get_ammo_total()
	local ammo_ratio = self:get_ammo_ratio()

	if ammo_total == 0 then
		return
	end

	local ammo_after_reduction = math.max(ammo_total - math.ceil(ammo_max * ammo_procentage), 0)

	self:set_ammo_total(math.round(math.min(ammo_total, ammo_after_reduction)))
	print("reduce_ammo_by_procentage_of_total", math.round(math.min(ammo_total, ammo_after_reduction)), ammo_after_reduction, ammo_max * ammo_procentage)

	local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()

	self:set_ammo_remaining_in_clip(math.round(math.min(ammo_after_reduction, ammo_remaining_in_clip)))
end

function RaycastWeaponBase:on_equip()
end

function RaycastWeaponBase:on_unequip()
end

function RaycastWeaponBase:on_enabled()
	self._enabled = true
end

function RaycastWeaponBase:on_disabled()
	self._enabled = false
end

function RaycastWeaponBase:enabled()
	return self._enabled
end

function RaycastWeaponBase:play_tweak_data_sound(event, alternative_event)
	local sounds = tweak_data.weapon[self._name_id].sounds
	local event = sounds and (sounds[event] or sounds[alternative_event])

	if event then
		self:play_sound(event)
	end
end

function RaycastWeaponBase:play_sound(event)
	local result = self._sound_fire:post_event(event)
end

function RaycastWeaponBase:destroy(unit)
	RaycastWeaponBase.super.pre_destroy(self, unit)

	if self._shooting then
		self:stop_shooting()
	end
end

function RaycastWeaponBase:_get_spread(user_unit)
	if user_unit == managers.player:player_unit() and managers.player:upgrade_value("player", "warcry_nullify_spread", false) == true then
		return 0
	end

	local spread_multiplier = self:spread_multiplier()
	local current_state = user_unit:movement()._current_state

	if current_state._moving then
		spread_multiplier = spread_multiplier * managers.player:upgrade_value(self:weapon_tweak_data().category, "move_spread_multiplier", 1)
	end

	if current_state:in_steelsight() then
		return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_steelsight" or "steelsight"] * spread_multiplier
	end

	spread_multiplier = spread_multiplier * managers.player:upgrade_value(self:weapon_tweak_data().category, "hip_fire_spread_multiplier", 1)

	if current_state._state_data.ducking then
		return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_crouching" or "crouching"] * spread_multiplier
	end

	return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_standing" or "standing"] * spread_multiplier
end

function RaycastWeaponBase:set_visibility_state(state)
	self._unit:set_visible(state)
end

function RaycastWeaponBase:set_bullet_hit_slotmask(new_slotmask)
	self._bullet_slotmask = new_slotmask
end

function RaycastWeaponBase:flashlight_state_changed()
end

function RaycastWeaponBase:set_flashlight_enabled(enabled)
end

function RaycastWeaponBase:set_timer(timer)
	self._timer = timer

	self._unit:set_timer(timer)
	self._unit:set_animation_timer(timer)
end

function RaycastWeaponBase:uses_ammo()
	return true
end

InstantBulletBase = InstantBulletBase or class()

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local weapon_type = weapon_unit and weapon_unit:weapon() and weapon_unit:weapon().type or nil
	local hit_unit = col_ray.unit
	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			if col_ray.position:length() > 90000 then
				debug_pause("[InstantBulletBase][on_collision] Position of the hit body is outside of alowed range and wouldn't be transportable through the network: ", inspect(col_ray), col_ray:position())

				return
			end

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage)

		if result == "no_damage" then
			play_impact_flesh = false
		elseif result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(col_ray, no_sound, weapon_type)
	end

	return result
end

function InstantBulletBase:_get_character_push_multiplier(weapon_unit, died)
	return 2.5

	if alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data().category == "shotgun" then
		return nil
	end

	return died and 2.5 or nil
end

function InstantBulletBase:on_hit_player(col_ray, weapon_unit, user_unit, damage)
	local armor_piercing = alive(weapon_unit) and weapon_unit:base():weapon_tweak_data().armor_piercing or nil
	col_ray.unit = managers.player:player_unit()

	return self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
end

function InstantBulletBase:bullet_slotmask()
	return managers.slot:get_mask("bullet_impact_targets_no_teamai")
end

function InstantBulletBase:blank_slotmask()
	return managers.slot:get_mask("bullet_blank_impact_targets")
end

function InstantBulletBase:play_impact_sound_and_effects(col_ray, no_sound, weapon_type)
	managers.game_play_central:play_impact_sound_and_effects({
		col_ray = col_ray,
		no_sound = no_sound,
		weapon_type = weapon_type
	})
end

function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local action_data = {
		variant = "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		is_turret = weapon_unit:base().sentry_gun
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

function InstantBulletBase._get_vector_sync_yaw_pitch(dir, yaw_resolution, pitch_resolution)
	mrotation.set_look_at(tmp_rot1, dir, math.UP)

	local packed_yaw = mrotation.yaw(tmp_rot1)
	packed_yaw = packed_yaw + 180
	packed_yaw = math.clamp(math.floor((yaw_resolution - 1) * packed_yaw / 360), 0, yaw_resolution - 1)
	local packed_pitch = mrotation.pitch(tmp_rot1)
	packed_pitch = packed_pitch + 90
	packed_pitch = math.clamp(math.floor((pitch_resolution - 1) * packed_pitch / 180), 0, pitch_resolution - 1)

	return packed_yaw, packed_pitch
end

InstantExplosiveBulletBase = InstantExplosiveBulletBase or class(InstantBulletBase)
InstantExplosiveBulletBase.CURVE_POW = tweak_data.upgrades.explosive_bullet.curve_pow
InstantExplosiveBulletBase.PLAYER_DMG_MUL = tweak_data.upgrades.explosive_bullet.player_dmg_mul
InstantExplosiveBulletBase.RANGE = tweak_data.upgrades.explosive_bullet.range
InstantExplosiveBulletBase.EFFECT_PARAMS = {
	sound_event = "round_explode",
	effect = "effects/vanilla/weapons/shotgun/sho_explosive_round",
	on_unit = true,
	sound_muffle_effect = true,
	feedback_range = tweak_data.upgrades.explosive_bullet.feedback_range,
	camera_shake_max_mul = tweak_data.upgrades.explosive_bullet.camera_shake_max_mul,
	idstr_decal = Idstring("explosion_round"),
	idstr_effect = Idstring("")
}

function InstantExplosiveBulletBase:bullet_slotmask()
	return managers.slot:get_mask("bullet_impact_targets")
end

function InstantExplosiveBulletBase:blank_slotmask()
	return managers.slot:get_mask("bullet_blank_impact_targets")
end

function InstantExplosiveBulletBase:play_impact_sound_and_effects(col_ray)
	managers.game_play_central:play_impact_sound_and_effects({
		no_decal = true,
		col_ray = col_ray
	})
end

function InstantExplosiveBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit

	if not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood then
		self:play_impact_sound_and_effects(col_ray)
	end

	if not blank then
		mvec3_set(tmp_vec1, col_ray.position)
		mvec3_set(tmp_vec2, col_ray.ray)
		mvec3_norm(tmp_vec2)
		mvec3_mul(tmp_vec2, 20)
		mvec3_sub(tmp_vec1, tmp_vec2)

		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if Network:is_server() then
			self:on_collision_server(tmp_vec1, col_ray.normal, damage, user_unit, weapon_unit, managers.network:session():local_peer():id())
		else
			self:on_collision_server(tmp_vec1, col_ray.normal, damage, user_unit, weapon_unit, managers.network:session():local_peer():id())
		end

		if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
			local sync_damage = not blank and hit_unit:id() ~= -1

			if sync_damage then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.body, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
			end

			local local_damage = not blank or hit_unit:id() == -1

			if local_damage then
				col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
			end
		end

		return {
			variant = "explosion",
			col_ray = col_ray
		}
	end

	return nil
end

function InstantExplosiveBulletBase:on_collision_server(position, normal, damage, user_unit, weapon_unit, owner_peer_id, owner_selection_index)
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:play_sound_and_effects(position, normal, self.RANGE, self.EFFECT_PARAMS)

	local hit_units, splinters, results = managers.explosion:detect_and_give_dmg({
		hit_pos = position,
		range = self.RANGE,
		collision_slotmask = slot_mask,
		curve_pow = self.CURVE_POW,
		damage = damage,
		player_damage = damage * self.PLAYER_DMG_MUL,
		ignore_unit = weapon_unit,
		user = user_unit,
		owner = weapon_unit
	})
	local network_damage = math.ceil(damage * 163.84)

	managers.network:session():send_to_peers_synched("sync_explode_bullet", position, normal, math.min(16384, network_damage), owner_peer_id)

	if managers.network:session():local_peer():id() == owner_peer_id then
		local enemies_hit = (results.count_gangsters or 0) + (results.count_cops or 0)
		local enemies_killed = (results.count_gangster_kills or 0) + (results.count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		if enemies_hit > 0 then
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil

		for achievement, achievement_data in pairs(tweak_data.achievement.explosion_achievements) do
			weapon_pass = not achievement_data.weapon or true
			weapon_type_pass = not achievement_data.weapon_type or weapon_unit:base() and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data().category == achievement_data.weapon_type
			count_pass = not achievement_data.count or achievement_data.count <= (achievement_data.kill and enemies_killed or enemies_hit)
			all_pass = weapon_pass and weapon_type_pass and count_pass

			if all_pass and achievement_data.award then
				managers.achievment:award(achievement_data.award)
			end
		end
	else
		local peer = managers.network:session():peer(owner_peer_id)
		local SYNCH_MIN = 0
		local SYNCH_MAX = 31
		local count_cops = math.clamp(results.count_cops, SYNCH_MIN, SYNCH_MAX)
		local count_gangsters = math.clamp(results.count_gangsters, SYNCH_MIN, SYNCH_MAX)
		local count_civilians = math.clamp(results.count_civilians, SYNCH_MIN, SYNCH_MAX)
		local count_cop_kills = math.clamp(results.count_cop_kills, SYNCH_MIN, SYNCH_MAX)
		local count_gangster_kills = math.clamp(results.count_gangster_kills, SYNCH_MIN, SYNCH_MAX)
		local count_civilian_kills = math.clamp(results.count_civilian_kills, SYNCH_MIN, SYNCH_MAX)

		managers.network:session():send_to_peer_synched(peer, "sync_explosion_results", count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, owner_selection_index)
	end
end

function InstantExplosiveBulletBase:on_collision_client(position, normal, damage, user_unit)
	managers.explosion:give_local_player_dmg(position, self.RANGE, damage * self.PLAYER_DMG_MUL)
	managers.explosion:explode_on_client(position, normal, user_unit, damage, self.RANGE, self.CURVE_POW, self.EFFECT_PARAMS)
end

FlameBulletBase = FlameBulletBase or class(InstantExplosiveBulletBase)
FlameBulletBase.EFFECT_PARAMS = {
	sound_event = "round_explode",
	sound_muffle_effect = true,
	on_unit = true,
	feedback_range = tweak_data.upgrades.flame_bullet.feedback_range,
	camera_shake_max_mul = tweak_data.upgrades.flame_bullet.camera_shake_max_mul,
	idstr_decal = Idstring("explosion_round"),
	idstr_effect = Idstring(""),
	pushunits = tweak_data.upgrades
}

function FlameBulletBase:on_hit_player(col_ray, weapon_unit, user_unit, damage)
	col_ray.unit = managers.player:player_unit()

	return self:give_fire_damage(col_ray, weapon_unit, user_unit, damage, false)
end

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit
	local play_impact_flesh = false

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage and not col_ray.unit:damage()._immune_fire then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			no_sound = true,
			col_ray = col_ray
		})
		self:play_impact_sound_and_effects(col_ray)
	end

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end

		managers.fire:leave_flamethrower_patch(col_ray.unit)
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

function FlameBulletBase:give_fire_damage_dot(col_ray, weapon_unit, attacker_unit, damage, is_fire_dot_damage)
	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = attacker_unit,
		col_ray = col_ray,
		is_fire_dot_damage = is_fire_dot_damage
	}
	local defense_data = {}

	if col_ray and col_ray.unit and alive(col_ray.unit) and col_ray.unit:character_damage() then
		defense_data = col_ray.unit:character_damage():damage_fire(action_data)
	end

	return defense_data
end

DragonBreathBulletBase = DragonBreathBulletBase or class(InstantBulletBase)

function DragonBreathBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit
	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray
		})
		self:play_impact_sound_and_effects(col_ray)
	end

	return result
end

function DragonBreathBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local action_data = {
		variant = "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		ignite_character = "dragonsbreath"
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

DOTBulletBase = DOTBulletBase or class(InstantBulletBase)
DOTBulletBase.DOT_DATA = {
	hurt_animation_chance = 1,
	dot_damage = 0.5,
	dot_length = 6,
	dot_tick_period = 0.5
}

function DOTBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local result = DOTBulletBase.super.on_collision(self, col_ray, weapon_unit, user_unit, damage, blank, self.NO_BULLET_INPACT_SOUND)
	local hit_unit = col_ray.unit

	if hit_unit:character_damage() and hit_unit:character_damage().damage_dot and not hit_unit:character_damage():dead() then
		result = self:start_dot_damage(col_ray, weapon_unit, self:_dot_data_by_weapon(weapon_unit))
	end

	return result
end

function DOTBulletBase:_dot_data_by_weapon(weapon_unit)
	if not alive(weapon_unit) then
		return nil
	end

	if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.dot_data then
		local ammo_dot_data = weapon_unit:base()._ammo_data.dot_data

		return managers.dot:create_dot_data(ammo_dot_data.type, ammo_dot_data.custom_data)
	end

	return nil
end

function DOTBulletBase:start_dot_damage(col_ray, weapon_unit, dot_data)
	local hurt_animation = not dot_data.hurt_animation_chance or math.rand(1) < dot_data.hurt_animation_chance
	dot_data = dot_data or self.DOT_DATA

	managers.dot:add_doted_enemy(col_ray.unit, TimerManager:game():time(), weapon_unit, dot_data.dot_length, dot_data.dot_damage, hurt_animation, self.VARIANT)
end

function DOTBulletBase:give_damage_dot(col_ray, weapon_unit, attacker_unit, damage, hurt_animation)
	local action_data = {
		variant = self.VARIANT,
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = attacker_unit,
		col_ray = col_ray,
		hurt_animation = hurt_animation
	}
	local defense_data = {}

	if col_ray and col_ray.unit and alive(col_ray.unit) and col_ray.unit:character_damage() then
		defense_data = col_ray.unit:character_damage():damage_dot(action_data)
	end

	return defense_data
end

PoisonBulletBase = PoisonBulletBase or class(DOTBulletBase)
PoisonBulletBase.VARIANT = "poison"
ProjectilesPoisonBulletBase = ProjectilesPoisonBulletBase or class(PoisonBulletBase)
ProjectilesPoisonBulletBase.NO_BULLET_INPACT_SOUND = true

function ProjectilesPoisonBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local result = DOTBulletBase.super.on_collision(self, col_ray, weapon_unit, user_unit, damage, blank, self.NO_BULLET_INPACT_SOUND)
	local hit_unit = col_ray.unit

	if hit_unit:character_damage() and hit_unit:character_damage().damage_dot and not hit_unit:character_damage():dead() then
		local dot_data = tweak_data.projectiles[weapon_unit:base()._projectile_entry].dot_data

		if not dot_data then
			return
		end

		local dot_type_data = tweak_data:get_dot_type_data(dot_data.type)

		if not dot_type_data then
			return
		end

		result = self:start_dot_damage(col_ray, nil, {
			dot_damage = dot_type_data.dot_damage,
			dot_length = dot_data.custom_length or dot_type_data.dot_length
		})
	end

	return result
end
