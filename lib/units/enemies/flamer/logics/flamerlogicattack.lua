local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local math_lerp = math.lerp
local math_within = math.within
local math_clamp = math.clamp
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
FlamerLogicAttack = class(CopLogicAttack)

function FlamerLogicAttack.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.vision = data.char_tweak.vision.combat
	local usage = data.unit:inventory():equipped_selection() and data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage

	if usage then
		my_data.weapon_range = data.char_tweak.weapon[usage].range
		my_data.weapon_range_max = data.char_tweak.weapon[usage].max_range
		my_data.additional_weapon_stats = data.char_tweak.weapon[usage].additional_weapon_stats
	end

	if data.char_tweak.throwable then
		my_data.throw_projectile_chance = data.char_tweak.throwable.throw_chance or 0.1
	end

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
	end

	my_data.peek_to_shoot_allowed = false
	my_data.detection_task_key = "CopLogicAttack._upd_enemy_detection" .. tostring(data.key)

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t)
	CopLogicBase._chk_has_old_action(data, my_data)

	my_data.attitude = data.objective and data.objective.attitude or "avoid"

	data.unit:brain():set_update_enabled_state(false)

	if data.cool then
		data.unit:movement():set_cool(false)
	end

	if (not data.objective or not data.objective.stance) and data.unit:movement():stance_code() == 1 then
		data.unit:movement():set_stance("hos")
	end

	if my_data ~= data.internal_data then
		return
	end

	my_data.update_queue_id = "FlamerLogicAttack.queued_update" .. tostring(data.key)

	FlamerLogicAttack.queue_update(data, my_data)

	if data.objective and (data.objective.action_duration or data.objective.action_timeout_t and data.t < data.objective.action_timeout_t) then
		CopLogicBase.request_action_timeout_callback(data)
	end

	data.unit:brain():set_attention_settings({
		cbt = true
	})
end

function FlamerLogicAttack.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	FlamerLogicAttack._cancel_chase_attempt(data, my_data)
	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	data.brain:rem_pos_rsrv("path")
	data.unit:brain():set_update_enabled_state(true)
end

function FlamerLogicAttack.update(data)
	local t = data.t
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		return
	end

	if CopLogicBase._chk_relocate(data) then
		return
	end

	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data or not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
			return
		end
	end

	local focus_enemy = data.attention_obj

	FlamerLogicAttack._process_pathing_results(data, my_data)

	local enemy_visible = focus_enemy.verified
	local engage = my_data.attitude == "engage"
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.walking_to_chase_pos

	if action_taken then
		return
	end

	if unit:anim_data().crouch then
		action_taken = CopLogicAttack._request_action_stand(data)
	end

	if action_taken then
		return
	end

	local enemy_pos = enemy_visible and focus_enemy.m_pos or focus_enemy.verified_pos
	action_taken = CopLogicAttack._request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)

	if action_taken then
		return
	end

	local chase = nil
	local z_dist = math.abs(data.m_pos.z - focus_enemy.m_pos.z)

	if AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction then
		if enemy_visible then
			if z_dist < 300 or focus_enemy.verified_dis > 2000 or engage and focus_enemy.verified_dis > 500 then
				chase = true
			end

			if focus_enemy.verified_dis < 800 and unit:anim_data().run then
				local new_action = {
					type = "idle",
					body_part = 2
				}

				data.unit:brain():action_request(new_action)
			end
		elseif z_dist < 300 or focus_enemy.verified_dis > 2000 or engage and (not focus_enemy.verified_t or t - focus_enemy.verified_t > 5 or focus_enemy.verified_dis > 700) then
			chase = true
		end
	end

	if chase then
		if my_data.walking_to_chase_pos then
			-- Nothing
		elseif my_data.pathing_to_chase_pos then
			-- Nothing
		elseif my_data.chase_path then
			local dist = focus_enemy.verified_dis
			local run_dist = focus_enemy.verified and 1500 or 800
			local walk = dist < run_dist

			FlamerLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, walk and "walk" or "run")
		elseif my_data.chase_pos then
			my_data.chase_path_search_id = tostring(unit:key()) .. "chase"
			my_data.pathing_to_chase_pos = true
			local to_pos = my_data.chase_pos
			my_data.chase_pos = nil

			data.brain:add_pos_rsrv("path", {
				radius = 60,
				position = mvector3.copy(to_pos)
			})
			unit:brain():search_for_path(my_data.chase_path_search_id, to_pos)
		elseif focus_enemy.nav_tracker then
			my_data.chase_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker)
		end
	else
		FlamerLogicAttack._cancel_chase_attempt(data, my_data)
	end
end

function FlamerLogicAttack._upd_aim(data, my_data)
	FlamerLogicAttack.super._upd_aim(data, my_data)

	local focus_enemy = data.attention_obj

	if focus_enemy then
		local enemy_visible = focus_enemy.verified

		if enemy_visible then
			FlamerLogicAttack._chk_throw_throwable(data, my_data, focus_enemy)
		end
	end
