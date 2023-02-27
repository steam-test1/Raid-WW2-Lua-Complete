SkillTreeTweakData = SkillTreeTweakData or class()
SkillTreeTweakData.CLASS_RECON = "recon"
SkillTreeTweakData.CLASS_ASSAULT = "assault"
SkillTreeTweakData.CLASS_INFILTRATOR = "infiltrator"
SkillTreeTweakData.CLASS_DEMOLITIONS = "demolitions"
SkillTreeTweakData.STARTING_SUBCLASS_LEVEL = 5

function SkillTreeTweakData:init(tweak_data)
	self:_init_classes(tweak_data)
	self:_init_skill_list()

	self.skill_trees = {}

	self:_init_recon_skill_tree()
	self:_init_assault_skill_tree()
	self:_init_infiltrator_skill_tree()
	self:_init_demolitions_skill_tree()

	self.automatic_unlock_progressions = {}
	self.default_weapons = {}

	self:_init_recon_unlock_progression()
	self:_init_assault_unlock_progression()
	self:_init_infiltrator_unlock_progression()
	self:_init_demolitions_unlock_progression()
	self:_create_class_warcry_data()
end

function SkillTreeTweakData:_create_class_warcry_data()
	self.class_warcry_data = {}

	for class_name, class_data in pairs(self.classes) do
		self.class_warcry_data[class_name] = {}

		for level, skilltree_data in pairs(self.skill_trees[class_name]) do
			for _, skill_data in pairs(skilltree_data) do
				local aquires_field = self.skills[skill_data.skill_name] and self.skills[skill_data.skill_name].acquires

				if aquires_field then
					for _, acquires_item in pairs(aquires_field) do
						if acquires_item.warcry then
							self.class_warcry_data[class_name] = acquires_item.warcry
						end
					end
				else
					Application:debug("[SkillTreeTweakData:_create_class_warcry_data] no aquires_field")
				end
			end
		end
	end
end

function SkillTreeTweakData:_init_classes(tweak_data)
	self.classes = {}
	self.base_classes = {
		"recon",
		"assault",
		"infiltrator",
		"demolitions"
	}
	self.icon_texture = "ui/main_menu/textures/class_stats_icons"
	self.icon_size_width = 128
	self.icon_size_height = 96
	self.classes.recon = {
		name = "recon",
		default_natioanlity = "british",
		name_id = "skill_class_recon_name",
		desc_id = "skill_class_recon_desc",
		icon = {
			x = 0,
			y = 0
		},
		icon_texture_rect_mission_join = {
			0,
			512,
			64,
			64
		},
		stats = {
			speed = 162,
			stamina = 68,
			health = 12
		},
		icon_data = tweak_data.gui.icons.ico_class_recon,
		subclasses = {
			"scout",
			"sniper"
		}
	}
	self.classes.recon.subclasses.scout = {
		name_id = "skill_class_scout_name",
		name = "scout",
		desc_id = "skill_class_scout_desc",
		icon = {
			x = 256,
			y = 0
		}
	}
	self.classes.recon.subclasses.sniper = {
		name_id = "skill_class_sniper_name",
		name = "sniper",
		desc_id = "skill_class_sniper_desc",
		icon = {
			x = 128,
			y = 0
		}
	}
	self.classes.assault = {
		name = "assault",
		default_natioanlity = "american",
		name_id = "skill_class_assault_name",
		desc_id = "skill_class_assault_desc",
		icon = {
			x = 384,
			y = 0
		},
		icon_texture_rect_mission_join = {
			192,
			512,
			64,
			64
		},
		stats = {
			speed = 163,
			stamina = 69,
			health = 13
		},
		icon_data = tweak_data.gui.icons.ico_class_assault,
		subclasses = {
			"rifleman",
			"sentry"
		}
	}
	self.classes.assault.subclasses.rifleman = {
		name_id = "skill_class_rifleman_name",
		name = "rifleman",
		desc_id = "skill_class_rifleman_desc",
		icon = {
			x = 640,
			y = 0
		}
	}
	self.classes.assault.subclasses.sentry = {
		name_id = "skill_class_sentry_name",
		name = "sentry",
		desc_id = "skill_class_sentry_desc",
		icon = {
			x = 512,
			y = 0
		}
	}
	self.classes.demolitions = {
		name = "demolitions",
		default_natioanlity = "german",
		name_id = "skill_class_demolitions_name",
		desc_id = "skill_class_demolitions_desc",
		icon = {
			x = 0,
			y = 96
		},
		icon_texture_rect_mission_join = {
			384,
			512,
			64,
			64
		},
		stats = {
			speed = 164,
			stamina = 70,
			health = 14
		},
		icon_data = tweak_data.gui.icons.ico_class_demolitions,
		subclasses = {
			"sapper",
			"grenadier"
		}
	}
	self.classes.demolitions.subclasses.sapper = {
		name_id = "skill_class_sapper_name",
		name = "sapper",
		desc_id = "skill_class_sapper_desc",
		icon = {
			x = 256,
			y = 96
		}
	}
	self.classes.demolitions.subclasses.grenadier = {
		name_id = "skill_class_grenadier_name",
		name = "grenadier",
		desc_id = "skill_class_grenadier_desc",
		icon = {
			x = 128,
			y = 96
		}
	}
	self.classes.infiltrator = {
		name = "infiltrator",
		default_natioanlity = "russian",
		name_id = "skill_class_infiltrator_name",
		desc_id = "skill_class_infiltrator_desc",
		icon = {
			x = 0,
			y = 96
		},
		icon_texture_rect_mission_join = {
			384,
			512,
			64,
			64
		},
		stats = {
			speed = 165,
			stamina = 71,
			health = 15
		},
		icon_data = tweak_data.gui.icons.ico_class_infiltrator
	}
end

