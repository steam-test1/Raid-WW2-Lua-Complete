RaidGUIControlListItemIconDescription = RaidGUIControlListItemIconDescription or class(RaidGUIControl)
RaidGUIControlListItemIconDescription.ICON_PADDING = 4
RaidGUIControlListItemIconDescription.ICON_PADDING_RIGHT = 10
RaidGUIControlListItemIconDescription.ICON_WIDTH = 42
RaidGUIControlListItemIconDescription.ICON_HEIGHT = 42
RaidGUIControlListItemIconDescription.FONT = tweak_data.gui.fonts.lato
RaidGUIControlListItemIconDescription.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlListItemIconDescription.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.paragraph
RaidGUIControlListItemIconDescription.COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlListItemIconDescription.ACTIVE_COLOR = tweak_data.gui.colors.raid_light_red
RaidGUIControlListItemIconDescription.TITLE_PADDING_DOWN = 13
RaidGUIControlListItemIconDescription.PANEL_PADDING_DOWN = 13
RaidGUIControlListItemIconDescription.SIDELINE_W = 3

-- Lines 17-42
function RaidGUIControlListItemIconDescription:init(parent, params, data)
	RaidGUIControlListItemIconDescription.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemIconDescription:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._data = data

	self:_create_panel()
	self:_create_sideline()
	self:_create_icon()
	self:_create_title()
	self:_create_description()
	self._object:set_h(self._description:y() + self._description:h() + RaidGUIControlListItemIconDescription.PANEL_PADDING_DOWN)

	self._selectable = self._data.selectable
	self._selected = false

	self:highlight_off()
end

-- Lines 44-53
function RaidGUIControlListItemIconDescription:_create_panel()
	local panel_params = {
		name = "list_item_" .. self._name,
		x = self._params.x or 0,
		y = self._params.y or 0,
		w = self._params.w or self._panel:w(),
		h = self._params.h or self._panel:h()
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 55-66
function RaidGUIControlListItemIconDescription:_create_sideline()
	local sideline_params = {
		alpha = 0,
		x = 0,
		y = (self._params.h - RaidGUIControlListItemIconDescription.ICON_HEIGHT) / 2,
		w = RaidGUIControlListItemIconDescription.SIDELINE_W,
		h = RaidGUIControlListItemIconDescription.ICON_HEIGHT,
		color = RaidGUIControlListItemIconDescription.ACTIVE_COLOR
	}
	self._sideline = self._object:rect(sideline_params)
end

-- Lines 68-83
function RaidGUIControlListItemIconDescription:_create_icon()
	local icon_params = {
		name = "list_item_icon_" .. self._name,
		x = self._sideline:x() + self._sideline:w() + RaidGUIControlListItemIconDescription.ICON_PADDING,
		y = (self._params.h - RaidGUIControlListItemIconDescription.ICON_HEIGHT) / 2,
		w = RaidGUIControlListItemIconDescription.ICON_WIDTH,
		h = RaidGUIControlListItemIconDescription.ICON_HEIGHT,
		texture = self._data.icon.texture,
		texture_rect = self._data.icon.texture_rect
	}
	self._icon = self._object:bitmap(icon_params)

	if self._params.icon_color then
		self._icon:set_color(self._params.icon_color)
	end
end

-- Lines 85-103
function RaidGUIControlListItemIconDescription:_create_title()
	local title_params = {
		vertical = "center",
		y = 0,
		name = "list_item_title_" .. tostring(self._name),
		x = self._icon:x() + self._icon:w() + RaidGUIControlListItemIconDescription.ICON_PADDING_RIGHT,
		w = self._params.w,
		h = self._params.h,
		text = self._data.title,
		font = RaidGUIControlListItemIconDescription.FONT,
		font_size = RaidGUIControlListItemIconDescription.TITLE_FONT_SIZE,
		color = RaidGUIControlListItemIconDescription.COLOR
	}
	self._title = self._object:text(title_params)

	self._title:set_w(self._object:w() - self._title:x())

	local _, _, w, h = self._title:text_rect()

	self._title:set_h(h)
	self._title:set_center_y(self._icon:center_y())
end

-- Lines 105-125
function RaidGUIControlListItemIconDescription:_create_description()
	local description_params = {
		wrap = true,
		vertical = "center",
		name = "list_item_description_" .. tostring(self._name),
		x = self._title:x(),
		y = self._title:y() + self._title:h() + RaidGUIControlListItemIconDescription.TITLE_PADDING_DOWN,
		w = self._params.w,
		h = self._params.h,
		text = self._data.description,
		font = RaidGUIControlListItemIconDescription.FONT,
		font_size = RaidGUIControlListItemIconDescription.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlListItemIconDescription.COLOR
	}
	self._description = self._object:text(description_params)

	self._description:set_w(self._object:w() - self._description:x())
	self._description:set_text(self._data.description)

	local _, _, w, h = self._description:text_rect()

	self._description:set_h(h)
end

-- Lines 128-135
function RaidGUIControlListItemIconDescription:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end

	if self._params.list_item_selected_callback then
		self._params.list_item_selected_callback(self._name)
	end
end

-- Lines 137-146
function RaidGUIControlListItemIconDescription:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 148-150
function RaidGUIControlListItemIconDescription:selected()
	return self._selected
end

-- Lines 152-158
function RaidGUIControlListItemIconDescription:select()
	self._selected = true

	self._title:set_color(RaidGUIControlListItemIconDescription.ACTIVE_COLOR)
	self._icon:set_color(RaidGUIControlListItemIconDescription.ACTIVE_COLOR)
	self._sideline:set_alpha(1)
end

-- Lines 160-168
function RaidGUIControlListItemIconDescription:unselect()
	self._selected = false

	if not self._active then
		self._title:set_color(RaidGUIControlListItemIconDescription.COLOR)
	end

	self._icon:set_color(self._params.icon_color or Color.white)
	self._sideline:set_alpha(0)
end

-- Lines 170-172
function RaidGUIControlListItemIconDescription:data()
	return self._data
end

-- Lines 174-176
function RaidGUIControlListItemIconDescription:highlight_on()
	self._title:set_color(RaidGUIControlListItemIconDescription.ACTIVE_COLOR)
end

-- Lines 178-185
function RaidGUIControlListItemIconDescription:highlight_off()
	if not self._active then
		self._title:set_color(RaidGUIControlListItemIconDescription.COLOR)
	end

	self._icon:set_color(self._params.icon_color or Color.white)
	self._sideline:set_alpha(0)
end

-- Lines 187-189
function RaidGUIControlListItemIconDescription:confirm_pressed()
	self:on_mouse_released(Idstring("0"))
end

-- Lines 191-194
function RaidGUIControlListItemIconDescription:activate()
	self._active = true

	self:highlight_on()
end

-- Lines 196-199
function RaidGUIControlListItemIconDescription:deactivate()
	self._active = false

	self:highlight_off()
end

-- Lines 201-203
function RaidGUIControlListItemIconDescription:activated()
	return self._active
end
