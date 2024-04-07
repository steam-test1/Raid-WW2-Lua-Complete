WeaponGadgetBase = WeaponGadgetBase or class(UnitBase)
WeaponGadgetBase.GADGET_TYPE = ""

function WeaponGadgetBase:init(unit)
	WeaponGadgetBase.super.init(self, unit)

	self._on = false
end

function WeaponGadgetBase:set_npc()
	return
end

function WeaponGadgetBase:set_state(on, sound_source)
	if not self:is_bipod() then
		if self._on ~= on and sound_source and (self._on_event or self._off_event) then
			sound_source:post_event(on and self._on_event or self._off_event)
		end

		self._on = on
	end

	self:_check_state()
end

function WeaponGadgetBase:is_usable()
	return true
end

function WeaponGadgetBase:set_on()
	self._on = true

	self:_check_state()
end

function WeaponGadgetBase:set_off()
	self._on = false

	self:_check_state()
end

function WeaponGadgetBase:toggle()
	self._on = not self._on

	self:_check_state()
end

function WeaponGadgetBase:is_on()
	return self._on
end

function WeaponGadgetBase:toggle_requires_stance_update()
	return false
end

function WeaponGadgetBase:_check_state()
	return
end

function WeaponGadgetBase:is_bipod()
	return false
end

function WeaponGadgetBase:destroy(unit)
	WeaponGadgetBase.super.pre_destroy(self, unit)
end
