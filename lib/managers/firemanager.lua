local FireSpawners = require("lib/managers/fire/FireSpawners")
FireManager = FireManager or class()

function FireManager:init()
	self._tweak_data = tweak_data.fire
	self._active_fires = {}
	self._slotmask_fire = managers.slot:get_mask("molotov_raycasts")
	self._slotmask_damage = managers.slot:get_mask("bullet_impact_targets")
end

function FireManager:on_simulation_ended()
	self:clear()
end

function FireManager:on_tweak_data_reloaded()
	self._tweak_data = tweak_data.fire
end

function FireManager:clear()
	managers.queued_tasks:unqueue_all(nil, self)

	for _, fire_data in ipairs(self._active_fires) do
		self:_stop_burn_sound(fire_data)

		for i, patch_data in ipairs(fire_data.fire_patches) do
			World:effect_manager():kill(patch_data.effect_id)
		end
	end

	self._active_fires = {}
end

function FireManager:update(t, dt)
	for i = #self._active_fires, 1, -1 do
		local data = self._active_fires[i]

		if data.tick_next <= t then
			self:_do_damage_tick(data)

			data.tick_next = t + data.tweak_data.tick_interval
			data.ticks_left = data.ticks_left - 1
		end

		if data.ticks_left == 0 then
			self:extinguish_fire(data)
			table.remove(self._active_fires, i)
		end
	end
end

function FireManager:propagate_fire(position, tweak_id, params)
	if not position or not tweak_id then
		Application:error("[FireManager:propagate_fire] Trying to start a fire with missing parameters")

		return
	end

	local fire_tweak = self._tweak_data[tweak_id]

	if not fire_tweak then
		Application:error("[FireManager:propagate_fire] Trying to start a fire with incorrect tweak id:", tweak_id)

		return
	end

	params = params or {}
	params.position = position + math.UP * 8
	params.normal = params.normal or math.UP
	params.slotmask = self._slotmask_fire
	params.source_unit = alive(params.source_unit) and params.source_unit or nil
	params.attacker_unit = alive(params.attacker_unit) and params.attacker_unit or nil
	params.weapon_unit = alive(params.weapon_unit) and params.weapon_unit or nil
	local duration = fire_tweak.duration
	local tick_interval = fire_tweak.tick_interval
	local total_ticks = math.floor(duration / tick_interval)
	local time = TimerManager:game():time()
	local range = fire_tweak.range
	params.splinter_vectors = {
		math.X * range,
		-math.X * range,
		math.Y * range,
		-math.Y * range,
		math.UP * range,
		-math.UP * range
	}

	if params.parent_name and params.source_unit then
		params.parent_object = params.source_unit:get_object(params.parent_name)
	end

	local dot_type = fire_tweak.dot_type
	local dot_data = self._tweak_data.dot_types[dot_type]
	local action_data = {
		attacker_unit = params.attacker_unit or params.source_unit,
		weapon_unit = params.weapon_unit,
		fire_dot_type = dot_type,
		fire_dot_data = dot_data
	}
	local fire_data = {
		tweak_id = tweak_id,
		tweak_data = fire_tweak,
		splinter_vectors = params.splinter_vectors,
		ticks_left = total_ticks,
		tick_next = time + tick_interval,
		action_data = action_data,
		source_unit = params.source_unit,
		fire_patches = {}
	}

	self:_spawn_sound_and_effects(fire_data, params)
	table.insert(self._active_fires, fire_data)

	return fire_data
end

function FireManager:extinguish_fire(fire_data, remove)
	self:_stop_burn_sound(fire_data)

	fire_data.sound_source = nil

	for i, patch_data in ipairs(fire_data.fire_patches) do
		World:effect_manager():fade_kill(patch_data.effect_id)
	end

	if remove then
		table.delete(self._active_fires, fire_data)
	end
end

function FireManager:_spawn_sound_and_effects(fire_data, params)
	local fire_tweak = fire_data.tweak_data
	local sound_impact = fire_tweak.sound_impact
	local sound_burning = fire_tweak.sound_burning
	local sound_impact_duration = fire_tweak.sound_impact_duration
	fire_data.sound_source = SoundDevice:create_source("fire_source")

	fire_data.sound_source:set_position(params.position)

	if params.parent_object then
		fire_data.sound_source:link(params.parent_object)
	end

	if sound_impact then
		fire_data.sound_source:post_event(sound_impact)
	end

	if sound_burning then
		if sound_impact_duration then
			managers.queued_tasks:queue("fire_start_burning", self._play_burn_sound, self, fire_data, sound_impact_duration)
		else
			self:_play_burn_sound(fire_data)
		end
	end

	params.search_host = params.source_unit and params.source_unit or World

	if mvector3.length(params.normal) < 0.1 then
		params.normal = math.UP
	end

	local type = fire_tweak.type or "single"
	local func = FireSpawners[type]

	if func then
		func(fire_tweak, params, fire_data.fire_patches)
	end
