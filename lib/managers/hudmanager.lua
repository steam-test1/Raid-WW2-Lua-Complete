HUDManager = HUDManager or class()
HUDManager.TAB_SCREEN_SAFERECT = Idstring("guis/tab_screen_saferect")
HUDManager.TAB_SCREEN_FULLSCREEN = Idstring("guis/tab_screen_fullscreen")
HUDManager.WEAPON_SELECT_SCREEN_SAFERECT = Idstring("guis/weapon_select_screen_saferect_pd2")
HUDManager.WEAPON_SELECT_SCREEN_FULLSCREEN = Idstring("guis/weapon_select_screen_fullscreen")
HUDManager.ASSAULT_DIALOGS = {
	"gen_ban_b01a",
	"gen_ban_b01b",
	"gen_ban_b02a",
	"gen_ban_b02b",
	"gen_ban_b02c",
	"gen_ban_b03x",
	"gen_ban_b04x",
	"gen_ban_b05x",
	"gen_ban_b10",
	"gen_ban_b11",
	"gen_ban_b12"
}
HUDManager.OVERHEAD_Y_OFFSET = 18
HUDManager.SUSPICION_INDICATOR_Y_OFFSET = 40
HUDManager.DEFAULT_ALPHA = 1
HUDManager.DIFFERENT_SUSPICION_INDICATORS_FOR_TEAMMATES = true
HUDManager.WAYPOINT_MAX_FADE = 0.5
HUDManager.NAME_LABEL_HEIGHT_FROM_HEAD = 50
HUDManager.NAME_LABEL_Y_DIST_COEFF = 4
HUDManager.NAME_LABEL_DIST_TO_ALPHA_COEFF = 0.004

core:import("CoreEvent")

function HUDManager:init()
	self._component_map = {}
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	local safe_rect = managers.viewport:get_safe_rect()
	local res = RenderSettings.resolution
	self._workspace_size = {
		x = 0,
		y = 0,
		w = res.x,
		h = res.y
	}
	self._saferect_size = {
		x = safe_rect.x,
		y = safe_rect.y,
		w = safe_rect.width,
		h = safe_rect.height
	}
	self._mid_saferect = managers.gui_data:create_saferect_workspace()

	self._mid_saferect:set_timer(TimerManager:game())

	self._fullscreen_workspace = managers.gui_data:create_fullscreen_16_9_workspace()

	self._fullscreen_workspace:set_timer(TimerManager:game())

	self._saferect = managers.gui_data:create_saferect_workspace()

	self._saferect:set_timer(TimerManager:game())
	managers.gui_data:layout_corner_saferect_1280_workspace(self._saferect)

	self._workspace = Overlay:gui():create_scaled_screen_workspace(self._workspace_size.w, self._workspace_size.h, self._workspace_size.x, self._workspace_size.y, RenderSettings.resolution.x, RenderSettings.resolution.y)

	self._workspace:set_timer(TimerManager:game())
	managers.gui_data:layout_fullscreen_workspace(self._workspace)

	self._updators = {}

	managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))

	self._sound_source = SoundDevice:create_source("hud")

	managers.user:add_setting_changed_callback("controller_mod", callback(self, self, "controller_mod_changed"), true)
	managers.controller:add_hotswap_callback("hud_manager", callback(self, self, "controller_mod_changed"))
	self:_init_player_hud_values()

	self._chatinput_changed_callback_handler = CoreEvent.CallbackEventHandler:new()
	HUDManager.HIDEABLE_HUDS = {
		[PlayerBase.INGAME_HUD_SAFERECT:key()] = true,
		[PlayerBase.INGAME_HUD_FULLSCREEN:key()] = true,
		[IngameWaitingForRespawnState.GUI_SPECTATOR:key()] = true
	}

	if Global.debug_show_coords then
		self:debug_show_coordinates()
	else
		self:debug_hide_coordinates()
	end

	self._visible_huds_states = {}
	self._progress_target = {}

	managers.system_event_listener:add_listener("peer_changed_level", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PEER_LEVEL_UP
	}, callback(self, self, "_peer_changed_level"))
end

function HUDManager:_peer_changed_level(params)
	local peer = params.peer
	local character_data = managers.criminals:character_data_by_peer_id(peer:id())

	if character_data and character_data.panel_id then
		self._teammate_panels[character_data.panel_id]:set_level(peer:level())
	end
end

function HUDManager:saferect_w()
	return self._saferect:width()
end

function HUDManager:saferect_h()
	return self._saferect:height()
end

function HUDManager:add_chatinput_changed_callback(callback_func)
	self._chatinput_changed_callback_handler:add(callback_func)
end

function HUDManager:remove_chatinput_changed_callback(callback_func)
	self._chatinput_changed_callback_handler:remove(callback_func)
end

local is_PS3 = SystemInfo:platform() == Idstring("PS3")

function HUDManager:init_finalize()
	if not self:exists(PlayerBase.PLAYER_CUSTODY_HUD) then
		managers.hud:load_hud(PlayerBase.PLAYER_CUSTODY_HUD, false, false, true, {})
	end

	if not self:exists(PlayerBase.INGAME_HUD_SAFERECT) then
		managers.hud:load_hud(PlayerBase.INGAME_HUD_FULLSCREEN, false, false, false, {})
		managers.hud:load_hud(PlayerBase.INGAME_HUD_SAFERECT, false, false, true, {})
	end
end

function HUDManager:set_safe_rect(rect)
	self._saferect_size = rect

	self._saferect:set_screen(rect.w, rect.h, rect.x, rect.y, RenderSettings.resolution.x)
end

function HUDManager:load_hud(name, visible, using_collision, using_saferect, mutex_list, bounding_box_list, using_mid_saferect, using_16_9_fullscreen)
	if self._component_map[name:key()] then
		Application:error("ERROR! Component " .. tostring(name) .. " have already been loaded!")

		return
	end

	local bounding_box = {}
	local panel = nil

	if using_16_9_fullscreen then
		panel = self._fullscreen_workspace:panel():gui(name, {})
	elseif using_mid_saferect then
		panel = self._mid_saferect:panel():gui(name, {})
	elseif using_saferect then
		panel = self._saferect:panel():gui(name, {})
	else
		panel = self._workspace:panel():gui(name, {})
	end

	panel:hide()

	local bb_list = bounding_box_list

	if not bb_list and panel:has_script() then
		for k, v in pairs(panel:script()) do
			if k == "get_bounding_box_list" then
				if type(v) == "function" then
					bb_list = v()
				end

				break
			end
		end
	end

	if bb_list then
		if bb_list.x then
			table.insert(bb_list, {
				x1 = bb_list.x,
				y1 = bb_list.y,
				x2 = bb_list.x + bb_list.w,
				y2 = bb_list.y + bb_list.h
			})
		else
			for _, rect in pairs(bb_list) do
				table.insert(bounding_box, {
					x1 = rect.x,
					y1 = rect.y,
					x2 = rect.x + rect.w,
					y2 = rect.y + rect.h
				})
			end
		end
	else
		bounding_box = self:_create_bounding_boxes(panel)
	end

	self._component_map[name:key()] = {}
	self._component_map[name:key()].panel = panel
	self._component_map[name:key()].bb_list = bounding_box
	self._component_map[name:key()].mutex_list = {}
	self._component_map[name:key()].overlay_list = {}
	self._component_map[name:key()].idstring = name
	self._component_map[name:key()].load_visible = visible
	self._component_map[name:key()].load_using_collision = using_collision
	self._component_map[name:key()].load_using_saferect = using_saferect

	if mutex_list then
		self._component_map[name:key()].mutex_list = mutex_list
	end

	if using_collision then
		self._component_map[name:key()].overlay_list = self:_create_overlay_list(name)
	end

	if visible then
		panel:show()
	end

	self:setup(name)
	self:layout(name)
end

function HUDManager:setup(name)
	local panel = self:script(name).panel

	if not panel:has_script() then
		return
	end

	for k, v in pairs(panel:script()) do
		if k == "setup" then
			panel:script().setup(self)

			break
		end
	end
end

function HUDManager:layout(name)
	local panel = self:script(name).panel

	if not panel:has_script() then
		return
	end

	for k, v in pairs(panel:script()) do
		if k == "layout" then
			panel:script().layout(self)

			break
		end
	end
end

function HUDManager:delete(name)
	self._component_map[name:key()] = nil
end

function HUDManager:set_disabled()
	self._disabled = true

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:hide()
			end
		end
	end
end

