require("lib/tweak_data/WeaponFactoryTweakData")

WeaponTweakData = WeaponTweakData or class()
WeaponTweakData.WEAPON_CATEGORY_SMG = "smg"
WeaponTweakData.WEAPON_CATEGORY_ASSAULT_RIFLE = "assault_rifle"
WeaponTweakData.WEAPON_CATEGORY_LMG = "lmg"
WeaponTweakData.WEAPON_CATEGORY_PISTOL = "pistol"
WeaponTweakData.WEAPON_CATEGORY_SNP = "snp"
WeaponTweakData.WEAPON_CATEGORY_SHOTGUN = "shotgun"
WeaponTweakData.WEAPON_CATEGORY_FLAMETHROWER = "flamethrower"
WeaponTweakData.DAMAGE_TYPE_BULLET = "bullet"
WeaponTweakData.DAMAGE_TYPE_MELEE = "melee"
WeaponTweakData.DAMAGE_TYPE_EXPLOSION = "explosion"
WeaponTweakData.HIT_INDICATOR_PERCENT = 0.05
WeaponTweakData.HIT_INDICATOR_ABSOLUTE = 2.5
WeaponTweakData.INIT_ROTATION_YAW = 55
WeaponTweakData.INIT_ROTATION_PITCH = 3
WeaponTweakData.INIT_ROTATION_PITCH_PISTOL = 4

function WeaponTweakData:get_weapon_class_regen_multiplier(weapon_class)
	if weapon_class == WeaponTweakData.WEAPON_CATEGORY_SMG then
		return 1
	elseif weapon_class == WeaponTweakData.WEAPON_CATEGORY_ASSAULT_RIFLE then
		return 1
	elseif weapon_class == WeaponTweakData.WEAPON_CATEGORY_PISTOL then
		return 1
	elseif weapon_class == WeaponTweakData.WEAPON_CATEGORY_SNP then
		return 1.25
	elseif weapon_class == WeaponTweakData.WEAPON_CATEGORY_SHOTGUN then
		return 1.25
	elseif weapon_class == WeaponTweakData.WEAPON_CATEGORY_FLAMETHROWER then
		return 1
	else
		return 0
	end
end

function WeaponTweakData:convert_rpm(rounds_per_minute)
	return 1 / (rounds_per_minute / 60)
end

function WeaponTweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:_init_data_npc_melee()
	self:_init_data_player_weapons(tweak_data)
	self:_init_data_turrets()
	self:_init_data_m4_npc()
	self:_init_data_c45_npc()
	self:_init_data_mp5_npc()
	self:_init_data_m1911_npc()
	self:_init_data_thompson_npc()
	self:_init_data_sten_npc()
	self:_init_data_garand_npc()
	self:_init_data_m1918_npc()
	self:_init_data_m1903_npc()
	self:_init_data_m1912_npc()
	self:_init_data_mp38_npc()
	self:_init_data_mp44_npc()
	self:_init_data_geco_npc()
	self:_init_data_dp28_npc()
	self:_init_data_tt33_npc()
	self:_init_data_ithaca_npc()
	self:_init_data_kar_98k_npc()
	self:_init_data_bren_npc()
	self:_init_data_lee_enfield_npc()
	self:_init_data_browning_npc()
	self:_init_data_welrod_npc()
	self:_init_data_shotty_npc()
	self:_init_data_tiger_main_gun_module_npc(difficulty_index)
	self:_init_data_tiger_machinegun_module_npc(difficulty_index)
	self:_init_data_junker_machinegun_module_npc(difficulty_index)
	self:_init_data_m24()
	self:_init_data_concrete()
	self:_init_data_d343()
	self:_init_data_mills()
	self:_init_data_decoy_coin()
	self:_init_data_molotov()
	self:_init_data_betty()
	self:_init_data_kar98_npc()
	self:_init_data_sniper_kar98_npc()
	self:_init_data_ger_luger_npc()
	self:_init_data_ger_stg44_npc()
	self:_init_data_usa_garand_npc()
	self:_init_data_usa_m1911_npc()
	self:_init_data_usa_sten_npc()
	self:_init_data_ger_geco_npc()
	self:_init_data_ger_mp38_npc()
	self:_init_data_carbine_npc()
	self:_init_data_mg42_npc()
	self:_init_data_c96_npc()
	self:_init_data_webley_npc()
	self:_init_data_mosin_npc()
	self:_init_data_sterling_npc()
	self:_init_data_spotting_optics_npc()
	self:_init_data_m42_flammenwerfer_npc(difficulty_index)
	self:_init_data_panzerfaust_60_npc()
	self:_init_data_weapon_skins()
end

function WeaponTweakData:_init_data_weapon_skins()
	self.weapon_skins = {}
	self.weapon_skins.garand_special_edition = {}
	self.weapon_skins.garand_special_edition.weapon_id = "garand"
	self.weapon_skins.garand_special_edition.name_id = "garand_se"
	self.weapon_skins.garand_special_edition.dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION
	self.weapon_skins.garand_special_edition.replaces_parts = {
		wpn_fps_ass_garand_body_standard = "wpn_fps_ass_garand_golden_body_standard",
		wpn_fps_ass_garand_b_standard = "wpn_fps_ass_garand_golden_b_standard",
		wpn_fps_ass_garand_strip_standard = "wpn_fps_ass_garand_golden_strip_standard",
		wpn_fps_ass_garand_extra_swiwel = "wpn_fps_ass_garand_golden_extra_swiwel",
		wpn_fps_ass_garand_extra1_swiwel = "wpn_fps_ass_garand_golden_extra1_swiwel",
		wpn_fps_ass_garand_dh_standard = "wpn_fps_ass_garand_golden_dh_standard",
		wpn_fps_ass_garand_s_standard = "wpn_fps_ass_garand_golden_s_standard",
		wpn_fps_ass_garand_bolt_standard = "wpn_fps_ass_garand_golden_bolt_standard",
		wpn_fps_ass_garand_ns_conical = "wpn_fps_ass_garand_golden_ns_conical",
		wpn_fps_ass_garand_b_tanker = "wpn_fps_ass_garand_golden_b_tanker",
		wpn_fps_ass_garand_s_folding = "wpn_fps_ass_garand_golden_s_folding",
		wpn_fps_ass_garand_m_bar_standard = "wpn_fps_ass_garand_golden_m_bar_standard",
		wpn_fps_ass_garand_m_bar_extended = "wpn_fps_ass_garand_golden_m_bar_extended"
	}
end

function WeaponTweakData:get_weapon_skins(weapon_id)
	local skins = {}

	for k, v in pairs(self.weapon_skins) do
		print(v.dlc or "false")

		if v.weapon_id == weapon_id and (not v.dlc or tweak_data.dlc:is_weapon_skin_unlocked(k)) then
			table.insert(skins, k)
		end
	end

	Application:debug("[WeaponTweakData] get_weapon_skins list '" .. weapon_id .. "' skins:", inspect(skins))

	return skins
end

function WeaponTweakData:get_weapon_skin_name_id(skin_id)
	return self.weapon_skins[skin_id] and self.weapon_skins[skin_id].name_id or "missing"
end

function WeaponTweakData:_set_difficulty_1()
	self:_set_npc_melee_damage_multiplier(1)

	self.tiger_main_gun_module.HEALTH_INIT = 7000
	self.tiger_main_gun_module.SHIELD_HEALTH_INIT = 100
	self.tiger_main_gun_module.DAMAGE = 20
	self.tiger_machinegun_module.HEALTH_INIT = 7000
	self.tiger_machinegun_module.SHIELD_HEALTH_INIT = 100
	self.tiger_machinegun_module.DAMAGE = 2
end

function WeaponTweakData:_set_difficulty_2()
	self:_set_npc_melee_damage_multiplier(1.5)

	self.tiger_main_gun_module.HEALTH_INIT = 7000
	self.tiger_main_gun_module.SHIELD_HEALTH_INIT = 100
	self.tiger_main_gun_module.DAMAGE = 30
	self.tiger_machinegun_module.HEALTH_INIT = 7000
	self.tiger_machinegun_module.SHIELD_HEALTH_INIT = 100
	self.tiger_machinegun_module.DAMAGE = 3
end

function WeaponTweakData:_set_difficulty_3()
	self:_set_npc_melee_damage_multiplier(1.75)

	self.tiger_main_gun_module.HEALTH_INIT = 27500
	self.tiger_main_gun_module.SHIELD_HEALTH_INIT = 400
	self.tiger_main_gun_module.DAMAGE = 40
	self.tiger_machinegun_module.HEALTH_INIT = 27000
	self.tiger_machinegun_module.SHIELD_HEALTH_INIT = 400
	self.tiger_machinegun_module.DAMAGE = 4
end

function WeaponTweakData:_set_difficulty_4()
	self:_set_npc_melee_damage_multiplier(2)

	self.tiger_main_gun_module.HEALTH_INIT = 50000
	self.tiger_main_gun_module.SHIELD_HEALTH_INIT = 750
	self.tiger_main_gun_module.DAMAGE = 50
	self.tiger_machinegun_module.HEALTH_INIT = 50000
	self.tiger_machinegun_module.SHIELD_HEALTH_INIT = 750
	self.tiger_machinegun_module.DAMAGE = 5
end

function WeaponTweakData:_init_data_npc_melee()
	self.npc_melee = {}
	self.npc_melee.fists = {}
	self.npc_melee.fists.unit_name = nil
	self.npc_melee.fists.damage = 12
	self.npc_melee.fists.animation_param = "melee_fist"
	self.npc_melee.fists.player_blood_effect = true
end

function WeaponTweakData:_set_npc_melee_damage_multiplier(mul)
	for name, data in pairs(self.npc_melee) do
		data.damage = data.damage * mul
	end
end

function WeaponTweakData:_init_data_m1911_npc()
	self.m1911_npc = {}
	self.m1911_npc.sounds = {}
	self.m1911_npc.use_data = {}
	self.m1911_npc.usage = "c45"
	self.m1911_npc.usage_anim = "c45"
	self.m1911_npc.sounds.prefix = ""
	self.m1911_npc.sounds.single = "colt_m1911_fire_npc"
	self.m1911_npc.sounds.autofire_start = nil
	self.m1911_npc.sounds.autofire_stop = nil
	self.m1911_npc.use_data.selection_index = 1
	self.m1911_npc.DAMAGE = 2
	self.m1911_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.m1911_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.m1911_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.m1911_npc.CLIP_AMMO_MAX = 10
	self.m1911_npc.NR_CLIPS_MAX = 5
	self.m1911_npc.AMMO_MAX = self.m1911_npc.CLIP_AMMO_MAX * self.m1911_npc.NR_CLIPS_MAX
	self.m1911_npc.hold = "pistol"
	self.m1911_npc.alert_size = 5000
	self.m1911_npc.suppression = 1
end

function WeaponTweakData:_init_data_geco_npc()
	self.geco_npc = {}
	self.geco_npc.sounds = {}
	self.geco_npc.use_data = {}
	self.geco_npc.usage = "geco"
	self.geco_npc.usage_anim = "geco"
	self.geco_npc.sounds.prefix = ""
	self.geco_npc.sounds.single = "double_barrel_fire_npc_single"
	self.geco_npc.sounds.autofire_start = nil
	self.geco_npc.sounds.autofire_stop = nil
	self.geco_npc.use_data.selection_index = 2
	self.geco_npc.DAMAGE = 6
	self.geco_npc.muzzleflash = "effects/vanilla/weapons/shotgun/sho_muzzleflash"
	self.geco_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.geco_npc.CLIP_AMMO_MAX = 2
	self.geco_npc.NR_CLIPS_MAX = 32
	self.geco_npc.AMMO_MAX = self.geco_npc.CLIP_AMMO_MAX * self.geco_npc.NR_CLIPS_MAX
	self.geco_npc.auto = {}
	self.geco_npc.auto.fire_rate = 0.8
	self.geco_npc.hold = "geco"
	self.geco_npc.alert_size = 5000
	self.geco_npc.suppression = 1
end

function WeaponTweakData:_init_data_dp28_npc()
	self.dp28_npc = {}
	self.dp28_npc.sounds = {}
	self.dp28_npc.use_data = {}
	self.dp28_npc.usage = "dp28"
	self.dp28_npc.usage_anim = "dp28"
	self.dp28_npc.sounds.prefix = ""
	self.dp28_npc.sounds.single = "dp28_fire_npc_single"
	self.dp28_npc.sounds.autofire_start = "dp28_fire_npc"
	self.dp28_npc.sounds.autofire_stop = "dp28_fire_npc_stop"
	self.dp28_npc.use_data.selection_index = 2
	self.dp28_npc.DAMAGE = 3
	self.dp28_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.dp28_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.dp28_npc.CLIP_AMMO_MAX = 47
	self.dp28_npc.NR_CLIPS_MAX = 4
	self.dp28_npc.AMMO_MAX = self.dp28_npc.CLIP_AMMO_MAX * self.dp28_npc.NR_CLIPS_MAX
	self.dp28_npc.auto = {}
	self.dp28_npc.auto.fire_rate = 0.1
	self.dp28_npc.hold = "dp28"
	self.dp28_npc.alert_size = 5000
	self.dp28_npc.suppression = 1
end

function WeaponTweakData:_init_data_bren_npc()
	self.bren_npc = {}
	self.bren_npc.sounds = {}
	self.bren_npc.use_data = {}
	self.bren_npc.usage = "bren"
	self.bren_npc.usage_anim = "bren"
	self.bren_npc.sounds.prefix = ""
	self.bren_npc.sounds.single = "bren_fire_single_npc"
	self.bren_npc.sounds.autofire_start = "bren_fire_npc"
	self.bren_npc.sounds.autofire_stop = "bren_fire_stop_npc"
	self.bren_npc.use_data.selection_index = 2
	self.bren_npc.DAMAGE = 3
	self.bren_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.bren_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.bren_npc.CLIP_AMMO_MAX = 20
	self.bren_npc.NR_CLIPS_MAX = 6
	self.bren_npc.AMMO_MAX = self.bren_npc.CLIP_AMMO_MAX * self.bren_npc.NR_CLIPS_MAX
	self.bren_npc.auto = {}
	self.bren_npc.auto.fire_rate = 0.12
	self.bren_npc.hold = "bren"
	self.bren_npc.alert_size = 5000
	self.bren_npc.suppression = 1
end

function WeaponTweakData:_init_data_tt33_npc()
	self.tt33_npc = {}
	self.tt33_npc.sounds = {}
	self.tt33_npc.use_data = {}
	self.tt33_npc.usage = "tt33"
	self.tt33_npc.usage_anim = "tt33"
	self.tt33_npc.sounds.prefix = ""
	self.tt33_npc.sounds.single = "tt33_fire_npc"
	self.tt33_npc.sounds.autofire_start = nil
	self.tt33_npc.sounds.autofire_stop = nil
	self.tt33_npc.sounds.dryfire = "secondary_dryfire"
	self.tt33_npc.use_data.selection_index = 1
	self.tt33_npc.DAMAGE = 2
	self.tt33_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.tt33_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.tt33_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.tt33_npc.CLIP_AMMO_MAX = 10
	self.tt33_npc.NR_CLIPS_MAX = 5
	self.tt33_npc.AMMO_MAX = self.tt33_npc.CLIP_AMMO_MAX * self.tt33_npc.NR_CLIPS_MAX
	self.tt33_npc.hold = "tt33"
	self.tt33_npc.alert_size = 5000
	self.tt33_npc.suppression = 1
end

function WeaponTweakData:_init_data_sten_npc()
	self.sten_npc = {}
	self.sten_npc.sounds = {}
	self.sten_npc.use_data = {}
	self.sten_npc.usage = "sten"
	self.sten_npc.usage_anim = "sten"
	self.sten_npc.sounds.prefix = ""
	self.sten_npc.sounds.single = "sten_fire_npc_single"
	self.sten_npc.sounds.autofire_start = "sten_fire_npc"
	self.sten_npc.sounds.autofire_stop = "sten_fire_npc_stop"
	self.sten_npc.use_data.selection_index = 2
	self.sten_npc.DAMAGE = 3
	self.sten_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.sten_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.sten_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.sten_npc.CLIP_AMMO_MAX = 20
	self.sten_npc.NR_CLIPS_MAX = 5
	self.sten_npc.AMMO_MAX = self.sten_npc.CLIP_AMMO_MAX * self.sten_npc.NR_CLIPS_MAX
	self.sten_npc.auto = {}
	self.sten_npc.auto.fire_rate = 0.125
	self.sten_npc.hold = "sten"
	self.sten_npc.alert_size = 5000
	self.sten_npc.suppression = 1
end

function WeaponTweakData:_init_data_garand_npc()
	self.garand_npc = {}
	self.garand_npc.sounds = {}
	self.garand_npc.use_data = {}
	self.garand_npc.usage = "garand"
	self.garand_npc.usage_anim = "garand"
	self.garand_npc.sounds.prefix = ""
	self.garand_npc.sounds.single = "m1garand_fire_npc"
	self.garand_npc.sounds.autofire_start = nil
	self.garand_npc.sounds.autofire_stop = nil
	self.garand_npc.use_data.selection_index = 2
	self.garand_npc.DAMAGE = 3
	self.garand_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.garand_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.garand_npc.CLIP_AMMO_MAX = 8
	self.garand_npc.NR_CLIPS_MAX = 4
	self.garand_npc.AMMO_MAX = self.garand_npc.CLIP_AMMO_MAX * self.garand_npc.NR_CLIPS_MAX
	self.garand_npc.auto = {}
	self.garand_npc.auto.fire_rate = 0.2
	self.garand_npc.hold = "garand"
	self.garand_npc.alert_size = 5000
	self.garand_npc.suppression = 1
end

function WeaponTweakData:_init_data_m1918_npc()
	self.m1918_npc = {}
	self.m1918_npc.sounds = {}
	self.m1918_npc.use_data = {}
	self.m1918_npc.usage = "m1918"
	self.m1918_npc.usage_anim = "m1918"
	self.m1918_npc.sounds.prefix = ""
	self.m1918_npc.sounds.single = "m1918_fire_npc_single"
	self.m1918_npc.sounds.autofire_start = "m1918_fire_npc"
	self.m1918_npc.sounds.autofire_stop = "m1918_fire_npc_stop"
	self.m1918_npc.use_data.selection_index = 2
	self.m1918_npc.DAMAGE = 3
	self.m1918_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.m1918_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.m1918_npc.CLIP_AMMO_MAX = 20
	self.m1918_npc.NR_CLIPS_MAX = 6
	self.m1918_npc.AMMO_MAX = self.m1918_npc.CLIP_AMMO_MAX * self.m1918_npc.NR_CLIPS_MAX
	self.m1918_npc.auto = {}
	self.m1918_npc.auto.fire_rate = 0.16
	self.m1918_npc.hold = "m1918"
	self.m1918_npc.alert_size = 5000
	self.m1918_npc.suppression = 1
end

function WeaponTweakData:_init_data_m24()
	self.m24 = {}
	self.m24.sounds = {}
	self.m24.use_data = {}
	self.m24.usage = "c45"
	self.m24.usage_anim = "c45"
	self.m24.name_id = "bm_grenade_frag"
	self.m24.sounds.prefix = ""
	self.m24.sounds.single = "grenade_explode"
	self.m24.sounds.autofire_start = nil
	self.m24.sounds.autofire_stop = nil
	self.m24.use_data.selection_index = 3
	self.m24.auto = {}
	self.m24.auto.fire_rate = 0.4
	self.m24.hold = "grenade"
	self.m24.alert_size = 5000
	self.m24.suppression = 1
	self.m24.timers = {}
	self.m24.timers.reload_not_empty = 1.25
	self.m24.timers.reload_empty = 1.65
	self.m24.timers.unequip = 0.25
	self.m24.timers.equip = 0.3
	self.m24.weapon_movement_penalty = 1
	self.m24.exit_run_speed_multiplier = 1
	self.m24.transition_duration = 0
	self.m24.stance = "m24"
	self.m24.weapon_hold = "m24"
	self.m24.use_data = {}
	self.m24.use_data.equip = {
		align_place = "right_hand"
	}
	self.m24.use_data.selection_index = 3
	self.m24.use_data.unequip = {
		align_place = "back"
	}
	self.m24.sound_event = "grenade_explode"
	self.m24.damage_melee = 86
	self.m24.damage_melee_effect_mul = 1
	self.m24.hud = {}
	self.m24.hud.icon = "weapon_panel_gre_m24"
	self.m24.hud.panel_class = "grenade"
	self.m24.gui = {}
	self.m24.gui.icon_large = "weapon_ass_garand_large"
	self.m24.stat_group = "grenade"
end

function WeaponTweakData:_init_data_concrete()
	self.concrete = {}
	self.concrete.sounds = {}
	self.concrete.use_data = {}
	self.concrete.usage = "c45"
	self.concrete.usage_anim = "c45"
	self.concrete.name_id = "bm_grenade_concrete"
	self.concrete.sounds.prefix = ""
	self.concrete.sounds.single = "new_grenade_explode"
	self.concrete.sounds.autofire_start = nil
	self.concrete.sounds.autofire_stop = nil
	self.concrete.use_data.selection_index = 3
	self.concrete.auto = {}
	self.concrete.auto.fire_rate = 0.4
	self.concrete.hold = "grenade"
	self.concrete.alert_size = 5000
	self.concrete.suppression = 1
	self.concrete.timers = {}
	self.concrete.timers.reload_not_empty = 1.25
	self.concrete.timers.reload_empty = 1.65
	self.concrete.timers.unequip = 0.25
	self.concrete.timers.equip = 0.3
	self.concrete.weapon_movement_penalty = 1
	self.concrete.exit_run_speed_multiplier = 1
	self.concrete.transition_duration = 0
	self.concrete.stance = "concrete"
	self.concrete.weapon_hold = "concrete"
	self.concrete.use_data = {}
	self.concrete.use_data.equip = {
		align_place = "right_hand"
	}
	self.concrete.use_data.selection_index = 3
	self.concrete.use_data.unequip = {
		align_place = "back"
	}
	self.concrete.sound_event = "new_grenade_explode"
	self.concrete.damage_melee = 86
	self.concrete.damage_melee_effect_mul = 1
	self.concrete.hud = {}
	self.concrete.hud.icon = "weapons_panel_gre_concrete"
	self.concrete.hud.panel_class = "grenade"
	self.concrete.gui = {}
	self.concrete.gui.icon_large = "weapon_gre_concrete_large"
	self.concrete.stat_group = "grenade"
end

function WeaponTweakData:_init_data_d343()
	self.d343 = {}
	self.d343.sounds = {}
	self.d343.use_data = {}
	self.d343.usage = "c45"
	self.d343.usage_anim = "c45"
	self.d343.name_id = "bm_grenade_d343"
	self.d343.sounds.prefix = ""
	self.d343.sounds.single = "new_grenade_explode"
	self.d343.sounds.autofire_start = nil
	self.d343.sounds.autofire_stop = nil
	self.d343.use_data.selection_index = 3
	self.d343.auto = {}
	self.d343.auto.fire_rate = 0.4
	self.d343.hold = "grenade"
	self.d343.alert_size = 5000
	self.d343.suppression = 1
	self.d343.timers = {}
	self.d343.timers.reload_not_empty = 1.25
	self.d343.timers.reload_empty = 1.65
	self.d343.timers.unequip = 0.25
	self.d343.timers.equip = 0.3
	self.d343.weapon_movement_penalty = 1
	self.d343.exit_run_speed_multiplier = 1
	self.d343.transition_duration = 0
	self.d343.stance = "d343"
	self.d343.weapon_hold = "d343"
	self.d343.use_data = {}
	self.d343.use_data.equip = {
		align_place = "right_hand"
	}
	self.d343.use_data.selection_index = 3
	self.d343.use_data.unequip = {
		align_place = "back"
	}
	self.d343.sound_event = "new_grenade_explode"
	self.d343.damage_melee = 86
	self.d343.damage_melee_effect_mul = 1
	self.d343.hud = {}
	self.d343.hud.icon = "weapons_panel_gre_d343"
	self.d343.hud.panel_class = "grenade"
	self.d343.gui = {}
	self.d343.gui.icon_large = "weapon_gre_d343_large"
	self.d343.stat_group = "grenade"
end

function WeaponTweakData:_init_data_mills()
	self.mills = {}
	self.mills.sounds = {}
	self.mills.use_data = {}
	self.mills.usage = "c45"
	self.mills.usage_anim = "c45"
	self.mills.name_id = "bm_grenade_mills"
	self.mills.sounds.prefix = ""
	self.mills.sounds.single = "new_grenade_explode"
	self.mills.sounds.autofire_start = nil
	self.mills.sounds.autofire_stop = nil
	self.mills.use_data.selection_index = 3
	self.mills.auto = {}
	self.mills.auto.fire_rate = 0.4
	self.mills.hold = "grenade"
	self.mills.alert_size = 5000
	self.mills.suppression = 1
	self.mills.timers = {}
	self.mills.timers.reload_not_empty = 1.25
	self.mills.timers.reload_empty = 1.65
	self.mills.timers.unequip = 0.25
	self.mills.timers.equip = 0.3
	self.mills.weapon_movement_penalty = 1
	self.mills.exit_run_speed_multiplier = 1
	self.mills.transition_duration = 0
	self.mills.stance = "mills"
	self.mills.weapon_hold = "mills"
	self.mills.use_data = {}
	self.mills.use_data.equip = {
		align_place = "right_hand"
	}
	self.mills.use_data.selection_index = 3
	self.mills.use_data.unequip = {
		align_place = "back"
	}
	self.mills.sound_event = "new_grenade_explode"
	self.mills.damage_melee = 86
	self.mills.damage_melee_effect_mul = 1
	self.mills.hud = {}
	self.mills.hud.icon = "weapons_panel_gre_mills"
	self.mills.hud.panel_class = "grenade"
	self.mills.gui = {}
	self.mills.gui.icon_large = "weapon_gre_mills_large"
	self.mills.stat_group = "grenade"
end

function WeaponTweakData:_init_data_betty()
	self.betty = {}
	self.betty.sounds = {}
	self.betty.use_data = {}
	self.betty.usage = "c45"
	self.betty.usage_anim = "c45"
	self.betty.name_id = "bm_grenade_betty"
	self.betty.sounds.prefix = ""
	self.betty.sounds.single = "new_grenade_explode"
	self.betty.sounds.autofire_start = nil
	self.betty.sounds.autofire_stop = nil
	self.betty.use_data.selection_index = 3
	self.betty.auto = {}
	self.betty.auto.fire_rate = 0.4
	self.betty.hold = "grenade"
	self.betty.alert_size = 5000
	self.betty.suppression = 1
	self.betty.timers = {}
	self.betty.timers.reload_not_empty = 1.25
	self.betty.timers.reload_empty = 1.65
	self.betty.timers.unequip = 0.25
	self.betty.timers.equip = 0.3
	self.betty.weapon_movement_penalty = 1
	self.betty.exit_run_speed_multiplier = 1
	self.betty.transition_duration = 0
	self.betty.stance = "mills"
	self.betty.weapon_hold = "mills"
	self.betty.use_data = {}
	self.betty.use_data.equip = {
		align_place = "right_hand"
	}
	self.betty.use_data.selection_index = 3
	self.betty.use_data.unequip = {
		align_place = "back"
	}
	self.betty.sound_event = "new_grenade_explode"
	self.betty.damage_melee = 86
	self.betty.damage_melee_effect_mul = 1
	self.betty.hud = {}
	self.betty.hud.icon = "weapons_panel_gre_betty"
	self.betty.hud.panel_class = "grenade"
	self.betty.gui = {}
	self.betty.gui.icon_large = "weapon_gre_betty_large"
	self.betty.stat_group = "mine"
end

function WeaponTweakData:_init_data_decoy_coin()
	self.decoy_coin = {}
	self.decoy_coin.sounds = {}
	self.decoy_coin.use_data = {}
	self.decoy_coin.usage = "c45"
	self.decoy_coin.usage_anim = "c45"
	self.decoy_coin.name_id = "bm_coin"
	self.decoy_coin.sounds.prefix = ""
	self.decoy_coin.sounds.single = ""
	self.decoy_coin.sounds.autofire_start = nil
	self.decoy_coin.sounds.autofire_stop = nil
	self.decoy_coin.throw_shout_replace = "player_gen_thanks"
	self.decoy_coin.use_data.selection_index = 3
	self.decoy_coin.auto = {}
	self.decoy_coin.auto.fire_rate = 0.4
	self.decoy_coin.hold = "grenade"
	self.decoy_coin.alert_size = 5000
	self.decoy_coin.suppression = 1
	self.decoy_coin.timers = {}
	self.decoy_coin.timers.reload_not_empty = 1.25
	self.decoy_coin.timers.reload_empty = 1.65
	self.decoy_coin.timers.unequip = 0.5
	self.decoy_coin.timers.equip = 0.25
	self.decoy_coin.weapon_movement_penalty = 1
	self.decoy_coin.exit_run_speed_multiplier = 1
	self.decoy_coin.transition_duration = 0
	self.decoy_coin.stance = "nagant"
	self.decoy_coin.weapon_hold = "nagant"
	self.decoy_coin.use_data = {}
	self.decoy_coin.use_data.equip = {
		align_place = "right_hand"
	}
	self.decoy_coin.use_data.selection_index = 3
	self.decoy_coin.use_data.unequip = {
		align_place = "back"
	}
	self.decoy_coin.damage_melee = 86
	self.decoy_coin.damage_melee_effect_mul = 1
	self.decoy_coin.hud = {}
	self.decoy_coin.hud.icon = "weapons_panel_gre_decoy_coin"
	self.decoy_coin.hud.panel_class = "grenade"
	self.decoy_coin.gui = {}
	self.decoy_coin.gui.icon_large = "weapon_gre_decoy_coin_large"
	self.decoy_coin.stat_group = "distraction"
end

function WeaponTweakData:_init_data_molotov()
	self.molotov = {}
	self.molotov.sounds = {}
	self.molotov.use_data = {}
	self.molotov.usage = "c45"
	self.molotov.usage_anim = "c45"
	self.molotov.name_id = "bm_grenade_molotov"
	self.molotov.sounds.prefix = ""
	self.molotov.sounds.single = ""
	self.molotov.sounds.autofire_start = nil
	self.molotov.sounds.autofire_stop = nil
	self.molotov.use_data.selection_index = 3
	self.molotov.auto = {}
	self.molotov.auto.fire_rate = 0.4
	self.molotov.hold = "grenade"
	self.molotov.alert_size = 5000
	self.molotov.suppression = 1
	self.molotov.timers = {}
	self.molotov.timers.reload_not_empty = 1.25
	self.molotov.timers.reload_empty = 1.65
	self.molotov.timers.unequip = 0.5
	self.molotov.timers.equip = 0.25
	self.molotov.weapon_movement_penalty = 1
	self.molotov.exit_run_speed_multiplier = 1
	self.molotov.transition_duration = 0
	self.molotov.stance = "m1911"
	self.molotov.weapon_hold = "m1911"
	self.molotov.use_data = {}
	self.molotov.use_data.equip = {
		align_place = "right_hand"
	}
	self.molotov.use_data.selection_index = 3
	self.molotov.use_data.unequip = {
		align_place = "back"
	}
	self.molotov.stat_group = "firebomb"
end

function WeaponTweakData:_init_data_m1903_npc()
	self.m1903_npc = {}
	self.m1903_npc.sounds = {}
	self.m1903_npc.use_data = {}
	self.m1903_npc.usage = "springfield"
	self.m1903_npc.usage_anim = "springfield"
	self.m1903_npc.sounds.prefix = ""
	self.m1903_npc.sounds.single = "springfield_fire_npc_single"
	self.m1903_npc.sounds.autofire_start = nil
	self.m1903_npc.sounds.autofire_stop = nil
	self.m1903_npc.use_data.selection_index = 2
	self.m1903_npc.DAMAGE = 3
	self.m1903_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.m1903_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.m1903_npc.CLIP_AMMO_MAX = 6
	self.m1903_npc.NR_CLIPS_MAX = 8
	self.m1903_npc.AMMO_MAX = self.m1903_npc.CLIP_AMMO_MAX * self.m1903_npc.NR_CLIPS_MAX
	self.m1903_npc.auto = {}
	self.m1903_npc.auto.fire_rate = 1.2
	self.m1903_npc.hold = "springfield"
	self.m1903_npc.alert_size = 5000
	self.m1903_npc.suppression = 1
end

function WeaponTweakData:_init_data_kar_98k_npc()
	self.kar_98k_npc = {}
	self.kar_98k_npc.sounds = {}
	self.kar_98k_npc.use_data = {}
	self.kar_98k_npc.usage = "springfield"
	self.kar_98k_npc.usage_anim = "springfield"
	self.kar_98k_npc.sounds.prefix = ""
	self.kar_98k_npc.sounds.single = "kar98_fire_npc_single"
	self.kar_98k_npc.sounds.autofire_start = nil
	self.kar_98k_npc.sounds.autofire_stop = nil
	self.kar_98k_npc.use_data.selection_index = 2
	self.kar_98k_npc.DAMAGE = 3
	self.kar_98k_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.kar_98k_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.kar_98k_npc.CLIP_AMMO_MAX = 6
	self.kar_98k_npc.NR_CLIPS_MAX = 8
	self.kar_98k_npc.AMMO_MAX = self.kar_98k_npc.CLIP_AMMO_MAX * self.kar_98k_npc.NR_CLIPS_MAX
	self.kar_98k_npc.auto = {}
	self.kar_98k_npc.auto.fire_rate = 1.2
	self.kar_98k_npc.hold = "springfield"
	self.kar_98k_npc.alert_size = 5000
	self.kar_98k_npc.suppression = 1
end

