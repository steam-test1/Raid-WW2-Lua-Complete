MolotovGrenade = MolotovGrenade or class(GrenadeBase)

function MolotovGrenade:destroy(unit)
	for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
		World:effect_manager():fade_kill(damage_effect_entry.effect_id)
	end
end

function MolotovGrenade:_setup_from_tweak_data()
	local grenade_entry = self.tweak_data or "molotov"
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._init_timer = self._tweak_data.init_timer or 10
	self._mass_look_up_modifier = self._tweak_data.mass_look_up_modifier
	self._range = self._tweak_data.range
	self._effect_name = "effects/vanilla/fire/fire_molotov_grenade_001"
	self._curve_pow = self._tweak_data.curve_pow or 3
	self._damage = self._tweak_data.damage
	self._player_damage = self._tweak_data.player_damage
	self._alert_radius = self._tweak_data.alert_radius
	self._fire_alert_radius = self._tweak_data.fire_alert_radius
	self._fire_dot_data = self._tweak_data.fire_dot_data
	local sound_event = self._tweak_data.sound_event or "grenade_explode"
	local sound_event_burning = self._tweak_data.sound_event_burning or "burn_loop_gen"
	local sound_event_impact_duration = self._tweak_data.sound_event_impact_duration or 1
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2,
		sound_event_burning = sound_event_burning,
		sound_event_impact_duration = sound_event_impact_duration
	}
	self._burn_duration = self._tweak_data.burn_duration
	self._burn_tick_temp_counter = 0
	self._burn_tick_period = self._tweak_data.burn_tick_period
	self._detonated = false
	self._detonated_position = nil
	self._molotov_damage_effect_table = {}
	self._initial_damage_done = false
	self._damaged_bodies = {}
	self._last_position = nil
end

function MolotovGrenade:update(unit, t, dt)
	if self._hand_held then
		return
	end

	MolotovGrenade.super.update(self, unit, t, dt)

	if self._detonated == true and self._burn_duration > 0 then
		self._burn_duration = self._burn_duration - dt
		self._burn_tick_temp_counter = self._burn_tick_temp_counter + dt

		for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
			local effect_body_alive = alive(damage_effect_entry.body)

			if damage_effect_entry.body ~= nil and effect_body_alive == true then
				local distance = mvector3.distance(damage_effect_entry.body:position(), damage_effect_entry.effect_initial_position)

				if distance ~= nil and distance >= 0.1 then
					local pos_diff = damage_effect_entry.body:position()

					mvector3.subtract(pos_diff, damage_effect_entry.body_initial_position)

					local effect_new_location = damage_effect_entry.effect_initial_position + pos_diff
					damage_effect_entry.effect_current_position = effect_new_location

					World:effect_manager():move(damage_effect_entry.effect_id, effect_new_location)
				end
			end
		end

		if self._burn_tick_period <= self._burn_tick_temp_counter or self._initial_damage_done == false then
			self:_do_damage()

			self._initial_damage_done = true
		end
	else
		self._last_position = unit:position()
	end

	if self._burn_duration <= 0 then
		if Network:is_server() then
			self._unit:set_slot(0)
		end

		self._detonated = false
	end
end

function MolotovGrenade:_do_damage()
	local pos = self._detonated_position
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local player_in_range = false
	local player_in_range_count = 0

	if self._molotov_damage_effect_table then
		local collision_safety_distance = Vector3(0, 0, 5)
		local effect_position = nil
		local player_damage_range = range

		for _, damage_effect_entry in pairs(self._molotov_damage_effect_table) do
			if damage_effect_entry.body ~= nil then
				effect_position = damage_effect_entry.effect_current_position + collision_safety_distance
				local damage_range = range

				if _ == 1 then
					damage_range = range * 1.5
				end

				if managers.player:player_unit() then
					local player_distance = mvector3.distance(damage_effect_entry.effect_current_position, managers.player:player_unit():position())

					if player_distance <= damage_range and player_in_range == false then
						local raycast = World:raycast("ray", effect_position, managers.player:player_unit():position() + Vector3(0, 0, 30), "slot_mask", slot_mask)
						local raycast2 = World:raycast("ray", effect_position, managers.player:player_unit():position() + Vector3(0, 0, 0), "slot_mask", slot_mask)

						if raycast == nil or raycast2 == nil then
							player_in_range = true
							player_in_range_count = player_in_range_count + 1
							pos = damage_effect_entry.effect_current_position
							player_damage_range = damage_range
						end
					end
				end

				if Network:is_server() then
					local hit_units, splinters = managers.fire:detect_and_give_dmg({
						player_damage = 0,
						push_units = false,
						hit_pos = effect_position,
						range = damage_range,
						collision_slotmask = slot_mask,
						curve_pow = self._curve_pow,
						damage = self._damage,
						ignore_unit = self._unit,
						user = self._unit,
						alert_radius = self._fire_alert_radius,
						fire_dot_data = self._fire_dot_data
					})
				end
			end
		end

		if player_in_range == true then
			managers.fire:give_local_player_dmg(pos, player_damage_range, self._player_damage)
		end
	end

	self._damaged_bodies = {}
	self._burn_tick_temp_counter = 0
end

function MolotovGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity)
	self:_detonate(normal)
end