function HUDManager:set_enabled()
	self._disabled = false

	for name, _ in pairs(HUDManager.HIDEABLE_HUDS) do
		if self._visible_huds_states[name] then
			local component = self._component_map[name]

			if component and alive(component.panel) then
				component.panel:show()
			end
		end
	end
end

function HUDManager:set_freeflight_disabled()
	self._saferect:hide()
	self._workspace:hide()
	self._mid_saferect:hide()
	self._fullscreen_workspace:hide()
end

function HUDManager:set_freeflight_enabled()
	self._saferect:show()
	self._workspace:show()
	self._mid_saferect:show()
	self._fullscreen_workspace:show()
end

function HUDManager:on_loading_screen_faded_to_black()
	self:hide_comm_wheel(true)
	self:hide_stats_screen()
	self:reset_player_panel_states()
	self._hud_chat:clear()
	self._hud_chat:hide()
	self:clear_vehicle_name_labels()
end

function HUDManager:disabled()
	return self._disabled
end

function HUDManager:reload_player_hud()
	self:reload()
end

function HUDManager:reload_all()
	self:reload()

	for name, gui in pairs(clone(self._component_map)) do
		local visible = self:visible(gui.idstring)

		self:hide(gui.idstring)
		self:delete(gui.idstring)
		self:load_hud(gui.idstring, gui.load_visible, gui.load_using_collision, gui.load_using_saferect, {})

		if visible then
			self:show(gui.idstring)
		end
	end
end

function HUDManager:reload()
	self:_recompile(managers.database:root_path() .. "assets\\guis\\")
end

function HUDManager:_recompile(dir)
	local source_files = self:_source_files(dir)
	local t = {
		target_db_name = "all",
		send_idstrings = false,
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:root_path() .. "/assets",
		target_db_root = Application:base_path() .. "assets",
		source_files = source_files
	}

	Application:data_compile(t)
	DB:reload()
	managers.database:clear_all_cached_indices()

	for _, file in ipairs(source_files) do
		PackageManager:reload(managers.database:entry_type(file):id(), managers.database:entry_path(file):id())
	end
end

function HUDManager:_source_files(dir)
	local files = {}
	local entry_path = managers.database:entry_path(dir) .. "/"

	for _, file in ipairs(SystemFS:list(dir)) do
		table.insert(files, entry_path .. file)
	end

	for _, sub_dir in ipairs(SystemFS:list(dir, true)) do
		for _, file in ipairs(SystemFS:list(dir .. "/" .. sub_dir)) do
			table.insert(files, entry_path .. sub_dir .. "/" .. file)
		end
	end

	return files
end

function HUDManager:panel(name)
	if not self._component_map[name:key()] then
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	else
		return self._component_map[name:key()].panel
	end
end

function HUDManager:alive(name)
	local component = self._component_map[name:key()]

	return component and alive(component.panel)
end

function HUDManager:script(name)
	local component = self._component_map[name:key()]

	if component and alive(component.panel) then
		return self._component_map[name:key()].panel:script()
	end
end

function HUDManager:exists(name)
	return not not self._component_map[name:key()]
end

function HUDManager:show(name)
	if HUDManager.disabled[name:key()] then
		return
	end

	self._visible_huds_states[name:key()] = true

	if self._disabled and HUDManager.HIDEABLE_HUDS[name:key()] then
		return
	end

	if self._component_map[name:key()] then
		local panel = self:script(name).panel

		if panel:has_script() then
			for k, v in pairs(panel:script()) do
				if k == "show" then
					panel:script().show(self)

					break
				end
			end
		end

		for _, mutex_name in pairs(self._component_map[name:key()].mutex_list) do
			if self._component_map[mutex_name:key()].panel:visible() then
				self._component_map[mutex_name:key()].panel:hide()
			end
		end

		if self:_validate_components(name) then
			self._component_map[name:key()].panel:show()
		end
	else
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end

	self._hud_chat:clear()
	self._hud_chat:unregister()

	if name == PlayerBase.INGAME_HUD_SAFERECT then
		self._hud_chat = self._hud_chat_ingame
	elseif name == IngameWaitingForRespawnState.GUI_SPECTATOR then
		self._hud_chat = self._hud_chat_respawn
	end

	self._hud_chat:register()
	self._hud_chat:hide()
end

function HUDManager:hide(name)
	self._visible_huds_states[name:key()] = nil
	local panel = self:script(name).panel

	if panel:has_script() then
		for k, v in pairs(panel:script()) do
			if k == "hide" then
				panel:script().hide(self)

				break
			end
		end
	end

	local component = self._component_map[name:key()]

	if component and alive(component.panel) then
		component.panel:hide()
	elseif not component then
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end
end

function HUDManager:visible(name)
	if self._component_map[name:key()] then
		return self._component_map[name:key()].panel:visible()
	else
		Application:error("ERROR! Component " .. tostring(name) .. " isn't loaded!")
	end
end

function HUDManager:_collision(rect1_map, rect2_map)
	if rect2_map.x2 <= rect1_map.x1 then
		return false
	end

	if rect1_map.x2 <= rect2_map.x1 then
		return false
	end

	if rect2_map.y2 <= rect1_map.y1 then
		return false
	end

	if rect1_map.y2 <= rect2_map.y1 then
		return false
	end

	return true
end

function HUDManager:_inside(rect1_map, rect2_map)
	if rect1_map.x1 < rect2_map.x1 or rect2_map.x2 < rect1_map.x1 then
		return false
	end

	if rect1_map.y1 < rect2_map.y1 or rect2_map.y2 < rect1_map.y1 then
		return false
	end

	if rect1_map.x2 < rect2_map.x1 or rect2_map.x2 < rect1_map.x2 then
		return false
	end

	if rect1_map.y2 < rect2_map.x1 or rect2_map.y2 < rect1_map.y2 then
		return false
	end

	return true
end

function HUDManager:_collision_rects(rect1_list, rect2_list)
	for _, rc1_map in pairs(rect1_list) do
		for _, rc2_map in pairs(rect2_list) do
			if self:_collision(rc1_map, rc2_map) then
				return true
			end
		end
	end

	return false
end

function HUDManager:_is_mutex(component_map, name)
	for _, mutex_name in pairs(component_map.mutex_list) do
		if mutex_name:key() == name then
			return true
		end
	end

	return false
end

function HUDManager:_create_bounding_boxes(panel)
	local bounding_box_list = {}
	local childrens = panel:children()
	local rect_map = {}

	for _, object in pairs(childrens) do
		rect_map = {
			x1 = object:x(),
			y1 = object:y(),
			x2 = object:x() + object:w(),
			y2 = object:y() + object:h()
		}

		if #bounding_box_list == 0 then
			table.insert(bounding_box_list, rect_map)
		else
			for _, bb_rect_map in pairs(bounding_box_list) do
				if self:_inside(rect_map, bb_rect_map) == false then
					table.insert(bounding_box_list, rect_map)

					break
				end
			end
		end
	end

	return bounding_box_list
end

function HUDManager:_create_overlay_list(name)
	local component = self._component_map[name:key()]
	local overlay_list = {}

	for cmp_name, cmp_map in pairs(self._component_map) do
		if name:key() ~= cmp_name and not self:_is_mutex(cmp_map, name:key()) and self:_collision_rects(component.bb_list, cmp_map.bb_list) then
			table.insert(overlay_list, cmp_map.idstring)

			if not self:_is_mutex(component, cmp_name) then
				table.insert(self._component_map[cmp_name].overlay_list, name)
			end

			if Application:production_build() then
				Application:error("WARNING! Component " .. tostring(name) .. " collides with " .. tostring(cmp_map.idstring))
			end
		end
	end

	return overlay_list
end

function HUDManager:_validate_components(name)
	for _, overlay_name in pairs(self._component_map[name:key()].overlay_list) do
		if self._component_map[overlay_name:key()] and self._component_map[overlay_name:key()].panel:visible() then
			Application:error("WARNING! Component " .. tostring(name) .. " collides with " .. tostring(overlay_name))

			return false
		end
	end

	return true
end

function HUDManager:resolution_changed()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
	local safe_rect = managers.viewport:get_safe_rect()

	managers.gui_data:layout_corner_saferect_1280_workspace(self._saferect)
	managers.gui_data:layout_fullscreen_workspace(self._workspace)
	managers.gui_data:layout_workspace(self._mid_saferect)
	managers.gui_data:layout_fullscreen_workspace(self._fullscreen_workspace)

	for name, gui in pairs(self._component_map) do
		self:layout(gui.idstring)
	end
end

