ConnectionNetworkHandler = ConnectionNetworkHandler or class(BaseNetworkHandler)

function ConnectionNetworkHandler:server_up(sender)
	if not self._verify_in_session() or Application:editor() then
		return
	end

	managers.network:session():on_server_up_received(sender)
end

function ConnectionNetworkHandler:request_host_discover_reply(sender)
	if not self._verify_in_server_session() then
		return
	end

	managers.network:on_discover_host_received(sender)
end

function ConnectionNetworkHandler:discover_host(sender)
	if not self._verify_in_server_session() or Application:editor() then
		return
	end

	managers.network:on_discover_host_received(sender)
end

function ConnectionNetworkHandler:discover_host_reply(sender_name, level_id, level_name, my_ip, state, difficulty, sender)
	if not self._verify_in_client_session() then
		return
	end

	if level_name == "" then
		level_name = tweak_data.levels:get_world_name_from_index(level_id)

		if not level_name then
			cat_print("multiplayer_base", "[ConnectionNetworkHandler:discover_host_reply] Ignoring host", sender_name, ". I do not have this level in my revision.")

			return
		end
	end

	managers.network:on_discover_host_reply(sender, sender_name, level_name, my_ip, state, difficulty)
end

function ConnectionNetworkHandler:request_join(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
	if not self._verify_in_server_session() then
		return
	end

	managers.network:session():on_join_request_received(peer_name, preferred_character, dlcs, xuid, peer_level, gameversion, join_attempt_identifier, auth_ticket, sender)
end

function ConnectionNetworkHandler:join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
	print(" 1 ConnectionNetworkHandler:join_request_reply", reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)

	if not self._verify_in_client_session() then
		return
	end

	managers.network:session():on_join_request_reply(reply_id, my_peer_id, my_character, level_index, difficulty_index, state, server_character, user_id, mission, job_id_index, job_stage, alternative_job_stage, interupt_job_stage_level_index, xuid, auth_ticket, sender)
end

function ConnectionNetworkHandler:peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
	print(" 1 ConnectionNetworkHandler:peer_handshake", name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)

	if not self._verify_in_client_session() then
		return
	end

	print(" 2 ConnectionNetworkHandler:peer_handshake")
	managers.network:session():peer_handshake(name, peer_id, ip, in_lobby, loading, synched, character, slot, mask_set, xuid, xnaddr)
end

function ConnectionNetworkHandler:request_player_name(sender)
	if not self._verify_sender(sender) then
		return
	end

	local name = managers.network:session():local_peer():name()

	sender:request_player_name_reply(name)
end

function ConnectionNetworkHandler:request_player_name_reply(name, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	sender_peer:set_name(name)
end

function ConnectionNetworkHandler:peer_exchange_info(peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	if self._verify_in_client_session() then
		if sender_peer:id() == 1 then
			managers.network:session():on_peer_requested_info(peer_id)
		elseif peer_id == sender_peer:id() then
			managers.network:session():send_to_host("peer_exchange_info", peer_id)
		end
	elseif self._verify_in_server_session() then
		managers.network:session():on_peer_connection_established(sender_peer, peer_id)
	end
end

function ConnectionNetworkHandler:connection_established(peer_id, sender)
	if not self._verify_in_server_session() then
		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_peer_connection_established(sender_peer, peer_id)
end

function ConnectionNetworkHandler:mutual_connection(other_peer_id)
	print("[ConnectionNetworkHandler:mutual_connection]", other_peer_id)

	if not self._verify_in_client_session() then
		return
	end

	managers.network:session():on_mutual_connection(other_peer_id)
end

function ConnectionNetworkHandler:kick_peer(peer_id, message_id, sender)
	if not self._verify_sender(sender) then
		return
	end

	sender:remove_peer_confirmation(peer_id)

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		print("[ConnectionNetworkHandler:kick_peer] unknown peer", peer_id)

		return
	end

	managers.network:session():on_peer_kicked(peer, peer_id, message_id)
end

function ConnectionNetworkHandler:remove_peer_confirmation(removed_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_remove_peer_confirmation(sender_peer, removed_peer_id)
end

function ConnectionNetworkHandler:set_loading_state(state, load_counter, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():set_peer_loading_state(peer, state, load_counter)
end

function ConnectionNetworkHandler:set_peer_synched(id, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.network:session():on_peer_synched(id)
end

function ConnectionNetworkHandler:set_dropin()
	managers.network:session():local_peer():set_drop_in(true)

	if game_state_machine:current_state().set_dropin then
		game_state_machine:current_state():set_dropin(managers.network:session():local_peer():character())
	end
end

function ConnectionNetworkHandler:spawn_dropin_penalty(dead, bleed_out, health, used_deployable)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	managers.player:spawn_dropin_penalty(dead, bleed_out, health, used_deployable)
	managers.player:set_player_state("standard")
end

function ConnectionNetworkHandler:ok_to_load_level(load_counter, sender)
	print("[ConnectionNetworkHandler:ok_to_load_level]", load_counter)

	if not self:_verify_in_client_session() then
		return
	end

	managers.network:session():ok_to_load_level(load_counter)
end

function ConnectionNetworkHandler:ok_to_load_lobby(load_counter, sender)
	print("[ConnectionNetworkHandler:ok_to_load_lobby]", load_counter)

	if not self:_verify_in_client_session() then
		return
	end

	managers.network:session():ok_to_load_lobby(load_counter)
end

function ConnectionNetworkHandler:set_peer_left(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():on_peer_left(peer, peer:id())
end

function ConnectionNetworkHandler:set_menu_sync_state_index(index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if managers.menu then
		managers.menu:set_peer_sync_state_index(peer:id(), index)
	end
end

function ConnectionNetworkHandler:entered_lobby_confirmation(peer_id)
	managers.network:session():on_entered_lobby_confirmation(peer_id)
end

function ConnectionNetworkHandler:set_peer_entered_lobby(sender)
	if not self._verify_in_session() then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.network:session():on_peer_entered_lobby(peer)
end

function ConnectionNetworkHandler:sync_game_settings(job_index, level_id_index, difficulty_index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local job_id = tweak_data.operations:get_raid_name_from_index(job_index)
	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	local difficulty = tweak_data:index_to_difficulty(difficulty_index)
	Global.game_settings.level_id = level_id
	Global.game_settings.mission = managers.raid_job:current_job()
	Global.game_settings.world_setting = nil

	tweak_data:set_difficulty(difficulty)
	peer:verify_job(job_id)
	managers.raid_job:on_mission_started()

	if managers.menu_component then
		managers.menu_component:on_job_updated()
	end
end

function ConnectionNetworkHandler:sync_stage_settings(level_id_index, stage_num, alternative_stage, interupt_stage_level_id, sender)
	print("ConnectionNetworkHandler:sync_stage_settings", level_id_index, stage_num, alternative_stage, interupt_stage_level_id)

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	Global.game_settings.level_id = level_id
	Global.game_settings.mission = managers.raid_job:current_job()
	Global.game_settings.world_setting = nil
end

function ConnectionNetworkHandler:sync_raid_job_on_restart_to_camp(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.raid_job:synced_on_restart_to_camp()
end

function ConnectionNetworkHandler:sync_challenge_cards_on_restart_to_camp(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.challenge_cards:sync_challenge_cards_on_restart_to_camp()
end

function ConnectionNetworkHandler:sync_on_restart_mission(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end
end

function ConnectionNetworkHandler:sync_selected_raid_objective(obj_id, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	Application:debug("[ConnectionNetworkHandler:sync_selected_raid_objective] obj_id", obj_id)
	managers.raid_job:sync_goto_job_objective(obj_id)
end

function ConnectionNetworkHandler:lobby_sync_update_level_id(level_id_index)
	local level_id = tweak_data.levels:get_level_name_from_index(level_id_index)
	local lobby_menu = managers.menu:get_menu("lobby_menu")

	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:sync_update_level_id(level_id)
	end
end

function ConnectionNetworkHandler:lobby_sync_update_difficulty(difficulty)
	local lobby_menu = managers.menu:get_menu("lobby_menu")

	if lobby_menu and lobby_menu.renderer:is_open() then
		lobby_menu.renderer:sync_update_difficulty(difficulty)
	end
end

function ConnectionNetworkHandler:lobby_info(level, character, mask_set, sender)
	local peer = self._verify_sender(sender)

	print("ConnectionNetworkHandler:lobby_info", peer and peer:id(), level)
	print("  IS THIS AN OK PEER?", peer and peer:id())

	if peer then
		peer:set_level(level)

		local lobby_menu = managers.menu:get_menu("lobby_menu")

		if lobby_menu and lobby_menu.renderer:is_open() then
			lobby_menu.renderer:_set_player_slot(peer:id(), {
				name = peer:name(),
				peer_id = peer:id(),
				level = level,
				character = character
			})
		end
	end
end

function ConnectionNetworkHandler:begin_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():begin_trade()
end

function ConnectionNetworkHandler:cancel_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():cancel_trade()
end

function ConnectionNetworkHandler:finish_trade()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_respawn) then
		return
	end

	game_state_machine:current_state():finish_trade()
end

function ConnectionNetworkHandler:request_spawn_member(sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	IngameWaitingForRespawnState.request_player_spawn(peer:id())
end

function ConnectionNetworkHandler:warn_about_civilian_free(i)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_warn_about_civilian_free(i)
end

function ConnectionNetworkHandler:request_drop_in_pause(peer_id, nickname, state, sender)
	managers.network:session():on_drop_in_pause_request_received(peer_id, nickname, state)
end

function ConnectionNetworkHandler:drop_in_pause_confirmation(dropin_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_drop_in_pause_confirmation_received(dropin_peer_id, sender_peer)
end

function ConnectionNetworkHandler:leave_ready_up_menu(sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.raid_menu:close_all_menus()
	managers.challenge_cards:remove_suggested_challenge_card()
end

function ConnectionNetworkHandler:report_dead_connection(other_peer_id, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.network:session():on_dead_connection_reported(sender_peer:id(), other_peer_id)
end

function ConnectionNetworkHandler:sanity_check_network_status(sender)
	if not self._verify_in_server_session() then
		sender:sanity_check_network_status_reply()

		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		sender:sanity_check_network_status_reply()

		return
	end
end

function ConnectionNetworkHandler:sanity_check_network_status_reply(sender)
	if not self._verify_in_client_session() then
		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local session = managers.network:session()

	if sender_peer ~= session:server_peer() then
		return
	end

	if session:is_expecting_sanity_chk_reply() then
		print("[ConnectionNetworkHandler:sanity_check_network_status_reply]")
		managers.network:session():on_peer_lost(sender_peer, sender_peer:id())
	end
end

function ConnectionNetworkHandler:dropin_progress(dropin_peer_id, progress_percentage, sender)
	if not self._verify_in_client_session() or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local session = managers.network:session()
	local dropin_peer = session:peer(dropin_peer_id)

	if not dropin_peer or dropin_peer_id == session:local_peer():id() then
		return
	end

	session:on_dropin_progress_received(dropin_peer_id, progress_percentage)
end

function ConnectionNetworkHandler:set_member_ready(peer_id, ready, mode, outfit_versions_str, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return
	end

	if mode == 1 then
		if ready ~= 0 then
			ready = true
		else
			ready = false
		end

		local ready_state = peer:waiting_for_player_ready()

		peer:set_waiting_for_player_ready(ready)
		managers.network:session():on_set_member_ready(peer_id, ready, ready_state ~= ready, true)

		if Network:is_server() then
			managers.network:session():send_to_peers_loaded_except(peer_id, "set_member_ready", peer_id, ready and 1 or 0, 1, "")
		end
	elseif mode == 2 then
		peer:set_streaming_status(ready)
		managers.network:session():on_streaming_progress_received(peer, ready)
	elseif mode == 3 then
		if Network:is_server() then
			managers.network:session():on_peer_finished_loading_outfit(peer, ready, outfit_versions_str)
		end
	elseif mode == 4 then
		if Network:is_client() and peer == managers.network:session():server_peer() then
			managers.network:session():notify_host_when_outfits_loaded(ready, outfit_versions_str)
		end
	elseif mode == 5 then
		peer.ready_for_dropin_spawn = true
	end
end

function ConnectionNetworkHandler:send_chat_message(channel_id, message, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	print("send_chat_message peer", peer, peer:id())
	managers.chat:receive_message_by_peer(channel_id, peer, message)
end

function ConnectionNetworkHandler:sync_outfit(outfit_string, outfit_version, outfit_signature, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	print("[ConnectionNetworkHandler:sync_outfit]", "peer_id", peer:id(), "outfit_string", outfit_string, "outfit_version", outfit_version)

	outfit_string, outfit_version, outfit_signature = peer:set_outfit_string(outfit_string, outfit_version, outfit_signature)

	if managers.network:session():is_host() then
		managers.network:session():chk_request_peer_outfit_load_status()
	end

	local local_peer = managers.network:session() and managers.network:session():local_peer()
	local in_lobby = local_peer and local_peer:in_lobby() and game_state_machine:current_state_name() ~= "ingame_lobby_menu" and not setup:is_unloading()

	if managers.menu_component then
		managers.menu_component:peer_outfit_updated(peer:id())
	end
end

function ConnectionNetworkHandler:sync_profile(level, class, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	peer:set_profile(level)
	peer:set_class(class)
end

function ConnectionNetworkHandler:steam_p2p_ping(sender)
	print("[ConnectionNetworkHandler:steam_p2p_ping] from", sender:ip_at_index(0), sender:protocol_at_index(0))

	local session = managers.network:session()

	if not session or session:closing() then
		print("[ConnectionNetworkHandler:steam_p2p_ping] no session or closing")

		return
	end

	session:on_steam_p2p_ping(sender)
end

function ConnectionNetworkHandler:re_open_lobby_request(state, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		sender:re_open_lobby_reply(false)

		return
	end

	local session = managers.network:session()

	if session:closing() then
		sender:re_open_lobby_reply(false)

		return
	end

	session:on_re_open_lobby_request(peer, state)
end

function ConnectionNetworkHandler:re_open_lobby_reply(status, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local session = managers.network:session()

	if session:closing() then
		return
	end

	managers.network.matchmake:from_host_lobby_re_opened(status)
end

function ConnectionNetworkHandler:sync_explode_bullet(position, normal, damage, peer_id_or_selection_index, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if InstantExplosiveBulletBase then
		if false then
			local user_unit = managers.criminals and managers.criminals:character_unit_by_peer_id(peer:id())

			if alive(user_unit) then
				local weapon_unit = user_unit:inventory():unit_by_selection(peer_id_or_selection_index)

				if alive(weapon_unit) then
					InstantExplosiveBulletBase:on_collision_server(position, normal, damage / 163.84, user_unit, weapon_unit, peer:id(), peer_id_or_selection_index)
				end
			end
		else
			InstantExplosiveBulletBase:on_collision_client(position, normal, damage / 163.84, managers.criminals and managers.criminals:character_unit_by_peer_id(peer_id_or_selection_index))
		end
	end
end

function ConnectionNetworkHandler:sync_flame_bullet(position, normal, damage, peer_id_or_selection_index, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if FlameBulletBase then
		if Network:is_server() then
			local user_unit = managers.criminals and managers.criminals:character_unit_by_peer_id(peer:id())

			if alive(user_unit) then
				local weapon_unit = user_unit:inventory():unit_by_selection(peer_id_or_selection_index)

				if alive(weapon_unit) then
					FlameBulletBase:on_collision_server(position, normal, damage / 163.84, user_unit, weapon_unit, peer:id(), peer_id_or_selection_index)
				end
			end
		else
			FlameBulletBase:on_collision_client(position, normal, damage / 163.84, managers.criminals and managers.criminals:character_unit_by_peer_id(peer_id_or_selection_index))
		end
	end
end

function ConnectionNetworkHandler:sync_explosion_results(count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, selection_index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local player = managers.player:local_player()
	local weapon_unit = alive(player) and player:inventory():unit_by_selection(selection_index)

	if alive(weapon_unit) then
		local enemies_hit = (count_gangsters or 0) + (count_cops or 0)
		local enemies_killed = (count_gangster_kills or 0) + (count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		if enemies_hit > 0 then
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end
	end
end

function ConnectionNetworkHandler:sync_fire_results(count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, selection_index, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local player = managers.player:local_player()
	local weapon_unit = alive(player) and player:inventory():unit_by_selection(selection_index)

	if alive(weapon_unit) then
		local enemies_hit = (count_gangsters or 0) + (count_cops or 0)
		local enemies_killed = (count_gangster_kills or 0) + (count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		if enemies_hit > 0 then
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil
	end
end

function ConnectionNetworkHandler:voting_data(type, value, result, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.vote:network_package(type, value, result, peer:id())
end

ConnectionNetworkHandler._SYNC_AWARD_ACHIEVEMENT_ALLOWED = {
	"ach_kill_enemies_with_single_grenade_5",
	"landmines_kill_some",
	"ach_all_players_go_to_bleedout"
}

function ConnectionNetworkHandler:sync_award_achievement(achievement_id, sender)
	if ConnectionNetworkHandler._SYNC_AWARD_ACHIEVEMENT_ALLOWED[achievement_id] then
		managers.achievment:award(achievement_id)
	else
		Application:warn("[ConnectionNetworkHandler:sync_award_achievement()] Someone tried to send you an achievement that isnt allowed!!!", achievement_id, sender)
	end
end

function ConnectionNetworkHandler:propagate_alert(type, position, range, filter, aggressor, head_position, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.groupai:state():propagate_alert({
		type,
		position,
		range,
		filter,
		aggressor,
		head_position
	})
end

function ConnectionNetworkHandler:set_auto_assault_ai_trade(character_name, time)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_set_auto_assault_ai_trade(character_name, time)
end

function ConnectionNetworkHandler:sync_prepare_world(world_id, peer, stage, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.worldcollection:sync_world_prepared(world_id, peer, stage)
end

function ConnectionNetworkHandler:send_loaded_packages(package, count, sender)
	if not self._verify_in_client_session() then
		Application:error("[ConnectionNetworkHandler:send_loaded_packages] Not session, recieving failed!")

		return
	end

	Global.game_settings.packages_packed = Global.game_settings.packages_packed or {}

	table.insert(Global.game_settings.packages_packed, {
		package = package,
		count = count
	})
end

function ConnectionNetworkHandler:sync_secured_bounty(bars, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.greed:sync_secured_bounty(bars)
end

function ConnectionNetworkHandler:spawn_loot(tweak_table, position, yaw, pitch, roll, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.drop_loot:drop_item(tweak_table, position, Rotation(yaw, pitch, roll))
end

function ConnectionNetworkHandler:connection_keep_alive(sender)
end

function ConnectionNetworkHandler:request_change_criminal_character(peer_id, new_character_name, peer_unit, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.character_customization:request_change_criminal_character(peer_id, new_character_name, peer_unit)
end

function ConnectionNetworkHandler:change_criminal_character(peer_id, new_character_name, peer_unit, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.character_customization:change_criminal_character(peer_id, new_character_name, peer_unit)
end

function ConnectionNetworkHandler:sync_host_selects_suggested_card(card_key_name, peer_id, steam_instance_id)
	if managers.menu_component._raid_challenge_cards_gui then
		managers.menu_component._raid_challenge_cards_gui:sync_host_selects_suggested_card(card_key_name, peer_id, steam_instance_id)
	end
end

function ConnectionNetworkHandler:sync_phase_two_execute_action(action, peer_id)
	if managers.menu_component._raid_challenge_cards_gui then
		managers.menu_component._raid_challenge_cards_gui:sync_phase_two_execute_action(action, peer_id)
	end
end

function ConnectionNetworkHandler:select_challenge_card(peer_id)
	managers.challenge_cards:select_challenge_card(peer_id)
end

function ConnectionNetworkHandler:remove_challenge_card_from_inventory(challenge_card_key, peer_id)
	local local_peer = managers.network:session():local_peer()

	if local_peer._id == peer_id then
		managers.challenge_cards:remove_challenge_card_from_inventory(challenge_card_key)
	end
end

function ConnectionNetworkHandler:sync_activate_challenge_card()
	managers.challenge_cards:_activate_challenge_card()
end

function ConnectionNetworkHandler:mark_active_card_as_spent()
	managers.challenge_cards:mark_active_card_as_spent()
end

function ConnectionNetworkHandler:set_successfull_raid_end()
	managers.challenge_cards:set_successfull_raid_end()
end

function ConnectionNetworkHandler:deactivate_active_challenge_card()
	managers.challenge_cards:deactivate_active_challenge_card()
end

function ConnectionNetworkHandler:remove_active_challenge_card()
	managers.challenge_cards:remove_active_challenge_card()
end

function ConnectionNetworkHandler:send_suggested_card_to_peers(challenge_card_key, peer_id, steam_instance_id)
	managers.challenge_cards:sync_suggested_card_from_peer(challenge_card_key, peer_id, steam_instance_id)
end

function ConnectionNetworkHandler:send_remove_suggested_card_to_peers(peer_id)
	managers.challenge_cards:sync_remove_suggested_card_from_peer(peer_id)
end

function ConnectionNetworkHandler:clear_suggested_cards()
	managers.challenge_cards:clear_suggested_cards()
end

function ConnectionNetworkHandler:send_toggle_lock_suggested_card_to_peers(peer_id)
	managers.challenge_cards:sync_toggle_lock_suggested_challenge_card(peer_id)
end

function ConnectionNetworkHandler:card_failed_warning(challenge_card_key, effect_id, peer_id)
	managers.challenge_cards:card_failed_warning(challenge_card_key, effect_id, peer_id)
end

function ConnectionNetworkHandler:fail_effect(failed_effect_name, peer_id)
	managers.buff_effect:fail_effect(failed_effect_name, peer_id)
end

function ConnectionNetworkHandler:sync_loot_to_peers(loot_type, name, xp, peer_id)
	managers.lootdrop:on_loot_dropped_for_peer(loot_type, name, xp, peer_id)
end

function ConnectionNetworkHandler:sync_set_selected_job(job_id, difficulty)
	tweak_data:set_difficulty(difficulty)
	managers.raid_job:_set_selected_job(job_id)
end

function ConnectionNetworkHandler:sync_current_job(job_id, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:sync_current_job(job_id)
end

function ConnectionNetworkHandler:sync_picked_up_loot_values(picked_up_current_leg, picked_up_total, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.lootdrop:set_picked_up_current_leg(picked_up_current_leg)
	managers.lootdrop:set_picked_up_total(picked_up_total)
	managers.notification:add_notification({
		id = "hud_hint_grabbed_nazi_gold",
		duration = 2,
		shelf_life = 5,
		notification_type = HUDNotification.DOG_TAG,
		acquired = picked_up_current_leg,
		total = picked_up_total
	})
end

function ConnectionNetworkHandler:sync_spawned_loot_values(spawned_current_leg, spawned_total, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.lootdrop:set_loot_spawned_total(spawned_total)
	managers.lootdrop:set_loot_spawned_current_leg(spawned_current_leg)
end

function ConnectionNetworkHandler:start_statistics_session(from_beginning, drop_in, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.statistics:start_session({
		from_beginning = from_beginning,
		drop_in = drop_in
	})
end

function ConnectionNetworkHandler:stop_statistics_session(success, quit, end_type, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.statistics:stop_session({
		success = success,
		quit = quit,
		type = end_type
	})
end

function ConnectionNetworkHandler:sync_current_event_index(current_event_index, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:sync_current_event_index(current_event_index)
end

function ConnectionNetworkHandler:sync_complete_job(sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:complete_job()
end

function ConnectionNetworkHandler:sync_event_loot_data(loot_acquired, loot_spawned, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:sync_event_loot_data(loot_acquired, loot_spawned)
end

function ConnectionNetworkHandler:sync_airplane_barrage(airplane_unit, sequence_name, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.barrage:sync_airplane_barrage(airplane_unit, sequence_name)
end

function ConnectionNetworkHandler:sync_barrage_launch_sound(event_name, sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.barrage:play_barrage_launch_sound(event_name)
end

function ConnectionNetworkHandler:sync_external_start_mission(mission_id, event_id, reload_mission_flag, sender)
	if not self._verify_sender(sender) then
		return
	end

	local mission = tweak_data.operations:mission_data(mission_id)

	if mission.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		managers.raid_job:set_current_event(mission, event_id)
	end

	if reload_mission_flag then
		managers.raid_job.reload_mission_flag = reload_mission_flag

		managers.worldcollection:add_one_package_ref_to_all()

		managers.raid_job._selected_job = managers.raid_job._current_job

		managers.raid_job:on_mission_restart()
		managers.raid_job:stop_sounds()
		managers.loot:reset()
	end

	managers.raid_job:do_external_start_mission(mission, event_id)
end

function ConnectionNetworkHandler:sync_external_end_mission(restart_camp, failed, sender)
	Application:debug("[ConnectionNetworkHandler:sync_external_end_mission] restart_camp, failed, sender", restart_camp, failed, sender)

	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:set_stage_success(not failed)
	managers.raid_job:do_external_end_mission(restart_camp)
end

function ConnectionNetworkHandler:restart(sender)
	if not self._verify_sender(sender) then
		return
	end

	managers.raid_job:do_external_end_mission()
end

function ConnectionNetworkHandler:sync_warcry_meter_fill_percentage(fill_percentage, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local character_data = managers.criminals:character_data_by_peer_id(sender_peer:id())

	if managers.hud and character_data then
		managers.hud:set_teammate_warcry_meter_fill(character_data.panel_id, {
			total = 100,
			current = fill_percentage
		})
	end
end

function ConnectionNetworkHandler:sync_warcry_meter_glow(value, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local character_data = managers.criminals:character_data_by_peer_id(sender_peer:id())

	if managers.hud then
		managers.hud:set_warcry_meter_glow(character_data.panel_id, value)
	end
end

function ConnectionNetworkHandler:sync_activate_warcry(warcry_type, warcry_level, duration, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local character_data = managers.criminals:character_data_by_peer_id(sender_peer:id())
	local name_label_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().name_label_id

	managers.hud:activate_teammate_warcry(character_data.panel_id, name_label_id, duration)
	managers.warcry:activate_peer_warcry(sender_peer:id(), warcry_type, warcry_level)
end

function ConnectionNetworkHandler:sync_deactivate_warcry(sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local character_data = managers.criminals:character_data_by_peer_id(sender_peer:id())
	local name_label_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().name_label_id

	if managers.hud then
		managers.hud:deactivate_teammate_warcry(character_data.panel_id, name_label_id)
	end

	managers.warcry:deactivate_peer_warcry(sender_peer:id())
end

function ConnectionNetworkHandler:refill_grenades(amount, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.player:refill_grenades(amount)
end

function ConnectionNetworkHandler:sync_queue_dialog(id, instigator, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	if Network:is_server() then
		managers.dialog:queue_dialog(id, {
			skip_idle_check = true,
			instigator = instigator
		})
	else
		managers.dialog:sync_queue_dialog(id, instigator)
	end
end

function ConnectionNetworkHandler:sync_camp_presence(value, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.player:set_local_player_in_camp(value)
end

function ConnectionNetworkHandler:sync_objectives_manager_mission_start(sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.objectives:on_mission_start_callback()
end

function ConnectionNetworkHandler:sync_active_challenge_card(card_key, locked, status, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.challenge_cards:sync_active_challenge_card(card_key, locked, status)
end

function ConnectionNetworkHandler:sync_active_challenge_card(card_key, locked, status, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.challenge_cards:sync_active_challenge_card(card_key, locked, status)
end

function ConnectionNetworkHandler:sync_spotter_spawn_flare(flare, pos, rot, forward, v, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.barrage:sync_spotter_spawn_flare(flare, pos, rot, forward, v)
end

function ConnectionNetworkHandler:sync_spotter_flare_disabled(unit, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	unit:damage():run_sequence_simple("state_barrage")
end

function ConnectionNetworkHandler:sync_randomize_operation(operation_id, string_delimited, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	tweak_data.operations:set_operation_indexes_delimited(operation_id, string_delimited)
end

function ConnectionNetworkHandler:set_hud_suspicion_state(indicator_id, state, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.hud:set_suspicion_indicator_state(indicator_id, state)
end

function ConnectionNetworkHandler:restore_health_by_percentage(health_percentage, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	if managers.player:player_unit() and not managers.player:player_unit():character_damage():bleed_out() then
		managers.player:player_unit():character_damage():restore_health(health_percentage / 100)
	end
end

function ConnectionNetworkHandler:enter_special_interaction_state(interaction_type, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local teammate_panel_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().teammate_panel_id
	local name_label_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().name_label_id

	if managers.hud then
		managers.hud:on_teammate_start_special_interaction(teammate_panel_id, name_label_id, interaction_type)
	end
end

function ConnectionNetworkHandler:exit_special_interaction_state(sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local teammate_panel_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().teammate_panel_id
	local name_label_id = sender_peer:unit() and sender_peer:unit():unit_data() and sender_peer:unit():unit_data().name_label_id

	if managers.hud then
		managers.hud:on_teammate_stop_special_interaction(teammate_panel_id, name_label_id)
	end
end

function ConnectionNetworkHandler:sync_document_spawn_chance(document_spawn_chance, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.consumable_missions:on_document_spawn_chance_received(document_spawn_chance, sender_peer:id())
end

function ConnectionNetworkHandler:reset_document_spawn_chance_modifier(sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.consumable_missions:reset_document_spawn_chance_modifier()
end

function ConnectionNetworkHandler:sync_choose_documents_type(chosen_document_unit, intel_type, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	managers.consumable_missions:sync_choose_documents_type(chosen_document_unit, intel_type)
end

function ConnectionNetworkHandler:sync_warcry_team_buff(upgrade_id, identifier, acquired, sender)
	if not self._verify_sender(sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	identifier = identifier or "buff_" .. tostring(upgrade_id)

	if acquired then
		managers.upgrades:aquire(upgrade_id, nil, identifier)
	else
		managers.upgrades:unaquire(upgrade_id, identifier)
	end
end
