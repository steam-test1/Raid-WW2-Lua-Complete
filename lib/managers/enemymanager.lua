local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local t_rem = table.remove
local t_ins = table.insert
local tmp_vec1 = Vector3()
EnemyManager = EnemyManager or class()
EnemyManager._nr_i_lod = {
	{
		2,
		2
	},
	{
		5,
		2
	},
	{
		10,
		5
	}
}
EnemyManager.ENEMIES = {
	german_black_waffen_sentry_light = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light",
	german_sommilier_01 = "units/vanilla/characters/enemies/models/german_sommilier/german_sommilier",
	german_black_waffen_sentry_light_kar98 = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_kar98",
	german_sommilier = "units/vanilla/characters/enemies/models/german_sommeleir/german_sommilier",
	german_black_waffen_sentry_light_shotgun = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_shotgun",
	soviet_nightwitch_02 = "units/vanilla/characters/enemies/models/soviet_nightwitch_02/soviet_nightwitch_02",
	german_black_waffen_sentry_heavy = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy",
	soviet_nightwitch_01 = "units/vanilla/characters/enemies/models/soviet_nightwitch_01/soviet_nightwitch_01",
	german_black_waffen_sentry_heavy_kar98 = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98",
	female_spy = "units/vanilla/characters/enemies/models/female_spy/female_spy",
	german_black_waffen_sentry_heavy_shotgun = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_shotgun",
	german_fallschirmjager_light_shotgun = "units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_shotgun",
	german_black_waffen_sentry_gasmask = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/german_black_waffen_sentry_gasmask",
	german_fallschirmjager_light_kar98 = "units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_kar98",
	german_black_waffen_sentry_gasmaskshotgun = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/german_black_waffen_sentry_gasmask_shotgun",
	german_fallschirmjager_light = "units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light",
	german_commander = "units/vanilla/characters/enemies/models/german_commander/german_commander",
	german_fallschirmjager_heavy_shotgun = "units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_shotgun",
	german_og_commander = "units/vanilla/characters/enemies/models/german_og_commander/german_og_commander",
	german_fallschirmjager_heavy_kar98 = "units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_kar98",
	german_officer = "units/vanilla/characters/enemies/models/german_commander/german_officer",
	german_fallschirmjager_heavy = "units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy",
	german_flamer = "units/vanilla/characters/enemies/models/german_flamer/german_flamer",
	german_waffen_ss_shotgun = "units/vanilla/characters/enemies/models/german_waffen_ss/german_waffen_ss_shotgun",
	german_sniper = "units/vanilla/characters/enemies/models/german_sniper/german_sniper",
	german_waffen_ss_kar98 = "units/vanilla/characters/enemies/models/german_waffen_ss/german_waffen_ss_kar98",
	german_spotter = "units/vanilla/characters/enemies/models/german_sniper/german_spotter",
	german_waffen_ss = "units/vanilla/characters/enemies/models/german_waffen_ss/german_waffen_ss",
	soviet_nkvd_int_security_captain = "units/vanilla/characters/enemies/models/soviet_nkvd_int_security_captain/soviet_nkvd_int_security_captain",
	german_gebirgsjager_heavy_shotgun = "units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_shotgun",
	soviet_nkvd_int_security_captain_b = "units/vanilla/characters/enemies/models/soviet_nkvd_int_security_captain_b/soviet_nkvd_int_security_captain_b",
	german_gebirgsjager_heavy_kar98 = "units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_kar98",
	fb_german_officer_boss = "units/upd_fb/characters/enemies/models/fb_german_commander_boss/fb_german_commander_boss",
	german_gebirgsjager_heavy = "units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy",
	fb_german_officer = "units/upd_fb/characters/enemies/models/fb_german_commander_boss/fb_german_commander",
	german_gebirgsjager_light_shotgun = "units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_shotgun",
	german_gebirgsjager_light_kar98 = "units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_kar98",
	german_gebirgsjager_light = "units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light",
	german_grunt_heavy_shotgun = "units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_shotgun",
	german_grunt_heavy_kar98 = "units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_kar98",
	german_grunt_heavy_mp38 = "units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_mp38",
	german_grunt_heavy = "units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy",
	german_grunt_mid_shotgun = "units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_shotgun",
	german_grunt_mid_kar98 = "units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_kar98",
	german_grunt_mid_mp38 = "units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_mp38",
	german_grunt_mid = "units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid",
	german_grunt_light_shotgun = "units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_shotgun",
	german_grunt_light_kar98 = "units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_kar98",
	german_grunt_light_mp38 = "units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_mp38",
	german_grunt_light = "units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light"
}

function EnemyManager:init()
	self._tickrate = tweak_data.group_ai.ai_tick_rate_stealth

	self:_init_enemy_data()

	self._unit_clbk_key = "EnemyManager"
	self._corpse_disposal_upd_interval = 5
	self._commander_active = 0
	self._difficulty_difference = 0
	self._corpse_limit = math.floor(managers.user:get_setting("corpse_limit"))

	managers.user:add_setting_changed_callback("corpse_limit", callback(self, self, "corpse_limit_changed"))