function WeaponTweakData:_init_data_lee_enfield_npc()
	self.lee_enfield_npc = {}
	self.lee_enfield_npc.sounds = {}
	self.lee_enfield_npc.use_data = {}
	self.lee_enfield_npc.usage = "springfield"
	self.lee_enfield_npc.usage_anim = "springfield"
	self.lee_enfield_npc.sounds.prefix = ""
	self.lee_enfield_npc.sounds.single = "lee_fire_npc_single"
	self.lee_enfield_npc.sounds.autofire_start = nil
	self.lee_enfield_npc.sounds.autofire_stop = nil
	self.lee_enfield_npc.use_data.selection_index = 2
	self.lee_enfield_npc.DAMAGE = 3
	self.lee_enfield_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.lee_enfield_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.lee_enfield_npc.CLIP_AMMO_MAX = 6
	self.lee_enfield_npc.NR_CLIPS_MAX = 8
	self.lee_enfield_npc.AMMO_MAX = self.lee_enfield_npc.CLIP_AMMO_MAX * self.lee_enfield_npc.NR_CLIPS_MAX
	self.lee_enfield_npc.auto = {}
	self.lee_enfield_npc.auto.fire_rate = 1.2
	self.lee_enfield_npc.hold = "springfield"
	self.lee_enfield_npc.alert_size = 5000
	self.lee_enfield_npc.suppression = 1
end

function WeaponTweakData:_init_data_m1912_npc()
	self.m1912_npc = {}
	self.m1912_npc.sounds = {}
	self.m1912_npc.use_data = {}
	self.m1912_npc.usage = "m1912"
	self.m1912_npc.usage_anim = "m1912"
	self.m1912_npc.sounds.prefix = ""
	self.m1912_npc.sounds.single = "shotgun_fire_npc_single"
	self.m1912_npc.sounds.autofire_start = nil
	self.m1912_npc.sounds.autofire_stop = nil
	self.m1912_npc.use_data.selection_index = 2
	self.m1912_npc.DAMAGE = 8
	self.m1912_npc.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.m1912_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.m1912_npc.CLIP_AMMO_MAX = 4
	self.m1912_npc.NR_CLIPS_MAX = 64
	self.m1912_npc.AMMO_MAX = self.m1912_npc.CLIP_AMMO_MAX * self.m1912_npc.NR_CLIPS_MAX
	self.m1912_npc.auto = {}
	self.m1912_npc.auto.fire_rate = 0.8
	self.m1912_npc.hold = "m1912"
	self.m1912_npc.alert_size = 5000
	self.m1912_npc.suppression = 1
end

function WeaponTweakData:_init_data_ithaca_npc()
	self.ithaca_npc = {}
	self.ithaca_npc.sounds = {}
	self.ithaca_npc.use_data = {}
	self.ithaca_npc.usage = "m1912"
	self.ithaca_npc.usage_anim = "m1912"
	self.ithaca_npc.sounds.prefix = ""
	self.ithaca_npc.sounds.single = "ithaca_fire_npc_single"
	self.ithaca_npc.sounds.autofire_start = nil
	self.ithaca_npc.sounds.autofire_stop = nil
	self.ithaca_npc.use_data.selection_index = 2
	self.ithaca_npc.DAMAGE = 8
	self.ithaca_npc.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.ithaca_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.ithaca_npc.CLIP_AMMO_MAX = 4
	self.ithaca_npc.NR_CLIPS_MAX = 64
	self.ithaca_npc.AMMO_MAX = self.ithaca_npc.CLIP_AMMO_MAX * self.ithaca_npc.NR_CLIPS_MAX
	self.ithaca_npc.auto = {}
	self.ithaca_npc.auto.fire_rate = 0.8
	self.ithaca_npc.hold = "m1912"
	self.ithaca_npc.alert_size = 5000
	self.ithaca_npc.suppression = 1
end

function WeaponTweakData:_init_data_browning_npc()
	self.browning_npc = {}
	self.browning_npc.sounds = {}
	self.browning_npc.use_data = {}
	self.browning_npc.usage = "m1912"
	self.browning_npc.usage_anim = "m1912"
	self.browning_npc.sounds.prefix = ""
	self.browning_npc.sounds.single = "browning_fire_npc_single"
	self.browning_npc.sounds.autofire_start = nil
	self.browning_npc.sounds.autofire_stop = nil
	self.browning_npc.use_data.selection_index = 2
	self.browning_npc.DAMAGE = 8
	self.browning_npc.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.browning_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.browning_npc.CLIP_AMMO_MAX = 4
	self.browning_npc.NR_CLIPS_MAX = 64
	self.browning_npc.AMMO_MAX = self.browning_npc.CLIP_AMMO_MAX * self.browning_npc.NR_CLIPS_MAX
	self.browning_npc.auto = {}
	self.browning_npc.auto.fire_rate = 0.3
	self.browning_npc.hold = "m1912"
	self.browning_npc.alert_size = 5000
	self.browning_npc.suppression = 1
end

function WeaponTweakData:_init_data_mp38_npc()
	self.mp38_npc = {}
	self.mp38_npc.sounds = {}
	self.mp38_npc.use_data = {}
	self.mp38_npc.usage = "ger_mp38_npc"
	self.mp38_npc.usage_anim = "m4"
	self.mp38_npc.sounds.prefix = ""
	self.mp38_npc.sounds.single = "mp38_fire_npc_single"
	self.mp38_npc.sounds.autofire_start = "mp38_fire_npc"
	self.mp38_npc.sounds.autofire_stop = "mp38_fire_npc_stop"
	self.mp38_npc.use_data.selection_index = 2
	self.mp38_npc.DAMAGE = 3
	self.mp38_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.mp38_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.mp38_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.mp38_npc.CLIP_AMMO_MAX = 20
	self.mp38_npc.NR_CLIPS_MAX = 5
	self.mp38_npc.AMMO_MAX = self.mp38_npc.CLIP_AMMO_MAX * self.mp38_npc.NR_CLIPS_MAX
	self.mp38_npc.auto = {}
	self.mp38_npc.auto.fire_rate = 0.12
	self.mp38_npc.hold = "rifle"
	self.mp38_npc.husk_hold = "mp38"
	self.mp38_npc.alert_size = 5000
	self.mp38_npc.suppression = 1
end

function WeaponTweakData:_init_data_mp44_npc()
	self.mp44_npc = {}
	self.mp44_npc.sounds = {}
	self.mp44_npc.use_data = {}
	self.mp44_npc.usage = "ger_stg44_npc"
	self.mp44_npc.usage_anim = "m4"
	self.mp44_npc.sounds.prefix = ""
	self.mp44_npc.sounds.single = "stg44_fire_npc_single"
	self.mp44_npc.sounds.autofire_start = "stg44_fire_npc"
	self.mp44_npc.sounds.autofire_stop = "stg44_fire_npc_stop"
	self.mp44_npc.use_data.selection_index = 2
	self.mp44_npc.DAMAGE = 3
	self.mp44_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.mp44_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.mp44_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.mp44_npc.CLIP_AMMO_MAX = 20
	self.mp44_npc.NR_CLIPS_MAX = 5
	self.mp44_npc.AMMO_MAX = self.mp44_npc.CLIP_AMMO_MAX * self.mp44_npc.NR_CLIPS_MAX
	self.mp44_npc.auto = {}
	self.mp44_npc.auto.fire_rate = 0.12
	self.mp44_npc.hold = "rifle"
	self.mp44_npc.husk_hold = "stg44"
	self.mp44_npc.alert_size = 5000
	self.mp44_npc.suppression = 1
end

function WeaponTweakData:_init_data_mg42_npc()
	self.mg42_npc = {}
	self.mg42_npc.sounds = {}
	self.mg42_npc.use_data = {}
	self.mg42_npc.usage = "mg42"
	self.mg42_npc.usage_anim = "mg42"
	self.mg42_npc.sounds.prefix = ""
	self.mg42_npc.sounds.single = "mg42_fire_npc_single"
	self.mg42_npc.sounds.autofire_start = "mg42_fire_npc"
	self.mg42_npc.sounds.autofire_stop = "mg42_fire_npc_stop"
	self.mg42_npc.use_data.selection_index = 2
	self.mg42_npc.DAMAGE = 3
	self.mg42_npc.muzzleflash = "effects/vanilla/weapons/big_762_auto"
	self.mg42_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556_lmg"
	self.mg42_npc.CLIP_AMMO_MAX = 120
	self.mg42_npc.NR_CLIPS_MAX = 3
	self.mg42_npc.AMMO_MAX = self.mg42_npc.CLIP_AMMO_MAX * self.mg42_npc.NR_CLIPS_MAX
	self.mg42_npc.auto = {}
	self.mg42_npc.auto.fire_rate = 0.05
	self.mg42_npc.hold = "mg42"
	self.mg42_npc.alert_size = 5000
	self.mg42_npc.suppression = 1
	self.mg42_secondary_npc = deep_clone(self.mg42_npc)
	self.mg42_secondary_npc.use_data.selection_index = 1
	self.mg42_secondary_npc.armor_piercing = true
end

function WeaponTweakData:_init_data_c96_npc()
	self.c96_npc = {}
	self.c96_npc = {}
	self.c96_npc.sounds = {}
	self.c96_npc.use_data = {}
	self.c96_npc.usage = "c45"
	self.c96_npc.usage_anim = "c45"
	self.c96_npc.sounds.prefix = ""
	self.c96_npc.sounds.single = "mauser_c96_fire_npc"
	self.c96_npc.sounds.autofire_start = nil
	self.c96_npc.sounds.autofire_stop = nil
	self.c96_npc.use_data.selection_index = 1
	self.c96_npc.DAMAGE = 2
	self.c96_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.c96_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.c96_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.c96_npc.CLIP_AMMO_MAX = 10
	self.c96_npc.NR_CLIPS_MAX = 5
	self.c96_npc.AMMO_MAX = self.c96_npc.CLIP_AMMO_MAX * self.c96_npc.NR_CLIPS_MAX
	self.c96_npc.hold = "pistol"
	self.c96_npc.alert_size = 5000
	self.c96_npc.suppression = 1
end

function WeaponTweakData:_init_data_webley_npc()
	self.webley_npc = {}
	self.webley_npc = {}
	self.webley_npc.sounds = {}
	self.webley_npc.use_data = {}
	self.webley_npc.usage = "c45"
	self.webley_npc.usage_anim = "c45"
	self.webley_npc.sounds.prefix = ""
	self.webley_npc.sounds.single = "webley_mk6_npc"
	self.webley_npc.sounds.autofire_start = nil
	self.webley_npc.sounds.autofire_stop = nil
	self.webley_npc.use_data.selection_index = 1
	self.webley_npc.DAMAGE = 2
	self.webley_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.webley_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.webley_npc.CLIP_AMMO_MAX = 5
	self.webley_npc.NR_CLIPS_MAX = 10
	self.webley_npc.AMMO_MAX = self.webley_npc.CLIP_AMMO_MAX * self.webley_npc.NR_CLIPS_MAX
	self.webley_npc.hold = "pistol"
	self.webley_npc.alert_size = 5000
	self.webley_npc.suppression = 1
end

function WeaponTweakData:_init_data_mosin_npc()
	self.mosin_npc = {}
	self.mosin_npc.sounds = {}
	self.mosin_npc.use_data = {}
	self.mosin_npc.usage = "mosin"
	self.mosin_npc.usage_anim = "mosin"
	self.mosin_npc.sounds.prefix = ""
	self.mosin_npc.sounds.single = "mosin_fire_npc_single"
	self.mosin_npc.sounds.autofire_start = nil
	self.mosin_npc.sounds.autofire_stop = nil
	self.mosin_npc.use_data.selection_index = 2
	self.mosin_npc.DAMAGE = 3
	self.mosin_npc.muzzleflash = "effects/vanilla/weapons/big_762_auto"
	self.mosin_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.mosin_npc.CLIP_AMMO_MAX = 5
	self.mosin_npc.NR_CLIPS_MAX = 8
	self.mosin_npc.AMMO_MAX = self.mosin_npc.CLIP_AMMO_MAX * self.mosin_npc.NR_CLIPS_MAX
	self.mosin_npc.auto = {}
	self.mosin_npc.auto.fire_rate = 0.2
	self.mosin_npc.hold = "mosin"
	self.mosin_npc.alert_size = 5000
	self.mosin_npc.suppression = 1
end

function WeaponTweakData:_init_data_sterling_npc()
	self.sterling_npc = {}
	self.sterling_npc.sounds = {}
	self.sterling_npc.use_data = {}
	self.sterling_npc.usage = "sterling"
	self.sterling_npc.usage_anim = "sterling"
	self.sterling_npc.sounds.prefix = ""
	self.sterling_npc.sounds.single = "sterling_fire_npc_single"
	self.sterling_npc.sounds.autofire_start = "sterling_fire_npc"
	self.sterling_npc.sounds.autofire_stop = "sterling_fire_npc_stop"
	self.sterling_npc.use_data.selection_index = 2
	self.sterling_npc.DAMAGE = 3
	self.sterling_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.sterling_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.sterling_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.sterling_npc.CLIP_AMMO_MAX = 40
	self.sterling_npc.NR_CLIPS_MAX = 5
	self.sterling_npc.AMMO_MAX = self.sterling_npc.CLIP_AMMO_MAX * self.sterling_npc.NR_CLIPS_MAX
	self.sterling_npc.auto = {}
	self.sterling_npc.auto.fire_rate = 0.11
	self.sterling_npc.hold = "sterling"
	self.sterling_npc.alert_size = 5000
	self.sterling_npc.suppression = 1
end

function WeaponTweakData:_init_data_welrod_npc()
	self.welrod_npc = {}
	self.welrod_npc.sounds = {}
	self.welrod_npc.use_data = {}
	self.welrod_npc.usage = "c45"
	self.welrod_npc.usage_anim = "c45"
	self.welrod_npc.sounds.prefix = ""
	self.welrod_npc.sounds.single = "welrod_fire_npc"
	self.welrod_npc.sounds.autofire_start = nil
	self.welrod_npc.sounds.autofire_stop = nil
	self.welrod_npc.use_data.selection_index = 1
	self.welrod_npc.DAMAGE = 2
	self.welrod_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto_silence"
	self.welrod_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.welrod_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.welrod_npc.CLIP_AMMO_MAX = 6
	self.welrod_npc.NR_CLIPS_MAX = 8
	self.welrod_npc.AMMO_MAX = self.welrod_npc.CLIP_AMMO_MAX * self.welrod_npc.NR_CLIPS_MAX
	self.welrod_npc.hold = "pistol"
	self.welrod_npc.alert_size = 5000
	self.welrod_npc.suppression = 1
end

function WeaponTweakData:_init_data_shotty_npc()
	self.shotty_npc = {}
	self.shotty_npc.sounds = {}
	self.shotty_npc.use_data = {}
	self.shotty_npc.usage = "c45"
	self.shotty_npc.usage_anim = "c45"
	self.shotty_npc.sounds.prefix = ""
	self.shotty_npc.sounds.single = "shotty_fire_npc_single"
	self.shotty_npc.sounds.autofire_start = nil
	self.shotty_npc.sounds.autofire_stop = nil
	self.shotty_npc.use_data.selection_index = 2
	self.shotty_npc.DAMAGE = 8
	self.shotty_npc.muzzleflash = "effects/vanilla/weapons/shotgun/sho_muzzleflash"
	self.shotty_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.shotty_npc.CLIP_AMMO_MAX = 2
	self.shotty_npc.NR_CLIPS_MAX = 32
	self.shotty_npc.AMMO_MAX = self.shotty_npc.CLIP_AMMO_MAX * self.shotty_npc.NR_CLIPS_MAX
	self.shotty_npc.auto = {}
	self.shotty_npc.auto.fire_rate = 0.8
	self.shotty_npc.hold = "pistol"
	self.shotty_npc.alert_size = 5000
	self.shotty_npc.suppression = 1
end

function WeaponTweakData:_init_data_c45_npc()
	self.c45_npc = {}
	self.c45_npc.sounds = {}
	self.c45_npc.use_data = {}
	self.c45_npc.usage = "c45"
	self.c45_npc.usage_anim = "c45"
	self.c45_npc.sounds.prefix = ""
	self.c45_npc.sounds.single = "mauser_c96_fire_npc"
	self.c45_npc.sounds.autofire_start = nil
	self.c45_npc.sounds.autofire_stop = nil
	self.c45_npc.use_data.selection_index = 1
	self.c45_npc.DAMAGE = 2
	self.c45_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.c45_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.c45_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.c45_npc.CLIP_AMMO_MAX = 10
	self.c45_npc.NR_CLIPS_MAX = 5
	self.c45_npc.AMMO_MAX = self.c45_npc.CLIP_AMMO_MAX * self.c45_npc.NR_CLIPS_MAX
	self.c45_npc.hold = "pistol"
	self.c45_npc.alert_size = 5000
	self.c45_npc.suppression = 1
	self.c45_primary_npc = deep_clone(self.c45_npc)
	self.c45_primary_npc.use_data.selection_index = 2
end

function WeaponTweakData:_init_data_m4_npc()
	self.m4_npc = {}
	self.m4_npc.sounds = {}
	self.m4_npc.use_data = {}
	self.m4_npc.usage = "m4"
	self.m4_npc.usage_anim = "m4"
	self.m4_npc.sounds.prefix = ""
	self.m4_npc.sounds.single = "sniper_enemy_fire"
	self.m4_npc.use_data.selection_index = 2
	self.m4_npc.DAMAGE = 2
	self.m4_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.m4_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.m4_npc.CLIP_AMMO_MAX = 20
	self.m4_npc.NR_CLIPS_MAX = 5
	self.m4_npc.AMMO_MAX = self.m4_npc.CLIP_AMMO_MAX * self.m4_npc.NR_CLIPS_MAX
	self.m4_npc.auto = {}
	self.m4_npc.auto.fire_rate = 0.175
	self.m4_npc.hold = "rifle"
	self.m4_npc.alert_size = 5000
	self.m4_npc.suppression = 1
	self.m4_secondary_npc = deep_clone(self.m4_npc)
	self.m4_secondary_npc.use_data.selection_index = 1
end

function WeaponTweakData:_init_data_mp5_npc()
	self.mp5_npc = {}
	self.mp5_npc.sounds = {}
	self.mp5_npc.use_data = {}
	self.mp5_npc.usage = "mp5"
	self.mp5_npc.usage_anim = "mp5"
	self.mp5_npc.sounds.prefix = "mp5_npc"
	self.mp5_npc.use_data.selection_index = 1
	self.mp5_npc.DAMAGE = 2
	self.mp5_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.mp5_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.mp5_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.mp5_npc.CLIP_AMMO_MAX = 30
	self.mp5_npc.NR_CLIPS_MAX = 5
	self.mp5_npc.AMMO_MAX = self.mp5_npc.CLIP_AMMO_MAX * self.mp5_npc.NR_CLIPS_MAX
	self.mp5_npc.auto = {}
	self.mp5_npc.auto.fire_rate = 0.12
	self.mp5_npc.hold = "rifle"
	self.mp5_npc.alert_size = 5000
	self.mp5_npc.suppression = 1
	self.mp5_tactical_npc = deep_clone(self.mp5_npc)
	self.mp5_tactical_npc.has_suppressor = "suppressed_a"
	self.ump_npc = deep_clone(self.mp5_npc)
end

function WeaponTweakData:_init_data_tiger_main_gun_module_npc(difficulty_index)
	self.tiger_main_gun_module = {}
	self.tiger_main_gun_module.sounds = {}
	self.tiger_main_gun_module.auto = {}
	self.tiger_main_gun_module.name_id = "tiger_main_gun_module"
	self.tiger_main_gun_module.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			1500,
			1
		}
	}
	self.tiger_main_gun_module.SUPPRESSION = 1
	self.tiger_main_gun_module.SPREAD = 2
	self.tiger_main_gun_module.FIRE_RANGE = 10000
	self.tiger_main_gun_module.AUTO_RELOAD = true
	self.tiger_main_gun_module.ECM_HACKABLE = false
	self.tiger_main_gun_module.AMMO_MAX = 110
	self.tiger_main_gun_module.HACKABLE_WITH_ECM = false
	self.tiger_main_gun_module.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.tiger_main_gun_module.muzzleflash = nil
	self.tiger_main_gun_module.shell_ejection = "effects/vanilla/weapons/shells/shell_556_lmg"
	self.tiger_main_gun_module.auto.fire_rate = 0.01
	self.tiger_main_gun_module.alert_size = 5000
	self.tiger_main_gun_module.headshot_dmg_mul = 1
	self.tiger_main_gun_module.EXPLOSION_DMG_MUL = 7
	self.tiger_main_gun_module.FIRE_DMG_MUL = 1
	self.tiger_main_gun_module.BAG_DMG_MUL = 200
	self.tiger_main_gun_module.SHIELD_DMG_MUL = 1
	self.tiger_main_gun_module.HEALTH_INIT = 5000
	self.tiger_main_gun_module.SHIELD_HEALTH_INIT = 1000
	self.tiger_main_gun_module.SHIELD_DAMAGE_CLAMP = 10000
	self.tiger_main_gun_module.LOST_SIGHT_VERIFICATION = 0.1
	self.tiger_main_gun_module.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.tiger_main_gun_module.DETECTION_RANGE = self.tiger_main_gun_module.FIRE_RANGE
	self.tiger_main_gun_module.DETECTION_DELAY = {
		{
			900,
			0.3
		},
		{
			3500,
			1.5
		}
	}
	self.tiger_main_gun_module.KEEP_FIRE_ANGLE = 0.999
	self.tiger_main_gun_module.MAX_VEL_SPIN = 20
	self.tiger_main_gun_module.MIN_VEL_SPIN = self.tiger_main_gun_module.MAX_VEL_SPIN * 0.5
	self.tiger_main_gun_module.SLOWDOWN_ANGLE_SPIN = 1
	self.tiger_main_gun_module.ACC_SPIN = self.tiger_main_gun_module.MAX_VEL_SPIN * 5
	self.tiger_main_gun_module.MAX_TARGETING_PITCH = 20
	self.tiger_main_gun_module.MAX_TARGETING_SPIN = 360
	self.tiger_main_gun_module.MAX_VEL_PITCH = 10
	self.tiger_main_gun_module.MIN_VEL_PITCH = self.tiger_main_gun_module.MAX_VEL_PITCH * 0.05
	self.tiger_main_gun_module.SLOWDOWN_ANGLE_PITCH = 1
	self.tiger_main_gun_module.ACC_PITCH = self.tiger_main_gun_module.MAX_VEL_PITCH * 5
	self.tiger_main_gun_module.recoil = {}
	self.tiger_main_gun_module.recoil.horizontal = {
		1,
		1.5,
		1,
		1
	}
	self.tiger_main_gun_module.recoil.vertical = {
		1,
		1.5,
		1,
		1
	}
	self.tiger_main_gun_module.challenges = {}
	self.tiger_main_gun_module.challenges.group = "sentry_gun"
	self.tiger_main_gun_module.challenges.weapon = "sentry_gun"
	self.tiger_main_gun_module.suppression = 0.81
	self.tiger_main_gun_module.CLIP_SIZE = 1

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.tiger_main_gun_module.DAMAGE = 25
		self.tiger_main_gun_module.AUTO_RELOAD_DURATION = 10
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.tiger_main_gun_module.DAMAGE = 35
		self.tiger_main_gun_module.AUTO_RELOAD_DURATION = 10
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.tiger_main_gun_module.DAMAGE = 45
		self.tiger_main_gun_module.AUTO_RELOAD_DURATION = 8
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.tiger_main_gun_module.DAMAGE = 65
		self.tiger_main_gun_module.AUTO_RELOAD_DURATION = 7
	end

	self.tiger_main_gun_module.sound = {
		main_cannon_fire = "tiger_npc_canon",
		main_cannon_fire_hit = "tiger_npc_canon",
		main_cannon_fire_tinnitus_range = 2000,
		main_cannon_lock_on = "tiger_npc_canon_reload"
	}
	self.tiger_main_gun_module.effect = {
		main_cannon_fire = "effects/vanilla/explosions/tank_turret_fire",
		main_cannon_fire_hit = "effects/vanilla/explosions/exp_airbomb_explosion_002"
	}
	self.tiger_main_gun_module.turret = {
		gun_locator = "anim_gun",
		range = 20000,
		damage = 75,
		locator = "anim_turret",
		time_before_taking_shot = 1,
		traverse_time = 10,
		player_damage = 25,
		armor_piercing = true,
		damage_radius = 1000
	}
	self.tiger_main_gun_module.main_cannon_shell_speed = 10000
	self.tiger_main_gun_module.fire_anim_sequence = "fire"
end

function WeaponTweakData:_init_data_tiger_machinegun_module_npc(difficulty_index)
	self.tiger_machinegun_module = {}
	self.tiger_machinegun_module.sounds = {}
	self.tiger_machinegun_module.auto = {}
	self.tiger_machinegun_module.name_id = "debug_sentry_gun"
	self.tiger_machinegun_module.DAMAGE_MUL_RANGE = {
		{
			800,
			4
		},
		{
			1000,
			1.1
		},
		{
			1500,
			1
		}
	}
	self.tiger_machinegun_module.SUPPRESSION = 1
	self.tiger_machinegun_module.SPREAD = 1
	self.tiger_machinegun_module.FIRE_RANGE = 10000
	self.tiger_machinegun_module.AUTO_RELOAD = true
	self.tiger_machinegun_module.ECM_HACKABLE = false
	self.tiger_machinegun_module.HACKABLE_WITH_ECM = false
	self.tiger_machinegun_module.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.tiger_machinegun_module.muzzleflash = "effects/vanilla/weapons/big_762_auto"
	self.tiger_machinegun_module.shell_ejection = "effects/vanilla/weapons/shells/shell_556_lmg"
	self.tiger_machinegun_module.auto.fire_rate = 0.06
	self.tiger_machinegun_module.alert_size = 5000
	self.tiger_machinegun_module.headshot_dmg_mul = 4
	self.tiger_machinegun_module.EXPLOSION_DMG_MUL = 7
	self.tiger_machinegun_module.FIRE_DMG_MUL = 1
	self.tiger_machinegun_module.BAG_DMG_MUL = 200
	self.tiger_machinegun_module.SHIELD_DMG_MUL = 1
	self.tiger_machinegun_module.HEALTH_INIT = 5000
	self.tiger_machinegun_module.SHIELD_HEALTH_INIT = 1000
	self.tiger_machinegun_module.SHIELD_DAMAGE_CLAMP = 75
	self.tiger_machinegun_module.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.tiger_machinegun_module.DETECTION_RANGE = self.tiger_machinegun_module.FIRE_RANGE
	self.tiger_machinegun_module.DETECTION_DELAY = {
		{
			900,
			0.3
		},
		{
			3500,
			1.5
		}
	}
	self.tiger_machinegun_module.KEEP_FIRE_ANGLE = 0.9
	self.tiger_machinegun_module.MAX_TARGETING_PITCH = 30
	self.tiger_machinegun_module.MAX_TARGETING_SPIN = 30
	self.tiger_machinegun_module.MAX_VEL_SPIN = 72
	self.tiger_machinegun_module.MIN_VEL_SPIN = self.tiger_machinegun_module.MAX_VEL_SPIN * 0.05
	self.tiger_machinegun_module.SLOWDOWN_ANGLE_SPIN = 30
	self.tiger_machinegun_module.ACC_SPIN = self.tiger_machinegun_module.MAX_VEL_SPIN * 5
	self.tiger_machinegun_module.MAX_VEL_PITCH = 60
	self.tiger_machinegun_module.MIN_VEL_PITCH = self.tiger_machinegun_module.MAX_VEL_PITCH * 0.05
	self.tiger_machinegun_module.SLOWDOWN_ANGLE_PITCH = 20
	self.tiger_machinegun_module.ACC_PITCH = self.tiger_machinegun_module.MAX_VEL_PITCH * 5
	self.tiger_machinegun_module.recoil = {}
	self.tiger_machinegun_module.recoil.horizontal = {
		1,
		1.5,
		1,
		1
	}
	self.tiger_machinegun_module.recoil.vertical = {
		1,
		1.5,
		1,
		1
	}
	self.tiger_machinegun_module.challenges = {}
	self.tiger_machinegun_module.challenges.group = "sentry_gun"
	self.tiger_machinegun_module.challenges.weapon = "sentry_gun"
	self.tiger_machinegun_module.suppression = 0.8

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.tiger_machinegun_module.DAMAGE = 3
		self.tiger_machinegun_module.CLIP_SIZE = 80
		self.tiger_machinegun_module.AUTO_RELOAD_DURATION = 4
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.tiger_machinegun_module.DAMAGE = 3
		self.tiger_machinegun_module.CLIP_SIZE = 80
		self.tiger_machinegun_module.AUTO_RELOAD_DURATION = 4
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.tiger_machinegun_module.DAMAGE = 3
		self.tiger_machinegun_module.CLIP_SIZE = 80
		self.tiger_machinegun_module.AUTO_RELOAD_DURATION = 4
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.tiger_machinegun_module.DAMAGE = 3
		self.tiger_machinegun_module.CLIP_SIZE = 80
		self.tiger_machinegun_module.AUTO_RELOAD_DURATION = 4
	end
end

function WeaponTweakData:_init_data_junker_machinegun_module_npc(difficulty_index)
	self.junker_machinegun_module = {}
	self.junker_machinegun_module.sounds = {}
	self.junker_machinegun_module.auto = {}
	self.junker_machinegun_module.name_id = "debug_sentry_gun"
	self.junker_machinegun_module.DAMAGE_MUL_RANGE = {
		{
			800,
			4
		},
		{
			1000,
			1.1
		},
		{
			1500,
			1
		}
	}
	self.junker_machinegun_module.SUPPRESSION = 1
	self.junker_machinegun_module.SPREAD = 0.1
	self.junker_machinegun_module.FIRE_RANGE = 42000
	self.junker_machinegun_module.AUTO_RELOAD = true
	self.junker_machinegun_module.ECM_HACKABLE = false
	self.junker_machinegun_module.HACKABLE_WITH_ECM = false
	self.junker_machinegun_module.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.junker_machinegun_module.muzzleflash = "effects/vanilla/weapons/big_762_auto"
	self.junker_machinegun_module.shell_ejection = "effects/vanilla/weapons/shells/shell_556_lmg"
	self.junker_machinegun_module.auto.fire_rate = 0.06
	self.junker_machinegun_module.alert_size = 100000
	self.junker_machinegun_module.headshot_dmg_mul = 4
	self.junker_machinegun_module.EXPLOSION_DMG_MUL = 7
	self.junker_machinegun_module.FIRE_DMG_MUL = 1
	self.junker_machinegun_module.BAG_DMG_MUL = 200
	self.junker_machinegun_module.SHIELD_DMG_MUL = 1
	self.junker_machinegun_module.HEALTH_INIT = 5000
	self.junker_machinegun_module.SHIELD_HEALTH_INIT = 1000
	self.junker_machinegun_module.SHIELD_DAMAGE_CLAMP = 75
	self.junker_machinegun_module.MAX_TARGETING_PITCH = 20
	self.junker_machinegun_module.MAX_TARGETING_SPIN = 10
	self.junker_machinegun_module.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.junker_machinegun_module.DETECTION_RANGE = self.junker_machinegun_module.FIRE_RANGE
	self.junker_machinegun_module.DETECTION_DELAY = {
		{
			0,
			0
		},
		{
			100000,
			0
		}
	}
	self.junker_machinegun_module.KEEP_FIRE_ANGLE = 30
	self.junker_machinegun_module.MAX_VEL_SPIN = 72
	self.junker_machinegun_module.MIN_VEL_SPIN = self.junker_machinegun_module.MAX_VEL_SPIN * 0.05
	self.junker_machinegun_module.SLOWDOWN_ANGLE_SPIN = 30
	self.junker_machinegun_module.ACC_SPIN = self.junker_machinegun_module.MAX_VEL_SPIN * 5
	self.junker_machinegun_module.MAX_VEL_PITCH = 60
	self.junker_machinegun_module.MIN_VEL_PITCH = self.junker_machinegun_module.MAX_VEL_PITCH * 0.05
	self.junker_machinegun_module.SLOWDOWN_ANGLE_PITCH = 20
	self.junker_machinegun_module.ACC_PITCH = self.junker_machinegun_module.MAX_VEL_PITCH * 5
	self.junker_machinegun_module.recoil = {}
	self.junker_machinegun_module.recoil.horizontal = {
		1,
		1.5,
		1,
		1
	}
	self.junker_machinegun_module.recoil.vertical = {
		1,
		1.5,
		1,
		1
	}
	self.junker_machinegun_module.challenges = {}
	self.junker_machinegun_module.challenges.group = "sentry_gun"
	self.junker_machinegun_module.challenges.weapon = "sentry_gun"
	self.junker_machinegun_module.suppression = 0.8

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.junker_machinegun_module.DAMAGE = 3
		self.junker_machinegun_module.CLIP_SIZE = 2000
		self.junker_machinegun_module.AUTO_RELOAD_DURATION = 0
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.junker_machinegun_module.DAMAGE = 3
		self.junker_machinegun_module.CLIP_SIZE = 2000
		self.junker_machinegun_module.AUTO_RELOAD_DURATION = 0
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.junker_machinegun_module.DAMAGE = 3
		self.junker_machinegun_module.CLIP_SIZE = 2000
		self.junker_machinegun_module.AUTO_RELOAD_DURATION = 0
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.junker_machinegun_module.DAMAGE = 3
		self.junker_machinegun_module.CLIP_SIZE = 2000
		self.junker_machinegun_module.AUTO_RELOAD_DURATION = 0
	end
end

function WeaponTweakData:_init_data_ger_luger_npc()
	self.ger_luger_npc = {}
	self.ger_luger_npc.sounds = {}
	self.ger_luger_npc.use_data = {}
	self.ger_luger_npc.usage = "ger_luger_npc"
	self.ger_luger_npc.usage_anim = "c45"
	self.ger_luger_npc.sounds.prefix = ""
	self.ger_luger_npc.sounds.single = "luger_fire_npc"
	self.ger_luger_npc.sounds.autofire_start = nil
	self.ger_luger_npc.sounds.autofire_stop = nil
	self.ger_luger_npc.use_data.selection_index = 1
	self.ger_luger_npc.DAMAGE = 2
	self.ger_luger_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.ger_luger_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.ger_luger_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.ger_luger_npc.CLIP_AMMO_MAX = 10
	self.ger_luger_npc.NR_CLIPS_MAX = 5
	self.ger_luger_npc.AMMO_MAX = self.ger_luger_npc.CLIP_AMMO_MAX * self.ger_luger_npc.NR_CLIPS_MAX
	self.ger_luger_npc.hold = "pistol"
	self.ger_luger_npc.alert_size = 5000
	self.ger_luger_npc.suppression = 1
end

