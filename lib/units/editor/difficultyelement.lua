DifficultyUnitElement = DifficultyUnitElement or class(MissionElement)

function DifficultyUnitElement:init(unit)
	DifficultyUnitElement.super.init(self, unit)

	self._hed.difficulty = 0

	table.insert(self._save_values, "difficulty")
end

function DifficultyUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local difficulty_params = {
		ctrlr_proportions = 2,
		panel = nil,
		name_proportions = 1,
		max = 1,
		min = 0,
		tooltip = "Set the current difficulty in level",
		floats = 2,
		value = nil,
		sizer = nil,
		name = "Difficulty:",
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.difficulty
	}
	local difficulty = CoreEWS.number_controller(difficulty_params)

	difficulty:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		ctrlr = nil,
		value = "difficulty",
		ctrlr = difficulty
	})
	difficulty:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		ctrlr = nil,
		value = "difficulty",
		ctrlr = difficulty
	})

	local help = {
		text = "Set the current difficulty in the level. Affects what enemies will be spawned etc.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
