local tmp_vec1 = Vector3()
CopLogicSpotter = class(CopLogicBase)
CopLogicSpotter.damage_clbk = CopLogicBase.damage_clbk
CopLogicSpotter.is_available_for_assignment = CopLogicAttack.is_available_for_assignment
CopLogicSpotter.death_clbk = CopLogicAttack.death_clbk

function CopLogicSpotter.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = nil,
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)

	local objective = data.objective

	data.unit:brain():cancel_all_pathing_searches()

	if data.unit:brain().reset_spotter then
		data.unit:brain():reset_spotter()
	else
		Application:error("[CopLogicSpotter.enter] Cannot reset_spotter there is no function for it for", data.unit)
	end

	local old_internal_data = data.internal_data
	my_data.detection = data.char_tweak.detection.recon
	my_data.vision = data.char_tweak.vision.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
		end

		if old_internal_data.shooting then
			data.unit:brain():action_request({
				type = "idle",
				body_part = 3
			})
		end
	end

	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	my_data.detection_task_key = "CopLogicSpotter._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicSpotter._upd_enemy_detection, data)

	if objective then
		my_data.wanted_stance = objective.stance
		my_data.wanted_pose = objective.pose
		my_data.attitude = objective.attitude or "avoid"
	end

	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({
		cbt = true
	})

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
end

function CopLogicSpotter.throw_flare_so(data)
	local action_desc = {
		body_part = 1,
		variant = "spotter_cbt_sup_throw_flare",
		type = "act",
		blocks = nil,
		blocks = {
			aim = -1,
			heavy_hurt = -1,
			hurt = -1,
			light_hurt = -1,
			walk = -1,
			action = -1
		}
	}

	data.unit:movement():action_request(action_desc)
end

function CopLogicSpotter.exit(data, new_logic_name, enter_params)
	CopLogicSpotter.super.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
end

function CopLogicSpotter._upd_spotter_detection(data)
	for _, player in pairs(managers.player:players()) do
		managers.groupai:state():on_spotter_detection_progress(player, data.unit, "empty")
	end
end

function CopLogicSpotter._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_AIM
	local delay = CopLogicSpotter._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicBase._get_priority_attention(data, data.detected_attention_objects, CopLogicSpotter._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	CopLogicSpotter._upd_aim(data, my_data)

	if my_data ~= data.internal_data then
		return
	end

	if data.important then
		delay = 0
	else
		delay = 0.5 + delay * 1.5
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicSpotter._upd_enemy_detection, data, data.t + delay)
end

function CopLogicSpotter._chk_reaction_to_attention_object(data, attention_data, stationary)
	local record = attention_data.criminal_record

	if not record or not attention_data.is_person then
		return attention_data.settings.reaction
	end

	if record.status == "disabled" then
		if record.assault_t and record.assault_t - record.disabled_t > 0.6 then
			return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
		end

		return AIAttentionObject.REACT_AIM
	end

	return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_COMBAT)
end

