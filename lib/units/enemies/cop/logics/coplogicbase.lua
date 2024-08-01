local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local mrot1 = Rotation()
CopLogicBase = class()
CopLogicBase.SAW_SOMETHING_THRESHOLD = 0.2
CopLogicBase.INVESTIGATE_THRESHOLD = 0.4
CopLogicBase._AGGRESSIVE_ALERT_TYPES = {
	vo_distress = true,
	aggression = true,
	bullet = true,
	vo_intimidate = true,
	explosion = true,
	footstep = true,
	vo_cbt = true
}
CopLogicBase._DANGEROUS_ALERT_TYPES = {
	explosion = true,
	bullet = true,
	aggression = true
}
CopLogicBase._SUSPICIOUS_SO_ANIMS = {
	rifle = {
		"e_so_suspicious_rifle_v01",
		"e_so_suspicious_rifle_v02"
	},
	pistol = {
		"e_so_suspicious_pistol_v01",
		"e_so_suspicious_pistol_v02"
	}
}
CopLogicBase._INVESTIGATE_SO_ANIMS = {
	"e_so_ntl_crouch_investigate_v01",
	"e_so_ntl_crouch_investigate_v02",
	"e_so_ntl_crouch_investigate_v03"
}

function CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	local old_internal_data = data.internal_data

	if old_internal_data then
		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end
end

function CopLogicBase.exit(data, new_logic_name, enter_params)
	local my_data = data.internal_data

	if data.internal_data then
		data.internal_data.exiting = true
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.moving_to_cover then
		managers.navigation:release_cover(my_data.moving_to_cover[1])
	end
end

function CopLogicBase.action_data(data)
	return data.action_data
end

function CopLogicBase.can_activate(data)
	return true
end

function CopLogicBase.on_intimidated(data, amount, aggressor_unit)
end

function CopLogicBase.on_tied(data, aggressor_unit)
end

function CopLogicBase.on_criminal_neutralized(data, criminal_key)
end

function CopLogicBase._set_attention_on_unit(data, attention_unit)
	local attention_data = {
		unit = attention_unit
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._set_attention(data, attention_info, reaction)
	local attention_data = {
		unit = attention_info.unit,
		u_key = attention_info.u_key,
		handler = attention_info.handler,
		reaction = reaction or attention_info.reaction
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._set_attention_on_pos(data, pos)
	local attention_data = {
		pos = pos
	}

	data.unit:movement():set_attention(attention_data)
end

function CopLogicBase._reset_attention(data)
	data.unit:movement():set_attention()
end

function CopLogicBase.is_available_for_assignment(data)
	return true
end

function CopLogicBase._nav_point_pos(nav_point)
	if nav_point.x then
		return nav_point
	end

	return nav_point:script_data().element:value("position")
end

function CopLogicBase.on_action_completed(data, action)
end

function CopLogicBase.request_action_timeout_callback(data)
	local my_data = data.internal_data
	my_data.action_timeout_clbk_id = "CopLogicBase_action_timeout" .. tostring(data.key)
	local action_timeout_t = data.objective.action_timeout_t or data.t + data.objective.action_duration
	data.objective.action_timeout_t = action_timeout_t

	CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicBase, CopLogicBase, "action_timeout_clbk", data), action_timeout_t)
end

function CopLogicBase.action_timeout_clbk(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil

	if not data.objective then
		debug_pause_unit(data.unit, "[CopLogicBase.action_timeout_clbk] missing objective")

		return
	end

	my_data.action_timed_out = true

	if data.unit:anim_data().act and data.unit:anim_data().needs_idle then
		CopLogicBase._start_idle_action_from_act(data)
	end

	data.objective_complete_clbk(data.unit, data.objective)
end

function CopLogicBase.damage_clbk(data, damage_info)
	local enemy = damage_info.attacker_unit
	local enemy_data = nil

	if enemy and enemy:in_slot(data.enemy_slotmask) then
		local my_data = data.internal_data
		local enemy_key = enemy:key()
		enemy_data = data.detected_attention_objects[enemy_key]
		local t = TimerManager:game():time()

		if enemy_data then
			enemy_data.verified_t = t
			enemy_data.verified = true

			mvector3.set(enemy_data.verified_pos, enemy:movement():m_stand_pos())

			enemy_data.verified_dis = mvector3.distance(enemy_data.verified_pos, data.unit:movement():m_stand_pos())
			enemy_data.dmg_t = t
			enemy_data.alert_t = t
			enemy_data.notice_delay = nil

			if not enemy_data.identified then
				enemy_data.identified = true
				enemy_data.identified_t = t
				enemy_data.notice_progress = nil
				enemy_data.prev_notice_chk_t = nil

				if enemy_data.settings.notice_clbk then
					enemy_data.settings.notice_clbk(data.unit, true)
				end

				data.logic.on_attention_obj_identified(data, enemy_key, enemy_data, "CopLogicBase.damage_clbk_1")
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[enemy_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

				if settings then
					enemy_data = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, enemy_key, attention_info, settings)
					enemy_data.verified_t = t
					enemy_data.verified = true
					enemy_data.dmg_t = t
					enemy_data.alert_t = t
					enemy_data.identified = true
					enemy_data.identified_t = t
					enemy_data.notice_progress = nil
					enemy_data.prev_notice_chk_t = nil

					if enemy_data.settings.notice_clbk then
						enemy_data.settings.notice_clbk(data.unit, true)
					end

					data.detected_attention_objects[enemy_key] = enemy_data

					data.logic.on_attention_obj_identified(data, enemy_key, enemy_data, "CopLogicBase.damage_clbk_2")
				end
			end
		end
	end

	if enemy_data and enemy_data.criminal_record then
		managers.groupai:state():criminal_spotted(enemy)
		managers.groupai:state():report_aggression(enemy)
	end
end

function CopLogicBase.death_clbk(data, damage_info)
end

function CopLogicBase.on_alert(data, alert_data)
	if not managers.player:local_player() then
		return
	end

	local nav_seg = data.unit:movement():nav_tracker():nav_segment()
	local world_id = managers.navigation:get_world_for_nav_seg(nav_seg)
	local worlds = managers.groupai:state():get_last_world_ids_for_criminals()
	local alarm = managers.worldcollection:get_alarm_for_world(world_id)
	local found = false

	for _, player_world_id in ipairs(worlds) do
		if world_id == player_world_id then
			found = true

			break
		end
	end

	if not found and not alarm then
		return
	end

	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	local was_cool = data.cool

	if CopLogicBase.is_alert_aggressive(alert_type) then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
	end

	if alert_unit and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if not att_obj_data then
			return
		end

		if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
			att_obj_data.alert_t = TimerManager:game():time()
		end

		local action_data = nil

		if is_new and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and AIAttentionObject.REACT_SURPRISED <= att_obj_data.reaction and data.unit:anim_data().idle and not data.unit:movement():chk_action_forbidden("walk") then
			action_data = {
				variant = "surprised",
				body_part = 1,
				type = "act"
			}

			data.unit:brain():action_request(action_data)
		end

		if not action_data and alert_type == "bullet" and data.logic.should_duck_on_alert(data, alert_data) then
			action_data = CopLogicAttack._request_action_crouch(data)
		end

		if att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(alert_unit)

			if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
				managers.groupai:state():report_aggression(alert_unit)
			end
		end
	elseif was_cool and (alert_type == "footstep" or alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" or alert_type == "vo_cbt" or alert_type == "vo_intimidate" or alert_type == "vo_distress") then
		local attention_obj = alert_unit and alert_unit:brain() and alert_unit:brain()._logic_data.attention_obj

		if attention_obj then
			local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
		end
	end
end

function CopLogicBase.on_area_safety(data, nav_seg, safe)
end

function CopLogicBase.draw_reserved_positions(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data
	local rsrv_pos = data.pos_rsrv

	if rsrv_pos.path then
		Application:draw_cylinder(rsrv_pos.path.position, my_pos, 6, 0, 0.3, 0.3)
	end

	if rsrv_pos.move_dest then
		Application:draw_cylinder(rsrv_pos.move_dest.position, my_pos, 6, 0.3, 0.3, 0)
	end

	if rsrv_pos.stand then
		Application:draw_cylinder(rsrv_pos.stand.position, my_pos, 6, 0.3, 0, 0.3)
	end

	return

	if my_data.best_cover then
		local cover_pos = my_data.best_cover[1][NavigationManager.COVER_RESERVATION].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.3, 0.6)
		Application:draw_sphere(cover_pos, 10, 0.2, 0.3, 0.6)
	end

	if my_data.nearest_cover then
		local cover_pos = my_data.nearest_cover[1][NavigationManager.COVER_RESERVATION].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.6, 0.3)
		Application:draw_sphere(cover_pos, 8, 0.2, 0.6, 0.3)
	end

	if my_data.moving_to_cover then
		local cover_pos = my_data.moving_to_cover[1][NavigationManager.COVER_RESERVATION].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.3, 0.6, 0.2)
		Application:draw_sphere(cover_pos, 8, 0.3, 0.6, 0.2)
	end
end

function CopLogicBase.draw_reserved_covers(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data

	if my_data.best_cover then
		local cover_pos = my_data.best_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.3, 0.6)
		Application:draw_sphere(cover_pos, 10, 0.2, 0.3, 0.6)
	end

	if my_data.nearest_cover then
		local cover_pos = my_data.nearest_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.6, 0.3)
		Application:draw_sphere(cover_pos, 8, 0.2, 0.6, 0.3)
	end

	if my_data.moving_to_cover then
		local cover_pos = my_data.moving_to_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.3, 0.6, 0.2)
		Application:draw_sphere(cover_pos, 8, 0.3, 0.6, 0.2)
	end
end

function CopLogicBase.release_reserved_covers(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data

	if my_data.best_cover then
		local cover_pos = my_data.best_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.3, 0.6)
		Application:draw_sphere(cover_pos, 10, 0.2, 0.3, 0.6)
	end

	if my_data.nearest_cover then
		local cover_pos = my_data.nearest_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.2, 0.6, 0.3)
		Application:draw_sphere(cover_pos, 8, 0.2, 0.6, 0.3)
	end

	if my_data.moving_to_cover then
		local cover_pos = my_data.moving_to_cover[1][5].pos

		Application:draw_cylinder(cover_pos, my_pos, 2, 0.3, 0.6, 0.2)
		Application:draw_sphere(cover_pos, 8, 0.3, 0.6, 0.2)
	end
