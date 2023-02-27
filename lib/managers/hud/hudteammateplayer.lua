HUDTeammatePlayer = HUDTeammatePlayer or class(HUDTeammateBase)
HUDTeammatePlayer.DEFAULT_X = 0
HUDTeammatePlayer.DEFAULT_W = 384
HUDTeammatePlayer.DEFAULT_H = 84
HUDTeammatePlayer.LEFT_PANEL_X = 0
HUDTeammatePlayer.LEFT_PANEL_Y = 0
HUDTeammatePlayer.LEFT_PANEL_W = 84
HUDTeammatePlayer.STAMINA_BG_ICON = "player_panel_stamina_bg"
HUDTeammatePlayer.STAMINA_BAR_ICON = "stamina_bar_fill"
HUDTeammatePlayer.STAMINA_COLORS = tweak_data.gui.colors.player_stamina_colors
HUDTeammatePlayer.WARCRY_BG_ICON = "player_panel_warcry_bg"
HUDTeammatePlayer.WARCRY_BAR_ICON = "warcry_bar_fill"
HUDTeammatePlayer.WARCRY_COLORS = tweak_data.gui.colors.player_warcry_colors
HUDTeammatePlayer.WARCRY_INACTIVE_COLOR = tweak_data.gui.colors.warcry_inactive
HUDTeammatePlayer.WARCRY_ACTIVE_COLOR = tweak_data.gui.colors.warcry_active
HUDTeammatePlayer.TIMER_BG_ICON = "player_panel_downed_bg"
HUDTeammatePlayer.TIMER_BAR_ICON = "teammate_circle_fill_large"
HUDTeammatePlayer.TIMER_FONT = "din_compressed_outlined_42"
HUDTeammatePlayer.TIMER_FONT_SIZE = 42
HUDTeammatePlayer.RIGHT_PANEL_X = 96
HUDTeammatePlayer.RIGHT_PANEL_Y = 0
HUDTeammatePlayer.PLAYER_NAME_H = 24
HUDTeammatePlayer.PLAYER_NAME_FONT = "din_compressed_outlined_22"
HUDTeammatePlayer.PLAYER_NAME_FONT_SIZE = 22
HUDTeammatePlayer.PLAYER_LEVEL_Y = 4
HUDTeammatePlayer.PLAYER_LEVEL_W = 24
HUDTeammatePlayer.PLAYER_LEVEL_H = 16
HUDTeammatePlayer.PLAYER_LEVEL_FONT = "din_compressed_outlined_22"
HUDTeammatePlayer.PLAYER_LEVEL_FONT_SIZE = 20
HUDTeammatePlayer.PLAYER_HEALTH_H = 10
HUDTeammatePlayer.PLAYER_HEALTH_BG_ICON = "backgrounds_health_bg"
HUDTeammatePlayer.PLAYER_HEALTH_COLORS = tweak_data.gui.colors.player_health_colors
HUDTeammatePlayer.PLAYER_HEALTH_HURT_COLOR = tweak_data.gui.colors.progress_dark_red
HUDTeammatePlayer.EQUIPMENT_H = 37
HUDTeammatePlayer.EQUIPMENT_PADDING = 6
HUDTeammatePlayer.HOST_ICON = "player_panel_host_indicator"
HUDTeammatePlayer.STATES = {
	{
		id = "downed",
		control = "timer_panel",
		hidden = {
			"stamina_panel",
			"warcry_panel"
		}
	},
	{
		id = "warcry",
		control = "warcry_icon"
	},
	{
		id = "normal",
		control = "nationality_icon"
	}
}

