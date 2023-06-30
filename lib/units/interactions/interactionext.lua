BaseInteractionExt = BaseInteractionExt or class()
BaseInteractionExt.EVENT_IDS = {
	at_interact_start = 1,
	at_interact_interupt = 2
}
BaseInteractionExt.SKILL_IDS = {
	none = 1,
	basic = 2,
	aced = 3
}
BaseInteractionExt.INFO_IDS = {
	1,
	2,
	4,
	8,
	16,
	32,
	64,
	128
}
BaseInteractionExt.INTERACTION_TYPE = {
	locator_based = "locator_based"
}

-- Lines 17-29
function BaseInteractionExt:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("interaction"), false)
	self:refresh_material()
	self:set_tweak_data(self.tweak_data)
	self:set_active(self._tweak_data.start_active or self._tweak_data.start_active == nil and true)
	self:_upd_interaction_topology()
end

local ids_material = Idstring("material")

-- Lines 32-40
function BaseInteractionExt:refresh_material()
	self._materials = {}
	local all_materials = self._unit:get_objects_by_type(ids_material)

	for _, m in ipairs(all_materials) do
		if m:variable_exists(Idstring("contour_color")) then
			table.insert(self._materials, m)
		end
	end
end

-- Lines 42-44
function BaseInteractionExt:external_upd_interaction_topology()
	self:_upd_interaction_topology()
end

-- Lines 46-58
function BaseInteractionExt:_upd_interaction_topology()
	if self._tweak_data.interaction_obj then
		self._interact_obj = self._unit:get_object(self._tweak_data.interaction_obj)
	else
		self._interact_obj = self._interact_object and self._unit:get_object(Idstring(self._interact_object))
	end

	self._interact_position = self._interact_obj and self._interact_obj:position() or self._unit:position()
	local rotation = self._interact_obj and self._interact_obj:rotation() or self._unit:rotation()
	self._interact_axis = self._tweak_data.axis and rotation[self._tweak_data.axis](rotation) or nil

	self:_update_interact_position()
	self:_setup_ray_objects()
end

-- Lines 60-89
function BaseInteractionExt:set_tweak_data(id)
	local contour_id = self._contour_id
	local selected_contour_id = self._selected_contour_id

	if contour_id then
		self._unit:contour():remove_by_id(contour_id)

		self._contour_id = nil
	end

	if selected_contour_id then
		self._unit:contour():remove_by_id(selected_contour_id)

		self._selected_contour_id = nil
	end

	self.tweak_data = id
	self._tweak_data = tweak_data.interaction[id]

	if self._active and self._tweak_data.contour_preset then
		self._contour_id = self._unit:contour():add(self._tweak_data.contour_preset)
	end

	if self._active and self._is_selected and self._tweak_data.contour_preset_selected then
		self._selected_contour_id = self._unit:contour():add(self._tweak_data.contour_preset_selected)
	end

	self:_upd_interaction_topology()

	if alive(managers.interaction:active_unit()) and self._unit == managers.interaction:active_unit() then
		self:set_dirty(true)
	end
end

-- Lines 91-93
function BaseInteractionExt:set_dirty(dirty)
	self._dirty = dirty
end

-- Lines 94-96
function BaseInteractionExt:dirty()
	return self._dirty
end

-- Lines 98-101
function BaseInteractionExt:interact_position()
	self:_update_interact_position()

	return self._interact_position
end

-- Lines 103-106
function BaseInteractionExt:interact_axis()
	self:_update_interact_axis()

	return self._interact_axis
end

-- Lines 108-115
function BaseInteractionExt:_setup_ray_objects()
	if self._ray_object_names then
		self._ray_objects = {
			self._interact_obj or self._unit:orientation_object()
		}

		for _, object_name in ipairs(self._ray_object_names) do
			table.insert(self._ray_objects, self._unit:get_object(Idstring(object_name)))
		end
	end
end

-- Lines 117-119
function BaseInteractionExt:ray_objects()
	return self._ray_objects
end

-- Lines 121-123
function BaseInteractionExt:self_blocking()
	return self._self_blocking
end

-- Lines 126-130
function BaseInteractionExt:_update_interact_position()
	if self._unit:moving() or self._tweak_data.force_update_position then
		self._interact_position = self._interact_obj and self._interact_obj:position() or self._unit:position()
	end
end

-- Lines 132-134
function BaseInteractionExt:refresh_interact_position()
	self._interact_position = self._interact_obj and self._interact_obj:position() or self._unit:position()
end

-- Lines 137-142
function BaseInteractionExt:_update_interact_axis()
	if self._tweak_data.axis and self._unit:moving() then
		local rotation = self._interact_obj and self._interact_obj:rotation() or self._unit:rotation()
		self._interact_axis = self._tweak_data.axis and rotation[self._tweak_data.axis](rotation) or nil
	end
end

-- Lines 144-146
function BaseInteractionExt:interact_distance()
	return self._tweak_data.interact_distance or tweak_data.interaction.INTERACT_DISTANCE
end

-- Lines 148-150
function BaseInteractionExt:interact_dont_interupt_on_distance()
	return self._tweak_data.interact_dont_interupt_on_distance or false
end

-- Lines 152-153
function BaseInteractionExt:update(distance_to_player)
end

-- Lines 155-162
function BaseInteractionExt:_btn_interact()
	if not managers.menu:is_pc_controller() then
		return nil
	end

	local val = managers.localization:btn_macro("interact")

	return val .. "\n"
end

-- Lines 164-183
function BaseInteractionExt:can_select(player)
	if not self._active then
		return false
	end

	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if self._tweak_data.special_equipment_block and managers.player:has_special_equipment(self._tweak_data.special_equipment_block) then
		return false
	end

	return true
end

-- Lines 185-197
function BaseInteractionExt:selected(player)
	local can_select, block_text = self:can_select(player)

	if not can_select then
		return
	end

	self._is_selected = true

	if block_text ~= false then
		self:_show_interaction_text()
	end

	return true
end

-- Lines 200-255
function BaseInteractionExt:_show_interaction_text(custom_text_id)
	local string_macros = {}

	self:_add_string_macros(string_macros)

	local text_id = custom_text_id or self._tweak_data.text_id or alive(self._unit) and self._unit:base().interaction_text_id and self._unit:base():interaction_text_id()
	local text = managers.localization:text(text_id, string_macros)
	local icon = self._tweak_data.icon

	if self._tweak_data.special_equipment and not managers.player:has_special_equipment(self._tweak_data.special_equipment) then
		local has_special_equipment = false

		if self._tweak_data.possible_special_equipment then
			for i, special_equipment in ipairs(self._tweak_data.possible_special_equipment) do
				if managers.player:has_special_equipment(special_equipment) then
					has_special_equipment = true

					break
				end
			end
		end

		if not has_special_equipment then
			text = managers.localization:text(self._tweak_data.equipment_text_id, string_macros)
			icon = self.no_equipment_icon or self._tweak_data.no_equipment_icon or icon
		end
	end

	if not not self._tweak_data.required_carry then
		local has_carry_item = false
		local plr_carry = managers.player:current_carry_id()

		if plr_carry then
			has_carry_item = (type(self._tweak_data.required_carry) ~= "table" or table.contains(self._tweak_data.required_carry, plr_carry)) and self._tweak_data.required_carry == plr_carry
		end

		if not has_carry_item then
			text = managers.localization:text(self._tweak_data.carry_text_id, string_macros)
			icon = self.no_equipment_icon or self._tweak_data.no_equipment_icon or icon
		end
	end

	if self._tweak_data.contour_preset or self._tweak_data.contour_preset_selected then
		if not self._selected_contour_id and self._tweak_data.contour_preset_selected and self._tweak_data.contour_preset ~= self._tweak_data.contour_preset_selected then
			self._selected_contour_id = self._unit:contour():add(self._tweak_data.contour_preset_selected)
		end
	else
		self:set_contour("selected_color")
	end

	if self._hide_interaction_prompt ~= true then
		managers.hud:show_interact({
			text = text,
			icon = icon
		})
	end
end

-- Lines 257-259
function BaseInteractionExt:_add_string_macros(macros)
	macros.BTN_INTERACT = self:_btn_interact()
end

-- Lines 261-285
function BaseInteractionExt:unselect()
	self._is_selected = nil

	if self._tweak_data.contour_preset or self._tweak_data.contour_preset_selected then
		if self._selected_contour_id then
			self._unit:contour():remove_by_id(self._selected_contour_id)
		end

		self._selected_contour_id = nil
	elseif not self._unit:vehicle_driving() then
		self:set_contour("standard_color")
	else
		local vehicle_state_name = self._unit:vehicle_driving():get_state_name()

		if vehicle_state_name == VehicleDrivingExt.STATE_BROKEN then
			self:set_contour("standard_color", 1)
		else
			self:set_contour("standard_color", 0)
		end
	end
end

-- Lines 287-299
function BaseInteractionExt:_has_required_upgrade(movement_state)
	if not movement_state then
		return true
	end

	if self._tweak_data.requires_upgrade then
		local category = self._tweak_data.requires_upgrade.category
		local upgrade = self._tweak_data.requires_upgrade.upgrade

		return managers.player:has_category_upgrade(category, upgrade)
	end

	return true
end

-- Lines 301-307
function BaseInteractionExt:_has_required_deployable()
	if self._tweak_data.required_deployable then
		return managers.player:has_deployable_left(self._tweak_data.required_deployable)
	end

	return true
end

-- Lines 309-314
function BaseInteractionExt:_allowed_in_movement_state(movement_state)
	if not movement_state then
		return false
	end

	return true
end

-- Lines 316-326
function BaseInteractionExt:_is_in_required_state(movement_state)
	if self._tweak_data.can_interact_only_in_civilian then
		if movement_state == "civilian" then
			return true
		else
			return false
		end
	end

	return true
end

-- Lines 328-334
function BaseInteractionExt:_interact_say(data)
	local player = data[1]
	local say_line = data[2]
	self._interact_say_clbk = nil

	player:sound():say(say_line, true)
end

