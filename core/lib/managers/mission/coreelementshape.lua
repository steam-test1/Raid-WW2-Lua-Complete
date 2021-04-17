local tmp_vec1 = Vector3()

core:module("CoreElementShape")
core:import("CoreShapeManager")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementShape = ElementShape or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 11-27
function ElementShape:init(...)
	ElementShape.super.init(self, ...)

	self._shapes = {}

	if not self._values.shape_type or self._values.shape_type == "box" then
		self:_add_shape(CoreShapeManager.ShapeBoxMiddle:new({
			position = self._values.position,
			rotation = self._values.rotation,
			width = self._values.width,
			depth = self._values.depth,
			height = self._values.height
		}))
	elseif self._values.shape_type == "cylinder" then
		self:_add_shape(CoreShapeManager.ShapeCylinderMiddle:new({
			position = self._values.position,
			rotation = self._values.rotation,
			height = self._values.height,
			radius = self._values.radius
		}))
	elseif self._values.shape_type == "unit" then
		self._shape_units = {}

		for _, id in ipairs(self._values.unit_ids) do
			local unit = Application:editor() and managers.editor:layer("Statics"):created_units_pairs()[id] or self._mission_script:worlddefinition():get_unit_by_id(id)

			table.insert(self._shape_units, unit)
		end
	end
end

-- Lines 29-31
function ElementShape:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 33-35
function ElementShape:_add_shape(shape)
	table.insert(self._shapes, shape)
end

-- Lines 37-39
function ElementShape:get_shapes()
	return self._shapes
end

-- Lines 41-66
function ElementShape:is_inside(pos)
	for _, shape in ipairs(self._shapes) do
		if shape:is_inside(pos) then
			return true
		end
	end

	if self._shape_units then
		for _, unit in ipairs(self._shape_units) do
			local data = unit:unit_data()
			local oobb = nil

			if data and data._object_oobb then
				local object = unit:get_object(Idstring(data._object_oobb))
				oobb = object:oobb()
			else
				oobb = unit:oobb()
			end

			local grow = self._values.grow or 0

			oobb:grow(grow)

			if oobb:point_inside(pos) then
				return true
			end
		end
	end

	return false
end

-- Lines 68-70
function ElementShape:client_on_executed(...)
end

-- Lines 72-78
function ElementShape:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementShape.super.on_executed(self, instigator)
end
