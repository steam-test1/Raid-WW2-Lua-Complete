RaidGUIControlListItemRaids = RaidGUIControlListItemRaids or class(RaidGUIControl)
RaidGUIControlListItemRaids.HEIGHT = 94
RaidGUIControlListItemRaids.ICON_PADDING = 28
RaidGUIControlListItemRaids.ICON_CENTER_X = 48
RaidGUIControlListItemRaids.NAME_CENTER_Y = 34
RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y = 63
RaidGUIControlListItemRaids.LOCK_ICON = "ico_locker"
RaidGUIControlListItemRaids.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT = 43
RaidGUIControlListItemRaids.LOCKED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlListItemRaids.UNLOCKED_COLOR = tweak_data.gui.colors.raid_dirty_white

-- Lines 18-65
function RaidGUIControlListItemRaids:init(parent, params, data)
	RaidGUIControlListItemRaids.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemRaids:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._data = data
	self._is_consumable = tweak_data.operations.missions[data.value].consumable ~= nil
	self._color = params.color or tweak_data.gui.colors.raid_white
	self._selected_color = params.selected_color or tweak_data.gui.colors.raid_red
	self._unlocked = data.unlocked or managers.progression:mission_unlocked(OperationsTweakData.JOB_TYPE_RAID, data.value)
	self._mouse_over_sound = params.on_mouse_over_sound_event
	self._mouse_click_sound = params.on_mouse_click_sound_event

	self:_layout_panel(params)
	self:_layout_background(params)
	self:_layout_highlight_marker()
	self:_layout_icon(params, data)
	self:_layout_raid_name(params, data)

	if not self._is_consumable then
		self:_layout_difficulty_locked()
		self:_layout_difficulty()
		self:_layout_lock_icon()
	else
		self:_layout_consumable_mission_label()
	end

	self._selectable = self._data.selectable
	self._selected = false

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self:highlight_off()

	if not self._is_consumable then
		self:_apply_progression_layout()
	end
end

