RaidGUIControlGoldBarPeerLoot = RaidGUIControlGoldBarPeerLoot or class(RaidGUIControl)
RaidGUIControlGoldBarPeerLoot.WIDTH = 544
RaidGUIControlGoldBarPeerLoot.HEIGHT = 96
RaidGUIControlGoldBarPeerLoot.REWARD_ICON_SINGLE = "rwd_gold_bar"
RaidGUIControlGoldBarPeerLoot.REWARD_ICON_FEW = "rwd_gold_bars"
RaidGUIControlGoldBarPeerLoot.REWARD_ICON_MANY = "rwd_gold_crate"
RaidGUIControlGoldBarPeerLoot.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlGoldBarPeerLoot.NAME_Y = 12
RaidGUIControlGoldBarPeerLoot.NAME_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlGoldBarPeerLoot.NAME_PADDING_DOWN = 2
RaidGUIControlGoldBarPeerLoot.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlGoldBarPeerLoot.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlGoldBarPeerLoot.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlGoldBarPeerLoot.IMAGE_PADDING_RIGHT = 10
RaidGUIControlGoldBarPeerLoot.TEXT_X = 128

-- Lines 23-33
function RaidGUIControlGoldBarPeerLoot:init(parent, params)
	RaidGUIControlGoldBarPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlGoldBarPeerLoot:init] Parameters not specified for the melee weapon peer drop details")

		return
	end

	self:_create_control_panel()
	self:_create_gold_bar_details()
end

-- Lines 36-46
function RaidGUIControlGoldBarPeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlGoldBarPeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlGoldBarPeerLoot.HEIGHT
	control_params.name = control_params.name .. "_melee_weapon_peer_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 49-89
function RaidGUIControlGoldBarPeerLoot:_create_gold_bar_details()
	local params_gold_bar_image = {
		name = "melee_weapon_image",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlGoldBarPeerLoot.REWARD_ICON_SINGLE].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlGoldBarPeerLoot.REWARD_ICON_SINGLE].texture_rect
	}
	self._gold_bar_image = self._object:bitmap(params_gold_bar_image)
	local params_player_name = {
		name = "peer_name_label",
		align = "left",
		text = "",
		layer = 1,
		x = RaidGUIControlGoldBarPeerLoot.TEXT_X,
		y = RaidGUIControlGoldBarPeerLoot.NAME_Y,
		w = self._object:w() - RaidGUIControlGoldBarPeerLoot.TEXT_X,
		color = RaidGUIControlGoldBarPeerLoot.NAME_COLOR,
		font = RaidGUIControlGoldBarPeerLoot.FONT,
		font_size = RaidGUIControlGoldBarPeerLoot.NAME_FONT_SIZE
	}
	self._name_label = self._object:text(params_player_name)
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)

	local params_gold_bar_description = {
		name = "melee_weapon_description_label",
		align = "left",
		layer = 1,
		text = self:translate("gold_bars", true),
		x = self._name_label:x(),
		y = self._name_label:y() + self._name_label:h() + RaidGUIControlGoldBarPeerLoot.NAME_PADDING_DOWN,
		w = self._name_label:w(),
		color = RaidGUIControlGoldBarPeerLoot.DESCRIPTION_COLOR,
		font = RaidGUIControlGoldBarPeerLoot.FONT,
		font_size = RaidGUIControlGoldBarPeerLoot.DESCRIPTION_FONT_SIZE
	}
	self._gold_bars_value_label = self._object:text(params_gold_bar_description)
	local _, _, _, h = self._gold_bars_value_label:text_rect()

	self._gold_bars_value_label:set_h(h)
end

-- Lines 91-94
function RaidGUIControlGoldBarPeerLoot:set_player_name(name)
	self._name_label:set_text(utf8.to_upper(name))
	self:_layout_text()
end

-- Lines 96-102
function RaidGUIControlGoldBarPeerLoot:_layout_text()
	local _, _, _, h = self._name_label:text_rect()

	self._name_label:set_h(h)
	self._name_label:set_y(RaidGUIControlGoldBarPeerLoot.NAME_Y)
	self._gold_bars_value_label:set_y(self._name_label:y() + self._name_label:h() + RaidGUIControlGoldBarPeerLoot.NAME_PADDING_DOWN)
end

-- Lines 104-106
function RaidGUIControlGoldBarPeerLoot:set_gold_bar_reward(amount)
	self._gold_bars_value_label:set_text((amount or 0) .. " " .. self:translate("menu_loot_screen_gold_bars", true))
end

-- Lines 108-126
function RaidGUIControlGoldBarPeerLoot:set_gold_bar_reward(amount)
	local text = ""

	if amount == 1 then
		text = self:translate("menu_loot_screen_gold_bars_single", true)
	else
		text = (amount or 0) .. " " .. self:translate("menu_loot_screen_gold_bars", true)
	end

	self._gold_bars_value_label:set_text(text)

	local icon = RaidGUIControlGoldBarPeerLoot.REWARD_ICON_SINGLE

	if amount and RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_MANY <= amount then
		icon = RaidGUIControlGoldBarPeerLoot.REWARD_ICON_MANY
	elseif amount and RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_FEW <= amount then
		icon = RaidGUIControlGoldBarPeerLoot.REWARD_ICON_FEW
	end

	self._gold_bar_image:set_image(tweak_data.gui.icons[icon].texture)
	self._gold_bar_image:set_texture_rect(unpack(tweak_data.gui.icons[icon].texture_rect))
end
