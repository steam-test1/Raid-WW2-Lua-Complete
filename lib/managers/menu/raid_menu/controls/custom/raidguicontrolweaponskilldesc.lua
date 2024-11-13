RaidGUIControlWeaponSkillDesc = RaidGUIControlWeaponSkillDesc or class(RaidGUIControl)
RaidGUIControlWeaponSkillDesc.CONTENT_W = 352
RaidGUIControlWeaponSkillDesc.BUTTON_SPACING = 96
RaidGUIControlWeaponSkillDesc.BUTTON_Y = 23
RaidGUIControlWeaponSkillDesc.BUTTON_HEIGHT = 54
RaidGUIControlWeaponSkillDesc.BUTTON_WIDTH = 40
RaidGUIControlWeaponSkillDesc.LINE_START_X = 36
RaidGUIControlWeaponSkillDesc.LINE_STRIDE = 96
RaidGUIControlWeaponSkillDesc.LINE_Y = 45
RaidGUIControlWeaponSkillDesc.LINE_LENGTH = 64
RaidGUIControlWeaponSkillDesc.LINE_THICKNESS = 3
RaidGUIControlWeaponSkillDesc.STATUS_COLOR = Color("878787")
RaidGUIControlWeaponSkillDesc.CHALLENGE_LOCKED_TEXT = "menu_weapon_challenge_locked"
RaidGUIControlWeaponSkillDesc.CHALLENGE_IN_PROGRESS_TEXT = "menu_weapon_challenge_in_progress"
RaidGUIControlWeaponSkillDesc.CHALLENGE_COMPLETED_TEXT = "menu_weapon_challenge_completed"
RaidGUIControlWeaponSkillDesc.CHALLENGE_LOCKED_DESCRIPTION = "weapon_skill_challenge_locked"

function RaidGUIControlWeaponSkillDesc:init(parent, params)
	RaidGUIControlWeaponSkillDesc.super.init(self, parent, params)

	self._object = self._panel:panel(params)

	self:_create_labels()
	self:_create_progress_bar()
end

function RaidGUIControlWeaponSkillDesc:set_weapon_skill(skill_data)
	local skill = skill_data.value
	local skill_info = tweak_data.weapon_skills.skills[skill.skill_name]
	local name_id = skill_info.name_id

	self._name_label:set_text(self:translate(name_id, true) .. " " .. self:translate("menu_inventory_tier", true) .. " " .. RaidGUIControlButtonWeaponSkill.ROMAN_NUMERALS[skill.tier])

	local desc_id = skill_info.desc_id
	local done_id = ""

	self._desc_label:set_text(self:translate(desc_id, false))

	local challenge, count, target, min_range, max_range = nil

	if skill.challenge_id then
		challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill.challenge_id)
		local tasks = challenge:tasks()
		desc_id = skill.challenge_briefing_id or tasks[1]:briefing_id() or desc_id
		done_id = skill.challenge_done_text_id or tasks[1]:done_text_id() or done_id
		count = tasks[1]:current_count()
		target = tasks[1]:target()
		min_range = math.round(tasks[1]:min_range() / 100)
		max_range = math.round(tasks[1]:max_range() / 100)
	end

	self._challenge_locked_label:set_visible(false)
	self._desc_label:set_visible(true)

	if not skill.challenge_unlocked or not managers.weapon_skills:is_weapon_tier_unlocked(skill.weapon_id, skill.tier) then
		self._status_label:set_text(self:translate(RaidGUIControlWeaponSkillDesc.CHALLENGE_LOCKED_TEXT, true))

		local level_needed, class = managers.weapon_skills:get_character_level_needed_for_tier(skill.weapon_id, skill.tier)
		local challenge_locked_text = nil

		if class then
			challenge_locked_text = managers.localization:text("weapon_skill_challenge_unlocked_level_different_class", {
				TIER = nil,
				LEVEL = nil,
				CLASS = nil,
				TIER = skill.tier,
				CLASS = class,
				LEVEL = level_needed
			})
		else
			challenge_locked_text = managers.localization:text("weapon_skill_challenge_unlocked_level", {
				TIER = nil,
				LEVEL = nil,
				TIER = skill.tier,
				LEVEL = level_needed
			})
		end

		self._challenge_locked_label:set_text(utf8.to_upper(challenge_locked_text))

		local _, _, _, h = self._challenge_locked_label:text_rect()

		self._challenge_locked_label:set_h(h)
		self._challenge_locked_label:set_visible(true)
		self._desc_label:set_visible(false)

		local description_text = managers.localization:text(RaidGUIControlWeaponSkillDesc.CHALLENGE_LOCKED_DESCRIPTION, {
			TIER = nil,
			TIER = skill_data.i_tier
		})

		self._desc_label:set_text(description_text)
		self._progress_bar_panel:set_visible(false)
	elseif skill.challenge_unlocked and not managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill.challenge_id):completed() then
		self._status_label:set_text(self:translate(RaidGUIControlWeaponSkillDesc.CHALLENGE_IN_PROGRESS_TEXT, true))

		local range = max_range > 0 and max_range or min_range

		self._desc_label:set_text(managers.localization:text(desc_id, {
			RANGE = nil,
			AMOUNT = nil,
			WEAPON = nil,
			AMOUNT = target,
			RANGE = range,
			WEAPON = self:translate(tweak_data.weapon[skill.weapon_id].name_id)
		}))
		self._progress_bar_panel:set_visible(true)
		self:set_progress(count, target)
	elseif managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill.challenge_id):completed() then
		local range = max_range > 0 and max_range or min_range

		self._status_label:set_text(self:translate(RaidGUIControlWeaponSkillDesc.CHALLENGE_COMPLETED_TEXT, true))
		self._desc_label:set_text(managers.localization:text(done_id, {
			RANGE = nil,
			AMOUNT = nil,
			WEAPON = nil,
			AMOUNT = target,
			RANGE = range,
			WEAPON = self:translate(tweak_data.weapon[skill.weapon_id].name_id)
		}))
		self._progress_bar_panel:set_visible(true)
		self:set_progress(count, target)
	end
