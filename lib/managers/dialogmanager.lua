DialogManager = DialogManager or class()
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

-- Lines 42-51
function DialogManager:init()
	self._dialog_list = {}
	self._random_list = {}
	self._current_dialog = nil
	self._next_dialog = nil
	self._show_subtitles = true
	self._ventrilo_unit = World:spawn_unit(Idstring("units/vanilla/characters/players/fps_mover/mrs_white"), Vector3(), Rotation())
end

-- Lines 53-55
function DialogManager:init_finalize()
	self:_load_dialogs()
end

-- Lines 57-110
function DialogManager:_create_dialogue_instance(id, instigator, test)
	local dialogue = deep_clone(self._dialog_list[id])
	local nr_criminals = managers.criminals:nr_taken_criminals()
	local char_names = managers.criminals:taken_criminal_names()
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

	local charA = nil

	if instigator then
		charA = instigator
	else
		charA = char_names[self:_random_criminal(nr_criminals)]
	end

	local charB = charA

	if nr_criminals > 1 then
		charB = char_names[self:_random_criminal(nr_criminals)]

		while charA == charB do
			charB = char_names[self:_random_criminal(nr_criminals)]
		end
	end

	local charC = charA

	if nr_criminals > 2 then
		charC = char_names[self:_random_criminal(nr_criminals)]

		while charC == charA or charC == charB do
			charC = char_names[self:_random_criminal(nr_criminals)]
		end
	end

	if dialogue.lines then
		for _, line in ipairs(dialogue.lines) do
			line.character = self:_parse_dialog_character(line.character, charA, charB, charC, dialogue, line, instigator, default_char)
		end
	else
		dialogue.character = self:_parse_dialog_character(dialogue.character, charA, charB, charC, dialogue, nil, instigator, default_char)
	end

	return dialogue
end

-- Lines 112-137
function DialogManager:_parse_dialog_character(char, charA, charB, charC, dialogue, line, instigator, default_char)
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
		result = instigator or managers.criminals:character_name_by_unit(managers.player:local_player()) or default_char
	elseif char == "A" then
		result = charA
	elseif char == "B" then
		result = charB
	elseif char == "C" then
		result = charC
	end

	return result
end

-- Lines 139-141
function DialogManager:_random_criminal(nr_criminals)
	return math.floor(math.random() * 100 % nr_criminals + 1)
end

-- Lines 144-166
function DialogManager:queue_random(id, params)
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
		self:queue_dialog(r.dialogs[1].id, params)
	else
		local rand = math.random(n)

		if r.last then
			while r.last == rand do
				rand = math.random(n)
			end
		end

		self:queue_dialog(r.dialogs[rand].id, params)

		r.last = rand
	end
end

-- Lines 168-174
function DialogManager:sync_queue_dialog(id, instigator)
	if self._paused then
		return
	end

	self:do_queue_dialog(id, {
		instigator = instigator
	})
end

-- Lines 176-207
function DialogManager:queue_dialog(id, params, test)
	if not self._dialog_list[id] then
		Application:error("[DialogManager:queue_dialog] The dialog script tries to queue a dialog with id '" .. tostring(id) .. "' which doesn't seem to exist!")

		return false
	end

	if self._paused then
		return
	end

	if self._current_dialog and self._current_dialog.id == id then
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

-- Lines 209-221
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

-- Lines 223-228
function DialogManager:set_paused(value)
	self._paused = value

	if value then
		self:quit_dialog(false)
	end
end

-- Lines 230-232
function DialogManager:paused()
	return self._paused
end

-- Lines 234-281
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
			Application:debug("[DialogManager:queue_dialog] Terminate current dialogue:", self._current_dialog.id, "Higher priority dialogue queued:", dialog.id)
			self:_stop_dialog()

			self._current_dialog = dialog
			self._next_dialog = nil

			self:_play_dialog({
				dialog = self._current_dialog
			})
		else
			Application:debug("[DialogManager:queue_dialog] Skip playing dialoge:", id, "Higher priority is already playing:", self._current_dialog.id)
			self:_call_done_callback(params and params.done_cbk, "skipped")

			return false
		end
	end

	return true
end

-- Lines 283-310
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

-- Lines 312-317
function DialogManager:on_dialog_completed()
	if self._current_dialog.params and self._current_dialog.params.done_cbk then
		self:_call_done_callback(self._current_dialog.params.done_cbk, "done")
	end
end

-- Lines 319-333
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

