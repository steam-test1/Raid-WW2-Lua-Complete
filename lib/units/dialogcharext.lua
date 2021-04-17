DialogCharExt = DialogCharExt or class()

-- Lines 3-7
function DialogCharExt:init(unit)
	self._unit = unit

	managers.dialog:register_character(self.character, self._unit)
end
