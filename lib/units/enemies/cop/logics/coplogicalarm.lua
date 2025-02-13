CopLogicAlarm = class(CopLogicBase)
CopLogicAlarm.ALARM_SAFE_RANGE = 2000

function CopLogicAlarm.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.guard
	my_data.vision = data.char_tweak.vision.combat
	my_data.alarming_targets = {}
	local key_str = tostring(data.key)
	my_data.update_task_key = "CopLogicAlarm.queued_update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicAlarm.queued_update, data, data.t)
	data.unit:brain():set_update_enabled_state(false)

	if (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and not data.unit:anim_data().stand then
		CopLogicAttack._request_action_stand(data)
	end

	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and (data.objective.nav_seg or data.objective.type == "follow") and not data.objective.in_place then
		debug_pause_unit(data.unit, "[CopLogicAlarm.enter] wrong logic1", data.unit, "objective", inspect(data.objective))
	end

	if data.unit:movement():stance_name() == "ntl" then
		data.unit:movement():set_stance("cbt")
	end

	CopLogicBase._chk_has_old_action(data, my_data)
	data.unit:brain():set_attention_settings({
		cbt = true
	})

	my_data.next_action_delay_t = data.t + math.lerp(1, 3, math.random())
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	if data.objective and (data.objective.nav_seg or data.objective.type == "follow") and not data.objective.in_place then
		debug_pause_unit(data.unit, "[CopLogicAlarm.enter] wrong logic2", data.unit, "objective", inspect(data.objective))
	end
end

function CopLogicAlarm.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if new_logic_name ~= "inactive" then
		data.unit:brain():set_update_enabled_state(true)
		CopLogicBase._reset_attention(data)
	end

	if my_data.calling_the_police then
		local action_data = {
			body_part = 3,
			type = "idle"
		}

		data.unit:brain():action_request(action_data)
	end

	if my_data.calling_the_police then
		managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
	end
end

function CopLogicAlarm.queued_update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data

	CopLogicAlarm._upd_enemy_detection(data)

	if my_data ~= data.internal_data then
		return
	end

	if my_data.has_old_action then
		CopLogicBase._upd_stop_old_action(data, my_data, data.objective)
		CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicAlarm.queued_update, data, data.t + 1, data.important)

		return
	end

	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicAlarm.queued_update, data, data.t + 1, data.important)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function CopLogicAlarm._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local all_attention_objects = data.detected_attention_objects

	CopLogicAlarm._verify_alarming_targets(data, my_data)

	local new_attention, new_prio_slot, new_reaction = CopLogicAlarm._get_priority_attention(data, data.detected_attention_objects)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	CopLogicAlarm._mark_call_in_event(data, my_data, new_attention)
	CopLogicAlarm._chk_say_discovery(data, my_data, new_attention)

	local should_sound_alarm = new_reaction == AIAttentionObject.REACT_ALARM

	if should_sound_alarm then
		my_data.in_position = true
	end

	local current_attention = data.unit:movement():attention()

	if new_attention and not current_attention or current_attention and not new_attention or new_attention and current_attention.u_key ~= new_attention.u_key then
		if new_attention then
			CopLogicBase._set_attention(data, new_attention)
		else
			CopLogicBase._reset_attention(data)
		end
	end

	if (not new_reaction or new_reaction < AIAttentionObject.REACT_SHOOT or not new_attention.verified or new_attention.dis >= CopLogicAlarm.ALARM_SAFE_RANGE) and (my_data.in_position or not my_data.should_sound_alarm) then
		if data.char_tweak.calls_in and my_data.next_action_delay_t < data.t and not managers.groupai:state():is_police_called() and not my_data.calling_the_police and not my_data.turning and not data.unit:sound():speaking(data.t) then
			CopLogicAlarm._call_the_police(data, my_data, true)

			return
		end

		if (managers.groupai:state():is_police_called() or managers.groupai:state():chk_enemy_calling_in_area(managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment()), data.key)) and not my_data.calling_the_police then
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data) or "idle"

			CopLogicBase._exit_to_state(data.unit, wanted_state)
			CopLogicBase._report_detections(data.detected_attention_objects)

			return
		end
	else
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if my_data.calling_the_police then
				data.unit:brain():action_request({
					body_part = 3,
					type = "idle"
				})
			end

			CopLogicBase._exit_to_state(data.unit, wanted_state)
			CopLogicBase._report_detections(data.detected_attention_objects)

			return
		end
	end
