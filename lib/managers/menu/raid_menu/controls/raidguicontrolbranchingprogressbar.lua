RaidGUIControlBranchingProgressBar = RaidGUIControlBranchingProgressBar or class(RaidGUIControl)

-- Lines 3-53
function RaidGUIControlBranchingProgressBar:init(parent, params)
	RaidGUIControlBranchingProgressBar.super.init(self, parent, params)

	self._levels = {}
	self._object = self._panel:panel({
		name = "wrap_panel",
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	})
	self._scrollable_panel = self._object:panel({
		name = "scrollable_panel",
		y = 0,
		x = 0,
		w = params.w,
		h = params.h
	})
	self._elements_panel = self._scrollable_panel:panel({
		name = "scrollable_panel",
		x = params.elements_panel_x or 0,
		y = params.elements_panel_y or 0,
		w = params.elements_panel_w or self._scrollable_panel:w(),
		h = params.elements_panel_h or self._scrollable_panel:h()
	})
	self._data_source_callback = params.data_source_callback

	if not self._data_source_callback then
		Application:error("[RaidGUIControlBranchingProgressBar] No data source callback given!")

		return
	end

	self._draggable = false

	self:_create_elements(params)

	self._current_points = params.starting_points or 0
	self._current_level = self:_get_current_level()
	self._path_animation_duration = params.path_animation_duration or 0.25
	self._activate_automatically = params.automatic or false
	self._on_mouse_enter_callback = params.on_mouse_enter_callback
	self._on_mouse_exit_callback = params.on_mouse_exit_callback
	self._on_click_callback = params.on_click_callback
	self._mouse_travel = 0
	self._panel_acceleration = 0

	self:_set_initial_state(self._current_points)

	if self._object:w() < self._scrollable_panel:w() then
		self._draggable = true

		managers.hud:add_updator("branching_progress_bar", callback(self, self, "update"))
	end

	if params.horizontal == "center" and self._scrollable_panel:w() < self._object:w() then
		self._scrollable_panel:set_x(self._object:w() / 2 - self._scrollable_panel:w() / 2)
	end
end

-- Lines 55-60
function RaidGUIControlBranchingProgressBar:close()
	RaidGUIControlScrollbar.super.close()
	managers.hud:remove_updator("branching_progress_bar")

	self._dragging = false
	self._draggable = false
end

