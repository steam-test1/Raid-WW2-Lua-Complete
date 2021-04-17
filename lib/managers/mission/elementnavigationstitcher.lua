core:import("CoreShapeManager")
core:import("CoreMissionScriptElement")

ElementNavigationStitcher = ElementNavigationStitcher or class(CoreMissionScriptElement.MissionScriptElement)

function ElementNavigationStitcher:init(...)
	ElementNavigationStitcher.super.init(self, ...)

	local unit = managers.worldcollection:get_unit_with_id(self._id, nil, self._sync_id)
end

function ElementNavigationStitcher:on_script_activated()
	self._on_script_activated_done = true

	self._mission_script:add_save_state_cb(self._id)
end

function ElementNavigationStitcher:set_enabled(enabled)
	ElementNavigationStitcher.super.set_enabled(self, enabled)
end

function ElementNavigationStitcher:on_executed(instigator, ...)
	if not self._values.enabled then
		return
	end

	ElementNavigationStitcher.super.on_executed(self, instigator, ...)
end

function ElementNavigationStitcher:pre_destroy()
	self:tear()
end

function ElementNavigationStitcher:debug_draw()
	if not self._debug_shape then
		self._debug_shape = CoreShapeManager.ShapeBoxMiddle:new({
			position = self._values.position,
			rotation = self._values.rotation,
			width = self._values.width,
			depth = self._values.depth,
			height = self._values.height
		})
	end

	self._debug_shape:draw(0, 0, 0.2, 0.2, 0.8, 0.3)
end

function ElementNavigationStitcher:_snap_to_grid(coord)
	coord = coord + self._grid_size / 2

	return coord - coord % self._grid_size
end

function ElementNavigationStitcher:_snap_pos_to_grid(pos)
	mvector3.set_x(pos, self:_snap_to_grid(pos.x))
	mvector3.set_y(pos, self:_snap_to_grid(pos.y))
end

function ElementNavigationStitcher:_calculate_extents()
	local x_half_extent = self._values.width / 2 * self._values.rotation:x()
	local y_half_extent = self._values.depth / 2 * self._values.rotation:y()
	local pos = self._values.position
	self._extents = {
		top_left = pos - x_half_extent + y_half_extent,
		top_right = pos + x_half_extent + y_half_extent,
		bottom_left = pos - x_half_extent - y_half_extent,
		bottom_right = pos + x_half_extent - y_half_extent,
		height = pos.z
	}

	self:_snap_pos_to_grid(self._extents.top_left)
	self:_snap_pos_to_grid(self._extents.top_right)
	self:_snap_pos_to_grid(self._extents.bottom_left)
	self:_snap_pos_to_grid(self._extents.bottom_right)

	self._extents.aabb = {
		min_x = math.min(math.min(self._extents.top_left.x, self._extents.top_right.x), math.min(self._extents.bottom_left.x, self._extents.bottom_right.x)),
		min_y = math.min(math.min(self._extents.top_left.y, self._extents.top_right.y), math.min(self._extents.bottom_left.y, self._extents.bottom_right.y)),
		max_x = math.max(math.max(self._extents.top_left.x, self._extents.top_right.x), math.max(self._extents.bottom_left.x, self._extents.bottom_right.x)),
		max_y = math.max(math.max(self._extents.top_left.y, self._extents.top_right.y), math.max(self._extents.bottom_left.y, self._extents.bottom_right.y))
	}
end

function ElementNavigationStitcher:_create_nav_data()
	self._nav_data = {
		version = 6,
		door_high_pos = {},
		door_low_pos = {},
		door_high_quads = {},
		door_low_quads = {},
		helper_blockers = {},
		quad_borders_x_pos = {},
		quad_borders_x_neg = {},
		quad_borders_y_pos = {},
		quad_borders_y_neg = {},
		quad_heights_xp_yp = {},
		quad_heights_xp_yn = {},
		quad_heights_xn_yp = {},
		quad_heights_xn_yn = {},
		segments = {}
	}
	self._nav_data.segments[1] = {
		location_id = "location_unknown",
		id = 1,
		position = self._values.position,
		pos = self._values.position,
		vis_groups = {}
	}
	self._nav_data.segments[1].vis_groups[1] = 1
	self._nav_data.segments[1].unique_id = managers.navigation:get_segment_unique_id(self._world_id, 1)
	self._nav_data.visibility_groups = {
		{
			pos = self._values.position,
			quads = {},
			visible_groups = {}
		}
	}
	self._nav_data.parent_world_id = self._sync_id
