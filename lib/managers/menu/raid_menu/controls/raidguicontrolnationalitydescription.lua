RaidGUIControlNationalityDescription = RaidGUIControlNationalityDescription or class(RaidGUIControl)
RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y = 290

function RaidGUIControlNationalityDescription:init(parent, params, item_data)
	RaidGUIControlNationalityDescription.super.init(self, parent, params, item_data)

	self._data = item_data

	self:_layout()
end

function RaidGUIControlNationalityDescription:_layout()
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
		texture = tweak_data.gui.icons.paper_reward_large.texture,
		texture_rect = tweak_data.gui.icons.paper_reward_large.texture_rect
	}
	self._object_bg = self._object:image(object_bg_params)
	local object_bg_params2 = {
		name = "object_bg",
		layer = -2,
		y = 0,
		x = -4,
		w = self._object:w() + 8,
		h = self._object:h(),
		texture = tweak_data.gui.icons.paper_reward_large.texture,
		texture_rect = tweak_data.gui.icons.paper_reward_large.texture_rect,
		rotation = -2 - math.random(4),
		color = Color(0.6, 0.6, 0.6)
	}
	self._object_bg2 = self._object:image(object_bg_params2)
	local tex_rect = tweak_data.gui.icons.character_creation_nationality_british.texture_rect
	self._nation_icon = self._object:image({
		name = "nation_icon",
		align = "center",
		y = 24,
		x = 8,
		w = tex_rect[3],
		h = tex_rect[4],
		texture = tweak_data.gui.icons.character_creation_nationality_british.texture,
		texture_rect = tex_rect,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._character_name_label = self._object:label({
		name = "character_name_label",
		h = 42,
		w = 224,
		align = "center",
		x = 0,
		y = self._nation_icon:bottom() - 8,
		text = utf8.to_upper("CHARNAME"),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.menu_list,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._backstory_label = self._object:label({
		name = "backstory_label",
		vertical = "top",
		h = 128,
		wrap = true,
		align = "center",
		x = padding,
		w = padded_width,
		y = self._character_name_label:bottom() + 32,
		text = self:translate("character_profile_creation_british_description", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._prefered_nationality_label = self._object:label({
		name = "preferred_nationality",
		h = 32,
		align = "center",
		x = padding,
		w = padded_width,
		y = RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y,
		text = self:translate("character_creation_preferred_nationality", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
	self._disclaimer_label = self._object:label({
		name = "preferred_nationality_disclaimer",
		vertical = "top",
		h = 320,
		wrap = true,
		align = "center",
		x = padding,
		w = padded_width,
		y = self._prefered_nationality_label:bottom() + 32,
		text = self:translate("character_creation_preferred_nationality_disclaimer", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		alpha = RaidGUIControlCharacterDescription.COMMON_ALPHA,
		color = tweak_data.gui.colors.raid_black
	})
end

function RaidGUIControlNationalityDescription:set_data(data)
	local nation_icon_data = tweak_data.gui.icons["character_creation_nationality_" .. data.nationality] or tweak_data.gui.icons.ico_flag_empty

	self._nation_icon:set_image(nation_icon_data.texture)
	self._nation_icon:set_texture_rect(nation_icon_data.texture_rect)
	self._nation_icon:set_visible(true)
	self._nation_icon:set_center_x(self._object:w() / 2)
	self._character_name_label:set_text(self:translate("menu_" .. data.nationality, true))
	self._character_name_label:set_center_x(self._object:w() / 2)

	local backstory_text = self:translate("character_profile_creation_" .. data.nationality .. "_description", false) or ""

	self._backstory_label:set_text(backstory_text)

	local _, _, _, h = self._backstory_label:text_rect()

	self._backstory_label:set_h(h)
	self._prefered_nationality_label:set_y(math.max(RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y, self._backstory_label:bottom() + 20))
	self._disclaimer_label:set_y(self._prefered_nationality_label:bottom() + 32)
end
