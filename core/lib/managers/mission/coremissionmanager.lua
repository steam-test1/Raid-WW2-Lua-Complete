core:module("CoreMissionManager")
core:import("CoreMissionScriptElement")
core:import("CoreEvent")
core:import("CoreClass")
core:import("CoreDebug")
core:import("CoreCode")
core:import("CoreTable")
require("core/lib/managers/mission/CoreElementDebug")

MissionManager = MissionManager or CoreClass.class(CoreEvent.CallbackHandler)

function MissionManager:init()
	MissionManager.super.init(self)

	self._runned_unit_sequences_callbacks = {}
	self._scripts = {}
	self._active_scripts = {}
	self._area_instigator_categories = {}

	self:add_area_instigator_categories("none")
	self:set_default_area_instigator("none")
end

function MissionManager:post_init()
	managers.viewport:add_resolution_changed_func(callback(self, self, "_resolution_changed"))
end

function MissionManager:_resolution_changed()
	managers.gui_data:layout_corner_saferect_workspace(self._workspace)
end

function MissionManager:parse(params, stage_name, offset, file_type)
	local file_path, activate_mission = nil

	if CoreClass.type_name(params) == "table" then
		file_path = params.file_path
		file_type = params.file_type or "mission"
		activate_mission = params.activate_mission
		offset = params.offset
		self._worlddefinition = params.worlddefinition
		self._sync_id = params.sync_id
	else
		file_path = params
		file_type = file_type or "mission"
	end

	CoreDebug.cat_debug("gaspode", "MissionManager", file_path, file_type, activate_mission)

	if not DB:has(file_type, file_path) then
		Application:error("Couldn't find", file_path, "(", file_type, ")")

		return false
	end

	local reverse = string.reverse(file_path)
	local i = string.find(reverse, "/")
	local file_dir = string.reverse(string.sub(reverse, i))
	local continent_files = self:_serialize_to_script(file_type, file_path)
	continent_files._meta = nil

	for name, data in pairs(continent_files) do
		if not (self._worlddefinition or managers.worlddefinition):continent_excluded(name) then
			self:_load_mission_file(file_dir, data)
		end
	end

	self:_activate_mission(activate_mission)

	self._parsed = true

	return true
end

function MissionManager:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name:id())
	else
		if not PackageManager:has(type:id(), name:id()) then
			Application:throw_exception("Script data file " .. name .. " of type " .. type .. " has not been loaded. Could be that old mission format is being loaded. Try resaving the level.")
		end

		return PackageManager:script_data(type:id(), name:id())
	end
end

function MissionManager:_load_mission_file(file_dir, data)
	local file_path = file_dir .. data.file
	local scripts = self:_serialize_to_script("mission", file_path)
	scripts._meta = nil

	for name, data in pairs(scripts) do
		data.name = name
		data.worlddefinition = self._worlddefinition
		data.sync_id = self._sync_id

		self:_add_script(data)
	end
end

function MissionManager:_add_script(data)
	self._scripts[data.name] = MissionScript:new(data)
end

function MissionManager:scripts()
	return self._scripts
end

function MissionManager:script(name)
	return self._scripts[name]
end

function MissionManager:_activate_mission(name)
	Application:debug("[MissionManager:_activate_mission]", name)

	if name then
		if self:script(name) then
			self:activate_script(name)
		else
			Application:throw_exception("There was no mission named " .. name .. " availible to activate!")
		end
	else
		for _, script in pairs(self._scripts) do
			if script:activate_on_parsed() then
				self:activate_script(script:name())
			end
		end
	end
end

function MissionManager:activate_script(name, ...)
	Application:debug("[MissionManager:activate_script] Simulating:", Global.running_simulation, "| Name:", name, inspect(self))

	if not self._scripts[name] then
		if Global.running_simulation then
			managers.editor:output_error("Can't activate mission script " .. name .. ". It doesn't exist.")

			return
		else
			Application:throw_exception("Can't activate mission script " .. name .. ". It doesn't exist.")
		end
	end

	Application:debug("[MissionManager:activate_script] Good to activate " .. name)
	self._scripts[name]:activate(...)
