SmallLootBase = SmallLootBase or class(UnitBase)

function SmallLootBase:take(unit)
	if self._empty then
		return
	end

	self:sync_taken()

	if Network:is_client() then
		managers.network:session():send_to_host("sync_small_loot_taken", self._unit)
	end

	local count = self._unit:loot_drop() and self._unit:loot_drop():value()

	managers.statistics:collect_dogtags(count)
end

function SmallLootBase:sync_taken()
	managers.lootdrop:pickup_loot(self._unit:loot_drop():value(), self._unit)
	managers.notification:add_notification({
		shelf_life = 5,
		duration = 2,
		id = "hud_hint_grabbed_nazi_gold",
		notification_type = HUDNotification.DOG_TAG,
		acquired = managers.lootdrop:picked_up_current_leg(),
		total = managers.lootdrop:loot_spawned_current_leg()
	})

	if Network:is_server() then
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
