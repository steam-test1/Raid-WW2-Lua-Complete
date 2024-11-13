LinkPrefabsTweakData = LinkPrefabsTweakData or class()

function LinkPrefabsTweakData:init()
	self.default_align_obj = "root_point"
	self.truck_cargo_001 = {
		align_obj = "anim_body",
		props = {
			{
				rot = nil,
				pos = nil,
				unit = "units/vanilla/props/props_sandbags_05/props_sandbags_05",
				pos = Vector3(0, 25, 70),
				rot = Rotation(0, 0, 0)
			},
			{
				sequences = nil,
				pos = nil,
				rot = nil,
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
