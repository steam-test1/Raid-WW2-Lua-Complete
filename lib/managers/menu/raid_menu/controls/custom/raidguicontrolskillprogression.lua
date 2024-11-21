RaidGUIControlSkillProgression = RaidGUIControlSkillProgression or class(RaidGUIControl)
RaidGUIControlSkillProgression.DEFAULT_W = 150
RaidGUIControlSkillProgression.DEFAULT_H = 225
RaidGUIControlSkillProgression.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkillProgression.FONT_SIZE = tweak_data.gui.font_sizes.medium
RaidGUIControlSkillProgression.COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlSkillProgression.PURCHASABLE_COLOR = tweak_data.gui.colors.raid_gold
RaidGUIControlSkillProgression.LOCKED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlSkillProgression.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.medium
RaidGUIControlSkillProgression.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlSkillProgression.LOCK_ICON = "btn_circ_lock_hover"
RaidGUIControlSkillProgression.LOCK_ANIMATION_DISTANCE = 32
RaidGUIControlSkillProgression.PROGRESS_FILL_CLAMP = 0.989
RaidGUIControlSkillProgression.STATUS_MAX_TIER = "skill_progress_status_max_tier"
RaidGUIControlSkillProgression.STATUS_OWNED_OR_PURCHASED = "skill_progress_status_owned_or_purchased"
RaidGUIControlSkillProgression.STATUS_LOCKED = "skill_progress_status_locked"
RaidGUIControlSkillProgression.STATUS_PURCHASABLE = "skill_progress_status_purchasable"
RaidGUIControlSkillProgression.STATUS_LOCKED_DLC = "skill_progress_status_locked_dlc"

function RaidGUIControlSkillProgression:init(parent, params)
	RaidGUIControlSkillProgression.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkillProgression:init] Parameters not specified for the skill details " .. tostring(self._name))

		return
	end

	self._skill_icon = nil
	self._exp_fill = nil
	self._exp_fill_value = 0
	self._exp_text = nil
	self._current_exp = 0

	self:_init_control_panel()
	self:_init_skill_icon()
	self:_init_skill_progress()
	self:_init_skill_text()
end

function RaidGUIControlSkillProgression:_init_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_skillprog_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlSkillProgression.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlSkillProgression.DEFAULT_H
	self._object = self._panel:panel(control_params)
end

function RaidGUIControlSkillProgression:_init_skill_icon()
	local gui_icon_data = tweak_data.gui:get_full_gui_data("skills_placeholder")
	local size = self._object:w() * 0.65
	self._skill_icon = self._object:bitmap({
		name = "skill_icon",
		w = size,
		h = size,
		layer = self._object:layer() + 1,
		texture = gui_icon_data.texture,
		texture_rect = gui_icon_data.texture_rect
	})

	self._skill_icon:set_center(self._object:w() / 2, self._object:w() / 2)

	local lock_icon_data = tweak_data.gui:get_full_gui_data(RaidGUIControlSkillProgression.LOCK_ICON)
	size = self._skill_icon:w() / 2
	self._lock_icon = self._object:bitmap({
		visible = false,
		name = "lock_icon",
		w = size,
		h = size,
		layer = self._object:layer() + 2,
		texture = lock_icon_data.texture,
		texture_rect = lock_icon_data.texture_rect
	})

	self._lock_icon:set_center(self._object:w() * 0.85, self._object:w() * 0.85)
end

function RaidGUIControlSkillProgression:set_skill_icon(icon)
	self._skill_icon:set_image(icon.texture, unpack(icon.texture_rect))
end

function RaidGUIControlSkillProgression:_init_skill_progress()
	self._exp_fill = CircleBitmapGuiObject:new(self._object, {
		bg_alpha = 0.5,
		use_bg = true,
		w = self._object:w(),
		h = self._object:w(),
		radius = self._object:w() / 2,
		image = tweak_data.gui.icons.skill_progress_circle_256px.texture,
		bg_image = tweak_data.gui.icons.skill_progress_circle_256px.texture,
		color = tweak_data.gui.colors.raid_red,
		bg_color = tweak_data.gui.colors.raid_dark_grey,
		layer = self._object:layer() + 1
	})
