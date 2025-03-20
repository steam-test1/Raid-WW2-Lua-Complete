RaidGUIControlButtonSkillTiny = RaidGUIControlButtonSkillTiny or class(RaidGUIControlButton)
RaidGUIControlButtonSkillTiny.OUTLINE_THICKNESS = 2
RaidGUIControlButtonSkillTiny.SPRITE_SCALE = 0.85

function RaidGUIControlButtonSkillTiny:init(parent, params)
	params.text = params.text or ""

	RaidGUIControlButtonSkillTiny.super.init(self, parent, params)

	params.selected_marker_w = params.selected_marker_w or 8
	params.selected_marker_h = params.selected_marker_h or 8
	params.color = params.color or Color.white
	params.color_edge = params.color_edge or params.color * 0.5
	params.color_icon = params.color_icon or Color.black
	self.locked = params.locked

	if self.locked then
		self:_layout_locks(params)
	end

	self:_layout_grid_item_icon(params)
end

function RaidGUIControlButtonSkillTiny:_layout_grid_item_icon(params)
	local image_coord_x = (params.selected_marker_w - params.w) / 2
	local image_coord_y = (params.selected_marker_h - params.h) / 2
	local gui_icon = tweak_data.gui:get_full_gui_data(params.icon or "locked")
	local color = params.color
	local layer = params.layer or 5
	self._grid_item_icon = self._object:rect({
		name = "grid_item_icon",
		w = params.w,
		h = params.h,
		color = params.color,
		layer = layer
	})
	local grid_item_fg = tweak_data.gui:get_full_gui_data("grid_item_fg")
	self._grid_item_icon_fg = self._object:bitmap({
		name = "grid_item_icon_fg",
		x = RaidGUIControlButtonSkillTiny.OUTLINE_THICKNESS,
		y = RaidGUIControlButtonSkillTiny.OUTLINE_THICKNESS,
		w = params.w - RaidGUIControlButtonSkillTiny.OUTLINE_THICKNESS * 2,
		h = params.h - RaidGUIControlButtonSkillTiny.OUTLINE_THICKNESS * 2,
		texture = grid_item_fg.texture,
		texture_rect = grid_item_fg.texture_rect,
		color = tweak_data.gui.colors.grid_item_grey,
		layer = self._grid_item_icon:layer() + 1
	})

	if not self.locked then
		self._grid_item_icon_sprite = self._object:bitmap({
			name = "grid_item_icon_sprite",
			texture = gui_icon.texture,
			texture_rect = gui_icon.texture_rect,
			w = params.w * RaidGUIControlButtonSkillTiny.SPRITE_SCALE,
			h = params.h * RaidGUIControlButtonSkillTiny.SPRITE_SCALE,
			layer = self._grid_item_icon_fg:layer() + 1,
			color = params.color
		})

		self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())
	end

	self._selected_icon_size = params.w
	self._unselected_icon_size = params.w * RaidGUIControlButtonSkillTiny.SPRITE_SCALE
end

function RaidGUIControlButtonSkillTiny:update_skill_data(skill_data, skill_id)
	if not self.locked and self.skill_id ~= skill_id then
		self.skill_id = skill_id
		self.skill_data = skill_data

		if not self._grid_item_icon_update then
			local col = tweak_data.gui.colors.raid_dirty_white
			self._grid_item_icon_update = self._object:gradient({
				name = "grid_item_icon_update",
				orientation = "vertical",
				y = self._object:h(),
				w = self._object:w(),
				h = self._object:h(),
				layer = self._grid_item_icon_fg:layer() + 10
			})

			self._grid_item_icon_update:set_gradient_points({
				0,
				col:with_alpha(0),
				0.1,
				col:with_alpha(1),
				0.9,
				col:with_alpha(1),
				1,
				col:with_alpha(0)
			})
		end

		self._object:stop()
		self._object:animate(callback(self, self, "_animate_update"))
	end
end

