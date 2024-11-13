SmallLootBase = SmallLootBase or class(UnitBase)

function SmallLootBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup()
end

function SmallLootBase:_setup()
end

function SmallLootBase:take(unit)
	if self._empty then
		return
	end

	self:taken()

	if Network:is_client() then
		managers.network:session():send_to_host("sync_small_loot_taken", self._unit)
	end

	local count = self._unit:loot_drop() and self._unit:loot_drop():value()
	local loot_size = self._unit:loot_drop() and self._unit:loot_drop()._loot_size

	managers.statistics:collect_dogtags(count)
	managers.dialog:queue_dialog("player_gen_loot_" .. tostring(loot_size), {
		instigator = nil,
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})
	managers.notification:add_notification({
		id = "hud_hint_grabbed_nazi_gold",
		shelf_life = 5,
		notification_type = nil,
		duration = 2,
		total = nil,
		acquired = nil,
		notification_type = HUDNotification.DOG_TAG,
		acquired = managers.lootdrop:picked_up_current_leg(),
		total = managers.lootdrop:loot_spawned_current_leg()
	})
end

function SmallLootBase:taken(skip_sync)
	managers.lootdrop:pickup_loot(self._unit:loot_drop():value(), self._unit)

	if Network:is_server() then
		managers.notification:add_notification({
			id = "hud_hint_grabbed_nazi_gold",
			shelf_life = 5,
			notification_type = nil,
			duration = 2,
			total = nil,
			acquired = nil,
			notification_type = HUDNotification.DOG_TAG,
			acquired = managers.lootdrop:picked_up_current_leg(),
			total = managers.lootdrop:loot_spawned_current_leg()
		})
		self:_set_empty()
		managers.network:session():send_to_peers_synched("sync_picked_up_loot_values", managers.lootdrop:picked_up_current_leg(), managers.lootdrop:loot_spawned_current_leg())
	end
end

function SmallLootBase:_set_empty()
	self._empty = true

	if not self.skip_remove_unit then
		self._unit:set_slot(0)
	end
end

function SmallLootBase:save(data)
	data.loot_value = self._unit:loot_drop():value()
end

function SmallLootBase:load(data)
	self._unit:loot_drop():set_value(data.loot_value)
end

function SmallLootBase:destroy()
end