end

function CopLogicAlarm._chk_reaction_to_attention_object(data, attention_data, stationary)
	local record = attention_data.criminal_record

	if not record or not attention_data.is_person then
		return attention_data.settings.reaction
	end

	if not attention_data.verified or CopLogicAlarm.ALARM_SAFE_RANGE < attention_data.dis then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_ALARM)
	end

	if record.status == "disabled" then
		if record.assault_t and record.assault_t - record.disabled_t > 0.6 then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
		end

		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_AIM)
	end

	return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
end

function CopLogicAlarm._verify_alarming_targets(data, my_data)
	local all_attention_objects = data.detected_attention_objects
	local alarming_targets = my_data.alarming_targets
	local group_ai = managers.groupai:state()

	for u_key, arrest_data in pairs(alarming_targets) do
		local drop, penalty = nil
		local record = group_ai:criminal_record(u_key)

		if not record then
			-- Nothing
		elseif arrest_data.intro_pos and mvector3.distance_sq(arrest_data.attention_obj.m_pos, arrest_data.intro_pos) > 28900 then
			drop = true
			penalty = true
		elseif arrest_data.intro_t and record.assault_t and record.assault_t > arrest_data.intro_t + 0.6 then
			drop = true
			penalty = true
		elseif record.status or data.t < record.alarm_timeout then
			drop = true
		elseif all_attention_objects[u_key] ~= arrest_data.attention_obj or not arrest_data.attention_obj.identified then
			drop = true

			if arrest_data.intro_pos then
				penalty = true
			end
		end

		if drop then
			if penalty then
				record.alarm_timeout = data.t + 5
			end

			alarming_targets[u_key] = nil
		end
	end
end