end

function CopLogicBase._exit_to_state(unit, state_name, params)
	if unit:brain().logic_queued_key then
		managers.queued_tasks:unqueue(unit:brain().logic_queued_key)

		unit:brain().logic_queued_key = nil
	end

	if state_name == "travel" and not unit:brain().random_travel_applied then
		unit:brain().random_travel_applied = true
		unit:brain().logic_queued_key = "travel" .. tostring(unit:key())

		managers.queued_tasks:queue(unit:brain().logic_queued_key, unit:brain().set_logic_queued, unit:brain(), {
			state_name = state_name,
			params = params
		}, math.random() * 0.7, nil)
	elseif params and params.delay then
		unit:brain().logic_queued_key = "logic_queue" .. tostring(unit:key())

		managers.queued_tasks:queue(unit:brain().logic_queued_key, unit:brain().set_logic_queued, unit:brain(), {
			state_name = state_name,
			params = params
		}, params.delay, nil)
	else
		unit:brain():set_logic(state_name, params)
	end
end

function CopLogicBase.on_detected_enemy_destroyed(data, enemy_unit)
end

function CopLogicBase._can_move(data)
	return true
end

function CopLogicBase._report_detections(enemies)
	local group = managers.groupai:state()

	for key, data in pairs(enemies) do
		if data.verified and data.criminal_record then
			group:criminal_spotted(data.unit)
		end
	end
end

function CopLogicBase.on_importance(data)
end

function CopLogicBase.queue_task(internal_data, id, func, data, exec_t, asap)
	if internal_data.unit and internal_data ~= internal_data.unit:brain()._logic_data.internal_data then
		debug_pause("[CopLogicBase.queue_task] Task queued from the wrong logic", internal_data.unit, id, func, data, exec_t, asap)
	end

	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		if qd_tasks[id] then
			debug_pause("[CopLogicBase.queue_task] Task queued twice", internal_data.unit, id, func, data, exec_t, asap)
		end

		qd_tasks[id] = true
	else
		internal_data.queued_tasks = {
			[id] = true
		}
	end

	managers.enemy:queue_task(id, func, data, exec_t, callback(CopLogicBase, CopLogicBase, "on_queued_task", internal_data), asap)
end

function CopLogicBase.cancel_queued_tasks(internal_data)
	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		local e_manager = managers.enemy

		for id, _ in pairs(qd_tasks) do
			e_manager:unqueue_task(id)
		end

		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.unqueue_task(internal_data, id)
	managers.enemy:unqueue_task(id)

	internal_data.queued_tasks[id] = nil

	if not next(internal_data.queued_tasks) then
		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.chk_unqueue_task(internal_data, id)
	if internal_data.queued_tasks and internal_data.queued_tasks[id] then
		managers.enemy:unqueue_task(id)

		internal_data.queued_tasks[id] = nil

		if not next(internal_data.queued_tasks) then
			internal_data.queued_tasks = nil
		end
	end
end

function CopLogicBase.on_queued_task(ignore_this, internal_data, id)
	if not internal_data.queued_tasks or not internal_data.queued_tasks[id] then
		debug_pause("[CopLogicBase.on_queued_task] the task is not queued", internal_data.unit, id)

		return
	end

	internal_data.queued_tasks[id] = nil

	if not next(internal_data.queued_tasks) then
		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.add_delayed_clbk(internal_data, id, clbk, exec_t)
	if internal_data.unit and internal_data ~= internal_data.unit:brain()._logic_data.internal_data then
		debug_pause("[CopLogicBase.add_delayed_clbk] Clbk added from the wrong logic", internal_data.unit, id, clbk, exec_t)
	end

	local clbks = internal_data.delayed_clbks

	if clbks then
		if clbks[id] then
			debug_pause("[CopLogicBase.queue_task] Callback added twice", internal_data.unit, id, clbk, exec_t)
		end

		clbks[id] = true
	else
		internal_data.delayed_clbks = {
			[id] = true
		}
	end

	managers.enemy:add_delayed_clbk(id, clbk, exec_t)
end

function CopLogicBase.cancel_delayed_clbks(internal_data)
	local clbks = internal_data.delayed_clbks

	if clbks then
		local e_manager = managers.enemy

		for id, _ in pairs(clbks) do
			e_manager:remove_delayed_clbk(id)
		end

		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.cancel_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		debug_pause("[CopLogicBase.cancel_delayed_clbk] Tried to cancel inexistent clbk", internal_data.unit, id, internal_data.delayed_clbks and inspect(internal_data.delayed_clbks))

		return
	end

	managers.enemy:remove_delayed_clbk(id)

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.chk_cancel_delayed_clbk(internal_data, id)
	if internal_data.delayed_clbks and internal_data.delayed_clbks[id] then
		managers.enemy:remove_delayed_clbk(id)

		internal_data.delayed_clbks[id] = nil

		if not next(internal_data.delayed_clbks) then
			internal_data.delayed_clbks = nil
		end
	end
end

function CopLogicBase.on_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		debug_pause("[CopLogicBase.on_delayed_clbk] Callback not added", internal_data.unit, id, internal_data.delayed_clbks and inspect(internal_data.delayed_clbks))

		return
	end

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.on_objective_unit_damaged(data, unit, attacker_unit)
end

function CopLogicBase.on_objective_unit_destroyed(data, unit)
	if not alive(data.unit) then
		debug_pause("dead unit did not remove destroy listener", data.debug_name, inspect(data.objective), data.name)

		return
	end

	data.objective.destroy_clbk_key = nil
	data.objective.death_clbk_key = nil

	data.objective_failed_clbk(data.unit, data.objective)
end

function CopLogicBase.update_follow_unit(data, old_objective)
	if old_objective and old_objective.follow_unit then
		if old_objective.destroy_clbk_key then
			old_objective.follow_unit:base():remove_destroy_listener(old_objective.destroy_clbk_key)

			old_objective.destroy_clbk_key = nil
		end

		if old_objective.death_clbk_key then
			old_objective.follow_unit:character_damage():remove_listener(old_objective.death_clbk_key)

			old_objective.death_clbk_key = nil
		end
	end

	local new_objective = data.objective

	if new_objective and new_objective.follow_unit and not new_objective.destroy_clbk_key then
		local ext_brain = data.unit:brain()
		local destroy_clbk_key = "objective_" .. new_objective.type .. tostring(data.unit:key())
		new_objective.destroy_clbk_key = destroy_clbk_key

		new_objective.follow_unit:base():add_destroy_listener(destroy_clbk_key, callback(ext_brain, ext_brain, "on_objective_unit_destroyed"))

		if new_objective.follow_unit:character_damage() then
			new_objective.death_clbk_key = destroy_clbk_key

			new_objective.follow_unit:character_damage():add_listener(destroy_clbk_key, {
				"death",
				"hurt"
			}, callback(ext_brain, ext_brain, "on_objective_unit_damaged"))
		end
	end
end

function CopLogicBase.on_new_objective(data, old_objective)
	local new_objective = data.objective

	CopLogicBase.update_follow_unit(data, old_objective)

	local my_data = data.internal_data

	if new_objective then
		local objective_type = new_objective.type

		if CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			CopLogicBase._exit_to_state(data.unit, "travel")
		elseif objective_type == "guard" then
			CopLogicBase._exit_to_state(data.unit, "guard")
		elseif objective_type == "security" then
			CopLogicBase._exit_to_state(data.unit, "idle")
		elseif objective_type == "sniper" then
			CopLogicBase._exit_to_state(data.unit, "sniper")
		elseif objective_type == "spotter" then
			CopLogicBase._exit_to_state(data.unit, "spotter")
		elseif objective_type == "phalanx" then
			CopLogicBase._exit_to_state(data.unit, "phalanx")
		elseif objective_type == "surrender" then
			CopLogicBase._exit_to_state(data.unit, "intimidated", new_objective.params)
		elseif objective_type == "free" and my_data.exiting then
			-- Nothing
		elseif new_objective.action or not data.attention_obj or AIAttentionObject.REACT_AIM > data.attention_obj.reaction then
			CopLogicBase._exit_to_state(data.unit, "idle")
		else
			CopLogicBase._exit_to_state(data.unit, "attack")
		end
	elseif not my_data.exiting then
		CopLogicBase._exit_to_state(data.unit, "idle")

		return
	end

	if new_objective and new_objective.stance then
		if new_objective.stance == "ntl" then
			data.unit:movement():set_cool(true)
		else
			data.unit:movement():set_cool(false)
		end
	end

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end

function CopLogicBase.is_advancing(data)
end

function CopLogicBase.anim_clbk(...)
end

function CopLogicBase._angle_chk(handler, settings, data, my_pos, strictness)
	local attention_pos = handler:get_detection_m_pos()
	local dis = mvector3.direction(tmp_vec1, my_pos, attention_pos)
	local my_data = data.internal_data
	local my_head_rot = data.unit:movement():m_head_rot()

	mrotation.set_look_at(mrot1, tmp_vec1, math.UP)

	local angle = math.abs(180 - math.abs(mrot1:yaw() - my_head_rot:yaw()))
	local angle_max = my_data.vision.cone_3.angle

	if angle_max > angle * strictness then
		return true
	end
end

