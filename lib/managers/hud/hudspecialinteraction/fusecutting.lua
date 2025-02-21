HUDSpecialInteractionFuseCutting = HUDSpecialInteractionFuseCutting or class(HUDSpecialInteraction)
HUDSpecialInteractionFuseCutting.SIZE = 300
HUDSpecialInteractionFuseCutting.TOTAL_ANGLE = 280
HUDSpecialInteractionFuseCutting.STARTING_ANGLE = -HUDSpecialInteractionFuseCutting.TOTAL_ANGLE / 2
HUDSpecialInteractionFuseCutting.ENDING_ANGLE = HUDSpecialInteractionFuseCutting.TOTAL_ANGLE / 2
HUDSpecialInteractionFuseCutting.TOTAL_RATIO = HUDSpecialInteractionFuseCutting.TOTAL_ANGLE / 360
HUDSpecialInteractionFuseCutting.CIRCLE_COLOR = Color.white
HUDSpecialInteractionFuseCutting.BACKGROUND_PLATE_IMAGE = "interact_generic_bg"
HUDSpecialInteractionFuseCutting.KNIFE_ICON = "interact_knife_tool"
HUDSpecialInteractionFuseCutting.CUT_COOLDOWN = 0.33
HUDSpecialInteractionFuseCutting.TIMER_FONT = tweak_data.gui.fonts.din_compressed_outlined_42
HUDSpecialInteractionFuseCutting.TIMER_FONT_SIZE = tweak_data.gui.font_sizes.size_52
HUDSpecialInteractionFuseCutting.STATE_DEFAULT_COLOR = tweak_data.gui.colors.raid_dark_grey
HUDSpecialInteractionFuseCutting.STATE_SUCCESS_COLOR = tweak_data.gui.colors.raid_light_gold
HUDSpecialInteractionFuseCutting.STATE_FAILURE_COLOR = tweak_data.gui.colors.raid_red

function HUDSpecialInteractionFuseCutting:init(hud, params)
	HUDSpecialInteractionFuseCutting.super.init(self, hud, params)

	self._current_speed = self._tweak_data.circle_rotation_speed or 160
	self._successful_cuts = 1
	self._max_cuts = self._tweak_data.max_cuts or 9
	self._circles = {}

	self:_create_bg_plate()
	self:_create_interact_arrow()
	self:_create_fuse_timer()
end

function HUDSpecialInteractionFuseCutting:_create_bg_plate()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionFuseCutting.BACKGROUND_PLATE_IMAGE)
	self._bg_plate = self._object:bitmap({
		layer = 1,
		halign = "center",
		valign = "center",
		name = "special_interaction_bg_plate",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		w = HUDSpecialInteractionFuseCutting.SIZE + 118,
		h = HUDSpecialInteractionFuseCutting.SIZE + 118
	})

	self._bg_plate:set_center(self._object:center())
end

function HUDSpecialInteractionFuseCutting:_create_interact_arrow()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionFuseCutting.KNIFE_ICON)
	self._interact_arrow = self._object:bitmap({
		name = "special_interaction_icon",
		w = HUDSpecialInteractionFuseCutting.SIZE * 0.9,
		h = HUDSpecialInteractionFuseCutting.SIZE * 0.9,
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		layer = self._bg_plate:layer() + 2
	})

	self._interact_arrow:set_center(self._object:center())
end

function HUDSpecialInteractionFuseCutting:_create_fuse_timer()
	self._interact_text = self._object:text({
		w = 240,
		name = "_interact_text",
		align = "center",
		text = "--:--",
		valign = "center",
		h = 60,
		layer = self._bg_plate:layer() + 2,
		font = HUDSpecialInteractionFuseCutting.TIMER_FONT,
		font_size = HUDSpecialInteractionFuseCutting.TIMER_FONT_SIZE
	})

	self._interact_text:set_center_x(self._object:w() / 2)
	self._interact_text:set_bottom(self._bg_plate:bottom() - 20)
end

