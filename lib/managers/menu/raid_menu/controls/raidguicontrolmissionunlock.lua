RaidGUIControlMissionUnlock = RaidGUIControlMissionUnlock or class(RaidGUIControl)
RaidGUIControlMissionUnlock.WIDTH = 448
RaidGUIControlMissionUnlock.HEIGHT = 688
RaidGUIControlMissionUnlock.ACTIVE_Y_OFFSET = 85
RaidGUIControlMissionUnlock.DESCRIPTION_Y = 480
RaidGUIControlMissionUnlock.DESCRIPTION_Y_OFFSET = 30

function RaidGUIControlMissionUnlock:init(parent, params)
	RaidGUIControlMissionUnlock.super.init(self, parent, params)

	self._mission = params.mission

	if not tweak_data.operations.missions[self._mission] then
		Application:error("[RaidGUIControlMissionUnlock] Trying to init with an invalid or removed mission ID!", self._mission)
	end

	self._on_click_callback = params.on_click_callback
	self._on_double_click_callback = params.on_double_click_callback

	self:_create_panel()
	self:_create_background()
	self:_create_selector_triangles()
	self:_create_active_border()
	self:_create_folder()
	self:_create_mission_description()
end

function RaidGUIControlMissionUnlock:_create_panel()
	local panel_params = {
		h = nil,
		name = nil,
		w = nil,
		name = "mission_unlock_" .. self._params.mission,
		w = RaidGUIControlMissionUnlock.WIDTH,
		h = RaidGUIControlMissionUnlock.HEIGHT
	}
	self._object = self._panel:panel(panel_params)
end

function RaidGUIControlMissionUnlock:_create_background()
	local background_params = {
		color = nil,
		visible = false,
		name = "background",
		layer = 1,
		color = tweak_data.gui.colors.raid_unlock_select_background
	}
	self._background = self._object:rect(background_params)
end

function RaidGUIControlMissionUnlock:_create_selector_triangles()
	local top_select_triangle_params = {
		texture_rect = nil,
		layer = 3,
		rotation = 90,
		visible = false,
		texture = nil,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	}
	self._top_triangle = self._object:bitmap(top_select_triangle_params)

	self._top_triangle:set_right(self._object:w())

	local bottom_select_triangle_params = {
		texture_rect = nil,
		layer = 3,
		rotation = 45,
		visible = false,
		texture = nil,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	}
	self._bottom_triangle = self._object:bitmap(top_select_triangle_params)

	self._bottom_triangle:set_bottom(self._object:h())
	self._bottom_triangle:set_rotation(-90)
end

function RaidGUIControlMissionUnlock:_create_active_border()
	local border_color = tweak_data.gui.colors.raid_red
	local border_thickness = 2
	local border_panel_params = {
		name = "border_panel",
		visible = false
	}
	self._border_panel = self._object:panel(border_panel_params)
	local top_border_params = {
		color = nil,
		name = "top_border",
		layer = 2,
		h = nil,
		w = nil,
		w = self._border_panel:w(),
		h = border_thickness,
		color = border_color
	}
	local top_border = self._border_panel:rect(top_border_params)
	local bottom_border_params = {
		color = nil,
		name = "bottom_border",
		layer = 2,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = border_thickness,
		color = border_color
	}
	local bottom_border = self._border_panel:rect(bottom_border_params)

	bottom_border:set_bottom(self._border_panel:h())

	local left_border_params = {
		color = nil,
		name = "left_border",
		layer = 2,
		h = nil,
		w = nil,
		w = border_thickness,
		h = self._border_panel:h(),
		color = border_color
	}
	local left_border = self._border_panel:rect(left_border_params)
	local right_border_params = {
		color = nil,
		name = "right_border",
		layer = 2,
		h = nil,
		w = nil,
		w = border_thickness,
		h = self._border_panel:h(),
		color = border_color
	}
	local right_border = self._border_panel:rect(right_border_params)

	right_border:set_right(self._border_panel:w())
