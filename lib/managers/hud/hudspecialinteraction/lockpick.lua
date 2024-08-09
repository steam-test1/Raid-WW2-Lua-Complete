HUDSpecialInteractionLockPick = HUDSpecialInteractionLockPick or class(HUDSpecialInteraction)
HUDSpecialInteractionLockPick.SIZE = 220
HUDSpecialInteractionLockPick.BACKGROUND_PLATE_IMAGE = "interact_generic_bg"
HUDSpecialInteractionLockPick.LOCKPICK_ICON = "interact_lockpick_tool"
HUDSpecialInteractionLockPick.CIRCLE_COLOR = Color.white
HUDSpecialInteractionLockPick.CIRCLE_COMPLETE_COLOR = tweak_data.gui.colors.raid_grey
HUDSpecialInteractionLockPick.CIRCLE_COMPLETE_FLASH_COLOR = tweak_data.gui.colors.raid_light_gold
HUDSpecialInteractionLockPick.CIRCLE_INVALID_COLOR = tweak_data.gui.colors.raid_red

-- Lines 13-23
function HUDSpecialInteractionLockPick:init(hud, params)
	HUDSpecialInteractionLockPick.super.init(self, hud, params)

	self._current_stage = 1
	self._circle_speed_modifier = 1
	self._sides = 64
	self._circles = {}

	self:_create_bg_plate()
	self:_create_lockpick_texture()
end

-- Lines 25-36
function HUDSpecialInteractionLockPick:_create_bg_plate()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionLockPick.BACKGROUND_PLATE_IMAGE)
	self._bg_plate = self._object:bitmap({
		name = "special_interaction_bg_plate",
		valign = "center",
		halign = "center",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect
	})

	self._bg_plate:set_center(self._object:center())
end

-- Lines 38-50
function HUDSpecialInteractionLockPick:_create_lockpick_texture()
	local gui_data = tweak_data.gui:get_full_gui_data(HUDSpecialInteractionLockPick.LOCKPICK_ICON)
	self._lockpick_texture = self._object:bitmap({
		name = "special_interaction_icon",
		w = HUDSpecialInteractionLockPick.SIZE,
		h = HUDSpecialInteractionLockPick.SIZE,
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect,
		layer = self._bg_plate:layer() + 1
	})

	self._lockpick_texture:set_center(self._object:center())
end

-- Lines 52-77
function HUDSpecialInteractionLockPick:_create_circles()
	self:_remove_circles()

	for i = 1, self._tweak_data.number_of_circles do
		local circle = CircleBitmapGuiObject:new(self._object, {
			use_bg = false,
			image = tweak_data.gui.icons.interact_lockpick_circles[i].texture,
			color = HUDSpecialInteractionLockPick.CIRCLE_COLOR,
			radius = HUDSpecialInteractionLockPick.SIZE,
			sides = self._sides,
			total = self._sides,
			layer = self._bg_plate:layer() + 2
		})

		circle:set_center(self._object:center())

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
end

-- Lines 79-90
function HUDSpecialInteractionLockPick:show()
	local bg_size = HUDSpecialInteractionLockPick.SIZE + 20 + 64 * self._tweak_data.number_of_circles + 1

	self._bg_plate:set_size(bg_size, bg_size)
	self._bg_plate:set_center(self._object:center())
	self._object:stop()
	self:_create_circles()
	HUDSpecialInteractionLockPick.super.show(self)
end

-- Lines 92-103
function HUDSpecialInteractionLockPick:hide(complete)
	if complete then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_interaction_complete"))

		self._is_active = false

		return
	end

	HUDSpecialInteractionLockPick.super.hide(self, complete)
end

-- Lines 106-154
function HUDSpecialInteractionLockPick:check_interact()
	local current_stage_data, current_stage = nil

	for stage, stage_data in pairs(self:circles()) do
		if not stage_data.completed then
			current_stage = stage
			current_stage_data = stage_data

			break
		end
	end

	if not current_stage then
		return
	end

	self._current_stage = current_stage
	local circle_difficulty = self._tweak_data.circle_difficulty[current_stage]
	local diff_degrees = 360 * (1 - circle_difficulty) - 3
	local circle = current_stage_data.circle._circle
	local current_rot = circle:rotation()
	local completed_stage = current_rot < diff_degrees

	if completed_stage then
		self:complete_stage(current_stage)
	else
		self:set_bar_valid(current_stage, false)
		self._lockpick_texture:stop()
		self._lockpick_texture:animate(callback(self, self, "_animate_stage_failed"))

		self._cooldown = IngameSpecialInteraction.FAILED_COOLDOWN

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.failed)
		end

		if managers.player:has_category_upgrade("interaction", "locksmith_failure_rotation_speed_decrease") then
			local limit = managers.player:upgrade_value("interaction", "locksmith_failure_rotation_speed_decrease")
			local decrease = tweak_data.upgrades.locksmith_failure_speed_decrease_step
			self._circle_speed_modifier = math.max(self._circle_speed_modifier - decrease, limit)
		end
	end

	return completed_stage
