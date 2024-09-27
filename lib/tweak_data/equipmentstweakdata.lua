EquipmentsTweakData = EquipmentsTweakData or class()

function EquipmentsTweakData:init()
	self.first_aid_kit = {
		upgrade_deploy_time_multiplier = nil,
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
			icon = "equipment_planks",
			sync_possession = true,
			transfer_quantity = 4,
			text_id = "debug_equipment_stash_planks"
		},
		boards = {
			icon = "equipment_planks",
			sync_possession = true,
			transfer_quantity = 4,
			text_id = "hud_equipment_boards"
		},
		crowbar = {
			icon = "equipment_panel_crowbar",
			sync_possession = true,
			text_id = "hud_equipment_crowbar"
		}
	}
	self.specials.crowbar_stack = deep_clone(self.specials.crowbar)
	self.specials.crowbar_stack.transfer_quantity = 4
	self.specials.dynamite = {
		quantity = 1,
		max_quantity = 99,
		transfer_quantity = 99,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite"
	}
	self.specials.dynamite_x5 = {
		quantity = 5,
		max_quantity = 5,
		transfer_quantity = 5,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite"
	}
	self.specials.dynamite_x4 = {
		quantity = 4,
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		text_id = "hud_equipment_dynamite"
	}
	self.specials.dynamite_x10 = {
		icon = "equipment_panel_dynamite_stick",
		sync_possession = true,
		quantity = 10,
		text_id = "hud_equipment_dynamite"
	}
	self.specials.dynamite_bag = {
		icon = "equipment_panel_dynamite",
		sync_possession = true,
		text_id = "hud_equipment_dynamite_bag"
	}
	self.specials.tank_grenade = {
		icon = "equipment_dynamite",
		sync_possession = true,
		text_id = "hud_equipment_tank_grenade"
	}
	self.specials.thermite = {
		icon = "equipment_panel_cvy_thermite",
		sync_possession = true,
		text_id = "hud_equipment_thermite"
	}
	self.specials.repair_tools = {
		icon = "equipment_panel_tools",
		sync_possession = true,
		text_id = "hud_equipment_tools"
	}
	self.specials.gas_tank = {
		icon = "equipment_panel_fuel_full",
		sync_possession = true,
		text_id = "hud_equipment_gas_tank"
	}
	self.specials.gas_x4 = {
		quantity = 1,
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_fuel_full",
		sync_possession = true,
		text_id = "hud_equipment_fuel_canister"
	}
	self.specials.safe_key = {
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true,
		text_id = "hud_safe_key"
	}
	self.specials.door_key = {
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true,
		text_id = "hud_door_key"
	}
	self.specials.car_key_01 = {
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true,
		text_id = "hud_car_key"
	}
	self.specials.car_key_02 = {
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true,
		text_id = "hud_car_key"
	}
	self.specials.car_key_03 = {
		icon = "equipment_panel_sps_interaction_key",
		sync_possession = true,
		text_id = "hud_car_key"
	}
	self.specials.acid = {
		icon = "equipment_acid",
		sync_possession = true,
		text_id = "hud_acid"
	}
	self.specials.gold_bar_mold = {
		icon = "equipment_gold_bar_mold",
		sync_possession = true,
		text_id = "hud_gold_bar_mold"
	}
	self.specials.tank_shell = {
		icon = "equipment_panel_tools",
		sync_possession = true,
		text_id = "hud_tank_shell"
	}
	self.specials.radio_parts = {
		quantity = 1,
		max_quantity = 10,
		transfer_quantity = 10,
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_parts"
	}
	self.specials.blacksmith_tong = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_blacksmith_tong"
	}
	self.specials.gold_bar = {
		icon = "equipment_panel_gold",
		sync_possession = true,
		text_id = "hud_equipment_gold_bar"
	}
	self.specials.radio_crystals = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_crystals"
	}
	self.specials.radio_reciever = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_reciever"
	}
	self.specials.radio_transmiter = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_transmiter"
	}
	self.specials.radio_pipes = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_pipes"
	}
	self.specials.radio_antena = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_antena"
	}
	self.specials.radio_microphone = {
		icon = "pd2_c4",
		sync_possession = true,
		text_id = "hud_equipment_radio_microphone"
	}
	self.specials.blow_torch = {
		icon = "equipment_blow_torch",
		sync_possession = true,
		text_id = "hud_equipment_blow_torch"
	}
	self.specials.blow_torch_fuel = {
		quantity = 2,
		max_quantity = 2,
		icon = "equipment_blow_torch_fuel",
		sync_possession = true,
		text_id = "hud_equipment_blow_torch_fuel"
	}
	self.specials.safe_keychain = {
		icon = "equipment_panel_sto_safe_key",
		sync_possession = true,
		text_id = "hud_equipment_safe_keychain"
	}
	self.specials.bolt_cutter = {
		icon = "pd2_wirecutter",
		sync_possession = true,
		text_id = "hud_equipment_bolt_cutter"
	}
	self.specials.tank_crank = {
		icon = "equipment_tank_crank",
		sync_possession = true,
		text_id = "hud_equipment_tank_crank"
	}
	self.specials.parachute = {
		icon = "equipment_panel_parachute",
		sync_possession = true,
		text_id = "hud_equipment_parachute"
	}
	self.specials.landmine = {
		quantity = 1,
		max_quantity = 4,
		transfer_quantity = 4,
		icon = "equipment_panel_cvy_landimine",
		sync_possession = true,
		text_id = "hud_equipment_landmine"
	}
	self.specials.scrap_parts = {
		quantity = 1,
		max_quantity = 100,
		transfer_quantity = 0,
		icon = "equipment_panel_tools",
		sync_possession = true,
		text_id = "hud_equipment_scrap_parts"
	}
	self.specials.fuel_canister = {
		icon = "equipment_panel_fuel_full",
		sync_possession = true,
		text_id = "hud_equipment_fuel_canister"
	}
	self.specials.empty_fuel_canister = {
		icon = "equipment_panel_fuel_empty",
		sync_possession = true,
		text_id = "hud_equipment_empty_fuel_canister"
	}
	self.specials.code_book = {
		icon = "equipment_panel_code_book",
		sync_possession = true,
		text_id = "hud_equipment_code_book"
	}
	self.specials.recording_device = {
		icon = "equipment_panel_recording_device",
		sync_possession = true,
		text_id = "hud_equipment_recording_device"
	}
	self.specials.enigma = {
		icon = "equipment_panel_code_device",
		sync_possession = true,
		text_id = "hud_equipment_enigma"
	}
	self.specials.empty_bucket = {
		icon = "equipment_files",
		sync_possession = true,
		text_id = "hud_equipment_empty_bucket"
	}
	self.specials.full_bucket = {
		icon = "equipment_files",
		sync_possession = true,
		text_id = "hud_equipment_full_bucket"
	}
	self.specials.portable_radio = {
		icon = "equipment_panel_recording_device",
		sync_possession = true,
		text_id = "hud_portable_radio"
	}
	self.specials.briefcase = {
		icon = "equipment_panel_sps_briefcase",
		sync_possession = true,
		text_id = "hud_briefcase"
	}
	self.max_amount = {
		sentry_gun = 2,
		ecm_jammer = 2,
		doctor_bag = 2,
		ammo_bag = 2,
		asset_ammo_bag = 4,
		asset_sentry_gun = 4,
		asset_grenade_crate = 3,
		asset_doctor_bag = 3,
		first_aid_kit = 14,
		grenades = 4,
		trip_mine = 6
	}
	self.class_name_to_deployable_id = {
		AmmoBagBase = "ammo_bag",
		FirstAidKitBase = "first_aid_kit",
		DoctorBagBase = "doctor_bag"
	}
end