function SkillTreeTweakData:_init_skill_list()
	self.skills = {
		skill_empty_placeholder = {
			icon_large = "skill_warcry_placeholder",
			desc_id = "skill_empty_placeholder_desc",
			name_id = "skill_empty_placeholder_name",
			icon = "skill_warcry_placeholder",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {}
		},
		skill_empty_placeholder_garand = {
			name_id = "skill_empty_placeholder_name",
			desc_id = "skill_empty_placeholder_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"garand"
			}
		},
		warcry_level_increase = {
			icon_large = "skill_warcry_placeholder",
			desc_id = "skill_warcry_level_increase_desc",
			name_id = "skill_warcry_level_increase_name",
			icon = "skill_warcry_placeholder",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry_level = 1
				}
			},
			upgrades = {}
		},
		warcry_sharpshooter = {
			icon_large = "skills_warcry_recon_sharpshooter_large",
			desc_id = "skill_warcry_sharpshooter_desc",
			name_id = "skill_warcry_sharpshooter_name",
			icon = "skills_warcry_recon_sharpshooter",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry = "sharpshooter"
				}
			},
			upgrades = {
				"player_can_use_scope",
				"player_highlight_enemy"
			}
		},
		warcry_sharpshooter_level_increase = {
			icon_large = "skills_warcry_recon_sharpshooter_large",
			desc_id = "skill_warcry_level_increase_desc",
			name_id = "skill_warcry_sharpshooter_level_increase_name",
			icon = "skills_warcry_recon_sharpshooter",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry_level = 1
				}
			},
			upgrades = {}
		},
		warcry_berserk = {
			icon_large = "skills_warcry_assault_berserk_large",
			desc_id = "skill_warcry_berserk_desc",
			name_id = "skill_warcry_berserk_name",
			icon = "skills_warcry_assault_berserk",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry = "berserk"
				}
			},
			upgrades = {
				"player_can_use_scope",
				"player_highlight_enemy"
			}
		},
		warcry_berserk_level_increase = {
			icon_large = "skills_warcry_assault_berserk_large",
			desc_id = "skill_warcry_level_increase_desc",
			name_id = "skill_warcry_berserk_level_increase_name",
			icon = "skills_warcry_assault_berserk",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry_level = 1
				}
			},
			upgrades = {}
		},
		warcry_ghost = {
			icon_large = "skills_warcry_infilitrator_invisibility_large",
			desc_id = "skill_warcry_ghost_desc",
			name_id = "skill_warcry_ghost_name",
			icon = "skills_warcry_infilitrator_invisibility",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry = "ghost"
				}
			},
			upgrades = {
				"player_can_use_scope",
				"player_highlight_enemy"
			}
		},
		warcry_ghost_level_increase = {
			icon_large = "skills_warcry_infilitrator_invisibility_large",
			desc_id = "skill_warcry_level_increase_desc",
			name_id = "skill_warcry_ghost_level_increase_name",
			icon = "skills_warcry_infilitrator_invisibility",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry_level = 1
				}
			},
			upgrades = {}
		},
		warcry_clustertruck = {
			icon_large = "skills_warcry_demolition_cluster_truck_large",
			desc_id = "skill_warcry_clustertruck_desc",
			name_id = "skill_warcry_clustertruck_name",
			icon = "skills_warcry_demolition_cluster_truck",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry = "clustertruck"
				}
			},
			upgrades = {
				"player_can_use_scope",
				"player_highlight_enemy"
			}
		},
		warcry_clustertruck_level_increase = {
			icon_large = "skills_warcry_demolition_cluster_truck_large",
			desc_id = "skill_warcry_level_increase_desc",
			name_id = "skill_warcry_clustertruck_level_increase_name",
			icon = "skills_warcry_demolition_cluster_truck",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					warcry_level = 1
				}
			},
			upgrades = {}
		},
		warcry_duration_1 = {
			icon_large = "skills_warcry_common_upgrade_duration_lvl1_large",
			desc_id = "skill_warcry_duration_increase_desc",
			name_id = "skill_warcry_duration_increase_name",
			icon = "warcry_common_upgrade_duration_lvl1",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_duration_1"
			}
		},
		warcry_duration_2 = {
			icon_large = "skills_warcry_common_upgrade_duration_lvl2_large",
			desc_id = "skill_warcry_duration_increase_desc",
			name_id = "skill_warcry_duration_increase_name",
			icon = "warcry_common_upgrade_duration_lvl2",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_duration_2"
			}
		},
		warcry_duration_3 = {
			icon_large = "skills_warcry_common_upgrade_duration_lvl3_large",
			desc_id = "skill_warcry_duration_increase_desc",
			name_id = "skill_warcry_duration_increase_name",
			icon = "warcry_common_upgrade_duration_lvl3",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_duration_3"
			}
		},
		warcry_duration_4 = {
			icon_large = "skills_warcry_common_upgrade_duration_lvl4_large",
			desc_id = "skill_warcry_duration_increase_desc",
			name_id = "skill_warcry_duration_increase_name",
			icon = "warcry_common_upgrade_duration_lvl4",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_duration_4"
			}
		},
		warcry_team_damage_buff_1 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_increased_damage_large",
			desc_id = "skill_warcry_team_damage_buff_desc",
			name_id = "skill_warcry_team_damage_buff_name",
			icon = "warcry_recon_sharpshooter_upgrade_increased_damage",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_buff_bonus_1"
			}
		},
		warcry_team_damage_buff_2 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_increased_damage_large",
			desc_id = "skill_warcry_team_damage_buff_desc",
			name_id = "skill_warcry_team_damage_buff_name",
			icon = "warcry_recon_sharpshooter_upgrade_increased_damage",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_buff_bonus_2"
			}
		},
		warcry_team_damage_buff_3 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_increased_damage_large",
			desc_id = "skill_warcry_team_damage_buff_desc",
			name_id = "skill_warcry_team_damage_buff_name",
			icon = "warcry_recon_sharpshooter_upgrade_increased_damage",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_buff_bonus_3"
			}
		},
		warcry_team_damage_buff_4 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_increased_damage_large",
			desc_id = "skill_warcry_team_damage_buff_desc",
			name_id = "skill_warcry_team_damage_buff_name",
			icon = "warcry_recon_sharpshooter_upgrade_increased_damage",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_buff_bonus_4"
			}
		},
		warcry_headshot_multiplier_bonus_1 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_headshot_large",
			desc_id = "skill_warcry_headshot_bonus_desc",
			name_id = "skill_warcry_headshot_bonus_name",
			icon = "warcry_recon_sharpshooter_upgrade_headshot",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_headshot_multiplier_bonus_1"
			}
		},
		warcry_headshot_multiplier_bonus_2 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_headshot_large",
			desc_id = "skill_warcry_headshot_bonus_desc",
			name_id = "skill_warcry_headshot_bonus_name",
			icon = "warcry_recon_sharpshooter_upgrade_headshot",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_headshot_multiplier_bonus_2"
			}
		},
		warcry_long_range_multiplier_bonus_1 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_long_range_large",
			desc_id = "skill_warcry_long_range_bonus_desc",
			name_id = "skill_warcry_long_range_bonus_name",
			icon = "warcry_recon_sharpshooter_upgrade_long_range",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_long_range_multiplier_bonus_1"
			}
		},
		warcry_long_range_multiplier_bonus_2 = {
			icon_large = "skills_warcry_recon_sharpshooter_upgrade_long_range_large",
			desc_id = "skill_warcry_long_range_bonus_desc",
			name_id = "skill_warcry_long_range_bonus_name",
			icon = "warcry_recon_sharpshooter_upgrade_long_range",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_long_range_multiplier_bonus_2"
			}
		},
		warcry_team_heal_buff_1 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_increased_team_heal_large",
			desc_id = "skill_warcry_team_heal_buff_desc",
			name_id = "skill_warcry_team_heal_buff_name",
			icon = "warcry_assault_berserk_upgrade_increased_team_heal",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_team_heal_bonus_1"
			}
		},
		warcry_team_heal_buff_2 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_increased_team_heal_large",
			desc_id = "skill_warcry_team_heal_buff_desc",
			name_id = "skill_warcry_team_heal_buff_name",
			icon = "warcry_assault_berserk_upgrade_increased_team_heal",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_team_heal_bonus_2"
			}
		},
		warcry_team_heal_buff_3 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_increased_team_heal_large",
			desc_id = "skill_warcry_team_heal_buff_desc",
			name_id = "skill_warcry_team_heal_buff_name",
			icon = "warcry_assault_berserk_upgrade_increased_team_heal",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_team_heal_bonus_3"
			}
		},
		warcry_team_heal_buff_4 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_increased_team_heal_large",
			desc_id = "skill_warcry_team_heal_buff_desc",
			name_id = "skill_warcry_team_heal_buff_name",
			icon = "warcry_assault_berserk_upgrade_increased_team_heal",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_team_heal_bonus_4"
			}
		},
		warcry_dismemberment_multiplier_bonus_1 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_dismemberment_large",
			desc_id = "skill_warcry_dismemberment_bonus_desc",
			name_id = "skill_warcry_dismemberment_bonus_name",
			icon = "warcry_assault_berserk_upgrade_dismemberment",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_dismemberment_multiplier_bonus_1"
			}
		},
		warcry_dismemberment_multiplier_bonus_2 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_dismemberment_large",
			desc_id = "skill_warcry_dismemberment_bonus_desc",
			name_id = "skill_warcry_dismemberment_bonus_name",
			icon = "warcry_assault_berserk_upgrade_dismemberment",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_dismemberment_multiplier_bonus_2"
			}
		},
		warcry_low_health_multiplier_bonus_1 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_low_health_large",
			desc_id = "skill_warcry_low_health_bonus_desc",
			name_id = "skill_warcry_low_health_bonus_name",
			icon = "warcry_assault_berserk_upgrade_low_health",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_low_health_multiplier_bonus_1"
			}
		},
		warcry_low_health_multiplier_bonus_2 = {
			icon_large = "skills_warcry_assault_berserk_upgrade_low_health_large",
			desc_id = "skill_warcry_low_health_bonus_desc",
			name_id = "skill_warcry_low_health_bonus_name",
			icon = "warcry_assault_berserk_upgrade_low_health",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_low_health_multiplier_bonus_2"
			}
		},
		warcry_team_movement_speed_buff_1 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_increased_move_speed_large",
			desc_id = "skill_warcry_team_movement_speed_buff_desc",
			name_id = "skill_warcry_team_movement_speed_buff_name",
			icon = "warcry_insurgent_untouchable_upgrade_increased_move_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_movement_speed_bonus_1"
			}
		},
		warcry_team_movement_speed_buff_2 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_increased_move_speed_large",
			desc_id = "skill_warcry_team_movement_speed_buff_desc",
			name_id = "skill_warcry_team_movement_speed_buff_name",
			icon = "warcry_insurgent_untouchable_upgrade_increased_move_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_movement_speed_bonus_2"
			}
		},
		warcry_team_movement_speed_buff_3 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_increased_move_speed_large",
			desc_id = "skill_warcry_team_movement_speed_buff_desc",
			name_id = "skill_warcry_team_movement_speed_buff_name",
			icon = "warcry_insurgent_untouchable_upgrade_increased_move_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_movement_speed_bonus_3"
			}
		},
		warcry_team_movement_speed_buff_4 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_increased_move_speed_large",
			desc_id = "skill_warcry_team_movement_speed_buff_desc",
			name_id = "skill_warcry_team_movement_speed_buff_name",
			icon = "warcry_insurgent_untouchable_upgrade_increased_move_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_movement_speed_bonus_4"
			}
		},
		warcry_melee_multiplier_bonus_1 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_melee_large",
			desc_id = "skill_warcry_melee_bonus_desc",
			name_id = "skill_warcry_melee_bonus_name",
			icon = "warcry_insurgent_untouchable_upgrade_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_melee_multiplier_bonus_1"
			}
		},
		warcry_melee_multiplier_bonus_2 = {
			icon_large = "skills_warcry_insurgent_untouchable_upgrade_melee_large",
			desc_id = "skill_warcry_melee_bonus_desc",
			name_id = "skill_warcry_melee_bonus_name",
			icon = "warcry_insurgent_untouchable_upgrade_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_melee_multiplier_bonus_2"
			}
		},
		warcry_short_range_multiplier_bonus_1 = {
			icon_large = "skills_warcry_insurgent_untouchable_short_range_bonus_large",
			desc_id = "skill_warcry_short_range_bonus_desc",
			name_id = "skill_warcry_short_range_bonus_name",
			icon = "warcry_insurgent_untouchable_short_range_bonus",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_short_range_multiplier_bonus_1"
			}
		},
		warcry_short_range_multiplier_bonus_2 = {
			icon_large = "skills_warcry_insurgent_untouchable_short_range_bonus_large",
			desc_id = "skill_warcry_short_range_bonus_desc",
			name_id = "skill_warcry_short_range_bonus_name",
			icon = "warcry_insurgent_untouchable_short_range_bonus",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_short_range_multiplier_bonus_2"
			}
		},
		warcry_team_damage_reduction_buff_1 = {
			icon_large = "skills_warcry_demolition_cluster_truck_damage_resist_large",
			desc_id = "skill_warcry_team_damage_reduction_buff_desc",
			name_id = "skill_warcry_team_damage_reduction_buff_name",
			icon = "warcry_demolition_cluster_truck_damage_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_reduction_bonus_on_activate_1"
			}
		},
		warcry_team_damage_reduction_buff_2 = {
			icon_large = "skills_warcry_demolition_cluster_truck_damage_resist_large",
			desc_id = "skill_warcry_team_damage_reduction_buff_desc",
			name_id = "skill_warcry_team_damage_reduction_buff_name",
			icon = "warcry_demolition_cluster_truck_damage_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_reduction_bonus_on_activate_2"
			}
		},
		warcry_team_damage_reduction_buff_3 = {
			icon_large = "skills_warcry_demolition_cluster_truck_damage_resist_large",
			desc_id = "skill_warcry_team_damage_reduction_buff_desc",
			name_id = "skill_warcry_team_damage_reduction_buff_name",
			icon = "warcry_demolition_cluster_truck_damage_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_reduction_bonus_on_activate_3"
			}
		},
		warcry_team_damage_reduction_buff_4 = {
			icon_large = "skills_warcry_demolition_cluster_truck_damage_resist_large",
			desc_id = "skill_warcry_team_damage_reduction_buff_desc",
			name_id = "skill_warcry_team_damage_reduction_buff_name",
			icon = "warcry_demolition_cluster_truck_damage_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_team_damage_reduction_bonus_on_activate_4"
			}
		},
		warcry_explosion_multiplier_bonus_1 = {
			icon_large = "skills_warcry_demolition_cluster_truck_granade_large",
			desc_id = "skill_warcry_explosion_bonus_desc",
			name_id = "skill_warcry_explosion_bonus_name",
			icon = "warcry_demolition_cluster_truck_granade",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_explosions_multiplier_bonus_1"
			}
		},
		warcry_explosion_multiplier_bonus_2 = {
			icon_large = "skills_warcry_demolition_cluster_truck_granade_large",
			desc_id = "skill_warcry_explosion_bonus_desc",
			name_id = "skill_warcry_explosion_bonus_name",
			icon = "warcry_demolition_cluster_truck_granade",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_explosions_multiplier_bonus_2"
			}
		},
		warcry_killstreak_multiplier_bonus_1 = {
			icon_large = "skills_warcry_demolition_cluster_truck_kill_streak_large",
			desc_id = "skill_warcry_killstreak_bonus_desc",
			name_id = "skill_warcry_killstreak_bonus_name",
			icon = "warcry_demolition_cluster_truck_kill_streak",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_killstreak_multiplier_bonus_1"
			}
		},
		warcry_killstreak_multiplier_bonus_2 = {
			icon_large = "skills_warcry_demolition_cluster_truck_kill_streak_large",
			desc_id = "skill_warcry_killstreak_bonus_desc",
			name_id = "skill_warcry_killstreak_bonus_name",
			icon = "warcry_demolition_cluster_truck_kill_streak",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{}
			},
			upgrades = {
				"warcry_player_killstreak_multiplier_bonus_2"
			}
		},
		subclass_to_scout = {
			name_id = "skill_subclass_to_scout_name",
			desc_id = "skill_subclass_to_scout_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					subclass = "scout"
				}
			},
			upgrades = {
				"player_highlight_enemy"
			}
		},
		subclass_to_rifleman = {
			name_id = "skill_subclass_to_rifleman_name",
			desc_id = "skill_subclass_to_rifleman_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					subclass = "rifleman"
				}
			},
			upgrades = {}
		},
		subclass_to_sentry = {
			name_id = "skill_subclass_to_sentry_name",
			desc_id = "skill_subclass_to_sentry_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					subclass = "sentry"
				}
			},
			upgrades = {}
		},
		subclass_to_sapper = {
			name_id = "skill_subclass_to_sapper_name",
			desc_id = "skill_subclass_to_sapper_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					subclass = "sapper"
				}
			},
			upgrades = {}
		},
		subclass_to_grenadier = {
			name_id = "skill_subclass_to_grenadier_name",
			desc_id = "skill_subclass_to_grenadier_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					subclass = "grenadier"
				}
			},
			upgrades = {}
		},
		undetectable_by_spotters = {
			name_id = "skill_undetectable_by_spotters_name",
			desc_id = "skill_undetectable_by_spotters_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_undetectable_by_spotters"
			}
		},
		player_critical_hit_chance_1 = {
			stat_desc_id = "skill_player_critical_hit_chance_stat_line",
			icon_large = "skills_dealing_damage_critical_chance_large",
			desc_id = "skill_player_critical_hit_chance_desc",
			name_id = "skill_player_critical_hit_chance_name",
			icon = "skills_dealing_damage_critical_chance",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_critical_hit_chance_1"
			}
		},
		player_critical_hit_chance_2 = {
			stat_desc_id = "skill_player_critical_hit_chance_stat_line",
			icon_large = "skills_dealing_damage_critical_chance_large",
			desc_id = "skill_player_critical_hit_chance_desc",
			name_id = "skill_player_critical_hit_chance_name",
			icon = "skills_dealing_damage_critical_chance",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_critical_hit_chance_2"
			}
		},
		player_critical_hit_chance_3 = {
			stat_desc_id = "skill_player_critical_hit_chance_stat_line",
			icon_large = "skills_dealing_damage_critical_chance_large",
			desc_id = "skill_player_critical_hit_chance_desc",
			name_id = "skill_player_critical_hit_chance_name",
			icon = "skills_dealing_damage_critical_chance",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_critical_hit_chance_3"
			}
		},
		player_critical_hit_chance_4 = {
			stat_desc_id = "skill_player_critical_hit_chance_stat_line",
			icon_large = "skills_dealing_damage_critical_chance_large",
			desc_id = "skill_player_critical_hit_chance_desc",
			name_id = "skill_player_critical_hit_chance_name",
			icon = "skills_dealing_damage_critical_chance",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_critical_hit_chance_4"
			}
		},
		stamina_multiplier_1 = {
			stat_desc_id = "skill_stamina_multiplier_stat_line",
			icon_large = "skills_navigation_stamina_reserve_large",
			desc_id = "skill_stamina_multiplier_desc",
			name_id = "skill_stamina_multiplier_name",
			icon = "skills_navigation_stamina_reserve",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_multiplier_1"
			}
		},
		stamina_multiplier_2 = {
			stat_desc_id = "skill_stamina_multiplier_stat_line",
			icon_large = "skills_navigation_stamina_reserve_large",
			desc_id = "skill_stamina_multiplier_desc",
			name_id = "skill_stamina_multiplier_name",
			icon = "skills_navigation_stamina_reserve",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_multiplier_2"
			}
		},
		stamina_multiplier_3 = {
			stat_desc_id = "skill_stamina_multiplier_stat_line",
			icon_large = "skills_navigation_stamina_reserve_large",
			desc_id = "skill_stamina_multiplier_desc",
			name_id = "skill_stamina_multiplier_name",
			icon = "skills_navigation_stamina_reserve",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_multiplier_3"
			}
		},
		stamina_multiplier_4 = {
			stat_desc_id = "skill_stamina_multiplier_stat_line",
			icon_large = "skills_navigation_stamina_reserve_large",
			desc_id = "skill_stamina_multiplier_desc",
			name_id = "skill_stamina_multiplier_name",
			icon = "skills_navigation_stamina_reserve",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_multiplier_4"
			}
		},
		stamina_regeneration_increase_1 = {
			stat_desc_id = "skill_stamina_regeneration_increase_stat_line",
			icon_large = "skills_navigation_stamina_regeneration_large",
			desc_id = "skill_stamina_regeneration_increase_desc",
			name_id = "skill_stamina_regeneration_increase_name",
			icon = "skills_navigation_stamina_regeneration",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_regeneration_increase_1"
			}
		},
		stamina_regeneration_increase_2 = {
			stat_desc_id = "skill_stamina_regeneration_increase_stat_line",
			icon_large = "skills_navigation_stamina_regeneration_large",
			desc_id = "skill_stamina_regeneration_increase_desc",
			name_id = "skill_stamina_regeneration_increase_name",
			icon = "skills_navigation_stamina_regeneration",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_regeneration_increase_2"
			}
		},
		stamina_regeneration_increase_3 = {
			stat_desc_id = "skill_stamina_regeneration_increase_stat_line",
			icon_large = "skills_navigation_stamina_regeneration_large",
			desc_id = "skill_stamina_regeneration_increase_desc",
			name_id = "skill_stamina_regeneration_increase_name",
			icon = "skills_navigation_stamina_regeneration",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_regeneration_increase_3"
			}
		},
		stamina_regeneration_increase_4 = {
			stat_desc_id = "skill_stamina_regeneration_increase_stat_line",
			icon_large = "skills_navigation_stamina_regeneration_large",
			desc_id = "skill_stamina_regeneration_increase_desc",
			name_id = "skill_stamina_regeneration_increase_name",
			icon = "skills_navigation_stamina_regeneration",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_stamina_regeneration_increase_4"
			}
		},
		max_health_multiplier_1 = {
			stat_desc_id = "skill_max_health_multiplier_stat_line",
			icon_large = "skills_soaking_damage_increased_health_large",
			desc_id = "skill_max_health_multiplier_desc",
			name_id = "skill_max_health_multiplier_name",
			icon = "skills_soaking_damage_increased_health",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_max_health_multiplier_1"
			}
		},
		max_health_multiplier_2 = {
			stat_desc_id = "skill_max_health_multiplier_stat_line",
			icon_large = "skills_soaking_damage_increased_health_large",
			desc_id = "skill_max_health_multiplier_desc",
			name_id = "skill_max_health_multiplier_name",
			icon = "skills_soaking_damage_increased_health",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_max_health_multiplier_2"
			}
		},
		max_health_multiplier_3 = {
			stat_desc_id = "skill_max_health_multiplier_stat_line",
			icon_large = "skills_soaking_damage_increased_health_large",
			desc_id = "skill_max_health_multiplier_desc",
			name_id = "skill_max_health_multiplier_name",
			icon = "skills_soaking_damage_increased_health",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_max_health_multiplier_3"
			}
		},
		max_health_multiplier_4 = {
			stat_desc_id = "skill_max_health_multiplier_stat_line",
			icon_large = "skills_soaking_damage_increased_health_large",
			desc_id = "skill_max_health_multiplier_desc",
			name_id = "skill_max_health_multiplier_name",
			icon = "skills_soaking_damage_increased_health",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_max_health_multiplier_4"
			}
		},
		pick_up_ammo_multiplier_1 = {
			stat_desc_id = "skill_pick_up_ammo_multiplier_stat_line",
			icon_large = "skills_interaction_extra_ammo_pickups_large",
			desc_id = "skill_pick_up_ammo_multiplier_desc",
			name_id = "skill_pick_up_ammo_multiplier_name",
			icon = "skills_interaction_extra_ammo_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_ammo_multiplier_1"
			}
		},
		pick_up_ammo_multiplier_2 = {
			stat_desc_id = "skill_pick_up_ammo_multiplier_stat_line",
			icon_large = "skills_interaction_extra_ammo_pickups_large",
			desc_id = "skill_pick_up_ammo_multiplier_desc",
			name_id = "skill_pick_up_ammo_multiplier_name",
			icon = "skills_interaction_extra_ammo_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_ammo_multiplier_2"
			}
		},
		pick_up_ammo_multiplier_3 = {
			stat_desc_id = "skill_pick_up_ammo_multiplier_stat_line",
			icon_large = "skills_interaction_extra_ammo_pickups_large",
			desc_id = "skill_pick_up_ammo_multiplier_desc",
			name_id = "skill_pick_up_ammo_multiplier_name",
			icon = "skills_interaction_extra_ammo_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_ammo_multiplier_3"
			}
		},
		pick_up_ammo_multiplier_4 = {
			stat_desc_id = "skill_pick_up_ammo_multiplier_stat_line",
			icon_large = "skills_interaction_extra_ammo_pickups_large",
			desc_id = "skill_pick_up_ammo_multiplier_desc",
			name_id = "skill_pick_up_ammo_multiplier_name",
			icon = "skills_interaction_extra_ammo_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_ammo_multiplier_4"
			}
		},
		pick_up_health_multiplier_mg42 = {
			name_id = "skill_pick_up_health_multiplier_1_name",
			desc_id = "skill_pick_up_health_multiplier_1_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_health_multiplier_1",
				"mg42"
			}
		},
		pick_up_health_multiplier_1 = {
			stat_desc_id = "skill_pick_up_health_multiplier_stat_line",
			icon_large = "skills_interaction_extra_health_pickups_large",
			desc_id = "skill_pick_up_health_multiplier_desc",
			name_id = "skill_pick_up_health_multiplier_name",
			icon = "skills_interaction_extra_health_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_health_multiplier_1"
			}
		},
		pick_up_health_multiplier_2 = {
			stat_desc_id = "skill_pick_up_health_multiplier_stat_line",
			icon_large = "skills_interaction_extra_health_pickups_large",
			desc_id = "skill_pick_up_health_multiplier_desc",
			name_id = "skill_pick_up_health_multiplier_name",
			icon = "skills_interaction_extra_health_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_health_multiplier_2"
			}
		},
		pick_up_health_multiplier_3 = {
			stat_desc_id = "skill_pick_up_health_multiplier_stat_line",
			icon_large = "skills_interaction_extra_health_pickups_large",
			desc_id = "skill_pick_up_health_multiplier_desc",
			name_id = "skill_pick_up_health_multiplier_name",
			icon = "skills_interaction_extra_health_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_health_multiplier_3"
			}
		},
		pick_up_health_multiplier_4 = {
			stat_desc_id = "skill_pick_up_health_multiplier_stat_line",
			icon_large = "skills_interaction_extra_health_pickups_large",
			desc_id = "skill_pick_up_health_multiplier_desc",
			name_id = "skill_pick_up_health_multiplier_name",
			icon = "skills_interaction_extra_health_pickups",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_pick_up_health_multiplier_4"
			}
		},
		primary_ammo_capacity_increase_1 = {
			stat_desc_id = "skill_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_prim_ammo_capacity_large",
			desc_id = "skill_ammo_capacity_increase_desc",
			name_id = "skill_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_prim_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_primary_ammo_increase_1"
			}
		},
		primary_ammo_capacity_increase_2 = {
			stat_desc_id = "skill_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_prim_ammo_capacity_large",
			desc_id = "skill_ammo_capacity_increase_desc",
			name_id = "skill_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_prim_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_primary_ammo_increase_2"
			}
		},
		primary_ammo_capacity_increase_3 = {
			stat_desc_id = "skill_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_prim_ammo_capacity_large",
			desc_id = "skill_ammo_capacity_increase_desc",
			name_id = "skill_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_prim_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_primary_ammo_increase_3"
			}
		},
		primary_ammo_capacity_increase_4 = {
			stat_desc_id = "skill_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_prim_ammo_capacity_large",
			desc_id = "skill_ammo_capacity_increase_desc",
			name_id = "skill_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_prim_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_primary_ammo_increase_4"
			}
		},
		secondary_ammo_capacity_increase_1 = {
			stat_desc_id = "skill_secondary_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_sec_ammo_capacity_large",
			desc_id = "skill_secondary_ammo_capacity_increase_desc",
			name_id = "skill_secondary_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_sec_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_secondary_ammo_increase_1"
			}
		},
		secondary_ammo_capacity_increase_2 = {
			stat_desc_id = "skill_secondary_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_sec_ammo_capacity_large",
			desc_id = "skill_secondary_ammo_capacity_increase_desc",
			name_id = "skill_secondary_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_sec_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_secondary_ammo_increase_2"
			}
		},
		secondary_ammo_capacity_increase_3 = {
			stat_desc_id = "skill_secondary_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_sec_ammo_capacity_large",
			desc_id = "skill_secondary_ammo_capacity_increase_desc",
			name_id = "skill_secondary_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_sec_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_secondary_ammo_increase_3"
			}
		},
		secondary_ammo_capacity_increase_4 = {
			stat_desc_id = "skill_secondary_ammo_capacity_increase_stat_line",
			icon_large = "skills_special_skills_increase_sec_ammo_capacity_large",
			desc_id = "skill_secondary_ammo_capacity_increase_desc",
			name_id = "skill_secondary_ammo_capacity_increase_name",
			icon = "skills_special_skills_increase_sec_ammo_capacity",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_secondary_ammo_increase_4"
			}
		},
		reload_speed_multiplier_1 = {
			stat_desc_id = "skill_reload_speed_multiplier_stat_line",
			icon_large = "skills_general_faster_reload_large",
			desc_id = "skill_reload_speed_multiplier_desc",
			name_id = "skill_reload_speed_multiplier_name",
			icon = "skills_general_faster_reload",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"primary_weapon_reload_speed_multiplier_1",
				"secondary_weapon_reload_speed_multiplier_1"
			}
		},
		reload_speed_multiplier_2 = {
			stat_desc_id = "skill_reload_speed_multiplier_stat_line",
			icon_large = "skills_general_faster_reload_large",
			desc_id = "skill_reload_speed_multiplier_desc",
			name_id = "skill_reload_speed_multiplier_name",
			icon = "skills_general_faster_reload",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"primary_weapon_reload_speed_multiplier_2",
				"secondary_weapon_reload_speed_multiplier_2"
			}
		},
		reload_speed_multiplier_3 = {
			stat_desc_id = "skill_reload_speed_multiplier_stat_line",
			icon_large = "skills_general_faster_reload_large",
			desc_id = "skill_reload_speed_multiplier_desc",
			name_id = "skill_reload_speed_multiplier_name",
			icon = "skills_general_faster_reload",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"primary_weapon_reload_speed_multiplier_3",
				"secondary_weapon_reload_speed_multiplier_3"
			}
		},
		reload_speed_multiplier_4 = {
			stat_desc_id = "skill_reload_speed_multiplier_stat_line",
			icon_large = "skills_general_faster_reload_large",
			desc_id = "skill_reload_speed_multiplier_desc",
			name_id = "skill_reload_speed_multiplier_name",
			icon = "skills_general_faster_reload",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"primary_weapon_reload_speed_multiplier_4",
				"secondary_weapon_reload_speed_multiplier_4"
			}
		},
		increase_general_speed_1 = {
			stat_desc_id = "skill_increase_general_speed_stat_line",
			icon_large = "skills_general_speed_large",
			desc_id = "skill_increase_general_speed_desc",
			name_id = "skill_increase_general_speed_name",
			icon = "skills_general_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_all_movement_speed_increase_1"
			}
		},
		increase_general_speed_2 = {
			stat_desc_id = "skill_increase_general_speed_stat_line",
			icon_large = "skills_general_speed_large",
			desc_id = "skill_increase_general_speed_desc",
			name_id = "skill_increase_general_speed_name",
			icon = "skills_general_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_all_movement_speed_increase_2"
			}
		},
		increase_general_speed_3 = {
			stat_desc_id = "skill_increase_general_speed_stat_line",
			icon_large = "skills_general_speed_large",
			desc_id = "skill_increase_general_speed_desc",
			name_id = "skill_increase_general_speed_name",
			icon = "skills_general_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_all_movement_speed_increase_3"
			}
		},
		increase_general_speed_4 = {
			stat_desc_id = "skill_increase_general_speed_stat_line",
			icon_large = "skills_general_speed_large",
			desc_id = "skill_increase_general_speed_desc",
			name_id = "skill_increase_general_speed_name",
			icon = "skills_general_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_all_movement_speed_increase_4"
			}
		},
		increase_run_speed_1 = {
			stat_desc_id = "skill_increase_run_speed_stat_line",
			icon_large = "skills_navigation_increase_run_speed_large",
			desc_id = "skill_increase_run_speed_desc",
			name_id = "skill_increase_run_speed_name",
			icon = "skills_navigation_increase_run_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_run_speed_increase_1"
			}
		},
		increase_run_speed_2 = {
			stat_desc_id = "skill_increase_run_speed_stat_line",
			icon_large = "skills_navigation_increase_run_speed_large",
			desc_id = "skill_increase_run_speed_desc",
			name_id = "skill_increase_run_speed_name",
			icon = "skills_navigation_increase_run_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_run_speed_increase_2"
			}
		},
		increase_run_speed_3 = {
			stat_desc_id = "skill_increase_run_speed_stat_line",
			icon_large = "skills_navigation_increase_run_speed_large",
			desc_id = "skill_increase_run_speed_desc",
			name_id = "skill_increase_run_speed_name",
			icon = "skills_navigation_increase_run_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_run_speed_increase_3"
			}
		},
		increase_run_speed_4 = {
			stat_desc_id = "skill_increase_run_speed_stat_line",
			icon_large = "skills_navigation_increase_run_speed_large",
			desc_id = "skill_increase_run_speed_desc",
			name_id = "skill_increase_run_speed_name",
			icon = "skills_navigation_increase_run_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_run_speed_increase_4"
			}
		},
		increase_crouch_speed_1 = {
			stat_desc_id = "skill_increase_crouch_speed_stat_line",
			icon_large = "skills_navigation_increase_crouch_speed_large",
			desc_id = "skill_increase_crouch_speed_desc",
			name_id = "skill_increase_crouch_speed_name",
			icon = "skills_navigation_increase_crouch_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouch_speed_increase_1"
			}
		},
		increase_crouch_speed_2 = {
			stat_desc_id = "skill_increase_crouch_speed_stat_line",
			icon_large = "skills_navigation_increase_crouch_speed_large",
			desc_id = "skill_increase_crouch_speed_desc",
			name_id = "skill_increase_crouch_speed_name",
			icon = "skills_navigation_increase_crouch_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouch_speed_increase_2"
			}
		},
		increase_crouch_speed_3 = {
			stat_desc_id = "skill_increase_crouch_speed_stat_line",
			icon_large = "skills_navigation_increase_crouch_speed_large",
			desc_id = "skill_increase_crouch_speed_desc",
			name_id = "skill_increase_crouch_speed_name",
			icon = "skills_navigation_increase_crouch_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouch_speed_increase_3"
			}
		},
		increase_crouch_speed_4 = {
			stat_desc_id = "skill_increase_crouch_speed_stat_line",
			icon_large = "skills_navigation_increase_crouch_speed_large",
			desc_id = "skill_increase_crouch_speed_desc",
			name_id = "skill_increase_crouch_speed_name",
			icon = "skills_navigation_increase_crouch_speed",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouch_speed_increase_4"
			}
		},
		carry_penalty_decrease_1 = {
			stat_desc_id = "skill_carry_penalty_decrease_stat_line",
			icon_large = "skills_navigation_move_faster_bags_large",
			desc_id = "skill_carry_penalty_decrease_desc",
			name_id = "skill_carry_penalty_decrease_name",
			icon = "skills_navigation_move_faster_bags",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_carry_penalty_decrease_1"
			}
		},
		carry_penalty_decrease_2 = {
			stat_desc_id = "skill_carry_penalty_decrease_stat_line",
			icon_large = "skills_navigation_move_faster_bags_large",
			desc_id = "skill_carry_penalty_decrease_desc",
			name_id = "skill_carry_penalty_decrease_name",
			icon = "skills_navigation_move_faster_bags",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_carry_penalty_decrease_2"
			}
		},
		carry_penalty_decrease_3 = {
			stat_desc_id = "skill_carry_penalty_decrease_stat_line",
			icon_large = "skills_navigation_move_faster_bags_large",
			desc_id = "skill_carry_penalty_decrease_desc",
			name_id = "skill_carry_penalty_decrease_name",
			icon = "skills_navigation_move_faster_bags",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_carry_penalty_decrease_3"
			}
		},
		carry_penalty_decrease_4 = {
			stat_desc_id = "skill_carry_penalty_decrease_stat_line",
			icon_large = "skills_navigation_move_faster_bags_large",
			desc_id = "skill_carry_penalty_decrease_desc",
			name_id = "skill_carry_penalty_decrease_name",
			icon = "skills_navigation_move_faster_bags",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_carry_penalty_decrease_4"
			}
		},
		running_damage_reduction_1 = {
			stat_desc_id = "skill_running_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_sprinting_large",
			desc_id = "skill_running_damage_reduction_desc",
			name_id = "skill_running_damage_reduction_name",
			icon = "skills_soaking_damage_less_sprinting",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_running_damage_reduction_1"
			}
		},
		running_damage_reduction_2 = {
			stat_desc_id = "skill_running_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_sprinting_large",
			desc_id = "skill_running_damage_reduction_desc",
			name_id = "skill_running_damage_reduction_name",
			icon = "skills_soaking_damage_less_sprinting",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_running_damage_reduction_2"
			}
		},
		running_damage_reduction_3 = {
			stat_desc_id = "skill_running_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_sprinting_large",
			desc_id = "skill_running_damage_reduction_desc",
			name_id = "skill_running_damage_reduction_name",
			icon = "skills_soaking_damage_less_sprinting",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_running_damage_reduction_3"
			}
		},
		running_damage_reduction_4 = {
			stat_desc_id = "skill_running_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_sprinting_large",
			desc_id = "skill_running_damage_reduction_desc",
			name_id = "skill_running_damage_reduction_name",
			icon = "skills_soaking_damage_less_sprinting",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_running_damage_reduction_4"
			}
		},
		crouching_damage_reduction_1 = {
			stat_desc_id = "skill_crouching_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_while_crouch_large",
			desc_id = "skill_crouching_damage_reduction_desc",
			name_id = "skill_crouching_damage_reduction_name",
			icon = "skills_soaking_damage_less_while_crouch",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouching_damage_reduction_1"
			}
		},
		crouching_damage_reduction_2 = {
			stat_desc_id = "skill_crouching_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_while_crouch_large",
			desc_id = "skill_crouching_damage_reduction_desc",
			name_id = "skill_crouching_damage_reduction_name",
			icon = "skills_soaking_damage_less_while_crouch",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouching_damage_reduction_2"
			}
		},
		crouching_damage_reduction_3 = {
			stat_desc_id = "skill_crouching_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_while_crouch_large",
			desc_id = "skill_crouching_damage_reduction_desc",
			name_id = "skill_crouching_damage_reduction_name",
			icon = "skills_soaking_damage_less_while_crouch",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouching_damage_reduction_3"
			}
		},
		crouching_damage_reduction_4 = {
			stat_desc_id = "skill_crouching_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_while_crouch_large",
			desc_id = "skill_crouching_damage_reduction_desc",
			name_id = "skill_crouching_damage_reduction_name",
			icon = "skills_soaking_damage_less_while_crouch",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_crouching_damage_reduction_4"
			}
		},
		interacting_damage_reduction_1 = {
			stat_desc_id = "skill_interacting_damage_reduction_stat_line",
			icon_large = "skills_interaction_less_damage_interact_large",
			desc_id = "skill_interacting_damage_reduction_desc",
			name_id = "skill_interacting_damage_reduction_name",
			icon = "skills_interaction_less_damage_interact",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_interacting_damage_reduction_1"
			}
		},
		interacting_damage_reduction_2 = {
			stat_desc_id = "skill_interacting_damage_reduction_stat_line",
			icon_large = "skills_interaction_less_damage_interact_large",
			desc_id = "skill_interacting_damage_reduction_desc",
			name_id = "skill_interacting_damage_reduction_name",
			icon = "skills_interaction_less_damage_interact",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_interacting_damage_reduction_2"
			}
		},
		interacting_damage_reduction_3 = {
			stat_desc_id = "skill_interacting_damage_reduction_stat_line",
			icon_large = "skills_interaction_less_damage_interact_large",
			desc_id = "skill_interacting_damage_reduction_desc",
			name_id = "skill_interacting_damage_reduction_name",
			icon = "skills_interaction_less_damage_interact",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_interacting_damage_reduction_3"
			}
		},
		interacting_damage_reduction_4 = {
			stat_desc_id = "skill_interacting_damage_reduction_stat_line",
			icon_large = "skills_interaction_less_damage_interact_large",
			desc_id = "skill_interacting_damage_reduction_desc",
			name_id = "skill_interacting_damage_reduction_name",
			icon = "skills_interaction_less_damage_interact",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_interacting_damage_reduction_4"
			}
		},
		bullet_damage_reduction_1 = {
			stat_desc_id = "skill_bullet_damage_reduction_stat_line",
			icon_large = "skills_general_resist_large",
			desc_id = "skill_bullet_damage_reduction_desc",
			name_id = "skill_bullet_damage_reduction_name",
			icon = "skills_general_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_bullet_damage_reduction_1"
			}
		},
		bullet_damage_reduction_2 = {
			stat_desc_id = "skill_bullet_damage_reduction_stat_line",
			icon_large = "skills_general_resist_large",
			desc_id = "skill_bullet_damage_reduction_desc",
			name_id = "skill_bullet_damage_reduction_name",
			icon = "skills_general_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_bullet_damage_reduction_2"
			}
		},
		bullet_damage_reduction_3 = {
			stat_desc_id = "skill_bullet_damage_reduction_stat_line",
			icon_large = "skills_general_resist_large",
			desc_id = "skill_bullet_damage_reduction_desc",
			name_id = "skill_bullet_damage_reduction_name",
			icon = "skills_general_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_bullet_damage_reduction_3"
			}
		},
		bullet_damage_reduction_4 = {
			stat_desc_id = "skill_bullet_damage_reduction_stat_line",
			icon_large = "skills_general_resist_large",
			desc_id = "skill_bullet_damage_reduction_desc",
			name_id = "skill_bullet_damage_reduction_name",
			icon = "skills_general_resist",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_bullet_damage_reduction_4"
			}
		},
		melee_damage_reduction_1 = {
			stat_desc_id = "skill_melee_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_melee_large",
			desc_id = "skill_melee_damage_reduction_desc",
			name_id = "skill_melee_damage_reduction_name",
			icon = "skills_soaking_damage_less_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_reduction_1"
			}
		},
		melee_damage_reduction_2 = {
			stat_desc_id = "skill_melee_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_melee_large",
			desc_id = "skill_melee_damage_reduction_desc",
			name_id = "skill_melee_damage_reduction_name",
			icon = "skills_soaking_damage_less_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_reduction_2"
			}
		},
		melee_damage_reduction_3 = {
			stat_desc_id = "skill_melee_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_melee_large",
			desc_id = "skill_melee_damage_reduction_desc",
			name_id = "skill_melee_damage_reduction_name",
			icon = "skills_soaking_damage_less_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_reduction_3"
			}
		},
		melee_damage_reduction_4 = {
			stat_desc_id = "skill_melee_damage_reduction_stat_line",
			icon_large = "skills_soaking_damage_less_melee_large",
			desc_id = "skill_melee_damage_reduction_desc",
			name_id = "skill_melee_damage_reduction_name",
			icon = "skills_soaking_damage_less_melee",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_reduction_4"
			}
		},
		headshot_damage_multiplier_1 = {
			stat_desc_id = "skill_headshot_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_headshot_multiplier_large",
			desc_id = "skill_headshot_damage_multiplier_desc",
			name_id = "skill_headshot_damage_multiplier_name",
			icon = "skills_dealing_damage_headshot_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_headshot_damage_multiplier_1"
			}
		},
		headshot_damage_multiplier_2 = {
			stat_desc_id = "skill_headshot_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_headshot_multiplier_large",
			desc_id = "skill_headshot_damage_multiplier_desc",
			name_id = "skill_headshot_damage_multiplier_name",
			icon = "skills_dealing_damage_headshot_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_headshot_damage_multiplier_2"
			}
		},
		headshot_damage_multiplier_3 = {
			stat_desc_id = "skill_headshot_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_headshot_multiplier_large",
			desc_id = "skill_headshot_damage_multiplier_desc",
			name_id = "skill_headshot_damage_multiplier_name",
			icon = "skills_dealing_damage_headshot_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_headshot_damage_multiplier_3"
			}
		},
		headshot_damage_multiplier_4 = {
			stat_desc_id = "skill_headshot_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_headshot_multiplier_large",
			desc_id = "skill_headshot_damage_multiplier_desc",
			name_id = "skill_headshot_damage_multiplier_name",
			icon = "skills_dealing_damage_headshot_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_headshot_damage_multiplier_4"
			}
		},
		melee_damage_multiplier_1 = {
			stat_desc_id = "skill_melee_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_melee_multiplier_large",
			desc_id = "skill_melee_damage_multiplier_desc",
			name_id = "skill_melee_damage_multiplier_name",
			icon = "skills_dealing_damage_melee_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_multiplier_1"
			}
		},
		melee_damage_multiplier_2 = {
			stat_desc_id = "skill_melee_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_melee_multiplier_large",
			desc_id = "skill_melee_damage_multiplier_desc",
			name_id = "skill_melee_damage_multiplier_name",
			icon = "skills_dealing_damage_melee_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_multiplier_2"
			}
		},
		melee_damage_multiplier_3 = {
			stat_desc_id = "skill_melee_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_melee_multiplier_large",
			desc_id = "skill_melee_damage_multiplier_desc",
			name_id = "skill_melee_damage_multiplier_name",
			icon = "skills_dealing_damage_melee_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_melee_damage_multiplier_3"
			}
		},
		highlight_enemy_damage_bonus_1 = {
			stat_desc_id = "skill_highlight_enemy_damage_bonus_stat_line",
			icon_large = "skills_dealing_damage_tagged_enemies_large",
			desc_id = "skill_highlight_enemy_damage_bonus_desc",
			name_id = "skill_highlight_enemy_damage_bonus_name",
			icon = "skills_dealing_damage_tagged_enemies",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_highlight_enemy_damage_bonus_1"
			}
		},
		highlight_enemy_damage_bonus_2 = {
			stat_desc_id = "skill_highlight_enemy_damage_bonus_stat_line",
			icon_large = "skills_dealing_damage_tagged_enemies_large",
			desc_id = "skill_highlight_enemy_damage_bonus_desc",
			name_id = "skill_highlight_enemy_damage_bonus_name",
			icon = "skills_dealing_damage_tagged_enemies",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_highlight_enemy_damage_bonus_2"
			}
		},
		highlight_enemy_damage_bonus_3 = {
			stat_desc_id = "skill_highlight_enemy_damage_bonus_stat_line",
			icon_large = "skills_dealing_damage_tagged_enemies_large",
			desc_id = "skill_highlight_enemy_damage_bonus_desc",
			name_id = "skill_highlight_enemy_damage_bonus_name",
			icon = "skills_dealing_damage_tagged_enemies",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_highlight_enemy_damage_bonus_3"
			}
		},
		highlight_enemy_damage_bonus_4 = {
			stat_desc_id = "skill_highlight_enemy_damage_bonus_stat_line",
			icon_large = "skills_dealing_damage_tagged_enemies_large",
			desc_id = "skill_highlight_enemy_damage_bonus_desc",
			name_id = "skill_highlight_enemy_damage_bonus_name",
			icon = "skills_dealing_damage_tagged_enemies",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_highlight_enemy_damage_bonus_4"
			}
		},
		on_hit_flinch_reduction_1 = {
			stat_desc_id = "skill_on_hit_flinch_reduction_stat_line",
			icon_large = "skills_weapons_reduce_flinch_when_hit_large",
			desc_id = "skill_on_hit_flinch_reduction_desc",
			name_id = "skill_on_hit_flinch_reduction_name",
			icon = "skills_weapons_reduce_flinch_when_hit",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_on_hit_flinch_reduction_1"
			}
		},
		on_hit_flinch_reduction_2 = {
			stat_desc_id = "skill_on_hit_flinch_reduction_stat_line",
			icon_large = "skills_weapons_reduce_flinch_when_hit_large",
			desc_id = "skill_on_hit_flinch_reduction_desc",
			name_id = "skill_on_hit_flinch_reduction_name",
			icon = "skills_weapons_reduce_flinch_when_hit",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_on_hit_flinch_reduction_2"
			}
		},
		on_hit_flinch_reduction_3 = {
			stat_desc_id = "skill_on_hit_flinch_reduction_stat_line",
			icon_large = "skills_weapons_reduce_flinch_when_hit_large",
			desc_id = "skill_on_hit_flinch_reduction_desc",
			name_id = "skill_on_hit_flinch_reduction_name",
			icon = "skills_weapons_reduce_flinch_when_hit",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_on_hit_flinch_reduction_3"
			}
		},
		on_hit_flinch_reduction_4 = {
			stat_desc_id = "skill_on_hit_flinch_reduction_stat_line",
			icon_large = "skills_weapons_reduce_flinch_when_hit_large",
			desc_id = "skill_on_hit_flinch_reduction_desc",
			name_id = "skill_on_hit_flinch_reduction_name",
			icon = "skills_weapons_reduce_flinch_when_hit",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_on_hit_flinch_reduction_4"
			}
		},
		swap_speed_multiplier_1 = {
			stat_desc_id = "skill_swap_speed_multiplier_stat_line",
			icon_large = "skills_weapons_switch_faster_large",
			desc_id = "skill_swap_speed_multiplier_desc",
			name_id = "skill_swap_speed_multiplier_name",
			icon = "skills_weapons_switch_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					player_swap_speed_multiplier = 1
				}
			},
			upgrades = {
				"player_swap_speed_multiplier_1"
			}
		},
		swap_speed_multiplier_2 = {
			stat_desc_id = "skill_swap_speed_multiplier_stat_line",
			icon_large = "skills_weapons_switch_faster_large",
			desc_id = "skill_swap_speed_multiplier_desc",
			name_id = "skill_swap_speed_multiplier_name",
			icon = "skills_weapons_switch_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_swap_speed_multiplier_2"
			}
		},
		swap_speed_multiplier_3 = {
			stat_desc_id = "skill_swap_speed_multiplier_stat_line",
			icon_large = "skills_weapons_switch_faster_large",
			desc_id = "skill_swap_speed_multiplier_desc",
			name_id = "skill_swap_speed_multiplier_name",
			icon = "skills_weapons_switch_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_swap_speed_multiplier_3"
			}
		},
		swap_speed_multiplier_4 = {
			stat_desc_id = "skill_swap_speed_multiplier_stat_line",
			icon_large = "skills_weapons_switch_faster_large",
			desc_id = "skill_swap_speed_multiplier_desc",
			name_id = "skill_swap_speed_multiplier_name",
			icon = "skills_weapons_switch_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_swap_speed_multiplier_4"
			}
		},
		ready_weapon_speed_multiplier_1 = {
			stat_desc_id = "skill_ready_weapon_speed_multiplier_stat_line",
			icon_large = "skills_weapons_ready_faster_after_sprint_large",
			desc_id = "skill_ready_weapon_speed_multiplier_desc",
			name_id = "skill_ready_weapon_speed_multiplier_name",
			icon = "skills_weapons_ready_faster_after_sprint",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_ready_weapon_speed_multiplier_1"
			}
		},
		ready_weapon_speed_multiplier_2 = {
			stat_desc_id = "skill_ready_weapon_speed_multiplier_stat_line",
			icon_large = "skills_weapons_ready_faster_after_sprint_large",
			desc_id = "skill_ready_weapon_speed_multiplier_desc",
			name_id = "skill_ready_weapon_speed_multiplier_name",
			icon = "skills_weapons_ready_faster_after_sprint",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_ready_weapon_speed_multiplier_2"
			}
		},
		ready_weapon_speed_multiplier_3 = {
			stat_desc_id = "skill_ready_weapon_speed_multiplier_stat_line",
			icon_large = "skills_weapons_ready_faster_after_sprint_large",
			desc_id = "skill_ready_weapon_speed_multiplier_desc",
			name_id = "skill_ready_weapon_speed_multiplier_name",
			icon = "skills_weapons_ready_faster_after_sprint",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_ready_weapon_speed_multiplier_3"
			}
		},
		ready_weapon_speed_multiplier_4 = {
			stat_desc_id = "skill_ready_weapon_speed_multiplier_stat_line",
			icon_large = "skills_weapons_ready_faster_after_sprint_large",
			desc_id = "skill_ready_weapon_speed_multiplier_desc",
			name_id = "skill_ready_weapon_speed_multiplier_name",
			icon = "skills_weapons_ready_faster_after_sprint",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_ready_weapon_speed_multiplier_4"
			}
		},
		wheel_hotspot_increase_1 = {
			stat_desc_id = "skill_wheel_hotspot_increase_stat_line",
			icon_large = "skills_interaction_wheel_hotspots_larger_large",
			desc_id = "skill_wheel_hotspot_increase_desc",
			name_id = "skill_wheel_hotspot_increase_name",
			icon = "skills_interaction_wheel_hotspots_larger",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_hotspot_increase_1"
			}
		},
		wheel_hotspot_increase_2 = {
			stat_desc_id = "skill_wheel_hotspot_increase_stat_line",
			icon_large = "skills_interaction_wheel_hotspots_larger_large",
			desc_id = "skill_wheel_hotspot_increase_desc",
			name_id = "skill_wheel_hotspot_increase_name",
			icon = "skills_interaction_wheel_hotspots_larger",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_hotspot_increase_2"
			}
		},
		wheel_hotspot_increase_3 = {
			stat_desc_id = "skill_wheel_hotspot_increase_stat_line",
			icon_large = "skills_interaction_wheel_hotspots_larger_large",
			desc_id = "skill_wheel_hotspot_increase_desc",
			name_id = "skill_wheel_hotspot_increase_name",
			icon = "skills_interaction_wheel_hotspots_larger",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_hotspot_increase_3"
			}
		},
		wheel_hotspot_increase_4 = {
			stat_desc_id = "skill_wheel_hotspot_increase_stat_line",
			icon_large = "skills_interaction_wheel_hotspots_larger_large",
			desc_id = "skill_wheel_hotspot_increase_desc",
			name_id = "skill_wheel_hotspot_increase_name",
			icon = "skills_interaction_wheel_hotspots_larger",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_hotspot_increase_4"
			}
		},
		wheel_rotation_speed_increase_1 = {
			stat_desc_id = "skill_wheel_rotation_speed_increase_stat_line",
			icon_large = "skills_interaction_wheels_turn_faster_large",
			desc_id = "skill_wheel_rotation_speed_increase_desc",
			name_id = "skill_wheel_rotation_speed_increase_name",
			icon = "skills_interaction_wheels_turn_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_rotation_speed_increase_1"
			}
		},
		wheel_rotation_speed_increase_2 = {
			stat_desc_id = "skill_wheel_rotation_speed_increase_stat_line",
			icon_large = "skills_interaction_wheels_turn_faster_large",
			desc_id = "skill_wheel_rotation_speed_increase_desc",
			name_id = "skill_wheel_rotation_speed_increase_name",
			icon = "skills_interaction_wheels_turn_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_rotation_speed_increase_2"
			}
		},
		wheel_rotation_speed_increase_3 = {
			stat_desc_id = "skill_wheel_rotation_speed_increase_stat_line",
			icon_large = "skills_interaction_wheels_turn_faster_large",
			desc_id = "skill_wheel_rotation_speed_increase_desc",
			name_id = "skill_wheel_rotation_speed_increase_name",
			icon = "skills_interaction_wheels_turn_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_rotation_speed_increase_3"
			}
		},
		wheel_rotation_speed_increase_4 = {
			stat_desc_id = "skill_wheel_rotation_speed_increase_stat_line",
			icon_large = "skills_interaction_wheels_turn_faster_large",
			desc_id = "skill_wheel_rotation_speed_increase_desc",
			name_id = "skill_wheel_rotation_speed_increase_name",
			icon = "skills_interaction_wheels_turn_faster",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_rotation_speed_increase_4"
			}
		},
		wheel_amount_decrease_1 = {
			stat_desc_id = "skill_wheel_amount_decrease_stat_line",
			icon_large = "skills_interaction_one_fewer_wheel_large",
			desc_id = "skill_wheel_amount_decrease_desc",
			name_id = "skill_wheel_amount_decrease_name",
			icon = "skills_interaction_one_fewer_wheel",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_amount_decrease_1"
			}
		},
		wheel_amount_decrease_2 = {
			stat_desc_id = "skill_wheel_amount_decrease_stat_line",
			icon_large = "skills_interaction_one_fewer_wheel_large",
			desc_id = "skill_wheel_amount_decrease_desc",
			name_id = "skill_wheel_amount_decrease_name",
			icon = "skills_interaction_one_fewer_wheel",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"interaction_wheel_amount_decrease_2"
			}
		},
		weapon_tier_unlocked_2 = {
			icon_large = "skills_weapon_tier_2_large",
			desc_id = "skill_weapon_tier_unlocked_2_desc",
			name_id = "skill_weapon_tier_unlocked_2_name",
			icon = "skills_weapon_tier_2",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_weapon_tier_unlocked_2"
			}
		},
		weapon_tier_unlocked_3 = {
			icon_large = "skills_weapon_tier_3_large",
			desc_id = "skill_weapon_tier_unlocked_3_desc",
			name_id = "skill_weapon_tier_unlocked_3_name",
			icon = "skills_weapon_tier_3",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_weapon_tier_unlocked_3"
			}
		},
		weapon_tier_unlocked_4 = {
			icon_large = "skills_weapon_tier_4_large",
			desc_id = "skill_weapon_tier_unlocked_4_desc",
			name_id = "skill_weapon_tier_unlocked_4_name",
			icon = "skills_weapon_tier_4",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_weapon_tier_unlocked_4"
			}
		},
		recon_tier_4_unlocked = {
			icon_large = "skills_weapon_tier_4_large",
			desc_id = "skill_recon_tier_4_unlocked_desc",
			name_id = "skill_recon_tier_4_unlocked_name",
			icon = "skills_weapon_tier_4",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_recon_tier_4_unlocked"
			}
		},
		assault_tier_4_unlocked = {
			icon_large = "skills_weapon_tier_4_large",
			desc_id = "skill_assault_tier_4_unlocked_desc",
			name_id = "skill_assault_tier_4_unlocked_name",
			icon = "skills_weapon_tier_4",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_assault_tier_4_unlocked"
			}
		},
		infiltrator_tier_4_unlocked = {
			icon_large = "skills_weapon_tier_4_large",
			desc_id = "skill_infiltrator_tier_4_unlocked_desc",
			name_id = "skill_infiltrator_tier_4_unlocked_name",
			icon = "skills_weapon_tier_4",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_infiltrator_tier_4_unlocked"
			}
		},
		demolitions_tier_4_unlocked = {
			icon_large = "skills_weapon_tier_4_large",
			desc_id = "skill_demolitions_tier_4_unlocked_desc",
			name_id = "skill_demolitions_tier_4_unlocked_name",
			icon = "skills_weapon_tier_4",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"player_demolitions_tier_4_unlocked"
			}
		},
		weapon_unlock_springfield = {
			name_id = "skill_weapon_unlock_springfield_name",
			desc_id = "skill_weapon_unlock_springfield_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"m1903"
			}
		},
		weapon_unlock_m1911 = {
			name_id = "skill_weapon_unlock_m1911_name",
			desc_id = "skill_weapon_unlock_m1911_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"m1911"
			}
		},
		weapon_unlock_c96 = {
			name_id = "skill_weapon_unlock_c96_name",
			desc_id = "skill_weapon_unlock_c96_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"c96"
			}
		},
		weapon_unlock_webley = {
			name_id = "skill_weapon_unlock_webley_name",
			desc_id = "skill_weapon_unlock_webley_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"webley"
			}
		},
		weapon_unlock_sten = {
			name_id = "skill_weapon_unlock_sten_name",
			desc_id = "skill_weapon_unlock_sten_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"sten"
			}
		},
		weapon_unlock_mp38 = {
			name_id = "skill_weapon_unlock_mp38_name",
			desc_id = "skill_weapon_unlock_mp38_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"mp38"
			}
		},
		weapon_unlock_thompson = {
			name_id = "skill_weapon_unlock_thompson_name",
			desc_id = "skill_weapon_unlock_thompson_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"thompson"
			}
		},
		weapon_unlock_garand = {
			name_id = "skill_weapon_unlock_garand_name",
			desc_id = "skill_weapon_unlock_garand_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"garand"
			}
		},
		weapon_unlock_winchester = {
			name_id = "skill_weapon_unlock_winchester_name",
			desc_id = "skill_weapon_unlock_winchester_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"m1912"
			}
		},
		weapon_unlock_sterling = {
			name_id = "skill_weapon_unlock_sterling_name",
			desc_id = "skill_weapon_unlock_sterling_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"sterling"
			}
		},
		weapon_unlock_bar = {
			name_id = "skill_weapon_unlock_bar_name",
			desc_id = "skill_weapon_unlock_bar_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"m1918"
			}
		},
		weapon_unlock_mp44 = {
			name_id = "skill_weapon_unlock_mp44_name",
			desc_id = "skill_weapon_unlock_mp44_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"mp44"
			}
		},
		weapon_unlock_mosin = {
			name_id = "skill_weapon_unlock_mosin_name",
			desc_id = "skill_weapon_unlock_mosin_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"mosin"
			}
		},
		weapon_unlock_carbine = {
			name_id = "skill_weapon_unlock_carbine_name",
			desc_id = "skill_weapon_unlock_carbine_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"carbine"
			}
		},
		weapon_unlock_mg42 = {
			name_id = "skill_weapon_unlock_mg42_name",
			desc_id = "skill_weapon_unlock_mg42_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"mg42"
			}
		},
		weapon_unlock_geco = {
			name_id = "skill_weapon_unlock_geco_name",
			desc_id = "skill_weapon_unlock_geco_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"geco"
			}
		},
		weapon_unlock_grenade_concrete = {
			name_id = "skill_weapon_unlock_grenade_concrete_name",
			desc_id = "skill_weapon_unlock_grenade_concrete_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"concrete"
			}
		},
		weapon_unlock_grenade_d343 = {
			name_id = "skill_weapon_unlock_grenade_d343_name",
			desc_id = "skill_weapon_unlock_grenade_d343_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"d343"
			}
		},
		weapon_unlock_grenade_mills = {
			name_id = "skill_weapon_unlock_grenade_mills_name",
			desc_id = "skill_weapon_unlock_grenade_mills_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"mills"
			}
		},
		weapon_unlock_decoy_coin = {
			name_id = "skill_weapon_unlock_decoy_coin_name",
			desc_id = "skill_weapon_unlock_decoy_coin_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"decoy_coin"
			}
		},
		weapon_unlock_grenade_betty = {
			name_id = "skill_weapon_unlock_grenade_betty_name",
			desc_id = "skill_weapon_unlock_grenade_betty_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"betty"
			}
		},
		weapon_unlock_dp28 = {
			name_id = "skill_weapon_unlock_dp28_name",
			desc_id = "skill_weapon_unlock_dp28_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"dp28"
			}
		},
		weapon_unlock_bren = {
			name_id = "skill_weapon_unlock_bren_name",
			desc_id = "skill_weapon_unlock_bren_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"bren"
			}
		},
		weapon_unlock_tt33 = {
			name_id = "skill_weapon_unlock_tt33_name",
			desc_id = "skill_weapon_unlock_tt33_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"tt33"
			}
		},
		weapon_unlock_kar_98k = {
			name_id = "skill_weapon_unlock_kar_98k_name",
			desc_id = "skill_weapon_unlock_kar_98k_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"kar_98k"
			}
		},
		weapon_unlock_lee_enfield = {
			name_id = "skill_weapon_unlock_lee_enfield_name",
			desc_id = "skill_weapon_unlock_lee_enfield_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"lee_enfield"
			}
		},
		weapon_unlock_ithaca = {
			name_id = "skill_weapon_unlock_ithaca_name",
			desc_id = "skill_weapon_unlock_ithaca_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"ithaca"
			}
		},
		weapon_unlock_browning = {
			name_id = "skill_weapon_unlock_browning_name",
			desc_id = "skill_weapon_unlock_browning_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"browning"
			}
		},
		weapon_unlock_welrod = {
			name_id = "skill_weapon_unlock_welrod_name",
			desc_id = "skill_weapon_unlock_welrod_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"welrod"
			}
		},
		weapon_unlock_shotty = {
			name_id = "skill_weapon_unlock_shotty_name",
			desc_id = "skill_weapon_unlock_shotty_desc",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"shotty"
			}
		},
		primary_group_damage_multiplier = {
			stat_desc_id = "skill_primary_group_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_assault_rifle_multiplier_large",
			desc_id = "skill_primary_group_damage_multiplier_desc",
			name_id = "skill_primary_group_damage_multiplier_name",
			icon = "skills_dealing_damage_assault_rifle_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					primary_weapon_damage_multiplier = 1
				}
			},
			upgrades = {}
		},
		secondary_group_damage_multiplier = {
			stat_desc_id = "skill_secondary_group_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_pistol_multiplier_large",
			desc_id = "skill_secondary_group_damage_multiplier_desc",
			name_id = "skill_secondary_group_damage_multiplier_name",
			icon = "skills_dealing_damage_pistol_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {
				{
					secondary_weapon_damage_multiplier = 1
				}
			},
			upgrades = {}
		},
		pistol_damage_multiplier_1 = {
			stat_desc_id = "skill_pistol_damage_multiplier_stat_line",
			icon_large = "skills_dealing_damage_pistol_multiplier_large",
			desc_id = "skill_pistol_damage_multiplier_desc",
			name_id = "skill_pistol_damage_multiplier_name",
			icon = "skills_dealing_damage_pistol_multiplier",
			icon_xy = {
				1,
				1
			},
			acquires = {},
			upgrades = {
				"pistol_damage_multiplier_1"
			}
		}
	}
	self.skills.pistol_damage_multiplier_2 = deep_clone(self.skills.pistol_damage_multiplier_1)
	self.skills.pistol_damage_multiplier_2.upgrades = {
		"pistol_damage_multiplier_2"
	}
	self.skills.pistol_damage_multiplier_3 = deep_clone(self.skills.pistol_damage_multiplier_1)
	self.skills.pistol_damage_multiplier_3.upgrades = {
		"pistol_damage_multiplier_3"
	}
	self.skills.pistol_damage_multiplier_4 = deep_clone(self.skills.pistol_damage_multiplier_1)
	self.skills.pistol_damage_multiplier_4.upgrades = {
		"pistol_damage_multiplier_4"
	}
	self.skills.shotgun_damage_multiplier_1 = {
		stat_desc_id = "skill_shotgun_damage_multiplier_stat_line",
		icon_large = "skills_dealing_damage_shotgun_multiplier_large",
		desc_id = "skill_shotgun_damage_multiplier_desc",
		name_id = "skill_shotgun_damage_multiplier_name",
		icon = "skills_dealing_damage_shotgun_multiplier",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"shotgun_damage_multiplier_1"
		}
	}
	self.skills.shotgun_damage_multiplier_2 = deep_clone(self.skills.shotgun_damage_multiplier_1)
	self.skills.shotgun_damage_multiplier_2.upgrades = {
		"shotgun_damage_multiplier_2"
	}
	self.skills.shotgun_damage_multiplier_3 = deep_clone(self.skills.shotgun_damage_multiplier_1)
	self.skills.shotgun_damage_multiplier_3.upgrades = {
		"shotgun_damage_multiplier_3"
	}
	self.skills.smg_damage_multiplier_1 = {
		stat_desc_id = "skill_smg_damage_multiplier_stat_line",
		icon_large = "skills_dealing_damage_smg_multiplier_large",
		desc_id = "skill_smg_damage_multiplier_desc",
		name_id = "skill_smg_damage_multiplier_name",
		icon = "skills_dealing_damage_smg_multiplier",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"smg_damage_multiplier_1"
		}
	}
	self.skills.smg_damage_multiplier_2 = deep_clone(self.skills.smg_damage_multiplier_1)
	self.skills.smg_damage_multiplier_2.upgrades = {
		"smg_damage_multiplier_2"
	}
	self.skills.smg_damage_multiplier_3 = deep_clone(self.skills.smg_damage_multiplier_1)
	self.skills.smg_damage_multiplier_3.upgrades = {
		"smg_damage_multiplier_3"
	}
	self.skills.assault_rifle_damage_multiplier_1 = {
		stat_desc_id = "skill_assault_rifle_damage_multiplier_stat_line",
		icon_large = "skills_dealing_damage_assault_rifle_multiplier_large",
		desc_id = "skill_assault_rifle_damage_multiplier_desc",
		name_id = "skill_assault_rifle_damage_multiplier_name",
		icon = "skills_dealing_damage_assault_rifle_multiplier",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"assault_rifle_damage_multiplier_1"
		}
	}
	self.skills.assault_rifle_damage_multiplier_2 = deep_clone(self.skills.assault_rifle_damage_multiplier_1)
	self.skills.assault_rifle_damage_multiplier_2.upgrades = {
		"assault_rifle_damage_multiplier_2"
	}
	self.skills.assault_rifle_damage_multiplier_3 = deep_clone(self.skills.assault_rifle_damage_multiplier_1)
	self.skills.assault_rifle_damage_multiplier_3.upgrades = {
		"assault_rifle_damage_multiplier_3"
	}
	self.skills.lmg_damage_multiplier_1 = {
		stat_desc_id = "skill_lmg_damage_multiplier_stat_line",
		icon_large = "skills_dealing_damage_heavy_multiplier_large",
		desc_id = "skill_lmg_damage_multiplier_desc",
		name_id = "skill_lmg_damage_multiplier_name",
		icon = "skills_dealing_damage_heavy_multiplier",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"lmg_damage_multiplier_1"
		}
	}
	self.skills.lmg_damage_multiplier_2 = deep_clone(self.skills.lmg_damage_multiplier_1)
	self.skills.lmg_damage_multiplier_2.upgrades = {
		"lmg_damage_multiplier_2"
	}
	self.skills.lmg_damage_multiplier_3 = deep_clone(self.skills.lmg_damage_multiplier_1)
	self.skills.lmg_damage_multiplier_3.upgrades = {
		"lmg_damage_multiplier_3"
	}
	self.skills.sniper_damage_multiplier_1 = {
		stat_desc_id = "skill_sniper_damage_multiplier_stat_line",
		icon_large = "skills_dealing_damage_snp_multiplier_large",
		desc_id = "skill_sniper_damage_multiplier_desc",
		name_id = "skill_sniper_damage_multiplier_name",
		icon = "skills_dealing_damage_snp_multiplier",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"snp_damage_multiplier_1"
		}
	}
	self.skills.sniper_damage_multiplier_2 = deep_clone(self.skills.sniper_damage_multiplier_1)
	self.skills.sniper_damage_multiplier_2.upgrades = {
		"snp_damage_multiplier_2"
	}
	self.skills.sniper_damage_multiplier_3 = deep_clone(self.skills.sniper_damage_multiplier_1)
	self.skills.sniper_damage_multiplier_3.upgrades = {
		"snp_damage_multiplier_3"
	}
	self.skills.grenade_quantity_1 = {
		stat_desc_id = "skill_grenade_quantity_stat_line",
		icon_large = "skills_weapons_carry_extra_granade_large",
		desc_id = "skill_grenade_quantity_desc",
		name_id = "skill_grenade_quantity_name",
		icon = "skills_weapons_carry_extra_granade",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_grenade_quantity_1"
		}
	}
	self.skills.grenade_quantity_2 = {
		stat_desc_id = "skill_grenade_quantity_stat_line",
		icon_large = "skills_weapons_carry_extra_granade_large",
		desc_id = "skill_grenade_quantity_desc",
		name_id = "skill_grenade_quantity_name",
		icon = "skills_weapons_carry_extra_granade",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_grenade_quantity_2"
		}
	}
	self.skills.turret_reduced_overheat_1 = {
		stat_desc_id = "skill_turret_reduced_overheat_stat_line",
		icon_large = "skills_special_skills_mounted_guns_overheat_large",
		desc_id = "skill_turret_reduced_overheat_desc",
		name_id = "skill_turret_reduced_overheat_name",
		icon = "skills_special_skills_mounted_guns_overheat",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_turret_m2_overheat_reduction_1",
			"player_turret_flakvierling_overheat_reduction_1"
		}
	}
	self.skills.turret_reduced_overheat_2 = {
		stat_desc_id = "skill_turret_reduced_overheat_stat_line",
		icon_large = "skills_special_skills_mounted_guns_overheat_large",
		desc_id = "skill_turret_reduced_overheat_desc",
		name_id = "skill_turret_reduced_overheat_name",
		icon = "skills_special_skills_mounted_guns_overheat",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_turret_m2_overheat_reduction_2",
			"player_turret_flakvierling_overheat_reduction_2"
		}
	}
	self.skills.turret_reduced_overheat_3 = {
		stat_desc_id = "skill_turret_reduced_overheat_stat_line",
		icon_large = "skills_special_skills_mounted_guns_overheat_large",
		desc_id = "skill_turret_reduced_overheat_desc",
		name_id = "skill_turret_reduced_overheat_name",
		icon = "skills_special_skills_mounted_guns_overheat",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_turret_m2_overheat_reduction_3",
			"player_turret_flakvierling_overheat_reduction_3"
		}
	}
	self.skills.turret_reduced_overheat_4 = {
		stat_desc_id = "skill_turret_reduced_overheat_stat_line",
		icon_large = "skills_special_skills_mounted_guns_overheat_large",
		desc_id = "skill_turret_reduced_overheat_desc",
		name_id = "skill_turret_reduced_overheat_name",
		icon = "skills_special_skills_mounted_guns_overheat",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_turret_m2_overheat_reduction_4",
			"player_turret_flakvierling_overheat_reduction_4"
		}
	}
	self.skills.revived_damage_reduction_1 = {
		stat_desc_id = "skill_revived_damage_reduction_stat_line",
		icon_large = "skills_soaking_damage_less_after_revive_large",
		desc_id = "skill_revived_damage_reduction_desc",
		name_id = "skill_revived_damage_reduction_name",
		icon = "skills_soaking_damage_less_after_revive",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"temporary_on_revived_damage_reduction_1"
		}
	}
	self.skills.revived_damage_reduction_2 = {
		stat_desc_id = "skill_revived_damage_reduction_stat_line",
		icon_large = "skills_soaking_damage_less_after_revive_large",
		desc_id = "skill_revived_damage_reduction_desc",
		name_id = "skill_revived_damage_reduction_name",
		icon = "skills_soaking_damage_less_after_revive",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"temporary_on_revived_damage_reduction_2"
		}
	}
	self.skills.revived_damage_reduction_3 = {
		stat_desc_id = "skill_revived_damage_reduction_stat_line",
		icon_large = "skills_soaking_damage_less_after_revive_large",
		desc_id = "skill_revived_damage_reduction_desc",
		name_id = "skill_revived_damage_reduction_name",
		icon = "skills_soaking_damage_less_after_revive",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"temporary_on_revived_damage_reduction_3"
		}
	}
	self.skills.revived_damage_reduction_4 = {
		stat_desc_id = "skill_revived_damage_reduction_stat_line",
		icon_large = "skills_soaking_damage_less_after_revive_large",
		desc_id = "skill_revived_damage_reduction_desc",
		name_id = "skill_revived_damage_reduction_name",
		icon = "skills_soaking_damage_less_after_revive",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"temporary_on_revived_damage_reduction_4"
		}
	}
	self.skills.bleedout_timer_increase_1 = {
		stat_desc_id = "skill_bleedout_timer_increase_stat_line",
		icon_large = "skills_soaking_damage_increase_bleedout_time_large",
		desc_id = "skill_bleedout_timer_increase_desc",
		name_id = "skill_bleedout_timer_increase_name",
		icon = "skills_soaking_damage_increase_bleedout_time",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_bleedout_timer_increase_1"
		}
	}
	self.skills.bleedout_timer_increase_2 = {
		stat_desc_id = "skill_bleedout_timer_increase_stat_line",
		icon_large = "skills_soaking_damage_increase_bleedout_time_large",
		desc_id = "skill_bleedout_timer_increase_desc",
		name_id = "skill_bleedout_timer_increase_name",
		icon = "skills_soaking_damage_increase_bleedout_time",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_bleedout_timer_increase_2"
		}
	}
	self.skills.bleedout_timer_increase_3 = {
		stat_desc_id = "skill_bleedout_timer_increase_stat_line",
		icon_large = "skills_soaking_damage_increase_bleedout_time_large",
		desc_id = "skill_bleedout_timer_increase_desc",
		name_id = "skill_bleedout_timer_increase_name",
		icon = "skills_soaking_damage_increase_bleedout_time",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_bleedout_timer_increase_3"
		}
	}
	self.skills.bleedout_timer_increase_4 = {
		stat_desc_id = "skill_bleedout_timer_increase_stat_line",
		icon_large = "skills_soaking_damage_increase_bleedout_time_large",
		desc_id = "skill_bleedout_timer_increase_desc",
		name_id = "skill_bleedout_timer_increase_name",
		icon = "skills_soaking_damage_increase_bleedout_time",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_bleedout_timer_increase_4"
		}
	}
	self.skills.revive_interaction_speed_multiplier_1 = {
		stat_desc_id = "skill_revive_interaction_speed_multiplier_stat_line",
		icon_large = "skills_interaction_revive_teammates_faster_large",
		desc_id = "skill_revive_interaction_speed_multiplier_desc",
		name_id = "skill_revive_interaction_speed_multiplier_name",
		icon = "skills_interaction_revive_teammates_faster",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_revive_interaction_speed_multiplier_1"
		}
	}
	self.skills.revive_interaction_speed_multiplier_2 = {
		stat_desc_id = "skill_revive_interaction_speed_multiplier_stat_line",
		icon_large = "skills_interaction_revive_teammates_faster_large",
		desc_id = "skill_revive_interaction_speed_multiplier_desc",
		name_id = "skill_revive_interaction_speed_multiplier_name",
		icon = "skills_interaction_revive_teammates_faster",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_revive_interaction_speed_multiplier_2"
		}
	}
	self.skills.revive_interaction_speed_multiplier_3 = {
		stat_desc_id = "skill_revive_interaction_speed_multiplier_stat_line",
		icon_large = "skills_interaction_revive_teammates_faster_large",
		desc_id = "skill_revive_interaction_speed_multiplier_desc",
		name_id = "skill_revive_interaction_speed_multiplier_name",
		icon = "skills_interaction_revive_teammates_faster",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_revive_interaction_speed_multiplier_3"
		}
	}
	self.skills.revive_interaction_speed_multiplier_4 = {
		stat_desc_id = "skill_revive_interaction_speed_multiplier_stat_line",
		icon_large = "skills_interaction_revive_teammates_faster_large",
		desc_id = "skill_revive_interaction_speed_multiplier_desc",
		name_id = "skill_revive_interaction_speed_multiplier_name",
		icon = "skills_interaction_revive_teammates_faster",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_revive_interaction_speed_multiplier_4"
		}
	}
	self.skills.general_interaction_speed_multiplier_1 = {
		stat_desc_id = "skill_general_interaction_speed_multiplier_stat_line",
		icon_large = "skills_general_faster_interaction_large",
		desc_id = "skill_general_interaction_speed_multiplier_desc",
		name_id = "skill_general_interaction_speed_multiplier_name",
		icon = "skills_general_faster_interaction",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"interaction_general_interaction_timer_multiplier_1"
		}
	}
	self.skills.general_interaction_speed_multiplier_2 = {
		stat_desc_id = "skill_general_interaction_speed_multiplier_stat_line",
		icon_large = "skills_general_faster_interaction_large",
		desc_id = "skill_general_interaction_speed_multiplier_desc",
		name_id = "skill_general_interaction_speed_multiplier_name",
		icon = "skills_general_faster_interaction",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"interaction_general_interaction_timer_multiplier_2"
		}
	}
	self.skills.general_interaction_speed_multiplier_3 = {
		stat_desc_id = "skill_general_interaction_speed_multiplier_stat_line",
		icon_large = "skills_general_faster_interaction_large",
		desc_id = "skill_general_interaction_speed_multiplier_desc",
		name_id = "skill_general_interaction_speed_multiplier_name",
		icon = "skills_general_faster_interaction",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"interaction_general_interaction_timer_multiplier_3"
		}
	}
	self.skills.general_interaction_speed_multiplier_4 = {
		stat_desc_id = "skill_general_interaction_speed_multiplier_stat_line",
		icon_large = "skills_general_faster_interaction_large",
		desc_id = "skill_general_interaction_speed_multiplier_desc",
		name_id = "skill_general_interaction_speed_multiplier_name",
		icon = "skills_general_faster_interaction",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"interaction_general_interaction_timer_multiplier_4"
		}
	}
	self.skills.long_dis_revive_1 = {
		icon_large = "skills_special_skills_revive_range_teammates_large",
		desc_id = "skill_long_dis_revive_1_desc",
		name_id = "skill_long_dis_revive_1_name",
		icon = "skills_special_skills_revive_range_teammates",
		icon_xy = {
			1,
			1
		},
		acquires = {},
		upgrades = {
			"player_long_dis_revive_1"
		}
	}
