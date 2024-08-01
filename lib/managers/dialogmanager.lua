DialogManager = DialogManager or class()
DialogManager.MAX_CASE_PLAYER_NUM = 4
DialogManager.MRS_WHITE = {
	sound_switch = "mrs_white",
	char = "MRS_WHITE"
}
DialogManager.NIGHT_WITCH = {
	sound_switch = "night_whitch",
	char = "NIGHT_WITCH"
}
DialogManager.FRANZ = {
	sound_switch = "franz",
	char = "FRANZ"
}
DialogManager.BOAT_DRIVER_BRIDGE = {
	sound_switch = "boat_driver_bridge",
	char = "BOAT_DRIVER_BRIDGE"
}
DialogManager.TRUCK_DRIVER_BRIDGE = {
	sound_switch = "truck_driver_bridge",
	char = "TRUCK_DRIVER_BRIDGE"
}
DialogManager.RESIST_PILOT_BANK = {
	sound_switch = "resist_pilot_bank",
	char = "RESIST_PILOT_BANK"
}
DialogManager.TRAIN_ENGINEER = {
	sound_switch = "train_engineer",
	char = "TRAIN_ENGINEER"
}
DialogManager.CASTLE_TRUCK_DRIVER = {
	sound_switch = "castle_truck_driver",
	char = "CASTLE_TRUCK_DRIVER"
}
DialogManager.MINIRAID2_TRUCK_DRIVER = {
	sound_switch = "miniraid2_truck_driver",
	char = "MINIRAID2_TRUCK_DRIVER"
}
DialogManager.BANK_TRUCK_DRIVER = {
	sound_switch = "bank_truck_driver",
	char = "BANK_TRUCK_DRIVER"
}
DialogManager.DR_REINHARDT = {
	sound_switch = "dr_reinhardt",
	char = "DR_REINHARDT"
}
DialogManager.TANK_GENERAL = {
	sound_switch = "tank_general",
	char = "TANK_GENERAL"
}
DialogManager.RUSSIAN_GENERAL = {
	sound_switch = "russian_general",
	char = "RUSSIAN_GENERAL"
}
DialogManager.RUSSIAN_GENERAL2 = {
	sound_switch = "russian_general2",
	char = "RUSSIAN_GENERAL2"
}
DialogManager.MALE_SPY = {
	sound_switch = "male_spy",
	char = "MALE_SPY"
}
DialogManager.FEMALE_SPY = {
	sound_switch = "female_spy",
	char = "FEMALE_SPY"
}
DialogManager.CHARS = {
	DialogManager.MRS_WHITE,
	DialogManager.NIGHT_WITCH,
	DialogManager.FRANZ,
	DialogManager.BOAT_DRIVER_BRIDGE,
	DialogManager.TRUCK_DRIVER_BRIDGE,
	DialogManager.RESIST_PILOT_BANK,
	DialogManager.TRAIN_ENGINEER,
	DialogManager.CASTLE_TRUCK_DRIVER,
	DialogManager.MINIRAID2_TRUCK_DRIVER,
	DialogManager.BANK_TRUCK_DRIVER,
	DialogManager.DR_REINHARDT,
	DialogManager.TANK_GENERAL,
	DialogManager.RUSSIAN_GENERAL,
	DialogManager.RUSSIAN_GENERAL2,
	DialogManager.MALE_SPY,
	DialogManager.FEMALE_SPY
}

-- Lines 46-55
function DialogManager:init()
	self._dialog_list = {}
	self._random_list = {}
	self._current_dialog = nil
	self._next_dialog = nil
	self._show_subtitles = true
	self._ventrilo_unit = World:spawn_unit(Idstring("units/vanilla/characters/players/fps_mover/mrs_white"), Vector3(), Rotation())
end

-- Lines 57-59
function DialogManager:init_finalize()
	self:_load_dialogs()
end

