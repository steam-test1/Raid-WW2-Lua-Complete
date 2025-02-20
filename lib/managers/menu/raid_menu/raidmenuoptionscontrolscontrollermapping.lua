RaidMenuOptionsControlsControllerMapping = RaidMenuOptionsControlsControllerMapping or class(RaidGuiBase)

function RaidMenuOptionsControlsControllerMapping:init(ws, fullscreen_ws, node, component_name)
	self._label_font = tweak_data.gui.fonts.din_compressed
	self._label_font_size = tweak_data.gui.font_sizes.size_24

	RaidMenuOptionsControlsControllerMapping.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuOptionsControlsControllerMapping:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_controller_mapping_on_foot")
end

function RaidMenuOptionsControlsControllerMapping:_layout()
	RaidMenuOptionsControlsControllerMapping.super._layout(self)

	self._controller_image = self._root_panel:bitmap({
		texture = "ui/main_menu/textures/controller",
		h = 600,
		w = 1200,
		y = 0,
		x = 0,
		name = "controller_image"
	})

	self._controller_image:set_center_x(self._root_panel:w() / 2)
	self._controller_image:set_center_y(self._root_panel:h() / 2)

	self._panel_on_foot = self._root_panel:panel({
		x = 0,
		y = 0,
		name = "panel_on_foot",
		visible = true
	})
	self._panel_in_vehicle = self._root_panel:panel({
		x = 0,
		y = 0,
		name = "panel_on_foot",
		visible = false
	})

	if IS_PS4 then
		self:_layout_on_foot_ps4()
		self:_layout_in_vehicle_ps4()
	else
		self:_layout_on_foot()
		self:_layout_in_vehicle()
	end

	self:_layout_on_foot()
	self:_layout_in_vehicle()
	self:bind_controller_inputs_on_foot()
end

function RaidMenuOptionsControlsControllerMapping:close()
	RaidMenuOptionsControlsControllerMapping.super.close(self)
end

