HUDTabWeaponChallenge = HUDTabWeaponChallenge or class()
HUDTabWeaponChallenge.WIDTH = 384
HUDTabWeaponChallenge.HEIGHT = 256
HUDTabWeaponChallenge.RIGHT_SIDE_X = 64
HUDTabWeaponChallenge.TITLE_Y = 32
HUDTabWeaponChallenge.TITLE_H = 64
HUDTabWeaponChallenge.TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDTabWeaponChallenge.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTabWeaponChallenge.TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabWeaponChallenge.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
HUDTabWeaponChallenge.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDTabWeaponChallenge.DESCRIPTION_COLOR = Color("b8b8b8")
HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE = 30
HUDTabWeaponChallenge.INDEX_BULLET_INACTIVE_ICON = "bullet_empty"
HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON = "bullet_active"
HUDTabWeaponChallenge.INDEX_BULLET_PANEL_W = 96
HUDTabWeaponChallenge.INDEX_BULLET_PADDING = 5

-- Lines 25-36
function HUDTabWeaponChallenge:init(panel)
	self:_create_panel(panel)
	self:_create_inner_panel()
	self:_create_index_bullet_panel()
	self:_create_title()
	self:_create_tier_label()
	self:_create_icon()
	self:_create_description()
	self:_create_progress_bar()
end

-- Lines 38-48
function HUDTabWeaponChallenge:_create_panel(panel)
	local panel_params = {
		name = "weapon_challenge_panel",
		halign = "left",
		valign = "bottom",
		w = HUDTabWeaponChallenge.WIDTH + HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE,
		h = HUDTabWeaponChallenge.HEIGHT
	}
	self._object = panel:panel(panel_params)
	self._initial_x_position = self._object:x()
end

-- Lines 50-57
function HUDTabWeaponChallenge:_create_inner_panel()
	local inner_panel_params = {
		name = "weapon_challenge_inner_panel",
		halign = "grow",
		valign = "grow",
		w = self._object:w() - HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE
	}
	self._inner_panel = self._object:panel(inner_panel_params)
end

-- Lines 59-69
function HUDTabWeaponChallenge:_create_index_bullet_panel()
	local index_bullet_panel_params = {
		name = "index_bullet_panel",
		h = 32,
		halign = "right",
		valign = "top",
		w = HUDTabWeaponChallenge.INDEX_BULLET_PANEL_W
	}
	self._index_bullet_panel = self._object:panel(index_bullet_panel_params)

	self._index_bullet_panel:set_right(self._object:w() - HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE)
end

-- Lines 71-85
function HUDTabWeaponChallenge:_create_title()
	local title_params = {
		name = "weapon_challenge_title",
		vertical = "center",
		align = "left",
		text = "INCREASE ACCURACY",
		y = HUDTabWeaponChallenge.TITLE_Y,
		x = HUDTabWeaponChallenge.RIGHT_SIDE_X,
		w = self._inner_panel:w() - HUDTabWeaponChallenge.RIGHT_SIDE_X,
		h = HUDTabWeaponChallenge.TITLE_H,
		font = tweak_data.gui:get_font_path(HUDTabWeaponChallenge.TITLE_FONT, HUDTabWeaponChallenge.TITLE_FONT_SIZE),
		font_size = HUDTabWeaponChallenge.TITLE_FONT_SIZE,
		color = HUDTabWeaponChallenge.TITLE_COLOR
	}
	self._title = self._inner_panel:text(title_params)
end

-- Lines 87-99
function HUDTabWeaponChallenge:_create_tier_label()
	local tier_label_params = {
		name = "weapon_challenge_tier",
		vertical = "center",
		align = "left",
		text = "TI",
		y = HUDTabWeaponChallenge.TITLE_Y,
		h = HUDTabWeaponChallenge.TITLE_H,
		font = tweak_data.gui:get_font_path(HUDTabWeaponChallenge.TITLE_FONT, HUDTabWeaponChallenge.TITLE_FONT_SIZE),
		font_size = HUDTabWeaponChallenge.TITLE_FONT_SIZE,
		color = HUDTabWeaponChallenge.TITLE_COLOR
	}
	self._tier = self._inner_panel:text(tier_label_params)
