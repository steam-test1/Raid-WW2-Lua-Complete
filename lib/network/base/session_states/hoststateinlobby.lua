HostStateInLobby = HostStateInLobby or class(HostStateBase)

-- Lines 4-10
function HostStateInLobby:on_join_request_received(data, peer_name, client_preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	local my_user_id = data.local_peer:user_id() or ""

	Application:debug("[HostStateInLobby][on_join_request_received peer_level] denying request for peer ", peer_name)
	self:_send_request_denied(sender, 3, my_user_id)
end

-- Lines 14-16
function HostStateInLobby:is_joinable(data)
	return false
end
