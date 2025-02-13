HUDNameLabel = HUDNameLabel or class()
HUDNameLabel.W = 200
HUDNameLabel.H = 70
HUDNameLabel.PLAYER_NAME_H = 30
HUDNameLabel.PLAYER_NAME_FONT = tweak_data.gui.fonts.din_compressed_outlined_22
HUDNameLabel.PLAYER_NAME_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDNameLabel.INTERACTION_PANEL_W = 40
HUDNameLabel.INTERACTION_PANEL_H = 40
HUDNameLabel.PROGRESS_BAR_ICON_BG = "player_panel_interaction_teammate_bg"
HUDNameLabel.PROGRESS_BAR_ICON_FILL = "teammate_interact_fill_large"
HUDNameLabel.MOUNTED_WEAPON_ICON = "player_panel_status_mounted_weapon"
HUDNameLabel.LOCKPICK_ICON = "player_panel_status_lockpick"
HUDNameLabel.TIMER_BG_ICON = "player_panel_ai_downed_and_objective_countdown_bg"
HUDNameLabel.TIMER_BAR_ICON = "teammate_circle_fill_small"
HUDNameLabel.TIMER_FONT = "din_compressed_outlined_24"
HUDNameLabel.TIMER_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDNameLabel.STATES = {
	{
		id = "downed",
		control = "timer_panel"
	},
	{
		id = "interaction",
		control = "interaction_panel"
	},
	{
		id = "special_interaction",
		control = "special_interaction_icon"
	},
	{
		id = "mounted_weapon",
		control = "mounted_weapon_icon"
	},
	{
		id = "normal",
		control = "character_name"
	}
}

