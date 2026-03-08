extends SceneTree

const T := preload("res://tests/_test_util.gd")


func _init() -> void:
	var base_url := OS.get_environment("SCRAPLING_FIXTURE_BASE_URL")
	if not T.require_true(self, base_url != "", "SCRAPLING_FIXTURE_BASE_URL must be set for fetcher tests"):
		return

	var fetcher_script := load("res://addons/scrapling/fetchers/Fetcher.gd")
	if not T.require_true(self, fetcher_script != null, "Failed to load res://addons/scrapling/fetchers/Fetcher.gd"):
		return

	var fetcher: Variant = fetcher_script.new()
	if not T.require_true(self, fetcher != null, "Failed to instantiate Fetcher.gd"):
		return

	var missing_response: Variant = fetcher.call("fetch_get", base_url + "/missing")
	if not T.require_eq(self, missing_response.call("get_status"), 404, "Unknown route must produce 404"):
		return

	var timeout_response: Variant = fetcher.call("fetch_get", base_url + "/slow?delay=1.0", {}, {}, {}, null, null, 0.2)
	if not T.require_true(self, timeout_response != null, "Timeout request must still return a response object"):
		return
	if not T.require_eq(self, timeout_response.call("get_status"), 0, "Timed out request must return status 0"):
		return
	if not T.require_eq(self, String(timeout_response.call("get_text")), "", "Timed out request must return empty body"):
		return

	T.pass_and_quit(self)
