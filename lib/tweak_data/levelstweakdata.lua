LevelsTweakData = LevelsTweakData or class()

function LevelsTweakData:init()
	self.altitude_difference_limit = 300
	self.editor_level = "zone_germany_park"
	self.streaming_level = {}
	self.streaming_level.name_id = "menu_stream"
	self.streaming_level.world_name = "vanilla/streaming_level"
	self.streaming_level.cube = "cube_apply_heist_bank"
	self.camp = {}
	self.camp.name_id = "menu_camp_hl"
	self.camp.briefing_id = "menu_germany_desc"
	self.camp.world_name = "vanilla/germany_camp"
	self.camp.cube = "cube_apply_heist_bank"
	self.tutorial = {}
	self.tutorial.name_id = "menu_tutorial_hl"
	self.tutorial.briefing_id = "menu_tutorial_briefing"
	self.tutorial.world_name = "vanilla/zone_germany_tutorial"
	self.tutorial.predefined_world = "tutorial"
	self.tutorial.package = {
		"packages/zone_germany"
	}
	self.tutorial.cube = "cube_apply_heist_bank"
	self.flakturm = {}
	self.flakturm.name_id = "menu_ger_miss_01_hl"
	self.flakturm.briefing_id = "menu_ger_miss_01_desc"
	self.flakturm.world_name = "vanilla/flakturm"
	self.flakturm.predefined_world = "germany_flakturm"
	self.flakturm.cube = "cube_apply_heist_bank"
	self.gold_rush = {}
	self.gold_rush.name_id = "menu_ger_miss_03_ld_hl"
	self.gold_rush.briefing_id = "menu_ger_miss_03_ld_desc"
	self.gold_rush.world_name = "vanilla/gold_rush"
	self.gold_rush.predefined_world = "germany_gold_rush"
	self.gold_rush.cube = "cube_apply_heist_bank"
	self.train_yard = {}
	self.train_yard.name_id = "menu_ger_miss_04_hl"
	self.train_yard.briefing_id = "menu_ger_miss_04_desc"
	self.train_yard.world_name = "vanilla/train_yard"
	self.train_yard.predefined_world = "germany_train_yard"
	self.train_yard.cube = "cube_apply_heist_bank"
	self.ger_bridge = {}
	self.ger_bridge.name_id = "menu_ger_bridge_00_hl"
	self.ger_bridge.briefing_id = "menu_ger_bridge_00_desc"
	self.ger_bridge.world_name = "vanilla/bridge"
	self.ger_bridge.predefined_world = "germany_bridge"
	self.ger_bridge.cube = "cube_apply_heist_bank"
	self.ger_bridge_operation = {}
	self.ger_bridge_operation.name_id = "menu_ger_bridge_00_hl"
	self.ger_bridge_operation.briefing_id = "menu_ger_bridge_00_desc"
	self.ger_bridge_operation.world_name = "vanilla/bridge"
	self.ger_bridge_operation.predefined_world = "germany_bridge_operation"
	self.ger_bridge_operation.cube = "cube_apply_heist_bank"
	self.radio_defense = {}
	self.radio_defense.name_id = "menu_afr_miss_04_hl"
	self.radio_defense.briefing_id = "menu_afr_miss_04_desc"
	self.radio_defense.world_name = "vanilla/radio_defense"
	self.radio_defense.predefined_world = "germany_radio"
	self.radio_defense.cube = "cube_apply_heist_bank"
	self.settlement = {}
	self.settlement.name_id = "menu_afr_miss_05_hl"
	self.settlement.briefing_id = "menu_afr_miss_05_desc"
	self.settlement.world_name = "vanilla/castle"
	self.settlement.predefined_world = "germany_castle"
	self.settlement.cube = "cube_apply_heist_bank"
	self.forest_gumpy = {}
	self.forest_gumpy.name_id = "forest_gumpy"
	self.forest_gumpy.briefing_id = "tank_radio_test_briefing"
	self.forest_gumpy.world_name = "vanilla/forest_gumpy"
	self.forest_gumpy.predefined_world = "forest_gumpy"
	self.forest_gumpy.cube = "cube_apply_heist_bank"
	self.zone_germany_park = {}
	self.zone_germany_park.name_id = "menu_germany_hl"
	self.zone_germany_park.briefing_id = "menu_germany_desc"
	self.zone_germany_park.world_name = "vanilla/zone_germany_park"
	self.zone_germany_park.predefined_world = "zone_germany_park"
	self.zone_germany_park.cube = "cube_apply_heist_bank"
	self.zone_germany_park.floor_coordinates = {
		-10000
	}
	self.zone_germany_park.map = {
		texture = "map",
		base_icon = "map_camp",
		base_location = {
			x = -200,
			y = -2850
		},
		world_borders = {
			down = -28846,
			up = 23122,
			left = -29736,
			right = 34700
		},
		panel_shape = {
			w = 885,
			h = 710,
			x = 105,
			y = 220
		}
	}
	self.zone_germany_destroyed = {}
	self.zone_germany_destroyed.name_id = "menu_germany_hl"
	self.zone_germany_destroyed.briefing_id = "menu_germany_desc"
	self.zone_germany_destroyed.world_name = "vanilla/zone_germany_destroyed"
	self.zone_germany_destroyed.predefined_world = "zone_germany_destroyed"
	self.zone_germany_destroyed.cube = "cube_apply_heist_bank"
	self.zone_germany_destroyed.floor_coordinates = {
		-10000
	}
	self.zone_germany_destroyed.map = {
		texture = "map",
		base_icon = "map_camp",
		base_location = {
			x = -200,
			y = -2850
		},
		world_borders = {
			down = -28846,
			up = 23122,
			left = -29736,
			right = 34700
		},
		panel_shape = {
			w = 885,
			h = 710,
			x = 105,
			y = 220
		}
	}
	self.zone_germany_destroyed_fuel = {}
	self.zone_germany_destroyed_fuel.name_id = "menu_germany_hl"
	self.zone_germany_destroyed_fuel.briefing_id = "menu_germany_desc"
	self.zone_germany_destroyed_fuel.world_name = "vanilla/zone_germany_destroyed_fuel"
	self.zone_germany_destroyed_fuel.predefined_world = "zone_germany_destroyed_fuel"
	self.zone_germany_destroyed_fuel.cube = "cube_apply_heist_bank"
	self.zone_germany_destroyed_fuel.floor_coordinates = {
		-10000
	}
	self.zone_germany_destroyed_fuel.map = {
		texture = "map",
		base_icon = "map_camp",
		base_location = {
			x = -200,
			y = -2850
		},
		world_borders = {
			down = -28846,
			up = 23122,
			left = -29736,
			right = 34700
		},
		panel_shape = {
			w = 885,
			h = 710,
			x = 105,
			y = 220
		}
	}
	self.zone_germany_roundabout = {}
	self.zone_germany_roundabout.name_id = "menu_germany_hl"
	self.zone_germany_roundabout.briefing_id = "menu_germany_desc"
	self.zone_germany_roundabout.world_name = "vanilla/zone_germany_roundabout"
	self.zone_germany_roundabout.predefined_world = "zone_germany_roundabout"
	self.zone_germany_roundabout.cube = "cube_apply_heist_bank"
	self.zone_germany_roundabout.floor_coordinates = {
		-10000
	}
	self.zone_germany_roundabout.map = {
		texture = "map",
		base_icon = "map_camp",
		base_location = {
			x = -200,
			y = -2850
		},
		world_borders = {
			down = -28846,
			up = 23122,
			left = -29736,
			right = 34700
		},
		panel_shape = {
			w = 885,
			h = 710,
			x = 105,
			y = 220
		}
	}
	self.zone_germany_roundabout_fuel = {}
	self.zone_germany_roundabout_fuel.name_id = "menu_germany_hl"
	self.zone_germany_roundabout_fuel.briefing_id = "menu_germany_desc"
	self.zone_germany_roundabout_fuel.world_name = "vanilla/zone_germany_roundabout_fuel"
	self.zone_germany_roundabout_fuel.predefined_world = "zone_germany_roundabout_fuel"
	self.zone_germany_roundabout_fuel.cube = "cube_apply_heist_bank"
	self.zone_germany_roundabout_fuel.floor_coordinates = {
		-10000
	}
	self.zone_germany_roundabout_fuel.map = {
		texture = "map",
		base_icon = "map_camp",
		base_location = {
			x = -200,
			y = -2850
		},
		world_borders = {
			down = -28846,
			up = 23122,
			left = -29736,
			right = 34700
		},
		panel_shape = {
			w = 885,
			h = 710,
			x = 105,
			y = 220
		}
	}
	self.bunker_test = {}
	self.bunker_test.name_id = "bunker_test"
	self.bunker_test.briefing_id = "bunker_test_briefing"
	self.bunker_test.world_name = "vanilla/bunker_test"
	self.bunker_test.cube = "cube_apply_heist_bank"
	self.bunker_test.predefined_world = "bunker_test"
	self.tnd = {}
	self.tnd.name_id = "tnd"
	self.tnd.briefing_id = "tnd_briefing"
	self.tnd.world_name = "vanilla/tnd"
	self.tnd.cube = "cube_apply_heist_bank"
	self.tnd.predefined_world = "tnd"
	self.hunters = {}
	self.hunters.name_id = "hunters"
	self.hunters.briefing_id = "hunters_briefing"
	self.hunters.world_name = "vanilla/hunters"
	self.hunters.cube = "cube_apply_heist_bank"
	self.hunters.predefined_world = "hunters"
	self.convoy = {}
	self.convoy.name_id = "convoy"
	self.convoy.briefing_id = "convoy_briefing"
	self.convoy.world_name = "vanilla/convoy"
	self.convoy.cube = "cube_apply_heist_bank"
	self.convoy.predefined_world = "convoy"
	self.spies_test = {}
	self.spies_test.name_id = "spies_test"
	self.spies_test.briefing_id = "spies_test_briefing"
	self.spies_test.world_name = "vanilla/spies_test_layout"
	self.spies_test.cube = "cube_apply_heist_bank"
	self.spies_test.predefined_world = "spies_test"
	self.sto = {}
	self.sto.name_id = "sto"
	self.sto.briefing_id = "sto_briefing"
	self.sto.world_name = "vanilla/sto"
	self.sto.cube = "cube_apply_heist_bank"
	self.sto.predefined_world = "sto"
	self.silo = {}
	self.silo.name_id = "silo"
	self.silo.briefing_id = "silo_briefing"
	self.silo.world_name = "upg_002/silo/silo_start"
	self.silo.packages = {
		"packages/zone_germany"
	}
	self.silo.cube = "cube_apply_heist_bank"
	self.silo.predefined_world = "silo"
	self.kelly = {}
	self.kelly.name_id = "kelly"
	self.kelly.briefing_id = "kelly_briefing"
	self.kelly.world_name = "upg_003/kelly"
	self.kelly.packages = {
		"packages/zone_germany"
	}
	self.kelly.cube = "cube_apply_heist_bank"
	self.kelly.predefined_world = "kelly"
	self.fury_railway = {}
	self.fury_railway.name_id = "fury_railway"
	self.fury_railway.briefing_id = "fury_railway_briefing"
	self.fury_railway.world_name = "upg_005/fury_railway"
	self.fury_railway.cube = "cube_apply_heist_bank"
	self.fury_railway.packages = {
		"packages/zone_germany"
	}
	self.fury_railway.predefined_world = "fury_railway"
	self._level_index = {
		"streaming_level",
		"germany_zone",
		"zone_germany",
		"flakturm",
		"gold_rush",
		"train_yard",
		"ger_bridge",
		"ger_bridge_operation",
		"radio_defense",
		"settlement",
		"forest_gumpy",
		"tutorial",
		"bunker_test",
		"tnd",
		"hunters",
		"convoy",
		"spies_test",
		"sto",
		"silo",
		"kelly",
		"fury_railway"
	}
	self.escape_levels = {}
