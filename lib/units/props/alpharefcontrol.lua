AlphaRefControl = AlphaRefControl or class()
local ids_alpha_ref = Idstring("alpha_ref")

-- Lines 5-24
function AlphaRefControl:init(unit)
	self._unit = unit
	self._materials = {}
	local materials = self._unit:get_objects_by_type(Idstring("material"))

	for _, material in ipairs(materials) do
		if material:variable_exists(ids_alpha_ref) then
			local ids_mat_name = material:name()
			local mat_table = {}

			table.insert(mat_table, material)
			table.insert(mat_table, 0)
			table.insert(mat_table, true)
			table.insert(self._materials, mat_table)
		end
	end

	if next(self._materials) == nil then
		Application:error("[AlphaRefControl:init] Unit needs at least one material with alpha_ref")
	end
end

-- Lines 26-36
function AlphaRefControl:update(unit, t, dt)
	for _, data in pairs(self._materials) do
		if not data[3] then
			local material = data[1]
			local alpha_ref = material:get_variable(ids_alpha_ref)
			alpha_ref = alpha_ref + dt * data[2]

			material:set_variable(ids_alpha_ref, alpha_ref)
		end
	end
end

-- Lines 38-48
function AlphaRefControl:play(material_name, speed)
	local ids_material_name = Idstring(material_name)

	for _, data in pairs(self._materials) do
		if data[1]:name() == ids_material_name then
			data[2] = speed
			data[3] = false

			break
		end
	end
end

-- Lines 51-61
function AlphaRefControl:stop(material_name)
	local ids_material_name = Idstring(material_name)

	for _, data in pairs(self._materials) do
		if data[1]:name() == ids_material_name then
			data[2] = 0
			data[3] = true

			break
		end
	end
end

-- Lines 64-73
function AlphaRefControl:pause(material_name)
	local ids_material_name = Idstring(material_name)

	for _, data in pairs(self._materials) do
		if data[1]:name() == ids_material_name then
			data[3] = true

			break
		end
	end
end

-- Lines 76-85
function AlphaRefControl:set_alpha_ref(material_name, alpha_ref)
	local ids_material_name = Idstring(material_name)

	for _, data in pairs(self._materials) do
		if data[1]:name() == ids_material_name then
			data[1]:set_variable(ids_alpha_ref, alpha_ref)

			break
		end
	end
end