end

-- Lines 101-111
function HUDTabWeaponChallenge:_create_icon()
	local default_icon = "wpn_skill_accuracy"
	local icon_params = {
		name = "weapon_challenge_icon",
		y = HUDTabWeaponChallenge.TITLE_Y + HUDTabWeaponChallenge.TITLE_H,
		texture = tweak_data.gui.icons[default_icon].texture,
		texture_rect = tweak_data.gui.icons[default_icon].texture_rect
	}
	self._icon = self._inner_panel:bitmap(icon_params)
end

-- Lines 113-126
function HUDTabWeaponChallenge:_create_description()
	local description_params = {
		name = "weapon_challenge_description",
		wrap = true,
		text = "Bla bla bla bla",
		x = HUDTabWeaponChallenge.RIGHT_SIDE_X,
		y = HUDTabWeaponChallenge.TITLE_Y + HUDTabWeaponChallenge.TITLE_H,
		w = self._inner_panel:w() - HUDTabWeaponChallenge.RIGHT_SIDE_X,
		font = tweak_data.gui:get_font_path(HUDTabWeaponChallenge.DESCRIPTION_FONT, HUDTabWeaponChallenge.DESCRIPTION_FONT_SIZE),
		font_size = HUDTabWeaponChallenge.DESCRIPTION_FONT_SIZE,
		color = HUDTabWeaponChallenge.DESCRIPTION_COLOR
	}
	self._description = self._inner_panel:text(description_params)
end