function HUDManager:update(t, dt)
	for _, cb in pairs(self._updators) do
		cb(t, dt)
	end

	self:_update_name_labels(t, dt)
	self:_update_vehicle_name_labels(t, dt)
	self:_update_waypoints(t, dt)
	self:_update_suspicion_indicators(t, dt)

	if self._debug then
		local cam_pos = managers.viewport:get_current_camera_position()

		if cam_pos then
			self._debug.coord:set_text(string.format("Cam pos:   \"%.0f %.0f %.0f\" [cm]", cam_pos.x, cam_pos.y, cam_pos.z))
		end
	end
end

function HUDManager:change_map_floor(new_floor)
	self.current_floor = new_floor

	if self._tab_screen then
		self._tab_screen:change_floor(new_floor)
	end
end

function HUDManager:add_updator(id, cb)
	self._updators[id] = cb
end

function HUDManager:remove_updator(id)
	self._updators[id] = nil
end

local nl_w_pos = Vector3()
local nl_pos = Vector3()
local nl_dir = Vector3()
local nl_dir_normalized = Vector3()
local nl_cam_forward = Vector3()

function HUDManager:_calculate_name_label_screen_position(name_label, cam)
	if name_label:movement() == nil then
		return
	end

	local head_obj = name_label:movement():get_object(Idstring("Head"))

	if head_obj == nil then
		Application:warn("[HUDManager:_calculate_name_label_screen_position] Tried to calculate name label position on dead unit!")

		return
	end

	local pos = head_obj:position()

	mvector3.set(nl_w_pos, pos)
	mvector3.set_z(nl_w_pos, mvector3.z(pos + Vector3(0, 0, HUDManager.NAME_LABEL_HEIGHT_FROM_HEAD)))
	mvector3.set(nl_pos, self._workspace:world_to_screen(cam, nl_w_pos))
end

function HUDManager:_handle_name_label_overlapping(name_label1, name_label2, cam_pos)
	if not name_label1 or not name_label2 then
		return
	end

	if not name_label1:is_overlapping(name_label2) then
		return
	end

	if not name_label1:panel():visible() or not name_label2:panel():visible() then
		return
	end

	if name_label1:movement() == nil or name_label2:movement() == nil then
		return
	end

	local head_obj1 = name_label1:movement():get_object(Idstring("Head"))
	local head_obj2 = name_label2:movement():get_object(Idstring("Head"))

	if head_obj1 == nil or head_obj2 == nil then
		Application:warn("[HUDManager:_handle_name_label_overlapping] Tried to calculate name label overlap on dead unit!")

		return
	end

	local head_pos1 = head_obj1:position()
	local head_pos2 = head_obj2:position()
	local label1_unit_dist = (head_pos1 - cam_pos):length()
	local label2_unit_dist = (head_pos2 - cam_pos):length()
	local further_label = name_label1

	if label1_unit_dist < label2_unit_dist then
		further_label = name_label2
	end

	local label_dist = HUDManager.NAME_LABEL_Y_DIST_COEFF * math.abs(name_label1:panel():center_y() - name_label2:panel():center_y())
	label_dist = label_dist + math.abs(name_label1:panel():center_x() - name_label2:panel():center_x())
	local alpha = math.min(math.clamp(label_dist * HUDManager.NAME_LABEL_DIST_TO_ALPHA_COEFF, 0, 1), further_label:panel():alpha())

	further_label:panel():set_alpha(alpha)
end

function HUDManager:_update_name_labels(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local player = managers.player:local_player()
	local in_steelsight = false

	if alive(player) then
		in_steelsight = player:movement() and player:movement():current_state() and player:movement():current_state():in_steelsight() or false
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, nl_cam_forward)

	local panel = nil

	for index, name_label in ipairs(self._hud.name_labels) do
		local panel = panel or name_label:panel():parent()

		self:_calculate_name_label_screen_position(name_label, cam)
		mvector3.set(nl_dir, nl_w_pos)
		mvector3.subtract(nl_dir, cam_pos)
		mvector3.set(nl_dir_normalized, nl_dir)
		mvector3.normalize(nl_dir_normalized)

		local dot = mvector3.dot(nl_cam_forward, nl_dir_normalized)

		if dot < 0 or panel:outside(mvector3.x(nl_pos), mvector3.y(nl_pos)) then
			name_label:hide()
		else
			name_label:panel():set_alpha(in_steelsight and math.clamp((1 - dot) * 100, 0, 1) or 1)
			name_label:show()
		end

		if name_label:movement() then
			if name_label:movement().current_state_name and name_label:movement():current_state_name() == "driving" then
				name_label:hide()
			elseif name_label:movement().vehicle_seat and name_label:movement().vehicle_seat.occupant ~= nil then
				name_label:hide()
			end
		end

		if name_label:panel():visible() then
			name_label:panel():set_center(nl_pos.x, nl_pos.y)
		end
	end

	for i = 1, #self._hud.name_labels do
		for j = i + 1, #self._hud.name_labels do
			self:_handle_name_label_overlapping(self._hud.name_labels[i], self._hud.name_labels[j], cam_pos)
		end
	end
end

function HUDManager:_update_vehicle_name_labels(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, nl_cam_forward)

	local panel = nil

	for index, name_label in ipairs(self._hud.vehicle_name_labels) do
		local panel = panel or name_label:panel():parent()
		local pos = name_label._vehicle_unit:position()

		mvector3.set(nl_w_pos, pos)
		mvector3.set_z(nl_w_pos, mvector3.z(pos + Vector3(0, 0, 200)))
		mvector3.set(nl_pos, self._workspace:world_to_screen(cam, nl_w_pos))
		mvector3.set(nl_dir, nl_w_pos)
		mvector3.subtract(nl_dir, cam_pos)
		mvector3.set(nl_dir_normalized, nl_dir)
		mvector3.normalize(nl_dir_normalized)

		local dot = mvector3.dot(nl_cam_forward, nl_dir_normalized)

		if dot < 0 or panel:outside(mvector3.x(nl_pos), mvector3.y(nl_pos)) then
			name_label:hide()
		else
			name_label:panel():set_alpha(1)
			name_label:show()
		end

		if name_label:panel():visible() then
			name_label:panel():set_center(nl_pos.x, nl_pos.y)
		end
	end
end

function HUDManager:_init_player_hud_values()
	self._hud = self._hud or {}
	self._hud.waypoints = self._hud.waypoints or {}
	self._hud.stored_waypoints = self._hud.stored_waypoints or {}
	self._hud.weapons = self._hud.weapons or {}
	self._hud.mugshots = self._hud.mugshots or {}
	self._hud.name_labels = self._hud.name_labels or {}
	self._hud.vehicle_name_labels = self._hud.vehicle_name_labels or {}
	self._hud.suspicion_indicators = self._hud.suspicion_indicators or {}
end

function HUDManager:post_event(event)
	self._sound_source:post_event(event)
end

function HUDManager:_player_hud_layout()
	self:_init_player_hud_values()

	for id, data in pairs(self._hud.stored_waypoints) do
		self:add_waypoint(id, data)
	end
end

function HUDManager:add_suspicion_indicator(id, data)
	if self._hud.suspicion_indicators[id] then
		self:remove_suspicion_indicator(id)
	end

	local hud = managers.hud:script(PlayerBase.INGAME_HUD_FULLSCREEN)

	if not hud then
		return
	end

	self:create_suspicion_indicator(id, data.position, data.state, data.suspect)

	local suspicion = HUDSuspicionIndicator:new(hud, data)
	self._hud.suspicion_indicators[id] = suspicion
end

function HUDManager:remove_suspicion_indicator(id)
	if self._hud.suspicion_indicators[id] then
		self._hud.suspicion_indicators[id]:destroy()

		self._hud.suspicion_indicators[id] = nil
	end

	if self._progress_target then
		self._progress_target[id] = nil
	end

	self._hud_suspicion_direction:remove_suspicion_indicator(id)
end

function HUDManager:set_suspicion_indicator_state(id, state)
	if not self._hud.suspicion_indicators[id] then
		return
	end

	local old_state = self._hud.suspicion_indicators[id]:state()

	if old_state == "calling" then
		return
	end

	if old_state == "alarmed" and state ~= "calling" then
		return
	end

	self._hud.suspicion_indicators[id]:set_state(state)
	self._hud_suspicion_direction:set_state(id, state)
end

function HUDManager:_get_raid_icon(icon)
	Application:trace("[HUDManager] _get_raid_icon(): " .. tostring(icon))

	if string.sub(icon, 1, string.len("waypoint_special")) == "waypoint_special" or string.sub(icon, 1, string.len("map_waypoint")) == "map_waypoint" then
		return tweak_data.gui.icons[icon].texture, tweak_data.gui.icons[icon].texture_rect
	else
		return tweak_data.hud_icons:get_icon_data(icon, {
			0,
			0,
			32,
			32
		})
	end