end

function EnemyManager:enemy_names()
	local result = {}
	local n = 0

	for k, v in pairs(EnemyManager.ENEMIES) do
		n = n + 1
		result[n] = k
	end

	table.sort(result)

	return result
end

function EnemyManager:enemy_units()
	local result = {}
	local n = 0

	for k, v in pairs(EnemyManager.ENEMIES) do
		n = n + 1
		result[n] = v
	end

	table.sort(result)

	return result
end

function EnemyManager:update(t, dt)
	if not managers.navigation:is_streamed_data_ready() then
		return
	end

	self._t = t
	self._queued_task_executed = nil

	self:_update_gfx_lod()
	self:_update_queued_tasks(t, dt)
	self:_cleanup_queued_tasks()
end

function EnemyManager:_update_gfx_lod()
	if self._gfx_lod_data.enabled and managers.navigation:is_data_ready() then
		local camera_rot = managers.viewport:get_current_camera_rotation()

		if camera_rot then
			local pl_tracker, cam_pos = nil
			local pl_fwd = camera_rot:y()
			local player = managers.player:player_unit()

			if player then
				pl_tracker = player:movement():nav_tracker()
				cam_pos = player:movement():m_head_pos()
			else
				pl_tracker = false
				cam_pos = managers.viewport:get_current_camera_position()
			end

			local entries = self._gfx_lod_data.entries
			local units = entries.units
			local states = entries.states
			local move_ext = entries.move_ext
			local trackers = entries.trackers
			local com = entries.com
			local chk_vis_func = pl_tracker and pl_tracker.check_visibility
			local unit_occluded = Unit.occluded
			local occ_skip_units = managers.occlusion._skip_occlusion
			local world_in_view_with_options = World.in_view_with_options

			for i, state in ipairs(states) do
				if not state and (occ_skip_units[units[i]:key()] or (not pl_tracker or chk_vis_func(pl_tracker, trackers[i])) and not unit_occluded(units[i])) and world_in_view_with_options(World, com[i], 0, 110, 18000) then
					states[i] = 1

					units[i]:base():set_visibility_state(1)
				end
			end

			if #states > 0 then
				local anim_lod = managers.user:get_setting("video_animation_lod")
				local nr_lod_1 = self._nr_i_lod[anim_lod][1]
				local nr_lod_2 = self._nr_i_lod[anim_lod][2]
				local nr_lod_total = nr_lod_1 + nr_lod_2
				local imp_i_list = self._gfx_lod_data.prio_i
				local imp_wgt_list = self._gfx_lod_data.prio_weights
				local nr_entries = #states
				local i = self._gfx_lod_data.next_chk_prio_i

				if nr_entries < i then
					i = 1
				end

				local start_i = i

				repeat
					if states[i] and alive(units[i]) then
						if not occ_skip_units[units[i]:key()] and (pl_tracker and not chk_vis_func(pl_tracker, trackers[i]) or unit_occluded(units[i])) then
							states[i] = false

							units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						elseif not world_in_view_with_options(World, com[i], 0, 120, 18000) then
							states[i] = false

							units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						else
							local my_wgt = mvec3_dir(tmp_vec1, cam_pos, com[i])
							local dot = mvec3_dot(tmp_vec1, pl_fwd)
							local previous_prio = nil

							for prio, i_entry in ipairs(imp_i_list) do
								if i == i_entry then
									previous_prio = prio

									break
								end
							end

							my_wgt = my_wgt * my_wgt * (1 - dot)
							local i_wgt = #imp_wgt_list

							while i_wgt > 0 do
								if previous_prio ~= i_wgt and imp_wgt_list[i_wgt] <= my_wgt then
									break
								end

								i_wgt = i_wgt - 1
							end

							if not previous_prio or i_wgt <= previous_prio then
								i_wgt = i_wgt + 1
							end

							if i_wgt ~= previous_prio then
								if previous_prio then
									t_rem(imp_i_list, previous_prio)
									t_rem(imp_wgt_list, previous_prio)

									if previous_prio <= nr_lod_1 and nr_lod_1 < i_wgt and nr_lod_1 <= #imp_i_list then
										local promote_i = imp_i_list[nr_lod_1]
										states[promote_i] = 1

										units[promote_i]:base():set_visibility_state(1)
									elseif nr_lod_1 < previous_prio and i_wgt <= nr_lod_1 then
										local denote_i = imp_i_list[nr_lod_1]
										states[denote_i] = 2

										units[denote_i]:base():set_visibility_state(2)
									end
								elseif i_wgt <= nr_lod_total and #imp_i_list == nr_lod_total then
									local kick_i = imp_i_list[nr_lod_total]
									states[kick_i] = 3

									units[kick_i]:base():set_visibility_state(3)
									t_rem(imp_wgt_list)
									t_rem(imp_i_list)
								end

								local lod_stage = nil

								if i_wgt <= nr_lod_total then
									t_ins(imp_wgt_list, i_wgt, my_wgt)
									t_ins(imp_i_list, i_wgt, i)

									lod_stage = i_wgt <= nr_lod_1 and 1 or 2
								else
									lod_stage = 3

									self:_remove_i_from_lod_prio(i, anim_lod)
								end

								if states[i] ~= lod_stage then
									states[i] = lod_stage

									units[i]:base():set_visibility_state(lod_stage)
								end
							end

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						end
					end

					if i == nr_entries then
						i = 1
					else
						i = i + 1
					end
				until i == start_i
			end
		end
	end