function WeaponTweakData:_init_data_ger_stg44_npc()
	self.ger_stg44_npc = {}
	self.ger_stg44_npc.sounds = {}
	self.ger_stg44_npc.use_data = {}
	self.ger_stg44_npc.usage = "ger_stg44_npc"
	self.ger_stg44_npc.usage_anim = "m4"
	self.ger_stg44_npc.sounds.prefix = ""
	self.ger_stg44_npc.sounds.single = "stg44_fire_npc_single"
	self.ger_stg44_npc.sounds.autofire_start = "stg44_fire_npc"
	self.ger_stg44_npc.sounds.autofire_stop = "stg44_fire_npc_stop"
	self.ger_stg44_npc.use_data.selection_index = 2
	self.ger_stg44_npc.DAMAGE = 2
	self.ger_stg44_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.ger_stg44_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.ger_stg44_npc.CLIP_AMMO_MAX = 20
	self.ger_stg44_npc.NR_CLIPS_MAX = 5
	self.ger_stg44_npc.AMMO_MAX = self.ger_stg44_npc.CLIP_AMMO_MAX * self.ger_stg44_npc.NR_CLIPS_MAX
	self.ger_stg44_npc.auto = {}
	self.ger_stg44_npc.auto.fire_rate = 0.175
	self.ger_stg44_npc.hold = "rifle"
	self.ger_stg44_npc.alert_size = 5000
	self.ger_stg44_npc.suppression = 1
end

function WeaponTweakData:_init_data_usa_garand_npc()
	self.usa_garand_npc = {}
	self.usa_garand_npc.sounds = {}
	self.usa_garand_npc.use_data = {}
	self.usa_garand_npc.usage = "usa_garand_npc"
	self.usa_garand_npc.usage_anim = "m4"
	self.usa_garand_npc.sounds.prefix = ""
	self.usa_garand_npc.sounds.single = "m1garand_fire_npc"
	self.usa_garand_npc.sounds.autofire_start = nil
	self.usa_garand_npc.sounds.autofire_stop = nil
	self.usa_garand_npc.use_data.selection_index = 1
	self.usa_garand_npc.DAMAGE = 17
	self.usa_garand_npc.muzzleflash = "effects/vanilla/weapons/556_auto"
	self.usa_garand_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.usa_garand_npc.CLIP_AMMO_MAX = 10
	self.usa_garand_npc.NR_CLIPS_MAX = 8
	self.usa_garand_npc.AMMO_MAX = self.usa_garand_npc.CLIP_AMMO_MAX * self.usa_garand_npc.NR_CLIPS_MAX
	self.usa_garand_npc.hold = "rifle"
	self.usa_garand_npc.alert_size = 5000
	self.usa_garand_npc.suppression = 1
end

function WeaponTweakData:_init_data_usa_m1911_npc()
	self.usa_m1911_npc = {}
	self.usa_m1911_npc.sounds = {}
	self.usa_m1911_npc.use_data = {}
	self.usa_m1911_npc.usage = "usa_m1911_npc"
	self.usa_m1911_npc.usage_anim = "c45"
	self.usa_m1911_npc.sounds.prefix = ""
	self.usa_m1911_npc.sounds.single = "colt_m1911_fire_npc"
	self.usa_m1911_npc.sounds.autofire_start = nil
	self.usa_m1911_npc.sounds.autofire_stop = nil
	self.usa_m1911_npc.use_data.selection_index = 1
	self.usa_m1911_npc.DAMAGE = 17
	self.usa_m1911_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.usa_m1911_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.usa_m1911_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.usa_m1911_npc.CLIP_AMMO_MAX = 10
	self.usa_m1911_npc.NR_CLIPS_MAX = 5
	self.usa_m1911_npc.AMMO_MAX = self.usa_m1911_npc.CLIP_AMMO_MAX * self.usa_m1911_npc.NR_CLIPS_MAX
	self.usa_m1911_npc.hold = "pistol"
	self.usa_m1911_npc.alert_size = 5000
	self.usa_m1911_npc.suppression = 1
end

function WeaponTweakData:_init_data_thompson_npc()
	self.thompson_npc = {}
	self.thompson_npc.sounds = {}
	self.thompson_npc.use_data = {}
	self.thompson_npc.usage = "thompson_npc"
	self.thompson_npc.usage_anim = "mp5"
	self.thompson_npc.sounds.prefix = ""
	self.thompson_npc.sounds.single = "thompson_fire_npc_single"
	self.thompson_npc.sounds.autofire_start = "thompson_fire_npc"
	self.thompson_npc.sounds.autofire_stop = "thompson_fire_npc_stop"
	self.thompson_npc.use_data.selection_index = 1
	self.thompson_npc.DAMAGE = 17
	self.thompson_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.thompson_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.thompson_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.thompson_npc.CLIP_AMMO_MAX = 30
	self.thompson_npc.NR_CLIPS_MAX = 5
	self.thompson_npc.AMMO_MAX = self.thompson_npc.CLIP_AMMO_MAX * self.thompson_npc.NR_CLIPS_MAX
	self.thompson_npc.auto = {}
	self.thompson_npc.auto.fire_rate = 0.07
	self.thompson_npc.hold = "rifle"
	self.thompson_npc.husk_hold = "thompson"
	self.thompson_npc.alert_size = 5000
	self.thompson_npc.suppression = 1
end

function WeaponTweakData:_init_data_usa_sten_npc()
	self.usa_sten_npc = {}
	self.usa_sten_npc.sounds = {}
	self.usa_sten_npc.use_data = {}
	self.usa_sten_npc.usage = "mp5"
	self.usa_sten_npc.usage_anim = "mp5"
	self.sten_npc.sounds.prefix = ""
	self.sten_npc.sounds.single = "sten_fire_npc_single"
	self.sten_npc.sounds.autofire_start = "sten_fire_npc"
	self.sten_npc.sounds.autofire_stop = "sten_fire_npc_stop"
	self.usa_sten_npc.use_data.selection_index = 1
	self.usa_sten_npc.DAMAGE = 17
	self.usa_sten_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.usa_sten_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.usa_sten_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.usa_sten_npc.CLIP_AMMO_MAX = 30
	self.usa_sten_npc.NR_CLIPS_MAX = 5
	self.usa_sten_npc.AMMO_MAX = self.usa_sten_npc.CLIP_AMMO_MAX * self.usa_sten_npc.NR_CLIPS_MAX
	self.usa_sten_npc.auto = {}
	self.usa_sten_npc.auto.fire_rate = 0.125
	self.usa_sten_npc.hold = "rifle"
	self.usa_sten_npc.alert_size = 5000
	self.usa_sten_npc.suppression = 1
end

function WeaponTweakData:_init_data_ger_geco_npc()
	self.ger_geco_npc = {}
	self.ger_geco_npc.sounds = {}
	self.ger_geco_npc.use_data = {}
	self.ger_geco_npc.usage = "ger_geco_npc"
	self.ger_geco_npc.usage_anim = "ger_geco_npc"
	self.ger_geco_npc.FIRE_MODE = "single"
	self.ger_geco_npc.sounds.prefix = ""
	self.ger_geco_npc.sounds.single = "double_barrel_fire_npc_single"
	self.ger_geco_npc.use_data.selection_index = 2
	self.ger_geco_npc.DAMAGE = 3
	self.ger_geco_npc.muzzleflash = "effects/vanilla/weapons/762_auto"
	self.ger_geco_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.ger_geco_npc.CLIP_AMMO_MAX = 2
	self.ger_geco_npc.NR_CLIPS_MAX = 12
	self.ger_geco_npc.AMMO_MAX = self.ger_geco_npc.CLIP_AMMO_MAX * self.ger_geco_npc.NR_CLIPS_MAX
	self.ger_geco_npc.hold = "rifle"
	self.ger_geco_npc.alert_size = 5000
	self.ger_geco_npc.suppression = 1.8
	self.ger_geco_npc.is_shotgun = true
	self.ger_geco_npc.armor_piercing = true
end

function WeaponTweakData:_init_data_ger_mp38_npc()
	self.ger_mp38_npc = {}
	self.ger_mp38_npc.sounds = {}
	self.ger_mp38_npc.sounds.prefix = ""
	self.ger_mp38_npc.sounds.single = "mp38_fire_npc_single"
	self.ger_mp38_npc.sounds.autofire_start = "mp38_fire_npc"
	self.ger_mp38_npc.sounds.autofire_stop = "mp38_fire_npc_stop"
	self.ger_mp38_npc.use_data = {}
	self.ger_mp38_npc.usage = "ger_mp38_npc"
	self.ger_mp38_npc.usage_anim = "mp5"
	self.ger_mp38_npc.FIRE_MODE = "auto"
	self.ger_mp38_npc.sounds.prefix = ""
	self.ger_mp38_npc.use_data.selection_index = 2
	self.ger_mp38_npc.DAMAGE = 2
	self.ger_mp38_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.ger_mp38_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.ger_mp38_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.ger_mp38_npc.CLIP_AMMO_MAX = 30
	self.ger_mp38_npc.NR_CLIPS_MAX = 5
	self.ger_mp38_npc.AMMO_MAX = self.ger_mp38_npc.CLIP_AMMO_MAX * self.ger_mp38_npc.NR_CLIPS_MAX
	self.ger_mp38_npc.auto = {}
	self.ger_mp38_npc.auto.fire_rate = 0.12
	self.ger_mp38_npc.hold = "rifle"
	self.ger_mp38_npc.alert_size = 5000
	self.ger_mp38_npc.suppression = 1
end

function WeaponTweakData:_init_data_carbine_npc()
	self.carbine_npc = {}
	self.carbine_npc.sounds = {}
	self.carbine_npc.use_data = {}
	self.carbine_npc.usage = "carbine"
	self.carbine_npc.usage_anim = "carbine"
	self.carbine_npc.sounds.prefix = ""
	self.carbine_npc.sounds.single = "m1_carbine_fire_npc"
	self.carbine_npc.use_data.selection_index = 2
	self.carbine_npc.DAMAGE = 1.5
	self.carbine_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.carbine_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.carbine_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.carbine_npc.CLIP_AMMO_MAX = 15
	self.carbine_npc.NR_CLIPS_MAX = 10
	self.carbine_npc.AMMO_MAX = self.carbine_npc.CLIP_AMMO_MAX * self.carbine_npc.NR_CLIPS_MAX
	self.carbine_npc.auto = {}
	self.carbine_npc.auto.fire_rate = 0.2
	self.carbine_npc.hold = "carbine"
	self.carbine_npc.alert_size = 5000
	self.carbine_npc.suppression = 1
end

function WeaponTweakData:_init_data_kar98_npc()
	self.ger_kar98_npc = {}
	self.ger_kar98_npc.sounds = {}
	self.ger_kar98_npc.use_data = {}
	self.ger_kar98_npc.usage = "ger_kar98_npc"
	self.ger_kar98_npc.usage_anim = "ger_kar98_npc"
	self.ger_kar98_npc.sounds.prefix = ""
	self.ger_kar98_npc.sounds.single = "kar98_fire_npc_single"
	self.ger_kar98_npc.use_data.selection_index = 2
	self.ger_kar98_npc.DAMAGE = 3
	self.ger_kar98_npc.muzzleflash = "effects/vanilla/weapons/762_auto"
	self.ger_kar98_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.ger_kar98_npc.CLIP_AMMO_MAX = 1
	self.ger_kar98_npc.NR_CLIPS_MAX = 50
	self.ger_kar98_npc.AMMO_MAX = self.ger_kar98_npc.CLIP_AMMO_MAX * self.ger_kar98_npc.NR_CLIPS_MAX
	self.ger_kar98_npc.hold = "rifle"
	self.ger_kar98_npc.alert_size = 5000
	self.ger_kar98_npc.suppression = 1
	self.ger_kar98_npc.armor_piercing = true
end

function WeaponTweakData:_init_data_sniper_kar98_npc()
	self.sniper_kar98_npc = {}
	self.sniper_kar98_npc.sounds = {}
	self.sniper_kar98_npc.use_data = {}
	self.sniper_kar98_npc.usage = "ger_kar98_npc"
	self.sniper_kar98_npc.usage_anim = "m4"
	self.sniper_kar98_npc.sounds.prefix = ""
	self.sniper_kar98_npc.sounds.single = "sniper_enemy_fire"
	self.sniper_kar98_npc.use_data.selection_index = 2
	self.sniper_kar98_npc.DAMAGE = 9
	self.sniper_kar98_npc.muzzleflash = "effects/vanilla/weapons/762_auto"
	self.sniper_kar98_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.sniper_kar98_npc.CLIP_AMMO_MAX = 1
	self.sniper_kar98_npc.NR_CLIPS_MAX = 50
	self.sniper_kar98_npc.AMMO_MAX = self.sniper_kar98_npc.CLIP_AMMO_MAX * self.sniper_kar98_npc.NR_CLIPS_MAX
	self.sniper_kar98_npc.hold = "rifle"
	self.sniper_kar98_npc.alert_size = 5000
	self.sniper_kar98_npc.suppression = 1
	self.sniper_kar98_npc.armor_piercing = true
end

function WeaponTweakData:_init_data_spotting_optics_npc()
	self.spotting_optics_npc = {}
	self.spotting_optics_npc.sounds = {}
	self.spotting_optics_npc.use_data = {}
	self.spotting_optics_npc.usage = "ger_stg44_npc"
	self.spotting_optics_npc.usage_anim = "m4"
	self.spotting_optics_npc.sounds.prefix = ""
	self.spotting_optics_npc.use_data.selection_index = 2
	self.spotting_optics_npc.DAMAGE = 0
	self.spotting_optics_npc.muzzleflash = ""
	self.spotting_optics_npc.shell_ejection = ""
	self.spotting_optics_npc.CLIP_AMMO_MAX = 100
	self.spotting_optics_npc.NR_CLIPS_MAX = 10000
	self.spotting_optics_npc.AMMO_MAX = self.spotting_optics_npc.CLIP_AMMO_MAX * self.spotting_optics_npc.NR_CLIPS_MAX
	self.spotting_optics_npc.hold = "pistol"
	self.spotting_optics_npc.alert_size = 5000
	self.spotting_optics_npc.suppression = 1
	self.spotting_optics_npc.armor_piercing = true
end

function WeaponTweakData:_init_data_m42_flammenwerfer_npc(difficulty_index)
	self.m42_flammenwerfer_npc = {}
	self.m42_flammenwerfer_npc.sounds = {}
	self.m42_flammenwerfer_npc.use_data = {}
	self.m42_flammenwerfer_npc.usage = "ak47"
	self.m42_flammenwerfer_npc.usage_anim = "ak47"
	self.m42_flammenwerfer_npc.sounds.prefix = ""
	self.m42_flammenwerfer_npc.sounds.single = ""
	self.m42_flammenwerfer_npc.sounds.autofire_start = "flamethrower_fire_npc"
	self.m42_flammenwerfer_npc.sounds.autofire_stop = "flamethrower_stop_npc"
	self.m42_flammenwerfer_npc.no_whizby = true
	self.m42_flammenwerfer_npc.use_data.selection_index = 2
	self.m42_flammenwerfer_npc.fire_dot_data = {
		dot_trigger_chance = 10,
		dot_damage = 1,
		dot_length = 3.1,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}
	self.m42_flammenwerfer_npc.muzzleflash = "effects/vanilla/weapons/9mm_auto"
	self.m42_flammenwerfer_npc.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence"
	self.m42_flammenwerfer_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.m42_flammenwerfer_npc.CLIP_AMMO_MAX = 100000
	self.m42_flammenwerfer_npc.NR_CLIPS_MAX = 1
	self.m42_flammenwerfer_npc.AMMO_MAX = self.m42_flammenwerfer_npc.CLIP_AMMO_MAX * self.m42_flammenwerfer_npc.NR_CLIPS_MAX
	self.m42_flammenwerfer_npc.hold = "rifle"
	self.m42_flammenwerfer_npc.auto = {}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.m42_flammenwerfer_npc.auto.fire_rate = 0.2
		self.m42_flammenwerfer_npc.DAMAGE = 2.5
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.m42_flammenwerfer_npc.auto.fire_rate = 0.15
		self.m42_flammenwerfer_npc.DAMAGE = 2.5
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.m42_flammenwerfer_npc.auto.fire_rate = 0.125
		self.m42_flammenwerfer_npc.DAMAGE = 3
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.m42_flammenwerfer_npc.auto.fire_rate = 0.1
		self.m42_flammenwerfer_npc.DAMAGE = 3.5
	end

	self.m42_flammenwerfer_npc.hud_icon = "rifle"
	self.m42_flammenwerfer_npc.alert_size = 5000
	self.m42_flammenwerfer_npc.suppression = 0.45
end

function WeaponTweakData:_init_data_panzerfaust_60_npc()
	self.panzerfaust_60_npc = {}
	self.panzerfaust_60_npc.sounds = {}
	self.panzerfaust_60_npc.use_data = {}
	self.panzerfaust_60_npc.usage = "ak47"
	self.panzerfaust_60_npc.usage_anim = "ak47"
	self.panzerfaust_60_npc.sounds.prefix = ""
	self.panzerfaust_60_npc.sounds.fire = "rpg_fire"
	self.panzerfaust_60_npc.sounds.stop_fire = ""
	self.panzerfaust_60_npc.use_data.selection_index = 2
	self.panzerfaust_60_npc.DAMAGE = 6
	self.panzerfaust_60_npc.damage_falloff_near = 1000
	self.panzerfaust_60_npc.damage_falloff_far = 2000
	self.panzerfaust_60_npc.rays = 6
	self.panzerfaust_60_npc.muzzleflash = "effects/vanilla/weapons/50cal_auto_fps"
	self.panzerfaust_60_npc.muzzleflash_silenced = nil
	self.panzerfaust_60_npc.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.panzerfaust_60_npc.CLIP_AMMO_MAX = 1
	self.panzerfaust_60_npc.NR_CLIPS_MAX = 5
	self.panzerfaust_60_npc.AMMO_MAX = self.panzerfaust_60_npc.CLIP_AMMO_MAX * self.panzerfaust_60_npc.NR_CLIPS_MAX
	self.panzerfaust_60_npc.hold = "rifle"
	self.panzerfaust_60_npc.hud_icon = "rifle"
	self.panzerfaust_60_npc.alert_size = 25000
	self.panzerfaust_60_npc.suppression = 2
end

function WeaponTweakData:_init_data_player_weapons(tweak_data)
	local autohit_rifle_default, autohit_pistol_default, autohit_shotgun_default, autohit_lmg_default, autohit_snp_default, autohit_smg_default, autohit_minigun_default, aim_assist_rifle_default, aim_assist_pistol_default, aim_assist_shotgun_default, aim_assist_lmg_default, aim_assist_snp_default, aim_assist_smg_default, aim_assist_minigun_default

	if _G.IS_PC then
		autohit_rifle_default = {
			INIT_RATIO = 0.15,
			MAX_RATIO = 0.85,
			far_angle = 1,
			far_dis = 4000,
			MIN_RATIO = 0.75,
			near_angle = 3
		}
		autohit_pistol_default = {
			INIT_RATIO = 0.15,
			MAX_RATIO = 0.95,
			far_angle = 0.5,
			far_dis = 4000,
			MIN_RATIO = 0.82,
			near_angle = 3
		}
		autohit_shotgun_default = {
			INIT_RATIO = 0.15,
			MAX_RATIO = 0.7,
			far_angle = 1.5,
			far_dis = 5000,
			MIN_RATIO = 0.6,
			near_angle = 3
		}
		autohit_lmg_default = {
			INIT_RATIO = 0.05,
			MAX_RATIO = 0.4,
			far_angle = 0.2,
			far_dis = 2000,
			MIN_RATIO = 0.2,
			near_angle = 2
		}
		autohit_snp_default = {
			INIT_RATIO = 0.05,
			MAX_RATIO = 0.4,
			far_angle = 0.2,
			far_dis = 5000,
			MIN_RATIO = 0.2,
			near_angle = 2
		}
		autohit_smg_default = {
			INIT_RATIO = 0.05,
			MAX_RATIO = 0.4,
			far_angle = 0.5,
			far_dis = 2500,
			MIN_RATIO = 0.2,
			near_angle = 4
		}
		autohit_minigun_default = {
			INIT_RATIO = 1,
			MAX_RATIO = 1,
			far_angle = 0.0005,
			far_dis = 10000,
			MIN_RATIO = 0,
			near_angle = 0.0005
		}
	else
		autohit_rifle_default = {
			INIT_RATIO = 0.6,
			MAX_RATIO = 0.6,
			far_angle = 3,
			far_dis = 5000,
			MIN_RATIO = 0.25,
			near_angle = 3
		}
		autohit_pistol_default = {
			INIT_RATIO = 0.6,
			MAX_RATIO = 0.6,
			far_angle = 3,
			far_dis = 2500,
			MIN_RATIO = 0.25,
			near_angle = 3
		}
		autohit_shotgun_default = {
			INIT_RATIO = 0.3,
			MAX_RATIO = 0.3,
			far_angle = 5,
			far_dis = 5000,
			MIN_RATIO = 0.15,
			near_angle = 3
		}
		autohit_lmg_default = {
			INIT_RATIO = 0.6,
			MAX_RATIO = 0.6,
			far_angle = 3,
			far_dis = 5000,
			MIN_RATIO = 0.25,
			near_angle = 3
		}
		autohit_snp_default = {
			INIT_RATIO = 0.6,
			MAX_RATIO = 0.6,
			far_angle = 3,
			far_dis = 5000,
			MIN_RATIO = 0.25,
			near_angle = 3
		}
		autohit_smg_default = {
			INIT_RATIO = 0.6,
			MAX_RATIO = 0.6,
			far_angle = 3,
			far_dis = 5000,
			MIN_RATIO = 0.25,
			near_angle = 3
		}
		autohit_minigun_default = {
			INIT_RATIO = 1,
			MAX_RATIO = 1,
			far_angle = 0.0005,
			far_dis = 10000,
			MIN_RATIO = 0,
			near_angle = 0.0005
		}
	end

	aim_assist_rifle_default = deep_clone(autohit_rifle_default)
	aim_assist_pistol_default = deep_clone(autohit_pistol_default)
	aim_assist_shotgun_default = deep_clone(autohit_shotgun_default)
	aim_assist_lmg_default = deep_clone(autohit_lmg_default)
	aim_assist_snp_default = deep_clone(autohit_snp_default)
	aim_assist_smg_default = deep_clone(autohit_smg_default)
	aim_assist_minigun_default = deep_clone(autohit_minigun_default)
	aim_assist_rifle_default.near_angle = 20
	aim_assist_pistol_default.near_angle = 15
	aim_assist_shotgun_default.near_angle = 20
	aim_assist_lmg_default.near_angle = 8
	aim_assist_snp_default.near_angle = 10
	aim_assist_smg_default.near_angle = 14
	self.crosshair = {}
	self.crosshair.MIN_OFFSET = 18
	self.crosshair.MAX_OFFSET = 150
	self.crosshair.MIN_KICK_OFFSET = 0
	self.crosshair.MAX_KICK_OFFSET = 100
	self.crosshair.DEFAULT_OFFSET = 0.16
	self.crosshair.DEFAULT_KICK_OFFSET = 0.6

	local damage_melee_default = 1
	local damage_melee_effect_multiplier_default = 0

	self.trip_mines = {}
	self.trip_mines.delay = 0.3
	self.trip_mines.damage = 100
	self.trip_mines.player_damage = 6
	self.trip_mines.damage_size = 300
	self.trip_mines.alert_radius = 5000

	self:_init_stats()

	self.factory = WeaponFactoryTweakData:new()

	local autohit_data = {
		autohit_rifle_default = autohit_rifle_default,
		autohit_pistol_default = autohit_pistol_default,
		autohit_shotgun_default = autohit_shotgun_default,
		autohit_lmg_default = autohit_lmg_default,
		autohit_snp_default = autohit_snp_default,
		autohit_smg_default = autohit_smg_default,
		autohit_minigun_default = autohit_minigun_default,
		damage_melee_default = damage_melee_default,
		damage_melee_effect_multiplier_default = damage_melee_effect_multiplier_default,
		aim_assist_rifle_default = aim_assist_rifle_default,
		aim_assist_pistol_default = aim_assist_pistol_default,
		aim_assist_shotgun_default = aim_assist_shotgun_default,
		aim_assist_lmg_default = aim_assist_lmg_default,
		aim_assist_snp_default = aim_assist_snp_default,
		aim_assist_smg_default = aim_assist_smg_default,
		aim_assist_minigun_default = aim_assist_minigun_default
	}

	self:_init_new_weapons(autohit_data)
	self:_collect_all_fps_animation_weights()
end

function WeaponTweakData:_collect_all_fps_animation_weights()
	self._all_fps_animation_weights = {}

	for weapon_part_name, weapon_part_data in pairs(self.factory.parts) do
		if weapon_part_data and weapon_part_data.fps_animation_weight then
			table.insert(self._all_fps_animation_weights, weapon_part_data.fps_animation_weight)
		end
	end
end

function WeaponTweakData:_init_data_turrets()
	self.turret_m2 = {}
	self.turret_m2.heat_material = "blinn2"
	self.turret_m2.heat_material_parameter = "intensity"
	self.turret_m2.announce_shooting_cooldown = {
		5,
		15
	}
	self.turret_m2.dazed_duration = 0.5
	self.turret_m2.overheat_time = 3.5
	self.turret_m2.shaker_multiplier = 0.8
	self.turret_m2.dismember_chance = 0.15
	self.turret_m2.rate_of_fire = 900
	self.turret_m2.exit_turret_speed = 1
	self.turret_m2.camera_limit_horizontal = 65
	self.turret_m2.camera_limit_vertical = 45
	self.turret_m2.fire_range = 30000
	self.turret_m2.damage = 76
	self.turret_m2.sound_fire_start = "mg42_fire_npc"
	self.turret_m2.sound_fire_stop = "mg42_fire_npc_stop"
	self.turret_m2.sound_fire_start_fps = "mg42_fire_1p"
	self.turret_m2.sound_fire_stop_fps = "mg42_fire_1p_stop"
	self.turret_m2.fire_type = "auto"
	self.turret_m2.number_of_barrels = 1
	self.turret_m2.anim_enter = "e_so_mg34_enter"
	self.turret_m2.anim_exit = "e_so_mg34_exit"
	self.turret_m2.puppet_stance = "standing"
	self.turret_m2.abandon_proximity = 2000
	self.turret_m2.abandon_proximity_visible_mul = 0.075
	self.turret_m2.puppet_damage_multiplier = 1.25
	self.turret_m2.use_dof = true
	self.turret_m2.shell_ejection_effect = "effects/vanilla/weapons/shells/shell_556"
	self.turret_m2.muzzle_effect = "effects/vanilla/weapons/m2_3dp"
	self.turret_m2.usable_by_npc = true
	self.turret_m2.can_shoot_at_AI = false
	self.turret_m2.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 32,
		alert_size = 7,
		spread = 2,
		spread_moving = 7,
		recoil = 7,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 20
	}
	self.turret_m2.WAIT_FOR_TARGET = 2
	self.turret_m2.DAMAGE = 2
	self.turret_m2.DAMAGE_MUL_RANGE = {
		{
			3000,
			1
		},
		{
			7500,
			0.65
		},
		{
			10000,
			0.35
		},
		{
			20000,
			0.1
		}
	}
	self.turret_m2.SUPPRESSION = 1
	self.turret_m2.SPREAD = 0.3
	self.turret_m2.FIRE_RANGE = 20000
	self.turret_m2.CLIP_SIZE = 1
	self.turret_m2.AUTO_RELOAD = true
	self.turret_m2.AUTO_RELOAD_DURATION = 5
	self.turret_m2.ECM_HACKABLE = false
	self.turret_m2.HACKABLE_WITH_ECM = false
	self.turret_m2.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.5
	}
	self.turret_m2.headshot_dmg_mul = 1.5
	self.turret_m2.EXPLOSION_DMG_MUL = 7
	self.turret_m2.FIRE_DMG_MUL = 1
	self.turret_m2.BAG_DMG_MUL = 200
	self.turret_m2.SHIELD_DMG_MUL = 1
	self.turret_m2.HEALTH_INIT = 5000
	self.turret_m2.SHIELD_HEALTH_INIT = 1000
	self.turret_m2.SHIELD_DAMAGE_CLAMP = 10000
	self.turret_m2.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.turret_m2.DETECTION_RANGE = self.turret_m2.FIRE_RANGE
	self.turret_m2.DETECTION_DELAY = {
		{
			900,
			0.15
		},
		{
			3500,
			0.35
		}
	}
	self.turret_m2.KEEP_FIRE_ANGLE = 0.99
	self.turret_m2.MAX_VEL_SPIN = 90
	self.turret_m2.MIN_VEL_SPIN = self.turret_m2.MAX_VEL_SPIN * 0.1
	self.turret_m2.SLOWDOWN_ANGLE_SPIN = 5
	self.turret_m2.ACC_SPIN = self.turret_m2.MAX_VEL_SPIN * 5
	self.turret_m2.MAX_VEL_PITCH = 15
	self.turret_m2.MIN_VEL_PITCH = self.turret_m2.MAX_VEL_PITCH * 0.05
	self.turret_m2.SLOWDOWN_ANGLE_PITCH = 5
	self.turret_m2.ACC_PITCH = self.turret_m2.MAX_VEL_PITCH * 5
	self.turret_m2.MIN_PITCH_ANGLE = -30
	self.turret_m2.MAX_PITCH_ANGLE = 30
	self.turret_m2.MAX_TARGETING_PITCH = self.turret_m2.MAX_PITCH_ANGLE
	self.turret_m2.MAX_TARGETING_SPIN = 45
	self.turret_m2.hud = {}
	self.turret_m2.hud.reticle = "weapons_reticles_smg_thompson"
	self.turret_flak_88 = {}
	self.turret_flak_88.name = "turret_flak_88"
	self.turret_flak_88.dazed_duration = 0.5
	self.turret_flak_88.shaker_multiplier = 0.5
	self.turret_flak_88.dismember_chance = 1
	self.turret_flak_88.rate_of_fire = 60
	self.turret_flak_88.exit_turret_speed = 1
	self.turret_flak_88.camera_limit_horizontal = 55
	self.turret_flak_88.camera_limit_vertical = 30
	self.turret_flak_88.camera_limit_vertical_mid = 20
	self.turret_flak_88.fire_range = 60000
	self.turret_flak_88.damage = 1200
	self.turret_flak_88.damage_radius = 500
	self.turret_flak_88.sound_fire_start = "flak88_fire"
	self.turret_flak_88.fire_type = "auto"
	self.turret_flak_88.number_of_barrels = 1
	self.turret_flak_88.anim_enter = "e_so_flak_88_sit_enter"
	self.turret_flak_88.anim_exit = "e_so_flak_88_sit_exit"
	self.turret_flak_88.puppet_stance = "sitting"
	self.turret_flak_88.abandon_proximity = 500
	self.turret_flak_88.puppet_damage_multiplier = 1
	self.turret_flak_88.bullet_type = "shell"
	self.turret_flak_88.armor_piercing = true
	self.turret_flak_88.use_dof = true
	self.turret_flak_88.shell_ejection_effect = nil
	self.turret_flak_88.muzzle_effect = "effects/vanilla/explosions/flak_88_fire_explosion"
	self.turret_flak_88.turret_rotation_deadzone = 30
	self.turret_flak_88.turret_rotation_speed = 30
	self.turret_flak_88.sound_movement_start = "aa_gun_movement_loop_start"
	self.turret_flak_88.sound_movement_stop = "aa_gun_movement_loop_stop"
	self.turret_flak_88.usable_by_npc = false
	self.turret_flak_88.can_shoot_at_AI = false
	self.turret_flak_88.hud = {}
	self.turret_flak_88.hud.reticle = "weapons_reticles_smg_thompson"
	self.turret_flak_88.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 10,
		alert_size = 7,
		spread = 3,
		spread_moving = 7,
		recoil = 7,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 20
	}
	self.turret_flak_88.WAIT_FOR_TARGET = 2
	self.turret_flak_88.DAMAGE = 50
	self.turret_flak_88.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			1500,
			1
		}
	}
	self.turret_flak_88.SUPPRESSION = 1
	self.turret_flak_88.SPREAD = 0.2
	self.turret_flak_88.FIRE_RANGE = 100000
	self.turret_flak_88.CLIP_SIZE = 1
	self.turret_flak_88.AUTO_RELOAD = true
	self.turret_flak_88.AUTO_RELOAD_DURATION = 5
	self.turret_flak_88.ECM_HACKABLE = false
	self.turret_flak_88.HACKABLE_WITH_ECM = false
	self.turret_flak_88.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.turret_flak_88.headshot_dmg_mul = 4
	self.turret_flak_88.EXPLOSION_DMG_MUL = 7
	self.turret_flak_88.FIRE_DMG_MUL = 1
	self.turret_flak_88.BAG_DMG_MUL = 200
	self.turret_flak_88.SHIELD_DMG_MUL = 1
	self.turret_flak_88.HEALTH_INIT = 5000
	self.turret_flak_88.SHIELD_HEALTH_INIT = 1000
	self.turret_flak_88.SHIELD_DAMAGE_CLAMP = 10000
	self.turret_flak_88.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.turret_flak_88.DETECTION_RANGE = self.turret_flak_88.FIRE_RANGE
	self.turret_flak_88.DETECTION_DELAY = {
		{
			900,
			0.3
		},
		{
			3500,
			1.5
		}
	}
	self.turret_flak_88.KEEP_FIRE_ANGLE = 0.99
	self.turret_flak_88.MAX_VEL_SPIN = 100
	self.turret_flak_88.MIN_VEL_SPIN = self.turret_flak_88.MAX_VEL_SPIN * 0.1
	self.turret_flak_88.SLOWDOWN_ANGLE_SPIN = 5
	self.turret_flak_88.ACC_SPIN = self.turret_flak_88.MAX_VEL_SPIN * 5
	self.turret_flak_88.MAX_VEL_PITCH = 10
	self.turret_flak_88.MIN_VEL_PITCH = self.turret_flak_88.MAX_VEL_PITCH * 0.05
	self.turret_flak_88.SLOWDOWN_ANGLE_PITCH = 5
	self.turret_flak_88.ACC_PITCH = self.turret_flak_88.MAX_VEL_PITCH * 5
	self.turret_flak_88.MAX_PITCH_ANGLE = 70
	self.turret_flak_88.MIN_PITCH_ANGLE = -14
	self.turret_flakvierling = {}
	self.turret_flakvierling.heat_material = "mat_heat"
	self.turret_flakvierling.heat_material_parameter = "intensity"
	self.turret_flakvierling.dazed_duration = 3
	self.turret_flakvierling.overheat_time = 10
	self.turret_flakvierling.shaker_multiplier = 0.75
	self.turret_flakvierling.dismember_chance = 1
	self.turret_flakvierling.rate_of_fire = 450
	self.turret_flakvierling.exit_turret_speed = 1
	self.turret_flakvierling.camera_limit_horizontal = 360
	self.turret_flakvierling.camera_limit_vertical_mid = 30
	self.turret_flakvierling.camera_limit_vertical = 45
	self.turret_flakvierling.camera_speed_limit = 1.8
	self.turret_flakvierling.fire_range = 1000000
	self.turret_flakvierling.damage = 150
	self.turret_flakvierling.sound_fire_start = "aa_gun"
	self.turret_flakvierling.sound_fire_stop = "aa_gun_stop"
	self.turret_flakvierling.sound_movement_start = "aa_gun_movement_loop_start"
	self.turret_flakvierling.sound_movement_stop = "aa_gun_movement_loop_stop"
	self.turret_flakvierling.fire_type = "auto"
	self.turret_flakvierling.number_of_barrels = 4
	self.turret_flakvierling.anim_enter = "ntl_enter_flakvierling"
	self.turret_flakvierling.anim_exit = "ntl_exit_flakvierling"
	self.turret_flakvierling.puppet_stance = "sitting"
	self.turret_flakvierling.use_dof = false
	self.turret_flakvierling.shell_ejection_effect = nil
	self.turret_flakvierling.muzzle_effect = "effects/vanilla/weapons/mg_34_3dp"
	self.turret_flakvierling.usable_by_npc = false
	self.turret_flakvierling.can_shoot_at_AI = false
	self.turret_flakvierling.WAIT_FOR_TARGET = 2
	self.turret_flakvierling.DAMAGE = 10
	self.turret_flakvierling.DAMAGE_MUL_RANGE = {
		{
			1200,
			1
		},
		{
			1500,
			1
		},
		{
			3000,
			1
		}
	}
	self.turret_flakvierling.SUPPRESSION = 1
	self.turret_flakvierling.SPREAD = 0.2
	self.turret_flakvierling.FIRE_RANGE = 500000
	self.turret_flakvierling.CLIP_SIZE = 1
	self.turret_flakvierling.AUTO_RELOAD = true
	self.turret_flakvierling.AUTO_RELOAD_DURATION = 5
	self.turret_flakvierling.ECM_HACKABLE = false
	self.turret_flakvierling.HACKABLE_WITH_ECM = false
	self.turret_flakvierling.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.turret_flakvierling.headshot_dmg_mul = 4
	self.turret_flakvierling.EXPLOSION_DMG_MUL = 7
	self.turret_flakvierling.FIRE_DMG_MUL = 1
	self.turret_flakvierling.BAG_DMG_MUL = 200
	self.turret_flakvierling.SHIELD_DMG_MUL = 1
	self.turret_flakvierling.HEALTH_INIT = 5000
	self.turret_flakvierling.SHIELD_HEALTH_INIT = 1000
	self.turret_flakvierling.SHIELD_DAMAGE_CLAMP = 10000
	self.turret_flakvierling.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.turret_flakvierling.DETECTION_RANGE = self.turret_flakvierling.FIRE_RANGE
	self.turret_flakvierling.DETECTION_DELAY = {
		{
			900,
			0.3
		},
		{
			3500,
			1.5
		}
	}
	self.turret_flakvierling.KEEP_FIRE_ANGLE = 0.99
	self.turret_flakvierling.MAX_VEL_SPIN = 100
	self.turret_flakvierling.MIN_VEL_SPIN = self.turret_flakvierling.MAX_VEL_SPIN * 0.1
	self.turret_flakvierling.SLOWDOWN_ANGLE_SPIN = 5
	self.turret_flakvierling.ACC_SPIN = self.turret_flakvierling.MAX_VEL_SPIN * 5
	self.turret_flakvierling.MAX_VEL_PITCH = 10
	self.turret_flakvierling.MIN_VEL_PITCH = self.turret_flakvierling.MAX_VEL_PITCH * 0.05
	self.turret_flakvierling.SLOWDOWN_ANGLE_PITCH = 5
	self.turret_flakvierling.ACC_PITCH = self.turret_flakvierling.MAX_VEL_PITCH * 5
	self.turret_flakvierling.MAX_PITCH_ANGLE = 73.67
	self.turret_flakvierling.MIN_PITCH_ANGLE = -13.67
	self.turret_flakvierling.hud = {}
	self.turret_flakvierling.hud.reticle = "weapons_reticles_ass_garand"
	self.turret_flakvierling.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 10,
		alert_size = 7,
		spread = 7,
		spread_moving = 7,
		recoil = 7,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 20
	}
	self.turret_flak_20mm = {}
	self.turret_flak_20mm.dazed_duration = 3
	self.turret_flak_20mm.overheat_time = 5
	self.turret_flak_20mm.shaker_multiplier = 0.5
	self.turret_flak_20mm.dismember_chance = 1
	self.turret_flak_20mm.rate_of_fire = 800
	self.turret_flak_20mm.exit_turret_speed = 1
	self.turret_flak_20mm.camera_limit_horizontal = 360
	self.turret_flak_20mm.camera_limit_vertical_mid = 35
	self.turret_flak_20mm.camera_limit_vertical = 35
	self.turret_flak_20mm.camera_speed_limit = 0.5
	self.turret_flak_20mm.fire_range = 1000000
	self.turret_flak_20mm.damage = 50
	self.turret_flak_20mm.sound_fire_start = "aa_gun"
	self.turret_flak_20mm.sound_fire_stop = "aa_gun_stop"
	self.turret_flak_20mm.sound_movement_start = "aa_gun_movement_loop_start"
	self.turret_flak_20mm.sound_movement_stop = "aa_gun_movement_loop_stop"
	self.turret_flak_20mm.fire_type = "auto"
	self.turret_flak_20mm.number_of_barrels = 4
	self.turret_flak_20mm.anim_enter = "ntl_enter_flakvierling"
	self.turret_flak_20mm.puppet_stance = "sitting"
	self.turret_flak_20mm.WAIT_FOR_TARGET = 2
	self.turret_flak_20mm.DAMAGE = 5
	self.turret_flak_20mm.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			1500,
			1
		}
	}
	self.turret_flak_20mm.SUPPRESSION = 1
	self.turret_flak_20mm.SPREAD = 0.2
	self.turret_flak_20mm.FIRE_RANGE = 500000
	self.turret_flak_20mm.CLIP_SIZE = 1
	self.turret_flak_20mm.AUTO_RELOAD = true
	self.turret_flak_20mm.AUTO_RELOAD_DURATION = 5
	self.turret_flak_20mm.ECM_HACKABLE = false
	self.turret_flak_20mm.HACKABLE_WITH_ECM = false
	self.turret_flak_20mm.VELOCITY_COMPENSATION = {
		OVERCOMPENSATION = 50,
		SNAPSHOT_INTERVAL = 0.3
	}
	self.turret_flak_20mm.headshot_dmg_mul = 4
	self.turret_flak_20mm.EXPLOSION_DMG_MUL = 7
	self.turret_flak_20mm.FIRE_DMG_MUL = 1
	self.turret_flak_20mm.BAG_DMG_MUL = 200
	self.turret_flak_20mm.SHIELD_DMG_MUL = 1
	self.turret_flak_20mm.HEALTH_INIT = 5000
	self.turret_flak_20mm.SHIELD_HEALTH_INIT = 1000
	self.turret_flak_20mm.SHIELD_DAMAGE_CLAMP = 10000
	self.turret_flak_20mm.DEATH_VERIFICATION = {
		0.4,
		0.75
	}
	self.turret_flak_20mm.DETECTION_RANGE = self.turret_flak_20mm.FIRE_RANGE
	self.turret_flak_20mm.DETECTION_DELAY = {
		{
			900,
			0.3
		},
		{
			3500,
			1.5
		}
	}
	self.turret_flak_20mm.KEEP_FIRE_ANGLE = 0.99
	self.turret_flak_20mm.MAX_VEL_SPIN = 100
	self.turret_flak_20mm.MIN_VEL_SPIN = self.turret_flak_20mm.MAX_VEL_SPIN * 0.1
	self.turret_flak_20mm.SLOWDOWN_ANGLE_SPIN = 5
	self.turret_flak_20mm.ACC_SPIN = self.turret_flak_20mm.MAX_VEL_SPIN * 5
	self.turret_flak_20mm.MAX_VEL_PITCH = 10
	self.turret_flak_20mm.MIN_VEL_PITCH = self.turret_flak_20mm.MAX_VEL_PITCH * 0.05
	self.turret_flak_20mm.SLOWDOWN_ANGLE_PITCH = 5
	self.turret_flak_20mm.ACC_PITCH = self.turret_flak_20mm.MAX_VEL_PITCH * 5
	self.turret_flak_20mm.MAX_PITCH_ANGLE = 70
	self.turret_flak_20mm.MIN_PITCH_ANGLE = 0
	self.turret_flak_20mm.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 10,
		alert_size = 7,
		spread = 7,
		spread_moving = 7,
		recoil = 7,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 20
	}
