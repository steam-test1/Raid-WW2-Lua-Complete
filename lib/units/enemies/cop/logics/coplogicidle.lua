local tmp_vec1 = Vector3()
CopLogicIdle = class(CopLogicBase)
CopLogicIdle.allowed_transitional_actions = {
	{
		"idle",
		"hurt",
		"dodge"
	},
	{
		"idle",
		"turn"
	},
	{
		"idle",
		"reload"
	},
	{
		"hurt",
		"stand",
		"crouch"
	}
}

-- Lines 16-134
function CopLogicIdle.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)

	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
		my_data.vision = data.char_tweak.vision.idle
	else
		my_data.vision = data.char_tweak.vision.combat
		my_data.detection = data.char_tweak.detection.idle
	end

	my_data.vision_cool = data.char_tweak.vision.idle
	my_data.vision_not_cool = data.char_tweak.vision.combat
	local old_internal_data = data.internal_data

	if old_internal_data then
		my_data.turning = old_internal_data.turning

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
		end

		if old_internal_data.shooting then
			data.unit:brain():action_request({
				body_part = 3,
				type = "idle"
			})
		end

		local lower_body_action = data.unit:movement()._active_actions[2]

		if lower_body_action and lower_body_action:type() == "walk" then
			my_data.advancing = lower_body_action
		else
			my_data.advancing = nil
		end
	end

	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	my_data.detection_task_key = "CopLogicIdle.update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	local objective = data.objective

	if objective then
		if (objective.nav_seg or objective.type == "follow") and not objective.in_place then
			debug_pause_unit(data.unit, "[CopLogicIdle.enter] wrong logic, shoudln't be in idle", data.unit)
		end

		my_data.scan = objective.scan
		my_data.rubberband_rotation = objective.rubberband_rotation and data.unit:movement():m_rot():y()
	else
		my_data.scan = true
	end

	if my_data.scan then
		my_data.stare_path_search_id = "stare" .. key_str
		my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. key_str
	end

	CopLogicBase._chk_has_old_action(data, my_data)

	if my_data.scan and (not objective or not objective.action) then
		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._scan_for_dangerous_areas, data, data.t)
	end

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	local inventory = data.unit:inventory()

	if inventory:equipped_unit() then
		local base = inventory:equipped_unit():base()
		local weapon_tweak_data = base:weapon_tweak_data()
		local usage = weapon_tweak_data.usage
		my_data.weapon_range = data.char_tweak.weapon[usage].range
	else
		my_data.weapon_range = {
			optimal = 2000,
			close = 1000
		}
	end

	data.unit:brain():set_update_enabled_state(false)
	managers.voice_over:guard_register_idle(data.unit)
	CopLogicIdle._perform_objective_action(data, my_data, objective)
end

-- Lines 138-157
function CopLogicIdle.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)
	data.brain:rem_pos_rsrv("path")
	managers.voice_over:guard_unregister_idle(data.unit)
end

-- Lines 161-237
function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicBase._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)

		return
	end

	if data.team and data.team.id == "criminal1" and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 6) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicBase._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)

	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	delay = data.important and 0 or delay or 0.1

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
end

-- Lines 241-307
function CopLogicIdle._upd_enemy_detection(data)
	if data.unit:brain().dead then
		return
	end

	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicBase._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SUSPICIOUS < new_reaction then
		local objective = data.objective
		local wanted_logic = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_logic = CopLogicBase._get_logic_state_from_reaction(data)
		end

		if wanted_logic and wanted_logic ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not data.unit:brain().logic_queued_key then
				local params = nil

				if managers.groupai:state():whisper_mode() and my_data.vision.detection_delay then
					params = {
						delay = my_data.vision.detection_delay
					}
				end

				CopLogicBase._exit(data.unit, wanted_logic, params)
			end
		end
	end

	if my_data == data.internal_data then
		CopLogicBase._chk_call_the_police(data)

		if my_data ~= data.internal_data then
			return delay
		end
	end

	return delay
end