function RaidMenuOptionsControlsControllerMapping:_layout_on_foot_ps4()
	local southpaw = managers.user:get_setting("southpaw")
	local controller_bind_move_text = self:translate("menu_controller_keybind_move", true)
	local controller_bind_malee_text = self:translate("menu_controller_keybind_melee_attack", true)

	if southpaw then
		controller_bind_move_text = self:translate("menu_controller_keybind_melee_attack", true)
		controller_bind_malee_text = self:translate("menu_controller_keybind_move", true)
	end

	self._controller_keybind_lean = self._panel_on_foot:label({
		name = "lean",
		text = self:translate("menu_controller_keybind_lean", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.25,
		control = self._controller_keybind_lean
	})

	self._controller_keybind_comm_wheel = self._panel_on_foot:label({
		name = "communication_wheel",
		text = self:translate("menu_controller_keybind_comm_wheel", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.402,
		control = self._controller_keybind_comm_wheel
	})

	self._controller_keybind_grenade = self._panel_on_foot:label({
		name = "grenade",
		text = self:translate("menu_controller_keybind_grenade", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.482,
		control = self._controller_keybind_grenade
	})

	self._controller_keybind_knife = self._panel_on_foot:label({
		name = "knife",
		text = self:translate("menu_controller_keybind_knife", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.647,
		control = self._controller_keybind_knife
	})

	self._controller_keybind_fire_mode = self._panel_on_foot:label({
		name = "fire_mode",
		text = self:translate("menu_controller_keybind_weap_fire_mode", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.547,
		control = self._controller_keybind_fire_mode
	})

	self._controller_keybind_move = self._panel_on_foot:label({
		name = "move",
		text = controller_bind_move_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.85,
		control = self._controller_keybind_move
	})

	self._controller_keybind_melee_attack = self._panel_on_foot:label({
		name = "melee_attack",
		text = controller_bind_malee_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.6,
		control = self._controller_keybind_melee_attack
	})

	self._controller_keybind_interact = self._panel_on_foot:label({
		name = "interact",
		text = self:translate("menu_controller_keybind_interact", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.25,
		control = self._controller_keybind_interact
	})

	self._controller_keybind_switch_weapons = self._panel_on_foot:label({
		name = "switch_weapons",
		text = self:translate("menu_controller_keybind_switch_weapons", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.402,
		control = self._controller_keybind_switch_weapons
	})

	self._controller_keybind_crouch = self._panel_on_foot:label({
		name = "crouch",
		text = self:translate("menu_controller_keybind_crouch", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.482,
		control = self._controller_keybind_crouch
	})

	self._controller_keybind_jump = self._panel_on_foot:label({
		name = "jump",
		text = self:translate("menu_controller_keybind_jump", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.568,
		control = self._controller_keybind_jump
	})

	self._controller_keybind_reload = self._panel_on_foot:label({
		name = "reload",
		text = self:translate("menu_controller_keybind_reload", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.647,
		control = self._controller_keybind_reload
	})

	self._controller_keybind_aim = self._panel_on_foot:label({
		name = "aim_down_sight",
		text = self:translate("menu_controller_keybind_aim_down_sight", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.182,
		control = self._controller_keybind_aim
	})

	self._controller_keybind_mission_info = self._panel_on_foot:label({
		name = "mission_info",
		text = self:translate("menu_controller_keybind_mission_info", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.63,
		control = self._controller_keybind_mission_info
	})

	self._controller_keybind_ingame_menu = self._panel_on_foot:label({
		name = "ingame_menu",
		text = self:translate("menu_controller_keybind_ingame_menu", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.445,
		control = self._controller_keybind_ingame_menu
	})

	self._controller_keybind_fire_weapon = self._panel_on_foot:label({
		name = "fire_weapon",
		text = self:translate("menu_controller_keybind_fire_weapon", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.792,
		control = self._controller_keybind_fire_weapon
	})
end

function RaidMenuOptionsControlsControllerMapping:_layout_in_vehicle_ps4()
	local southpaw = managers.user:get_setting("southpaw")
	local controller_bind_steering_text = self:translate("menu_controller_keybind_steering", true)
	local controller_bind_look_back_text = self:translate("menu_controller_keybind_look_back", true)

	if southpaw then
		controller_bind_steering_text = self:translate("menu_controller_keybind_not_available", true)
		controller_bind_look_back_text = self:translate("menu_controller_keybind_steering_southpaw", true)
	end

	self._controller_keybind_change_seat = self._panel_in_vehicle:label({
		name = "change_seat",
		text = self:translate("menu_controller_keybind_change_seat", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.25,
		control = self._controller_keybind_change_seat
	})

	self._controller_keybind_na2 = self._panel_in_vehicle:label({
		name = "na2",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.402,
		control = self._controller_keybind_na2
	})

	self._controller_keybind_na3 = self._panel_in_vehicle:label({
		name = "na3",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.482,
		control = self._controller_keybind_na3
	})

	self._controller_keybind_na5 = self._panel_in_vehicle:label({
		name = "na5",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.647,
		control = self._controller_keybind_na5
	})

	self._controller_keybind_na4 = self._panel_in_vehicle:label({
		name = "na4",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.547,
		control = self._controller_keybind_na4
	})

	self._controller_keybind_steering = self._panel_in_vehicle:label({
		name = "move",
		text = controller_bind_steering_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.85,
		control = self._controller_keybind_steering
	})

	self._controller_keybind_look_back = self._panel_in_vehicle:label({
		name = "look_back",
		text = controller_bind_look_back_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.6,
		control = self._controller_keybind_look_back
	})

	self._controller_keybind_exit_vehicle = self._panel_in_vehicle:label({
		name = "exit_vehicle",
		text = self:translate("menu_controller_keybind_exit_vehicle", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.25,
		control = self._controller_keybind_exit_vehicle
	})

	self._controller_keybind_na8 = self._panel_in_vehicle:label({
		name = "na8",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.402,
		control = self._controller_keybind_na8
	})

	self._controller_keybind_switch_pose = self._panel_in_vehicle:label({
		name = "switch_pose",
		text = self:translate("menu_controller_keybind_switch_pose", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.482,
		control = self._controller_keybind_switch_pose
	})

	self._controller_keybind_handbrake = self._panel_in_vehicle:label({
		name = "handbrake",
		text = self:translate("menu_controller_keybind_handbrake", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.568,
		control = self._controller_keybind_handbrake
	})

	self._controller_keybind_na10 = self._panel_in_vehicle:label({
		name = "na10",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.647,
		control = self._controller_keybind_na10
	})

	self._controller_keybind_reverse = self._panel_in_vehicle:label({
		name = "reverse",
		text = self:translate("menu_controller_keybind_reverse", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.215,
		control = self._controller_keybind_reverse
	})

	self._controller_keybind_mission_info_vehicle = self._panel_in_vehicle:label({
		name = "mission_info_vehicle",
		text = self:translate("menu_controller_keybind_mission_info", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.63,
		control = self._controller_keybind_mission_info_vehicle
	})

	self._controller_keybind_ingame_menu_vehicle = self._panel_in_vehicle:label({
		name = "ingame_menu_vehicle",
		text = self:translate("menu_controller_keybind_ingame_menu", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.445,
		control = self._controller_keybind_ingame_menu_vehicle
	})

	self._controller_keybind_accelerate = self._panel_in_vehicle:label({
		name = "accelerate",
		text = self:translate("menu_controller_keybind_accelerate", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.786,
		control = self._controller_keybind_accelerate
	})
end

function RaidMenuOptionsControlsControllerMapping:_layout_on_foot()
	local southpaw = managers.user:get_setting("southpaw")
	local controller_bind_move_text = self:translate("menu_controller_keybind_move", true)
	local controller_bind_malee_text = self:translate("menu_controller_keybind_melee_attack", true)

	if southpaw then
		controller_bind_move_text = self:translate("menu_controller_keybind_melee_attack", true)
		controller_bind_malee_text = self:translate("menu_controller_keybind_move", true)
	end

	self._controller_keybind_aim = self._panel_on_foot:label({
		name = "aim_down_sight",
		text = self:translate("menu_controller_keybind_aim_down_sight", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.13,
		control = self._controller_keybind_aim
	})

	self._controller_keybind_lean = self._panel_on_foot:label({
		name = "lean",
		text = self:translate("menu_controller_keybind_lean", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.25,
		control = self._controller_keybind_lean
	})

	self._controller_keybind_move = self._panel_on_foot:label({
		name = "move",
		text = controller_bind_move_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.44,
		control = self._controller_keybind_move
	})

	self._controller_keybind_comm_wheel = self._panel_on_foot:label({
		name = "communication_wheel",
		text = self:translate("menu_controller_keybind_comm_wheel", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.57,
		control = self._controller_keybind_comm_wheel
	})

	self._controller_keybind_grenade = self._panel_on_foot:label({
		name = "grenade",
		text = self:translate("menu_controller_keybind_grenade", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.635,
		control = self._controller_keybind_grenade
	})

	self._controller_keybind_fire_mode = self._panel_on_foot:label({
		name = "fire_mode",
		text = self:translate("menu_controller_keybind_weap_fire_mode", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.83,
		control = self._controller_keybind_fire_mode
	})

	self._controller_keybind_knife = self._panel_on_foot:label({
		name = "knife",
		text = self:translate("menu_controller_keybind_knife", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.47,
		control = self._controller_keybind_knife
	})

	self._controller_keybind_melee_attack = self._panel_on_foot:label({
		name = "melee_attack",
		text = controller_bind_malee_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.6,
		control = self._controller_keybind_melee_attack
	})

	self._controller_keybind_fire_weapon = self._panel_on_foot:label({
		name = "fire_weapon",
		text = self:translate("menu_controller_keybind_fire_weapon", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.13,
		control = self._controller_keybind_fire_weapon
	})

	self._controller_keybind_interact = self._panel_on_foot:label({
		name = "interact",
		text = self:translate("menu_controller_keybind_interact", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.25,
		control = self._controller_keybind_interact
	})

	self._controller_keybind_switch_weapons = self._panel_on_foot:label({
		name = "switch_weapons",
		text = self:translate("menu_controller_keybind_switch_weapons", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.36,
		control = self._controller_keybind_switch_weapons
	})

	self._controller_keybind_crouch = self._panel_on_foot:label({
		name = "crouch",
		text = self:translate("menu_controller_keybind_crouch", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.44,
		control = self._controller_keybind_crouch
	})

	self._controller_keybind_jump = self._panel_on_foot:label({
		name = "jump",
		text = self:translate("menu_controller_keybind_jump", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.52,
		control = self._controller_keybind_jump
	})

	self._controller_keybind_reload = self._panel_on_foot:label({
		name = "reload",
		text = self:translate("menu_controller_keybind_reload", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.59,
		control = self._controller_keybind_reload
	})

	self._controller_keybind_mission_info = self._panel_on_foot:label({
		name = "mission_info",
		text = self:translate("menu_controller_keybind_mission_info", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.465,
		control = self._controller_keybind_mission_info
	})

	self._controller_keybind_ingame_menu = self._panel_on_foot:label({
		name = "ingame_menu",
		text = self:translate("menu_controller_keybind_ingame_menu", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.56,
		control = self._controller_keybind_ingame_menu
	})

	self._controller_keybind_warcry = self._panel_on_foot:label({
		name = "warcry",
		text = self:translate("menu_controller_keybind_warcry", true),
		font = self._label_font,
		font_size = self._label_font_size
	})
	local x, y, w, h = self._controller_keybind_warcry:text_rect()

	self._controller_keybind_warcry:set_w(w)
	self._controller_keybind_warcry:set_h(h)
	self._controller_keybind_warcry:set_align("center")
	self._controller_keybind_warcry:set_center_x(self._controller_image:center_x() + 20)
	self._controller_keybind_warcry:set_y(self._controller_image:y() - 20)
end

function RaidMenuOptionsControlsControllerMapping:_layout_in_vehicle()
	local southpaw = managers.user:get_setting("southpaw")
	local controller_bind_steering_text = self:translate("menu_controller_keybind_steering", true)
	local controller_bind_look_back_text = self:translate("menu_controller_keybind_look_back", true)

	if southpaw then
		controller_bind_steering_text = self:translate("menu_controller_keybind_not_available", true)
		controller_bind_look_back_text = self:translate("menu_controller_keybind_steering_southpaw", true)
	end

	self._controller_keybind_reverse = self._panel_in_vehicle:label({
		name = "reverse",
		text = self:translate("menu_controller_keybind_reverse", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.13,
		control = self._controller_keybind_reverse
	})

	self._controller_keybind_change_seat = self._panel_in_vehicle:label({
		name = "change_seat",
		text = self:translate("menu_controller_keybind_change_seat", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.25,
		control = self._controller_keybind_change_seat
	})

	self._controller_keybind_steering = self._panel_in_vehicle:label({
		name = "move",
		text = controller_bind_steering_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.44,
		control = self._controller_keybind_steering
	})

	self._controller_keybind_na2 = self._panel_in_vehicle:label({
		name = "na2",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.57,
		control = self._controller_keybind_na2
	})

	self._controller_keybind_na3 = self._panel_in_vehicle:label({
		name = "na3",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.635,
		control = self._controller_keybind_na3
	})

	self._controller_keybind_na4 = self._panel_in_vehicle:label({
		name = "na4",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "left",
		coord_y = 0.83,
		control = self._controller_keybind_na4
	})

	self._controller_keybind_na5 = self._panel_in_vehicle:label({
		name = "na5",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.47,
		control = self._controller_keybind_na5
	})

	self._controller_keybind_look_back = self._panel_in_vehicle:label({
		name = "look_back",
		text = controller_bind_look_back_text,
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "bottom",
		coord_x = 0.6,
		control = self._controller_keybind_look_back
	})

	self._controller_keybind_na7 = self._panel_in_vehicle:label({
		name = "accelerate",
		text = self:translate("menu_controller_keybind_accelerate", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.13,
		control = self._controller_keybind_na7
	})

	self._controller_keybind_exit_vehicle = self._panel_in_vehicle:label({
		name = "exit_vehicle",
		text = self:translate("menu_controller_keybind_exit_vehicle", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.25,
		control = self._controller_keybind_exit_vehicle
	})

	self._controller_keybind_na8 = self._panel_in_vehicle:label({
		name = "na8",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.36,
		control = self._controller_keybind_na8
	})

	self._controller_keybind_switch_pose = self._panel_in_vehicle:label({
		name = "switch_pose",
		text = self:translate("menu_controller_keybind_switch_pose", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.44,
		control = self._controller_keybind_switch_pose
	})

	self._controller_keybind_handbrake = self._panel_in_vehicle:label({
		name = "handbrake",
		text = self:translate("menu_controller_keybind_handbrake", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.52,
		control = self._controller_keybind_handbrake
	})

	self._controller_keybind_na10 = self._panel_in_vehicle:label({
		name = "na10",
		text = self:translate("menu_controller_keybind_not_available", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "right",
		coord_y = 0.59,
		control = self._controller_keybind_na10
	})

	self._controller_keybind_mission_info_vehicle = self._panel_in_vehicle:label({
		name = "mission_info_vehicle",
		text = self:translate("menu_controller_keybind_mission_info", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.465,
		control = self._controller_keybind_mission_info_vehicle
	})

	self._controller_keybind_ingame_menu_vehicle = self._panel_in_vehicle:label({
		name = "ingame_menu_vehicle",
		text = self:translate("menu_controller_keybind_ingame_menu", true),
		font = self._label_font,
		font_size = self._label_font_size
	})

	self:_set_position_size_controller_keybind_label({
		align = "top",
		coord_x = 0.56,
		control = self._controller_keybind_ingame_menu_vehicle
	})
end

function RaidMenuOptionsControlsControllerMapping:_set_position_size_controller_keybind_label(params)
	local x, y, w, h = params.control:text_rect()

	params.control:set_w(w)
	params.control:set_h(h)
	params.control:set_align("center")

	if params.align == "left" then
		params.control:set_right(self._controller_image:x() + self._controller_image:w() * 0.17)
		params.control:set_center_y(self._controller_image:y() + self._controller_image:h() * params.coord_y)
	elseif params.align == "bottom" then
		params.control:set_top(self._controller_image:bottom())
		params.control:set_center_x(self._controller_image:x() + self._controller_image:w() * params.coord_x)
	elseif params.align == "right" then
		params.control:set_left(self._controller_image:right() - self._controller_image:w() * 0.17)
		params.control:set_center_y(self._controller_image:y() + self._controller_image:h() * params.coord_y)
	elseif params.align == "top" then
		params.control:set_bottom(self._controller_image:top() + self._controller_image:top() * 0.43)
		params.control:set_center_x(self._controller_image:x() + self._controller_image:w() * params.coord_x)
	end
end

function RaidMenuOptionsControlsControllerMapping:bind_controller_inputs_on_foot()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_show_vehicle_mapping")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_options_controller_mapping_in_vehicle"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function RaidMenuOptionsControlsControllerMapping:bind_controller_inputs_in_vehicle()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_show_on_foot_mapping")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_options_controller_mapping_on_foot"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function RaidMenuOptionsControlsControllerMapping:_show_vehicle_mapping()
	self._panel_on_foot:hide()
	self._panel_in_vehicle:show()
	self:bind_controller_inputs_in_vehicle()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_controller_mapping_in_vehicle")
end

function RaidMenuOptionsControlsControllerMapping:_show_on_foot_mapping()
	self._panel_on_foot:show()
	self._panel_in_vehicle:hide()
	self:bind_controller_inputs_on_foot()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_controller_mapping_on_foot")
end
