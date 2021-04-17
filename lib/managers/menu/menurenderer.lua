core:import("CoreMenuRenderer")
require("lib/managers/menu/MenuNodeGui")
require("lib/managers/menu/raid_menu/MenuNodeGuiRaid")
require("lib/managers/menu/renderers/MenuNodeBaseGui")
require("lib/managers/menu/renderers/MenuNodeTableGui")
require("lib/managers/menu/renderers/MenuNodeStatsGui")
require("lib/managers/menu/renderers/MenuNodeCreditsGui")
require("lib/managers/menu/renderers/MenuNodeButtonLayoutGui")
require("lib/managers/menu/renderers/MenuNodeHiddenGui")
require("lib/managers/menu/renderers/MenuNodeUpdatesGui")
require("lib/managers/menu/renderers/MenuNodeReticleSwitchGui")
require("lib/managers/menu/renderers/MenuNodeJukeboxGui")
require("lib/managers/menu/renderers/MenuModInfoGui")

MenuRenderer = MenuRenderer or class(CoreMenuRenderer.Renderer)

-- Lines 18-22
function MenuRenderer:init(logic, ...)
	MenuRenderer.super.init(self, logic, ...)

	self._sound_source = SoundDevice:create_source("MenuRenderer")
end

-- Lines 24-48
function MenuRenderer:show_node(node)
	local gui_class = MenuNodeGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	local parameters = {
		marker_alpha = 1,
		align = "left",
		row_item_blend_mode = "normal",
		to_upper = true,
		font = tweak_data.menu.pd2_medium_font,
		row_item_color = tweak_data.menu.default_font_row_item_color,
		row_item_hightlight_color = tweak_data.menu.default_hightlight_row_item_color,
		font_size = tweak_data.menu.pd2_medium_font_size,
		node_gui_class = gui_class,
		spacing = node:parameters().spacing,
		marker_color = tweak_data.screen_colors.button_stage_3:with_alpha(1)
	}

	MenuRenderer.super.show_node(self, node, parameters)
end

-- Lines 50-58
function MenuRenderer:open(...)
	MenuRenderer.super.open(self, ...)

	self._menu_stencil_align = "left"
	self._menu_stencil_default_image = "guis/textures/empty"
	self._menu_stencil_image = self._menu_stencil_default_image

	self._create_blackborders()
end

-- Lines 61-66
function MenuRenderer.destroy_blackborder_workspace_instance()
	if alive(Global.blackborder_workspace) then
		Overlay:gui():destroy_workspace(Global.blackborder_workspace)
	end

	Global.blackborder_workspace = nil
end

-- Lines 68-78
function MenuRenderer.get_blackborder_workspace_instance()
	if not Global.blackborder_workspace then
		Global.blackborder_workspace = managers.gui_data:create_fullscreen_workspace()

		Global.blackborder_workspace:panel():rect({
			name = "top_border",
			layer = 1000,
			color = Color.black
		})
		Global.blackborder_workspace:panel():rect({
			name = "bottom_border",
			layer = 1000,
			color = Color.black
		})
		Global.blackborder_workspace:panel():rect({
			name = "left_border",
			layer = 1000,
			color = Color.black
		})
		Global.blackborder_workspace:panel():rect({
			name = "right_border",
			layer = 1000,
			color = Color.black
		})
	end

	return Global.blackborder_workspace
end

-- Lines 80-86
function MenuRenderer:close(...)
	MenuRenderer.super.close(self, ...)

	if managers.raid_menu:ct_open_menus() == 1 then
		MenuRenderer._remove_blackborders()
	end
end

-- Lines 88-91
function MenuRenderer._remove_blackborders()
	local blackborder_workspace = MenuRenderer.get_blackborder_workspace_instance()

	blackborder_workspace:panel():set_visible(false)
end

