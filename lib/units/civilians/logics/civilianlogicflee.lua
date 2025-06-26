CivilianLogicFlee = class(CivilianLogicBase)

function CivilianLogicFlee.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.cbt

	data.unit:brain():set_update_enabled_state(false)

	local key_str = tostring(data.key)
	my_data.panic_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())
	my_data.vision = data.char_tweak.vision

	CivilianLogicFlee.reset_actions(data)

	if data.objective then
		if data.objective.alert_data then
			CivilianLogicFlee.on_alert(data, data.objective.alert_data)

			if my_data ~= data.internal_data then
				return
			end

			if data.unit:anim_data().react_enter and not data.unit:anim_data().idle then
				my_data.delayed_post_react_alert_id = "postreact_alert" .. key_str

				CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
					data = data,
					alert_data = clone(data.objective.alert_data)
				}), TimerManager:game():time() + math.lerp(4, 8, math.random()))
			end
		elseif data.objective.dmg_info then
			CivilianLogicFlee.damage_clbk(data, data.objective.dmg_info)
		end
	end

	data.unit:movement():set_stance("hos")
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and data.objective.was_rescued then
		data.objective.was_rescued = nil

		CivilianLogicFlee._get_coarse_flee_path(data)
	end

	if not data.been_outlined and data.char_tweak.outline_on_discover then
		my_data.outline_detection_task_key = "CivilianLogicFlee_upd_outline_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
	end

	if not my_data.detection_task_key and data.unit:anim_data().react_enter then
		my_data.detection_task_key = "CivilianLogicFlee._upd_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicFlee._upd_detection, data, data.t + 0)
	end

	local attention_settings = {
		"civ_enemy_cbt",
		"civ_civ_cbt",
		"civ_murderer_cbt"
	}

	CivilianLogicFlee.schedule_run_away_clbk(data)

	if not my_data.delayed_post_react_alert_id and data.unit:movement():stance_name() == "ntl" then
		my_data.delayed_post_react_alert_id = "postreact_alert" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
			data = data
		}), TimerManager:game():time() + math.lerp(4, 8, math.random()))
	end

	data.unit:brain():set_attention_settings(attention_settings)

	if data.char_tweak.calls_in and not managers.groupai:state():is_police_called() then
		my_data.call_police_clbk_id = "civ_call_police" .. key_str
		local call_t = math.max(data.call_police_delay_t or 0, TimerManager:game():time() + math.lerp(1, 10, math.random()))

		CopLogicBase.add_delayed_clbk(my_data, my_data.call_police_clbk_id, callback(CivilianLogicFlee, CivilianLogicFlee, "clbk_chk_call_the_police", data), call_t)
	end

	my_data.next_action_t = 0
end

function CivilianLogicFlee.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)
	CopLogicBase._reset_attention(data)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_delayed_clbks(my_data)
	CopLogicBase.cancel_queued_tasks(my_data)

	if my_data.enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(my_data.enemy_weapons_hot_listen_id)
	end

	if my_data.calling_the_police then
		managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
	end
end

