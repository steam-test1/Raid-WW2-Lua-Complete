EquipmentsTweakData = EquipmentsTweakData or class()

function EquipmentsTweakData:init()
	self.first_aid_kit = {
		deploy_time = 1,
		dummy_unit = "units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit_dummy",
		use_function_name = "use_first_aid_kit",
		text_id = "debug_equipment_first_aid_kit",
		quantity = 4,
		visual_object = "g_firstaidbag",
		icon = "equipment_first_aid_kit",
		description_id = "des_first_aid_kit",
		upgrade_deploy_time_multiplier = {
			upgrade = "first_aid_kit_deploy_time_multiplier",
			category = "player"
		}
	}
	self.specials = {
		planks = {
			sync_possession = true,
			icon = "equipment_planks",
			transfer_quantity = 4,
			text_id = "debug_equipment_stash_planks"
		},
		boards = {
			sync_possession = true,
			icon = "equipment_planks",
			transfer_quantity = 4,
			text_id = "hud_equipment_boards"
		},
		crowbar = {
			sync_possession = true,
			icon = "equipment_panel_crowbar",
			text_id = "hud_equipment_crowbar"
		}
	}
	self.specials.crowbar_stack = deep_clone(self.specials.crowbar)
	self.specials.crowbar_stack.transfer_quantity = 4
	self.specials.dynamite = {
		quantity = 1,
		transfer_quantity = 99,
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		max_quantity = 99,
		icon = "equipment_panel_dynamite_stick"
	}
	self.specials.dynamite_x5 = {
		quantity = 5,
		transfer_quantity = 5,
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		max_quantity = 5,
		icon = "equipment_panel_dynamite_stick"
	}
	self.specials.dynamite_x4 = {
		quantity = 4,
		transfer_quantity = 4,
		sync_possession = true,
		text_id = "hud_equipment_dynamite",
		max_quantity = 4,
		icon = "equipment_panel_dynamite_stick"
	}
	self.specials.dynamite_x10 = {
		sync_possession = true,
		icon = "equipment_panel_dynamite_stick",
		quantity = 10,
		text_id = "hud_equipment_dynamite"
	}
	self.specials.dynamite_bag = {
		sync_possession = true,
		icon = "equipment_panel_dynamite",
		text_id = "hud_equipment_dynamite_bag"
	}
	self.specials.tank_grenade = {
		sync_possession = true,
		icon = "equipment_dynamite",
		text_id = "hud_equipment_tank_grenade"
	}
	self.specials.thermite = {
		sync_possession = true,
		icon = "equipment_panel_cvy_thermite",
		text_id = "hud_equipment_thermite"
	}
	self.specials.repair_tools = {
		sync_possession = true,
		icon = "equipment_panel_tools",
		text_id = "hud_equipment_tools"
	}
	self.specials.gas_tank = {
		sync_possession = true,
		icon = "equipment_panel_fuel_full",
		text_id = "hud_equipment_gas_tank"
	}
	self.specials.gas_x4 = {
		quantity = 1,
		sync_possession = true,
		transfer_quantity = 4,
		text_id = "hud_equipment_fuel_canister",
		max_quantity = 4,
		icon = "equipment_panel_fuel_full"
	}
	self.specials.safe_key = {
		sync_possession = true,
		icon = "equipment_panel_sto_safe_key",
		text_id = "hud_safe_key"
	}
	self.specials.door_key = {
		sync_possession = true,
		icon = "equipment_panel_sto_safe_key",
		text_id = "hud_door_key"
	}
	self.specials.car_key_01 = {
		sync_possession = true,
		icon = "equipment_panel_sps_interaction_key",
		text_id = "hud_car_key"
	}
	self.specials.car_key_02 = {
		sync_possession = true,
		icon = "equipment_panel_sps_interaction_key",
		text_id = "hud_car_key"
	}
	self.specials.car_key_03 = {
		sync_possession = true,
		icon = "equipment_panel_sps_interaction_key",
		text_id = "hud_car_key"
	}
	self.specials.acid = {
		sync_possession = true,
		icon = "equipment_acid",
		text_id = "hud_acid"
	}
	self.specials.gold_bar_mold = {
		sync_possession = true,
		icon = "equipment_gold_bar_mold",
		text_id = "hud_gold_bar_mold"
	}
	self.specials.tank_shell = {
		sync_possession = true,
		icon = "equipment_panel_tools",
		text_id = "hud_tank_shell"
	}
	self.specials.radio_parts = {
		quantity = 1,
		transfer_quantity = 10,
		sync_possession = true,
		text_id = "hud_equipment_radio_parts",
		max_quantity = 10,
		icon = "pd2_c4"
	}
	self.specials.blacksmith_tong = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_blacksmith_tong"
	}
	self.specials.gold_bar = {
		sync_possession = true,
		icon = "equipment_panel_gold",
		text_id = "hud_equipment_gold_bar"
	}
	self.specials.radio_crystals = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_crystals"
	}
	self.specials.radio_reciever = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_reciever"
	}
	self.specials.radio_transmiter = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_transmiter"
	}
	self.specials.radio_pipes = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_pipes"
	}
	self.specials.radio_antena = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_antena"
	}
	self.specials.radio_microphone = {
		sync_possession = true,
		icon = "pd2_c4",
		text_id = "hud_equipment_radio_microphone"
	}
	self.specials.blow_torch = {
		sync_possession = true,
		icon = "equipment_blow_torch",
		text_id = "hud_equipment_blow_torch"
	}
	self.specials.blow_torch_fuel = {
		quantity = 2,
		sync_possession = true,
		text_id = "hud_equipment_blow_torch_fuel",
		max_quantity = 2,
		icon = "equipment_blow_torch_fuel"
	}
	self.specials.safe_keychain = {
		sync_possession = true,
		icon = "equipment_panel_sto_safe_key",
		text_id = "hud_equipment_safe_keychain"
	}
	self.specials.bolt_cutter = {
		sync_possession = true,
		icon = "pd2_wirecutter",
		text_id = "hud_equipment_bolt_cutter"
	}
	self.specials.tank_crank = {
		sync_possession = true,
		icon = "equipment_tank_crank",
		text_id = "hud_equipment_tank_crank"
	}
	self.specials.parachute = {
		sync_possession = true,
		icon = "equipment_panel_parachute",
		text_id = "hud_equipment_parachute"
	}
	self.specials.landmine = {
		quantity = 1,
		sync_possession = true,
		transfer_quantity = 4,
		text_id = "hud_equipment_landmine",
		max_quantity = 4,
		icon = "equipment_panel_cvy_landimine"
	}
	self.specials.scrap_parts = {
		quantity = 1,
		transfer_quantity = 0,
		sync_possession = true,
		text_id = "hud_equipment_scrap_parts",
		max_quantity = 100,
		icon = "equipment_panel_tools"
	}
	self.specials.fuel_canister = {
		sync_possession = true,
		icon = "equipment_panel_fuel_full",
		text_id = "hud_equipment_fuel_canister"
	}
	self.specials.empty_fuel_canister = {
		sync_possession = true,
		icon = "equipment_panel_fuel_empty",
		text_id = "hud_equipment_empty_fuel_canister"
	}
	self.specials.code_book = {
		sync_possession = true,
		icon = "equipment_panel_code_book",
		text_id = "hud_equipment_code_book"
	}
	self.specials.recording_device = {
		sync_possession = true,
		icon = "equipment_panel_recording_device",
		text_id = "hud_equipment_recording_device"
	}
	self.specials.enigma = {
		sync_possession = true,
		icon = "equipment_panel_code_device",
		text_id = "hud_equipment_enigma"
	}
	self.specials.empty_bucket = {
		sync_possession = true,
		icon = "equipment_files",
		text_id = "hud_equipment_empty_bucket"
	}
	self.specials.full_bucket = {
		sync_possession = true,
		icon = "equipment_files",
		text_id = "hud_equipment_full_bucket"
	}
	self.specials.portable_radio = {
		sync_possession = true,
		icon = "equipment_panel_recording_device",
		text_id = "hud_portable_radio"
	}
	self.specials.briefcase = {
		sync_possession = true,
		icon = "equipment_panel_sps_briefcase",
		text_id = "hud_briefcase"
	}
	self.max_amount = {
		trip_mine = 6,
		asset_sentry_gun = 4,
		ecm_jammer = 2,
		asset_doctor_bag = 3,
		ammo_bag = 2,
		grenades = 4,
		asset_ammo_bag = 4,
		asset_grenade_crate = 3,
		first_aid_kit = 14,
		sentry_gun = 2,
		doctor_bag = 2
	}
	self.class_name_to_deployable_id = {
		AmmoBagBase = "ammo_bag",
		FirstAidKitBase = "first_aid_kit",
		DoctorBagBase = "doctor_bag"
	}
end
