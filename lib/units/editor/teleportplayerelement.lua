TeleportPlayerElement = TeleportPlayerElement or class(MissionElement)

function TeleportPlayerElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.state = managers.player:default_player_state()

	table.insert(self._save_values, "state")
end

function TeleportPlayerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", managers.player:player_states(), "Select a state from the combobox")
	self:_add_help_text("The state the player will change to after teleportation")
end

function TeleportPlayerElement:add_to_mission_package()
	return
end
