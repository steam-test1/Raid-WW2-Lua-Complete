HUDSpecialInteraction = HUDSpecialInteraction or class()

function HUDSpecialInteraction:init(hud, params)
	self._workspace = managers.gui_data:create_fullscreen_workspace()

	self._workspace:set_timer(TimerManager:game())

	self._bg_panel = self._workspace:panel()
	self._hud_panel = hud.panel
	self._tweak_data = params
	self._sides = 64
	self._child_name_text = "interact_child_text"
	self._child_ivalid_name_text = "interact_child_invalid_text"
	self._is_active = false
	self._circles = {}

	if self._hud_panel:child(self._child_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	end

	if self._hud_panel:child(self._child_ivalid_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))
	end

	self._interact_text = self._hud_panel:text({
		layer = 1,
		h = 64,
		font_size = 24,
		align = "center",
		text = "HELLO",
		visible = false,
		valign = "center",
		name = self._child_name_text,
		color = Color.white,
		font = tweak_data.gui.fonts.din_compressed_outlined_24
	})
	self._invalid_text = self._hud_panel:text({
		layer = 3,
		h = 64,
		text = "HELLO",
		font_size = 24,
		align = "center",
		blend_mode = "normal",
		visible = false,
		valign = "center",
		name = self._child_ivalid_name_text,
		color = Color(1, 0.3, 0.3),
		font = tweak_data.gui.fonts.din_compressed_outlined_24
	})

	self._interact_text:set_y(self._hud_panel:h() / 2 + 64 + 16)
	self._invalid_text:set_center_y(self._interact_text:center_y())

	local res_x = tweak_data.gui.base_resolution.x
	local res_y = tweak_data.gui.base_resolution.y
	self._background_texture = self._bg_panel:bitmap({
		name = "_background_texture",
		layer = 1,
		visible = false,
		y = 0,
		x = 0,
		texture = tweak_data.gui.backgrounds.secondary_menu.texture,
		texture_rect = tweak_data.gui.backgrounds.secondary_menu.texture_rect,
		w = res_x * 1.2,
		h = res_y
	})
	self._lockpick_texture = self._hud_panel:bitmap({
		name = "_lockpick_texture",
		layer = 2,
		visible = false,
		x = self._hud_panel:w() / 2,
		y = self._hud_panel:h() / 2,
		texture = tweak_data.gui.icons.interact_lockpick_tool.texture,
		texture_rect = tweak_data.gui.icons.interact_lockpick_tool.texture_rect
	})
	self._legend_exit_text = self._hud_panel:text({
		vertical = "center",
		name = "_legend_exit_text",
		layer = 2,
		wrap = false,
		font_size = 24,
		align = "center",
		word_wrap = false,
		text = "EXIT[SPACE]",
		x = 0,
		valign = "bottom",
		y = -self._hud_panel:y(),
		font = tweak_data.gui.fonts.din_compressed_outlined_24,
		color = Color.white
	})

	self._legend_exit_text:set_center_x(self._hud_panel:center_x() + 302)
	self._legend_exit_text:set_center_y(self._hud_panel:center_y() - 13)

	self._legend_interact_text = self._hud_panel:text({
		vertical = "center",
		name = "_legend_interact_text",
		layer = 2,
		wrap = false,
		font_size = 24,
		align = "center",
		word_wrap = false,
		text = "INTERACT[F]",
		x = 0,
		valign = "bottom",
		y = -self._hud_panel:y(),
		font = tweak_data.gui.fonts.din_compressed_outlined_24,
		color = Color.white
	})

	self._legend_interact_text:set_center_x(self._hud_panel:center_x() - 302)
	self._legend_interact_text:set_center_y(self._hud_panel:center_y() - 13)
end

function HUDSpecialInteraction:show()
	self._lockpick_texture:stop()
	self._background_texture:set_visible(true)
	self._background_texture:set_alpha(0.5)
	self._legend_exit_text:set_visible(true)
	self._legend_exit_text:set_text(utf8.to_upper(managers.localization:text(self._tweak_data.legend_exit_text_id or "hud_legend_lockpicking_exit", {
		BTN_CANCEL = managers.localization:btn_macro("jump") or utf8.char(57344)
	})))
	self._legend_interact_text:set_visible(true)
	self._legend_interact_text:set_text(utf8.to_upper(managers.localization:text(self._tweak_data.legend_interact_text_id or "hud_legend_lockpicking_interact", {
		BTN_INTERACT = managers.localization:btn_macro("interact")
	})))
	self._lockpick_texture:set_visible(true)
	self._lockpick_texture:set_position(self._hud_panel:w() / 2 - self._lockpick_texture:w() / 2, self._hud_panel:h() / 2 - self._lockpick_texture:h() / 2)
	self:_remove_circles()

	for i = 1, self._tweak_data.number_of_circles do
		local circle_radius = self._tweak_data.circle_radius[i]
		local circle = CircleBitmapGuiObject:new(self._hud_panel, {
			use_bg = false,
			blend_mode = "add",
			layer = 2,
			image = tweak_data.gui.icons.interact_lockpick_circles[i].texture,
			radius = circle_radius,
			sides = self._sides,
			current = self._sides,
			total = self._sides,
			color = Color.white
		})

		circle:set_position(self._hud_panel:w() / 2 - circle_radius, self._hud_panel:h() / 2 - circle_radius)

		local start_rotation = math.random() * 360

		circle._circle:set_rotation(start_rotation)

		local circle_diff = self._tweak_data.circle_difficulty[i]

		circle:set_current(circle_diff)

		self._circles[i] = {
			completed = false,
			valid = true,
			circle = circle
		}
	end

	self._is_active = true
	self._active_stage = 1
