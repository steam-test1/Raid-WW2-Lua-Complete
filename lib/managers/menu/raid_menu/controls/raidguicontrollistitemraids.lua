RaidGUIControlListItemRaids = RaidGUIControlListItemRaids or class(RaidGUIControl)
RaidGUIControlListItemRaids.HEIGHT = 86
RaidGUIControlListItemRaids.NAME_CENTER_Y = RaidGUIControlListItemRaids.HEIGHT * 0.33
RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y = RaidGUIControlListItemRaids.HEIGHT * 0.66
RaidGUIControlListItemRaids.ICON_CENTER_X = 40
RaidGUIControlListItemRaids.ICON_PADDING = 20
RaidGUIControlListItemRaids.LOCK_ICON = "ico_locker"
RaidGUIControlListItemRaids.LOCK_ICON_CENTER_DISTANCE_FROM_RIGHT = 43
RaidGUIControlListItemRaids.LOCKED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlListItemRaids.UNLOCKED_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlListItemRaids.DEBUG_LOCKED_COLOR = Color(0.2, 0.5, 0.2)
RaidGUIControlListItemRaids.DEBUG_UNLOCKED_COLOR = Color(0.4, 1, 0.4)

function RaidGUIControlListItemRaids:init(parent, params, data)
	RaidGUIControlListItemRaids.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemRaids:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._mouse_over_sound = params.on_mouse_over_sound_event
	self._mouse_click_sound = params.on_mouse_click_sound_event
	self._data = data
	local mission_data = data.mission_data or tweak_data.operations.missions[data.value]
	self._is_consumable = not not mission_data.consumable
	self._is_debug = not not mission_data.debug
	self._is_unlocked = data.unlocked or managers.progression:mission_unlocked(OperationsTweakData.JOB_TYPE_RAID, data.value)
	self._color = params.color or tweak_data.gui.colors.raid_white
	self._selected_color = params.selected_color or tweak_data.gui.colors.raid_red

	if self._is_debug then
		self._color = RaidGUIControlListItemRaids.DEBUG_UNLOCKED_COLOR

		if self._is_unlocked then
			self._color_type = RaidGUIControlListItemRaids.DEBUG_UNLOCKED_COLOR
		else
			self._color_type = RaidGUIControlListItemRaids.DEBUG_LOCKED_COLOR
		end
	elseif self._is_unlocked then
		self._color_type = RaidGUIControlListItemRaids.UNLOCKED_COLOR
	else
		self._color_type = RaidGUIControlListItemRaids.LOCKED_COLOR
	end

	self:_layout_panel(params)
	self:_layout_background(params)
	self:_layout_highlight_marker()
	self:_layout_icon(params, data)
	self:_layout_raid_name(params, data)
	self:_layout_exp(params, data)

	if self._is_consumable then
		self:_layout_consumable_mission_label()
	else
		self:_layout_difficulty_locked()
		self:_layout_difficulty()
		self:_layout_lock_icon()
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

function RaidGUIControlListItemRaids:_layout_background(params)
	local background_params = {
		visible = false,
		y = 1,
		x = 0,
		name = "list_item_back_" .. self._name,
		w = params.w,
		h = self._object:h() - 2,
		color = tweak_data.gui.colors.raid_list_background
	}
	self._item_background = self._object:rect(background_params)
end

function RaidGUIControlListItemRaids:_layout_highlight_marker()
	local marker_params = {
		visible = false,
		w = 3,
		y = 1,
		x = 0,
		name = "list_item_highlight_" .. self._name,
		h = self._object:h() - 2,
		color = self._selected_color
	}
	self._item_highlight_marker = self._object:rect(marker_params)
end

function RaidGUIControlListItemRaids:_layout_icon(params, data)
	local icon_params = {
		name = "list_item_icon_" .. self._name,
		x = RaidGUIControlListItemRaids.ICON_PADDING,
		y = (RaidGUIControlListItemRaids.HEIGHT - data.icon.texture_rect[4]) / 2,
		texture = data.icon.texture,
		texture_rect = data.icon.texture_rect,
		color = self:_get_mission_color()
	}
	self._item_icon = self._object:image(icon_params)

	self._item_icon:set_center_x(RaidGUIControlListItemRaids.ICON_CENTER_X)
	self._item_icon:set_center_y(self._object:h() / 2)
