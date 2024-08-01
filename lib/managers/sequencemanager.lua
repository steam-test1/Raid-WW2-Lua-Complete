core:module("SequenceManager")
core:import("CoreSequenceManager")
core:import("CoreClass")

SequenceManager = SequenceManager or class(CoreSequenceManager.SequenceManager)

-- Lines 9-23
function SequenceManager:init()
	SequenceManager.super.init(self, managers.slot:get_mask("body_area_damage"), managers.slot:get_mask("area_damage_blocker"), managers.slot:get_mask("unit_area_damage"))
	self:register_event_element_class(InteractionElement)
	self:register_event_element_class(AlertElement)
	self:register_event_element_class(AttentionElement)

	self._proximity_masks.players = managers.slot:get_mask("players")
	self._proximity_masks.enemies = managers.slot:get_mask("enemies")
end

-- Lines 26-33
function SequenceManager:update(t, dt)
	if managers.menu.loading_screen_visible then
		return
	end

	SequenceManager.super.update(self, t, dt)
end

-- Lines 35-48
function SequenceManager:on_level_transition()
	self._start_time_callback_list = {}
	self._startup_callback_map = {}
	self._callback_map = {}
	self._retry_callback_list = {}
	self._retry_callback_indices = {}
	self._area_damage_callback_map = {}
	self._last_start_time_callback_id = 0
	self._last_startup_callback_id = 0
	self._current_start_time_callback_index = 0
	self._last_callback_id = 0
	self._current_retry_callback_index = 0
	self._last_area_damage_callback_id = 0
end

InteractionElement = InteractionElement or class(CoreSequenceManager.BaseElement)
InteractionElement.NAME = "interaction"

-- Lines 54-58
function InteractionElement:init(node, unit_element)
	InteractionElement.super.init(self, node, unit_element)

	self._enabled = self:get("enabled")
end

-- Lines 60-65
function InteractionElement:activate_callback(env)
	local enabled = self:run_parsed_func(env, self._enabled)

	if env.dest_unit:interaction() then
		env.dest_unit:interaction():set_active(enabled)
	end
end

AlertElement = AlertElement or class(CoreSequenceManager.BaseElement)
AlertElement.NAME = "alert"

-- Lines 71-76
function AlertElement:init(node, unit_element)
	AlertElement.super.init(self, node, unit_element)

	self._obj_name = self:get("object_name")
	self._range = self:get("range")
end

-- Lines 78-95
function AlertElement:activate_callback(env)
	local pos = nil

	if self._obj_name then
		local obj_name = self:run_parsed_func(env, self._obj_name)
		pos = env.dest_unit:get_object(obj_name:id()).pos
	else
		pos = env.pos
	end

	local new_alert = {
		"aggression",
		pos,
		self._range or 1200,
		managers.groupai:state():get_unit_type_filter("civilians_enemies"),
		env.dest_unit
	}

	managers.groupai:state():propagate_alert(new_alert)
end

AttentionElement = AttentionElement or class(CoreSequenceManager.BaseElement)
AttentionElement.NAME = "attention"

-- Lines 101-108
function AttentionElement:init(node, unit_element)
	AlertElement.super.init(self, node, unit_element)

	self._preset_name = self:get("preset_name")
	self._operation = self:get("operation")
	self._giveaway = self:get("giveaway")
	self._obj_name = self:get("object_name")
end

-- Lines 110-131
function AttentionElement:activate_callback(env)
	local operation = self:run_parsed_func(env, self._operation)
	local preset_name = self:run_parsed_func(env, self._preset_name)
	local giveaway = self:run_parsed_func(env, self._giveaway)
	local obj_name = self:run_parsed_func(env, self._obj_name)

	if not env.dest_unit:attention() then
		_G.debug_pause_unit(env.dest_unit, "AttentionElement:activate_callback: unit missing attention extension", env.dest_unit)
	elseif operation == "add" then
		local attention_setting = _G.PlayerMovement._create_attention_setting_from_descriptor(self, _G.tweak_data.attention.settings[preset_name], preset_name)
		attention_setting.giveaway = giveaway

		env.dest_unit:attention():add_attention(attention_setting)

		if obj_name then
			env.dest_unit:attention():set_detection_object_name(obj_name)
		end
	elseif operation == "remove" then
		env.dest_unit:attention():remove_attention(preset_name)
	else
		_G.debug_pause_unit(env.dest_unit, "AttentionElement:activate_callback: operation not 'add' nor 'remove'", operation, env.dest_unit)
	end
end

CoreClass.override_class(CoreSequenceManager.SequenceManager, SequenceManager)
