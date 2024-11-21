FleePointElement = FleePointElement or class(MissionElement)
FleePointElement.SAVE_UNIT_ROTATION = false

function FleePointElement:init(unit)
	FleePointElement.super.init(self, unit)

	self._hed.functionality = "flee_point"
	self._hed.so_action = "none"
	self._hed.SO_access = tostring(tonumber("8FFFFFFF", 16))

	table.insert(self._save_values, "functionality")
	table.insert(self._save_values, "so_action")
	table.insert(self._save_values, "SO_access")

	self._enemies = {}
end

function FleePointElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "functionality", {
		"flee_point",
		"loot_drop"
	}, "Select the functionality of the point")

	local options = table.list_add({
		"none"
	}, clone(CopActionAct._act_redirects.SO))

	self:_build_value_combobox(panel, panel_sizer, "so_action", options, "Select a action that the unit should start with.")
	self:_build_value_combobox(panel, panel_sizer, "test_unit", managers.enemy:enemy_units(), "Select the unit to be used when testing.")
end

function FleePointElement:test_element()
	if not managers.navigation:is_data_ready() then
		EWS:message_box(Global.frame_panel, "Can't test flee point unit without ready navigation data (AI-graph)", "Flee point", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local spawn_unit_name = self._hed.test_unit or Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light")
	local enemy = safe_spawn_unit(spawn_unit_name, self._unit:position(), self._unit:rotation())

	if not enemy then
		return
	end

	table.insert(self._enemies, enemy)
	managers.groupai:state():set_char_team(enemy, tweak_data.levels:get_default_team_ID("non_combatant"))
	enemy:movement():set_root_blend(false)

	local t = {
		id = self._unit:unit_data().unit_id,
		editor_name = self._unit:unit_data().name_id,
		values = self:new_save_values()
	}
	t.values.use_instigator = true
	t.values.is_navigation_link = false
	t.values.is_alert_point = false
	t.values.followup_elements = nil
	t.values.spawn_instigator_ids = nil
	self._script = MissionScript:new({
		elements = {}
	})
	self._so_class = ElementFleePoint:new(self._script, t)
	self._so_class._values.align_position = nil
	self._so_class._values.align_rotation = nil

	self._so_class:on_executed(enemy)

	self._start_test_t = Application:time()
end

function FleePointElement:stop_test_element()
	for _, enemy in ipairs(self._enemies) do
		enemy:set_slot(0)
	end

	self._enemies = {}

	print("Stop test time", self._start_test_t and Application:time() - self._start_test_t or 0)
end
