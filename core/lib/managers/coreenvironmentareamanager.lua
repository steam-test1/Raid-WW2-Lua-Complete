core:module("CoreEnvironmentAreaManager")
core:import("CoreShapeManager")
core:import("CoreEnvironmentFeeder")

EnvironmentAreaManager = EnvironmentAreaManager or class()
EnvironmentAreaManager.POSITION_OFFSET = 50

-- Lines 10-25
function EnvironmentAreaManager:init()
	self._areas = {}
	self._blocks = 0

	self:set_default_transition_time(0.1)
	self:set_default_bezier_curve({
		0,
		0,
		1,
		1
	})

	local default_filter_list = {}

	for name, data_path_key_list in pairs(managers.viewport:get_predefined_environment_filter_map()) do
		for _, data_path_key in ipairs(data_path_key_list) do
			table.insert(default_filter_list, data_path_key)
		end
	end

	self._default_filter_list = default_filter_list
end

-- Lines 27-29
function EnvironmentAreaManager:set_default_transition_time(time)
	self._default_transition_time = time
end

-- Lines 31-33
function EnvironmentAreaManager:default_transition_time()
	return self._default_transition_time
end

-- Lines 35-37
function EnvironmentAreaManager:set_default_bezier_curve(bezier_curve)
	self._default_bezier_curve = bezier_curve
end

-- Lines 39-41
function EnvironmentAreaManager:default_bezier_curve()
	return self._default_bezier_curve
end

-- Lines 43-49
function EnvironmentAreaManager:default_filter_list()
	if self._default_filter_list then
		return table.list_copy(self._default_filter_list)
	else
		return nil
	end
end

-- Lines 51-53
function EnvironmentAreaManager:default_prio()
	return 100
end

-- Lines 55-57
function EnvironmentAreaManager:areas()
	return self._areas
end

-- Lines 59-65
function EnvironmentAreaManager:get_area_by_name(name)
	for _, area in ipairs(self._areas) do
		if area:name() == name then
			return area
		end
	end
end

-- Lines 67-73
function EnvironmentAreaManager:add_area(area_params, world_id)
	local area = EnvironmentArea:new(area_params)
	area._world_id = world_id

	table.insert(self._areas, area)
	self:prio_order_areas()

	return area
end

-- Lines 75-77
function EnvironmentAreaManager:prio_order_areas()
	table.sort(self._areas, function (a, b)
		return a:is_higher_prio(b:prio())
	end)
end

-- Lines 79-84
function EnvironmentAreaManager:remove_area(area)
	for _, vp in ipairs(managers.viewport:viewports()) do
		vp:on_environment_area_removed(area)
	end

	table.delete(self._areas, area)
end

-- Lines 86-90
function EnvironmentAreaManager:remove_all_areas()
	while #self._areas > 0 do
		self:remove_area(self._areas[1])
	end
end

-- Lines 92-98
function EnvironmentAreaManager:remove_all_areas_for_world(world_id)
	for i = #self._areas, 1, -1 do
		if self._areas[i]._world_id == world_id then
			self:remove_area(self._areas[i])
		end
	end
end

-- Lines 100-109
function EnvironmentAreaManager:update(t, dt)
	local vps = managers.viewport:all_really_active_viewports()

	for _, vp in ipairs(vps) do
		if self._blocks > 0 then
			return
		end

		vp:update_environment_area(self._areas, self.POSITION_OFFSET)
	end
end

-- Lines 112-121
function EnvironmentAreaManager:environment_at_position(pos)
	local environment = managers.viewport:default_environment()

	for _, area in ipairs(self._areas) do
		if area:is_inside(pos) then
			environment = area:environment()

			break
		end
	end

	return environment
end

-- Lines 123-125
function EnvironmentAreaManager:add_block()
	self._blocks = self._blocks + 1
end

-- Lines 127-129
function EnvironmentAreaManager:remove_block()
	self._blocks = self._blocks - 1
end

EnvironmentArea = EnvironmentArea or class(CoreShapeManager.ShapeBox)

-- Lines 135-146
function EnvironmentArea:init(params)
	params.type = "box"

	EnvironmentArea.super.init(self, params)

	self._properties.name = params.name
	self._properties.environment = params.environment or managers.viewport:game_default_environment()
	self._properties.permanent = params.permanent or false
	self._properties.transition_time = params.transition_time or managers.environment_area:default_transition_time()
	self._properties.bezier_curve = params.bezier_curve or managers.environment_area:default_bezier_curve()
	self._properties.filter_list = managers.environment_area:default_filter_list()
	self._properties.prio = params.prio or managers.environment_area:default_prio()

	self:_generate_id()
end

-- Lines 148-150
function EnvironmentArea:name()
	return self._properties.name
end

-- Lines 152-160
function EnvironmentArea:_generate_id()
	local filter_list_id = ""

	if self._properties.filter_list then
		for _, data_path_key in pairs(self._properties.filter_list) do
			filter_list_id = filter_list_id .. "," .. data_path_key
		end
	end

	self._id = (self._properties.environment .. filter_list_id):key()
end

-- Lines 162-170
function EnvironmentArea:save_level_data()
	local unit = self:unit()

	if unit then
		self._properties.name = self._unit:unit_data().name_id
	end

	return EnvironmentArea.super.save_level_data(self)
end

-- Lines 172-180
function EnvironmentArea:set_unit(unit)
	EnvironmentArea.super.set_unit(self, unit)

	if unit and self._properties.name then
		return self._properties.name
	else
		return nil
	end
end

-- Lines 182-184
function EnvironmentArea:id()
	return self._id
end

-- Lines 186-188
function EnvironmentArea:environment()
	return self:property("environment")
end

-- Lines 190-193
function EnvironmentArea:set_environment(environment)
	self:set_property_string("environment", environment)
	self:_generate_id()
end

-- Lines 195-197
function EnvironmentArea:permanent()
	return self:property("permanent")
end

-- Lines 199-201
function EnvironmentArea:set_permanent(permanent)
	self._properties.permanent = permanent
end

-- Lines 203-205
function EnvironmentArea:transition_time()
	return self:property("transition_time")
end

-- Lines 207-209
function EnvironmentArea:set_transition_time(time)
	self._properties.transition_time = time
end

-- Lines 211-213
function EnvironmentArea:bezier_curve()
	return self:property("bezier_curve")
end

-- Lines 215-217
function EnvironmentArea:set_bezier_curve(bezier_curve)
	self._properties.bezier_curve = bezier_curve
end

-- Lines 219-221
function EnvironmentArea:filter_list()
	return self:property("filter_list")
end

-- Lines 223-226
function EnvironmentArea:set_filter_list(filter_list)
	self._properties.filter_list = filter_list

	self:_generate_id()
end

-- Lines 228-230
function EnvironmentArea:prio()
	return self:property("prio")
end

-- Lines 232-237
function EnvironmentArea:set_prio(prio)
	if self._properties.prio ~= prio then
		self._properties.prio = prio

		managers.environment_area:prio_order_areas()
	end
end

-- Lines 239-245
function EnvironmentArea:is_higher_prio(min_prio)
	if min_prio then
		return self._properties.prio < min_prio
	else
		return true
	end
end