end

function RaidGUIControlSkillProgression:_init_earned_progress()
	self._earned_exp_fill = CircleBitmapGuiObject:new(self._object, {
		rotation = 360,
		w = self._object:w(),
		h = self._object:w(),
		radius = self._object:w() / 2,
		image = tweak_data.gui.icons.skill_progress_circle_256px.texture,
		bg_image = tweak_data.gui.icons.skill_progress_circle_256px.texture,
		bg_color = tweak_data.gui.colors.raid_dark_grey,
		layer = self._exp_fill:layer() - 1
	})

	self._earned_exp_fill:set_color(self._exp_fill:color() * 0.7)

	local size = self._skill_icon:w() / 3
	local gui_data = tweak_data.gui:get_full_gui_data("ico_map_mini_raid")
	self._level_up_icon = self._object:bitmap({
		visible = false,
		name = "level_up_icon",
		w = size,
		h = size,
		layer = self._object:layer() + 2,
		color = tweak_data.gui.colors.raid_gold,
		texture = gui_data.texture,
		texture_rect = {
			gui_data.texture_rect[1],
			gui_data.texture_rect[2] + gui_data.texture_rect[4],
			gui_data.texture_rect[3],
			-gui_data.texture_rect[4]
		}
	})

	self._level_up_icon:set_right(self._object:w())
end

function RaidGUIControlSkillProgression:set_progress(value)
	if value < 1 then
		value = math.min(value, self.PROGRESS_FILL_CLAMP)
	end

	self._exp_fill_value = value

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_change_progress"))
end

function RaidGUIControlSkillProgression:set_earned_xp(value, params)
	self._earned_exp_value = value

	if not self._earned_exp_fill then
		self:_init_earned_progress()
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_change_earned_progress", params))
end

function RaidGUIControlSkillProgression:set_progress_color(color)
	self._exp_fill:set_color(color)
end

function RaidGUIControlSkillProgression:_toggle_status_max_tier()
	if self._lock_icon:visible() then
		self._lock_icon:stop()
		self._lock_icon:animate(callback(self, self, "_animate_hide_lock"))
	end

	self._resource_icon:hide()
	self._skill_icon:set_color(RaidGUIControlSkillProgression.COLOR)
	self._progress_text:set_color(self._exp_fill:color())
	self._progress_desc:set_color(RaidGUIControlSkillProgression.DESCRIPTION_COLOR)
	self._progress_desc:set_text("")
end

function RaidGUIControlSkillProgression:_toggle_status_normal()
	if self._lock_icon:visible() then
		self._lock_icon:stop()
		self._lock_icon:animate(callback(self, self, "_animate_hide_lock"))
	end

	self._resource_icon:hide()
	self._skill_icon:set_color(RaidGUIControlSkillProgression.COLOR)
	self._progress_text:set_color(RaidGUIControlSkillProgression.COLOR)
	self._progress_desc:set_color(RaidGUIControlSkillProgression.DESCRIPTION_COLOR)
	self._progress_desc:set_text(self:translate("menu_skills_progress_desc_xp", true))
end

function RaidGUIControlSkillProgression:_toggle_status_locked()
	if not self._lock_icon:visible() then
		self._lock_icon:stop()
		self._lock_icon:animate(callback(self, self, "_animate_show_lock"))
	end

	self._resource_icon:hide()
	self._skill_icon:set_color(RaidGUIControlSkillProgression.LOCKED_COLOR)
	self._progress_text:set_color(RaidGUIControlSkillProgression.COLOR)
	self._progress_desc:set_color(RaidGUIControlSkillProgression.DESCRIPTION_COLOR)
	self._progress_desc:set_text(self:translate("menu_skills_progress_desc_level", true))
end

