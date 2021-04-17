InventoryGenerator = InventoryGenerator or class()
InventoryGenerator.path = "aux_assets\\inventory\\"

-- Lines 5-92
function InventoryGenerator.generate()
	local items, error = InventoryGenerator._items()
	local json_path = InventoryGenerator._root_path() .. InventoryGenerator.path

	if not SystemFS:exists(json_path) then
		SystemFS:make_dir(json_path)
	end

	local defid_data = {}

	if items then
		InventoryGenerator._create_steam_itemdef(json_path .. "challenge_cards.json", items, defid_data)
	end

	Application:trace("Generation Completed.")
end

-- Lines 94-115
function InventoryGenerator.next_defid(category, defid_list)
	local start_index = 1

	if category then
		local categories = {
			safes = 50000,
			bundles = 30000,
			gameplay = 1,
			contents = 10000,
			weapon_skins = 100000,
			drills = 70000
		}

		if categories[category] then
			start_index = categories[category]
		end
	end

	local defids_check = defid_list or InventoryGenerator._defids(InventoryGenerator._root_path() .. InventoryGenerator.path)

	for count = start_index, 1000000 do
		if not defids_check[count] then
			return count
		end
	end

	Application:error("[InventoryGenerator.next_defid] - Couldn't find a free spot.")
end

-- Lines 117-197
function InventoryGenerator.verify()
	local error = false

	for item, data in pairs(tweak_data.economy.safes) do
		if not tweak_data.economy.contents[data.content] then
			Application:error("[InventoryGenerator.verify] - The item 'safes." .. item .. "' have an invalid content reference.")

			error = true
		elseif not tweak_data.economy.drills[data.drill] then
			Application:error("[InventoryGenerator.verify] - The item 'safes." .. item .. "' have an invalid drill reference.")

			error = true
		elseif tweak_data.economy.drills[data.drill].safe ~= item then
			Application:error("[InventoryGenerator.verify] - The item 'drills." .. data.drill .. "' have an invalid safe reference.")

			error = true
		end
	end

	for item, data in pairs(tweak_data.economy.drills) do
		if not tweak_data.economy.safes[data.safe] then
			Application:error("[InventoryGenerator.verify] - The item 'drills." .. item .. "' have an invalid safe reference.")

			error = true
		end
	end

	for item, data in pairs(tweak_data.economy.contents) do
		if not data.contains and type(data.contains) ~= "table" then
			Application:error("[InventoryGenerator.verify] - The item 'contents." .. item .. "' is missing content.")

			error = true
		else
			for category, items in pairs(data.contains) do
				local tweak_group = tweak_data.economy[category] or tweak_data.blackmarket[category]

				if not tweak_group then
					Application:error("[InventoryGenerator.verify] - The item 'contents." .. item .. "' have invalid content.")

					error = true
				else
					for _, entry in pairs(items) do
						if not tweak_group[entry] then
							Application:error("[InventoryGenerator.verify] - The item 'contents." .. item .. "' have invalid content. Item '" .. category .. "." .. entry .. "' doesn't exist.")

							error = true
						elseif category == "contents" and not tweak_group[entry].def_id then
							Application:error("[InventoryGenerator.verify] - The item 'contents." .. item .. "' have invalid content. Item '" .. category .. "." .. entry .. "' is not an economy item.")

							error = true
						elseif not tweak_group[entry].rarity then
							Application:error("[InventoryGenerator.verify] - The item 'contents." .. item .. "' have invalid content. Item '" .. category .. "." .. entry .. "' is missing a rarity flag.")

							error = true
						end
					end
				end
			end
		end
	end

	for item, data in pairs(tweak_data.economy.bundles) do
		if not data.contains and type(data.contains) ~= "table" then
			Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' is missing content.")

			error = true
		elseif not data.dlc and not data.dlc_id then
			Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' is awarded without any DLC requirement.")

			error = true
		else
			for category, items in pairs(data.contains) do
				local tweak_group = tweak_data.economy[category] or tweak_data.blackmarket[category]

				if not tweak_group then
					Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' have invalid content.")

					error = true
				else
					for _, entry in pairs(items) do
						if not tweak_group[entry] then
							Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' have invalid content. Item '" .. category .. "." .. entry .. "' doesn't exist.")

							error = true
						elseif category == "contents" and not tweak_group[entry].def_id then
							Application:error("[InventoryGenerator.verify] - The item 'bundles." .. item .. "' have invalid content. Item '" .. category .. "." .. entry .. "' is not an economy item.")

							error = true
						end
					end
				end
			end
		end
	end

	return not error
