HUDTabCandyProgression = HUDTabCandyProgression or class()
HUDTabCandyProgression.Y = 20
HUDTabCandyProgression.WIDTH = 384
HUDTabCandyProgression.HEIGHT = 608
HUDTabCandyProgression.CARD_Y = 48
HUDTabCandyProgression.CARD_H = 234
HUDTabCandyProgression.TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDTabCandyProgression.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTabCandyProgression.TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabCandyProgression.TIER_TITLE_Y = 290
HUDTabCandyProgression.TIER_TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDTabCandyProgression.TIER_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTabCandyProgression.TIER_TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabCandyProgression.PROGRESS_BAR_Y = 290
HUDTabCandyProgression.PROGRESS_BAR_W = 168
HUDTabCandyProgression.PROGRESS_BAR_H = 26
HUDTabCandyProgression.PROGRESS_BAR_BOTTOM_Y = 16
HUDTabCandyProgression.PROGRESS_IMAGE_LEFT = "candy_progress_left"
HUDTabCandyProgression.PROGRESS_IMAGE_CENTER = "candy_progress_center"
HUDTabCandyProgression.PROGRESS_IMAGE_RIGHT = "candy_progress_right"
HUDTabCandyProgression.PROGRESS_IMAGE_OVERLAY = "candy_progress_overlay"
HUDTabCandyProgression.DEBUFF_TITLE_Y = 340
HUDTabCandyProgression.DEBUFF_W = 216
HUDTabCandyProgression.DEBUFF_TITLE_FONT = tweak_data.gui.fonts.lato
HUDTabCandyProgression.DEBUFF_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_18
HUDTabCandyProgression.DEBUFF_TITLE_COLOR = tweak_data.gui.colors.raid_light_grey

function HUDTabCandyProgression:init(panel, params)
	self._panel = panel

	self:_create_panel(panel, params)
	self:_create_card()
	self:_create_progress_bar()
	self:_create_tier_info()
	self:set_data(params)
end

function HUDTabCandyProgression:destroy()
	if self._panel:child("hud_tab_candy_progress") then
		self._panel:remove(self._object)
	end
end

function HUDTabCandyProgression:_create_panel(panel, params)
	self._object = panel:panel({
		valign = "bottom",
		name = "hud_tab_candy_progress",
		halign = "right",
		x = params.x or 0,
		y = params.y or self.Y,
		w = self.WIDTH,
		h = self.HEIGHT,
		layer = params.layer or panel:layer()
	})
end

function HUDTabCandyProgression:_create_card()
	local title = self._object:text({
		name = "candy_progression_title",
		text = managers.localization:to_upper_text("hud_active_event_details"),
		font = tweak_data.gui:get_font_path(self.TITLE_FONT, self.TITLE_FONT_SIZE),
		font_size = self.TITLE_FONT_SIZE,
		color = self.TITLE_COLOR
	})
	self._card_panel = RaidGUIPanel:new(self._object, {
		is_root_panel = true,
		layer = 3,
		vertical = "bottom",
		name = "candy_progress_bar_panel",
		y = self.CARD_Y,
		w = self.PROGRESS_BAR_W,
		h = self.CARD_H
	})
	self._card = self._card_panel:create_custom_control(RaidGUIControlCardBase, {
		name = "card",
		panel = self._card_panel,
		card_image_params = {
			w = self.PROGRESS_BAR_W,
			h = self.CARD_H
		}
	})
end