function RaidGUIControlSkillProgression:_toggle_status_purchasable()
	if self._lock_icon:visible() then
		self._lock_icon:stop()
		self._lock_icon:animate(callback(self, self, "_animate_hide_lock"))
	end

	self._resource_icon:show()
	self._skill_icon:set_color(RaidGUIControlSkillProgression.LOCKED_COLOR)
	self._progress_text:set_color(RaidGUIControlSkillProgression.PURCHASABLE_COLOR)
	self._progress_desc:set_color(RaidGUIControlSkillProgression.PURCHASABLE_COLOR)
	self._progress_text:set_center_x(self._object:w() / 2 + self._resource_icon:w() / 2)
	self._resource_icon:set_right(self._progress_text:x())
	self._progress_desc:set_text(self:translate("menu_skills_progress_desc_gold", true))
end

function RaidGUIControlSkillProgression:_toggle_status_challenge()
	if self._lock_icon:visible() then
		self._lock_icon:stop()
		self._lock_icon:animate(callback(self, self, "_animate_hide_lock"))
	end

	self._resource_icon:show()
	self._progress_text:set_center_x(self._object:w() / 2 + self._resource_icon:w() / 2)
	self._resource_icon:set_right(self._progress_text:x())
	self._progress_desc:set_text(self:translate("menu_skills_progress_desc_challenge", true))
end

function RaidGUIControlSkillProgression:_init_skill_text()
	self._progress_text = self._object:label({
		text = "???",
		align = "center",
		name = "progress_text",
		w = self._object:w(),
		font = RaidGUIControlSkillProgression.FONT,
		font_size = RaidGUIControlSkillProgression.FONT_SIZE,
		color = RaidGUIControlSkillProgression.COLOR,
		layer = self._object:layer() + 1
	})
	local h = select(4, self._progress_text:text_rect())

	self._progress_text:set_y(self._exp_fill:bottom() + 4)
	self._progress_text:set_h(h)

	self._progress_desc = self._object:label({
		align = "center",
		text = "UNTIL NEXT TIER",
		name = "progress_desc",
		w = self._object:w(),
		h = h,
		font = RaidGUIControlSkillProgression.FONT,
		font_size = RaidGUIControlSkillProgression.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlSkillProgression.DESCRIPTION_COLOR,
		layer = self._object:layer() + 1
	})

	self._progress_desc:set_y(self._progress_text:bottom())

	local gold_amount_footer = tweak_data.gui:get_full_gui_data("gold_amount_footer")
	self._resource_icon = self._object:image({
		visible = false,
		name = "resource_icon",
		texture = gold_amount_footer.texture,
		texture_rect = gold_amount_footer.texture_rect,
		color = tweak_data.gui.colors.gold_orange
	})

	self._resource_icon:set_center(self._progress_text:center_x(), self._progress_text:center_y())
end

function RaidGUIControlSkillProgression:set_status(status, text)
	if text then
		self._progress_text:set_text(text)

		local _, _, w, h = self._progress_text:text_rect()

		self._progress_text:set_w(w)
		self._progress_text:set_h(h)
		self._progress_text:set_center_x(self._object:w() / 2)
		self._progress_text:set_y(self._exp_fill:bottom() + 4)
	end

	if status == RaidGUIControlSkillProgression.STATUS_MAX_TIER then
		self:_toggle_status_max_tier()
	elseif status == RaidGUIControlSkillProgression.STATUS_OWNED_OR_PURCHASED then
		self:_toggle_status_normal()
	elseif status == RaidGUIControlSkillProgression.STATUS_PURCHASABLE then
		self:_toggle_status_purchasable()
	else
		self:_toggle_status_locked()
	end
end

function RaidGUIControlSkillProgression:_animate_change_progress()
	local t = 0
	local duration = 0.2
	local start_value = self._exp_fill:current()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_value = Easing.quadratic_out(t, start_value, self._exp_fill_value - start_value, duration)

		self._exp_fill:set_current(current_value)
	end

	self._exp_fill:set_current(self._exp_fill_value)