end

function MissionManager:find_alert_point(position)
	local distances = {}

	for name, script in pairs(self._scripts) do
		for _, alert_point in pairs(script._alert_points) do
			if alert_point:value("enabled") and not alert_point.executing then
				local distance = mvector3.distance(alert_point:value("position"), position)
				distances[distance] = alert_point
			end
		end
	end

	local min = -1

	for distance, alert_point in pairs(distances) do
		if min == -1 or distance < min then
			min = distance
		end
	end

	return distances[min]
end

function MissionManager:debug_enabled_alert_points()
	local distances = {}

	for name, script in pairs(self._scripts) do
		for _, alert_point in pairs(script._alert_points) do
			if alert_point:value("enabled") and not alert_point.executing then
				Application:debug("Enabled alert point at", alert_point:value("position"))
			end
		end
	end
end

function MissionManager:find_closest_metal_object_position(position)
	local distances = {}

	for name, script in pairs(self._scripts) do
		for _, object in pairs(script._metal_detector_objects) do
			if object:value("enabled") then
				local distance = mvector3.distance(object:value("position"), position)
				distances[distance] = object
			end
		end
	end

	local min = -1

	for distance, alert_point in pairs(distances) do
		if min == -1 or distance < min then
			min = distance
		end
	end

	return min
end

function MissionManager:update(t, dt)
	for _, script in pairs(self._scripts) do
		script:update(t, dt)
	end
end

function MissionManager:stop_simulation(...)
	self:pre_destroy()

	for _, script in pairs(self._scripts) do
		script:stop_simulation(...)
	end

	self._scripts = {}
	self._runned_unit_sequences_callbacks = {}
end

function MissionManager:on_simulation_started()
	self._pre_destroyed = nil
end

function MissionManager:add_runned_unit_sequence_trigger(id, sequence, callback)
	if self._runned_unit_sequences_callbacks[id] then
		if self._runned_unit_sequences_callbacks[id][sequence] then
			table.insert(self._runned_unit_sequences_callbacks[id][sequence], callback)
		else
			self._runned_unit_sequences_callbacks[id][sequence] = {
				callback
			}
		end
	else
		local t = {
			[sequence] = {
				callback
			}
		}
		self._runned_unit_sequences_callbacks[id] = t
	end
end

function MissionManager:runned_unit_sequence(unit, sequence, params)
	if self._pre_destroyed then
		return
	end

	if alive(unit) and unit:unit_data() then
		local id = unit:unit_data().unit_id
		id = id ~= 0 and id or unit:editor_id()

		if self._runned_unit_sequences_callbacks[id] and self._runned_unit_sequences_callbacks[id][sequence] then
			for _, call in ipairs(self._runned_unit_sequences_callbacks[id][sequence]) do
				call(params and params.unit)
			end
		end
	end
end

function MissionManager:add_area_instigator_categories(category)
	table.insert(self._area_instigator_categories, category)
end

function MissionManager:area_instigator_categories()
	return self._area_instigator_categories
end

function MissionManager:set_default_area_instigator(default)
	self._default_area_instigator = default
end

function MissionManager:default_area_instigator()
	return self._default_area_instigator
end

function MissionManager:default_instigator()
	return nil
end

function MissionManager:persistent_debug_enabled()
	return self._persistent_debug_enabled
end

function MissionManager:set_persistent_debug_enabled(enabled)
	self._persistent_debug_enabled = enabled

	if enabled then
		self._persistent_debug_output:show()
	else
		self._persistent_debug_output:hide()
	end
end

function MissionManager:add_persistent_debug_output(debug, color)
	if not self._persistent_debug_enabled then
		return
	end

	Application:debug("[MissionManager:add_persistent_debug_output]", debug)
	self._persistent_debug_output:script().log(debug, color)
end

function MissionManager:set_fading_debug_enabled(enabled)
	self._fading_debug_enabled = enabled

	if enabled then
		self._fading_debug_output:show()
	else
		self._fading_debug_output:hide()
	end
end

