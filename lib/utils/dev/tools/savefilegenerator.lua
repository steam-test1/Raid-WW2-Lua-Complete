SavefileGenerator = SavefileGenerator or class()
SavefileGenerator.path = "aux_assets\\inventory\\"
SavefileGenerator.savefile_slot = 11

-- Lines 6-36
function SavefileGenerator.generate()
	local file_path = SavefileGenerator._root_path() .. SavefileGenerator.path

	if not SystemFS:exists(file_path) then
		SystemFS:make_dir(file_path)
	end

	file_path = file_path .. "filesave_slot_11.xml"
	local cache_object = Global.savefile_manager.meta_data_list[SavefileGenerator.savefile_slot].cache

	SavefileGenerator._reset_indent_counter()

	SavefileGenerator.file_content = SystemFS:open(file_path, "w")

	SavefileGenerator._process_table(cache_object)
	SystemFS:close(SavefileGenerator.file_content)
	Application:trace("Savefile Generation Completed.")
end

-- Lines 38-64
function SavefileGenerator._process_table(table_object)
	for key, value in pairs(table_object) do
		if type(value) == "table" then
			local indent = SavefileGenerator._get_indent()

			SavefileGenerator.file_content:puts(indent .. "<table name=\"" .. key .. "\">")
			SavefileGenerator._process_table(value)
			SavefileGenerator.file_content:puts(indent .. "</table>")
		end
	end
end

-- Lines 66-68
function SavefileGenerator._increase_indent_counter()
	SavefileGenerator.indent_counter = SavefileGenerator.indent_counter + 1
end

-- Lines 70-72
function SavefileGenerator._reset_indent_counter()
	SavefileGenerator.indent_counter = 0
end

-- Lines 74-80
function SavefileGenerator._get_indent()
	local indent = ""

	for i = 1, SavefileGenerator.indent_counter do
		indent = indent .. SavefileGenerator.indent
	end

	return indent
end

-- Lines 84-91
function SavefileGenerator._root_path()
	local path = Application:base_path() .. (CoreApp.arg_value("-assetslocation") or "..\\..\\")
	path = Application:nice_path(path, true)
	local f = nil

	-- Lines 89-89
	function f(s)
		local str, i = string.gsub(s, "\\[%w_%.%s]+\\%.%.", "")

		return i > 0 and f(str) or str
	end

	return f(path)
end
