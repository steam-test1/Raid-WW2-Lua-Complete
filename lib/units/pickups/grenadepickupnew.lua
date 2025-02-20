GrenadePickupNew = GrenadePickupNew or class()

function GrenadePickupNew:init(unit)
	self._unit = unit
	self._visual_objects = self.visual_objects or 1
	self._stack_size_max = self.stack_size_max or 1
	self._mul_chance = math.max(0, self.mul_chance or 0.5)
	self._graphics_name = self._graphics_name or "g_grenade_"
	self._beaming = self.beaming or false
	self._automatic_pickup = self.automatic_pickup or false

	if Network:is_server() then
		self:_randomize_stack_size()
	end

	local material = self._unit:material(Idstring("mat_effect"))

	if material then
		Pickup.randomize_glow_effect(material)
	end

	if self._beaming then
		self._unit:damage():has_then_run_sequence_simple("show_dropped")
	else
		self._unit:damage():has_then_run_sequence_simple("show_static")
	end
end

function GrenadePickupNew:_randomize_stack_size()
	local stack_amount = self._stack_size_max
	local stack_size = 0

	if stack_amount > 1 then
		local chance = 100

		for i = 1, stack_amount do
			if i == 1 or math.random(100) <= chance then
				chance = chance * self._mul_chance

				if stack_size then
					stack_size = stack_size + 1
				else
					stack_size = 1
				end
			end
		end
	else
		stack_size = 1
	end

	self:set_stack_size(stack_size)

	if self._stack_size > 0 then
		managers.network:session():send_to_peers_synched("register_munitions_stack_size", self._unit, self._stack_size)
	else
		Application:warn("[GrenadePickupNew] Generated with 0 stack size -- Deleting unit!")
		self:delete_unit()
	end
end

function GrenadePickupNew:sync_pickup_munitions_stack(stack_consume)
	self:consume(stack_consume)
end

function GrenadePickupNew:sync_pickup_munitions_size(stack_size)
	self:set_stack_size(stack_size)
end

function GrenadePickupNew:consume(stack_consume)
	self:set_stack_size(self._stack_size - stack_consume)
end

function GrenadePickupNew:delete_unit()
	if Network:is_server() then
		managers.drop_loot:despawn_item(self._unit)
	end
end

function GrenadePickupNew:despawn_item()
	if Network:is_server() then
		self._unit:set_slot(0)
	end
end

function GrenadePickupNew:pickup(player_unit)
	return self:_pickup(player_unit)
end

function GrenadePickupNew:_pickup(player_unit)
	local inventory = player_unit:inventory()

	if not player_unit:character_damage():dead() and inventory then
		local local_peer = managers.network:session():local_peer():id()
		local amount_taken = 0
		local amount_needed = managers.player:get_grenade_amount_missing(local_peer)

		if amount_needed > 0 then
			local effect_ammo_pickup_multiplier = 1

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) then
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) or 1) - 1
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1
			end

			amount_needed = math.min(self._stack_size, amount_needed)
			local tweak_data_per_stack = (tweak_data.projectiles[inventory.equipped_grenade].per_pickup or 1) * effect_ammo_pickup_multiplier
			local grenades_to_add = math.ceil(amount_needed / tweak_data_per_stack)
			amount_taken = managers.player:add_grenade_amount(grenades_to_add)
		end

		if amount_taken > 0 then
			for i_grenade = 1, amount_taken do
				managers.player:register_grenade(local_peer)
			end

			local grant_ammo = math.rand_bool()

			if managers.player:has_category_upgrade("player", "opportunist_pick_up_grenade_to_ammo") and grant_ammo then
				local add_ammo_ratio = managers.player:upgrade_value("player", "opportunist_pick_up_grenade_to_ammo") - 1
				local any_picked_up = false

				for id, weapon in pairs(player_unit:inventory():available_selections()) do
					local picked_up = weapon.unit:base():add_ammo(add_ammo_ratio)

					if picked_up then
						managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())

						any_picked_up = true
					end
				end

				if not any_picked_up then
					grant_ammo = false
				end
			end

			if managers.player:has_category_upgrade("player", "opportunist_pick_up_grenade_to_health") and not grant_ammo then
				local damage_ext = player_unit:character_damage()

				if damage_ext and not damage_ext:is_downed() and not damage_ext:dead() and not damage_ext:is_perseverating() then
					local restore_value = managers.player:upgrade_value("player", "opportunist_pick_up_grenade_to_health")

					damage_ext:restore_health(restore_value, true)
				end
			end

			managers.network:session():send_to_peers_synched("sync_pickup_munitions_stack", self._unit, amount_taken)
			player_unit:sound():play(self._pickup_event or "pickup_grenade")
			self:consume(amount_taken)

			return true
		end
	end

	return false
end

function GrenadePickupNew:register_grenades(gained_grenades, peer)
	local player = managers.player:local_player()

	if not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if peer then
		for i_grenade = 1, gained_grenades do
			managers.player:register_grenade(peer:id())
		end
	end
end

function GrenadePickupNew:get_stack_size()
	return self._stack_size or 0
end

function GrenadePickupNew:set_stack_size(stack_size)
	self._stack_size = stack_size

	if self._stack_size <= 0 then
		Application:debug("[GrenadePickupNew] EMPTY... KILL IT")
		self:delete_unit()

		return
	else
		if self._unit:interaction() then
			self._unit:interaction():set_active(true, true)
		end

		for i = 1, self._visual_objects do
			local obj1 = self._unit:get_object(Idstring(self._graphics_name .. i))

			if obj1 then
				local vis = i <= self._stack_size

				obj1:set_visibility(vis)

				local obj2 = self._unit:get_object(Idstring(self._graphics_name .. i .. "_lod"))

				if obj2 then
					obj2:set_visibility(vis)
				end
			end
		end
	end
end

function GrenadePickupNew:get_automatic_pickup()
	return self._automatic_pickup
end

function GrenadePickupNew:get_pickup_type()
	return "grenade"
end

function GrenadePickupNew:save(data)
	local state = {
		stack_size = self._stack_size
	}
	data.GrenadePickupNew = state
end

function GrenadePickupNew:load(data)
	local state = data.GrenadePickupNew

	if state then
		self:set_stack_size(state.stack_size)
	end
end