-- Lines 335-342
function DialogManager:conversation_names()
	local t = {}

	for name, _ in pairs(self._dialog_list) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

-- Lines 344-351
function DialogManager:random_names()
	local t = {}

	for name, _ in pairs(self._random_list) do
		table.insert(t, name)
	end

	table.sort(t)

	return t
end

-- Lines 353-355
function DialogManager:on_simulation_ended()
	self:quit_dialog(true)
end

-- Lines 357-380
function DialogManager:_setup_position(dialog, char_data)
	Application:debug("[DialogManager:_setup_position]", inspect(char_data))

	local unit = managers.dialog._ventrilo_unit

	if not alive(unit) then
		return
	end

	if dialog.params.position then
		unit:set_position(dialog.params.position)
	elseif char_data.unit then
		if alive(char_data.unit) then
			unit:set_position(char_data.unit:position())
			unit:set_rotation(char_data.unit:rotation())
		end
	elseif managers.player:local_player() then
		unit:set_position(managers.player:local_player():position())
		unit:set_rotation(managers.player:local_player():rotation())
	end

	return unit
end

-- Lines 382-479
function DialogManager:_play_dialog(data)
	local dialog = data.dialog
	local unit = dialog.params.on_unit or dialog.params.override_characters and managers.player:player_unit()
	local line = data.line or 1
	local third_person_data = dialog.third_person or dialog.lines and dialog.lines[line] and dialog.lines[line].third_person

	if dialog.lines and #dialog.lines > 0 then
		dialog.line = line
	end

	local char = dialog.character or dialog.lines and dialog.lines[dialog.line].character
	char = char or managers.criminals:character_name_by_unit(managers.player:player_unit())
	local nationality_icon = nil

	if char == "british" then
		nationality_icon = tweak_data.gui.icons.nationality_small_british
	elseif char == "german" then
		nationality_icon = tweak_data.gui.icons.nationality_small_german
	elseif char == "russian" then
		nationality_icon = tweak_data.gui.icons.nationality_small_russian
	elseif char == "american" then
		nationality_icon = tweak_data.gui.icons.nationality_small_american
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
		Application:debug("[DialogManager:_play_dialog] and nationality_icon is nil!!!!!!", data.dialog, data.line)
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
			Application:debug("[DialogManager:_play_dialog] Playing dialogue on unit:", char, unit, dialog.string_id)
		end
	end
end

-- Lines 481-487
function DialogManager:_stop_dialog()
	if self._current_dialog and alive(self._current_dialog.unit) then
		self._current_dialog.unit:drama():stop_cue()
	end
end

-- Lines 489-494
function DialogManager:_call_done_callback(done_cbk, reason)
	if done_cbk then
		done_cbk(reason)
		Application:debug("DialogManager:_call_done_callback")
	end
end

-- Lines 496-505
function DialogManager:_load_dialogs()
	local file_name = "gamedata/dialogs/index"
	local data = PackageManager:script_data(Idstring("dialog_index"), file_name:id())

	for _, c in ipairs(data) do
		if c.name then
			self:_load_dialog_data(c.name)
		end
	end
end

-- Lines 507-560
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

-- Lines 562-574
function DialogManager:_parse_line_node(node)
	local censored = node.censored
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

-- Lines 576-587
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

-- Lines 589-608
function DialogManager:is_dialogue_playing_for_local_player()
	local res = false

	if self._current_dialog then
		local local_crim = managers.criminals:local_character_name()
		local current_sound = nil

		if self._current_dialog.character then
			current_sound = self._current_dialog.character
		elseif self._current_dialog.lines and self._current_dialog.line and self._current_dialog.lines[self._current_dialog.line] then
			current_sound = self._current_dialog.lines[self._current_dialog.line].character
		else
			Application:debug("[DialogManager:is_dialogue_playing_for_local_player()] current dialog without line!?", self._current_dialog.line, inspect(self._current_dialog.lines))
		end

		if local_crim == current_sound then
			res = true
		end
	end

	return res
end

-- Lines 610-621
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

-- Lines 623-625
function DialogManager:update(t, dt)
end

-- Lines 627-672
function DialogManager:debug_print_missiong_strings()
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

-- Lines 674-676
function DialogManager:set_subtitles_shown(show_subtitles)
	self._show_subtitles = not not show_subtitles
end

-- Lines 678-680
function DialogManager:is_showing_subtitles()
	return self._show_subtitles
end