end

-- Lines 201-230
function InventoryGenerator._items_content(safe_items, contains)
	for category, items in pairs(contains) do
		for _, entry in pairs(items) do
			if category == "contents" then
				InventoryGenerator._items_content(safe_items, tweak_data.economy.contents[entry].contains)
			else
				local id = nil
				local item_data = tweak_data.blackmarket[category][entry]

				if not item_data then
					Application:error("[InventoryGenerator._items_content] - Item '" .. category .. "." .. entry .. "' is not available in blackmarket.")
				end

				if item_data.reserve_quality then
					for quality, _ in pairs(tweak_data.economy.qualities) do
						id = InventoryGenerator._create_id(category, entry, quality, false)
						safe_items[id] = {
							bonus = false,
							category = category,
							entry = entry,
							quality = quality,
							data = item_data
						}
					end

					for quality, _ in pairs(tweak_data.economy.qualities) do
						id = InventoryGenerator._create_id(category, entry, quality, true)
						safe_items[id] = {
							bonus = true,
							category = category,
							entry = entry,
							quality = quality,
							data = item_data
						}
					end
				else
					id = InventoryGenerator._create_id(category, entry)
					safe_items[id] = {
						category = category,
						entry = entry,
						data = item_data
					}
				end
			end
		end
	end
end

-- Lines 232-246
function InventoryGenerator._items_add(category, entry, def_id, content_data, safe_items, unique_def_ids)
	local id = InventoryGenerator._create_id(category, entry)
	safe_items[id] = {
		entry = entry,
		category = category,
		def_id = def_id,
		data = content_data
	}

	if def_id then
		if unique_def_ids[def_id] and unique_def_ids[def_id] ~= id then
			Application:error("[InventoryGenerator._items_add] - Item '" .. category .. "." .. entry .. "' have same ID as '" .. unique_def_ids[def_id] .. "' ( " .. def_id .. " ).")

			return 1
		end

		unique_def_ids[def_id] = id
	end

	return 0
end

-- Lines 248-269
function InventoryGenerator._items_containers(safe_items, contains, unique_def_ids)
	local error = 0

	for category, items in pairs(contains) do
		if category == "contents" then
			for _, entry in pairs(items) do
				local content_data = tweak_data.economy.contents[entry]

				if not content_data then
					Application:error("[InventoryGenerator._items_containers] - The item 'contents." .. entry .. "' is missing.")

					error = 1
				elseif not content_data.def_id then
					Application:error("[InventoryGenerator._items_containers] - The item 'contents." .. entry .. "' is missing an item ID ('def_id').")

					error = 1
				else
					error = error + InventoryGenerator._items_add(category, entry, content_data.def_id, content_data, safe_items, unique_def_ids)
				end
			end
		end
	end

	return error
end

-- Lines 271-315
function InventoryGenerator._items()
	local items = {}
	local error = 0
	local unique_def_ids = {}
	local challenge_card_indexed_list = tweak_data.challenge_cards:get_all_cards_indexed()

	for _, challenge_card_data in pairs(challenge_card_indexed_list) do
		table.insert(items, challenge_card_data)
	end

	return items, error > 0
end

-- Lines 319-347
function InventoryGenerator._probability_list(content, item_list)
	local id = nil
	local probability_list = {}

	for category, items in pairs(item_list) do
		local tweak_group = tweak_data.economy[category] or tweak_data.blackmarket[category]

		for _, entry in pairs(items) do
			local rarity = tweak_group[entry].rarity
			local rarity_bonus = tweak_group[entry].rarity .. "_bonus"
			local tweak_weight = InventorySetup.setup.rarities[content] or InventorySetup.setup.rarities.default

			if tweak_group[entry].reserve_quality then
				for quality, _ in pairs(tweak_data.economy.qualities) do
					id = InventoryGenerator._create_id(category, entry, quality, false)

					table.insert(probability_list, {
						bonus = false,
						id = id,
						category = category,
						entry = entry,
						quality = quality,
						weight = tweak_weight[rarity]
					})
				end

				for quality, _ in pairs(tweak_data.economy.qualities) do
					id = InventoryGenerator._create_id(category, entry, quality, true)

					table.insert(probability_list, {
						bonus = true,
						id = id,
						category = category,
						entry = entry,
						quality = quality,
						weight = tweak_weight[rarity_bonus]
					})
				end
			else
				id = InventoryGenerator._create_id(category, entry)

				table.insert(probability_list, {
					id = id,
					category = category,
					entry = entry,
					weight = tweak_weight[rarity] + tweak_weight[rarity_bonus]
				})
			end
		end
	end

	return probability_list
