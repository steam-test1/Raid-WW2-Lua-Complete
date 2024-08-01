RevivePumpkinExt = RevivePumpkinExt or class()
local idstr_pumpkin_asset = Idstring("revive_pumpkin")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")

-- Lines 9-42
function RevivePumpkinExt:init(unit)
	self._unit = unit
	self._should_sync = true

	self._unit:set_extension_update_enabled(idstr_pumpkin_asset, false)

	self._listener_key_enter = "revive_pumpkin_enter" .. tostring(unit:key())
	self._listener_key_exit = "revive_pumpkin_exit" .. tostring(unit:key())

	if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_NO_BLEEDOUT_PUMPIKIN_REVIVE) and Network:is_server() then
		if not Application:editor() then
			self._unit:set_slot(0)
		end
	end

	managers.system_event_listener:add_listener(self._listener_key_enter, {
		PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN
	}, callback(self, self, "local_player_enter_resapwn"))
	managers.system_event_listener:add_listener(self._listener_key_exit, {
		PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN
	}, callback(self, self, "local_player_exit_resapwn"))

	self._materials = {}
	local all_materials = self._unit:get_objects_by_type(IDS_MATERIAL)

	for _, m in ipairs(all_materials) do
		if m:variable_exists(idstr_contour_color) then
			table.insert(self._materials, m)

			local cont_color = tweak_data.contour[self.contour or "interactable"]
			cont_color = cont_color.standard_color or Vector3(0, 0, 0)

			m:set_variable(idstr_contour_color, cont_color)
			m:set_variable(idstr_contour_opacity, 0)
		end
	end
end

-- Lines 45-59
function RevivePumpkinExt:local_player_enter_resapwn(level)
	if self._unit:damage():has_sequence("local_show") then
		self._unit:damage():run_sequence("local_show")
	end

	for _, m in ipairs(self._materials) do
		m:set_variable(idstr_contour_opacity, 1)
	end
end

-- Lines 62-76
function RevivePumpkinExt:local_player_exit_resapwn(level)
	if self._unit:damage():has_sequence("local_hide") then
		self._unit:damage():run_sequence("local_hide")
	end

	for _, m in ipairs(self._materials) do
		m:set_variable(idstr_contour_opacity, 0)
	end
end

-- Lines 79-88
function RevivePumpkinExt:destroy()
	managers.system_event_listener:remove_listener(self._listener_key_enter)
	managers.system_event_listener:remove_listener(self._listener_key_exit)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PUMPKIN_DESTROYED)

	if self._should_sync and managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_revive_pumpkin_destroyed", self._unit)
	end
end

-- Lines 91-93
function RevivePumpkinExt:set_should_sync(should_sync)
	self._should_sync = should_sync
end
