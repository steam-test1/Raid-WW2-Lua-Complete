RaidGUIControlBranchingBarSkilltreeNode = RaidGUIControlBranchingBarSkilltreeNode or class(RaidGUIControlBranchingBarNode)
RaidGUIControlBranchingBarSkilltreeNode.DEFAULT_W = 70
RaidGUIControlBranchingBarSkilltreeNode.DEFAULT_H = 70
RaidGUIControlBranchingBarSkilltreeNode.PADDING_HORIZONTAL = 12
RaidGUIControlBranchingBarSkilltreeNode.PADDING_VERTICAL = 8
RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_W = 16
RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_H = 16

-- Lines 12-45
function RaidGUIControlBranchingBarSkilltreeNode:init(parent, params)
	params.w = RaidGUIControlBranchingBarSkilltreeNode.W
	params.h = RaidGUIControlBranchingBarSkilltreeNode.H
	local icon = tweak_data.skilltree.skills[params.value.skill].icon or "skill_placeholder"
	params.w = tweak_data.gui:icon_w(icon) + 2 * RaidGUIControlBranchingBarSkilltreeNode.PADDING_HORIZONTAL
	params.h = tweak_data.gui:icon_h(icon) + 2 * RaidGUIControlBranchingBarSkilltreeNode.PADDING_VERTICAL

	RaidGUIControlBranchingBarSkilltreeNode.super.init(self, parent, params)

	self._data = params.value

	self:_create_selector()
	self:_create_icon()

	self._on_click_callback = params.on_click_callback
	self._on_mouse_enter_callback = params.on_mouse_enter_callback
	self._on_mouse_exit_callback = params.on_mouse_exit_callback
	self._on_mouse_released_callback = params.on_node_mouse_released_callback
	self._on_mouse_pressed_callback = params.on_node_mouse_pressed_callback
	self._on_mouse_moved_callback = params.on_node_mouse_moved_callback

	self:_init_state_data()
	self:refresh_current_state()
	self:_layout_breadcrumb()
end

-- Lines 47-57
function RaidGUIControlBranchingBarSkilltreeNode:_layout_breadcrumb()
	local breadcrumb_params = {
		padding = 3,
		category = BreadcrumbManager.CATEGORY_RANK_REWARD,
		identifiers = {
			self._data.skill
		},
		layer = self._icon:layer() + 1
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_y(0)
end

-- Lines 60-106
function RaidGUIControlBranchingBarSkilltreeNode:_create_selector()
	local selector_panel_params = {
		halign = "scale",
		name = "selector_panel",
		y = 0,
		alpha = 0,
		x = 0,
		valign = "scale",
		w = self._object:w(),
		h = self._object:h()
	}
	self._selector_panel = self._object:panel(selector_panel_params)
	local selector_background_params = {
		halign = "scale",
		name = "selector_background",
		alpha = 1,
		y = 0,
		x = 0,
		valign = "scale",
		w = self._selector_panel:w(),
		h = self._selector_panel:h(),
		color = tweak_data.gui.colors.raid_select_card_background
	}
	self._selector_rect = self._selector_panel:rect(selector_background_params)
	local selector_triangle_up_params = {
		name = "selector_triangle_up",
		y = 0,
		alpha = 1,
		halign = "left",
		x = 0,
		valign = "top",
		w = RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_W,
		h = RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_H,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	}
	self._selector_triangle_up = self._selector_panel:image(selector_triangle_up_params)
	local selector_triangle_down_params = {
		name = "selector_triangle_down",
		alpha = 1,
		halign = "right",
		valign = "bottom",
		x = self._selector_panel:w() - RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_W,
		y = self._selector_panel:h() - RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_H,
		w = RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_W,
		h = RaidGUIControlBranchingBarSkilltreeNode.SELECTOR_TRIANGLE_H,
		texture = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture_rect
	}
	self._selector_triangle_down = self._selector_panel:image(selector_triangle_down_params)
end

-- Lines 108-123
function RaidGUIControlBranchingBarSkilltreeNode:_create_icon()
	local icon = tweak_data.skilltree.skills[self._data.skill].icon or "skill_placeholder"
	local icon_params = {
		name = "skill_icon",
		y = 0,
		halign = "scale",
		x = 0,
		valign = "scale",
		w = tweak_data.gui:icon_w(icon),
		h = tweak_data.gui:icon_h(icon),
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect,
		layer = self._selector_panel:layer() + 5
	}
	self._icon = self._object:image(icon_params)

	self._icon:set_center(self._object:w() / 2, self._object:h() / 2)
end

-- Lines 125-162
function RaidGUIControlBranchingBarSkilltreeNode:_init_state_data()
	self._state_data = {
		STATE_INACTIVE = {}
	}
	self._state_data.STATE_INACTIVE.color = Color("9e9e9e"):with_alpha(0.7)
	self._state_data.STATE_INACTIVE.selector_opacity = 0
	self._state_data.STATE_INACTIVE.show_triangles = false
	self._state_data.STATE_HOVER = {
		color = Color.white,
		selector_opacity = 1,
		show_triangles = false
	}
	self._state_data.STATE_SELECTED = {
		color = Color.white,
		selector_opacity = 1,
		show_triangles = true
	}
	self._state_data.STATE_ACTIVE = {
		color = tweak_data.gui.colors.raid_red,
		selector_opacity = 0,
		show_triangles = false
	}
	self._state_data.STATE_PENDING = {
		color = Color.white,
		selector_opacity = 0,
		show_triangles = false
	}
	self._state_data.STATE_PENDING_BLOCKED = {
		color = Color(0.8705882352941177, 0.615686274509804, 0.615686274509804),
		selector_opacity = 0,
		show_triangles = false
	}
	self._state_data.STATE_DISABLED = {
		color = Color("9e9e9e"):with_alpha(0.7),
		selector_opacity = 0,
		show_triangles = false
	}
end

-- Lines 164-172
function RaidGUIControlBranchingBarSkilltreeNode:set_inactive()
	self._state = self.STATE_INACTIVE

	self:refresh_current_state()
end

-- Lines 174-181
function RaidGUIControlBranchingBarSkilltreeNode:set_hovered()
	self._selector_panel:set_alpha(1)
	self._selector_rect:set_visible(true)
end

-- Lines 183-195
function RaidGUIControlBranchingBarSkilltreeNode:set_selected()
	self._state = self.STATE_SELECTED

	self:refresh_current_state()

	if self._breadcrumb then
		managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_RANK_REWARD, {
			self._data.skill
		})
	end
