RaidGUIControlListItemOperations = RaidGUIControlListItemOperations or class(RaidGUIControl)
RaidGUIControlListItemOperations.HEIGHT = 94
RaidGUIControlListItemOperations.ICON_PADDING = 28
RaidGUIControlListItemOperations.ICON_CENTER_X = 48
RaidGUIControlListItemOperations.NAME_CENTER_Y = 34
RaidGUIControlListItemOperations.DIFFICULTY_CENTER_Y = 63
RaidGUIControlListItemOperations.LOCK_ICON = "ico_locker"
RaidGUIControlListItemOperations.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT = 43
RaidGUIControlListItemOperations.LOCKED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlListItemOperations.UNLOCKED_COLOR = tweak_data.gui.colors.raid_dirty_white

-- Lines 18-55
function RaidGUIControlListItemOperations:init(parent, params, data)
	RaidGUIControlListItemOperations.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemOperations:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._data = data
	self._color = params.color or tweak_data.gui.colors.raid_white
	self._selected_color = params.selected_color or tweak_data.gui.colors.raid_red
	self._unlocked = data.unlocked or managers.progression:mission_unlocked(OperationsTweakData.JOB_TYPE_OPERATION, data.value)
	self._mouse_over_sound = params.on_mouse_over_sound_event
	self._mouse_click_sound = params.on_mouse_click_sound_event

	self:_layout_panel(params)
	self:_layout_background(params)
	self:_layout_highlight_marker()
	self:_layout_icon(params, data)
	self:_layout_operation_name(params, data)
	self:_layout_difficulty()

	self._selectable = self._data.selectable
	self._selected = false

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self:highlight_off()
	self:_apply_progression_layout()
end

-- Lines 57-66
function RaidGUIControlListItemOperations:_layout_panel(params)
	local panel_params = {
		name = "list_item_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = RaidGUIControlListItemOperations.HEIGHT
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 68-77
function RaidGUIControlListItemOperations:_layout_background(params)
	local background_params = {
		y = 1,
		visible = false,
		x = 0,
		name = "list_item_back_" .. self._name,
		w = params.w,
		h = self._object:h() - 2,
		color = tweak_data.gui.colors.raid_list_background
	}
	self._item_background = self._object:rect(background_params)
end

-- Lines 79-87
function RaidGUIControlListItemOperations:_layout_highlight_marker()
	local marker_params = {
		y = 1,
		w = 3,
		visible = false,
		x = 0,
		name = "list_item_highlight_" .. self._name,
		h = self._object:h() - 2,
		color = self._selected_color
	}
	self._item_highlight_marker = self._object:rect(marker_params)
end

-- Lines 89-101
function RaidGUIControlListItemOperations:_layout_icon(params, data)
	local icon_params = {
		name = "list_item_icon_" .. self._name,
		x = RaidGUIControlListItemOperations.ICON_PADDING,
		y = (RaidGUIControlListItemOperations.HEIGHT - data.icon.texture_rect[4]) / 2,
		texture = data.icon.texture,
		texture_rect = data.icon.texture_rect,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_icon = self._object:image(icon_params)

	self._item_icon:set_center_x(RaidGUIControlListItemOperations.ICON_CENTER_X)
	self._item_icon:set_center_y(self._object:h() / 2)
end

-- Lines 103-117
function RaidGUIControlListItemOperations:_layout_operation_name(params, data)
	local raid_name_params = {
		vertical = "center",
		y = 0,
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemOperations.ICON_PADDING,
		w = params.w,
		h = params.h,
		text = utf8.to_upper(data.title),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_label = self._object:label(raid_name_params)

	self._item_label:set_center_y(RaidGUIControlListItemOperations.NAME_CENTER_Y)
end

-- Lines 119-126
function RaidGUIControlListItemOperations:_layout_difficulty()
	local difficulty_params = {
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemOperations.ICON_PADDING,
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = self._object:create_custom_control(RaidGuiControlDifficultyStars, difficulty_params)

	self._difficulty_indicator:set_center_y(RaidGUIControlListItemOperations.DIFFICULTY_CENTER_Y)
end

-- Lines 128-136
function RaidGUIControlListItemOperations:_layout_breadcrumb()
	local breadcrumb_params = {
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 138-155
function RaidGUIControlListItemOperations:_apply_progression_layout()
	if self._unlocked then
		self._difficulty_indicator:show()
		self._item_icon:set_color(RaidGUIControlListItemOperations.UNLOCKED_COLOR)
		self._item_label:set_color(RaidGUIControlListItemOperations.UNLOCKED_COLOR)

		local difficulty_available, difficulty_completed = managers.progression:get_mission_progression(OperationsTweakData.JOB_TYPE_OPERATION, self._data.value)

		if difficulty_available and difficulty_completed then
			self._difficulty_indicator:set_progress(difficulty_available, difficulty_completed)
		end
	else
		self._difficulty_indicator:hide()
		self._item_icon:set_color(RaidGUIControlListItemOperations.LOCKED_COLOR)
		self._item_label:set_color(RaidGUIControlListItemOperations.LOCKED_COLOR)
	end
end

-- Lines 157-172
function RaidGUIControlListItemOperations:on_mouse_released(button)
	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	if self._mouse_click_sound then
		managers.menu_component:post_event(self._mouse_click_sound)
	end

	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end

	if self._params.list_item_selected_callback then
		self._params.list_item_selected_callback(self._name)
	end
end

-- Lines 174-183
function RaidGUIControlListItemOperations:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 185-187
function RaidGUIControlListItemOperations:selected()
	return self._selected
end

-- Lines 189-205
function RaidGUIControlListItemOperations:select()
	self._selected = true

	self._item_background:show()

	if self._unlocked then
		self._item_label:set_color(self._selected_color)
	end

	self._item_highlight_marker:show()

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

-- Lines 207-210
function RaidGUIControlListItemOperations:unfocus()
	self._item_background:hide()
	self._item_highlight_marker:hide()
end

-- Lines 212-220
function RaidGUIControlListItemOperations:unselect()
	self._selected = false

	self._item_background:hide()

	if self._unlocked then
		self._item_label:set_color(self._color)
	end

	self._item_highlight_marker:hide()
end

-- Lines 222-224
function RaidGUIControlListItemOperations:data()
	return self._data
end

-- Lines 226-242
function RaidGUIControlListItemOperations:highlight_on()
	self._item_background:show()

	if self._mouse_over_sound then
		managers.menu_component:post_event(self._mouse_over_sound)
	end

	if not self._unlocked then
		return
	end

	if self._selected then
		self._item_label:set_color(self._selected_color)
	else
		self._item_label:set_color(self._color)
	end
end

-- Lines 244-255
function RaidGUIControlListItemOperations:highlight_off()
	if not managers.menu:is_pc_controller() then
		self._item_highlight_marker:hide()
		self._item_background:hide()
	end

	if not self._selected then
		self._item_background:hide()
	end
end

-- Lines 257-262
function RaidGUIControlListItemOperations:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self._name)

		return true
	end
end
