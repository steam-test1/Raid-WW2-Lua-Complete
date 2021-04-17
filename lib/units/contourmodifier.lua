ContourModifier = ContourModifier or class()
local ids_contour_opacity = Idstring("contour_opacity")

-- Lines 5-7
function ContourModifier:init(unit)
	self._unit = unit
end

-- Lines 9-12
function ContourModifier:turn_off(material_name)
	local material = self._unit:material(Idstring(material_name))

	material:set_variable(ids_contour_opacity, 0)
end

-- Lines 14-17
function ContourModifier:turn_on(material_name)
	local material = self._unit:material(Idstring(material_name))

	material:set_variable(ids_contour_opacity, 1)
end