-- Lines 311-351
function CopLogicIdle._upd_pathing(data, my_data)
	if not data.pathing_results then
		return
	end

	local path = my_data.stare_path_search_id and data.pathing_results[my_data.stare_path_search_id]

	if not path then
		return
	end

	data.pathing_results[my_data.stare_path_search_id] = nil

	if not next(data.pathing_results) then
		data.pathing_results = nil
	end

	if path ~= "failed" then
		my_data.stare_path = path

		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._smooth_stare_path, data, data.t)
	else
		print("[CopLogicIdle:_upd_pathing] stare path failed!", data.unit:key())

		local path_jobs = my_data.stare_path_pos

		table.remove(path_jobs)

		if #path_jobs ~= 0 then
			data.unit:brain():search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
		else
			my_data.stare_path_pos = nil
		end
	end
end

-- Lines 356-430
function CopLogicIdle._upd_scan(data, my_data)
	if CopLogicBase._chk_focus_on_attention_object(data, my_data) then
		return
	end

	if not data.logic.is_available_for_assignment(data) or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	if not my_data.stare_pos or not my_data.next_scan_t or data.t < my_data.next_scan_t then
		if not my_data.turning and my_data.fwd_offset then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end

			CopLogicBase._turn_by_spin(data, my_data, return_spin)
		end

		return
	end

	local scan_target_positions = my_data.scan_target_positions

	if not scan_target_positions then
		scan_target_positions = {}

		for i_pos, pos in ipairs(my_data.stare_pos) do
			table.insert(scan_target_positions, pos)
		end

		my_data.scan_target_positions = scan_target_positions
	end

	local scan_target_index = math.random(#scan_target_positions)
	local scan_pos = scan_target_positions[scan_target_index]

	if #scan_target_positions == 1 then
		my_data.scan_target_positions = nil
	else
		scan_target_positions[scan_target_positions] = scan_target_positions[#scan_target_positions]

		table.remove(scan_target_positions)
	end

	CopLogicBase._set_attention_on_pos(data, scan_pos)

	local should_turn = CopLogicBase._chk_request_action_turn_to_look_pos(data, my_data, data.m_pos, scan_pos)

	if should_turn then
		if my_data.rubberband_rotation then
			my_data.fwd_offset = true
		end

		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action then
			local idle_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:movement():action_request(idle_action)
		end
	end

	my_data.next_scan_t = data.t + math.random(3, 10)
end

-- Lines 435-518
function CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)
	local record = attention_data.criminal_record
	local can_arrest = CopLogicBase._can_arrest(data)

	if not record or not attention_data.is_person then
		if attention_data.settings.reaction == AIAttentionObject.REACT_ARREST and not can_arrest then
			return AIAttentionObject.REACT_AIM
		else
			return attention_data.settings.reaction
		end
	end

	local att_unit = attention_data.unit

	if attention_data.is_deployable or data.t < record.arrest_timeout then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
	end

	if record.status == "dead" then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
	elseif record.status == "disabled" then
		if record.assault_t and record.assault_t - record.disabled_t > 0.6 then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
		else
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
		end
	elseif record.being_arrested then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
	elseif can_arrest and (not record.assault_t or att_unit:base():arrest_settings().aggression_timeout < data.t - record.assault_t) and record.arrest_timeout < data.t and not record.status then
		local under_threat = false

		if attention_data.dis < CopLogicArrest.ARREST_RANGE then
			for u_key, other_crim_rec in pairs(managers.groupai:state():all_criminals()) do
				local other_crim_attention_info = data.detected_attention_objects[u_key]

				if other_crim_attention_info and (other_crim_attention_info.is_deployable or other_crim_attention_info.verified and other_crim_rec.assault_t and data.t - other_crim_rec.assault_t < other_crim_rec.unit:base():arrest_settings().aggression_timeout) then
					under_threat = true

					break
				end
			end
		end

		if under_threat then
			-- Nothing
		elseif attention_data.dis < CopLogicArrest.ARREST_RANGE and attention_data.verified then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_ARREST)
		else
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
		end
	end

	return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
