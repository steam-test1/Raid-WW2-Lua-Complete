core:import("CoreMenuNode")

ComicBookInteractionExt = ComicBookInteractionExt or class(UseInteractionExt)

function ComicBookInteractionExt:init(unit)
	ComicBookInteractionExt.super.init(self, unit)

	local comic_data = tweak_data.comic_book[self._comic_id]

	if not comic_data or comic_data.dlc and not managers.dlc:is_dlc_unlocked(comic_data.dlc) then
		self._unit:set_slot(0)
	end
end

function ComicBookInteractionExt:can_select(player, locator)
	local comic_data = tweak_data.comic_book[self._comic_id]

	if not comic_data then
		return false
	end

	if comic_data.dlc then
		return managers.dlc:is_dlc_unlocked(comic_data.dlc)
	end

	return true
end

function ComicBookInteractionExt:interact(player)
	ComicBookInteractionExt.super.super.interact(self, player)

	local success = managers.raid_menu:open_menu("comic_book_menu")

	if success then
		managers.menu_component:set_comic_book_id(self._comic_id)
	end

	return success
end
