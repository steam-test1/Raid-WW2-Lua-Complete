require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicAttack")

TeamAILogicTravel = class(TeamAILogicBase)
TeamAILogicTravel.damage_clbk = TeamAILogicIdle.damage_clbk
TeamAILogicTravel.on_cop_neutralized = TeamAILogicIdle.on_cop_neutralized
TeamAILogicTravel.on_objective_unit_damaged = TeamAILogicIdle.on_objective_unit_damaged
TeamAILogicTravel.on_alert = TeamAILogicIdle.on_alert
TeamAILogicTravel.on_long_dis_interacted = TeamAILogicIdle.on_long_dis_interacted
TeamAILogicTravel.on_new_objective = TeamAILogicIdle.on_new_objective
TeamAILogicTravel.clbk_heat = TeamAILogicIdle.clbk_heat
TeamAILogicTravel._upd_pathing = CopLogicTravel._upd_pathing
TeamAILogicTravel._get_exact_move_pos = CopLogicTravel._get_exact_move_pos
TeamAILogicTravel.chk_should_turn = CopLogicTravel.chk_should_turn
TeamAILogicTravel._get_all_paths = CopLogicTravel._get_all_paths
TeamAILogicTravel._set_verified_paths = CopLogicTravel._set_verified_paths
TeamAILogicTravel.get_pathing_prio = CopLogicTravel.get_pathing_prio
TeamAILogicTravel.on_action_completed = CopLogicTravel.on_action_completed
TeamAILogicTravel.on_intimidated = TeamAILogicIdle.on_intimidated

-- Lines 27-91
function TeamAILogicTravel.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	my_data.detection = data.char_tweak.detection.recon
	my_data.vision = data.char_tweak.vision.idle

	if old_internal_data then
		my_data.attention_unit = old_internal_data.attention_unit
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)

	if not data.unit:movement():cool() then
		my_data.detection_task_key = "TeamAILogicTravel._upd_enemy_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t)
	end

	my_data.cover_update_task_key = "TeamAILogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.advance_path_search_id = "TeamAILogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "TeamAILogicTravel_coarse" .. tostring(data.key)
	my_data.path_ahead = data.team.id == tweak_data.levels:get_default_team_ID("player")

	if data.objective then
		data.objective.called = false
		my_data.called = true

		if data.objective.follow_unit then
			my_data.cover_wait_t = {
				0,
				0
			}
		end

		if data.objective.path_style == "warp" then
			my_data.warp_pos = data.objective.pos
		end
	end

	data.unit:movement():set_allow_fire(false)

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	if not data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	if Application:production_build() then
		my_data.pathing_debug = {
			from_pos = Vector3(),
			to_pos = Vector3()
		}
	end
end

-- Lines 95-106
function TeamAILogicTravel.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)
	data.brain:rem_pos_rsrv("path")
end

-- Lines 110-115
function TeamAILogicTravel.update(data)
	TeamAILogicTravel._upd_ai_perceptors(data)

	return CopLogicTravel.upd_advance(data)
end

-- Lines 119-188
function TeamAILogicTravel._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_CURIOUS, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_attention then
		local objective = data.objective
		local allow_trans, obj_failed = nil
		local dont_exit = false

		if data.unit:movement():chk_action_forbidden("walk") and not data.unit:anim_data().act_idle then
			dont_exit = true
		else
			allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)
		end

		if obj_failed and not dont_exit then
			if objective.type == "follow" then
				debug_pause_unit(data.unit, "failing follow", allow_trans, obj_failed, inspect(objective))
			end

			data.objective_failed_clbk(data.unit, data.objective)

			return
		end
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
		local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)

		if civ then
			my_data._intimidate_t = data.t

			if not data.attention_obj then
				CopLogicBase._set_attention_on_unit(data, civ)

				local key = "RemoveAttentionOnUnit" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, {
					data = data,
					target_key = civ:key()
				}, data.t + 1.5)
			end
		end
	end

	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t + delay)
end

-- Lines 192-199
function TeamAILogicTravel._remove_enemy_attention(param)
	local data = param.data

	if not data.attention_obj or data.attention_obj.u_key ~= param.target_key then
		return
	end

	CopLogicBase._reset_attention(data)
end

-- Lines 203-214
function TeamAILogicTravel.is_available_for_assignment(data, new_objective)
	if new_objective and new_objective.forced then
		return true
	elseif data.objective and data.objective.type == "act" then
		if (not new_objective or new_objective and new_objective.type == "free") and data.objective.interrupt_dis == -1 then
			return true
		end

		return
	else
		return TeamAILogicAssault.is_available_for_assignment(data, new_objective)
	end
