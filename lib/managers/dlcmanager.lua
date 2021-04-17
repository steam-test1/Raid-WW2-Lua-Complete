DLCManager = DLCManager or class()
DLCManager.PLATFORM_CLASS_MAP = {}

-- Lines 7-10
function DLCManager:new(...)
	local platform = SystemInfo:platform()

	return (self.PLATFORM_CLASS_MAP[platform:key()] or GenericDLCManager):new(...)
end

GenericDLCManager = GenericDLCManager or class()

-- Lines 14-19
function GenericDLCManager:init()
	self._debug_on = Application:production_build()

	self:_set_dlc_save_table()
end

-- Lines 21-25
function GenericDLCManager:_set_dlc_save_table()
	if not Global.dlc_save then
		Global.dlc_save = {
			packages = {}
		}
	end
end

-- Lines 27-30
function GenericDLCManager:setup()
	self:_modify_locked_content()
	self:_create_achievement_locked_content_table()
end

-- Lines 32-54
function GenericDLCManager:_create_achievement_locked_content_table()
	self._achievement_locked_content = {}
	self._dlc_locked_content = {}

	for name, dlc in pairs(tweak_data.dlc.descriptions) do
		local content = dlc.content

		if content then
			local loot_drops = content.loot_drops

			if loot_drops then
				for _, loot_drop in ipairs(loot_drops) do
					if loot_drop.type_items then
						if dlc.achievement_id then
							self._achievement_locked_content[loot_drop.type_items] = self._achievement_locked_content[loot_drop.type_items] or {}
							self._achievement_locked_content[loot_drop.type_items][loot_drop.item_entry] = name
						else
							self._dlc_locked_content[loot_drop.type_items] = self._dlc_locked_content[loot_drop.type_items] or {}
							self._dlc_locked_content[loot_drop.type_items][loot_drop.item_entry] = name
						end
					end
				end
			end
		end
	end
end

