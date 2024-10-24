ImpactDecoy = ImpactDecoy or class(ImpactHurt)

function ImpactDecoy:_setup_from_tweak_data()
	ImpactDecoy.super._setup_from_tweak_data(self)

	self._range = self._tweak_data.range
	self._pathing_searches = {}
	local sound_event = self._tweak_data.sound_event or "grenade_explode"
	self._custom_params = {
		feedback_range = nil,
		effect = nil,
		sound_event = nil,
		sound_muffle_effect = true,
		camera_shake_max_mul = 4,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}
end

function ImpactDecoy:_on_collision(col_ray)
	ImpactDecoy.super._on_collision(self, col_ray)

	if not managers.groupai:state():whisper_mode() then
		return
	end

	local pos = self._unit:position()
	local range = self._range
	local slotmask = managers.slot:get_mask("enemies")
	local units = World:find_units_quick("sphere", pos, range, slotmask)

	if #units == 0 then
		Application:debug("[ImpactDecoy:_on_collision] There were no enemies nearby")

		return
	else
		Application:debug("[ImpactDecoy:_on_collision] There were " .. tostring(#units) .. " enemies nearby")
	end

	local end_position = Vector3(pos.x, pos.y, pos.z - 400)
	local collision = World:raycast("ray", pos, end_position, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"))
	local is_point_inside_nav = managers.navigation:is_point_inside(not not collision and collision.position or pos, false)
	local final_lure_position = nil

	if is_point_inside_nav then
		final_lure_position = pos

		Application:debug("[ImpactDecoy:_on_collision] Usable lure position:", final_lure_position)
	else
		local tracker = managers.navigation:create_nav_tracker(end_position, false)
		final_lure_position = tracker:field_position()

		managers.navigation:destroy_nav_tracker(tracker)

		local dist = mvector3.distance(final_lure_position, end_position)

		if range < dist then
			Application:debug("[ImpactDecoy:_on_collision] The Nav tracker backup position was too far to be considered usable. dist:", dist)

			return
		else
			Application:debug("[ImpactDecoy:_on_collision] Fell out of navigation, use nav field tracker pos:", final_lure_position)
		end
	end

	if not managers.navigation:is_point_inside(final_lure_position, false) then
		Application:debug("[ImpactDecoy:_on_collision] There was no hope for this final lure position. Cancelled lure.")

		return
	end

	local closest_cop_dist, closest_cop = nil

	for _, cop in ipairs(units) do
		local dist = mvector3.distance(final_lure_position, cop:position())

		if not closest_cop_dist or dist < closest_cop_dist then
			closest_cop_dist = dist
			closest_cop = cop
		end
	end

	if alive(closest_cop) then
		Application:debug("[ImpactDecoy:_on_collision] Closest boso is lured.", closest_cop)

		local search_id = "ImpactDecoy._on_collision" .. tostring(closest_cop:key())
		local search_params = {
			pos_from = nil,
			access_pos = nil,
			cop = nil,
			result_clbk = nil,
			id = nil,
			pos_to = nil,
			finished = false,
			pos_from = closest_cop:movement():m_pos(),
			pos_to = final_lure_position,
			id = search_id,
			result_clbk = callback(self, self, "clbk_pathing_results", search_id),
			access_pos = closest_cop:brain()._SO_access,
			cop = closest_cop
		}
		self._pathing_searches[search_id] = search_params

		managers.navigation:search_pos_to_pos(search_params)
	end
end

function ImpactDecoy:add_damage_result(unit, attacker, is_dead, damage_percent)
	local thrower_peer_id = self:get_thrower_peer_id()

	if is_dead and not unit:movement():cool() then
		self:_award_achievement_decoy_kill(thrower_peer_id)
	end
end

function ImpactDecoy:_award_achievement_decoy_kill(thrower_peer_id)
	Application:info("[ImpactDecoy:achievements] ach_decoy_kill_anyone PEER:", thrower_peer_id)

	local achievement_id = "ach_decoy_kill_anyone"

	if thrower_peer_id == 1 then
		managers.achievment:award(achievement_id)
	else
		local thrower_peer = managers.network:session():peer(thrower_peer_id)

		managers.network:session():send_to_peer(thrower_peer, "sync_award_achievement", achievement_id)
	end
end

function ImpactDecoy:clbk_pathing_results(search_id, path)
	Application:debug("[ImpactDecoy:clbk_pathing_results] Whoop", search_id, path)

	local search = self._pathing_searches[search_id]

	if path and search then
		search.finished = true
		search.total_length = 0
		local last_leg = nil

		for _, leg in ipairs(path) do
			if leg.x then
				if last_leg then
					local length = leg - last_leg
					search.total_length = search.total_length + length:length()
				else
					last_leg = leg
				end
			else
				search.invalid = true
			end
		end

		if not search.invalid and search.total_length < self._range * 2 and not self._found_cop then
			Application:debug("[ImpactDecoy:clbk_pathing_results] Valid path, route is short enough", search.total_length, self._range * 4)
			self:_abort_all_unfinished_pathing()

			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(search.cop:base()._char_tweak.access)[search.cop:key()]
			attention_info.m_pos = search.pos_to
			attention_info.settings = {
				reaction = nil,
				reaction = AIAttentionObject.REACT_SUSPICIOUS
			}
			attention_info.u_key = 1
			local search_data = {
				unit = nil,
				activated_clbk = nil,
				unit = self._unit,
				activated_clbk = callback(self, self, "_guard_picked_up")
			}
			self._found_cop = CopLogicBase.register_search_SO(search.cop, attention_info, search.pos_to, search_data)
		end
	end
end

function ImpactDecoy:_guard_picked_up(guard)
	Application:debug("[ImpactDecoy:clbk_pathing_results] Guard yoinked coin")

	if Network:is_server() then
		self._unit:set_slot(0)
	end

	if guard then
		managers.voice_over:guard_found_coin(guard)
	end
end

function ImpactDecoy:_abort_all_unfinished_pathing()
	for search_id, search in pairs(self._pathing_searches) do
		if not search.finished then
			managers.navigation:cancel_pathing_search(search_id)
		end
	end
end

function ImpactDecoy:set_attention_state(state)
	if state then
		if not self._attention_setting then
			self._attention_handler = AIAttentionObject:new(self._unit, true)

			if self._attention_obj_name then
				self._attention_handler:set_detection_object_name(self._attention_obj_name)
			end

			local descriptor = "distraction_ntl"
			local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings[descriptor], descriptor)

			self._attention_handler:set_attention(attention_setting)
		end
	elseif self._attention_handler then
		self._attention_handler:set_attention(nil)

		self._attention_handler = nil
	end
end

function ImpactDecoy:update_attention_settings(descriptor)
	local tweak_data = tweak_data.attention.settings[descriptor]

	if tweak_data and self._attention_handler then
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data, descriptor)

		self._attention_handler:set_attention(attention_setting)
	end
end
