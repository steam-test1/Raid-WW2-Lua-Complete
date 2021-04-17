BarrageUnitElement = BarrageUnitElement or class(MissionElement)
BarrageUnitElement.SAVE_UNIT_POSITION = false
BarrageUnitElement.SAVE_UNIT_ROTATION = false

-- Lines 6-15
function BarrageUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.operation = "start"
	self._hed.type = "default"

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "type")
end

-- Lines 20-28
function BarrageUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"start",
		"stop",
		"set_spotter_type"
	})
	self:_build_value_combobox(panel, panel_sizer, "type", tweak_data.barrage:get_barrage_ids())
end
