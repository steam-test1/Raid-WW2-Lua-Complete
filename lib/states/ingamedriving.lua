require("lib/states/GameState")

IngameDriving = IngameDriving or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameDriving:init(game_state_machine)
	IngameDriving.super.init(self, "ingame_driving", game_state_machine)
end

-- Lines 10-23
function IngameDriving:_update_driving_hud()
	local vehicle = managers.player:get_vehicle().vehicle_unit:vehicle()
	local vehicle_state = vehicle:get_state()
	local speed = vehicle_state:get_speed() * 3.6
	local rpm = vehicle_state:get_rpm()
	local gear = vehicle_state:get_gear() - 1

	if gear == 0 then
		gear = "N"
	elseif gear < 0 then
		gear = "R"
	end

	managers.hud:set_driving_vehicle_state(speed, rpm, gear)
end

-- Lines 25-53
function IngameDriving:at_enter(old_state, ...)
	print("IngameDriving:at_enter()")

	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	SoundDevice:set_rtpc("stamina", 100)

	self._old_state = old_state:name()

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 56-64
function IngameDriving:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