function CivilianLogicFlee.update(data)
	local exit_state = nil
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = data.t

	if my_data.calling_the_police then
		-- Nothing
	elseif my_data.flee_path_search_id or my_data.coarse_path_search_id then
		CivilianLogicFlee._update_pathing(data, my_data)
	elseif my_data.flee_path then
		if not unit:movement():chk_action_forbidden("walk") then
			CivilianLogicFlee._start_moving_to_cover(data, my_data)
		end
	elseif my_data.coarse_path then
		if not my_data.advancing and my_data.next_action_t < data.t then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index == total_nav_points then
				if data.unit:unit_data().mission_element then
					data.unit:unit_data().mission_element:event("fled", data.unit)
				end

				data.unit:base():set_slot(unit, 0)
			else
				local to_pos, to_cover = nil

				if cur_index == total_nav_points - 1 then
					to_pos = my_data.flee_target.pos
				else
					local next_area = managers.groupai:state():get_area_from_nav_seg_id(coarse_path[cur_index + 1][1])
					local cover = managers.navigation:find_cover_in_nav_seg_1(next_area.nav_segs)

					if cover then
						CopLogicAttack._set_best_cover(data, my_data, {
							cover
						})

						to_cover = my_data.best_cover
					else
						to_pos = CopLogicTravel._get_pos_on_wall(coarse_path[cur_index + 1][2], 700)
					end
				end

				my_data.flee_path_search_id = "civ_flee" .. tostring(data.key)

				if to_cover then
					my_data.pathing_to_cover = to_cover

					unit:brain():search_for_path_to_cover(my_data.flee_path_search_id, to_cover[1], nil, nil)
				else
					data.brain:add_pos_rsrv("path", {
						radius = 30,
						position = to_pos
					})
					unit:brain():search_for_path(my_data.flee_path_search_id, to_pos)
				end
			end
		end
	elseif my_data.best_cover then
		local best_cover = my_data.best_cover

		if not my_data.moving_to_cover or my_data.moving_to_cover ~= best_cover then
			if not my_data.in_cover or my_data.in_cover ~= best_cover then
				if not unit:anim_data().panic then
					local action_data = {
						variant = "panic",
						body_part = 1,
						clamp_to_graph = true,
						type = "act"
					}

					data.unit:brain():action_request(action_data)
					data.unit:brain():set_update_enabled_state(true)
					CopLogicBase._reset_attention(data)
				end

				my_data.pathing_to_cover = my_data.best_cover
				local search_id = "civ_cover" .. tostring(data.key)
				my_data.flee_path_search_id = search_id

				data.unit:brain():search_for_path_to_cover(search_id, my_data.best_cover[1])
			end
		end
	end
end

function CivilianLogicFlee._upd_detection(data)
	local my_data = data.internal_data

	if my_data.advancing or not data.unit:anim_data().react and not data.unit:anim_data().react_enter then
		my_data.detection_task_key = nil

		CopLogicBase._reset_attention(data)

		return
	end

	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_reaction = CivilianLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CivilianLogicIdle._set_attention_obj(data, new_attention, new_reaction)

	delay = delay * 3

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicFlee._upd_detection, data, data.t + delay)
end

