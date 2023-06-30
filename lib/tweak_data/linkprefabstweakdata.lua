LinkPrefabsTweakData = LinkPrefabsTweakData or class()

function LinkPrefabsTweakData:init()
	self.default_align_obj = "root_point"
	self.truck_cargo_001 = {
		align_obj = "anim_body",
		props = {
			{
				unit = "units/vanilla/props/props_wood_box_weapons/props_wooden_box_weapons2",
				pos = Vector3(0, 0, 60),
				rot = Rotation(90, 0, 0),
				sequences = {
					_init = "set_body_animated"
				}
			},
			{
				unit = "units/vanilla/props/props_wood_box_weapons/props_wooden_box_weapons2",
				pos = Vector3(0, 0, 85),
				rot = Rotation(88, 0, 0),
				sequences = {
					_init = "set_body_animated"
				}
			},
			{
				unit = "units/vanilla/props/props_wood_box_weapons/props_wooden_box_weapons2",
				pos = Vector3(0, -55, 60),
				rot = Rotation(93, 0, 0),
				sequences = {
					_init = "set_body_animated"
				}
			}
		}
	}
end
