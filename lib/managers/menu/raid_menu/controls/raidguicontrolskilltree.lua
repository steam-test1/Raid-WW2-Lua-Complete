RaidGUIControlSkilltree = RaidGUIControlSkilltree or class(RaidGUIControlBranchingProgressBar)
RaidGUIControlSkilltree.DEFAULT_H = 416
RaidGUIControlSkilltree.DEFAULT_BPB_H = 320

-- Lines 6-35
function RaidGUIControlSkilltree:init(parent, params)
	Application:debug("[RaidGUIControlSkilltree:init]")

	params.h = params.h or RaidGUIControlSkilltree.DEFAULT_H
	params.elements_panel_h = params.elements_panel_h or RaidGUIControlSkilltree.DEFAULT_BPB_H
	params.x_step = 100

	RaidGUIControlSkilltree.super.init(self, parent, params)

	local progress_bar_x = self._levels[1].nodes[1]:x() + self._levels[1].nodes[1]:w() / 2
	local progress_bar_w = self._levels[#self._levels].nodes[1]:x() + self._levels[#self._levels].nodes[1]:w() / 2 - (self._levels[1].nodes[1]:x() + self._levels[1].nodes[1]:w() / 2)
	local progress_bar_params = {
		initial_progress = 0,
		name = "progress_bar",
		initial_level = 1,
		y = 0,
		x = 0,
		w = self._scrollable_panel:w(),
		h = self._scrollable_panel:h(),
		horizontal_padding = progress_bar_x,
		bar_w = progress_bar_w
	}
	self._progress_bar = self._scrollable_panel:create_custom_control(RaidGUIControlSkilltreeProgressBar, progress_bar_params)

	self._progress_bar:set_bottom(self._scrollable_panel:h())

	self._selection_changed_callback = params.on_selection_changed_callback
	self._selected_nodes = {}
end

-- Lines 37-60
function RaidGUIControlSkilltree:on_respec()
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
			elseif node:state() == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
				node:set_selected()

				self._selected_nodes[node._data.level] = node._data
			else
				current_level.nodes[j]:set_pending()
			end
		end

		current_level_index = current_level_index + 1
	end

	self:_refresh_tree(true)
	self:_set_scrollable_panel_x(self._levels[1].nodes[1])
end

-- Lines 62-68
function RaidGUIControlSkilltree:give_points(points, animate)
	RaidGUIControlSkilltree.super.give_points(self, points, animate)

	local progress = self:get_progress()

	self._progress_bar:set_progress(progress)
	self._progress_bar:unlock_level(self:_get_current_level())
end

-- Lines 70-81
function RaidGUIControlSkilltree:get_progress()
	local current_level = self:_get_current_level()
	local levels_progress = (current_level - 1) / (#self._levels - 1)
	local progress_in_level = 0
	local level_cap = managers.experience:level_cap()

	if current_level < level_cap then
		progress_in_level = self:_get_level_progress(current_level + 1) / (#self._levels - 1)
	end

	return levels_progress + progress_in_level
end

-- Lines 83-103
function RaidGUIControlSkilltree:_node_click_callback(node, node_data)
	if not self._on_click_callback then
		return
	end

	local node = self._levels[node_data.level].nodes[node_data.index]

	if node:state() == RaidGUIControlBranchingBarNode.STATE_PENDING then
		if self._activate_automatically then
			node:set_active()
			self._on_click_callback(node_data)
			self:_refresh_tree()
		else
			self:_select_node(node_data)
		end
	elseif node:state() == RaidGUIControlBranchingBarNode.STATE_SELECTED then
		self:_unselect_node(node_data.level, node_data.index)
	end
end

-- Lines 105-122
function RaidGUIControlSkilltree:_select_node(node_data)
	local node = self._levels[node_data.level].nodes[node_data.index]

	for i, level_node in pairs(self._levels[node_data.level].nodes) do
		if level_node:state() == RaidGUIControlBranchingBarNode.STATE_SELECTED then
			level_node:set_pending()
		end
	end

	node:set_selected()

	self._selected_nodes[node_data.level] = node_data

	if self._selection_changed_callback then
		self._selection_changed_callback()
	end

	managers.hud._sound_source:post_event("skill_select")
end

-- Lines 124-135
function RaidGUIControlSkilltree:_unselect_node(level, index)
	local node = self._levels[level].nodes[index]

	node:set_pending()

	self._selected_nodes[level] = nil

	if self._selection_changed_callback then
		self._selection_changed_callback()
	end

	managers.hud._sound_source:post_event("skill_remove")
end

-- Lines 137-139
function RaidGUIControlSkilltree:get_selected_nodes()
	return self._selected_nodes
end

-- Lines 141-165
function RaidGUIControlSkilltree:is_selection_valid()
	if not self._selected_nodes[self._first_available_level] then
		return false
	end

	local largest_selected_index = 0

	for index, node in pairs(self._selected_nodes) do
		if largest_selected_index < index then
			largest_selected_index = index
		end
	end

	local last_selected_index = self._first_available_level

	for i = self._first_available_level, largest_selected_index do
		if self._selected_nodes[i] then
			if i - last_selected_index > 1 then
				return false
			end

			last_selected_index = i
		end
	end

	return true
end

-- Lines 167-183
function RaidGUIControlSkilltree:apply_selected_skills()
	local largest_selected_index = 0

	for index, node_data in pairs(self._selected_nodes) do
		local node = self._levels[node_data.level].nodes[node_data.index]

		node:set_active()

		if largest_selected_index < index then
			largest_selected_index = index
		end
	end

	self._selected_nodes = {}
	self._first_available_level = largest_selected_index + 1

	self:_refresh_tree()
end

-- Lines 185-187
function RaidGUIControlSkilltree:_node_enter_callback(node, node_data)
	self._on_mouse_enter_callback(node_data)
end

-- Lines 205-222
function RaidGUIControlSkilltree:set_selected(value)
	self._selected = value
	self._selected_level_idx, self._selected_node_idx = self:_get_active_level_node_index()
	local skill_node = self:get_skill_tree_node(self._selected_level_idx + 1, self._selected_node_idx)

	if skill_node then
		self._selected_level_idx = self._selected_level_idx + 1
	else
		skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)
	end

	self:_select_skill_tree_node(skill_node)
end

-- Lines 224-250
function RaidGUIControlSkilltree:_get_active_level_node_index()
	if not self._levels then
		return 1, 1
	end

	local last_active_level = nil

	for level_index, level_data in ipairs(self._levels) do
		if level_data.active then
			last_active_level = clone(level_data)
			last_active_level.level = level_index
		elseif not level_data.active and last_active_level then
			return last_active_level.level, last_active_level.active_node_index
		elseif not level_data.active and not last_active_level then
			-- Nothing
		end
	end

	if last_active_level then
		return last_active_level.level, last_active_level.active_node_index
	end

	return 1, 1
end

-- Lines 252-257
function RaidGUIControlSkilltree:_click_skill_tree_node(skill_node)
	skill_node:mouse_clicked(nil, nil, skill_node:world_x(), skill_node:world_y())
	skill_node:set_hovered()
end

-- Lines 259-263
function RaidGUIControlSkilltree:_select_skill_tree_node(skill_node)
	skill_node:set_hovered()
	skill_node:on_mouse_over()
end

-- Lines 265-268
function RaidGUIControlSkilltree:_unselect_skill_tree_node(skill_node)
	skill_node:refresh_current_state()
	skill_node:on_mouse_out()
end

-- Lines 270-281
function RaidGUIControlSkilltree:get_skill_tree_node(level_idx, node_idx)
	local level = self._levels[level_idx]

	if level then
		local node = level.nodes[node_idx]

		if node then
			return self._levels[level_idx].nodes[node_idx]
		end
	end

	return nil
end

-- Lines 283-293
function RaidGUIControlSkilltree:select_node(level, node)
	if self._selected_level_idx == level and self._selected_node_idx == node then
		return
	end

	self:_unselect_skill_tree_node(self:get_current_skill_tree_node())
	self:get_skill_tree_node(level, node):set_hovered()

	self._selected_level_idx = level
	self._selected_node_idx = node
end

-- Lines 295-297
function RaidGUIControlSkilltree:get_current_skill_tree_node()
	return self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)
end

-- Lines 299-319
function RaidGUIControlSkilltree:move_up()
	self._new_selected_node_idx = self._selected_node_idx - 1

	if self._new_selected_node_idx <= 0 then
		self._selected_node_idx = 1
	else
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_node_idx = self._new_selected_node_idx
		local skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_select_skill_tree_node(skill_node)
	end

	return true
end

-- Lines 321-341
function RaidGUIControlSkilltree:move_down()
	self._new_selected_node_idx = self._selected_node_idx + 1

	if self._new_selected_node_idx > #self._levels[self._selected_level_idx].nodes then
		self._selected_node_idx = #self._levels[self._selected_level_idx].nodes
	else
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_node_idx = self._new_selected_node_idx
		local skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_select_skill_tree_node(skill_node)
	end

	return true
end

-- Lines 343-347
function RaidGUIControlSkilltree:move_left()
	return self:_move_left(1)
end

-- Lines 349-353
function RaidGUIControlSkilltree:move_right()
	return self:_move_right(1)
end

-- Lines 356-360
function RaidGUIControlSkilltree:shoulder_move_left()
	return self:_move_left(3)
end

-- Lines 362-366
function RaidGUIControlSkilltree:shoulder_move_right()
	return self:_move_right(3)
end

-- Lines 368-405
function RaidGUIControlSkilltree:_move_left(value)
	self._new_selected_level_idx = self._selected_level_idx - value

	if self._selected_level_idx == 1 then
		return false
	elseif self._new_selected_level_idx <= 0 then
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_level_idx = 1
	else
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_level_idx = self._new_selected_level_idx
	end

	for count = self._selected_node_idx, 1, -1 do
		self._selected_node_idx = count
		local skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		if skill_node then
			self:_select_skill_tree_node(skill_node)
			self:_set_scrollable_panel_x(skill_node)

			return true
		end
	end

	return false
end

-- Lines 407-444
function RaidGUIControlSkilltree:_move_right(value)
	self._new_selected_level_idx = self._selected_level_idx + value

	if self._selected_level_idx == #self._levels then
		return false
	elseif self._new_selected_level_idx > #self._levels then
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_level_idx = #self._levels
	else
		local old_skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		self:_unselect_skill_tree_node(old_skill_node)

		self._selected_level_idx = self._new_selected_level_idx
	end

	for count = self._selected_node_idx, 1, -1 do
		self._selected_node_idx = count
		local skill_node = self:get_skill_tree_node(self._selected_level_idx, self._selected_node_idx)

		if skill_node then
			self:_select_skill_tree_node(skill_node)
			self:_set_scrollable_panel_x(skill_node)

			return true
		end
	end

	return false
end

-- Lines 446-461
function RaidGUIControlSkilltree:_set_scrollable_panel_x(skill_node)
	self._controller_enabled = true
	local scrollable_panel_new_x = -skill_node:x() + 800

	if scrollable_panel_new_x > 0 then
		scrollable_panel_new_x = 0
	elseif math.abs(scrollable_panel_new_x) > self._scrollable_panel:w() - self:w() then
		scrollable_panel_new_x = -(self._scrollable_panel:w() - self:w())
	end

	self._scrollable_panel:set_x(scrollable_panel_new_x)
end

-- Lines 463-468
function RaidGUIControlSkilltree:confirm_pressed()
	local skill_node = self:get_current_skill_tree_node()

	self:_click_skill_tree_node(skill_node)
end