end

function EnemyManager:_remove_i_from_lod_prio(i, anim_lod)
	anim_lod = anim_lod or managers.user:get_setting("video_animation_lod")
	local nr_i_lod1 = self._nr_i_lod[anim_lod][1]

	for prio, i_entry in ipairs(self._gfx_lod_data.prio_i) do
		if i == i_entry then
			table.remove(self._gfx_lod_data.prio_i, prio)
			table.remove(self._gfx_lod_data.prio_weights, prio)

			if prio <= nr_i_lod1 and nr_i_lod1 < #self._gfx_lod_data.prio_i then
				local promoted_i_entry = self._gfx_lod_data.prio_i[prio]
				self._gfx_lod_data.entries.states[promoted_i_entry] = 1

				self._gfx_lod_data.entries.units[promoted_i_entry]:base():set_visibility_state(1)
			end

			return
		end
	end
end

function EnemyManager:_create_unit_gfx_lod_data(unit)
	local lod_entries = self._gfx_lod_data.entries

	table.insert(lod_entries.units, unit)
	table.insert(lod_entries.states, 1)
	table.insert(lod_entries.move_ext, unit:movement())
	table.insert(lod_entries.trackers, unit:movement():nav_tracker())
	table.insert(lod_entries.com, unit:movement():m_com())
end

function EnemyManager:_destroy_unit_gfx_lod_data(u_key)
	local lod_entries = self._gfx_lod_data.entries

	for i, unit in ipairs(lod_entries.units) do
		if u_key == unit:key() then
			if not lod_entries.states[i] then
				unit:base():set_visibility_state(1)
			end

			local nr_entries = #lod_entries.units

			self:_remove_i_from_lod_prio(i)

			for prio, i_entry in ipairs(self._gfx_lod_data.prio_i) do
				if i_entry == nr_entries then
					self._gfx_lod_data.prio_i[prio] = i

					break
				end
			end

			lod_entries.units[i] = lod_entries.units[nr_entries]

			table.remove(lod_entries.units)

			lod_entries.states[i] = lod_entries.states[nr_entries]

			table.remove(lod_entries.states)

			lod_entries.move_ext[i] = lod_entries.move_ext[nr_entries]

			table.remove(lod_entries.move_ext)

			lod_entries.trackers[i] = lod_entries.trackers[nr_entries]

			table.remove(lod_entries.trackers)

			lod_entries.com[i] = lod_entries.com[nr_entries]

			table.remove(lod_entries.com)

			break
		end
	end
end

function EnemyManager:set_gfx_lod_enabled(state)
	if state then
		self._gfx_lod_data.enabled = state
	elseif self._gfx_lod_data.enabled then
		self._gfx_lod_data.enabled = state
		local entries = self._gfx_lod_data.entries
		local units = entries.units
		local states = entries.states

		for i, state in ipairs(states) do
			states[i] = 1

			if alive(units[i]) then
				units[i]:base():set_visibility_state(1)
			end
		end
	end
end

function EnemyManager:chk_any_unit_in_slotmask_visible(slotmask, cam_pos, cam_nav_tracker)
	if self._gfx_lod_data.enabled and managers.navigation:is_data_ready() then
		local camera_rot = managers.viewport:get_current_camera_rotation()
		local entries = self._gfx_lod_data.entries
		local units = entries.units
		local states = entries.states
		local trackers = entries.trackers
		local move_exts = entries.move_ext
		local com = entries.com
		local chk_vis_func = cam_nav_tracker and cam_nav_tracker.check_visibility
		local unit_occluded = Unit.occluded
		local occ_skip_units = managers.occlusion._skip_occlusion
		local vis_slotmask = managers.slot:get_mask("AI_visibility")

		for i, state in ipairs(states) do
			local unit = units[i]

			if unit:in_slot(slotmask) and (occ_skip_units[unit:key()] or (not cam_nav_tracker or chk_vis_func(cam_nav_tracker, trackers[i])) and not unit_occluded(unit)) then
				local distance = mvec3_dir(tmp_vec1, cam_pos, com[i])

				if distance < 300 then
					return true
				elseif distance < 2000 then
					local u_m_head_pos = move_exts[i]:m_head_pos()
					local ray = World:raycast("ray", cam_pos, u_m_head_pos, "slot_mask", vis_slotmask, "report")

					if not ray then
						return true
					else
						ray = World:raycast("ray", cam_pos, com[i], "slot_mask", vis_slotmask, "report")

						if not ray then
							return true
						end
					end
				end
			end
		end
	end
end