function CivilianLogicFlee._update_pathing(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		my_data.has_cover_path = nil
		local path = my_data.flee_path_search_id and pathing_results[my_data.flee_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.flee_path = path

				if my_data.pathing_to_cover then
					my_data.has_path_to_cover = my_data.pathing_to_cover
				end
			end

			my_data.pathing_to_cover = nil
			my_data.flee_path_search_id = nil
		end
	end
end

function CivilianLogicFlee.on_action_completed(data, action)
	local my_data = data.internal_data

	if action:type() == "walk" then
		my_data.next_action_t = TimerManager:game():time() + math.lerp(2, 8, math.random())

		if action:expired() then
			if my_data.moving_to_cover then
				data.unit:sound():say("a03x_any", true)

				my_data.in_cover = my_data.moving_to_cover

				CopLogicAttack._set_nearest_cover(my_data, my_data.in_cover)
			end

			if my_data.coarse_path_index then
				my_data.coarse_path_index = my_data.coarse_path_index + 1
			end
		end

		my_data.moving_to_cover = nil
		my_data.advancing = nil

		if not my_data.coarse_path_index then
			data.unit:brain():set_update_enabled_state(false)
		end
	elseif action:type() == "act" and my_data.calling_the_police then
		my_data.calling_the_police = nil

		if not my_data.called_the_police then
			managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
		end
	end
end

function CivilianLogicFlee.on_alert(data, alert_data)
	local my_data = data.internal_data

	if my_data.coarse_path then
		return
	end

	if CopLogicBase.is_alert_aggressive(alert_data[1]) then
		local aggressor = alert_data[5]

		if aggressor and aggressor:base() then
			data.unit:brain():on_long_distance_interact(1, aggressor)

			return
		end
	end

	local anim_data = data.unit:anim_data()

	if anim_data.react_enter and not anim_data.idle then
		if not my_data.delayed_post_react_alert_id then
			my_data.delayed_post_react_alert_id = "postreact_alert" .. tostring(data.key)

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
				data = data,
				alert_data = clone(alert_data)
			}), TimerManager:game():time() + 1)
		end

		return
	elseif anim_data.peaceful or data.unit:movement():stance_name() == "ntl" then
		local action_data = {
			variant = "panic",
			body_part = 1,
			clamp_to_graph = true,
			type = "act"
		}

		data.unit:brain():action_request(action_data)
		data.unit:sound():say("a01x_any", true)

		if data.unit:unit_data().mission_element then
			data.unit:unit_data().mission_element:event("panic", data.unit)
		end

		if not managers.groupai:state():enemy_weapons_hot() then
			local alert = {
				"vo_distress",
				data.unit:movement():m_head_pos(),
				200,
				data.SO_access,
				data.unit
			}

			managers.groupai:state():propagate_alert(alert)
		end

		return
	elseif alert_data[1] ~= "bullet" and alert_data[1] ~= "aggression" and alert_data[1] ~= "explosion" then
		return
	elseif anim_data.react or anim_data.drop then
		local action_data = {
			variant = "panic",
			body_part = 1,
			clamp_to_graph = true,
			type = "act"
		}

		data.unit:brain():action_request(action_data)

		local is_dangerous = CopLogicBase.is_alert_dangerous(alert_data[1])

		if is_dangerous then
			data.unit:sound():say("a01x_any", true)
		end

		if data.unit:unit_data().mission_element then
			data.unit:unit_data().mission_element:event("panic", data.unit)
		end

		CopLogicBase._reset_attention(data)

		if is_dangerous and not managers.groupai:state():enemy_weapons_hot() then
			local alert = {
				"vo_distress",
				data.unit:movement():m_head_pos(),
				200,
				data.SO_access,
				data.unit
			}

			managers.groupai:state():propagate_alert(alert)
		end

		return
	end

	CivilianLogicFlee._run_away_from_alert(data, alert_data)
end

function CivilianLogicFlee._run_away_from_alert(data, alert_data)
	local my_data = data.internal_data
	local avoid_pos = nil

	if alert_data[1] == "bullet" then
		local tail = alert_data[2]
		local head = alert_data[6]
		local alert_dir = head - tail
		local alert_len = mvector3.normalize(alert_dir)
		avoid_pos = data.m_pos - tail
		local my_dot = mvector3.dot(alert_dir, avoid_pos)

		mvector3.set(avoid_pos, alert_dir)
		mvector3.multiply(avoid_pos, my_dot)
		mvector3.add(avoid_pos, tail)
	else
		avoid_pos = alert_data[2] or alert_data[5] and alert_data[5]:position() or math.UP:random_orthogonal() * 100 + data.m_pos
	end

	my_data.avoid_pos = avoid_pos

	if not my_data.cover_search_task_key then
		my_data.cover_search_task_key = "CivilianLogicFlee._find_hide_cover" .. tostring(data.key)

		CopLogicBase.queue_task(my_data, my_data.cover_search_task_key, CivilianLogicFlee._find_hide_cover, data, data.t + 0.5)
	end
end

