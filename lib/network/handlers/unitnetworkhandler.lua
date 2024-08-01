local tmp_rot1 = Rotation()
UnitNetworkHandler = UnitNetworkHandler or class(BaseNetworkHandler)

-- Lines 5-42
function UnitNetworkHandler:set_unit(unit, character_name, outfit_string, outfit_version, peer_id, team_id)
	Application:trace("[UnitNetworkHandler:set_unit]", unit, character_name, peer_id)

	if peer_id == 0 then
		local crim_data = managers.criminals:character_data_by_name(character_name)

		if alive(unit) then
			if not crim_data or not crim_data.ai then
				managers.criminals:add_character(character_name, unit, nil, true)
			else
				managers.criminals:set_unit(character_name, unit)
			end

			unit:movement():set_character_anim_variables()
		elseif not crim_data or not crim_data.ai then
			managers.criminals:add_character(character_name, nil, nil, true)
		end

		return
	end

	if not alive(unit) then
		return
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return
	end

	if peer ~= managers.network:session():local_peer() then
		peer:set_outfit_string(outfit_string, outfit_version)
	end

	peer:set_unit(unit, character_name)
	self:_chk_flush_unit_too_early_packets(unit)
end

-- Lines 46-70
function UnitNetworkHandler:set_character_customization(unit, outfit_string, outfit_version, peer_id)
	if not alive(unit) then
		return
	end

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if peer_id == 0 then
		local customization = managers.blackmarket:unpack_team_ai_customization_from_string(outfit_string)

		unit:movement():set_character_customization(customization)
	else
		local peer = managers.network:session():peer(peer_id)

		if not peer then
			return
		end

		if peer ~= managers.network:session():local_peer() then
			peer:set_outfit_string(outfit_string, outfit_version)
		end

		peer:set_character_customization()
	end
end

-- Lines 74-89
function UnitNetworkHandler:set_equipped_weapon(unit, send_equipped_weapon_type, equipped_weapon_category_id, equipped_weapon_identifier, blueprint_string, cosmetics_string, sender)
	if not self._verify_character(unit) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if not unit:inventory() or not unit:inventory().synch_equipped_weapon then
		Application:error("[UnitNetworkHandler:set_equipped_weapon] unit umable to sync equipped weapon:  ", inspect(unit), "    ", inspect(unit:inventory()), "      ", type(unit:inventory()))

		return
	end

	unit:inventory():synch_equipped_weapon(send_equipped_weapon_type, equipped_weapon_category_id, equipped_weapon_identifier, blueprint_string, cosmetics_string, peer)
end

-- Lines 91-96
function UnitNetworkHandler:set_weapon_gadget_state(unit, gadget_state, sender)
	if not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:inventory():synch_weapon_gadget_state(gadget_state)
end

-- Lines 100-111
function UnitNetworkHandler:set_look_dir(unit, yaw_in, pitch_in, sender)
	if not self._verify_character_and_sender(unit, sender) then
		return
	end

	local dir = Vector3()
	local yaw = 360 * yaw_in / 255
	local pitch = math.lerp(-85, 85, pitch_in / 127)
	local rot = Rotation(yaw, pitch, 0)

	mrotation.y(rot, dir)
	unit:movement():sync_look_dir(dir)
end

-- Lines 115-169
function UnitNetworkHandler:action_walk_start(unit, first_nav_point, nav_link_yaw, nav_link_act_index, from_idle, haste_code, end_yaw, no_walk, no_strafe, end_pose_code)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	local end_rot = nil

	if end_yaw ~= 0 then
		end_rot = Rotation(360 * (end_yaw - 1) / 254, 0, 0)
	end

	local nav_path = {}

	if nav_link_act_index ~= 0 then
		local nav_link_rot = 360 * nav_link_yaw / 255
		local nav_link = unit:movement()._actions.walk.synthesize_nav_link(first_nav_point, nav_link_rot, unit:movement()._actions.act:_get_act_name_from_index(nav_link_act_index), from_idle)

		-- Lines 129-129
		function nav_link.element.value(element, name)
			return element[name]
		end

		nav_link.element.nav_link_wants_align_pos = nav_link.element.nav_link_wants_align_pos or function (element)
			Application:debug("[CopActionWalk:action_walk_start] Appending something that is not nav_link", inspect(self))

			return true
		end

		table.insert(nav_path, nav_link)
	else
		table.insert(nav_path, first_nav_point)
	end

	local end_pose = nil

	if end_pose_code == 1 then
		end_pose = "stand"
	elseif end_pose_code == 2 then
		end_pose = "crouch"
	end

	local action_desc = {
		path_simplified = true,
		type = "walk",
		persistent = true,
		body_part = 2,
		variant = haste_code == 1 and "walk" or "run",
		end_rot = end_rot,
		nav_path = nav_path,
		no_walk = no_walk,
		no_strafe = no_strafe,
		end_pose = end_pose,
		blocks = {
			act = -1,
			idle = -1,
			turn = -1,
			walk = -1
		}
	}

	unit:movement():action_request(action_desc)
end

