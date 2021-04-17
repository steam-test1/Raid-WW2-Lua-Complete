RaidGUIControlCardPeerLoot = RaidGUIControlCardPeerLoot or class(RaidGUIControl)
RaidGUIControlCardPeerLoot.WIDTH = 98
RaidGUIControlCardPeerLoot.HEIGHT = 166
RaidGUIControlCardPeerLoot.IMAGE_PADDING_DOWN = 5
RaidGUIControlCardPeerLoot.CARD_TITLE_PADDING_PERCENT = 7
RaidGUIControlCardPeerLoot.TEXT_H = 40
RaidGUIControlCardPeerLoot.TEXT_FONT = tweak_data.hud.large_font
RaidGUIControlCardPeerLoot.FONT_SIZE = 18

-- Lines 14-28
function RaidGUIControlCardPeerLoot:init(parent, params)
	RaidGUIControlCardPeerLoot.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlCardPeerLoot:init] Parameters not specified for the card details")

		return
	end

	self._pointer_type = "arrow"

	self:highlight_off()
	self:_create_control_panel()
	self:_create_card_details()
end

-- Lines 31-32
function RaidGUIControlCardPeerLoot:close()
end

-- Lines 35-45
function RaidGUIControlCardPeerLoot:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlCardPeerLoot.WIDTH
	control_params.h = control_params.h or RaidGUIControlCardPeerLoot.HEIGHT
	control_params.name = control_params.name .. "_card_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 48-68
function RaidGUIControlCardPeerLoot:_create_card_details()
	local params_card_image = {
		texture = "ui/main_menu/textures/cards_atlas",
		name = "card_image",
		y = 0,
		x = 0,
		w = self._control_panel:w(),
		h = self._control_panel:w() * 1.45,
		texture_rect = {
			56,
			669,
			144,
			209
		}
	}
	self._card_image = self._control_panel:bitmap(params_card_image)
	local params_player_name = {
		name = "peer_player_name_label",
		align = "center",
		text = "PLAYER 1",
		x = 0,
		layer = 1,
		y = self._card_image:y() + self._card_image:h() + RaidGUIControlCardPeerLoot.IMAGE_PADDING_DOWN,
		w = self._control_panel:w(),
		h = RaidGUIControlCardPeerLoot.TEXT_H,
		color = tweak_data.menu.raid_red,
		font = RaidGUIControlCardPeerLoot.TEXT_FONT,
		font_size = RaidGUIControlCardPeerLoot.FONT_SIZE
	}
	self._name_label = self._control_panel:label(params_player_name)
	local params_card_title = {
		name = "card_title_label",
		wrap = true,
		align = "right",
		text = "22xp",
		layer = 1,
		x = self._card_image:w() * RaidGUIControlCardPeerLoot.CARD_TITLE_PADDING_PERCENT / 100,
		y = self._card_image:y() + self._card_image:h() / 2 - RaidGUIControlCardPeerLoot.TEXT_H / 2,
		w = self._card_image:w() * (1 - 2 * RaidGUIControlCardPeerLoot.CARD_TITLE_PADDING_PERCENT / 100),
		h = RaidGUIControlCardPeerLoot.TEXT_H,
		color = Color.white,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	}
	self._card_title_label = self._control_panel:label(params_card_title)
end

-- Lines 71-73
function RaidGUIControlCardPeerLoot:set_debug(value)
	self._control_panel:set_debug(value)
end

-- Lines 76-92
function RaidGUIControlCardPeerLoot:set_card(card)
	self._card = card

	self._card_title_label:set_text(self:translate(card.name, true))
	self._card_title_label:set_text(utf8.to_upper(card.name))
	self._card_title_label:set_color(tweak_data.challenge_cards.rarity_definition[card.rarity].color)

	local card_texture = tweak_data.challenge_cards.rarity_definition[card.rarity].texture_path_thumb
	local card_texture_rect = tweak_data.challenge_cards.rarity_definition[card.rarity].texture_rect_thumb

	self._card_image:set_image(card_texture)
	self._card_image:set_texture_rect(unpack(card_texture_rect))
end

-- Lines 94-96
function RaidGUIControlCardPeerLoot:get_card()
	return self._card
end

-- Lines 98-100
function RaidGUIControlCardPeerLoot:set_player_name(name)
	self._name_label:set_text(name)
end
