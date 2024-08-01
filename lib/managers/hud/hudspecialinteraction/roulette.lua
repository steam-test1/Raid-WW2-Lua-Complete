HUDSpecialInteractionRoulette = HUDSpecialInteractionRoulette or class(HUDSpecialInteraction)
HUDSpecialInteractionRoulette.SIZE = 220
HUDSpecialInteractionRoulette.BACKGROUND_PLATE_IMAGE = "interact_generic_bg"
HUDSpecialInteractionRoulette.WHEEL_GUI_ID = "special_int_cc_roulette_wheel"
HUDSpecialInteractionRoulette.POINTER_GUI_ID = "special_int_cc_roulette_pointer"
HUDSpecialInteractionRoulette.TIMER_GUI_ID = "special_int_cc_roulette_timer"
HUDSpecialInteractionRoulette.BULLET_GUI_ID = "special_int_cc_roulette_bullet"
HUDSpecialInteractionRoulette.CIRCLE_COLOR = Color.white
HUDSpecialInteractionRoulette.CIRCLE_COMPLETE_COLOR = tweak_data.gui.colors.raid_grey
HUDSpecialInteractionRoulette.CIRCLE_COMPLETE_FLASH_COLOR = tweak_data.gui.colors.raid_light_gold
HUDSpecialInteractionRoulette.CIRCLE_INVALID_COLOR = tweak_data.gui.colors.raid_red

function HUDSpecialInteractionRoulette:init(hud, params)
	HUDSpecialInteractionRoulette.super.init(self, hud, params)

	self._circle_speed_modifier = 1
	self._sides = 12
	self._circle = {}

	self:_create_bg_plate()
	self:_create_pointer()
	self:_create_timer()
	self:_create_wheel()
end

function HUDSpecialInteractionRoulette:_create_bg_plate()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionRoulette.BACKGROUND_PLATE_IMAGE)
	self._bg_plate = self._object:bitmap({
		name = "special_interaction_bg_plate",
		valign = "center",
		halign = "center",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		color = gui_data.color
	})

	self._bg_plate:set_center(self._object:center())
end

function HUDSpecialInteractionRoulette:_create_pointer()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionRoulette.POINTER_GUI_ID)
	self._pointer_texture = self._object:bitmap({
		name = "special_interaction_pointer_texture",
		valign = "center",
		halign = "center",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		color = gui_data.color,
		layer = self._bg_plate:layer() + 1
	})

	self._pointer_texture:set_center_x(self._object:center_x())
	self._pointer_texture:set_center_y(self._object:center_y() - HUDSpecialInteractionRoulette.SIZE)
end

function HUDSpecialInteractionRoulette:_create_timer()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionRoulette.TIMER_GUI_ID)
	self._timer = CircleBitmapGuiObject:new(self._object, {
		radius = 128,
		use_bg = false,
		image = gui_data.texture,
		color = gui_data.color,
		sides = self._sides,
		total = self._sides,
		layer = self._bg_plate:layer() + 1
	})

	self._timer:set_center(self._object:center())
end

function HUDSpecialInteractionRoulette:_create_wheel()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionRoulette.WHEEL_GUI_ID)
	local circle = self._object:bitmap({
		name = "special_interaction_circle_texture",
		valign = "center",
		halign = "center",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		color = gui_data.color,
		rotation = math.random(360),
		layer = self._bg_plate:layer() + 2
	})

	circle:set_center(self._object:center())

	self._circle = {
		completed = false,
		valid = true,
		circle = circle
	}
end

function HUDSpecialInteractionRoulette:show()
	local bg_size = HUDSpecialInteractionRoulette.SIZE + 84

	self._bg_plate:set_size(bg_size, bg_size)
	self._bg_plate:set_center(self._object:center())
	self._object:stop()
	HUDSpecialInteractionRoulette.super.show(self)
end

function HUDSpecialInteractionRoulette:hide(complete)
	if complete then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_interaction_complete"))

		self._is_active = false

		return
	end

	HUDSpecialInteractionRoulette.super.hide(self, complete)
end

function HUDSpecialInteractionRoulette:check_interact()
	if self._circle.completed then
		return
	end

	local circle_difficulty = self:get_difficulty()
	local diff_degrees = 360 * (1 - circle_difficulty) - 3
	local circle = self._circle.circle
	local current_rot = circle:rotation()
	local completed_stage = current_rot < diff_degrees

	if completed_stage then
		self:complete_stage()
	else
		self:set_bar_valid(false)

		self._cooldown = IngameSpecialInteraction.FAILED_COOLDOWN

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.failed)
		end
	end

	return completed_stage
end

function HUDSpecialInteractionRoulette:complete_stage()
	if self._circle then
		self._circle.completed = true

		self._object:animate(callback(self, self, "_animate_stage_complete", self._circle.circle))

		self._circle_speed_modifier = 1

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.circles[1].lock)

			if self._tweak_data.sounds.circles[1] then
				self:_play_sound(self._tweak_data.sounds.circles[1].mechanics, true)
			end
		end
	end
end

function HUDSpecialInteractionRoulette:set_bar_valid(valid)
	if self._circle then
		self._circle.valid = valid
		local color = valid and self.CIRCLE_COLOR or self.CIRCLE_INVALID_COLOR

		self._circle.circle:set_color(color)
	end
end

function HUDSpecialInteractionRoulette:destroy()
	self:_remove_wheel()
	HUDSpecialInteractionRoulette.super.destroy(self)
end

