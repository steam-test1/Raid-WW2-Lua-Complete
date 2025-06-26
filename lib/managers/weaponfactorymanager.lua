WeaponFactoryManager = WeaponFactoryManager or class()
WeaponFactoryManager._uses_tasks = false
WeaponFactoryManager._uses_streaming = true

function WeaponFactoryManager:init()
	self:_setup()

	self._tasks = {}
end

function WeaponFactoryManager:update(t, dt)
	if self._active_task then
		if self:_update_task(self._active_task) then
			self._active_task = nil

			self:_check_task()
		end
	elseif next(self._tasks) then
		self:_check_task()
	end
end

function WeaponFactoryManager:_check_task()
	if not self._active_task and #self._tasks > 0 then
		self._active_task = table.remove(self._tasks, 1)

		if not alive(self._active_task.p_unit) then
			self._active_task = nil

			self:_check_task()
		end
	end
end

function WeaponFactoryManager:_setup()
	if not Global.weapon_factory then
		Global.weapon_factory = {}
	end

	self._global = Global.weapon_factory
	Global.weapon_factory.loaded_packages = Global.weapon_factory.loaded_packages or {}
	self._loaded_packages = Global.weapon_factory.loaded_packages

	self:_read_factory_data()
end

function WeaponFactoryManager:_read_factory_data()
	self._parts_by_type = {}
	local weapon_data = tweak_data.weapon

	for id, data in pairs(tweak_data.weapon.factory.parts) do
		self._parts_by_type[data.type] = self._parts_by_type[data.type] or {}
		self._parts_by_type[data.type][id] = true
	end

	self._parts_by_weapon = {}
	self._part_used_by_weapons = {}

	for factory_id, data in pairs(tweak_data.weapon.factory) do
		if factory_id ~= "parts" then
			self._parts_by_weapon[factory_id] = self._parts_by_weapon[factory_id] or {}

			for _, part_id in ipairs(data.uses_parts) do
				if tweak_data.weapon.factory.parts[part_id] then
					local type = tweak_data.weapon.factory.parts[part_id].type
					self._parts_by_weapon[factory_id][type] = self._parts_by_weapon[factory_id][type] or {}

					table.insert(self._parts_by_weapon[factory_id][type], part_id)

					if not string.match(factory_id, "_npc") and weapon_data[self:get_weapon_id_by_factory_id(factory_id)] then
						self._part_used_by_weapons[part_id] = self._part_used_by_weapons[part_id] or {}

						table.insert(self._part_used_by_weapons[part_id], factory_id)
					end
				end
			end
		end
	end
end

function WeaponFactoryManager:get_weapons_uses_part(part_id)
	return self._part_used_by_weapons[part_id]
end