-- Lines 61-106
function DialogManager:_create_dialogue_instance(id, instigator, test)
	local dialogue = deep_clone(self._dialog_list[id])
	local char_names = managers.criminals:alive_criminal_names()
	local nr_criminals = math.min(#char_names, DialogManager.MAX_CASE_PLAYER_NUM)
	local default_char = nil

	if test then
		nr_criminals = 4
		char_names = managers.criminals:character_names()
		default_char = "british"
	end

	if dialogue.cases then
		for _, case in ipairs(dialogue.cases) do
			if string.find(case.players_no, nr_criminals, 1, true) then
				dialogue.lines = case.lines

				break
			end
		end
	end

	if instigator then
		table.delete(char_names, instigator)
	end

	local characters = {
		A = instigator or self:_random_criminal(char_names, default_char)
	}
	characters.B = self:_random_criminal(char_names, characters.A)
	characters.C = self:_random_criminal(char_names, characters.A)

	if dialogue.lines then
		for _, line in ipairs(dialogue.lines) do
			line.character = self:_parse_dialog_character(line.character, characters, dialogue, line, default_char)
		end
	else
		dialogue.character = self:_parse_dialog_character(dialogue.character, characters, dialogue, nil, default_char)
	end

	return dialogue
end

-- Lines 108-129
function DialogManager:_parse_dialog_character(char, characters, dialogue, line, default_char)
	local result = nil

	for _, v in ipairs(DialogManager.CHARS) do
		if v.char == char then
			result = v.sound_switch

			if line then
				line.third_person = v
			else
				dialogue.third_person = v
			end

			return result
		end
	end

	if not char then
		result = characters.A or managers.criminals:character_name_by_unit(managers.player:local_player()) or default_char
	else
		return characters[char]
	end

	return result
end

-- Lines 131-143
function DialogManager:_random_criminal(char_names, default)
	if not char_names or #char_names == 0 then
		return default
	end

	local num_chars = math.min(#char_names, DialogManager.MAX_CASE_PLAYER_NUM)
	local char_index = math.floor(math.random() * 100 % num_chars + 1)
	local char_name = char_names[char_index]

	table.remove(char_names, char_index)

	return char_name
end

-- Lines 146-152
function DialogManager:queue_random(id, params)
	local queue_item = self:get_random_queue_dialogue(id)

	self:queue_dialog(queue_item, params)

	local r = self._random_list[id]
	r.last = queue_item
end

-- Lines 155-178
function DialogManager:get_random_queue_dialogue(id)
	local r = self._random_list[id]

	if not r then
		debug_pause("[DialogManager:_random_criminal] Tried to queue random dialoge that does not exist:", id)

		return
	end

	local n = #r.dialogs

	if n == 0 then
		Application:error("[DialogManager:_random_criminal] Empty random dialog container!", id)

		return
	elseif n == 1 then
		return r.dialogs[1].id
	else
		local rand = math.random(n)

		if r.last then
			while r.last == rand do
				rand = math.random(n)
			end
		end

		return r.dialogs[rand].id
	end

	return nil
end

-- Lines 180-186
function DialogManager:sync_queue_dialog(id, instigator)
	if self._paused then
		return
	end

	self:do_queue_dialog(id, {
		instigator = instigator
	})
end

-- Lines 188-222
function DialogManager:queue_dialog(id, params, test)
	if not self._dialog_list[id] then
		Application:error("[DialogManager:queue_dialog] The dialog script tries to queue a dialog with id '" .. tostring(id) .. "' which doesn't seem to exist!")

		return false
	end

	if self._paused then
		return
	end

	if self._current_dialog and self._current_dialog.id == id or self._next_dialog and self._next_dialog.id == id then
		Application:warn("[DialogManager:queue_dialog] Dialog already playing, skipping", id)

		return
	end

	local chance = self._dialog_list[id].chance

	if chance < 1 then
		local rand = math.rand(1)

		if chance < rand then
			return
		end
	end

	if Network:is_server() then
		self:do_queue_dialog(id, params, test)
	else
		local instigator = self:_calc_instigator_string(params)

		managers.network:session():send_to_host("sync_queue_dialog", id, instigator or "nil")
	end
end

-- Lines 224-236
function DialogManager:_calc_instigator_string(params)
	local instigator = nil

	if params.instigator then
		if type(params.instigator) == "string" then
			if params.instigator ~= "nil" then
				instigator = params.instigator
			end
		else
			instigator = managers.criminals:character_name_by_unit(params.instigator)
		end
	end

	return instigator
end

-- Lines 238-250
function DialogManager:_calc_character_string(character)
	if not character then
		return
	end

	if type(character) == "string" then
		if character ~= "nil" then
			return character
		end
	else
		return managers.criminals:character_name_by_unit(character)
	end
end

-- Lines 252-268
function DialogManager:_get_dialog_characters(params)
	local characters = {}

	if params.char_a or params.instigator then
		characters.A = self:_calc_character_string(params.char_a or params.instigator)
	end

	if params.char_b then
		characters.B = self:_calc_character_string(params.char_b)
	end

	if params.char_c then
		characters.C = self:_calc_character_string(params.char_c)
	end

	return characters
end

-- Lines 270-275
function DialogManager:set_paused(value)
	self._paused = value

	if value then
		self:quit_dialog(false)
	end
end

-- Lines 277-279
function DialogManager:paused()
	return self._paused
end

-- Lines 281-330
function DialogManager:do_queue_dialog(id, params, test)
	local instigator = self:_calc_instigator_string(params)

	if Network:is_server() then
		local send = instigator or "nil"

		managers.network:session():send_to_peers_synched("sync_queue_dialog", id, send)
	end

	if not params.skip_idle_check and managers.platform:presence() == "Idle" then
		return
	end

	local nr_criminals = managers.criminals:nr_taken_criminals()

	if nr_criminals == 0 and not test then
		return
	end

	if not self._current_dialog then
		self._current_dialog = self:_create_dialogue_instance(id, instigator, test)
		self._current_dialog.params = params

		self:_play_dialog({
			dialog = self._current_dialog
		})
	else
		local dialog = self:_create_dialogue_instance(id, instigator, test)
		dialog.params = params

		if self._current_dialog.priority == dialog.priority and dialog.priority < 4 or dialog.priority < self._current_dialog.priority then
			self:_stop_dialog()

			self._current_dialog = dialog
			self._next_dialog = nil

			self:_play_dialog({
				dialog = self._current_dialog
			})
		else
			self:_call_done_callback(params and params.done_cbk, "skipped")

			return false
		end
	end

	return true
end

-- Lines 332-359
function DialogManager:finished()
	self:_stop_dialog()

	if self._current_dialog then
		if self._next_dialog then
			Application:debug("Skip current dialog, play new!")
			self:on_dialog_completed()

			self._current_dialog = self._next_dialog
			self._next_dialog = nil

			managers.queued_tasks:queue(nil, self._play_dialog, self, {
				dialog = self._current_dialog
			}, 1.5, nil)
		elseif self._current_dialog.line then
			local line = self._current_dialog.line + 1

			if line <= #self._current_dialog.lines then
				local delay = self._current_dialog.lines[self._current_dialog.line].delay or 0.5

				managers.queued_tasks:queue(nil, self._play_dialog, self, {
					dialog = self._current_dialog,
					line = line
				}, delay, nil)
			else
				self:on_dialog_completed()

				self._current_dialog = nil
			end
		else
			self:on_dialog_completed()

			self._current_dialog = nil
		end
	end
end

-- Lines 361-366
function DialogManager:on_dialog_completed()
	if self._current_dialog.params and self._current_dialog.params.done_cbk then
		self:_call_done_callback(self._current_dialog.params.done_cbk, "done")
	end
end

-- Lines 368-382
function DialogManager:quit_dialog(no_done_cbk)
	managers.queued_tasks:unqueue_all(nil, self)
	managers.subtitle:clear_subtitle()
	managers.subtitle:set_visible(false)
	managers.subtitle:set_enabled(false)
	self:_stop_dialog()

	if not no_done_cbk and self._current_dialog and self._current_dialog.params then
		self:_call_done_callback(self._current_dialog.params.done_cbk, "done")
	end

	self._current_dialog = nil
	self._next_dialog = nil
end

-- Lines 384-391
function DialogManager:conversation_names()
	local t = {}

	for name, _ in pairs(self._dialog_list) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

-- Lines 393-400
function DialogManager:random_names()
	local t = {}

	for name, _ in pairs(self._random_list) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

-- Lines 402-404
function DialogManager:on_simulation_ended()
	self:quit_dialog(true)
end

-- Lines 406-433
function DialogManager:_setup_position(dialog, char_data)
	local unit = managers.dialog._ventrilo_unit

	if not alive(unit) then
		return
	end

	if dialog.params.position then
		unit:set_position(dialog.params.position)

		if dialog.params.rotation then
			unit:set_rotation(dialog.params.rotation)
		end
	elseif char_data.unit then
		if alive(char_data.unit) then
			unit:set_position(char_data.unit:position())
			unit:set_rotation(char_data.unit:rotation())
		end
	else
		local player = managers.player:local_player()

		if alive(player) then
			unit:set_position(player:position())
			unit:set_rotation(player:rotation())
		end
	end

	return unit
end

-- Lines 435-527
function DialogManager:_play_dialog(data)
	local dialog = data.dialog
	local unit = dialog.params.on_unit or dialog.params.override_characters and managers.player:player_unit()
	local line = data.line or 1
	local third_person_data = dialog.third_person or dialog.lines and dialog.lines[line] and dialog.lines[line].third_person

	if dialog.lines and #dialog.lines > 0 then
		dialog.line = line
	end

	local char = dialog.character or dialog.lines and dialog.lines[dialog.line].character
	char = char or managers.criminals:character_name_by_unit(managers.player:player_unit()) or ""
	local nationality_icon = nil

	if tweak_data.gui.icons["nationality_small_" .. char] then
		nationality_icon = tweak_data.gui.icons["nationality_small_" .. char]
	end

	if not alive(unit) then
		if third_person_data then
			unit = self:_setup_position(dialog, third_person_data)
		else
			unit = managers.criminals:character_unit_by_name(char)
		end
	end

	if not alive(unit) then
		Application:error("The dialog script tries to access a unit named '" .. tostring(dialog.character) .. "', which doesn't seem to exist. Line will be skipped.")
		managers.dialog:finished()

		return
	end

	local char_voice = nil

	if third_person_data then
		unit:drama():set_voice(char)
	elseif char then
		char_voice = tweak_data.character[char].speech_prefix

		unit:drama():set_voice(char_voice)
	end

	if not nationality_icon then
		Application:debug("[DialogManager:_play_dialog] nationality_icon was NIL for dialogue.", data.line, inspect(data.dialog))
	end

	dialog.unit = unit
	local color_id = managers.criminals:character_color_id_by_unit(unit)
	local crim_color = tweak_data.chat_colors[color_id]

	if dialog.lines and #dialog.lines > 0 then
		local line_data = dialog.lines[line]

		if line_data.string_id then
			local s = line_data.string_id

			if char_voice then
				s = s .. "_" .. char_voice
			end

			if self._show_subtitles then
				unit:drama():play_subtitle(s, nil, crim_color, nationality_icon)
			end
		end

		if line_data.sound then
			if unit == managers.player:local_player() then
				managers.player:stop_all_speaking_except_dialog()
			end

			unit:drama():play_sound(line_data.sound, dialog.sound_source)
		end
	else
		if dialog.string_id then
			local s = dialog.string_id

			if char_voice then
				s = s .. "_" .. char_voice
			end

			if self._show_subtitles then
				unit:drama():play_subtitle(s, nil, crim_color, nationality_icon)
			end
		end

		if dialog.sound then
			if unit == managers.player:local_player() then
				managers.player:stop_all_speaking_except_dialog()
			end

			unit:drama():play_sound(dialog.sound, dialog.sound_source)
		end
	end
end

-- Lines 529-535
function DialogManager:_stop_dialog()
	if self._current_dialog and alive(self._current_dialog.unit) then
		self._current_dialog.unit:drama():stop_cue()
	end
end

-- Lines 537-542
function DialogManager:_call_done_callback(done_cbk, reason)
	if done_cbk then
		done_cbk(reason)
	end
end

-- Lines 544-553
function DialogManager:_load_dialogs()
	local file_name = "gamedata/dialogs/index"
	local data = PackageManager:script_data(Idstring("dialog_index"), file_name:id())

	for _, c in ipairs(data) do
		if c.name then
			self:_load_dialog_data(c.name)
		end
	end
end

-- Lines 555-608
function DialogManager:_load_dialog_data(name)
	local file_name = "gamedata/dialogs/" .. name
	local data = PackageManager:script_data(Idstring("dialog"), file_name:id())

	for _, node in ipairs(data) do
		if node._meta == "dialog" then
			if not node.id then
				Application:throw_exception("Error in '" .. file_name .. "'! A node definition must have an id parameter!")

				break
			end

			self._dialog_list[node.id] = {
				id = node.id,
				character = node.character,
				sound = node.sound,
				string_id = node.string_id,
				priority = node.priority and tonumber(node.priority) or tweak_data.dialog.DEFAULT_PRIORITY,
				chance = node.chance and tonumber(node.chance) or 1,
				file_name = file_name
			}

			for _, child_node in ipairs(node) do
				if child_node._meta == "line" then
					self._dialog_list[node.id].multiline = true
					self._dialog_list[node.id].lines = self._dialog_list[node.id].lines or {}
					local line = self:_parse_line_node(child_node)

					table.insert(self._dialog_list[node.id].lines, line)
				elseif child_node._meta == "case" then
					self:_parse_case_node(node.id, child_node)
				end
			end

			if self._dialog_list[node.id].lines and node.sound then
				Application:throw_exception("Error in '" .. file_name .. "' in node " .. node.id .. "! Sound can't be defined in parameters when it have sound lines!")

				self._dialog_list[node.id].sound = nil
			end
		elseif node._meta == "random" then
			if not node.id then
				Application:throw_exception("Error in '" .. file_name .. "'! A node definition must have an id parameter!")

				break
			end

			self._random_list[node.id] = {
				id = node.id,
				dialogs = {}
			}

			for _, child_node in ipairs(node) do
				if child_node._meta == "dialog" then
					local d = {
						id = child_node.id
					}

					table.insert(self._random_list[node.id].dialogs, d)
				end
			end
		end
	end
end

-- Lines 610-617
function DialogManager:_parse_line_node(node)
	local sound = node.sound

	if not sound then
		Application:error("[DialogManager][_parse_line_node] Dialog line has no sound:  ", inspect(node))
	end

	return {
		sound = sound,
		character = node.character,
		string_id = node.string_id,
		delay = node.delay
	}
end

-- Lines 619-630
function DialogManager:_parse_case_node(parent_id, node)
	self._dialog_list[parent_id].cases = self._dialog_list[parent_id].cases or {}
	local case_node = {
		lines = {},
		id = node.id,
		players_no = node.players
	}

	for _, child_node in ipairs(node) do
		if child_node._meta == "line" then
			case_node.lines = case_node.lines or {}
			local line = self:_parse_line_node(child_node)
			case_node.lines[#case_node.lines + 1] = line
		end
	end

	table.insert(self._dialog_list[parent_id].cases, case_node)
end

-- Lines 632-652
function DialogManager:is_unit_talking(unit)
	if self._current_dialog then
		local character = managers.criminals:character_name_by_unit(unit)
		local current_sound = nil

		if self._current_dialog.character then
			current_sound = self._current_dialog.character
		elseif self._current_dialog.lines and self._current_dialog.line and self._current_dialog.lines[self._current_dialog.line] then
			current_sound = self._current_dialog.lines[self._current_dialog.line].character
		else
			Application:debug("[DialogManager:is_unit_talking()] current dialog without line!?", self._current_dialog.line, inspect(self._current_dialog.lines))
		end

		if character == current_sound then
			return true
		end
	end

	return false
end

-- Lines 654-665
function DialogManager:register_character(char, unit)
	local found = nil

	for _, v in ipairs(DialogManager.CHARS) do
		if v.char == char then
			v.unit = unit
			found = true
		end
	end

	if not found then
		debug_pause("[DialogManager:register_character] Trying to run register unknown dialogue character: ", char, unit)
	end
end

-- Lines 667-677
function DialogManager:update(t, dt)
	local player = managers.player:local_player()

	if alive(player) and alive(self._ventrilo_unit) and self:is_unit_talking(player) then
		self._ventrilo_unit:set_position(player:position())
		self._ventrilo_unit:set_rotation(player:rotation())
	end
end

-- Lines 679-724
function DialogManager:debug_print_missing_strings()
	for dialog_id, data in pairs(managers.dialog._dialog_list) do
		if data.cases then
			for _, case in pairs(data.cases) do
				for _, line in pairs(case.lines) do
					if line.string_id and string.find(managers.localization:text(line.string_id), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_brit"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_amer"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_ger"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_russ"), "ERROR:") then
						Application:debug("MISSING:", line.string_id, " DIALOG:", dialog_id)
					end
				end
			end
		elseif data.lines then
			for _, line in pairs(data.lines) do
				if line.string_id and string.find(managers.localization:text(line.string_id), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_brit"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_amer"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_ger"), "ERROR:") and string.find(managers.localization:text(line.string_id .. "_russ"), "ERROR:") then
					Application:debug("MISSING:", line.string_id, " DIALOG:", dialog_id)
				end
			end
		elseif data.string_id and string.find(managers.localization:text(data.string_id), "ERROR:") and string.find(managers.localization:text(data.string_id .. "_brit"), "ERROR:") and string.find(managers.localization:text(data.string_id .. "_amer"), "ERROR:") and string.find(managers.localization:text(data.string_id .. "_ger"), "ERROR:") and string.find(managers.localization:text(data.string_id .. "_russ"), "ERROR:") then
			Application:debug("MISSING:", data.string_id, " DIALOG:", dialog_id)
		end
	end
end

-- Lines 726-728
function DialogManager:set_subtitles_shown(show_subtitles)
	self._show_subtitles = not not show_subtitles
end

-- Lines 730-732
function DialogManager:is_showing_subtitles()
	return self._show_subtitles
end
