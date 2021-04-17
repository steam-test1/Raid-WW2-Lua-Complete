NewFlamethrowerBase = NewFlamethrowerBase or class(NewRaycastWeaponBase)
NewFlamethrowerBase.EVENT_IDS = {
	flamethrower_effect = 1
}

-- Lines 5-8
function NewFlamethrowerBase:init(...)
	NewFlamethrowerBase.super.init(self, ...)
	self:setup_default()
end

-- Lines 10-18
function NewFlamethrowerBase:setup_default()
	self._rays = tweak_data.weapon[self._name_id].rays or 6
	self._range = tweak_data.weapon[self._name_id].flame_max_range or 1000
	self._flame_max_range = tweak_data.weapon[self._name_id].flame_max_range
	self._single_flame_effect_duration = tweak_data.weapon[self._name_id].single_flame_effect_duration
	self._bullet_class = FlameBulletBase
end

-- Lines 21-24
function NewFlamethrowerBase:update(unit, t, dt)
end

-- Lines 28-38
function NewFlamethrowerBase:_create_use_setups()
	local use_data = {}
	local player_setup = {
		selection_index = tweak_data.weapon[self._name_id].use_data.selection_index,
		equip = {
			align_place = tweak_data.weapon[self._name_id].use_data.align_place or "left_hand"
		},
		unequip = {
			align_place = "back"
		}
	}
	use_data.player = player_setup
	self._use_data = use_data
end

-- Lines 43-53
function NewFlamethrowerBase:_update_stats_values()
	NewFlamethrowerBase.super._update_stats_values(self)
	self:setup_default()

	if self._ammo_data and self._ammo_data.rays ~= nil then
		self._rays = self._ammo_data.rays
	end
end

-- Lines 57-58
function NewFlamethrowerBase:get_damage_falloff(damage, col_ray, user_unit)
end

-- Lines 61-63
function NewFlamethrowerBase:_spawn_muzzle_effect(from_pos, direction)
	self._unit:flamethrower_effect_extension():_spawn_muzzle_effect(from_pos, direction)
end

local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

-- Lines 69-220
function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	if self._rays == 1 then
		local result = NewFlamethrowerBase.super._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)

		return result
	end

	local result = {}
	local hit_enemies = {}
	local hit_something, col_rays = nil

	if self._alert_events then
		col_rays = {}
	end

	local damage = self:_get_current_damage(dmg_mul)
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, self._range)
	local weight = 0.1
	local enemy_died = false

	-- Lines 88-97
	local function hit_enemy(col_ray)
		if col_ray.unit:character_damage() and col_ray.unit:character_damage().is_head then
			local enemy_key = col_ray.unit:key()

			if not hit_enemies[enemy_key] or col_ray.unit:character_damage():is_head(col_ray.body) then
				hit_enemies[enemy_key] = col_ray
			end
		else
			self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
		end
	end

	local spread = self:_get_spread(user_unit)

	mvector3.set(mvec_direction, direction)

	for i = 1, self._rays do
		mvector3.set(mvec_spread_direction, mvec_direction)

		if spread then
			mvector3.spread(mvec_spread_direction, spread * (spread_mul or 1))
		end

		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		local search_for_targets = true
		local raycast_from = from_pos
		local raycast_to = mvec_to
		local raycast_ignore_units = clone(self._setup.ignore_units)
		local test_color = 1
		local col_ray, test_last_raycast_hit_position = nil

		while search_for_targets do
			col_ray = World:raycast("ray", raycast_from, raycast_to, "slot_mask", self._bullet_slotmask, "ignore_unit", raycast_ignore_units)

			if test_last_raycast_hit_position == nil then
				test_last_raycast_hit_position = raycast_from
			end

			if col_rays then
				if col_ray then
					if col_ray then
						test_last_raycast_hit_position = col_ray.hit_position
					end

					if self._flame_max_range < col_ray.distance then
						search_for_targets = false

						break
					elseif col_ray.unit:in_slot(managers.slot:get_mask("world_geometry")) then
						table.insert(col_rays, col_ray)

						search_for_targets = false
					else
						table.insert(raycast_ignore_units, col_ray.unit)
					end
				else
					local ray_to = mvector3.copy(raycast_to)
					local spread_direction = mvector3.copy(mvec_spread_direction)

					table.insert(col_rays, {
						position = ray_to,
						ray = spread_direction
					})

					search_for_targets = false
				end
			end

			if self._autoaim and autoaim then
				if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
					self._autohit_current = (self._autohit_current + weight) / (1 + weight)

					hit_enemy(col_ray)

					autoaim = false
				else
					autoaim = false
					local autohit = self:check_autoaim(from_pos, direction, self._range)

					if autohit then
						local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

						if math.random() < autohit_chance then
							self._autohit_current = (self._autohit_current + weight) / (1 + weight)
							hit_something = true

							hit_enemy(autohit)
						else
							self._autohit_current = self._autohit_current / (1 + weight)
						end
					elseif col_ray then
						hit_something = true

						hit_enemy(col_ray)
					end
				end
			elseif col_ray then
				hit_something = true

				hit_enemy(col_ray)
			end
		end
	end

	for _, col_ray in pairs(hit_enemies) do
		if damage > 0 then
			local result = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)

			if result and result.type == "death" then
				-- Nothing
			end
		end
	end

	if dodge_enemies and self._suppression then
		for enemy_data, dis_error in pairs(dodge_enemies) do
			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
		end
	end

	result.hit_enemy = next(hit_enemies) and true or false

	if self._alert_events then
		result.rays = #col_rays > 0 and col_rays
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	if next(hit_enemies) then
		if true or false then
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = self._unit
			})
		end
	end

	return result
end

-- Lines 224-226
function NewFlamethrowerBase:reload_interuptable()
	return false
end

-- Lines 230-233
function NewFlamethrowerBase:calculate_vertical_recoil_kick()
	return 0
end

-- Lines 236-238
function NewFlamethrowerBase:third_person_important()
	return true
end