-- Lines 336-397
function BaseInteractionExt:interact_start(player, locator)
	-- Lines 338-345
	local function show_hint(hint_id)
		managers.notification:add_notification({
			duration = 2,
			shelf_life = 5,
			id = hint_id,
			text = managers.localization:text(hint_id)
		})
	end

	local blocked, skip_hint, custom_hint = self:_interact_blocked(player)

	if blocked then
		if not skip_hint and (custom_hint or self._tweak_data.blocked_hint) then
			Application:debug("[BaseInteractionExt:interact_start] interaction blocked, unit: " .. tostring(self._unit), "block_hint: " .. tostring(custom_hint or self._tweak_data.blocked_hint))

			if self._tweak_data.blocked_hint_sound then
				self:_post_event(player, "blocked_hint_sound")
				managers.dialog:queue_dialog("player_gen_full_reserve", {
					skip_idle_check = true,
					instigator = managers.player:local_player()
				})
			end

			if custom_hint or self._tweak_data.blocked_hint then
				show_hint(custom_hint or self._tweak_data.blocked_hint)
			end
		end

		return false
	end

	local has_equipment = not self._tweak_data.special_equipment and true or managers.player:has_special_equipment(self._tweak_data.special_equipment)
	local sound = has_equipment and (self._tweak_data.say_waiting or "") or self.say_waiting

	if sound and sound ~= "" then
		local delay = (self:_timer_value() or 0) * managers.player:toolset_value()
		delay = delay / 3 + math.random() * delay / 3
		local say_t = Application:time() + delay
		self._interact_say_clbk = "interact_say_waiting"

		managers.enemy:add_delayed_clbk(self._interact_say_clbk, callback(self, self, "_interact_say", {
			player,
			sound
		}), say_t)
	end

	if not self:can_interact(player) then
		if self._tweak_data.blocked_hint then
			show_hint(self._tweak_data.blocked_hint)
		end

		return false
	end

	if self._unit:damage() and self._unit:damage():has_sequence("interact_start_local") then
		self._unit:damage():run_sequence_simple("interact_start_local", {
			unit = player
		})
	end

	if self:_timer_value() then
		local timer = self:_get_timer()

		if timer ~= 0 then
			self:_post_event(player, "sound_start")
			self:_at_interact_start(player, timer)

			return false, timer
		end
	end

	return self:interact(player, locator)
end

-- Lines 400-402
function BaseInteractionExt:_timer_value()
	return self._tweak_data.timer
end

-- Lines 404-426
function BaseInteractionExt:_get_timer()
	local modified_timer = self:_get_modified_timer()

	if modified_timer then
		return modified_timer
	end

	local multiplier = 1

	if self._tweak_data.upgrade_timer_multiplier then
		multiplier = multiplier * managers.player:upgrade_value(self._tweak_data.upgrade_timer_multiplier.category, self._tweak_data.upgrade_timer_multiplier.upgrade, 1)
	end

	if self._tweak_data.upgrade_timer_multipliers then
		for _, upgrade_timer_multiplier in pairs(self._tweak_data.upgrade_timer_multipliers) do
			multiplier = multiplier * managers.player:upgrade_value(upgrade_timer_multiplier.category, upgrade_timer_multiplier.upgrade, 1)
		end
	end

	if managers.player:has_category_upgrade("player", "level_interaction_timer_multiplier") then
		local data = managers.player:upgrade_value("player", "level_interaction_timer_multiplier") or {}
		local player_level = managers.experience:current_level() or 0
		multiplier = multiplier * (1 - (data[1] or 0) * math.ceil(player_level / (data[2] or 1)))
	end

	return self:_timer_value() * multiplier * managers.player:toolset_value()
end

-- Lines 428-434
function BaseInteractionExt:_get_modified_timer()
	if managers.player:has_category_upgrade("interaction", "general_interaction_timer_multiplier") then
		return self:_timer_value() * managers.player:upgrade_value("interaction", "general_interaction_timer_multiplier", 1)
	end

	return nil
end

-- Lines 437-439
function BaseInteractionExt:check_interupt()
	return false
end

-- Lines 441-457
function BaseInteractionExt:interact_interupt(player, complete)
	local tweak_data_id = self._tweak_data_at_interact_start ~= self.tweak_data and self._tweak_data_at_interact_start

	self:_post_event(player, "sound_interupt", tweak_data_id)

	if self._interact_say_clbk then
		managers.enemy:remove_delayed_clbk(self._interact_say_clbk)

		self._interact_say_clbk = nil
	end

	if not complete and self._unit:damage() and self._unit:damage():has_sequence("interact_interupt_local") then
		self._unit:damage():run_sequence_simple("interact_interupt_local", {
			unit = player
		})
	end

	self:_at_interact_interupt(player, complete)
end

-- Lines 459-474
function BaseInteractionExt:_post_event(player, sound_type, tweak_data_id)
	if not alive(player) then
		return
	end

	if player ~= managers.player:player_unit() then
		return
	end

	local tweak_data_table = self._tweak_data

	if tweak_data_id then
		tweak_data_table = tweak_data.interaction[tweak_data_id]
	end

	if tweak_data_table[sound_type] then
		player:sound():play(tweak_data_table[sound_type])
	end
end

-- Lines 476-478
function BaseInteractionExt:_at_interact_start()
	self._tweak_data_at_interact_start = self.tweak_data
end

-- Lines 480-482
function BaseInteractionExt:_at_interact_interupt(player, complete)
	self._tweak_data_at_interact_start = nil
end

-- Lines 484-496
function BaseInteractionExt:interact(player)
	self._tweak_data_at_interact_start = nil

	self:_post_event(player, "sound_done")

	local weap_base = managers.player:get_current_state()._equipped_unit:base()

	if weap_base.name_id == "dp28" then
		weap_base:set_magazine_pos_based_on_ammo()
	end
end

-- Lines 498-518
function BaseInteractionExt:can_interact(player)
	if not self._active then
		return false
	end

	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if self._tweak_data.special_equipment_block and managers.player:has_special_equipment(self._tweak_data.special_equipment_block) then
		return false
	end

	if not self._tweak_data.special_equipment or self._tweak_data.dont_need_equipment then
		return true
	end

	return managers.player:has_special_equipment(self._tweak_data.special_equipment)
end

-- Lines 520-522
function BaseInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 524-526
function BaseInteractionExt:active()
	return self._active
end

-- Lines 528-591
function BaseInteractionExt:set_active(active, sync)
	if not active and self._active then
		managers.interaction:remove_unit(self._unit)

		if self._tweak_data.contour_preset or self._tweak_data.contour_preset_selected then
			if self._contour_id and self._unit:contour() then
				self._unit:contour():remove_by_id(self._contour_id)
			end

			self._contour_id = nil

			if self._selected_contour_id and self._unit:contour() then
				self._unit:contour():remove_by_id(self._selected_contour_id)
			end

			self._selected_contour_id = nil
		elseif not self._tweak_data.no_contour then
			managers.occlusion:add_occlusion(self._unit)
		end

		self._is_selected = nil
	elseif active and not self._active then
		managers.interaction:add_unit(self._unit)

		if self._tweak_data.contour_preset then
			if not self._contour_id then
				self._contour_id = self._unit:contour():add(self._tweak_data.contour_preset)
			end
		elseif not self._tweak_data.no_contour then
			managers.occlusion:remove_occlusion(self._unit)
		end
	end

	self._active = active

	if not self._tweak_data.contour_preset then
		local contour = self._unit:contour()

		if not contour or contour:enabled() then
			local opacity_value = self:_set_active_contour_opacity()

			self:set_contour("standard_color", opacity_value)
		end
	end

	if sync and managers.network:session() then
		local u_id = self._unit:id()

		if u_id == -1 then
			debug_pause_unit(self._unit, "[BaseInteractionExt:set_active] could not sync interaction state.", self._unit)

			return
		end

		managers.network:session():send_to_peers_synched("interaction_set_active", self._unit, u_id, active, self.tweak_data, self._unit:contour() and self._unit:contour():is_flashing() or false)
	end
end

-- Lines 593-611
function BaseInteractionExt:_set_active_contour_opacity()
	return nil
end

-- Lines 613-618
function BaseInteractionExt:set_outline_flash_state(state, sync)
	if self._contour_id then
		self._unit:contour():flash(self._contour_id, state and self._tweak_data.contour_flash_interval or nil)
		self:set_active(self._active, sync)
	end
end

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")

-- Lines 622-639
function BaseInteractionExt:set_contour(color, opacity)
	local contour = self._unit:contour()

	if contour and not contour:enabled() or self._tweak_data.no_contour or self._contour_override then
		return
	end

	for _, m in ipairs(self._materials) do
		m:set_variable(ids_contour_color, tweak_data.contour[self._tweak_data.contour or "interactable"][color])
		m:set_variable(ids_contour_opacity, opacity or self._active and 1 or 0)
	end
end

-- Lines 641-643
function BaseInteractionExt:set_contour_override(state)
	self._contour_override = state
end

-- Lines 645-657
function BaseInteractionExt:save(data)
	local state = {
		active = self._active
	}

	if self.tweak_data then
		state.tweak_data = self.tweak_data
	end

	if self._unit:contour() and self._unit:contour():is_flashing() then
		state.is_flashing = true
	end

	data.InteractionExt = state
end

-- Lines 659-671
function BaseInteractionExt:load(data)
	local state = data.InteractionExt

	if state then
		self:set_active(state.active)

		if state.tweak_data then
			self:set_tweak_data(state.tweak_data)
		end

		if state.is_flashing and self._contour_id then
			self._unit:contour():flash(self._contour_id, self._tweak_data.contour_flash_interval)
		end
	end
end

-- Lines 673-677
function BaseInteractionExt:remove_interact()
	if not managers.interaction:active_unit() or self._unit == managers.interaction:active_unit() then
		managers.hud:remove_interact()
	end
end

-- Lines 679-699
function BaseInteractionExt:destroy()
	self:remove_interact()
	self:set_active(false, false)

	if self._unit == managers.interaction:active_unit() then
		self:_post_event(managers.player:player_unit(), "sound_interupt")
	end

	if self._tweak_data.contour_preset then
		-- Nothing
	elseif not self._tweak_data.no_contour then
		managers.occlusion:add_occlusion(self._unit)
	end

	if self._interacting_units then
		for u_key, unit in pairs(self._interacting_units) do
			if alive(unit) then
				unit:base():remove_destroy_listener(self._interacting_unit_destroy_listener_key)
			end
		end

		self._interacting_units = nil
	end
end

UseInteractionExt = UseInteractionExt or class(BaseInteractionExt)

-- Lines 705-708
function UseInteractionExt:unselect()
	UseInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 710-774
function UseInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	UseInteractionExt.super.interact(self, player)

	if self._tweak_data.equipment_consume then
		managers.player:remove_special(self._tweak_data.special_equipment)

		if self._tweak_data.special_equipment == "planks" and Global.level_data.level_id == "secret_stash" then
			UseInteractionExt._saviour_count = (UseInteractionExt._saviour_count or 0) + 1
		end
	end

	if self._tweak_data.deployable_consume then
		managers.player:remove_equipment(self._tweak_data.required_deployable)
	end

	if self._tweak_data.sound_event then
		player:sound():play(self._tweak_data.sound_event)
	end

	self:remove_interact()

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	if self._unit:damage() and self._unit:damage():has_sequence("load") then
		self._unit:damage():run_sequence_simple("load", {
			unit = player
		})
	end

	managers.network:session():send_to_peers_synched("sync_interacted", self._unit, -2, self.tweak_data, 1)

	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	self:set_active(self._tweak_data.keep_active == true)
end

-- Lines 776-817
function UseInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end

	local player = peer:unit()

	if not skip_alive_check and not alive(player) then
		return
	end

	self:remove_interact()
	self:set_active(false)

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	if self._unit:damage() and self._unit:damage():has_sequence("load") then
		self._unit:damage():run_sequence_simple("load", {
			unit = player
		})
	end

	return player
end

-- Lines 819-822
function UseInteractionExt:destroy()
	UseInteractionExt.super.destroy(self)
end

LootCrateInteractionExt = LootCrateInteractionExt or class(UseInteractionExt)

