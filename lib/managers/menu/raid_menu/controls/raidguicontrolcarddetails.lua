RaidGUIControlCardDetails = RaidGUIControlCardDetails or class(RaidGUIControl)
RaidGUIControlCardDetails.DEFAULT_WIDTH = 400
RaidGUIControlCardDetails.DEFAULT_HEIGHT = 255
RaidGUIControlCardDetails.CARD_WIDTH = 150
RaidGUIControlCardDetails.SCREEN_STATE_STARTING_MISSION_SERVER = "starting_mission_server"
RaidGUIControlCardDetails.SCREEN_STATE_STARTING_MISSION_CLIENT = "starting_mission_client"
RaidGUIControlCardDetails.SCREEN_STATE_EMPTY = "empty"
RaidGUIControlCardDetails.TITLE_FONT = tweak_data.hud.large_font
RaidGUIControlCardDetails.TITLE_TEXT_SIZE = 28
RaidGUIControlCardDetails.MISC_TEXT_SIZE = 18
RaidGUIControlCardDetails.DESCRIPTION_TEXT_SIZE = 14
RaidGUIControlCardDetails.DESCRIPTION_RIGHT_TEXT_SIZE = 18
RaidGUIControlCardDetails.TITLE_RIGHT_PADDING_DOWN = 5
RaidGUIControlCardDetails.MODE_VIEW_ONLY = "mode_view_only"
RaidGUIControlCardDetails.MODE_SUGGESTING = "mode_suggesting"
RaidGUIControlCardDetails.BONUS_EFFECT_Y = 224
RaidGUIControlCardDetails.MALUS_EFFECT_Y = 320
RaidGUIControlCardDetails.EFFECT_DISTANCE = 16
RaidGUIControlCardDetails.FONT = tweak_data.gui.fonts.din_compressed

-- Lines 29-48
function RaidGUIControlCardDetails:init(parent, params)
	RaidGUIControlCardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlCardDetails:init] Parameters not specified for the card details")

		return
	end

	self._pointer_type = "arrow"

	self:highlight_off()
	self:_create_object()
	self:_create_card_details()
end

-- Lines 50-51
function RaidGUIControlCardDetails:close()
end

-- Lines 53-63
function RaidGUIControlCardDetails:_create_object()
	local control_params = clone(self._params)
	control_params.w = control_params.w or RaidGUIControlCardDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlCardDetails.DEFAULT_HEIGHT
	control_params.x = control_params.x or 0
	control_params.y = control_params.y or 0
	control_params.name = control_params.name .. "_card_panel"
	control_params.layer = self._panel:layer() + 1
	self._object = self._panel:panel(control_params)
end

-- Lines 65-120
function RaidGUIControlCardDetails:_create_card_details()
	local card_params = {
		name = "player_loot_card",
		x = self._params.card_x or 0,
		y = self._params.card_y or 64,
		item_w = self._params.card_w or 496,
		item_h = self._params.card_h or 671
	}
	self._card_control = self._object:create_custom_control(RaidGUIControlCardBase, card_params)
	local x_spacing = self._card_control:w() + 48
	local params_card_name_right = {
		name = "card_name_label_right",
		h = 64,
		wrap = true,
		w = 640,
		align = "left",
		vertical = "bottom",
		text = "",
		y = 16,
		x = x_spacing,
		color = tweak_data.gui.colors.white,
		layer = self._object:layer() + 1,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38
	}
	self._card_name_label_right = self._object:label(params_card_name_right)
	local params_card_description_right = {
		name = "card_description_label_right",
		h = 0,
		wrap = true,
		w = 0,
		visible = false,
		text = "",
		y = 0,
		x = 0,
		color = Color.white,
		layer = self._object:layer() + 1,
		font = tweak_data.gui.fonts.lato,
		font_size = RaidGUIControlLootCardDetails.DESCRIPTION_RIGHT_TEXT_SIZE
	}
	self._card_description_label_right = self._object:label(params_card_description_right)
	local label_y = 160
	local icon_y = 96
	self._experience_bonus_count = self._object:label({
		w = 160,
		name = "experience_bonus_count",
		h = 64,
		visible = false,
		align = "right",
		text = "",
		x = x_spacing + 224,
		y = icon_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.title,
		color = tweak_data.gui.colors.raid_white
	})
	self._experience_bonus_label = self._object:label({
		w = 160,
		name = "experience_bonus_label",
		h = 32,
		visible = false,
		align = "right",
		x = x_spacing + 224,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		text = self:translate("challenge_cards_label_experience", true),
		color = tweak_data.gui.colors.raid_grey
	})
	self._type_icon = self._object:image({
		name = "type_icon",
		visible = false,
		x = x_spacing,
		y = icon_y,
		texture = tweak_data.challenge_cards.type_definition.card_type_raid.texture_path,
		texture_rect = tweak_data.challenge_cards.type_definition.card_type_raid.texture_rect
	})
	self._type_label = self._object:label({
		w = 96,
		name = "type_label",
		h = 32,
		align = "center",
		text = "",
		x = x_spacing,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		color = tweak_data.gui.colors.raid_grey
	})
	self._rarity_icon = self._object:image({
		name = "rarity_icon",
		visible = false,
		x = x_spacing + 128,
		y = icon_y,
		texture = tweak_data.challenge_cards.rarity_definition.loot_rarity_common.texture_path_icon,
		texture_rect = tweak_data.challenge_cards.rarity_definition.loot_rarity_common.texture_rect_icon
	})
	self._rarity_label = self._object:label({
		w = 128,
		name = "rarity_label",
		h = 32,
		align = "center",
		text = "",
		x = x_spacing + 96,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		color = tweak_data.gui.colors.raid_grey
	})
	self._bonus_effect_icon = self._object:image({
		name = "bonus_effect_icon",
		h = 64,
		w = 64,
		visible = false,
		x = x_spacing,
		y = RaidGUIControlCardDetails.BONUS_EFFECT_Y,
		texture = tweak_data.gui.icons.ico_bonus.texture,
		texture_rect = tweak_data.gui.icons.ico_bonus.texture_rect
	})
	self._malus_effect_icon = self._object:image({
		name = "malus_effect_icon",
		h = 64,
		w = 64,
		visible = false,
		x = x_spacing,
		y = RaidGUIControlCardDetails.MALUS_EFFECT_Y,
		texture = tweak_data.gui.icons.ico_malus.texture,
		texture_rect = tweak_data.gui.icons.ico_malus.texture_rect
	})
	self._bonus_effect_label = self._object:label({
		w = 288,
		name = "bonus_effect_label",
		h = 64,
		wrap = true,
		align = "left",
		vertical = "center",
		text = "",
		x = x_spacing + 80,
		y = RaidGUIControlCardDetails.BONUS_EFFECT_Y,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})
	self._malus_effect_label = self._object:label({
		w = 288,
		name = "malus_effect_label",
		h = 150,
		wrap = true,
		align = "left",
		vertical = "center",
		text = "",
		x = x_spacing + 80,
		y = RaidGUIControlCardDetails.MALUS_EFFECT_Y,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})
