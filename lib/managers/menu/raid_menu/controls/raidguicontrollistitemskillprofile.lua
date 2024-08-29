RaidGUIControlListItemSkillProfile = RaidGUIControlListItemSkillProfile or class(RaidGUIControl)
RaidGUIControlListItemSkillProfile.HEIGHT = 64
RaidGUIControlListItemSkillProfile.BACKGROUND_COLOR = tweak_data.gui.colors.list_item_background
RaidGUIControlListItemSkillProfile.PURCHASE_COLOR = tweak_data.gui.colors.raid_gold
RaidGUIControlListItemSkillProfile.NAME_X = 16
RaidGUIControlListItemSkillProfile.NAME_Y = 8
RaidGUIControlListItemSkillProfile.NAME_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlListItemSkillProfile.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlListItemSkillProfile.PURCHASE_VALUE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlListItemSkillProfile.PURCHASE_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.subtitle
RaidGUIControlListItemSkillProfile.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlListItemSkillProfile.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlListItemSkillProfile.TEXT_DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlListItemSkillProfile.RENAME_BUTTON_SIZE = 46
RaidGUIControlListItemSkillProfile.RENAME_BUTTON_ICON = "list_btn_ico_rename"

-- Lines 26-36
function RaidGUIControlListItemSkillProfile:init(parent, params, data)
	RaidGUIControlListItemSkillProfile.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._special_action_callback = params.special_action_callback
	self._data = data

	self:_layout_panel(params)
	self:_layout(params, data)
end

-- Lines 38-46
function RaidGUIControlListItemSkillProfile:_layout_panel(params)
	self._object = self._panel:panel({
		name = "skill_profile_list_item",
		x = params.x,
		y = params.y,
		w = params.w,
		h = self.HEIGHT
	})
end

-- Lines 48-75
function RaidGUIControlListItemSkillProfile:_layout(params, item_data)
	self._background = self._object:gradient({
		visible = false,
		alpha = 0,
		w = self._object:w(),
		h = self._object:h(),
		gradient_points = self.BACKGROUND_COLOR
	})
	self._name_panel = self._object:panel({
		name = "profile_name_panel",
		x = self.NAME_X,
		layer = self._background:layer() + 1
	})
	self._context_info_panel = self._object:panel({
		name = "context_info_panel",
		visible = false,
		layer = self._background:layer() + 1
	})

	if item_data.unlocked then
		self:_layout_equipable(item_data)
	else
		self:_layout_purchasable(item_data)
	end
end

-- Lines 77-105
function RaidGUIControlListItemSkillProfile:_layout_equipable(item_data)
	item_data.separator_highlight_color = nil
	self._profile_name_label = self._name_panel:label({
		name = "profile_name_label",
		vertical = "center",
		font = self.NAME_FONT,
		font_size = self.NAME_FONT_SIZE,
		text = item_data.value,
		color = self.TEXT_COLOR,
		layer = self._background:layer() + 1
	})
	local gui_data = tweak_data.gui:get_full_gui_data(self.RENAME_BUTTON_ICON)
	self._rename_profile_button = self._context_info_panel:create_custom_control(RaidGUIControlListItemContextButton, {
		name = "rename_profile_button",
		w = self.RENAME_BUTTON_SIZE,
		h = self.RENAME_BUTTON_SIZE,
		on_click_callback = self._special_action_callback,
		callback_value = self._data.key,
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		visible = not managers.controller:is_controller_present(),
		layer = self._background:layer() + 1
	})

	self._rename_profile_button:set_right(self._context_info_panel:w())
	self._rename_profile_button:set_center_y(self._context_info_panel:h() / 2)
end

-- Lines 107-146
function RaidGUIControlListItemSkillProfile:_layout_purchasable(item_data)
	item_data.separator_highlight_color = self.PURCHASE_COLOR
	self._profile_name_label = self._name_panel:label({
		name = "profile_name_label",
		vertical = "center",
		font = self.NAME_FONT,
		font_size = self.NAME_FONT_SIZE,
		text = item_data.value,
		color = self.TEXT_DISABLED_COLOR
	})
	local purchase_cost = item_data.purchase_cost and tostring(item_data.purchase_cost)
	self._gold_value_label = self._context_info_panel:label({
		name = "profile_name_label",
		fit_text = true,
		vertical = "center",
		font = self.PURCHASE_VALUE_FONT,
		font_size = self.PURCHASE_VALUE_FONT_SIZE,
		text = purchase_cost,
		color = self.PURCHASE_COLOR
	})

	self._gold_value_label:set_center_y(self._context_info_panel:h() / 2)
	self._context_info_panel:set_w(self._gold_value_label:w())

	local gold_amount_footer = tweak_data.gui:get_full_gui_data("gold_amount_footer")
	self._gold_icon = self._object:image({
		name = "profile_gold_icon",
		h = 25,
		w = 25,
		texture = gold_amount_footer.texture,
		texture_rect = gold_amount_footer.texture_rect,
		color = self.PURCHASE_COLOR
	})

	self._gold_icon:set_right(self._object:w() - self.NAME_X)
	self._gold_icon:set_center_y(self._object:h() / 2)
end

-- Lines 148-150
function RaidGUIControlListItemSkillProfile:data()
	return self._data
end

-- Lines 152-163
function RaidGUIControlListItemSkillProfile:mouse_released(o, button, x, y)
	if self._rename_profile_button and self._rename_profile_button:inside(x, y) then
		return self._rename_profile_button:mouse_released(o, button, x, y)
	end

	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end