function HUDNameLabel:init(hud, params)
	self._name = params.name
	self._nationality = params.nationality
	self._id = params.id
	self._peer_id = params.peer_id
	self._movement = params.movement
	self._states = HUDNameLabel.STATES
	self._displayed_state = self._states[#self._states]
	self._active_states = {}

	self:_add_active_state(self._displayed_state.id)

	local peer = managers.network:session():peer(self._peer_id)

	if peer then
		self.class = peer:class()
	end

	self:_create_panel(hud)
	self:_create_name()
	self:_create_timer()
	self:_create_special_interaction_icon()
	self:_create_mounted_weapon_icon()
	self:_create_interaction_progress_bar()
end

function HUDNameLabel:_create_panel(hud)
	local panel_params = {
		name = "name_label_" .. tostring(self._nationality),
		w = HUDNameLabel.W,
		h = HUDNameLabel.H
	}
	self._object = hud.panel:panel(panel_params)
end

function HUDNameLabel:_create_name()
	local name_params = {
		name = "character_name",
		vertical = "center",
		align = "center",
		w = self._object:w(),
		h = HUDNameLabel.PLAYER_NAME_H,
		font = HUDNameLabel.PLAYER_NAME_FONT,
		font_size = HUDNameLabel.PLAYER_NAME_FONT_SIZE,
		text = utf8.to_upper(self._name)
	}
	self._character_name = self._object:text(name_params)

	self._character_name:set_center_x(self._object:w() / 2)
	self._character_name:set_center_y(self._object:h() / 2)
end

function HUDNameLabel:_create_nationality_icon()
	local nationality_icon = "player_panel_nationality_" .. tostring(self._nationality)
	local icon_params = {
		name = "nationality_icon",
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[nationality_icon].texture,
		texture_rect = tweak_data.gui.icons[nationality_icon].texture_rect
	}
	self._nationality_icon = self._object:bitmap(icon_params)

	self._nationality_icon:set_center_x(self._object:w() / 2)
	self._nationality_icon:set_center_y(self._object:h() / 2)
end

function HUDNameLabel:_create_special_interaction_icon()
	local gui_icon = tweak_data.gui:get_full_gui_data(HUDNameLabel.LOCKPICK_ICON)
	self._special_interaction_icon = self._object:bitmap({
		alpha = 0,
		name = "special_interaction_icon",
		halign = "center",
		valign = "center",
		texture = gui_icon.texture,
		texture_rect = gui_icon.texture_rect
	})

	self._special_interaction_icon:set_center(self._object:w() / 2, self._object:h() / 2)
end

function HUDNameLabel:_create_mounted_weapon_icon()
	local mounted_weapon_icon_params = {
		alpha = 0,
		name = "mounted_weapon_icon",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[HUDNameLabel.MOUNTED_WEAPON_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNameLabel.MOUNTED_WEAPON_ICON].texture_rect
	}
	self._mounted_weapon_icon = self._object:bitmap(mounted_weapon_icon_params)

	self._mounted_weapon_icon:set_center_x(self._object:w() / 2)
	self._mounted_weapon_icon:set_center_y(self._object:h() / 2)
end

function HUDNameLabel:_create_timer()
	local timer_panel_params = {
		alpha = 0,
		layer = 5,
		name = "timer_panel"
	}
	self._timer_panel = self._object:panel(timer_panel_params)
	local timer_background_params = {
		name = "timer_background",
		halign = "center",
		valign = "center",
		layer = 1,
		texture = tweak_data.gui.icons[HUDNameLabel.TIMER_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNameLabel.TIMER_BG_ICON].texture_rect
	}
	local timer_background = self._timer_panel:bitmap(timer_background_params)

	timer_background:set_center_x(self._timer_panel:w() / 2)
	timer_background:set_center_y(self._timer_panel:h() / 2)

	local timer_bar_params = {
		halign = "center",
		valign = "center",
		render_template = "VertexColorTexturedRadial",
		name = "timer_bar",
		layer = 2,
		texture = tweak_data.gui.icons[HUDNameLabel.TIMER_BAR_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDNameLabel.TIMER_BAR_ICON),
			0,
			-tweak_data.gui:icon_w(HUDNameLabel.TIMER_BAR_ICON),
			tweak_data.gui:icon_h(HUDNameLabel.TIMER_BAR_ICON)
		},
		w = tweak_data.gui:icon_w(HUDNameLabel.TIMER_BAR_ICON),
		h = tweak_data.gui:icon_h(HUDNameLabel.TIMER_BAR_ICON)
	}
	self._timer_bar = self._timer_panel:bitmap(timer_bar_params)

	self._timer_bar:set_center_x(self._timer_panel:w() / 2)
	self._timer_bar:set_center_y(self._timer_panel:h() / 2)

	local timer_text_params = {
		name = "timer_text",
		x = 0,
		y = 0,
		text = "37",
		vertical = "center",
		align = "center",
		layer = 3,
		w = self._timer_panel:w(),
		h = self._timer_panel:h(),
		font = tweak_data.gui.fonts[HUDNameLabel.TIMER_FONT],
		font_size = HUDNameLabel.TIMER_FONT_SIZE
	}
	self._timer_text = self._timer_panel:text(timer_text_params)
	local _, _, _, h = self._timer_text:text_rect()

	self._timer_text:set_h(h)
	self._timer_text:set_center_y(self._timer_panel:h() / 2)
end

