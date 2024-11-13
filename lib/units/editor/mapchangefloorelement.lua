MapChangeFloorElement = MapChangeFloorElement or class(MissionElement)

function MapChangeFloorElement:init(unit)
	MapChangeFloorElement.super.init(self, unit)

	self._hed.floor = 1

	table.insert(self._save_values, "floor")
end

function MapChangeFloorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local floor, floor_params = self:_build_value_number(panel, panel_sizer, "floor", {
		floats = 0,
		min = 1
	}, "Sets the map floor.")

	floor_params.name_ctrlr:set_label("Floor:")

	self._floor_params = floor_params
end
