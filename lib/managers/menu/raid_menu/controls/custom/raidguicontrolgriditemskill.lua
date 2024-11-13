RaidGUIControlGridItemSkill = RaidGUIControlGridItemSkill or class(RaidGUIControlGridItem)
RaidGUIControlGridItemSkill.STATE_NORMAL = "STATE_NORMAL"
RaidGUIControlGridItemSkill.STATE_APPLIED = "STATE_APPLIED"
RaidGUIControlGridItemSkill.STATE_LOCKED = "STATE_LOCKED"
RaidGUIControlGridItemSkill.STATE_PURCHASABLE = "STATE_PURCHASABLE"
RaidGUIControlGridItemSkill.OUTLINE_THICKNESS = 1
RaidGUIControlGridItemSkill.OUTLINE_THICKNESS_SELECTED = 3
RaidGUIControlGridItemSkill.TRIANGLE_PADDING = 4
RaidGUIControlGridItemSkill.MAX_TIER = 4
RaidGUIControlGridItemSkill.ROMAN_NUMBERS = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}

local function to_roman(i)
	return RaidGUIControlGridItemSkill.ROMAN_NUMBERS[i]
end

function RaidGUIControlGridItemSkill:init(parent, params, item_data, grid_params)
	self:_init_state_data()

	self._highlighted = false

	RaidGUIControlGridItemSkill.super.init(self, parent, params, item_data)
	self._skill_triangle:set_color(self._item_data[self._params.grid_item_tag_color] or Color.white)
	self._skill_triangle:set_left(-RaidGUIControlGridItemSkill.TRIANGLE_PADDING + self._grid_item_icon:right())
	self._skill_triangle:set_top(RaidGUIControlGridItemSkill.TRIANGLE_PADDING + self._grid_item_icon:top())

	self._play_mouse_over_sound = true

	self:_toggle_visibility_status_icons()

	if self:_is_unlocked() or self:_is_applied() then
		self:_layout_level_tier(item_data.exp_tier or 1)
	end
end

function RaidGUIControlGridItemSkill:_layout_grid_item_icon(params)
	local image_coord_x = (params.selected_marker_w - params.item_w) / 2
	local image_coord_y = (params.selected_marker_h - params.item_h) / 2
	local gui_icon = tweak_data.gui:get_full_gui_data(self._item_data[self._params.grid_item_icon])
	self._grid_item_icon = self._object:rect({
		color = nil,
		layer = 10,
		w = nil,
		y = nil,
		x = nil,
		name = "grid_item_icon",
		h = nil,
		x = image_coord_x,
		y = image_coord_y,
		w = params.item_w,
		h = params.item_h,
		color = tweak_data.gui.colors.raid_grey
	})
	local grid_item_fg = tweak_data.gui:get_full_gui_data("grid_item_fg")
	self._grid_item_icon_fg = self._object:bitmap({
		color = nil,
		layer = 12,
		texture_rect = nil,
		texture = nil,
		w = nil,
		y = nil,
		x = nil,
		name = "grid_item_icon_fg",
		h = nil,
		x = image_coord_x + RaidGUIControlGridItemSkill.OUTLINE_THICKNESS,
		y = image_coord_y + RaidGUIControlGridItemSkill.OUTLINE_THICKNESS,
		w = params.item_w - RaidGUIControlGridItemSkill.OUTLINE_THICKNESS * 2,
		h = params.item_h - RaidGUIControlGridItemSkill.OUTLINE_THICKNESS * 2,
		texture = grid_item_fg.texture,
		texture_rect = grid_item_fg.texture_rect,
		color = tweak_data.gui.colors.grid_item_grey
	})
	self._grid_item_icon_sprite = self._object:bitmap({
		name = "grid_item_icon_sprite",
		layer = 13,
		w = nil,
		texture_rect = nil,
		texture = nil,
		h = nil,
		texture = gui_icon.texture,
		texture_rect = gui_icon.texture_rect,
		w = params.icon_size_off or params.item_w * 0.6,
		h = params.icon_size_off or params.item_w * 0.6
	})

	self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())

	self._selected_icon_size = params.icon_size_on or params.item_w
	self._unselected_icon_size = params.icon_size_off or params.item_w * 0.6
end