end

function HUDManager:add_waypoint(id, data)
	if self._hud.waypoints[id] then
		self:remove_waypoint(id)
	end

	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

	if not hud then
		self._hud.stored_waypoints[id] = data

		return
	end

	local icon = data.icon or "wp_standard"
	local icon, texture_rect, rect_over = self:_get_raid_icon(icon)
	self._hud.waypoints[id] = {
		move_speed = 1,
		id_string = id,
		init_data = data,
		state = data.state or "present",
		present_timer = data.present_timer or 2.5,
		position = data.position,
		rotation = data.rotation,
		unit = data.unit,
		suspect = data.suspect,
		no_sync = data.no_sync,
		radius = data.radius or 160,
		position_offset_z = data.position_offset_z or nil,
		waypoint_type = data.waypoint_type,
		waypoint_display = data.waypoint_display,
		waypoint_color = data.waypoint_color,
		waypoint_width = data.waypoint_width,
		waypoint_depth = data.waypoint_depth,
		waypoint_radius = data.waypoint_radius,
		icon = icon,
		map_icon = data.map_icon,
		texture_rect = texture_rect,
		show_on_screen = data.show_on_screen or data.show_on_screen == nil and true,
		lifetime = data.lifetime or false
	}
	self._hud.waypoints[id].init_data.position = data.position or data.unit:position()

	if self._tab_screen ~= nil and data.position ~= nil and data.waypoint_type == "objective" then
		self._tab_screen:add_waypoint(self._hud.waypoints[id])
	end

	local show_on_screen = self._hud.waypoints[id].show_on_screen

	if show_on_screen == true then
		local waypoint_panel = hud.panel
		local bitmap = waypoint_panel:bitmap({
			layer = 0,
			rotation = 360,
			name = "bitmap" .. id,
			texture = icon,
			texture_rect = texture_rect,
			color = data.color or Color.white,
			w = texture_rect[3],
			h = texture_rect[4],
			blend_mode = data.blend_mode
		})
		local bitmap_over, searching, aiming = nil

		if rect_over then
			bitmap_over = waypoint_panel:bitmap({
				h = 0,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "bitmap_over" .. id,
				texture = icon,
				texture_rect = rect_over
			})
			local aiming_icon, aiming_rect = tweak_data.hud_icons:get_icon_data("wp_aiming")
			local searching_icon, searching_rect = tweak_data.hud_icons:get_icon_data("wp_investigating")
			searching = waypoint_panel:bitmap({
				h = 16,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "searching" .. id,
				texture = searching_icon,
				texture_rect = searching_rect
			})
			aiming = waypoint_panel:bitmap({
				h = 16,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "aiming" .. id,
				texture = aiming_icon,
				texture_rect = aiming_rect
			})
		end

		local arrow_icon = tweak_data.gui.icons.map_waypoint_pov_out.texture
		local arrow_texture_rect = tweak_data.gui.icons.map_waypoint_pov_out.texture_rect
		local arrow = waypoint_panel:bitmap({
			layer = 0,
			visible = false,
			rotation = 360,
			name = "arrow" .. id,
			texture = arrow_icon,
			texture_rect = arrow_texture_rect,
			color = data.color or Color.white,
			w = arrow_texture_rect[3],
			h = arrow_texture_rect[4],
			blend_mode = data.blend_mode
		})
		local distance = nil

		if data.distance then
			distance = waypoint_panel:text({
				vertical = "center",
				h = 26,
				w = 128,
				align = "center",
				text = "",
				rotation = 360,
				layer = 0,
				name = "distance" .. id,
				color = data.color or Color.white,
				font = tweak_data.gui.fonts.din_compressed_outlined_24,
				font_size = tweak_data.gui.font_sizes.size_24,
				blend_mode = data.blend_mode
			})

			distance:set_visible(false)
		end

		local timer = data.timer and waypoint_panel:text({
			font_size = 32,
			h = 32,
			vertical = "center",
			w = 32,
			align = "center",
			rotation = 360,
			layer = 0,
			name = "timer" .. id,
			text = (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer),
			font = tweak_data.gui.fonts.din_compressed_outlined_32
		})
		local w, h = bitmap:size()
		local stealth_over_rect = nil

		if rect_over then
			stealth_over_rect = {
				rect_over[1],
				rect_over[2],
				rect_over[3],
				rect_over[4]
			}
		end

		self._hud.waypoints[id].bitmap = bitmap
		self._hud.waypoints[id].bitmap_over = bitmap_over
		self._hud.waypoints[id].searching = searching
		self._hud.waypoints[id].aiming = aiming
		self._hud.waypoints[id].stealth_over_rect = stealth_over_rect
		self._hud.waypoints[id].arrow = arrow
		self._hud.waypoints[id].size = Vector3(w, h, 0)
		self._hud.waypoints[id].distance = distance
		self._hud.waypoints[id].timer_gui = timer
		self._hud.waypoints[id].timer = data.timer
		self._hud.waypoints[id].pause_timer = data.pause_timer or data.timer and 0
		local slot = 1
		local t = {}

		for _, data in pairs(self._hud.waypoints) do
			if data.slot then
				t[data.slot] = 0
			end
		end

		for i = 1, 10 do
			if not t[i] then
				self._hud.waypoints[id].slot = i

				break
			end
		end

		self._hud.waypoints[id].slot_x = 0

		if self._hud.waypoints[id].slot == 2 then
			self._hud.waypoints[id].slot_x = t[1] / 2 + 10
		elseif self._hud.waypoints[id].slot == 3 then
			self._hud.waypoints[id].slot_x = -t[1] / 2 - 10
		elseif self._hud.waypoints[id].slot == 4 then
			self._hud.waypoints[id].slot_x = t[1] / 2 + t[2] + 20
		elseif self._hud.waypoints[id].slot == 5 then
			self._hud.waypoints[id].slot_x = -t[1] / 2 - t[3] - 20
		end
	end
end

function HUDManager:change_waypoint_icon(id, icon)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local waypoint_panel = hud.panel
	local wp_data = self._hud.waypoints[id]
	local texture, rect, rect_over = tweak_data.hud_icons:get_icon_data(icon, {
		0,
		0,
		32,
		32
	})
	wp_data.icon = texture
	wp_data.texture_rect = rect
	local show_on_screen = wp_data.show_on_screen

	if show_on_screen == true then
		wp_data.bitmap:set_image(texture, rect[1], rect[2], rect[3], rect[4])
		wp_data.bitmap:set_size(rect[3], rect[4])

		wp_data.size = Vector3(rect[3], rect[4])

		if wp_data.bitmap_over then
			waypoint_panel:remove(wp_data.bitmap_over)
			waypoint_panel:remove(wp_data.searching)
			waypoint_panel:remove(wp_data.aiming)

			wp_data.bitmap_over = nil
			wp_data.searching = nil
			wp_data.aiming = nil
		end

		if rect_over then
			wp_data.stealth_over_rect = {
				rect_over[1],
				rect_over[2],
				rect_over[3],
				rect_over[4]
			}
			wp_data.bitmap_over = waypoint_panel:bitmap({
				h = 0,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "bitmap_over" .. id,
				texture = texture,
				texture_rect = rect_over
			})
			local aiming_icon, aiming_rect = tweak_data.hud_icons:get_icon_data("wp_aiming")
			local searching_icon, searching_rect = tweak_data.hud_icons:get_icon_data("wp_investigating")
			wp_data.searching = waypoint_panel:bitmap({
				h = 16,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "searching" .. id,
				texture = searching_icon,
				texture_rect = searching_rect
			})
			wp_data.aiming = waypoint_panel:bitmap({
				h = 16,
				blend_mode = "normal",
				w = 32,
				layer = 0,
				rotation = 360,
				name = "aiming" .. id,
				texture = aiming_icon,
				texture_rect = aiming_rect
			})
		end
	end
end

function HUDManager:change_waypoint_icon_alpha(id, alpha)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]
	local show_on_screen = wp_data.show_on_screen

	if show_on_screen == true then
		wp_data.bitmap:set_alpha(alpha)
	end
end

function HUDManager:change_waypoint_arrow_color(id, color)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_icon] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]
	local show_on_screen = wp_data.show_on_screen

	if show_on_screen == true then
		wp_data.arrow:set_color(color:with_alpha(wp_data.arrow:color().a))
	end
end

