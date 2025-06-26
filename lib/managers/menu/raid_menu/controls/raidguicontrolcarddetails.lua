RaidGUIControlCardDetails = RaidGUIControlCardDetails or class(RaidGUIControl)
RaidGUIControlCardDetails.DEFAULT_WIDTH = 400
RaidGUIControlCardDetails.DEFAULT_HEIGHT = 255
RaidGUIControlCardDetails.CARD_WIDTH = 150
RaidGUIControlCardDetails.SCREEN_STATE_STARTING_MISSION_SERVER = "starting_mission_server"
RaidGUIControlCardDetails.SCREEN_STATE_STARTING_MISSION_CLIENT = "starting_mission_client"
RaidGUIControlCardDetails.SCREEN_STATE_EMPTY = "empty"
RaidGUIControlCardDetails.DESCRIPTION_RIGHT_TEXT_SIZE = 18
RaidGUIControlCardDetails.TITLE_RIGHT_PADDING_DOWN = 5
RaidGUIControlCardDetails.MODE_VIEW_ONLY = "mode_view_only"
RaidGUIControlCardDetails.MODE_SUGGESTING = "mode_suggesting"
RaidGUIControlCardDetails.EFFECT_DISTANCE = 16
RaidGUIControlCardDetails.FONT = tweak_data.gui.fonts.din_compressed

function RaidGUIControlCardDetails:init(parent, params)
	RaidGUIControlCardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlCardDetails:init] Parameters not specified for the card details")

		return
	end

	self._show_type = params.show_type == nil and true or params.show_type
	self._show_rarity = params.show_rarity == nil and true or params.show_rarity
	self._show_xp = params.show_xp == nil and true or params.show_xp
	self._crush_top_row = not self._show_type and not self._show_rarity and not self._show_xp
	self._info_padding = params.info_padding or 32
	self._pointer_type = "arrow"
	self._effects_list = {}

	self:highlight_off()
	self:_create_object()
	self:_create_card_details()
end

function RaidGUIControlCardDetails:close()
end

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

function RaidGUIControlCardDetails:_create_card_details()
	local card_params = {
		name = "player_loot_card",
		x = self._params.card_x or 0,
		y = self._params.card_y or 64,
		item_w = self._params.card_w or 496,
		item_h = self._params.card_h or 671
	}
	self._card_control = self._object:create_custom_control(RaidGUIControlCardBase, card_params)
	local x_spacing = self._card_control:w() + 32
	local params_card_description_right = {
		name = "card_description_label_right",
		wrap = true,
		text = "",
		visible = false,
		color = Color.white,
		layer = self._object:layer() + 1,
		font = tweak_data.gui.fonts.lato,
		font_size = RaidGUIControlLootCardDetails.DESCRIPTION_RIGHT_TEXT_SIZE
	}
	self._card_description_label_right = self._object:label(params_card_description_right)
	local icon_y = 8
	local label_y = icon_y + 64
	self._experience_bonus_count = self._object:label({
		h = 64,
		w = 160,
		text = "",
		align = "right",
		name = "experience_bonus_count",
		visible = false,
		x = x_spacing + 224,
		y = icon_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.title,
		color = tweak_data.gui.colors.raid_white
	})
	self._experience_bonus_label = self._object:label({
		h = 32,
		w = 160,
		align = "right",
		name = "experience_bonus_label",
		visible = false,
		x = x_spacing + 224,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		text = self:translate("challenge_cards_label_experience", true),
		color = tweak_data.gui.colors.raid_grey
	})
	local type_def_icon = tweak_data.challenge_cards.type_definition.card_type_raid.texture_gui
	self._type_icon = self._object:image({
		name = "type_icon",
		visible = false,
		x = x_spacing,
		y = icon_y,
		texture = type_def_icon.texture,
		texture_rect = type_def_icon.texture_rect
	})
	self._type_label = self._object:label({
		h = 32,
		w = 96,
		text = "",
		align = "center",
		name = "type_label",
		x = x_spacing,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		color = tweak_data.gui.colors.raid_grey
	})
	local rarity_def_icon = tweak_data.challenge_cards.rarity_definition.loot_rarity_common.texture_gui
	self._rarity_icon = self._object:image({
		name = "rarity_icon",
		visible = false,
		x = x_spacing + 128,
		y = icon_y,
		texture = rarity_def_icon.texture,
		texture_rect = rarity_def_icon.texture_rect
	})
	self._rarity_label = self._object:label({
		h = 32,
		w = 128,
		text = "",
		align = "center",
		name = "rarity_label",
		x = x_spacing + 96,
		y = label_y,
		font = RaidGUIControlCardDetails.FONT,
		font_size = tweak_data.gui.font_sizes.medium,
		color = tweak_data.gui.colors.raid_grey
	})
end

