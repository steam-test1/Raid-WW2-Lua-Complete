RaidGUIControlCharacterDescription = RaidGUIControlCharacterDescription or class(RaidGUIControl)
RaidGUIControlCharacterDescription.MODE_SELECTION = "mode_selection"
RaidGUIControlCharacterDescription.MODE_CUSTOMIZATION = "mode_customization"

-- Lines 6-13
function RaidGUIControlCharacterDescription:init(parent, params, item_data)
	RaidGUIControlCharacterDescription.super.init(self, parent, params, item_data)

	self._data = item_data
	self._mode = self._params.mode or RaidGUIControlCharacterDescription.MODE_SELECTION

	self:_layout()
end

-- Lines 15-76
function RaidGUIControlCharacterDescription:_layout()
	self._object = self._panel:panel({
		name = "character_info_panel",
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})
	local text_rect = tweak_data.gui.icons.ico_class_recon.texture_rect
	self._class_icon = self._object:image({
		name = "class_icon",
		y = 32,
		visible = false,
		x = 32,
		w = text_rect[3],
		h = text_rect[4],
		texture = tweak_data.gui.icons.ico_class_recon.texture,
		texture_rect = tweak_data.gui.icons.ico_class_recon.texture_rect
	})
	self._class_label = self._object:label({
		name = "class_label",
		vertical = "center",
		h = 32,
		w = 134,
		align = "center",
		text = "",
		y = 96,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	})
	self._nation_flag_icon = self._object:image({
		name = "nation_flag_icon",
		h = 64,
		y = 32,
		w = 96,
		visible = false,
		x = 144,
		texture = tweak_data.gui.icons.ico_flag_empty.texture,
		texture_rect = tweak_data.gui.icons.ico_flag_empty.texture_rect
	})
	self._nation_flag_label = self._object:label({
		name = "nation_flag_label",
		vertical = "center",
		h = 32,
		w = 104,
		align = "center",
		text = "",
		y = 96,
		x = 144,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	})
	self._level_amount_level = self._object:label({
		name = "level_amount_level",
		vertical = "center",
		h = 64,
		w = 64,
		align = "center",
		text = "",
		y = 32,
		x = 280,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_52,
		color = tweak_data.gui.colors.raid_white
	})
	self._level_label = self._object:label({
		name = "level_label",
		vertical = "center",
		h = 32,
		w = 72,
		align = "center",
		text = "",
		y = 96,
		x = 280,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	})

	if self._mode == RaidGUIControlCharacterDescription.MODE_SELECTION then
		self._description_label = self._object:label({
			name = "description_label",
			vertical = "top",
			h = 224,
			wrap = true,
			w = 354,
			align = "left",
			y = 160,
			x = 0,
			text = self:translate("skill_class_recon_desc", false),
			font = tweak_data.gui.fonts.lato,
			font_size = tweak_data.gui.font_sizes.size_20,
			color = tweak_data.gui.colors.raid_grey
		})
		self._health_amount_label = self._object:label({
			name = "health_amount_label",
			vertical = "center",
			h = 64,
			w = 64,
			align = "center",
			text = "",
			y = 398,
			x = 8,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_52,
			color = tweak_data.gui.colors.raid_white
		})
		self._health_label = self._object:label({
			name = "health_label",
			vertical = "center",
			h = 32,
			w = 64,
			align = "center",
			text = "",
			y = 462,
			x = 8,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_24,
			color = tweak_data.gui.colors.raid_grey
		})
		self._speed_amount_label = self._object:label({
			name = "speed_amount_label",
			vertical = "center",
			h = 64,
			w = 96,
			align = "center",
			text = "",
			y = 398,
			x = 128,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_52,
			color = tweak_data.gui.colors.raid_white
		})
		self._speed_label = self._object:label({
			name = "speed_label",
			vertical = "center",
			h = 32,
			w = 96,
			align = "center",
			text = "",
			y = 462,
			x = 128,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_24,
			color = tweak_data.gui.colors.raid_grey
		})
		self._stamina_amount_label = self._object:label({
			name = "stamina_amount_label",
			vertical = "center",
			h = 64,
			w = 96,
			align = "center",
			text = "",
			y = 398,
			x = 254,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_52,
			color = tweak_data.gui.colors.raid_white
		})
		self._stamina_label = self._object:label({
			name = "stamina_label",
			vertical = "center",
			h = 32,
			w = 68,
			align = "center",
			text = "",
			y = 462,
			x = 270,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_24,
			color = tweak_data.gui.colors.raid_grey
		})
		self._warcries_label = self._object:label({
			name = "warcries_label",
			vertical = "center",
			h = 32,
			w = 96,
			align = "left",
			text = "",
			y = 528,
			x = 0,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.small,
			color = Color("b8b8b8")
		})
		self._warcry_icon = self._object:image({
			name = "warcry_icon",
			h = 64,
			y = 576,
			w = 64,
			x = 0,
			texture = tweak_data.gui.icons.ico_flag_empty.texture,
			texture_rect = tweak_data.gui.icons.ico_flag_empty.texture_rect
		})
		self._warcry_name_label = self._object:label({
			name = "warcry_name_label",
			vertical = "center",
			h = 32,
			w = 242,
			align = "left",
			text = "",
			y = 528,
			x = 79,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.small,
			color = Color("d0d0d0")
		})
		self._warcry_description_label = self._object:label({
			name = "warcry_description_label",
			vertical = "top",
			wrap = true,
			align = "left",
			text = "",
			y = 570,
			x = 79,
			w = self._object:w() - 79,
			h = self._object:h() - 570,
			font = tweak_data.gui.fonts.lato,
			font_size = tweak_data.gui.font_sizes.size_18,
			color = Color("737373")
		})
	end