function EnemyManager:_init_enemy_data()
	local enemy_data = {}
	local unit_data = {}
	self._enemy_data = enemy_data
	enemy_data.unit_data = unit_data
	enemy_data.nr_units = 0
	enemy_data.nr_active_units = 0
	enemy_data.nr_inactive_units = 0
	enemy_data.inactive_units = {}
	enemy_data.max_nr_active_units = 20
	enemy_data.corpses = {}
	enemy_data.nr_corpses = 0
	self._civilian_data = {
		unit_data = {}
	}
	self._queued_tasks = {}
	self._queued_task_executed = nil
	self._delayed_clbks = {}
	self._t = 0
	self._gfx_lod_data = {
		enabled = true,
		prio_i = {},
		prio_weights = {},
		next_chk_prio_i = 1,
		entries = {}
	}
	local lod_entries = self._gfx_lod_data.entries
	lod_entries.units = {}
	lod_entries.states = {}
	lod_entries.move_ext = {}
	lod_entries.trackers = {}
	lod_entries.com = {}
	self._corpse_disposal_enabled = false
end

function EnemyManager:all_enemies()
	return self._enemy_data.unit_data
end

function EnemyManager:is_enemy(unit)
	return self._enemy_data.unit_data[unit:key()] and true or false
end

function EnemyManager:all_civilians()
	return self._civilian_data.unit_data
end

function EnemyManager:is_civilian(unit)
	return self._civilian_data.unit_data[unit:key()] and true or false
end

function EnemyManager:queue_task(id, task_clbk, data, execute_t, verification_clbk, asap)
	local task_data = {
		clbk = task_clbk,
		id = id,
		data = data,
		t = execute_t,
		v_cb = verification_clbk,
		asap = asap,
		queue_time = TimerManager:game():time()
	}

	table.insert(self._queued_tasks, task_data)
end

function EnemyManager:unqueue_all_tasks()
	self._queued_tasks = {}
end

function EnemyManager:remove_delayed_clbks()
	self._delayed_clbks = {}
end

function EnemyManager:unqueue_task(id)
	local tasks = self._queued_tasks
	local i = #tasks

	while i > 0 do
		if tasks[i].id == id then
			table.remove(tasks, i)

			return
		end

		i = i - 1
	end
end

function EnemyManager:_cleanup_queued_tasks()
	local tasks = self._queued_tasks
	local i = #tasks

	while i > 0 do
		if tasks[i].is_executed then
			table.remove(tasks, i)
		end

		i = i - 1
	end
end

function EnemyManager:unqueue_task_debug(id)
	if not id then
		Application:stack_dump()
	end

	local tasks = self._queued_tasks
	local i = #tasks
	local removed = nil

	while i > 0 do
		if tasks[i].id == id then
			if removed then
				debug_pause("DOUBLE TASK AT ", i, id)
			else
				table.remove(tasks, i)

				removed = true
			end
		end

		i = i - 1
	end

	if not removed then
		debug_pause("[EnemyManager:unqueue_task] task", id, "was not queued!!!")
	end
end

function EnemyManager:has_task(id)
	local tasks = self._queued_tasks
	local i = #tasks
	local count = 0

	while i > 0 do
		if tasks[i].id == id then
			count = count + 1
		end

		i = i - 1
	end

	return count > 0 and count
end

function EnemyManager:_execute_queued_task(i)
	local task = self._queued_tasks[i]
	local time = TimerManager:game():time()

	if math.abs(time - task.queue_time) < 0.1 then
		return
	end

	self._queued_task_executed = true
	task.is_executed = true

	if task.data and task.data.unit and not alive(task.data.unit) then
		Application:error("[EnemyManager:_execute_queued_task] dead unit", inspect(task))

		return
	end

	if task.v_cb then
		task.v_cb(task.id)
	end

	task.clbk(task.data)
end

local m_ceil = math.ceil
local t_remove = table.remove

function EnemyManager:_update_queued_tasks(t, dt)
	local i_asap_task, asp_task_t = nil
	local queue_remaining = m_ceil(dt * self._tickrate)

	for i_task, task_data in ipairs(self._queued_tasks) do
		if not task_data.t or task_data.t < t then
			self:_execute_queued_task(i_task)

			queue_remaining = queue_remaining - 1

			if queue_remaining <= 0 then
				break
			end
		elseif task_data.asap and (not asp_task_t or task_data.t < asp_task_t) then
			i_asap_task = i_task
			asp_task_t = task_data.t
		end
	end

	if i_asap_task and not self._queued_task_executed then
		self:_execute_queued_task(i_asap_task)
	end

	local all_clbks = self._delayed_clbks

	if all_clbks[1] and all_clbks[1][2] < t then
		local clbk = t_remove(all_clbks, 1)[3]

		clbk()
	end
end

function EnemyManager:add_delayed_clbk(id, clbk, execute_t)
	if not clbk then
		debug_pause("[EnemyManager:add_delayed_clbk] Empty callback object!!!")
	end

	local clbk_data = {
		id,
		execute_t,
		clbk
	}
	local all_clbks = self._delayed_clbks
	local i = #all_clbks

	while i > 0 and execute_t < all_clbks[i][2] do
		i = i - 1
	end

	table.insert(all_clbks, i + 1, clbk_data)
