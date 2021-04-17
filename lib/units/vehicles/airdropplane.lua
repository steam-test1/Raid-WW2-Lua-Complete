AirDropPlane = AirDropPlane or class(UnitBase)

-- Lines 3-8
function AirDropPlane:init(unit)
	AirDropPlane.super.init(self, unit, false)

	self._unit = unit
	self._body_name = self._body_name or "a_body"
end

-- Lines 10-12
function AirDropPlane:set_drop_unit(unit)
	self._drop_unit = unit
end

-- Lines 14-16
function AirDropPlane:spawn_pod()
	managers.airdrop:spawn_pod(self._drop_unit, self._unit)
end
