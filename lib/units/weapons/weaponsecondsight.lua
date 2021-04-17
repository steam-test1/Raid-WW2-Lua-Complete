WeaponSecondSight = WeaponSecondSight or class(WeaponGadgetBase)
WeaponSecondSight.GADGET_TYPE = "second_sight"

-- Lines 4-9
function WeaponSecondSight:init(unit)
	WeaponSecondSight.super.init(self, unit)
end

-- Lines 13-15
function WeaponSecondSight:_check_state(...)
	WeaponSecondSight.super._check_state(self, ...)
end

-- Lines 17-19
function WeaponSecondSight:toggle_requires_stance_update()
	return true
end

-- Lines 23-25
function WeaponSecondSight:destroy(unit)
	WeaponSecondSight.super.destroy(self, unit)
end