end

-- Lines 523-538
function CopLogicIdle._area_has_enemies(data, area)
	local is_enemy = data.unit:in_slot(managers.slot:get_mask("enemies"))

	if is_enemy then
		if next(area.criminal.units) then
			return true
		end
	elseif next(area.police.units) then
		return true
	end

	return false
end

-- Lines 543-653
function CopLogicIdle._scan_for_dangerous_areas(data)
	local nav_tracker = data.unit:movement():nav_tracker()
	local current_area = managers.groupai:state():get_area_from_nav_seg_id(nav_tracker:nav_segment())
	local found_areas = {
		[current_area] = true
	}
	local areas_to_search = {
		current_area
	}
	local dangerous_far_areas = {}

	if CopLogicIdle._area_has_enemies(data, current_area) then
		return
	end

	while next(areas_to_search) do
		local test_area = table.remove(areas_to_search, 1)

		if CopLogicIdle._area_has_enemies(data, test_area) then
			if test_area == current_area then
				debug_pause("[CopLogic] Found enemies in the area that the unit is in, should not be possible to happen")
			end

			dangerous_far_areas[test_area] = true
		else
			for n_area_id, n_area in pairs(test_area.neighbours) do
				if not found_areas[n_area] then
					found_areas[n_area] = test_area

					table.insert(areas_to_search, n_area)
				end
			end
		end
	end

	local dangerous_near_areas = {}

	for area, _ in pairs(dangerous_far_areas) do
		local backwards_area = area

		while found_areas[backwards_area] ~= current_area do
			backwards_area = found_areas[backwards_area]
		end

		dangerous_near_areas[backwards_area] = true
	end

	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local walk_params = {
		tracker_from = nav_tracker
	}
	local slotmask = data.visibility_slotmask
	local mvec3_set = mvector3.set
	local mvec3_set_z = mvector3.set_z
	local stare_pos = {}
	local path_tasks = {}

	for area, _ in pairs(dangerous_near_areas) do
		local nav_seg_id = area.pos_nav_seg
		local nav_seg = all_nav_segs[area.pos_nav_seg]

		if not nav_seg.disabled then
			local seg_pos = nav_manager:find_random_position_in_segment(nav_seg_id)
			walk_params.pos_to = seg_pos
			local ray_hit = nav_manager:raycast(walk_params)

			if ray_hit then
				mvec3_set(ray_to_pos, seg_pos)
				mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

				ray_hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask)

				if ray_hit then
					table.insert(path_tasks, seg_pos)
				else
					table.insert(stare_pos, ray_to_pos)
				end
			else
				table.insert(stare_pos, seg_pos + math.UP * 160)
			end
		end
	end

	local my_data = data.internal_data

	if #stare_pos > 0 then
		my_data.stare_pos = stare_pos
		my_data.next_scan_t = 0
	end

	if #path_tasks > 0 then
		my_data.stare_path_pos = path_tasks

		data.unit:brain():search_for_path(my_data.stare_path_search_id, path_tasks[#path_tasks])
	end
end

-- Lines 659-763
function CopLogicIdle._smooth_stare_path(data)
	local my_data = data.internal_data
	local slotmask = data.visibility_slotmask
	local stare_path = my_data.stare_path

	if not stare_path or #stare_path == 0 then
		Application:error("[CopLogic] No stare path, should be at least one present")

		return
	end

	local f_nav_point_pos = CopLogicBase._nav_point_pos

	for i, nav_point in ipairs(stare_path) do
		stare_path[i] = f_nav_point_pos(nav_point)
	end

	local mvec3_dis = mvector3.distance
	local mvec3_lerp = mvector3.lerp
	local mvec3_set_z = mvector3.set_z
	local segment_distances = {}
	local total_distance = 0
	local ct_nodes = #stare_path
	local i_node = 1
	local current_pos = stare_path[1]

	repeat
		local next_pos = stare_path[i_node + 1]
		local distance = mvec3_dis(current_pos, next_pos)

		table.insert(segment_distances, distance)

		total_distance = total_distance + distance
		current_pos = next_pos
		i_node = i_node + 1
	until i_node == ct_nodes

	local path_steps = 5
	local distance_step = total_distance / (path_steps + 1)
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = Vector3()
	local current_step_distance = 0
	local i_node = ct_nodes
	local i_step = 0

	repeat
		current_step_distance = current_step_distance + distance_step
		local segment_distance = segment_distances[i_node - 1]

		while segment_distance < current_step_distance do
			i_node = i_node - 1
			current_step_distance = current_step_distance - segment_distance
			segment_distance = segment_distances[i_node - 1]
		end

		mvec3_lerp(ray_to_pos, stare_path[i_node], stare_path[i_node - 1], current_step_distance / segment_distance)
		mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

		local hit = World:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

		if not hit then
			if not my_data.stare_pos then
				my_data.next_scan_t = 0
				my_data.stare_pos = {}
			end

			table.insert(my_data.stare_pos, ray_to_pos)

			break
		end

		i_step = i_step + 1
	until i_step == path_steps

	my_data.stare_path = nil
	local path_jobs = my_data.stare_path_pos

	table.remove(path_jobs)

	if #path_jobs > 0 then
		data.unit:brain():search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
	else
		my_data.stare_path_pos = nil

		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._scan_for_dangerous_areas, data, data.t + 2)
	end
end

-- Lines 768-790
function CopLogicIdle.on_area_safety(data, nav_seg, safe, event)
	if safe or event.reason ~= "criminal" then
		return
	end

	local my_data = data.internal_data
	local u_criminal = event.record.unit
	local key_criminal = u_criminal:key()

	if not data.detected_attention_objects[key_criminal] then
		local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[key_criminal]

		if attention_info then
			local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

			if settings then
				data.detected_attention_objects[key_criminal] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, key_criminal, attention_info, settings)
			end
		end
	end
