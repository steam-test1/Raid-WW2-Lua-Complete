core:import("CoreEditorUtils")
core:import("CoreUnit")

SpawnCivilianUnitElement = SpawnCivilianUnitElement or class(MissionElement)
SpawnCivilianUnitElement.USES_POINT_ORIENTATION = true
SpawnCivilianUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "enemy",
		type = "civilian"
	},
	{
		value = "state",
		type = "civilian_spawn_state"
	}
}
SpawnCivilianUnitElement._options = {
	"units/vanilla/characters/enemies/models/german_grunt_light_test/german_grunt_light_test",
	"units/vanilla/characters/enemies/models/soviet_nightwitch_01/soviet_nightwitch_01",
	"units/vanilla/characters/enemies/models/soviet_nightwitch_02/soviet_nightwitch_02",
	"units/vanilla/characters/enemies/models/female_spy/female_spy",
	"units/vanilla/characters/enemies/models/male_spy/male_spy"
}

-- Lines 16-31
function SpawnCivilianUnitElement:init(unit)
	SpawnCivilianUnitElement.super.init(self, unit)

	self._enemies = {}
	self._states = CopActionAct._act_redirects.civilian_spawn
	self._hed.state = "none"
	self._hed.enemy = "units/vanilla/characters/enemies/models/german_grunt_light_test/german_grunt_light_test"
	self._hed.force_pickup = "none"
	self._hed.team = "default"

	table.insert(self._save_values, "enemy")
	table.insert(self._save_values, "state")
	table.insert(self._save_values, "force_pickup")
	table.insert(self._save_values, "team")
end

-- Lines 33-36
function SpawnCivilianUnitElement:post_init(...)
	SpawnCivilianUnitElement.super.post_init(self, ...)
	self:_load_pickup()
end

-- Lines 38-40
function SpawnCivilianUnitElement:_get_enemy()
	return self._hed.enemy
end

-- Lines 42-44
function SpawnCivilianUnitElement:test_element()
	SpawnEnemyUnitElement.test_element(self)
end

-- Lines 46-48
function SpawnCivilianUnitElement:get_spawn_anim()
	return self._hed.state
end

-- Lines 50-59
function SpawnCivilianUnitElement:stop_test_element()
	for _, enemy in ipairs(self._enemies) do
		if enemy:base() and enemy:base().set_slot then
			enemy:base():set_slot(enemy, 0)
		else
			enemy:set_slot(0)
		end
	end

	self._enemies = {}
end

-- Lines 61-66
function SpawnCivilianUnitElement:set_element_data(params, ...)
	SpawnCivilianUnitElement.super.set_element_data(self, params, ...)

	if params.value == "force_pickup" then
		self:_load_pickup()
	end
end

-- Lines 68-73
function SpawnCivilianUnitElement:_reload_unit_list_btn()
	self:stop_test_element()

	if self._hed.enemy ~= "none" then
		managers.editor:reload_units({
			Idstring(self._hed.enemy)
		}, true, true)
	end
end

-- Lines 75-102
function SpawnCivilianUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local enemy_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(enemy_sizer, 0, 0, "EXPAND")
	self:_build_value_combobox(panel, enemy_sizer, "enemy", self._options, nil, nil, {
		horizontal_sizer_proportions = 1
	})

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_UNIT_LIST", "Reload unit", CoreEws.image_path("toolbar\\refresh_16x16.png"), nil)
	toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_reload_unit_list_btn"), nil)
	toolbar:realize()
	enemy_sizer:add(toolbar, 0, 0, "EXPAND,LEFT")
	self:_build_value_combobox(panel, panel_sizer, "state", table.list_add(self._states, {
		"none"
	}))

	local pickups = table.map_keys(tweak_data.pickups)

	table.insert(pickups, "none")
	self:_build_value_combobox(panel, panel_sizer, "force_pickup", pickups)
	self:_build_value_combobox(panel, panel_sizer, "team", table.list_add({
		"default"
	}, tweak_data.levels:get_team_names_indexed()), "Select the character's team.")
end

-- Lines 104-109
function SpawnCivilianUnitElement:_load_pickup()
	if self._hed.force_pickup ~= "none" then
		local unit_name = tweak_data.pickups[self._hed.force_pickup].unit

		CoreUnit.editor_load_unit(unit_name)
	end
end

-- Lines 111-123
function SpawnCivilianUnitElement:add_to_mission_package()
	if self._hed.force_pickup ~= "none" then
		local unit_name = tweak_data.pickups[self._hed.force_pickup].unit

		managers.editor:add_to_world_package({
			category = "units",
			name = unit_name:s(),
			continent = self._unit:unit_data().continent
		})

		local sequence_files = {}

		CoreEditorUtils.get_sequence_files_by_unit_name(unit_name, sequence_files)

		for _, file in ipairs(sequence_files) do
			managers.editor:add_to_world_package({
				init = true,
				category = "script_data",
				name = file:s() .. ".sequence_manager",
				continent = self._unit:unit_data().continent
			})
		end
	end
end

-- Lines 125-131
function SpawnCivilianUnitElement:_resolve_team(unit)
	if self._hed.team == "default" then
		return tweak_data.levels:get_default_team_ID("non_combatant")
	else
		return self._hed.team
	end
end

-- Lines 133-136
function SpawnCivilianUnitElement:destroy(...)
	SpawnCivilianUnitElement.super.destroy(self, ...)
	self:stop_test_element()
end
