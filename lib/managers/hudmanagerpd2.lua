core:import("CoreEvent")
require("lib/managers/hud/HUDTeammateBase")
require("lib/managers/hud/HUDTeammatePlayer")
require("lib/managers/hud/HUDTeammateAI")
require("lib/managers/hud/HUDTeammatePeer")
require("lib/managers/hud/HUDWeapon/HUDWeaponBase")
require("lib/managers/hud/HUDWeapon/HUDWeaponGeneric")
require("lib/managers/hud/HUDWeapon/HUDWeaponGrenade")
require("lib/managers/hud/HUDWeapon/HUDWeaponClipShots")
require("lib/managers/hud/HUDWeapon/HUDWeaponDrum")
require("lib/managers/hud/HUDWeapon/HUDWeaponRevolver")
require("lib/managers/hud/HUDEquipment")
require("lib/managers/hud/HUDInteraction")
require("lib/managers/hud/HUDCardDetails")
require("lib/managers/hud/HUDMapWaypoint")
require("lib/managers/hud/HUDMapPlayerPin")
require("lib/managers/hud/HUDMapBase")
require("lib/managers/hud/HUDMapTab")
require("lib/managers/hud/HUDTabGreedBar")
require("lib/managers/hud/HUDTabWeaponChallenge")
require("lib/managers/hud/HUDTabScreen")
require("lib/managers/hud/HUDNameLabel")
require("lib/managers/hud/HUDNameVehicleLabel")
require("lib/managers/hud/HUDObjectives")
require("lib/managers/hud/HUDObjectivesTab")
require("lib/managers/hud/HUDObjectiveBase")
require("lib/managers/hud/HUDObjectiveSub")
require("lib/managers/hud/HUDObjectiveMain")
require("lib/managers/hud/HUDObjectiveDescription")
require("lib/managers/hud/HUDToastNotification")
require("lib/managers/hud/HUDCarry")
require("lib/managers/hud/HUDChat")
require("lib/managers/hud/HUDChatMessage")
require("lib/managers/hud/HUDDriving")
require("lib/managers/hud/HUDHitConfirm")
require("lib/managers/hud/HUDHitDirection")
require("lib/managers/hud/HUDSuspicion")
require("lib/managers/hud/HUDSuspicionIndicator")
require("lib/managers/hud/HUDSuspicionDirection")
require("lib/managers/hud/HUDPlayerCustody")
require("lib/managers/hud/HUDMotionDot")
require("lib/managers/hud/HUDCenterPrompt")
require("lib/managers/hud/HUDBigPrompt")
require("lib/managers/hud/HUDSpecialInteraction")
require("lib/managers/hud/HUDMultipleChoiceWheel")
require("lib/managers/hud/HUDTurret")
require("lib/managers/hud/HUDWatermark/HUDWatermarkBase")
require("lib/managers/hud/HUDPlayerVoiceChatStatus")

HUDManager.disabled = {
	[Idstring("guis/player_hud"):key()] = true,
	[Idstring("guis/experience_hud"):key()] = true
}
HUDManager.PLAYER_PANEL = 4
HUDManager.TEAMMATE_PANEL_W = 444
HUDManager.TEAMMATE_PANEL_DISTANCE = 32
HUDManager.AI_TEAMMATE_PANEL_PADDING = 18
HUDManager.PEER_TEAMMATE_PANEL_PADDING = 10
HUDManager.WEAPONS_PANEL_W = 384
HUDManager.WEAPONS_PANEL_H = 84
HUDManager.CHAT_DISTANCE_FROM_BOTTOM = 128

-- Lines 70-74
function HUDManager:controller_mod_changed()
	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end
end

-- Lines 78-141
function HUDManager:add_weapon(data)
	self._hud.weapons[data.inventory_index] = {
		inventory_index = data.inventory_index,
		unit = data.unit
	}
	local tweak_data = data.unit:base():weapon_tweak_data()

	if tweak_data.hud and (not self._weapon_panels[data.inventory_index] or self._weapon_panels[data.inventory_index] and self._weapon_panels[data.inventory_index]:name_id() ~= tweak_data.name_id) then
		if self._weapon_panels[data.inventory_index] then
			self._weapon_panels[data.inventory_index]:destroy()
		end

		self._weapon_panels[data.inventory_index] = nil
		local weapons_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:child("weapons_panel")

		if data.inventory_index == 1 or data.inventory_index == 2 then
			local weapon_hud_type = data.unit:base():get_weapon_hud_type()

			if weapon_hud_type then
				tweak_data = deep_clone(tweak_data)

				for k, v in pairs(weapon_hud_type) do
					tweak_data.hud[k] = v
				end
			end
		end

		local panel_class_id = tweak_data.hud and tweak_data.hud.panel_class

		if panel_class_id then
			local is_grenade = panel_class_id and panel_class_id == "grenade"
			local use_custom_ui = managers.user:get_setting("hud_special_weapon_panels") or is_grenade
			local panel_class = use_custom_ui and self._weapon_panel_classes[panel_class_id] or HUDWeaponGeneric
			self._weapon_panels[data.inventory_index] = panel_class:new(data.inventory_index, weapons_panel, tweak_data)
		else
			self._weapon_panels[data.inventory_index] = HUDWeaponGeneric:new(data.inventory_index, weapons_panel, tweak_data)
		end

		self:_layout_weapon_panels()
	end

	if data.is_equip then
		self:set_weapon_selected_by_inventory_index(data.inventory_index)
	end

	if not data.is_equip and (data.inventory_index == 1 or data.inventory_index == 2) then
		self:_update_second_weapon_ammo_info(HUDManager.PLAYER_PANEL, data.unit)
	end
end

-- Lines 143-172
function HUDManager:_layout_weapon_panels()
	local weapons_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:child("weapons_panel")
	local right = weapons_panel:w()
	local bottom = weapons_panel:h()
	local w = 0

	for i = #self._weapon_panels, 1, -1 do
		if i ~= 2 then
			self._weapon_panels[i]:set_x(right - self._weapon_panels[i]:w())
			self._weapon_panels[i]:set_y(bottom - self._weapon_panels[i]:h())

			right = right - self._weapon_panels[i]:w()
			w = w + self._weapon_panels[i]:w()
		end
	end

	if self._weapon_panels[2] then
		self._weapon_panels[2]:set_x(right - self._weapon_panels[2]:w())
		self._weapon_panels[2]:set_y(bottom - self._weapon_panels[2]:h())

		right = right - self._weapon_panels[2]:w()
		w = w + self._weapon_panels[2]:w()
	end

	weapons_panel:set_w(w)
	weapons_panel:set_right(weapons_panel:parent():w())
	weapons_panel:set_bottom(weapons_panel:parent():h())
end

-- Lines 175-177
function HUDManager:set_weapon_selected_by_inventory_index(inventory_index)
	self:_set_weapon_selected(inventory_index)
end

-- Lines 180-185
function HUDManager:_set_weapon_selected(id)
	self._hud.selected_weapon = id
	local icon = self._hud.weapons[self._hud.selected_weapon].unit:base():weapon_tweak_data().hud and self._hud.weapons[self._hud.selected_weapon].unit:base():weapon_tweak_data().hud.icon

	self:_set_teammate_weapon_selected(HUDManager.PLAYER_PANEL, id, icon)
end

-- Lines 190-198
function HUDManager:_set_teammate_weapon_selected(i, id, icon)
	if i ~= HUDManager.PLAYER_PANEL then
		return
	end

	for j = 1, #self._weapon_panels do
		self._weapon_panels[j]:set_selected(j == id)
	end
end

-- Lines 200-204
function HUDManager:unselect_all_weapons()
	for i = 1, #self._weapon_panels do
		self._weapon_panels[i]:set_selected(false)
	end
end

-- Lines 207-211
function HUDManager:recreate_weapon_firemode(i)
end

-- Lines 214-219
function HUDManager:set_teammate_weapon_firemode(i, id, firemode)
	if i == HUDManager.PLAYER_PANEL then
		self._weapon_panels[id]:set_firemode(firemode)
	end
end

