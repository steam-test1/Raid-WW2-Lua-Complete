IntelTweakData = IntelTweakData or class()

function IntelTweakData:init(tweak_data)
	self.categories = {}
	self.categories.bulletins = {}
	self.categories.bulletins.name_id = "category_bulletins_name_id"
	self.categories.operational_status = {}
	self.categories.operational_status.name_id = "category_operational_status_name_id"
	self.categories.raid_personnel = {}
	self.categories.raid_personnel.name_id = "category_raid_personnel_name_id"
	self.categories.opposition_forces = {}
	self.categories.opposition_forces.name_id = "category_opposition_forces_name_id"
	self.category_index = {
		"raid_personnel",
		"opposition_forces"
	}
	self.categories.bulletins.items = {}
	self.categories.bulletins.items[1] = {}
	self.categories.bulletins.items[1].id = "bulletin_1"
	self.categories.bulletins.items[1].list_item_name_id = "bulletin_1_list_item_name_id"
	self.categories.bulletins.items[1].update_date = "SEP 26 2017"
	self.categories.bulletins.items[1].update_person = "CONTROL"
	self.categories.bulletins.items[1].title = "bulletin_1_title_id"
	self.categories.bulletins.items[1].texture = "ui/control_table/bulletins_img_002_hud"
	self.categories.bulletins.items[1].texture_rect = {
		0,
		0,
		512,
		288
	}
	self.categories.bulletins.items[1].text = "bulletin_1_text_id"
	self.categories.bulletins.items[2] = {}
	self.categories.bulletins.items[2].id = "bulletin_2"
	self.categories.bulletins.items[2].list_item_name_id = "bulletin_2_list_item_name_id"
	self.categories.bulletins.items[2].update_date = "OCT 26 2017"
	self.categories.bulletins.items[2].update_person = "CONTROL"
	self.categories.bulletins.items[2].title = "bulletin_2_title_id"
	self.categories.bulletins.items[2].text = "bulletin_2_text_id"
	self.categories.operational_status.items = {}
	self.categories.operational_status.items[1] = {}
	self.categories.operational_status.items[1].id = "operational_status_1"
	self.categories.operational_status.items[1].list_item_name_id = "operational_status_1_list_item_name_id"
	self.categories.operational_status.items[1].update_date = "SEP 26 2017"
	self.categories.operational_status.items[1].update_person = "CONTROL"
	self.categories.operational_status.items[1].title = "operational_status_1_title_id"
	self.categories.operational_status.items[1].texture = "ui/control_table/op_status_img_001_hud"
	self.categories.operational_status.items[1].texture_rect = {
		0,
		0,
		512,
		288
	}
	self.categories.operational_status.items[1].text = "operational_status_1_text_id"
	self.categories.operational_status.items[2] = {}
	self.categories.operational_status.items[2].id = "operational_status_2"
	self.categories.operational_status.items[2].list_item_name_id = "operational_status_2_list_item_name_id"
	self.categories.operational_status.items[2].update_date = "SEP 28 2017"
	self.categories.operational_status.items[2].update_person = "CONTROL"
	self.categories.operational_status.items[2].title = "operational_status_2_title_id"
	self.categories.operational_status.items[2].text = "operational_status_2_text_id"
	self.categories.operational_status.items[3] = {}
	self.categories.operational_status.items[3].id = "operational_status_3"
	self.categories.operational_status.items[3].list_item_name_id = "operational_status_3_list_item_name_id"
	self.categories.operational_status.items[3].update_date = "OCT 4 2017"
	self.categories.operational_status.items[3].update_person = "CONTROL"
	self.categories.operational_status.items[3].title = "operational_status_3_title_id"
	self.categories.operational_status.items[3].text = "operational_status_3_text_id"
	self.categories.operational_status.items[4] = {}
	self.categories.operational_status.items[4].id = "operational_status_4"
	self.categories.operational_status.items[4].list_item_name_id = "operational_status_4_list_item_name_id"
	self.categories.operational_status.items[4].update_date = "OCT 5 2017"
	self.categories.operational_status.items[4].update_person = "CONTROL"
	self.categories.operational_status.items[4].title = "operational_status_4_title_id"
	self.categories.operational_status.items[4].text = "operational_status_4_text_id"
	self.categories.operational_status.items[5] = {}
	self.categories.operational_status.items[5].id = "operational_status_5"
	self.categories.operational_status.items[5].list_item_name_id = "operational_status_5_list_item_name_id"
	self.categories.operational_status.items[5].update_date = "OCT 11 2017"
	self.categories.operational_status.items[5].update_person = "CONTROL"
	self.categories.operational_status.items[5].title = "operational_status_5_title_id"
	self.categories.operational_status.items[5].text = "operational_status_5_text_id"
	self.categories.operational_status.items[6] = {}
	self.categories.operational_status.items[6].id = "operational_status_6"
	self.categories.operational_status.items[6].list_item_name_id = "operational_status_6_list_item_name_id"
	self.categories.operational_status.items[6].update_date = "OCT 18 2017"
	self.categories.operational_status.items[6].update_person = "CONTROL"
	self.categories.operational_status.items[6].title = "operational_status_6_title_id"
	self.categories.operational_status.items[6].text = "operational_status_6_text_id"
	self.categories.operational_status.items[7] = {}
	self.categories.operational_status.items[7].id = "operational_status_7"
	self.categories.operational_status.items[7].list_item_name_id = "operational_status_7_list_item_name_id"
	self.categories.operational_status.items[7].update_date = "OCT 26 2017"
	self.categories.operational_status.items[7].update_person = "CONTROL"
	self.categories.operational_status.items[7].title = "operational_status_7_title_id"
	self.categories.operational_status.items[7].text = "operational_status_7_text_id"
	self.categories.operational_status.items[8] = {}
	self.categories.operational_status.items[8].id = "operational_status_8"
	self.categories.operational_status.items[8].list_item_name_id = "operational_status_8_list_item_name_id"
	self.categories.operational_status.items[8].update_date = "OCT 26 2017"
	self.categories.operational_status.items[8].update_person = "CONTROL"
	self.categories.operational_status.items[8].title = "operational_status_8_title_id"
	self.categories.operational_status.items[8].text = "operational_status_8_text_id"
	self.categories.operational_status.items[9] = {}
	self.categories.operational_status.items[9].id = "operational_status_9"
	self.categories.operational_status.items[9].list_item_name_id = "operational_status_9_list_item_name_id"
	self.categories.operational_status.items[9].update_date = "DEC 12 2022"
	self.categories.operational_status.items[9].update_person = "CONTROL"
	self.categories.operational_status.items[9].title = "operational_status_9_title_id"
	self.categories.operational_status.items[9].text = "operational_status_9_text_id"
	self.categories.raid_personnel.items = {}
	self.categories.raid_personnel.items[1] = {}
	self.categories.raid_personnel.items[1].id = "raid_personnel_1"
	self.categories.raid_personnel.items[1].list_item_name_id = "personnel_sterling_header"
	self.categories.raid_personnel.items[1].header_name_id = "personnel_sterling_header"
	self.categories.raid_personnel.items[1].real_name_id = "personnel_sterling_real_name"
	self.categories.raid_personnel.items[1].rank_id = "personnel_sterling_rank"
	self.categories.raid_personnel.items[1].notes_id = "personnel_sterling_notes"
	self.categories.raid_personnel.items[1].texture = tweak_data.gui.icons.intel_table_personnel_img_sterling.texture
	self.categories.raid_personnel.items[1].texture_rect = tweak_data.gui.icons.intel_table_personnel_img_sterling.texture_rect
	self.categories.raid_personnel.items[1].description_vo_id = "char_creation_sterling_intro"
	self.categories.raid_personnel.items[2] = {}
	self.categories.raid_personnel.items[2].id = "raid_personnel_2"
	self.categories.raid_personnel.items[2].list_item_name_id = "personnel_rivet_header"
	self.categories.raid_personnel.items[2].header_name_id = "personnel_rivet_header"
	self.categories.raid_personnel.items[2].real_name_id = "personnel_rivet_real_name"
	self.categories.raid_personnel.items[2].rank_id = "personnel_rivet_rank"
	self.categories.raid_personnel.items[2].notes_id = "personnel_rivet_notes"
	self.categories.raid_personnel.items[2].texture = tweak_data.gui.icons.intel_table_personnel_img_rivet.texture
	self.categories.raid_personnel.items[2].texture_rect = tweak_data.gui.icons.intel_table_personnel_img_rivet.texture_rect
	self.categories.raid_personnel.items[2].description_vo_id = "char_creation_rivet_intro"
	self.categories.raid_personnel.items[3] = {}
	self.categories.raid_personnel.items[3].id = "raid_personnel_3"
	self.categories.raid_personnel.items[3].list_item_name_id = "personnel_kurgan_header"
	self.categories.raid_personnel.items[3].header_name_id = "personnel_kurgan_header"
	self.categories.raid_personnel.items[3].real_name_id = "personnel_kurgan_real_name"
	self.categories.raid_personnel.items[3].rank_id = "personnel_kurgan_rank"
	self.categories.raid_personnel.items[3].notes_id = "personnel_kurgan_notes"
	self.categories.raid_personnel.items[3].texture = tweak_data.gui.icons.intel_table_personnel_img_kurgan.texture
	self.categories.raid_personnel.items[3].texture_rect = tweak_data.gui.icons.intel_table_personnel_img_kurgan.texture_rect
	self.categories.raid_personnel.items[3].description_vo_id = "char_creation_kurgan_intro"
	self.categories.raid_personnel.items[4] = {}
	self.categories.raid_personnel.items[4].id = "raid_personnel_4"
	self.categories.raid_personnel.items[4].list_item_name_id = "personnel_wolfgang_header"
	self.categories.raid_personnel.items[4].header_name_id = "personnel_wolfgang_header"
	self.categories.raid_personnel.items[4].real_name_id = "personnel_wolfgang_real_name"
	self.categories.raid_personnel.items[4].rank_id = "personnel_wolfgang_rank"
	self.categories.raid_personnel.items[4].notes_id = "personnel_wolfgang_notes"
	self.categories.raid_personnel.items[4].texture = tweak_data.gui.icons.intel_table_personnel_img_wolfgang.texture
	self.categories.raid_personnel.items[4].texture_rect = tweak_data.gui.icons.intel_table_personnel_img_wolfgang.texture_rect
	self.categories.raid_personnel.items[4].description_vo_id = "char_creation_wolfgang_intro"
	self.categories.opposition_forces.items = {}
	self.categories.opposition_forces.items[1] = {}
	self.categories.opposition_forces.items[1].id = "opposition_forces_1"
	self.categories.opposition_forces.items[1].list_item_name_id = "opposition_heer_header"
	self.categories.opposition_forces.items[1].name_id = "opposition_heer_header"
	self.categories.opposition_forces.items[1].desc_id = "opposition_heer_notes"
	self.categories.opposition_forces.items[1].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture_rect
		},
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_herr_b.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_herr_b.texture_rect
		},
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_herr_c.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_herr_c.texture_rect
		}
	}
	self.categories.opposition_forces.items[1].description_vo_id = "control_enemy_wehr_inf"
	self.categories.opposition_forces.items[2] = {}
	self.categories.opposition_forces.items[2].id = "opposition_forces_2"
	self.categories.opposition_forces.items[2].list_item_name_id = "opposition_gebirgsjager_header"
	self.categories.opposition_forces.items[2].name_id = "opposition_gebirgsjager_header"
	self.categories.opposition_forces.items[2].desc_id = "opposition_gebirgsjager_notes"
	self.categories.opposition_forces.items[2].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_gebirgsjager_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_gebirgsjager_a.texture_rect
		},
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_gebirgsjager_b.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_gebirgsjager_b.texture_rect
		}
	}
	self.categories.opposition_forces.items[2].description_vo_id = "control_enemy_gebir"
	self.categories.opposition_forces.items[3] = {}
	self.categories.opposition_forces.items[3].id = "opposition_forces_3"
	self.categories.opposition_forces.items[3].list_item_name_id = "opposition_fallschirmjager_header"
	self.categories.opposition_forces.items[3].name_id = "opposition_fallschirmjager_header"
	self.categories.opposition_forces.items[3].desc_id = "opposition_fallschirmjager_notes"
	self.categories.opposition_forces.items[3].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_fallschirmjager_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_fallschirmjager_a.texture_rect
		},
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_fallschirmjager_b.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_fallschirmjager_b.texture_rect
		}
	}
	self.categories.opposition_forces.items[3].description_vo_id = "control_enemy_fallshi"
	self.categories.opposition_forces.items[4] = {}
	self.categories.opposition_forces.items[4].id = "opposition_forces_4"
	self.categories.opposition_forces.items[4].list_item_name_id = "opposition_ss_header"
	self.categories.opposition_forces.items[4].name_id = "opposition_ss_header"
	self.categories.opposition_forces.items[4].desc_id = "opposition_ss_notes"
	self.categories.opposition_forces.items[4].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_waffen_ss_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_waffen_ss_a.texture_rect
		},
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_waffen_ss_b.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_waffen_ss_b.texture_rect
		}
	}
	self.categories.opposition_forces.items[4].description_vo_id = "control_enemy_s_inf"
	self.categories.opposition_forces.items[5] = {}
	self.categories.opposition_forces.items[5].id = "opposition_forces_5"
	self.categories.opposition_forces.items[5].list_item_name_id = "opposition_sniper_header"
	self.categories.opposition_forces.items[5].name_id = "opposition_sniper_header"
	self.categories.opposition_forces.items[5].desc_id = "opposition_sniper_notes"
	self.categories.opposition_forces.items[5].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_sniper_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_sniper_a.texture_rect
		}
	}
	self.categories.opposition_forces.items[6] = {}
	self.categories.opposition_forces.items[6].id = "opposition_forces_6"
	self.categories.opposition_forces.items[6].list_item_name_id = "opposition_spotter_header"
	self.categories.opposition_forces.items[6].name_id = "opposition_spotter_header"
	self.categories.opposition_forces.items[6].desc_id = "opposition_spotter_notes"
	self.categories.opposition_forces.items[6].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_spotter_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_spotter_a.texture_rect
		}
	}
	self.categories.opposition_forces.items[7] = {}
	self.categories.opposition_forces.items[7].id = "opposition_forces_7"
	self.categories.opposition_forces.items[7].list_item_name_id = "opposition_flammenwerfer_header"
	self.categories.opposition_forces.items[7].name_id = "opposition_flammenwerfer_header"
	self.categories.opposition_forces.items[7].desc_id = "opposition_flammenwerfer_notes"
	self.categories.opposition_forces.items[7].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_flammen_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_flammen_a.texture_rect
		}
	}
	self.categories.opposition_forces.items[7].description_vo_id = "control_enemy_flamer"
	self.categories.opposition_forces.items[8] = {}
	self.categories.opposition_forces.items[8].id = "opposition_forces_8"
	self.categories.opposition_forces.items[8].list_item_name_id = "opposition_officer_header"
	self.categories.opposition_forces.items[8].name_id = "opposition_officer_header"
	self.categories.opposition_forces.items[8].desc_id = "opposition_officer_notes"
	self.categories.opposition_forces.items[8].images = {
		{
			texture = tweak_data.gui.icons.intel_table_opp_img_officer_a.texture,
			texture_rect = tweak_data.gui.icons.intel_table_opp_img_officer_a.texture_rect
		}
	}
	self.categories.opposition_forces.items[8].description_vo_id = "control_enemy_wehr_off"
end

function IntelTweakData:get_control_video_by_path(path)
	if not self.categories.control_archive then
		return
	end

	for item_index, item_data in pairs(self.categories.control_archive.items) do
		if item_data.video_path == path then
			return item_data.id
		end
	end
end

function IntelTweakData:get_item_data(category_name, item_id)
	for _, item_data in ipairs(self.categories[category_name].items) do
		if tostring(item_data.id) == tostring(item_id) then
			return item_data
		end
	end

	return nil
end