-- Lines 67-76
function RaidGUIControlListItemRaids:_layout_panel(params)
	local panel_params = {
		name = "list_item_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = RaidGUIControlListItemRaids.HEIGHT
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 78-87
function RaidGUIControlListItemRaids:_layout_background(params)
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

-- Lines 89-97
function RaidGUIControlListItemRaids:_layout_highlight_marker()
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

-- Lines 99-111
function RaidGUIControlListItemRaids:_layout_icon(params, data)
	local icon_params = {
		name = "list_item_icon_" .. self._name,
		x = RaidGUIControlListItemRaids.ICON_PADDING,
		y = (RaidGUIControlListItemRaids.HEIGHT - data.icon.texture_rect[4]) / 2,
		texture = data.icon.texture,
		texture_rect = data.icon.texture_rect,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_icon = self._object:image(icon_params)

	self._item_icon:set_center_x(RaidGUIControlListItemRaids.ICON_CENTER_X)
	self._item_icon:set_center_y(self._object:h() / 2)
end

-- Lines 113-127
function RaidGUIControlListItemRaids:_layout_raid_name(params, data)
	local raid_name_params = {
		vertical = "center",
		y = 0,
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		w = params.w,
		h = params.h,
		text = utf8.to_upper(data.text),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._item_label = self._object:label(raid_name_params)

	self._item_label:set_center_y(RaidGUIControlListItemRaids.NAME_CENTER_Y)
end

-- Lines 129-147
function RaidGUIControlListItemRaids:_layout_consumable_mission_label()
	local consumable_mission_label_params = {
		vertical = "center",
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		text = self:translate("menu_mission_selected_mission_type_consumable", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_gold
	}
	self._consumable_mission_label = self._object:text(consumable_mission_label_params)
	local _, _, w, h = self._consumable_mission_label:text_rect()

	self._consumable_mission_label:set_w(w)
	self._consumable_mission_label:set_h(h)
	self._consumable_mission_label:set_center_y(RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y)
	self._consumable_mission_label:stop()
	self._consumable_mission_label:animate(UIAnimation.animate_text_glow, Color("e4a13d"), 0.55, 0.04, 1.4)
end

-- Lines 149-164
function RaidGUIControlListItemRaids:_layout_difficulty_locked()
	local difficulty_locked_params = {
		text = "--",
		vertical = "center",
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_dark_grey
	}
	self._difficulty_locked_indicator = self._object:label(difficulty_locked_params)
	local _, _, w, h = self._difficulty_locked_indicator:text_rect()

	self._difficulty_locked_indicator:set_w(w)
	self._difficulty_locked_indicator:set_h(h)
	self._difficulty_locked_indicator:set_center_y(RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y)
end

-- Lines 166-173
function RaidGUIControlListItemRaids:_layout_difficulty()
	local difficulty_params = {
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = self._object:create_custom_control(RaidGuiControlDifficultyStars, difficulty_params)

	self._difficulty_indicator:set_center_y(RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y)
end

-- Lines 175-184
function RaidGUIControlListItemRaids:_layout_lock_icon()
	local lock_icon_params = {
		texture = tweak_data.gui.icons[RaidGUIControlListItemRaids.LOCK_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlListItemRaids.LOCK_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_dark_grey
	}
	self._lock_icon = self._object:bitmap(lock_icon_params)

	self._lock_icon:set_center_x(self._object:w() - RaidGUIControlListItemRaids.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT)
	self._lock_icon:set_center_y(self._object:h() / 2)
end

-- Lines 186-194
function RaidGUIControlListItemRaids:_layout_breadcrumb()
	local breadcrumb_params = {
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 196-217
function RaidGUIControlListItemRaids:_apply_progression_layout()
	if self._unlocked then
		self._lock_icon:hide()
		self._difficulty_locked_indicator:hide()
		self._difficulty_indicator:show()
		self._item_icon:set_color(RaidGUIControlListItemRaids.UNLOCKED_COLOR)
		self._item_label:set_color(RaidGUIControlListItemRaids.UNLOCKED_COLOR)

		local difficulty_available, difficulty_completed = managers.progression:get_mission_progression(OperationsTweakData.JOB_TYPE_RAID, self._data.value)

		if difficulty_available and difficulty_completed then
			self._difficulty_indicator:set_progress(difficulty_available, difficulty_completed)
		end
	else
		self._lock_icon:show()
		self._difficulty_locked_indicator:show()
		self._difficulty_indicator:hide()
		self._item_icon:set_color(RaidGUIControlListItemRaids.LOCKED_COLOR)
		self._item_label:set_color(RaidGUIControlListItemRaids.LOCKED_COLOR)
	end
end

-- Lines 219-234
function RaidGUIControlListItemRaids:on_mouse_released(button)
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

-- Lines 236-245
function RaidGUIControlListItemRaids:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 247-249
function RaidGUIControlListItemRaids:selected()
	return self._selected
end

-- Lines 251-267
function RaidGUIControlListItemRaids:select()
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

-- Lines 269-272
function RaidGUIControlListItemRaids:unfocus()
	self._item_background:hide()
	self._item_highlight_marker:hide()
end

-- Lines 274-282
function RaidGUIControlListItemRaids:unselect()
	self._selected = false

	self._item_background:hide()

	if self._unlocked then
		self._item_label:set_color(self._color)
	end

	self._item_highlight_marker:hide()
end

-- Lines 284-286
function RaidGUIControlListItemRaids:data()
	return self._data
end

-- Lines 288-304
function RaidGUIControlListItemRaids:highlight_on()
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

-- Lines 306-317
function RaidGUIControlListItemRaids:highlight_off()
	if not managers.menu:is_pc_controller() then
		self._item_highlight_marker:hide()
		self._item_background:hide()
	end

	if not self._selected then
		self._item_background:hide()
	end
end

-- Lines 319-324
function RaidGUIControlListItemRaids:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self._name)

		return true
	end
end
