RaidGUIControlMeleeWeaponPeerLoot = RaidGUIControlMeleeWeaponPeerLoot or class(RaidGUIControl)
RaidGUIControlMeleeWeaponPeerLoot.WIDTH = 544
RaidGUIControlMeleeWeaponPeerLoot.HEIGHT = 96
RaidGUIControlMeleeWeaponPeerLoot.ICON = "rwd_melee"
RaidGUIControlMeleeWeaponPeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlMeleeWeaponPeerLoot.NAME_Y = 12
RaidGUIControlMeleeWeaponPeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlMeleeWeaponPeerLoot.NAME_PADDING_DOWN = 2
RaidGUIControlMeleeWeaponPeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlMeleeWeaponPeerLoot.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlMeleeWeaponPeerLoot.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlMeleeWeaponPeerLoot.IMAGE_PADDING_RIGHT = 10
RaidGUIControlMeleeWeaponPeerLoot.TEXT_X = 128

-- Lines 21-31
function RaidGUIControlMeleeWeaponPeerLoot:init(parent, params)
	RaidGUIControlMeleeWeaponPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlMeleeWeaponPeerLoot:init] Parameters not specified for the melee weapon peer drop details")

		return
	end

	self:_create_control_panel()
	self:_create_weapon_point_details()
end

-- Lines 34-44
function RaidGUIControlMeleeWeaponPeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlMeleeWeaponPeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlMeleeWeaponPeerLoot.HEIGHT
	control_params.name = control_params.name .. "_melee_weapon_peer_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 47-87
function RaidGUIControlMeleeWeaponPeerLoot:_create_weapon_point_details()
	local params_weapon_point_image = {
		name = "melee_weapon_image",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlMeleeWeaponPeerLoot.ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlMeleeWeaponPeerLoot.ICON].texture_rect
	}
	self._weapon_point_image = self._object:bitmap(params_weapon_point_image)
	local params_player_name = {
		name = "peer_melee_weapon_name_label",
		align = "left",
		text = "",
		layer = 1,
		x = RaidGUIControlMeleeWeaponPeerLoot.TEXT_X,
		y = RaidGUIControlMeleeWeaponPeerLoot.NAME_Y,
		w = self._object:w() - RaidGUIControlMeleeWeaponPeerLoot.TEXT_X,
		color = RaidGUIControlMeleeWeaponPeerLoot.NAME_COLOR,
		font = RaidGUIControlMeleeWeaponPeerLoot.FONT,
		font_size = RaidGUIControlMeleeWeaponPeerLoot.NAME_FONT_SIZE
	}
	self._name_label = self._object:text(params_player_name)
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local params_weapon_point_description = {
		name = "melee_weapon_description_label",
		align = "left",
		layer = 1,
		text = self:translate("melee_weapon", true),
		x = self._name_label:x(),
		y = self._name_label:y() + self._name_label:h() + RaidGUIControlMeleeWeaponPeerLoot.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		color = RaidGUIControlMeleeWeaponPeerLoot.DESCRIPTION_COLOR,
		font = RaidGUIControlMeleeWeaponPeerLoot.FONT,
		font_size = RaidGUIControlMeleeWeaponPeerLoot.DESCRIPTION_FONT_SIZE
	}
	self._xp_value_label = self._object:text(params_weapon_point_description)
	local _, _, _, h = self._xp_value_label:text_rect()

	self._xp_value_label:set_h(h)
end

-- Lines 89-92
function RaidGUIControlMeleeWeaponPeerLoot:set_player_name(name)
	self._name_label:set_text(utf8.to_upper(name))
	self:_layout_text()
end

-- Lines 94-100
function RaidGUIControlMeleeWeaponPeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(RaidGUIControlMeleeWeaponPeerLoot.NAME_Y)
	self._xp_value_label:set_y(self._name_label:y() + self._name_label:h() + RaidGUIControlMeleeWeaponPeerLoot.NAME_PADDING_DOWN)
end

-- Lines 102-109
function RaidGUIControlMeleeWeaponPeerLoot:set_melee_weapon(weapon_id)
	local weapon_name = ""
	local tweak_data = tweak_data.blackmarket.melee_weapons[weapon_id]

	if tweak_data then
		weapon_name = self:translate(tweak_data.name_id, true)
	end

	self._xp_value_label:set_text(weapon_name)
end
