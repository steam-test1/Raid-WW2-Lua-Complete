RaidGUIControlDialogTest = RaidGUIControlDialogTest or class(RaidGUIControl)

function RaidGUIControlDialogTest:init(parent, params)
	RaidGUIControlDialogTest.super.init(self, parent, params)

	self._yes_callback = self._params.yes_callback
	self._no_callback = self._params.no_callback
	self._object = self._panel:panel({
		w = nil,
		y = 0,
		x = 0,
		name = "dialog_panel",
		layer = nil,
		h = nil,
		w = self._panel:w(),
		h = self._panel:h(),
		layer = self._panel:layer() + 100
	})
	self._background = self._object:rect({
		w = nil,
		y = 0,
		x = 0,
		color = nil,
		name = "background",
		h = nil,
		w = self._object:w(),
		h = self._object:h(),
		color = tweak_data.gui.colors.raid_black:with_alpha(0.9)
	})
	local center_x, center_y = self._object:center()
	self._title_label = self._object:label({
		font_size = nil,
		align = "center",
		font = nil,
		text = nil,
		h = 32,
		w = 576,
		y = nil,
		x = nil,
		visible = false,
		name = "dialog_title",
		vertical = "center",
		x = center_x,
		y = center_y - 82,
		text = self:translate("character_creation_create_title", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.dialg_title
	})

	self._title_label:set_center_x(center_x)
	self._title_label:set_visible(true)

	self._input_box = self._object:input_field({
		w = 430,
		y = nil,
		x = nil,
		visible = false,
		name = "input_field",
		ws = nil,
		h = 48,
		x = center_x,
		y = center_y,
		ws = self._params.ws
	})

	self._input_box:set_center_x(center_x)
	self._input_box:set_center_y(center_y)
	self._input_box:set_visible(true)

	self._yes_button = self._object:short_primary_button({
		on_click_callback = nil,
		y = nil,
		x = nil,
		name = "yes_button",
		text = nil,
		x = center_x,
		y = center_y + 112,
		text = self:translate("yes", true),
		on_click_callback = self._yes_callback
	})

	self._yes_button:set_x(self._input_box:x())
	self._yes_button:set_visible(true)

	self._no_button = self._object:short_secondary_button({
		on_click_callback = nil,
		y = nil,
		x = nil,
		name = "no_button",
		text = nil,
		x = center_x,
		y = center_y + 112,
		text = self:translate("no", true),
		on_click_callback = self._no_callback
	})

	self._no_button:set_x(self._input_box:x() + self._input_box:w() - self._no_button:w())
	self._no_button:set_visible(true)
end

function RaidGUIControlDialogTest:get_new_profile_name()
	return self._input_box:get_text()
end

function RaidGUIControlDialogTest:confirm_pressed()
	return true
end
