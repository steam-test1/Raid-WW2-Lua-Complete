AirdropManager = AirdropManager or class()
local idstr_plane = Idstring("units/vanilla/vehicles/vhc_junkers_resupply/vhc_junkers_resupply")
local idstr_pod = Idstring("units/vanilla/props/props_drop_pod/props_drop_pod")
local idstr_spawn_pod = Idstring("spawn_pod")

function AirdropManager:init()
	self._in_cooldown = false
	self._drop_point_groups = {}
	self._planes = {}
	self._drop_pods = {}
	self._items_in_pods = {}
end

function AirdropManager:register_drop_point_group(drop_point_group)
	table.insert(self._drop_point_groups, drop_point_group)
	Application:info("[AirdropManager] #Groups:", #self._drop_point_groups)
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
		Application:trace("[AirdropManager] AIRDROP IN COOLDOWN. Please wait " .. tostring(math.ceil(managers.queued_tasks:when("airdrop_cooldown"))) .. " second(s).")

		return
	end

	local drop_position = nil
	local player_position = managers.player:player_unit():position()

	Application:info("[AirdropManager] player_position:", player_position)

	if #self._drop_point_groups > 0 then
		local closest_drop_group_distance = mvector3.distance_sq(player_position, self._drop_point_groups[1]._values.position)
		local closest_drop_idx = 1

		for i = 1, #self._drop_point_groups do
			local current_group_distance = mvector3.distance_sq(player_position, self._drop_point_groups[i]._values.position)

			Application:info("[AirdropManager] DIST:", current_group_distance)

			if current_group_distance < closest_drop_group_distance then
				closest_drop_group_distance = current_group_distance
				closest_drop_idx = i
			end
		end

		drop_position = self._drop_point_groups[closest_drop_idx]:get_random_drop_point()
	else
		drop_position = managers.player:player_unit():movement():m_pos()
	end

	local data = {
		position = drop_position,
		unit = unit
	}
	local drop_tweak_data = tweak_data.interaction:get_interaction("drop_test")

	managers.queued_tasks:queue("airdrop", self.drop_item, self, data, drop_tweak_data.delay, nil)

	self._in_cooldown = true

	managers.queued_tasks:queue("airdrop_cooldown", self.exit_cooldown, self, nil, drop_tweak_data.cooldown, nil)
end

function AirdropManager:drop_item(data)
	local angle = math.random(0, 359)
	local dist = math.random(0, 150)
	local dx = dist * math.cos(angle)
	local dy = dist * math.sin(angle)
	local position = Vector3(data.position.x + dx, data.position.y + dy, data.position.z)
	local rotation = Rotation(0, 0, 0)
	local unit = World:spawn_unit(idstr_plane, position, rotation)

	unit:damage():run_sequence_simple("anim_drop_pod")
	unit:base():set_drop_unit(data.unit)
	managers.network:session():send_to_peers_synched("airdrop_trigger_drop_sequence", unit, "anim_drop_pod")
	table.insert(self._planes, unit)
end

function AirdropManager:set_plane_sequence(plane_unit, sequence_name)
	plane_unit:damage():run_sequence_simple(sequence_name)
end

function AirdropManager:server_spawn_pod(unit_to_spawn, plane_unit)
	if Network and Network:is_server() then
		self:_spawn_pod(unit_to_spawn, plane_unit)
	end
end

function AirdropManager:_spawn_pod(unit_to_spawn, plane_unit)
	local pod_locator = plane_unit:get_object(idstr_spawn_pod)
	local pod = World:spawn_unit(idstr_pod, pod_locator:position(), pod_locator:rotation())

	pod:interaction():set_unit(unit_to_spawn)

	self._items_in_pods[tostring(pod:id())] = unit_to_spawn

	self:register_pod(pod)
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
	Application:debug("[AirdropManager] Finished cooldown!")

	self._in_cooldown = false

	self:clear_latest_plane()
end

function AirdropManager:register_pod(pod)
	table.insert(self._drop_pods, pod)
	Application:debug("[AirdropManager] Registered Pod:", pod, "TotalPods #" .. tostring(#self._drop_pods))
end

function AirdropManager:on_simulation_ended()
	self:cleanup()
end

function AirdropManager:clear_latest_plane()
	if self._planes then
		local plane_unit = table.remove(self._planes)

		if plane_unit:alive() then
			plane_unit:set_slot(0)
		end
	end

	Application:info("[AirdropManager] #Planes", #self._planes, inspect(self._planes))
end

function AirdropManager:cleanup()
	Application:debug("[AirdropManager] Cleanup!")
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