end

-- Lines 197-204
function RaidGUIControlBranchingBarSkilltreeNode:set_active()
	self._state = self.STATE_ACTIVE

	self:refresh_current_state()
end

-- Lines 206-213
function RaidGUIControlBranchingBarSkilltreeNode:set_pending()
	self._state = self.STATE_PENDING

	self:refresh_current_state()
end

-- Lines 215-222
function RaidGUIControlBranchingBarSkilltreeNode:set_pending_blocked()
	self._state = self.STATE_PENDING_BLOCKED

	self:refresh_current_state()
end

-- Lines 224-227
function RaidGUIControlBranchingBarSkilltreeNode:set_disabled()
	self._state = self.STATE_DISABLED

	self:refresh_current_state()
end

-- Lines 229-236
function RaidGUIControlBranchingBarSkilltreeNode:refresh_current_state()
	self._icon:set_color(self._state_data[self._state].color)
	self._selector_panel:set_alpha(self._state_data[self._state].selector_opacity)
	self._selector_triangle_up:set_visible(self._state_data[self._state].show_triangles)
	self._selector_triangle_down:set_visible(self._state_data[self._state].show_triangles)
	self._selector_rect:set_visible(false)

	self._data.state = self._state
end

-- Lines 238-241
function RaidGUIControlBranchingBarSkilltreeNode:init_to_state(state)
	self._icon:set_color(self._state_data[state].color)
	self:refresh_current_state()
end

-- Lines 243-249
function RaidGUIControlBranchingBarSkilltreeNode:mouse_clicked(o, button, x, y)
	if self:inside(x, y) then
		self:on_mouse_clicked(button)

		return true
	end

	return false
end

-- Lines 251-255
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_clicked(button)
	if self._on_click_callback then
		self:_on_click_callback(self._data)
	end
end

-- Lines 257-266
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_pressed()
	if self._on_mouse_pressed_callback then
		self._on_mouse_pressed_callback()
	end

	self._pressed = true

	if self._state == self.STATE_PENDING then
		self._panel:stop()
	end
end

-- Lines 268-272
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_moved(o, x, y)
	if self._pressed and self._on_mouse_moved_callback then
		self._on_mouse_moved_callback(o, x, y)
	end
end

-- Lines 274-279
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_released()
	if self._on_mouse_released_callback then
		self._on_mouse_released_callback()
	end

	self._pressed = false
end

-- Lines 281-290
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_over(x, y)
	self._mouse_inside = true

	if self._on_mouse_enter_callback then
		self:_on_mouse_enter_callback(self._data)
	end

	if self._breadcrumb then
		managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_RANK_REWARD, {
			self._data.skill
		})
	end
end

-- Lines 293-298
function RaidGUIControlBranchingBarSkilltreeNode:on_mouse_out(x, y)
	self._mouse_inside = false

	if self._on_mouse_exit_callback then
		self:_on_mouse_exit_callback(self._data)
	end
end

-- Lines 301-319
function RaidGUIControlBranchingBarSkilltreeNode:_animate_pressed()
	local t = 0
	local duration = 0.15
	local starting_color = self._icon:color()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quintic_out(t, starting_color.r, self._state_data.STATE_ACTIVE.color.r - starting_color.r, duration)
		local current_g = Easing.quintic_out(t, starting_color.g, self._state_data.STATE_ACTIVE.color.g - starting_color.g, duration)
		local current_b = Easing.quintic_out(t, starting_color.b, self._state_data.STATE_ACTIVE.color.b - starting_color.b, duration)

		self._icon:set_color(Color(current_r, current_g, current_b))
	end

	self._icon:set_color(self._state_data.STATE_ACTIVE.color)
end
