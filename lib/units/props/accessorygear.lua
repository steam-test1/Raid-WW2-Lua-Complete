AccessoryGear = AccessoryGear or class()
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")

function AccessoryGear:init(unit)
	self._unit = unit

	self:_setup_contours()
end

function AccessoryGear:_setup_contours()
	self._contour_materials = {}
	local all_materials = self._unit:get_objects_by_type(IDS_MATERIAL)

	for _, m in ipairs(all_materials) do
		if m:variable_exists(idstr_contour_color) then
			table.insert(self._contour_materials, m)
			m:set_variable(idstr_contour_color, Vector3(0, 0, 0))
			m:set_variable(idstr_contour_opacity, 0)
		end
	end
end
