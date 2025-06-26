RaidGUIControlWeaponPointPeerLoot = RaidGUIControlWeaponPointPeerLoot or class(RaidGUIControl)
RaidGUIControlWeaponPointPeerLoot.WIDTH = 544
RaidGUIControlWeaponPointPeerLoot.HEIGHT = 96
RaidGUIControlWeaponPointPeerLoot.ICON = "rwd_weapon"
RaidGUIControlWeaponPointPeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlWeaponPointPeerLoot.NAME_Y = 9
RaidGUIControlWeaponPointPeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponPointPeerLoot.NAME_PADDING_DOWN = 5
RaidGUIControlWeaponPointPeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlWeaponPointPeerLoot.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlWeaponPointPeerLoot.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.small
RaidGUIControlWeaponPointPeerLoot.IMAGE_PADDING_RIGHT = 10
RaidGUIControlWeaponPointPeerLoot.TEXT_X = 128

function RaidGUIControlWeaponPointPeerLoot:init(parent, params)
	RaidGUIControlWeaponPointPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlWeaponPointPeerLoot:init] Parameters not specified for the weapon point peer drop details")

		return
	end

	self:_create_control_panel()
	self:_create_weapon_point_details()
end

function RaidGUIControlWeaponPointPeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlWeaponPointPeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlWeaponPointPeerLoot.HEIGHT
	control_params.name = control_params.name .. "_weapon_point_peer_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlWeaponPointPeerLoot:_create_weapon_point_details()
	local params_weapon_point_image = {
		y = 0,
		name = "weapon_point_image",
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlWeaponPointPeerLoot.ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlWeaponPointPeerLoot.ICON].texture_rect
	}
	self._weapon_point_image = self._object:bitmap(params_weapon_point_image)
	local params_player_name = {
		layer = 1,
		text = "",
		name = "peer_weapon_point_name_label",
		align = "left",
		x = RaidGUIControlWeaponPointPeerLoot.TEXT_X,
		y = RaidGUIControlWeaponPointPeerLoot.NAME_Y,
		w = self._object:w() - RaidGUIControlWeaponPointPeerLoot.TEXT_X,
		color = RaidGUIControlWeaponPointPeerLoot.NAME_COLOR,
		font = RaidGUIControlWeaponPointPeerLoot.FONT,
		font_size = RaidGUIControlWeaponPointPeerLoot.NAME_FONT_SIZE
	}
	self._name_label = self._object:text(params_player_name)
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local params_weapon_point_description = {
		layer = 1,
		name = "weapon_point_description_label",
		align = "left",
		text = self:translate("weapon_point", true),
		x = self._name_label:x(),
		y = self._name_label:y() + self._name_label:h() + RaidGUIControlWeaponPointPeerLoot.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		color = RaidGUIControlWeaponPointPeerLoot.DESCRIPTION_COLOR,
		font = RaidGUIControlWeaponPointPeerLoot.FONT,
		font_size = RaidGUIControlWeaponPointPeerLoot.DESCRIPTION_FONT_SIZE
	}
	self._xp_value_label = self._object:text(params_weapon_point_description)
	local _, _, _, h = self._xp_value_label:text_rect()

	self._xp_value_label:set_h(h)
end

function RaidGUIControlWeaponPointPeerLoot:set_player_name(name)
	if managers.user:get_setting("capitalize_names") then
		name = utf8.to_upper(name)
	end

	self._name_label:set_text(name)
	self:_layout_text()
end

function RaidGUIControlWeaponPointPeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(RaidGUIControlWeaponPointPeerLoot.NAME_Y)
	self._xp_value_label:set_y(self._name_label:y() + self._name_label:h() + RaidGUIControlWeaponPointPeerLoot.NAME_PADDING_DOWN)
end