function MissionManager:add_fading_debug_output(debug, color, as_subtitle)
	if not Application:production_build() then
		return
	end

	if as_subtitle then
		self:_show_debug_subtitle(debug, color)
	else
		local stuff = {
			" -",
			" \\",
			" |",
			" /"
		}
		self._fade_index = (self._fade_index or 0) + 1
		self._fade_index = self._fade_index > #stuff and self._fade_index and 1 or self._fade_index

		self._fading_debug_output:script().log(stuff[self._fade_index] .. " " .. debug, color, nil)
	end
end

function MissionManager:_show_debug_subtitle(debug, color)
	self._debug_subtitle_text = self._debug_subtitle_text or self._workspace:panel():text({
		word_wrap = true,
		valign = "center",
		halign = "center",
		align = "center",
		wrap = true,
		name = "debug_fading_subtitle_text",
		font_size = 20,
		font = "core/fonts/diesel",
		text = nil,
		color = nil,
		text = debug,
		color = color or Color.white
	})

	self._debug_subtitle_text:set_w(self._workspace:panel():w() / 2)
	self._debug_subtitle_text:set_text(debug)

	local subtitle_time = math.max(4, utf8.len(debug) * 0.04)
	local _, _, w, h = self._debug_subtitle_text:text_rect()

	self._debug_subtitle_text:set_h(h)
	self._debug_subtitle_text:set_center_x(self._workspace:panel():w() / 2)
	self._debug_subtitle_text:set_top(self._workspace:panel():h() / 1.4)
	self._debug_subtitle_text:set_color(color or Color.white)
	self._debug_subtitle_text:set_alpha(1)
	self._debug_subtitle_text:stop()
	self._debug_subtitle_text:animate(function (o)
		_G.wait(subtitle_time)
		self._debug_subtitle_text:set_alpha(0)
	end)
end

function MissionManager:get_element_by_id(id)
	for name, script in pairs(self._scripts) do
		if script:element(id) then
			return script:element(id)
		end
	end
end

function MissionManager:get_element_by_name(name)
	for _, data in pairs(self._scripts) do
		for id, element in pairs(data:elements()) do
			if element:editor_name() == name then
				return element
			end
		end
	end
end

function MissionManager:save(data)
	local state = {}

	for _, script in pairs(self._scripts) do
		script:save(state)
	end

	data.MissionManager = state
end

function MissionManager:load(data)
	Application:debug("[MissionManager:load]", self._sync_id, inspect(data.MissionManager))

	local state = data.MissionManager

	if self._parsed then
		for _, script in pairs(self._scripts) do
			script:load(state)
		end
	else
		Application:debug("[MissionManager:load] dropin!")

		Global.mision_load_state_dropin = state
	end
end

function MissionManager:pre_destroy()
	self._pre_destroyed = true

	for _, script in pairs(self._scripts) do
		script:pre_destroy()
	end
end

function MissionManager:destroy()
	for _, script in pairs(self._scripts) do
		script:destroy()
	end
end

MissionScript = MissionScript or CoreClass.class(CoreEvent.CallbackHandler)
MissionScript.imported_modules = MissionScript.imported_modules or {}

for module_name, _ in pairs(MissionScript.imported_modules) do
	MissionScript.import(module_name)
end

function MissionScript.import(module_name)
	MissionScript.imported_modules[module_name] = true
	local module = core:import(module_name)

	return module
end

function MissionScript:init(data)
	MissionScript.super.init(self)

	self._metal_detector_objects = {}
	self._alert_points = {}
	self._elements = {}
	self._element_groups = {}
	self._name = data.name
	self._activate_on_parsed = data.activate_on_parsed
	self._worlddefinition = data.worlddefinition
	self._sync_id = data.sync_id
	self._worlddefinition_id = data.sync_id

	CoreDebug.cat_debug("gaspode", "New MissionScript:", self._name)
	self:_add_translation(data.elements)
	self:_create_elements(data.elements)

	if data.instances then
		for _, instance_name in ipairs(data.instances) do
			local instance_data = managers.world_instance:get_instance_data_by_name(instance_name, self._worlddefinition_id)
			local prepare_mission_data = managers.world_instance:prepare_mission_data_by_name(instance_name, self._worlddefinition_id)

			if not instance_data.mission_placed then
				self:create_instance_elements(prepare_mission_data)
			else
				self:_preload_instance_class_elements(prepare_mission_data)
			end
		end
	end

	self._updators = {}
	self._save_states = {}

	self:_on_created(self._elements)