end

function EnemyManager:remove_delayed_clbk(id)
	local all_clbks = self._delayed_clbks

	for i, clbk_data in ipairs(all_clbks) do
		if clbk_data[1] == id then
			table.remove(all_clbks, i)

			return
		end
	end

	Application:error("[EnemyManager:remove_delayed_clbk] id", id, "was not scheduled!!!")
end

function EnemyManager:remove_all_delayed_clbks(id)
	local all_clbks = self._delayed_clbks
	local callback_data = nil
	local i = #all_clbks

	while i > 0 do
		callback_data = all_clbks[i]

		if callback_data[1] == id then
			table.remove(all_clbks, i)
		end

		i = i - 1
	end
end

function EnemyManager:reschedule_delayed_clbk(id, execute_t)
	local all_clbks = self._delayed_clbks
	local clbk_data = nil

	for i, clbk_d in ipairs(all_clbks) do
		if clbk_d[1] == id then
			clbk_data = table.remove(all_clbks, i)

			break
		end
	end

	if clbk_data then
		clbk_data[2] = execute_t
		local i = #all_clbks

		while i > 0 and execute_t < all_clbks[i][2] do
			i = i - 1
		end

		table.insert(all_clbks, i + 1, clbk_data)

		return
	end

	print("[EnemyManager:reschedule_delayed_clbk] id", id, "was not scheduled!!!")
end

function EnemyManager:force_delayed_clbk(id)
	local all_clbks = self._delayed_clbks

	for i, clbk_data in ipairs(all_clbks) do
		if clbk_data[1] == id then
			local clbk = table.remove(all_clbks, 1)[3]

			clbk()

			return
		end
	end

	debug_pause("[EnemyManager:force_delayed_clbk] id", id, "was not scheduled!!!")
end

function EnemyManager:queued_tasks_by_callback()
	local t = TimerManager:game():time()
	local categorised_queued_tasks = {}
	local congestion = 0

	for i_task, task_data in ipairs(self._queued_tasks) do
		if categorised_queued_tasks[task_data.clbk] then
			categorised_queued_tasks[task_data.clbk].amount = categorised_queued_tasks[task_data.clbk].amount + 1
		else
			categorised_queued_tasks[task_data.clbk] = {
				amount = 1,
				key = task_data.id
			}
		end

		if not task_data.t or task_data.t < t then
			congestion = congestion + 1
		end
	end

	print("congestion", congestion)

	for clbk, data in pairs(categorised_queued_tasks) do
		print(data.key, data.amount)
	end
end

function EnemyManager:register_enemy(enemy)
	if self._destroyed then
		debug_pause("[EnemyManager:register_enemy] enemy manager is destroyed")
	end

	local char_tweak = tweak_data.character[enemy:base()._tweak_table]
	local u_data = {
		importance = 0,
		unit = enemy,
		m_pos = enemy:movement():m_pos(),
		tracker = enemy:movement():nav_tracker(),
		char_tweak = char_tweak,
		so_access = managers.navigation:convert_access_flag(char_tweak.access)
	}
	self._enemy_data.unit_data[enemy:key()] = u_data

	enemy:base():add_destroy_listener(self._unit_clbk_key, callback(self, self, "on_enemy_destroyed"))
	self:on_enemy_registered(enemy)
end

function EnemyManager:on_enemy_died(dead_unit, damage_info)
	if self._destroyed then
		debug_pause("[EnemyManager:on_enemy_died] enemy manager is destroyed", dead_unit)
	end

	local u_key = dead_unit:key()
	local enemy_data = self._enemy_data
	local u_data = enemy_data.unit_data[u_key]

	self:on_enemy_unregistered(dead_unit)

	enemy_data.unit_data[u_key] = nil

	managers.mission:call_global_event("enemy_killed")

	local atk_from_pos = damage_info.attacker_unit and damage_info.attacker_unit:position()

	if atk_from_pos then
		local world = managers.worldcollection:get_world_id_from_pos(atk_from_pos)
		local alarm = managers.worldcollection:get_alarm_for_world(world)
		local is_cool = dead_unit:movement() and dead_unit:movement():cool()

		if not alarm and is_cool then
			managers.dialog:queue_dialog("player_gen_stealth_kill", {
				skip_idle_check = true,
				instigator = damage_info.attacker_unit
			})
		end
	end

	if dead_unit:movement() then
		dead_unit:movement():anim_clbk_close_parachute()
	end

	enemy_data.nr_corpses = enemy_data.nr_corpses + 1
	enemy_data.corpses[u_key] = u_data
	u_data.death_t = self._t

	self:_destroy_unit_gfx_lod_data(u_key)

	u_data.u_id = dead_unit:id()

	if self:is_corpse_disposal_enabled() then
		self:_detach_network_enemy(dead_unit)
		self:_chk_corpse_disposal()
	end

	local contour_ext = dead_unit:contour()

	if contour_ext then
		contour_ext:disable()
	end
