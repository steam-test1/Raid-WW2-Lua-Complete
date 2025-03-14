RaidGUIControlRespec = RaidGUIControlRespec or class(RaidGUIControl)
RaidGUIControlRespec.DEFAULT_W = 320
RaidGUIControlRespec.DEFAULT_H = 150
RaidGUIControlRespec.TITLE_H = 64
RaidGUIControlRespec.TITLE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlRespec.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlRespec.TITLE_COLOR = Color.white
RaidGUIControlRespec.DESCRIPTION_W = 320
RaidGUIControlRespec.DESCRIPTION_Y = 80
RaidGUIControlRespec.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlRespec.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlRespec.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlRespec.COST_PADDING_DOWN = 32

function RaidGUIControlRespec:init(parent, params)
	RaidGUIControlRespec.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlRespec:init] Parameters not specified for the skill details " .. tostring(self._name))

		return
	end

	self:_create_control_panel()
	self:_create_respec_description()
end

function RaidGUIControlRespec:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlRespec.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlRespec.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlRespec:_create_respec_title()
	local skill_title_params = {
		y = 0,
		x = 0,
		name = "respec_title",
		align = "left",
		vertical = "center",
		wrap = false,
		text = utf8.to_upper(managers.localization:text("menu_character_skills_retrain_title")),
		w = self._object:w(),
		h = RaidGUIControlRespec.TITLE_H,
		font = RaidGUIControlRespec.TITLE_FONT,
		font_size = RaidGUIControlRespec.TITLE_FONT_SIZE,
		color = RaidGUIControlRespec.TITLE_COLOR
	}
	self._title = self._object:label(skill_title_params)
end

function RaidGUIControlRespec:_create_respec_description()
	local description_text_params = {
		x = 0,
		word_wrap = true,
		name = "respec_description",
		wrap = true,
		text = managers.localization:text("menu_character_skills_retrain_desc"),
		y = RaidGUIControlRespec.DESCRIPTION_Y,
		w = RaidGUIControlRespec.DESCRIPTION_W,
		h = self._object:h(),
		font = RaidGUIControlRespec.DESCRIPTION_FONT,
		font_size = RaidGUIControlRespec.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlRespec.DESCRIPTION_COLOR
	}
	self._description = self._object:label(description_text_params)
end