end

function RaidGUIControlMissionUnlock:_create_folder()
	local mission_tweak_data = tweak_data.operations:mission_data(self._mission)

	if not mission_tweak_data then
		Application:error("[RaidGUIControlMissionUnlock] Mission Data was missing for mission", self._mission)

		return
	end

	local folder_panel_params = {
		name = "folder_panel",
		h = 448,
		layer = 5
	}
	self._folder_panel = self._object:panel(folder_panel_params)

	self._folder_panel:set_center_y(self._object:h() / 2)

	local folder_image_params = {
		texture_rect = nil,
		layer = 50,
		name = "folder_image",
		texture = nil,
		texture = tweak_data.gui.icons.folder_mission_selection.texture,
		texture_rect = tweak_data.gui.icons.folder_mission_selection.texture_rect
	}
	self._folder_image = self._folder_panel:bitmap(folder_image_params)

	self._folder_image:set_center_x(self._folder_panel:w() / 2)
	self._folder_image:set_center_y(self._folder_panel:h() / 2)

	local icon_id = mission_tweak_data.icon_menu_big or "xp_events_missions_raids_category"
	local icon_w = tweak_data.gui:icon_w(icon_id)
	local icon_h = tweak_data.gui:icon_h(icon_id)
	local mission_image_params = {
		valign = "center",
		halign = "center",
		name = "mission_icon",
		layer = nil,
		texture_rect = nil,
		w = nil,
		color = nil,
		texture = nil,
		texture = tweak_data.gui.icons[icon_id].texture,
		texture_rect = tweak_data.gui.icons[icon_id].texture_rect,
		w = self._folder_image:w() * 0.7,
		layer = self._folder_image:layer() + 1,
		color = tweak_data.gui.colors.raid_light_red,
		layer = self._folder_image:layer() + 1
	}
	self._mission_image = self._folder_panel:bitmap(mission_image_params)

	self._mission_image:set_h(self._mission_image:w() * icon_h / icon_w)
	self._mission_image:set_center_x(self._folder_image:center_x())
	self._mission_image:set_center_y(self._folder_image:center_y() - 20)

	local mission_title_params = {
		text = nil,
		vertical = "center",
		align = "center",
		layer = nil,
		font = nil,
		font_size = nil,
		name = "folder_mission_title",
		color = nil,
		h = 32,
		w = 192,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_light_red,
		layer = self._mission_image:layer(),
		text = self:translate(mission_tweak_data.name_id, true),
		layer = self._folder_image:layer() + 1
	}
	self._folder_mission_title = self._folder_panel:text(mission_title_params)

	self._folder_mission_title:set_center_x(self._mission_image:center_x())
	self._folder_mission_title:set_center_y(self._mission_image:center_y() + 124)
	self:_fit_mission_title()

	self._mission_photos = {}
	local mission_photos = deep_clone(mission_tweak_data.photos)

	math.shuffle(mission_photos)

	local mission_photo_data = table.remove(mission_photos)
	local mission_photo_params = {
		static = true,
		photo = nil,
		alpha = 0,
		layer = 1,
		photo = mission_photo_data.photo
	}
	local mission_photo = self._folder_panel:create_custom_control(RaidGUIControlIntelImage, mission_photo_params)
	local position_x = math.random() * 0.07 + 0.72
	local position_y = math.random() * 0.06 + 0.16

	mission_photo:set_center_x(self._folder_image:x() + self._folder_image:w() * position_x)
	mission_photo:set_center_y(self._folder_image:y() + self._folder_image:h() * position_y)

	local rotation = math.random(-3, -0.7)

	mission_photo:set_rotation(rotation)
	table.insert(self._mission_photos, {
		position_x = nil,
		photo = nil,
		final_alpha = 1,
		rotation = nil,
		initial_y = 0.25,
		initial_x = 0.5,
		initial_alpha = 1,
		position_y = nil,
		photo = mission_photo,
		rotation = rotation,
		position_x = position_x,
		position_y = position_y
	})

	mission_photo_data = table.remove(mission_photos)
	mission_photo_params = {
		static = true,
		photo = nil,
		alpha = 0,
		layer = 3,
		photo = mission_photo_data.photo
	}
	mission_photo = self._folder_panel:create_custom_control(RaidGUIControlIntelImage, mission_photo_params)
	position_x = math.random() * 0.07 + 0.65
	position_y = math.random() * 0.04 + 0.47

	mission_photo:set_center_x(self._folder_image:x() + self._folder_image:w() * position_x)
	mission_photo:set_center_y(self._folder_image:y() + self._folder_image:h() * position_y)

	rotation = math.random(-2, -2)

	mission_photo:set_rotation(rotation)
	table.insert(self._mission_photos, {
		position_x = nil,
		photo = nil,
		final_alpha = 1,
		rotation = nil,
		initial_y = nil,
		initial_x = 0.5,
		initial_alpha = 1,
		position_y = nil,
		photo = mission_photo,
		rotation = rotation,
		position_x = position_x,
		initial_y = position_y,
		position_y = position_y
	})

	mission_photo_data = table.remove(mission_photos)
	mission_photo_params = {
		static = true,
		photo = nil,
		alpha = 0,
		layer = nil,
		photo = mission_photo_data.photo,
		layer = self._folder_mission_title:layer() + 1
	}
	mission_photo = self._folder_panel:create_custom_control(RaidGUIControlIntelImage, mission_photo_params)
	position_x = math.random() * 0.07 + 0.31
	position_y = math.random() * 0.03 + 0.79

	mission_photo:set_center_x(self._folder_image:x() + self._folder_image:w() * position_x)
	mission_photo:set_center_y(self._folder_image:y() + self._folder_image:h() * position_y)

	rotation = math.random(-2, 5)

	mission_photo:set_rotation(rotation)
	table.insert(self._mission_photos, {
		position_x = nil,
		photo = nil,
		final_alpha = 1,
		rotation = nil,
		initial_y = 0.6,
		initial_x = 0.5,
		initial_alpha = 0,
		position_y = nil,
		photo = mission_photo,
		rotation = rotation,
		position_x = position_x,
		position_y = position_y
	})
