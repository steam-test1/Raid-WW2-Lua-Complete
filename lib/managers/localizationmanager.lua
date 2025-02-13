core:import("CoreLocalizationManager")
core:import("CoreClass")

LocalizationManager = LocalizationManager or class(CoreLocalizationManager.LocalizationManager)

function LocalizationManager:init()
	LocalizationManager.super.init(self)
	Application:set_default_letter(95)
end

function LocalizationManager:init_finalize()
	local clbk = callback(self, self, "setup_macros")

	managers.user:add_setting_changed_callback("controller_mod", clbk)
	managers.controller:add_hotswap_callback("localization_manager", clbk, 0)
	self:setup_macros()
end

function LocalizationManager:setup_macros()
	local type = managers.controller:get_default_wrapper_type()
	local btn_a = self:btn_macro("menu_controller_face_bottom", type)
	local btn_b = self:btn_macro("menu_controller_face_right", type)
	local btn_x = self:btn_macro("menu_controller_face_left", type)
	local btn_y = self:btn_macro("menu_controller_face_top", type)
	local btn_start = self:btn_macro("start", type)
	local btn_back = self:btn_macro("menu_back", type)
	local btn_top_l = self:btn_macro("menu_controller_shoulder_left", type)
	local btn_top_r = self:btn_macro("menu_controller_shoulder_right", type)
	local btn_bottom_l = self:btn_macro("menu_controller_trigger_left", type)
	local btn_bottom_r = self:btn_macro("menu_controller_trigger_right", type)
	local btn_stick_l = self:btn_macro("run", type)
	local btn_stick_r = self:btn_macro("melee", type)
	local btn_dpad_u = self:btn_macro("menu_controller_dpad_down", type)
	local btn_dpad_r = self:btn_macro("menu_controller_dpad_right", type)
	local btn_dpad_d = self:btn_macro("menu_controller_dpad_up", type)
	local btn_dpad_l = self:btn_macro("menu_controller_dpad_left", type)
	local btn_accept = btn_start
	local btn_cancel = btn_back
	local btn_interact = self:btn_macro("interact", type)
	local btn_jump = self:btn_macro("jump", type)
	local btn_duck = self:btn_macro("duck", type)
	local btn_reload = self:btn_macro("reload", type)
	local btn_primary = self:btn_macro("primary_attack", type)
	local btn_secondary = self:btn_macro("secondary_attack", type)
	local btn_use_item = self:btn_macro("use_item", type)
	local btn_switch_weapon = self:btn_macro("switch_weapon", type)
	local btn_change_seat = self:btn_macro("vehicle_change_seat", type)
	local btn_stats_screen = self:btn_macro("stats_screen", type)

	self:set_default_macro("BTN_START", btn_start)
	self:set_default_macro("BTN_BACK", btn_back)
	self:set_default_macro("BTN_A", btn_a)
	self:set_default_macro("BTN_B", btn_b)
	self:set_default_macro("BTN_X", btn_x)
	self:set_default_macro("BTN_Y", btn_y)
	self:set_default_macro("BTN_TOP_L", btn_top_l)
	self:set_default_macro("BTN_TOP_R", btn_top_r)
	self:set_default_macro("BTN_BOTTOM_L", btn_bottom_l)
	self:set_default_macro("BTN_BOTTOM_R", btn_bottom_r)
	self:set_default_macro("BTN_STICK_L", btn_stick_l)
	self:set_default_macro("BTN_STICK_R", btn_stick_r)
	self:set_default_macro("BTN_INTERACT", btn_interact)
	self:set_default_macro("BTN_USE_ITEM", btn_use_item)
	self:set_default_macro("BTN_PRIMARY", btn_primary)
	self:set_default_macro("BTN_SECONDARY", btn_secondary)
	self:set_default_macro("BTN_RELOAD", btn_reload)
	self:set_default_macro("BTN_JUMP", btn_jump)
	self:set_default_macro("BTN_CROUCH", btn_duck)
	self:set_default_macro("BTN_ACCEPT", btn_accept)
	self:set_default_macro("BTN_CANCEL", btn_cancel)
	self:set_default_macro("CONTINUE", btn_a)
	self:set_default_macro("BTN_DPAD_DOWN", btn_dpad_d)
	self:set_default_macro("BTN_DPAD_UP", btn_dpad_u)
	self:set_default_macro("BTN_DPAD_RIGHT", btn_dpad_r)
	self:set_default_macro("BTN_DPAD_LEFT", btn_dpad_l)
	self:set_default_macro("BTN_SEAT", btn_change_seat)
	self:set_default_macro("BTN_SWITCH_WEAPON", btn_switch_weapon)
	self:set_default_macro("BTN_STATS_VIEW", btn_stats_screen)