-- Lines 58-104
function GenericDLCManager:_modify_locked_content()
	if SystemInfo:platform() == Idstring("WIN32") then
		return
	end

	-- Lines 63-80
	local function _modify_loot_drop(loot_drop)
		local entry = tweak_data.blackmarket[loot_drop.type_items] and tweak_data.blackmarket[loot_drop.type_items][loot_drop.item_entry]

		if entry then
			if not entry.pc and (not entry.pcs or #entry.pcs == 0) then
				entry.pcs = {
					10,
					20,
					30,
					40
				}

				if loot_drop.type_items == "weapon_mods" then
					tweak_data.weapon.factory.parts[loot_drop.item_entry].pcs = {
						10,
						20,
						30,
						40
					}
				end
			end
		else
			print(" -- entry not exists")
		end
	end

	for name, dlc in pairs(tweak_data.dlc.descriptions) do
		if not dlc.content_on_consoles then
			local content = dlc.content

			if content then
				local loot_drops = content.loot_drops

				if loot_drops then
					for _, loot_drop in ipairs(loot_drops) do
						if #loot_drop > 0 then
							for _, lp in ipairs(loot_drop) do
								_modify_loot_drop(lp)
							end
						else
							_modify_loot_drop(loot_drop)
						end
					end

					content.loot_drops = {}
				end
			end
		end
	end
end

-- Lines 106-108
function GenericDLCManager:achievement_locked_content()
	return self._achievement_locked_content
end

-- Lines 109-111
function GenericDLCManager:is_mask_achievement_locked(mask_id)
	return self._achievement_locked_content.masks and self._achievement_locked_content.masks[mask_id]
end

-- Lines 112-114
function GenericDLCManager:is_material_achievement_locked(material_id)
	return self._achievement_locked_content.materials and self._achievement_locked_content.materials[material_id]
end

-- Lines 115-117
function GenericDLCManager:is_texture_achievement_locked(texture_id)
	return self._achievement_locked_content.textures and self._achievement_locked_content.textures[texture_id]
end

-- Lines 118-120
function GenericDLCManager:is_weapon_mod_achievement_locked(weapon_mod_id)
	return self._achievement_locked_content.weapon_mods and self._achievement_locked_content.weapon_mods[weapon_mod_id]
end

-- Lines 122-124
function GenericDLCManager:on_tweak_data_reloaded()
	self:setup()
end

-- Lines 126-128
function GenericDLCManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
end

-- Lines 130-131
function GenericDLCManager:chk_content_updated()
end

-- Lines 138-159
function GenericDLCManager:give_dlc_and_verify_blackmarket()
	self:give_dlc_package()

	if managers.blackmarket then
		managers.blackmarket:verify_dlc_items()
	else
		Application:error("[GenericDLCManager] _load_done(): BlackMarketManager not yet initialized!")
	end
end

-- Lines 161-163
function GenericDLCManager:_load_done(...)
	self:give_dlc_and_verify_blackmarket()
end

-- Lines 165-188
function GenericDLCManager:give_dlc_package()
	for package_id, data in pairs(tweak_data.dlc.descriptions) do
		if self:is_dlc_unlocked(package_id) then
			local identifier = UpgradesManager.AQUIRE_STRINGS[5] .. tostring(package_id)

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				if not managers.upgrades:aquired(upgrade, identifier) then
					managers.upgrades:aquire_default(upgrade, identifier)
				end
			end
		else
			local identifier = UpgradesManager.AQUIRE_STRINGS[5] .. tostring(package_id)

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				if managers.upgrades:aquired(upgrade, identifier) then
					managers.upgrades:unaquire(upgrade, identifier)
				end
			end
		end
	end
end

-- Lines 235-261
function GenericDLCManager:list_dlc_package(dlcs)
	local t = {}

	for package_id, data in pairs(tweak_data.dlc.descriptions) do
		if not dlcs or dlcs[package_id] or table.contains(dlcs, package_id) then
			for _, loot_drop in ipairs(data.content.loot_drops or {}) do
				t.items = t.items or {}

				if #loot_drop <= 0 then
					local global_value = loot_drop.global_value or data.content.loot_global_value or package_id
					local category = loot_drop.type_items
					local entry = loot_drop.item_entry
					local amount = loot_drop.amount

					table.insert(t.items, {
						global_value,
						category,
						entry,
						amount
					})
				end
			end

			for _, upgrade in ipairs(data.content.upgrades or {}) do
				t.upgrades = t.upgrades or {}

				table.insert(t.upgrades, upgrade)
			end
		end
	end

	return t
end

-- Lines 263-265
function GenericDLCManager:save(data)
	data.dlc_save = Global.dlc_save
end

-- Lines 267-271
function GenericDLCManager:load(data)
	if data.dlc_save and data.dlc_save.packages then
		Global.dlc_save = data.dlc_save
	end
end

-- Lines 273-277
function GenericDLCManager:on_reset_profile()
	Global.dlc_save = nil

	self:_set_dlc_save_table()
	self:give_dlc_package()
end

-- Lines 279-282
function GenericDLCManager:on_achievement_award_loot()
	Application:debug("GenericDLCManager:on_achievement_award_loot()")
	self:give_dlc_package()
end

-- Lines 284-285
function GenericDLCManager:on_signin_complete()
end

-- Lines 287-294
function GenericDLCManager:is_dlcs_unlocked(list_of_dlcs)
	for _, dlc in ipairs(list_of_dlcs) do
		if not self:is_dlc_unlocked(dlc) then
			return false
		end
	end

	return true
end

-- Lines 296-298
function GenericDLCManager:is_dlc_unlocked(dlc)
	return tweak_data.dlc.descriptions[dlc] and tweak_data.dlc.descriptions[dlc].free or self:has_dlc(dlc)
end

-- Lines 300-318
function GenericDLCManager:has_dlc(dlc)
	local dlc_description = tweak_data.dlc.descriptions[dlc]

	if dlc_description and dlc_description.dlc then
		if self[dlc_description.dlc] then
			return self[dlc_description.dlc](self, dlc_description)
		else
			Application:error("Didn't have dlc has function for", dlc, "has_dlc()", dlc_description.dlc)
			Application:stack_dump()
		end
	end

	local dlc_data = Global.dlc_manager.all_dlc_data[dlc]

	if not dlc_data then
		Application:error("Didn't have dlc data for", dlc)

		return false
	end

	return dlc_data.verified
end

-- Lines 320-322
function GenericDLCManager:has_full_game()
	return Global.dlc_manager.all_dlc_data.full_game.verified
end

-- Lines 324-326
function GenericDLCManager:is_trial()
	return not self:has_full_game()
end

-- Lines 328-336
function GenericDLCManager:is_installing()
	if not DB:is_bundled() or SystemInfo:platform() == Idstring("WIN32") then
		return false, 1
	end

	local install_progress = Application:installer():get_progress()
	local is_installing = install_progress < 1

	return is_installing, install_progress
end

-- Lines 339-344
function GenericDLCManager:dlcs_string()
	local s = ""
	s = s .. (self:is_dlc_unlocked("preorder") and "preorder " or "")

	return s
end

-- Lines 346-348
function GenericDLCManager:has_corrupt_data()
	return self._has_corrupt_data
end

-- Lines 352-354
function GenericDLCManager:has_all_dlcs()
	return true
end

-- Lines 358-360
function GenericDLCManager:has_preorder()
	return Global.dlc_manager.all_dlc_data.preorder and Global.dlc_manager.all_dlc_data.preorder.verified
end

-- Lines 364-367
function GenericDLCManager:has_achievement(data)
	local achievement = managers.achievment and data and data.achievement_id and managers.achievment:get_info(data.achievement_id)

	return achievement and achievement.awarded or false
end

PS3DLCManager = PS3DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("PS3"):key()] = PS3DLCManager
PS3DLCManager.SERVICE_ID = "EP4040-BLES01902_00"