function CopLogicSpotter._upd_attention_obj_detection(data, min_reaction, max_reaction)
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

	if managers.barrage:is_barrage_running() then
		return delay
	end

	local player_skill = PlayerSkill

	for u_key, attention_info in pairs(all_attention_objects) do
		local human_player = false
		local undetectable = false

		if alive(attention_info.unit) then
			if attention_info.unit:base() then
				human_player = attention_info.unit:base().is_local_player or attention_info.unit:base().is_husk_player

				if human_player then
					undetectable = player_skill.has_skill("player", "undetectable_by_spotters", attention_info.unit:base().is_husk_player and attention_info.unit or false)
				end
			end

			if u_key ~= my_key and not detected_obj[u_key] and human_player and not undetectable and (not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker)) then
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
	end

	for u_key, attention_info in pairs(detected_obj) do
		if alive(attention_info.unit) then
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

					if angle then
						local attention_pos = attention_info.handler:get_detection_m_pos()
						local vis_ray = World:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

						if not vis_ray or vis_ray.unit:key() == u_key then
							noticable = true
						end
					end

					local dt = t - attention_info.prev_notice_chk_t
					local delta_prog = dt * -0.125

					if noticable then
						if angle == -1 then
							delta_prog = 1
						else
							local min_delay = my_data.detection.delay[1]
							local max_delay = my_data.detection.delay[2]
							local angle_mul_mod = 0.25 * math.min(angle / my_data.detection.angle_max, 1)
							local dis_mul_mod = 0.75 * dis_multiplier
							local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

							if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
								notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
							end

							local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod + angle_mul_mod)
							delta_prog = dt / speed_mul
						end
					end

					if not attention_info.notice_progress then
						attention_info.notice_progress_wanted = 0
					end

					attention_info.notice_progress_wanted = attention_info.notice_progress_wanted or 0
					attention_info.notice_progress = attention_info.notice_progress_wanted
					attention_info.notice_progress_wanted = attention_info.notice_progress_wanted + delta_prog

					if attention_info.notice_progress > 1 then
						attention_info.notice_progress = nil
						attention_info.notice_progress_wanted = nil
						attention_info.prev_notice_chk_t = nil
						attention_info.identified = true
						attention_info.release_t = t + attention_info.settings.release_delay
						attention_info.identified_t = t
						noticable = true

						managers.groupai:state():on_spotter_detection_progress(attention_info.unit, data.unit, "barrage")
						data.logic.on_attention_obj_identified(data, u_key, attention_info, "spotter")
					elseif attention_info.notice_progress < 0 then
						noticable = false

						CopLogicBase._detection_obj_lost(data, attention_info)
						managers.groupai:state():on_spotter_detection_progress(attention_info.unit, data.unit, "remove")
					else
						noticable = attention_info.notice_progress_wanted
						attention_info.prev_notice_chk_t = t

						managers.groupai:state():on_spotter_detection_progress(attention_info.unit, data.unit, noticable)
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

					if dis < my_data.detection.dis_max * 1.2 and (not attention_info.settings.max_range or dis < attention_info.settings.max_range * (attention_info.settings.detection and attention_info.settings.detection.range_mul or 1) * 1.2) then
						local detect_pos = attention_pos
						local in_FOV = not attention_info.settings.notice_requires_FOV or data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) or CopLogicBase._angle_chk(attention_info.handler, attention_info.settings, data, my_pos, 0.8)

						if in_FOV then
							vis_ray = World:raycast("ray", my_pos, detect_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

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
							if not is_detection_persistent and mvector3.distance(attention_pos, attention_info.criminal_record.pos) > 700 then
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
		end

		CopLogicBase._chk_record_acquired_attention_importance_wgt(attention_info, player_importance_wgt, my_pos)
	end

	if player_importance_wgt then
		managers.groupai:state():set_importance_weight(data.key, player_importance_wgt)
	end

	return delay
end

function CopLogicSpotter._upd_aim(data, my_data)
	if not data.logic._should_aim_or_shoot then
		return
	end

	local aim, shoot = data.logic._should_aim_or_shoot(data, my_data)
	local focus_enemy = data.attention_obj
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk")
	action_taken = action_taken or data.logic._upd_aim_action(data, my_data)

	if my_data.reposition and not action_taken and not my_data.advancing then
		local objective = data.objective
		my_data.advance_path = {
			mvector3.copy(data.m_pos),
			mvector3.copy(objective.pos)
		}

		if CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, objective.haste or "walk", objective.rot) then
			action_taken = true
		end
	end

	data.logic._aim_or_shoot(data, my_data, aim, shoot)
	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicSpotter._should_aim_or_shoot(data, my_data)
	local aim, shoot = nil
	local focus_enemy = data.attention_obj

	if focus_enemy then
		aim = true
		shoot = true
	end

	return aim, shoot
end

