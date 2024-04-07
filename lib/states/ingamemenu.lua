require("lib/states/GameState")

IngameMenu = IngameMenu or class(IngamePlayerBaseState)

function IngameMenu:init(game_state_machine)
	IngameMenu.super.init(self, "ingame_menu", game_state_machine)
end

function IngameMenu:_setup_controller()
	self._controller = managers.controller:create_controller("ingame_menu", managers.controller:get_default_wrapper_index(), false)

	self._controller:set_enabled(true)
end

function IngameMenu:_clear_controller()
	if self._controller then
		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

function IngameMenu:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

function IngameMenu:exit()
	return
end

function IngameMenu:on_destroyed()
	return
end

function IngameMenu:update(t, dt)
	return
end

function IngameMenu:at_enter(old_state, params)
	self:_setup_controller()
end

function IngameMenu:at_exit()
	self:_clear_controller()
end

function IngameMenu:game_ended()
	return true
end