-- Lines 62-189
function RaidGUIControlBranchingProgressBar:_create_elements(params)
	local node_tree = self._data_source_callback()
	local panel_padding = params.padding or 0
	local x_step = params.x_step or 200
	local y_step = params.y_step or 20
	local leading_path_length = nil

	if node_tree[1].points_needed and node_tree[1].points_needed > 0 then
		leading_path_length = params.leading_path_length or x_step / 2
	else
		leading_path_length = 0
	end

	local x = panel_padding + leading_path_length
	local active_level = 1

	for level_index, level_data in pairs(node_tree) do
		local nodes = {}
		local paths = {}

		for node_index, node_data in ipairs(level_data.nodes) do
			local node_state = RaidGUIControlBranchingBarNode.STATE_INACTIVE

			if node_data.state and node_data.state == "active" then
				node_state = RaidGUIControlBranchingBarNode.STATE_ACTIVE
				active_level = level_index
			end

			local node_value_data = node_data.value or {}
			node_value_data.level = level_index
			node_value_data.index = node_index
			local node_params = {
				name = "node_" .. tostring(level_index) .. "_" .. tostring(node_index),
				x = x,
				value = node_data.value,
				on_click_callback = callback(self, self, "_node_click_callback"),
				on_mouse_enter_callback = callback(self, self, "_node_enter_callback"),
				on_mouse_exit_callback = callback(self, self, "_node_exit_callback"),
				on_node_mouse_released_callback = callback(self, self, "on_mouse_released"),
				on_node_mouse_pressed_callback = callback(self, self, "on_mouse_pressed"),
				on_node_mouse_moved_callback = callback(self, self, "on_mouse_moved"),
				layer = self._elements_panel:layer() + 3,
				parents = node_data.parents,
				level = level_index,
				state = node_state
			}
			local node_class = params.node_class or RaidGUIControlBranchingBarSkilltreeNode
			local node = self._elements_panel:create_custom_control(node_class, node_params)
			local y_padding = (self._elements_panel:h() - #level_data.nodes * node:h() - (#level_data.nodes - 1) * y_step) / 2

			node:set_y(y_padding + (node_index - 1) * (node:h() + y_step))

			if not self._node_width then
				self._node_width = math.ceil(node:w())
			end

			node:set_x(x + (self._node_width - node:w()) / 2)
			table.insert(nodes, node)

			local path_class = params.path_class or RaidGUIControlBranchingBarSkilltreePath

			if node_data.parents and #node_data.parents ~= 0 then
				for _, parent_index in pairs(node_data.parents) do
					local previous_node = self._levels[level_index - 1].nodes[parent_index]
					local path_vector = {
						x = node:x() + node:w() / 2 - (previous_node:x() + previous_node:w() / 2),
						y = node:y() + node:h() / 2 - (previous_node:y() + previous_node:h() / 2)
					}
					local identity_vector = {
						x = 3,
						y = 0
					}
					local angle = math.atan2(path_vector.y, path_vector.x) - math.atan2(identity_vector.y, identity_vector.x)
					local dx = (node:w() / 2 - 2) * math.cos(angle)
					local dy = (node:w() / 2 - 2) * math.sin(angle)
					local points = {}
					local starting_point = Vector3(previous_node:x() + previous_node:w() / 2 + dx, previous_node:y() + previous_node:h() / 2 + dy, 0)
					local ending_point = Vector3(node:x() + node:w() / 2 - dx, node:y() + node:h() / 2 - dy, 0)
					local path_params = {
						starting_point = starting_point,
						starting_point_index = parent_index,
						ending_point = ending_point,
						ending_point_index = node_index,
						layer = self._elements_panel:layer() + 1,
						line_width = params.path_width or 3
					}
					local path = self._elements_panel:create_custom_control(path_class, path_params)

					table.insert(paths, path)
				end
			elseif level_index == 1 and level_data.points_needed and level_data.points_needed > 0 then
				local starting_point = Vector3(node:x() - leading_path_length, node:y() + node:h() / 2, 0)
				local ending_point = Vector3(node:x() + 2, node:y() + node:h() / 2, 0)
				local path_params = {
					starting_point_index = 0,
					starting_point = starting_point,
					ending_point = ending_point,
					ending_point_index = node_index,
					layer = self._elements_panel:layer() + 1,
					line_width = params.path_width or 3
				}
				local path = self._elements_panel:create_custom_control(path_class, path_params)

				table.insert(paths, path)
			end
		end

		local level = {
			nodes = nodes,
			paths = paths,
			points_needed = level_data.points_needed
		}

		table.insert(self._levels, level)

		x = x + self._node_width + x_step
	end

	self._elements_panel:set_w(#node_tree * self._node_width + (#node_tree - 1) * params.x_step + panel_padding * 2 + leading_path_length)
	self._scrollable_panel:set_w(self._elements_panel:w())

	local active_level_position_x = panel_padding + self._node_width / 2 + (active_level - 1) * (params.x_step + self._node_width)
	local panel_position_x = -active_level_position_x + self._object:w() / 2

	if panel_position_x > 0 then
		panel_position_x = 0
	elseif panel_position_x < -(self._elements_panel:w() - self._object:w()) then
		panel_position_x = -(self._elements_panel:w() - self._object:w())
	end

	self._scrollable_panel:set_x(panel_position_x)
end

-- Lines 191-205
function RaidGUIControlBranchingProgressBar:_check_if_node_reachable(node)
	if node:level() == 1 then
		return true
	end

	for _, parent_index in pairs(node:parents()) do
		local previous_node = self._levels[node:level() - 1].nodes[parent_index]

		if previous_node:state() ~= RaidGUIControlBranchingBarNode.STATE_DISABLED then
			return true
		end
	end

	return false
end

-- Lines 207-223
function RaidGUIControlBranchingProgressBar:_check_if_node_blocked(node)
	if node:level() == 1 then
		return false
	end

	for _, parent_index in pairs(node:parents()) do
		local previous_node = self._levels[node:level() - 1].nodes[parent_index]

		if previous_node:state() == RaidGUIControlBranchingBarNode.STATE_PENDING or previous_node:state() == RaidGUIControlBranchingBarNode.STATE_PENDING_BLOCKED then
			return true
		elseif previous_node:state() == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
			return false
		end
	end

	return false
end

-- Lines 227-231
function RaidGUIControlBranchingProgressBar:_set_initial_state(initial_points)
	self._current_points = initial_points

	self:_refresh_tree(true)
end

-- Lines 233-256
function RaidGUIControlBranchingProgressBar:_node_click_callback(node, node_data)
	if not self._on_click_callback then
		return
	end

	local node = self._levels[node_data.level].nodes[node_data.index]

	if node:state() == RaidGUIControlBranchingBarNode.STATE_PENDING then
		node:set_active()
		self:_refresh_tree()
		self._on_click_callback(node_data)
	end
end

-- Lines 276-280
function RaidGUIControlBranchingProgressBar:_node_enter_callback(node, node_data)
	if self._on_mouse_enter_callback then
		self._on_mouse_enter_callback(node_data)
	end
end

-- Lines 282-286
function RaidGUIControlBranchingProgressBar:_node_exit_callback(node, node_data)
	if self._on_mouse_exit_callback then
		self._on_mouse_exit_callback(node_data)
	end
end

-- Lines 288-319
function RaidGUIControlBranchingProgressBar:_get_level_progress(level)
	if self._levels[level].points_needed == 0 then
		return 1
	end

	local level_progress = nil

	if level == 1 then
		if self._levels[level].points_needed and self._levels[level].points_needed > 0 then
			level_progress = self._current_points / self._levels[level].points_needed
		else
			level_progress = 1
		end
	else
		local previous_level_points_needed = nil

		if self._levels[level - 1].points_needed then
			previous_level_points_needed = self._levels[level - 1].points_needed
		else
			previous_level_points_needed = 0
		end

		level_progress = (self._current_points - previous_level_points_needed) / (self._levels[level].points_needed - previous_level_points_needed)
	end

	if level_progress < 0 then
		return 0
	elseif level_progress > 1 then
		return 1
	end

	return level_progress
end

-- Lines 321-333
function RaidGUIControlBranchingProgressBar:_get_current_level()
	local current_level = 1

	for i = 1, #self._levels do
		if self._levels[i].points_needed and self._levels[i].points_needed <= self._current_points then
			current_level = i
		else
			break
		end
	end

	return current_level
end

-- Lines 335-347
function RaidGUIControlBranchingProgressBar:_get_level_by_points(points)
	local current_level = 0

	for i = 1, #self._levels do
		if self._levels[i].points_needed <= points then
			current_level = i
		else
			break
		end
	end

	return current_level
end

-- Lines 349-408
function RaidGUIControlBranchingProgressBar:_refresh_tree(full_refresh)
	local current_level_index = 1
	local need_to_check_further = true
	local level_progress = nil

	while (need_to_check_further or full_refresh) and current_level_index <= #self._levels do
		local current_level = self._levels[current_level_index]
		need_to_check_further = false
		level_progress = self:_get_level_progress(current_level_index)

		for j = 1, #current_level.nodes do
			local is_reachable = self:_check_if_node_reachable(current_level.nodes[j])
			local is_blocked = self:_check_if_node_blocked(current_level.nodes[j])
			local node_state = current_level.nodes[j]:state()

			if level_progress == 1 and node_state == RaidGUIControlBranchingBarNode.STATE_INACTIVE and is_reachable then
				if self._activate_automatically then
					current_level.nodes[j]:set_active()
				else
					if not self._first_available_level then
						self._first_available_level = current_level_index
					end

					current_level.nodes[j]:set_pending()
				end

				need_to_check_further = true
			elseif node_state == RaidGUIControlBranchingBarNode.STATE_PENDING_BLOCKED and is_reachable and not is_blocked then
				current_level.nodes[j]:set_pending()
			elseif node_state == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
				for k = 1, #current_level.nodes do
					if k ~= j then
						current_level.nodes[k]:set_disabled()
					end
				end

				need_to_check_further = true
				current_level.active = true
				current_level.active_node_index = j
			elseif not is_reachable then
				current_level.nodes[j]:set_disabled()

				need_to_check_further = true
			end

			if level_progress == 1 then
				need_to_check_further = true
			end
		end

		self:_refresh_level_paths(current_level_index)

		current_level_index = current_level_index + 1
	end
end

-- Lines 410-451
function RaidGUIControlBranchingProgressBar:_refresh_level_paths(level_index)
	if level_index < 1 or level_index > #self._levels then
		return
	end

	local level = self._levels[level_index]
	local level_progress = self:_get_level_progress(level_index)

	for j = 1, #level.paths do
		local path = level.paths[j]
		local endpoints = path:endpoints()
		local node_state = level.nodes[endpoints[2]]:state()
		local previous_node_state = nil

		if level_index == 1 then
			previous_node_state = RaidGUIControlBranchingBarNode.STATE_ACTIVE
		else
			previous_node_state = self._levels[level_index - 1].nodes[endpoints[1]]:state()
		end

		if node_state == RaidGUIControlBranchingBarNode.STATE_DISABLED or previous_node_state == RaidGUIControlBranchingBarNode.STATE_DISABLED then
			path:set_disabled()
		else
			if node_state == RaidGUIControlBranchingBarNode.STATE_ACTIVE and previous_node_state == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
				level_progress = 1

				path:set_locked()
			elseif level_progress >= 1 then
				level_progress = 1

				path:set_full()
			elseif level_progress < 0 then
				level_progress = 0
			else
				path:set_active()
			end

			path:set_progress(level_progress)
		end
	end
end

-- Lines 454-465
function RaidGUIControlBranchingProgressBar:set_points(points)
	local old_points = self._current_points
	self._current_points = points
	local new_level = self:_get_level_by_points(self._current_points)

	if new_level ~= self:_get_level_by_points(old_points) or new_level > #self._levels then
		self:_refresh_tree()
	else
		self:_refresh_level_paths(new_level + 1)
	end
end

-- Lines 467-469
function RaidGUIControlBranchingProgressBar:get_points()
	return self._current_points
end

-- Lines 473-479
function RaidGUIControlBranchingProgressBar:give_points(points, animate)
	if animate == true then
		self._scrollable_panel:get_engine_panel():animate(callback(self, self, "_animate_giving_points"), points, self._path_animation_duration)
	else
		self:set_points(self._current_points + points)
	end
end

-- Lines 481-484
function RaidGUIControlBranchingProgressBar:reset_points()
	self._current_points = 0

	self:give_points(0)
end

-- Lines 486-500
function RaidGUIControlBranchingProgressBar:_animate_giving_points(panel, new_points, duration)
	local t = 0
	local starting_points = self._current_points

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_points = self:_ease_in_out_quint(t, starting_points, new_points, duration)

		self:set_points(current_points)
	end

	self:set_points(starting_points + new_points)
end

-- Lines 503-538
function RaidGUIControlBranchingProgressBar:on_mouse_moved(o, x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlBranchingProgressBar.super.on_mouse_moved(self, o, x, y)

	if not self._dragging then
		return
	end

	if not self._mouse_start_x then
		self._mouse_start_x = x
		self._mouse_last_x = x
	end

	if self._scrollable_panel:x() > 35 then
		self._move_damping = 1 - math.abs(self._scrollable_panel:x() - 35) / 100
	elseif self._scrollable_panel:x() < -(self._scrollable_panel:w() - self._object:w() + 35) then
		self._move_damping = 1 - math.abs(self._scrollable_panel:x() + self._scrollable_panel:w() - self._object:w() + 35) / 100
	else
		self._move_damping = 1
	end

	if self._move_damping < 0 then
		self._move_damping = 0
	end

	self._mouse_travel = (x - self._mouse_last_x) * self._move_damping
	local scrollable_panel_new_x = self._scrollable_panel:x() + (x - self._mouse_last_x) * self._move_damping
	scrollable_panel_new_x = math.round(scrollable_panel_new_x)

	self._scrollable_panel:set_x(scrollable_panel_new_x)

	self._mouse_last_x = x

	return true, "grab"
end

-- Lines 541-549
function RaidGUIControlBranchingProgressBar:on_mouse_over(x, y)
	RaidGUIControlBranchingProgressBar.super.on_mouse_over(self, x, y)
end

-- Lines 552-567
function RaidGUIControlBranchingProgressBar:on_mouse_out(x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlBranchingProgressBar.super.on_mouse_out(self, x, y)
	self:on_mouse_released()

	self._dragging = false
end

-- Lines 570-586
function RaidGUIControlBranchingProgressBar:on_mouse_pressed()
	if not self._draggable then
		return
	end

	managers.raid_menu:set_active_control(self)

	self._pointer_type = "grab"
	self._dragging = true
	self._mouse_start_x = nil
	self._panel_start_x = self._scrollable_panel:x()
	self._panel_velocity = nil
	self._panel_acceleration = nil
	self._controller_enabled = false
end

-- Lines 589-605
function RaidGUIControlBranchingProgressBar:on_mouse_released()
	if not self._draggable then
		return
	end

	self._pointer_type = "hand"
	self._dragging = false
	self._mouse_start_x = nil
	self._panel_start_x = nil
	self._panel_acceleration = 0

	if self._on_value_change_callback then
		self._on_value_change_callback()
	end
end

-- Lines 607-610
function RaidGUIControlBranchingProgressBar:show()
	self._object:show()
	self._bar:show()
end

-- Lines 612-615
function RaidGUIControlBranchingProgressBar:hide()
	self._object:hide()
	self._bar:hide()
end

-- Lines 617-629
function RaidGUIControlBranchingProgressBar:_ease_in_out_quint(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t * t * t * t + starting_value
	end

	t = t - 2

	return change / 2 * (t * t * t * t * t + 2) + starting_value
end

-- Lines 631-678
function RaidGUIControlBranchingProgressBar:update(t, dt)
	if self._dragging or managers.controller:is_using_controller() or self._controller_enabled then
		return
	end

	if not self._panel_velocity then
		self._panel_velocity = self._mouse_travel / dt
		self._scrollable_panel_x = self._scrollable_panel:x()
	end

	if self._scrollable_panel:x() > 90 or self._scrollable_panel:x() < -(self._scrollable_panel:w() - self._object:w() + 90) then
		self._draggable = false
	elseif self._object:w() < self._scrollable_panel:w() then
		self._draggable = true
	end

	if self._scrollable_panel_x > 0.01 then
		self._spring = true
		self._panel_acceleration = -25 * self._scrollable_panel_x - 10 * self._panel_velocity
	elseif self._scrollable_panel_x < -(self._scrollable_panel:w() - self._object:w()) then
		self._spring = true
		self._panel_acceleration = 25 * (-(self._scrollable_panel:w() - self._object:w()) - self._scrollable_panel_x) - 10 * self._panel_velocity
	elseif self._scrollable_panel_x <= 0.01 and self._scrollable_panel_x >= -(self._scrollable_panel:w() - self._object:w()) and self._spring then
		self._spring = false
		self._panel_acceleration = 0
	end

	self._panel_velocity = self._panel_velocity * 0.9
	self._panel_velocity = self._panel_velocity + self._panel_acceleration * dt
	local previous_x = self._scrollable_panel:x()
	self._scrollable_panel_x = self._scrollable_panel_x + self._panel_velocity * dt

	self._scrollable_panel:set_x(math.floor(self._scrollable_panel_x))
end

-- Lines 680-702
function RaidGUIControlBranchingProgressBar:clear_selection()
	self._selected_nodes = {}
	self._first_available_level = 2
	local current_level_index = 2
	local need_to_check_further = true

	while need_to_check_further and current_level_index <= #self._levels do
		local current_level = self._levels[current_level_index]

		for j = 1, #current_level.nodes do
			local node = current_level.nodes[j]

			if node:state() == RaidGUIControlBranchingBarNode.STATE_INACTIVE then
				need_to_check_further = false
			elseif node:state() == RaidGUIControlBranchingBarNode.STATE_SELECTED then
				node:set_pending()
			elseif node:state() == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
				self._first_available_level = current_level_index + 1
			end
		end

		current_level_index = current_level_index + 1
	end

	self:_refresh_tree(true)
	self:_set_scrollable_panel_x(self._levels[1].nodes[1])
end
