RaidGUIControlExperiencePeerLoot = RaidGUIControlExperiencePeerLoot or class(RaidGUIControl)
RaidGUIControlExperiencePeerLoot.WIDTH = 544
RaidGUIControlExperiencePeerLoot.HEIGHT = 96
RaidGUIControlExperiencePeerLoot.ICON = "rwd_xp"
RaidGUIControlExperiencePeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlExperiencePeerLoot.NAME_Y = 12
RaidGUIControlExperiencePeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlExperiencePeerLoot.NAME_PADDING_DOWN = 2
RaidGUIControlExperiencePeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlExperiencePeerLoot.XP_VALUE_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlExperiencePeerLoot.XP_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlExperiencePeerLoot.TEXT_X = 128

-- Lines 21-31
function RaidGUIControlExperiencePeerLoot:init(parent, params)
	RaidGUIControlExperiencePeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlExperiencePeerLoot:init] Parameters not specified for the xp drop details")

		return
	end

	self:_create_control_panel()
	self:_create_experience_details()
end

-- Lines 34-35
function RaidGUIControlExperiencePeerLoot:close()
end

-- Lines 38-47
function RaidGUIControlExperiencePeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlExperiencePeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlExperiencePeerLoot.HEIGHT
	control_params.name = control_params.name .. "_xp_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 50-91
function RaidGUIControlExperiencePeerLoot:_create_experience_details()
	local params_xp_image = {
		name = "xp_image",
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlExperiencePeerLoot.ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlExperiencePeerLoot.ICON].texture_rect
	}
	self._xp_image = self._object:bitmap(params_xp_image)

	self._xp_image:set_center_y(self._object:h() / 2)

	local params_player_name = {
		name = "peer_xp_name_label",
		align = "left",
		text = "aa",
		layer = 1,
		x = RaidGUIControlExperiencePeerLoot.TEXT_X,
		y = RaidGUIControlExperiencePeerLoot.NAME_Y,
		w = self._object:w() - RaidGUIControlExperiencePeerLoot.TEXT_X,
		color = RaidGUIControlExperiencePeerLoot.NAME_COLOR,
		font = RaidGUIControlExperiencePeerLoot.FONT,
		font_size = RaidGUIControlExperiencePeerLoot.NAME_FONT_SIZE
	}
	self._name_label = self._object:text(params_player_name)
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local params_customization_xp_value = {
		name = "customization_xp_value_label",
		align = "left",
		text = "a",
		layer = 1,
		x = self._name_label:x(),
		y = self._name_label:y() + self._name_label:h() + RaidGUIControlExperiencePeerLoot.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		color = RaidGUIControlExperiencePeerLoot.XP_VALUE_COLOR,
		font = RaidGUIControlExperiencePeerLoot.FONT,
		font_size = RaidGUIControlExperiencePeerLoot.XP_VALUE_FONT_SIZE
	}
	self._xp_value_label = self._object:text(params_customization_xp_value)
	local _, _, _, h = self._xp_value_label:text_rect()

	self._xp_value_label:set_h(h)
end

-- Lines 93-96
function RaidGUIControlExperiencePeerLoot:set_xp(xp)
	self._xp_value_label:set_text("+" .. xp .. " " .. self:translate("experience_points", true))
	self:_layout_text()
end

-- Lines 98-101
function RaidGUIControlExperiencePeerLoot:set_player_name(name)
	self._name_label:set_text(utf8.to_upper(name))
	self:_layout_text()
end

-- Lines 103-109
function RaidGUIControlExperiencePeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(RaidGUIControlExperiencePeerLoot.NAME_Y)
	self._xp_value_label:set_y(self._name_label:y() + self._name_label:h() + RaidGUIControlExperiencePeerLoot.NAME_PADDING_DOWN)
end
