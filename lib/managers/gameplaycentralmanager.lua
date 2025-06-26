local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local idstr_concrete = Idstring("concrete")
local idstr_blood_spatter = Idstring("blood_spatter")
local idstr_no_material = Idstring("no_material")
local idstr_bullet_hit = Idstring("bullet_hit")
local idstr_blood_screen = tweak_data.common_effects.blood_screen
local idstr_bullet_hit_blood = tweak_data.common_effects.blood_impact_1
local idstr_pellet_hit_blood = tweak_data.common_effects.blood_impact_3
local idstr_fallback = tweak_data.common_effects.impact
local mvec_1 = Vector3()
local mvec_2 = Vector3()
GamePlayCentralManager = GamePlayCentralManager or class()
GamePlayCentralManager.MAX_BULLET_HITS_PERFRAME = 5

function GamePlayCentralManager:init()
	self._bullet_hits = {}
	self._play_effects = {}
	self._play_sounds = {}
	self._queue_fire_raycast = {}

	if Application:editor() then
		self._spawned_warcry_units = {}
		self._spawned_projectiles = {}
		self._spawned_pickups = {}
		self._dropped_weapons = {}
	end

	self._bullet_hits_max_frame = 0
	self._effect_manager = World:effect_manager()
	self._slotmask_flesh = managers.slot:get_mask("flesh")
	self._slotmask_world_geometry = managers.slot:get_mask("world_geometry")
	self._slotmask_physics_push = managers.slot:get_mask("bullet_physics_push")
	self._slotmask_bullet_impact_targets = managers.slot:get_mask("bullet_impact_targets")

	self:_init_impact_sources()

	self._mission_disabled_units = {}
	self._mission_destroyed_units = {}
	self._job_timer = {
		running = false,
		start_time = 0
	}
end

function GamePlayCentralManager:restart_portal_effects()
	if not self._portal_effects_restarted then
		self._portal_effects_restarted = true

		if Network:is_client() then
			managers.portal:restart_effects()
		end
	end
end

function GamePlayCentralManager:_init_impact_sources()
	self._impact_sounds = {
		index = 1,
		sources = {}
	}

	for i = 1, 20 do
		table.insert(self._impact_sounds.sources, SoundDevice:create_source("impact_sound" .. i))
	end

	self._impact_sounds.max_index = #self._impact_sounds.sources
end

function GamePlayCentralManager:_get_impact_source()
	local source = self._impact_sounds.sources[self._impact_sounds.index]
	self._impact_sounds.index = self._impact_sounds.index < self._impact_sounds.max_index and self._impact_sounds.index + 1 or 1

	return source
end

function GamePlayCentralManager:update(t, dt)
	if self._job_timer.running then
		local heist_time = t - self._job_timer.start_time

		managers.hud:feed_session_time(heist_time + self._job_timer.offset_time)

		if Network:is_server() and self._job_timer.next_sync < t then
			self._job_timer.next_sync = t + 9

			for _, peer in pairs(managers.network:session():peers()) do
				local sync_time = math.min(100000, heist_time + Network:qos(peer:rpc()).ping / 1000)

				peer:send_queued_sync("sync_job_time", sync_time)
			end
		end
	end
end

function GamePlayCentralManager:end_update(t, dt)
	self._camera_pos = managers.viewport:get_current_camera_position()

	self:_flush_bullet_hits()
	self:_flush_play_effects()
	self:_flush_play_sounds()
	self:_flush_queue_fire_raycast()
end

function GamePlayCentralManager:play_impact_sound_and_effects(params)
	if params and not table.empty(params) then
		table.insert(self._bullet_hits, params)
	end
end

