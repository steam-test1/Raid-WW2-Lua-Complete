RaidGUIControlPeerDetails = RaidGUIControlPeerDetails or class(RaidGUIControl)
RaidGUIControlPeerDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlPeerDetails.NAME_X = 70
RaidGUIControlPeerDetails.NAME_FONT_SIZE = 26
RaidGUIControlPeerDetails.NAME_PADDING_DOWN = 10
RaidGUIControlPeerDetails.NAME_COLOR = tweak_data.gui.colors.raid_light_red
RaidGUIControlPeerDetails.DEFAULT_W = 300
RaidGUIControlPeerDetails.DEFAULT_H = 64
RaidGUIControlPeerDetails.CLASS_ICON_PADDING_LEFT = 5
RaidGUIControlPeerDetails.ICON_TITLE_FONT_SIZE = 38
RaidGUIControlPeerDetails.ICON_FONT_SIZE = 14
RaidGUIControlPeerDetails.LEVEL_W = 64

-- Lines 16-31
function RaidGUIControlPeerDetails:init(parent, params)
	RaidGUIControlPeerDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlPeerDetails:init] Parameters not specified for the peer details control " .. tostring(self._name))

		return
	end

	self._pointer_type = "arrow"

	self:highlight_off()
	self:_create_panel()
	self:_create_profile_name()
	self:_create_profile_details()
end

-- Lines 33-43
function RaidGUIControlPeerDetails:_create_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlPeerDetails.DEFAULT_W
	panel_params.h = RaidGUIControlPeerDetails.DEFAULT_H
	self._object = self._panel:panel(panel_params)
end

-- Lines 45-58
function RaidGUIControlPeerDetails:_create_profile_name()
	local profile_name_params = {
		name = "profile_name",
		h = 32,
		vertical = "center",
		align = "left",
		text = "PROFILE NAME",
		y = 0,
		x = RaidGUIControlPeerDetails.NAME_X,
		w = self._object:w() - RaidGUIControlPeerDetails.NAME_X - RaidGUIControlPeerDetails.LEVEL_W,
		font = RaidGUIControlPeerDetails.FONT,
		font_size = RaidGUIControlPeerDetails.NAME_FONT_SIZE,
		color = tweak_data.gui.colors.raid_black
	}
	self._profile_name = self._object:text(profile_name_params)
end

-- Lines 60-98
function RaidGUIControlPeerDetails:_create_profile_details()
	local class_icon_params = {
		name = "class_icon",
		texture = tweak_data.gui.icons.ico_class_infiltrator.texture,
		texture_rect = tweak_data.gui.icons.ico_class_infiltrator.texture_rect,
		color = tweak_data.gui.colors.raid_black
	}
	self._class_icon = self._object:bitmap(class_icon_params)

	self._class_icon:set_center_y(self._object:h() / 2)

	local nationality_params = {
		name = "nationality",
		h = 32,
		vertical = "center",
		align = "left",
		text = "GERMAN",
		y = 0,
		x = RaidGUIControlPeerDetails.NAME_X,
		w = self._object:w() - RaidGUIControlPeerDetails.NAME_X,
		font = RaidGUIControlPeerDetails.FONT,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_black
	}
	self._nationality = self._object:text(nationality_params)

	self._nationality:set_bottom(self._object:h())

	local level_text_params = {
		vertical = "center",
		h = 32,
		name = "level_text",
		align = "center",
		text = "10",
		w = RaidGUIControlPeerDetails.LEVEL_W,
		font = RaidGUIControlPeerDetails.FONT,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_black
	}
	self._level_text = self._object:text(level_text_params)

	self._level_text:set_right(self._object:w())
end

-- Lines 100-102
function RaidGUIControlPeerDetails:set_profile_name(name)
	self._profile_name:set_text(utf8.to_upper(name))
end

-- Lines 104-107
function RaidGUIControlPeerDetails:set_class(character_class)
	self._class_icon:set_image(tweak_data.gui.icons["ico_class_" .. character_class].texture)
	self._class_icon:set_texture_rect(unpack(tweak_data.gui.icons["ico_class_" .. character_class].texture_rect))
end

-- Lines 109-116
function RaidGUIControlPeerDetails:set_nationality(nationality)
	local params = {
		icon_h = 48,
		text_size = RaidGUIControlPeerDetails.ICON_FONT_SIZE
	}

	self._nationality:set_text(utf8.to_upper(managers.localization:text("nationality_" .. nationality)))
end

-- Lines 118-120
function RaidGUIControlPeerDetails:set_level(level)
	self._level_text:set_text(tostring(level))
end

-- Lines 122-123
function RaidGUIControlPeerDetails:close()
end
