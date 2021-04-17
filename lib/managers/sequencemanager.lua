core:module("SequenceManager")
core:import("CoreSequenceManager")
core:import("CoreClass")

SequenceManager = SequenceManager or class(CoreSequenceManager.SequenceManager)

-- Lines 8-15
function SequenceManager:init()
	SequenceManager.super.init(self, managers.slot:get_mask("body_area_damage"), managers.slot:get_mask("area_damage_blocker"), managers.slot:get_mask("unit_area_damage"))
	self:register_event_element_class(InteractionElement)

	self._proximity_masks.players = managers.slot:get_mask("players")
end

-- Lines 17-30
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

-- Lines 35-39
function InteractionElement:init(node, unit_element)
	InteractionElement.super.init(self, node, unit_element)

	self._enabled = self:get("enabled")
end

-- Lines 41-48
function InteractionElement:activate_callback(env)
	local enabled = self:run_parsed_func(env, self._enabled)

	if env.dest_unit:interaction() then
		env.dest_unit:interaction():set_active(enabled)
	else
		Application:error("Unit " .. tostring(env.dest_unit:name()) .. " doesn't have the interaction extension.")
	end
end

CoreClass.override_class(CoreSequenceManager.SequenceManager, SequenceManager)
