WarcryManager = WarcryManager or class()
WarcryManager.WARCRY_READY_MESSAGE_DURATION = 6
WarcryManager.CLASS_TO_WARCRY = {
	recon = "sharpshooter",
	demolitions = "clustertruck",
	assault = "berserk",
	infiltrator = "ghost"
}

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
	self._warcries = {}
	self._active_warcry = nil
	self._ids_warcry_post_processor = Idstring("warcry")
	self._ids_warcry_modifier = Idstring("warcry")
end

function WarcryManager:_setup()
	self:reset()

	if self._active_warcry then
		self:set_active_warcry({
			name = self._active_warcry:get_type(),
			level = self._active_warcry:get_level()
		})
	end
end

function WarcryManager:set_warcry_post_effect(ids_effect)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", self._ids_warcry_post_processor, ids_effect)
	end
end

function WarcryManager:warcry_post_material()
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local warcry_pp = vp:vp():get_post_processor_effect("World", self._ids_warcry_post_processor)

		if warcry_pp then
			local warcry_mod = warcry_pp:modifier(self._ids_warcry_modifier)

			if warcry_mod then
				return warcry_mod:material()
			end
		end
	end
end

function WarcryManager:acquire_warcry(warcry_name)
	if self:warcry_acquired(warcry_name) then
		return
	end

	if self._active_warcry then
		self:deactivate_warcry()
	end

	local warcry = {
		level = 1,
		name = warcry_name
	}

	table.insert(self._warcries, warcry)
	self:set_active_warcry(warcry)
end

