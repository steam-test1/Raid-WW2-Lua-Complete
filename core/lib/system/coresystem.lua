require("core/lib/system/CorePatchLua")
require("core/lib/system/CorePatchEngine")
require("core/lib/system/CoreModule")
require("core/lib/system/CoreModules")
require("core/lib/system/CoreGlobals")
core:import("CoreExtendLua")
core:import("CoreEngineAccess")

managers = managers or {}

core:_add_to_pristine_and_global("managers", managers)
core:_copy_module_to_global("CoreClass")
core:_copy_module_to_global("CoreCode")
core:_copy_module_to_global("CoreDebug")
core:_copy_module_to_global("CoreEvent")
core:_copy_module_to_global("CoreEws")
core:_copy_module_to_global("CoreInput")
core:_copy_module_to_global("CoreMath")
core:_copy_module_to_global("CoreOldModule")
core:_copy_module_to_global("CoreString")
core:_copy_module_to_global("CoreTable")
core:_copy_module_to_global("CoreUnit")
core:_copy_module_to_global("CoreXml")
core:_copy_module_to_global("CoreApp")
core:_close_pristine_namespace()
