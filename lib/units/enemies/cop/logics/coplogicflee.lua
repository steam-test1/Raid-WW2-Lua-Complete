CopLogicFlee = class(CopLogicBase)

function CopLogicFlee.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.vision = data.char_tweak.vision.combat
	data.internal_data = my_data

	if data.unit:movement():chk_action_forbidden("walk") then
		my_data.wants_stop_old_walk_action = true
	end

	local key_str = tostring(data.key)
	my_data.detection_task_key = "CopLogicFlee._update_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicFlee._update_enemy_detection, data)

	my_data.cover_update_task_key = "CopLogicFlee._update_cover" .. key_str

	CopLogicBase.queue_task(my_data, my_data.cover_update_task_key, CopLogicFlee._update_cover, data, data.t + 1)

	my_data.cover_path_search_id = key_str .. "cover"

	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_cover = true
	end

	CopLogicBase._reset_attention(data)
	data.unit:movement():set_stance("wnd")
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({
		cbt = true
	})
end

function CopLogicFlee.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	data.brain:rem_pos_rsrv("path")
end

function CopLogicFlee.update(data)
	local exit_state = nil
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = data.t

	if my_data.wants_stop_old_walk_action then
		if not data.unit:movement():chk_action_forbidden("walk") then
			data.unit:movement():action_request({
				type = "idle",
				body_part = 2
			})

			my_data.wants_stop_old_walk_action = nil
		end

		return
	end

	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		CopLogicFlee._cancel_flee_pathing(data, my_data)
		CopLogicFlee._update_cover_pathing(data, my_data)

		if my_data.cover_pathing then
			-- Nothing
		elseif my_data.moving_to_cover then
			-- Nothing
		elseif my_data.cover_path then
			if not my_data.turning and not unit:movement():chk_action_forbidden("walk") then
				CopLogicAttack._adjust_path_start_pos(data, my_data.cover_path)

				local new_action_data = {
					type = "walk",
					body_part = 2,
					variant = "run",
					nav_path = my_data.cover_path
				}
				my_data.cover_path = nil

				if unit:brain():action_request(new_action_data) then
					my_data.moving_to_cover = my_data.best_cover
					my_data.in_cover = nil
				end
			end
		elseif my_data.best_cover and my_data.best_cover ~= my_data.in_cover then
			my_data.cover_pathing = true

			unit:brain():search_for_path(my_data.cover_path_search_id, my_data.best_cover[1][NavigationManager.COVER_POSITION])
		end
	else
		CopLogicFlee._cancel_cover_pathing(data, my_data)

		if my_data.advancing then
			if not unit:anim_data().crouch then
				CopLogicAttack._request_action_crouch(data)
			end
		elseif my_data.processing_flee_path or my_data.processing_coarse_path then
			CopLogicFlee._update_pathing(data, my_data)
		elseif my_data.cover_leave_t then
			if not my_data.turning and not unit:movement():chk_action_forbidden("walk") then
				if my_data.cover_leave_t < t then
					my_data.cover_leave_t = nil
				elseif my_data.best_cover and not CopLogicTravel._chk_request_action_turn_to_cover(data, my_data) and not unit:anim_data().crouch then
					CopLogicAttack._request_action_crouch(data)
				end
			end
		elseif my_data.flee_path then
			if my_data.path_blocked == false and not unit:movement():chk_action_forbidden("walk") then
				local new_action_data = {
					type = "walk",
					body_part = 2,
					path_simplified = true,
					variant = "run",
					nav_path = my_data.flee_path
				}
				my_data.flee_path = nil
				my_data.advancing = unit:brain():action_request(new_action_data)

				if my_data.advancing then
					my_data.in_cover = nil

					if my_data.cover_pathing then
						managers.navigation:cancel_pathing_search(my_data.cover_path_search_id)

						my_data.cover_pathing = nil
					end
				end
			end
		elseif my_data.flee_target then
			if my_data.coarse_path then
				local coarse_path = my_data.coarse_path
				local cur_index = my_data.coarse_path_index
				local total_nav_points = #coarse_path

				if cur_index == total_nav_points then
					data.unit:base():set_slot(unit, 0)
				elseif not my_data.processing_flee_path then
					local to_pos = nil

					if cur_index == total_nav_points - 1 then
						to_pos = my_data.flee_target.pos
					else
						local end_pos = coarse_path[cur_index + 1][2]
						local my_pos = data.m_pos
						local walk_dir = end_pos - my_pos
						local walk_dis = mvector3.normalize(walk_dir)
						local cover_range = math.min(700, math.max(0, walk_dis - 100))
						local cover = managers.navigation:find_cover_near_pos_1(end_pos, end_pos + walk_dir * 700, cover_range, cover_range)

						if cover then
							if my_data.best_cover then
								managers.navigation:release_cover(my_data.best_cover[1])
							end

							managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

							my_data.moving_to_cover = {
								cover
							}
							my_data.best_cover = my_data.moving_to_cover
							to_pos = cover[1]
						else
							to_pos = end_pos
						end
					end

					my_data.flee_path_search_id = tostring(unit:key()) .. "flee"
					my_data.processing_flee_path = true
					my_data.path_blocked = nil

					unit:brain():search_for_path(my_data.flee_path_search_id, to_pos)
				end
			else
				local search_id = tostring(unit:key()) .. "coarseflee"
				local verify_clbk = nil

				if not my_data.coarse_search_failed then
					verify_clbk = callback(CopLogicFlee, CopLogicFlee, "_flee_coarse_path_verify_clbk")
				end

				if unit:brain():search_for_coarse_path(search_id, my_data.flee_target.nav_seg, verify_clbk) then
					my_data.coarse_path_search_id = search_id
					my_data.processing_coarse_path = true
				end
			end
		else
			local flee_pos = managers.groupai:state():flee_point(data.unit:movement():nav_tracker():nav_segment())

			if flee_pos then
				local nav_seg = managers.navigation:get_nav_seg_from_pos(flee_pos)
				my_data.flee_target = {
					nav_seg = nav_seg,
					pos = flee_pos
				}
			end
		end
	end
