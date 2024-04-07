BarrageManager = BarrageManager or class()
BarrageManager.MIN_DELAY_VARIANCE = 0.5
BarrageManager.MAX_DELAY_VARIANCE = 2
BarrageManager.DEFAULT_DISTANCE = 3000
BarrageManager.FLARE_SHOOT_ELEVATION = 45
BarrageManager.FLARE_MASS = 0.4
BarrageManager.SPOTTER_COOLDOWN = 10
BarrageManager.FLARE_UNIT = Idstring("units/vanilla/props/props_flare/props_spotter_flare")
BarrageManager.default_params = tweak_data.barrage.default

function BarrageManager:init()
	self._running_barrages = {}
	self._listener_holder = EventListenerHolder:new()
	self._spotters = {}
	self._flares = {}
	self._spotter_barrage_type = BarrageManager.default_params
	self._queued_projectiles = {}
	self._soundsource = SoundDevice:create_source("barrage_launch")
end

function BarrageManager:on_simulation_ended()
	self:cleanup()

	self._running_barrages = {}
	self._listener_holder = EventListenerHolder:new()
	self._spotters = {}
	self._flares = {}
	self._spotter_barrage_type = BarrageManager.default_params
	self._next_spotter_barrage_time = nil

	self._soundsource:stop()
end

function BarrageManager:cleanup()
	if Network:is_server() then
		for _, data in ipairs(self._flares) do
			if alive(data.unit) then
				data.unit:set_slot(0)
			end
		end
	end

	self._flares = {}
end

function BarrageManager:spawn_flare(spotter, target)
	if not alive(target) then
		return
	end

	local pos = spotter:position() + Vector3(0, 0, 150)
	local rot = spotter:rotation()

	self._soundsource:post_event("spotter_flare_thrown")
	managers.dialog:queue_dialog("player_gen_barrage_flare_drop", {
		skip_idle_check = true
	})

	local target_pos = Vector3(target:position().x, target:position().y, pos.z)
	local height = pos.z - target:position().z
	local displacement = mvector3.distance(pos, target:position())
	local distance = mvector3.distance(pos, target_pos)

	Application:debug("[BarrageManager][spawn_flare] height, displacement, distance", height, displacement, distance)

	local cos_fi = math.cos(BarrageManager.FLARE_SHOOT_ELEVATION)
	local tan_fi = math.tan(BarrageManager.FLARE_SHOOT_ELEVATION)
	local elevation = tan_fi * distance

	mvector3.add(target_pos, Vector3(0, 0, elevation))

	local v = math.sqrt(distance * distance * 981 / 2 * cos_fi * cos_fi * (tan_fi * distance + height)) / 1000
	local sin_2fi = math.sin(2 * BarrageManager.FLARE_SHOOT_ELEVATION)
	local d = distance - height / 1.8

	if d < 0 then
		d = distance
	end

	local v0 = math.sqrt(d * 981 / sin_2fi)
	local forward = target_pos - pos

	mvector3.normalize(forward)
	Application:debug("[BarrageManager][spawn_flare]", v, elevation)

	local flare = safe_spawn_unit(BarrageManager.FLARE_UNIT, pos, Rotation())

	self:sync_spotter_spawn_flare(flare, pos, rot, forward, v0, spotter)
	managers.network:session():send_to_peers_synched("sync_spotter_spawn_flare", flare, pos, rot, forward, v0)
end

function BarrageManager:sync_spotter_spawn_flare(flare, pos, rot, forward, v, spotter)
	flare:body("static_body"):set_enabled(true)
	flare:damage():run_sequence_simple("state_interaction_enabled")
	flare:damage():run_sequence_simple("effect_start_red")

	local velocity = forward * v
	local push_str = 10
	local rand1 = push_str - math.random(0, push_str * 2)
	local rand2 = push_str - math.random(0, push_str * 2)
	local rand3 = push_str - math.random(0, push_str * 2)

	flare:push_at(BarrageManager.FLARE_MASS, velocity, flare:position() + Vector3(rand1, rand2, rand3))

	local t = Application:time() + tweak_data.barrage.flare_timer

	table.insert(self._flares, {
		spotter = spotter,
		unit = flare,
		barrage_time = t
	})
