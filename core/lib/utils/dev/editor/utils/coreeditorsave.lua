core:module("CoreEditorSave")
core:import("CoreEditorUtils")
core:import("CoreCode")
core:import("CoreClass")
core:import("CoreXml")
core:import("CoreDebug")

function save_data_table(unit)
	local ud = unit:unit_data()
	local t = {
		name = unit:name():s(),
		unit_id = ud.unit_id,
		name_id = ud.name_id,
		continent = unit:unit_data().continent and unit:unit_data().continent:name(),
		position = unit:position(),
		rotation = unit:rotation(),
		mesh_variation = ud.mesh_variation,
		material_variation = ud.material,
		cutscene_actor = ud.cutscene_actor,
		disable_shadows = ud.disable_shadows,
		hide_on_projection_light = ud.hide_on_projection_light,
		disable_on_ai_graph = ud.disable_on_ai_graph,
		lights = _light_data_table(unit),
		triggers = _triggers_data_table(unit),
		projection_light = CoreEditorUtils.has_any_projection_light(unit),
		projection_lights = ud.projection_lights,
		projection_textures = ud.projection_textures
	}

	for _, extension in pairs(unit:extensions_infos()) do
		if extension.editor_save then
			extension:editor_save(t)
		end
	end

	return t
end

function _light_data_table(unit)
	local lights = CoreEditorUtils.get_editable_lights(unit)

	if not lights then
		return nil
	end

	local t = {}

	for _, light in ipairs(lights) do
		local data = {
			name = light:name():s(),
			enabled = light:enable(),
			far_range = light:far_range(),
			near_range = light:near_range(),
			color = light:color(),
			spot_angle_start = light:spot_angle_start(),
			spot_angle_end = light:spot_angle_end(),
			multiplier = CoreEditorUtils.get_intensity_preset(light:multiplier()):s(),
			falloff_exponent = light:falloff_exponent(),
			linear_attenuation_factor = light:linear_attenuation_factor(),
			clipping_values = light:clipping_values()
		}

		table.insert(t, data)
	end

	return #t > 0 and t or nil
end

function _triggers_data_table(unit)
	local triggers = managers.sequence:get_trigger_list(unit:name())

	if #triggers == 0 then
		return nil
	end

	local t = {}

	if #triggers > 0 and unit:damage() then
		local trigger_name_list = unit:damage():get_trigger_name_list()

		if trigger_name_list then
			for _, trigger_name in ipairs(trigger_name_list) do
				local trigger_data = unit:damage():get_trigger_data_list(trigger_name)

				if trigger_data and #trigger_data > 0 then
					for _, data in ipairs(trigger_data) do
						table.insert(t, {
							name = data.trigger_name,
							id = data.id,
							notify_unit_id = data.notify_unit:unit_data().unit_id,
							time = data.time,
							notify_unit_sequence = data.notify_unit_sequence
						})
					end
				end
			end
		end
	end

	return #t > 0 and t or nil
end

function save_layout(params)
	local dialogs = {}

	if params.save_dialog_states then
		for name, dialog in pairs(params.dialogs) do
			dialogs[name] = {
				class = CoreDebug.class_name(getmetatable(dialog)),
				position = dialog:position(),
				size = dialog:size(),
				visible = dialog:visible()
			}
		end

		for name, setting in pairs(params.dialogs_settings) do
			if not params.dialogs[name] then
				dialogs[name] = {
					class = setting.class,
					position = setting.position,
					size = setting.size,
					visible = setting.visible
				}
			end
		end
	end

	local data = {
		is_maximized = Global.frame:is_maximized(),
		is_iconized = Global.frame:is_iconized(),
		size = Global.frame:get_size(),
		position = Global.frame:get_position(),
		dialogs = dialogs
	}
	local f = SystemFS:open(params.file, "w")

	f:puts(ScriptSerializer:to_generic_xml(data))
	f:close()
end

function load_layout(params)
	local data = ScriptSerializer:from_generic_xml(params.file:read())

	for name, settings in pairs(data.dialogs) do
		params.dialogs_settings[name] = settings

		if settings.visible then
			managers.editor:show_dialog(name, settings.class)
		end
	end

	if not data.is_maximized and not data.is_iconized then
		Global.frame:maximize(data.is_maximized)
		Global.frame:set_size(data.size)
		Global.frame:set_position(data.position)
	elseif data.is_iconized then
		Global.frame:iconize(data.is_iconized)
	end
end