end

function RaidGUIControlMissionUnlock:_fit_mission_title()
	local default_font_size = tweak_data.gui.font_sizes.size_32
	local font_sizes = {}

	for index, size in pairs(tweak_data.gui.font_sizes) do
		if size <= default_font_size then
			table.insert(font_sizes, size)
		end
	end

	table.sort(font_sizes)

	for i = #font_sizes, 1, -1 do
		self._folder_mission_title:set_font_size(font_sizes[i])

		local _, _, w, _ = self._folder_mission_title:text_rect()

		if w <= self._folder_mission_title:w() then
			break
		end
	end
end

function RaidGUIControlMissionUnlock:_create_mission_description()
	local mission_tweak_data = tweak_data.operations:mission_data(self._mission)
	local mission_description_panel_params = {
		w = 384,
		alpha = 0,
		name = "mission_description_panel",
		h = 192,
		y = nil,
		y = RaidGUIControlMissionUnlock.DESCRIPTION_Y
	}
	self._description_panel = self._object:panel(mission_description_panel_params)

	self._description_panel:set_center_x(self._object:w() / 2)

	local mission_title_params = {
		font = nil,
		vertical = "center",
		name = "mission_title",
		align = "center",
		color = nil,
		font_size = nil,
		h = 32,
		text = nil,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_dirty_white,
		text = self:translate(mission_tweak_data.name_id, true)
	}
	self._mission_title = self._description_panel:text(mission_title_params)
	local mission_description_params = {
		text = nil,
		vertical = "top",
		align = "center",
		font = nil,
		name = "mission_description",
		font_size = nil,
		y = 48,
		color = nil,
		wrap = true,
		h = nil,
		h = self._description_panel:h() - 32,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey,
		text = self:translate(mission_tweak_data.loading.text)
	}
	self._mission_description = self._description_panel:text(mission_description_params)

	self._mission_description:set_center_x(self._description_panel:w() / 2)
