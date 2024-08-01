Pickup = Pickup or class()
Pickup.PATH = "to be removed"

-- Lines 5-20
function Pickup:init(unit)
	if not Network:is_server() and unit:slot() == 23 then
		unit:set_slot(20)
	end

	self._unit = unit
	self._beaming = self.beaming or false
	self._automatic_pickup = self.automatic_pickup or false
	self._active = true
	local material = self._unit:material(Idstring("mat_effect"))

	if material then
		Pickup.randomize_glow_effect(material)
	end
end

-- Lines 23-32
function Pickup.randomize_glow_effect(material)
	local ids_uv0_offset = Idstring("uv0_offset")
	local ids_uv0_speed = Idstring("uv0_speed")
	local r = math.random()

	material:set_variable(ids_uv0_offset, Vector3(r, r, r))

	r = math.rand(0.2, 0.4)

	material:set_variable(ids_uv0_speed, Vector3(r, r, r))
end

-- Lines 34-36
function Pickup:sync_pickup()
	self:consume()
end

-- Lines 38-40
function Pickup:_pickup()
	Application:error("Pickup didn't have a _pickup() function!")
end

-- Lines 42-48
function Pickup:pickup(unit)
	if not self._active then
		return
	end

	return self:_pickup(unit)
end

-- Lines 50-52
function Pickup:consume()
	self:delete_unit()
end

-- Lines 54-56
function Pickup:set_active(active)
	self._active = active
end

-- Lines 59-64
function Pickup:delete_unit()
	if Network:is_server() then
		managers.drop_loot:despawn_item(self._unit)
	end

	self._unit:set_slot(0)
end

-- Lines 66-70
function Pickup:save(data)
	local state = {
		active = self._active
	}
	data.Pickup = state
end

-- Lines 72-77
function Pickup:load(data)
	local state = data.Pickup

	if state then
		self:set_active(state.active)
	end
end

-- Lines 79-80
function Pickup:sync_net_event(event, peer)
end

-- Lines 82-83
function Pickup:destroy(unit)
end

-- Lines 85-87
function Pickup:get_automatic_pickup()
	return self._automatic_pickup
end

-- Lines 89-91
function Pickup:get_pickup_type()
	return nil
end