function HUDTeammatePlayer:init(i, teammates_panel)
	self._id = i
	self._max_stamina = 1
	self._equipment = {}
	self._states = HUDTeammatePlayer.STATES
	self._displayed_state = self._states[#self._states]
	self._active_states = {}

	self:_add_active_state(self._displayed_state.id)
	self:_create_panel(teammates_panel)
	self:_create_left_panel()
	self:_create_status_panel()
	self:_create_stamina_bar()
	self:_create_warcry_bar()
	self:_create_nationality_icon()
	self:_create_timer()
	self:_create_host_indicator()
	self:_create_right_panel()
	self:_create_player_name()
	self:_create_player_level()
	self:_create_player_health()
	self:_create_equipment_panel()
end

function HUDTeammatePlayer:_create_panel(teammates_panel)
	local panel_params = {
		halign = "left",
		valign = "bottom",
		x = HUDTeammatePlayer.DEFAULT_X,
		y = teammates_panel:h() - HUDTeammatePlayer.DEFAULT_H,
		w = HUDTeammatePlayer.DEFAULT_W,
		h = HUDTeammatePlayer.DEFAULT_H,
		layer = tweak_data.gui.PLAYER_PANELS_LAYER
	}
	self._object = teammates_panel:panel(panel_params)
end

function HUDTeammatePlayer:_create_status_panel()
	local status_panel_params = {
		name = "status_panel"
	}
	self._status_panel = self._left_panel:panel(status_panel_params)
end

function HUDTeammatePlayer:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		x = HUDTeammatePlayer.LEFT_PANEL_X,
		y = HUDTeammatePlayer.LEFT_PANEL_Y,
		w = HUDTeammatePlayer.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

function HUDTeammatePlayer:_create_stamina_bar()
	local stamina_panel_params = {
		name = "stamina_panel",
		w = self._left_panel:w(),
		h = self._left_panel:h()
	}
	local stamina_panel = self._left_panel:panel(stamina_panel_params)
	local stamina_background_params = {
		name = "stamina_background",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.STAMINA_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTeammatePlayer.STAMINA_BG_ICON].texture_rect
	}
	local stamina_background = stamina_panel:bitmap(stamina_background_params)

	stamina_background:set_center_x(stamina_panel:w() / 2)
	stamina_background:set_center_y(stamina_panel:h() / 2)

	local stamina_bar_params = {
		name = "stamina_bar",
		halign = "center",
		render_template = "VertexColorTexturedRadial",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.STAMINA_BAR_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDTeammatePlayer.STAMINA_BAR_ICON),
			0,
			-tweak_data.gui:icon_w(HUDTeammatePlayer.STAMINA_BAR_ICON),
			tweak_data.gui:icon_h(HUDTeammatePlayer.STAMINA_BAR_ICON)
		},
		w = tweak_data.gui:icon_w(HUDTeammatePlayer.STAMINA_BAR_ICON),
		h = tweak_data.gui:icon_h(HUDTeammatePlayer.STAMINA_BAR_ICON),
		layer = stamina_background:layer() + 1
	}
	self._stamina_bar = stamina_panel:bitmap(stamina_bar_params)

	self._stamina_bar:set_center_x(stamina_panel:w() / 2)
	self._stamina_bar:set_center_y(stamina_panel:h() / 2)
	self:set_stamina(self._max_stamina)
end

function HUDTeammatePlayer:_create_warcry_bar()
	local warcry_panel_params = {
		name = "warcry_panel",
		w = self._left_panel:w(),
		h = self._left_panel:h()
	}
	self._warcry_panel = self._left_panel:panel(warcry_panel_params)
	local warcry_background_params = {
		name = "warcry_background",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.WARCRY_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTeammatePlayer.WARCRY_BG_ICON].texture_rect
	}
	local warcry_background = self._warcry_panel:bitmap(warcry_background_params)

	warcry_background:set_center_x(self._warcry_panel:w() / 2)
	warcry_background:set_center_y(self._warcry_panel:h() / 2)

	local warcry_bar_params = {
		name = "warcry_bar",
		halign = "center",
		render_template = "VertexColorTexturedRadial",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.WARCRY_BAR_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDTeammatePlayer.WARCRY_BAR_ICON),
			0,
			-tweak_data.gui:icon_w(HUDTeammatePlayer.WARCRY_BAR_ICON),
			tweak_data.gui:icon_h(HUDTeammatePlayer.WARCRY_BAR_ICON)
		},
		w = tweak_data.gui:icon_w(HUDTeammatePlayer.WARCRY_BAR_ICON),
		h = tweak_data.gui:icon_h(HUDTeammatePlayer.WARCRY_BAR_ICON),
		color = HUDTeammatePlayer.WARCRY_INACTIVE_COLOR,
		layer = warcry_background:layer() + 1
	}
	self._warcry_bar = self._warcry_panel:bitmap(warcry_bar_params)

	self._warcry_bar:set_center_x(self._warcry_panel:w() / 2)
	self._warcry_bar:set_center_y(self._warcry_panel:h() / 2)
	self._warcry_bar:set_position_z(0)

	local active_warcry = managers.warcry:get_active_warcry_name()

	if active_warcry then
		self:set_active_warcry(active_warcry)
	end
end