end

function LevelsTweakData:get_level_index()
	return self._level_index
end

function LevelsTweakData:get_world_name_from_index(index)
	if not self._level_index[index] then
		return
	end

	return self[self._level_index[index]].world_name
end

function LevelsTweakData:get_level_name_from_index(index)
	return self._level_index[index]
end

function LevelsTweakData:get_index_from_world_name(world_name)
	for index, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return index
		end
	end
end

function LevelsTweakData:get_index_from_level_id(level_id)
	for index, entry_name in ipairs(self._level_index) do
		if entry_name == level_id then
			return index
		end
	end
end

function LevelsTweakData:requires_dlc(level_id)
	return self[level_id].dlc
end

function LevelsTweakData:requires_dlc_by_index(index)
	return self[self._level_index[index]].dlc
end

function LevelsTweakData:get_level_name_from_world_name(world_name)
	for _, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return entry_name
		end
	end
end

function LevelsTweakData:get_localized_level_name_from_world_name(world_name)
	for _, entry_name in ipairs(self._level_index) do
		if world_name == self[entry_name].world_name then
			return managers.localization:text(self[entry_name].name_id)
		end
	end
end

function LevelsTweakData:get_localized_level_name_from_level_id(level_id)
	for _, entry_name in ipairs(self._level_index) do
		if level_id == entry_name then
			return managers.localization:text(self[entry_name].name_id)
		end
	end