end

-- Lines 222-318
function TeamAILogicTravel._upd_ai_perceptors(data)
	if not TeamAILogicTravel._ai_perceptors_t then
		TeamAILogicTravel._ai_perceptors_t = data.t
	end

	if data.t < TeamAILogicTravel._ai_perceptors_t then
		return
	end

	if not TeamAILogicTravel._ai_perceptors then
		TeamAILogicTravel._ai_perceptors = {}
		local players = managers.player:players()

		for _, p in ipairs(players) do
			local id = managers.network:session():peer_by_unit(p):id()
			TeamAILogicTravel._ai_perceptors[id] = {
				is_moving = false,
				is_rotating = false,
				position = Vector3(),
				rotation = Rotation(),
				last_position = Vector3(),
				last_rotation = Rotation()
			}

			mvector3.set(TeamAILogicTravel._ai_perceptors[id].position, p:position())
			mvector3.set(TeamAILogicTravel._ai_perceptors[id].last_position, p:position())
			mrotation.set_yaw_pitch_roll(TeamAILogicTravel._ai_perceptors[id].rotation, p:camera():rotation():yaw(), p:camera():rotation():pitch(), p:camera():rotation():roll())
			mrotation.set_yaw_pitch_roll(TeamAILogicTravel._ai_perceptors[id].last_rotation, p:camera():rotation():yaw(), p:camera():rotation():pitch(), p:camera():rotation():roll())
		end

		TeamAILogicTravel._ai_perceptors_t = TeamAILogicTravel._ai_perceptors_t + 0.5

		return
	end

	local DISTANCE_THRESHOLD = 0.1 * tweak_data.player.team_ai.movement.speed.WALKING_SPEED
	local ROTATION_THRESHOLD = 100
	local players = managers.player:players()

	for _, p in ipairs(players) do
		local id = managers.network:session():peer_by_unit(p):id()

		mvector3.set(TeamAILogicTravel._ai_perceptors[id].last_position, TeamAILogicTravel._ai_perceptors[id].position)
		mvector3.set(TeamAILogicTravel._ai_perceptors[id].position, p:position())
		mrotation.set_yaw_pitch_roll(TeamAILogicTravel._ai_perceptors[id].last_rotation, TeamAILogicTravel._ai_perceptors[id].rotation:yaw(), TeamAILogicTravel._ai_perceptors[id].rotation:pitch(), TeamAILogicTravel._ai_perceptors[id].rotation:roll())
		mrotation.set_yaw_pitch_roll(TeamAILogicTravel._ai_perceptors[id].rotation, p:camera():rotation():yaw(), p:camera():rotation():pitch(), p:camera():rotation():roll())

		local dist_vec = TeamAILogicTravel._ai_perceptors[id].position - TeamAILogicTravel._ai_perceptors[id].last_position
		local dist = dist_vec:length()
		TeamAILogicTravel._ai_perceptors[id].is_moving = true

		if dist <= DISTANCE_THRESHOLD then
			TeamAILogicTravel._ai_perceptors[id].is_moving = false
		end

		local rot_diff = Rotation:rotation_difference(TeamAILogicTravel._ai_perceptors[id].rotation, TeamAILogicTravel._ai_perceptors[id].last_rotation)
		local diff_sum = math.abs(rot_diff:yaw())
		TeamAILogicTravel._ai_perceptors[id].is_rotating = true

		if diff_sum <= ROTATION_THRESHOLD then
			TeamAILogicTravel._ai_perceptors[id].is_rotating = false
		end
	end

	TeamAILogicTravel._ai_perceptors_t = TeamAILogicTravel._ai_perceptors_t + 0.5
end

-- Lines 330-337
function TeamAILogicTravel._is_player_camping(p)
	if not TeamAILogicTravel._ai_perceptors then
		return
	end

	local id = managers.network:session():peer_by_unit(p):id()

	return not TeamAILogicTravel._ai_perceptors[id].is_moving and not TeamAILogicTravel._ai_perceptors[id].is_rotating
end

-- Lines 341-350
function TeamAILogicTravel._players_that_are_camping()
	local players = managers.player:players()
	local campers = {}

	for _, p in ipairs(players) do
		if TeamAILogicTravel._is_player_camping(p) then
			table.insert(campers, p)
		end
	end

	return campers
end

