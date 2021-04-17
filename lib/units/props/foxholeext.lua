FoxholeExt = FoxholeExt or class()

-- Lines 3-6
function FoxholeExt:init(unit)
	self._player = nil
	self._locked = false
end

-- Lines 8-10
function FoxholeExt:register_player(player)
	self._player = player
end

-- Lines 12-14
function FoxholeExt:unregister_player()
	self._player = nil
end

-- Lines 16-18
function FoxholeExt:set_locked(locked)
	self._locked = locked
end

-- Lines 20-22
function FoxholeExt:locked()
	return self._locked
end

-- Lines 24-27
function FoxholeExt:release_player()
	self:set_locked(false)
	managers.player:set_player_state("standard")
end

-- Lines 29-31
function FoxholeExt:taken()
	return not not self._player
end

-- Lines 33-37
function FoxholeExt:save(data)
	data.foxhole = {
		player = self._player,
		locked = self._locked
	}
end

-- Lines 39-44
function FoxholeExt:load(data)
	if data.foxhole then
		self._player = data.foxhole.player
		self._locked = data.foxhole.locked
	end
end