function RaidGUIControlGridItemSkill:_layout_level_tier(level)
	if level and level > 0 then
		self._level_tier_text = self._object:text({
			h = 32,
			align = "left",
			layer = 50,
			font_size = nil,
			font = nil,
			text = nil,
			w = 32,
			name = "level_tier_text",
			vertical = "center",
			font = tweak_data.gui.fonts.lato,
			font_size = tweak_data.gui.font_sizes.size_18,
			text = to_roman(level)
		})

		self._level_tier_text:set_left(self._grid_item_icon_fg:left() + 4)
		self._level_tier_text:set_bottom(self._grid_item_icon_fg:bottom() + 8)

		if RaidGUIControlGridItemSkill.MAX_TIER <= level then
			self._level_tier_text:set_color(tweak_data.gui.colors.raid_light_gold)
		end
	end
end

function RaidGUIControlGridItemSkill:_layout_locks()
	self._item_status_panel = self._object:panel({
		name = "grid_item_lock_panel",
		layer = 50
	})
end

function RaidGUIControlGridItemSkill:_clear_locks()
	if self._item_status_panel then
		self._item_status_panel:clear()
	end
end

function RaidGUIControlGridItemSkill:_layout_lock_locked()
	self:_clear_locks()

	local grid_item_locked = tweak_data.gui:get_full_gui_data("grid_item_locked")
	local status_lock_bg = self._item_status_panel:image({
		texture = nil,
		color = nil,
		w = nil,
		texture_rect = nil,
		name = "grid_item_lock_bg",
		h = nil,
		w = self._item_status_panel:w(),
		h = self._item_status_panel:h(),
		texture = grid_item_locked.texture,
		texture_rect = grid_item_locked.texture_rect,
		color = grid_item_locked.color
	})
	local ico_locker = tweak_data.gui:get_full_gui_data("ico_locker")
	self._item_status_lock_icon = self._item_status_panel:image({
		texture = nil,
		color = nil,
		layer = nil,
		w = 40,
		texture_rect = nil,
		name = "grid_item_lock_icon",
		h = 40,
		texture = ico_locker.texture,
		texture_rect = ico_locker.texture_rect,
		color = ico_locker.color,
		layer = status_lock_bg:layer() + 1
	})

	self._item_status_lock_icon:set_center_x(self._grid_item_icon:w() / 2)
	self._item_status_lock_icon:set_center_y(self._grid_item_icon:h() / 2 - 10)

	local text = tostring(math.round(self._item_data.level_required or 0))
	self._item_status_lock_text = self._item_status_panel:text({
		font = nil,
		text = nil,
		color = nil,
		layer = nil,
		font_size = nil,
		align = "center",
		name = "grid_item_lock_text",
		h = 24,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		text = text,
		color = tweak_data.gui.colors.raid_white,
		layer = status_lock_bg:layer() + 1
	})

	self._item_status_lock_text:set_center_x(self._grid_item_icon:w() / 2)
	self._item_status_lock_text:set_top(self._item_status_lock_icon:bottom())
end

function RaidGUIControlGridItemSkill:_layout_lock_purchasable()
	self:_clear_locks()

	local gold_amount_footer = tweak_data.gui:get_full_gui_data("gold_amount_footer")
	self._item_status_resource_icon = self._item_status_panel:image({
		texture = nil,
		name = "grid_item_resource_icon",
		w = 25,
		texture_rect = nil,
		color = nil,
		h = 25,
		texture = gold_amount_footer.texture,
		texture_rect = gold_amount_footer.texture_rect,
		color = tweak_data.gui.colors.gold_orange
	})

	self._item_status_resource_icon:set_left(self._grid_item_icon:left() + 4)
	self._item_status_resource_icon:set_bottom(self._grid_item_icon:bottom() - 4)
end

function RaidGUIControlGridItemSkill:_layout_lock_dlc()
	self:_clear_locks()

	local ico_dlc = tweak_data.gui:get_full_gui_data("ico_dlc")
	self._item_status_dlc_lock = self._item_status_panel:image({
		name = "grid_item_dlc_lock_icon",
		texture_rect = nil,
		texture = nil,
		layer = 20,
		texture = ico_dlc.texture,
		texture_rect = ico_dlc.texture_rect
	})

	self._item_status_dlc_lock:set_left(self._grid_item_icon:left() + 4)
	self._item_status_dlc_lock:set_bottom(self._grid_item_icon:bottom() - 4)
end