end

-- Lines 349-368
function InventoryGenerator._create_steam_itemdef_gameplay(json, tweak, defid_data)
	json:puts("\t\"type\": \"playtimegenerator\",")

	local bundle_string = ""

	for category, items in pairs(tweak.contains) do
		for _, entry in pairs(items) do
			local drop_rate = 0

			if not InventorySetup.setup.gameplay[category] or not InventorySetup.setup.gameplay[category][entry] then
				Application:error("[InventoryGenerator._create_steam_itemdef_gameplay] - Drop rate is missing on item " .. category .. "." .. entry .. ".")
			else
				drop_rate = InventorySetup.setup.gameplay[category][entry]
			end

			local id = InventoryGenerator._create_id(category, entry)
			bundle_string = bundle_string .. defid_data[id].def_id .. "x" .. drop_rate .. ";"
		end
	end

	json:puts("\t\"bundle\": \"" .. bundle_string .. "\",")
end

-- Lines 370-382
function InventoryGenerator._create_steam_itemdef_bundle(json, tweak, defid_data)
	json:puts("\t\"type\": \"bundle\",")

	local bundle_string = ""

	for category, items in pairs(tweak.contains) do
		for _, entry in pairs(items) do
			local id = InventoryGenerator._create_id(category, entry, tweak.quality, tweak.bonus)
			bundle_string = bundle_string .. defid_data[id].def_id .. "x1;"
		end
	end

	json:puts("\t\"bundle\": \"" .. bundle_string .. "\",")
end

-- Lines 384-425
function InventoryGenerator._create_steam_itemdef_content(json, tweak, entry, defid_data)
	json:puts("\t\"type\": \"generator\",")

	local proability_list = InventoryGenerator._probability_list(tweak.type or entry, tweak.contains)

	for _, data in pairs(proability_list) do
		data.def_id = defid_data[data.id].def_id
	end

	table.sort(proability_list, function (a, b)
		return a.weight == b.weight and a.def_id < b.def_id or b.weight < a.weight
	end)

	local bundle_string = ""

	for _, data in ipairs(proability_list) do
		if not data.def_id then
			Application:error("[InventoryGenerator._create_steam_itemdef_content] - Invalid definition ID on item " .. data.category .. "." .. data.entry .. ".")
		end

		if data.weight < 1 then
			Application:error("[InventoryGenerator._create_steam_itemdef_content] - Too low drop chance on item " .. data.category .. "." .. data.entry .. ".")
		end

		bundle_string = bundle_string .. data.def_id .. "x" .. data.weight .. ";"
	end

	json:puts("\t\"bundle\": \"" .. bundle_string .. "\",")

	local exchange_string = ""

	for safe_entry, safe_data in pairs(tweak_data.economy.safes) do
		if safe_data.content == entry then
			if safe_data.free then
				local safe_id = InventoryGenerator._create_id("safes", safe_entry)
				exchange_string = exchange_string .. defid_data[safe_id].def_id .. "x1;"
			elseif tweak_data.economy.drills[safe_data.drill] then
				local safe_id = InventoryGenerator._create_id("safes", safe_entry)
				local drill_id = InventoryGenerator._create_id("drills", safe_data.drill)
				exchange_string = exchange_string .. defid_data[safe_id].def_id .. "x1," .. defid_data[drill_id].def_id .. "x1;"
			end
		end
	end

	if exchange_string ~= "" then
		json:puts("\t\"exchange\": \"" .. exchange_string .. "\",")
	end
end

-- Lines 427-430
function InventoryGenerator._create_hex_color(color)
	local r, g, b = color:unpack()

	return string.format("%02X", r * 255) .. string.format("%02X", g * 255) .. string.format("%02X", b * 255)
end

