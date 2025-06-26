RaidGUIControlListItemModern = RaidGUIControlListItemModern or class(RaidGUIControl)
RaidGUIControlListItemModern.HEIGHT = 64
RaidGUIControlListItemModern.BACKGROUND_LEFT = "list_item_background_left"
RaidGUIControlListItemModern.BACKGROUND_CENTER = "list_item_background_center"
RaidGUIControlListItemModern.BACKGROUND_RIGHT = "list_item_background_right"
RaidGUIControlListItemModern.BACKGROUND_COLOR = tweak_data.gui.colors.grid_item_grey
RaidGUIControlListItemModern.PURCHASE_COLOR = tweak_data.gui.colors.raid_gold
RaidGUIControlListItemModern.NAME_X = 16
RaidGUIControlListItemModern.NAME_Y = 8
RaidGUIControlListItemModern.NAME_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlListItemModern.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlListItemModern.PURCHASE_VALUE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlListItemModern.PURCHASE_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.subtitle
RaidGUIControlListItemModern.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlListItemModern.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlListItemModern.TEXT_DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey

function RaidGUIControlListItemModern:init(parent, params, data)
	RaidGUIControlListItemModern.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._data = data

	self:_layout_panel(params)
	self:_layout(params, data)

	if not data.unlocked then
		if data.gold_price then
			self:_layout_purchasable(data)
		else
			self:_layout_locked(data)
		end
	end

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end
end

function RaidGUIControlListItemModern:_layout_panel(params)
	self._object = self._panel:panel({
		name = "list_item_modern",
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h or self.HEIGHT
	})
end

function RaidGUIControlListItemModern:_layout_breadcrumb()
	self._breadcrumb = self._object:breadcrumb({
		category = self._data.breadcrumb.category,
		identifiers = self._data.breadcrumb.identifiers,
		layer = self._background:layer() + 10
	})

	self._breadcrumb:set_right(self._object:w() + self.NAME_X)
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

function RaidGUIControlListItemModern:_layout(params, item_data)
	self._background = self._object:three_cut_bitmap({
		alpha = 0,
		name = "background",
		visible = false,
		w = self._object:w(),
		h = self._object:h(),
		left = self.BACKGROUND_LEFT,
		center = self.BACKGROUND_CENTER,
		right = self.BACKGROUND_RIGHT,
		color = self.BACKGROUND_COLOR
	})
	self._name_panel = self._object:panel({
		name = "name_panel",
		x = self.NAME_X,
		layer = self._background:layer() + 1
	})
	local text_color = item_data.unlocked and self.TEXT_COLOR or self.TEXT_DISABLED_COLOR
	self._name_label = self._name_panel:label({
		vertical = "center",
		name = "name_label",
		font = self.NAME_FONT,
		font_size = self.NAME_FONT_SIZE,
		text = item_data.value,
		color = text_color
	})
end

function RaidGUIControlListItemModern:_layout_locked(item_data)
	item_data.separator_highlight_color = self.TEXT_HIGHLIGHT_COLOR
	self._locked_panel = self._object:panel({
		name = "gold_panel",
		w = 25,
		layer = self._background:layer() + 5
	})

	self._locked_panel:set_right(self._object:w() - self.NAME_X)

	local ico_locker = tweak_data.gui:get_full_gui_data("ico_locker")
	self._locked_icon = self._locked_panel:image({
		h = 25,
		w = 25,
		name = "gold_icon",
		texture = ico_locker.texture,
		texture_rect = ico_locker.texture_rect,
		color = self.TEXT_COLOR
	})

	self._locked_icon:set_center_y(self._locked_panel:h() / 2)
end

function RaidGUIControlListItemModern:_layout_purchasable(item_data)
	item_data.separator_highlight_color = self.PURCHASE_COLOR
	self._gold_panel = self._object:panel({
		name = "gold_panel",
		w = 25,
		layer = self._background:layer() + 5
	})

	self._gold_panel:set_right(self._object:w() - self.NAME_X)

	local gold_amount_footer = tweak_data.gui:get_full_gui_data("gold_amount_footer")
	self._gold_icon = self._gold_panel:image({
		h = 25,
		w = 25,
		name = "gold_icon",
		texture = gold_amount_footer.texture,
		texture_rect = gold_amount_footer.texture_rect,
		color = self.PURCHASE_COLOR
	})

	self._gold_icon:set_center_y(self._gold_panel:h() / 2)

	local gold_price = managers.gold_economy:gold_string(item_data.gold_price or 0)
	self._gold_value_label = self._gold_panel:label({
		fit_text = true,
		vertical = "center",
		name = "profile_name_label",
		font = self.PURCHASE_VALUE_FONT,
		font_size = self.PURCHASE_VALUE_FONT_SIZE,
		color = self.PURCHASE_COLOR,
		text = gold_price
	})

	self._gold_value_label:set_left(self._gold_icon:right() + 2)
	self._gold_value_label:set_center_y(self._gold_panel:h() / 2)