function RaidGUIControlGridItemSkill:_layout_triangles()
	local layer = 50
	local ico_sel_rect_top_left_white = tweak_data.gui:get_full_gui_data("ico_sel_rect_top_left_white")
	local params = {
		layer = nil,
		w = -18,
		texture_rect = nil,
		texture = nil,
		h = 18,
		texture = ico_sel_rect_top_left_white.texture,
		texture_rect = ico_sel_rect_top_left_white.texture_rect,
		layer = layer
	}
	self._skill_triangle = self._triangle_markers_panel:image(params)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_icons()
	self:set_state(self._item_data.status)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_owned_unlocked()
	self:set_state(RaidGUIControlGridItemSkill.STATE_NORMAL)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_applied()
	self:set_state(RaidGUIControlGridItemSkill.STATE_APPLIED)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_locked()
	self:set_state(RaidGUIControlGridItemSkill.STATE_LOCKED)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_purchasable()
	self:set_state(RaidGUIControlGridItemSkill.STATE_PURCHASABLE)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_not_enough_resources()
	self:set_state(RaidGUIControlGridItemSkill.STATE_LOCKED)
end

function RaidGUIControlGridItemSkill:_toggle_visibility_status_locked_dlc()
	self:set_state(RaidGUIControlGridItemSkill.STATE_LOCKED)
end

function RaidGUIControlGridItemSkill:set_state(state)
	self._state = state
	self._item_data.active = self:_is_applied()

	if state == RaidGUIControlGridItemSkill.STATE_LOCKED then
		self:_layout_lock_locked()
	elseif state == RaidGUIControlGridItemSkill.STATE_PURCHASABLE then
		self:_layout_lock_purchasable()
	else
		self:_clear_locks()
	end

	if self._item_data.active then
		local trangle_alpha = self._state_data[self._state].show_selector_triangles_alpha

		self._skill_triangle:set_alpha(trangle_alpha)
		self._triangle_markers_panel:show()
	else
		self._triangle_markers_panel:hide()
	end

	self:_update_style()
end

function RaidGUIControlGridItemSkill:select(dont_fire_selected_callback)
	Application:debug("[RaidGUIControlGridItemSkill:select] skill", self._item_data.key_name, "dont_fire_selected_callback", dont_fire_selected_callback)
	RaidGUIControlGridItemSkill.super.select(self, dont_fire_selected_callback)
end

function RaidGUIControlGridItemSkill:unselect()
	RaidGUIControlGridItemSkill.super.unselect(self)
end

function RaidGUIControlGridItemSkill:on_mouse_released(button)
	self:activate()
end

function RaidGUIControlGridItemSkill:activate()
	if self:can_activate() then
		if self:_is_applied() then
			self:_toggle_visibility_status_owned_unlocked()
			managers.menu_component:post_event("skill_remove")
		else
			self:_toggle_visibility_status_applied()
			managers.menu_component:post_event("skill_select")
		end
	else
		if self:_can_buy_and_afford() then
			local confirm_callback = callback(self, self, "on_skill_purchase_confirmed")

			managers.menu:show_skill_selection_confirm_dialog({
				yes_callback = nil,
				yes_callback = confirm_callback
			})
		else
			managers.menu_component:post_event("generic_fail_sound")
			self._object:animate(callback(self, self, "_animate_shake"))
		end

		return
	end

	self._grid_item_icon:stop()
	self._grid_item_icon:animate(callback(self, self, "_animate_clicked"))

	if self._on_click_callback then
		self._on_click_callback(self._item_data, self._params.key_value_field)
	end
end

function RaidGUIControlGridItemSkill:deactivate()
end

function RaidGUIControlGridItemSkill:on_mouse_over(x, y)
	RaidGUIControlGridItemSkill.super.on_mouse_over(self, x, y)

	if self._on_selected_callback then
		self._on_selected_callback(self._params.item_idx, self._item_data)
	end
end

function RaidGUIControlGridItemSkill:on_skill_purchase_confirmed()
	local purchased = managers.skilltree:purchase_skill(self._item_data.key_name)

	if purchased then
		self._item_data.bought = true

		managers.menu_component:post_event("gold_spending_apply")
		self:_toggle_visibility_status_owned_unlocked()

		if self._on_click_callback then
			self._on_click_callback(self._item_data, self._params.key_value_field)
		end
	end
end

function RaidGUIControlGridItemSkill:select_on()
	self:highlight_on()
end

function RaidGUIControlGridItemSkill:select_off()
	self:highlight_off()
