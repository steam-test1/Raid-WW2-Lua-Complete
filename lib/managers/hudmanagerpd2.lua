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
require("lib/managers/hud/HUDControllerHotswap")
require("lib/managers/hud/HUDCrosshair")
require("lib/managers/hud/HUDSpecialInteraction/Base")
require("lib/managers/hud/HUDSpecialInteraction/LockPick")
require("lib/managers/hud/HUDSpecialInteraction/FuseCutting")
require("lib/managers/hud/HUDSpecialInteraction/Rewiring")
require("lib/managers/hud/HUDSpecialInteraction/Roulette")
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
HUDManager.MINIGAMES = {
	pick_lock = HUDSpecialInteractionLockPick,
	cut_fuse = HUDSpecialInteractionFuseCutting,
	rewire = HUDSpecialInteractionRewiring,
	roulette = HUDSpecialInteractionRoulette
}

-- Lines 96-100
function HUDManager:controller_mod_changed()
	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end
end

-- Lines 106-116
function HUDManager:fit_text(text, default_font_size)
	text:set_font_size(default_font_size)

	local rect_w = select(3, text:text_rect())
	local text_w = text:w()

	if text_w < rect_w then
		local scale = text_w / rect_w

		text:set_font_size(default_font_size * scale)
	end
end

-- Lines 120-183
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

-- Lines 185-214
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

-- Lines 217-219
function HUDManager:set_weapon_selected_by_inventory_index(inventory_index)
	self:_set_weapon_selected(inventory_index)
end

-- Lines 222-227
function HUDManager:_set_weapon_selected(id)
	self._hud.selected_weapon = id
	local icon = self._hud.weapons[self._hud.selected_weapon].unit:base():weapon_tweak_data().hud and self._hud.weapons[self._hud.selected_weapon].unit:base():weapon_tweak_data().hud.icon

	self:_set_teammate_weapon_selected(HUDManager.PLAYER_PANEL, id, icon)
end

-- Lines 232-240
function HUDManager:_set_teammate_weapon_selected(i, id, icon)
	if i ~= HUDManager.PLAYER_PANEL then
		return
	end

	for j = 1, #self._weapon_panels do
		self._weapon_panels[j]:set_selected(j == id)
	end
end

-- Lines 242-246
function HUDManager:unselect_all_weapons()
	for i = 1, #self._weapon_panels do
		self._weapon_panels[i]:set_selected(false)
	end
end

-- Lines 248-253
function HUDManager:remove_all_weapons()
	while self._weapon_panels and #self._weapon_panels > 0 do
		self._weapon_panels[1]:destroy()
		table.remove(self._weapon_panels, 1)
	end
end

-- Lines 256-258
function HUDManager:set_weapon_blocked_by_inventory_index(inventory_index, state)
	self:_set_teammate_weapon_blocked(HUDManager.PLAYER_PANEL, inventory_index, state)
end

-- Lines 260-270
function HUDManager:_set_teammate_weapon_blocked(i, id, blocked)
	if i ~= HUDManager.PLAYER_PANEL then
		return
	end

	for j = 1, #self._weapon_panels do
		if j == id then
			self._weapon_panels[j]:set_blocked(blocked)
		end
	end
end

-- Lines 274-278
function HUDManager:recreate_weapon_firemode(i)
end

-- Lines 281-286
function HUDManager:set_teammate_weapon_firemode(i, id, firemode)
	if i == HUDManager.PLAYER_PANEL and self._weapon_panels[id] then
		self._weapon_panels[id]:set_firemode(firemode)
	end
end

-- Lines 288-296
function HUDManager:set_firemode_for_weapon(weapon_name_id, firemode)
	for i = 1, #self._weapon_panels do
		local panel_name_id = self._weapon_panels[i] and self._weapon_panels[i]:name_id()

		if panel_name_id and panel_name_id == weapon_name_id then
			self._weapon_panels[i]:set_firemode(firemode)

			return
		end
	end
end

-- Lines 299-313
function HUDManager:set_ammo_amount(selection_index, max_clip, current_clip, current_left, max)
	if selection_index > 2 then
		return
	end

	self:set_teammate_ammo_amount(HUDManager.PLAYER_PANEL, selection_index, max_clip, current_clip, current_left, max)
end

-- Lines 317-343
function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max)
	if not self._weapon_panels[selection_index] then
		Application:error("[HUDManager:set_teammate_ammo_amount] Attempting to set ammo for non existant weapon panel")

		return
	end

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

-- Lines 346-351
function HUDManager:set_weapon_ammo_by_unit(unit)
	local second_weapon_index = self._hud.selected_weapon == 1 and 2 or 1

	if second_weapon_index == unit:base():weapon_tweak_data().use_data.selection_index then
		self:_update_second_weapon_ammo_info(HUDManager.PLAYER_PANEL, unit)
	end
end

-- Lines 354-356
function HUDManager:_update_second_weapon_ammo_info(i, unit)
end

-- Lines 358-360
function HUDManager:set_player_panel_character_data(data)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_character_data(data)
end

-- Lines 362-364
function HUDManager:refresh_player_panel()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:refresh()
end

-- Lines 366-369
function HUDManager:show_player_panel()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:show()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_peer_id(managers.network:session():local_peer():id())
end

-- Lines 371-373
function HUDManager:hide_player_panel()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:hide()
end

-- Lines 375-378
function HUDManager:reset_player_state()
	self:reset_teammate_state(HUDManager.PLAYER_PANEL)
end

-- Lines 380-384
function HUDManager:reset_player_panel_states()
	for i = 1, #self._teammate_panels do
		self:reset_teammate_state(i)
	end
end

-- Lines 386-388
function HUDManager:reset_teammate_state(i)
	self._teammate_panels[i]:reset_state()
end

-- Lines 391-393
function HUDManager:set_player_health(data)
	self:set_teammate_health(HUDManager.PLAYER_PANEL, data)
end

-- Lines 395-404
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

-- Lines 406-408
function HUDManager:set_player_special_health(data)
	self:set_teammate_special_health(HUDManager.PLAYER_PANEL, data)
end

