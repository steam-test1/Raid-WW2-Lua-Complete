LinkPrefabsTweakData = LinkPrefabsTweakData or class()

-- Lines 17-69
function LinkPrefabsTweakData:init()
	self.default_align_obj = "root_point"
	self.truck_cargo_001 = {
		align_obj = "anim_body",
		props = {
			{
				unit = "units/vanilla/props/props_sandbags_05/props_sandbags_05",
				pos = Vector3(0, 25, 70),
				rot = Rotation(0, 0, 0)
			},
			{
				unit = "units/vanilla/turrets/turret_m2/turret_m2",
				pos = Vector3(0, -10, 70),
				rot = Rotation(0, 0, 0),
				sequences = {
					_init = "disable_search_for_enemies"
				}
			}
		}
	}
end