-- Lines 128-190
function HUDTabWeaponChallenge:_create_progress_bar()
	local texture_center = "slider_large_center"
	local texture_left = "slider_large_left"
	local texture_right = "slider_large_right"
	local progress_bar_panel_params = {
		vertical = "bottom",
		name = "weapon_challenge_progress_bar_panel",
		is_root_panel = true,
		x = 0,
		w = self._inner_panel:w(),
		h = tweak_data.gui:icon_h(texture_center)
	}
	self._progress_bar_panel = RaidGUIPanel:new(self._inner_panel, progress_bar_panel_params)

	self._progress_bar_panel:set_center_y(self._inner_panel:h() - 32)

	local progress_bar_background_params = {
		name = "weapon_challenge_progress_bar_background",
		layer = 1,
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = Color.white:with_alpha(0.5)
	}
	local progress_bar_background = self._progress_bar_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_foreground_panel_params = {
		halign = "scale",
		name = "weapon_challenge_progress_bar_foreground_panel",
		y = 0,
		layer = 2,
		x = 0,
		valign = "scale",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h()
	}
	self._progress_bar_foreground_panel = self._progress_bar_panel:panel(progress_bar_foreground_panel_params)
	local progress_bar_background_params = {
		name = "weapon_challenge_progress_bar_background",
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = tweak_data.gui.colors.raid_red
	}
	local progress_bar_background = self._progress_bar_foreground_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_text_params = {
		name = "weapon_challenge_progress_bar_text",
		vertical = "center",
		align = "center",
		text = "123/456",
		y = -2,
		x = 0,
		layer = 5,
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._progress_text = self._progress_bar_panel:label(progress_bar_text_params)
end

-- Lines 192-196
function HUDTabWeaponChallenge:set_challenges(challenges)
	self._challenges = challenges

	self:_create_challenge_bullets()
	self:set_challenge(1)
end

-- Lines 198-225
function HUDTabWeaponChallenge:_create_challenge_bullets()
	self._index_bullet_panel:clear()

	self._active_bullets = {}
	self._inactive_bullets = {}

	for i = #self._challenges, 1, -1 do
		local inactive_bullet_params = {
			x = self._index_bullet_panel:w() - tweak_data.gui:icon_w(HUDTabWeaponChallenge.INDEX_BULLET_INACTIVE_ICON) * i - HUDTabWeaponChallenge.INDEX_BULLET_PADDING * (i - 1),
			y = self._index_bullet_panel:h() / 2 - tweak_data.gui:icon_h(HUDTabWeaponChallenge.INDEX_BULLET_INACTIVE_ICON) / 2,
			texture = tweak_data.gui.icons[HUDTabWeaponChallenge.INDEX_BULLET_INACTIVE_ICON].texture,
			texture_rect = tweak_data.gui.icons[HUDTabWeaponChallenge.INDEX_BULLET_INACTIVE_ICON].texture_rect,
			layer = self._index_bullet_panel:layer() + 1
		}
		local inactive_bullet = self._index_bullet_panel:bitmap(inactive_bullet_params)

		table.insert(self._inactive_bullets, inactive_bullet)

		local active_bullet_params = {
			alpha = 0,
			texture = tweak_data.gui.icons[HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON].texture,
			texture_rect = tweak_data.gui.icons[HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON].texture_rect,
			layer = inactive_bullet:layer() + 1
		}
		local active_bullet = self._index_bullet_panel:bitmap(active_bullet_params)

		active_bullet:set_center(inactive_bullet:center())
		table.insert(self._active_bullets, active_bullet)
	end
end

-- Lines 227-244
function HUDTabWeaponChallenge:set_challenge(index, animate)
	if self._currently_shown_challenge == index then
		animate = false
	end

	if animate then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_data_change"), index)
	else
		self:_set_challenge(index)

		for index, bullet in pairs(self._active_bullets) do
			bullet:set_alpha(0)
		end

		self._active_bullets[index]:set_alpha(1)
	end
end

-- Lines 246-282
function HUDTabWeaponChallenge:_set_challenge(challenge_index)
	local challenge, count, target, min_range = nil
	local challenge_data = self._challenges[challenge_index]

	if challenge_data.challenge_id then
		challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_data.challenge_id)
		local tasks = challenge:tasks()
		count = tasks[1]:current_count()
		target = tasks[1]:target()
		min_range = math.round(tasks[1]:min_range() / 100)
	end

	local skill_tweak_data = tweak_data.weapon_skills.skills[challenge_data.skill_name]

	self._title:set_text(utf8.to_upper(managers.localization:text(skill_tweak_data.name_id)))
	self._description:set_text(managers.localization:text(challenge_data.challenge_briefing_id, {
		AMOUNT = target,
		RANGE = min_range,
		WEAPON = managers.localization:text(tweak_data.weapon[challenge_data.weapon_id].name_id)
	}))

	local tier_text = utf8.to_upper(managers.localization:text("menu_weapons_stats_tier_abbreviation")) .. RaidGUIControlWeaponSkills.ROMAN_NUMERALS[challenge_data.tier]

	self._tier:set_text(tier_text)

	local _, _, w, _ = self._tier:text_rect()

	self._tier:set_w(w)
	self._tier:set_center_x(self._icon:center_x())

	local icon = tweak_data.gui.icons[skill_tweak_data.icon]

	self._icon:set_image(icon.texture, unpack(icon.texture_rect))
	self._progress_bar_foreground_panel:set_w(self._progress_bar_panel:w() * count / target)

	local progress_text = nil

	if count ~= target then
		progress_text = tostring(count) .. "/" .. tostring(target)
	else
		progress_text = utf8.to_upper(managers.localization:text("menu_weapon_challenge_completed"))
	end

	self._progress_text:set_text(progress_text)

	self._currently_shown_challenge = challenge_index
end

-- Lines 285-288
function HUDTabWeaponChallenge:set_x(x)
	self._object:set_x(x)

	self._initial_x_position = self._object:x()
end