function RaidGUIControlButtonSkillTiny:_layout_locks(params)
	local layer = params.layer + 10 or 10
	local cx = self._object:w() / 2
	self._item_status_lock_panel = self._object:panel({
		name = "grid_item_lock_panel",
		layer = layer
	})
	local grid_item_locked = tweak_data.gui:get_full_gui_data("grid_item_locked")
	local status_lock_bg = self._item_status_lock_panel:image({
		name = "grid_item_lock_bg",
		w = self._item_status_lock_panel:w(),
		h = self._item_status_lock_panel:h(),
		texture = grid_item_locked.texture,
		texture_rect = grid_item_locked.texture_rect,
		color = grid_item_locked.color
	})
	local ico_locker = tweak_data.gui:get_full_gui_data("ico_locker")
	self._item_status_lock_icon = self._item_status_lock_panel:image({
		name = "grid_item_lock_icon",
		w = params.w / 2,
		h = params.h / 2,
		texture = ico_locker.texture,
		texture_rect = ico_locker.texture_rect,
		color = ico_locker.color,
		layer = status_lock_bg:layer() + 1
	})

	self._item_status_lock_icon:set_center_x(cx)
	self._item_status_lock_icon:set_center_y(self._object:h() / 2 - 10)

	local text = tostring(params.level_lock or 99)
	self._item_status_lock_text = self._item_status_lock_panel:text({
		name = "grid_item_lock_text",
		align = "center",
		h = 16,
		w = params.w,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_16,
		text = text,
		layer = status_lock_bg:layer() + 1
	})

	self._item_status_lock_text:set_center_x(cx)
	self._item_status_lock_text:set_top(self._item_status_lock_icon:bottom())
end

function RaidGUIControlButtonSkillTiny:highlight_on()
	if not self.skill_data then
		return
	end

	self._grid_item_icon_sprite:stop()
	self._grid_item_icon_sprite:animate(callback(self, self, "_animate_highlight", true))
	RaidGUIControlButtonSkillTiny.super.highlight_on(self)
end

function RaidGUIControlButtonSkillTiny:highlight_off()
	if not self.skill_data then
		return
	end

	self._grid_item_icon_sprite:stop()
	self._grid_item_icon_sprite:animate(callback(self, self, "_animate_highlight", false))
	RaidGUIControlButtonSkillTiny.super.highlight_off(self)
end

function RaidGUIControlButtonSkillTiny:on_mouse_pressed(button)
	if self.skill_data then
		RaidGUIControlButtonSkillTiny.super.on_mouse_pressed(self, button)
	end
end

function RaidGUIControlButtonSkillTiny:on_mouse_released(button)
	if not self.skill_data then
		return
	end

	if self.skill_data.upgrades_type == SkillTreeTweakData.TYPE_WARCRY then
		managers.menu_component:post_event("generic_fail_sound")

		return
	end

	managers.menu_component:post_event("skill_remove")
	RaidGUIControlButtonSkillTiny.super.on_mouse_released(self, button)
end

function RaidGUIControlButtonSkillTiny:_animate_press()
end

function RaidGUIControlButtonSkillTiny:_animate_release()
end

function RaidGUIControlButtonSkillTiny:_animate_highlight(highlighted)
	local t = 0
	local duration = 0.15
	local progress_start = highlighted and 0 or 1
	local progress_end = highlighted and 1 or -1

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in_out(t, progress_start, progress_end, duration)
		local current_size = math.lerp(self._unselected_icon_size, self._selected_icon_size, progress)

		self._grid_item_icon_sprite:set_size(current_size, current_size)
		self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())
	end
end

function RaidGUIControlButtonSkillTiny:_animate_update()
	print("RaidGUIControlButtonSkillTiny:_animate_update()")

	local t = 0
	local duration = 0.15
	local y = self._object:h()
	local icon = tweak_data.skilltree:get_skill_icon_tiered(self.skill_id)
	local gui_data = tweak_data.gui:get_full_gui_data(icon)
	local sprite_color = self.skill_data and tweak_data.gui.colors.raid_white or self._params.color
	local sprite_blend = self.skill_data and "sub" or "normal"
	local fg_color = self.skill_data and self._params.color or tweak_data.gui.colors.grid_item_grey
	local edge_color = self.skill_data and self._params.color_edge or self._params.color

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._grid_item_icon_sprite:set_alpha(current_alpha)

		local current_y = Easing.quadratic_in(t, y, -y, duration)

		self._grid_item_icon_update:set_y(current_y)
	end

	self._grid_item_icon_update:set_y(y)
	self._grid_item_icon_sprite:set_image(gui_data.texture, unpack(gui_data.texture_rect))
	self._grid_item_icon_sprite:set_color(sprite_color)
	self._grid_item_icon_sprite:set_blend_mode(sprite_blend)

	if not self.skill_data then
		self._grid_item_icon_sprite:set_size(self._unselected_icon_size, self._unselected_icon_size)
		self._grid_item_icon_sprite:set_center(self._grid_item_icon:center())
	end

	self._grid_item_icon_fg:set_color(fg_color)
	self._grid_item_icon:set_color(edge_color)

	t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_y = Easing.quadratic_out(t, 0, -y, duration)

		self._grid_item_icon_update:set_y(current_y)

		local current_alpha = Easing.quadratic_out(t, 0, 1, duration)

		self._grid_item_icon_sprite:set_alpha(current_alpha)
	end

	self._object:remove(self._grid_item_icon_update)

	self._grid_item_icon_update = nil
end
