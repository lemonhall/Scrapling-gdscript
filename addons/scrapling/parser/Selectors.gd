extends RefCounted
class_name Selectors

var _items: Array = []


func _init(items: Array = []) -> void:
	_items = items.duplicate()


func size() -> int:
	return _items.size()


func get(index: int) -> Variant:
	return _items[index]


func to_array() -> Array:
	return _items.duplicate()