-- Lines 93-130
function MenuRenderer._create_blackborders()
	Application:debug("[MenuRenderer][_create_blackborders]")

	local blackborder_workspace = MenuRenderer.get_blackborder_workspace_instance()

	blackborder_workspace:panel():set_visible(true)

	local top_border = blackborder_workspace:panel():child("top_border")
	local bottom_border = blackborder_workspace:panel():child("bottom_border")
	local left_border = blackborder_workspace:panel():child("left_border")
	local right_border = blackborder_workspace:panel():child("right_border")
	local width = blackborder_workspace:panel():w()
	local height = blackborder_workspace:panel():h()
	local base_resolution = clone(tweak_data.gui.base_resolution)
	local base_aspect_ratio = base_resolution.x / base_resolution.y
	base_resolution.y = width / base_aspect_ratio
	base_resolution.x = height * base_aspect_ratio
	local border_w = (width - base_resolution.x) / 2
	local border_h = (height - base_resolution.y) / 2

	top_border:set_position(-1, -1)
	top_border:set_size(width + 2, border_h + 2)
	top_border:set_visible(border_h > 0)
	bottom_border:set_position(-1, math.ceil(border_h) + base_resolution.y - 1)
	bottom_border:set_size(width + 2, border_h + 2)
	bottom_border:set_visible(border_h > 0)
	left_border:set_position(-1, -1)
	left_border:set_size(border_w + 2, height + 2)
	left_border:set_visible(border_w > 0)
	right_border:set_position(math.floor(border_w) + base_resolution.x - 1, -1)
	right_border:set_size(border_w + 2, height + 2)
	right_border:set_visible(border_w > 0)
end

-- Lines 132-135
function MenuRenderer:update(t, dt)
	MenuRenderer.super.update(self, t, dt)
end

local mugshot_stencil = {
	random = {
		"bg_lobby_fullteam",
		65
	},
	undecided = {
		"bg_lobby_fullteam",
		65
	},
	american = {
		"bg_hoxton",
		65
	},
	german = {
		"bg_wolf",
		55
	},
	russian = {
		"bg_dallas",
		65
	},
	spanish = {
		"bg_chains",
		60
	}
}

-- Lines 146-149
function MenuRenderer:highlight_item(item, ...)
	MenuRenderer.super.highlight_item(self, item, ...)
	self:post_event("highlight")
end

-- Lines 151-175
function MenuRenderer:trigger_item(item)
	MenuRenderer.super.trigger_item(self, item)

	if item and item:visible() and item:parameters().sound ~= "false" then
		local item_type = item:type()

		if item_type == "" then
			self:post_event("menu_enter")
		elseif item_type == "toggle" then
			if item:value() == "on" then
				self:post_event("box_tick")
			else
				self:post_event("box_untick")
			end
		elseif item_type == "slider" then
			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				-- Nothing
			end
		elseif item_type == "multi_choice" then
			-- Nothing
		end
	end
end

-- Lines 177-179
function MenuRenderer:post_event(event)
	self._sound_source:post_event(event)
end

-- Lines 181-186
function MenuRenderer:navigate_back()
	MenuRenderer.super.navigate_back(self)
	self:active_node_gui():update_item_icon_visibility()
	self:post_event("menu_exit")
end

-- Lines 188-195
function MenuRenderer:resolution_changed(...)
	MenuRenderer.super.resolution_changed(self, ...)
	self._create_blackborders()

	local active_node_gui = self:active_node_gui()

	if active_node_gui and active_node_gui.update_item_icon_visibility then
		self:active_node_gui():update_item_icon_visibility()
	end
end