function HUDTeammatePlayer:_create_nationality_icon()
	local nationality = managers.player:get_character_profile_nation()

	if not nationality or nationality == "" then
		nationality = "british"
	end

	local nationality_icon = "player_panel_nationality_" .. tostring(nationality)
	local nationality_icon_params = {
		name = "nationality_icon",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[nationality_icon].texture,
		texture_rect = tweak_data.gui.icons[nationality_icon].texture_rect
	}
	self._nationality_icon = self._status_panel:bitmap(nationality_icon_params)

	self._nationality_icon:set_center_x(self._status_panel:w() / 2)
	self._nationality_icon:set_center_y(self._status_panel:h() / 2)
end

function HUDTeammatePlayer:_create_timer()
	local timer_panel_params = {
		alpha = 0,
		name = "timer_panel",
		layer = 5
	}
	self._timer_panel = self._status_panel:panel(timer_panel_params)
	local timer_background_params = {
		name = "timer_background",
		halign = "center",
		layer = 1,
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.TIMER_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTeammatePlayer.TIMER_BG_ICON].texture_rect
	}
	local timer_background = self._timer_panel:bitmap(timer_background_params)

	timer_background:set_center_x(self._timer_panel:w() / 2)
	timer_background:set_center_y(self._timer_panel:h() / 2)

	local timer_bar_params = {
		name = "timer_bar",
		layer = 2,
		halign = "center",
		render_template = "VertexColorTexturedRadial",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.TIMER_BAR_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDTeammatePlayer.TIMER_BAR_ICON),
			0,
			-tweak_data.gui:icon_w(HUDTeammatePlayer.TIMER_BAR_ICON),
			tweak_data.gui:icon_h(HUDTeammatePlayer.TIMER_BAR_ICON)
		},
		w = tweak_data.gui:icon_w(HUDTeammatePlayer.TIMER_BAR_ICON),
		h = tweak_data.gui:icon_h(HUDTeammatePlayer.TIMER_BAR_ICON)
	}
	self._timer_bar = self._timer_panel:bitmap(timer_bar_params)

	self._timer_bar:set_center_x(self._timer_panel:w() / 2)
	self._timer_bar:set_center_y(self._timer_panel:h() / 2)

	local timer_text_params = {
		name = "timer_text",
		vertical = "center",
		align = "center",
		text = "37",
		y = 0,
		x = 0,
		layer = 3,
		w = self._timer_panel:w(),
		h = self._timer_panel:h(),
		font = tweak_data.gui.fonts[HUDTeammatePlayer.TIMER_FONT],
		font_size = HUDTeammatePlayer.TIMER_FONT_SIZE
	}
	self._timer_text = self._timer_panel:text(timer_text_params)
	local _, _, _, h = self._timer_text:text_rect()

	self._timer_text:set_h(h)
	self._timer_text:set_center_y(self._timer_panel:h() / 2 - 3)
end

function HUDTeammatePlayer:_create_host_indicator()
	local warcry_background = self._warcry_panel:child("warcry_background")
	local host_indicator_params = {
		name = "host_indicator",
		layer = 30,
		alpha = 0,
		texture = tweak_data.gui.icons[HUDTeammatePlayer.HOST_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTeammatePlayer.HOST_ICON].texture_rect
	}
	local host_indicator = self._left_panel:bitmap(host_indicator_params)

	host_indicator:set_right(self._warcry_panel:x() + warcry_background:x() + warcry_background:w() - 4)
	host_indicator:set_bottom(self._warcry_panel:y() + warcry_background:y() + warcry_background:h() - 4)
end

function HUDTeammatePlayer:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		x = HUDTeammatePlayer.RIGHT_PANEL_X,
		y = HUDTeammatePlayer.RIGHT_PANEL_Y,
		w = self._object:w() - HUDTeammatePlayer.RIGHT_PANEL_X,
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)
end

function HUDTeammatePlayer:_create_player_name()
	local player_name_params = {
		name = "player_name",
		vertical = "center",
		align = "left",
		text = "",
		y = 1,
		x = 0,
		w = self._right_panel:w() - HUDTeammatePlayer.PLAYER_LEVEL_W,
		h = HUDTeammatePlayer.PLAYER_NAME_H,
		font = tweak_data.gui.fonts[HUDTeammatePlayer.PLAYER_NAME_FONT],
		font_size = HUDTeammatePlayer.PLAYER_NAME_FONT_SIZE
	}
	self._player_name = self._right_panel:text(player_name_params)
end