-- Lines 221-229
function HUDManager:set_firemode_for_weapon(weapon_name_id, firemode)
	for i = 1, #self._weapon_panels do
		local panel_name_id = self._weapon_panels[i]:name_id()

		if panel_name_id and panel_name_id == weapon_name_id then
			self._weapon_panels[i]:set_firemode(firemode)

			return
		end
	end
end

-- Lines 232-246
function HUDManager:set_ammo_amount(selection_index, max_clip, current_clip, current_left, max)
	if selection_index > 2 then
		return
	end

	self:set_teammate_ammo_amount(HUDManager.PLAYER_PANEL, selection_index, max_clip, current_clip, current_left, max)
end

-- Lines 250-271
function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max)
	local type = selection_index == 1 and "secondary" or "primary"

	self._weapon_panels[selection_index]:set_max_clip(max_clip)
	self._weapon_panels[selection_index]:set_current_clip(current_clip)
	self._weapon_panels[selection_index]:set_max(max)

	local total_ammo_without_current_clip = current_left - current_clip

	if total_ammo_without_current_clip < 0 then
		total_ammo_without_current_clip = 0
	end

	local is_empty = current_clip == 0 and total_ammo_without_current_clip == 0

	self._weapon_panels[selection_index]:set_current_left(total_ammo_without_current_clip)
	self._weapon_panels[selection_index]:set_no_ammo(is_empty)
end

-- Lines 274-279
function HUDManager:set_weapon_ammo_by_unit(unit)
	local second_weapon_index = self._hud.selected_weapon == 1 and 2 or 1

	if second_weapon_index == unit:base():weapon_tweak_data().use_data.selection_index then
		self:_update_second_weapon_ammo_info(HUDManager.PLAYER_PANEL, unit)
	end
end

-- Lines 282-284
function HUDManager:_update_second_weapon_ammo_info(i, unit)
end

-- Lines 286-288
function HUDManager:set_player_panel_character_data(data)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_character_data(data)
end

-- Lines 290-292
function HUDManager:refresh_player_panel()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:refresh()
end

-- Lines 294-297
function HUDManager:reset_player_state()
	self:reset_teammate_state(HUDManager.PLAYER_PANEL)
end

-- Lines 299-303
function HUDManager:reset_player_panel_states()
	for i = 1, #self._teammate_panels do
		self:reset_teammate_state(i)
	end
end

-- Lines 305-307
function HUDManager:reset_teammate_state(i)
	self._teammate_panels[i]:reset_state()
end

-- Lines 310-312
function HUDManager:set_player_health(data)
	self:set_teammate_health(HUDManager.PLAYER_PANEL, data)
end

-- Lines 314-323
function HUDManager:set_teammate_health(i, data)
	if self._teammate_panels[i] then
		self._teammate_panels[i]:set_health(data)
	else
		debug_pause("[ HUDManager:set_teammate_health ] teammate panel " .. tostring(i) .. " doesn't exist!")
		Application:error("data:", inspect(data))
		Application:error("teammate panels:", inspect(self._teammate_panels))
		Application:error(debug.traceback())
	end
end

-- Lines 325-327
function HUDManager:set_player_warcry_meter_fill(data)
	self:set_teammate_warcry_meter_fill(HUDManager.PLAYER_PANEL, data)
end

-- Lines 329-331
function HUDManager:set_teammate_warcry_meter_fill(i, data)
	self._teammate_panels[i]:set_warcry_meter_fill(data)
end

-- Lines 333-336
function HUDManager:set_player_warcry_meter_glow(value)
	self:set_warcry_meter_glow(HUDManager.PLAYER_PANEL, value)
end

-- Lines 339-342
function HUDManager:set_player_active_warcry(warcry)
	self:set_teammate_active_warcry(HUDManager.PLAYER_PANEL, nil, warcry)
end

-- Lines 344-351
function HUDManager:set_teammate_active_warcry(i, name_label_id, warcry)
	self._teammate_panels[i]:set_active_warcry(warcry)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:set_warcry(warcry)
	end
end

-- Lines 353-356
function HUDManager:set_warcry_meter_glow(i, value)
	self._teammate_panels[i]:set_warcry_ready(value)
end

-- Lines 358-365
function HUDManager:activate_teammate_warcry(i, name_label_id, duration)
	self._teammate_panels[i]:activate_warcry(duration)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:activate_warcry()
	end
end

-- Lines 367-373
function HUDManager:deactivate_player_warcry()
	self:set_player_warcry_meter_glow(false)
	self:remove_comm_wheel_option("warcry")
	self._sound_source:post_event("warcry_active_stop")
	self:hide_big_prompt()
	self:deactivate_teammate_warcry(HUDManager.PLAYER_PANEL, nil)
end

-- Lines 375-382
function HUDManager:deactivate_teammate_warcry(i, name_label_id)
	self._teammate_panels[i]:deactivate_warcry()

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:deactivate_warcry()
	end
end

-- Lines 384-387
function HUDManager:set_player_level(level)
	self:set_teammate_level(HUDManager.PLAYER_PANEL, level)
end

-- Lines 389-391
function HUDManager:set_teammate_level(i, level)
	self._teammate_panels[i]:set_level(level)
end

-- Lines 400-411
function HUDManager:show_teammate_turret_icon(teammate_panel_id, name_label_id)
	local panel = self._teammate_panels[teammate_panel_id]

	if panel ~= nil then
		panel:show_turret_icon()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:show_turret_icon()
	end
end

-- Lines 413-424
function HUDManager:hide_teammate_turret_icon(teammate_panel_id, name_label_id)
	local panel = self._teammate_panels[teammate_panel_id]

	if panel ~= nil then
		panel:hide_turret_icon()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:hide_turret_icon()
	end
end

-- Lines 427-428
function HUDManager:set_player_armor(data)
end

-- Lines 431-432
function HUDManager:set_teammate_armor(i, data)
end

-- Lines 434-437
function HUDManager:set_teammate_name(i, teammate_name)
	local is_local_player = i == HUDManager.PLAYER_PANEL

	self._teammate_panels[i]:set_name(teammate_name, is_local_player)
end

-- Lines 439-441
function HUDManager:set_player_nationality(nationality)
	self:set_teammate_nationality(HUDManager.PLAYER_PANEL, nationality)
end

-- Lines 443-445
function HUDManager:set_teammate_nationality(i, nationality)
	self._teammate_panels[i]:set_nationality(nationality)
end

-- Lines 447-449
function HUDManager:add_special_equipment(data)
	self:add_teammate_special_equipment(HUDManager.PLAYER_PANEL, data)
end

-- Lines 451-459
function HUDManager:add_teammate_special_equipment(i, data)
	if not i then
		Application:error("[HUDManager][add_teammate_special_equipment] - Didn't get a teammate panel number")
		Application:stack_dump()

		return
	end

	self._teammate_panels[i]:add_special_equipment(data)
end

-- Lines 461-463
function HUDManager:remove_special_equipment(equipment)
	self:remove_teammate_special_equipment(HUDManager.PLAYER_PANEL, equipment)
end

-- Lines 465-467
function HUDManager:remove_teammate_special_equipment(panel_id, equipment)
	self._teammate_panels[panel_id]:remove_special_equipment(equipment)
end

-- Lines 469-471
function HUDManager:set_special_equipment_amount(equipment_id, amount)
	self:set_teammate_special_equipment_amount(HUDManager.PLAYER_PANEL, equipment_id, amount)
end

-- Lines 473-475
function HUDManager:set_teammate_special_equipment_amount(i, equipment_id, amount)
	self._teammate_panels[i]:set_special_equipment_amount(equipment_id, amount)
end

-- Lines 477-479
function HUDManager:clear_player_special_equipments()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:clear_special_equipment()
end

-- Lines 482-484
function HUDManager:set_stored_health(stored_health_ratio)
end

-- Lines 487-489
function HUDManager:set_stored_health_max(stored_health_ratio)
end

-- Lines 528-530
function HUDManager:add_item(data)
end

-- Lines 533-535
function HUDManager:set_deployable_equipment(i, data)
end

-- Lines 538-540
function HUDManager:set_item_amount(index, amount)
end