function HUDNameLabel:_create_interaction_progress_bar()
	local interaction_panel_params = {
		name = "interaction_panel",
		alpha = 0,
		halign = "center",
		valign = "top",
		w = HUDNameLabel.INTERACTION_PANEL_W,
		h = HUDNameLabel.INTERACTION_PANEL_H
	}
	self._interaction_panel = self._object:panel(interaction_panel_params)

	self._interaction_panel:set_center_x(self._object:w() / 2)
	self._interaction_panel:set_center_y(self._object:h() / 2)

	local interaction_progress_background_params = {
		name = "interaction_progress_background",
		texture = tweak_data.gui.icons[HUDNameLabel.PROGRESS_BAR_ICON_BG].texture,
		texture_rect = tweak_data.gui.icons[HUDNameLabel.PROGRESS_BAR_ICON_BG].texture_rect,
		w = self._interaction_panel:w(),
		h = self._interaction_panel:h()
	}
	local interaction_progress_background = self._interaction_panel:bitmap(interaction_progress_background_params)

	interaction_progress_background:set_center_x(self._interaction_panel:w() / 2)
	interaction_progress_background:set_center_y(self._interaction_panel:h() / 2)

	local interaction_progress_fill_params = {
		position_z = 0,
		render_template = "VertexColorTexturedRadial",
		name = "interaction_progress_fill",
		texture = tweak_data.gui.icons[HUDNameLabel.PROGRESS_BAR_ICON_FILL].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDNameLabel.PROGRESS_BAR_ICON_FILL),
			0,
			-tweak_data.gui:icon_w(HUDNameLabel.PROGRESS_BAR_ICON_FILL),
			tweak_data.gui:icon_h(HUDNameLabel.PROGRESS_BAR_ICON_FILL)
		},
		w = self._interaction_panel:w() + 6,
		h = self._interaction_panel:h() + 6,
		layer = interaction_progress_background:layer() + 1,
		color = tweak_data.gui.colors.teammate_interaction_bar
	}
	self._interaction_progress_fill = self._interaction_panel:bitmap(interaction_progress_fill_params)

	self._interaction_progress_fill:set_center_x(self._interaction_panel:w() / 2)
	self._interaction_progress_fill:set_center_y(self._interaction_panel:h() / 2)
end

function HUDNameLabel:nationality()
	return self._nationality
end

function HUDNameLabel:id()
	return self._id
end

function HUDNameLabel:peer_id()
	return self._peer_id
end

function HUDNameLabel:movement()
	return self._movement
end

function HUDNameLabel:panel()
	return self._object
end

function HUDNameLabel:destroy()
	self._object:clear()
	self._object:parent():remove(self._object)

	self._nationality = nil
end

function HUDNameLabel:go_into_bleedout()
	self:_add_active_state("downed")
end

function HUDNameLabel:on_revived()
	self:_remove_active_state("downed")
	self:stop_timer()
end

function HUDNameLabel:show()
	self._object:set_visible(true)
end

function HUDNameLabel:hide()
	self._object:set_visible(false)
end

function HUDNameLabel:is_overlapping(name_label)
	local c1x = self._object:center_x()
	local c1y = self._object:center_y()
	local c2x = name_label:panel():center_x()
	local c2y = name_label:panel():center_y()
	local h = self._object:h()
	local w = self._object:w()
	local y_overlap = c1y - h / 2 < c2y + h / 2 or c2y - h / 2 < c1y + h / 2
	local x_overlap = c1x + h / 2 > c2x - h / 2 or c2x + h / 2 > c1x - h / 2

	return y_overlap and x_overlap
end

function HUDNameLabel:show_special_interaction_icon(interaction_type)
	local minigame_icon = tweak_data.interaction.minigame_icons[interaction_type]

	if minigame_icon then
		local gui_icon = tweak_data.gui:get_full_gui_data(minigame_icon)

		self._special_interaction_icon:set_image(gui_icon.texture)
		self._special_interaction_icon:set_texture_rect(unpack(gui_icon.texture_rect))
		self._special_interaction_icon:set_center(self._object:w() / 2, self._object:h() / 2)
		self:_add_active_state("special_interaction")
	end
end

function HUDNameLabel:hide_special_interaction_icon()
	self:_remove_active_state("special_interaction")
end

function HUDNameLabel:show_turret_icon()
	self:_add_active_state("mounted_weapon")
end

function HUDNameLabel:hide_turret_icon()
	self:_remove_active_state("mounted_weapon")
end

function HUDNameLabel:start_interact(duration)
	self:_add_active_state("interaction")
	self._interaction_progress_fill:stop()
	self._interaction_progress_fill:animate(callback(self, self, "_animate_interact"), duration)
end

function HUDNameLabel:cancel_interact()
	self:_remove_active_state("interaction")
	self._interaction_progress_fill:stop()
	self._interaction_progress_fill:animate(callback(self, self, "_animate_cancel_interact"))
end

function HUDNameLabel:complete_interact()
	self:_remove_active_state("interaction")
	self._interaction_progress_fill:stop()
	self._interaction_progress_fill:animate(callback(self, self, "_animate_complete_interact"))
