Pickup = Pickup or class()
Pickup.PATH = "to be removed"

function Pickup:init(unit)
	self._unit = unit
	self._beaming = self.beaming or false
	self._automatic_pickup = self.automatic_pickup or false
	self._active = true
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

function Pickup.randomize_glow_effect(material)
	local ids_uv0_offset = Idstring("uv0_offset")
	local ids_uv0_speed = Idstring("uv0_speed")
	local r = math.random()

	material:set_variable(ids_uv0_offset, Vector3(r, r, r))

	r = math.rand(0.2, 0.4)

	material:set_variable(ids_uv0_speed, Vector3(r, r, r))
end

function Pickup:sync_pickup()
	if not self._picked_up then
		self._picked_up = true

		self:consume()
	end
end

function Pickup:_pickup(unit)
	Application:error("Pickup didn't have a _pickup() function!")
end

function Pickup:pickup(unit)
	if not self._active then
		return
	end

	return self:_pickup(unit)
end

function Pickup:consume()
	if self._unit:interaction() then
		self._unit:interaction():set_active(false)
	end

	self._unit:set_enabled(false)
	self:delete_unit()
end

function Pickup:set_active(active)
	self._active = active
end

function Pickup:delete_unit()
	if Network:is_server() then
		managers.drop_loot:despawn_item(self._unit)
	end
end

function Pickup:despawn_item()
	if Network:is_server() then
		self._unit:set_slot(0)
	end
end

function Pickup:save(data)
	local state = {
		active = self._active
	}
	data.Pickup = state
end

function Pickup:load(data)
	local state = data.Pickup

	if state then
		self:set_active(state.active)
	end
end

function Pickup:sync_net_event(event, peer)
end

function Pickup:destroy(unit)
end

function Pickup:get_automatic_pickup()
	return self._automatic_pickup
end

function Pickup:get_pickup_type()
	return nil
end