end

-- Lines 795-846
function CopLogicIdle.on_action_completed(data, action)
	local action_type = action:type()

	if action_type == "turn" then
		data.internal_data.turning = nil

		if data.internal_data.fwd_offset then
			local return_spin = data.internal_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				data.internal_data.fwd_offset = nil
			end
		end
	elseif action_type == "act" then
		local my_data = data.internal_data

		if my_data.action_started == action then
			if my_data.scan and not my_data.exiting and not my_data.stare_path_pos and (not my_data.queued_tasks or not my_data.queued_tasks[my_data.wall_stare_task_key]) then
				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._scan_for_dangerous_areas, data, data.t)
			end

			if action:expired() then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, data.objective)
				end
			elseif not my_data.action_timed_out then
				data.objective_failed_clbk(data.unit, data.objective)
			end
		end

		if action._action_desc and action._action_desc.complete_callback then
			action._action_desc.complete_callback(data.unit)
		end
	elseif action_type == "hurt" and data.important and action:expired() then
		CopLogicBase.chk_start_action_dodge(data, "hit")
	end
end

-- Lines 851-883
function CopLogicIdle.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	local my_data = data.internal_data

	if data.objective and data.objective.action then
		if my_data.action_started then
			if not data.unit:anim_data().act_idle then
				return false
			end
		else
			return false
		end
	end

	if my_data.exiting or data.path_fail_t and data.t < data.path_fail_t + 6 then
		return false
	end

	return true
end

-- Lines 888-891
function CopLogicIdle._can_move(data)
	return not data.objective or not data.objective.pos or not data.objective.in_place
end

-- Lines 895-923
function CopLogicIdle._exit_non_walkable_area(data)
	local my_data = data.internal_data

	if my_data.advancing or my_data.old_action_advancing or not CopLogicIdle._can_move(data) or data.unit:movement():chk_action_forbidden("walk") then
		return false
	end

	local nav_tracker = data.unit:movement():nav_tracker()

	if not nav_tracker:obstructed() then
		return false
	end

	if data.objective and data.objective.nav_seg then
		local nav_seg_id = nav_tracker:nav_segment()

		if not managers.navigation._nav_segments[nav_seg_id].disabled then
			data.objective.in_place = nil

			CopLogicBase.on_new_objective(data, data.objective)

			return true
		end
	end
