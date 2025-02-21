WalletGuiObject = WalletGuiObject or class()

function WalletGuiObject:init(panel)
	WalletGuiObject.set_wallet(panel)
end

function WalletGuiObject.set_wallet(panel, layer)
	WalletGuiObject.remove_wallet()

	Global.wallet_panel = panel:panel({
		name = "WalletGuiObject",
		layer = layer or 0
	})
	local money_icon = Global.wallet_panel:bitmap({
		name = "wallet_money_icon",
		texture = "guis/textures/pd2/shared_wallet_symbol"
	})
	local level_icon = Global.wallet_panel:bitmap({
		name = "wallet_level_icon",
		texture = "guis/textures/pd2/shared_level_symbol"
	})
	local skillpoint_icon = Global.wallet_panel:bitmap({
		name = "wallet_skillpoint_icon",
		texture = "guis/textures/pd2/shared_skillpoint_symbol"
	})
	local money_text = Global.wallet_panel:text({
		name = "wallet_money_text",
		text = "",
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})
	local level_text = Global.wallet_panel:text({
		name = "wallet_level_text",
		text = tostring(managers.experience:current_level()),
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})
	local skillpoint_text = Global.wallet_panel:text({
		name = "wallet_skillpoint_text",
		text = tostring(0),
		font_size = tweak_data.menu.pd2_small_font_size,
		font = tweak_data.menu.pd2_small_font,
		color = tweak_data.screen_colors.text
	})
	local mw, mh = WalletGuiObject.make_fine_text(money_text)
	local lw, lh = WalletGuiObject.make_fine_text(level_text)
	local sw, sh = WalletGuiObject.make_fine_text(skillpoint_text)

	money_icon:set_leftbottom(2, Global.wallet_panel:h() - 2)
	money_text:set_left(money_icon:right() + 2)
	money_text:set_center_y(money_icon:center_y())
	money_text:set_y(math.round(money_text:y()))
	level_icon:set_leftbottom(money_text:right() + 10, Global.wallet_panel:h() - 2)
	level_text:set_left(level_icon:right() + 2)
	level_text:set_center_y(level_icon:center_y())
	level_text:set_y(math.round(level_text:y()))
	skillpoint_icon:set_leftbottom(level_text:right() + 10, Global.wallet_panel:h() - 2)
	skillpoint_text:set_left(skillpoint_icon:right() + 2)
	skillpoint_text:set_center_y(skillpoint_icon:center_y())
	skillpoint_text:set_y(math.round(skillpoint_text:y()))

	local max_w = skillpoint_text:right()
	local bg_blur = Global.wallet_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		w = 0,
		render_template = "VertexColorTexturedBlur3D",
		layer = -1,
		name = "bg_blur",
		h = 0
	})

	bg_blur:set_leftbottom(0, Global.wallet_panel:h())
	bg_blur:set_w(max_w + 2)
	bg_blur:set_h(Global.wallet_panel:h() - money_icon:top())
	WalletGuiObject.set_object_visible("wallet_skillpoint_icon", false)
	WalletGuiObject.set_object_visible("wallet_skillpoint_text", false)
end

function WalletGuiObject.refresh()
	if Global.wallet_panel then
		local money_icon = Global.wallet_panel:child("wallet_money_icon")
		local level_icon = Global.wallet_panel:child("wallet_level_icon")
		local skillpoint_icon = Global.wallet_panel:child("wallet_skillpoint_icon")
		local money_text = Global.wallet_panel:child("wallet_money_text")
		local level_text = Global.wallet_panel:child("wallet_level_text")
		local skillpoint_text = Global.wallet_panel:child("wallet_skillpoint_text")

		money_text:set_text("")
		WalletGuiObject.make_fine_text(money_text)
		money_icon:set_leftbottom(2, Global.wallet_panel:h() - 2)
		money_text:set_left(money_icon:right() + 2)
		money_text:set_center_y(money_icon:center_y())
		money_text:set_y(math.round(money_text:y()))
		level_text:set_text(tostring(managers.experience:current_level()))
		WalletGuiObject.make_fine_text(level_text)
		level_icon:set_leftbottom(money_text:right() + 10, Global.wallet_panel:h() - 2)
		level_text:set_left(level_icon:right() + 2)
		level_text:set_center_y(level_icon:center_y())
		level_text:set_y(math.round(level_text:y()))
		skillpoint_text:set_text(tostring(0))
		WalletGuiObject.make_fine_text(skillpoint_text)
		skillpoint_icon:set_leftbottom(level_text:right() + 10, Global.wallet_panel:h() - 2)
		skillpoint_text:set_left(skillpoint_icon:right() + 2)
		skillpoint_text:set_center_y(skillpoint_icon:center_y())
		skillpoint_text:set_y(math.round(skillpoint_text:y()))
		WalletGuiObject.set_object_visible("wallet_skillpoint_icon", false)
		WalletGuiObject.set_object_visible("wallet_skillpoint_text", false)
	end
end

function WalletGuiObject.make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))

	return w, h
end

function WalletGuiObject.set_layer(layer)
	if not alive(Global.wallet_panel) then
		return
	end

	Global.wallet_panel:set_layer(layer)
end

function WalletGuiObject.move_wallet(mx, my)
	if not alive(Global.wallet_panel) then
		return
	end

	Global.wallet_panel:move(mx, my)
end

function WalletGuiObject.set_object_visible(object, visible)
	if not alive(Global.wallet_panel) then
		return
	end

	Global.wallet_panel:child(object):set_visible(visible)

	local bg_blur = Global.wallet_panel:child("bg_blur")

	if Global.wallet_panel:child("wallet_skillpoint_icon"):visible() then
		bg_blur:set_w(Global.wallet_panel:child("wallet_skillpoint_text"):right())
	elseif Global.wallet_panel:child("wallet_level_icon"):visible() then
		bg_blur:set_w(Global.wallet_panel:child("wallet_level_text"):right())
	elseif Global.wallet_panel:child("wallet_money_icon"):visible() then
		bg_blur:set_w(Global.wallet_panel:child("wallet_money_text"):right())
	else
		bg_blur:set_w(0)
	end

	bg_blur:set_leftbottom(Global.wallet_panel:child("wallet_money_icon"):leftbottom())
end

function WalletGuiObject.remove_wallet()
	if not alive(Global.wallet_panel) or not alive(Global.wallet_panel:parent()) then
		Global.wallet_panel = nil

		return
	end

	Global.wallet_panel:parent():remove(Global.wallet_panel)

	Global.wallet_panel = nil
end

function WalletGuiObject.close_wallet(panel)
	if not alive(Global.wallet_panel) or not alive(Global.wallet_panel:parent()) then
		Global.wallet_panel = nil

		return
	end

	if panel ~= Global.wallet_panel:parent() then
		return
	end

	panel:remove(Global.wallet_panel)

	Global.wallet_panel = nil
end