function HUDManager:change_waypoint_distance_color(id, color)
	if not self._hud.waypoints[id] then
		Application:error("[HUDManager:change_waypoint_distance_color] no waypoint with id", id)

		return
	end

	local wp_data = self._hud.waypoints[id]
	local show_on_screen = wp_data.show_on_screen

	if show_on_screen == true then
		wp_data.distance:set_color(color:with_alpha(wp_data.distance:color().a))
	end
end

function HUDManager:remove_waypoint(id)
	self._hud.stored_waypoints[id] = nil

	if not self._hud.waypoints[id] then
		return
	end

	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

	if not hud then
		return
	end

	if self._tab_screen ~= nil then
		self._tab_screen:remove_waypoint(tostring(id))
	end

	local waypoint_panel = hud.panel
	local show_on_screen = self._hud.waypoints[id].show_on_screen

	if show_on_screen == true then
		waypoint_panel:remove(self._hud.waypoints[id].bitmap)

		if self._hud.waypoints[id].bitmap_over then
			waypoint_panel:remove(self._hud.waypoints[id].bitmap_over)
			waypoint_panel:remove(self._hud.waypoints[id].searching)
			waypoint_panel:remove(self._hud.waypoints[id].aiming)
		end

		waypoint_panel:remove(self._hud.waypoints[id].arrow)
	end

	if self._hud.waypoints[id].timer_gui then
		waypoint_panel:remove(self._hud.waypoints[id].timer_gui)
	end

	if self._hud.waypoints[id].distance then
		waypoint_panel:remove(self._hud.waypoints[id].distance)
	end

	self._hud.waypoints[id] = nil

	self:_check_and_hide_suspicion()
end

function HUDManager:_check_and_hide_suspicion()
	local found = false

	for _, data in pairs(self._hud.waypoints) do
		if data.waypoint_type == "suspicion" then
			found = true
		end
	end

	for _, suspicion_indicator in pairs(self._hud.suspicion_indicators) do
		found = true
	end

	if not found then
		self:hide_suspicion()
	end
end

function HUDManager:set_waypoint_timer_pause(id, pause)
	if not self._hud.waypoints[id] then
		return
	end

	if self._hud.waypoints[id].show_on_screen == true and self._hud.waypoints[id].pause_timer then
		self._hud.waypoints[id].pause_timer = self._hud.waypoints[id].pause_timer + (pause and 1 or -1)
	end
end

function HUDManager:get_waypoint_data(id)
	return self._hud.waypoints[id]
end

function HUDManager:get_all_waypoints()
	return self._hud.waypoints
end

function HUDManager:clear_waypoints()
	for id, _ in pairs(clone(self._hud.waypoints)) do
		self:remove_waypoint(id)
	end

	for id, indicator in pairs(clone(self._hud.suspicion_indicators)) do
		indicator:destroy()

		indicator = nil
	end

	self._hud.suspicion_indicators = {}
end

function HUDManager:clear_objectives()
	self._hud_objectives:_clear_objectives()
end

function HUDManager:get_waypoint_for_unit(unit)
	for id, data in pairs(self._hud.waypoints) do
		if data.unit and data.unit == unit then
			return id
		end
	end
end

function HUDManager:clear_weapons()
	self._hud.weapons = {}
end

function HUDManager:add_mugshot_by_unit(unit)
	if unit:base().is_local_player then
		return
	end

	local characters = managers.criminals:characters()
	local nationality = nil

	for i = 1, #characters do
		if characters[i].unit == unit then
			nationality = characters[i].name
		end
	end

	local character_name = unit:base():nick_name()
	local is_husk_player = unit:base().is_husk_player
	local name_label_params = {
		name = character_name,
		unit = unit,
		nationality = nationality
	}
	local name_label_id = managers.hud:_add_name_label(name_label_params)
	unit:unit_data().name_label_id = name_label_id
	local character_name_id = managers.criminals:character_name_by_unit(unit)

	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name_id then
			if is_husk_player and not data.peer_id then
				self:_remove_mugshot(data.id)

				break
			else
				unit:unit_data().mugshot_id = data.id

				managers.hud:set_mugshot_normal(unit:unit_data().mugshot_id)
				managers.hud:set_mugshot_armor(unit:unit_data().mugshot_id, 1)
				managers.hud:set_mugshot_health(unit:unit_data().mugshot_id, 1)

				return
			end
		end
	end

	local peer, peer_id = nil

	if is_husk_player then
		peer = unit:network():peer()
		peer_id = peer:id()
	end

	local use_lifebar = is_husk_player and true or false
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})
	unit:unit_data().mugshot_id = mugshot_id

	if peer and peer:is_cheater() then
		if NetworkPeer.CHEAT_CHECKS_DISABLED == true then
			return
		end

		self:mark_cheater(peer_id)
	end

	return mugshot_id, name_label_id
end

function HUDManager:add_mugshot_without_unit(char_name, ai, peer_id, name)
	local character_name = name
	local character_name_id = char_name
	local use_lifebar = not ai
	local mugshot_id = managers.hud:add_mugshot({
		name = character_name,
		use_lifebar = use_lifebar,
		peer_id = peer_id,
		character_name_id = character_name_id
	})

	return mugshot_id
end

function HUDManager:get_character_name_by_nationality(nationality)
	local name = "DEFAULT_NAME"

	if nationality == "russian" then
		name = "kurgan"
	elseif nationality == "german" then
		name = "wolfgang"
	elseif nationality == "british" then
		name = "stirling"
	elseif nationality == "american" then
		name = "rivet"
	end

	return utf8.to_upper(name)
end

function HUDManager:add_mugshot(data)
	local panel_id = self:add_teammate_panel(data.character_name_id, data.name, not data.use_lifebar, data.peer_id)
	managers.criminals:character_data_by_name(data.character_name_id).panel_id = panel_id
	local last_id = self._hud.mugshots[#self._hud.mugshots] and self._hud.mugshots[#self._hud.mugshots].id or 0
	local id = last_id + 1

	table.insert(self._hud.mugshots, {
		id = id,
		character_name_id = data.character_name_id,
		peer_id = data.peer_id
	})

	return id
end

function HUDManager:remove_hud_info_by_unit(unit)
	if unit:unit_data().name_label_id then
		self:_remove_name_label(unit:unit_data().name_label_id)
	end
end

function HUDManager:remove_mugshot_by_character_name(character_name)
	for i, data in ipairs(self._hud.mugshots) do
		if data.character_name_id == character_name then
			self:_remove_mugshot(data.id)

			break
		end
	end
end

function HUDManager:remove_mugshot(id)
	self:_remove_mugshot(id)
end

function HUDManager:_remove_mugshot(id)
	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			table.remove(self._hud.mugshots, i)
			self:remove_teammate_panel_by_name_id(data.character_name_id)

			break
		end
	end
end

function HUDManager:remove_teammate_panel_by_name_id(name_id)
	local character_data = managers.criminals:character_data_by_name(name_id)

	if character_data and character_data.panel_id then
		self:remove_teammate_panel(character_data.panel_id)
	end
end

function HUDManager:set_mugshot_weapon(id, hud_icon_id, weapon_index)
	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			print("set_mugshot_weapon", id, hud_icon_id, weapon_index)
			self:_set_teammate_weapon_selected(managers.criminals:character_data_by_name(data.character_name_id).panel_id, weapon_index, hud_icon_id)

			break
		end
	end
end

function HUDManager:set_mugshot_armor(id, amount)
	if not id then
		return
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			self:set_teammate_armor(managers.criminals:character_data_by_name(data.character_name_id).panel_id, {
				total = 1,
				max = 1,
				current = amount
			})

			break
		end
	end
end

function HUDManager:set_mugshot_health(id, amount)
	if not id then
		return
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			self:set_teammate_health(managers.criminals:character_data_by_name(data.character_name_id).panel_id, {
				total = 1,
				max = 1,
				current = amount
			})

			break
		end
	end
end

function HUDManager:_get_mugshot_data(id)
	if not id then
		return nil
	end

	for i, data in ipairs(self._hud.mugshots) do
		if data.id == id then
			return data
		end
	end

	return nil
end

function HUDManager:set_mugshot_normal(id)
	local data = self:_get_mugshot_data(id)

	if not data then
		return
	end

	self:set_teammate_condition(managers.criminals:character_data_by_name(data.character_name_id).panel_id, "mugshot_normal", "")
end

function HUDManager:set_mugshot_downed(id)
	self._teammate_panels[id]:go_into_bleedout()
end

function HUDManager:set_mugshot_custody(id)
	local data = self:_set_mugshot_state(id, "mugshot_in_custody", managers.localization:text("debug_mugshot_in_custody"))

	if data then
		local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id

		self:set_teammate_health(i, {
			total = 100,
			current = 0,
			no_hint = true
		})
		self:set_teammate_armor(i, {
			total = 100,
			current = 0,
			no_hint = true
		})
	end
end

function HUDManager:_set_mugshot_state(id, icon_data, text)
	local data = self:_get_mugshot_data(id)

	if not data then
		return
	end

	local i = managers.criminals:character_data_by_name(data.character_name_id).panel_id

	self:set_teammate_condition(i, icon_data, text)

	return data
end

function HUDManager:update_vehicle_label_by_id(label_id, num_players)
end

function HUDManager:start_anticipation(data)
end

function HUDManager:sync_start_anticipation()
end

function HUDManager:check_start_anticipation_music(t)
	if not self._anticipation_music_started and t < 30 then
		self._anticipation_music_started = true

		managers.network:session():send_to_peers_synched("sync_start_anticipation_music")
		self:sync_start_anticipation_music()
	end
end

function HUDManager:sync_start_anticipation_music()
	managers.music:raid_music_state_change(MusicManager.RAID_MUSIC_ANTICIPATION)
end

function HUDManager:start_assault(data)
	self._hud.in_assault = true

	managers.network:session():send_to_peers_synched("sync_start_assault")
	self:sync_start_assault(data)
end

function HUDManager:end_assault(result)
	self._anticipation_music_started = false
	self._hud.in_assault = false

	self:sync_end_assault(result)
	managers.network:session():send_to_peers_synched("sync_end_assault", result)
end

function HUDManager:setup_anticipation(total_t)
	local exists = self._anticipation_dialogs and true or false
	self._anticipation_dialogs = {}

	if not exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 45,
			dialog = 1
		})
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 2
		})
	elseif exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 6
		})
	end

	if total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 3
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 35 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 7
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 25 then
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 8
		})
	end