end

function SkillTreeTweakData:_init_recon_skill_tree()
	self.skill_trees.recon = {
		{
			{
				skill_name = "warcry_sharpshooter"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_1"
			},
			{
				skill_name = "turret_reduced_overheat_1"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_1"
			},
			{
				skill_name = "stamina_regeneration_increase_1"
			},
			{
				skill_name = "carry_penalty_decrease_1"
			}
		},
		{
			{
				skill_name = "increase_general_speed_1"
			},
			{
				skill_name = "increase_run_speed_1"
			},
			{
				skill_name = "increase_crouch_speed_1"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_buff_1"
			},
			{
				skill_name = "warcry_long_range_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_1"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_1"
			},
			{
				skill_name = "headshot_damage_multiplier_1"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_1"
			}
		},
		{
			{
				skill_name = "running_damage_reduction_1"
			},
			{
				skill_name = "crouching_damage_reduction_1"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_1"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_1"
			},
			{
				skill_name = "pick_up_ammo_multiplier_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_1"
			},
			{
				skill_name = "wheel_rotation_speed_increase_1"
			},
			{
				skill_name = "general_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "warcry_sharpshooter_level_increase"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_1"
			},
			{
				skill_name = "pick_up_health_multiplier_1"
			},
			{
				skill_name = "bleedout_timer_increase_1"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_1"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_2"
			},
			{
				skill_name = "on_hit_flinch_reduction_1"
			}
		},
		{
			{
				skill_name = "increase_general_speed_2"
			},
			{
				skill_name = "increase_run_speed_2"
			},
			{
				skill_name = "increase_crouch_speed_2"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_2"
			},
			{
				skill_name = "headshot_damage_multiplier_2"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_2"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_buff_2"
			},
			{
				skill_name = "warcry_headshot_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_2"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_2"
			},
			{
				skill_name = "crouching_damage_reduction_2"
			},
			{
				skill_name = "revived_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "sniper_damage_multiplier_1"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_1"
			},
			{
				skill_name = "pistol_damage_multiplier_1"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_2"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_2"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "interacting_damage_reduction_1"
			},
			{
				skill_name = "bullet_damage_reduction_1"
			},
			{
				skill_name = "melee_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "warcry_sharpshooter_level_increase"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_2"
			},
			{
				skill_name = "pick_up_ammo_multiplier_2"
			},
			{
				skill_name = "general_interaction_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "stamina_regeneration_increase_2"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_3"
			},
			{
				skill_name = "carry_penalty_decrease_2"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_2"
			},
			{
				skill_name = "melee_damage_multiplier_1"
			},
			{
				skill_name = "running_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_2"
			},
			{
				skill_name = "crouching_damage_reduction_3"
			},
			{
				skill_name = "increase_crouch_speed_3"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_buff_3"
			},
			{
				skill_name = "warcry_long_range_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_3"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_3"
			},
			{
				skill_name = "headshot_damage_multiplier_3"
			},
			{
				skill_name = "on_hit_flinch_reduction_2"
			}
		},
		{
			{
				skill_name = "increase_general_speed_3"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_3"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_3"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_3"
			},
			{
				skill_name = "sniper_damage_multiplier_2"
			},
			{
				skill_name = "increase_run_speed_3"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_3"
			},
			{
				skill_name = "player_critical_hit_chance_3"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_3"
			}
		},
		{
			{
				skill_name = "warcry_sharpshooter_level_increase"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_2"
			},
			{
				skill_name = "smg_damage_multiplier_1"
			},
			{
				skill_name = "pick_up_health_multiplier_2"
			}
		},
		{
			{
				skill_name = "interacting_damage_reduction_2"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_4"
			},
			{
				skill_name = "bleedout_timer_increase_2"
			}
		},
		{
			{
				skill_name = "wheel_rotation_speed_increase_2"
			},
			{
				skill_name = "revived_damage_reduction_2"
			},
			{
				skill_name = "increase_crouch_speed_4"
			}
		},
		{
			{
				skill_name = "headshot_damage_multiplier_4"
			},
			{
				skill_name = "crouching_damage_reduction_4"
			},
			{
				skill_name = "pick_up_ammo_multiplier_3"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_buff_4"
			},
			{
				skill_name = "warcry_headshot_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_4"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_2"
			},
			{
				skill_name = "on_hit_flinch_reduction_3"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_4"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_4"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_2"
			},
			{
				skill_name = "running_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_4"
			},
			{
				skill_name = "primary_ammo_capacity_increase_4"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_4"
			}
		},
		{
			{
				skill_name = "turret_reduced_overheat_2"
			},
			{
				skill_name = "sniper_damage_multiplier_3"
			},
			{
				skill_name = "bullet_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "warcry_sharpshooter_level_increase"
			}
		}
	}