end

function RaidGUIControlSkillProgression:_animate_change_earned_progress(params, panel)
	if not params.previous_tier or not params.current_tier then
		Application:warn("[RaidGUIControlSkillProgression:_animate_change_earned_progress] animation missing a tier value", params.previous_tier, params.current_tier)

		return
	end

	self._earned_exp_fill:set_current(self._exp_fill_value)

	local max_tier = params.max_tier
	local previous_tier = params.previous_tier
	local current_tier = params.current_tier
	local i = previous_tier

	repeat
		local t = 0
		local duration = 1.2
		local start_value = i == previous_tier and self._exp_fill_value or 0
		local end_value = i == current_tier and self._earned_exp_value or 1

		if i == current_tier then
			end_value = math.min(end_value, self.PROGRESS_FILL_CLAMP)
		end

		i = i + 1
		local at_max_tier = i == max_tier

		while t < duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_value = Easing.quadratic_in_out(t, start_value, end_value - start_value, duration)

			self._earned_exp_fill:set_current(current_value)
		end

		self._earned_exp_fill:set_current(end_value)

		if end_value >= 1 then
			self._level_up_icon:set_visible(true)
			self._level_up_icon:set_alpha(0)

			if at_max_tier then
				self._exp_fill:set_current(1)
			end

			local t = 0
			local duration = 0.4

			while t < duration do
				local dt = coroutine.yield()
				t = t + dt
				local current_alpha = Easing.quadratic_in_out(t, 0, 1, duration)

				self._level_up_icon:set_alpha(current_alpha)

				local current_y = math.lerp(20, 0, current_alpha)

				self._level_up_icon:set_y(current_y)

				local current_size = Easing.quadratic_in(t, self._object:w(), 25, duration)

				self._earned_exp_fill:set_size(current_size, current_size)
				self._earned_exp_fill:set_center(self._object:w() / 2, self._object:w() / 2)
				self._earned_exp_fill:set_alpha(1 - current_alpha)

				if not at_max_tier then
					self._exp_fill:set_alpha(1 - current_alpha)
				end
			end

			self._earned_exp_fill:set_current(0)
			self._earned_exp_fill:set_alpha(1)
			self._earned_exp_fill:set_size(self._object:w(), self._object:w())
			self._earned_exp_fill:set_center(self._object:w() / 2, self._object:w() / 2)
			self._level_up_icon:set_alpha(1)

			if not at_max_tier then
				self._exp_fill:set_current(0)
			end

			self._exp_fill:set_alpha(1)
			wait(0.2)
		end
	until current_tier < i or at_max_tier
end

function RaidGUIControlSkillProgression:_animate_show_lock()
	local duration = 0.06
	local t = self._lock_icon:alpha() * duration
	local y = self._object:w() * 0.85

	self._lock_icon:show()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_out(t, 0, 1, duration)

		self._lock_icon:set_alpha(current_alpha)

		local current_y = Easing.quadratic_out(t, y + RaidGUIControlSkillProgression.LOCK_ANIMATION_DISTANCE, -RaidGUIControlSkillProgression.LOCK_ANIMATION_DISTANCE, duration)

		self._lock_icon:set_center_y(current_y)
	end

	self._lock_icon:set_alpha(1)
	self._lock_icon:set_center_y(y)
end

function RaidGUIControlSkillProgression:_animate_hide_lock()
	local duration = 0.06
	local t = (1 - self._lock_icon:alpha()) * duration
	local y = self._object:w() * 0.85

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._lock_icon:set_alpha(current_alpha)

		local current_y = Easing.quadratic_in(t, y, RaidGUIControlSkillProgression.LOCK_ANIMATION_DISTANCE, duration)

		self._lock_icon:set_center_y(current_y)
	end

	self._lock_icon:set_alpha(0)
	self._lock_icon:set_center_y(y)
	self._lock_icon:hide()
end