function CopLogicBase._angle_and_dis_chk(handler, settings, data, my_pos)
	local attention_pos = handler:get_detection_m_pos()
	local dis = mvector3.direction(tmp_vec1, my_pos, attention_pos)
	local my_data = data.internal_data
	local my_head_rot = data.unit:movement():m_head_rot()

	if not my_data.vision then
		Application:error("CopLogicBase._angle_and_dis_chk: Unit missing vision property. ", inspect(my_data.unit))

		return
	end

	if settings.notice_requires_FOV and my_data.vision.cone_1.distance < dis / 3 and my_data.vision.cone_2.distance < dis / 3 and my_data.vision.cone_3.distance < dis / 3 then
		return
	end

	mrotation.set_look_at(mrot1, tmp_vec1, math.UP)

	local angle = math.abs(180 - math.abs(mrot1:yaw() - my_head_rot:yaw()))
	local angle_z = mvector3.angle(my_head_rot:y(), tmp_vec1)
	local angle_max = my_data.vision.cone_3.angle
	local angle_multiplier = angle / angle_max
	local retval = {}
	local range_mul = settings.range_mul or 1
	local dis_max, speed_mul = nil

	if angle <= my_data.vision.cone_1.angle / 2 and dis < my_data.vision.cone_1.distance * range_mul then
		speed_mul = my_data.vision.cone_1.speed_mul
		dis_max = my_data.vision.cone_1.distance * range_mul
	elseif angle <= my_data.vision.cone_2.angle / 2 and dis < my_data.vision.cone_2.distance * range_mul then
		speed_mul = my_data.vision.cone_2.speed_mul
		dis_max = my_data.vision.cone_2.distance * range_mul
	elseif angle <= my_data.vision.cone_3.angle / 2 and dis < my_data.vision.cone_3.distance * range_mul then
		speed_mul = my_data.vision.cone_3.speed_mul
		dis_max = my_data.vision.cone_3.distance * range_mul
	else
		speed_mul = 100
		dis_max = 1
	end

	local dis_multiplier = dis / dis_max

	if my_data.detection.use_uncover_range and settings.uncover_range and dis < settings.uncover_range and (not settings.uncover_requires_FOV or settings.uncover_requires_FOV and angle_multiplier < 1) then
		return -1, 0, 0
	end

	if dis_multiplier < 1 then
		if settings.notice_requires_FOV then
			if angle_multiplier < 1 then
				retval = {
					angle,
					dis_multiplier,
					speed_mul
				}
			end
		else
			retval = {
				0,
				dis_multiplier,
				speed_mul
			}
		end
	end

	return unpack(retval)
end

function CopLogicBase._nearly_visible_chk(data, attention_info, my_pos, detect_pos)
	local near_pos = tmp_vec1

	if attention_info.verified_dis < 2000 and math.abs(detect_pos.z - my_pos.z) < 300 then
		mvec3_set(near_pos, detect_pos)
		mvec3_set_z(near_pos, near_pos.z + 100)

		local near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

		if near_vis_ray then
			local side_vec = tmp_vec1

			mvec3_set(side_vec, detect_pos)
			mvec3_sub(side_vec, my_pos)
			mvector3.cross(side_vec, side_vec, math.UP)
			mvector3.set_length(side_vec, 150)
			mvector3.set(near_pos, detect_pos)
			mvector3.add(near_pos, side_vec)

			local near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

			if near_vis_ray then
				mvector3.multiply(side_vec, -2)
				mvector3.add(near_pos, side_vec)

				near_vis_ray = World:raycast("ray", my_pos, near_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")
			end
		end

		if not near_vis_ray then
			attention_info.nearly_visible = true
			attention_info.last_verified_pos = mvector3.copy(near_pos)
		end
	end
end

function CopLogicBase._chk_record_acquired_attention_importance_wgt(attention_info, player_importance_wgt, my_pos)
	if not player_importance_wgt or not attention_info.is_human_player then
		return
	end

	local weight = mvector3.direction(tmp_vec1, attention_info.m_head_pos, my_pos)
	local e_fwd = nil

	if attention_info.is_husk_player then
		e_fwd = attention_info.unit:movement():detect_look_dir()
	else
		e_fwd = attention_info.unit:movement():m_head_rot():y()
	end

	local dot = mvector3.dot(e_fwd, tmp_vec1)
	weight = weight * weight * (1 - dot)

	table.insert(player_importance_wgt, attention_info.u_key)
	table.insert(player_importance_wgt, weight)
end

function CopLogicBase._chk_record_attention_obj_importance_wgt(u_key, attention_info, player_importance_wgt, my_pos)
	if not player_importance_wgt then
		return
	end

	local is_human_player, is_local_player, is_husk_player = nil

	if attention_info.unit:base() then
		is_local_player = attention_info.unit:base().is_local_player
		is_husk_player = not is_local_player and attention_info.unit:base().is_husk_player
		is_human_player = is_local_player or is_husk_player
	end

	if not is_human_player then
		return
	end

	local weight = mvector3.direction(tmp_vec1, attention_info.handler:get_detection_m_pos(), my_pos)
	local e_fwd = nil

	if is_husk_player then
		e_fwd = attention_info.unit:movement():detect_look_dir()
	else
		e_fwd = attention_info.unit:movement():m_head_rot():y()
	end

	local dot = mvector3.dot(e_fwd, tmp_vec1)
	weight = weight * weight * (1 - dot)

	table.insert(player_importance_wgt, u_key)
	table.insert(player_importance_wgt, weight)
end

function CopLogicBase._upd_attention_obj_detection(data, min_reaction, max_reaction)
	local t = data.t
	local detected_obj = data.detected_attention_objects
	local my_data = data.internal_data
	local my_key = data.key
	local my_pos = data.unit:movement():m_head_pos()
	local my_access = data.SO_access
	local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str, data.team)
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local is_detection_persistent = managers.groupai:state():is_detection_persistent()
	local delay = 1
	local player_importance_wgt = data.unit:in_slot(managers.slot:get_mask("enemies")) and {}

	for u_key, attention_info in pairs(all_attention_objects) do
		if u_key ~= my_key and not detected_obj[u_key] and not Global.blind_enemies and (not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker)) then
			local settings = attention_info.handler:get_attention(my_access, min_reaction, max_reaction, data.team)

			if settings then
				local acquired = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local angle, distance = CopLogicBase._angle_and_dis_chk(attention_info.handler, settings, data, my_pos)

				if angle then
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						acquired = true
						detected_obj[u_key] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, settings)
					end
				end

				if not acquired then
					CopLogicBase._chk_record_attention_obj_importance_wgt(u_key, attention_info, player_importance_wgt, my_pos)
				end
			end
		end
	end

	for u_key, attention_info in pairs(detected_obj) do
		if t < attention_info.next_verify_t then
			if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.reaction then
				delay = math.min(attention_info.next_verify_t - t, delay)
			end
		else
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval or attention_info.settings.notice_interval or attention_info.settings.verification_interval)
			delay = math.min(delay, attention_info.settings.verification_interval)

			if not attention_info.identified then
				local noticable = nil
				local angle, dis_multiplier, speed_mul = CopLogicBase._angle_and_dis_chk(attention_info.handler, attention_info.settings, data, my_pos)
				local notice_is_cool = attention_info.settings.notice_requires_cool and data.cool or attention_info.settings.notice_requires_cool == nil

				if angle and notice_is_cool then
					local vis_ray = CopLogicBase._detection_ray(my_pos, attention_info.handler:get_detection_m_pos(), data.visibility_slotmask)

					if not vis_ray or vis_ray.unit:key() == u_key then
						noticable = true
					end
				end

				local dt = t - attention_info.prev_notice_chk_t
				local delta_prog = dt * -0.125
				local peer_id, local_peer = nil

				if managers.network:session() ~= nil then
					peer_id = managers.network:session():peer_id_by_unit(attention_info.unit)
					local_peer = peer_id == managers.network:session():local_peer()._id
				end

				if noticable then
					if angle == -1 then
						if local_peer then
							delta_prog = managers.player:upgrade_value("player", "pickpocket_uncover_detection", 1)
						elseif peer_id then
							delta_prog = attention_info.unit:base():upgrade_value("player", "pickpocket_uncover_detection") or 1
						else
							delta_prog = 1
						end
					else
						local notice_delay_mul = attention_info.settings.notice_delay_mul or 1
						delta_prog = dt / speed_mul * notice_delay_mul

						if peer_id then
							local slower_detection_multiplier = 0
							slower_detection_multiplier = (not local_peer or managers.player:upgrade_value("player", "sprinter_running_detection_multiplier", 1)) and (attention_info.unit:base():upgrade_value("player", "sprinter_running_detection_multiplier") or 1)
							delta_prog = delta_prog * slower_detection_multiplier
						end
					end
				end

				if not attention_info.notice_progress then
					attention_info.notice_progress_wanted = 0
				end

				attention_info.notice_progress_wanted = attention_info.notice_progress_wanted or 0
				attention_info.notice_progress = attention_info.notice_progress_wanted
				attention_info.notice_progress_wanted = attention_info.notice_progress_wanted + delta_prog

				if my_data.detection.search_for_player and attention_info.is_human_player and not attention_info.identified and not managers.groupai:state():enemy_weapons_hot() then
					if CopLogicBase.INVESTIGATE_THRESHOLD < attention_info.notice_progress then
						if not data.unit:brain()._SO_id then
							CopLogicBase.register_stop_and_look_SO(data, attention_info)
							CopLogicBase._upd_look_for_player(data, attention_info)
							CopLogicBase._upd_aim_at_player(data, my_data)
							managers.hud:set_suspicion_indicator_state(data.unit:unit_data().suspicion_icon_id, "investigating")
						end
					elseif attention_info.notice_progress <= CopLogicBase.INVESTIGATE_THRESHOLD and CopLogicBase.SAW_SOMETHING_THRESHOLD < attention_info.notice_progress and not attention_info.noticed_over_threshold and not attention_info.flagged_search then
						attention_info.noticed_over_threshold = true

						CopLogicBase._set_attention_obj(data, nil)
						managers.voice_over:guard_saw_something_ut(data.unit)
						managers.hud:set_suspicion_indicator_state(data.unit:unit_data().suspicion_icon_id, "saw_something")
					elseif attention_info.notice_progress <= CopLogicBase.SAW_SOMETHING_THRESHOLD and not attention_info.noticed_under_threshold and not attention_info.noticed_over_threshold and not attention_info.flagged_search then
						attention_info.noticed_under_threshold = true
						attention_info.nearly_visible = false

						CopLogicBase._set_attention_obj(data, nil)
						managers.hud:set_suspicion_indicator_state(data.unit:unit_data().suspicion_icon_id, "heard_something")
					end
				end

				if attention_info.notice_progress > 1 then
					attention_info.notice_progress = nil
					attention_info.notice_progress_wanted = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true

					data.logic.on_attention_obj_identified(data, u_key, attention_info, "CopLogicBase._upd_attention_obj_detection")
					managers.hud:set_suspicion_indicator_state(data.unit:unit_data().suspicion_icon_id, "alarmed")
				elseif attention_info.notice_progress < 0 and not attention_info.flagged_search then
					noticable = false

					CopLogicBase._detection_obj_lost(data, attention_info)
				else
					noticable = attention_info.notice_progress_wanted
					attention_info.prev_notice_chk_t = t

					if data.cool and AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, noticable)
					end
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(data.unit, noticable)
				end
			end

			if attention_info.identified then
				delay = math.min(delay, attention_info.settings.verification_interval)
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(data.m_pos, attention_info.m_pos)

				if my_data.detection and my_data.detection.dis_max and dis < my_data.detection.dis_max * 1.2 and (not attention_info.settings.max_range or dis < attention_info.settings.max_range * (attention_info.settings.range_mul or 1) * 1.2) then
					local in_FOV = not attention_info.settings.notice_requires_FOV or data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) or CopLogicBase._angle_chk(attention_info.handler, attention_info.settings, data, my_pos, 0.8)

					if in_FOV then
						vis_ray = CopLogicBase._detection_ray(my_pos, attention_info.handler:get_detection_m_pos(), data.visibility_slotmask)

						if not vis_ray or vis_ray.unit:key() == u_key then
							verified = true
						end
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis
				attention_info.vis_ray = vis_ray and vis_ray.dis or nil

				if verified then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) then
					if attention_info.criminal_record and AIAttentionObject.REACT_COMBAT <= attention_info.settings.reaction then
						if not is_detection_persistent and mvector3.distance(attention_pos, attention_info.criminal_record.pos) > 1400 then
							CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
						else
							delay = math.min(0.2, delay)
							attention_info.verified_pos = mvector3.copy(attention_info.criminal_record.pos)
							attention_info.verified_dis = dis

							if vis_ray and data.logic._chk_nearly_visible_chk_needed(data, attention_info, u_key) then
								CopLogicBase._nearly_visible_chk(data, attention_info, my_pos, attention_pos)
							end
						end
					elseif attention_info.release_t and attention_info.release_t < t then
						CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
					else
						attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
					end
				elseif attention_info.release_t and attention_info.release_t < t then
					CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end

		CopLogicBase._chk_record_acquired_attention_importance_wgt(attention_info, player_importance_wgt, my_pos)
	end

	if player_importance_wgt then
		managers.groupai:state():set_importance_weight(data.key, player_importance_wgt)
	end

	return delay