end

function SkillTreeTweakData:_init_assault_skill_tree()
	self.skill_trees.assault = {
		{
			{
				skill_name = "warcry_berserk"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_1"
			},
			{
				skill_name = "turret_reduced_overheat_1"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_1"
			},
			{
				skill_name = "interacting_damage_reduction_1"
			},
			{
				skill_name = "revived_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_1"
			},
			{
				skill_name = "pick_up_health_multiplier_1"
			},
			{
				skill_name = "bleedout_timer_increase_1"
			}
		},
		{
			{
				skill_name = "warcry_team_heal_buff_1"
			},
			{
				skill_name = "warcry_low_health_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_1"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_1"
			},
			{
				skill_name = "stamina_regeneration_increase_1"
			},
			{
				skill_name = "carry_penalty_decrease_1"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_1"
			},
			{
				skill_name = "crouching_damage_reduction_1"
			},
			{
				skill_name = "running_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_1"
			},
			{
				skill_name = "headshot_damage_multiplier_1"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_1"
			},
			{
				skill_name = "wheel_rotation_speed_increase_1"
			},
			{
				skill_name = "general_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "warcry_berserk_level_increase"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_1"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_1"
			},
			{
				skill_name = "pick_up_ammo_multiplier_1"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_2"
			},
			{
				skill_name = "pick_up_health_multiplier_2"
			},
			{
				skill_name = "bleedout_timer_increase_2"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_1"
			},
			{
				skill_name = "turret_reduced_overheat_2"
			},
			{
				skill_name = "on_hit_flinch_reduction_1"
			}
		},
		{
			{
				skill_name = "increase_general_speed_1"
			},
			{
				skill_name = "increase_run_speed_1"
			},
			{
				skill_name = "increase_crouch_speed_1"
			}
		},
		{
			{
				skill_name = "warcry_team_heal_buff_2"
			},
			{
				skill_name = "warcry_dismemberment_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_2"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_2"
			},
			{
				skill_name = "crouching_damage_reduction_2"
			},
			{
				skill_name = "revived_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "assault_rifle_damage_multiplier_1"
			},
			{
				skill_name = "smg_damage_multiplier_1"
			},
			{
				skill_name = "lmg_damage_multiplier_1"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_2"
			},
			{
				skill_name = "melee_damage_multiplier_1"
			},
			{
				skill_name = "on_hit_flinch_reduction_2"
			}
		},
		{
			{
				skill_name = "revive_interaction_speed_multiplier_1"
			},
			{
				skill_name = "stamina_regeneration_increase_2"
			},
			{
				skill_name = "carry_penalty_decrease_2"
			}
		},
		{
			{
				skill_name = "warcry_berserk_level_increase"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_2"
			},
			{
				skill_name = "headshot_damage_multiplier_2"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_2"
			}
		},
		{
			{
				skill_name = "turret_reduced_overheat_3"
			},
			{
				skill_name = "pick_up_health_multiplier_3"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_2"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_3"
			},
			{
				skill_name = "increase_crouch_speed_2"
			},
			{
				skill_name = "crouching_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_2"
			},
			{
				skill_name = "revived_damage_reduction_3"
			},
			{
				skill_name = "bleedout_timer_increase_3"
			}
		},
		{
			{
				skill_name = "warcry_team_heal_buff_3"
			},
			{
				skill_name = "warcry_low_health_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_3"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_2"
			},
			{
				skill_name = "increase_run_speed_2"
			},
			{
				skill_name = "running_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_3"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_2"
			},
			{
				skill_name = "primary_ammo_capacity_increase_2"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_3"
			},
			{
				skill_name = "reload_speed_multiplier_2"
			},
			{
				skill_name = "turret_reduced_overheat_4"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_2"
			},
			{
				skill_name = "stamina_regeneration_increase_3"
			},
			{
				skill_name = "on_hit_flinch_reduction_3"
			}
		},
		{
			{
				skill_name = "warcry_berserk_level_increase"
			}
		},
		{
			{
				skill_name = "pick_up_ammo_multiplier_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_2"
			},
			{
				skill_name = "melee_damage_multiplier_2"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_4"
			},
			{
				skill_name = "smg_damage_multiplier_2"
			},
			{
				skill_name = "grenade_quantity_1"
			}
		},
		{
			{
				skill_name = "general_interaction_speed_multiplier_2"
			},
			{
				skill_name = "pick_up_health_multiplier_4"
			},
			{
				skill_name = "carry_penalty_decrease_3"
			}
		},
		{
			{
				skill_name = "revive_interaction_speed_multiplier_2"
			},
			{
				skill_name = "revived_damage_reduction_4"
			},
			{
				skill_name = "bleedout_timer_increase_4"
			}
		},
		{
			{
				skill_name = "warcry_team_heal_buff_4"
			},
			{
				skill_name = "warcry_dismemberment_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_4"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_4"
			},
			{
				skill_name = "lmg_damage_multiplier_2"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_3"
			},
			{
				skill_name = "headshot_damage_multiplier_3"
			},
			{
				skill_name = "on_hit_flinch_reduction_4"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_4"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_3"
			},
			{
				skill_name = "interacting_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "highlight_enemy_damage_bonus_3"
			},
			{
				skill_name = "increase_general_speed_2"
			},
			{
				skill_name = "reload_speed_multiplier_3"
			}
		},
		{
			{
				skill_name = "warcry_berserk_level_increase"
			}
		}
	}