end

function HUDManager:set_crosshair_offset(offset)
end

function HUDManager:set_crosshair_visible(visible)
end

function HUDManager:present_mid_text(params)
	params.present_mid_text = true

	self:present(params)
end

function HUDManager:_update_crosshair_offset(t, dt)
end

function HUDManager:_upd_suspition_waypoint_pos(data)
	if data.bitmap_over then
		data.bitmap_over:set_bottom(data.bitmap:bottom())
		data.bitmap_over:set_left(data.bitmap:left())
		data.searching:set_bottom(data.bitmap:top())
		data.searching:set_left(data.bitmap:left())
		data.aiming:set_bottom(data.bitmap:top())
		data.aiming:set_left(data.bitmap:left())
	end
end

function HUDManager:_upd_suspition_waypoint_alpha(data, alpha)
	local fix = 0

	if alpha > 0 then
		fix = 0.15
	end

	if data.bitmap_over then
		data.bitmap_over:set_color(data.bitmap_over:color():with_alpha(alpha))
		data.searching:set_color(data.searching:color():with_alpha(alpha + fix))
		data.aiming:set_color(data.aiming:color():with_alpha(alpha + fix))
	end
end

function HUDManager:_animate_suspition_waypoint_alpha(data, callback, x, y, z)
	local fix = 0

	if x > 0 then
		fix = 0.15
	end

	data.arrow:stop()
	data.arrow:animate(callback, data, x, y, z)
	data.bitmap:stop()
	data.bitmap:animate(callback, data, x, y, z)

	if data.bitmap_over ~= nil then
		data.bitmap_over:stop()
		data.bitmap_over:animate(callback, data, x, y, z)
		data.searching:stop()
		data.searching:animate(callback, data, x + fix, y, z)
		data.aiming:stop()
		data.aiming:animate(callback, data, x + fix, y, z)
	end
end

function HUDManager:_upd_suspition_waypoint_state(data, show_on_screen)
	if not show_on_screen then
		return
	end

	if data.bitmap_over ~= nil then
		if data.is_aiming then
			data.aiming:set_visible(true)
		else
			data.aiming:set_visible(false)
		end

		if data.is_searching then
			data.searching:set_visible(true)
		else
			data.searching:set_visible(false)
		end
	end
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()

function HUDManager:_update_suspicion_indicators(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, wp_cam_forward)

	if self._hud.suspicion_indicators then
		for id, suspicion_indicator in pairs(self._hud.suspicion_indicators) do
			suspicion_indicator:update_progress(t, dt)

			local parent_panel = suspicion_indicator:parent()
			local observer_position = suspicion_indicator:observer_position()

			mvector3.set(wp_pos, self._fullscreen_workspace:world_to_screen(cam, observer_position))
			mvector3.set(wp_dir, observer_position)
			mvector3.subtract(wp_dir, cam_pos)
			mvector3.set(wp_dir_normalized, wp_dir)
			mvector3.normalize(wp_dir_normalized)

			local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

			if suspicion_indicator:suspect() == "player" or HUDManager.DIFFERENT_SUSPICION_INDICATORS_FOR_TEAMMATES ~= true then
				if dot < 0 or parent_panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
					if suspicion_indicator:onscreen() then
						suspicion_indicator:go_offscreen()
						self:show_suspicion_indicator(id)

						suspicion_indicator.out_timer = 0 - (1 - suspicion_indicator.in_timer)
					end

					if self:need_to_init_suspicion_indicator(id) then
						self:initialize_suspicion_indicator(id, 1)
					end

					local direction = wp_onscreen_direction
					local panel_center_x, panel_center_y = parent_panel:center()

					mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
					mvector3.normalize(direction)

					local target_pos = wp_onscreen_target_pos

					mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * HUDSuspicionDirection.RADIUS, panel_center_y + mvector3.y(direction) * HUDSuspicionDirection.RADIUS, 0)

					if suspicion_indicator.out_timer ~= 1 then
						suspicion_indicator.out_timer = math.clamp(suspicion_indicator.out_timer + dt, 0, 1)

						mvector3.set(suspicion_indicator.current_position, math.bezier({
							suspicion_indicator.current_position,
							suspicion_indicator.current_position,
							target_pos,
							target_pos
						}, suspicion_indicator.out_timer))

						local current_alpha = math.bezier({
							suspicion_indicator:alpha(),
							suspicion_indicator:alpha(),
							0,
							0
						}, suspicion_indicator.out_timer)

						suspicion_indicator:set_alpha(current_alpha)
					else
						mvector3.set(suspicion_indicator.current_position, target_pos)
					end

					suspicion_indicator:set_center(mvector3.x(suspicion_indicator.current_position), mvector3.y(suspicion_indicator.current_position))
				else
					if not suspicion_indicator:onscreen() then
						suspicion_indicator:go_onscreen()
						managers.hud:hide_suspicion_indicator(id)

						suspicion_indicator.in_timer = 0 - (1 - suspicion_indicator.out_timer)
					end

					if self:need_to_init_suspicion_indicator(id) then
						self:initialize_suspicion_indicator(id, 0)
					end

					local alpha = suspicion_indicator:active_alpha()

					if dot > 0.99 then
						alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
					end

					suspicion_indicator:set_alpha(alpha)

					if suspicion_indicator.in_timer ~= 1 then
						suspicion_indicator.in_timer = math.clamp(suspicion_indicator.in_timer + dt, 0, 1)

						mvector3.set(suspicion_indicator.current_position, math.bezier({
							suspicion_indicator.current_position,
							suspicion_indicator.current_position,
							wp_pos,
							wp_pos
						}, suspicion_indicator.in_timer))

						local current_alpha = math.bezier({
							suspicion_indicator:alpha(),
							suspicion_indicator:alpha(),
							suspicion_indicator:active_alpha(),
							suspicion_indicator:active_alpha()
						}, suspicion_indicator.in_timer)

						suspicion_indicator:set_alpha(current_alpha)
					else
						mvector3.set(suspicion_indicator.current_position, wp_pos)
					end

					suspicion_indicator:set_center(mvector3.x(suspicion_indicator.current_position), mvector3.y(suspicion_indicator.current_position) - HUDManager.SUSPICION_INDICATOR_Y_OFFSET)
				end
			else
				if dot < 0 or parent_panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
					suspicion_indicator:set_alpha(0)
				else
					suspicion_indicator:set_alpha(suspicion_indicator:active_alpha())
				end

				mvector3.set(suspicion_indicator.current_position, wp_pos)
				suspicion_indicator:set_center(mvector3.x(suspicion_indicator.current_position), mvector3.y(suspicion_indicator.current_position) - HUDManager.SUSPICION_INDICATOR_Y_OFFSET)
			end
		end
	end
end