end

function WeaponTweakData:_init_stats()
	self.stats = {}
	self.stats.alert_size = {
		30000,
		20000,
		15000,
		10000,
		7500,
		6000,
		4500,
		4000,
		3500,
		1800,
		1500,
		1200,
		1000,
		850,
		700,
		500,
		350,
		200,
		100,
		0
	}
	self.stats.suppression = {
		4.5,
		3.9,
		3.6,
		3.3,
		3,
		2.8,
		2.6,
		2.4,
		2.2,
		1.6,
		1.5,
		1.4,
		1.3,
		1.2,
		1.1,
		1,
		0.8,
		0.6,
		0.4,
		0.2
	}
	self.stats.zoom = {
		63,
		60,
		55,
		50,
		45,
		40,
		35,
		30,
		25,
		17
	}
	self.stats.spread = {
		2,
		1.8,
		1.6,
		1.4,
		1.2,
		1,
		0.8,
		0.6,
		0.4,
		0.2,
		0.1
	}
	self.stats.spread_moving = {
		3,
		2.7,
		2.4,
		2.2,
		2,
		1.7,
		1.4,
		1.2,
		1,
		0.9,
		0.8,
		0.7,
		0.6,
		0.5
	}
	self.stats.recoil = {
		3,
		2.7,
		2.4,
		2.2,
		1.75,
		1.5,
		1.25,
		1.1,
		1,
		1,
		0.9,
		0.8,
		0.7,
		0.6,
		0.5
	}
	self.stats.value = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10
	}
	self.stats.concealment = {
		0.3,
		0.4,
		0.5,
		0.6,
		0.65,
		0.7,
		0.75,
		0.8,
		0.825,
		0.85,
		1,
		1.05,
		1.1,
		1.15,
		1.2,
		1.225,
		1.25,
		1.275,
		1.3,
		1.325,
		1.35,
		1.375,
		1.4,
		1.425,
		1.45,
		1.475,
		1.5,
		1.525,
		1.55,
		1.6
	}
	self.stats.extra_ammo = {}

	for i = -10, 50, 2 do
		table.insert(self.stats.extra_ammo, i)
	end

	self.stats.total_ammo_mod = {}

	for i = -100, 100, 5 do
		table.insert(self.stats.total_ammo_mod, i / 100)
	end
end

function WeaponTweakData:_pickup_chance(max_ammo, selection_index)
	local low, high

	if selection_index == 2 then
		low = 0.02
		high = 0.05
	else
		low = 0.02
		high = 0.05
	end

	return {
		max_ammo * low,
		max_ammo * high
	}
end

function WeaponTweakData:_init_new_weapons(weapon_data)
	local total_damage_primary = 300
	local total_damage_secondary = 150

	self.default_values = {}
	self.default_values.damage_profile = {
		{
			damage = 10,
			range = 1000
		}
	}
	self.default_values.headshot_multiplier = 2
	self.default_values.spread = {}
	self.default_values.spread.standing = 3.5
	self.default_values.spread.crouching = self.default_values.spread.standing
	self.default_values.spread.steelsight = 1
	self.default_values.spread.moving_standing = self.default_values.spread.standing
	self.default_values.spread.moving_crouching = self.default_values.spread.standing
	self.default_values.spread.moving_steelsight = self.default_values.spread.steelsight * 2
	self.default_values.spread.per_shot = 0
	self.default_values.spread.per_shot_steelsight = 0
	self.default_values.spread.recovery = 10
	self.default_values.spread.recovery_wait_multiplier = 1
	self.default_values.kick = {}
	self.default_values.kick.standing = {
		-0.1,
		0.2,
		-0.18,
		0.2
	}
	self.default_values.kick.crouching = {
		-0.1,
		0.2,
		-0.18,
		0.2
	}
	self.default_values.kick.steelsight = {
		-0.1,
		0.2,
		-0.22,
		0.2
	}
	self.default_values.kick.crouching_steelsight = {
		-0.1,
		0.2,
		-0.22,
		0.2
	}
	self.default_values.kick.recenter_speed = 500
	self.default_values.kick.recenter_speed_steelsight = 500

	self:_init_flamethrower_mk2(weapon_data)
	self:_init_m1911(weapon_data)
	self:_init_c96(weapon_data)
	self:_init_webley(weapon_data)
	self:_init_thompson(weapon_data)
	self:_init_sten_mk2(weapon_data)
	self:_init_m1_garand(weapon_data)
	self:_init_m1918_bar(weapon_data)
	self:_init_m1903_springfield(weapon_data)
	self:_init_m1912_winchester(weapon_data)
	self:_init_mp38(weapon_data)
	self:_init_m1_carbine(weapon_data)
	self:_init_mp44(weapon_data)
	self:_init_mg42(weapon_data)
	self:_init_mosin(weapon_data)
	self:_init_sterling(weapon_data)
	self:_init_geco(weapon_data)
	self:_init_dp28(weapon_data)
	self:_init_tt33(weapon_data)
	self:_init_ithaca(weapon_data)
	self:_init_kar_98k(weapon_data)
	self:_init_bren(weapon_data)
	self:_init_lee_enfield(weapon_data)
	self:_init_browning(weapon_data)
	self:_init_welrod(weapon_data)
	self:_init_shotty(weapon_data)
end

function WeaponTweakData:_init_flamethrower_mk2(weapon_data)
	self.flamethrower_mk2 = {}
	self.flamethrower_mk2.inventory_texture = "ui/temp/customization_temp_df"
	self.flamethrower_mk2.category = WeaponTweakData.WEAPON_CATEGORY_FLAMETHROWER
	self.flamethrower_mk2.has_description = true
	self.flamethrower_mk2.damage_melee = weapon_data.damage_melee_default
	self.flamethrower_mk2.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.flamethrower_mk2.sounds = {}
	self.flamethrower_mk2.sounds.fire = "flamethrower_fire_npc"
	self.flamethrower_mk2.sounds.stop_fire = "flamethrower_stop_npc"
	self.flamethrower_mk2.sounds.dryfire = "flamethrower_dryfire"
	self.flamethrower_mk2.timers = {}
	self.flamethrower_mk2.timers.reload_not_empty = 8.5
	self.flamethrower_mk2.timers.reload_empty = self.flamethrower_mk2.timers.reload_not_empty
	self.flamethrower_mk2.timers.unequip = 0.85
	self.flamethrower_mk2.timers.equip = 0.85
	self.flamethrower_mk2.name_id = "bm_w_flamethrower_mk2"
	self.flamethrower_mk2.desc_id = "bm_w_flamethrower_mk2_desc"
	self.flamethrower_mk2.description_id = "des_flamethrower_mk2"
	self.flamethrower_mk2.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.flamethrower_mk2.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.flamethrower_mk2.use_data = {}
	self.flamethrower_mk2.use_data.selection_index = 2
	self.flamethrower_mk2.use_data.align_place = "right_hand"
	self.flamethrower_mk2.DAMAGE = 1
	self.flamethrower_mk2.rays = 6
	self.flamethrower_mk2.CLIP_AMMO_MAX = 150
	self.flamethrower_mk2.NR_CLIPS_MAX = 4
	self.flamethrower_mk2.AMMO_MAX = self.flamethrower_mk2.CLIP_AMMO_MAX * self.flamethrower_mk2.NR_CLIPS_MAX
	self.flamethrower_mk2.AMMO_PICKUP = self:_pickup_chance(0, 1)
	self.flamethrower_mk2.FIRE_MODE = "auto"
	self.flamethrower_mk2.fire_mode_data = {}
	self.flamethrower_mk2.fire_mode_data.fire_rate = 0.03
	self.flamethrower_mk2.auto = {}
	self.flamethrower_mk2.auto.fire_rate = 0.05
	self.flamethrower_mk2.spread = {}
	self.flamethrower_mk2.spread.standing = self.default_values.spread.standing * 1
	self.flamethrower_mk2.spread.crouching = self.default_values.spread.standing * 1
	self.flamethrower_mk2.spread.steelsight = self.default_values.spread.standing * 0.8
	self.flamethrower_mk2.spread.moving_standing = self.default_values.spread.standing * 1
	self.flamethrower_mk2.spread.moving_crouching = self.default_values.spread.standing * 1
	self.flamethrower_mk2.spread.moving_steelsight = self.default_values.spread.standing * 0.8
	self.flamethrower_mk2.kick = {}
	self.flamethrower_mk2.kick.standing = {
		0,
		0,
		0,
		0
	}
	self.flamethrower_mk2.kick.crouching = self.flamethrower_mk2.kick.standing
	self.flamethrower_mk2.kick.steelsight = self.flamethrower_mk2.kick.standing
	self.flamethrower_mk2.crosshair = {}
	self.flamethrower_mk2.crosshair.standing = {}
	self.flamethrower_mk2.crosshair.crouching = {}
	self.flamethrower_mk2.crosshair.steelsight = {}
	self.flamethrower_mk2.crosshair.standing.offset = 0.16
	self.flamethrower_mk2.crosshair.standing.moving_offset = 0.8
	self.flamethrower_mk2.crosshair.standing.kick_offset = 0.6
	self.flamethrower_mk2.crosshair.standing.hidden = true
	self.flamethrower_mk2.crosshair.crouching.offset = 0.08
	self.flamethrower_mk2.crosshair.crouching.moving_offset = 0.7
	self.flamethrower_mk2.crosshair.crouching.kick_offset = 0.4
	self.flamethrower_mk2.crosshair.crouching.hidden = true
	self.flamethrower_mk2.crosshair.steelsight.hidden = true
	self.flamethrower_mk2.crosshair.steelsight.offset = 0
	self.flamethrower_mk2.crosshair.steelsight.moving_offset = 0
	self.flamethrower_mk2.crosshair.steelsight.kick_offset = 0.1
	self.flamethrower_mk2.shake = {}
	self.flamethrower_mk2.shake.fire_multiplier = 0
	self.flamethrower_mk2.shake.fire_steelsight_multiplier = 0
	self.flamethrower_mk2.autohit = weapon_data.autohit_shotgun_default
	self.flamethrower_mk2.aim_assist = weapon_data.aim_assist_shotgun_default
	self.flamethrower_mk2.animations = {}
	self.flamethrower_mk2.animations.equip_id = "equip_flamethrower"
	self.flamethrower_mk2.animations.recoil_steelsight = false
	self.flamethrower_mk2.no_whizby = true
	self.flamethrower_mk2.flame_max_range = 2000
	self.flamethrower_mk2.single_flame_effect_duration = 1
	self.flamethrower_mk2.global_value = "normal"
	self.flamethrower_mk2.texture_bundle_folder = "bbq"
	self.flamethrower_mk2.fire_dot_data = {
		dot_trigger_chance = 10,
		dot_damage = 1,
		dot_length = 3.1,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}
	self.flamethrower_mk2.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 5,
		alert_size = 1,
		spread = 1,
		spread_moving = 6,
		recoil = 0,
		value = 1,
		extra_ammo = 6,
		suppression = 2,
		concealment = 7
	}
end

function WeaponTweakData:_init_c96(weapon_data)
	self.c96 = {}
	self.c96.inventory_texture = "ui/temp/customization_temp_df"
	self.c96.category = WeaponTweakData.WEAPON_CATEGORY_PISTOL
	self.c96.damage_melee = 86
	self.c96.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.c96.sounds = {}
	self.c96.sounds.fire = "mauser_c96_fire_1p"
	self.c96.sounds.dryfire = "secondary_dryfire"
	self.c96.sounds.enter_steelsight = nil
	self.c96.sounds.leave_steelsight = nil
	self.c96.timers = {}
	self.c96.timers.reload_not_empty = 2.42
	self.c96.timers.reload_empty = 1.6
	self.c96.timers.unequip = 0.5
	self.c96.timers.equip = 0.35
	self.c96.name_id = "bm_w_c96"
	self.c96.desc_id = "bm_w_c96_desc"
	self.c96.description_id = "des_c96"
	self.c96.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.c96.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.c96.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.c96.use_data = {}
	self.c96.use_data.selection_index = 1
	self.c96.damage_profile = {
		{
			damage = 52,
			range = 1500
		},
		{
			damage = 15,
			range = 6000
		}
	}
	self.c96.headshot_multiplier = 3.5
	self.c96.CLIP_AMMO_MAX = 10
	self.c96.NR_CLIPS_MAX = 5
	self.c96.AMMO_MAX = self.c96.CLIP_AMMO_MAX * self.c96.NR_CLIPS_MAX
	self.c96.AMMO_PICKUP = self:_pickup_chance(self.c96.AMMO_MAX, 1)
	self.c96.ammo_pickup_base = 10
	self.c96.FIRE_MODE = "single"
	self.c96.fire_mode_data = {}
	self.c96.fire_mode_data.fire_rate = 0.125
	self.c96.single = {}
	self.c96.single.fire_rate = 0.125
	self.c96.spread = {}
	self.c96.spread.standing = 2.1
	self.c96.spread.crouching = self.c96.spread.standing - 0.25
	self.c96.spread.steelsight = self.c96.spread.standing - 1.25
	self.c96.spread.moving_standing = self.c96.spread.standing + 1
	self.c96.spread.moving_crouching = self.c96.spread.crouching + 0.5
	self.c96.spread.moving_steelsight = self.c96.spread.steelsight + 0.2
	self.c96.spread.per_shot = 0.75
	self.c96.spread.per_shot_steelsight = self.c96.spread.per_shot - 0.15
	self.c96.spread.recovery = 10
	self.c96.spread.recovery_wait_multiplier = 2
	self.c96.kick = {}
	self.c96.kick.standing = {
		1.1,
		1.4,
		-1,
		0.5
	}
	self.c96.kick.crouching = {
		1.2,
		1.3,
		-0.8,
		0.4
	}
	self.c96.kick.steelsight = {
		0.8,
		1.1,
		-2,
		0.2
	}
	self.c96.kick.crouching_steelsight = {
		0.7,
		0.9,
		-1.8,
		0.17
	}
	self.c96.gun_kick = {}
	self.c96.gun_kick.hip_fire = {
		20,
		40,
		-40,
		20
	}
	self.c96.gun_kick.steelsight = {
		20,
		25,
		-20,
		5
	}
	self.c96.gun_kick.position_ratio = 0.1
	self.c96.crosshair = {}
	self.c96.crosshair.standing = {}
	self.c96.crosshair.crouching = {}
	self.c96.crosshair.steelsight = {}
	self.c96.crosshair.standing.offset = 0.2
	self.c96.crosshair.standing.moving_offset = 0.6
	self.c96.crosshair.standing.kick_offset = 0.4
	self.c96.crosshair.crouching.offset = 0.1
	self.c96.crosshair.crouching.moving_offset = 0.6
	self.c96.crosshair.crouching.kick_offset = 0.3
	self.c96.crosshair.steelsight.hidden = true
	self.c96.crosshair.steelsight.offset = 0
	self.c96.crosshair.steelsight.moving_offset = 0
	self.c96.crosshair.steelsight.kick_offset = 0.1
	self.c96.shake = {}
	self.c96.shake.fire_multiplier = 1.5
	self.c96.shake.fire_steelsight_multiplier = -1.5
	self.c96.autohit = weapon_data.autohit_pistol_default
	self.c96.aim_assist = weapon_data.aim_assist_pistol_default
	self.c96.weapon_hold = "c96"
	self.c96.animations = {}
	self.c96.animations.equip_id = "equip_c96"
	self.c96.animations.magazine_empty = "last_recoil"
	self.c96.animations.recoil_steelsight = true
	self.c96.panic_suppression_chance = 0.05
	self.c96.gui = {}
	self.c96.gui.rotation_offset = -4
	self.c96.gui.distance_offset = -80
	self.c96.gui.height_offset = -11
	self.c96.gui.display_offset = 12
	self.c96.gui.initial_rotation = {}
	self.c96.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.c96.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.c96.gui.initial_rotation.roll = 0
	self.c96.gui.icon_large = "weapon_pis_c96_large"
	self.c96.hud = {}
	self.c96.hud.icon = "weapon_panel_pis_c96"
	self.c96.hud.panel_class = "clip_shots"
	self.c96.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.c96.hud.panel_clip_icon_spent = "9mm_spent"
	self.c96.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.c96.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.c96.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 15,
		alert_size = 7,
		spread = 6,
		recoil = 5,
		spread_moving = 9,
		value = 1,
		extra_ammo = 6,
		suppression = 14,
		concealment = 28
	}
end

function WeaponTweakData:_init_tt33(weapon_data)
	self.tt33 = {}
	self.tt33.inventory_texture = "ui/temp/customization_temp_df"
	self.tt33.category = WeaponTweakData.WEAPON_CATEGORY_PISTOL
	self.tt33.dismember_chance = 0
	self.tt33.damage_melee = 86
	self.tt33.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.tt33.sounds = {}
	self.tt33.sounds.fire = "tt33_fire_1p"
	self.tt33.sounds.dryfire = "secondary_dryfire"
	self.tt33.sounds.enter_steelsight = nil
	self.tt33.sounds.leave_steelsight = nil
	self.tt33.FIRE_MODE = "single"
	self.tt33.fire_mode_data = {}
	self.tt33.fire_mode_data.fire_rate = 0.1153
	self.tt33.single = {}
	self.tt33.single.fire_rate = 0.1153
	self.tt33.timers = {}
	self.tt33.timers.reload_not_empty = 1.25
	self.tt33.timers.reload_empty = 1.65
	self.tt33.timers.unequip = 0.5
	self.tt33.timers.equip = 0.25
	self.tt33.name_id = "bm_w_tt33"
	self.tt33.desc_id = "bm_w_tt33_desc"
	self.tt33.description_id = "des_tt33"
	self.tt33.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.tt33.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.tt33.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.tt33.use_data = {}
	self.tt33.use_data.selection_index = 1
	self.tt33.damage_profile = {
		{
			damage = 54,
			range = 1000
		},
		{
			damage = 15,
			range = 6000
		}
	}
	self.tt33.headshot_multiplier = 3.5
	self.tt33.CLIP_AMMO_MAX = 8
	self.tt33.NR_CLIPS_MAX = 8
	self.tt33.AMMO_MAX = self.tt33.CLIP_AMMO_MAX * self.tt33.NR_CLIPS_MAX
	self.tt33.AMMO_PICKUP = self:_pickup_chance(self.tt33.AMMO_MAX, 1)
	self.tt33.ammo_pickup_base = 10
	self.tt33.spread = {}
	self.tt33.spread = {}
	self.tt33.spread.standing = 2.5
	self.tt33.spread.crouching = self.tt33.spread.standing - 0.25
	self.tt33.spread.steelsight = self.tt33.spread.standing - 1.25
	self.tt33.spread.moving_standing = self.tt33.spread.standing + 1
	self.tt33.spread.moving_crouching = self.tt33.spread.crouching + 0.5
	self.tt33.spread.moving_steelsight = self.tt33.spread.steelsight + 0.2
	self.tt33.spread.per_shot = 0.75
	self.tt33.spread.per_shot_steelsight = self.tt33.spread.per_shot - 0.15
	self.tt33.spread.recovery = 8
	self.tt33.spread.recovery_wait_multiplier = 1.5
	self.tt33.kick = {}
	self.tt33.kick.standing = {
		1.05,
		1.3,
		-0.55,
		0.55
	}
	self.tt33.kick.crouching = {
		1.05,
		1.3,
		-0.45,
		0.45
	}
	self.tt33.kick.steelsight = {
		1.2,
		1.5,
		-0.3,
		0.3
	}
	self.tt33.kick.crouching_steelsight = {
		1.25,
		1.4,
		-0.25,
		0.25
	}
	self.tt33.gun_kick = {}
	self.tt33.gun_kick.hip_fire = {
		30,
		55,
		-32,
		30
	}
	self.tt33.gun_kick.steelsight = {
		30,
		35,
		-22,
		24
	}
	self.tt33.gun_kick.position_ratio = -0.05
	self.tt33.crosshair = {}
	self.tt33.crosshair.standing = {}
	self.tt33.crosshair.crouching = {}
	self.tt33.crosshair.steelsight = {}
	self.tt33.crosshair.standing.offset = 0.175
	self.tt33.crosshair.standing.moving_offset = 0.6
	self.tt33.crosshair.standing.kick_offset = 0.4
	self.tt33.crosshair.crouching.offset = 0.1
	self.tt33.crosshair.crouching.moving_offset = 0.6
	self.tt33.crosshair.crouching.kick_offset = 0.3
	self.tt33.crosshair.steelsight.hidden = true
	self.tt33.crosshair.steelsight.offset = 0
	self.tt33.crosshair.steelsight.moving_offset = 0
	self.tt33.crosshair.steelsight.kick_offset = 0.1
	self.tt33.shake = {}
	self.tt33.shake.fire_multiplier = 1
	self.tt33.shake.fire_steelsight_multiplier = 1
	self.tt33.autohit = weapon_data.autohit_pistol_default
	self.tt33.aim_assist = weapon_data.aim_assist_pistol_default
	self.tt33.weapon_hold = "tt33"
	self.tt33.animations = {}
	self.tt33.animations.equip_id = "equip_tt33"
	self.tt33.animations.magazine_empty = "last_recoil"
	self.tt33.animations.recoil_steelsight = true
	self.tt33.transition_duration = 0
	self.tt33.panic_suppression_chance = 0.05
	self.tt33.gui = {}
	self.tt33.gui.rotation_offset = -4
	self.tt33.gui.distance_offset = -80
	self.tt33.gui.height_offset = -11
	self.tt33.gui.display_offset = 12
	self.tt33.gui.initial_rotation = {}
	self.tt33.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.tt33.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.tt33.gui.initial_rotation.roll = 0
	self.tt33.gui.icon_large = "weapon_pis_tt33_large"
	self.tt33.hud = {}
	self.tt33.hud.icon = "weapon_panel_pis_tt33"
	self.tt33.hud.panel_class = "clip_shots"
	self.tt33.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.tt33.hud.panel_clip_icon_spent = "9mm_spent"
	self.tt33.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 14,
		concealment = 29
	}
end

function WeaponTweakData:_init_webley(weapon_data)
	self.webley = {}
	self.webley.inventory_texture = "ui/temp/customization_temp_df"
	self.webley.category = WeaponTweakData.WEAPON_CATEGORY_PISTOL
	self.webley.damage_melee = 86
	self.webley.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.webley.sounds = {}
	self.webley.sounds.fire = "webley_mk6_1p"
	self.webley.sounds.dryfire = "secondary_dryfire"
	self.webley.sounds.enter_steelsight = nil
	self.webley.sounds.leave_steelsight = nil
	self.webley.timers = {}
	self.webley.timers.reload_not_empty = 2.2
	self.webley.timers.reload_empty = 2.2
	self.webley.timers.unequip = 0.5
	self.webley.timers.equip = 0.35
	self.webley.name_id = "bm_w_webley"
	self.webley.desc_id = "bm_w_webley_desc"
	self.webley.description_id = "des_webley"
	self.webley.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.webley.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.webley.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.webley.use_data = {}
	self.webley.use_data.selection_index = 1
	self.webley.damage_profile = {
		{
			damage = 100,
			range = 1000
		},
		{
			damage = 25,
			range = 6000
		}
	}
	self.webley.headshot_multiplier = 3.5
	self.webley.CLIP_AMMO_MAX = 6
	self.webley.NR_CLIPS_MAX = 6
	self.webley.AMMO_MAX = self.webley.CLIP_AMMO_MAX * self.webley.NR_CLIPS_MAX
	self.webley.AMMO_PICKUP = self:_pickup_chance(self.webley.AMMO_MAX, 1)
	self.webley.ammo_pickup_base = 6
	self.webley.FIRE_MODE = "single"
	self.webley.fire_mode_data = {}
	self.webley.fire_mode_data.fire_rate = 0.3
	self.webley.single = {}
	self.webley.single.fire_rate = 0.3
	self.webley.spread = {}
	self.webley.spread.standing = 1.9
	self.webley.spread.crouching = self.webley.spread.standing - 0.35
	self.webley.spread.steelsight = self.webley.spread.standing - 1.35
	self.webley.spread.moving_standing = self.webley.spread.standing + 1
	self.webley.spread.moving_crouching = self.webley.spread.crouching + 0.5
	self.webley.spread.moving_steelsight = self.webley.spread.steelsight + 0.2
	self.webley.spread.per_shot = 0.85
	self.webley.spread.per_shot_steelsight = self.webley.spread.per_shot - 0.08
	self.webley.spread.recovery = 12
	self.webley.spread.recovery_wait_multiplier = 2.2
	self.webley.kick = {}
	self.webley.kick.standing = {
		1.3,
		1.7,
		-1,
		1.1
	}
	self.webley.kick.crouching = {
		1.6,
		1.5,
		-0.8,
		1.3
	}
	self.webley.kick.steelsight = {
		1.1,
		1.7,
		-0.25,
		0.54
	}
	self.webley.kick.crouching_steelsight = {
		1.1,
		1.3,
		-0.25,
		0.25
	}
	self.webley.gun_kick = {}
	self.webley.gun_kick.hip_fire = {
		40,
		95,
		-50,
		15
	}
	self.webley.gun_kick.steelsight = {
		30,
		70,
		-50,
		10
	}
	self.webley.gun_kick.position_ratio = -0.02
	self.webley.crosshair = {}
	self.webley.crosshair.standing = {}
	self.webley.crosshair.crouching = {}
	self.webley.crosshair.steelsight = {}
	self.webley.crosshair.standing.offset = 0.2
	self.webley.crosshair.standing.moving_offset = 0.6
	self.webley.crosshair.standing.kick_offset = 0.4
	self.webley.crosshair.crouching.offset = 0.1
	self.webley.crosshair.crouching.moving_offset = 0.6
	self.webley.crosshair.crouching.kick_offset = 0.3
	self.webley.crosshair.steelsight.hidden = true
	self.webley.crosshair.steelsight.offset = 0
	self.webley.crosshair.steelsight.moving_offset = 0
	self.webley.crosshair.steelsight.kick_offset = 0.1
	self.webley.shake = {}
	self.webley.shake.fire_multiplier = 1
	self.webley.shake.fire_steelsight_multiplier = -1
	self.webley.autohit = weapon_data.autohit_pistol_default
	self.webley.aim_assist = weapon_data.aim_assist_pistol_default
	self.webley.weapon_hold = "webley"
	self.webley.animations = {}
	self.webley.animations.equip_id = "equip_webley"
	self.webley.animations.recoil_steelsight = true
	self.webley.panic_suppression_chance = 0.075
	self.webley.gui = {}
	self.webley.gui.rotation_offset = -4
	self.webley.gui.distance_offset = -80
	self.webley.gui.height_offset = -11
	self.webley.gui.display_offset = 12
	self.webley.gui.initial_rotation = {}
	self.webley.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.webley.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.webley.gui.initial_rotation.roll = 0
	self.webley.gui.icon_large = "weapon_pis_webley_large"
	self.webley.hud = {}
	self.webley.hud.icon = "weapons_panel_pis_webley"
	self.webley.hud.panel_class = "revolver"
	self.webley.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		damage = 33,
		alert_size = 7,
		spread = 7,
		recoil = 2,
		spread_moving = 10,
		value = 1,
		extra_ammo = 6,
		suppression = 14,
		concealment = 28
	}
