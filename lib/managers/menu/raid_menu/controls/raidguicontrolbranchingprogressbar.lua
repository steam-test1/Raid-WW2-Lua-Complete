RaidGUIControlBranchingProgressBar = RaidGUIControlBranchingProgressBar or class(RaidGUIControl)
RaidGUIControlBranchingProgressBar.SCROLL_RATE = 1200

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

	self:_layout_skill_details()
end

function RaidGUIControlBranchingProgressBar:_layout_skill_details()
	local params_skill_details = {
		layer = 1000,
		name = "skill_details",
		x = ExperienceGui.SKILL_DETAILS_X,
		y = ExperienceGui.SKILL_DETAILS_Y
	}
	self._skill_details = self._scrollable_panel:create_custom_control(RaidGUIControlSkillDetails, params_skill_details)
end

function RaidGUIControlBranchingProgressBar:update_skill_details(button_data, skill_flavor, skill_description, color_changes)
	local current_button = self:get_current_skill_tree_node()
	local new_shape = {
		x = current_button:x() + current_button:w(),
		y = current_button:y(),
		h = current_button:h()
	}

	self._skill_details:set_skill(button_data.skill, utf8.to_upper(managers.localization:text(button_data.skill_title)), skill_flavor, skill_description, color_changes, new_shape)
end

function RaidGUIControlBranchingProgressBar:hide_skill_details()
	self._skill_details:fade_away()
end

function RaidGUIControlBranchingProgressBar:close()
	RaidGUIControlScrollbar.super.close()
	managers.hud:remove_updator("branching_progress_bar")

	self._dragging = false
	self._draggable = false
end

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
				on_click_callback = callback(self, self, "_node_click_callback"),
				on_mouse_enter_callback = callback(self, self, "_node_enter_callback"),
				on_mouse_exit_callback = callback(self, self, "_node_exit_callback"),
				on_node_mouse_released_callback = callback(self, self, "on_mouse_released"),
				on_node_mouse_pressed_callback = callback(self, self, "on_mouse_pressed"),
				on_node_mouse_moved_callback = callback(self, self, "on_mouse_moved"),
				layer = self._elements_panel:layer() + 3,
				x = x,
				parents = node_data.parents,
				value = node_data.value,
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

function RaidGUIControlBranchingProgressBar:_set_initial_state(initial_points)
	self._current_points = initial_points

	self:_refresh_tree(true)
end

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

function RaidGUIControlBranchingProgressBar:_node_enter_callback(node, node_data)
	if self._on_mouse_enter_callback then
		self._on_mouse_enter_callback(node_data)
	end
end

function RaidGUIControlBranchingProgressBar:_node_exit_callback(node, node_data)
	if self._on_mouse_exit_callback then
		self._on_mouse_exit_callback(node_data)
	end
end

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

function RaidGUIControlBranchingProgressBar:get_points()
	return self._current_points
end

function RaidGUIControlBranchingProgressBar:give_points(points, animate)
	if animate == true then
		self._scrollable_panel:get_engine_panel():animate(callback(self, self, "_animate_giving_points"), points, self._path_animation_duration)
	else
		self:set_points(self._current_points + points)
	end
end

function RaidGUIControlBranchingProgressBar:reset_points()
	self._current_points = 0

	self:give_points(0)
end

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

function RaidGUIControlBranchingProgressBar:on_mouse_over(x, y)
	RaidGUIControlBranchingProgressBar.super.on_mouse_over(self, x, y)
end

function RaidGUIControlBranchingProgressBar:on_mouse_out(x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlBranchingProgressBar.super.on_mouse_out(self, x, y)
	self:on_mouse_released()

	self._dragging = false
end

function RaidGUIControlBranchingProgressBar:on_mouse_pressed()
	if not self._draggable then
		return
	end

	managers.raid_menu:set_active_control(self)

	self._pointer_type = "grab"
	self._dragging = true
	self._mouse_start_x = nil
	self._panel_start_x = self._scrollable_panel:x()
	self._panel_velocity = 0
	self._panel_acceleration = 0
	self._controller_enabled = false
end

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

function RaidGUIControlBranchingProgressBar:mouse_scroll_up(o, button, x, y)
	if self:inside(x, y) and self._panel_velocity then
		self._panel_velocity = self._panel_velocity + RaidGUIControlBranchingProgressBar.SCROLL_RATE

		return self:on_mouse_scroll_up(button)
	end

	return false
end

function RaidGUIControlBranchingProgressBar:mouse_scroll_down(o, button, x, y)
	if self:inside(x, y) and self._panel_velocity then
		self._panel_velocity = self._panel_velocity - RaidGUIControlBranchingProgressBar.SCROLL_RATE

		return self:on_mouse_scroll_down(button)
	end

	return false
end

function RaidGUIControlBranchingProgressBar:show()
	self._object:show()
	self._bar:show()
end

function RaidGUIControlBranchingProgressBar:hide()
	self._object:hide()
	self._bar:hide()
end

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

function RaidGUIControlBranchingProgressBar:update(t, dt)
	if self._dragging or managers.controller:is_using_controller() or self._controller_enabled then
		return
	end

	if self._panel_velocity and self._panel_velocity == 0 then
		self._panel_velocity = self._mouse_travel / dt
		self._scrollable_panel_x = self._scrollable_panel:x()
	end

	if self._scrollable_panel:x() > 90 or self._scrollable_panel:x() < -(self._scrollable_panel:w() - self._object:w() + 90) then
		self._draggable = false
	elseif self._object:w() < self._scrollable_panel:w() then
		self._draggable = true
	end

	if self._scrollable_panel_x then
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
	else
		self._scrollable_panel_x = 0
	end

	self._panel_velocity = (self._panel_velocity or 0) * 0.9
	self._panel_velocity = self._panel_velocity + self._panel_acceleration * dt
	local previous_x = self._scrollable_panel:x()
	self._scrollable_panel_x = self._scrollable_panel_x + self._panel_velocity * dt

	self._scrollable_panel:set_x(math.floor(self._scrollable_panel_x))
end

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