-- Lines 829-831
function LootCrateInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 833-854
function LootCrateInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	LootCrateInteractionExt.super.interact(self, player)

	local loot_index = 1
	local loot_locator = self._unit:get_object(Idstring("item_" .. string.format("%02d", loot_index)))

	while alive(loot_locator) do
		managers.drop_loot:drop_item(self._tweak_data.loot_table[1], loot_locator:position(), loot_locator:rotation())

		loot_index = loot_index + 1
		loot_locator = self._unit:get_object(Idstring("item_" .. string.format("%02d", loot_index)))
	end

	managers.statistics:open_loot_crate()

	return true
end

LootDropInteractionExt = LootDropInteractionExt or class(UseInteractionExt)

-- Lines 861-871
function LootDropInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	LootDropInteractionExt.super.interact(self, player)

	if Network:is_server() then
		self:_spawn_loot()
	end

	return true
end

-- Lines 873-878
function LootDropInteractionExt:sync_interacted(...)
	LootDropInteractionExt.super.sync_interacted(self, ...)

	if Network:is_server() then
		self:_spawn_loot()
	end
end

-- Lines 880-885
function LootDropInteractionExt:_spawn_loot()
	local loot_locator = self._unit:get_object(Idstring("snap_1"))
	local unit = managers.game_play_central:spawn_pickup({
		name = "gold_bar_medium",
		position = loot_locator:position() + Vector3(0, 0, 5),
		rotation = loot_locator:rotation()
	})

	unit:loot_drop():set_value(self._unit:loot_drop():value())
	managers.network:session():send_to_peers_synched("sync_loot_value", unit, self._unit:loot_drop():value())
end

SpecialLootCrateInteractionExt = SpecialLootCrateInteractionExt or class(LootCrateInteractionExt)

-- Lines 891-893
function SpecialLootCrateInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 895-913
function SpecialLootCrateInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	local params = deep_clone(self._tweak_data)
	params.target_unit = self._unit
	local pm = managers.player
	params.number_of_circles = math.max(params.number_of_circles - pm:upgrade_value("interaction", "wheel_amount_decrease", 0), 1)
	local count = params.number_of_circles

	for i = 1, count do
		params.circle_difficulty[i] = params.circle_difficulty[i] * pm:upgrade_value("interaction", "wheel_hotspot_increase", 1)
		params.circle_rotation_speed[i] = params.circle_rotation_speed[i] * pm:upgrade_value("interaction", "wheel_rotation_speed_increase", 1)
	end

	self._player = player
	self._unit:unit_data()._interaction_done = false

	game_state_machine:change_state_by_name("ingame_special_interaction", params)

	return true
end

-- Lines 915-918
function SpecialLootCrateInteractionExt:special_interaction_done()
	SpecialLootCrateInteractionExt.super.interact(self, self._player)
	managers.network:session():send_to_peers("special_interaction_done", self._unit)
end

-- Lines 920-922
function SpecialLootCrateInteractionExt:set_special_interaction_done()
	self._unit:unit_data()._interaction_done = true
end

PickupInteractionExt = PickupInteractionExt or class(UseInteractionExt)

-- Lines 928-930
function PickupInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 932-942
function PickupInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	PickupInteractionExt.super.interact(self, player)
	self._unit:pickup():pickup(player)

	return true
end

HealthPickupInteractionExt = HealthPickupInteractionExt or class(PickupInteractionExt)

-- Lines 948-950
function HealthPickupInteractionExt:_interact_blocked(player)
	return player:character_damage():full_health()
end

-- Lines 952-966
function HealthPickupInteractionExt:selected(player)
	if not self:can_select(player) then
		return
	end

	if player ~= nil and player:character_damage():full_health() then
		self._hide_interaction_prompt = true
	end

	local return_val = HealthPickupInteractionExt.super.selected(self, player)
	self._hide_interaction_prompt = nil

	return return_val
end

-- Lines 968-971
function HealthPickupInteractionExt:unselect()
	HealthPickupInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 973-981
function HealthPickupInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	HealthPickupInteractionExt.super.interact(self, player)

	return true
end

AmmoPickupInteractionExt = AmmoPickupInteractionExt or class(PickupInteractionExt)

-- Lines 987-1001
function AmmoPickupInteractionExt:selected(player)
	if not self:can_select(player) then
		return
	end

	if player ~= nil and not player:inventory():need_ammo() then
		self._hide_interaction_prompt = true
	end

	local return_val = AmmoPickupInteractionExt.super.selected(self, player)
	self._hide_interaction_prompt = nil

	return return_val
end

-- Lines 1003-1006
function AmmoPickupInteractionExt:unselect()
	AmmoPickupInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 1008-1010
function AmmoPickupInteractionExt:_interact_blocked(player)
	return not player:inventory():need_ammo()
end

-- Lines 1012-1020
function AmmoPickupInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	AmmoPickupInteractionExt.super.interact(self, player)

	return true
end

GrenadePickupInteractionExt = GrenadePickupInteractionExt or class(PickupInteractionExt)

-- Lines 1026-1040
function GrenadePickupInteractionExt:selected(player)
	if not self:can_select(player) then
		return
	end

	if managers.player:got_max_grenades() then
		self._hide_interaction_prompt = true
	end

	local return_val = GrenadePickupInteractionExt.super.selected(self, player)
	self._hide_interaction_prompt = nil

	return return_val
end

-- Lines 1042-1045
function GrenadePickupInteractionExt:unselect()
	GrenadePickupInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 1047-1049
function GrenadePickupInteractionExt:_interact_blocked(player)
	return managers.player:got_max_grenades()
end

-- Lines 1051-1059
function GrenadePickupInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	GrenadePickupInteractionExt.super.interact(self, player)

	return true
end

DropInteractionExt = DropInteractionExt or class(UseInteractionExt)

-- Lines 1065-1067
function DropInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 1069-1079
function DropInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	DropInteractionExt.super.super.interact(self, player)

	local params = deep_clone(self._tweak_data)
	params.target_unit = self._unit

	game_state_machine:change_state_by_name("ingame_multiple_choice_interaction", params)

	return true
end

MultipleChoiceInteractionExt = MultipleChoiceInteractionExt or class(UseInteractionExt)

-- Lines 1158-1183
function MultipleChoiceInteractionExt:can_interact(player)
	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if self._tweak_data.special_equipment_block and managers.player:has_special_equipment(self._tweak_data.special_equipment_block) then
		return false
	end

	if not self._tweak_data.special_equipment or self._tweak_data.dont_need_equipment then
		return true
	end

	if managers.player:has_special_equipment(self._tweak_data.special_equipment) then
		return true
	end

	if self._tweak_data.possible_special_equipment then
		for i, special_equipment in ipairs(self._tweak_data.possible_special_equipment) do
			if managers.player:has_special_equipment(special_equipment) then
				return true
			end
		end
	end

	return false
end

-- Lines 1185-1209
function MultipleChoiceInteractionExt:interact(player)
	if self._tweak_data.dont_need_equipment then
		MultipleChoiceInteractionExt.super.interact(self, player)

		return
	end

	if not managers.player:has_special_equipment(self._tweak_data.special_equipment) then
		if self._tweak_data.possible_special_equipment then
			for i, special_equipment in ipairs(self._tweak_data.possible_special_equipment) do
				if managers.player:has_special_equipment(special_equipment) then
					managers.player:remove_special(special_equipment)
				end
			end
		end

		if self._unit:damage() then
			self._unit:damage():run_sequence_simple("wrong", {
				unit = player
			})
		end

		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "interaction", 1)

		return
	end

	MultipleChoiceInteractionExt.super.interact(self, player)
	managers.player:remove_special(self._tweak_data.special_equipment)
end

-- Lines 1211-1215
function MultipleChoiceInteractionExt:sync_net_event(event_id, player)
	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("wrong", {
			unit = player
		})
	end
end

ECMJammerInteractionExt = ECMJammerInteractionExt or class(UseInteractionExt)

-- Lines 1221-1229
function ECMJammerInteractionExt:interact(player)
	if not self:can_interact(player) then
		return false
	end

	ECMJammerInteractionExt.super.super.interact(self, player)
	self._unit:base():set_feedback_active()
	self:remove_interact()
end

-- Lines 1231-1233
function ECMJammerInteractionExt:can_interact(player)
	return ECMJammerInteractionExt.super.can_interact(self, player) and self._unit:base():owner() == player
end

-- Lines 1235-1246
function ECMJammerInteractionExt:selected(player)
	if not self:can_interact(player) then
		return
	end

	local result = ECMJammerInteractionExt.super.selected(self, player)

	if result then
		self._unit:base():contour_selected()
	end

	return result
end

-- Lines 1248-1251
function ECMJammerInteractionExt:unselect()
	ECMJammerInteractionExt.super.unselect(self)
	self._unit:base():contour_unselected()
end

-- Lines 1253-1256
function ECMJammerInteractionExt:set_active(active, sync, ...)
	ECMJammerInteractionExt.super.set_active(self, active, sync, ...)
	self._unit:base():contour_interaction()
end

ReviveInteractionExt = ReviveInteractionExt or class(BaseInteractionExt)

-- Lines 1263-1266
function ReviveInteractionExt:init(unit, ...)
	self._wp_id = "ReviveInteractionExt" .. unit:id()

	ReviveInteractionExt.super.init(self, unit, ...)
end

-- Lines 1270-1280
function ReviveInteractionExt:_at_interact_start(player, timer)
	ReviveInteractionExt.super._at_interact_start(self, player, timer)

	if self.tweak_data == "revive" then
		self:_at_interact_start_revive(player, timer)
	elseif self.tweak_data == "free" then
		self:_at_interact_start_free(player)
	end

	self:set_waypoint_paused(true)
	managers.network:session():send_to_peers_synched("interaction_set_waypoint_paused", self._unit, true)
end

-- Lines 1282-1293
function ReviveInteractionExt:_at_interact_start_revive(player, timer)
	if self._unit:base().is_husk_player then
		local revive_rpc_params = {
			"start_revive_player",
			timer
		}

		self._unit:network():send_to_unit(revive_rpc_params)
	else
		self._unit:character_damage():pause_bleed_out()
	end

	if player:base().is_local_player then
		managers.achievment:set_script_data("player_reviving", true)
	end
end

-- Lines 1295-1302
function ReviveInteractionExt:_at_interact_start_free(player)
	if self._unit:base().is_husk_player then
		local revive_rpc_params = {
			"start_free_player"
		}

		self._unit:network():send_to_unit(revive_rpc_params)
	else
		self._unit:character_damage():pause_arrested_timer()
	end
end

-- Lines 1306-1318
function ReviveInteractionExt:_at_interact_interupt(player, complete)
	ReviveInteractionExt.super._at_interact_interupt(self, player, complete)

	if self.tweak_data == "revive" then
		self:_at_interact_interupt_revive(player)
	elseif self.tweak_data == "free" then
		self:_at_interact_interupt_free(player)
	end

	self:set_waypoint_paused(false)

	if self._unit:id() ~= -1 then
		managers.network:session():send_to_peers_synched("interaction_set_waypoint_paused", self._unit, false)
	end