end

function RaidGUIControlListItemModern:data()
	return self._data
end

function RaidGUIControlListItemModern:highlight_on()
	if not self._highlighted then
		if self._data.breadcrumb then
			managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
		end

		self._object:stop()
		self._object:animate(callback(self, self, "_animate_select"))

		self._highlighted = true
	end

	if not self._played_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._played_mouse_over_sound = true
	end
end

function RaidGUIControlListItemModern:highlight_off()
	if self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_unselect"))

		self._highlighted = nil
	end

	self._played_mouse_over_sound = nil
end

function RaidGUIControlListItemModern:_animate_select()
	local duration = 0.12
	local t = self._background:alpha() * duration

	self._background:show()

	local normal_color = self._data.unlocked and self.TEXT_COLOR or self.TEXT_DISABLED_COLOR
	local highlight_color = self._data.separator_highlight_color or self.TEXT_HIGHLIGHT_COLOR

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._background:set_alpha(progress)

		if self._gold_panel then
			local current_w = math.lerp(self._gold_icon:w(), self._gold_value_label:right(), progress)

			self._gold_panel:set_w(current_w)
			self._gold_panel:set_right(self._object:w() - self.NAME_X)
			self._gold_value_label:set_alpha(progress)
		end

		local current_x = self.NAME_X * (progress + 1)
		local current_color = math.lerp(normal_color, highlight_color, progress)

		self._name_panel:set_x(current_x)
		self._name_label:set_color(current_color)
	end

	self._background:set_alpha(1)

	if self._gold_panel then
		self._gold_panel:set_w(self._gold_value_label:right())
		self._gold_panel:set_right(self._object:w() - self.NAME_X)
		self._gold_value_label:set_alpha(1)
	end

	self._name_panel:set_x(self.NAME_X * 2)
	self._name_label:set_color(highlight_color)
end

function RaidGUIControlListItemModern:_animate_unselect()
	local duration = 0.12
	local t = (1 - self._background:alpha()) * duration
	local normal_color = self._data.unlocked and self.TEXT_COLOR or self.TEXT_DISABLED_COLOR
	local highlight_color = self._data.separator_highlight_color or self.TEXT_HIGHLIGHT_COLOR

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 1, -1, duration)

		self._background:set_alpha(progress)

		if self._gold_icon then
			local current_w = math.lerp(self._gold_icon:w(), self._gold_value_label:right(), progress)

			self._gold_panel:set_w(current_w)
			self._gold_panel:set_right(self._object:w() - self.NAME_X)
			self._gold_value_label:set_alpha(progress)
		end

		local current_x = self.NAME_X * (progress + 1)
		local current_color = math.lerp(normal_color, highlight_color, progress)

		self._name_panel:set_x(current_x)
		self._name_label:set_color(current_color)
	end

	self._background:hide()
	self._background:set_alpha(0)

	if self._gold_panel then
		self._gold_panel:set_w(self._gold_icon:w())
		self._gold_panel:set_right(self._object:w() - self.NAME_X)
		self._gold_value_label:set_alpha(0)
	end

	self._name_panel:set_x(self.NAME_X)
	self._name_label:set_color(normal_color)
end

function RaidGUIControlListItemModern:on_mouse_released(button)
	return self:activate()
end

function RaidGUIControlListItemModern:confirm_pressed()
	if not self._selected then
		return false
	end

	return self:activate()
end

function RaidGUIControlListItemModern:activate()
	if self._on_click_callback then
		self._on_click_callback(nil, self, self._data, true)

		return true
	end
end

function RaidGUIControlListItemModern:select(dont_trigger_selected_callback)
	if self._selected then
		return
	end

	self._selected = true

	self:highlight_on()

	if self._on_item_selected_callback and not dont_trigger_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

function RaidGUIControlListItemModern:unselect()
	if self._selected then
		self._selected = false

		self:highlight_off()
	end
end

function RaidGUIControlListItemModern:selected()
	return self._selected
end
