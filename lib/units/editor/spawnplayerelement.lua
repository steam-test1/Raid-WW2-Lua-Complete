SpawnPlayerElement = SpawnPlayerElement or class(MissionElement)

-- Lines 3-11
function SpawnPlayerElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.state = managers.player:default_player_state()
	self._hed.use_for_teleport = true

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "use_for_teleport")
end

-- Lines 13-22
function SpawnPlayerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", managers.player:player_states(), "Select a state from the combobox")
	self:_build_value_checkbox(panel, panel_sizer, "use_for_teleport", "Use for teleport")
	self:_add_help_text("The state defines how the player will be spawned/teleported")
end

-- Lines 24-26
function SpawnPlayerElement:add_to_mission_package()
end
