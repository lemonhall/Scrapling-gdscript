extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for async response metadata tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/AsyncFetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/AsyncFetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate AsyncFetcher.gd"):
		return

	var header_response: Variant = await fetcher.fetch_get(base_url + "/set-cookie")
	if not T.require_true(self, header_response != null, "Async fetcher must return a response object"):
		return
	if not T.require_true(self, header_response.has_method("get_headers"), "Async fetcher response must expose get_headers()"):
		return
	if not T.require_true(self, header_response.has_method("get_header"), "Async fetcher response must expose get_header()"):
		return
	if not T.require_eq(self, header_response.call("get_status"), 200, "Unexpected async /set-cookie status"):
		return

	var headers: Variant = header_response.call("get_headers")
	if not T.require_true(self, headers is Dictionary, "Async response headers must be a Dictionary"):
		return
	var content_type := String(header_response.call("get_header", "Content-Type"))
	if not T.require_true(self, content_type.contains("application/json"), "Async response Content-Type must be captured"):
		return
	var set_cookie := String(header_response.call("get_header", "Set-Cookie"))
	if not T.require_true(self, set_cookie.contains("session_id=abc123"), "Async response Set-Cookie must be captured"):
		return

	var missing_response: Variant = await fetcher.fetch_get(base_url + "/missing")
	if not T.require_eq(self, missing_response.call("get_status"), 404, "Async missing route must produce 404"):
		return

	var timeout_response: Variant = await fetcher.fetch_get(base_url + "/slow?delay=1.0", {}, {}, {}, null, null, 0.2)
	if not T.require_true(self, timeout_response != null, "Async timeout request must still return a response object"):
		return
	if not T.require_eq(self, timeout_response.call("get_status"), 0, "Async timed out request must return status 0"):
		return
	if not T.require_eq(self, String(timeout_response.call("get_text")), "", "Async timed out request must return empty body"):
		return

	T.pass_and_quit(self)