end

function MissionScript:_add_translation(elements)
	if not self._worlddefinition or not self._worlddefinition:translation() then
		return
	end

	local position = self._worlddefinition:translation().position
	local rotation = self._worlddefinition:translation().rotation

	for _, element in ipairs(elements) do
		_G.CoreWorldInstanceManager.translate_element_values(element, position, rotation)
	end
end

function MissionScript:external_create_instance_elements(prepare_mission_data)
	local new_elements = self:create_instance_elements(prepare_mission_data)

	self:_on_created(new_elements)

	if self._active then
		self:_on_script_activated(new_elements)
	end
end

function MissionScript:create_instance_elements(prepare_mission_data)
	local new_elements = {}

	for _, instance_mission_data in pairs(prepare_mission_data) do
		new_elements = self:_create_elements(instance_mission_data.elements)
	end

	return new_elements
end

function MissionScript:_preload_instance_class_elements(prepare_mission_data)
	for _, instance_mission_data in pairs(prepare_mission_data) do
		for _, element in ipairs(instance_mission_data.elements) do
			self:_element_class(element.module, element.class)
		end
	end
end

function MissionScript:_create_elements(elements)
	local new_elements = {}

	for _, element in ipairs(elements) do
		local class = element.class
		local new_element = self:_element_class(element.module, class):new(self, element)
		local is_alert = new_element:value("is_alert_point")
		local is_metal_detector_object = new_element:value("is_metal_detector_object")
		local old_element = self._elements[element.id]

		if old_element and not Application:editor() then
			Application:debug("[MissionScript:_create_elements] Leaking mission element! old", inspect(old_element))
			Application:debug("[MissionScript:_create_elements] Leaking mission element! new", inspect(new_element))
			_G.debug_pause("[MissionScript:_create_elements] Leaking mission element! ID:", element.id)
		end

		self._elements[element.id] = new_element
		new_elements[element.id] = new_element
		self._element_groups[class] = self._element_groups[class] or {}

		table.insert(self._element_groups[class], new_element)

		if is_alert then
			self._alert_points[element.id] = new_element
		end

		if is_metal_detector_object then
			self._metal_detector_objects[element.id] = new_element
		end
	end

	return new_elements
end

function MissionScript:activate_on_parsed()
	return self._activate_on_parsed
end

function MissionScript:_on_created(elements)
	for _, element in pairs(elements) do
		element:on_created()
	end
end

function MissionScript:_element_class(module_name, class_name)
	local element_class = rawget(_G, class_name)

	if not element_class and module_name and module_name ~= "none" then
		local raw_module = rawget(_G, "CoreMissionManager")[module_name]
		element_class = raw_module and raw_module[class_name] or MissionScript.import(module_name)[class_name]
	end

	if not element_class then
		element_class = CoreMissionScriptElement.MissionScriptElement

		Application:error("[MissionScript]SCRIPT ERROR: Didn't find class", class_name, module_name)
	end

	return element_class
end

function MissionScript:activate(...)
	self._active = true

	managers.mission:add_persistent_debug_output("")
	managers.mission:add_persistent_debug_output("Activate mission " .. self._name, Color(1, 0, 1, 0))
	self:_on_script_activated(CoreTable.clone(self._elements), ...)
end

function MissionScript:_on_script_activated(elements, ...)
	for _, element in pairs(elements) do
		element:on_script_activated()
	end

	local startup_order = {}

	for _, element in pairs(elements) do
		if element:value("execute_on_startup") then
			table.insert(startup_order, element)
		end
	end

	local function sort_func(a, b)
		local av = a:value("execute_on_startup_priority")
		local bv = b:value("execute_on_startup_priority")

		if av and bv then
			return av < bv
		end

		if av then
			return true
		else
			return false
		end
	end

	table.sort(startup_order, sort_func)

	for _, element in ipairs(startup_order) do
		element:on_executed(...)
	end