end

function LocalizationManager:btn_macro(button, to_upper, type)
	type = type or managers.controller:get_default_wrapper_type()
	local key = tostring(managers.controller:get_settings(type):get_connection(button):get_input_name_list()[1])

	if type == "pc" then
		local text = "[" .. key .. "]"

		return to_upper and utf8.to_upper(text) or text
	end

	local buttons = tweak_data.input.controller_buttons[type]

	return buttons and buttons[key]
end

function LocalizationManager:ids(file)
	return Localizer:ids(Idstring(file))
end

function LocalizationManager:to_upper_text(string_id, macros)
	return utf8.to_upper(self:text(string_id, macros))
end

function LocalizationManager:debug_file(file)
	local t = {}
	local ids_in_file = self:ids(file)

	for i, ids in ipairs(ids_in_file) do
		local s = ids:s()
		local text = self:text(s, {
			BTN_INTERACT = self:btn_macro("interact")
		})
		t[s] = text
	end

	return t
end

CoreClass.override_class(CoreLocalizationManager.LocalizationManager, LocalizationManager)

function LocalizationManager:check_translation()
	local path = "d:/raid_ww2_trunk/assets/strings"
	local files = SystemFS:list(path)
	local p_files = {}
	local l_files = {}

	for i, file in ipairs(files) do
		local s_index = string.find(file, ".", 1, true)
		local e_index = string.find(file, ".", s_index + 1, true)
		local prename = string.sub(file, 1, s_index - 1)
		p_files[prename] = p_files[prename] or {}

		table.insert(p_files[prename], file)

		local language = not e_index and "english" or string.sub(file, s_index + 1, e_index - 1)
		l_files[language] = l_files[language] or {}

		table.insert(l_files[language], file)
	end

	local parsed = {}

	for language, files in pairs(l_files) do
		parsed[language] = parsed[language] or {}

		for _, file in ipairs(files) do
			for child in SystemFS:parse_xml(path .. "/" .. file):children() do
				parsed[language][child:parameter("id")] = child:parameter("value")
			end
		end
	end

	local out_file = io.open("d:/missing_strings.txt", "w+")

	io.output(out_file)
	io.write("Missing Localised Strings:\n")

	for language, ids in pairs(parsed) do
		if language ~= "english" then
			io.write("\tLanguage: " .. language .. "\n")

			for id, value in pairs(parsed.english) do
				if parsed[language][id] == nil then
					io.write("\t\tID: " .. id .. "\n")
				end
			end
		end
	end

	io.write("Non-Localised String:\n")

	for language, ids in pairs(parsed) do
		if language ~= "english" then
			io.write("\tLanguage: " .. language .. "\n")

			for id, value in pairs(ids) do
				if value == parsed.english[id] then
					io.write("\t\tID: " .. id .. "\n")
				end
			end
		end
	end

	io.close(out_file)
end

function LocalizationManager:check_keybind_translation(binding)
	self._keybind_translations = {
		"left ctrl",
		"right ctrl",
		"confirm",
		"enter",
		"esc",
		"left",
		"right",
		"up",
		"down",
		"space",
		"delete",
		"left shift",
		"right shift",
		"left alt",
		"right alt",
		"num",
		"mouse",
		"caps lock",
		"backspace",
		"insert",
		"home",
		"end",
		"page up",
		"page down",
		"scroll lock",
		"pause"
	}
	local translation = binding

	for _, binding_record in ipairs(self._keybind_translations) do
		if binding_record == "num" and string.sub(binding, 1, 3) == binding_record then
			translation = self:text("menu_keybind_" .. string.sub(binding, 1, 3)) .. string.sub(binding, 4, 5)
		elseif binding_record == "mouse" and string.sub(binding, 1, 5) == binding_record then
			translation = self:text("menu_keybind_" .. string.sub(binding, 1, 5)) .. string.sub(binding, 6, 7)
		elseif binding_record == binding then
			translation = self:text("menu_keybind_" .. string.gsub(binding, " ", "_"))
		end
	end

	return translation
end