function HUDSpecialInteractionRoulette:update(t, dt)
	if self:cooldown() then
		self._cooldown = self._cooldown - dt

		if self._cooldown <= 0 then
			self._cooldown = 0

			self:set_bar_valid(true)

			local sound = self:get_update_sound(t, dt)

			if sound then
				self:_play_sound(sound)
			end
		end
	end

	if self._circle and not self._circle.completed then
		local current_rot = self._circle.circle:rotation()
		local rotation_speed = -self._tweak_data.circle_rotation_speed or -100

		if not self._circle.valid then
			rotation_speed = 0
		end

		local delta = rotation_speed * dt
		local new_rot = (current_rot + delta) % 360

		self._circle.circle:set_rotation(new_rot)
	end
end

function HUDSpecialInteractionRoulette:_remove_wheel()
	if self ~= nil then
		self._circle = {}
	end
end

function HUDSpecialInteractionRoulette:get_type()
	return "roulette"
end

function HUDSpecialInteractionRoulette:get_difficulty()
	return 0.16666666666666666
end

function HUDSpecialInteractionRoulette:get_update_sound(t, dt)
	if self._tweak_data.sounds and self._tweak_data.sounds.circles then
		local a = self._tweak_data.sounds.circles[1]

		return a.mechanics
	end
end

function HUDSpecialInteractionRoulette:check_all_complete()
	local completed = false

	if self._circle and self._circle.completed then
		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.success)
		end

		completed = true
	end

	return completed
end

function HUDSpecialInteractionRoulette:_animate_show()
	local duration = 0.24
	local t = 0
	local circle_delta_rot = 90
	local starting_rotation = self._circle.circle:rotation()

	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	self._circle.circle:set_alpha(0)
	self._pointer_texture:set_alpha(0)

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
		self._circle.circle:set_alpha(progress)
		self._circle.circle:set_rotation(starting_rotation - (1 - progress) * 360)

		local cur_pointer_delta = progress * HUDSpecialInteractionRoulette.SIZE

		self._pointer_texture:set_center_y(self._hud_panel:center_y() - cur_pointer_delta)
		self._pointer_texture:set_alpha(progress)
	end

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)
	managers.environment_controller:set_vignette(1)
	self._circle.circle:set_alpha(1)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x() + self.LEGEND_X_OFFSET)
	self._legend_interact_text:set_center_x(self._hud_panel:center_x() - self.LEGEND_X_OFFSET)
	self._pointer_texture:set_center_y(self._hud_panel:center_y() - HUDSpecialInteractionRoulette.SIZE)
end

function HUDSpecialInteractionRoulette:_animate_hide()
	local duration = 0.24
	local t = 0
	local circle_delta_rot = 90
	local starting_rotation = self._circle.circle:rotation()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		if self._circle then
			local circle_diff = self:get_difficulty()
			local cur_circle_delta = circle_delta_rot * (1 - progress)

			self._circle.circle:set_rotation(starting_rotation + cur_circle_delta)
		end

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)

		local cur_pointer_delta = progress * HUDSpecialInteractionRoulette.SIZE

		self._pointer_texture:set_center_y(self._hud_panel:center_y() - cur_pointer_delta)
		self._pointer_texture:set_alpha(progress)
	end

	self._remove_wheel()
	self._object:set_visible(false)
	self._bg_panel:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	managers.environment_controller:set_vignette(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())
	self._pointer_texture:set_center_y(self._hud_panel:center_y())
	self._pointer_texture:set_alpha(0)

	self._is_active = false
end

function HUDSpecialInteractionRoulette:_animate_interaction_complete()
	local duration = 0.33
	local t = 0
	local starting_progress = self:get_difficulty()
	local pick_delta_y = 60

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress * 0.3)
		self._bg_plate:set_alpha(progress * 0.3)
		managers.environment_controller:set_vignette(progress)

		local cur_progress = math.lerp(0, starting_progress, progress)

		self._circle.circle:set_rotation((1 - cur_progress) * 180)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._remove_wheel()
	self._object:set_visible(false)
	self._bg_panel:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())
	managers.environment_controller:set_vignette(0)

	self._is_active = false
end

function HUDSpecialInteractionRoulette:_animate_stage_complete(completed_circle)
	local duration = 0.4
	local t = 0
	local circle_start_rot = completed_circle:rotation()
	local circle_end_rot = (1 - self:get_difficulty()) * 180
	local circle_end_alpha = 0.25

	while t <= duration do
		local dt = coroutine.yield()
		t = t + dt
		local cur_circle_rot = Easing.quadratic_out(t, circle_start_rot, circle_end_rot - circle_start_rot, duration)

		completed_circle:set_rotation(cur_circle_rot)

		local progress = Easing.quintic_in(t, 0, 1, duration)
		local cur_circle_col = math.lerp(self.CIRCLE_COMPLETE_FLASH_COLOR, self.CIRCLE_COMPLETE_COLOR, progress)

		completed_circle:set_color(cur_circle_col)

		local cur_alpha = Easing.quintic_in(t, 1, -1 + circle_end_alpha, duration)

		completed_circle:set_alpha(cur_alpha)
	end

	completed_circle:set_rotation(circle_end_rot)
	completed_circle:set_color(self.CIRCLE_COMPLETE_COLOR)
	completed_circle:set_alpha(circle_end_alpha)
end

function HUDSpecialInteractionRoulette:_animate_stage_failed()
	local duration = IngameSpecialInteraction.FAILED_COOLDOWN / 2
	local t = 0

	while duration >= t do
		local dt = coroutine.yield()
		t = t + dt
	end
end