function CopLogicSpotter._upd_aim_action(data, my_data)
	local focus_enemy = data.attention_obj
	local action_taken = nil
	local anim_data = data.unit:anim_data()

	if anim_data.reload and not anim_data.crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
		action_taken = CopLogicAttack._request_action_crouch(data)
	end

	if action_taken then
		-- Nothing
	elseif my_data.attitude == "engage" and not data.is_suppressed then
		if focus_enemy then
			if not CopLogicAttack._request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.verified_pos or focus_enemy.m_head_pos) and not focus_enemy.verified and not anim_data.reload then
				if anim_data.crouch then
					if (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and not CopLogicSniper._chk_stand_visibility(data.m_pos, focus_enemy.m_head_pos, data.visibility_slotmask) then
						CopLogicAttack._request_action_stand(data)
					end
				elseif (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) and not CopLogicSniper._chk_crouch_visibility(data.m_pos, focus_enemy.m_head_pos, data.visibility_slotmask) then
					CopLogicAttack._request_action_crouch(data)
				end
			end
		elseif my_data.wanted_pose and not anim_data.reload then
			if my_data.wanted_pose == "crouch" then
				if not anim_data.crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					action_taken = CopLogicAttack._request_action_crouch(data)
				end
			elseif not anim_data.stand and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
				action_taken = CopLogicAttack._request_action_stand(data)
			end
		end
	elseif focus_enemy then
		if not CopLogicAttack._request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.verified_pos or focus_enemy.m_head_pos) and focus_enemy.verified and anim_data.stand and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) and CopLogicSniper._chk_crouch_visibility(data.m_pos, focus_enemy.m_head_pos, data.visibility_slotmask) then
			CopLogicAttack._request_action_crouch(data)
		end
	elseif my_data.wanted_pose and not anim_data.reload then
		if my_data.wanted_pose == "crouch" then
			if not anim_data.crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				action_taken = CopLogicAttack._request_action_crouch(data)
			end
		elseif not anim_data.stand and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
			action_taken = CopLogicAttack._request_action_stand(data)
		end
	end

	return action_taken
end

function CopLogicSpotter._aim_or_shoot(data, my_data, aim, shoot)
	local focus_enemy = data.attention_obj

	if aim or shoot then
		if focus_enemy.verified then
			if my_data.attention_unit ~= focus_enemy.unit:key() then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.unit:key()
			end
		elseif my_data.attention_unit ~= focus_enemy.verified_pos then
			CopLogicBase._set_attention_on_pos(data, mvector3.copy(focus_enemy.verified_pos))

			my_data.attention_unit = mvector3.copy(focus_enemy.verified_pos)
		end
	else
		if my_data.shooting then
			local new_action = nil

			if data.unit:anim_data().reload then
				new_action = {
					type = "reload",
					body_part = 3
				}
			else
				new_action = {
					type = "idle",
					body_part = 3
				}
			end

			data.unit:brain():action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end
end

function CopLogicSpotter._request_action_shoot(data, my_data)
	if my_data.shooting or data.unit:anim_data().reload or data.unit:movement():chk_action_forbidden("action") then
		return
	end

	local shoot_action = {
		type = "shoot",
		body_part = 3
	}

	if data.unit:brain():action_request(shoot_action) then
		my_data.shooting = true
	end
end

function CopLogicSpotter._upd_look_for_player(data, attention_info)
end

function CopLogicSpotter.on_alert(data, alert_data)
end

function CopLogicSpotter.on_attention_obj_identified(data, attention_u_key, attention_info)
	if not data.unit:brain().on_cooldown then
		CopLogicSpotter.throw_flare_so(data)

		data.unit:brain()._spotted_unit = attention_info.unit

		data.unit:brain():schedule_spotter_reset(BarrageManager.SPOTTER_COOLDOWN + tweak_data.barrage.flare_timer)
	end

	CopLogicBase.on_attention_obj_identified(data, attention_u_key, attention_info)
end