end

function HUDNameLabel:_add_active_state(state_id)
	self._active_states[state_id] = true

	self:_check_state_change()
end

function HUDNameLabel:_remove_active_state(state_id)
	self._active_states[state_id] = nil

	self:_check_state_change()
end

function HUDNameLabel:_check_state_change()
	local new_state = nil

	for i = 1, #self._states do
		if self._active_states[self._states[i].id] then
			if self._states[i].id == self._displayed_state.id then
				return
			end

			new_state = self._states[i]

			break
		end
	end

	if new_state then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_state_change"), new_state)
	end
end

function HUDNameLabel:start_timer(time, current)
	self._timer_total = time
	self._timer_current = current or time
	self._is_timer_running = true

	self._timer_text:animate(callback(self, self, "_animate_timer_countdown"))
end

function HUDNameLabel:set_pause_timer(pause)
	self._is_timer_running = not pause
end

function HUDNameLabel:is_timer_running()
	return self._is_timer_running
end

function HUDNameLabel:stop_timer()
	self._timer_total = nil
	self._is_timer_running = false

	self._timer_text:stop()
end

function HUDNameLabel:_animate_timer_countdown()
	while self._timer_current > 0 and self._timer_total and self._timer_total > 0 do
		local dt = coroutine.yield()

		if self._is_timer_running and self._timer_total and self._timer_total > 0 then
			self._timer_current = self._timer_current - dt

			self._timer_bar:set_position_z(self._timer_current / self._timer_total)

			local time_text = math.round(self._timer_current) < 10 and "0" .. math.round(self._timer_current) or math.round(self._timer_current)

			self._timer_text:set_text(time_text)
		end
	end
end

function HUDNameLabel:_animate_state_change(status_panel, new_state)
	local old_state = self._displayed_state
	local fade_out_duration = 0.15
	local t = (1 - self._object:alpha()) * fade_out_duration
	self._displayed_state = new_state

	while t < fade_out_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._object:set_alpha(current_alpha)

		if new_state.hidden then
			for index, control_id in pairs(new_state.hidden) do
				local control = self._object:child(control_id)

				control:set_alpha(current_alpha)
			end
		end
	end

	for index, state in pairs(self._states) do
		self._object:child(state.control):set_alpha(0)
	end

	self._object:child(self._displayed_state.control):set_alpha(1)

	local fade_in_duration = 0.15
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._object:set_alpha(current_alpha)

		if old_state.hidden then
			for index, control_id in pairs(old_state.hidden) do
				local control = self._object:child(control_id)

				control:set_alpha(current_alpha)
			end
		end
	end

	self._object:set_alpha(1)
end

function HUDNameLabel:_animate_interact(interact_image, duration)
	local size_increase_duration = 0.18
	local t = 0

	self._interaction_progress_fill:set_position_z(0)
	self._interaction_progress_fill:set_rotation(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_progress = Easing.linear(t, 0, 1, duration)

		self._interaction_progress_fill:set_position_z(current_progress)
	end

	self._interaction_progress_fill:set_position_z(1)
end

function HUDNameLabel:_animate_cancel_interact()
	local size_decrease_duration = 0.18
	local duration = 0.2
	local t = (1 - self._interaction_progress_fill:position_z()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_progress = Easing.linear(t, 1, -1, duration)

		self._interaction_progress_fill:set_position_z(current_progress)
	end

	self._interaction_progress_fill:set_position_z(0)
end

function HUDNameLabel:_animate_complete_interact()
	local size_decrease_duration = 0.18
	local duration = 0.2
	local t = 0

	self._interaction_progress_fill:set_position_z(1)
	self._interaction_progress_fill:set_rotation(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_progress = Easing.linear(t, 1, -1, duration)

		self._interaction_progress_fill:set_position_z(current_progress)

		local current_rotation = Easing.linear(t, 360, -360, duration)

		self._interaction_progress_fill:set_rotation(current_rotation)
	end

	self._interaction_progress_fill:set_position_z(0)
	self._interaction_progress_fill:set_rotation(0)
end
