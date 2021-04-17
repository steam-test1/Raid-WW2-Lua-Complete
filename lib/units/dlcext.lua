DLCExt = DLCExt or class()

-- Lines 3-11
function DLCExt:init(unit)
	self._unit = unit

	if Network:is_server() and self._sequence_dlc and managers.dlc:is_dlc_unlocked(self._sequence_dlc) and unit:damage() and unit:damage():has_sequence(self._sequence_name) then
		unit:damage():run_sequence_simple(self._sequence_name)
	end
end