end

function CopLogicFlee._update_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_COMBAT
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicBase._get_priority_attention(data, data.detected_attention_objects, CopLogicFlee._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	my_data.advance_blocked = nil
	my_data.path_blocked = false

	if new_attention then
		my_data.want_cover = true

		CopLogicFlee._upd_shoot(data, my_data)
	else
		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end

		if my_data.shooting then
			local new_action = {
				type = "idle",
				body_part = 3
			}

			data.unit:brain():action_request(new_action)
			data.unit:movement():set_allow_fire(false)
		end

		my_data.want_cover = nil
	end

	if data.important then
		delay = 0
	else
		delay = 0.5 + delay * 1.5
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicFlee._update_enemy_detection, data, data.t + delay)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function CopLogicFlee._upd_shoot(data, my_data)
	local shoot = nil
	local focus_enemy = data.attention_obj
	local action_taken = data.unit:movement():chk_action_forbidden("walk") or my_data.turning or my_data.moving_to_cover

	if not action_taken then
		if my_data.advance_blocked and data.unit:anim_data().move then
			local new_action = {
				type = "idle",
				body_part = 2
			}

			data.unit:brain():action_request(new_action)
		elseif not CopLogicAttack._request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos) and not data.unit:anim_data().crouch then
			CopLogicAttack._request_action_crouch(data)
		end
	end

	if not my_data.shooting and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
		CopLogicBase._set_attention(data, focus_enemy)

		my_data.attention_unit = focus_enemy.u_key
		local shoot_action = {
			type = "shoot",
			body_part = 3
		}

		if data.unit:brain():action_request(shoot_action) then
			my_data.shooting = true
		end
	elseif my_data.attention_unit ~= focus_enemy.u_key then
		CopLogicBase._set_attention(data, focus_enemy)

		my_data.attention_unit = focus_enemy.u_key
	end

	data.unit:movement():set_allow_fire(focus_enemy.verified and true or false)
