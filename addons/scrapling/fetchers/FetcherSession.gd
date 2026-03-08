extends RefCounted
class_name FetcherSession

const FetcherScript := preload("res://addons/scrapling/fetchers/Fetcher.gd")

var _fetcher: Variant = null
var _cookie_jar_path := ""
var _default_proxy: Variant = null
var _default_proxy_rotator: Variant = null
var _default_timeout_sec := -1.0


func _init(default_headers: Dictionary = {}, default_proxy: Variant = null, default_proxy_rotator: Variant = null, default_timeout_sec: float = -1.0) -> void:
	_cookie_jar_path = _create_cookie_jar_file()
	_default_proxy = default_proxy
	_default_proxy_rotator = default_proxy_rotator
	_default_timeout_sec = default_timeout_sec
	_fetcher = FetcherScript.new(default_headers, _cookie_jar_path)


func fetch_get(url: String, params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0) -> Variant:
	return _fetcher.fetch_get(url, params, headers, cookies, _resolve_proxy(proxy), _resolve_rotator(proxy_rotator), _resolve_timeout(timeout_sec))


func fetch_post(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0) -> Variant:
	return _fetcher.fetch_post(url, body, params, headers, cookies, _resolve_proxy(proxy), _resolve_rotator(proxy_rotator), _resolve_timeout(timeout_sec))


func fetch_put(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0) -> Variant:
	return _fetcher.fetch_put(url, body, params, headers, cookies, _resolve_proxy(proxy), _resolve_rotator(proxy_rotator), _resolve_timeout(timeout_sec))


func fetch_delete(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null, timeout_sec: float = -1.0) -> Variant:
	return _fetcher.fetch_delete(url, body, params, headers, cookies, _resolve_proxy(proxy), _resolve_rotator(proxy_rotator), _resolve_timeout(timeout_sec))


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


func _resolve_proxy(proxy: Variant) -> Variant:
	if proxy != null:
		return proxy
	return _default_proxy


func _resolve_rotator(proxy_rotator: Variant) -> Variant:
	if proxy_rotator != null:
		return proxy_rotator
	return _default_proxy_rotator


func _resolve_timeout(timeout_sec: float) -> float:
	if timeout_sec > 0.0:
		return timeout_sec
	return _default_timeout_sec