function CivilianLogicFlee.post_react_alert_clbk(shait, params)
	local data = params.data
	local alert_data = params.alert_data
	local my_data = data.internal_data
	local anim_data = data.unit:anim_data()

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_post_react_alert_id)

	if anim_data.react_enter then
		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
			data = data,
			alert_data = data.objective and data.objective.alert_data and clone(data.objective.alert_data) or alert_data
		}), TimerManager:game():time() + 1)

		return
	end

	my_data.delayed_post_react_alert_id = nil

	if not anim_data.react then
		return
	end

	if alert_data and alive(alert_data[5]) then
		CivilianLogicFlee._run_away_from_alert(data, alert_data)

		return
	end

	if anim_data.react or anim_data.drop then
		local action_data = {
			variant = "panic",
			body_part = 1,
			clamp_to_graph = true,
			type = "act"
		}

		data.unit:brain():action_request(action_data)
		data.unit:sound():say("a01x_any", true)

		if data.unit:unit_data().mission_element then
			data.unit:unit_data().mission_element:event("panic", data.unit)
		end

		CopLogicBase._reset_attention(data)

		if not managers.groupai:state():enemy_weapons_hot() then
			local alert = {
				"vo_distress",
				data.unit:movement():m_head_pos(),
				200,
				data.SO_access,
				data.unit
			}

			managers.groupai:state():propagate_alert(alert)
		end

		return
	end

	CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
		data = data,
		alert_data = data.objective and data.objective.alert_data and clone(data.objective.alert_data) or alert_data
	}), TimerManager:game():time() + 1)
end

function CivilianLogicFlee._flee_coarse_path_verify_clbk(shait, nav_seg)
	return managers.groupai:state():is_nav_seg_safe(nav_seg)
end

function CivilianLogicFlee.on_long_distance_interact(data, amount, aggressor_unit)
	if not data.char_tweak.intimidateable or data.unit:base().unintimidateable or data.unit:anim_data().unintimidateable then
		return
	end

	local my_data = data.internal_data

	if not my_data.delayed_intimidate_id then
		my_data.delayed_intimidate_id = "intimidate" .. tostring(data.key)
		local delay = 1 - amount + math.random() * 0.2

		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_intimidate_id, callback(CivilianLogicFlee, CivilianLogicFlee, "_delayed_intimidate_clbk", {
			data,
			amount,
			aggressor_unit
		}), TimerManager:game():time() + delay)
	end
end

function CivilianLogicFlee._delayed_intimidate_clbk(ignore_this, params)
	local data = params[1]
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_intimidate_id)

	my_data.delayed_intimidate_id = nil

	if not alive(params[3]) then
		return
	end

	CivilianLogicIdle.on_long_distance_interact(data, params[2], params[3])
end