end

function CopLogicFlee._update_pathing(data, my_data)
	if data.pathing_results then
		local path = my_data.flee_path_search_id and data.pathing_results[my_data.flee_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.flee_path = path
			else
				cat_print("george", "CopLogicFlee:_update_pathing() flee_path failed!")
			end

			data.pathing_results[my_data.flee_path_search_id] = nil
			my_data.processing_flee_path = nil
			my_data.flee_path_search_id = nil
		end

		path = data.pathing_results[my_data.coarse_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.coarse_path = path
				my_data.coarse_path_index = 1
			else
				if my_data.coarse_search_failed then
					cat_print("george", "CopLogicFlee:_update_pathing() coarse_path failed unsafe!")

					my_data.flee_target = nil
				end

				my_data.coarse_search_failed = true
			end

			data.pathing_results[my_data.coarse_path_search_id] = nil
			my_data.processing_coarse_path = nil
			my_data.coarse_path_search_id = nil
		end

		data.pathing_results = nil
		my_data.cover_pathing = nil
	end
end

function CopLogicFlee._update_cover_pathing(data, my_data)
	if data.pathing_results then
		local path = data.pathing_results[my_data.cover_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.cover_path = path
			else
				cat_print("george", "CopLogicFlee:_update_cover_pathing() cover pathing failed!")
			end

			my_data.cover_pathing = nil
		end

		data.pathing_results = nil
		my_data.processing_flee_path = nil
		my_data.flee_path_search_id = nil
		my_data.processing_coarse_path = nil
		my_data.coarse_path_search_id = nil
	end
end

function CopLogicFlee._chk_reaction_to_attention_object(data, attention_data, stationary)
	local record = attention_data.criminal_record

	if not record or not attention_data.is_person then
		return attention_data.settings.reaction
	end

	if record.status == "disabled" and (not record.assault_t or record.assault_t - record.disabled_t > 0.6) and (record.engaged_force < 5 or attention_data.is_human_player and CopLogicBase._is_important_to_player(record, data.key)) then
		return math.min(attention_data.reaction, AIAttentionObject.REACT_COMBAT)
	end

	return AIAttentionObject.REACT_IDLE
end

function CopLogicFlee.on_action_completed(data, action)
	local action_type = action:type()

	if action_type == "walk" then
		local my_data = data.internal_data

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)

				my_data.in_cover = my_data.best_cover

				if my_data.advancing then
					my_data.cover_leave_t = data.t + math.random(2, 4)
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][NavigationManager.COVER_POSITION], data.unit:movement():m_pos())

			if dis > 100 then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if my_data.advancing then
			if action:expired() then
				my_data.coarse_path_index = my_data.coarse_path_index + 1
			end

			my_data.advancing = nil
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil
	elseif action_type == "shoot" then
		data.internal_data.shooting = nil
	elseif action_type == "hurt" then
		if data.important and action:expired() then
			local action_data = CopLogicBase.chk_start_action_dodge(data, "hit")
			local my_data = data.internal_data

			if action_data then
				CopLogicFlee._cancel_cover_pathing(data, my_data)
				CopLogicFlee._cancel_flee_pathing(data, my_data)
			end
		end
	elseif action_type == "dodge" then
		local my_data = data.internal_data

		CopLogicFlee._cancel_cover_pathing(data, my_data)
		CopLogicFlee._cancel_flee_pathing(data, my_data)
	end
end