-- Lines 380-400
function PS3DLCManager:init()
	PS3DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					filename = "full_game_key.edat",
					product_id = self.SERVICE_ID .. "-PAYDAY2NPEU00000"
				},
				preorder = {
					filename = "preorder_dlc_key.edat",
					product_id = self.SERVICE_ID .. "-PPAYDAY2XX000006"
				}
			}
		}

		self:_verify_dlcs()
	end
end

-- Lines 403-422
function PS3DLCManager:_verify_dlcs()
	local all_dlc = {}

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified then
			table.insert(all_dlc, dlc_data.filename)
		end
	end

	local verified_dlcs = PS3:check_dlc_availability(all_dlc)
	Global.dlc_manager.verified_dlcs = verified_dlcs

	for _, verified_filename in pairs(verified_dlcs) do
		for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
			if dlc_data.filename == verified_filename then
				print("DLC verified:", verified_filename)

				dlc_data.verified = true

				break
			end
		end
	end
end

-- Lines 424-445
function PS3DLCManager:_init_NPCommerce()
	PS3:set_service_id(self.SERVICE_ID)

	local result = NPCommerce:init()

	print("init result", result)

	if not result then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	local result = NPCommerce:open(callback(self, self, "cb_NPCommerce"))

	print("open result", result)

	if result < 0 then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	return true
end

-- Lines 447-462
function PS3DLCManager:buy_full_game()
	print("[PS3DLCManager:buy_full_game]")

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		product = "full_game",
		type = "buy_product"
	}
	self._activity = {
		type = "open"
	}
end

-- Lines 464-479
function PS3DLCManager:buy_product(product_name)
	print("[PS3DLCManager:buy_product]", product_name)

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		type = "buy_product",
		product = product_name
	}
	self._activity = {
		type = "open"
	}
end

-- Lines 481-535
function PS3DLCManager:cb_NPCommerce(result, info)
	print("[PS3DLCManager:cb_NPCommerce]", result, info)

	for i, k in pairs(info) do
		print(i, k)
	end

	self._NPCommerce_cb_results = self._NPCommerce_cb_results or {}

	print("self._activity", self._activity and inspect(self._activity))
	table.insert(self._NPCommerce_cb_results, {
		result,
		info
	})

	if not self._activity then
		return
	elseif self._activity.type == "open" then
		if info.category_error or info.category_done == false then
			self._activity = nil

			managers.system_menu:close("waiting_for_NPCommerce_open")
			self:_close_NPCommerce()
		else
			managers.system_menu:close("waiting_for_NPCommerce_open")

			local product_id = Global.dlc_manager.all_dlc_data[self._request.product].product_id

			print("starting storebrowse", product_id)

			local ret = NPCommerce:storebrowse("product", product_id, true)

			if not ret then
				self._activity = nil

				managers.menu:show_NPCommerce_checkout_fail()
				self:_close_NPCommerce()
			end

			self._activity = {
				type = "browse"
			}
		end
	elseif self._activity.type == "browse" then
		if info.browse_succes then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_success()
			self:_close_NPCommerce()
		elseif info.browse_back then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.category_error then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_fail()
			self:_close_NPCommerce()
		end
	elseif self._activity.type == "checkout" then
		if info.checkout_error then
			self._activity = nil

			managers.menu:show_NPCommerce_checkout_fail()
			self:_close_NPCommerce()
		elseif info.checkout_cancel then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.checkout_success then
			self._activity = nil

			self:_close_NPCommerce()
		end
	end

	print("/[PS3DLCManager:cb_NPCommerce]")
end

-- Lines 539-542
function PS3DLCManager:_close_NPCommerce()
	print("[PS3DLCManager:_close_NPCommerce]")
	NPCommerce:destroy()
end

