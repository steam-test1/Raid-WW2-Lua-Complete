HUDEquipment = HUDEquipment or class()
HUDEquipment.DEFAULT_W = 38
HUDEquipment.DEFAULT_H = 38
HUDEquipment.FONT = tweak_data.gui.fonts.din_compressed_outlined_20
HUDEquipment.FONT_SIZE = 20

-- Lines 9-20
function HUDEquipment:init(equipment_panel, icon, equipment_id, amount)
	self._id = equipment_id
	self._amount = 1

	self:_create_panel(equipment_panel, equipment_id)
	self:_create_icon(icon)
	self:_create_amount_text()

	if amount then
		self:set_amount(amount)
	end
end

-- Lines 22-29
function HUDEquipment:_create_panel(equipment_panel, equipment_id)
	local panel_params = {
		name = "equipment_" .. tostring(equipment_id) .. "_panel",
		w = HUDEquipment.DEFAULT_W,
		h = HUDEquipment.DEFAULT_H
	}
	self._object = equipment_panel:panel(panel_params)
end

-- Lines 31-41
function HUDEquipment:_create_icon(icon)
	local icon_params = {
		name = "icon",
		layer = 1,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)

	self._icon:set_bottom(self._object:h())
end

-- Lines 43-56
function HUDEquipment:_create_amount_text()
	local amount_text_params = {
		name = "amount_text",
		vertical = "top",
		align = "right",
		text = "",
		y = 0,
		x = 0,
		layer = 3,
		font = HUDEquipment.FONT,
		font_size = HUDEquipment.FONT_SIZE
	}
	self._amount_text = self._object:text(amount_text_params)

	self:_fit_amount_text()
end

-- Lines 58-68
function HUDEquipment:set_amount(amount)
	self._amount = amount

	self._amount_text:set_text(amount)
	self:_fit_amount_text()

	if amount > 1 then
		self._amount_text:set_alpha(1)
	else
		self._amount_text:set_alpha(0)
	end
end

-- Lines 70-77
function HUDEquipment:_fit_amount_text()
	local _, _, w, h = self._amount_text:text_rect()

	self._amount_text:set_w(w)
	self._amount_text:set_h(h)
	self._amount_text:set_right(self._object:w() - 1)
	self._amount_text:set_top(0)
end

-- Lines 79-81
function HUDEquipment:set_x(x)
	self._object:set_x(x)
end

-- Lines 83-85
function HUDEquipment:w()
	return self._object:w()
end

-- Lines 87-89
function HUDEquipment:id()
	return self._id
end

-- Lines 91-93
function HUDEquipment:amount()
	return self._amount
end

-- Lines 95-97
function HUDEquipment:destroy()
	self._object:clear()
end
