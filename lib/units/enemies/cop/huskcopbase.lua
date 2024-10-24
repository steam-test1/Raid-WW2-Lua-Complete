HuskCopBase = HuskCopBase or class(CopBase)

function HuskCopBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self:set_anim_lod(1)

	self._lod_stage = 1

	if managers.navigation:is_data_ready() then
		self:_do_post_init()
	else
		Application:debug("[HuskCopBase:post_init()] Navigation not ready! Queue cop post_init method.", inspect(managers.navigation._nav_segments))

		self._nav_ready_listener_key = "HuskCopBase" .. tostring(self._unit:key())

		managers.navigation:add_listener(self._nav_ready_listener_key, {
			"navigation_ready"
		}, callback(self, self, "_do_post_init"))
	end
end

function HuskCopBase:_do_post_init()
	Application:debug("[HuskCopBase:post_init()] Navigation READY!", self._nav_ready_listener_key)
	self._ext_movement:post_init()
	self._unit:brain():post_init()
	managers.enemy:register_enemy(self._unit)
	self:_init_spawn_gear()

	if self._nav_ready_listener_key then
		managers.navigation:remove_listener(self._nav_ready_listener_key)
	end
end

function HuskCopBase:pre_destroy(unit)
	self:_clear_spawn_gear()
	UnitBase.pre_destroy(self, unit)
end