-- Lines 546-548
function PS3DLCManager:cb_confirm_purchase_yes(sku_data)
	NPCommerce:checkout(sku_data.skuid)
end

-- Lines 552-555
function PS3DLCManager:cb_confirm_purchase_no()
	self._activity = nil

	self:_close_NPCommerce()
end

X360DLCManager = X360DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("X360"):key()] = X360DLCManager

-- Lines 562-585
function X360DLCManager:init()
	X360DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					is_default = true,
					verified = true,
					index = 0
				},
				preorder = {
					is_default = false,
					index = 1
				}
			}
		}

		self:_verify_dlcs()
	end
end

-- Lines 587-615
function X360DLCManager:_verify_dlcs()
	local found_dlc = {}
	local status = XboxLive:check_dlc_availability(0, 100, found_dlc)

	if not status then
		Application:error("XboxLive:check_dlc_availability failed", inspect(found_dlc))

		return
	end

	print("[X360DLCManager:_verify_dlcs] found DLC:")

	for i, k in pairs(found_dlc) do
		print(i, k)
	end

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if found_dlc[dlc_data.index] == "corrupt" then
			print("[X360DLCManager:_verify_dlcs] Found corrupt DLC:", dlc_name)

			dlc_data.is_corrupt = true
		elseif dlc_data.is_default or found_dlc[dlc_data.index] == true then
			dlc_data.verified = true
		else
			dlc_data.verified = false
		end
	end

	if found_dlc.has_corrupt_data then
		print("[X360DLCManager:_verify_dlcs] Found at least one corrupt DLC.")

		self._has_corrupt_data = true
	end
end

-- Lines 617-619
function X360DLCManager:on_signin_complete()
	self:_verify_dlcs()
end

PS4DLCManager = PS4DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("PS4"):key()] = PS4DLCManager
PS4DLCManager.SERVICE_ID = "EP4040-BLES01902_00"

-- Lines 629-646
function PS4DLCManager:init()
	PS4DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					verified = true
				},
				preorder = {
					verified = false
				}
			}
		}

		self:_verify_dlcs()
	end
end

-- Lines 649-657
function PS4DLCManager:_verify_dlcs()
	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if dlc_data.is_default or dlc_data.verified == true then
			dlc_data.verified = true
		else
			dlc_data.verified = PS3:has_entitlement(dlc_data.product_id)
		end
	end
end

-- Lines 659-680
function PS4DLCManager:_init_NPCommerce()
	local result = NPCommerce:init()

	print("init result", result)

	if not result then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	local result = NPCommerce:open(callback(self, self, "cb_NPCommerce"))

	print("open result", result)

	if result < 0 then
		MenuManager:show_np_commerce_init_fail()
		NPCommerce:destroy()

		return
	end

	return true
end

-- Lines 682-697
function PS4DLCManager:buy_full_game()
	print("[PS4DLCManager:buy_full_game]")

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		product = "full_game",
		type = "buy_product"
	}
	self._activity = {
		type = "open"
	}
end

-- Lines 699-714
function PS4DLCManager:buy_product(product_name)
	print("[PS4DLCManager:buy_product]", product_name)

	if self._activity then
		return
	end

	if not self:_init_NPCommerce() then
		return
	end

	managers.menu:show_waiting_NPCommerce_open()

	self._request = {
		type = "buy_product",
		product = product_name
	}
	self._activity = {
		type = "open"
	}
end

-- Lines 716-770
function PS4DLCManager:cb_NPCommerce(result, info)
	print("[PS4DLCManager:cb_NPCommerce]", result, info)

	for i, k in pairs(info) do
		print(i, k)
	end

	self._NPCommerce_cb_results = self._NPCommerce_cb_results or {}

	print("self._activity", self._activity and inspect(self._activity))
	table.insert(self._NPCommerce_cb_results, {
		result,
		info
	})

	if not self._activity then
		return
	elseif self._activity.type == "open" then
		if info.category_error or info.category_done == false then
			self._activity = nil

			managers.system_menu:close("waiting_for_NPCommerce_open")
			self:_close_NPCommerce()
		else
			managers.system_menu:close("waiting_for_NPCommerce_open")

			local product_id = Global.dlc_manager.all_dlc_data[self._request.product].product_id

			print("starting storebrowse", product_id)

			local ret = NPCommerce:storebrowse("product", product_id, true)

			if not ret then
				self._activity = nil

				managers.menu:show_NPCommerce_checkout_fail()
				self:_close_NPCommerce()
			end

			self._activity = {
				type = "browse"
			}
		end
	elseif self._activity.type == "browse" then
		if info.browse_succes then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_success()
			self:_close_NPCommerce()
		elseif info.browse_back then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.category_error then
			self._activity = nil

			managers.menu:show_NPCommerce_browse_fail()
			self:_close_NPCommerce()
		end
	elseif self._activity.type == "checkout" then
		if info.checkout_error then
			self._activity = nil

			managers.menu:show_NPCommerce_checkout_fail()
			self:_close_NPCommerce()
		elseif info.checkout_cancel then
			self._activity = nil

			self:_close_NPCommerce()
		elseif info.checkout_success then
			self._activity = nil

			self:_close_NPCommerce()
		end
	end

	print("/[PS4DLCManager:cb_NPCommerce]")
