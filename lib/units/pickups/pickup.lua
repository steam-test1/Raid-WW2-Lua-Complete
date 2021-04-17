Pickup = Pickup or class()

-- Lines 3-12
function Pickup:init(unit)
	if not Network:is_server() and unit:slot() == 23 then
		unit:set_slot(20)
	end

	self._unit = unit
	self._active = true
end

local ids_mat_effect = Idstring("mat_effect")
local ids_uv0_offset = Idstring("uv0_offset")

-- Lines 17-22
function Pickup:_randomize_glow_effect()
	local material = self._unit:material(ids_mat_effect)

	if material then
		material:set_variable(ids_uv0_offset, Vector3(0, math.random(), 0))
	end
end

-- Lines 24-26
function Pickup:sync_pickup()
	self:consume()
end

-- Lines 28-30
function Pickup:_pickup()
	Application:error("Pickup didn't have a _pickup() function!")
end

-- Lines 32-38
function Pickup:pickup(unit)
	if not self._active then
		return
	end

	return self:_pickup(unit)
end

-- Lines 40-42
function Pickup:consume()
	self:delete_unit()
end

-- Lines 44-46
function Pickup:set_active(active)
	self._active = active
end

-- Lines 48-50
function Pickup:delete_unit()
	World:delete_unit(self._unit)
end

-- Lines 52-56
function Pickup:save(data)
	local state = {
		active = self._active
	}
	data.Pickup = state
end

-- Lines 58-63
function Pickup:load(data)
	local state = data.Pickup

	if state then
		self:set_active(state.active)
	end
end

-- Lines 65-66
function Pickup:sync_net_event(event, peer)
end

-- Lines 68-69
function Pickup:destroy(unit)
end

-- Lines 71-73
function Pickup:get_pickup_type()
	return nil
end