-- Lines 543-545
function HUDManager:set_teammate_deployable_equipment_amount(i, index, data)
end

-- Lines 548-554
function HUDManager:set_teammate_grenades(i, data)
	if i == HUDManager.PLAYER_PANEL then
		self._weapon_panels[WeaponInventoryManager.BM_CATEGORY_GRENADES_ID]:set_amount(data.amount)
	end
end

-- Lines 557-563
function HUDManager:set_teammate_grenades_amount(i, data)
	if i == HUDManager.PLAYER_PANEL then
		self._weapon_panels[WeaponInventoryManager.BM_CATEGORY_GRENADES_ID]:set_amount(data.amount)
	end
end

-- Lines 565-567
function HUDManager:set_player_condition(icon_data, text)
	self:set_teammate_condition(HUDManager.PLAYER_PANEL, icon_data, text)
end

-- Lines 570-579
function HUDManager:set_teammate_condition(i, icon_data, text)
	if not i then
		print("Didn't get a number")
		Application:stack_dump()

		return
	end

	self._teammate_panels[i]:set_condition(icon_data, text)
end

-- Lines 581-593
function HUDManager:on_teammate_downed(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:go_into_bleedout()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:go_into_bleedout()
	end
end

-- Lines 595-607
function HUDManager:on_teammate_revived(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:on_revived()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:on_revived()
	end
end

-- Lines 609-620
function HUDManager:on_teammate_died(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:on_died()
	end
end

-- Lines 622-633
function HUDManager:on_teammate_start_lockpicking(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:show_lockpick_icon()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:show_lockpick_icon()
	end
end

-- Lines 635-646
function HUDManager:on_teammate_stop_lockpicking(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:hide_lockpick_icon()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:hide_lockpick_icon()
	end
end

-- Lines 648-657
function HUDManager:set_teammate_carry_info(teammate_panel_id, name_label_id, carry_id)
	if teammate_panel_id and self._teammate_panels[teammate_panel_id] and teammate_panel_id ~= HUDManager.PLAYER_PANEL then
		self._teammate_panels[teammate_panel_id]:set_carry_info(carry_id)
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:set_carry_info(carry_id)
	end
end

-- Lines 659-668
function HUDManager:remove_teammate_carry_info(teammate_panel_id, name_label_id)
	if teammate_panel_id and self._teammate_panels[teammate_panel_id] and teammate_panel_id ~= HUDManager.PLAYER_PANEL then
		self._teammate_panels[teammate_panel_id]:remove_carry_info()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:remove_carry_info()
	end
end

-- Lines 672-674
function HUDManager:start_player_timer(time)
	self:start_teammate_timer(HUDManager.PLAYER_PANEL, nil, time)
end

-- Lines 676-683
function HUDManager:start_teammate_timer(i, name_label_id, time, current)
	self._teammate_panels[i]:start_timer(time, current)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:start_timer(time, current)
	end
end

-- Lines 685-687
function HUDManager:is_teammate_timer_running(i)
	return self._teammate_panels[i]:is_timer_running()
end

-- Lines 689-691
function HUDManager:pause_player_timer(pause)
	self:pause_teammate_timer(HUDManager.PLAYER_PANEL, nil, pause)
end

-- Lines 693-700
function HUDManager:pause_teammate_timer(i, name_label_id, pause)
	self._teammate_panels[i]:set_pause_timer(pause)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:set_pause_timer(pause)
	end
end

-- Lines 702-704
function HUDManager:stop_player_timer()
	self:stop_teammate_timer(HUDManager.PLAYER_PANEL, nil)
end

-- Lines 706-715
function HUDManager:stop_teammate_timer(i, name_label_id)
	if self._teammate_panels[i] then
		self._teammate_panels[i]:stop_timer()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:stop_timer()
	end
end

-- Lines 719-756
function HUDManager:_setup_ingame_hud_saferect()
	Application:trace("[HUDManager]_setup_ingame_hud_saferect")

	if not self:alive(PlayerBase.INGAME_HUD_SAFERECT) then
		return
	end

	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

	self:_create_teammates_panel(hud)
	self:_create_weapons_panel(hud)
	self:_create_present_panel(hud)
	self:_create_interaction(hud)
	self:_create_pd_progress()
	self:_create_progress_timer(hud)
	self:_create_objectives(hud)
	self:_create_suspicion(hud)
	self:_create_hit_confirm(hud)
	self:_create_hit_direction(hud)
	self:_create_center_prompt(hud)
	self:_create_big_prompt(hud)
	self:_create_suspicion_direction(hud)
	self:_create_turret_hud(hud)
	self:_create_carry(hud)
	self:_setup_driving_hud()
	self:_create_custody_hud()
	self:_create_motiondot_hud()
	self:_create_hud_chat()
	self:_setup_tab_screen()
	self:_get_tab_objectives()
	self:_create_watermark(hud)
end

-- Lines 758-769
function HUDManager:_create_ammo_test()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

	if hud.panel:child("ammo_test") then
		hud.panel:remove(hud.panel:child("ammo_test"))
	end

	local panel = hud.panel:panel({
		name = "ammo_test",
		h = 4,
		y = 200,
		w = 100,
		x = 550
	})

	panel:set_center_y(hud.panel:h() / 2 - 40)
	panel:set_center_x(hud.panel:w() / 2)
	panel:rect({
		name = "ammo_test_bg_rect",
		color = Color.black:with_alpha(0.5)
	})
	panel:rect({
		name = "ammo_test_rect",
		layer = 1,
		color = Color.white
	})
end

-- Lines 771-773
function HUDManager:hud_chat()
	return self._hud_chat
end

-- Lines 775-796
function HUDManager:_create_hud_chat()
	local hud_ingame = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_respawn = managers.hud:script(IngameWaitingForRespawnState.GUI_SPECTATOR)

	if self._hud_chat_ingame then
		self._hud_chat_ingame:remove()
	end

	self._hud_chat_ingame = HUDChat:new(self._saferect, hud_ingame.panel, true)

	self._hud_chat_ingame:set_bottom(hud_ingame.panel:h() - HUDManager.CHAT_DISTANCE_FROM_BOTTOM)
	self._hud_chat_ingame:hide()
	self._hud_chat_ingame:unregister()

	if self._hud_chat_respawn then
		self._hud_chat_respawn:remove()
	end

	self._hud_chat_respawn = HUDChat:new(self._saferect, hud_respawn.panel, true)

	self._hud_chat_respawn:set_bottom(hud_respawn.panel:h() - HUDManager.CHAT_DISTANCE_FROM_BOTTOM)
	self._hud_chat_respawn:hide()
	self._hud_chat_respawn:unregister()

	self._hud_chat = self._hud_chat_ingame
end

-- Lines 798-814
function HUDManager:mark_cheater(peer_id)
	if NetworkPeer.CHEAT_CHECKS_DISABLED == true then
		return
	end

	for i, data in ipairs(self._hud.teammate_panels_data) do
		if self._teammate_panels[i]:peer_id() == peer_id then
			self._teammate_panels[i]:set_cheater(true)

			break
		end
	end
end

-- Lines 817-933
function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
	for i, data in ipairs(self._hud.teammate_panels_data) do
		if not data.taken then
			if i ~= HUDManager.PLAYER_PANEL then
				self._ai_teammate_panels[i]:hide()
				self._peer_teammate_panels[i]:hide()

				self._teammate_panels[i] = ai and self._ai_teammate_panels[i] or self._peer_teammate_panels[i]
			end

			self._teammate_panels[i]:reset_state()
			self._teammate_panels[i]:show()
			self._teammate_panels[i]:set_peer_id(peer_id)
			self:set_teammate_name(i, player_name)
			self:set_teammate_nationality(i, character_name)

			if peer_id then
				local peer_equipment = managers.player:get_synced_equipment_possession(peer_id) or {}

				for equipment, amount in pairs(peer_equipment) do
					self:add_teammate_special_equipment(i, {
						id = equipment,
						icon = tweak_data.equipments.specials[equipment].icon,
						amount = amount
					})
				end

				local peer_deployable_equipment = managers.player:get_synced_deployable_equipment(peer_id)

				if peer_deployable_equipment then
					local icon = tweak_data.equipments[peer_deployable_equipment.deployable].icon

					self:set_deployable_equipment(i, {
						icon = icon,
						amount = peer_deployable_equipment.amount
					})
				end

				local peer_grenades = managers.player:get_synced_grenades(peer_id)

				if peer_grenades then
					local icon = tweak_data.projectiles[peer_grenades.grenade].icon
				end

				local peer = managers.network:session():peer(peer_id)

				self._teammate_panels[i]:set_level(peer:level())

				if Network:is_server() then
					self._teammate_panels[HUDManager.PLAYER_PANEL]:show_host_indicator()
				elseif peer:is_host() then
					self._teammate_panels[i]:show_host_indicator()
				end
			end

			local unit = managers.criminals:character_unit_by_name(character_name)

			if alive(unit) then
				local weapon = unit:inventory():equipped_unit()

				if alive(weapon) then
					local icon = weapon:base():weapon_tweak_data().hud_icon
					local equipped_selection = unit:inventory():equipped_selection()

					self:_set_teammate_weapon_selected(i, equipped_selection, icon)
				end
			else
				self:on_teammate_died(i)
			end

			local peer_carry_data = managers.player:get_synced_carry(peer_id)

			if peer_carry_data then
				local unit_data = managers.network:session():peer(peer_id):unit():unit_data()
				local name_label_id = nil

				if unit_data.name_label_id then
					name_label_id = unit_data.name_label_id
				end

				self:set_teammate_carry_info(i, name_label_id, peer_carry_data.carry_id)
			end

			data.taken = true

			if ai then
				data.ai = true
			else
				data.ai = false
			end

			if unit then
				unit:unit_data().teammate_panel_id = i
			end

			if peer_id then
				managers.network:session():peer(peer_id):set_teammate_panel_id(i)
			end

			self:_layout_teammate_panels()
			self._tab_screen:refresh_peers()

			if unit and unit:character_damage().run_queued_teammate_panel_update then
				unit:character_damage():run_queued_teammate_panel_update()
			end

			return i
		end
	end

	debug_pause("[HUDManager:add_teammate_panel] Teammate panel is not added:", character_name, player_name, ai, peer_id)
end

-- Lines 936-956
function HUDManager:remove_teammate_panel(id)
	self._teammate_panels[id]:hide()

	if not self._teammate_panels[id]:is_ai() then
		self._teammate_panels[id]:hide_host_indicator()
	end

	self._hud.teammate_panels_data[id].taken = false

	self:_layout_teammate_panels()
	self._tab_screen:refresh_peers()

	if Network:is_server() and managers.network:session():count_all_peers() == 1 then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:hide_host_indicator()
	end
end

-- Lines 958-986
function HUDManager:_layout_teammate_panels()
	local y = 0
	local human_teammates_exist = false

	for i = 1, #self._teammate_panels do
		if i ~= HUDManager.PLAYER_PANEL and not self._teammate_panels[i]:is_ai() then
			self._teammate_panels[i]:set_y(y)

			y = y + self._teammate_panels[i]:h() + self._teammate_panels[i]:padding_down()
			human_teammates_exist = true
		end
	end

	for i = 1, #self._teammate_panels do
		if i ~= HUDManager.PLAYER_PANEL and self._teammate_panels[i]:is_ai() then
			self._teammate_panels[i]:set_y(y)

			y = y + self._teammate_panels[i]:h() + self._teammate_panels[i]:padding_down()

			if human_teammates_exist then
				self._teammate_panels[i]:set_x(16)
			else
				self._teammate_panels[i]:set_x(0)
			end
		end
	end
end

-- Lines 988-996
function HUDManager:get_teammate_panel_by_id(peer_id)
	for i = 1, 4 do
		if peer_id == self._teammate_panels[i]:peer_id() then
			return self._teammate_panels[i]
		end
	end

	return nil
end

-- Lines 998-1002
function HUDManager:teampanels_height()
	return 300
end

-- Lines 1004-1057
function HUDManager:_create_teammates_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	self._ai_teammate_panels = {}
	self._peer_teammate_panels = {}

	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end

	local teammates_panel_params = {
		halign = "left",
		name = "teammates_panel",
		y = 0,
		x = 0,
		valign = "grow",
		w = HUDManager.TEAMMATE_PANEL_W,
		h = hud.panel:h()
	}
	local teammates_panel = hud.panel:panel(teammates_panel_params)

	for i = 1, 3 do
		self._hud.teammate_panels_data[i] = {
			taken = false,
			special_equipments = {}
		}
		local ai_teammate = HUDTeammateAI:new(i, teammates_panel)

		ai_teammate:set_y((i - 1) * (HUDTeammateAI.DEFAULT_H + ai_teammate:padding_down()))
		table.insert(self._ai_teammate_panels, ai_teammate)

		local peer_teammate = HUDTeammatePeer:new(i, teammates_panel)

		peer_teammate:set_y((i - 1) * (HUDTeammatePeer.DEFAULT_H + peer_teammate:padding_down()))
		peer_teammate:hide()
		table.insert(self._peer_teammate_panels, peer_teammate)
	end

	for i = 1, #self._ai_teammate_panels do
		self._teammate_panels[i] = self._ai_teammate_panels[i]
	end

	local teammate = HUDTeammatePlayer:new(HUDManager.PLAYER_PANEL, teammates_panel)

	table.insert(self._teammate_panels, teammate)

	self._hud.teammate_panels_data[HUDManager.PLAYER_PANEL] = {
		taken = false,
		special_equipments = {}
	}
end

-- Lines 1059-1077
function HUDManager:_fix_peer_warcry_icons()
	for i = 1, #self._hud.name_labels do
		local peer_name_label = self._hud.name_labels[i]
		local peer_id = peer_name_label._peer_id
		local warcry = peer_name_label.warcry

		if peer_name_label and peer_id then
			for j = 1, #self._teammate_panels do
				local teammate_panel = self._teammate_panels[j]

				if teammate_panel._peer_id == peer_id then
					print(inspect(teammate_panel))
					teammate_panel:set_active_warcry(warcry)
				end
			end
		end
	end
end

-- Lines 1079-1099
function HUDManager:_create_weapons_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local weapons_panel_params = {
		name = "weapons_panel",
		halign = "right",
		valign = "bottom",
		w = HUDManager.WEAPONS_PANEL_W,
		h = HUDManager.WEAPONS_PANEL_H
	}
	local weapons_panel = hud.panel:panel(weapons_panel_params)

	weapons_panel:set_right(hud.panel:w())
	weapons_panel:set_bottom(hud.panel:h())

	self._weapon_panel_classes = {
		grenade = HUDWeaponGrenade,
		clip_shots = HUDWeaponClipShots,
		drum_mag = HUDWeaponDrum,
		revolver = HUDWeaponRevolver
	}
	self._weapon_panels = {}
end

-- Lines 1103-1115
function HUDManager:_create_comm_wheel(hud, params)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local params = tweak_data.interaction.com_wheel
	local pm = managers.player
	params.show_clbks = {
		callback(pm, pm, "disable_view_movement")
	}
	params.hide_clbks = {
		callback(pm, pm, "enable_view_movement")
	}
	self._hud_comm_wheel = HUDMultipleChoiceWheel:new(self._saferect, hud, params or tweak_data.interaction.com_wheel)

	self._hud_comm_wheel:set_x(hud.panel:w() / 2 - self._hud_comm_wheel:w() / 2)
	self._hud_comm_wheel:set_y(0)
	self._hud_comm_wheel:hide()
end

-- Lines 1117-1119
function HUDManager:comm_wheel_exists()
	return self._hud_comm_wheel ~= nil
end

-- Lines 1121-1128
function HUDManager:show_comm_wheel()
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:show()
end

-- Lines 1130-1134
function HUDManager:trigger_comm_wheel_option(option_id)
	if self._hud_comm_wheel then
		self._hud_comm_wheel:trigger_option(option_id)
	end
end

-- Lines 1136-1141
function HUDManager:hide_comm_wheel(quiet)
	if self._hud_comm_wheel then
		self._hud_comm_wheel:hide(quiet)
	end
end

-- Lines 1143-1149
function HUDManager:add_comm_wheel_option(option, index)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:add_option(option, index)
end

-- Lines 1151-1157
function HUDManager:remove_comm_wheel_option(option_id)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:remove_option(option_id)
end

-- Lines 1159-1165
function HUDManager:set_comm_wheel_options(options)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:set_options(options)
end

-- Lines 1167-1173
function HUDManager:is_comm_wheel_visible()
	if self._hud_comm_wheel ~= nil then
		return self._hud_comm_wheel:is_visible()
	end

	return false
end

-- Lines 1175-1177
function HUDManager:_destroy_comm_wheel()
	self._hud_comm_wheel = nil
end

-- Lines 1182-1188
function HUDManager:create_special_interaction(hud, params)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_special_interaction = self._hud_special_interaction or HUDSpecialInteraction:new(hud, params)

	self._hud_special_interaction:set_tweak_data(params)
	self._hud_special_interaction:hide()

	return self._hud_special_interaction
end

-- Lines 1190-1192
function HUDManager:special_interaction_exists()
	return self._hud_special_interaction ~= nil
end

-- Lines 1194-1198
function HUDManager:show_special_interaction()
	if self._hud_special_interaction then
		self._hud_special_interaction:show()
	end
end

-- Lines 1200-1204
function HUDManager:hide_special_interaction(completed)
	if self._hud_special_interaction then
		self._hud_special_interaction:hide(completed)
	end
end

-- Lines 1206-1212
function HUDManager:is_special_interaction_visible()
	if self._hud_special_interaction ~= nil then
		return self._hud_special_interaction:is_visible()
	end

	return false
end

-- Lines 1217-1223
function HUDManager:_create_present_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._toast_notification = HUDToastNotification:new(hud)

	self._toast_notification:set_x(hud.panel:w() / 2 - self._toast_notification:w() / 2)
	self._toast_notification:set_y(0)
end

-- Lines 1226-1235
function HUDManager:present(params)
	if not self._toast_notification then
		local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

		self:_create_present_panel(hud)
	end

	if self._toast_notification then
		self._toast_notification:present(params)
	end
end

-- Lines 1238-1239
function HUDManager:present_done()
end

-- Lines 1243-1246
function HUDManager:_create_interaction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_interaction = HUDInteraction:new(hud)
end

-- Lines 1249-1251
function HUDManager:show_interact(data)
	self._hud_interaction:show_interact(data)
end

-- Lines 1254-1259
function HUDManager:remove_interact()
	if not self._hud_interaction then
		return
	end

	self._hud_interaction:remove_interact()
end

-- Lines 1262-1264
function HUDManager:show_interaction_bar(current, total)
	self._hud_interaction:show_interaction_bar(current, total)
end

-- Lines 1267-1269
function HUDManager:set_interaction_bar_width(current, total)
	self._hud_interaction:set_interaction_bar_width(current, total)
end

-- Lines 1272-1274
function HUDManager:hide_interaction_bar(complete, show_interact_at_finish)
	self._hud_interaction:hide_interaction_bar(complete, show_interact_at_finish)
end

-- Lines 1278-1281
function HUDManager:_create_progress_timer(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._progress_timer = HUDInteraction:new(hud, "progress_timer")
end

-- Lines 1283-1285
function HUDManager:show_progress_timer(data)
	self._progress_timer:show_interact(data)
end

-- Lines 1287-1289
function HUDManager:remove_progress_timer()
	self._progress_timer:remove_interact()
end

-- Lines 1291-1307
function HUDManager:show_progress_timer_bar(current, total, description)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local progress_bar_params = {
		name = "progress_timer_progress_bar",
		height = 8,
		width = 256,
		x = hud.panel:w() / 2,
		y = hud.panel:h() / 2,
		color = Color(1, 0.6666666666666666, 0):with_alpha(0.8),
		description = description
	}
	self._progress_timer_progress_bar = ProgressBarGuiObject:new(hud.panel, progress_bar_params)

	self._progress_timer_progress_bar:show()
end

-- Lines 1309-1312
function HUDManager:set_progress_timer_bar_width(current, total)
	self._progress_timer_progress_bar:set_progress(current, total)
end

-- Lines 1314-1316
function HUDManager:set_progress_timer_bar_valid(valid, text_id)
	self._progress_timer:set_bar_valid(valid, text_id)
end

-- Lines 1318-1321
function HUDManager:hide_progress_timer_bar(complete)
	self._progress_timer_progress_bar:hide(complete)
end

-- Lines 1325-1331
function HUDManager:create_objectives_timer_hud(current, total)
	self._hud_objectives:show_timer()

	if self._tab_objectives then
		self._tab_objectives:show_timer()
	end
end

-- Lines 1333-1339
function HUDManager:set_objectives_timer_hud_value(current, total, remaining)
	self._hud_objectives:set_timer_value(current, total)

	if self._tab_objectives then
		self._tab_objectives:set_timer_value(current, total)
	end
end

-- Lines 1341-1347
function HUDManager:remove_objectives_timer_hud(complete)
	self._hud_objectives:hide_timer()

	if self._tab_objectives then
		self._tab_objectives:hide_timer()
	end
end

-- Lines 1349-1355
function HUDManager:show_objectives_timer_hud()
	self._hud_objectives:show_timer()

	if self._tab_objectives then
		self._tab_objectives:show_timer()
	end
end

-- Lines 1357-1363
function HUDManager:hide_objectives_timer_hud()
	self._hud_objectives:hide_timer()

	if self._tab_objectives then
		self._tab_objectives:hide_timer()
	end
end

-- Lines 1369-1370
function HUDManager:set_control_info(data)
end

-- Lines 1375-1389
function HUDManager:sync_start_assault(data)
	if not managers.groupai:state():get_hunt_mode() then
		managers.dialog:queue_dialog("gen_ban_b02c", {})
	end
end

-- Lines 1392-1397
function HUDManager:sync_end_assault(result)
	if result then
		-- Nothing
	end
end

-- Lines 1401-1413
function HUDManager:on_progression_cycle_completed()
	if self._tab_screen then
		self._tab_screen:on_progression_cycle_completed()
	end

	local notification_params = {
		id = "progression_cycle_completed",
		duration = 6,
		priority = 4,
		notification_type = HUDNotification.RAID_UNLOCKED
	}

	managers.notification:add_notification(notification_params)
end

-- Lines 1415-1427
function HUDManager:on_greed_loot_picked_up(old_progress, new_progress)
	if self._tab_screen then
		self._tab_screen:on_greed_loot_picked_up(old_progress, new_progress)
	end

	managers.notification:add_notification({
		id = "greed_item_picked_up",
		shelf_life = 6,
		notification_type = HUDNotification.GREED_ITEM,
		initial_progress = old_progress,
		new_progress = new_progress
	})
end

-- Lines 1429-1433
function HUDManager:set_current_greed_amount(amount)
	if self._tab_screen then
		self._tab_screen:set_current_greed_amount(amount)
	end
end

-- Lines 1435-1439
function HUDManager:reset_greed_indicators()
	if self._tab_screen then
		self._tab_screen:reset_greed_indicator()
	end
end

-- Lines 1441-1458
function HUDManager:_setup_tab_screen()
	if not self:exists(HUDManager.TAB_SCREEN_FULLSCREEN) then
		self:load_hud(HUDManager.TAB_SCREEN_SAFERECT, true, true, true, {})
		self:load_hud(HUDManager.TAB_SCREEN_FULLSCREEN, true, true, false, {})
	end

	local hud_tab_fullscreen = managers.hud:script(HUDManager.TAB_SCREEN_FULLSCREEN)
	local hud_tab_safe = managers.hud:script(HUDManager.TAB_SCREEN_SAFERECT)
	self._tab_screen = HUDTabScreen:new(hud_tab_fullscreen, hud_tab_safe)

	self._tab_screen:hide()

	if _G.IS_PC and SystemInfo:distribution() == Idstring("STEAM") then
		managers.network.account:add_overlay_listener("[HUDManager] hide_tab_screen", {
			"overlay_open"
		}, callback(self, self, "hide_stats_screen"))
	end
end

-- Lines 1461-1471
function HUDManager:show_stats_screen()
	self._tab_screen:show()

	self._showing_stats_screen = true

	self:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
	self:hide(PlayerBase.INGAME_HUD_SAFERECT)
	self:hide(IngameWaitingForRespawnState.GUI_SPECTATOR)
	self:show(HUDManager.TAB_SCREEN_FULLSCREEN)
	self:show(HUDManager.TAB_SCREEN_SAFERECT)
end

-- Lines 1474-1492
function HUDManager:hide_stats_screen()
	if self._tab_screen then
		self._tab_screen:hide()
	end

	if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
		self:show(IngameWaitingForRespawnState.GUI_SPECTATOR)
	else
		self:show(PlayerBase.INGAME_HUD_FULLSCREEN)
		self:show(PlayerBase.INGAME_HUD_SAFERECT)
	end

	if self._showing_stats_screen then
		self:hide(HUDManager.TAB_SCREEN_FULLSCREEN)
		self:hide(HUDManager.TAB_SCREEN_SAFERECT)
	end

	self._showing_stats_screen = false
end

-- Lines 1494-1496
function HUDManager:showing_stats_screen()
	return self._showing_stats_screen
end

-- Lines 1498-1500
function HUDManager:set_loot_picked_up(amount)
	self._tab_screen:set_loot_picked_up(amount)
end

-- Lines 1502-1504
function HUDManager:set_loot_total(amount)
	self._tab_screen:set_loot_total(amount)
end

-- Lines 1509-1510
function HUDManager:feed_point_of_no_return_timer(time, is_inside)
end

-- Lines 1513-1514
function HUDManager:show_point_of_no_return_timer()
end

-- Lines 1517-1518
function HUDManager:hide_point_of_no_return_timer()
end

-- Lines 1521-1527
function HUDManager:flash_point_of_no_return_timer(beep)
	if beep then
		self._sound_source:post_event("last_10_seconds_beep")
	end
end

-- Lines 1531-1537
function HUDManager:_create_objectives(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_objectives = HUDObjectives:new(hud.panel)

	self._hud_objectives:set_x(hud.panel:w() - self._hud_objectives:w())
	self._hud_objectives:set_y(0)
end

-- Lines 1539-1541
function HUDManager:_get_tab_objectives()
	self._tab_objectives = self._tab_screen:get_objectives_control()
end

-- Lines 1543-1551
function HUDManager:show_objectives()
	if self._hud_objectives then
		self._hud_objectives:show()
	end

	if self._tab_objectives then
		self._tab_objectives:show()
	end
end

-- Lines 1553-1561
function HUDManager:hide_objectives()
	if self._hud_objectives then
		self._hud_objectives:hide()
	end

	if self._tab_objectives then
		self._tab_objectives:hide()
	end
end

-- Lines 1565-1574
function HUDManager:activate_objective(data)
	if self._hud_objectives then
		self._hud_objectives:activate_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:activate_objective(data)
	end
end

-- Lines 1577-1586
function HUDManager:complete_sub_objective(data)
	if self._hud_objectives then
		self._hud_objectives:complete_sub_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:complete_sub_objective(data)
	end
end

-- Lines 1589-1598
function HUDManager:update_amount_objective(data)
	if self._hud_objectives then
		self._hud_objectives:update_amount_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:update_amount_objective(data)
	end
end

-- Lines 1600-1609
function HUDManager:update_amount_sub_objective(data)
	if self._hud_objectives then
		self._hud_objectives:update_amount_sub_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:update_amount_sub_objective(data)
	end
end

-- Lines 1612-1620
function HUDManager:remind_objective(id)
	if self._hud_objectives then
		self._hud_objectives:remind_objective(id)
	end

	if self._tab_objectives then
		self._tab_objectives:remind_objective(id)
	end
end

-- Lines 1622-1630
function HUDManager:remind_sub_objective(id)
	if self._hud_objectives then
		self._hud_objectives:remind_sub_objective(id)
	end

	if self._tab_objectives then
		self._tab_objectives:remind_sub_objective(id)
	end
end

-- Lines 1633-1642
function HUDManager:complete_objective(data)
	if self._hud_objectives then
		self._hud_objectives:complete_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:complete_objective(data)
	end
end

-- Lines 1644-1653
function HUDManager:render_objective()
	if self._hud_objectives then
		self._hud_objectives:update_objectives()
	end

	if self._tab_objectives then
		self._tab_objectives:update_objectives()
	end
end

-- Lines 1658-1660
function HUDManager:feed_session_time(time)
	self._tab_screen:set_time(time)
end

-- Lines 1662-1665
function HUDManager:reset_session_time()
	self._tab_screen:reset_time()
	managers.game_play_central:start_heist_timer()
end

-- Lines 1669-1672
function HUDManager:set_stamina_value(value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(value)
end

-- Lines 1674-1677
function HUDManager:set_max_stamina(value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_max_stamina(value)
end

-- Lines 1681-1685
function HUDManager:_create_turret_hud(hud)
	self._turret_hud = HUDTurret:new(hud)

	self._turret_hud:set_x(hud.panel:w() / 2 - self._turret_hud:w() / 2)
	self._turret_hud:set_y(hud.panel:h() / 2 - self._turret_hud:h() / 2)
end

-- Lines 1687-1690
function HUDManager:show_turret_hud(turret_unit, bullet_type)
	self._turret_hud:show(turret_unit, bullet_type)
end

-- Lines 1692-1695
function HUDManager:hide_turret_hud(turret_unit)
	self._turret_hud:hide(turret_unit)
end

-- Lines 1697-1700
function HUDManager:update_heat_indicator(current)
	self._turret_hud:update_heat_indicator(current)
end

-- Lines 1702-1705
function HUDManager:player_turret_overheat(turret_unit)
	self._turret_hud:overheat(turret_unit)
end

-- Lines 1707-1709
function HUDManager:player_turret_flak_insert()
	self._turret_hud:flak_insert()
end

-- Lines 1711-1713
function HUDManager:set_player_turret_overheating(overheating)
	self._turret_hud:set_overheating(overheating)
end

-- Lines 1715-1718
function HUDManager:player_turret_cooldown()
	self._turret_hud:cooldown()
end

-- Lines 1722-1728
function HUDManager:_create_watermark(hud)
end

-- Lines 1732-1736
function HUDManager:_create_carry(hud)
	self._carry_hud = HUDCarry:new(hud)

	self._carry_hud:set_x(hud.panel:w() / 2 - self._carry_hud:w() / 2)
	self._carry_hud:set_y(hud.panel:h() - self._carry_hud:h())
end

-- Lines 1738-1740
function HUDManager:show_carry_item(carry_id)
	self._carry_hud:show_carry_item(carry_id)
end

-- Lines 1742-1744
function HUDManager:hide_carry_item()
	self._carry_hud:hide_carry_item()
end

-- Lines 1748-1751
function HUDManager:_create_suspicion(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_suspicion = HUDSuspicion:new(hud, self._sound_source)
end

-- Lines 1753-1755
function HUDManager:hide_suspicion()
	self._hud_suspicion:hide()
end

-- Lines 1757-1759
function HUDManager:show_suspicion()
	self._hud_suspicion:show()
end

-- Lines 1762-1775
function HUDManager:set_suspicion(status)
	if type(status) == "boolean" then
		if status then
			self._hud_suspicion:discovered()
		else
			self._hud_suspicion:back_to_stealth()
		end
	else
		self._hud_suspicion:show()
	end
end

-- Lines 1779-1782
function HUDManager:_create_hit_confirm(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_hit_confirm = HUDHitConfirm:new(hud)
end

-- Lines 1784-1788
function HUDManager:on_hit_confirmed(world_hit_pos, wep_type_shotgun)
	if managers.user:get_setting("hit_indicator") > 1 then
		self._hud_hit_confirm:on_hit_confirmed(world_hit_pos, wep_type_shotgun)
	end
end

-- Lines 1790-1794
function HUDManager:on_headshot_confirmed(world_hit_pos, wep_type_shotgun)
	if managers.user:get_setting("hit_indicator") > 1 then
		self._hud_hit_confirm:on_headshot_confirmed(world_hit_pos, wep_type_shotgun)
	end
end

-- Lines 1796-1800
function HUDManager:on_crit_confirmed(world_hit_pos, wep_type_shotgun)
	if managers.user:get_setting("hit_indicator") > 1 then
		self._hud_hit_confirm:on_crit_confirmed(world_hit_pos, wep_type_shotgun)
	end
end

-- Lines 1804-1807
function HUDManager:_create_hit_direction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_hit_direction = HUDHitDirection:new(hud)
end

-- Lines 1809-1811
function HUDManager:on_hit_direction(dir, unit_type_hit)
	self._hud_hit_direction:on_hit_direction(dir, unit_type_hit)
end

-- Lines 1813-1815
function HUDManager:on_hit_unit(attack_data, unit_type_hit)
	self._hud_hit_direction:on_hit_unit(attack_data, unit_type_hit)
end

-- Lines 1817-1819
function HUDManager:clear_hit_direction_indicators()
	self._hud_hit_direction:clean_up()
end

-- Lines 1823-1829
function HUDManager:_create_center_prompt(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._center_prompt = HUDCenterPrompt:new(hud)

	self._center_prompt:set_x(hud.panel:w() / 2 - self._center_prompt:w() / 2)
	self._center_prompt:set_y(hud.panel:h() / 2 + 48 - self._center_prompt:h() / 2)
end

-- Lines 1831-1833
function HUDManager:set_prompt(id, text, duration)
	self._center_prompt:show_prompt(id, text, duration)
end

-- Lines 1835-1837
function HUDManager:hide_prompt(id)
	self._center_prompt:hide_prompt(id)
end

-- Lines 1842-1848
function HUDManager:_create_big_prompt(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._big_prompt = HUDBigPrompt:new(hud)

	self._big_prompt:set_x(hud.panel:w() / 2 - self._big_prompt:w() / 2)
	self._big_prompt:set_y(hud.panel:h() / 2 + 116 - self._big_prompt:h() / 2)
end

-- Lines 1850-1852
function HUDManager:set_big_prompt(params)
	self._big_prompt:show_prompt(params)
end

-- Lines 1854-1856
function HUDManager:hide_big_prompt(id)
	self._big_prompt:hide_prompt(id)
end

-- Lines 1864-1867
function HUDManager:_create_suspicion_direction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_suspicion_direction = HUDSuspicionDirection:new(hud)
end

-- Lines 1869-1871
function HUDManager:create_suspicion_indicator(observer_key, observer_position, initial_state, suspect)
	self._hud_suspicion_direction:create_suspicion_indicator(observer_key, observer_position, initial_state, suspect)
end

-- Lines 1873-1875
function HUDManager:need_to_init_suspicion_indicator(observer_key)
	return self._hud_suspicion_direction:need_to_init(observer_key)
end

-- Lines 1877-1879
function HUDManager:initialize_suspicion_indicator(observer_key, alpha)
	self._hud_suspicion_direction:initialize(observer_key, alpha)
end

-- Lines 1881-1883
function HUDManager:show_suspicion_indicator(observer_key)
	self._hud_suspicion_direction:show_suspicion_indicator(observer_key)
end

-- Lines 1885-1887
function HUDManager:hide_suspicion_indicator(observer_key)
	self._hud_suspicion_direction:hide_suspicion_indicator(observer_key)
end

-- Lines 1889-1891
function HUDManager:set_suspicion_indicator_progress(observer_key, progress)
	self._hud_suspicion_direction:set_suspicion_indicator_progress(observer_key, progress)
end

-- Lines 1893-1895
function HUDManager:clear_suspicion_direction_indicators()
	self._hud_suspicion_direction:clean_up()
end

-- Lines 1899-1902
function HUDManager:_create_custody_hud(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_CUSTODY_HUD)
	self._hud_player_custody = HUDPlayerCustody:new(hud)
end

-- Lines 1904-1906
function HUDManager:set_custody_respawn_time(time)
	self._hud_player_custody:set_respawn_time(time)
end

-- Lines 1908-1910
function HUDManager:set_custody_timer_visibility(visible)
	self._hud_player_custody:set_timer_visibility(visible)
end

-- Lines 1912-1914
function HUDManager:set_custody_civilians_killed(amount)
	self._hud_player_custody:set_civilians_killed(amount)
end

-- Lines 1916-1918
function HUDManager:set_custody_trade_delay(time)
	self._hud_player_custody:set_trade_delay(time)
end

-- Lines 1920-1922
function HUDManager:set_custody_trade_delay_visible(visible)
	self._hud_player_custody:set_trade_delay_visible(visible)
end

-- Lines 1924-1926
function HUDManager:set_custody_negotiating_visible(visible)
	self._hud_player_custody:set_negotiating_visible(visible)
end

-- Lines 1928-1930
function HUDManager:set_custody_can_be_trade_visible(visible)
	self._hud_player_custody:set_can_be_trade_visible(visible)
end

-- Lines 1932-1934
function HUDManager:set_custody_pumpkin_challenge()
	self._hud_player_custody:set_pumpkin_challenge()
end

-- Lines 1938-1941
function HUDManager:_create_motiondot_hud(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_motion_dot = HUDMotionDot:new(hud)
end

-- Lines 1944-1946
function HUDManager:set_motiondot_visibility(visible)
	self._hud_motion_dot:on_setting_counts(visible)
end

-- Lines 1949-1951
function HUDManager:set_motiondot_counts(index)
	self._hud_motion_dot:on_setting_counts(index)
end

-- Lines 1953-1955
function HUDManager:increment_motiondot_counts()
	self._hud_motion_dot:on_setting_counts_increment()
end

-- Lines 1958-1960
function HUDManager:set_motiondot_offsets(index)
	self._hud_motion_dot:on_setting_offsets(index)
end

-- Lines 1962-1964
function HUDManager:increment_motiondot_offsets()
	self._hud_motion_dot:on_setting_offsets_increment()
end

-- Lines 1967-1969
function HUDManager:set_motiondot_icons(index)
	self._hud_motion_dot:on_setting_icons(index)
end

-- Lines 1971-1973
function HUDManager:increment_motiondot_icons()
	self._hud_motion_dot:on_setting_icons_increment()
end

-- Lines 1976-1978
function HUDManager:set_motiondot_sizes(index)
	self._hud_motion_dot:on_setting_sizes(index)
end

-- Lines 1980-1982
function HUDManager:increment_motiondot_sizes()
	self._hud_motion_dot:on_setting_sizes_increment()
end

-- Lines 1985-1987
function HUDManager:set_motiondot_color(color)
	self._hud_motion_dot:on_setting_color(color)
end

-- Lines 1988-1990
function HUDManager:set_motiondot_color_silly()
	self._hud_motion_dot:on_setting_color_silly()
end

-- Lines 1993-1995
function HUDManager:fade_out_motion_dot()
	self._hud_motion_dot:set_fade_hide_dots()
end

-- Lines 1997-1999
function HUDManager:fade_in_motion_dot()
	self._hud_motion_dot:set_fade_show_dots()
end

-- Lines 2003-2062
function HUDManager:align_teammate_name_label(panel, interact, double_radius)
	local text = panel:child("text")
	local action = panel:child("action")
	local bag = panel:child("bag")
	local bag_number = panel:child("bag_number")
	local cheater = panel:child("cheater")
	local _, _, tw, th = text:text_rect()
	local _, _, aw, ah = action:text_rect()
	local _, _, cw, ch = cheater:text_rect()

	panel:set_size(math.max(tw, cw) + 4 + double_radius, math.max(th + ah + ch, double_radius))
	text:set_size(panel:w(), th)
	action:set_size(panel:w(), ah)
	cheater:set_size(tw, ch)
	action:set_x(double_radius + 4)
	cheater:set_x(double_radius + 4)
	text:set_top(cheater:bottom())
	action:set_top(text:bottom())
	bag:set_top(text:top() + 4)

	local infamy = panel:child("infamy")

	if infamy then
		panel:set_w(panel:w() + infamy:w())
		text:set_size(panel:size())
		infamy:set_x(double_radius + 4)
		infamy:set_top(text:top())
		text:set_x(double_radius + 4 + infamy:w())
	end

	if bag_number then
		bag_number:set_bottom(text:bottom() - 1)
		panel:set_w(panel:w() + bag_number:w() + bag:w() + 8)
		bag:set_right(panel:w() - bag_number:w())
		bag_number:set_right(panel:w() + 2)
	else
		panel:set_w(panel:w() + bag:w() + 4)
		bag:set_right(panel:w())
	end

	bag:set_w(32)
	bag:set_h(16)
	bag:set_center_x(bag:parent():w() / 2)
	bag:set_y(10)
	text:set_center_x(panel:w() / 2)
	interact:set_position(panel:w() / 2, panel:h() / 2 + text:h() / 2 + 4)
end

-- Lines 2067-2092
function HUDManager:_add_name_label(data)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels]:id() or 0
	local id = last_id + 1
	local peer_id = nil
	local is_husk_player = data.unit:base().is_husk_player

	if is_husk_player then
		peer_id = data.unit:network():peer():id()
	end

	local name_label_params = {
		id = id,
		name = data.name,
		nationality = data.nationality,
		peer_id = peer_id,
		movement = data.unit:movement()
	}
	local name_label = HUDNameLabel:new(hud, name_label_params)

	table.insert(self._hud.name_labels, name_label)

	return id
end

-- Lines 2094-2111
function HUDManager:add_vehicle_name_label(data)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels]:id() or 0
	local id = last_id + 1
	local vehicle_name_label_params = {
		id = id,
		vehicle_name = managers.localization:text(data.name),
		vehicle_unit = data.unit
	}
	local name_label = HUDNameVehicleLabel:new(hud, vehicle_name_label_params)

	table.insert(self._hud.vehicle_name_labels, name_label)

	return id
end

-- Lines 2113-2126
function HUDManager:_remove_name_label(id)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	for i, name_label in ipairs(self._hud.name_labels) do
		if name_label:id() == id then
			name_label:destroy()
			table.remove(self._hud.name_labels, i)

			break
		end
	end
end

-- Lines 2128-2141
function HUDManager:remove_vehicle_name_label(id)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	for i, name_label in ipairs(self._hud.vehicle_name_labels) do
		if name_label:id() == id then
			name_label:destroy()
			table.remove(self._hud.vehicle_name_labels, i)

			break
		end
	end
end

-- Lines 2143-2153
function HUDManager:clear_vehicle_name_labels()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	for i, name_label in ipairs(self._hud.vehicle_name_labels) do
		name_label:destroy()
	end

	self._hud.vehicle_name_labels = {}
end

-- Lines 2156-2167
function HUDManager:_name_label_by_peer_id(peer_id)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	for i, name_label in ipairs(self._hud.name_labels) do
		if name_label:peer_id() == peer_id then
			return name_label
		end
	end
end

-- Lines 2169-2179
function HUDManager:_get_name_label(id)
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	for i, name_label in ipairs(self._hud.name_labels) do
		if name_label:id() == id then
			return name_label
		end
	end
end

-- Lines 2180-2181
function HUDManager:set_name_label_carry_info(peer_id, carry_id)
end

-- Lines 2183-2184
function HUDManager:set_vehicle_label_carry_info(label_id, value, number)
end

-- Lines 2187-2188
function HUDManager:remove_name_label_carry_info(peer_id)
end

-- Lines 2191-2202
function HUDManager:teammate_start_progress(teammate_panel_id, name_label_id, timer)
	local name_label = self:_get_name_label(name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if name_label and name_label.start_interact then
		name_label:start_interact(timer)
	end

	if teammate_panel and teammate_panel.start_interact then
		teammate_panel:start_interact(timer)
	end
end

-- Lines 2204-2215
function HUDManager:teammate_cancel_progress(teammate_panel_id, name_label_id)
	local name_label = self:_get_name_label(name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if name_label and name_label.cancel_interact then
		name_label:cancel_interact()
	end

	if teammate_panel and teammate_panel.cancel_interact then
		teammate_panel:cancel_interact()
	end
end

-- Lines 2217-2228
function HUDManager:teammate_complete_progress(teammate_panel_id, name_label_id)
	local name_label = self:_get_name_label(name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if name_label and name_label.complete_interact then
		name_label:complete_interact()
	end

	if teammate_panel and teammate_panel.complete_interact then
		teammate_panel:complete_interact()
	end
end

-- Lines 2232-2240
function HUDManager:_animate_label_interact(panel, interact, timer)
	local t = 0

	while timer >= t do
		local dt = coroutine.yield()
		t = t + dt

		interact:set_current(t / timer)
	end

	interact:set_current(1)
end

-- Lines 2242-2244
function HUDManager:toggle_chatinput()
	self:set_chat_focus(true)
end

-- Lines 2246-2248
function HUDManager:chat_focus()
	return self._chat_focus
end

-- Lines 2250-2254
function HUDManager:set_chat_skip_first(skip_first)
	if self._hud_chat then
		self._hud_chat:set_skip_first(skip_first)
	end
end

-- Lines 2257-2279
function HUDManager:set_chat_focus(focus)
	if not self:alive(PlayerBase.INGAME_HUD_FULLSCREEN) and not self:alive(IngameWaitingForRespawnState.GUI_SPECTATOR) then
		return
	end

	if self._chat_focus == focus then
		return
	end

	if self._hud_comm_wheel then
		self:hide_comm_wheel(true)
	end

	setup:add_end_frame_callback(function ()
		self._chat_focus = focus
	end)
	self._chatinput_changed_callback_handler:dispatch(focus)

	if focus then
		self._hud_chat:_on_focus()
	else
		self._hud_chat:_loose_focus()
	end
end

-- Lines 2283-2286
function HUDManager:_setup_driving_hud()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_driving = HUDDriving:new(hud)
end

-- Lines 2288-2290
function HUDManager:start_driving()
	self._hud_driving:start()
end

-- Lines 2292-2294
function HUDManager:stop_driving()
	self._hud_driving:stop()
end

-- Lines 2296-2298
function HUDManager:set_driving_vehicle_state(speed, rpm, gear)
	self._hud_driving:set_vehicle_state(speed, rpm, gear)
end

-- Lines 2300-2302
function HUDManager:set_vehicle_loot_info(vehicle, current_loot, current_loot_amount, max_loot_amount)
	self._hud_driving:set_vehicle_loot_info(vehicle, current_loot, current_loot_amount, max_loot_amount)
end

-- Lines 2304-2306
function HUDManager:ai_entered_vehicle(ai_unit, vehicle)
	self._hud_driving:refresh_seats()
end

-- Lines 2308-2315
function HUDManager:peer_enter_vehicle(peer_id, vehicle)
	if peer_id == managers.network:session():local_peer():id() then
		self._hud_driving:show(vehicle)
	end

	self._hud_driving:refresh_seats()
	self._tab_screen:peer_enter_vehicle(peer_id)
end

-- Lines 2317-2325
function HUDManager:peer_exit_vehicle(peer_id)
	if peer_id == managers.network:session():local_peer():id() then
		self._hud_driving:hide()
	else
		self._hud_driving:refresh_seats()
	end

	self._tab_screen:peer_exit_vehicle(peer_id)
end

-- Lines 2327-2329
function HUDManager:player_changed_vehicle_seat()
	self._hud_driving:refresh_seats(true)
end

-- Lines 2331-2333
function HUDManager:refresh_vehicle_health()
	self._hud_driving:refresh_health()
end

-- Lines 2335-2337
function HUDManager:hide_vehicle_hud()
	self._hud_driving:hide()
end

-- Lines 2341-2343
function HUDManager:set_custody_respawn_type(is_ai_trade)
	self._hud_player_custody:set_respawn_type(is_ai_trade)
end