function GamePlayCentralManager:physics_push(col_ray, push_multiplier)
	local unit = col_ray.unit
	push_multiplier = push_multiplier or 1

	if unit:in_slot(self._slotmask_physics_push) then
		local body = col_ray.body

		if not body:dynamic() then
			local original_body_com = body:center_of_mass()
			local closest_body_dis_sq = nil
			local nr_bodies = unit:num_bodies()
			local i_body = 0

			while nr_bodies > i_body do
				local test_body = unit:body(i_body)

				if test_body:enabled() and test_body:dynamic() then
					local test_dis_sq = mvector3.distance_sq(test_body:center_of_mass(), original_body_com)

					if not closest_body_dis_sq or test_dis_sq < closest_body_dis_sq then
						closest_body_dis_sq = test_dis_sq
						body = test_body
					end
				end

				i_body = i_body + 1
			end
		end

		local body_mass = math.min(50, body:mass()) * push_multiplier
		local len = mvector3.distance(col_ray.position, body:center_of_mass())
		local body_vel = body:velocity()

		mvector3.set(tmp_vec1, col_ray.ray)

		local vel_dot = mvector3.dot(body_vel, tmp_vec1)
		local max_vel = 600

		if vel_dot < max_vel then
			local push_vel = max_vel - math.max(vel_dot, 0)
			push_vel = math.lerp(push_vel * 0.7, push_vel, math.random()) * push_multiplier

			mvector3.multiply(tmp_vec1, push_vel)
			body:push_at(body_mass, tmp_vec1, col_ray.position)
		end
	end
end

