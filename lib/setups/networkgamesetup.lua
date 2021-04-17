require("lib/setups/GameSetup")
require("lib/network/base/NetworkManager")

NetworkGameSetup = NetworkGameSetup or class(GameSetup)

-- Lines 7-10
function NetworkGameSetup:init_managers(managers)
	GameSetup.init_managers(self, managers)

	managers.network = NetworkManager:new()
end

-- Lines 12-16
function NetworkGameSetup:init_finalize()
	GameSetup.init_finalize(self)
	managers.network:init_finalize()
end

-- Lines 18-22
function NetworkGameSetup:update(t, dt)
	GameSetup.update(self, t, dt)
	managers.network:update(t, dt)
end

-- Lines 24-28
function NetworkGameSetup:paused_update(t, dt)
	GameSetup.paused_update(self, t, dt)
	managers.network:update(t, dt)
end

-- Lines 30-34
function NetworkGameSetup:end_update(t, dt)
	GameSetup.end_update(self, t, dt)
	managers.network:end_update()
end

-- Lines 36-40
function NetworkGameSetup:paused_end_update(t, dt)
	GameSetup.paused_end_update(self, t, dt)
	managers.network:end_update()
end

return NetworkGameSetup
