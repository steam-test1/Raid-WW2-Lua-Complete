AirDropPlane = AirDropPlane or class(UnitBase)

function AirDropPlane:init(unit)
	AirDropPlane.super.init(self, unit, false)

	self._unit = unit
	self._body_name = self._body_name or "a_body"
end

function AirDropPlane:set_drop_unit(unit)
	self._drop_unit = unit
end

function AirDropPlane:spawn_pod()
	managers.airdrop:server_spawn_pod(self._drop_unit, self._unit)
end
