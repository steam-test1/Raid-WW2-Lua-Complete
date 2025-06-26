ComicBookTweakData = ComicBookTweakData or class()

function ComicBookTweakData:init()
	self.special_edition = {
		front_cover = true,
		page_count = 14,
		page_h = 912,
		page_w = 593,
		texture_path = "ui/comic_book/special_edition",
		back_cover = true,
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
		texture_rect = {
			left = {
				0,
				0,
				1024,
				2048
			},
			right = {
				1024,
				0,
				1024,
				2048
			}
		}
	}
	self.georg = {
		front_cover = true,
		page_count = 3,
		page_h = 912,
		page_w = 593,
		texture_path = "ui/comic_book/georg",
		texture_rect = {
			left = {
				0,
				0,
				1024,
				2048
			},
			right = {
				1024,
				0,
				1024,
				2048
			}
		}
	}
end
