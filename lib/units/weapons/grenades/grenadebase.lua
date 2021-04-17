GrenadeBase = GrenadeBase or class(ProjectileBase)
GrenadeBase.EVENT_IDS = {
	detonate = 1
}
local mvec1 = Vector3()
local mvec2 = Vector3()

-- Lines 9-14
function GrenadeBase:_setup_server_data()
	self._slot_mask = managers.slot:get_mask("trip_mine_targets")

	if self._init_timer then
		self._timer = self._init_timer
	end
end

-- Lines 17-18
function GrenadeBase:setup(unit, t, dt)
end

-- Lines 20-36
function GrenadeBase:update(unit, t, dt)
	if self._hand_held then
		return
	end

	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._timer = nil

			self:_detonate()

			return
		end
	end

	GrenadeBase.super.update(self, unit, t, dt)
end

-- Lines 40-42
function GrenadeBase:clbk_impact(...)
	self:_detonate()
end

-- Lines 44-46
function GrenadeBase:_on_collision(col_ray)
	self:_detonate()
end

-- Lines 50-52
function GrenadeBase:_detonate()
	print("no _detonate function for grenade base")
end

-- Lines 54-56
function GrenadeBase:_detonate_on_client()
	print("no _detonate_on_client function for grenade base")
end

-- Lines 60-64
function GrenadeBase:sync_net_event(event_id)
	if event_id == GrenadeBase.EVENT_IDS.detonate then
		self:_detonate_on_client()
	end
end

-- Lines 68-77
function GrenadeBase:throw(...)
	GrenadeBase.super.throw(self, ...)

	local weapon_id = tweak_data.projectiles[self:projectile_entry()].weapon_id

	if weapon_id then
		managers.statistics:shot_fired({
			hit = false,
			name_id = weapon_id
		})
	end
end

-- Lines 79-105
function GrenadeBase:add_damage_result(unit, is_dead, damage_percent)
	if not alive(self._thrower_unit) or self._thrower_unit ~= managers.player:player_unit() then
		return
	end

	local unit_type = unit:base()._tweak_table
	local is_civlian = unit:character_damage().is_civilian(unit_type)
	local is_gangster = unit:character_damage().is_gangster(unit_type)
	local is_cop = unit:character_damage().is_cop(unit_type)

	if is_civlian then
		return
	end

	local weapon_id = tweak_data.projectiles[self:projectile_entry()].weapon_id

	if weapon_id and not self._recorded_hit then
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			name_id = weapon_id
		})

		self._recorded_hit = true
	end

	table.insert(self._damage_results, is_dead)

	local hit_count = #self._damage_results
	local kill_count = 0

	for i, death in ipairs(self._damage_results) do
		kill_count = kill_count + (death and 1 or 0)
	end
end

-- Lines 107-113
function GrenadeBase:get_use_data(character_setup)
	local use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = 3,
		unequip = {
			align_place = "back"
		}
	}

	return use_data
end

-- Lines 117-124
function GrenadeBase:tweak_data_anim_play(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_play(animations[anim], ...)

		return true
	end

	return false
end

-- Lines 126-133
function GrenadeBase:anim_play(anim, speed_multiplier)
	if anim then
		local length = self._unit:anim_length(Idstring(anim))
		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim))
		self._unit:anim_play_to(Idstring(anim), length, speed_multiplier)
	end
end

-- Lines 135-142
function GrenadeBase:tweak_data_anim_stop(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_stop(self:weapon_tweak_data().animations[anim], ...)

		return true
	end

	return false
end

-- Lines 144-146
function GrenadeBase:anim_stop(anim)
	self._unit:anim_stop(Idstring(anim))
end

-- Lines 148-152
function GrenadeBase:melee_damage_info()
	local my_tweak_data = self:weapon_tweak_data()

	return my_tweak_data.damage_melee, my_tweak_data.damage_melee_effect_mul
end

-- Lines 154-155
function GrenadeBase:ammo_info()
end

-- Lines 157-160
function GrenadeBase:add_ammo(ratio, add_amount_override, add_amount_multiplier)
	return false, 0
end

-- Lines 163-165
function GrenadeBase:add_ammo_from_bag(available)
	return 0
end

-- Lines 167-169
function GrenadeBase:set_hand_held(value)
	self._hand_held = value
end

-- Lines 171-172
function GrenadeBase:on_equip()
end

-- Lines 174-175
function GrenadeBase:on_unequip()
end

-- Lines 177-179
function GrenadeBase:on_enabled()
	self._enabled = true
end

-- Lines 181-183
function GrenadeBase:on_disabled()
	self._enabled = false
end

-- Lines 185-187
function GrenadeBase:enabled()
	return self._enabled
end

-- Lines 189-191
function GrenadeBase:get_stance_id()
	return self:weapon_tweak_data().stance
end

-- Lines 193-195
function GrenadeBase:transition_duration()
	return self:weapon_tweak_data().transition_duration
end

-- Lines 198-200
function GrenadeBase:enter_steelsight_speed_multiplier()
	return 1
end

-- Lines 202-204
function GrenadeBase:exit_run_speed_multiplier()
	return self:weapon_tweak_data().exit_run_speed_multiplier
end

-- Lines 206-208
function GrenadeBase:weapon_tweak_data()
	return tweak_data.projectiles[self.name_id]
end

-- Lines 210-212
function GrenadeBase:weapon_hold()
	return self:weapon_tweak_data().weapon_hold
end

-- Lines 214-216
function GrenadeBase:selection_index()
	return PlayerInventory.SLOT_3
end

-- Lines 218-220
function GrenadeBase:has_range_distance_scope()
	return false
end

-- Lines 222-224
function GrenadeBase:set_visibility_state(state)
	self._unit:set_visible(state)
end

-- Lines 226-228
function GrenadeBase:movement_penalty()
	return self:weapon_tweak_data().weapon_movement_penalty or 1
end

-- Lines 230-232
function GrenadeBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

-- Lines 234-236
function GrenadeBase:start_shooting_allowed()
	return true
end

-- Lines 238-242
function GrenadeBase:save(data)
	local state = {
		timer = self._timer
	}
	data.GrenadeBase = state
end

-- Lines 244-247
function GrenadeBase:load(data)
	local state = data.GrenadeBase
	self._timer = state.timer
end

-- Lines 250-252
function GrenadeBase:uses_ammo()
	return false
end

-- Lines 254-257
function GrenadeBase:replenish()
	local name, amount = managers.blackmarket:equipped_grenade()

	managers.player:add_grenade_amount(amount)
end
