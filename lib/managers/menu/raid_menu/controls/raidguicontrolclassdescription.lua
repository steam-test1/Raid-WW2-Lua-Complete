RaidGUIControlClassDescription = RaidGUIControlClassDescription or class(RaidGUIControl)
RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_Y = 82
RaidGUIControlClassDescription.CLASS_DESCRIPTION_DEFAULT_H = 160
RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y = 200
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
		vertical = "center",
		h = 256,
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
	local y_stats = self._object:h() - RaidGUIControlClassDescription.CLASS_STATS_DEFAULT_Y
	local y_stats_label = y_stats + 64
	local x_stats_step = self._object:w() / 5
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
		h = 64,
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
		h = 64,
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
		h = 64,
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
	self._carry_weight_label = self._object:label({
		w = 100,
		name = "carry_weight_label",
		h = 64,
		vertical = "center",
		align = "center",
		text = "",
		x = 320,
		y = y_stats,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_52,
		color = tweak_data.gui.colors.raid_black
	})
	self._carry_label = self._object:label({
		w = 100,
		name = "carry_label",
		h = 64,
		vertical = "center",
		align = "center",
		text = "",
		x = 320,
		y = y_stats_label,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_black
	})

	self._health_amount_label:set_center_x(x_stats_step)
	self._health_label:set_center_x(x_stats_step)
	self._speed_label:set_center_x(x_stats_step * 2)
	self._speed_amount_label:set_center_x(x_stats_step * 2)
	self._stamina_label:set_center_x(x_stats_step * 3)
	self._stamina_amount_label:set_center_x(x_stats_step * 3)
	self._carry_weight_label:set_center_x(x_stats_step * 4)
	self._carry_label:set_center_x(x_stats_step * 4)
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

	local health_amount = data.class_stats and data.class_stats.health or 0

	self._health_amount_label:set_text(string.format("%.0f", health_amount))
	self._health_label:set_text(self:translate("character_stats_health_label", true))

	local speed_amount = data.class_stats and data.class_stats.speed_walk or 0

	self._speed_amount_label:set_text(string.format("%.0f", speed_amount))
	self._speed_label:set_text(self:translate("character_stats_speed_walk_label", true))

	local stamina_amount = data.class_stats and data.class_stats.stamina or 0

	self._stamina_amount_label:set_text(string.format("%.0f", stamina_amount))
	self._stamina_label:set_text(self:translate("character_stats_stamina_label", true))

	local carry_limit = data.class_stats and data.class_stats.carry_limit or 0

	self._carry_weight_label:set_text(carry_limit)
	self._carry_label:set_text(self:translate("character_stats_carry_limit_label", true))

	if not data.class_name or not tweak_data.skilltree.class_warcry_data[data.class_name] then
		Application:error("[RaidGUIControlClassDescription:set_data] No classname data!!")

		return
	end
end