end

function CopLogicBase._detection_ray(from, to, slot)
	local vis_ray = nil
	local dis = mvector3.distance(to, from)
	local dis_limit = 200
	local raycast_radius = 1

	if dis_limit < dis then
		raycast_radius = math.clamp(dis / dis_limit * 2, 1, 10)
		vis_ray = World:raycast("ray", from, to, "slot_mask", slot, "sphere_cast_radius", raycast_radius, "ray_type", "ai_vision")
	else
		vis_ray = World:raycast("ray", from, to, "slot_mask", slot, "ray_type", "ai_vision")
	end

	return vis_ray
end

function CopLogicBase._detection_obj_lost(data, attention_info)
	CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
	CopLogicBase._set_attention_obj(data, nil)

	if attention_info.flagged_looking and not managers.groupai:state():enemy_weapons_hot() and not attention_info.identified then
		data.unit:movement():set_stance("ntl", false, false)

		data.unit:brain()._flagged_looking = false
	end

	if attention_info.flagged_search then
		data.unit:brain()._SO_id = nil
	end

	attention_info.noticed_under_threshold = false
	attention_info.noticed_over_threshold = false
	attention_info.flagged_looking = false
	attention_info.flagged_search = false
	attention_info.nearly_visible = false

	if data._queued_objective and not managers.groupai:state():enemy_weapons_hot() then
		local stop_current_action = {
			action_duration = 1,
			type = "act",
			stance = "ntl",
			followup_objective = data._queued_objective,
			action = {
				body_part = 1,
				type = "idle"
			}
		}

		data.unit:brain():set_objective(stop_current_action)
	end
end

function CopLogicBase.on_search_SO_failed(cop, params)
	managers.groupai:state():hide_investigate_icon(cop)
end

function CopLogicBase.on_search_SO_completed(cop, params)
	managers.voice_over:guard_back_to_patrol(cop)

	if params.attention_info then
		CopLogicBase._detection_obj_lost(cop:brain()._logic_data, params.attention_info)

		params.attention_info.flagged_search = false
	end

	managers.groupai:state():hide_investigate_icon(cop)

	cop:brain()._SO_id = nil
end

function CopLogicBase.on_search_SO_started(cop, params)
	managers.voice_over:guard_investigate(cop)
	managers.groupai:state():show_investigate_icon(cop)

	if params.custom_stance then
		cop:movement():set_stance(params.custom_stance, false, false)
	end
end

function CopLogicBase._upd_look_for_player(data, attention_info)
	if not data.attention_obj or data.attention_obj.u_key ~= attention_info.u_key then
		CopLogicBase._set_attention_obj(data, attention_info)

		attention_info.nearly_visible = true
	end

	if data.unit:movement():stance_name() ~= "cbt" and not data.unit:brain()._switch_to_cbt_called then
		Application:debug("[CopLogicBase._upd_look_for_player] Switch to cbt and equip weapon", data.unit)

		data.unit:brain()._switch_to_cbt_called = true

		managers.queued_tasks:queue(nil, data.unit:brain()._switch_to_cbt, data.unit:brain(), nil, 1.5, nil)
	end
end

function CopLogicBase._create_return_from_search_SO(cop, old_objective)
	local pos = mvector3.copy(cop:movement():m_pos())
	local nav_seg = managers.navigation:get_nav_seg_from_pos(pos)
	local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
	local rot = Rotation()

	mrotation.set_zero(rot)
	mrotation.multiply(rot, cop:movement():m_rot())

	local objective = {
		type = "free",
		stance = "ntl",
		haste = "walk",
		scan = true,
		interrupt_dis = -1,
		attitude = "engage",
		path_style = "coarse_complete",
		followup_objective = old_objective,
		pos = pos,
		rot = rot,
		nav_seg = nav_seg,
		area = area
	}

	return objective
end

function CopLogicBase.register_search_SO(cop, attention_info, position)
	Application:debug("CopLogicBase.register_search_SO", attention_info, position)

	if not cop:brain():stealth_action_allowed() or not managers.navigation:is_data_ready() then
		return
	end

	local pos = nil

	if attention_info then
		attention_info.flagged_search = true
		pos = mvector3.copy(attention_info.m_pos)
	else
		pos = position
	end

	local filter = managers.navigation:convert_SO_AI_group_to_access("enemies")
	local nav_seg = managers.navigation:get_nav_seg_from_pos(pos)
	local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
	local old_objective = cop:brain():objective()

	if not old_objective then
		old_objective = CopLogicBase._create_return_from_search_SO(cop)
	elseif not old_objective.pos then
		old_objective = CopLogicBase._create_return_from_search_SO(cop, old_objective)
	end

	local go_to_search_pos = {
		stance = "ntl",
		type = "free",
		action_duration = 5,
		haste = "walk",
		scan = true,
		interrupt_dis = -1,
		attitude = "engage",
		pos = pos,
		nav_seg = nav_seg,
		area = area,
		followup_objective = old_objective,
		complete_clbk = callback(cop, CopLogicBase, "on_search_SO_completed", {
			attention_info = attention_info,
			position = pos
		})
	}
	local so_investigate = {
		type = "act",
		stance = "ntl",
		haste = "walk",
		interrupt_dis = -1,
		attitude = "engage",
		pos = pos,
		nav_seg = nav_seg,
		area = area,
		followup_objective = old_objective,
		complete_clbk = callback(cop, CopLogicBase, "on_search_SO_completed", {
			attention_info = attention_info,
			position = pos
		}),
		fail_clbk = callback(cop, CopLogicBase, "on_search_SO_failed", {
			attention_info = attention_info,
			position = pos
		}),
		action = {
			align_sync = true,
			needs_full_blend = true,
			type = "act",
			body_part = 1,
			variant = table.random(CopLogicBase._INVESTIGATE_SO_ANIMS),
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				aim = -1,
				walk = -1
			}
		}
	}
	local stop_current_action = {
		action_duration = 1,
		type = "act",
		stance = "ntl",
		followup_objective = so_investigate,
		complete_clbk = callback(cop, CopLogicBase, "on_search_SO_started", {
			attention_info = attention_info
		}),
		action = {
			body_part = 1,
			type = "idle"
		}
	}
	local so_id = "search" .. tostring(cop:key())
	cop:brain()._SO_id = so_id

	cop:brain():set_objective(stop_current_action)

	return true
end

function CopLogicBase.register_stop_and_look_SO(data, attention_info)
	local cop = data.unit

	if not cop:brain():stealth_action_allowed() or attention_info.flagged_looking then
		return
	end

	Application:debug("CopLogicBase.register_stop_and_look_SO", cop)
	managers.voice_over:guard_saw_something_ot(cop)

	local old_objective = cop:brain():objective()

	if old_objective and old_objective.pos then
		local stop_current_action = {
			action_duration = 1,
			stance = "ntl",
			type = "act",
			action = {
				body_part = 1,
				type = "idle"
			}
		}

		cop:brain():set_objective(stop_current_action)

		data._queued_objective = old_objective
	end

	cop:brain()._flagged_looking = true
	attention_info.flagged_looking = true

	managers.groupai:state():show_aiming_icon(cop)
end

function CopLogicBase.register_alert_SO(data)
	if not data.unit:unit_data().mission_element then
		return
	end

	local sync_id = data.unit:unit_data().mission_element._sync_id
	local mission = sync_id ~= 0 and managers.worldcollection:mission_by_id(sync_id) or managers.mission
	local alert_point = mission:find_alert_point(data.unit:position())

	if alert_point then
		alert_point:add_event_callback("complete", callback(data.unit, CopLogicBase, "on_alert_completed", {
			data = data,
			alert_point = alert_point
		}), tostring(data.unit:key()))
		alert_point:add_event_callback("fail", callback(data.unit, CopLogicBase, "on_alert_failed", {
			data = data,
			alert_point = alert_point
		}), tostring(data.unit:key()))
		alert_point:add_event_callback("administered", callback(data.unit, CopLogicBase, "on_alert_administered", {
			data = data,
			alert_point = alert_point
		}), tostring(data.unit:key()))
		alert_point:add_event_callback("anim_start", callback(data.unit, CopLogicBase, "on_alert_anim_start", {
			data = data,
			alert_point = alert_point
		}), tostring(data.unit:key()))

		alert_point.executing = true
		data.internal_data.is_on_alert_SO = true

		alert_point:on_executed(data.unit)
	end
end

function CopLogicBase.on_alert_administered(cop, params)
	if alive(cop) and Network:is_server() then
		local is_dead = cop:character_damage():dead()

		if not is_dead then
			managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "calling")
		else
			params.alert_point:remove_event_callback(tostring(cop:key()))

			params.alert_point.executing = false
			params.data.internal_data.is_on_alert_SO = false
		end
	end