function HUDTabCandyProgression:_create_progress_bar()
	self._progress_bar_panel = RaidGUIPanel:new(self._object, {
		layer = 3,
		is_root_panel = true,
		vertical = "bottom",
		name = "candy_progress_bar_panel",
		y = self.PROGRESS_BAR_Y,
		w = self.PROGRESS_BAR_W,
		h = self.PROGRESS_BAR_H
	})

	self._progress_bar_panel:three_cut_bitmap({
		alpha = 0.5,
		layer = 1,
		name = "candy_progress_bar_background",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		left = self.PROGRESS_IMAGE_LEFT,
		center = self.PROGRESS_IMAGE_CENTER,
		right = self.PROGRESS_IMAGE_RIGHT
	})

	self._progress_bar_foreground_panel = self._progress_bar_panel:panel({
		valign = "scale",
		w = 0,
		layer = 2,
		name = "candy_progress_bar_foreground_panel",
		halign = "scale",
		h = self._progress_bar_panel:h()
	})
	local progress_bar = self._progress_bar_foreground_panel:three_cut_bitmap({
		name = "candy_progress_bar_background",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		left = self.PROGRESS_IMAGE_LEFT,
		center = self.PROGRESS_IMAGE_CENTER,
		right = self.PROGRESS_IMAGE_RIGHT,
		color = tweak_data.gui.colors.progress_orange
	})
	local icon_data = tweak_data.gui:get_full_gui_data(self.PROGRESS_IMAGE_OVERLAY)
	icon_data.texture_rect[3] = self._progress_bar_panel:w() * 0.55
	self._progress_bar_overlay = self._progress_bar_foreground_panel:bitmap({
		alpha = 0.3,
		wrap_mode = "wrap",
		name = "candy_progress_bar_background",
		blend_mode = "add",
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect,
		color = tweak_data.gui.colors.raid_dark_red,
		layer = progress_bar:layer() + 5
	})
end

function HUDTabCandyProgression:_create_tier_info()
	local font = tweak_data.gui:get_font_path(self.TIER_TITLE_FONT, self.TIER_TITLE_FONT_SIZE)
	local tier = 1
	self._tier_title = self._object:text({
		name = "tier_title",
		text = "TIER",
		align = "center",
		y = self.TIER_TITLE_Y,
		w = self.PROGRESS_BAR_W,
		font = font,
		font_size = self.TIER_TITLE_FONT_SIZE,
		color = self.SUBTITLE_COLOR,
		layer = self._progress_bar_panel:layer() + 5
	})
	self._malus_effects_panel = self._object:panel({
		h = 0,
		name = "malus_effects_panel",
		x = self._card_panel:right(),
		y = self._card_panel:y(),
		w = self.DEBUFF_W
	})
end

function HUDTabCandyProgression:set_data(data)
	if data.progress then
		self._progress_bar_foreground_panel:set_w(self._progress_bar_panel:w() * data.progress)
	end

	if data.card then
		self._card:set_card(data.card)
	end

	if data.tier then
		if data.tier < 1 then
			self._tier_title:set_visible(false)
		else
			local tier_text = managers.localization:to_upper_text("menu_inventory_tier") .. " " .. RaidGUIControlWeaponSkills.ROMAN_NUMERALS[data.tier]

			self._tier_title:set_text(tier_text)
			self._tier_title:set_visible(true)
		end

		local xp_bonus = (tweak_data:get_value("experience_manager", "sugar_high_bonus") - 1) * 100
		local xp_text = xp_bonus * data.tier .. "%"

		self._card:set_xp_bonus(xp_text)
	end

	if data.malus_effect then
		local y = self._malus_effects_panel:h()
		local icon_data = tweak_data.gui:get_full_gui_data(data.malus_effect.icon)
		local malus_icon = self._malus_effects_panel:bitmap({
			h = 28,
			w = 28,
			name = "malus_icon_" .. data.malus_effect.name,
			y = y + 2,
			texture = icon_data.texture,
			texture_rect = icon_data.texture_rect
		})
		local malus_text = self._malus_effects_panel:text({
			wrap = true,
			word_wrap = true,
			name = "malus_text_" .. data.malus_effect.name,
			x = malus_icon:right() + 4,
			y = y,
			w = self._malus_effects_panel:w() - malus_icon:w(),
			text = managers.localization:text(data.malus_effect.desc_id, data.malus_effect.desc_params),
			font = tweak_data.gui:get_font_path(self.DEBUFF_TITLE_FONT, self.DEBUFF_TITLE_FONT_SIZE),
			font_size = self.DEBUFF_TITLE_FONT_SIZE,
			color = self.DEBUFF_TITLE_COLOR
		})
		local _, _, w, h = malus_text:text_rect()

		malus_text:set_size(w, h)

		y = y + h + 8

		self._malus_effects_panel:set_h(y)
	end
end
