extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	if not T.require_true(self, FileAccess.file_exists("res://project.godot"), "Missing res://project.godot"):
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not T.require_true(self, project_text.contains("config/name=\"Scrapling-gdscript\""), "project.godot must declare config/name=\"Scrapling-gdscript\""):
		return
	if not T.require_true(self, project_text.contains("config/features=PackedStringArray(\"4.6\")"), "project.godot must target Godot 4.6"):
		return

	if not T.require_true(self, FileAccess.file_exists("res://addons/scrapling/plugin.cfg"), "Missing res://addons/scrapling/plugin.cfg"):
		return

	var plugin_cfg := ConfigFile.new()
	var plugin_err := plugin_cfg.load("res://addons/scrapling/plugin.cfg")
	if not T.require_eq(self, plugin_err, OK, "plugin.cfg must be readable"):
		return
	if not T.require_eq(self, str(plugin_cfg.get_value("plugin", "name", "")), "Scrapling", "plugin name must be Scrapling"):
		return
	if not T.require_true(self, FileAccess.file_exists("res://addons/scrapling/plugin.gd"), "Missing res://addons/scrapling/plugin.gd"):
		return

	var scrapling_script := load("res://addons/scrapling/Scrapling.gd")
	if not T.require_true(self, scrapling_script != null, "Failed to load res://addons/scrapling/Scrapling.gd"):
		return

	var scrapling: Variant = scrapling_script.new()
	if not T.require_true(self, scrapling != null, "Failed to instantiate Scrapling.gd"):
		return
	if not T.require_true(self, scrapling is RefCounted, "Scrapling root object must extend RefCounted"):
		return
	if not T.require_true(self, scrapling.has_method("get_plugin_name"), "Scrapling.gd must define get_plugin_name()"):
		return
	if not T.require_eq(self, scrapling.call("get_plugin_name"), "Scrapling", "Unexpected plugin name"):
		return
	if not T.require_true(self, scrapling.has_method("get_target_engine"), "Scrapling.gd must define get_target_engine()"):
		return
	if not T.require_eq(self, scrapling.call("get_target_engine"), "4.6", "Unexpected target engine"):
		return

	T.pass_and_quit(self)
