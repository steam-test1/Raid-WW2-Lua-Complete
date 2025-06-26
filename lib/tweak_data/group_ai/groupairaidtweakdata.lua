GroupAIRaidTweakData = GroupAIRaidTweakData or class()

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
	self.max_important_distance = 9000000
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

	self.assault.charge_wait_in_place = {
		4,
		10
	}
	self.assault.force = {
		14,
		16,
		18,
		20
	}
	self.assault.force_pool = {
		55,
		60,
		68,
		74
	}
	self.assault.push_delay = {
		4,
		4,
		3.5,
		3
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.force_balance_mul = {
			0.9,
			1,
			1.17,
			1.32
		}
		self.assault.force_pool_balance_mul = {
			0.9,
			1,
			1.17,
			1.32
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.force_balance_mul = {
			1,
			1.13,
			1.28,
			1.4
		}
		self.assault.force_pool_balance_mul = {
			1,
			1.13,
			1.28,
			1.4
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.force_balance_mul = {
			1.04,
			1.14,
			1.33,
			1.55
		}
		self.assault.force_pool_balance_mul = {
			1.04,
			1.14,
			1.33,
			1.55
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.force_balance_mul = {
			1.07,
			1.16,
			1.4,
			1.7
		}
		self.assault.force_pool_balance_mul = {
			1.07,
			1.16,
			1.4,
			1.7
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.groups = {
			grunt_flankers = {
				25,
				22,
				20
			},
			grunt_chargers = {
				25,
				22,
				20
			},
			grunt_support_range = {
				25,
				22,
				20
			},
			gerbish_flankers = {
				15,
				18,
				20
			},
			gerbish_chargers = {
				15,
				18,
				20
			},
			gerbish_rifle_range = {
				15,
				18,
				20
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.groups = {
			grunt_flankers = {
				25,
				22,
				20
			},
			grunt_chargers = {
				25,
				22,
				20
			},
			grunt_support_range = {
				25,
				22,
				20
			},
			gerbish_flankers = {
				15,
				18,
				20
			},
			gerbish_chargers = {
				15,
				18,
				20
			},
			gerbish_rifle_range = {
				15,
				18,
				20
			},
			flamethrower = {
				2,
				4,
				6
			},
			commanders = {
				0,
				2,
				3
			},
			commander_squad = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.groups = {
			gerbish_flankers = {
				25,
				22,
				20
			},
			gerbish_chargers = {
				25,
				22,
				20
			},
			gerbish_rifle_range = {
				25,
				22,
				20
			},
			fallschirm_flankers = {
				15,
				18,
				20
			},
			fallschirm_charge = {
				15,
				18,
				20
			},
			fallschirm_support = {
				15,
				18,
				20
			},
			flamethrower = {
				3,
				5,
				7
			},
			commanders = {
				1,
				4,
				6
			},
			commander_squad = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.groups = {
			fallschirm_flankers = {
				25,
				22,
				20
			},
			fallschirm_charge = {
				25,
				22,
				20
			},
			fallschirm_support = {
				25,
				22,
				20
			},
			ss_flankers = {
				15,
				18,
				20
			},
			ss_chargers = {
				15,
				18,
				20
			},
			ss_rifle_range = {
				15,
				18,
				20
			},
			flamethrower = {
				4,
				6,
				8
			},
			commanders = {
				2,
				6,
				8
			},
			commander_squad = {
				10,
				10,
				10
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
				25,
				22,
				20
			},
			grunt_chargers = {
				25,
				22,
				20
			},
			grunt_support_range = {
				25,
				22,
				20
			},
			gerbish_chargers = {
				15,
				18,
				20
			},
			gerbish_rifle_range = {
				15,
				18,
				20
			},
			gerbish_flankers = {
				15,
				18,
				20
			},
			commander_squad = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.reenforce.groups = {
			grunt_flankers = {
				25,
				22,
				20
			},
			grunt_chargers = {
				25,
				22,
				20
			},
			grunt_support_range = {
				25,
				22,
				20
			},
			gerbish_chargers = {
				15,
				18,
				20
			},
			gerbish_rifle_range = {
				15,
				18,
				20
			},
			gerbish_flankers = {
				15,
				18,
				20
			},
			commander_squad = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.reenforce.groups = {
			gerbish_chargers = {
				25,
				22,
				20
			},
			gerbish_rifle_range = {
				25,
				22,
				20
			},
			gerbish_flankers = {
				25,
				22,
				20
			},
			fallschirm_charge = {
				15,
				18,
				20
			},
			fallschirm_support = {
				15,
				18,
				20
			},
			fallschirm_flankers = {
				15,
				18,
				20
			},
			commander_squad = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.reenforce.groups = {
			fallschirm_charge = {
				25,
				22,
				20
			},
			fallschirm_support = {
				25,
				22,
				20
			},
			fallschirm_flankers = {
				25,
				22,
				20
			},
			ss_flankers = {
				15,
				18,
				20
			},
			ss_rifle_range = {
				15,
				18,
				20
			},
			ss_chargers = {
				15,
				18,
				20
			},
			commander_squad = {
				10,
				10,
				10
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
