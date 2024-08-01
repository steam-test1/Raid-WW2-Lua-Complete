GroupAIRaidTweakData = GroupAIRaidTweakData or class()

-- Lines 3-225
function GroupAIRaidTweakData:init(difficulty_index)
	Application:debug("[GroupAITweakData:init] Mode: Raid, difficulty_index", difficulty_index)

	self.regroup = {}
	self.assault = {
		force = {}
	}
	self.reenforce = {}
	self.recon = {}
	self.rescue = {}
	self.cloaker = {}
	self.max_spawning_distance = 15000
	self.min_spawning_distance = 700
	self.max_spawning_height_diff = 1440000
	self.max_distance_to_player = 100000000
	self.recurring_group_SO = {
		recurring_spawn_1 = {
			interval = {
				30,
				60
			}
		}
	}
	self.regroup.duration = {
		15,
		15,
		15
	}
	self.assault = {
		anticipation_duration = {
			{
				15,
				1
			},
			{
				15,
				1
			},
			{
				15,
				1
			}
		},
		build_duration = 15,
		sustain_duration_min = {
			100,
			120,
			140
		},
		sustain_duration_max = {
			120,
			140,
			160
		},
		sustain_duration_balance_mul = {
			1,
			1.1,
			1.15,
			1.25
		},
		fade_duration = 10,
		enemy_low_limit = 7,
		task_timeout = 20,
		drama_timeout = 35
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.delay = {
			30,
			30,
			28
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.delay = {
			30,
			28,
			25
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.delay = {
			27,
			23,
			20
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.delay = {
			25,
			20,
			15
		}
	end

	self.assault.hostage_hesitation_delay = {
		0,
		0,
		0
	}
	self.assault.force = {
		8,
		12,
		15,
		18
	}
	self.assault.force_pool = {
		55,
		60,
		65,
		70
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.force_balance_mul = {
			0.9,
			1,
			1.12,
			1.15
		}
		self.assault.force_pool_balance_mul = {
			0.9,
			1,
			1.12,
			1.15
		}
		self.assault.push_delay = {
			6.5,
			4.5,
			3.5,
			3
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.force_balance_mul = {
			1,
			1.12,
			1.2,
			1.23
		}
		self.assault.force_pool_balance_mul = {
			1,
			1.12,
			1.2,
			1.23
		}
		self.assault.push_delay = {
			6.5,
			4.5,
			3.5,
			3
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.force_balance_mul = {
			1.04,
			1.12,
			1.22,
			1.24
		}
		self.assault.force_pool_balance_mul = {
			1.04,
			1.12,
			1.22,
			1.24
		}
		self.assault.push_delay = {
			6.25,
			4.25,
			3.25,
			2.75
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.force_balance_mul = {
			1.07,
			1.14,
			1.23,
			1.25
		}
		self.assault.force_pool_balance_mul = {
			1.07,
			1.14,
			1.23,
			1.25
		}
		self.assault.push_delay = {
			6,
			4,
			3,
			2.5
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.groups = {
			grunt_flankers = {
				75,
				75,
				75
			},
			grunt_chargers = {
				75,
				80,
				0
			},
			grunt_support_range = {
				40,
				40,
				40
			},
			gerbish_chargers = {
				40,
				75,
				75
			},
			gerbish_rifle_range = {
				30,
				40,
				30
			},
			gerbish_flankers = {
				30,
				75,
				75
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.groups = {
			grunt_flankers = {
				75,
				75,
				75
			},
			grunt_chargers = {
				75,
				80,
				0
			},
			grunt_support_range = {
				40,
				40,
				40
			},
			gerbish_chargers = {
				40,
				75,
				75
			},
			gerbish_rifle_range = {
				30,
				40,
				30
			},
			gerbish_flankers = {
				30,
				75,
				75
			},
			flamethrower = {
				1,
				2,
				4
			},
			commanders = {
				0,
				1,
				2
			},
			commander_squad = {
				0,
				25,
				35
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.groups = {
			gerbish_chargers = {
				75,
				75,
				30
			},
			gerbish_rifle_range = {
				40,
				40,
				20
			},
			gerbish_flankers = {
				75,
				75,
				30
			},
			fallschirm_charge = {
				30,
				75,
				75
			},
			fallschirm_support = {
				0,
				40,
				40
			},
			fallschirm_flankers = {
				0,
				75,
				75
			},
			flamethrower = {
				5,
				8,
				10
			},
			commanders = {
				1,
				3,
				5
			},
			commander_squad = {
				30,
				45,
				60
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.groups = {
			fallschirm_charge = {
				75,
				75,
				40
			},
			fallschirm_support = {
				40,
				40,
				30
			},
			fallschirm_flankers = {
				75,
				75,
				40
			},
			ss_flankers = {
				30,
				75,
				75
			},
			ss_rifle_range = {
				0,
				40,
				75
			},
			ss_chargers = {
				30,
				75,
				75
			},
			flamethrower = {
				8,
				10,
				13
			},
			commanders = {
				1,
				4,
				6
			},
			commander_squad = {
				60,
				70,
				80
			}
		}
	end

	self.reenforce.interval = {
		10,
		15,
		20,
		30
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.reenforce.groups = {
			grunt_flankers = {
				40,
				40,
				40
			},
			grunt_chargers = {
				50,
				50,
				50
			},
			grunt_support_range = {
				40,
				40,
				40
			},
			gerbish_chargers = {
				30,
				30,
				30
			},
			gerbish_rifle_range = {
				20,
				20,
				20
			},
			gerbish_flankers = {
				20,
				20,
				20
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.reenforce.groups = {
			grunt_flankers = {
				20,
				20,
				20
			},
			grunt_chargers = {
				30,
				30,
				30
			},
			grunt_support_range = {
				20,
				20,
				20
			},
			gerbish_chargers = {
				50,
				50,
				50
			},
			gerbish_rifle_range = {
				40,
				40,
				40
			},
			gerbish_flankers = {
				40,
				40,
				40
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.reenforce.groups = {
			gerbish_chargers = {
				30,
				30,
				30
			},
			gerbish_rifle_range = {
				20,
				20,
				20
			},
			gerbish_flankers = {
				20,
				20,
				20
			},
			fallschirm_charge = {
				50,
				50,
				50
			},
			fallschirm_support = {
				40,
				40,
				40
			},
			fallschirm_flankers = {
				40,
				40,
				40
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.reenforce.groups = {
			fallschirm_charge = {
				30,
				30,
				30
			},
			fallschirm_support = {
				20,
				20,
				20
			},
			fallschirm_flankers = {
				20,
				20,
				20
			},
			ss_flankers = {
				40,
				40,
				40
			},
			ss_rifle_range = {
				40,
				40,
				40
			},
			ss_chargers = {
				50,
				50,
				50
			}
		}
	end

	self.recon.interval = {
		5,
		5,
		5
	}
	self.recon.interval_variation = 40
	self.recon.force = {
		2,
		4,
		6
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.recon.groups = {
			grunt_flankers = {
				10,
				10,
				10
			},
			grunt_chargers = {
				10,
				10,
				10
			},
			grunt_support_range = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.recon.groups = {
			grunt_flankers = {
				10,
				10,
				10
			},
			grunt_chargers = {
				10,
				10,
				10
			},
			grunt_support_range = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.recon.groups = {
			gerbish_chargers = {
				10,
				10,
				10
			},
			gerbish_rifle_range = {
				10,
				10,
				10
			},
			gerbish_flankers = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.recon.groups = {
			fallschirm_charge = {
				10,
				10,
				10
			},
			fallschirm_support = {
				10,
				10,
				10
			},
			fallschirm_flankers = {
				10,
				10,
				10
			}
		}
	end
end