end

-- Lines 1320-1331
function ReviveInteractionExt:_at_interact_interupt_revive(player)
	if self._unit:base().is_husk_player then
		local revive_rpc_params = {
			"interupt_revive_player"
		}

		self._unit:network():send_to_unit(revive_rpc_params)
	else
		self._unit:character_damage():unpause_bleed_out()
	end

	if player:base().is_local_player then
		managers.achievment:set_script_data("player_reviving", false)
	end
end

-- Lines 1333-1340
function ReviveInteractionExt:_at_interact_interupt_free(player)
	if self._unit:base().is_husk_player then
		local revive_rpc_params = {
			"interupt_free_player"
		}

		self._unit:network():send_to_unit(revive_rpc_params)
	else
		self._unit:character_damage():unpause_arrested_timer()
	end
end

-- Lines 1344-1353
function ReviveInteractionExt:set_waypoint_paused(paused)
	if self._active_wp then
		managers.hud:set_waypoint_timer_pause(self._wp_id, paused)

		if managers.criminals:character_data_by_unit(self._unit) then
			local name_label_id = self._unit:unit_data() and self._unit:unit_data().name_label_id

			managers.hud:pause_teammate_timer(managers.criminals:character_data_by_unit(self._unit).panel_id, name_label_id, paused)
		end
	end
end

-- Lines 1355-1364
function ReviveInteractionExt:get_waypoint_time()
	if self._active_wp then
		local data = managers.hud:get_waypoint_data(self._wp_id)

		if data then
			return data.timer
		end
	end

	return nil
end

local is_win32 = _G.IS_PC

-- Lines 1367-1447
function ReviveInteractionExt:set_active(active, sync, down_time)
	ReviveInteractionExt.super.set_active(self, active)

	local panel_id = nil

	if managers.criminals:character_data_by_unit(self._unit) then
		panel_id = managers.criminals:character_data_by_unit(self._unit).panel_id
	end

	panel_id = panel_id or self._unit:unit_data() and self._unit:unit_data().teammate_panel_id
	local name_label_id = self._unit:unit_data() and self._unit:unit_data().name_label_id

	if self._active then
		local hint = self.tweak_data == "revive" and "hint_teammate_downed" or "teammate_arrested"

		if hint == "hint_teammate_downed" then
			managers.achievment:set_script_data("stand_together_fail", true)
		end

		local location_id = self._unit:movement():get_location_id()
		local location = location_id and " " .. managers.localization:text(location_id) or ""

		managers.notification:add_notification({
			duration = 3,
			shelf_life = 5,
			id = hint,
			text = managers.localization:text(hint, {
				TEAMMATE = self._unit:base():nick_name(),
				LOCATION = location
			})
		})

		if not self._active_wp then
			down_time = down_time or 999
			local text = managers.localization:text(self.tweak_data == "revive" and "debug_team_mate_need_revive" or "debug_team_mate_need_free")
			local icon = self.tweak_data == "revive" and "waypoint_special_downed" or "wp_rescue"
			local timer = self.tweak_data == "revive" and (self._unit:base().is_husk_player and down_time or tweak_data.character[self._unit:base()._tweak_table].damage.DOWNED_TIME) or self._unit:base().is_husk_player and tweak_data.player.damage.ARRESTED_TIME or tweak_data.character[self._unit:base()._tweak_table].damage.ARRESTED_TIME

			managers.hud:add_waypoint(self._wp_id, {
				waypoint_type = "revive",
				text = text,
				icon = icon,
				unit = self._unit,
				distance = is_win32
			})

			self._active_wp = true

			managers.hud:start_teammate_timer(panel_id, name_label_id, timer)
		end

		if self._from_dropin then
			down_time = down_time or 999
			local name = managers.criminals:character_name_by_unit(self._unit)
			local current = managers.hud._teammate_timers[name] and managers.hud._teammate_timers[name].timer_current
			local total = managers.hud._teammate_timers[name] and managers.hud._teammate_timers[name].timer_total

			if current then
				managers.hud:start_teammate_timer(panel_id, name_label_id, total, current)
			end

			self._from_dropin = nil
		end
	elseif self._active_wp then
		managers.hud:remove_waypoint(self._wp_id)

		self._active_wp = false

		managers.hud:stop_teammate_timer(panel_id, name_label_id)
	end
end

-- Lines 1449-1452
function ReviveInteractionExt:unselect()
	ReviveInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 1454-1502
function ReviveInteractionExt:interact(reviving_unit)
	if reviving_unit and reviving_unit == managers.player:player_unit() then
		if not self:can_interact(reviving_unit) then
			return
		end

		if self._tweak_data.equipment_consume then
			managers.player:remove_special(self._tweak_data.special_equipment)
		end

		if self._tweak_data.sound_event then
			reviving_unit:sound():play(self._tweak_data.sound_event)
		end

		ReviveInteractionExt.super.interact(self, reviving_unit)
		managers.achievment:set_script_data("player_reviving", false)
		managers.player:activate_temporary_upgrade("temporary", "combat_medic_damage_multiplier")
		managers.player:activate_temporary_upgrade("temporary", "combat_medic_enter_steelsight_speed_multiplier")
	end

	self:remove_interact()

	if self._unit:damage() then
		if self._unit:damage() and self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact", {
				unit = player
			})
		end

		if self._unit:damage() and self._unit:damage():has_sequence("load") then
			self._unit:damage():run_sequence_simple("load", {
				unit = player
			})
		end
	end

	if self._unit:base().is_husk_player then
		local revive_rpc_params = {
			"revive_player",
			managers.player:upgrade_value("player", "revive_health_boost", 0),
			managers.player:upgrade_value("player", "revive_damage_reduction_level", 0)
		}

		managers.statistics:revived({
			npc = false,
			reviving_unit = reviving_unit
		})
		self._unit:network():send_to_unit(revive_rpc_params)
	else
		self._unit:character_damage():revive(reviving_unit)
		managers.statistics:revived({
			npc = true,
			reviving_unit = reviving_unit
		})
	end

	if reviving_unit:in_slot(managers.slot:get_mask("criminals")) then
		local hint = self.tweak_data == "revive" and 2 or 3

		managers.network:session():send_to_peers_synched("sync_teammate_helped_hint", hint, self._unit, reviving_unit)
		managers.trade:sync_teammate_helped_hint(self._unit, reviving_unit, hint)
	end
end

-- Lines 1504-1510
function ReviveInteractionExt:save(data)
	ReviveInteractionExt.super.save(self, data)

	local state = {
		active_wp = self._active_wp,
		wp_id = self._wp_id
	}
	data.ReviveInteractionExt = state
end

-- Lines 1512-1526
function ReviveInteractionExt:load(data)
	local state = data.ReviveInteractionExt

	if state then
		self._active_wp = state.active_wp
		self._wp_id = state.wp_id
	end

	ReviveInteractionExt.super.load(self, data)

	self._from_dropin = true
end

GageAssignmentInteractionExt = GageAssignmentInteractionExt or class(UseInteractionExt)

-- Lines 1532-1534
function GageAssignmentInteractionExt:init(unit)
	GageAssignmentInteractionExt.super.init(self, unit)
end

-- Lines 1536-1541
function GageAssignmentInteractionExt:_interact_blocked(player)
	if self._unit:base() and self._unit:base().interact_blocked then
		return self._unit:base() and self._unit:base():interact_blocked()
	end

	return GageAssignmentInteractionExt.super._interact_blocked(self, player)
end

-- Lines 1543-1545
function GageAssignmentInteractionExt:can_select(player)
	return GageAssignmentInteractionExt.super.can_select(self, player)
end

-- Lines 1547-1553
function GageAssignmentInteractionExt:interact(player)
	GageAssignmentInteractionExt.super.super.interact(self, player)

	if alive(player) and player:sound() then
		player:sound():say("g92", false, true)
	end

	return self._unit:base():pickup(player)
end

AmmoBagInteractionExt = AmmoBagInteractionExt or class(UseInteractionExt)

-- Lines 1559-1561
function AmmoBagInteractionExt:_interact_blocked(player)
	return not player:inventory():need_ammo()
end

-- Lines 1563-1574
function AmmoBagInteractionExt:interact(player)
	AmmoBagInteractionExt.super.super.interact(self, player)

	local interacted = self._unit:base():take_ammo(player)

	for id, weapon in pairs(player:inventory():available_selections()) do
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end

	return interacted
end

GrenadeCrateInteractionExt = GrenadeCrateInteractionExt or class(UseInteractionExt)

-- Lines 1580-1582
function GrenadeCrateInteractionExt:_interact_blocked(player)
	return managers.player:got_max_grenades()
end

-- Lines 1584-1587
function GrenadeCrateInteractionExt:interact(player)
	GrenadeCrateInteractionExt.super.super.interact(self, player)

	return self._unit:base():take_grenade(player)
end

BodyBagsBagInteractionExt = BodyBagsBagInteractionExt or class(UseInteractionExt)

-- Lines 1593-1595
function BodyBagsBagInteractionExt:_interact_blocked(player)
	return managers.player:has_max_body_bags()
end

-- Lines 1597-1600
function BodyBagsBagInteractionExt:interact(player)
	BodyBagsBagInteractionExt.super.super.interact(self, player)

	return self._unit:base():take_bodybag(player)
end

DoctorBagBaseInteractionExt = DoctorBagBaseInteractionExt or class(UseInteractionExt)

-- Lines 1606-1610
function DoctorBagBaseInteractionExt:_interact_blocked(player)
	local full_health = player:character_damage():full_health()
	local is_berserker = player:character_damage():is_berserker()

	return full_health or is_berserker, false, is_berserker and "hint_health_berserking" or false
end

-- Lines 1612-1616
function DoctorBagBaseInteractionExt:interact(player)
	DoctorBagBaseInteractionExt.super.super.interact(self, player)

	local interacted = self._unit:base():take(player)

	return interacted
end

C4BagInteractionExt = C4BagInteractionExt or class(UseInteractionExt)

-- Lines 1622-1624
function C4BagInteractionExt:_interact_blocked(player)
	return not managers.player:can_pickup_equipment("c4")
end

-- Lines 1626-1630
function C4BagInteractionExt:interact(player)
	C4BagInteractionExt.super.super.interact(self, player)
	managers.player:add_special({
		name = "c4"
	})

	return true
end

MultipleEquipmentBagInteractionExt = MultipleEquipmentBagInteractionExt or class(UseInteractionExt)

-- Lines 1635-1637
function MultipleEquipmentBagInteractionExt:_interact_blocked(player)
	return not managers.player:can_pickup_equipment(self._special_equipment or "c4")
end