end

function CopLogicBase.on_alert_anim_start(cop, params)
	if alive(cop) and Network:is_server() then
		local is_dead = cop:character_damage():dead()

		if not is_dead then
			cop:sound():say("phone_ringing", true, false)
		end
	end
end

function CopLogicBase.on_alert_completed(cop, params)
	params.alert_point.executing = false
	params.data.internal_data.is_on_alert_SO = false

	params.alert_point:remove_event_callback(tostring(cop:key()))

	if Network:is_server() then
		if not alive(cop) then
			managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "call_interrupted")

			return
		end

		local is_dead = cop:character_damage():dead()

		if is_dead then
			managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "call_interrupted")

			return
		end

		if not managers.groupai:state():is_ecm_jammer_active("call") then
			local group_state = managers.groupai:state()
			local cop_type = tostring(group_state.blame_triggers[cop:movement()._ext_base._tweak_table])

			managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "called")
			group_state:on_police_called(cop:movement():coolness_giveaway())
			managers.voice_over:disable()
		else
			managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "call_interrupted")
		end
	end
end

function CopLogicBase.on_alert_failed(cop, params)
	params.alert_point.executing = false
	params.data.internal_data.is_on_alert_SO = false

	params.alert_point:remove_event_callback(tostring(cop:key()))

	if Network:is_server() then
		managers.groupai:state():on_criminal_suspicion_progress(nil, cop, "call_interrupted")
	end
end

function CopLogicBase._create_detected_attention_object_data(time, my_unit, u_key, attention_info, settings)
	local ext_brain = my_unit:brain()

	attention_info.handler:add_listener("detect_" .. tostring(my_unit:key()), callback(ext_brain, ext_brain, "on_detected_attention_obj_modified"))

	local att_unit = attention_info.unit
	local m_pos = attention_info.handler:get_ground_m_pos()
	local m_head_pos = attention_info.handler:get_detection_m_pos()
	local is_local_player, is_husk_player, is_deployable, is_person, is_very_dangerous, nav_tracker, char_tweak = nil

	if att_unit:base() then
		is_local_player = att_unit:base().is_local_player
		is_husk_player = att_unit:base().is_husk_player
		is_deployable = att_unit:base().sentry_gun
		is_person = att_unit:in_slot(managers.slot:get_mask("persons"))

		if att_unit:base().char_tweak then
			char_tweak = att_unit:base():char_tweak()
		end

		is_very_dangerous = att_unit:base()._tweak_table == "taser"
	end

	local dis = mvector3.distance(my_unit:movement():m_head_pos(), m_head_pos)
	local new_entry = {
		verified = false,
		verified_t = false,
		notice_progress = 0,
		settings = settings,
		unit = attention_info.unit,
		u_key = u_key,
		handler = attention_info.handler,
		next_verify_t = time + (settings.notice_interval or settings.verification_interval),
		prev_notice_chk_t = time,
		m_pos = m_pos,
		m_head_pos = m_head_pos,
		nav_tracker = attention_info.nav_tracker,
		is_local_player = is_local_player,
		is_husk_player = is_husk_player,
		is_human_player = is_local_player or is_husk_player,
		is_deployable = is_deployable,
		is_person = is_person,
		is_very_dangerous = is_very_dangerous,
		reaction = settings.reaction,
		criminal_record = managers.groupai:state():criminal_record(u_key),
		char_tweak = char_tweak,
		detected_pos = mvector3.copy(m_pos),
		verified_pos = mvector3.copy(m_head_pos),
		verified_dis = dis,
		dis = dis,
		has_team = att_unit:movement() and att_unit:movement().team
	}

	return new_entry
end

function CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
	attention_info.handler:remove_listener("detect_" .. tostring(data.key))

	if attention_info.settings.notice_clbk then
		attention_info.settings.notice_clbk(data.unit, false)
	end

	if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.settings.reaction then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
	end

	if attention_info.uncover_progress then
		attention_info.unit:movement():on_suspicion(data.unit, false)
	end

	data.detected_attention_objects[attention_info.u_key] = nil
end

function CopLogicBase._destroy_all_detected_attention_object_data(data)
	for u_key, attention_info in pairs(data.detected_attention_objects) do
		attention_info.handler:remove_listener("detect_" .. tostring(data.key))

		if not attention_info.identified and attention_info.settings.notice_clbk then
			attention_info.settings.notice_clbk(data.unit, false)
		end

		if AIAttentionObject.REACT_SUSPICIOUS <= attention_info.settings.reaction then
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
		end

		if attention_info.uncover_progress then
			attention_info.unit:movement():on_suspicion(data.unit, false)
		end
	end

	data.detected_attention_objects = {}
end

function CopLogicBase.on_detected_attention_obj_modified(data, modified_u_key)
	if data.logic.on_detected_attention_obj_modified_internal then
		data.logic.on_detected_attention_obj_modified_internal(data, modified_u_key)
	end

	local attention_info = data.detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk

	if new_settings then
		local switch_from_suspicious = AIAttentionObject.REACT_SCARED <= new_settings.reaction and attention_info.reaction <= AIAttentionObject.REACT_SUSPICIOUS
		attention_info.settings = new_settings
		attention_info.stare_expire_t = nil
		attention_info.pause_expire_t = nil

		if attention_info.uncover_progress then
			attention_info.uncover_progress = nil

			attention_info.unit:movement():on_suspicion(data.unit, false)
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
		end

		if attention_info.identified then
			if switch_from_suspicious then
				attention_info.identified = false
				attention_info.notice_progress = attention_info.uncover_progress or 0
				attention_info.notice_progress_wanted = attention_info.uncover_progress or 0
				attention_info.verified = nil
				attention_info.next_verify_t = 0
				attention_info.prev_notice_chk_t = TimerManager:game():time()
			end
		elseif switch_from_suspicious then
			attention_info.next_verify_t = 0
			attention_info.notice_progress = 0
			attention_info.notice_progress_wanted = 0
			attention_info.prev_notice_chk_t = TimerManager:game():time()
		end

		attention_info.reaction = math.min(new_settings.reaction, attention_info.reaction)
	else
		CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

		local my_data = data.internal_data

		if data.attention_obj and data.attention_obj.u_key == modified_u_key then
			CopLogicBase._set_attention_obj(data, nil, nil)

			if my_data and (my_data.firing or my_data.firing_on_client) then
				data.unit:movement():set_allow_fire(false)

				my_data.firing = nil
				my_data.firing_on_client = nil
			end
		end

		if my_data.alarming_targets then
			my_data.alarming_targets[modified_u_key] = nil
		end
	end

	if old_notice_clbk and (not new_settings or not new_settings.notice_clbk) then
		old_notice_clbk(data.unit, false)
	end

	if AIAttentionObject.REACT_SCARED <= old_settings.reaction and (not new_settings or AIAttentionObject.REACT_SCARED > new_settings.reaction) then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
	end
end

function CopLogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_reaction = new_reaction or new_att_obj.settings.reaction
		new_att_obj.reaction = new_reaction
		local new_crim_rec = new_att_obj.criminal_record
		local is_same_obj, contact_chatter_time_ok = nil

		if old_att_obj then
			if old_att_obj.u_key == new_att_obj.u_key then
				is_same_obj = true
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 2

				if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
					if new_att_obj.settings.pause then
						new_att_obj.stare_expire_t = nil
						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
					if not new_att_obj.settings.attract_chance or math.random() < new_att_obj.settings.attract_chance then
						new_att_obj.pause_expire_t = nil
						new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
					else
						debug_pause_unit(data.unit, "skipping attraction")

						new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())
					end
				end
			else
				if old_att_obj.criminal_record then
					managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
				end

				if new_crim_rec then
					managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
				end

				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
			end
		else
			if new_crim_rec then
				managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
			end

			contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
		end

		if not is_same_obj then
			if new_att_obj.settings.duration then
				new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
				new_att_obj.pause_expire_t = nil
			end

			new_att_obj.acquire_t = data.t
		end

		if AIAttentionObject.REACT_SHOOT <= new_reaction and new_att_obj.verified and contact_chatter_time_ok and (data.unit:anim_data().idle or data.unit:anim_data().move) and new_att_obj.is_person and data.char_tweak.chatter.contact then
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.unit:position(), "spotted_player")
		end
	elseif old_att_obj and old_att_obj.criminal_record then
		managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
	end
end

function CopLogicBase._is_important_to_player(record, my_key)
	if record.important_enemies then
		for i, test_e_key in ipairs(record.important_enemies) do
			if test_e_key == my_key then
				return true
			end
		end
	end
end

function CopLogicBase.should_duck_on_alert(data, alert_data)
	if not data.important or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.crouch or alert_data[1] == "voice" or data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local lower_body_action = data.unit:movement()._active_actions[2]

	if lower_body_action and lower_body_action:type() == "walk" and not data.char_tweak.crouch_move then
		return
	end
end

function CopLogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	return not attention_info.criminal_record or attention_info.is_human_player and CopLogicBase._is_important_to_player(attention_info.criminal_record, data.key)
end

function CopLogicBase._chk_relocate(data)
	if not data.objective then
		return false
	end

	if data.objective.type == "follow" then
		if data.is_converted then
			if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective) then
				data.objective.in_place = nil

				data.logic._exit_to_state(data.unit, "travel")

				return true
			end

			return
		end

		if data.is_tied and data.objective.lose_track_dis and data.objective.lose_track_dis * data.objective.lose_track_dis < mvector3.distance_sq(data.m_pos, data.objective.follow_unit:movement():m_pos()) then
			data.brain:set_objective(nil)

			return true
		end

		local relocate = nil
		local follow_unit = data.objective.follow_unit
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()

		if data.objective.relocated_to and mvector3.equal(data.objective.relocated_to, follow_unit_pos) then
			return false
		end

		if data.objective.distance and data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos) then
			relocate = true
		end

		if not relocate then
			local ray_params = {
				tracker_from = data.unit:movement():nav_tracker(),
				pos_to = follow_unit_pos
			}
			local ray_res = managers.navigation:raycast(ray_params)

			if ray_res then
				relocate = true
			end
		end

		if relocate then
			data.objective.in_place = nil
			data.objective.nav_seg = follow_unit:movement():nav_tracker():nav_segment()
			data.objective.relocated_to = mvector3.copy(follow_unit_pos)

			data.logic._exit_to_state(data.unit, "travel")

			return true
		end
	elseif data.objective.type == "hunt" then
		local area = data.objective.area

		if area and not next(area.criminal.units) then
			local found_areas = {
				[area] = true
			}
			local areas_to_search = {
				area
			}
			local target_area = nil

			while next(areas_to_search) do
				local current_area = table.remove(areas_to_search)

				if next(current_area.criminal.units) then
					target_area = current_area

					break
				end

				for _, n_area in pairs(current_area.neighbours) do
					if not found_areas[n_area] then
						found_areas[n_area] = true

						table.insert(areas_to_search, n_area)
					end
				end
			end

			if target_area then
				data.objective.in_place = nil
				data.objective.nav_seg = next(target_area.nav_segs)
				data.objective.path_data = {
					{
						data.objective.nav_seg
					}
				}

				data.logic._exit_to_state(data.unit, "travel")

				if data.group then
					data.group.objective.area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.nav_seg)
				end

				return true
			end
		end
	end

	return false
