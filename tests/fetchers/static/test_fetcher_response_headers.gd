extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for response header tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/Fetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	var response: Variant = fetcher.call("fetch_get", base_url + "/set-cookie")
	if not T.require_true(self, response != null, "Fetcher must return a response object"):
		return
	if not T.require_true(self, response.has_method("get_headers"), "FetcherResponse must expose get_headers()"):
		return
	if not T.require_true(self, response.has_method("get_header"), "FetcherResponse must expose get_header()"):
		return

	var headers: Variant = response.call("get_headers")
	if not T.require_true(self, headers is Dictionary, "Response headers must be a Dictionary"):
		return
	var content_type := String(response.call("get_header", "Content-Type"))
	if not T.require_true(self, content_type.contains("application/json"), "Content-Type header must be captured"):
		return
	var set_cookie := String(response.call("get_header", "Set-Cookie"))
	if not T.require_true(self, set_cookie.contains("session_id=abc123"), "Set-Cookie header must be captured"):
		return

	T.pass_and_quit(self)