end

function RaidGUIControlGridItemSkill:highlight_on()
	if not self._highlighted then
		self._grid_item_icon:stop()
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight", true))
	end

	self._highlighted = true

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

function RaidGUIControlGridItemSkill:highlight_off()
	if self._highlighted then
		self._grid_item_icon:stop()
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight", false))
	end

	self._highlighted = false
	self._play_mouse_over_sound = true
end

function RaidGUIControlGridItemSkill:_animate_highlight(highlighted)
	local state_data = self._state_data[self._state]

	self._object:set_x(self._params.x)
	self._object:set_y(self._params.y)

	local t = 0
	local duration = 0.15
	local progress_start = highlighted and 0 or 1
	local progress_end = highlighted and 1 or -1

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in_out(t, progress_start, progress_end, duration)
		local current_color = math.lerp(state_data.highlight_off, state_data.highlight_on, progress)

		self._grid_item_icon:set_color(current_color)

		local current_size = math.lerp(RaidGUIControlGridItemSkill.OUTLINE_THICKNESS, RaidGUIControlGridItemSkill.OUTLINE_THICKNESS_SELECTED, progress)

		self._grid_item_icon_fg:set_shape(self._grid_item_icon:x() + current_size, self._grid_item_icon:y() + current_size, self._grid_item_icon:w() - current_size * 2, self._grid_item_icon:h() - current_size * 2)

		current_color = math.lerp(state_data.icon_off, state_data.icon_on, progress)

		self._grid_item_icon_sprite:set_color(current_color)

		current_size = math.lerp(self._unselected_icon_size, self._selected_icon_size, progress)

		self._grid_item_icon_sprite:set_w(current_size)
		self._grid_item_icon_sprite:set_h(current_size)
		self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())

		local current_alpha = math.lerp(state_data.locks_alpha_highlight_off, state_data.locks_alpha_highlight_on, progress)

		self._item_status_panel:set_alpha(current_alpha)
	end

	self:_update_style()
end

function RaidGUIControlGridItemSkill:_animate_clicked()
	local state_data = self._state_data[self._state]
	local t = 0
	local duration = 0.25

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_size = Easing.quadratic_out(t, self._unselected_icon_size, self._selected_icon_size - self._unselected_icon_size, duration)

		self._grid_item_icon_sprite:set_w(current_size)
		self._grid_item_icon_sprite:set_h(current_size)
		self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())
	end
end

function RaidGUIControlGridItemSkill:_animate_shake()
	local duration = 0.4
	local t = 0
	local freq = 1820
	local amp = 8
	local x = self._params.x
	local y = self._params.y

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_y = math.sin(t * freq) * amp * (duration - t)
		local current_x = math.cos(t * freq) * amp * (duration - t)

		self._object:set_x(x + current_x)
		self._object:set_y(y + current_y)
	end

	self._object:set_x(x)
	self._object:set_y(y)
end

function RaidGUIControlGridItemSkill:_update_style()
	local state_data = self._state_data[self._state]

	self._grid_item_icon:set_color(state_data[self._highlighted and "highlight_on" or "highlight_off"])

	local outline_size = self._highlighted and RaidGUIControlGridItemSkill.OUTLINE_THICKNESS_SELECTED or RaidGUIControlGridItemSkill.OUTLINE_THICKNESS

	self._grid_item_icon_fg:set_shape(self._grid_item_icon:x() + outline_size, self._grid_item_icon:y() + outline_size, self._grid_item_icon:w() - outline_size * 2, self._grid_item_icon:h() - outline_size * 2)
	self._grid_item_icon_sprite:set_color(state_data[self._highlighted and "icon_on" or "icon_off"])

	local sprite_size = self._highlighted and self._selected_icon_size or self._unselected_icon_size

	self._grid_item_icon_sprite:set_w(sprite_size)
	self._grid_item_icon_sprite:set_h(sprite_size)
	self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())

	local locks_alpha = state_data[self._highlighted and "locks_alpha_highlight_on" or "locks_alpha_highlight_off"]

	self._item_status_panel:set_alpha(locks_alpha)
end

