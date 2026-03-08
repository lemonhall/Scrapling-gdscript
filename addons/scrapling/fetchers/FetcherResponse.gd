extends RefCounted
class_name FetcherResponse

var _status := 0
var _text := ""
var _headers: Dictionary = {}


func _init(status_code: int = 0, body_text: String = "", response_headers: Dictionary = {}) -> void:
	_status = status_code
	_text = body_text
	_headers = response_headers.duplicate(true)


func get_status() -> int:
	return _status


func get_text() -> String:
	return _text


func get_headers() -> Dictionary:
	return _headers.duplicate(true)


func get_header(name: String, default: String = "") -> String:
	if _headers.has(name):
		return str(_headers[name])
	for key in _headers.keys():
		if str(key).to_lower() == name.to_lower():
			return str(_headers[key])
	return default