-- Lines 1639-1658
function MultipleEquipmentBagInteractionExt:interact(player)
	MultipleEquipmentBagInteractionExt.super.super.interact(self, player)

	local equipment_name = self._special_equipment or "c4"
	local max_player_can_carry = tweak_data.equipments.specials[equipment_name].quantity or 1
	local player_equipment = managers.player:has_special_equipment(equipment_name)
	local amount_wanted = nil

	if player_equipment then
		amount_wanted = max_player_can_carry - Application:digest_value(player_equipment.amount, false)
	else
		amount_wanted = max_player_can_carry
	end

	if Network:is_server() then
		self:sync_interacted(nil, player, amount_wanted)
	else
		managers.network:session():send_to_host("sync_multiple_equipment_bag_interacted", self._unit, amount_wanted)
	end
end

-- Lines 1660-1697
function MultipleEquipmentBagInteractionExt:sync_interacted(peer, player, amount_wanted)
	local instigator = player or peer:unit()

	if Network:is_server() then
		if self._unit:damage() and self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact", {
				unit = player
			})
		end

		if self._unit:damage() and self._unit:damage():has_sequence("load") then
			self._unit:damage():run_sequence_simple("load", {
				unit = player
			})
		end

		if self._global_event then
			managers.mission:call_global_event(self._global_event, instigator)
		end
	end

	local equipment_name = self._special_equipment or "c4"
	local starting_quantity = tweak_data.equipments.specials[equipment_name] and tweak_data.equipments.specials[equipment_name].quantity or 1
	self._current_quantity = self._current_quantity or starting_quantity
	local amount_to_give = math.min(self._current_quantity, amount_wanted)

	if peer then
		managers.network:session():send_to_peer(peer, "give_equipment", equipment_name, amount_to_give, false)
	elseif player then
		managers.player:add_special({
			name = equipment_name,
			amount = amount_to_give
		})
	end

	if self._remove_when_empty then
		self._current_quantity = self._current_quantity - amount_to_give

		if self._current_quantity <= 0 then
			self._unit:set_slot(0)
			managers.network:session():send_to_peers("remove_unit", self._unit)
		end
	end
end

SmallLootInteractionExt = SmallLootInteractionExt or class(UseInteractionExt)

-- Lines 1703-1711
function SmallLootInteractionExt:interact(player)
	if not self._unit:damage() or not self._unit:damage():has_sequence("interact") then
		SmallLootInteractionExt.super.super.interact(self, player)
	else
		SmallLootInteractionExt.super.interact(self, player)
	end

	self._unit:base():take(player)
end

ZipLineInteractionExt = ZipLineInteractionExt or class(UseInteractionExt)

-- Lines 1717-1723
function ZipLineInteractionExt:can_select(player)
	return ZipLineInteractionExt.super.can_select(self, player)
end

-- Lines 1725-1730
function ZipLineInteractionExt:check_interupt()
	if alive(self._unit:zipline():user_unit()) then
		return true
	end

	return ZipLineInteractionExt.super.check_interupt(self)
end

-- Lines 1732-1747
function ZipLineInteractionExt:_interact_blocked(player)
	if self._unit:zipline():is_usage_type_bag() and not managers.player:is_carrying() then
		return true, nil, "zipline_no_bag"
	end

	if player:movement():in_air() then
		return true, nil, nil
	end

	if self._unit:zipline():is_interact_blocked() then
		return true, nil, nil
	end

	return false
end

-- Lines 1749-1753
function ZipLineInteractionExt:interact(player)
	ZipLineInteractionExt.super.super.interact(self, player)
	print("ZipLineInteractionExt:interact")
	self._unit:zipline():on_interacted(player)
end

IntimitateInteractionExt = IntimitateInteractionExt or class(BaseInteractionExt)

-- Lines 1759-1762
function IntimitateInteractionExt:init(unit, ...)
	IntimitateInteractionExt.super.init(self, unit, ...)

	self._nbr_interactions = 0
end

-- Lines 1764-1767
function IntimitateInteractionExt:unselect()
	UseInteractionExt.super.unselect(self)
	managers.hud:remove_interact()
end

-- Lines 1769-1883
function IntimitateInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	local has_equipment = managers.player:has_special_equipment(self._tweak_data.special_equipment)

	if self._tweak_data.equipment_consume and has_equipment then
		managers.player:remove_special(self._tweak_data.special_equipment)
	end

	if self._tweak_data.sound_event then
		player:sound():play(self._tweak_data.sound_event)
	end

	if self._unit:damage() then
		if self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact", {
				unit = player
			})
		end

		if self._unit:damage():has_sequence("load") then
			self._unit:damage():run_sequence_simple("load", {
				unit = player
			})
		end
	end

	if self.tweak_data == "corpse_alarm_pager" then
		if Network:is_server() then
			self._nbr_interactions = 0

			if self._unit:character_damage():dead() then
				local u_id = self._unit:id()

				managers.network:session():send_to_peers_synched("alarm_pager_interaction", u_id, self.tweak_data, 3)
			else
				managers.network:session():send_to_peers_synched("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
			end

			self._unit:brain():on_alarm_pager_interaction("complete", player)

			if alive(managers.interaction:active_unit()) then
				managers.interaction:active_unit():interaction():selected()
			end
		elseif managers.enemy:get_corpse_unit_data_from_key(self._unit:id()) then
			local u_id = self._unit:id()

			managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 3)
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
		end

		self:remove_interact()
	elseif self.tweak_data == "corpse_dispose" then
		local enemy_tweak_data = self._unit:base():char_tweak()
		local carry_name = enemy_tweak_data.carry_tweak_corpse or "person"

		managers.player:set_carry(carry_name, 0)
		managers.player:on_used_body_bag()

		if player == managers.player:player_unit() then
			local carry_tweak = tweak_data.carry[carry_name]
			local carry_type = carry_tweak.type

			if carry_tweak.is_corpse then
				managers.player:set_carry_temporary_data(carry_name, self._unit:character_damage():dismembered_parts())
			end
		end

		local u_id = self._unit:id()

		if Network:is_server() then
			self:remove_interact()
			self:set_active(false, true)
			self._unit:set_slot(0)
			managers.network:session():send_to_peers_synched("remove_corpse_by_id", u_id, true, managers.network:session():local_peer():id())
		else
			managers.network:session():send_to_host("sync_interacted_by_id", u_id, self.tweak_data)
			player:movement():set_carry_restriction(true)
		end
	elseif self._tweak_data.dont_need_equipment and not has_equipment then
		self:set_active(false)
		self._unit:brain():on_tied(player, true)
	elseif self.tweak_data == "hostage_trade" then
		self._unit:brain():on_trade(player)
		managers.statistics:trade({
			name = self._unit:base()._tweak_table
		})
	elseif self.tweak_data == "hostage_convert" then
		if Network:is_server() then
			self:remove_interact()
			self:set_active(false, true)
			managers.groupai:state():convert_hostage_to_criminal(self._unit)
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	elseif self.tweak_data == "hostage_move" then
		if Network:is_server() then
			if self._unit:brain():on_hostage_move_interaction(player, "move") then
				self:remove_interact()
			end
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	elseif self.tweak_data == "hostage_stay" then
		if Network:is_server() then
			if self._unit:brain():on_hostage_move_interaction(player, "stay") then
				self:remove_interact()
			end
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	else
		self:remove_interact()
		self:set_active(false)
		player:sound():play("cable_tie_apply")
		self._unit:brain():on_tied(player)
	end
end

-- Lines 1885-1910
function IntimitateInteractionExt:_at_interact_start(player, timer)
	IntimitateInteractionExt.super._at_interact_start(self)

	if self.tweak_data == "corpse_alarm_pager" then
		if Network:is_server() then
			self._nbr_interactions = self._nbr_interactions + 1
		end

		if self._in_progress then
			return
		end

		self._in_progress = true

		player:sound():say("dsp_radio_checking_1", true, true)

		if Network:is_server() then
			self._unit:brain():on_alarm_pager_interaction("started")
		elseif managers.enemy:get_corpse_unit_data_from_key(self._unit:id()) then
			local u_id = self._unit:id()

			managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 1)
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	end
end

-- Lines 1912-1941
function IntimitateInteractionExt:_at_interact_interupt(player, complete)
	IntimitateInteractionExt.super._at_interact_interupt(self, player, complete)

	if self.tweak_data == "corpse_alarm_pager" then
		if not self._in_progress then
			return
		end

		player:sound():say("dsp_stop_all", false, true)

		if not complete then
			self._unit:base():set_material_state(true)

			if Network:is_server() then
				self._nbr_interactions = self._nbr_interactions - 1

				if self._nbr_interactions == 0 then
					self._in_progress = nil

					self._unit:brain():on_alarm_pager_interaction("interrupted", player)
				end
			else
				self._in_progress = nil

				if managers.enemy:get_corpse_unit_data_from_key(self._unit:id()) then
					local u_id = self._unit:id()

					managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 2)
				else
					managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 2)
				end
			end
		end
	end
end

