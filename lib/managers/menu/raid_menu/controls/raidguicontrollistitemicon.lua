RaidGUIControlListItemIcon = RaidGUIControlListItemIcon or class(RaidGUIControl)
RaidGUIControlListItemIcon.ICON_PADDING = 28
RaidGUIControlListItemIcon.ICON_WIDTH = 42
RaidGUIControlListItemIcon.ICON_HEIGHT = 42

-- Lines 7-42
function RaidGUIControlListItemIcon:init(parent, params, data)
	RaidGUIControlListItemIcon.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemIcon:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._data = data
	self._object = self._panel:panel({
		name = "list_item_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	})
	self._color = params.color or tweak_data.gui.colors.raid_white
	self._selected_color = params.selected_color or tweak_data.gui.colors.raid_red
	self._item_icon = self._object:image({
		name = "list_item_icon_" .. self._name,
		x = RaidGUIControlListItemIcon.ICON_PADDING,
		y = (params.h - RaidGUIControlListItemIcon.ICON_HEIGHT) / 2,
		w = RaidGUIControlListItemIcon.ICON_WIDTH,
		h = RaidGUIControlListItemIcon.ICON_HEIGHT,
		texture = data.icon.texture,
		texture_rect = data.icon.texture_rect,
		color = params.color or tweak_data.gui.colors.raid_white
	})
	self._item_label = self._object:label({
		vertical = "center",
		y = 0,
		name = "list_item_label_" .. self._name,
		x = self._item_icon:x() + self._item_icon:w() + RaidGUIControlListItemIcon.ICON_PADDING,
		w = params.w,
		h = params.h,
		text = data.text,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = params.color or tweak_data.gui.colors.raid_white
	})
	self._item_background = self._object:rect({
		y = 1,
		visible = false,
		x = 0,
		name = "list_item_back_" .. self._name,
		w = params.w,
		h = params.h - 2,
		color = tweak_data.gui.colors.raid_list_background
	})
	self._item_highlight_marker = self._object:rect({
		y = 1,
		w = 3,
		visible = false,
		x = 0,
		name = "list_item_highlight_" .. self._name,
		h = params.h - 2,
		color = self._selected_color
	})
	self._selectable = self._data.selectable
	self._selected = false

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self:highlight_off()
end

-- Lines 44-52
function RaidGUIControlListItemIcon:_layout_breadcrumb()
	local breadcrumb_params = {
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 54-65
function RaidGUIControlListItemIcon:on_mouse_released(button)
	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end

	if self._params.list_item_selected_callback then
		self._params.list_item_selected_callback(self._name)
	end
end

-- Lines 67-76
function RaidGUIControlListItemIcon:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 78-80
function RaidGUIControlListItemIcon:selected()
	return self._selected
end

-- Lines 82-96
function RaidGUIControlListItemIcon:select()
	self._selected = true

	self._item_background:show()
	self._item_label:set_color(self._selected_color)
	self._item_highlight_marker:show()

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

-- Lines 98-101
function RaidGUIControlListItemIcon:unfocus()
	self._item_background:hide()
	self._item_highlight_marker:hide()
end

-- Lines 103-109
function RaidGUIControlListItemIcon:unselect()
	self._selected = false

	self._item_background:hide()
	self._item_label:set_color(self._color)
	self._item_highlight_marker:hide()
end

-- Lines 111-113
function RaidGUIControlListItemIcon:data()
	return self._data
end

-- Lines 115-122
function RaidGUIControlListItemIcon:highlight_on()
	self._item_background:show()

	if self._selected then
		self._item_label:set_color(self._selected_color)
	else
		self._item_label:set_color(self._color)
	end
end

-- Lines 124-135
function RaidGUIControlListItemIcon:highlight_off()
	if not managers.menu:is_pc_controller() then
		self._item_highlight_marker:hide()
		self._item_background:hide()
	end

	if not self._selected then
		self._item_background:hide()
	end
end

-- Lines 137-142
function RaidGUIControlListItemIcon:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self._name)

		return true
	end
end