function GamePlayCentralManager:play_impact_flesh(params)
	local col_ray = params.col_ray

	if alive(col_ray.unit) and col_ray.unit:in_slot(self._slotmask_flesh) then
		local splatter_from = col_ray.position
		local splatter_to = col_ray.position + col_ray.ray * 1000
		local splatter_ray = col_ray.unit:raycast("ray", splatter_from, splatter_to, "slot_mask", self._slotmask_world_geometry)

		if splatter_ray then
			World:project_decal(idstr_blood_spatter, splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
		end
	end
end

function GamePlayCentralManager:sync_play_impact_flesh(from, dir)
	local splatter_from = from
	local splatter_to = from + dir * 1000
	local splatter_ray = World:raycast("ray", splatter_from, splatter_to, "slot_mask", self._slotmask_world_geometry)

	if splatter_ray then
		World:project_decal(idstr_blood_spatter, splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
	end

	self._effect_manager:spawn({
		effect = idstr_bullet_hit_blood,
		position = from,
		normal = dir
	})

	local sound_source = self:_get_impact_source()

	sound_source:stop()
	sound_source:set_position(from)
	sound_source:set_switch("materials", "flesh")
	sound_source:post_event("bullet_hit")
end

function GamePlayCentralManager:material_name(idstring)
	local material = tweak_data.materials[idstring:key()]

	return material or "no_material"
end

function GamePlayCentralManager:spawn_pickup(params)
	if not tweak_data.pickups[params.name] then
		Application:error("No pickup definition for " .. tostring(params.name))

		return
	end

	local unit_name = tweak_data.pickups[params.name].unit
	local unit = World:spawn_unit(unit_name, params.position, params.rotation)

	if Application:editor() then
		table.insert(self._spawned_pickups, unit)
	else
		managers.worldcollection:register_spawned_unit(unit, params.position, params.world_id)
	end

	return unit
end

function GamePlayCentralManager:spawn_warcry_unit(params)
	local tweak = tweak_data.warcry_units[params.name]

	if not tweak then
		Application:error("No warcry unit definition for " .. tostring(params.name))

		return
	end

	mvector3.set(mvec_1, params.position)

	if tweak.drop_to_ground then
		mvector3.set(mvec_2, math.UP)
		mvector3.multiply(mvec_2, -10000)
		mvector3.add(mvec_2, mvec_1)

		local ray = World:raycast("ray", mvec_1, mvec_2, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

		if ray then
			mvector3.set(mvec_1, ray.hit_position)
		end
	end

	local unit = World:spawn_unit(tweak.unit, mvec_1, params.rotation)

	if Application:editor() then
		table.insert(self._spawned_warcry_units, unit)
	else
		managers.worldcollection:register_spawned_unit(unit, mvec_1, params.world_id)
	end

	if unit:damage() and tweak.level_seq and params.level then
		unit:damage():run_sequence_simple(tweak.level_seq[params.level])
	end

	return unit
end

function GamePlayCentralManager:add_spawned_projectiles(unit, world_id)
	if Application:editor() then
		table.insert(self._spawned_projectiles, unit)
	else
		managers.worldcollection:register_spawned_unit(unit, unit:position(), world_id)
	end

	return unit
end

function GamePlayCentralManager:add_dropped_weapon(unit)
	if Application:editor() then
		table.insert(self._dropped_weapons, unit)
	else
		managers.worldcollection:register_spawned_unit(unit, unit:position())
	end
end

function GamePlayCentralManager:_flush_bullet_hits()
	while not table.empty(self._bullet_hits) do
		self:_play_bullet_hit(table.remove(self._bullet_hits, 1))

		if not self._bullet_hits_max_frame or GamePlayCentralManager.MAX_BULLET_HITS_PERFRAME < self._bullet_hits_max_frame then
			self._bullet_hits_max_frame = 0

			break
		else
			self._bullet_hits_max_frame = self._bullet_hits_max_frame + 1
		end
	end
end

function GamePlayCentralManager:_flush_play_effects()
	while #self._play_effects > 0 do
		self._effect_manager:spawn(table.remove(self._play_effects, 1))
	end
end

function GamePlayCentralManager:_flush_play_sounds()
	while #self._play_sounds > 0 do
		self:_play_sound(table.remove(self._play_sounds, 1))
	end
end

local zero_vector = Vector3()

function GamePlayCentralManager:_play_bullet_hit(params)
	local hit_pos = params.col_ray.position
	local need_sound = not params.no_sound and World:in_view_with_options(hit_pos, 2000, 0, 0)
	local need_effect = World:in_view_with_options(hit_pos, 20, 100, 5000)
	local need_decal = not params.no_decal and need_effect and World:in_view_with_options(hit_pos, 3000, 0, 0)

	if not need_sound and not need_effect and not need_decal then
		return
	end

	if not alive(params.col_ray.unit) then
		return
	end

	local col_ray = params.col_ray
	local event = params.event or "bullet_hit"
	local decal = params.decal and Idstring(params.decal) or idstr_bullet_hit
	local slot_mask = params.slot_mask or self._slotmask_bullet_impact_targets
	local sound_switch_name = nil
	local decal_ray_from = tmp_vec1
	local decal_ray_to = tmp_vec2

	mvector3.set(decal_ray_from, col_ray.ray)
	mvector3.set(decal_ray_to, hit_pos)
	mvector3.multiply(decal_ray_from, 25)
	mvector3.add(decal_ray_to, decal_ray_from)
	mvector3.negate(decal_ray_from)
	mvector3.add(decal_ray_from, hit_pos)

	local material_name, pos, norm = World:pick_decal_material(col_ray.unit, decal_ray_from, decal_ray_to, slot_mask)
	material_name = material_name ~= IDS_EMPTY and material_name
	local effect = params.effect
	local effects = {}

	if material_name then
		local offset = col_ray.sphere_cast_radius and col_ray.ray * col_ray.sphere_cast_radius or zero_vector
		local redir_name = nil

		if need_decal then
			redir_name, pos, norm = World:project_decal(decal, hit_pos + offset, col_ray.ray, col_ray.unit, math.UP, col_ray.normal)
		elseif need_effect then
			redir_name, pos, norm = World:pick_decal_effect(decal, col_ray.unit, decal_ray_from, decal_ray_to, slot_mask)
		end

		if redir_name == IDS_EMPTY then
			redir_name = idstr_fallback
		end

		if need_effect then
			if params.weapon_type then
				if params.weapon_type and (params.weapon_type == WeaponTweakData.WEAPON_CATEGORY_MOUNTED_TURRET or params.weapon_type == WeaponTweakData.WEAPON_CATEGORY_MOUNTED_AAGUN) then
					self:_turret_effect(effects, effect or redir_name, col_ray.normal, hit_pos + offset)
				elseif redir_name == idstr_bullet_hit_blood and params.weapon_type == WeaponTweakData.WEAPON_CATEGORY_SHOTGUN then
					effect = idstr_pellet_hit_blood
				end
			end

			table.insert(effects, {
				effect = effect or redir_name,
				position = hit_pos + offset,
				normal = col_ray.normal
			})
		end

		sound_switch_name = need_sound and material_name
	else
		if need_effect then
			local generic_effect = effect or idstr_fallback

			table.insert(effects, {
				effect = generic_effect,
				position = hit_pos,
				normal = col_ray.normal
			})

			if params.weapon_type and (params.weapon_type == WeaponTweakData.WEAPON_CATEGORY_MOUNTED_TURRET or params.weapon_type == WeaponTweakData.WEAPON_CATEGORY_MOUNTED_AAGUN) then
				self:_turret_effect(effects, generic_effect, col_ray.normal, hit_pos)
			end
		end

		sound_switch_name = need_sound and idstr_no_material
	end

	for _, effect in ipairs(effects) do
		table.insert(self._play_effects, effect)
	end

	if need_sound then
		table.insert(self._play_sounds, {
			sound_switch_name = sound_switch_name,
			position = hit_pos,
			event = event
		})
	end
end

function GamePlayCentralManager:_turret_effect(effects, effect, normal, position)
	local spawn_rotation = Rotation(normal, math.UP)
	local spawn_1 = Vector3(1, 1, 0):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = effect or redir_name,
		position = position,
		normal = spawn_1
	})

	local spawn_2 = Vector3(-1, 1, 0):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = effect or redir_name,
		position = position,
		normal = spawn_2
	})

	local spawn_3 = Vector3(1, 0, 1):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = effect or redir_name,
		position = position,
		normal = spawn_3
	})

	local spawn_4 = Vector3(-1, 0, 1):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = effect or redir_name,
		position = position,
		normal = spawn_4
	})
