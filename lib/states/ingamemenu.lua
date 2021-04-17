require("lib/states/GameState")

IngameMenu = IngameMenu or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameMenu:init(game_state_machine)
	IngameMenu.super.init(self, "ingame_menu", game_state_machine)
end

-- Lines 9-12
function IngameMenu:_setup_controller()
	self._controller = managers.controller:create_controller("ingame_menu", managers.controller:get_default_wrapper_index(), false)

	self._controller:set_enabled(true)
end

-- Lines 16-22
function IngameMenu:_clear_controller()
	if self._controller then
		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

-- Lines 24-28
function IngameMenu:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

-- Lines 30-32
function IngameMenu:exit()
end

-- Lines 34-35
function IngameMenu:on_destroyed()
end

-- Lines 37-38
function IngameMenu:update(t, dt)
end

-- Lines 40-48
function IngameMenu:at_enter(old_state, params)
	self:_setup_controller()
end

-- Lines 50-55
function IngameMenu:at_exit()
	self:_clear_controller()
end

-- Lines 58-60
function IngameMenu:game_ended()
	return true
end