function HUDTeammatePlayer:_create_player_level()
	local player_level_params = {
		vertical = "center",
		name = "player_level",
		align = "right",
		text = "",
		x = self._right_panel:w() - HUDTeammatePlayer.PLAYER_LEVEL_W,
		y = HUDTeammatePlayer.PLAYER_LEVEL_Y,
		w = HUDTeammatePlayer.PLAYER_LEVEL_W,
		h = HUDTeammatePlayer.PLAYER_LEVEL_H,
		font = tweak_data.gui.fonts[HUDTeammatePlayer.PLAYER_LEVEL_FONT],
		font_size = HUDTeammatePlayer.PLAYER_LEVEL_FONT_SIZE
	}
	self._player_level = self._right_panel:text(player_level_params)
	local current_level = managers.experience:current_level()

	if current_level then
		self._player_level:set_text(current_level)
	end
end

function HUDTeammatePlayer:_create_player_health()
	local health_panel_params = {
		name = "health_panel",
		x = 0,
		y = self._right_panel:h() / 2 - HUDTeammatePlayer.PLAYER_HEALTH_H,
		w = self._right_panel:w(),
		h = HUDTeammatePlayer.PLAYER_HEALTH_H
	}
	local health_panel = self._right_panel:panel(health_panel_params)
	local health_background_params = {
		name = "health_background",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[HUDTeammatePlayer.PLAYER_HEALTH_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTeammatePlayer.PLAYER_HEALTH_BG_ICON].texture_rect
	}
	local health_background = health_panel:bitmap(health_background_params)

	health_background:set_center_x(health_panel:w() / 2)
	health_background:set_center_y(health_panel:h() / 2)

	local health_bar_hurt_params = {
		name = "health_bar_hurt",
		w = health_background:w() - 2,
		h = health_background:h() - 2,
		color = HUDTeammatePlayer.PLAYER_HEALTH_HURT_COLOR,
		layer = health_background:layer() + 1
	}
	self._health_bar_hurt = health_panel:rect(health_bar_hurt_params)

	self._health_bar_hurt:set_center_x(health_panel:w() / 2)
	self._health_bar_hurt:set_center_y(health_panel:h() / 2)

	local health_bar_params = {
		name = "health_bar",
		w = health_background:w() - 2,
		h = health_background:h() - 2,
		color = tweak_data.gui.colors.progress_75,
		layer = health_background:layer() + 1
	}
	self._health_bar = health_panel:rect(health_bar_params)

	self._health_bar:set_center_x(health_panel:w() / 2)
	self._health_bar:set_center_y(health_panel:h() / 2)

	self._full_health_bar_w = self._health_bar:w()
end

function HUDTeammatePlayer:_create_equipment_panel()
	local equipment_panel_params = {
		name = "equipment_panel",
		x = 0,
		y = self._right_panel:h() / 2,
		w = self._right_panel:w(),
		h = HUDTeammatePlayer.EQUIPMENT_H
	}
	self._equipment_panel = self._right_panel:panel(equipment_panel_params)
end

function HUDTeammatePlayer:show()
	HUDTeammatePlayer.super.show(self)
	self:refresh()
end

function HUDTeammatePlayer:refresh()
	local nationality = managers.criminals:local_character_name()

	if nationality then
		self:set_nationality(nationality)
	end

	local current_level = managers.experience:current_level()

	self:set_level(current_level)
	self._player_level:set_text(current_level)
end

