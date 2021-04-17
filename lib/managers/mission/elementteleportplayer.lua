core:import("CoreMissionScriptElement")

ElementTeleportPlayer = ElementTeleportPlayer or class(CoreMissionScriptElement.MissionScriptElement)
ElementTeleportPlayer.PEER_OFFSETS = {
	0,
	1,
	-1,
	2
}

-- Lines 11-13
function ElementTeleportPlayer:init(...)
	ElementTeleportPlayer.super.init(self, ...)
end

-- Lines 16-18
function ElementTeleportPlayer:value(name)
	return self._values[name]
end

-- Lines 20-26
function ElementTeleportPlayer:get_spawn_position()
	local peer_id = managers.network:session():local_peer():id()
	local position = self._values.position
	local x = self._values.rotation:x()
	position = position + ElementTeleportPlayer.PEER_OFFSETS[peer_id] * x * 100

	return position
end

-- Lines 28-39
function ElementTeleportPlayer:client_on_executed(...)
	if not self._values.enabled then
		return
	end

	if not managers.player:local_player() then
		return
	end

	local position = self:get_spawn_position()

	managers.player:warp_to(position, self._values.rotation)
	managers.player:set_player_state(self._values.state or managers.player:current_state())
	managers.menu:hide_loading_screen()
end

-- Lines 41-64
function ElementTeleportPlayer:on_executed(instigator)
	Application:debug("[ElementTeleportPlayer:on_executed]", self._sync_id)

	if not self._values.enabled then
		return
	end

	if not managers.player:local_player() then
		return
	end

	local position = self:get_spawn_position()

	managers.player:warp_to(position, self._values.rotation)
	managers.player:set_player_state(self._values.state or managers.player:current_state())
	managers.menu:hide_loading_screen()
	managers.groupai:state():on_player_spawn_state_set(self._values.state or managers.player:default_player_state())
	ElementTeleportPlayer.super.on_executed(self, self._unit or instigator)
end

-- Lines 66-69
function ElementTeleportPlayer:_spawnt_team_ai()
	managers.worldcollection.team_ai_transition = false

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed(true)
end