-- Lines 410-414
function HUDManager:set_teammate_special_health(i, recoverable_percent)
	if self._teammate_panels[i] then
		self._teammate_panels[i]:set_special_health(recoverable_percent)
	end
end

-- Lines 416-420
function HUDManager:set_player_downs(downs_amount)
	if self._teammate_panels[HUDManager.PLAYER_PANEL] then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_downs_amount(downs_amount)
	end
end

-- Lines 422-426
function HUDManager:override_player_down_color(color)
	if self._teammate_panels[HUDManager.PLAYER_PANEL] then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:override_downs_color(color)
	end
end

-- Lines 428-430
function HUDManager:set_player_warcry_meter_fill(data)
	self:set_teammate_warcry_meter_fill(HUDManager.PLAYER_PANEL, data)
end

-- Lines 432-434
function HUDManager:set_teammate_warcry_meter_fill(i, data)
	self._teammate_panels[i]:set_warcry_meter_fill(data)
end

-- Lines 436-439
function HUDManager:set_player_warcry_meter_glow(value)
	self:set_warcry_meter_glow(HUDManager.PLAYER_PANEL, value)
end

-- Lines 442-445
function HUDManager:set_player_active_warcry(warcry)
	self:set_teammate_active_warcry(HUDManager.PLAYER_PANEL, nil, warcry)
end

-- Lines 447-449
function HUDManager:set_teammate_active_warcry(i, name_label_id, warcry)
	self._teammate_panels[i]:set_active_warcry(warcry)
end

-- Lines 451-454
function HUDManager:set_warcry_meter_glow(i, value)
	self._teammate_panels[i]:set_warcry_ready(value)
end

-- Lines 456-458
function HUDManager:activate_teammate_warcry(i, name_label_id, duration)
	self._teammate_panels[i]:activate_warcry(duration)
end

-- Lines 460-466
function HUDManager:deactivate_player_warcry()
	self._sound_source:post_event("warcry_active_stop")
	self:set_player_warcry_meter_glow(false)
	self:hide_big_prompt("warcry_ready")
	self:deactivate_teammate_warcry(HUDManager.PLAYER_PANEL, nil)
end

-- Lines 468-470
function HUDManager:deactivate_teammate_warcry(i, name_label_id)
	self._teammate_panels[i]:deactivate_warcry()
end

-- Lines 472-475
function HUDManager:set_player_level(level)
	self:set_teammate_level(HUDManager.PLAYER_PANEL, level)
end

-- Lines 477-479
function HUDManager:set_teammate_level(i, level)
	self._teammate_panels[i]:set_level(level)
end

-- Lines 488-499
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

-- Lines 501-512
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

-- Lines 516-518
function HUDManager:set_player_armor(data)
	self:set_teammate_armor(HUDManager.PLAYER_PANEL, data)
end

-- Lines 521-530
function HUDManager:set_teammate_armor(i, data)
	if not self._teammate_panels[i] then
		debug_pause("[ HUDManager:set_teammate_armor ] teammate panel " .. tostring(i) .. " doesn't exist!")
		Application:error("data:", inspect(data))
		Application:error("teammate panels:", inspect(self._teammate_panels))
		Application:error(debug.traceback())
	end
end

-- Lines 532-535
function HUDManager:set_teammate_name(i, teammate_name)
	local is_local_player = i == HUDManager.PLAYER_PANEL

	self._teammate_panels[i]:set_name(teammate_name, is_local_player)
end

-- Lines 537-539
function HUDManager:set_player_nationality(nationality)
	self:set_teammate_nationality(HUDManager.PLAYER_PANEL, nationality)
end

-- Lines 541-543
function HUDManager:set_teammate_nationality(i, nationality)
	self._teammate_panels[i]:set_nationality(nationality)
end

-- Lines 545-547
function HUDManager:add_special_equipment(data)
	self:add_teammate_special_equipment(HUDManager.PLAYER_PANEL, data)
end

-- Lines 549-557
function HUDManager:add_teammate_special_equipment(i, data)
	if not i then
		Application:error("[HUDManager][add_teammate_special_equipment] - Didn't get a teammate panel number")
		Application:stack_dump()

		return
	end

	self._teammate_panels[i]:add_special_equipment(data)
end

-- Lines 559-561
function HUDManager:remove_special_equipment(equipment)
	self:remove_teammate_special_equipment(HUDManager.PLAYER_PANEL, equipment)
end

-- Lines 563-565
function HUDManager:remove_teammate_special_equipment(panel_id, equipment)
	self._teammate_panels[panel_id]:remove_special_equipment(equipment)
end

-- Lines 567-569
function HUDManager:set_special_equipment_amount(equipment_id, amount)
	self:set_teammate_special_equipment_amount(HUDManager.PLAYER_PANEL, equipment_id, amount)
end

-- Lines 571-573
function HUDManager:set_teammate_special_equipment_amount(i, equipment_id, amount)
	self._teammate_panels[i]:set_special_equipment_amount(equipment_id, amount)
end

-- Lines 575-577
function HUDManager:clear_player_special_equipments()
	self._teammate_panels[HUDManager.PLAYER_PANEL]:clear_special_equipment()
end

-- Lines 580-582
function HUDManager:set_stored_health(stored_health_ratio)
end

-- Lines 585-587
function HUDManager:set_stored_health_max(stored_health_ratio)
end

-- Lines 626-628
function HUDManager:add_item(data)
end

-- Lines 631-633
function HUDManager:set_deployable_equipment(i, data)
end

-- Lines 636-638
function HUDManager:set_item_amount(index, amount)
end

-- Lines 641-643
function HUDManager:set_teammate_deployable_equipment_amount(i, index, data)
end

-- Lines 646-652
function HUDManager:set_teammate_grenades(i, data)
	if i == HUDManager.PLAYER_PANEL then
		self._weapon_panels[WeaponInventoryManager.BM_CATEGORY_GRENADES_ID]:set_amount(data.amount)
	end
end

-- Lines 655-661
function HUDManager:set_teammate_grenades_amount(i, data)
	if i == HUDManager.PLAYER_PANEL then
		self._weapon_panels[WeaponInventoryManager.BM_CATEGORY_GRENADES_ID]:set_amount(data.amount)
	end
end