end

-- Lines 122-219
function RaidGUIControlCardDetails:set_card(card_key_name, steam_instance_id)
	self._card = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)

	if self._card then
		local card_rarity = self._card.rarity
		local card_type = self._card.card_type
		local card_rarity_icon_texture = tweak_data.challenge_cards.rarity_definition[card_rarity].texture_path_icon
		local card_rarity_icon_texture_rect = tweak_data.challenge_cards.rarity_definition[card_rarity].texture_rect_icon

		if card_rarity_icon_texture and card_rarity_icon_texture_rect then
			self._rarity_icon:set_image(card_rarity_icon_texture)
			self._rarity_icon:set_texture_rect(card_rarity_icon_texture_rect)
			self._rarity_icon:show()
		else
			self._rarity_icon:hide()
		end

		local card_type_icon_texture = tweak_data.challenge_cards.type_definition[card_type].texture_path
		local card_type_icon_texture_rect = tweak_data.challenge_cards.type_definition[card_type].texture_rect

		if card_type_icon_texture and card_rarity_icon_texture_rect then
			self._type_icon:set_image(card_type_icon_texture)
			self._type_icon:set_texture_rect(card_type_icon_texture_rect)
			self._type_icon:show()
		else
			self._type_icon:hide()
		end

		self._card.steam_instance_id = steam_instance_id

		self._card_control:set_card(self._card)
		self._card_control:set_visible(true)

		local card_name = self._card.name
		local card_description = self._card.description

		self._card_name_label_right:set_text(self:translate(card_name, true))

		local _, _, w, h = self._card_name_label_right:text_rect()

		self._card_name_label_right:set_height(h)
		self._card_description_label_right:set_text(self:translate(card_description))
		self._card_description_label_right:set_y(self._card_name_label_right:y() + h)

		local xp_label_value = managers.challenge_cards:get_card_xp_label(card_key_name, true)

		if xp_label_value and xp_label_value ~= "" then
			self._experience_bonus_count:set_text(xp_label_value)
			self._experience_bonus_count:set_visible(true)
			self._experience_bonus_label:set_visible(true)
		else
			self._experience_bonus_count:set_text("")
			self._experience_bonus_count:set_visible(false)
			self._experience_bonus_label:set_visible(false)
		end

		self._type_label:set_text(self:translate(self._card.card_type, true))
		self._rarity_label:set_text(self:translate(self._card.rarity, true))

		local bonus_description, malus_description = managers.challenge_cards:get_card_description(card_key_name)

		if bonus_description and bonus_description ~= "" then
			self._bonus_effect_icon:show()
			self._bonus_effect_label:set_text(bonus_description)

			local _, _, _, h = self._bonus_effect_label:text_rect()

			self._bonus_effect_label:set_h(h)
		else
			self._bonus_effect_label:set_text("")
			self._bonus_effect_icon:hide()
		end

		if malus_description and malus_description ~= "" then
			self._malus_effect_icon:show()
			self._malus_effect_label:set_text(malus_description)

			local _, _, _, h = self._malus_effect_label:text_rect()

			self._malus_effect_label:set_h(h)

			local malus_effect_y = self._bonus_effect_icon:y()

			if self._bonus_effect_icon:visible() then
				malus_effect_y = math.max(self._bonus_effect_icon:bottom(), self._bonus_effect_label:bottom()) + RaidGUIControlCardDetails.EFFECT_DISTANCE
			end

			self._malus_effect_label:set_y(malus_effect_y)
			self._malus_effect_icon:set_y(malus_effect_y)
		else
			self._malus_effect_label:set_text("")
			self._malus_effect_icon:hide()
		end
	else
		self._card_control:set_visible(false)
		self._card_name_label_right:set_text("")
		self._card_description_label_right:set_text("")
		self._experience_bonus_count:set_visible(false)
		self._experience_bonus_label:set_visible(false)
	end
end

-- Lines 221-223
function RaidGUIControlCardDetails:set_mode_layout()
	self._type_icon:set_center_x(self._type_label:center_x())
end

-- Lines 225-228
function RaidGUIControlCardDetails:get_card()
	return self._card, self._card.steam_instance_id
end

-- Lines 230-234
function RaidGUIControlCardDetails:set_control_mode(mode)
	self._mode = mode

	self:set_mode_layout()
end
