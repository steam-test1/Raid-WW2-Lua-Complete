CivilianBrain = CivilianBrain or class(CopBrain)
CivilianBrain.set_attention_settings = PlayerMovement.set_attention_settings

function CivilianBrain:init(unit)
	self._unit = unit
	self._timer = TimerManager:game()

	self:set_update_enabled_state(false)

	self._current_logic = nil
	self._current_logic_name = nil
	self._active = true
	self._SO_access = managers.navigation:convert_access_flag(tweak_data.character[unit:base()._tweak_table].access)
	self._slotmask_enemies = managers.slot:get_mask("criminals")
	CopBrain._reload_clbks[unit:key()] = callback(self, self, "on_reload")
end

function CivilianBrain:_reset_logic_data()
	CopBrain._reset_logic_data(self)

	self._logic_data.enemy_slotmask = nil
	self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_civilian_objective_complete")
	self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_civilian_objective_failed")
end

function CivilianBrain:on_cool_state_changed(state)
	if self._logic_data then
		self._logic_data.cool = state
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)
	else
		self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
	end

	local alert_listen_filter, alert_types = nil

	if state then
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminals_enemies_civilians")
		alert_types = {
			aggression = true,
			vo_distress = true,
			vo_intimidate = true,
			vo_cbt = true,
			bullet = true,
			footstep = true,
			explosion = true
		}
	else
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminal")
		alert_types = {
			bullet = true
		}
	end

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())
end

function CivilianBrain:set_objective(new_objective)
	if new_objective and new_objective.type == "free" and self._unit:escort() then
		new_objective = {
			type = "escort"
		}
	end

	CivilianBrain.super.set_objective(self, new_objective)
end
