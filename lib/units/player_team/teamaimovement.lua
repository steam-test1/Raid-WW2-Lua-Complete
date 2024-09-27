TeamAIMovement = TeamAIMovement or class(CopMovement)
TeamAIMovement._char_name_to_index = HuskPlayerMovement._char_name_to_index
TeamAIMovement._char_model_names = HuskPlayerMovement._char_model_names

function TeamAIMovement:_post_init()
	if managers.groupai:state():whisper_mode() then
		if not self._heat_listener_clbk and Network:is_server() then
			self._heat_listener_clbk = "TeamAIMovement" .. tostring(self._unit:key())

			managers.groupai:state():add_listener(self._heat_listener_clbk, {
				"whisper_mode"
			}, callback(self, self, "heat_clbk"))
		end

		self._unit:base():set_slot(self._unit, 24)
	else
		self:set_cool(false)
	end

	self._standing_nav_seg_id = self._nav_tracker:nav_segment()

	self:play_redirect("idle")
end

function TeamAIMovement:set_character_anim_variables()
	HuskPlayerMovement.set_character_anim_variables(self)
end

function TeamAIMovement:check_visual_equipment()
	if Network:is_server() and self._unit:customization() then
		local nationality = managers.criminals:character_name_by_unit(self._unit) or "british"
		local customization = managers.player:get_customization_for_nationality(nationality)

		self:set_character_customization(customization)
	end
end

function TeamAIMovement:set_character_customization(customization)
	customization = customization or {
		nationality = nil,
		nationality = managers.criminals:character_name_by_unit(self._unit) or "british"
	}
	local head_name = customization.equiped_head_name
	local upper_name = customization.equiped_upper_name
	local lower_name = customization.equiped_lower_name
	local nationality = customization.nationality

	self._unit:customization():attach_all_parts_to_character_by_parts_for_husk(nationality, head_name, upper_name, lower_name)

	self._customization = managers.blackmarket:team_ai_customization_string(customization)

	if Network:is_server() then
		self._unit:network():send("set_character_customization", self._customization, 0, 0)
	end
end

function TeamAIMovement:m_detect_pos()
	return self._m_head_pos
end

function TeamAIMovement:set_position(pos)
	CopMovement.set_position(self, pos)
	self:_upd_location()
end

function TeamAIMovement:set_m_pos(pos)
	CopMovement.set_m_pos(self, pos)
	self:_upd_location()
end

function TeamAIMovement:_upd_location()
	local nav_seg_id = self._nav_tracker:nav_segment()

	if self._standing_nav_seg_id ~= nav_seg_id then
		self._standing_nav_seg_id = nav_seg_id

		managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
	end
end

function TeamAIMovement:get_location_id()
	return managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id).location_id
end

function TeamAIMovement:on_discovered()
	if self._cool then
		self:_switch_to_not_cool()
	end
end

function TeamAIMovement:on_tase_ended()
	self._unit:character_damage():on_tase_ended()
end

function TeamAIMovement:tased()
	return self._unit:anim_data().tased
end

function TeamAIMovement:cool()
	return self._cool
end

function TeamAIMovement:downed()
	return self._unit:interaction()._active
end

function TeamAIMovement:set_cool(state)
	state = state and true or false

	if state == self._cool then
		return
	end

	local old_state = self._cool

	if state then
		self._cool = true

		if not self._heat_listener_clbk and Network:is_server() then
			self._heat_listener_clbk = "TeamAIMovement" .. tostring(self._unit:key())

			managers.groupai:state():add_listener(self._heat_listener_clbk, {
				"whisper_mode"
			}, callback(self, self, "heat_clbk"))
		end

		self._unit:base():set_slot(self._unit, 24)

		if self._unit:brain().on_cool_state_changed then
			self._unit:brain():on_cool_state_changed(true)
		end

		self:set_stance_by_code(1)
	else
		self._not_cool_t = TimerManager:game():time()

		self:_switch_to_not_cool(true)
	end
end

function TeamAIMovement:heat_clbk(whisper_state)
	if self._cool and not whisper_state then
		self:_switch_to_not_cool()
	end
end

function TeamAIMovement:_switch_to_not_cool(instant)
	if not Network:is_server() then
		return
	end

	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if instant then
		if self._switch_to_not_cool_clbk_id then
			managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id)
		end

		self._switch_to_not_cool_clbk_id = "dummy"

		self:_switch_to_not_cool_clbk_func()
	elseif not self._switch_to_not_cool_clbk_id then
		self._switch_to_not_cool_clbk_id = "switch_to_not_cool_clbk" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_switch_to_not_cool_clbk_func"), TimerManager:game():time() + math.random() * 1 + 0.5)
	end
end

function TeamAIMovement:_switch_to_not_cool_clbk_func()
	if self._switch_to_not_cool_clbk_id and self._cool then
		self._switch_to_not_cool_clbk_id = nil
		self._cool = false
		self._not_cool_t = TimerManager:game():time()

		self._unit:base():set_slot(self._unit, 16)

		if self._unit:brain()._logic_data and self._unit:brain():is_available_for_assignment() then
			self._unit:brain():set_objective()
			self._unit:movement():action_request({
				sync = true,
				body_part = 1,
				type = "idle"
			})
		end

		self:set_stance_by_code(2)
		self._unit:brain():on_cool_state_changed(false)
	end
end

function TeamAIMovement:zipline_unit()
	return nil
end

function TeamAIMovement:current_state_name()
	return nil
end

function TeamAIMovement:save(data)
	data.movement = {
		customization = nil,
		customization = self._customization
	}
end

function TeamAIMovement:pre_destroy()
	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._switch_to_not_cool_clbk_id then
		managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id)

		self._switch_to_not_cool_clbk_id = nil
	end

	if self._link_data then
		self._link_data.parent:base():remove_destroy_listener("CopMovement" .. tostring(unit:key()))
	end

	if alive(self._rope) then
		self._rope:base():retract()

		self._rope = nil
	end

	self:_destroy_gadgets()

	for i_action, action in ipairs(self._active_actions) do
		if action and action.on_destroy then
			action:on_destroy()
		end
	end

	if self._attention and self._attention.destroy_listener_key then
		self._attention.unit:base():remove_destroy_listener(self._attention.destroy_listener_key)

		self._attention.destroy_listener_key = nil
	end
end