end

-- Lines 774-777
function PS4DLCManager:_close_NPCommerce()
	print("[PS4DLCManager:_close_NPCommerce]")
	NPCommerce:destroy()
end

-- Lines 781-783
function PS4DLCManager:cb_confirm_purchase_yes(sku_data)
	NPCommerce:checkout(sku_data.skuid)
end

-- Lines 787-790
function PS4DLCManager:cb_confirm_purchase_no()
	self._activity = nil

	self:_close_NPCommerce()
end

XB1DLCManager = XB1DLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("XB1"):key()] = XB1DLCManager

-- Lines 798-820
function XB1DLCManager:init()
	XB1DLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					is_default = true,
					verified = true,
					index = 0
				},
				preorder = {
					is_default = false,
					product_id = "123456",
					index = 1
				}
			}
		}

		self:_verify_dlcs()
	end
end

-- Lines 822-837
function XB1DLCManager:_verify_dlcs()
	local dlc_content_updated = false
	local old_verified = nil

	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		old_verified = dlc_data.verified or false

		if dlc_data.is_default then
			dlc_data.verified = true
		else
			dlc_data.verified = XboxLive:check_dlc(dlc_data.product_id)
		end

		dlc_content_updated = dlc_content_updated or old_verified ~= dlc_data.verified
	end

	return dlc_content_updated
end

-- Lines 839-852
function XB1DLCManager:chk_content_updated()
	print("[XB1DLCManager:chk_content_updated]")

	if not managers.blackmarket:currently_customizing_mask() and self:_verify_dlcs() then
		print("[XB1DLCManager:chk_content_updated] content updated")

		if managers.experience and managers.upgrades then
			for level = 1, managers.experience:current_level() do
				managers.upgrades:aquire_from_level_tree(level, true)
				managers.upgrades:verify_level_tree(level, true)
			end
		end

		self:give_dlc_and_verify_blackmarket()
	end
end

-- Lines 854-857
function XB1DLCManager:on_signin_complete()
	self:chk_content_updated()
end

WINDLCManager = WINDLCManager or class(GenericDLCManager)
DLCManager.PLATFORM_CLASS_MAP[Idstring("WIN32"):key()] = WINDLCManager

-- Lines 866-905
function WINDLCManager:init()
	WINDLCManager.super.init(self)

	if not Global.dlc_manager then
		Global.dlc_manager = {
			all_dlc_data = {
				full_game = {
					verified = true,
					no_install = true,
					external = true,
					app_id = tostring(self:get_app_id())
				},
				preorder = {
					app_id = "707070",
					no_install = true
				},
				special_edition = {
					app_id = "707080",
					no_install = true
				},
				raid_community = {
					no_install = true,
					source_id = "103582791460014708"
				},
				official_soundtrack = {
					app_id = "720860",
					no_install = true
				}
			}
		}

		self:_verify_dlcs()
	end
end

-- Lines 907-909
function WINDLCManager:get_app_id()
	return 414740
end

-- Lines 911-927
function WINDLCManager:_check_dlc_data(dlc_data)
	if SystemInfo:distribution() == Idstring("STEAM") then
		if dlc_data.app_id then
			if dlc_data.no_install then
				if Steam:is_product_owned(dlc_data.app_id) then
					return true
				end
			elseif Steam:is_product_installed(dlc_data.app_id) then
				return true
			end
		elseif dlc_data.source_id and Steam:is_user_in_source(Steam:userid(), dlc_data.source_id) then
			return true
		end
	end
end

-- Lines 929-941
function WINDLCManager:_verify_dlcs()
	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified and self:_check_dlc_data(dlc_data) then
			dlc_data.verified = true
		end
	end
end

-- Lines 943-950
function WINDLCManager:chk_content_updated()
	for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
		if not dlc_data.verified and self:_check_dlc_data(dlc_data) then
			managers.menu:show_dlc_require_restart()

			break
		end
	end
end