end

function RaidGUIControlMissionUnlock:close()
end

function RaidGUIControlMissionUnlock:mission()
	return self._mission
end

function RaidGUIControlMissionUnlock:on_mouse_released()
	self:set_active(not self._active)

	self._selected = self._active

	managers.menu_component:post_event("highlight")

	if self._on_click_callback then
		self:_on_click_callback(self._mission, self._active)
	end
end

function RaidGUIControlMissionUnlock:on_double_click()
	if self._on_double_click_callback then
		self._on_double_click_callback(self._mission, self._active)

		return true
	end

	return false
end

function RaidGUIControlMissionUnlock:confirm_pressed()
	self:on_double_click()
end

function RaidGUIControlMissionUnlock:on_mouse_over(x, y)
	RaidGUIControlMissionUnlock.super.on_mouse_over(self, x, y)

	self._mouse_inside = true

	self:_highlight_on()
end

function RaidGUIControlMissionUnlock:on_mouse_out(x, y)
	RaidGUIControlMissionUnlock.super.on_mouse_out(self, x, y)

	self._mouse_inside = false

	self:_highlight_off()
end

function RaidGUIControlMissionUnlock:_highlight_on()
	if self._active then
		return
	end

	self._folder_image:stop()
	self._folder_image:animate(callback(self, self, "_animate_open_folder"))
end

function RaidGUIControlMissionUnlock:_highlight_off()
	if self._active then
		return
	end

	self._folder_image:stop()
	self._folder_image:animate(callback(self, self, "_animate_close_folder"))
end

function RaidGUIControlMissionUnlock:set_active(active)
	self._active = active

	self._background:set_visible(active)
	self._top_triangle:set_visible(active)
	self._bottom_triangle:set_visible(active)

	if not active and not self._mouse_inside then
		self:_highlight_off()
	end
end

function RaidGUIControlMissionUnlock:set_selected(selected)
	if selected then
		self:select()
	else
		self:unselect()
	end

	self:on_mouse_released()
end

function RaidGUIControlMissionUnlock:select()
	self._selected = true

	self._folder_image:stop()
	self._folder_image:animate(callback(self, self, "_animate_open_folder"))
end

function RaidGUIControlMissionUnlock:unselect()
	self._selected = false

	self._folder_image:stop()
	self._folder_image:animate(callback(self, self, "_animate_close_folder"))
end