end

-- Lines 156-173
function HUDSpecialInteractionLockPick:complete_stage(index)
	local circle_data = self._circles[index]

	if circle_data then
		circle_data.completed = true

		self._object:animate(callback(self, self, "_animate_stage_complete", circle_data.circle._circle))

		self._current_stage = index + 1
		self._circle_speed_modifier = 1

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.circles[index].lock)

			if self._tweak_data.sounds.circles[index + 1] then
				self:_play_sound(self._tweak_data.sounds.circles[index + 1].mechanics, true)
			end
		end
	end
end

-- Lines 175-190
function HUDSpecialInteractionLockPick:set_bar_valid(circle_id, valid)
	if circle_id < 1 then
		return
	elseif self._tweak_data.number_of_circles < circle_id then
		return
	end

	local circle_data = self._circles[circle_id]
	circle_data.valid = valid
	local color = valid and self.CIRCLE_COLOR or self.CIRCLE_INVALID_COLOR

	circle_data.circle:set_color(color)

	local legent_color = valid and HUDSpecialInteraction.LEGEND_FONT_COLOR or HUDSpecialInteraction.LEGEND_FONT_DISABLED_COLOR

	self._legend_exit_text:set_color(legent_color)
end

-- Lines 192-196
function HUDSpecialInteractionLockPick:destroy()
	self:_remove_circles()
	HUDSpecialInteractionLockPick.super.destroy(self)
end

-- Lines 199-204
function HUDSpecialInteractionLockPick:set_circle_value(index, value)
	local circle_data = self._circles[index]

	if circle_data then
		circle_data.circle:set_current(value)
	end
end

-- Lines 206-240
function HUDSpecialInteractionLockPick:update(t, dt)
	if self:cooldown() then
		self._cooldown = self._cooldown - dt

		if self._cooldown <= 0 then
			self._cooldown = 0

			self:set_bar_valid(self._current_stage, true)

			local sound = self:get_update_sound(t, dt)

			if sound then
				self:_play_sound(sound)
			end
		end
	end

	for i, circle_data in pairs(self._circles) do
		if not circle_data.completed and i == self._current_stage then
			local circle = circle_data.circle._circle
			local current_rot = circle:rotation()
			local rotation_speed = self._tweak_data.circle_rotation_speed[i] * self._circle_speed_modifier * self._tweak_data.circle_rotation_direction[i]

			if not circle_data.valid then
				rotation_speed = rotation_speed * 7
			end

			local delta = rotation_speed * dt
			local new_rot = (current_rot + delta) % 360

			circle:set_rotation(new_rot)
		end
	end
end

-- Lines 242-249
function HUDSpecialInteractionLockPick:_remove_circles()
	if self ~= nil then
		for _, circle_data in pairs(self._circles) do
			circle_data.circle:remove()
		end

		self._circles = {}
	end
end

-- Lines 253-255
function HUDSpecialInteractionLockPick:get_type()
	return self._tweak_data.minigame_type or tweak_data.interaction.MINIGAME_PICK_LOCK
end