end

function RaidGUIControlWeaponSkillDesc:_create_labels()
	local params_name_label = {
		font_size = nil,
		color = nil,
		font = nil,
		y = 0,
		x = 0,
		h = 38,
		text = "UNKNOWN SKILL NAME",
		name = nil,
		name = self._params.name .. "_name_label",
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._name_label = self._object:label(params_name_label)
	local params_status_label = {
		font_size = nil,
		w = nil,
		align = "left",
		color = nil,
		text = "lol",
		vertical = "bottom",
		font = nil,
		y = 32,
		x = 0,
		h = 32,
		name = nil,
		name = self._params.name .. "_status_label",
		w = RaidGUIControlWeaponSkillDesc.CONTENT_W,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = RaidGUIControlWeaponSkillDesc.STATUS_COLOR
	}
	self._status_label = self._object:label(params_status_label)
	local params_desc_label = {
		font_size = nil,
		word_wrap = true,
		wrap = true,
		color = nil,
		w = nil,
		text = "Unknown skill description. Lorem ipsum glupsum tumsum. Kajaznam kolko ovog stane u tri linije mozda jos malo a mozda i ne.",
		font = nil,
		y = 96,
		x = 0,
		h = 100,
		name = nil,
		name = self._params.name .. "_desc_label",
		w = RaidGUIControlWeaponSkillDesc.CONTENT_W,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	}
	self._desc_label = self._object:label(params_desc_label)
	local tier_unlocks_at_level_label_params = {
		visible = false,
		h = 58,
		wrap = true,
		color = nil,
		font_size = nil,
		align = "left",
		text = "",
		font = nil,
		y = nil,
		x = 0,
		w = nil,
		layer = 1,
		name = "cant_equip_explenation_label",
		y = self._desc_label:y(),
		w = RaidGUIControlWeaponSkillDesc.CONTENT_W,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_red
	}
	self._challenge_locked_label = self._object:label(tier_unlocks_at_level_label_params)
end

function RaidGUIControlWeaponSkillDesc:_create_progress_bar()
	local progress_bar_panel_params = {
		w = nil,
		vertical = "bottom",
		x = 0,
		h = 32,
		name = nil,
		name = self._params.name .. "_progress_bar_panel",
		w = RaidGUIControlWeaponSkillDesc.CONTENT_W
	}
	self._progress_bar_panel = self._object:panel(progress_bar_panel_params)

	self._progress_bar_panel:set_bottom(self._object:h())

	local texture_center = "slider_large_center"
	local texture_left = "slider_large_left"
	local texture_right = "slider_large_right"
	local progress_bar_background_params = {
		h = nil,
		right = nil,
		left = nil,
		color = nil,
		layer = 1,
		w = nil,
		center = nil,
		name = nil,
		name = self._params.name .. "_progress_bar_background",
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = Color.white:with_alpha(0.5)
	}
	local progress_bar_background = self._progress_bar_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_foreground_panel_params = {
		h = nil,
		valign = "scale",
		layer = 2,
		y = 0,
		x = 0,
		w = nil,
		halign = "scale",
		name = nil,
		name = self._params.name .. "_progress_bar_foreground_panel",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h()
	}
	self._progress_bar_foreground_panel = self._progress_bar_panel:panel(progress_bar_foreground_panel_params)
	local progress_bar_background_params = {
		h = nil,
		right = nil,
		left = nil,
		color = nil,
		w = nil,
		center = nil,
		name = nil,
		name = self._params.name .. "_progress_bar_background",
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = tweak_data.gui.colors.raid_red
	}
	local progress_bar_background = self._progress_bar_foreground_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_text_params = {
		font_size = nil,
		h = nil,
		align = "center",
		color = nil,
		text = "123/456",
		vertical = "center",
		font = nil,
		y = -2,
		x = 0,
		w = nil,
		layer = 5,
		name = nil,
		name = self._params.name .. "_progress_bar_text",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._progress_text = self._progress_bar_panel:label(progress_bar_text_params)
end

function RaidGUIControlWeaponSkillDesc:set_progress(count, target)
	self._progress_bar_foreground_panel:set_w(self._progress_bar_panel:w() * count / target)

	if count ~= target then
		self._progress_text:set_text(tostring(count) .. "/" .. tostring(target))
	else
		self._progress_text:set_text(utf8.to_upper(managers.localization:text("menu_weapon_challenge_completed")))
	end
end

function RaidGUIControlWeaponSkillDesc:on_click_weapon_skill_button()
end

function RaidGUIControlWeaponSkillDesc:on_mouse_enter_weapon_skill_button()
end

function RaidGUIControlWeaponSkillDesc:on_mouse_exit_weapon_skill_button()
end