end

function EnemyManager:_detach_network_enemy(unit)
	if Network:is_server() then
		return
	end

	Network:detach_unit(unit)

	for _, ext_name in ipairs(unit:extensions()) do
		local extension = unit[ext_name](unit)

		if extension.detach_from_network then
			extension:detach_from_network()
		end
	end
end

function EnemyManager:add_corpse_lootbag(corpse)
	if self._destroyed then
		debug_pause("[EnemyManager:add_corpse_lootbag] enemy manager is destroyed", corpse)
	end

	local ignore_corpse_cleanup = corpse:carry_data() and corpse:carry_data():carry_tweak_data() and corpse:carry_data():carry_tweak_data().ignore_corpse_cleanup

	if ignore_corpse_cleanup then
		Application:debug("[EnemyManager:add_corpse_lootbag] Not adding ignored corpse", inspect(corpse))
	else
		Application:debug("[EnemyManager:add_corpse_lootbag] Adding", inspect(corpse))

		local enemy_data = self._enemy_data
		enemy_data.nr_corpses = enemy_data.nr_corpses + 1
		enemy_data.corpses[corpse:key()] = {
			unit = corpse,
			u_id = corpse:id(),
			m_pos = corpse:position(),
			death_t = self._t
		}

		if self:is_corpse_disposal_enabled() then
			self:_detach_network_enemy(corpse)
			self:_chk_corpse_disposal()
		end
	end
end

function EnemyManager:unmark_dead_enemies()
	for _, corpse in pairs(managers.enemy._enemy_data.corpses) do
		local unit = corpse.unit

		if alive(unit) and unit.contour then
			local contour = unit:contour()

			if contour then
				contour:disable()
			end
		end
	end
end

function EnemyManager:on_enemy_destroyed(enemy)
	local u_key = enemy:key()
	local enemy_data = self._enemy_data

	if enemy_data.unit_data[u_key] then
		self:on_enemy_unregistered(enemy)

		enemy_data.unit_data[u_key] = nil

		self:_destroy_unit_gfx_lod_data(u_key)
	elseif enemy_data.corpses[u_key] then
		enemy_data.nr_corpses = enemy_data.nr_corpses - 1
		enemy_data.corpses[u_key] = nil
	end
end

function EnemyManager:on_enemy_registered(unit)
	self._enemy_data.nr_units = self._enemy_data.nr_units + 1

	self:_create_unit_gfx_lod_data(unit, true)
	managers.groupai:state():on_enemy_registered(unit)
end

function EnemyManager:on_enemy_unregistered(unit)
	self._enemy_data.nr_units = self._enemy_data.nr_units - 1

	managers.groupai:state():on_enemy_unregistered(unit)
end

function EnemyManager:register_civilian(unit)
	unit:base():add_destroy_listener(self._unit_clbk_key, callback(self, self, "on_civilian_destroyed"))
	self:_create_unit_gfx_lod_data(unit, true)

	local char_tweak = tweak_data.character[unit:base()._tweak_table]
	self._civilian_data.unit_data[unit:key()] = {
		is_civilian = true,
		unit = unit,
		m_pos = unit:movement():m_pos(),
		tracker = unit:movement():nav_tracker(),
		char_tweak = char_tweak,
		so_access = managers.navigation:convert_access_flag(char_tweak.access)
	}
end

function EnemyManager:on_civilian_died(dead_unit, damage_info)
	local u_key = dead_unit:key()

	managers.groupai:state():on_civilian_unregistered(dead_unit)

	if Network:is_server() and damage_info.attacker_unit and not dead_unit:base().enemy then
		managers.groupai:state():hostage_killed(damage_info.attacker_unit)
	end

	managers.mission:call_global_event("civilian_killed")

	local u_data = self._civilian_data.unit_data[u_key]
	local enemy_data = self._enemy_data
	enemy_data.nr_corpses = enemy_data.nr_corpses + 1
	enemy_data.corpses[u_key] = u_data
	u_data.death_t = TimerManager:game():time()
	self._civilian_data.unit_data[u_key] = nil

	self:_destroy_unit_gfx_lod_data(u_key)

	u_data.u_id = dead_unit:id()

	if self:is_corpse_disposal_enabled() then
		self:_detach_network_enemy(dead_unit)
		self:_chk_corpse_disposal()
	end
end

function EnemyManager:on_civilian_destroyed(enemy)
	local u_key = enemy:key()
	local enemy_data = self._enemy_data

	if enemy_data.corpses[u_key] then
		enemy_data.nr_corpses = enemy_data.nr_corpses - 1
		enemy_data.corpses[u_key] = nil
	else
		managers.groupai:state():on_civilian_unregistered(enemy)

		self._civilian_data.unit_data[u_key] = nil

		self:_destroy_unit_gfx_lod_data(u_key)
	end
end

function EnemyManager:on_criminal_registered(unit)
	self:_create_unit_gfx_lod_data(unit, false)