-- Lines 432-485
function InventoryGenerator.create_description_safe(safe_entry)
	local safe_td = tweak_data.economy.safes[safe_entry]

	if not safe_td then
		return "", {}
	end

	local content_td = tweak_data.economy.contents[safe_td.content]

	if not content_td then
		return "", {}
	end

	local text = ""
	local items_list = {}

	for category, items in pairs(content_td.contains) do
		for _, item in ipairs(items) do
			items_list[#items_list + 1] = {
				category = category,
				entry = item
			}
		end
	end

	local x_td, y_td, xr_td, yr_td = nil

	-- Lines 453-464
	local function sort_func(x, y)
		x_td = (tweak_data.economy[x.category] or tweak_data.blackmarket[x.category])[x.entry]
		y_td = (tweak_data.economy[y.category] or tweak_data.blackmarket[y.category])[y.entry]
		xr_td = tweak_data.economy.rarities[x_td.rarity or "common"]
		yr_td = tweak_data.economy.rarities[y_td.rarity or "common"]

		if xr_td.index ~= yr_td.index then
			return xr_td.index < yr_td.index
		end

		return x.entry < y.entry
	end

	table.sort(items_list, sort_func)

	local td = nil

	for _, item in ipairs(items_list) do
		td = (tweak_data.economy[item.category] or tweak_data.blackmarket[item.category])[item.entry]
		text = text .. "[color=#" .. InventoryGenerator._create_hex_color(tweak_data.economy.rarities[td.rarity or "common"].color) .. "]"

		if item.category == "contents" and td.rarity == "legendary" then
			text = text .. managers.localization:text("bm_menu_rarity_legendary_item_long") .. "[/color]"
		else
			text = text .. (td.weapon_id and utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(td.weapon_id)) .. " | " or "") .. managers.localization:text(td.name_id)
		end

		if _ ~= #items_list then
			text = text .. "[/color]\\n"
		end
	end

	return text
end

-- Lines 487-514
function InventoryGenerator._find_item_in_content(entry, category, content)
	if category == "drills" or category == "safes" or category == "contents" then
		return false
	end

	local content_data = tweak_data.economy.contents[content]

	if content_data then
		for search_category, search_content in pairs(content_data.contains) do
			if search_category == "contents" then
				for _, search_entry in pairs(search_content) do
					if InventoryGenerator._find_item_in_content(entry, category, search_entry) then
						return true
					end
				end
			end

			if search_category == category then
				for _, search_entry in pairs(search_content) do
					if search_entry == entry then
						return true
					end
				end
			end
		end
	end

	return false
end

-- Lines 516-579
function InventoryGenerator._create_steam_itemdef(json_path, items, defid_data)
	local json = SystemFS:open(json_path, "w")

	json:puts("{")
	json:puts("\t\"appid\": " .. managers.dlc:get_app_id() .. ",")
	json:puts("\t\"items\": [")

	for count, item in ipairs(items) do
		json:puts("\t{")
		json:puts("\t\"itemdefid\": \"" .. item.def_id .. "\",")
		json:puts("\t\"item_name\": \"" .. item.key_name .. "\",")
		json:puts("\t\"item_slot\": \"" .. "challenge_card" .. "\",")

		if item.category == "gameplay" then
			InventoryGenerator._create_steam_itemdef_gameplay(json, tweak, defid_data)
		elseif item.category == "bundles" then
			InventoryGenerator._create_steam_itemdef_bundle(json, tweak, defid_data)
		elseif item.category == "contents" then
			InventoryGenerator._create_steam_itemdef_content(json, tweak, item.entry, defid_data)
		else
			json:puts("\t\"type\": \"item\",")
		end

		json:puts("\t\"name\": \"" .. managers.localization:text(item.name) .. "\",")
		json:puts("\t\"store_tags\": \"" .. "challenge card" .. "\",")

		local description_positive_text, description_negative_text = managers.challenge_cards:get_card_description(item.key_name)

		if description_positive_text ~= "" and description_negative_text ~= "" then
			json:puts("\t\"description\": \"" .. description_positive_text .. "; " .. description_negative_text .. "\",")
		elseif description_positive_text ~= "" and description_negative_text == "" then
			json:puts("\t\"description\": \"" .. description_positive_text .. "\",")
		elseif description_positive_text == "" and description_negative_text ~= "" then
			json:puts("\t\"description\": \"" .. description_negative_text .. "\",")
		end

		json:puts("\t\"icon_url\": \"https://s3-us-west-2.amazonaws.com/media.raidww2.com/steam_icons_challenge_cards/" .. item.key_name .. "_small.png\",")
		json:puts("\t\"icon_url_large\": \"https://s3-us-west-2.amazonaws.com/media.raidww2.com/steam_icons_challenge_cards/" .. item.key_name .. "_large.png\",")
		json:puts("\t\"name_color\": \"" .. "2360D8" .. "\",")

		local tradable = "true"
		local marketable = "false"

		json:puts("\t\"tradable\": " .. tradable .. ",")
		json:puts("\t\"marketable\": " .. marketable)

		if count == #items then
			json:puts("\t}")
		else
			json:puts("\t},")
		end
	end

	json:puts("\t]")
	json:puts("}")
	SystemFS:close(json)