end

function ElementNavigationStitcher:_create_quad(x, y)
	table.insert(self._nav_data.quad_borders_x_pos, math.round(self:_snap_to_grid(x + self._grid_size / 2) / self._grid_size))
	table.insert(self._nav_data.quad_borders_x_neg, math.round(self:_snap_to_grid(x - self._grid_size / 2) / self._grid_size))
	table.insert(self._nav_data.quad_borders_y_pos, math.round(self:_snap_to_grid(y + self._grid_size / 2) / self._grid_size))
	table.insert(self._nav_data.quad_borders_y_neg, math.round(self:_snap_to_grid(y - self._grid_size / 2) / self._grid_size))
	table.insert(self._nav_data.quad_heights_xp_yp, self._extents.height + 0.9)
	table.insert(self._nav_data.quad_heights_xp_yn, self._extents.height + 0.9)
	table.insert(self._nav_data.quad_heights_xn_yp, self._extents.height + 0.9)
	table.insert(self._nav_data.quad_heights_xn_yn, self._extents.height + 0.9)

	local i_quad = #self._nav_data.quad_borders_x_pos

	table.insert(self._nav_data.visibility_groups[1].quads, i_quad)

	return i_quad
end

function ElementNavigationStitcher:_create_top_door(i_x, i_y, z)
	local i_top_quad = self._quad_grid[i_y - 1][i_x]
	local i_bottom_quad = self._quad_grid[i_y][i_x]
	local xp = self._nav_data.quad_borders_x_pos[i_top_quad]
	local xn = self._nav_data.quad_borders_x_neg[i_top_quad]
	local yn = self._nav_data.quad_borders_y_neg[i_top_quad]

	table.insert(self._nav_data.door_high_pos, Vector3(xp, yn, z + 0.9))
	table.insert(self._nav_data.door_low_pos, Vector3(xn, yn, z + 0.9))
	table.insert(self._nav_data.door_high_quads, i_top_quad)
	table.insert(self._nav_data.door_low_quads, i_bottom_quad)
end

function ElementNavigationStitcher:_create_left_door(i_x, i_y, z)
	local i_left_quad = self._quad_grid[i_y][i_x - 1]
	local i_right_quad = self._quad_grid[i_y][i_x]
	local xp = self._nav_data.quad_borders_x_pos[i_left_quad]
	local yp = self._nav_data.quad_borders_y_pos[i_left_quad]
	local yn = self._nav_data.quad_borders_y_neg[i_left_quad]

	table.insert(self._nav_data.door_high_pos, Vector3(xp, yp, z + 0.9))
	table.insert(self._nav_data.door_low_pos, Vector3(xp, yn, z + 0.9))
	table.insert(self._nav_data.door_high_quads, i_left_quad)
	table.insert(self._nav_data.door_low_quads, i_right_quad)
end

function ElementNavigationStitcher:_create_quads()
	local z = self._extents.height
	local i_x = 1
	local i_y = 1
	self._quad_grid = {}
	local pos = nil
	local x = self._extents.aabb.min_x + self._grid_size / 2

	while x <= self._extents.aabb.max_x do
		i_y = 1
		local y = self._extents.aabb.max_y - self._grid_size / 2

		while self._extents.aabb.min_y <= y do
			if not self._quad_grid[i_y] then
				self._quad_grid[i_y] = {}
			end

			local inside = managers.navigation:is_point_inside(Vector3(x, y, z), false)

			if not inside then
				local i_quad = self:_create_quad(x, y)
				self._quad_grid[i_y][i_x] = i_quad

				if i_y >= 2 and self._quad_grid[i_y - 1][i_x] then
					self:_create_top_door(i_x, i_y, z)
				end

				if i_x >= 2 and self._quad_grid[i_y][i_x - 1] then
					self:_create_left_door(i_x, i_y, z)
				end
			end

			y = y - self._grid_size
			i_y = i_y + 1
		end

		x = x + self._grid_size
		i_x = i_x + 1
	end

	self._ct_x = i_x - 1
	self._ct_y = i_y - 1