-- Lines 663-665
function HUDManager:set_player_condition(icon_data, text)
	self:set_teammate_condition(HUDManager.PLAYER_PANEL, icon_data, text)
end

-- Lines 668-677
function HUDManager:set_teammate_condition(i, icon_data, text)
	if not i then
		print("Didn't get a number")
		Application:stack_dump()

		return
	end

	self._teammate_panels[i]:set_condition(icon_data, text)
end

-- Lines 679-691
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

-- Lines 693-705
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

-- Lines 707-718
function HUDManager:on_teammate_died(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:on_died()
	end
end

-- Lines 720-731
function HUDManager:on_teammate_start_special_interaction(teammate_panel_id, name_label_id, interaction_type)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:show_special_interaction_icon(interaction_type)
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:show_special_interaction_icon(interaction_type)
	end
end

-- Lines 733-744
function HUDManager:on_teammate_stop_special_interaction(teammate_panel_id, name_label_id)
	local teammate_panel = self._teammate_panels[teammate_panel_id]

	if teammate_panel then
		self._teammate_panels[teammate_panel_id]:hide_special_interaction_icon()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:hide_special_interaction_icon()
	end
end

-- Lines 747-751
function HUDManager:set_teammate_carry_info(teammate_panel_id, name_label_id, carry_id)
	if teammate_panel_id and self._teammate_panels[teammate_panel_id] and teammate_panel_id ~= HUDManager.PLAYER_PANEL then
		self._teammate_panels[teammate_panel_id]:set_carry_info(carry_id)
	end
end

-- Lines 753-757
function HUDManager:remove_teammate_carry_info(teammate_panel_id, name_label_id)
	if teammate_panel_id and self._teammate_panels[teammate_panel_id] and teammate_panel_id ~= HUDManager.PLAYER_PANEL then
		self._teammate_panels[teammate_panel_id]:remove_carry_info()
	end
end

-- Lines 761-763
function HUDManager:start_player_timer(time)
	self:start_teammate_timer(HUDManager.PLAYER_PANEL, nil, time)
end

-- Lines 765-772
function HUDManager:start_teammate_timer(i, name_label_id, time, current)
	self._teammate_panels[i]:start_timer(time, current)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:start_timer(time, current)
	end
end

-- Lines 774-776
function HUDManager:is_teammate_timer_running(i)
	return self._teammate_panels[i]:is_timer_running()
end

-- Lines 778-780
function HUDManager:pause_player_timer(pause)
	self:pause_teammate_timer(HUDManager.PLAYER_PANEL, nil, pause)
end

-- Lines 782-789
function HUDManager:pause_teammate_timer(i, name_label_id, pause)
	self._teammate_panels[i]:set_pause_timer(pause)

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:set_pause_timer(pause)
	end
end

-- Lines 791-793
function HUDManager:stop_player_timer()
	self:stop_teammate_timer(HUDManager.PLAYER_PANEL, nil)
end

-- Lines 795-804
function HUDManager:stop_teammate_timer(i, name_label_id)
	if self._teammate_panels[i] then
		self._teammate_panels[i]:stop_timer()
	end

	local name_label = self:_get_name_label(name_label_id)

	if name_label then
		name_label:stop_timer()
	end
end

-- Lines 808-852
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
	self:_create_controller_hotswap(hud)
	self:_create_suspicion_direction(hud)
	self:_create_turret_hud(hud)
	self:_create_carry(hud)
	self:_setup_driving_hud()
	self:_create_custody_hud()
	self:_create_hud_chat()
	self:_setup_tab_screen()
	self:_get_tab_objectives()
	self:_create_watermark(hud)
	self:_create_crosshair(hud)
	self:set_motiondot_type(managers.user:get_setting("motion_dot"))
end

-- Lines 854-865
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

-- Lines 867-869
function HUDManager:hud_chat()
	return self._hud_chat
end

-- Lines 871-892
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

-- Lines 894-910
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

-- Lines 913-1029
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

			if peer_carry_data and #peer_carry_data > 0 then
				local unit_data = managers.network:session():peer(peer_id):unit():unit_data()
				local name_label_id = nil

				if unit_data.name_label_id then
					name_label_id = unit_data.name_label_id
				end

				self:set_teammate_carry_info(i, name_label_id, peer_carry_data[1].carry_id)
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

-- Lines 1032-1052
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

-- Lines 1054-1082
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

-- Lines 1084-1092
function HUDManager:get_teammate_panel_by_id(peer_id)
	for i = 1, 4 do
		if peer_id == self._teammate_panels[i]:peer_id() then
			return self._teammate_panels[i]
		end
	end

	return nil
end

-- Lines 1094-1098
function HUDManager:teampanels_height()
	return 300
end

-- Lines 1100-1153
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

-- Lines 1155-1170
function HUDManager:_fix_peer_warcry_icons()
	for i = 1, #self._hud.name_labels do
		local peer_name_label = self._hud.name_labels[i]
		local peer_id = peer_name_label:peer_id()
		local warcry = peer_name_label.warcry

		if peer_name_label and peer_id and warcry then
			for j = 1, #self._teammate_panels do
				local teammate_panel = self._teammate_panels[j]

				if teammate_panel:peer_id() == peer_id then
					teammate_panel:set_active_warcry(warcry)
				end
			end
		end
	end
end

-- Lines 1172-1192
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

-- Lines 1196-1213
function HUDManager:_create_comm_wheel(hud, in_params)
	if self._hud_comm_wheel then
		self._hud_comm_wheel:destroy()

		self._hud_comm_wheel = nil
	end

	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local params = tweak_data.interaction:get_interaction("com_wheel")
	local pm = managers.player
	params.show_clbks = {
		callback(pm, pm, "disable_view_movement")
	}
	params.hide_clbks = {
		callback(pm, pm, "enable_view_movement")
	}
	self._hud_comm_wheel = HUDMultipleChoiceWheel:new(self._saferect, hud, params)

	self._hud_comm_wheel:set_x(hud.panel:w() / 2 - self._hud_comm_wheel:w() / 2)
	self._hud_comm_wheel:set_y(0)
	self._hud_comm_wheel:hide()
end

-- Lines 1215-1217
function HUDManager:comm_wheel_exists()
	return self._hud_comm_wheel ~= nil
end

-- Lines 1219-1225
function HUDManager:show_comm_wheel()
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:show()
end

-- Lines 1227-1231
function HUDManager:trigger_comm_wheel_option(option_id)
	if self._hud_comm_wheel then
		self._hud_comm_wheel:trigger_option(option_id)
	end
end

-- Lines 1233-1238
function HUDManager:hide_comm_wheel(quiet)
	if self._hud_comm_wheel then
		self._hud_comm_wheel:hide(quiet)
	end
end

-- Lines 1240-1246
function HUDManager:add_comm_wheel_option(option, index)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:add_option(option, index)
end

-- Lines 1248-1254
function HUDManager:remove_comm_wheel_option(option_id)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:remove_option(option_id)
end

-- Lines 1256-1262
function HUDManager:set_comm_wheel_options(options)
	if not self._hud_comm_wheel then
		self:_create_comm_wheel()
	end

	self._hud_comm_wheel:set_options(options)
end

-- Lines 1264-1270
function HUDManager:is_comm_wheel_visible()
	if self._hud_comm_wheel ~= nil then
		return self._hud_comm_wheel:is_visible()
	end

	return false
end

-- Lines 1272-1277
function HUDManager:_destroy_comm_wheel()
	if self._hud_comm_wheel then
		self._hud_comm_wheel:destroy()

		self._hud_comm_wheel = nil
	end
end

-- Lines 1282-1292
function HUDManager:_create_carry_wheel(hud, in_params)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local params = tweak_data.interaction:get_interaction("carry_wheel")
	local pm = managers.player
	params.show_clbks = {
		callback(pm, pm, "disable_view_movement")
	}
	params.hide_clbks = {
		callback(pm, pm, "enable_view_movement")
	}
	self._hud_carry_wheel = HUDMultipleChoiceWheel:new(self._saferect, hud, params)

	self._hud_carry_wheel:hide()
end

-- Lines 1294-1300
function HUDManager:show_carry_wheel()
	if not self._hud_carry_wheel then
		self:_create_carry_wheel()
	end

	self._hud_carry_wheel:show()
end

-- Lines 1302-1306
function HUDManager:hide_carry_wheel(quiet)
	if self._hud_carry_wheel then
		self._hud_carry_wheel:hide(quiet)
	end
end

-- Lines 1308-1314
function HUDManager:set_carry_wheel_options(options)
	if not self._hud_carry_wheel then
		self:_create_carry_wheel()
	end

	self._hud_carry_wheel:set_options(options)
end

-- Lines 1316-1322
function HUDManager:is_carry_wheel_visible()
	if self._hud_carry_wheel ~= nil then
		return self._hud_carry_wheel:is_visible()
	end

	return false
end

-- Lines 1324-1329
function HUDManager:_destroy_carry_wheel()
	if self._hud_carry_wheel then
		self._hud_carry_wheel:destroy()

		self._hud_carry_wheel = nil
	end
end

-- Lines 1387-1406
function HUDManager:create_special_interaction(hud, params)
	Application:debug("[HUDManager:create_special_interaction] TYPE", params.minigame_type)

	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local mini = params.minigame_type or tweak_data.interaction.MINIGAME_PICK_LOCK

	if not HUDManager.MINIGAMES[mini] then
		debug_pause("[HUDManager:create_special_interaction] minigame_type was nil!!")
	end

	if self._hud_special_interaction then
		self._hud_special_interaction:destroy()
	end

	self._hud_special_interaction = HUDManager.MINIGAMES[mini]:new(hud, params)

	self._hud_special_interaction:set_tweak_data(params)
	self._hud_special_interaction:hide()

	return self._hud_special_interaction
end

-- Lines 1408-1410
function HUDManager:special_interaction_exists()
	return self._hud_special_interaction ~= nil
end

-- Lines 1412-1416
function HUDManager:show_special_interaction()
	if self._hud_special_interaction then
		self._hud_special_interaction:show()
	end
end

-- Lines 1418-1422
function HUDManager:hide_special_interaction(completed)
	if self._hud_special_interaction then
		self._hud_special_interaction:hide(completed)
	end
end

-- Lines 1424-1430
function HUDManager:is_special_interaction_visible()
	if self._hud_special_interaction ~= nil then
		return self._hud_special_interaction:is_visible()
	end

	return false
end

-- Lines 1435-1441
function HUDManager:_create_present_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._toast_notification = HUDToastNotification:new(hud)

	self._toast_notification:set_x(hud.panel:w() / 2 - self._toast_notification:w() / 2)
	self._toast_notification:set_y(70)
end

-- Lines 1444-1453
function HUDManager:present(params)
	if not self._toast_notification then
		local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

		self:_create_present_panel(hud)
	end

	if self._toast_notification then
		self._toast_notification:present(params)
	end
end

-- Lines 1456-1457
function HUDManager:present_done()
end

-- Lines 1461-1464
function HUDManager:_create_interaction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_interaction = HUDInteraction:new(hud)
end

-- Lines 1467-1469
function HUDManager:show_interact(data)
	self._hud_interaction:show_interact(data)
end

-- Lines 1472-1477
function HUDManager:remove_interact()
	if not self._hud_interaction then
		return
	end

	self._hud_interaction:remove_interact()
end

-- Lines 1480-1482
function HUDManager:show_interaction_bar(current, total)
	self._hud_interaction:show_interaction_bar(current, total)
end

-- Lines 1485-1487
function HUDManager:set_interaction_bar_width(current, total)
	self._hud_interaction:set_interaction_bar_width(current, total)
end

-- Lines 1490-1492
function HUDManager:hide_interaction_bar(complete, show_interact_at_finish)
	self._hud_interaction:hide_interaction_bar(complete, show_interact_at_finish)
end

-- Lines 1496-1499
function HUDManager:_create_progress_timer(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._progress_timer = HUDInteraction:new(hud, "progress_timer")
end

-- Lines 1501-1503
function HUDManager:show_progress_timer(data)
	self._progress_timer:show_interact(data)
end

-- Lines 1505-1507
function HUDManager:remove_progress_timer()
	self._progress_timer:remove_interact()
end

-- Lines 1509-1525
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

-- Lines 1527-1530
function HUDManager:set_progress_timer_bar_width(current, total)
	self._progress_timer_progress_bar:set_progress(current, total)
end

-- Lines 1532-1534
function HUDManager:set_progress_timer_bar_valid(valid, text_id)
	self._progress_timer:set_bar_valid(valid, text_id)
end

-- Lines 1536-1539
function HUDManager:hide_progress_timer_bar(complete)
	self._progress_timer_progress_bar:hide(complete)
end

-- Lines 1543-1549
function HUDManager:create_objectives_timer_hud(current, total)
	self._hud_objectives:show_timer()

	if self._tab_objectives then
		self._tab_objectives:show_timer()
	end
end

-- Lines 1551-1557
function HUDManager:set_objectives_timer_hud_value(current, total, remaining)
	self._hud_objectives:set_timer_value(current, total)

	if self._tab_objectives then
		self._tab_objectives:set_timer_value(current, total)
	end
end

-- Lines 1559-1565
function HUDManager:remove_objectives_timer_hud(complete)
	self._hud_objectives:hide_timer()

	if self._tab_objectives then
		self._tab_objectives:hide_timer()
	end
end

-- Lines 1567-1573
function HUDManager:show_objectives_timer_hud()
	self._hud_objectives:show_timer()

	if self._tab_objectives then
		self._tab_objectives:show_timer()
	end
end

-- Lines 1575-1581
function HUDManager:hide_objectives_timer_hud()
	self._hud_objectives:hide_timer()

	if self._tab_objectives then
		self._tab_objectives:hide_timer()
	end
end

-- Lines 1587-1589
function HUDManager:set_control_info(data)
end

-- Lines 1592-1594
function HUDManager:sync_start_assault(data)
end

-- Lines 1597-1599
function HUDManager:sync_end_assault(result)
end

-- Lines 1603-1615
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

-- Lines 1617-1630
function HUDManager:on_greed_loot_picked_up(old_progress, new_progress, notification_item)
	if self._tab_screen then
		self._tab_screen:on_greed_loot_picked_up(old_progress, new_progress)
	end

	managers.notification:add_notification({
		id = "greed_item_picked_up",
		shelf_life = 8,
		notification_type = HUDNotification.GREED_ITEM,
		initial_progress = old_progress,
		new_progress = new_progress,
		item = notification_item
	})
end

-- Lines 1632-1636
function HUDManager:set_current_greed_amount(amount)
	if self._tab_screen then
		self._tab_screen:set_current_greed_amount(amount)
	end
end

-- Lines 1638-1642
function HUDManager:reset_greed_indicators()
	if self._tab_screen then
		self._tab_screen:reset_greed_indicator()
	end
end

-- Lines 1644-1659
function HUDManager:_setup_tab_screen()
	if not self:exists(HUDManager.TAB_SCREEN_FULLSCREEN) then
		self:load_hud(HUDManager.TAB_SCREEN_SAFERECT, true, true, true, {})
		self:load_hud(HUDManager.TAB_SCREEN_FULLSCREEN, true, true, false, {})
	end

	local hud_tab_fullscreen = managers.hud:script(HUDManager.TAB_SCREEN_FULLSCREEN)
	local hud_tab_safe = managers.hud:script(HUDManager.TAB_SCREEN_SAFERECT)
	self._tab_screen = HUDTabScreen:new(hud_tab_fullscreen, hud_tab_safe)

	self._tab_screen:hide()

	if IS_PC and IS_STEAM then
		managers.network.account:add_overlay_listener("[HUDManager] hide_tab_screen", {
			"overlay_open"
		}, callback(self, self, "hide_stats_screen"))
	end
end

-- Lines 1662-1672
function HUDManager:show_stats_screen()
	self._tab_screen:show()

	self._showing_stats_screen = true

	self:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
	self:hide(PlayerBase.INGAME_HUD_SAFERECT)
	self:hide(IngameWaitingForRespawnState.GUI_SPECTATOR)
	self:show(HUDManager.TAB_SCREEN_FULLSCREEN)
	self:show(HUDManager.TAB_SCREEN_SAFERECT)
end

-- Lines 1675-1693
function HUDManager:hide_stats_screen()
	if self._tab_screen then
		self._tab_screen:hide()
	end

	if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
		self:show(IngameWaitingForRespawnState.GUI_SPECTATOR)
	end

	self:show(PlayerBase.INGAME_HUD_FULLSCREEN)
	self:show(PlayerBase.INGAME_HUD_SAFERECT)

	if self._showing_stats_screen then
		self:hide(HUDManager.TAB_SCREEN_FULLSCREEN)
		self:hide(HUDManager.TAB_SCREEN_SAFERECT)
	end

	self._showing_stats_screen = false
end

-- Lines 1695-1697
function HUDManager:showing_stats_screen()
	return self._showing_stats_screen
end

-- Lines 1699-1701
function HUDManager:set_loot_picked_up(amount)
	self._tab_screen:set_loot_picked_up(amount)
end

-- Lines 1703-1705
function HUDManager:set_loot_total(amount)
	self._tab_screen:set_loot_total(amount)
end

-- Lines 1710-1711
function HUDManager:feed_point_of_no_return_timer(time, is_inside)
end

-- Lines 1714-1715
function HUDManager:show_point_of_no_return_timer()
end

-- Lines 1718-1719
function HUDManager:hide_point_of_no_return_timer()
end

-- Lines 1722-1728
function HUDManager:flash_point_of_no_return_timer(beep)
	if beep then
		self._sound_source:post_event("last_10_seconds_beep")
	end
end

-- Lines 1732-1738
function HUDManager:_create_objectives(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_objectives = HUDObjectives:new(hud.panel)

	self._hud_objectives:set_x(hud.panel:w() - self._hud_objectives:w())
	self._hud_objectives:set_y(0)
end

-- Lines 1740-1742
function HUDManager:_get_tab_objectives()
	self._tab_objectives = self._tab_screen:get_objectives_control()
end

-- Lines 1744-1752
function HUDManager:show_objectives()
	if self._hud_objectives then
		self._hud_objectives:show()
	end

	if self._tab_objectives then
		self._tab_objectives:show()
	end
end

-- Lines 1754-1762
function HUDManager:hide_objectives()
	if self._hud_objectives then
		self._hud_objectives:hide()
	end

	if self._tab_objectives then
		self._tab_objectives:hide()
	end
end

-- Lines 1766-1775
function HUDManager:activate_objective(data)
	if self._hud_objectives then
		self._hud_objectives:activate_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:activate_objective(data)
	end
end

-- Lines 1778-1787
function HUDManager:complete_sub_objective(data)
	if self._hud_objectives then
		self._hud_objectives:complete_sub_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:complete_sub_objective(data)
	end
end

-- Lines 1790-1799
function HUDManager:update_amount_objective(data)
	if self._hud_objectives then
		self._hud_objectives:update_amount_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:update_amount_objective(data)
	end
end

-- Lines 1801-1810
function HUDManager:update_amount_sub_objective(data)
	if self._hud_objectives then
		self._hud_objectives:update_amount_sub_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:update_amount_sub_objective(data)
	end
end

-- Lines 1813-1821
function HUDManager:remind_objective(id)
	if self._hud_objectives then
		self._hud_objectives:remind_objective(id)
	end

	if self._tab_objectives then
		self._tab_objectives:remind_objective(id)
	end
end

-- Lines 1823-1831
function HUDManager:remind_sub_objective(id)
	if self._hud_objectives then
		self._hud_objectives:remind_sub_objective(id)
	end

	if self._tab_objectives then
		self._tab_objectives:remind_sub_objective(id)
	end
end

-- Lines 1834-1843
function HUDManager:complete_objective(data)
	if self._hud_objectives then
		self._hud_objectives:complete_objective(data)
	end

	if self._tab_objectives then
		self._tab_objectives:complete_objective(data)
	end
end

-- Lines 1845-1854
function HUDManager:render_objective()
	if self._hud_objectives then
		self._hud_objectives:update_objectives()
	end

	if self._tab_objectives then
		self._tab_objectives:update_objectives()
	end
end

-- Lines 1859-1861
function HUDManager:feed_session_time(time)
	self._tab_screen:set_time(time)
end

-- Lines 1863-1866
function HUDManager:reset_session_time()
	self._tab_screen:reset_time()
	managers.game_play_central:start_heist_timer()
end

-- Lines 1870-1873
function HUDManager:set_stamina_value(value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(value)
end

-- Lines 1875-1878
function HUDManager:set_max_stamina(value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_max_stamina(value)
end

-- Lines 1882-1886
function HUDManager:_create_turret_hud(hud)
	self._turret_hud = HUDTurret:new(hud)

	self._turret_hud:set_x(hud.panel:w() / 2 - self._turret_hud:w() / 2)
	self._turret_hud:set_y(hud.panel:h() / 2 - self._turret_hud:h() / 2)
end

-- Lines 1888-1890
function HUDManager:show_turret_hud(turret_unit, bullet_type)
	self._turret_hud:show(turret_unit, bullet_type)
end

-- Lines 1892-1894
function HUDManager:hide_turret_hud(turret_unit)
	self._turret_hud:hide(turret_unit)
end

-- Lines 1896-1898
function HUDManager:update_turret_reticle(v3)
	self._turret_hud:update_turret_reticle(v3)
end

-- Lines 1900-1902
function HUDManager:update_heat_indicator(current)
	self._turret_hud:update_heat_indicator(current)
end

-- Lines 1904-1906
function HUDManager:player_turret_overheat(turret_unit)
	self._turret_hud:overheat(turret_unit)
end

-- Lines 1908-1910
function HUDManager:player_turret_flak_insert()
	self._turret_hud:flak_insert()
end

-- Lines 1912-1914
function HUDManager:set_player_turret_overheating(overheating)
	self._turret_hud:set_overheating(overheating)
end

-- Lines 1916-1918
function HUDManager:player_turret_cooldown()
	self._turret_hud:cooldown()
end

-- Lines 1922-1928
function HUDManager:_create_watermark(hud)
end

-- Lines 1932-1937
function HUDManager:_create_carry(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._carry_hud = HUDCarry:new(hud)

	self._carry_hud:set_x(hud.panel:w() / 2 - self._carry_hud:w() / 2)
	self._carry_hud:set_y(hud.panel:h() - self._carry_hud:h())
end

-- Lines 1939-1941
function HUDManager:show_carry_item(carry_id)
	self._carry_hud:show_carry_item(carry_id)
end

-- Lines 1943-1945
function HUDManager:hide_carry_item()
	self._carry_hud:hide_carry_item()
end

-- Lines 1947-1949
function HUDManager:set_carry_weight(ratio, overweight)
	self._carry_hud:set_carry_weight(ratio, overweight)
end

-- Lines 1951-1953
function HUDManager:shake_carry_icon()
	self._carry_hud:shake_carry_icon()
end

-- Lines 1957-1960
function HUDManager:_create_suspicion(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_suspicion = HUDSuspicion:new(hud, self._sound_source)
end

-- Lines 1962-1964
function HUDManager:hide_suspicion()
	self._hud_suspicion:hide()
end

-- Lines 1966-1968
function HUDManager:show_suspicion()
	self._hud_suspicion:show()
end

-- Lines 1971-1984
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

-- Lines 1987-1990
function HUDManager:_create_hit_confirm(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)
	self._hud_hit_confirm = HUDHitConfirm:new(hud)
end

-- Lines 1992-1996
function HUDManager:on_hit_confirmed(data)
	if HUDHitConfirm.MODE_OFF < managers.user:get_setting("hit_indicator") then
		self._hud_hit_confirm:on_hit_confirmed(data or {})
	end
end

-- Lines 1999-2004
function HUDManager:_create_crosshair(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_crosshair = HUDCrosshair:new(hud)

	self:set_crosshair_visible(true)
end

-- Lines 2007-2011
function HUDManager:set_crosshair_type(t)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_type(t)
	end
end

-- Lines 2014-2018
function HUDManager:set_crosshair_visible(visible)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_visible(managers.user:get_setting("hud_crosshairs") and visible)
	end
end

-- Lines 2020-2024
function HUDManager:set_crosshair_fade(visible)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_fade(visible)
	end
end

-- Lines 2027-2031
function HUDManager:set_crosshair_offset(offset)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_offset(offset)
	end
end

-- Lines 2033-2037
function HUDManager:set_crosshair_offset_instant(offset)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_offset_instant(offset)
	end
end

-- Lines 2039-2043
function HUDManager:set_crosshair_offset_kick(offset)
	if self._hud_crosshair then
		self._hud_crosshair:set_crosshair_offset_kick(offset)
	end
end

-- Lines 2045-2049
function HUDManager:update_crosshair_offset(t, dt)
	if self._hud_crosshair and managers.user:get_setting("hud_crosshairs") then
		self._hud_crosshair:update_crosshair_offset(t, dt)
	end
end

-- Lines 2080-2083
function HUDManager:_create_hit_direction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_hit_direction = HUDHitDirection:new(hud)
end

-- Lines 2085-2087
function HUDManager:on_hit_direction(dir, unit_type_hit)
	self._hud_hit_direction:on_hit_direction(dir, unit_type_hit)
end

-- Lines 2089-2091
function HUDManager:on_hit_unit(attack_data, unit_type_hit)
	self._hud_hit_direction:on_hit_unit(attack_data, unit_type_hit)
end

-- Lines 2093-2095
function HUDManager:clear_hit_direction_indicators()
	self._hud_hit_direction:clean_up()
end

-- Lines 2099-2106
function HUDManager:_create_center_prompt(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._center_prompt = HUDCenterPrompt:new(hud)
	local y_offset = 128

	self._center_prompt:set_x(hud.panel:w() / 2 - self._center_prompt:w() / 2)
	self._center_prompt:set_y(hud.panel:h() / 2 + y_offset - self._center_prompt:h() / 2)
end

-- Lines 2108-2110
function HUDManager:set_prompt(id, text, duration)
	self._center_prompt:show_prompt(id, text, duration)
end

-- Lines 2112-2114
function HUDManager:hide_prompt(id)
	self._center_prompt:hide_prompt(id)
end

-- Lines 2119-2125
function HUDManager:_create_big_prompt(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._big_prompt = HUDBigPrompt:new(hud)

	self._big_prompt:set_x(hud.panel:w() / 2 - self._big_prompt:w() / 2)
	self._big_prompt:set_y(hud.panel:h() / 2 - 262)
end

-- Lines 2127-2129
function HUDManager:set_big_prompt(params)
	self._big_prompt:show_prompt(params)
end

-- Lines 2131-2133
function HUDManager:hide_big_prompt(id)
	self._big_prompt:hide_prompt(id)
end

-- Lines 2139-2145
function HUDManager:_create_controller_hotswap(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._controller_hotswap = HUDControllerHotswap:new(hud)

	self._controller_hotswap:set_x(0)
	self._controller_hotswap:set_y(hud.panel:h() / 2 - 140)
end

-- Lines 2147-2149
function HUDManager:set_controller_hotswap(params)
	self._controller_hotswap:show_prompt(params)
end

-- Lines 2151-2153
function HUDManager:hide_controller_hotswap(id)
	self._controller_hotswap:hide_prompt(id)
end

-- Lines 2161-2164
function HUDManager:_create_suspicion_direction(hud)
	hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_suspicion_direction = HUDSuspicionDirection:new(hud)
end

-- Lines 2166-2168
function HUDManager:create_suspicion_indicator(observer_key, observer_position, initial_state, suspect)
	self._hud_suspicion_direction:create_suspicion_indicator(observer_key, observer_position, initial_state, suspect)
end

-- Lines 2170-2172
function HUDManager:need_to_init_suspicion_indicator(observer_key)
	return self._hud_suspicion_direction:need_to_init(observer_key)
end

-- Lines 2174-2176
function HUDManager:initialize_suspicion_indicator(observer_key, alpha)
	self._hud_suspicion_direction:initialize(observer_key, alpha)
end

-- Lines 2178-2180
function HUDManager:show_suspicion_indicator(observer_key)
	self._hud_suspicion_direction:show_suspicion_indicator(observer_key)
end

-- Lines 2182-2184
function HUDManager:hide_suspicion_indicator(observer_key)
	self._hud_suspicion_direction:hide_suspicion_indicator(observer_key)
end

-- Lines 2186-2188
function HUDManager:set_suspicion_indicator_progress(observer_key, progress)
	self._hud_suspicion_direction:set_suspicion_indicator_progress(observer_key, progress)
end

-- Lines 2190-2192
function HUDManager:clear_suspicion_direction_indicators()
	self._hud_suspicion_direction:clean_up()
end

-- Lines 2196-2199
function HUDManager:_create_custody_hud(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_CUSTODY_HUD)
	self._hud_player_custody = HUDPlayerCustody:new(hud)
end

-- Lines 2201-2203
function HUDManager:set_custody_respawn_time(time)
	self._hud_player_custody:set_respawn_time(time)
end

-- Lines 2205-2207
function HUDManager:set_custody_respawn_type(is_ai_trade)
	self._hud_player_custody:set_respawn_type(is_ai_trade)
end

-- Lines 2209-2211
function HUDManager:set_custody_timer_visibility(visible)
	self._hud_player_custody:set_timer_visibility(visible)
end

-- Lines 2213-2215
function HUDManager:set_custody_civilians_killed(amount)
	self._hud_player_custody:set_civilians_killed(amount)
end

-- Lines 2217-2219
function HUDManager:set_custody_trade_delay(time)
	self._hud_player_custody:set_trade_delay(time)
end

-- Lines 2221-2223
function HUDManager:set_custody_trade_delay_visible(visible)
	self._hud_player_custody:set_trade_delay_visible(visible)
end

-- Lines 2225-2227
function HUDManager:set_custody_negotiating_visible(visible)
	self._hud_player_custody:set_negotiating_visible(visible)
end

-- Lines 2229-2231
function HUDManager:set_custody_can_be_trade_visible(visible)
	self._hud_player_custody:set_can_be_trade_visible(visible)
end

-- Lines 2233-2235
function HUDManager:set_custody_pumpkin_challenge()
	self._hud_player_custody:set_pumpkin_challenge()
end

-- Lines 2237-2239
function HUDManager:set_custody_spectator_info(unit)
	self._hud_player_custody:set_spectator_info(unit)
end

-- Lines 2243-2250
function HUDManager:_create_motiondot_hud(hud)
	if not self:is_motion_dot_active() then
		hud = hud or managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
		self._hud_motion_dot = HUDMotionDot:new(hud)
	else
		Application:warn("[HUDManager:_create_motiondot_hud] Motion dot already exists")
	end
end

-- Lines 2252-2259
function HUDManager:_kill_motiondot_hud()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:clean_up()

		self._hud_motion_dot = nil
	else
		Application:warn("[HUDManager:_kill_motiondot_hud] Motion dot doesnt exist to kill")
	end
end

-- Lines 2262-2272
function HUDManager:set_motiondot_type(index)
	if index > 1 then
		if not self:is_motion_dot_active() then
			self:_create_motiondot_hud()
		else
			self._hud_motion_dot:on_setting_counts(index)
		end
	else
		self:_kill_motiondot_hud()
	end
end

-- Lines 2275-2279
function HUDManager:set_motiondot_counts(index)
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_counts(index)
	end
end

-- Lines 2281-2285
function HUDManager:increment_motiondot_counts()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_counts_increment()
	end
end

-- Lines 2288-2292
function HUDManager:set_motiondot_offsets(index)
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_offsets(index)
	end
end

-- Lines 2294-2298
function HUDManager:increment_motiondot_offsets()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_offsets_increment()
	end
end

-- Lines 2301-2305
function HUDManager:set_motiondot_icons(index)
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_icons(index)
	end
end

-- Lines 2307-2311
function HUDManager:increment_motiondot_icons()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_icons_increment()
	end
end

-- Lines 2314-2318
function HUDManager:set_motiondot_sizes(index)
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_sizes(index)
	end
end

-- Lines 2320-2324
function HUDManager:increment_motiondot_sizes()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_sizes_increment()
	end
end

-- Lines 2327-2331
function HUDManager:set_motiondot_color(color)
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_color(color)
	end
end

-- Lines 2332-2336
function HUDManager:set_motiondot_color_silly()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:on_setting_color_silly()
	end
end

-- Lines 2339-2343
function HUDManager:fade_out_motion_dot()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:set_fade_hide_dots()
	end
end

-- Lines 2345-2349
function HUDManager:fade_in_motion_dot()
	if self:is_motion_dot_active() then
		self._hud_motion_dot:set_fade_show_dots()
	end
end

-- Lines 2351-2353
function HUDManager:is_motion_dot_active()
	return not not self._hud_motion_dot
end

-- Lines 2355-2357
function HUDManager:is_motion_dot_ads_fade()
	return self._hud_motion_dot and tweak_data.motion_dot_modes_ads_hides[math.min(self._hud_motion_dot:type_index(), #tweak_data.motion_dot_modes_ads_hides)] or false
end

-- Lines 2361-2420
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

-- Lines 2425-2450
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

-- Lines 2452-2469
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

-- Lines 2471-2484
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

-- Lines 2486-2499
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

-- Lines 2501-2511
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

-- Lines 2514-2525
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

-- Lines 2527-2537
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

-- Lines 2538-2539
function HUDManager:set_name_label_carry_info(peer_id, carry_id)
end

-- Lines 2541-2542
function HUDManager:set_vehicle_label_carry_info(label_id, value, number)
end

-- Lines 2545-2546
function HUDManager:remove_name_label_carry_info(peer_id)
end

-- Lines 2549-2560
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

-- Lines 2562-2573
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

-- Lines 2575-2586
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

-- Lines 2590-2598
function HUDManager:_animate_label_interact(panel, interact, timer)
	local t = 0

	while timer >= t do
		local dt = coroutine.yield()
		t = t + dt

		interact:set_current(t / timer)
	end

	interact:set_current(1)
end

-- Lines 2600-2602
function HUDManager:toggle_chatinput()
	self:set_chat_focus(true)
end

-- Lines 2604-2606
function HUDManager:chat_focus()
	return self._chat_focus
end

-- Lines 2608-2612
function HUDManager:set_chat_skip_first(skip_first)
	if self._hud_chat then
		self._hud_chat:set_skip_first(skip_first)
	end
end

-- Lines 2615-2637
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

-- Lines 2641-2644
function HUDManager:_setup_driving_hud()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_driving = HUDDriving:new(hud)
end

-- Lines 2646-2648
function HUDManager:start_driving()
	self._hud_driving:start()
end

-- Lines 2650-2652
function HUDManager:stop_driving()
	self._hud_driving:stop()
end

-- Lines 2654-2656
function HUDManager:set_driving_vehicle_state(speed, rpm, gear)
	self._hud_driving:set_vehicle_state(speed, rpm, gear)
end

-- Lines 2658-2660
function HUDManager:set_vehicle_loot_info(vehicle, current_loot, current_loot_amount, max_loot_amount)
	self._hud_driving:set_vehicle_loot_info(vehicle, current_loot, current_loot_amount, max_loot_amount)
end

-- Lines 2662-2664
function HUDManager:ai_entered_vehicle(ai_unit, vehicle)
	self._hud_driving:refresh_seats()
end

-- Lines 2666-2673
function HUDManager:peer_enter_vehicle(peer_id, vehicle)
	if peer_id == managers.network:session():local_peer():id() then
		self._hud_driving:show(vehicle)
	end

	self._hud_driving:refresh_seats()
	self._tab_screen:peer_enter_vehicle(peer_id)
end

-- Lines 2675-2683
function HUDManager:peer_exit_vehicle(peer_id)
	if peer_id == managers.network:session():local_peer():id() then
		self._hud_driving:hide()
	else
		self._hud_driving:refresh_seats()
	end

	self._tab_screen:peer_exit_vehicle(peer_id)
end

-- Lines 2685-2687
function HUDManager:player_changed_vehicle_seat()
	self._hud_driving:refresh_seats(true)
end

-- Lines 2689-2691
function HUDManager:refresh_vehicle_health()
	self._hud_driving:refresh_health()
end

-- Lines 2693-2695
function HUDManager:hide_vehicle_hud()
	self._hud_driving:hide()
end
