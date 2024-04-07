TestPhysXCrash = TestPhysXCrash or class()
TestPhysXCrash.testPositions = {
	Vector3(1506, -1225, 22.7375),
	Vector3(-5533.26, -2864.1, 537.501),
	Vector3(1751.39, -2134.46, 68.5001),
	Vector3(-841.854, -1704.87, 90.1195),
	Vector3(2381.24, 2805.92, 2234.12),
	Vector3(5721.93, -2210.52, 68.5001),
	Vector3(-4601.63, -5450.82, 137.75),
	Vector3(989.35, -1742.43, 37.3692),
	Vector3(-1686.51, -272.814, 222.044),
	Vector3(537.232, -2294.28, 428.336),
	Vector3(1912.01, -3619.06, 61.4985),
	Vector3(-661.549, -1700.14, 37.1985),
	Vector3(6172.45, -86.1826, 38.4998),
	Vector3(-1967.56, -3135.17, 138.751),
	Vector3(5996.02, -2469.51, 70.2581)
}

local counter = 1

function TestPhysXCrash:init()
	counter = 1
end

function TestPhysXCrash:update(t, dt)
	self:hardcodeCrash(t, dt)
end

function TestPhysXCrash:toggleTest()
	counter = 1
end

function TestPhysXCrash:hardcodeCrash(t, dt)
	if counter < #TestPhysXCrash.testPositions + 1 then
		managers.test.utils:spawn_projectile_at_pos(TestPhysXCrash.testPositions[counter])

		counter = counter + 1
	end
end
