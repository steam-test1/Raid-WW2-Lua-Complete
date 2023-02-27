InteractionTweakData = InteractionTweakData or class()

function InteractionTweakData:init()
	self.CULLING_DISTANCE = 2000
	self.INTERACT_DISTANCE = 200
	self.POWERUP_INTERACTION_DISTANCE = 270
	self.MINIGAME_CIRCLE_RADIUS_SMALL = 133
	self.MINIGAME_CIRCLE_RADIUS_MEDIUM = 134
	self.MINIGAME_CIRCLE_RADIUS_BIG = 270
	self.copy_machine_smuggle = {
		icon = "equipment_thermite",
		text_id = "debug_interact_copy_machine",
		interact_distance = 305
	}
	self.safety_deposit = {
		icon = "develop",
		text_id = "debug_interact_safety_deposit"
	}
	self.paper_pickup = {
		icon = "develop",
		text_id = "debug_interact_paper_pickup"
	}
	self.empty_interaction = {
		interact_distance = 0
	}
	self.thermite = {
		icon = "equipment_thermite",
		text_id = "debug_interact_thermite",
		equipment_text_id = "debug_interact_equipment_thermite",
		special_equipment = "thermite",
		equipment_consume = true,
		interact_distance = 300,
		timer = 3
	}
	self.gasoline = {
		icon = "equipment_thermite",
		text_id = "debug_interact_gas",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 300
	}
	self.gasoline_engine = {
		icon = "equipment_thermite",
		text_id = "debug_interact_gas",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 300,
		timer = 20
	}
	self.train_car = {
		icon = "develop",
		text_id = "debug_interact_train_car",
		equipment_text_id = "debug_interact_equipment_gas",
		special_equipment = "gas",
		equipment_consume = true,
		interact_distance = 400
	}
	self.walkout_van = {
		icon = "develop",
		text_id = "debug_interact_walkout_van",
		equipment_text_id = "debug_interact_equipment_gold",
		special_equipment = "gold",
		equipment_consume = true,
		interact_distance = 400
	}
	self.alaska_plane = {
		icon = "develop",
		text_id = "debug_interact_alaska_plane",
		equipment_text_id = "debug_interact_equipment_organs",
		special_equipment = "organs",
		equipment_consume = true,
		interact_distance = 400
	}
	self.suburbia_door_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar",
		equipment_text_id = "hud_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 5,
		start_active = false,
		sound_start = "bar_crowbar",
		sound_interupt = "bar_crowbar_cancel",
		sound_done = "bar_crowbar_end",
		interact_distance = 130
	}
	self.secret_stash_trunk_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar2",
		equipment_text_id = "hud_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 20,
		start_active = false,
		sound_start = "und_crowbar_trunk",
		sound_interupt = "und_crowbar_trunk_cancel",
		sound_done = "und_crowbar_trunk_finished"
	}
	self.requires_crowbar_interactive_template = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar_breach",
		equipment_text_id = "hud_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 8,
		start_active = false,
		sound_start = "bar_crowbar_open_metal",
		sound_interupt = "bar_crowbar_open_metal_cancel",
		sound_done = "bar_crowbar_open_metal_finished"
	}
	self.requires_saw_blade = {
		icon = "develop",
		text_id = "hud_int_hold_add_blade",
		equipment_text_id = "hud_equipment_no_saw_blade",
		special_equipment = "saw_blade",
		timer = 2,
		start_active = false,
		equipment_consume = true
	}
	self.saw_blade = {
		text_id = "hud_int_hold_take_blade",
		action_text_id = "hud_action_taking_saw_blade",
		timer = 0.5,
		start_active = false,
		special_equipment_block = "saw_blade"
	}
	self.open_slash_close_sec_box = {
		text_id = "hud_int_hold_open_slash_close_sec_box",
		action_text_id = "hud_action_opening_slash_closing_sec_box",
		timer = 0.5,
		start_active = false
	}
	self.activate_camera = {
		text_id = "hud_int_hold_activate_camera",
		action_text_id = "hud_action_activating_camera",
		timer = 0.5,
		start_active = false
	}
	self.weapon_cache_drop_zone = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_container",
		equipment_text_id = "debug_interact_equipment_blood_sample_verified",
		special_equipment = "blood_sample",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.secret_stash_limo_roof_crowbar = {
		icon = "develop",
		text_id = "hud_interact_equipment_crowbar",
		timer = 5,
		start_active = false,
		sound_start = "und_limo_chassis_open",
		sound_interupt = "und_limo_chassis_open_stop",
		sound_done = "und_limo_chassis_open_stop",
		axis = "y"
	}
	self.suburbia_iron_gate_crowbar = {
		icon = "equipment_crowbar",
		text_id = "debug_interact_crowbar",
		equipment_text_id = "hud_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 5,
		start_active = false,
		sound_start = "bar_crowbar_open_metal",
		sound_interupt = "bar_crowbar_open_metal_cancel"
	}
	self.apartment_key = {
		icon = "equipment_chavez_key",
		text_id = "debug_interact_apartment_key",
		equipment_text_id = "debug_interact_equiptment_apartment_key",
		special_equipment = "chavez_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.hospital_sample_validation_machine = {
		icon = "equipment_vial",
		text_id = "debug_interact_sample_validation",
		equipment_text_id = "debug_interact_equiptment_sample_validation",
		special_equipment = "blood_sample",
		equipment_consume = true,
		start_active = false,
		interact_distance = 150,
		axis = "y"
	}
	self.methlab_bubbling = {
		icon = "develop",
		text_id = "hud_int_methlab_bubbling",
		equipment_text_id = "hud_int_no_acid",
		special_equipment = "acid",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_bubbling",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.methlab_caustic_cooler = {
		icon = "develop",
		text_id = "hud_int_methlab_caustic_cooler",
		equipment_text_id = "hud_int_no_caustic_soda",
		special_equipment = "caustic_soda",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_caustic_cooler",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.methlab_gas_to_salt = {
		icon = "develop",
		text_id = "hud_int_methlab_gas_to_salt",
		equipment_text_id = "hud_int_no_hydrogen_chloride",
		special_equipment = "hydrogen_chloride",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_gas_to_salt"
	}
	self.methlab_drying_meth = {
		icon = "develop",
		text_id = "hud_int_methlab_drying_meth",
		equipment_text_id = "hud_int_no_liquid_meth",
		special_equipment = "liquid_meth",
		equipment_consume = true,
		start_active = false,
		timer = 1,
		action_text_id = "hud_action_methlab_drying_meth",
		sound_start = "liquid_pour",
		sound_interupt = "liquid_pour_stop",
		sound_done = "liquid_pour_stop"
	}
	self.muriatic_acid = {
		icon = "develop",
		text_id = "hud_int_take_acid",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "acid"
	}
	self.caustic_soda = {
		icon = "develop",
		text_id = "hud_int_take_caustic_soda",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "caustic_soda"
	}
	self.hydrogen_chloride = {
		icon = "develop",
		text_id = "hud_int_take_hydrogen_chloride",
		start_active = false,
		interact_distance = 225,
		special_equipment_block = "hydrogen_chloride"
	}
	self.elevator_button = {
		icon = "interaction_elevator",
		text_id = "debug_interact_elevator_door",
		start_active = false
	}
	self.use_computer = {
		icon = "interaction_elevator",
		text_id = "hud_int_use_computer",
		start_active = false,
		timer = 2
	}
	self.elevator_button_roof = {
		icon = "interaction_elevator",
		text_id = "debug_interact_elevator_door_roof",
		start_active = false
	}
	self.key_double = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_equipment_keycard",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		interact_distance = 100
	}
	self.key = deep_clone(self.key_double)
	self.key.axis = "x"
	self.numpad = {
		icon = "equipment_bank_manager_key",
		text_id = "debug_interact_numpad",
		start_active = false,
		axis = "z"
	}
	self.numpad_keycard = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_numpad_keycard",
		equipment_text_id = "hud_int_numpad_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = false,
		axis = "z"
	}
	self.timelock_panel = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_timelock_panel",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = false,
		axis = "y"
	}
	self.take_weapons = {
		icon = "develop",
		text_id = "hud_int_take_weapons",
		action_text_id = "hud_action_taking_weapons",
		timer = 3,
		axis = "x",
		interact_distance = 120
	}
	self.take_weapons_not_active = deep_clone(self.take_weapons)
	self.take_weapons_not_active.start_active = false
	self.pick_lock_easy = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 10,
		interact_distance = 100,
		requires_upgrade = {
			upgrade = "pick_lock_easy",
			category = "player"
		},
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.pick_lock_easy_no_skill = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 7,
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.pick_lock_hard = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 45,
		requires_upgrade = {
			upgrade = "pick_lock_hard",
			category = "player"
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.pick_lock_hard_no_skill = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 20,
		action_text_id = "hud_action_picking_lock",
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.pick_lock_deposit_transport = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_deposit_transport.timer = 15
	self.pick_lock_deposit_transport.axis = "y"
	self.pick_lock_deposit_transport.interact_distance = 80
	self.open_door_with_keys = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_try_keys",
		start_active = false,
		timer = 5,
		action_text_id = "hud_action_try_keys",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished",
		special_equipment = "keychain",
		equipment_text_id = "hud_action_try_keys_no_key"
	}
	self.cant_pick_lock = {
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = false,
		interact_distance = 80
	}
	self.hospital_veil_container = {
		icon = "equipment_vialOK",
		text_id = "debug_interact_hospital_veil_container",
		equipment_text_id = "debug_interact_equipment_blood_sample_verified",
		special_equipment = "blood_sample_verified",
		equipment_consume = true,
		start_active = false,
		timer = 2,
		axis = "y"
	}
	self.hospital_phone = {
		icon = "interaction_answerphone",
		text_id = "debug_interact_hospital_phone",
		start_active = false
	}
	self.hospital_security_cable = {
		text_id = "debug_interact_hospital_security_cable",
		icon = "interaction_wirecutter",
		start_active = false,
		timer = 5,
		interact_distance = 75
	}
	self.hospital_veil = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_hold",
		start_active = false,
		timer = 2
	}
	self.hospital_veil_take = {
		icon = "equipment_vial",
		text_id = "debug_interact_hospital_veil_take",
		start_active = false
	}
	self.hospital_sentry = {
		icon = "interaction_sentrygun",
		text_id = "debug_interact_hospital_sentry",
		start_active = false,
		timer = 2
	}
	self.drill = {
		icon = "equipment_drill",
		contour = "interactable_icon",
		text_id = "hud_int_equipment_drill",
		equipment_text_id = "hud_int_equipment_no_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "y",
		action_text_id = "hud_action_placing_drill"
	}
	self.drill_upgrade = {
		icon = "equipment_drill",
		contour = "upgradable",
		text_id = "hud_int_equipment_drill_upgrade",
		timer = 10,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		action_text_id = "hud_action_upgrading_drill"
	}
	self.drill_jammed = {
		icon = "equipment_drill",
		text_id = "hud_int_equipment_drill_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_fixing_drill"
	}
	self.lance = {
		icon = "equipment_drill",
		contour = "interactable_icon",
		text_id = "hud_int_equipment_lance",
		equipment_text_id = "hud_int_equipment_no_lance",
		timer = 3,
		blocked_hint = "no_lance",
		sound_start = "bar_thermal_lance_apply",
		sound_interupt = "bar_thermal_lance_apply_cancel",
		sound_done = "bar_thermal_lance_apply_finished",
		action_text_id = "hud_action_placing_lance"
	}
	self.lance_jammed = {
		icon = "equipment_drill",
		text_id = "hud_int_equipment_lance_jammed",
		timer = 10,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_fixing_lance"
	}
	self.lance_upgrade = {
		icon = "equipment_drill",
		contour = "upgradable",
		text_id = "hud_int_equipment_lance_upgrade",
		timer = 10,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		action_text_id = "hud_action_upgrading_lance"
	}
	self.glass_cutter = {
		icon = "equipment_cutter",
		text_id = "debug_interact_glass_cutter",
		equipment_text_id = "debug_interact_equipment_glass_cutter",
		special_equipment = "glass_cutter",
		timer = 3,
		blocked_hint = "no_glass_cutter",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.glass_cutter_jammed = {
		icon = "equipment_cutter",
		text_id = "debug_interact_cutter_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.hack_ipad = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "x"
	}
	self.hack_ipad_jammed = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.hack_suburbia = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "y",
		contour = "contour_off"
	}
	self.hack_suburbia_jammed = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.security_station = {
		icon = "equipment_hack_ipad",
		text_id = "debug_interact_security_station",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		axis = "z",
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.security_station_keyboard = {
		icon = "interaction_keyboard",
		text_id = "debug_interact_security_station",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.big_computer_hackable = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_hackable",
		timer = 6,
		start_active = false,
		interact_distance = 200,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.big_computer_not_hackable = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_hackable",
		timer = 6,
		start_active = false,
		interact_distance = 200,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		equipment_text_id = "hud_int_big_computer_unhackable",
		special_equipment = "nothing"
	}
	self.big_computer_server = {
		icon = "interaction_keyboard",
		text_id = "hud_int_big_computer_server",
		timer = 6,
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.security_station_jammed = {
		icon = "interaction_keyboard",
		text_id = "debug_interact_security_station_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		axis = "z"
	}
	self.apartment_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.apartment_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200
	}
	self.suburbia_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.suburbia_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200
	}
	self.goldheist_drill = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill",
		equipment_text_id = "debug_interact_equipment_drill",
		timer = 3,
		blocked_hint = "no_drill",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200
	}
	self.goldheist_drill_jammed = {
		icon = "equipment_drill",
		text_id = "debug_interact_drill_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200
	}
	self.hospital_saw_teddy = {
		icon = "equipment_saw",
		text_id = "debug_interact_hospital_saw_teddy",
		start_active = false,
		timer = 2
	}
	self.hospital_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		equipment_text_id = "debug_interact_equipment_saw",
		special_equipment = "saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.hospital_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.apartment_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.apartment_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.secret_stash_saw = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw",
		timer = 3,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished",
		interact_distance = 200,
		axis = "z"
	}
	self.secret_stash_saw_jammed = {
		icon = "equipment_saw",
		text_id = "debug_interact_saw_jammed",
		timer = 3,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished",
		interact_distance = 200,
		axis = "z",
		upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.revive = {
		icon = "interaction_help",
		text_id = "hud_interact_revive",
		start_active = false,
		interact_distance = 300,
		axis = "z",
		timer = 6,
		action_text_id = "hud_action_reviving",
		upgrade_timer_multiplier = {
			upgrade = "revive_interaction_speed_multiplier",
			category = "player"
		},
		contour_preset = "teammate_downed",
		contour_preset_selected = "teammate_downed_selected"
	}
	self.dead = {
		icon = "interaction_help",
		text_id = "hud_interact_revive",
		start_active = false,
		interact_distance = 300
	}
	self.free = {
		icon = "interaction_free",
		text_id = "debug_interact_free",
		start_active = false,
		interact_distance = 300,
		no_contour = true,
		timer = 1,
		sound_start = "bar_rescue",
		sound_interupt = "bar_rescue_cancel",
		sound_done = "bar_rescue_finished",
		action_text_id = "hud_action_freeing"
	}
	self.hostage_trade = {
		icon = "interaction_trade",
		text_id = "debug_interact_trade",
		start_active = true,
		timer = 3,
		requires_upgrade = {
			upgrade = "hostage_trade",
			category = "player"
		},
		action_text_id = "hud_action_trading",
		contour_preset = "generic_interactable",
		contour_preset_selected = "generic_interactable_selected"
	}
	self.hostage_move = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_move",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_standing_up",
		no_contour = true,
		interaction_obj = Idstring("Spine")
	}
	self.hostage_stay = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_stay",
		start_active = true,
		timer = 0.4,
		action_text_id = "hud_action_getting_down",
		no_contour = true,
		interaction_obj = Idstring("Spine2")
	}
	self.trip_mine = {
		icon = "equipment_trip_mine",
		requires_upgrade = {
			upgrade = "can_switch_on_off",
			category = "trip_mine"
		},
		no_contour = true
	}
	self.grenade_crate = {
		icon = "equipment_ammo_bag",
		text_id = "hud_interact_grenade_crate_take_grenades",
		contour = "crate_loot_pickup",
		blocked_hint = "hint_full_grenades",
		blocked_hint_sound = "no_more_grenades",
		sound_done = "pickup_grenade",
		action_text_id = "hud_action_taking_grenades",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.grenade_pickup_new = deep_clone(self.grenade_crate)
	self.grenade_pickup_new.start_active = true
	self.grenade_crate_small = {
		icon = self.grenade_crate.icon,
		text_id = self.grenade_crate.text_id,
		contour = self.grenade_crate.contour,
		blocked_hint = self.grenade_crate.blocked_hint,
		blocked_hint_sound = self.grenade_crate.blocked_hint_sound,
		sound_start = self.grenade_crate.sound_start,
		sound_interupt = self.grenade_crate.sound_interupt,
		sound_done = self.grenade_crate.sound_done,
		action_text_id = self.grenade_crate.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.grenade_crate_big = {
		icon = self.grenade_crate.icon,
		text_id = self.grenade_crate.text_id,
		contour = self.grenade_crate.contour,
		blocked_hint = self.grenade_crate.blocked_hint,
		blocked_hint_sound = self.grenade_crate.blocked_hint_sound,
		sound_start = self.grenade_crate.sound_start,
		sound_interupt = self.grenade_crate.sound_interupt,
		sound_done = self.grenade_crate.sound_done,
		action_text_id = self.grenade_crate.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag = {
		icon = "equipment_ammo_bag",
		text_id = "hud_interact_ammo_bag_take_ammo",
		contour = "deployable",
		blocked_hint = "hint_full_ammo",
		blocked_hint_sound = "no_more_ammo",
		sound_done = "pickup_ammo",
		action_text_id = "hud_action_taking_ammo",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag_small = {
		icon = self.ammo_bag.icon,
		text_id = self.ammo_bag.text_id,
		contour = self.ammo_bag.contour,
		blocked_hint = self.ammo_bag.blocked_hint,
		blocked_hint_sound = self.ammo_bag.blocked_hint_sound,
		sound_start = self.ammo_bag.sound_start,
		sound_interupt = self.ammo_bag.sound_interupt,
		sound_done = self.ammo_bag.sound_done,
		action_text_id = self.ammo_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag_big = {
		icon = self.ammo_bag.icon,
		text_id = self.ammo_bag.text_id,
		contour = self.ammo_bag.contour,
		blocked_hint = self.ammo_bag.blocked_hint,
		blocked_hint_sound = self.ammo_bag.blocked_hint_sound,
		sound_start = self.ammo_bag.sound_start,
		sound_interupt = self.ammo_bag.sound_interupt,
		sound_done = self.ammo_bag.sound_done,
		action_text_id = self.ammo_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.health_bag = {
		icon = "equipment_doctor_bag",
		text_id = "hud_interact_doctor_bag_heal",
		contour = "deployable",
		blocked_hint = "hint_full_health",
		blocked_hint_sound = "no_more_health",
		sound_done = "pickup_health",
		action_text_id = "hud_action_healing",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.health_bag_small = {
		icon = self.health_bag.icon,
		text_id = self.health_bag.text_id,
		contour = self.health_bag.contour,
		timer = 0,
		blocked_hint = self.health_bag.blocked_hint,
		blocked_hint_sound = self.health_bag.blocked_hint_sound,
		sound_start = self.health_bag.sound_start,
		sound_interupt = self.health_bag.sound_interupt,
		sound_done = self.health_bag.sound_done,
		action_text_id = self.health_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.health_bag_big = {
		icon = self.health_bag.icon,
		text_id = self.health_bag.text_id,
		contour = self.health_bag.contour,
		timer = 0,
		blocked_hint = self.health_bag.blocked_hint,
		blocked_hint_sound = self.health_bag.blocked_hint_sound,
		sound_start = self.health_bag.sound_start,
		sound_interupt = self.health_bag.sound_interupt,
		sound_done = self.health_bag.sound_done,
		action_text_id = self.health_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.doctor_bag = {
		icon = "equipment_doctor_bag",
		text_id = "debug_interact_doctor_bag_heal",
		contour = "deployable",
		timer = 3.5,
		blocked_hint = "hint_full_health",
		sound_start = "bar_helpup",
		sound_interupt = "bar_helpup_cancel",
		sound_done = "bar_helpup_finished",
		action_text_id = "hud_action_healing",
		upgrade_timer_multiplier = {
			upgrade = "interaction_speed_multiplier",
			category = "doctor_bag"
		}
	}
	self.test_interactive_door = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box"
	}
	self.test_interactive_door_one_direction = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		axis = "y"
	}
	self.temp_interact_box = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		timer = 4
	}
	self.requires_cable_ties = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		equipment_text_id = "debug_interact_equipment_requires_cable_ties",
		special_equipment = "cable_tie",
		equipment_consume = true,
		timer = 5,
		requires_upgrade = {
			upgrade = "can_cable_tie_doors",
			category = "cable_tie"
		},
		upgrade_timer_multiplier = {
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		}
	}
	self.temp_interact_box_no_timer = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box"
	}
	self.access_camera = {
		icon = "develop",
		text_id = "hud_int_access_camera",
		interact_distance = 125
	}
	self.driving_console = {
		icon = "develop",
		text_id = "hud_int_driving_console",
		interact_distance = 500
	}
	self.driving_drive = {
		icon = "develop",
		text_id = "hud_int_driving_drive",
		timer = 1,
		interact_distance = 500
	}
	self.driving_willy = {
		icon = "develop",
		text_id = "hud_int_driving_drive",
		timer = 1,
		interact_distance = 200
	}
	self.foxhole = {
		icon = "develop",
		text_id = "hud_int_enter_foxhole",
		timer = 1,
		interact_distance = 500,
		sound_start = "cvy_foxhole_start",
		sound_interupt = "cvy_foxhole_cancel",
		sound_done = "cvy_foxhole_finish"
	}
	self.main_menu_select_interaction = {
		text_id = "hud_menu_crate_select",
		interact_distance = 300,
		sound_done = "paper_shuffle"
	}
	self.interaction_ball = {
		icon = "develop",
		text_id = "debug_interact_interaction_ball",
		timer = 5,
		sound_start = "cft_hose_loop",
		sound_interupt = "cft_hose_cancel",
		sound_done = "cft_hose_end"
	}
	self.invisible_interaction_open = {
		icon = "develop",
		text_id = "hud_int_invisible_interaction_open",
		timer = 0.5
	}
	self.fork_lift_sound = deep_clone(self.invisible_interaction_open)
	self.fork_lift_sound.text_id = "hud_int_fork_lift_sound"
	self.money_briefcase = deep_clone(self.invisible_interaction_open)
	self.money_briefcase.axis = "x"
	self.grenade_briefcase = deep_clone(self.invisible_interaction_open)
	self.grenade_briefcase.contour = "deployable"
	self.cash_register = deep_clone(self.invisible_interaction_open)
	self.cash_register.axis = "x"
	self.cash_register.interact_distance = 110
	self.atm_interaction = deep_clone(self.invisible_interaction_open)
	self.atm_interaction.start_active = false
	self.atm_interaction.contour = "interactable_icon"
	self.weapon_case = deep_clone(self.invisible_interaction_open)
	self.weapon_case.axis = "x"
	self.weapon_case.interact_distance = 110
	self.weapon_case_close = deep_clone(self.weapon_case)
	self.weapon_case_close.text_id = "hud_int_invisible_interaction_close"
	self.invisible_interaction_close = deep_clone(self.invisible_interaction_open)
	self.invisible_interaction_close.text_id = "hud_int_invisible_interaction_close"
	self.interact_gen_pku_loot_take = {
		icon = "develop",
		text_id = "debug_interact_gen_pku_loot_take",
		timer = 2
	}
	self.water_tap = {
		icon = "develop",
		text_id = "debug_interact_water_tap",
		timer = 3,
		start_active = false,
		axis = "y"
	}
	self.water_manhole = {
		icon = "develop",
		text_id = "debug_interact_water_tap",
		timer = 3,
		start_active = false,
		axis = "z",
		interact_distance = 200
	}
	self.sewer_manhole = {
		icon = "develop",
		text_id = "debug_interact_sewer_manhole",
		timer = 3,
		start_active = false,
		interact_distance = 200,
		equipment_text_id = "hud_interact_equipment_crowbar"
	}
	self.circuit_breaker = {
		icon = "interaction_powerbox",
		text_id = "debug_interact_circuit_breaker",
		start_active = false,
		axis = "z"
	}
	self.hold_circuit_breaker = deep_clone(self.circuit_breaker)
	self.hold_circuit_breaker.timer = 2
	self.hold_circuit_breaker.text_id = "hud_int_hold_turn_on_power"
	self.hold_circuit_breaker.action_text_id = "hud_action_turning_on_power"
	self.hold_circuit_breaker.axis = "y"
	self.transformer_box = {
		icon = "interaction_powerbox",
		text_id = "debug_interact_transformer_box",
		start_active = false,
		axis = "y",
		timer = 5
	}
	self.stash_server_cord = {
		icon = "interaction_powercord",
		text_id = "debug_interact_stash_server_cord",
		start_active = false,
		axis = "z"
	}
	self.stash_planks = {
		icon = "equipment_planks",
		contour = "interactable_icon",
		text_id = "debug_interact_stash_planks",
		start_active = false,
		timer = 2.5,
		equipment_text_id = "debug_interact_equipment_stash_planks",
		special_equipment = "planks",
		equipment_consume = true,
		sound_start = "bar_barricade_window",
		sound_interupt = "bar_barricade_window_cancel",
		sound_done = "bar_barricade_window_finished",
		action_text_id = "hud_action_barricading",
		axis = "z"
	}
	self.stash_planks_pickup = {
		icon = "equipment_planks",
		text_id = "debug_interact_stash_planks_pickup",
		start_active = false,
		timer = 2,
		axis = "z",
		special_equipment_block = "planks",
		sound_start = "bar_pick_up_planks",
		sound_interupt = "bar_pick_up_planks_cancel",
		sound_done = "bar_pick_up_planks_finished",
		action_text_id = "hud_action_grabbing_planks"
	}
	self.stash_server = {
		icon = "equipment_stash_server",
		text_id = "debug_interact_stash_server",
		timer = 2,
		start_active = false,
		axis = "z",
		equipment_text_id = "debug_interact_equipment_stash_server",
		special_equipment = "server",
		equipment_consume = true
	}
	self.stash_server_pickup = {
		icon = "equipment_stash_server",
		text_id = "hud_int_hold_take_hdd",
		timer = 1,
		start_active = false,
		axis = "z",
		special_equipment_block = "server",
		interact_distance = 250
	}
	self.shelf_sliding_suburbia = {
		icon = "develop",
		text_id = "debug_interact_move_bookshelf",
		start_active = false,
		timer = 3
	}
	self.tear_painting = {
		icon = "develop",
		text_id = "debug_interact_tear_painting",
		start_active = false,
		axis = "y"
	}
	self.ejection_seat_interact = {
		icon = "equipment_ejection_seat",
		text_id = "debug_interact_temp_interact_box",
		timer = 4
	}
	self.diamond_pickup = {
		icon = "interaction_diamond",
		text_id = "hud_int_take_jewelry",
		sound_event = "money_grab",
		start_active = false,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.safe_loot_pickup = deep_clone(self.diamond_pickup)
	self.safe_loot_pickup.start_active = true
	self.safe_loot_pickup.text_id = "hud_int_take"
	self.mus_pku_artifact = deep_clone(self.diamond_pickup)
	self.mus_pku_artifact.start_active = true
	self.mus_pku_artifact.text_id = "hud_int_take_artifact"
	self.tiara_pickup = {
		icon = "develop",
		text_id = "hud_int_pickup_tiara",
		sound_event = "money_grab",
		start_active = false
	}
	self.patientpaper_pickup = {
		icon = "interaction_patientfile",
		text_id = "debug_interact_patient_paper",
		timer = 2,
		start_active = false
	}
	self.diamond_case = {
		icon = "interaction_diamond",
		text_id = "debug_interact_diamond_case",
		start_active = false,
		axis = "x",
		interact_distance = 150
	}
	self.diamond_single_pickup = {
		icon = "interaction_diamond",
		text_id = "debug_interact_temp_interact_box_press",
		start_active = false
	}
	self.suburbia_necklace_pickup = {
		icon = "interaction_diamond",
		text_id = "debug_interact_temp_interact_box_press",
		start_active = false,
		interact_distance = 100
	}
	self.temp_interact_box2 = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		timer = 20
	}
	self.printing_plates = {
		icon = "develop",
		text_id = "hud_int_printing_plates"
	}
	self.c4 = {
		icon = "equipment_c4",
		text_id = "debug_interact_c4",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		action_text_id = "hud_action_placing_c4"
	}
	self.c4_mission_door = deep_clone(self.c4)
	self.c4_mission_door.special_equipment = "c4"
	self.c4_mission_door.equipment_text_id = "debug_interact_equipment_c4"
	self.c4_mission_door.equipment_consume = true
	self.c4_diffusible = {
		icon = "equipment_c4",
		text_id = "debug_c4_diffusible",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		axis = "z"
	}
	self.open_trunk = {
		icon = "develop",
		text_id = "debug_interact_open_trunk",
		timer = 0.5,
		axis = "x",
		action_text_id = "hud_action_opening_trunk",
		sound_start = "truck_back_door_opening",
		sound_done = "truck_back_door_open",
		sound_interupt = "stop_truck_back_door_opening"
	}
	self.embassy_door = {
		start_active = false,
		icon = "interaction_open_door",
		text_id = "debug_interact_embassy_door",
		interact_distance = 150,
		timer = 5
	}
	self.c4_special = {
		icon = "equipment_c4",
		text_id = "debug_interact_c4",
		equipment_text_id = "debug_interact_equipment_c4",
		equipment_consume = true,
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		axis = "z",
		action_text_id = "hud_action_placing_c4"
	}
	self.c4_bag = {
		text_id = "debug_interact_c4_bag",
		timer = 4,
		contour = "interactable",
		axis = "z"
	}
	self.money_wrap = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_take_money",
		start_active = false,
		timer = 3,
		action_text_id = "hud_action_taking_money",
		blocked_hint = "hud_hint_carry_block_interact",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.suburbia_money_wrap = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_printed_take_money",
		start_active = false,
		timer = 3,
		action_text_id = "hud_action_taking_money"
	}
	self.money_wrap_single_bundle = {
		icon = "interaction_money_wrap",
		text_id = "debug_interact_money_wrap_single_bundle_take_money",
		start_active = false,
		interact_distance = 200,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		start_active = true
	}
	self.christmas_present = {
		icon = "interaction_christmas_present",
		text_id = "debug_interact_take_christmas_present",
		start_active = true,
		interact_distance = 125
	}
	self.gold_pile = {
		icon = "interaction_gold",
		text_id = "hud_interact_gold_pile_take_money",
		start_active = true,
		action_text_id = "hud_action_taking_gold",
		blocked_hint = "hud_hint_carry_block_interact",
		sound_done = "gold_crate_drop",
		timer = 1
	}
	self.gold_pile_inactive = deep_clone(self.gold_pile)
	self.gold_pile_inactive.start_active = false
	self.take_gold_bar = {
		icon = "interaction_gold",
		text_id = "hud_take_gold_bar",
		start_active = true,
		blocked_hint = "hud_hint_carry_block_interact",
		sound_done = "gold_crate_drop",
		timer = 0
	}
	self.take_gold_bar_bag = {
		icon = "develop",
		text_id = "hud_take_gold_bar",
		action_text_id = "hud_action_taking_gold_bar",
		timer = 0,
		force_update_position = true,
		blocked_hint = "hud_hint_carry_block_interact",
		sound_start = "gold_crate_pickup",
		sound_interupt = "gold_crate_drop",
		sound_done = "gold_crate_drop"
	}
	self.gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_gold_bag",
		start_active = false,
		timer = 1,
		special_equipment_block = "gold_bag_equip",
		action_text_id = "hud_action_taking_gold"
	}
	self.requires_gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_requires_gold_bag",
		equipment_text_id = "debug_interact_equipment_requires_gold_bag",
		special_equipment = "gold_bag_equip",
		start_active = true,
		equipment_consume = true,
		timer = 1,
		axis = "x"
	}
	self.intimidate = {
		icon = "equipment_cable_ties",
		text_id = "debug_interact_intimidate",
		equipment_text_id = "debug_interact_equipment_cable_tie",
		start_active = false,
		special_equipment = "cable_tie",
		equipment_consume = true,
		no_contour = true,
		timer = 2,
		upgrade_timer_multiplier = {
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		},
		action_text_id = "hud_action_cable_tying"
	}
	self.intimidate_and_search = {
		icon = "equipment_cable_ties",
		text_id = "debug_interact_intimidate",
		equipment_text_id = "debug_interact_search_key",
		start_active = false,
		special_equipment = "cable_tie",
		equipment_consume = true,
		dont_need_equipment = true,
		no_contour = true,
		timer = 3.5,
		action_text_id = "hud_action_cable_tying"
	}
	self.intimidate_with_contour = deep_clone(self.intimidate)
	self.intimidate_with_contour.no_contour = false
	self.intimidate_and_search_with_contour = deep_clone(self.intimidate_and_search)
	self.intimidate_and_search_with_contour.no_contour = false
	self.computer_test = {
		icon = "develop",
		text_id = "debug_interact_computer_test",
		start_active = false
	}
	self.carry_drop = {
		icon = "develop",
		text_id = "hud_int_hold_grab_the_bag",
		timer = 1,
		force_update_position = true,
		upgrade_timer_multiplier = {
			upgrade = "carry_pickup_multiplier",
			category = "interaction"
		},
		action_text_id = "hud_action_grabbing_bag",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.painting_carry_drop = {
		icon = "develop",
		text_id = "hud_int_hold_grab_the_painting",
		timer = 1,
		force_update_position = true,
		action_text_id = "hud_action_grabbing_painting",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.corpse_alarm_pager = {
		icon = "develop",
		text_id = "hud_int_disable_alarm_pager",
		timer = 10,
		force_update_position = true,
		action_text_id = "hud_action_disabling_alarm_pager",
		contour_preset = "generic_interactable",
		contour_preset_selected = "generic_interactable_selected",
		contour_flash_interval = 0.15,
		upgrade_timer_multiplier = {
			upgrade = "alarm_pager_speed_multiplier",
			category = "player"
		},
		interact_dont_interupt_on_distance = true
	}
	self.corpse_dispose = {
		icon = "develop",
		text_id = "hud_int_dispose_corpse",
		timer = 2,
		upgrade_timer_multiplier = {
			upgrade = "corpse_dispose_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_disposing_corpse",
		no_contour = true
	}
	self.shaped_sharge = {
		icon = "equipment_c4",
		text_id = "hud_int_equipment_shaped_charge",
		contour = "interactable_icon",
		required_deployable = "trip_mine",
		deployable_consume = true,
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished",
		requires_upgrade = {
			upgrade = "trip_mine_shaped_charge",
			category = "player"
		},
		action_text_id = "hud_action_placing_shaped_charge"
	}
	self.shaped_charge_single = deep_clone(self.shaped_sharge)
	self.shaped_charge_single.axis = "z"
	self.hostage_convert = {
		icon = "develop",
		text_id = "hud_int_hostage_convert",
		blocked_hint = "convert_enemy_failed",
		timer = 1.5,
		requires_upgrade = {
			upgrade = "convert_enemies",
			category = "player"
		},
		upgrade_timer_multiplier = {
			upgrade = "convert_enemies_interaction_speed_multiplier",
			category = "player"
		},
		action_text_id = "hud_action_converting_hostage",
		no_contour = true
	}
	self.break_open = {
		icon = "develop",
		text_id = "hud_int_break_open",
		start_active = false
	}
	self.cut_fence = {
		text_id = "hud_int_hold_cut_fence",
		action_text_id = "hud_action_cutting_fence",
		contour = "interactable_icon",
		timer = 0.5,
		start_active = true,
		sound_start = "bar_cut_fence",
		sound_interupt = "bar_cut_fence_cancel",
		sound_done = "bar_cut_fence_finished"
	}
	self.burning_money = {
		text_id = "hud_int_hold_ignite_money",
		action_text_id = "hud_action_igniting_money",
		timer = 2,
		start_active = false,
		interact_distance = 250
	}
	self.hold_take_painting = {
		text_id = "hud_int_hold_take_painting",
		action_text_id = "hud_action_taking_painting",
		start_active = false,
		axis = "y",
		timer = 2,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.barricade_fence = deep_clone(self.stash_planks)
	self.barricade_fence.contour = "interactable_icon"
	self.barricade_fence.sound_start = "bar_barricade_fence"
	self.barricade_fence.sound_interupt = "bar_barricade_fence_cancel"
	self.barricade_fence.sound_done = "bar_barricade_fence_finished"
	self.hack_numpad = {
		text_id = "hud_int_hold_hack_numpad",
		action_text_id = "hud_action_hacking_numpad",
		start_active = false,
		timer = 15
	}
	self.pickup_phone = {
		text_id = "hud_int_pickup_phone",
		start_active = false
	}
	self.pickup_tablet = deep_clone(self.pickup_phone)
	self.pickup_tablet.text_id = "hud_int_pickup_tablet"
	self.hold_take_server = {
		text_id = "hud_int_hold_take_server",
		action_text_id = "hud_action_taking_server",
		timer = 4,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.hold_take_server_axis = deep_clone(self.hold_take_server)
	self.hold_take_server_axis.axis = "y"
	self.hold_take_blueprints = {
		text_id = "hud_int_hold_take_blueprints",
		action_text_id = "hud_action_taking_blueprints",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_steal_painting",
		sound_interupt = "bar_steal_painting_cancel",
		sound_done = "bar_steal_painting_finished"
	}
	self.take_confidential_folder = {
		text_id = "hud_int_take_confidential_folder",
		start_active = false
	}
	self.take_confidential_folder_event = {
		text_id = "hud_int_take_confidential_folder_event",
		start_active = false,
		timer = 1
	}
	self.hold_take_gas_can = {
		text_id = "hud_int_hold_take_gas",
		action_text_id = "hud_action_taking_gasoline",
		start_active = false,
		timer = 0.5,
		special_equipment_block = "gas"
	}
	self.gen_ladyjustice_statue = {
		text_id = "hud_int_ladyjustice_statue"
	}
	self.hold_place_gps_tracker = {
		text_id = "hud_int_hold_place_gps_tracker",
		action_text_id = "hud_action_placing_gps_tracker",
		contour = "interactable_icon",
		start_active = false,
		timer = 1.5,
		interact_distance = 200
	}
	self.keyboard_no_time = deep_clone(self.security_station_keyboard)
	self.keyboard_no_time.timer = 2.5
	self.keyboard_eday_1 = deep_clone(self.security_station_keyboard)
	self.keyboard_eday_1.timer = 2.5
	self.keyboard_eday_1.text_id = "hud_int_keyboard_eday_1"
	self.keyboard_eday_2 = deep_clone(self.security_station_keyboard)
	self.keyboard_eday_2.timer = 2.5
	self.keyboard_eday_2.text_id = "hud_int_keyboard_eday_2"
	self.keyboard_hox_1 = deep_clone(self.security_station_keyboard)
	self.keyboard_hox_1.timer = 2.5
	self.keyboard_hox_1.text_id = "hud_int_keyboard_hox_1"
	self.keyboard_hox_1.action_text_id = "hud_action_keyboard_hox_1"
	self.hold_use_computer = {
		start_active = false,
		text_id = "hud_int_hold_use_computer",
		action_text_id = "hud_action_using_computer",
		timer = 1,
		axis = "z",
		interact_distance = 100
	}
	self.use_server_device = {
		text_id = "hud_int_hold_use_device",
		action_text_id = "hud_action_using_device",
		timer = 1,
		start_active = false
	}
	self.iphone_answer = {
		text_id = "hud_int_answer_phone",
		start_active = false
	}
	self.use_flare = {
		text_id = "hud_int_use_flare",
		start_active = false
	}
	self.extinguish_flare = {
		text_id = "hud_int_estinguish_flare",
		start_active = false,
		timer = 1
	}
	self.steal_methbag = {
		text_id = "hud_int_hold_steal_meth",
		action_text_id = "hud_action_stealing_meth",
		start_active = true,
		timer = 3
	}
	self.pickup_keycard = {
		text_id = "hud_int_pickup_keycard",
		sound_done = "pick_up_key_card",
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		blocked_hint = "full_keycard"
	}
	self.open_from_inside = {
		text_id = "hud_int_invisible_interaction_open",
		start_active = true,
		interact_distance = 100,
		timer = 0.2,
		axis = "x"
	}
	self.money_luggage = deep_clone(self.money_wrap)
	self.money_luggage.start_active = true
	self.money_luggage.axis = "x"
	self.hold_pickup_lance = {
		text_id = "hud_int_hold_pickup_lance",
		action_text_id = "hud_action_grabbing_lance",
		timer = 1
	}
	self.barrier_numpad = {
		text_id = "hud_int_barrier_numpad",
		start_active = false,
		axis = "z"
	}
	self.timelock_numpad = {
		text_id = "hud_int_timelock_numpad",
		start_active = false,
		axis = "z"
	}
	self.pickup_asset = {
		text_id = "hud_int_pickup_asset"
	}
	self.open_slash_close = {
		text_id = "hud_int_open_slash_close",
		start_active = false,
		axis = "y",
		interact_distance = 200
	}
	self.open_slash_close_act = {
		text_id = "hud_int_open_slash_close",
		action_text_id = "hud_action_open_slash_close",
		timer = 1,
		start_active = true
	}
	self.raise_balloon = {
		text_id = "hud_int_hold_raise_balloon",
		action_text_id = "hud_action_raise_balloon",
		start_active = false,
		timer = 2
	}
	self.stn_int_place_camera = {
		text_id = "hud_int_place_camera",
		start_active = true
	}
	self.stn_int_take_camera = {
		text_id = "hud_int_take_camera",
		start_active = true
	}
	self.gage_assignment = {
		icon = "develop",
		text_id = "debug_interact_gage_assignment_take",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_taking_gage_assignment",
		blocked_hint = "hint_gage_mods_dlc_block"
	}
	self.gen_pku_fusion_reactor = {
		text_id = "hud_int_hold_take_reaktor",
		action_text_id = "hud_action_taking_reaktor",
		blocked_hint = "hud_hint_carry_block_interact",
		start_active = false,
		timer = 3,
		no_contour = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.gen_pku_cocaine = {
		text_id = "hud_int_hold_take_cocaine",
		action_text_id = "hud_action_taking_cocaine",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.gen_pku_painting = {
		text_id = "hud_int_hold_take_cocaine",
		action_text_id = "hud_action_taking_cocaine",
		timer = 3,
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.gen_pku_artifact_statue = {
		text_id = "hud_int_hold_take_artifact",
		action_text_id = "hud_action_taking_artifact",
		timer = 3,
		start_active = false,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.gen_pku_artifact = deep_clone(self.gen_pku_artifact_statue)
	self.gen_pku_artifact.start_active = true
	self.gen_pku_artifact.sound_start = "bar_bag_armor"
	self.gen_pku_artifact.sound_interupt = "bar_bag_armor_cancel"
	self.gen_pku_artifact.sound_done = "bar_bag_armor_finished"
	self.gen_pku_artifact_painting = deep_clone(self.gen_pku_artifact_statue)
	self.gen_pku_artifact_painting.start_active = true
	self.gen_pku_artifact_painting.sound_start = "bar_steal_painting"
	self.gen_pku_artifact_painting.sound_interupt = "bar_steal_painting_cancel"
	self.gen_pku_artifact_painting.sound_done = "bar_steal_painting_finished"
	self.gen_pku_jewelry = {
		text_id = "hud_int_hold_take_jewelry",
		action_text_id = "hud_action_taking_jewelry",
		timer = 3,
		sound_start = "bar_bag_jewelry",
		sound_interupt = "bar_bag_jewelry_cancel",
		sound_done = "bar_bag_jewelry_finished",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.taking_meth = {
		text_id = "hud_int_hold_take_meth",
		action_text_id = "hud_action_taking_meth",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.gen_pku_crowbar = {
		text_id = "hud_int_take_crowbar",
		special_equipment_block = "crowbar",
		sound_done = "crowbar_pickup"
	}
	self.gen_pku_crowbar_stack = {
		text_id = "hud_int_take_crowbar",
		special_equipment_block = "crowbar_stack",
		sound_done = "crowbar_pickup"
	}
	self.gen_pku_thermite = {
		text_id = "hud_int_take_thermite",
		special_equipment_block = "thermite"
	}
	self.gen_pku_thermite_paste = {
		text_id = "hud_int_take_thermite_paste",
		special_equipment_block = "thermite_paste",
		contour = "deployable",
		sound_done = "pick_up_thermite"
	}
	self.button_infopad = {
		text_id = "hud_int_press_for_info",
		start_active = false,
		axis = "z"
	}
	self.crate_loot = {
		text_id = "hud_int_hold_crack_crate",
		action_text_id = "hud_action_cracking_crate",
		timer = 1,
		start_active = false,
		sound_start = "bar_open_crate",
		sound_interupt = "bar_open_crate_cancel",
		sound_done = "bar_open_crate_finished"
	}
	self.crate_loot_crowbar = deep_clone(self.crate_loot)
	self.crate_loot_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.crate_loot_crowbar.special_equipment = "crowbar"
	self.crate_loot_crowbar.sound_start = "bar_crowbar"
	self.crate_loot_crowbar.sound_interupt = "bar_crowbar_cancel"
	self.crate_loot_crowbar.sound_done = "bar_crowbar_end"
	self.crate_loot_crowbar.start_active = true
	self.weapon_case_not_active = deep_clone(self.weapon_case)
	self.weapon_case_not_active.start_active = false
	self.crate_weapon_crowbar = deep_clone(self.weapon_case)
	self.crate_weapon_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.crate_weapon_crowbar.timer = 2
	self.crate_weapon_crowbar.start_active = false
	self.crate_weapon_crowbar.special_equipment = "crowbar"
	self.crate_weapon_crowbar.sound_start = "bar_crowbar_plastic"
	self.crate_weapon_crowbar.sound_interupt = "bar_crowbar_plastic_cancel"
	self.crate_weapon_crowbar.sound_done = "bar_crowbar_plastic_finished"
	self.crate_loot_close = {
		text_id = "hud_int_hold_close_crate",
		action_text_id = "hud_action_closing_crate",
		timer = 2,
		start_active = false,
		sound_start = "bar_close_crate",
		sound_interupt = "bar_close_crate_cancel",
		sound_done = "bar_close_crate_finished"
	}
	self.halloween_trick = {
		text_id = "hud_int_trick_treat"
	}
	self.disassemble_turret = {
		text_id = "hud_int_hold_disassemble_turret",
		action_text_id = "hud_action_disassemble_turret",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 3,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.take_ammo = {
		text_id = "hud_int_hold_pack_shells",
		action_text_id = "hud_action_packing_shells",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2
	}
	self.bank_note = {
		text_id = "hud_int_bank_note",
		start_active = false,
		timer = 3
	}
	self.pickup_boards = {
		text_id = "hud_int_hold_pickup_boards",
		action_text_id = "hud_action_picking_up",
		start_active = false,
		timer = 2,
		axis = "z",
		special_equipment_block = "boards",
		sound_start = "bar_pick_up_planks",
		sound_interupt = "bar_pick_up_planks_cancel",
		sound_done = "bar_pick_up_planks_finished"
	}
	self.need_boards = {
		contour = "interactable_icon",
		text_id = "debug_interact_stash_planks",
		action_text_id = "hud_action_barricading",
		start_active = false,
		timer = 2.5,
		equipment_text_id = "hud_equipment_need_boards",
		special_equipment = "boards",
		equipment_consume = true,
		sound_start = "bar_barricade_window",
		sound_interupt = "bar_barricade_window_cancel",
		sound_done = "bar_barricade_window_finished",
		axis = "z"
	}
	self.uload_database = {
		text_id = "hud_int_hold_use_computer",
		action_text_id = "hud_action_using_computer",
		timer = 4,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "x",
		contour = "contour_off"
	}
	self.uload_database_jammed = {
		text_id = "hud_int_hold_resume_upload",
		action_text_id = "hud_action_resuming_upload",
		timer = 1,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished",
		axis = "x"
	}
	self.votingmachine2 = {
		text_id = "debug_interact_hack_ipad",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.votingmachine2_jammed = {
		text_id = "debug_interact_hack_ipad_jammed",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.sc_tape_loop = {
		icon = "interaction_help",
		text_id = "hud_int_tape_loop",
		start_active = true,
		interact_distance = 150,
		no_contour = true,
		timer = 4,
		action_text_id = "hud_action_tape_looping",
		requires_upgrade = {
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.money_scanner = deep_clone(self.invisible_interaction_open)
	self.money_scanner.axis = "y"
	self.money_small = deep_clone(self.money_wrap)
	self.money_small.sound_start = "bar_bag_pour_money"
	self.money_small.sound_interupt = "bar_bag_pour_money_cancel"
	self.money_small.sound_done = "bar_bag_pour_money_finished"
	self.money_small_take = deep_clone(self.money_small)
	self.money_small_take.text_id = "debug_interact_money_printed_take_money"
	self.shape_charge_plantable = {
		text_id = "debug_interact_c4",
		action_text_id = "hud_action_placing_c4",
		equipment_text_id = "debug_interact_equipment_c4",
		special_equipment = "c4",
		equipment_consume = true,
		axis = "z",
		timer = 4,
		sound_start = "bar_c4_apply",
		sound_interupt = "bar_c4_apply_cancel",
		sound_done = "bar_c4_apply_finished"
	}
	self.player_zipline = {
		text_id = "hud_int_use_zipline"
	}
	self.bag_zipline = {
		text_id = "hud_int_bag_zipline"
	}
	self.huge_lance = {
		text_id = "hud_int_equipment_huge_lance",
		action_text_id = "hud_action_placing_huge_lance",
		timer = 3,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.huge_lance_jammed = {
		text_id = "hud_int_equipment_huge_lance_jammed",
		action_text_id = "hud_action_fixing_huge_lance",
		special_equipment = "lance_part",
		equipment_text_id = "hud_int_equipment_no_lance_part",
		blocked_hint = "no_huge_lance",
		equipment_consume = true,
		timer = 10,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.gen_pku_lance_part = {
		text_id = "hud_int_take_lance_part",
		special_equipment_block = "lance_part",
		sound_done = "drill_fix_end"
	}
	self.crane_joystick_left = {
		text_id = "hud_int_crane_left",
		start_active = false
	}
	self.crane_joystick_lift = {
		text_id = "hud_int_crane_lift",
		start_active = false
	}
	self.crane_joystick_right = {
		text_id = "hud_int_crane_right",
		start_active = false
	}
	self.crane_joystick_release = {
		text_id = "hud_int_crane_release",
		start_active = false
	}
	self.gen_int_thermite_rig = {
		text_id = "hud_int_hold_assemble_thermite",
		action_text_id = "hud_action_assemble_thermite",
		special_equipment = "thermite",
		equipment_text_id = "debug_interact_equipment_thermite",
		equipment_consume = true,
		contour = "interactable_icon",
		timer = 20,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.gen_int_thermite_apply = {
		text_id = "hud_int_hold_ignite_thermite",
		action_text_id = "hud_action_ignite_thermite",
		contour = "interactable_icon",
		timer = 2,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.apply_thermite_paste = {
		text_id = "hud_int_hold_ignite_thermite_paste",
		action_text_id = "hud_action_ignite_thermite_paste",
		special_equipment = "thermite_paste",
		equipment_text_id = "hud_int_need_thermite_paste",
		equipment_consume = true,
		start_active = false,
		contour = "interactable_icon",
		timer = 2,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.set_off_alarm = {
		text_id = "hud_int_set_off_alarm",
		action_text_id = "hud_action_setting_off_alarm",
		timer = 0.5,
		start_active = false
	}
	self.hold_open_vault = {
		text_id = "hud_int_hold_open_vault",
		action_text_id = "hud_action_opening_vault",
		timer = 4,
		axis = "y",
		start_active = false
	}
	self.samurai_armor = {
		text_id = "hud_int_hold_bag_sa_armor",
		action_text_id = "hud_action_bagging_sa_armor",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 3,
		sound_start = "bar_bag_armor",
		sound_interupt = "bar_bag_armor_cancel",
		sound_done = "bar_bag_armor_finished"
	}
	self.fingerprint_scanner = {
		text_id = "hud_int_use_scanner",
		start_active = false
	}
	self.enter_code = {
		text_id = "hud_int_enter_code",
		action_text_id = "hud_action_enter_code",
		timer = 1,
		start_active = false,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.take_keys = {
		text_id = "hud_int_take_keys"
	}
	self.take_bank_door_keys = {
		start_active = true,
		text_id = "hud_int_take_door_keys"
	}
	self.hold_unlock_bank_door = {
		text_id = "hud_int_hold_unlock_door",
		action_text_id = "hud_int_action_unlocking_door",
		special_equipment = "door_key",
		equipment_text_id = "hud_int_need_door_keys",
		equipment_consume = false,
		start_active = false,
		timer = 2
	}
	self.take_car_keys = {
		text_id = "hud_int_take_car_keys",
		sound_done = "sps_inter_keys_pickup"
	}
	self.unlock_car_01 = {
		text_id = "hud_int_hold_unlock_car",
		action_text_id = "hud_unlocking_car",
		special_equipment = "car_key_01",
		equipment_text_id = "hud_int_need_car_keys",
		equipment_consume = true,
		start_active = false,
		timer = 2,
		sound_start = "sps_inter_unlock_truck_start_loop",
		sound_interupt = "sps_inter_unlock_truck_stop_loop",
		sound_done = "sps_inter_unlock_truck_success"
	}
	self.unlock_car_02 = deep_clone(self.unlock_car_01)
	self.unlock_car_02.special_equipment = "car_key_02"
	self.unlock_car_02.sound_start = "sps_inter_unlock_truck_start_loop"
	self.unlock_car_02.sound_interupt = "sps_inter_unlock_truck_stop_loop"
	self.unlock_car_02.sound_done = "sps_inter_unlock_truck_success"
	self.unlock_car_03 = deep_clone(self.unlock_car_01)
	self.unlock_car_03.special_equipment = "car_key_03"
	self.unlock_car_03.sound_start = "sps_inter_unlock_truck_start_loop"
	self.unlock_car_03.sound_interupt = "sps_inter_unlock_truck_stop_loop"
	self.unlock_car_03.sound_done = "sps_inter_unlock_truck_success"
	self.push_button = {
		text_id = "hud_int_push_button",
		axis = "z"
	}
	self.use_chute = {
		text_id = "hud_int_use_chute",
		axis = "z"
	}
	self.breach_door = {
		text_id = "debug_interact_crowbar",
		action_text_id = "hud_action_breaching_door",
		start_active = false,
		timer = 2,
		sound_start = "bar_pry_open_elevator_door",
		sound_interupt = "bar_pry_open_elevator_door_cancel",
		sound_done = "bar_pry_open_elevator_door_finished"
	}
	self.bus_wall_phone = {
		text_id = "hud_int_use_phone_signal_bus",
		start_active = false
	}
	self.zipline_mount = {
		text_id = "hud_int_setup_zipline",
		action_text_id = "hud_action_setting_zipline",
		start_active = false,
		timer = 2,
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.rewire_timelock = deep_clone(self.security_station)
	self.rewire_timelock.text_id = "hud_int_rewire_timelock"
	self.rewire_timelock.action_text_id = "hud_action_rewiring_timelock"
	self.rewire_timelock.axis = "x"
	self.pick_lock_x_axis = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_x_axis.axis = "x"
	self.money_wrap_single_bundle_active = deep_clone(self.money_wrap_single_bundle)
	self.money_wrap_single_bundle_active.start_active = true
	self.pku_barcode_downtown = {
		text_id = "hud_int_hold_barcode",
		action_text_id = "hud_action_barcode",
		special_equipment_block = "barcode_downtown",
		timer = 2
	}
	self.pku_barcode_brickell = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_brickell.special_equipment_block = "barcode_brickell"
	self.pku_barcode_edgewater = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_edgewater.special_equipment_block = "barcode_edgewater"
	self.pku_barcode_isles_beach = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_isles_beach.special_equipment_block = "barcode_isles_beach"
	self.pku_barcode_opa_locka = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_opa_locka.special_equipment_block = "barcode_opa_locka"
	self.read_barcode_downtown = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_downtown",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_brickell = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_brickell",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_edgewater = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_edgewater",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_isles_beach = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_isles_beach",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_opa_locka = {
		text_id = "hud_int_hold_read_barcode",
		action_text_id = "hud_action_read_barcode",
		special_equipment = "barcode_opa_locka",
		dont_need_equipment = false,
		possible_special_equipment = {
			"barcode_downtown",
			"barcode_brickell",
			"barcode_edgewater",
			"barcode_isles_beach",
			"barcode_opa_locka"
		},
		equipment_text_id = "hud_equipment_need_barcode",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.read_barcode_activate = {
		text_id = "hud_int_hold_activate_reader",
		action_text_id = "hud_action_activating_reader",
		start_active = false,
		timer = 2
	}
	self.hlm_motor_start = {
		text_id = "hud_int_hold_start_motor",
		action_text_id = "hud_action_startig_motor",
		start_active = false,
		force_update_position = true,
		timer = 2,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.hlm_connect_equip = {
		text_id = "hud_int_hold_connect_equip",
		action_text_id = "hud_action_connecting_equip",
		start_active = false,
		timer = 2
	}
	self.hlm_roll_carpet = {
		text_id = "hud_int_hold_roll_carpet",
		action_text_id = "hud_action_rolling_carpet",
		start_active = false,
		timer = 2,
		sound_start = "bar_roll_carpet",
		sound_interupt = "bar_roll_carpet_cancel",
		sound_done = "bar_roll_carpet_finished"
	}
	self.hold_pku_equipmentbag = {
		text_id = "hud_int_hold_pku_equipment",
		action_text_id = "hud_action_grabbing_equipment",
		timer = 1
	}
	self.disarm_bomb = {
		text_id = "hud_int_hold_disarm_bomb",
		action_text_id = "hud_action_disarm_bomb",
		start_active = false,
		timer = 2.5
	}
	self.pku_take_mask = {
		text_id = "hud_int_take_mask",
		start_active = true
	}
	self.hold_activate_sprinklers = {
		text_id = "hud_int_hold_activate_sprinklers",
		action_text_id = "hud_action_activating_sprinklers",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_thermal_lance_apply",
		sound_interupt = "bar_thermal_lance_apply_cancel",
		sound_done = "bar_thermal_lance_apply_finished"
	}
	self.hold_hlm_open_circuitbreaker = {
		text_id = "hud_int_hold_open_circuitbreaker",
		action_text_id = "hud_action_opening_circuitbreaker",
		start_active = false,
		timer = 0.5
	}
	self.hold_remove_cover = {
		text_id = "hud_int_hold_remove_cover",
		action_text_id = "hud_action_removing_cover",
		start_active = false,
		timer = 0.5
	}
	self.hold_cut_cable = {
		text_id = "hud_int_hold_cut_cable",
		action_text_id = "hud_action_cutting_cable",
		start_active = false,
		timer = 0.5,
		sound_start = "bar_cut_fence",
		sound_interupt = "bar_cut_fence_cancel",
		sound_done = "bar_cut_fence_finished"
	}
	self.firstaid_box = deep_clone(self.doctor_bag)
	self.firstaid_box.start_active = false
	self.first_aid_kit = {
		icon = "equipment_first_aid_kit",
		text_id = "debug_interact_doctor_bag_heal",
		contour = "deployable",
		timer = 0,
		blocked_hint = "full_health",
		sound_start = "bar_helpup",
		sound_interupt = "bar_helpup_cancel",
		sound_done = "bar_helpup_finished",
		action_text_id = "hud_action_healing"
	}
	self.road_spikes = {
		text_id = "hud_int_remove_stinger",
		action_text_id = "hud_action_removing_stinger",
		timer = 2,
		axis = "z",
		start_active = false,
		sound_start = "bar_roadspike",
		sound_interupt = "bar_roadspike_cancel",
		sound_done = "bar_roadspike_finished"
	}
	self.grab_server = {
		text_id = "hud_int_grab_server",
		action_text_id = "hud_action_grab_server",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.pickup_harddrive = {
		text_id = "hud_int_take_harddrive",
		action_text_id = "hud_action_take_harddrive",
		special_equipment_block = "harddrive",
		timer = 1
	}
	self.place_harddrive = {
		text_id = "hud_int_place_harddrive",
		action_text_id = "hud_action_place_harddrive",
		equipment_text_id = "hud_equipment_need_harddrive",
		special_equipment = "harddrive",
		equipment_consume = true,
		timer = 1
	}
	self.invisible_interaction_searching = {
		text_id = "hud_int_search_files",
		action_text_id = "hud_action_searching_files",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		special_equipment_block = "files",
		interact_distance = 200,
		start_active = false,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.invisible_interaction_gathering = {
		text_id = "hud_int_hold_gather_evidence",
		action_text_id = "hud_action_gathering_evidence",
		timer = 2,
		special_equipment_block = "evidence",
		start_active = false
	}
	self.invisible_interaction_checking = {
		text_id = "hud_int_hold_check_evidence",
		action_text_id = "hud_action_checking_evidence",
		equipment_text_id = "hud_equipment_need_evidence",
		special_equipment = "evidence",
		equipment_consume = true,
		timer = 2,
		start_active = false
	}
	self.take_medical_supplies = {
		text_id = "hud_int_take_supplies",
		action_text_id = "hud_int_taking_supplies",
		timer = 2
	}
	self.search_files_false = {
		text_id = "hud_int_search_files",
		action_text_id = "hud_action_searching_files",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		interact_distance = 200,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.use_files = {
		text_id = "hud_int_use_files",
		action_text_id = "hud_action_use_files",
		equipment_text_id = "hud_equipment_need_files",
		special_equipment = "files",
		equipment_consume = true,
		timer = 1,
		contour = "interactable_icon",
		interact_distance = 200
	}
	self.hack_electric_box = {
		text_id = "hud_int_hack_box",
		action_text_id = "hud_action_hack_box",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.take_ticket = {
		text_id = "hud_int_take_ticket",
		action_text_id = "hud_action_take_ticket",
		icon = "equipment_crowbar",
		timer = 3,
		special_equipment_block = "ticket",
		start_active = false,
		sound_start = "bar_ticket",
		sound_interupt = "bar_ticket_cancel",
		sound_done = "bar_ticket_finished"
	}
	self.use_ticket = {
		text_id = "hud_int_use_ticket",
		action_text_id = "hud_action_use_ticket",
		equipment_text_id = "hud_equipment_use_ticket",
		equipment_consume = true,
		timer = 3,
		special_equipment = "ticket",
		sound_start = "bar_ticket",
		sound_interupt = "bar_ticket_cancel",
		sound_done = "bar_ticket_finished"
	}
	self.hold_signal_driver = {}
	self.hold_signal_driver = {
		text_id = "hud_int_signal_driver",
		action_text_id = "hud_action_signaling_driver",
		start_active = false,
		force_update_position = true,
		axis = "z",
		timer = 1.5,
		interact_distance = 500,
		sound_start = "bar_car_tap",
		sound_interupt = "bar_car_tap_cancel",
		sound_done = "bar_car_tap_finished"
	}
	self.hold_hack_comp = {
		text_id = "hud_int_hold_hack_computer",
		action_text_id = "hud_action_hacking_computer",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.hold_approve_req = {
		text_id = "hud_int_hold_approve_request",
		action_text_id = "hud_action_approving_request",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.hold_download_keys = {
		text_id = "hud_int_hold_download_keys",
		action_text_id = "hud_action_downloading_keys",
		start_active = false,
		axis = "z",
		timer = 5,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_analyze_evidence = {
		text_id = "hud_int_hold_analyze_evidence",
		action_text_id = "hud_action_analyzing_evidence",
		start_active = false,
		axis = "z",
		timer = 1
	}
	self.take_bridge = {
		text_id = "hud_int_take_bridge",
		action_text_id = "hud_action_take_bridge",
		special_equipment_block = "bridge",
		timer = 1,
		interact_distance = 200,
		start_active = false
	}
	self.use_bridge = {
		text_id = "hud_int_use_bridge",
		action_text_id = "hud_action_use_bridge",
		equipment_text_id = "hud_equipment_use_bridge",
		equipment_consume = true,
		timer = 2,
		special_equipment = "bridge",
		interact_distance = 500,
		start_active = false
	}
	self.hold_close_keycard = {
		text_id = "hud_int_invisible_interaction_close",
		action_text_id = "hud_action_open_slash_close",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y",
		timer = 0.5
	}
	self.hold_close = {
		text_id = "hud_int_invisible_interaction_close",
		action_text_id = "hud_action_open_slash_close",
		start_active = false,
		axis = "y",
		timer = 0.5
	}
	self.hold_open = {
		text_id = "hud_int_invisible_interaction_open",
		action_text_id = "hud_action_open_slash_close",
		start_active = false,
		axis = "y",
		timer = 0.5
	}
	self.hold_move_car = {
		text_id = "hud_int_hold_move_car",
		action_text_id = "hud_action_moving_car",
		start_active = false,
		timer = 3,
		interact_distance = 150,
		axis = "y",
		sound_start = "bar_cop_car",
		sound_interupt = "bar_cop_car_cancel",
		sound_done = "bar_cop_car_finished"
	}
	self.hold_remove_armor_plating = {
		text_id = "hud_int_hold_remove_armor_plating",
		action_text_id = "hud_action_removing_armor_plating",
		timer = 5,
		sound_start = "bar_steal_circuit",
		sound_interupt = "bar_steal_circuit_cancel",
		sound_done = "bar_steal_circuit_finished"
	}
	self.gen_pku_cocaine_pure = deep_clone(self.gen_pku_cocaine)
	self.gen_pku_cocaine_pure.text_id = "hud_int_hold_take_pure_cocaine"
	self.gen_pku_cocaine_pure.action_text_id = "hud_action_taking_pure_cocaine"
	self.gen_pku_sandwich = {
		text_id = "hud_int_hold_take_sandwich",
		action_text_id = "hud_action_taking_sandwich",
		timer = 3,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.place_flare = {
		text_id = "hud_int_place_flare",
		start_active = false
	}
	self.ignite_flare = {
		text_id = "hud_int_ignite_flare",
		start_active = false
	}
	self.hold_open_xmas_present = {
		text_id = "hud_int_hold_open_xmas_present",
		action_text_id = "hud_action_opening_xmas_present",
		start_active = false,
		timer = 1.5,
		sound_start = "bar_gift_box_open",
		sound_interupt = "bar_gift_box_open_cancel",
		sound_done = "bar_gift_box_open_finished"
	}
	self.c4_bag_dynamic = deep_clone(self.c4_bag)
	self.c4_bag_dynamic.force_update_position = true
	self.shape_charge_plantable_c4_1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_1.special_equipment = "c4_1"
	self.shape_charge_plantable_c4_x1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_x1.special_equipment = "c4_x1"
	self.shape_charge_plantable_c4_x1.interact_distance = 500
	self.hold_call_captain = {
		text_id = "hud_int_hold_call_captain",
		action_text_id = "hud_action_calling_captain",
		start_active = false,
		timer = 1,
		interact_distance = 75
	}
	self.hold_pku_disassemble_cro_loot = {
		text_id = "hud_int_hold_disassemble_cro_loot",
		action_text_id = "hud_action_disassemble_cro_loot",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2,
		axis = "x"
	}
	self.hold_remove_ladder = {
		text_id = "hud_int_hold_remove_ladder",
		action_text_id = "hud_action_remove_ladder",
		start_active = false,
		timer = 2,
		sound_done = "",
		interact_distance = 150
	}
	self.connect_hose = {
		icon = "develop",
		text_id = "hud_int_hold_connect_hose",
		action_text_id = "hud_action_connect_hose",
		start_active = false,
		timer = 4,
		interact_distance = 200,
		sound_start = "bar_hose_ground_connect",
		sound_interupt = "bar_hose_ground_connect_cancel",
		sound_done = "bar_hose_ground_connect_finished"
	}
	self.generator_start = {
		text_id = "hud_generator_start",
		action_text_id = "hud_action_generator_start",
		start_active = false,
		interact_distance = 300
	}
	self.hold_open_bomb_case = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_int_hold_open_case",
		start_active = false,
		timer = 2,
		interact_distance = 120,
		axis = "x"
	}
	self.press_c4_pku = {
		text_id = "hud_int_take_c4",
		contour = "interactable",
		start_active = false,
		interact_distance = 150
	}
	self.open_train_cargo_door = {
		text_id = "hud_int_open_cargo_door",
		start_active = false,
		interact_distance = 150,
		timer = 0.5
	}
	self.close_train_cargo_door = {
		text_id = "hud_int_close_cargo_door",
		start_active = false,
		interact_distance = 150,
		timer = 0.5
	}
	self.take_chainsaw = {
		text_id = "hud_int_take_chainsaw",
		icon = "equipment_chainsaw",
		special_equipment_block = "chainsaw"
	}
	self.use_chainsaw = {
		text_id = "hud_int_hold_cut_tree",
		action_text_id = "hud_action_cutting_tree",
		equipment_text_id = "hint_no_chainsaw",
		special_equipment = "chainsaw",
		equipment_consume = false,
		timer = 2,
		sound_start = "bar_chainsaw",
		sound_interupt = "bar_chainsaw_cancel",
		sound_done = "bar_chainsaw_finished"
	}
	self.hack_ship_control = {
		icon = "interaction_keyboard",
		text_id = "hud_hack_ship_control",
		action_text_id = "hud_hacking_ship_control",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.move_ship_gps_coords = {
		icon = "interaction_keyboard",
		text_id = "hud_move_ship_gps_coords",
		action_text_id = "hud_moving_ship_gps_coords",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.pku_manifest = {
		text_id = "hud_pku_manifest",
		icon = "equipment_manifest",
		special_equipment_block = "manifest",
		start_active = false,
		interact_distance = 150,
		equipment_consume = false
	}
	self.c4_x1_bag = {
		text_id = "debug_interact_c4_bag",
		timer = 4,
		contour = "interactable"
	}
	self.cut_glass = {
		text_id = "hud_int_cut_glass",
		action_text_id = "hud_action_cut_glass",
		timer = 4,
		contour = "interactable_icon",
		axis = "y",
		equipment_text_id = "hud_equipment_need_glass_cutter",
		special_equipment = "mus_glas_cutter",
		sound_start = "bar_glasscutter",
		sound_interupt = "bar_glasscutter_cancel",
		sound_done = "bar_glasscutter_finished"
	}
	self.mus_hold_open_display = {
		text_id = "hud_int_hold_open_display",
		action_text_id = "hud_action_open_display",
		timer = 1
	}
	self.mus_take_diamond = {
		text_id = "debug_interact_diamond"
	}
	self.rewire_electric_box = {
		text_id = "hud_int_rewire_box",
		action_text_id = "hud_action_rewire_box",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.timelock_hack = {
		text_id = "hud_int_hack_timelock",
		action_text_id = "hud_action_hack_timelock",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.hold_unlock_car = {
		text_id = "hud_int_hold_unlock_car",
		action_text_id = "hud_unlocking_car",
		timer = 1,
		equipment_text_id = "hud_equipment_need_car_keys",
		special_equipment = "c_keys",
		equipment_consume = true
	}
	self.gen_pku_evidence_bag = {
		text_id = "hud_int_hold_take_evidence",
		action_text_id = "hud_action_taking_evidence_bag",
		timer = 3,
		axis = "y",
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.mcm_fbi_case = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_opening_case",
		timer = 3
	}
	self.mcm_fbi_taperecorder = {
		text_id = "hud_int_play_tape",
		action_text_id = "hud_action_play_tape",
		timer = 1
	}
	self.mcm_laptop = {
		text_id = "hud_int_hack_laptop",
		action_text_id = "hud_action_hack_laptop",
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.mcm_laptop_code = {
		text_id = "hud_int_grab_code",
		action_text_id = "hud_action_grab_code",
		timer = 2,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.mcm_break_planks = {
		text_id = "hud_int_break_planks",
		action_text_id = "hud_action_break_planks",
		timer = 4,
		sound_start = "bar_wood_fence_break",
		sound_interupt = "bar_wood_fence_cancel",
		sound_done = "bar_wood_fence_finnished"
	}
	self.mcm_panicroom_keycard = {
		text_id = "hud_int_open_panicroom",
		action_text_id = "hud_action_open_panicroom",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y",
		timer = 0.5
	}
	self.mcm_panicroom_keycard_2 = {
		text_id = "hud_int_equipment_keycard",
		equipment_text_id = "hud_int_equipment_no_keycard",
		special_equipment = "bank_manager_key",
		equipment_consume = true,
		start_active = true,
		axis = "y"
	}
	self.gen_prop_container_a_vault_seq = {
		text_id = "hud_int_hold_jam_vent",
		action_text_id = "hud_action_jamming_vent",
		equipment_text_id = "hud_interact_equipment_crowbar",
		special_equipment = "crowbar",
		timer = 1,
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_fan_jam",
		sound_interupt = "bar_fan_jam_cancel",
		sound_done = "bar_fan_jam_finished"
	}
	self.gen_pku_warhead = {
		text_id = "hud_int_hold_take_warhead",
		action_text_id = "hud_action_taking_warhead",
		timer = 3,
		start_active = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished",
		blocked_hint = "carry_block"
	}
	self.gen_pku_warhead_box = {
		text_id = "hud_int_hold_open_case",
		action_text_id = "hud_action_opening_case",
		timer = 2,
		start_active = false,
		sound_start = "bar_open_warhead_box",
		sound_interupt = "bar_open_warhead_box_cancel",
		sound_done = "bar_open_warhead_box_finished"
	}
	self.gen_pku_circle_cutter = {
		text_id = "hud_int_hold_take_circle_cutter",
		action_text_id = "hud_action_taking_circle_cutter",
		timer = 1,
		sound_done = "pick_up_crowbar"
	}
	self.hold_circle_cutter = {
		text_id = "debug_interact_glass_cutter",
		action_text_id = "hud_action_placing_cutter",
		timer = 3,
		equipment_consume = true,
		equipment_text_id = "hud_equipment_need_circle_cutter",
		special_equipment = "circle_cutter",
		sound_start = "bar_drill_apply",
		sound_interupt = "bar_drill_apply_cancel",
		sound_done = "bar_drill_apply_finished"
	}
	self.circle_cutter_jammed = {
		text_id = "debug_interact_cutter_jammed",
		timer = 10,
		sound_start = "bar_drill_fix",
		sound_interupt = "bar_drill_fix_cancel",
		sound_done = "bar_drill_fix_finished"
	}
	self.answer_call = {
		text_id = "hud_int_hold_answer_call",
		action_text_id = "hud_action_answering_call",
		timer = 0.5,
		start_active = false
	}
	self.hold_take_fire_extinguisher = {
		text_id = "hud_int_hold_take_fire_extinguisher",
		action_text_id = "hud_action_taking_fire_extinguisher",
		timer = 1,
		start_active = false,
		special_equipment_block = "fire_extinguisher"
	}
	self.hold_extinguish_fire = {
		text_id = "hud_int_hold_extinguish_fire",
		action_text_id = "hud_action_extinguishing_fire",
		timer = 3,
		axis = "y",
		start_active = false,
		equipment_consume = true,
		equipment_text_id = "hud_equipment_need_fire_extinguisher",
		special_equipment = "fire_extinguisher",
		sound_start = "bar_fire_extinguisher",
		sound_interupt = "bar_fire_extinguisher_cancel",
		sound_done = "bar_fire_extinguisher_finished"
	}
	self.are_laptop = {
		text_id = "hud_int_hold_place_laptop",
		action_text_id = "hud_action_placeing_laptop",
		timer = 3,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.hold_search_c4 = {
		text_id = "hud_int_hold_search_c4",
		action_text_id = "hud_action_searching_c4",
		start_active = false,
		timer = 3,
		sound_start = "bar_gift_box_open",
		sound_interupt = "bar_gift_box_open_cancel",
		sound_done = "bar_gift_box_open_finished"
	}
	self.c4_x10 = deep_clone(self.c4_mission_door)
	self.c4_x10.special_equipment = "c4_x10"
	self.c4_x10.axis = "z"
	self.pick_lock_hard_no_skill_deactivated = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_hard_no_skill_deactivated.start_active = false
	self.are_turn_on_tv = {
		text_id = "hud_int_are_turn_on_tv",
		start_active = false,
		interact_distance = 100,
		axis = "y"
	}
	self.money_wrap_updating = deep_clone(self.money_wrap)
	self.money_wrap_updating.force_update_position = true
	self.panic_room_key = {
		icon = "equipment_chavez_key",
		text_id = "debug_interact_chavez_key_key",
		equipment_text_id = "debug_interact_equiptment_chavez_key",
		special_equipment = "chavez_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.hack_skylight_barrier = {
		text_id = "hud_hack_skylight_barrier",
		action_text_id = "hud_action_hack_skylight_barrier",
		timer = 6,
		start_active = false,
		axis = "y",
		sound_start = "bar_hack_fuse_box",
		sound_interupt = "bar_hack_fuse_box_cancel",
		sound_done = "bar_hack_fuse_box_finished"
	}
	self.take_bottle = {
		text_id = "hud_int_take_bottle",
		action_text_id = "hud_action_take_bottle",
		icon = "equipment_bottle",
		special_equipment_block = "bottle",
		timer = 3
	}
	self.pour_spiked_drink = {
		text_id = "hud_int_pour_drink",
		equipment_text_id = "hint_no_bottle",
		special_equipment = "bottle",
		equipment_consume = true
	}
	self.computer_blueprints = {
		text_id = "hud_int_search_blueprints",
		action_text_id = "hud_action_searching_blueprints",
		timer = 4.5,
		axis = "x",
		contour = "interactable_icon",
		interact_distance = 200,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished",
		icon = "equipment_files",
		special_equipment_block = "blueprints"
	}
	self.use_blueprints = {
		text_id = "hud_int_hold_scan_blueprints",
		action_text_id = "hud_action_scanning_blueprints",
		equipment_text_id = "hint_no_blueprints",
		special_equipment = "blueprints",
		equipment_consume = true,
		timer = 5,
		sound_start = "bar_scan_documents",
		sound_interupt = "bar_scan_documents_cancel",
		sound_done = "bar_scan_documents_finished"
	}
	self.send_blueprints = {
		text_id = "hud_int_send_blueprints"
	}
	self.cas_customer_database = {
		text_id = "hud_check_customer_database",
		action_text_id = "hud_action_cas_checking_customer_database",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.disable_lasers = {
		text_id = "hud_disable_lasers",
		action_text_id = "hud_action_disabling_lasers",
		timer = 6,
		axis = "z",
		start_active = false,
		interact_distance = 150,
		sound_start = "bar_keyboard",
		sound_interupt = "bar_keyboard_cancel",
		sound_done = "bar_keyboard_finished"
	}
	self.pickup_hotel_room_keycard = {
		text_id = "hud_int_take_hotel_keycard",
		special_equipment_block = "hotel_room_key",
		start_active = true
	}
	self.use_hotel_room_key = {
		text_id = "hud_insert_hotel_room_key",
		equipment_text_id = "hint_no_hotel_room_key",
		special_equipment = "hotel_room_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.use_hotel_room_key_no_access = {
		text_id = "hud_insert_hotel_room_key",
		equipment_text_id = "hint_no_hotel_room_key",
		special_equipment = "hotel_room_key",
		equipment_consume = false,
		interact_distance = 150
	}
	self.lift_choose_floor = {
		text_id = "hud_int_lift_choose_floor",
		action_text_id = "hud_action_lift_choose_floor",
		start_active = false,
		interact_distance = 200
	}
	self.cas_open_briefcase = {
		text_id = "hud_open_cas_briefcase",
		action_text_id = "hud_opening_cas_briefcase",
		timer = 2,
		start_active = false,
		interact_distance = 150
	}
	self.cas_open_securityroom_door = {
		text_id = "hud_open_cas_securityroom_door",
		action_text_id = "hud_opening_cas_securityroom_door",
		timer = 1,
		interact_distance = 80,
		axis = "x"
	}
	self.cas_elevator_door_open = {
		text_id = "hud_open_cas_elevator",
		start_active = true,
		interact_distance = 100
	}
	self.cas_elevator_door_close = {
		text_id = "hud_close_cas_elevator",
		start_active = false,
		interact_distance = 100
	}
	self.lockpick_locker = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 2,
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.lockpick_box = {
		contour = "interactable_icon",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 2,
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		action_text_id = "hud_action_picking_lock",
		interact_distance = 100,
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.cas_copy_usb = {
		text_id = "hud_int_copy_data_usb",
		equipment_text_id = "hint_no_usb_key",
		interact_distance = 100,
		special_equipment = "cas_usb_key",
		start_active = false,
		equipment_consume = true
	}
	self.cas_use_usb = {
		text_id = "hud_insert_usb",
		equipment_text_id = "hint_no_data_usb_key",
		special_equipment = "cas_data_usb_key",
		equipment_consume = true,
		interact_distance = 150
	}
	self.cas_take_usb_key = {
		text_id = "hud_take_usb_key",
		interact_distance = 200,
		special_equipment_block = "cas_usb_key",
		start_active = false
	}
	self.cas_take_usb_key_data = {
		text_id = "hud_take_usb_key_data",
		interact_distance = 200,
		special_equipment_block = "cas_data_usb_key",
		start_active = false
	}
	self.cas_screw_down = {
		text_id = "hud_screw_down",
		action_text_id = "hud_action_screwing_down",
		interact_distance = 150,
		timer = 2,
		start_active = false,
		sound_start = "bar_secure_winch",
		sound_interupt = "bar_secure_winch_cancel",
		sound_done = "bar_secure_winch_finished"
	}
	self.cas_start_winch = {
		text_id = "hud_start_winch",
		action_text_id = "hud_action_starting_winch",
		interact_distance = 200,
		timer = 2,
		start_active = false
	}
	self.cas_take_hook = {
		text_id = "hud_take_hook",
		action_text_id = "hud_action_taking_hook",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_start_drill = {
		text_id = "hud_start_drill",
		action_text_id = "hud_action_starting_drill",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_stop_drill = {
		text_id = "hud_stop_drill",
		action_text_id = "hud_action_stoping_drill",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_take_empty_watertank = {
		text_id = "hud_take_watertank",
		action_text_id = "hud_action_taking_watertank",
		timer = 2,
		interact_distance = 100,
		start_active = false,
		sound_start = "bar_replace_empty_watertank",
		sound_interupt = "bar_replace_empty_watertank_cancel",
		sound_done = "bar_replace_empty_watertank_finished"
	}
	self.cas_take_full_watertank = {
		text_id = "hud_take_watertank",
		action_text_id = "hud_action_taking_watertank",
		timer = 2,
		interact_distance = 150,
		start_active = false,
		sound_start = "bar_take_watertank",
		sound_interupt = "bar_take_watertank_cancel",
		sound_done = "bar_take_watertank_finished"
	}
	self.cas_vent_gas = {
		text_id = "hud_place_sleeping_gass",
		action_text_id = "hud_action_placing_sleeping_gass",
		interact_distance = 150,
		timer = 2,
		equipment_text_id = "hint_no_sleeping_gas",
		special_equipment = "cas_sleeping_gas",
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_sleeping_gas",
		sound_interupt = "bar_sleeping_gas_cancel",
		sound_done = "bar_sleeping_gas_finished",
		axis = "x"
	}
	self.cas_connect_power = {
		text_id = "hud_connect_cable",
		action_text_id = "hud_action_connecting_cable",
		interact_distance = 100,
		timer = 2,
		start_active = false
	}
	self.cas_take_sleeping_gas = {
		text_id = "hud_take_sleeping_gas",
		action_text_id = "hud_action_taking_sleeping_gas",
		timer = 2,
		interact_distance = 150,
		special_equipment_block = "cas_sleeping_gas",
		start_active = false
	}
	self.cas_chips_pile = {
		text_id = "hud_take_casino_chips",
		start_active = false,
		interact_distance = 110,
		requires_mask_off_upgrade = {
			upgrade = "mask_off_pickup",
			category = "player"
		},
		can_interact_in_civilian = true
	}
	self.cas_connect_winch_hook = {
		text_id = "hud_connect_which_hook",
		action_text_id = "hud_action_connecting_which_hook",
		equipment_text_id = "hint_no_winch_hook",
		special_equipment = "cas_winch_hook",
		start_active = false,
		interact_distance = 200,
		timer = 2,
		equipment_consume = true
	}
	self.cas_open_powerbox = {
		text_id = "hud_cas_open_powerbox",
		action_text_id = "hud_action_cas_opening_powerbox",
		start_active = false,
		interact_distance = 100,
		timer = 2
	}
	self.cas_take_fireworks_bag = {
		text_id = "hud_cas_take_fireworks_bag",
		action_text_id = "hud_action_cas_taking_fireworks_bag",
		blocked_hint = "carry_block",
		start_active = false,
		timer = 2
	}
	self.cas_ignite_fireworks = {
		text_id = "hud_cas_ignite_fireworks",
		action_text_id = "hud_action_cas_igniting_fireworks",
		start_active = false,
		interact_distance = 200,
		timer = 2,
		sound_start = "bar_light_fireworks",
		sound_interupt = "bar_light_fireworks_cancel",
		sound_done = "bar_light_fireworks_finished"
	}
	self.cas_open_compartment = {
		text_id = "hud_cas_open_compartment",
		start_active = false,
		interact_distance = 150
	}
	self.cas_bfd_drill_toolbox = {
		text_id = "hud_take_bfd_tool",
		interact_distance = 200,
		special_equipment_block = "cas_bfd_tool",
		start_active = false
	}
	self.cas_fix_bfd_drill = {
		text_id = "hud_fix_bfd_drill",
		action_text_id = "hud_action_fixing_bfd_drill",
		interact_distance = 150,
		timer = 10,
		equipment_text_id = "hint_no_bfd_tool",
		special_equipment = "cas_bfd_tool",
		start_active = false,
		equipment_consume = true,
		sound_start = "bar_huge_lance_fix",
		sound_interupt = "bar_huge_lance_fix_cancel",
		sound_done = "bar_huge_lance_fix_finished"
	}
	self.cas_elevator_key = {
		text_id = "hud_take_elevator_key",
		interact_distance = 200,
		special_equipment_block = "cas_elevator_key",
		start_active = false
	}
	self.cas_use_elevator_key = {
		text_id = "hud_use_elevator_key",
		interact_distance = 150,
		equipment_text_id = "hint_no_elevator_key",
		special_equipment = "cas_elevator_key",
		start_active = false,
		equipment_consume = false
	}
	self.cas_open_door = {
		text_id = "hud_cas_open_door",
		start_active = true,
		interact_distance = 150,
		can_interact_in_civilian = true
	}
	self.cas_close_door = {
		text_id = "hud_cas_close_door",
		start_active = false,
		interact_distance = 150,
		can_interact_in_civilian = true
	}
	self.cas_slot_machine = {
		text_id = "hud_int_hold_play_slots",
		action_text_id = "hud_action_playing_slots",
		interact_distance = 100,
		timer = 2,
		start_active = false,
		can_interact_in_civilian = true,
		sound_done = "bar_slot_machine_pull_lever_finished",
		sound_interupt = "bar_slot_machine_pull_lever_cancel",
		sound_start = "bar_slot_machine_pull_lever"
	}
	self.cas_button_01 = {
		text_id = "hud_int_press_01",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_02 = {
		text_id = "hud_int_press_02",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_03 = {
		text_id = "hud_int_press_03",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_04 = {
		text_id = "hud_int_press_04",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_05 = {
		text_id = "hud_int_press_05",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_06 = {
		text_id = "hud_int_press_06",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_07 = {
		text_id = "hud_int_press_07",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_08 = {
		text_id = "hud_int_press_08",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_09 = {
		text_id = "hud_int_press_09",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_0 = {
		text_id = "hud_int_press_0",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_clear = {
		text_id = "hud_int_press_clear",
		start_active = false,
		interact_distance = 50
	}
	self.cas_button_enter = {
		text_id = "hud_int_press_enter",
		start_active = false,
		interact_distance = 50
	}
	self.cas_skylight_panel = {
		text_id = "hud_hack_skylight_panel",
		start_active = false,
		interact_distance = 50
	}
	self.cas_take_unknown = {
		text_id = "hud_take_???",
		action_text_id = "hud_action_taking_???",
		timer = 2,
		interact_distance = 100,
		start_active = false
	}
	self.cas_unpack_turret = {
		text_id = "hud_unpack_turret",
		action_text_id = "hud_action_unpacking_turret",
		timer = 2,
		interact_distance = 150,
		start_active = false
	}
	self.cas_open_guitar_case = {
		text_id = "hud_cas_open_guitar_case",
		action_text_id = "hud_action_cas_opening_guitar_case",
		timer = 3,
		interact_distance = 300,
		start_active = false,
		can_interact_only_in_civilian = true
	}
	self.cas_take_gear = {
		text_id = "hud_cas_take_gear",
		action_text_id = "hud_action_cas_taking_gear",
		contour = "deployable",
		timer = 3,
		interact_distance = 300,
		start_active = false,
		can_interact_only_in_civilian = true
	}
	self.cas_security_door = {
		text_id = "hud_cas_security_door",
		action_text_id = "hud_action_cas_security_door",
		timer = 10,
		interact_distance = 150,
		start_active = false,
		axis = "y"
	}
	self.pick_lock_30 = {
		contour = "interactable_icon",
		icon = "equipment_bank_manager_key",
		text_id = "hud_int_pick_lock",
		start_active = true,
		timer = 30,
		requires_upgrade = {
			upgrade = "pick_lock_hard",
			category = "player"
		},
		action_text_id = "hud_action_picking_lock",
		sound_start = "bar_pick_lock",
		sound_interupt = "bar_pick_lock_cancel",
		sound_done = "bar_pick_lock_finished"
	}
	self.winning_slip = {
		text_id = "hud_int_take_win_slip",
		start_active = false,
		interact_distance = 110,
		can_interact_in_civilian = true
	}
	self.carry_drop_gold = {
		icon = "develop",
		text_id = "hud_interact_gold_pile_take_money",
		timer = 1,
		force_update_position = true,
		action_text_id = "hud_action_taking_gold",
		blocked_hint = "hud_hint_carry_block_interact",
		sound_start = "gold_crate_pickup",
		sound_interupt = "gold_crate_drop",
		sound_done = "gold_crate_drop"
	}
	self.carry_drop_flak_shell = deep_clone(self.carry_drop_gold)
	self.carry_drop_flak_shell.text_id = "hud_take_flak_shell"
	self.carry_drop_flak_shell.action_text_id = "hud_action_taking_flak_shell"
	self.carry_drop_flak_shell.sound_start = "flakshell_take"
	self.carry_drop_flak_shell.sound_done = "flakshell_packed"
	self.carry_drop_flak_shell.sound_interupt = "flakshell_take_stop"
	self.carry_drop_tank_shell = deep_clone(self.carry_drop_gold)
	self.carry_drop_tank_shell.text_id = "hud_take_tank_shell"
	self.carry_drop_tank_shell.action_text_id = "hud_action_taking_tank_shell"
	self.carry_drop_tank_shell.sound_start = "flakshell_take"
	self.carry_drop_tank_shell.sound_done = "flakshell_packed"
	self.carry_drop_tank_shell.sound_interupt = "flakshell_take_stop"
	self.carry_drop_barrel = deep_clone(self.carry_drop_gold)
	self.carry_drop_barrel.text_id = "hud_take_barrel"
	self.carry_drop_barrel.action_text_id = "hud_action_taking_barrel"
	self.hold_pku_intelligence = {
		text_id = "hud_int_pickup_intelligence",
		action_text_id = "hud_action_pickup_intelligence",
		timer = 1,
		interact_distance = 150
	}
	self.dynamite_x1_pku = {
		text_id = "hud_int_take_dynamite",
		action_text_id = "hud_action_taking_dynamite",
		timer = 0.5,
		interact_distance = 200,
		icon = "equipment_dynamite",
		special_equipment_block = "dynamite",
		sound_done = "pickup_dynamite"
	}
	self.mine_pku = {
		text_id = "hud_int_take_mine",
		action_text_id = "hud_action_taking_mine",
		special_equipment_block = "landmine",
		timer = 2,
		start_active = true,
		sound_start = "cvy_pick_up_mine",
		sound_interupt = "cvy_pick_up_mine_cancel_01",
		sound_done = "cvy_pick_up_mine_finish_01"
	}
	self.dynamite_x4_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x4_pku.special_equipment_block = "dynamite_x4"
	self.dynamite_x5_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x5_pku.special_equipment_block = "dynamite_x5"
	self.plant_dynamite = {
		text_id = "hud_plant_dynamite",
		action_text_id = "hud_action_planting_dynamite",
		interact_distance = 150,
		timer = 2,
		equipment_text_id = "hint_no_dynamite",
		special_equipment = "dynamite",
		upgrade_timer_multipliers = {
			{
				upgrade = "dynamite_plant_multiplier",
				category = "interaction"
			}
		},
		start_active = false,
		equipment_consume = true,
		axis = "z",
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.plant_dynamite_x5 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x5.special_equipment = "dynamite_x5"
	self.plant_dynamite_x4 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x4.special_equipment = "dynamite_x4"
	self.plant_dynamite_from_bag = deep_clone(self.plant_dynamite)
	self.plant_dynamite_from_bag.equipment_consume = false
	self.plant_dynamite_from_bag.special_equipment = "dynamite_bag"
	self.plant_mine = {
		text_id = "hud_plant_mine",
		action_text_id = "hud_action_planting_mine",
		interact_distance = 200,
		timer = 2,
		equipment_text_id = "hint_no_mine",
		special_equipment = "landmine",
		start_active = false,
		equipment_consume = true,
		axis = "z",
		sound_start = "cvy_plant_mine_loop_01",
		sound_done = "cvy_plant_mine_finish_01",
		sound_interupt = "cvy_plant_mine_cancel_01"
	}
	self.piano_key_instant_01 = {
		text_id = "hud_play_key_01",
		interact_distance = 135
	}
	self.piano_key_instant_02 = {
		text_id = "hud_play_key_02",
		interact_distance = 135
	}
	self.piano_key_instant_03 = {
		text_id = "hud_play_key_03",
		interact_distance = 135
	}
	self.piano_key_instant_04 = {
		text_id = "hud_play_key_04",
		interact_distance = 135
	}
	self.open_door_instant = {
		text_id = "hud_open_door_instant",
		interact_distance = 200,
		sound_done = "door_open_generic"
	}
	self.open_door_short = {
		text_id = "hud_open_door",
		action_text_id = "hud_action_opening_door",
		icon = "interaction_open_door",
		interact_distance = 200,
		timer = 3,
		start_active = true,
		axis = "y",
		sound_done = "door_open_generic"
	}
	self.open_door_medium = {
		text_id = "hud_open_door",
		action_text_id = "hud_action_opening_door",
		upgrade_timer_multipliers = {
			{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			},
			{
				upgrade = "pick_lock_speed_multiplier",
				category = "player"
			}
		},
		icon = "interaction_open_door",
		interact_distance = 200,
		timer = 5,
		start_active = true,
		axis = "y",
		sound_done = "door_open_generic"
	}
	self.open_crate_2 = {
		text_id = "hud_open_crate_2",
		action_text_id = "hud_action_opening_crate_2",
		interact_distance = 200,
		timer = 0,
		start_active = true,
		loot_table = {
			"basic_crate_tier",
			"crate_scrap_tier"
		},
		sound_done = "crate_open"
	}
	self.open_metalbox = {
		text_id = "hud_open_crate_2",
		action_text_id = "hud_action_opening_crate_2",
		interact_distance = 200,
		start_active = false
	}
	self.take_document = {
		text_id = "hud_take_document",
		interact_distance = 200,
		start_active = true,
		sound_done = "paper_shuffle"
	}
	self.take_documents = {
		text_id = "hud_take_documents",
		interact_distance = 200,
		start_active = true,
		sound_done = "paper_shuffle"
	}
	self.open_window = {
		text_id = "hud_open_window",
		action_text_id = "hud_action_opening_window",
		interact_distance = 200,
		timer = 3,
		axis = "y",
		start_active = false
	}
	self.take_thermite = {
		text_id = "hud_take_thermite",
		action_text_id = "hud_action_taking_thermite",
		special_equipment_block = "thermite",
		timer = 2,
		start_active = true,
		sound_event = "cvy_pick_up_thermite"
	}
	self.set_up_radio = {
		text_id = "hud_int_set_up_radio",
		action_text_id = "hud_action_set_up_radio",
		timer = 4,
		start_active = false
	}
	self.anwser_radio = {
		text_id = "hud_int_answer_radio",
		action_text_id = "hud_action_answering_radio",
		timer = 1,
		start_active = false
	}
	self.tune_radio = deep_clone(self.anwser_radio)
	self.tune_radio.text_id = "hud_sii_tune_radio"
	self.tune_radio.action_text_id = "hud_action_sii_tune_radio"
	self.tune_radio.timer = 2
	self.ignite_thermite = {
		text_id = "hud_ignite_thermite",
		action_text_id = "hud_action_igniting_thermite",
		special_equipment = "thermite",
		equipment_text_id = "hud_int_need_thermite",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.untie_zeppelin = {
		text_id = "hud_untie_zeppelin",
		action_text_id = "hud_action_untying_zeppelin",
		interact_distance = 200,
		timer = 3,
		start_active = false
	}
	self.take_tank_grenade = {
		text_id = "hud_take_tank_grenade",
		action_text_id = "hud_action_taking_tank_grenade",
		special_equipment_block = "tank_grenade",
		timer = 2,
		start_active = true
	}
	self.replace_tank_grenade = {
		text_id = "hud_replace_tank_grenade",
		action_text_id = "hud_action_replacing_tank_grenade",
		special_equipment = "tank_grenade",
		equipment_text_id = "hud_no_tank_grenade",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.take_tools = {
		text_id = "hud_take_tools",
		action_text_id = "hud_action_taking_tools",
		special_equipment_block = "repair_tools",
		timer = 2,
		start_active = true,
		sound_done = "pickup_tools"
	}
	self.repair = {
		text_id = "hud_repair",
		action_text_id = "hud_action_repairing",
		special_equipment = "repair_tools",
		equipment_text_id = "hud_no_tools",
		equipment_consume = false,
		start_active = false,
		timer = 2
	}
	self.take_gas_tank = {
		text_id = "hud_take_gas_tank",
		action_text_id = "hud_action_taking_gas_tank",
		special_equipment_block = "gas_tank",
		timer = 2,
		start_active = true
	}
	self.hold_remove_latch = {
		text_id = "hud_int_remove_latch",
		action_text_id = "hud_action_remove_latch",
		timer = 2,
		start_active = false,
		axis = "y"
	}
	self.replace_gas_tank = {
		text_id = "hud_replace_gas_tank",
		action_text_id = "hud_action_replacing_gas_tank",
		special_equipment = "gas_tank",
		equipment_text_id = "hud_no_gas_tank",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.take_gold_brick = {
		text_id = "hud_take_gold_brick",
		start_active = true
	}
	self.take_gold_pile = {
		icon = "interaction_gold",
		text_id = "hud_interact_gold_pile_take_money",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_taking_gold",
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.open_toolbox = {
		text_id = "hud_open_toolbox",
		action_text_id = "hud_action_opening_toolbox",
		start_active = false,
		timer = 2,
		interact_distance = 200,
		sound_start = "toolbox_interact_start",
		sound_done = "toolbox_interact_stop",
		sound_interupt = "toolbox_interact_stop"
	}
	self.take_safe_key = {
		text_id = "hud_take_safe_key",
		special_equipment_block = "safe_key",
		start_active = true,
		sound_done = "sto_pick_up_key"
	}
	self.unlock_the_safe = {
		text_id = "hud_unlock_safe",
		action_text_id = "hud_action_unlocking_safe",
		special_equipment = "safe_key",
		equipment_text_id = "hud_no_safe_key",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.pour_acid = {
		text_id = "hud_pour_acid",
		action_text_id = "hud_action_pouring_acid",
		special_equipment = "acid",
		equipment_text_id = "hud_int_need_acid",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.take_acid = {
		text_id = "hud_take_acid",
		action_text_id = "hud_action_taking_acid",
		special_equipment_block = "acid",
		start_active = true,
		timer = 2
	}
	self.take_sps_briefcase = {
		text_id = "hud_take_briefcase",
		action_text_id = "hud_action_taking_briefcase",
		special_equipment_block = "briefcase",
		start_active = true,
		timer = 2,
		sound_done = "sps_pick_up_briefcase"
	}
	self.take_thermite = {
		text_id = "hud_int_take_thermite",
		special_equipment_block = "thermite",
		start_active = true,
		sound_event = "cvy_pick_up_thermite"
	}
	self.use_thermite = {
		text_id = "hud_int_hold_use_thermite",
		action_text_id = "hud_action_hold_using_thermite",
		special_equipment = "thermite",
		equipment_text_id = "hud_int_need_thermite_cvy",
		equipment_consume = true,
		start_active = true,
		timer = 3,
		sound_start = "cvy_place_thermite",
		sound_interupt = "cvy_place_thermite_cancel",
		sound_done = "cvy_place_thermite_cancel"
	}
	self.open_lid = {
		text_id = "hud_int_open_lid",
		start_active = true,
		sound_event = "brh_holding_cells_door_lid"
	}
	self.pku_codemachine_part_01 = {
		text_id = "hud_take_codemachine_part_01",
		action_text_id = "hud_action_taking_codemachine_part_01",
		start_active = true,
		timer = 1,
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.pku_codemachine_part_02 = {
		text_id = "hud_take_codemachine_part_02",
		action_text_id = "hud_action_taking_codemachine_part_03",
		start_active = true,
		timer = 1,
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.pku_codemachine_part_03 = {
		text_id = "hud_take_codemachine_part_03",
		action_text_id = "hud_action_taking_codemachine_part_03",
		start_active = true,
		timer = 1,
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.pku_codemachine_part_04 = {
		text_id = "hud_take_codemachine_part_04",
		action_text_id = "hud_action_taking_codemachine_part_04",
		start_active = true,
		timer = 1,
		blocked_hint = "hud_hint_carry_block_interact"
	}
	self.take_gold_bar_mold = {
		text_id = "hud_take_gold_bar_mold",
		action_text_id = "hud_action_taking_gold_bar_mold",
		start_active = true,
		timer = 2,
		special_equipment_block = "gold_bar_mold"
	}
	self.place_mold = {
		text_id = "hud_place_mold",
		action_text_id = "hud_action_placing_mold",
		special_equipment = "gold_bar_mold",
		equipment_text_id = "hud_int_need_gold_bar_mold",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.take_tank_shell = {
		text_id = "hud_take_tank_shell",
		action_text_id = "hud_action_taking_tank_shell",
		special_equipment_block = "tank_shell",
		start_active = false,
		timer = 2
	}
	self.place_tank_shell = {
		text_id = "hud_place_tank_shell",
		action_text_id = "hud_action_placing_tank_shell",
		special_equipment = "tank_shell",
		equipment_text_id = "hud_int_need_tank_shell",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.graveyard_check_tank = {
		text_id = "hud_graveyard_check_tank",
		action_text_id = "hud_action_graveyard_check_tank",
		start_active = true,
		timer = 2,
		special_equipment_block = "gold_bar_mold"
	}
	self.graveyard_drag_pilot_1 = {
		text_id = "hud_graveyard_drag_pilot_1",
		action_text_id = "hud_action_graveyard_drag_pilot_1",
		start_active = true,
		timer = 2,
		special_equipment_block = "gold_bar_mold"
	}
	self.search_radio_parts = {
		text_id = "hud_search_radio_parts",
		action_text_id = "hud_action_searching_radio_parts",
		start_active = false,
		timer = 4,
		special_equipment_block = "radio_parts"
	}
	self.replace_radio_parts = {
		text_id = "hud_replace_radio_parts",
		action_text_id = "hud_action_replacing_radio_parts",
		special_equipment = "radio_parts",
		equipment_text_id = "hud_int_need_radio_parts",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.take_blacksmith_tong = {
		text_id = "hud_take_blacksmith_tong",
		start_active = false,
		special_equipment_block = "blacksmith_tong"
	}
	self.turret_m2 = {
		text_id = "hud_turret_m2",
		action_text_id = "hud_action_mounting_turret",
		start_active = true,
		timer = 0.5
	}
	self.turret_flak_88 = {
		text_id = "hud_turret_88",
		action_text_id = "hud_action_mounting_turret",
		start_active = false,
		timer = 0.5,
		interact_distance = 400,
		axis = "z"
	}
	self.turret_flakvierling = {
		text_id = "hud_int_hold_turret_flakvierling",
		action_text_id = "hud_action_turret_flakvierling",
		start_active = true,
		timer = 1,
		interact_distance = 400
	}
	self.start_ladle = {
		start_active = "false",
		text_id = "hud_start_ladle"
	}
	self.stop_ladle = {
		start_active = "false",
		text_id = "hud_stop_ladle"
	}
	self.cool_gold_bar = {
		text_id = "hud_cool_gold_bar",
		action_text_id = "hud_action_cooling_gold_bar",
		special_equipment = "gold_bar",
		equipment_text_id = "hud_int_need_gold_bar",
		equipment_consume = true,
		start_active = false,
		timer = 2
	}
	self.pour_iron = {
		text_id = "hud_pour_iron",
		start_active = false
	}
	self.open_chest = {
		text_id = "hud_open_chest",
		action_text_id = "hud_action_opening_chest",
		start_active = false,
		timer = 2
	}
	self.take_contraband_jewelry = {
		text_id = "hud_take_contraband_jewelry",
		action_text_id = "hud_action_taking_contraband_jewelry",
		start_active = true,
		timer = 2
	}
	self.open_radio_hatch = {
		text_id = "hud_open_radio_hatch",
		action_text_id = "hud_action_opening_radio_hatch",
		start_active = false,
		timer = 2
	}
	self.open_tank_hatch = {
		text_id = "hud_open_tank_hatch",
		action_text_id = "hud_action_opening_tank_hatch",
		start_active = false,
		timer = 2
	}
	self.open_hatch = {
		text_id = "hud_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		start_active = false,
		timer = 2
	}
	self.break_open_door = {
		text_id = "hud_break_open_door",
		action_text_id = "hud_action_breaking_opening_door",
		special_equipment = "crowbar",
		equipment_text_id = "hud_int_need_crowbar",
		equipment_consume = false,
		start_active = false,
		timer = 3,
		axis = "x"
	}
	self.open_vault_door = {
		text_id = "hud_open_vault_door",
		action_text_id = "hud_action_opening_vault_door",
		start_active = false,
		timer = 3
	}
	self.breach_open_door = {
		text_id = "hud_breach_door",
		action_text_id = "hud_action_breaching_door",
		start_active = false,
		timer = 3
	}
	self.take_blow_torch = {
		text_id = "hud_take_blow_torch",
		special_equipment_block = "blow_torch",
		equipment_consume = false,
		start_active = false
	}
	self.fill_blow_torch = {
		text_id = "hud_fill_blow_torch",
		action_text_id = "hud_action_filling_blow_torch",
		special_equipment = "blow_torch",
		special_equipment_block = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch",
		equipment_consume = false,
		start_active = false,
		timer = 5
	}
	self.cut_vault_bars = {
		text_id = "hud_cut_vault_bars",
		action_text_id = "hud_action_cutting_vault_bars",
		special_equipment = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch_fuel",
		equipment_consume = true,
		start_active = true,
		timer = 5
	}
	self.take_torch_tank = {
		text_id = "hud_take_torch_tank",
		action_text_id = "hud_action_taking_torch_tank",
		start_active = false,
		timer = 3
	}
	self.sii_test = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		interact_distance = 500,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.sii_lockpick_easy_y_direction = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.sii_lockpick_easy = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.sii_lockpick_medium_y_direction = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_medium_y_direction
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.sii_lockpick_medium = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.sii_lockpick_hard_y_direction = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.sii_lockpick_hard = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		},
		loot_table = {
			"lockpick_crate_tier",
			"crate_scrap_tier"
		}
	}
	self.take_turret_m2_gun = {
		text_id = "hud_take_turret_m2_gun",
		action_text_id = "hud_action_taking_turret_m2_gun",
		start_active = false,
		timer = 3,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop"
	}
	self.take_turret_m2_gun_enabled = {
		text_id = "hud_take_turret_m2_gun",
		action_text_id = "hud_action_taking_turret_m2_gun",
		start_active = true,
		timer = 3,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop"
	}
	local com_wheel_color = Color(1, 0.8, 0)

	local function com_wheel_clbk(say_target_id, default_say_id, post_prefix, past_prefix, waypoint_tech)
		local character = managers.network:session():local_peer()._character
		local nationality = CriminalsManager.comm_wheel_callout_from_nationality(character)
		local snd = post_prefix .. nationality .. past_prefix
		local text = nil
		local player = managers.player:player_unit()

		if not player then
			return
		end

		local target, target_nationality = player:movement():current_state():teammate_aimed_at_by_player()

		if target ~= nil then
			local target_char = CriminalsManager.comm_wheel_callout_from_nationality(target_nationality)

			if target_char == nationality and nationality ~= "amer" then
				target_char = "amer"
			elseif target_char == nationality and nationality == "amer" then
				target_char = "brit"
			end

			if nationality == "russian" then
				nationality = "rus"
			end

			text = managers.localization:text(say_target_id, {
				TARGET = target
			})

			if not managers.dialog:is_dialogue_playing_for_local_player() then
				managers.player:stop_all_speaking_except_dialog()
				managers.player:player_unit():sound():say(nationality .. "_call_" .. target_char, nil, true)
				managers.player:player_unit():sound():queue_sound("comm_wheel", post_prefix .. nationality .. past_prefix, nil, true)
			end
		else
			text = managers.localization:text(default_say_id)

			if not managers.dialog:is_dialogue_playing_for_local_player() then
				managers.player:stop_all_speaking_except_dialog()
				managers.player:player_unit():sound():say(post_prefix .. nationality .. past_prefix, false, true)
			end
		end

		managers.chat:send_message(ChatManager.GAME, "Player", text)
	end

	self.com_wheel = {
		icon = "develop",
		color = com_wheel_color,
		text_id = "debug_interact_temp_interact_box",
		wheel_radius_inner = 120,
		wheel_radius_outer = 150,
		text_padding = 25,
		cooldown = 1,
		options = {
			{
				id = "yes",
				text_id = "com_wheel_yes",
				icon = "comm_wheel_yes",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_yes",
					"com_wheel_say_yes",
					"com_",
					"_yes"
				}
			},
			{
				id = "no",
				text_id = "com_wheel_no",
				icon = "comm_wheel_no",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_no",
					"com_wheel_say_no",
					"com_",
					"_no"
				}
			},
			{
				id = "found_it",
				text_id = "com_wheel_found_it",
				icon = "comm_wheel_found_it",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_found_it",
					"com_wheel_say_found_it",
					"com_",
					"_found"
				}
			},
			{
				id = "wait",
				text_id = "com_wheel_wait",
				icon = "comm_wheel_wait",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_wait",
					"com_wheel_say_wait",
					"com_",
					"_wait"
				}
			},
			{
				id = "not_here",
				text_id = "com_wheel_not_here",
				icon = "comm_wheel_not_here",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_not_here",
					"com_wheel_say_not_here",
					"com_",
					"_notfound"
				}
			},
			{
				id = "follow_me",
				text_id = "com_wheel_follow_me",
				icon = "comm_wheel_follow_me",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_follow_me",
					"com_wheel_say_follow_me",
					"com_",
					"_follow"
				}
			},
			{
				id = "assistance",
				text_id = "com_wheel_assistance",
				icon = "comm_wheel_assistance",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_assistance",
					"com_wheel_say_assistance",
					"com_",
					"_help"
				}
			},
			{
				id = "enemy",
				text_id = "com_wheel_enemy",
				icon = "comm_wheel_enemy",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_enemy",
					"com_wheel_say_enemy",
					"com_",
					"_enemy"
				}
			}
		}
	}
	self.take_money_print_plate = {
		text_id = "hud_take_money_print_plate",
		action_text_id = "hud_action_taking_money_print_plate",
		start_active = false,
		timer = 3
	}
	self.signal_light = {
		text_id = "hud_signal_light",
		start_active = true,
		axis = "z"
	}
	self.take_safe_keychain = {
		text_id = "hud_take_safe_keychain",
		start_active = true,
		special_equipment_block = "safe_keychain",
		equipment_consume = false
	}
	self.unlock_the_safe_keychain = {
		text_id = "hud_unlock_safe",
		action_text_id = "hud_action_unlocking_safe",
		special_equipment = "safe_keychain",
		equipment_text_id = "hud_no_safe_keychain",
		equipment_consume = false,
		start_active = false,
		timer = 2
	}
	self.take_gear = {
		text_id = "hud_take_gear",
		action_text_id = "hud_action_taking_gear",
		start_active = false,
		interact_distance = 250,
		timer = 3,
		can_interact_in_civilian = true
	}
	self.take_ladder = {
		text_id = "hud_take_ladder",
		action_text_id = "hud_action_taking_ladder",
		start_active = false,
		interact_distance = 250,
		timer = 3,
		sound_start = "ladder_pickup_loop_start",
		sound_interupt = "ladder_pickup_complete",
		sound_done = "ladder_pickup_complete"
	}
	self.take_flak_shell = {
		text_id = "hud_take_flak_shell",
		action_text_id = "hud_action_taking_flak_shell",
		start_active = false,
		interact_distance = 300,
		timer = 1.5,
		sound_start = "flakshell_take",
		sound_done = "flakshell_packed",
		sound_interupt = "flakshell_take_stop"
	}
	self.take_flak_shell_bag = deep_clone(self.take_flak_shell)
	self.take_flak_shell_bag.force_update_position = true
	self.take_flak_shell_bag.start_active = true
	self.take_flak_shell_bag.timer = 1
	self.take_plank = {
		text_id = "hud_take_plank",
		action_text_id = "hud_action_taking_plank",
		start_active = false,
		interact_distance = 300,
		timer = 0.5,
		sound_done = "take_plank"
	}
	self.take_plank_bag = deep_clone(self.take_plank)
	self.take_plank_bag.force_update_position = true
	self.take_plank_bag.start_active = true
	self.take_flak_shell_pallete = {
		text_id = "hud_take_flak_shell_pallete",
		action_text_id = "hud_action_taking_flak_shell_pallete",
		start_active = false,
		interact_distance = 250,
		timer = 3
	}
	self.activate_elevator = {
		text_id = "hud_activate_elevator",
		start_active = false,
		interact_distance = 250
	}
	self.lift_trap_door = {
		text_id = "hud_lift_trap_door",
		start_active = false,
		interact_distance = 300
	}
	self.open_drop_pod = {
		text_id = "hud_open_drop_pod",
		action_text_id = "hud_action_opening_drop_pod",
		start_active = false,
		interact_distance = 300,
		timer = 2,
		sound_start = "open_drop_pod_start",
		sound_interupt = "open_drop_pod_interrupt"
	}
	self.pour_lava_ladle_01 = {
		text_id = "hud_pour_lava",
		action_text_id = "hud_action_pouring_lava",
		start_active = false,
		interact_distance = 250,
		timer = 3
	}
	self.open_army_crate = {
		text_id = "hud_open_army_crate",
		action_text_id = "hud_action_opening_army_crate",
		special_equipment = "crowbar",
		equipment_text_id = "hud_int_need_crowbar",
		equipment_consume = false,
		start_active = false,
		interact_distance = 250,
		timer = 1.5,
		upgrade_timer_multipliers = {
			{
				upgrade = "open_crate_multiplier",
				category = "interaction"
			}
		},
		loot_table = {
			"crowbar_crate_tier",
			"crate_scrap_tier"
		},
		sound_start = "crowbarcrate_open",
		sound_done = "crate_open",
		sound_interupt = "stop_crowbarcrate_open"
	}
	self.open_fusebox = {
		text_id = "hud_open_fusebox",
		action_text_id = "hud_action_opening_fusebox",
		start_active = false,
		interact_distance = 250,
		timer = 2
	}
	self.activate_trigger = {
		text_id = "hud_activate_trigger",
		action_text_id = "hud_action_activating_trigger",
		start_active = false,
		interact_distance = 250,
		timer = 1
	}
	self.sii_tune_radio = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.si_revive = {
		icon = "develop",
		text_id = "skill_interaction_revive",
		action_text_id = "skill_interaction_revive",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.sii_tune_radio_easy = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.sii_tune_radio_medium = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.activate_switch = {
		icon = "develop",
		text_id = "hud_activate_switch",
		action_text_id = "hud_action_activate_switch",
		axis = "y",
		interact_distance = 200,
		timer = 2.335
	}
	self.activate_switch_easy = deep_clone(self.activate_switch)
	self.activate_switch_medium = deep_clone(self.activate_switch)
	self.rewire_fuse_pane = {
		icon = "develop",
		text_id = "hud_rewire_fuse_pane",
		action_text_id = "hud_action_rewire_fuse_pane",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.rewire_fuse_pane_easy = {
		icon = "develop",
		text_id = "hud_rewire_fuse_pane",
		action_text_id = "hud_action_rewire_fuse_pane",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.rewire_fuse_pane_medium = {
		icon = "develop",
		text_id = "hud_rewire_fuse_pane",
		action_text_id = "hud_action_rewire_fuse_pane",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_door = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_door_easy = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_door_medium = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_window = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_window_easy = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.picklock_window_medium = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.call_mrs_white = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.call_mrs_white_easy = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.call_mrs_white_medium = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.activate_burners = {
		icon = "develop",
		text_id = "hud_activate_burners",
		action_text_id = "hud_action_activate_burners",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 3,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
			self.MINIGAME_CIRCLE_RADIUS_BIG
		},
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.activate_burners_easy = {
		icon = "develop",
		text_id = "hud_activate_burners",
		action_text_id = "hud_action_activate_burners",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 1,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL
		},
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.activate_burners_medium = {
		icon = "develop",
		text_id = "hud_activate_burners",
		action_text_id = "hud_action_activate_burners",
		axis = "y",
		interact_distance = 200,
		number_of_circles = 2,
		circle_radius = {
			self.MINIGAME_CIRCLE_RADIUS_SMALL,
			self.MINIGAME_CIRCLE_RADIUS_MEDIUM
		},
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.take_parachute = {
		text_id = "hud_take_parachute",
		start_active = false,
		interact_distance = 250
	}
	self.take_bolt_cutter = {
		text_id = "hud_take_bolt_cutter",
		start_active = false,
		interact_distance = 250,
		special_equipment_block = "bolt_cutter"
	}
	self.cut_chain_bolt_cutter = {
		text_id = "hud_cut_chain",
		action_text_id = "hud_action_cutting_chain",
		special_equipment = "bolt_cutter",
		equipment_text_id = "hud_int_need_bolt_cutter",
		equipment_consume = false,
		start_active = false,
		timer = 1
	}
	self.take_painting = {
		text_id = "hud_take_painting",
		action_text_id = "hud_action_taking_painting",
		start_active = false,
		interact_distance = 250,
		timer = 2.5,
		sound_start = "sto_painting",
		sound_interupt = "sto_painting_cancel",
		sound_done = "sto_painting_finish"
	}
	self.take_painting_active = deep_clone(self.take_painting)
	self.take_painting_active = {
		text_id = "hud_take_painting",
		action_text_id = "hud_action_taking_painting",
		interact_distance = 250,
		timer = 1.5,
		sound_start = nil,
		sound_interupt = nil,
		sound_done = "sto_pick_up_painting",
		start_active = true
	}
	self.take_bonds = {
		text_id = "hud_take_bonds",
		action_text_id = "hud_action_taking_bonds",
		start_active = false,
		timer = 1,
		blocked_hint = "carry_block"
	}
	self.take_tank_crank = {
		text_id = "hud_take_tank_crank",
		start_active = false,
		interact_distance = 250,
		special_equipment_block = "tank_crank"
	}
	self.start_the_tank = {
		text_id = "hud_start_tank",
		action_text_id = "hud_action_starting_tank",
		start_active = false,
		interact_distance = 250,
		timer = 5
	}
	self.take_tank_shells = {
		text_id = "hud_take_tank_shells",
		action_text_id = "hud_action_taking_tank_shells",
		start_active = false,
		interact_distance = 250,
		timer = 5
	}
	self.turn_searchlight = {
		text_id = "hud_turn_searchlight",
		action_text_id = "hud_action_turning_searchlight",
		start_active = false,
		interact_distance = 250,
		sound_start = "searchlight_interaction_loop_start",
		sound_done = "searchlight_interaction_loop_stop",
		sound_interupt = "searchlight_interaction_loop_stop",
		timer = 2.5
	}
	self.take_dynamite_bag = {
		text_id = "hud_int_take_dynamite",
		action_text_id = "hud_action_taking_dynamite",
		timer = 2,
		interact_distance = 250,
		icon = "equipment_dynamite",
		special_equipment_block = "dynamite_bag",
		sound_done = "pickup_dynamite"
	}
	self.plant_dynamite_bag = {
		text_id = "hud_plant_dynamite_bag",
		action_text_id = "hud_action_planting_dynamite_bag",
		interact_distance = 250,
		timer = 5,
		equipment_text_id = "hint_no_dynamite_bag",
		upgrade_timer_multipliers = {
			{
				upgrade = "dynamite_plant_multiplier",
				category = "interaction"
			}
		},
		special_equipment = "dynamite_bag",
		start_active = false,
		equipment_consume = true,
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.flaktrum_raid_start = {
		text_id = "hud_start_flaktrum_raid",
		action_text_id = "hud_action_starting_flaktrum_raid",
		interact_distance = 200,
		timer = 1
	}
	self.take_cable = {
		text_id = "hud_take_cable",
		action_text_id = "hud_action_taking_cable",
		interact_distance = 200,
		timer = 2,
		force_update_position = true,
		sound_done = "el_cable_connected",
		sound_start = "el_cable_connect",
		sound_interupt = "el_cable_connect_stop"
	}
	self.open_cargo_door = {
		text_id = "hud_int_open_cargo_door",
		action_text_id = "hud_action_opening_cargo_door",
		interact_distance = 200
	}
	self.close_cargo_door = {
		text_id = "hud_int_close_cargo_door",
		action_text_id = "hud_action_closing_cargo_door",
		interact_distance = 200
	}
	self.lockpick_cargo_door = deep_clone(self.open_cargo_door)
	self.lockpick_cargo_door.number_of_circles = 1
	self.lockpick_cargo_door.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.lockpick_cargo_door.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.lockpick_cargo_door.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.lockpick_cargo_door.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.lockpick_cargo_door.sounds = {
		success = "success",
		failed = "lock_fail",
		circles = {
			{
				mechanics = "lock_mechanics_a",
				lock = "lock_a"
			},
			{
				mechanics = "lock_mechanics_b",
				lock = "lock_b"
			},
			{
				mechanics = "lock_mechanics_c",
				lock = "lock_c"
			}
		}
	}
	self.hold_couple_wagon = {
		text_id = "hud_int_hold_couple_wagon",
		action_text_id = "hud_action_coupling_wagon",
		start_active = false,
		interact_distance = 300,
		timer = 0.5
	}
	self.hold_decouple_wagon = deep_clone(self.hold_couple_wagon)
	self.hold_decouple_wagon.text_id = "hud_int_hold_decouple_wagon"
	self.hold_decouple_wagon.action_text_id = "hud_action_decoupling_wagon"
	self.hold_pull_lever = {
		text_id = "hud_int_hold_pull_lever",
		action_text_id = "hud_action_pulling_lever",
		start_active = false,
		interact_distance = 150,
		timer = 0.5,
		force_update_position = true,
		sound_start = "rail_switch_interaction_loop_start",
		sound_done = "rail_switch_interaction_loop_stop",
		sound_interupt = "rail_switch_interaction_loop_stop"
	}
	self.hold_get_gear = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		start_active = false,
		interact_distance = 300,
		timer = 1.5
	}
	self.hold_open_crate_tut = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		start_active = false,
		interact_distance = 300,
		timer = 1.5,
		sound_start = "camp_unpack_stuff",
		sound_done = "camp_unpacked"
	}
	self.hold_get_gear_short_range = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		start_active = false,
		interact_distance = 300,
		timer = 1.5
	}
	self.hold_remove_blocker = {
		text_id = "hud_int_hold_remove_blocker",
		action_text_id = "hud_action_removing_blocker",
		start_active = false,
		interact_distance = 250,
		timer = 1,
		axis = "y",
		sound_start = "loco_blocker_remove_start",
		sound_done = "loco_blocker_remove_stop",
		sound_interupt = "loco_blocker_remove_stop"
	}
	self.hold_open_hatch = {
		text_id = "hud_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		timer = 0.5,
		start_active = false,
		sound_done = "open_hatch_done"
	}
	self.take_landmines = {
		text_id = "hud_take_landmines",
		action_text_id = "hud_action_taking_landmines",
		timer = 3,
		start_active = false,
		interact_distance = 250,
		sound_start = "cvy_pick_up_mine",
		sound_interupt = "cvy_pick_up_mine_cancel_01",
		sound_done = "cvy_pick_up_mine_finish_01"
	}
	self.hold_take_wine_crate = {
		text_id = "hud_take_wine_crate",
		action_text_id = "hud_action_taking_wine_crate",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_cigar_crate = {
		text_id = "hud_take_cigar_crate",
		action_text_id = "hud_action_taking_cigar_crate",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_chocolate_box = {
		text_id = "hud_take_chocolate_box",
		action_text_id = "hud_action_taking_chocolate_box",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_crucifix = {
		text_id = "hud_take_crucifix",
		action_text_id = "hud_action_taking_crucifix",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_baptismal_font = {
		text_id = "hud_take_baptismal_font",
		action_text_id = "hud_action_taking_baptismal_font",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_religious_figurine = {
		text_id = "hud_take_religious_figurine",
		action_text_id = "hud_action_taking_religious_figurine",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.hold_take_candelabrum = {
		text_id = "hud_take_candelabrum",
		action_text_id = "hud_action_taking_candelabrum",
		timer = 1,
		start_active = true,
		interact_distance = 250
	}
	self.place_landmine = {
		text_id = "hud_place_landmine",
		action_text_id = "hud_action_placing_landmine",
		timer = 3,
		start_active = false,
		interact_distance = 250,
		equipment_text_id = "hint_no_landmines",
		special_equipment = "landmine",
		equipment_consume = true
	}
	self.hold_start_locomotive = {
		text_id = "hud_int_signal_driver",
		action_text_id = "hud_action_signaling_driver",
		timer = 1,
		start_active = false
	}
	self.free_radio_tehnician = {
		text_id = "hud_untie_tehnician",
		action_text_id = "hud_action_untying_technician",
		timer = 5,
		start_active = false,
		interact_distance = 250,
		sound_start = "untie_rope_loop_interact_start",
		sound_done = "untie_rope_interact_end",
		sound_interupt = "untie_rope_loop_interrupt"
	}
	self.rig_dynamite = {
		text_id = "hud_int_rig_dynamite",
		action_text_id = "hud_action_rig_dynamite",
		timer = 5,
		interact_distance = 250,
		upgrade_timer_multipliers = {
			{
				upgrade = "dynamite_plant_multiplier",
				category = "interaction"
			}
		},
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing",
		special_equipment = "dynamite",
		equipment_consume = true
	}
	self.hold_pull_down_ladder = {
		text_id = "hud_int_pull_down_ladder",
		action_text_id = "hud_action_pull_down_ladder",
		timer = 2,
		sound_done = "ladder_pull",
		interact_distance = 250
	}
	self.detonate_the_dynamite = {
		text_id = "hud_int_detonate_the_dynamite",
		action_text_id = "hud_action_detonate_the_dynamite",
		timer = 0,
		sound_done = "bridge_switch_start",
		interact_distance = 250
	}
	self.detonate_the_dynamite_panel = {
		text_id = "hud_int_detonate_the_dynamite",
		action_text_id = "hud_action_detonate_the_dynamite",
		timer = 0,
		sound_done = "bridge_switch_start",
		interact_distance = 110,
		start_active = false
	}
	self.generic_press_panel = deep_clone(self.detonate_the_dynamite_panel)
	self.generic_press_panel.text_id = "hud_hold_open_barrier"
	self.generic_press_panel.action_text_id = "hud_action_opening_barrier"
	self.hold_call_boat_driver = {
		text_id = "hud_int_hold_call_boat_driver",
		action_text_id = "hud_action_hold_call_boat_driver",
		timer = 3,
		sound_done = "",
		interact_distance = 250
	}
	self.cut_cage_lock = {
		text_id = "hud_cut_cage_lock",
		action_text_id = "hud_action_cutting_cage_lock",
		special_equipment = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch_fuel",
		equipment_consume = true,
		start_active = false,
		timer = 3
	}
	self.vhc_move_wagon = {
		text_id = "hud_int_press_move_wagon",
		force_update_position = true
	}
	self.move_crane = {
		text_id = "hud_int_press_move_crane"
	}
	self.search_scrap_parts = {
		text_id = "hud_search_scrap_parts",
		action_text_id = "hud_action_searching_scrap_parts",
		start_active = true,
		timer = 5
	}
	self.hold_attach_cable = {
		text_id = "hud_int_hold_attach_cable",
		action_text_id = "hud_action_attaching_cable",
		start_active = false,
		timer = 0.5
	}
	self.hold_detach_cable = {
		text_id = "hud_int_hold_detach_cable",
		action_text_id = "hud_action_detaching_cable",
		start_active = false,
		timer = 0.5,
		sound_start = "cutting_cable_loop_start",
		sound_interupt = "cutting_cable_loop_interrupt",
		sound_done = "cutting_cable_loop_stop"
	}
	self.take_code_book = {
		text_id = "hud_take_code_book",
		action_text_id = "hud_action_taking_code_book",
		special_equipment_block = "code_book",
		start_active = false,
		timer = 1,
		sound_done = "codebook_pickup_done"
	}
	self.take_code_book_active = deep_clone(self.take_code_book)
	self.take_code_book_active.start_active = true
	self.take_code_book_empty = {
		text_id = "hud_take_code_book",
		action_text_id = "hud_action_taking_code_book",
		start_active = false,
		timer = 2,
		sound_done = "codebook_pickup_done"
	}
	self.hold_ignite_flag = {
		text_id = "hud_int_hold_ignite_flag",
		action_text_id = "hud_action_igniting_flag",
		timer = 2,
		start_active = false,
		axis = "y",
		sound_start = "flag_burn_interaction_start",
		sound_interupt = "flag_burn_interaction_interrupt",
		sound_done = "flag_burn_interaction_success"
	}
	self.train_yard_open_door = {
		text_id = "hud_open_door_instant",
		start_active = false,
		interact_distance = 250,
		sound_done = "generic_wood_door_opened"
	}
	self.hold_take_canister = {
		text_id = "hud_int_hold_take_canister",
		action_text_id = "hud_action_taking_canister",
		start_active = false,
		timer = 0.5,
		blocked_hint = "hud_hint_carry_block",
		sound_done = "canister_pickup"
	}
	self.hold_take_crate_canisters = {
		text_id = "hud_int_hold_take_crate_canisters",
		action_text_id = "hud_action_taking_crate_canisters",
		start_active = false,
		timer = 0.5
	}
	self.hold_take_empty_canister = deep_clone(self.hold_take_canister)
	self.hold_take_empty_canister.text_id = "hud_int_hold_empty_take_canister"
	self.hold_take_empty_canister.action_text_id = "hud_action_taking_empty_canister"
	self.hold_take_empty_canister.special_equipment_block = "empty_fuel_canister"
	self.hold_place_canister = {
		text_id = "hud_int_hold_place_canister",
		action_text_id = "hud_action_placing_canister",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "fuel_canister",
		timer = 0.5,
		start_active = false,
		equipment_consume = true,
		sound_done = "canister_pickup"
	}
	self.hold_fill_canister = {
		text_id = "hud_int_hold_fill_canister",
		action_text_id = "hud_action_filling_canister",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "empty_fuel_canister",
		timer = 3,
		start_active = false,
		sound_start = "canister_fill_loop_start",
		sound_interupt = "canister_fill_loop_stop",
		sound_done = "canister_fill_loop_stop"
	}
	self.hold_fill_jeep = {
		text_id = "hud_int_hold_fill_jeep",
		action_text_id = "hud_action_filling_jeep",
		equipment_text_id = "hud_hint_no_gasoline",
		special_equipment = "gas_x4",
		timer = 3,
		start_active = false,
		equipment_consume = true,
		sound_start = "car_refuel_start",
		sound_interupt = "car_refuel_stop",
		sound_done = "car_refuel_stop"
	}
	self.hold_fill_barrel_gasoline = deep_clone(self.hold_fill_jeep)
	self.hold_fill_barrel_gasoline.text_id = "hud_int_hold_fill_barrel_gasoline"
	self.hold_fill_barrel_gasoline.action_text_id = "hud_action_filling_barrel"
	self.hold_fill_barrel_gasoline.equipment_text_id = "hud_hint_no_gasoline"
	self.hold_fill_barrel_gasoline.special_equipment = "fuel_canister"
	self.give_tools_franz = {
		text_id = "hud_give_tools_franz",
		action_text_id = "hud_action_giving_tools_franz",
		special_equipment = "repair_tools",
		equipment_text_id = "hud_no_tools_franz",
		equipment_consume = true,
		start_active = false,
		timer = 2,
		sound_done = "toolbox_pass"
	}
	self.hold_reinforce_door = {
		text_id = "hud_int_hold_reinforce_door",
		action_text_id = "hud_action_reinforcing_door",
		timer = 0.5,
		start_active = false,
		sound_start = "reinforce_door_interact",
		sound_done = "reinforce_door_success",
		sound_interupt = "reinforce_door_interact_interrupt"
	}
	self.hold_take_recording_device = {
		text_id = "hud_int_hold_take_recording_device",
		action_text_id = "hud_action_taking_recording_device",
		start_active = false,
		timer = 0.5,
		sound_done = "recording_device_pickup"
	}
	self.hold_place_recording_device = {
		text_id = "hud_int_hold_place_recording_device",
		action_text_id = "hud_action_placing_recording_device",
		equipment_text_id = "hud_hint_no_recording_device",
		special_equipment = "recording_device",
		timer = 0.5,
		start_active = false,
		equipment_consume = true,
		sound_done = "recording_device_placement"
	}
	self.hold_connect_cable = {
		text_id = "hud_int_hold_connect_cable",
		action_text_id = "hud_action_connecting_cable",
		timer = 0.5,
		start_active = false,
		sound_done = "el_cable_connected"
	}
	self.press_collect_reward = {
		text_id = "hud_int_collect_reward",
		start_active = false,
		interact_distance = 500
	}
	self.start_recording = {
		text_id = "hud_int_start_recording",
		start_active = false
	}
	self.hold_place_codebook = {
		text_id = "hud_int_hold_place_codebook",
		action_text_id = "hud_action_placing_codebook",
		equipment_text_id = "hud_hint_no_codebook",
		special_equipment = "code_book",
		timer = 0.5,
		start_active = false,
		equipment_consume = true,
		sound_done = "codebook_pickup_done"
	}
	self.sii_play_recordings = deep_clone(self.sii_tune_radio)
	self.sii_play_recordings.text_id = "hud_int_play_recordings"
	self.sii_play_recordings.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings.axis = "z"
	self.sii_play_recordings_easy = deep_clone(self.sii_tune_radio_easy)
	self.sii_play_recordings_easy.text_id = "hud_int_play_recordings"
	self.sii_play_recordings_easy.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings_easy.axis = "z"
	self.sii_play_recordings_medium = deep_clone(self.sii_tune_radio_medium)
	self.sii_play_recordings_medium.text_id = "hud_int_play_recordings"
	self.sii_play_recordings_medium.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings_medium.axis = "z"
	self.sii_replay_last_message = deep_clone(self.sii_play_recordings)
	self.sii_replay_last_message.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message.action_text_id = "hud_action_replaying_message"
	self.sii_replay_last_message_easy = deep_clone(self.sii_play_recordings_easy)
	self.sii_replay_last_message_easy.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message_easy.action_text_id = "hud_action_replaying_message"
	self.sii_replay_last_message_medium = deep_clone(self.sii_play_recordings_medium)
	self.sii_replay_last_message_medium.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message_medium.action_text_id = "hud_action_replaying_message"
	self.hold_repair_fusebox = {
		text_id = "hud_int_hold_repair_fusebox",
		action_text_id = "hud_action_repairing_fusebox",
		timer = 5,
		start_active = false,
		axis = "x",
		sound_start = "fusebox_repair_interact_start",
		sound_interupt = "fusebox_repair_interrupt",
		sound_done = "fusebox_repair_success"
	}
	self.hold_place_codemachine = {
		text_id = "hud_int_hold_place_codemachine",
		action_text_id = "hud_action_placing_codemachine",
		equipment_text_id = "hud_hint_no_codemachine",
		special_equipment = "enigma",
		timer = 0.5,
		start_active = false,
		equipment_consume = true,
		sound_done = "recording_device_placement"
	}
	self.pour_gas_generator = {
		text_id = "hud_pour_gas_generator",
		action_text_id = "hud_action_pouring_gas_generator",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "fuel_canister",
		timer = 5,
		start_active = false,
		equipment_consume = true,
		sound_start = "canister_fill_loop_start",
		sound_interupt = "canister_fill_loop_stop"
	}
	self.start_generator = {
		text_id = "hud_start_generator",
		start_active = false
	}
	self.load_shell = {
		text_id = "hud_load_shell",
		action_text_id = "hud_action_loading_shell",
		timer = 2,
		start_active = false
	}
	self.pku_empty_bucket = {
		text_id = "hud_int_take_empty_bucket",
		special_equipment_block = "empty_bucket",
		timer = 0.5,
		start_active = false
	}
	self.pku_fill_bucket = {
		text_id = "hud_int_fill_bucket",
		equipment_text_id = "hud_hint_need_empty_bucket",
		special_equipment_block = "full_bucket",
		special_equipment = "empty_bucket",
		timer = 0.5,
		start_active = false,
		equipment_consume = true
	}
	self.hold_give_full_bucket = {
		text_id = "hud_int_hold_give_full_bucket",
		action_text_id = "hud_action_giving_full_bucket",
		equipment_text_id = "hud_hint_need_full_bucket",
		special_equipment = "full_bucket",
		timer = 0.5,
		start_active = false,
		equipment_consume = true
	}
	self.hold_contact_mrs_white = {
		text_id = "hud_int_hold_contact_mrs_white",
		action_text_id = "hud_action_contacting_mrs_white",
		timer = 0.5,
		start_active = false
	}
	self.hold_contact_boat_driver = deep_clone(self.hold_contact_mrs_white)
	self.hold_contact_boat_driver.text_id = "hud_int_hold_contact_boat_driver"
	self.hold_contact_boat_driver.action_text_id = "hud_action_contacting_boat_driver"
	self.hold_request_dynamite_airdrop = deep_clone(self.hold_contact_mrs_white)
	self.hold_request_dynamite_airdrop.text_id = "hud_int_hold_request_dynamite_airdrop"
	self.hold_request_dynamite_airdrop.action_text_id = "hud_action_requesting_airdrop"
	self.disable_flare = {
		text_id = "hud_int_disable_flare",
		start_active = false
	}
	self.take_spiked_wine = {
		text_id = "hud_take_spiked_wine",
		action_text_id = "hud_action_taking_spiked_wine",
		start_active = false,
		timer = 1
	}
	self.take_code_machine_part = {
		text_id = "hud_take_code_machine_part",
		start_active = true,
		sound_done = "recording_device_placement"
	}
	self.hold_start_plane = {
		text_id = "hud_hold_start_plane",
		action_text_id = "hud_action_starting_plane",
		start_active = false,
		timer = 0.5
	}
	self.take_enigma = {
		text_id = "hud_take_enigma",
		action_text_id = "hud_action_taking_enigma",
		special_equipment_block = "enigma",
		start_active = false,
		timer = 3,
		sound_done = "enigma_machine_pickup"
	}
	self.wake_up_spy = {
		text_id = "hud_wake_up_spy",
		action_text_id = "hud_action_waking_up_spy",
		start_active = false,
		timer = 5
	}
	self.carry_spy = {
		text_id = "hud_carry_spy",
		action_text_id = "hud_action_carring_spy",
		start_active = false,
		timer = 3,
		sound_done = "spy_pickup"
	}
	self.carry_drop_spy = deep_clone(self.carry_drop)
	self.carry_drop_spy.text_id = "hud_carry_spy"
	self.carry_drop_spy.action_text_id = "hud_action_carring_spy"
	self.carry_drop_spy.timer = 3
	self.carry_drop_spy.sound_done = "spy_pickup"
	self.hold_open_barrier = {
		text_id = "hud_hold_open_barrier",
		action_text_id = "hud_action_opening_barrier",
		start_active = false,
		timer = 0.5
	}
	self.shut_off_valve = {
		text_id = "hud_shut_off_valve",
		action_text_id = "hud_action_shutting_off_valve",
		start_active = false,
		timer = 3,
		sound_start = "open_drop_pod_start",
		sound_interupt = "open_drop_pod_interrupt",
		sound_done = "elevator_switch"
	}
	self.turn_on_valve = {
		text_id = "hud_turn_on_valve",
		action_text_id = "hud_action_turning_on_valve",
		start_active = false,
		timer = 3,
		sound_start = "disconnect_hose_start",
		sound_interupt = "disconnect_hose_interrupt",
		sound_done = "disconnect_hose_interrupt"
	}
	self.destroy_valve = {
		text_id = "hud_desroy_valve",
		action_text_id = "hud_action_destroying_valve",
		start_active = false,
		timer = 3,
		sound_start = "gas_controller_destroy_interaction_start",
		sound_interupt = "gas_controller_destroy_interaction_stop",
		sound_done = "gas_controller_destroy"
	}
	self.replace_flag = {
		text_id = "hud_replace_flag",
		action_text_id = "hud_action_replacing_flag",
		start_active = false,
		timer = 3,
		sound_done = "flag_replace"
	}
	self.open_container = {
		text_id = "hud_open_container",
		action_text_id = "hud_action_opening_container",
		start_active = false,
		timer = 1.5
	}
	self.close_container = {
		text_id = "hud_close_container",
		action_text_id = "hud_action_closing_container",
		start_active = false,
		timer = 3
	}
	self.press_take_dogtags = {
		text_id = "hud_int_press_take_dogtags",
		sound_done = "dogtags_pickup",
		start_active = true,
		timer = 0
	}
	self.hold_take_dogtags = {
		text_id = "hud_int_hold_take_dogtags",
		action_text_id = "hud_action_taking_dogtags",
		sound_done = "dogtags_pickup",
		start_active = true,
		timer = 0.5
	}
	self.hold_take_loot = {
		text_id = "hud_int_hold_take_loot",
		action_text_id = "hud_action_taking_loot",
		sound_done = "pickup_tools",
		start_active = true,
		timer = 0.5
	}
	self.press_take_loot = {
		text_id = "hud_int_press_take_loot",
		sound_done = "pickup_tools",
		start_active = true,
		timer = 0
	}
	self.regular_cache_box = {
		text_id = "hud_int_regular_cache_box",
		action_text_id = "hud_action_taking_cache_loot",
		sound_done = "pickup_tools",
		start_active = true
	}
	self.disconnect_hose = {
		text_id = "hud_disconnect_hose",
		action_text_id = "hud_action_disconnecting_hose",
		start_active = false,
		timer = 3,
		sound_start = "disconnect_hose_start",
		sound_interupt = "disconnect_hose_interrupt",
		sound_done = "disconnect_hose_success"
	}
	self.push_truck_bridge = {
		text_id = "hud_push_truck_bridge",
		action_text_id = "hud_action_pushing_truck_bridge",
		start_active = false,
		timer = 1
	}
	self.connect_tank_truck = {
		text_id = "hud_connect_tank_truck",
		action_text_id = "hud_action_connecting_tank_truck",
		start_active = false,
		timer = 3,
		sound_start = "fuel_tank_connect",
		sound_interupt = "fuel_tank_connect_stop"
	}
	self.take_portable_radio = {
		text_id = "hud_int_take_portable_radio",
		action_text_id = "hud_action_taking_portable_radio",
		timer = 2,
		interact_distance = 250,
		special_equipment_block = "portable_radio"
	}
	self.sii_change_channel = deep_clone(self.sii_play_recordings)
	self.sii_change_channel.text_id = "hud_int_change_channel"
	self.sii_change_channel.action_text_id = "hud_action_changing_channel"
	self.plant_portable_radio = {
		text_id = "hud_plant_portable_radio",
		action_text_id = "hud_action_planting_portable_radio",
		interact_distance = 250,
		timer = 2,
		equipment_text_id = "hint_no_portable_radio",
		special_equipment = "portable_radio",
		start_active = false,
		equipment_consume = true,
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.set_fire_barrel = {
		text_id = "hud_interact_consumable_mission",
		action_text_id = "hud_action_consumable_mission",
		start_active = false,
		timer = 3,
		sound_start = "flag_burn_interaction_start",
		sound_interupt = "flag_burn_interaction_interrupt",
		sound_done = "barrel_fire_start"
	}
	self.open_door = {
		text_id = "hud_open_door_instant",
		interact_distance = 200,
		axis = "y"
	}
	self.open_truck_trunk = {
		text_id = "hud_open_truck_trunk",
		action_text_id = "hud_opening_truck_trunk",
		interact_distance = 200,
		start_active = false,
		timer = 2,
		axis = "y",
		sound_start = "truck_back_door_opening",
		sound_done = "truck_back_door_open"
	}
	self.consumable_mission = {
		text_id = "hud_interact_consumable_mission",
		action_text_id = "hud_action_consumable_mission",
		blocked_hint = "hud_hint_consumable_mission_block",
		start_active = true,
		timer = 3,
		sound_done = "consumable_mission_unlocked"
	}
	self.request_recording_device = {
		text_id = "hud_request_recording_device",
		action_text_id = "hud_action_requesting_recording_device",
		start_active = true,
		timer = 2
	}
end
