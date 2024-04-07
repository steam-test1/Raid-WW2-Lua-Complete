InteractionTweakData = InteractionTweakData or class()

function InteractionTweakData:init()
	self.CULLING_DISTANCE = 2000
	self.INTERACT_DISTANCE = 200
	self.POWERUP_INTERACTION_DISTANCE = 270
	self.MINIGAME_CIRCLE_RADIUS_SMALL = 133
	self.MINIGAME_CIRCLE_RADIUS_MEDIUM = 134
	self.MINIGAME_CIRCLE_RADIUS_BIG = 270
	self.copy_machine_smuggle = {}
	self.copy_machine_smuggle.icon = "equipment_thermite"
	self.copy_machine_smuggle.text_id = "debug_interact_copy_machine"
	self.copy_machine_smuggle.interact_distance = 305
	self.safety_deposit = {}
	self.safety_deposit.icon = "develop"
	self.safety_deposit.text_id = "debug_interact_safety_deposit"
	self.paper_pickup = {}
	self.paper_pickup.icon = "develop"
	self.paper_pickup.text_id = "debug_interact_paper_pickup"
	self.empty_interaction = {}
	self.empty_interaction.interact_distance = 0
	self.thermite = {}
	self.thermite.icon = "equipment_thermite"
	self.thermite.text_id = "debug_interact_thermite"
	self.thermite.equipment_text_id = "debug_interact_equipment_thermite"
	self.thermite.special_equipment = "thermite"
	self.thermite.equipment_consume = true
	self.thermite.interact_distance = 300
	self.thermite.timer = 3
	self.gasoline = {}
	self.gasoline.icon = "equipment_thermite"
	self.gasoline.text_id = "debug_interact_gas"
	self.gasoline.equipment_text_id = "debug_interact_equipment_gas"
	self.gasoline.special_equipment = "gas"
	self.gasoline.equipment_consume = true
	self.gasoline.interact_distance = 300
	self.gasoline_engine = {}
	self.gasoline_engine.icon = "equipment_thermite"
	self.gasoline_engine.text_id = "debug_interact_gas"
	self.gasoline_engine.equipment_text_id = "debug_interact_equipment_gas"
	self.gasoline_engine.special_equipment = "gas"
	self.gasoline_engine.equipment_consume = true
	self.gasoline_engine.interact_distance = 300
	self.gasoline_engine.timer = 20
	self.train_car = {}
	self.train_car.icon = "develop"
	self.train_car.text_id = "debug_interact_train_car"
	self.train_car.equipment_text_id = "debug_interact_equipment_gas"
	self.train_car.special_equipment = "gas"
	self.train_car.equipment_consume = true
	self.train_car.interact_distance = 400
	self.walkout_van = {}
	self.walkout_van.icon = "develop"
	self.walkout_van.text_id = "debug_interact_walkout_van"
	self.walkout_van.equipment_text_id = "debug_interact_equipment_gold"
	self.walkout_van.special_equipment = "gold"
	self.walkout_van.equipment_consume = true
	self.walkout_van.interact_distance = 400
	self.alaska_plane = {}
	self.alaska_plane.icon = "develop"
	self.alaska_plane.text_id = "debug_interact_alaska_plane"
	self.alaska_plane.equipment_text_id = "debug_interact_equipment_organs"
	self.alaska_plane.special_equipment = "organs"
	self.alaska_plane.equipment_consume = true
	self.alaska_plane.interact_distance = 400
	self.suburbia_door_crowbar = {}
	self.suburbia_door_crowbar.icon = "equipment_crowbar"
	self.suburbia_door_crowbar.text_id = "debug_interact_crowbar"
	self.suburbia_door_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.suburbia_door_crowbar.special_equipment = "crowbar"
	self.suburbia_door_crowbar.timer = 5
	self.suburbia_door_crowbar.start_active = false
	self.suburbia_door_crowbar.sound_start = "bar_crowbar"
	self.suburbia_door_crowbar.sound_interupt = "bar_crowbar_cancel"
	self.suburbia_door_crowbar.sound_done = "bar_crowbar_end"
	self.suburbia_door_crowbar.interact_distance = 130
	self.secret_stash_trunk_crowbar = {}
	self.secret_stash_trunk_crowbar.icon = "equipment_crowbar"
	self.secret_stash_trunk_crowbar.text_id = "debug_interact_crowbar2"
	self.secret_stash_trunk_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.secret_stash_trunk_crowbar.special_equipment = "crowbar"
	self.secret_stash_trunk_crowbar.timer = 20
	self.secret_stash_trunk_crowbar.start_active = false
	self.secret_stash_trunk_crowbar.sound_start = "und_crowbar_trunk"
	self.secret_stash_trunk_crowbar.sound_interupt = "und_crowbar_trunk_cancel"
	self.secret_stash_trunk_crowbar.sound_done = "und_crowbar_trunk_finished"
	self.requires_crowbar_interactive_template = {}
	self.requires_crowbar_interactive_template.icon = "equipment_crowbar"
	self.requires_crowbar_interactive_template.text_id = "debug_interact_crowbar_breach"
	self.requires_crowbar_interactive_template.equipment_text_id = "hud_interact_equipment_crowbar"
	self.requires_crowbar_interactive_template.special_equipment = "crowbar"
	self.requires_crowbar_interactive_template.timer = 8
	self.requires_crowbar_interactive_template.start_active = false
	self.requires_crowbar_interactive_template.sound_start = "bar_crowbar_open_metal"
	self.requires_crowbar_interactive_template.sound_interupt = "bar_crowbar_open_metal_cancel"
	self.requires_crowbar_interactive_template.sound_done = "bar_crowbar_open_metal_finished"
	self.requires_saw_blade = {}
	self.requires_saw_blade.icon = "develop"
	self.requires_saw_blade.text_id = "hud_int_hold_add_blade"
	self.requires_saw_blade.equipment_text_id = "hud_equipment_no_saw_blade"
	self.requires_saw_blade.special_equipment = "saw_blade"
	self.requires_saw_blade.timer = 2
	self.requires_saw_blade.start_active = false
	self.requires_saw_blade.equipment_consume = true
	self.saw_blade = {}
	self.saw_blade.text_id = "hud_int_hold_take_blade"
	self.saw_blade.action_text_id = "hud_action_taking_saw_blade"
	self.saw_blade.timer = 0.5
	self.saw_blade.start_active = false
	self.saw_blade.special_equipment_block = "saw_blade"
	self.open_slash_close_sec_box = {}
	self.open_slash_close_sec_box.text_id = "hud_int_hold_open_slash_close_sec_box"
	self.open_slash_close_sec_box.action_text_id = "hud_action_opening_slash_closing_sec_box"
	self.open_slash_close_sec_box.timer = 0.5
	self.open_slash_close_sec_box.start_active = false
	self.activate_camera = {}
	self.activate_camera.text_id = "hud_int_hold_activate_camera"
	self.activate_camera.action_text_id = "hud_action_activating_camera"
	self.activate_camera.timer = 0.5
	self.activate_camera.start_active = false
	self.weapon_cache_drop_zone = {}
	self.weapon_cache_drop_zone.icon = "equipment_vial"
	self.weapon_cache_drop_zone.text_id = "debug_interact_hospital_veil_container"
	self.weapon_cache_drop_zone.equipment_text_id = "debug_interact_equipment_blood_sample_verified"
	self.weapon_cache_drop_zone.special_equipment = "blood_sample"
	self.weapon_cache_drop_zone.equipment_consume = true
	self.weapon_cache_drop_zone.start_active = false
	self.weapon_cache_drop_zone.timer = 2
	self.secret_stash_limo_roof_crowbar = {}
	self.secret_stash_limo_roof_crowbar.icon = "develop"
	self.secret_stash_limo_roof_crowbar.text_id = "hud_interact_equipment_crowbar"
	self.secret_stash_limo_roof_crowbar.timer = 5
	self.secret_stash_limo_roof_crowbar.start_active = false
	self.secret_stash_limo_roof_crowbar.sound_start = "und_limo_chassis_open"
	self.secret_stash_limo_roof_crowbar.sound_interupt = "und_limo_chassis_open_stop"
	self.secret_stash_limo_roof_crowbar.sound_done = "und_limo_chassis_open_stop"
	self.secret_stash_limo_roof_crowbar.axis = "y"
	self.suburbia_iron_gate_crowbar = {}
	self.suburbia_iron_gate_crowbar.icon = "equipment_crowbar"
	self.suburbia_iron_gate_crowbar.text_id = "debug_interact_crowbar"
	self.suburbia_iron_gate_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.suburbia_iron_gate_crowbar.special_equipment = "crowbar"
	self.suburbia_iron_gate_crowbar.timer = 5
	self.suburbia_iron_gate_crowbar.start_active = false
	self.suburbia_iron_gate_crowbar.sound_start = "bar_crowbar_open_metal"
	self.suburbia_iron_gate_crowbar.sound_interupt = "bar_crowbar_open_metal_cancel"
	self.apartment_key = {}
	self.apartment_key.icon = "equipment_chavez_key"
	self.apartment_key.text_id = "debug_interact_apartment_key"
	self.apartment_key.equipment_text_id = "debug_interact_equiptment_apartment_key"
	self.apartment_key.special_equipment = "chavez_key"
	self.apartment_key.equipment_consume = true
	self.apartment_key.interact_distance = 150
	self.hospital_sample_validation_machine = {}
	self.hospital_sample_validation_machine.icon = "equipment_vial"
	self.hospital_sample_validation_machine.text_id = "debug_interact_sample_validation"
	self.hospital_sample_validation_machine.equipment_text_id = "debug_interact_equiptment_sample_validation"
	self.hospital_sample_validation_machine.special_equipment = "blood_sample"
	self.hospital_sample_validation_machine.equipment_consume = true
	self.hospital_sample_validation_machine.start_active = false
	self.hospital_sample_validation_machine.interact_distance = 150
	self.hospital_sample_validation_machine.axis = "y"
	self.methlab_bubbling = {}
	self.methlab_bubbling.icon = "develop"
	self.methlab_bubbling.text_id = "hud_int_methlab_bubbling"
	self.methlab_bubbling.equipment_text_id = "hud_int_no_acid"
	self.methlab_bubbling.special_equipment = "acid"
	self.methlab_bubbling.equipment_consume = true
	self.methlab_bubbling.start_active = false
	self.methlab_bubbling.timer = 1
	self.methlab_bubbling.action_text_id = "hud_action_methlab_bubbling"
	self.methlab_bubbling.sound_start = "liquid_pour"
	self.methlab_bubbling.sound_interupt = "liquid_pour_stop"
	self.methlab_bubbling.sound_done = "liquid_pour_stop"
	self.methlab_caustic_cooler = {}
	self.methlab_caustic_cooler.icon = "develop"
	self.methlab_caustic_cooler.text_id = "hud_int_methlab_caustic_cooler"
	self.methlab_caustic_cooler.equipment_text_id = "hud_int_no_caustic_soda"
	self.methlab_caustic_cooler.special_equipment = "caustic_soda"
	self.methlab_caustic_cooler.equipment_consume = true
	self.methlab_caustic_cooler.start_active = false
	self.methlab_caustic_cooler.timer = 1
	self.methlab_caustic_cooler.action_text_id = "hud_action_methlab_caustic_cooler"
	self.methlab_caustic_cooler.sound_start = "liquid_pour"
	self.methlab_caustic_cooler.sound_interupt = "liquid_pour_stop"
	self.methlab_caustic_cooler.sound_done = "liquid_pour_stop"
	self.methlab_gas_to_salt = {}
	self.methlab_gas_to_salt.icon = "develop"
	self.methlab_gas_to_salt.text_id = "hud_int_methlab_gas_to_salt"
	self.methlab_gas_to_salt.equipment_text_id = "hud_int_no_hydrogen_chloride"
	self.methlab_gas_to_salt.special_equipment = "hydrogen_chloride"
	self.methlab_gas_to_salt.equipment_consume = true
	self.methlab_gas_to_salt.start_active = false
	self.methlab_gas_to_salt.timer = 1
	self.methlab_gas_to_salt.action_text_id = "hud_action_methlab_gas_to_salt"
	self.methlab_drying_meth = {}
	self.methlab_drying_meth.icon = "develop"
	self.methlab_drying_meth.text_id = "hud_int_methlab_drying_meth"
	self.methlab_drying_meth.equipment_text_id = "hud_int_no_liquid_meth"
	self.methlab_drying_meth.special_equipment = "liquid_meth"
	self.methlab_drying_meth.equipment_consume = true
	self.methlab_drying_meth.start_active = false
	self.methlab_drying_meth.timer = 1
	self.methlab_drying_meth.action_text_id = "hud_action_methlab_drying_meth"
	self.methlab_drying_meth.sound_start = "liquid_pour"
	self.methlab_drying_meth.sound_interupt = "liquid_pour_stop"
	self.methlab_drying_meth.sound_done = "liquid_pour_stop"
	self.muriatic_acid = {}
	self.muriatic_acid.icon = "develop"
	self.muriatic_acid.text_id = "hud_int_take_acid"
	self.muriatic_acid.start_active = false
	self.muriatic_acid.interact_distance = 225
	self.muriatic_acid.special_equipment_block = "acid"
	self.caustic_soda = {}
	self.caustic_soda.icon = "develop"
	self.caustic_soda.text_id = "hud_int_take_caustic_soda"
	self.caustic_soda.start_active = false
	self.caustic_soda.interact_distance = 225
	self.caustic_soda.special_equipment_block = "caustic_soda"
	self.hydrogen_chloride = {}
	self.hydrogen_chloride.icon = "develop"
	self.hydrogen_chloride.text_id = "hud_int_take_hydrogen_chloride"
	self.hydrogen_chloride.start_active = false
	self.hydrogen_chloride.interact_distance = 225
	self.hydrogen_chloride.special_equipment_block = "hydrogen_chloride"
	self.elevator_button = {}
	self.elevator_button.icon = "interaction_elevator"
	self.elevator_button.text_id = "debug_interact_elevator_door"
	self.elevator_button.start_active = false
	self.use_computer = {}
	self.use_computer.icon = "interaction_elevator"
	self.use_computer.text_id = "hud_int_use_computer"
	self.use_computer.start_active = false
	self.use_computer.timer = 2
	self.elevator_button_roof = {}
	self.elevator_button_roof.icon = "interaction_elevator"
	self.elevator_button_roof.text_id = "debug_interact_elevator_door_roof"
	self.elevator_button_roof.start_active = false
	self.key_double = {}
	self.key_double.icon = "equipment_bank_manager_key"
	self.key_double.text_id = "hud_int_equipment_keycard"
	self.key_double.equipment_text_id = "hud_int_equipment_no_keycard"
	self.key_double.special_equipment = "bank_manager_key"
	self.key_double.equipment_consume = true
	self.key_double.interact_distance = 100
	self.key = deep_clone(self.key_double)
	self.key.axis = "x"
	self.numpad = {}
	self.numpad.icon = "equipment_bank_manager_key"
	self.numpad.text_id = "debug_interact_numpad"
	self.numpad.start_active = false
	self.numpad.axis = "z"
	self.numpad_keycard = {}
	self.numpad_keycard.icon = "equipment_bank_manager_key"
	self.numpad_keycard.text_id = "hud_int_numpad_keycard"
	self.numpad_keycard.equipment_text_id = "hud_int_numpad_no_keycard"
	self.numpad_keycard.special_equipment = "bank_manager_key"
	self.numpad_keycard.equipment_consume = true
	self.numpad_keycard.start_active = false
	self.numpad_keycard.axis = "z"
	self.timelock_panel = {}
	self.timelock_panel.icon = "equipment_bank_manager_key"
	self.timelock_panel.text_id = "hud_int_timelock_panel"
	self.timelock_panel.equipment_text_id = "hud_int_equipment_no_keycard"
	self.timelock_panel.special_equipment = "bank_manager_key"
	self.timelock_panel.equipment_consume = true
	self.timelock_panel.start_active = false
	self.timelock_panel.axis = "y"
	self.take_weapons = {}
	self.take_weapons.icon = "develop"
	self.take_weapons.text_id = "hud_int_take_weapons"
	self.take_weapons.action_text_id = "hud_action_taking_weapons"
	self.take_weapons.timer = 3
	self.take_weapons.axis = "x"
	self.take_weapons.interact_distance = 120
	self.take_weapons_not_active = deep_clone(self.take_weapons)
	self.take_weapons_not_active.start_active = false
	self.pick_lock_easy = {}
	self.pick_lock_easy.contour = "interactable_icon"
	self.pick_lock_easy.icon = "equipment_bank_manager_key"
	self.pick_lock_easy.text_id = "hud_int_pick_lock"
	self.pick_lock_easy.start_active = true
	self.pick_lock_easy.timer = 10
	self.pick_lock_easy.interact_distance = 100
	self.pick_lock_easy.requires_upgrade = {
		upgrade = "pick_lock_easy",
		category = "player"
	}
	self.pick_lock_easy.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.pick_lock_easy.action_text_id = "hud_action_picking_lock"
	self.pick_lock_easy.sound_start = "bar_pick_lock"
	self.pick_lock_easy.sound_interupt = "bar_pick_lock_cancel"
	self.pick_lock_easy.sound_done = "bar_pick_lock_finished"
	self.pick_lock_easy_no_skill = {}
	self.pick_lock_easy_no_skill.contour = "interactable_icon"
	self.pick_lock_easy_no_skill.icon = "equipment_bank_manager_key"
	self.pick_lock_easy_no_skill.text_id = "hud_int_pick_lock"
	self.pick_lock_easy_no_skill.start_active = true
	self.pick_lock_easy_no_skill.timer = 7
	self.pick_lock_easy_no_skill.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.pick_lock_easy_no_skill.action_text_id = "hud_action_picking_lock"
	self.pick_lock_easy_no_skill.interact_distance = 100
	self.pick_lock_easy_no_skill.sound_start = "bar_pick_lock"
	self.pick_lock_easy_no_skill.sound_interupt = "bar_pick_lock_cancel"
	self.pick_lock_easy_no_skill.sound_done = "bar_pick_lock_finished"
	self.pick_lock_hard = {}
	self.pick_lock_hard.contour = "interactable_icon"
	self.pick_lock_hard.icon = "equipment_bank_manager_key"
	self.pick_lock_hard.text_id = "hud_int_pick_lock"
	self.pick_lock_hard.start_active = true
	self.pick_lock_hard.timer = 45
	self.pick_lock_hard.requires_upgrade = {
		upgrade = "pick_lock_hard",
		category = "player"
	}
	self.pick_lock_hard.action_text_id = "hud_action_picking_lock"
	self.pick_lock_hard.sound_start = "bar_pick_lock"
	self.pick_lock_hard.sound_interupt = "bar_pick_lock_cancel"
	self.pick_lock_hard.sound_done = "bar_pick_lock_finished"
	self.pick_lock_hard_no_skill = {}
	self.pick_lock_hard_no_skill.contour = "interactable_icon"
	self.pick_lock_hard_no_skill.icon = "equipment_bank_manager_key"
	self.pick_lock_hard_no_skill.text_id = "hud_int_pick_lock"
	self.pick_lock_hard_no_skill.start_active = true
	self.pick_lock_hard_no_skill.timer = 20
	self.pick_lock_hard_no_skill.action_text_id = "hud_action_picking_lock"
	self.pick_lock_hard_no_skill.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.pick_lock_hard_no_skill.interact_distance = 100
	self.pick_lock_hard_no_skill.sound_start = "bar_pick_lock"
	self.pick_lock_hard_no_skill.sound_interupt = "bar_pick_lock_cancel"
	self.pick_lock_hard_no_skill.sound_done = "bar_pick_lock_finished"
	self.pick_lock_deposit_transport = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_deposit_transport.timer = 15
	self.pick_lock_deposit_transport.axis = "y"
	self.pick_lock_deposit_transport.interact_distance = 80
	self.open_door_with_keys = {}
	self.open_door_with_keys.contour = "interactable_icon"
	self.open_door_with_keys.icon = "equipment_bank_manager_key"
	self.open_door_with_keys.text_id = "hud_int_try_keys"
	self.open_door_with_keys.start_active = false
	self.open_door_with_keys.timer = 5
	self.open_door_with_keys.action_text_id = "hud_action_try_keys"
	self.open_door_with_keys.interact_distance = 100
	self.open_door_with_keys.sound_start = "bar_pick_lock"
	self.open_door_with_keys.sound_interupt = "bar_pick_lock_cancel"
	self.open_door_with_keys.sound_done = "bar_pick_lock_finished"
	self.open_door_with_keys.special_equipment = "keychain"
	self.open_door_with_keys.equipment_text_id = "hud_action_try_keys_no_key"
	self.cant_pick_lock = {}
	self.cant_pick_lock.icon = "equipment_bank_manager_key"
	self.cant_pick_lock.text_id = "hud_int_pick_lock"
	self.cant_pick_lock.start_active = false
	self.cant_pick_lock.interact_distance = 80
	self.hospital_veil_container = {}
	self.hospital_veil_container.icon = "equipment_vialOK"
	self.hospital_veil_container.text_id = "debug_interact_hospital_veil_container"
	self.hospital_veil_container.equipment_text_id = "debug_interact_equipment_blood_sample_verified"
	self.hospital_veil_container.special_equipment = "blood_sample_verified"
	self.hospital_veil_container.equipment_consume = true
	self.hospital_veil_container.start_active = false
	self.hospital_veil_container.timer = 2
	self.hospital_veil_container.axis = "y"
	self.hospital_phone = {}
	self.hospital_phone.icon = "interaction_answerphone"
	self.hospital_phone.text_id = "debug_interact_hospital_phone"
	self.hospital_phone.start_active = false
	self.hospital_security_cable = {}
	self.hospital_security_cable.text_id = "debug_interact_hospital_security_cable"
	self.hospital_security_cable.icon = "interaction_wirecutter"
	self.hospital_security_cable.start_active = false
	self.hospital_security_cable.timer = 5
	self.hospital_security_cable.interact_distance = 75
	self.hospital_veil = {}
	self.hospital_veil.icon = "equipment_vial"
	self.hospital_veil.text_id = "debug_interact_hospital_veil_hold"
	self.hospital_veil.start_active = false
	self.hospital_veil.timer = 2
	self.hospital_veil_take = {}
	self.hospital_veil_take.icon = "equipment_vial"
	self.hospital_veil_take.text_id = "debug_interact_hospital_veil_take"
	self.hospital_veil_take.start_active = false
	self.hospital_sentry = {}
	self.hospital_sentry.icon = "interaction_sentrygun"
	self.hospital_sentry.text_id = "debug_interact_hospital_sentry"
	self.hospital_sentry.start_active = false
	self.hospital_sentry.timer = 2
	self.drill = {}
	self.drill.icon = "equipment_drill"
	self.drill.contour = "interactable_icon"
	self.drill.text_id = "hud_int_equipment_drill"
	self.drill.equipment_text_id = "hud_int_equipment_no_drill"
	self.drill.timer = 3
	self.drill.blocked_hint = "no_drill"
	self.drill.sound_start = "bar_drill_apply"
	self.drill.sound_interupt = "bar_drill_apply_cancel"
	self.drill.sound_done = "bar_drill_apply_finished"
	self.drill.axis = "y"
	self.drill.action_text_id = "hud_action_placing_drill"
	self.drill_upgrade = {}
	self.drill_upgrade.icon = "equipment_drill"
	self.drill_upgrade.contour = "upgradable"
	self.drill_upgrade.text_id = "hud_int_equipment_drill_upgrade"
	self.drill_upgrade.timer = 10
	self.drill_upgrade.sound_start = "bar_drill_apply"
	self.drill_upgrade.sound_interupt = "bar_drill_apply_cancel"
	self.drill_upgrade.sound_done = "bar_drill_apply_finished"
	self.drill_upgrade.action_text_id = "hud_action_upgrading_drill"
	self.drill_jammed = {}
	self.drill_jammed.icon = "equipment_drill"
	self.drill_jammed.text_id = "hud_int_equipment_drill_jammed"
	self.drill_jammed.timer = 10
	self.drill_jammed.sound_start = "bar_drill_fix"
	self.drill_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.drill_jammed.sound_done = "bar_drill_fix_finished"
	self.drill_jammed.upgrade_timer_multiplier = {
		upgrade = "drill_fix_interaction_speed_multiplier",
		category = "player"
	}
	self.drill_jammed.action_text_id = "hud_action_fixing_drill"
	self.lance = {}
	self.lance.icon = "equipment_drill"
	self.lance.contour = "interactable_icon"
	self.lance.text_id = "hud_int_equipment_lance"
	self.lance.equipment_text_id = "hud_int_equipment_no_lance"
	self.lance.timer = 3
	self.lance.blocked_hint = "no_lance"
	self.lance.sound_start = "bar_thermal_lance_apply"
	self.lance.sound_interupt = "bar_thermal_lance_apply_cancel"
	self.lance.sound_done = "bar_thermal_lance_apply_finished"
	self.lance.action_text_id = "hud_action_placing_lance"
	self.lance_jammed = {}
	self.lance_jammed.icon = "equipment_drill"
	self.lance_jammed.text_id = "hud_int_equipment_lance_jammed"
	self.lance_jammed.timer = 10
	self.lance_jammed.sound_start = "bar_thermal_lance_fix"
	self.lance_jammed.sound_interupt = "bar_thermal_lance_fix_cancel"
	self.lance_jammed.sound_done = "bar_thermal_lance_fix_finished"
	self.lance_jammed.upgrade_timer_multiplier = {
		upgrade = "drill_fix_interaction_speed_multiplier",
		category = "player"
	}
	self.lance_jammed.action_text_id = "hud_action_fixing_lance"
	self.lance_upgrade = {}
	self.lance_upgrade.icon = "equipment_drill"
	self.lance_upgrade.contour = "upgradable"
	self.lance_upgrade.text_id = "hud_int_equipment_lance_upgrade"
	self.lance_upgrade.timer = 10
	self.lance_upgrade.sound_start = "bar_drill_apply"
	self.lance_upgrade.sound_interupt = "bar_drill_apply_cancel"
	self.lance_upgrade.sound_done = "bar_drill_apply_finished"
	self.lance_upgrade.action_text_id = "hud_action_upgrading_lance"
	self.glass_cutter = {}
	self.glass_cutter.icon = "equipment_cutter"
	self.glass_cutter.text_id = "debug_interact_glass_cutter"
	self.glass_cutter.equipment_text_id = "debug_interact_equipment_glass_cutter"
	self.glass_cutter.special_equipment = "glass_cutter"
	self.glass_cutter.timer = 3
	self.glass_cutter.blocked_hint = "no_glass_cutter"
	self.glass_cutter.sound_start = "bar_drill_apply"
	self.glass_cutter.sound_interupt = "bar_drill_apply_cancel"
	self.glass_cutter.sound_done = "bar_drill_apply_finished"
	self.glass_cutter_jammed = {}
	self.glass_cutter_jammed.icon = "equipment_cutter"
	self.glass_cutter_jammed.text_id = "debug_interact_cutter_jammed"
	self.glass_cutter_jammed.timer = 10
	self.glass_cutter_jammed.sound_start = "bar_drill_fix"
	self.glass_cutter_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.glass_cutter_jammed.sound_done = "bar_drill_fix_finished"
	self.hack_ipad = {}
	self.hack_ipad.icon = "equipment_hack_ipad"
	self.hack_ipad.text_id = "debug_interact_hack_ipad"
	self.hack_ipad.timer = 3
	self.hack_ipad.sound_start = "bar_drill_apply"
	self.hack_ipad.sound_interupt = "bar_drill_apply_cancel"
	self.hack_ipad.sound_done = "bar_drill_apply_finished"
	self.hack_ipad.axis = "x"
	self.hack_ipad_jammed = {}
	self.hack_ipad_jammed.icon = "equipment_hack_ipad"
	self.hack_ipad_jammed.text_id = "debug_interact_hack_ipad_jammed"
	self.hack_ipad_jammed.timer = 10
	self.hack_ipad_jammed.sound_start = "bar_drill_fix"
	self.hack_ipad_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.hack_ipad_jammed.sound_done = "bar_drill_fix_finished"
	self.hack_suburbia = {}
	self.hack_suburbia.icon = "equipment_hack_ipad"
	self.hack_suburbia.text_id = "debug_interact_hack_ipad"
	self.hack_suburbia.timer = 5
	self.hack_suburbia.sound_start = "bar_keyboard"
	self.hack_suburbia.sound_interupt = "bar_keyboard_cancel"
	self.hack_suburbia.sound_done = "bar_keyboard_finished"
	self.hack_suburbia.axis = "y"
	self.hack_suburbia.contour = "contour_off"
	self.hack_suburbia_jammed = {}
	self.hack_suburbia_jammed.icon = "equipment_hack_ipad"
	self.hack_suburbia_jammed.text_id = "debug_interact_hack_ipad_jammed"
	self.hack_suburbia_jammed.timer = 5
	self.hack_suburbia_jammed.sound_start = "bar_keyboard"
	self.hack_suburbia_jammed.sound_interupt = "bar_keyboard_cancel"
	self.hack_suburbia_jammed.sound_done = "bar_keyboard_finished"
	self.security_station = {}
	self.security_station.icon = "equipment_hack_ipad"
	self.security_station.text_id = "debug_interact_security_station"
	self.security_station.timer = 3
	self.security_station.sound_start = "bar_drill_apply"
	self.security_station.sound_interupt = "bar_drill_apply_cancel"
	self.security_station.sound_done = "bar_drill_apply_finished"
	self.security_station.axis = "z"
	self.security_station.start_active = false
	self.security_station.sound_start = "bar_keyboard"
	self.security_station.sound_interupt = "bar_keyboard_cancel"
	self.security_station.sound_done = "bar_keyboard_finished"
	self.security_station_keyboard = {}
	self.security_station_keyboard.icon = "interaction_keyboard"
	self.security_station_keyboard.text_id = "debug_interact_security_station"
	self.security_station_keyboard.timer = 6
	self.security_station_keyboard.axis = "z"
	self.security_station_keyboard.start_active = false
	self.security_station_keyboard.interact_distance = 150
	self.security_station_keyboard.sound_start = "bar_keyboard"
	self.security_station_keyboard.sound_interupt = "bar_keyboard_cancel"
	self.security_station_keyboard.sound_done = "bar_keyboard_finished"
	self.big_computer_hackable = {}
	self.big_computer_hackable.icon = "interaction_keyboard"
	self.big_computer_hackable.text_id = "hud_int_big_computer_hackable"
	self.big_computer_hackable.timer = 6
	self.big_computer_hackable.start_active = false
	self.big_computer_hackable.interact_distance = 200
	self.big_computer_hackable.sound_start = "bar_keyboard"
	self.big_computer_hackable.sound_interupt = "bar_keyboard_cancel"
	self.big_computer_hackable.sound_done = "bar_keyboard_finished"
	self.big_computer_not_hackable = {}
	self.big_computer_not_hackable.icon = "interaction_keyboard"
	self.big_computer_not_hackable.text_id = "hud_int_big_computer_hackable"
	self.big_computer_not_hackable.timer = 6
	self.big_computer_not_hackable.start_active = false
	self.big_computer_not_hackable.interact_distance = 200
	self.big_computer_not_hackable.sound_start = "bar_keyboard"
	self.big_computer_not_hackable.sound_interupt = "bar_keyboard_cancel"
	self.big_computer_not_hackable.sound_done = "bar_keyboard_finished"
	self.big_computer_not_hackable.equipment_text_id = "hud_int_big_computer_unhackable"
	self.big_computer_not_hackable.special_equipment = "nothing"
	self.big_computer_server = {}
	self.big_computer_server.icon = "interaction_keyboard"
	self.big_computer_server.text_id = "hud_int_big_computer_server"
	self.big_computer_server.timer = 6
	self.big_computer_server.start_active = false
	self.big_computer_server.interact_distance = 150
	self.big_computer_server.sound_start = "bar_keyboard"
	self.big_computer_server.sound_interupt = "bar_keyboard_cancel"
	self.big_computer_server.sound_done = "bar_keyboard_finished"
	self.security_station_jammed = {}
	self.security_station_jammed.icon = "interaction_keyboard"
	self.security_station_jammed.text_id = "debug_interact_security_station_jammed"
	self.security_station_jammed.timer = 10
	self.security_station_jammed.sound_start = "bar_drill_fix"
	self.security_station_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.security_station_jammed.sound_done = "bar_drill_fix_finished"
	self.security_station_jammed.axis = "z"
	self.apartment_drill = {}
	self.apartment_drill.icon = "equipment_drill"
	self.apartment_drill.text_id = "debug_interact_drill"
	self.apartment_drill.equipment_text_id = "debug_interact_equipment_drill"
	self.apartment_drill.timer = 3
	self.apartment_drill.blocked_hint = "no_drill"
	self.apartment_drill.sound_start = "bar_drill_apply"
	self.apartment_drill.sound_interupt = "bar_drill_apply_cancel"
	self.apartment_drill.sound_done = "bar_drill_apply_finished"
	self.apartment_drill.interact_distance = 200
	self.apartment_drill_jammed = {}
	self.apartment_drill_jammed.icon = "equipment_drill"
	self.apartment_drill_jammed.text_id = "debug_interact_drill_jammed"
	self.apartment_drill_jammed.timer = 3
	self.apartment_drill_jammed.sound_start = "bar_drill_fix"
	self.apartment_drill_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.apartment_drill_jammed.sound_done = "bar_drill_fix_finished"
	self.apartment_drill_jammed.interact_distance = 200
	self.suburbia_drill = {}
	self.suburbia_drill.icon = "equipment_drill"
	self.suburbia_drill.text_id = "debug_interact_drill"
	self.suburbia_drill.equipment_text_id = "debug_interact_equipment_drill"
	self.suburbia_drill.timer = 3
	self.suburbia_drill.blocked_hint = "no_drill"
	self.suburbia_drill.sound_start = "bar_drill_apply"
	self.suburbia_drill.sound_interupt = "bar_drill_apply_cancel"
	self.suburbia_drill.sound_done = "bar_drill_apply_finished"
	self.suburbia_drill.interact_distance = 200
	self.suburbia_drill_jammed = {}
	self.suburbia_drill_jammed.icon = "equipment_drill"
	self.suburbia_drill_jammed.text_id = "debug_interact_drill_jammed"
	self.suburbia_drill_jammed.timer = 3
	self.suburbia_drill_jammed.sound_start = "bar_drill_fix"
	self.suburbia_drill_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.suburbia_drill_jammed.sound_done = "bar_drill_fix_finished"
	self.suburbia_drill_jammed.interact_distance = 200
	self.goldheist_drill = {}
	self.goldheist_drill.icon = "equipment_drill"
	self.goldheist_drill.text_id = "debug_interact_drill"
	self.goldheist_drill.equipment_text_id = "debug_interact_equipment_drill"
	self.goldheist_drill.timer = 3
	self.goldheist_drill.blocked_hint = "no_drill"
	self.goldheist_drill.sound_start = "bar_drill_apply"
	self.goldheist_drill.sound_interupt = "bar_drill_apply_cancel"
	self.goldheist_drill.sound_done = "bar_drill_apply_finished"
	self.goldheist_drill.interact_distance = 200
	self.goldheist_drill_jammed = {}
	self.goldheist_drill_jammed.icon = "equipment_drill"
	self.goldheist_drill_jammed.text_id = "debug_interact_drill_jammed"
	self.goldheist_drill_jammed.timer = 3
	self.goldheist_drill_jammed.sound_start = "bar_drill_fix"
	self.goldheist_drill_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.goldheist_drill_jammed.sound_done = "bar_drill_fix_finished"
	self.goldheist_drill_jammed.interact_distance = 200
	self.hospital_saw_teddy = {}
	self.hospital_saw_teddy.icon = "equipment_saw"
	self.hospital_saw_teddy.text_id = "debug_interact_hospital_saw_teddy"
	self.hospital_saw_teddy.start_active = false
	self.hospital_saw_teddy.timer = 2
	self.hospital_saw = {}
	self.hospital_saw.icon = "equipment_saw"
	self.hospital_saw.text_id = "debug_interact_saw"
	self.hospital_saw.equipment_text_id = "debug_interact_equipment_saw"
	self.hospital_saw.special_equipment = "saw"
	self.hospital_saw.timer = 3
	self.hospital_saw.sound_start = "bar_drill_apply"
	self.hospital_saw.sound_interupt = "bar_drill_apply_cancel"
	self.hospital_saw.sound_done = "bar_drill_apply_finished"
	self.hospital_saw.interact_distance = 200
	self.hospital_saw.axis = "z"
	self.hospital_saw_jammed = {}
	self.hospital_saw_jammed.icon = "equipment_saw"
	self.hospital_saw_jammed.text_id = "debug_interact_saw_jammed"
	self.hospital_saw_jammed.timer = 3
	self.hospital_saw_jammed.sound_start = "bar_drill_fix"
	self.hospital_saw_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.hospital_saw_jammed.sound_done = "bar_drill_fix_finished"
	self.hospital_saw_jammed.interact_distance = 200
	self.hospital_saw_jammed.axis = "z"
	self.hospital_saw_jammed.upgrade_timer_multiplier = {
		upgrade = "drill_fix_interaction_speed_multiplier",
		category = "player"
	}
	self.apartment_saw = {}
	self.apartment_saw.icon = "equipment_saw"
	self.apartment_saw.text_id = "debug_interact_saw"
	self.apartment_saw.timer = 3
	self.apartment_saw.sound_start = "bar_drill_apply"
	self.apartment_saw.sound_interupt = "bar_drill_apply_cancel"
	self.apartment_saw.sound_done = "bar_drill_apply_finished"
	self.apartment_saw.interact_distance = 200
	self.apartment_saw.axis = "z"
	self.apartment_saw_jammed = {}
	self.apartment_saw_jammed.icon = "equipment_saw"
	self.apartment_saw_jammed.text_id = "debug_interact_saw_jammed"
	self.apartment_saw_jammed.timer = 3
	self.apartment_saw_jammed.sound_start = "bar_drill_fix"
	self.apartment_saw_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.apartment_saw_jammed.sound_done = "bar_drill_fix_finished"
	self.apartment_saw_jammed.interact_distance = 200
	self.apartment_saw_jammed.axis = "z"
	self.apartment_saw_jammed.upgrade_timer_multiplier = {
		upgrade = "drill_fix_interaction_speed_multiplier",
		category = "player"
	}
	self.secret_stash_saw = {}
	self.secret_stash_saw.icon = "equipment_saw"
	self.secret_stash_saw.text_id = "debug_interact_saw"
	self.secret_stash_saw.timer = 3
	self.secret_stash_saw.sound_start = "bar_drill_apply"
	self.secret_stash_saw.sound_interupt = "bar_drill_apply_cancel"
	self.secret_stash_saw.sound_done = "bar_drill_apply_finished"
	self.secret_stash_saw.interact_distance = 200
	self.secret_stash_saw.axis = "z"
	self.secret_stash_saw_jammed = {}
	self.secret_stash_saw_jammed.icon = "equipment_saw"
	self.secret_stash_saw_jammed.text_id = "debug_interact_saw_jammed"
	self.secret_stash_saw_jammed.timer = 3
	self.secret_stash_saw_jammed.sound_start = "bar_drill_fix"
	self.secret_stash_saw_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.secret_stash_saw_jammed.sound_done = "bar_drill_fix_finished"
	self.secret_stash_saw_jammed.interact_distance = 200
	self.secret_stash_saw_jammed.axis = "z"
	self.secret_stash_saw_jammed.upgrade_timer_multiplier = {
		upgrade = "drill_fix_interaction_speed_multiplier",
		category = "player"
	}
	self.revive = {}
	self.revive.icon = "interaction_help"
	self.revive.text_id = "hud_interact_revive"
	self.revive.start_active = false
	self.revive.interact_distance = 300
	self.revive.axis = "z"
	self.revive.timer = 6
	self.revive.action_text_id = "hud_action_reviving"
	self.revive.upgrade_timer_multiplier = {
		upgrade = "revive_interaction_speed_multiplier",
		category = "player"
	}
	self.revive.contour_preset = "teammate_downed"
	self.revive.contour_preset_selected = "teammate_downed_selected"
	self.dead = {}
	self.dead.icon = "interaction_help"
	self.dead.text_id = "hud_interact_revive"
	self.dead.start_active = false
	self.dead.interact_distance = 300
	self.free = {}
	self.free.icon = "interaction_free"
	self.free.text_id = "debug_interact_free"
	self.free.start_active = false
	self.free.interact_distance = 300
	self.free.no_contour = true
	self.free.timer = 1
	self.free.sound_start = "bar_rescue"
	self.free.sound_interupt = "bar_rescue_cancel"
	self.free.sound_done = "bar_rescue_finished"
	self.free.action_text_id = "hud_action_freeing"
	self.hostage_trade = {}
	self.hostage_trade.icon = "interaction_trade"
	self.hostage_trade.text_id = "debug_interact_trade"
	self.hostage_trade.start_active = true
	self.hostage_trade.timer = 3
	self.hostage_trade.requires_upgrade = {
		upgrade = "hostage_trade",
		category = "player"
	}
	self.hostage_trade.action_text_id = "hud_action_trading"
	self.hostage_trade.contour_preset = "generic_interactable"
	self.hostage_trade.contour_preset_selected = "generic_interactable_selected"
	self.hostage_move = {}
	self.hostage_move.icon = "interaction_trade"
	self.hostage_move.text_id = "debug_interact_hostage_move"
	self.hostage_move.start_active = true
	self.hostage_move.timer = 1
	self.hostage_move.action_text_id = "hud_action_standing_up"
	self.hostage_move.no_contour = true
	self.hostage_move.interaction_obj = Idstring("Spine")
	self.hostage_stay = {}
	self.hostage_stay.icon = "interaction_trade"
	self.hostage_stay.text_id = "debug_interact_hostage_stay"
	self.hostage_stay.start_active = true
	self.hostage_stay.timer = 0.4
	self.hostage_stay.action_text_id = "hud_action_getting_down"
	self.hostage_stay.no_contour = true
	self.hostage_stay.interaction_obj = Idstring("Spine2")
	self.trip_mine = {}
	self.trip_mine.icon = "equipment_trip_mine"
	self.trip_mine.requires_upgrade = {
		upgrade = "can_switch_on_off",
		category = "trip_mine"
	}
	self.trip_mine.no_contour = true
	self.grenade_crate = {}
	self.grenade_crate.icon = "equipment_ammo_bag"
	self.grenade_crate.text_id = "hud_interact_grenade_crate_take_grenades"
	self.grenade_crate.contour = "crate_loot_pickup"
	self.grenade_crate.blocked_hint = "hint_full_grenades"
	self.grenade_crate.blocked_hint_sound = "no_more_grenades"
	self.grenade_crate.sound_done = "pickup_grenade"
	self.grenade_crate.action_text_id = "hud_action_taking_grenades"
	self.grenade_crate.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.grenade_pickup_new = deep_clone(self.grenade_crate)
	self.grenade_pickup_new.start_active = true
	self.grenade_crate_small = {}
	self.grenade_crate_small.icon = self.grenade_crate.icon
	self.grenade_crate_small.text_id = self.grenade_crate.text_id
	self.grenade_crate_small.contour = self.grenade_crate.contour
	self.grenade_crate_small.blocked_hint = self.grenade_crate.blocked_hint
	self.grenade_crate_small.blocked_hint_sound = self.grenade_crate.blocked_hint_sound
	self.grenade_crate_small.sound_start = self.grenade_crate.sound_start
	self.grenade_crate_small.sound_interupt = self.grenade_crate.sound_interupt
	self.grenade_crate_small.sound_done = self.grenade_crate.sound_done
	self.grenade_crate_small.action_text_id = self.grenade_crate.action_text_id
	self.grenade_crate_small.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.grenade_crate_big = {}
	self.grenade_crate_big.icon = self.grenade_crate.icon
	self.grenade_crate_big.text_id = self.grenade_crate.text_id
	self.grenade_crate_big.contour = self.grenade_crate.contour
	self.grenade_crate_big.blocked_hint = self.grenade_crate.blocked_hint
	self.grenade_crate_big.blocked_hint_sound = self.grenade_crate.blocked_hint_sound
	self.grenade_crate_big.sound_start = self.grenade_crate.sound_start
	self.grenade_crate_big.sound_interupt = self.grenade_crate.sound_interupt
	self.grenade_crate_big.sound_done = self.grenade_crate.sound_done
	self.grenade_crate_big.action_text_id = self.grenade_crate.action_text_id
	self.grenade_crate_big.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.ammo_bag = {}
	self.ammo_bag.icon = "equipment_ammo_bag"
	self.ammo_bag.text_id = "hud_interact_ammo_bag_take_ammo"
	self.ammo_bag.contour = "deployable"
	self.ammo_bag.blocked_hint = "hint_full_ammo"
	self.ammo_bag.blocked_hint_sound = "no_more_ammo"
	self.ammo_bag.sound_done = "pickup_ammo"
	self.ammo_bag.action_text_id = "hud_action_taking_ammo"
	self.ammo_bag.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.ammo_bag_small = {}
	self.ammo_bag_small.icon = self.ammo_bag.icon
	self.ammo_bag_small.text_id = self.ammo_bag.text_id
	self.ammo_bag_small.contour = self.ammo_bag.contour
	self.ammo_bag_small.blocked_hint = self.ammo_bag.blocked_hint
	self.ammo_bag_small.blocked_hint_sound = self.ammo_bag.blocked_hint_sound
	self.ammo_bag_small.sound_start = self.ammo_bag.sound_start
	self.ammo_bag_small.sound_interupt = self.ammo_bag.sound_interupt
	self.ammo_bag_small.sound_done = self.ammo_bag.sound_done
	self.ammo_bag_small.action_text_id = self.ammo_bag.action_text_id
	self.ammo_bag_small.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.ammo_bag_big = {}
	self.ammo_bag_big.icon = self.ammo_bag.icon
	self.ammo_bag_big.text_id = self.ammo_bag.text_id
	self.ammo_bag_big.contour = self.ammo_bag.contour
	self.ammo_bag_big.blocked_hint = self.ammo_bag.blocked_hint
	self.ammo_bag_big.blocked_hint_sound = self.ammo_bag.blocked_hint_sound
	self.ammo_bag_big.sound_start = self.ammo_bag.sound_start
	self.ammo_bag_big.sound_interupt = self.ammo_bag.sound_interupt
	self.ammo_bag_big.sound_done = self.ammo_bag.sound_done
	self.ammo_bag_big.action_text_id = self.ammo_bag.action_text_id
	self.ammo_bag_big.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.health_bag = {}
	self.health_bag.icon = "equipment_doctor_bag"
	self.health_bag.text_id = "hud_interact_doctor_bag_heal"
	self.health_bag.contour = "deployable"
	self.health_bag.blocked_hint = "hint_full_health"
	self.health_bag.blocked_hint_sound = "no_more_health"
	self.health_bag.sound_done = "pickup_health"
	self.health_bag.action_text_id = "hud_action_healing"
	self.health_bag.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.health_bag_small = {}
	self.health_bag_small.icon = self.health_bag.icon
	self.health_bag_small.text_id = self.health_bag.text_id
	self.health_bag_small.contour = self.health_bag.contour
	self.health_bag_small.timer = 0
	self.health_bag_small.blocked_hint = self.health_bag.blocked_hint
	self.health_bag_small.blocked_hint_sound = self.health_bag.blocked_hint_sound
	self.health_bag_small.sound_start = self.health_bag.sound_start
	self.health_bag_small.sound_interupt = self.health_bag.sound_interupt
	self.health_bag_small.sound_done = self.health_bag.sound_done
	self.health_bag_small.action_text_id = self.health_bag.action_text_id
	self.health_bag_small.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.health_bag_big = {}
	self.health_bag_big.icon = self.health_bag.icon
	self.health_bag_big.text_id = self.health_bag.text_id
	self.health_bag_big.contour = self.health_bag.contour
	self.health_bag_big.timer = 0
	self.health_bag_big.blocked_hint = self.health_bag.blocked_hint
	self.health_bag_big.blocked_hint_sound = self.health_bag.blocked_hint_sound
	self.health_bag_big.sound_start = self.health_bag.sound_start
	self.health_bag_big.sound_interupt = self.health_bag.sound_interupt
	self.health_bag_big.sound_done = self.health_bag.sound_done
	self.health_bag_big.action_text_id = self.health_bag.action_text_id
	self.health_bag_big.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.resupply_all_equipment = {}
	self.resupply_all_equipment.start_active = true
	self.resupply_all_equipment.keep_active = true
	self.resupply_all_equipment.icon = self.ammo_bag_big.icon
	self.resupply_all_equipment.text_id = "hud_interact_ammo_bag_take_ammo"
	self.resupply_all_equipment.contour = self.ammo_bag_big.contour
	self.resupply_all_equipment.timer = 0.5
	self.resupply_all_equipment.blocked_hint = self.ammo_bag_big.blocked_hint
	self.resupply_all_equipment.blocked_hint_sound = self.ammo_bag_big.blocked_hint_sound
	self.resupply_all_equipment.sound_start = self.ammo_bag_big.sound_start
	self.resupply_all_equipment.sound_interupt = self.ammo_bag_big.sound_interupt
	self.resupply_all_equipment.sound_done = self.ammo_bag_big.sound_done
	self.resupply_all_equipment.action_text_id = self.ammo_bag_big.action_text_id
	self.resupply_all_equipment.interact_distance = self.POWERUP_INTERACTION_DISTANCE
	self.doctor_bag = {}
	self.doctor_bag.icon = "equipment_doctor_bag"
	self.doctor_bag.text_id = "debug_interact_doctor_bag_heal"
	self.doctor_bag.contour = "deployable"
	self.doctor_bag.timer = 3.5
	self.doctor_bag.blocked_hint = "hint_full_health"
	self.doctor_bag.sound_start = "bar_helpup"
	self.doctor_bag.sound_interupt = "bar_helpup_cancel"
	self.doctor_bag.sound_done = "bar_helpup_finished"
	self.doctor_bag.action_text_id = "hud_action_healing"
	self.doctor_bag.upgrade_timer_multiplier = {
		upgrade = "interaction_speed_multiplier",
		category = "doctor_bag"
	}
	self.test_interactive_door = {}
	self.test_interactive_door.icon = "develop"
	self.test_interactive_door.text_id = "debug_interact_temp_interact_box"
	self.test_interactive_door_one_direction = {}
	self.test_interactive_door_one_direction.icon = "develop"
	self.test_interactive_door_one_direction.text_id = "debug_interact_temp_interact_box"
	self.test_interactive_door_one_direction.axis = "y"
	self.temp_interact_box = {}
	self.temp_interact_box.icon = "develop"
	self.temp_interact_box.text_id = "debug_interact_temp_interact_box"
	self.temp_interact_box.timer = 4
	self.requires_cable_ties = {}
	self.requires_cable_ties.icon = "develop"
	self.requires_cable_ties.text_id = "debug_interact_temp_interact_box"
	self.requires_cable_ties.equipment_text_id = "debug_interact_equipment_requires_cable_ties"
	self.requires_cable_ties.special_equipment = "cable_tie"
	self.requires_cable_ties.equipment_consume = true
	self.requires_cable_ties.timer = 5
	self.requires_cable_ties.requires_upgrade = {
		upgrade = "can_cable_tie_doors",
		category = "cable_tie"
	}
	self.requires_cable_ties.upgrade_timer_multiplier = {
		upgrade = "interact_speed_multiplier",
		category = "cable_tie"
	}
	self.temp_interact_box_no_timer = {}
	self.temp_interact_box_no_timer.icon = "develop"
	self.temp_interact_box_no_timer.text_id = "debug_interact_temp_interact_box"
	self.access_camera = {}
	self.access_camera.icon = "develop"
	self.access_camera.text_id = "hud_int_access_camera"
	self.access_camera.interact_distance = 125
	self.driving_console = {}
	self.driving_console.icon = "develop"
	self.driving_console.text_id = "hud_int_driving_console"
	self.driving_console.interact_distance = 500
	self.driving_drive = {}
	self.driving_drive.icon = "develop"
	self.driving_drive.text_id = "hud_int_driving_drive"
	self.driving_drive.timer = 1
	self.driving_drive.interact_distance = 500
	self.driving_willy = {}
	self.driving_willy.icon = "develop"
	self.driving_willy.text_id = "hud_int_driving_drive"
	self.driving_willy.timer = 1
	self.driving_willy.interact_distance = 200
	self.foxhole = {}
	self.foxhole.icon = "develop"
	self.foxhole.text_id = "hud_int_enter_foxhole"
	self.foxhole.timer = 1
	self.foxhole.interact_distance = 500
	self.foxhole.sound_start = "cvy_foxhole_start"
	self.foxhole.sound_interupt = "cvy_foxhole_cancel"
	self.foxhole.sound_done = "cvy_foxhole_finish"
	self.main_menu_select_interaction = {}
	self.main_menu_select_interaction.text_id = "hud_menu_crate_select"
	self.main_menu_select_interaction.interact_distance = 300
	self.main_menu_select_interaction.sound_done = "paper_shuffle"
	self.interaction_ball = {}
	self.interaction_ball.icon = "develop"
	self.interaction_ball.text_id = "debug_interact_interaction_ball"
	self.interaction_ball.timer = 5
	self.interaction_ball.sound_start = "cft_hose_loop"
	self.interaction_ball.sound_interupt = "cft_hose_cancel"
	self.interaction_ball.sound_done = "cft_hose_end"
	self.invisible_interaction_open = {}
	self.invisible_interaction_open.icon = "develop"
	self.invisible_interaction_open.text_id = "hud_int_invisible_interaction_open"
	self.invisible_interaction_open.timer = 0.5
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
	self.interact_gen_pku_loot_take = {}
	self.interact_gen_pku_loot_take.icon = "develop"
	self.interact_gen_pku_loot_take.text_id = "debug_interact_gen_pku_loot_take"
	self.interact_gen_pku_loot_take.timer = 2
	self.water_tap = {}
	self.water_tap.icon = "develop"
	self.water_tap.text_id = "debug_interact_water_tap"
	self.water_tap.timer = 3
	self.water_tap.start_active = false
	self.water_tap.axis = "y"
	self.water_manhole = {}
	self.water_manhole.icon = "develop"
	self.water_manhole.text_id = "debug_interact_water_tap"
	self.water_manhole.timer = 3
	self.water_manhole.start_active = false
	self.water_manhole.axis = "z"
	self.water_manhole.interact_distance = 200
	self.sewer_manhole = {}
	self.sewer_manhole.icon = "develop"
	self.sewer_manhole.text_id = "debug_interact_sewer_manhole"
	self.sewer_manhole.timer = 3
	self.sewer_manhole.start_active = false
	self.sewer_manhole.interact_distance = 200
	self.sewer_manhole.equipment_text_id = "hud_interact_equipment_crowbar"
	self.circuit_breaker = {}
	self.circuit_breaker.icon = "interaction_powerbox"
	self.circuit_breaker.text_id = "debug_interact_circuit_breaker"
	self.circuit_breaker.start_active = false
	self.circuit_breaker.axis = "z"
	self.hold_circuit_breaker = deep_clone(self.circuit_breaker)
	self.hold_circuit_breaker.timer = 2
	self.hold_circuit_breaker.text_id = "hud_int_hold_turn_on_power"
	self.hold_circuit_breaker.action_text_id = "hud_action_turning_on_power"
	self.hold_circuit_breaker.axis = "y"
	self.transformer_box = {}
	self.transformer_box.icon = "interaction_powerbox"
	self.transformer_box.text_id = "debug_interact_transformer_box"
	self.transformer_box.start_active = false
	self.transformer_box.axis = "y"
	self.transformer_box.timer = 5
	self.stash_server_cord = {}
	self.stash_server_cord.icon = "interaction_powercord"
	self.stash_server_cord.text_id = "debug_interact_stash_server_cord"
	self.stash_server_cord.start_active = false
	self.stash_server_cord.axis = "z"
	self.stash_planks = {}
	self.stash_planks.icon = "equipment_planks"
	self.stash_planks.contour = "interactable_icon"
	self.stash_planks.text_id = "debug_interact_stash_planks"
	self.stash_planks.start_active = false
	self.stash_planks.timer = 2.5
	self.stash_planks.equipment_text_id = "debug_interact_equipment_stash_planks"
	self.stash_planks.special_equipment = "planks"
	self.stash_planks.equipment_consume = true
	self.stash_planks.sound_start = "bar_barricade_window"
	self.stash_planks.sound_interupt = "bar_barricade_window_cancel"
	self.stash_planks.sound_done = "bar_barricade_window_finished"
	self.stash_planks.action_text_id = "hud_action_barricading"
	self.stash_planks.axis = "z"
	self.stash_planks_pickup = {}
	self.stash_planks_pickup.icon = "equipment_planks"
	self.stash_planks_pickup.text_id = "debug_interact_stash_planks_pickup"
	self.stash_planks_pickup.start_active = false
	self.stash_planks_pickup.timer = 2
	self.stash_planks_pickup.axis = "z"
	self.stash_planks_pickup.special_equipment_block = "planks"
	self.stash_planks_pickup.sound_start = "bar_pick_up_planks"
	self.stash_planks_pickup.sound_interupt = "bar_pick_up_planks_cancel"
	self.stash_planks_pickup.sound_done = "bar_pick_up_planks_finished"
	self.stash_planks_pickup.action_text_id = "hud_action_grabbing_planks"
	self.stash_server = {}
	self.stash_server.icon = "equipment_stash_server"
	self.stash_server.text_id = "debug_interact_stash_server"
	self.stash_server.timer = 2
	self.stash_server.start_active = false
	self.stash_server.axis = "z"
	self.stash_server.equipment_text_id = "debug_interact_equipment_stash_server"
	self.stash_server.special_equipment = "server"
	self.stash_server.equipment_consume = true
	self.stash_server_pickup = {}
	self.stash_server_pickup.icon = "equipment_stash_server"
	self.stash_server_pickup.text_id = "hud_int_hold_take_hdd"
	self.stash_server_pickup.timer = 1
	self.stash_server_pickup.start_active = false
	self.stash_server_pickup.axis = "z"
	self.stash_server_pickup.special_equipment_block = "server"
	self.stash_server_pickup.interact_distance = 250
	self.shelf_sliding_suburbia = {}
	self.shelf_sliding_suburbia.icon = "develop"
	self.shelf_sliding_suburbia.text_id = "debug_interact_move_bookshelf"
	self.shelf_sliding_suburbia.start_active = false
	self.shelf_sliding_suburbia.timer = 3
	self.tear_painting = {}
	self.tear_painting.icon = "develop"
	self.tear_painting.text_id = "debug_interact_tear_painting"
	self.tear_painting.start_active = false
	self.tear_painting.axis = "y"
	self.ejection_seat_interact = {}
	self.ejection_seat_interact.icon = "equipment_ejection_seat"
	self.ejection_seat_interact.text_id = "debug_interact_temp_interact_box"
	self.ejection_seat_interact.timer = 4
	self.diamond_pickup = {}
	self.diamond_pickup.icon = "interaction_diamond"
	self.diamond_pickup.text_id = "hud_int_take_jewelry"
	self.diamond_pickup.sound_event = "money_grab"
	self.diamond_pickup.start_active = false
	self.diamond_pickup.requires_mask_off_upgrade = {
		upgrade = "mask_off_pickup",
		category = "player"
	}
	self.safe_loot_pickup = deep_clone(self.diamond_pickup)
	self.safe_loot_pickup.start_active = true
	self.safe_loot_pickup.text_id = "hud_int_take"
	self.mus_pku_artifact = deep_clone(self.diamond_pickup)
	self.mus_pku_artifact.start_active = true
	self.mus_pku_artifact.text_id = "hud_int_take_artifact"
	self.tiara_pickup = {}
	self.tiara_pickup.icon = "develop"
	self.tiara_pickup.text_id = "hud_int_pickup_tiara"
	self.tiara_pickup.sound_event = "money_grab"
	self.tiara_pickup.start_active = false
	self.patientpaper_pickup = {}
	self.patientpaper_pickup.icon = "interaction_patientfile"
	self.patientpaper_pickup.text_id = "debug_interact_patient_paper"
	self.patientpaper_pickup.timer = 2
	self.patientpaper_pickup.start_active = false
	self.diamond_case = {}
	self.diamond_case.icon = "interaction_diamond"
	self.diamond_case.text_id = "debug_interact_diamond_case"
	self.diamond_case.start_active = false
	self.diamond_case.axis = "x"
	self.diamond_case.interact_distance = 150
	self.diamond_single_pickup = {}
	self.diamond_single_pickup.icon = "interaction_diamond"
	self.diamond_single_pickup.text_id = "debug_interact_temp_interact_box_press"
	self.diamond_single_pickup.start_active = false
	self.suburbia_necklace_pickup = {}
	self.suburbia_necklace_pickup.icon = "interaction_diamond"
	self.suburbia_necklace_pickup.text_id = "debug_interact_temp_interact_box_press"
	self.suburbia_necklace_pickup.start_active = false
	self.suburbia_necklace_pickup.interact_distance = 100
	self.temp_interact_box2 = {}
	self.temp_interact_box2.icon = "develop"
	self.temp_interact_box2.text_id = "debug_interact_temp_interact_box"
	self.temp_interact_box2.timer = 20
	self.printing_plates = {}
	self.printing_plates.icon = "develop"
	self.printing_plates.text_id = "hud_int_printing_plates"
	self.c4 = {}
	self.c4.icon = "equipment_c4"
	self.c4.text_id = "debug_interact_c4"
	self.c4.timer = 4
	self.c4.sound_start = "bar_c4_apply"
	self.c4.sound_interupt = "bar_c4_apply_cancel"
	self.c4.sound_done = "bar_c4_apply_finished"
	self.c4.action_text_id = "hud_action_placing_c4"
	self.c4_mission_door = deep_clone(self.c4)
	self.c4_mission_door.special_equipment = "c4"
	self.c4_mission_door.equipment_text_id = "debug_interact_equipment_c4"
	self.c4_mission_door.equipment_consume = true
	self.c4_diffusible = {}
	self.c4_diffusible.icon = "equipment_c4"
	self.c4_diffusible.text_id = "debug_c4_diffusible"
	self.c4_diffusible.timer = 4
	self.c4_diffusible.sound_start = "bar_c4_apply"
	self.c4_diffusible.sound_interupt = "bar_c4_apply_cancel"
	self.c4_diffusible.sound_done = "bar_c4_apply_finished"
	self.c4_diffusible.axis = "z"
	self.open_trunk = {}
	self.open_trunk.icon = "develop"
	self.open_trunk.text_id = "debug_interact_open_trunk"
	self.open_trunk.timer = 0.5
	self.open_trunk.axis = "x"
	self.open_trunk.action_text_id = "hud_action_opening_trunk"
	self.open_trunk.sound_start = "truck_back_door_opening"
	self.open_trunk.sound_done = "truck_back_door_open"
	self.open_trunk.sound_interupt = "stop_truck_back_door_opening"
	self.embassy_door = {}
	self.embassy_door.start_active = false
	self.embassy_door.icon = "interaction_open_door"
	self.embassy_door.text_id = "debug_interact_embassy_door"
	self.embassy_door.interact_distance = 150
	self.embassy_door.timer = 5
	self.c4_special = {}
	self.c4_special.icon = "equipment_c4"
	self.c4_special.text_id = "debug_interact_c4"
	self.c4_special.equipment_text_id = "debug_interact_equipment_c4"
	self.c4_special.equipment_consume = true
	self.c4_special.timer = 4
	self.c4_special.sound_start = "bar_c4_apply"
	self.c4_special.sound_interupt = "bar_c4_apply_cancel"
	self.c4_special.sound_done = "bar_c4_apply_finished"
	self.c4_special.axis = "z"
	self.c4_special.action_text_id = "hud_action_placing_c4"
	self.c4_bag = {}
	self.c4_bag.text_id = "debug_interact_c4_bag"
	self.c4_bag.timer = 4
	self.c4_bag.contour = "interactable"
	self.c4_bag.axis = "z"
	self.money_wrap = {}
	self.money_wrap.icon = "interaction_money_wrap"
	self.money_wrap.text_id = "debug_interact_money_wrap_take_money"
	self.money_wrap.start_active = false
	self.money_wrap.timer = 3
	self.money_wrap.action_text_id = "hud_action_taking_money"
	self.money_wrap.blocked_hint = "hud_hint_carry_block_interact"
	self.money_wrap.sound_start = "bar_bag_money"
	self.money_wrap.sound_interupt = "bar_bag_money_cancel"
	self.money_wrap.sound_done = "bar_bag_money_finished"
	self.suburbia_money_wrap = {}
	self.suburbia_money_wrap.icon = "interaction_money_wrap"
	self.suburbia_money_wrap.text_id = "debug_interact_money_printed_take_money"
	self.suburbia_money_wrap.start_active = false
	self.suburbia_money_wrap.timer = 3
	self.suburbia_money_wrap.action_text_id = "hud_action_taking_money"
	self.money_wrap_single_bundle = {}
	self.money_wrap_single_bundle.icon = "interaction_money_wrap"
	self.money_wrap_single_bundle.text_id = "debug_interact_money_wrap_single_bundle_take_money"
	self.money_wrap_single_bundle.start_active = false
	self.money_wrap_single_bundle.interact_distance = 200
	self.money_wrap_single_bundle.requires_mask_off_upgrade = {
		upgrade = "mask_off_pickup",
		category = "player"
	}
	self.money_wrap_single_bundle.start_active = true
	self.christmas_present = {}
	self.christmas_present.icon = "interaction_christmas_present"
	self.christmas_present.text_id = "debug_interact_take_christmas_present"
	self.christmas_present.start_active = true
	self.christmas_present.interact_distance = 125
	self.gold_pile = {}
	self.gold_pile.icon = "interaction_gold"
	self.gold_pile.text_id = "hud_interact_gold_pile_take_money"
	self.gold_pile.start_active = true
	self.gold_pile.action_text_id = "hud_action_taking_gold"
	self.gold_pile.blocked_hint = "hud_hint_carry_block_interact"
	self.gold_pile.sound_done = "gold_crate_drop"
	self.gold_pile.timer = 1
	self.gold_pile_inactive = deep_clone(self.gold_pile)
	self.gold_pile_inactive.start_active = false
	self.take_gold_bar = {}
	self.take_gold_bar.icon = "interaction_gold"
	self.take_gold_bar.text_id = "hud_take_gold_bar"
	self.take_gold_bar.start_active = true
	self.take_gold_bar.blocked_hint = "hud_hint_carry_block_interact"
	self.take_gold_bar.sound_done = "gold_crate_drop"
	self.take_gold_bar.timer = 0
	self.take_gold_bar_bag = {}
	self.take_gold_bar_bag.icon = "develop"
	self.take_gold_bar_bag.text_id = "hud_take_gold_bar"
	self.take_gold_bar_bag.action_text_id = "hud_action_taking_gold_bar"
	self.take_gold_bar_bag.timer = 0
	self.take_gold_bar_bag.force_update_position = true
	self.take_gold_bar_bag.blocked_hint = "hud_hint_carry_block_interact"
	self.take_gold_bar_bag.sound_start = "gold_crate_pickup"
	self.take_gold_bar_bag.sound_interupt = "gold_crate_drop"
	self.take_gold_bar_bag.sound_done = "gold_crate_drop"
	self.gold_bag = {}
	self.gold_bag.icon = "interaction_gold"
	self.gold_bag.text_id = "debug_interact_gold_bag"
	self.gold_bag.start_active = false
	self.gold_bag.timer = 1
	self.gold_bag.special_equipment_block = "gold_bag_equip"
	self.gold_bag.action_text_id = "hud_action_taking_gold"
	self.requires_gold_bag = {}
	self.requires_gold_bag.icon = "interaction_gold"
	self.requires_gold_bag.text_id = "debug_interact_requires_gold_bag"
	self.requires_gold_bag.equipment_text_id = "debug_interact_equipment_requires_gold_bag"
	self.requires_gold_bag.special_equipment = "gold_bag_equip"
	self.requires_gold_bag.start_active = true
	self.requires_gold_bag.equipment_consume = true
	self.requires_gold_bag.timer = 1
	self.requires_gold_bag.axis = "x"
	self.intimidate = {}
	self.intimidate.icon = "equipment_cable_ties"
	self.intimidate.text_id = "debug_interact_intimidate"
	self.intimidate.equipment_text_id = "debug_interact_equipment_cable_tie"
	self.intimidate.start_active = false
	self.intimidate.special_equipment = "cable_tie"
	self.intimidate.equipment_consume = true
	self.intimidate.no_contour = true
	self.intimidate.timer = 2
	self.intimidate.upgrade_timer_multiplier = {
		upgrade = "interact_speed_multiplier",
		category = "cable_tie"
	}
	self.intimidate.action_text_id = "hud_action_cable_tying"
	self.intimidate_and_search = {}
	self.intimidate_and_search.icon = "equipment_cable_ties"
	self.intimidate_and_search.text_id = "debug_interact_intimidate"
	self.intimidate_and_search.equipment_text_id = "debug_interact_search_key"
	self.intimidate_and_search.start_active = false
	self.intimidate_and_search.special_equipment = "cable_tie"
	self.intimidate_and_search.equipment_consume = true
	self.intimidate_and_search.dont_need_equipment = true
	self.intimidate_and_search.no_contour = true
	self.intimidate_and_search.timer = 3.5
	self.intimidate_and_search.action_text_id = "hud_action_cable_tying"
	self.intimidate_with_contour = deep_clone(self.intimidate)
	self.intimidate_with_contour.no_contour = false
	self.intimidate_and_search_with_contour = deep_clone(self.intimidate_and_search)
	self.intimidate_and_search_with_contour.no_contour = false
	self.computer_test = {}
	self.computer_test.icon = "develop"
	self.computer_test.text_id = "debug_interact_computer_test"
	self.computer_test.start_active = false
	self.carry_drop = {}
	self.carry_drop.icon = "develop"
	self.carry_drop.text_id = "hud_int_hold_grab_the_bag"
	self.carry_drop.timer = 1
	self.carry_drop.force_update_position = true
	self.carry_drop.upgrade_timer_multiplier = {
		upgrade = "carry_pickup_multiplier",
		category = "interaction"
	}
	self.carry_drop.action_text_id = "hud_action_grabbing_bag"
	self.carry_drop.blocked_hint = "hud_hint_carry_block_interact"
	self.painting_carry_drop = {}
	self.painting_carry_drop.icon = "develop"
	self.painting_carry_drop.text_id = "hud_int_hold_grab_the_painting"
	self.painting_carry_drop.timer = 1
	self.painting_carry_drop.force_update_position = true
	self.painting_carry_drop.action_text_id = "hud_action_grabbing_painting"
	self.painting_carry_drop.blocked_hint = "hud_hint_carry_block_interact"
	self.corpse_alarm_pager = {}
	self.corpse_alarm_pager.icon = "develop"
	self.corpse_alarm_pager.text_id = "hud_int_disable_alarm_pager"
	self.corpse_alarm_pager.timer = 10
	self.corpse_alarm_pager.force_update_position = true
	self.corpse_alarm_pager.action_text_id = "hud_action_disabling_alarm_pager"
	self.corpse_alarm_pager.contour_preset = "generic_interactable"
	self.corpse_alarm_pager.contour_preset_selected = "generic_interactable_selected"
	self.corpse_alarm_pager.contour_flash_interval = 0.15
	self.corpse_alarm_pager.upgrade_timer_multiplier = {
		upgrade = "alarm_pager_speed_multiplier",
		category = "player"
	}
	self.corpse_alarm_pager.interact_dont_interupt_on_distance = true
	self.corpse_dispose = {}
	self.corpse_dispose.icon = "develop"
	self.corpse_dispose.text_id = "hud_int_dispose_corpse"
	self.corpse_dispose.timer = 2
	self.corpse_dispose.upgrade_timer_multiplier = {
		upgrade = "corpse_dispose_speed_multiplier",
		category = "player"
	}
	self.corpse_dispose.action_text_id = "hud_action_disposing_corpse"
	self.corpse_dispose.no_contour = true
	self.shaped_sharge = {}
	self.shaped_sharge.icon = "equipment_c4"
	self.shaped_sharge.text_id = "hud_int_equipment_shaped_charge"
	self.shaped_sharge.contour = "interactable_icon"
	self.shaped_sharge.required_deployable = "trip_mine"
	self.shaped_sharge.deployable_consume = true
	self.shaped_sharge.timer = 4
	self.shaped_sharge.sound_start = "bar_c4_apply"
	self.shaped_sharge.sound_interupt = "bar_c4_apply_cancel"
	self.shaped_sharge.sound_done = "bar_c4_apply_finished"
	self.shaped_sharge.requires_upgrade = {
		upgrade = "trip_mine_shaped_charge",
		category = "player"
	}
	self.shaped_sharge.action_text_id = "hud_action_placing_shaped_charge"
	self.shaped_charge_single = deep_clone(self.shaped_sharge)
	self.shaped_charge_single.axis = "z"
	self.hostage_convert = {}
	self.hostage_convert.icon = "develop"
	self.hostage_convert.text_id = "hud_int_hostage_convert"
	self.hostage_convert.blocked_hint = "convert_enemy_failed"
	self.hostage_convert.timer = 1.5
	self.hostage_convert.requires_upgrade = {
		upgrade = "convert_enemies",
		category = "player"
	}
	self.hostage_convert.upgrade_timer_multiplier = {
		upgrade = "convert_enemies_interaction_speed_multiplier",
		category = "player"
	}
	self.hostage_convert.action_text_id = "hud_action_converting_hostage"
	self.hostage_convert.no_contour = true
	self.break_open = {}
	self.break_open.icon = "develop"
	self.break_open.text_id = "hud_int_break_open"
	self.break_open.start_active = false
	self.cut_fence = {}
	self.cut_fence.text_id = "hud_int_hold_cut_fence"
	self.cut_fence.action_text_id = "hud_action_cutting_fence"
	self.cut_fence.contour = "interactable_icon"
	self.cut_fence.timer = 0.5
	self.cut_fence.start_active = true
	self.cut_fence.sound_start = "bar_cut_fence"
	self.cut_fence.sound_interupt = "bar_cut_fence_cancel"
	self.cut_fence.sound_done = "bar_cut_fence_finished"
	self.burning_money = {}
	self.burning_money.text_id = "hud_int_hold_ignite_money"
	self.burning_money.action_text_id = "hud_action_igniting_money"
	self.burning_money.timer = 2
	self.burning_money.start_active = false
	self.burning_money.interact_distance = 250
	self.hold_take_painting = {}
	self.hold_take_painting.text_id = "hud_int_hold_take_painting"
	self.hold_take_painting.action_text_id = "hud_action_taking_painting"
	self.hold_take_painting.start_active = false
	self.hold_take_painting.axis = "y"
	self.hold_take_painting.timer = 2
	self.hold_take_painting.sound_start = "bar_steal_painting"
	self.hold_take_painting.sound_interupt = "bar_steal_painting_cancel"
	self.hold_take_painting.sound_done = "bar_steal_painting_finished"
	self.hold_take_painting.blocked_hint = "hud_hint_carry_block_interact"
	self.barricade_fence = deep_clone(self.stash_planks)
	self.barricade_fence.contour = "interactable_icon"
	self.barricade_fence.sound_start = "bar_barricade_fence"
	self.barricade_fence.sound_interupt = "bar_barricade_fence_cancel"
	self.barricade_fence.sound_done = "bar_barricade_fence_finished"
	self.hack_numpad = {}
	self.hack_numpad.text_id = "hud_int_hold_hack_numpad"
	self.hack_numpad.action_text_id = "hud_action_hacking_numpad"
	self.hack_numpad.start_active = false
	self.hack_numpad.timer = 15
	self.pickup_phone = {}
	self.pickup_phone.text_id = "hud_int_pickup_phone"
	self.pickup_phone.start_active = false
	self.pickup_tablet = deep_clone(self.pickup_phone)
	self.pickup_tablet.text_id = "hud_int_pickup_tablet"
	self.hold_take_server = {}
	self.hold_take_server.text_id = "hud_int_hold_take_server"
	self.hold_take_server.action_text_id = "hud_action_taking_server"
	self.hold_take_server.timer = 4
	self.hold_take_server.sound_start = "bar_steal_circuit"
	self.hold_take_server.sound_interupt = "bar_steal_circuit_cancel"
	self.hold_take_server.sound_done = "bar_steal_circuit_finished"
	self.hold_take_server_axis = deep_clone(self.hold_take_server)
	self.hold_take_server_axis.axis = "y"
	self.hold_take_blueprints = {}
	self.hold_take_blueprints.text_id = "hud_int_hold_take_blueprints"
	self.hold_take_blueprints.action_text_id = "hud_action_taking_blueprints"
	self.hold_take_blueprints.start_active = false
	self.hold_take_blueprints.timer = 0.5
	self.hold_take_blueprints.sound_start = "bar_steal_painting"
	self.hold_take_blueprints.sound_interupt = "bar_steal_painting_cancel"
	self.hold_take_blueprints.sound_done = "bar_steal_painting_finished"
	self.take_confidential_folder = {}
	self.take_confidential_folder.text_id = "hud_int_take_confidential_folder"
	self.take_confidential_folder.start_active = false
	self.take_confidential_folder_event = {}
	self.take_confidential_folder_event.text_id = "hud_int_take_confidential_folder_event"
	self.take_confidential_folder_event.start_active = false
	self.take_confidential_folder_event.timer = 1
	self.hold_take_gas_can = {}
	self.hold_take_gas_can.text_id = "hud_int_hold_take_gas"
	self.hold_take_gas_can.action_text_id = "hud_action_taking_gasoline"
	self.hold_take_gas_can.start_active = false
	self.hold_take_gas_can.timer = 0.5
	self.hold_take_gas_can.special_equipment_block = "gas"
	self.gen_ladyjustice_statue = {}
	self.gen_ladyjustice_statue.text_id = "hud_int_ladyjustice_statue"
	self.hold_place_gps_tracker = {}
	self.hold_place_gps_tracker.text_id = "hud_int_hold_place_gps_tracker"
	self.hold_place_gps_tracker.action_text_id = "hud_action_placing_gps_tracker"
	self.hold_place_gps_tracker.contour = "interactable_icon"
	self.hold_place_gps_tracker.start_active = false
	self.hold_place_gps_tracker.timer = 1.5
	self.hold_place_gps_tracker.interact_distance = 200
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
	self.hold_use_computer = {}
	self.hold_use_computer.start_active = false
	self.hold_use_computer.text_id = "hud_int_hold_use_computer"
	self.hold_use_computer.action_text_id = "hud_action_using_computer"
	self.hold_use_computer.timer = 1
	self.hold_use_computer.axis = "z"
	self.hold_use_computer.interact_distance = 100
	self.use_server_device = {}
	self.use_server_device.text_id = "hud_int_hold_use_device"
	self.use_server_device.action_text_id = "hud_action_using_device"
	self.use_server_device.timer = 1
	self.use_server_device.start_active = false
	self.iphone_answer = {}
	self.iphone_answer.text_id = "hud_int_answer_phone"
	self.iphone_answer.start_active = false
	self.use_flare = {}
	self.use_flare.text_id = "hud_int_use_flare"
	self.use_flare.start_active = false
	self.extinguish_flare = {}
	self.extinguish_flare.text_id = "hud_int_estinguish_flare"
	self.extinguish_flare.start_active = false
	self.extinguish_flare.timer = 1
	self.steal_methbag = {}
	self.steal_methbag.text_id = "hud_int_hold_steal_meth"
	self.steal_methbag.action_text_id = "hud_action_stealing_meth"
	self.steal_methbag.start_active = true
	self.steal_methbag.timer = 3
	self.pickup_keycard = {}
	self.pickup_keycard.text_id = "hud_int_pickup_keycard"
	self.pickup_keycard.sound_done = "pick_up_key_card"
	self.pickup_keycard.requires_mask_off_upgrade = {
		upgrade = "mask_off_pickup",
		category = "player"
	}
	self.pickup_keycard.blocked_hint = "full_keycard"
	self.open_from_inside = {}
	self.open_from_inside.text_id = "hud_int_invisible_interaction_open"
	self.open_from_inside.start_active = true
	self.open_from_inside.interact_distance = 100
	self.open_from_inside.timer = 0.2
	self.open_from_inside.axis = "x"
	self.money_luggage = deep_clone(self.money_wrap)
	self.money_luggage.start_active = true
	self.money_luggage.axis = "x"
	self.hold_pickup_lance = {}
	self.hold_pickup_lance.text_id = "hud_int_hold_pickup_lance"
	self.hold_pickup_lance.action_text_id = "hud_action_grabbing_lance"
	self.hold_pickup_lance.timer = 1
	self.barrier_numpad = {}
	self.barrier_numpad.text_id = "hud_int_barrier_numpad"
	self.barrier_numpad.start_active = false
	self.barrier_numpad.axis = "z"
	self.timelock_numpad = {}
	self.timelock_numpad.text_id = "hud_int_timelock_numpad"
	self.timelock_numpad.start_active = false
	self.timelock_numpad.axis = "z"
	self.pickup_asset = {}
	self.pickup_asset.text_id = "hud_int_pickup_asset"
	self.open_slash_close = {}
	self.open_slash_close.text_id = "hud_int_open_slash_close"
	self.open_slash_close.start_active = false
	self.open_slash_close.axis = "y"
	self.open_slash_close.interact_distance = 200
	self.open_slash_close_act = {}
	self.open_slash_close_act.text_id = "hud_int_open_slash_close"
	self.open_slash_close_act.action_text_id = "hud_action_open_slash_close"
	self.open_slash_close_act.timer = 1
	self.open_slash_close_act.start_active = true
	self.raise_balloon = {}
	self.raise_balloon.text_id = "hud_int_hold_raise_balloon"
	self.raise_balloon.action_text_id = "hud_action_raise_balloon"
	self.raise_balloon.start_active = false
	self.raise_balloon.timer = 2
	self.stn_int_place_camera = {}
	self.stn_int_place_camera.text_id = "hud_int_place_camera"
	self.stn_int_place_camera.start_active = true
	self.stn_int_take_camera = {}
	self.stn_int_take_camera.text_id = "hud_int_take_camera"
	self.stn_int_take_camera.start_active = true
	self.gage_assignment = {}
	self.gage_assignment.icon = "develop"
	self.gage_assignment.text_id = "debug_interact_gage_assignment_take"
	self.gage_assignment.start_active = true
	self.gage_assignment.timer = 1
	self.gage_assignment.action_text_id = "hud_action_taking_gage_assignment"
	self.gage_assignment.blocked_hint = "hint_gage_mods_dlc_block"
	self.gen_pku_fusion_reactor = {}
	self.gen_pku_fusion_reactor.text_id = "hud_int_hold_take_reaktor"
	self.gen_pku_fusion_reactor.action_text_id = "hud_action_taking_reaktor"
	self.gen_pku_fusion_reactor.blocked_hint = "hud_hint_carry_block_interact"
	self.gen_pku_fusion_reactor.start_active = false
	self.gen_pku_fusion_reactor.timer = 3
	self.gen_pku_fusion_reactor.no_contour = true
	self.gen_pku_fusion_reactor.sound_start = "bar_bag_money"
	self.gen_pku_fusion_reactor.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_fusion_reactor.sound_done = "bar_bag_money_finished"
	self.gen_pku_cocaine = {}
	self.gen_pku_cocaine.text_id = "hud_int_hold_take_cocaine"
	self.gen_pku_cocaine.action_text_id = "hud_action_taking_cocaine"
	self.gen_pku_cocaine.timer = 3
	self.gen_pku_cocaine.sound_start = "bar_bag_money"
	self.gen_pku_cocaine.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_cocaine.sound_done = "bar_bag_money_finished"
	self.gen_pku_cocaine.blocked_hint = "hud_hint_carry_block_interact"
	self.gen_pku_painting = {}
	self.gen_pku_painting.text_id = "hud_int_hold_take_cocaine"
	self.gen_pku_painting.action_text_id = "hud_action_taking_cocaine"
	self.gen_pku_painting.timer = 3
	self.gen_pku_painting.blocked_hint = "hud_hint_carry_block_interact"
	self.gen_pku_artifact_statue = {}
	self.gen_pku_artifact_statue.text_id = "hud_int_hold_take_artifact"
	self.gen_pku_artifact_statue.action_text_id = "hud_action_taking_artifact"
	self.gen_pku_artifact_statue.timer = 3
	self.gen_pku_artifact_statue.start_active = false
	self.gen_pku_artifact_statue.sound_start = "bar_bag_money"
	self.gen_pku_artifact_statue.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_artifact_statue.sound_done = "bar_bag_money_finished"
	self.gen_pku_artifact_statue.blocked_hint = "hud_hint_carry_block_interact"
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
	self.gen_pku_jewelry = {}
	self.gen_pku_jewelry.text_id = "hud_int_hold_take_jewelry"
	self.gen_pku_jewelry.action_text_id = "hud_action_taking_jewelry"
	self.gen_pku_jewelry.timer = 3
	self.gen_pku_jewelry.sound_start = "bar_bag_jewelry"
	self.gen_pku_jewelry.sound_interupt = "bar_bag_jewelry_cancel"
	self.gen_pku_jewelry.sound_done = "bar_bag_jewelry_finished"
	self.gen_pku_jewelry.blocked_hint = "hud_hint_carry_block_interact"
	self.taking_meth = {}
	self.taking_meth.text_id = "hud_int_hold_take_meth"
	self.taking_meth.action_text_id = "hud_action_taking_meth"
	self.taking_meth.timer = 3
	self.taking_meth.sound_start = "bar_bag_money"
	self.taking_meth.sound_interupt = "bar_bag_money_cancel"
	self.taking_meth.sound_done = "bar_bag_money_finished"
	self.taking_meth.blocked_hint = "hud_hint_carry_block_interact"
	self.gen_pku_crowbar = {}
	self.gen_pku_crowbar.text_id = "hud_int_take_crowbar"
	self.gen_pku_crowbar.special_equipment_block = "crowbar"
	self.gen_pku_crowbar.sound_done = "crowbar_pickup"
	self.gen_pku_crowbar_stack = {}
	self.gen_pku_crowbar_stack.text_id = "hud_int_take_crowbar"
	self.gen_pku_crowbar_stack.special_equipment_block = "crowbar_stack"
	self.gen_pku_crowbar_stack.sound_done = "crowbar_pickup"
	self.gen_pku_thermite = {}
	self.gen_pku_thermite.text_id = "hud_int_take_thermite"
	self.gen_pku_thermite.special_equipment_block = "thermite"
	self.gen_pku_thermite_paste = {}
	self.gen_pku_thermite_paste.text_id = "hud_int_take_thermite_paste"
	self.gen_pku_thermite_paste.special_equipment_block = "thermite_paste"
	self.gen_pku_thermite_paste.contour = "deployable"
	self.gen_pku_thermite_paste.sound_done = "pick_up_thermite"
	self.button_infopad = {}
	self.button_infopad.text_id = "hud_int_press_for_info"
	self.button_infopad.start_active = false
	self.button_infopad.axis = "z"
	self.crate_loot = {}
	self.crate_loot.text_id = "hud_int_hold_crack_crate"
	self.crate_loot.action_text_id = "hud_action_cracking_crate"
	self.crate_loot.timer = 1
	self.crate_loot.start_active = false
	self.crate_loot.sound_start = "bar_open_crate"
	self.crate_loot.sound_interupt = "bar_open_crate_cancel"
	self.crate_loot.sound_done = "bar_open_crate_finished"
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
	self.crate_loot_close = {}
	self.crate_loot_close.text_id = "hud_int_hold_close_crate"
	self.crate_loot_close.action_text_id = "hud_action_closing_crate"
	self.crate_loot_close.timer = 2
	self.crate_loot_close.start_active = false
	self.crate_loot_close.sound_start = "bar_close_crate"
	self.crate_loot_close.sound_interupt = "bar_close_crate_cancel"
	self.crate_loot_close.sound_done = "bar_close_crate_finished"
	self.halloween_trick = {}
	self.halloween_trick.text_id = "hud_int_trick_treat"
	self.disassemble_turret = {}
	self.disassemble_turret.text_id = "hud_int_hold_disassemble_turret"
	self.disassemble_turret.action_text_id = "hud_action_disassemble_turret"
	self.disassemble_turret.blocked_hint = "carry_block"
	self.disassemble_turret.start_active = false
	self.disassemble_turret.timer = 3
	self.disassemble_turret.sound_start = "bar_steal_circuit"
	self.disassemble_turret.sound_interupt = "bar_steal_circuit_cancel"
	self.disassemble_turret.sound_done = "bar_steal_circuit_finished"
	self.take_ammo = {}
	self.take_ammo.text_id = "hud_int_hold_pack_shells"
	self.take_ammo.action_text_id = "hud_action_packing_shells"
	self.take_ammo.blocked_hint = "carry_block"
	self.take_ammo.start_active = false
	self.take_ammo.timer = 2
	self.bank_note = {}
	self.bank_note.text_id = "hud_int_bank_note"
	self.bank_note.start_active = false
	self.bank_note.timer = 3
	self.pickup_boards = {}
	self.pickup_boards.text_id = "hud_int_hold_pickup_boards"
	self.pickup_boards.action_text_id = "hud_action_picking_up"
	self.pickup_boards.start_active = false
	self.pickup_boards.timer = 2
	self.pickup_boards.axis = "z"
	self.pickup_boards.special_equipment_block = "boards"
	self.pickup_boards.sound_start = "bar_pick_up_planks"
	self.pickup_boards.sound_interupt = "bar_pick_up_planks_cancel"
	self.pickup_boards.sound_done = "bar_pick_up_planks_finished"
	self.need_boards = {}
	self.need_boards.contour = "interactable_icon"
	self.need_boards.text_id = "debug_interact_stash_planks"
	self.need_boards.action_text_id = "hud_action_barricading"
	self.need_boards.start_active = false
	self.need_boards.timer = 2.5
	self.need_boards.equipment_text_id = "hud_equipment_need_boards"
	self.need_boards.special_equipment = "boards"
	self.need_boards.equipment_consume = true
	self.need_boards.sound_start = "bar_barricade_window"
	self.need_boards.sound_interupt = "bar_barricade_window_cancel"
	self.need_boards.sound_done = "bar_barricade_window_finished"
	self.need_boards.axis = "z"
	self.uload_database = {}
	self.uload_database.text_id = "hud_int_hold_use_computer"
	self.uload_database.action_text_id = "hud_action_using_computer"
	self.uload_database.timer = 4
	self.uload_database.start_active = false
	self.uload_database.sound_start = "bar_keyboard"
	self.uload_database.sound_interupt = "bar_keyboard_cancel"
	self.uload_database.sound_done = "bar_keyboard_finished"
	self.uload_database.axis = "x"
	self.uload_database.contour = "contour_off"
	self.uload_database_jammed = {}
	self.uload_database_jammed.text_id = "hud_int_hold_resume_upload"
	self.uload_database_jammed.action_text_id = "hud_action_resuming_upload"
	self.uload_database_jammed.timer = 1
	self.uload_database_jammed.sound_start = "bar_keyboard"
	self.uload_database_jammed.sound_interupt = "bar_keyboard_cancel"
	self.uload_database_jammed.sound_done = "bar_keyboard_finished"
	self.uload_database_jammed.axis = "x"
	self.votingmachine2 = {}
	self.votingmachine2.text_id = "debug_interact_hack_ipad"
	self.votingmachine2.timer = 5
	self.votingmachine2.sound_start = "bar_keyboard"
	self.votingmachine2.sound_interupt = "bar_keyboard_cancel"
	self.votingmachine2.sound_done = "bar_keyboard_finished"
	self.votingmachine2_jammed = {}
	self.votingmachine2_jammed.text_id = "debug_interact_hack_ipad_jammed"
	self.votingmachine2_jammed.timer = 5
	self.votingmachine2_jammed.sound_start = "bar_keyboard"
	self.votingmachine2_jammed.sound_interupt = "bar_keyboard_cancel"
	self.votingmachine2_jammed.sound_done = "bar_keyboard_finished"
	self.sc_tape_loop = {}
	self.sc_tape_loop.icon = "interaction_help"
	self.sc_tape_loop.text_id = "hud_int_tape_loop"
	self.sc_tape_loop.start_active = true
	self.sc_tape_loop.interact_distance = 150
	self.sc_tape_loop.no_contour = true
	self.sc_tape_loop.timer = 4
	self.sc_tape_loop.action_text_id = "hud_action_tape_looping"
	self.sc_tape_loop.requires_upgrade = {
		upgrade = "tape_loop_duration",
		category = "player"
	}
	self.money_scanner = deep_clone(self.invisible_interaction_open)
	self.money_scanner.axis = "y"
	self.money_small = deep_clone(self.money_wrap)
	self.money_small.sound_start = "bar_bag_pour_money"
	self.money_small.sound_interupt = "bar_bag_pour_money_cancel"
	self.money_small.sound_done = "bar_bag_pour_money_finished"
	self.money_small_take = deep_clone(self.money_small)
	self.money_small_take.text_id = "debug_interact_money_printed_take_money"
	self.shape_charge_plantable = {}
	self.shape_charge_plantable.text_id = "debug_interact_c4"
	self.shape_charge_plantable.action_text_id = "hud_action_placing_c4"
	self.shape_charge_plantable.equipment_text_id = "debug_interact_equipment_c4"
	self.shape_charge_plantable.special_equipment = "c4"
	self.shape_charge_plantable.equipment_consume = true
	self.shape_charge_plantable.axis = "z"
	self.shape_charge_plantable.timer = 4
	self.shape_charge_plantable.sound_start = "bar_c4_apply"
	self.shape_charge_plantable.sound_interupt = "bar_c4_apply_cancel"
	self.shape_charge_plantable.sound_done = "bar_c4_apply_finished"
	self.player_zipline = {}
	self.player_zipline.text_id = "hud_int_use_zipline"
	self.bag_zipline = {}
	self.bag_zipline.text_id = "hud_int_bag_zipline"
	self.huge_lance = {}
	self.huge_lance.text_id = "hud_int_equipment_huge_lance"
	self.huge_lance.action_text_id = "hud_action_placing_huge_lance"
	self.huge_lance.timer = 3
	self.huge_lance.sound_start = "bar_huge_lance_fix"
	self.huge_lance.sound_interupt = "bar_huge_lance_fix_cancel"
	self.huge_lance.sound_done = "bar_huge_lance_fix_finished"
	self.huge_lance_jammed = {}
	self.huge_lance_jammed.text_id = "hud_int_equipment_huge_lance_jammed"
	self.huge_lance_jammed.action_text_id = "hud_action_fixing_huge_lance"
	self.huge_lance_jammed.special_equipment = "lance_part"
	self.huge_lance_jammed.equipment_text_id = "hud_int_equipment_no_lance_part"
	self.huge_lance_jammed.blocked_hint = "no_huge_lance"
	self.huge_lance_jammed.equipment_consume = true
	self.huge_lance_jammed.timer = 10
	self.huge_lance_jammed.sound_start = "bar_huge_lance_fix"
	self.huge_lance_jammed.sound_interupt = "bar_huge_lance_fix_cancel"
	self.huge_lance_jammed.sound_done = "bar_huge_lance_fix_finished"
	self.gen_pku_lance_part = {}
	self.gen_pku_lance_part.text_id = "hud_int_take_lance_part"
	self.gen_pku_lance_part.special_equipment_block = "lance_part"
	self.gen_pku_lance_part.sound_done = "drill_fix_end"
	self.crane_joystick_left = {}
	self.crane_joystick_left.text_id = "hud_int_crane_left"
	self.crane_joystick_left.start_active = false
	self.crane_joystick_lift = {}
	self.crane_joystick_lift.text_id = "hud_int_crane_lift"
	self.crane_joystick_lift.start_active = false
	self.crane_joystick_right = {}
	self.crane_joystick_right.text_id = "hud_int_crane_right"
	self.crane_joystick_right.start_active = false
	self.crane_joystick_release = {}
	self.crane_joystick_release.text_id = "hud_int_crane_release"
	self.crane_joystick_release.start_active = false
	self.gen_int_thermite_rig = {}
	self.gen_int_thermite_rig.text_id = "hud_int_hold_assemble_thermite"
	self.gen_int_thermite_rig.action_text_id = "hud_action_assemble_thermite"
	self.gen_int_thermite_rig.special_equipment = "thermite"
	self.gen_int_thermite_rig.equipment_text_id = "debug_interact_equipment_thermite"
	self.gen_int_thermite_rig.equipment_consume = true
	self.gen_int_thermite_rig.contour = "interactable_icon"
	self.gen_int_thermite_rig.timer = 20
	self.gen_int_thermite_rig.sound_start = "bar_drill_apply"
	self.gen_int_thermite_rig.sound_interupt = "bar_drill_apply_cancel"
	self.gen_int_thermite_rig.sound_done = "bar_drill_apply_finished"
	self.gen_int_thermite_apply = {}
	self.gen_int_thermite_apply.text_id = "hud_int_hold_ignite_thermite"
	self.gen_int_thermite_apply.action_text_id = "hud_action_ignite_thermite"
	self.gen_int_thermite_apply.contour = "interactable_icon"
	self.gen_int_thermite_apply.timer = 2
	self.gen_int_thermite_apply.sound_start = "bar_thermal_lance_fix"
	self.gen_int_thermite_apply.sound_interupt = "bar_thermal_lance_fix_cancel"
	self.gen_int_thermite_apply.sound_done = "bar_thermal_lance_fix_finished"
	self.apply_thermite_paste = {}
	self.apply_thermite_paste.text_id = "hud_int_hold_ignite_thermite_paste"
	self.apply_thermite_paste.action_text_id = "hud_action_ignite_thermite_paste"
	self.apply_thermite_paste.special_equipment = "thermite_paste"
	self.apply_thermite_paste.equipment_text_id = "hud_int_need_thermite_paste"
	self.apply_thermite_paste.equipment_consume = true
	self.apply_thermite_paste.start_active = false
	self.apply_thermite_paste.contour = "interactable_icon"
	self.apply_thermite_paste.timer = 2
	self.apply_thermite_paste.sound_start = "bar_thermal_lance_fix"
	self.apply_thermite_paste.sound_interupt = "bar_thermal_lance_fix_cancel"
	self.apply_thermite_paste.sound_done = "bar_thermal_lance_fix_finished"
	self.set_off_alarm = {}
	self.set_off_alarm.text_id = "hud_int_set_off_alarm"
	self.set_off_alarm.action_text_id = "hud_action_setting_off_alarm"
	self.set_off_alarm.timer = 0.5
	self.set_off_alarm.start_active = false
	self.hold_open_vault = {}
	self.hold_open_vault.text_id = "hud_int_hold_open_vault"
	self.hold_open_vault.action_text_id = "hud_action_opening_vault"
	self.hold_open_vault.timer = 4
	self.hold_open_vault.axis = "y"
	self.hold_open_vault.start_active = false
	self.samurai_armor = {}
	self.samurai_armor.text_id = "hud_int_hold_bag_sa_armor"
	self.samurai_armor.action_text_id = "hud_action_bagging_sa_armor"
	self.samurai_armor.blocked_hint = "carry_block"
	self.samurai_armor.start_active = false
	self.samurai_armor.timer = 3
	self.samurai_armor.sound_start = "bar_bag_armor"
	self.samurai_armor.sound_interupt = "bar_bag_armor_cancel"
	self.samurai_armor.sound_done = "bar_bag_armor_finished"
	self.fingerprint_scanner = {}
	self.fingerprint_scanner.text_id = "hud_int_use_scanner"
	self.fingerprint_scanner.start_active = false
	self.enter_code = {}
	self.enter_code.text_id = "hud_int_enter_code"
	self.enter_code.action_text_id = "hud_action_enter_code"
	self.enter_code.timer = 1
	self.enter_code.start_active = false
	self.enter_code.sound_start = "bar_keyboard"
	self.enter_code.sound_interupt = "bar_keyboard_cancel"
	self.enter_code.sound_done = "bar_keyboard_finished"
	self.take_keys = {}
	self.take_keys.text_id = "hud_int_take_keys"
	self.take_bank_door_keys = {}
	self.take_bank_door_keys.start_active = true
	self.take_bank_door_keys.text_id = "hud_int_take_door_keys"
	self.hold_unlock_bank_door = {}
	self.hold_unlock_bank_door.text_id = "hud_int_hold_unlock_door"
	self.hold_unlock_bank_door.action_text_id = "hud_int_action_unlocking_door"
	self.hold_unlock_bank_door.special_equipment = "door_key"
	self.hold_unlock_bank_door.equipment_text_id = "hud_int_need_door_keys"
	self.hold_unlock_bank_door.equipment_consume = false
	self.hold_unlock_bank_door.start_active = false
	self.hold_unlock_bank_door.timer = 2
	self.take_car_keys = {}
	self.take_car_keys.text_id = "hud_int_take_car_keys"
	self.take_car_keys.sound_done = "sps_inter_keys_pickup"
	self.unlock_car_01 = {}
	self.unlock_car_01.text_id = "hud_int_hold_unlock_car"
	self.unlock_car_01.action_text_id = "hud_unlocking_car"
	self.unlock_car_01.special_equipment = "car_key_01"
	self.unlock_car_01.equipment_text_id = "hud_int_need_car_keys"
	self.unlock_car_01.equipment_consume = true
	self.unlock_car_01.start_active = false
	self.unlock_car_01.timer = 2
	self.unlock_car_01.sound_start = "sps_inter_unlock_truck_start_loop"
	self.unlock_car_01.sound_interupt = "sps_inter_unlock_truck_stop_loop"
	self.unlock_car_01.sound_done = "sps_inter_unlock_truck_success"
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
	self.push_button = {}
	self.push_button.text_id = "hud_int_push_button"
	self.push_button.axis = "z"
	self.use_chute = {}
	self.use_chute.text_id = "hud_int_use_chute"
	self.use_chute.axis = "z"
	self.breach_door = {}
	self.breach_door.text_id = "debug_interact_crowbar"
	self.breach_door.action_text_id = "hud_action_breaching_door"
	self.breach_door.start_active = false
	self.breach_door.timer = 2
	self.breach_door.sound_start = "bar_pry_open_elevator_door"
	self.breach_door.sound_interupt = "bar_pry_open_elevator_door_cancel"
	self.breach_door.sound_done = "bar_pry_open_elevator_door_finished"
	self.bus_wall_phone = {}
	self.bus_wall_phone.text_id = "hud_int_use_phone_signal_bus"
	self.bus_wall_phone.start_active = false
	self.zipline_mount = {}
	self.zipline_mount.text_id = "hud_int_setup_zipline"
	self.zipline_mount.action_text_id = "hud_action_setting_zipline"
	self.zipline_mount.start_active = false
	self.zipline_mount.timer = 2
	self.zipline_mount.sound_start = "bar_drill_apply"
	self.zipline_mount.sound_interupt = "bar_drill_apply_cancel"
	self.zipline_mount.sound_done = "bar_drill_apply_finished"
	self.rewire_timelock = deep_clone(self.security_station)
	self.rewire_timelock.text_id = "hud_int_rewire_timelock"
	self.rewire_timelock.action_text_id = "hud_action_rewiring_timelock"
	self.rewire_timelock.axis = "x"
	self.pick_lock_x_axis = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_x_axis.axis = "x"
	self.money_wrap_single_bundle_active = deep_clone(self.money_wrap_single_bundle)
	self.money_wrap_single_bundle_active.start_active = true
	self.pku_barcode_downtown = {}
	self.pku_barcode_downtown.text_id = "hud_int_hold_barcode"
	self.pku_barcode_downtown.action_text_id = "hud_action_barcode"
	self.pku_barcode_downtown.special_equipment_block = "barcode_downtown"
	self.pku_barcode_downtown.timer = 2
	self.pku_barcode_brickell = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_brickell.special_equipment_block = "barcode_brickell"
	self.pku_barcode_edgewater = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_edgewater.special_equipment_block = "barcode_edgewater"
	self.pku_barcode_isles_beach = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_isles_beach.special_equipment_block = "barcode_isles_beach"
	self.pku_barcode_opa_locka = deep_clone(self.pku_barcode_downtown)
	self.pku_barcode_opa_locka.special_equipment_block = "barcode_opa_locka"
	self.read_barcode_downtown = {}
	self.read_barcode_downtown.text_id = "hud_int_hold_read_barcode"
	self.read_barcode_downtown.action_text_id = "hud_action_read_barcode"
	self.read_barcode_downtown.special_equipment = "barcode_downtown"
	self.read_barcode_downtown.dont_need_equipment = false
	self.read_barcode_downtown.possible_special_equipment = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_downtown.equipment_text_id = "hud_equipment_need_barcode"
	self.read_barcode_downtown.equipment_consume = true
	self.read_barcode_downtown.start_active = false
	self.read_barcode_downtown.timer = 2
	self.read_barcode_brickell = {}
	self.read_barcode_brickell.text_id = "hud_int_hold_read_barcode"
	self.read_barcode_brickell.action_text_id = "hud_action_read_barcode"
	self.read_barcode_brickell.special_equipment = "barcode_brickell"
	self.read_barcode_brickell.dont_need_equipment = false
	self.read_barcode_brickell.possible_special_equipment = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_brickell.equipment_text_id = "hud_equipment_need_barcode"
	self.read_barcode_brickell.equipment_consume = true
	self.read_barcode_brickell.start_active = false
	self.read_barcode_brickell.timer = 2
	self.read_barcode_edgewater = {}
	self.read_barcode_edgewater.text_id = "hud_int_hold_read_barcode"
	self.read_barcode_edgewater.action_text_id = "hud_action_read_barcode"
	self.read_barcode_edgewater.special_equipment = "barcode_edgewater"
	self.read_barcode_edgewater.dont_need_equipment = false
	self.read_barcode_edgewater.possible_special_equipment = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_edgewater.equipment_text_id = "hud_equipment_need_barcode"
	self.read_barcode_edgewater.equipment_consume = true
	self.read_barcode_edgewater.start_active = false
	self.read_barcode_edgewater.timer = 2
	self.read_barcode_isles_beach = {}
	self.read_barcode_isles_beach.text_id = "hud_int_hold_read_barcode"
	self.read_barcode_isles_beach.action_text_id = "hud_action_read_barcode"
	self.read_barcode_isles_beach.special_equipment = "barcode_isles_beach"
	self.read_barcode_isles_beach.dont_need_equipment = false
	self.read_barcode_isles_beach.possible_special_equipment = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_isles_beach.equipment_text_id = "hud_equipment_need_barcode"
	self.read_barcode_isles_beach.equipment_consume = true
	self.read_barcode_isles_beach.start_active = false
	self.read_barcode_isles_beach.timer = 2
	self.read_barcode_opa_locka = {}
	self.read_barcode_opa_locka.text_id = "hud_int_hold_read_barcode"
	self.read_barcode_opa_locka.action_text_id = "hud_action_read_barcode"
	self.read_barcode_opa_locka.special_equipment = "barcode_opa_locka"
	self.read_barcode_opa_locka.dont_need_equipment = false
	self.read_barcode_opa_locka.possible_special_equipment = {
		"barcode_downtown",
		"barcode_brickell",
		"barcode_edgewater",
		"barcode_isles_beach",
		"barcode_opa_locka"
	}
	self.read_barcode_opa_locka.equipment_text_id = "hud_equipment_need_barcode"
	self.read_barcode_opa_locka.equipment_consume = true
	self.read_barcode_opa_locka.start_active = false
	self.read_barcode_opa_locka.timer = 2
	self.read_barcode_activate = {}
	self.read_barcode_activate.text_id = "hud_int_hold_activate_reader"
	self.read_barcode_activate.action_text_id = "hud_action_activating_reader"
	self.read_barcode_activate.start_active = false
	self.read_barcode_activate.timer = 2
	self.hlm_motor_start = {}
	self.hlm_motor_start.text_id = "hud_int_hold_start_motor"
	self.hlm_motor_start.action_text_id = "hud_action_startig_motor"
	self.hlm_motor_start.start_active = false
	self.hlm_motor_start.force_update_position = true
	self.hlm_motor_start.timer = 2
	self.hlm_motor_start.sound_start = "bar_huge_lance_fix"
	self.hlm_motor_start.sound_interupt = "bar_huge_lance_fix_cancel"
	self.hlm_motor_start.sound_done = "bar_huge_lance_fix_finished"
	self.hlm_connect_equip = {}
	self.hlm_connect_equip.text_id = "hud_int_hold_connect_equip"
	self.hlm_connect_equip.action_text_id = "hud_action_connecting_equip"
	self.hlm_connect_equip.start_active = false
	self.hlm_connect_equip.timer = 2
	self.hlm_roll_carpet = {}
	self.hlm_roll_carpet.text_id = "hud_int_hold_roll_carpet"
	self.hlm_roll_carpet.action_text_id = "hud_action_rolling_carpet"
	self.hlm_roll_carpet.start_active = false
	self.hlm_roll_carpet.timer = 2
	self.hlm_roll_carpet.sound_start = "bar_roll_carpet"
	self.hlm_roll_carpet.sound_interupt = "bar_roll_carpet_cancel"
	self.hlm_roll_carpet.sound_done = "bar_roll_carpet_finished"
	self.hold_pku_equipmentbag = {}
	self.hold_pku_equipmentbag.text_id = "hud_int_hold_pku_equipment"
	self.hold_pku_equipmentbag.action_text_id = "hud_action_grabbing_equipment"
	self.hold_pku_equipmentbag.timer = 1
	self.disarm_bomb = {}
	self.disarm_bomb.text_id = "hud_int_hold_disarm_bomb"
	self.disarm_bomb.action_text_id = "hud_action_disarm_bomb"
	self.disarm_bomb.start_active = false
	self.disarm_bomb.timer = 2.5
	self.pku_take_mask = {}
	self.pku_take_mask.text_id = "hud_int_take_mask"
	self.pku_take_mask.start_active = true
	self.hold_activate_sprinklers = {}
	self.hold_activate_sprinklers.text_id = "hud_int_hold_activate_sprinklers"
	self.hold_activate_sprinklers.action_text_id = "hud_action_activating_sprinklers"
	self.hold_activate_sprinklers.start_active = false
	self.hold_activate_sprinklers.timer = 0.5
	self.hold_activate_sprinklers.sound_start = "bar_thermal_lance_apply"
	self.hold_activate_sprinklers.sound_interupt = "bar_thermal_lance_apply_cancel"
	self.hold_activate_sprinklers.sound_done = "bar_thermal_lance_apply_finished"
	self.hold_hlm_open_circuitbreaker = {}
	self.hold_hlm_open_circuitbreaker.text_id = "hud_int_hold_open_circuitbreaker"
	self.hold_hlm_open_circuitbreaker.action_text_id = "hud_action_opening_circuitbreaker"
	self.hold_hlm_open_circuitbreaker.start_active = false
	self.hold_hlm_open_circuitbreaker.timer = 0.5
	self.hold_remove_cover = {}
	self.hold_remove_cover.text_id = "hud_int_hold_remove_cover"
	self.hold_remove_cover.action_text_id = "hud_action_removing_cover"
	self.hold_remove_cover.start_active = false
	self.hold_remove_cover.timer = 0.5
	self.hold_cut_cable = {}
	self.hold_cut_cable.text_id = "hud_int_hold_cut_cable"
	self.hold_cut_cable.action_text_id = "hud_action_cutting_cable"
	self.hold_cut_cable.start_active = false
	self.hold_cut_cable.timer = 0.5
	self.hold_cut_cable.sound_start = "bar_cut_fence"
	self.hold_cut_cable.sound_interupt = "bar_cut_fence_cancel"
	self.hold_cut_cable.sound_done = "bar_cut_fence_finished"
	self.firstaid_box = deep_clone(self.doctor_bag)
	self.firstaid_box.start_active = false
	self.first_aid_kit = {}
	self.first_aid_kit.icon = "equipment_first_aid_kit"
	self.first_aid_kit.text_id = "debug_interact_doctor_bag_heal"
	self.first_aid_kit.contour = "deployable"
	self.first_aid_kit.timer = 0
	self.first_aid_kit.blocked_hint = "full_health"
	self.first_aid_kit.sound_start = "bar_helpup"
	self.first_aid_kit.sound_interupt = "bar_helpup_cancel"
	self.first_aid_kit.sound_done = "bar_helpup_finished"
	self.first_aid_kit.action_text_id = "hud_action_healing"
	self.road_spikes = {}
	self.road_spikes.text_id = "hud_int_remove_stinger"
	self.road_spikes.action_text_id = "hud_action_removing_stinger"
	self.road_spikes.timer = 2
	self.road_spikes.axis = "z"
	self.road_spikes.start_active = false
	self.road_spikes.sound_start = "bar_roadspike"
	self.road_spikes.sound_interupt = "bar_roadspike_cancel"
	self.road_spikes.sound_done = "bar_roadspike_finished"
	self.grab_server = {}
	self.grab_server.text_id = "hud_int_grab_server"
	self.grab_server.action_text_id = "hud_action_grab_server"
	self.grab_server.timer = 3
	self.grab_server.sound_start = "bar_bag_money"
	self.grab_server.sound_interupt = "bar_bag_money_cancel"
	self.grab_server.sound_done = "bar_bag_money_finished"
	self.pickup_harddrive = {}
	self.pickup_harddrive.text_id = "hud_int_take_harddrive"
	self.pickup_harddrive.action_text_id = "hud_action_take_harddrive"
	self.pickup_harddrive.special_equipment_block = "harddrive"
	self.pickup_harddrive.timer = 1
	self.place_harddrive = {}
	self.place_harddrive.text_id = "hud_int_place_harddrive"
	self.place_harddrive.action_text_id = "hud_action_place_harddrive"
	self.place_harddrive.equipment_text_id = "hud_equipment_need_harddrive"
	self.place_harddrive.special_equipment = "harddrive"
	self.place_harddrive.equipment_consume = true
	self.place_harddrive.timer = 1
	self.invisible_interaction_searching = {}
	self.invisible_interaction_searching.text_id = "hud_int_search_files"
	self.invisible_interaction_searching.action_text_id = "hud_action_searching_files"
	self.invisible_interaction_searching.timer = 4.5
	self.invisible_interaction_searching.axis = "x"
	self.invisible_interaction_searching.contour = "interactable_icon"
	self.invisible_interaction_searching.special_equipment_block = "files"
	self.invisible_interaction_searching.interact_distance = 200
	self.invisible_interaction_searching.start_active = false
	self.invisible_interaction_searching.sound_start = "bar_shuffle_papers"
	self.invisible_interaction_searching.sound_interupt = "bar_shuffle_papers_cancel"
	self.invisible_interaction_searching.sound_done = "bar_shuffle_papers_finished"
	self.invisible_interaction_gathering = {}
	self.invisible_interaction_gathering.text_id = "hud_int_hold_gather_evidence"
	self.invisible_interaction_gathering.action_text_id = "hud_action_gathering_evidence"
	self.invisible_interaction_gathering.timer = 2
	self.invisible_interaction_gathering.special_equipment_block = "evidence"
	self.invisible_interaction_gathering.start_active = false
	self.invisible_interaction_checking = {}
	self.invisible_interaction_checking.text_id = "hud_int_hold_check_evidence"
	self.invisible_interaction_checking.action_text_id = "hud_action_checking_evidence"
	self.invisible_interaction_checking.equipment_text_id = "hud_equipment_need_evidence"
	self.invisible_interaction_checking.special_equipment = "evidence"
	self.invisible_interaction_checking.equipment_consume = true
	self.invisible_interaction_checking.timer = 2
	self.invisible_interaction_checking.start_active = false
	self.take_medical_supplies = {}
	self.take_medical_supplies.text_id = "hud_int_take_supplies"
	self.take_medical_supplies.action_text_id = "hud_int_taking_supplies"
	self.take_medical_supplies.timer = 2
	self.search_files_false = {}
	self.search_files_false.text_id = "hud_int_search_files"
	self.search_files_false.action_text_id = "hud_action_searching_files"
	self.search_files_false.timer = 4.5
	self.search_files_false.axis = "x"
	self.search_files_false.contour = "interactable_icon"
	self.search_files_false.interact_distance = 200
	self.search_files_false.sound_start = "bar_shuffle_papers"
	self.search_files_false.sound_interupt = "bar_shuffle_papers_cancel"
	self.search_files_false.sound_done = "bar_shuffle_papers_finished"
	self.use_files = {}
	self.use_files.text_id = "hud_int_use_files"
	self.use_files.action_text_id = "hud_action_use_files"
	self.use_files.equipment_text_id = "hud_equipment_need_files"
	self.use_files.special_equipment = "files"
	self.use_files.equipment_consume = true
	self.use_files.timer = 1
	self.use_files.contour = "interactable_icon"
	self.use_files.interact_distance = 200
	self.hack_electric_box = {}
	self.hack_electric_box.text_id = "hud_int_hack_box"
	self.hack_electric_box.action_text_id = "hud_action_hack_box"
	self.hack_electric_box.timer = 6
	self.hack_electric_box.start_active = false
	self.hack_electric_box.axis = "y"
	self.hack_electric_box.sound_start = "bar_hack_fuse_box"
	self.hack_electric_box.sound_interupt = "bar_hack_fuse_box_cancel"
	self.hack_electric_box.sound_done = "bar_hack_fuse_box_finished"
	self.take_ticket = {}
	self.take_ticket.text_id = "hud_int_take_ticket"
	self.take_ticket.action_text_id = "hud_action_take_ticket"
	self.take_ticket.icon = "equipment_crowbar"
	self.take_ticket.timer = 3
	self.take_ticket.special_equipment_block = "ticket"
	self.take_ticket.start_active = false
	self.take_ticket.sound_start = "bar_ticket"
	self.take_ticket.sound_interupt = "bar_ticket_cancel"
	self.take_ticket.sound_done = "bar_ticket_finished"
	self.use_ticket = {}
	self.use_ticket.text_id = "hud_int_use_ticket"
	self.use_ticket.action_text_id = "hud_action_use_ticket"
	self.use_ticket.equipment_text_id = "hud_equipment_use_ticket"
	self.use_ticket.equipment_consume = true
	self.use_ticket.timer = 3
	self.use_ticket.special_equipment = "ticket"
	self.use_ticket.sound_start = "bar_ticket"
	self.use_ticket.sound_interupt = "bar_ticket_cancel"
	self.use_ticket.sound_done = "bar_ticket_finished"
	self.hold_signal_driver = {}
	self.hold_signal_driver = {}
	self.hold_signal_driver.text_id = "hud_int_signal_driver"
	self.hold_signal_driver.action_text_id = "hud_action_signaling_driver"
	self.hold_signal_driver.start_active = false
	self.hold_signal_driver.force_update_position = true
	self.hold_signal_driver.axis = "z"
	self.hold_signal_driver.timer = 1.5
	self.hold_signal_driver.interact_distance = 500
	self.hold_signal_driver.sound_start = "bar_car_tap"
	self.hold_signal_driver.sound_interupt = "bar_car_tap_cancel"
	self.hold_signal_driver.sound_done = "bar_car_tap_finished"
	self.hold_hack_comp = {}
	self.hold_hack_comp.text_id = "hud_int_hold_hack_computer"
	self.hold_hack_comp.action_text_id = "hud_action_hacking_computer"
	self.hold_hack_comp.start_active = false
	self.hold_hack_comp.axis = "z"
	self.hold_hack_comp.timer = 1
	self.hold_approve_req = {}
	self.hold_approve_req.text_id = "hud_int_hold_approve_request"
	self.hold_approve_req.action_text_id = "hud_action_approving_request"
	self.hold_approve_req.start_active = false
	self.hold_approve_req.axis = "z"
	self.hold_approve_req.timer = 1
	self.hold_download_keys = {}
	self.hold_download_keys.text_id = "hud_int_hold_download_keys"
	self.hold_download_keys.action_text_id = "hud_action_downloading_keys"
	self.hold_download_keys.start_active = false
	self.hold_download_keys.axis = "z"
	self.hold_download_keys.timer = 5
	self.hold_download_keys.sound_start = "bar_keyboard"
	self.hold_download_keys.sound_interupt = "bar_keyboard_cancel"
	self.hold_download_keys.sound_done = "bar_keyboard_finished"
	self.hold_analyze_evidence = {}
	self.hold_analyze_evidence.text_id = "hud_int_hold_analyze_evidence"
	self.hold_analyze_evidence.action_text_id = "hud_action_analyzing_evidence"
	self.hold_analyze_evidence.start_active = false
	self.hold_analyze_evidence.axis = "z"
	self.hold_analyze_evidence.timer = 1
	self.take_bridge = {}
	self.take_bridge.text_id = "hud_int_take_bridge"
	self.take_bridge.action_text_id = "hud_action_take_bridge"
	self.take_bridge.special_equipment_block = "bridge"
	self.take_bridge.timer = 1
	self.take_bridge.interact_distance = 200
	self.take_bridge.start_active = false
	self.use_bridge = {}
	self.use_bridge.text_id = "hud_int_use_bridge"
	self.use_bridge.action_text_id = "hud_action_use_bridge"
	self.use_bridge.equipment_text_id = "hud_equipment_use_bridge"
	self.use_bridge.equipment_consume = true
	self.use_bridge.timer = 2
	self.use_bridge.special_equipment = "bridge"
	self.use_bridge.interact_distance = 500
	self.use_bridge.start_active = false
	self.hold_close_keycard = {}
	self.hold_close_keycard.text_id = "hud_int_invisible_interaction_close"
	self.hold_close_keycard.action_text_id = "hud_action_open_slash_close"
	self.hold_close_keycard.equipment_text_id = "hud_int_equipment_no_keycard"
	self.hold_close_keycard.special_equipment = "bank_manager_key"
	self.hold_close_keycard.equipment_consume = true
	self.hold_close_keycard.start_active = true
	self.hold_close_keycard.axis = "y"
	self.hold_close_keycard.timer = 0.5
	self.hold_close = {}
	self.hold_close.text_id = "hud_int_invisible_interaction_close"
	self.hold_close.action_text_id = "hud_action_open_slash_close"
	self.hold_close.start_active = false
	self.hold_close.axis = "y"
	self.hold_close.timer = 0.5
	self.hold_open = {}
	self.hold_open.text_id = "hud_int_invisible_interaction_open"
	self.hold_open.action_text_id = "hud_action_open_slash_close"
	self.hold_open.start_active = false
	self.hold_open.axis = "y"
	self.hold_open.timer = 0.5
	self.hold_move_car = {}
	self.hold_move_car.text_id = "hud_int_hold_move_car"
	self.hold_move_car.action_text_id = "hud_action_moving_car"
	self.hold_move_car.start_active = false
	self.hold_move_car.timer = 3
	self.hold_move_car.interact_distance = 150
	self.hold_move_car.axis = "y"
	self.hold_move_car.sound_start = "bar_cop_car"
	self.hold_move_car.sound_interupt = "bar_cop_car_cancel"
	self.hold_move_car.sound_done = "bar_cop_car_finished"
	self.hold_remove_armor_plating = {}
	self.hold_remove_armor_plating.text_id = "hud_int_hold_remove_armor_plating"
	self.hold_remove_armor_plating.action_text_id = "hud_action_removing_armor_plating"
	self.hold_remove_armor_plating.timer = 5
	self.hold_remove_armor_plating.sound_start = "bar_steal_circuit"
	self.hold_remove_armor_plating.sound_interupt = "bar_steal_circuit_cancel"
	self.hold_remove_armor_plating.sound_done = "bar_steal_circuit_finished"
	self.gen_pku_cocaine_pure = deep_clone(self.gen_pku_cocaine)
	self.gen_pku_cocaine_pure.text_id = "hud_int_hold_take_pure_cocaine"
	self.gen_pku_cocaine_pure.action_text_id = "hud_action_taking_pure_cocaine"
	self.gen_pku_sandwich = {}
	self.gen_pku_sandwich.text_id = "hud_int_hold_take_sandwich"
	self.gen_pku_sandwich.action_text_id = "hud_action_taking_sandwich"
	self.gen_pku_sandwich.timer = 3
	self.gen_pku_sandwich.sound_start = "bar_bag_money"
	self.gen_pku_sandwich.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_sandwich.sound_done = "bar_bag_money_finished"
	self.gen_pku_sandwich.blocked_hint = "carry_block"
	self.place_flare = {}
	self.place_flare.text_id = "hud_int_place_flare"
	self.place_flare.start_active = false
	self.ignite_flare = {}
	self.ignite_flare.text_id = "hud_int_ignite_flare"
	self.ignite_flare.start_active = false
	self.hold_open_xmas_present = {}
	self.hold_open_xmas_present.text_id = "hud_int_hold_open_xmas_present"
	self.hold_open_xmas_present.action_text_id = "hud_action_opening_xmas_present"
	self.hold_open_xmas_present.start_active = false
	self.hold_open_xmas_present.timer = 1.5
	self.hold_open_xmas_present.sound_start = "bar_gift_box_open"
	self.hold_open_xmas_present.sound_interupt = "bar_gift_box_open_cancel"
	self.hold_open_xmas_present.sound_done = "bar_gift_box_open_finished"
	self.c4_bag_dynamic = deep_clone(self.c4_bag)
	self.c4_bag_dynamic.force_update_position = true
	self.shape_charge_plantable_c4_1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_1.special_equipment = "c4_1"
	self.shape_charge_plantable_c4_x1 = deep_clone(self.shape_charge_plantable)
	self.shape_charge_plantable_c4_x1.special_equipment = "c4_x1"
	self.shape_charge_plantable_c4_x1.interact_distance = 500
	self.hold_call_captain = {}
	self.hold_call_captain.text_id = "hud_int_hold_call_captain"
	self.hold_call_captain.action_text_id = "hud_action_calling_captain"
	self.hold_call_captain.start_active = false
	self.hold_call_captain.timer = 1
	self.hold_call_captain.interact_distance = 75
	self.hold_pku_disassemble_cro_loot = {}
	self.hold_pku_disassemble_cro_loot.text_id = "hud_int_hold_disassemble_cro_loot"
	self.hold_pku_disassemble_cro_loot.action_text_id = "hud_action_disassemble_cro_loot"
	self.hold_pku_disassemble_cro_loot.blocked_hint = "carry_block"
	self.hold_pku_disassemble_cro_loot.start_active = false
	self.hold_pku_disassemble_cro_loot.timer = 2
	self.hold_pku_disassemble_cro_loot.axis = "x"
	self.hold_remove_ladder = {}
	self.hold_remove_ladder.text_id = "hud_int_hold_remove_ladder"
	self.hold_remove_ladder.action_text_id = "hud_action_remove_ladder"
	self.hold_remove_ladder.start_active = false
	self.hold_remove_ladder.timer = 2
	self.hold_remove_ladder.sound_done = ""
	self.hold_remove_ladder.interact_distance = 150
	self.connect_hose = {}
	self.connect_hose.icon = "develop"
	self.connect_hose.text_id = "hud_int_hold_connect_hose"
	self.connect_hose.action_text_id = "hud_action_connect_hose"
	self.connect_hose.start_active = false
	self.connect_hose.timer = 4
	self.connect_hose.interact_distance = 200
	self.connect_hose.sound_start = "bar_hose_ground_connect"
	self.connect_hose.sound_interupt = "bar_hose_ground_connect_cancel"
	self.connect_hose.sound_done = "bar_hose_ground_connect_finished"
	self.generator_start = {}
	self.generator_start.text_id = "hud_generator_start"
	self.generator_start.action_text_id = "hud_action_generator_start"
	self.generator_start.start_active = false
	self.generator_start.interact_distance = 300
	self.hold_open_bomb_case = {}
	self.hold_open_bomb_case.text_id = "hud_int_hold_open_case"
	self.hold_open_bomb_case.action_text_id = "hud_action_int_hold_open_case"
	self.hold_open_bomb_case.start_active = false
	self.hold_open_bomb_case.timer = 2
	self.hold_open_bomb_case.interact_distance = 120
	self.hold_open_bomb_case.axis = "x"
	self.press_c4_pku = {}
	self.press_c4_pku.text_id = "hud_int_take_c4"
	self.press_c4_pku.contour = "interactable"
	self.press_c4_pku.start_active = false
	self.press_c4_pku.interact_distance = 150
	self.open_train_cargo_door = {}
	self.open_train_cargo_door.text_id = "hud_int_open_cargo_door"
	self.open_train_cargo_door.start_active = false
	self.open_train_cargo_door.interact_distance = 150
	self.open_train_cargo_door.timer = 0.5
	self.close_train_cargo_door = {}
	self.close_train_cargo_door.text_id = "hud_int_close_cargo_door"
	self.close_train_cargo_door.start_active = false
	self.close_train_cargo_door.interact_distance = 150
	self.close_train_cargo_door.timer = 0.5
	self.take_chainsaw = {}
	self.take_chainsaw.text_id = "hud_int_take_chainsaw"
	self.take_chainsaw.icon = "equipment_chainsaw"
	self.take_chainsaw.special_equipment_block = "chainsaw"
	self.use_chainsaw = {}
	self.use_chainsaw.text_id = "hud_int_hold_cut_tree"
	self.use_chainsaw.action_text_id = "hud_action_cutting_tree"
	self.use_chainsaw.equipment_text_id = "hint_no_chainsaw"
	self.use_chainsaw.special_equipment = "chainsaw"
	self.use_chainsaw.equipment_consume = false
	self.use_chainsaw.timer = 2
	self.use_chainsaw.sound_start = "bar_chainsaw"
	self.use_chainsaw.sound_interupt = "bar_chainsaw_cancel"
	self.use_chainsaw.sound_done = "bar_chainsaw_finished"
	self.hack_ship_control = {}
	self.hack_ship_control.icon = "interaction_keyboard"
	self.hack_ship_control.text_id = "hud_hack_ship_control"
	self.hack_ship_control.action_text_id = "hud_hacking_ship_control"
	self.hack_ship_control.timer = 6
	self.hack_ship_control.axis = "z"
	self.hack_ship_control.start_active = false
	self.hack_ship_control.interact_distance = 150
	self.hack_ship_control.sound_start = "bar_keyboard"
	self.hack_ship_control.sound_interupt = "bar_keyboard_cancel"
	self.hack_ship_control.sound_done = "bar_keyboard_finished"
	self.move_ship_gps_coords = {}
	self.move_ship_gps_coords.icon = "interaction_keyboard"
	self.move_ship_gps_coords.text_id = "hud_move_ship_gps_coords"
	self.move_ship_gps_coords.action_text_id = "hud_moving_ship_gps_coords"
	self.move_ship_gps_coords.timer = 6
	self.move_ship_gps_coords.axis = "z"
	self.move_ship_gps_coords.start_active = false
	self.move_ship_gps_coords.interact_distance = 150
	self.move_ship_gps_coords.sound_start = "bar_keyboard"
	self.move_ship_gps_coords.sound_interupt = "bar_keyboard_cancel"
	self.move_ship_gps_coords.sound_done = "bar_keyboard_finished"
	self.pku_manifest = {}
	self.pku_manifest.text_id = "hud_pku_manifest"
	self.pku_manifest.icon = "equipment_manifest"
	self.pku_manifest.special_equipment_block = "manifest"
	self.pku_manifest.start_active = false
	self.pku_manifest.interact_distance = 150
	self.pku_manifest.equipment_consume = false
	self.c4_x1_bag = {}
	self.c4_x1_bag.text_id = "debug_interact_c4_bag"
	self.c4_x1_bag.timer = 4
	self.c4_x1_bag.contour = "interactable"
	self.cut_glass = {}
	self.cut_glass.text_id = "hud_int_cut_glass"
	self.cut_glass.action_text_id = "hud_action_cut_glass"
	self.cut_glass.timer = 4
	self.cut_glass.contour = "interactable_icon"
	self.cut_glass.axis = "y"
	self.cut_glass.equipment_text_id = "hud_equipment_need_glass_cutter"
	self.cut_glass.special_equipment = "mus_glas_cutter"
	self.cut_glass.sound_start = "bar_glasscutter"
	self.cut_glass.sound_interupt = "bar_glasscutter_cancel"
	self.cut_glass.sound_done = "bar_glasscutter_finished"
	self.mus_hold_open_display = {}
	self.mus_hold_open_display.text_id = "hud_int_hold_open_display"
	self.mus_hold_open_display.action_text_id = "hud_action_open_display"
	self.mus_hold_open_display.timer = 1
	self.mus_take_diamond = {}
	self.mus_take_diamond.text_id = "debug_interact_diamond"
	self.rewire_electric_box = {}
	self.rewire_electric_box.text_id = "hud_int_rewire_box"
	self.rewire_electric_box.action_text_id = "hud_action_rewire_box"
	self.rewire_electric_box.timer = 6
	self.rewire_electric_box.start_active = false
	self.rewire_electric_box.axis = "y"
	self.rewire_electric_box.sound_start = "bar_hack_fuse_box"
	self.rewire_electric_box.sound_interupt = "bar_hack_fuse_box_cancel"
	self.rewire_electric_box.sound_done = "bar_hack_fuse_box_finished"
	self.timelock_hack = {}
	self.timelock_hack.text_id = "hud_int_hack_timelock"
	self.timelock_hack.action_text_id = "hud_action_hack_timelock"
	self.timelock_hack.timer = 6
	self.timelock_hack.start_active = false
	self.timelock_hack.axis = "y"
	self.timelock_hack.sound_start = "bar_hack_fuse_box"
	self.timelock_hack.sound_interupt = "bar_hack_fuse_box_cancel"
	self.timelock_hack.sound_done = "bar_hack_fuse_box_finished"
	self.hold_unlock_car = {}
	self.hold_unlock_car.text_id = "hud_int_hold_unlock_car"
	self.hold_unlock_car.action_text_id = "hud_unlocking_car"
	self.hold_unlock_car.timer = 1
	self.hold_unlock_car.equipment_text_id = "hud_equipment_need_car_keys"
	self.hold_unlock_car.special_equipment = "c_keys"
	self.hold_unlock_car.equipment_consume = true
	self.gen_pku_evidence_bag = {}
	self.gen_pku_evidence_bag.text_id = "hud_int_hold_take_evidence"
	self.gen_pku_evidence_bag.action_text_id = "hud_action_taking_evidence_bag"
	self.gen_pku_evidence_bag.timer = 3
	self.gen_pku_evidence_bag.axis = "y"
	self.gen_pku_evidence_bag.sound_start = "bar_bag_money"
	self.gen_pku_evidence_bag.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_evidence_bag.sound_done = "bar_bag_money_finished"
	self.gen_pku_evidence_bag.blocked_hint = "carry_block"
	self.mcm_fbi_case = {}
	self.mcm_fbi_case.text_id = "hud_int_hold_open_case"
	self.mcm_fbi_case.action_text_id = "hud_action_opening_case"
	self.mcm_fbi_case.timer = 3
	self.mcm_fbi_taperecorder = {}
	self.mcm_fbi_taperecorder.text_id = "hud_int_play_tape"
	self.mcm_fbi_taperecorder.action_text_id = "hud_action_play_tape"
	self.mcm_fbi_taperecorder.timer = 1
	self.mcm_laptop = {}
	self.mcm_laptop.text_id = "hud_int_hack_laptop"
	self.mcm_laptop.action_text_id = "hud_action_hack_laptop"
	self.mcm_laptop.timer = 3
	self.mcm_laptop.sound_start = "bar_keyboard"
	self.mcm_laptop.sound_interupt = "bar_keyboard_cancel"
	self.mcm_laptop.sound_done = "bar_keyboard_finished"
	self.mcm_laptop_code = {}
	self.mcm_laptop_code.text_id = "hud_int_grab_code"
	self.mcm_laptop_code.action_text_id = "hud_action_grab_code"
	self.mcm_laptop_code.timer = 2
	self.mcm_laptop_code.sound_start = "bar_keyboard"
	self.mcm_laptop_code.sound_interupt = "bar_keyboard_cancel"
	self.mcm_laptop_code.sound_done = "bar_keyboard_finished"
	self.mcm_break_planks = {}
	self.mcm_break_planks.text_id = "hud_int_break_planks"
	self.mcm_break_planks.action_text_id = "hud_action_break_planks"
	self.mcm_break_planks.timer = 4
	self.mcm_break_planks.sound_start = "bar_wood_fence_break"
	self.mcm_break_planks.sound_interupt = "bar_wood_fence_cancel"
	self.mcm_break_planks.sound_done = "bar_wood_fence_finnished"
	self.mcm_panicroom_keycard = {}
	self.mcm_panicroom_keycard.text_id = "hud_int_open_panicroom"
	self.mcm_panicroom_keycard.action_text_id = "hud_action_open_panicroom"
	self.mcm_panicroom_keycard.equipment_text_id = "hud_int_equipment_no_keycard"
	self.mcm_panicroom_keycard.special_equipment = "bank_manager_key"
	self.mcm_panicroom_keycard.equipment_consume = true
	self.mcm_panicroom_keycard.start_active = true
	self.mcm_panicroom_keycard.axis = "y"
	self.mcm_panicroom_keycard.timer = 0.5
	self.mcm_panicroom_keycard_2 = {}
	self.mcm_panicroom_keycard_2.text_id = "hud_int_equipment_keycard"
	self.mcm_panicroom_keycard_2.equipment_text_id = "hud_int_equipment_no_keycard"
	self.mcm_panicroom_keycard_2.special_equipment = "bank_manager_key"
	self.mcm_panicroom_keycard_2.equipment_consume = true
	self.mcm_panicroom_keycard_2.start_active = true
	self.mcm_panicroom_keycard_2.axis = "y"
	self.gen_prop_container_a_vault_seq = {}
	self.gen_prop_container_a_vault_seq.text_id = "hud_int_hold_jam_vent"
	self.gen_prop_container_a_vault_seq.action_text_id = "hud_action_jamming_vent"
	self.gen_prop_container_a_vault_seq.equipment_text_id = "hud_interact_equipment_crowbar"
	self.gen_prop_container_a_vault_seq.special_equipment = "crowbar"
	self.gen_prop_container_a_vault_seq.timer = 1
	self.gen_prop_container_a_vault_seq.start_active = false
	self.gen_prop_container_a_vault_seq.equipment_consume = true
	self.gen_prop_container_a_vault_seq.sound_start = "bar_fan_jam"
	self.gen_prop_container_a_vault_seq.sound_interupt = "bar_fan_jam_cancel"
	self.gen_prop_container_a_vault_seq.sound_done = "bar_fan_jam_finished"
	self.gen_pku_warhead = {}
	self.gen_pku_warhead.text_id = "hud_int_hold_take_warhead"
	self.gen_pku_warhead.action_text_id = "hud_action_taking_warhead"
	self.gen_pku_warhead.timer = 3
	self.gen_pku_warhead.start_active = true
	self.gen_pku_warhead.sound_start = "bar_bag_money"
	self.gen_pku_warhead.sound_interupt = "bar_bag_money_cancel"
	self.gen_pku_warhead.sound_done = "bar_bag_money_finished"
	self.gen_pku_warhead.blocked_hint = "carry_block"
	self.gen_pku_warhead_box = {}
	self.gen_pku_warhead_box.text_id = "hud_int_hold_open_case"
	self.gen_pku_warhead_box.action_text_id = "hud_action_opening_case"
	self.gen_pku_warhead_box.timer = 2
	self.gen_pku_warhead_box.start_active = false
	self.gen_pku_warhead_box.sound_start = "bar_open_warhead_box"
	self.gen_pku_warhead_box.sound_interupt = "bar_open_warhead_box_cancel"
	self.gen_pku_warhead_box.sound_done = "bar_open_warhead_box_finished"
	self.gen_pku_circle_cutter = {}
	self.gen_pku_circle_cutter.text_id = "hud_int_hold_take_circle_cutter"
	self.gen_pku_circle_cutter.action_text_id = "hud_action_taking_circle_cutter"
	self.gen_pku_circle_cutter.timer = 1
	self.gen_pku_circle_cutter.sound_done = "pick_up_crowbar"
	self.hold_circle_cutter = {}
	self.hold_circle_cutter.text_id = "debug_interact_glass_cutter"
	self.hold_circle_cutter.action_text_id = "hud_action_placing_cutter"
	self.hold_circle_cutter.timer = 3
	self.hold_circle_cutter.equipment_consume = true
	self.hold_circle_cutter.equipment_text_id = "hud_equipment_need_circle_cutter"
	self.hold_circle_cutter.special_equipment = "circle_cutter"
	self.hold_circle_cutter.sound_start = "bar_drill_apply"
	self.hold_circle_cutter.sound_interupt = "bar_drill_apply_cancel"
	self.hold_circle_cutter.sound_done = "bar_drill_apply_finished"
	self.circle_cutter_jammed = {}
	self.circle_cutter_jammed.text_id = "debug_interact_cutter_jammed"
	self.circle_cutter_jammed.timer = 10
	self.circle_cutter_jammed.sound_start = "bar_drill_fix"
	self.circle_cutter_jammed.sound_interupt = "bar_drill_fix_cancel"
	self.circle_cutter_jammed.sound_done = "bar_drill_fix_finished"
	self.answer_call = {}
	self.answer_call.text_id = "hud_int_hold_answer_call"
	self.answer_call.action_text_id = "hud_action_answering_call"
	self.answer_call.timer = 0.5
	self.answer_call.start_active = false
	self.hold_take_fire_extinguisher = {}
	self.hold_take_fire_extinguisher.text_id = "hud_int_hold_take_fire_extinguisher"
	self.hold_take_fire_extinguisher.action_text_id = "hud_action_taking_fire_extinguisher"
	self.hold_take_fire_extinguisher.timer = 1
	self.hold_take_fire_extinguisher.start_active = false
	self.hold_take_fire_extinguisher.special_equipment_block = "fire_extinguisher"
	self.hold_extinguish_fire = {}
	self.hold_extinguish_fire.text_id = "hud_int_hold_extinguish_fire"
	self.hold_extinguish_fire.action_text_id = "hud_action_extinguishing_fire"
	self.hold_extinguish_fire.timer = 3
	self.hold_extinguish_fire.axis = "y"
	self.hold_extinguish_fire.start_active = false
	self.hold_extinguish_fire.equipment_consume = true
	self.hold_extinguish_fire.equipment_text_id = "hud_equipment_need_fire_extinguisher"
	self.hold_extinguish_fire.special_equipment = "fire_extinguisher"
	self.hold_extinguish_fire.sound_start = "bar_fire_extinguisher"
	self.hold_extinguish_fire.sound_interupt = "bar_fire_extinguisher_cancel"
	self.hold_extinguish_fire.sound_done = "bar_fire_extinguisher_finished"
	self.are_laptop = {}
	self.are_laptop.text_id = "hud_int_hold_place_laptop"
	self.are_laptop.action_text_id = "hud_action_placeing_laptop"
	self.are_laptop.timer = 3
	self.are_laptop.sound_start = "bar_keyboard"
	self.are_laptop.sound_interupt = "bar_keyboard_cancel"
	self.are_laptop.sound_done = "bar_keyboard_finished"
	self.hold_search_c4 = {}
	self.hold_search_c4.text_id = "hud_int_hold_search_c4"
	self.hold_search_c4.action_text_id = "hud_action_searching_c4"
	self.hold_search_c4.start_active = false
	self.hold_search_c4.timer = 3
	self.hold_search_c4.sound_start = "bar_gift_box_open"
	self.hold_search_c4.sound_interupt = "bar_gift_box_open_cancel"
	self.hold_search_c4.sound_done = "bar_gift_box_open_finished"
	self.c4_x10 = deep_clone(self.c4_mission_door)
	self.c4_x10.special_equipment = "c4_x10"
	self.c4_x10.axis = "z"
	self.pick_lock_hard_no_skill_deactivated = deep_clone(self.pick_lock_hard_no_skill)
	self.pick_lock_hard_no_skill_deactivated.start_active = false
	self.are_turn_on_tv = {}
	self.are_turn_on_tv.text_id = "hud_int_are_turn_on_tv"
	self.are_turn_on_tv.start_active = false
	self.are_turn_on_tv.interact_distance = 100
	self.are_turn_on_tv.axis = "y"
	self.money_wrap_updating = deep_clone(self.money_wrap)
	self.money_wrap_updating.force_update_position = true
	self.panic_room_key = {}
	self.panic_room_key.icon = "equipment_chavez_key"
	self.panic_room_key.text_id = "debug_interact_chavez_key_key"
	self.panic_room_key.equipment_text_id = "debug_interact_equiptment_chavez_key"
	self.panic_room_key.special_equipment = "chavez_key"
	self.panic_room_key.equipment_consume = true
	self.panic_room_key.interact_distance = 150
	self.hack_skylight_barrier = {}
	self.hack_skylight_barrier.text_id = "hud_hack_skylight_barrier"
	self.hack_skylight_barrier.action_text_id = "hud_action_hack_skylight_barrier"
	self.hack_skylight_barrier.timer = 6
	self.hack_skylight_barrier.start_active = false
	self.hack_skylight_barrier.axis = "y"
	self.hack_skylight_barrier.sound_start = "bar_hack_fuse_box"
	self.hack_skylight_barrier.sound_interupt = "bar_hack_fuse_box_cancel"
	self.hack_skylight_barrier.sound_done = "bar_hack_fuse_box_finished"
	self.take_bottle = {}
	self.take_bottle.text_id = "hud_int_take_bottle"
	self.take_bottle.action_text_id = "hud_action_take_bottle"
	self.take_bottle.icon = "equipment_bottle"
	self.take_bottle.special_equipment_block = "bottle"
	self.take_bottle.timer = 3
	self.pour_spiked_drink = {}
	self.pour_spiked_drink.text_id = "hud_int_pour_drink"
	self.pour_spiked_drink.equipment_text_id = "hint_no_bottle"
	self.pour_spiked_drink.special_equipment = "bottle"
	self.pour_spiked_drink.equipment_consume = true
	self.computer_blueprints = {}
	self.computer_blueprints.text_id = "hud_int_search_blueprints"
	self.computer_blueprints.action_text_id = "hud_action_searching_blueprints"
	self.computer_blueprints.timer = 4.5
	self.computer_blueprints.axis = "x"
	self.computer_blueprints.contour = "interactable_icon"
	self.computer_blueprints.interact_distance = 200
	self.computer_blueprints.sound_start = "bar_shuffle_papers"
	self.computer_blueprints.sound_interupt = "bar_shuffle_papers_cancel"
	self.computer_blueprints.sound_done = "bar_shuffle_papers_finished"
	self.computer_blueprints.icon = "equipment_files"
	self.computer_blueprints.special_equipment_block = "blueprints"
	self.use_blueprints = {}
	self.use_blueprints.text_id = "hud_int_hold_scan_blueprints"
	self.use_blueprints.action_text_id = "hud_action_scanning_blueprints"
	self.use_blueprints.equipment_text_id = "hint_no_blueprints"
	self.use_blueprints.special_equipment = "blueprints"
	self.use_blueprints.equipment_consume = true
	self.use_blueprints.timer = 5
	self.use_blueprints.sound_start = "bar_scan_documents"
	self.use_blueprints.sound_interupt = "bar_scan_documents_cancel"
	self.use_blueprints.sound_done = "bar_scan_documents_finished"
	self.send_blueprints = {}
	self.send_blueprints.text_id = "hud_int_send_blueprints"
	self.cas_customer_database = {}
	self.cas_customer_database.text_id = "hud_check_customer_database"
	self.cas_customer_database.action_text_id = "hud_action_cas_checking_customer_database"
	self.cas_customer_database.timer = 6
	self.cas_customer_database.axis = "z"
	self.cas_customer_database.start_active = false
	self.cas_customer_database.interact_distance = 150
	self.cas_customer_database.sound_start = "bar_keyboard"
	self.cas_customer_database.sound_interupt = "bar_keyboard_cancel"
	self.cas_customer_database.sound_done = "bar_keyboard_finished"
	self.disable_lasers = {}
	self.disable_lasers.text_id = "hud_disable_lasers"
	self.disable_lasers.action_text_id = "hud_action_disabling_lasers"
	self.disable_lasers.timer = 6
	self.disable_lasers.axis = "z"
	self.disable_lasers.start_active = false
	self.disable_lasers.interact_distance = 150
	self.disable_lasers.sound_start = "bar_keyboard"
	self.disable_lasers.sound_interupt = "bar_keyboard_cancel"
	self.disable_lasers.sound_done = "bar_keyboard_finished"
	self.pickup_hotel_room_keycard = {}
	self.pickup_hotel_room_keycard.text_id = "hud_int_take_hotel_keycard"
	self.pickup_hotel_room_keycard.special_equipment_block = "hotel_room_key"
	self.pickup_hotel_room_keycard.start_active = true
	self.use_hotel_room_key = {}
	self.use_hotel_room_key.text_id = "hud_insert_hotel_room_key"
	self.use_hotel_room_key.equipment_text_id = "hint_no_hotel_room_key"
	self.use_hotel_room_key.special_equipment = "hotel_room_key"
	self.use_hotel_room_key.equipment_consume = true
	self.use_hotel_room_key.interact_distance = 150
	self.use_hotel_room_key_no_access = {}
	self.use_hotel_room_key_no_access.text_id = "hud_insert_hotel_room_key"
	self.use_hotel_room_key_no_access.equipment_text_id = "hint_no_hotel_room_key"
	self.use_hotel_room_key_no_access.special_equipment = "hotel_room_key"
	self.use_hotel_room_key_no_access.equipment_consume = false
	self.use_hotel_room_key_no_access.interact_distance = 150
	self.lift_choose_floor = {}
	self.lift_choose_floor.text_id = "hud_int_lift_choose_floor"
	self.lift_choose_floor.action_text_id = "hud_action_lift_choose_floor"
	self.lift_choose_floor.start_active = false
	self.lift_choose_floor.interact_distance = 200
	self.cas_open_briefcase = {}
	self.cas_open_briefcase.text_id = "hud_open_cas_briefcase"
	self.cas_open_briefcase.action_text_id = "hud_opening_cas_briefcase"
	self.cas_open_briefcase.timer = 2
	self.cas_open_briefcase.start_active = false
	self.cas_open_briefcase.interact_distance = 150
	self.cas_open_securityroom_door = {}
	self.cas_open_securityroom_door.text_id = "hud_open_cas_securityroom_door"
	self.cas_open_securityroom_door.action_text_id = "hud_opening_cas_securityroom_door"
	self.cas_open_securityroom_door.timer = 1
	self.cas_open_securityroom_door.interact_distance = 80
	self.cas_open_securityroom_door.axis = "x"
	self.cas_elevator_door_open = {}
	self.cas_elevator_door_open.text_id = "hud_open_cas_elevator"
	self.cas_elevator_door_open.start_active = true
	self.cas_elevator_door_open.interact_distance = 100
	self.cas_elevator_door_close = {}
	self.cas_elevator_door_close.text_id = "hud_close_cas_elevator"
	self.cas_elevator_door_close.start_active = false
	self.cas_elevator_door_close.interact_distance = 100
	self.lockpick_locker = {}
	self.lockpick_locker.contour = "interactable_icon"
	self.lockpick_locker.icon = "equipment_bank_manager_key"
	self.lockpick_locker.text_id = "hud_int_pick_lock"
	self.lockpick_locker.start_active = true
	self.lockpick_locker.timer = 2
	self.lockpick_locker.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.lockpick_locker.action_text_id = "hud_action_picking_lock"
	self.lockpick_locker.interact_distance = 100
	self.lockpick_locker.sound_start = "bar_pick_lock"
	self.lockpick_locker.sound_interupt = "bar_pick_lock_cancel"
	self.lockpick_locker.sound_done = "bar_pick_lock_finished"
	self.lockpick_box = {}
	self.lockpick_box.contour = "interactable_icon"
	self.lockpick_box.text_id = "hud_int_pick_lock"
	self.lockpick_box.start_active = true
	self.lockpick_box.timer = 2
	self.lockpick_box.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.lockpick_box.action_text_id = "hud_action_picking_lock"
	self.lockpick_box.interact_distance = 100
	self.lockpick_box.sound_start = "bar_pick_lock"
	self.lockpick_box.sound_interupt = "bar_pick_lock_cancel"
	self.lockpick_box.sound_done = "bar_pick_lock_finished"
	self.cas_copy_usb = {}
	self.cas_copy_usb.text_id = "hud_int_copy_data_usb"
	self.cas_copy_usb.equipment_text_id = "hint_no_usb_key"
	self.cas_copy_usb.interact_distance = 100
	self.cas_copy_usb.special_equipment = "cas_usb_key"
	self.cas_copy_usb.start_active = false
	self.cas_copy_usb.equipment_consume = true
	self.cas_use_usb = {}
	self.cas_use_usb.text_id = "hud_insert_usb"
	self.cas_use_usb.equipment_text_id = "hint_no_data_usb_key"
	self.cas_use_usb.special_equipment = "cas_data_usb_key"
	self.cas_use_usb.equipment_consume = true
	self.cas_use_usb.interact_distance = 150
	self.cas_take_usb_key = {}
	self.cas_take_usb_key.text_id = "hud_take_usb_key"
	self.cas_take_usb_key.interact_distance = 200
	self.cas_take_usb_key.special_equipment_block = "cas_usb_key"
	self.cas_take_usb_key.start_active = false
	self.cas_take_usb_key_data = {}
	self.cas_take_usb_key_data.text_id = "hud_take_usb_key_data"
	self.cas_take_usb_key_data.interact_distance = 200
	self.cas_take_usb_key_data.special_equipment_block = "cas_data_usb_key"
	self.cas_take_usb_key_data.start_active = false
	self.cas_screw_down = {}
	self.cas_screw_down.text_id = "hud_screw_down"
	self.cas_screw_down.action_text_id = "hud_action_screwing_down"
	self.cas_screw_down.interact_distance = 150
	self.cas_screw_down.timer = 2
	self.cas_screw_down.start_active = false
	self.cas_screw_down.sound_start = "bar_secure_winch"
	self.cas_screw_down.sound_interupt = "bar_secure_winch_cancel"
	self.cas_screw_down.sound_done = "bar_secure_winch_finished"
	self.cas_start_winch = {}
	self.cas_start_winch.text_id = "hud_start_winch"
	self.cas_start_winch.action_text_id = "hud_action_starting_winch"
	self.cas_start_winch.interact_distance = 200
	self.cas_start_winch.timer = 2
	self.cas_start_winch.start_active = false
	self.cas_take_hook = {}
	self.cas_take_hook.text_id = "hud_take_hook"
	self.cas_take_hook.action_text_id = "hud_action_taking_hook"
	self.cas_take_hook.interact_distance = 100
	self.cas_take_hook.timer = 2
	self.cas_take_hook.start_active = false
	self.cas_start_drill = {}
	self.cas_start_drill.text_id = "hud_start_drill"
	self.cas_start_drill.action_text_id = "hud_action_starting_drill"
	self.cas_start_drill.interact_distance = 100
	self.cas_start_drill.timer = 2
	self.cas_start_drill.start_active = false
	self.cas_stop_drill = {}
	self.cas_stop_drill.text_id = "hud_stop_drill"
	self.cas_stop_drill.action_text_id = "hud_action_stoping_drill"
	self.cas_stop_drill.interact_distance = 100
	self.cas_stop_drill.timer = 2
	self.cas_stop_drill.start_active = false
	self.cas_take_empty_watertank = {}
	self.cas_take_empty_watertank.text_id = "hud_take_watertank"
	self.cas_take_empty_watertank.action_text_id = "hud_action_taking_watertank"
	self.cas_take_empty_watertank.timer = 2
	self.cas_take_empty_watertank.interact_distance = 100
	self.cas_take_empty_watertank.start_active = false
	self.cas_take_empty_watertank.sound_start = "bar_replace_empty_watertank"
	self.cas_take_empty_watertank.sound_interupt = "bar_replace_empty_watertank_cancel"
	self.cas_take_empty_watertank.sound_done = "bar_replace_empty_watertank_finished"
	self.cas_take_full_watertank = {}
	self.cas_take_full_watertank.text_id = "hud_take_watertank"
	self.cas_take_full_watertank.action_text_id = "hud_action_taking_watertank"
	self.cas_take_full_watertank.timer = 2
	self.cas_take_full_watertank.interact_distance = 150
	self.cas_take_full_watertank.start_active = false
	self.cas_take_full_watertank.sound_start = "bar_take_watertank"
	self.cas_take_full_watertank.sound_interupt = "bar_take_watertank_cancel"
	self.cas_take_full_watertank.sound_done = "bar_take_watertank_finished"
	self.cas_vent_gas = {}
	self.cas_vent_gas.text_id = "hud_place_sleeping_gass"
	self.cas_vent_gas.action_text_id = "hud_action_placing_sleeping_gass"
	self.cas_vent_gas.interact_distance = 150
	self.cas_vent_gas.timer = 2
	self.cas_vent_gas.equipment_text_id = "hint_no_sleeping_gas"
	self.cas_vent_gas.special_equipment = "cas_sleeping_gas"
	self.cas_vent_gas.start_active = false
	self.cas_vent_gas.equipment_consume = true
	self.cas_vent_gas.sound_start = "bar_sleeping_gas"
	self.cas_vent_gas.sound_interupt = "bar_sleeping_gas_cancel"
	self.cas_vent_gas.sound_done = "bar_sleeping_gas_finished"
	self.cas_vent_gas.axis = "x"
	self.cas_connect_power = {}
	self.cas_connect_power.text_id = "hud_connect_cable"
	self.cas_connect_power.action_text_id = "hud_action_connecting_cable"
	self.cas_connect_power.interact_distance = 100
	self.cas_connect_power.timer = 2
	self.cas_connect_power.start_active = false
	self.cas_take_sleeping_gas = {}
	self.cas_take_sleeping_gas.text_id = "hud_take_sleeping_gas"
	self.cas_take_sleeping_gas.action_text_id = "hud_action_taking_sleeping_gas"
	self.cas_take_sleeping_gas.timer = 2
	self.cas_take_sleeping_gas.interact_distance = 150
	self.cas_take_sleeping_gas.special_equipment_block = "cas_sleeping_gas"
	self.cas_take_sleeping_gas.start_active = false
	self.cas_chips_pile = {}
	self.cas_chips_pile.text_id = "hud_take_casino_chips"
	self.cas_chips_pile.start_active = false
	self.cas_chips_pile.interact_distance = 110
	self.cas_chips_pile.requires_mask_off_upgrade = {
		upgrade = "mask_off_pickup",
		category = "player"
	}
	self.cas_chips_pile.can_interact_in_civilian = true
	self.cas_connect_winch_hook = {}
	self.cas_connect_winch_hook.text_id = "hud_connect_which_hook"
	self.cas_connect_winch_hook.action_text_id = "hud_action_connecting_which_hook"
	self.cas_connect_winch_hook.equipment_text_id = "hint_no_winch_hook"
	self.cas_connect_winch_hook.special_equipment = "cas_winch_hook"
	self.cas_connect_winch_hook.start_active = false
	self.cas_connect_winch_hook.interact_distance = 200
	self.cas_connect_winch_hook.timer = 2
	self.cas_connect_winch_hook.equipment_consume = true
	self.cas_open_powerbox = {}
	self.cas_open_powerbox.text_id = "hud_cas_open_powerbox"
	self.cas_open_powerbox.action_text_id = "hud_action_cas_opening_powerbox"
	self.cas_open_powerbox.start_active = false
	self.cas_open_powerbox.interact_distance = 100
	self.cas_open_powerbox.timer = 2
	self.cas_take_fireworks_bag = {}
	self.cas_take_fireworks_bag.text_id = "hud_cas_take_fireworks_bag"
	self.cas_take_fireworks_bag.action_text_id = "hud_action_cas_taking_fireworks_bag"
	self.cas_take_fireworks_bag.blocked_hint = "carry_block"
	self.cas_take_fireworks_bag.start_active = false
	self.cas_take_fireworks_bag.timer = 2
	self.cas_ignite_fireworks = {}
	self.cas_ignite_fireworks.text_id = "hud_cas_ignite_fireworks"
	self.cas_ignite_fireworks.action_text_id = "hud_action_cas_igniting_fireworks"
	self.cas_ignite_fireworks.start_active = false
	self.cas_ignite_fireworks.interact_distance = 200
	self.cas_ignite_fireworks.timer = 2
	self.cas_ignite_fireworks.sound_start = "bar_light_fireworks"
	self.cas_ignite_fireworks.sound_interupt = "bar_light_fireworks_cancel"
	self.cas_ignite_fireworks.sound_done = "bar_light_fireworks_finished"
	self.cas_open_compartment = {}
	self.cas_open_compartment.text_id = "hud_cas_open_compartment"
	self.cas_open_compartment.start_active = false
	self.cas_open_compartment.interact_distance = 150
	self.cas_bfd_drill_toolbox = {}
	self.cas_bfd_drill_toolbox.text_id = "hud_take_bfd_tool"
	self.cas_bfd_drill_toolbox.interact_distance = 200
	self.cas_bfd_drill_toolbox.special_equipment_block = "cas_bfd_tool"
	self.cas_bfd_drill_toolbox.start_active = false
	self.cas_fix_bfd_drill = {}
	self.cas_fix_bfd_drill.text_id = "hud_fix_bfd_drill"
	self.cas_fix_bfd_drill.action_text_id = "hud_action_fixing_bfd_drill"
	self.cas_fix_bfd_drill.interact_distance = 150
	self.cas_fix_bfd_drill.timer = 10
	self.cas_fix_bfd_drill.equipment_text_id = "hint_no_bfd_tool"
	self.cas_fix_bfd_drill.special_equipment = "cas_bfd_tool"
	self.cas_fix_bfd_drill.start_active = false
	self.cas_fix_bfd_drill.equipment_consume = true
	self.cas_fix_bfd_drill.sound_start = "bar_huge_lance_fix"
	self.cas_fix_bfd_drill.sound_interupt = "bar_huge_lance_fix_cancel"
	self.cas_fix_bfd_drill.sound_done = "bar_huge_lance_fix_finished"
	self.cas_elevator_key = {}
	self.cas_elevator_key.text_id = "hud_take_elevator_key"
	self.cas_elevator_key.interact_distance = 200
	self.cas_elevator_key.special_equipment_block = "cas_elevator_key"
	self.cas_elevator_key.start_active = false
	self.cas_use_elevator_key = {}
	self.cas_use_elevator_key.text_id = "hud_use_elevator_key"
	self.cas_use_elevator_key.interact_distance = 150
	self.cas_use_elevator_key.equipment_text_id = "hint_no_elevator_key"
	self.cas_use_elevator_key.special_equipment = "cas_elevator_key"
	self.cas_use_elevator_key.start_active = false
	self.cas_use_elevator_key.equipment_consume = false
	self.cas_open_door = {}
	self.cas_open_door.text_id = "hud_cas_open_door"
	self.cas_open_door.start_active = true
	self.cas_open_door.interact_distance = 150
	self.cas_open_door.can_interact_in_civilian = true
	self.cas_close_door = {}
	self.cas_close_door.text_id = "hud_cas_close_door"
	self.cas_close_door.start_active = false
	self.cas_close_door.interact_distance = 150
	self.cas_close_door.can_interact_in_civilian = true
	self.cas_slot_machine = {}
	self.cas_slot_machine.text_id = "hud_int_hold_play_slots"
	self.cas_slot_machine.action_text_id = "hud_action_playing_slots"
	self.cas_slot_machine.interact_distance = 100
	self.cas_slot_machine.timer = 2
	self.cas_slot_machine.start_active = false
	self.cas_slot_machine.can_interact_in_civilian = true
	self.cas_slot_machine.sound_done = "bar_slot_machine_pull_lever_finished"
	self.cas_slot_machine.sound_interupt = "bar_slot_machine_pull_lever_cancel"
	self.cas_slot_machine.sound_start = "bar_slot_machine_pull_lever"
	self.cas_button_01 = {}
	self.cas_button_01.text_id = "hud_int_press_01"
	self.cas_button_01.start_active = false
	self.cas_button_01.interact_distance = 50
	self.cas_button_02 = {}
	self.cas_button_02.text_id = "hud_int_press_02"
	self.cas_button_02.start_active = false
	self.cas_button_02.interact_distance = 50
	self.cas_button_03 = {}
	self.cas_button_03.text_id = "hud_int_press_03"
	self.cas_button_03.start_active = false
	self.cas_button_03.interact_distance = 50
	self.cas_button_04 = {}
	self.cas_button_04.text_id = "hud_int_press_04"
	self.cas_button_04.start_active = false
	self.cas_button_04.interact_distance = 50
	self.cas_button_05 = {}
	self.cas_button_05.text_id = "hud_int_press_05"
	self.cas_button_05.start_active = false
	self.cas_button_05.interact_distance = 50
	self.cas_button_06 = {}
	self.cas_button_06.text_id = "hud_int_press_06"
	self.cas_button_06.start_active = false
	self.cas_button_06.interact_distance = 50
	self.cas_button_07 = {}
	self.cas_button_07.text_id = "hud_int_press_07"
	self.cas_button_07.start_active = false
	self.cas_button_07.interact_distance = 50
	self.cas_button_08 = {}
	self.cas_button_08.text_id = "hud_int_press_08"
	self.cas_button_08.start_active = false
	self.cas_button_08.interact_distance = 50
	self.cas_button_09 = {}
	self.cas_button_09.text_id = "hud_int_press_09"
	self.cas_button_09.start_active = false
	self.cas_button_09.interact_distance = 50
	self.cas_button_0 = {}
	self.cas_button_0.text_id = "hud_int_press_0"
	self.cas_button_0.start_active = false
	self.cas_button_0.interact_distance = 50
	self.cas_button_clear = {}
	self.cas_button_clear.text_id = "hud_int_press_clear"
	self.cas_button_clear.start_active = false
	self.cas_button_clear.interact_distance = 50
	self.cas_button_enter = {}
	self.cas_button_enter.text_id = "hud_int_press_enter"
	self.cas_button_enter.start_active = false
	self.cas_button_enter.interact_distance = 50
	self.cas_skylight_panel = {}
	self.cas_skylight_panel.text_id = "hud_hack_skylight_panel"
	self.cas_skylight_panel.start_active = false
	self.cas_skylight_panel.interact_distance = 50
	self.cas_take_unknown = {}
	self.cas_take_unknown.text_id = "hud_take_???"
	self.cas_take_unknown.action_text_id = "hud_action_taking_???"
	self.cas_take_unknown.timer = 2
	self.cas_take_unknown.interact_distance = 100
	self.cas_take_unknown.start_active = false
	self.cas_unpack_turret = {}
	self.cas_unpack_turret.text_id = "hud_unpack_turret"
	self.cas_unpack_turret.action_text_id = "hud_action_unpacking_turret"
	self.cas_unpack_turret.timer = 2
	self.cas_unpack_turret.interact_distance = 150
	self.cas_unpack_turret.start_active = false
	self.cas_open_guitar_case = {}
	self.cas_open_guitar_case.text_id = "hud_cas_open_guitar_case"
	self.cas_open_guitar_case.action_text_id = "hud_action_cas_opening_guitar_case"
	self.cas_open_guitar_case.timer = 3
	self.cas_open_guitar_case.interact_distance = 300
	self.cas_open_guitar_case.start_active = false
	self.cas_open_guitar_case.can_interact_only_in_civilian = true
	self.cas_take_gear = {}
	self.cas_take_gear.text_id = "hud_cas_take_gear"
	self.cas_take_gear.action_text_id = "hud_action_cas_taking_gear"
	self.cas_take_gear.contour = "deployable"
	self.cas_take_gear.timer = 3
	self.cas_take_gear.interact_distance = 300
	self.cas_take_gear.start_active = false
	self.cas_take_gear.can_interact_only_in_civilian = true
	self.cas_security_door = {}
	self.cas_security_door.text_id = "hud_cas_security_door"
	self.cas_security_door.action_text_id = "hud_action_cas_security_door"
	self.cas_security_door.timer = 10
	self.cas_security_door.interact_distance = 150
	self.cas_security_door.start_active = false
	self.cas_security_door.axis = "y"
	self.pick_lock_30 = {}
	self.pick_lock_30.contour = "interactable_icon"
	self.pick_lock_30.icon = "equipment_bank_manager_key"
	self.pick_lock_30.text_id = "hud_int_pick_lock"
	self.pick_lock_30.start_active = true
	self.pick_lock_30.timer = 30
	self.pick_lock_30.requires_upgrade = {
		upgrade = "pick_lock_hard",
		category = "player"
	}
	self.pick_lock_30.action_text_id = "hud_action_picking_lock"
	self.pick_lock_30.sound_start = "bar_pick_lock"
	self.pick_lock_30.sound_interupt = "bar_pick_lock_cancel"
	self.pick_lock_30.sound_done = "bar_pick_lock_finished"
	self.winning_slip = {}
	self.winning_slip.text_id = "hud_int_take_win_slip"
	self.winning_slip.start_active = false
	self.winning_slip.interact_distance = 110
	self.winning_slip.can_interact_in_civilian = true
	self.carry_drop_gold = {}
	self.carry_drop_gold.icon = "develop"
	self.carry_drop_gold.text_id = "hud_interact_gold_pile_take_money"
	self.carry_drop_gold.timer = 1
	self.carry_drop_gold.force_update_position = true
	self.carry_drop_gold.action_text_id = "hud_action_taking_gold"
	self.carry_drop_gold.blocked_hint = "hud_hint_carry_block_interact"
	self.carry_drop_gold.sound_start = "gold_crate_pickup"
	self.carry_drop_gold.sound_interupt = "gold_crate_drop"
	self.carry_drop_gold.sound_done = "gold_crate_drop"
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
	self.hold_pku_intelligence = {}
	self.hold_pku_intelligence.text_id = "hud_int_pickup_intelligence"
	self.hold_pku_intelligence.action_text_id = "hud_action_pickup_intelligence"
	self.hold_pku_intelligence.timer = 1
	self.hold_pku_intelligence.interact_distance = 150
	self.dynamite_x1_pku = {}
	self.dynamite_x1_pku.text_id = "hud_int_take_dynamite"
	self.dynamite_x1_pku.action_text_id = "hud_action_taking_dynamite"
	self.dynamite_x1_pku.timer = 0.5
	self.dynamite_x1_pku.interact_distance = 200
	self.dynamite_x1_pku.icon = "equipment_dynamite"
	self.dynamite_x1_pku.special_equipment_block = "dynamite"
	self.dynamite_x1_pku.sound_done = "pickup_dynamite"
	self.mine_pku = {}
	self.mine_pku.text_id = "hud_int_take_mine"
	self.mine_pku.action_text_id = "hud_action_taking_mine"
	self.mine_pku.special_equipment_block = "landmine"
	self.mine_pku.timer = 2
	self.mine_pku.start_active = true
	self.mine_pku.sound_start = "cvy_pick_up_mine"
	self.mine_pku.sound_interupt = "cvy_pick_up_mine_cancel_01"
	self.mine_pku.sound_done = "cvy_pick_up_mine_finish_01"
	self.dynamite_x4_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x4_pku.special_equipment_block = "dynamite_x4"
	self.dynamite_x5_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x5_pku.special_equipment_block = "dynamite_x5"
	self.plant_dynamite = {}
	self.plant_dynamite.text_id = "hud_plant_dynamite"
	self.plant_dynamite.action_text_id = "hud_action_planting_dynamite"
	self.plant_dynamite.interact_distance = 150
	self.plant_dynamite.timer = 2
	self.plant_dynamite.equipment_text_id = "hint_no_dynamite"
	self.plant_dynamite.special_equipment = "dynamite"
	self.plant_dynamite.upgrade_timer_multipliers = {
		{
			upgrade = "dynamite_plant_multiplier",
			category = "interaction"
		}
	}
	self.plant_dynamite.start_active = false
	self.plant_dynamite.equipment_consume = true
	self.plant_dynamite.axis = "z"
	self.plant_dynamite.sound_start = "dynamite_placing"
	self.plant_dynamite.sound_done = "dynamite_placed"
	self.plant_dynamite.sound_interupt = "stop_dynamite_placing"
	self.plant_dynamite_x5 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x5.special_equipment = "dynamite_x5"
	self.plant_dynamite_x4 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x4.special_equipment = "dynamite_x4"
	self.plant_dynamite_from_bag = deep_clone(self.plant_dynamite)
	self.plant_dynamite_from_bag.equipment_consume = false
	self.plant_dynamite_from_bag.special_equipment = "dynamite_bag"
	self.plant_mine = {}
	self.plant_mine.text_id = "hud_plant_mine"
	self.plant_mine.action_text_id = "hud_action_planting_mine"
	self.plant_mine.interact_distance = 200
	self.plant_mine.timer = 2
	self.plant_mine.equipment_text_id = "hint_no_mine"
	self.plant_mine.special_equipment = "landmine"
	self.plant_mine.start_active = false
	self.plant_mine.equipment_consume = true
	self.plant_mine.axis = "z"
	self.plant_mine.sound_start = "cvy_plant_mine_loop_01"
	self.plant_mine.sound_done = "cvy_plant_mine_finish_01"
	self.plant_mine.sound_interupt = "cvy_plant_mine_cancel_01"
	self.piano_key_instant_01 = {}
	self.piano_key_instant_01.text_id = "hud_play_key_01"
	self.piano_key_instant_01.interact_distance = 135
	self.piano_key_instant_02 = {}
	self.piano_key_instant_02.text_id = "hud_play_key_02"
	self.piano_key_instant_02.interact_distance = 135
	self.piano_key_instant_03 = {}
	self.piano_key_instant_03.text_id = "hud_play_key_03"
	self.piano_key_instant_03.interact_distance = 135
	self.piano_key_instant_04 = {}
	self.piano_key_instant_04.text_id = "hud_play_key_04"
	self.piano_key_instant_04.interact_distance = 135
	self.open_door_instant = {}
	self.open_door_instant.text_id = "hud_open_door_instant"
	self.open_door_instant.interact_distance = 200
	self.open_door_instant.sound_done = "door_open_generic"
	self.open_door_short = {}
	self.open_door_short.text_id = "hud_open_door"
	self.open_door_short.action_text_id = "hud_action_opening_door"
	self.open_door_short.icon = "interaction_open_door"
	self.open_door_short.interact_distance = 200
	self.open_door_short.timer = 3
	self.open_door_short.start_active = true
	self.open_door_short.axis = "y"
	self.open_door_short.sound_done = "door_open_generic"
	self.open_door_medium = {}
	self.open_door_medium.text_id = "hud_open_door"
	self.open_door_medium.action_text_id = "hud_action_opening_door"
	self.open_door_medium.upgrade_timer_multipliers = {
		{
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		},
		{
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.open_door_medium.icon = "interaction_open_door"
	self.open_door_medium.interact_distance = 200
	self.open_door_medium.timer = 5
	self.open_door_medium.start_active = true
	self.open_door_medium.axis = "y"
	self.open_door_medium.sound_done = "door_open_generic"
	self.open_crate_2 = {}
	self.open_crate_2.text_id = "hud_open_crate_2"
	self.open_crate_2.action_text_id = "hud_action_opening_crate_2"
	self.open_crate_2.interact_distance = 200
	self.open_crate_2.timer = 0
	self.open_crate_2.start_active = true
	self.open_crate_2.loot_table = {
		"basic_crate_tier",
		"crate_scrap_tier"
	}
	self.open_crate_2.sound_done = "crate_open"
	self.open_metalbox = {}
	self.open_metalbox.text_id = "hud_open_crate_2"
	self.open_metalbox.action_text_id = "hud_action_opening_crate_2"
	self.open_metalbox.interact_distance = 200
	self.open_metalbox.start_active = false
	self.take_document = {}
	self.take_document.text_id = "hud_take_document"
	self.take_document.interact_distance = 200
	self.take_document.start_active = true
	self.take_document.sound_done = "paper_shuffle"
	self.take_documents = {}
	self.take_documents.text_id = "hud_take_documents"
	self.take_documents.interact_distance = 200
	self.take_documents.start_active = true
	self.take_documents.sound_done = "paper_shuffle"
	self.open_window = {}
	self.open_window.text_id = "hud_open_window"
	self.open_window.action_text_id = "hud_action_opening_window"
	self.open_window.interact_distance = 200
	self.open_window.timer = 3
	self.open_window.axis = "y"
	self.open_window.start_active = false
	self.take_thermite = {}
	self.take_thermite.text_id = "hud_take_thermite"
	self.take_thermite.action_text_id = "hud_action_taking_thermite"
	self.take_thermite.special_equipment_block = "thermite"
	self.take_thermite.timer = 2
	self.take_thermite.start_active = true
	self.take_thermite.sound_event = "cvy_pick_up_thermite"
	self.set_up_radio = {}
	self.set_up_radio.text_id = "hud_int_set_up_radio"
	self.set_up_radio.action_text_id = "hud_action_set_up_radio"
	self.set_up_radio.timer = 4
	self.set_up_radio.start_active = false
	self.anwser_radio = {}
	self.anwser_radio.text_id = "hud_int_answer_radio"
	self.anwser_radio.action_text_id = "hud_action_answering_radio"
	self.anwser_radio.timer = 1
	self.anwser_radio.start_active = false
	self.tune_radio = deep_clone(self.anwser_radio)
	self.tune_radio.text_id = "hud_sii_tune_radio"
	self.tune_radio.action_text_id = "hud_action_sii_tune_radio"
	self.tune_radio.timer = 2
	self.ignite_thermite = {}
	self.ignite_thermite.text_id = "hud_ignite_thermite"
	self.ignite_thermite.action_text_id = "hud_action_igniting_thermite"
	self.ignite_thermite.special_equipment = "thermite"
	self.ignite_thermite.equipment_text_id = "hud_int_need_thermite"
	self.ignite_thermite.equipment_consume = true
	self.ignite_thermite.start_active = false
	self.ignite_thermite.timer = 2
	self.untie_zeppelin = {}
	self.untie_zeppelin.text_id = "hud_untie_zeppelin"
	self.untie_zeppelin.action_text_id = "hud_action_untying_zeppelin"
	self.untie_zeppelin.interact_distance = 200
	self.untie_zeppelin.timer = 3
	self.untie_zeppelin.start_active = false
	self.take_tank_grenade = {}
	self.take_tank_grenade.text_id = "hud_take_tank_grenade"
	self.take_tank_grenade.action_text_id = "hud_action_taking_tank_grenade"
	self.take_tank_grenade.special_equipment_block = "tank_grenade"
	self.take_tank_grenade.timer = 2
	self.take_tank_grenade.start_active = true
	self.replace_tank_grenade = {}
	self.replace_tank_grenade.text_id = "hud_replace_tank_grenade"
	self.replace_tank_grenade.action_text_id = "hud_action_replacing_tank_grenade"
	self.replace_tank_grenade.special_equipment = "tank_grenade"
	self.replace_tank_grenade.equipment_text_id = "hud_no_tank_grenade"
	self.replace_tank_grenade.equipment_consume = true
	self.replace_tank_grenade.start_active = false
	self.replace_tank_grenade.timer = 2
	self.take_tools = {}
	self.take_tools.text_id = "hud_take_tools"
	self.take_tools.action_text_id = "hud_action_taking_tools"
	self.take_tools.special_equipment_block = "repair_tools"
	self.take_tools.timer = 2
	self.take_tools.start_active = true
	self.take_tools.sound_done = "pickup_tools"
	self.repair = {}
	self.repair.text_id = "hud_repair"
	self.repair.action_text_id = "hud_action_repairing"
	self.repair.special_equipment = "repair_tools"
	self.repair.equipment_text_id = "hud_no_tools"
	self.repair.equipment_consume = false
	self.repair.start_active = false
	self.repair.timer = 2
	self.take_gas_tank = {}
	self.take_gas_tank.text_id = "hud_take_gas_tank"
	self.take_gas_tank.action_text_id = "hud_action_taking_gas_tank"
	self.take_gas_tank.special_equipment_block = "gas_tank"
	self.take_gas_tank.timer = 2
	self.take_gas_tank.start_active = true
	self.hold_remove_latch = {}
	self.hold_remove_latch.text_id = "hud_int_remove_latch"
	self.hold_remove_latch.action_text_id = "hud_action_remove_latch"
	self.hold_remove_latch.timer = 2
	self.hold_remove_latch.start_active = false
	self.hold_remove_latch.axis = "y"
	self.replace_gas_tank = {}
	self.replace_gas_tank.text_id = "hud_replace_gas_tank"
	self.replace_gas_tank.action_text_id = "hud_action_replacing_gas_tank"
	self.replace_gas_tank.special_equipment = "gas_tank"
	self.replace_gas_tank.equipment_text_id = "hud_no_gas_tank"
	self.replace_gas_tank.equipment_consume = true
	self.replace_gas_tank.start_active = false
	self.replace_gas_tank.timer = 2
	self.take_gold_brick = {}
	self.take_gold_brick.text_id = "hud_take_gold_brick"
	self.take_gold_brick.start_active = true
	self.take_gold_pile = {}
	self.take_gold_pile.icon = "interaction_gold"
	self.take_gold_pile.text_id = "hud_interact_gold_pile_take_money"
	self.take_gold_pile.start_active = true
	self.take_gold_pile.timer = 1
	self.take_gold_pile.action_text_id = "hud_action_taking_gold"
	self.take_gold_pile.blocked_hint = "hud_hint_carry_block_interact"
	self.open_toolbox = {}
	self.open_toolbox.text_id = "hud_open_toolbox"
	self.open_toolbox.action_text_id = "hud_action_opening_toolbox"
	self.open_toolbox.start_active = false
	self.open_toolbox.timer = 2
	self.open_toolbox.interact_distance = 200
	self.open_toolbox.sound_start = "toolbox_interact_start"
	self.open_toolbox.sound_done = "toolbox_interact_stop"
	self.open_toolbox.sound_interupt = "toolbox_interact_stop"
	self.take_safe_key = {}
	self.take_safe_key.text_id = "hud_take_safe_key"
	self.take_safe_key.special_equipment_block = "safe_key"
	self.take_safe_key.start_active = true
	self.take_safe_key.sound_done = "sto_pick_up_key"
	self.unlock_the_safe = {}
	self.unlock_the_safe.text_id = "hud_unlock_safe"
	self.unlock_the_safe.action_text_id = "hud_action_unlocking_safe"
	self.unlock_the_safe.special_equipment = "safe_key"
	self.unlock_the_safe.equipment_text_id = "hud_no_safe_key"
	self.unlock_the_safe.equipment_consume = true
	self.unlock_the_safe.start_active = false
	self.unlock_the_safe.timer = 2
	self.pour_acid = {}
	self.pour_acid.text_id = "hud_pour_acid"
	self.pour_acid.action_text_id = "hud_action_pouring_acid"
	self.pour_acid.special_equipment = "acid"
	self.pour_acid.equipment_text_id = "hud_int_need_acid"
	self.pour_acid.equipment_consume = true
	self.pour_acid.start_active = false
	self.pour_acid.timer = 2
	self.take_acid = {}
	self.take_acid.text_id = "hud_take_acid"
	self.take_acid.action_text_id = "hud_action_taking_acid"
	self.take_acid.special_equipment_block = "acid"
	self.take_acid.start_active = true
	self.take_acid.timer = 2
	self.take_sps_briefcase = {}
	self.take_sps_briefcase.text_id = "hud_take_briefcase"
	self.take_sps_briefcase.action_text_id = "hud_action_taking_briefcase"
	self.take_sps_briefcase.special_equipment_block = "briefcase"
	self.take_sps_briefcase.start_active = true
	self.take_sps_briefcase.timer = 2
	self.take_sps_briefcase.sound_done = "sps_pick_up_briefcase"
	self.take_thermite = {}
	self.take_thermite.text_id = "hud_int_take_thermite"
	self.take_thermite.special_equipment_block = "thermite"
	self.take_thermite.start_active = true
	self.take_thermite.sound_event = "cvy_pick_up_thermite"
	self.use_thermite = {}
	self.use_thermite.text_id = "hud_int_hold_use_thermite"
	self.use_thermite.action_text_id = "hud_action_hold_using_thermite"
	self.use_thermite.special_equipment = "thermite"
	self.use_thermite.equipment_text_id = "hud_int_need_thermite_cvy"
	self.use_thermite.equipment_consume = true
	self.use_thermite.start_active = true
	self.use_thermite.timer = 3
	self.use_thermite.sound_start = "cvy_place_thermite"
	self.use_thermite.sound_interupt = "cvy_place_thermite_cancel"
	self.use_thermite.sound_done = "cvy_place_thermite_cancel"
	self.open_lid = {}
	self.open_lid.text_id = "hud_int_open_lid"
	self.open_lid.start_active = true
	self.open_lid.sound_event = "brh_holding_cells_door_lid"
	self.pku_codemachine_part_01 = {}
	self.pku_codemachine_part_01.text_id = "hud_take_codemachine_part_01"
	self.pku_codemachine_part_01.action_text_id = "hud_action_taking_codemachine_part_01"
	self.pku_codemachine_part_01.start_active = true
	self.pku_codemachine_part_01.timer = 1
	self.pku_codemachine_part_01.blocked_hint = "hud_hint_carry_block_interact"
	self.pku_codemachine_part_02 = {}
	self.pku_codemachine_part_02.text_id = "hud_take_codemachine_part_02"
	self.pku_codemachine_part_02.action_text_id = "hud_action_taking_codemachine_part_03"
	self.pku_codemachine_part_02.start_active = true
	self.pku_codemachine_part_02.timer = 1
	self.pku_codemachine_part_02.blocked_hint = "hud_hint_carry_block_interact"
	self.pku_codemachine_part_03 = {}
	self.pku_codemachine_part_03.text_id = "hud_take_codemachine_part_03"
	self.pku_codemachine_part_03.action_text_id = "hud_action_taking_codemachine_part_03"
	self.pku_codemachine_part_03.start_active = true
	self.pku_codemachine_part_03.timer = 1
	self.pku_codemachine_part_03.blocked_hint = "hud_hint_carry_block_interact"
	self.pku_codemachine_part_04 = {}
	self.pku_codemachine_part_04.text_id = "hud_take_codemachine_part_04"
	self.pku_codemachine_part_04.action_text_id = "hud_action_taking_codemachine_part_04"
	self.pku_codemachine_part_04.start_active = true
	self.pku_codemachine_part_04.timer = 1
	self.pku_codemachine_part_04.blocked_hint = "hud_hint_carry_block_interact"
	self.take_gold_bar_mold = {}
	self.take_gold_bar_mold.text_id = "hud_take_gold_bar_mold"
	self.take_gold_bar_mold.action_text_id = "hud_action_taking_gold_bar_mold"
	self.take_gold_bar_mold.start_active = true
	self.take_gold_bar_mold.timer = 2
	self.take_gold_bar_mold.special_equipment_block = "gold_bar_mold"
	self.place_mold = {}
	self.place_mold.text_id = "hud_place_mold"
	self.place_mold.action_text_id = "hud_action_placing_mold"
	self.place_mold.special_equipment = "gold_bar_mold"
	self.place_mold.equipment_text_id = "hud_int_need_gold_bar_mold"
	self.place_mold.equipment_consume = true
	self.place_mold.start_active = false
	self.place_mold.timer = 2
	self.take_tank_shell = {}
	self.take_tank_shell.text_id = "hud_take_tank_shell"
	self.take_tank_shell.action_text_id = "hud_action_taking_tank_shell"
	self.take_tank_shell.special_equipment_block = "tank_shell"
	self.take_tank_shell.start_active = false
	self.take_tank_shell.timer = 2
	self.place_tank_shell = {}
	self.place_tank_shell.text_id = "hud_place_tank_shell"
	self.place_tank_shell.action_text_id = "hud_action_placing_tank_shell"
	self.place_tank_shell.special_equipment = "tank_shell"
	self.place_tank_shell.equipment_text_id = "hud_int_need_tank_shell"
	self.place_tank_shell.equipment_consume = true
	self.place_tank_shell.start_active = false
	self.place_tank_shell.timer = 2
	self.place_tank_shell.interact_dont_interupt_on_distance = true
	self.graveyard_check_tank = {}
	self.graveyard_check_tank.text_id = "hud_graveyard_check_tank"
	self.graveyard_check_tank.action_text_id = "hud_action_graveyard_check_tank"
	self.graveyard_check_tank.start_active = true
	self.graveyard_check_tank.timer = 2
	self.graveyard_check_tank.special_equipment_block = "gold_bar_mold"
	self.graveyard_drag_pilot_1 = {}
	self.graveyard_drag_pilot_1.text_id = "hud_graveyard_drag_pilot_1"
	self.graveyard_drag_pilot_1.action_text_id = "hud_action_graveyard_drag_pilot_1"
	self.graveyard_drag_pilot_1.start_active = true
	self.graveyard_drag_pilot_1.timer = 2
	self.graveyard_drag_pilot_1.special_equipment_block = "gold_bar_mold"
	self.search_radio_parts = {}
	self.search_radio_parts.text_id = "hud_search_radio_parts"
	self.search_radio_parts.action_text_id = "hud_action_searching_radio_parts"
	self.search_radio_parts.start_active = false
	self.search_radio_parts.timer = 4
	self.search_radio_parts.special_equipment_block = "radio_parts"
	self.replace_radio_parts = {}
	self.replace_radio_parts.text_id = "hud_replace_radio_parts"
	self.replace_radio_parts.action_text_id = "hud_action_replacing_radio_parts"
	self.replace_radio_parts.special_equipment = "radio_parts"
	self.replace_radio_parts.equipment_text_id = "hud_int_need_radio_parts"
	self.replace_radio_parts.equipment_consume = true
	self.replace_radio_parts.start_active = false
	self.replace_radio_parts.timer = 2
	self.take_blacksmith_tong = {}
	self.take_blacksmith_tong.text_id = "hud_take_blacksmith_tong"
	self.take_blacksmith_tong.start_active = false
	self.take_blacksmith_tong.special_equipment_block = "blacksmith_tong"
	self.turret_m2 = {}
	self.turret_m2.text_id = "hud_turret_m2"
	self.turret_m2.action_text_id = "hud_action_mounting_turret"
	self.turret_m2.start_active = true
	self.turret_m2.timer = 0.5
	self.turret_flak_88 = {}
	self.turret_flak_88.text_id = "hud_turret_88"
	self.turret_flak_88.action_text_id = "hud_action_mounting_turret"
	self.turret_flak_88.start_active = false
	self.turret_flak_88.timer = 0.5
	self.turret_flak_88.interact_distance = 400
	self.turret_flak_88.axis = "z"
	self.turret_flakvierling = {}
	self.turret_flakvierling.text_id = "hud_int_hold_turret_flakvierling"
	self.turret_flakvierling.action_text_id = "hud_action_turret_flakvierling"
	self.turret_flakvierling.start_active = true
	self.turret_flakvierling.timer = 1
	self.turret_flakvierling.interact_distance = 400
	self.start_ladle = {}
	self.start_ladle.start_active = "false"
	self.start_ladle.text_id = "hud_start_ladle"
	self.stop_ladle = {}
	self.stop_ladle.start_active = "false"
	self.stop_ladle.text_id = "hud_stop_ladle"
	self.cool_gold_bar = {}
	self.cool_gold_bar.text_id = "hud_cool_gold_bar"
	self.cool_gold_bar.action_text_id = "hud_action_cooling_gold_bar"
	self.cool_gold_bar.special_equipment = "gold_bar"
	self.cool_gold_bar.equipment_text_id = "hud_int_need_gold_bar"
	self.cool_gold_bar.equipment_consume = true
	self.cool_gold_bar.start_active = false
	self.cool_gold_bar.timer = 2
	self.pour_iron = {}
	self.pour_iron.text_id = "hud_pour_iron"
	self.pour_iron.start_active = false
	self.open_chest = {}
	self.open_chest.text_id = "hud_open_chest"
	self.open_chest.action_text_id = "hud_action_opening_chest"
	self.open_chest.start_active = false
	self.open_chest.timer = 2
	self.take_contraband_jewelry = {}
	self.take_contraband_jewelry.text_id = "hud_take_contraband_jewelry"
	self.take_contraband_jewelry.action_text_id = "hud_action_taking_contraband_jewelry"
	self.take_contraband_jewelry.start_active = true
	self.take_contraband_jewelry.timer = 2
	self.open_radio_hatch = {}
	self.open_radio_hatch.text_id = "hud_open_radio_hatch"
	self.open_radio_hatch.action_text_id = "hud_action_opening_radio_hatch"
	self.open_radio_hatch.start_active = false
	self.open_radio_hatch.timer = 2
	self.open_tank_hatch = {}
	self.open_tank_hatch.text_id = "hud_open_tank_hatch"
	self.open_tank_hatch.action_text_id = "hud_action_opening_tank_hatch"
	self.open_tank_hatch.start_active = false
	self.open_tank_hatch.timer = 2
	self.open_hatch = {}
	self.open_hatch.text_id = "hud_open_hatch"
	self.open_hatch.action_text_id = "hud_action_opening_hatch"
	self.open_hatch.start_active = false
	self.open_hatch.timer = 2
	self.break_open_door = {}
	self.break_open_door.text_id = "hud_break_open_door"
	self.break_open_door.action_text_id = "hud_action_breaking_opening_door"
	self.break_open_door.special_equipment = "crowbar"
	self.break_open_door.equipment_text_id = "hud_int_need_crowbar"
	self.break_open_door.equipment_consume = false
	self.break_open_door.start_active = false
	self.break_open_door.timer = 3
	self.break_open_door.axis = "x"
	self.open_vault_door = {}
	self.open_vault_door.text_id = "hud_open_vault_door"
	self.open_vault_door.action_text_id = "hud_action_opening_vault_door"
	self.open_vault_door.start_active = false
	self.open_vault_door.timer = 3
	self.breach_open_door = {}
	self.breach_open_door.text_id = "hud_breach_door"
	self.breach_open_door.action_text_id = "hud_action_breaching_door"
	self.breach_open_door.start_active = false
	self.breach_open_door.timer = 3
	self.take_blow_torch = {}
	self.take_blow_torch.text_id = "hud_take_blow_torch"
	self.take_blow_torch.special_equipment_block = "blow_torch"
	self.take_blow_torch.equipment_consume = false
	self.take_blow_torch.start_active = false
	self.fill_blow_torch = {}
	self.fill_blow_torch.text_id = "hud_fill_blow_torch"
	self.fill_blow_torch.action_text_id = "hud_action_filling_blow_torch"
	self.fill_blow_torch.special_equipment = "blow_torch"
	self.fill_blow_torch.special_equipment_block = "blow_torch_fuel"
	self.fill_blow_torch.equipment_text_id = "hud_int_need_blow_torch"
	self.fill_blow_torch.equipment_consume = false
	self.fill_blow_torch.start_active = false
	self.fill_blow_torch.timer = 5
	self.cut_vault_bars = {}
	self.cut_vault_bars.text_id = "hud_cut_vault_bars"
	self.cut_vault_bars.action_text_id = "hud_action_cutting_vault_bars"
	self.cut_vault_bars.special_equipment = "blow_torch_fuel"
	self.cut_vault_bars.equipment_text_id = "hud_int_need_blow_torch_fuel"
	self.cut_vault_bars.equipment_consume = true
	self.cut_vault_bars.start_active = true
	self.cut_vault_bars.timer = 5
	self.take_torch_tank = {}
	self.take_torch_tank.text_id = "hud_take_torch_tank"
	self.take_torch_tank.action_text_id = "hud_action_taking_torch_tank"
	self.take_torch_tank.start_active = false
	self.take_torch_tank.timer = 3
	self.sii_test = {}
	self.sii_test.icon = "develop"
	self.sii_test.text_id = "debug_interact_temp_interact_box"
	self.sii_test.interact_distance = 500
	self.sii_test.number_of_circles = 3
	self.sii_test.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.sii_test.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.sii_test.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.sii_test.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.sii_test.sounds = {
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
	self.sii_lockpick_easy_y_direction = {}
	self.sii_lockpick_easy_y_direction.icon = "develop"
	self.sii_lockpick_easy_y_direction.text_id = "hud_sii_lockpick"
	self.sii_lockpick_easy_y_direction.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_easy_y_direction.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_easy_y_direction.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_easy_y_direction.axis = "y"
	self.sii_lockpick_easy_y_direction.interact_distance = 200
	self.sii_lockpick_easy_y_direction.number_of_circles = 1
	self.sii_lockpick_easy_y_direction.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.sii_lockpick_easy_y_direction.circle_rotation_speed = {
		160
	}
	self.sii_lockpick_easy_y_direction.circle_rotation_direction = {
		1
	}
	self.sii_lockpick_easy_y_direction.circle_difficulty = {
		0.9
	}
	self.sii_lockpick_easy_y_direction.sounds = {
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
	self.sii_lockpick_easy_y_direction.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.sii_lockpick_easy = {}
	self.sii_lockpick_easy.icon = "develop"
	self.sii_lockpick_easy.text_id = "hud_sii_lockpick"
	self.sii_lockpick_easy.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_easy.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_easy.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_easy.interact_distance = 200
	self.sii_lockpick_easy.number_of_circles = 1
	self.sii_lockpick_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.sii_lockpick_easy.circle_rotation_speed = {
		160
	}
	self.sii_lockpick_easy.circle_rotation_direction = {
		1
	}
	self.sii_lockpick_easy.circle_difficulty = {
		0.9
	}
	self.sii_lockpick_easy.sounds = {
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
	self.sii_lockpick_easy.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.sii_lockpick_medium_y_direction = {}
	self.sii_lockpick_medium_y_direction.icon = "develop"
	self.sii_lockpick_medium_y_direction.text_id = "hud_sii_lockpick"
	self.sii_lockpick_medium_y_direction.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_medium_y_direction.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_medium_y_direction.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_medium_y_direction.axis = "y"
	self.sii_lockpick_medium_y_direction.interact_distance = 200
	self.sii_lockpick_medium_y_direction.number_of_circles = 2
	self.sii_lockpick_medium_y_direction.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_medium_y_direction
	}
	self.sii_lockpick_medium_y_direction.circle_rotation_speed = {
		160,
		180
	}
	self.sii_lockpick_medium_y_direction.circle_rotation_direction = {
		1,
		-1
	}
	self.sii_lockpick_medium_y_direction.circle_difficulty = {
		0.9,
		0.93
	}
	self.sii_lockpick_medium_y_direction.sounds = {
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
	self.sii_lockpick_medium_y_direction.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.sii_lockpick_medium = {}
	self.sii_lockpick_medium.icon = "develop"
	self.sii_lockpick_medium.text_id = "hud_sii_lockpick"
	self.sii_lockpick_medium.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_medium.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_medium.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_medium.interact_distance = 200
	self.sii_lockpick_medium.number_of_circles = 2
	self.sii_lockpick_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.sii_lockpick_medium.circle_rotation_speed = {
		160,
		180
	}
	self.sii_lockpick_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.sii_lockpick_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.sii_lockpick_medium.sounds = {
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
	self.sii_lockpick_medium.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.sii_lockpick_hard_y_direction = {}
	self.sii_lockpick_hard_y_direction.icon = "develop"
	self.sii_lockpick_hard_y_direction.text_id = "hud_sii_lockpick"
	self.sii_lockpick_hard_y_direction.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_hard_y_direction.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_hard_y_direction.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_hard_y_direction.axis = "y"
	self.sii_lockpick_hard_y_direction.interact_distance = 200
	self.sii_lockpick_hard_y_direction.number_of_circles = 3
	self.sii_lockpick_hard_y_direction.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.sii_lockpick_hard_y_direction.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.sii_lockpick_hard_y_direction.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.sii_lockpick_hard_y_direction.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.sii_lockpick_hard_y_direction.sounds = {
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
	self.sii_lockpick_hard_y_direction.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.sii_lockpick_hard = {}
	self.sii_lockpick_hard.icon = "develop"
	self.sii_lockpick_hard.text_id = "hud_sii_lockpick"
	self.sii_lockpick_hard.action_text_id = "hud_action_sii_lockpicking"
	self.sii_lockpick_hard.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.sii_lockpick_hard.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.sii_lockpick_hard.interact_distance = 200
	self.sii_lockpick_hard.number_of_circles = 3
	self.sii_lockpick_hard.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.sii_lockpick_hard.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.sii_lockpick_hard.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.sii_lockpick_hard.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.sii_lockpick_hard.sounds = {
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
	self.sii_lockpick_hard.loot_table = {
		"lockpick_crate_tier",
		"crate_scrap_tier"
	}
	self.take_turret_m2_gun = {}
	self.take_turret_m2_gun.text_id = "hud_take_turret_m2_gun"
	self.take_turret_m2_gun.action_text_id = "hud_action_taking_turret_m2_gun"
	self.take_turret_m2_gun.start_active = false
	self.take_turret_m2_gun.timer = 3
	self.take_turret_m2_gun.sound_start = "turret_pick_up"
	self.take_turret_m2_gun.sound_interupt = "turret_pick_up_stop"
	self.take_turret_m2_gun_enabled = {}
	self.take_turret_m2_gun_enabled.text_id = "hud_take_turret_m2_gun"
	self.take_turret_m2_gun_enabled.action_text_id = "hud_action_taking_turret_m2_gun"
	self.take_turret_m2_gun_enabled.start_active = true
	self.take_turret_m2_gun_enabled.timer = 3
	self.take_turret_m2_gun_enabled.sound_start = "turret_pick_up"
	self.take_turret_m2_gun_enabled.sound_interupt = "turret_pick_up_stop"

	local com_wheel_color = Color(1, 0.8, 0)

	local function com_wheel_clbk(say_target_id, default_say_id, post_prefix, past_prefix, waypoint_tech)
		local character = managers.network:session():local_peer()._character
		local nationality = CriminalsManager.comm_wheel_callout_from_nationality(character)
		local snd = post_prefix .. nationality .. past_prefix
		local text
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

	self.com_wheel = {}
	self.com_wheel.icon = "develop"
	self.com_wheel.color = com_wheel_color
	self.com_wheel.text_id = "debug_interact_temp_interact_box"
	self.com_wheel.wheel_radius_inner = 120
	self.com_wheel.wheel_radius_outer = 150
	self.com_wheel.text_padding = 25
	self.com_wheel.cooldown = 1.5
	self.com_wheel.options = {
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
	self.take_money_print_plate = {}
	self.take_money_print_plate.text_id = "hud_take_money_print_plate"
	self.take_money_print_plate.action_text_id = "hud_action_taking_money_print_plate"
	self.take_money_print_plate.start_active = false
	self.take_money_print_plate.timer = 3
	self.signal_light = {}
	self.signal_light.text_id = "hud_signal_light"
	self.signal_light.start_active = true
	self.signal_light.axis = "z"
	self.take_safe_keychain = {}
	self.take_safe_keychain.text_id = "hud_take_safe_keychain"
	self.take_safe_keychain.start_active = true
	self.take_safe_keychain.special_equipment_block = "safe_keychain"
	self.take_safe_keychain.equipment_consume = false
	self.unlock_the_safe_keychain = {}
	self.unlock_the_safe_keychain.text_id = "hud_unlock_safe"
	self.unlock_the_safe_keychain.action_text_id = "hud_action_unlocking_safe"
	self.unlock_the_safe_keychain.special_equipment = "safe_keychain"
	self.unlock_the_safe_keychain.equipment_text_id = "hud_no_safe_keychain"
	self.unlock_the_safe_keychain.equipment_consume = false
	self.unlock_the_safe_keychain.start_active = false
	self.unlock_the_safe_keychain.timer = 2
	self.take_gear = {}
	self.take_gear.text_id = "hud_take_gear"
	self.take_gear.action_text_id = "hud_action_taking_gear"
	self.take_gear.start_active = false
	self.take_gear.interact_distance = 250
	self.take_gear.timer = 3
	self.take_gear.can_interact_in_civilian = true
	self.take_ladder = {}
	self.take_ladder.text_id = "hud_take_ladder"
	self.take_ladder.action_text_id = "hud_action_taking_ladder"
	self.take_ladder.start_active = false
	self.take_ladder.interact_distance = 250
	self.take_ladder.timer = 3
	self.take_ladder.sound_start = "ladder_pickup_loop_start"
	self.take_ladder.sound_interupt = "ladder_pickup_complete"
	self.take_ladder.sound_done = "ladder_pickup_complete"
	self.take_flak_shell = {}
	self.take_flak_shell.text_id = "hud_take_flak_shell"
	self.take_flak_shell.action_text_id = "hud_action_taking_flak_shell"
	self.take_flak_shell.start_active = false
	self.take_flak_shell.interact_distance = 300
	self.take_flak_shell.timer = 1.5
	self.take_flak_shell.sound_start = "flakshell_take"
	self.take_flak_shell.sound_done = "flakshell_packed"
	self.take_flak_shell.sound_interupt = "flakshell_take_stop"
	self.take_flak_shell_bag = deep_clone(self.take_flak_shell)
	self.take_flak_shell_bag.force_update_position = true
	self.take_flak_shell_bag.start_active = true
	self.take_flak_shell_bag.timer = 1
	self.take_plank = {}
	self.take_plank.text_id = "hud_take_plank"
	self.take_plank.action_text_id = "hud_action_taking_plank"
	self.take_plank.start_active = false
	self.take_plank.interact_distance = 300
	self.take_plank.timer = 0.5
	self.take_plank.sound_done = "take_plank"
	self.take_plank_bag = deep_clone(self.take_plank)
	self.take_plank_bag.force_update_position = true
	self.take_plank_bag.start_active = true
	self.take_flak_shell_pallete = {}
	self.take_flak_shell_pallete.text_id = "hud_take_flak_shell_pallete"
	self.take_flak_shell_pallete.action_text_id = "hud_action_taking_flak_shell_pallete"
	self.take_flak_shell_pallete.start_active = false
	self.take_flak_shell_pallete.interact_distance = 250
	self.take_flak_shell_pallete.timer = 3
	self.activate_elevator = {}
	self.activate_elevator.text_id = "hud_activate_elevator"
	self.activate_elevator.start_active = false
	self.activate_elevator.interact_distance = 250
	self.lift_trap_door = {}
	self.lift_trap_door.text_id = "hud_lift_trap_door"
	self.lift_trap_door.start_active = false
	self.lift_trap_door.interact_distance = 300
	self.open_drop_pod = {}
	self.open_drop_pod.text_id = "hud_open_drop_pod"
	self.open_drop_pod.action_text_id = "hud_action_opening_drop_pod"
	self.open_drop_pod.start_active = false
	self.open_drop_pod.interact_distance = 300
	self.open_drop_pod.timer = 2
	self.open_drop_pod.sound_start = "open_drop_pod_start"
	self.open_drop_pod.sound_interupt = "open_drop_pod_interrupt"
	self.pour_lava_ladle_01 = {}
	self.pour_lava_ladle_01.text_id = "hud_pour_lava"
	self.pour_lava_ladle_01.action_text_id = "hud_action_pouring_lava"
	self.pour_lava_ladle_01.start_active = false
	self.pour_lava_ladle_01.interact_distance = 250
	self.pour_lava_ladle_01.timer = 3
	self.open_army_crate = {}
	self.open_army_crate.text_id = "hud_open_army_crate"
	self.open_army_crate.action_text_id = "hud_action_opening_army_crate"
	self.open_army_crate.special_equipment = "crowbar"
	self.open_army_crate.equipment_text_id = "hud_int_need_crowbar"
	self.open_army_crate.equipment_consume = false
	self.open_army_crate.start_active = false
	self.open_army_crate.interact_distance = 250
	self.open_army_crate.timer = 1.5
	self.open_army_crate.upgrade_timer_multipliers = {
		{
			upgrade = "open_crate_multiplier",
			category = "interaction"
		}
	}
	self.open_army_crate.loot_table = {
		"crowbar_crate_tier",
		"crate_scrap_tier"
	}
	self.open_army_crate.sound_start = "crowbarcrate_open"
	self.open_army_crate.sound_done = "crate_open"
	self.open_army_crate.sound_interupt = "stop_crowbarcrate_open"
	self.open_fusebox = {}
	self.open_fusebox.text_id = "hud_open_fusebox"
	self.open_fusebox.action_text_id = "hud_action_opening_fusebox"
	self.open_fusebox.start_active = false
	self.open_fusebox.interact_distance = 250
	self.open_fusebox.timer = 2
	self.activate_trigger = {}
	self.activate_trigger.text_id = "hud_activate_trigger"
	self.activate_trigger.action_text_id = "hud_action_activating_trigger"
	self.activate_trigger.start_active = false
	self.activate_trigger.interact_distance = 250
	self.activate_trigger.timer = 1
	self.sii_tune_radio = {}
	self.sii_tune_radio.icon = "develop"
	self.sii_tune_radio.text_id = "hud_sii_tune_radio"
	self.sii_tune_radio.action_text_id = "hud_action_sii_tune_radio"
	self.sii_tune_radio.axis = "y"
	self.sii_tune_radio.interact_distance = 200
	self.sii_tune_radio.number_of_circles = 3
	self.sii_tune_radio.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.sii_tune_radio.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.sii_tune_radio.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.sii_tune_radio.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.sii_tune_radio.sounds = {
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
	self.si_revive = {}
	self.si_revive.icon = "develop"
	self.si_revive.text_id = "skill_interaction_revive"
	self.si_revive.action_text_id = "skill_interaction_revive"
	self.si_revive.axis = "y"
	self.si_revive.interact_distance = 200
	self.si_revive.number_of_circles = 1
	self.si_revive.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.si_revive.circle_rotation_speed = {
		160
	}
	self.si_revive.circle_rotation_direction = {
		1
	}
	self.si_revive.circle_difficulty = {
		0.9
	}
	self.si_revive.sounds = {
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
	self.sii_tune_radio_easy = {}
	self.sii_tune_radio_easy.icon = "develop"
	self.sii_tune_radio_easy.text_id = "hud_sii_tune_radio"
	self.sii_tune_radio_easy.action_text_id = "hud_action_sii_tune_radio"
	self.sii_tune_radio_easy.axis = "y"
	self.sii_tune_radio_easy.interact_distance = 200
	self.sii_tune_radio_easy.number_of_circles = 1
	self.sii_tune_radio_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.sii_tune_radio_easy.circle_rotation_speed = {
		160
	}
	self.sii_tune_radio_easy.circle_rotation_direction = {
		1
	}
	self.sii_tune_radio_easy.circle_difficulty = {
		0.9
	}
	self.sii_tune_radio_easy.sounds = {
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
	self.sii_tune_radio_medium = {}
	self.sii_tune_radio_medium.icon = "develop"
	self.sii_tune_radio_medium.text_id = "hud_sii_tune_radio"
	self.sii_tune_radio_medium.action_text_id = "hud_action_sii_tune_radio"
	self.sii_tune_radio_medium.axis = "y"
	self.sii_tune_radio_medium.interact_distance = 200
	self.sii_tune_radio_medium.number_of_circles = 2
	self.sii_tune_radio_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.sii_tune_radio_medium.circle_rotation_speed = {
		160,
		180
	}
	self.sii_tune_radio_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.sii_tune_radio_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.sii_tune_radio_medium.sounds = {
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
	self.activate_switch = {}
	self.activate_switch.icon = "develop"
	self.activate_switch.text_id = "hud_activate_switch"
	self.activate_switch.action_text_id = "hud_action_activate_switch"
	self.activate_switch.axis = "y"
	self.activate_switch.interact_distance = 200
	self.activate_switch.timer = 2.335
	self.activate_switch_easy = deep_clone(self.activate_switch)
	self.activate_switch_medium = deep_clone(self.activate_switch)
	self.rewire_fuse_pane = {}
	self.rewire_fuse_pane.icon = "develop"
	self.rewire_fuse_pane.text_id = "hud_rewire_fuse_pane"
	self.rewire_fuse_pane.action_text_id = "hud_action_rewire_fuse_pane"
	self.rewire_fuse_pane.axis = "y"
	self.rewire_fuse_pane.interact_distance = 200
	self.rewire_fuse_pane.number_of_circles = 3
	self.rewire_fuse_pane.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.rewire_fuse_pane.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.rewire_fuse_pane.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.rewire_fuse_pane.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.rewire_fuse_pane.sounds = {
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
	self.rewire_fuse_pane_easy = {}
	self.rewire_fuse_pane_easy.icon = "develop"
	self.rewire_fuse_pane_easy.text_id = "hud_rewire_fuse_pane"
	self.rewire_fuse_pane_easy.action_text_id = "hud_action_rewire_fuse_pane"
	self.rewire_fuse_pane_easy.axis = "y"
	self.rewire_fuse_pane_easy.interact_distance = 200
	self.rewire_fuse_pane_easy.number_of_circles = 1
	self.rewire_fuse_pane_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.rewire_fuse_pane_easy.circle_rotation_speed = {
		160
	}
	self.rewire_fuse_pane_easy.circle_rotation_direction = {
		1
	}
	self.rewire_fuse_pane_easy.circle_difficulty = {
		0.9
	}
	self.rewire_fuse_pane_easy.sounds = {
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
	self.rewire_fuse_pane_medium = {}
	self.rewire_fuse_pane_medium.icon = "develop"
	self.rewire_fuse_pane_medium.text_id = "hud_rewire_fuse_pane"
	self.rewire_fuse_pane_medium.action_text_id = "hud_action_rewire_fuse_pane"
	self.rewire_fuse_pane_medium.axis = "y"
	self.rewire_fuse_pane_medium.interact_distance = 200
	self.rewire_fuse_pane_medium.number_of_circles = 2
	self.rewire_fuse_pane_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.rewire_fuse_pane_medium.circle_rotation_speed = {
		160,
		180
	}
	self.rewire_fuse_pane_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.rewire_fuse_pane_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.rewire_fuse_pane_medium.sounds = {
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
	self.picklock_door = {}
	self.picklock_door.icon = "develop"
	self.picklock_door.text_id = "hud_picklock_door"
	self.picklock_door.action_text_id = "hud_action_picklock_door"
	self.picklock_door.axis = "y"
	self.picklock_door.interact_distance = 200
	self.picklock_door.number_of_circles = 3
	self.picklock_door.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.picklock_door.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.picklock_door.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.picklock_door.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.picklock_door.sounds = {
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
	self.picklock_door_easy = {}
	self.picklock_door_easy.icon = "develop"
	self.picklock_door_easy.text_id = "hud_picklock_door"
	self.picklock_door_easy.action_text_id = "hud_action_picklock_door"
	self.picklock_door_easy.axis = "y"
	self.picklock_door_easy.interact_distance = 200
	self.picklock_door_easy.number_of_circles = 1
	self.picklock_door_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.picklock_door_easy.circle_rotation_speed = {
		160
	}
	self.picklock_door_easy.circle_rotation_direction = {
		1
	}
	self.picklock_door_easy.circle_difficulty = {
		0.9
	}
	self.picklock_door_easy.sounds = {
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
	self.picklock_door_medium = {}
	self.picklock_door_medium.icon = "develop"
	self.picklock_door_medium.text_id = "hud_picklock_door"
	self.picklock_door_medium.action_text_id = "hud_action_picklock_door"
	self.picklock_door_medium.axis = "y"
	self.picklock_door_medium.interact_distance = 200
	self.picklock_door_medium.number_of_circles = 2
	self.picklock_door_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.picklock_door_medium.circle_rotation_speed = {
		160,
		180
	}
	self.picklock_door_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.picklock_door_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.picklock_door_medium.sounds = {
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
	self.picklock_window = {}
	self.picklock_window.icon = "develop"
	self.picklock_window.text_id = "hud_picklock_window"
	self.picklock_window.action_text_id = "hud_action_picklock_window"
	self.picklock_window.axis = "y"
	self.picklock_window.interact_distance = 200
	self.picklock_window.number_of_circles = 3
	self.picklock_window.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.picklock_window.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.picklock_window.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.picklock_window.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.picklock_window.sounds = {
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
	self.picklock_window_easy = {}
	self.picklock_window_easy.icon = "develop"
	self.picklock_window_easy.text_id = "hud_picklock_window"
	self.picklock_window_easy.action_text_id = "hud_action_picklock_window"
	self.picklock_window_easy.axis = "y"
	self.picklock_window_easy.interact_distance = 200
	self.picklock_window_easy.number_of_circles = 1
	self.picklock_window_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.picklock_window_easy.circle_rotation_speed = {
		160
	}
	self.picklock_window_easy.circle_rotation_direction = {
		1
	}
	self.picklock_window_easy.circle_difficulty = {
		0.9
	}
	self.picklock_window_easy.sounds = {
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
	self.picklock_window_medium = {}
	self.picklock_window_medium.icon = "develop"
	self.picklock_window_medium.text_id = "hud_picklock_window"
	self.picklock_window_medium.action_text_id = "hud_action_picklock_window"
	self.picklock_window_medium.axis = "y"
	self.picklock_window_medium.interact_distance = 200
	self.picklock_window_medium.number_of_circles = 2
	self.picklock_window_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.picklock_window_medium.circle_rotation_speed = {
		160,
		180
	}
	self.picklock_window_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.picklock_window_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.picklock_window_medium.sounds = {
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
	self.call_mrs_white = {}
	self.call_mrs_white.icon = "develop"
	self.call_mrs_white.text_id = "hud_call_mrs_white"
	self.call_mrs_white.action_text_id = "hud_action_call_mrs_white"
	self.call_mrs_white.axis = "z"
	self.call_mrs_white.interact_distance = 200
	self.call_mrs_white.number_of_circles = 3
	self.call_mrs_white.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.call_mrs_white.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.call_mrs_white.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.call_mrs_white.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.call_mrs_white.sounds = {
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
	self.call_mrs_white_easy = {}
	self.call_mrs_white_easy.icon = "develop"
	self.call_mrs_white_easy.text_id = "hud_call_mrs_white"
	self.call_mrs_white_easy.action_text_id = "hud_action_call_mrs_white"
	self.call_mrs_white_easy.axis = "z"
	self.call_mrs_white_easy.interact_distance = 200
	self.call_mrs_white_easy.number_of_circles = 1
	self.call_mrs_white_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.call_mrs_white_easy.circle_rotation_speed = {
		160
	}
	self.call_mrs_white_easy.circle_rotation_direction = {
		1
	}
	self.call_mrs_white_easy.circle_difficulty = {
		0.9
	}
	self.call_mrs_white_easy.sounds = {
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
	self.call_mrs_white_medium = {}
	self.call_mrs_white_medium.icon = "develop"
	self.call_mrs_white_medium.text_id = "hud_call_mrs_white"
	self.call_mrs_white_medium.action_text_id = "hud_action_call_mrs_white"
	self.call_mrs_white_medium.axis = "z"
	self.call_mrs_white_medium.interact_distance = 200
	self.call_mrs_white_medium.number_of_circles = 2
	self.call_mrs_white_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.call_mrs_white_medium.circle_rotation_speed = {
		160,
		180
	}
	self.call_mrs_white_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.call_mrs_white_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.call_mrs_white_medium.sounds = {
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
	self.activate_burners = {}
	self.activate_burners.icon = "develop"
	self.activate_burners.text_id = "hud_activate_burners"
	self.activate_burners.action_text_id = "hud_action_activate_burners"
	self.activate_burners.axis = "y"
	self.activate_burners.interact_distance = 200
	self.activate_burners.number_of_circles = 3
	self.activate_burners.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		self.MINIGAME_CIRCLE_RADIUS_BIG
	}
	self.activate_burners.circle_rotation_speed = {
		160,
		180,
		190
	}
	self.activate_burners.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.activate_burners.circle_difficulty = {
		0.9,
		0.93,
		0.96
	}
	self.activate_burners.sounds = {
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
	self.activate_burners_easy = {}
	self.activate_burners_easy.icon = "develop"
	self.activate_burners_easy.text_id = "hud_activate_burners"
	self.activate_burners_easy.action_text_id = "hud_action_activate_burners"
	self.activate_burners_easy.axis = "y"
	self.activate_burners_easy.interact_distance = 200
	self.activate_burners_easy.number_of_circles = 1
	self.activate_burners_easy.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL
	}
	self.activate_burners_easy.circle_rotation_speed = {
		160
	}
	self.activate_burners_easy.circle_rotation_direction = {
		1
	}
	self.activate_burners_easy.circle_difficulty = {
		0.9
	}
	self.activate_burners_easy.sounds = {
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
	self.activate_burners_medium = {}
	self.activate_burners_medium.icon = "develop"
	self.activate_burners_medium.text_id = "hud_activate_burners"
	self.activate_burners_medium.action_text_id = "hud_action_activate_burners"
	self.activate_burners_medium.axis = "y"
	self.activate_burners_medium.interact_distance = 200
	self.activate_burners_medium.number_of_circles = 2
	self.activate_burners_medium.circle_radius = {
		self.MINIGAME_CIRCLE_RADIUS_SMALL,
		self.MINIGAME_CIRCLE_RADIUS_MEDIUM
	}
	self.activate_burners_medium.circle_rotation_speed = {
		160,
		180
	}
	self.activate_burners_medium.circle_rotation_direction = {
		1,
		-1
	}
	self.activate_burners_medium.circle_difficulty = {
		0.9,
		0.93
	}
	self.activate_burners_medium.sounds = {
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
	self.take_parachute = {}
	self.take_parachute.text_id = "hud_take_parachute"
	self.take_parachute.start_active = false
	self.take_parachute.interact_distance = 250
	self.take_bolt_cutter = {}
	self.take_bolt_cutter.text_id = "hud_take_bolt_cutter"
	self.take_bolt_cutter.start_active = false
	self.take_bolt_cutter.interact_distance = 250
	self.take_bolt_cutter.special_equipment_block = "bolt_cutter"
	self.cut_chain_bolt_cutter = {}
	self.cut_chain_bolt_cutter.text_id = "hud_cut_chain"
	self.cut_chain_bolt_cutter.action_text_id = "hud_action_cutting_chain"
	self.cut_chain_bolt_cutter.special_equipment = "bolt_cutter"
	self.cut_chain_bolt_cutter.equipment_text_id = "hud_int_need_bolt_cutter"
	self.cut_chain_bolt_cutter.equipment_consume = false
	self.cut_chain_bolt_cutter.start_active = false
	self.cut_chain_bolt_cutter.timer = 1
	self.take_painting = {}
	self.take_painting.text_id = "hud_take_painting"
	self.take_painting.action_text_id = "hud_action_taking_painting"
	self.take_painting.start_active = false
	self.take_painting.interact_distance = 250
	self.take_painting.timer = 2.5
	self.take_painting.sound_start = "sto_painting"
	self.take_painting.sound_interupt = "sto_painting_cancel"
	self.take_painting.sound_done = "sto_painting_finish"
	self.take_painting_active = deep_clone(self.take_painting)
	self.take_painting_active = {}
	self.take_painting_active.text_id = "hud_take_painting"
	self.take_painting_active.action_text_id = "hud_action_taking_painting"
	self.take_painting_active.interact_distance = 250
	self.take_painting_active.timer = 1.5
	self.take_painting_active.sound_start = nil
	self.take_painting_active.sound_interupt = nil
	self.take_painting_active.sound_done = "sto_pick_up_painting"
	self.take_painting_active.start_active = true
	self.take_bonds = {}
	self.take_bonds.text_id = "hud_take_bonds"
	self.take_bonds.action_text_id = "hud_action_taking_bonds"
	self.take_bonds.start_active = false
	self.take_bonds.timer = 1
	self.take_bonds.blocked_hint = "carry_block"
	self.take_tank_crank = {}
	self.take_tank_crank.text_id = "hud_take_tank_crank"
	self.take_tank_crank.start_active = false
	self.take_tank_crank.interact_distance = 250
	self.take_tank_crank.special_equipment_block = "tank_crank"
	self.start_the_tank = {}
	self.start_the_tank.text_id = "hud_start_tank"
	self.start_the_tank.action_text_id = "hud_action_starting_tank"
	self.start_the_tank.start_active = false
	self.start_the_tank.interact_distance = 250
	self.start_the_tank.timer = 5
	self.take_tank_shells = {}
	self.take_tank_shells.text_id = "hud_take_tank_shells"
	self.take_tank_shells.action_text_id = "hud_action_taking_tank_shells"
	self.take_tank_shells.start_active = false
	self.take_tank_shells.interact_distance = 250
	self.take_tank_shells.timer = 5
	self.turn_searchlight = {}
	self.turn_searchlight.text_id = "hud_turn_searchlight"
	self.turn_searchlight.action_text_id = "hud_action_turning_searchlight"
	self.turn_searchlight.start_active = false
	self.turn_searchlight.interact_distance = 250
	self.turn_searchlight.sound_start = "searchlight_interaction_loop_start"
	self.turn_searchlight.sound_done = "searchlight_interaction_loop_stop"
	self.turn_searchlight.sound_interupt = "searchlight_interaction_loop_stop"
	self.turn_searchlight.timer = 2.5
	self.take_dynamite_bag = {}
	self.take_dynamite_bag.text_id = "hud_int_take_dynamite"
	self.take_dynamite_bag.action_text_id = "hud_action_taking_dynamite"
	self.take_dynamite_bag.timer = 2
	self.take_dynamite_bag.interact_distance = 250
	self.take_dynamite_bag.icon = "equipment_dynamite"
	self.take_dynamite_bag.special_equipment_block = "dynamite_bag"
	self.take_dynamite_bag.sound_done = "pickup_dynamite"
	self.plant_dynamite_bag = {}
	self.plant_dynamite_bag.text_id = "hud_plant_dynamite_bag"
	self.plant_dynamite_bag.action_text_id = "hud_action_planting_dynamite_bag"
	self.plant_dynamite_bag.interact_distance = 250
	self.plant_dynamite_bag.timer = 5
	self.plant_dynamite_bag.equipment_text_id = "hint_no_dynamite_bag"
	self.plant_dynamite_bag.upgrade_timer_multipliers = {
		{
			upgrade = "dynamite_plant_multiplier",
			category = "interaction"
		}
	}
	self.plant_dynamite_bag.special_equipment = "dynamite_bag"
	self.plant_dynamite_bag.start_active = false
	self.plant_dynamite_bag.equipment_consume = true
	self.plant_dynamite_bag.sound_start = "dynamite_placing"
	self.plant_dynamite_bag.sound_done = "dynamite_placed"
	self.plant_dynamite_bag.sound_interupt = "stop_dynamite_placing"
	self.flaktrum_raid_start = {}
	self.flaktrum_raid_start.text_id = "hud_start_flaktrum_raid"
	self.flaktrum_raid_start.action_text_id = "hud_action_starting_flaktrum_raid"
	self.flaktrum_raid_start.interact_distance = 200
	self.flaktrum_raid_start.timer = 1
	self.take_cable = {}
	self.take_cable.text_id = "hud_take_cable"
	self.take_cable.action_text_id = "hud_action_taking_cable"
	self.take_cable.interact_distance = 200
	self.take_cable.timer = 2
	self.take_cable.force_update_position = true
	self.take_cable.sound_done = "el_cable_connected"
	self.take_cable.sound_start = "el_cable_connect"
	self.take_cable.sound_interupt = "el_cable_connect_stop"
	self.open_cargo_door = {}
	self.open_cargo_door.text_id = "hud_int_open_cargo_door"
	self.open_cargo_door.action_text_id = "hud_action_opening_cargo_door"
	self.open_cargo_door.interact_distance = 200
	self.close_cargo_door = {}
	self.close_cargo_door.text_id = "hud_int_close_cargo_door"
	self.close_cargo_door.action_text_id = "hud_action_closing_cargo_door"
	self.close_cargo_door.interact_distance = 200
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
	self.hold_couple_wagon = {}
	self.hold_couple_wagon.text_id = "hud_int_hold_couple_wagon"
	self.hold_couple_wagon.action_text_id = "hud_action_coupling_wagon"
	self.hold_couple_wagon.start_active = false
	self.hold_couple_wagon.interact_distance = 300
	self.hold_couple_wagon.timer = 0.5
	self.hold_decouple_wagon = deep_clone(self.hold_couple_wagon)
	self.hold_decouple_wagon.text_id = "hud_int_hold_decouple_wagon"
	self.hold_decouple_wagon.action_text_id = "hud_action_decoupling_wagon"
	self.hold_pull_lever = {}
	self.hold_pull_lever.text_id = "hud_int_hold_pull_lever"
	self.hold_pull_lever.action_text_id = "hud_action_pulling_lever"
	self.hold_pull_lever.start_active = false
	self.hold_pull_lever.interact_distance = 150
	self.hold_pull_lever.timer = 0.5
	self.hold_pull_lever.force_update_position = true
	self.hold_pull_lever.sound_start = "rail_switch_interaction_loop_start"
	self.hold_pull_lever.sound_done = "rail_switch_interaction_loop_stop"
	self.hold_pull_lever.sound_interupt = "rail_switch_interaction_loop_stop"
	self.hold_get_gear = {}
	self.hold_get_gear.text_id = "hud_int_hold_get_gear"
	self.hold_get_gear.action_text_id = "hud_action_get_gear"
	self.hold_get_gear.start_active = false
	self.hold_get_gear.interact_distance = 300
	self.hold_get_gear.timer = 1.5
	self.hold_open_crate_tut = {}
	self.hold_open_crate_tut.text_id = "hud_int_hold_get_gear"
	self.hold_open_crate_tut.action_text_id = "hud_action_get_gear"
	self.hold_open_crate_tut.start_active = false
	self.hold_open_crate_tut.interact_distance = 300
	self.hold_open_crate_tut.timer = 1.5
	self.hold_open_crate_tut.sound_start = "camp_unpack_stuff"
	self.hold_open_crate_tut.sound_done = "camp_unpacked"
	self.hold_get_gear_short_range = {}
	self.hold_get_gear_short_range.text_id = "hud_int_hold_get_gear"
	self.hold_get_gear_short_range.action_text_id = "hud_action_get_gear"
	self.hold_get_gear_short_range.start_active = false
	self.hold_get_gear_short_range.interact_distance = 300
	self.hold_get_gear_short_range.timer = 1.5
	self.hold_remove_blocker = {}
	self.hold_remove_blocker.text_id = "hud_int_hold_remove_blocker"
	self.hold_remove_blocker.action_text_id = "hud_action_removing_blocker"
	self.hold_remove_blocker.start_active = false
	self.hold_remove_blocker.interact_distance = 250
	self.hold_remove_blocker.timer = 1
	self.hold_remove_blocker.axis = "y"
	self.hold_remove_blocker.sound_start = "loco_blocker_remove_start"
	self.hold_remove_blocker.sound_done = "loco_blocker_remove_stop"
	self.hold_remove_blocker.sound_interupt = "loco_blocker_remove_stop"
	self.hold_open_hatch = {}
	self.hold_open_hatch.text_id = "hud_open_hatch"
	self.hold_open_hatch.action_text_id = "hud_action_opening_hatch"
	self.hold_open_hatch.timer = 0.5
	self.hold_open_hatch.start_active = false
	self.hold_open_hatch.sound_done = "open_hatch_done"
	self.take_landmines = {}
	self.take_landmines.text_id = "hud_take_landmines"
	self.take_landmines.action_text_id = "hud_action_taking_landmines"
	self.take_landmines.timer = 3
	self.take_landmines.start_active = false
	self.take_landmines.interact_distance = 250
	self.take_landmines.sound_start = "cvy_pick_up_mine"
	self.take_landmines.sound_interupt = "cvy_pick_up_mine_cancel_01"
	self.take_landmines.sound_done = "cvy_pick_up_mine_finish_01"
	self.hold_take_wine_crate = {}
	self.hold_take_wine_crate.text_id = "hud_take_wine_crate"
	self.hold_take_wine_crate.action_text_id = "hud_action_taking_wine_crate"
	self.hold_take_wine_crate.timer = 1
	self.hold_take_wine_crate.start_active = true
	self.hold_take_wine_crate.interact_distance = 250
	self.hold_take_cigar_crate = {}
	self.hold_take_cigar_crate.text_id = "hud_take_cigar_crate"
	self.hold_take_cigar_crate.action_text_id = "hud_action_taking_cigar_crate"
	self.hold_take_cigar_crate.timer = 1
	self.hold_take_cigar_crate.start_active = true
	self.hold_take_cigar_crate.interact_distance = 250
	self.hold_take_chocolate_box = {}
	self.hold_take_chocolate_box.text_id = "hud_take_chocolate_box"
	self.hold_take_chocolate_box.action_text_id = "hud_action_taking_chocolate_box"
	self.hold_take_chocolate_box.timer = 1
	self.hold_take_chocolate_box.start_active = true
	self.hold_take_chocolate_box.interact_distance = 250
	self.hold_take_crucifix = {}
	self.hold_take_crucifix.text_id = "hud_take_crucifix"
	self.hold_take_crucifix.action_text_id = "hud_action_taking_crucifix"
	self.hold_take_crucifix.timer = 1
	self.hold_take_crucifix.start_active = true
	self.hold_take_crucifix.interact_distance = 250
	self.hold_take_baptismal_font = {}
	self.hold_take_baptismal_font.text_id = "hud_take_baptismal_font"
	self.hold_take_baptismal_font.action_text_id = "hud_action_taking_baptismal_font"
	self.hold_take_baptismal_font.timer = 1
	self.hold_take_baptismal_font.start_active = true
	self.hold_take_baptismal_font.interact_distance = 250
	self.hold_take_religious_figurine = {}
	self.hold_take_religious_figurine.text_id = "hud_take_religious_figurine"
	self.hold_take_religious_figurine.action_text_id = "hud_action_taking_religious_figurine"
	self.hold_take_religious_figurine.timer = 1
	self.hold_take_religious_figurine.start_active = true
	self.hold_take_religious_figurine.interact_distance = 250
	self.hold_take_candelabrum = {}
	self.hold_take_candelabrum.text_id = "hud_take_candelabrum"
	self.hold_take_candelabrum.action_text_id = "hud_action_taking_candelabrum"
	self.hold_take_candelabrum.timer = 1
	self.hold_take_candelabrum.start_active = true
	self.hold_take_candelabrum.interact_distance = 250
	self.place_landmine = {}
	self.place_landmine.text_id = "hud_place_landmine"
	self.place_landmine.action_text_id = "hud_action_placing_landmine"
	self.place_landmine.timer = 3
	self.place_landmine.start_active = false
	self.place_landmine.interact_distance = 250
	self.place_landmine.equipment_text_id = "hint_no_landmines"
	self.place_landmine.special_equipment = "landmine"
	self.place_landmine.equipment_consume = true
	self.hold_start_locomotive = {}
	self.hold_start_locomotive.text_id = "hud_int_signal_driver"
	self.hold_start_locomotive.action_text_id = "hud_action_signaling_driver"
	self.hold_start_locomotive.timer = 1
	self.hold_start_locomotive.start_active = false
	self.free_radio_tehnician = {}
	self.free_radio_tehnician.text_id = "hud_untie_tehnician"
	self.free_radio_tehnician.action_text_id = "hud_action_untying_technician"
	self.free_radio_tehnician.timer = 5
	self.free_radio_tehnician.start_active = false
	self.free_radio_tehnician.interact_distance = 250
	self.free_radio_tehnician.sound_start = "untie_rope_loop_interact_start"
	self.free_radio_tehnician.sound_done = "untie_rope_interact_end"
	self.free_radio_tehnician.sound_interupt = "untie_rope_loop_interrupt"
	self.rig_dynamite = {}
	self.rig_dynamite.text_id = "hud_int_rig_dynamite"
	self.rig_dynamite.action_text_id = "hud_action_rig_dynamite"
	self.rig_dynamite.timer = 5
	self.rig_dynamite.interact_distance = 250
	self.rig_dynamite.upgrade_timer_multipliers = {
		{
			upgrade = "dynamite_plant_multiplier",
			category = "interaction"
		}
	}
	self.rig_dynamite.sound_start = "dynamite_placing"
	self.rig_dynamite.sound_done = "dynamite_placed"
	self.rig_dynamite.sound_interupt = "stop_dynamite_placing"
	self.rig_dynamite.special_equipment = "dynamite"
	self.rig_dynamite.equipment_consume = true
	self.hold_pull_down_ladder = {}
	self.hold_pull_down_ladder.text_id = "hud_int_pull_down_ladder"
	self.hold_pull_down_ladder.action_text_id = "hud_action_pull_down_ladder"
	self.hold_pull_down_ladder.timer = 2
	self.hold_pull_down_ladder.sound_done = "ladder_pull"
	self.hold_pull_down_ladder.interact_distance = 250
	self.detonate_the_dynamite = {}
	self.detonate_the_dynamite.text_id = "hud_int_detonate_the_dynamite"
	self.detonate_the_dynamite.action_text_id = "hud_action_detonate_the_dynamite"
	self.detonate_the_dynamite.timer = 0
	self.detonate_the_dynamite.sound_done = "bridge_switch_start"
	self.detonate_the_dynamite.interact_distance = 250
	self.detonate_the_dynamite_panel = {}
	self.detonate_the_dynamite_panel.text_id = "hud_int_detonate_the_dynamite"
	self.detonate_the_dynamite_panel.action_text_id = "hud_action_detonate_the_dynamite"
	self.detonate_the_dynamite_panel.timer = 0
	self.detonate_the_dynamite_panel.sound_done = "bridge_switch_start"
	self.detonate_the_dynamite_panel.interact_distance = 110
	self.detonate_the_dynamite_panel.start_active = false
	self.generic_press_panel = deep_clone(self.detonate_the_dynamite_panel)
	self.generic_press_panel.text_id = "hud_hold_open_barrier"
	self.generic_press_panel.action_text_id = "hud_action_opening_barrier"
	self.hold_call_boat_driver = {}
	self.hold_call_boat_driver.text_id = "hud_int_hold_call_boat_driver"
	self.hold_call_boat_driver.action_text_id = "hud_action_hold_call_boat_driver"
	self.hold_call_boat_driver.timer = 3
	self.hold_call_boat_driver.sound_done = ""
	self.hold_call_boat_driver.interact_distance = 250
	self.cut_cage_lock = {}
	self.cut_cage_lock.text_id = "hud_cut_cage_lock"
	self.cut_cage_lock.action_text_id = "hud_action_cutting_cage_lock"
	self.cut_cage_lock.special_equipment = "blow_torch_fuel"
	self.cut_cage_lock.equipment_text_id = "hud_int_need_blow_torch_fuel"
	self.cut_cage_lock.equipment_consume = true
	self.cut_cage_lock.start_active = false
	self.cut_cage_lock.timer = 3
	self.vhc_move_wagon = {}
	self.vhc_move_wagon.text_id = "hud_int_press_move_wagon"
	self.vhc_move_wagon.force_update_position = true
	self.move_crane = {}
	self.move_crane.text_id = "hud_int_press_move_crane"
	self.search_scrap_parts = {}
	self.search_scrap_parts.text_id = "hud_search_scrap_parts"
	self.search_scrap_parts.action_text_id = "hud_action_searching_scrap_parts"
	self.search_scrap_parts.start_active = true
	self.search_scrap_parts.timer = 5
	self.hold_attach_cable = {}
	self.hold_attach_cable.text_id = "hud_int_hold_attach_cable"
	self.hold_attach_cable.action_text_id = "hud_action_attaching_cable"
	self.hold_attach_cable.start_active = false
	self.hold_attach_cable.timer = 0.5
	self.hold_detach_cable = {}
	self.hold_detach_cable.text_id = "hud_int_hold_detach_cable"
	self.hold_detach_cable.action_text_id = "hud_action_detaching_cable"
	self.hold_detach_cable.start_active = false
	self.hold_detach_cable.timer = 0.5
	self.hold_detach_cable.sound_start = "cutting_cable_loop_start"
	self.hold_detach_cable.sound_interupt = "cutting_cable_loop_interrupt"
	self.hold_detach_cable.sound_done = "cutting_cable_loop_stop"
	self.take_code_book = {}
	self.take_code_book.text_id = "hud_take_code_book"
	self.take_code_book.action_text_id = "hud_action_taking_code_book"
	self.take_code_book.special_equipment_block = "code_book"
	self.take_code_book.start_active = false
	self.take_code_book.timer = 1
	self.take_code_book.sound_done = "codebook_pickup_done"
	self.take_code_book_active = deep_clone(self.take_code_book)
	self.take_code_book_active.start_active = true
	self.take_code_book_empty = {}
	self.take_code_book_empty.text_id = "hud_take_code_book"
	self.take_code_book_empty.action_text_id = "hud_action_taking_code_book"
	self.take_code_book_empty.start_active = false
	self.take_code_book_empty.timer = 2
	self.take_code_book_empty.sound_done = "codebook_pickup_done"
	self.hold_ignite_flag = {}
	self.hold_ignite_flag.text_id = "hud_int_hold_ignite_flag"
	self.hold_ignite_flag.action_text_id = "hud_action_igniting_flag"
	self.hold_ignite_flag.timer = 2
	self.hold_ignite_flag.start_active = false
	self.hold_ignite_flag.axis = "y"
	self.hold_ignite_flag.sound_start = "flag_burn_interaction_start"
	self.hold_ignite_flag.sound_interupt = "flag_burn_interaction_interrupt"
	self.hold_ignite_flag.sound_done = "flag_burn_interaction_success"
	self.train_yard_open_door = {}
	self.train_yard_open_door.text_id = "hud_open_door_instant"
	self.train_yard_open_door.start_active = false
	self.train_yard_open_door.interact_distance = 250
	self.train_yard_open_door.sound_done = "generic_wood_door_opened"
	self.hold_take_canister = {}
	self.hold_take_canister.text_id = "hud_int_hold_take_canister"
	self.hold_take_canister.action_text_id = "hud_action_taking_canister"
	self.hold_take_canister.start_active = false
	self.hold_take_canister.timer = 0.5
	self.hold_take_canister.blocked_hint = "hud_hint_carry_block"
	self.hold_take_canister.sound_done = "canister_pickup"
	self.hold_take_crate_canisters = {}
	self.hold_take_crate_canisters.text_id = "hud_int_hold_take_crate_canisters"
	self.hold_take_crate_canisters.action_text_id = "hud_action_taking_crate_canisters"
	self.hold_take_crate_canisters.start_active = false
	self.hold_take_crate_canisters.timer = 0.5
	self.hold_take_empty_canister = deep_clone(self.hold_take_canister)
	self.hold_take_empty_canister.text_id = "hud_int_hold_empty_take_canister"
	self.hold_take_empty_canister.action_text_id = "hud_action_taking_empty_canister"
	self.hold_take_empty_canister.special_equipment_block = "empty_fuel_canister"
	self.hold_place_canister = {}
	self.hold_place_canister.text_id = "hud_int_hold_place_canister"
	self.hold_place_canister.action_text_id = "hud_action_placing_canister"
	self.hold_place_canister.equipment_text_id = "hud_hint_no_canister"
	self.hold_place_canister.special_equipment = "fuel_canister"
	self.hold_place_canister.timer = 0.5
	self.hold_place_canister.start_active = false
	self.hold_place_canister.equipment_consume = true
	self.hold_place_canister.sound_done = "canister_pickup"
	self.hold_fill_canister = {}
	self.hold_fill_canister.text_id = "hud_int_hold_fill_canister"
	self.hold_fill_canister.action_text_id = "hud_action_filling_canister"
	self.hold_fill_canister.equipment_text_id = "hud_hint_no_canister"
	self.hold_fill_canister.special_equipment = "empty_fuel_canister"
	self.hold_fill_canister.timer = 3
	self.hold_fill_canister.start_active = false
	self.hold_fill_canister.sound_start = "canister_fill_loop_start"
	self.hold_fill_canister.sound_interupt = "canister_fill_loop_stop"
	self.hold_fill_canister.sound_done = "canister_fill_loop_stop"
	self.hold_fill_jeep = {}
	self.hold_fill_jeep.text_id = "hud_int_hold_fill_jeep"
	self.hold_fill_jeep.action_text_id = "hud_action_filling_jeep"
	self.hold_fill_jeep.equipment_text_id = "hud_hint_no_gasoline"
	self.hold_fill_jeep.special_equipment = "gas_x4"
	self.hold_fill_jeep.timer = 3
	self.hold_fill_jeep.start_active = false
	self.hold_fill_jeep.equipment_consume = true
	self.hold_fill_jeep.sound_start = "car_refuel_start"
	self.hold_fill_jeep.sound_interupt = "car_refuel_stop"
	self.hold_fill_jeep.sound_done = "car_refuel_stop"
	self.hold_fill_barrel_gasoline = deep_clone(self.hold_fill_jeep)
	self.hold_fill_barrel_gasoline.text_id = "hud_int_hold_fill_barrel_gasoline"
	self.hold_fill_barrel_gasoline.action_text_id = "hud_action_filling_barrel"
	self.hold_fill_barrel_gasoline.equipment_text_id = "hud_hint_no_gasoline"
	self.hold_fill_barrel_gasoline.special_equipment = "fuel_canister"
	self.give_tools_franz = {}
	self.give_tools_franz.text_id = "hud_give_tools_franz"
	self.give_tools_franz.action_text_id = "hud_action_giving_tools_franz"
	self.give_tools_franz.special_equipment = "repair_tools"
	self.give_tools_franz.equipment_text_id = "hud_no_tools_franz"
	self.give_tools_franz.equipment_consume = true
	self.give_tools_franz.start_active = false
	self.give_tools_franz.timer = 2
	self.give_tools_franz.sound_done = "toolbox_pass"
	self.hold_reinforce_door = {}
	self.hold_reinforce_door.text_id = "hud_int_hold_reinforce_door"
	self.hold_reinforce_door.action_text_id = "hud_action_reinforcing_door"
	self.hold_reinforce_door.timer = 0.5
	self.hold_reinforce_door.start_active = false
	self.hold_reinforce_door.sound_start = "reinforce_door_interact"
	self.hold_reinforce_door.sound_done = "reinforce_door_success"
	self.hold_reinforce_door.sound_interupt = "reinforce_door_interact_interrupt"
	self.hold_take_recording_device = {}
	self.hold_take_recording_device.text_id = "hud_int_hold_take_recording_device"
	self.hold_take_recording_device.action_text_id = "hud_action_taking_recording_device"
	self.hold_take_recording_device.start_active = false
	self.hold_take_recording_device.timer = 0.5
	self.hold_take_recording_device.sound_done = "recording_device_pickup"
	self.hold_place_recording_device = {}
	self.hold_place_recording_device.text_id = "hud_int_hold_place_recording_device"
	self.hold_place_recording_device.action_text_id = "hud_action_placing_recording_device"
	self.hold_place_recording_device.equipment_text_id = "hud_hint_no_recording_device"
	self.hold_place_recording_device.special_equipment = "recording_device"
	self.hold_place_recording_device.timer = 0.5
	self.hold_place_recording_device.start_active = false
	self.hold_place_recording_device.equipment_consume = true
	self.hold_place_recording_device.sound_done = "recording_device_placement"
	self.hold_connect_cable = {}
	self.hold_connect_cable.text_id = "hud_int_hold_connect_cable"
	self.hold_connect_cable.action_text_id = "hud_action_connecting_cable"
	self.hold_connect_cable.timer = 0.5
	self.hold_connect_cable.start_active = false
	self.hold_connect_cable.sound_done = "el_cable_connected"
	self.press_collect_reward = {}
	self.press_collect_reward.text_id = "hud_int_collect_reward"
	self.press_collect_reward.start_active = false
	self.press_collect_reward.interact_distance = 500
	self.start_recording = {}
	self.start_recording.text_id = "hud_int_start_recording"
	self.start_recording.start_active = false
	self.hold_place_codebook = {}
	self.hold_place_codebook.text_id = "hud_int_hold_place_codebook"
	self.hold_place_codebook.action_text_id = "hud_action_placing_codebook"
	self.hold_place_codebook.equipment_text_id = "hud_hint_no_codebook"
	self.hold_place_codebook.special_equipment = "code_book"
	self.hold_place_codebook.timer = 0.5
	self.hold_place_codebook.start_active = false
	self.hold_place_codebook.equipment_consume = true
	self.hold_place_codebook.sound_done = "codebook_pickup_done"
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
	self.hold_repair_fusebox = {}
	self.hold_repair_fusebox.text_id = "hud_int_hold_repair_fusebox"
	self.hold_repair_fusebox.action_text_id = "hud_action_repairing_fusebox"
	self.hold_repair_fusebox.timer = 5
	self.hold_repair_fusebox.start_active = false
	self.hold_repair_fusebox.axis = "x"
	self.hold_repair_fusebox.sound_start = "fusebox_repair_interact_start"
	self.hold_repair_fusebox.sound_interupt = "fusebox_repair_interrupt"
	self.hold_repair_fusebox.sound_done = "fusebox_repair_success"
	self.hold_place_codemachine = {}
	self.hold_place_codemachine.text_id = "hud_int_hold_place_codemachine"
	self.hold_place_codemachine.action_text_id = "hud_action_placing_codemachine"
	self.hold_place_codemachine.equipment_text_id = "hud_hint_no_codemachine"
	self.hold_place_codemachine.special_equipment = "enigma"
	self.hold_place_codemachine.timer = 0.5
	self.hold_place_codemachine.start_active = false
	self.hold_place_codemachine.equipment_consume = true
	self.hold_place_codemachine.sound_done = "recording_device_placement"
	self.pour_gas_generator = {}
	self.pour_gas_generator.text_id = "hud_pour_gas_generator"
	self.pour_gas_generator.action_text_id = "hud_action_pouring_gas_generator"
	self.pour_gas_generator.equipment_text_id = "hud_hint_no_canister"
	self.pour_gas_generator.special_equipment = "fuel_canister"
	self.pour_gas_generator.timer = 5
	self.pour_gas_generator.start_active = false
	self.pour_gas_generator.equipment_consume = true
	self.pour_gas_generator.sound_start = "canister_fill_loop_start"
	self.pour_gas_generator.sound_interupt = "canister_fill_loop_stop"
	self.start_generator = {}
	self.start_generator.text_id = "hud_start_generator"
	self.start_generator.start_active = false
	self.load_shell = {}
	self.load_shell.text_id = "hud_load_shell"
	self.load_shell.action_text_id = "hud_action_loading_shell"
	self.load_shell.timer = 2
	self.load_shell.start_active = false
	self.load_shell.interact_dont_interupt_on_distance = true
	self.load_shell_use_carry = deep_clone(self.load_shell)
	self.load_shell_use_carry.required_carry = {
		"flak_shell",
		"flak_shell_explosive",
		"flak_shell_shot_explosive"
	}
	self.load_shell_use_carry.carry_text_id = "needs_carry_flak_shell"
	self.load_shell_use_carry.carry_consume = true
	self.place_shell_use_carry = deep_clone(self.load_shell)
	self.place_shell_use_carry.text_id = "hud_place_shell"
	self.place_shell_use_carry.action_text_id = "hud_action_placing_shell"
	self.place_shell_use_carry.required_carry = {
		"flak_shell",
		"flak_shell_explosive",
		"flak_shell_shot_explosive"
	}
	self.place_shell_use_carry.carry_text_id = "needs_carry_flak_shell"
	self.place_shell_use_carry.carry_consume = true
	self.place_shell_use_carry.timer = 1
	self.pku_empty_bucket = {}
	self.pku_empty_bucket.text_id = "hud_int_take_empty_bucket"
	self.pku_empty_bucket.special_equipment_block = "empty_bucket"
	self.pku_empty_bucket.timer = 0.5
	self.pku_empty_bucket.start_active = false
	self.pku_fill_bucket = {}
	self.pku_fill_bucket.text_id = "hud_int_fill_bucket"
	self.pku_fill_bucket.equipment_text_id = "hud_hint_need_empty_bucket"
	self.pku_fill_bucket.special_equipment_block = "full_bucket"
	self.pku_fill_bucket.special_equipment = "empty_bucket"
	self.pku_fill_bucket.timer = 0.5
	self.pku_fill_bucket.start_active = false
	self.pku_fill_bucket.equipment_consume = true
	self.hold_give_full_bucket = {}
	self.hold_give_full_bucket.text_id = "hud_int_hold_give_full_bucket"
	self.hold_give_full_bucket.action_text_id = "hud_action_giving_full_bucket"
	self.hold_give_full_bucket.equipment_text_id = "hud_hint_need_full_bucket"
	self.hold_give_full_bucket.special_equipment = "full_bucket"
	self.hold_give_full_bucket.timer = 0.5
	self.hold_give_full_bucket.start_active = false
	self.hold_give_full_bucket.equipment_consume = true
	self.hold_contact_mrs_white = {}
	self.hold_contact_mrs_white.text_id = "hud_int_hold_contact_mrs_white"
	self.hold_contact_mrs_white.action_text_id = "hud_action_contacting_mrs_white"
	self.hold_contact_mrs_white.timer = 0.5
	self.hold_contact_mrs_white.start_active = false
	self.hold_contact_boat_driver = deep_clone(self.hold_contact_mrs_white)
	self.hold_contact_boat_driver.text_id = "hud_int_hold_contact_boat_driver"
	self.hold_contact_boat_driver.action_text_id = "hud_action_contacting_boat_driver"
	self.hold_request_dynamite_airdrop = deep_clone(self.hold_contact_mrs_white)
	self.hold_request_dynamite_airdrop.text_id = "hud_int_hold_request_dynamite_airdrop"
	self.hold_request_dynamite_airdrop.action_text_id = "hud_action_requesting_airdrop"
	self.disable_flare = {}
	self.disable_flare.text_id = "hud_int_disable_flare"
	self.disable_flare.start_active = false
	self.take_spiked_wine = {}
	self.take_spiked_wine.text_id = "hud_take_spiked_wine"
	self.take_spiked_wine.action_text_id = "hud_action_taking_spiked_wine"
	self.take_spiked_wine.start_active = false
	self.take_spiked_wine.timer = 1
	self.take_code_machine_part = {}
	self.take_code_machine_part.text_id = "hud_take_code_machine_part"
	self.take_code_machine_part.start_active = true
	self.take_code_machine_part.sound_done = "recording_device_placement"
	self.hold_start_plane = {}
	self.hold_start_plane.text_id = "hud_hold_start_plane"
	self.hold_start_plane.action_text_id = "hud_action_starting_plane"
	self.hold_start_plane.start_active = false
	self.hold_start_plane.timer = 0.5
	self.take_enigma = {}
	self.take_enigma.text_id = "hud_take_enigma"
	self.take_enigma.action_text_id = "hud_action_taking_enigma"
	self.take_enigma.special_equipment_block = "enigma"
	self.take_enigma.start_active = false
	self.take_enigma.timer = 3
	self.take_enigma.sound_done = "enigma_machine_pickup"
	self.wake_up_spy = {}
	self.wake_up_spy.text_id = "hud_wake_up_spy"
	self.wake_up_spy.action_text_id = "hud_action_waking_up_spy"
	self.wake_up_spy.start_active = false
	self.wake_up_spy.timer = 5
	self.carry_spy = {}
	self.carry_spy.text_id = "hud_carry_spy"
	self.carry_spy.action_text_id = "hud_action_carring_spy"
	self.carry_spy.start_active = false
	self.carry_spy.timer = 3
	self.carry_spy.sound_done = "spy_pickup"
	self.carry_drop_spy = deep_clone(self.carry_drop)
	self.carry_drop_spy.text_id = "hud_carry_spy"
	self.carry_drop_spy.action_text_id = "hud_action_carring_spy"
	self.carry_drop_spy.timer = 3
	self.carry_drop_spy.sound_done = "spy_pickup"
	self.hold_open_barrier = {}
	self.hold_open_barrier.text_id = "hud_hold_open_barrier"
	self.hold_open_barrier.action_text_id = "hud_action_opening_barrier"
	self.hold_open_barrier.start_active = false
	self.hold_open_barrier.timer = 0.5
	self.shut_off_valve = {}
	self.shut_off_valve.text_id = "hud_shut_off_valve"
	self.shut_off_valve.action_text_id = "hud_action_shutting_off_valve"
	self.shut_off_valve.start_active = false
	self.shut_off_valve.timer = 3
	self.shut_off_valve.sound_start = "open_drop_pod_start"
	self.shut_off_valve.sound_interupt = "open_drop_pod_interrupt"
	self.shut_off_valve.sound_done = "elevator_switch"
	self.turn_on_valve = {}
	self.turn_on_valve.text_id = "hud_turn_on_valve"
	self.turn_on_valve.action_text_id = "hud_action_turning_on_valve"
	self.turn_on_valve.start_active = false
	self.turn_on_valve.timer = 3
	self.turn_on_valve.sound_start = "disconnect_hose_start"
	self.turn_on_valve.sound_interupt = "disconnect_hose_interrupt"
	self.turn_on_valve.sound_done = "disconnect_hose_interrupt"
	self.destroy_valve = {}
	self.destroy_valve.text_id = "hud_desroy_valve"
	self.destroy_valve.action_text_id = "hud_action_destroying_valve"
	self.destroy_valve.start_active = false
	self.destroy_valve.timer = 3
	self.destroy_valve.sound_start = "gas_controller_destroy_interaction_start"
	self.destroy_valve.sound_interupt = "gas_controller_destroy_interaction_stop"
	self.destroy_valve.sound_done = "gas_controller_destroy"
	self.replace_flag = {}
	self.replace_flag.text_id = "hud_replace_flag"
	self.replace_flag.action_text_id = "hud_action_replacing_flag"
	self.replace_flag.start_active = false
	self.replace_flag.timer = 3
	self.replace_flag.sound_done = "flag_replace"
	self.open_container = {}
	self.open_container.text_id = "hud_open_container"
	self.open_container.action_text_id = "hud_action_opening_container"
	self.open_container.start_active = false
	self.open_container.timer = 1.5
	self.close_container = {}
	self.close_container.text_id = "hud_close_container"
	self.close_container.action_text_id = "hud_action_closing_container"
	self.close_container.start_active = false
	self.close_container.timer = 3
	self.press_take_dogtags = {}
	self.press_take_dogtags.text_id = "hud_int_press_take_dogtags"
	self.press_take_dogtags.sound_done = "dogtags_pickup"
	self.press_take_dogtags.start_active = true
	self.press_take_dogtags.timer = 0
	self.hold_take_dogtags = {}
	self.hold_take_dogtags.text_id = "hud_int_hold_take_dogtags"
	self.hold_take_dogtags.action_text_id = "hud_action_taking_dogtags"
	self.hold_take_dogtags.sound_done = "dogtags_pickup"
	self.hold_take_dogtags.start_active = true
	self.hold_take_dogtags.timer = 0.5
	self.hold_take_loot = {}
	self.hold_take_loot.text_id = "hud_int_hold_take_loot"
	self.hold_take_loot.action_text_id = "hud_action_taking_loot"
	self.hold_take_loot.sound_done = "pickup_tools"
	self.hold_take_loot.start_active = true
	self.hold_take_loot.timer = 0.5
	self.press_take_loot = {}
	self.press_take_loot.text_id = "hud_int_press_take_loot"
	self.press_take_loot.sound_done = "pickup_tools"
	self.press_take_loot.start_active = true
	self.press_take_loot.timer = 0
	self.regular_cache_box = {}
	self.regular_cache_box.text_id = "hud_int_regular_cache_box"
	self.regular_cache_box.action_text_id = "hud_action_taking_cache_loot"
	self.regular_cache_box.sound_done = "pickup_tools"
	self.regular_cache_box.start_active = true
	self.disconnect_hose = {}
	self.disconnect_hose.text_id = "hud_disconnect_hose"
	self.disconnect_hose.action_text_id = "hud_action_disconnecting_hose"
	self.disconnect_hose.start_active = false
	self.disconnect_hose.timer = 3
	self.disconnect_hose.sound_start = "disconnect_hose_start"
	self.disconnect_hose.sound_interupt = "disconnect_hose_interrupt"
	self.disconnect_hose.sound_done = "disconnect_hose_success"
	self.push_truck_bridge = {}
	self.push_truck_bridge.text_id = "hud_push_truck_bridge"
	self.push_truck_bridge.action_text_id = "hud_action_pushing_truck_bridge"
	self.push_truck_bridge.start_active = false
	self.push_truck_bridge.timer = 1
	self.connect_tank_truck = {}
	self.connect_tank_truck.text_id = "hud_connect_tank_truck"
	self.connect_tank_truck.action_text_id = "hud_action_connecting_tank_truck"
	self.connect_tank_truck.start_active = false
	self.connect_tank_truck.timer = 3
	self.connect_tank_truck.sound_start = "fuel_tank_connect"
	self.connect_tank_truck.sound_interupt = "fuel_tank_connect_stop"
	self.take_portable_radio = {}
	self.take_portable_radio.text_id = "hud_int_take_portable_radio"
	self.take_portable_radio.action_text_id = "hud_action_taking_portable_radio"
	self.take_portable_radio.timer = 2
	self.take_portable_radio.interact_distance = 250
	self.take_portable_radio.special_equipment_block = "portable_radio"
	self.sii_change_channel = deep_clone(self.sii_play_recordings)
	self.sii_change_channel.text_id = "hud_int_change_channel"
	self.sii_change_channel.action_text_id = "hud_action_changing_channel"
	self.plant_portable_radio = {}
	self.plant_portable_radio.text_id = "hud_plant_portable_radio"
	self.plant_portable_radio.action_text_id = "hud_action_planting_portable_radio"
	self.plant_portable_radio.interact_distance = 250
	self.plant_portable_radio.timer = 2
	self.plant_portable_radio.equipment_text_id = "hint_no_portable_radio"
	self.plant_portable_radio.special_equipment = "portable_radio"
	self.plant_portable_radio.start_active = false
	self.plant_portable_radio.equipment_consume = true
	self.plant_portable_radio.sound_start = "dynamite_placing"
	self.plant_portable_radio.sound_done = "dynamite_placed"
	self.plant_portable_radio.sound_interupt = "stop_dynamite_placing"
	self.set_fire_barrel = {}
	self.set_fire_barrel.text_id = "hud_interact_consumable_mission"
	self.set_fire_barrel.action_text_id = "hud_action_consumable_mission"
	self.set_fire_barrel.start_active = false
	self.set_fire_barrel.timer = 3
	self.set_fire_barrel.sound_start = "flag_burn_interaction_start"
	self.set_fire_barrel.sound_interupt = "flag_burn_interaction_interrupt"
	self.set_fire_barrel.sound_done = "barrel_fire_start"
	self.open_door = {}
	self.open_door.text_id = "hud_open_door_instant"
	self.open_door.interact_distance = 200
	self.open_door.axis = "y"
	self.open_truck_trunk = {}
	self.open_truck_trunk.text_id = "hud_open_truck_trunk"
	self.open_truck_trunk.action_text_id = "hud_opening_truck_trunk"
	self.open_truck_trunk.interact_distance = 200
	self.open_truck_trunk.start_active = false
	self.open_truck_trunk.timer = 2
	self.open_truck_trunk.axis = "y"
	self.open_truck_trunk.sound_start = "truck_back_door_opening"
	self.open_truck_trunk.sound_done = "truck_back_door_open"
	self.consumable_mission = {}
	self.consumable_mission.text_id = "hud_interact_consumable_mission"
	self.consumable_mission.action_text_id = "hud_action_consumable_mission"
	self.consumable_mission.blocked_hint = "hud_hint_consumable_mission_block"
	self.consumable_mission.start_active = true
	self.consumable_mission.timer = 3
	self.consumable_mission.sound_done = "consumable_mission_unlocked"
	self.request_recording_device = {}
	self.request_recording_device.text_id = "hud_request_recording_device"
	self.request_recording_device.action_text_id = "hud_action_requesting_recording_device"
	self.request_recording_device.start_active = true
	self.request_recording_device.timer = 2
end
