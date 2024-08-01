LootManager = LootManager or class()

-- Lines 3-5
function LootManager:init()
	self:_setup()
end

-- Lines 7-26
function LootManager:_setup()
	local distribute = {}
	local saved_secured = {}

	if Global.loot_manager and Global.loot_manager.secured then
		saved_secured = deep_clone(Global.loot_manager.secured)

		for _, data in ipairs(Global.loot_manager.secured) do
			table.insert(distribute, data)
		end
	end

	Global.loot_manager = {
		secured = {},
		distribute = distribute,
		saved_secured = saved_secured
	}
	self._global = Global.loot_manager
	self._triggers = {}
	self._respawns = {}
end

-- Lines 28-30
function LootManager:clear()
	Global.loot_manager = nil
end

-- Lines 32-35
function LootManager:reset()
	Global.loot_manager = nil

	self:_setup()
end

-- Lines 37-39
function LootManager:on_simulation_ended()
	self._respawns = {}
end

-- Lines 41-44
function LootManager:add_trigger(id, type, amount, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		amount = amount,
		callback = callback
	}
end

-- Lines 46-59
function LootManager:_check_triggers(type)
	if not self._triggers[type] then
		return
	end

	if type == "report_only" then
		for id, cb_data in pairs(self._triggers[type]) do
			cb_data.callback()
		end
	else
		debug_pause("[LootManager:_check_triggers] Unsupported trigger type!", type)
	end
end

-- Lines 64-66
function LootManager:get_secured()
	return table.remove(self._global.secured, 1)
end

-- Lines 70-73
function LootManager:get_secured_random()
	local entry = math.random(#self._global.secured)

	return table.remove(self._global.secured, entry)
end

-- Lines 78-80
function LootManager:get_distribute()
	return table.remove(self._global.distribute, 1)
end

-- Lines 85-87
function LootManager:get_respawn()
	return table.remove(self._respawns, 1)
end

-- Lines 92-94
function LootManager:add_to_respawn(carry_id, multiplier)
	table.insert(self._respawns, {
		carry_id = carry_id,
		multiplier = multiplier
	})
end

-- Lines 99-101
function LootManager:on_job_deactivated()
	self:clear()
end

-- Lines 103-105
function LootManager:on_restart_to_camp()
	self:clear()
end

-- Lines 111-119
function LootManager:secure(carry_id, multiplier_level, silent)
	if Network:is_server() then
		self:server_secure_loot(carry_id, multiplier_level, silent)
	else
		managers.network:session():send_to_host("server_secure_loot", carry_id, multiplier_level, silent)
	end
end

-- Lines 124-128
function LootManager:server_secure_loot(carry_id, multiplier_level, silent)
	managers.network:session():send_to_peers_synched("sync_secure_loot", carry_id, multiplier_level, silent)
	self:sync_secure_loot(carry_id, multiplier_level, silent)
end

-- Lines 134-150
function LootManager:sync_secure_loot(carry_id, multiplier_level, silent)
	local multiplier = 1

	table.insert(self._global.secured, {
		carry_id = carry_id,
		multiplier = multiplier
	})
	self:_check_triggers("report_only")

	if not silent then
		-- Nothing
	end

	if managers.raid_job:current_job() and not managers.raid_job:current_job().consumable then
		managers.greed:secure_greed_carry_loot(carry_id, multiplier)
	end

	managers.experience:mission_xp_award("tiny_loot_bonus")
end

-- Lines 155-164
function LootManager:_present(carry_id, multiplier)
	local carry_data = tweak_data.carry[carry_id]
	local title = managers.localization:text("hud_loot_secured_title")
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local text = managers.localization:text("hud_loot_secured", {
		AMOUNT = "",
		CARRY_TYPE = type_text
	})
	local icon = nil

	managers.hud:present_mid_text({
		time = 4,
		text = text,
		title = title,
		icon = icon
	})
end

-- Lines 169-171
function LootManager:sync_save(data)
	data.LootManager = self._global
end

-- Lines 174-182
function LootManager:sync_load(data)
	self._global = data.LootManager

	for _, data in ipairs(self._global.secured) do
		if data.multiplier and data.multiplier > 2 then
			data.multiplier = 2
		end
	end
end
