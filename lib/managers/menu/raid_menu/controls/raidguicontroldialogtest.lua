RaidGUIControlDialogTest = RaidGUIControlDialogTest or class(RaidGUIControl)

-- Lines 3-33
function RaidGUIControlDialogTest:init(parent, params)
	RaidGUIControlDialogTest.super.init(self, parent, params)

	self._yes_callback = self._params.yes_callback
	self._no_callback = self._params.no_callback
	self._object = self._panel:panel({
		name = "dialog_panel",
		y = 0,
		x = 0,
		w = self._panel:w(),
		h = self._panel:h(),
		layer = self._panel:layer() + 100
	})
	self._background = self._object:rect({
		name = "background",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = self._object:h(),
		color = tweak_data.gui.colors.raid_black:with_alpha(0.9)
	})
	local center_x, center_y = self._object:center()
	self._title_label = self._object:label({
		w = 576,
		name = "dialog_title",
		h = 32,
		vertical = "center",
		align = "center",
		visible = false,
		x = center_x,
		y = center_y - 82,
		text = self:translate("character_creation_create_title", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.dialg_title
	})

	self._title_label:set_center_x(center_x)
	self._title_label:set_visible(true)

	self._input_box = self._object:input_field({
		visible = false,
		name = "input_field",
		h = 48,
		w = 430,
		x = center_x,
		y = center_y,
		ws = self._params.ws
	})

	self._input_box:set_center_x(center_x)
	self._input_box:set_center_y(center_y)
	self._input_box:set_visible(true)

	self._yes_button = self._object:short_primary_button({
		name = "yes_button",
		x = center_x,
		y = center_y + 112,
		text = self:translate("yes", true),
		on_click_callback = self._yes_callback
	})

	self._yes_button:set_x(self._input_box:x())
	self._yes_button:set_visible(true)

	self._no_button = self._object:short_secondary_button({
		name = "no_button",
		x = center_x,
		y = center_y + 112,
		text = self:translate("no", true),
		on_click_callback = self._no_callback
	})

	self._no_button:set_x(self._input_box:x() + self._input_box:w() - self._no_button:w())
	self._no_button:set_visible(true)
end

-- Lines 35-37
function RaidGUIControlDialogTest:get_new_profile_name()
	return self._input_box:get_text()
end

-- Lines 39-41
function RaidGUIControlDialogTest:confirm_pressed()
	return true
end
