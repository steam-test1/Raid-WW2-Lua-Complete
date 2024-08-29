BarrageTweakData = BarrageTweakData or class()
BarrageType = {
	ARTILLERY = 1,
	AIRPLANE = 2,
	RANDOM = 3
}

-- Lines 13-180
function BarrageTweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	self.default = {
		type = BarrageType.ARTILLERY,
		direction = Vector3(-0.33, 0, -0.33),
		distance = 16000,
		projectile_id = "mortar_shell",
		lauch_power = 36,
		area_radius = {
			1200,
			1000,
			900
		},
		cooldown = {
			140,
			130,
			120
		},
		initial_delay = 3.5,
		barrage_launch_sound_delay = 3.5,
		barrage_launch_sound_event = "grenade_launcher"
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.default.projectiles_per_minute = {
			30,
			30,
			30
		}
		self.flare_timer = 15
		self.default.duration = {
			10,
			15,
			20
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.default.projectiles_per_minute = {
			30,
			35,
			40
		}
		self.flare_timer = 12
		self.default.duration = {
			10,
			15,
			20
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.default.projectiles_per_minute = {
			30,
			40,
			45
		}
		self.flare_timer = 10
		self.default.duration = {
			12,
			17,
			22
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.default.projectiles_per_minute = {
			35,
			40,
			50
		}
		self.flare_timer = 8
		self.default.duration = {
			14,
			19,
			24
		}
	end

	self.blimp_barrage = deep_clone(self.default)
	self.blimp_barrage.launch_from = "blimp"
	self.blimp_barrage.direction = nil
	self.blimp_barrage.area_radius = {
		1000,
		600,
		1200
	}
	self.blimp_barrage.lauch_power = 35
	self.blimp_barrage.projectiles_per_minute = {
		90,
		100,
		120
	}
	self.blimp_barrage.duration = {
		30,
		30,
		30
	}
	self.blimp_barrage.initial_delay = 1
	self.blimp_barrage.barrage_launch_sound_delay = 0.1
	self.spotted_arty = clone(self.default)
	self.spotted_arty.direction = Vector3(0, 0, -1)
	self.spotted_arty.spotting_rounds = 0
	self.spotted_arty.area_radius = {
		900,
		700,
		800
	}
	self.spotted_arty.spotting_rounds_delay = 5
	self.spotted_arty.spotting_rounds_min_distance = 1000
	self.spotted_arty.initial_delay = 0
	self.spotted_arty.cooldown = {
		60,
		40,
		20
	}
	self.spotted_arty.barrage_launch_sound_delay = 7.5
	self.spotted_arty.barrage_launch_sound_event = "grenade_launcher"
	self.stuka_strafe = {
		type = BarrageType.AIRPLANE,
		airplane_unit = Idstring("units/vanilla/vehicles/vhc_junkers_attack/vhc_junkers_attack"),
		sequence_name = "anim_machinegun_attack",
		cooldown = {
			5,
			4,
			3
		}
	}
	self.stuka_bomb = {
		type = BarrageType.AIRPLANE,
		airplane_unit = Idstring("units/vanilla/vehicles/vhc_junkers_ju87_anim/vhc_junkers_ju87_anim"),
		sequence_name = "anim_drop_bomb",
		cooldown = {
			30,
			20,
			10
		}
	}
	self.napalm = {
		type = BarrageType.ARTILLERY,
		direction = Vector3(0, 0, -1),
		area_radius = {
			1500,
			1200,
			1000
		},
		projectile_id = "molotov",
		lauch_power = 20,
		duration = {
			10,
			12,
			15
		},
		projectiles_per_minute = {
			90,
			100,
			120
		},
		cooldown = {
			15,
			12.5,
			10
		},
		initial_delay = 8,
		barrage_launch_sound_delay = 7.5,
		barrage_launch_sound_event = "grenade_launcher"
	}
	self.cluster = {
		type = BarrageType.ARTILLERY,
		direction = Vector3(0, 0, -1),
		area_radius = {
			900,
			700,
			800
		},
		projectile_id = "mortar_shell",
		lauch_power = 15,
		duration = {
			20,
			25,
			30
		},
		projectiles_per_minute = {
			70,
			70,
			75
		},
		cooldown = {
			45,
			30,
			20
		},
		initial_delay = 8,
		barrage_launch_sound_delay = 7.5,
		barrage_launch_sound_event = "grenade_launcher"
	}
	self.random = {
		type = BarrageType.RANDOM,
		type_table = {
			cluster = {
				4,
				5,
				8
			},
			stuka_bomb = {
				8,
				4,
				2
			}
		}
	}
end

-- Lines 183-192
function BarrageTweakData:get_barrage_ids()
	local t = {}

	for id, _ in pairs(tweak_data.barrage) do
		if type(tweak_data.barrage[id]) == "table" then
			table.insert(t, id)
		end
	end

	table.sort(t)

	return t
end
