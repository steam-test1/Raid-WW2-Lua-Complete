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

function MenuRenderer:init(logic, ...)
	MenuRenderer.super.init(self, logic, ...)
end

function MenuRenderer:show_node(node)
	local gui_class = MenuNodeGui

	if node:parameters().gui_class then
		gui_class = CoreSerialize.string_to_classtable(node:parameters().gui_class)
	end

	local parameters = {
		to_upper = true,
		row_item_color = nil,
		align = "left",
		font = nil,
		marker_color = nil,
		marker_alpha = 1,
		spacing = nil,
		node_gui_class = nil,
		font_size = nil,
		row_item_blend_mode = "normal",
		row_item_hightlight_color = nil,
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

function MenuRenderer:open(...)
	MenuRenderer.super.open(self, ...)

	self._menu_stencil_align = "left"
	self._menu_stencil_default_image = "guis/textures/empty"
	self._menu_stencil_image = self._menu_stencil_default_image
end

function MenuRenderer:close(...)
	MenuRenderer.super.close(self, ...)
end

function MenuRenderer:update(t, dt)
	MenuRenderer.super.update(self, t, dt)
end

function MenuRenderer:highlight_item(item, ...)
	MenuRenderer.super.highlight_item(self, item, ...)
end

function MenuRenderer:trigger_item(item)
	MenuRenderer.super.trigger_item(self, item)
end

function MenuRenderer:navigate_back()
	MenuRenderer.super.navigate_back(self)
	self:active_node_gui():update_item_icon_visibility()
end

function MenuRenderer:resolution_changed(...)
	MenuRenderer.super.resolution_changed(self, ...)

	local active_node_gui = self:active_node_gui()

	if active_node_gui and active_node_gui.update_item_icon_visibility then
		self:active_node_gui():update_item_icon_visibility()
	end
end

function MenuRenderer:accept_input(accept)
	managers.menu_component:accept_input(accept)
end

function MenuRenderer:input_focus()
	if self:active_node_gui() and self:active_node_gui().input_focus then
		local input_focus = self:active_node_gui():input_focus()

		if input_focus then
			return input_focus
		end
	end

	return managers.menu_component:input_focus()
end

function MenuRenderer:mouse_pressed(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_pressed and self:active_node_gui():mouse_pressed(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_pressed(o, button, x, y) then
		return true
	end
end

function MenuRenderer:mouse_released(o, button, x, y)
	if self:active_node_gui() and self:active_node_gui().mouse_released and self:active_node_gui():mouse_released(button, x, y) then
		return true
	end

	if managers.menu_component:mouse_released(o, button, x, y) then
		return true
	end

	return false
end

function MenuRenderer:mouse_clicked(o, button, x, y)
	if managers.menu_component:mouse_clicked(o, button, x, y) then
		return true
	end

	return false
end

function MenuRenderer:mouse_double_click(o, button, x, y)
	if managers.menu_component:mouse_double_click(o, button, x, y) then
		return true
	end

	return false
end

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

function MenuRenderer:scroll_up()
	return managers.menu_component:scroll_up()
end

function MenuRenderer:scroll_down()
	return managers.menu_component:scroll_down()
end

function MenuRenderer:move_up()
	if self:active_node_gui() and self:active_node_gui().move_up and self:active_node_gui():move_up() then
		return true
	end

	return managers.menu_component:move_up()
end

function MenuRenderer:move_down()
	if self:active_node_gui() and self:active_node_gui().move_down and self:active_node_gui():move_down() then
		return true
	end

	return managers.menu_component:move_down()
end

function MenuRenderer:move_left()
	if self:active_node_gui() and self:active_node_gui().move_left and self:active_node_gui():move_left() then
		return true
	end

	return managers.menu_component:move_left()
end

function MenuRenderer:move_right()
	if self:active_node_gui() and self:active_node_gui().move_right and self:active_node_gui():move_right() then
		return true
	end

	return managers.menu_component:move_right()
end

function MenuRenderer:scroll_up()
	if self:active_node_gui() and self:active_node_gui().scroll_up and self:active_node_gui():scroll_up() then
		return true
	end

	return managers.menu_component:scroll_up()
end

function MenuRenderer:scroll_down()
	if self:active_node_gui() and self:active_node_gui().scroll_down and self:active_node_gui():scroll_down() then
		return true
	end

	return managers.menu_component:scroll_down()
end

function MenuRenderer:scroll_left()
	if self:active_node_gui() and self:active_node_gui().scroll_left and self:active_node_gui():scroll_left() then
		return true
	end

	return managers.menu_component:scroll_left()
end

function MenuRenderer:scroll_right()
	if self:active_node_gui() and self:active_node_gui().scroll_right and self:active_node_gui():scroll_right() then
		return true
	end

	return managers.menu_component:scroll_right()
end

function MenuRenderer:next_page()
	if self:active_node_gui() and self:active_node_gui().next_page and self:active_node_gui():next_page() then
		return true
	end

	return managers.menu_component:next_page()
end

function MenuRenderer:previous_page()
	if self:active_node_gui() and self:active_node_gui().previous_page and self:active_node_gui():previous_page() then
		return true
	end

	return managers.menu_component:previous_page()
end

function MenuRenderer:confirm_pressed()
	if self:active_node_gui() and self:active_node_gui().confirm_pressed and self:active_node_gui():confirm_pressed() then
		return true
	end

	return managers.menu_component:confirm_pressed()
end

function MenuRenderer:back_pressed()
	return managers.menu_component:back_pressed()
end

function MenuRenderer:special_btn_pressed(...)
	if self:active_node_gui() and self:active_node_gui().special_btn_pressed and self:active_node_gui():special_btn_pressed(...) then
		return true
	end

	return managers.menu_component:special_btn_pressed(...)
end

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
		w = 48,
		h = 48,
		color = nil,
		orientation = "vertical",
		layer = 0,
		y = nil,
		x = nil,
		x = x,
		y = y,
		color = Color.green
	})
	local full = self._test_full:panel():rect({
		w = 48,
		h = 48,
		color = nil,
		orientation = "vertical",
		layer = 0,
		y = nil,
		x = nil,
		x = fx,
		y = fy,
		color = Color.red
	})
end
