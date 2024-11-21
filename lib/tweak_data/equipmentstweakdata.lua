EquipmentsTweakData = EquipmentsTweakData or class()

function EquipmentsTweakData:init()
	self.first_aid_kit = {
		deploy_time = 1,
		dummy_unit = "units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit_dummy",
		description_id = "des_first_aid_kit",
		text_id = "debug_equipment_first_aid_kit",
		quantity = 4,
		use_function_name = "use_first_aid_kit",
		visual_object = "g_firstaidbag",
		icon = "equipment_first_aid_kit",
		upgrade_deploy_time_multiplier = {
			upgrade = "first_aid_kit_deploy_time_multiplier",
			category = "player"
		}
	}
	self.specials = {
		planks = {
			transfer_quantity = 4,
			text_id = "debug_equipment_stash_planks",
			icon = "equipment_planks",
			sync_possession = true
		},
		boards = {
			transfer_quantity = 4,
			text_id = "hud_equipment_boards",
			icon = "equipment_planks",
			sync_possession = true
		},
		crowbar = {
			text_id = "hud_equipment_crowbar",
			icon = "equipment_panel_crowbar",
			sync_possession = true
		}
	}
	self.specials.crowbar_stack = deep_clone(self.specials.crowbar)
	self.specials.crowbar_stack.transfer_quantity = 4
	self.specials.dynamite = {
		transfer_quantity = 99,
		text_id = "hud_equipment_dynamite",
		quantity = 1,
		max_quantity = 99,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true
	}
	self.specials.dynamite_x5 = {
		transfer_quantity = 5,
		text_id = "hud_equipment_dynamite",
		quantity = 5,
		max_quantity = 5,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true
	}
	self.specials.dynamite_x4 = {
		transfer_quantity = 4,
		text_id = "hud_equipment_dynamite",
		quantity = 4,
		max_quantity = 4,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true
	}
	self.specials.dynamite_x10 = {
		quantity = 10,
		text_id = "hud_equipment_dynamite",
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true
	}
	self.specials.dynamite_bag = {
		text_id = "hud_equipment_dynamite_bag",
		icon = "equipment_panel_dynamite",
		sync_possession = true
	}
	self.specials.tank_grenade = {
		text_id = "hud_equipment_tank_grenade",
		icon = "equipment_dynamite",
		sync_possession = true
	}
	self.specials.thermite = {
		text_id = "hud_equipment_thermite",
		icon = "equipment_panel_cvy_thermite",
		sync_possession = true
	}
	self.specials.repair_tools = {
		text_id = "hud_equipment_tools",
		icon = "equipment_panel_tools",
		sync_possession = true
	}
	self.specials.gas_tank = {
		text_id = "hud_equipment_gas_tank",
		icon = "equipment_panel_fuel_full",
		sync_possession = true
	}
	self.specials.gas_x4 = {
		transfer_quantity = 4,
		text_id = "hud_equipment_fuel_canister",
		quantity = 1,
		max_quantity = 4,
		icon = "equipment_panel_fuel_full",
		sync_possession = true
	}
	self.specials.safe_key = {
		text_id = "hud_safe_key",
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true
	}
	self.specials.door_key = {
		text_id = "hud_door_key",
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true
	}
	self.specials.car_key_01 = {
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true
	}
	self.specials.car_key_02 = {
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true
	}
	self.specials.car_key_03 = {
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true
	}
	self.specials.acid = {
		text_id = "hud_acid",
		icon = "equipment_acid",
		sync_possession = true
	}
	self.specials.gold_bar_mold = {
		text_id = "hud_gold_bar_mold",
		icon = "equipment_gold_bar_mold",
		sync_possession = true
	}
	self.specials.tank_shell = {
		text_id = "hud_tank_shell",
		icon = "equipment_panel_tools",
		sync_possession = true
	}
	self.specials.radio_parts = {
		transfer_quantity = 10,
		text_id = "hud_equipment_radio_parts",
		quantity = 1,
		max_quantity = 10,
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.blacksmith_tong = {
		text_id = "hud_equipment_blacksmith_tong",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.gold_bar = {
		text_id = "hud_equipment_gold_bar",
		icon = "equipment_panel_gold",
		sync_possession = true
	}
	self.specials.radio_crystals = {
		text_id = "hud_equipment_radio_crystals",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.radio_reciever = {
		text_id = "hud_equipment_radio_reciever",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.radio_transmiter = {
		text_id = "hud_equipment_radio_transmiter",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.radio_pipes = {
		text_id = "hud_equipment_radio_pipes",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.radio_antena = {
		text_id = "hud_equipment_radio_antena",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.radio_microphone = {
		text_id = "hud_equipment_radio_microphone",
		icon = "pd2_c4",
		sync_possession = true
	}
	self.specials.blow_torch = {
		text_id = "hud_equipment_blow_torch",
		icon = "equipment_blow_torch",
		sync_possession = true
	}
	self.specials.blow_torch_fuel = {
		text_id = "hud_equipment_blow_torch_fuel",
		quantity = 2,
		max_quantity = 2,
		icon = "equipment_blow_torch_fuel",
		sync_possession = true
	}
	self.specials.safe_keychain = {
		text_id = "hud_equipment_safe_keychain",
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true
	}
	self.specials.bolt_cutter = {
		text_id = "hud_equipment_bolt_cutter",
		icon = "pd2_wirecutter",
		sync_possession = true
	}
	self.specials.tank_crank = {
		text_id = "hud_equipment_tank_crank",
		icon = "equipment_tank_crank",
		sync_possession = true
	}
	self.specials.parachute = {
		text_id = "hud_equipment_parachute",
		icon = "equipment_panel_parachute",
		sync_possession = true
	}
	self.specials.landmine = {
		transfer_quantity = 4,
		text_id = "hud_equipment_landmine",
		quantity = 1,
		max_quantity = 4,
		icon = "equipment_panel_cvy_landimine",
		sync_possession = true
	}
	self.specials.scrap_parts = {
		transfer_quantity = 0,
		text_id = "hud_equipment_scrap_parts",
		quantity = 1,
		max_quantity = 100,
		icon = "equipment_panel_tools",
		sync_possession = true
	}
	self.specials.fuel_canister = {
		text_id = "hud_equipment_fuel_canister",
		icon = "equipment_panel_fuel_full",
		sync_possession = true
	}
	self.specials.empty_fuel_canister = {
		text_id = "hud_equipment_empty_fuel_canister",
		icon = "equipment_panel_fuel_empty",
		sync_possession = true
	}
	self.specials.code_book = {
		text_id = "hud_equipment_code_book",
		icon = "equipment_panel_code_book",
		sync_possession = true
	}
	self.specials.recording_device = {
		text_id = "hud_equipment_recording_device",
		icon = "equipment_panel_recording_device",
		sync_possession = true
	}
	self.specials.enigma = {
		text_id = "hud_equipment_enigma",
		icon = "equipment_panel_code_device",
		sync_possession = true
	}
	self.specials.empty_bucket = {
		text_id = "hud_equipment_empty_bucket",
		icon = "equipment_files",
		sync_possession = true
	}
	self.specials.full_bucket = {
		text_id = "hud_equipment_full_bucket",
		icon = "equipment_files",
		sync_possession = true
	}
	self.specials.portable_radio = {
		text_id = "hud_portable_radio",
		icon = "equipment_panel_recording_device",
		sync_possession = true
	}
	self.specials.briefcase = {
		text_id = "hud_briefcase",
		icon = "equipment_panel_sps_briefcase",
		sync_possession = true
	}
	self.max_amount = {
		asset_ammo_bag = 4,
		grenades = 4,
		trip_mine = 6,
		sentry_gun = 2,
		ecm_jammer = 2,
		doctor_bag = 2,
		ammo_bag = 2,
		asset_doctor_bag = 3,
		asset_sentry_gun = 4,
		asset_grenade_crate = 3,
		first_aid_kit = 14
	}
	self.class_name_to_deployable_id = {
		FirstAidKitBase = "first_aid_kit",
		DoctorBagBase = "doctor_bag",
		AmmoBagBase = "ammo_bag"
	}
end
