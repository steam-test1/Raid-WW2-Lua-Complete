DistractionRock = DistractionRock or class(GrenadeBase)

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

function DistractionRock:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	Application:debug("[DistractionRock:clbk_impact]", tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function DistractionRock:_on_collision(col_ray)
	Application:debug("[DistractionRock:_on_collision]")
end

function DistractionRock:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._hand_held then
		return
	end

	local pos = self._unit:position()
	local range = self._range
	local slotmask = managers.slot:get_mask("enemies")
	local units = World:find_units_quick("sphere", pos, self._range, slotmask)
	local end_position = Vector3(pos.x, pos.y, pos.z - 50)
	local collision = World:raycast("ray", pos, end_position, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"))

	if collision then
		if managers.navigation:is_point_inside(pos, false) then
			Application:debug("[DistractionRock:_detonate] Hit the ground! coin pos: " .. pos .. " true")
		else
			Application:debug("[DistractionRock:_detonate] Hit the ground! coin pos: " .. pos .. " false")

			return
		end
	elseif managers.navigation:is_point_inside(pos, false) then
		Application:debug("[DistractionRock:_detonate] Missed the ground! coin pos: " .. pos .. " true")
	else
		Application:debug("[DistractionRock:_detonate] Missed the ground! coin pos: " .. pos .. " false")

		return
	end

	if units and managers.navigation:is_point_inside(pos, false) then
		local closest_cop = nil

		for _, cop in ipairs(units) do
			local search_id = "DistractionRock._detonate" .. tostring(cop:key())
			local search_params = {
				finished = false,
				pos_from = cop:movement():m_pos(),
				pos_to = pos,
				id = search_id,
				result_clbk = callback(self, self, "clbk_pathing_results", search_id),
				access_pos = cop:brain()._SO_access,
				cop = cop
			}
			self._pathing_searches[search_id] = search_params

			managers.navigation:search_pos_to_pos(search_params)
		end
	end
end

function DistractionRock:clbk_pathing_results(search_id, path)
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

		if not search.invalid and search.total_length < self._range and not self._found_cop then
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

function DistractionRock:_abort_all_unfinished_pathing()
	for search_id, search in pairs(self._pathing_searches) do
		if not search.finished then
			managers.navigation:cancel_pathing_search(search_id)
		end
	end
end

function DistractionRock:_detonate_on_client()
end

function DistractionRock:bullet_hit()
	Application:debug("[DistractionRock:bullet_hit]")
end

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

function DistractionRock:update_attention_settings(descriptor)
	local tweak_data = tweak_data.attention.settings[descriptor]

	if tweak_data and self._attention_handler then
		local attention_setting = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data, descriptor)

		self._attention_handler:set_attention(attention_setting)
	end
end