-- Lines 257-264
function HUDSpecialInteractionLockPick:get_update_sound(t, dt)
	if self._tweak_data.sounds and self._tweak_data.sounds.circles then
		local a = self._tweak_data.sounds.circles[math.min(self._current_stage, #self._tweak_data.sounds.circles)]

		return a.mechanics
	end
end

-- Lines 266-268
function HUDSpecialInteractionLockPick:circles()
	return self._circles
end

-- Lines 270-284
function HUDSpecialInteractionLockPick:check_all_complete()
	local completed = true

	for stage, stage_data in pairs(self:circles()) do
		completed = completed and stage_data.completed
	end

	if completed and self._tweak_data.sounds then
		self:_play_sound(self._tweak_data.sounds.success)
	end

	return completed
end

-- Lines 288-344
function HUDSpecialInteractionLockPick:_animate_show()
	local duration = 0.24
	local t = 0
	local circle_delta_rot = 90
	local starting_rotations = {}

	for i = 1, #self._circles do
		starting_rotations[i] = self._circles[i].circle._circle:rotation()
	end

	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		if #self._circles > 1 then
			for i = 2, #self._circles do
				local circle_diff = self._tweak_data.circle_difficulty[i]
				local cur_circle_delta = circle_delta_rot * (1 - progress)
				cur_circle_delta = cur_circle_delta * -self._tweak_data.circle_rotation_direction[i]

				self._circles[i].circle:set_current(1 - (1 - circle_diff) * progress)
				self._circles[i].circle._circle:set_rotation(starting_rotations[i] + cur_circle_delta)
			end
		end

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)
	managers.environment_controller:set_vignette(1)

	for i = 1, #self._circles do
		local circle_diff = self._tweak_data.circle_difficulty[i]

		self._circles[i].circle:set_current(circle_diff)
		self._circles[i].circle:set_alpha(1)
	end

	self._legend_exit_text:set_center_x(self._hud_panel:center_x() + self.LEGEND_X_OFFSET)
	self._legend_interact_text:set_center_x(self._hud_panel:center_x() - self.LEGEND_X_OFFSET)
end

-- Lines 346-396
function HUDSpecialInteractionLockPick:_animate_hide()
	local duration = 0.24
	local t = 0
	local circle_delta_rot = 90
	local starting_rotations = {}

	for i = 1, #self._circles do
		starting_rotations[i] = self._circles[i].circle._circle:rotation()
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		for i = 1, #self._circles do
			local circle_diff = self._tweak_data.circle_difficulty[i]
			local cur_circle_delta = circle_delta_rot * (1 - progress)
			cur_circle_delta = cur_circle_delta * self._tweak_data.circle_rotation_direction[i]

			self._circles[i].circle:set_current(1 - (1 - circle_diff) * progress)
			self._circles[i].circle._circle:set_rotation(starting_rotations[i] + cur_circle_delta)
		end

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._remove_circles()
	self._object:set_visible(false)
	self._bg_panel:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	managers.environment_controller:set_vignette(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())

	self._is_active = false
end

-- Lines 398-449
function HUDSpecialInteractionLockPick:_animate_interaction_complete()
	local duration = 0.33
	local t = 0
	local starting_progress = {}

	for i = 1, #self._circles do
		starting_progress[i] = self._circles[i].circle:current()
	end

	local pick_delta_y = 32 * #self._circles
	local pick_start_y = self._lockpick_texture:y()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress * 0.3)
		self._bg_plate:set_alpha(progress * 0.3)
		managers.environment_controller:set_vignette(progress)

		for i = 1, #self._circles do
			local cur_progress = math.lerp(0, starting_progress[i], progress)

			self._circles[i].circle:set_current(cur_progress)
			self._circles[i].circle._circle:set_rotation((1 - cur_progress) * 180)
		end

		local cur_delta_y = math.lerp(pick_delta_y, 0, progress)

		self._lockpick_texture:set_y(pick_start_y - cur_delta_y)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._remove_circles()
	self._object:set_visible(false)
	self._bg_panel:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())
	managers.environment_controller:set_vignette(0)

	self._is_active = false
end

-- Lines 453-489
function HUDSpecialInteractionLockPick:_animate_stage_complete(completed_circle)
	local duration = 0.4
	local t = 0
	local pick_delta_y = 32
	local pick_start_y = self._lockpick_texture:y()
	local pick_end_y = pick_start_y - pick_delta_y
	local circle_start_rot = completed_circle:rotation()
	local circle_end_rot = (1 - self._tweak_data.circle_difficulty[self._current_stage]) * 180
	local circle_end_alpha = 0.16 + self._current_stage * 0.1

	while t <= duration do
		local dt = coroutine.yield()
		t = t + dt
		local cur_delta_y = Easing.quintic_in(t, 0, pick_delta_y, duration)

		self._lockpick_texture:set_y(pick_start_y - cur_delta_y)

		local cur_circle_rot = Easing.quadratic_out(t, circle_start_rot, circle_end_rot - circle_start_rot, duration)

		completed_circle:set_rotation(cur_circle_rot)

		local progress = Easing.quintic_in(t, 0, 1, duration)
		local cur_circle_col = math.lerp(self.CIRCLE_COMPLETE_FLASH_COLOR, self.CIRCLE_COMPLETE_COLOR, progress)

		completed_circle:set_color(cur_circle_col)

		local cur_alpha = Easing.quintic_in(t, 1, -1 + circle_end_alpha, duration)

		completed_circle:set_alpha(cur_alpha)
	end

	self._lockpick_texture:set_y(pick_end_y)
	completed_circle:set_rotation(circle_end_rot)
	completed_circle:set_color(self.CIRCLE_COMPLETE_COLOR)
	completed_circle:set_alpha(circle_end_alpha)
end

-- Lines 491-510
function HUDSpecialInteractionLockPick:_animate_stage_failed()
	local duration = IngameSpecialInteraction.FAILED_COOLDOWN / 2
	local t = 0
	local pick_start_y = self._lockpick_texture:y()
	local freq = 1120
	local amp = 28

	while t <= duration do
		local dt = coroutine.yield()
		t = t + dt
		local cur_delta_y = math.abs(math.sin(t * freq) * amp * (duration - t))

		self._lockpick_texture:set_y(pick_start_y - cur_delta_y)
	end

	self._lockpick_texture:set_y(pick_start_y)
end
