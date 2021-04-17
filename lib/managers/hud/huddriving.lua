HUDDriving = HUDDriving or class()
HUDDriving.W = 960
HUDDriving.H = 288
HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN = 32
HUDDriving.SLOT_PANEL_W = 96
HUDDriving.SLOT_PANEL_H = 84
HUDDriving.EMPTY_SEAT_ICON = "car_slot_empty"
HUDDriving.SLOT_NATIONALITY_BASE = "player_panel_nationality_"
HUDDriving.SEATING_ARRANGEMENT = {
	"driver",
	"passenger_front",
	"passenger_back_left",
	"passenger_back_right"
}
HUDDriving.HEALTH_W = 64
HUDDriving.HEALTH_H = 10
HUDDriving.HEALTH_BG_ICON = "backgrounds_vehicle_damage_bg"
HUDDriving.HEALTH_METER_COLORS = tweak_data.gui.colors.vehicle_health_colors
HUDDriving.CARRY_PANEL_PADDING_LEFT = 16
HUDDriving.CARRY_PANEL_PADDING_RIGHT = 9
HUDDriving.CARRY_PANEL_W = 10
HUDDriving.CARRY_PANEL_BG_ICON = "backgrounds_vehicle_bags_weight"
HUDDriving.CARRY_PANEL_INDICATOR_ICON = "vehicle_bags_weight_indicator"
HUDDriving.CARRY_INDICATOR_COLORS = tweak_data.gui.colors.vehicle_carry_amount_colors
HUDDriving.CARRY_INFO_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_20
HUDDriving.CARRY_INFO_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDDriving.BUTTON_PROMPTS_H = 64
HUDDriving.BUTTON_PROMPT_DISTANCE = 30
HUDDriving.BUTTON_PROMPT_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_20
HUDDriving.BUTTON_PROMPT_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDDriving.BUTTON_PROMPT_LOOK_BEHIND = "hud_driving_prompt_look_behind"
HUDDriving.BUTTON_PROMPT_SWITCH_POSE = "hud_driving_prompt_switch_pose"
HUDDriving.BUTTON_PROMPT_EXIT_VEHICLE = "hud_driving_prompt_exit_vehicle"
HUDDriving.BUTTON_PROMPT_CHANGE_SEAT = "hud_driving_prompt_change_seat"

function HUDDriving:init(hud)
	self:_create_panel(hud)
	self:_create_slot_panel()
	self:_create_carry_info()
	self:_create_button_prompts()
end