end

-- Lines 581-608
function InventoryGenerator._create_steam_itemdef_clear(json_path, items, defid_data)
	local json = SystemFS:open(json_path, "w")

	json:puts("{")
	json:puts("\t\"appid\": 412890,")
	json:puts("\t\"items\": [")

	local keys_sorted = table.map_keys(items)

	for count, index in ipairs(keys_sorted) do
		local item = items[index]
		local tweak = item.data

		json:puts("\t{")
		json:puts("\t\"itemdefid\": " .. item.def_id)

		if count == #keys_sorted then
			json:puts("\t}")
		else
			json:puts("\t},")
		end
	end

	json:puts("\t]")
	json:puts("}")
	SystemFS:close(json)
end

-- Lines 612-628
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

-- Lines 630-642
function InventoryGenerator._create_id(category, entry, quality, bonus)
	if not category or not entry then
		return
	end

	local id = category .. "_" .. entry

	if quality then
		id = id .. (bonus and "_b_" or "_n_") .. quality
	end

	return id
end

-- Lines 644-672
function InventoryGenerator._fill_defids(list, json_path)
	local defid_list = {}
	local defid_data = {}

	for safe, safe_items in pairs(list) do
		local json_data = InventoryGenerator.json_load(json_path .. "safe_" .. safe .. ".json")

		if json_data and json_data.items and type(json_data.items) == "table" then
			for _, item in pairs(json_data.items) do
				local id = InventoryGenerator._create_id(item.item_slot, item.item_name, item.dsl_quality, item.dsl_bonus == "true", item.promo)
				local def_id = tonumber(item.itemdefid)

				if safe_items[id] then
					if not safe_items[id].def_id then
						safe_items[id].def_id = def_id
					elseif safe_items[id].def_id ~= def_id then
						Application:error("[InventoryGenerator._fill_defids] - The item '" .. item.item_slot .. "." .. item.item_name .. " have different ID since last time ( New: " .. tostring(safe_items[id].def_id) .. ", Old: " .. tostring(def_id) .. ").")
					end
				end

				defid_list[def_id] = true
				defid_data[id] = {
					category = item.item_slot,
					entry = item.item_name,
					quality = item.dsl_quality,
					bonus = item.dsl_bonus,
					def_id = def_id
				}
			end
		end
	end

	return defid_list, defid_data
end

-- Lines 674-697
function InventoryGenerator._fill_defids_OLD(list, json_path)
	local defid_list = {}
	local defid_data = {}
	local json_data = InventoryGenerator.json_load(json_path .. "inventory.json")

	if json_data and json_data.items and type(json_data.items) == "table" then
		for _, item in pairs(json_data.items) do
			local id = InventoryGenerator._create_id(item.item_slot, item.item_name, item.dsl_quality, item.dsl_bonus == "true")

			if id then
				local def_id = tonumber(item.itemdefid)

				for safe, safe_items in pairs(list) do
					if safe_items[id] and not safe_items[id].def_id then
						safe_items[id].def_id = def_id
					end
				end

				defid_list[def_id] = true
				defid_data[id] = {
					category = item.item_slot,
					entry = item.item_name,
					quality = item.dsl_quality,
					bonus = item.dsl_bonus,
					def_id = def_id
				}
			end
		end
	end

	return defid_list, defid_data
end

-- Lines 701-714
function InventoryGenerator.json_load(path)
	if not SystemFS:exists(path) then
		return
	end

	local json = SystemFS:open(path, "r")
	local json_data = json:read()

	SystemFS:close(json)

	local start = json_data:find("{")
	local stop = json_data:find("}[^}]*$")

	return InventoryGenerator._json_entry(not start and json_data or json_data:sub(start + 1, stop and stop - 1))
end

-- Lines 716-764
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

-- Lines 766-795
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

-- Lines 797-813
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

-- Lines 815-850
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

-- Lines 854-861
function InventoryGenerator._root_path()
	local path = Application:base_path() .. (CoreApp.arg_value("-assetslocation") or "..\\..\\")
	path = Application:nice_path(path, true)
	local f = nil

	-- Lines 859-859
	function f(s)
		local str, i = string.gsub(s, "\\[%w_%.%s]+\\%.%.", "")

		return i > 0 and f(str) or str
	end

	return f(path)
end