function CivilianLogicFlee._cancel_pathing(data, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	my_data.pathing_to_cover = nil
	my_data.has_path_to_cover = nil
	my_data.coarse_path_search_id = nil
	my_data.coarse_search_failed = nil
	my_data.coarse_path = nil
	my_data.flee_target = nil
	my_data.coarse_path_index = nil
end

function CivilianLogicFlee._find_hide_cover(data)
	local my_data = data.internal_data
	my_data.cover_search_task_key = nil

	if data.unit:anim_data().dont_flee then
		return
	end

	local avoid_pos = nil

	if my_data.avoid_pos then
		avoid_pos = my_data.avoid_pos
	elseif data.attention_obj and AIAttentionObject.REACT_SCARED <= data.attention_obj.reaction then
		avoid_pos = data.attention_obj.m_pos
	else
		local closest_crim, closest_crim_dis = nil

		for u_key, att_data in pairs(data.detected_attention_objects) do
			if not closest_crim_dis or att_data.dis < closest_crim_dis then
				closest_crim = att_data
				closest_crim_dis = att_data.dis
			end
		end

		if closest_crim then
			avoid_pos = closest_crim.m_pos
		else
			avoid_pos = Vector3()

			mvector3.random_orthogonal(avoid_pos, math.UP)
			mvector3.multiply(avoid_pos, 100)
			mvector3.add(data.m_pos, 100)
		end
	end

	if my_data.best_cover then
		local best_cover_vec = avoid_pos - my_data.best_cover[1][NavigationManager.COVER_POSITION]

		if mvector3.dot(best_cover_vec, my_data.best_cover[1][NavigationManager.COVER_FORWARD]) > 0.7 then
			return
		end
	end

	local cover = managers.navigation:find_cover_away_from_pos(data.m_pos, avoid_pos, my_data.panic_area.nav_segs)

	if cover then
		if not data.unit:anim_data().panic then
			data.unit:brain():action_request({
				variant = "panic",
				body_part = 1,
				clamp_to_graph = true,
				type = "act"
			})
		end

		CivilianLogicFlee._cancel_pathing(data, my_data)
		CopLogicAttack._set_best_cover(data, my_data, {
			cover
		})
		data.unit:brain():set_update_enabled_state(true)
		CopLogicBase._reset_attention(data)
	elseif data.unit:anim_data().react or data.unit:anim_data().halt then
		data.unit:brain():action_request({
			variant = "panic",
			body_part = 1,
			clamp_to_graph = true,
			type = "act"
		})
		data.unit:sound():say("a02x_any", true)

		if data.unit:unit_data().mission_element then
			data.unit:unit_data().mission_element:event("panic", data.unit)
		end

		CopLogicBase._reset_attention(data)

		if not managers.groupai:state():enemy_weapons_hot() then
			managers.groupai:state():propagate_alert({
				"vo_distress",
				data.unit:movement():m_head_pos(),
				200,
				data.SO_access,
				data.unit
			})
		end
	end
end

function CivilianLogicFlee._start_moving_to_cover(data, my_data)
	data.unit:sound():say("a03x_any", true)
	CopLogicAttack._adjust_path_start_pos(data, my_data.flee_path)
	CopLogicBase._reset_attention(data)

	local new_action_data = {
		body_part = 2,
		variant = "run",
		type = "walk",
		nav_path = my_data.flee_path
	}
	my_data.advancing = data.unit:brain():action_request(new_action_data)
	my_data.flee_path = nil

	data.brain:rem_pos_rsrv("path")

	if my_data.has_path_to_cover then
		my_data.moving_to_cover = my_data.has_path_to_cover
		my_data.has_path_to_cover = nil
	end
end

function CivilianLogicFlee._add_delayed_rescue_SO(data, my_data)
	if my_data.rescue_active then
		return
	end

	if data.char_tweak.flee_type ~= "hide" then
		if data.unit:unit_data() and data.unit:unit_data().not_rescued then
			-- Nothing
		elseif my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
			managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 1)
		elseif my_data.rescuer then
			local objective = my_data.rescuer:brain():objective()
			local rescuer = my_data.rescuer
			my_data.rescuer = nil

			managers.groupai:state():on_objective_failed(rescuer, objective)
		elseif my_data.rescue_SO_id then
			managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

			my_data.rescue_SO_id = nil
		end
	end

	my_data.rescue_active = true
end

function CivilianLogicFlee.on_rescue_SO_completed(ignore_this, data, good_pig)
	if data.internal_data.rescuer and good_pig:key() == data.internal_data.rescuer:key() then
		data.internal_data.rescue_active = nil
		data.internal_data.rescuer = nil

		if data.name == "surrender" then
			local new_action = nil

			if data.unit:anim_data().drop then
				new_action = {
					variant = "stand",
					body_part = 1,
					type = "act"
				}
			end

			if new_action then
				data.unit:interaction():set_active(false, true)
				data.unit:brain():action_request(new_action)
			end

			data.unit:brain():set_objective({
				was_rescued = true,
				is_default = true,
				type = "free"
			})
		elseif not CivilianLogicFlee._get_coarse_flee_path(data) then
			return
		end
	end

	data.unit:brain():set_update_enabled_state(true)
end