end

function EnemyManager:on_criminal_unregistered(u_key)
	self:_destroy_unit_gfx_lod_data(u_key)
end

function EnemyManager:corpse_limit_changed(name, old_value, new_value)
	self._corpse_limit = math.floor(new_value)

	self:_chk_corpse_disposal()
end

function EnemyManager:_chk_corpse_disposal()
	if not self:is_corpse_disposal_enabled() then
		self:unqueue_task("EnemyManager._upd_corpse_disposal")

		return
	end

	if self._enemy_data.nr_corpses <= self._corpse_limit then
		return
	end

	if self:has_task("EnemyManager._upd_corpse_disposal") then
		return
	end

	local t = TimerManager:game():time()
	local queue_t = t + self._corpse_disposal_upd_interval

	self:queue_task("EnemyManager._upd_corpse_disposal", self._upd_corpse_disposal, self, queue_t)
end

function EnemyManager:_upd_corpse_disposal()
	local enemy_data = self._enemy_data
	local nr_corpses = enemy_data.nr_corpses
	local disposals_needed = nr_corpses - self._corpse_limit
	local corpses = enemy_data.corpses

	if not self:is_corpse_disposal_enabled() or disposals_needed <= 0 then
		return
	end

	local camera_pos = managers.viewport:get_current_camera_position()
	local camera_rot = managers.viewport:get_current_camera_rotation()
	local camera_fwd = camera_rot and camera_rot:y()
	local to_dispose = {}
	local nr_found = 0

	if camera_pos and camera_fwd then
		local close_distance = 200
		local enemy_dir = tmp_vec1

		for u_key, u_data in pairs(corpses) do
			local u_pos = u_data.m_pos

			if close_distance < mvec3_dis(camera_pos, u_pos) then
				mvec3_dir(enemy_dir, camera_pos, u_pos)

				if mvec3_dot(camera_fwd, enemy_dir) < 0 then
					to_dispose[u_key] = true
					nr_found = nr_found + 1

					if nr_found == disposals_needed then
						break
					end
				end
			end
		end
	end

	disposals_needed = disposals_needed - nr_found

	if disposals_needed > 0 then
		for u_key, u_data in pairs(corpses) do
			if not to_dispose[u_key] and alive(u_data.unit) then
				to_dispose[u_key] = true
				nr_found = nr_found + 1

				if nr_found == disposals_needed then
					break
				end
			end
		end
	end

	local is_server = Network:is_server()

	for u_key, _ in pairs(to_dispose) do
		local u_data = corpses[u_key]
		corpses[u_key] = nil

		if alive(u_data.unit) then
			local unit = u_data.unit

			if is_server or unit:id() == -1 then
				unit:set_slot(0)
			else
				unit:set_enabled(false)
			end
		end
	end

	enemy_data.nr_corpses = nr_corpses - nr_found
end

function EnemyManager:set_hot_state(state)
	self._tickrate = tweak_data.group_ai[state and "ai_tick_rate_loud" or "ai_tick_rate_stealth"]

	self:set_corpse_disposal_enabled(state)
end

function EnemyManager:set_corpse_disposal_enabled(enabled)
	self._corpse_disposal_enabled = enabled

	if enabled then
		for _, corpse_data in pairs(self._enemy_data.corpses) do
			local unit = corpse_data.unit

			if alive(unit) and unit:id() ~= -1 then
				self:_detach_network_enemy(unit)
			end
		end
	end

	self:_chk_corpse_disposal()
end

function EnemyManager:is_corpse_disposal_enabled()
	return self._corpse_disposal_enabled
end

function EnemyManager:on_simulation_ended()
	self._commander_active = 0
end

function EnemyManager:on_simulation_started()
	self._destroyed = nil
end

function EnemyManager:on_level_transition()
	self._destroyed = nil

	self:unqueue_all_tasks()
	self:remove_delayed_clbks()
	self:dispose_all_corpses()
end

function EnemyManager:dispose_all_corpses()
	for _, corpse_data in pairs(self._enemy_data.corpses) do
		if alive(corpse_data.unit) then
			if corpse_data.unit:id() ~= -1 then
				self:_detach_network_enemy(corpse_data.unit)
			end

			World:delete_unit(corpse_data.unit)
		end
	end

	self._enemy_data.corpses = {}
end

function EnemyManager:save(data)
	local my_data = nil
	my_data = my_data or {}

	for u_key, u_data in pairs(self._enemy_data.corpses) do
		local unit = u_data.unit

		if alive(unit) then
			local movement = unit:movement()
			local corpse_data = {
				u_data.u_id,
				movement and movement:m_pos() or unit:position(),
				u_data.is_civilian and true or false,
				unit:interaction():active() and true or false,
				unit:interaction().tweak_data,
				unit:contour() and unit:contour():is_flashing() or false
			}
			my_data.corpses = my_data.corpses or {}

			table.insert(my_data.corpses, corpse_data)
		else
			Application:warn("[EnemyManager:save] Tried to use a unit that was not alive(), skipping this u_data", inspect(u_data))
		end
	end

	data.enemy_manager = my_data