function HUDManager:_update_waypoints(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, wp_cam_forward)

	for id, data in pairs(self._hud.waypoints) do
		local show_on_screen = data.show_on_screen

		if data.lifetime then
			if data.lifetime <= 0 then
				self:remove_waypoint(id)
				Application:debug("[HUDManager:_update_waypoints] remove_waypoint with 0 lifetime")

				return
			else
				data.lifetime = data.lifetime - dt
			end
		end

		self:_upd_suspition_waypoint_state(data, show_on_screen)

		if show_on_screen == true then
			local panel = data.bitmap:parent()

			if data.state == "dirty" then
				-- Nothing
			end

			if data.state == "sneak_present" then
				if data.suspect == "teammate" then
					data.bitmap:set_color(data.bitmap:color():with_alpha(0))
					self:_upd_suspition_waypoint_alpha(data, 0)
				end

				data.current_position = Vector3(panel:center_x(), panel:center_y())

				data.bitmap:set_center_x(data.current_position.x)
				data.bitmap:set_center_y(data.current_position.y)
				mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
				data.bitmap:set_center(mvector3.x(wp_pos), mvector3.y(wp_pos) - HUDManager.OVERHEAD_Y_OFFSET)
				self:_upd_suspition_waypoint_pos(data)

				data.slot = nil
				data.current_scale = 1
				data.state = "present_ended"
				data.text_alpha = 0.5
				data.in_timer = 1
				data.target_scale = 1

				if data.distance then
					data.distance:set_visible(true)
				end
			elseif data.state == "present" then
				data.current_position = Vector3(panel:center_x(), panel:center_y())

				data.bitmap:set_center_x(data.current_position.x)
				data.bitmap:set_center_y(data.current_position.y)
				self:_upd_suspition_waypoint_pos(data)

				data.present_timer = data.present_timer - dt

				if data.present_timer <= 0 then
					data.slot = nil
					data.current_scale = 1
					data.state = "present_ended"
					data.text_alpha = 0.5
					data.in_timer = 1
					data.target_scale = 1

					if data.distance then
						data.distance:set_visible(true)
					end
				end
			else
				local pos_has_external_update = data.waypoint_type == "spotter" or data.waypoint_type == "suspicion" or data.waypoint_type == "unit_waypoint"
				data.position = not pos_has_external_update and data.unit and data.unit.position and data.unit:position() or data.position

				if data.position_offset_z then
					data.position = data.position:with_z(data.position.z + data.position_offset_z)
				end

				mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
				mvector3.set(wp_dir, data.position)
				mvector3.subtract(wp_dir, cam_pos)
				mvector3.set(wp_dir_normalized, wp_dir)
				mvector3.normalize(wp_dir_normalized)

				local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

				if data.suspect == "teammate" then
					if data.waypoint_type == "suspicion" and self:need_to_init_suspicion_indicator(data.unit:key()) then
						self:initialize_suspicion_indicator(data.unit:key(), 0)
					end

					local alpha = HUDManager.DEFAULT_ALPHA

					if dot > 0.99 then
						alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
					elseif dot < 0 then
						alpha = HUDManager.WAYPOINT_MAX_FADE
					end

					if data.bitmap:color().alpha ~= alpha then
						data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))
						self:_upd_suspition_waypoint_alpha(data, alpha)

						if data.distance then
							data.distance:set_color(data.distance:color():with_alpha(alpha))
						end

						if data.timer_gui then
							data.timer_gui:set_color(data.bitmap:color():with_alpha(alpha))
						end
					end

					data.bitmap:set_center(mvector3.x(wp_pos), mvector3.y(wp_pos) - HUDManager.OVERHEAD_Y_OFFSET)

					if data.bitmap_over then
						data.bitmap_over:set_texture_rect(data.stealth_over_rect[1], data.stealth_over_rect[2], data.stealth_over_rect[3], data.stealth_over_rect[4])
						data.bitmap_over:set_h(data.stealth_over_rect[4])
						data.bitmap_over:set_size(data.size.x * data.current_scale, data.stealth_over_rect[4] * data.current_scale)
						data.searching:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						data.aiming:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						self:_upd_suspition_waypoint_pos(data)
					end
				elseif dot < 0 or panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
					if data.state ~= "offscreen" then
						data.state = "offscreen"

						data.arrow:set_visible(true)
						data.bitmap:set_color(data.bitmap:color():with_alpha(HUDManager.DEFAULT_ALPHA))
						self:_upd_suspition_waypoint_alpha(data, HUDManager.DEFAULT_ALPHA)

						data.off_timer = 0 - (1 - data.in_timer)
						data.target_scale = 0.7

						if data.distance then
							data.distance:set_visible(false)
						end

						if data.timer_gui then
							data.timer_gui:set_visible(false)
						end

						if data.waypoint_type == "suspicion" then
							managers.hud:show_suspicion_indicator(data.unit:key())
							self:_animate_suspition_waypoint_alpha(data, callback(self, self, "_animate_alpha"), 0, 0.5, 0)
						end
					end

					if data.waypoint_type == "suspicion" and self:need_to_init_suspicion_indicator(data.unit:key()) then
						self:initialize_suspicion_indicator(data.unit:key(), 1)
					end

					local direction = wp_onscreen_direction
					local panel_center_x, panel_center_y = panel:center()

					mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
					mvector3.normalize(direction)

					local distance = 364
					local target_pos = wp_onscreen_target_pos

					mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

					data.off_timer = math.clamp(data.off_timer + dt / data.move_speed, 0, 1)

					if data.off_timer ~= 1 then
						mvector3.set(data.current_position, math.bezier({
							data.current_position,
							data.current_position,
							target_pos,
							target_pos
						}, data.off_timer))

						data.current_scale = math.bezier({
							data.current_scale,
							data.current_scale,
							data.target_scale,
							data.target_scale
						}, data.off_timer)

						data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)

						local current_alpha = math.bezier({
							data.bitmap:alpha(),
							data.bitmap:alpha(),
							HUDManager.WAYPOINT_MAX_FADE,
							HUDManager.WAYPOINT_MAX_FADE
						}, data.off_timer)

						data.bitmap:set_alpha(current_alpha)
					else
						mvector3.set(data.current_position, target_pos)
						data.bitmap:set_alpha(HUDManager.WAYPOINT_MAX_FADE)
					end

					data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

					if data.bitmap_over then
						data.bitmap_over:set_texture_rect(data.stealth_over_rect[1], data.stealth_over_rect[2], data.stealth_over_rect[3], data.stealth_over_rect[4])
						data.bitmap_over:set_h(data.stealth_over_rect[4])
						data.bitmap_over:set_size(data.size.x * data.current_scale, data.stealth_over_rect[4] * data.current_scale)
						data.searching:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						data.aiming:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						self:_upd_suspition_waypoint_pos(data)
					end

					data.arrow:set_center(mvector3.x(data.current_position) + direction.x * 30, mvector3.y(data.current_position) + direction.y * 30)

					local angle = math.X:angle(direction) * math.sign(direction.y)

					data.arrow:set_rotation(angle + 90)
				else
					if data.state == "offscreen" then
						data.state = "onscreen"

						data.arrow:set_visible(false)
						data.bitmap:set_color(data.bitmap:color():with_alpha(HUDManager.DEFAULT_ALPHA))
						self:_upd_suspition_waypoint_alpha(data, HUDManager.DEFAULT_ALPHA)

						data.in_timer = 0 - (1 - data.off_timer)
						data.target_scale = 1

						if data.distance then
							data.distance:set_visible(true)
						end

						if data.timer_gui then
							data.timer_gui:set_visible(true)
						end

						if data.waypoint_type == "suspicion" then
							managers.hud:hide_suspicion_indicator(data.unit:key())
							self:_animate_suspition_waypoint_alpha(data, callback(self, self, "_animate_alpha"), HUDManager.DEFAULT_ALPHA, 0.5, 1)
						end
					end

					if data.waypoint_type == "suspicion" and self:need_to_init_suspicion_indicator(data.unit:key()) then
						self:initialize_suspicion_indicator(data.unit:key(), 0)
					end

					local alpha = HUDManager.DEFAULT_ALPHA

					if dot > 0.99 then
						alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
						data.looking_directly = true
					else
						data.looking_directly = false
					end

					if data.bitmap:color().alpha ~= alpha then
						data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))
						self:_upd_suspition_waypoint_alpha(data, alpha)

						if data.distance then
							data.distance:set_color(data.distance:color():with_alpha(alpha))
						end

						if data.timer_gui then
							data.timer_gui:set_color(data.bitmap:color():with_alpha(alpha))
						end
					end

					if data.in_timer ~= 1 then
						data.in_timer = math.clamp(data.in_timer + dt / data.move_speed, 0, 1)

						mvector3.set(data.current_position, math.bezier({
							data.current_position,
							data.current_position,
							wp_pos,
							wp_pos
						}, data.in_timer))

						data.current_scale = math.bezier({
							data.current_scale,
							data.current_scale,
							data.target_scale,
							data.target_scale
						}, data.in_timer)

						data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)

						local current_alpha = math.bezier({
							data.bitmap:alpha(),
							data.bitmap:alpha(),
							1,
							1
						}, data.in_timer)

						data.bitmap:set_alpha(current_alpha)
					else
						mvector3.set(data.current_position, wp_pos)
						data.bitmap:set_alpha(1)
					end

					data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position) - HUDManager.OVERHEAD_Y_OFFSET)

					if data.bitmap_over then
						data.bitmap_over:set_texture_rect(data.stealth_over_rect[1], data.stealth_over_rect[2], data.stealth_over_rect[3], data.stealth_over_rect[4])
						data.bitmap_over:set_h(data.stealth_over_rect[4])
						data.bitmap_over:set_size(data.size.x * data.current_scale, data.stealth_over_rect[4] * data.current_scale)
						data.searching:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						data.aiming:set_size(data.size.x * data.current_scale, data.size.y / 2 * data.current_scale)
						self:_upd_suspition_waypoint_pos(data)
					end

					if data.distance then
						local length = wp_dir:length()

						data.distance:set_text(string.format("%.0f", length / 100) .. "m")
						data.distance:set_center_x(data.bitmap:center_x())
						data.distance:set_top(data.bitmap:bottom())
					end
				end
			end

			if data.timer_gui then
				data.timer_gui:set_center_x(data.bitmap:center_x())
				data.timer_gui:set_bottom(data.bitmap:top())

				if data.pause_timer == 0 then
					data.timer = data.timer - dt
					local text = data.timer < 0 and "00" or (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer)

					data.timer_gui:set_text(text)
				end
			end
		end
	end