function CopLogicAlarm.on_action_completed(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil
		my_data.next_action_delay_t = TimerManager:game():time() + math.lerp(0.2, 0.5, math.random())
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "act" then
		if my_data.calling_the_police then
			my_data.calling_the_police = nil

			if not my_data.called_the_police then
				managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
			end
		end

		my_data.next_action_delay_t = TimerManager:game():time() + math.lerp(0.2, 0.5, math.random())
	end
end

function CopLogicAlarm.damage_clbk(data, damage_info)
	local my_data = data.internal_data

	CopLogicBase.damage_clbk(data, damage_info)

	if my_data ~= data.internal_data then
		return
	end

	local enemy = damage_info.attacker_unit

	if enemy then
		for enemy_key, arrest_data in pairs(my_data.alarming_targets) do
			my_data.alarming_targets[enemy_key] = nil
			local record = managers.groupai:state():criminal_record(enemy_key)

			if record then
				record.alarm_timeout = data.t + 5
			end
		end
	end
end

function CopLogicAlarm.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	return false
end

function CopLogicAlarm.on_criminal_neutralized(data, criminal_key)
	local record = managers.groupai:state():criminal_record(criminal_key)
	local my_data = data.internal_data

	if record.status == "dead" or record.status == "removed" then
		if my_data.alarming_targets[criminal_key] then
			managers.groupai:state():on_arrest_end(data.key, criminal_key)
		end

		my_data.alarming_targets[criminal_key] = nil
	elseif my_data.alarming_targets[criminal_key] and my_data.alarming_targets[criminal_key].intro_pos then
		my_data.alarming_targets[criminal_key].intro_pos = mvector3.copy(my_data.alarming_targets[criminal_key].attention_obj.m_pos)
		my_data.alarming_targets[criminal_key].intro_t = TimerManager:game():time()
	end
end

function CopLogicAlarm._call_the_police(data, my_data, paniced)
	if not my_data.is_on_alert_SO then
		CopLogicBase.register_alert_SO(data)
		CopLogicAlarm._say_call_the_police(data, my_data)
	end
end

function CopLogicAlarm._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicAlarm._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				attention_data.pause_expire_t = nil
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = mvector3.distance(data.m_pos, attention_data.m_pos)
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 200 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local alarming_targets = data.internal_data.alarming_targets

				if reaction == AIAttentionObject.REACT_ALARM and reaction == best_target_reaction and alarming_targets and alarming_targets[best_target.u_key] and alarming_targets[best_target.u_key].intro_t and (not alarming_targets[u_key] or not alarming_targets[u_key].intro_t) then
					best_target = attention_data
					best_target_reaction = reaction
					best_target_priority_slot = 7
					best_target_priority = distance
				else
					local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
					local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
					local status = crim_record and crim_record.status
					local nr_enemies = crim_record and crim_record.engaged_force

					if data.attention_obj and data.attention_obj.u_key == u_key then
						alert_dt = alert_dt and alert_dt * 0.8
						dmg_dt = dmg_dt and dmg_dt * 0.8
						distance = distance * 0.8
					end

					local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK
					local visible = attention_data.verified
					local near = distance < near_threshold
					local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 200
					local free_status = status == nil
					local has_alerted = alert_dt < 3.5
					local has_damaged = dmg_dt < 5
					local reviving = nil

					if attention_data.is_local_player then
						local iparams = att_unit:movement():current_state()._interact_params

						if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
							reviving = true
						end
					else
						reviving = att_unit:anim_data() and att_unit:anim_data().revive
					end

					local target_priority = distance
					local target_priority_slot = 0

					if visible and not reviving then
						if free_status then
							if too_near then
								target_priority_slot = 1
							elseif near then
								target_priority_slot = 2
							elseif assault_reaction then
								target_priority_slot = 3
							else
								target_priority_slot = 4
							end
						elseif has_damaged then
							if near then
								target_priority_slot = 3
							else
								target_priority_slot = 5
							end
						elseif has_alerted then
							target_priority_slot = 6
						end
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
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicAlarm._process_pathing_results(data, my_data)
	if data.pathing_results then
		for path_id, path in pairs(data.pathing_results) do
			if path_id == my_data.path_search_id then
				if path ~= "failed" then
					my_data.advance_path = path
				else
					print("[CopLogicAlarm._process_pathing_results] advance path failed")
				end

				my_data.processing_path = nil
				my_data.path_search_id = nil
			end
		end

		data.pathing_results = nil
	end
end

function CopLogicAlarm._cancel_advance(data, my_data)
	if my_data.processing_path then
		if data.active_searches[my_data.path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.path_search_id)

			data.active_searches[my_data.path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.path_search_id] = nil
		end

		my_data.processing_path = nil
		my_data.path_search_id = nil
	end

	my_data.advance_path = nil

	if my_data.advancing then
		local action_data = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(action_data)
	end

	my_data.in_position = false
end

function CopLogicAlarm._get_att_obj_close_pos(data, my_data)
	local nav_manager = managers.navigation
	local my_nav_tracker = data.unit:movement():nav_tracker()
	local destroy_att_nav_tracker, att_nav_tracker = nil

	if data.attention_obj.nav_tracker then
		att_nav_tracker = data.attention_obj.nav_tracker
	else
		destroy_att_nav_tracker = true
		att_nav_tracker = nav_manager:create_nav_tracker(data.attention_obj.m_pos)
	end

	local att_obj_pos = att_nav_tracker:field_position()
	local my_dis = mvector3.distance(data.m_pos, att_obj_pos)
	local optimal_dis = 150 + math.random() * 150

	if my_dis > optimal_dis * 0.8 and my_dis < optimal_dis * 1.2 then
		if destroy_att_nav_tracker then
			nav_manager:destroy_nav_tracker(att_nav_tracker)
		end

		return false
	end

	local pos_on_wall = CopLogicTravel._get_pos_on_wall(att_obj_pos, optimal_dis, nil, false)

	return pos_on_wall
end

function CopLogicAlarm._say_scary_stuff_discovered(data)
	if not data.attention_obj then
		return
	end

	data.unit:sound():stop()
	managers.groupai:state():chk_say_enemy_chatter(data.unit, data.unit:position(), "spotted_player")
end

function CopLogicAlarm.death_clbk(data, damage_info)
	if not alive(damage_info.attacker_unit) then
		return
	end

	local my_data = data.internal_data
	local attacker_u_key = damage_info.attacker_unit:key()
	local arrest_data = my_data.alarming_targets[attacker_u_key]

	if arrest_data then
		local record = managers.groupai:state():criminal_record(attacker_u_key)

		if record then
			record.alarm_timeout = data.t + 5
		end
	end
end

function CopLogicAlarm._mark_call_in_event(data, my_data, attention_obj)
	if not attention_obj then
		return
	end

	if attention_obj.reaction == AIAttentionObject.REACT_ALARM then
		my_data.call_in_event = "criminal"
	elseif AIAttentionObject.REACT_SCARED <= attention_obj.reaction then
		local unit_base = attention_obj.unit:base()
		local unit_brain = attention_obj.unit:brain()

		if attention_obj.unit:in_slot(17) then
			my_data.call_in_event = managers.enemy:get_corpse_unit_data_from_key(attention_obj.unit:key()).is_civilian and "dead_civ" or "dead_cop"
		elseif attention_obj.unit:in_slot(managers.slot:get_mask("enemies")) then
			my_data.call_in_event = "w_hot"
		elseif unit_brain and unit_brain.is_hostage and unit_brain:is_hostage() then
			my_data.call_in_event = managers.enemy:is_civilian(attention_obj.unit) and "hostage_civ" or "hostage_cop"
		elseif unit_base and unit_base.is_drill then
			my_data.call_in_event = "drill"
		elseif unit_base and unit_base.sentry_gun then
			my_data.call_in_event = "sentry_gun"
		elseif attention_obj.unit:carry_data() and attention_obj.unit:carry_data():carry_id() == "person" then
			my_data.call_in_event = "body_bag"
		elseif attention_obj.unit:in_slot(21) then
			my_data.call_in_event = "civilian"
		end
	end
end

function CopLogicAlarm._chk_say_discovery(data, my_data, attention_obj)
	if not attention_obj then
		return
	end

	if not my_data.discovery_said and attention_obj.reaction == AIAttentionObject.REACT_SCARED then
		my_data.discovery_said = true

		managers.groupai:state():chk_say_enemy_chatter(data.unit, data.unit:position(), "spotted_player")
	end
end

function CopLogicAlarm._chk_say_approach(data, my_data, attention_obj)
end

function CopLogicAlarm.on_police_call_success(data)
	data.internal_data.called_the_police = true
end

function CopLogicAlarm._say_call_the_police(data, my_data)
	local blame_list = {
		dead_civ = "saw_body",
		dead_cop = "saw_body",
		civilian = "saw_civilian",
		body_bag = "saw_bag",
		trip_mine = "saw_trip_mine",
		sentry_gun = "saw_sentry_gun",
		drill = "saw_drill",
		hostage_cop = "saw_hostage_cop",
		hostage_civ = "saw_hostage_civ",
		criminal = "spotted_player",
		w_hot = "spotted_player"
	}
	local event = blame_list[my_data.call_in_event] or "spotted_player"

	if event == "spotted_player" then
		managers.groupai:state():chk_say_enemy_chatter(data.unit, data.unit:position(), "spotted_player")
	else
		data.unit:sound():say(event, true)
	end
end
