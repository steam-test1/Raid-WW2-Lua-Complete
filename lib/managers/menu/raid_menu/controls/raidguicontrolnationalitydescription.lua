RaidGUIControlNationalityDescription = RaidGUIControlNationalityDescription or class(RaidGUIControl)
RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y = 242

-- Lines 6-12
function RaidGUIControlNationalityDescription:init(parent, params, item_data)
	RaidGUIControlNationalityDescription.super.init(self, parent, params, item_data)

	self._data = item_data

	self:_layout()
end

-- Lines 14-38
function RaidGUIControlNationalityDescription:_layout()
	self._object = self._panel:panel({
		name = "character_info_panel",
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})
	local tex_rect = tweak_data.gui.icons.character_creation_nationality_british.texture_rect
	self._nation_icon = self._object:image({
		name = "nation_icon",
		y = 5,
		x = 0,
		w = tex_rect[3],
		h = tex_rect[4],
		texture = tweak_data.gui.icons.character_creation_nationality_british.texture,
		texture_rect = tex_rect
	})
	self._character_name_label = self._object:label({
		w = 224,
		name = "character_name_label",
		h = 42,
		y = 8,
		x = 64,
		text = utf8.to_upper("Stirling"),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.menu_list,
		color = tweak_data.gui.colors.raid_red
	})
	self._backstory_label = self._object:label({
		name = "backstory_label",
		vertical = "top",
		h = 128,
		wrap = true,
		w = 416,
		align = "left",
		x = 0,
		y = self._character_name_label:bottom() + 32,
		text = self:translate("character_profile_creation_british_description", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})
	self._prefered_nationality_label = self._object:label({
		w = 320,
		name = "preferred_nationality",
		h = 32,
		x = 0,
		y = RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y,
		text = self:translate("character_creation_preferred_nationality", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._disclaimer_label = self._object:label({
		name = "preferred_nationality_disclaimer",
		vertical = "top",
		h = 320,
		wrap = true,
		w = 416,
		align = "left",
		x = 0,
		y = self._prefered_nationality_label:bottom() + 32,
		text = self:translate("character_creation_preferred_nationality_disclaimer", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})
end

-- Lines 40-58
function RaidGUIControlNationalityDescription:set_data(data)
	local nation_icon_data = tweak_data.gui.icons["character_creation_nationality_" .. data.nationality] or tweak_data.gui.icons.ico_flag_empty

	self._nation_icon:set_image(nation_icon_data.texture)
	self._nation_icon:set_texture_rect(nation_icon_data.texture_rect)
	self._nation_icon:set_visible(true)
	self._character_name_label:set_text(self:translate("menu_" .. data.nationality, true))

	local backstory_text = self:translate("character_profile_creation_" .. data.nationality .. "_description", false) or ""

	self._backstory_label:set_text(backstory_text)

	local _, _, _, h = self._backstory_label:text_rect()

	self._backstory_label:set_h(h)
	self._prefered_nationality_label:set_y(math.max(RaidGUIControlNationalityDescription.PREFERRED_NATIONALITY_LABEL_DEFAULT_Y, self._backstory_label:bottom() + 32))
	self._disclaimer_label:set_y(self._prefered_nationality_label:bottom() + 32)
end