end

-- Lines 78-147
function RaidGUIControlCharacterDescription:set_data(data)
	local class_icon_data = tweak_data.gui.icons["ico_class_" .. data.class_name] or tweak_data.gui.icons.ico_flag_empty

	self._class_icon:set_image(class_icon_data.texture)
	self._class_icon:set_texture_rect(class_icon_data.texture_rect)
	self._class_icon:set_visible(true)
	self._class_label:set_text(self:translate(tweak_data.skilltree.classes[data.class_name].name_id, true))

	local nation_flag_data = tweak_data.gui.icons["ico_flag_" .. data.nationality] or tweak_data.gui.icons.ico_flag_empty

	self._nation_flag_icon:set_image(nation_flag_data.texture)
	self._nation_flag_icon:set_texture_rect(nation_flag_data.texture_rect)
	self._nation_flag_icon:set_visible(true)
	self._nation_flag_label:set_text(utf8.to_upper(managers.localization:text("nationality_" .. data.nationality)))
	self._level_amount_level:set_text(data.level)
	self._level_label:set_text(self:translate("select_character_level_label", true))

	if self._mode == RaidGUIControlCharacterDescription.MODE_SELECTION then
		local class_description = self:translate(tweak_data.skilltree.classes[data.class_name].desc_id, false) or ""

		self._description_label:set_text(class_description)

		local health_amount = data.character_stats and data.character_stats.health.base or 0

		self._health_amount_label:set_text(string.format("%.0f", health_amount))
		self._health_label:set_text(self:translate("select_character_health_label", true))

		local _, _, w, _ = self._health_label:text_rect()

		self._health_label:set_w(w)
		self._health_label:set_center_x(self._health_amount_label:x() + self._health_amount_label:w() / 2)

		local speed_amount = data.character_stats and data.character_stats.speed.base or 0

		self._speed_amount_label:set_text(string.format("%.0f", speed_amount))
		self._speed_label:set_text(self:translate("select_character_speed_label", true))

		local stamina_amount = data.character_stats and data.character_stats.stamina.base or 0

		self._stamina_amount_label:set_text(string.format("%.0f", stamina_amount))
		self._stamina_label:set_text(self:translate("select_character_stamina_label", true))
		self._warcries_label:set_text(self:translate("select_character_warcries_label", true))

		local _, _, w, _ = self._warcries_label:text_rect()

		self._warcries_label:set_w(w)

		local warcry_name_id = tweak_data.skilltree.class_warcry_data[data.class_name]
		local warcry_name = self:translate(tweak_data.warcry[warcry_name_id].name_id, true)
		local warcry_desc = self:translate(tweak_data.warcry[warcry_name_id].desc_id, false)
		local warcry_menu_icon_name = tweak_data.warcry[warcry_name_id].menu_icon
		local warcry_icon_data = tweak_data.gui.icons[warcry_menu_icon_name]

		self._warcry_description_label:set_text(warcry_desc)
		self._warcry_icon:set_image(warcry_icon_data.texture)
		self._warcry_icon:set_texture_rect(warcry_icon_data.texture_rect)
		self._warcry_name_label:set_text(warcry_name)

		local _, _, w, _ = self._warcry_name_label:text_rect()

		self._warcry_name_label:set_w(w)
		self._warcry_name_label:set_x(self._warcries_label:x() + self._warcries_label:w() + 5)
	end
end
