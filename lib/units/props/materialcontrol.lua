MaterialControl = MaterialControl or class()

function MaterialControl:init(unit)
	self._unit = unit
end

function MaterialControl:save(save_data)
	local data = {}
	local materials = self._unit:get_objects_by_type(Idstring("material"))

	for idx, material in ipairs(materials) do
		local material_data = {}

		material_data.time = material:time()
		material_data.is_playing = material:is_playing()
		material_data.playing_speed = material:playing_speed()
		data[idx] = material_data
	end

	save_data.material_control = data
end

function MaterialControl:load(load_data)
	local data = load_data.material_control

	if not data then
		return
	end

	local materials = self._unit:get_objects_by_type(Idstring("material"))

	for idx, material in ipairs(materials) do
		local material_data = data[idx]

		if material_data then
			if material_data.is_playing then
				material:play(material_data.playing_speed)
				material:set_time(material_data.time)
			else
				material:stop()
				material:set_time(material_data.time)
			end
		end
	end
end

function MaterialControl:play(material_name, speed)
	local materials = self._unit:get_objects_by_type(Idstring("material"))
	local material_id = Idstring(material_name)

	for i, material in ipairs(materials) do
		if material:name() == material_id then
			material:play(speed)
		end
	end
end

function MaterialControl:stop(material_name)
	local materials = self._unit:get_objects_by_type(Idstring("material"))
	local material_id = Idstring(material_name)

	for _, material in ipairs(materials) do
		if material:name() == material_id then
			material:stop()
		end
	end
end

function MaterialControl:pause(material_name)
	local materials = self._unit:get_objects_by_type(Idstring("material"))
	local material_id = Idstring(material_name)

	for _, material in ipairs(materials) do
		if material:name() == material_id then
			material:pause()
		end
	end
end

function MaterialControl:set_time(material_name, time)
	local materials = self._unit:get_objects_by_type(Idstring("material"))
	local material_id = Idstring(material_name)

	for _, material in ipairs(materials) do
		if material:name() == material_id then
			material:set_time(time)
		end
	end
end
