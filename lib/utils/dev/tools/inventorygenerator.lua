InventoryGenerator = InventoryGenerator or class()
InventoryGenerator.path = "aux_assets\\inventory\\"
InventoryGenerator.web_image_base = "https://liongamelion.com/assets/challenge/"

function InventoryGenerator.generate()
	local items, error = InventoryGenerator._items()
	local json_path = InventoryGenerator._root_path() .. InventoryGenerator.path

	if not SystemFS:exists(json_path) then
		SystemFS:make_dir(json_path)
	end

	local defid_data = {}

	if items then
		InventoryGenerator._create_steam_itemdef(json_path .. "generated_inventory.json", items, defid_data)
		Application:trace("Generation Completed.", #items)
	else
		Application:error("Generation Failed No Items.")
	end

	print("next clear defid #", InventoryGenerator._next_clear_defid(defid_data, 1))
end

function InventoryGenerator.verify()
	local error = false

	for item, data in pairs(tweak_data.challenge_cards.cards) do
		if not data.bundle and type(data.bundle) ~= "table" then
			Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' is missing content.")

			error = true
		end
	end

	return not error
end

function InventoryGenerator._items()
	local items = {}
	local error = 0
	error = error + InventoryGenerator._items_challenge_cards(items)
	error = error + InventoryGenerator._items_card_exchange(items)
	error = error + InventoryGenerator._items_card_bundles(items)
	error = error + InventoryGenerator._items_card_crafts(items)

	return items, error > 0
end

function InventoryGenerator._items_challenge_cards(items)
	local error = 0
	local challenge_card_indexed_list = deep_clone(tweak_data.challenge_cards:get_all_cards_indexed())

	for card_idx, challenge_card_data in pairs(challenge_card_indexed_list) do
		local card_id = tweak_data.challenge_cards.cards_index[card_idx]

		Application:info("[InventoryGenerator] Building...", card_idx, card_id)

		local description = ""
		local tags = ""
		local rarity_color_hex = ""
		local rarity_name = challenge_card_data.rarity and managers.localization:text(challenge_card_data.rarity) or ""
		local collection_name = challenge_card_data.collection and managers.localization:text(challenge_card_data.collection) or ""

		if challenge_card_data.rarity and rarity_name and rarity_name ~= "" and false then
			local color = tweak_data.gui.colors[challenge_card_data.rarity]

			if color then
				rarity_color_hex = InventoryGenerator._create_hex_color(color)
			else
				Application:warn("[InventoryGenerator] No color tweakdata for", challenge_card_data.rarity)
			end

			description = description .. "[color=#d7d7d7]Rarity:[/color] [color=#" .. rarity_color_hex .. "]" .. rarity_name .. "[/color]\\n"
			tags = tags .. "rarity:" .. string.lower(rarity_name) .. ";"
		end

		if challenge_card_data.bonus_xp then
			description = description .. "[color=#d7d7d7]Awards: +" .. challenge_card_data.bonus_xp .. " Base Mission XP[/color]\\n"
		elseif challenge_card_data.bonus_xp_multiplier then
			description = description .. "[color=#d7d7d7]Awards: " .. challenge_card_data.bonus_xp_multiplier .. "x Base Mission XP[/color]\\n"
		end

		if challenge_card_data.loot_drop_group then
			description = description .. "[color=#d7d7d7]Awards: Special Loot Drop Item(s)[/color]\\n"
		end

		if challenge_card_data.achievement_id and challenge_card_data.achievement_id ~= "" then
			description = description .. "[color=#d7d7d7][i]Awards: " .. challenge_card_data.achievement_id .. " achievement[/i][/color]\\n"
		end

		local description_positive_text, description_negative_text = managers.challenge_cards:get_card_description(card_id)

		if description_positive_text or description_negative_text then
			description = description .. "\\n[color=#d7d7d7]Effects:[/color]"

			if description_positive_text and description_positive_text ~= "" then
				description = description .. "\\n[color=#70b35b]+ " .. description_positive_text .. "[/color]"
			end

			if description_negative_text and description_negative_text ~= "" then
				description = description .. "\\n[color=#de4a3e]- " .. description_negative_text .. "[/color]"
			end

			description = description .. "\\n"
		end

		if collection_name and collection_name ~= "" then
			description = description .. "\\n[color=#d7d7d7][i]" .. collection_name .. "[/i][/color]"
		end

		if description_negative_text ~= "" then
			challenge_card_data.display_type = challenge_card_data.display_type or "display_type_challenge_card"
			tags = tags .. "cards:challenge;"
		else
			challenge_card_data.display_type = challenge_card_data.display_type or "display_type_booster_card"
			tags = tags .. "cards:booster;"
		end

		if challenge_card_data.effects then
			challenge_card_data.extra_data = challenge_card_data.extra_data or {}

			for i, effect in ipairs(challenge_card_data.effects) do
				challenge_card_data.extra_data["dsl_effect_" .. i] = effect.type .. ":" .. effect.name .. ":" .. tostring(effect.value)
			end
		end

		challenge_card_data.item_slot = "challenge_card"
		challenge_card_data.description = description
		challenge_card_data.tags = tags
		challenge_card_data.name_color = rarity_color_hex

		table.insert(items, challenge_card_data)
	end

	return error
end

function InventoryGenerator._items_card_exchange(items)
	local error = 0

	for nick, data in pairs(tweak_data.challenge_cards.exchangers) do
		Application:info("[InventoryGenerator] Building Exchanger " .. nick .. " - DefID:" .. data.def_id)

		data.category = data.category or "item"
		data.name = managers.localization:text(data.category .. "_" .. nick)

		table.insert(items, data)
	end

	return error
end

function InventoryGenerator._items_card_bundles(items)
	local error = 0

	for nick, data in pairs(tweak_data.challenge_cards.bundles) do
		Application:info("[InventoryGenerator] Building Bundle " .. nick .. " - DefID:" .. data.def_id)

		data.category = data.category or "bundle"
		data.name = managers.localization:text(data.category .. "_" .. nick)

		table.insert(items, data)
	end

	return error
end

function InventoryGenerator._items_card_crafts(items)
	local error = 0

	for nick, data in pairs(tweak_data.challenge_cards.crafting_items) do
		Application:info("[InventoryGenerator] Building Crafting Item " .. nick .. " - DefID:" .. data.def_id)

		data.item_slot = "crafting_item"
		data.category = data.category or "item"
		local description = ""

		if data.tags_list and data.tags_list.card_scrap then
			local tag_loc = managers.localization:text(data.tags_list.card_scrap)
			description = description .. "[color=#d7d7d7][i]Torn up " .. tag_loc .. " card scraps.\\nCan be used for crafting or upgrading " .. tag_loc .. " cards.[/i][/color]\\n"
		end

		data.description = description
		data.tags = ""

		if data.tags_list then
			for tag, tagtype in pairs(data.tags_list) do
				data.tags = data.tags .. tag .. ":" .. tagtype .. ";"
			end
		end

		table.insert(items, data)
	end

	return error
end

function InventoryGenerator._create_steam_itemdef(json_path, items, defid_data)
	Application:trace("[InventoryGenerator._create_steam_itemdef] Items#", #items)

	local json = SystemFS:open(json_path, "w")

	json:puts("{")
	json:puts("\t\"appid\": " .. managers.dlc:get_app_id() .. ",")
	json:puts("\t\"items\": [")

	for count, item in ipairs(items) do
		InventoryGenerator._add_defid(item.def_id, item, defid_data)
		json:puts("\t{")

		if item.key_name and item.key_name ~= "" then
			json:puts("\t\"item_name\": \"" .. item.key_name .. "\",")

			local icon_name = item.texture or "cc_" .. item.key_name .. "_hud"

			json:puts("\t\"icon_url\": \"" .. InventoryGenerator.web_image_base .. icon_name .. ".png\",")

			if item.name and item.name ~= "" then
				json:puts("\t\"name\": \"" .. managers.localization:text(item.name) .. "\",")
			end
		elseif item.name and item.name ~= "" then
			json:puts("\t\"name\": \"" .. item.name .. "\",")
		end

		if item.category == "gameplay" then
			InventoryGenerator._create_steam_itemdef_gameplay(json, item, defid_data)
		elseif item.category == "bundles" then
			InventoryGenerator._create_steam_itemdef_bundle(json, item, defid_data)
		elseif item.category == "contents" then
			InventoryGenerator._create_steam_itemdef_content(json, item, defid_data)
		else
			json:puts("\t\"type\": \"item\",")
		end

		if item.recipes then
			local exchange_string = InventoryGenerator._make_bundle_string(item.recipes)

			if exchange_string ~= "" then
				json:puts("\t\"exchange\": \"" .. exchange_string .. "\",")
			end
		end

		if item.item_slot and item.item_slot ~= "" then
			json:puts("\t\"item_slot\": \"" .. item.item_slot .. "\",")
		end

		if item.display_type and item.display_type ~= "" then
			json:puts("\t\"display_type\": \"" .. managers.localization:text(item.display_type) .. "\",")
		end

		if item.tags and item.tags ~= "" then
			json:puts("\t\"tags\": \"" .. item.tags .. "\",")
		end

		if item.store_tags and item.store_tags ~= "" then
			json:puts("\t\"store_tags\": \"" .. item.store_tags .. "\",")
		end

		if item.description and item.description ~= "" then
			json:puts("\t\"description\": \"" .. item.description .. "\",")
		end

		if item.name_color and item.name_color ~= "" then
			json:puts("\t\"name_color\": \"" .. item.name_color .. "\",")
		end

		if item.tradable and item.tradable == true then
			json:puts("\t\"tradable\": true,")
		end

		if item.marketable and item.marketable == true then
			json:puts("\t\"marketable\": true,")
		end

		if item.hidden and item.hidden == true then
			json:puts("\t\"hidden\": true,")
		end

		if item.auto_stack and item.auto_stack == true then
			json:puts("\t\"auto_stack\": true,")
		end

		if item.extra_data then
			for k, v in pairs(item.extra_data) do
				json:puts("\t\"" .. k .. "\": \"" .. v .. "\",")
			end
		end

		json:puts("\t\"itemdefid\": \"" .. item.def_id .. "\"")

		if count == #items then
			json:puts("\t}")
		else
			json:puts("\t},")
		end
	end

	json:puts("\t]")
	SystemFS:close(json)
end

function InventoryGenerator._create_steam_itemdef_gameplay(json, item, defid_data)
	json:puts("\t\"type\": \"playtimegenerator\",")

	if item.drop_window and item.drop_window > 0 then
		json:puts("\t\"drop_window\": \"" .. item.drop_window .. "\",")
	end

	if item.drop_max_per_window and item.drop_max_per_window > 0 then
		json:puts("\t\"drop_max_per_window\": \"" .. item.drop_max_per_window .. "\",")
	end

	if item.drop_interval and item.drop_interval > 0 then
		json:puts("\t\"drop_interval\": \"" .. item.drop_interval .. "\",")
	end

	if item.bundle then
		local bs = InventoryGenerator._make_bundle_string(item.bundle)

		json:puts("\t\"bundle\": \"" .. bs .. "\",")
	else
		Application:warn("[InventoryGenerator._create_steam_itemdef_gameplay] item lacks bundle data", item, item.def_id)
	end
end

function InventoryGenerator._create_steam_itemdef_bundle(json, item, defid_data)
	json:puts("\t\"type\": \"bundle\",")

	local bs = InventoryGenerator._make_bundle_string(item.bundle)

	json:puts("\t\"bundle\": \"" .. bs .. "\",")
end

function InventoryGenerator._make_bundle_string(data)
	if not data then
		Application:error("[InventoryGenerator._make_bundle_string] item lacks bundle data", data and inspect(data))

		return "ERROR"
	end

	Application:info("[InventoryGenerator._make_bundle_string]", inspect(data))

	local bundle_string = ""

	for _, group in ipairs(data) do
		for _, item in ipairs(group) do
			local xorstar = "x"

			if type(item[1]) == "string" then
				xorstar = "*"
			end

			bundle_string = bundle_string .. item[1] .. xorstar .. (item[2] or 1) .. ";"
		end
	end

	return bundle_string
end

function InventoryGenerator._create_steam_itemdef_content(json, item, defid_data)
	Application:info("[InventoryGenerator._create_steam_itemdef_content] START ", json, inspect(item), defid_data)
	json:puts("\t\"type\": \"generator\",")

	if item.bundle then
		local bs = InventoryGenerator._make_bundle_string(item.bundle)

		json:puts("\t\"bundle\": \"" .. bs .. "\",")
	else
		Application:warn("[InventoryGenerator._create_steam_itemdef_content] item lacks bundle data", item, item.def_id)
	end
end

function InventoryGenerator._defids(json_path)
	local defid_list = {}
	local json_data = InventoryGenerator.json_load(json_path)

	if json_data and json_data.items and type(json_data.items) == "table" then
		for _, item in pairs(json_data.items) do
			local def_id = tonumber(item.itemdefid)

			if defid_list[def_id] then
				Application:error("[InventoryGenerator._defids] - The item '" .. item.item_slot .. "." .. item.item_name .. "' conflicts with item '" .. defid_list[def_id].category .. "." .. defid_list[def_id].entry .. "'. They use the same ID (" .. tostring(def_id) .. ").")
			else
				defid_list[def_id] = true
			end
		end
	end

	return defid_list
end

function InventoryGenerator._create_id(category, entry)
	if not category or not entry then
		return
	end

	local id = category .. "_" .. entry

	return id
end

function InventoryGenerator._add_defid(def_id, item, defid_data)
	if defid_data[def_id] then
		Application:error("[InventoryGenerator._add_defid] Definition IDX already occupied!", def_id, defid_data[def_id])
	else
		defid_data[def_id] = item
	end
end

function InventoryGenerator._next_clear_defid(defid_data, from)
	local safe = from or 1

	while defid_data[safe] do
		safe = safe + 1
	end

	return safe
end

function InventoryGenerator.json_load(path)
	if not SystemFS:exists(path) then
		return
	end

	local json = SystemFS:open(path, "r")
	local json_data = json:read()

	SystemFS:close(json)

	local start = json_data:find("{")

	return InventoryGenerator._json_entry(not start and json_data or json_data:sub(start + 1, stop and stop - 1))
end

function InventoryGenerator._json_entry(data_string)
	local key, temp = nil
	local i1 = 1
	local i2 = 1
	local data = {}

	while i2 and i2 < #data_string do
		i1 = data_string:find("\"", i2)
		i2 = data_string:find("\"", i1 and i1 + 1)

		if not i1 or not i2 then
			break
		end

		key = data_string:sub(i1 + 1, i2 - 1)
		i1 = data_string:find(":", i2)

		if not i1 then
			break
		end

		i2 = i1 + 1
		local first_char = data_string:match("^%s*(.+)", i2):sub(1, 1)

		if first_char == "[" then
			temp, i2 = InventoryGenerator._json_find_section(data_string, "%[", "%]", i1)
		elseif first_char == "{" then
			temp, i2 = InventoryGenerator._json_find_section(data_string, "{", "}", i1)
		end

		local pos = i2
		i2 = data_string:find(",", pos)

		if i2 then
			local str_pos = data_string:find("\"", pos)

			if str_pos and str_pos < i2 then
				str_pos = data_string:find("\"", str_pos + 1)
				local t = i2
				i2 = data_string:find(",", str_pos)
			end
		end

		data[key] = InventoryGenerator._json_value(data_string:sub(i1 + 1, i2 and i2 - 1))
	end

	return data
end

function InventoryGenerator._json_value(data_string)
	if not data_string or data_string == "" then
		return
	end

	local first_char = data_string:match("^%s*(.+)"):sub(1, 1)

	if first_char == "\"" then
		local start = data_string:find("\"")
		local stop = data_string:find("\"", start + 1)

		return data_string:sub(start + 1, stop and stop - 1)
	elseif first_char == "t" then
		local start = data_string:find("t")

		if data_string:sub(start, start + 4) == "true" then
			return true
		end
	elseif first_char == "f" then
		local start = data_string:find("f")

		if data_string:sub(start, start + 5) == "false" then
			return false
		end
	elseif first_char == "{" then
		local start, stop = InventoryGenerator._json_find_section(data_string, "{", "}")

		return InventoryGenerator._json_entry(data_string:sub(start + 1, stop and stop - 1))
	elseif first_char == "[" then
		local start, stop = InventoryGenerator._json_find_section(data_string, "%[", "%]")

		return InventoryGenerator._json_value_list(data_string:sub(start + 1, stop and stop - 1))
	else
		return tonumber(data_string)
	end
end

function InventoryGenerator._json_value_list(data_string)
	local data = {}
	local start = 1
	local stop = 1

	while stop and stop < #data_string do
		start, stop = InventoryGenerator._json_find_section(data_string, "{", "}", stop)

		if not start then
			break
		end

		table.insert(data, InventoryGenerator._json_entry(data_string:sub(start + 1, stop and stop - 1)))
	end

	return data
end

function InventoryGenerator._json_find_section(data_string, start_char, stop_char, pos)
	local stop = pos or 1
	local start = data_string:find(start_char, stop)
	local current = start

	while current do
		local i = data_string:find(start_char, current + 1)
		stop = data_string:find(stop_char, current + 1)

		if i and stop and i < stop then
			current = i + 1
		else
			current = nil
			local find_string = pos or 1

			while find_string do
				local string_start = data_string:find("\"", find_string)
				find_string = nil

				if string_start and stop and string_start < stop then
					local string_stop = data_string:find("\"", string_start + 1)

					if string_stop then
						if stop < string_stop then
							current = string_stop + 1
						else
							find_string = string_stop + 1
						end
					end
				end
			end
		end
	end

	return start, stop or #data_string
end

function InventoryGenerator._root_path()
	local path = Application:base_path() .. (CoreApp.arg_value("-assetslocation") or "..\\..\\")
	path = Application:nice_path(path, true)
	local f = nil

	function f(s)
		local str, i = string.gsub(s, "\\[%w_%.%s]+\\%.%.", "")

		return i > 0 and f(str) or str
	end

	return f(path)
end

function InventoryGenerator._create_hex_color(color)
	local r, g, b = color:unpack()

	return string.format("%X%X%X", r * 255, g * 255, b * 255)
end