end

function CopLogicBase.is_obstructed(data, objective, strictness, attention)
	local my_data = data.internal_data
	attention = attention or data.attention_obj

	if not objective or objective.is_default or (objective.in_place or not objective.nav_seg) and not objective.action then
		return true, false
	end

	if objective.interrupt_suppression and data.is_suppressed then
		return true, true
	end

	strictness = strictness or 0

	if objective.interrupt_health then
		local health_ratio = data.unit:character_damage():health_ratio()

		if health_ratio < 1 and health_ratio * (1 - strictness) < objective.interrupt_health then
			return true, true
		end
	end

	if objective.interrupt_dis then
		if attention and (AIAttentionObject.REACT_COMBAT <= attention.reaction or data.cool and AIAttentionObject.REACT_SURPRISED <= attention.reaction) then
			if objective.interrupt_dis == -1 then
				return true, true
			elseif math.abs(attention.m_pos.z - data.m_pos.z) < 250 then
				local enemy_dis = attention.dis * (1 - strictness)

				if not attention.verified then
					enemy_dis = 2 * attention.dis * (1 - strictness)
				end

				if attention.is_very_dangerous then
					enemy_dis = enemy_dis * 0.25
				end

				if enemy_dis < objective.interrupt_dis then
					return true, true
				end
			end

			if objective.pos and math.abs(attention.m_pos.z - objective.pos.z) < 250 then
				local enemy_dis = mvector3.distance(objective.pos, attention.m_pos) * (1 - strictness)

				if enemy_dis < objective.interrupt_dis then
					return true, true
				end
			end
		elseif objective.interrupt_dis == -1 and not data.unit:movement():cool() then
			return true, true
		end
	end

	return false, false
end

function CopLogicBase._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicIdle._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local near_threshold = 2000
	local too_close_threshold = 1000

	if data.internal_data.weapon_range then
		near_threshold = data.internal_data.weapon_range.optimal or near_threshold
		too_close_threshold = data.internal_data.weapon_range.close or too_close_threshold
	end

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				if not attention_data.settings.attract_chance or math.random() < attention_data.settings.attract_chance then
					attention_data.pause_expire_t = nil
				else
					debug_pause_unit(data.unit, "[ CopLogicBase._get_priority_attention] skipping attraction")

					attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
				end
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = attention_data.dis
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

			if data.cool and AIAttentionObject.REACT_SCARED <= reaction then
				data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit))
			end

			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 200 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
				attention_data.aimed_at = aimed_at
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local status = crim_record and crim_record.status
				local nr_enemies = crim_record and crim_record.engaged_force
				local old_enemy = false

				if data.attention_obj and data.attention_obj.u_key == u_key and data.t - attention_data.acquire_t < 4 then
					old_enemy = true
				end

				local weight_mul = attention_data.settings.weight_mul or 1
				local reviving = false

				if attention_data.is_local_player then
					local iparams = att_unit:movement():current_state()._interact_params

					if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
						reviving = true
					end

					if reviving then
						weight_mul = weight_mul * managers.player:upgrade_value("player", "medic_attention_weight_reduction", 1)
					end
				elseif att_unit:base() and att_unit:base().upgrade_value then
					reviving = att_unit:anim_data() and att_unit:anim_data().revive

					if reviving then
						weight_mul = weight_mul * (att_unit:base():upgrade_value("player", "medic_attention_weight_reduction") or 1)
					end
				end

				if weight_mul ~= 1 then
					weight_mul = 1 / weight_mul
					alert_dt = alert_dt and alert_dt * weight_mul
					dmg_dt = dmg_dt and dmg_dt * weight_mul
					distance = distance * weight_mul
				end

				local visible = attention_data.verified
				local near = distance < near_threshold
				local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 200
				local free_status = status == nil
				local has_alerted = alert_dt < 3.5
				local has_damaged = dmg_dt < 5
				local target_priority = distance
				local target_priority_slot = 0

				if visible and not reviving then
					if distance < 500 then
						target_priority_slot = 2
					elseif distance < 1500 then
						target_priority_slot = 4
					else
						target_priority_slot = 6
					end

					if has_damaged then
						target_priority_slot = target_priority_slot - 2
					elseif has_alerted then
						target_priority_slot = target_priority_slot - 1
					else
						local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK

						if free_status and assault_reaction then
							target_priority_slot = 5
						end
					end

					if old_enemy then
						target_priority_slot = target_priority_slot - 3
					end

					target_priority_slot = math.clamp(target_priority_slot, 1, 10)
				elseif free_status then
					target_priority_slot = 7
				end

				if reaction < AIAttentionObject.REACT_COMBAT then
					target_priority_slot = 10 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
				end

				if target_priority_slot ~= 0 then
					local best = false

					if not best_target then
						best = true
					elseif target_priority_slot < best_target_priority_slot then
						best = true
					elseif target_priority_slot == best_target_priority_slot and target_priority < best_target_priority then
						best = true
					end

					if best then
						best_target = attention_data
						best_target_reaction = reaction
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	local function _exit_func()
		attention_obj.unit:movement():on_uncovered(data.unit)

		local reaction = AIAttentionObject.REACT_COMBAT
		local state_name = "attack"
		attention_obj.reaction = reaction
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, attention_obj)

		if allow_trans then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)

				if my_data ~= data.internal_data then
					return true
				end
			end

			CopLogicBase._exit_to_state(data.unit, state_name)

			return true
		end
	end

	local dis = attention_obj.dis
	local susp_settings = attention_obj.unit:base():suspicion_settings()

	if attention_obj.settings.uncover_range and dis < math.min(attention_obj.settings.max_range, attention_obj.settings.uncover_range) * susp_settings.range_mul then
		attention_obj.unit:movement():on_suspicion(data.unit, true)
		managers.groupai:state():criminal_spotted(attention_obj.unit)

		return _exit_func()
	elseif attention_obj.verified and attention_obj.settings.suspicion_range and dis < math.min(attention_obj.settings.max_range, attention_obj.settings.suspicion_range) * susp_settings.range_mul then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			local range_max = (attention_obj.settings.suspicion_range - (attention_obj.settings.uncover_range or 0)) * susp_settings.range_mul
			local range_min = (attention_obj.settings.uncover_range or 0) * susp_settings.range_mul
			local mul = 1 - (dis - range_min) / range_max
			local progress = dt * mul * susp_settings.buildup_mul / attention_obj.settings.suspicion_duration
			attention_obj.uncover_progress = (attention_obj.uncover_progress or 0) + progress

			if attention_obj.uncover_progress < 1 then
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
				managers.groupai:state():on_criminal_suspicion_progress(attention_obj.unit, data.unit, attention_obj.uncover_progress)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, true)
				managers.groupai:state():criminal_spotted(attention_obj.unit)

				return _exit_func()
			end
		else
			attention_obj.uncover_progress = 0
		end

		attention_obj.last_suspicion_t = data.t
	elseif attention_obj.uncover_progress then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			attention_obj.uncover_progress = attention_obj.uncover_progress - dt

			if attention_obj.uncover_progress <= 0 then
				attention_obj.uncover_progress = nil
				attention_obj.last_suspicion_t = nil

				attention_obj.unit:movement():on_suspicion(data.unit, false)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
			end
		else
			attention_obj.last_suspicion_t = data.t
		end
	end
end

function CopLogicBase.upd_suspicion_decay(data)
	local my_data = data.internal_data

	for u_key, u_data in pairs(data.detected_attention_objects) do
		if u_data.uncover_progress and u_data.last_suspicion_t ~= data.t then
			local dt = data.t - u_data.last_suspicion_t
			u_data.uncover_progress = u_data.uncover_progress - dt

			if u_data.uncover_progress <= 0 then
				u_data.uncover_progress = nil
				u_data.last_suspicion_t = nil

				u_data.unit:movement():on_suspicion(data.unit, false)
			else
				u_data.unit:movement():on_suspicion(data.unit, u_data.uncover_progress)

				u_data.last_suspicion_t = data.t
			end
		end
	end
end

function CopLogicBase._get_logic_state_from_reaction(data, reaction)
	local result = nil

	if reaction == nil and data.attention_obj then
		reaction = data.attention_obj.reaction
	end

	local nav_seg = data.unit:movement():nav_tracker():nav_segment()
	local nav_seg_id = nav_seg and managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
	local police_is_being_called = nav_seg_id and managers.groupai:state():chk_enemy_calling_in_area(nav_seg_id, data.key)

	if not reaction or reaction <= AIAttentionObject.REACT_SCARED then
		if not data.unit:movement():cool() then
			result = "idle"
		end
	else
		result = "attack"
	end

	return result
end

function CopLogicBase._call_the_police(data, my_data, paniced)
	if not my_data.is_on_alert_SO then
		CopLogicBase.register_alert_SO(data)
		CopLogicArrest._say_call_the_police(data, my_data)
	end
end

function CopLogicBase._say_call_the_police(data, my_data)
	local blame_list = {
		hostage_civ = "saw_hostage_civ",
		drill = "saw_drill",
		civilian = "saw_civilian",
		trip_mine = "saw_trip_mine",
		w_hot = "spotted_player",
		criminal = "spotted_player",
		sentry_gun = "saw_sentry_gun",
		dead_cop = "saw_body",
		hostage_cop = "saw_hostage_cop",
		body_bag = "saw_bag",
		dead_civ = "saw_body"
	}
	local event = blame_list[my_data.call_in_event] or "spotted_player"

	if event == "spotted_player" then
		managers.groupai:state():chk_say_enemy_chatter(data.unit, data.unit:position(), "spotted_player")
	else
		data.unit:sound():say(event, true)
	end