end

function SkillTreeTweakData:_init_infiltrator_skill_tree()
	self.skill_trees.infiltrator = {
		{
			{
				skill_name = "warcry_ghost"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_1"
			},
			{
				skill_name = "turret_reduced_overheat_1"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_1"
			},
			{
				skill_name = "running_damage_reduction_1"
			},
			{
				skill_name = "interacting_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "increase_general_speed_1"
			},
			{
				skill_name = "increase_run_speed_1"
			},
			{
				skill_name = "increase_crouch_speed_1"
			}
		},
		{
			{
				skill_name = "warcry_team_movement_speed_buff_1"
			},
			{
				skill_name = "warcry_short_range_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_1"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_1"
			},
			{
				skill_name = "stamina_regeneration_increase_1"
			},
			{
				skill_name = "carry_penalty_decrease_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_1"
			},
			{
				skill_name = "wheel_rotation_speed_increase_1"
			},
			{
				skill_name = "general_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_1"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_1"
			},
			{
				skill_name = "pick_up_ammo_multiplier_1"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_1"
			},
			{
				skill_name = "pick_up_health_multiplier_1"
			},
			{
				skill_name = "bleedout_timer_increase_1"
			}
		},
		{
			{
				skill_name = "warcry_ghost_level_increase"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_1"
			},
			{
				skill_name = "headshot_damage_multiplier_1"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_1"
			}
		},
		{
			{
				skill_name = "increase_general_speed_2"
			},
			{
				skill_name = "increase_run_speed_2"
			},
			{
				skill_name = "increase_crouch_speed_2"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_2"
			},
			{
				skill_name = "running_damage_reduction_2"
			},
			{
				skill_name = "revived_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_1"
			},
			{
				skill_name = "swap_speed_multiplier_2"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "warcry_team_movement_speed_buff_2"
			},
			{
				skill_name = "warcry_melee_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_2"
			}
		},
		{
			{
				skill_name = "stamina_regeneration_increase_2"
			},
			{
				skill_name = "on_hit_flinch_reduction_1"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "smg_damage_multiplier_1"
			},
			{
				skill_name = "melee_damage_multiplier_1"
			},
			{
				skill_name = "pistol_damage_multiplier_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_2"
			},
			{
				skill_name = "general_interaction_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "interacting_damage_reduction_2"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_2"
			},
			{
				skill_name = "pick_up_health_multiplier_2"
			}
		},
		{
			{
				skill_name = "warcry_ghost_level_increase"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_1"
			},
			{
				skill_name = "shotgun_damage_multiplier_1"
			},
			{
				skill_name = "carry_penalty_decrease_2"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_3"
			},
			{
				skill_name = "turret_reduced_overheat_2"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_2"
			}
		},
		{
			{
				skill_name = "increase_general_speed_3"
			},
			{
				skill_name = "pistol_damage_multiplier_2"
			},
			{
				skill_name = "revived_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "stamina_regeneration_increase_3"
			},
			{
				skill_name = "increase_run_speed_3"
			},
			{
				skill_name = "running_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "warcry_team_movement_speed_buff_3"
			},
			{
				skill_name = "warcry_short_range_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_3"
			}
		},
		{
			{
				skill_name = "crouching_damage_reduction_1"
			},
			{
				skill_name = "melee_damage_multiplier_2"
			},
			{
				skill_name = "increase_crouch_speed_3"
			}
		},
		{
			{
				skill_name = "smg_damage_multiplier_2"
			},
			{
				skill_name = "max_health_multiplier_2"
			},
			{
				skill_name = "pick_up_ammo_multiplier_2"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_2"
			},
			{
				skill_name = "swap_speed_multiplier_3"
			},
			{
				skill_name = "general_interaction_speed_multiplier_3"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_3"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_3"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_3"
			}
		},
		{
			{
				skill_name = "warcry_ghost_level_increase"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_3"
			},
			{
				skill_name = "pick_up_health_multiplier_3"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_2"
			},
			{
				skill_name = "shotgun_damage_multiplier_2"
			},
			{
				skill_name = "wheel_amount_decrease_1"
			}
		},
		{
			{
				skill_name = "stamina_regeneration_increase_4"
			},
			{
				skill_name = "increase_run_speed_4"
			},
			{
				skill_name = "running_damage_reduction_4"
			}
		},
		{
			{
				skill_name = "increase_general_speed_4"
			},
			{
				skill_name = "headshot_damage_multiplier_2"
			},
			{
				skill_name = "revived_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "warcry_team_movement_speed_buff_4"
			},
			{
				skill_name = "warcry_melee_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_4"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_4"
			},
			{
				skill_name = "melee_damage_multiplier_3"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "bleedout_timer_increase_2"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_4"
			},
			{
				skill_name = "interacting_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "crouching_damage_reduction_2"
			},
			{
				skill_name = "on_hit_flinch_reduction_2"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_1"
			}
		},
		{
			{
				skill_name = "smg_damage_multiplier_3"
			},
			{
				skill_name = "primary_ammo_capacity_increase_2"
			},
			{
				skill_name = "bullet_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "warcry_ghost_level_increase"
			}
		}
	}