function HUDDriving:_create_panel(hud)
	local panel_params = {
		visible = false,
		name = "driving_panel",
		halign = "center",
		valign = "bottom",
		w = HUDDriving.W,
		h = HUDDriving.H
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_center_x(hud.panel:w() / 2)
	self._object:set_bottom(hud.panel:h())
end

function HUDDriving:_create_slot_panel()
	local slot_panel_params = {
		name = "slot_panel",
		halign = "left",
		valign = "bottom",
		w = HUDDriving.SLOT_PANEL_W,
		h = HUDDriving.SLOT_PANEL_H
	}
	self._slot_panel = self._object:panel(slot_panel_params)

	self._slot_panel:set_center_x(self._object:w() / 2)
	self._slot_panel:set_bottom(self._object:h())

	self._slots = {}

	for i = 1, 4 do
		local empty_slot_params = {
			name = "empty_slot_" .. tostring(i),
			texture = tweak_data.gui.icons[HUDDriving.EMPTY_SEAT_ICON].texture,
			texture_rect = tweak_data.gui.icons[HUDDriving.EMPTY_SEAT_ICON].texture_rect
		}
		local empty_slot = self._slot_panel:bitmap(empty_slot_params)
		local placeholder_nationality_icon = HUDDriving.SLOT_NATIONALITY_BASE .. "german"
		local taken_slot_params = {
			layer = 2,
			name = "taken_slot_" .. tostring(i),
			texture = tweak_data.gui.icons[placeholder_nationality_icon].texture,
			texture_rect = tweak_data.gui.icons[placeholder_nationality_icon].texture_rect
		}
		local taken_slot = self._slot_panel:bitmap(taken_slot_params)

		if i % 2 == 0 then
			empty_slot:set_center_x(3 * self._slot_panel:w() / 4)
			taken_slot:set_center_x(3 * self._slot_panel:w() / 4)
		else
			empty_slot:set_center_x(self._slot_panel:w() / 4)
			taken_slot:set_center_x(self._slot_panel:w() / 4)
		end

		if math.ceil(i / 2 - 1) >= 1 then
			empty_slot:set_center_y(3 * self._slot_panel:h() / 4)
			taken_slot:set_center_y(3 * self._slot_panel:h() / 4)
		else
			empty_slot:set_center_y(self._slot_panel:h() / 4)
			taken_slot:set_center_y(self._slot_panel:h() / 4)
		end

		local slot = {
			free = true,
			empty = empty_slot,
			taken = taken_slot
		}

		table.insert(self._slots, slot)
	end
end

function HUDDriving:_create_carry_info()
	local carry_panel_x = self._slot_panel:x() + self._slot_panel:w() + HUDDriving.CARRY_PANEL_PADDING_LEFT
	local carry_info_panel_params = {
		halign = "right",
		name = "carry_info_panel",
		y = 0,
		valign = "scale",
		x = carry_panel_x,
		w = self._object:w() - carry_panel_x,
		h = self._slot_panel:h() + 20
	}
	local carry_info_panel = self._object:panel(carry_info_panel_params)

	carry_info_panel:set_bottom(self._slot_panel:bottom())

	local carry_panel_background_params = {
		name = "carry_background",
		texture = tweak_data.gui.icons[HUDDriving.CARRY_PANEL_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDDriving.CARRY_PANEL_BG_ICON].texture_rect
	}
	local carry_panel_background = carry_info_panel:bitmap(carry_panel_background_params)

	carry_panel_background:set_bottom(carry_info_panel:h())

	local carry_indicator_params = {
		name = "carry_indicator",
		layer = 5,
		texture = tweak_data.gui.icons[HUDDriving.CARRY_PANEL_INDICATOR_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDDriving.CARRY_PANEL_INDICATOR_ICON].texture_rect
	}
	self._carry_indicator = carry_info_panel:bitmap(carry_indicator_params)

	self._carry_indicator:set_y(0)
	self._carry_indicator:set_center_x(carry_panel_background:center_x())

	local carry_info_text_x = self._carry_indicator:x() + self._carry_indicator:w() + HUDDriving.CARRY_PANEL_PADDING_RIGHT
	local carry_info_text_params = {
		vertical = "center",
		name = "carry_info_text",
		align = "left",
		text = "",
		halign = "center",
		valign = "left",
		x = carry_info_text_x,
		w = carry_info_panel:w() - carry_info_text_x,
		font = HUDDriving.CARRY_INFO_TEXT_FONT,
		font_size = HUDDriving.CARRY_INFO_TEXT_FONT_SIZE
	}
	self._carry_info_text = carry_info_panel:text(carry_info_text_params)

	self._carry_info_text:set_center_y(self._carry_indicator:center_y())
end

function HUDDriving:_create_button_prompts()
	local button_prompts_panel_params = {
		alpha = 0,
		name = "button_prompts_panel",
		halign = "scale",
		valign = "top",
		w = self._object:w(),
		h = HUDDriving.BUTTON_PROMPTS_H
	}
	self._button_prompts_panel = self._object:panel(button_prompts_panel_params)
end

function HUDDriving:show(vehicle)
	self._vehicle = vehicle

	vehicle:character_damage():add_listener("hud_driving_damage", {
		"hurt",
		"death"
	}, callback(self, self, "on_vehicle_damaged"))

	local loot = vehicle:vehicle_driving():get_loot()
	local current_loot_amount = vehicle:vehicle_driving():get_current_loot_amount()
	local max_loot = vehicle:vehicle_driving():get_max_loot()

	self:set_vehicle_loot_info(self._vehicle, loot, current_loot_amount, max_loot)
	self._object:set_visible(true)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))
	managers.controller:add_hotswap_callback("hud_driving", callback(self, self, "controller_mod_changed"))
	self:refresh_button_prompts()
end

function HUDDriving:controller_mod_changed()
	self:refresh_button_prompts(true)
end