-- Lines 198-212
function MenuRenderer:current_menu_text(topic_id)
	local ids = {}

	for i, node_gui in ipairs(self._node_gui_stack) do
		table.insert(ids, node_gui.node:parameters().topic_id)
	end

	table.insert(ids, topic_id)

	local s = ""

	for i, id in ipairs(ids) do
		s = s .. managers.localization:text(id)
		s = s .. (i < #ids and " > " or "")
	end

	return s
end

-- Lines 215-217
function MenuRenderer:accept_input(accept)
	managers.menu_component:accept_input(accept)
end

-- Lines 219-228
function MenuRenderer:input_focus()
	if self:active_node_gui() and self:active_node_gui().input_focus then
		local input_focus = self:active_node_gui():input_focus()

		if input_focus then
			return input_focus
		end
	end

	return managers.menu_component:input_focus()
end

-- Lines 230-238
function MenuRenderer:mouse_pressed(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_pressed and self:active_node_gui():mouse_pressed(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_pressed(o, button, x, y) then
		return true
	end
end

-- Lines 240-250
function MenuRenderer:mouse_released(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_released and self:active_node_gui():mouse_released(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_released(o, button, x, y) then
		return true
	end

	return false
end

-- Lines 252-258
function MenuRenderer:mouse_clicked(o, button, x, y)
	if managers.menu_component:mouse_clicked(o, button, x, y) then
		return true
	end

	return false
end

-- Lines 260-266
function MenuRenderer:mouse_double_click(o, button, x, y)
	if managers.menu_component:mouse_double_click(o, button, x, y) then
		return true
	end

	return false
end

-- Lines 268-288
function MenuRenderer:mouse_moved(o, x, y)
	local wanted_pointer = "arrow"

	if self:active_node_gui() and self:active_node_gui().mouse_moved and managers.menu_component:input_focus() ~= true then
		local used, pointer = self:active_node_gui():mouse_moved(o, x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	local used, pointer = managers.menu_component:mouse_moved(o, x, y)
	wanted_pointer = pointer or wanted_pointer

	if used then
		return true, wanted_pointer
	end

	return false, wanted_pointer
end

-- Lines 290-292
function MenuRenderer:scroll_up()
	return managers.menu_component:scroll_up()
end

-- Lines 294-296
function MenuRenderer:scroll_down()
	return managers.menu_component:scroll_down()
end

-- Lines 298-303
function MenuRenderer:move_up()
	if self:active_node_gui() and self:active_node_gui().move_up and self:active_node_gui():move_up() then
		return true
	end

	return managers.menu_component:move_up()
end

-- Lines 305-310
function MenuRenderer:move_down()
	if self:active_node_gui() and self:active_node_gui().move_down and self:active_node_gui():move_down() then
		return true
	end

	return managers.menu_component:move_down()
end

-- Lines 312-317
function MenuRenderer:move_left()
	if self:active_node_gui() and self:active_node_gui().move_left and self:active_node_gui():move_left() then
		return true
	end

	return managers.menu_component:move_left()
end

-- Lines 319-324
function MenuRenderer:move_right()
	if self:active_node_gui() and self:active_node_gui().move_right and self:active_node_gui():move_right() then
		return true
	end

	return managers.menu_component:move_right()
end

-- Lines 326-331
function MenuRenderer:scroll_up()
	if self:active_node_gui() and self:active_node_gui().scroll_up and self:active_node_gui():scroll_up() then
		return true
	end

	return managers.menu_component:scroll_up()
end

-- Lines 333-338
function MenuRenderer:scroll_down()
	if self:active_node_gui() and self:active_node_gui().scroll_down and self:active_node_gui():scroll_down() then
		return true
	end

	return managers.menu_component:scroll_down()
end

-- Lines 340-345
function MenuRenderer:scroll_left()
	if self:active_node_gui() and self:active_node_gui().scroll_left and self:active_node_gui():scroll_left() then
		return true
	end

	return managers.menu_component:scroll_left()
end

-- Lines 347-352
function MenuRenderer:scroll_right()
	if self:active_node_gui() and self:active_node_gui().scroll_right and self:active_node_gui():scroll_right() then
		return true
	end

	return managers.menu_component:scroll_right()
end

-- Lines 354-359
function MenuRenderer:next_page()
	if self:active_node_gui() and self:active_node_gui().next_page and self:active_node_gui():next_page() then
		return true
	end

	return managers.menu_component:next_page()
end

-- Lines 361-366
function MenuRenderer:previous_page()
	if self:active_node_gui() and self:active_node_gui().previous_page and self:active_node_gui():previous_page() then
		return true
	end

	return managers.menu_component:previous_page()
end

-- Lines 368-373
function MenuRenderer:confirm_pressed()
	if self:active_node_gui() and self:active_node_gui().confirm_pressed and self:active_node_gui():confirm_pressed() then
		return true
	end

	return managers.menu_component:confirm_pressed()
end

-- Lines 375-377
function MenuRenderer:back_pressed()
	return managers.menu_component:back_pressed()
end

-- Lines 379-384
function MenuRenderer:special_btn_pressed(...)
	if self:active_node_gui() and self:active_node_gui().special_btn_pressed and self:active_node_gui():special_btn_pressed(...) then
		return true
	end

	return managers.menu_component:special_btn_pressed(...)
end

-- Lines 389-408
function MenuRenderer:ws_test()
	if alive(self._test_safe) then
		Overlay:gui():destroy_workspace(self._test_safe)
	end

	if alive(self._test_full) then
		Overlay:gui():destroy_workspace(self._test_full)
	end

	self._test_safe = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_workspace(self._test_safe)

	self._test_full = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_fullscreen_workspace(self._test_full)

	local x = 150
	local y = 200
	local fx, fy = managers.gui_data:safe_to_full(x, y)
	local safe = self._test_safe:panel():rect({
		h = 48,
		w = 48,
		orientation = "vertical",
		layer = 0,
		x = x,
		y = y,
		color = Color.green
	})
	local full = self._test_full:panel():rect({
		h = 48,
		w = 48,
		orientation = "vertical",
		layer = 0,
		x = fx,
		y = fy,
		color = Color.red
	})
end