end

function ElementNavigationStitcher:_collect_external_top_door(x, y, z, i_quad)
	local door_high_pos = Vector3(self._nav_data.quad_borders_x_pos[i_quad] * self._grid_size, self._nav_data.quad_borders_y_pos[i_quad] * self._grid_size, z + 0.9)
	local door_low_pos = Vector3(self._nav_data.quad_borders_x_neg[i_quad] * self._grid_size, self._nav_data.quad_borders_y_pos[i_quad] * self._grid_size, z + 0.9)
	local stitch_quad_pos = Vector3(x, y, z + 0.9)
	local external_quad_pos = Vector3(x, y + self._grid_size, z + 0.9)

	table.insert(self._external_doors, {
		side = "top",
		stitch_quad_pos = stitch_quad_pos,
		external_quad_pos = external_quad_pos,
		door_high_pos = door_high_pos,
		door_low_pos = door_low_pos
	})
end

function ElementNavigationStitcher:_collect_external_left_door(x, y, z, i_quad)
	local door_high_pos = Vector3(self._nav_data.quad_borders_x_neg[i_quad] * self._grid_size, self._nav_data.quad_borders_y_pos[i_quad] * self._grid_size, z + 0.9)
	local door_low_pos = Vector3(self._nav_data.quad_borders_x_neg[i_quad] * self._grid_size, self._nav_data.quad_borders_y_neg[i_quad] * self._grid_size, z + 0.9)
	local stitch_quad_pos = Vector3(x, y, z + 0.9)
	local external_quad_pos = Vector3(x - self._grid_size, y, z + 0.9)

	table.insert(self._external_doors, {
		side = "left",
		stitch_quad_pos = stitch_quad_pos,
		external_quad_pos = external_quad_pos,
		door_high_pos = door_high_pos,
		door_low_pos = door_low_pos
	})
end

function ElementNavigationStitcher:_collect_external_bottom_door(x, y, z, i_quad)
	local door_high_pos = Vector3(self._nav_data.quad_borders_x_neg[i_quad] * self._grid_size, self._nav_data.quad_borders_y_neg[i_quad] * self._grid_size, z + 0.9)
	local door_low_pos = Vector3(self._nav_data.quad_borders_x_pos[i_quad] * self._grid_size, self._nav_data.quad_borders_y_neg[i_quad] * self._grid_size, z + 0.9)
	local stitch_quad_pos = Vector3(x, y, z + 0.9)
	local external_quad_pos = Vector3(x, y - self._grid_size, z + 0.9)

	table.insert(self._external_doors, {
		side = "bottom",
		stitch_quad_pos = stitch_quad_pos,
		external_quad_pos = external_quad_pos,
		door_high_pos = door_high_pos,
		door_low_pos = door_low_pos
	})
end

function ElementNavigationStitcher:_collect_external_right_door(x, y, z, i_quad)
	local door_high_pos = Vector3(self._nav_data.quad_borders_x_pos[i_quad] * self._grid_size, self._nav_data.quad_borders_y_neg[i_quad] * self._grid_size, z + 0.9)
	local door_low_pos = Vector3(self._nav_data.quad_borders_x_pos[i_quad] * self._grid_size, self._nav_data.quad_borders_y_pos[i_quad] * self._grid_size, z + 0.9)
	local stitch_quad_pos = Vector3(x, y, z + 0.9)
	local external_quad_pos = Vector3(x + self._grid_size, y, z + 0.9)

	table.insert(self._external_doors, {
		side = "right",
		stitch_quad_pos = stitch_quad_pos,
		external_quad_pos = external_quad_pos,
		door_high_pos = door_high_pos,
		door_low_pos = door_low_pos
	})
end