function HUDDriving:refresh_button_prompts(force)
	if not managers.player:current_state() == "driving" then
		return
	end

	local seat_prompts = self:_get_prompts_needed_for_current_seat()
	local have_new_prompts = false

	if self._current_seat_prompts and #seat_prompts == #self._current_seat_prompts then
		for i = 1, #seat_prompts do
			local found_match = false

			for j = 1, #self._current_seat_prompts do
				if seat_prompts[i].name == self._current_seat_prompts[j].name then
					found_match = true

					break
				end
			end

			if not found_match then
				have_new_prompts = true
			end
		end
	else
		have_new_prompts = true
	end

	if have_new_prompts or force then
		self._current_seat_prompts = seat_prompts

		self._button_prompts_panel:stop()
		self._button_prompts_panel:animate(callback(self, self, "_animate_refresh_seats"))
	end
end

function HUDDriving:_create_button_prompt(prompt_name, prompt, buttons)
	if managers.controller:is_xbox_controller_present() and not managers.menu:is_pc_controller() then
		buttons = managers.localization:get_default_macros()
	end

	local button_prompt_params = {
		vertical = "center",
		halign = "center",
		align = "center",
		valign = "center",
		name = "button_prompt_" .. tostring(prompt_name),
		font = HUDDriving.BUTTON_PROMPT_TEXT_FONT,
		font_size = HUDDriving.BUTTON_PROMPT_TEXT_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text(prompt, buttons))
	}
	local button_prompt = self._button_prompts_panel:text(button_prompt_params)
	local _, _, w, h = button_prompt:text_rect()

	button_prompt:set_w(w)
	button_prompt:set_h(h)
	button_prompt:set_center_y(self._button_prompts_panel:h() / 2)
end