-- Lines 1943-2049
function IntimitateInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	-- Lines 1944-1953
	local function _get_unit()
		local unit = player

		if not unit then
			unit = peer and peer:unit()

			if not unit then
				print("[IntimitateInteractionExt:sync_interacted] missing unit", inspect(peer))
			end
		end

		return unit
	end

	if self.tweak_data == "corpse_alarm_pager" then
		if Network:is_server() then
			self._interacting_unit_destroy_listener_key = "IntimitateInteractionExt_" .. tostring(self._unit:key())

			if status == 1 then
				status = "started"
			elseif status == 2 then
				status = "interrupted"
			elseif status == 3 then
				status = "complete"
			end

			if status == "started" then
				local husk_unit = _get_unit()

				if husk_unit then
					husk_unit:base():add_destroy_listener(self._interacting_unit_destroy_listener_key, callback(self, self, "on_interacting_unit_destroyed", peer))

					self._interacting_units = self._interacting_units or {}
					self._interacting_units[husk_unit:key()] = husk_unit
				end

				self._nbr_interactions = self._nbr_interactions + 1

				if self._in_progress then
					return
				end

				self._in_progress = true

				self._unit:brain():on_alarm_pager_interaction(status, _get_unit())
			else
				if not self._in_progress then
					return
				end

				local husk_unit = _get_unit()

				if husk_unit then
					husk_unit:base():remove_destroy_listener(self._interacting_unit_destroy_listener_key)

					self._interacting_units[husk_unit:key()] = nil

					if not next(self._interacting_units) then
						self._interacting_units = nil
					end
				end

				if status == "complete" then
					self._nbr_interactions = 0

					if managers.enemy:get_corpse_unit_data_from_key(self._unit:id()) then
						local u_id = self._unit:id()

						managers.network:session():send_to_peers_synched_except(peer:id(), "alarm_pager_interaction", u_id, self.tweak_data, 3)
					else
						managers.network:session():send_to_peers_synched_except(peer:id(), "sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
					end
				else
					self._nbr_interactions = self._nbr_interactions - 1
				end

				if self._nbr_interactions == 0 then
					self._in_progress = nil

					self:remove_interact()
					self._unit:brain():on_alarm_pager_interaction(status, _get_unit())
				end
			end
		end
	elseif self.tweak_data == "corpse_dispose" then
		self:remove_interact()
		self:set_active(false, true)

		local u_id = self._unit:id()

		self._unit:set_slot(0)
		managers.network:session():send_to_peers_synched("remove_corpse_by_id", u_id, true, peer:id())

		if Network:is_server() and peer then
			peer:on_used_body_bags()
			managers.player:set_carry_approved(peer)
		end
	elseif self.tweak_data == "hostage_convert" then
		self:remove_interact()
		self:set_active(false, true)
		managers.groupai:state():convert_hostage_to_criminal(self._unit, _get_unit())
	elseif self.tweak_data == "hostage_move" then
		if Network:is_server() and self._unit:brain():on_hostage_move_interaction(_get_unit(), "move") then
			self:remove_interact()
		end
	elseif self.tweak_data == "hostage_stay" and Network:is_server() and self._unit:brain():on_hostage_move_interaction(_get_unit(), "stay") then
		self:remove_interact()
	end
end

-- Lines 2051-2082
function IntimitateInteractionExt:_interact_blocked(player)
	if self.tweak_data == "corpse_dispose" then
		if managers.player:is_carrying() then
			return true
		end

		local has_upgrade = true

		if not has_upgrade then
			return true
		end

		return not managers.player:can_carry("person")
	elseif self.tweak_data == "hostage_convert" then
		return not managers.player:has_category_upgrade("player", "convert_enemies") or managers.player:chk_minion_limit_reached() or managers.groupai:state():whisper_mode()
	elseif self.tweak_data == "hostage_move" then
		if not self._unit:anim_data().tied then
			return true
		end

		local following_hostages = managers.groupai:state():get_following_hostages(player)

		if following_hostages and tweak_data.player.max_nr_following_hostages <= table.size(following_hostages) then
			return true, nil, "hint_hostage_follow_limit"
		end
	elseif self.tweak_data == "hostage_stay" then
		return not self._unit:anim_data().stand or self._unit:anim_data().to_idle
	end
end

-- Lines 2084-2091
function IntimitateInteractionExt:_is_in_required_state(player)
	if self.tweak_data == "corpse_dispose" and managers.groupai:state():is_police_called() then
		return false
	end

	return IntimitateInteractionExt.super._is_in_required_state(self, player)
end

-- Lines 2093-2095
function IntimitateInteractionExt:on_interacting_unit_destroyed(peer, player)
	self:sync_interacted(peer, player, "interrupted", nil)
end

CarryInteractionExt = CarryInteractionExt or class(UseInteractionExt)

-- Lines 2101-2107
function CarryInteractionExt:_interact_blocked(player)
	local silent_block = managers.player:carry_blocked_by_cooldown() or self._unit:carry_data():is_attached_to_zipline_unit()

	if managers.player:is_carrying() or silent_block then
		return true, silent_block
	end

	return not managers.player:can_carry(self._unit:carry_data():carry_id())
end

-- Lines 2109-2122
function CarryInteractionExt:can_select(player)
	if not self._active then
		return false
	end

	if self.tweak_data == "corpse_dispose" and managers.groupai:state():is_police_called() then
		return false
	end

	if managers.player:carry_blocked_by_cooldown() or self._unit:carry_data():is_attached_to_zipline_unit() then
		return false
	end

	return CarryInteractionExt.super.can_select(self, player), not managers.player:is_carrying()
end

-- Lines 2124-2149
function CarryInteractionExt:interact(player)
	CarryInteractionExt.super.super.interact(self, player)

	if self._has_modified_timer then
		managers.achievment:award("murphys_laws")
	end

	self._unit:carry_data():on_pickup()
	managers.player:set_carry(self._unit:carry_data():carry_id(), self._unit:carry_data():multiplier(), self._unit:carry_data():dye_pack_data())
	managers.network:session():send_to_peers_synched("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
	self:sync_interacted(nil, player)

	if Network:is_client() then
		player:movement():set_carry_restriction(true)
	end

	return true
end

-- Lines 2152-2186
function CarryInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	player = player or peer:unit()

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	if self._unit:damage() and self._unit:damage():has_sequence("load") then
		self._unit:damage():run_sequence_simple("load", {
			unit = player
		})
	end

	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	if Network:is_server() then
		if self._remove_on_interact then
			if self._unit == managers.interaction:active_unit() then
				self:interact_interupt(managers.player:player_unit(), false)
			end

			self:remove_interact()
			self:set_active(false, true)

			if alive(player) then
				self._unit:carry_data():trigger_load(player)
			end

			self._unit:set_slot(0)
		end

		if peer then
			managers.player:set_carry_approved(peer)
		end
	elseif self._remove_on_interact then
		self._unit:set_enabled(false)
	end
end

-- Lines 2188-2196
function CarryInteractionExt:_get_modified_timer()
	local base_timer = CarryInteractionExt.super._get_modified_timer(self) or self:_timer_value()

	if managers.player:has_category_upgrade("carry", "interact_speed_multiplier") then
		return base_timer * managers.player:upgrade_value("carry", "interact_speed_multiplier", 1)
	end

	return nil
end

-- Lines 2198-2209
function CarryInteractionExt:register_collision_callbacks()
	self._unit:set_body_collision_callback(callback(self, self, "_collision_callback"))

	self._has_modified_timer = true
	self._air_start_time = Application:time()

	for i = 0, self._unit:num_bodies() - 1 do
		local body = self._unit:body(i)

		body:set_collision_script_tag(Idstring("throw"))
		body:set_collision_script_filter(1)
		body:set_collision_script_quiet_time(1)
	end
end

-- Lines 2211-2231
function CarryInteractionExt:_collision_callback(tag, unit, body, other_unit, other_body, position, normal, velocity, ...)
	if self._has_modified_timer then
		self._has_modified_timer = nil
	end

	local air_time = Application:time() - self._air_start_time

	self._unit:carry_data():check_explodes_on_impact(velocity, air_time)

	self._air_start_time = Application:time()

	if self._unit:carry_data():can_explode() and not self._unit:carry_data():explode_sequence_started() then
		return
	end

	for i = 0, self._unit:num_bodies() - 1 do
		local body = self._unit:body(i)

		body:set_collision_script_tag(Idstring(""))
	end
end

LootBankInteractionExt = LootBankInteractionExt or class(UseInteractionExt)

-- Lines 2239-2241
function LootBankInteractionExt:_interact_blocked(player)
	return not managers.player:is_carrying()
end

-- Lines 2243-2253
function LootBankInteractionExt:interact(player)
	LootBankInteractionExt.super.super.interact(self, player)

	if Network:is_client() then
		managers.network:session():send_to_host("sync_interacted", self._unit, -2, self.tweak_data, 1)
	else
		self:sync_interacted(nil, player)
	end

	managers.player:bank_carry()

	return true
end

-- Lines 2255-2260
function LootBankInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	local player = player or peer:unit()

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end
end

UseCarryInteractionExt = UseCarryInteractionExt or class(UseInteractionExt)

-- Lines 2266-2282
function UseCarryInteractionExt:_interact_blocked(player)
	local plr_carry = managers.player:current_carry_id()

	if plr_carry then
		local correct_carry = false
		correct_carry = (type(self._tweak_data.required_carry) ~= "table" or table.has(self._tweak_data.required_carry, plr_carry)) and self._tweak_data.required_carry == plr_carry
		local carry_warning = not correct_carry and (self._tweak_data.required_carry_text or "wrong_carry_item") or nil

		return correct_carry, nil, carry_warning
	end

	return true, nil, self._tweak_data.required_carry_text
end

-- Lines 2284-2298
function UseCarryInteractionExt:interact(player)
	UseCarryInteractionExt.super.super.interact(self, player)

	if Network:is_client() then
		managers.network:session():send_to_host("sync_interacted", self._unit, -2, self.tweak_data, 1)
	else
		self:sync_interacted(nil, player)
	end

	if self._tweak_data.carry_consume then
		managers.player:remove_carry()
	end

	return true
end

-- Lines 2300-2305
function UseCarryInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	local player = player or peer:unit()

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end
end

EventIDInteractionExt = EventIDInteractionExt or class(UseInteractionExt)

-- Lines 2311-2316
function EventIDInteractionExt:show_blocked_hint(player, skip_hint)
	local unit_base = alive(self._unit) and self._unit:base()

	if unit_base and unit_base.show_blocked_hint then
		unit_base:show_blocked_hint(self._tweak_data, player, skip_hint)
	end
end

-- Lines 2318-2324
function EventIDInteractionExt:_interact_blocked(player)
	local unit_base = alive(self._unit) and self._unit:base()

	if unit_base and unit_base.check_interact_blocked then
		return unit_base:check_interact_blocked(player)
	end

	return false
end

-- Lines 2326-2360
function EventIDInteractionExt:interact_start(player)
	local blocked, skip_hint = self:_interact_blocked(player)

	if blocked then
		self:show_blocked_hint(player, skip_hint)

		return false
	end

	local has_equipment = not self._tweak_data.special_equipment and true or managers.player:has_special_equipment(self._tweak_data.special_equipment)
	local sound = has_equipment and (self._tweak_data.say_waiting or "") or self.say_waiting

	if sound and sound ~= "" then
		local delay = (self._tweak_data.timer or 0) * managers.player:toolset_value()
		delay = delay / 3 + math.random() * delay / 3
		local say_t = Application:time() + delay
		self._interact_say_clbk = "interact_say_waiting"

		managers.enemy:add_delayed_clbk(self._interact_say_clbk, callback(self, self, "_interact_say", {
			player,
			sound
		}), say_t)
	end

	if self._tweak_data.timer then
		if not self:can_interact(player) then
			self:show_blocked_hint(player)

			return false
		end

		local timer = self:_get_timer()

		if timer ~= 0 then
			self:_post_event(player, "sound_start")
			self:_at_interact_start(player, timer)

			return false, timer
		end
	end

	return self:interact(player)
end

-- Lines 2363-2368
function EventIDInteractionExt:_add_string_macros(macros)
	EventIDInteractionExt.super._add_string_macros(self, macros)

	if alive(self._unit) and self._unit:base() and self._unit:base().add_string_macros then
		self._unit:base():add_string_macros(macros)
	end
end

-- Lines 2370-2380
function EventIDInteractionExt:interact(player)
	if not self:can_interact(player) then
		return false
	end

	local event_id = alive(self._unit) and self._unit:base() and self._unit:base().get_net_event_id and self._unit:base():get_net_event_id(player) or 1

	if event_id then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "interaction", event_id)
		self:sync_net_event(event_id, managers.network:session():local_peer())
	end
end

-- Lines 2382-2387
function EventIDInteractionExt:can_interact(player)
	if not EventIDInteractionExt.super.can_interact(self, player) then
		return false
	end

	return alive(self._unit) and self._unit:base() and self._unit:base().can_interact and self._unit:base():can_interact(player)
end

-- Lines 2389-2396
function EventIDInteractionExt:selected(player)
	local result = EventIDInteractionExt.super.selected(self, player)

	if result and self._unit:base().contour_selected then
		self._unit:base():contour_selected()
	end

	return result
end

-- Lines 2398-2404
function EventIDInteractionExt:unselect()
	EventIDInteractionExt.super.unselect(self)

	if self._unit:base().contour_unselected then
		self._unit:base():contour_unselected()
	end
end

-- Lines 2406-2411
function EventIDInteractionExt:sync_net_event(event_id, peer)
	local unit_base = alive(self._unit) and self._unit:base()

	if unit_base and unit_base.sync_net_event then
		unit_base:sync_net_event(event_id, peer)
	end
end

SpecialEquipmentInteractionExt = SpecialEquipmentInteractionExt or class(UseInteractionExt)

-- Lines 2417-2420
function SpecialEquipmentInteractionExt:_interact_blocked(player)
	local can_pickup, has_max_quantity = managers.player:can_pickup_equipment(self._special_equipment)

	return not can_pickup, false, has_max_quantity and "max_special_equipment" or nil
end

-- Lines 2422-2438
function SpecialEquipmentInteractionExt:interact(player)
	SpecialEquipmentInteractionExt.super.super.interact(self, player)
	managers.player:add_special({
		name = self._special_equipment
	})

	if self._remove_on_interact then
		self:remove_interact()
		self:set_active(false)
	end

	if Network:is_client() then
		managers.network:session():send_to_host("sync_interacted", self._unit, -2, self.tweak_data, 1)
	else
		self:sync_interacted(nil, player)
	end

	return true
end

-- Lines 2440-2450
function SpecialEquipmentInteractionExt:selected(player)
	if self._special_equipment and managers.player:has_special_equipment(self._special_equipment) then
		return true
	end

	return SpecialEquipmentInteractionExt.super.selected(self, player)
end

-- Lines 2452-2470
function SpecialEquipmentInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	player = player or peer:unit()

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	if self._unit:damage() and self._unit:damage():has_sequence("load") then
		self._unit:damage():run_sequence_simple("load", {
			unit = player
		})
	end

	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	if self._remove_on_interact then
		self._unit:set_slot(0)
	end
end

AccessCameraInteractionExt = AccessCameraInteractionExt or class(UseInteractionExt)

-- Lines 2476-2478
function AccessCameraInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 2480-2486
function AccessCameraInteractionExt:interact(player)
	AccessCameraInteractionExt.super.super.interact(self, player)
	game_state_machine:change_state_by_name("ingame_access_camera")

	return true
end

MissionElementInteractionExt = MissionElementInteractionExt or class(UseInteractionExt)

-- Lines 2492-2494
function MissionElementInteractionExt:set_mission_element(mission_element)
	self._mission_element = mission_element
end

-- Lines 2496-2501
function MissionElementInteractionExt:_timer_value(...)
	if self._override_timer_value then
		return self._override_timer_value
	end

	return MissionElementInteractionExt.super._timer_value(self, ...)
end

-- Lines 2503-2505
function MissionElementInteractionExt:set_override_timer_value(override_timer_value)
	self._override_timer_value = override_timer_value
end

-- Lines 2507-2518
function MissionElementInteractionExt:sync_net_event(event_id, peer)
	local player = peer:unit()

	if event_id == BaseInteractionExt.EVENT_IDS.at_interact_start then
		if Network:is_server() then
			self._mission_element:on_interact_start(player)
		end
	elseif event_id == BaseInteractionExt.EVENT_IDS.at_interact_interupt and Network:is_server() then
		self._mission_element:on_interact_interupt(player)
	end
end

-- Lines 2520-2527
function MissionElementInteractionExt:_at_interact_start(player, ...)
	MissionElementInteractionExt.super._at_interact_start(self, player, ...)

	if Network:is_server() then
		self._mission_element:on_interact_start(player)
	else
		managers.network:session():send_to_host("sync_unit_event_id_16", self._unit, "interaction", BaseInteractionExt.EVENT_IDS.at_interact_start)
	end
end

-- Lines 2529-2538
function MissionElementInteractionExt:_at_interact_interupt(player, complete)
	MissionElementInteractionExt.super._at_interact_interupt(self, player, complete)

	if not complete then
		if Network:is_server() then
			self._mission_element:on_interact_interupt(player)
		else
			managers.network:session():send_to_host("sync_unit_event_id_16", self._unit, "interaction", BaseInteractionExt.EVENT_IDS.at_interact_interupt)
		end
	end
end

-- Lines 2540-2548
function MissionElementInteractionExt:interact(player, ...)
	MissionElementInteractionExt.super.interact(self, player, ...)

	if Network:is_server() then
		self._mission_element:on_interacted(player)
	end

	return true
end

-- Lines 2550-2558
function MissionElementInteractionExt:sync_interacted(peer, player, ...)
	player = MissionElementInteractionExt.super.sync_interacted(self, peer, player, ...)

	if Network:is_server() and alive(player) then
		self._mission_element:on_interacted(player)
	end
end

-- Lines 2560-2566
function MissionElementInteractionExt:save(data)
	MissionElementInteractionExt.super.save(self, data)

	local state = {
		tweak_data = self.tweak_data,
		override_timer_value = self._override_timer_value
	}
	data.MissionElementInteractionExt = state
end

-- Lines 2568-2573
function MissionElementInteractionExt:load(data)
	local state = data.MissionElementInteractionExt
	self._override_timer_value = state.override_timer_value

	MissionElementInteractionExt.super.load(self, data)
	self:set_tweak_data(state.tweak_data)
end

DrivingInteractionExt = DrivingInteractionExt or class(UseInteractionExt)

-- Lines 2578-2580
function DrivingInteractionExt:init(unit)
	self.super.init(self, unit)
end

-- Lines 2582-2587
function DrivingInteractionExt:_timer_value(...)
	if self._override_timer_value then
		return self._override_timer_value
	end

	return MissionElementInteractionExt.super._timer_value(self, ...)
end

-- Lines 2589-2591
function DrivingInteractionExt:set_override_timer_value(override_timer_value)
	self._override_timer_value = override_timer_value
end

-- Lines 2593-2628
function DrivingInteractionExt:interact(player, locator)
	if locator == nil then
		return false
	end

	DrivingInteractionExt.super.super.interact(self, player)

	local vehicle_ext = self._unit:vehicle_driving()
	local success = false
	local action = vehicle_ext:get_action_for_interaction(player:position(), locator)

	Application:debug("[DrivingInteractionExt:interact] action ", action)

	if action == VehicleDrivingExt.INTERACT_ENTER or action == VehicleDrivingExt.INTERACT_DRIVE then
		success = managers.player:enter_vehicle(self._unit, locator)
	elseif action == VehicleDrivingExt.INTERACT_LOOT then
		success = vehicle_ext:give_vehicle_loot_to_player(managers.network:session():local_peer():id())
	elseif action == VehicleDrivingExt.INTERACT_REPAIR then
		vehicle_ext:repair_vehicle()
		managers.interaction:deactivate_unit()
	elseif action == VehicleDrivingExt.INTERACT_TRUNK then
		vehicle_ext:interact_trunk()
	end

	return success
end

-- Lines 2630-2633
function DrivingInteractionExt:_add_string_macros(macros)
	DrivingInteractionExt.super._add_string_macros(self, macros)

	macros.LOOT = self._loot_text
end

-- Lines 2635-2685
function DrivingInteractionExt:selected(player, locator)
	if locator == nil then
		return false
	end

	if locator then
		Application:debug("[DrivingInteractionExt:selected] locator: ", locator:name())
	end

	if not alive(player) or not self:can_select(player, locator) then
		return
	end

	local vehicle_ext = self._unit:vehicle_driving()
	local action = vehicle_ext:get_action_for_interaction(player:position(), locator)

	if action == VehicleDrivingExt.INTERACT_ENTER then
		self._tweak_data.text_id = "hud_int_vehicle_enter"
	elseif action == VehicleDrivingExt.INTERACT_DRIVE then
		self._tweak_data.text_id = "hud_int_vehicle_drive"
	elseif action == VehicleDrivingExt.INTERACT_LOOT and vehicle_ext:has_loot_stored() then
		self._tweak_data.text_id = "hud_int_vehicle_loot"
		local loot_data = vehicle_ext:get_loot() and vehicle_ext:get_loot()[vehicle_ext:get_current_loot_amount()]

		if loot_data then
			local carry_data = tweak_data.carry[loot_data.carry_id]

			if carry_data and carry_data.carry_item_id then
				self._tweak_data.text_id = "hud_int_vehicle_custom_loot"
				self._loot_text = managers.localization:text(carry_data.carry_item_id)
			end
		end
	elseif action == VehicleDrivingExt.INTERACT_REPAIR then
		self._tweak_data.text_id = "hud_int_vehicle_repair"
	elseif action == VehicleDrivingExt.INTERACT_TRUNK then
		if vehicle_ext._trunk_open then
			self._tweak_data.text_id = "hud_int_vehicle_close_trunk"
		else
			self._tweak_data.text_id = "hud_int_vehicle_open_trunk"
		end
	else
		self._tweak_data.text_id = nil

		return false
	end

	self._action = action
	local res = DrivingInteractionExt.super.selected(self, player)

	return res
end

-- Lines 2687-2707
function DrivingInteractionExt:can_select(player, locator)
	if locator == nil then
		return true
	end

	local can_select = DrivingInteractionExt.super.can_select(self, player)

	if can_select then
		local vehicle_ext = self._unit:vehicle_driving()
		local action = vehicle_ext:get_action_for_interaction(player:position(), locator)
		can_select = vehicle_ext:is_interaction_enabled(action)

		if managers.player:is_carrying() and action == VehicleDrivingExt.INTERACT_LOOT then
			can_select = false
		end
	end

	return can_select
end

-- Lines 2709-2736
function DrivingInteractionExt:can_interact(player)
	local can_interact = DrivingInteractionExt.super.can_interact(self, player)

	if can_interact and managers.player:is_berserker() then
		can_interact = false

		managers.notification:add_notification({
			duration = 2,
			shelf_life = 5,
			id = "hud_vehicle_no_enter_berserker",
			text = managers.localization:text("hud_vehicle_no_enter_berserker")
		})
	elseif can_interact and managers.player:is_carrying() then
		if self._action == VehicleDrivingExt.INTERACT_ENTER or self._action == VehicleDrivingExt.INTERACT_DRIVE then
			can_interact = false

			managers.notification:add_notification({
				duration = 3,
				shelf_life = 5,
				id = "hud_vehicle_no_enter_carry",
				text = managers.localization:text("hud_vehicle_no_enter_carry")
			})
		elseif self._action == VehicleDrivingExt.INTERACT_LOOT then
			can_interact = false
		end
	end

	return can_interact
end

-- Lines 2738-2762
function DrivingInteractionExt:_post_event(player, sound_type, tweak_data_id)
	if not alive(player) then
		return
	end

	if player ~= managers.player:player_unit() then
		return
	end

	local vehicle_ext = self._unit:vehicle_driving()

	if self._vehicle_action == VehicleDrivingExt.INTERACT_REPAIR then
		if sound_type == "sound_interupt" then
			local sound = vehicle_ext._tweak_data.sound.fix_engine_stop

			if sound then
				player:sound():play(sound)
			end
		elseif sound_type == "sound_start" then
			local sound = vehicle_ext._tweak_data.sound.fix_engine_loop

			if sound then
				player:sound():play(sound)
			end
		end
	end
end

-- Lines 2764-2780
function DrivingInteractionExt:_set_active_contour_opacity()
	if self._unit:vehicle_driving() then
		if self._unit:vehicle_driving():get_state_name() == VehicleDrivingExt.STATE_BROKEN then
			return 1
		else
			return 0
		end
	else
		return 1
	end
end

-- Lines 2782-2785
function DrivingInteractionExt:interact_distance()
	local vehicle_ext = self._unit:vehicle_driving()

	return vehicle_ext._tweak_data.interact_distance or tweak_data.interaction.INTERACT_DISTANCE
end

-- Lines 2787-2795
function DrivingInteractionExt:_setup_ray_objects()
	if self._ray_object_names then
		self._ray_objects = {}

		for _, object_name in ipairs(self._ray_object_names) do
			table.insert(self._ray_objects, self._unit:get_object(Idstring(object_name)))
		end
	end
end

core:import("CoreMenuNode")

MainMenuInteractionExt = MainMenuInteractionExt or class(UseInteractionExt)

-- Lines 2801-2808
function MainMenuInteractionExt:init(unit)
	MainMenuInteractionExt.super.init(self, unit)

	if self._menu_item == "comic_book_menu" and not managers.dlc:is_dlc_unlocked(DLCTweakData.DLC_NAME_SPECIAL_EDITION) then
		self._unit:set_slot(0)
	end
end

-- Lines 2810-2819
function MainMenuInteractionExt:can_select(player, locator)
	if self._menu_item == "comic_book_menu" then
		return managers.dlc:is_dlc_unlocked(DLCTweakData.DLC_NAME_SPECIAL_EDITION)
	end

	return true
end

-- Lines 2821-2854
function MainMenuInteractionExt:interact(player)
	MainMenuInteractionExt.super.super.interact(self, player)

	local success = false
	local is_offline = Global.game_settings.single_player

	if self._menu_item == "mission_join_menu" and is_offline then
		return false
	elseif self._menu_item == "challenge_cards_view_menu" and is_offline then
		return false
	end

	if self._menu_item == "mission_selection_menu" then
		if managers.progression:have_pending_missions_to_unlock() then
			success = managers.raid_menu:open_menu("mission_unlock_menu")
		else
			success = managers.raid_menu:open_menu(self._menu_item)
		end
	else
		success = managers.raid_menu:open_menu(self._menu_item)
	end

	if success then
		-- Nothing
	end

	return success
end

-- Lines 2856-2898
function MainMenuInteractionExt:selected(player)
	if self._menu_item == "raid_menu_weapon_select" then
		self._tweak_data.text_id = "hud_menu_interaction_select_weapon_select"
	elseif self._menu_item == "challenge_cards_view_menu" then
		if Global.game_settings.single_player then
			self._tweak_data.text_id = "hud_menu_interaction_challenge_cards_offline"
		else
			self._tweak_data.text_id = "hud_menu_interaction_challenge_card_view"
		end
	elseif self._menu_item == "mission_selection_menu" then
		if managers.progression:have_pending_missions_to_unlock() then
			self._tweak_data.text_id = "hud_menu_interaction_unlock_missions"
		elseif Network:is_server() then
			self._tweak_data.text_id = "hud_menu_interaction_select_missions"
		else
			self._tweak_data.text_id = "hud_menu_interaction_view_missions"
		end
	elseif self._menu_item == "mission_join_menu" then
		if Global.game_settings.single_player then
			self._tweak_data.text_id = "hud_menu_interaction_select_mission_join_offline"
		else
			self._tweak_data.text_id = "hud_menu_interaction_select_mission_join"
		end
	elseif self._menu_item == "profile_selection_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_profiles"
	elseif self._menu_item == "profile_creation_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_profiles_creation"
	elseif self._menu_item == "raid_main_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_main_menu"
	elseif self._menu_item == "raid_menu_xp" then
		self._tweak_data.text_id = "hud_menu_interaction_select_skills_menu"
	elseif self._menu_item == "gold_asset_store_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_gold_asset_store_menu"
	elseif self._menu_item == "intel_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_intel_menu"
	elseif self._menu_item == "comic_book_menu" then
		self._tweak_data.text_id = "hud_menu_interaction_select_comic_book_menu"
	end

	local res = MainMenuInteractionExt.super.selected(self, player)

	return res
end

SpotterFlareInteractionExt = SpotterFlareInteractionExt or class(UseInteractionExt)

-- Lines 2904-2911
function SpotterFlareInteractionExt:interact(player)
	SpotterFlareInteractionExt.super.interact(self, player)

	local pos = managers.player:local_player():position()

	managers.dialog:queue_dialog("player_flare_extinguished", {
		skip_idle_check = true,
		instigator = managers.player:local_player(),
		position = pos
	})
end

GreedItemInteractionExt = GreedItemInteractionExt or class(UseInteractionExt)

-- Lines 2918-2938
function GreedItemInteractionExt:interact(player)
	Application:debug("[GreedItemInteractionExt:interact] Player picked up a greed item.")
	GreedItemInteractionExt.super.interact(self, player)

	local value = self._unit:greed():value()
	local value_line = self._unit:greed():value_line_id()

	managers.dialog:queue_dialog("player_gen_loot_" .. value_line, {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})
	managers.greed:pickup_greed_item(value, self._unit)
	managers.network:session():send_to_peers("greed_item_picked_up", self._unit, value)
end

-- Lines 2941-2943
function GreedItemInteractionExt:on_peer_interacted(amount)
	managers.greed:pickup_greed_item(amount, self._unit)
end

-- Lines 2945-2947
function GreedItemInteractionExt:can_select()
	return true
end

GreedCacheItemInteractionExt = GreedCacheItemInteractionExt or class(BaseInteractionExt)

-- Lines 2954-2956
function GreedCacheItemInteractionExt:init(unit)
	GreedCacheItemInteractionExt.super.init(self, unit)
end

-- Lines 2959-2984
function GreedCacheItemInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	if self._unit:greed():locked() then
		local params = self._unit:greed():get_lockpick_parameters()
		params.target_unit = self._unit
		params.number_of_circles = math.max(params.number_of_circles - managers.player:upgrade_value("interaction", "wheel_amount_decrease", 0), 1)
		local count = params.number_of_circles

		for i = 1, count do
			params.circle_difficulty[i] = params.circle_difficulty[i] * managers.player:upgrade_value("interaction", "wheel_hotspot_increase", 1)
			params.circle_rotation_speed[i] = params.circle_rotation_speed[i] * managers.player:upgrade_value("interaction", "wheel_rotation_speed_increase", 1)
		end

		game_state_machine:change_state_by_name("ingame_special_interaction", params)
	else
		GreedCacheItemInteractionExt.super.interact(self, player)

		local value = self._unit:greed():on_interacted()

		managers.greed:pickup_cache_loot(value)
		managers.network:session():send_to_peers("greed_cache_item_interacted_with", self._unit, value)
	end

	return true
end

-- Lines 2987-2990
function GreedCacheItemInteractionExt:on_peer_interacted(amount)
	local amount_picked_up = self._unit:greed():on_interacted(amount)

	managers.greed:pickup_cache_loot(amount_picked_up)
end

-- Lines 2993-2998
function GreedCacheItemInteractionExt:special_interaction_done()
	self._unit:greed():unlock()
	self:set_dirty(true)
	managers.network:session():send_to_peers("special_interaction_done", self._unit)
end

-- Lines 3001-3004
function GreedCacheItemInteractionExt:set_special_interaction_done()
	self._unit:greed():unlock()
	self:set_dirty(true)
end

-- Lines 3007-3009
function GreedCacheItemInteractionExt:can_select()
	return self._unit:greed():reserve_left() > 0
end

-- Lines 3011-3013
function GreedCacheItemInteractionExt:unselect()
	UseInteractionExt.unselect(self)
end

-- Lines 3016-3022
function GreedCacheItemInteractionExt:_show_interaction_text()
	if self._unit:greed():locked() then
		GreedCacheItemInteractionExt.super._show_interaction_text(self, "hud_greed_cache_locked_prompt")
	else
		GreedCacheItemInteractionExt.super._show_interaction_text(self, "hud_greed_cache_unlocked_prompt")
	end
end

-- Lines 3025-3031
function GreedCacheItemInteractionExt:_timer_value()
	if self._unit:greed():locked() then
		return 0
	else
		return self._unit:greed():interaction_timer_value()
	end
end

ConsumableMissionInteractionExt = ConsumableMissionInteractionExt or class(UseInteractionExt)

-- Lines 3038-3058
function ConsumableMissionInteractionExt:interact(player)
	Application:debug("[ConsumableMissionInteractionExt:interact] called : called consumable mission interaction!")
	ConsumableMissionInteractionExt.super.interact(self, player)

	local chosen_consumable = tweak_data.operations:get_random_unowned_consumable_raid()

	managers.consumable_missions:pickup_mission(chosen_consumable)

	local notification_data = {
		id = "hud_hint_consumable_mission",
		duration = 4,
		priority = 3,
		notification_type = HUDNotification.CONSUMABLE_MISSION_PICKED_UP
	}

	managers.notification:add_notification(notification_data)
end

-- Lines 3061-3069
function ConsumableMissionInteractionExt:can_interact(player)
	if managers.consumable_missions:is_all_missions_unlocked() then
		return false
	end

	return ConsumableMissionInteractionExt.super.can_interact(self, player)
end

-- Lines 3071-3074
function ConsumableMissionInteractionExt:on_load_complete()
	local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:unit_data().unit_id):world_id()

	managers.consumable_missions:register_document(self._unit, world_id)