end

-- Lines 927-931
function CopLogicIdle._get_all_paths(data)
	return {
		stare_path = data.internal_data.stare_path
	}
end

-- Lines 935-937
function CopLogicIdle._set_verified_paths(data, verified_paths)
	data.internal_data.stare_path = verified_paths.stare_path
end

-- Lines 942-977
function CopLogicIdle._upd_curious_reaction(data)
	local my_data = data.internal_data
	local attention_obj = data.attention_obj
	local has_attention = data.unit:movement():attention()

	if not has_attention or has_attention.u_key ~= attention_obj.u_key then
		CopLogicBase._set_attention(data, attention_obj)
	end

	local turn_angle_limit = 70
	local distance = attention_obj.dis

	if (not attention_obj.settings.turn_around_range or distance < attention_obj.settings.turn_around_range) and data.objective and data.objective.rot then
		local angle_to_att_obj = (attention_obj.m_pos - data.m_pos):to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

		if turn_angle_limit < angle_to_att_obj then
			CopLogicBase._turn_by_spin(data, my_data, angle_to_att_obj)

			if my_data.rubberband_rotation then
				my_data.fwd_offset = true
			end
		end
	end

	local is_suspicious = data.cool and attention_obj.reaction == AIAttentionObject.REACT_SUSPICIOUS

	if is_suspicious then
		return CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	end
end

-- Lines 982-1010
function CopLogicIdle._chk_objective_needs_travel(data, objective)
	if not objective.nav_seg and objective.type ~= "follow" then
		return false
	end

	if objective.in_place then
		return false
	end

	if objective.pos then
		return true
	end

	if objective.area and objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()] then
		objective.in_place = true

		return false
	end

	return true
end

-- Lines 1014-1087
function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local applied_objective_stance, applied_objective_pose = nil

	if objective then
		if objective.stance and (not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances[objective.stance]) then
			applied_objective_stance = true
			local upper_body_action = data.unit:movement()._active_actions[3]

			if not upper_body_action or upper_body_action:type() ~= "shoot" then
				data.unit:movement():set_stance(objective.stance)
			end
		end

		if objective.pose and not data.is_suppressed and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses[objective.pose]) then
			applied_objective_pose = true

			if objective.pose == "crouch" then
				CopLogicAttack._request_action_crouch(data)
			elseif objective.pose == "stand" then
				CopLogicAttack._request_action_stand(data)
			end
		end
	end

	if not applied_objective_stance and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[data.unit:anim_data().stance] then
		for stance_name, allowed in pairs(data.char_tweak.allowed_stances) do
			if allowed then
				data.unit:movement():set_stance(stance_name)

				break
			end
		end
	end

	if not applied_objective_pose then
		if data.is_suppressed and not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			CopLogicAttack._request_action_crouch(data)
		elseif data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses[data.unit:anim_data().pose] then
			for pose_name, state in pairs(data.char_tweak.allowed_poses) do
				if state then
					if pose_name == "crouch" then
						CopLogicAttack._request_action_crouch(data)

						break
					end

					if pose_name == "stand" then
						CopLogicAttack._request_action_stand(data)
					end

					break
				end
			end
		end
	end
end

-- Lines 1091-1121
function CopLogicIdle._perform_objective_action(data, my_data, objective)
	if not objective or my_data.action_started or not data.unit:anim_data().act_idle and data.unit:movement():chk_action_forbidden("action") then
		return
	end

	if objective.action then
		my_data.action_started = data.unit:brain():action_request(objective.action)
	else
		my_data.action_started = true
	end

	if my_data.action_started then
		if objective.action_duration or objective.action_timeout_t then
			CopLogicBase.request_action_timeout_callback(data)
		end

		if objective.action_start_clbk then
			objective.action_start_clbk(data.unit)
		end
	end
end