end

function FireManager:_play_burn_sound(fire_data)
	if fire_data.sound_source then
		fire_data.sound_source:post_event(fire_data.tweak_data.sound_burning)
	end
end

function FireManager:_stop_burn_sound(fire_data)
	if not fire_data.sound_source then
		return
	end

	if fire_data.tweak_data.sound_burning_stop then
		fire_data.sound_source:post_event(fire_data.tweak_data.sound_burning_stop)
	else
		fire_data.sound_source:stop()
	end
end

function FireManager:_do_damage_tick(fire_data)
	local fire_tweak = fire_data.tweak_data
	local source_unit = fire_data.source_unit
	local hit_characters = {}
	local attacker_unit = fire_data.action_data.attacker_unit
	local weapon_unit = fire_data.action_data.weapon_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
		fire_data.action_data.attacker_unit = attacker_unit
	end

	if source_unit and not alive(source_unit) then
		fire_data.source_unit = nil
		source_unit = nil
	end

	if attacker_unit and not alive(attacker_unit) then
		fire_data.action_data.attacker_unit = nil
		attacker_unit = nil
	end

	if weapon_unit and not alive(weapon_unit) then
		fire_data.action_data.weapon_unit = nil
		weapon_unit = nil
	end

	local search_host = source_unit or World

	for _, patch_data in ipairs(fire_data.fire_patches) do
		if alive(patch_data.parent_object) then
			local current_pos = patch_data.parent_object:position()
			local previous_pos = patch_data.parent_pos

			if mvector3.distance_sq(current_pos, previous_pos) >= 0.1 then
				patch_data.parent_pos = mvector3.copy(current_pos)

				mvector3.subtract(current_pos, previous_pos)

				patch_data.current_pos = patch_data.current_pos + current_pos

				FireSpawners.recalculate_splinters(patch_data, fire_data.splinter_vectors, search_host, self._slotmask_damage)
			end
		end

		local hit_pos = patch_data.current_pos

		if fire_tweak.alert_radius then
			managers.groupai:state():propagate_alert({
				"fire",
				hit_pos,
				fire_tweak.alert_radius,
				fire_tweak.alert_filter,
				attacker_unit
			})
		end

		local bodies = search_host:find_bodies("intersect", "sphere", hit_pos, fire_tweak.range, self._slotmask_damage)

		for _, hit_body in ipairs(bodies) do
			local hit_unit = hit_body:unit()
			local unit_key = hit_unit:key()
			local damage_ext = hit_unit:character_damage()
			local character = damage_ext and damage_ext.damage_fire and not damage_ext:dead()
			local apply_dmg = hit_body:extension() and hit_body:extension().damage
			local dir = hit_body:center_of_mass()
			local ray_hit = false

			if not character and (apply_dmg or hit_body:dynamic()) then
				ray_hit = true
			elseif character and not hit_characters[unit_key] then
				if fire_tweak.no_raycast_check_characters then
					ray_hit = true
				else
					for _, s_pos in ipairs(patch_data.splinters) do
						ray_hit = not search_host:raycast("ray", s_pos, dir, "slot_mask", self._slotmask_damage, "ignore_unit", hit_unit, "report")

						if ray_hit then
							break
						end
					end
				end
			end

			if ray_hit then
				local is_player = hit_unit:base() and hit_unit:base().is_player

				if Network:is_server() or is_player then
					if character then
						local action_data = {
							is_fire_dot_damage = false,
							variant = "fire",
							attacker_unit = attacker_unit,
							weapon_unit = weapon_unit,
							col_ray = {
								position = hit_body:position(),
								ray = dir
							},
							damage = is_player and fire_tweak.player_damage or fire_tweak.damage,
							fire_dot_type = fire_data.action_data.fire_dot_type,
							fire_dot_data = fire_data.action_data.fire_dot_data
						}

						damage_ext:damage_fire(action_data)

						hit_characters[unit_key] = hit_unit
					elseif apply_dmg then
						self:_apply_body_damage(true, hit_body, attacker_unit, dir, fire_tweak.damage)
					end
				end
			end
		end
	end