end

function EnemyManager:load(data)
	local my_data = data.enemy_manager

	if not my_data then
		return
	end

	if my_data.corpses then
		for _, corpse_data in pairs(my_data.corpses) do
			local u_id = corpse_data[1]
			local spawn_pos = corpse_data[2]
			local is_civilian = corpse_data[3]
			local interaction_active = corpse_data[4]
			local interaction_tweak_data = corpse_data[5]
			local contour_flashing = corpse_data[6]
			local grnd_ray = World:raycast("ray", spawn_pos + Vector3(0, 0, 50), spawn_pos - Vector3(0, 0, 100), "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")
			local corpse = World:unit_manager():get_unit_by_id(u_id)

			if alive(corpse) then
				if corpse:base() then
					corpse:base():add_destroy_listener("EnemyManager_corpse_dummy" .. tostring(corpse:key()), callback(self, self, is_civilian and "on_civilian_destroyed" or "on_enemy_destroyed"))
				end

				self._enemy_data.corpses[corpse:key()] = {
					death_t = 0,
					unit = corpse,
					u_id = u_id,
					m_pos = corpse:position()
				}
				self._enemy_data.nr_corpses = self._enemy_data.nr_corpses + 1

				if corpse:damage() and corpse:damage():has_sequence("unfreeze_ragdoll") then
					Application:debug("[EnemyManager:load] call unfreeze_ragdoll", corpse)
					corpse:damage():run_sequence_simple("unfreeze_ragdoll")
					corpse:set_extension_update_enabled(Idstring("movement"), false)
					managers.queued_tasks:queue(nil, self._queue_freeze_ragdoll, self, {
						corpse = corpse
					}, 6, nil)
				end

				if self:is_corpse_disposal_enabled() then
					self:_detach_network_enemy(corpse)
				end
			else
				Application:warn("[EnemyManager:load] Tried to use a unit that was not alive(), skipping this corpse", corpse)
			end
		end
	end

	self:_chk_corpse_disposal()
end

function EnemyManager:_queue_freeze_ragdoll(data)
	if alive(data.corpse) then
		data.corpse:damage():has_then_run_sequence_simple("freeze_ragdoll")
	end
end

function EnemyManager:get_corpse_unit_data_from_key(u_key)
	return self._enemy_data.corpses[u_key]
end

function EnemyManager:get_corpse_unit_data_from_id(u_id)
	for u_key, u_data in pairs(self._enemy_data.corpses) do
		if u_id == u_data.u_id then
			return u_data
		end
	end
end

function EnemyManager:remove_corpse_by_id(u_id)
	for u_key, u_data in pairs(self._enemy_data.corpses) do
		if u_id == u_data.u_id then
			u_data.unit:set_slot(0)

			self._enemy_data.corpses[u_key] = nil

			break
		end
	end
end

function EnemyManager:commander_difficulty()
	return self._difficulty_difference or 0
end

function EnemyManager:is_commander_active()
	return self._commander_active > 0
end

function EnemyManager:is_spawn_group_allowed(group_type)
	local allowed = true

	if not managers.enemy:is_commander_active() then
		for i, v in ipairs(tweak_data.group_ai.commander_backup_groups) do
			if group_type == v then
				allowed = false

				break
			end
		end
	end

	return allowed
end

function EnemyManager:register_commander()
	self._commander_active = self._commander_active + 1

	if self._commander_active == 1 then
		local old_diff = managers.groupai:state():get_difficulty()
		local new_diff = old_diff + CommanderBrain.INTENSITY_INCREASE
		new_diff = math.clamp(new_diff, new_diff, 1)
		self._difficulty_difference = new_diff - old_diff

		if self._difficulty_difference > 0 then
			Application:debug("[EnemyManager:register_commander()] setting new intensity value (old,new)", old_diff, new_diff)
			managers.groupai:state():set_difficulty(new_diff)
		end

		local count = managers.statistics._global.killed.german_commander.count + managers.statistics._global.killed.german_og_commander.count

		if count < 5 then
			managers.hud:set_big_prompt({
				duration = 5,
				id = "commander_arrived",
				title = utf8.to_upper(managers.localization:text("hint_commander_arrived")),
				description = managers.localization:text("hint_commander_arrived_desc")
			})
		end
	elseif self:is_commander_active() then
		Application:warn("[EnemyManager:register_commander()] More than one commander is active!!", self._commander_active)
	end
end

function EnemyManager:unregister_commander()
	self._commander_active = math.max(self._commander_active - 1, 0)

	if not self:is_commander_active() and self._difficulty_difference > 0 then
		local old_diff = managers.groupai:state():get_difficulty()
		local new_diff = old_diff - self._difficulty_difference
		new_diff = math.max(new_diff, 0)
		self._difficulty_difference = 0

		Application:debug("[EnemyManager:unregister_commander()] setting new intensity value (old,new)", old_diff, new_diff)
		managers.groupai:state():set_difficulty(new_diff)
	end
end