end

function CopLogicBase._chk_call_the_police(data)
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

	if allow_trans and data.logic.is_available_for_assignment(data) and not data.is_converted and not data.unit:movement():cool() and not managers.groupai:state():is_police_called() and (not data.attention_obj or not data.attention_obj.verified_t or data.t - data.attention_obj.verified_t > 1 or data.attention_obj.reaction <= AIAttentionObject.REACT_SHOOT) then
		if obj_failed then
			data.objective_failed_clbk(data.unit, data.objective)
		end

		local nav_segment = data.unit:movement():nav_tracker():nav_segment()
		local nav_area = managers.groupai:state():get_area_from_nav_seg_id(nav_segment)

		if (not data.objective or data.objective.is_default) and not managers.groupai:state():chk_enemy_calling_in_area(nav_area, data.key) then
			CopLogicBase._exit_to_state(data.unit, "alarm")
		end
	end
end

function CopLogicBase.identify_attention_obj_instant(data, att_u_key)
	local att_obj_data = data.detected_attention_objects[att_u_key]
	local is_new = not att_obj_data

	if att_obj_data then
		mvector3.set(att_obj_data.verified_pos, att_obj_data.handler:get_detection_m_pos())

		att_obj_data.verified_dis = mvector3.distance(att_obj_data.verified_pos, data.unit:movement():m_stand_pos())

		if not att_obj_data.identified then
			att_obj_data.identified = true
			att_obj_data.identified_t = data.t
			att_obj_data.notice_progress = nil
			att_obj_data.prev_notice_chk_t = nil

			if att_obj_data.settings.notice_clbk then
				att_obj_data.settings.notice_clbk(data.unit, true)
			end

			data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data, "CopLogicBase.identify_attention_obj_instant_1")
		elseif att_obj_data.uncover_progress then
			att_obj_data.uncover_progress = nil

			att_obj_data.unit:movement():on_suspicion(data.unit, false)
		end
	else
		local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[att_u_key]

		if attention_info then
			local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

			if settings then
				att_obj_data = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, att_u_key, attention_info, settings)
				att_obj_data.identified = true
				att_obj_data.identified_t = data.t
				att_obj_data.notice_progress = nil
				att_obj_data.prev_notice_chk_t = nil

				if att_obj_data.settings.notice_clbk then
					att_obj_data.settings.notice_clbk(data.unit, true)
				end

				data.detected_attention_objects[att_u_key] = att_obj_data

				data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data, "CopLogicBase.identify_attention_obj_instant_2")
			end
		end
	end

	if att_obj_data then
		managers.groupai:state():on_criminal_suspicion_progress(att_obj_data.unit, data.unit, true)
		managers.hud:set_suspicion_indicator_state(data.unit:unit_data().suspicion_icon_id, "alarmed")
	end

	return att_obj_data, is_new
end

function CopLogicBase.is_alert_aggressive(alert_type)
	return CopLogicBase._AGGRESSIVE_ALERT_TYPES[alert_type]
end

function CopLogicBase.is_alert_dangerous(alert_type)
	return CopLogicBase._DANGEROUS_ALERT_TYPES[alert_type]
end

function CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)
	local surrender_tweak = data.char_tweak.surrender

	if not surrender_tweak then
		return
	end

	local t = data.t

	if data.surrender_window and data.surrender_window.window_expire_t < t then
		data.unit:brain():on_surrender_chance()

		return
	end

	local hold_chance = 1
	local surrender_chk = {
		health = function (health_surrender)
			local health_ratio = data.unit:character_damage():health_ratio()

			if health_ratio < 1 then
				local min_setting, max_setting = nil

				for k, v in pairs(health_surrender) do
					if not min_setting or k < min_setting.k then
						min_setting = {
							k = k,
							v = v
						}
					end

					if not max_setting or max_setting.k < k then
						max_setting = {
							k = k,
							v = v
						}
					end
				end

				if health_ratio < max_setting.k then
					hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, health_ratio - min_setting.k) / (max_setting.k - min_setting.k)))
				end
			end
		end,
		aggressor_dis = function (agg_dis_surrender)
			local agg_dis = mvec3_dis(data.m_pos, aggressor_unit:movement():m_pos())
			local min_setting, max_setting = nil

			for k, v in pairs(agg_dis_surrender) do
				if not min_setting or k < min_setting.k then
					min_setting = {
						k = k,
						v = v
					}
				end

				if not max_setting or max_setting.k < k then
					max_setting = {
						k = k,
						v = v
					}
				end
			end

			if agg_dis < max_setting.k then
				hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, agg_dis - min_setting.k) / (max_setting.k - min_setting.k)))
			end
		end,
		weapon_down = function (weap_down_surrender)
			local anim_data = data.unit:anim_data()

			if anim_data.reload then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif anim_data.hurt then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif data.unit:movement():stance_name() == "ntl" then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end

			local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

			if ammo == 0 then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end
		end,
		flanked = function (flanked_surrender)
			local dis = mvec3_dir(tmp_vec1, data.m_pos, aggressor_unit:movement():m_pos())

			if dis > 200 then
				local fwd = data.unit:movement():m_rot():y()
				local fwd_dot = mvec3_dot(fwd, tmp_vec1)

				if fwd_dot < -0.5 then
					hold_chance = hold_chance * (1 - flanked_surrender)
				end
			end
		end,
		unaware_of_aggressor = function (unaware_of_aggressor_surrender)
			local att_info = data.detected_attention_objects[aggressor_unit:key()]

			if not att_info or not att_info.identified or t - att_info.identified_t < 1 then
				hold_chance = hold_chance * (1 - unaware_of_aggressor_surrender)
			end
		end,
		enemy_weap_cold = function (enemy_weap_cold_surrender)
			if not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - enemy_weap_cold_surrender)
			end
		end,
		isolated = function (isolated_surrender)
			if data.group and data.group.has_spawned and data.group.initial_size > 1 then
				local has_support = nil
				local max_dis_sq = 722500

				for u_key, u_data in pairs(data.group.units) do
					if u_key ~= data.key and mvec3_dis_sq(data.m_pos, u_data.m_pos) < max_dis_sq then
						has_support = true

						break
					end

					if not has_support then
						hold_chance = hold_chance * (1 - isolated_surrender)
					end
				end
			end
		end,
		pants_down = function (pants_down_surrender)
			local not_cool_t = data.unit:movement():not_cool_t()

			if (not not_cool_t or t - not_cool_t < 1.5) and not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - pants_down_surrender)
			end
		end
	}

	for reason, reason_data in pairs(surrender_tweak.reasons) do
		surrender_chk[reason](reason_data)
	end

	if hold_chance >= 1 - (surrender_tweak.significant_chance or 0) then
		return 1
	end

	for factor, factor_data in pairs(surrender_tweak.factors) do
		surrender_chk[factor](factor_data)
	end

	if data.surrender_window then
		hold_chance = hold_chance * (1 - data.surrender_window.chance_mul)
	end

	if surrender_tweak.violence_timeout then
		local violence_t = data.unit:character_damage():last_suppression_t()

		if violence_t then
			local violence_dt = t - violence_t

			if violence_dt < surrender_tweak.violence_timeout then
				hold_chance = hold_chance + (1 - hold_chance) * (1 - violence_dt / surrender_tweak.violence_timeout)
			end
		end
	end

	return hold_chance < 1 and hold_chance
end

function CopLogicBase.on_intimidated(data, amount, aggressor_unit)
	return false
end

function CopLogicBase._surrender(data, amount, aggressor_unit)
	local params = {
		effect = amount,
		aggressor_unit = aggressor_unit
	}

	data.brain:set_objective({
		type = "surrender",
		params = params
	})
end

function CopLogicBase.on_attention_obj_identified(data, attention_u_key, attention_info, reason)
	if not data.unit:unit_data().mugshot_id and not managers.groupai:state():is_police_called() then
		-- Nothing
	end

	if attention_info.unit then
		if attention_info.unit:character_damage() and attention_info.unit:character_damage():dead() then
			managers.voice_over:guard_saw_body(data.unit)
		elseif attention_info.unit:carry_data() then
			managers.voice_over:guard_saw_bag(data.unit)
		elseif managers.groupai:state():whisper_mode() and attention_info.unit:character_damage() and attention_info.unit:movement() and attention_info.unit:movement().SO_access then
			local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
			local difficulty_index = tweak_data:difficulty_to_index(difficulty)
			local alert_radius = (data.char_tweak.shout_radius or 0) + (data.char_tweak.shout_radius_difficulty and data.char_tweak.shout_radius_difficulty[difficulty_index] or 0)
			local new_alert = {
				"vo_cbt",
				data.unit:movement():m_head_pos(),
				data.char_tweak.shout_radius or 0,
				attention_info.unit:movement():SO_access(),
				attention_info.unit
			}

			managers.groupai:state():propagate_alert(new_alert)
		end
	end

	if data.group then
		for u_key, u_data in pairs(data.group.units) do
			if u_key ~= data.key then
				if alive(u_data.unit) then
					u_data.unit:brain():clbk_group_member_attention_identified(data.unit, attention_u_key)
				else
					debug_pause_unit(data.unit, "[CopLogicBase.on_attention_obj_identified] destroyed group member", data.unit, inspect(data.group), inspect(u_data), u_key)
				end
			end
		end
	end
end

function CopLogicBase.on_suppressed_state(data)
	if data.is_suppressed and data.objective then
		local allow_trans, interrupt = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

		if interrupt then
			data.objective_failed_clbk(data.unit, data.objective)
		end
	end
end

