RaidGUIControlClassDescription = RaidGUIControlClassDescription or class(RaidGUIControl)
RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_Y = 82
RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_H = 160
RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y = 286
RaidGUIControlClassDescription.WARCRY_DEFAULT_Y = 386
RaidGUIControlClassDescription.WARCRY_DEFAULT_H = 64
RaidGUIControlClassDescription.PERSONAL_BUFF_DEFAULT_Y = 470

function RaidGUIControlClassDescription:init(parent, params, item_data)
	RaidGUIControlClassDescription.super.init(self, parent, params, item_data)

	self._data = item_data

	self:_layout()
end

function RaidGUIControlClassDescription:_layout()
	self._object = self._panel:panel({
		name = "character_info_panel",
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})
	local padding = 16
	local padded_width = self._object:w() - padding * 2
	local object_bg_params = {
		name = "object_bg",
		y = 0,
		layer = -1,
		x = -4,
		w = self._object:w() + 8,
		h = self._object:h(),
		texture = tweak_data.gui.icons.paper_mission_book.texture,
		texture_rect = tweak_data.gui.icons.paper_mission_book.texture_rect
	}
	self._object_bg = self._object:image(object_bg_params)
	local object_bg_params2 = {
		name = "object_bg",
		layer = -2,
		y = 0,
		x = -4,
		w = self._object:w() + 8,
		h = self._object:h(),
		texture = tweak_data.gui.icons.paper_mission_book.texture,
		texture_rect = tweak_data.gui.icons.paper_mission_book.texture_rect,
		rotation = 2 + math.random(4),
		color = Color(0.7, 0.7, 0.7)
	}
	self._object_bg2 = self._object:image(object_bg_params2)
	local class_icon_data = tweak_data.gui.icons.ico_class_recon or tweak_data.gui.icons.ico_flag_empty
	local text_rect = class_icon_data.texture_rect
	self._class_icon = self._object:image({
		name = "class_icon",
		align = "center",
		y = 24,
		x = padding,
		w = text_rect[3],
		h = text_rect[4],
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black,
		texture = class_icon_data.texture,
		texture_rect = text_rect
	})
	self._class_label = self._object:label({
		name = "class_label",
		h = 42,
		w = 224,
		align = "center",
		text = "CLASSNAME",
		x = 0,
		y = self._class_icon:bottom() - 8,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.menu_list,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})

	self._class_label:set_w(self._object:w() - self._class_label:x())

	self._description_label = self._object:label({
		name = "description_label",
		vertical = "top",
		h = 128,
		wrap = true,
		align = "center",
		x = padding,
		w = padded_width,
		y = self._class_label:bottom() + 32,
		text = self:translate("skill_class_recon_desc", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	local y_stats = RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y
	local y_stats_label = y_stats + 64
	local x_stats_step = self._object:w() / 4
	self._health_amount_label = self._object:label({
		name = "health_amount_label",
		vertical = "center",
		h = 64,
		w = 100,
		align = "center",
		text = "",
		x = 0,
		y = y_stats,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_52,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._health_label = self._object:label({
		name = "health_label",
		vertical = "center",
		h = 32,
		w = 100,
		align = "center",
		text = "",
		x = 0,
		y = y_stats_label,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._speed_amount_label = self._object:label({
		name = "speed_amount_label",
		vertical = "center",
		h = 64,
		w = 100,
		align = "center",
		text = "",
		x = 160,
		y = y_stats,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_52,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._speed_label = self._object:label({
		name = "speed_label",
		vertical = "center",
		h = 32,
		w = 100,
		align = "center",
		text = "",
		x = 160,
		y = y_stats_label,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._stamina_amount_label = self._object:label({
		name = "stamina_amount_label",
		vertical = "center",
		h = 64,
		w = 100,
		align = "center",
		text = "",
		x = 320,
		y = y_stats,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_52,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._stamina_label = self._object:label({
		name = "stamina_label",
		vertical = "center",
		h = 32,
		w = 100,
		align = "center",
		text = "",
		x = 320,
		y = y_stats_label,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})

	self._health_amount_label:set_center_x(x_stats_step)
	self._health_label:set_center_x(x_stats_step)
	self._speed_label:set_center_x(x_stats_step * 2)
	self._speed_amount_label:set_center_x(x_stats_step * 2)
	self._stamina_label:set_center_x(x_stats_step * 3)
	self._stamina_amount_label:set_center_x(x_stats_step * 3)

	local y_warcry = RaidGUIControlClassDescription.WARCRY_DEFAULT_Y
	self._warcry_icon = self._object:image({
		name = "warcry_icon",
		x = 0,
		y = y_warcry,
		texture = tweak_data.gui.icons.warcry_sharpshooter.texture,
		texture_rect = tweak_data.gui.icons.warcry_sharpshooter.texture_rect,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_dark_red
	})

	self._warcry_icon:set_center_x(self._object:w() / 2)

	local _, c_y = self._warcry_icon:center()
	self._warcry_name_label = self._object:label({
		name = "warcry_name_label",
		h = 32,
		w = 242,
		align = "left",
		text = "WARCRYNAME",
		y = 0,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})

	self._warcry_name_label:set_center_y(c_y + 4)

	self._warcries_label = self._object:label({
		name = "warcries_label",
		h = 32,
		w = 96,
		align = "right",
		y = 0,
		x = 0,
		text = self:translate("select_character_warcries_label", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})

	self._warcries_label:set_center_y(c_y + 4)

	local _, _, w, _ = self._warcries_label:text_rect()

	self._warcries_label:set_w(w)
	self._warcries_label:set_right(self._warcry_icon:left() - 4)

	local _, _, w, _ = self._warcry_name_label:text_rect()

	self._warcry_name_label:set_w(w)
	self._warcry_name_label:set_left(self._warcry_icon:right() + 4)

	self._warcry_description_short = self._object:label({
		name = "warcry_description_short",
		h = 24,
		align = "center",
		text = "",
		x = padding,
		w = padded_width,
		y = self._warcry_icon:bottom() + 32,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._warcry_description_label = self._object:label({
		name = "warcry_description_label",
		vertical = "top",
		h = 64,
		wrap = true,
		align = "center",
		text = "",
		x = padding,
		w = padded_width,
		y = self._warcry_description_short:bottom() + 8,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._warcry_team_buff_description_short = self._object:label({
		name = "warcry_description_team_short_label",
		h = 24,
		align = "center",
		text = "",
		x = padding,
		w = padded_width,
		y = self._warcry_description_label:bottom() + 24,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._warcry_team_buff_description = self._object:label({
		name = "warcry_description_team_label",
		vertical = "top",
		h = 120,
		wrap = true,
		align = "center",
		text = "",
		x = padding,
		w = padded_width,
		y = self._warcry_team_buff_description_short:bottom() + 8,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
end

function RaidGUIControlClassDescription:set_data(data)
	local class_icon_data = tweak_data.gui.icons["ico_class_" .. data.class_name] or tweak_data.gui.icons.ico_flag_empty

	self._class_icon:set_image(class_icon_data.texture)
	self._class_icon:set_texture_rect(class_icon_data.texture_rect)
	self._class_icon:set_visible(true)
	self._class_icon:set_center_x(self._object:w() / 2)
	self._class_label:set_text(self:translate(tweak_data.skilltree.classes[data.class_name].name_id, true))
	self._class_label:set_center_x(self._object:w() / 2)

	local class_description = self:translate(tweak_data.skilltree.classes[data.class_name].desc_id, false) or ""

	self._description_label:set_text(class_description)

	local _, _, _, h = self._description_label:text_rect()

	self._description_label:set_h(h)

	local description_extra_h = 0

	if RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_H < h then
		description_extra_h = h - RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_H
	end

	local health_amount = data.class_stats and data.class_stats.health.base or 0

	self._health_amount_label:set_text(string.format("%.0f", health_amount))
	self._health_label:set_text(self:translate("select_character_health_label", true))
	self._health_amount_label:set_y(RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y + description_extra_h)
	self._health_label:set_y(self._health_amount_label:bottom() - 12)

	local speed_amount = data.class_stats and data.class_stats.speed.base or 0

	self._speed_amount_label:set_text(string.format("%.0f", speed_amount))

	local _, _, w, _ = self._speed_amount_label:text_rect()

	self._speed_label:set_text(self:translate("select_character_speed_label", true))

	local _, _, w, _ = self._speed_label:text_rect()

	self._speed_amount_label:set_y(RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y + description_extra_h)
	self._speed_label:set_y(self._speed_amount_label:bottom() - 12)

	local stamina_amount = data.class_stats and data.class_stats.stamina.base or 0

	self._stamina_amount_label:set_text(string.format("%.0f", stamina_amount))

	local _, _, w, _ = self._stamina_amount_label:text_rect()

	self._stamina_label:set_text(self:translate("select_character_stamina_label", true))

	if self._stamina_amount_label:w() < self._stamina_label:w() then
		self._stamina_amount_label:set_center_x(self._stamina_label:center_x())
	else
		self._stamina_label:set_center_x(self._stamina_amount_label:center_x())
	end

	self._stamina_amount_label:set_y(RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y + description_extra_h)
	self._stamina_label:set_y(self._stamina_amount_label:bottom() - 12)

	local warcry_name_id = tweak_data.skilltree.class_warcry_data[data.class_name]
	local warcry_name = self:translate(tweak_data.warcry[warcry_name_id].name_id, true)
	local warcry_desc = self:translate(tweak_data.warcry[warcry_name_id].desc_self_id, false)
	local warcry_menu_icon_name = tweak_data.warcry[warcry_name_id].menu_icon
	local warcry_icon_data = tweak_data.gui.icons[warcry_menu_icon_name]

	self._warcry_description_label:set_text(warcry_desc)

	local _, _, _, h = self._warcry_description_label:text_rect()

	self._warcry_description_label:set_h(h)
	self._warcry_icon:set_image(warcry_icon_data.texture)
	self._warcry_icon:set_texture_rect(warcry_icon_data.texture_rect)
	self._warcry_icon:set_center_y(RaidGUIControlClassDescription.WARCRY_DEFAULT_Y + RaidGUIControlClassDescription.WARCRY_DEFAULT_H / 2 + description_extra_h)
	self._warcry_name_label:set_text(warcry_name)

	local _, _, w, _ = self._warcry_name_label:text_rect()

	self._warcry_name_label:set_w(w)
	self._warcry_description_short:set_text(self:translate(tweak_data.warcry[warcry_name_id].desc_short_id, true))
	self._warcry_team_buff_description_short:set_text(self:translate(tweak_data.warcry[warcry_name_id].desc_team_short_id, true))
	self._warcry_team_buff_description:set_text(self:translate(tweak_data.warcry[warcry_name_id].desc_team_id, false))

	local team_buff_y = math.max(RaidGUIControlClassDescription.PERSONAL_BUFF_DEFAULT_Y, self._warcry_description_label:bottom() + 32)

	self._warcry_team_buff_description_short:set_y(team_buff_y)
	self._warcry_team_buff_description:set_y(self._warcry_team_buff_description_short:bottom() + 24)
	self._warcry_description_short:set_y(RaidGUIControlClassDescription.PERSONAL_BUFF_DEFAULT_Y + description_extra_h)
	self._warcry_description_label:set_y(self._warcry_description_short:bottom() + 8)
	self._warcry_team_buff_description_short:set_y(self._warcry_description_label:bottom() + 24)
	self._warcry_team_buff_description:set_y(self._warcry_team_buff_description_short:bottom() + 8)
end
