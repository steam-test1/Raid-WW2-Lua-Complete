GroupAIRaidTweakData = GroupAIRaidTweakData or class()

-- Lines 3-370
function GroupAIRaidTweakData:init(difficulty_index)
	local is_console = SystemInfo:platform() ~= Idstring("WIN32")
	self.regroup = {}
	self.assault = {
		force = {}
	}
	self.reenforce = {}
	self.recon = {}
	self.rescue = {}
	self.cloaker = {}
	self.max_spawning_distance = 8000
	self.min_spawning_distance = 1500
	self.max_spawning_height_diff = 700

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.recurring_group_SO = {
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.recurring_group_SO = {
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.recurring_group_SO = {
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.recurring_group_SO = {
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	else
		debug_pause("[GroupAIRaidTweakData:init] Unknown difficulty_index", difficulty_index)
	end

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
			60,
			100,
			140
		},
		sustain_duration_max = {
			90,
			120,
			160
		},
		sustain_duration_balance_mul = {
			1,
			1.1,
			1.2,
			1.3
		},
		fade_duration = 5
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.delay = {
			40,
			35,
			30
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.delay = {
			40,
			30,
			20
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.delay = {
			35,
			25,
			25
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.delay = {
			30,
			20,
			10
		}
	end

	self.assault.hostage_hesitation_delay = {
		0,
		0,
		0
	}

	if is_console then
		self.assault.force = {
			0,
			4,
			7
		}
		self.assault.force_pool = {
			0,
			60,
			100
		}
	else
		self.assault.force = {
			12,
			13,
			15
		}
		self.assault.force_pool = {
			100,
			125,
			175
		}
	end

	if is_console then
		if difficulty_index <= TweakData.DIFFICULTY_1 then
			self.assault.force_balance_mul = {
				1,
				1.1,
				1.2,
				1.3
			}
			self.assault.force_pool_balance_mul = {
				1,
				1.1,
				1.2,
				1.3
			}
		elseif difficulty_index == TweakData.DIFFICULTY_2 then
			self.assault.force_balance_mul = {
				1.2,
				1.4,
				1.6,
				1.8
			}
			self.assault.force_pool_balance_mul = {
				1.2,
				1.4,
				1.6,
				1.8
			}
		elseif difficulty_index == TweakData.DIFFICULTY_3 then
			self.assault.force_balance_mul = {
				1.6,
				1.8,
				2,
				2.2
			}
			self.assault.force_pool_balance_mul = {
				1.7,
				2,
				2.2,
				2.4
			}
		elseif difficulty_index == TweakData.DIFFICULTY_4 then
			self.assault.force_balance_mul = {
				1.8,
				2.1,
				2.4,
				2.8
			}
			self.assault.force_pool_balance_mul = {
				2.2,
				2.4,
				2.6,
				2.8
			}
		else
			self.assault.force_balance_mul = {
				1,
				4.2,
				4.5,
				4.9
			}
			self.assault.force_pool_balance_mul = {
				3,
				5,
				7,
				9
			}
		end
	elseif difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.force_balance_mul = {
			0.7,
			1,
			1.3,
			1.7
		}
		self.assault.force_pool_balance_mul = {
			0.5,
			0.65,
			0.7,
			0.9
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.force_balance_mul = {
			0.8,
			1.1,
			1.4,
			1.8
		}
		self.assault.force_pool_balance_mul = {
			0.6,
			1,
			1.4,
			1.8
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.force_balance_mul = {
			1.1,
			1.7,
			2.2,
			2.7
		}
		self.assault.force_pool_balance_mul = {
			1.2,
			1.7,
			2.2,
			2.7
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.force_balance_mul = {
			2,
			2.25,
			3,
			4
		}
		self.assault.force_pool_balance_mul = {
			1.8,
			2.8,
			3.3,
			3.8
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.groups = {
			grunt_flankers = {
				50,
				50,
				50
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
				0,
				50,
				50
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				50
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				0,
				0,
				1
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.groups = {
			grunt_flankers = {
				50,
				50,
				50
			},
			grunt_chargers = {
				50,
				60,
				0
			},
			grunt_support_range = {
				40,
				40,
				40
			},
			gerbish_chargers = {
				40,
				50,
				50
			},
			gerbish_rifle_range = {
				30,
				40,
				30
			},
			gerbish_flankers = {
				30,
				50,
				50
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				1,
				1,
				2
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.groups = {
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
			},
			gerbish_chargers = {
				50,
				50,
				30
			},
			gerbish_rifle_range = {
				40,
				40,
				20
			},
			gerbish_flankers = {
				50,
				50,
				30
			},
			fallschirm_charge = {
				30,
				50,
				50
			},
			fallschirm_support = {
				0,
				40,
				40
			},
			fallschirm_flankers = {
				0,
				50,
				50
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				9,
				12,
				15
			},
			commanders = {
				3,
				6,
				9
			},
			commander_squad = {
				60,
				60,
				60
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.groups = {
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
			},
			gerbish_chargers = {
				0,
				0,
				0
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				0
			},
			fallschirm_charge = {
				50,
				50,
				40
			},
			fallschirm_support = {
				40,
				40,
				30
			},
			fallschirm_flankers = {
				50,
				50,
				40
			},
			ss_flankers = {
				30,
				50,
				50
			},
			ss_rifle_range = {
				0,
				40,
				50
			},
			ss_chargers = {
				30,
				50,
				50
			},
			flamethrower = {
				15,
				18,
				20
			},
			commanders = {
				15,
				18,
				20
			},
			commander_squad = {
				60,
				60,
				60
			}
		}
	end

	self.reenforce.interval = {
		10,
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
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
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
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.reenforce.groups = {
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
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
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.reenforce.groups = {
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
			},
			gerbish_chargers = {
				0,
				0,
				0
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				0
			},
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

	if difficulty_index < 6 then
		self.recon.force = {
			2,
			4,
			6
		}
	else
		self.recon.force = {
			3,
			4,
			6
		}
	end

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
			},
			gerbish_chargers = {
				0,
				0,
				0
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				0
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				0,
				0,
				0
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
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
			},
			gerbish_chargers = {
				0,
				0,
				0
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				0
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				0,
				0,
				0
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.recon.groups = {
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
			},
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
			},
			fallschirm_charge = {
				0,
				0,
				0
			},
			fallschirm_support = {
				0,
				0,
				0
			},
			fallschirm_flankers = {
				0,
				0,
				0
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				0,
				0,
				0
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.recon.groups = {
			grunt_flankers = {
				0,
				0,
				0
			},
			grunt_chargers = {
				0,
				0,
				0
			},
			grunt_support_range = {
				0,
				0,
				0
			},
			gerbish_chargers = {
				0,
				0,
				0
			},
			gerbish_rifle_range = {
				0,
				0,
				0
			},
			gerbish_flankers = {
				0,
				0,
				0
			},
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
			},
			ss_flankers = {
				0,
				0,
				0
			},
			ss_rifle_range = {
				0,
				0,
				0
			},
			ss_chargers = {
				0,
				0,
				0
			},
			flamethrower = {
				0,
				0,
				0
			},
			commanders = {
				0,
				0,
				0
			},
			commander_squad = {
				0,
				0,
				0
			}
		}
	end
end