end

function FireManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		return
	end

	local prop_damage = math.min(damage, self._tweak_data.PROP_DAMAGE_LIMIT)

	if prop_damage < self._tweak_data.PROP_DAMAGE_PRECISION then
		prop_damage = math.round(prop_damage, self._tweak_data.PROP_DAMAGE_PRECISION)
	end

	if prop_damage == 0 then
		return
	end

	local network_damage = math.ceil(prop_damage * self._tweak_data.NETWORK_DAMAGE_MULTIPLIER)
	prop_damage = network_damage / self._tweak_data.NETWORK_DAMAGE_MULTIPLIER
	local hit_position = hit_body:position()
	local normal = dir

	if local_damage then
		local damage_ext = hit_body:extension().damage

		damage_ext:damage_fire(user_unit, normal, hit_position, dir, prop_damage)
		damage_ext:damage_damage(user_unit, normal, hit_position, dir, prop_damage)
	end

	if sync_damage and managers.network:session() then
		network_damage = math.min(network_damage, self._tweak_data.NETWORK_DAMAGE_LIMIT)

		if alive(user_unit) then
			managers.network:session():send_to_peers_synched("sync_body_damage_fire", hit_body, user_unit, normal, hit_position, dir, network_damage)
		else
			managers.network:session():send_to_peers_synched("sync_body_damage_fire_no_attacker", hit_body, normal, hit_position, dir, network_damage)
		end
	end
end

function FireManager:ignite_character(enemy_unit, effects_table)
	if not alive(enemy_unit) then
		Application:error("[FireManager:ignite_character] Trying to ignite an enemy with missing parameters")

		return
	end

	local bones = self._tweak_data.character_fire_bones
	local effect_name = self._tweak_data.effects.character_endless
	local effect_manager = World:effect_manager()

	for _, bone_name in ipairs(bones) do
		local bone = enemy_unit:get_object(bone_name)

		if bone then
			local effect_id = effect_manager:spawn({
				effect = effect_name,
				parent = bone
			})

			table.insert(effects_table, effect_id)
		end
	end
end

function FireManager:sync_save(data)
	local state = {
		active_fires = {}
	}
	local t = TimerManager:game():time()

	for _, fire_data in ipairs(self._active_fires) do
		local middle_patch = fire_data.fire_patches[1]

		if middle_patch then
			local parent_name = middle_patch.parent_object and middle_patch.parent_object:name()
			local source_unit = alive(fire_data.source_unit) and fire_data.source_unit:id()
			local attacker_unit = alive(fire_data.action_data.attacker_unit) and fire_data.action_data.attacker_unit:id()
			local weapon_unit = alive(fire_data.action_data.weapon_unit) and fire_data.action_data.weapon_unit:id()
			local tick_next = fire_data.tick_next - t
			local save_data = {
				position = middle_patch.current_pos,
				tweak_id = fire_data.tweak_id,
				ticks_left = fire_data.ticks_left,
				tick_next = tick_next,
				source_unit = source_unit,
				attacker_unit = attacker_unit,
				weapon_unit = weapon_unit,
				parent_name = parent_name
			}

			table.insert(state.active_fires, save_data)
		end
	end

	data.FireManager = state
end

function FireManager:sync_load(data)
	local state = data.FireManager

	if not state then
		return
	end

	local unit_manager = World:unit_manager()
	local t = TimerManager:game():time()

	for _, params in ipairs(state.active_fires) do
		local position = params.position
		local tweak_id = params.tweak_id
		params.source_unit = params.source_unit and unit_manager:get_unit_by_id(params.source_unit)
		params.attacker_unit = params.attacker_unit and unit_manager:get_unit_by_id(params.attacker_unit)
		params.weapon_unit = params.weapon_unit and unit_manager:get_unit_by_id(params.weapon_unit)
		local new_fire = self:propagate_fire(position, tweak_id, params)
		new_fire.ticks_left = params.ticks_left
		new_fire.tick_next = t + params.tick_next

		if alive(params.source_unit) and params.source_unit:base() and params.source_unit:base().sync_fire_data then
			params.source_unit:base():sync_fire_data(new_fire)
		end
	end
end
