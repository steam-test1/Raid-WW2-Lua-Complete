DistractionRock = DistractionRock or class(GrenadeBase)

-- Lines 8-23
function DistractionRock:_setup_from_tweak_data()
	local grenade_entry = self.name_id
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._init_timer = self._tweak_data.init_timer or 2.5
	self._mass_look_up_modifier = self._tweak_data.mass_look_up_modifier
	self._range = self._tweak_data.range
	self._pathing_searches = {}
	local sound_event = self._tweak_data.sound_event or "grenade_explode"
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}
end

-- Lines 28-30
function DistractionRock:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	Application:debug("[DistractionRock:clbk_impact]", tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

-- Lines 32-34
function DistractionRock:_on_collision(col_ray)
	Application:debug("[DistractionRock:_on_collision]")
end

-- Lines 36-162
function DistractionRock:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._hand_held then
		return
	end

	local pos = self._unit:position()
	local range = self._range
	local slotmask = managers.slot:get_mask("enemies")
	local units = World:find_units_quick("sphere", pos, range, slotmask)

	if #units == 0 then
		Application:debug("[DistractionRock:_detonate] There were no enemies nearby")

		return
	else
		Application:debug("[DistractionRock:_detonate] There were " .. tostring(#units) .. " enemies nearby")
	end

	local end_position = Vector3(pos.x, pos.y, pos.z - 400)
	local collision = World:raycast("ray", pos, end_position, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"))
	local is_point_inside_nav = managers.navigation:is_point_inside(not not collision and collision.position or pos, false)
	local final_lure_position = nil

	if is_point_inside_nav then
		final_lure_position = pos

		Application:debug("[DistractionRock:_detonate] Usable lure position:", final_lure_position)
	else
		local tracker = managers.navigation:create_nav_tracker(end_position, false)
		final_lure_position = tracker:field_position()

		managers.navigation:destroy_nav_tracker(tracker)

		local dist = mvector3.distance(final_lure_position, end_position)

		if range < dist then
			Application:debug("[DistractionRock:_detonate] The Nav tracker backup position was too far to be considered usable. dist:", dist)

			return
		else
			Application:debug("[DistractionRock:_detonate] Fell out of navigation, use nav field tracker pos:", final_lure_position)
		end
	end

	if not managers.navigation:is_point_inside(final_lure_position, false) then
		Application:debug("[DistractionRock:_detonate] There was no hope for this final lure position. Cancelled lure.")

		return
	end

	if units then
		local closest_cop_dist, closest_cop = nil

		for _, cop in ipairs(units) do
			local dist = mvector3.distance(final_lure_position, cop:position())

			if not closest_cop_dist or dist < closest_cop_dist then
				closest_cop_dist = dist
				closest_cop = cop
			end
		end

		if closest_cop then
			Application:debug("[DistractionRock:_detonate] Closest boso is lured.", closest_cop)

			local search_id = "DistractionRock._detonate" .. tostring(closest_cop:key())
			local search_params = {
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
end

-- Lines 164-202
function DistractionRock:clbk_pathing_results(search_id, path)
	Application:debug("[DistractionRock:clbk_pathing_results] Whoop", search_id, path)

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
			Application:debug("[DistractionRock:clbk_pathing_results] Valid path, route is short enough", search.total_length, self._range * 4)
			self:_abort_all_unfinished_pathing()

			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(search.cop:base()._char_tweak.access)[search.cop:key()]
			attention_info.m_pos = search.pos_to
			attention_info.settings = {
				reaction = AIAttentionObject.REACT_SUSPICIOUS
			}
			attention_info.u_key = 1
			self._found_cop = CopLogicBase.register_search_SO(search.cop, attention_info, search.pos_to)
		end
	end
end

-- Lines 218-226
function DistractionRock:_abort_all_unfinished_pathing()
	for search_id, search in pairs(self._pathing_searches) do
		if not search.finished then
			managers.navigation:cancel_pathing_search(search_id)
		end
	end
end

-- Lines 230-231
function DistractionRock:_detonate_on_client()
end

-- Lines 235-237
function DistractionRock:bullet_hit()
	Application:debug("[DistractionRock:bullet_hit]")
end

-- Lines 241-256
function DistractionRock:set_attention_state(state)
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

-- Lines 258-264
function DistractionRock:update_attention_settings(descriptor)
	local tweak_data = tweak_data.attention.settings[descriptor]

	if tweak_data and self._attention_handler then
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data, descriptor)

		self._attention_handler:set_attention(attention_setting)
	end
end
