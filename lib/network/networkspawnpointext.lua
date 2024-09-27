NetworkSpawnPointExt = NetworkSpawnPointExt or class()

function NetworkSpawnPointExt:init(unit)
	if managers.network then
		-- Nothing
	end
end

function NetworkSpawnPointExt:get_data(unit)
	return {
		rotation = nil,
		position = nil,
		position = unit:position(),
		rotation = unit:rotation()
	}
end

function NetworkSpawnPointExt:destroy(unit)
end