function CopLogicBase.chk_start_action_dodge(data, reason)
	if not data.char_tweak.dodge or not data.char_tweak.dodge.occasions[reason] then
		return
	end

	if data.dodge_timeout_t and data.t < data.dodge_timeout_t or data.dodge_chk_timeout_t and data.t < data.dodge_chk_timeout_t or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local dodge_tweak = data.char_tweak.dodge.occasions[reason]
	data.dodge_chk_timeout_t = TimerManager:game():time() + math.lerp(dodge_tweak.check_timeout[1], dodge_tweak.check_timeout[2], math.random())

	if dodge_tweak.chance == 0 or dodge_tweak.chance < math.random() then
		return
	end

	local rand_nr = math.random()
	local total_chance = 0
	local variation, variation_data = nil

	for test_variation, test_variation_data in pairs(dodge_tweak.variations) do
		total_chance = total_chance + test_variation_data.chance

		if test_variation_data.chance > 0 and rand_nr <= total_chance then
			variation = test_variation
			variation_data = test_variation_data

			break
		end
	end

	local dodge_dir = Vector3()
	local face_attention = nil

	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		mvec3_set(dodge_dir, data.attention_obj.m_pos)
		mvec3_sub(dodge_dir, data.m_pos)
		mvector3.set_z(dodge_dir, 0)
		mvector3.normalize(dodge_dir)

		if mvector3.dot(data.unit:movement():m_fwd(), dodge_dir) < 0 then
			return
		end

		mvector3.cross(dodge_dir, dodge_dir, math.UP)

		face_attention = true
	else
		mvector3.random_orthogonal(dodge_dir, math.UP)
	end

	local dodge_dir_reversed = false

	if math.random() < 0.5 then
		mvector3.negate(dodge_dir)

		dodge_dir_reversed = not dodge_dir_reversed
	end

	local prefered_space = 130
	local min_space = 90
	local ray_to_pos = tmp_vec1

	mvec3_set(ray_to_pos, dodge_dir)
	mvector3.multiply(ray_to_pos, 130)
	mvector3.add(ray_to_pos, data.m_pos)

	local ray_params = {
		trace = true,
		tracker_from = data.unit:movement():nav_tracker(),
		pos_to = ray_to_pos
	}
	local ray_hit1 = managers.navigation:raycast(ray_params)
	local dis = nil

	if ray_hit1 then
		local hit_vec = tmp_vec2

		mvec3_set(hit_vec, ray_params.trace[1])
		mvec3_sub(hit_vec, data.m_pos)
		mvec3_set_z(hit_vec, 0)

		dis = mvector3.length(hit_vec)

		mvec3_set(ray_to_pos, dodge_dir)
		mvector3.multiply(ray_to_pos, -130)
		mvector3.add(ray_to_pos, data.m_pos)

		ray_params.pos_to = ray_to_pos
		local ray_hit2 = managers.navigation:raycast(ray_params)

		if ray_hit2 then
			mvec3_set(hit_vec, ray_params.trace[1])
			mvec3_sub(hit_vec, data.m_pos)
			mvec3_set_z(hit_vec, 0)

			local prev_dis = dis
			dis = mvector3.length(hit_vec)

			if prev_dis < dis and min_space < dis then
				mvector3.negate(dodge_dir)

				dodge_dir_reversed = not dodge_dir_reversed
			end
		else
			mvector3.negate(dodge_dir)

			dis = nil
			dodge_dir_reversed = not dodge_dir_reversed
		end
	end

	if ray_hit1 and dis and dis < min_space then
		return
	end

	local dodge_side = nil

	if face_attention then
		if dodge_dir_reversed then
			dodge_side = "l"
		else
			dodge_side = "r"
		end
	else
		local fwd_dot = mvec3_dot(dodge_dir, data.unit:movement():m_fwd())
		local my_right = tmp_vec1

		mrotation.x(data.unit:movement():m_rot(), my_right)

		local right_dot = mvec3_dot(dodge_dir, my_right)

		if math.abs(fwd_dot) > 0.7071067690849 then
			if fwd_dot > 0 then
				dodge_side = "fwd"
			else
				dodge_side = "bwd"
			end
		elseif right_dot > 0 then
			dodge_side = "r"
		else
			dodge_side = "l"
		end
	end

	local body_part = 1
	local shoot_chance = variation_data.shoot_chance

	if shoot_chance and shoot_chance > 0 and math.random() < shoot_chance then
		body_part = 2
	end

	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = variation,
		side = dodge_side,
		direction = dodge_dir,
		timeout = variation_data.timeout,
		speed = data.char_tweak.dodge.speed,
		shoot_accuracy = variation_data.shoot_accuracy,
		blocks = {
			act = -1,
			tase = -1,
			bleedout = -1,
			dodge = -1,
			walk = -1,
			action = body_part == 1 and -1 or nil,
			aim = body_part == 1 and -1 or nil
		}
	}

	if variation ~= "side_step" then
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
	end

	local action = data.unit:movement():action_request(action_data)

	if action then
		local my_data = data.internal_data

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._cancel_expected_pos_path(data, my_data)
		CopLogicAttack._cancel_walking_to_cover(data, my_data, true)
	end

	return action
end

function CopLogicBase.chk_am_i_aimed_at(data, attention_obj, max_dot)
	if not attention_obj.is_person then
		return
	end

	if attention_obj.dis < 700 and max_dot > 0.3 then
		max_dot = math.lerp(0.3, max_dot, (attention_obj.dis - 50) / 650)
	end

	local enemy_look_dir = tmp_vec1

	mrotation.y(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)

	local enemy_vec = tmp_vec2

	mvec3_dir(enemy_vec, attention_obj.m_head_pos, data.unit:movement():m_com())

	return max_dot < mvec3_dot(enemy_vec, enemy_look_dir)
end

function CopLogicBase._chk_alert_obstructed(my_listen_pos, alert_data)
	if alert_data[3] then
		local alert_epicenter = nil

		if alert_data[1] == "bullet" then
			alert_epicenter = tmp_vec1

			mvector3.step(alert_epicenter, alert_data[2], alert_data[6], 50)
		else
			alert_epicenter = alert_data[2]
		end

		local ray = World:raycast("ray", my_listen_pos, alert_epicenter, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

		if ray then
			if alert_data[1] == "footstep" then
				return true
			end

			local my_dis_sq = mvector3.distance(my_listen_pos, alert_epicenter)
			local dampening = alert_data[1] == "bullet" and 0.5 or 0.25
			local effective_dis_sq = alert_data[3] * dampening
			effective_dis_sq = effective_dis_sq * effective_dis_sq

			if my_dis_sq > effective_dis_sq then
				return true
			end
		end
	end
end

function CopLogicBase._chk_has_old_action(data, my_data)
	local anim_data = data.unit:anim_data()
	my_data.has_old_action = anim_data.to_idle or anim_data.act
	local lower_body_action = data.unit:movement()._active_actions[2]

	if lower_body_action and lower_body_action:type() == "walk" then
		my_data.advancing = lower_body_action
	else
		my_data.advancing = nil
	end
end

function CopLogicBase._upd_stop_old_action(data, my_data, objective)
	if not my_data.action_started and objective and objective.action and not data.unit:anim_data().to_idle then
		if my_data.advancing then
			if not data.unit:movement():chk_action_forbidden("idle") then
				data.unit:brain():action_request({
					sync = true,
					body_part = 2,
					type = "idle"
				})
			end
		elseif not data.unit:movement():chk_action_forbidden("idle") and data.unit:anim_data().needs_idle then
			CopLogicBase._start_idle_action_from_act(data)
		elseif data.unit:anim_data().act_idle then
			data.unit:brain():action_request({
				sync = true,
				body_part = 2,
				type = "idle"
			})
		end

		CopLogicBase._chk_has_old_action(data, my_data)
	end
end

function CopLogicBase._chk_focus_on_attention_object(data, my_data)
	local current_attention = data.attention_obj

	if not current_attention then
		local set_attention = data.unit:movement():attention()

		if set_attention and set_attention.handler then
			CopLogicBase._reset_attention(data)
		end

		return
	end

	if my_data.turning then
		return
	end

	if (current_attention.reaction == AIAttentionObject.REACT_CURIOUS or current_attention.reaction == AIAttentionObject.REACT_SUSPICIOUS) and CopLogicIdle._upd_curious_reaction(data) then
		return true
	end

	if data.logic.is_available_for_assignment(data) and not data.unit:movement():chk_action_forbidden("walk") then
		local attention_pos = current_attention.handler:get_attention_m_pos(current_attention.settings)
		local turn_angle = CopLogicBase._chk_turn_needed(data, my_data, data.m_pos, attention_pos)

		if turn_angle and current_attention.reaction < AIAttentionObject.REACT_CURIOUS then
			if turn_angle > 70 then
				return
			else
				turn_angle = nil
			end
		end

		if turn_angle then
			local err_to_correct_abs = math.abs(turn_angle)
			local angle_str = nil

			if err_to_correct_abs > 40 then
				if not CopLogicBase._turn_by_spin(data, my_data, turn_angle) then
					return
				end

				if my_data.rubberband_rotation then
					my_data.fwd_offset = true
				end
			end
		end
	end

	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= current_attention.u_key then
		CopLogicBase._set_attention(data, current_attention, nil)
	end

	return true
end

function CopLogicBase._chk_request_action_turn_to_look_pos(data, my_data, my_pos, look_pos)
	local turn_angle = CopLogicBase._chk_turn_needed(data, my_data, my_pos, look_pos)

	if not turn_angle or math.abs(turn_angle) < 5 then
		return
	end

	return CopLogicBase._turn_by_spin(data, my_data, turn_angle)
end

function CopLogicBase._chk_turn_needed(data, my_data, my_pos, look_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = look_pos - my_pos
	local error_polar = target_vec:to_polar_with_reference(fwd, math.UP)
	local error_spin = error_polar.spin
	local abs_err_spin = math.abs(error_spin)
	local tolerance = error_spin < 0 and 50 or 30
	local err_to_correct = error_spin - tolerance * math.sign(error_spin)

	if math.sign(err_to_correct) ~= math.sign(error_spin) then
		return
	end

	return err_to_correct
end

function CopLogicBase._turn_by_spin(data, my_data, spin)
	local new_action_data = {
		body_part = 2,
		type = "turn",
		angle = spin
	}
	my_data.turning = data.unit:brain():action_request(new_action_data)

	if my_data.turning then
		return true
	end
end

function CopLogicBase._start_idle_action_from_act(data)
	data.unit:brain():action_request({
		variant = "idle",
		body_part = 1,
		type = "act",
		blocks = {
			light_hurt = -1,
			hurt = -1,
			action = -1,
			expl_hurt = -1,
			heavy_hurt = -1,
			idle = -1,
			fire_hurt = -1,
			walk = -1
		}
	})
end

function CopLogicBase._upd_aim_at_player(data, my_data)
	local focus_enemy = data.attention_obj

	if data.logic.chk_should_turn(data, my_data) and focus_enemy then
		local enemy_pos = (focus_enemy.verified or focus_enemy.nearly_visible) and focus_enemy.m_head_pos or focus_enemy.verified_pos

		CopLogicAttack._request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
	end
end

function CopLogicBase.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action
end
