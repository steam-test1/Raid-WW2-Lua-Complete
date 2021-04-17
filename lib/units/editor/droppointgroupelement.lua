DropPointGroupElement = DropPointGroupElement or class(MissionElement)

-- Lines 3-8
function DropPointGroupElement:init(unit)
	DropPointGroupElement.super.init(self, unit)

	self._hed.points = {}
	self._hed.execute_on_startup = true
end