function ElementNavigationStitcher:_collect_external_doors()
	self._external_doors = {}
	local i_x = 1
	local i_y = 1
	local top_left_x = self._extents.aabb.min_x - self._grid_size / 2
	local top_left_y = self._extents.aabb.max_y + self._grid_size / 2
	local z = self._extents.height

	for i_x = 1, self._ct_x do
		local x = top_left_x + i_x * self._grid_size

		for i_y = 1, self._ct_y do
			local y = top_left_y - i_y * self._grid_size
			local i_quad = self._quad_grid[i_y][i_x]

			if i_quad then
				if (i_y <= 1 or not self._quad_grid[i_y - 1] or not self._quad_grid[i_y - 1][i_x]) and managers.navigation:is_point_inside(Vector3(x, y + self._grid_size, z), false) then
					self:_collect_external_top_door(x, y, z, self._quad_grid[i_y][i_x])
				end

				if (i_x <= 1 or not self._quad_grid[i_y][i_x - 1]) and managers.navigation:is_point_inside(Vector3(x - self._grid_size, y, z), false) then
					self:_collect_external_left_door(x, y, z, self._quad_grid[i_y][i_x])
				end

				if (not self._quad_grid[i_y + 1] or not self._quad_grid[i_y + 1][i_x]) and managers.navigation:is_point_inside(Vector3(x, y - self._grid_size, z), false) then
					self:_collect_external_bottom_door(x, y, z, self._quad_grid[i_y][i_x])
				end

				if not self._quad_grid[i_y][i_x + 1] and managers.navigation:is_point_inside(Vector3(x + self._grid_size, y, z), false) then
					self:_collect_external_right_door(x, y, z, self._quad_grid[i_y][i_x])
				end
			end
		end
	end
end

function ElementNavigationStitcher:_create_external_doors()
	for _, door in ipairs(self._external_doors) do
		managers.navigation._quad_field:add_door(door.stitch_quad_pos, door.external_quad_pos, door.door_high_pos, door.door_low_pos)
	end
end

function ElementNavigationStitcher:_clear_data()
	self._extents = {}
	self._nav_data = {}
	self._external_doors = {}
	self._has_created = false
end

function ElementNavigationStitcher:stitch(from_dropin)
	if self._has_created and not from_dropin then
		return
	end

	self._has_created = true
	self._world_id = self._world_id or managers.worldcollection:get_next_navstitcher_id()
	self._grid_size = managers.navigation:grid_size()

	self:_calculate_extents()
	self:_create_nav_data()
	self:_create_quads()

	if #self._nav_data.quad_borders_x_pos == 0 then
		Application:error("[ElementNavigationStitcher] Navigation stitcher area is fully inside existing navigation - nothing to stitch")
		self:_clear_data()

		return
	end

	self:_collect_external_doors()
	managers.navigation:set_load_data(self._nav_data, self._world_id, Vector3(0, 0, 0), 0, true)
	self:_create_external_doors()
	managers.navigation._quad_field:refresh_neighbours(self._world_id)
	managers.navigation:_resolve_segment_neighbours(self._world_id, true)
	managers.groupai._state:merge_world_data(self._world_id)
end

function ElementNavigationStitcher:tear()
	if not self._has_created then
		return
	end

	self:_clear_data()
	managers.navigation:unload_world_data(self._world_id)
end

function ElementNavigationStitcher:save(data)
	data.enabled = self._values.enabled
	data.has_created = self._has_created
	data.world_id = self._world_id
end

function ElementNavigationStitcher:load(data)
	if not self._on_script_activated_done then
		self:on_script_activated()
	end

	self._world_id = data.world_id
	self._has_created = data.has_created

	if self._has_created then
		if managers.navigation:is_streamed_data_ready() then
			Application:debug("[ElementNavigationStitcher:load] Stitching!")
			self:stitch(true)
		else
			Application:debug("[ElementNavigationStitcher:load] Queuing stitching!")
			managers.navigation:add_listener("stitcher" .. self._id, {
				"navigation_ready"
			}, callback(self, self, "_queue_stitch"))
		end
	end

	self:set_enabled(data.enabled)
end

function ElementNavigationStitcher:_queue_stitch()
	Application:debug("[ElementNavigationStitcher:load] Stitching from queue!")
	self:stitch(true)
end
