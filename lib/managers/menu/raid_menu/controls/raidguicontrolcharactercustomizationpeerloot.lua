RaidGUIControlCharacterCustomizationPeerLoot = RaidGUIControlCharacterCustomizationPeerLoot or class(RaidGUIControl)
RaidGUIControlCharacterCustomizationPeerLoot.WIDTH = 544
RaidGUIControlCharacterCustomizationPeerLoot.HEIGHT = 96
RaidGUIControlCharacterCustomizationPeerLoot.ICON_UPPER = "rwd_upper_body"
RaidGUIControlCharacterCustomizationPeerLoot.ICON_LOWER = "rwd_lower_body"
RaidGUIControlCharacterCustomizationPeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlCharacterCustomizationPeerLoot.NAME_Y = 12
RaidGUIControlCharacterCustomizationPeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlCharacterCustomizationPeerLoot.NAME_PADDING_DOWN = 2
RaidGUIControlCharacterCustomizationPeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlCharacterCustomizationPeerLoot.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlCharacterCustomizationPeerLoot.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlCharacterCustomizationPeerLoot.TEXT_X = 128

-- Lines 22-32
function RaidGUIControlCharacterCustomizationPeerLoot:init(parent, params)
	RaidGUIControlCharacterCustomizationPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlCharacterCustomizationPeerLoot:init] Parameters not specified for the customization details")

		return
	end

	self:_create_control_panel()
	self:_create_customization_details(params)
end

-- Lines 35-45
function RaidGUIControlCharacterCustomizationPeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlCharacterCustomizationPeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlCharacterCustomizationPeerLoot.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 48-94
function RaidGUIControlCharacterCustomizationPeerLoot:_create_customization_details(params)
	local icon = nil

	if params.customization.part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		icon = RaidGUIControlCharacterCustomizationPeerLoot.ICON_UPPER
	else
		icon = RaidGUIControlCharacterCustomizationPeerLoot.ICON_LOWER
	end

	local params_customization_image = {
		name = "card_image",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	self._customization_image = self._control_panel:bitmap(params_customization_image)
	local params_player_name = {
		name = "peer_customization_name_label",
		align = "left",
		text = "",
		layer = 1,
		x = RaidGUIControlCharacterCustomizationPeerLoot.TEXT_X,
		y = RaidGUIControlCharacterCustomizationPeerLoot.NAME_Y,
		w = self._object:w() - RaidGUIControlCharacterCustomizationPeerLoot.TEXT_X,
		color = RaidGUIControlCharacterCustomizationPeerLoot.NAME_COLOR,
		font = RaidGUIControlCharacterCustomizationPeerLoot.FONT,
		font_size = RaidGUIControlCharacterCustomizationPeerLoot.NAME_FONT_SIZE
	}
	self._name_label = self._object:text(params_player_name)
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local params_customization_description = {
		name = "customization_description_label",
		wrap = true,
		align = "left",
		text = "",
		layer = 1,
		x = self._name_label:x(),
		y = self._name_label:y() + self._name_label:h() + RaidGUIControlCharacterCustomizationPeerLoot.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		color = RaidGUIControlCharacterCustomizationPeerLoot.DESCRIPTION_COLOR,
		font = RaidGUIControlCharacterCustomizationPeerLoot.FONT,
		font_size = RaidGUIControlCharacterCustomizationPeerLoot.DESCRIPTION_FONT_SIZE
	}
	self._customization_description = self._object:text(params_customization_description)
end

-- Lines 97-101
function RaidGUIControlCharacterCustomizationPeerLoot:set_customization(customization)
	self._customization = customization

	self._customization_description:set_text(self:translate(customization.name, true))
	self:_layout_text()
end

-- Lines 103-106
function RaidGUIControlCharacterCustomizationPeerLoot:set_player_name(name)
	self._name_label:set_text(utf8.to_upper(name))
	self:_layout_text()
end

-- Lines 108-114
function RaidGUIControlCharacterCustomizationPeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(RaidGUIControlCharacterCustomizationPeerLoot.NAME_Y)
	self._customization_description:set_y(self._name_label:y() + self._name_label:h() + RaidGUIControlCharacterCustomizationPeerLoot.NAME_PADDING_DOWN)
end
