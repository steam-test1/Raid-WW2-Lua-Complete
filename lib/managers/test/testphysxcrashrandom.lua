TestPhysXCrashRandom = TestPhysXCrashRandom or class()
TestPhysXCrashRandom.PERIOD_BETWEEN_SPAWNS = 3

local timer = 0
local testing_active = true

function TestPhysXCrashRandom:init()
	timer = TestPhysXCrashRandom.PERIOD_BETWEEN_SPAWNS
	testing_active = true
end

function TestPhysXCrashRandom:update(t, dt)
	self:randomCrash(t, dt)
end

function TestPhysXCrashRandom:toggleTest()
	testing_active = not testing_active
end

function TestPhysXCrashRandom:randomCrash(t, dt)
	if testing_active == true then
		if timer < 0 then
			managers.test.utils:spawn_enemy_on_graph()

			timer = TestPhysXCrashRandom.PERIOD_BETWEEN_SPAWNS
		else
			managers.test.utils:spawn_projectile_on_graph()

			timer = timer - dt
		end
	end
end
