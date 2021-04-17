SmallLootBase = SmallLootBase or class(UnitBase)

-- Lines 5-9
function SmallLootBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup()
end

-- Lines 13-14
function SmallLootBase:_setup()
end

-- Lines 18-39
function SmallLootBase:take(unit)
	if self._empty then
		return
	end

	self:taken()

	if Network:is_client() then
		managers.network:session():send_to_host("sync_small_loot_taken", self._unit)
	end

	managers.dialog:queue_dialog("player_gen_loot_" .. tostring(self._unit:loot_drop()._loot_size), {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

	local percentage_picked_up = math.clamp(math.ceil(100 * managers.lootdrop:picked_up_current_leg() / managers.lootdrop:loot_spawned_current_leg()), 0, 100)

	managers.notification:add_notification({
		id = "hud_hint_grabbed_nazi_gold",
		duration = 2,
		shelf_life = 5,
		notification_type = HUDNotification.DOG_TAG,
		acquired = managers.lootdrop:picked_up_current_leg(),
		total = managers.lootdrop:loot_spawned_current_leg()
	})
end

-- Lines 41-57
function SmallLootBase:taken(skip_sync)
	managers.lootdrop:pickup_loot(self._unit:loot_drop():value(), self._unit)

	if Network:is_server() then
		managers.notification:add_notification({
			id = "hud_hint_grabbed_nazi_gold",
			duration = 2,
			shelf_life = 5,
			notification_type = HUDNotification.DOG_TAG,
			acquired = managers.lootdrop:picked_up_current_leg(),
			total = managers.lootdrop:loot_spawned_current_leg()
		})
		self:_set_empty()
		managers.network:session():send_to_peers_synched("sync_picked_up_loot_values", managers.lootdrop:picked_up_current_leg(), managers.lootdrop:loot_spawned_current_leg())
	end
end

-- Lines 59-65
function SmallLootBase:_set_empty()
	self._empty = true

	if not self.skip_remove_unit then
		self._unit:set_slot(0)
	end
end

-- Lines 69-71
function SmallLootBase:save(data)
	data.loot_value = self._unit:loot_drop():value()
end

-- Lines 73-75
function SmallLootBase:load(data)
	self._unit:loot_drop():set_value(data.loot_value)
end

-- Lines 77-79
function SmallLootBase:destroy()
end
