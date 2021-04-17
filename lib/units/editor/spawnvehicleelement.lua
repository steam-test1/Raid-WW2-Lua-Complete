SpawnVehicleElement = SpawnVehicleElement or class(MissionElement)

-- Lines 3-22
function SpawnVehicleElement:init(unit)
	Application:trace("SpawnVehicleElement:init", unit)
	MissionElement.init(self, unit)

	self._vehicle_names = {}

	for k, v in pairs(tweak_data.vehicle) do
		if v.unit then
			table.insert_sorted(self._vehicle_names, k)
		end
	end

	self._hed.state = VehicleDrivingExt.STATE_INACTIVE
	self._hed.vehicle = self._vehicle_names[1]

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "vehicle")
end

-- Lines 24-33
function SpawnVehicleElement:_build_panel(panel, panel_sizer)
	Application:trace("SpawnVehicleElement:_build_panel")
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "vehicle", self._vehicle_names, "Select a vehicle from the combobox")
	self:_add_help_text("The vehicle that will be spawned")
end

-- Lines 35-38
function SpawnVehicleElement:add_to_mission_package()
	Application:trace("SpawnVehicleElement:add_to_mission_package")
end