end

function SkillTreeTweakData:_init_demolitions_skill_tree()
	self.skill_trees.demolitions = {
		{
			{
				skill_name = "warcry_clustertruck"
			}
		},
		{
			{
				skill_name = "swap_speed_multiplier_1"
			},
			{
				skill_name = "turret_reduced_overheat_1"
			},
			{
				skill_name = "ready_weapon_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_1"
			},
			{
				skill_name = "wheel_rotation_speed_increase_1"
			},
			{
				skill_name = "general_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_1"
			},
			{
				skill_name = "stamina_regeneration_increase_1"
			},
			{
				skill_name = "carry_penalty_decrease_1"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_reduction_buff_1"
			},
			{
				skill_name = "warcry_explosion_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_1"
			}
		},
		{
			{
				skill_name = "max_health_multiplier_1"
			},
			{
				skill_name = "pick_up_health_multiplier_1"
			},
			{
				skill_name = "bleedout_timer_increase_1"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_1"
			},
			{
				skill_name = "interacting_damage_reduction_1"
			},
			{
				skill_name = "revived_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_1"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_1"
			},
			{
				skill_name = "pick_up_ammo_multiplier_1"
			}
		},
		{
			{
				skill_name = "player_critical_hit_chance_1"
			},
			{
				skill_name = "headshot_damage_multiplier_1"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_1"
			}
		},
		{
			{
				skill_name = "warcry_clustertruck_level_increase"
			}
		},
		{
			{
				skill_name = "bullet_damage_reduction_1"
			},
			{
				skill_name = "crouching_damage_reduction_1"
			},
			{
				skill_name = "running_damage_reduction_1"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_2"
			},
			{
				skill_name = "general_interaction_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "increase_general_speed_1"
			},
			{
				skill_name = "increase_run_speed_1"
			},
			{
				skill_name = "increase_crouch_speed_1"
			}
		},
		{
			{
				skill_name = "reload_speed_multiplier_1"
			},
			{
				skill_name = "swap_speed_multiplier_2"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_1"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_reduction_buff_2"
			},
			{
				skill_name = "warcry_killstreak_multiplier_bonus_1"
			},
			{
				skill_name = "warcry_duration_2"
			}
		},
		{
			{
				skill_name = "wheel_amount_decrease_1"
			},
			{
				skill_name = "on_hit_flinch_reduction_1"
			},
			{
				skill_name = "turret_reduced_overheat_2"
			}
		},
		{
			{
				skill_name = "shotgun_damage_multiplier_1"
			},
			{
				skill_name = "lmg_damage_multiplier_1"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_1"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_2"
			},
			{
				skill_name = "max_health_multiplier_2"
			},
			{
				skill_name = "bleedout_timer_increase_2"
			}
		},
		{
			{
				skill_name = "pick_up_ammo_multiplier_2"
			},
			{
				skill_name = "interacting_damage_reduction_2"
			},
			{
				skill_name = "carry_penalty_decrease_2"
			}
		},
		{
			{
				skill_name = "warcry_clustertruck_level_increase"
			}
		},
		{
			{
				skill_name = "grenade_quantity_1"
			},
			{
				skill_name = "headshot_damage_multiplier_2"
			},
			{
				skill_name = "secondary_ammo_capacity_increase_2"
			}
		},
		{
			{
				skill_name = "ready_weapon_speed_multiplier_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_3"
			},
			{
				skill_name = "turret_reduced_overheat_3"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_3"
			},
			{
				skill_name = "bullet_damage_reduction_2"
			},
			{
				skill_name = "highlight_enemy_damage_bonus_2"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_2"
			},
			{
				skill_name = "revive_interaction_speed_multiplier_2"
			},
			{
				skill_name = "general_interaction_speed_multiplier_3"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_reduction_buff_3"
			},
			{
				skill_name = "warcry_explosion_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_3"
			}
		},
		{
			{
				skill_name = "melee_damage_reduction_2"
			},
			{
				skill_name = "swap_speed_multiplier_3"
			},
			{
				skill_name = "carry_penalty_decrease_3"
			}
		},
		{
			{
				skill_name = "shotgun_damage_multiplier_2"
			},
			{
				skill_name = "pick_up_health_multiplier_2"
			},
			{
				skill_name = "interacting_damage_reduction_3"
			}
		},
		{
			{
				skill_name = "pick_up_ammo_multiplier_3"
			},
			{
				skill_name = "lmg_damage_multiplier_2"
			},
			{
				skill_name = "increase_general_speed_2"
			}
		},
		{
			{
				skill_name = "stamina_regeneration_increase_2"
			},
			{
				skill_name = "increase_run_speed_2"
			},
			{
				skill_name = "running_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "warcry_clustertruck_level_increase"
			}
		},
		{
			{
				skill_name = "stamina_multiplier_3"
			},
			{
				skill_name = "increase_crouch_speed_2"
			},
			{
				skill_name = "crouching_damage_reduction_2"
			}
		},
		{
			{
				skill_name = "revived_damage_reduction_2"
			},
			{
				skill_name = "wheel_rotation_speed_increase_4"
			},
			{
				skill_name = "bleedout_timer_increase_3"
			}
		},
		{
			{
				skill_name = "wheel_hotspot_increase_4"
			},
			{
				skill_name = "max_health_multiplier_3"
			},
			{
				skill_name = "assault_rifle_damage_multiplier_2"
			}
		},
		{
			{
				skill_name = "revive_interaction_speed_multiplier_3"
			},
			{
				skill_name = "swap_speed_multiplier_4"
			},
			{
				skill_name = "general_interaction_speed_multiplier_4"
			}
		},
		{
			{
				skill_name = "warcry_team_damage_reduction_buff_4"
			},
			{
				skill_name = "warcry_killstreak_multiplier_bonus_2"
			},
			{
				skill_name = "warcry_duration_4"
			}
		},
		{
			{
				skill_name = "grenade_quantity_2"
			},
			{
				skill_name = "bullet_damage_reduction_3"
			},
			{
				skill_name = "reload_speed_multiplier_2"
			}
		},
		{
			{
				skill_name = "on_hit_flinch_reduction_2"
			},
			{
				skill_name = "interacting_damage_reduction_4"
			},
			{
				skill_name = "carry_penalty_decrease_4"
			}
		},
		{
			{
				skill_name = "shotgun_damage_multiplier_3"
			},
			{
				skill_name = "pick_up_ammo_multiplier_4"
			},
			{
				skill_name = "player_critical_hit_chance_2"
			}
		},
		{
			{
				skill_name = "primary_ammo_capacity_increase_3"
			},
			{
				skill_name = "lmg_damage_multiplier_3"
			},
			{
				skill_name = "wheel_amount_decrease_2"
			}
		},
		{
			{
				skill_name = "warcry_clustertruck_level_increase"
			}
		}
	}
