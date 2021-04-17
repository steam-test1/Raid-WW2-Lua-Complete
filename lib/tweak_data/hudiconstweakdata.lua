HudIconsTweakData = HudIconsTweakData or class()

-- Lines 33-659
function HudIconsTweakData:init()
	self.scroll_up = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			0,
			0,
			15,
			18
		}
	}
	self.scroll_dn = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			15,
			0,
			15,
			18
		}
	}
	self.scrollbar = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			30,
			0,
			15,
			32
		}
	}
	self.icon_buy = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			16,
			16,
			16
		}
	}
	self.icon_repair = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			0,
			16,
			16
		}
	}
	self.icon_addon = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			16,
			16,
			16
		}
	}
	self.icon_equipped = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			32,
			16,
			16
		}
	}
	self.icon_locked = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			0,
			16,
			16,
			16
		}
	}
	self.icon_circlebg = {
		texture = "guis/textures/scroll_items",
		texture_rect = {
			45,
			48,
			16,
			16
		}
	}
	self.icon_circlefill0 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			0,
			1,
			1
		}
	}
	self.icon_circlefill1 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			0,
			16,
			16
		}
	}
	self.icon_circlefill2 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			0,
			16,
			16
		}
	}
	self.icon_circlefill3 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			0,
			16,
			16
		}
	}
	self.icon_circlefill4 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			0,
			16,
			16
		}
	}
	self.icon_circlefill5 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			16,
			16,
			16
		}
	}
	self.icon_circlefill6 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			16,
			16,
			16
		}
	}
	self.icon_circlefill7 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			16,
			16,
			16
		}
	}
	self.icon_circlefill8 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			16,
			16,
			16
		}
	}
	self.icon_circlefill9 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			32,
			16,
			16
		}
	}
	self.icon_circlefill10 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			32,
			16,
			16
		}
	}
	self.icon_circlefill11 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			32,
			16,
			16
		}
	}
	self.icon_circlefill12 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			32,
			16,
			16
		}
	}
	self.icon_circlefill13 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			0,
			48,
			16,
			16
		}
	}
	self.icon_circlefill14 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			16,
			48,
			16,
			16
		}
	}
	self.icon_circlefill15 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			32,
			48,
			16,
			16
		}
	}
	self.icon_circlefill16 = {
		texture = "guis/textures/circlefill",
		texture_rect = {
			48,
			48,
			16,
			16
		}
	}
	self.fallback = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			0,
			32,
			32
		}
	}
	self.develop = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			192,
			48,
			48
		}
	}
	self.locked = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			144,
			48,
			48
		}
	}
	self.loading = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			96,
			32,
			32
		}
	}
	self.beretta92 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			0,
			48,
			48
		}
	}
	self.m4 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			0,
			48,
			48
		}
	}
	self.r870_shotgun = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			0,
			48,
			48
		}
	}
	self.mp5 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			0,
			48,
			48
		}
	}
	self.c45 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			0,
			48,
			48
		}
	}
	self.raging_bull = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			0,
			48,
			48
		}
	}
	self.mossberg = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			0,
			48,
			48
		}
	}
	self.hk21 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			0,
			48,
			48
		}
	}
	self.m14 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			0,
			48,
			48
		}
	}
	self.mac11 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			0,
			48,
			48
		}
	}
	self.glock = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			288,
			48,
			48
		}
	}
	self.ak = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			416,
			288,
			48,
			48
		}
	}
	self.m79 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			288,
			48,
			48
		}
	}
	self.wp_vial = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			310,
			32,
			32
		}
	}
	self.wp_standard = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			64,
			32,
			32
		}
	}
	self.wp_revive = {
		texture = "ui/ingame/textures/hud/hud_waypoint_icons_01",
		texture_rect = {
			320,
			0,
			32,
			32
		}
	}
	self.wp_rescue = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			96,
			32,
			32
		}
	}
	self.wp_trade = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			96,
			32,
			32
		}
	}
	self.wp_powersupply = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			242,
			32,
			32
		}
	}
	self.wp_watersupply = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			242,
			32,
			32
		}
	}
	self.wp_drill = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			242,
			32,
			32
		}
	}
	self.wp_hack = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			276,
			32,
			32
		}
	}
	self.wp_talk = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			276,
			32,
			32
		}
	}
	self.wp_c4 = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			242,
			32,
			32
		}
	}
	self.wp_crowbar = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			276,
			32,
			32
		}
	}
	self.wp_planks = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			276,
			32,
			32
		}
	}
	self.wp_door = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			310,
			32,
			32
		}
	}
	self.wp_saw = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			310,
			32,
			32
		}
	}
	self.wp_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			310,
			32,
			32
		}
	}
	self.wp_exit = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			310,
			32,
			32
		}
	}
	self.wp_can = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			2,
			344,
			32,
			32
		}
	}
	self.wp_target = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			36,
			344,
			32,
			32
		}
	}
	self.wp_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			70,
			344,
			32,
			32
		}
	}
	self.wp_winch = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			344,
			32,
			32
		}
	}
	self.wp_escort = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			138,
			344,
			32,
			32
		}
	}
	self.wp_powerbutton = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			172,
			344,
			32,
			32
		}
	}
	self.wp_server = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			206,
			344,
			32,
			32
		},
		texture_rect = {
			206,
			344,
			32,
			32
		}
	}
	self.wp_powercord = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			344,
			32,
			32
		}
	}
	self.wp_phone = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			144,
			32,
			32
		}
	}
	self.wp_scrubs = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			177,
			32,
			32
		}
	}
	self.wp_sentry = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			480,
			210,
			32,
			32
		}
	}
	self.wp_suspicious = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			0,
			0,
			32,
			32
		},
		texture_rect_over = {
			32,
			0,
			32,
			0
		}
	}
	self.wp_detected = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			64,
			0,
			32,
			32
		}
	}
	self.wp_investigating = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			0,
			48,
			32,
			16
		}
	}
	self.wp_aiming = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			0,
			32,
			32,
			16
		}
	}
	self.wp_calling_in = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			96,
			0,
			32,
			32
		}
	}
	self.wp_spotter_progress = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			0,
			0,
			32,
			32
		},
		texture_rect_over = {
			384,
			0,
			32,
			0
		}
	}
	self.wp_spotter_barrage = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			416,
			0,
			32,
			32
		}
	}
	self.equipment_trip_mine = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			96,
			48,
			48
		}
	}
	self.equipment_ammo_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			96,
			48,
			48
		}
	}
	self.equipment_doctor_bag = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			96,
			48,
			48
		}
	}
	self.equipment_ecm_jammer = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			272,
			288,
			48,
			48
		}
	}
	self.equipment_bank_manager_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			144,
			48,
			48
		}
	}
	self.equipment_chavez_key = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			96,
			48,
			48
		}
	}
	self.equipment_drill = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			96,
			48,
			48
		}
	}
	self.equipment_ejection_seat = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			144,
			48,
			48
		}
	}
	self.equipment_saw = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			144,
			48,
			48
		}
	}
	self.equipment_cutter = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			192,
			48,
			48
		}
	}
	self.equipment_hack_ipad = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			192,
			48,
			48
		}
	}
	self.equipment_gold = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			240,
			48,
			48
		}
	}
	self.equipment_thermite = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			96,
			48,
			48
		}
	}
	self.equipment_cable_ties = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			96,
			48,
			48
		}
	}
	self.equipment_bleed_out = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			144,
			48,
			48
		}
	}
	self.equipment_planks = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			288,
			48,
			48
		}
	}
	self.equipment_sentry = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			288,
			48,
			48
		}
	}
	self.equipment_stash_server = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			272,
			288,
			48,
			48
		}
	}
	self.equipment_vialOK = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			48,
			48,
			48
		}
	}
	self.equipment_vial = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			416,
			336,
			48,
			48
		}
	}
	self.interaction_free = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			48,
			192,
			48,
			48
		}
	}
	self.interaction_trade = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			144,
			48,
			48
		}
	}
	self.interaction_intimidate = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			192,
			48,
			48
		}
	}
	self.interaction_money_wrap = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			191,
			48,
			48
		}
	}
	self.interaction_christmas_present = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			144,
			240,
			48,
			48
		}
	}
	self.interaction_powerbox = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			288,
			48,
			48
		}
	}
	self.interaction_gold = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			384,
			240,
			48,
			48
		}
	}
	self.interaction_open_door = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			96,
			192,
			48,
			48
		}
	}
	self.interaction_diamond = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			432,
			240,
			48,
			48
		}
	}
	self.interaction_powercord = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			272,
			336,
			48,
			48
		}
	}
	self.interaction_help = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			192,
			192,
			48,
			48
		}
	}
	self.interaction_answerphone = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			336,
			48,
			48
		}
	}
	self.interaction_patientfile = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			336,
			48,
			48
		}
	}
	self.interaction_wirecutter = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			336,
			48,
			48
		}
	}
	self.interaction_elevator = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			464,
			384,
			48,
			48
		}
	}
	self.interaction_sentrygun = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			320,
			288,
			48,
			48
		}
	}
	self.interaction_keyboard = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			368,
			384,
			48,
			48
		}
	}
	self.laptop_objective = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			144,
			48,
			48
		}
	}
	self.interaction_bar = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			1,
			393,
			358,
			20
		}
	}
	self.interaction_bar_background = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			0,
			414,
			360,
			22
		}
	}
	self.mugshot_health_background = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			240,
			12,
			48
		}
	}
	self.mugshot_health_armor = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			252,
			240,
			12,
			48
		}
	}
	self.mugshot_health_health = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			264,
			240,
			12,
			48
		}
	}
	self.mugshot_talk = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			288,
			16,
			16
		}
	}
	self.mugshot_in_custody = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			0,
			64,
			64,
			64
		}
	}
	self.mugshot_downed = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			128,
			64,
			64,
			64
		}
	}
	self.mugshot_cuffed = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			288,
			464,
			48,
			48
		}
	}
	self.mugshot_electrified = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			336,
			464,
			48,
			48
		}
	}
	self.mugshot_turret = {
		texture = "ui/ingame/textures/hud/hud_icons_01",
		texture_rect = {
			64,
			64,
			64,
			64
		}
	}
	self.control_marker = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			352,
			288,
			16,
			48
		}
	}
	self.control_left = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			304,
			288,
			48,
			48
		}
	}
	self.control_right = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			256,
			288,
			48,
			48
		}
	}
	self.assault = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			276,
			192,
			108,
			96
		}
	}
	self.ps3buttonhighlight = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			192,
			32,
			32
		}
	}
	self.equipment_dynamite = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			64,
			0,
			64,
			64
		}
	}
	self.equipment_gas_tank = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			0,
			64,
			64,
			64
		}
	}
	self.equipment_empty_fuel_canister = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			448,
			0,
			64,
			64
		}
	}
	self.equipment_parachute = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			128,
			0,
			64,
			64
		}
	}
	self.equipment_scrap_parts = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			104,
			276,
			32,
			32
		}
	}
	self.equipment_tools = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			192,
			0,
			64,
			64
		}
	}
	self.equipment_code_book = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			256,
			0,
			64,
			64
		}
	}
	self.equipment_recording_device = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			320,
			0,
			64,
			64
		}
	}
	self.equipment_gas_fuel = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			128,
			64,
			64,
			64
		}
	}
	self.equipment_enigma = {
		texture = "ui/ingame/textures/hud/hud_pickup_icons_01",
		texture_rect = {
			64,
			64,
			64,
			64
		}
	}
	self.raid_prisoner = {
		texture = "ui/ingame/textures/hud/hud_waypoint_icons_01",
		texture_rect = {
			384,
			0,
			32,
			32
		}
	}
	self.raid_wp_wait = {
		texture = "ui/ingame/textures/hud/hud_waypoint_icons_01",
		texture_rect = {
			64,
			32,
			32,
			32
		}
	}
	self.waypoint_escort_stand = {
		texture = "ui/ingame/textures/hud/hud_waypoint_icons_01",
		texture_rect = {
			96,
			32,
			32,
			32
		}
	}
	self.waypoint_escort_crouch = {
		texture = "ui/ingame/textures/hud/hud_waypoint_icons_01",
		texture_rect = {
			128,
			32,
			32,
			32
		}
	}
end

-- Lines 662-668
function HudIconsTweakData:get_icon_data(icon_id, default_rect)
	local icon = tweak_data.hud_icons[icon_id] and tweak_data.hud_icons[icon_id].texture or icon_id
	local texture_rect = tweak_data.hud_icons[icon_id] and tweak_data.hud_icons[icon_id].texture_rect or default_rect or {
		0,
		0,
		48,
		48
	}
	local texture_rect_over = tweak_data.hud_icons[icon_id] and tweak_data.hud_icons[icon_id].texture_rect_over

	return icon, texture_rect, texture_rect_over
end