function HUDDriving:_layout_button_prompts()
	local button_prompts = self._button_prompts_panel:children()
	local total_width = 0

	for index, button_prompt in pairs(button_prompts) do
		total_width = total_width + button_prompt:w()
	end

	total_width = total_width + (#button_prompts - 1) * HUDDriving.BUTTON_PROMPT_DISTANCE
	local x = math.floor((self._button_prompts_panel:w() - total_width) / 2)

	for index, button_prompt in pairs(button_prompts) do
		button_prompt:set_x(x)

		x = x + button_prompt:w() + HUDDriving.BUTTON_PROMPT_DISTANCE
	end
end

function HUDDriving:_create_current_seat_prompts()
	self._button_prompts_panel:clear()

	for index, prompt in pairs(self._current_seat_prompts) do
		self:_create_button_prompt(prompt.name, prompt.prompt, prompt.buttons)
	end

	self:_layout_button_prompts()
end

function HUDDriving:_get_prompts_needed_for_current_seat()
	local player_seat = self._vehicle:vehicle_driving():find_seat_for_player(managers.player:local_player())
	local seat_prompts = {}

	if player_seat.driving then
		table.insert(seat_prompts, {
			name = "look_behind",
			prompt = HUDDriving.BUTTON_PROMPT_LOOK_BEHIND,
			buttons = {
				STICK_R = managers.localization:btn_macro("vehicle_rear_camera")
			}
		})
	end

	if player_seat.has_shooting_mode then
		table.insert(seat_prompts, {
			name = "switch_pose",
			prompt = HUDDriving.BUTTON_PROMPT_SWITCH_POSE,
			buttons = {
				BTN_B = managers.localization:btn_macro("vehicle_shooting_stance")
			}
		})
	end

	table.insert(seat_prompts, {
		name = "exit_vehicle",
		prompt = HUDDriving.BUTTON_PROMPT_EXIT_VEHICLE,
		buttons = {
			BTN_TOP_R = managers.localization:btn_macro("vehicle_exit")
		}
	})
	table.insert(seat_prompts, {
		name = "change_seat",
		prompt = HUDDriving.BUTTON_PROMPT_CHANGE_SEAT,
		buttons = {
			BTN_TOP_L = managers.localization:btn_macro("vehicle_change_seat")
		}
	})

	return seat_prompts
end

function HUDDriving:on_vehicle_damaged()
end

function HUDDriving:refresh_health()
end

function HUDDriving:refresh_seats(refresh_button_prompts)
	if not self._vehicle then
		return
	end

	local seats = self._vehicle:vehicle_driving():seats()

	for index, seat in pairs(seats) do
		local seat_index = nil

		for i, seat_name in pairs(HUDDriving.SEATING_ARRANGEMENT) do
			if seat.name == seat_name then
				seat_index = i
			end
		end

		if not seat.occupant then
			self:free_seat(seat_index)
		else
			self:occupy_seat(seat_index, seat.occupant)
		end
	end

	if refresh_button_prompts then
		self:refresh_button_prompts()
	end
end

function HUDDriving:free_seat(id)
	self._slots[id].taken:set_visible(false)
	self._slots[id].empty:set_visible(true)

	self._slots[id].free = true
	self._slots[id].occupant = nil
end

function HUDDriving:occupy_seat(id, unit)
	local nationality = managers.criminals:character_name_by_unit(unit)

	if not nationality then
		return
	end

	self._slots[id].taken:set_image(tweak_data.gui.icons[HUDDriving.SLOT_NATIONALITY_BASE .. nationality].texture)
	self._slots[id].taken:set_texture_rect(unpack(tweak_data.gui.icons[HUDDriving.SLOT_NATIONALITY_BASE .. nationality].texture_rect))
	self._slots[id].taken:set_visible(true)
	self._slots[id].empty:set_visible(false)

	self._slots[id].free = false
	self._slots[id].occupant = unit
end

function HUDDriving:set_vehicle_loot_info(vehicle, current_loot, current_loot_amount, max_loot_amount)
	if vehicle ~= self._vehicle then
		return
	end

	if current_loot and current_loot[1] and current_loot[1].carry_id == "german_spy" then
		return
	end

	local loot_percentage = max_loot_amount == 0 and 0 or current_loot_amount / max_loot_amount
	local carry_panel = self._object:child("carry_info_panel")

	self._carry_indicator:set_bottom(carry_panel:h() - loot_percentage * (carry_panel:child("carry_background"):h() - self._carry_indicator:h()))
	self._carry_indicator:set_color(self:_get_color_for_percentage(HUDDriving.CARRY_INDICATOR_COLORS, loot_percentage))

	if current_loot and current_loot[1] and current_loot[1].carry_id and tweak_data.carry[current_loot[1].carry_id] then
		local loot_name = managers.localization:text(tweak_data.carry[current_loot[1].carry_id].name_id)
		local carry_info_text = loot_name .. " " .. tostring(current_loot_amount) .. "/" .. tostring(max_loot_amount)

		self._carry_info_text:set_text(utf8.to_upper(carry_info_text))
		self._carry_info_text:set_center_y(self._carry_indicator:center_y())

		if current_loot_amount == 0 then
			self._carry_info_text:set_alpha(0)
		else
			self._carry_info_text:set_alpha(1)
		end
	else
		self._carry_info_text:set_alpha(0)
	end
end

function HUDDriving:_get_color_for_percentage(color_table, percentage)
	for i = #color_table, 1, -1 do
		if color_table[i].start_percentage < percentage then
			return color_table[i].color
		end
	end

	return color_table[1].color
end

function HUDDriving:hide()
	if not self._vehicle then
		return
	end

	self._vehicle:character_damage():remove_listener("hud_driving_damage")

	self._vehicle = nil

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDDriving:_on_hidden()
	managers.controller:remove_hotswap_callback("hud_driving")

	self._current_seat_prompts = nil

	self._button_prompts_panel:clear()
	self._button_prompts_panel:set_alpha(0)
end

function HUDDriving:_animate_show()
	local duration = 0.5
	local t = self._object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)

		local current_bottom_distance = Easing.quartic_out(t, HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN, -HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

		self._object:set_bottom(self._object:parent():h() - current_bottom_distance)
	end

	self._object:set_alpha(1)
	self._object:set_bottom(self._object:parent():h())
end

function HUDDriving:_animate_hide()
	local duration = 0.25
	local t = (1 - self._object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 1, -1, duration)

		self._object:set_alpha(current_alpha)

		local current_bottom_distance = Easing.quartic_out(t, 0, HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

		self._object:set_bottom(self._object:parent():h() - current_bottom_distance)
	end

	self._object:set_alpha(0)
	self._object:set_bottom(self._object:parent():h() - HUDDriving.BOTTOM_DISTANCE_WHILE_HIDDEN)
	self._object:set_visible(false)
	self:_on_hidden()
end

function HUDDriving:_animate_refresh_seats()
	local fade_out_duration = 0.2
	local t = (1 - self._button_prompts_panel:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._button_prompts_panel:set_alpha(current_alpha)
	end

	self._button_prompts_panel:set_alpha(0)
	self:_create_current_seat_prompts()

	local fade_in_duration = 0.2
	local t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._button_prompts_panel:set_alpha(current_alpha)
	end

	self._button_prompts_panel:set_alpha(1)
end
