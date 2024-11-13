local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local empty_idstr = Idstring("")
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
	self._footsteps = {}
	self._queue_fire_raycast = {}
	self._projectile_trails = {}
	self._spawned_warcry_units = {}
	self._spawned_projectiles = {}
	self._spawned_pickups = {}
	self._bullet_hits_max_frame = 0
	self._effect_manager = World:effect_manager()
	self._slotmask_flesh = managers.slot:get_mask("flesh")
	self._slotmask_world_geometry = managers.slot:get_mask("world_geometry")
	self._slotmask_physics_push = managers.slot:get_mask("bullet_physics_push")
	self._slotmask_footstep = managers.slot:get_mask("footstep")
	self._slotmask_bullet_impact_targets = managers.slot:get_mask("bullet_impact_targets")

	self:_init_impact_sources()

	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	self._flashlights_on = lvl_tweak_data and lvl_tweak_data.flashlights_on
	self._dropped_weapons = {
		units = nil,
		index = 1,
		units = {}
	}
	self._flashlights_on_player_on = false

	if lvl_tweak_data and lvl_tweak_data.environment_effects then
		for _, effect in ipairs(lvl_tweak_data.environment_effects) do
			managers.environment_effects:use(effect)
		end
	end

	self._mission_disabled_units = {}
	self._heist_timer = {
		running = false,
		start_time = 0
	}
end

function GamePlayCentralManager:setup_effects(level_id)
	local lvl_id = level_id or Global.level_data and Global.level_data.level_id
	local lvl_tweak_data = Global.level_data and tweak_data.levels[lvl_id]

	if lvl_tweak_data and lvl_tweak_data.environment_effects then
		for _, effect in ipairs(lvl_tweak_data.environment_effects) do
			managers.environment_effects:use(effect)
		end
	end
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
		sources = nil,
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

function GamePlayCentralManager:test_current_weapon_cycle(limited, manual)
	local unit = managers.player:player_unit()
	local weapon = unit:inventory():equipped_unit()
	local blueprints = limited and managers.weapon_factory:create_limited_blueprints(weapon:base()._factory_id) or managers.weapon_factory:create_blueprints(weapon:base()._factory_id)

	self:test_weapon_cycle(weapon, blueprints, manual)
end

function GamePlayCentralManager:test_weapon_cycle(weapon, blueprints, manual)
	self._test_weapon = weapon
	self._test_weapon_force_gadget = not manual
	self._blueprints = blueprints
	self._blueprint_random = not manual
	self._blueprint_i = 1
	self._blueprint_t = not manual and Application:time() or nil
	self._pause_weapon_cycle = false
end

function GamePlayCentralManager:toggle_pause_weapon_cycle()
	self._pause_weapon_cycle = not self._pause_weapon_cycle
end

