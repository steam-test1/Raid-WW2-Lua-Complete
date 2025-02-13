PlayerCharacterFilterElement = PlayerCharacterFilterElement or class(MissionElement)

function PlayerCharacterFilterElement:init(unit)
	PlayerCharacterFilterElement.super.init(self, unit)

	self._hed.character = tweak_data.criminals.character_nations[1]
	self._hed.use_instigator = false

	table.insert(self._save_values, "character")
	table.insert(self._save_values, "use_instigator")
end

function PlayerCharacterFilterElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "character", tweak_data.criminals.character_nations, "Select a character from the combobox")

	local use_instigator = EWS:CheckBox(panel, "Use Instigator", "")

	use_instigator:set_value(self._hed.use_instigator)
	use_instigator:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "use_instigator",
		ctrlr = use_instigator
	})
	panel_sizer:add(use_instigator, 0, 0, "EXPAND")
end