-- Lines 355-370
function TeamAILogicTravel._unit_cones(units, cone_depth)
	local cones = {}

	for _, u in ipairs(units) do
		local cone_top = Vector3()

		mvector3.set(cone_top, u:movement():m_head_pos())

		local rot = Rotation()

		mrotation.set_yaw_pitch_roll(rot, u:movement():m_head_rot():yaw(), 0, 0)

		local rot_vec = rot:y()

		mvector3.normalize(rot_vec)

		local cone_base = cone_top + cone_depth * rot_vec
		local cone_angle = managers.user:get_setting("fov_standard")
		local cone = {
			cone_top = cone_top,
			cone_base = cone_base,
			cone_angle = cone_angle
		}

		table.insert(cones, cone)
	end

	return cones
end

-- Lines 372-507
function TeamAILogicTravel._determine_destination_occupation(data, objective)
	local occupation = nil

	if objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		elseif objective.pos then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				pos = objective.pos,
				radius = objective.radius
			}
		else
			local near_pos = objective.follow_unit and objective.follow_unit:movement():nav_tracker():field_position()
			local cover = CopLogicTravel._find_cover(data, objective.nav_seg, near_pos)

			if cover then
				local cover_entry = {
					cover
				}
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					cover = cover_entry,
					radius = objective.radius
				}
			else
				near_pos = CopLogicTravel._get_pos_on_wall(managers.navigation._nav_segments[objective.nav_seg].pos, 700)
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = near_pos,
					radius = objective.radius
				}
			end
		end
	elseif objective.type == "phalanx" then
		local logic = data.unit:brain():get_logic_by_name(objective.type)

		logic.register_in_group_ai(data.unit)

		local phalanx_circle_pos = logic.calc_initial_phalanx_pos(data.m_pos, objective)
		occupation = {
			type = "defend",
			seg = objective.nav_seg,
			pos = phalanx_circle_pos,
			radius = objective.radius
		}
	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		local my_data = data.internal_data
		local follow_tracker = objective.follow_unit:movement():nav_tracker()
		local dest_nav_seg_id = my_data.coarse_path[#my_data.coarse_path][1]
		local dest_area = managers.groupai:state():get_area_from_nav_seg_id(dest_nav_seg_id)
		local follow_pos = follow_tracker:field_position()
		local threat_pos = nil

		if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
			threat_pos = data.attention_obj.nav_tracker:field_position()
		end

		local campers = TeamAILogicTravel._players_that_are_camping()
		local cones_to_send = TeamAILogicTravel._unit_cones(campers, 400)
		local cover = managers.navigation:find_cover_in_nav_seg_excluding_cones(dest_area.nav_segs, nil, follow_pos, threat_pos, cones_to_send)

		if cover then
			local cover_entry = {
				cover
			}
			occupation = {
				type = "defend",
				cover = cover_entry
			}
		else
			local max_dist = nil

			if objective.called then
				max_dist = 600
			end

			local to_pos = CopLogicTravel._get_pos_on_wall(dest_area.pos, max_dist)
			occupation = {
				type = "defend",
				pos = to_pos
			}
		end
	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {
			trace = true,
			tracker_from = revive_u_tracker
		}

		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end

		local stand_dis = nil

		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 120
		else
			stand_dis = 90
			local mid_pos = mvector3.copy(revive_u_fwd)

			mvector3.multiply(mid_pos, -20)
			mvector3.add(mid_pos, revive_u_pos)

			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end

		local rand_side_mul = math.random() > 0.5 and 1 or -1
		local revive_pos = mvector3.copy(revive_u_right)

		mvector3.multiply(revive_pos, rand_side_mul * stand_dis)
		mvector3.add(revive_pos, revive_u_pos)

		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)

		if ray_res then
			local opposite_pos = mvector3.copy(revive_u_right)

			mvector3.multiply(opposite_pos, -rand_side_mul * stand_dis)
			mvector3.add(opposite_pos, revive_u_pos)

			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)

			if opposite_ray_res then
				if mvector3.distance(revive_pos, revive_u_pos) < mvector3.distance(ray_params.trace[1], revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end
			else
				revive_pos = ray_params.trace[1]
			end
		else
			revive_pos = ray_params.trace[1]
		end

		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math.UP)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	else
		occupation = {
			seg = objective.nav_seg,
			pos = objective.pos
		}
	end

	return occupation
end

-- Lines 514-523
function TeamAILogicTravel._draw_debug_unit_cones(cones)
	local brush = Draw:brush(Color.green:with_alpha(0.5), 2)

	for _, c in ipairs(cones) do
		local h = (c.cone_top - c.cone_base):length()
		local angle = c.cone_angle / 2
		local radius = math.tan(angle) * h

		brush:cone(c.cone_top, c.cone_base, radius)
	end
end
