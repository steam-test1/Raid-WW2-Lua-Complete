WarcryManager = WarcryManager or class()

require("lib/managers/warcries/Warcry")

WarcryManager.WARCRY_READY_MESSAGE_DURATION = 4
WarcryManager.WARCRY_BLOCKED_MESSAGE_DURATION = 3
WarcryManager.WARCRY_BLOCKED_TEXT = "hud_warcry_blocked"
WarcryManager.WARCRY_BLOCKED_AIR_TEXT = "hud_warcry_blocked_in_air"
local IDS_WARCRY = Idstring("warcry")

function WarcryManager.get_instance()
	if not Global.warcry_manager then
		Global.warcry_manager = WarcryManager:new()
	end

	setmetatable(Global.warcry_manager, WarcryManager)
	Global.warcry_manager:_setup()

	return Global.warcry_manager
end

function WarcryManager:init()
	self._meter_value = 0
	self._meter_max_value = 1
	self._interrupt_penalty_reduction = 0
	self._warcries = {}
	self._active_warcry = nil
end

function WarcryManager:_setup()
	self:reset()

	if self._active_warcry then
		Application:debug("[WarcryManager:_setup] Warcry", self._active_warcry:get_type(), "LV", self._active_warcry:get_level())
		self:set_active_warcry({
			name = self._active_warcry:get_type(),
			level = self._active_warcry:get_level()
		})
	end
end

function WarcryManager:set_warcry_post_effect(ids_effect)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", IDS_WARCRY, ids_effect)
	end
end

function WarcryManager:warcry_post_material()
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local warcry_pp = vp:vp():get_post_processor_effect("World", IDS_WARCRY)

		if warcry_pp then
			local warcry_mod = warcry_pp:modifier(IDS_WARCRY)

			if warcry_mod then
				return warcry_mod:material()
			end
		end
	end
end

function WarcryManager:acquire_warcry(warcry_name)
	Application:debug("[WarcryManager:acquire_warcry] WARCRY NAME", warcry_name)

	if self:warcry_acquired(warcry_name) then
		return
	end

	if self._active_warcry then
		self:deactivate_warcry(true)
	end

	local warcry = {
		level = 1,
		name = warcry_name
	}

	table.insert(self._warcries, warcry)
	self:set_active_warcry(warcry)
end

function WarcryManager:set_active_warcry(warcry)
	if not warcry or not warcry.name then
		debug_pause("[WarcryManager:set_active_warcry] tried to activate a warcry that doesn't exist", warcry)
	end

	Application:debug("[WarcryManager:set_active_warcry] Activating warcry", inspect(warcry))

	if self._active_warcry then
		self:deactivate_warcry(true)
		self._active_warcry:cleanup()

		self._active_warcry = nil
		self._meter_full = nil

		if managers.hud then
			managers.hud:deactivate_player_warcry()
		end
	end

	self._active_warcry = Warcry.create(warcry.name)

	self._active_warcry:set_level(warcry.level)

	self._active_warcry_name = warcry.name

	self:setup_upgrades()

	if managers.hud then
		managers.hud:set_player_active_warcry(warcry.name)
	end
end

function WarcryManager:get_active_warcry()
	return self._active_warcry
end

function WarcryManager:get_active_warcry_name()
	return self._active_warcry_name
end

function WarcryManager:increase_warcry_level(warcry_name, amount)
	local increase_amount = amount or 1

	if not warcry_name and self._active_warcry then
		warcry_name = self._active_warcry:get_type()
	elseif not warcry_name and not self._active_warcry then
		return
	end

	if self._active_warcry and warcry_name == self._active_warcry:get_type() then
		local current_level = self._active_warcry:get_level()

		self._active_warcry:set_level(current_level + increase_amount)
	end

	for i = 1, #self._warcries do
		if self._warcries[i].name == warcry_name then
			self._warcries[i].level = self._warcries[i].level + increase_amount
		end
	end
end

function WarcryManager:warcry_acquired(warcry_name)
	for i = 1, #self._warcries do
		if self._warcries[i].name == warcry_name then
			return true
		end
	end

	return false
end