function CopLogicFlee._update_cover(data)
	local my_data = data.internal_data
	local cover_release_dis = 100
	local best_cover = my_data.best_cover
	local nearest_cover = my_data.nearest_cover
	local want_cover = my_data.want_cover

	if want_cover and data.attention_obj then
		local threat_pos = data.attention_obj.verified_pos
		local min_threat_dis = 700

		if not my_data.moving_to_cover and (not best_cover or not CopLogicAttack._verify_cover(best_cover[1], threat_pos, min_threat_dis) or min_threat_dis >= mvector3.distance(best_cover[1][NavigationManager.COVER_POSITION], threat_pos)) then
			local better_cover = nil

			if nearest_cover and CopLogicAttack._verify_cover(nearest_cover[1], threat_pos, min_threat_dis) then
				better_cover = nearest_cover
			end

			if not better_cover then
				local max_near_dis = 1000
				local found_cover = managers.navigation:find_cover_near_pos_1(data.m_pos, threat_pos, max_near_dis, min_threat_dis)

				if found_cover then
					better_cover = {
						found_cover
					}
				end
			end

			if better_cover then
				if best_cover then
					managers.navigation:release_cover(best_cover[1])
					CopLogicFlee._cancel_cover_pathing(data, my_data)
				end

				my_data.best_cover = better_cover

				managers.navigation:reserve_cover(better_cover[1], data.pos_rsrv_id)
			end
		end
	else
		if nearest_cover and cover_release_dis < mvector3.distance(nearest_cover[1][NavigationManager.COVER_POSITION], data.m_pos) then
			managers.navigation:release_cover(nearest_cover[1])

			my_data.nearest_cover = nil
		end

		if best_cover and cover_release_dis < mvector3.distance(best_cover[1][NavigationManager.COVER_POSITION], data.m_pos) then
			managers.navigation:release_cover(best_cover[1])

			my_data.best_cover = nil
		end
	end

	local delay = want_cover and 2 or 3

	CopLogicBase.queue_task(my_data, my_data.cover_update_task_key, CopLogicFlee._update_cover, data, data.t + delay)
end

function CopLogicFlee._cancel_cover_pathing(data, my_data)
	if my_data.cover_pathing then
		if data.active_searches[my_data.cover_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.cover_path_search_id)

			data.active_searches[my_data.cover_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.cover_path_search_id] = nil
		end

		my_data.cover_pathing = nil
	end

	my_data.cover_path = nil
end

function CopLogicFlee._cancel_flee_pathing(data, my_data)
	if my_data.flee_path_search_id then
		if data.active_searches[my_data.flee_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.flee_path_search_id)
		elseif data.pathing_results then
			data.pathing_results[my_data.flee_path_search_id] = nil
		end

		my_data.processing_flee_path = nil
		my_data.flee_path_search_id = nil
	end

	if my_data.coarse_path_search_id then
		if data.active_searches[my_data.coarse_path_search_id] then
			managers.navigation:cancel_coarse_search(my_data.coarse_path_search_id)
		elseif data.pathing_results then
			data.pathing_results[my_data.coarse_path_search_id] = nil
		end

		my_data.processing_coarse_path = nil
		my_data.coarse_path_search_id = nil
	end
end

function CopLogicFlee.damage_clbk(data, damage_info)
	CopLogicBase.damage_clbk(data, damage_info)
end

function CopLogicFlee.death_clbk(data, damage_info)
	CopLogicAttack.death_clbk(data, damage_info)
end

function CopLogicFlee.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	return false
end

function CopLogicFlee._flee_coarse_path_verify_clbk(shait, nav_seg)
	return managers.groupai:state():is_nav_seg_safe(nav_seg)
end

function CopLogicFlee.on_new_objective(data, old_objective)
	CopLogicBase.update_follow_unit(data, old_objective)
end

function CopLogicFlee.on_intimidated(data, amount, aggressor_unit)
	CopLogicBase._surrender(data, amount)
end

function CopLogicFlee._get_all_paths(data)
	return {
		flee_path = data.internal_data.flee_path
	}
end

function CopLogicFlee._set_verified_paths(data, verified_paths)
	data.internal_data.flee_path = verified_paths.flee_path
end