end

function BarrageManager:update(t, dt)
	local now = t

	if not Network:is_server() then
		return
	end

	local ct_barrages = #self._running_barrages

	for i_barrage = ct_barrages, 1, -1 do
		local barrage = self._running_barrages[i_barrage]

		if now >= barrage.end_time then
			table.remove(self._running_barrages, i_barrage)
			managers.mission:call_global_event("barrage_ended")
			self:_call_listeners("barrage_ended")

			if alive(barrage._spotter) then
				barrage._spotter:brain():on_barrage_ended()
			end
		elseif now >= barrage.next_projectile_time then
			barrage.next_projectile_time = self:_get_next_projectile_time(barrage)

			self:_queue_projectile(barrage)
		end
	end

	local remaining_projectiles = {}

	for _, projectile in ipairs(self._queued_projectiles) do
		if t > projectile.time then
			self:_spawn_projectile(projectile.barrage_params)
		else
			table.insert(remaining_projectiles, projectile)
		end
	end

	self._queued_projectiles = remaining_projectiles

	self:_remove_dead_spotters()
	self:_check_flare_start_barrage(t)
end

function BarrageManager:_check_flare_start_barrage(t)
	for _, data in ipairs(self._flares) do
		if alive(data.unit) and data.unit:interaction():active() and not data.called and t > data.barrage_time then
			Application:debug("[BarrageManager][_check_flare_start_barrage] START BARRAGE")
			self:start_spotter_barrage(data.spotter, data.unit:position())

			data.called = true

			data.unit:damage():run_sequence_simple("state_interaction_disabled")
			managers.network:session():send_to_peers_synched("sync_spotter_flare_disabled", data.unit)
		end

		if alive(data.unit) and t > data.barrage_time + 20 then
			data.unit:set_slot(0)
		end
	end
end

function BarrageManager:is_barrage_running()
	local barrage_running = #self._running_barrages > 0

	return barrage_running
end

function BarrageManager:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end

function BarrageManager:add_listener(key, events, clbk)
	if not Network:is_server() then
		return
	end

	self._listener_holder:add(key, events, clbk)
end

function BarrageManager:remove_listener(key)
	if not Network:is_server() then
		return
	end

	self._listener_holder:remove(key)
end

function BarrageManager:start_barrage(params)
	local barrage_params = params

	if barrage_params.type == BarrageType.RANDOM then
		barrage_params = self:_choose_random_type(barrage_params)
	end

	barrage_params = self:_prepare_barrage_params(barrage_params)

	local player_pos = self:_get_barrage_position()

	if not player_pos then
		Application:error("[BarrageManager][start_barrage] Unable to get player position, no players or team AI active")

		return
	end

	self:_set_barrage_position(barrage_params, player_pos)
	self:_start_barrage(barrage_params)
end

function BarrageManager:_start_barrage(barrage_params)
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_NO_BARRAGE) then
		return
	end

	if not Network:is_server() then
		return
	end

	local now = TimerManager:game():time()

	if barrage_params.type == BarrageType.ARTILLERY then
		local delay = barrage_params.initial_delay or 0

		barrage_params.next_projectile_time = now + delay

		table.insert(self._running_barrages, barrage_params)
	elseif barrage_params.type == BarrageType.AIRPLANE then
		local airplane_unit = safe_spawn_unit(barrage_params.airplane_unit, barrage_params.center, barrage_params.direction)

		managers.network:session():send_to_peers_synched("sync_airplane_barrage", airplane_unit, barrage_params.sequence_name)
		self:sync_airplane_barrage(airplane_unit, barrage_params.sequence_name)
	else
		Application:error("[BarrageManager] Trying to start invalid barrage type (not artillery nor aircraft)")
	end

	managers.mission:call_global_event("barrage_started")
	self:_call_listeners("barrage_started")
end