-- Lines 173-178
function UnitNetworkHandler:action_walk_nav_point(unit, nav_point, sender)
	if not self._verify_character_and_sender(unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	unit:movement():sync_action_walk_nav_point(nav_point)
end

-- Lines 182-187
function UnitNetworkHandler:action_walk_stop(unit)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	unit:movement():sync_action_walk_stop()
end

-- Lines 191-197
function UnitNetworkHandler:action_walk_nav_link(unit, pos, yaw, anim_index, from_idle)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	local rot = 360 * yaw / 255

	unit:movement():sync_action_walk_nav_link(pos, rot, anim_index, from_idle)
end

-- Lines 201-206
function UnitNetworkHandler:action_change_pose(unit, pose_code, pos)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	unit:movement():sync_action_change_pose(pose_code, pos)
end

-- Lines 208-214
function UnitNetworkHandler:skill_action_knockdown(unit, hit_position, direction, hurt_type, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	CopDamage.skill_action_knockdown(unit, hit_position, direction, hurt_type)
end

-- Lines 217-229
function UnitNetworkHandler:action_warp_start(unit, has_pos, pos, has_rot, yaw, sender)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame_playing) then
		return
	end

	local action_desc = {
		body_part = 1,
		type = "warp",
		position = has_pos and pos,
		rotation = has_rot and Rotation(360 * (yaw - 1) / 254, 0, 0)
	}

	unit:movement():action_request(action_desc)
end

-- Lines 233-238
function UnitNetworkHandler:friendly_fire_hit(subject_unit)
	if not self._verify_character(subject_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	subject_unit:character_damage():friendly_fire_hit()
end

-- Lines 242-250
function UnitNetworkHandler:damage_bullet(subject_unit, attacker_unit, damage, i_body, height_offset, death, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_bullet(attacker_unit, damage, i_body, height_offset, death)
end

-- Lines 252-260
function UnitNetworkHandler:damage_knockdown(subject_unit, attacker_unit, damage, i_body, height_offset, death, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_knockdown(attacker_unit, damage, i_body, height_offset, death)
end

-- Lines 263-278
function UnitNetworkHandler:damage_explosion_fire(subject_unit, attacker_unit, damage, i_attack_variant, death, direction, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	if i_attack_variant == 3 then
		subject_unit:character_damage():sync_damage_fire(attacker_unit, damage, i_attack_variant, death, direction)
	else
		subject_unit:character_damage():sync_damage_explosion(attacker_unit, damage, i_attack_variant, death, direction)
	end
end

-- Lines 280-289
function UnitNetworkHandler:damage_fire(subject_unit, attacker_unit, damage, start_dot_dance_antimation, death, direction, weapon_type, weapon_unit, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_fire(attacker_unit, damage, start_dot_dance_antimation, death, direction, weapon_type, weapon_unit)
end

-- Lines 293-301
function UnitNetworkHandler:damage_dot(subject_unit, attacker_unit, damage, death, variant, hurt_animation, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_dot(attacker_unit, damage, death, variant, hurt_animation)
end

-- Lines 305-313
function UnitNetworkHandler:damage_tase(subject_unit, attacker_unit, damage, variant, death, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_tase(attacker_unit, damage, variant, death)
end

-- Lines 318-326
function UnitNetworkHandler:damage_melee(subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_melee(attacker_unit, damage, damage_effect, i_body, height_offset, variant, death)
end

-- Lines 330-335
function UnitNetworkHandler:sync_part_dismemberment(subject_unit, part_name, variant, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	subject_unit:character_damage():dismember(part_name, variant, false)
end

-- Lines 339-347
function UnitNetworkHandler:from_server_damage_bullet(subject_unit, attacker_unit, hit_offset_height, result_index, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_bullet(attacker_unit, hit_offset_height, result_index)
end

-- Lines 351-365
function UnitNetworkHandler:from_server_damage_explosion_fire(subject_unit, attacker_unit, result_index, i_attack_variant, sender)
	if not self._verify_character(subject_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	if i_attack_variant == 3 then
		subject_unit:character_damage():sync_damage_fire(attacker_unit, result_index, i_attack_variant)
	else
		subject_unit:character_damage():sync_damage_explosion(attacker_unit, result_index, i_attack_variant)
	end
end

-- Lines 369-377
function UnitNetworkHandler:from_server_damage_melee(subject_unit, attacker_unit, hit_offset_height, result_index, sender)
	if not self._verify_character(subject_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(attacker_unit) or attacker_unit:key() == subject_unit:key() then
		attacker_unit = nil
	end

	subject_unit:character_damage():sync_damage_melee(attacker_unit, attacker_unit, hit_offset_height, result_index)
end

-- Lines 381-386
function UnitNetworkHandler:from_server_damage_incapacitated(subject_unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(subject_unit) then
		return
	end

	subject_unit:character_damage():sync_damage_incapacitated()
end

-- Lines 390-395
function UnitNetworkHandler:from_server_damage_bleeding(subject_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(subject_unit) then
		return
	end

	subject_unit:character_damage():sync_damage_bleeding()
end

-- Lines 399-404
function UnitNetworkHandler:from_server_damage_tase(subject_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(subject_unit) then
		return
	end

	subject_unit:character_damage():sync_damage_tase()
end

-- Lines 408-413
function UnitNetworkHandler:from_server_unit_recovered(subject_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(subject_unit) then
		return
	end

	subject_unit:character_damage():sync_unit_recovered()
end

-- Lines 417-422
function UnitNetworkHandler:shot_blank(shooting_unit, impact, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(shooting_unit, sender) then
		return
	end

	shooting_unit:movement():sync_shot_blank(impact)
end

-- Lines 425-430
function UnitNetworkHandler:sync_start_auto_fire_sound(shooting_unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(shooting_unit, sender) then
		return
	end

	shooting_unit:movement():sync_start_auto_fire_sound()
end

-- Lines 432-437
function UnitNetworkHandler:sync_stop_auto_fire_sound(shooting_unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(shooting_unit, sender) then
		return
	end

	shooting_unit:movement():sync_stop_auto_fire_sound()
end

-- Lines 441-446
function UnitNetworkHandler:shot_blank_reliable(shooting_unit, impact, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(shooting_unit, sender) then
		return
	end

	shooting_unit:movement():sync_shot_blank(impact)
end

-- Lines 450-455
function UnitNetworkHandler:reload_weapon(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:movement():sync_reload_weapon()
end

-- Lines 459-470
function UnitNetworkHandler:run_mission_element(mission_id, id, unit, orientation_element_index)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		if self._verify_gamestate(self._gamestate_filter.any_end_game) then
			managers.mission:client_run_mission_element_end_screen(mission_id, id, unit, orientation_element_index)

			return
		end

		print("UnitNetworkHandler:run_mission_element discarded id:", mission_id, id)

		return
	end

	managers.mission:client_run_mission_element(mission_id, id, unit, orientation_element_index)
end

-- Lines 472-483
function UnitNetworkHandler:run_mission_element_no_instigator(mission_id, id, orientation_element_index)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		if self._verify_gamestate(self._gamestate_filter.any_end_game) then
			managers.mission:client_run_mission_element_end_screen(mission_id, id, nil, orientation_element_index)

			return
		end

		print("UnitNetworkHandler:run_mission_element discarded id:", mission_id, id)

		return
	end

	managers.mission:client_run_mission_element(mission_id, id, nil, orientation_element_index)
end

-- Lines 485-487
function UnitNetworkHandler:sync_client_hud_timer_command(mission_id, id, orientation_element_index, command, command_value)
	managers.mission:sync_client_hud_timer_command(mission_id, id, orientation_element_index, command, command_value)
end

-- Lines 491-496
function UnitNetworkHandler:to_server_mission_element_trigger(mission_id, id, unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.mission:server_run_mission_element_trigger(mission_id, id, unit)
end

-- Lines 498-503
function UnitNetworkHandler:to_server_area_event(event_id, mission_id, id, unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.mission:to_server_area_event(event_id, mission_id, id, unit)
end

-- Lines 519-525
function UnitNetworkHandler:to_server_access_camera_trigger(mission_id, id, trigger, instigator)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.mission:to_server_access_camera_trigger(mission_id, id, trigger, instigator)
end

-- Lines 529-559
function UnitNetworkHandler:sync_body_damage_bullet(body, attacker, normal_yaw, normal_pitch, position, direction_yaw, direction_pitch, damage, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_body_damage_bullet] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_body_damage_bullet] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_bullet then
		print("[UnitNetworkHandler:sync_body_damage_bullet] body has no damage damage_bullet function", body:name(), body:unit():name())

		return
	end

	local normal = Vector3()

	mrotation.set_yaw_pitch_roll(tmp_rot1, math.lerp(-180, 180, normal_yaw / 127), math.lerp(-90, 90, normal_pitch / 63), 0)
	mrotation.y(tmp_rot1, normal)

	local direction = Vector3()

	mrotation.set_yaw_pitch_roll(tmp_rot1, math.lerp(-180, 180, direction_yaw / 127), math.lerp(-90, 90, direction_pitch / 63), 0)
	mrotation.y(tmp_rot1, direction)
	body:extension().damage:damage_bullet(attacker, normal, position, direction, 1)
	body:extension().damage:damage_damage(attacker, normal, position, direction, damage / 163.84)
end

-- Lines 563-584
function UnitNetworkHandler:sync_body_damage_lock(body, damage, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_body_damage_lock] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_body_damage_lock] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_lock then
		print("[UnitNetworkHandler:sync_body_damage_lock] body has no damage damage_lock function", body:name(), body:unit():name())

		return
	end

	body:extension().damage:damage_lock(nil, nil, nil, nil, damage)
end

-- Lines 588-609
function UnitNetworkHandler:sync_body_damage_explosion(body, attacker, normal, position, direction, damage, armor_piercing, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_body_damage_explosion] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_body_damage_explosion] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_explosion then
		print("[UnitNetworkHandler:sync_body_damage_explosion] body has no damage damage_explosion function", body:name(), body:unit():name())

		return
	end

	body:extension().damage:damage_explosion(attacker, normal, position, direction, damage / 163.84, armor_piercing)
	body:extension().damage:damage_damage(attacker, normal, position, direction, damage / 163.84)
end

-- Lines 613-615
function UnitNetworkHandler:sync_body_damage_explosion_no_attacker(body, normal, position, direction, damage, armor_piercing, sender)
	self:sync_body_damage_explosion(body, nil, normal, position, direction, damage, armor_piercing, sender)
end

-- Lines 619-640
function UnitNetworkHandler:sync_body_damage_fire(body, attacker, normal, position, direction, damage, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_body_damage_fire] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_body_damage_fire] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_fire then
		print("[UnitNetworkHandler:sync_body_damage_fire] body has no damage damage_fire function", body:name(), body:unit():name())

		return
	end

	body:extension().damage:damage_fire(attacker, normal, position, direction, damage / 163.84)
	body:extension().damage:damage_damage(attacker, normal, position, direction, damage / 163.84)
end

-- Lines 644-646
function UnitNetworkHandler:sync_body_damage_fire_no_attacker(body, normal, position, direction, damage, sender)
	self:sync_body_damage_fire(body, nil, normal, position, direction, damage, sender)
end

-- Lines 650-670
function UnitNetworkHandler:sync_body_damage_melee(body, attacker, normal, position, direction, damage, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_body_damage_melee] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_body_damage_melee] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_melee then
		print("[UnitNetworkHandler:sync_body_damage_melee] body has no damage damage_melee function", body:name(), body:unit():name())

		return
	end

	body:extension().damage:damage_melee(attacker, normal, position, direction, damage)
end

-- Lines 674-698
function UnitNetworkHandler:sync_interacted(unit, unit_id, tweak_setting, status, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if Network:is_server() and unit_id ~= -2 then
		if alive(unit) and unit:interaction().tweak_data == tweak_setting and unit:interaction():active() then
			sender:sync_interaction_reply(true)
		else
			sender:sync_interaction_reply(false)

			return
		end
	end

	if alive(unit) then
		unit:interaction():sync_interacted(peer, nil, status)
	end
end

-- Lines 702-715
function UnitNetworkHandler:sync_multiple_equipment_bag_interacted(unit, amount_wanted, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if unit and alive(unit) and unit:interaction() then
		unit:interaction():sync_interacted(peer, nil, amount_wanted)
	end
end

-- Lines 719-732
function UnitNetworkHandler:sync_interaction_info_id(unit, info_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if alive(unit) and unit:interaction().set_info_id then
		unit:interaction():set_info_id(info_id)
	end
end

-- Lines 736-747
function UnitNetworkHandler:sync_interacted_by_id(unit_id, tweak_setting, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) and not self._verify_sender(sender) then
		return
	end

	local u_data = managers.enemy:get_corpse_unit_data_from_id(unit_id)

	if not u_data then
		sender:sync_interaction_reply(false)

		return
	end

	self:sync_interacted(u_data.unit, unit_id, tweak_setting, 1, sender)
end

-- Lines 751-761
function UnitNetworkHandler:sync_interaction_reply(status)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(managers.player:player_unit()) then
		return
	end

	managers.player:from_server_interaction_reply(status)
end

-- Lines 765-785
function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(unit) then
		local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)

		if not u_data then
			return
		end

		unit = u_data.unit
	end

	unit:interaction():set_tweak_data(tweak_data)
	unit:interaction():set_active(active)

	if flash then
		unit:interaction():set_outline_flash_state(true, nil)
	end
end

-- Lines 789-798
function UnitNetworkHandler:sync_teammate_start_progress(timer, interact_unit, sender)
	local sender_peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
		return
	end

	local teammate_panel_id = sender_peer:unit():unit_data().teammate_panel_id
	local name_label_id = interact_unit ~= managers.player:player_unit() and sender_peer:unit():unit_data().name_label_id or nil

	managers.hud:teammate_start_progress(teammate_panel_id, name_label_id, timer)
end

-- Lines 800-809
function UnitNetworkHandler:sync_teammate_cancel_progress(sender)
	local sender_peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
		return
	end

	local teammate_panel_id = sender_peer:unit():unit_data().teammate_panel_id
	local name_label_id = sender_peer:unit():unit_data().name_label_id

	managers.hud:teammate_cancel_progress(teammate_panel_id, name_label_id)
end

-- Lines 811-820
function UnitNetworkHandler:sync_teammate_complete_progress(sender)
	local sender_peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
		return
	end

	local teammate_panel_id = sender_peer:unit():unit_data().teammate_panel_id
	local name_label_id = sender_peer:unit():unit_data().name_label_id

	managers.hud:teammate_complete_progress(teammate_panel_id, name_label_id)
end

-- Lines 824-840
function UnitNetworkHandler:action_aim_state(cop, state)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(cop) then
		return
	end

	if state then
		local shoot_action = {
			block_type = "action",
			body_part = 3,
			type = "shoot"
		}

		cop:movement():action_request(shoot_action)
	else
		self:action_aim_end(cop)
	end
end

-- Lines 844-849
function UnitNetworkHandler:action_aim_end(cop)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(cop) then
		return
	end

	cop:movement():sync_action_aim_end()
end

-- Lines 853-858
function UnitNetworkHandler:action_hurt_end(unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():sync_action_hurt_end()
end

-- Lines 862-888
function UnitNetworkHandler:set_attention(unit, target_unit, reaction, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	if not alive(target_unit) then
		unit:movement():synch_attention()

		return
	end

	local handler = nil

	if target_unit:attention() then
		handler = target_unit:attention()
	elseif target_unit:brain() and target_unit:brain().attention_handler then
		handler = target_unit:brain():attention_handler()
	elseif target_unit:movement() and target_unit:movement().attention_handler then
		handler = target_unit:movement():attention_handler()
	elseif target_unit:base() and target_unit:base().attention_handler then
		handler = target_unit:base():attention_handler()
	end

	if not handler and (not target_unit:movement() or not target_unit:movement().m_head_pos) then
		debug_pause_unit(target_unit, "[UnitNetworkHandler:set_attention] no attention handler or m_head_pos", target_unit)

		return
	end

	unit:movement():synch_attention({
		unit = target_unit,
		u_key = target_unit:key(),
		handler = handler,
		reaction = reaction
	})
end

-- Lines 892-897
function UnitNetworkHandler:cop_set_attention_pos(unit, pos)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():synch_attention({
		pos = pos,
		reaction = AIAttentionObject.REACT_IDLE
	})
end

-- Lines 901-906
function UnitNetworkHandler:set_allow_fire(unit, state)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():synch_allow_fire(state)
end

-- Lines 910-915
function UnitNetworkHandler:set_stance(unit, stance_code, instant, execute_queued, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:movement():sync_stance(stance_code, instant, execute_queued)
end

-- Lines 919-924
function UnitNetworkHandler:set_pose(unit, pose_code, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:movement():sync_pose(pose_code)
end

-- Lines 928-955
function UnitNetworkHandler:long_dis_interaction(target_unit, amount, aggressor_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(target_unit) or not self._verify_character(aggressor_unit) then
		return
	end

	local target_is_criminal = target_unit:in_slot(managers.slot:get_mask("criminals")) or target_unit:in_slot(managers.slot:get_mask("harmless_criminals"))
	local aggressor_is_criminal = aggressor_unit:in_slot(managers.slot:get_mask("criminals")) or aggressor_unit:in_slot(managers.slot:get_mask("harmless_criminals"))

	if target_is_criminal then
		if aggressor_is_criminal then
			if target_unit:brain() then
				if target_unit:brain().on_long_dis_interacted then
					target_unit:movement():set_cool(false)
					target_unit:brain():on_long_dis_interacted(amount, aggressor_unit)
				end
			elseif amount == 1 then
				target_unit:movement():on_morale_boost(aggressor_unit)
			end
		else
			target_unit:brain():on_intimidated(amount / 10, aggressor_unit)
		end
	elseif target_unit:brain() then
		target_unit:brain():on_intimidated(amount / 10, aggressor_unit)
	end
end

-- Lines 959-965
function UnitNetworkHandler:remove_corpse_by_id(u_id, carry_bodybag, peer_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.enemy:remove_corpse_by_id(u_id)
end

-- Lines 969-974
function UnitNetworkHandler:unit_tied(unit, aggressor)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:brain():on_tied(aggressor)
end

-- Lines 978-983
function UnitNetworkHandler:unit_traded(unit, trader)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:brain():on_trade(trader)
end

-- Lines 987-992
function UnitNetworkHandler:hostage_trade(unit, enable, trade_success)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	CopLogicTrade.hostage_trade(unit, enable, trade_success)
end

-- Lines 994-999
function UnitNetworkHandler:set_unit_invulnerable(unit, enable)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:character_damage():set_invulnerable(enable)
end

-- Lines 1001-1006
function UnitNetworkHandler:set_trade_countdown(enable)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:set_trade_countdown(enable)
end

-- Lines 1008-1013
function UnitNetworkHandler:set_trade_death(criminal_name, respawn_penalty, hostages_killed)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_set_trade_death(criminal_name, respawn_penalty, hostages_killed)
end

-- Lines 1015-1020
function UnitNetworkHandler:set_trade_spawn(criminal_name)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_set_trade_spawn(criminal_name)
end

-- Lines 1022-1027
function UnitNetworkHandler:set_trade_replace(replace_ai, criminal_name1, criminal_name2, respawn_penalty)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.trade:sync_set_trade_replace(replace_ai, criminal_name1, criminal_name2, respawn_penalty)
end

-- Lines 1031-1036
function UnitNetworkHandler:action_idle_start(unit, body_part, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():action_request({
		type = "idle",
		body_part = body_part
	})
end

-- Lines 1040-1042
function UnitNetworkHandler:action_act_start(unit, act_index, blocks_hurt, clamp_to_graph, needs_full_blend)
	self:action_act_start_align(unit, act_index, blocks_hurt, clamp_to_graph, needs_full_blend, nil, nil)
end

-- Lines 1046-1057
function UnitNetworkHandler:action_act_start_align(unit, act_index, blocks_hurt, clamp_to_graph, needs_full_blend, start_yaw, start_pos)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	local start_rot = nil

	if start_yaw and start_yaw ~= 0 then
		start_rot = Rotation(360 * (start_yaw - 1) / 254, 0, 0)
	end

	unit:movement():sync_action_act_start(act_index, blocks_hurt, clamp_to_graph, needs_full_blend, start_rot, start_pos)
end

-- Lines 1059-1064
function UnitNetworkHandler:action_act_end(unit)
	if not alive(unit) or unit:character_damage():dead() then
		return
	end

	unit:movement():sync_action_act_end()
end

-- Lines 1068-1073
function UnitNetworkHandler:action_dodge_start(unit, body_part, variation, side, rotation, speed, shoot_acc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():sync_action_dodge_start(body_part, variation, side, rotation, speed, shoot_acc)
end

-- Lines 1075-1080
function UnitNetworkHandler:action_dodge_end(unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():sync_action_dodge_end()
end

-- Lines 1084-1113
function UnitNetworkHandler:action_tase_event(taser_unit, event_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(taser_unit) then
		return
	end

	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	if event_id == 1 then
		if not managers.network:session():is_client() or managers.network:session():server_peer() ~= sender_peer then
			return
		end

		local tase_action = {
			body_part = 3,
			type = "tase"
		}

		taser_unit:movement():action_request(tase_action)
	elseif event_id == 2 then
		if not managers.network:session():is_client() or managers.network:session():server_peer() ~= sender_peer then
			return
		end

		taser_unit:movement():sync_action_tase_end()
	else
		taser_unit:movement():sync_taser_fire()
	end
end

-- Lines 1117-1135
function UnitNetworkHandler:alert(alerted_unit, aggressor)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(alerted_unit) or not self._verify_character(aggressor) then
		return
	end

	local record = managers.groupai:state():criminal_record(aggressor:key())

	if not record then
		return
	end

	local aggressor_pos = nil

	if aggressor:movement() and aggressor:movement().m_head_pos then
		aggressor_pos = aggressor:movement():m_head_pos()
	else
		aggressor_pos = aggressor:position()
	end

	alerted_unit:brain():on_alert({
		"aggression",
		aggressor_pos,
		false,
		[5] = aggressor
	})
end

-- Lines 1139-1154
function UnitNetworkHandler:revive_player(revive_health_level, revive_damage_reduction, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.need_revive) or not peer then
		return
	end

	if revive_damage_reduction > 0 then
		managers.player:activate_temporary_upgrade_by_level("temporary", "passive_revive_damage_reduction", revive_damage_reduction)
	end

	local player = managers.player:player_unit()

	if alive(player) then
		player:character_damage():revive()
	end
end

-- Lines 1157-1167
function UnitNetworkHandler:pause_downed_teammate_timer(peer_id, pause, sender)
	local sender_peer = self._verify_sender(sender)

	if not sender_peer then
		return
	end

	local criminals_data = managers.criminals:character_data_by_peer_id(peer_id)

	if criminals_data then
		managers.hud:pause_teammate_timer(peer_id, criminals_data.name_label_id, pause)
	end
end

-- Lines 1169-1179
function UnitNetworkHandler:start_revive_player(timer, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.downed) or not peer then
		return
	end

	local player = managers.player:player_unit()

	if alive(player) then
		player:character_damage():pause_downed_timer(timer, peer:id())
	end
end

-- Lines 1181-1191
function UnitNetworkHandler:interupt_revive_player(sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.downed) or not peer then
		return
	end

	local player = managers.player:player_unit()

	if alive(player) then
		player:character_damage():unpause_downed_timer(peer:id())
	end
end

-- Lines 1195-1200
function UnitNetworkHandler:revive_unit(unit, reviving_unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) or not alive(reviving_unit) then
		return
	end

	unit:interaction():interact(reviving_unit)
end

-- Lines 1202-1208
function UnitNetworkHandler:pause_bleed_out(unit, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer or not self._verify_character(unit) then
		return
	end

	unit:character_damage():pause_bleed_out(peer:id())
end

-- Lines 1210-1216
function UnitNetworkHandler:unpause_bleed_out(unit, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer or not self._verify_character(unit) then
		return
	end

	unit:character_damage():unpause_bleed_out(peer:id())
end

-- Lines 1218-1230
function UnitNetworkHandler:interaction_set_waypoint_paused(unit, paused, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(unit) then
		return
	end

	if not unit:interaction() then
		return
	end

	unit:interaction():set_waypoint_paused(paused)
end

-- Lines 1234-1250
function UnitNetworkHandler:from_server_ecm_jammer_place_result(unit, rpc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit = alive(unit) and unit or nil

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():equipment():from_server_ecm_jammer_placement_result(unit and true or false)
	end

	if not unit then
		return
	end

	unit:base():set_owner(managers.player:player_unit())
end

-- Lines 1254-1262
function UnitNetworkHandler:from_server_ecm_jammer_rejected(rpc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():equipment():from_server_ecm_jammer_placement_result(false)
	end
end

-- Lines 1266-1279
function UnitNetworkHandler:sync_unit_event_id_16(unit, ext_name, event_id, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local extension = unit[ext_name](unit)

	if not extension then
		debug_pause("[UnitNetworkHandler:sync_unit_event_id_16] unit", unit, "does not have extension", ext_name)

		return
	end

	extension:sync_net_event(event_id, peer)
end

-- Lines 1283-1292
function UnitNetworkHandler:sync_tank_cannon_explosion(unit, position, range, damage, player_damage, curve_pow, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:mounted_weapon():_tank_main_cannon_hit_explosion_on_client(position, range, damage, player_damage, curve_pow)
end

-- Lines 1296-1305
function UnitNetworkHandler:sync_ai_tank_singleshot_blank(unit, position, normal, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:weapon():play_singleshot_sound_and_effect(position, normal)
end

-- Lines 1309-1318
function UnitNetworkHandler:sync_ai_tank_grenade_explosion(unit, position, range, damage, player_damage, curve_pow, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:weapon():_hit_explosion_on_client(position, range, damage, player_damage, curve_pow)
end

-- Lines 1322-1328
function UnitNetworkHandler:m79grenade_explode_on_client(position, normal, user, damage, range, curve_pow, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(user, sender) then
		return
	end

	ProjectileBase._explode_on_client(position, normal, user, damage, range, curve_pow)
end

-- Lines 1331-1337
function UnitNetworkHandler:element_explode_on_client(position, normal, damage, range, curve_pow, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.explosion:client_damage_and_push(position, normal, nil, damage, range, curve_pow)
end

-- Lines 1341-1353
function UnitNetworkHandler:place_sentry_gun(pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, equipment_selection_index, user_unit, rpc)
	local peer = self._verify_sender(rpc)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	local unit = SentryGunBase.spawn(user_unit, pos, rot, ammo_multiplier, armor_multiplier, damage_multiplier, peer:id(), true)

	if unit then
		unit:base():set_server_information(peer:id())
	end

	managers.network:session():send_to_peers_synched("from_server_sentry_gun_place_result", peer:id(), unit and equipment_selection_index or 0, unit, unit and unit:movement()._rot_speed_mul, unit and unit:weapon()._setup.spread_mul, unit and unit:base():has_shield() and true or false)
end

-- Lines 1357-1385
function UnitNetworkHandler:from_server_sentry_gun_place_result(owner_peer_id, equipment_selection_index, sentry_gun_unit, rot_speed_mul, spread_mul, shield, rpc)
	local local_peer = managers.network:session():local_peer()

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(rpc) or not alive(sentry_gun_unit) or not managers.network:session():peer(owner_peer_id) then
		if alive(local_peer:unit()) then
			local_peer:unit():equipment():from_server_sentry_gun_place_result()
		end

		return
	end

	sentry_gun_unit:base():set_owner_id(owner_peer_id)

	if owner_peer_id == local_peer:id() and alive(local_peer:unit()) then
		managers.player:from_server_equipment_place_result(equipment_selection_index, local_peer:unit())
	end

	if shield then
		sentry_gun_unit:base():enable_shield()
	end

	sentry_gun_unit:movement():setup(rot_speed_mul)
	sentry_gun_unit:brain():setup(1 / rot_speed_mul)

	local setup_data = {
		spread_mul = spread_mul,
		ignore_units = {
			sentry_gun_unit
		}
	}

	sentry_gun_unit:weapon():setup(setup_data, 1)
end

-- Lines 1389-1396
function UnitNetworkHandler:place_ammo_bag(pos, rot, ammo_upgrade_lvl, rpc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(rpc) then
		return
	end

	local peer = self._verify_sender(rpc)
	local unit = AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl)

	unit:base():set_server_information(peer:id())
end

-- Lines 1400-1408
function UnitNetworkHandler:special_interaction_done(unit)
	Application:trace("[UnitNetworkHandler:special_interaction_done] unit ", unit)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		unit:interaction():set_special_interaction_done()
	end
end

-- Lines 1410-1418
function UnitNetworkHandler:special_interaction_dynamite_done(unit, cuts)
	Application:trace("[UnitNetworkHandler:special_interaction_dynamite_done] unit, cuts ", unit, cuts)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		unit:interaction():set_special_interaction_dynamite_done(cuts)
	end
end

-- Lines 1420-1428
function UnitNetworkHandler:greed_cache_item_interacted_with(unit, amount)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		unit:interaction():on_peer_interacted(amount)
	end
end

-- Lines 1430-1438
function UnitNetworkHandler:greed_item_picked_up(unit, amount)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		unit:interaction():on_peer_interacted(amount)
	end
end

-- Lines 1440-1448
function UnitNetworkHandler:pickpocket_interaction(unit, tweak_table_name)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit then
		unit:interaction():on_peer_interacted(tweak_table_name)
	end
end

-- Lines 1452-1457
function UnitNetworkHandler:sentrygun_ammo(unit, ammo_ratio)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:weapon():sync_ammo(ammo_ratio)
end

-- Lines 1461-1466
function UnitNetworkHandler:sentrygun_health(unit, health_ratio)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:character_damage():sync_health(health_ratio)
end

-- Lines 1470-1475
function UnitNetworkHandler:turret_idle_state(unit, state)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:brain():set_idle(state)
end

-- Lines 1479-1485
function UnitNetworkHandler:turret_sabotaged(unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:character_damage():sync_sabotaged()
end

-- Lines 1489-1495
function UnitNetworkHandler:turret_complete_repairing(unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:movement():complete_repairing()
end

-- Lines 1499-1504
function UnitNetworkHandler:turret_repair_sabotage(unit)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:character_damage():repair_sabotage()
end

-- Lines 1508-1518
function UnitNetworkHandler:sync_unit_module(parent_unit, module_unit, align_obj_name, module_id, parent_extension_name)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(parent_unit) or not alive(module_unit) then
		return
	end

	parent_unit[parent_extension_name](parent_unit):spawn_module(module_unit, align_obj_name, module_id)
end

-- Lines 1522-1533
function UnitNetworkHandler:run_unit_module_function(parent_unit, module_id, parent_extension_name, module_extension_name, func_name, params)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(parent_unit) then
		return
	end

	local params_split = string.split(params, " ")

	parent_unit[parent_extension_name](parent_unit):run_module_function_unsafe(module_id, module_extension_name, func_name, params_split[1], params_split[2])
end

-- Lines 1537-1543
function UnitNetworkHandler:sync_equipment_setup(unit, upgrade_lvl, peer_id)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:base():sync_setup(upgrade_lvl, peer_id)
end

-- Lines 1547-1552
function UnitNetworkHandler:sync_ammo_bag_ammo_taken(unit, amount, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:base():sync_ammo_taken(amount)
end

-- Lines 1556-1561
function UnitNetworkHandler:sync_grenade_crate_grenade_taken(unit, amount, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:base():sync_grenade_taken(amount)
end

-- Lines 1565-1582
function UnitNetworkHandler:place_deployable_bag(class_name, pos, rot, upgrade_lvl, rpc)
	local peer = self._verify_sender(rpc)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	local class_name_to_deployable_id = tweak_data.equipments.class_name_to_deployable_id

	if not managers.player:verify_equipment(peer:id(), class_name_to_deployable_id[class_name]) then
		return
	end

	local class = CoreSerialize.string_to_classtable(class_name)

	if class then
		local unit = class.spawn(pos, rot, upgrade_lvl, peer:id())

		unit:base():set_server_information(peer:id())
	end
end

-- Lines 1586-1593
function UnitNetworkHandler:used_deployable(rpc)
	local peer = self._verify_sender(rpc)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	peer:set_used_deployable(true)
end

-- Lines 1597-1602
function UnitNetworkHandler:sync_doctor_bag_taken(unit, amount, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:base():sync_taken(amount)
end

-- Lines 1606-1611
function UnitNetworkHandler:sync_money_wrap_money_taken(unit, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:base():sync_money_taken()
end

-- Lines 1615-1628
function UnitNetworkHandler:sync_pickup(unit, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local pickup_extension = unit:base()

	if not pickup_extension or not pickup_extension.sync_pickup then
		pickup_extension = unit:pickup()
	end

	if pickup_extension and pickup_extension.sync_pickup then
		pickup_extension:sync_pickup(self._verify_sender(sender))
	end
end

-- Lines 1632-1642
function UnitNetworkHandler:unit_sound_play(unit, event_id, source, sender)
	if not alive(unit) or not self._verify_sender(sender) then
		return
	end

	if source == "" then
		source = nil
	end

	unit:sound():play(event_id, source, false)
end

-- Lines 1646-1667
function UnitNetworkHandler:corpse_sound_play(unit_id, event_id, source)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local u_data = managers.enemy:get_corpse_unit_data_from_id(unit_id)

	if not u_data then
		return
	end

	if not u_data.unit then
		debug_pause("[UnitNetworkHandler:corpse_sound_play] u_data without unit", inspect(u_data))

		return
	end

	if not u_data.unit:sound() then
		return
	end

	u_data.unit:sound():play(event_id, source, false)
end

-- Lines 1671-1680
function UnitNetworkHandler:say(unit, event_id, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if unit:in_slot(managers.slot:get_mask("all_criminals")) and not managers.groupai:state():is_enemy_converted_to_criminal(unit) then
		unit:sound():say(event_id, true, nil)
	else
		unit:sound():say(event_id, nil, true)
	end
end

-- Lines 1684-1689
function UnitNetworkHandler:sync_remove_one_teamAI(name, replace_with_player)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_remove_one_teamAI(name, replace_with_player)
end

-- Lines 1693-1698
function UnitNetworkHandler:sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
end

-- Lines 1702-1707
function UnitNetworkHandler:sync_smoke_grenade_kill()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_smoke_grenade_kill()
end

-- Lines 1711-1716
function UnitNetworkHandler:sync_cs_grenade(detonate_pos, shooter_pos, duration)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_cs_grenade(detonate_pos, shooter_pos, duration)
end

-- Lines 1720-1725
function UnitNetworkHandler:sync_cs_grenade_kill()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_cs_grenade_kill()
end

-- Lines 1729-1734
function UnitNetworkHandler:sync_hostage_headcount(value)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_hostage_headcount(value)
end

-- Lines 1738-1744
function UnitNetworkHandler:play_distance_interact_redirect(unit, redirect, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:movement():play_redirect(redirect)
end

-- Lines 1748-1753
function UnitNetworkHandler:start_timer_gui(unit, timer, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:timer_gui():sync_start(timer)
end

-- Lines 1766-1771
function UnitNetworkHandler:give_equipment(equipment, amount, transfer, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.player:add_special({
		name = equipment,
		amount = amount,
		transfer = transfer
	})
end

-- Lines 1776-1781
function UnitNetworkHandler:killzone_set_unit(type)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.killzone:set_unit(managers.player:player_unit(), type)
end

-- Lines 1785-1790
function UnitNetworkHandler:dangerzone_set_level(level)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.player:player_unit():character_damage():set_danger_level(level)
end

-- Lines 1794-1821
function UnitNetworkHandler:set_player_level(unit, level, unit_id_str, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if self:_chk_unit_too_early(unit, unit_id_str, "set_player_level", 1, unit, level, unit_id_str) then
		return
	end

	if not alive(unit) then
		return
	end

	level = math.clamp(level, 0, managers.experience:level_cap())

	peer:set_level(level)

	local character_data = managers.criminals:character_data_by_peer_id(unit:id())
	local panel_id = character_data and character_data.panel_id

	if panel_id then
		managers.hud:set_teammate_level(panel_id, level)
	end
end

-- Lines 1823-1854
function UnitNetworkHandler:set_player_nationality(unit, nationality, unit_id_str, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if self:_chk_unit_too_early(unit, unit_id_str, "set_player_nationality", 1, unit, nationality, unit_id_str) then
		return
	end

	if not alive(unit) then
		return
	end

	if not nationality or not tweak_data.criminals.character_nation_name[nationality] then
		debug_pause("[UnitNetworkHandler:set_player_nationality] peer attempted to change to a non-existant nationality:", peer:id(), nationality)

		nationality = tweak_data.criminals.character_nations[1]
	end

	peer:set_nationality(nationality)

	local character_data = managers.criminals:character_data_by_peer_id(unit:id())
	local panel_id = character_data and character_data.panel_id

	if panel_id then
		managers.hud:set_teammate_nationality(panel_id, level)
	end
end

-- Lines 1857-1879
function UnitNetworkHandler:set_player_class(unit, class, unit_id_str, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	if self:_chk_unit_too_early(unit, unit_id_str, "set_player_class", 1, unit, class, unit_id_str) then
		return
	end

	if not alive(unit) then
		return
	end

	if not class or not tweak_data.skilltree.classes[class] then
		debug_pause("[UnitNetworkHandler:set_player_class] peer attempted to change to a non-existant class:", peer:id(), class)

		class = SkillTreeTweakData.CLASS_RECON
	end

	peer:set_class(class)
end

-- Lines 1881-1924
function UnitNetworkHandler:set_active_warcry(unit, warcry_name, fill_percentage, unit_id_str, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if self:_chk_unit_too_early(unit, unit_id_str, "set_active_warcry", 1, unit, warcry_name, unit_id_str) then
		return
	end

	if not alive(unit) then
		return
	end

	if not warcry_name or not tweak_data.warcry[warcry_name] then
		debug_pause("[UnitNetworkHandler:set_active_warcry] peer attempted to activate a warcry that doesn't exist:", peer:id(), warcry_name)

		local peer_class = peer:class() or SkillTreeTweakData.CLASS_RECON
		warcry_name = tweak_data.skilltree.class_warcry_data[peer_class][1]
	end

	peer:set_active_warcry(warcry_name)

	local character_data = managers.criminals:character_data_by_peer_id(peer:id())
	local panel_id = character_data and character_data.panel_id
	local name_label_id = peer:unit() and peer:unit():unit_data() and peer:unit():unit_data().name_label_id

	if panel_id then
		if warcry_name then
			managers.hud:set_teammate_active_warcry(character_data.panel_id, name_label_id, warcry_name)
		end

		if fill_percentage then
			managers.hud:set_teammate_warcry_meter_fill(character_data.panel_id, {
				total = 100,
				current = fill_percentage
			})
		end
	end
end

-- Lines 1929-1998
function UnitNetworkHandler:sync_player_movement_state(unit, state, down_time, unit_id_str)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	self:_chk_unit_too_early(unit, unit_id_str, "sync_player_movement_state", 1, unit, state, down_time, unit_id_str)

	if not alive(unit) then
		return
	end

	local local_peer = managers.network:session():local_peer()

	if local_peer:unit() and unit:key() == local_peer:unit():key() then
		local valid_transitions = {
			standard = {
				incapacitated = true,
				bleed_out = true,
				carry = true,
				tased = true
			},
			carry = {
				incapacitated = true,
				bleed_out = true,
				standard = true,
				tased = true
			},
			mask_off = {
				carry = true,
				standard = true
			},
			bleed_out = {
				carry = true,
				fatal = true,
				standard = true
			},
			fatal = {
				carry = true,
				standard = true
			},
			tased = {
				incapacitated = true,
				carry = true,
				standard = true
			},
			incapacitated = {
				carry = true,
				standard = true
			},
			clean = {
				mask_off = true,
				carry = true,
				standard = true,
				civilian = true
			}
		}

		if unit:movement():current_state_name() == state then
			return
		end

		if unit:movement():current_state_name() and valid_transitions[unit:movement():current_state_name()][state] then
			managers.player:set_player_state(state)
		else
			debug_pause_unit(unit, "[UnitNetworkHandler:sync_player_movement_state] received invalid transition", unit, unit:movement():current_state_name(), "->", state)
		end
	else
		unit:movement():sync_movement_state(state, down_time)
	end
end

-- Lines 2003-2008
function UnitNetworkHandler:sync_waiting_for_player_start(variant, soundtrack)
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_players) then
		return
	end

	game_state_machine:current_state():sync_start(variant, soundtrack)
end

-- Lines 2010-2015
function UnitNetworkHandler:sync_waiting_for_player_skip()
	if not self._verify_gamestate(self._gamestate_filter.waiting_for_players) then
		return
	end

	game_state_machine:current_state():sync_skip()
end

-- Lines 2019-2028
function UnitNetworkHandler:criminal_hurt(criminal_unit, attacker_unit, damage_ratio, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(criminal_unit, sender) then
		return
	end

	if not alive(attacker_unit) or criminal_unit:key() == attacker_unit:key() then
		attacker_unit = nil
	end

	managers.groupai:state():criminal_hurt_drama(criminal_unit, attacker_unit, damage_ratio * 0.01)
end

-- Lines 2031-2043
function UnitNetworkHandler:suspect_uncovered(enemy_unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local suspect_member = managers.network:session():local_peer()
	local suspect_unit = suspect_member and suspect_member:unit()

	if not suspect_unit then
		return
	end

	suspect_unit:movement():on_uncovered(enemy_unit)
end

-- Lines 2047-2055
function UnitNetworkHandler:clear_synced_team_upgrades(sender)
	local sender_peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
		return
	end

	local peer_id = sender_peer:id()

	managers.player:clear_synced_team_upgrades(peer_id)
end

-- Lines 2059-2067
function UnitNetworkHandler:add_synced_team_upgrade(category, upgrade, level, sender)
	local sender_peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
		return
	end

	local peer_id = sender_peer:id()

	managers.player:add_synced_team_upgrade(peer_id, category, upgrade, level)
end

-- Lines 2070-2077
function UnitNetworkHandler:sync_deployable_equipment(deployable, amount, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:set_synced_deployable_equipment(peer, deployable, amount)
end

-- Lines 2080-2090
function UnitNetworkHandler:sync_peer_world_data(world_id, stage_prepare, stage_load, stage_load_finished, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	Application:debug("[UnitNetworkHandler:sync_peer_world_data]", peer:id(), world_id, stage_prepare, stage_load, stage_load_finished)

	peer._synced_worlds[world_id] = peer._synced_worlds[world_id] or {}
	peer._synced_worlds[world_id][CoreWorldCollection.STAGE_LOAD] = stage_load
	peer._synced_worlds[world_id][CoreWorldCollection.STAGE_PREPARE] = stage_prepare
	peer._synced_worlds[world_id][CoreWorldCollection.STAGE_LOAD_FINISHED] = stage_load_finished
end

-- Lines 2093-2100
function UnitNetworkHandler:sync_grenades(grenade, amount, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:set_synced_grenades(peer:id(), grenade, amount)
end

-- Lines 2103-2110
function UnitNetworkHandler:sync_ammo_amount(selection_index, max_clip, current_clip, current_left, max, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:set_synced_ammo_info(peer:id(), selection_index, max_clip, current_clip, current_left, max)
end

-- Lines 2113-2120
function UnitNetworkHandler:sync_bipod(bipod_pos, body_pos, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:set_synced_bipod(peer, bipod_pos, body_pos)
end

-- Lines 2124-2131
function UnitNetworkHandler:sync_add_carry(carry_id, multiplier, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:add_synced_carry(peer, carry_id, multiplier)
end

-- Lines 2134-2141
function UnitNetworkHandler:sync_remove_all_carry(sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:remove_synced_carry(nil, peer)
end

-- Lines 2144-2151
function UnitNetworkHandler:sync_remove_carry(carry_id, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:remove_synced_carry(carry_id, peer)
end

-- Lines 2153-2160
function UnitNetworkHandler:server_drop_carry(carry_id, carry_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:server_drop_carry(carry_id, carry_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
end

-- Lines 2162-2170
function UnitNetworkHandler:sync_carry_data(unit, carry_id, carry_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.player:sync_carry_data(unit, carry_id, carry_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
end

-- Lines 2175-2197
function UnitNetworkHandler:request_throw_projectile(projectile_type, position, dir, cooking_t, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	local peer_id = peer:id()
	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	if not projectile_entry or not tweak_data.projectiles[projectile_entry] then
		return
	end

	local no_cheat_count = tweak_data.projectiles[projectile_entry].no_cheat_count

	if not no_cheat_count and not managers.player:verify_grenade(peer_id) then
		return
	end

	ProjectileBase.throw_projectile(projectile_type, position, dir, peer_id, cooking_t)
end

-- Lines 2200-2256
function UnitNetworkHandler:sync_throw_projectile(unit, pos, dir, projectile_type, peer_id, parent_projectile_id, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		print("_verify failed!!!")

		return
	end

	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)
	local tweak_entry = tweak_data.projectiles[projectile_entry]

	if tweak_entry.client_authoritative then
		if not unit then
			local unit_name = Idstring(tweak_entry.local_unit)
			unit = World:spawn_unit(unit_name, pos, Rotation(dir, math.UP))
		end

		unit:base():set_owner_peer_id(peer_id)
	end

	if not alive(unit) then
		print("unit is not alive!!!")

		return
	end

	local server_peer = managers.network:session():server_peer()

	if tweak_entry.throwable and not peer == server_peer then
		print("projectile is throwable, should not be thrown by client!!!")

		return
	end

	local no_cheat_count = tweak_entry.no_cheat_count

	if not no_cheat_count then
		managers.player:verify_grenade(peer_id)
	end

	local member = managers.network:session():peer(peer_id)
	local thrower_unit = member and member:unit()

	if thrower_unit then
		unit:base():set_thrower_unit(thrower_unit)
		unit:base():set_thrower_peer_id(peer_id)

		if not tweak_entry.throwable and thrower_unit:movement() and thrower_unit:movement():current_state() then
			unit:base():set_weapon_unit(thrower_unit:movement():current_state()._equipped_unit)
		end
	end

	if parent_projectile_id then
		unit:base():set_parent_projectile_id(parent_projectile_id)
	end

	unit:base():sync_throw_projectile(dir, projectile_type)
end

-- Lines 2258-2271
function UnitNetworkHandler:sync_detonate_molotov_grenade(unit, ext_name, event_id, normal, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local extension = unit[ext_name](unit)

	if not extension then
		debug_pause("[UnitNetworkHandler:sync_detonate_molotov_grenade] unit", unit, "does not have extension", ext_name)

		return
	end

	extension:sync_detonate_molotov_grenade(event_id, normal, peer)
end

-- Lines 2275-2282
function UnitNetworkHandler:sync_fall_position(unit, pos, rot)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:movement():sync_fall_position(pos, rot)
	end
end

-- Lines 2286-2291
function UnitNetworkHandler:sync_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, rpc)
	local peer = self._verify_sender(rpc)

	managers.fire:sync_add_fire_dot(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, peer)
end

-- Lines 2295-2302
function UnitNetworkHandler:server_secure_loot(carry_id, multiplier_level, silent, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.loot:server_secure_loot(carry_id, multiplier_level, silent)
end

-- Lines 2304-2310
function UnitNetworkHandler:sync_secure_loot(carry_id, multiplier_level, silent, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) and not self._verify_gamestate(self._gamestate_filter.any_end_game) or not self._verify_sender(sender) then
		return
	end

	managers.loot:sync_secure_loot(carry_id, multiplier_level, silent)
end

-- Lines 2312-2318
function UnitNetworkHandler:sync_small_loot_taken(unit, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit:base():taken()
end

-- Lines 2322-2328
function UnitNetworkHandler:sync_heist_time(time, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.game_play_central:sync_heist_time(time)
end

-- Lines 2332-2371
function UnitNetworkHandler:set_teammate_hud(unit, percent, id, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) or not PlayerDamage then
		return
	end

	local peer = self._verify_sender(sender)
	local peer_id = peer:id()
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if id == PlayerDamage.HUD_NET_EVENTS.health then
		if character_data and character_data.panel_id then
			managers.hud:set_teammate_health(character_data.panel_id, {
				total = 1,
				max = 1,
				current = percent / 100
			})
			character_data.unit:character_damage():set_health_ratio(percent / 100)
		else
			managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, percent / 100)
		end

		if percent ~= 100 then
			managers.mission:call_global_event("player_damaged")
		end
	elseif id == PlayerDamage.HUD_NET_EVENTS.armor then
		if character_data and character_data.panel_id then
			managers.hud:set_teammate_armor(character_data.panel_id, {
				total = 1,
				max = 1,
				current = percent / 100
			})
		else
			managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, percent / 100)
		end
	elseif id == PlayerDamage.HUD_NET_EVENTS.stored_health then
		if character_data and character_data.panel_id then
			managers.hud:set_teammate_stored_health(character_data.panel_id, percent / 100)
		else
			managers.hud:set_mugshot_stored_health(unit:unit_data().mugshot_id, percent / 100)
		end
	elseif id == PlayerDamage.HUD_NET_EVENTS.stored_health_max then
		if character_data and character_data.panel_id then
			managers.hud:set_teammate_stored_health_max(character_data.panel_id, percent / 100)
		else
			managers.hud:set_mugshot_stored_health_max(unit:unit_data().mugshot_id, percent / 100)
		end
	end
end

-- Lines 2373-2387
function UnitNetworkHandler:set_armor(unit, percent, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local peer = self._verify_sender(sender)
	local peer_id = peer:id()
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:set_teammate_armor(character_data.panel_id, {
			total = 1,
			max = 1,
			current = percent / 100
		})
	else
		managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, percent / 100)
	end
end

-- Lines 2389-2411
function UnitNetworkHandler:set_health(unit, percent, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local peer = self._verify_sender(sender)
	local peer_id = peer:id()
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)
	local health_ratio = percent / 100

	if character_data and character_data.panel_id then
		managers.hud:set_teammate_health(character_data.panel_id, {
			total = 1,
			max = 1,
			current = health_ratio
		})
	else
		managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, health_ratio)
	end

	if percent ~= 100 then
		managers.mission:call_global_event("player_damaged")
	end

	unit:character_damage():set_health_ratio(health_ratio)
end

-- Lines 2413-2418
function UnitNetworkHandler:sync_equipment_possession(peer_id, equipment, amount, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.player:set_synced_equipment_possession(peer_id, equipment, amount)
end

-- Lines 2420-2430
function UnitNetworkHandler:sync_remove_equipment_possession(peer_id, equipment, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local equipment_peer = managers.network:session():peer(peer_id)

	if not equipment_peer then
		print("[UnitNetworkHandler:sync_remove_equipment_possession] unknown peer", peer_id)

		return
	end

	managers.player:remove_equipment_possession(peer_id, equipment)
end

-- Lines 2434-2439
function UnitNetworkHandler:sync_start_anticipation()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.hud:sync_start_anticipation()
end

-- Lines 2441-2446
function UnitNetworkHandler:sync_start_anticipation_music()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.hud:sync_start_anticipation_music()
end

-- Lines 2448-2453
function UnitNetworkHandler:sync_start_assault()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.hud:sync_start_assault()
end

-- Lines 2455-2460
function UnitNetworkHandler:sync_end_assault(result)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.hud:sync_end_assault(result)
end

-- Lines 2464-2489
function UnitNetworkHandler:sync_contour_state(unit, u_id, type, state, multiplier, damage_multiplier, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local contour_unit = nil

	if alive(unit) and unit:id() ~= -1 then
		contour_unit = unit
	else
		local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)

		if unit_data then
			contour_unit = unit_data.unit
		end
	end

	if not contour_unit then
		Application:error("[UnitNetworkHandler:sync_contour_state] Unit is missing")

		return
	end

	if state then
		contour_unit:contour():add(ContourExt.indexed_types[type], false, multiplier, damage_multiplier)
	else
		contour_unit:contour():remove(ContourExt.indexed_types[type], nil)
	end
end

-- Lines 2493-2513
function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	local health_multiplier = 1

	if convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.convert_enemies_health_multiplier[convert_enemies_health_multiplier_level]
	end

	if passive_convert_enemies_health_multiplier_level > 0 then
		health_multiplier = health_multiplier * tweak_data.upgrades.values.player.passive_convert_enemies_health_multiplier[passive_convert_enemies_health_multiplier_level]
	end

	unit:character_damage():convert_to_criminal(health_multiplier)
	unit:contour():add("friendly", false)
	managers.groupai:state():sync_converted_enemy(unit)

	if minion_owner_peer_id == managers.network:session():local_peer():id() then
		managers.player:count_up_player_minions()
	end
end

-- Lines 2515-2520
function UnitNetworkHandler:count_down_player_minions()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.player:count_down_player_minions()
end

-- Lines 2524-2529
function UnitNetworkHandler:sync_teammate_helped_hint(hint, helped_unit, helping_unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(helped_unit, sender) or not self._verify_character(helping_unit, sender) then
		return
	end

	managers.trade:sync_teammate_helped_hint(helped_unit, helping_unit, hint)
end

-- Lines 2533-2538
function UnitNetworkHandler:sync_assault_mode(enabled)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_assault_mode(enabled)
end

-- Lines 2542-2547
function UnitNetworkHandler:sync_hostage_killed_warning(warning)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_hostage_killed_warning(warning)
end

-- Lines 2551-2557
function UnitNetworkHandler:set_interaction_voice(unit, voice, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	unit:brain():set_interaction_voice(voice ~= "" and voice or nil)
end

-- Lines 2561-2566
function UnitNetworkHandler:sync_teammate_comment(message, pos, pos_based, radius, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.groupai:state():sync_teammate_comment(message, pos, pos_based, radius)
end

-- Lines 2568-2573
function UnitNetworkHandler:sync_teammate_comment_instigator(unit, message)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.groupai:state():sync_teammate_comment_instigator(unit, message)
end

-- Lines 2577-2582
function UnitNetworkHandler:begin_gameover_fadeout()
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():begin_gameover_fadeout()
end

-- Lines 2586-2598
function UnitNetworkHandler:send_statistics(total_kills, total_specials_kills, total_head_shots, accuracy, downs, revives, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_end_game) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	managers.statistics:on_statistics_recieved(peer:id(), total_kills, total_specials_kills, total_head_shots, accuracy, downs, revives)
end

-- Lines 2602-2619
function UnitNetworkHandler:sync_statistics_result(top_stat_1_id, top_stat_1_peer_id, top_stat_1_peer_name, top_stat_1_score, top_stat_2_id, top_stat_2_peer_id, top_stat_2_peer_name, top_stat_2_score, top_stat_3_id, top_stat_3_peer_id, top_stat_3_peer_name, top_stat_3_score, bottom_stat_1_id, bottom_stat_1_peer_id, bottom_stat_1_peer_name, bottom_stat_1_score, bottom_stat_2_id, bottom_stat_2_peer_id, bottom_stat_2_peer_name, bottom_stat_2_score, bottom_stat_3_id, bottom_stat_3_peer_id, bottom_stat_3_peer_name, bottom_stat_3_score)
	managers.statistics:set_top_stats(top_stat_1_id, top_stat_1_peer_id, top_stat_1_peer_name, top_stat_1_score, top_stat_2_id, top_stat_2_peer_id, top_stat_2_peer_name, top_stat_2_score, top_stat_3_id, top_stat_3_peer_id, top_stat_3_peer_name, top_stat_3_score)
	managers.statistics:set_bottom_stats(bottom_stat_1_id, bottom_stat_1_peer_id, bottom_stat_1_peer_name, bottom_stat_1_score, bottom_stat_2_id, bottom_stat_2_peer_id, bottom_stat_2_peer_name, bottom_stat_2_score, bottom_stat_3_id, bottom_stat_3_peer_id, bottom_stat_3_peer_name, bottom_stat_3_score)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.TOP_STATS_READY)
end

-- Lines 2623-2628
function UnitNetworkHandler:statistics_tied(name, sender)
end

-- Lines 2632-2640
function UnitNetworkHandler:bain_comment(bain_line, sender)
	if not self._verify_sender(sender) then
		return
	end

	if managers.dialog and managers.groupai and managers.groupai:state():bain_state() then
		managers.dialog:queue_dialog(bain_line, {})
	end
end

-- Lines 2644-2651
function UnitNetworkHandler:is_inside_point_of_no_return(is_inside, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.groupai:state():set_is_inside_point_of_no_return(peer:id(), is_inside)
end

-- Lines 2655-2668
function UnitNetworkHandler:mission_ended(win, num_is_inside, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if managers.platform:presence() == "Playing" then
		if win then
			game_state_machine:change_state_by_name("victoryscreen", {
				num_winners = num_is_inside,
				personal_win = not managers.groupai:state()._failed_point_of_no_return and alive(managers.player:player_unit())
			})
		else
			game_state_machine:change_state_by_name("gameoverscreen")
		end
	end
end

-- Lines 2672-2682
function UnitNetworkHandler:sync_character_level(level, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	level = math.clamp(level, 0, managers.experience:level_cap())

	peer:set_level(level)
end

-- Lines 2684-2705
function UnitNetworkHandler:sync_character_class_nationality(class, nationality, sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if not nationality or not tweak_data.criminals.character_nation_name[nationality] then
		debug_pause("[UnitNetworkHandler:sync_character_class_nationality] peer attempted to change to a non-existant nationality:", peer:id(), nationality)

		nationality = tweak_data.criminals.character_nations[1]
	end

	if not class or not tweak_data.skilltree.classes[class] then
		debug_pause("[UnitNetworkHandler:set_player_class] peer attempted to change to a non-existant class:", peer:id(), class)

		class = SkillTreeTweakData.CLASS_RECON
	end

	peer:set_class_nation(class, nationality)
end

-- Lines 2708-2717
function UnitNetworkHandler:update_matchmake_attributes(sender)
	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if Network:is_server() then
		managers.network:update_matchmake_attributes()
	end
end

-- Lines 2730-2736
function UnitNetworkHandler:sync_disable_shout(unit, state, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	ElementDisableShout.sync_function(unit, state)
end

-- Lines 2738-2744
function UnitNetworkHandler:sync_run_sequence_char(unit, seq, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	ElementSequenceCharacter.sync_function(unit, seq)
end

-- Lines 2746-2755
function UnitNetworkHandler:sync_player_kill_statistic(tweak_table_name, is_headshot, weapon_unit, variant, stats_name, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) or not alive(weapon_unit) then
		return
	end

	local data = {
		name = tweak_table_name,
		stats_name = stats_name,
		head_shot = is_headshot,
		weapon_unit = weapon_unit,
		variant = variant
	}

	managers.statistics:killed_by_anyone(data)

	local attacker_state = managers.player:current_state()
	data.attacker_state = attacker_state

	managers.statistics:killed(data)
end

-- Lines 2759-2770
function UnitNetworkHandler:set_attention_enabled(unit, setting_index, state, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	if unit:in_slot(managers.slot:get_mask("players")) and unit:base().is_husk_player then
		local setting_name = tweak_data.attention:get_attention_name(setting_index)

		unit:movement():sync_attention_setting(setting_name, state, false)
	else
		debug_pause_unit(unit, "[UnitNetworkHandler:set_attention_enabled] invalid unit", unit)
	end
end

-- Lines 2774-2780
function UnitNetworkHandler:link_attention_no_rot(parent_unit, attention_object, parent_object, local_pos, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not alive(parent_unit) or not alive(attention_object) then
		return
	end

	attention_object:attention():link(parent_unit, parent_object, local_pos)
end

-- Lines 2784-2790
function UnitNetworkHandler:unlink_attention(attention_object, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not alive(attention_object) then
		return
	end

	attention_object:attention():link(nil)
end

-- Lines 2794-2818
function UnitNetworkHandler:suspicion(suspect_peer_id, susp_value, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local suspect_member = managers.network:session():peer(suspect_peer_id)

	if not suspect_member then
		return
	end

	local suspect_unit = suspect_member:unit()

	if not suspect_unit then
		return
	end

	if susp_value == 0 then
		susp_value = false
	elseif susp_value == 255 then
		susp_value = true
	else
		susp_value = susp_value / 254
	end

	suspect_unit:movement():on_suspicion(nil, susp_value)
end

-- Lines 2822-2850
function UnitNetworkHandler:suspicion_hud(suspect_unit, observer_unit, status, suspect_id)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not alive(observer_unit) then
		return
	end

	if status == 0 then
		status = false
	elseif status == 2 then
		status = true
	elseif status == 3 then
		status = "calling"
	elseif status == 4 then
		status = "called"
	elseif status == 5 then
		status = "call_interrupted"
	elseif status == 6 then
		managers.hud._progress_target[observer_unit:id()] = nil
		status = false
	end

	if not suspect_unit and managers.hud._progress_target[observer_unit:id()] and managers.hud._progress_target[observer_unit:id()][suspect_id] then
		managers.hud._progress_target[observer_unit:id()][suspect_id] = nil
	end

	managers.groupai:state():on_criminal_suspicion_progress(suspect_unit, observer_unit, status)
end

-- Lines 2852-2866
function UnitNetworkHandler:spotter_hud(suspect_unit, observer_unit, status)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not alive(observer_unit) then
		return
	end

	if status == 0 then
		status = "remove"
	elseif status == 2 then
		status = "barrage"
	elseif status == 3 then
		status = "empty"
	end

	managers.groupai:state():on_spotter_detection_progress(suspect_unit, observer_unit, status)
end

-- Lines 2868-2883
function UnitNetworkHandler:sync_suspicion_icon(unit, icon_type, status)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local waypoint = managers.hud:get_waypoint_for_unit(unit)

	if waypoint then
		if icon_type == "aim" then
			managers.hud:set_aiming_icon(waypoint, status)
		elseif icon_type == "investigate" then
			managers.hud:set_investigate_icon(waypoint, status)
		end
	else
		Application:error("[UnitNetworkHandler:sync_suspicion_icon] Waypoint not found for unit", unit)
	end
end

-- Lines 2887-2893
function UnitNetworkHandler:group_ai_event(event_id, blame_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_event(event_id, blame_id)
end

-- Lines 2897-2917
function UnitNetworkHandler:start_timespeed_effect(effect_id, timer_name, affect_timer_names_str, speed, fade_in, sustain, fade_out, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local affect_timer_names = nil

	if affect_timer_names_str ~= "" then
		affect_timer_names = string.split(affect_timer_names_str, ";")
	end

	local effect_desc = {
		timer = timer_name,
		affect_timer = affect_timer_names,
		speed = speed,
		fade_in = fade_in,
		sustain = sustain,
		fade_out = fade_out
	}

	managers.time_speed:play_effect(effect_id, effect_desc)
end

-- Lines 2921-2927
function UnitNetworkHandler:stop_timespeed_effect(effect_id, fade_out_duration, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	managers.time_speed:stop_effect(effect_id, fade_out_duration)
end

-- Lines 2931-2944
function UnitNetworkHandler:sync_upgrade(unit, upgrade_category, upgrade_name, upgrade_level, unit_id_str, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(unit) then
		Application:error("[UnitNetworkHandler:sync_upgrade] Unit is missing", unit, upgrade_category, upgrade_name, upgrade_level, unit_id_str, sender)

		return
	end

	self:_chk_unit_too_early(unit, unit_id_str, "sync_upgrade", 1, unit, upgrade_category, upgrade_name, upgrade_level, unit_id_str)
	unit:base():set_upgrade_value(upgrade_category, upgrade_name, upgrade_level)
end

-- Lines 2948-2972
function UnitNetworkHandler:suppression(unit, ratio, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	local sup_tweak = unit:base():char_tweak().suppression

	if not sup_tweak then
		debug_pause_unit(unit, "[UnitNetworkHandler:suppression] husk missing suppression settings", unit)

		return
	end

	local amount_max = (sup_tweak.brown_point or sup_tweak.react_point)[2]
	local amount, panic_chance = nil

	if ratio == 16 then
		amount = "max"
		panic_chance = -1
	else
		amount = ratio == 15 and "max" or amount_max > 0 and amount_max * ratio / 15 or "max"
	end

	unit:character_damage():build_suppression(amount, panic_chance)
end

-- Lines 2976-2982
function UnitNetworkHandler:suppressed_state(unit, state, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	unit:movement():on_suppressed(state)
end

-- Lines 2986-2994
function UnitNetworkHandler:camera_yaw_pitch(cam_unit, yaw_255, pitch_255)
	if not alive(cam_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local yaw = 360 * yaw_255 / 255 - 180
	local pitch = 180 * pitch_255 / 255 - 90

	cam_unit:base():apply_rotations(yaw, pitch)
end

-- Lines 2998-3008
function UnitNetworkHandler:loot_link(loot_unit, parent_unit, sender)
	if not alive(loot_unit) or not alive(parent_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if loot_unit == parent_unit then
		loot_unit:carry_data():unlink()
	else
		loot_unit:carry_data():link_to(parent_unit)
	end
end

-- Lines 3012-3022
function UnitNetworkHandler:remove_unit(unit, sender)
	if not alive(unit) then
		return
	end

	if unit:id() ~= -1 then
		Network:detach_unit(unit)
	end

	unit:set_slot(0)
end

-- Lines 3026-3032
function UnitNetworkHandler:sync_gui_net_event(unit, event_id, value, sender)
	if not alive(unit) or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:digital_gui():sync_gui_net_event(event_id, value)
end

-- Lines 3036-3042
function UnitNetworkHandler:sync_proximity_activation(unit, proximity_name, range_data_string, sender)
	if not alive(unit) or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:damage():sync_proximity_activation(proximity_name, range_data_string)
end

-- Lines 3044-3064
function UnitNetworkHandler:sync_inflict_body_damage(body, unit, normal, position, direction, damage, velocity, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(body) then
		return
	end

	if not body:extension() then
		print("[UnitNetworkHandler:sync_inflict_body_damage] body has no extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage then
		print("[UnitNetworkHandler:sync_inflict_body_damage] body has no damage extension", body:name(), body:unit():name())

		return
	end

	if not body:extension().damage.damage_fire then
		print("[UnitNetworkHandler:sync_inflict_body_damage] body has no damage damage_bullet function", body:name(), body:unit():name())

		return
	end

	body:extension().damage:damage_fire(unit, normal, position, direction, damage, velocity)
end

-- Lines 3069-3084
function UnitNetworkHandler:sync_team_relation(team_index_1, team_index_2, relation_code)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local team_id_1 = tweak_data.levels:get_team_names_indexed()[team_index_1]
	local team_id_2 = tweak_data.levels:get_team_names_indexed()[team_index_2]
	local relation = relation_code == 1 and "neutral" or relation_code == 2 and "friend" or "foe"

	if not team_id_1 or not team_id_2 or relation_code < 1 or relation_code > 3 then
		debug_pause("[UnitNetworkHandler:sync_team_relation] invalid params", team_index_1, team_index_2, relation_code, Global.level_data.level_id)

		return
	end

	managers.groupai:state():set_team_relation(team_id_1, team_id_2, relation, nil)
end

-- Lines 3088-3100
function UnitNetworkHandler:sync_char_team(unit, team_index, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not self._verify_character(unit) then
		return
	end

	local team_id = tweak_data.levels:get_team_names_indexed()[team_index]
	local team_data = managers.groupai:state():team_data(team_id)

	unit:movement():set_team(team_data)
end

-- Lines 3104-3120
function UnitNetworkHandler:sync_vehicle_driving(action, unit, player)
	Application:debug("[DRIVING_NET] sync_vehicle_driving " .. action)

	if not alive(unit) then
		return
	end

	local ext = unit:npc_vehicle_driving()
	ext = ext or unit:vehicle_driving()

	if action == "start" then
		ext:sync_start(player)
	elseif action == "stop" then
		ext:sync_stop()
	end
end

-- Lines 3123-3129
function UnitNetworkHandler:sync_vehicle_set_input(unit, accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
	if not alive(unit) then
		return
	end

	unit:vehicle_driving():sync_set_input(accelerate, steer, brake, handbrake, gear_up, gear_down, forced_gear)
end

-- Lines 3131-3136
function UnitNetworkHandler:sync_vehicle_state(unit, position, rotation, velocity)
	if not alive(unit) then
		return
	end

	unit:vehicle_driving():sync_state(position, rotation, velocity)
end

-- Lines 3139-3144
function UnitNetworkHandler:sync_enter_vehicle_host(vehicle, seat_name, peer_id, player)
	if not alive(vehicle) then
		return
	end

	managers.player:server_enter_vehicle(vehicle, peer_id, player, seat_name)
end

-- Lines 3146-3154
function UnitNetworkHandler:sync_vehicle_player(action, vehicle, peer_id, player, seat_name, prev_seat_name)
	if action == "enter" then
		managers.player:sync_enter_vehicle(vehicle, peer_id, player, seat_name)
	elseif action == "exit" then
		managers.player:sync_exit_vehicle(peer_id, player)
	elseif action == "next_seat" then
		managers.player:sync_move_to_next_seat(vehicle, peer_id, player, seat_name, prev_seat_name)
	end
end

-- Lines 3156-3158
function UnitNetworkHandler:sync_vehicle_player_swithc_seat(action, vehicle, peer_id, player, seat_name, previous_seat_name, previous_occupant)
	managers.player:sync_move_to_next_seat(vehicle, peer_id, player, seat_name, previous_seat_name, previous_occupant)
end

-- Lines 3160-3162
function UnitNetworkHandler:sync_move_to_next_seat(vehicle, peer_id, player, seat_name)
	managers.player:server_move_to_next_seat(vehicle, peer_id, player, seat_name)
end

-- Lines 3164-3169
function UnitNetworkHandler:sync_vehicle_skin(vehicle, skin_name)
	if not alive(vehicle) then
		return
	end

	vehicle:vehicle_driving():set_skin(skin_name)
end

-- Lines 3171-3176
function UnitNetworkHandler:sync_vehicle_data(vehicle, state_name, occupant_driver, occupant_left, occupant_back_left, occupant_back_right, is_trunk_open, vehicle_health)
	if not alive(vehicle) then
		return
	end

	managers.vehicle:sync_vehicle_data(vehicle, state_name, occupant_driver, occupant_left, occupant_back_left, occupant_back_right, is_trunk_open, vehicle_health)
end

-- Lines 3178-3183
function UnitNetworkHandler:sync_npc_vehicle_data(vehicle, state_name, target_unit)
	if not alive(vehicle) then
		return
	end

	managers.vehicle:sync_npc_vehicle_data(vehicle, state_name, target_unit)
end

-- Lines 3186-3191
function UnitNetworkHandler:sync_vehicle_loot(vehicle, carry_id1, multiplier1, carry_id2, multiplier2, carry_id3, multiplier3)
	if not alive(vehicle) then
		return
	end

	managers.vehicle:sync_vehicle_loot(vehicle, carry_id1, multiplier1, carry_id2, multiplier2, carry_id3, multiplier3)
end

-- Lines 3193-3209
function UnitNetworkHandler:sync_ai_vehicle_action(action, vehicle, data, unit)
	if not alive(vehicle) then
		return
	end

	if action == "health" then
		vehicle:character_damage():sync_vehicle_health(data)
	elseif action == "revive" then
		vehicle:character_damage():sync_vehicle_revive(data)
	elseif action == "state" then
		vehicle:vehicle_driving():sync_vehicle_state(data)
	else
		if not alive(unit) then
			return
		end

		vehicle:vehicle_driving():sync_ai_vehicle_action(action, data, unit)
	end
end

-- Lines 3211-3216
function UnitNetworkHandler:server_store_loot_in_vehicle(vehicle, loot_bag)
	if not alive(vehicle) or not alive(loot_bag) then
		return
	end

	vehicle:vehicle_driving():server_store_loot_in_vehicle(loot_bag)
end

-- Lines 3218-3223
function UnitNetworkHandler:sync_vehicle_change_stance(shooting_unit, stance)
	if not alive(shooting_unit) then
		return
	end

	shooting_unit:movement():sync_vehicle_change_stance(stance)
end

-- Lines 3225-3230
function UnitNetworkHandler:sync_store_loot_in_vehicle(vehicle, loot_bag, carry_id, multiplier)
	if not alive(vehicle) or not alive(loot_bag) then
		return
	end

	vehicle:vehicle_driving():sync_store_loot_in_vehicle(loot_bag, carry_id, multiplier)
end

-- Lines 3232-3234
function UnitNetworkHandler:server_give_vehicle_loot_to_player(vehicle, peer_id)
	vehicle:vehicle_driving():server_give_vehicle_loot_to_player(peer_id)
end

-- Lines 3236-3238
function UnitNetworkHandler:sync_give_vehicle_loot_to_player(vehicle, carry_id, multiplier, peer_id)
	vehicle:vehicle_driving():sync_give_vehicle_loot_to_player(carry_id, multiplier, peer_id)
end

-- Lines 3240-3242
function UnitNetworkHandler:sync_vehicle_interact_trunk(vehicle, peer_id)
	vehicle:vehicle_driving():_interact_trunk(vehicle)
end

-- Lines 3244-3247
function UnitNetworkHandler:sync_remote_position(unit, head_pos, pos)
	unit:movement():sync_remote_position(head_pos, pos)
end

-- Lines 3249-3259
function UnitNetworkHandler:sync_vehicle_loot_enabled(vehicle, enabled)
	if not vehicle then
		return
	end

	if enabled then
		vehicle:vehicle_driving():enable_loot_interaction()
	else
		vehicle:vehicle_driving():disable_loot_interaction()
	end
end

-- Lines 3261-3271
function UnitNetworkHandler:sync_vehicle_accepting_loot(vehicle, enabled)
	if not vehicle then
		return
	end

	if enabled then
		vehicle:vehicle_driving():enable_accepting_loot()
	else
		vehicle:vehicle_driving():disable_accepting_loot()
	end
end

-- Lines 3276-3284
function UnitNetworkHandler:sync_unit_data(unit, world_id, editor_id)
	local world = managers.worldcollection:worlddefinition_by_id(world_id)

	if world then
		world:sync_unit_data(unit, editor_id)
	else
		debug_pause("[UnitNetworkHandler:sync_unit_data] Network message arrived for non existant world (unit, world_id, editor_id).", unit, world_id, editor_id, inspect(managers.worldcollection._world_definitions))
	end
end

-- Lines 3286-3292
function UnitNetworkHandler:sync_vehicle_turret_rot(vehicle, rotation)
	Application:debug("[UnitNetworkHandler] sync_vehicle_turret_rot", vehicle)

	if alive(vehicle) then
		vehicle:mounted_weapon():set_turret_target_rot(rotation, false)
	end
end

-- Lines 3294-3305
function UnitNetworkHandler:sync_damage_reduction_buff(damage_reduction)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not damage_reduction then
		debug_pause("[UnitNetworkHandler:sync_damage_reduction_buff] invalid params", damage_reduction)

		return
	end

	managers.groupai:state():set_phalanx_damage_reduction_buff(damage_reduction)
end

-- Lines 3309-3315
function UnitNetworkHandler:sync_assault_endless(enabled)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():set_assault_endless(enabled)
end

-- Lines 3319-3327
function UnitNetworkHandler:action_jump(unit, pos, jump_vec, sender)
	if not self._verify_character_and_sender(unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(unit) then
		return
	end

	unit:movement():sync_action_jump(pos, jump_vec)
end

-- Lines 3329-3337
function UnitNetworkHandler:action_jump_middle(unit, pos, sender)
	if not self._verify_character_and_sender(unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(unit) then
		return
	end

	unit:movement():sync_action_jump_middle(pos)
end

-- Lines 3339-3347
function UnitNetworkHandler:action_land(unit, pos, sender)
	if not self._verify_character_and_sender(unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(unit) then
		return
	end

	unit:movement():sync_action_land(pos)
end

-- Lines 3349-3356
function UnitNetworkHandler:sync_fall_position(unit, pos, rot)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:movement():sync_fall_position(pos, rot)
	end
end

-- Lines 3360-3367
function UnitNetworkHandler:sync_ground_turret_rot(player_rotation, turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_turret_rotation(player_rotation)
	end
end

-- Lines 3369-3376
function UnitNetworkHandler:sync_ground_turret_activate(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():set_active(true)
	end
end

-- Lines 3378-3385
function UnitNetworkHandler:sync_ground_turret_start_autofire(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():start_autofire()
	end
end

-- Lines 3387-3394
function UnitNetworkHandler:sync_ground_turret_stop_autofire(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():stop_autofire()
	end
end

-- Lines 3396-3403
function UnitNetworkHandler:sync_ground_turret_trigger_held(turret_unit, blanks, expend_ammo, shoot_player, target_unit, damage_multiplier, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():trigger_held(blanks, expend_ammo, shoot_player, target_unit, damage_multiplier)
	end
end

-- Lines 3405-3412
function UnitNetworkHandler:sync_ground_turret_activate_as_module(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:base():activate_as_module("combatant", "turret_m2")
	end
end

-- Lines 3414-3421
function UnitNetworkHandler:sync_ground_turret_husk(husk_pos, turret_rot, enter_animation, exit_animation, turret_unit, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	managers.player:set_synced_turret(peer, husk_pos, turret_rot, enter_animation, exit_animation, turret_unit)
end

-- Lines 3423-3434
function UnitNetworkHandler:sync_ground_turret_SO_completed(turret_unit, puppet_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) and alive(puppet_unit) then
		if turret_unit:weapon()._SO_object then
			puppet_unit:warp_to(turret_unit:weapon()._SO_object:rotation(), turret_unit:weapon()._SO_object:position())
		end

		turret_unit:weapon():sync_SO_completed(puppet_unit)
	end
end

-- Lines 3436-3443
function UnitNetworkHandler:sync_ground_turret_SO_administered(turret_unit, administered_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_administered_unit(administered_unit)
	end
end

-- Lines 3445-3452
function UnitNetworkHandler:sync_ground_turret_create_SO(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_create_SO()
	end
end

-- Lines 3454-3461
function UnitNetworkHandler:sync_ground_turret_cancel_SO(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_cancel_SO()
	end
end

-- Lines 3463-3470
function UnitNetworkHandler:sync_ground_turret_activate_triggers(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_activate_triggers()
	end
end

-- Lines 3473-3480
function UnitNetworkHandler:sync_player_on(turret_unit, player_on, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():set_player_on(player_on)
	end
end

-- Lines 3482-3489
function UnitNetworkHandler:sync_ground_turret_exit_triggers(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():sync_exit_triggers()
	end
end

-- Lines 3491-3498
function UnitNetworkHandler:sync_ground_turret_puppet_damaged(turret_unit, attacker_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():on_puppet_damaged_client(attacker_unit)
	end
end

-- Lines 3500-3507
function UnitNetworkHandler:sync_ground_turret_puppet_death(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():on_puppet_death_client()
	end
end

-- Lines 3510-3517
function UnitNetworkHandler:sync_ground_turret_deactivate(turret_unit, sender)
	if not self._verify_sender(sender) then
		return
	end

	if alive(turret_unit) then
		turret_unit:weapon():deactivate_client()
	end
end

-- Lines 3520-3527
function UnitNetworkHandler:sync_ground_turret_shell_explosion(unit, position, range, damage, player_damage, curve_pow, rpc)
	local peer = self._verify_sender(rpc)

	if not peer or not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	unit:weapon():_shell_explosion_on_client(position, range, damage, player_damage, curve_pow)
end

-- Lines 3543-3550
function UnitNetworkHandler:register_grenades_pickup(pickup_unit, number_of_grenades, sender)
	local peer = self._verify_sender(sender)

	if not peer or not alive(pickup_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	pickup_unit:pickup():register_grenades(number_of_grenades, peer)
end

-- Lines 3556-3572
function UnitNetworkHandler:register_munitions_stack_size(stack_unit, stack_size, sender)
	if not alive(stack_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local stack_unit_ext = stack_unit:base()
	stack_unit_ext = stack_unit_ext or stack_unit:pickup()

	if stack_unit_ext and stack_unit_ext.sync_pickup_munitions_size then
		stack_unit_ext:sync_pickup_munitions_size(stack_size)
	end
end

-- Lines 3575-3591
function UnitNetworkHandler:sync_pickup_munitions_stack(stack_unit, stack_consume, sender)
	if not alive(stack_unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local stack_unit_ext = stack_unit:base()
	stack_unit_ext = stack_unit_ext or stack_unit:pickup()

	if stack_unit_ext and stack_unit_ext.sync_pickup_munitions_stack then
		stack_unit_ext:sync_pickup_munitions_stack(stack_consume)
	end
end

-- Lines 3599-3607
function UnitNetworkHandler:sync_grenade_freeze(unit, pos, rot, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if unit:base() then
		unit:base():sync_grenade_freeze(pos, rot)
	end
end

-- Lines 3609-3623
function UnitNetworkHandler:sync_character_nationality_switch(unit, character_nationality, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		print("_verify failed!!!")

		return
	end

	if unit and alive(unit) then
		unit:damage():run_sequence_simple(character_nationality)
	end
end

-- Lines 3626-3630
function UnitNetworkHandler:sync_distance_to_target(unit, distance)
	if alive(unit) then
		unit:brain():set_distance_to_target(distance)
	end
end

-- Lines 3632-3641
function UnitNetworkHandler:sync_loot_value(unit, value, sender)
	if not self._verify_sender(sender) then
		return
	end

	if unit and alive(unit) then
		unit:loot_drop():set_value(value)
	end
end

-- Lines 3643-3650
function UnitNetworkHandler:sync_warp_position(unit, pos, rot)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:movement():sync_warp_position(pos, rot)
	end
end

-- Lines 3652-3659
function UnitNetworkHandler:sync_stored_pos(unit, allow_sync, pos, rot)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:base():sync_stored_pos(allow_sync, pos, rot)
	end
end

-- Lines 3661-3664
function UnitNetworkHandler:sync_spawn_ammo_bag(pos, dir, level_idx, sender)
	local peer = self._verify_sender(sender)

	ThrowableAmmoBag.spawn(pos, dir, level_idx, peer:unit())
end

-- Lines 3666-3668
function UnitNetworkHandler:sync_throw_ammo_bag(unit, dir, sender)
	ThrowableAmmoBag.throw_bag(unit, dir)
end

-- Lines 3670-3672
function UnitNetworkHandler:sync_ammo_bag_level(unit, level_index, sender)
	ThrowableAmmoBag.set_level(unit, level_index)
end

-- Lines 3674-3677
function UnitNetworkHandler:sync_ammo_bag_hit_player(player_unit, ammo_bag_unit, bag_owner_peer_id, sender)
	local picked_up = ThrowableAmmoBag.interact_pickup(ammo_bag_unit, player_unit, bag_owner_peer_id)

	managers.network:session():send_to_host("ammo_bag_pickup_response", ammo_bag_unit, picked_up)
end

-- Lines 3679-3684
function UnitNetworkHandler:ammo_bag_pickup_response(ammo_bag_unit, picked_up, sender)
	if alive(ammo_bag_unit) then
		local peer = self._verify_sender(sender)

		ammo_bag_unit:base():from_client_response(picked_up, peer:name())
	end
end

-- Lines 3686-3698
local function warcry_dmg_func(peer_name, data)
	local percent = Utl.mul_to_string_percent(data)
	local notification_data = {
		priority = 1,
		duration = 5,
		id = "skill_ammo_warcry_from",
		icon = "test_icon",
		force = true,
		notification_type = HUDNotification.ICON,
		text = managers.localization:text("skill_ammo_warcry_from", {
			NAME = peer_name,
			PERCENT = percent
		})
	}

	managers.notification:add_notification(notification_data)
end

local gui_notification = {
	warcry_dmg_func
}

-- Lines 3705-3723
function UnitNetworkHandler:sync_warcry(source_unit, radius_idx, effect_name_idx, effect_data_idx, time_idx, gui_notification_idx, sender)
	if alive(source_unit) then
		local pm = managers.player
		local player_unit = pm:player_unit()

		if player_unit and alive(player_unit) then
			local source_pos = source_unit:position()
			local player_pos = player_unit:position()
			local radius = UpgradesTweakData.WARCRY_RADIUS[radius_idx]

			if mvector3.distance_sq(source_pos, player_pos) < radius * radius then
				local effect_name = UpgradesTweakData.WARCRY_EFFECT_NAME[effect_name_idx]
				local effect_data = UpgradesTweakData.WARCRY_EFFECT_DATA[effect_data_idx]
				local time = UpgradesTweakData.WARCRY_TIME[time_idx]

				pm:activate_temporary_property(effect_name, time, effect_data)

				local peer = self._verify_sender(sender)

				gui_notification[gui_notification_idx](peer:name(), effect_data)
			end
		end
	end
end

-- Lines 3727-3738
function UnitNetworkHandler:sync_unit_spawn(parent_unit, spawn_unit, align_obj_name, unit_id, parent_extension_name, offset_position, offset_rotation)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(parent_unit) or not alive(spawn_unit) then
		return
	end

	parent_unit[parent_extension_name](parent_unit):spawn_unit(unit_id, align_obj_name, spawn_unit, offset_position, offset_rotation)
	parent_unit[parent_extension_name](parent_unit):sync_unit_spawn(unit_id)
end

-- Lines 3742-3752
function UnitNetworkHandler:run_spawn_unit_sequence(parent_unit, parent_extension_name, unit_id, sequence_name)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(parent_unit) then
		return
	end

	parent_unit[parent_extension_name](parent_unit):_spawn_run_sequence(unit_id, sequence_name)
end

-- Lines 3756-3766
function UnitNetworkHandler:run_local_push_child_unit(parent_unit, parent_extension_name, unit_id, mass, pow, vec3_a, vec3_b)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(parent_unit) then
		return
	end

	parent_unit[parent_extension_name](parent_unit):local_push_child_unit(unit_id, mass, pow, vec3_a, vec3_b)
end

-- Lines 3770-3775
function UnitNetworkHandler:leave_flamethrower_patch(subject_unit, sender)
	if not self._verify_character_and_sender(subject_unit, sender) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.fire:leave_flamethrower_patch(subject_unit)
end

-- Lines 3777-3784
function UnitNetworkHandler:sync_camp_asset(unit, level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:gold_asset():apply_upgrade_level(level)
	end
end

-- Lines 3786-3793
function UnitNetworkHandler:sync_automatic_camp_asset(unit, level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:gold_asset():local_apply_upgrade_level(level)
	end
end

-- Lines 3797-3805
function UnitNetworkHandler:sync_foxhole_state(unit, foxhole, state)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) and unit:movement() then
		unit:movement():set_foxhole_state(state, foxhole)
	end
end

-- Lines 3809-3817
function UnitNetworkHandler:set_escort_active(unit, active)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) and unit:escort() then
		unit:escort():set_active(active)
	end
end

-- Lines 3819-3830
function UnitNetworkHandler:sync_ai_interaction_start(unit, duration, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		local teammate_panel_id = unit:unit_data().teammate_panel_id
		local name_label_id = unit:unit_data().name_label_id

		managers.hud:teammate_start_progress(teammate_panel_id, name_label_id, duration)
	end
end

-- Lines 3832-3843
function UnitNetworkHandler:sync_ai_interaction_cancel(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		local teammate_panel_id = unit:unit_data().teammate_panel_id
		local name_label_id = unit:unit_data().name_label_id

		managers.hud:teammate_cancel_progress(teammate_panel_id, name_label_id)
	end
end

-- Lines 3845-3856
function UnitNetworkHandler:sync_ai_interaction_complete(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		local teammate_panel_id = unit:unit_data().teammate_panel_id
		local name_label_id = unit:unit_data().name_label_id

		managers.hud:teammate_complete_progress(teammate_panel_id, name_label_id)
	end
end

-- Lines 3858-3865
function UnitNetworkHandler:sync_camp_trophy(unit, level, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		managers.progression:sync_trophy_level(unit, level)
	end
end

-- Lines 3867-3876
function UnitNetworkHandler:sync_revive_pumpkin_destroyed(pumpkin, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(pumpkin) then
		pumpkin:revive_pumpkin():set_should_sync(false)
		pumpkin:set_slot(0)
	end
end

-- Lines 3878-3890
function UnitNetworkHandler:sync_honk_horn(vehicle, honk_state, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(vehicle) and vehicle.vehicle_driving then
		if honk_state == true then
			vehicle:vehicle_driving():play_horn_sound()
		else
			vehicle:vehicle_driving():stop_horn_sound()
		end
	end
end

-- Lines 3893-3901
function UnitNetworkHandler:sync_pile_store_carry(align_unit, carry_unit, carry_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(align_unit) and alive(carry_unit) then
		align_unit:carry_align():client_store_carry(carry_unit, carry_id)
	end
end

-- Lines 3904-3912
function UnitNetworkHandler:sync_pile_remove_carry(unit, carry_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) then
		unit:carry_align():client_remove_carry(carry_id)
	end
end

-- Lines 3915-3923
function UnitNetworkHandler:sync_set_lootcrate_tier(unit, tier, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if alive(unit) and unit:interaction() then
		unit:interaction():set_lootcrate_tier(tier)
	end
end

-- Lines 3926-3938
function UnitNetworkHandler:sync_martyrdom(unit, projectile_type, sender)
	if not alive(unit) or not self._verify_sender(sender) then
		return
	end

	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	if not projectile_entry or not tweak_data.projectiles[projectile_entry] then
		return
	end

	unit:character_damage():sync_martyrdom(projectile_entry)
end