end

function WeaponTweakData:_init_m1911(weapon_data)
	self.m1911 = {}
	self.m1911.inventory_texture = "ui/temp/customization_temp_df"
	self.m1911.category = WeaponTweakData.WEAPON_CATEGORY_PISTOL
	self.m1911.dismember_chance = 0
	self.m1911.damage_melee = 86
	self.m1911.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.m1911.sounds = {}
	self.m1911.sounds.fire = "colt_m1911_fire_1p"
	self.m1911.sounds.dryfire = "secondary_dryfire"
	self.m1911.sounds.enter_steelsight = nil
	self.m1911.sounds.leave_steelsight = nil
	self.m1911.FIRE_MODE = "single"
	self.m1911.fire_mode_data = {}
	self.m1911.fire_mode_data.fire_rate = 0.12
	self.m1911.single = {}
	self.m1911.single.fire_rate = 0.12
	self.m1911.timers = {}
	self.m1911.timers.reload_not_empty = 1.25
	self.m1911.timers.reload_empty = 1.65
	self.m1911.timers.unequip = 0.5
	self.m1911.timers.equip = 0.25
	self.m1911.name_id = "bm_w_m1911"
	self.m1911.desc_id = "bm_w_m1911_desc"
	self.m1911.description_id = "des_m1911"
	self.m1911.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.m1911.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.m1911.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.m1911.use_data = {}
	self.m1911.use_data.selection_index = 1
	self.m1911.damage_profile = {
		{
			damage = 62,
			range = 1000
		},
		{
			damage = 15,
			range = 6000
		}
	}
	self.m1911.headshot_multiplier = 3.5
	self.m1911.CLIP_AMMO_MAX = 7
	self.m1911.NR_CLIPS_MAX = 7
	self.m1911.AMMO_MAX = self.m1911.CLIP_AMMO_MAX * self.m1911.NR_CLIPS_MAX
	self.m1911.AMMO_PICKUP = self:_pickup_chance(self.m1911.AMMO_MAX, 1)
	self.m1911.ammo_pickup_base = 10
	self.m1911.spread = {}
	self.m1911.spread = {}
	self.m1911.spread.standing = 2.1
	self.m1911.spread.crouching = self.m1911.spread.standing - 0.25
	self.m1911.spread.steelsight = self.m1911.spread.standing - 1.25
	self.m1911.spread.moving_standing = self.m1911.spread.standing + 1
	self.m1911.spread.moving_crouching = self.m1911.spread.crouching + 0.5
	self.m1911.spread.moving_steelsight = self.m1911.spread.steelsight + 0.2
	self.m1911.spread.per_shot = 0.825
	self.m1911.spread.per_shot_steelsight = self.m1911.spread.per_shot - 0.125
	self.m1911.spread.recovery = 10
	self.m1911.spread.recovery_wait_multiplier = 1.6
	self.m1911.kick = {}
	self.m1911.kick.standing = {
		1,
		1.2,
		-0.5,
		0.5
	}
	self.m1911.kick.crouching = {
		1,
		1.2,
		-0.4,
		0.4
	}
	self.m1911.kick.steelsight = {
		1.2,
		1.45,
		-0.25,
		0.25
	}
	self.m1911.kick.crouching_steelsight = {
		1.2,
		1.3,
		-0.2,
		0.2
	}
	self.m1911.gun_kick = {}
	self.m1911.gun_kick.hip_fire = {
		25,
		50,
		-30,
		25
	}
	self.m1911.gun_kick.steelsight = {
		25,
		32,
		-20,
		20
	}
	self.m1911.gun_kick.position_ratio = -0.05
	self.m1911.crosshair = {}
	self.m1911.crosshair.standing = {}
	self.m1911.crosshair.crouching = {}
	self.m1911.crosshair.steelsight = {}
	self.m1911.crosshair.standing.offset = 0.175
	self.m1911.crosshair.standing.moving_offset = 0.6
	self.m1911.crosshair.standing.kick_offset = 0.4
	self.m1911.crosshair.crouching.offset = 0.1
	self.m1911.crosshair.crouching.moving_offset = 0.6
	self.m1911.crosshair.crouching.kick_offset = 0.3
	self.m1911.crosshair.steelsight.hidden = true
	self.m1911.crosshair.steelsight.offset = 0
	self.m1911.crosshair.steelsight.moving_offset = 0
	self.m1911.crosshair.steelsight.kick_offset = 0.1
	self.m1911.shake = {}
	self.m1911.shake.fire_multiplier = 1
	self.m1911.shake.fire_steelsight_multiplier = 1
	self.m1911.autohit = weapon_data.autohit_pistol_default
	self.m1911.aim_assist = weapon_data.aim_assist_pistol_default
	self.m1911.weapon_hold = "m1911"
	self.m1911.animations = {}
	self.m1911.animations.equip_id = "equip_m1911"
	self.m1911.animations.magazine_empty = "last_recoil"
	self.m1911.animations.recoil_steelsight = true
	self.m1911.transition_duration = 0
	self.m1911.panic_suppression_chance = 0.05
	self.m1911.gui = {}
	self.m1911.gui.rotation_offset = -4
	self.m1911.gui.distance_offset = -80
	self.m1911.gui.height_offset = -11
	self.m1911.gui.display_offset = 12
	self.m1911.gui.initial_rotation = {}
	self.m1911.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.m1911.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.m1911.gui.initial_rotation.roll = 0
	self.m1911.gui.icon_large = "weapon_pis_m1911_large"
	self.m1911.hud = {}
	self.m1911.hud.icon = "weapon_panel_pis_m1911"
	self.m1911.hud.panel_class = "clip_shots"
	self.m1911.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.m1911.hud.panel_clip_icon_spent = "9mm_spent"
	self.m1911.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 14,
		concealment = 29
	}
end

function WeaponTweakData:_init_m1912_winchester(weapon_data)
	self.m1912 = {}
	self.m1912.inventory_texture = "ui/temp/customization_temp_df"
	self.m1912.category = WeaponTweakData.WEAPON_CATEGORY_SHOTGUN
	self.m1912.use_shotgun_reload = true
	self.m1912.dismember_chance = 0.33
	self.m1912.damage_melee = 108
	self.m1912.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.m1912.sounds = {}
	self.m1912.sounds.fire = "shotgun_fire_1p_single"
	self.m1912.sounds.dryfire = "primary_dryfire"
	self.m1912.timers = {}
	self.m1912.timers.shotgun_reload_enter = 0.5333333333333333
	self.m1912.timers.shotgun_reload_exit_empty = 0.4
	self.m1912.timers.shotgun_reload_exit_not_empty = 0.4
	self.m1912.timers.shotgun_reload_shell = 0.6666666666666666
	self.m1912.timers.shotgun_reload_first_shell_offset = 0.13333333333333333
	self.m1912.timers.unequip = 0.85
	self.m1912.timers.equip = 0.6
	self.m1912.name_id = "bm_w_m1912"
	self.m1912.desc_id = "bm_w_m1912_desc"
	self.m1912.description_id = "des_m1912"
	self.m1912.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.m1912.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.m1912.use_data = {}
	self.m1912.use_data.selection_index = 2
	self.m1912.use_data.align_place = "right_hand"
	self.m1912.damage_profile = {
		{
			damage = 200,
			range = 1000
		},
		{
			damage = 20,
			range = 2000
		}
	}
	self.m1912.headshot_multiplier = 3
	self.m1912.rays = 12
	self.m1912.CLIP_AMMO_MAX = 6
	self.m1912.NR_CLIPS_MAX = 5
	self.m1912.AMMO_MAX = self.m1912.CLIP_AMMO_MAX * self.m1912.NR_CLIPS_MAX
	self.m1912.AMMO_PICKUP = self:_pickup_chance(self.m1912.AMMO_MAX, 1)
	self.m1912.ammo_pickup_base = 3
	self.m1912.FIRE_MODE = "single"
	self.m1912.fire_mode_data = {}
	self.m1912.fire_mode_data.fire_rate = 0.7
	self.m1912.CAN_TOGGLE_FIREMODE = false
	self.m1912.single = {}
	self.m1912.single.fire_rate = 0.7
	self.m1912.spread = {}
	self.m1912.spread.standing = 3
	self.m1912.spread.crouching = 3
	self.m1912.spread.steelsight = 3
	self.m1912.spread.moving_standing = 3
	self.m1912.spread.moving_crouching = 3
	self.m1912.spread.moving_steelsight = 3
	self.m1912.spread.per_shot = 0
	self.m1912.spread.per_shot_steelsight = 0
	self.m1912.spread.recovery = 12
	self.m1912.spread.recovery_wait_multiplier = 0.5
	self.m1912.kick = {}
	self.m1912.kick.standing = {
		3.6,
		4.2,
		-2,
		2
	}
	self.m1912.kick.crouching = {
		3.2,
		3.8,
		-2,
		2
	}
	self.m1912.kick.steelsight = {
		3.4,
		3.8,
		-2,
		2
	}
	self.m1912.kick.crouching_steelsight = {
		3.2,
		3.4,
		-1.8,
		1.8
	}
	self.m1912.gun_kick = {}
	self.m1912.gun_kick.hip_fire = {
		60,
		90,
		-55,
		55
	}
	self.m1912.gun_kick.steelsight = {
		48,
		45,
		-45,
		-45
	}
	self.m1912.gun_kick.position_ratio = -0.075
	self.m1912.crosshair = {}
	self.m1912.crosshair.standing = {}
	self.m1912.crosshair.crouching = {}
	self.m1912.crosshair.steelsight = {}
	self.m1912.crosshair.standing.offset = 0.7
	self.m1912.crosshair.standing.moving_offset = 0.7
	self.m1912.crosshair.standing.kick_offset = 0.8
	self.m1912.crosshair.crouching.offset = 0.65
	self.m1912.crosshair.crouching.moving_offset = 0.65
	self.m1912.crosshair.crouching.kick_offset = 0.75
	self.m1912.crosshair.steelsight.hidden = true
	self.m1912.crosshair.steelsight.offset = 0
	self.m1912.crosshair.steelsight.moving_offset = 0
	self.m1912.crosshair.steelsight.kick_offset = 0
	self.m1912.shake = {}
	self.m1912.shake.fire_multiplier = 2
	self.m1912.shake.fire_steelsight_multiplier = -2
	self.m1912.autohit = weapon_data.autohit_shotgun_default
	self.m1912.aim_assist = weapon_data.aim_assist_shotgun_default
	self.m1912.weapon_hold = "m1912"
	self.m1912.animations = {}
	self.m1912.animations.equip_id = "equip_r870_shotgun"
	self.m1912.animations.recoil_steelsight = true
	self.m1912.panic_suppression_chance = 0.25
	self.m1912.gui = {}
	self.m1912.gui.rotation_offset = -30
	self.m1912.gui.distance_offset = 15
	self.m1912.gui.height_offset = -7
	self.m1912.gui.display_offset = -10
	self.m1912.gui.initial_rotation = {}
	self.m1912.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.m1912.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.m1912.gui.initial_rotation.roll = 0
	self.m1912.gui.icon_large = "weapon_sho_1912_large"
	self.m1912.hud = {}
	self.m1912.hud.icon = "weapon_panel_sho_1912"
	self.m1912.hud.panel_class = "clip_shots"
	self.m1912.hud.panel_clip_icon_loaded = "shell_loaded"
	self.m1912.hud.panel_clip_icon_spent = "shell_spent"
	self.m1912.hud.panel_clip_icon_loaded_thin = "shell_small_loaded"
	self.m1912.hud.panel_clip_icon_spent_thin = "shell_small_spent"
	self.m1912.hud.panel_clip_icon_stack_min = 2
	self.m1912.hud.panel_clip_icon_thin_min = 2
	self.m1912.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 3,
		value = 1,
		extra_ammo = 6,
		suppression = 6,
		concealment = 12
	}
end

function WeaponTweakData:_init_ithaca(weapon_data)
	self.ithaca = {}
	self.ithaca.inventory_texture = "ui/temp/customization_temp_df"
	self.ithaca.category = WeaponTweakData.WEAPON_CATEGORY_SHOTGUN
	self.ithaca.use_shotgun_reload = true
	self.ithaca.dismember_chance = 0.33
	self.ithaca.damage_melee = 108
	self.ithaca.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.ithaca.sounds = {}
	self.ithaca.sounds.fire = "ithaca_fire_1p_single"
	self.ithaca.sounds.dryfire = "primary_dryfire"
	self.ithaca.timers = {}
	self.ithaca.timers.shotgun_reload_enter = 0.5333333333333333
	self.ithaca.timers.shotgun_reload_exit_empty = 0.4
	self.ithaca.timers.shotgun_reload_exit_not_empty = 0.4
	self.ithaca.timers.shotgun_reload_shell = 0.6666666666666666
	self.ithaca.timers.shotgun_reload_first_shell_offset = 0.13333333333333333
	self.ithaca.timers.unequip = 0.85
	self.ithaca.timers.equip = 0.6
	self.ithaca.name_id = "bm_w_ithaca"
	self.ithaca.desc_id = "bm_w_ithaca_desc"
	self.ithaca.description_id = "des_ithaca"
	self.ithaca.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.ithaca.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.ithaca.use_data = {}
	self.ithaca.use_data.selection_index = 2
	self.ithaca.use_data.align_place = "right_hand"
	self.ithaca.damage_profile = {
		{
			damage = 240,
			range = 1000
		},
		{
			damage = 30,
			range = 2000
		}
	}
	self.ithaca.headshot_multiplier = 3
	self.ithaca.rays = 12
	self.ithaca.CLIP_AMMO_MAX = 6
	self.ithaca.NR_CLIPS_MAX = 6
	self.ithaca.AMMO_MAX = self.ithaca.CLIP_AMMO_MAX * self.ithaca.NR_CLIPS_MAX
	self.ithaca.AMMO_PICKUP = self:_pickup_chance(self.ithaca.AMMO_MAX, 1)
	self.ithaca.ammo_pickup_base = 3
	self.ithaca.FIRE_MODE = "single"
	self.ithaca.fire_mode_data = {}
	self.ithaca.fire_mode_data.fire_rate = 0.72
	self.ithaca.CAN_TOGGLE_FIREMODE = false
	self.ithaca.single = {}
	self.ithaca.single.fire_rate = 0.72
	self.ithaca.spread = {}
	self.ithaca.spread.standing = 2
	self.ithaca.spread.crouching = 2
	self.ithaca.spread.steelsight = 2
	self.ithaca.spread.moving_standing = 2
	self.ithaca.spread.moving_crouching = 2
	self.ithaca.spread.moving_steelsight = 2
	self.ithaca.spread.per_shot = 0
	self.ithaca.spread.per_shot_steelsight = 0
	self.ithaca.spread.recovery = 12
	self.ithaca.spread.recovery_wait_multiplier = 0.5
	self.ithaca.kick = {}
	self.ithaca.kick.standing = {
		3.6,
		4.2,
		-2,
		2
	}
	self.ithaca.kick.crouching = {
		3.2,
		3.8,
		-2,
		2
	}
	self.ithaca.kick.steelsight = {
		3.4,
		3.8,
		-2,
		2
	}
	self.ithaca.kick.crouching_steelsight = {
		3.2,
		3.4,
		-1.8,
		1.8
	}
	self.ithaca.gun_kick = {}
	self.ithaca.gun_kick.hip_fire = {
		60,
		90,
		-55,
		55
	}
	self.ithaca.gun_kick.steelsight = {
		48,
		45,
		-45,
		-45
	}
	self.ithaca.gun_kick.position_ratio = -0.075
	self.ithaca.crosshair = {}
	self.ithaca.crosshair.standing = {}
	self.ithaca.crosshair.crouching = {}
	self.ithaca.crosshair.steelsight = {}
	self.ithaca.crosshair.standing.offset = 0.7
	self.ithaca.crosshair.standing.moving_offset = 0.7
	self.ithaca.crosshair.standing.kick_offset = 0.8
	self.ithaca.crosshair.crouching.offset = 0.65
	self.ithaca.crosshair.crouching.moving_offset = 0.65
	self.ithaca.crosshair.crouching.kick_offset = 0.75
	self.ithaca.crosshair.steelsight.hidden = true
	self.ithaca.crosshair.steelsight.offset = 0
	self.ithaca.crosshair.steelsight.moving_offset = 0
	self.ithaca.crosshair.steelsight.kick_offset = 0
	self.ithaca.shake = {}
	self.ithaca.shake.fire_multiplier = 2
	self.ithaca.shake.fire_steelsight_multiplier = -2
	self.ithaca.autohit = weapon_data.autohit_shotgun_default
	self.ithaca.aim_assist = weapon_data.aim_assist_shotgun_default
	self.ithaca.weapon_hold = "ithaca"
	self.ithaca.animations = {}
	self.ithaca.animations.equip_id = "equip_ithaca"
	self.ithaca.animations.recoil_steelsight = true
	self.ithaca.panic_suppression_chance = 0.18
	self.ithaca.gui = {}
	self.ithaca.gui.rotation_offset = -30
	self.ithaca.gui.distance_offset = 15
	self.ithaca.gui.height_offset = -7
	self.ithaca.gui.display_offset = -10
	self.ithaca.gui.initial_rotation = {}
	self.ithaca.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.ithaca.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.ithaca.gui.initial_rotation.roll = 0
	self.ithaca.gui.icon_large = "weapon_itchaca_large"
	self.ithaca.hud = {}
	self.ithaca.hud.icon = "weapons_panel_itchaca"
	self.ithaca.hud.panel_class = "clip_shots"
	self.ithaca.hud.panel_clip_icon_spent = "shell_small_spent"
	self.ithaca.hud.panel_clip_icon_loaded = "shell_small_loaded"
	self.ithaca.hud.panel_clip_icon_stack_min = 1
	self.ithaca.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 6,
		concealment = 12
	}
end

function WeaponTweakData:_init_browning(weapon_data)
	self.browning = {}
	self.browning.inventory_texture = "ui/temp/customization_temp_df"
	self.browning.category = WeaponTweakData.WEAPON_CATEGORY_SHOTGUN
	self.browning.use_shotgun_reload = true
	self.browning.dismember_chance = 0.33
	self.browning.damage_melee = 108
	self.browning.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.browning.sounds = {}
	self.browning.sounds.fire = "browning_fire_1p_single"
	self.browning.sounds.dryfire = "primary_dryfire"
	self.browning.timers = {}
	self.browning.timers.shotgun_reload_enter = 0.5333333333333333
	self.browning.timers.shotgun_reload_exit_empty = 0.4
	self.browning.timers.shotgun_reload_exit_not_empty = 0.4
	self.browning.timers.shotgun_reload_shell = 0.6666666666666666
	self.browning.timers.shotgun_reload_first_shell_offset = 0.13333333333333333
	self.browning.timers.unequip = 0.85
	self.browning.timers.equip = 0.6
	self.browning.name_id = "bm_w_browning"
	self.browning.desc_id = "bm_w_browning_desc"
	self.browning.description_id = "des_browning"
	self.browning.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.browning.shell_ejection = "effects/vanilla/weapons/shells/shell_slug_semi"
	self.browning.use_data = {}
	self.browning.use_data.selection_index = 2
	self.browning.use_data.align_place = "right_hand"
	self.browning.damage_profile = {
		{
			damage = 190,
			range = 1000
		},
		{
			damage = 15,
			range = 2000
		}
	}
	self.browning.headshot_multiplier = 3
	self.browning.rays = 12
	self.browning.CLIP_AMMO_MAX = 5
	self.browning.NR_CLIPS_MAX = 4
	self.browning.AMMO_MAX = self.browning.CLIP_AMMO_MAX * self.browning.NR_CLIPS_MAX
	self.browning.AMMO_PICKUP = self:_pickup_chance(self.browning.AMMO_MAX, 1)
	self.browning.ammo_pickup_base = 3
	self.browning.FIRE_MODE = "single"
	self.browning.fire_mode_data = {}
	self.browning.fire_mode_data.fire_rate = self:convert_rpm(430)
	self.browning.CAN_TOGGLE_FIREMODE = false
	self.browning.single = {}
	self.browning.single.fire_rate = self:convert_rpm(430)
	self.browning.spread = {}
	self.browning.spread.standing = 3
	self.browning.spread.crouching = 3
	self.browning.spread.steelsight = 3
	self.browning.spread.moving_standing = 3
	self.browning.spread.moving_crouching = 3
	self.browning.spread.moving_steelsight = 3
	self.browning.spread.per_shot = 0
	self.browning.spread.per_shot_steelsight = 0
	self.browning.spread.recovery = 6
	self.browning.spread.recovery_wait_multiplier = 0.6
	self.browning.kick = {}
	self.browning.kick.standing = {
		3.6,
		5.2,
		-2,
		2
	}
	self.browning.kick.crouching = {
		3.2,
		4.8,
		-2,
		2
	}
	self.browning.kick.steelsight = {
		3.4,
		4.8,
		-2,
		2
	}
	self.browning.kick.crouching_steelsight = {
		3.2,
		4.4,
		-1.8,
		1.8
	}
	self.browning.gun_kick = {}
	self.browning.gun_kick.hip_fire = {
		57,
		95,
		-55,
		55
	}
	self.browning.gun_kick.steelsight = {
		48,
		58,
		-45,
		-45
	}
	self.browning.gun_kick.position_ratio = -0.075
	self.browning.crosshair = {}
	self.browning.crosshair.standing = {}
	self.browning.crosshair.crouching = {}
	self.browning.crosshair.steelsight = {}
	self.browning.crosshair.standing.offset = 0.7
	self.browning.crosshair.standing.moving_offset = 0.7
	self.browning.crosshair.standing.kick_offset = 0.8
	self.browning.crosshair.crouching.offset = 0.65
	self.browning.crosshair.crouching.moving_offset = 0.65
	self.browning.crosshair.crouching.kick_offset = 0.75
	self.browning.crosshair.steelsight.hidden = true
	self.browning.crosshair.steelsight.offset = 0
	self.browning.crosshair.steelsight.moving_offset = 0
	self.browning.crosshair.steelsight.kick_offset = 0
	self.browning.shake = {}
	self.browning.shake.fire_multiplier = 2.5
	self.browning.shake.fire_steelsight_multiplier = -2
	self.browning.autohit = weapon_data.autohit_shotgun_default
	self.browning.aim_assist = weapon_data.aim_assist_shotgun_default
	self.browning.weapon_hold = "browning"
	self.browning.animations = {}
	self.browning.animations.equip_id = "equip_browning"
	self.browning.animations.recoil_steelsight = true
	self.browning.panic_suppression_chance = 0.33
	self.browning.gui = {}
	self.browning.gui.rotation_offset = -30
	self.browning.gui.distance_offset = 85
	self.browning.gui.height_offset = -7
	self.browning.gui.display_offset = -10
	self.browning.gui.initial_rotation = {}
	self.browning.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.browning.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.browning.gui.initial_rotation.roll = 0
	self.browning.gui.icon_large = "weapon_browning_large"
	self.browning.hud = {}
	self.browning.hud.icon = "weapon_panel_sho_1912"
	self.browning.hud.panel_class = "clip_shots"
	self.browning.hud.panel_clip_icon_loaded = "shell_small_loaded"
	self.browning.hud.panel_clip_icon_spent = "shell_small_spent"
	self.browning.hud.panel_clip_icon_stack_min = 1
	self.browning.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 5,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 6,
		concealment = 12
	}
end

function WeaponTweakData:_init_welrod(weapon_data)
	self.welrod = {}
	self.welrod.inventory_texture = "ui/temp/customization_temp_df"
	self.welrod.category = WeaponTweakData.WEAPON_CATEGORY_PISTOL
	self.welrod.dismember_chance = 0
	self.welrod.damage_melee = 86
	self.welrod.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.welrod.sounds = {}
	self.welrod.sounds.fire = "welrod_fire_1p"
	self.welrod.sounds.dryfire = "secondary_dryfire"
	self.welrod.sounds.enter_steelsight = nil
	self.welrod.sounds.leave_steelsight = nil
	self.welrod.FIRE_MODE = "single"
	self.welrod.fire_mode_data = {}
	self.welrod.fire_mode_data.fire_rate = 1
	self.welrod.single = {}
	self.welrod.single.fire_rate = 1.6
	self.welrod.timers = {}
	self.welrod.timers.reload_not_empty = 3.45
	self.welrod.timers.reload_empty = 3.45
	self.welrod.timers.unequip = 0.5
	self.welrod.timers.equip = 0.25
	self.welrod.name_id = "bm_w_welrod"
	self.welrod.desc_id = "bm_w_welrod_desc"
	self.welrod.description_id = "des_welrod"
	self.welrod.muzzleflash = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.welrod.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.welrod.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.welrod.use_data = {}
	self.welrod.use_data.selection_index = 1
	self.welrod.damage_profile = {
		{
			damage = 100,
			range = 500
		},
		{
			damage = 15,
			range = 2500
		}
	}
	self.welrod.headshot_multiplier = 3
	self.welrod.CLIP_AMMO_MAX = 6
	self.welrod.NR_CLIPS_MAX = 2
	self.welrod.AMMO_MAX = self.welrod.CLIP_AMMO_MAX * self.welrod.NR_CLIPS_MAX
	self.welrod.AMMO_PICKUP = self:_pickup_chance(self.welrod.AMMO_MAX, 1)
	self.welrod.ammo_pickup_base = 2
	self.welrod.spread = {}
	self.welrod.spread.standing = 2
	self.welrod.spread.crouching = 1.25
	self.welrod.spread.steelsight = 0.75
	self.welrod.spread.moving_standing = 3.75
	self.welrod.spread.moving_crouching = 3.38
	self.welrod.spread.moving_steelsight = 1.56
	self.welrod.spread.per_shot = 0.24
	self.welrod.spread.per_shot_steelsight = 0.16
	self.welrod.spread.recovery = 8
	self.welrod.spread.recovery_wait_multiplier = 1
	self.welrod.kick = {}
	self.welrod.kick.standing = {
		1,
		1.2,
		-0.5,
		0.5
	}
	self.welrod.kick.crouching = {
		1,
		1.2,
		-0.4,
		0.4
	}
	self.welrod.kick.steelsight = {
		1.2,
		1.45,
		-0.25,
		0.25
	}
	self.welrod.kick.crouching_steelsight = {
		1.2,
		1.3,
		-0.2,
		0.2
	}
	self.welrod.gun_kick = {}
	self.welrod.gun_kick.hip_fire = {
		25,
		50,
		-30,
		25
	}
	self.welrod.gun_kick.steelsight = {
		25,
		32,
		-20,
		20
	}
	self.welrod.gun_kick.position_ratio = -0.05
	self.welrod.crosshair = {}
	self.welrod.crosshair.standing = {}
	self.welrod.crosshair.crouching = {}
	self.welrod.crosshair.steelsight = {}
	self.welrod.crosshair.standing.offset = 0.175
	self.welrod.crosshair.standing.moving_offset = 0.6
	self.welrod.crosshair.standing.kick_offset = 0.4
	self.welrod.crosshair.crouching.offset = 0.1
	self.welrod.crosshair.crouching.moving_offset = 0.6
	self.welrod.crosshair.crouching.kick_offset = 0.3
	self.welrod.crosshair.steelsight.hidden = true
	self.welrod.crosshair.steelsight.offset = 0
	self.welrod.crosshair.steelsight.moving_offset = 0
	self.welrod.crosshair.steelsight.kick_offset = 0.1
	self.welrod.shake = {}
	self.welrod.shake.fire_multiplier = 1
	self.welrod.shake.fire_steelsight_multiplier = 1
	self.welrod.autohit = weapon_data.autohit_pistol_default
	self.welrod.aim_assist = weapon_data.aim_assist_pistol_default
	self.welrod.weapon_hold = "welrod_pistol"
	self.welrod.animations = {}
	self.welrod.animations.equip_id = "equip_welrod_pistol"
	self.welrod.animations.magazine_empty = "last_recoil"
	self.welrod.animations.recoil_steelsight = true
	self.welrod.transition_duration = 0
	self.welrod.panic_suppression_chance = 0.01
	self.welrod.gui = {}
	self.welrod.gui.rotation_offset = -4
	self.welrod.gui.distance_offset = -80
	self.welrod.gui.height_offset = -9
	self.welrod.gui.display_offset = 12
	self.welrod.gui.initial_rotation = {}
	self.welrod.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.welrod.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.welrod.gui.initial_rotation.roll = 0
	self.welrod.gui.icon_large = "weapon_welrod_large"
	self.welrod.hud = {}
	self.welrod.hud.icon = "weapon_panel_welrod"
	self.welrod.hud.panel_class = "clip_shots"
	self.welrod.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.welrod.hud.panel_clip_icon_spent = "9mm_spent"
	self.welrod.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.welrod.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.welrod.hud.panel_clip_icon_thin_min = 20
	self.welrod.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 16,
		spread = 6,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 14,
		concealment = 29
	}
end

function WeaponTweakData:_init_shotty(weapon_data)
	self.shotty = {}
	self.shotty.inventory_texture = "ui/temp/customization_temp_df"
	self.shotty.category = WeaponTweakData.WEAPON_CATEGORY_SHOTGUN
	self.shotty.use_shotgun_reload = false
	self.shotty.dismember_chance = 0.33
	self.shotty.damage_melee = 108
	self.shotty.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.shotty.sounds = {}
	self.shotty.sounds.fire = "shotty_fire_1p_single"
	self.shotty.sounds.dryfire = "primary_dryfire"
	self.shotty.timers = {}
	self.shotty.timers.reload_not_empty = 2.1
	self.shotty.timers.reload_empty = 2.1
	self.shotty.timers.unequip = 0.85
	self.shotty.timers.equip = 0.75
	self.shotty.name_id = "bm_w_shotty"
	self.shotty.desc_id = "bm_w_shotty_desc"
	self.shotty.description_id = "des_shotty"
	self.shotty.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.shotty.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.shotty.use_data = {}
	self.shotty.use_data.selection_index = 1
	self.shotty.use_data.align_place = "right_hand"
	self.shotty.damage_profile = {
		{
			damage = 145,
			range = 700
		},
		{
			damage = 25,
			range = 1500
		}
	}
	self.shotty.headshot_multiplier = 3
	self.shotty.rays = 12
	self.shotty.CLIP_AMMO_MAX = 2
	self.shotty.NR_CLIPS_MAX = 12
	self.shotty.AMMO_MAX = self.shotty.CLIP_AMMO_MAX * self.shotty.NR_CLIPS_MAX
	self.shotty.AMMO_PICKUP = self:_pickup_chance(self.shotty.AMMO_MAX, 1)
	self.shotty.ammo_pickup_base = 2
	self.shotty.FIRE_MODE = "single"
	self.shotty.fire_mode_data = {}
	self.shotty.fire_mode_data.fire_rate = 0.2
	self.shotty.CAN_TOGGLE_FIREMODE = false
	self.shotty.single = {}
	self.shotty.single.fire_rate = 0.2
	self.shotty.spread = {}
	self.shotty.spread.standing = 5
	self.shotty.spread.crouching = 5
	self.shotty.spread.steelsight = 5
	self.shotty.spread.moving_standing = 5
	self.shotty.spread.moving_crouching = 5
	self.shotty.spread.moving_steelsight = 5
	self.shotty.spread.per_shot = 0
	self.shotty.spread.per_shot_steelsight = 0
	self.shotty.spread.recovery = 12
	self.shotty.spread.recovery_wait_multiplier = 0.5
	self.shotty.kick = {}
	self.shotty.kick.standing = {
		8.3,
		9.6,
		-4.9,
		4.7
	}
	self.shotty.kick.crouching = {
		7.8,
		9.4,
		-4.6,
		4.9
	}
	self.shotty.kick.steelsight = {
		7.7,
		8.7,
		-4.6,
		4.8
	}
	self.shotty.kick.crouching_steelsight = {
		7.4,
		7.5,
		-4.2,
		4.2
	}
	self.shotty.gun_kick = {}
	self.shotty.gun_kick.hip_fire = {
		142,
		184,
		-127,
		127
	}
	self.shotty.gun_kick.steelsight = {
		116,
		138,
		-109,
		-109
	}
	self.shotty.gun_kick.position_ratio = -0.075
	self.shotty.crosshair = {}
	self.shotty.crosshair.standing = {}
	self.shotty.crosshair.crouching = {}
	self.shotty.crosshair.steelsight = {}
	self.shotty.crosshair.standing.offset = 0.7
	self.shotty.crosshair.standing.moving_offset = 0.7
	self.shotty.crosshair.standing.kick_offset = 0.8
	self.shotty.crosshair.crouching.offset = 0.65
	self.shotty.crosshair.crouching.moving_offset = 0.65
	self.shotty.crosshair.crouching.kick_offset = 0.75
	self.shotty.crosshair.steelsight.hidden = true
	self.shotty.crosshair.steelsight.offset = 0
	self.shotty.crosshair.steelsight.moving_offset = 0
	self.shotty.crosshair.steelsight.kick_offset = 0
	self.shotty.shake = {}
	self.shotty.shake.fire_multiplier = 2
	self.shotty.shake.fire_steelsight_multiplier = -2
	self.shotty.autohit = weapon_data.autohit_shotgun_default
	self.shotty.aim_assist = weapon_data.aim_assist_shotgun_default
	self.shotty.weapon_hold = "shotty"
	self.shotty.animations = {}
	self.shotty.animations.equip_id = "equip_shotty"
	self.shotty.animations.recoil_steelsight = true
	self.shotty.panic_suppression_chance = 0.1
	self.shotty.gui = {}
	self.shotty.gui.rotation_offset = -10
	self.shotty.gui.distance_offset = -80
	self.shotty.gui.height_offset = -9
	self.shotty.gui.display_offset = 10
	self.shotty.gui.initial_rotation = {}
	self.shotty.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.shotty.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH_PISTOL
	self.shotty.gui.initial_rotation.roll = 0
	self.shotty.gui.icon_large = "weapon_panel_shotty"
	self.shotty.hud = {}
	self.shotty.hud.icon = "weapon_panel_shotty"
	self.shotty.hud.panel_class = "clip_shots"
	self.shotty.hud.panel_clip_icon_spent = "shell_spent"
	self.shotty.hud.panel_clip_icon_loaded = "shell_loaded"
	self.shotty.hud.panel_clip_icon_loaded_thin = "shell_small_loaded"
	self.shotty.hud.panel_clip_icon_spent_thin = "shell_small_spent"
	self.shotty.hud.panel_clip_icon_thin_min = 2
	self.shotty.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 11,
		value = 1,
		extra_ammo = 6,
		suppression = 6,
		concealment = 12
	}