function RaidGUIControlMissionUnlock:_animate_open_folder(o)
	local duration = 0.4
	self._show_details_animation_t = self._show_details_animation_t or 0
	local t = self._show_details_animation_t * duration

	managers.menu_component:post_event("paper_shuffle_menu")

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in_out(t, 0, RaidGUIControlMissionUnlock.ACTIVE_Y_OFFSET, duration)

		self._folder_panel:set_center_y(self._object:h() / 2 - current_offset)

		local current_description_offset = Easing.quartic_in_out(t, RaidGUIControlMissionUnlock.DESCRIPTION_Y_OFFSET, -RaidGUIControlMissionUnlock.DESCRIPTION_Y_OFFSET, duration)

		self._description_panel:set_y(RaidGUIControlMissionUnlock.DESCRIPTION_Y + current_description_offset)

		if duration - t < 0.25 then
			local current_description_alpha = Easing.quartic_in_out(t - (duration - 0.2), 0, 1, 0.25)

			self._description_panel:set_alpha(current_description_alpha)
		end

		for index, photo_data in pairs(self._mission_photos) do
			local current_x = Easing.quartic_out(t, photo_data.initial_x, photo_data.position_x - photo_data.initial_x, duration)

			photo_data.photo:set_center_x(self._folder_image:x() + self._folder_image:w() * current_x)

			local current_y = Easing.quartic_out(t, photo_data.initial_y, photo_data.position_y - photo_data.initial_y, duration)

			photo_data.photo:set_center_y(self._folder_image:y() + self._folder_image:h() * current_y)

			local current_photo_alpha = Easing.quartic_in_out(t, photo_data.initial_alpha, photo_data.final_alpha - photo_data.initial_alpha, duration)

			photo_data.photo:set_alpha(current_photo_alpha)
		end

		self._show_details_animation_t = t / duration
	end

	self._show_details_animation_t = 1

	self._folder_panel:set_center_y(self._object:h() / 2 - RaidGUIControlMissionUnlock.ACTIVE_Y_OFFSET)
	self._description_panel:set_alpha(1)
	self._description_panel:set_y(RaidGUIControlMissionUnlock.DESCRIPTION_Y)

	for index, photo_data in pairs(self._mission_photos) do
		photo_data.photo:set_center_x(self._folder_image:x() + self._folder_image:w() * photo_data.position_x)
		photo_data.photo:set_center_y(self._folder_image:y() + self._folder_image:h() * photo_data.position_y)
		photo_data.photo:set_alpha(photo_data.final_alpha)
	end
end

function RaidGUIControlMissionUnlock:_animate_close_folder(o)
	local duration = 0.4
	self._show_details_animation_t = self._show_details_animation_t or 0
	local t = (1 - self._show_details_animation_t) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in_out(t, RaidGUIControlMissionUnlock.ACTIVE_Y_OFFSET, -RaidGUIControlMissionUnlock.ACTIVE_Y_OFFSET, duration)

		self._folder_panel:set_center_y(self._object:h() / 2 - current_offset)

		local current_description_offset = Easing.quartic_in_out(t, 0, RaidGUIControlMissionUnlock.DESCRIPTION_Y_OFFSET, duration)

		self._description_panel:set_y(RaidGUIControlMissionUnlock.DESCRIPTION_Y + current_description_offset)

		local current_description_alpha = Easing.quartic_in_out(t, 1, -1, 0.25)

		self._description_panel:set_alpha(current_description_alpha)

		for index, photo_data in pairs(self._mission_photos) do
			local current_x = Easing.quartic_in(t, photo_data.position_x, photo_data.initial_x - photo_data.position_x, duration)

			photo_data.photo:set_center_x(self._folder_image:x() + self._folder_image:w() * current_x)

			local current_y = Easing.quartic_in(t, photo_data.position_y, photo_data.initial_y - photo_data.position_y, duration)

			photo_data.photo:set_center_y(self._folder_image:y() + self._folder_image:h() * current_y)

			local current_photo_alpha = Easing.quartic_in_out(t, photo_data.final_alpha, photo_data.initial_alpha - photo_data.final_alpha, duration)

			photo_data.photo:set_alpha(current_photo_alpha)
		end

		self._show_details_animation_t = 1 - t / duration
	end

	self._show_details_animation_t = 0

	self._folder_panel:set_center_y(self._object:h() / 2)
	self._description_panel:set_alpha(0)
	self._description_panel:set_y(RaidGUIControlMissionUnlock.DESCRIPTION_Y + RaidGUIControlMissionUnlock.DESCRIPTION_Y_OFFSET)

	for index, photo_data in pairs(self._mission_photos) do
		photo_data.photo:set_center_x(self._folder_image:x() + self._folder_image:w() * photo_data.initial_x)
		photo_data.photo:set_center_y(self._folder_image:y() + self._folder_image:h() * photo_data.initial_y)
		photo_data.photo:set_alpha(photo_data.initial_alpha)
	end
end
