RaidGUIControlCard = RaidGUIControlCard or class(RaidGUIControl)

function RaidGUIControlCard:init(parent, item_params, item_data, grid_params)
	RaidGUIControlCard.super.init(self, parent, item_params)

	self._item_data = item_data
	self._card_panel = self._panel:panel({
		name = "panel_card",
		x = item_params.x,
		y = item_params.y,
		w = item_params.w,
		h = item_params.h
	}, true)
	self._object = self._card_panel
	self._card_glow = self._card_panel:bitmap({
		name = "glow_texture",
		visible = false,
		y = -2,
		x = -2,
		w = self._card_panel:w() + 6,
		h = self._card_panel:h() + 5,
		color = Color.green,
		texture = tweak_data.challenge_cards.card_glow.texture,
		texture_rect = tweak_data.challenge_cards.card_glow.texture_rect
	})
	self._card_lock_glow = self._card_panel:bitmap({
		name = "glow_lock_texture",
		visible = false,
		y = -2,
		x = -2,
		w = self._card_panel:w() + 6,
		h = self._card_panel:h() + 5,
		color = tweak_data.menu.raid_red,
		texture = tweak_data.challenge_cards.card_glow.texture,
		texture_rect = tweak_data.challenge_cards.card_glow.texture_rect
	})

	if self._item_data then
		self._bitmap_card = self._card_panel:bitmap({
			name = "bitmap_card",
			w = item_params.w,
			h = item_params.h,
			texture = tweak_data.challenge_cards.rarity_definition[item_data.rarity].texture_path_thumb,
			texture_rect = tweak_data.challenge_cards.rarity_definition[item_data.rarity].texture_rect_thumb
		})
		self._xp_value = self._card_panel:label({
			wrap = true,
			name = "label_xp_value",
			font_size = 15,
			text = "$$$",
			h = 17,
			w = 33,
			y = 112,
			x = 5,
			font = tweak_data.menu.pd2_medium_font
		})
	end

	self:_create_border()

	self._selected = false
	self._locked = false

	if grid_params.on_click_callback then
		self._on_click_callback = grid_params.on_click_callback
	end

	self._object = self._card_panel
	self._name = "card_control"
end

function RaidGUIControlCard:_create_border()
	local border_thickness = 1.6
	self._border_left = self._card_panel:gradient({
		layer = 2,
		name = "border_left",
		orientation = "vertical",
		w = border_thickness,
		h = self._card_panel:h()
	})

	self._border_left:set_gradient_points({
		0,
		Color(0.19215686274509805, 0.23529411764705882, 0.25098039215686274),
		1,
		Color(0.3137254901960784, 0.40784313725490196, 0.35294117647058826)
	})

	self._border_right = self._card_panel:gradient({
		layer = 2,
		name = "border_right",
		orientation = "vertical",
		y = 0,
		x = self._card_panel:w() - border_thickness,
		w = border_thickness,
		h = self._card_panel:h()
	})

	self._border_right:set_gradient_points({
		0,
		Color(0.3058823529411765, 0.40784313725490196, 0.36470588235294116),
		1,
		Color(0.3411764705882353, 0.35294117647058826, 0.3176470588235294)
	})

	self._border_up = self._card_panel:gradient({
		layer = 2,
		name = "border_up",
		orientation = "horizontal",
		y = 0,
		x = 0,
		w = self._card_panel:w(),
		h = border_thickness
	})

	self._border_up:set_gradient_points({
		0,
		Color(0.19215686274509805, 0.23529411764705882, 0.25098039215686274),
		0.38,
		Color(0.34901960784313724, 0.34901960784313724, 0.3411764705882353),
		0.544,
		Color(0.596078431372549, 0.6274509803921569, 0.5843137254901961),
		0.77,
		Color(0.34901960784313724, 0.34901960784313724, 0.3411764705882353),
		1,
		Color(0.3058823529411765, 0.40784313725490196, 0.36470588235294116)
	})

	self._border_down = self._card_panel:gradient({
		layer = 2,
		name = "border_down",
		orientation = "horizontal",
		x = 0,
		y = self._card_panel:h() - border_thickness,
		w = self._card_panel:w(),
		h = border_thickness
	})

	self._border_down:set_gradient_points({
		0,
		Color(0.3137254901960784, 0.40784313725490196, 0.35294117647058826),
		0.3,
		Color(0.596078431372549, 0.615686274509804, 0.592156862745098),
		0.69,
		Color(0.6039215686274509, 0.615686274509804, 0.5882352941176471),
		1,
		Color(0.3411764705882353, 0.35294117647058826, 0.3176470588235294)
	})
end

function RaidGUIControlCard:mouse_released(o, button, x, y)
	self:on_mouse_released(button)

	return true
end

function RaidGUIControlCard:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(button, self, self._item_data)
	end
end

function RaidGUIControlCard:selected()
	return self._selected
end

function RaidGUIControlCard:select()
	self._selected = true

	if self._card_glow and alive(self._card_glow) and self._item_data then
		self._card_glow:show()
		self._card_lock_glow:hide()
	end
end

function RaidGUIControlCard:unselect()
	self._selected = false

	if self._card_glow and alive(self._card_glow) then
		self._card_glow:hide()
	end
end

function RaidGUIControlCard:locked()
	return self._locked
end

function RaidGUIControlCard:lock()
	self._locked = true

	if self._card_lock_glow and alive(self._card_lock_glow) and self._item_data then
		self._card_lock_glow:show()
		self._card_glow:hide()
	end
end

function RaidGUIControlCard:unlock()
	self._locked = false

	if self._card_lock_glow and alive(self._card_lock_glow) then
		self._card_lock_glow:hide()
	end
end