function WarcryManager:set_active_warcry(warcry)
	if self._active_warcry then
		self._active_warcry:cleanup()

		self._active_warcry = nil
	end

	self._active_warcry = Warcry.create(warcry.name)

	self._active_warcry:set_level(warcry.level)

	self._active_warcry_name = warcry.name

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

	managers.hud:remove_comm_wheel_option("warcry")
	managers.hud:hide_big_prompt("warcry_ready")
	self._active_warcry:activate()

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES) then
		managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES, managers.network:session():local_peer():id())
	end

	self._duration = self._active_warcry:duration()
	self._remaining = self._duration
	self._active = true
	local warcry_type = self._active_warcry:get_type()
	local warcry_level = self._active_warcry:get_level()

	managers.network:session():send_to_peers_synched("sync_activate_warcry", warcry_type, warcry_level, self._duration)

	local warcry_switch = managers.hud._sound_source

	warcry_switch:set_switch("warcry_switch", tostring("warcry_" .. tostring(warcry_type)))
	warcry_switch:set_switch("warcry_level", tostring("warcry_level_" .. tostring(warcry_level)))
	managers.hud._sound_source:post_event("warcry_active")
	managers.dialog:queue_dialog(tostring("warcry_" .. tostring(warcry_type)), {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

	if Network:is_server() then
		self:activate_peer_warcry(managers.network:session():local_peer()._id, warcry_type, warcry_level)
	end
end

function WarcryManager:deactivate_warcry()
	self:_fill_meter_by_value(-self._meter_value, true)

	self._meter_full = false

	if managers.hud then
		managers.hud:deactivate_player_warcry()
	end

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

function WarcryManager:_fill_meter_by_value(value, sync)
	self._meter_value = self._meter_value + value

	if self._meter_max_value <= self._meter_value then
		self._meter_value = self._meter_max_value

		if not self._meter_full then
			self:_on_meter_full()
		end
	end

	if self._meter_value < 0 then
		self._meter_value = 0
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
		id = "warcry",
		text_id = "com_wheel_warcry",
		icon = tweak_data.warcry[self._active_warcry:get_type()].hud_icon,
		color = Color.white,
		clbk = callback(self, self, "activate_warcry")
	}

	managers.hud:add_comm_wheel_option(warcry_comm_wheel_option, index)
end

function WarcryManager:current_meter_percentage()
	return self._meter_value / self._meter_max_value * 100
end

function WarcryManager:_on_meter_full()
	self._meter_full = true

	managers.hud:set_player_warcry_meter_glow(true)
	managers.network:session():send_to_peers_synched("sync_warcry_meter_glow", true)
	managers.hud._sound_source:post_event("warcry_available")
	self:add_warcry_comm_wheel_option(1)

	local prompt_text = nil

	if managers.controller:is_using_controller() then
		prompt_text = utf8.to_upper(managers.localization:text("hud_interact_warcry_ready", {
			BTN_USE_ITEM = managers.localization:get_default_macros().BTN_TOP_L .. " + " .. managers.localization:get_default_macros().BTN_TOP_R
		}))
	else
		prompt_text = utf8.to_upper(managers.localization:text("hud_interact_warcry_ready", {
			BTN_USE_ITEM = managers.localization:btn_macro("activate_warcry")
		}))
	end

	local interact_data = {
		id = "warcry_ready",
		text = prompt_text,
		duration = WarcryManager.WARCRY_READY_MESSAGE_DURATION
	}

	managers.hud:set_big_prompt({
		background = "backgrounds_warcry_msg",
		id = interact_data.id,
		text = interact_data.text,
		duration = interact_data.duration,
		text_color = Color("dd9a38")
	})
end

function WarcryManager:_deactivate_warcry()
	if self._active_warcry then
		self._active_warcry:deactivate()
	end

	self._duration = nil
	self._active = false
	self._meter_full = false
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

	self._remaining = self._remaining - dt
	local diff = self._remaining / self._duration - self._last_value

	self:_fill_meter_by_value(diff)

	self._last_value = self._meter_value

	if self._meter_value <= 0 then
		self:_deactivate_warcry()
	end
end

function WarcryManager:remaining()
	return self._remaining
end

function WarcryManager:duration()
	return self._duration
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
		self:_fill_meter_by_value(-self._meter_value, true)
		setmetatable(self._active_warcry, Warcry.get_metatable(self._active_warcry_name))
		self:deactivate_warcry()
		self._active_warcry:cleanup()
	end

	self._meter_value = 0
	self._meter_max_value = 1
	self._remaining = nil
	self._peer_warcries = {}

	for i = 1, 4 do
		self._peer_warcries[i] = nil
	end
end

function WarcryManager:clear_active_warcry()
	if self._active_warcry then
		self:_fill_meter_by_value(-self._meter_value, true)
		setmetatable(self._active_warcry, Warcry.get_metatable(self._active_warcry_name))
		self:deactivate_warcry()
		self._active_warcry:cleanup()
	end

	self._warcries = {}
	self._active_warcry = nil
end

function WarcryManager:peer_warcry_upgrade_value(peer_id, upgrade_category, upgrade_definition_name, default_value)
	local peer_warcry = self._peer_warcries[peer_id]

	if peer_warcry then
		local buffs = nil

		if peer_warcry.level > #tweak_data.warcry[peer_warcry.type].buffs then
			buffs = tweak_data.warcry[peer_warcry.type].buffs[#tweak_data.warcry[peer_warcry.type].buffs]
		else
			buffs = tweak_data.warcry[peer_warcry.type].buffs[peer_warcry.level]
		end

		for index, buff in pairs(buffs) do
			local upgrade_definition = tweak_data.upgrades.definitions[buff]

			if upgrade_definition.upgrade.upgrade == upgrade_definition_name then
				local upgrade_name = upgrade_definition.upgrade.upgrade
				local upgrade_level = upgrade_definition.upgrade.value
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
		end
	end

	return default_value
end

function WarcryManager:save(data)
	if self._warcries then
		local manager_data = {
			warcries = self._warcries,
			active_warcry = self._active_warcry
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
		self._warcries = {}
		self._active_warcry = nil
		self._warcries = data.warcry_manager.warcries

		if data.warcry_manager.active_warcry then
			self:set_active_warcry({
				level = data.warcry_manager.active_warcry._level,
				name = data.warcry_manager.active_warcry._type
			})
		else
			self:set_active_warcry(self._warcries[#self._warcries])
		end
	end
end

function WarcryManager:on_simulation_ended()
	self._meter_value = 0
end

function WarcryManager:on_mission_end_callback()
	self:_deactivate_warcry()
	self:_fill_meter_by_value(-self._meter_value, true)
end