end

-- Lines 166-181
function RaidGUIControlListItemSkillProfile:highlight_on()
	if self._rename_profile_button then
		self._rename_profile_button:set_visible(not managers.controller:is_controller_present())
	end

	if not self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_select"))

		self._highlighted = true
	end

	if not self._played_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._played_mouse_over_sound = true
	end
end

-- Lines 183-192
function RaidGUIControlListItemSkillProfile:highlight_off()
	if self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_unselect"))

		self._highlighted = nil
	end

	self._played_mouse_over_sound = nil
end

-- Lines 194-239
function RaidGUIControlListItemSkillProfile:_animate_select()
	local duration = 0.12
	local t = self._background:alpha() * duration

	self._background:show()
	self._context_info_panel:show()

	local normal_color = self._data.unlocked and self.TEXT_COLOR or self.TEXT_DISABLED_COLOR
	local highlight_color = self._data.unlocked and self.TEXT_HIGHLIGHT_COLOR or self.PURCHASE_COLOR

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._background:set_alpha(progress)

		local current_offset = self.NAME_X * progress

		self._context_info_panel:set_alpha(progress)
		self._context_info_panel:set_right(self._object:w() - current_offset)

		if self._gold_icon then
			local current_w = self._context_info_panel:w() * progress

			self._gold_icon:set_right(self._object:w() - self.NAME_X - current_w)
		end

		local current_x = progress + 1
		local current_color = math.lerp(normal_color, highlight_color, progress)

		self._name_panel:set_x(self.NAME_X * current_x)
		self._profile_name_label:set_color(current_color)
	end

	self._background:set_alpha(1)
	self._context_info_panel:set_right(self._object:w() - self.NAME_X)

	if self._gold_icon then
		self._gold_icon:set_right(self._context_info_panel:x())
	end

	self._name_panel:set_x(self.NAME_X * 2)
	self._profile_name_label:set_color(highlight_color)
end

-- Lines 241-285
function RaidGUIControlListItemSkillProfile:_animate_unselect()
	local duration = 0.12
	local t = (1 - self._background:alpha()) * duration
	local normal_color = self._data.unlocked and self.TEXT_COLOR or self.TEXT_DISABLED_COLOR
	local highlight_color = self._data.unlocked and self.TEXT_HIGHLIGHT_COLOR or self.PURCHASE_COLOR

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 1, -1, duration)

		self._background:set_alpha(progress)

		local current_offset = self.NAME_X * progress

		self._context_info_panel:set_alpha(progress)
		self._context_info_panel:set_right(self._object:w() - current_offset)

		if self._gold_icon then
			local current_w = self._context_info_panel:w() * progress

			self._gold_icon:set_right(self._object:w() - self.NAME_X - current_w)
		end

		local current_x = progress + 1
		local current_color = math.lerp(normal_color, highlight_color, progress)

		self._name_panel:set_x(self.NAME_X * current_x)
		self._profile_name_label:set_color(current_color)
	end

	self._background:hide()
	self._background:set_alpha(0)
	self._context_info_panel:hide()
	self._context_info_panel:set_right(self._object:w())

	if self._gold_icon then
		self._gold_icon:set_right(self._object:w() - self.NAME_X)
	end

	self._name_panel:set_x(self.NAME_X)
	self._profile_name_label:set_color(normal_color)
end

-- Lines 287-289
function RaidGUIControlListItemSkillProfile:on_mouse_released(button)
	self:activate()
end

-- Lines 291-297
function RaidGUIControlListItemSkillProfile:confirm_pressed()
	if not self._selected then
		return false
	end

	self:activate()
end

-- Lines 299-324
function RaidGUIControlListItemSkillProfile:activate()
	local profile_purchased = managers.skilltree:is_skill_profile_purchased(self._data.key)

	if not profile_purchased then
		local purchase_cost = tweak_data.skilltree.skill_profiles[self._data.key]

		if purchase_cost and purchase_cost <= managers.gold_economy:current() then
			local confirm_callback = callback(self, self, "on_profile_purchased")

			managers.menu:show_skill_profile_purchase_dialog({
				callback_yes = confirm_callback,
				amount = purchase_cost
			})
		else
			managers.menu_component:post_event("generic_fail_sound")
		end

		return
	end

	if self._on_click_callback then
		self._on_click_callback(nil, self, self._data, true)

		return true
	end
end

-- Lines 326-336
function RaidGUIControlListItemSkillProfile:on_profile_purchased()
	local purchased = managers.skilltree:purchase_skill_profile(self._data.key)

	if purchased then
		managers.menu_component:post_event("gold_spending_apply")

		if self._on_click_callback then
			self._on_click_callback(nil, self, self._data, true)
		end
	end
end

-- Lines 338-348
function RaidGUIControlListItemSkillProfile:select(dont_trigger_selected_callback)
	if not self._selected then
		self._selected = true

		self:highlight_on()

		if self._on_item_selected_callback and not dont_trigger_selected_callback then
			self:_on_item_selected_callback(self._data)
		end
	end
end

-- Lines 350-356
function RaidGUIControlListItemSkillProfile:unselect()
	if self._selected then
		self._selected = false

		self:highlight_off()
	end
end

-- Lines 358-360
function RaidGUIControlListItemSkillProfile:selected()
	return self._selected
end