function CivilianLogicFlee._get_coarse_flee_path(data)
	local flee_point = managers.groupai:state():safe_flee_point(data.unit:movement():nav_tracker():nav_segment())

	if not flee_point then
		return
	end

	local my_data = data.internal_data
	local verify_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "_flee_coarse_path_verify_clbk")
	local search_params = {
		from_tracker = data.unit:movement():nav_tracker(),
		to_seg = flee_point.nav_seg,
		id = "CivilianLogicFlee._get_coarse_flee_path" .. tostring(data.key),
		access_pos = data.char_tweak.access,
		verify_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "_flee_coarse_path_verify_clbk")
	}
	local coarse_path = managers.navigation:search_coarse(search_params)

	if not coarse_path then
		return
	end

	managers.groupai:state():trim_coarse_path_to_areas(coarse_path)

	my_data.coarse_path_index = 1
	my_data.coarse_path = coarse_path
	my_data.flee_target = flee_point

	return true
end

function CivilianLogicFlee.on_new_objective(data, old_objective)
	CivilianLogicIdle.on_new_objective(data, old_objective)
end

function CivilianLogicFlee.on_rescue_allowed_state(data, state)
end

function CivilianLogicFlee._get_all_paths(data)
	return {
		flee_path = data.internal_data.flee_path
	}
end

function CivilianLogicFlee._set_verified_paths(data, verified_paths)
	data.internal_data.flee_path = verified_paths.flee_path
end

function CivilianLogicFlee.reset_actions(data)
	local walk_action = data.unit:movement()._active_actions[2]

	if walk_action and walk_action:type() == "walk" then
		local action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:movement():action_request(action)
	end
end

function CivilianLogicFlee.clbk_chk_run_away(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.run_away_clbk_id)

	my_data.run_away_clbk_id = nil

	if not my_data.coarse_path and CivilianLogicFlee._get_coarse_flee_path(data) then
		data.unit:brain():set_update_enabled_state(true)
	end

	data.run_away_next_chk_t = TimerManager:game():time() + math.lerp(5, 8, math.random())

	CivilianLogicFlee.schedule_run_away_clbk(data)
end

function CivilianLogicFlee.schedule_run_away_clbk(data)
	local my_data = data.internal_data

	if my_data.run_away_clbk_id or not data.char_tweak.run_away_delay then
		return
	end

	data.run_away_next_chk_t = data.run_away_next_chk_t or data.t + math.lerp(data.char_tweak.run_away_delay[1], data.char_tweak.run_away_delay[2], math.random())
	my_data.run_away_clbk_id = "runaway_chk" .. tostring(data.key)

	CopLogicBase.add_delayed_clbk(my_data, my_data.run_away_clbk_id, callback(CivilianLogicFlee, CivilianLogicFlee, "clbk_chk_run_away", data), data.run_away_next_chk_t)
end

function CivilianLogicFlee.clbk_chk_call_the_police(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.call_police_clbk_id)

	my_data.call_police_clbk_id = nil

	if managers.groupai:state():is_police_called() then
		return
	end

	local my_areas = managers.groupai:state():get_areas_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())
	local already_calling = false

	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		local civ_nav_seg = u_data.unit:movement():nav_tracker():nav_segment()

		if my_areas[civ_nav_seg] and u_data.unit:anim_data().call_police then
			already_calling = true

			break
		end
	end

	if not already_calling and (not my_data.calling_the_police or not data.unit:movement():chk_action_forbidden("walk")) then
		local action = {
			variant = "cmf_so_call_police",
			body_part = 1,
			type = "act",
			blocks = {}
		}
		my_data.calling_the_police = data.unit:movement():action_request(action)

		if my_data.calling_the_police then
			CivilianLogicFlee._say_call_the_police(data, my_data)
			managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "calling")
		end
	end

	my_data.call_police_clbk_id = "civ_call_police" .. tostring(data.key)

	CopLogicBase.add_delayed_clbk(my_data, my_data.call_police_clbk_id, callback(CivilianLogicFlee, CivilianLogicFlee, "clbk_chk_call_the_police", data), TimerManager:game():time() + math.lerp(15, 20, math.random()))
end

function CivilianLogicFlee._say_call_the_police(data, my_data)
	data.unit:sound():say("911_call", true, false)
end

function CivilianLogicFlee.on_police_call_success(data)
	data.internal_data.called_the_police = true
end