end

function MissionScript:add_updator(id, updator)
	self._updators[id] = updator
end

function MissionScript:remove_updator(id)
	self._updators[id] = nil
end

function MissionScript:update(t, dt)
	MissionScript.super.update(self, dt)

	for _, updator in pairs(self._updators) do
		updator(t, dt)
	end
end

function MissionScript:_debug_draw(t, dt)
	local brush = Draw:brush(Color.red)
	local name_brush = Draw:brush(Color.red)

	name_brush:set_font(Idstring("fonts/font_medium"), 16)
	name_brush:set_render_template(Idstring("OverlayVertexColorTextured"))

	for _, element in pairs(self._elements) do
		brush:set_color(element:enabled() and Color.green or Color.red)
		name_brush:set_color(element:enabled() and Color.green or Color.red)

		if element:value("position") then
			brush:sphere(element:value("position"), 5)

			if managers.viewport:get_current_camera() then
				local cam_up = managers.viewport:get_current_camera():rotation():z()
				local cam_right = managers.viewport:get_current_camera():rotation():x()

				name_brush:center_text(element:value("position") + Vector3(0, 0, 30), utf8.from_latin1(element:editor_name()), cam_right, -cam_up)
			end
		end

		if element:value("rotation") then
			local rotation = CoreClass.type_name(element:value("rotation")) == "Rotation" and element:value("rotation") or Rotation(element:value("rotation"), 0, 0)

			brush:cylinder(element:value("position"), element:value("position") + rotation:y() * 50, 2)
			brush:cylinder(element:value("position"), element:value("position") + rotation:z() * 25, 1)
		end

		element:debug_draw(t, dt)
	end
end

function MissionScript:name()
	return self._name
end

function MissionScript:element_groups()
	return self._element_groups
end

function MissionScript:element_group(name)
	return self._element_groups[name]
end

function MissionScript:elements()
	return self._elements
end

function MissionScript:element(id)
	return self._elements[id]
end

function MissionScript:debug_output(debug, color)
	managers.mission:add_persistent_debug_output(Application:date("%X") .. ": " .. debug, color)
	CoreDebug.cat_print("editor", debug)
end

function MissionScript:worlddefinition()
	return self._worlddefinition or managers.worlddefinition
end

function MissionScript:sync_id()
	return self._sync_id or 0
end

function MissionScript:is_debug()
	return true
end

function MissionScript:add_save_state_cb(id)
	self._save_states[id] = true
end

function MissionScript:remove_save_state_cb(id)
	self._save_states[id] = nil
end

function MissionScript:save(data)
	local state = {}

	for id, _ in pairs(self._save_states) do
		state[id] = {}

		self._elements[id]:save(state[id])
	end

	data[self._name] = state
end

function MissionScript:load(data)
	local state = data[self._name]

	if not state then
		Application:debug("[MissionScript:load] Nothing to load!", self._name, inspect(data), debug.traceback())

		return
	end

	if self._element_groups.ElementInstancePoint then
		for _, element in ipairs(self._element_groups.ElementInstancePoint) do
			if state[element:id()] then
				self._elements[element:id()]:load(state[element:id()])

				state[element:id()] = nil
			end
		end
	end

	for id, mission_state in pairs(state) do
		if self._elements[id] and self._elements[id].load then
			self._elements[id]:load(mission_state)
		else
			_G.debug_pause("Mission element without load method?", id, inspect(mission_state))
		end
	end
end

function MissionScript:stop_simulation(...)
	for _, element in pairs(self._elements) do
		element:stop_simulation(...)
	end

	MissionScript.super.clear(self)
end

function MissionScript:pre_destroy(...)
	for _, element in pairs(self._elements) do
		element:pre_destroy(...)
	end

	MissionScript.super.clear(self)
end

function MissionScript:destroy(...)
	for _, element in pairs(self._elements) do
		element:destroy(...)
	end

	MissionScript.super.clear(self)
end
