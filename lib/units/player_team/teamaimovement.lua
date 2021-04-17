TeamAIMovement = TeamAIMovement or class(CopMovement)
TeamAIMovement._char_name_to_index = HuskPlayerMovement._char_name_to_index
TeamAIMovement._char_model_names = HuskPlayerMovement._char_model_names

-- Lines 7-21
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

-- Lines 25-40
function TeamAIMovement:set_character_anim_variables()
	HuskPlayerMovement.set_character_anim_variables(self)
end

-- Lines 42-43
function TeamAIMovement:check_visual_equipment()
end

-- Lines 47-49
function TeamAIMovement:m_detect_pos()
	return self._m_head_pos
end

-- Lines 53-56
function TeamAIMovement:set_position(pos)
	CopMovement.set_position(self, pos)
	self:_upd_location()
end

-- Lines 60-63
function TeamAIMovement:set_m_pos(pos)
	CopMovement.set_m_pos(self, pos)
	self:_upd_location()
end

-- Lines 67-73
function TeamAIMovement:_upd_location()
	local nav_seg_id = self._nav_tracker:nav_segment()

	if self._standing_nav_seg_id ~= nav_seg_id then
		self._standing_nav_seg_id = nav_seg_id

		managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
	end
end

-- Lines 77-79
function TeamAIMovement:get_location_id()
	return managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id).location_id
end

-- Lines 83-87
function TeamAIMovement:on_cuffed()
	self._unit:brain():set_logic("surrender")
	self._unit:network():send("arrested")
	self._unit:character_damage():on_arrested()
end

-- Lines 91-95
function TeamAIMovement:on_discovered()
	if self._cool then
		self:_switch_to_not_cool()
	end
end

-- Lines 99-101
function TeamAIMovement:on_tase_ended()
	self._unit:character_damage():on_tase_ended()
end

-- Lines 105-107
function TeamAIMovement:tased()
	return self._unit:anim_data().tased
end

-- Lines 111-113
function TeamAIMovement:cool()
	return self._cool
end

-- Lines 117-119
function TeamAIMovement:downed()
	return self._unit:interaction()._active
end

-- Lines 123-153
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

-- Lines 157-161
function TeamAIMovement:heat_clbk(state)
	if self._cool and not state then
		self:_switch_to_not_cool()
	end
end

-- Lines 165-185
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

-- Lines 189-203
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

-- Lines 207-209
function TeamAIMovement:zipline_unit()
	return nil
end

-- Lines 211-213
function TeamAIMovement:current_state_name()
	return nil
end

-- Lines 217-252
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