end

function SkillTreeTweakData:get_weapon_unlock_levels()
	local ret = {}

	for class_name, class_unlock_data in pairs(self.automatic_unlock_progressions) do
		for level, unlock_data in pairs(class_unlock_data) do
			if unlock_data.weapons then
				for _, weapon_unlock in pairs(unlock_data.weapons) do
					for _, upgrade in ipairs(self.skills[weapon_unlock].upgrades) do
						if not ret[upgrade] then
							ret[upgrade] = {}
						end

						ret[upgrade][class_name] = level
					end
				end
			end
		end
	end

	return ret
end

function SkillTreeTweakData:get_weapon_unlock_level(weapon_id, class_name)
	for level, unlock_data in pairs(self.automatic_unlock_progressions[class_name]) do
		if unlock_data.weapons then
			for _, weapon_unlock in pairs(unlock_data.weapons) do
				for _, upgrade in ipairs(self.skills[weapon_unlock].upgrades) do
					if upgrade == weapon_id then
						return level
					end
				end
			end
		end
	end

	return nil
end

function SkillTreeTweakData:_init_recon_unlock_progression()
	self.automatic_unlock_progressions.recon = {
		{
			weapons = {
				"weapon_unlock_springfield",
				"weapon_unlock_carbine",
				"weapon_unlock_c96"
			}
		},
		[3] = {
			weapons = {
				"weapon_unlock_sten"
			}
		},
		[5] = {
			weapons = {
				"weapon_unlock_tt33"
			}
		},
		[7] = {
			weapons = {
				"weapon_unlock_decoy_coin"
			}
		},
		[8] = {
			weapons = {
				"weapon_unlock_grenade_concrete"
			}
		},
		[10] = {
			weapons = {
				"weapon_unlock_kar_98k"
			}
		},
		[11] = {
			weapons = {
				"weapon_unlock_shotty"
			}
		},
		[12] = {
			weapons = {
				"weapon_unlock_grenade_betty"
			}
		},
		[13] = {
			weapons = {
				"weapon_unlock_garand"
			}
		},
		[15] = {
			weapons = {
				"weapon_unlock_thompson"
			},
			unlocks = {
				"weapon_tier_unlocked_2"
			}
		},
		[18] = {
			weapons = {
				"weapon_unlock_webley"
			}
		},
		[19] = {
			weapons = {
				"weapon_unlock_welrod"
			}
		},
		[21] = {
			weapons = {
				"weapon_unlock_grenade_d343"
			}
		},
		[23] = {
			weapons = {
				"weapon_unlock_mosin"
			}
		},
		[25] = {
			weapons = {
				"weapon_unlock_mp38"
			},
			unlocks = {
				"weapon_tier_unlocked_3"
			}
		},
		[30] = {
			weapons = {
				"weapon_unlock_m1911"
			}
		},
		[31] = {
			weapons = {
				"weapon_unlock_grenade_mills"
			}
		},
		[33] = {
			weapons = {
				"weapon_unlock_lee_enfield"
			}
		},
		[35] = {
			unlocks = {
				"recon_tier_4_unlocked",
				"assault_tier_4_unlocked",
				"infiltrator_tier_4_unlocked",
				"demolitions_tier_4_unlocked"
			}
		},
		[38] = {
			weapons = {
				"weapon_unlock_sterling"
			}
		},
		[40] = {
			weapons = {
				"weapon_unlock_mp44"
			}
		}
	}
	self.default_weapons.recon = {
		primary = "m1903",
		secondary = "c96"
	}
