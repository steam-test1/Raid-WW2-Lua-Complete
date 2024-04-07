RevivePumpkinExt = RevivePumpkinExt or class()

function RevivePumpkinExt:init(unit)
	local idstr_pumpkin_asset = Idstring("revive_pumpkin")

	self._unit = unit
	self._should_sync = true

	self._unit:set_extension_update_enabled(idstr_pumpkin_asset, false)

	self._listener_key_enter = "revive_pumpkin_enter" .. tostring(unit:key())
	self._listener_key_exit = "revive_pumpkin_exit" .. tostring(unit:key())

	if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_NO_BLEEDOUT_PUMPIKIN_REVIVE) and not Application:editor() and Network:is_server() then
		self._unit:set_slot(0)

		return
	end

	managers.system_event_listener:add_listener(self._listener_key_enter, {
		PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN
	}, callback(self, self, "local_player_enter_resapwn"))
	managers.system_event_listener:add_listener(self._listener_key_exit, {
		PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN
	}, callback(self, self, "local_player_exit_resapwn"))

	self._materials = {}

	local all_materials = self._unit:get_objects_by_type(Idstring("material"))

	for _, m in ipairs(all_materials) do
		if m:variable_exists(Idstring("contour_color")) then
			table.insert(self._materials, m)
			m:set_variable(Idstring("contour_opacity"), 0)
		end
	end
end

function RevivePumpkinExt:local_player_enter_resapwn(level)
	Application:debug("[RevivePumpkinExt:local_player_enter_resapwn]")

	for _, m in ipairs(self._materials) do
		m:set_variable(Idstring("contour_opacity"), 1)
	end
end

function RevivePumpkinExt:local_player_exit_resapwn(level)
	Application:debug("[RevivePumpkinExt:local_player_exit_resapwn]")

	for _, m in ipairs(self._materials) do
		m:set_variable(Idstring("contour_opacity"), 0)
	end
end

function RevivePumpkinExt:destroy()
	managers.system_event_listener:remove_listener(self._listener_key_enter)
	managers.system_event_listener:remove_listener(self._listener_key_exit)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PUMPKIN_DESTROYED)

	if self._should_sync and managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_revive_pumpkin_destroyed", self._unit)
	end
end

function RevivePumpkinExt:set_should_sync(should_sync)
	self._should_sync = should_sync
end
