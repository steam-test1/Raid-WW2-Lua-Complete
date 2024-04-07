GrenadePickupNew = GrenadePickupNew or class()

function GrenadePickupNew:init(unit)
	self._unit = unit
	self._visual_objects = self.visual_objects or 1
	self._stack_size_max = self.stack_size_max or 1
	self._mul_chance = math.max(0, self.mul_chance or 0.5)
	self._graphics_name = self._graphics_name or "g_grenade_"

	if Network:is_server() then
		self:_randomize_stack_size()
	end

	self:_randomize_glow_effect()
end

local ids_mat_effect = Idstring("mat_sweep")
local ids_uv0_offset = Idstring("uv0_offset")

function GrenadePickupNew:_randomize_glow_effect()
	local material = self._unit:material(ids_mat_effect)

	if material then
		local r = math.random()

		material:set_variable(ids_uv0_offset, Vector3(r, r, r))
	end
end

function GrenadePickupNew:_randomize_stack_size()
	local stack_amount = self._stack_size_max
	local stack_size = 0

	if stack_amount > 1 then
		local chance = 100

		for i = 1, stack_amount do
			if i == 1 or chance >= math.random(100) then
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
	if self._stack_size then
		self:set_stack_size(self._stack_size - stack_consume)
	end
end

function GrenadePickupNew:delete_unit()
	World:delete_unit(self._unit)
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
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + ((managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) or 1) - 1)
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + ((managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1)
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

			managers.network:session():send_to_peers_synched("sync_pickup_munitions_stack", self._unit, amount_taken)
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

function GrenadePickupNew:get_pickup_type()
	return "grenade"
end

function GrenadePickupNew:save(data)
	local state = {}

	state.stack_size = self._stack_size
	data.GrenadePickupNew = state
end

function GrenadePickupNew:load(data)
	local state = data.GrenadePickupNew

	if state then
		self:set_stack_size(state.stack_size)
	end
end

function GrenadePickupNew:set_stack_size(stack_size)
	self._stack_size = stack_size

	if self._stack_size <= 0 then
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
