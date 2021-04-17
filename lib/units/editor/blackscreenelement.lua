BlackscreenElement = BlackscreenElement or class(MissionElement)

-- Lines 3-13
function BlackscreenElement:init(unit)
	BlackscreenElement.super.init(self, unit)

	self._hed.action = "fade_in"
	self._hed.level = "generic"
	self._hed.skip_delete_brushes = false

	table.insert(self._save_values, "action")
	table.insert(self._save_values, "level")
	table.insert(self._save_values, "skip_delete_brushes")
end

-- Lines 15-23
function BlackscreenElement:set_element_data(params, ...)
	BlackscreenElement.super.set_element_data(self, params, ...)
	Application:trace(inspect(self._hed.level))

	if params.value == "action" then
		self:_set_action()
	end
end

-- Lines 25-29
function BlackscreenElement:_set_action()
	local action = self._hed.action

	self._level:set_enabled(action == "fade_in")
end

-- Lines 32-48
function BlackscreenElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local loading_screens = {}
	local all_screens = tweak_data.operations:get_all_loading_screens()

	for level, data in pairs(all_screens) do
		table.insert(loading_screens, level)
	end

	self._action = self:_build_value_combobox(panel, panel_sizer, "action", {
		"fade_in",
		"fade_out",
		"fade_to_black"
	})
	self._level = self:_build_value_combobox(panel, panel_sizer, "level", loading_screens)
end