function BarrageManager:sync_airplane_barrage(airplane_unit, sequence_name)
	airplane_unit:damage():run_sequence_simple(sequence_name)
end

function BarrageManager:stop_barrages()
	self:on_simulation_ended()
end

function BarrageManager:_get_barrage_position()
	local pos_rot = managers.criminals:get_valid_player_spawn_pos_rot()

	if pos_rot then
		return pos_rot[1]
	end

	return nil
end

function BarrageManager:_set_barrage_position(barrage_params, target_pos)
	if barrage_params.type == BarrageType.ARTILLERY then
		barrage_params.direction = barrage_params.direction:normalized()

		local distance = barrage_params.distance or BarrageManager.DEFAULT_DISTANCE

		barrage_params.center = target_pos + barrage_params.direction * -distance
	elseif barrage_params.type == BarrageType.AIRPLANE then
		barrage_params.direction = Rotation(math.random(360), 0, 0)
		barrage_params.center = target_pos
	else
		Application:error("[BarrageManager] Trying to start nvalid barrage type (not artillery nor aircraft)")
	end
end

function BarrageManager:_get_next_projectile_time(barrage_params)
	local now = TimerManager:game():time()
	local next_projectile_time = 0

	if barrage_params.spotting_rounds and barrage_params.spotting_rounds > 0 then
		next_projectile_time = now + barrage_params.spotting_rounds_delay
	else
		local average_delay = barrage_params.time_between_projectiles
		local min_delay = average_delay * BarrageManager.MIN_DELAY_VARIANCE
		local max_delay = average_delay * BarrageManager.MAX_DELAY_VARIANCE
		local delay = math.lerp(min_delay, max_delay, math.random())

		next_projectile_time = now + delay
	end

	return next_projectile_time
end

function BarrageManager:_queue_projectile(barrage_params)
	local queued_projectile = {
		barrage_params = barrage_params,
		time = TimerManager:game():time() + (barrage_params.barrage_launch_sound_delay or 0)
	}

	if barrage_params.barrage_launch_sound_event then
		self:play_barrage_launch_sound(barrage_params.barrage_launch_sound_event)
		managers.network:session():send_to_peers_synched("sync_barrage_launch_sound", barrage_params.barrage_launch_sound_event)
	end

	table.insert(self._queued_projectiles, queued_projectile)
end

function BarrageManager:play_barrage_launch_sound(event_name)
	self._soundsource:post_event(event_name)
end

function BarrageManager:_spawn_projectile(barrage_params)
	local x, y = math.uniform_sample_circle(barrage_params.radius)
	local delta_x = x * barrage_params.ortho_x
	local delta_y = y * barrage_params.ortho_y
	local pos = barrage_params.center + delta_x + delta_y

	if barrage_params.spotting_rounds and barrage_params.spotting_rounds > 0 then
		if barrage_params.spotting_rounds_min_distance then
			local distance = math.sqrt(x * x + y * y)

			if distance < barrage_params.spotting_rounds_min_distance then
				local adjustment = barrage_params.spotting_rounds_min_distance / distance

				delta_x = delta_x * adjustment
				delta_y = delta_y * adjustment
				pos = barrage_params.center + delta_x + delta_y
			end
		end

		barrage_params.spotting_rounds = barrage_params.spotting_rounds - 1
	end

	ProjectileBase.throw_projectile(barrage_params.projectile_index, pos, barrage_params.direction * barrage_params.lauch_power)
end

