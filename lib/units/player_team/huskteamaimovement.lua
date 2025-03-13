HuskTeamAIMovement = HuskTeamAIMovement or class(TeamAIMovement)

function HuskTeamAIMovement:init(unit)
	HuskTeamAIMovement.super.init(self, unit)

	self._queued_actions = {}
	self._m_host_stop_pos = mvector3.copy(self._m_pos)
end

function HuskTeamAIMovement:_post_init()
	if managers.groupai:state():whisper_mode() then
		self._unit:base():set_slot(self._unit, 24)
	end

	self:play_redirect("idle")
end

function HuskTeamAIMovement:_upd_actions(t)
	TeamAIMovement._upd_actions(self, t)
	HuskCopMovement._chk_start_queued_action(self)
end

function HuskTeamAIMovement:load(data)
	HuskTeamAIMovement.super.load(self, data)

	if self._unit:customization() and data.movement and data.movement.customization then
		local customization = managers.blackmarket:unpack_team_ai_customization_from_string(data.movement.customization)

		self:set_character_customization(customization)
	end
end

function HuskTeamAIMovement:action_request(action_desc)
	return HuskCopMovement.action_request(self, action_desc)
end

function HuskTeamAIMovement:chk_action_forbidden(action_desc)
	return HuskCopMovement.chk_action_forbidden(self, action_desc)
end