function HUDSpecialInteractionFuseCutting:_create_circles()
	self:_remove_circles()

	local max_cuts = self._max_cuts - 1
	local current_gap = self._tweak_data.circle_difficulty or 0.2
	local deviation_min = 0.45
	local deviation_max = 1

	if self._tweak_data.circle_difficulty_deviation then
		deviation_min = self._tweak_data.circle_difficulty_deviation[1]
		deviation_max = self._tweak_data.circle_difficulty_deviation[2]
	end

	local fill_mul = HUDSpecialInteractionFuseCutting.TOTAL_RATIO

	for i = 1, max_cuts do
		local circle = CircleBitmapGuiObject:new(self._object, {
			position_z = 0,
			blend_mode = "add",
			image = tweak_data.gui.icons.interact_fuse_thread.texture,
			color = HUDSpecialInteractionFuseCutting.STATE_DEFAULT_COLOR,
			rotation = HUDSpecialInteractionFuseCutting.ENDING_ANGLE,
			radius = HUDSpecialInteractionFuseCutting.SIZE,
			layer = self._bg_plate:layer() + 1
		})

		circle:set_center(self._object:center())

		local deviation = math.random() * (deviation_max - deviation_min) + deviation_min
		local fill = current_gap * deviation

		table.insert(self._circles, {
			cut_point = true,
			size = 0,
			circle = circle,
			max_size = fill * fill_mul,
			rotation = HUDSpecialInteractionFuseCutting.TOTAL_ANGLE
		})

		current_gap = current_gap * self._tweak_data.circle_difficulty_mul
	end

	local max_segments = max_cuts * 2 + 1
	local segment_size = 0.43

	for i = 1, max_segments, 2 do
		local circle = CircleBitmapGuiObject:new(self._object, {
			position_z = 0,
			image = tweak_data.gui.icons.interact_lockpick_circles[1].texture,
			color = HUDSpecialInteractionFuseCutting.CIRCLE_COLOR,
			rotation = HUDSpecialInteractionFuseCutting.ENDING_ANGLE,
			radius = HUDSpecialInteractionFuseCutting.SIZE,
			layer = self._bg_plate:layer() + 1
		})

		circle:set_center(self._object:center())

		local fill = 0.092 + math.random() * segment_size

		table.insert(self._circles, i, {
			size = 0,
			circle = circle,
			max_size = fill * fill_mul,
			rotation = HUDSpecialInteractionFuseCutting.TOTAL_ANGLE
		})

		segment_size = segment_size * self._tweak_data.circle_difficulty_mul
	end

	self._circles[#self._circles].max_size = self._circles[#self._circles].max_size * 4
end

function HUDSpecialInteractionFuseCutting:_remove_circles()
	if self ~= nil then
		for _, circle_data in pairs(self._circles) do
			circle_data.circle:remove()
		end

		self._circles = {}
	end
end

function HUDSpecialInteractionFuseCutting:show()
	local time_string = self._get_time_text(self._tweak_data.cut_timers[1])

	self._interact_text:set_text(time_string)
	self._interact_text:set_visible(true)
	self:_create_circles()
	HUDSpecialInteractionFuseCutting.super.show(self)
end

function HUDSpecialInteractionFuseCutting:hide(complete)
	if complete and self._tweak_data.sounds and self:_is_all_cut() then
		self:_play_sound(self._tweak_data.sounds.success)
	end

	HUDSpecialInteractionFuseCutting.super.hide(self, complete)
end

function HUDSpecialInteractionFuseCutting:destroy()
	self:_remove_circles()
	HUDSpecialInteractionFuseCutting.super.destroy(self)
end

function HUDSpecialInteractionFuseCutting:_inside_target()
	for i, circle_data in ipairs(self._circles) do
		if not circle_data.already_cut then
			local rotation = circle_data.rotation
			local size = circle_data.size * 360
			local circle_start = rotation - HUDSpecialInteractionFuseCutting.ENDING_ANGLE
			local circle_end = circle_start + size

			if circle_start < 0 and circle_end > 0 then
				circle_data.already_cut = true

				return circle_data.cut_point, circle_data.circle
			end
		end
	end

	return false
end

function HUDSpecialInteractionFuseCutting:on_leave()
	self._failed_cut = true
	self._cooldown = IngameSpecialInteraction.FAILED_COOLDOWN

	if self._tweak_data.sounds then
		self:_play_sound(self._tweak_data.sounds.failed)
	end

	return false
end

function HUDSpecialInteractionFuseCutting:check_interact()
	local completed_stage, cut_cricle = self:_inside_target()

	if completed_stage then
		self:check_interact_success(cut_cricle)
	elseif cut_cricle then
		self:check_interact_failed(cut_cricle)
	end

	return completed_stage
end

function HUDSpecialInteractionFuseCutting:check_interact_success(cut_cricle)
	if self._tweak_data.sounds then
		self:_play_sound(self._tweak_data.sounds.apply)
	end

	if not self:_is_completed() then
		self._cooldown = HUDSpecialInteractionFuseCutting.CUT_COOLDOWN
		self._successful_cuts = self._successful_cuts + 1

		self._object:stop()
		self._object:animate(callback(self, self, "_animate_interaction_success", cut_cricle))
	end
end

function HUDSpecialInteractionFuseCutting:check_interact_failed(cut_cricle)
	self._failed_cut = true
	self._cooldown = IngameSpecialInteraction.FAILED_COOLDOWN

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_interaction_failed", cut_cricle))

	if self._tweak_data.sounds then
		self:_play_sound(self._tweak_data.sounds.failed)
	end
end

function HUDSpecialInteractionFuseCutting:check_fuse_ended()
	self._failed_cut = true
end

function HUDSpecialInteractionFuseCutting:update(t, dt)
	if self:cooldown() then
		self._cooldown = self._cooldown - dt

		if self._cooldown <= 0 then
			self._cooldown = 0
			local sound = self:get_update_sound(t, dt)

			if sound then
				self:_play_sound(sound)
			end
		end

		return
	end

	self:_update_circles(self._current_speed * dt)

	if not self:_is_completed() then
		local last_circle = self._circles[#self._circles]

		if last_circle.rotation + 10 < HUDSpecialInteractionFuseCutting.ENDING_ANGLE then
			self:check_fuse_ended()
		end
	end
end

function HUDSpecialInteractionFuseCutting:_update_circles(spin_speed)
	local angle_start = HUDSpecialInteractionFuseCutting.STARTING_ANGLE
	local angle_end = HUDSpecialInteractionFuseCutting.ENDING_ANGLE

	for i, circle_data in ipairs(self._circles) do
		local rotation = circle_data.rotation
		circle_data.rotation = circle_data.rotation - spin_speed
		circle_data.size = math.abs(circle_data.rotation) / HUDSpecialInteractionFuseCutting.TOTAL_ANGLE
		circle_data.size = circle_data.size * HUDSpecialInteractionFuseCutting.TOTAL_RATIO

		if circle_data.rotation > 0 then
			circle_data.size = math.min(HUDSpecialInteractionFuseCutting.TOTAL_RATIO - circle_data.size, circle_data.max_size)
		else
			circle_data.size = circle_data.max_size - circle_data.size
		end

		local new_rot = math.clamp(circle_data.rotation - angle_end, angle_start, angle_end)

		circle_data.circle:set_rotation(new_rot)
		circle_data.circle:set_current(circle_data.size)

		if circle_data.rotation > 0 then
			if circle_data.size < circle_data.max_size then
				break
			end
		elseif circle_data.size <= 0 then
			circle_data.circle:remove()
			table.remove(self._circles, i)
		end
	end
end

function HUDSpecialInteractionFuseCutting:get_update_sound(t, dt)
	return self._tweak_data.sounds and self._tweak_data.sounds.tick
end

function HUDSpecialInteractionFuseCutting:get_type()
	return "cut_fuse"
end

function HUDSpecialInteractionFuseCutting:_is_all_cut()
	return self._successful_cuts == self._max_cuts
end

function HUDSpecialInteractionFuseCutting:_is_completed()
	return self._failed_cut or self:_is_all_cut()
end

function HUDSpecialInteractionFuseCutting:get_interaction_data()
	return {
		successful_cuts = self._successful_cuts
	}
end

function HUDSpecialInteractionFuseCutting:circles()
	return self._circles
end

function HUDSpecialInteractionFuseCutting:check_all_complete()
	return self:_is_completed()
end

function HUDSpecialInteractionFuseCutting._get_time_text(time)
	time = math.max(math.floor(time or 0), 0)
	local minutes = math.floor(time / 60)
	local seconds = math.mod(time, 60)

	return string.format("%02d:%02d", minutes, seconds)
end

function HUDSpecialInteractionFuseCutting:_animate_show()
	local duration = 0.42
	local t = 0

	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)

	local start_time = 0
	local end_time = self._tweak_data.cut_timers[1]

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)

		local cur_time = math.lerp(start_time, end_time, progress)

		self._interact_text:set_text(self._get_time_text(cur_time))

		local cur_knife_rot = 130 * (1 - progress)

		self._interact_arrow:set_rotation(-cur_knife_rot)
	end

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)
	managers.environment_controller:set_vignette(1)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x() + self.LEGEND_X_OFFSET)
	self._legend_interact_text:set_center_x(self._hud_panel:center_x() - self.LEGEND_X_OFFSET)
	self._interact_arrow:set_rotation(0)