-- Lines 290-292
function HUDTabWeaponChallenge:set_y(y)
	self._object:set_y(y)
end

-- Lines 294-296
function HUDTabWeaponChallenge:set_bottom(y)
	self._object:set_bottom(y)
end

-- Lines 298-300
function HUDTabWeaponChallenge:set_top(y)
	self._object:set_top(y)
end

-- Lines 302-305
function HUDTabWeaponChallenge:set_left(x)
	self._object:set_left(x)

	self._initial_x_position = self._object:x()
end

-- Lines 307-310
function HUDTabWeaponChallenge:set_right(x)
	self._object:set_right(x)

	self._initial_x_position = self._object:x()
end

-- Lines 312-315
function HUDTabWeaponChallenge:set_center_x(x)
	self._object:set_center_x(x)

	self._initial_x_position = self._object:x()
end

-- Lines 317-319
function HUDTabWeaponChallenge:set_center_y(y)
	self._object:set_center_y(y)
end

-- Lines 321-323
function HUDTabWeaponChallenge:show()
	self._object:set_visible(true)
end

-- Lines 325-327
function HUDTabWeaponChallenge:hide()
	self._object:set_visible(false)
end

-- Lines 329-382
function HUDTabWeaponChallenge:_animate_data_change(panel, challenge_data)
	local fade_out_duration = 0.3
	local fade_in_duration = 0.3
	local t = (1 - self._inner_panel:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in(t, 1, -1, fade_out_duration)

		self._inner_panel:set_alpha(current_alpha)
		self._active_bullets[self._currently_shown_challenge]:set_w(current_alpha * tweak_data.gui:icon_w(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
		self._active_bullets[self._currently_shown_challenge]:set_h(current_alpha * tweak_data.gui:icon_h(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
		self._active_bullets[self._currently_shown_challenge]:set_center(self._inactive_bullets[self._currently_shown_challenge]:center())

		local current_position = Easing.quartic_in(t, 0, HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE, fade_out_duration)
		current_position = math.round(current_position)

		self._inner_panel:set_x(current_position)
	end

	self._inner_panel:set_alpha(0)
	self._inner_panel:set_x(HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE)
	self._active_bullets[self._currently_shown_challenge]:set_alpha(0)
	self._active_bullets[self._currently_shown_challenge]:set_w(tweak_data.gui:icon_w(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
	self._active_bullets[self._currently_shown_challenge]:set_h(tweak_data.gui:icon_h(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
	self._active_bullets[self._currently_shown_challenge]:set_center(self._inactive_bullets[self._currently_shown_challenge]:center())
	self:_set_challenge(challenge_data)
	self._active_bullets[self._currently_shown_challenge]:set_alpha(1)
	self._active_bullets[self._currently_shown_challenge]:set_w(0)
	self._active_bullets[self._currently_shown_challenge]:set_h(0)
	self._active_bullets[self._currently_shown_challenge]:set_center(self._inactive_bullets[self._currently_shown_challenge]:center())
	wait(0.2)

	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, fade_in_duration)

		self._inner_panel:set_alpha(current_alpha)
		self._active_bullets[self._currently_shown_challenge]:set_w(current_alpha * tweak_data.gui:icon_w(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
		self._active_bullets[self._currently_shown_challenge]:set_h(current_alpha * tweak_data.gui:icon_h(HUDTabWeaponChallenge.INDEX_BULLET_ACTIVE_ICON))
		self._active_bullets[self._currently_shown_challenge]:set_center(self._inactive_bullets[self._currently_shown_challenge]:center())

		local current_position = Easing.quartic_out(t, HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE, -HUDTabWeaponChallenge.ANIMATION_MOVE_X_DISTANCE, fade_in_duration)
		current_position = math.round(current_position)

		self._inner_panel:set_x(current_position)
	end

	self._inner_panel:set_alpha(1)
	self._inner_panel:set_x(0)
end