function RaidGUIControlGridItemSkill:_init_state_data()
	self._state_data = {
		[RaidGUIControlGridItemSkill.STATE_NORMAL] = {
			locks_alpha_highlight_off = 0,
			show_selector_triangles_alpha = 1,
			highlight_off = nil,
			highlight_on = nil,
			icon_on = nil,
			icon_off = nil,
			locks_alpha_highlight_on = 0,
			highlight_off = tweak_data.gui.colors.raid_dark_grey,
			highlight_on = tweak_data.gui.colors.raid_red,
			icon_off = tweak_data.gui.colors.raid_grey,
			icon_on = tweak_data.gui.colors.raid_dirty_white
		},
		[RaidGUIControlGridItemSkill.STATE_APPLIED] = {
			locks_alpha_highlight_off = 0,
			show_selector_triangles_alpha = 1,
			highlight_off = nil,
			highlight_on = nil,
			icon_on = nil,
			icon_off = nil,
			locks_alpha_highlight_on = 0,
			highlight_off = tweak_data.gui.colors.raid_dark_grey,
			highlight_on = tweak_data.gui.colors.raid_red,
			icon_off = tweak_data.gui.colors.raid_dirty_white,
			icon_on = tweak_data.gui.colors.raid_white
		},
		[RaidGUIControlGridItemSkill.STATE_PURCHASABLE] = {
			locks_alpha_highlight_off = 1,
			show_selector_triangles_alpha = 0,
			highlight_off = nil,
			highlight_on = nil,
			icon_on = nil,
			icon_off = nil,
			locks_alpha_highlight_on = 0.35,
			highlight_off = tweak_data.gui.colors.raid_dark_grey,
			highlight_on = tweak_data.gui.colors.raid_gold,
			icon_off = tweak_data.gui.colors.raid_dark_grey,
			icon_on = tweak_data.gui.colors.raid_gold
		},
		[RaidGUIControlGridItemSkill.STATE_LOCKED] = {
			locks_alpha_highlight_off = 0.85,
			show_selector_triangles_alpha = 0,
			highlight_off = nil,
			highlight_on = nil,
			icon_on = nil,
			icon_off = nil,
			locks_alpha_highlight_on = 0.1,
			highlight_off = tweak_data.gui.colors.raid_dark_grey,
			highlight_on = tweak_data.gui.colors.raid_brown_red,
			icon_off = tweak_data.gui.colors.raid_dark_grey,
			icon_on = tweak_data.gui.colors.raid_red
		}
	}
end

function RaidGUIControlGridItemSkill:can_activate()
	if self:_is_type_warcry() then
		return self:_is_unlocked() and not self:_is_applied()
	end

	if self:_is_applied() then
		return true
	end

	if self:_is_type_boost() then
		return self:_is_unlocked()
	end

	if self:_is_type_talent() then
		local unused_talent_slots_count = managers.skilltree.get_unused_talent_slots_count()
		local amount_talents_applied = managers.skilltree:get_amount_talents_applied()

		if self:_is_unlocked() and amount_talents_applied < unused_talent_slots_count then
			return true
		end
	end

	return false
end

function RaidGUIControlGridItemSkill:_is_type_warcry()
	return self._item_data.upgrades_type == SkillTreeTweakData.TYPE_WARCRY
end

function RaidGUIControlGridItemSkill:_is_type_boost()
	return self._item_data.upgrades_type == SkillTreeTweakData.TYPE_BOOSTS
end

function RaidGUIControlGridItemSkill:_is_type_talent()
	return self._item_data.upgrades_type == SkillTreeTweakData.TYPE_TALENT
end

function RaidGUIControlGridItemSkill:_is_unlocked()
	return self._state == RaidGUIControlGridItemSkill.STATE_NORMAL
end

function RaidGUIControlGridItemSkill:_is_applied()
	return self._state == RaidGUIControlGridItemSkill.STATE_APPLIED
end

function RaidGUIControlGridItemSkill:_is_level_locked()
	return self._state == RaidGUIControlGridItemSkill.STATE_LOCKED
end

function RaidGUIControlGridItemSkill:_is_purchasable()
	return self._state == RaidGUIControlGridItemSkill.STATE_PURCHASABLE
end

function RaidGUIControlGridItemSkill:refresh()
	self._item_data.status = managers.skilltree:get_skill_button_status(self._item_data.upgrades_type, self._item_data.key_name)

	self:_toggle_visibility_status_icons()
end

function RaidGUIControlGridItemSkill:_can_buy_and_afford()
	local can_afford = self._item_data.gold_requirements <= managers.gold_economy:current()

	return can_afford and self:_is_purchasable()
end
