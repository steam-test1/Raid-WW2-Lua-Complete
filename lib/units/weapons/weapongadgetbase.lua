WeaponGadgetBase = WeaponGadgetBase or class(UnitBase)
WeaponGadgetBase.GADGET_TYPE = ""

-- Lines 4-7
function WeaponGadgetBase:init(unit)
	WeaponGadgetBase.super.init(self, unit)

	self._on = false
end

-- Lines 9-10
function WeaponGadgetBase:set_npc()
end

-- Lines 12-26
function WeaponGadgetBase:set_state(on, sound_source)
	if not self:is_bipod() then
		if self._on ~= on and sound_source and (self._on_event or self._off_event) then
			sound_source:post_event(on and self._on_event or self._off_event)
		end

		self._on = on
	end

	self:_check_state()
end

-- Lines 28-30
function WeaponGadgetBase:is_usable()
	return true
end

-- Lines 32-35
function WeaponGadgetBase:set_on()
	self._on = true

	self:_check_state()
end

-- Lines 37-40
function WeaponGadgetBase:set_off()
	self._on = false

	self:_check_state()
end

-- Lines 42-45
function WeaponGadgetBase:toggle()
	self._on = not self._on

	self:_check_state()
end

-- Lines 47-49
function WeaponGadgetBase:is_on()
	return self._on
end

-- Lines 51-53
function WeaponGadgetBase:toggle_requires_stance_update()
	return false
end

-- Lines 55-56
function WeaponGadgetBase:_check_state()
end

-- Lines 58-60
function WeaponGadgetBase:is_bipod()
	return false
end

-- Lines 64-66
function WeaponGadgetBase:destroy(unit)
	WeaponGadgetBase.super.pre_destroy(self, unit)
end
