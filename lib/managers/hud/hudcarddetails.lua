HUDCardDetails = HUDCardDetails or class()
HUDCardDetails.CARD_H = 234
HUDCardDetails.BONUS_ICON = "ico_bonus"
HUDCardDetails.BONUS_Y = 256
HUDCardDetails.BONUS_H = 64
HUDCardDetails.MALUS_ICON = "ico_malus"
HUDCardDetails.MALUS_Y = 332
HUDCardDetails.MALUS_H = 64
HUDCardDetails.EFFECT_DISTANCE = 12
HUDCardDetails.TEXT_X = 75
HUDCardDetails.TEXT_FONT = tweak_data.gui.fonts.lato
HUDCardDetails.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20

-- Lines 19-25
function HUDCardDetails:init(panel, params)
	self._params = params

	self:_create_panel(panel, params)
	self:_create_card()
	self:_create_bonus()
	self:_create_malus()
end

-- Lines 27-36
function HUDCardDetails:_create_panel(panel, params)
	local panel_params = {
		name = "card_details_panel",
		x = params.x or 0,
		y = params.y or 0,
		w = params.w or panel:w(),
		h = params.h or panel:h()
	}
	self._object = panel:panel(panel_params)
end

-- Lines 38-58
function HUDCardDetails:_create_card()
	local card_panel_params = {
		visible = true,
		name = "card_panel",
		y = 0,
		is_root_panel = true,
		x = 0,
		w = self._object:w(),
		h = HUDCardDetails.CARD_H
	}
	self._card_panel = RaidGUIPanel:new(self._object, card_panel_params)
	local card_params = {
		name = "card",
		panel = self._card_panel,
		card_image_params = {
			w = self._params.card_image_params.w,
			h = self._params.card_image_params.h
		}
	}
	self._card = self._card_panel:create_custom_control(RaidGUIControlCardBase, card_params)
end

-- Lines 60-90
function HUDCardDetails:_create_bonus()
	local bonus_panel_params = {
		name = "bonus_panel",
		x = 0,
		y = HUDCardDetails.BONUS_Y,
		w = self._object:w(),
		h = HUDCardDetails.BONUS_H
	}
	self._bonus_panel = self._object:panel(bonus_panel_params)
	local bonus_icon_params = {
		name = "bonus_icon",
		valign = "top",
		texture = tweak_data.gui.icons[HUDCardDetails.BONUS_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDCardDetails.BONUS_ICON].texture_rect
	}
	self._bonus_icon = self._bonus_panel:bitmap(bonus_icon_params)
	local bonus_text_params = {
		name = "bonus_text",
		wrap = true,
		align = "left",
		vertical = "top",
		text = "",
		y = 4,
		valign = "scale",
		x = HUDCardDetails.TEXT_X,
		w = self._bonus_panel:w() - HUDCardDetails.TEXT_X,
		h = self._bonus_panel:h() - 4,
		font = tweak_data.gui:get_font_path(HUDCardDetails.TEXT_FONT, HUDCardDetails.TEXT_FONT_SIZE),
		font_size = HUDCardDetails.TEXT_FONT_SIZE
	}
	self._bonus_text = self._bonus_panel:text(bonus_text_params)
end

-- Lines 92-122
function HUDCardDetails:_create_malus()
	local malus_panel_params = {
		name = "malus_panel",
		x = 0,
		y = HUDCardDetails.MALUS_Y,
		w = self._object:w(),
		h = HUDCardDetails.MALUS_H
	}
	self._malus_panel = self._object:panel(malus_panel_params)
	local malus_icon_params = {
		name = "malus_icon",
		valign = "top",
		texture = tweak_data.gui.icons[HUDCardDetails.MALUS_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDCardDetails.MALUS_ICON].texture_rect
	}
	self._malus_icon = self._malus_panel:bitmap(malus_icon_params)
	local malus_text_params = {
		name = "malus_text",
		wrap = true,
		align = "left",
		vertical = "top",
		text = "",
		y = 4,
		valign = "scale",
		x = HUDCardDetails.TEXT_X,
		w = self._malus_panel:w() - HUDCardDetails.TEXT_X,
		h = self._malus_panel:h() - 4,
		font = tweak_data.gui:get_font_path(HUDCardDetails.TEXT_FONT, HUDCardDetails.TEXT_FONT_SIZE),
		font_size = HUDCardDetails.TEXT_FONT_SIZE
	}
	self._malus_text = self._malus_panel:text(malus_text_params)
end

-- Lines 124-160
function HUDCardDetails:set_card(card)
	self._card:set_card(card)

	if card and card.effects then
		local bonus_description, malus_description = managers.challenge_cards:get_card_description(card.key_name)

		self._bonus_text:set_text(bonus_description)
		self._malus_text:set_text(malus_description)

		local effect_y = HUDCardDetails.BONUS_Y

		if bonus_description == "" then
			self._bonus_icon:hide()
		else
			self._bonus_icon:show()

			local _, _, _, h = self._bonus_text:text_rect()

			self._bonus_text:set_h(h)
			self._bonus_panel:set_y(effect_y)
			self._bonus_panel:set_h(math.max(self._bonus_text:h(), self._bonus_icon:h()))

			effect_y = effect_y + self._bonus_panel:h() + HUDCardDetails.EFFECT_DISTANCE
		end

		if malus_description == "" then
			self._malus_icon:hide()
		else
			self._malus_icon:show()

			local _, _, _, h = self._malus_text:text_rect()

			self._malus_text:set_h(h)
			self._malus_panel:set_y(effect_y)
			self._malus_panel:set_h(math.max(self._malus_text:h(), self._malus_icon:h()))
		end
	end
end
