NetworkBaseExtension = NetworkBaseExtension or class()

-- Lines 3-5
function NetworkBaseExtension:init(unit)
	self._unit = unit
end

-- Lines 9-18
function NetworkBaseExtension:send(func, ...)
	if managers.network:session() then
		local peer = managers.network:session():local_peer()

		if not peer:loading() then
			managers.network:session():send_to_peers_synched(func, self._unit, ...)
		else
			Application:debug("[NetworkBaseExtension:send_to_unit] SKIPPED!", self._unit)
		end
	end
end

-- Lines 22-31
function NetworkBaseExtension:send_to_host(func, ...)
	if managers.network:session() then
		local peer = managers.network:session():local_peer()

		if not peer:loading() then
			managers.network:session():send_to_host(func, self._unit, ...)
		else
			Application:debug("[NetworkBaseExtension:send_to_unit] SKIPPED!", self._unit)
		end
	end
end

-- Lines 35-47
function NetworkBaseExtension:send_to_unit(params)
	if managers.network:session() then
		local peer = managers.network:session():local_peer()

		if not peer:loading() then
			local peer = managers.network:session():peer_by_unit(self._unit)

			if peer then
				managers.network:session():send_to_peer(peer, unpack(params))
			end
		else
			Application:debug("[NetworkBaseExtension:send_to_unit] SKIPPED!", self._unit)
		end
	end
end

-- Lines 51-55
function NetworkBaseExtension:peer()
	if managers.network:session() then
		return managers.network:session():peer_by_unit(self._unit)
	end
end
