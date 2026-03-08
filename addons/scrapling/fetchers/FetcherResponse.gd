extends RefCounted
class_name FetcherResponse

var _status := 0
var _text := ""


func _init(status_code: int = 0, body_text: String = "") -> void:
	_status = status_code
	_text = body_text


func get_status() -> int:
	return _status


func get_text() -> String:
	return _text