end

function WeaponTweakData:_init_geco(weapon_data)
	self.geco = {}
	self.geco.inventory_texture = "ui/temp/customization_temp_df"
	self.geco.category = WeaponTweakData.WEAPON_CATEGORY_SHOTGUN
	self.geco.use_shotgun_reload = false
	self.geco.dismember_chance = 0.33
	self.geco.damage_melee = 108
	self.geco.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.geco.sounds = {}
	self.geco.sounds.fire = "double_barrel_fire_1p_single"
	self.geco.sounds.dryfire = "primary_dryfire"
	self.geco.timers = {}
	self.geco.timers.reload_not_empty = 2.1
	self.geco.timers.reload_empty = 2.1
	self.geco.timers.unequip = 0.85
	self.geco.timers.equip = 0.75
	self.geco.name_id = "bm_w_geco"
	self.geco.desc_id = "bm_w_geco_desc"
	self.geco.description_id = "des_geco"
	self.geco.muzzleflash = "effects/vanilla/weapons/12g_auto_fps"
	self.geco.shell_ejection = "effects/vanilla/weapons/shells/shell_empty"
	self.geco.use_data = {}
	self.geco.use_data.selection_index = 2
	self.geco.use_data.align_place = "right_hand"
	self.geco.damage_profile = {
		{
			damage = 250,
			range = 1000
		},
		{
			damage = 20,
			range = 1750
		}
	}
	self.geco.headshot_multiplier = 3
	self.geco.rays = 12
	self.geco.CLIP_AMMO_MAX = 2
	self.geco.NR_CLIPS_MAX = 15
	self.geco.AMMO_MAX = self.geco.CLIP_AMMO_MAX * self.geco.NR_CLIPS_MAX
	self.geco.AMMO_PICKUP = self:_pickup_chance(self.geco.AMMO_MAX, 1)
	self.geco.ammo_pickup_base = 3
	self.geco.FIRE_MODE = "single"
	self.geco.fire_mode_data = {}
	self.geco.fire_mode_data.fire_rate = 0.2
	self.geco.CAN_TOGGLE_FIREMODE = false
	self.geco.single = {}
	self.geco.single.fire_rate = 0.2
	self.geco.spread = {}
	self.geco.spread.standing = 4
	self.geco.spread.crouching = 4
	self.geco.spread.steelsight = 4
	self.geco.spread.moving_standing = 4
	self.geco.spread.moving_crouching = 4
	self.geco.spread.moving_steelsight = 4
	self.geco.spread.per_shot = 0
	self.geco.spread.per_shot_steelsight = 0
	self.geco.spread.recovery = 12
	self.geco.spread.recovery_wait_multiplier = 0.5
	self.geco.kick = {}
	self.geco.kick.standing = {
		7.9,
		9.2,
		-4.4,
		4.4
	}
	self.geco.kick.crouching = {
		7,
		8.4,
		-4.4,
		4.4
	}
	self.geco.kick.steelsight = {
		7.5,
		8.4,
		-4.4,
		4.4
	}
	self.geco.kick.crouching_steelsight = {
		7,
		7.5,
		-4,
		4
	}
	self.geco.gun_kick = {}
	self.geco.gun_kick.hip_fire = {
		132,
		176,
		-121,
		121
	}
	self.geco.gun_kick.steelsight = {
		106,
		128,
		-99,
		-99
	}
	self.geco.gun_kick.position_ratio = -0.075
	self.geco.crosshair = {}
	self.geco.crosshair.standing = {}
	self.geco.crosshair.crouching = {}
	self.geco.crosshair.steelsight = {}
	self.geco.crosshair.standing.offset = 0.7
	self.geco.crosshair.standing.moving_offset = 0.7
	self.geco.crosshair.standing.kick_offset = 0.8
	self.geco.crosshair.crouching.offset = 0.65
	self.geco.crosshair.crouching.moving_offset = 0.65
	self.geco.crosshair.crouching.kick_offset = 0.75
	self.geco.crosshair.steelsight.hidden = true
	self.geco.crosshair.steelsight.offset = 0
	self.geco.crosshair.steelsight.moving_offset = 0
	self.geco.crosshair.steelsight.kick_offset = 0
	self.geco.shake = {}
	self.geco.shake.fire_multiplier = 2
	self.geco.shake.fire_steelsight_multiplier = -2
	self.geco.autohit = weapon_data.autohit_shotgun_default
	self.geco.aim_assist = weapon_data.aim_assist_shotgun_default
	self.geco.weapon_hold = "geco"
	self.geco.animations = {}
	self.geco.animations.equip_id = "equip_geco"
	self.geco.animations.recoil_steelsight = true
	self.geco.panic_suppression_chance = 0.25
	self.geco.gui = {}
	self.geco.gui.rotation_offset = -20
	self.geco.gui.distance_offset = 10
	self.geco.gui.height_offset = -8
	self.geco.gui.display_offset = 0
	self.geco.gui.initial_rotation = {}
	self.geco.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.geco.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.geco.gui.initial_rotation.roll = 0
	self.geco.gui.icon_large = "weapon_sho_geco_large"
	self.geco.hud = {}
	self.geco.hud.icon = "weapon_panel_sho_geco"
	self.geco.hud.panel_class = "clip_shots"
	self.geco.hud.panel_clip_icon_spent = "shell_spent"
	self.geco.hud.panel_clip_icon_loaded = "shell_loaded"
	self.geco.hud.panel_clip_icon_loaded_thin = "shell_small_loaded"
	self.geco.hud.panel_clip_icon_spent_thin = "shell_small_spent"
	self.geco.hud.panel_clip_icon_thin_min = 2
	self.geco.stats = {
		zoom = 3,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 9,
		value = 1,
		extra_ammo = 6,
		suppression = 6,
		concealment = 12
	}
end

function WeaponTweakData:_init_sten_mk2(weapon_data)
	self.sten = {}
	self.sten.inventory_texture = "ui/temp/customization_temp_df"
	self.sten.category = WeaponTweakData.WEAPON_CATEGORY_SMG
	self.sten.dismember_chance = 0.05
	self.sten.sounds = {}
	self.sten.sounds.fire_single = "sten_fire_1p_single"
	self.sten.sounds.fire_auto = "sten_fire_1p"
	self.sten.sounds.stop_fire = "sten_fire_1p_stop"
	self.sten.sounds.dryfire = "primary_dryfire"
	self.sten.timers = {}
	self.sten.timers.reload_not_empty = 2.25
	self.sten.timers.reload_empty = 3.25
	self.sten.timers.unequip = 0.75
	self.sten.timers.equip = 0.4
	self.sten.name_id = "bm_w_sten"
	self.sten.desc_id = "bm_w_sten_desc"
	self.sten.description_id = "des_sten"
	self.sten.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.sten.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.sten.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.sten.use_data = {}
	self.sten.use_data.selection_index = 2
	self.sten.damage_melee = 96
	self.sten.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.sten.damage_profile = {
		{
			damage = 70,
			range = 1500
		},
		{
			damage = 55,
			range = 2800
		}
	}
	self.sten.headshot_multiplier = 3.5
	self.sten.CLIP_AMMO_MAX = 32
	self.sten.NR_CLIPS_MAX = 6
	self.sten.AMMO_MAX = self.sten.CLIP_AMMO_MAX * self.sten.NR_CLIPS_MAX
	self.sten.AMMO_PICKUP = self:_pickup_chance(self.sten.AMMO_MAX, 2)
	self.sten.ammo_pickup_base = 19
	self.sten.FIRE_MODE = "auto"
	self.sten.fire_mode_data = {}
	self.sten.fire_mode_data.fire_rate = 0.125
	self.sten.CAN_TOGGLE_FIREMODE = true
	self.sten.auto = {}
	self.sten.auto.fire_rate = 0.125
	self.sten.spread = {}
	self.sten.spread.standing = 3
	self.sten.spread.crouching = 2.8
	self.sten.spread.steelsight = 1.8
	self.sten.spread.moving_standing = self.sten.spread.standing * 1.1
	self.sten.spread.moving_crouching = self.sten.spread.standing * 1.1
	self.sten.spread.moving_steelsight = self.sten.spread.standing * 1.1
	self.sten.spread.per_shot = 0.2
	self.sten.spread.per_shot_steelsight = 0.1
	self.sten.spread.recovery = 6
	self.sten.spread.recovery_wait_multiplier = 3
	self.sten.spread.max = 2.5
	self.sten.kick = {}
	self.sten.kick.standing = {
		1.2,
		1.4,
		-2,
		2
	}
	self.sten.kick.crouching = {
		1.1,
		1.3,
		-1.8,
		1.8
	}
	self.sten.kick.steelsight = {
		1,
		1.2,
		-1.7,
		1.7
	}
	self.sten.kick.crouching_steelsight = {
		0.9,
		1.05,
		-1.6,
		1.6
	}
	self.sten.kick.recenter_speed = 500
	self.sten.kick.recenter_speed_steelsight = 500
	self.sten.minimum_view_kick = {}
	self.sten.minimum_view_kick.standing = {
		0,
		0.5
	}
	self.sten.minimum_view_kick.crouching = {
		0,
		0.5
	}
	self.sten.minimum_view_kick.steelsight = {
		0,
		0.7
	}
	self.sten.minimum_view_kick.crouching_steelsight = {
		0,
		0.6
	}
	self.sten.gun_kick = {}
	self.sten.gun_kick.hip_fire = {
		-40,
		40,
		-40,
		40
	}
	self.sten.gun_kick.steelsight = {
		-10,
		25,
		-15,
		35
	}
	self.sten.gun_kick.position_ratio = 0.1
	self.sten.crosshair = {}
	self.sten.crosshair.standing = {}
	self.sten.crosshair.crouching = {}
	self.sten.crosshair.steelsight = {}
	self.sten.crosshair.standing.offset = 0.16
	self.sten.crosshair.standing.moving_offset = 0.8
	self.sten.crosshair.standing.kick_offset = 0.6
	self.sten.crosshair.crouching.offset = 0.08
	self.sten.crosshair.crouching.moving_offset = 0.7
	self.sten.crosshair.crouching.kick_offset = 0.4
	self.sten.crosshair.steelsight.hidden = true
	self.sten.crosshair.steelsight.offset = 0
	self.sten.crosshair.steelsight.moving_offset = 0
	self.sten.crosshair.steelsight.kick_offset = 0.1
	self.sten.shake = {}
	self.sten.shake.fire_multiplier = 1
	self.sten.shake.fire_steelsight_multiplier = -1
	self.sten.autohit = weapon_data.autohit_rifle_default
	self.sten.aim_assist = weapon_data.aim_assist_rifle_default
	self.sten.weapon_hold = "sten"
	self.sten.animations = {}
	self.sten.animations.equip_id = "equip_m4"
	self.sten.animations.magazine_empty = "last_recoil"
	self.sten.animations.recoil_steelsight = true
	self.sten.panic_suppression_chance = 0.05
	self.sten.gui = {}
	self.sten.gui.rotation_offset = -15
	self.sten.gui.distance_offset = -25
	self.sten.gui.height_offset = -13
	self.sten.gui.display_offset = 5
	self.sten.gui.initial_rotation = {}
	self.sten.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.sten.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.sten.gui.initial_rotation.roll = 0
	self.sten.gui.icon_large = "weapon_smg_sten_large"
	self.sten.hud = {}
	self.sten.hud.icon = "weapon_panel_smg_sten"
	self.sten.hud.panel_class = "clip_shots"
	self.sten.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.sten.hud.panel_clip_icon_spent = "9mm_spent"
	self.sten.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.sten.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.sten.hud.panel_clip_icon_thin_min = 20
	self.sten.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 5,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 17
	}
end

function WeaponTweakData:_init_thompson(weapon_data)
	self.thompson = {}
	self.thompson.inventory_texture = "ui/temp/customization_temp_df"
	self.thompson.category = WeaponTweakData.WEAPON_CATEGORY_SMG
	self.thompson.sounds = {}
	self.thompson.sounds.fire_single = "thompson_fire_1p_single"
	self.thompson.sounds.fire_auto = "thompson_fire_1p"
	self.thompson.sounds.stop_fire = "thompson_fire_1p_stop"
	self.thompson.sounds.dryfire = "primary_dryfire"
	self.thompson.timers = {}
	self.thompson.timers.reload_not_empty = 1.55
	self.thompson.timers.reload_empty = 2.5
	self.thompson.timers.unequip = 0.75
	self.thompson.timers.equip = 0.4
	self.thompson.name_id = "bm_w_thompson"
	self.thompson.desc_id = "bm_w_thompson_desc"
	self.thompson.description_id = "des_thompson"
	self.thompson.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.thompson.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.thompson.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.thompson.use_data = {}
	self.thompson.use_data.selection_index = 2
	self.thompson.dismember_chance = 0.05
	self.thompson.damage_melee = 96
	self.thompson.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.thompson.damage_profile = {
		{
			damage = 58,
			range = 1500
		},
		{
			damage = 35,
			range = 2500
		}
	}
	self.thompson.headshot_multiplier = 3.5
	self.thompson.CLIP_AMMO_MAX = 20
	self.thompson.NR_CLIPS_MAX = 10
	self.thompson.AMMO_MAX = self.thompson.CLIP_AMMO_MAX * self.thompson.NR_CLIPS_MAX
	self.thompson.AMMO_PICKUP = self:_pickup_chance(self.thompson.AMMO_MAX, 2)
	self.thompson.ammo_pickup_base = 20
	self.thompson.FIRE_MODE = "auto"
	self.thompson.fire_mode_data = {}
	self.thompson.fire_mode_data.fire_rate = 0.1
	self.thompson.CAN_TOGGLE_FIREMODE = true
	self.thompson.auto = {}
	self.thompson.auto.fire_rate = 0.1
	self.thompson.spread = {}
	self.thompson.spread.standing = 2.75
	self.thompson.spread.crouching = 2.5
	self.thompson.spread.steelsight = 1.5
	self.thompson.spread.moving_standing = self.thompson.spread.standing * 1.1
	self.thompson.spread.moving_crouching = self.thompson.spread.standing * 1.1
	self.thompson.spread.moving_steelsight = self.thompson.spread.standing * 1.1
	self.thompson.spread.per_shot = 0.15
	self.thompson.spread.per_shot_steelsight = 0.1
	self.thompson.spread.recovery = 10
	self.thompson.spread.recovery_wait_multiplier = 3
	self.thompson.spread.max = 1.75
	self.thompson.kick = {}
	self.thompson.kick.standing = {
		1,
		1.2,
		-1,
		1.5
	}
	self.thompson.kick.crouching = {
		1,
		1.15,
		-0.9,
		1.4
	}
	self.thompson.kick.steelsight = {
		0.8,
		1,
		-0.6,
		1
	}
	self.thompson.kick.crouching_steelsight = {
		0.8,
		0.9,
		-0.55,
		0.9
	}
	self.thompson.minimum_view_kick = {}
	self.thompson.minimum_view_kick.standing = {
		0,
		0.3
	}
	self.thompson.minimum_view_kick.crouching = {
		0,
		0.5
	}
	self.thompson.minimum_view_kick.steelsight = {
		0,
		0.5
	}
	self.thompson.minimum_view_kick.crouching_steelsight = {
		0,
		0.5
	}
	self.thompson.gun_kick = {}
	self.thompson.gun_kick.hip_fire = {
		-20,
		30,
		-35,
		35
	}
	self.thompson.gun_kick.steelsight = {
		20,
		28,
		-20,
		20
	}
	self.thompson.gun_kick.position_ratio = 0.23
	self.thompson.crosshair = {}
	self.thompson.crosshair.standing = {}
	self.thompson.crosshair.crouching = {}
	self.thompson.crosshair.steelsight = {}
	self.thompson.crosshair.standing.offset = 0.16
	self.thompson.crosshair.standing.moving_offset = 0.8
	self.thompson.crosshair.standing.kick_offset = 0.6
	self.thompson.crosshair.crouching.offset = 0.08
	self.thompson.crosshair.crouching.moving_offset = 0.7
	self.thompson.crosshair.crouching.kick_offset = 0.4
	self.thompson.crosshair.steelsight.hidden = true
	self.thompson.crosshair.steelsight.offset = 0
	self.thompson.crosshair.steelsight.moving_offset = 0
	self.thompson.crosshair.steelsight.kick_offset = 0.1
	self.thompson.shake = {}
	self.thompson.shake.fire_multiplier = 0.5
	self.thompson.shake.fire_steelsight_multiplier = -0.5
	self.thompson.autohit = weapon_data.autohit_rifle_default
	self.thompson.aim_assist = weapon_data.aim_assist_rifle_default
	self.thompson.weapon_hold = "thompson"
	self.thompson.animations = {}
	self.thompson.animations.equip_id = "equip_m4"
	self.thompson.animations.magazine_empty = "last_recoil"
	self.thompson.animations.recoil_steelsight = true
	self.thompson.panic_suppression_chance = 0.075
	self.thompson.gui = {}
	self.thompson.gui.rotation_offset = -14
	self.thompson.gui.distance_offset = -5
	self.thompson.gui.height_offset = -12
	self.thompson.gui.display_offset = -2
	self.thompson.gui.initial_rotation = {}
	self.thompson.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.thompson.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.thompson.gui.initial_rotation.roll = 0
	self.thompson.gui.icon_large = "weapon_smg_thompson_large"
	self.thompson.hud = {}
	self.thompson.hud.icon = "weapon_panel_smg_thompson"
	self.thompson.hud.panel_class = "clip_shots"
	self.thompson.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.thompson.hud.panel_clip_icon_spent = "9mm_spent"
	self.thompson.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.thompson.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.thompson.hud.panel_clip_icon_thin_min = 20
	self.thompson.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 4,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 17
	}
end

function WeaponTweakData:_init_mp38(weapon_data)
	self.mp38 = {}
	self.mp38.inventory_texture = "ui/temp/customization_temp_df"
	self.mp38.category = WeaponTweakData.WEAPON_CATEGORY_SMG
	self.mp38.sounds = {}
	self.mp38.sounds.fire_single = "mp38_fire_1p_single"
	self.mp38.sounds.fire_auto = "mp38_fire_1p"
	self.mp38.sounds.stop_fire = "mp38_fire_1p_stop"
	self.mp38.sounds.dryfire = "primary_dryfire"
	self.mp38.timers = {}
	self.mp38.timers.reload_not_empty = 1.66
	self.mp38.timers.reload_empty = 2.76
	self.mp38.timers.unequip = 0.75
	self.mp38.timers.equip = 0.4
	self.mp38.name_id = "bm_w_mp38"
	self.mp38.desc_id = "bm_w_mp38_desc"
	self.mp38.description_id = "des_mp38"
	self.mp38.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.mp38.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.mp38.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.mp38.use_data = {}
	self.mp38.use_data.selection_index = 2
	self.mp38.dismember_chance = 0.05
	self.mp38.damage_melee = 96
	self.mp38.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.mp38.damage_profile = {
		{
			damage = 75,
			range = 1500
		},
		{
			damage = 45,
			range = 3000
		}
	}
	self.mp38.headshot_multiplier = 3.5
	self.mp38.CLIP_AMMO_MAX = 32
	self.mp38.NR_CLIPS_MAX = 6
	self.mp38.AMMO_MAX = self.mp38.CLIP_AMMO_MAX * self.mp38.NR_CLIPS_MAX
	self.mp38.AMMO_PICKUP = self:_pickup_chance(self.mp38.AMMO_MAX, 2)
	self.mp38.ammo_pickup_base = 19
	self.mp38.FIRE_MODE = "auto"
	self.mp38.fire_mode_data = {}
	self.mp38.fire_mode_data.fire_rate = 0.125
	self.mp38.CAN_TOGGLE_FIREMODE = false
	self.mp38.auto = {}
	self.mp38.auto.fire_rate = 0.125
	self.mp38.spread = {}
	self.mp38.spread.standing = 2.25
	self.mp38.spread.crouching = 2
	self.mp38.spread.steelsight = 1.25
	self.mp38.spread.moving_standing = self.mp38.spread.standing * 1.1
	self.mp38.spread.moving_crouching = self.mp38.spread.standing * 1.1
	self.mp38.spread.moving_steelsight = self.mp38.spread.standing * 1.1
	self.mp38.spread.per_shot = 0.2
	self.mp38.spread.per_shot_steelsight = 0.15
	self.mp38.spread.recovery = 10
	self.mp38.spread.recovery_wait_multiplier = 3
	self.mp38.spread.max = 1.5
	self.mp38.kick = {}
	self.mp38.kick.standing = {
		2.4,
		2.6,
		-2.35,
		2.35
	}
	self.mp38.kick.crouching = {
		2.2,
		2.3,
		-2.2,
		2.2
	}
	self.mp38.kick.steelsight = {
		1.8,
		2.1,
		-2.1,
		2.1
	}
	self.mp38.kick.crouching_steelsight = {
		1.8,
		2,
		-1.9,
		1.9
	}
	self.mp38.gun_kick = {}
	self.mp38.gun_kick.hip_fire = {
		-10,
		40,
		-30,
		35
	}
	self.mp38.gun_kick.steelsight = {
		-10,
		22,
		-25,
		25
	}
	self.mp38.gun_kick.position_ratio = -0.06
	self.mp38.crosshair = {}
	self.mp38.crosshair.standing = {}
	self.mp38.crosshair.crouching = {}
	self.mp38.crosshair.steelsight = {}
	self.mp38.crosshair.standing.offset = 0.16
	self.mp38.crosshair.standing.moving_offset = 0.8
	self.mp38.crosshair.standing.kick_offset = 0.6
	self.mp38.crosshair.crouching.offset = 0.08
	self.mp38.crosshair.crouching.moving_offset = 0.7
	self.mp38.crosshair.crouching.kick_offset = 0.4
	self.mp38.crosshair.steelsight.hidden = true
	self.mp38.crosshair.steelsight.offset = 0
	self.mp38.crosshair.steelsight.moving_offset = 0
	self.mp38.crosshair.steelsight.kick_offset = 0.1
	self.mp38.shake = {}
	self.mp38.shake.fire_multiplier = 1
	self.mp38.shake.fire_steelsight_multiplier = -1
	self.mp38.autohit = weapon_data.autohit_rifle_default
	self.mp38.aim_assist = weapon_data.aim_assist_rifle_default
	self.mp38.weapon_hold = "mp38"
	self.mp38.animations = {}
	self.mp38.animations.equip_id = "equip_m4"
	self.mp38.animations.recoil_steelsight = true
	self.mp38.panic_suppression_chance = 0.1
	self.mp38.gui = {}
	self.mp38.gui.rotation_offset = -14
	self.mp38.gui.distance_offset = -8
	self.mp38.gui.height_offset = -13
	self.mp38.gui.display_offset = -2
	self.mp38.gui.initial_rotation = {}
	self.mp38.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.mp38.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.mp38.gui.initial_rotation.roll = 0
	self.mp38.gui.icon_large = "weapon_smg_mp38_large"
	self.mp38.hud = {}
	self.mp38.hud.icon = "weapon_panel_smg_mp38"
	self.mp38.hud.panel_class = "clip_shots"
	self.mp38.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.mp38.hud.panel_clip_icon_spent = "9mm_spent"
	self.mp38.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.mp38.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.mp38.hud.panel_clip_icon_thin_min = 20
	self.mp38.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 7,
		recoil = 10,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 17
	}
end

function WeaponTweakData:_init_sterling(weapon_data)
	self.sterling = {}
	self.sterling.inventory_texture = "ui/temp/customization_temp_df"
	self.sterling.category = WeaponTweakData.WEAPON_CATEGORY_SMG
	self.sterling.sounds = {}
	self.sterling.sounds.fire_single = "sterling_fire_1p_single"
	self.sterling.sounds.fire_auto = "sterling_fire_1p"
	self.sterling.sounds.stop_fire = "sterling_fire_1p_stop"
	self.sterling.sounds.dryfire = "primary_dryfire"
	self.sterling.timers = {}
	self.sterling.timers.reload_not_empty = 2.2
	self.sterling.timers.reload_empty = 2.9
	self.sterling.timers.unequip = 0.55
	self.sterling.timers.equip = 0.65
	self.sterling.name_id = "bm_w_sterling"
	self.sterling.desc_id = "bm_w_sterling_desc"
	self.sterling.description_id = "des_sterling"
	self.sterling.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.sterling.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.sterling.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.sterling.use_data = {}
	self.sterling.use_data.selection_index = 2
	self.sterling.damage_melee = 96
	self.sterling.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.sterling.damage_profile = {
		{
			damage = 80,
			range = 1000
		},
		{
			damage = 42,
			range = 2500
		}
	}
	self.sterling.headshot_multiplier = 3.5
	self.sterling.CLIP_AMMO_MAX = 20
	self.sterling.NR_CLIPS_MAX = 10
	self.sterling.AMMO_MAX = self.sterling.CLIP_AMMO_MAX * self.sterling.NR_CLIPS_MAX
	self.sterling.AMMO_PICKUP = self:_pickup_chance(self.sterling.AMMO_MAX, 2)
	self.sterling.ammo_pickup_base = 20
	self.sterling.FIRE_MODE = "auto"
	self.sterling.fire_mode_data = {}
	self.sterling.fire_mode_data.fire_rate = 0.11
	self.sterling.CAN_TOGGLE_FIREMODE = true
	self.sterling.auto = {}
	self.sterling.auto.fire_rate = 0.11
	self.sterling.spread = {}
	self.sterling.spread.standing = 3
	self.sterling.spread.crouching = 2.8
	self.sterling.spread.steelsight = 1.8
	self.sterling.spread.moving_standing = self.sterling.spread.standing * 1.1
	self.sterling.spread.moving_crouching = self.sterling.spread.standing * 1.1
	self.sterling.spread.moving_steelsight = self.sterling.spread.standing * 1.1
	self.sterling.spread.per_shot = 0.15
	self.sterling.spread.per_shot_steelsight = 0.1
	self.sterling.spread.recovery = 8
	self.sterling.spread.recovery_wait_multiplier = 3
	self.sterling.spread.max = 2.5
	self.sterling.kick = {}
	self.sterling.kick.standing = {
		1.55,
		1.85,
		-2,
		2
	}
	self.sterling.kick.crouching = {
		1.5,
		1.7,
		-1.8,
		1.8
	}
	self.sterling.kick.steelsight = {
		1.2,
		1.4,
		-1.45,
		1.45
	}
	self.sterling.kick.crouching_steelsight = {
		1.05,
		1.1,
		-1.3,
		1.3
	}
	self.sterling.recenter_speed = 1200
	self.sterling.recenter_speed_steelsight = 1200
	self.sterling.gun_kick = {}
	self.sterling.gun_kick.hip_fire = {
		-25,
		35,
		-30,
		30
	}
	self.sterling.gun_kick.steelsight = {
		9,
		12,
		-28,
		-12
	}
	self.sterling.gun_kick.position_ratio = 0.125
	self.sterling.crosshair = {}
	self.sterling.crosshair.standing = {}
	self.sterling.crosshair.crouching = {}
	self.sterling.crosshair.steelsight = {}
	self.sterling.crosshair.standing.offset = 0.5
	self.sterling.crosshair.standing.moving_offset = 0.8
	self.sterling.crosshair.standing.kick_offset = 0.7
	self.sterling.crosshair.crouching.offset = 0.3
	self.sterling.crosshair.crouching.moving_offset = 0.6
	self.sterling.crosshair.crouching.kick_offset = 0.5
	self.sterling.crosshair.steelsight.hidden = true
	self.sterling.crosshair.steelsight.offset = 0
	self.sterling.crosshair.steelsight.moving_offset = 0
	self.sterling.crosshair.steelsight.kick_offset = 0.3
	self.sterling.shake = {}
	self.sterling.shake.fire_multiplier = 0.8
	self.sterling.shake.fire_steelsight_multiplier = -0.8
	self.sterling.autohit = weapon_data.autohit_smg_default
	self.sterling.aim_assist = weapon_data.aim_assist_smg_default
	self.sterling.weapon_hold = "sterling"
	self.sterling.animations = {}
	self.sterling.animations.equip_id = "equip_sterling"
	self.sterling.animations.magazine_empty = "last_recoil"
	self.sterling.animations.recoil_steelsight = true
	self.sterling.panic_suppression_chance = 0.05
	self.sterling.gui = {}
	self.sterling.gui.rotation_offset = -8
	self.sterling.gui.distance_offset = -10
	self.sterling.gui.height_offset = -13
	self.sterling.gui.display_offset = -2
	self.sterling.gui.initial_rotation = {}
	self.sterling.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.sterling.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.sterling.gui.initial_rotation.roll = 0
	self.sterling.gui.icon_large = "weapon_smg_sterling_large"
	self.sterling.hud = {}
	self.sterling.hud.icon = "weapon_panel_smg_sterling"
	self.sterling.hud.panel_class = "clip_shots"
	self.sterling.hud.panel_clip_icon_loaded = "9mm_loaded"
	self.sterling.hud.panel_clip_icon_spent = "9mm_spent"
	self.sterling.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.sterling.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.sterling.hud.panel_clip_icon_thin_min = 20
	self.sterling.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 4,
		value = 7,
		extra_ammo = 6,
		suppression = 12,
		concealment = 20
	}
end

