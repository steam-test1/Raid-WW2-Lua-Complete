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
			category = "player",
			upgrade = "first_aid_kit_deploy_time_multiplier"
		}
	}
	self.specials = {
		planks = {
			sync_possession = true,
			transfer_quantity = 4,
			text_id = "debug_equipment_stash_planks",
			icon = "equipment_planks"
		},
		boards = {
			sync_possession = true,
			transfer_quantity = 4,
			text_id = "hud_equipment_boards",
			icon = "equipment_planks"
		},
		crowbar = {
			sync_possession = true,
			text_id = "hud_equipment_crowbar",
			icon = "equipment_panel_crowbar"
		}
	}
	self.specials.crowbar_stack = deep_clone(self.specials.crowbar)
	self.specials.crowbar_stack.transfer_quantity = 4
	self.specials.dynamite = {
		max_quantity = 99,
		transfer_quantity = 99,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		quantity = 1
	}
	self.specials.dynamite_x5 = {
		max_quantity = 5,
		transfer_quantity = 5,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		quantity = 5
	}
	self.specials.dynamite_x4 = {
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		quantity = 4
	}
	self.specials.dynamite_x10 = {
		sync_possession = true,
		quantity = 10,
		text_id = "hud_equipment_dynamite",
		icon = "equipment_panel_dynamite_stick"
	}
	self.specials.dynamite_bag = {
		sync_possession = true,
		text_id = "hud_equipment_dynamite_bag",
		icon = "equipment_panel_dynamite"
	}
	self.specials.tank_grenade = {
		sync_possession = true,
		text_id = "hud_equipment_tank_grenade",
		icon = "equipment_dynamite"
	}
	self.specials.thermite = {
		sync_possession = true,
		text_id = "hud_equipment_thermite",
		icon = "equipment_panel_cvy_thermite"
	}
	self.specials.repair_tools = {
		sync_possession = true,
		text_id = "hud_equipment_tools",
		icon = "equipment_panel_tools"
	}
	self.specials.gas_tank = {
		sync_possession = true,
		text_id = "hud_equipment_gas_tank",
		icon = "equipment_panel_fuel_full"
	}
	self.specials.gas_x4 = {
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_fuel_full",
		sync_possession = true,
		text_id = "hud_equipment_fuel_canister",
		quantity = 1
	}
	self.specials.safe_key = {
		sync_possession = true,
		text_id = "hud_safe_key",
		icon = "equipment_panel_sto_safe_key"
	}
	self.specials.door_key = {
		sync_possession = true,
		text_id = "hud_door_key",
		icon = "equipment_panel_sto_safe_key"
	}
	self.specials.car_key_01 = {
		sync_possession = true,
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key"
	}
	self.specials.car_key_02 = {
		sync_possession = true,
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key"
	}
	self.specials.car_key_03 = {
		sync_possession = true,
		text_id = "hud_car_key",
		icon = "equipment_panel_sps_interaction_key"
	}
	self.specials.acid = {
		sync_possession = true,
		text_id = "hud_acid",
		icon = "equipment_acid"
	}
	self.specials.gold_bar_mold = {
		sync_possession = true,
		text_id = "hud_gold_bar_mold",
		icon = "equipment_gold_bar_mold"
	}
	self.specials.tank_shell = {
		sync_possession = true,
		text_id = "hud_tank_shell",
		icon = "equipment_panel_tools"
	}
	self.specials.radio_parts = {
		max_quantity = 10,
		transfer_quantity = 10,
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_parts",
		quantity = 1
	}
	self.specials.blacksmith_tong = {
		sync_possession = true,
		text_id = "hud_equipment_blacksmith_tong",
		icon = "pd2_c4"
	}
	self.specials.gold_bar = {
		sync_possession = true,
		text_id = "hud_equipment_gold_bar",
		icon = "equipment_panel_gold"
	}
	self.specials.radio_crystals = {
		sync_possession = true,
		text_id = "hud_equipment_radio_crystals",
		icon = "pd2_c4"
	}
	self.specials.radio_reciever = {
		sync_possession = true,
		text_id = "hud_equipment_radio_reciever",
		icon = "pd2_c4"
	}
	self.specials.radio_transmiter = {
		sync_possession = true,
		text_id = "hud_equipment_radio_transmiter",
		icon = "pd2_c4"
	}
	self.specials.radio_pipes = {
		sync_possession = true,
		text_id = "hud_equipment_radio_pipes",
		icon = "pd2_c4"
	}
	self.specials.radio_antena = {
		sync_possession = true,
		text_id = "hud_equipment_radio_antena",
		icon = "pd2_c4"
	}
	self.specials.radio_microphone = {
		sync_possession = true,
		text_id = "hud_equipment_radio_microphone",
		icon = "pd2_c4"
	}
	self.specials.blow_torch = {
		sync_possession = true,
		text_id = "hud_equipment_blow_torch",
		icon = "equipment_blow_torch"
	}
	self.specials.blow_torch_fuel = {
		max_quantity = 2,
		icon = "equipment_blow_torch_fuel",
		sync_possession = true,
		text_id = "hud_equipment_blow_torch_fuel",
		quantity = 2
	}
	self.specials.safe_keychain = {
		sync_possession = true,
		text_id = "hud_equipment_safe_keychain",
		icon = "equipment_panel_sto_safe_key"
	}
	self.specials.bolt_cutter = {
		sync_possession = true,
		text_id = "hud_equipment_bolt_cutter",
		icon = "pd2_wirecutter"
	}
	self.specials.tank_crank = {
		sync_possession = true,
		text_id = "hud_equipment_tank_crank",
		icon = "equipment_tank_crank"
	}
	self.specials.parachute = {
		sync_possession = true,
		text_id = "hud_equipment_parachute",
		icon = "equipment_panel_parachute"
	}
	self.specials.landmine = {
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_cvy_landimine",
		sync_possession = true,
		text_id = "hud_equipment_landmine",
		quantity = 1
	}
	self.specials.scrap_parts = {
		max_quantity = 100,
		transfer_quantity = 0,
		icon = "equipment_panel_tools",
		sync_possession = true,
		text_id = "hud_equipment_scrap_parts",
		quantity = 1
	}
	self.specials.fuel_canister = {
		sync_possession = true,
		text_id = "hud_equipment_fuel_canister",
		icon = "equipment_panel_fuel_full"
	}
	self.specials.empty_fuel_canister = {
		sync_possession = true,
		text_id = "hud_equipment_empty_fuel_canister",
		icon = "equipment_panel_fuel_empty"
	}
	self.specials.code_book = {
		sync_possession = true,
		text_id = "hud_equipment_code_book",
		icon = "equipment_panel_code_book"
	}
	self.specials.recording_device = {
		sync_possession = true,
		text_id = "hud_equipment_recording_device",
		icon = "equipment_panel_recording_device"
	}
	self.specials.enigma = {
		sync_possession = true,
		text_id = "hud_equipment_enigma",
		icon = "equipment_panel_code_device"
	}
	self.specials.empty_bucket = {
		sync_possession = true,
		text_id = "hud_equipment_empty_bucket",
		icon = "equipment_files"
	}
	self.specials.full_bucket = {
		sync_possession = true,
		text_id = "hud_equipment_full_bucket",
		icon = "equipment_files"
	}
	self.specials.portable_radio = {
		sync_possession = true,
		text_id = "hud_portable_radio",
		icon = "equipment_panel_recording_device"
	}
	self.specials.briefcase = {
		sync_possession = true,
		text_id = "hud_briefcase",
		icon = "equipment_panel_sps_briefcase"
	}
	self.specials.fuel_hose = {
		sync_possession = true,
		text_id = "hud_fuel_hose",
		icon = "equipment_panel_fuel_full"
	}
	self.specials.power_cable = {
		sync_possession = true,
		text_id = "hud_power_cable",
		icon = "equipment_panel_power_cable"
	}
	self.max_amount = {
		asset_grenade_crate = 3,
		asset_doctor_bag = 3,
		asset_ammo_bag = 4,
		grenades = 4,
		trip_mine = 6,
		sentry_gun = 2,
		ecm_jammer = 2,
		doctor_bag = 2,
		ammo_bag = 2,
		first_aid_kit = 14,
		asset_sentry_gun = 4
	}
	self.class_name_to_deployable_id = {
		DoctorBagBase = "doctor_bag",
		AmmoBagBase = "ammo_bag",
		FirstAidKitBase = "first_aid_kit"
	}
end