end

function FlamerLogicAttack._chk_throw_throwable(data, my_data, focus)
	local projectile = data.char_tweak.throwable and data.char_tweak.throwable.projectile_id

	if not projectile then
		return
	end

	if data.projectile_thrown_t and data.t < data.projectile_thrown_t then
		return
	end

	if not focus.last_verified_pos or not focus.verified_t then
		return
	end

	if data.char_tweak.throwable.throw_chance < math.random() then
		return
	end

	local mov_ext = data.unit:movement()

	if mov_ext:chk_action_forbidden("action") then
		return
	end

	local head_pos = mov_ext:m_head_pos()
	local throw_dis = focus.verified_dis
	local min_distance = my_data.weapon_range_max * 0.9

	if not math_within(throw_dis, min_distance, 2400) then
		return
	end

	local throw_pos = head_pos + mov_ext:m_head_rot():y() * 50
	local enemy_pos = focus.m_head_pos
	local slotmask = managers.slot:get_mask("world_geometry")

	if data.unit:raycast("ray", throw_pos, enemy_pos, "sphere_cast_radius", 15, "slot_mask", slotmask, "report") then
		return
	end

	local throw_dir = Vector3()

	mvec3_lerp(throw_dir, throw_pos, enemy_pos, 0.6)
	mvec3_sub(throw_dir, throw_pos)

	local dis_lerp = math_clamp((throw_dis - 1000) / 1000, 0, 1)
	local adjust = math_lerp(0, 280, dis_lerp)

	mvec3_set_z(throw_dir, throw_dir.z + adjust)
	mvec3_norm(throw_dir)

	data.projectile_thrown_t = data.t + (data.char_tweak.throwable.cooldown or 35)

	if mov_ext:play_redirect("throw_grenade") then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", data.unit, "throw_grenade")
	end

	local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile)

	ProjectileBase.throw_projectile(projectile_index, throw_pos, throw_dir)
end

function FlamerLogicAttack.queued_update(data)
	local my_data = data.internal_data
	my_data.update_queued = false
	data.t = TimerManager:game():time()

	FlamerLogicAttack.update(data)

	if my_data == data.internal_data then
		FlamerLogicAttack.queue_update(data, data.internal_data)
	end
end

function FlamerLogicAttack._process_pathing_results(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.chase_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.chase_path = path
			end

			my_data.pathing_to_chase_pos = nil
			my_data.chase_path_search_id = nil
		end
	end
end

function FlamerLogicAttack._cancel_chase_attempt(data, my_data)
	my_data.chase_path = nil

	if my_data.walking_to_chase_pos then
		local new_action = {
			type = "idle",
			body_part = 2
		}

		data.unit:brain():action_request(new_action)
	elseif my_data.pathing_to_chase_pos then
		data.brain:rem_pos_rsrv("path")

		if data.active_searches[my_data.chase_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.chase_path_search_id)

			data.active_searches[my_data.chase_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.chase_path_search_id] = nil
		end

		my_data.chase_path_search_id = nil
		my_data.pathing_to_chase_pos = nil

		data.unit:brain():cancel_all_pathing_searches()
	elseif my_data.chase_pos then
		my_data.chase_pos = nil
	end
end

function FlamerLogicAttack.on_action_completed(data, action)
	local action_type = action:type()
	local my_data = data.internal_data

	if action_type == "walk" then
		my_data.advancing = nil

		if my_data.walking_to_chase_pos then
			my_data.walking_to_chase_pos = nil
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" and action:expired() then
		CopLogicAttack._upd_aim(data, my_data)
	end
end

function FlamerLogicAttack.chk_should_turn(data, my_data)
	return not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.retreating and not my_data.walking_to_chase_pos
end

function FlamerLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, FlamerLogicAttack.queued_update, data, data.t + 1.5, data.important)
end

function FlamerLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, speed, end_rot)
	if not data.unit:movement():chk_action_forbidden("walk") then
		local new_action_data = {
			type = "walk",
			no_strafe = false,
			body_part = 2,
			nav_path = my_data.chase_path,
			variant = speed or "run",
			end_rot = end_rot
		}
		my_data.chase_path = nil
		my_data.walking_to_chase_pos = data.unit:brain():action_request(new_action_data)

		if my_data.walking_to_chase_pos then
			data.brain:rem_pos_rsrv("path")
		end
	end
end

function FlamerLogicAttack.is_advancing(data)
	if data.internal_data.walking_to_chase_pos and data.pos_rsrv.move_dest then
		return data.pos_rsrv.move_dest.position
	end
end

function FlamerLogicAttack._get_all_paths(data)
	return {
		chase_path = data.internal_data.chase_path
	}
end

function FlamerLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.chase_path = verified_paths.chase_path
end
