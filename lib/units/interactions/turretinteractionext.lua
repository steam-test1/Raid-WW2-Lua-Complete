TurretInteractionExt = TurretInteractionExt or class(UseInteractionExt)

function TurretInteractionExt:interact_distance(...)
	return TurretInteractionExt.super.interact_distance(self, ...)
end

function TurretInteractionExt:can_select(player)
	local super_condition = TurretInteractionExt.super.can_select(self, player)

	if not player then
		return false
	end

	return super_condition
end

function TurretInteractionExt:_interact_blocked(player)
	if self._unit:weapon():player_on() then
		return true, nil, "hud_action_mounting_turret_blocked_taken"
	end

	if self._unit:weapon():locked_fire() then
		return true, nil, "hud_action_mounting_turret_blocked_locked_fire"
	end

	if managers.player:is_carrying() then
		return true, nil, "hud_action_mounting_turret_blocked_bag"
	end

	if player:movement() and player:movement():running() then
		return true, nil, "hud_action_mounting_turret_blocked_sprint"
	end

	return false
end

function TurretInteractionExt:interact(player)
	TurretInteractionExt.super.super.interact(self, player)
	managers.player:use_turret(self._unit)
	managers.player:set_player_state("turret")
end

function TurretInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

function TurretInteractionExt:set_contour(color, opacity)
end