function WeaponTweakData:_init_m1_carbine(weapon_data)
	self.carbine = {}
	self.carbine.inventory_texture = "ui/temp/customization_temp_df"
	self.carbine.category = WeaponTweakData.WEAPON_CATEGORY_ASSAULT_RIFLE
	self.carbine.dismember_chance = 0.1
	self.carbine.damage_melee = 108
	self.carbine.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.carbine.sounds = {}
	self.carbine.sounds.fire_single = "m1_carbine_fire_1p"
	self.carbine.sounds.dryfire = "primary_dryfire"
	self.carbine.timers = {}
	self.carbine.timers.reload_not_empty = 2
	self.carbine.timers.reload_empty = 2.8
	self.carbine.timers.unequip = 0.75
	self.carbine.timers.equip = 0.4
	self.carbine.name_id = "bm_w_carbine"
	self.carbine.desc_id = "bm_w_carbine_desc"
	self.carbine.description_id = "des_carbine"
	self.carbine.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.carbine.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.carbine.shell_ejection = "effects/vanilla/weapons/shells/shell_carbine"
	self.carbine.use_data = {}
	self.carbine.use_data.selection_index = 2
	self.carbine.damage_profile = {
		{
			damage = 92,
			range = 2000
		},
		{
			damage = 55,
			range = 4000
		}
	}
	self.carbine.headshot_multiplier = 4
	self.carbine.CLIP_AMMO_MAX = 15
	self.carbine.NR_CLIPS_MAX = 10
	self.carbine.AMMO_MAX = self.carbine.CLIP_AMMO_MAX * self.carbine.NR_CLIPS_MAX
	self.carbine.AMMO_PICKUP = self:_pickup_chance(self.carbine.AMMO_MAX, 2)
	self.carbine.ammo_pickup_base = 15
	self.carbine.FIRE_MODE = "single"
	self.carbine.fire_mode_data = {}
	self.carbine.fire_mode_data.fire_rate = self:convert_rpm(520)
	self.carbine.CAN_TOGGLE_FIREMODE = false
	self.carbine.spread = {}
	self.carbine.spread.standing = 2.5
	self.carbine.spread.crouching = 1.75
	self.carbine.spread.steelsight = 0.5
	self.carbine.spread.moving_standing = 3.75
	self.carbine.spread.moving_crouching = 2.63
	self.carbine.spread.moving_steelsight = 0.63
	self.carbine.spread.per_shot = 0.2
	self.carbine.spread.per_shot_steelsight = 0.08
	self.carbine.spread.recovery = 7
	self.carbine.spread.recovery_wait_multiplier = 1.5
	self.carbine.kick = {}
	self.carbine.kick.standing = {
		2.2,
		2.4,
		-2,
		2
	}
	self.carbine.kick.crouching = {
		2.1,
		2.2,
		-1.9,
		1.8
	}
	self.carbine.kick.steelsight = {
		2,
		2.15,
		-1.2,
		1.2
	}
	self.carbine.kick.crouching_steelsight = {
		1.8,
		2.1,
		-1.05,
		1.05
	}
	self.carbine.kick.recenter_speed = 300
	self.carbine.kick.recenter_speed_steelsight = 300
	self.carbine.minimum_view_kick = {}
	self.carbine.minimum_view_kick.standing = {
		0,
		0.65
	}
	self.carbine.minimum_view_kick.crouching = {
		0,
		0.7
	}
	self.carbine.minimum_view_kick.steelsight = {
		0,
		0.6
	}
	self.carbine.minimum_view_kick.crouching_steelsight = {
		0,
		0.55
	}
	self.carbine.gun_kick = {}
	self.carbine.gun_kick.hip_fire = {
		24,
		35,
		-24,
		24
	}
	self.carbine.gun_kick.steelsight = {
		18,
		24,
		-24,
		-5
	}
	self.carbine.gun_kick.position_ratio = -0.1
	self.carbine.crosshair = {}
	self.carbine.crosshair.standing = {}
	self.carbine.crosshair.crouching = {}
	self.carbine.crosshair.steelsight = {}
	self.carbine.crosshair.standing.offset = 0.16
	self.carbine.crosshair.standing.moving_offset = 0.8
	self.carbine.crosshair.standing.kick_offset = 0.6
	self.carbine.crosshair.crouching.offset = 0.08
	self.carbine.crosshair.crouching.moving_offset = 0.7
	self.carbine.crosshair.crouching.kick_offset = 0.4
	self.carbine.crosshair.steelsight.hidden = true
	self.carbine.crosshair.steelsight.offset = 0
	self.carbine.crosshair.steelsight.moving_offset = 0
	self.carbine.crosshair.steelsight.kick_offset = 0.1
	self.carbine.shake = {}
	self.carbine.shake.fire_multiplier = 1
	self.carbine.shake.fire_steelsight_multiplier = -1
	self.carbine.autohit = weapon_data.autohit_rifle_default
	self.carbine.aim_assist = weapon_data.aim_assist_rifle_default
	self.carbine.weapon_hold = "carbine"
	self.carbine.animations = {}
	self.carbine.animations.magazine_empty = "last_recoil"
	self.carbine.animations.equip_id = "equip_m4"
	self.carbine.animations.recoil_steelsight = true
	self.carbine.panic_suppression_chance = 0.13
	self.carbine.gui = {}
	self.carbine.gui.rotation_offset = -15
	self.carbine.gui.distance_offset = -4
	self.carbine.gui.height_offset = -12
	self.carbine.gui.display_offset = 4
	self.carbine.gui.initial_rotation = {}
	self.carbine.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.carbine.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.carbine.gui.initial_rotation.roll = 0
	self.carbine.gui.icon_large = "weapon_ass_carbine_large"
	self.carbine.hud = {}
	self.carbine.hud.icon = "weapon_panel_ass_carbine"
	self.carbine.hud.panel_class = "clip_shots"
	self.carbine.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.carbine.hud.panel_clip_icon_spent = "rifle_spent"
	self.carbine.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.carbine.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.carbine.hud.panel_clip_icon_stack_min = 16
	self.carbine.hud.panel_clip_icon_thin_min = 16
	self.carbine.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 9,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 17
	}
end

function WeaponTweakData:_init_m1_garand(weapon_data)
	self.garand = {}
	self.garand.inventory_texture = "ui/temp/customization_temp_df"
	self.garand.category = WeaponTweakData.WEAPON_CATEGORY_ASSAULT_RIFLE
	self.garand.dismember_chance = 0.15
	self.garand.damage_melee = 108
	self.garand.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.garand.sounds = {}
	self.garand.sounds.fire_single = "m1garand_fire_1p"
	self.garand.sounds.dryfire = "primary_dryfire"
	self.garand.sounds.magazine_empty = "wp_garand_clip_eject"
	self.garand.timers = {}
	self.garand.timers.reload_not_empty = 3.3
	self.garand.timers.reload_empty = 1.55
	self.garand.timers.unequip = 0.8
	self.garand.timers.equip = 0.8
	self.garand.name_id = "bm_w_garand"
	self.garand.desc_id = "bm_w_garand_desc"
	self.garand.description_id = "des_garand"
	self.garand.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.garand.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.garand.use_data = {}
	self.garand.use_data.selection_index = 2
	self.garand.damage_profile = {
		{
			damage = 134,
			range = 3000
		},
		{
			damage = 94,
			range = 6000
		}
	}
	self.garand.headshot_multiplier = 4
	self.garand.CLIP_AMMO_MAX = 8
	self.garand.NR_CLIPS_MAX = 10
	self.garand.AMMO_MAX = self.garand.CLIP_AMMO_MAX * self.garand.NR_CLIPS_MAX
	self.garand.AMMO_PICKUP = {
		0.7,
		1
	}
	self.garand.ammo_pickup_base = 8
	self.garand.FIRE_MODE = "single"
	self.garand.fire_mode_data = {}
	self.garand.fire_mode_data.fire_rate = self:convert_rpm(520)
	self.garand.CAN_TOGGLE_FIREMODE = false
	self.garand.auto = {}
	self.garand.auto.fire_rate = self:convert_rpm(520)
	self.garand.spread = {}
	self.garand.spread.standing = 5
	self.garand.spread.crouching = 3.5
	self.garand.spread.steelsight = 0.5
	self.garand.spread.moving_standing = 7.5
	self.garand.spread.moving_crouching = 5.25
	self.garand.spread.moving_steelsight = 0.63
	self.garand.spread.per_shot = 0.48
	self.garand.spread.per_shot_steelsight = 0.08
	self.garand.spread.recovery = 8
	self.garand.spread.recovery_wait_multiplier = 2
	self.garand.kick = {}
	self.garand.kick.standing = {
		2.8,
		3.2,
		-2,
		2
	}
	self.garand.kick.crouching = {
		2.6,
		2.9,
		-1.8,
		1.8
	}
	self.garand.kick.steelsight = {
		1.7,
		2,
		0,
		1.7
	}
	self.garand.kick.crouching_steelsight = {
		1.65,
		1.9,
		0,
		1.4
	}
	self.garand.minimum_view_kick = {}
	self.garand.minimum_view_kick.standing = {
		0,
		1.6
	}
	self.garand.minimum_view_kick.crouching = {
		0,
		1.45
	}
	self.garand.minimum_view_kick.steelsight = {
		0,
		1.35
	}
	self.garand.minimum_view_kick.crouching_steelsight = {
		0,
		1
	}
	self.garand.gun_kick = {}
	self.garand.gun_kick.hip_fire = {
		35,
		48,
		-40,
		40
	}
	self.garand.gun_kick.steelsight = {
		28,
		35,
		-24,
		-5
	}
	self.garand.gun_kick.position_ratio = 0.02
	self.garand.crosshair = {}
	self.garand.crosshair.standing = {}
	self.garand.crosshair.crouching = {}
	self.garand.crosshair.steelsight = {}
	self.garand.crosshair.standing.offset = 0.16
	self.garand.crosshair.standing.moving_offset = 0.8
	self.garand.crosshair.standing.kick_offset = 0.6
	self.garand.crosshair.crouching.offset = 0.08
	self.garand.crosshair.crouching.moving_offset = 0.7
	self.garand.crosshair.crouching.kick_offset = 0.4
	self.garand.crosshair.steelsight.hidden = true
	self.garand.crosshair.steelsight.offset = 0
	self.garand.crosshair.steelsight.moving_offset = 0
	self.garand.crosshair.steelsight.kick_offset = 0.1
	self.garand.shake = {}
	self.garand.shake.fire_multiplier = 1
	self.garand.shake.fire_steelsight_multiplier = -1
	self.garand.autohit = weapon_data.autohit_rifle_default
	self.garand.aim_assist = weapon_data.aim_assist_rifle_default
	self.garand.weapon_hold = "garand"
	self.garand.animations = {}
	self.garand.animations.magazine_empty = "magazine_empty"
	self.garand.animations.equip_id = "garand"
	self.garand.animations.recoil_steelsight = true
	self.garand.panic_suppression_chance = 0.15
	self.garand.gui = {}
	self.garand.gui.rotation_offset = -26
	self.garand.gui.distance_offset = 40
	self.garand.gui.height_offset = -12
	self.garand.gui.display_offset = -5
	self.garand.gui.initial_rotation = {}
	self.garand.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.garand.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.garand.gui.initial_rotation.roll = 0
	self.garand.gui.icon_large = "weapon_ass_garand_large"
	self.garand.hud = {}
	self.garand.hud.icon = "weapon_panel_ass_garand"
	self.garand.hud.panel_class = "clip_shots"
	self.garand.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.garand.hud.panel_clip_icon_spent = "rifle_spent"
	self.garand.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.garand.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.garand.hud.panel_clip_icon_thin_min = 20
	self.garand.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		recoil = 7,
		alert_size = 7,
		spread = 6,
		spread_moving = 9,
		value = 1,
		extra_ammo = 6,
		suppression = 8,
		concealment = 10
	}
end

function WeaponTweakData:_init_mp44(weapon_data)
	self.mp44 = {}
	self.mp44.inventory_texture = "ui/temp/customization_temp_df"
	self.mp44.category = WeaponTweakData.WEAPON_CATEGORY_ASSAULT_RIFLE
	self.mp44.dismember_chance = 0.15
	self.mp44.damage_melee = 108
	self.mp44.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.mp44.sounds = {}
	self.mp44.sounds.fire_single = "stg44_fire_1p_single"
	self.mp44.sounds.fire_auto = "stg44_fire_1p"
	self.mp44.sounds.stop_fire = "stg44_fire_1p_stop"
	self.mp44.sounds.dryfire = "primary_dryfire"
	self.mp44.timers = {}
	self.mp44.timers.reload_not_empty = 2
	self.mp44.timers.reload_empty = 2.6
	self.mp44.timers.unequip = 0.75
	self.mp44.timers.equip = 0.4
	self.mp44.name_id = "bm_w_mp44"
	self.mp44.desc_id = "bm_w_mp44_desc"
	self.mp44.description_id = "des_mp44"
	self.mp44.muzzleflash = "effects/vanilla/weapons/9mm_auto_fps"
	self.mp44.muzzleflash_silenced = "effects/vanilla/weapons/9mm_auto_silence_fps"
	self.mp44.shell_ejection = "effects/vanilla/weapons/shells/shell_9mm"
	self.mp44.use_data = {}
	self.mp44.use_data.selection_index = 2
	self.mp44.damage_profile = {
		{
			damage = 99,
			range = 2500
		},
		{
			damage = 64,
			range = 5000
		}
	}
	self.mp44.headshot_multiplier = 3.5
	self.mp44.CLIP_AMMO_MAX = 15
	self.mp44.NR_CLIPS_MAX = 10
	self.mp44.AMMO_MAX = self.mp44.CLIP_AMMO_MAX * self.mp44.NR_CLIPS_MAX
	self.mp44.AMMO_PICKUP = self:_pickup_chance(self.mp44.AMMO_MAX, 2)
	self.mp44.ammo_pickup_base = 15
	self.mp44.FIRE_MODE = "auto"
	self.mp44.fire_mode_data = {}
	self.mp44.fire_mode_data.fire_rate = 0.11
	self.mp44.CAN_TOGGLE_FIREMODE = true
	self.mp44.auto = {}
	self.mp44.auto.fire_rate = 0.11
	self.mp44.spread = {}
	self.mp44.spread.standing = 2.45
	self.mp44.spread.crouching = self.mp44.spread.standing * 0.65
	self.mp44.spread.steelsight = self.mp44.spread.standing * 0.35
	self.mp44.spread.moving_standing = self.mp44.spread.standing * 1.2
	self.mp44.spread.moving_crouching = self.mp44.spread.crouching * 1.2
	self.mp44.spread.moving_steelsight = self.mp44.spread.steelsight * 1.15
	self.mp44.spread.per_shot = 0.27
	self.mp44.spread.per_shot_steelsight = 0.15
	self.mp44.spread.recovery = 8.5
	self.mp44.spread.recovery_wait_multiplier = 1.3
	self.mp44.spread.max = 3.5
	self.mp44.kick = {}
	self.mp44.kick.standing = {
		1.7,
		2,
		-2.2,
		2.2
	}
	self.mp44.kick.crouching = {
		1.7,
		1.9,
		-2.1,
		2.1
	}
	self.mp44.kick.steelsight = {
		1.5,
		1.75,
		-1.4,
		1.4
	}
	self.mp44.kick.crouching_steelsight = {
		1.45,
		1.7,
		-1.2,
		1.2
	}
	self.mp44.minimum_kick = {}
	self.mp44.minimum_kick.standing = {
		0,
		0.8
	}
	self.mp44.minimum_kick.crouching = {
		0,
		0.8
	}
	self.mp44.minimum_kick.steelsight = {
		0,
		0.85
	}
	self.mp44.minimum_kick.crouching_steelsight = {
		0,
		0.8
	}
	self.mp44.gun_kick = {}
	self.mp44.gun_kick.hip_fire = {
		-20,
		20,
		10,
		40
	}
	self.mp44.gun_kick.steelsight = {
		16,
		22,
		-22,
		18
	}
	self.mp44.gun_kick.position_ratio = -0.015
	self.mp44.crosshair = {}
	self.mp44.crosshair.standing = {}
	self.mp44.crosshair.crouching = {}
	self.mp44.crosshair.steelsight = {}
	self.mp44.crosshair.standing.offset = 0.16
	self.mp44.crosshair.standing.moving_offset = 0.8
	self.mp44.crosshair.standing.kick_offset = 0.6
	self.mp44.crosshair.crouching.offset = 0.08
	self.mp44.crosshair.crouching.moving_offset = 0.7
	self.mp44.crosshair.crouching.kick_offset = 0.4
	self.mp44.crosshair.steelsight.hidden = true
	self.mp44.crosshair.steelsight.offset = 0
	self.mp44.crosshair.steelsight.moving_offset = 0
	self.mp44.crosshair.steelsight.kick_offset = 0.1
	self.mp44.shake = {}
	self.mp44.shake.fire_multiplier = 1
	self.mp44.shake.fire_steelsight_multiplier = -1
	self.mp44.autohit = weapon_data.autohit_rifle_default
	self.mp44.aim_assist = weapon_data.aim_assist_rifle_default
	self.mp44.weapon_hold = "mp44"
	self.mp44.animations = {}
	self.mp44.animations.equip_id = "equip_m4"
	self.mp44.animations.recoil_steelsight = true
	self.mp44.panic_suppression_chance = 0.15
	self.mp44.gui = {}
	self.mp44.gui.rotation_offset = -14
	self.mp44.gui.distance_offset = -5
	self.mp44.gui.height_offset = -16
	self.mp44.gui.display_offset = -2
	self.mp44.gui.initial_rotation = {}
	self.mp44.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.mp44.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.mp44.gui.initial_rotation.roll = 0
	self.mp44.gui.icon_large = "weapon_ass_mp44_large"
	self.mp44.hud = {}
	self.mp44.hud.icon = "weapon_panel_ass_mp44"
	self.mp44.hud.panel_class = "clip_shots"
	self.mp44.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.mp44.hud.panel_clip_icon_spent = "rifle_spent"
	self.mp44.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.mp44.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.mp44.hud.panel_clip_icon_thin_min = 20
	self.mp44.stats = {
		zoom = 4,
		total_ammo_mod = 21,
		recoil = 9,
		alert_size = 7,
		spread = 6,
		spread_moving = 9,
		value = 1,
		extra_ammo = 6,
		suppression = 10,
		concealment = 17
	}
end

function WeaponTweakData:_init_m1918_bar(weapon_data)
	self.m1918 = {}
	self.m1918.inventory_texture = "ui/temp/customization_temp_df"
	self.m1918.category = WeaponTweakData.WEAPON_CATEGORY_LMG
	self.m1918.dismember_chance = 0.2
	self.m1918.damage_melee = 108
	self.m1918.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.m1918.sounds = {}
	self.m1918.sounds.fire_single = "m1918_fire_1p_single"
	self.m1918.sounds.fire_auto = "m1918_fire_1p"
	self.m1918.sounds.stop_fire = "m1918_fire_1p_stop"
	self.m1918.sounds.dryfire = "primary_dryfire"
	self.m1918.timers = {}
	self.m1918.timers.reload_not_empty = 2
	self.m1918.timers.reload_empty = 3.125
	self.m1918.timers.unequip = 0.9
	self.m1918.timers.equip = 0.9
	self.m1918.name_id = "bm_w_m1918"
	self.m1918.desc_id = "bm_w_m1918_desc"
	self.m1918.description_id = "des_m1918"
	self.m1918.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.m1918.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.m1918.use_data = {}
	self.m1918.use_data.selection_index = 2
	self.m1918.damage_profile = {
		{
			damage = 105,
			range = 2500
		},
		{
			damage = 63,
			range = 5000
		}
	}
	self.m1918.headshot_multiplier = 3
	self.m1918.CLIP_AMMO_MAX = 20
	self.m1918.NR_CLIPS_MAX = 10
	self.m1918.AMMO_MAX = self.m1918.CLIP_AMMO_MAX * self.m1918.NR_CLIPS_MAX
	self.m1918.AMMO_PICKUP = {
		10,
		1
	}
	self.m1918.ammo_pickup_base = 20
	self.m1918.FIRE_MODE = "auto"
	self.m1918.fire_mode_data = {}
	self.m1918.fire_mode_data.fire_rate = 0.16
	self.m1918.CAN_TOGGLE_FIREMODE = true
	self.m1918.auto = {}
	self.m1918.auto.fire_rate = 0.16
	self.m1918.spread = {}
	self.m1918.spread.standing = 1.7
	self.m1918.spread.crouching = self.m1918.spread.standing * 0.8
	self.m1918.spread.steelsight = self.m1918.spread.standing * 0.5
	self.m1918.spread.moving_standing = self.m1918.spread.standing * 1.2
	self.m1918.spread.moving_crouching = self.m1918.spread.crouching * 1.2
	self.m1918.spread.moving_steelsight = self.m1918.spread.steelsight * 1.1
	self.m1918.spread.per_shot = 0.25
	self.m1918.spread.per_shot_steelsight = 0.15
	self.m1918.spread.recovery = 4.5
	self.m1918.spread.recovery_wait_multiplier = 1.5
	self.m1918.spread.max = 3.5
	self.m1918.kick = {}
	self.m1918.kick.standing = {
		1.5,
		1.8,
		0.7,
		1.3
	}
	self.m1918.kick.crouching = {
		1.1,
		1.45,
		0.55,
		1
	}
	self.m1918.kick.steelsight = {
		0.5,
		0.75,
		0.2,
		0.45
	}
	self.m1918.kick.crouching_steelsight = {
		0.4,
		0.65,
		0.15,
		0.35
	}

	function self.m1918.kick.formula(x)
		if x < 1.45 then
			return 1.45
		else
			return math.min(math.pow(x, 1.45), 5.5)
		end
	end

	self.m1918.kick.recovery = 10
	self.m1918.kick.recovery_wait_multiplier = 1.33
	self.m1918.kick.recenter_speed = 700
	self.m1918.kick.recenter_speed_steelsight = 800
	self.m1918.gun_kick = {}
	self.m1918.gun_kick.hip_fire = {
		-42,
		42,
		-40,
		40
	}
	self.m1918.gun_kick.steelsight = {
		2,
		12,
		2,
		10
	}
	self.m1918.gun_kick.position_ratio = -0.025
	self.m1918.crosshair = {}
	self.m1918.crosshair.standing = {}
	self.m1918.crosshair.crouching = {}
	self.m1918.crosshair.steelsight = {}
	self.m1918.crosshair.standing.offset = 0.16
	self.m1918.crosshair.standing.moving_offset = 1
	self.m1918.crosshair.standing.kick_offset = 0.8
	self.m1918.crosshair.crouching.offset = 0.1
	self.m1918.crosshair.crouching.moving_offset = 0.6
	self.m1918.crosshair.crouching.kick_offset = 0.4
	self.m1918.crosshair.steelsight.hidden = true
	self.m1918.crosshair.steelsight.offset = 0
	self.m1918.crosshair.steelsight.moving_offset = 0
	self.m1918.crosshair.steelsight.kick_offset = 0.14
	self.m1918.shake = {}
	self.m1918.shake.fire_multiplier = 1
	self.m1918.shake.fire_steelsight_multiplier = -1
	self.m1918.autohit = weapon_data.autohit_lmg_default
	self.m1918.aim_assist = weapon_data.aim_assist_lmg_default
	self.m1918.weapon_hold = "m1918"
	self.m1918.animations = {}
	self.m1918.animations.equip_id = "equip_m1918"
	self.m1918.animations.recoil_steelsight = true
	self.m1918.panic_suppression_chance = 0.25
	self.m1918.gui = {}
	self.m1918.gui.rotation_offset = -32
	self.m1918.gui.distance_offset = 35
	self.m1918.gui.height_offset = -13
	self.m1918.gui.display_offset = -5
	self.m1918.gui.initial_rotation = {}
	self.m1918.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.m1918.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.m1918.gui.initial_rotation.roll = 0
	self.m1918.gui.icon_large = "weapon_lmg_m1918_large"
	self.m1918.hud = {}
	self.m1918.hud.icon = "weapon_panel_lmg_m1918"
	self.m1918.hud.panel_class = "clip_shots"
	self.m1918.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.m1918.hud.panel_clip_icon_spent = "rifle_spent"
	self.m1918.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.m1918.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.m1918.hud.panel_clip_icon_thin_min = 20
	self.m1918.stats = {
		zoom = 2,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 8,
		spread = 7,
		recoil = 4,
		value = 9,
		extra_ammo = 6,
		suppression = 6,
		concealment = 2
	}
end

function WeaponTweakData:_init_dp28(weapon_data)
	self.dp28 = {}
	self.dp28.inventory_texture = "ui/temp/customization_temp_df"
	self.dp28.category = WeaponTweakData.WEAPON_CATEGORY_LMG
	self.dp28.dismember_chance = 0.45
	self.dp28.damage_melee = 108
	self.dp28.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.dp28.sounds = {}
	self.dp28.sounds.fire_single = "dp28_fire_1p_single"
	self.dp28.sounds.fire_auto = "dp28_fire_1p"
	self.dp28.sounds.stop_fire = "dp28_fire_1p_stop"
	self.dp28.sounds.dryfire = "primary_dryfire"
	self.dp28.timers = {}
	self.dp28.timers.reload_not_empty = 3.85
	self.dp28.timers.reload_empty = 3.85
	self.dp28.timers.unequip = 0.9
	self.dp28.timers.equip = 0.9
	self.dp28.name_id = "bm_w_dp28"
	self.dp28.desc_id = "bm_w_dp28_desc"
	self.dp28.description_id = "des_dp28"
	self.dp28.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.dp28.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.dp28.use_data = {}
	self.dp28.use_data.selection_index = 2
	self.dp28.damage_profile = {
		{
			damage = 120,
			range = 2500
		},
		{
			damage = 85,
			range = 5000
		}
	}
	self.dp28.headshot_multiplier = 2
	self.dp28.CLIP_AMMO_MAX = 47
	self.dp28.NR_CLIPS_MAX = 4
	self.dp28.AMMO_MAX = self.dp28.CLIP_AMMO_MAX * self.dp28.NR_CLIPS_MAX
	self.dp28.AMMO_PICKUP = {
		10,
		1
	}
	self.dp28.ammo_pickup_base = 20
	self.dp28.FIRE_MODE = "auto"
	self.dp28.fire_mode_data = {}
	self.dp28.fire_mode_data.fire_rate = 0.1
	self.dp28.CAN_TOGGLE_FIREMODE = true
	self.dp28.auto = {}
	self.dp28.auto.fire_rate = 0.1
	self.dp28.spread = {}
	self.dp28.spread.standing = 1.9
	self.dp28.spread.crouching = self.dp28.spread.standing * 0.8
	self.dp28.spread.steelsight = self.dp28.spread.standing * 0.7
	self.dp28.spread.moving_standing = self.dp28.spread.standing * 1.4
	self.dp28.spread.moving_crouching = self.dp28.spread.crouching * 1.3
	self.dp28.spread.moving_steelsight = self.dp28.spread.steelsight * 1.2
	self.dp28.spread.per_shot = 0.4
	self.dp28.spread.per_shot_steelsight = 0.18
	self.dp28.spread.recovery = 1.8
	self.dp28.spread.recovery_wait_multiplier = 1
	self.dp28.spread.max = 2
	self.dp28.kick = {}
	self.dp28.kick.standing = {
		1.5,
		1.8,
		-0.55,
		1.3
	}
	self.dp28.kick.crouching = {
		1.1,
		1.3,
		-0.35,
		1
	}
	self.dp28.kick.steelsight = {
		0.7,
		1.2,
		-0.15,
		0.45
	}
	self.dp28.kick.crouching_steelsight = {
		0.9,
		1.1,
		-0.25,
		0.7
	}

	function self.dp28.kick.formula(x)
		if x < 1.5 then
			return 1.5
		else
			return math.min(math.pow(x, 1.05), 5)
		end
	end

	self.dp28.kick.recovery = 10
	self.dp28.kick.recovery_wait_multiplier = 1.33
	self.dp28.kick.recenter_speed = 700
	self.dp28.kick.recenter_speed_steelsight = 800
	self.dp28.gun_kick = {}
	self.dp28.gun_kick.hip_fire = {
		-42,
		42,
		-40,
		40
	}
	self.dp28.gun_kick.steelsight = {
		2,
		12,
		2,
		10
	}
	self.dp28.gun_kick.position_ratio = -0.025
	self.dp28.crosshair = {}
	self.dp28.crosshair.standing = {}
	self.dp28.crosshair.crouching = {}
	self.dp28.crosshair.steelsight = {}
	self.dp28.crosshair.standing.offset = 0.16
	self.dp28.crosshair.standing.moving_offset = 1
	self.dp28.crosshair.standing.kick_offset = 0.8
	self.dp28.crosshair.crouching.offset = 0.1
	self.dp28.crosshair.crouching.moving_offset = 0.6
	self.dp28.crosshair.crouching.kick_offset = 0.4
	self.dp28.crosshair.steelsight.hidden = true
	self.dp28.crosshair.steelsight.offset = 0
	self.dp28.crosshair.steelsight.moving_offset = 0
	self.dp28.crosshair.steelsight.kick_offset = 0.14
	self.dp28.shake = {}
	self.dp28.shake.fire_multiplier = 1
	self.dp28.shake.fire_steelsight_multiplier = -1
	self.dp28.autohit = weapon_data.autohit_lmg_default
	self.dp28.aim_assist = weapon_data.aim_assist_lmg_default
	self.dp28.weapon_hold = "dp28"
	self.dp28.animations = {}
	self.dp28.animations.equip_id = "equip_dp28"
	self.dp28.animations.recoil_steelsight = true
	self.dp28.panic_suppression_chance = 0.3
	self.dp28.gui = {}
	self.dp28.gui.rotation_offset = -32
	self.dp28.gui.distance_offset = 55
	self.dp28.gui.height_offset = -11
	self.dp28.gui.display_offset = -6
	self.dp28.gui.initial_rotation = {}
	self.dp28.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.dp28.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.dp28.gui.initial_rotation.roll = 0
	self.dp28.gui.icon_large = "weapon_lmg_dp28_large"
	self.dp28.hud = {}
	self.dp28.hud.icon = "weapon_panel_lmg_dp28"
	self.dp28.hud.panel_class = "drum_mag"
	self.dp28.hud.feed_flip_y = true
	self.dp28.hud.feed_flip_x = false
	self.dp28.stats = {
		zoom = 2,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 8,
		spread = 7,
		recoil = 4,
		value = 9,
		extra_ammo = 6,
		suppression = 6,
		concealment = 2
	}
end

function WeaponTweakData:_init_bren(weapon_data)
	self.bren = {}
	self.bren.inventory_texture = "ui/temp/customization_temp_df"
	self.bren.category = WeaponTweakData.WEAPON_CATEGORY_LMG
	self.bren.dismember_chance = 0.45
	self.bren.damage_melee = 108
	self.bren.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.bren.sounds = {}
	self.bren.sounds.fire_single = "bren_fire_1p_single"
	self.bren.sounds.fire_auto = "bren_fire_1p"
	self.bren.sounds.stop_fire = "bren_fire_1p_stop"
	self.bren.sounds.dryfire = "primary_dryfire"
	self.bren.timers = {}
	self.bren.timers.reload_not_empty = 1.8
	self.bren.timers.reload_empty = 2.4
	self.bren.timers.unequip = 0.9
	self.bren.timers.equip = 0.9
	self.bren.name_id = "bm_w_bren"
	self.bren.desc_id = "bm_w_bren_desc"
	self.bren.description_id = "des_bren"
	self.bren.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.bren.shell_ejection = "effects/vanilla/weapons/shells/shell_556"
	self.bren.use_data = {}
	self.bren.use_data.selection_index = 2
	self.bren.damage_profile = {
		{
			damage = 160,
			range = 3500
		},
		{
			damage = 100,
			range = 5500
		}
	}
	self.bren.headshot_multiplier = 2
	self.bren.CLIP_AMMO_MAX = 20
	self.bren.NR_CLIPS_MAX = 6
	self.bren.AMMO_MAX = self.bren.CLIP_AMMO_MAX * self.bren.NR_CLIPS_MAX
	self.bren.AMMO_PICKUP = {
		10,
		1
	}
	self.bren.ammo_pickup_base = 20
	self.bren.FIRE_MODE = "auto"
	self.bren.fire_mode_data = {}
	self.bren.fire_mode_data.fire_rate = 0.12
	self.bren.CAN_TOGGLE_FIREMODE = true
	self.bren.auto = {}
	self.bren.auto.fire_rate = 0.12
	self.bren.spread = {}
	self.bren.spread.standing = 1.7
	self.bren.spread.crouching = self.bren.spread.standing * 0.8
	self.bren.spread.steelsight = self.bren.spread.standing * 0.6
	self.bren.spread.moving_standing = self.bren.spread.standing * 1.4
	self.bren.spread.moving_crouching = self.bren.spread.crouching * 1.3
	self.bren.spread.moving_steelsight = self.bren.spread.steelsight * 1.2
	self.bren.spread.per_shot = 0.4
	self.bren.spread.per_shot_steelsight = 0.25
	self.bren.spread.recovery = 2.5
	self.bren.spread.recovery_wait_multiplier = 0.75
	self.bren.spread.max = 3
	self.bren.kick = {}
	self.bren.kick.standing = {
		1.35,
		1.7,
		0.8,
		1.3
	}
	self.bren.kick.crouching = {
		1.1,
		1.3,
		0.55,
		1
	}
	self.bren.kick.steelsight = {
		0.5,
		0.6,
		0.2,
		0.45
	}
	self.bren.kick.crouching_steelsight = {
		0.9,
		1.07,
		0.45,
		0.8
	}

	function self.bren.kick.formula(x)
		if x < 1.75 then
			return 1.75
		else
			return math.min(math.pow(x, 1.3), 6)
		end
	end

	self.bren.kick.recovery = 10
	self.bren.kick.recovery_wait_multiplier = 1.45
	self.bren.kick.recenter_speed = 700
	self.bren.kick.recenter_speed_steelsight = 800
	self.bren.gun_kick = {}
	self.bren.gun_kick.hip_fire = {
		-46,
		40,
		-43,
		42
	}
	self.bren.gun_kick.steelsight = {
		4,
		11,
		3,
		11
	}
	self.bren.gun_kick.position_ratio = -0.025
	self.bren.crosshair = {}
	self.bren.crosshair.standing = {}
	self.bren.crosshair.crouching = {}
	self.bren.crosshair.steelsight = {}
	self.bren.crosshair.standing.offset = 0.16
	self.bren.crosshair.standing.moving_offset = 1
	self.bren.crosshair.standing.kick_offset = 0.8
	self.bren.crosshair.crouching.offset = 0.1
	self.bren.crosshair.crouching.moving_offset = 0.6
	self.bren.crosshair.crouching.kick_offset = 0.4
	self.bren.crosshair.steelsight.hidden = true
	self.bren.crosshair.steelsight.offset = 0
	self.bren.crosshair.steelsight.moving_offset = 0
	self.bren.crosshair.steelsight.kick_offset = 0.14
	self.bren.shake = {}
	self.bren.shake.fire_multiplier = 1
	self.bren.shake.fire_steelsight_multiplier = -1
	self.bren.autohit = weapon_data.autohit_lmg_default
	self.bren.aim_assist = weapon_data.aim_assist_lmg_default
	self.bren.weapon_hold = "bren"
	self.bren.animations = {}
	self.bren.animations.equip_id = "equip_bren"
	self.bren.animations.recoil_steelsight = true
	self.bren.panic_suppression_chance = 0.3
	self.bren.gui = {}
	self.bren.gui.rotation_offset = -27
	self.bren.gui.distance_offset = 60
	self.bren.gui.height_offset = -12
	self.bren.gui.display_offset = -10
	self.bren.gui.initial_rotation = {}
	self.bren.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.bren.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.bren.gui.initial_rotation.roll = 0
	self.bren.gui.icon_large = "weapon_bren_large"
	self.bren.hud = {}
	self.bren.hud.icon = "weapons_panel_bren"
	self.bren.hud.panel_class = "clip_shots"
	self.bren.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.bren.hud.panel_clip_icon_spent = "rifle_spent"
	self.bren.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.bren.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.bren.hud.panel_clip_icon_thin_min = 20
	self.bren.stats = {
		zoom = 2,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 8,
		spread = 7,
		recoil = 5,
		value = 9,
		extra_ammo = 6,
		suppression = 6,
		concealment = 2
	}
end

