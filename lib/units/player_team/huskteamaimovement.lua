HuskTeamAIMovement = HuskTeamAIMovement or class(TeamAIMovement)

-- Lines 3-8
function HuskTeamAIMovement:init(unit)
	HuskTeamAIMovement.super.init(self, unit)

	self._queued_actions = {}
	self._m_host_stop_pos = mvector3.copy(self._m_pos)
end

-- Lines 12-17
function HuskTeamAIMovement:_post_init()
	if managers.groupai:state():whisper_mode() then
		self._unit:base():set_slot(self._unit, 24)
	end

	self:play_redirect("idle")
end

-- Lines 21-26
function HuskTeamAIMovement:sync_arrested()
	self._unit:interaction():set_tweak_data("free")
	self._unit:interaction():set_active(true, false)
	self._unit:base():set_slot(self._unit, 24)
end

-- Lines 30-33
function HuskTeamAIMovement:_upd_actions(t)
	TeamAIMovement._upd_actions(self, t)
	HuskCopMovement._chk_start_queued_action(self)
end

-- Lines 37-39
function HuskTeamAIMovement:action_request(action_desc)
	return HuskCopMovement.action_request(self, action_desc)
end

-- Lines 43-45
function HuskTeamAIMovement:chk_action_forbidden(action_desc)
	return HuskCopMovement.chk_action_forbidden(self, action_desc)
end
