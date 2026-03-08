@tool
extends EditorPlugin

const ScraplingRoot := preload("res://addons/scrapling/Scrapling.gd")


func _enter_tree() -> void:
	var instance: Variant = ScraplingRoot.new()
	if instance == null:
		push_error("Failed to instantiate Scrapling root")


func _exit_tree() -> void:
	pass