end

FoxholeInteractionExt = FoxholeInteractionExt or class(UseInteractionExt)

-- Lines 3080-3096
function FoxholeInteractionExt:interact(player)
	FoxholeInteractionExt.super.interact(self, player)

	if not self._unit:foxhole() then
		Application:error("[FoxholeInteractionExt:interact] Foxhole interaction unit missing foxhole extension!")

		return
	end

	if not alive(player) then
		Application:error("[FoxholeInteractionExt:interact] Invalid player unit")

		return
	end

	self._unit:foxhole():register_player(player)
	player:movement():set_foxhole_unit(self._unit)
	managers.player:set_player_state("foxhole")
end

ResupplyFullInteractionExt = ResupplyFullInteractionExt or class(UseInteractionExt)

-- Lines 3102-3111
function ResupplyFullInteractionExt:_interact_blocked(player)
	if not player:inventory():need_ammo() and managers.player:got_max_grenades() and player:character_damage():full_health() then
		return true
	end

	return false
end

-- Lines 3113-3116
function ResupplyFullInteractionExt:interact(player)
	ResupplyFullInteractionExt.super.super.interact(self, player)
	managers.player:replenish_player_weapons()
end

DummyInteractionExt = DummyInteractionExt or class(BaseInteractionExt)

-- Lines 3122-3124
function DummyInteractionExt:interact_start()
	return false
end

-- Lines 3126-3128
function DummyInteractionExt:can_select()
	return false
end

-- Lines 3130-3132
function DummyInteractionExt:can_interact()
	return false
end