function BarrageManager:_prepare_barrage_params(barrage_params)
	local prepared_params = clone(barrage_params or BarrageManager.default_params)

	if prepared_params.type == BarrageType.ARTILLERY then
		local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(barrage_params.projectile_id)

		if not projectile_index then
			Application:error("[BarrageManager] Trying to spawn an unknown projectile type: ", barrage_params.projectile_id)

			return
		end

		prepared_params.projectile_index = projectile_index

		local barrage_duration = managers.groupai:get_difficulty_dependent_value(prepared_params.duration)

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BARRAGE_LENGTH) then
			barrage_duration = barrage_duration * (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_BARRAGE_LENGTH) or 1)
		end

		prepared_params.duration = barrage_duration
		prepared_params.end_time = TimerManager:game():time() + prepared_params.duration
		prepared_params.projectiles_per_minute = managers.groupai:get_difficulty_dependent_value(prepared_params.projectiles_per_minute)
		prepared_params.time_between_projectiles = 60 / prepared_params.projectiles_per_minute
		prepared_params.ortho_x = prepared_params.direction:random_orthogonal():normalized()
		prepared_params.ortho_y = math.cross(prepared_params.direction, prepared_params.ortho_x):normalized()
		prepared_params.radius = managers.groupai:get_difficulty_dependent_value(prepared_params.area_radius)
	elseif prepared_params.type == BarrageType.AIRPLANE then
		-- Nothing
	else
		Application:error("[BarrageManager] Invalid barrage type (not artillery nor aircraft)")
	end

	prepared_params.cooldown = managers.groupai:get_difficulty_dependent_value(prepared_params.cooldown)

	return prepared_params
end

function BarrageManager:_choose_random_type(barrage_params)
	if not barrage_params.type_table then
		Application:error("[BarrageManager] Barrage params for random type don't have a table of options")

		return nil
	end

	local total_weight = 0

	for name, weight in pairs(barrage_params.type_table) do
		local w = managers.groupai:get_difficulty_dependent_value(weight)

		total_weight = total_weight + w
	end

	local random_value = math.random() * total_weight

	for name, weight in pairs(barrage_params.type_table) do
		local w = managers.groupai:get_difficulty_dependent_value(weight)

		if random_value <= w then
			local barrage_type = tweak_data.barrage[name]

			if not barrage_type then
				Application:error("[BarrageManager] Barrage type specified in random table isn't present in BarrageTweakData: ", name)

				return nil
			end

			return barrage_type
		end

		random_value = random_value - w
	end

	return nil
end

function BarrageManager:set_spotter_barrage_type(barrage_params)
	self._spotter_barrage_type = clone(barrage_params)
end

function BarrageManager:get_spotter_barrage_type()
	return self._spotter_barrage_type
end

function BarrageManager:register_spotter(spotter_unit)
	table.insert(self._spotters, spotter_unit)
end

function BarrageManager:start_spotter_barrage(spotter, target_pos)
	local t = TimerManager:game():time()

	if not self._spotter_barrage_type then
		Application:error("[BarrageManager] Spotter barrage type not set via func_barrage. Using default to prevent a crash.")
		self:set_spotter_barrage_type(BarrageManager.default_params)
	end

	if not target_pos then
		Application:error("[BarrageManager][start_spotter_barrage] Spotter barrage target not provided")

		return
	end

	if not self:_is_spotter_barrage_off_cooldown(t) then
		return
	end

	local barrage_params = self._spotter_barrage_type

	if barrage_params.type == BarrageType.RANDOM then
		barrage_params = self:_choose_random_type(barrage_params)
	end

	barrage_params = self:_prepare_barrage_params(barrage_params)
	barrage_params._spotter = spotter

	self:_set_barrage_position(barrage_params, target_pos)
	self:_start_barrage(barrage_params)

	self._next_spotter_barrage_time = t + barrage_params.cooldown

	Application:debug("[BarrageManager][start_spotter_barrage] Barage called on pos:", target_pos, t, inspect(barrage_params))

	return true
end

function BarrageManager:_is_spotter_barrage_off_cooldown(t)
	do return true end

	local off_cooldown = not self._next_spotter_barrage_time or t > self._next_spotter_barrage_time

	if not off_cooldown then
		-- Nothing
	end

	return off_cooldown
end

function BarrageManager:_remove_dead_spotters()
	local ct_spotters = #self._spotters

	for i_spotter = ct_spotters, 1, -1 do
		local spotter = self._spotters[i_spotter]

		if not alive(spotter) or spotter:character_damage() and spotter:character_damage():dead() then
			table.remove(self._spotters, i_spotter)
		end
	end
end