end

function LevelsTweakData:get_default_team_ID(type)
	local lvl_tweak = self[Global.level_data.level_id]

	if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
		if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
			return lvl_tweak.default_teams[type]
		else
			debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ", lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
		end
	end

	if type == "player" then
		return "criminal1"
	elseif type == "combatant" then
		return "law1"
	elseif type == "non_combatant" then
		return "neutral1"
	else
		return "mobster1"
	end
end

function LevelsTweakData:get_team_setup()
	local lvl_tweak

	if Application:editor() and managers.editor then
		lvl_tweak = self[managers.editor:layer("Level Settings"):get_setting("simulation_level_id")]
	else
		lvl_tweak = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	end

	local teams = lvl_tweak and lvl_tweak.teams

	if teams then
		teams = deep_clone(teams)
	else
		teams = {
			criminal1 = {
				foes = {
					law1 = true,
					mobster1 = true
				}
			},
			law1 = {
				foes = {
					converted_enemy = true,
					criminal1 = true,
					mobster1 = true
				}
			},
			mobster1 = {
				foes = {
					converted_enemy = true,
					law1 = true,
					criminal1 = true
				}
			},
			converted_enemy = {
				foes = {
					law1 = true,
					mobster1 = true
				}
			},
			neutral1 = {
				foes = {}
			},
			hacked_turret = {
				foes = {
					law1 = true,
					mobster1 = true
				}
			}
		}

		for id, team in pairs(teams) do
			team.id = id
		end
	end

	return teams
end

function LevelsTweakData:get_default_team_IDs()
	local lvl_tweak

	if Application:editor() and managers.editor then
		lvl_tweak = self[managers.editor:layer("Level Settings"):get_setting("simulation_level_id")]
	else
		lvl_tweak = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	end

	local default_team_IDs = lvl_tweak and lvl_tweak.default_teams

	default_team_IDs = default_team_IDs or {
		player = self:get_default_team_ID("player"),
		combatant = self:get_default_team_ID("combatant"),
		non_combatant = self:get_default_team_ID("non_combatant"),
		gangster = self:get_default_team_ID("gangster")
	}

	return default_team_IDs
end

function LevelsTweakData:get_team_names_indexed()
	local teams_index = self._teams_index

	if not teams_index then
		teams_index = {}

		local teams = self:get_team_setup()

		for team_id, team_data in pairs(teams) do
			table.insert(teams_index, team_id)
		end

		table.sort(teams_index)

		self._teams_index = teams_index
	end

	return teams_index
end

function LevelsTweakData:get_team_index(team_id)
	local teams_index = self:get_team_names_indexed()

	for index, test_team_id in ipairs(teams_index) do
		if team_id == test_team_id then
			return index
		end
	end
end
