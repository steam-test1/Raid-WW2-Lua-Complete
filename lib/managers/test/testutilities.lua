TestUtilities = TestUtilities or class()

-- Lines 10-11
function TestUtilities:init()
end

-- Lines 13-18
function TestUtilities:spawn_projectile_at_pos(trgt_pos)
	local barrage_params = managers.barrage:_prepare_barrage_params(clone(managers.barrage.default_params))
	local pos = trgt_pos

	Application:trace("TestUtilities   !!!!!!!!!!!!!!!!!!!!!!!!!!!!    Spawned proj at: " .. pos)
	ProjectileBase.throw_projectile(barrage_params.projectile_index, pos, barrage_params.direction * barrage_params.lauch_power)
end

-- Lines 20-23
function TestUtilities:spawn_projectile_on_graph()
	local pos = managers.navigation:HACK_get_random_point_on_graph()

	self:spawn_projectile_at_pos(pos)
end

-- Lines 25-32
function TestUtilities:spawn_enemy_at_pos(trgt_pos)
	local position = trgt_pos
	local rot = Rotation(managers.viewport:get_current_camera_rotation():y():with_z(0), math.UP)
	local unit = World:spawn_unit(Idstring("units/vanilla/characters/enemies/models/german_commander/german_commander"), position, rot)

	Application:trace("TestUtilities  !!!!!!!!!!!!!!!!!!!!!!!!!!!   Spawned enemy at: " .. position)
	managers.groupai:state():assign_enemy_to_group_ai(unit, "law1")
end

-- Lines 34-39
function TestUtilities:spawn_enemy_on_graph()
	local position = managers.navigation:HACK_get_random_point_on_graph()

	self:spawn_enemy_at_pos(position)
end

-- Lines 42-45
function TestUtilities:get_random_seg_id_on_test_range()
	local seg_id = tostring(world_id) .. "_" .. tostring(TestUtilities.SEG_IDS[math.random(#TestUtilities.SEG_IDS)])

	return seg_id
end
