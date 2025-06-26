function preload_all()
	for id, part in pairs(tweak_data.weapon.factory.parts) do
		if part.third_unit then
			local ids_unit_name = Idstring(part.third_unit)

			managers.dyn_resource:load(IDS_UNIT, ids_unit_name, "packages/dyn_resources", false)
		else
			print(id, "didn't have third")
		end
	end
end

function preload_all_units()
	for id, part in pairs(tweak_data.weapon.factory) do
		if part.unit then
			local ids_unit_name = Idstring(part.unit)

			managers.dyn_resource:load(IDS_UNIT, ids_unit_name, "packages/dyn_resources", false)
		else
			print(id, "didn't have unit")
		end
	end
end

function print_package_strings_unit()
	for id, part in pairs(tweak_data.weapon.factory) do
		if part.unit then
			print("<unit name=\"" .. part.unit .. "\"/>")
		end
	end
end

function print_package_strings_part_unit()
	for id, part in pairs(tweak_data.weapon.factory.parts) do
		if part.unit then
			local f = SystemFS:open(id .. ".package", "w")

			f:puts("<package>")
			f:puts("\t<units>")
			f:puts("\t\t<unit name=\"" .. part.unit .. "\"/>")
			f:puts("\t</units>")
			f:puts("</package>")
			SystemFS:close(f)
		end
	end
end

function preload_all_first()
	for id, part in pairs(tweak_data.weapon.factory.parts) do
		if part.unit then
			local ids_unit_name = Idstring(part.unit)

			managers.dyn_resource:load(IDS_UNIT, ids_unit_name, "packages/dyn_resources", false)
		else
			print(id, "didn't have unit")
		end
	end
end

function print_package_strings()
	for id, part in pairs(tweak_data.weapon.factory.parts) do
		if part.third_unit then
			print("<unit name=\"" .. part.third_unit .. "\"/>")
		end
	end
end

function print_parts_without_texture()
	Application:debug("print_parts_without_texture")

	for id, part in pairs(tweak_data.weapon.factory.parts) do
		if part.pcs then
			local guis_catalog = "guis/"
			local bundle_folder = part.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			guis_catalog = guis_catalog .. "textures/pd2/blackmarket/icons/mods/"

			if not DB:has(Idstring("texture"), guis_catalog .. id) then
				print(guis_catalog .. id)
			end
		end
	end

	Application:debug("---------------------------")
end

local is_win_32 = IS_PC
local is_not_win_32 = not is_win_32
WeaponFactoryTweakData = WeaponFactoryTweakData or class()

function WeaponFactoryTweakData:init()
	self.parts = {}

	self:_init_base_parts_for_cloning()
	self:_init_silencers()
	self:_init_nozzles()
	self:_init_gadgets()
	self:_init_vertical_grips()
	self:_init_sights()
	self:_init_m1911()
	self:_init_webley()
	self:_init_thompson()
	self:_init_sten()
	self:_init_garand()
	self:_init_garand_golden()
	self:_init_m1918()
	self:_init_m1903()
	self:_init_m1912()
	self:_init_mp38()
	self:_init_mp44()
	self:_init_carbine()
	self:_init_mg42()
	self:_init_c96()
	self:_init_mosin()
	self:_init_sterling()
	self:_init_geco()
	self:_init_dp28()
	self:_init_tt33()
	self:_init_ithaca()
	self:_init_kar_98k()
	self:_init_bren()
	self:_init_lee_enfield()
	self:_init_browning()
	self:_init_welrod()
	self:_init_shotty()
	self:_init_georg()
	self:_init_weapon_skins()
	self:create_ammunition()
	self:_init_content_unfinished()
	self:_cleanup_unfinished_content()
	self:_cleanup_unfinished_parts()
end

function WeaponFactoryTweakData:_init_silencers()
end

function WeaponFactoryTweakData:_init_nozzles()
end

function WeaponFactoryTweakData:_init_gadgets()
end

function WeaponFactoryTweakData:_init_vertical_grips()
end

function WeaponFactoryTweakData:_init_sights()
end

function WeaponFactoryTweakData:_init_content_unfinished()
end

function WeaponFactoryTweakData:_cleanup_unfinished_content()
end

function WeaponFactoryTweakData:_cleanup_unfinished_parts()
end

function WeaponFactoryTweakData:_init_base_parts_for_cloning()
end