function MolotovGrenade:detonate(normal)
	managers.explosion:detect_and_give_dmg({
		range = 250,
		curve_pow = 0.1,
		damage = 3,
		player_damage = 0,
		push_units = false,
		hit_pos = self._unit:position(),
		collision_slotmask = managers.slot:get_mask("explosion_targets"),
		alert_radius = self._alert_radius,
		ignore_unit = managers.player:player_unit(),
		user = self._unit
	})

	self._detonated_position = self._unit:position()
	local position = self._detonated_position
	local range = self._range
	local single_effect_radius = range
	local diagonal_distance = math.sqrt(math.pow(single_effect_radius * 2, 2) - math.pow(single_effect_radius, 2))
	local raycast = nil
	local slotmask = managers.slot:get_mask("molotov_raycasts")
	local vector, effect_id = nil

	if normal == nil or mvector3.length(normal) < 0.1 then
		normal = Vector3(0, 0, 1)
	end

	local tangent = Vector3(normal.z, normal.z, -normal.x - normal.y)

	if tangent.x == 0 and tangent.y == 0 and tangent.z == 0 then
		tangent = Vector3(-normal.y - normal.z, normal.x, normal.x)
	end

	mvector3.normalize(tangent)

	local offset = tangent

	mvector3.multiply(offset, single_effect_radius * 2)

	local rotation = Rotation()

	mrotation.set_axis_angle(rotation, normal, 60)

	vector = position + Vector3(0, 0, 0)
	raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
	local ray_cast2, fake_ball_main = nil

	if raycast == nil then
		local vector21 = vector + Vector3(0, 0, -150)
		raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector21, "slot_mask", slotmask)

		if raycast == nil then
			local vector41 = vector21 - 50 * normal
			raycast = World:raycast("ray", vector21 + 20 * normal, vector41, "slot_mask", slotmask)

			if raycast ~= nil then
				managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

				ray_cast2 = raycast
			else
				local vector31 = vector + Vector3(0, 0, -1500)
				raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector31, "slot_mask", slotmask)

				if raycast ~= nil then
					managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

					ray_cast2 = raycast
				end
			end
		else
			managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

			ray_cast2 = raycast
		end

		if ray_cast2 ~= nil then
			self._molotov_damage_effect_table[1].body = ray_cast2.body
			self._molotov_damage_effect_table[1].body_initial_position = ray_cast2.body:position()
			self._molotov_damage_effect_table[1].body_initial_rotation = ray_cast2.body:rotation()
			self._molotov_damage_effect_table[1].effect_initial_position = ray_cast2.position
			self._molotov_damage_effect_table[1].effect_initial_normal = ray_cast2.normal
		end
	end

	for i = 1, 6 do
		vector = position + offset
		raycast = World:raycast("ray", position, vector, "slot_mask", slotmask)
		local ray_cast, fake_ball_outline = nil

		if raycast == nil then
			local vector2 = vector + Vector3(0, 0, -150)
			raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector2, "slot_mask", slotmask)

			if raycast == nil then
				local vector4 = vector2 - 50 * normal
				raycast = World:raycast("ray", vector2 + 20 * normal, vector4, "slot_mask", slotmask)

				if raycast ~= nil then
					managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

					ray_cast = raycast
				else
					local vector3 = vector + Vector3(0, 0, -1500)
					raycast = World:raycast("ray", vector + Vector3(0, 0, 20), vector3, "slot_mask", slotmask)

					if raycast ~= nil then
						managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

						ray_cast = raycast
					end
				end
			else
				managers.fire:play_sound_and_effects(raycast.position, raycast.normal, range, self._custom_params, self._molotov_damage_effect_table)

				ray_cast = raycast
			end

			if ray_cast ~= nil then
				local tableSize = #self._molotov_damage_effect_table
				self._molotov_damage_effect_table[tableSize].body = ray_cast.body
				self._molotov_damage_effect_table[tableSize].body_initial_position = ray_cast.body:position()
				self._molotov_damage_effect_table[tableSize].body_initial_rotation = ray_cast.body:rotation()
				self._molotov_damage_effect_table[tableSize].effect_initial_position = ray_cast.position
				self._molotov_damage_effect_table[tableSize].effect_initial_normal = ray_cast.normal
			end
		else
			table.insert(self._molotov_damage_effect_table, nil)
		end

		mvector3.rotate_with(offset, rotation)
	end

	self._detonated = true

	self._unit:damage():run_sequence_simple("disable")
	self._unit:set_visible(false)
end

function MolotovGrenade:_detonate(normal)
	if self._detonated == false then
		self:detonate(normal)
		managers.network:session():send_to_peers_synched("sync_detonate_molotov_grenade", self._unit, "base", GrenadeBase.EVENT_IDS.detonate, normal)
	end
end

function MolotovGrenade:sync_detonate_molotov_grenade(event_id, normal)
	if event_id == GrenadeBase.EVENT_IDS.detonate then
		self:_detonate_on_client(normal)
	end
end

function MolotovGrenade:_detonate_on_client(normal)
	if self._detonated == false then
		self:detonate(normal)
	end
end

function MolotovGrenade:_detonate_on_client_OLD(normal)
	if self._detonated == false then
		self._detonated_position = self._unit:position()
		local pos = self._detonated_position
		local range = self._range
		local slot_mask = managers.slot:get_mask("explosion_targets")

		managers.fire:play_sound_and_effects(pos, normal, range, self._custom_params)

		self._detonated = true

		self._unit:set_visible(false)
	end
end

function MolotovGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self._timer = nil

	self:_detonate()
end

function MolotovGrenade:add_damage_result(unit, is_dead, damage_percent)
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

	if is_dead then
		self:_check_achievements(unit, is_dead, damage_percent, 1, 1)
	end
end
