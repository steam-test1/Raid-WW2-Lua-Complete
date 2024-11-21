core:import("CoreLocalizationManager")
core:import("CoreClass")

LocalizationManager = LocalizationManager or class(CoreLocalizationManager.LocalizationManager)
LocalizationManager.TYPEWRITER_UTF_PREFIX = 55000

function LocalizationManager:init()
	LocalizationManager.super.init(self)
	self:_setup_macros()
	Application:set_default_letter(95)
end

function LocalizationManager:_convert_typewriter_font(char)
	local c = utf8.to_upper(char)
	local retVal = LocalizationManager.TYPEWRITER_UTF_PREFIX + string.byte(c)

	return retVal
end

function LocalizationManager:_setup_macros()
	local btn_a = utf8.char(57344)
	local btn_b = utf8.char(57345)
	local btn_x = utf8.char(57346)
	local btn_y = utf8.char(57347)
	local btn_back = utf8.char(57348)
	local btn_start = utf8.char(57349)
	local stick_l = utf8.char(57350)
	local stick_r = utf8.char(57351)
	local btn_top_l = utf8.char(57352)
	local btn_top_r = utf8.char(57353)
	local btn_bottom_l = utf8.char(57354)
	local btn_bottom_r = utf8.char(57355)
	local btn_stick_l = utf8.char(57356)
	local btn_stick_r = utf8.char(57357)
	local btn_dpad_d = utf8.char(57358)
	local btn_dpad_u = utf8.char(57359)
	local btn_dpad_l = utf8.char(57360)
	local btn_dpad_r = utf8.char(57361)
	local btn_inv_new = utf8.char(57362)
	local btn_ghost = utf8.char(57363)
	local btn_skull = utf8.char(57364)
	local btn_padlock = utf8.char(57365)
	local btn_stat_boost = utf8.char(57366)
	local btn_team_boost = utf8.char(57367)
	local btn_accept = btn_a
	local btn_cancel = btn_b
	local btn_attack = btn_a
	local btn_block = btn_b
	local btn_interact = btn_top_r
	local btn_primary = btn_bottom_r
	local btn_use_item = btn_top_l
	local btn_secondary = btn_top_l
	local btn_reload = btn_x
	local btn_jump = btn_a
	local swap_accept = false

	if IS_PS4 and PS4:pad_cross_circle_inverted() then
		swap_accept = true
	end

	if swap_accept then
		local btn_tmp = btn_a
		btn_a = btn_b
		btn_b = btn_tmp
		btn_accept = btn_a
		btn_cancel = btn_b
	end

	if IS_PC then
		btn_stick_r = stick_r
		btn_stick_l = stick_l
	end

	self:set_default_macro("BTN_BACK", btn_back)
	self:set_default_macro("BTN_START", btn_start)
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
	self:set_default_macro("STICK_L", stick_l)
	self:set_default_macro("STICK_R", stick_r)
	self:set_default_macro("BTN_INTERACT", btn_interact)
	self:set_default_macro("BTN_USE_ITEM", btn_use_item)
	self:set_default_macro("BTN_PRIMARY", btn_primary)
	self:set_default_macro("BTN_SECONDARY", btn_secondary)
	self:set_default_macro("BTN_RELOAD", btn_reload)
	self:set_default_macro("BTN_JUMP", btn_jump)
	self:set_default_macro("BTN_SKILLSET", btn_x)
	self:set_default_macro("BTN_CROUCH", btn_b)
	self:set_default_macro("BTN_ACCEPT", btn_accept)
	self:set_default_macro("BTN_CANCEL", btn_cancel)
	self:set_default_macro("BTN_ATTACK", btn_attack)
	self:set_default_macro("BTN_BLOCK", btn_block)
	self:set_default_macro("CONTINUE", btn_a)
	self:set_default_macro("BTN_GADGET", btn_dpad_d)
	self:set_default_macro("BTN_BIPOD", btn_dpad_d)
	self:set_default_macro("BTN_DPAD_UP", btn_dpad_u)
	self:set_default_macro("BTN_DPAD_RIGHT", btn_dpad_r)
	self:set_default_macro("BTN_DPAD_LEFT", btn_dpad_l)
	self:set_default_macro("BTN_INV_NEW", btn_inv_new)
	self:set_default_macro("BTN_GHOST", btn_ghost)
	self:set_default_macro("BTN_SKULL", btn_skull)
	self:set_default_macro("BTN_PADLOCK", btn_padlock)
	self:set_default_macro("BTN_SEAT", btn_top_l)
	self:set_default_macro("BTN_STAT_BOOST", btn_stat_boost)
	self:set_default_macro("BTN_TEAM_BOOST", btn_team_boost)
	self:set_default_macro("BTN_SWITCH_WEAPON", btn_y)
	self:set_default_macro("BTN_STATS_VIEW", btn_back)
	self:set_default_macro("BTN_RESET_SKILLS", btn_back)
	self:set_default_macro("BTN_RESET_ALL_SKILLS", btn_start)
end

function LocalizationManager:btn_macro(button, to_upper)
	if not managers.menu:is_pc_controller() then
		return
	end

	local type = managers.controller:get_default_wrapper_type()
	local key = tostring(managers.controller:get_settings(type):get_connection(button):get_input_name_list()[1])
	local text = "[" .. key .. "]"

	return to_upper and utf8.to_upper(text) or text
end

function LocalizationManager:ids(file)
	return Localizer:ids(Idstring(file))
end

function LocalizationManager:to_upper_text(string_id, macros)
	return utf8.to_upper(self:text(string_id, macros))
end

function LocalizationManager:steam_btn(button)
	return button
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

function LocalizationManager:check_translation()
	local path = "g:/projects/payday2/trunk/assets/strings"
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

		if e_index then
			-- Nothing
		end
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

	for language, ids in pairs(parsed) do
		if language ~= "english" then
			for id, value in pairs(ids) do
				if value == parsed.english[id] then
					print("same as english", language, id, value)
				end
			end
		end
	end
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
			translation = managers.localization:text("menu_keybind_" .. string.sub(binding, 1, 3)) .. string.sub(binding, 4, 5)
		elseif binding_record == "mouse" and string.sub(binding, 1, 5) == binding_record then
			translation = managers.localization:text("menu_keybind_" .. string.sub(binding, 1, 5)) .. string.sub(binding, 6, 7)
		elseif binding_record == binding then
			translation = managers.localization:text("menu_keybind_" .. string.gsub(binding, " ", "_"))
		end
	end

	return translation
end