function WeaponFactoryTweakData:_init_thompson()
	self.parts.wpn_fps_smg_thompson_b_standard = {
		name_id = "bm_wp_smg_thompson_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_b_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_b_m1928 = {
		name_id = "bm_wp_smg_thompson_b_m1928",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_b_m1928",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_b_m1928",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_body_standard = {
		name_id = "bm_wp_smg_thompson_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_body_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_body_m1928 = {
		name_id = "bm_wp_smg_thompson_body_m1928",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_body_m1928",
		fps_animation_weight = "thompson_t3_spread",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_body_m1928",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_o_standard = {
		name_id = "bm_wp_smg_thompson_o_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_o_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_o_standard",
		a_obj = "a_body",
		type = "sight",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_o_m1928 = {
		name_id = "bm_wp_smg_thompson_o_m1928",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_o_m1928",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_o_m1928",
		a_obj = "a_body",
		type = "sight",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_m_standard",
		name_id = "bm_wp_smg_thompson_m_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 4,
			prefix = "g_bullet_"
		},
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_m_standard_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_m_standard_double",
		name_id = "bm_wp_smg_thompson_m_standard_double",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_m_standard_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 4,
			prefix = "g_bullet_"
		},
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_m_drum = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_m_drum",
		name_id = "bm_wp_smg_thompson_m_drum",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_m_drum",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 0
		},
		hud_class_override = {
			panel_class = "drum_mag"
		}
	}
	self.parts.wpn_fps_smg_thompson_m_short = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_m_short",
		name_id = "bm_wp_smg_thompson_m_short",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_m_short",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 4,
			prefix = "g_bullet_"
		},
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_m_short_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_m_short_double",
		name_id = "bm_wp_smg_thompson_m_short_double",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_m_short_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 4,
			prefix = "g_bullet_"
		},
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_dh_standard = {
		name_id = "bm_wp_smg_thompson_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_dh_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_dh_m1928 = {
		name_id = "bm_wp_smg_thompson_dh_m1928",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_dh_m1928",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_dh_m1928",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_extra_sling = {
		name_id = "bm_wp_smg_thompson_extra_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_extra_sling",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_extra_sling",
		a_obj = "a_extra",
		type = "extra",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_fg_standard = {
		name_id = "bm_wp_smg_thompson_fg_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_fg_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_fg_standard",
		a_obj = "a_fg",
		type = "foregrip",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_fg_m1928 = {
		name_id = "bm_wp_smg_thompson_fg_m1928",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_fg_m1928",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_fg_m1928",
		a_obj = "a_fg",
		fps_animation_weight = "thompson_t2_spread",
		type = "foregrip",
		stats = {
			value = 0
		},
		forbids = {
			"wpn_fps_smg_thompson_extra_sling"
		}
	}
	self.parts.wpn_fps_smg_thompson_release_standard = {
		name_id = "bm_wp_smg_thompson_release_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_release_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_release_standard",
		a_obj = "a_release",
		type = "extra",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_s_standard = {
		name_id = "bm_wp_smg_thompson_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_s_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_g_standard = {
		name_id = "bm_wp_smg_thompson_g_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_g_standard",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_g_standard",
		a_obj = "a_g",
		type = "grip",
		stats = {
			value = 0
		}
	}
	self.parts.wpn_fps_smg_thompson_ns_cutts = {
		parent = "barrel",
		name_id = "bm_wp_smg_thompson_g_ns_cutts",
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson_pts/wpn_fps_smg_thompson_ns_cutts",
		third_unit = "units/vanilla/weapons/wpn_third_smg_thompson_pts/wpn_third_smg_thompson_ns_cutts",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 0
		}
	}
	self.wpn_fps_smg_thompson = {
		unit = "units/vanilla/weapons/wpn_fps_smg_thompson/wpn_fps_smg_thompson",
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		override = {
			wpn_fps_smg_thompson_ns_cutts = {
				parent = "barrel"
			}
		},
		default_blueprint = {
			"wpn_fps_smg_thompson_body_standard",
			"wpn_fps_smg_thompson_s_standard",
			"wpn_fps_smg_thompson_b_standard",
			"wpn_fps_smg_thompson_m_short",
			"wpn_fps_smg_thompson_dh_standard",
			"wpn_fps_smg_thompson_extra_sling",
			"wpn_fps_smg_thompson_fg_standard",
			"wpn_fps_smg_thompson_release_standard",
			"wpn_fps_smg_thompson_g_standard",
			"wpn_fps_smg_thompson_o_standard"
		},
		uses_parts = {
			"wpn_fps_smg_thompson_body_standard",
			"wpn_fps_smg_thompson_s_standard",
			"wpn_fps_smg_thompson_b_standard",
			"wpn_fps_smg_thompson_m_short",
			"wpn_fps_smg_thompson_dh_standard",
			"wpn_fps_smg_thompson_extra_sling",
			"wpn_fps_smg_thompson_fg_standard",
			"wpn_fps_smg_thompson_release_standard",
			"wpn_fps_smg_thompson_g_standard",
			"wpn_fps_smg_thompson_o_standard",
			"wpn_fps_smg_thompson_b_m1928",
			"wpn_fps_smg_thompson_body_m1928",
			"wpn_fps_smg_thompson_o_m1928",
			"wpn_fps_smg_thompson_m_short_double",
			"wpn_fps_smg_thompson_m_standard",
			"wpn_fps_smg_thompson_m_standard_double",
			"wpn_fps_smg_thompson_m_drum",
			"wpn_fps_smg_thompson_fg_m1928",
			"wpn_fps_smg_thompson_ns_cutts",
			"wpn_fps_smg_thompson_dh_m1928"
		}
	}
	self.wpn_fps_smg_thompson_npc = deep_clone(self.wpn_fps_smg_thompson)
	self.wpn_fps_smg_thompson_npc.unit = "units/vanilla/weapons/wpn_fps_smg_thompson/wpn_fps_smg_thompson_npc"
end

function WeaponFactoryTweakData:_init_sten()
	self.parts.wpn_fps_smg_sten_b_standard = {
		name_id = "bm_wp_smg_sten_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_o_lee_enfield = {
		name_id = "bm_wp_smg_sten_o_lee_enfield",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_o_lee_enfield",
		a_obj = "a_b",
		type = "sight",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_ns_slanted = {
		parent = "barrel",
		name_id = "bm_wp_smg_sten_ns_slanted",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_ns_slanted",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_body_standard = {
		name_id = "bm_wp_smg_sten_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_body_standard",
		a_obj = "a_body",
		type = "upper_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_body_mk3 = {
		name_id = "bm_wp_smg_sten_body_mk3",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_body_mk3",
		a_obj = "a_body",
		type = "upper_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_body_mk3_vented = {
		name_id = "bm_wp_smg_sten_body_mk3_vented",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_body_mk3_vented",
		a_obj = "a_body",
		type = "upper_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_m_standard",
		name_id = "bm_wp_smg_sten_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_m_standard_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_m_standard_double",
		name_id = "bm_wp_smg_sten_m_standard_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_m_long = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_m_long",
		name_id = "bm_wp_smg_sten_m_long",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_m_long_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_m_long_double",
		name_id = "bm_wp_smg_sten_m_long_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_m_short = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_m_short",
		name_id = "bm_wp_smg_sten_m_short",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_dh_standard = {
		name_id = "bm_wp_smg_sten_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_s_standard = {
		name_id = "bm_wp_smg_sten_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_s_wooden = {
		name_id = "bm_wp_smg_sten_s_wooden",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_s_wooden",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_fg_wooden = {
		name_id = "bm_wp_smg_sten_fg_wooden",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_fg_wooden",
		fps_animation_weight = "sten_t2_spread",
		a_obj = "a_body",
		type = "foregrip",
		stats = {
			value = 1
		},
		stance_mod = {
			wpn_fps_smg_sten = {
				translation = Vector3(-0.1535, 10.5846, 2.7523)
			}
		}
	}
	self.parts.wpn_fps_smg_sten_g_wooden = {
		name_id = "bm_wp_smg_sten_g_wooden",
		unit = "units/vanilla/weapons/wpn_fps_smg_sten_pts/wpn_fps_smg_sten_g_wooden",
		fps_animation_weight = "sten_t3_recoil",
		a_obj = "a_body",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sten_b_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_b_standard"
	self.parts.wpn_fps_smg_sten_o_lee_enfield.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_o_lee_enfield"
	self.parts.wpn_fps_smg_sten_ns_slanted.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_ns_slanted"
	self.parts.wpn_fps_smg_sten_body_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_body_standard"
	self.parts.wpn_fps_smg_sten_body_mk3.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_body_mk3"
	self.parts.wpn_fps_smg_sten_body_mk3_vented.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_body_mk3_vented"
	self.parts.wpn_fps_smg_sten_m_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_m_standard"
	self.parts.wpn_fps_smg_sten_m_standard_double.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_m_standard_double"
	self.parts.wpn_fps_smg_sten_m_long.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_m_long"
	self.parts.wpn_fps_smg_sten_m_long_double.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_m_long_double"
	self.parts.wpn_fps_smg_sten_m_short.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_m_short"
	self.parts.wpn_fps_smg_sten_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_dh_standard"
	self.parts.wpn_fps_smg_sten_s_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_s_standard"
	self.parts.wpn_fps_smg_sten_s_wooden.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_s_wooden"
	self.parts.wpn_fps_smg_sten_fg_wooden.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_fg_wooden"
	self.parts.wpn_fps_smg_sten_g_wooden.third_unit = "units/vanilla/weapons/wpn_third_smg_sten_pts/wpn_third_smg_sten_g_wooden"
	self.wpn_fps_smg_sten = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sten/wpn_fps_smg_sten",
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_smg_sten_body_standard",
			"wpn_fps_smg_sten_b_standard",
			"wpn_fps_smg_sten_m_short",
			"wpn_fps_smg_sten_dh_standard",
			"wpn_fps_smg_sten_s_standard"
		},
		uses_parts = {
			"wpn_fps_smg_sten_body_standard",
			"wpn_fps_smg_sten_b_standard",
			"wpn_fps_smg_sten_m_short",
			"wpn_fps_smg_sten_dh_standard",
			"wpn_fps_smg_sten_s_standard",
			"wpn_fps_smg_sten_m_standard",
			"wpn_fps_smg_sten_m_standard_double",
			"wpn_fps_smg_sten_m_long",
			"wpn_fps_smg_sten_m_long_double",
			"wpn_fps_smg_sten_s_wooden",
			"wpn_fps_smg_sten_fg_wooden",
			"wpn_fps_smg_sten_g_wooden",
			"wpn_fps_smg_sten_ns_slanted",
			"wpn_fps_smg_sten_body_mk3",
			"wpn_fps_smg_sten_body_mk3_vented",
			"wpn_fps_smg_sten_o_lee_enfield"
		}
	}
	self.wpn_fps_smg_sten_npc = deep_clone(self.wpn_fps_smg_sten)
	self.wpn_fps_smg_sten_npc.unit = "units/vanilla/weapons/wpn_fps_smg_sten/wpn_fps_smg_sten_npc"
end

function WeaponFactoryTweakData:_init_garand()
	self.parts.wpn_fps_ass_garand_b_standard = {
		name_id = "bm_wp_ass_garand_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_b_tanker = {
		name_id = "bm_wp_ass_garand_b_tanker",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_b_tanker",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_ass_garand_extra_swiwel"
		}
	}
	self.parts.wpn_fps_ass_garand_body_standard = {
		name_id = "bm_wp_ass_garand_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_ns_conical = {
		parent = "barrel",
		name_id = "bm_wp_ass_garand_ns_conical",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_ns_conical",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_m_standard",
		name_id = "bm_wp_ass_garand_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 8,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_m_bar_standard = {
		name_id = "bm_wp_ass_garand_m_bar_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_m_bar_standard",
		a_obj = "a_body",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_m_bar_extended = {
		name_id = "bm_wp_ass_garand_m_bar_extended",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_m_bar_extended",
		a_obj = "a_body",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_bolt_standard = {
		name_id = "bm_wp_ass_garand_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_bolt_standard",
		a_obj = "a_bolt",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_dh_standard = {
		name_id = "bm_wp_ass_garand_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_extra_swiwel = {
		name_id = "bm_wp_ass_garand_extra_swiwel",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_extra_swiwel",
		a_obj = "a_extra",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_extra1_swiwel = {
		name_id = "bm_wp_ass_garand_extra1_swiwel",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_extra1_swiwel",
		a_obj = "a_extra1",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_s_standard = {
		name_id = "bm_wp_ass_garand_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_s_folding = {
		name_id = "bm_wp_ass_garand_s_folding",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_s_folding",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_ass_garand_s_cheek_rest"
		}
	}
	self.parts.wpn_fps_ass_garand_s_cheek_rest = {
		name_id = "bm_wp_ass_garand_s_cheek_rest",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_s_cheek_rest",
		a_obj = "a_s",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_strip_standard = {
		name_id = "bm_wp_ass_garand_strip_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_strip_standard",
		a_obj = "a_strip",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_b_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_b_standard"
	self.parts.wpn_fps_ass_garand_b_tanker.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_b_tanker"
	self.parts.wpn_fps_ass_garand_body_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_body_standard"
	self.parts.wpn_fps_ass_garand_ns_conical.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_ns_conical"
	self.parts.wpn_fps_ass_garand_m_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_m_standard"
	self.parts.wpn_fps_ass_garand_m_bar_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_m_bar_standard"
	self.parts.wpn_fps_ass_garand_m_bar_extended.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_m_bar_extended"
	self.parts.wpn_fps_ass_garand_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_bolt_standard"
	self.parts.wpn_fps_ass_garand_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_dh_standard"
	self.parts.wpn_fps_ass_garand_extra_swiwel.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_extra_swiwel"
	self.parts.wpn_fps_ass_garand_extra1_swiwel.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_extra1_swiwel"
	self.parts.wpn_fps_ass_garand_s_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_s_standard"
	self.parts.wpn_fps_ass_garand_s_folding.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_s_folding"
	self.parts.wpn_fps_ass_garand_s_cheek_rest.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_s_cheek_rest"
	self.parts.wpn_fps_ass_garand_strip_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_strip_standard"
	self.wpn_fps_ass_garand = {
		unit = "units/vanilla/weapons/wpn_fps_ass_garand/wpn_fps_ass_garand",
		animations = {
			fire = "recoil",
			magazine_empty = "magazine_empty",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_ass_garand_body_standard",
			"wpn_fps_ass_garand_b_standard",
			"wpn_fps_ass_garand_m_standard",
			"wpn_fps_ass_garand_bolt_standard",
			"wpn_fps_ass_garand_dh_standard",
			"wpn_fps_ass_garand_extra_swiwel",
			"wpn_fps_ass_garand_extra1_swiwel",
			"wpn_fps_ass_garand_s_standard",
			"wpn_fps_ass_garand_strip_standard"
		},
		uses_parts = {
			"wpn_fps_ass_garand_body_standard",
			"wpn_fps_ass_garand_b_standard",
			"wpn_fps_ass_garand_m_standard",
			"wpn_fps_ass_garand_bolt_standard",
			"wpn_fps_ass_garand_dh_standard",
			"wpn_fps_ass_garand_extra_swiwel",
			"wpn_fps_ass_garand_extra1_swiwel",
			"wpn_fps_ass_garand_s_standard",
			"wpn_fps_ass_garand_strip_standard",
			"wpn_fps_ass_garand_ns_conical",
			"wpn_fps_ass_garand_b_tanker",
			"wpn_fps_ass_garand_s_cheek_rest",
			"wpn_fps_ass_garand_s_folding",
			"wpn_fps_ass_garand_m_bar_standard",
			"wpn_fps_ass_garand_m_bar_extended",
			"wpn_fps_ass_garand_golden_body_standard",
			"wpn_fps_ass_garand_golden_b_standard",
			"wpn_fps_ass_garand_golden_bolt_standard",
			"wpn_fps_ass_garand_golden_dh_standard",
			"wpn_fps_ass_garand_golden_extra_swiwel",
			"wpn_fps_ass_garand_golden_extra1_swiwel",
			"wpn_fps_ass_garand_golden_s_standard",
			"wpn_fps_ass_garand_golden_strip_standard",
			"wpn_fps_ass_garand_golden_ns_conical",
			"wpn_fps_ass_garand_golden_b_tanker",
			"wpn_fps_ass_garand_golden_s_folding",
			"wpn_fps_ass_garand_golden_m_bar_standard",
			"wpn_fps_ass_garand_golden_m_bar_extended"
		}
	}
	self.wpn_fps_ass_garand_npc = deep_clone(self.wpn_fps_ass_garand)
	self.wpn_fps_ass_garand_npc.unit = "units/vanilla/weapons/wpn_fps_ass_garand/wpn_fps_ass_garand_npc"
end

function WeaponFactoryTweakData:_init_garand_golden()
	self.parts.wpn_fps_ass_garand_golden_b_standard = {
		name_id = "bm_wp_ass_garand_golden_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_b_tanker = {
		name_id = "bm_wp_ass_garand_golden_b_tanker",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_b_tanker",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_ass_garand_golden_extra_swiwel"
		}
	}
	self.parts.wpn_fps_ass_garand_golden_body_standard = {
		name_id = "bm_wp_ass_garand_golden_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_ns_conical = {
		parent = "barrel",
		name_id = "bm_wp_ass_garand_golden_ns_conical",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_ns_conical",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_m_standard",
		name_id = "bm_wp_ass_garand_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 8,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_m_bar_standard = {
		name_id = "bm_wp_ass_garand_golden_m_bar_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_m_bar_standard",
		a_obj = "a_body",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_m_bar_extended = {
		name_id = "bm_wp_ass_garand_golden_m_bar_extended",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_m_bar_extended",
		a_obj = "a_body",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_bolt_standard = {
		name_id = "bm_wp_ass_garand_golden_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_bolt_standard",
		a_obj = "a_bolt",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_dh_standard = {
		name_id = "bm_wp_ass_garand_golden_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_extra_swiwel = {
		name_id = "bm_wp_ass_garand_golden_extra_swiwel",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_extra_swiwel",
		a_obj = "a_extra",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_extra1_swiwel = {
		name_id = "bm_wp_ass_garand_golden_extra1_swiwel",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_extra1_swiwel",
		a_obj = "a_extra1",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_s_standard = {
		name_id = "bm_wp_ass_garand_golden_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_s_folding = {
		name_id = "bm_wp_ass_garand_golden_s_folding",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_s_folding",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_ass_garand_s_cheek_rest"
		}
	}
	self.parts.wpn_fps_ass_garand_s_cheek_rest = {
		name_id = "bm_wp_ass_garand_s_cheek_rest",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_s_cheek_rest",
		a_obj = "a_s",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_strip_standard = {
		name_id = "bm_wp_ass_garand_golden_strip_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_garand_pts/wpn_fps_ass_garand_golden_strip_standard",
		a_obj = "a_strip",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_garand_golden_b_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_b_standard"
	self.parts.wpn_fps_ass_garand_golden_b_tanker.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_b_tanker"
	self.parts.wpn_fps_ass_garand_golden_body_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_body_standard"
	self.parts.wpn_fps_ass_garand_golden_ns_conical.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_ns_conical"
	self.parts.wpn_fps_ass_garand_m_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_m_standard"
	self.parts.wpn_fps_ass_garand_golden_m_bar_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_m_bar_standard"
	self.parts.wpn_fps_ass_garand_golden_m_bar_extended.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_m_bar_extended"
	self.parts.wpn_fps_ass_garand_golden_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_bolt_standard"
	self.parts.wpn_fps_ass_garand_golden_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_dh_standard"
	self.parts.wpn_fps_ass_garand_golden_extra_swiwel.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_extra_swiwel"
	self.parts.wpn_fps_ass_garand_golden_extra1_swiwel.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_extra1_swiwel"
	self.parts.wpn_fps_ass_garand_golden_s_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_s_standard"
	self.parts.wpn_fps_ass_garand_golden_s_folding.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_s_folding"
	self.parts.wpn_fps_ass_garand_s_cheek_rest.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_s_cheek_rest"
	self.parts.wpn_fps_ass_garand_golden_strip_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_garand_pts/wpn_third_ass_garand_golden_strip_standard"
end

function WeaponFactoryTweakData:_init_m1918()
	self.parts.wpn_fps_lmg_m1918_b_standard = {
		name_id = "bm_wp_lmg_m1918_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_ns_standard = {
		parent = "barrel",
		name_id = "bm_wp_lmg_m1918_ns_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_ns_standard",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_ns_cutts = {
		parent = "barrel",
		name_id = "bm_wp_lmg_m1918_ns_cutts",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_ns_cutts",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_body_standard = {
		name_id = "bm_wp_lmg_m1918_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_carry_handle = {
		name_id = "bm_wp_lmg_m1918_carry_handle",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_carry_handle",
		a_obj = "a_body",
		type = "handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_bipod = {
		parent = "barrel",
		name_id = "bm_wp_lmg_m1918_bipod",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_bipod",
		a_obj = "a_bp",
		type = "bipod",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_g_monitor = {
		name_id = "bm_wp_lmg_m1918_g_monitor",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_g_monitor",
		fps_animation_weight = "m1918_t1_spread",
		a_obj = "a_body",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_m_standard = {
		name_id = "bm_wp_lmg_m1918_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_m_extended = {
		name_id = "bm_wp_lmg_m1918_m_extended",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_m_extended",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_dh_standard = {
		name_id = "bm_wp_lmg_m1918_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918_pts/wpn_fps_lmg_m1918_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_m1918_b_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_b_standard"
	self.parts.wpn_fps_lmg_m1918_ns_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_ns_standard"
	self.parts.wpn_fps_lmg_m1918_ns_cutts.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_ns_cutts"
	self.parts.wpn_fps_lmg_m1918_body_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_body_standard"
	self.parts.wpn_fps_lmg_m1918_carry_handle.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_carry_handle"
	self.parts.wpn_fps_lmg_m1918_bipod.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_bipod"
	self.parts.wpn_fps_lmg_m1918_g_monitor.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_g_monitor"
	self.parts.wpn_fps_lmg_m1918_m_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_m_standard"
	self.parts.wpn_fps_lmg_m1918_m_extended.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_m_extended"
	self.parts.wpn_fps_lmg_m1918_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_m1918_pts/wpn_third_lmg_m1918_dh_standard"
	self.wpn_fps_lmg_m1918 = {
		unit = "units/vanilla/weapons/wpn_fps_lmg_m1918/wpn_fps_lmg_m1918",
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_lmg_m1918_body_standard",
			"wpn_fps_lmg_m1918_b_standard",
			"wpn_fps_lmg_m1918_ns_standard",
			"wpn_fps_lmg_m1918_m_standard",
			"wpn_fps_lmg_m1918_dh_standard"
		},
		uses_parts = {
			"wpn_fps_lmg_m1918_body_standard",
			"wpn_fps_lmg_m1918_b_standard",
			"wpn_fps_lmg_m1918_ns_standard",
			"wpn_fps_lmg_m1918_m_standard",
			"wpn_fps_lmg_m1918_dh_standard",
			"wpn_fps_lmg_m1918_ns_cutts",
			"wpn_fps_lmg_m1918_g_monitor",
			"wpn_fps_lmg_m1918_m_extended",
			"wpn_fps_lmg_m1918_carry_handle",
			"wpn_fps_lmg_m1918_bipod"
		}
	}
	self.wpn_fps_lmg_m1918_npc = deep_clone(self.wpn_fps_lmg_m1918)
	self.wpn_fps_lmg_m1918_npc.unit = "units/vanilla/weapons/wpn_fps_lmg_m1918/wpn_fps_lmg_m1918_npc"
end

function WeaponFactoryTweakData:_init_m1903()
	self.parts.wpn_fps_snp_m1903_b_standard = {
		name_id = "bm_wp_snp_m1903_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_body_type_s = {
		name_id = "bm_wp_snp_m1903_body_type_s",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_body_type_s",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_body_type_c = {
		name_id = "bm_wp_snp_m1903_body_type_c",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_body_type_c",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_s_cheek_rest = {
		name_id = "bm_wp_snp_m1903_s_cheek_rest",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_s_cheek_rest",
		a_obj = "a_body",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_bolt_firepin = {
		name_id = "bm_wp_snp_m1903_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_bolt_firepin",
		a_obj = "a_firepin",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_bolt_standard = {
		name_id = "bm_wp_snp_m1903_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_bolt_standard",
		a_obj = "a_bolt",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_dh_standard = {
		name_id = "bm_wp_snp_m1903_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_extra_follower = {
		name_id = "bm_wp_snp_m1903_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_extra_follower",
		a_obj = "a_follower",
		type = "extra",
		st5ats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_m_standard",
		name_id = "bm_wp_snp_m1903_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		}
	}
	self.parts.wpn_fps_snp_m1903_m_extended = {
		name_id = "bm_wp_snp_m1903_m_standard",
		parent = "body",
		a_obj = "a_m",
		type = "magazine_ext",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_m_extended",
		bullet_objects = {
			amount = 10,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_snp_m1903_m_standard"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		}
	}
	self.parts.wpn_fps_snp_m1903_ns_mclean = {
		parent = "barrel",
		name_id = "bm_wp_snp_m1903_ns_mclean",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_ns_mclean",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_m1903_o_scope = {
		name_id = "bm_wp_snp_m1903_o_scope",
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903_pts/wpn_fps_snp_m1903_o_scope",
		reticle_obj = "g_reticle_1",
		a_obj = "a_o",
		type = "scope",
		stats = {
			zoom = 10,
			value = 1
		},
		stance_mod = {
			wpn_fps_snp_m1903 = {
				lens_distortion_power = 1.02,
				translation = Vector3(0.015, -30, -1.69)
			}
		}
	}
	self.parts.wpn_fps_snp_m1903_b_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_b_standard"
	self.parts.wpn_fps_snp_m1903_body_type_s.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_body_type_s"
	self.parts.wpn_fps_snp_m1903_body_type_c.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_body_type_c"
	self.parts.wpn_fps_snp_m1903_s_cheek_rest.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_s_cheek_rest"
	self.parts.wpn_fps_snp_m1903_bolt_firepin.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_bolt_firepin"
	self.parts.wpn_fps_snp_m1903_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_bolt_standard"
	self.parts.wpn_fps_snp_m1903_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_dh_standard"
	self.parts.wpn_fps_snp_m1903_extra_follower.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_extra_follower"
	self.parts.wpn_fps_snp_m1903_m_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_m_standard"
	self.parts.wpn_fps_snp_m1903_m_extended.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_m_extended"
	self.parts.wpn_fps_snp_m1903_ns_mclean.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_ns_mclean"
	self.parts.wpn_fps_snp_m1903_o_scope.third_unit = "units/vanilla/weapons/wpn_third_snp_m1903_pts/wpn_third_snp_m1903_o_scope"
	self.wpn_fps_snp_m1903 = {
		unit = "units/vanilla/weapons/wpn_fps_snp_m1903/wpn_fps_snp_m1903",
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		},
		default_blueprint = {
			"wpn_fps_snp_m1903_body_type_s",
			"wpn_fps_snp_m1903_b_standard",
			"wpn_fps_snp_m1903_bolt_firepin",
			"wpn_fps_snp_m1903_bolt_standard",
			"wpn_fps_snp_m1903_dh_standard",
			"wpn_fps_snp_m1903_extra_follower",
			"wpn_fps_snp_m1903_m_standard"
		},
		uses_parts = {
			"wpn_fps_snp_m1903_body_type_s",
			"wpn_fps_snp_m1903_b_standard",
			"wpn_fps_snp_m1903_bolt_firepin",
			"wpn_fps_snp_m1903_bolt_standard",
			"wpn_fps_snp_m1903_dh_standard",
			"wpn_fps_snp_m1903_extra_follower",
			"wpn_fps_snp_m1903_m_standard",
			"wpn_fps_snp_m1903_body_type_c",
			"wpn_fps_snp_m1903_s_cheek_rest",
			"wpn_fps_snp_m1903_ns_mclean",
			"wpn_fps_snp_m1903_o_scope",
			"wpn_fps_snp_m1903_m_extended"
		}
	}
	self.wpn_fps_snp_m1903_npc = deep_clone(self.wpn_fps_snp_m1903)
	self.wpn_fps_snp_m1903_npc.unit = "units/vanilla/weapons/wpn_fps_snp_m1903/wpn_fps_snp_m1903_npc"
end

function WeaponFactoryTweakData:_init_kar_98k()
	self.parts.wpn_fps_snp_kar_98k_b_standard = {
		name_id = "bm_wp_snp_kar_98k_b_standard",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_b_standard",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_b_long = {
		name_id = "bm_wp_snp_kar_98k_b_long",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_b_long",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_body_standard = {
		name_id = "bm_wp_snp_kar_98k_body_standard",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_body_standard",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_body_standard",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_body_grip = {
		name_id = "bm_wp_snp_kar_98k_body_grip",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_body_grip",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_body_grip",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_pad_standard = {
		parent = "body",
		name_id = "bm_wp_snp_kar_98k_pad_standard",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_pad_standard",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_pad_standard",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_pad_big = {
		parent = "body",
		name_id = "bm_wp_snp_kar_98k_pad_big",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_pad_big",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_pad_big",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_firepin = {
		name_id = "bm_wp_snp_kar_98k_firepin",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_firepin",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_firepin",
		a_obj = "a_bolt",
		type = "firepin",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_bolt_standard = {
		name_id = "bm_wp_snp_kar_98k_bolt",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_bolt_standard",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_bolt_standard",
		a_obj = "a_bolt",
		type = "bolt",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_dh_standard = {
		name_id = "bm_wp_snp_kar_98k_dh_standard",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_dh_standard",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_strip = {
		name_id = "bm_wp_snp_kar_98k_strip",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_strip",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_strip",
		a_obj = "a_strip",
		type = "strip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_trigger = {
		name_id = "bm_wp_snp_kar_98k_trigger",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_trigger",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_trigger",
		a_obj = "a_trigger",
		type = "trigger",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_bullet = {
		name_id = "bm_wp_snp_kar_98k_bullet",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_bullet",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_bullet",
		a_obj = "a_bullets",
		type = "magazine",
		stats = {
			value = 1
		},
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		}
	}
	self.parts.wpn_fps_snp_kar_98k_bullets = {
		name_id = "bm_wp_snp_kar_98k_bullets",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_bullets",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_bullets",
		a_obj = "a_bullets",
		type = "bullets",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_m_extended = {
		name_id = "bm_wp_snp_kar_98k_m_extended",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_m_extended",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_m_extended",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		},
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		}
	}
	self.parts.wpn_fps_snp_kar_98k_m_long = {
		name_id = "bm_wp_snp_kar_98k_m_long",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_m_long",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_m_long",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_kar_98k_o_scope = {
		name_id = "bm_wp_snp_kar_98k_o_scope",
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k_pts/wpn_fps_snp_kar_98k_o_scope",
		third_unit = "units/upd_003/weapons/wpn_third_snp_kar_98k_pts/wpn_third_snp_kar_98k_o_scope",
		a_obj = "a_o",
		reticle_obj = "g_reticle",
		type = "scope",
		stats = {
			zoom = 9,
			value = 1
		},
		stance_mod = {
			wpn_fps_snp_kar_98k = {
				lens_distortion_power = 1.02,
				translation = Vector3(0, -24, -3.8478)
			}
		}
	}
	self.wpn_fps_snp_kar_98k = {
		unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k/wpn_fps_snp_kar_98k",
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			fire = "recoil",
			reload_enter = "reload_enter",
			fire_steelsight = "recoil",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_snp_kar_98k_strip",
			"wpn_fps_snp_kar_98k_dh_standard",
			"wpn_fps_snp_kar_98k_bolt_standard",
			"wpn_fps_snp_kar_98k_b_standard",
			"wpn_fps_snp_kar_98k_body_standard",
			"wpn_fps_snp_kar_98k_firepin",
			"wpn_fps_snp_kar_98k_bullet",
			"wpn_fps_snp_kar_98k_bullets",
			"wpn_fps_snp_kar_98k_trigger",
			"wpn_fps_snp_kar_98k_pad_standard"
		},
		uses_parts = {
			"wpn_fps_snp_kar_98k_strip",
			"wpn_fps_snp_kar_98k_dh_standard",
			"wpn_fps_snp_kar_98k_bolt_standard",
			"wpn_fps_snp_kar_98k_b_standard",
			"wpn_fps_snp_kar_98k_body_standard",
			"wpn_fps_snp_kar_98k_firepin",
			"wpn_fps_snp_kar_98k_bullet",
			"wpn_fps_snp_kar_98k_bullets",
			"wpn_fps_snp_kar_98k_trigger",
			"wpn_fps_snp_kar_98k_pad_standard",
			"wpn_fps_snp_kar_98k_b_long",
			"wpn_fps_snp_kar_98k_body_grip",
			"wpn_fps_snp_kar_98k_pad_big",
			"wpn_fps_snp_kar_98k_m_extended",
			"wpn_fps_snp_kar_98k_m_long",
			"wpn_fps_snp_kar_98k_o_scope"
		}
	}
	self.wpn_fps_snp_kar_98k_npc = deep_clone(self.wpn_fps_snp_kar_98k)
	self.wpn_fps_snp_kar_98k_npc.unit = "units/upd_003/weapons/wpn_fps_snp_kar_98k/wpn_fps_snp_kar_98k_npc"
end

function WeaponFactoryTweakData:_init_lee_enfield()
	self.parts.wpn_fps_snp_lee_enfield_b_standard = {
		name_id = "bm_wp_snp_lee_enfield_b_standard",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_b_standard",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_b_long = {
		name_id = "bm_wp_snp_lee_enfield_b_long",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_b_long",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_ns_coned = {
		parent = "barrel",
		name_id = "bm_wp_snp_lee_enfield_ns_coned",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_ns_coned",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_ns_coned",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_body_standard = {
		name_id = "bm_wp_snp_lee_enfield_body_standard",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_body_standard",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_body_standard",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_s_standard = {
		name_id = "bm_wp_snp_lee_enfield_s_standard",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_s_standard",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_pad_buffered = {
		name_id = "bm_wp_snp_lee_enfield_pad_buffered",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_pad_buffered",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_pad_buffered",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_cheek_rest = {
		name_id = "bm_wp_snp_lee_enfield_cheek_rest",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_cheek_rest",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_cheek_rest",
		a_obj = "a_rest",
		type = "rest",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_firepin = {
		name_id = "bm_wp_snp_lee_enfield_firepin",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_firepin",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_firepin",
		a_obj = "a_firepin",
		type = "firepin",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_dh_standard = {
		name_id = "bm_wp_snp_lee_enfield_dh_standard",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_dh_standard",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_m_standard = {
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_m_standard",
		name_id = "bm_wp_snp_lee_enfield_m_standard",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_bullet = {
		name_id = "bm_wp_snp_lee_enfield_bullet",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_bullet",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_bullet",
		a_obj = "a_bullet",
		type = "extra",
		animations = {
			reload_not_empty_exit = "reload_exit",
			reload_exit = "reload_exit",
			reload_enter = "reload_enter",
			fire = "recoil",
			fire_steelsight = "recoil"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_m_extended = {
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_m_extended",
		name_id = "bm_wp_snp_lee_enfield_m_extended",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_m_extended",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_lee_enfield_o_scope = {
		name_id = "bm_wp_snp_lee_enfield_o_scope",
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield_pts/wpn_fps_snp_lee_enfield_o_scope",
		third_unit = "units/upd_015/weapons/wpn_third_snp_lee_enfield_pts/wpn_third_snp_lee_enfield_o_scope",
		a_obj = "a_o",
		reticle_obj = "g_reticle",
		type = "scope",
		stats = {
			zoom = 9,
			value = 1
		},
		stance_mod = {
			wpn_fps_snp_lee_enfield = {
				lens_distortion_power = 1.02,
				translation = Vector3(0, -16, -2.2586)
			}
		}
	}
	self.wpn_fps_snp_lee_enfield = {
		unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield/wpn_fps_snp_lee_enfield",
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		animations = {
			reload_not_empty_exit = "reload_exit",
			fire = "recoil",
			reload_enter = "reload_enter",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_snp_lee_enfield_dh_standard",
			"wpn_fps_snp_lee_enfield_b_standard",
			"wpn_fps_snp_lee_enfield_body_standard",
			"wpn_fps_snp_lee_enfield_firepin",
			"wpn_fps_snp_lee_enfield_s_standard",
			"wpn_fps_snp_lee_enfield_m_standard",
			"wpn_fps_snp_lee_enfield_bullet"
		},
		uses_parts = {
			"wpn_fps_snp_lee_enfield_dh_standard",
			"wpn_fps_snp_lee_enfield_b_standard",
			"wpn_fps_snp_lee_enfield_body_standard",
			"wpn_fps_snp_lee_enfield_firepin",
			"wpn_fps_snp_lee_enfield_s_standard",
			"wpn_fps_snp_lee_enfield_m_standard",
			"wpn_fps_snp_lee_enfield_bullet",
			"wpn_fps_snp_lee_enfield_b_long",
			"wpn_fps_snp_lee_enfield_ns_coned",
			"wpn_fps_snp_lee_enfield_pad_buffered",
			"wpn_fps_snp_lee_enfield_cheek_rest",
			"wpn_fps_snp_lee_enfield_m_extended",
			"wpn_fps_snp_lee_enfield_o_scope"
		}
	}
	self.wpn_fps_snp_lee_enfield_npc = deep_clone(self.wpn_fps_snp_lee_enfield)
	self.wpn_fps_snp_lee_enfield_npc.unit = "units/upd_015/weapons/wpn_fps_snp_lee_enfield/wpn_fps_snp_lee_enfield_npc"
end

function WeaponFactoryTweakData:_init_m1911()
	self.parts.wpn_fps_pis_m1911_body_standard = {
		name_id = "bm_wp_pis_m1911_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_body_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_b_standard = {
		name_id = "bm_wp_pis_m1911_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_b_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_sl_standard = {
		name_id = "bm_wp_pis_m1911_sl_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_sl_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_sl_standard",
		a_obj = "a_sl",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_m_standard",
		name_id = "bm_wp_pis_m1911_m_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 8,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_m_extended = {
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_m_extended",
		name_id = "bm_wp_pis_m1911_m_extended",
		fps_animation_weight = "m1911_t1_mag",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_m_extended",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_m_banana = {
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_m_banana",
		name_id = "bm_wp_pis_m1911_m_banana",
		fps_animation_weight = "m1911_t2_mag",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_m_banana",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_dh_hammer = {
		name_id = "bm_wp_pis_m1911_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_dh_hammer",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_dh_hammer",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_ns_cutts = {
		parent = "barrel",
		name_id = "bm_wp_pis_m1911_ns_cutts",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_ns_cutts",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_ns_cutts",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_fg_tommy = {
		name_id = "bm_wp_pis_m1911_fg_tommy",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_fg_tommy",
		fps_animation_weight = "m1911_t2_spread",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_fg_tommy",
		a_obj = "a_body",
		type = "foregrip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_m1911_s_wooden = {
		name_id = "bm_wp_pis_m1911_s_wooden",
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911_pts/wpn_fps_pis_m1911_s_wooden",
		third_unit = "units/vanilla/weapons/wpn_third_pis_m1911_pts/wpn_third_pis_m1911_s_wooden",
		a_obj = "a_body",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_pis_m1911 = {
		unit = "units/vanilla/weapons/wpn_fps_pis_m1911/wpn_fps_pis_m1911",
		optional_types = {
			"barrel_ext",
			"gadget"
		},
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_pis_m1911_body_standard",
			"wpn_fps_pis_m1911_b_standard",
			"wpn_fps_pis_m1911_sl_standard",
			"wpn_fps_pis_m1911_m_standard",
			"wpn_fps_pis_m1911_dh_hammer"
		},
		uses_parts = {
			"wpn_fps_pis_m1911_body_standard",
			"wpn_fps_pis_m1911_b_standard",
			"wpn_fps_pis_m1911_sl_standard",
			"wpn_fps_pis_m1911_m_standard",
			"wpn_fps_pis_m1911_dh_hammer",
			"wpn_fps_pis_m1911_m_extended",
			"wpn_fps_pis_m1911_m_banana",
			"wpn_fps_pis_m1911_ns_cutts",
			"wpn_fps_pis_m1911_fg_tommy",
			"wpn_fps_pis_m1911_s_wooden"
		}
	}
	self.wpn_fps_pis_m1911_npc = deep_clone(self.wpn_fps_pis_m1911)
	self.wpn_fps_pis_m1911_npc.unit = "units/vanilla/weapons/wpn_fps_pis_m1911/wpn_fps_pis_m1911_npc"
end

function WeaponFactoryTweakData:_init_geco()
	self.parts.wpn_fps_sho_geco_b_standard = {
		name_id = "bm_wp_sho_geco_b_standard",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_b_standard",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_b_short = {
		name_id = "bm_wp_sho_geco_b_short",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_b_short",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_b_short",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_s_standard = {
		name_id = "bm_wp_sho_geco_s_standard",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_s_standard",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_s_cheek_rest = {
		name_id = "bm_wp_sho_geco_s_cheek_rest",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_s_cheek_rest",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_s_cheek_rest",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_lock = {
		name_id = "bm_wp_sho_geco_lock",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_lock",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_lock",
		a_obj = "a_lock",
		type = "lock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_body_standard = {
		name_id = "bm_wp_sho_geco_body_standard",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_body_standard",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_shell_1 = {
		name_id = "bm_wp_sho_geco_shell_1",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_shell_1",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_shell_1",
		a_obj = "a_shell_1",
		type = "shell_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_shell_2 = {
		name_id = "bm_wp_sho_geco_shell_2",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_shell_2",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_shell_2",
		a_obj = "a_shell_2",
		type = "shell_2",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_trigger_1 = {
		name_id = "bm_wp_sho_geco_trigger_1",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_trigger_1",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_trigger_1",
		a_obj = "a_trigger_1",
		type = "trigger_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_geco_trigger_2 = {
		name_id = "bm_wp_sho_geco_trigger_2",
		unit = "units/upd_001/weapons/wpn_fps_sho_geco_pts/wpn_fps_sho_geco_trigger_2",
		third_unit = "units/upd_001/weapons/wpn_third_sho_geco_pts/wpn_third_sho_geco_trigger_2",
		a_obj = "a_trigger_2",
		type = "trigger_2",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_sho_geco = {
		unit = "units/upd_001/weapons/wpn_fps_sho_geco/wpn_fps_sho_geco",
		optional_types = {
			"barrel_ext",
			"gadget"
		},
		animations = {
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_sho_geco_b_standard",
			"wpn_fps_sho_geco_s_standard",
			"wpn_fps_sho_geco_lock",
			"wpn_fps_sho_geco_body_standard",
			"wpn_fps_sho_geco_shell_1",
			"wpn_fps_sho_geco_shell_2",
			"wpn_fps_sho_geco_trigger_1",
			"wpn_fps_sho_geco_trigger_2"
		},
		uses_parts = {
			"wpn_fps_sho_geco_b_standard",
			"wpn_fps_sho_geco_s_standard",
			"wpn_fps_sho_geco_lock",
			"wpn_fps_sho_geco_body_standard",
			"wpn_fps_sho_geco_shell_1",
			"wpn_fps_sho_geco_shell_2",
			"wpn_fps_sho_geco_trigger_1",
			"wpn_fps_sho_geco_trigger_2",
			"wpn_fps_sho_geco_b_short",
			"wpn_fps_sho_geco_s_cheek_rest"
		}
	}
	self.wpn_fps_sho_geco_npc = deep_clone(self.wpn_fps_sho_geco)
	self.wpn_fps_sho_geco_npc.unit = "units/upd_001/weapons/wpn_fps_sho_geco/wpn_fps_sho_geco_npc"
end

function WeaponFactoryTweakData:_init_dp28()
	self.parts.wpn_fps_lmg_dp28_b_standard = {
		name_id = "bm_wp_lmg_dp28_b_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_b_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_b_coned = {
		name_id = "bm_wp_lmg_dp28_b_coned",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_b_coned",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_b_coned",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_bipod = {
		parent = "barrel",
		name_id = "bm_wp_lmg_dp28_bipod",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_bipod",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_bipod",
		a_obj = "a_bp",
		type = "bipod",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_body_standard = {
		name_id = "bm_wp_lmg_dp28_body_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_body_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_body_standard",
		a_obj = "a_body",
		type = "receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_dh_standard = {
		name_id = "bm_wp_lmg_dp28_dh_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_dh_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_g_standard = {
		name_id = "bm_wp_lmg_dp28_g_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_g_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_g_standard",
		a_obj = "a_body",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_m_strap = {
		parent = "magazine",
		name_id = "bm_wp_lmg_dp28_m_strap",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_m_strap",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_m_strap",
		a_obj = "a_strap",
		type = "strap",
		stats = {
			value = 1
		},
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil"
		}
	}
	self.parts.wpn_fps_lmg_dp28_m_casing = {
		name_id = "bm_wp_lmg_dp28_m_casing",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_m_casing",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_m_casing",
		a_obj = "a_m",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_m_standard = {
		name_id = "bm_wp_lmg_dp28_m_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_m_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		},
		animations = {
			fire = "recoil"
		}
	}
	self.parts.wpn_fps_lmg_dp28_m_casing_ext = {
		name_id = "bm_wp_lmg_dp28_m_casing_ext",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_m_casing_ext",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_m_casing_ext",
		a_obj = "a_m",
		type = "magazine_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_m_extended = {
		name_id = "bm_wp_lmg_dp28_m_extended",
		fps_animation_weight = "dp28_t2_recoil",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_m_extended",
		a_obj = "a_m",
		type = "magazine",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_m_extended",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_lmg_dp28_m_strap"
		},
		animations = {
			fire = "recoil"
		}
	}
	self.parts.wpn_fps_lmg_dp28_o_standard = {
		name_id = "bm_wp_lmg_dp28_o_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_o_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_o_standard",
		a_obj = "a_o",
		type = "sight",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_o_extended = {
		name_id = "bm_wp_lmg_dp28_o_extended",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_o_extended",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_o_extended",
		a_obj = "a_o",
		type = "sight",
		stance_mod = {
			wpn_fps_lmg_dp28 = {
				translation = Vector3(0, 0, -4.5991)
			}
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_s_standard = {
		name_id = "bm_wp_lmg_dp28_s_standard",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_s_standard",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_s_standard",
		a_obj = "a_body",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_s_light = {
		name_id = "bm_wp_lmg_dp28_s_light",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_s_light",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_s_light",
		a_obj = "a_body",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_dp28_trigger = {
		name_id = "bm_wp_lmg_dp28_trigger",
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28_pts/wpn_fps_lmg_dp28_trigger",
		third_unit = "units/upd_001/weapons/wpn_third_lmg_dp28_pts/wpn_third_lmg_dp28_trigger",
		a_obj = "a_trigger",
		type = "trigger",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_lmg_dp28 = {
		unit = "units/upd_001/weapons/wpn_fps_lmg_dp28/wpn_fps_lmg_dp28",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_lmg_dp28_b_standard",
			"wpn_fps_lmg_dp28_body_standard",
			"wpn_fps_lmg_dp28_dh_standard",
			"wpn_fps_lmg_dp28_m_strap",
			"wpn_fps_lmg_dp28_m_casing",
			"wpn_fps_lmg_dp28_m_standard",
			"wpn_fps_lmg_dp28_o_standard",
			"wpn_fps_lmg_dp28_s_standard",
			"wpn_fps_lmg_dp28_trigger"
		},
		uses_parts = {
			"wpn_fps_lmg_dp28_b_standard",
			"wpn_fps_lmg_dp28_body_standard",
			"wpn_fps_lmg_dp28_dh_standard",
			"wpn_fps_lmg_dp28_m_strap",
			"wpn_fps_lmg_dp28_m_casing",
			"wpn_fps_lmg_dp28_m_standard",
			"wpn_fps_lmg_dp28_o_standard",
			"wpn_fps_lmg_dp28_s_standard",
			"wpn_fps_lmg_dp28_trigger",
			"wpn_fps_lmg_dp28_b_coned",
			"wpn_fps_lmg_dp28_bipod",
			"wpn_fps_lmg_dp28_g_standard",
			"wpn_fps_lmg_dp28_m_casing_ext",
			"wpn_fps_lmg_dp28_m_extended",
			"wpn_fps_lmg_dp28_o_extended",
			"wpn_fps_lmg_dp28_s_light"
		}
	}
	self.wpn_fps_lmg_dp28_npc = deep_clone(self.wpn_fps_lmg_dp28)
	self.wpn_fps_lmg_dp28_npc.unit = "units/upd_001/weapons/wpn_fps_lmg_dp28/wpn_fps_lmg_dp28_npc"
end

function WeaponFactoryTweakData:_init_bren()
	self.parts.wpn_fps_lmg_bren_b_standard = {
		name_id = "bm_wp_lmg_bren_b_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_b_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_b_long = {
		name_id = "bm_wp_lmg_bren_b_long",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_b_long",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_ns_brake = {
		parent = "barrel",
		name_id = "bm_wp_lmg_bren_ns_brake",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_ns_brake",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_ns_brake",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_bipod = {
		parent = "barrel",
		name_id = "bm_wp_lmg_bren_bipod",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_bipod",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_bipod",
		a_obj = "a_bp",
		type = "bipod",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_support = {
		name_id = "bm_wp_lmg_bren_support",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_support",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_support",
		a_obj = "a_support",
		type = "support",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_body_standard = {
		name_id = "bm_wp_lmg_bren_body_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_body_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_body_standard",
		a_obj = "a_body",
		type = "receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_dh_standard = {
		name_id = "bm_wp_lmg_bren_dh_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_dh_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_m_standard = {
		name_id = "bm_wp_lmg_bren_m_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_m_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_m_extended = {
		name_id = "bm_wp_lmg_bren_m_extended",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_m_extended",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_m_extended",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_s_standard = {
		name_id = "bm_wp_lmg_bren_s_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_s_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_pad_standard = {
		name_id = "bm_wp_lmg_bren_pad_standard",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_pad_standard",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_pad_standard",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_bren_pad_buffered = {
		name_id = "bm_wp_lmg_bren_pad_buffered",
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_pad_buffered",
		third_unit = "units/upd_005/weapons/wpn_third_lmg_bren_pts/wpn_third_lmg_bren_pad_buffered",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_lmg_bren = {
		unit = "units/upd_005/weapons/wpn_fps_lmg_bren/wpn_fps_lmg_bren",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_lmg_bren_b_standard",
			"wpn_fps_lmg_bren_body_standard",
			"wpn_fps_lmg_bren_dh_standard",
			"wpn_fps_lmg_bren_m_standard",
			"wpn_fps_lmg_bren_s_standard",
			"wpn_fps_lmg_bren_pad_standard"
		},
		uses_parts = {
			"wpn_fps_lmg_bren_b_standard",
			"wpn_fps_lmg_bren_body_standard",
			"wpn_fps_lmg_bren_dh_standard",
			"wpn_fps_lmg_bren_m_standard",
			"wpn_fps_lmg_bren_s_standard",
			"wpn_fps_lmg_bren_pad_standard",
			"wpn_fps_lmg_bren_b_long",
			"wpn_fps_lmg_bren_ns_brake",
			"wpn_fps_lmg_bren_bipod",
			"wpn_fps_lmg_bren_support",
			"wpn_fps_lmg_bren_m_extended",
			"wpn_fps_lmg_bren_pad_buffered"
		}
	}
	self.wpn_fps_lmg_bren_npc = deep_clone(self.wpn_fps_lmg_bren)
	self.wpn_fps_lmg_bren_npc.unit = "units/upd_005/weapons/wpn_fps_lmg_bren/wpn_fps_lmg_bren_npc"
end

function WeaponFactoryTweakData:_init_tt33()
	self.parts.wpn_fps_pis_tt33_body_standard = {
		name_id = "bm_wp_pis_tt33_body_standard",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_body_standard",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_b_standard = {
		name_id = "bm_wp_pis_tt33_b_standard",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_b_standard",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_sl_standard = {
		name_id = "bm_wp_pis_tt33_sl_standard",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_sl_standard",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_sl_standard",
		a_obj = "a_sl",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_hammer = {
		name_id = "bm_wp_pis_tt33_hammer",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_hammer",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_hammer",
		a_obj = "a_hammer",
		type = "hammer",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_trigger = {
		name_id = "bm_wp_pis_tt33_trigger",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_trigger",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_trigger",
		a_obj = "a_trigger",
		type = "trigger",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_release = {
		name_id = "bm_wp_pis_tt33_release",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_release",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_release",
		a_obj = "a_release",
		type = "release",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_g_standard = {
		name_id = "bm_wp_pis_tt33_g_standard",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_g_standard",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_g_standard",
		a_obj = "a_g",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_g_wooden = {
		name_id = "bm_wp_pis_tt33_g_wooden",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_g_wooden",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_g_wooden",
		a_obj = "a_g",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_m_standard = {
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_m_standard",
		name_id = "bm_wp_pis_tt33_m_standard",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 8,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_m_extended = {
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_m_extended",
		name_id = "bm_wp_pis_tt33_m_extended",
		fps_animation_weight = "tt33_t1_mag",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_m_extended",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 9,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_m_long = {
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_m_long",
		name_id = "bm_wp_pis_tt33_m_long",
		fps_animation_weight = "tt33_t2_mag",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_m_long",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 13,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_tt33_ns_brake = {
		parent = "custom",
		name_id = "bm_wp_pis_tt33_ns_brake",
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33_pts/wpn_fps_pis_tt33_ns_brake",
		third_unit = "units/upd_001/weapons/wpn_third_pis_tt33_pts/wpn_third_pis_tt33_ns_brake",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_pis_tt33 = {
		unit = "units/upd_001/weapons/wpn_fps_pis_tt33/wpn_fps_pis_tt33",
		optional_types = {
			"barrel_ext",
			"gadget"
		},
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_pis_tt33_body_standard",
			"wpn_fps_pis_tt33_b_standard",
			"wpn_fps_pis_tt33_sl_standard",
			"wpn_fps_pis_tt33_m_standard",
			"wpn_fps_pis_tt33_hammer",
			"wpn_fps_pis_tt33_trigger",
			"wpn_fps_pis_tt33_release",
			"wpn_fps_pis_tt33_g_standard"
		},
		uses_parts = {
			"wpn_fps_pis_tt33_body_standard",
			"wpn_fps_pis_tt33_b_standard",
			"wpn_fps_pis_tt33_sl_standard",
			"wpn_fps_pis_tt33_m_standard",
			"wpn_fps_pis_tt33_hammer",
			"wpn_fps_pis_tt33_trigger",
			"wpn_fps_pis_tt33_release",
			"wpn_fps_pis_tt33_g_standard",
			"wpn_fps_pis_tt33_m_extended",
			"wpn_fps_pis_tt33_m_long",
			"wpn_fps_pis_tt33_ns_brake",
			"wpn_fps_pis_tt33_g_wooden"
		}
	}
	self.wpn_fps_pis_tt33_npc = deep_clone(self.wpn_fps_pis_tt33)
	self.wpn_fps_pis_tt33_npc.unit = "units/upd_001/weapons/wpn_fps_pis_tt33/wpn_fps_pis_tt33_npc"
end

function WeaponFactoryTweakData:_init_georg()
	local unique_materials = {
		"mat_body",
		"mat_body_addons"
	}
	self.parts.wpn_fps_pis_georg_body_default = {
		name_id = "bm_wp_pis_georg_dummy",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/body_default_fps",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/body_default_tps",
		a_obj = "a_body",
		type = "body",
		unique_materials = unique_materials,
		stats = {
			value = 1
		},
		animations = {
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		}
	}
	self.parts.wpn_fps_pis_georg_slide_default = {
		name_id = "bm_wp_pis_georg_dummy",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/slide_default_tps",
		a_obj = "a_slide",
		type = "slide",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/slide_default_fps",
		parent = "body",
		unique_materials = unique_materials,
		stats = {
			value = 1
		},
		animations = {
			magazine_empty = "last_recoil",
			fire = "recoil",
			fire_steelsight = "recoil",
			reload = "reload"
		}
	}
	self.parts.wpn_fps_pis_georg_barrel_short = {
		parent = "slide",
		name_id = "bm_wp_pis_georg_dummy",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/barrel_short_fps",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/barrel_short_tps",
		a_obj = "a_barrel",
		type = "barrel",
		stats = {
			value = 1
		},
		unique_materials = unique_materials
	}
	self.parts.wpn_fps_pis_georg_barrel_long = {
		name_id = "bm_wp_pis_georg_dummy",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/barrel_long_tps",
		a_obj = "a_barrel",
		type = "barrel",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/barrel_long_fps",
		parent = "slide",
		stats = {
			value = 1
		},
		unique_materials = unique_materials,
		stance_mod = {
			wpn_fps_pis_georg = {
				translation = Vector3(0, -3, -0.1),
				rotation = Rotation(0, 0.06, 0)
			}
		}
	}
	self.parts.wpn_fps_pis_georg_mag_default = {
		name_id = "bm_wp_pis_georg_dummy",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/mag_default_tps",
		a_obj = "a_mag",
		type = "magazine",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/mag_default_fps",
		parent = "body",
		stats = {
			value = 1
		},
		unique_materials = unique_materials,
		bullet_objects = {
			amount = 12,
			prefix = "g_bullet_"
		}
	}
	self.parts.wpn_fps_pis_georg_stock_wooden = {
		name_id = "bm_wp_pis_georg_dummy",
		third_unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/stock_wooden_tps",
		a_obj = "a_stock",
		type = "stock",
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/parts/stock_wooden_fps",
		parent = "body",
		stats = {
			value = 1
		},
		unique_materials = unique_materials,
		stance_mod = {
			wpn_fps_pis_georg = {
				translation = Vector3(0, 0, -0.15),
				rotation = Rotation(0, 0, -2)
			}
		}
	}
	self.wpn_fps_pis_georg = {
		unit = "units/upd_georg/weapons/wpn_fps_pis_georg/wpn_fps_pis_georg",
		optional_types = {
			"slide",
			"barrel",
			"stock"
		},
		animations = {},
		default_blueprint = {
			"wpn_fps_pis_georg_body_default",
			"wpn_fps_pis_georg_mag_default",
			"wpn_fps_pis_georg_slide_default",
			"wpn_fps_pis_georg_barrel_short"
		},
		uses_parts = {
			"wpn_fps_pis_georg_body_default",
			"wpn_fps_pis_georg_mag_default",
			"wpn_fps_pis_georg_slide_default",
			"wpn_fps_pis_georg_barrel_short",
			"wpn_fps_pis_georg_barrel_long",
			"wpn_fps_pis_georg_stock_wooden"
		}
	}
	self.wpn_fps_pis_georg_npc = clone(self.wpn_fps_pis_georg)
	self.wpn_fps_pis_georg_npc.unit = "units/upd_georg/weapons/wpn_fps_pis_georg/wpn_fps_pis_georg_npc"
end

function WeaponFactoryTweakData:_init_m1912()
	self.parts.wpn_fps_sho_m1912_b_standard = {
		name_id = "bm_wp_sho_m1912_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_b_long = {
		name_id = "bm_wp_sho_m1912_b_long",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_b_short = {
		name_id = "bm_wp_sho_m1912_b_short",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_b_short",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_b_heat_shield = {
		name_id = "bm_wp_sho_m1912_b_heat_shield",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_b_heat_shield",
		a_obj = "a_b",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_ns_cutts = {
		parent = "barrel",
		name_id = "bm_wp_sho_m1912_ns_cutts",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_ns_cutts",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_body_standard = {
		name_id = "bm_wp_sho_m1912_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_bolt_standard = {
		name_id = "bm_wp_sho_m1912_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_bolt_standard",
		a_obj = "a_bolt",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_fg_standard = {
		name_id = "bm_wp_sho_m1912_fg_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_fg_standard",
		a_obj = "a_fg",
		type = "foregrip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_fg_long = {
		name_id = "bm_wp_sho_m1912_fg_long",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_fg_long",
		a_obj = "a_fg",
		type = "foregrip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_m_standard = {
		name_id = "bm_wp_sho_m1912_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_s_standard = {
		name_id = "bm_wp_sho_m1912_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_s_cheek_rest = {
		name_id = "bm_wp_sho_m1912_s_cheek_rest",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_s_cheek_rest",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_s_pad = {
		parent = "stock",
		name_id = "bm_wp_sho_m1912_s_pad",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_s_pad",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_m1912_s_pistol_grip = {
		name_id = "bm_wp_sho_m1912_s_pistol_grip",
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912_pts/wpn_fps_sho_m1912_s_pistol_grip",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_sho_m1912_s_pad"
		}
	}
	self.parts.wpn_fps_sho_m1912_b_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_b_standard"
	self.parts.wpn_fps_sho_m1912_b_long.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_b_long"
	self.parts.wpn_fps_sho_m1912_b_short.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_b_short"
	self.parts.wpn_fps_sho_m1912_b_heat_shield.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_b_heat_shield"
	self.parts.wpn_fps_sho_m1912_ns_cutts.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_ns_cutts"
	self.parts.wpn_fps_sho_m1912_body_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_body_standard"
	self.parts.wpn_fps_sho_m1912_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_bolt_standard"
	self.parts.wpn_fps_sho_m1912_fg_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_fg_standard"
	self.parts.wpn_fps_sho_m1912_fg_long.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_fg_long"
	self.parts.wpn_fps_sho_m1912_m_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_m_standard"
	self.parts.wpn_fps_sho_m1912_s_standard.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_s_standard"
	self.parts.wpn_fps_sho_m1912_s_cheek_rest.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_s_cheek_rest"
	self.parts.wpn_fps_sho_m1912_s_pad.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_s_pad"
	self.parts.wpn_fps_sho_m1912_s_pistol_grip.third_unit = "units/vanilla/weapons/wpn_third_sho_m1912_pts/wpn_third_sho_m1912_s_pistol_grip"
	self.wpn_fps_sho_m1912 = {
		unit = "units/vanilla/weapons/wpn_fps_sho_m1912/wpn_fps_sho_m1912",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_exit = "reload_exit"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_sho_m1912_b_standard",
			"wpn_fps_sho_m1912_body_standard",
			"wpn_fps_sho_m1912_bolt_standard",
			"wpn_fps_sho_m1912_fg_standard",
			"wpn_fps_sho_m1912_m_standard",
			"wpn_fps_sho_m1912_s_standard"
		},
		uses_parts = {
			"wpn_fps_sho_m1912_b_standard",
			"wpn_fps_sho_m1912_body_standard",
			"wpn_fps_sho_m1912_bolt_standard",
			"wpn_fps_sho_m1912_fg_standard",
			"wpn_fps_sho_m1912_m_standard",
			"wpn_fps_sho_m1912_s_standard",
			"wpn_fps_sho_m1912_b_long",
			"wpn_fps_sho_m1912_b_short",
			"wpn_fps_sho_m1912_ns_cutts",
			"wpn_fps_sho_m1912_s_cheek_rest",
			"wpn_fps_sho_m1912_s_pad",
			"wpn_fps_sho_m1912_s_pistol_grip",
			"wpn_fps_sho_m1912_b_heat_shield",
			"wpn_fps_sho_m1912_fg_long"
		}
	}
	self.wpn_fps_sho_m1912_npc = deep_clone(self.wpn_fps_sho_m1912)
	self.wpn_fps_sho_m1912_npc.unit = "units/vanilla/weapons/wpn_fps_sho_m1912/wpn_fps_sho_m1912_npc"
end

function WeaponFactoryTweakData:_init_ithaca()
	self.parts.wpn_fps_sho_ithaca_m_standard = {
		name_id = "bm_wp_sho_ithaca_m_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_b_standard = {
		name_id = "bm_wp_sho_ithaca_b_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_b_reinforced = {
		name_id = "bm_wp_sho_ithaca_b_reinforced",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_b_reinforced",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_b_heat_shield = {
		name_id = "bm_wp_sho_ithaca_b_heat_shield",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_b_heat_shield",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_ns_brake = {
		parent = "barrel",
		name_id = "bm_wp_sho_ithaca_ns_brake",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_ns_brake",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_body_standard = {
		name_id = "bm_wp_sho_ithaca_body_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_lifter = {
		name_id = "bm_wp_sho_ithaca_lifter_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_lifter",
		a_obj = "a_lifter",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_trigger = {
		name_id = "bm_wp_sho_ithaca_trigger_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_trigger",
		a_obj = "a_trigger",
		type = "trigger",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_sl_standard = {
		name_id = "bm_wp_sho_ithaca_sl_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_sl_standard",
		a_obj = "a_sl",
		type = "foregrip",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_s_standard = {
		name_id = "bm_wp_sho_ithaca_s_standard",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_s_cheek_rest = {
		name_id = "bm_wp_sho_ithaca_s_cheek_rest",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_s_cheek_rest",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_s_pistol_grip = {
		name_id = "bm_wp_sho_ithaca_s_pistol_grip",
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca_pts/wpn_fps_sho_ithaca_s_pistol_grip",
		fps_animation_weight = "ithaca_t4_recoil",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_ithaca_m_standard.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_m_standard"
	self.parts.wpn_fps_sho_ithaca_b_standard.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_b_standard"
	self.parts.wpn_fps_sho_ithaca_b_reinforced.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_b_reinforced"
	self.parts.wpn_fps_sho_ithaca_b_heat_shield.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_b_heat_shield"
	self.parts.wpn_fps_sho_ithaca_ns_brake.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_ns_brake"
	self.parts.wpn_fps_sho_ithaca_body_standard.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_body_standard"
	self.parts.wpn_fps_sho_ithaca_lifter.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_lifter"
	self.parts.wpn_fps_sho_ithaca_trigger.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_trigger"
	self.parts.wpn_fps_sho_ithaca_sl_standard.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_sl_standard"
	self.parts.wpn_fps_sho_ithaca_s_standard.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_s_standard"
	self.parts.wpn_fps_sho_ithaca_s_cheek_rest.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_s_cheek_rest"
	self.parts.wpn_fps_sho_ithaca_s_pistol_grip.third_unit = "units/upd_017/weapons/wpn_third_sho_ithaca_pts/wpn_third_sho_ithaca_s_pistol_grip"
	self.wpn_fps_sho_ithaca = {
		unit = "units/upd_017/weapons/wpn_fps_sho_ithaca/wpn_fps_sho_ithaca",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_exit = "reload_exit"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_sho_ithaca_m_standard",
			"wpn_fps_sho_ithaca_b_standard",
			"wpn_fps_sho_ithaca_body_standard",
			"wpn_fps_sho_ithaca_lifter",
			"wpn_fps_sho_ithaca_trigger",
			"wpn_fps_sho_ithaca_sl_standard",
			"wpn_fps_sho_ithaca_s_standard"
		},
		uses_parts = {
			"wpn_fps_sho_ithaca_m_standard",
			"wpn_fps_sho_ithaca_b_standard",
			"wpn_fps_sho_ithaca_body_standard",
			"wpn_fps_sho_ithaca_lifter",
			"wpn_fps_sho_ithaca_trigger",
			"wpn_fps_sho_ithaca_sl_standard",
			"wpn_fps_sho_ithaca_s_standard",
			"wpn_fps_sho_ithaca_b_reinforced",
			"wpn_fps_sho_ithaca_b_heat_shield",
			"wpn_fps_sho_ithaca_ns_brake",
			"wpn_fps_sho_ithaca_s_cheek_rest",
			"wpn_fps_sho_ithaca_s_pistol_grip"
		}
	}
	self.wpn_fps_sho_ithaca_npc = deep_clone(self.wpn_fps_sho_ithaca)
	self.wpn_fps_sho_ithaca_npc.unit = "units/upd_017/weapons/wpn_fps_sho_ithaca/wpn_fps_sho_ithaca_npc"
end

function WeaponFactoryTweakData:_init_browning()
	self.parts.wpn_fps_sho_browning_m_standard = {
		name_id = "bm_wp_sho_browning_m_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_m_standard",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_m_extended = {
		name_id = "bm_wp_sho_browning_m_extended",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_m_extended",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_m_extended",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_m_long = {
		name_id = "bm_wp_sho_browning_m_long",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_m_long",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_m_long",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_b_standard = {
		name_id = "bm_wp_sho_browning_b_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_b_standard",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_b_reinforced = {
		name_id = "bm_wp_sho_browning_b_reinforced",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_b_reinforced",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_b_reinforced",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_body_standard = {
		name_id = "bm_wp_sho_browning_body_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_body_standard",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_dh_standard = {
		name_id = "bm_wp_sho_browning_dh_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_dh_standard",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_lifter = {
		name_id = "bm_wp_sho_browning_lifter_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_lifter",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_lifter",
		a_obj = "a_lifter",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_s_standard = {
		name_id = "bm_wp_sho_browning_s_standard",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_s_standard",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_s_grip = {
		name_id = "bm_wp_sho_browning_s_grip",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_s_grip",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_s_grip",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_pad_big = {
		name_id = "bm_wp_sho_browning_pad_big",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_pad_big",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_pad_big",
		a_obj = "a_pad",
		type = "stock_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_sho_browning_slug = {
		name_id = "bm_wp_sho_browning_slug",
		unit = "units/upd_007/weapons/wpn_fps_sho_browning_pts/wpn_fps_sho_browning_slug",
		third_unit = "units/upd_007/weapons/wpn_third_sho_browning_pts/wpn_third_sho_browning_slug",
		a_obj = "a_slug",
		type = "extra",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_sho_browning = {
		unit = "units/upd_007/weapons/wpn_fps_sho_browning/wpn_fps_sho_browning",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_exit = "reload_exit"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_sho_browning_m_standard",
			"wpn_fps_sho_browning_b_standard",
			"wpn_fps_sho_browning_body_standard",
			"wpn_fps_sho_browning_dh_standard",
			"wpn_fps_sho_browning_lifter",
			"wpn_fps_sho_browning_s_standard",
			"wpn_fps_sho_browning_slug"
		},
		uses_parts = {
			"wpn_fps_sho_browning_m_standard",
			"wpn_fps_sho_browning_b_standard",
			"wpn_fps_sho_browning_body_standard",
			"wpn_fps_sho_browning_dh_standard",
			"wpn_fps_sho_browning_lifter",
			"wpn_fps_sho_browning_s_standard",
			"wpn_fps_sho_browning_slug",
			"wpn_fps_sho_browning_m_extended",
			"wpn_fps_sho_browning_m_long",
			"wpn_fps_sho_browning_b_reinforced",
			"wpn_fps_sho_browning_s_grip",
			"wpn_fps_sho_browning_pad_big"
		}
	}
	self.wpn_fps_sho_browning_npc = deep_clone(self.wpn_fps_sho_browning)
	self.wpn_fps_sho_browning_npc.unit = "units/upd_007/weapons/wpn_fps_sho_browning/wpn_fps_sho_browning_npc"
end

function WeaponFactoryTweakData:_init_mp38()
	self.parts.wpn_fps_smg_mp38_b_standard = {
		name_id = "bm_wp_smg_mp38_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_b_compensated = {
		name_id = "bm_wp_smg_mp38_b_compensated",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_b_compensated",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_b_fluted = {
		name_id = "bm_wp_smg_mp38_b_fluted",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_b_fluted",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_body_standard = {
		name_id = "bm_wp_smg_mp38_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_dh_standard = {
		name_id = "bm_wp_smg_mp38_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_dh_curved = {
		name_id = "bm_wp_smg_mp38_dh_curved",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_dh_curved",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_m_standard",
		name_id = "bm_wp_smg_mp38_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_m_standard_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_m_standard_double",
		name_id = "bm_wp_smg_mp38_m_standard_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_s_standard = {
		name_id = "bm_wp_smg_mp38_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_s_wooden = {
		name_id = "bm_wp_smg_mp38_s_wooden",
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38_pts/wpn_fps_smg_mp38_s_wooden",
		fps_animation_weight = "mp38_t2_recoil",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_mp38_b_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_b_standard"
	self.parts.wpn_fps_smg_mp38_b_compensated.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_b_compensated"
	self.parts.wpn_fps_smg_mp38_b_fluted.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_b_fluted"
	self.parts.wpn_fps_smg_mp38_body_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_body_standard"
	self.parts.wpn_fps_smg_mp38_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_dh_standard"
	self.parts.wpn_fps_smg_mp38_dh_curved.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_dh_curved"
	self.parts.wpn_fps_smg_mp38_m_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_m_standard"
	self.parts.wpn_fps_smg_mp38_m_standard_double.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_m_standard_double"
	self.parts.wpn_fps_smg_mp38_s_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_s_standard"
	self.parts.wpn_fps_smg_mp38_s_wooden.third_unit = "units/vanilla/weapons/wpn_third_smg_mp38_pts/wpn_third_smg_mp38_s_wooden"
	self.wpn_fps_smg_mp38 = {
		unit = "units/vanilla/weapons/wpn_fps_smg_mp38/wpn_fps_smg_mp38",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_smg_mp38_b_standard",
			"wpn_fps_smg_mp38_body_standard",
			"wpn_fps_smg_mp38_dh_standard",
			"wpn_fps_smg_mp38_m_standard",
			"wpn_fps_smg_mp38_s_standard"
		},
		uses_parts = {
			"wpn_fps_smg_mp38_b_standard",
			"wpn_fps_smg_mp38_body_standard",
			"wpn_fps_smg_mp38_dh_standard",
			"wpn_fps_smg_mp38_m_standard",
			"wpn_fps_smg_mp38_s_standard",
			"wpn_fps_smg_mp38_m_standard_double",
			"wpn_fps_smg_mp38_dh_curved",
			"wpn_fps_smg_mp38_b_compensated",
			"wpn_fps_smg_mp38_b_fluted",
			"wpn_fps_smg_mp38_s_wooden"
		}
	}
	self.wpn_fps_smg_mp38_npc = deep_clone(self.wpn_fps_smg_mp38)
	self.wpn_fps_smg_mp38_npc.unit = "units/vanilla/weapons/wpn_fps_smg_mp38/wpn_fps_smg_mp38_npc"
end

function WeaponFactoryTweakData:_init_mp44()
	self.parts.wpn_fps_ass_mp44_b_standard = {
		name_id = "bm_wp_ass_mp44_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_body_standard = {
		name_id = "bm_wp_ass_mp44_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_body_standard",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_dh_standard = {
		name_id = "bm_wp_ass_mp44_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_dh_standard",
		a_obj = "a_dh",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_m_short = {
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_m_short",
		name_id = "bm_wp_ass_mp44_m_short",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_m_short_double = {
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_m_short_double",
		name_id = "bm_wp_ass_mp44_m_short_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_m_standard",
		name_id = "bm_wp_ass_mp44_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_m_standard_double = {
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_m_standard_double",
		name_id = "bm_wp_ass_mp44_m_standard_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_fg_standard = {
		name_id = "bm_wp_ass_mp44_fg_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_fg_standard",
		a_obj = "a_fg",
		type = "foregrip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_s_standard = {
		name_id = "bm_wp_ass_mp44_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_mp44_o_scope = {
		parent = "body",
		name_id = "bm_wp_ass_mp44_o_scope",
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44_pts/wpn_fps_ass_mp44_o_scope",
		a_obj = "a_o",
		type = "scope",
		stats = {
			zoom = 4,
			value = 1
		},
		stance_mod = {
			wpn_fps_ass_mp44 = {
				lens_distortion_power = 1.01,
				translation = Vector3(0, -10, -1.64784)
			}
		}
	}
	self.parts.wpn_fps_ass_mp44_b_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_b_standard"
	self.parts.wpn_fps_ass_mp44_body_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_body_standard"
	self.parts.wpn_fps_ass_mp44_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_dh_standard"
	self.parts.wpn_fps_ass_mp44_m_short.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_m_short"
	self.parts.wpn_fps_ass_mp44_m_short_double.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_m_short_double"
	self.parts.wpn_fps_ass_mp44_m_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_m_standard"
	self.parts.wpn_fps_ass_mp44_m_standard_double.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_m_standard_double"
	self.parts.wpn_fps_ass_mp44_fg_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_fg_standard"
	self.parts.wpn_fps_ass_mp44_s_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_s_standard"
	self.parts.wpn_fps_ass_mp44_o_scope.third_unit = "units/vanilla/weapons/wpn_third_ass_mp44_pts/wpn_third_ass_mp44_o_scope"
	self.wpn_fps_ass_mp44 = {
		unit = "units/vanilla/weapons/wpn_fps_ass_mp44/wpn_fps_ass_mp44",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_ass_mp44_b_standard",
			"wpn_fps_ass_mp44_body_standard",
			"wpn_fps_ass_mp44_dh_standard",
			"wpn_fps_ass_mp44_m_short",
			"wpn_fps_ass_mp44_fg_standard",
			"wpn_fps_ass_mp44_s_standard"
		},
		uses_parts = {
			"wpn_fps_ass_mp44_b_standard",
			"wpn_fps_ass_mp44_body_standard",
			"wpn_fps_ass_mp44_dh_standard",
			"wpn_fps_ass_mp44_m_short",
			"wpn_fps_ass_mp44_fg_standard",
			"wpn_fps_ass_mp44_s_standard",
			"wpn_fps_ass_mp44_m_short_double",
			"wpn_fps_ass_mp44_m_standard",
			"wpn_fps_ass_mp44_m_standard_double",
			"wpn_fps_ass_mp44_o_scope"
		}
	}
	self.wpn_fps_ass_mp44_npc = deep_clone(self.wpn_fps_ass_mp44)
	self.wpn_fps_ass_mp44_npc.unit = "units/vanilla/weapons/wpn_fps_ass_mp44/wpn_fps_ass_mp44_npc"
end

function WeaponFactoryTweakData:_init_carbine()
	self.parts.wpn_fps_ass_carbine_b_short = {
		name_id = "bm_wp_ass_carbine_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_b_short",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_b_medium = {
		name_id = "bm_wp_ass_carbine_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_b_medium",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_b_standard = {
		name_id = "bm_wp_ass_carbine_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_body_standard = {
		name_id = "bm_wp_ass_carbine_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_body_wooden = {
		name_id = "bm_wp_ass_carbine_body_wooden",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_body_wooden",
		fps_animation_weight = "carbine_t2_recoil",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		},
		forbids = {
			"wpn_fps_ass_carbine_s_standard",
			"wpn_fps_ass_carbine_g_standard"
		}
	}
	self.parts.wpn_fps_ass_carbine_dh_standard = {
		name_id = "bm_wp_ass_carbine_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_dh_standard",
		a_obj = "a_dh",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_bolt_standard = {
		name_id = "bm_wp_ass_carbine_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_bolt_standard",
		a_obj = "a_bolt",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_m_standard = {
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_m_standard",
		name_id = "bm_wp_ass_carbine_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_m_extended = {
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_m_extended",
		name_id = "bm_wp_ass_carbine_m_extended",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_g_standard = {
		name_id = "bm_wp_ass_carbine_g_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_g_standard",
		a_obj = "a_g",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_s_standard = {
		name_id = "bm_wp_ass_carbine_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine_pts/wpn_fps_ass_carbine_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_ass_carbine_b_short.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_b_short"
	self.parts.wpn_fps_ass_carbine_b_medium.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_b_medium"
	self.parts.wpn_fps_ass_carbine_b_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_b_standard"
	self.parts.wpn_fps_ass_carbine_body_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_body_standard"
	self.parts.wpn_fps_ass_carbine_body_wooden.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_body_wooden"
	self.parts.wpn_fps_ass_carbine_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_dh_standard"
	self.parts.wpn_fps_ass_carbine_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_bolt_standard"
	self.parts.wpn_fps_ass_carbine_m_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_m_standard"
	self.parts.wpn_fps_ass_carbine_m_extended.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_m_extended"
	self.parts.wpn_fps_ass_carbine_g_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_g_standard"
	self.parts.wpn_fps_ass_carbine_s_standard.third_unit = "units/vanilla/weapons/wpn_third_ass_carbine_pts/wpn_third_ass_carbine_s_standard"
	self.wpn_fps_ass_carbine = {
		unit = "units/vanilla/weapons/wpn_fps_ass_carbine/wpn_fps_ass_carbine",
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"barrel",
			"lower_receiver"
		},
		default_blueprint = {
			"wpn_fps_ass_carbine_b_short",
			"wpn_fps_ass_carbine_body_standard",
			"wpn_fps_ass_carbine_dh_standard",
			"wpn_fps_ass_carbine_bolt_standard",
			"wpn_fps_ass_carbine_m_standard",
			"wpn_fps_ass_carbine_g_standard",
			"wpn_fps_ass_carbine_s_standard"
		},
		uses_parts = {
			"wpn_fps_ass_carbine_b_short",
			"wpn_fps_ass_carbine_b_medium",
			"wpn_fps_ass_carbine_b_standard",
			"wpn_fps_ass_carbine_body_standard",
			"wpn_fps_ass_carbine_dh_standard",
			"wpn_fps_ass_carbine_bolt_standard",
			"wpn_fps_ass_carbine_m_standard",
			"wpn_fps_ass_carbine_g_standard",
			"wpn_fps_ass_carbine_s_standard",
			"wpn_fps_ass_carbine_body_wooden",
			"wpn_fps_ass_carbine_m_extended"
		}
	}
	self.wpn_fps_ass_carbine_npc = deep_clone(self.wpn_fps_ass_carbine)
	self.wpn_fps_ass_carbine_npc.unit = "units/vanilla/weapons/wpn_fps_ass_carbine/wpn_fps_ass_carbine_npc"
end

function WeaponFactoryTweakData:_init_mg42()
	self.parts.wpn_fps_lmg_mg42_b_mg42 = {
		name_id = "bm_wp_mg42_b_mg42",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_b_mg42",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_n42 = {
		parent = "barrel",
		name_id = "bm_wp_mg42_n42",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_n42",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_b_mg34 = {
		name_id = "bm_wp_mg42_b_mg34",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_b_mg34",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_n34 = {
		parent = "barrel",
		name_id = "bm_wp_mg42_n34",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_n42",
		a_obj = "a_ns",
		type = "barrel_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_receiver = {
		name_id = "bm_wp_mg42_receiver",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_receiver",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_lid_standard = {
		name_id = "bm_wp_mg42_lid_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_lid_standard",
		a_obj = "a_lid",
		type = "upper_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_lid_mg34 = {
		name_id = "bm_wp_mg42_lid_mg34",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_lid_mg34",
		a_obj = "a_body",
		type = "upper_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_dh_standard = {
		name_id = "bm_wp_mg42_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_dh_extra = {
		name_id = "bm_wp_mg42_dh_extra",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_dh_extra",
		a_obj = "a_dh_extra",
		type = "dh_ext",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_bipod = {
		parent = "barrel",
		name_id = "bm_wp_mg42_bipod",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_bipod",
		a_obj = "a_bp",
		type = "bipod",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_dh_mg34 = {
		name_id = "bm_wp_mg42_dh_mg34",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_dh_mg34",
		a_obj = "a_body",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_m_standard = {
		name_id = "bm_wp_mg42_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_handle = {
		name_id = "bm_wp_mg42_handle",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_handle",
		a_obj = "a_handle",
		type = "custom",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_band_1 = {
		name_id = "bm_wp_mg42_band_1",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_band_1",
		a_obj = "a_band_1",
		type = "band_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_band_2 = {
		name_id = "bm_wp_mg42_band_2",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_band_2",
		a_obj = "a_band_2",
		type = "band_2",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_band_3 = {
		name_id = "bm_wp_mg42_band_3",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_band_3",
		a_obj = "a_band_3",
		type = "band_3",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_lmg_mg42_m_double = {
		name_id = "bm_wp_mg42_m_double",
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_m_double",
		a_obj = "a_body",
		fps_animation_weight = "mg42_t3_mag",
		type = "magazine",
		stats = {
			value = 1
		},
		animations = {
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		hud_class_override = {
			drums = 2
		}
	}
	self.parts.wpn_fps_lmg_mg42_b_mg42.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_b_mg42"
	self.parts.wpn_fps_lmg_mg42_n42.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_n42"
	self.parts.wpn_fps_lmg_mg42_b_mg34.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_b_mg34"
	self.parts.wpn_fps_lmg_mg42_n34.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_n34"
	self.parts.wpn_fps_lmg_mg42_receiver.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_receiver"
	self.parts.wpn_fps_lmg_mg42_lid_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_lid_standard"
	self.parts.wpn_fps_lmg_mg42_lid_mg34.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_lid_mg34"
	self.parts.wpn_fps_lmg_mg42_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_dh_standard"
	self.parts.wpn_fps_lmg_mg42_dh_extra.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_dh_extra"
	self.parts.wpn_fps_lmg_mg42_bipod.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_bipod"
	self.parts.wpn_fps_lmg_mg42_dh_mg34.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_dh_mg34"
	self.parts.wpn_fps_lmg_mg42_m_standard.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_m_standard"
	self.parts.wpn_fps_lmg_mg42_handle.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_handle"
	self.parts.wpn_fps_lmg_mg42_band_1.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_band_1"
	self.parts.wpn_fps_lmg_mg42_band_2.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_band_2"
	self.parts.wpn_fps_lmg_mg42_band_3.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_band_3"
	self.parts.wpn_fps_lmg_mg42_m_double.third_unit = "units/vanilla/weapons/wpn_third_lmg_mg42_pts/wpn_third_lmg_mg42_m_double"
	self.wpn_fps_lmg_mg42 = {
		unit = "units/vanilla/weapons/wpn_fps_lmg_mg42/wpn_fps_lmg_mg42",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"vertical_grip"
		},
		default_blueprint = {
			"wpn_fps_lmg_mg42_b_mg42",
			"wpn_fps_lmg_mg42_n42",
			"wpn_fps_lmg_mg42_receiver",
			"wpn_fps_lmg_mg42_lid_standard",
			"wpn_fps_lmg_mg42_dh_standard",
			"wpn_fps_lmg_mg42_dh_extra",
			"wpn_fps_lmg_mg42_m_standard",
			"wpn_fps_lmg_mg42_handle",
			"wpn_fps_lmg_mg42_band_1",
			"wpn_fps_lmg_mg42_band_2",
			"wpn_fps_lmg_mg42_band_3"
		},
		uses_parts = {
			"wpn_fps_lmg_mg42_b_mg42",
			"wpn_fps_lmg_mg42_n42",
			"wpn_fps_lmg_mg42_receiver",
			"wpn_fps_lmg_mg42_lid_standard",
			"wpn_fps_lmg_mg42_dh_standard",
			"wpn_fps_lmg_mg42_dh_extra",
			"wpn_fps_lmg_mg42_m_standard",
			"wpn_fps_lmg_mg42_handle",
			"wpn_fps_lmg_mg42_band_1",
			"wpn_fps_lmg_mg42_band_2",
			"wpn_fps_lmg_mg42_band_3",
			"wpn_fps_lmg_mg42_b_mg34",
			"wpn_fps_lmg_mg42_n34",
			"wpn_fps_lmg_mg42_bipod",
			"wpn_fps_lmg_mg42_dh_mg34",
			"wpn_fps_lmg_mg42_m_double",
			"wpn_fps_lmg_mg42_lid_mg34"
		}
	}
	self.wpn_fps_lmg_mg42_npc = deep_clone(self.wpn_fps_lmg_mg42)
	self.wpn_fps_lmg_mg42_npc.unit = "units/vanilla/weapons/wpn_fps_lmg_mg42/wpn_fps_lmg_mg42_npc"
end

function WeaponFactoryTweakData:_init_c96()
	self.parts.wpn_fps_pis_c96_b_long = {
		name_id = "bm_wp_c96_b_long",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_b_long",
		a_obj = "a_b",
		type = "slide",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_b_long_finned = {
		name_id = "bm_wp_c96_b_long_finned",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_b_long_finned",
		a_obj = "a_b",
		type = "slide",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_b_standard = {
		name_id = "bm_wp_c96_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_b_standard",
		a_obj = "a_b",
		type = "slide",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_body_standard = {
		name_id = "bm_wp_c96_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_g_standard = {
		name_id = "bm_wp_c96_g_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_g_standard",
		a_obj = "a_g",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_m_long = {
		name_id = "bm_wp_c96_m_long",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_m_long",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_m_extended = {
		name_id = "bm_wp_c96_m_extended",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_m_extended",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_m_standard = {
		name_id = "bm_wp_c96_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_s_wooden = {
		name_id = "bm_wp_c96_s_wooden",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_s_wooden",
		a_obj = "a_s",
		type = "grip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_bullets_standard = {
		name_id = "bm_wp_c96_bullets_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_bullets_standard",
		a_obj = "a_bullets",
		type = "bullets",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_strip_standard = {
		name_id = "bm_wp_c96_strip_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_strip_standard",
		a_obj = "a_strip",
		type = "strip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_bolt_standard = {
		name_id = "bm_wp_c96_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_bolt_standard",
		a_obj = "a_bolt",
		type = "bolt",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_hammer_standard = {
		name_id = "bm_wp_c96_hammer_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_c96_pts/wpn_fps_pis_c96_hammer_standard",
		a_obj = "a_hammer",
		type = "hammer",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_c96_b_long.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_b_long"
	self.parts.wpn_fps_pis_c96_b_long_finned.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_b_long_finned"
	self.parts.wpn_fps_pis_c96_b_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_b_standard"
	self.parts.wpn_fps_pis_c96_body_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_body_standard"
	self.parts.wpn_fps_pis_c96_g_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_g_standard"
	self.parts.wpn_fps_pis_c96_m_long.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_m_long"
	self.parts.wpn_fps_pis_c96_m_extended.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_m_extended"
	self.parts.wpn_fps_pis_c96_m_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_m_standard"
	self.parts.wpn_fps_pis_c96_s_wooden.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_s_wooden"
	self.parts.wpn_fps_pis_c96_bullets_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_bullets_standard"
	self.parts.wpn_fps_pis_c96_strip_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_strip_standard"
	self.parts.wpn_fps_pis_c96_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_bolt_standard"
	self.parts.wpn_fps_pis_c96_hammer_standard.third_unit = "units/vanilla/weapons/wpn_third_pis_c96_pts/wpn_third_pis_c96_hammer_standard"
	self.wpn_fps_pis_c96 = {
		unit = "units/vanilla/weapons/wpn_fps_pis_c96/wpn_fps_pis_c96",
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"sight"
		},
		default_blueprint = {
			"wpn_fps_pis_c96_b_standard",
			"wpn_fps_pis_c96_body_standard",
			"wpn_fps_pis_c96_g_standard",
			"wpn_fps_pis_c96_m_standard",
			"wpn_fps_pis_c96_bullets_standard",
			"wpn_fps_pis_c96_strip_standard",
			"wpn_fps_pis_c96_bolt_standard",
			"wpn_fps_pis_c96_hammer_standard"
		},
		uses_parts = {
			"wpn_fps_pis_c96_b_standard",
			"wpn_fps_pis_c96_body_standard",
			"wpn_fps_pis_c96_g_standard",
			"wpn_fps_pis_c96_m_standard",
			"wpn_fps_pis_c96_bullets_standard",
			"wpn_fps_pis_c96_strip_standard",
			"wpn_fps_pis_c96_bolt_standard",
			"wpn_fps_pis_c96_hammer_standard",
			"wpn_fps_pis_c96_b_long",
			"wpn_fps_pis_c96_b_long_finned",
			"wpn_fps_pis_c96_m_long",
			"wpn_fps_pis_c96_m_extended",
			"wpn_fps_pis_c96_s_wooden"
		}
	}
	self.wpn_fps_pis_c96_npc = deep_clone(self.wpn_fps_pis_c96)
	self.wpn_fps_pis_c96_npc.unit = "units/vanilla/weapons/wpn_fps_pis_c96/wpn_fps_pis_c96_npc"
end

function WeaponFactoryTweakData:_init_webley()
	self.parts.wpn_fps_pis_webley_body_standard = {
		name_id = "bm_wp_webley_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_body_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_body_standard",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_lock_standard = {
		name_id = "bm_wp_webley_lock_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_lock_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_lock_standard",
		a_obj = "a_lock",
		type = "lock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_hammer_standard = {
		name_id = "bm_wp_webley_hammer_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_hammer_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_hammer_standard",
		a_obj = "a_hammer",
		type = "hammer",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_trigger_standard = {
		name_id = "bm_wp_webley_trigger_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_trigger_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_trigger_standard",
		a_obj = "a_trigger",
		type = "trigger",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_b_standard = {
		name_id = "bm_wp_webley_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_b_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_m_standard = {
		name_id = "bm_wp_webley_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_m_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_m_standard",
		a_obj = "a_m",
		type = "drum",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_ejector_standard = {
		name_id = "bm_wp_webley_ejector_standard",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_ejector_standard",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_ejector_standard",
		a_obj = "a_ejector",
		type = "ejector",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_1 = {
		name_id = "bm_wp_webley_casing_1",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_1",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_1",
		a_obj = "a_casing_1",
		type = "extra_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_2 = {
		name_id = "bm_wp_webley_casing_2",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_2",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_2",
		a_obj = "a_casing_2",
		type = "extra_2",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_3 = {
		name_id = "bm_wp_webley_casing_3",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_3",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_3",
		a_obj = "a_casing_3",
		type = "extra_3",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_4 = {
		name_id = "bm_wp_webley_casing_4",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_4",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_4",
		a_obj = "a_casing_4",
		type = "extra_4",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_5 = {
		name_id = "bm_wp_webley_casing_5",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_5",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_5",
		a_obj = "a_casing_5",
		type = "extra_5",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_casing_6 = {
		name_id = "bm_wp_webley_casing_6",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_casing_6",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_casing_6",
		a_obj = "a_casing_6",
		type = "extra_6",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_bullet_clip = {
		name_id = "bm_wp_webley_bullet_clip",
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_bullet_clip",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_bullet_clip",
		a_obj = "a_clip",
		type = "bullet_clip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_webley_bullets = {
		unit = "units/vanilla/weapons/wpn_fps_pis_webley_pts/wpn_fps_pis_webley_bullets",
		name_id = "bm_wp_webley_bullets",
		third_unit = "units/vanilla/weapons/wpn_third_pis_webley_pts/wpn_third_pis_webley_bullets",
		a_obj = "a_bullets",
		type = "magazine",
		bullet_objects = {
			amount = 6,
			prefix = "g_bullet_"
		},
		animations = {
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		stats = {
			value = 1
		}
	}
	self.wpn_fps_pis_webley = {
		unit = "units/vanilla/weapons/wpn_fps_pis_webley/wpn_fps_pis_webley",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"sight"
		},
		default_blueprint = {
			"wpn_fps_pis_webley_body_standard",
			"wpn_fps_pis_webley_lock_standard",
			"wpn_fps_pis_webley_hammer_standard",
			"wpn_fps_pis_webley_trigger_standard",
			"wpn_fps_pis_webley_b_standard",
			"wpn_fps_pis_webley_m_standard",
			"wpn_fps_pis_webley_ejector_standard",
			"wpn_fps_pis_webley_casing_1",
			"wpn_fps_pis_webley_casing_2",
			"wpn_fps_pis_webley_casing_3",
			"wpn_fps_pis_webley_casing_4",
			"wpn_fps_pis_webley_casing_5",
			"wpn_fps_pis_webley_casing_6",
			"wpn_fps_pis_webley_bullet_clip",
			"wpn_fps_pis_webley_bullets"
		},
		uses_parts = {
			"wpn_fps_pis_webley_body_standard",
			"wpn_fps_pis_webley_lock_standard",
			"wpn_fps_pis_webley_hammer_standard",
			"wpn_fps_pis_webley_trigger_standard",
			"wpn_fps_pis_webley_b_standard",
			"wpn_fps_pis_webley_m_standard",
			"wpn_fps_pis_webley_ejector_standard",
			"wpn_fps_pis_webley_casing_1",
			"wpn_fps_pis_webley_casing_2",
			"wpn_fps_pis_webley_casing_3",
			"wpn_fps_pis_webley_casing_4",
			"wpn_fps_pis_webley_casing_5",
			"wpn_fps_pis_webley_casing_6",
			"wpn_fps_pis_webley_bullet_clip",
			"wpn_fps_pis_webley_bullets"
		}
	}
	self.wpn_fps_pis_webley_npc = deep_clone(self.wpn_fps_pis_webley)
	self.wpn_fps_pis_webley_npc.unit = "units/vanilla/weapons/wpn_fps_pis_webley/wpn_fps_pis_webley_npc"
end

function WeaponFactoryTweakData:_init_mosin()
	self.parts.wpn_fps_snp_mosin_b_standard = {
		name_id = "bm_wp_mosin_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_b_long = {
		name_id = "bm_wp_mosin_b_long",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_body_standard = {
		name_id = "bm_wp_mosin_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_body_standard",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_body_grip = {
		name_id = "bm_wp_mosin_body_grip",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_body_grip",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_body_target = {
		name_id = "bm_wp_mosin_body_target",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_body_target",
		a_obj = "a_body",
		type = "body",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_bolt_standard = {
		name_id = "bm_wp_mosin_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_bolt_standard",
		a_obj = "a_bolt",
		type = "bolt",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_dh_standard = {
		name_id = "bm_wp_mosin_dh_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_dh_standard",
		a_obj = "a_dh",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_m_standard = {
		name_id = "bm_wp_mosin_m_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_m_standard",
		a_obj = "a_m",
		type = "magazine",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_clip_standard = {
		name_id = "bm_wp_mosin_clip_standard",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_clip_standard",
		a_obj = "a_clip",
		type = "clip",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_bullet = {
		name_id = "bm_wp_mosin_bullet",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_bullet",
		a_obj = "a_bullet",
		type = "bullets",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_snp_mosin_o_scope = {
		parent = "body",
		name_id = "bm_wp_mosin_o_scope",
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin_pts/wpn_fps_snp_mosin_o_scope",
		a_obj = "a_o",
		reticle_obj = "g_reticle",
		type = "scope",
		stats = {
			zoom = 7,
			value = 1
		},
		stance_mod = {
			wpn_fps_snp_mosin = {
				lens_distortion_power = 1.015,
				translation = Vector3(0, -21, -2.323)
			}
		}
	}
	self.parts.wpn_fps_snp_mosin_b_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_b_standard"
	self.parts.wpn_fps_snp_mosin_b_long.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_b_long"
	self.parts.wpn_fps_snp_mosin_body_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_body_standard"
	self.parts.wpn_fps_snp_mosin_body_grip.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_body_grip"
	self.parts.wpn_fps_snp_mosin_body_target.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_body_target"
	self.parts.wpn_fps_snp_mosin_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_bolt_standard"
	self.parts.wpn_fps_snp_mosin_dh_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_dh_standard"
	self.parts.wpn_fps_snp_mosin_m_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_m_standard"
	self.parts.wpn_fps_snp_mosin_clip_standard.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_clip_standard"
	self.parts.wpn_fps_snp_mosin_bullet.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_bullet"
	self.parts.wpn_fps_snp_mosin_o_scope.third_unit = "units/vanilla/weapons/wpn_third_snp_mosin_pts/wpn_third_snp_mosin_o_scope"
	self.wpn_fps_snp_mosin = {
		unit = "units/vanilla/weapons/wpn_fps_snp_mosin/wpn_fps_snp_mosin",
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"gadget",
			"sight",
			"bayonet"
		},
		default_blueprint = {
			"wpn_fps_snp_mosin_b_standard",
			"wpn_fps_snp_mosin_body_standard",
			"wpn_fps_snp_mosin_bolt_standard",
			"wpn_fps_snp_mosin_dh_standard",
			"wpn_fps_snp_mosin_m_standard",
			"wpn_fps_snp_mosin_clip_standard",
			"wpn_fps_snp_mosin_bullet"
		},
		uses_parts = {
			"wpn_fps_snp_mosin_b_standard",
			"wpn_fps_snp_mosin_body_standard",
			"wpn_fps_snp_mosin_bolt_standard",
			"wpn_fps_snp_mosin_dh_standard",
			"wpn_fps_snp_mosin_m_standard",
			"wpn_fps_snp_mosin_clip_standard",
			"wpn_fps_snp_mosin_bullet",
			"wpn_fps_snp_mosin_b_long",
			"wpn_fps_snp_mosin_body_grip",
			"wpn_fps_snp_mosin_body_target",
			"wpn_fps_snp_mosin_o_scope"
		}
	}
	self.wpn_fps_snp_mosin_npc = deep_clone(self.wpn_fps_snp_mosin)
	self.wpn_fps_snp_mosin_npc.unit = "units/vanilla/weapons/wpn_fps_snp_mosin/wpn_fps_snp_mosin_npc"
end

function WeaponFactoryTweakData:_init_sterling()
	self.parts.wpn_fps_smg_sterling_b_long = {
		name_id = "bm_wp_sterling_b_long",
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_b_long",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_b_standard = {
		name_id = "bm_wp_sterling_b_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_body_standard = {
		name_id = "bm_wp_sterling_body_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_bolt_standard = {
		name_id = "bm_wp_sterling_bolt_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_bolt_standard",
		a_obj = "a_bolt",
		type = "bolt",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_m_long = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_m_long",
		name_id = "bm_wp_sterling_m_long",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_m_long_double = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_m_long_double",
		name_id = "bm_wp_sterling_m_long_double",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_m_medium = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_m_medium",
		name_id = "bm_wp_sterling_m_medium",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 3,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_s_standard = {
		name_id = "bm_wp_sterling_s_standard",
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling_pts/wpn_fps_smg_sterling_s_standard",
		a_obj = "a_s",
		type = "stock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_smg_sterling_b_long.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_b_long"
	self.parts.wpn_fps_smg_sterling_b_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_b_standard"
	self.parts.wpn_fps_smg_sterling_body_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_body_standard"
	self.parts.wpn_fps_smg_sterling_bolt_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_bolt_standard"
	self.parts.wpn_fps_smg_sterling_m_long.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_m_long"
	self.parts.wpn_fps_smg_sterling_m_long_double.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_m_long_double"
	self.parts.wpn_fps_smg_sterling_m_medium.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_m_medium"
	self.parts.wpn_fps_smg_sterling_s_standard.third_unit = "units/vanilla/weapons/wpn_third_smg_sterling_pts/wpn_third_smg_sterling_s_standard"
	self.wpn_fps_smg_sterling = {
		unit = "units/vanilla/weapons/wpn_fps_smg_sterling/wpn_fps_smg_sterling",
		animations = {
			fire = "recoil",
			magazine_empty = "last_recoil",
			fire_steelsight = "recoil",
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		optional_types = {
			"barrel_ext",
			"gadget",
			"vertical_grip"
		},
		default_blueprint = {
			"wpn_fps_smg_sterling_b_standard",
			"wpn_fps_smg_sterling_body_standard",
			"wpn_fps_smg_sterling_bolt_standard",
			"wpn_fps_smg_sterling_m_medium",
			"wpn_fps_smg_sterling_s_standard"
		},
		uses_parts = {
			"wpn_fps_smg_sterling_b_standard",
			"wpn_fps_smg_sterling_body_standard",
			"wpn_fps_smg_sterling_bolt_standard",
			"wpn_fps_smg_sterling_m_medium",
			"wpn_fps_smg_sterling_s_standard",
			"wpn_fps_smg_sterling_b_long",
			"wpn_fps_smg_sterling_m_long",
			"wpn_fps_smg_sterling_m_long_double"
		}
	}
	self.wpn_fps_smg_sterling_npc = deep_clone(self.wpn_fps_smg_sterling)
	self.wpn_fps_smg_sterling_npc.unit = "units/vanilla/weapons/wpn_fps_smg_sterling/wpn_fps_smg_sterling_npc"
end

function WeaponFactoryTweakData:_init_welrod()
	self.parts.wpn_fps_pis_welrod_body_standard = {
		name_id = "bm_wp_welrod_body_standard",
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_body_standard",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_body_standard",
		a_obj = "a_body",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_welrod_bolt_standard = {
		name_id = "bm_wp_welrod_bolt_standard",
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_bolt_standard",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_bolt_standard",
		a_obj = "a_bolt",
		type = "drag_handle",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_welrod_m_standard = {
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_m_standard",
		name_id = "bm_wp_welrod_m_standard",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_m_standard",
		a_obj = "a_m",
		type = "magazine",
		bullet_objects = {
			amount = 5,
			prefix = "g_bullet_"
		},
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_welrod_catch = {
		name_id = "bm_wp_welrod_catch",
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_catch",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_catch",
		a_obj = "a_catch",
		type = "extra_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_welrod_trigger = {
		name_id = "bm_wp_welrod_trigger",
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_trigger",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_trigger",
		a_obj = "a_trigger",
		type = "extra_2",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_welrod_safety = {
		name_id = "bm_wp_welrod_safety",
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod_pts/wpn_fps_pis_welrod_safety",
		third_unit = "units/upd_017/weapons/wpn_third_pis_welrod_pts/wpn_third_pis_welrod_safety",
		a_obj = "a_safety",
		type = "extra_3",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_pis_welrod = {
		unit = "units/upd_017/weapons/wpn_fps_pis_welrod/wpn_fps_pis_welrod",
		optional_types = {
			"barrel_ext",
			"gadget"
		},
		animations = {
			fire_steelsight = "recoil",
			fire = "recoil",
			reload_not_empty = "reload",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_pis_welrod_body_standard",
			"wpn_fps_pis_welrod_bolt_standard",
			"wpn_fps_pis_welrod_m_standard",
			"wpn_fps_pis_welrod_catch",
			"wpn_fps_pis_welrod_trigger",
			"wpn_fps_pis_welrod_safety"
		},
		uses_parts = {
			"wpn_fps_pis_welrod_body_standard",
			"wpn_fps_pis_welrod_bolt_standard",
			"wpn_fps_pis_welrod_m_standard",
			"wpn_fps_pis_welrod_catch",
			"wpn_fps_pis_welrod_trigger",
			"wpn_fps_pis_welrod_safety"
		}
	}
	self.wpn_fps_pis_welrod_npc = deep_clone(self.wpn_fps_pis_welrod)
	self.wpn_fps_pis_welrod_npc.unit = "units/upd_017/weapons/wpn_fps_pis_welrod/wpn_fps_pis_welrod_npc"
end

function WeaponFactoryTweakData:_init_shotty()
	self.parts.wpn_fps_pis_shotty_b_standard = {
		name_id = "bm_wp_pis_shotty_b_standard",
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty_pts/wpn_fps_pis_shotty_b_standard",
		third_unit = "units/upd_015/weapons/wpn_third_pis_shotty_pts/wpn_third_pis_shotty_b_standard",
		a_obj = "a_b",
		type = "barrel",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_shotty_body_standard = {
		name_id = "bm_wp_pis_shotty_body_standard",
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty_pts/wpn_fps_pis_shotty_body_standard",
		third_unit = "units/upd_015/weapons/wpn_third_pis_shotty_pts/wpn_third_pis_shotty_body_standard",
		a_obj = "a_body",
		type = "lower_receiver",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_shotty_lock = {
		name_id = "bm_wp_pis_shotty_lock",
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty_pts/wpn_fps_pis_shotty_lock",
		third_unit = "units/upd_015/weapons/wpn_third_pis_shotty_pts/wpn_third_pis_shotty_lock",
		a_obj = "a_lock",
		type = "lock",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_shotty_shell_1 = {
		name_id = "bm_wp_pis_shotty_shell_1",
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty_pts/wpn_fps_pis_shotty_shell_1",
		third_unit = "units/upd_015/weapons/wpn_third_pis_shotty_pts/wpn_third_pis_shotty_shell_1",
		a_obj = "a_shell_1",
		type = "shell_1",
		stats = {
			value = 1
		}
	}
	self.parts.wpn_fps_pis_shotty_shell_2 = {
		name_id = "bm_wp_pis_shotty_shell_2",
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty_pts/wpn_fps_pis_shotty_shell_2",
		third_unit = "units/upd_015/weapons/wpn_third_pis_shotty_pts/wpn_third_pis_shotty_shell_2",
		a_obj = "a_shell_2",
		type = "shell_2",
		stats = {
			value = 1
		}
	}
	self.wpn_fps_pis_shotty = {
		unit = "units/upd_015/weapons/wpn_fps_pis_shotty/wpn_fps_pis_shotty",
		optional_types = {
			"barrel_ext",
			"gadget"
		},
		animations = {
			reload_not_empty = "reload_not_empty",
			reload = "reload"
		},
		default_blueprint = {
			"wpn_fps_pis_shotty_b_standard",
			"wpn_fps_pis_shotty_body_standard",
			"wpn_fps_pis_shotty_lock",
			"wpn_fps_pis_shotty_shell_1",
			"wpn_fps_pis_shotty_shell_2"
		},
		uses_parts = {
			"wpn_fps_pis_shotty_b_standard",
			"wpn_fps_pis_shotty_body_standard",
			"wpn_fps_pis_shotty_lock",
			"wpn_fps_pis_shotty_shell_1",
			"wpn_fps_pis_shotty_shell_2"
		}
	}
	self.wpn_fps_pis_shotty_npc = deep_clone(self.wpn_fps_pis_shotty)
	self.wpn_fps_pis_shotty_npc.unit = "units/upd_015/weapons/wpn_fps_pis_shotty/wpn_fps_pis_shotty_npc"
end

function WeaponFactoryTweakData:_init_weapon_skins()
	local materials_fps = {
		mat_body = {
			bump_normal_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_nm",
			material_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_gsm",
			diffuse_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_df"
		},
		mat_body_addons = {
			bump_normal_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_addons_nm",
			material_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_addons_gsm",
			diffuse_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/american/body_addons_df"
		}
	}
	local materials_tps = materials_fps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_body_default_skin1")

	self.parts.wpn_fps_pis_georg_body_default_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_body_default)
	self.parts.wpn_fps_pis_georg_body_default_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_body_default_skin1.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_slide_default_skin1")

	self.parts.wpn_fps_pis_georg_slide_default_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_slide_default)
	self.parts.wpn_fps_pis_georg_slide_default_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_slide_default_skin1.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_barrel_short_skin1")

	self.parts.wpn_fps_pis_georg_barrel_short_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_barrel_short)
	self.parts.wpn_fps_pis_georg_barrel_short_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_barrel_short_skin1.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_barrel_long_skin1")

	self.parts.wpn_fps_pis_georg_barrel_long_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_barrel_long)
	self.parts.wpn_fps_pis_georg_barrel_long_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_barrel_long_skin1.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_mag_default_skin1")

	self.parts.wpn_fps_pis_georg_mag_default_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_mag_default)
	self.parts.wpn_fps_pis_georg_mag_default_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_mag_default_skin1.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_stock_wooden_skin1")

	self.parts.wpn_fps_pis_georg_stock_wooden_skin1 = deep_clone(self.parts.wpn_fps_pis_georg_stock_wooden)
	self.parts.wpn_fps_pis_georg_stock_wooden_skin1.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_stock_wooden_skin1.materials_tps = materials_tps
	materials_fps = {
		mat_body = {
			bump_normal_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_nm",
			material_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_gsm",
			diffuse_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_df"
		},
		mat_body_addons = {
			bump_normal_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_addons_nm",
			material_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_addons_gsm",
			diffuse_texture = "units/upd_georg/weapons/wpn_fps_pis_georg/skins/german/body_addons_df"
		}
	}
	materials_tps = materials_fps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_body_default_skin2")

	self.parts.wpn_fps_pis_georg_body_default_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_body_default)
	self.parts.wpn_fps_pis_georg_body_default_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_body_default_skin2.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_slide_default_skin2")

	self.parts.wpn_fps_pis_georg_slide_default_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_slide_default)
	self.parts.wpn_fps_pis_georg_slide_default_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_slide_default_skin2.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_barrel_short_skin2")

	self.parts.wpn_fps_pis_georg_barrel_short_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_barrel_short)
	self.parts.wpn_fps_pis_georg_barrel_short_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_barrel_short_skin2.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_barrel_long_skin2")

	self.parts.wpn_fps_pis_georg_barrel_long_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_barrel_long)
	self.parts.wpn_fps_pis_georg_barrel_long_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_barrel_long_skin2.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_mag_default_skin2")

	self.parts.wpn_fps_pis_georg_mag_default_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_mag_default)
	self.parts.wpn_fps_pis_georg_mag_default_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_mag_default_skin2.materials_tps = materials_tps

	table.insert(self.wpn_fps_pis_georg.uses_parts, "wpn_fps_pis_georg_stock_wooden_skin2")

	self.parts.wpn_fps_pis_georg_stock_wooden_skin2 = deep_clone(self.parts.wpn_fps_pis_georg_stock_wooden)
	self.parts.wpn_fps_pis_georg_stock_wooden_skin2.materials_fps = materials_fps
	self.parts.wpn_fps_pis_georg_stock_wooden_skin2.materials_tps = materials_tps
end

function WeaponFactoryTweakData:is_part_internal(part_id)
	return self.parts[part_id] and self.parts[part_id].internal_part or false
end

function WeaponFactoryTweakData:create_ammunition()
end