end

function GamePlayCentralManager:_play_sound(params)
	local sound_source = self:_get_impact_source()

	sound_source:stop()
	sound_source:set_position(params.position)
	sound_source:set_switch("car_switch", "outside")
	sound_source:set_switch("materials", self:material_name(params.sound_switch_name))

	local result = sound_source:post_event(params.event)
end

function GamePlayCentralManager:on_simulation_ended()
	self:stop_job_timer()

	self._mission_disabled_units = {}
	self._mission_destroyed_units = {}
	self._bullet_hits = {}
	self._queue_fire_raycast = {}

	local function _clean_me(tbl)
		for i = #tbl, 1, -1 do
			if alive(tbl[i]) then
				tbl[i]:set_slot(0)
			end

			tbl[i] = nil
		end
	end

	_clean_me(self._spawned_pickups)
	_clean_me(self._spawned_projectiles)
	_clean_me(self._spawned_warcry_units)
	_clean_me(self._dropped_weapons)
end

function GamePlayCentralManager:mission_disable_unit(unit, destroy)
	if alive(unit) then
		if self._mission_destroyed_units[unit:unit_data().unit_id] then
			return
		end

		if destroy then
			self._mission_disabled_units[unit:unit_data().unit_id] = nil
			self._mission_destroyed_units[unit:unit_data().unit_id] = true

			unit:set_slot(0)
		else
			self._mission_disabled_units[unit:unit_data().unit_id] = true

			self:_set_unit_mission_enabled(unit, false)
		end
	else
		Application:warn("[GamePlayCentralManager:mission_disable_unit] Cannot disable unit, unit is not alive! (This may be fine if multiple disables destroy this unit)", unit)
	end
end

function GamePlayCentralManager:mission_enable_unit(unit)
	if alive(unit) then
		if self._mission_destroyed_units[unit:unit_data().unit_id] then
			return
		end

		self._mission_disabled_units[unit:unit_data().unit_id] = nil

		self:_set_unit_mission_enabled(unit, true)
	else
		Application:warn("[GamePlayCentralManager:mission_enable_unit] Cannot enable unit, unit is not alive!", unit)
	end
end

function GamePlayCentralManager:_set_unit_mission_enabled(unit, state)
	unit:set_enabled(state)

	for _, ext_name in ipairs(unit:extensions()) do
		local extension = unit[ext_name](unit)

		if extension.on_unit_set_enabled then
			extension:on_unit_set_enabled(state)
		end
	end