function WeaponTweakData:_init_mg42(weapon_data)
	self.mg42 = {}
	self.mg42.inventory_texture = "ui/temp/customization_temp_df"
	self.mg42.category = WeaponTweakData.WEAPON_CATEGORY_LMG
	self.mg42.damage_melee = 108
	self.mg42.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.mg42.dismember_chance = 0.4
	self.mg42.sounds = {}
	self.mg42.sounds.fire_single = "mg42_fire_1p_single"
	self.mg42.sounds.fire_auto = "mg42_fire_1p"
	self.mg42.sounds.stop_fire = "mg42_fire_1p_stop"
	self.mg42.sounds.dryfire = "primary_dryfire"
	self.mg42.timers = {}
	self.mg42.timers.reload_not_empty = 4
	self.mg42.timers.reload_empty = 4
	self.mg42.timers.unequip = 0.9
	self.mg42.timers.equip = 0.9
	self.mg42.timers.deploy_bipod = 1
	self.mg42.bipod_camera_spin_limit = 40
	self.mg42.bipod_camera_pitch_limit = 15
	self.mg42.bipod_weapon_translation = Vector3(-8.5, 20, -7.5)
	self.mg42.name_id = "bm_w_mg42"
	self.mg42.desc_id = "bm_w_mg42_desc"
	self.mg42.description_id = "des_mg42"
	self.mg42.muzzleflash = "effects/vanilla/weapons/762_auto_fps"
	self.mg42.shell_ejection = "effects/vanilla/weapons/shells/shell_556_lmg"
	self.mg42.use_data = {}
	self.mg42.use_data.selection_index = 2
	self.mg42.damage_profile = {
		{
			damage = 94,
			range = 2500
		},
		{
			damage = 60,
			range = 5200
		}
	}
	self.mg42.headshot_multiplier = 2
	self.mg42.CLIP_AMMO_MAX = 50
	self.mg42.NR_CLIPS_MAX = 4
	self.mg42.AMMO_MAX = self.mg42.CLIP_AMMO_MAX * self.mg42.NR_CLIPS_MAX
	self.mg42.AMMO_PICKUP = self:_pickup_chance(self.mg42.AMMO_MAX, 1)
	self.mg42.ammo_pickup_base = 20
	self.mg42.FIRE_MODE = "auto"
	self.mg42.fire_mode_data = {}
	self.mg42.fire_mode_data.fire_rate = self:convert_rpm(1200)
	self.mg42.CAN_TOGGLE_FIREMODE = false
	self.mg42.auto = {}
	self.mg42.auto.fire_rate = self:convert_rpm(1200)
	self.mg42.spread = {}
	self.mg42.spread.standing = 2
	self.mg42.spread.crouching = self.mg42.spread.standing * 0.75
	self.mg42.spread.steelsight = self.mg42.spread.standing * 0.5
	self.mg42.spread.moving_standing = self.mg42.spread.standing * 1.4
	self.mg42.spread.moving_crouching = self.mg42.spread.crouching * 1.4
	self.mg42.spread.moving_steelsight = self.mg42.spread.steelsight * 1.4
	self.mg42.spread.per_shot = 0.3
	self.mg42.spread.per_shot_steelsight = 0.25
	self.mg42.spread.recovery = 3
	self.mg42.spread.recovery_wait_multiplier = 0.5
	self.mg42.spread.max = 6
	self.mg42.kick = {}
	self.mg42.kick.standing = {
		1.7,
		1.8,
		0.9,
		1.4
	}
	self.mg42.kick.crouching = {
		1.1,
		1.3,
		0.55,
		1
	}
	self.mg42.kick.steelsight = {
		0.5,
		0.6,
		0.2,
		0.45
	}
	self.mg42.kick.crouching_steelsight = {
		0.9,
		1.07,
		0.45,
		0.8
	}

	function self.mg42.kick.formula(x)
		if x < 1.6 then
			return 1.6
		else
			return math.min(math.pow(x, 1.2), 6)
		end
	end

	self.mg42.kick.recovery = 9
	self.mg42.kick.recovery_wait_multiplier = 1.21
	self.mg42.kick.recenter_speed = 700
	self.mg42.kick.recenter_speed_steelsight = 800
	self.mg42.crosshair = {}
	self.mg42.crosshair.standing = {}
	self.mg42.crosshair.crouching = {}
	self.mg42.crosshair.steelsight = {}
	self.mg42.crosshair.standing.offset = 0.16
	self.mg42.crosshair.standing.moving_offset = 1
	self.mg42.crosshair.standing.kick_offset = 0.8
	self.mg42.crosshair.crouching.offset = 0.1
	self.mg42.crosshair.crouching.moving_offset = 0.6
	self.mg42.crosshair.crouching.kick_offset = 0.4
	self.mg42.crosshair.steelsight.hidden = true
	self.mg42.crosshair.steelsight.offset = 0
	self.mg42.crosshair.steelsight.moving_offset = 0
	self.mg42.crosshair.steelsight.kick_offset = 0.14
	self.mg42.shake = {}
	self.mg42.shake.fire_multiplier = 0.5
	self.mg42.shake.fire_steelsight_multiplier = -0.5
	self.mg42.autohit = weapon_data.autohit_lmg_default
	self.mg42.aim_assist = weapon_data.aim_assist_lmg_default
	self.mg42.weapon_hold = "mg42"
	self.mg42.animations = {}
	self.mg42.animations.equip_id = "equip_mg42"
	self.mg42.animations.recoil_steelsight = true
	self.mg42.animations.bipod_enter = "bipod_enter"
	self.mg42.animations.bipod_exit = "bipod_exit"
	self.mg42.animations.bipod_recoil = "bipod_recoil"
	self.mg42.animations.bipod_recoil_enter = "bipod_recoil"
	self.mg42.animations.bipod_recoil_loop = "bipod_recoil_loop"
	self.mg42.animations.bipod_recoil_exit = "bipod_recoil_exit"
	self.mg42.panic_suppression_chance = 0.2
	self.mg42.gui = {}
	self.mg42.gui.rotation_offset = -25
	self.mg42.gui.distance_offset = 40
	self.mg42.gui.height_offset = -18
	self.mg42.gui.display_offset = -2
	self.mg42.gui.initial_rotation = {}
	self.mg42.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.mg42.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.mg42.gui.initial_rotation.roll = 0
	self.mg42.gui.icon_large = "weapon_lmg_mg42_large"
	self.mg42.hud = {}
	self.mg42.hud.icon = "weapon_panel_lmg_mg42"
	self.mg42.hud.panel_class = "drum_mag"
	self.mg42.hud.feed_flip_x = true
	self.mg42.hud.drums = 1
	self.mg42.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		spread_moving = 8,
		alert_size = 8,
		spread = 5,
		recoil = 5,
		value = 9,
		extra_ammo = 6,
		suppression = 4,
		concealment = 2
	}
end

function WeaponTweakData:_init_m1903_springfield(weapon_data)
	self.m1903 = {}
	self.m1903.inventory_texture = "ui/temp/customization_temp_df"
	self.m1903.category = WeaponTweakData.WEAPON_CATEGORY_SNP
	self.m1903.use_shotgun_reload = true
	self.m1903.dismember_chance = 0.25
	self.m1903.damage_melee = 108
	self.m1903.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.m1903.sounds = {}
	self.m1903.sounds.fire_single = "springfield_fire_1p_single"
	self.m1903.sounds.dryfire = "primary_dryfire"
	self.m1903.timers = {}
	self.m1903.timers.shotgun_reload_enter = 0.5333333333333333
	self.m1903.timers.shotgun_reload_exit_empty = 0.4
	self.m1903.timers.shotgun_reload_exit_not_empty = 0.4
	self.m1903.timers.shotgun_reload_shell = 0.5666666666666667
	self.m1903.timers.shotgun_reload_first_shell_offset = 0.016666666666666666
	self.m1903.timers.unequip = 0.85
	self.m1903.timers.equip = 0.85
	self.m1903.name_id = "bm_w_m1903"
	self.m1903.desc_id = "bm_w_m1903_desc"
	self.m1903.description_id = "des_m1903"
	self.m1903.muzzleflash = "effects/vanilla/weapons/762_sniper_fps"
	self.m1903.muzzletrail = "effects/vanilla/weapons/762_sniper_trail_fps"
	self.m1903.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.m1903.use_data = {}
	self.m1903.use_data.selection_index = 2
	self.m1903.damage_profile = {
		{
			damage = 275,
			range = 1000
		}
	}
	self.m1903.headshot_multiplier = 3.5
	self.m1903.CLIP_AMMO_MAX = 5
	self.m1903.NR_CLIPS_MAX = 10
	self.m1903.AMMO_MAX = self.m1903.CLIP_AMMO_MAX * self.m1903.NR_CLIPS_MAX
	self.m1903.AMMO_PICKUP = {
		0.7,
		1
	}
	self.m1903.ammo_pickup_base = 5
	self.m1903.FIRE_MODE = "single"
	self.m1903.fire_mode_data = {}
	self.m1903.fire_mode_data.fire_rate = 1.15
	self.m1903.CAN_TOGGLE_FIREMODE = false
	self.m1903.auto = {}
	self.m1903.auto.fire_rate = 1.15
	self.m1903.spread = {}
	self.m1903.spread.standing = 4.29
	self.m1903.spread.crouching = 3
	self.m1903.spread.steelsight = 0.07
	self.m1903.spread.moving_standing = 8.57
	self.m1903.spread.moving_crouching = 6
	self.m1903.spread.moving_steelsight = 0.11
	self.m1903.spread.per_shot = 0.8
	self.m1903.spread.per_shot_steelsight = 0.1
	self.m1903.spread.recovery = 16
	self.m1903.spread.recovery_wait_multiplier = 0.9
	self.m1903.kick = {}
	self.m1903.kick.standing = {
		2.2,
		2.5,
		-2.4,
		2.4
	}
	self.m1903.kick.crouching = {
		2.1,
		2.4,
		-2,
		2
	}
	self.m1903.kick.steelsight = {
		2,
		2.3,
		-2,
		2
	}
	self.m1903.kick.crouching_steelsight = {
		1.9,
		2.2,
		-1.9,
		1.9
	}
	self.m1903.kick.recenter_speed = 500
	self.m1903.kick.recenter_speed_steelsight = 400
	self.m1903.minimum_view_kick = {}
	self.m1903.minimum_view_kick.standing = {
		0,
		1.8
	}
	self.m1903.minimum_view_kick.crouching = {
		0,
		1.6
	}
	self.m1903.minimum_view_kick.steelsight = {
		0,
		1.5
	}
	self.m1903.minimum_view_kick.crouching_steelsight = {
		0,
		1.4
	}
	self.m1903.gun_kick = {}
	self.m1903.gun_kick.hip_fire = {
		40,
		40,
		-40,
		40
	}
	self.m1903.gun_kick.steelsight = {
		0,
		0,
		0,
		0
	}
	self.m1903.crosshair = {}
	self.m1903.crosshair.standing = {}
	self.m1903.crosshair.crouching = {}
	self.m1903.crosshair.steelsight = {}
	self.m1903.crosshair.standing.offset = 0.16
	self.m1903.crosshair.standing.moving_offset = 0.8
	self.m1903.crosshair.standing.kick_offset = 0.6
	self.m1903.crosshair.crouching.offset = 0.08
	self.m1903.crosshair.crouching.moving_offset = 0.7
	self.m1903.crosshair.crouching.kick_offset = 0
	self.m1903.crosshair.steelsight.hidden = true
	self.m1903.crosshair.steelsight.offset = 0
	self.m1903.crosshair.steelsight.moving_offset = 0
	self.m1903.crosshair.steelsight.kick_offset = 0.1
	self.m1903.shake = {}
	self.m1903.shake.fire_multiplier = 2
	self.m1903.shake.fire_steelsight_multiplier = -1
	self.m1903.autohit = weapon_data.autohit_snp_default
	self.m1903.aim_assist = weapon_data.aim_assist_snp_default
	self.m1903.weapon_hold = "m1903"
	self.m1903.animations = {}
	self.m1903.animations.equip_id = "equip_m4"
	self.m1903.animations.recoil_steelsight = true
	self.m1903.can_shoot_through_enemy = true
	self.m1903.can_shoot_through_shield = false
	self.m1903.can_shoot_through_wall = false
	self.m1903.armor_piercing_chance = 1
	self.m1903.panic_suppression_chance = 0.25
	self.m1903.gui = {}
	self.m1903.gui.rotation_offset = -33
	self.m1903.gui.distance_offset = 40
	self.m1903.gui.height_offset = -13
	self.m1903.gui.display_offset = -4
	self.m1903.gui.initial_rotation = {}
	self.m1903.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.m1903.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.m1903.gui.initial_rotation.roll = 0
	self.m1903.gui.icon_large = "weapon_snp_m1903_large"
	self.m1903.hud = {}
	self.m1903.hud.icon = "weapon_panel_snp_m1903"
	self.m1903.hud.panel_class = "clip_shots"
	self.m1903.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.m1903.hud.panel_clip_icon_spent = "rifle_spent"
	self.m1903.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.m1903.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.m1903.stats = {
		zoom = 6,
		total_ammo_mod = 21,
		spread_moving = 9,
		alert_size = 7,
		spread = 6,
		recoil = 2,
		value = 1,
		extra_ammo = 6,
		suppression = 8,
		concealment = 10
	}
end

function WeaponTweakData:_init_kar_98k(weapon_data)
	self.kar_98k = {}
	self.kar_98k.inventory_texture = "ui/temp/customization_temp_df"
	self.kar_98k.category = WeaponTweakData.WEAPON_CATEGORY_SNP
	self.kar_98k.use_shotgun_reload = true
	self.kar_98k.dismember_chance = 0.25
	self.kar_98k.damage_melee = 108
	self.kar_98k.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.kar_98k.sounds = {}
	self.kar_98k.sounds.fire_single = "kar98_fire_1p_single"
	self.kar_98k.sounds.dryfire = "primary_dryfire"
	self.kar_98k.timers = {}
	self.kar_98k.timers.reload_empty = 2.07
	self.kar_98k.timers.shotgun_reload_enter = 0.6333333333333333
	self.kar_98k.timers.shotgun_reload_exit_empty = 0.8333333333333334
	self.kar_98k.timers.shotgun_reload_exit_not_empty = 0.8333333333333334
	self.kar_98k.timers.shotgun_reload_shell = 0.8666666666666667
	self.kar_98k.timers.shotgun_reload_first_shell_offset = 0.16666666666666666
	self.kar_98k.timers.unequip = 0.6
	self.kar_98k.timers.equip = 0.5
	self.kar_98k.name_id = "bm_w_kar_98k"
	self.kar_98k.desc_id = "bm_w_kar_98k_desc"
	self.kar_98k.description_id = "des_kar_98k"
	self.kar_98k.muzzleflash = "effects/vanilla/weapons/762_sniper_fps"
	self.kar_98k.muzzletrail = "effects/vanilla/weapons/762_sniper_trail_fps"
	self.kar_98k.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.kar_98k.use_data = {}
	self.kar_98k.use_data.selection_index = 2
	self.kar_98k.damage_profile = {
		{
			damage = 275,
			range = 1000
		}
	}
	self.kar_98k.headshot_multiplier = 3.5
	self.kar_98k.CLIP_AMMO_MAX = 5
	self.kar_98k.NR_CLIPS_MAX = 9
	self.kar_98k.AMMO_MAX = self.kar_98k.CLIP_AMMO_MAX * self.kar_98k.NR_CLIPS_MAX
	self.kar_98k.AMMO_PICKUP = {
		0.7,
		1
	}
	self.kar_98k.ammo_pickup_base = 5
	self.kar_98k.FIRE_MODE = "single"
	self.kar_98k.fire_mode_data = {}
	self.kar_98k.fire_mode_data.fire_rate = 1.2
	self.kar_98k.CAN_TOGGLE_FIREMODE = false
	self.kar_98k.auto = {}
	self.kar_98k.auto.fire_rate = 1.2
	self.kar_98k.spread = {}
	self.kar_98k.spread.standing = 4.4
	self.kar_98k.spread.crouching = 3.1
	self.kar_98k.spread.steelsight = 0.1
	self.kar_98k.spread.moving_standing = 8.9
	self.kar_98k.spread.moving_crouching = 6
	self.kar_98k.spread.moving_steelsight = 0.16
	self.kar_98k.spread.per_shot = 0.8
	self.kar_98k.spread.per_shot_steelsight = 0.1
	self.kar_98k.spread.recovery = 16
	self.kar_98k.spread.recovery_wait_multiplier = 0.9
	self.kar_98k.kick = {}
	self.kar_98k.kick.standing = {
		1.3,
		1.6,
		-1.4,
		1.4
	}
	self.kar_98k.kick.crouching = {
		1.1,
		1.4,
		-1.1,
		1.1
	}
	self.kar_98k.kick.steelsight = {
		1.05,
		1.3,
		-1,
		1.05
	}
	self.kar_98k.kick.crouching_steelsight = {
		0.95,
		0.2,
		-0.95,
		0.95
	}
	self.kar_98k.kick.recenter_speed = 490
	self.kar_98k.kick.recenter_speed_steelsight = 400
	self.kar_98k.minimum_view_kick = {}
	self.kar_98k.minimum_view_kick.standing = {
		0,
		1.9
	}
	self.kar_98k.minimum_view_kick.crouching = {
		0,
		1.75
	}
	self.kar_98k.minimum_view_kick.steelsight = {
		0,
		1.65
	}
	self.kar_98k.minimum_view_kick.crouching_steelsight = {
		0,
		1.4
	}
	self.kar_98k.gun_kick = {}
	self.kar_98k.gun_kick.hip_fire = {
		40,
		40,
		-40,
		40
	}
	self.kar_98k.gun_kick.steelsight = {
		0,
		0,
		0,
		0
	}
	self.kar_98k.crosshair = {}
	self.kar_98k.crosshair.standing = {}
	self.kar_98k.crosshair.crouching = {}
	self.kar_98k.crosshair.steelsight = {}
	self.kar_98k.crosshair.standing.offset = 0.16
	self.kar_98k.crosshair.standing.moving_offset = 0.8
	self.kar_98k.crosshair.standing.kick_offset = 0.6
	self.kar_98k.crosshair.crouching.offset = 0.08
	self.kar_98k.crosshair.crouching.moving_offset = 0.7
	self.kar_98k.crosshair.crouching.kick_offset = 0
	self.kar_98k.crosshair.steelsight.hidden = true
	self.kar_98k.crosshair.steelsight.offset = 0
	self.kar_98k.crosshair.steelsight.moving_offset = 0
	self.kar_98k.crosshair.steelsight.kick_offset = 0.1
	self.kar_98k.shake = {}
	self.kar_98k.shake.fire_multiplier = 2
	self.kar_98k.shake.fire_steelsight_multiplier = -1
	self.kar_98k.autohit = weapon_data.autohit_snp_default
	self.kar_98k.aim_assist = weapon_data.aim_assist_snp_default
	self.kar_98k.weapon_hold = "kar_98k"
	self.kar_98k.animations = {}
	self.kar_98k.animations.equip_id = "kar_98k"
	self.kar_98k.animations.recoil_steelsight = true
	self.kar_98k.can_shoot_through_enemy = true
	self.kar_98k.can_shoot_through_shield = false
	self.kar_98k.can_shoot_through_wall = false
	self.kar_98k.armor_piercing_chance = 1
	self.kar_98k.panic_suppression_chance = 0.25
	self.kar_98k.gui = {}
	self.kar_98k.gui.rotation_offset = -33
	self.kar_98k.gui.distance_offset = 40
	self.kar_98k.gui.height_offset = -13
	self.kar_98k.gui.display_offset = -4
	self.kar_98k.gui.initial_rotation = {}
	self.kar_98k.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.kar_98k.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.kar_98k.gui.initial_rotation.roll = 0
	self.kar_98k.gui.icon_large = "weapon_kar_98k_large"
	self.kar_98k.hud = {}
	self.kar_98k.hud.icon = "weapons_panel_kar_98k"
	self.kar_98k.hud.panel_class = "clip_shots"
	self.kar_98k.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.kar_98k.hud.panel_clip_icon_spent = "rifle_spent"
	self.kar_98k.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.kar_98k.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.kar_98k.stats = {
		zoom = 6,
		total_ammo_mod = 21,
		spread_moving = 8,
		alert_size = 7,
		spread = 5,
		recoil = 3,
		value = 1,
		extra_ammo = 6,
		suppression = 8,
		concealment = 10
	}
end

function WeaponTweakData:_init_lee_enfield(weapon_data)
	self.lee_enfield = {}
	self.lee_enfield.inventory_texture = "ui/temp/customization_temp_df"
	self.lee_enfield.category = WeaponTweakData.WEAPON_CATEGORY_SNP
	self.lee_enfield.use_shotgun_reload = true
	self.lee_enfield.dismember_chance = 0.25
	self.lee_enfield.damage_melee = 108
	self.lee_enfield.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.lee_enfield.sounds = {}
	self.lee_enfield.sounds.fire_single = "lee_fire_1p_single"
	self.lee_enfield.sounds.dryfire = "primary_dryfire"
	self.lee_enfield.timers = {}
	self.lee_enfield.timers.reload_empty = 3.7
	self.lee_enfield.timers.reload_not_empty = 2.07
	self.lee_enfield.timers.shotgun_reload_enter = 0.6333333333333333
	self.lee_enfield.timers.shotgun_reload_exit_empty = 0.8333333333333334
	self.lee_enfield.timers.shotgun_reload_exit_not_empty = 0.8333333333333334
	self.lee_enfield.timers.shotgun_reload_shell = 0.8666666666666667
	self.lee_enfield.timers.shotgun_reload_first_shell_offset = 0.16666666666666666
	self.lee_enfield.timers.unequip = 0.6
	self.lee_enfield.timers.equip = 0.5
	self.lee_enfield.name_id = "bm_w_lee_enfield"
	self.lee_enfield.desc_id = "bm_w_lee_enfield_desc"
	self.lee_enfield.description_id = "des_lee_enfield"
	self.lee_enfield.muzzleflash = "effects/vanilla/weapons/762_sniper_fps"
	self.lee_enfield.muzzletrail = "effects/vanilla/weapons/762_sniper_trail_fps"
	self.lee_enfield.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.lee_enfield.use_data = {}
	self.lee_enfield.use_data.selection_index = 2
	self.lee_enfield.damage_profile = {
		{
			damage = 280,
			range = 1000
		}
	}
	self.lee_enfield.headshot_multiplier = 3.5
	self.lee_enfield.CLIP_AMMO_MAX = 5
	self.lee_enfield.NR_CLIPS_MAX = 9
	self.lee_enfield.AMMO_MAX = self.lee_enfield.CLIP_AMMO_MAX * self.lee_enfield.NR_CLIPS_MAX
	self.lee_enfield.AMMO_PICKUP = {
		0.7,
		1
	}
	self.lee_enfield.ammo_pickup_base = 5
	self.lee_enfield.FIRE_MODE = "single"
	self.lee_enfield.fire_mode_data = {}
	self.lee_enfield.fire_mode_data.fire_rate = 1.2
	self.lee_enfield.CAN_TOGGLE_FIREMODE = false
	self.lee_enfield.auto = {}
	self.lee_enfield.auto.fire_rate = 1.2
	self.lee_enfield.spread = {}
	self.lee_enfield.spread.standing = 4.1
	self.lee_enfield.spread.crouching = 2.8
	self.lee_enfield.spread.steelsight = 0.05
	self.lee_enfield.spread.moving_standing = 8.4
	self.lee_enfield.spread.moving_crouching = 6
	self.lee_enfield.spread.moving_steelsight = 0.11
	self.lee_enfield.spread.per_shot = 0.8
	self.lee_enfield.spread.per_shot_steelsight = 0.1
	self.lee_enfield.spread.recovery = 16
	self.lee_enfield.spread.recovery_wait_multiplier = 0.9
	self.lee_enfield.kick = {}
	self.lee_enfield.kick.standing = {
		1.3,
		1.6,
		-1.4,
		1.4
	}
	self.lee_enfield.kick.crouching = {
		1.1,
		1.4,
		-1.1,
		1.1
	}
	self.lee_enfield.kick.steelsight = {
		1.05,
		1.3,
		-1,
		1.05
	}
	self.lee_enfield.kick.crouching_steelsight = {
		0.95,
		0.2,
		-0.95,
		0.95
	}
	self.lee_enfield.kick.recenter_speed = 490
	self.lee_enfield.kick.recenter_speed_steelsight = 400
	self.lee_enfield.minimum_view_kick = {}
	self.lee_enfield.minimum_view_kick.standing = {
		0,
		1.9
	}
	self.lee_enfield.minimum_view_kick.crouching = {
		0,
		1.75
	}
	self.lee_enfield.minimum_view_kick.steelsight = {
		0,
		1.65
	}
	self.lee_enfield.minimum_view_kick.crouching_steelsight = {
		0,
		1.4
	}
	self.lee_enfield.gun_kick = {}
	self.lee_enfield.gun_kick.hip_fire = {
		40,
		40,
		-40,
		40
	}
	self.lee_enfield.gun_kick.steelsight = {
		0,
		0,
		0,
		0
	}
	self.lee_enfield.crosshair = {}
	self.lee_enfield.crosshair.standing = {}
	self.lee_enfield.crosshair.crouching = {}
	self.lee_enfield.crosshair.steelsight = {}
	self.lee_enfield.crosshair.standing.offset = 0.16
	self.lee_enfield.crosshair.standing.moving_offset = 0.8
	self.lee_enfield.crosshair.standing.kick_offset = 0.6
	self.lee_enfield.crosshair.crouching.offset = 0.08
	self.lee_enfield.crosshair.crouching.moving_offset = 0.7
	self.lee_enfield.crosshair.crouching.kick_offset = 0
	self.lee_enfield.crosshair.steelsight.hidden = true
	self.lee_enfield.crosshair.steelsight.offset = 0
	self.lee_enfield.crosshair.steelsight.moving_offset = 0
	self.lee_enfield.crosshair.steelsight.kick_offset = 0.1
	self.lee_enfield.shake = {}
	self.lee_enfield.shake.fire_multiplier = 2
	self.lee_enfield.shake.fire_steelsight_multiplier = -1
	self.lee_enfield.autohit = weapon_data.autohit_snp_default
	self.lee_enfield.aim_assist = weapon_data.aim_assist_snp_default
	self.lee_enfield.weapon_hold = "lee_enfield"
	self.lee_enfield.animations = {}
	self.lee_enfield.animations.equip_id = "lee_enfield"
	self.lee_enfield.animations.recoil_steelsight = true
	self.lee_enfield.can_shoot_through_enemy = true
	self.lee_enfield.can_shoot_through_shield = false
	self.lee_enfield.can_shoot_through_wall = false
	self.lee_enfield.armor_piercing_chance = 1
	self.lee_enfield.panic_suppression_chance = 0.25
	self.lee_enfield.gui = {}
	self.lee_enfield.gui.rotation_offset = -30
	self.lee_enfield.gui.distance_offset = 40
	self.lee_enfield.gui.height_offset = -11
	self.lee_enfield.gui.display_offset = -4
	self.lee_enfield.gui.initial_rotation = {}
	self.lee_enfield.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.lee_enfield.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.lee_enfield.gui.initial_rotation.roll = 0
	self.lee_enfield.gui.icon_large = "weapon_enfield_large"
	self.lee_enfield.hud = {}
	self.lee_enfield.hud.icon = "weapons_panel_enfield"
	self.lee_enfield.hud.panel_class = "clip_shots"
	self.lee_enfield.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.lee_enfield.hud.panel_clip_icon_spent = "rifle_spent"
	self.lee_enfield.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.lee_enfield.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.lee_enfield.stats = {
		zoom = 6,
		total_ammo_mod = 21,
		spread_moving = 8,
		alert_size = 7,
		spread = 10,
		recoil = 6,
		value = 1,
		extra_ammo = 6,
		suppression = 8,
		concealment = 10
	}
end

function WeaponTweakData:_init_mosin(weapon_data)
	self.mosin = {}
	self.mosin.inventory_texture = "ui/temp/customization_temp_df"
	self.mosin.category = WeaponTweakData.WEAPON_CATEGORY_SNP
	self.mosin.upgrade_blocks = {
		weapon = {
			"clip_ammo_increase"
		}
	}
	self.mosin.dismember_chance = 0.25
	self.mosin.damage_melee = 108
	self.mosin.damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default
	self.mosin.sounds = {}
	self.mosin.sounds.fire = ""
	self.mosin.sounds.fire_single = "mosin_fire_1p_single"
	self.mosin.sounds.dryfire = "primary_dryfire"
	self.mosin.timers = {}
	self.mosin.timers.reload_not_empty = 2.07
	self.mosin.timers.reload_empty = 2.07
	self.mosin.timers.unequip = 0.6
	self.mosin.timers.equip = 0.5
	self.mosin.name_id = "bm_w_mosin"
	self.mosin.desc_id = "bm_w_mosin_desc"
	self.mosin.description_id = "des_mosin"
	self.mosin.muzzleflash = "effects/vanilla/weapons/762_sniper_fps"
	self.mosin.muzzletrail = "effects/vanilla/weapons/762_sniper_trail_fps"
	self.mosin.shell_ejection = "effects/vanilla/weapons/shells/shell_sniper"
	self.mosin.use_data = {}
	self.mosin.use_data.selection_index = 2
	self.mosin.use_data.align_place = "right_hand"
	self.mosin.damage_profile = {
		{
			damage = 250,
			range = 1000
		}
	}
	self.mosin.headshot_multiplier = 3.5
	self.mosin.CLIP_AMMO_MAX = 5
	self.mosin.NR_CLIPS_MAX = 10
	self.mosin.AMMO_MAX = self.mosin.CLIP_AMMO_MAX * self.mosin.NR_CLIPS_MAX
	self.mosin.AMMO_PICKUP = {
		0.7,
		1
	}
	self.mosin.ammo_pickup_base = 5
	self.mosin.FIRE_MODE = "single"
	self.mosin.fire_mode_data = {}
	self.mosin.fire_mode_data.fire_rate = 1
	self.mosin.CAN_TOGGLE_FIREMODE = false
	self.mosin.single = {}
	self.mosin.single.fire_rate = 1
	self.mosin.spread = {}
	self.mosin.spread.standing = 4.29
	self.mosin.spread.crouching = 3
	self.mosin.spread.steelsight = 0.07
	self.mosin.spread.moving_standing = 8.57
	self.mosin.spread.moving_crouching = 6
	self.mosin.spread.moving_steelsight = 0.11
	self.mosin.spread.per_shot = 0.8
	self.mosin.spread.per_shot_steelsight = 0.5
	self.mosin.kick = {}
	self.mosin.kick.standing = {
		1.3,
		1.6,
		-1.4,
		1.4
	}
	self.mosin.kick.crouching = {
		1.1,
		1.4,
		-1.1,
		1.1
	}
	self.mosin.kick.steelsight = {
		1.05,
		1.3,
		-1,
		1.05
	}
	self.mosin.kick.crouching_steelsight = {
		0.95,
		0.2,
		-0.95,
		0.95
	}
	self.mosin.kick.recenter_speed = 400
	self.mosin.kick.recenter_speed_steelsight = 400
	self.mosin.minimum_view_kick = {}
	self.mosin.minimum_view_kick.standing = {
		0,
		2
	}
	self.mosin.minimum_view_kick.crouching = {
		0,
		1.9
	}
	self.mosin.minimum_view_kick.steelsight = {
		0,
		1.6
	}
	self.mosin.minimum_view_kick.crouching_steelsight = {
		0,
		1.5
	}
	self.mosin.gun_kick = {}
	self.mosin.gun_kick.hip_fire = {
		30,
		45,
		-40,
		40
	}
	self.mosin.gun_kick.steelsight = {
		0,
		0,
		0,
		0
	}
	self.mosin.crosshair = {}
	self.mosin.crosshair.standing = {}
	self.mosin.crosshair.crouching = {}
	self.mosin.crosshair.steelsight = {}
	self.mosin.crosshair.standing.offset = 1.14
	self.mosin.crosshair.standing.moving_offset = 1.8
	self.mosin.crosshair.standing.kick_offset = 1.6
	self.mosin.crosshair.crouching.offset = 1.1
	self.mosin.crosshair.crouching.moving_offset = 1.6
	self.mosin.crosshair.crouching.kick_offset = 1.4
	self.mosin.crosshair.steelsight.hidden = true
	self.mosin.crosshair.steelsight.offset = 1
	self.mosin.crosshair.steelsight.moving_offset = 1
	self.mosin.crosshair.steelsight.kick_offset = 1.14
	self.mosin.shake = {}
	self.mosin.shake.fire_multiplier = 2
	self.mosin.shake.fire_steelsight_multiplier = -1
	self.mosin.autohit = weapon_data.autohit_snp_default
	self.mosin.aim_assist = weapon_data.aim_assist_snp_default
	self.mosin.weapon_hold = "mosin"
	self.mosin.animations = {}
	self.mosin.animations.equip_id = "equip_mosin"
	self.mosin.animations.recoil_steelsight = true
	self.mosin.can_shoot_through_enemy = true
	self.mosin.can_shoot_through_shield = false
	self.mosin.can_shoot_through_wall = false
	self.mosin.armor_piercing_chance = 1
	self.mosin.panic_suppression_chance = 0.25
	self.mosin.gui = {}
	self.mosin.gui.rotation_offset = -32
	self.mosin.gui.distance_offset = 55
	self.mosin.gui.height_offset = -11
	self.mosin.gui.display_offset = 0
	self.mosin.gui.initial_rotation = {}
	self.mosin.gui.initial_rotation.yaw = WeaponTweakData.INIT_ROTATION_YAW
	self.mosin.gui.initial_rotation.pitch = WeaponTweakData.INIT_ROTATION_PITCH
	self.mosin.gui.initial_rotation.roll = 0
	self.mosin.gui.icon_large = "weapon_snp_mosin_large"
	self.mosin.hud = {}
	self.mosin.hud.icon = "weapon_panel_snp_mosin"
	self.mosin.hud.panel_class = "clip_shots"
	self.mosin.hud.panel_clip_icon_loaded = "rifle_loaded"
	self.mosin.hud.panel_clip_icon_spent = "rifle_spent"
	self.mosin.hud.panel_clip_icon_loaded_thin = "9mm_loaded_thin"
	self.mosin.hud.panel_clip_icon_spent_thin = "9mm_spent_thin"
	self.mosin.stats = {
		zoom = 6,
		total_ammo_mod = 21,
		recoil = 4,
		alert_size = 7,
		spread = 6,
		spread_moving = 9,
		value = 9,
		extra_ammo = 6,
		suppression = 5,
		concealment = 6
	}
end

function WeaponTweakData:_init_data_offhand_weapons()
	return
end