function WarcryManager:activate_peer_warcry(peer_id, warcry_type, level)
	self._peer_warcries[peer_id] = {
		type = warcry_type,
		level = level
	}
end

function WarcryManager:deactivate_peer_warcry(peer_id)
	self._peer_warcries[peer_id] = nil
end

function WarcryManager:activate_warcry()
	if not self._active_warcry then
		return
	end

	local can_activate, blocked_text_id = self._active_warcry:can_activate()

	if not can_activate then
		blocked_text_id = blocked_text_id or self.WARCRY_BLOCKED_TEXT
		local notification_data = {
			sound_effect = "generic_fail_sound",
			shelf_life = 5,
			id = self.WARCRY_BLOCKED_TEXT,
			text = managers.localization:text(blocked_text_id),
			duration = self.WARCRY_BLOCKED_MESSAGE_DURATION
		}

		managers.notification:add_notification(notification_data)

		return
	end

	managers.hud:hide_big_prompt("warcry_ready")
	self._active_warcry:activate()

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES) then
		managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES, managers.network:session():local_peer():id())
	end

	self._duration = self._active_warcry:duration() * self:duration_multiplier()
	self._remaining = self._duration * self._meter_value
	self._active = true
	local warcry_type = self._active_warcry:get_type()
	local warcry_level = self._active_warcry:get_level()
	local sound_switch = self._active_warcry:get_sound_switch()

	managers.network:session():send_to_peers_synched("sync_activate_warcry", warcry_type, warcry_level, self._duration)

	if sound_switch then
		managers.hud:set_sound_switch("warcry_switch", sound_switch)
		managers.hud:post_event("warcry_active")
	end

	managers.dialog:queue_dialog(self._active_warcry:get_activation_callout(), {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

	if Network:is_server() then
		self:activate_peer_warcry(managers.network:session():local_peer():id(), warcry_type, warcry_level)
	end
end

function WarcryManager:deactivate_warcry(force_reset)
	if not self._active_warcry then
		return
	end

	local value = self._meter_value
	local threshold = self._active_warcry.activation_threshold and self._active_warcry:activation_threshold()

	if threshold and not force_reset then
		local penalty_percentage, penalty_multiplier = self._active_warcry:interrupt_penalty()
		value = self._meter_value * (penalty_multiplier or 0)
		value = value + (penalty_percentage or 0)
		value = value * (1 - self._interrupt_penalty_reduction)

		if threshold < self._meter_value - value then
			value = self._meter_value - threshold
		end
	end

	self:_fill_meter_by_value(-value, true)

	self._meter_full = false

	if not self._active then
		return
	end

	self:_deactivate_warcry()
end

function WarcryManager:fill_meter_by_value(value, sync)
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_WARCRIES_DISABLED) then
		return
	end

	if self._active then
		return
	end

	self:_fill_meter_by_value(value, sync)
end

function WarcryManager:downed()
	local multiplier = tweak_data.player.damage.DOWNED_WARCRY_REDUCTION
	multiplier = multiplier - self._interrupt_penalty_reduction
	local reduction = self._meter_value * multiplier

	self:_fill_meter_by_value(-reduction, true)

	self._meter_full = false
	self._is_perseverating = false

	if managers.hud then
		managers.hud:deactivate_player_warcry()
	end

	if not self._active then
		return
	end

	self:_deactivate_warcry()
end

function WarcryManager:on_enter_perseverance()
	self._is_perseverating = true
	self._meter_full = false

	self:_deactivate_warcry()
end

function WarcryManager:_fill_meter_by_value(value, sync)
	if not self._active_warcry then
		return
	end

	self._meter_value = math.max(self._meter_value + value, 0)
	local threshold = self._active_warcry.activation_threshold and self._active_warcry:activation_threshold() or self._meter_max_value

	if threshold <= self._meter_value then
		self._meter_value = math.min(self._meter_value, self._meter_max_value)

		if not self._meter_full and not self._is_perseverating then
			self:_on_meter_full()
		end
	end

	if managers.hud then
		managers.hud:set_player_warcry_meter_fill({
			current = self._meter_value,
			total = self._meter_max_value
		})

		if sync and managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_warcry_meter_fill_percentage", self._meter_value / self._meter_max_value * 100)
		end
	end
end

function WarcryManager:add_warcry_comm_wheel_option(index)
	local warcry_comm_wheel_option = {
		text_id = "com_wheel_warcry",
		id = "warcry",
		icon = tweak_data.warcry[self._active_warcry:get_type()].hud_icon,
		color = Color.white,
		clbk = callback(self, self, "activate_warcry")
	}

	managers.hud:add_comm_wheel_option(warcry_comm_wheel_option, index)
end

function WarcryManager:current_meter_percentage()
	return self._meter_value / self._meter_max_value * 100
end

function WarcryManager:_on_meter_full(skip_notification)
	self._meter_full = true

	managers.hud:set_player_warcry_meter_glow(true)
	managers.network:session():send_to_peers_synched("sync_warcry_meter_glow", true)

	if self._active_warcry and not skip_notification then
		managers.hud:post_event("warcry_available")

		if managers.user:get_setting("warcry_ready_indicator") then
			local warcry = self._active_warcry:get_type()
			local name_id = tweak_data.warcry[warcry].name_id
			local icon = tweak_data.warcry[warcry].hud_icon
			local prompt_title = managers.localization:to_upper_text("hud_hint_warcry_ready_title", {
				WARCRY = managers.localization:text(name_id)
			})
			local prompt_desc = nil

			if managers.controller:is_using_controller() then
				local macros = managers.localization:get_default_macros()
				prompt_desc = managers.localization:to_upper_text("hud_interact_warcry_ready", {
					BTN_USE_ITEM = macros.BTN_TOP_L .. " + " .. macros.BTN_TOP_R
				})
			else
				prompt_desc = managers.localization:to_upper_text("hud_interact_warcry_ready", {
					BTN_USE_ITEM = managers.localization:btn_macro("activate_warcry")
				})
			end

			managers.hud:set_big_prompt({
				flares = true,
				id = "warcry_ready",
				background = "backgrounds_warcry_msg",
				priority = true,
				title = prompt_title,
				description = prompt_desc,
				icon = icon,
				duration = self.WARCRY_READY_MESSAGE_DURATION,
				text_color = tweak_data.gui.colors.raid_gold
			})
		end
	end
end

function WarcryManager:_deactivate_warcry()
	if self._active_warcry then
		self._active_warcry:deactivate()
	end

	self._meter_full = false
	self._duration = nil
	self._active = false
	self._last_value = nil

	if managers.hud then
		managers.hud:deactivate_player_warcry()
	end

	if managers.network then
		managers.network:session():send_to_peers_synched("sync_warcry_meter_glow", false)
		managers.network:session():send_to_peers_synched("sync_deactivate_warcry")

		if Network:is_server() then
			self:deactivate_peer_warcry(managers.network:session():local_peer()._id)
		end
	end
end

function WarcryManager:update(t, dt)
	if not self._active then
		return
	end

	if not self._last_value then
		self._last_value = self._meter_value
	end

	self._active_warcry:update(dt)

	local consume = dt * self._active_warcry:drain_rate()
	self._remaining = self._remaining - consume
	local diff = self._remaining / self._duration - self._last_value

	self:_fill_meter_by_value(diff)

	self._last_value = self._meter_value

	if self._meter_value <= 0 then
		self:_deactivate_warcry()
	end
end

function WarcryManager:add_remaining(value)
	self._remaining = math.clamp(self._remaining + value, 0, self._duration)
end

function WarcryManager:remaining()
	return self._remaining
end

function WarcryManager:duration()
	return self._duration
end

function WarcryManager:duration_multiplier()
	local multiplier = managers.player:upgrade_value("player", "helpcry_warcry_duration_multiplier", 1)

	return multiplier
end

function WarcryManager:active()
	return self._active
end

function WarcryManager:current_meter_value()
	return self._meter_value
end

function WarcryManager:meter_full()
	return self._meter_full
end

function WarcryManager:reset()
	if self._active_warcry then
		if self._meter_value > 0 then
			self:_fill_meter_by_value(-self._meter_value, true)
		end

		setmetatable(self._active_warcry, Warcry.get_metatable(self._active_warcry_name))
		self:deactivate_warcry(true)
		self._active_warcry:cleanup()
	end

	self._meter_value = 0
	self._meter_max_value = 1
	self._remaining = nil
	self._is_perseverating = nil
	self._peer_warcries = {}

	for i = 1, 4 do
		self._peer_warcries[i] = nil
	end
end

function WarcryManager:clear_active_warcry()
	if self._active_warcry then
		self:_fill_meter_by_value(-self._meter_value, true)
		setmetatable(self._active_warcry, Warcry.get_metatable(self._active_warcry_name))
		self:deactivate_warcry(true)
		self._active_warcry:cleanup()
	end

	self._warcries = {}
	self._active_warcry = nil
end

function WarcryManager:peer_warcry_upgrade_value(peer_id, upgrade_category, upgrade_definition_name, default_value)
	local peer_warcry = self._peer_warcries[peer_id]

	if not peer_warcry then
		return default_value
	end

	local tweak_buffs = tweak_data.warcry[peer_warcry.type].buffs
	local level = math.min(peer_warcry.level, #tweak_buffs)
	local wanted_upgrade = nil

	for i = 1, level do
		local buffs = tweak_buffs[i]

		for index, buff in pairs(buffs) do
			local upgrade_definition = tweak_data.upgrades.definitions[buff]

			if not upgrade_definition and not upgrade_definition.upgrade then
				Application:error("[WarcryManager:peer_warcry_upgrade_value] upgrade_definition is not valid", buff)

				return default_value
			end

			if upgrade_definition.upgrade.upgrade == upgrade_definition_name then
				local upgrade_level = upgrade_definition.upgrade.value

				if not wanted_upgrade or wanted_upgrade.value < upgrade_level then
					wanted_upgrade = upgrade_definition.upgrade

					break
				end
			end
		end
	end

	if wanted_upgrade then
		local upgrade_name = wanted_upgrade.upgrade
		local upgrade_level = wanted_upgrade.value
		local upgrade_category_table = nil

		if type(upgrade_category) == "table" then
			upgrade_category_table = tweak_data.upgrades.values

			for j = 1, #upgrade_category do
				upgrade_category_table = upgrade_category_table[upgrade_category[j]]
			end
		else
			upgrade_category_table = tweak_data.upgrades.values[upgrade_category]
		end

		return upgrade_category_table[upgrade_name][upgrade_level]
	end

	return default_value
end

function WarcryManager:save(data)
	if self._warcries then
		local active_warcry = nil

		if self._active_warcry then
			active_warcry = {
				name = self._active_warcry:get_type(),
				level = self._active_warcry:get_level()
			}
		end

		local manager_data = {
			warcries = self._warcries,
			active_warcry = active_warcry
		}
		data.warcry_manager = manager_data
	end
end

function WarcryManager:load(data, version)
	if data.warcry_manager and data.warcry_manager.warcries then
		self:reset()
		self:clear_active_warcry()

		self._meter_value = 0
		self._meter_max_value = 1
		self._warcries = data.warcry_manager.warcries or {}
		self._active_warcry = nil

		Application:debug("[WarcryManager:load] Fallback to getting first active warcry from 'managers.skilltree:get_warcries_applied()'")

		local warcries = managers.skilltree:get_warcries_applied()

		for id, skill_data in pairs(warcries) do
			if skill_data.active and skill_data.warcry_id then
				Application:debug("[WarcryManager:load] warcry_id", skill_data.warcry_id, "Tier", skill_data.exp_tier)
				self:set_active_warcry({
					name = skill_data.warcry_id,
					level = skill_data.exp_tier or 1
				})

				break
			end
		end
	end
end

function WarcryManager:setup_upgrades()
	if self._active then
		self:_deactivate_warcry()
	end

	local pm = managers.player
	self._interrupt_penalty_reduction = pm:upgrade_value("player", "helpcry_warcry_downed_reduction", 1) - 1
end

function WarcryManager:on_simulation_ended()
	self:on_mission_end_callback()
end

function WarcryManager:on_mission_end_callback()
	self:deactivate_warcry(true)
end