end

function SkillTreeTweakData:_init_assault_unlock_progression()
	self.automatic_unlock_progressions.assault = {
		{
			weapons = {
				"weapon_unlock_carbine",
				"weapon_unlock_sten",
				"weapon_unlock_c96"
			}
		},
		[3] = {
			weapons = {
				"weapon_unlock_bar"
			}
		},
		[5] = {
			weapons = {
				"weapon_unlock_tt33"
			}
		},
		[8] = {
			weapons = {
				"weapon_unlock_grenade_concrete"
			}
		},
		[10] = {
			weapons = {
				"weapon_unlock_garand"
			}
		},
		[11] = {
			weapons = {
				"weapon_unlock_thompson"
			}
		},
		[15] = {
			unlocks = {
				"weapon_tier_unlocked_2"
			},
			weapons = {
				"weapon_unlock_dp28",
				"weapon_unlock_decoy_coin"
			}
		},
		[17] = {
			weapons = {
				"weapon_unlock_webley"
			}
		},
		[19] = {
			weapons = {
				"weapon_unlock_shotty"
			}
		},
		[20] = {
			weapons = {
				"weapon_unlock_grenade_betty"
			}
		},
		[21] = {
			weapons = {
				"weapon_unlock_grenade_d343"
			}
		},
		[22] = {
			weapons = {
				"weapon_unlock_welrod"
			}
		},
		[25] = {
			unlocks = {
				"weapon_tier_unlocked_3"
			},
			weapons = {
				"weapon_unlock_bren"
			}
		},
		[28] = {
			weapons = {
				"weapon_unlock_mp38"
			}
		},
		[30] = {
			weapons = {
				"weapon_unlock_m1911"
			}
		},
		[31] = {
			weapons = {
				"weapon_unlock_grenade_mills"
			}
		},
		[33] = {
			weapons = {
				"weapon_unlock_mp44"
			}
		},
		[35] = {
			unlocks = {
				"recon_tier_4_unlocked",
				"assault_tier_4_unlocked",
				"infiltrator_tier_4_unlocked",
				"demolitions_tier_4_unlocked"
			}
		},
		[38] = {
			weapons = {
				"weapon_unlock_mg42"
			}
		},
		[40] = {
			weapons = {
				"weapon_unlock_sterling"
			}
		}
	}
	self.default_weapons.assault = {
		primary = "carbine",
		secondary = "c96"
	}
end

function SkillTreeTweakData:_init_infiltrator_unlock_progression()
	self.automatic_unlock_progressions.infiltrator = {
		{
			weapons = {
				"weapon_unlock_sten",
				"weapon_unlock_winchester",
				"weapon_unlock_c96"
			}
		},
		[3] = {
			weapons = {
				"weapon_unlock_carbine"
			}
		},
		[5] = {
			weapons = {
				"weapon_unlock_tt33"
			}
		},
		[7] = {
			weapons = {
				"weapon_unlock_grenade_concrete"
			}
		},
		[10] = {
			weapons = {
				"weapon_unlock_thompson"
			}
		},
		[11] = {
			weapons = {
				"weapon_unlock_shotty",
				"weapon_unlock_decoy_coin"
			}
		},
		[13] = {
			weapons = {
				"weapon_unlock_geco"
			}
		},
		[15] = {
			weapons = {
				"weapon_unlock_garand"
			},
			unlocks = {
				"weapon_tier_unlocked_2"
			}
		},
		[18] = {
			weapons = {
				"weapon_unlock_webley"
			}
		},
		[20] = {
			weapons = {
				"weapon_unlock_grenade_d343",
				"weapon_unlock_welrod",
				"weapon_unlock_grenade_betty"
			}
		},
		[23] = {
			weapons = {
				"weapon_unlock_mp38"
			}
		},
		[25] = {
			unlocks = {
				"weapon_tier_unlocked_3"
			}
		},
		[28] = {
			weapons = {
				"weapon_unlock_ithaca"
			}
		},
		[30] = {
			weapons = {
				"weapon_unlock_m1911"
			}
		},
		[31] = {
			weapons = {
				"weapon_unlock_grenade_mills"
			}
		},
		[33] = {
			weapons = {
				"weapon_unlock_sterling"
			}
		},
		[35] = {
			unlocks = {
				"recon_tier_4_unlocked",
				"assault_tier_4_unlocked",
				"infiltrator_tier_4_unlocked",
				"demolitions_tier_4_unlocked"
			}
		},
		[38] = {
			weapons = {
				"weapon_unlock_mp44"
			}
		},
		[40] = {
			weapons = {
				"weapon_unlock_browning"
			}
		}
	}
	self.default_weapons.infiltrator = {
		primary = "sten",
		secondary = "c96"
	}
end

function SkillTreeTweakData:_init_demolitions_unlock_progression()
	self.automatic_unlock_progressions.demolitions = {
		{
			weapons = {
				"weapon_unlock_winchester",
				"weapon_unlock_bar",
				"weapon_unlock_c96"
			}
		},
		[3] = {
			weapons = {
				"weapon_unlock_carbine"
			}
		},
		[5] = {
			weapons = {
				"weapon_unlock_tt33"
			}
		},
		[6] = {
			weapons = {
				"weapon_unlock_grenade_concrete"
			}
		},
		[8] = {
			weapons = {
				"weapon_unlock_shotty"
			}
		},
		[10] = {
			weapons = {
				"weapon_unlock_geco",
				"weapon_unlock_grenade_betty"
			}
		},
		[13] = {
			weapons = {
				"weapon_unlock_dp28"
			}
		},
		[15] = {
			weapons = {
				"weapon_unlock_garand",
				"weapon_unlock_decoy_coin"
			},
			unlocks = {
				"weapon_tier_unlocked_2"
			}
		},
		[18] = {
			weapons = {
				"weapon_unlock_webley"
			}
		},
		[19] = {
			weapons = {
				"weapon_unlock_grenade_d343"
			}
		},
		[23] = {
			weapons = {
				"weapon_unlock_ithaca",
				"weapon_unlock_welrod"
			}
		},
		[25] = {
			unlocks = {
				"weapon_tier_unlocked_3"
			}
		},
		[28] = {
			weapons = {
				"weapon_unlock_bren"
			}
		},
		[30] = {
			weapons = {
				"weapon_unlock_m1911"
			}
		},
		[31] = {
			weapons = {
				"weapon_unlock_grenade_mills"
			}
		},
		[33] = {
			weapons = {
				"weapon_unlock_browning"
			}
		},
		[35] = {
			unlocks = {
				"recon_tier_4_unlocked",
				"assault_tier_4_unlocked",
				"infiltrator_tier_4_unlocked",
				"demolitions_tier_4_unlocked"
			}
		},
		[38] = {
			weapons = {
				"weapon_unlock_mp44"
			}
		},
		[40] = {
			weapons = {
				"weapon_unlock_mg42"
			}
		}
	}
	self.default_weapons.demolitions = {
		primary = "m1912",
		secondary = "c96"
	}
end