function HUDTeammatePlayer:reset_state()
	self:clear_special_equipment()
	self._nationality_icon:set_alpha(1)
	self._left_panel:child("stamina_panel"):set_alpha(1)
	self._warcry_panel:set_alpha(1)
	self._status_panel:child(self._displayed_state.control):set_alpha(0)
	self:set_warcry_ready(false)

	self._displayed_state = self._states[#self._states]
	self._active_states = {}

	self:_add_active_state(self._displayed_state.id)
	self._status_panel:child(self._displayed_state.control):set_alpha(1)
end

function HUDTeammatePlayer:set_character_data(data)
	if data.nationality then
		local nationality_icon = "player_panel_nationality_" .. tostring(data.nationality)

		self._nationality_icon:set_image(tweak_data.gui.icons[nationality_icon].texture)
		self._nationality_icon:set_texture_rect(unpack(tweak_data.gui.icons[nationality_icon].texture_rect))
	end

	if data.character_level then
		self._player_level:set_text(data.character_level)
	end
end

function HUDTeammatePlayer:set_health(data)
	local health_percentage = math.clamp(data.current / data.total, 0, 1)

	self._health_bar:set_w(health_percentage * self._full_health_bar_w)
	self._health_bar:set_color(self:_get_color_for_percentage(HUDTeammatePlayer.PLAYER_HEALTH_COLORS, health_percentage))
	self._health_bar_hurt:stop()
	self._health_bar_hurt:animate(callback(self, self, "_animate_health_change"))
end

function HUDTeammatePlayer:set_stamina(value)
	local stamina_percentage = math.clamp(value / self._max_stamina, 0, 1)

	self._stamina_bar:set_position_z(stamina_percentage)

	local player_unit = managers.player:player_unit()

	if player_unit and player_unit:movement() then
		if player_unit:movement():is_above_stamina_threshold() then
			self._stamina_bar:set_color(self:_get_color_for_percentage(HUDTeammatePlayer.STAMINA_COLORS, 1))
		else
			self._stamina_bar:set_color(self:_get_color_for_percentage(HUDTeammatePlayer.STAMINA_COLORS, 0.001))
		end
	else
		self._stamina_bar:set_color(self:_get_color_for_percentage(HUDTeammatePlayer.STAMINA_COLORS, stamina_percentage))
	end
end

function HUDTeammatePlayer:set_max_stamina(value)
	self._max_stamina = value
end

function HUDTeammatePlayer:set_active_warcry(warcry)
	if self._warcry_icon then
		self._status_panel:remove(self._warcry_icon)
	end

	local warcry_icon_name = tweak_data.warcry[warcry].hud_icon
	local warcry_icon_params = {
		name = "warcry_icon",
		halign = "center",
		alpha = 0,
		valign = "center",
		texture = tweak_data.gui.icons[warcry_icon_name].texture,
		texture_rect = tweak_data.gui.icons[warcry_icon_name].texture_rect,
		color = HUDTeammatePlayer.WARCRY_ACTIVE_COLOR
	}
	self._warcry_icon = self._status_panel:bitmap(warcry_icon_params)

	self._warcry_icon:set_center_x(self._status_panel:w() / 2)
	self._warcry_icon:set_center_y(self._status_panel:h() / 2)
end

function HUDTeammatePlayer:set_warcry_meter_fill(data)
	local warcry_percentage = data.current / data.total
	self._true_warcry_percentage = warcry_percentage

	if self._true_warcry_percentage < 1 then
		self._warcry_panel:stop()
		self._warcry_panel:animate(callback(self, self, "_animate_warcry_fill"))
	else
		self._warcry_bar:set_position_z(warcry_percentage)
	end

	self._true_warcry_percentage_prev = warcry_percentage
end

function HUDTeammatePlayer:activate_warcry(duration)
end

function HUDTeammatePlayer:deactivate_warcry()
	self._warcry_panel:stop()
	self._warcry_panel:animate(callback(self, self, "_animate_warcry_not_ready"))
	self:_remove_active_state("warcry")
end

function HUDTeammatePlayer:set_warcry_ready(value)
	self._warcry_panel:stop()

	if value == true then
		self:_add_active_state("warcry")
		self._warcry_panel:animate(callback(self, self, "_animate_warcry_ready"))
	else
		self:_remove_active_state("warcry")
		self._warcry_panel:animate(callback(self, self, "_animate_warcry_not_ready"))
	end
end

function HUDTeammatePlayer:set_name(name)
	self._player_name:set_text(utf8.to_upper(name))
end

function HUDTeammatePlayer:set_nationality(nationality)
	local nationality_icon = "player_panel_nationality_" .. tostring(nationality)

	self._nationality_icon:set_image(tweak_data.gui.icons[nationality_icon].texture)
	self._nationality_icon:set_texture_rect(unpack(tweak_data.gui.icons[nationality_icon].texture_rect))
end

function HUDTeammatePlayer:set_level(level)
	self._player_level:set_text(level)
end

function HUDTeammatePlayer:set_cheater(state)
end

function HUDTeammatePlayer:on_revived()
	self:_remove_active_state("warcry")
	HUDTeammatePlayer.super.on_revived(self)
end

function HUDTeammatePlayer:set_carry_info(carry_id)
end

function HUDTeammatePlayer:remove_carry_info()
end

function HUDTeammatePlayer:show_turret_icon()
end

function HUDTeammatePlayer:hide_turret_icon()
end

function HUDTeammatePlayer:show_host_indicator()
	local host_indicator = self._left_panel:child("host_indicator")

	host_indicator:stop()
	host_indicator:animate(callback(self, self, "_animate_show_host_indicator"))
end

function HUDTeammatePlayer:hide_host_indicator()
	local host_indicator = self._left_panel:child("host_indicator")

	host_indicator:stop()
	host_indicator:animate(callback(self, self, "_animate_hide_host_indicator"))
end

function HUDTeammatePlayer:add_special_equipment(data)
	local existing_equipment = nil

	for i = 1, #self._equipment do
		if self._equipment[i]:id() == data.id then
			existing_equipment = self._equipment[i]

			break
		end
	end

	if existing_equipment then
		local new_amount = data and data.amount or 1

		existing_equipment:set_amount(existing_equipment:amount() + new_amount)
	else
		local equipment = HUDEquipment:new(self._equipment_panel, data.icon, data.id, data.amount)

		table.insert(self._equipment, equipment)
		self:_layout_special_equipment()
	end
end

function HUDTeammatePlayer:remove_special_equipment(id)
	for i = #self._equipment, 1, -1 do
		if self._equipment[i]:id() == id then
			self._equipment[i]:destroy()
			table.remove(self._equipment, i)

			break
		end
	end

	self:_layout_special_equipment()
end

function HUDTeammatePlayer:set_special_equipment_amount(equipment_id, amount)
	for i = 1, #self._equipment do
		if self._equipment[i]:id() == equipment_id then
			self._equipment[i]:set_amount(amount)
		end
	end
end

function HUDTeammatePlayer:clear_special_equipment()
	self._equipment_panel:clear()

	self._equipment = {}
end

function HUDTeammatePlayer:_layout_special_equipment()
	local x = 0

	for i = 1, #self._equipment do
		self._equipment[i]:set_x(x)

		x = x + self._equipment[i]:w() + HUDTeammatePlayer.EQUIPMENT_PADDING
	end
end

function HUDTeammatePlayer:set_condition(icon_data, text)
end

function HUDTeammatePlayer:_get_color_for_percentage(color_table, percentage)
	for i = #color_table, 1, -1 do
		if color_table[i].start_percentage < percentage then
			return color_table[i].color
		end
	end

	return color_table[1].color
end

function HUDTeammatePlayer:_animate_health_change()
	local from = self._health_bar_hurt:w()
	local to = self._health_bar:w()
	local duration = (from - to) / 100

	if duration > 0 then
		local t = 0

		while duration > t do
			local dt = coroutine.yield()
			t = t + dt

			self._health_bar_hurt:set_w(math.lerp(from, to, t / duration))
		end

		self._health_bar_hurt:set_w(to)
	else
		self._health_bar_hurt:set_w(to)
	end
end

function HUDTeammatePlayer:_animate_warcry_fill()
	local from = self._true_warcry_percentage_prev or 0
	local to = self._true_warcry_percentage or 0
	local duration = (to - from) * 2
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt

		self._warcry_bar:set_position_z(math.lerp(from, to, t / duration))
	end

	self._warcry_bar:set_position_z(to)
end

function HUDTeammatePlayer:_animate_warcry_ready()
	local duration = 0.3
	local t = (self._warcry_bar:color().r - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r) / (HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.r - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.r - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r, duration)
		local current_g = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.g, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.g - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.g, duration)
		local current_b = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.b, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.b - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.b, duration)

		self._warcry_bar:set_color(Color(current_r, current_g, current_b))
	end

	self._warcry_bar:set_color(HUDTeammatePlayer.WARCRY_ACTIVE_COLOR)
end

function HUDTeammatePlayer:_animate_warcry_not_ready()
	local duration = 0.3
	local t = (1 - (self._warcry_bar:color().r - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r) / (HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.r - HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r)) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.r, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.r - HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.r, duration)
		local current_g = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.g, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.g - HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.g, duration)
		local current_b = Easing.quartic_out(t, HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.b, HUDTeammatePlayer.WARCRY_INACTIVE_COLOR.b - HUDTeammatePlayer.WARCRY_ACTIVE_COLOR.b, duration)

		self._warcry_bar:set_color(Color(current_r, current_g, current_b))
	end

	self._warcry_bar:set_color(HUDTeammatePlayer.WARCRY_INACTIVE_COLOR)
end

function HUDTeammatePlayer:_animate_show_host_indicator(host_indicator)
	local duration = 0.15
	local t = host_indicator:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		host_indicator:set_alpha(current_alpha)
	end

	host_indicator:set_alpha(1)
end

function HUDTeammatePlayer:_animate_hide_host_indicator(host_indicator)
	local duration = 0.15
	local t = (1 - host_indicator:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, duration)

		host_indicator:set_alpha(current_alpha)
	end

	host_indicator:set_alpha(0)
end