function RaidGUIControlCardDetails:set_card_details(card)
	self._card = type(card) == "string" and tweak_data.challenge_cards:get_card_by_key_name(card) or card

	if self._card then
		if self._show_rarity then
			local card_rarity = self._card.rarity
			local rarity_definitions_icon = tweak_data.challenge_cards.rarity_definition[card_rarity].texture_gui

			if rarity_definitions_icon then
				self._rarity_icon:set_image(rarity_definitions_icon.texture)
				self._rarity_icon:set_texture_rect(rarity_definitions_icon.texture_rect)
				self._rarity_icon:show()
			else
				self._rarity_icon:hide()
				Application:error("[RaidGUIControlCardDetails:set_card]", card, "is missing rarity icons!")
			end

			self._rarity_label:set_text(self:translate(card_rarity, true))
		else
			self._rarity_icon:hide()
		end

		if self._show_type then
			local card_type = self._card.card_type
			local type_definitions_icon = tweak_data.challenge_cards.type_definition[card_type].texture_gui

			if type_definitions_icon then
				self._type_icon:set_image(type_definitions_icon.texture)
				self._type_icon:set_texture_rect(type_definitions_icon.texture_rect)
				self._type_icon:show()
			else
				self._type_icon:hide()
				Application:error("[RaidGUIControlCardDetails:set_card]", card, "is missing type icons!")
			end

			self._type_label:set_text(self:translate(self._card.card_type, true))
		else
			self._type_icon:hide()
		end

		self._card_control:set_card(self._card, false)
		self._card_control:set_visible(true)

		if self._show_xp then
			local xp_label_value = managers.challenge_cards:get_card_xp_label(card, true)

			if xp_label_value and xp_label_value ~= "" then
				self._experience_bonus_count:set_text(xp_label_value)
				self._experience_bonus_count:set_visible(true)
				self._experience_bonus_label:set_visible(true)
			else
				self._experience_bonus_count:set_text("")
				self._experience_bonus_count:set_visible(false)
				self._experience_bonus_label:set_visible(false)
			end
		else
			self._experience_bonus_count:set_text("")
			self._experience_bonus_count:set_visible(false)
			self._experience_bonus_label:set_visible(false)
		end
	else
		self._card_control:set_visible(false)
		self._card_description_label_right:set_text("")
		self._experience_bonus_count:set_visible(false)
		self._experience_bonus_label:set_visible(false)
	end

	self:_recreate_card_effects(self._object)
end

function RaidGUIControlCardDetails:_recreate_card_effects(parent)
	for _, data in ipairs(self._effects_list) do
		for _, obj in pairs(data) do
			obj:hide()
		end
	end

	if not self._card then
		Application:warn("[RaidGUIControlCardDetails] No card data in details", self._card)

		return
	end

	local list_start_y = self._crush_top_row and 0 or 128
	local x_spacing = self._card_control:w() + self._info_padding
	local TEMP_DATA = {}

	if self._card.positive_description then
		table.insert(TEMP_DATA, {
			type = "positive_effect",
			name = self._card.positive_description.desc_id,
			value = self._card.positive_description.desc_params
		})
	end

	if self._card.negative_description then
		table.insert(TEMP_DATA, {
			type = "negative_effect",
			name = self._card.negative_description.desc_id,
			value = self._card.negative_description.desc_params
		})
	end

	for i, data in ipairs(TEMP_DATA) do
		local line_data = self._effects_list[i]

		if not line_data then
			local gui = tweak_data.gui:get_full_gui_data("ico_condition")
			local effect_icon = parent:image({
				w = 64,
				h = 64,
				name = "effect_icon_" .. tostring(i),
				x = x_spacing,
				y = list_start_y,
				texture = gui.texture,
				texture_rect = gui.texture_rect
			})
			local effect_label = parent:label({
				h = 64,
				align = "left",
				text = "ABC",
				wrap = true,
				vertical = "center",
				name = "effect_label_" .. tostring(i),
				x = effect_icon:right() + 8,
				y = list_start_y,
				w = parent:w() - (effect_icon:right() + 8),
				font = tweak_data.gui.fonts.lato,
				font_size = tweak_data.gui.font_sizes.size_20,
				color = tweak_data.gui.colors.raid_grey
			})
			line_data = {
				effect_icon = effect_icon,
				effect_label = effect_label
			}

			table.insert(self._effects_list, line_data)
		end

		for _, obj in pairs(line_data) do
			obj:show()
		end

		local gui = tweak_data.gui:get_full_gui_data(data.type == "positive_effect" and "ico_bonus" or "ico_malus")

		line_data.effect_icon:set_image(gui.texture, unpack(gui.texture_rect))
		line_data.effect_icon:set_texture_rect(gui.texture_rect)

		local loc_text = managers.localization:text(data.name, data.value or nil)

		line_data.effect_label:set_text(loc_text)

		local x, y, w, h = line_data.effect_label:text_rect()

		line_data.effect_label:set_h(math.max(h, 64))

		list_start_y = list_start_y + line_data.effect_label:h() + 8
	end

	Application:debug("[RaidGUIControlCardDetails] Done remade card details!")
end

function RaidGUIControlCardDetails:set_mode_layout()
	self._type_icon:set_center_x(self._type_label:center_x())
end

function RaidGUIControlCardDetails:get_card()
	return self._card
end

function RaidGUIControlCardDetails:set_control_mode(mode)
	self._mode = mode

	self:set_mode_layout()
end