end

function HUDSpecialInteractionFuseCutting:_animate_hide()
	local spin_speed = self._current_speed * #self._circles * 1.5

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)
	self._interact_arrow:set_center_y(self._hud_panel:center_y())

	while #self._circles > 0 do
		local dt = coroutine.yield()

		self:_update_circles(spin_speed * dt)
	end

	local duration = 0.24
	local t = 0

	while duration >= t do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)

		local cur_knife_rot = 130 * (1 - progress)

		self._interact_arrow:set_rotation(-cur_knife_rot)
	end

	self._object:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_visible(false)
	self._bg_panel:set_alpha(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())
	managers.environment_controller:set_vignette(0)
	self._interact_arrow:set_rotation(-130)

	self._is_active = false
end

function HUDSpecialInteractionFuseCutting:_animate_interaction_success(circle)
	local duration = self._cooldown
	local t = 0
	local freq = 800
	local amp = HUDSpecialInteractionFuseCutting.SIZE * 1.5
	local start_time = self._tweak_data.cut_timers[self._successful_cuts - 1]
	local end_time = self._tweak_data.cut_timers[self._successful_cuts]

	while t <= duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)
		local cur_circle_col = math.lerp(self.STATE_DEFAULT_COLOR, self.STATE_SUCCESS_COLOR, progress)

		circle:set_color(cur_circle_col)

		local cur_delta_y = math.abs(math.sin(t * freq) * amp * (duration - t))

		self._interact_arrow:set_center_y(self._object:center_y() - cur_delta_y)

		local cur_time = math.lerp(start_time, end_time, progress)

		self._interact_text:set_text(self._get_time_text(cur_time))
	end

	circle:set_color(HUDSpecialInteractionFuseCutting.STATE_SUCCESS_COLOR)
	self._interact_arrow:set_center_y(self._object:center_y())

	local time_string = self._get_time_text(end_time)

	self._interact_text:set_text(time_string)
end

function HUDSpecialInteractionFuseCutting:_animate_interaction_failed(circle)
	local duration = 0.28
	local t = 0
	local freq = 1440
	local circle_freq = 900
	local amp = HUDSpecialInteractionFuseCutting.SIZE * 0.6
	local circle_amp = 50
	local center_y = self._object:center_y()

	while t <= duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in(t, 0, 1, duration)
		local cur_circle_col = math.lerp(self.CIRCLE_COLOR, self.STATE_FAILURE_COLOR, progress)

		circle:set_color(cur_circle_col)

		local cur_delta_y = math.abs(math.sin(t * freq) * amp * (duration - t))

		self._interact_arrow:set_center_y(center_y - cur_delta_y)

		cur_delta_y = math.sin(t * circle_freq) * circle_amp * (duration - t)

		circle:set_center_y(center_y - cur_delta_y)
	end

	circle:set_color(HUDSpecialInteractionFuseCutting.STATE_FAILURE_COLOR)
	circle:set_center_y(center_y)
	self._interact_arrow:set_center_y(center_y)
end