end

function HUDManager:show_waypoint(icon, data, new_alpha, duration)
end

function HUDManager:hide_waypoint(icon, data, new_alpha, duration)
end

function HUDManager:_animate_alpha(icon, data, new_alpha, duration, delay)
	local t = 0
	local dt = nil
	local starting_alpha = icon:color().a
	local change = new_alpha - starting_alpha

	while t < duration + delay do
		dt = coroutine.yield()
		t = t + dt

		if data.looking_directly then
			break
		end

		if delay <= t then
			local curr_alpha = Easing.quartic_in_out(t, starting_alpha, change, duration)

			icon:set_color(icon:color():with_alpha(curr_alpha))

			if duration <= t then
				icon:set_color(icon:color():with_alpha(starting_alpha + change))
			end
		end
	end
end

function HUDManager:set_aiming_icon(id, status)
	local data = self._hud.waypoints[id]

	if not data then
		print("[HUDManager:set_aiming_icon] Attempt to change no existant waypoint:", id)

		return
	end

	data.is_aiming = status

	if Network:is_server() and managers.network:session() then
		managers.network:session():send_to_peers("sync_suspicion_icon", data.unit, "aim", status)
	end
end

function HUDManager:set_investigate_icon(id, status)
	local data = self._hud.waypoints[id]

	if not data then
		Application:error("[HUDManager:set_investigate_icon] Attempt to change no existant waypoint:", id)
	end

	data.is_searching = status

	if Network:is_server() and managers.network:session() then
		managers.network:session():send_to_peers("sync_suspicion_icon", data.unit, "investigate", status)
	end
end

function HUDManager:set_stealth_meter(id, target_id, progress)
	local suspicion_indicator = self._hud.suspicion_indicators[id]

	if not suspicion_indicator then
		Application:error("[HUDManager:set_stealth_meter] Attempt to set progress to a non-existant suspicion indicator; id: " .. tostring(id), "Current suspicion indicators are " .. inspect(self._hud.suspicion_indicators))

		return
	end

	local max_progress = self:_set_progress_for_target(id, target_id, progress)

	suspicion_indicator:set_progress(max_progress)
end

function HUDManager:_set_progress_for_target(id, target_id, progress)
	self._progress_target[id] = self._progress_target[id] or {}
	self._progress_target[id][target_id] = math.clamp(progress, 0, 1)
	local max = 0

	for _, p in pairs(self._progress_target[id]) do
		if max < p then
			max = p
		end
	end

	return max
end

function HUDManager:_upd_suspition_progress(data, dt)
	local old_h = data.stealth_over_rect and data.stealth_over_rect[4] or 0

	if data.stealth_target_h then
		local distance = math.abs(data.stealth_target_h - old_h)

		if distance > 0.1 then
			local lerp_speed = distance / 2
			local h = math.lerp(old_h, data.stealth_target_h, lerp_speed * dt)
			data.stealth_over_rect[2] = 32 - h
			data.stealth_over_rect[4] = h
		end
	end
end

function HUDManager:reset_player_hpbar()
	local crim_entry = managers.criminals:character_static_data_by_name(managers.criminals:local_character_name())

	if not crim_entry then
		return
	end

	local color_id = managers.network:session():local_peer():id()

	self:set_teammate_name(4, managers.network:session():local_peer():name())
end

function HUDManager:_create_pd_progress()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)

	if not hud then
		return
	end

	self._pd2_hud_interaction = HUDInteraction:new(hud)
end

function HUDManager:pd_start_progress(current, total, msg, icon_id)
	self._pd2_hud_interaction:animate_progress(total)
end

function HUDManager:pd_cancel_progress()
	self._pd2_hud_interaction:hide_interaction_bar(false)
end

function HUDManager:pd_complete_progress()
	self._pd2_hud_interaction:hide_interaction_bar(true)
end

function HUDManager:on_simulation_ended()
	self:remove_updator("point_of_no_return")
	self:end_assault()
	self:_destroy_comm_wheel()
	self._hud_hit_direction:clean_up()
	self._hud_suspicion_direction:clean_up()

	if self._black_screen then
		self._black_screen:clean_up()
	end

	if self._toast_notification then
		self._toast_notification:cleanup()

		self._toast_notification = nil
	end

	if self._hud_objectives then
		self._hud_objectives:clean_up()
	end

	managers.network.account:remove_overlay_listener("[HUDManager] hide_tab_screen")
end

function HUDManager:clean_up()
	self:clear_waypoints()
end

function HUDManager:debug_show_coordinates()
	if self._debug then
		return
	end

	self._debug = {
		ws = Overlay:newgui():create_screen_workspace()
	}
	self._debug.panel = self._debug.ws:panel()
	self._debug.coord = self._debug.panel:text({
		text = "",
		name = "debug_coord",
		y = 14,
		font_size = 14,
		x = 14,
		layer = 2000,
		font = tweak_data.gui.fonts.din_compressed_outlined_18,
		color = Color.white
	})
end

function HUDManager:debug_hide_coordinates()
	if not self._debug then
		return
	end

	Overlay:newgui():destroy_workspace(self._debug.ws)

	self._debug = nil
end

function HUDManager:save(d)
	local state = {
		waypoints = {},
		in_assault = self._hud.in_assault,
		teammate_timers = {}
	}

	for id, data in pairs(self._hud.waypoints) do
		if not data.no_sync then
			state.waypoints[id] = {}
			state.waypoints[id] = data.init_data
			state.waypoints[id].timer = data.timer
			state.waypoints[id].pause_timer = data.pause_timer
			state.waypoints[id].unit = data.unit
		end
	end

	for id, data in pairs(self._teammate_panels) do
		if data._timer_current and data._timer_current > 0 then
			local name = nil

			for _, char in pairs(managers.criminals:characters()) do
				if char.data.panel_id and char.data.panel_id == data._id or data._peer_id and char.peer_id and data._peer_id == char.peer_id or data._id == HUDManager.PLAYER_PANEL and char.peer_id == 1 then
					name = char.name
				end
			end

			if name then
				state.teammate_timers[name] = {
					timer_current = data._timer_current,
					timer_total = data._timer_total
				}
			end
		end
	end

	d.HUDManager = state
end

function HUDManager:load(data)
	local state = data.HUDManager

	for id, init_data in pairs(state.waypoints) do
		if init_data.waypoint_origin ~= "waypoint_extension" then
			self:add_waypoint(id, init_data)
		end
	end

	self._teammate_timers = state.teammate_timers

	if state.in_assault then
		self:sync_start_assault()
	end
end

require("lib/managers/HUDManagerPD2")
