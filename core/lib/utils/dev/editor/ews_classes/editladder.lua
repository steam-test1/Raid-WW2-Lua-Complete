core:import("CoreEditorUtils")
core:import("CoreEws")

EditLadder = EditLadder or class(EditUnitBase)

function EditLadder:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Ladder",
		class = nil,
		class = self
	})
	self._panel = panel
	self._width_params = {
		panel = nil,
		ctrlr_proportions = 1,
		name_proportions = 1,
		min = 0,
		events = nil,
		tooltip = "Sets the width of the ladder in cm",
		floats = 0,
		value = 0,
		name = "Width [cm]:",
		sizer = nil,
		panel = panel,
		sizer = sizer,
		events = {
			{
				callback = nil,
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_width")
			},
			{
				callback = nil,
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_width")
			}
		}
	}

	CoreEws.number_controller(self._width_params)

	self._height_params = {
		panel = nil,
		ctrlr_proportions = 1,
		name_proportions = 1,
		min = 0,
		events = nil,
		tooltip = "Sets the height of the ladder in cm",
		floats = 0,
		value = 0,
		name = "Height [cm]:",
		sizer = nil,
		panel = panel,
		sizer = sizer,
		events = {
			{
				callback = nil,
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = callback(self, self, "_update_height")
			},
			{
				callback = nil,
				event = "EVT_KILL_FOCUS",
				callback = callback(self, self, "_update_height")
			}
		}
	}

	CoreEws.number_controller(self._height_params)
	panel:layout()
	panel:set_enabled(false)
end

function EditLadder:update(t, dt)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():debug_draw()
		end
	end
end

function EditLadder:_update_width(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_width(self._width_params.value)
		end
	end
end

function EditLadder:_update_height(params)
	for _, unit in ipairs(self._selected_units) do
		if unit:ladder() then
			unit:ladder():set_height(self._height_params.value)
		end
	end
end

function EditLadder:is_editable(unit, units)
	if alive(unit) and unit:ladder() then
		self._reference_unit = unit
		self._selected_units = units
		self._no_event = true

		CoreEws.change_entered_number(self._width_params, unit:ladder():width())
		CoreEws.change_entered_number(self._height_params, unit:ladder():height())

		self._no_event = false

		return true
	end

	self._selected_units = {}

	return false
end