end

function GamePlayCentralManager:get_job_timer()
	return self._job_timer and Application:time() - (self._job_timer.start_time or 0) + (self._job_timer.offset_time or 0) or 0
end

function GamePlayCentralManager:start_job_timer()
	self._job_timer.running = true
	self._job_timer.start_time = Application:time()
	self._job_timer.offset_time = 0
	self._job_timer.next_sync = Application:time() + 10
end

function GamePlayCentralManager:stop_job_timer()
	self._job_timer.running = false
end

function GamePlayCentralManager:sync_job_time(job_time)
	self._job_timer.offset_time = job_time
	self._job_timer.start_time = Application:time()
end

function GamePlayCentralManager:restart_the_game()
	Application:debug("[GamePlayCentralManager:restart_the_game]")
	managers.challenge_cards:on_restart_to_camp()
	managers.raid_job:stop_sounds()
	managers.raid_job:on_restart_to_camp()
	managers.loot:on_restart_to_camp()
	managers.mission:on_restart_to_camp()
	managers.criminals:on_mission_end_callback()
	managers.vehicle:on_restart_to_camp()
	managers.airdrop:cleanup()
	managers.enemy:remove_delayed_clbk("_gameover_clbk")

	local restart_camp = managers.raid_job:is_camp_loaded()

	managers.raid_job:external_end_mission(restart_camp, true)
end

function GamePlayCentralManager:restart_the_mission()
	managers.raid_job.reload_mission_flag = true

	managers.worldcollection:add_one_package_ref_to_all()

	managers.raid_job._selected_job = managers.raid_job._current_job

	managers.raid_job:on_mission_restart()
	managers.raid_job:stop_sounds()
	Application:debug("[AirdropManager] cleanup from GamePlayCentralManager:restart_the_mission")
	managers.airdrop:cleanup()
	managers.loot:reset()
	managers.enemy:remove_delayed_clbk("_gameover_clbk")
	managers.global_state:fire_event("system_start_raid")
end

function GamePlayCentralManager:set_restarting(value)
	self._restarting = value
end

function GamePlayCentralManager:is_restarting(value)
	return self._restarting
end

function GamePlayCentralManager:stop_the_game()
	Application:trace("[GamePlayCentralManager:stop_the_game()]")
	World:set_extensions_update_enabled(false)
	game_state_machine:change_state_by_name("ingame_standard")
	managers.loot:reset()
	managers.raid_job:stop_sounds()
	managers.statistics:stop_session()
	managers.savefile:save_setting(true)
	managers.savefile:save_progress()
	managers.worldcollection:on_simulation_ended()
	Application:debug("[AirdropManager] cleanup from GamePlayCentralManager:stop_the_game")
	managers.airdrop:cleanup()
	managers.groupai:state():set_AI_enabled(false)
	managers.menu:destroy()
	managers.video:init()

	if Network:multiplayer() and managers.network:session() then
		local peer = managers.network:session():local_peer()

		if peer then
			peer:unit_delete()
		end
	end
end

function GamePlayCentralManager:queue_fire_raycast(expire_t, weapon_unit, ...)
	self._queue_fire_raycast = self._queue_fire_raycast or {}
	local data = {
		expire_t = expire_t,
		weapon_unit = weapon_unit,
		data = {
			...
		}
	}

	table.insert(self._queue_fire_raycast, data)
end

function GamePlayCentralManager:_flush_queue_fire_raycast()
	local i = 1

	while i <= #self._queue_fire_raycast do
		local ray_data = self._queue_fire_raycast[i]

		if ray_data.expire_t < Application:time() then
			table.remove(self._queue_fire_raycast, i)

			local data = ray_data.data
			local player_unit = data[1]

			if alive(ray_data.weapon_unit) and alive(player_unit) then
				ray_data.weapon_unit:base():_fire_raycast(unpack(data))
			end
		else
			i = i + 1
		end
	end
end