end

function RaidGUIControlListItemRaids:_layout_raid_name(params, data)
	local raid_name_params = {
		vertical = "center",
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

function RaidGUIControlListItemRaids:_layout_exp(params, data)
	local xp_value = data.mission_data and data.mission_data.xp or tweak_data.operations.missions[self._data.value].xp or 0
	self._exp_label = self._object:text({
		align = "right",
		vertical = "center",
		name = "list_item_exp_label_" .. self._name,
		text = utf8.to_upper(xp_value .. " XP"),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_grey
	})
	local _, _, w, h = self._exp_label:text_rect()

	self._exp_label:set_size(w, h)
	self._exp_label:set_right(self._item_label:w() - 20)
	self._exp_label:set_center_y(RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y)
end

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

function RaidGUIControlListItemRaids:_layout_difficulty_locked()
	local locked_subtext = self:translate("raid_next_raid_in_description", true)
	local difficulty_locked_params = {
		vertical = "center",
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		text = locked_subtext,
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

function RaidGUIControlListItemRaids:_layout_difficulty()
	local difficulty_params = {
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemRaids.ICON_PADDING,
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = self._object:create_custom_control(RaidGuiControlDifficultyStars, difficulty_params)

	self._difficulty_indicator:set_center_y(RaidGUIControlListItemRaids.DIFFICULTY_CENTER_Y)
end

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

function RaidGUIControlListItemRaids:_get_mission_color()
	return self._is_consumable and tweak_data.gui.colors.raid_gold or tweak_data.gui.colors.raid_dirty_white
end

function RaidGUIControlListItemRaids:_layout_breadcrumb()
	local breadcrumb_params = {
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_left(4)
	self._breadcrumb:set_center_y(16)
end

function RaidGUIControlListItemRaids:_apply_progression_layout()
	if self._is_unlocked then
		self._lock_icon:hide()
		self._exp_label:show()
		self._difficulty_locked_indicator:hide()
		self._difficulty_indicator:show()

		local difficulty_available, difficulty_completed = managers.progression:get_mission_progression(OperationsTweakData.JOB_TYPE_RAID, self._data.value)

		if difficulty_available and difficulty_completed then
			self._difficulty_indicator:set_progress(difficulty_available, difficulty_completed)
		end

		self._item_icon:set_color(self._color)
	else
		self._lock_icon:show()
		self._exp_label:hide()
		self._difficulty_locked_indicator:show()
		self._difficulty_indicator:hide()
		self._item_icon:set_color(self._color_type)
	end

	self._item_label:set_color(self._color_type)
end

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

function RaidGUIControlListItemRaids:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

function RaidGUIControlListItemRaids:selected()
	return self._selected
end

function RaidGUIControlListItemRaids:select()
	self._selected = true

	self._item_background:show()

	if self._is_unlocked then
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

function RaidGUIControlListItemRaids:unfocus()
	self._item_background:hide()
	self._item_highlight_marker:hide()
end

function RaidGUIControlListItemRaids:unselect()
	self._selected = false

	self._item_background:hide()

	if self._is_unlocked then
		self._item_label:set_color(self._color_type)
	end

	self._item_highlight_marker:hide()
end

function RaidGUIControlListItemRaids:data()
	return self._data
end

function RaidGUIControlListItemRaids:highlight_on()
	self._item_background:show()

	if self._mouse_over_sound then
		managers.menu_component:post_event(self._mouse_over_sound)
	end

	if not self._is_unlocked then
		return
	end

	if self._selected then
		self._item_label:set_color(self._selected_color)
	else
		self._item_label:set_color(self._color_type)
	end
end

function RaidGUIControlListItemRaids:highlight_off()
	if not managers.menu:is_pc_controller() then
		self._item_highlight_marker:hide()
		self._item_background:hide()
	end

	if not self._selected then
		self._item_background:hide()
	end
end

function RaidGUIControlListItemRaids:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self._name)

		return true
	end
end