function WeaponFactoryManager:get_weapon_id_by_factory_id(factory_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_factory_id(factory_id)

	if not upgrade then
		Application:error("[WeaponFactoryManager:get_weapon_id_by_factory_id] Found no upgrade for factory id", factory_id)

		return
	end

	return upgrade.weapon_id
end

function WeaponFactoryManager:get_weapon_name_by_weapon_id(weapon_id)
	if not tweak_data.weapon[weapon_id] then
		return
	end

	return managers.localization:text(tweak_data.weapon[weapon_id].name_id)
end

function WeaponFactoryManager:get_weapon_name_by_factory_id(factory_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_factory_id(factory_id)

	if not upgrade then
		Application:error("[WeaponFactoryManager:get_weapon_name_by_factory_id] Found no upgrade for factory id", factory_id)

		return
	end

	local weapon_id = upgrade.weapon_id

	return managers.localization:text(tweak_data.weapon[weapon_id].name_id)
end

function WeaponFactoryManager:get_factory_id_by_weapon_id(weapon_id)
	local upgrade = managers.upgrades:weapon_upgrade_by_weapon_id(weapon_id)

	if not upgrade then
		Application:stack_dump("[WeaponFactoryManager:get_factory_id_by_weapon_id] Found no upgrade for factory id: '" .. tostring(weapon_id) .. "'!")

		return
	end

	return upgrade.factory_id
end

function WeaponFactoryManager:get_default_blueprint_by_factory_id(factory_id)
	return tweak_data.weapon.factory[factory_id] and tweak_data.weapon.factory[factory_id].default_blueprint or {}
end

function WeaponFactoryManager:preload_blueprint(factory_id, blueprint, third_person, done_cb, only_record)
	return self:_preload_blueprint(factory_id, blueprint, third_person, done_cb, only_record)
end

function WeaponFactoryManager:_preload_blueprint(factory_id, blueprint, third_person, done_cb, only_record)
	if not done_cb then
		Application:error("[WeaponFactoryManager] _preload_blueprint(): No done_cb!", "factory_id: " .. factory_id, "blueprint: " .. inspect(blueprint))
		Application:stack_dump()
	end

	local factory = tweak_data.weapon.factory
	local factory_weapon = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_preload_parts(factory_id, factory_weapon, blueprint, forbidden, third_person, done_cb, only_record)
end

function WeaponFactoryManager:_preload_parts(factory_id, factory_weapon, blueprint, forbidden, third_person, done_cb, only_record)
	local parts = {}
	local need_parent = {}
	local override = self:_get_override_parts(factory_id, blueprint)
	local async_task_data = nil

	if not only_record and self._uses_streaming then
		async_task_data = {
			spawn = false,
			third_person = third_person,
			parts = parts,
			done_cb = done_cb,
			blueprint = blueprint
		}
		self._async_load_tasks = self._async_load_tasks or {}
		self._async_load_tasks[async_task_data] = true
	end

	for _, part_id in ipairs(blueprint) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	end

	for _, part_id in ipairs(need_parent) do
		self:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	end

	if async_task_data then
		async_task_data.all_requests_sent = true

		self:clbk_part_unit_loaded(async_task_data, false, Idstring(), Idstring())
	else
		done_cb(parts, blueprint)
	end

	return parts, blueprint
end

function WeaponFactoryManager:get_assembled_blueprint(factory_id, blueprint)
	local assembled_blueprint = {}
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] then
			local part = self:_part_data(part_id, factory_id, override)
			local original_part = factory.parts[part_id] or part

			if factory[factory_id] and factory[factory_id].adds and factory[factory_id].adds[part_id] then
				local add_blueprint = self:get_assembled_blueprint(factory_id, factory[factory_id].adds[part_id]) or {}

				for i, d in ipairs(add_blueprint) do
					table.insert(assembled_blueprint, d)
				end
			end

			if part.adds_type then
				for _, add_type in ipairs(part.adds_type) do
					if factory[factory_id] then
						local add_id = factory[factory_id][add_type]

						table.insert(assembled_blueprint, add_id)
					end
				end
			end

			if part.adds then
				for _, add_id in ipairs(part.adds) do
					table.insert(assembled_blueprint, add_id)
				end
			end

			table.insert(assembled_blueprint, part_id)
		end
	end

	return assembled_blueprint
end

function WeaponFactoryManager:_preload_part(factory_id, part_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.weapon.factory
	local part = self:_part_data(part_id, factory_id, override)
	local original_part = factory.parts[part_id] or part

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_preload_part(factory_id, add_id, forbidden, override, parts, third_person, need_parent, done_cb, async_task_data, only_record)
		end
	end

	if parts[part_id] then
		return
	end

	if part.parent and not async_task_data and not self:get_part_from_weapon_by_type(part.parent, parts) then
		table.insert(need_parent, part_id)

		return
	end

	local unit_name = third_person and part.third_unit or part.unit
	local ids_unit_name = Idstring(unit_name)
	local original_unit_name = third_person and original_part.third_unit or original_part.unit
	local ids_orig_unit_name = Idstring(original_unit_name)
	local package = nil

	if not third_person and ids_unit_name == ids_orig_unit_name and not self._uses_streaming then
		package = "packages/fps_weapon_parts/" .. part_id

		if DB:has(Idstring("package"), Idstring(package)) then
			parts[part_id] = {
				package = package
			}

			self:load_package(parts[part_id].package)
		else
			Application:debug("[WeaponFactoryManager] Expected weapon part packages for", part_id)

			package = nil
		end
	end

	if not package then
		parts[part_id] = {
			name = ids_unit_name,
			is_streaming = async_task_data and true or nil
		}

		if not only_record then
			if async_task_data then
				managers.dyn_resource:load(IDS_UNIT, ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_part_unit_loaded", async_task_data))
			else
				managers.dyn_resource:load(unpack(parts[part_id]))
			end
		end
	end
end

function WeaponFactoryManager:assemble_default(factory_id, p_unit, third_person, done_cb, skip_queue)
	local blueprint = clone(tweak_data.weapon.factory[factory_id].default_blueprint)

	return self:_assemble(factory_id, p_unit, blueprint, third_person, done_cb, skip_queue), blueprint
end

function WeaponFactoryManager:assemble_from_blueprint(factory_id, p_unit, blueprint, third_person, done_cb, skip_queue)
	return self:_assemble(factory_id, p_unit, blueprint, third_person, done_cb, skip_queue)
end

function WeaponFactoryManager:modify_skin_blueprint(factory_id, blueprint, skin_id)
	local modified_blueprint = {}
	local _, skin_data = nil

	if skin_id then
		skin_data = tweak_data.weapon.weapon_skins[skin_id]
	else
		_, skin_data = managers.weapon_inventory:get_applied_weapon_skin(factory_id)
	end

	for _, v in ipairs(blueprint) do
		local replacement = skin_data and skin_data.replaces_parts and skin_data.replaces_parts[v]

		table.insert(modified_blueprint, replacement or v)
	end

	return modified_blueprint
end

function WeaponFactoryManager:_assemble(factory_id, p_unit, blueprint, third_person, done_cb, skip_queue)
	if not done_cb then
		Application:error("[WeaponFactoryManager] _assemble Error stack dump below...!")
		Application:stack_dump()
	end

	local factory = tweak_data.weapon.factory
	local factory_weapon = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	return self:_add_parts(p_unit, factory_id, factory_weapon, blueprint, forbidden, third_person, done_cb, skip_queue)
end

function WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override)

		if part then
			if part.depends_on then
				local part_forbidden = true

				for _, other_part_id in ipairs(blueprint) do
					local other_part = self:_part_data(other_part_id, factory_id, override)

					if part.depends_on == other_part.type then
						part_forbidden = false

						break
					end
				end

				if part_forbidden then
					forbidden[part_id] = part.depends_on
				end
			end

			if part.forbids then
				for _, forbidden_id in ipairs(part.forbids) do
					forbidden[forbidden_id] = part_id
				end
			end

			if part.adds then
				local add_forbidden = self:_get_forbidden_parts(factory_id, part.adds)

				for forbidden_id, part_id in pairs(add_forbidden) do
					forbidden[forbidden_id] = part_id
				end
			end
		end
	end

	return forbidden
end

function WeaponFactoryManager:_get_override_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local overridden = {}
	local override_override = {}

	if not blueprint then
		return overridden
	end

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				if override_data.override then
					override_override[override_id] = override_data
				end
			end
		end
	end

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override_override)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				overridden[override_id] = override_data
			end
		end
	end

	return overridden
end

function WeaponFactoryManager:_update_task(task)
	if not alive(task.p_unit) then
		return true
	end

	if task.blueprint_i <= #task.blueprint then
		local part_id = task.blueprint[task.blueprint_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.third_person, task.need_parent)

		task.blueprint_i = task.blueprint_i + 1

		return
	end

	if task.need_parent_i <= #task.need_parent then
		local part_id = task.need_parent[task.need_parent_i]

		self:_add_part(task.p_unit, task.factory_id, part_id, task.forbidden, task.override, task.parts, task.third_person, task.need_parent)

		task.need_parent_i = task.need_parent_i + 1

		return
	end

	task.done_cb(task.parts, task.blueprint)

	return true
end

function WeaponFactoryManager:_add_parts(p_unit, factory_id, factory_weapon, blueprint, forbidden, third_person, done_cb, skip_queue)
	self._tasks = self._tasks or {}
	local parts = {}
	local need_parent = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	if self._uses_tasks and not skip_queue then
		table.insert(self._tasks, {
			need_parent_i = 1,
			blueprint_i = 1,
			done_cb = done_cb,
			p_unit = p_unit,
			factory_id = factory_id,
			blueprint = blueprint,
			forbidden = forbidden,
			third_person = third_person,
			parts = parts,
			need_parent = need_parent,
			override = override
		})
	else
		local async_task_data = nil

		if self._uses_streaming then
			async_task_data = {
				spawn = true,
				third_person = third_person,
				parts = parts,
				done_cb = done_cb,
				blueprint = blueprint
			}
			self._async_load_tasks = self._async_load_tasks or {}
			self._async_load_tasks[async_task_data] = true
		end

		for _, part_id in ipairs(blueprint) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end

		for _, part_id in ipairs(need_parent) do
			self:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end

		if async_task_data then
			async_task_data.all_requests_sent = true

			self:clbk_part_unit_loaded(async_task_data, false, Idstring(), Idstring())
		else
			done_cb(parts, blueprint)
		end
	end

	return parts, blueprint
end

function WeaponFactoryManager:_part_data(part_id, factory_id, override)
	local factory = tweak_data.weapon.factory

	if not factory.parts[part_id] then
		Application:error("[WeaponFactoryManager] _part_data Part do not exist!", part_id, "factory_id", factory_id)

		return
	end

	local part = deep_clone(factory.parts[part_id])

	if factory[factory_id] and factory[factory_id].override and factory[factory_id].override[part_id] then
		for d, v in pairs(factory[factory_id].override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	if override and override[part_id] then
		for d, v in pairs(override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	return part
end

function WeaponFactoryManager:_add_part(p_unit, factory_id, part_id, forbidden, override, parts, third_person, need_parent, async_task_data)
	if forbidden[part_id] then
		return
	end

	local factory = tweak_data.weapon.factory
	local part = self:_part_data(part_id, factory_id, override)

	if not part then
		return
	end

	if factory[factory_id].adds and factory[factory_id].adds[part_id] then
		for _, add_id in ipairs(factory[factory_id].adds[part_id]) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end
	end

	if part.adds_type then
		for _, add_type in ipairs(part.adds_type) do
			local add_id = factory[factory_id][add_type]

			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end
	end

	if part.adds then
		for _, add_id in ipairs(part.adds) do
			self:_add_part(p_unit, factory_id, add_id, forbidden, override, parts, third_person, need_parent, async_task_data)
		end
	end

	if parts[part_id] then
		return
	end

	local link_to_unit = p_unit

	if async_task_data then
		if part.parent then
			link_to_unit = nil
		end
	elseif part.parent then
		local parent_part = self:get_part_from_weapon_by_type(part.parent, parts)

		if parent_part then
			link_to_unit = parent_part.unit
		else
			table.insert(need_parent, part_id)

			return
		end
	end

	local unit_name = third_person and part.third_unit or part.unit
	local ids_unit_name = Idstring(unit_name)
	local dyn_package = nil

	if not third_person and not async_task_data then
		local tweak_unit_name = tweak_data:get_raw_value("weapon", "factory", "parts", part_id, "unit")
		local ids_tweak_unit_name = tweak_unit_name and Idstring(tweak_unit_name)

		if ids_tweak_unit_name and ids_tweak_unit_name == ids_unit_name then
			dyn_package = "packages/fps_weapon_parts/" .. part_id

			if DB:has(Idstring("package"), Idstring(dyn_package)) then
				Application:debug("[WeaponFactoryManager] Has part as dynamic package:", dyn_package)
				self:load_package(dyn_package)
			else
				Application:debug("[WeaponFactoryManager] Expected weapon part packages for", part_id)

				dyn_package = nil
			end
		end
	end

	if async_task_data then
		parts[part_id] = {
			is_streaming = true,
			animations = part.animations,
			name = ids_unit_name,
			link_to_unit = link_to_unit,
			a_obj = Idstring(part.a_obj),
			parent = part.parent
		}

		managers.dyn_resource:load(IDS_UNIT, ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "clbk_part_unit_loaded", async_task_data))
	else
		if not dyn_package then
			managers.dyn_resource:load(IDS_UNIT, ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end

		local unit = self:_spawn_and_link_unit(ids_unit_name, Idstring(part.a_obj), third_person, link_to_unit)
		parts[part_id] = {
			unit = unit,
			animations = part.animations,
			name = ids_unit_name,
			package = dyn_package
		}
	end
end

function WeaponFactoryManager:clbk_part_unit_loaded(task_data, status, u_type, u_name)
	if not self._async_load_tasks[task_data] then
		return
	end

	if task_data.spawn then
		local function _spawn(part)
			local unit = self:_spawn_and_link_unit(part.name, part.a_obj, task_data.third_person, part.link_to_unit)

			if alive(unit) then
				unit:set_enabled(false)

				part.unit = unit
				part.a_obj = nil
				part.link_to_unit = nil
			end
		end

		for part_id, part in pairs(task_data.parts) do
			if part.name == u_name and part.is_streaming then
				part.is_streaming = nil

				if part.link_to_unit then
					_spawn(part)
				else
					local parent_part = self:get_part_from_weapon_by_type(part.parent, task_data.parts)

					if parent_part and parent_part.unit then
						part.link_to_unit = parent_part.unit

						_spawn(part)
					end
				end
			end
		end

		repeat
			local re_iterate = nil

			for part_id, part in pairs(task_data.parts) do
				if not part.unit and not part.is_streaming then
					local parent_part = self:get_part_from_weapon_by_type(part.parent, task_data.parts)

					if parent_part and parent_part.unit then
						part.link_to_unit = parent_part.unit

						_spawn(part)

						re_iterate = true
					end
				end
			end
		until not re_iterate
	else
		for part_id, part in pairs(task_data.parts) do
			if part.name == u_name and part.is_streaming then
				part.is_streaming = nil
			end
		end
	end

	if not task_data.all_requests_sent then
		return
	end

	for part_id, part in pairs(task_data.parts) do
		if part.is_streaming or task_data.spawn and not part.unit then
			return
		end
	end

	for part_id, part in pairs(task_data.parts) do
		if alive(part.unit) then
			part.unit:set_enabled(true)
		end
	end

	self._async_load_tasks[task_data] = nil

	if not task_data.done_cb then
		return
	end

	task_data.done_cb(task_data.parts, task_data.blueprint)
end

function WeaponFactoryManager:_spawn_and_link_unit(u_name, a_obj, third_person, link_to_unit)
	if alive(link_to_unit) then
		local unit = World:spawn_unit(u_name, Vector3(), Rotation())
		local res = link_to_unit:link(a_obj, unit, unit:orientation_object():name())

		if managers.occlusion and not third_person then
			managers.occlusion:remove_occlusion(unit)
		end

		return unit
	else
		Application:error("[WeaponFactoryManager] _spawn_and_link_unit LINK TO UNIT WAS NOT ALIVE", u_name, a_obj, third_person, link_to_unit)
	end
end

function WeaponFactoryManager:load_package(package)
	Application:debug("[WeaponFactoryManager:load_package] Try loading", package)

	if not self._loaded_packages[package] then
		Application:debug("[WeaponFactoryManager:load_package] Load for real", package)
		PackageManager:load(package)

		self._loaded_packages[package] = 1
	else
		self._loaded_packages[package] = self._loaded_packages[package] + 1
	end
end

function WeaponFactoryManager:unload_package(package)
	Application:debug("[WeaponFactoryManager:unload_package] Try loading", package)

	if not self._loaded_packages[package] then
		Application:error("[WeaponFactoryManager] Trying to unload package that wasn't loaded")

		return
	end

	self._loaded_packages[package] = self._loaded_packages[package] - 1

	if self._loaded_packages[package] <= 0 then
		Application:debug("[WeaponFactoryManager:unload_package] Unload for real", package)
		PackageManager:unload(package)

		self._loaded_packages[package] = nil
	end
end

function WeaponFactoryManager:get_parts_from_weapon_by_type_or_perk(type_or_perk, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local type_parts = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.type == type_or_perk or part.perks and table.contains(part.perks, type_or_perk) then
			table.insert(type_parts, id)
		end
	end

	return type_parts
end

function WeaponFactoryManager:get_parts_from_weapon_by_perk(perk, parts)
	local factory = tweak_data.weapon.factory
	local type_parts = {}

	for id, data in pairs(parts) do
		local perks = factory.parts[id].perks

		if perks and table.contains(perks, perk) then
			table.insert(type_parts, parts[id])
		end
	end

	return type_parts
end

function WeaponFactoryManager:get_custom_stats_from_part_id(part_id)
	local factory = tweak_data.weapon.factory.parts

	return factory[part_id] and factory[part_id].custom_stats or false
end

function WeaponFactoryManager:get_custom_stats_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		local part = self:_part_data(id, factory_id)

		if part.custom_stats then
			t[id] = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_ammo_data_from_weapon(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local t = {}

	for _, id in ipairs(self:get_assembled_blueprint(factory_id, blueprint)) do
		if factory.parts[id].type == "ammo" then
			local part = self:_part_data(id, factory_id)
			t = part.custom_stats
		end
	end

	return t
end

function WeaponFactoryManager:get_part_id_from_weapon_by_type(type, blueprint)
	local factory = tweak_data.weapon.factory

	for _, part_id in pairs(blueprint) do
		if factory.parts[part_id].type == type then
			return part_id
		end
	end

	return false
end

function WeaponFactoryManager:get_part_from_weapon_by_type(type, parts)
	local factory = tweak_data.weapon.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return parts[id]
		end
	end

	return false
end

function WeaponFactoryManager:get_part_data_type_from_weapon_by_type(type, data_type, parts)
	local factory = tweak_data.weapon.factory

	for id, data in pairs(parts) do
		if factory.parts[id].type == type then
			return factory.parts[id][data_type]
		end
	end

	return false
end

function WeaponFactoryManager:is_weapon_unmodded(factory_id, blueprint)
	local weapon_tweak = tweak_data.weapon.factory[factory_id]
	local blueprint_map = {}

	for _, part in ipairs(blueprint) do
		blueprint_map[part] = true
	end

	for _, part in ipairs(weapon_tweak.default_blueprint) do
		if not blueprint_map[part] then
			return false
		end

		blueprint_map[part] = nil
	end

	return table.size(blueprint_map) == 0
end

function WeaponFactoryManager:has_weapon_more_than_default_parts(factory_id)
	local weapon_tweak = tweak_data.weapon.factory[factory_id]

	return #weapon_tweak.uses_parts > #weapon_tweak.default_blueprint
end

function WeaponFactoryManager:get_parts_from_factory_id(factory_id)
	return self._parts_by_weapon[factory_id]
end

function WeaponFactoryManager:get_parts_from_weapon_id(weapon_id)
	local factory_id = self:get_factory_id_by_weapon_id(weapon_id)

	return self._parts_by_weapon[factory_id]
end

function WeaponFactoryManager:is_part_standard_issue(factory_id, part_id)
	local weapon_factory_tweak_data = tweak_data.weapon.factory[factory_id]
	local part_tweak_data = tweak_data.weapon.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[WeaponFactoryManager:is_part_standard_issue] Found no part with part id", part_id)

		return false
	end

	if not weapon_factory_tweak_data then
		Application:error("[WeaponFactoryManager:is_part_standard_issue] Found no weapon with factory id", factory_id)

		return false
	end

	return table.contains(weapon_factory_tweak_data.default_blueprint or {}, part_id)
end

function WeaponFactoryManager:get_part_data_by_part_id_from_weapon(part_id, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local override = self:_get_override_parts(factory_id, blueprint)

	return self:_part_data(part_id, factory_id, override)
end

function WeaponFactoryManager:get_part_name_by_part_id(part_id)
	local part_tweak_data = tweak_data.weapon.factory.parts[part_id]

	if not part_tweak_data then
		Application:error("[WeaponFactoryManager:get_part_name_by_part_id] Found no part with part id", part_id)

		return
	end

	return managers.localization:text(part_tweak_data.name_id)
end

function WeaponFactoryManager:change_part(p_unit, factory_id, part_id, parts, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:change_part Part", part_id, "doesn't exist!")

		return parts
	end

	local type = part.type

	if self._parts_by_weapon[factory_id][type] then
		if table.contains(self._parts_by_weapon[factory_id][type], part_id) then
			for rem_id, rem_data in pairs(parts) do
				if factory.parts[rem_id].type == type then
					table.delete(blueprint, rem_id)

					break
				end
			end

			table.insert(blueprint, part_id)
			self:disassemble(parts)

			return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
		else
			Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
		end
	else
		Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
	end

	return parts
end

function WeaponFactoryManager:remove_part_from_blueprint(part_id, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:remove_part_from_blueprint Part", part_id, "doesn't exist!")

		return
	end

	table.delete(blueprint, part_id)
end

function WeaponFactoryManager:change_part_blueprint_only(factory_id, part_id, blueprint, remove_part)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:change_part Part", part_id, " doesn't exist!")

		return false
	end

	local type = part.type

	if remove_part then
		table.delete(blueprint, part_id)

		local forbidden = WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

		for _, rem_id in ipairs(blueprint) do
			if forbidden[rem_id] then
				table.delete(blueprint, rem_id)
			end
		end
	elseif self._parts_by_weapon[factory_id][type] then
		if table.contains(self._parts_by_weapon[factory_id][type], part_id) then
			for _, rem_id in ipairs(blueprint) do
				if factory.parts[rem_id].type == type then
					table.delete(blueprint, rem_id)

					break
				end
			end

			table.insert(blueprint, part_id)

			local forbidden = WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint) or {}

			for _, rem_id in ipairs(blueprint) do
				if forbidden[rem_id] then
					table.delete(blueprint, rem_id)
				end
			end

			return true
		else
			Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
		end
	else
		Application:error("WeaponFactoryManager:change_part Part", part_id, "not allowed for weapon", factory_id, "!")
	end

	return false
end

function WeaponFactoryManager:remove_part(p_unit, factory_id, part_id, parts, blueprint)
	local factory = tweak_data.weapon.factory
	local part = factory.parts[part_id]

	if not part then
		Application:error("WeaponFactoryManager:remove_part Part", part_id, "doesn't exist!")

		return parts
	end

	table.delete(blueprint, part_id)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:remove_part_by_type(p_unit, factory_id, type, parts, blueprint)
	local factory = tweak_data.weapon.factory

	for part_id, part_data in pairs(parts) do
		if factory.parts[part_id].type == type then
			table.delete(blueprint, part_id)

			break
		end
	end

	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:change_blueprint(p_unit, factory_id, parts, blueprint)
	self:disassemble(parts)

	return self:assemble_from_blueprint(factory_id, p_unit, blueprint)
end

function WeaponFactoryManager:blueprint_to_string(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local index_table = {}

	for i, part_id in ipairs(factory[factory_id] and factory[factory_id].uses_parts or {}) do
		index_table[part_id] = i
	end

	local s = ""

	for _, part_id in ipairs(blueprint) do
		if index_table[part_id] then
			s = s .. tostring(index_table[part_id]) .. " "
		else
			Application:error("[WeaponFactoryManager:blueprint_to_string] Part do not exist in weapon's uses_parts!", "factory_id", factory_id, "part_id", part_id)
		end
	end

	return s
end

function WeaponFactoryManager:unpack_blueprint_from_string(factory_id, blueprint_string)
	local factory = tweak_data.weapon.factory
	local index_table = string.split(blueprint_string, " ")
	local blueprint = {}
	local part_id = nil

	for _, part_index in ipairs(index_table) do
		part_id = factory[factory_id].uses_parts[tonumber(part_index)]

		if part_id then
			table.insert(blueprint, part_id)
		end
	end

	return blueprint
end

function WeaponFactoryManager:get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id] and factory.parts[part_id].stats then
			local part = self:_part_data(part_id, factory_id)

			for stat_type, value in pairs(part.stats) do
				stats[stat_type] = stats[stat_type] or 0
				stats[stat_type] = stats[stat_type] + value
			end
		end
	end

	return stats
end

function WeaponFactoryManager:get_stance_mod(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local assembled_blueprint = self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, assembled_blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	local translation = Vector3()
	local rotation = Rotation()
	local lens_distortion = managers.environment_controller:get_lens_distortion_value()
	local part = nil

	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			part = self:_part_data(part_id, factory_id, override)

			if part.stance_mod and part.stance_mod[factory_id] then
				local part_translation = part.stance_mod[factory_id].translation

				if part_translation then
					mvector3.add(translation, part_translation)
				end

				local part_rotation = part.stance_mod[factory_id].rotation

				if part_rotation then
					mrotation.multiply(rotation, part_rotation)
				end

				local part_lens_distortion = part.stance_mod[factory_id].lens_distortion_power

				if part_lens_distortion then
					lens_distortion = part_lens_distortion
				end
			end
		end
	end

	return {
		translation = translation,
		rotation = rotation,
		lens_distortion = lens_distortion
	}
end

function WeaponFactoryManager:has_perk(perk_name, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].perks then
			for _, perk in ipairs(factory.parts[part_id].perks) do
				if perk == perk_name then
					return true
				end
			end
		end
	end

	return false
end

function WeaponFactoryManager:get_perks_from_part_id(part_id)
	local factory = tweak_data.weapon.factory

	if not factory.parts[part_id] then
		return {}
	end

	local perks = {}

	if factory.parts[part_id].perks then
		for _, perk in ipairs(factory.parts[part_id].perks) do
			perks[perk] = true
		end
	end

	return perks
end

function WeaponFactoryManager:get_perks(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local perks = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].perks then
			for _, perk in ipairs(factory.parts[part_id].perks) do
				perks[perk] = true
			end
		end
	end

	return perks
end

function WeaponFactoryManager:get_sound_switch(switch_group, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local t = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].sound_switch and factory.parts[part_id].sound_switch[switch_group] then
			table.insert(t, part_id)
		end
	end

	if #t > 0 then
		if #t > 1 then
			local part_x, part_y = nil

			table.sort(t, function (x, y)
				part_x = factory.parts[x]
				part_y = factory.parts[y]

				if part_x.sub_type == "silencer" then
					return true
				end

				if part_y.sub_type == "silencer" then
					return false
				end

				return x < y
			end)
		end

		return factory.parts[t[1]].sound_switch[switch_group]
	end

	return nil
end

function WeaponFactoryManager:disassemble(parts)
	for task_data, _ in pairs(self._async_load_tasks) do
		if task_data.parts == parts then
			self._async_load_tasks[task_data] = nil

			break
		end
	end

	local names = {}

	if parts then
		for part_id, data in pairs(parts) do
			if data.package then
				self:unload_package(data.package)
			else
				table.insert(names, data.name)
			end

			if alive(data.unit) then
				World:delete_unit(data.unit)
			end
		end
	end

	for _, name in pairs(names) do
		managers.dyn_resource:unload(IDS_UNIT, name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	parts = {}
end

function WeaponFactoryManager:save(data)
	data.weapon_factory = self._global
end

function WeaponFactoryManager:load(data)
	self._global = data.weapon_factory
end

function WeaponFactoryManager:debug_get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] then
			stats[part_id] = factory.parts[part_id].stats
		end
	end

	return stats
end