function GamePlayCentralManager:auto_highlight_enemy(unit, use_player_upgrades)
	if not unit:contour() then
		debug_pause_unit(unit, "[GamePlayCentralManager:auto_highlight_enemy]: Unit doesn't have Contour Extension")

		return false
	end

	local contour_type = "mark_enemy"
	local time_multiplier = 1
	local damage_multiplier = 1

	if use_player_upgrades then
		time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
		damage_multiplier = managers.player:upgrade_value("player", "big_game_highlight_enemy_multiplier", 1)

		if damage_multiplier > 1 then
			contour_type = "mark_enemy_damage_bonus"
		end
	end

	local dmg_mul = unit:character_damage():marked_dmg_mul()

	if dmg_mul and damage_multiplier < dmg_mul then
		return false
	end

	if unit:unit_data().turret_weapon then
		unit:unit_data().turret_weapon:mark_turret({
			contour_type,
			true,
			time_multiplier,
			damage_multiplier
		})
	else
		unit:contour():add(contour_type, true, time_multiplier, damage_multiplier)
	end

	return true
end

function GamePlayCentralManager:do_shotgun_push(unit, hit_pos, dir, distance)
	local HARDCODED_DISTANCE = 500

	if distance > HARDCODED_DISTANCE then
		return
	end

	local HARDCODED_STRENGTH = 40

	if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
		unit:movement()._active_actions[1]:force_ragdoll()
	end

	local height = mvector3.distance(hit_pos, unit:position()) - 100
	local twist_dir = math.rand_bool() and 1 or -1
	local rot_acc = (dir:cross(math.UP) + math.UP * 0.175 * twist_dir) * -1000 * math.sign(height)
	local rot_time = 0.5 + math.rand(0.5)
	local nr_u_bodies = unit:num_bodies()
	local i_u_body = 0

	while nr_u_bodies > i_u_body do
		local u_body = unit:body(i_u_body)

		if u_body:enabled() and u_body:dynamic() then
			local pvec3 = Vector3(dir.x, dir.y, dir.z * 0.3 + 0.4):normalized()

			World:play_physic_effect(tweak_data.physics_effects.shotgun_push, u_body, pvec3, HARDCODED_STRENGTH, rot_acc, rot_time)
		end

		i_u_body = i_u_body + 1
	end
end

function GamePlayCentralManager:save(data)
	local state = {
		job_timer = Application:time() - self._job_timer.start_time,
		job_timer_running = self._job_timer.running,
		mission_disabled_units = self._mission_disabled_units,
		mission_destroyed_units = self._mission_destroyed_units
	}
	data.GamePlayCentralManager = state
end

function GamePlayCentralManager:load(data)
	local state = data.GamePlayCentralManager

	if state.mission_disabled_units then
		self._mission_disabled_units = state.mission_disabled_units
		self._mission_destroyed_units = state.mission_destroyed_units

		managers.worldcollection:add_world_loaded_callback(self)
	end

	if state.job_timer then
		self._job_timer.start_time = Application:time()
		self._job_timer.offset_time = state.job_timer
		self._job_timer.running = state.job_timer_running
	end
end

function GamePlayCentralManager:on_world_loaded()
	Application:debug("[GamePlayCentralManager:on_world_loaded()]")

	for id, _ in pairs(self._mission_disabled_units) do
		local worlddefinition = managers.worldcollection and managers.worldcollection:get_worlddefinition_by_unit_id(id) or managers.worlddefinition
		local original_unit_id = worlddefinition:get_original_unit_id(id)

		self:mission_disable_unit(worlddefinition:get_unit_on_load(original_unit_id, callback(self, self, "mission_disable_unit")))
	end

	for id, _ in pairs(self._mission_destroyed_units) do
		local worlddefinition = managers.worldcollection and managers.worldcollection:get_worlddefinition_by_unit_id(id) or managers.worlddefinition
		local original_unit_id = worlddefinition:get_original_unit_id(id)

		self:mission_disable_unit(worlddefinition:get_unit_on_load(original_unit_id, callback(self, self, "mission_disable_unit", true)))
	end
end

function GamePlayCentralManager:on_level_transition()
	self._mission_disabled_units = {}
	self._mission_destroyed_units = {}
	self._bullet_hits = {}
	self._queue_fire_raycast = {}
end