end

function HUDSpecialInteraction:complete_stage(index)
	local circle_data = self._circles[index]

	if circle_data then
		circle_data.completed = true
		local color = Color(self._tweak_data.circle_difficulty[index], 0.3, 0.3, 0.3)

		circle_data.circle:set_color(color)
		circle_data.circle._circle:set_rotation((1 - self._tweak_data.circle_difficulty[index]) * 180)
		self._hud_panel:animate(callback(self, self, "_animate_stage_complete"))

		self._active_stage = index + 1
	end
end

function HUDSpecialInteraction:hide(complete)
	if complete then
		self._lockpick_texture:animate(callback(self, self, "_animate_interaction_complete"))
	else
		self:_remove_circles()
	end

	self._background_texture:set_visible(false)
	self._legend_exit_text:set_visible(false)
	self._legend_interact_text:set_visible(false)
	self._lockpick_texture:set_visible(false)

	self._is_active = false
end

function HUDSpecialInteraction:set_bar_valid(circle_id, valid)
	if circle_id < 1 then
		return
	elseif self._tweak_data.number_of_circles < circle_id then
		return
	end

	local circle_data = self._circles[circle_id]
	circle_data.valid = valid
	local color = Color(self._tweak_data.circle_difficulty[circle_id], 1, 1, 1)

	if not valid then
		color = Color(self._tweak_data.circle_difficulty[circle_id], 0.7215686, 0.22353, 0.180392)
	end

	circle_data.circle:set_color(color)
end

function HUDSpecialInteraction:rotate_circles(dt)
	for i, circle_data in pairs(self._circles) do
		if not circle_data.completed and i == self._active_stage then
			local circle = circle_data.circle._circle
			local current_rot = circle:rotation()
			local rotation_speed = self._tweak_data.circle_rotation_speed[i]

			if not circle_data.valid then
				rotation_speed = rotation_speed * 10
			end

			local delta = rotation_speed * dt * self._tweak_data.circle_rotation_direction[i]
			local new_rot = (current_rot + delta) % 360

			circle:set_rotation(new_rot)
		end
	end
end

function HUDSpecialInteraction:_remove_circles()
	if self ~= nil then
		for _, circle_data in pairs(self._circles) do
			circle_data.circle:remove()
		end

		self._circles = {}
	end
end

function HUDSpecialInteraction:destroy()
	self._hud_panel:clear()
	self:_remove_circles()
end

function HUDSpecialInteraction:set_circle_value(index, value)
	local circle_data = self._circles[index]

	if circle_data then
		circle_data.circle:set_current(value)
	end
end

function HUDSpecialInteraction:is_visible()
	return self._is_active
end

function HUDSpecialInteraction:circles()
	return self._circles
end

function HUDSpecialInteraction:set_tweak_data(data)
	self._tweak_data = data
end

function HUDSpecialInteraction:_animate_interaction_complete()
	local TOTAL_T = 0.5
	local starting_rotations = {}

	for i = 1, #self._circles do
		starting_rotations[i] = (1 - self._tweak_data.circle_difficulty[i]) * 180
	end

	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local progress = t / TOTAL_T

		for i = 1, #self._circles do
			local color = Color(math.max(0, self._tweak_data.circle_difficulty[i] - (1 - progress)), progress, progress, progress)

			self._circles[i].circle:set_color(color)
			self._circles[i].circle._circle:set_rotation(starting_rotations[i] + (1 - progress) * 180)
		end
	end

	for i = 1, #self._circles do
		self._circles[i].circle:set_visible(false)
	end

	self._remove_circles()
end

function HUDSpecialInteraction:_animate_stage_complete()
	local TOTAL_T = 0.7
	local DELTA_Y = 24
	local start_y = self._lockpick_texture:y()
	local end_y = start_y - DELTA_Y
	local t = 0.3

	while TOTAL_T >= t do
		local dt = coroutine.yield()
		t = t + dt
		local cur_delta_y = HUDSpecialInteraction:_ease_in_quint(t, 0, DELTA_Y, TOTAL_T)

		self._lockpick_texture:set_y(start_y - cur_delta_y)
	end

	self._lockpick_texture:set_y(end_y)
end

function HUDSpecialInteraction:_ease_in_quint(time, begin, change, duration)
	local alpha = time / duration

	return begin + change * alpha * alpha * alpha * alpha * alpha
end
