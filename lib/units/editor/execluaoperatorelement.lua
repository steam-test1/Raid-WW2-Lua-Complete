ExecLuaOperatorElement = ExecLuaOperatorElement or class(MissionElement)

function ExecLuaOperatorElement:init(unit)
	ExecLuaOperatorElement.super.init(self, unit)

	self._hed.lua_string = ""
	self._hed.local_only = false

	table.insert(self._save_values, "lua_string")
	table.insert(self._save_values, "local_only")

	self._syntax_colors = {
		NONE = Vector3(0, 0, 0),
		OK = Vector3(50, 210, 50),
		ERROR = Vector3(220, 50, 50)
	}
end

function ExecLuaOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local additional_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Adittional options")
	local additional_element_sizer = EWS:BoxSizer("HORIZONTAL")

	additional_sizer:add(additional_element_sizer, 0, 1, "EXPAND,LEFT")
	self:_build_value_checkbox(panel, additional_sizer, "local_only", "Local Only")
	panel_sizer:add(additional_sizer, 0, 0, "EXPAND,LEFT")

	local text_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "LUA goes here")
	local text = EWS:TextCtrl(panel, self._hed.lua_string, "", "TE_MULTILINE,TE_DONTWRAP,VSCROLL,ALWAYS_SHOW_SB,TE_PROCESS_ENTER")

	text:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "lua_string",
		ctrlr = text
	})
	text:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "lua_string",
		ctrlr = text
	})
	text:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "_lua_syntax_check"))
	text:connect("EVT_KILL_FOCUS", callback(self, self, "_lua_syntax_check"))
	text_sizer:add(text, 1, 0, "EXPAND")
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")

	local button = EWS:Button(panel, "Check syntax", "", "")

	button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_lua_syntax_check"), button)
	panel_sizer:add(button, 0, 0, "LEFT")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	self._syntax_check_ctrl = EWS:TextCtrl(panel, "Syntax not checked", 0, "TE_RICH2,TE_MULTILINE,TE_READONLY,TE_WORDWRAP,TE_CENTRE")

	panel_sizer:add(self._syntax_check_ctrl, 0, 0, "EXPAND,TOP,BOTTOM")
	self:_add_help_text("!!EXPERIMENTAL!! Executes arbitrary LUA code")
	self:_lua_syntax_check()
end

function ExecLuaOperatorElement:_lua_syntax_check()
	self._syntax_check_ctrl:set_value("")

	if self._hed.lua_string then
		local func, res = loadstring(self._hed.lua_string)

		if func then
			res = "Syntax OK!"

			self._syntax_check_ctrl:set_default_style_colour(self._syntax_colors.OK)
		else
			self._syntax_check_ctrl:set_default_style_colour(self._syntax_colors.ERROR)
		end

		self._syntax_check_ctrl:append(res)
	else
		self._syntax_check_ctrl:set_default_style_colour(self._syntax_colors.NONE)
		self._syntax_check_ctrl:append("LUA string is empty!")
	end
end