function GamePlayCentralManager:next_weapon()
	if alive(self._test_weapon) then
		local blueprint = self._blueprint_random and self._blueprints[math.random(#self._blueprints)] or self._blueprints[self._blueprint_i]

		self._test_weapon:base():change_blueprint(blueprint)

		if self._test_weapon_force_gadget then
			self._test_weapon:base():gadget_on()
		end

		self._blueprint_i = self._blueprint_i + 1

		if self._blueprint_i > #self._blueprints then
			self._blueprint_i = 1
		end

		if managers.player:player_unit() then
			managers.player:player_unit():inventory():_send_equipped_weapon()
		end
	end
end

function GamePlayCentralManager:stop_test_weapon_cycle()
	self._test_weapon = nil
end

function GamePlayCentralManager:update(t, dt)
	if alive(self._test_weapon) and self._blueprint_t and self._blueprint_t < t then
		self._blueprint_t = Application:time() + 0.1

		if not self._pause_weapon_cycle then
			self:next_weapon()
		end
	end

	if #self._dropped_weapons.units > 0 then
		local data = self._dropped_weapons.units[self._dropped_weapons.index]
		local unit = data.unit
		data.t = data.t + t - data.last_t
		data.last_t = t
		local alive = alive(unit)

		if not alive then
			table.remove(self._dropped_weapons.units, self._dropped_weapons.index)
		elseif data.state == "wait" then
			if data.t > 4 then
				data.flashlight_data.light:set_enable(false)
				data.flashlight_data.effect:kill_effect()

				data.state = "off"
				data.t = 0
			end
		elseif data.state == "off" then
			if data.t > 0.2 then
				data.flashlight_data.light:set_enable(true)
				data.flashlight_data.effect:activate()

				data.state = "on"
				data.t = 0
			end
		elseif data.state == "on" and data.t > 0.1 then
			data.flashlight_data.light:set_enable(false)
			data.flashlight_data.effect:kill_effect()
			table.remove(self._dropped_weapons.units, self._dropped_weapons.index)
		end

		self._dropped_weapons.index = self._dropped_weapons.index + 1
		self._dropped_weapons.index = self._dropped_weapons.index <= #self._dropped_weapons.units and self._dropped_weapons.index or 1
	end

	if self._heist_timer.running then
		managers.hud:feed_session_time(Application:time() - self._heist_timer.start_time + self._heist_timer.offset_time)

		if Network:is_server() and self._heist_timer.next_sync < Application:time() then
			self._heist_timer.next_sync = Application:time() + 9
			local heist_time = Application:time() - self._heist_timer.start_time

			for peer_id, peer in pairs(managers.network:session():peers()) do
				local sync_time = math.min(100000, heist_time + Network:qos(peer:rpc()).ping / 1000)

				peer:send_queued_sync("sync_heist_time", sync_time)
			end
		end
	end
end

function GamePlayCentralManager:end_update(t, dt)
	self._camera_pos = managers.viewport:get_current_camera_position()

	self:_flush_bullet_hits()
	self:_flush_play_effects()
	self:_flush_play_sounds()
	self:_flush_footsteps()
	self:_flush_queue_fire_raycast()
end

function GamePlayCentralManager:play_impact_sound_and_effects(params)
	if params and not table.empty(params) then
		table.insert(self._bullet_hits, params)
	end
end

function GamePlayCentralManager:request_play_footstep(unit, m_pos)
	if self._camera_pos then
		local dis = mvector3.distance_sq(self._camera_pos, m_pos)

		if dis < 250000 and #self._footsteps < 3 then
			table.insert(self._footsteps, {
				dis = nil,
				unit = nil,
				unit = unit,
				dis = dis
			})
		end
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

		if managers.player:player_unit() and mvector3.distance_sq(col_ray.position, managers.player:player_unit():movement():m_head_pos()) < 40000 then
			self._effect_manager:spawn({
				effect = nil,
				rotation = nil,
				position = nil,
				effect = idstr_blood_screen,
				position = Vector3(),
				rotation = Rotation()
			})
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
		effect = nil,
		normal = nil,
		position = nil,
		effect = idstr_bullet_hit_blood,
		position = from,
		normal = dir
	})

	if managers.player:player_unit() and mvector3.distance_sq(splatter_from, managers.player:player_unit():movement():m_head_pos()) < 40000 then
		self._effect_manager:spawn({
			effect = nil,
			rotation = nil,
			position = nil,
			effect = idstr_blood_screen,
			position = Vector3(),
			rotation = Rotation()
		})
	end

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
		table.insert(self._spawned_pickups, unit)
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
	material_name = material_name ~= empty_idstr and material_name
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

		if redir_name == empty_idstr then
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
				effect = nil,
				normal = nil,
				position = nil,
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
				effect = nil,
				normal = nil,
				position = nil,
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
			event = nil,
			sound_switch_name = nil,
			position = nil,
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
		effect = nil,
		normal = nil,
		position = nil,
		effect = effect or redir_name,
		position = position,
		normal = spawn_1
	})

	local spawn_2 = Vector3(-1, 1, 0):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = nil,
		normal = nil,
		position = nil,
		effect = effect or redir_name,
		position = position,
		normal = spawn_2
	})

	local spawn_3 = Vector3(1, 0, 1):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = nil,
		normal = nil,
		position = nil,
		effect = effect or redir_name,
		position = position,
		normal = spawn_3
	})

	local spawn_4 = Vector3(-1, 0, 1):rotate_with(spawn_rotation)

	table.insert(effects, {
		effect = nil,
		normal = nil,
		position = nil,
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

function GamePlayCentralManager:_flush_footsteps()
	local footstep = table.remove(self._footsteps, 1)

	if footstep and alive(footstep.unit) then
		local sound_switch_name = nil

		if footstep.dis < 2000 then
			local ext_movement = footstep.unit:movement()
			local decal_ray_from = tmp_vec1
			local decal_ray_to = tmp_vec2

			mvector3.set(decal_ray_from, ext_movement:m_head_pos())
			mvector3.set(decal_ray_to, math.UP)
			mvector3.multiply(decal_ray_to, -250)
			mvector3.add(decal_ray_to, decal_ray_from)

			local material_name, pos, norm = nil
			local ground_ray = ext_movement:ground_ray()

			if ground_ray and ground_ray.unit then
				material_name, pos, norm = World:pick_decal_material(ground_ray.unit, decal_ray_from, decal_ray_to, self._slotmask_footstep)
			else
				material_name, pos, norm = World:pick_decal_material(decal_ray_from, decal_ray_to, self._slotmask_footstep)
			end

			material_name = material_name ~= empty_idstr and material_name

			if material_name then
				sound_switch_name = material_name
			else
				sound_switch_name = idstr_no_material
			end
		else
			sound_switch_name = idstr_concrete
		end

		local sound_source = footstep.unit:sound_source()

		sound_source:set_switch("materials", self:material_name(sound_switch_name))

		local event = footstep.unit:movement():get_footstep_event()

		sound_source:post_event(event)
	end
end

function GamePlayCentralManager:weapon_dropped(weapon)
	local flashlight_data = weapon:base():flashlight_data()

	if not flashlight_data then
		return
	end

	flashlight_data.dropped = true

	if not weapon:base():has_flashlight_on() then
		return
	end

	weapon:set_flashlight_light_lod_enabled(true)
	table.insert(self._dropped_weapons.units, {
		flashlight_data = nil,
		state = "wait",
		last_t = nil,
		t = 0,
		unit = nil,
		unit = weapon,
		flashlight_data = flashlight_data,
		last_t = Application:time()
	})
end

function GamePlayCentralManager:set_flashlights_on(flashlights_on)
	if self._flashlights_on == flashlights_on then
		return
	end

	self._flashlights_on = flashlights_on
	local weapons = World:find_units_quick("all", 13)

	for _, weapon in ipairs(weapons) do
		if weapon:base().flashlight_state_changed then
			weapon:base():flashlight_state_changed()
		end
	end
end

function GamePlayCentralManager:flashlights_on()
	return self._flashlights_on
end

function GamePlayCentralManager:set_flashlights_on_player_on(flashlights_on_player_on)
	if self._flashlights_on_player_on == flashlights_on_player_on then
		return
	end

	self._flashlights_on_player_on = flashlights_on_player_on
	local player_unit = managers.player:player_unit()

	if player_unit and alive(player_unit:camera():camera_unit()) then
		player_unit:camera():camera_unit():base():check_flashlight_enabled()
	end
end

function GamePlayCentralManager:flashlights_on_player_on()
	return self._flashlights_on_player_on
end

function GamePlayCentralManager:on_simulation_ended()
	self:set_flashlights_on(false)
	self:set_flashlights_on_player_on(false)
	self:stop_heist_timer()

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
end

function GamePlayCentralManager:mission_disable_unit(unit, destroy)
	if alive(unit) then
		self._mission_disabled_units[unit:unit_data().unit_id] = true

		unit:set_enabled(false)

		if unit:base() and unit:base().on_unit_set_enabled then
			unit:base():on_unit_set_enabled(false)
		end

		if unit:editable_gui() then
			unit:editable_gui():on_unit_set_enabled(false)
		end

		if destroy then
			unit:set_slot(0)
		end
	else
		Application:warn("[GamePlayCentralManager:mission_disable_unit] Cannot disable unit, unit is not alive!", unit)
	end
end

function GamePlayCentralManager:mission_enable_unit(unit)
	if alive(unit) then
		self._mission_disabled_units[unit:unit_data().unit_id] = nil

		unit:set_enabled(true)

		if unit:base() and unit:base().on_unit_set_enabled then
			unit:base():on_unit_set_enabled(true)
		end

		if unit:editable_gui() then
			unit:editable_gui():on_unit_set_enabled(true)
		end
	else
		Application:warn("[GamePlayCentralManager:mission_enable_unit] Cannot enable unit, unit is not alive!", unit)
	end
end

function GamePlayCentralManager:get_heist_timer()
	return self._heist_timer and Application:time() - (self._heist_timer.start_time or 0) + (self._heist_timer.offset_time or 0) or 0
end

function GamePlayCentralManager:start_heist_timer()
	self._heist_timer.running = true
	self._heist_timer.start_time = Application:time()
	self._heist_timer.offset_time = 0
	self._heist_timer.next_sync = Application:time() + 10
end

function GamePlayCentralManager:stop_heist_timer()
	self._heist_timer.running = false
end

function GamePlayCentralManager:sync_heist_time(heist_time)
	self._heist_timer.offset_time = heist_time
	self._heist_timer.start_time = Application:time()
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
		weapon_unit = nil,
		expire_t = nil,
		data = nil,
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

function GamePlayCentralManager:announcer_say(event)
	Application:warn("[GamePlayCentralManager:announcer_say] This is being removed!")
end

function GamePlayCentralManager:save(data)
	local state = {
		heist_timer_running = nil,
		heist_timer = nil,
		mission_disabled_units = nil,
		flashlights_on = nil,
		flashlights_on_player_on = nil,
		flashlights_on = self._flashlights_on,
		mission_disabled_units = self._mission_disabled_units,
		flashlights_on_player_on = self._flashlights_on_player_on,
		heist_timer = Application:time() - self._heist_timer.start_time,
		heist_timer_running = self._heist_timer.running
	}
	data.GamePlayCentralManager = state
end

function GamePlayCentralManager:load(data)
	local state = data.GamePlayCentralManager

	self:set_flashlights_on(state.flashlights_on)
	self:set_flashlights_on_player_on(state.flashlights_on_player_on)

	if state.mission_disabled_units then
		managers.worldcollection:add_world_loaded_callback(self)

		self._mission_disabled_units = state.mission_disabled_units
	end

	if state.heist_timer then
		self._heist_timer.offset_time = state.heist_timer
		self._heist_timer.start_time = Application:time()
		self._heist_timer.running = state.heist_timer_running
	end
end

function GamePlayCentralManager:on_world_loaded()
	Application:debug("[GamePlayCentralManager:on_world_loaded()]")

	for id, _ in pairs(self._mission_disabled_units) do
		local worlddefinition = managers.worldcollection and managers.worldcollection:get_worlddefinition_by_unit_id(id) or managers.worlddefinition
		local original_unit_id = worlddefinition:get_original_unit_id(id)

		self:mission_disable_unit(worlddefinition:get_unit_on_load(original_unit_id, callback(self, self, "mission_disable_unit")))
	end
end

function GamePlayCentralManager:on_level_transition()
	self._mission_disabled_units = {}
	self._bullet_hits = {}
	self._queue_fire_raycast = {}
	self._projectile_trails = {}
	self._spawned_pickups = {}
end

function GamePlayCentralManager:debug_weapon()
	managers.debug:set_enabled(true)
	managers.debug:set_systems_enabled(true, {
		"gui"
	})

	local gui = managers.debug._system_list.gui
	local tweak_data = tweak_data.weapon.stats

	gui:clear()

	local function add_func()
		if not managers.player:player_unit() or not managers.player:player_unit():alive() then
			return ""
		end

		local unit = managers.player:player_unit()
		local weapon = unit:inventory():equipped_unit()
		local blueprint = weapon:base()._blueprint
		local parts_stats = managers.weapon_factory:debug_get_stats(weapon:base()._factory_id, blueprint)

		local function add_line(text, s)
			return text .. s .. "\n"
		end

		local text = ""
		text = add_line(text, weapon:base()._name_id)
		local base_stats = weapon:base():weapon_tweak_data().stats
		local stats = base_stats and deep_clone(base_stats) or {}

		for part_id, part in pairs(parts_stats) do
			for stat_id, stat in pairs(part) do
				if not stats[stat_id] then
					stats[stat_id] = 0
				end

				stats[stat_id] = math.clamp(stats[stat_id] + stat, 1, #tweak_data[stat_id])
			end
		end

		for stat_id, stat in pairs(stats) do
			if stat_id ~= "damage" then
				text = add_line(text, "         " .. stat_id .. " " .. stat)
			end
		end

		for part_id, part in pairs(parts_stats) do
			text = add_line(text, part_id)

			for stat_id, stat in pairs(part) do
				if stat_id ~= "damage" then
					text = add_line(text, "         " .. stat_id .. " " .. stat)
				end
			end
		end

		return text
	end

	gui:set_func(1, add_func)
	gui:set_color(1, 1, 1, 1)
end
