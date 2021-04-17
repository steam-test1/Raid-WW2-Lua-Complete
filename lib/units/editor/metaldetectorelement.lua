MetalDetectorElement = MetalDetectorElement or class(MissionElement)

-- Lines 3-9
function MetalDetectorElement:init(unit)
	MetalDetectorElement.super.init(self, unit)

	self._hed.is_metal_detector_object = true

	table.insert(self._save_values, "is_metal_detector_object")
end

-- Lines 11-16
function MetalDetectorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()
	self:_add_help_text("Place this metal detector object somewhere in the world.")
end
