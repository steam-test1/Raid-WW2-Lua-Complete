FoxholeExt = FoxholeExt or class()

function FoxholeExt:init(unit)
	self._player = nil
	self._locked = false
end

function FoxholeExt:register_player(player)
	self._player = player
end

function FoxholeExt:unregister_player()
	self._player = nil
end

function FoxholeExt:set_locked(locked)
	self._locked = locked
end

function FoxholeExt:locked()
	return self._locked
end

function FoxholeExt:release_player()
	self:set_locked(false)
	managers.player:set_player_state("standard")
end

function FoxholeExt:taken()
	return not not self._player
end

function FoxholeExt:save(data)
	data.foxhole = {}
	data.foxhole.player = self._player
	data.foxhole.locked = self._locked
end

function FoxholeExt:load(data)
	if data.foxhole then
		self._player = data.foxhole.player
		self._locked = data.foxhole.locked
	end
end
