extends RefCounted
class_name Fetcher

const FetcherResponseScript := preload("res://addons/scrapling/fetchers/FetcherResponse.gd")
const STATUS_MARKER := "__STATUS__"
const CURL_JSON_HEADER := "Content-Type: application/json"

var _default_headers: Dictionary = {}
var _cookie_jar_path := ""


func _init(default_headers: Dictionary = {}, cookie_jar_path: String = "") -> void:
	_default_headers = default_headers.duplicate(true)
	_cookie_jar_path = cookie_jar_path


func fetch_get(url: String, params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null) -> Variant:
	return _curl_request(url, "GET", "", params, headers, cookies, proxy, proxy_rotator)


func fetch_post(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null) -> Variant:
	return _curl_request(url, "POST", body, params, headers, cookies, proxy, proxy_rotator)


func fetch_put(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null) -> Variant:
	return _curl_request(url, "PUT", body, params, headers, cookies, proxy, proxy_rotator)


func fetch_delete(url: String, body: String = "", params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null) -> Variant:
	return _curl_request(url, "DELETE", body, params, headers, cookies, proxy, proxy_rotator)


func _curl_request(url: String, method: String, body: String, params: Dictionary = {}, headers: Dictionary = {}, cookies: Dictionary = {}, proxy: Variant = null, proxy_rotator: Variant = null) -> Variant:
	var output: Array = []
	var request_url := _append_query_params(url, params)
	var args: Array = ["-sS", "-X", method]
	_append_header_args(args, _merge_headers(headers))
	_append_cookie_jar_args(args)
	_append_cookie_args(args, cookies)
	_append_proxy_args(args, _resolve_proxy(proxy, proxy_rotator))
	var temp_body_path := ""
	if _should_send_body(method, body):
		temp_body_path = _write_request_body_file(body)
		if temp_body_path == "":
			return FetcherResponseScript.new(0, "")
		args.append_array(["-H", CURL_JSON_HEADER, "--data-binary", "@" + temp_body_path])
	args.append_array(["-w", STATUS_MARKER + "%{http_code}", request_url])
	var exit_code := OS.execute("curl.exe", args, output, true)
	if temp_body_path != "":
		DirAccess.remove_absolute(temp_body_path)
	if exit_code != 0:
		return FetcherResponseScript.new(0, "")
	var combined := "".join(output)
	var marker_index := combined.rfind(STATUS_MARKER)
	if marker_index < 0:
		return FetcherResponseScript.new(0, combined)
	var response_body := combined.substr(0, marker_index)
	var status_text := combined.substr(marker_index + STATUS_MARKER.length())
	return FetcherResponseScript.new(int(status_text), response_body)


func _write_request_body_file(body: String) -> String:
	var temp_file_name := "scrapling-request-%s.json" % str(Time.get_ticks_usec())
	var project_temp_path := "user://%s" % temp_file_name
	var file := FileAccess.open(project_temp_path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(body)
	file.close()
	return ProjectSettings.globalize_path(project_temp_path)


func _should_send_body(method: String, body: String) -> bool:
	if body == "":
		return false
	return method == "POST" or method == "PUT" or method == "DELETE"


func _append_query_params(url: String, params: Dictionary) -> String:
	if params.is_empty():
		return url
	var parts: Array[String] = []
	for key in params.keys():
		parts.append("%s=%s" % [str(key).uri_encode(), str(params[key]).uri_encode()])
	var separator := "?"
	if url.contains("?"):
		separator = "&"
	return url + separator + "&".join(parts)


func _append_header_args(args: Array, headers: Dictionary) -> void:
	if headers.is_empty():
		return
	for key in headers.keys():
		args.append_array(["-H", "%s: %s" % [str(key), str(headers[key])]])


func _merge_headers(headers: Dictionary) -> Dictionary:
	var merged := _default_headers.duplicate(true)
	for key in headers.keys():
		merged[key] = headers[key]
	return merged


func _append_cookie_jar_args(args: Array) -> void:
	if _cookie_jar_path == "":
		return
	args.append_array(["-b", _cookie_jar_path, "-c", _cookie_jar_path])


func _append_cookie_args(args: Array, cookies: Dictionary) -> void:
	if cookies.is_empty():
		return
	var parts: Array[String] = []
	for key in cookies.keys():
		parts.append("%s=%s" % [str(key), str(cookies[key])])
	args.append_array(["-b", "; ".join(parts)])


func _resolve_proxy(proxy: Variant, proxy_rotator: Variant) -> Variant:
	if proxy_rotator != null and proxy_rotator.has_method("resolve_proxy"):
		return proxy_rotator.call("resolve_proxy", proxy)
	return proxy


func _append_proxy_args(args: Array, proxy: Variant) -> void:
	if proxy == null:
		return
	if proxy is String:
		if String(proxy) == "":
			return
		args.append_array(["-x", String(proxy)])
		return
	if proxy is Dictionary:
		var server := str(proxy.get("server", ""))
		if server == "":
			return
		args.append_array(["-x", server])
		var username := str(proxy.get("username", ""))
		var password := str(proxy.get("password", ""))
		if username != "" or password != "":
			args.append_array(["-U", "%s:%s" % [username, password]])

