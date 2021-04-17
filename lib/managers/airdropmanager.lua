AirdropManager = AirdropManager or class()

function AirdropManager:init()
	self._drop_point_groups = {}
	self._planes = {}
	self._drop_pods = {}
	self._in_cooldown = false
	self._items_in_pods = {}
end

function AirdropManager:register_drop_point_group(drop_point_group)
	table.insert(self._drop_point_groups, drop_point_group)
end

function AirdropManager:call_drop(unit)
	if Network and Network:is_server() then
		self:_call_drop(unit)
	else
		managers.network:session():send_to_host("call_airdrop", unit)
	end
end

function AirdropManager:_call_drop(unit)
	if self._in_cooldown == true then
		Application:trace("AIRDROP IN COOLDOWN. Please wait " .. tostring(math.ceil(managers.queued_tasks:when("airdrop_cooldown"))) .. " second(s).")

		return
	end

	local drop_position = nil
	local player_position = managers.player:player_unit():movement():m_pos()

	if #self._drop_point_groups > 0 then
		local closest_drop_group_distance = mvector3.distance_sq(player_position, self._drop_point_groups[1]._values.position)
		local closest_drop_group = 1

		for i = 1, #self._drop_point_groups do
			local current_group_distance = mvector3.distance_sq(player_position, self._drop_point_groups[i]._values.position)

			if current_group_distance < closest_drop_group_distance then
				closest_drop_group_distance = current_group_distance
				closest_drop_group = i
			end
		end

		drop_position = self._drop_point_groups[closest_drop_group]:get_random_drop_point()
	else
		drop_position = managers.player:player_unit():movement():m_pos():with_z(1000)
	end

	local data = {
		position = drop_position,
		unit = unit
	}

	managers.queued_tasks:queue("airdrop", self.drop_item, self, data, tweak_data.interaction.drop_test.delay, nil)

	self._in_cooldown = true

	managers.queued_tasks:queue("airdrop_cooldown", self.exit_cooldown, self, nil, tweak_data.interaction.drop_test.cooldown, nil)
end

function AirdropManager:drop_item(data)
	local angle = math.random(0, 359)
	local dist = math.random(0, 150)
	local dx = dist * math.cos(angle)
	local dy = dist * math.sin(angle)
	local position = Vector3(data.position.x + dx, data.position.y + dy, data.position.z)
	local rotation = Rotation(0, 0, 0)
	local unit = World:spawn_unit(Idstring("units/vanilla/vehicles/vhc_junkers_resupply/vhc_junkers_resupply"), position, rotation)

	unit:damage():run_sequence_simple("anim_drop_pod")
	unit:base():set_drop_unit(data.unit)
	managers.network:session():send_to_peers_synched("airdrop_trigger_drop_sequence", unit, "anim_drop_pod")
	table.insert(self._planes, unit)
end

function AirdropManager:set_plane_sequence(plane_unit, sequence_name)
	plane_unit:damage():run_sequence_simple(sequence_name)
end

function AirdropManager:spawn_pod(unit_to_spawn, plane_unit)
	if Network and Network:is_server() then
		self:_spawn_pod(unit_to_spawn, plane_unit)
	end
end

function AirdropManager:_spawn_pod(unit_to_spawn, plane_unit)
	local pod_locator = plane_unit:get_object(Idstring("spawn_pod"))
	local pod = World:spawn_unit(Idstring("units/vanilla/props/props_drop_pod/props_drop_pod"), pod_locator:position(), pod_locator:rotation())

	pod:interaction():set_unit(unit_to_spawn)

	self._items_in_pods[tostring(pod:id())] = unit_to_spawn

	table.insert(self._drop_pods, pod)
end

function AirdropManager:spawn_unit_inside_pod(unit, position, yaw, pitch, roll)
	if Network and Network:is_server() then
		self:_spawn_unit_inside_pod(unit, position, Rotation(yaw, pitch, roll))
	else
		managers.network:session():send_to_host("airdrop_spawn_unit_in_pod", unit, position, yaw, pitch, roll)
	end
end

function AirdropManager:_spawn_unit_inside_pod(unit, position, rotation)
	if self._items_in_pods[unit] ~= nil then
		World:spawn_unit(Idstring(self._items_in_pods[unit]), position, rotation)
	end
end

function AirdropManager:exit_cooldown()
	self._in_cooldown = false
end

function AirdropManager:on_simulation_ended()
	managers.queued_tasks:unqueue_all(nil, self)

	self._drop_point_groups = {}
	self._items_in_pods = {}

	for i = #self._planes, 1, -1 do
		if self._planes[i]:alive() then
			self._planes[i]:set_slot(0)
		end
	end

	for i = #self._drop_pods, 1, -1 do
		self._drop_pods[i]:set_slot(0)
	end

	self._planes = {}
	self._drop_pods = {}
	self._in_cooldown = false
end
