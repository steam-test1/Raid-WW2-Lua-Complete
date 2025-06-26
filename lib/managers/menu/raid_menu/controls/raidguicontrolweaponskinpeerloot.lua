RaidGUIControlWeaponSkinPeerLoot = RaidGUIControlWeaponSkinPeerLoot or class(RaidGUIControl)
RaidGUIControlWeaponSkinPeerLoot.WIDTH = 544
RaidGUIControlWeaponSkinPeerLoot.HEIGHT = 96
RaidGUIControlWeaponSkinPeerLoot.ICON = "rwd_weapon"
RaidGUIControlWeaponSkinPeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlWeaponSkinPeerLoot.NAME_Y = 12
RaidGUIControlWeaponSkinPeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlWeaponSkinPeerLoot.NAME_PADDING_DOWN = 2
RaidGUIControlWeaponSkinPeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlWeaponSkinPeerLoot.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlWeaponSkinPeerLoot.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlWeaponSkinPeerLoot.TEXT_X = 128

function RaidGUIControlWeaponSkinPeerLoot:init(parent, params)
	RaidGUIControlWeaponSkinPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlWeaponSkinPeerLoot:init] Parameters not specified for the customization details")

		return
	end

	self:_layout_panel()
	self:_layout_reward_details(params)
end

function RaidGUIControlWeaponSkinPeerLoot:_layout_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.x = control_params.x
	control_params.w = control_params.w or self.WIDTH
	control_params.h = control_params.h or self.HEIGHT
	control_params.layer = self._panel:layer() + 1
	self._object = self._panel:panel(control_params)
end

function RaidGUIControlWeaponSkinPeerLoot:_layout_reward_details(params)
	local gui_data = tweak_data.gui:get_full_gui_data(self.ICON)
	local weapon_data = tweak_data.weapon[params.weapon_skin.weapon_id]

	if weapon_data then
		gui_data = tweak_data.gui:get_full_gui_data(weapon_data.hud.icon)
	end

	self._customization_image = self._object:bitmap({
		name = "card_image",
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect
	})

	self._customization_image:set_center_y(self._object:h() / 2)

	self._name_label = self._object:text({
		text = "",
		layer = 1,
		name = "peer_customization_name_label",
		align = "left",
		x = self.TEXT_X,
		y = self.NAME_Y,
		w = self._object:w() - self.TEXT_X,
		font = self.FONT,
		font_size = self.NAME_FONT_SIZE,
		color = self.NAME_COLOR
	})
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local item_title = params.weapon_skin and self:translate(params.weapon_skin.name_id, true)
	self._customization_description = self._object:text({
		wrap = true,
		layer = 1,
		name = "customization_description_label",
		align = "left",
		x = self._name_label:x(),
		y = self._name_label:bottom() + self.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		font = self.FONT,
		font_size = self.DESCRIPTION_FONT_SIZE,
		text = item_title,
		color = self.DESCRIPTION_COLOR
	})
end

function RaidGUIControlWeaponSkinPeerLoot:set_player_name(name)
	self._name_label:set_text(name)
	self:_layout_text()
end

function RaidGUIControlWeaponSkinPeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(self.NAME_Y)
	self._customization_description:set_y(self._name_label:bottom() + self.NAME_PADDING_DOWN)
end
