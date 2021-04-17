RaidGUIControlListItemSaveSlots = RaidGUIControlListItemSaveSlots or class(RaidGUIControl)
RaidGUIControlListItemSaveSlots.HEIGHT = 94
RaidGUIControlListItemSaveSlots.ICON_PADDING = 28
RaidGUIControlListItemSaveSlots.ICON_CENTER_X = 48
RaidGUIControlListItemSaveSlots.NAME_CENTER_Y = 34
RaidGUIControlListItemSaveSlots.DIFFICULTY_CENTER_Y = 63
RaidGUIControlListItemSaveSlots.LOCK_ICON = "ico_locker"
RaidGUIControlListItemSaveSlots.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT = 43
RaidGUIControlListItemSaveSlots.LOCKED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlListItemSaveSlots.UNLOCKED_COLOR = tweak_data.gui.colors.raid_dirty_white

-- Lines 18-61
function RaidGUIControlListItemSaveSlots:init(parent, params, data)
	RaidGUIControlListItemSaveSlots.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemSaveSlots:init] On click callback not specified for list item: ", params.name)
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
	self:_layout_raid_name(params, data)

	if data.empty then
		self:_layout_difficulty_locked()
	else
		self:_layout_difficulty()
	end

	self._selectable = self._data.selectable
	self._selected = false

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self:highlight_off()

	if managers.progression:operations_state() == ProgressionManager.OPERATIONS_STATE_LOCKED then
		self:_layout_lock_icon()
		self:_apply_locked_layout()
	end
end

-- Lines 63-72
function RaidGUIControlListItemSaveSlots:_layout_panel(params)
	local panel_params = {
		name = "list_item_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = RaidGUIControlListItemSaveSlots.HEIGHT
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 74-83
function RaidGUIControlListItemSaveSlots:_layout_background(params)
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

-- Lines 85-93
function RaidGUIControlListItemSaveSlots:_layout_highlight_marker()
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

-- Lines 95-107
function RaidGUIControlListItemSaveSlots:_layout_icon(params, data)
	local icon_params = {
		name = "list_item_icon_" .. self._name,
		x = RaidGUIControlListItemSaveSlots.ICON_PADDING,
		y = (RaidGUIControlListItemSaveSlots.HEIGHT - data.icon.texture_rect[4]) / 2,
		texture = data.icon.texture,
		texture_rect = data.icon.texture_rect,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_icon = self._object:image(icon_params)

	self._item_icon:set_center_x(RaidGUIControlListItemSaveSlots.ICON_CENTER_X)
	self._item_icon:set_center_y(self._object:h() / 2)
end

-- Lines 109-123
function RaidGUIControlListItemSaveSlots:_layout_raid_name(params, data)
	local raid_name_params = {
		vertical = "center",
		y = 0,
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemSaveSlots.ICON_PADDING,
		w = params.w,
		h = params.h,
		text = utf8.to_upper(data.text),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_label = self._object:label(raid_name_params)

	self._item_label:set_center_y(RaidGUIControlListItemSaveSlots.NAME_CENTER_Y)
end

-- Lines 125-140
function RaidGUIControlListItemSaveSlots:_layout_difficulty_locked()
	local difficulty_locked_params = {
		text = "--",
		vertical = "center",
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemSaveSlots.ICON_PADDING,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_dark_grey
	}
	self._difficulty_locked_indicator = self._object:label(difficulty_locked_params)
	local _, _, w, h = self._difficulty_locked_indicator:text_rect()

	self._difficulty_locked_indicator:set_w(w)
	self._difficulty_locked_indicator:set_h(h)
	self._difficulty_locked_indicator:set_center_y(RaidGUIControlListItemSaveSlots.DIFFICULTY_CENTER_Y)
end

-- Lines 142-154
function RaidGUIControlListItemSaveSlots:_layout_difficulty()
	local difficulty_params = {
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemSaveSlots.ICON_PADDING,
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = self._object:create_custom_control(RaidGuiControlDifficultyStars, difficulty_params)

	self._difficulty_indicator:set_center_y(RaidGUIControlListItemSaveSlots.DIFFICULTY_CENTER_Y)

	if self._data.difficulty then
		local difficulty = tweak_data:difficulty_to_index(self._data.difficulty)

		self._difficulty_indicator:set_active_difficulty(difficulty)
	end
end

-- Lines 156-165
function RaidGUIControlListItemSaveSlots:_layout_lock_icon()
	local lock_icon_params = {
		texture = tweak_data.gui.icons[RaidGUIControlListItemSaveSlots.LOCK_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlListItemSaveSlots.LOCK_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_dark_grey
	}
	self._lock_icon = self._object:bitmap(lock_icon_params)

	self._lock_icon:set_center_x(self._object:w() - RaidGUIControlListItemSaveSlots.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT)
	self._lock_icon:set_center_y(self._object:h() / 2)
end

-- Lines 167-175
function RaidGUIControlListItemSaveSlots:_layout_breadcrumb()
	local breadcrumb_params = {
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 177-187
function RaidGUIControlListItemSaveSlots:_apply_locked_layout()
	self._lock_icon:show()

	if self._difficulty_locked_indicator then
		self._difficulty_locked_indicator:show()
	end

	if self._difficulty_indicator then
		self._difficulty_indicator:hide()
	end

	self._item_icon:set_color(RaidGUIControlListItemSaveSlots.LOCKED_COLOR)
	self._item_label:set_color(RaidGUIControlListItemSaveSlots.LOCKED_COLOR)
end

-- Lines 189-205
function RaidGUIControlListItemSaveSlots:on_mouse_released(button)
	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_OPERATIONS, {
		"operations_pending"
	})

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

-- Lines 207-216
function RaidGUIControlListItemSaveSlots:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 218-220
function RaidGUIControlListItemSaveSlots:selected()
	return self._selected
end

-- Lines 222-239
function RaidGUIControlListItemSaveSlots:select()
	self._selected = true

	self._item_background:show()

	if self._unlocked then
		self._item_label:set_color(self._selected_color)
	end

	self._item_highlight_marker:show()

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_OPERATIONS, {
		"operations_pending"
	})

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

-- Lines 241-244
function RaidGUIControlListItemSaveSlots:unfocus()
	self._item_background:hide()
	self._item_highlight_marker:hide()
end

-- Lines 246-254
function RaidGUIControlListItemSaveSlots:unselect()
	self._selected = false

	self._item_background:hide()

	if self._unlocked then
		self._item_label:set_color(self._color)
	end

	self._item_highlight_marker:hide()
end

-- Lines 256-258
function RaidGUIControlListItemSaveSlots:data()
	return self._data
end

-- Lines 260-276
function RaidGUIControlListItemSaveSlots:highlight_on()
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

-- Lines 278-289
function RaidGUIControlListItemSaveSlots:highlight_off()
	if not managers.menu:is_pc_controller() then
		self._item_highlight_marker:hide()
		self._item_background:hide()
	end

	if not self._selected then
		self._item_background:hide()
	end
end

-- Lines 291-296
function RaidGUIControlListItemSaveSlots:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self._name)

		return true
	end
end
