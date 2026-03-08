extends RefCounted
class_name FetcherSession

const FetcherScript := preload("res://addons/scrapling/fetchers/Fetcher.gd")

var _fetcher: Variant = null
var _cookie_jar_path := ""


func _init(default_headers: Dictionary = {}) -> void:
	_cookie_jar_path = _create_cookie_jar_file()
	_fetcher = FetcherScript.new(default_headers, _cookie_jar_path)


func fetch_get(url: String, params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}) -> Variant:
	return _fetcher.fetch_get(url, params, headers, cookies)


func fetch_post(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}) -> Variant:
	return _fetcher.fetch_post(url, body, params, headers, cookies)


func fetch_put(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}) -> Variant:
	return _fetcher.fetch_put(url, body, params, headers, cookies)


func fetch_delete(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}) -> Variant:
	return _fetcher.fetch_delete(url, body, params, headers, cookies)


func close() -> void:
	if _cookie_jar_path == "":
		return
	DirAccess.remove_absolute(_cookie_jar_path)
	_cookie_jar_path = ""


func _create_cookie_jar_file() -> String:
	var jar_name := "scrapling-session-%s.cookies" % str(Time.get_ticks_usec())
	var project_path := "user://%s" % jar_name
	var file := FileAccess.open(project_path, FileAccess.WRITE)
	if file == null:
		return ""
	file.close()
	return ProjectSettings.globalize_path(project_path)
